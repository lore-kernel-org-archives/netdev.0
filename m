From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/13] i40e: fix up NVM update sm error handling
Date: Tue,  9 Dec 2014 13:26:16 -0800
Message-ID: <1418160380-29847-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:33308 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbaLIV03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 16:26:29 -0500
In-Reply-To: <1418160380-29847-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The state transitions after an error were not managed well, so
these changes get us back to the INIT state or don't transition
out of the INIT state after most errors.

Change-ID: I90aa0e4e348dc4f58cbcdce9c5d4b7fd35981c6c
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index f55e52b..f3d1c85 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -535,7 +535,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 			*errno = i40e_aq_rc_to_posix(hw->aq.asq_last_status);
 		} else {
 			status = i40e_nvmupd_nvm_read(hw, cmd, bytes, errno);
-			hw->nvmupd_state = I40E_NVMUPD_STATE_READING;
+			if (status)
+				i40e_release_nvm(hw);
+			else
+				hw->nvmupd_state = I40E_NVMUPD_STATE_READING;
 		}
 		break;
 
@@ -571,7 +574,10 @@ static i40e_status i40e_nvmupd_state_init(struct i40e_hw *hw,
 			*errno = i40e_aq_rc_to_posix(hw->aq.asq_last_status);
 		} else {
 			status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
-			hw->nvmupd_state = I40E_NVMUPD_STATE_WRITING;
+			if (status)
+				i40e_release_nvm(hw);
+			else
+				hw->nvmupd_state = I40E_NVMUPD_STATE_WRITING;
 		}
 		break;
 
@@ -671,30 +677,30 @@ static i40e_status i40e_nvmupd_state_writing(struct i40e_hw *hw,
 
 	case I40E_NVMUPD_WRITE_LCB:
 		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
-		if (!status) {
+		if (!status)
 			hw->aq.nvm_release_on_done = true;
-			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
-		}
+		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		break;
 
 	case I40E_NVMUPD_CSUM_CON:
 		status = i40e_update_nvm_checksum(hw);
-		if (status)
+		if (status) {
 			*errno = hw->aq.asq_last_status ?
 				   i40e_aq_rc_to_posix(hw->aq.asq_last_status) :
 				   -EIO;
+			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
+		}
 		break;
 
 	case I40E_NVMUPD_CSUM_LCB:
 		status = i40e_update_nvm_checksum(hw);
-		if (status) {
+		if (status)
 			*errno = hw->aq.asq_last_status ?
 				   i40e_aq_rc_to_posix(hw->aq.asq_last_status) :
 				   -EIO;
-		} else {
+		else
 			hw->aq.nvm_release_on_done = true;
-			hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
-		}
+		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 		break;
 
 	default:
-- 
1.9.3
