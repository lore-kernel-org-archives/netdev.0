From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] i40e/i40evf: add GetStatus command for nvmupdate
Date: Thu, 17 Sep 2015 17:17:56 -0700
Message-ID: <1442535480-65222-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18405 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbbIRASH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:07 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This adds a new GetStatus command so that the NVM update tool can query
the current status instead of doing fake write requests to probe for
readiness.

Change-ID: I671ec6ccd4dfc9dbac3a03b964589d693fda5cd8
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 42 ++++++++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  2 ++
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  2 ++
 3 files changed, 35 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index e71ce23..7ff3099 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -638,6 +638,7 @@ static char *i40e_nvm_update_state_str[] = {
 	"I40E_NVMUPD_CSUM_CON",
 	"I40E_NVMUPD_CSUM_SA",
 	"I40E_NVMUPD_CSUM_LCB",
+	"I40E_NVMUPD_STATUS",
 };
 
 /**
@@ -654,10 +655,34 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 				u8 *bytes, int *perrno)
 {
 	i40e_status status;
+	enum i40e_nvmupd_cmd upd_cmd;
 
 	/* assume success */
 	*perrno = 0;
 
+	/* early check for status command and debug msgs */
+	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, perrno);
+
+	i40e_debug(hw, I40E_DEBUG_NVM, "%s state %d nvm_release_on_hold %d\n",
+		   i40e_nvm_update_state_str[upd_cmd],
+		   hw->nvmupd_state,
+		   hw->aq.nvm_release_on_done);
+
+	if (upd_cmd == I40E_NVMUPD_INVALID) {
+		*perrno = -EFAULT;
+		i40e_debug(hw, I40E_DEBUG_NVM,
+			   "i40e_nvmupd_validate_command returns %d errno %d\n",
+			   upd_cmd, *perrno);
+	}
+
+	/* a status request returns immediately rather than
+	 * going into the state machine
+	 */
+	if (upd_cmd == I40E_NVMUPD_STATUS) {
+		bytes[0] = hw->nvmupd_state;
+		return 0;
+	}
+
 	switch (hw->nvmupd_state) {
 	case I40E_NVMUPD_STATE_INIT:
 		status = i40e_nvmupd_state_init(hw, cmd, bytes, perrno);
@@ -954,12 +979,13 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 						 int *perrno)
 {
 	enum i40e_nvmupd_cmd upd_cmd;
-	u8 transaction;
+	u8 module, transaction;
 
 	/* anything that doesn't match a recognized case is an error */
 	upd_cmd = I40E_NVMUPD_INVALID;
 
 	transaction = i40e_nvmupd_get_transaction(cmd->config);
+	module = i40e_nvmupd_get_module(cmd->config);
 
 	/* limits on data size */
 	if ((cmd->data_size < 1) ||
@@ -986,6 +1012,10 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		case I40E_NVM_SA:
 			upd_cmd = I40E_NVMUPD_READ_SA;
 			break;
+		case I40E_NVM_EXEC:
+			if (module == 0xf)
+				upd_cmd = I40E_NVMUPD_STATUS;
+			break;
 		}
 		break;
 
@@ -1018,17 +1048,7 @@ static enum i40e_nvmupd_cmd i40e_nvmupd_validate_command(struct i40e_hw *hw,
 		}
 		break;
 	}
-	i40e_debug(hw, I40E_DEBUG_NVM, "%s state %d nvm_release_on_hold %d\n",
-		   i40e_nvm_update_state_str[upd_cmd],
-		   hw->nvmupd_state,
-		   hw->aq.nvm_release_on_done);
 
-	if (upd_cmd == I40E_NVMUPD_INVALID) {
-		*perrno = -EFAULT;
-		i40e_debug(hw, I40E_DEBUG_NVM,
-			   "i40e_nvmupd_validate_command returns %d errno %d\n",
-			   upd_cmd, *perrno);
-	}
 	return upd_cmd;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index a4fec8b..f63f538 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -305,6 +305,7 @@ enum i40e_nvmupd_cmd {
 	I40E_NVMUPD_CSUM_CON,
 	I40E_NVMUPD_CSUM_SA,
 	I40E_NVMUPD_CSUM_LCB,
+	I40E_NVMUPD_STATUS,
 };
 
 enum i40e_nvmupd_state {
@@ -329,6 +330,7 @@ enum i40e_nvmupd_state {
 #define I40E_NVM_SA		(I40E_NVM_SNT | I40E_NVM_LCB)
 #define I40E_NVM_ERA		0x4
 #define I40E_NVM_CSUM		0x8
+#define I40E_NVM_EXEC		0xf
 
 #define I40E_NVM_ADAPT_SHIFT	16
 #define I40E_NVM_ADAPT_MASK	(0xffff << I40E_NVM_ADAPT_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index cf865cc..7f3c05c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -304,6 +304,7 @@ enum i40e_nvmupd_cmd {
 	I40E_NVMUPD_CSUM_CON,
 	I40E_NVMUPD_CSUM_SA,
 	I40E_NVMUPD_CSUM_LCB,
+	I40E_NVMUPD_STATUS,
 };
 
 enum i40e_nvmupd_state {
@@ -328,6 +329,7 @@ enum i40e_nvmupd_state {
 #define I40E_NVM_SA		(I40E_NVM_SNT | I40E_NVM_LCB)
 #define I40E_NVM_ERA		0x4
 #define I40E_NVM_CSUM		0x8
+#define I40E_NVM_EXEC		0xf
 
 #define I40E_NVM_ADAPT_SHIFT	16
 #define I40E_NVM_ADAPT_MASK	(0xffff << I40E_NVM_ADAPT_SHIFT)
-- 
2.4.3
