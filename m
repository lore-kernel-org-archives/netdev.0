From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] i40e/i40evf: add get AQ result command to nvmupdate utility
Date: Thu, 17 Sep 2015 17:17:59 -0700
Message-ID: <1442535480-65222-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:54009 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbbIRASI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:08 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add a facility to recover the result of a previously run AQ command.

Change-ID: I21afec2c20c1a5e6ba60c7fbfcbedfff78c10e45
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 79 +++++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  1 +
 3 files changed, 81 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 50d4aa3..d0288ad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -618,6 +618,9 @@ static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 static i40e_status i40e_nvmupd_exec_aq(struct i40e_hw *hw,
 				       struct i40e_nvm_access *cmd,
 				       u8 *bytes, int *perrno);
+static i40e_status i40e_nvmupd_get_aq_result(struct i40e_hw *hw,
+					     struct i40e_nvm_access *cmd,
+					     u8 *bytes, int *perrno);
 static inline u8 i40e_nvmupd_get_module(u32 val)
 {
 	return (u8)(val & I40E_NVM_MOD_PNT_MASK);
@@ -643,6 +646,7 @@ static char *i40e_nvm_update_state_str[] = {
 	"I40E_NVMUPD_CSUM_LCB",
 	"I40E_NVMUPD_STATUS",
 	"I40E_NVMUPD_EXEC_AQ",
+	"I40E_NVMUPD_GET_AQ_RESULT",
 };
 
 /**
@@ -832,6 +836,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 		status = i40e_nvmupd_exec_aq(hw, cmd, bytes, perrno);
 		break;
 
+	case I40E_NVMUPD_GET_AQ_RESULT:
+		status = i40e_nvmupd_get_aq_result(hw, cmd, bytes, perrno);
+		break;
+
 	default:
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "NVMUPD: bad cmd %s in init state\n",
@@ -1047,6 +1055,8 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		case I40E_NVM_EXEC:
 			if (module == 0xf)
 				upd_cmd = I40E_NVMUPD_STATUS;
+			else if (module == 0)
+				upd_cmd = I40E_NVMUPD_GET_AQ_RESULT;
 			break;
 		}
 		break;
@@ -1160,6 +1170,75 @@ static i40e_status i40e_nvmupd_exec_aq(struct i40e_hw *hw,
 }
 
 /**
+ * i40e_nvmupd_get_aq_result - Get the results from the previous exec_aq
+ * @hw: pointer to hardware structure
+ * @cmd: pointer to nvm update command buffer
+ * @bytes: pointer to the data buffer
+ * @perrno: pointer to return error code
+ *
+ * cmd structure contains identifiers and data buffer
+ **/
+static i40e_status i40e_nvmupd_get_aq_result(struct i40e_hw *hw,
+					     struct i40e_nvm_access *cmd,
+					     u8 *bytes, int *perrno)
+{
+	u32 aq_total_len;
+	u32 aq_desc_len;
+	int remainder;
+	u8 *buff;
+
+	i40e_debug(hw, I40E_DEBUG_NVM, "NVMUPD: %s\n", __func__);
+
+	aq_desc_len = sizeof(struct i40e_aq_desc);
+	aq_total_len = aq_desc_len + le16_to_cpu(hw->nvm_wb_desc.datalen);
+
+	/* check offset range */
+	if (cmd->offset > aq_total_len) {
+		i40e_debug(hw, I40E_DEBUG_NVM, "%s: offset too big %d > %d\n",
+			   __func__, cmd->offset, aq_total_len);
+		*perrno = -EINVAL;
+		return I40E_ERR_PARAM;
+	}
+
+	/* check copylength range */
+	if (cmd->data_size > (aq_total_len - cmd->offset)) {
+		int new_len = aq_total_len - cmd->offset;
+
+		i40e_debug(hw, I40E_DEBUG_NVM, "%s: copy length %d too big, trimming to %d\n",
+			   __func__, cmd->data_size, new_len);
+		cmd->data_size = new_len;
+	}
+
+	remainder = cmd->data_size;
+	if (cmd->offset < aq_desc_len) {
+		u32 len = aq_desc_len - cmd->offset;
+
+		len = min(len, cmd->data_size);
+		i40e_debug(hw, I40E_DEBUG_NVM, "%s: aq_desc bytes %d to %d\n",
+			   __func__, cmd->offset, cmd->offset + len);
+
+		buff = ((u8 *)&hw->nvm_wb_desc) + cmd->offset;
+		memcpy(bytes, buff, len);
+
+		bytes += len;
+		remainder -= len;
+		buff = hw->nvm_buff.va;
+	} else {
+		buff = hw->nvm_buff.va + (cmd->offset - aq_desc_len);
+	}
+
+	if (remainder > 0) {
+		int start_byte = buff - (u8 *)hw->nvm_buff.va;
+
+		i40e_debug(hw, I40E_DEBUG_NVM, "%s: databuf bytes %d to %d\n",
+			   __func__, start_byte, start_byte + remainder);
+		memcpy(bytes, buff, remainder);
+	}
+
+	return 0;
+}
+
+/**
  * i40e_nvmupd_nvm_read - Read NVM
  * @hw: pointer to hardware structure
  * @cmd: pointer to nvm update command buffer
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index a78b077..af48290 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -307,6 +307,7 @@ enum i40e_nvmupd_cmd {
 	I40E_NVMUPD_CSUM_LCB,
 	I40E_NVMUPD_STATUS,
 	I40E_NVMUPD_EXEC_AQ,
+	I40E_NVMUPD_GET_AQ_RESULT,
 };
 
 enum i40e_nvmupd_state {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 4d36615..ed71666 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -306,6 +306,7 @@ enum i40e_nvmupd_cmd {
 	I40E_NVMUPD_CSUM_LCB,
 	I40E_NVMUPD_STATUS,
 	I40E_NVMUPD_EXEC_AQ,
+	I40E_NVMUPD_GET_AQ_RESULT,
 };
 
 enum i40e_nvmupd_state {
-- 
2.4.3
