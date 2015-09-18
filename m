From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] i40e/i40evf: add handling of writeback descriptor
Date: Thu, 17 Sep 2015 17:17:55 -0700
Message-ID: <1442535480-65222-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57564 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbbIRASH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:07 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

If the writeback descriptor buffer was previously created, this gives it
to the AQ command request to be used to save the results.

Change-ID: I8c8a1af81e6ebed6d0a15ed31697fe1a6c4e3708
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 26 ++++++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  1 +
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 3f2fec9..e71ce23 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -418,6 +418,10 @@ static i40e_status i40e_write_nvm_aq(struct i40e_hw *hw, u8 module_pointer,
 				     bool last_command)
 {
 	i40e_status ret_code = I40E_ERR_NVM;
+	struct i40e_asq_cmd_details cmd_details;
+
+	memset(&cmd_details, 0, sizeof(cmd_details));
+	cmd_details.wb_desc = &hw->nvm_wb_desc;
 
 	/* Here we are checking the SR limit only for the flat memory model.
 	 * We cannot do it for the module-based model, as we did not acquire
@@ -443,7 +447,7 @@ static i40e_status i40e_write_nvm_aq(struct i40e_hw *hw, u8 module_pointer,
 		ret_code = i40e_aq_update_nvm(hw, module_pointer,
 					      2 * offset,  /*bytes*/
 					      2 * words,   /*bytes*/
-					      data, last_command, NULL);
+					      data, last_command, &cmd_details);
 
 	return ret_code;
 }
@@ -1041,6 +1045,7 @@ static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 					struct i40e_nvm_access *cmd,
 					u8 *bytes, int *perrno)
 {
+	struct i40e_asq_cmd_details cmd_details;
 	i40e_status status;
 	u8 module, transaction;
 	bool last;
@@ -1049,8 +1054,11 @@ static i40e_status i40e_nvmupd_nvm_read(struct i40e_hw *hw,
 	module = i40e_nvmupd_get_module(cmd->config);
 	last = (transaction == I40E_NVM_LCB) || (transaction == I40E_NVM_SA);
 
+	memset(&cmd_details, 0, sizeof(cmd_details));
+	cmd_details.wb_desc = &hw->nvm_wb_desc;
+
 	status = i40e_aq_read_nvm(hw, module, cmd->offset, (u16)cmd->data_size,
-				  bytes, last, NULL);
+				  bytes, last, &cmd_details);
 	if (status) {
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_nvm_read mod 0x%x  off 0x%x  len 0x%x\n",
@@ -1077,14 +1085,19 @@ static i40e_status i40e_nvmupd_nvm_erase(struct i40e_hw *hw,
 					 int *perrno)
 {
 	i40e_status status = 0;
+	struct i40e_asq_cmd_details cmd_details;
 	u8 module, transaction;
 	bool last;
 
 	transaction = i40e_nvmupd_get_transaction(cmd->config);
 	module = i40e_nvmupd_get_module(cmd->config);
 	last = (transaction & I40E_NVM_LCB);
+
+	memset(&cmd_details, 0, sizeof(cmd_details));
+	cmd_details.wb_desc = &hw->nvm_wb_desc;
+
 	status = i40e_aq_erase_nvm(hw, module, cmd->offset, (u16)cmd->data_size,
-				   last, NULL);
+				   last, &cmd_details);
 	if (status) {
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_nvm_erase mod 0x%x  off 0x%x len 0x%x\n",
@@ -1112,6 +1125,7 @@ static i40e_status i40e_nvmupd_nvm_write(struct i40e_hw *hw,
 					 u8 *bytes, int *perrno)
 {
 	i40e_status status = 0;
+	struct i40e_asq_cmd_details cmd_details;
 	u8 module, transaction;
 	bool last;
 
@@ -1119,8 +1133,12 @@ static i40e_status i40e_nvmupd_nvm_write(struct i40e_hw *hw,
 	module = i40e_nvmupd_get_module(cmd->config);
 	last = (transaction & I40E_NVM_LCB);
 
+	memset(&cmd_details, 0, sizeof(cmd_details));
+	cmd_details.wb_desc = &hw->nvm_wb_desc;
+
 	status = i40e_aq_update_nvm(hw, module, cmd->offset,
-				    (u16)cmd->data_size, bytes, last, NULL);
+				    (u16)cmd->data_size, bytes, last,
+				    &cmd_details);
 	if (status) {
 		i40e_debug(hw, I40E_DEBUG_NVM,
 			   "i40e_nvmupd_nvm_write mod 0x%x off 0x%x len 0x%x\n",
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 4842239..a4fec8b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -492,6 +492,7 @@ struct i40e_hw {
 
 	/* state of nvm update process */
 	enum i40e_nvmupd_state nvmupd_state;
+	struct i40e_aq_desc nvm_wb_desc;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 24a2693..cf865cc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -486,6 +486,7 @@ struct i40e_hw {
 
 	/* state of nvm update process */
 	enum i40e_nvmupd_state nvmupd_state;
+	struct i40e_aq_desc nvm_wb_desc;
 
 	/* HMC info */
 	struct i40e_hmc_info hmc; /* HMC info struct */
-- 
2.4.3
