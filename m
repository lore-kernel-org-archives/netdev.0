From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] i40e/i40evf: add exec_aq command to nvmupdate utility
Date: Thu, 17 Sep 2015 17:17:58 -0700
Message-ID: <1442535480-65222-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57564 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbbIRASI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:08 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add a facility to run AQ commands through the nvmupdate utility in order
to allow the update tools to interact with the FW and do special
commands needed for updates and configuration changes.

Change-ID: I5c41523e4055b37f8e4ee479f7a0574368f4a588
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |  3 +
 drivers/net/ethernet/intel/i40e/i40e_nvm.c      | 83 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h     |  2 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |  3 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h   |  2 +
 5 files changed, 93 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index ea1e930..199275d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -657,6 +657,9 @@ i40e_status i40e_shutdown_adminq(struct i40e_hw *hw)
 
 	/* destroy the locks */
 
+	if (hw->nvm_buff.va)
+		i40e_free_virt_mem(hw, &hw->nvm_buff);
+
 	return ret_code;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 7bcbe59..50d4aa3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -615,6 +615,9 @@ static i40e_status i40e_nvmupd_nvm_write(struct i40e_hw *hw,
 static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 					struct i40e_nvm_access *cmd,
 					u8 *bytes, int *perrno);
+static i40e_status i40e_nvmupd_exec_aq(struct i40e_hw *hw,
+				       struct i40e_nvm_access *cmd,
+				       u8 *bytes, int *perrno);
 static inline u8 i40e_nvmupd_get_module(u32 val)
 {
 	return (u8)(val & I40E_NVM_MOD_PNT_MASK);
@@ -639,6 +642,7 @@ static char *i40e_nvm_update_state_str[] = {
 	"I40E_NVMUPD_CSUM_SA",
 	"I40E_NVMUPD_CSUM_LCB",
 	"I40E_NVMUPD_STATUS",
+	"I40E_NVMUPD_EXEC_AQ",
 };
 
 /**
@@ -824,6 +828,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 		}
 		break;
 
+	case I40E_NVMUPD_EXEC_AQ:
+		status = i40e_nvmupd_exec_aq(hw, cmd, bytes, perrno);
+		break;
+
 	default:
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "NVMUPD: bad cmd %s in init state\n",
@@ -1069,6 +1077,10 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		case (I40E_NVM_CSUM|I40E_NVM_LCB):
 			upd_cmd = I40E_NVMUPD_CSUM_LCB;
 			break;
+		case I40E_NVM_EXEC:
+			if (module == 0)
+				upd_cmd = I40E_NVMUPD_EXEC_AQ;
+			break;
 		}
 		break;
 	}
@@ -1077,6 +1089,77 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 }
 
 /**
+ * i40e_nvmupd_exec_aq - Run an AQ command
+ * @hw: pointer to hardware structure
+ * @cmd: pointer to nvm update command buffer
+ * @bytes: pointer to the data buffer
+ * @perrno: pointer to return error code
+ *
+ * cmd structure contains identifiers and data buffer
+ **/
+static i40e_status i40e_nvmupd_exec_aq(struct i40e_hw *hw,
+				       struct i40e_nvm_access *cmd,
+				       u8 *bytes, int *perrno)
+{
+	struct i40e_asq_cmd_details cmd_details;
+	i40e_status status;
+	struct i40e_aq_desc *aq_desc;
+	u32 buff_size = 0;
+	u8 *buff = NULL;
+	u32 aq_desc_len;
+	u32 aq_data_len;
+
+	i40e_debug(hw, I40E_DEBUG_NVM, "NVMUPD: %s\n", __func__);
+	memset(&cmd_details, 0, sizeof(cmd_details));
+	cmd_details.wb_desc = &hw->nvm_wb_desc;
+
+	aq_desc_len = sizeof(struct i40e_aq_desc);
+	memset(&hw->nvm_wb_desc, 0, aq_desc_len);
+
+	/* get the aq descriptor */
+	if (cmd->data_size < aq_desc_len) {
+		i40e_debug(hw, I40E_DEBUG_NVM,
+			   "NVMUPD: not enough aq desc bytes for exec, size %d < %d\n",
+			   cmd->data_size, aq_desc_len);
+		*perrno = -EINVAL;
+		return I40E_ERR_PARAM;
+	}
+	aq_desc = (struct i40e_aq_desc *)bytes;
+
+	/* if data buffer needed, make sure it's ready */
+	aq_data_len = cmd->data_size - aq_desc_len;
+	buff_size = max_t(u32, aq_data_len, le16_to_cpu(aq_desc->datalen));
+	if (buff_size) {
+		if (!hw->nvm_buff.va) {
+			status = i40e_allocate_virt_mem(hw, &hw->nvm_buff,
+							hw->aq.asq_buf_size);
+			if (status)
+				i40e_debug(hw, I40E_DEBUG_NVM,
+					   "NVMUPD: i40e_allocate_virt_mem for exec buff failed, %d\n",
+					   status);
+		}
+
+		if (hw->nvm_buff.va) {
+			buff = hw->nvm_buff.va;
+			memcpy(buff, &bytes[aq_desc_len], aq_data_len);
+		}
+	}
+
+	/* and away we go! */
+	status = i40e_asq_send_command(hw, aq_desc, buff,
+				       buff_size, &cmd_details);
+	if (status) {
+		i40e_debug(hw, I40E_DEBUG_NVM,
+			   "i40e_nvmupd_exec_aq err %s aq_err %s\n",
+			   i40e_stat_str(hw, status),
+			   i40e_aq_str(hw, hw->aq.asq_last_status));
+		*perrno = i40e_aq_rc_to_posix(status, hw->aq.asq_last_status);
+	}
+
+	return status;
+}
+
+/**
  * i40e_nvmupd_nvm_read - Read NVM
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 3f79930..a78b077 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -306,6 +306,7 @@ enum i40e_nvmupd_cmd {
 	I40E_NVMUPD_CSUM_SA,
 	I40E_NVMUPD_CSUM_LCB,
 	I40E_NVMUPD_STATUS,
+	I40E_NVMUPD_EXEC_AQ,
 };
 
 enum i40e_nvmupd_state {
@@ -497,6 +498,7 @@ struct i40e_hw {
 	/* state of nvm update process */
 	enum i40e_nvmupd_state nvmupd_state;
 	struct i40e_aq_desc nvm_wb_desc;
+	struct i40e_virt_mem nvm_buff;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 15c8ac8..0940db7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -596,6 +596,9 @@ i40e_status i40evf_shutdown_adminq(struct i40e_hw *hw)
 
 	/* destroy the locks */
 
+	if (hw->nvm_buff.va)
+		i40e_free_virt_mem(hw, &hw->nvm_buff);
+
 	return ret_code;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 439a4e1..4d36615 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -305,6 +305,7 @@ enum i40e_nvmupd_cmd {
 	I40E_NVMUPD_CSUM_SA,
 	I40E_NVMUPD_CSUM_LCB,
 	I40E_NVMUPD_STATUS,
+	I40E_NVMUPD_EXEC_AQ,
 };
 
 enum i40e_nvmupd_state {
@@ -491,6 +492,7 @@ struct i40e_hw {
 	/* state of nvm update process */
 	enum i40e_nvmupd_state nvmupd_state;
 	struct i40e_aq_desc nvm_wb_desc;
+	struct i40e_virt_mem nvm_buff;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
-- 
2.4.3
