class Dog

	attr_accessor :name, :breed, :id

	def initialize(id:nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
			)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE dogs
		SQL
		DB[:conn].execute(sql)
	end

	def self.create(name:, breed:)
		new_dog = Dog.new(name: name, breed: breed)
		new_dog.save
		new_dog
	end

	def self.find_or_create_by(name:, breed:)
		sql = <<-SQL
			SELECT * FROM dogs
			WHERE name = ? and breed = ?
		SQL
		result = DB[:conn].execute(sql, name, breed)
		if result[0]
			self.find_by_id(result[0][0])
		else
			Dog.create(name: name, breed: breed)
		end
	end

	def self.new_from_db(row)
		Dog.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.find_by_name(name)
		dog_data = DB[:conn].execute("SELECT *
		FROM dogs
		WHERE name = ?", name)
		self.new_from_db(dog_data[0])
		# Dog.new(id: dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2])
	end

	def self.find_by_id(id)
		dog_data = DB[:conn].execute("SELECT *
		FROM dogs
		WHERE dogs.id = #{id}")
		Dog.new(id: dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2])
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs(name, breed)
				VALUES (?, ?)
			SQL
		end
		DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end


	def update
		sql = <<-SQL
			UPDATE dogs
			SET name = ?, breed = ?
			WHERE id = ?
		SQL
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

end