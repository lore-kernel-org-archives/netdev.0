From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40evf: kick a stalled admin queue
Date: Tue, 13 Jan 2015 03:33:24 -0800
Message-ID: <1421148811-9763-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65096 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbbAMLdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:37 -0500
In-Reply-To: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

On some versions of the firmware, the VF admin send queue may become
stalled. In this case, the easiest solution is to just place another
descriptor on the queue; the firmware will then process both requests.

The early init code already accounts for this, but the runtime code does
not. In the watchdog task, check for the stall condition, and if it's
found, send our API version to the PF. When the PF replies, just ignore
the reply.

Change-ID: I380d78185a4f284d649c44d263e648afc9b4d50c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 7 ++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 3 +++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 6d5a0e6..c663182 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1336,8 +1336,13 @@ static void i40evf_watchdog_task(struct work_struct *work)
 	/* Process admin queue tasks. After init, everything gets done
 	 * here so we don't race on the admin queue.
 	 */
-	if (adapter->aq_pending)
+	if (adapter->aq_pending) {
+		if (!i40evf_asq_done(hw)) {
+			dev_dbg(&adapter->pdev->dev, "Admin queue timeout\n");
+			i40evf_send_api_ver(adapter);
+		}
 		goto watchdog_done;
+	}
 
 	if (adapter->aq_required & I40EVF_FLAG_AQ_MAP_VECTORS) {
 		i40evf_map_queues(adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 3aeb633..3f0c85e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -720,6 +720,9 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 			__func__, v_retval, v_opcode);
 	}
 	switch (v_opcode) {
+	case I40E_VIRTCHNL_OP_VERSION:
+		/* no action, but also not an error */
+		break;
 	case I40E_VIRTCHNL_OP_GET_STATS: {
 		struct i40e_eth_stats *stats =
 			(struct i40e_eth_stats *)msg;
-- 
1.9.3
