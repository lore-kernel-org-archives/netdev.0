From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 14/14] e1000e: check return code from NVM accesses
	and fix bank detection
Date: Fri, 21 Nov 2008 11:02:56 -0800
Message-ID: <20081121190256.32313.2561.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:45804 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbYKUTDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:03:12 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Check return code for all NVM accesses[1] and error out accordingly; log
a debug message for failed accesses.

For ICH8/9, the valid NVM bank detect function was not checking whether the
SEC1VAL (sector 1 valid) bit in the EECD register was itself valid (bits 8
and 9 also have to be set).  If invalid, it would have defaulted to the
possibly invalid bank 0.  Instead, try to use the valid bank detection
method used by ICH10 which has been cleaned up a bit.

[1] - reads and updates only; not writes because those are only writing to
the Shadow RAM, the update following the write is the only thing actually
writing the modified Shadow RAM contents to the NVM.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---

 drivers/net/e1000e/82571.c   |    5 +-
 drivers/net/e1000e/defines.h |    1 
 drivers/net/e1000e/ethtool.c |   35 +++++++----
 drivers/net/e1000e/ich8lan.c |  134 ++++++++++++++++++++++++++++--------------
 drivers/net/e1000e/netdev.c  |    4 +
 5 files changed, 116 insertions(+), 63 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 60c15cb..cf43ee7 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -332,8 +332,9 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 
 	case e1000_82573:
 		if (pdev->device == E1000_DEV_ID_82573L) {
-			e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1,
-				       &eeprom_data);
+			if (e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1,
+				       &eeprom_data) < 0)
+				break;
 			if (eeprom_data & NVM_WORD1A_ASPM_MASK)
 				adapter->flags &= ~FLAG_HAS_JUMBO_FRAMES;
 		}
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 34a68fc..e6caf29 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -572,6 +572,7 @@
 #define E1000_EECD_FLUPD     0x00080000 /* Update FLASH */
 #define E1000_EECD_AUPDEN    0x00100000 /* Enable Autonomous FLASH update */
 #define E1000_EECD_SEC1VAL   0x00400000 /* Sector One Valid */
+#define E1000_EECD_SEC1VAL_VALID_MASK (E1000_EECD_AUTO_RD | E1000_EECD_PRES)
 
 #define E1000_NVM_RW_REG_DATA   16   /* Offset to data in NVM read/write registers */
 #define E1000_NVM_RW_REG_DONE   2    /* Offset to READ/WRITE done bit */
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 34f1f63..e48956d 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -492,18 +492,19 @@ static int e1000_get_eeprom(struct net_device *netdev,
 		for (i = 0; i < last_word - first_word + 1; i++) {
 			ret_val = e1000_read_nvm(hw, first_word + i, 1,
 						      &eeprom_buff[i]);
-			if (ret_val) {
-				/* a read error occurred, throw away the
-				 * result */
-				memset(eeprom_buff, 0xff, sizeof(eeprom_buff));
+			if (ret_val)
 				break;
-			}
 		}
 	}
 
-	/* Device's eeprom is always little-endian, word addressable */
-	for (i = 0; i < last_word - first_word + 1; i++)
-		le16_to_cpus(&eeprom_buff[i]);
+	if (ret_val) {
+		/* a read error occurred, throw away the result */
+		memset(eeprom_buff, 0xff, sizeof(eeprom_buff));
+	} else {
+		/* Device's eeprom is always little-endian, word addressable */
+		for (i = 0; i < last_word - first_word + 1; i++)
+			le16_to_cpus(&eeprom_buff[i]);
+	}
 
 	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
 	kfree(eeprom_buff);
@@ -555,6 +556,9 @@ static int e1000_set_eeprom(struct net_device *netdev,
 		ret_val = e1000_read_nvm(hw, last_word, 1,
 				  &eeprom_buff[last_word - first_word]);
 
+	if (ret_val)
+		goto out;
+
 	/* Device's eeprom is always little-endian, word addressable */
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
@@ -567,15 +571,18 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	ret_val = e1000_write_nvm(hw, first_word,
 				  last_word - first_word + 1, eeprom_buff);
 
+	if (ret_val)
+		goto out;
+
 	/*
 	 * Update the checksum over the first part of the EEPROM if needed
-	 * and flush shadow RAM for 82573 controllers
+	 * and flush shadow RAM for applicable controllers
 	 */
-	if ((ret_val == 0) && ((first_word <= NVM_CHECKSUM_REG) ||
-			       (hw->mac.type == e1000_82574) ||
-			       (hw->mac.type == e1000_82573)))
-		e1000e_update_nvm_checksum(hw);
+	if ((first_word <= NVM_CHECKSUM_REG) ||
+	    (hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82573))
+		ret_val = e1000e_update_nvm_checksum(hw);
 
+out:
 	kfree(eeprom_buff);
 	return ret_val;
 }
@@ -860,7 +867,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
 		if ((e1000_read_nvm(&adapter->hw, i, 1, &temp)) < 0) {
 			*data = 1;
-			break;
+			return *data;
 		}
 		checksum += temp;
 	}
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 33898ea..92f2ace 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -94,6 +94,8 @@
 
 #define E1000_ICH_NVM_SIG_WORD		0x13
 #define E1000_ICH_NVM_SIG_MASK		0xC000
+#define E1000_ICH_NVM_VALID_SIG_MASK    0xC0
+#define E1000_ICH_NVM_SIG_VALUE         0x80
 
 #define E1000_ICH8_LAN_INIT_TIMEOUT	1500
 
@@ -958,45 +960,62 @@ static s32 e1000_set_d3_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
  *  @bank:  pointer to the variable that returns the active bank
  *
  *  Reads signature byte from the NVM using the flash access registers.
+ *  Word 0x13 bits 15:14 = 10b indicate a valid signature for that bank.
  **/
 static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 {
+	u32 eecd;
 	struct e1000_nvm_info *nvm = &hw->nvm;
-	/* flash bank size is in words */
 	u32 bank1_offset = nvm->flash_bank_size * sizeof(u16);
 	u32 act_offset = E1000_ICH_NVM_SIG_WORD * 2 + 1;
-	u8 bank_high_byte = 0;
+	u8 sig_byte = 0;
+	s32 ret_val = 0;
 
-	if (hw->mac.type != e1000_ich10lan) {
-		if (er32(EECD) & E1000_EECD_SEC1VAL)
-			*bank = 1;
-		else
-			*bank = 0;
-	} else {
-		/*
-		 * Make sure the signature for bank 0 is valid,
-		 * if not check for bank1
-		 */
-		e1000_read_flash_byte_ich8lan(hw, act_offset, &bank_high_byte);
-		if ((bank_high_byte & 0xC0) == 0x80) {
+	switch (hw->mac.type) {
+	case e1000_ich8lan:
+	case e1000_ich9lan:
+		eecd = er32(EECD);
+		if ((eecd & E1000_EECD_SEC1VAL_VALID_MASK) ==
+		    E1000_EECD_SEC1VAL_VALID_MASK) {
+			if (eecd & E1000_EECD_SEC1VAL)
+				*bank = 1;
+			else
+				*bank = 0;
+
+			return 0;
+		}
+		hw_dbg(hw, "Unable to determine valid NVM bank via EEC - "
+		       "reading flash signature\n");
+		/* fall-thru */
+	default:
+		/* set bank to 0 in case flash read fails */
+		*bank = 0;
+
+		/* Check bank 0 */
+		ret_val = e1000_read_flash_byte_ich8lan(hw, act_offset,
+		                                        &sig_byte);
+		if (ret_val)
+			return ret_val;
+		if ((sig_byte & E1000_ICH_NVM_VALID_SIG_MASK) ==
+		    E1000_ICH_NVM_SIG_VALUE) {
 			*bank = 0;
-		} else {
-			/*
-			 * find if segment 1 is valid by verifying
-			 * bit 15:14 = 10b in word 0x13
-			 */
-			e1000_read_flash_byte_ich8lan(hw,
-						      act_offset + bank1_offset,
-						      &bank_high_byte);
+			return 0;
+		}
 
-			/* bank1 has a valid signature equivalent to SEC1V */
-			if ((bank_high_byte & 0xC0) == 0x80) {
-				*bank = 1;
-			} else {
-				hw_dbg(hw, "ERROR: EEPROM not present\n");
-				return -E1000_ERR_NVM;
-			}
+		/* Check bank 1 */
+		ret_val = e1000_read_flash_byte_ich8lan(hw, act_offset +
+		                                        bank1_offset,
+		                                        &sig_byte);
+		if (ret_val)
+			return ret_val;
+		if ((sig_byte & E1000_ICH_NVM_VALID_SIG_MASK) ==
+		    E1000_ICH_NVM_SIG_VALUE) {
+			*bank = 1;
+			return 0;
 		}
+
+		hw_dbg(hw, "ERROR: No valid NVM bank present\n");
+		return -E1000_ERR_NVM;
 	}
 
 	return 0;
@@ -1029,11 +1048,11 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		return ret_val;
+		goto out;
 
 	ret_val = e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
 	if (ret_val)
-		return ret_val;
+		goto release;
 
 	act_offset = (bank) ? nvm->flash_bank_size : 0;
 	act_offset += offset;
@@ -1052,8 +1071,13 @@ static s32 e1000_read_nvm_ich8lan(struct e1000_hw *hw, u16 offset, u16 words,
 		}
 	}
 
+release:
 	e1000_release_swflag_ich8lan(hw);
 
+out:
+	if (ret_val)
+		hw_dbg(hw, "NVM read error: %d\n", ret_val);
+
 	return ret_val;
 }
 
@@ -1342,14 +1366,14 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 
 	ret_val = e1000e_update_nvm_checksum_generic(hw);
 	if (ret_val)
-		return ret_val;
+		goto out;
 
 	if (nvm->type != e1000_nvm_flash_sw)
-		return ret_val;
+		goto out;
 
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	if (ret_val)
-		return ret_val;
+		goto out;
 
 	/*
 	 * We're writing to the opposite bank so if we're on bank 1,
@@ -1357,17 +1381,27 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 * is going to be written
 	 */
 	ret_val =  e1000_valid_nvm_bank_detect_ich8lan(hw, &bank);
-	if (ret_val)
-		return ret_val;
+	if (ret_val) {
+		e1000_release_swflag_ich8lan(hw);
+		goto out;
+	}
 
 	if (bank == 0) {
 		new_bank_offset = nvm->flash_bank_size;
 		old_bank_offset = 0;
-		e1000_erase_flash_bank_ich8lan(hw, 1);
+		ret_val = e1000_erase_flash_bank_ich8lan(hw, 1);
+		if (ret_val) {
+			e1000_release_swflag_ich8lan(hw);
+			goto out;
+		}
 	} else {
 		old_bank_offset = nvm->flash_bank_size;
 		new_bank_offset = 0;
-		e1000_erase_flash_bank_ich8lan(hw, 0);
+		ret_val = e1000_erase_flash_bank_ich8lan(hw, 0);
+		if (ret_val) {
+			e1000_release_swflag_ich8lan(hw);
+			goto out;
+		}
 	}
 
 	for (i = 0; i < E1000_ICH8_SHADOW_RAM_WORDS; i++) {
@@ -1379,9 +1413,11 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		if (dev_spec->shadow_ram[i].modified) {
 			data = dev_spec->shadow_ram[i].value;
 		} else {
-			e1000_read_flash_word_ich8lan(hw,
-						      i + old_bank_offset,
-						      &data);
+			ret_val = e1000_read_flash_word_ich8lan(hw, i +
+			                                        old_bank_offset,
+			                                        &data);
+			if (ret_val)
+				break;
 		}
 
 		/*
@@ -1422,7 +1458,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 		/* Possibly read-only, see e1000e_write_protect_nvm_ich8lan() */
 		hw_dbg(hw, "Flash commit failed.\n");
 		e1000_release_swflag_ich8lan(hw);
-		return ret_val;
+		goto out;
 	}
 
 	/*
@@ -1432,14 +1468,18 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	 * and we need to change bit 14 to 0b
 	 */
 	act_offset = new_bank_offset + E1000_ICH_NVM_SIG_WORD;
-	e1000_read_flash_word_ich8lan(hw, act_offset, &data);
+	ret_val = e1000_read_flash_word_ich8lan(hw, act_offset, &data);
+	if (ret_val) {
+		e1000_release_swflag_ich8lan(hw);
+		goto out;
+	}
 	data &= 0xBFFF;
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw,
 						       act_offset * 2 + 1,
 						       (u8)(data >> 8));
 	if (ret_val) {
 		e1000_release_swflag_ich8lan(hw);
-		return ret_val;
+		goto out;
 	}
 
 	/*
@@ -1452,7 +1492,7 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	ret_val = e1000_retry_write_flash_byte_ich8lan(hw, act_offset, 0);
 	if (ret_val) {
 		e1000_release_swflag_ich8lan(hw);
-		return ret_val;
+		goto out;
 	}
 
 	/* Great!  Everything worked, we can now clear the cached entries. */
@@ -1470,6 +1510,10 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	e1000e_reload_nvm(hw);
 	msleep(10);
 
+out:
+	if (ret_val)
+		hw_dbg(hw, "NVM update error: %d\n", ret_val);
+
 	return ret_val;
 }
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b1b534d..ca5d3f5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4723,14 +4723,14 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 		return;
 
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
-	if (!(le16_to_cpu(buf) & (1 << 0))) {
+	if (!ret_val && (!(le16_to_cpu(buf) & (1 << 0)))) {
 		/* Deep Smart Power Down (DSPD) */
 		dev_warn(&adapter->pdev->dev,
 			 "Warning: detected DSPD enabled in EEPROM\n");
 	}
 
 	ret_val = e1000_read_nvm(hw, NVM_INIT_3GIO_3, 1, &buf);
-	if (le16_to_cpu(buf) & (3 << 2)) {
+	if (!ret_val && (le16_to_cpu(buf) & (3 << 2))) {
 		/* ASPM enable */
 		dev_warn(&adapter->pdev->dev,
 			 "Warning: detected ASPM enabled in EEPROM\n");

