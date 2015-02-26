From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 12/13] i40e: catch NVM write semaphore timeout and retry
Date: Thu, 26 Feb 2015 07:03:48 -0800
Message-ID: <1424963029-4612-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40565 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753966AbbBZPD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:58 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

In some circumstances, a multi-write transaction takes longer than the
default 3 minute timeout on the write semaphore.  If the write failed with
an EBUSY status, this is likely the problem, so here we try to reacquire
the semaphore then retry the write.  We only do one retry, then give up.

Change-ID: I1c8be60688acc2f39573839579baf601207c4a36
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c | 35 ++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 3e70f2e..5defe0d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -679,9 +679,11 @@ static i40e_status i40e_nvmupd_state_writing(struct i40e_hw *hw,
 {
 	i40e_status status;
 	enum i40e_nvmupd_cmd upd_cmd;
+	bool retry_attempt = false;
 
 	upd_cmd = i40e_nvmupd_validate_command(hw, cmd, errno);
 
+retry:
 	switch (upd_cmd) {
 	case I40E_NVMUPD_WRITE_CON:
 		status = i40e_nvmupd_nvm_write(hw, cmd, bytes, errno);
@@ -725,6 +727,39 @@ static i40e_status i40e_nvmupd_state_writing(struct i40e_hw *hw,
 		*errno = -ESRCH;
 		break;
 	}
+
+	/* In some circumstances, a multi-write transaction takes longer
+	 * than the default 3 minute timeout on the write semaphore.  If
+	 * the write failed with an EBUSY status, this is likely the problem,
+	 * so here we try to reacquire the semaphore then retry the write.
+	 * We only do one retry, then give up.
+	 */
+	if (status && (hw->aq.asq_last_status == I40E_AQ_RC_EBUSY) &&
+	    !retry_attempt) {
+		i40e_status old_status = status;
+		u32 old_asq_status = hw->aq.asq_last_status;
+		u32 gtime;
+
+		gtime = rd32(hw, I40E_GLVFGEN_TIMER);
+		if (gtime >= hw->nvm.hw_semaphore_timeout) {
+			i40e_debug(hw, I40E_DEBUG_ALL,
+				   "NVMUPD: write semaphore expired (%d >= %lld), retrying\n",
+				   gtime, hw->nvm.hw_semaphore_timeout);
+			i40e_release_nvm(hw);
+			status = i40e_acquire_nvm(hw, I40E_RESOURCE_WRITE);
+			if (status) {
+				i40e_debug(hw, I40E_DEBUG_ALL,
+					   "NVMUPD: write semaphore reacquire failed aq_err = %d\n",
+					   hw->aq.asq_last_status);
+				status = old_status;
+				hw->aq.asq_last_status = old_asq_status;
+			} else {
+				retry_attempt = true;
+				goto retry;
+			}
+		}
+	}
+
 	return status;
 }
 
-- 
1.9.3
