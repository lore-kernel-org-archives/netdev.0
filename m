From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: Move NVM event wait check to NVM code
Date: Wed,  6 Apr 2016 20:29:36 -0700
Message-ID: <1459999779-22254-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23097 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753408AbcDGD3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:44 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The logic that checks AQ events for NVM done events is better kept
in nvm.c with the rest of the nvmupdate handling code.

Change-ID: I2ea58980df8ecaa3726b28a37bff3dfcb8df03dc
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c    | 31 +-----------------------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c       | 31 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  1 +
 3 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index e8278e1..43bb413 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -33,16 +33,6 @@
 static void i40e_resume_aq(struct i40e_hw *hw);
 
 /**
- * i40e_is_nvm_update_op - return true if this is an NVM update operation
- * @desc: API request descriptor
- **/
-static inline bool i40e_is_nvm_update_op(struct i40e_aq_desc *desc)
-{
-	return (desc->opcode == cpu_to_le16(i40e_aqc_opc_nvm_erase)) ||
-		(desc->opcode == cpu_to_le16(i40e_aqc_opc_nvm_update));
-}
-
-/**
  *  i40e_adminq_init_regs - Initialize AdminQ registers
  *  @hw: pointer to the hardware structure
  *
@@ -1023,26 +1013,7 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	hw->aq.arq.next_to_clean = ntc;
 	hw->aq.arq.next_to_use = ntu;
 
-	if (i40e_is_nvm_update_op(&e->desc)) {
-		if (hw->nvm_release_on_done) {
-			i40e_release_nvm(hw);
-			hw->nvm_release_on_done = false;
-		}
-
-		switch (hw->nvmupd_state) {
-		case I40E_NVMUPD_STATE_INIT_WAIT:
-			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
-			break;
-
-		case I40E_NVMUPD_STATE_WRITE_WAIT:
-			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITING;
-			break;
-
-		default:
-			break;
-		}
-	}
-
+	i40e_nvmupd_check_wait_event(hw, le16_to_cpu(e->desc.opcode));
 clean_arq_element_out:
 	/* Set pending if needed, unlock and return */
 	if (pending)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 1ae29ac..f2cea3d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -1030,6 +1030,37 @@ retry:
 }
 
 /**
+ * i40e_nvmupd_check_wait_event - handle NVM update operation events
+ * @hw: pointer to the hardware structure
+ * @opcode: the event that just happened
+ **/
+void i40e_nvmupd_check_wait_event(struct i40e_hw *hw, u16 opcode)
+{
+	if (opcode == i40e_aqc_opc_nvm_erase ||
+	    opcode == i40e_aqc_opc_nvm_update) {
+		i40e_debug(hw, I40E_DEBUG_NVM,
+			   "NVMUPD: clearing wait on opcode 0x%04x\n", opcode);
+		if (hw->nvm_release_on_done) {
+			i40e_release_nvm(hw);
+			hw->nvm_release_on_done = false;
+		}
+
+		switch (hw->nvmupd_state) {
+		case I40E_NVMUPD_STATE_INIT_WAIT:
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+			break;
+
+		case I40E_NVMUPD_STATE_WRITE_WAIT:
+			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITING;
+			break;
+
+		default:
+			break;
+		}
+	}
+}
+
+/**
  * i40e_nvmupd_validate_command - Validate given command
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index d51eee5..134035f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -308,6 +308,7 @@ i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
 i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 				struct i40e_nvm_access *cmd,
 				u8 *bytes, int *);
+void i40e_nvmupd_check_wait_event(struct i40e_hw *hw, u16 opcode);
 void i40e_set_pci_config_data(struct i40e_hw *hw, u16 link_status);
 
 extern struct i40e_rx_ptype_decoded i40e_ptype_lookup[];
-- 
2.5.5
