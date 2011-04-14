From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 19/24] ixgbe: fix semaphores in eeprom routines for x540
Date: Wed, 13 Apr 2011 18:02:15 -0700
Message-ID: <1302742940-22141-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32675 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758243Ab1DNBCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:41 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

HW can upload EEPROM content from flash while
in a middle of checksum calculation. Take NVM ownership for the whole
process of checksum update.

Call ixgbe_read_eerd_generic() and ixgbe_write_eewr_generic() directly to
avoid double take of semaphores which leads to long loading times.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |   44 +++++++++++-
 drivers/net/ixgbe/ixgbe_common.h |    2 +-
 drivers/net/ixgbe/ixgbe_x540.c   |  154 +++++++++++++++++++++++++++-----------
 3 files changed, 153 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index a67cba5..fc31e02 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -54,6 +54,7 @@ static s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw);
 static s32 ixgbe_negotiate_fc(struct ixgbe_hw *hw, u32 adv_reg, u32 lp_reg,
 			      u32 adv_sym, u32 adv_asm, u32 lp_sym, u32 lp_asm);
 static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num);
+static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 
 /**
  *  ixgbe_start_hw_generic - Prepare hardware for Tx/Rx
@@ -778,6 +779,47 @@ out:
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
+	u32 eewr;
+	s32 status;
+
+	hw->eeprom.ops.init_params(hw);
+
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+		goto out;
+	}
+
+	eewr = (offset << IXGBE_EEPROM_RW_ADDR_SHIFT) |
+	       (data << IXGBE_EEPROM_RW_REG_DATA) | IXGBE_EEPROM_RW_REG_START;
+
+	status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
+	if (status != 0) {
+		hw_dbg(hw, "Eeprom write EEWR timed out\n");
+		goto out;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_EEWR, eewr);
+
+	status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
+	if (status != 0) {
+		hw_dbg(hw, "Eeprom write EEWR timed out\n");
+		goto out;
+	}
+
+out:
+	return status;
+}
+
+/**
  *  ixgbe_poll_eerd_eewr_done - Poll EERD read or EEWR write status
  *  @hw: pointer to hardware structure
  *  @ee_reg: EEPROM flag for polling
@@ -785,7 +827,7 @@ out:
  *  Polls the status bit (bit 1) of the EERD or EEWR to determine when the
  *  read or write is done respectively.
  **/
-s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
+static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg)
 {
 	u32 i;
 	u32 reg;
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 2585bf3..e18dc13 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -50,13 +50,13 @@ s32 ixgbe_led_off_generic(struct ixgbe_hw *hw, u32 index);
 s32 ixgbe_init_eeprom_params_generic(struct ixgbe_hw *hw);
 s32 ixgbe_write_eeprom_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
 s32 ixgbe_read_eerd_generic(struct ixgbe_hw *hw, u16 offset, u16 *data);
+s32 ixgbe_write_eewr_generic(struct ixgbe_hw *hw, u16 offset, u16 data);
 s32 ixgbe_read_eeprom_bit_bang_generic(struct ixgbe_hw *hw, u16 offset,
                                        u16 *data);
 u16 ixgbe_calc_eeprom_checksum_generic(struct ixgbe_hw *hw);
 s32 ixgbe_validate_eeprom_checksum_generic(struct ixgbe_hw *hw,
                                            u16 *checksum_val);
 s32 ixgbe_update_eeprom_checksum_generic(struct ixgbe_hw *hw);
-s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 
 s32 ixgbe_set_rar_generic(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vmdq,
                           u32 enable_addr);
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 8aa1dc1..5433f15 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -322,55 +322,33 @@ static s32 ixgbe_read_eerd_X540(struct ixgbe_hw *hw, u16 offset, u16 *data)
 }
 
 /**
- * ixgbe_write_eewr_X540 - Write EEPROM word using EEWR
- * @hw: pointer to hardware structure
- * @offset: offset of  word in the EEPROM to write
- * @data: word write to the EEPROM
+ *  ixgbe_write_eewr_X540 - Write EEPROM word using EEWR
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to write
+ *  @data: word write to the EEPROM
  *
- * Write a 16 bit word to the EEPROM using the EEWR register.
+ *  Write a 16 bit word to the EEPROM using the EEWR register.
  **/
 static s32 ixgbe_write_eewr_X540(struct ixgbe_hw *hw, u16 offset, u16 data)
 {
-	u32 eewr;
-	s32 status;
-
-	hw->eeprom.ops.init_params(hw);
-
-	if (offset >= hw->eeprom.word_size) {
-		status = IXGBE_ERR_EEPROM;
-		goto out;
-	}
-
-	eewr = (offset << IXGBE_EEPROM_RW_ADDR_SHIFT) |
-	       (data << IXGBE_EEPROM_RW_REG_DATA) |
-	       IXGBE_EEPROM_RW_REG_START;
-
-	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0) {
-		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
-		if (status != 0) {
-			hw_dbg(hw, "Eeprom write EEWR timed out\n");
-			goto out;
-		}
-
-		IXGBE_WRITE_REG(hw, IXGBE_EEWR, eewr);
+	s32 status = 0;
 
-		status = ixgbe_poll_eerd_eewr_done(hw, IXGBE_NVM_POLL_WRITE);
-		if (status != 0) {
-			hw_dbg(hw, "Eeprom write EEWR timed out\n");
-			goto out;
-		}
-	} else {
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0)
+		status = ixgbe_write_eewr_generic(hw, offset, data);
+	else
 		status = IXGBE_ERR_SWFW_SYNC;
-	}
 
-out:
-	ixgbe_release_swfw_sync_X540(hw, IXGBE_GSSR_EEP_SM);
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 	return status;
 }
 
 /**
- * ixgbe_calc_eeprom_checksum_X540 - Calculates and returns the checksum
- * @hw: pointer to hardware structure
+ *  ixgbe_calc_eeprom_checksum_X540 - Calculates and returns the checksum
+ *
+ *  This function does not use synchronization for EERD and EEWR. It can
+ *  be used internally by function which utilize ixgbe_acquire_swfw_sync_X540.
+ *
+ *  @hw: pointer to hardware structure
  **/
 static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 {
@@ -381,9 +359,15 @@ static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 	u16 pointer = 0;
 	u16 word = 0;
 
+	/*
+	 * Do not use hw->eeprom.ops.read because we do not want to take
+	 * the synchronization semaphores here. Instead use
+	 * ixgbe_read_eerd_generic
+	 */
+
 	/* Include 0x0-0x3F in the checksum */
 	for (i = 0; i < IXGBE_EEPROM_CHECKSUM; i++) {
-		if (hw->eeprom.ops.read(hw, i, &word) != 0) {
+		if (ixgbe_read_eerd_generic(hw, i, &word) != 0) {
 			hw_dbg(hw, "EEPROM read failed\n");
 			break;
 		}
@@ -398,7 +382,7 @@ static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 		if (i == IXGBE_PHY_PTR || i == IXGBE_OPTION_ROM_PTR)
 			continue;
 
-		if (hw->eeprom.ops.read(hw, i, &pointer) != 0) {
+		if (ixgbe_read_eerd_generic(hw, i, &pointer) != 0) {
 			hw_dbg(hw, "EEPROM read failed\n");
 			break;
 		}
@@ -408,7 +392,7 @@ static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 		    pointer >= hw->eeprom.word_size)
 			continue;
 
-		if (hw->eeprom.ops.read(hw, pointer, &length) != 0) {
+		if (ixgbe_read_eerd_generic(hw, pointer, &length) != 0) {
 			hw_dbg(hw, "EEPROM read failed\n");
 			break;
 		}
@@ -419,7 +403,7 @@ static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 			continue;
 
 		for (j = pointer+1; j <= pointer+length; j++) {
-			if (hw->eeprom.ops.read(hw, j, &word) != 0) {
+			if (ixgbe_read_eerd_generic(hw, j, &word) != 0) {
 				hw_dbg(hw, "EEPROM read failed\n");
 				break;
 			}
@@ -433,6 +417,62 @@ static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_validate_eeprom_checksum_X540 - Validate EEPROM checksum
+ *  @hw: pointer to hardware structure
+ *  @checksum_val: calculated checksum
+ *
+ *  Performs checksum calculation and validates the EEPROM checksum.  If the
+ *  caller does not need checksum_val, the value can be NULL.
+ **/
+static s32 ixgbe_validate_eeprom_checksum_X540(struct ixgbe_hw *hw,
+					       u16 *checksum_val)
+{
+	s32 status;
+	u16 checksum;
+	u16 read_checksum = 0;
+
+	/*
+	 * Read the first word from the EEPROM. If this times out or fails, do
+	 * not continue or we could be in for a very long wait while every
+	 * EEPROM read fails
+	 */
+	status = hw->eeprom.ops.read(hw, 0, &checksum);
+
+	if (status != 0) {
+		hw_dbg(hw, "EEPROM read failed\n");
+		goto out;
+	}
+
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0) {
+		checksum = hw->eeprom.ops.calc_checksum(hw);
+
+		/*
+		 * Do not use hw->eeprom.ops.read because we do not want to take
+		 * the synchronization semaphores twice here.
+		 */
+		ixgbe_read_eerd_generic(hw, IXGBE_EEPROM_CHECKSUM,
+					&read_checksum);
+
+		/*
+		 * Verify read checksum from EEPROM is the same as
+		 * calculated checksum
+		 */
+		if (read_checksum != checksum)
+			status = IXGBE_ERR_EEPROM_CHECKSUM;
+
+		/* If the user cares, return the calculated checksum */
+		if (checksum_val)
+			*checksum_val = checksum;
+	} else {
+		status = IXGBE_ERR_SWFW_SYNC;
+	}
+
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+out:
+	return status;
+}
+
+/**
  * ixgbe_update_eeprom_checksum_X540 - Updates the EEPROM checksum and flash
  * @hw: pointer to hardware structure
  *
@@ -443,11 +483,35 @@ static u16 ixgbe_calc_eeprom_checksum_X540(struct ixgbe_hw *hw)
 static s32 ixgbe_update_eeprom_checksum_X540(struct ixgbe_hw *hw)
 {
 	s32 status;
+	u16 checksum;
 
-	status = ixgbe_update_eeprom_checksum_generic(hw);
+	/*
+	 * Read the first word from the EEPROM. If this times out or fails, do
+	 * not continue or we could be in for a very long wait while every
+	 * EEPROM read fails
+	 */
+	status = hw->eeprom.ops.read(hw, 0, &checksum);
+
+	if (status != 0)
+		hw_dbg(hw, "EEPROM read failed\n");
+
+	if (hw->mac.ops.acquire_swfw_sync(hw, IXGBE_GSSR_EEP_SM) == 0) {
+		checksum = hw->eeprom.ops.calc_checksum(hw);
 
-	if (status)
+		/*
+		 * Do not use hw->eeprom.ops.write because we do not want to
+		 * take the synchronization semaphores twice here.
+		 */
+		status = ixgbe_write_eewr_generic(hw, IXGBE_EEPROM_CHECKSUM,
+						  checksum);
+
+	if (status == 0)
 		status = ixgbe_update_flash_X540(hw);
+	else
+		status = IXGBE_ERR_SWFW_SYNC;
+	}
+
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 
 	return status;
 }
@@ -728,7 +792,7 @@ static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
 	.read                   = &ixgbe_read_eerd_X540,
 	.write                  = &ixgbe_write_eewr_X540,
 	.calc_checksum		= &ixgbe_calc_eeprom_checksum_X540,
-	.validate_checksum      = &ixgbe_validate_eeprom_checksum_generic,
+	.validate_checksum      = &ixgbe_validate_eeprom_checksum_X540,
 	.update_checksum        = &ixgbe_update_eeprom_checksum_X540,
 };
 
-- 
1.7.4.2

