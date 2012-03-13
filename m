From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbe: Allocate rings as part of the q_vector
Date: Mon, 12 Mar 2012 21:03:50 -0700
Message-ID: <1331611432-30109-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab2CMEEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:04:05 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes the rings a part of the q_vector directly instead of
indirectly.  Specifically on x86 systems this helps to avoid any cache
set conflicts between the q_vector, the tx_rings, and the rx_rings as the
critical stride is 4K and in order to cross that boundary you would need to
have over 15 rings on a single q_vector.

In addition this allows for smarter allocations when Flow Director is
enabled.  Previously Flow Director would set the irq_affinity hints based
on the CPU and was still using a node interleaving approach which on some
systems would end up with the two values mismatched.  With the new approach
we can set the affinity for the irq_vector and use the CPU for that
affinity to determine the node value for the node and the rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  489 +++++++++++-----------
 3 files changed, 244 insertions(+), 257 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f25b4e2..699899a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -254,10 +254,8 @@ struct ixgbe_ring {
 		struct ixgbe_tx_queue_stats tx_stats;
 		struct ixgbe_rx_queue_stats rx_stats;
 	};
-	int numa_node;
 	unsigned int size;		/* length in bytes */
 	dma_addr_t dma;			/* phys. address of descriptor ring */
-	struct rcu_head rcu;
 	struct ixgbe_q_vector *q_vector; /* back-pointer to host q_vector */
 } ____cacheline_internodealigned_in_smp;
 
@@ -317,8 +315,13 @@ struct ixgbe_q_vector {
 	struct ixgbe_ring_container rx, tx;
 
 	struct napi_struct napi;
-	cpumask_var_t affinity_mask;
+	cpumask_t affinity_mask;
+	int numa_node;
+	struct rcu_head rcu;	/* to avoid race with update stats on free */
 	char name[IFNAMSIZ + 9];
+
+	/* for dynamic allocation of rings associated with this q_vector */
+	struct ixgbe_ring ring[0] ____cacheline_internodealigned_in_smp;
 };
 
 /*
@@ -514,7 +517,6 @@ struct ixgbe_adapter {
 	u16 eeprom_verl;
 	u16 eeprom_cap;
 
-	int node;
 	u32 interrupt_event;
 	u32 led_reg;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 4846206..51d159b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1591,7 +1591,6 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	tx_ring->dev = &adapter->pdev->dev;
 	tx_ring->netdev = adapter->netdev;
 	tx_ring->reg_idx = adapter->tx_ring[0]->reg_idx;
-	tx_ring->numa_node = adapter->node;
 
 	err = ixgbe_setup_tx_resources(tx_ring);
 	if (err)
@@ -1617,7 +1616,6 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	rx_ring->netdev = adapter->netdev;
 	rx_ring->reg_idx = adapter->rx_ring[0]->reg_idx;
 	rx_ring->rx_buf_len = IXGBE_RXBUFFER_2K;
-	rx_ring->numa_node = adapter->node;
 
 	err = ixgbe_setup_rx_resources(rx_ring);
 	if (err) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b1f53ed..604540d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1893,7 +1893,7 @@ static void ixgbe_set_itr(struct ixgbe_q_vector *q_vector)
 }
 
 /**
- * ixgbe_check_overtemp_subtask - check for over tempurature
+ * ixgbe_check_overtemp_subtask - check for over temperature
  * @adapter: pointer to adapter
  **/
 static void ixgbe_check_overtemp_subtask(struct ixgbe_adapter *adapter)
@@ -2205,78 +2205,6 @@ static irqreturn_t ixgbe_msix_clean_rings(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
-				     int r_idx)
-{
-	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
-	struct ixgbe_ring *rx_ring = a->rx_ring[r_idx];
-
-	rx_ring->q_vector = q_vector;
-	rx_ring->next = q_vector->rx.ring;
-	q_vector->rx.ring = rx_ring;
-	q_vector->rx.count++;
-}
-
-static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
-				     int t_idx)
-{
-	struct ixgbe_q_vector *q_vector = a->q_vector[v_idx];
-	struct ixgbe_ring *tx_ring = a->tx_ring[t_idx];
-
-	tx_ring->q_vector = q_vector;
-	tx_ring->next = q_vector->tx.ring;
-	q_vector->tx.ring = tx_ring;
-	q_vector->tx.count++;
-	q_vector->tx.work_limit = a->tx_work_limit;
-}
-
-/**
- * ixgbe_map_rings_to_vectors - Maps descriptor rings to vectors
- * @adapter: board private structure to initialize
- *
- * This function maps descriptor rings to the queue-specific vectors
- * we were allotted through the MSI-X enabling code.  Ideally, we'd have
- * one vector per ring/queue, but on a constrained vector budget, we
- * group the rings as "efficiently" as possible.  You would add new
- * mapping configurations in here.
- **/
-static void ixgbe_map_rings_to_vectors(struct ixgbe_adapter *adapter)
-{
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	int rxr_remaining = adapter->num_rx_queues, rxr_idx = 0;
-	int txr_remaining = adapter->num_tx_queues, txr_idx = 0;
-	int v_start = 0;
-
-	/* only one q_vector if MSI-X is disabled. */
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
-		q_vectors = 1;
-
-	/*
-	 * If we don't have enough vectors for a 1-to-1 mapping, we'll have to
-	 * group them so there are multiple queues per vector.
-	 *
-	 * Re-adjusting *qpv takes care of the remainder.
-	 */
-	for (; v_start < q_vectors && rxr_remaining; v_start++) {
-		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors - v_start);
-		for (; rqpv; rqpv--, rxr_idx++, rxr_remaining--)
-			map_vector_to_rxq(adapter, v_start, rxr_idx);
-	}
-
-	/*
-	 * If there are not enough q_vectors for each ring to have it's own
-	 * vector then we must pair up Rx/Tx on a each vector
-	 */
-	if ((v_start + txr_remaining) > q_vectors)
-		v_start = 0;
-
-	for (; v_start < q_vectors && txr_remaining; v_start++) {
-		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors - v_start);
-		for (; tqpv; tqpv--, txr_idx++, txr_remaining--)
-			map_vector_to_txq(adapter, v_start, txr_idx);
-	}
-}
-
 /**
  * ixgbe_request_msix_irqs - Initialize MSI-X interrupts
  * @adapter: board private structure
@@ -2320,14 +2248,14 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 			/* assign the mask for this irq */
 			irq_set_affinity_hint(entry->vector,
-					      q_vector->affinity_mask);
+					      &q_vector->affinity_mask);
 		}
 	}
 
 	err = request_irq(adapter->msix_entries[vector].vector,
 			  ixgbe_msix_other, 0, netdev->name, adapter);
 	if (err) {
-		e_err(probe, "request_irq for msix_lsc failed: %d\n", err);
+		e_err(probe, "request_irq for msix_other failed: %d\n", err);
 		goto free_queue_irqs;
 	}
 
@@ -2414,31 +2342,6 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static inline void ixgbe_reset_q_vectors(struct ixgbe_adapter *adapter)
-{
-	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	int i;
-
-	/* legacy and MSI only use one vector */
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
-		q_vectors = 1;
-
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i]->q_vector = NULL;
-		adapter->rx_ring[i]->next = NULL;
-	}
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i]->q_vector = NULL;
-		adapter->tx_ring[i]->next = NULL;
-	}
-
-	for (i = 0; i < q_vectors; i++) {
-		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
-		memset(&q_vector->rx, 0, sizeof(struct ixgbe_ring_container));
-		memset(&q_vector->tx, 0, sizeof(struct ixgbe_ring_container));
-	}
-}
-
 /**
  * ixgbe_request_irq - initialize interrupts
  * @adapter: board private structure
@@ -2451,9 +2354,6 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int err;
 
-	/* map all of the rings to the q_vectors */
-	ixgbe_map_rings_to_vectors(adapter);
-
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
 		err = ixgbe_request_msix_irqs(adapter);
 	else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED)
@@ -2463,13 +2363,9 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 		err = request_irq(adapter->pdev->irq, ixgbe_intr, IRQF_SHARED,
 				  netdev->name, adapter);
 
-	if (err) {
+	if (err)
 		e_err(probe, "request_irq failed, Error %d\n", err);
 
-		/* place q_vectors and rings back into a known good state */
-		ixgbe_reset_q_vectors(adapter);
-	}
-
 	return err;
 }
 
@@ -2499,9 +2395,6 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
 	} else {
 		free_irq(adapter->pdev->irq, adapter);
 	}
-
-	/* clear q_vector state information */
-	ixgbe_reset_q_vectors(adapter);
 }
 
 /**
@@ -4828,75 +4721,6 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_alloc_queues - Allocate memory for all rings
- * @adapter: board private structure to initialize
- *
- * We allocate one ring per queue at run-time since we don't know the
- * number of queues at compile-time.  The polling_netdev array is
- * intended for Multiqueue, but should work fine with a single queue.
- **/
-static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
-{
-	int rx = 0, tx = 0, nid = adapter->node;
-
-	if (nid < 0 || !node_online(nid))
-		nid = first_online_node;
-
-	for (; tx < adapter->num_tx_queues; tx++) {
-		struct ixgbe_ring *ring;
-
-		ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, nid);
-		if (!ring)
-			ring = kzalloc(sizeof(*ring), GFP_KERNEL);
-		if (!ring)
-			goto err_allocation;
-		ring->count = adapter->tx_ring_count;
-		ring->queue_index = tx;
-		ring->numa_node = nid;
-		ring->dev = &adapter->pdev->dev;
-		ring->netdev = adapter->netdev;
-
-		adapter->tx_ring[tx] = ring;
-	}
-
-	for (; rx < adapter->num_rx_queues; rx++) {
-		struct ixgbe_ring *ring;
-
-		ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, nid);
-		if (!ring)
-			ring = kzalloc(sizeof(*ring), GFP_KERNEL);
-		if (!ring)
-			goto err_allocation;
-		ring->count = adapter->rx_ring_count;
-		ring->queue_index = rx;
-		ring->numa_node = nid;
-		ring->dev = &adapter->pdev->dev;
-		ring->netdev = adapter->netdev;
-
-		/*
-		 * 82599 errata, UDP frames with a 0 checksum can be marked as
-		 * checksum errors.
-		 */
-		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			set_bit(__IXGBE_RX_CSUM_UDP_ZERO_ERR, &ring->state);
-
-		adapter->rx_ring[rx] = ring;
-	}
-
-	ixgbe_cache_ring_register(adapter);
-
-	return 0;
-
-err_allocation:
-	while (tx)
-		kfree(adapter->tx_ring[--tx]);
-
-	while (rx)
-		kfree(adapter->rx_ring[--rx]);
-	return -ENOMEM;
-}
-
-/**
  * ixgbe_set_interrupt_capability - set MSI-X or MSI if supported
  * @adapter: board private structure to initialize
  *
@@ -4927,7 +4751,7 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * descriptor queues supported by our device.  Thus, we cap it off in
 	 * those rare cases where the cpu count also exceeds our vector limit.
 	 */
-	v_budget = min(v_budget, (int)hw->mac.max_msix_vectors);
+	v_budget = min_t(int, v_budget, hw->mac.max_msix_vectors);
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter. */
@@ -4974,6 +4798,164 @@ out:
 	return err;
 }
 
+static void ixgbe_add_ring(struct ixgbe_ring *ring,
+			   struct ixgbe_ring_container *head)
+{
+	ring->next = head->ring;
+	head->ring = ring;
+	head->count++;
+}
+
+/**
+ * ixgbe_alloc_q_vector - Allocate memory for a single interrupt vector
+ * @adapter: board private structure to initialize
+ * @v_idx: index of vector in adapter struct
+ *
+ * We allocate one q_vector.  If allocation fails we return -ENOMEM.
+ **/
+static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter, int v_idx,
+				int txr_count, int txr_idx,
+				int rxr_count, int rxr_idx)
+{
+	struct ixgbe_q_vector *q_vector;
+	struct ixgbe_ring *ring;
+	int node = -1;
+	int cpu = -1;
+	int ring_count, size;
+
+	ring_count = txr_count + rxr_count;
+	size = sizeof(struct ixgbe_q_vector) +
+	       (sizeof(struct ixgbe_ring) * ring_count);
+
+	/* customize cpu for Flow Director mapping */
+	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
+		if (cpu_online(v_idx)) {
+			cpu = v_idx;
+			node = cpu_to_node(cpu);
+		}
+	}
+
+	/* allocate q_vector and rings */
+	q_vector = kzalloc_node(size, GFP_KERNEL, node);
+	if (!q_vector)
+		q_vector = kzalloc(size, GFP_KERNEL);
+	if (!q_vector)
+		return -ENOMEM;
+
+	/* setup affinity mask and node */
+	if (cpu != -1)
+		cpumask_set_cpu(cpu, &q_vector->affinity_mask);
+	else
+		cpumask_copy(&q_vector->affinity_mask, cpu_online_mask);
+	q_vector->numa_node = node;
+
+	/* initialize NAPI */
+	netif_napi_add(adapter->netdev, &q_vector->napi,
+		       ixgbe_poll, 64);
+
+	/* tie q_vector and adapter together */
+	adapter->q_vector[v_idx] = q_vector;
+	q_vector->adapter = adapter;
+	q_vector->v_idx = v_idx;
+
+	/* initialize work limits */
+	q_vector->tx.work_limit = adapter->tx_work_limit;
+
+	/* initialize pointer to rings */
+	ring = q_vector->ring;
+
+	while (txr_count) {
+		/* assign generic ring traits */
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+
+		/* configure backlink on ring */
+		ring->q_vector = q_vector;
+
+		/* update q_vector Tx values */
+		ixgbe_add_ring(ring, &q_vector->tx);
+
+		/* apply Tx specific ring traits */
+		ring->count = adapter->tx_ring_count;
+		ring->queue_index = txr_idx;
+
+		/* assign ring to adapter */
+		adapter->tx_ring[txr_idx] = ring;
+
+		/* update count and index */
+		txr_count--;
+		txr_idx++;
+
+		/* push pointer to next ring */
+		ring++;
+	}
+
+	while (rxr_count) {
+		/* assign generic ring traits */
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+
+		/* configure backlink on ring */
+		ring->q_vector = q_vector;
+
+		/* update q_vector Rx values */
+		ixgbe_add_ring(ring, &q_vector->rx);
+
+		/*
+		 * 82599 errata, UDP frames with a 0 checksum
+		 * can be marked as checksum errors.
+		 */
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			set_bit(__IXGBE_RX_CSUM_UDP_ZERO_ERR, &ring->state);
+
+		/* apply Rx specific ring traits */
+		ring->count = adapter->rx_ring_count;
+		ring->queue_index = rxr_idx;
+
+		/* assign ring to adapter */
+		adapter->rx_ring[rxr_idx] = ring;
+
+		/* update count and index */
+		rxr_count--;
+		rxr_idx++;
+
+		/* push pointer to next ring */
+		ring++;
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_free_q_vector - Free memory allocated for specific interrupt vector
+ * @adapter: board private structure to initialize
+ * @v_idx: Index of vector to be freed
+ *
+ * This function frees the memory allocated to the q_vector.  In addition if
+ * NAPI is enabled it will delete any references to the NAPI struct prior
+ * to freeing the q_vector.
+ **/
+static void ixgbe_free_q_vector(struct ixgbe_adapter *adapter, int v_idx)
+{
+	struct ixgbe_q_vector *q_vector = adapter->q_vector[v_idx];
+	struct ixgbe_ring *ring;
+
+	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
+		adapter->tx_ring[ring->queue_index] = NULL;
+
+	for (ring = q_vector->rx.ring; ring != NULL; ring = ring->next)
+		adapter->rx_ring[ring->queue_index] = NULL;
+
+	adapter->q_vector[v_idx] = NULL;
+	netif_napi_del(&q_vector->napi);
+
+	/*
+	 * ixgbe_get_stats64() might access the rings on this vector,
+	 * we must wait a grace period before freeing it.
+	 */
+	kfree_rcu(q_vector, rcu);
+}
+
 /**
  * ixgbe_alloc_q_vectors - Allocate memory for interrupt vectors
  * @adapter: board private structure to initialize
@@ -4983,33 +4965,46 @@ out:
  **/
 static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 {
-	int v_idx, num_q_vectors;
-	struct ixgbe_q_vector *q_vector;
+	int q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	int rxr_remaining = adapter->num_rx_queues;
+	int txr_remaining = adapter->num_tx_queues;
+	int rxr_idx = 0, txr_idx = 0, v_idx = 0;
+	int err;
 
-	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-	else
-		num_q_vectors = 1;
+	/* only one q_vector if MSI-X is disabled. */
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED))
+		q_vectors = 1;
 
-	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
-		q_vector = kzalloc_node(sizeof(struct ixgbe_q_vector),
-					GFP_KERNEL, adapter->node);
-		if (!q_vector)
-			q_vector = kzalloc(sizeof(struct ixgbe_q_vector),
-					   GFP_KERNEL);
-		if (!q_vector)
-			goto err_out;
+	if (q_vectors >= (rxr_remaining + txr_remaining)) {
+		for (; rxr_remaining; v_idx++, q_vectors--) {
+			int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors);
+			err = ixgbe_alloc_q_vector(adapter, v_idx,
+						   0, 0, rqpv, rxr_idx);
 
-		q_vector->adapter = adapter;
-		q_vector->v_idx = v_idx;
+			if (err)
+				goto err_out;
+
+			/* update counts and index */
+			rxr_remaining -= rqpv;
+			rxr_idx += rqpv;
+		}
+	}
 
-		/* Allocate the affinity_hint cpumask, configure the mask */
-		if (!alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL))
+	for (; q_vectors; v_idx++, q_vectors--) {
+		int rqpv = DIV_ROUND_UP(rxr_remaining, q_vectors);
+		int tqpv = DIV_ROUND_UP(txr_remaining, q_vectors);
+		err = ixgbe_alloc_q_vector(adapter, v_idx,
+					   tqpv, txr_idx,
+					   rqpv, rxr_idx);
+
+		if (err)
 			goto err_out;
-		cpumask_set_cpu(v_idx, q_vector->affinity_mask);
-		netif_napi_add(adapter->netdev, &q_vector->napi,
-			       ixgbe_poll, 64);
-		adapter->q_vector[v_idx] = q_vector;
+
+		/* update counts and index */
+		rxr_remaining -= rqpv;
+		rxr_idx += rqpv;
+		txr_remaining -= tqpv;
+		txr_idx += tqpv;
 	}
 
 	return 0;
@@ -5017,12 +5012,9 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 err_out:
 	while (v_idx) {
 		v_idx--;
-		q_vector = adapter->q_vector[v_idx];
-		netif_napi_del(&q_vector->napi);
-		free_cpumask_var(q_vector->affinity_mask);
-		kfree(q_vector);
-		adapter->q_vector[v_idx] = NULL;
+		ixgbe_free_q_vector(adapter, v_idx);
 	}
+
 	return -ENOMEM;
 }
 
@@ -5036,20 +5028,15 @@ err_out:
  **/
 static void ixgbe_free_q_vectors(struct ixgbe_adapter *adapter)
 {
-	int v_idx, num_q_vectors;
+	int v_idx, q_vectors;
 
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-		num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+		q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 	else
-		num_q_vectors = 1;
+		q_vectors = 1;
 
-	for (v_idx = 0; v_idx < num_q_vectors; v_idx++) {
-		struct ixgbe_q_vector *q_vector = adapter->q_vector[v_idx];
-		adapter->q_vector[v_idx] = NULL;
-		netif_napi_del(&q_vector->napi);
-		free_cpumask_var(q_vector->affinity_mask);
-		kfree(q_vector);
-	}
+	for (v_idx = 0; v_idx < q_vectors; v_idx++)
+		ixgbe_free_q_vector(adapter, v_idx);
 }
 
 static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
@@ -5096,11 +5083,7 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 		goto err_alloc_q_vectors;
 	}
 
-	err = ixgbe_alloc_queues(adapter);
-	if (err) {
-		e_dev_err("Unable to allocate memory for queues\n");
-		goto err_alloc_queues;
-	}
+	ixgbe_cache_ring_register(adapter);
 
 	e_dev_info("Multiqueue %s: Rx Queue count = %u, Tx Queue count = %u\n",
 		   (adapter->num_rx_queues > 1) ? "Enabled" : "Disabled",
@@ -5110,8 +5093,6 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 
 	return 0;
 
-err_alloc_queues:
-	ixgbe_free_q_vectors(adapter);
 err_alloc_q_vectors:
 	ixgbe_reset_interrupt_capability(adapter);
 err_set_interrupt:
@@ -5127,22 +5108,6 @@ err_set_interrupt:
  **/
 void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 {
-	int i;
-
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		kfree(adapter->tx_ring[i]);
-		adapter->tx_ring[i] = NULL;
-	}
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->rx_ring[i];
-
-		/* ixgbe_get_stats64() might access this ring, we must wait
-		 * a grace period before freeing it.
-		 */
-		kfree_rcu(ring, rcu);
-		adapter->rx_ring[i] = NULL;
-	}
-
 	adapter->num_tx_queues = 0;
 	adapter->num_rx_queues = 0;
 
@@ -5286,9 +5251,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
-	/* get assigned NUMA node */
-	adapter->node = dev_to_node(&pdev->dev);
-
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -5303,10 +5265,16 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 {
 	struct device *dev = tx_ring->dev;
+	int orig_node = dev_to_node(dev);
+	int numa_node = -1;
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vzalloc_node(size, tx_ring->numa_node);
+
+	if (tx_ring->q_vector)
+		numa_node = tx_ring->q_vector->numa_node;
+
+	tx_ring->tx_buffer_info = vzalloc_node(size, numa_node);
 	if (!tx_ring->tx_buffer_info)
 		tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
@@ -5316,8 +5284,15 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	tx_ring->desc = dma_alloc_coherent(dev, tx_ring->size,
-					   &tx_ring->dma, GFP_KERNEL);
+	set_dev_node(dev, numa_node);
+	tx_ring->desc = dma_alloc_coherent(dev,
+					   tx_ring->size,
+					   &tx_ring->dma,
+					   GFP_KERNEL);
+	set_dev_node(dev, orig_node);
+	if (!tx_ring->desc)
+		tx_ring->desc = dma_alloc_coherent(dev, tx_ring->size,
+						   &tx_ring->dma, GFP_KERNEL);
 	if (!tx_ring->desc)
 		goto err;
 
@@ -5366,10 +5341,16 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
+	int orig_node = dev_to_node(dev);
+	int numa_node = -1;
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vzalloc_node(size, rx_ring->numa_node);
+
+	if (rx_ring->q_vector)
+		numa_node = rx_ring->q_vector->numa_node;
+
+	rx_ring->rx_buffer_info = vzalloc_node(size, numa_node);
 	if (!rx_ring->rx_buffer_info)
 		rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info)
@@ -5379,9 +5360,15 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
-	rx_ring->desc = dma_alloc_coherent(dev, rx_ring->size,
-					   &rx_ring->dma, GFP_KERNEL);
-
+	set_dev_node(dev, numa_node);
+	rx_ring->desc = dma_alloc_coherent(dev,
+					   rx_ring->size,
+					   &rx_ring->dma,
+					   GFP_KERNEL);
+	set_dev_node(dev, orig_node);
+	if (!rx_ring->desc)
+		rx_ring->desc = dma_alloc_coherent(dev, rx_ring->size,
+						   &rx_ring->dma, GFP_KERNEL);
 	if (!rx_ring->desc)
 		goto err;
 
-- 
1.7.7.6
