From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: Specify AQ event opcode to wait for
Date: Tue, 26 Apr 2016 13:55:39 -0700
Message-ID: <1461704148-114349-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:24352 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbcDZUzy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:55:54 -0400
In-Reply-To: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

To add a little flexibility to the nvmupdate facility, this code adds the
ability to specify an AQ event opcode to wait on after the Exec_AQ request.

Change-ID: Iddbfd63c3de8df3edb9d3e90678b08989bc4946e
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 49 +++++++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  1 +
 3 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index f2cea3d..954efe3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -693,10 +693,10 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 	/* early check for status command and debug msgs */
 	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, perrno);
 
-	i40e_debug(hw, I40E_DEBUG_NVM, "%s state %d nvm_release_on_hold %d cmd 0x%08x config 0x%08x offset 0x%08x data_size 0x%08x\n",
+	i40e_debug(hw, I40E_DEBUG_NVM, "%s state %d nvm_release_on_hold %d opc 0x%04x cmd 0x%08x config 0x%08x offset 0x%08x data_size 0x%08x\n",
 		   i40e_nvm_update_state_str[upd_cmd],
 		   hw->nvmupd_state,
-		   hw->nvm_release_on_done,
+		   hw->nvm_release_on_done, hw->nvm_wait_opcode,
 		   cmd->command, cmd->config, cmd->offset, cmd->data_size);
 
 	if (upd_cmd == I40E_NVMUPD_INVALID) {
@@ -710,7 +710,18 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 	 * going into the state machine
 	 */
 	if (upd_cmd == I40E_NVMUPD_STATUS) {
+		if (!cmd->data_size) {
+			*perrno = -EFAULT;
+			return I40E_ERR_BUF_TOO_SHORT;
+		}
+
 		bytes[0] = hw->nvmupd_state;
+
+		if (cmd->data_size >= 4) {
+			bytes[1] = 0;
+			*((u16 *)&bytes[2]) = hw->nvm_wait_opcode;
+		}
+
 		return 0;
 	}
 
@@ -729,6 +740,14 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 
 	case I40E_NVMUPD_STATE_INIT_WAIT:
 	case I40E_NVMUPD_STATE_WRITE_WAIT:
+		/* if we need to stop waiting for an event, clear
+		 * the wait info and return before doing anything else
+		 */
+		if (cmd->offset == 0xffff) {
+			i40e_nvmupd_check_wait_event(hw, hw->nvm_wait_opcode);
+			return 0;
+		}
+
 		status = I40E_ERR_NOT_READY;
 		*perrno = -EBUSY;
 		break;
@@ -800,6 +819,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 				i40e_release_nvm(hw);
 			} else {
 				hw->nvm_release_on_done = true;
+				hw->nvm_wait_opcode = i40e_aqc_opc_nvm_erase;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
@@ -816,6 +836,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 				i40e_release_nvm(hw);
 			} else {
 				hw->nvm_release_on_done = true;
+				hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
@@ -828,10 +849,12 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 						     hw->aq.asq_last_status);
 		} else {
 			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
-			if (status)
+			if (status) {
 				i40e_release_nvm(hw);
-			else
+			} else {
+				hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_WRITE_WAIT;
+			}
 		}
 		break;
 
@@ -850,6 +873,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 				i40e_release_nvm(hw);
 			} else {
 				hw->nvm_release_on_done = true;
+				hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
@@ -940,8 +964,10 @@ retry:
 	switch (upd_cmd) {
 	case I40E_NVMUPD_WRITE_CON:
 		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
-		if (!status)
+		if (!status) {
+			hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITE_WAIT;
+		}
 		break;
 
 	case I40E_NVMUPD_WRITE_LCB:
@@ -954,6 +980,7 @@ retry:
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		} else {
 			hw->nvm_release_on_done = true;
+			hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 		}
 		break;
@@ -967,6 +994,7 @@ retry:
 				   -EIO;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		} else {
+			hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITE_WAIT;
 		}
 		break;
@@ -981,6 +1009,7 @@ retry:
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		} else {
 			hw->nvm_release_on_done = true;
+			hw->nvm_wait_opcode = i40e_aqc_opc_nvm_update;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 		}
 		break;
@@ -1036,14 +1065,14 @@ retry:
  **/
 void i40e_nvmupd_check_wait_event(struct i40e_hw *hw, u16 opcode)
 {
-	if (opcode == i40e_aqc_opc_nvm_erase ||
-	    opcode == i40e_aqc_opc_nvm_update) {
+	if (opcode == hw->nvm_wait_opcode) {
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "NVMUPD: clearing wait on opcode 0x%04x\n", opcode);
 		if (hw->nvm_release_on_done) {
 			i40e_release_nvm(hw);
 			hw->nvm_release_on_done = false;
 		}
+		hw->nvm_wait_opcode = 0;
 
 		switch (hw->nvmupd_state) {
 		case I40E_NVMUPD_STATE_INIT_WAIT:
@@ -1220,6 +1249,12 @@ static i40e_status i40e_nvmupd_exec_aq(struct i40e_hw *hw,
 		*perrno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
 	}
 
+	/* should we wait for a followup event? */
+	if (cmd->offset) {
+		hw->nvm_wait_opcode = cmd->offset;
+		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
+	}
+
 	return status;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 793036b..bb57cd9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -550,6 +550,7 @@ struct i40e_hw {
 	struct i40e_aq_desc nvm_wb_desc;
 	struct i40e_virt_mem nvm_buff;
 	bool nvm_release_on_done;
+	u16 nvm_wait_opcode;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 4a78c18..b720713 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -523,6 +523,7 @@ struct i40e_hw {
 	struct i40e_aq_desc nvm_wb_desc;
 	struct i40e_virt_mem nvm_buff;
 	bool nvm_release_on_done;
+	u16 nvm_wait_opcode;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
-- 
2.5.5
