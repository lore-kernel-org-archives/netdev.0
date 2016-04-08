From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/18] ixgbe/ixgbevf: Add support for bulk free in Tx cleanup & cleanup boolean logic
Date: Thu,  7 Apr 2016 20:21:01 -0700
Message-ID: <1460085673-87056-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5938 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756948AbcDHDVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:20 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This patch enables bulk free in Tx cleanup for ixgbevf and cleans up the
boolean logic in the polling routines for ixgbe and ixgbevf in the hopes of
avoiding any mix-ups similar to what occurred with i40e and i40evf.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 10 +++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 +++++++++-----
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 19bf386..d5509cc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1111,6 +1111,7 @@ static int ixgbe_tx_maxrate(struct net_device *netdev,
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: structure containing interrupt and ring information
  * @tx_ring: tx ring to clean
+ * @napi_budget: Used to determine if we are in netpoll
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *tx_ring, int napi_budget)
@@ -2807,8 +2808,10 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	ixgbe_for_each_ring(ring, q_vector->tx)
-		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring, budget);
+	ixgbe_for_each_ring(ring, q_vector->tx) {
+		if (!ixgbe_clean_tx_irq(q_vector, ring, budget))
+			clean_complete = false;
+	}
 
 	/* Exit if we are called by netpoll or busy polling is active */
 	if ((budget <= 0) || !ixgbe_qv_lock_napi(q_vector))
@@ -2826,7 +2829,8 @@ int ixgbe_poll(struct napi_struct *napi, int budget)
 						 per_ring_budget);
 
 		work_done += cleaned;
-		clean_complete &= (cleaned < per_ring_budget);
+		if (cleaned >= per_ring_budget)
+			clean_complete = false;
 	}
 
 	ixgbe_qv_unlock_napi(q_vector);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 50b6bff..007cbe0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -288,9 +288,10 @@ static void ixgbevf_tx_timeout(struct net_device *netdev)
  * ixgbevf_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: board private structure
  * @tx_ring: tx ring to clean
+ * @napi_budget: Used to determine if we are in netpoll
  **/
 static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
-				 struct ixgbevf_ring *tx_ring)
+				 struct ixgbevf_ring *tx_ring, int napi_budget)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	struct ixgbevf_tx_buffer *tx_buffer;
@@ -328,7 +329,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 		total_packets += tx_buffer->gso_segs;
 
 		/* free the skb */
-		dev_kfree_skb_any(tx_buffer->skb);
+		napi_consume_skb(tx_buffer->skb, napi_budget);
 
 		/* unmap skb header data */
 		dma_unmap_single(tx_ring->dev,
@@ -1013,8 +1014,10 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	int per_ring_budget, work_done = 0;
 	bool clean_complete = true;
 
-	ixgbevf_for_each_ring(ring, q_vector->tx)
-		clean_complete &= ixgbevf_clean_tx_irq(q_vector, ring);
+	ixgbevf_for_each_ring(ring, q_vector->tx) {
+		if (!ixgbevf_clean_tx_irq(q_vector, ring, budget))
+			clean_complete = false;
+	}
 
 	if (budget <= 0)
 		return budget;
@@ -1035,7 +1038,8 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 		int cleaned = ixgbevf_clean_rx_irq(q_vector, ring,
 						   per_ring_budget);
 		work_done += cleaned;
-		clean_complete &= (cleaned < per_ring_budget);
+		if (cleaned >= per_ring_budget)
+			clean_complete = false;
 	}
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
-- 
2.5.5
