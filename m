From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] ixgbe: Add iterator for cycling through rings on a q_vector
Date: Mon, 12 Mar 2012 21:03:51 -0700
Message-ID: <1331611432-30109-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35493 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620Ab2CMEEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:06 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since there are multiple spots where we have to cycle through all of the
rings on a q_vector it makes sense to just add a function for iterating
through all of them.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    4 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 ++++++++--------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 699899a..03175cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -296,6 +296,10 @@ struct ixgbe_ring_container {
 	u8 itr;				/* current ITR setting for ring */
 };
 
+/* iterator for handling rings in ring container */
+#define ixgbe_for_each_ring(pos, head) \
+	for (pos = (head).ring; pos != NULL; pos = pos->next)
+
 #define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) \
                               ? 8 : 1)
 #define MAX_TX_PACKET_BUFFERS MAX_RX_PACKET_BUFFERS
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 604540d..95240ab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -928,10 +928,10 @@ static void ixgbe_update_dca(struct ixgbe_q_vector *q_vector)
 	if (q_vector->cpu == cpu)
 		goto out_no_update;
 
-	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
+	ixgbe_for_each_ring(ring, q_vector->tx)
 		ixgbe_update_tx_dca(adapter, ring, cpu);
 
-	for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
+	ixgbe_for_each_ring(ring, q_vector->rx)
 		ixgbe_update_rx_dca(adapter, ring, cpu);
 
 	q_vector->cpu = cpu;
@@ -1706,10 +1706,10 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		struct ixgbe_ring *ring;
 		q_vector = adapter->q_vector[v_idx];
 
-		for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
+		ixgbe_for_each_ring(ring, q_vector->rx)
 			ixgbe_set_ivar(adapter, 0, ring->reg_idx, v_idx);
 
-		for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
+		ixgbe_for_each_ring(ring, q_vector->tx)
 			ixgbe_set_ivar(adapter, 1, ring->reg_idx, v_idx);
 
 		if (q_vector->tx.ring && !q_vector->rx.ring) {
@@ -4195,7 +4195,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
+	ixgbe_for_each_ring(ring, q_vector->tx)
 		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
@@ -4205,7 +4205,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	else
 		per_ring_budget = budget;
 
-	for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
+	ixgbe_for_each_ring(ring, q_vector->rx)
 		clean_complete &= ixgbe_clean_rx_irq(q_vector, ring,
 						     per_ring_budget);
 
@@ -4940,10 +4940,10 @@ static void ixgbe_free_q_vector(struct ixgbe_adapter *adapter, int v_idx)
 	struct ixgbe_q_vector *q_vector = adapter->q_vector[v_idx];
 	struct ixgbe_ring *ring;
 
-	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
+	ixgbe_for_each_ring(ring, q_vector->tx)
 		adapter->tx_ring[ring->queue_index] = NULL;
 
-	for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
+	ixgbe_for_each_ring(ring, q_vector->rx)
 		adapter->rx_ring[ring->queue_index] = NULL;
 
 	adapter->q_vector[v_idx] = NULL;
-- 
1.7.7.6
