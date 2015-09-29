From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e/i40evf: check for stopped admin queue
Date: Mon, 28 Sep 2015 17:31:26 -0700
Message-ID: <1443486686-49798-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4063 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbbI2Ab3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:31:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

It's possible that while we are waiting for the spinlock, another
entity (that owns the spinlock) has shut down the admin queue.
If we then attempt to use the queue, we will panic.

Add a check for this condition on the receive side. This matches
an existing check on the send queue side.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 9 +++++++++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 9 +++++++++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 3e0d200..62488a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -946,6 +946,13 @@ i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
 	/* take the lock before we start messing with the ring */
 	mutex_lock(&hw->aq.arq_mutex);
 
+	if (hw->aq.arq.count == 0) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "AQRX: Admin queue not initialized.\n");
+		ret_code = I40E_ERR_QUEUE_EMPTY;
+		goto clean_arq_element_err;
+	}
+
 	/* set next_to_use to head */
 	ntu = (rd32(hw, hw->aq.arq.head) & I40E_PF_ARQH_ARQH_MASK);
 	if (ntu == ntc) {
@@ -1007,6 +1014,8 @@ clean_arq_element_out:
 	/* Set pending if needed, unlock and return */
 	if (pending != NULL)
 		*pending = (ntc > ntu ? hw->aq.arq.count : 0) + (ntu - ntc);
+
+clean_arq_element_err:
 	mutex_unlock(&hw->aq.arq_mutex);
 
 	if (i40e_is_nvm_update_op(&e->desc)) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index c1d25f8..7f52ee1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -898,6 +898,13 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 	/* take the lock before we start messing with the ring */
 	mutex_lock(&hw->aq.arq_mutex);
 
+	if (hw->aq.arq.count == 0) {
+		i40e_debug(hw, I40E_DEBUG_AQ_MESSAGE,
+			   "AQRX: Admin queue not initialized.\n");
+		ret_code = I40E_ERR_QUEUE_EMPTY;
+		goto clean_arq_element_err;
+	}
+
 	/* set next_to_use to head */
 	ntu = (rd32(hw, hw->aq.arq.head) & I40E_PF_ARQH_ARQH_MASK);
 	if (ntu == ntc) {
@@ -959,6 +966,8 @@ clean_arq_element_out:
 	/* Set pending if needed, unlock and return */
 	if (pending != NULL)
 		*pending = (ntc > ntu ? hw->aq.arq.count : 0) + (ntu - ntc);
+
+clean_arq_element_err:
 	mutex_unlock(&hw->aq.arq_mutex);
 
 	return ret_code;
-- 
2.4.3
