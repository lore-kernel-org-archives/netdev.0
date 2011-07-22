From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbe: add structure for containing RX/TX rings to q_vector
Date: Thu, 21 Jul 2011 23:09:06 -0700
Message-ID: <1311314951-11142-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753440Ab1GVGJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 02:09:17 -0400
In-Reply-To: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for a ring container structure to be used within
the q_vector.  The basic idea is to provide a means of separating the RX
and TX rings while maintaining a common structure for their containment.
The advantage to this is that later we should be able to pass this
structure to the update_itr functions without needing to pass individual
rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |   16 +++--
 drivers/net/ixgbe/ixgbe_ethtool.c |    6 +-
 drivers/net/ixgbe/ixgbe_main.c    |  150 ++++++++++++++++++------------------
 3 files changed, 88 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 744b641..a5ed9fd 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -277,6 +277,15 @@ struct ixgbe_ring_feature {
 	int mask;
 } ____cacheline_internodealigned_in_smp;
 
+struct ixgbe_ring_container {
+#if MAX_RX_QUEUES > MAX_TX_QUEUES
+	DECLARE_BITMAP(idx, MAX_RX_QUEUES);
+#else
+	DECLARE_BITMAP(idx, MAX_TX_QUEUES);
+#endif
+	u8 count;			/* total number of rings in vector */
+	u8 itr;				/* current ITR setting for ring */
+};
 
 #define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) \
                               ? 8 : 1)
@@ -294,12 +303,7 @@ struct ixgbe_q_vector {
 	int cpu;	    /* CPU for DCA */
 #endif
 	struct napi_struct napi;
-	DECLARE_BITMAP(rxr_idx, MAX_RX_QUEUES); /* Rx ring indices */
-	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
-	u8 rxr_count;     /* Rx ring count assigned to this vector */
-	u8 txr_count;     /* Tx ring count assigned to this vector */
-	u8 tx_itr;
-	u8 rx_itr;
+	struct ixgbe_ring_container rx, tx;
 	u32 eitr;
 	cpumask_var_t affinity_mask;
 	char name[IFNAMSIZ + 9];
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 074e9ba..cd842f9 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2122,7 +2122,7 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 	}
 
 	/* if in mixed tx/rx queues per vector mode, report only rx settings */
-	if (adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count)
+	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count)
 		return 0;
 
 	/* only valid if in constant ITR mode */
@@ -2187,7 +2187,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	bool need_reset = false;
 
 	/* don't accept tx specific changes if we've got mixed RxTx vectors */
-	if (adapter->q_vector[0]->txr_count && adapter->q_vector[0]->rxr_count
+	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count
 	   && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
@@ -2261,7 +2261,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		int num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 		for (i = 0; i < num_vectors; i++) {
 			q_vector = adapter->q_vector[i];
-			if (q_vector->txr_count && !q_vector->rxr_count)
+			if (q_vector->tx.count && !q_vector->rx.count)
 				/* tx only */
 				q_vector->eitr = adapter->tx_eitr_param;
 			else
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7275c5c..bd1fd8f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -959,17 +959,17 @@ static void ixgbe_update_dca(struct ixgbe_q_vector *q_vector)
 	if (q_vector->cpu == cpu)
 		goto out_no_update;
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	for (i = 0; i < q_vector->txr_count; i++) {
+	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->tx.count; i++) {
 		ixgbe_update_tx_dca(adapter, adapter->tx_ring[r_idx], cpu);
-		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rxr_count; i++) {
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rx.count; i++) {
 		ixgbe_update_rx_dca(adapter, adapter->rx_ring[r_idx], cpu);
-		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
 
@@ -1517,31 +1517,31 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	for (v_idx = 0; v_idx < q_vectors; v_idx++) {
 		q_vector = adapter->q_vector[v_idx];
 		/* XXX for_each_set_bit(...) */
-		r_idx = find_first_bit(q_vector->rxr_idx,
+		r_idx = find_first_bit(q_vector->rx.idx,
 				       adapter->num_rx_queues);
 
-		for (i = 0; i < q_vector->rxr_count; i++) {
+		for (i = 0; i < q_vector->rx.count; i++) {
 			u8 reg_idx = adapter->rx_ring[r_idx]->reg_idx;
 			ixgbe_set_ivar(adapter, 0, reg_idx, v_idx);
-			r_idx = find_next_bit(q_vector->rxr_idx,
+			r_idx = find_next_bit(q_vector->rx.idx,
 					      adapter->num_rx_queues,
 					      r_idx + 1);
 		}
-		r_idx = find_first_bit(q_vector->txr_idx,
+		r_idx = find_first_bit(q_vector->tx.idx,
 				       adapter->num_tx_queues);
 
-		for (i = 0; i < q_vector->txr_count; i++) {
+		for (i = 0; i < q_vector->tx.count; i++) {
 			u8 reg_idx = adapter->tx_ring[r_idx]->reg_idx;
 			ixgbe_set_ivar(adapter, 1, reg_idx, v_idx);
-			r_idx = find_next_bit(q_vector->txr_idx,
+			r_idx = find_next_bit(q_vector->tx.idx,
 					      adapter->num_tx_queues,
 					      r_idx + 1);
 		}
 
-		if (q_vector->txr_count && !q_vector->rxr_count)
+		if (q_vector->tx.count && !q_vector->rx.count)
 			/* tx only */
 			q_vector->eitr = adapter->tx_eitr_param;
-		else if (q_vector->rxr_count)
+		else if (q_vector->rx.count)
 			/* rx or mixed */
 			q_vector->eitr = adapter->rx_eitr_param;
 
@@ -1705,37 +1705,37 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	u32 new_itr;
 	u8 current_itr, ret_itr;
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	for (i = 0; i < q_vector->txr_count; i++) {
+	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->tx.count; i++) {
 		struct ixgbe_ring *tx_ring = adapter->tx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->tx_itr,
+					   q_vector->tx.itr,
 					   tx_ring->total_packets,
 					   tx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
-		q_vector->tx_itr = ((q_vector->tx_itr > ret_itr) ?
-				    q_vector->tx_itr - 1 : ret_itr);
-		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		q_vector->tx.itr = ((q_vector->tx.itr > ret_itr) ?
+				    q_vector->tx.itr - 1 : ret_itr);
+		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rxr_count; i++) {
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rx.count; i++) {
 		struct ixgbe_ring *rx_ring = adapter->rx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->rx_itr,
+					   q_vector->rx.itr,
 					   rx_ring->total_packets,
 					   rx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
-		q_vector->rx_itr = ((q_vector->rx_itr > ret_itr) ?
-				    q_vector->rx_itr - 1 : ret_itr);
-		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		q_vector->rx.itr = ((q_vector->rx.itr > ret_itr) ?
+				    q_vector->rx.itr - 1 : ret_itr);
+		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
 
-	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
+	current_itr = max(q_vector->rx.itr, q_vector->tx.itr);
 
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
@@ -1995,15 +1995,15 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	struct ixgbe_ring     *tx_ring;
 	int i, r_idx;
 
-	if (!q_vector->txr_count)
+	if (!q_vector->tx.count)
 		return IRQ_HANDLED;
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	for (i = 0; i < q_vector->txr_count; i++) {
+	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->tx.count; i++) {
 		tx_ring = adapter->tx_ring[r_idx];
 		tx_ring->total_bytes = 0;
 		tx_ring->total_packets = 0;
-		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
 
@@ -2031,16 +2031,16 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rxr_count; i++) {
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rx.count; i++) {
 		rx_ring = adapter->rx_ring[r_idx];
 		rx_ring->total_bytes = 0;
 		rx_ring->total_packets = 0;
-		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
 
-	if (!q_vector->rxr_count)
+	if (!q_vector->rx.count)
 		return IRQ_HANDLED;
 
 	/* EIAM disabled interrupts (on this vector) for us */
@@ -2057,24 +2057,24 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 	int r_idx;
 	int i;
 
-	if (!q_vector->txr_count && !q_vector->rxr_count)
+	if (!q_vector->tx.count && !q_vector->rx.count)
 		return IRQ_HANDLED;
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	for (i = 0; i < q_vector->txr_count; i++) {
+	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->tx.count; i++) {
 		ring = adapter->tx_ring[r_idx];
 		ring->total_bytes = 0;
 		ring->total_packets = 0;
-		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rxr_count; i++) {
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rx.count; i++) {
 		ring = adapter->rx_ring[r_idx];
 		ring->total_bytes = 0;
 		ring->total_packets = 0;
-		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
 
@@ -2106,7 +2106,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
 	rx_ring = adapter->rx_ring[r_idx];
 
 	ixgbe_clean_rx_irq(q_vector, rx_ring, &work_done, budget);
@@ -2147,27 +2147,27 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	for (i = 0; i < q_vector->txr_count; i++) {
+	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->tx.count; i++) {
 		ring = adapter->tx_ring[r_idx];
 		tx_clean_complete &= ixgbe_clean_tx_irq(q_vector, ring);
-		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
 	 * the budget to go below 1 because we'll exit polling */
-	budget /= (q_vector->rxr_count ?: 1);
+	budget /= (q_vector->rx.count ?: 1);
 	budget = max(budget, 1);
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rxr_count; i++) {
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rx.count; i++) {
 		ring = adapter->rx_ring[r_idx];
 		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
-		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
 
-	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
 	ring = adapter->rx_ring[r_idx];
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
@@ -2205,7 +2205,7 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
 	tx_ring = adapter->tx_ring[r_idx];
 
 	if (!ixgbe_clean_tx_irq(q_vector, tx_ring))
@@ -2230,8 +2230,8 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
 	struct ixgbe_ring *rx_ring = a->rx_ring[r_idx];
 
-	set_bit(r_idx, q_vector->rxr_idx);
-	q_vector->rxr_count++;
+	set_bit(r_idx, q_vector->rx.idx);
+	q_vector->rx.count++;
 	rx_ring->q_vector = q_vector;
 }
 
@@ -2241,8 +2241,8 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
 	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
 	struct ixgbe_ring *tx_ring = a->tx_ring[t_idx];
 
-	set_bit(t_idx, q_vector->txr_idx);
-	q_vector->txr_count++;
+	set_bit(t_idx, q_vector->tx.idx);
+	q_vector->tx.count++;
 	tx_ring->q_vector = q_vector;
 }
 
@@ -2332,10 +2332,10 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	if (err)
 		return err;
 
-#define SET_HANDLER(_v) (((_v)->rxr_count && (_v)->txr_count)        \
+#define SET_HANDLER(_v) (((_v)->rx.count && (_v)->tx.count)        \
 					  ? &ixgbe_msix_clean_many : \
-			  (_v)->rxr_count ? &ixgbe_msix_clean_rx   : \
-			  (_v)->txr_count ? &ixgbe_msix_clean_tx   : \
+			  (_v)->rx.count ? &ixgbe_msix_clean_rx   : \
+			  (_v)->tx.count ? &ixgbe_msix_clean_tx   : \
 			  NULL)
 	for (vector = 0; vector < q_vectors; vector++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
@@ -2394,16 +2394,16 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	u32 new_itr = q_vector->eitr;
 	u8 current_itr;
 
-	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
-					    q_vector->tx_itr,
+	q_vector->tx.itr = ixgbe_update_itr(adapter, new_itr,
+					    q_vector->tx.itr,
 					    tx_ring->total_packets,
 					    tx_ring->total_bytes);
-	q_vector->rx_itr = ixgbe_update_itr(adapter, new_itr,
-					    q_vector->rx_itr,
+	q_vector->rx.itr = ixgbe_update_itr(adapter, new_itr,
+					    q_vector->rx.itr,
 					    rx_ring->total_packets,
 					    rx_ring->total_bytes);
 
-	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
+	current_itr = max(q_vector->rx.itr, q_vector->tx.itr);
 
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
@@ -2553,10 +2553,10 @@ static inline void ixgbe_reset_q_vectors(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < q_vectors; i++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
-		bitmap_zero(q_vector->rxr_idx, MAX_RX_QUEUES);
-		bitmap_zero(q_vector->txr_idx, MAX_TX_QUEUES);
-		q_vector->rxr_count = 0;
-		q_vector->txr_count = 0;
+		bitmap_zero(q_vector->rx.idx, MAX_RX_QUEUES);
+		bitmap_zero(q_vector->tx.idx, MAX_TX_QUEUES);
+		q_vector->rx.count = 0;
+		q_vector->tx.count = 0;
 	}
 }
 
@@ -2601,8 +2601,8 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		i--;
 		for (; i >= 0; i--) {
 			/* free only the irqs that were actually requested */
-			if (!adapter->q_vector[i]->rxr_count &&
-			    !adapter->q_vector[i]->txr_count)
+			if (!adapter->q_vector[i]->rx.count &&
+			    !adapter->q_vector[i]->tx.count)
 				continue;
 
 			free_irq(adapter->msix_entries[i].vector,
@@ -3616,10 +3616,10 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 		q_vector = adapter->q_vector[q_idx];
 		napi = &q_vector->napi;
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-			if (!q_vector->rxr_count || !q_vector->txr_count) {
-				if (q_vector->txr_count == 1)
+			if (!q_vector->rx.count || !q_vector->tx.count) {
+				if (q_vector->tx.count == 1)
 					napi->poll = &ixgbe_clean_txonly;
-				else if (q_vector->rxr_count == 1)
+				else if (q_vector->rx.count == 1)
 					napi->poll = &ixgbe_clean_rxonly;
 			}
 		}
@@ -4965,7 +4965,7 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
-		if (q_vector->txr_count && !q_vector->rxr_count)
+		if (q_vector->tx.count && !q_vector->rx.count)
 			q_vector->eitr = adapter->tx_eitr_param;
 		else
 			q_vector->eitr = adapter->rx_eitr_param;
@@ -5979,7 +5979,7 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 		/* get one bit for every active tx/rx interrupt vector */
 		for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
 			struct ixgbe_q_vector *qv = adapter->q_vector[i];
-			if (qv->rxr_count || qv->txr_count)
+			if (qv->rx.count || qv->tx.count)
 				eics |= ((u64)1 << i);
 		}
 	}
-- 
1.7.6

