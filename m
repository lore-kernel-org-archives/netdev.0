From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Update state variable for adminq subtask
Date: Sun, 27 Aug 2017 17:15:49 -0700
Message-ID: <20170828001603.75876-2-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55214 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751613AbdH1AQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:18 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

During NVM update, state machine gets into unrecoverable state because
i40e_clean_adminq_subtask can get scheduled after the admin queue
command but before other state variables are updated. This causes
incorrect input to i40e_nvmupd_check_wait_event and state transitions
don't happen.

This fix updates the state variables so that adminq_subtask will have
accurate information whenever it gets scheduled.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 2cf7db2dc7cd..96afef98a08f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -755,7 +755,11 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 
 	/* Acquire lock to prevent race condition where adminq_task
 	 * can execute after i40e_nvmupd_nvm_read/write but before state
-	 * variables (nvm_wait_opcode, nvm_release_on_done) are updated
+	 * variables (nvm_wait_opcode, nvm_release_on_done) are updated.
+	 *
+	 * During NVMUpdate, it is observed that lock could be held for
+	 * ~5ms for most commands. However lock is held for ~60ms for
+	 * NVMUPD_CSUM_LCB command.
 	 */
 	mutex_lock(&hw->aq.arq_mutex);
 	switch (hw->nvmupd_state) {
@@ -778,7 +782,8 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 		 */
 		if (cmd->offset == 0xffff) {
 			i40e_nvmupd_check_wait_event(hw, hw->nvm_wait_opcode);
-			return 0;
+			status = 0;
+			goto exit;
 		}
 
 		status = I40E_ERR_NOT_READY;
@@ -793,6 +798,7 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 		*perrno = -ESRCH;
 		break;
 	}
+exit:
 	mutex_unlock(&hw->aq.arq_mutex);
 	return status;
 }
-- 
2.14.1
