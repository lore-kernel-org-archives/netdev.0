From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: synchronize nvmupdate command and adminq subtask
Date: Sat, 12 Aug 2017 04:08:48 -0700
Message-ID: <20170812110848.18264-17-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12721 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751989AbdHLLI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:57 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

During NVM update, state machine gets into unrecoverable state because
i40e_clean_adminq_subtask can get scheduled after the admin queue
command but before other state variables are updated. This causes
incorrect input to i40e_nvmupd_check_wait_event and state transitions
don't happen.

This issue existed before but surfaced after commit 373149fc99a0
("i40e: Decrease the scope of rtnl lock")

This fix adds locking around admin queue command and update of
state variables so that adminq_subtask will have accurate information
whenever it gets scheduled.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 6fdecd70dcbc..2cf7db2dc7cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -753,6 +753,11 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 		hw->nvmupd_state = I40E_NVMUPD_STATE_INIT;
 	}
 
+	/* Acquire lock to prevent race condition where adminq_task
+	 * can execute after i40e_nvmupd_nvm_read/write but before state
+	 * variables (nvm_wait_opcode, nvm_release_on_done) are updated
+	 */
+	mutex_lock(&hw->aq.arq_mutex);
 	switch (hw->nvmupd_state) {
 	case I40E_NVMUPD_STATE_INIT:
 		status = i40e_nvmupd_state_init(hw, cmd, bytes, perrno);
@@ -788,6 +793,7 @@ i40e_status i40e_nvmupd_command(struct i40e_hw *hw,
 		*perrno = -ESRCH;
 		break;
 	}
+	mutex_unlock(&hw->aq.arq_mutex);
 	return status;
 }
 
-- 
2.14.0
