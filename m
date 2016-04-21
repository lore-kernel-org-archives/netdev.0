From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] fm10k: Add support for bulk Tx cleanup & cleanup boolean logic
Date: Wed, 20 Apr 2016 23:09:15 -0700
Message-ID: <1461218969-68578-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8320 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbcDUGJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:35 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch enables bulk free in Tx cleanup for fm10k and cleans up the
boolean logic in the polling routines for fm10k in the hopes of avoiding
any mix-ups similar to what occurred with i40e and i40evf.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 0b46539..9765080 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1198,9 +1198,10 @@ void fm10k_tx_timeout_reset(struct fm10k_intfc *interface)
  * fm10k_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: structure containing interrupt and ring information
  * @tx_ring: tx ring to clean
+ * @napi_budget: Used to determine if we are in netpoll
  **/
 static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
-			       struct fm10k_ring *tx_ring)
+			       struct fm10k_ring *tx_ring, int napi_budget)
 {
 	struct fm10k_intfc *interface = q_vector->interface;
 	struct fm10k_tx_buffer *tx_buffer;
@@ -1238,7 +1239,7 @@ static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_consume_skb_any(tx_buffer->skb);
+		napi_consume_skb(tx_buffer->skb, napi_budget);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -1449,8 +1450,10 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	int per_ring_budget, work_done = 0;
 	bool clean_complete = true;
 
-	fm10k_for_each_ring(ring, q_vector->tx)
-		clean_complete &= fm10k_clean_tx_irq(q_vector, ring);
+	fm10k_for_each_ring(ring, q_vector->tx) {
+		if (!fm10k_clean_tx_irq(q_vector, ring, budget))
+			clean_complete = false;
+	}
 
 	/* Handle case where we are called by netpoll with a budget of 0 */
 	if (budget <= 0)
@@ -1468,7 +1471,8 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 		int work = fm10k_clean_rx_irq(q_vector, ring, per_ring_budget);
 
 		work_done += work;
-		clean_complete &= !!(work < per_ring_budget);
+		if (work >= per_ring_budget)
+			clean_complete = false;
 	}
 
 	/* If all work not completed, return budget and keep polling */
-- 
2.5.5
