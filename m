From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 2/3] igb: transform igb_{update,validate}_nvm_checksum into wrappers of their *_with_offset equivalents
Date: Tue, 29 Mar 2011 15:09:45 +0200
Message-ID: <1301404186-20872-3-git-send-email-sassmann@kpanic.de>
References: <1301404186-20872-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab1C2NKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 09:10:01 -0400
In-Reply-To: <1301404186-20872-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

igb_update_nvm_checksum_with_offset and igb_update_nvm_checksum are similar
except one additionally handles an offset.
Move igb_update_nvm_checksum_with_offset to e1000_nvm.c and transform
igb_update_nvm_checksum to a simple wrapper of
igb_update_nvm_checksum_with_offset.

Exactly the same is done for igb_validate_nvm_checksum.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/igb/e1000_82575.c |   76 +---------------------------------------
 drivers/net/igb/e1000_nvm.c   |   38 ++++++++++++++++----
 drivers/net/igb/e1000_nvm.h   |    2 +
 3 files changed, 34 insertions(+), 82 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 0cd41c4..11f7519 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -66,12 +66,8 @@ static s32  igb_set_pcie_completion_timeout(struct e1000_hw *hw);
 static s32  igb_reset_mdicnfg_82580(struct e1000_hw *hw);
 static s32  igb_validate_nvm_checksum_82580(struct e1000_hw *hw);
 static s32  igb_update_nvm_checksum_82580(struct e1000_hw *hw);
-static s32  igb_update_nvm_checksum_with_offset(struct e1000_hw *hw,
-						u16 offset);
-static s32 igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw,
-						u16 offset);
-static s32 igb_validate_nvm_checksum_i350(struct e1000_hw *hw);
-static s32 igb_update_nvm_checksum_i350(struct e1000_hw *hw);
+static s32  igb_validate_nvm_checksum_i350(struct e1000_hw *hw);
+static s32  igb_update_nvm_checksum_i350(struct e1000_hw *hw);
 static const u16 e1000_82580_rxpbs_table[] =
 	{ 36, 72, 144, 1, 2, 4, 8, 16,
 	  35, 70, 140 };
@@ -1788,74 +1784,6 @@ u16 igb_rxpbs_adjust_82580(u32 data)
 }
 
 /**
- *  igb_validate_nvm_checksum_with_offset - Validate EEPROM
- *  checksum
- *  @hw: pointer to the HW structure
- *  @offset: offset in words of the checksum protected region
- *
- *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
- *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
- **/
-s32 igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
-{
-	s32 ret_val = 0;
-	u16 checksum = 0;
-	u16 i, nvm_data;
-
-	for (i = offset; i < ((NVM_CHECKSUM_REG + offset) + 1); i++) {
-		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
-		if (ret_val) {
-			hw_dbg("NVM Read Error\n");
-			goto out;
-		}
-		checksum += nvm_data;
-	}
-
-	if (checksum != (u16) NVM_SUM) {
-		hw_dbg("NVM Checksum Invalid\n");
-		ret_val = -E1000_ERR_NVM;
-		goto out;
-	}
-
-out:
-	return ret_val;
-}
-
-/**
- *  igb_update_nvm_checksum_with_offset - Update EEPROM
- *  checksum
- *  @hw: pointer to the HW structure
- *  @offset: offset in words of the checksum protected region
- *
- *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
- *  up to the checksum.  Then calculates the EEPROM checksum and writes the
- *  value to the EEPROM.
- **/
-s32 igb_update_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
-{
-	s32 ret_val;
-	u16 checksum = 0;
-	u16 i, nvm_data;
-
-	for (i = offset; i < (NVM_CHECKSUM_REG + offset); i++) {
-		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
-		if (ret_val) {
-			hw_dbg("NVM Read Error while updating checksum.\n");
-			goto out;
-		}
-		checksum += nvm_data;
-	}
-	checksum = (u16) NVM_SUM - checksum;
-	ret_val = hw->nvm.ops.write(hw, (NVM_CHECKSUM_REG + offset), 1,
-				&checksum);
-	if (ret_val)
-		hw_dbg("NVM Write Error while updating checksum.\n");
-
-out:
-	return ret_val;
-}
-
-/**
  *  igb_validate_nvm_checksum_82580 - Validate EEPROM checksum
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 75bf36a..0f1ec3f 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -648,19 +648,21 @@ s32 igb_read_mac_addr(struct e1000_hw *hw)
 }
 
 /**
- *  igb_validate_nvm_checksum - Validate EEPROM checksum
+ *  igb_validate_nvm_checksum_with_offset - Validate EEPROM
+ *  checksum
  *  @hw: pointer to the HW structure
+ *  @offset: offset in words of the checksum protected region
  *
  *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
  *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
  **/
-s32 igb_validate_nvm_checksum(struct e1000_hw *hw)
+s32 igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
 {
 	s32 ret_val = 0;
 	u16 checksum = 0;
 	u16 i, nvm_data;
 
-	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
+	for (i = offset; i < ((NVM_CHECKSUM_REG + offset) + 1); i++) {
 		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg("NVM Read Error\n");
@@ -680,20 +682,31 @@ out:
 }
 
 /**
- *  igb_update_nvm_checksum - Update EEPROM checksum
+ *  igb_validate_nvm_checksum - Validate EEPROM checksum
+ *  @hw: pointer to the HW structure
+ **/
+s32 igb_validate_nvm_checksum(struct e1000_hw *hw)
+{
+	return igb_validate_nvm_checksum_with_offset(hw, 0);
+}
+
+/**
+ *  igb_update_nvm_checksum_with_offset - Update EEPROM
+ *  checksum
  *  @hw: pointer to the HW structure
+ *  @offset: offset in words of the checksum protected region
  *
  *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
  *  up to the checksum.  Then calculates the EEPROM checksum and writes the
  *  value to the EEPROM.
  **/
-s32 igb_update_nvm_checksum(struct e1000_hw *hw)
+s32 igb_update_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset)
 {
-	s32  ret_val;
+	s32 ret_val;
 	u16 checksum = 0;
 	u16 i, nvm_data;
 
-	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
+	for (i = offset; i < (NVM_CHECKSUM_REG + offset); i++) {
 		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg("NVM Read Error while updating checksum.\n");
@@ -702,7 +715,8 @@ s32 igb_update_nvm_checksum(struct e1000_hw *hw)
 		checksum += nvm_data;
 	}
 	checksum = (u16) NVM_SUM - checksum;
-	ret_val = hw->nvm.ops.write(hw, NVM_CHECKSUM_REG, 1, &checksum);
+	ret_val = hw->nvm.ops.write(hw, (NVM_CHECKSUM_REG + offset), 1,
+				&checksum);
 	if (ret_val)
 		hw_dbg("NVM Write Error while updating checksum.\n");
 
@@ -710,3 +724,11 @@ out:
 	return ret_val;
 }
 
+/**
+ *  igb_update_nvm_checksum - Update EEPROM checksum
+ *  @hw: pointer to the HW structure
+ **/
+s32 igb_update_nvm_checksum(struct e1000_hw *hw)
+{
+	return igb_update_nvm_checksum_with_offset(hw, 0);
+}
diff --git a/drivers/net/igb/e1000_nvm.h b/drivers/net/igb/e1000_nvm.h
index 7f43564..b13b405 100644
--- a/drivers/net/igb/e1000_nvm.h
+++ b/drivers/net/igb/e1000_nvm.h
@@ -38,6 +38,8 @@ s32  igb_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 s32  igb_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 s32  igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 s32  igb_validate_nvm_checksum(struct e1000_hw *hw);
+s32  igb_validate_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset);
 s32  igb_update_nvm_checksum(struct e1000_hw *hw);
+s32  igb_update_nvm_checksum_with_offset(struct e1000_hw *hw, u16 offset);
 
 #endif
-- 
1.7.4

