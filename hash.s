# ZACHARIADIS GEWRGIOS 3180055 - CHANIWTIS ANASTASIOS 3180201


#Data which we are going to use in our program with some strings to display in console.
	.data
		menu: .asciiz "\n MENU \n"
		insert: .asciiz "1.Insert Key\n"
		find: .asciiz "2.Find Key\n"
		display: .asciiz "3.Display Hash Table\n"
		exit: .asciiz "4.Exit\n"
		choice: .asciiz "Choice? "
		give: .asciiz "\nGive new key (greater than zero): "
		finder: .asciiz "\nGive key to search for: "
		num_error: .asciiz "\nKey must be greater than zero!\n"
		already_num: .asciiz "\nKey is already in hash table.\n"
		not_in: .asciiz "\nKey is not in hash table.\n"
		value: .asciiz "\nKey value = "
		table_position: .asciiz "\nTable position = "
		full: .asciiz "\nHash table is full.\n"
		print: .asciiz "\npos key\n"
		empty: .asciiz " "
		line: .asciiz "\n"

		HashTable:	.word 0 0 0 0 0 0 0 0 0 0			#Hash Table with initiliazed values '0' zeros. ( amount = 10 )
	.text
	.globl main
#MAIN PROGRAM WITH THE MENU.	
main:
	li $s1,0				#Load current amount of items in the hash table.
	
	MENU:										#Displays the Menu with all the choices we have.
		la $a0, menu
		li $v0, 4
		syscall
		la $a0, insert
		li $v0, 4
		syscall
		la $a0, find
		li $v0, 4
		syscall
		la $a0, display
		li $v0, 4
		syscall
		la $a0, exit
		li $v0, 4
		syscall
		la $a0, choice
		li $v0, 4
		syscall
		li $v0, 5
		syscall

		beq $v0, 4, exit_program					#If the user types '4', the program jumps at exit_program and ends.
		beq $v0, 1, INSERT 							#Jumps at the INSERT function.
		beq $v0, 2, FIND 							#Jumps at the FIND function.
		beq $v0, 3, DISPLAY 						#Jumps at the DISPLAY function.
		
		j MENU

exit_program:						#EXIT
	li $v0, 10
	syscall 		

#INSERT FUNCTION , WHICH IS USED TO INSERT KEYS AT THE HASH TABLE
INSERT:
	la $s7,HashTable			#Load the address of Hash Table.
	la $a0, give 			#Give a number in the console
	li $v0, 4
	syscall

	li $v0, 5
	syscall
	
	move $s0,$v0				#Save our integer we want to store in our Hash Table.
	
	blez $s0, number_error 		#If the number given is lower or equal than zero, jumps at the number_error.

	jal findkey 				#Jumps at the findkey function in order to check if the given number, is already in hash table.
	bne $v1,-1,already 			#Case: Already in the hash table ( jumps at the already function ).
	bge $s1,10,full_table 		#Case: Full Hash Table ( jumps at full_table function ).

	jal hashfunction			#If we don't have any errors, the programm jumps at the hashfunction.

	move $t7,$v1				#Save the position we got from the hashfunction into the register $t7
	mul $t7,$t7,4				#Calculate how many steps we are going to move in our Hash Table in order to get the specific index, to store the integer.
	add $t8,$s7,$t7
	
	sw $s0,($t8)				#Storing the integer in the index we got above.

	addi $s1,$s1,1				#Increase the amount of items.

	j MENU 				#When we finish the insertion, jump again at the main MENU.

number_error:						#Displays the number error: Key must be greater than zero!
	la $a0, num_error
	li $v0, 4
	syscall

	j MENU

#FIND FUNCTION , WHICH IS USED TO FIND OUR KEY IN THE HASH TABLE.
FIND:
	la $s7,HashTable			#Load the address of Hash Table.

	la $a0, finder 				#load the finder string.
	li $v0, 4
	syscall

	li $v0,5				#Take the key we want to search for.
	syscall

	jal findkey 			#Jumps at the findkey function in order to check if the key is in the Hash Table.
	move $s2, $v0 			#Save the key value.

	beq $v1,-1,not_in_hash 				#If the key is not in the Hash Table jumps at the not_in_hash error.

	la $a0,value 				#Displays the value.
	li $v0,4
	syscall

	mul $t7,$s2,4 				
	add $s7,$s7,$t7

	lw $a0,($s7) 				
	li $v0,1
	syscall

	la $a0, table_position 				#Gets the position of the key, in the Hash Table, and displays it.
	li $v0, 4
	syscall

	move $a0,$s2
	li $v0, 1
	syscall

	j MENU 				#When we finish jump again at the main MENU.

#DISPLAY FUNCTION , WHICH DISPLAYS ALL THE VALUES IN THE HASH TABLE.
DISPLAY:
	la $s7,HashTable			#Load the address of Hash Table.
	la $a0, print
	li $v0, 4
	syscall

	li $t5,0 				#i = 0
	for:
		bge $t5,10,MENU 			#for(int i = 0; i < N; i++)
		la $a0,empty 				#Displays (\npos num\n)
		li $v0,4
		syscall 

		move $a0,$t5 				#Position.
		li $v0, 1
		syscall

		la $a0,empty
		li $v0,4
		syscall

		la $a0,empty
		li $v0,4
		syscall  

		lw $a0,($s7) 				#Key value in current position.
		li $v0, 1
		syscall

		addi $s7,$s7,4 				#Goes to the next position in the Hash Table.

		la $a0, line
		li $v0, 4
		syscall 

		addi $t5,$t5,1 				#i++
		j for

	


#FINDKEY FUNCTION TO CHECK IF THE NUMBER GIVEN AT THE CONSOLE IS ALREADY IN HASH TABLE.
findkey:
	li $t0, 0		#i = 0.
	li $t1, 0		#found = 0.
	rem $t3,$v0,10 		#position = k % N.
	move $t6,$v0 			#Save the integer.
	mul $t7,$t3,4 			#Calculating current index in the Hash Table.
	add $t8,$s7,$t7
	lw $t4,($t8) 			#Loads current value in the index we got above.



loop:
	bge $t0,10,notFound			#while( i < N && found == 0).
	bne $t1,$zero,check
	addi $t0, $t0, 1			#i++
	beq $t4, $t6, Found 		#if(hash[position] == k).
	addi $t3,$t3,1				#position++
	rem $t3,$t3,10				#position %= N.
	mul $t7,$t3,4 				#Calculating current index in the Hash Table.
	add $t8,$s7,$t7
	lw $t4,($t8) 				#Loads current value in the index we got above.
	j loop

#HASH FUNCTION IN ORDER TO CHECK WHERE WE ARE GOING TO SAVE THE INTEGER WE WANT TO INSERT AT THE HASH TABLE.
hashfunction:
	rem $t3,$s0,10 					#position = k % N.
	mul $t7,$t3,4 					#Calculating current index in the Hash Table.
	add $t8,$s7,$t7
	lw $t4,($t8) 					#Loads current value in the index we got above.
	while: 							#while( hash[position] != 0).
		beq $t4,0,pos
		addi $t3,$t3,1 				#position++
		rem $t3,$t3,10 				#position = k % N.
		mul $t7,$t3,4 				#Calculating current index in the Hash Table.
		add $t8,$s7,$t7
		lw $t4,($t8) 				#Loads current value in the index we got above.
		j while


Found:					#Found function to return position.
	addi $t1,$t1,1
	j loop

notFound:				#notFound function to return -1.
	addi $t1,$t1,-1
	j check		

check:				#Return the result.
	addi $v1,$t1,0
	addi $v0,$t3,0
	jr $ra

already:				#already function to display: Key is already in hash table.
	la $a0, already_num
	li $v0, 4
	syscall

	j MENU

full_table:				#full_table function to display: Hash table is full
	la $a0, full
	li $v0,4
	syscall 

	j MENU

not_in_hash: 				#not_in_hash function to display: Key is not in hash table.
	la $a0,not_in
	li $v0,4
	syscall

	j MENU

pos: 					#Save the position of the Hash Table, in which we are going to save the integer.
	addi $v1,$t3,0
	jr $ra	