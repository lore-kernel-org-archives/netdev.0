From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH 1/2] i40e: use non-locking i40e_read_nvm_word() function during nvmupdate
Date: Fri,  1 Sep 2017 16:02:33 +0200
Message-ID: <20170901140234.7840-2-sassmann@kpanic.de>
References: <20170901140234.7840-1-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64572 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdIAOCq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 10:02:46 -0400
In-Reply-To: <20170901140234.7840-1-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During firmware update the adminq gets locked. Currently during the
update i40e_calc_nvm_checksum() calls i40e_read_nvm_word() which itself
tries to acquire the adminq lock. This fails as the lock is already
taken.
This results in the firmware update to fail, leaving the eeprom in a
corrupt state.

To fix this, introducing __i40e_read_nvm_word() which avoids locking and
replace the calls to i40e_read_nvm_word() in i40e_calc_nvm_checksum()
with the newly introduced function. The change matches the i40e
sourceforge driver as much as possible.

With this in place the firmware update is now working again.
Fixes: ("96a39aed25e6 i40e: Acquire NVM lock before reads on all devices")

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 96afef98a08f..aa4cfdc51d2b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -322,6 +322,26 @@ i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 }
 
 /**
+ * __i40e_read_nvm_word - Reads nvm word, assumes caller does the locking
+ * @hw: pointer to the HW structure
+ * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF)
+ * @data: word read from the Shadow RAM
+ *
+ * Reads one 16 bit word from the Shadow RAM using the GLNVM_SRCTL register.
+ **/
+static i40e_status __i40e_read_nvm_word(struct i40e_hw *hw,
+					u16 offset, u16 *data)
+{
+	enum i40e_status_code ret_code = 0;
+
+	if (hw->flags & I40E_HW_FLAG_AQ_SRCTL_ACCESS_ENABLE)
+		ret_code = i40e_read_nvm_word_aq(hw, offset, data);
+	else
+		ret_code = i40e_read_nvm_word_srctl(hw, offset, data);
+	return ret_code;
+}
+
+/**
  * i40e_read_nvm_buffer_srctl - Reads Shadow RAM buffer via SRCTL register
  * @hw: pointer to the HW structure
  * @offset: offset of the Shadow RAM word to read (0x000000 - 0x001FFF).
@@ -516,14 +536,14 @@ static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
 	data = (u16 *)vmem.va;
 
 	/* read pointer to VPD area */
-	ret_code = i40e_read_nvm_word(hw, I40E_SR_VPD_PTR, &vpd_module);
+	ret_code = __i40e_read_nvm_word(hw, I40E_SR_VPD_PTR, &vpd_module);
 	if (ret_code) {
 		ret_code = I40E_ERR_NVM_CHECKSUM;
 		goto i40e_calc_nvm_checksum_exit;
 	}
 
 	/* read pointer to PCIe Alt Auto-load module */
-	ret_code = i40e_read_nvm_word(hw, I40E_SR_PCIE_ALT_AUTO_LOAD_PTR,
+	ret_code = __i40e_read_nvm_word(hw, I40E_SR_PCIE_ALT_AUTO_LOAD_PTR,
 				      &pcie_alt_module);
 	if (ret_code) {
 		ret_code = I40E_ERR_NVM_CHECKSUM;
-- 
2.13.5
