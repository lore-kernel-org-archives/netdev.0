From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 03/10] ixgbe: move tx processing into NAPI context
Date: Thu, 04 Jun 2009 19:00:27 -0700
Message-ID: <20090605020026.8468.65360.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:46018
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752029AbZFECAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:00:44 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves the tx cleanup processing out of the MSI-X interrupt
processing and gives it it's own napi routine.  This allows the driver to
process TX cleanup in a polling context instead of in an interrupt context
which prevents TX from starving RX.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  141 ++++++++++++++++++++++++++++++----------
 1 files changed, 107 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2500e8b..f81fff5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1178,17 +1178,16 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
-#ifdef CONFIG_IXGBE_DCA
-		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-			ixgbe_update_tx_dca(adapter, tx_ring);
-#endif
 		tx_ring->total_bytes = 0;
 		tx_ring->total_packets = 0;
-		ixgbe_clean_tx_irq(q_vector, tx_ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 		                      r_idx + 1);
 	}
 
+	/* disable interrupts on this vector only */
+	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
+	napi_schedule(&q_vector->napi);
+
 	return IRQ_HANDLED;
 }
 
@@ -1228,8 +1227,36 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 
 static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 {
-	ixgbe_msix_clean_rx(irq, data);
-	ixgbe_msix_clean_tx(irq, data);
+	struct ixgbe_q_vector *q_vector = data;
+	struct ixgbe_adapter  *adapter = q_vector->adapter;
+	struct ixgbe_ring  *ring;
+	int r_idx;
+	int i;
+
+	if (!q_vector->txr_count && !q_vector->rxr_count)
+		return IRQ_HANDLED;
+
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->txr_count; i++) {
+		ring = &(adapter->tx_ring[r_idx]);
+		ring->total_bytes = 0;
+		ring->total_packets = 0;
+		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		                      r_idx + 1);
+	}
+
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rxr_count; i++) {
+		ring = &(adapter->rx_ring[r_idx]);
+		ring->total_bytes = 0;
+		ring->total_packets = 0;
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		                      r_idx + 1);
+	}
+
+	/* disable interrupts on this vector only */
+	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
+	napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1274,21 +1301,34 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 }
 
 /**
- * ixgbe_clean_rxonly_many - msix (aka one shot) rx clean routine
+ * ixgbe_clean_rxtx_many - msix (aka one shot) rx clean routine
  * @napi: napi struct with our devices info in it
  * @budget: amount of work driver is allowed to do this pass, in packets
  *
  * This function will clean more than one rx queue associated with a
  * q_vector.
  **/
-static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
+static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
 	                       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring *rx_ring = NULL;
+	struct ixgbe_ring *ring = NULL;
 	int work_done = 0, i;
 	long r_idx;
+	bool tx_clean_complete = true;
+
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->txr_count; i++) {
+		ring = &(adapter->tx_ring[r_idx]);
+#ifdef CONFIG_IXGBE_DCA
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+			ixgbe_update_tx_dca(adapter, ring);
+#endif
+		tx_clean_complete &= ixgbe_clean_tx_irq(q_vector, ring);
+		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+		                      r_idx + 1);
+	}
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
 	 * the budget to go below 1 because we'll exit polling */
@@ -1296,18 +1336,18 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	budget = max(budget, 1);
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
-		rx_ring = &(adapter->rx_ring[r_idx]);
+		ring = &(adapter->rx_ring[r_idx]);
 #ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-			ixgbe_update_rx_dca(adapter, rx_ring);
+			ixgbe_update_rx_dca(adapter, ring);
 #endif
-		ixgbe_clean_rx_irq(q_vector, rx_ring, &work_done, budget);
+		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 		                      r_idx + 1);
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	rx_ring = &(adapter->rx_ring[r_idx]);
+	ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
@@ -1321,6 +1361,46 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 
 	return work_done;
 }
+
+/**
+ * ixgbe_clean_txonly - msix (aka one shot) tx clean routine
+ * @napi: napi struct with our devices info in it
+ * @budget: amount of work driver is allowed to do this pass, in packets
+ *
+ * This function is optimized for cleaning one queue only on a single
+ * q_vector!!!
+ **/
+static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
+{
+	struct ixgbe_q_vector *q_vector =
+	                       container_of(napi, struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_ring *tx_ring = NULL;
+	int work_done = 0;
+	long r_idx;
+
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	tx_ring = &(adapter->tx_ring[r_idx]);
+#ifdef CONFIG_IXGBE_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		ixgbe_update_tx_dca(adapter, tx_ring);
+#endif
+
+	if (!ixgbe_clean_tx_irq(q_vector, tx_ring))
+		work_done = budget;
+
+	/* If all Rx work done, exit the polling mode */
+	if (work_done < budget) {
+		napi_complete(napi);
+		if (adapter->itr_setting & 1)
+			ixgbe_set_itr_msix(q_vector);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
+	}
+
+	return work_done;
+}
+
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
                                      int r_idx)
 {
@@ -2213,12 +2293,15 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
 		struct napi_struct *napi;
 		q_vector = adapter->q_vector[q_idx];
-		if (!q_vector->rxr_count)
-			continue;
 		napi = &q_vector->napi;
-		if ((adapter->flags & IXGBE_FLAG_MSIX_ENABLED) &&
-		    (q_vector->rxr_count > 1))
-			napi->poll = &ixgbe_clean_rxonly_many;
+		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+			if (!q_vector->rxr_count || !q_vector->txr_count) {
+				if (q_vector->txr_count == 1)
+					napi->poll = &ixgbe_clean_txonly;
+				else if (q_vector->rxr_count == 1)
+					napi->poll = &ixgbe_clean_rxonly;
+			}
+		}
 
 		napi_enable(napi);
 	}
@@ -2236,8 +2319,6 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
 		q_vector = adapter->q_vector[q_idx];
-		if (!q_vector->rxr_count)
-			continue;
 		napi_disable(&q_vector->napi);
 	}
 }
@@ -3321,7 +3402,7 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 		napi_vectors = adapter->num_rx_queues;
-		poll = &ixgbe_clean_rxonly;
+		poll = &ixgbe_clean_rxtx_many;
 	} else {
 		num_q_vectors = 1;
 		napi_vectors = 1;
@@ -3335,9 +3416,7 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		q_vector->adapter = adapter;
 		q_vector->eitr = adapter->eitr_param;
 		q_vector->v_idx = q_idx;
-		if (q_idx < napi_vectors)
-			netif_napi_add(adapter->netdev, &q_vector->napi,
-			               (*poll), 64);
+		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
 		adapter->q_vector[q_idx] = q_vector;
 	}
 
@@ -3365,22 +3444,16 @@ err_out:
 static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 {
 	int q_idx, num_q_vectors;
-	int napi_vectors;
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-		napi_vectors = adapter->num_rx_queues;
-	} else {
+	else
 		num_q_vectors = 1;
-		napi_vectors = 1;
-	}
 
 	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[q_idx];
-
 		adapter->q_vector[q_idx] = NULL;
-		if (q_idx < napi_vectors)
-			netif_napi_del(&q_vector->napi);
+		netif_napi_del(&q_vector->napi);
 		kfree(q_vector);
 	}
 }

