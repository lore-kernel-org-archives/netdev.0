From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/7] igb: Remove logic that was doing NUMA pseudo-aware allocations
Date: Sat, 22 Sep 2012 03:30:32 -0700
Message-ID: <1348309836-7107-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8125 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755298Ab2IVKbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 06:31:06 -0400
In-Reply-To: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes the code that was doing the NUMA allocations for the
q_vectors, rings, and ring resources.  The problem is the logic used assumed
that the NUMA nodes were always interleved and that is not always the case.

At some point I hope to add this functionality back in a more controlled
manner in the future.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |  3 -
 drivers/net/ethernet/intel/igb/igb_main.c | 95 +++++--------------------------
 2 files changed, 13 insertions(+), 85 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 6f17f69..9cad058 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -213,7 +213,6 @@ struct igb_q_vector {
 	struct igb_ring_container rx, tx;
 
 	struct napi_struct napi;
-	int numa_node;
 
 	u16 itr_val;
 	u8 set_itr;
@@ -258,7 +257,6 @@ struct igb_ring {
 	};
 	/* Items past this point are only used during ring alloc / free */
 	dma_addr_t dma;                /* phys address of the ring */
-	int numa_node;                  /* node to alloc ring memory on */
 };
 
 enum e1000_ring_flags_t {
@@ -373,7 +371,6 @@ struct igb_adapter {
 	int vf_rate_link_speed;
 	u32 rss_queues;
 	u32 wvbr;
-	int node;
 	u32 *shadow_vfta;
 
 #ifdef CONFIG_IGB_PTP
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 60cf3eb..c9997d8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -682,52 +682,29 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 {
 	struct igb_ring *ring;
 	int i;
-	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		ring = kzalloc_node(sizeof(struct igb_ring), GFP_KERNEL,
-				    adapter->node);
-		if (!ring)
-			ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
+		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
 		if (!ring)
 			goto err;
 		ring->count = adapter->tx_ring_count;
 		ring->queue_index = i;
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
-		ring->numa_node = adapter->node;
 		/* For 82575, context index must be unique per ring. */
 		if (adapter->hw.mac.type == e1000_82575)
 			set_bit(IGB_RING_FLAG_TX_CTX_IDX, &ring->flags);
 		adapter->tx_ring[i] = ring;
 	}
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		ring = kzalloc_node(sizeof(struct igb_ring), GFP_KERNEL,
-				    adapter->node);
-		if (!ring)
-			ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
+		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
 		if (!ring)
 			goto err;
 		ring->count = adapter->rx_ring_count;
 		ring->queue_index = i;
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
-		ring->numa_node = adapter->node;
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
 			set_bit(IGB_RING_FLAG_RX_SCTP_CSUM, &ring->flags);
@@ -741,16 +718,12 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 
 		adapter->rx_ring[i] = ring;
 	}
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
 
 	igb_cache_ring_register(adapter);
 
 	return 0;
 
 err:
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
 	igb_free_queues(adapter);
 
 	return -ENOMEM;
@@ -1116,24 +1089,10 @@ static int igb_alloc_q_vectors(struct igb_adapter *adapter)
 	struct igb_q_vector *q_vector;
 	struct e1000_hw *hw = &adapter->hw;
 	int v_idx;
-	int orig_node = adapter->node;
 
 	for (v_idx = 0; v_idx < adapter->num_q_vectors; v_idx++) {
-		if ((adapter->num_q_vectors == (adapter->num_rx_queues +
-						adapter->num_tx_queues)) &&
-		    (adapter->num_rx_queues == v_idx))
-			adapter->node = orig_node;
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		q_vector = kzalloc_node(sizeof(struct igb_q_vector), GFP_KERNEL,
-					adapter->node);
-		if (!q_vector)
-			q_vector = kzalloc(sizeof(struct igb_q_vector),
-					   GFP_KERNEL);
+		q_vector = kzalloc(sizeof(struct igb_q_vector),
+				   GFP_KERNEL);
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
@@ -1142,14 +1101,10 @@ static int igb_alloc_q_vectors(struct igb_adapter *adapter)
 		netif_napi_add(adapter->netdev, &q_vector->napi, igb_poll, 64);
 		adapter->q_vector[v_idx] = q_vector;
 	}
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
 
 	return 0;
 
 err_out:
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
 	igb_free_q_vectors(adapter);
 	return -ENOMEM;
 }
@@ -2423,8 +2378,6 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 				  VLAN_HLEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
-	adapter->node = -1;
-
 	spin_lock_init(&adapter->stats64_lock);
 #ifdef CONFIG_PCI_IOV
 	switch (hw->mac.type) {
@@ -2671,13 +2624,11 @@ static int igb_close(struct net_device *netdev)
 int igb_setup_tx_resources(struct igb_ring *tx_ring)
 {
 	struct device *dev = tx_ring->dev;
-	int orig_node = dev_to_node(dev);
 	int size;
 
 	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vzalloc_node(size, tx_ring->numa_node);
-	if (!tx_ring->tx_buffer_info)
-		tx_ring->tx_buffer_info = vzalloc(size);
+
+	tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 
@@ -2685,18 +2636,10 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
-	set_dev_node(dev, tx_ring->numa_node);
 	tx_ring->desc = dma_alloc_coherent(dev,
 					   tx_ring->size,
 					   &tx_ring->dma,
 					   GFP_KERNEL);
-	set_dev_node(dev, orig_node);
-	if (!tx_ring->desc)
-		tx_ring->desc = dma_alloc_coherent(dev,
-						   tx_ring->size,
-						   &tx_ring->dma,
-						   GFP_KERNEL);
-
 	if (!tx_ring->desc)
 		goto err;
 
@@ -2707,8 +2650,8 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 
 err:
 	vfree(tx_ring->tx_buffer_info);
-	dev_err(dev,
-		"Unable to allocate memory for the transmit descriptor ring\n");
+	tx_ring->tx_buffer_info = NULL;
+	dev_err(dev, "Unable to allocate memory for the Tx descriptor ring\n");
 	return -ENOMEM;
 }
 
@@ -2825,34 +2768,23 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 int igb_setup_rx_resources(struct igb_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
-	int orig_node = dev_to_node(dev);
-	int size, desc_len;
+	int size;
 
 	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vzalloc_node(size, rx_ring->numa_node);
-	if (!rx_ring->rx_buffer_info)
-		rx_ring->rx_buffer_info = vzalloc(size);
+
+	rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info)
 		goto err;
 
-	desc_len = sizeof(union e1000_adv_rx_desc);
 
 	/* Round up to nearest 4K */
-	rx_ring->size = rx_ring->count * desc_len;
+	rx_ring->size = rx_ring->count * sizeof(union e1000_adv_rx_desc);
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
-	set_dev_node(dev, rx_ring->numa_node);
 	rx_ring->desc = dma_alloc_coherent(dev,
 					   rx_ring->size,
 					   &rx_ring->dma,
 					   GFP_KERNEL);
-	set_dev_node(dev, orig_node);
-	if (!rx_ring->desc)
-		rx_ring->desc = dma_alloc_coherent(dev,
-						   rx_ring->size,
-						   &rx_ring->dma,
-						   GFP_KERNEL);
-
 	if (!rx_ring->desc)
 		goto err;
 
@@ -2864,8 +2796,7 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 err:
 	vfree(rx_ring->rx_buffer_info);
 	rx_ring->rx_buffer_info = NULL;
-	dev_err(dev, "Unable to allocate memory for the receive descriptor"
-		" ring\n");
+	dev_err(dev, "Unable to allocate memory for the Rx descriptor ring\n");
 	return -ENOMEM;
 }
 
-- 
1.7.11.4
