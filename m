From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/8] i40e/i40evf: add wait states to NVM state machine
Date: Thu, 17 Sep 2015 17:17:57 -0700
Message-ID: <1442535480-65222-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18405 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbbIRASH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 20:18:07 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This adds wait states to the NVM update state machine to signify when
waiting for an update operation to finish, whether we're in the middle
of a set of Write operations, or we're now idle but waiting.

Change-ID: Iabe91d6579ef6a2ea560647e374035656211ab43
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 13 ++++++++
 drivers/net/ethernet/intel/i40e/i40e_nvm.c    | 48 ++++++++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  4 ++-
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  4 ++-
 4 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 8a77f59..ea1e930 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -1018,6 +1018,19 @@ clean_arq_element_out:
 			i40e_release_nvm(hw);
 			hw->aq.nvm_release_on_done = false;
 		}
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
 	}
 
 	return ret_code;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 7ff3099..7bcbe59 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -696,6 +696,12 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 		status = i40e_nvmupd_state_writing(hw, cmd, bytes, perrno);
 		break;
 
+	case I40E_NVMUPD_STATE_INIT_WAIT:
+	case I40E_NVMUPD_STATE_WRITE_WAIT:
+		status = I40E_ERR_NOT_READY;
+		*perrno = -EBUSY;
+		break;
+
 	default:
 		/* invalid state, should never happen */
 		i40e_debug(hw, I40E_DEBUG_NVM,
@@ -759,10 +765,12 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 						     hw->aq.asq_last_status);
 		} else {
 			status = i40e_nvmupd_nvm_erase(hw, cmd, perrno);
-			if (status)
+			if (status) {
 				i40e_release_nvm(hw);
-			else
+			} else {
 				hw->aq.nvm_release_on_done = true;
+				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
+			}
 		}
 		break;
 
@@ -773,10 +781,12 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 						     hw->aq.asq_last_status);
 		} else {
 			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
-			if (status)
+			if (status) {
 				i40e_release_nvm(hw);
-			else
+			} else {
 				hw->aq.nvm_release_on_done = true;
+				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
+			}
 		}
 		break;
 
@@ -790,7 +800,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 			if (status)
 				i40e_release_nvm(hw);
 			else
-				hw->nvmupd_state = I40E_NVMUPD_STATE_WRITING;
+				hw->nvmupd_state = I40E_NVMUPD_STATE_WRITE_WAIT;
 		}
 		break;
 
@@ -809,6 +819,7 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 				i40e_release_nvm(hw);
 			} else {
 				hw->aq.nvm_release_on_done = true;
+				hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
 			}
 		}
 		break;
@@ -838,7 +849,7 @@ static i40e_status i40e_nvmupd_state_reading(struct i40e_hw *hw,
 					     struct i40e_nvm_access *cmd,
 					     u8 *bytes, int *perrno)
 {
-	i40e_status status;
+	i40e_status status = 0;
 	enum i40e_nvmupd_cmd upd_cmd;
 
 	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, perrno);
@@ -880,7 +891,7 @@ static i40e_status i40e_nvmupd_state_writing(struct i40e_hw *hw,
 					     struct i40e_nvm_access *cmd,
 					     u8 *bytes, int *perrno)
 {
-	i40e_status status;
+	i40e_status status = 0;
 	enum i40e_nvmupd_cmd upd_cmd;
 	bool retry_attempt = false;
 
@@ -890,13 +901,22 @@ retry:
 	switch (upd_cmd) {
 	case I40E_NVMUPD_WRITE_CON:
 		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
+		if (!status)
+			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITE_WAIT;
 		break;
 
 	case I40E_NVMUPD_WRITE_LCB:
 		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, perrno);
-		if (!status)
+		if (status) {
+			*perrno = hw->aq.asq_last_status ?
+				   i40e_aq_rc_to_posix(status,
+						       hw->aq.asq_last_status) :
+				   -EIO;
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+		} else {
 			hw->aq.nvm_release_on_done = true;
-		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
+		}
 		break;
 
 	case I40E_NVMUPD_CSUM_CON:
@@ -907,19 +927,23 @@ retry:
 						       hw->aq.asq_last_status) :
 				   -EIO;
 			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+		} else {
+			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITE_WAIT;
 		}
 		break;
 
 	case I40E_NVMUPD_CSUM_LCB:
 		status = i40e_update_nvm_checksum(hw);
-		if (status)
+		if (status) {
 			*perrno = hw->aq.asq_last_status ?
 				   i40e_aq_rc_to_posix(status,
 						       hw->aq.asq_last_status) :
 				   -EIO;
-		else
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+		} else {
 			hw->aq.nvm_release_on_done = true;
-		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT_WAIT;
+		}
 		break;
 
 	default:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index f63f538..3f79930 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -311,7 +311,9 @@ enum i40e_nvmupd_cmd {
 enum i40e_nvmupd_state {
 	I40E_NVMUPD_STATE_INIT,
 	I40E_NVMUPD_STATE_READING,
-	I40E_NVMUPD_STATE_WRITING
+	I40E_NVMUPD_STATE_WRITING,
+	I40E_NVMUPD_STATE_INIT_WAIT,
+	I40E_NVMUPD_STATE_WRITE_WAIT,
 };
 
 /* nvm_access definition and its masks/shifts need to be accessible to
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 7f3c05c..439a4e1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -310,7 +310,9 @@ enum i40e_nvmupd_cmd {
 enum i40e_nvmupd_state {
 	I40E_NVMUPD_STATE_INIT,
 	I40E_NVMUPD_STATE_READING,
-	I40E_NVMUPD_STATE_WRITING
+	I40E_NVMUPD_STATE_WRITING,
+	I40E_NVMUPD_STATE_INIT_WAIT,
+	I40E_NVMUPD_STATE_WRITE_WAIT,
 };
 
 /* nvm_access definition and its masks/shifts need to be accessible to
-- 
2.4.3
