From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] v2 ixgbe: consolidate all MSI-X ring interrupts and poll routines into one
Date: Thu, 15 Sep 2011 21:42:44 -0700
Message-ID: <1316148173-11209-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab1IPEm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:42:57 -0400
In-Reply-To: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change consolidates all of the MSI-X interrupt and polling routines
into two single functions.  One for the interrupt and one for the code.
The main advantage to doing this is that the compiler can optimize the
routines into single monolithic functions which should allow all of them
function to occupy a single block of memory and as such avoid jumping
around.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  279 ++++++-------------------
 1 files changed, 63 insertions(+), 216 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0f633ad..3ce0277 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1297,9 +1297,9 @@ static inline bool ixgbe_get_rsc_state(union ixgbe_adv_rx_desc *rx_desc)
 		IXGBE_RXDADV_RSCCNT_MASK);
 }
 
-static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
+static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *rx_ring,
-			       int *work_done, int work_to_do)
+			       int budget)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
@@ -1479,11 +1479,11 @@ static void ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 #endif /* IXGBE_FCOE */
 		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
 
+		budget--;
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
 
-		(*work_done)++;
-		if (*work_done >= work_to_do)
+		if (!budget)
 			break;
 
 		/* return some buffers to hardware, one at a time is too slow */
@@ -1524,9 +1524,10 @@ next_desc:
 	u64_stats_update_end(&rx_ring->syncp);
 	q_vector->rx.total_packets += total_rx_packets;
 	q_vector->rx.total_bytes += total_rx_bytes;
+
+	return !!budget;
 }
 
-static int ixgbe_clean_rxonly(struct napi_struct *, int);
 /**
  * ixgbe_configure_msix - Configure MSI-X hardware
  * @adapter: board private structure
@@ -1980,167 +1981,18 @@ static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
 	/* skip the flush */
 }
 
-static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
-{
-	struct ixgbe_q_vector *q_vector = data;
-
-	if (!q_vector->tx.count)
-		return IRQ_HANDLED;
-
-	/* EIAM disabled interrupts (on this vector) for us */
-	napi_schedule(&q_vector->napi);
-
-	return IRQ_HANDLED;
-}
-
-/**
- * ixgbe_msix_clean_rx - single unshared vector rx clean (all queues)
- * @irq: unused
- * @data: pointer to our q_vector struct for this interrupt vector
- **/
-static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
+static irqreturn_t ixgbe_msix_clean_rings(int irq, void *data)
 {
 	struct ixgbe_q_vector *q_vector = data;
 
-	if (!q_vector->rx.count)
-		return IRQ_HANDLED;
-
 	/* EIAM disabled interrupts (on this vector) for us */
-	napi_schedule(&q_vector->napi);
-
-	return IRQ_HANDLED;
-}
-
-static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
-{
-	struct ixgbe_q_vector *q_vector = data;
 
-	if (!q_vector->tx.count && !q_vector->rx.count)
-		return IRQ_HANDLED;
-
-	/* EIAM disabled interrupts (on this vector) for us */
-	napi_schedule(&q_vector->napi);
+	if (q_vector->rx.ring || q_vector->tx.ring)
+		napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
 
-/**
- * ixgbe_clean_rxonly - msix (aka one shot) rx clean routine
- * @napi: napi struct with our devices info in it
- * @budget: amount of work driver is allowed to do this pass, in packets
- *
- * This function is optimized for cleaning one queue only on a single
- * q_vector!!!
- **/
-static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
-{
-	struct ixgbe_q_vector *q_vector =
-			       container_of(napi, struct ixgbe_q_vector, napi);
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int work_done = 0;
-
-#ifdef CONFIG_IXGBE_DCA
-	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_dca(q_vector);
-#endif
-
-	ixgbe_clean_rx_irq(q_vector, q_vector->rx.ring, &work_done, budget);
-
-	/* If all Rx work done, exit the polling mode */
-	if (work_done < budget) {
-		napi_complete(napi);
-		if (adapter->rx_itr_setting & 1)
-			ixgbe_set_itr(q_vector);
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter,
-						((u64)1 << q_vector->v_idx));
-	}
-
-	return work_done;
-}
-
-/**
- * ixgbe_clean_rxtx_many - msix (aka one shot) rx clean routine
- * @napi: napi struct with our devices info in it
- * @budget: amount of work driver is allowed to do this pass, in packets
- *
- * This function will clean more than one rx queue associated with a
- * q_vector.
- **/
-static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
-{
-	struct ixgbe_q_vector *q_vector =
-			       container_of(napi, struct ixgbe_q_vector, napi);
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring *ring;
-	int work_done = 0;
-	bool clean_complete = true;
-
-#ifdef CONFIG_IXGBE_DCA
-	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_dca(q_vector);
-#endif
-
-	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
-		clean_complete &= ixgbe_clean_tx_irq(q_vector, ring);
-
-	/* attempt to distribute budget to each queue fairly, but don't allow
-	 * the budget to go below 1 because we'll exit polling */
-	budget /= (q_vector->rx.count ?: 1);
-	budget = max(budget, 1);
-
-	for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
-		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
-
-	if (!clean_complete)
-		work_done = budget;
-
-	/* If all Rx work done, exit the polling mode */
-	if (work_done < budget) {
-		napi_complete(napi);
-		if (adapter->rx_itr_setting & 1)
-			ixgbe_set_itr(q_vector);
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter,
-						((u64)1 << q_vector->v_idx));
-		return 0;
-	}
-
-	return work_done;
-}
-
-/**
- * ixgbe_clean_txonly - msix (aka one shot) tx clean routine
- * @napi: napi struct with our devices info in it
- * @budget: amount of work driver is allowed to do this pass, in packets
- *
- * This function is optimized for cleaning one queue only on a single
- * q_vector!!!
- **/
-static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
-{
-	struct ixgbe_q_vector *q_vector =
-			       container_of(napi, struct ixgbe_q_vector, napi);
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-
-#ifdef CONFIG_IXGBE_DCA
-	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_dca(q_vector);
-#endif
-
-	if (!ixgbe_clean_tx_irq(q_vector, q_vector->tx.ring))
-		return budget;
-
-	/* If all Tx work done, exit the polling mode */
-	napi_complete(napi);
-	if (adapter->tx_itr_setting & 1)
-		ixgbe_set_itr(q_vector);
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
-
-	return 0;
-}
-
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 				     int r_idx)
 {
@@ -2241,7 +2093,6 @@ out:
 static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	irqreturn_t (*handler)(int, void *);
 	int i, vector, q_vectors, err;
 	int ri = 0, ti = 0;
 
@@ -2252,31 +2103,25 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	if (err)
 		return err;
 
-#define SET_HANDLER(_v) (((_v)->rx.count && (_v)->tx.count)        \
-					  ? &ixgbe_msix_clean_many : \
-			  (_v)->rx.count ? &ixgbe_msix_clean_rx   : \
-			  (_v)->tx.count ? &ixgbe_msix_clean_tx   : \
-			  NULL)
 	for (vector = 0; vector < q_vectors; vector++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[vector];
-		handler = SET_HANDLER(q_vector);
 
-		if (handler == &ixgbe_msix_clean_rx) {
+		if (q_vector->tx.ring && q_vector->rx.ring) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-			         "%s-%s-%d", netdev->name, "rx", ri++);
-		} else if (handler == &ixgbe_msix_clean_tx) {
+				 "%s-%s-%d", netdev->name, "TxRx", ri++);
+			ti++;
+		} else if (q_vector->rx.ring) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-			         "%s-%s-%d", netdev->name, "tx", ti++);
-		} else if (handler == &ixgbe_msix_clean_many) {
+				 "%s-%s-%d", netdev->name, "rx", ri++);
+		} else if (q_vector->tx.ring) {
 			snprintf(q_vector->name, sizeof(q_vector->name) - 1,
-			         "%s-%s-%d", netdev->name, "TxRx", ri++);
-			ti++;
+				 "%s-%s-%d", netdev->name, "tx", ti++);
 		} else {
 			/* skip this unused q_vector */
 			continue;
 		}
 		err = request_irq(adapter->msix_entries[vector].vector,
-				  handler, 0, q_vector->name,
+				  &ixgbe_msix_clean_rings, 0, q_vector->name,
 				  q_vector);
 		if (err) {
 			e_err(probe, "request_irq failed for MSIX interrupt "
@@ -2484,8 +2329,8 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 		i--;
 		for (; i >= 0; i--) {
 			/* free only the irqs that were actually requested */
-			if (!adapter->q_vector[i]->rx.count &&
-			    !adapter->q_vector[i]->tx.count)
+			if (!adapter->q_vector[i]->rx.ring &&
+			    !adapter->q_vector[i]->tx.ring)
 				continue;
 
 			free_irq(adapter->msix_entries[i].vector,
@@ -3478,19 +3323,8 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 		q_vectors = 1;
 
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
-		struct napi_struct *napi;
 		q_vector = adapter->q_vector[q_idx];
-		napi = &q_vector->napi;
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-			if (!q_vector->rx.count || !q_vector->tx.count) {
-				if (q_vector->tx.count == 1)
-					napi->poll = &ixgbe_clean_txonly;
-				else if (q_vector->rx.count == 1)
-					napi->poll = &ixgbe_clean_rxonly;
-			}
-		}
-
-		napi_enable(napi);
+		napi_enable(&q_vector->napi);
 	}
 }
 
@@ -4148,28 +3982,41 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	struct ixgbe_q_vector *q_vector =
 				container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int tx_clean_complete, work_done = 0;
+	struct ixgbe_ring *ring;
+	int per_ring_budget;
+	bool clean_complete = true;
 
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring[0]);
-	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring[0], &work_done, budget);
+	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
+		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
 
-	if (!tx_clean_complete)
-		work_done = budget;
+	/* attempt to distribute budget to each queue fairly, but don't allow
+	 * the budget to go below 1 because we'll exit polling */
+	if (q_vector->rx.count > 1)
+		per_ring_budget = max(budget/q_vector->rx.count, 1);
+	else
+		per_ring_budget = budget;
 
-	/* If budget not fully consumed, exit the polling mode */
-	if (work_done < budget) {
-		napi_complete(napi);
-		if (adapter->rx_itr_setting & 1)
-			ixgbe_set_itr(q_vector);
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter, IXGBE_EIMS_RTX_QUEUE);
-	}
-	return work_done;
+	for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
+		clean_complete &= ixgbe_clean_rx_irq(q_vector, ring,
+						     per_ring_budget);
+
+	/* If all work not completed, return budget and keep polling */
+	if (!clean_complete)
+		return budget;
+
+	/* all work done, exit the polling mode */
+	napi_complete(napi);
+	if (adapter->rx_itr_setting & 1)
+		ixgbe_set_itr(q_vector);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
+
+	return 0;
 }
 
 /**
@@ -4810,19 +4657,15 @@ out:
  **/
 static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 {
-	int q_idx, num_q_vectors;
+	int v_idx, num_q_vectors;
 	struct ixgbe_q_vector *q_vector;
-	int (*poll)(struct napi_struct *, int);
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-		poll = &ixgbe_clean_rxtx_many;
-	} else {
+	else
 		num_q_vectors = 1;
-		poll = &ixgbe_poll;
-	}
 
-	for (q_idx = 0; q_idx < num_q_vectors; q_idx++) {
+	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
 		q_vector = kzalloc_node(sizeof(struct ixgbe_q_vector),
 					GFP_KERNEL, adapter->node);
 		if (!q_vector)
@@ -4830,25 +4673,29 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 					   GFP_KERNEL);
 		if (!q_vector)
 			goto err_out;
+
 		q_vector->adapter = adapter;
+		q_vector->v_idx = v_idx;
+
 		if (q_vector->tx.count && !q_vector->rx.count)
 			q_vector->eitr = adapter->tx_eitr_param;
 		else
 			q_vector->eitr = adapter->rx_eitr_param;
-		q_vector->v_idx = q_idx;
-		netif_napi_add(adapter->netdev, &q_vector->napi, (*poll), 64);
-		adapter->q_vector[q_idx] = q_vector;
+
+		netif_napi_add(adapter->netdev, &q_vector->napi,
+			       ixgbe_poll, 64);
+		adapter->q_vector[v_idx] = q_vector;
 	}
 
 	return 0;
 
 err_out:
-	while (q_idx) {
-		q_idx--;
-		q_vector = adapter->q_vector[q_idx];
+	while (v_idx) {
+		v_idx--;
+		q_vector = adapter->q_vector[v_idx];
 		netif_napi_del(&q_vector->napi);
 		kfree(q_vector);
-		adapter->q_vector[q_idx] = NULL;
+		adapter->q_vector[v_idx] = NULL;
 	}
 	return -ENOMEM;
 }
@@ -6960,7 +6807,7 @@ static void ixgbe_netpoll(struct net_device *netdev)
 		int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 		for (i = 0; i < num_q_vectors; i++) {
 			struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
-			ixgbe_msix_clean_many(0, q_vector);
+			ixgbe_msix_clean_rings(0, q_vector);
 		}
 	} else {
 		ixgbe_intr(adapter->pdev->irq, netdev);
-- 
1.7.6
