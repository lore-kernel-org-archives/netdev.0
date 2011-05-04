From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 8/9] ixgbe: improve EEPROM read/write operations
Date: Wed,  4 May 2011 12:30:40 -0700
Message-ID: <1304537441-2056-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65312 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755436Ab1EDTau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:50 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Introduce buffered read/writes which greatly improves performance on
parts with large EEPROMs.

Previously reading/writing a word requires taking/releasing of synchronization
semaphores which adds 10ms to each operation. The optimization is to
read/write in buffers, but make sure the semaphore is not held for >500ms
according to the datasheet.

Since we can't read the EEPROM page size ixgbe_detect_eeprom_page_size() is
used to discover the EEPROM size when needed and keeps the result in
word_page_size for the rest of the run time.

Use buffered reads for ethtool -e.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c   |    1 +
 drivers/net/ixgbe/ixgbe_82599.c   |   35 +++
 drivers/net/ixgbe/ixgbe_common.c  |  440 +++++++++++++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_common.h  |    8 +
 drivers/net/ixgbe/ixgbe_ethtool.c |    7 +-
 drivers/net/ixgbe/ixgbe_type.h    |    7 +
 drivers/net/ixgbe/ixgbe_x540.c    |   67 +++++-
 7 files changed, 465 insertions(+), 100 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 7a64f50..8179e50 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1281,6 +1281,7 @@ static struct ixgbe_mac_operations mac_ops_82598 = {
 static struct ixgbe_eeprom_operations eeprom_ops_82598 = {
 	.init_params		= &ixgbe_init_eeprom_params_generic,
 	.read			= &ixgbe_read_eerd_generic,
+	.read_buffer		= &ixgbe_read_eerd_buffer_generic,
 	.calc_checksum          = &ixgbe_calc_eeprom_checksum_generic,
 	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
 	.update_checksum	= &ixgbe_update_eeprom_checksum_generic,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5b8e17e..dba5ca6 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -2064,6 +2064,39 @@ out:
 }
 
 /**
+ *  ixgbe_read_eeprom_buffer_82599 - Read EEPROM word(s) using
+ *  fastest available method
+ *
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in EEPROM to read
+ *  @words: number of words
+ *  @data: word(s) read from the EEPROM
+ *
+ *  Retrieves 16 bit word(s) read from EEPROM
+ **/
+static s32 ixgbe_read_eeprom_buffer_82599(struct ixgbe_hw *hw, u16 offset,
+					  u16 words, u16 *data)
+{
+	struct ixgbe_eeprom_info *eeprom = &hw->eeprom;
+	s32 ret_val = IXGBE_ERR_CONFIG;
+
+	/*
+	 * If EEPROM is detected and can be addressed using 14 bits,
+	 * use EERD otherwise use bit bang
+	 */
+	if ((eeprom->type == ixgbe_eeprom_spi) &&
+	    (offset + (words - 1) <= IXGBE_EERD_MAX_ADDR))
+		ret_val = ixgbe_read_eerd_buffer_generic(hw, offset, words,
+							 data);
+	else
+		ret_val = ixgbe_read_eeprom_buffer_bit_bang_generic(hw, offset,
+								    words,
+								    data);
+
+	return ret_val;
+}
+
+/**
  *  ixgbe_read_eeprom_82599 - Read EEPROM word using
  *  fastest available method
  *
@@ -2139,7 +2172,9 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 static struct ixgbe_eeprom_operations eeprom_ops_82599 = {
 	.init_params		= &ixgbe_init_eeprom_params_generic,
 	.read			= &ixgbe_read_eeprom_82599,
+	.read_buffer		= &ixgbe_read_eeprom_buffer_82599,
 	.write			= &ixgbe_write_eeprom_generic,
+	.write_buffer		= &ixgbe_write_eeprom_buffer_bit_bang_generic,
 	.calc_checksum		= &ixgbe_calc_eeprom_checksum_generic,
 	.validate_checksum	= &ixgbe_validate_eeprom_checksum_generic,
 	.update_checksum	= &ixgbe_update_eeprom_checksum_generic,
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index cb2e8e1..c4730cd 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -55,6 +55,12 @@ static s32 ixgbe_negotiate_fc(struct ixgbe_hw *hw, u32 adv_reg, u32 lp_reg,
 			      u32 adv_sym, u32 adv_asm, u32 lp_sym, u32 lp_asm);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
 static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
+static s32 ixgbe_read_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
+					     u16 words, u16 *data);
+static s32 ixgbe_write_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
+					     u16 words, u16 *data);
+static s32 ixgbe_detect_eeprom_page_size_generic(struct ixgbe_hw *hw,
+						 u16 offset);
 
 /**
  *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
@@ -585,6 +591,8 @@ s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw)
 		/* Set default semaphore delay to 10ms which is a well
 		 * tested value */
 		eeprom->semaphore_delay = 10;
+		/* Clear EEPROM page size, it will be initialized as needed */
+		eeprom->word_page_size = 0;
 
 		/*
 		 * Check for EEPROM present first.
@@ -617,26 +625,78 @@ s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_write_eeprom_generic - Writes 16 bit value to EEPROM
+ *  ixgbe_write_eeprom_buffer_bit_bang_generic - Write EEPROM using bit-bang
  *  @hw: pointer to hardware structure
- *  @offset: offset within the EEPROM to be written to
- *  @data: 16 bit word to be written to the EEPROM
+ *  @offset: offset within the EEPROM to write
+ *  @words: number of words
+ *  @data: 16 bit word(s) to write to EEPROM
  *
- *  If ixgbe_eeprom_update_checksum is not called after this function, the
- *  EEPROM will most likely contain an invalid checksum.
+ *  Reads 16 bit word(s) from EEPROM through bit-bang method
  **/
-s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
+s32 ixgbe_write_eeprom_buffer_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+					       u16 words, u16 *data)
 {
-	s32 status;
-	u8 write_opcode = IXGBE_EEPROM_WRITE_OPCODE_SPI;
+	s32 status = 0;
+	u16 i, count;
 
 	hw->eeprom.ops.init_params(hw);
 
-	if (offset >= hw->eeprom.word_size) {
+	if (words == 0) {
+		status = IXGBE_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
+
+	if (offset + words > hw->eeprom.word_size) {
 		status = IXGBE_ERR_EEPROM;
 		goto out;
 	}
 
+	/*
+	 * The EEPROM page size cannot be queried from the chip. We do lazy
+	 * initialization. It is worth to do that when we write large buffer.
+	 */
+	if ((hw->eeprom.word_page_size == 0) &&
+	    (words > IXGBE_EEPROM_PAGE_SIZE_MAX))
+		ixgbe_detect_eeprom_page_size_generic(hw, offset);
+
+	/*
+	 * We cannot hold synchronization semaphores for too long
+	 * to avoid other entity starvation. However it is more efficient
+	 * to read in bursts than synchronizing access for each word.
+	 */
+	for (i = 0; i < words; i += IXGBE_EEPROM_RD_BUFFER_MAX_COUNT) {
+		count = (words - i) / IXGBE_EEPROM_RD_BUFFER_MAX_COUNT > 0 ?
+			 IXGBE_EEPROM_RD_BUFFER_MAX_COUNT : (words - i);
+		status = ixgbe_write_eeprom_buffer_bit_bang(hw, offset + i,
+							    count, &data[i]);
+
+		if (status != 0)
+			break;
+	}
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_write_eeprom_buffer_bit_bang - Writes 16 bit word(s) to EEPROM
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @words: number of word(s)
+ *  @data: 16 bit word(s) to be written to the EEPROM
+ *
+ *  If ixgbe_eeprom_update_checksum is not called after this function, the
+ *  EEPROM will most likely contain an invalid checksum.
+ **/
+static s32 ixgbe_write_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
+					      u16 words, u16 *data)
+{
+	s32 status;
+	u16 word;
+	u16 page_size;
+	u16 i;
+	u8 write_opcode = IXGBE_EEPROM_WRITE_OPCODE_SPI;
+
 	/* Prepare the EEPROM for writing  */
 	status = ixgbe_acquire_eeprom(hw);
 
@@ -648,62 +708,147 @@ s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
 	}
 
 	if (status == 0) {
-		ixgbe_standby_eeprom(hw);
+		for (i = 0; i < words; i++) {
+			ixgbe_standby_eeprom(hw);
 
-		/*  Send the WRITE ENABLE command (8 bit opcode )  */
-		ixgbe_shift_out_eeprom_bits(hw, IXGBE_EEPROM_WREN_OPCODE_SPI,
-		                            IXGBE_EEPROM_OPCODE_BITS);
+			/*  Send the WRITE ENABLE command (8 bit opcode )  */
+			ixgbe_shift_out_eeprom_bits(hw,
+						  IXGBE_EEPROM_WREN_OPCODE_SPI,
+						  IXGBE_EEPROM_OPCODE_BITS);
 
-		ixgbe_standby_eeprom(hw);
+			ixgbe_standby_eeprom(hw);
 
-		/*
-		 * Some SPI eeproms use the 8th address bit embedded in the
-		 * opcode
-		 */
-		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
-			write_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+			/*
+			 * Some SPI eeproms use the 8th address bit embedded
+			 * in the opcode
+			 */
+			if ((hw->eeprom.address_bits == 8) &&
+			    ((offset + i) >= 128))
+				write_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+			/* Send the Write command (8-bit opcode + addr) */
+			ixgbe_shift_out_eeprom_bits(hw, write_opcode,
+						    IXGBE_EEPROM_OPCODE_BITS);
+			ixgbe_shift_out_eeprom_bits(hw, (u16)((offset + i) * 2),
+						    hw->eeprom.address_bits);
+
+			page_size = hw->eeprom.word_page_size;
+
+			/* Send the data in burst via SPI*/
+			do {
+				word = data[i];
+				word = (word >> 8) | (word << 8);
+				ixgbe_shift_out_eeprom_bits(hw, word, 16);
+
+				if (page_size == 0)
+					break;
+
+				/* do not wrap around page */
+				if (((offset + i) & (page_size - 1)) ==
+				    (page_size - 1))
+					break;
+			} while (++i < words);
+
+			ixgbe_standby_eeprom(hw);
+			usleep_range(10000, 20000);
+		}
+		/* Done with writing - release the EEPROM */
+		ixgbe_release_eeprom(hw);
+	}
 
-		/* Send the Write command (8-bit opcode + addr) */
-		ixgbe_shift_out_eeprom_bits(hw, write_opcode,
-		                            IXGBE_EEPROM_OPCODE_BITS);
-		ixgbe_shift_out_eeprom_bits(hw, (u16)(offset*2),
-		                            hw->eeprom.address_bits);
+	return status;
+}
 
-		/* Send the data */
-		data = (data >> 8) | (data << 8);
-		ixgbe_shift_out_eeprom_bits(hw, data, 16);
-		ixgbe_standby_eeprom(hw);
+/**
+ *  ixgbe_write_eeprom_generic - Writes 16 bit value to EEPROM
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @data: 16 bit word to be written to the EEPROM
+ *
+ *  If ixgbe_eeprom_update_checksum is not called after this function, the
+ *  EEPROM will most likely contain an invalid checksum.
+ **/
+s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
+{
+	s32 status;
 
-		/* Done with writing - release the EEPROM */
-		ixgbe_release_eeprom(hw);
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
 	}
 
+	status = ixgbe_write_eeprom_buffer_bit_bang(hw, offset, 1, &data);
+
 out:
 	return status;
 }
 
 /**
- *  ixgbe_read_eeprom_bit_bang_generic - Read EEPROM word using bit-bang
+ *  ixgbe_read_eeprom_buffer_bit_bang_generic - Read EEPROM using bit-bang
  *  @hw: pointer to hardware structure
  *  @offset: offset within the EEPROM to be read
- *  @data: read 16 bit value from EEPROM
+ *  @words: number of word(s)
+ *  @data: read 16 bit words(s) from EEPROM
  *
- *  Reads 16 bit value from EEPROM through bit-bang method
+ *  Reads 16 bit word(s) from EEPROM through bit-bang method
  **/
-s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
-                                       u16 *data)
+s32 ixgbe_read_eeprom_buffer_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+					      u16 words, u16 *data)
 {
-	s32 status;
-	u16 word_in;
-	u8 read_opcode = IXGBE_EEPROM_READ_OPCODE_SPI;
+	s32 status = 0;
+	u16 i, count;
 
 	hw->eeprom.ops.init_params(hw);
 
-	if (offset >= hw->eeprom.word_size) {
+	if (words == 0) {
+		status = IXGBE_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
+
+	if (offset + words > hw->eeprom.word_size) {
 		status = IXGBE_ERR_EEPROM;
 		goto out;
 	}
 
+	/*
+	 * We cannot hold synchronization semaphores for too long
+	 * to avoid other entity starvation. However it is more efficient
+	 * to read in bursts than synchronizing access for each word.
+	 */
+	for (i = 0; i < words; i += IXGBE_EEPROM_RD_BUFFER_MAX_COUNT) {
+		count = (words - i) / IXGBE_EEPROM_RD_BUFFER_MAX_COUNT > 0 ?
+			 IXGBE_EEPROM_RD_BUFFER_MAX_COUNT : (words - i);
+
+		status = ixgbe_read_eeprom_buffer_bit_bang(hw, offset + i,
+							   count, &data[i]);
+
+		if (status != 0)
+			break;
+	}
+
+out:
+	return status;
+}
+
+/**
+ *  ixgbe_read_eeprom_buffer_bit_bang - Read EEPROM using bit-bang
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be read
+ *  @words: number of word(s)
+ *  @data: read 16 bit word(s) from EEPROM
+ *
+ *  Reads 16 bit word(s) from EEPROM through bit-bang method
+ **/
+static s32 ixgbe_read_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
+					     u16 words, u16 *data)
+{
+	s32 status;
+	u16 word_in;
+	u8 read_opcode = IXGBE_EEPROM_READ_OPCODE_SPI;
+	u16 i;
+
 	/* Prepare the EEPROM for reading  */
 	status = ixgbe_acquire_eeprom(hw);
 
@@ -715,104 +860,208 @@ s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
 	}
 
 	if (status == 0) {
-		ixgbe_standby_eeprom(hw);
+		for (i = 0; i < words; i++) {
+			ixgbe_standby_eeprom(hw);
+			/*
+			 * Some SPI eeproms use the 8th address bit embedded
+			 * in the opcode
+			 */
+			if ((hw->eeprom.address_bits == 8) &&
+			    ((offset + i) >= 128))
+				read_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+			/* Send the READ command (opcode + addr) */
+			ixgbe_shift_out_eeprom_bits(hw, read_opcode,
+						    IXGBE_EEPROM_OPCODE_BITS);
+			ixgbe_shift_out_eeprom_bits(hw, (u16)((offset + i) * 2),
+						    hw->eeprom.address_bits);
+
+			/* Read the data. */
+			word_in = ixgbe_shift_in_eeprom_bits(hw, 16);
+			data[i] = (word_in >> 8) | (word_in << 8);
+		}
 
-		/*
-		 * Some SPI eeproms use the 8th address bit embedded in the
-		 * opcode
-		 */
-		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
-			read_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+		/* End this read operation */
+		ixgbe_release_eeprom(hw);
+	}
 
-		/* Send the READ command (opcode + addr) */
-		ixgbe_shift_out_eeprom_bits(hw, read_opcode,
-		                            IXGBE_EEPROM_OPCODE_BITS);
-		ixgbe_shift_out_eeprom_bits(hw, (u16)(offset*2),
-		                            hw->eeprom.address_bits);
+	return status;
+}
 
-		/* Read the data. */
-		word_in = ixgbe_shift_in_eeprom_bits(hw, 16);
-		*data = (word_in >> 8) | (word_in << 8);
+/**
+ *  ixgbe_read_eeprom_bit_bang_generic - Read EEPROM word using bit-bang
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be read
+ *  @data: read 16 bit value from EEPROM
+ *
+ *  Reads 16 bit value from EEPROM through bit-bang method
+ **/
+s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+				       u16 *data)
+{
+	s32 status;
 
-		/* End this read operation */
-		ixgbe_release_eeprom(hw);
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
 	}
 
+	status = ixgbe_read_eeprom_buffer_bit_bang(hw, offset, 1, data);
+
 out:
 	return status;
 }
 
 /**
- *  ixgbe_read_eerd_generic - Read EEPROM word using EERD
+ *  ixgbe_read_eerd_buffer_generic - Read EEPROM word(s) using EERD
  *  @hw: pointer to hardware structure
- *  @offset: offset of  word in the EEPROM to read
- *  @data: word read from the EEPROM
+ *  @offset: offset of word in the EEPROM to read
+ *  @words: number of word(s)
+ *  @data: 16 bit word(s) from the EEPROM
  *
- *  Reads a 16 bit word from the EEPROM using the EERD register.
+ *  Reads a 16 bit word(s) from the EEPROM using the EERD register.
  **/
-s32 ixgbe_read_eerd_generic(struct ixgbe_hw *hw, u16 offset, u16 *data)
+s32 ixgbe_read_eerd_buffer_generic(struct ixgbe_hw *hw, u16 offset,
+				   u16 words, u16 *data)
 {
 	u32 eerd;
-	s32 status;
+	s32 status = 0;
+	u32 i;
 
 	hw->eeprom.ops.init_params(hw);
 
+	if (words == 0) {
+		status = IXGBE_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
+
 	if (offset >= hw->eeprom.word_size) {
 		status = IXGBE_ERR_EEPROM;
 		goto out;
 	}
 
-	eerd = (offset << IXGBE_EEPROM_RW_ADDR_SHIFT) +
-	       IXGBE_EEPROM_RW_REG_START;
+	for (i = 0; i < words; i++) {
+		eerd = ((offset + i) << IXGBE_EEPROM_RW_ADDR_SHIFT) +
+		       IXGBE_EEPROM_RW_REG_START;
 
-	IXGBE_WRITE_REG(hw, IXGBE_EERD, eerd);
-	status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_READ);
+		IXGBE_WRITE_REG(hw, IXGBE_EERD, eerd);
+		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_READ);
 
-	if (status == 0)
-		*data = (IXGBE_READ_REG(hw, IXGBE_EERD) >>
-		         IXGBE_EEPROM_RW_REG_DATA);
-	else
-		hw_dbg(hw, "Eeprom read timed out\n");
+		if (status == 0) {
+			data[i] = (IXGBE_READ_REG(hw, IXGBE_EERD) >>
+				   IXGBE_EEPROM_RW_REG_DATA);
+		} else {
+			hw_dbg(hw, "Eeprom read timed out\n");
+			goto out;
+		}
+	}
+out:
+	return status;
+}
 
+/**
+ *  ixgbe_detect_eeprom_page_size_generic - Detect EEPROM page size
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be used as a scratch pad
+ *
+ *  Discover EEPROM page size by writing marching data at given offset.
+ *  This function is called only when we are writing a new large buffer
+ *  at given offset so the data would be overwritten anyway.
+ **/
+static s32 ixgbe_detect_eeprom_page_size_generic(struct ixgbe_hw *hw,
+						 u16 offset)
+{
+	u16 data[IXGBE_EEPROM_PAGE_SIZE_MAX];
+	s32 status = 0;
+	u16 i;
+
+	for (i = 0; i < IXGBE_EEPROM_PAGE_SIZE_MAX; i++)
+		data[i] = i;
+
+	hw->eeprom.word_page_size = IXGBE_EEPROM_PAGE_SIZE_MAX;
+	status = ixgbe_write_eeprom_buffer_bit_bang(hw, offset,
+					     IXGBE_EEPROM_PAGE_SIZE_MAX, data);
+	hw->eeprom.word_page_size = 0;
+	if (status != 0)
+		goto out;
+
+	status = ixgbe_read_eeprom_buffer_bit_bang(hw, offset, 1, data);
+	if (status != 0)
+		goto out;
+
+	/*
+	 * When writing in burst more than the actual page size
+	 * EEPROM address wraps around current page.
+	 */
+	hw->eeprom.word_page_size = IXGBE_EEPROM_PAGE_SIZE_MAX - data[0];
+
+	hw_dbg(hw, "Detected EEPROM page size = %d words.",
+	       hw->eeprom.word_page_size);
 out:
 	return status;
 }
 
 /**
- *  ixgbe_write_eewr_generic - Write EEPROM word using EEWR
+ *  ixgbe_read_eerd_generic - Read EEPROM word using EERD
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to read
+ *  @data: word read from the EEPROM
+ *
+ *  Reads a 16 bit word from the EEPROM using the EERD register.
+ **/
+s32 ixgbe_read_eerd_generic(struct ixgbe_hw *hw, u16 offset, u16 *data)
+{
+	return ixgbe_read_eerd_buffer_generic(hw, offset, 1, data);
+}
+
+/**
+ *  ixgbe_write_eewr_buffer_generic - Write EEPROM word(s) using EEWR
  *  @hw: pointer to hardware structure
  *  @offset: offset of  word in the EEPROM to write
- *  @data: word write to the EEPROM
+ *  @words: number of words
+ *  @data: word(s) write to the EEPROM
  *
- *  Write a 16 bit word to the EEPROM using the EEWR register.
+ *  Write a 16 bit word(s) to the EEPROM using the EEWR register.
  **/
-s32 ixgbe_write_eewr_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
+s32 ixgbe_write_eewr_buffer_generic(struct ixgbe_hw *hw, u16 offset,
+				    u16 words, u16 *data)
 {
 	u32 eewr;
-	s32 status;
+	s32 status = 0;
+	u16 i;
 
 	hw->eeprom.ops.init_params(hw);
 
+	if (words == 0) {
+		status = IXGBE_ERR_INVALID_ARGUMENT;
+		goto out;
+	}
+
 	if (offset >= hw->eeprom.word_size) {
 		status = IXGBE_ERR_EEPROM;
 		goto out;
 	}
 
-	eewr = (offset << IXGBE_EEPROM_RW_ADDR_SHIFT) |
-	       (data << IXGBE_EEPROM_RW_REG_DATA) | IXGBE_EEPROM_RW_REG_START;
+	for (i = 0; i < words; i++) {
+		eewr = ((offset + i) << IXGBE_EEPROM_RW_ADDR_SHIFT) |
+		       (data[i] << IXGBE_EEPROM_RW_REG_DATA) |
+		       IXGBE_EEPROM_RW_REG_START;
 
-	status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
-	if (status != 0) {
-		hw_dbg(hw, "Eeprom write EEWR timed out\n");
-		goto out;
-	}
+		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
+		if (status != 0) {
+			hw_dbg(hw, "Eeprom write EEWR timed out\n");
+			goto out;
+		}
 
-	IXGBE_WRITE_REG(hw, IXGBE_EEWR, eewr);
+		IXGBE_WRITE_REG(hw, IXGBE_EEWR, eewr);
 
-	status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
-	if (status != 0) {
-		hw_dbg(hw, "Eeprom write EEWR timed out\n");
-		goto out;
+		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
+		if (status != 0) {
+			hw_dbg(hw, "Eeprom write EEWR timed out\n");
+			goto out;
+		}
 	}
 
 out:
@@ -820,6 +1069,19 @@ out:
 }
 
 /**
+ *  ixgbe_write_eewr_generic - Write EEPROM word using EEWR
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to write
+ *  @data: word write to the EEPROM
+ *
+ *  Write a 16 bit word to the EEPROM using the EEWR register.
+ **/
+s32 ixgbe_write_eewr_generic(struct ixgbe_hw *hw, u16 offset, u16 data)
+{
+	return ixgbe_write_eewr_buffer_generic(hw, offset, 1, &data);
+}
+
+/**
  *  ixgbe_poll_eerd_eewr_done - Poll EERD read or EEWR write status
  *  @hw: pointer to hardware structure
  *  @ee_reg: EEPROM flag for polling
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index e850adb..46be83c 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -49,10 +49,18 @@ s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index);
 
 s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw);
 s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
+s32 ixgbe_write_eeprom_buffer_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+					       u16 words, u16 *data);
 s32 ixgbe_read_eerd_generic(struct ixgbe_hw *hw, u16 offset, u16 *data);
+s32 ixgbe_read_eerd_buffer_generic(struct ixgbe_hw *hw, u16 offset,
+				   u16 words, u16 *data);
 s32 ixgbe_write_eewr_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
+s32 ixgbe_write_eewr_buffer_generic(struct ixgbe_hw *hw, u16 offset,
+				    u16 words, u16 *data);
 s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
                                        u16 *data);
+s32 ixgbe_read_eeprom_buffer_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
+					      u16 words, u16 *data);
 u16 ixgbe_calc_eeprom_checksum_generic(struct ixgbe_hw *hw);
 s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
                                            u16 *checksum_val);
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 410c298..f2efa32 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -847,11 +847,8 @@ static int ixgbe_get_eeprom(struct net_device *netdev,
 	if (!eeprom_buff)
 		return -ENOMEM;
 
-	for (i = 0; i < eeprom_len; i++) {
-		if ((ret_val = hw->eeprom.ops.read(hw, first_word + i,
-		    &eeprom_buff[i])))
-			break;
-	}
+	ret_val = hw->eeprom.ops.read_buffer(hw, first_word, eeprom_len,
+					     eeprom_buff);
 
 	/* Device's eeprom is always little-endian, word addressable */
 	for (i = 0; i < eeprom_len; i++)
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index fab9737..b1d523c 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1668,6 +1668,10 @@
 
 #define IXGBE_ETH_LENGTH_OF_ADDRESS   6
 
+#define IXGBE_EEPROM_PAGE_SIZE_MAX       128
+#define IXGBE_EEPROM_RD_BUFFER_MAX_COUNT 512 /* EEPROM words # read in burst */
+#define IXGBE_EEPROM_WR_BUFFER_MAX_COUNT 256 /* EEPROM words # wr in burst */
+
 #ifndef IXGBE_EEPROM_GRANT_ATTEMPTS
 #define IXGBE_EEPROM_GRANT_ATTEMPTS 1000 /* EEPROM # attempts to gain grant */
 #endif
@@ -2563,7 +2567,9 @@ typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_ptr,
 struct ixgbe_eeprom_operations {
 	s32 (*init_params)(struct ixgbe_hw *);
 	s32 (*read)(struct ixgbe_hw *, u16, u16 *);
+	s32 (*read_buffer)(struct ixgbe_hw *, u16, u16, u16 *);
 	s32 (*write)(struct ixgbe_hw *, u16, u16);
+	s32 (*write_buffer)(struct ixgbe_hw *, u16, u16, u16 *);
 	s32 (*validate_checksum)(struct ixgbe_hw *, u16 *);
 	s32 (*update_checksum)(struct ixgbe_hw *);
 	u16 (*calc_checksum)(struct ixgbe_hw *);
@@ -2649,6 +2655,7 @@ struct ixgbe_eeprom_info {
 	u32                             semaphore_delay;
 	u16                             word_size;
 	u16                             address_bits;
+	u16                             word_page_size;
 };
 
 #define IXGBE_FLAGS_DOUBLE_RESET_REQUIRED	0x01
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 179ee82..4ed687b 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -304,16 +304,19 @@ static s32 ixgbe_init_eeprom_params_X540(struct ixgbe_hw *hw)
 }
 
 /**
- * ixgbe_read_eerd_X540 - Read EEPROM word using EERD
- * @hw: pointer to hardware structure
- * @offset: offset of word in the EEPROM to read
- * @data: word read from the EERPOM
+ *  ixgbe_read_eerd_X540- Read EEPROM word using EERD
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to read
+ *  @data: word read from the EEPROM
+ *
+ *  Reads a 16 bit word from the EEPROM using the EERD register.
  **/
 static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 {
-	s32 status;
+	s32 status = 0;
 
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0)
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) ==
+	    0)
 		status = ixgbe_read_eerd_generic(hw, offset, data);
 	else
 		status = IXGBE_ERR_SWFW_SYNC;
@@ -323,6 +326,31 @@ static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 }
 
 /**
+ *  ixgbe_read_eerd_buffer_X540 - Read EEPROM word(s) using EERD
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to read
+ *  @words: number of words
+ *  @data: word(s) read from the EEPROM
+ *
+ *  Reads a 16 bit word(s) from the EEPROM using the EERD register.
+ **/
+static s32 ixgbe_read_eerd_buffer_X540(struct ixgbe_hw *hw,
+				       u16 offset, u16 words, u16 *data)
+{
+	s32 status = 0;
+
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) ==
+	    0)
+		status = ixgbe_read_eerd_buffer_generic(hw, offset,
+							words, data);
+	else
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+	return status;
+}
+
+/**
  *  ixgbe_write_eewr_X540 - Write EEPROM word using EEWR
  *  @hw: pointer to hardware structure
  *  @offset: offset of  word in the EEPROM to write
@@ -344,6 +372,31 @@ static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
 }
 
 /**
+ *  ixgbe_write_eewr_buffer_X540 - Write EEPROM word(s) using EEWR
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to write
+ *  @words: number of words
+ *  @data: word(s) write to the EEPROM
+ *
+ *  Write a 16 bit word(s) to the EEPROM using the EEWR register.
+ **/
+static s32 ixgbe_write_eewr_buffer_X540(struct ixgbe_hw *hw,
+					u16 offset, u16 words, u16 *data)
+{
+	s32 status = 0;
+
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) ==
+	    0)
+		status = ixgbe_write_eewr_buffer_generic(hw, offset,
+							 words, data);
+	else
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+	return status;
+}
+
+/**
  *  ixgbe_calc_eeprom_checksum_X540 - Calculates and returns the checksum
  *
  *  This function does not use synchronization for EERD and EEWR. It can
@@ -851,7 +904,9 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
 	.init_params            = &ixgbe_init_eeprom_params_X540,
 	.read                   = &ixgbe_read_eerd_X540,
+	.read_buffer		= &ixgbe_read_eerd_buffer_X540,
 	.write                  = &ixgbe_write_eewr_X540,
+	.write_buffer		= &ixgbe_write_eewr_buffer_X540,
 	.calc_checksum		= &ixgbe_calc_eeprom_checksum_X540,
 	.validate_checksum      = &ixgbe_validate_eeprom_checksum_X540,
 	.update_checksum        = &ixgbe_update_eeprom_checksum_X540,
-- 
1.7.4.4

