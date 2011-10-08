From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/11] igb: Use node specific allocations for the q_vectors and rings
Date: Fri,  7 Oct 2011 23:47:32 -0700
Message-ID: <1318056461-19562-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6789 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751383Ab1JHGrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 02:47:45 -0400
In-Reply-To: <1318056461-19562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to update the ring and vector allocations so that they
are per node instead of allocating everything on the node that
ifconfig/modprobe is called on.  By doing this we can cut down
significantly on cross node traffic.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    4 ++
 drivers/net/ethernet/intel/igb/igb_main.c |   80 +++++++++++++++++++++++++++--
 2 files changed, 79 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index de35c02..9e4bed3 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -185,6 +185,8 @@ struct igb_q_vector {
 	u16 cpu;
 	u16 tx_work_limit;
 
+	int numa_node;
+
 	u16 itr_val;
 	u8 set_itr;
 	void __iomem *itr_register;
@@ -232,6 +234,7 @@ struct igb_ring {
 	};
 	/* Items past this point are only used during ring alloc / free */
 	dma_addr_t dma;                /* phys address of the ring */
+	int numa_node;                  /* node to alloc ring memory on */
 };
 
 #define IGB_RING_FLAG_RX_CSUM        0x00000001 /* RX CSUM enabled */
@@ -341,6 +344,7 @@ struct igb_adapter {
 	int vf_rate_link_speed;
 	u32 rss_queues;
 	u32 wvbr;
+	int node;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1c234f0..287be85 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -687,41 +687,68 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 {
 	struct igb_ring *ring;
 	int i;
+	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
+		ring = kzalloc_node(sizeof(struct igb_ring), GFP_KERNEL,
+				    adapter->node);
+		if (!ring)
+			ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
 		if (!ring)
 			goto err;
 		ring->count = adapter->tx_ring_count;
 		ring->queue_index = i;
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
+		ring->numa_node = adapter->node;
 		/* For 82575, context index must be unique per ring. */
 		if (adapter->hw.mac.type == e1000_82575)
 			ring->flags = IGB_RING_FLAG_TX_CTX_IDX;
 		adapter->tx_ring[i] = ring;
 	}
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
+		ring = kzalloc_node(sizeof(struct igb_ring), GFP_KERNEL,
+				    adapter->node);
+		if (!ring)
+			ring = kzalloc(sizeof(struct igb_ring), GFP_KERNEL);
 		if (!ring)
 			goto err;
 		ring->count = adapter->rx_ring_count;
 		ring->queue_index = i;
 		ring->dev = &adapter->pdev->dev;
 		ring->netdev = adapter->netdev;
+		ring->numa_node = adapter->node;
 		ring->flags = IGB_RING_FLAG_RX_CSUM; /* enable rx checksum */
 		/* set flag indicating ring supports SCTP checksum offload */
 		if (adapter->hw.mac.type >= e1000_82576)
 			ring->flags |= IGB_RING_FLAG_RX_SCTP_CSUM;
 		adapter->rx_ring[i] = ring;
 	}
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
 
 	igb_cache_ring_register(adapter);
 
 	return 0;
 
 err:
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
 	igb_free_queues(adapter);
 
 	return -ENOMEM;
@@ -1087,9 +1114,24 @@ static int igb_alloc_q_vectors(struct igb_adapter *adapter)
 	struct igb_q_vector *q_vector;
 	struct e1000_hw *hw = &adapter->hw;
 	int v_idx;
+	int orig_node = adapter->node;
 
 	for (v_idx = 0; v_idx < adapter->num_q_vectors; v_idx++) {
-		q_vector = kzalloc(sizeof(struct igb_q_vector), GFP_KERNEL);
+		if ((adapter->num_q_vectors == (adapter->num_rx_queues +
+						adapter->num_tx_queues)) &&
+		    (adapter->num_rx_queues == v_idx))
+			adapter->node = orig_node;
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
+		q_vector = kzalloc_node(sizeof(struct igb_q_vector), GFP_KERNEL,
+					adapter->node);
+		if (!q_vector)
+			q_vector = kzalloc(sizeof(struct igb_q_vector),
+					   GFP_KERNEL);
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
@@ -1098,9 +1140,14 @@ static int igb_alloc_q_vectors(struct igb_adapter *adapter)
 		netif_napi_add(adapter->netdev, &q_vector->napi, igb_poll, 64);
 		adapter->q_vector[v_idx] = q_vector;
 	}
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
+
 	return 0;
 
 err_out:
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
 	igb_free_q_vectors(adapter);
 	return -ENOMEM;
 }
@@ -2409,6 +2456,8 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 				  VLAN_HLEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
+	adapter->node = -1;
+
 	spin_lock_init(&adapter->stats64_lock);
 #ifdef CONFIG_PCI_IOV
 	switch (hw->mac.type) {
@@ -2579,10 +2628,13 @@ static int igb_close(struct net_device *netdev)
 int igb_setup_tx_resources(struct igb_ring *tx_ring)
 {
 	struct device *dev = tx_ring->dev;
+	int orig_node = dev_to_node(dev);
 	int size;
 
 	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vzalloc(size);
+	tx_ring->tx_buffer_info = vzalloc_node(size, tx_ring->numa_node);
+	if (!tx_ring->tx_buffer_info)
+		tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 
@@ -2590,16 +2642,24 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
+	set_dev_node(dev, tx_ring->numa_node);
 	tx_ring->desc = dma_alloc_coherent(dev,
 					   tx_ring->size,
 					   &tx_ring->dma,
 					   GFP_KERNEL);
+	set_dev_node(dev, orig_node);
+	if (!tx_ring->desc)
+		tx_ring->desc = dma_alloc_coherent(dev,
+						   tx_ring->size,
+						   &tx_ring->dma,
+						   GFP_KERNEL);
 
 	if (!tx_ring->desc)
 		goto err;
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
+
 	return 0;
 
 err:
@@ -2722,10 +2782,13 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 int igb_setup_rx_resources(struct igb_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
+	int orig_node = dev_to_node(dev);
 	int size, desc_len;
 
 	size = sizeof(struct igb_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vzalloc(size);
+	rx_ring->rx_buffer_info = vzalloc_node(size, rx_ring->numa_node);
+	if (!rx_ring->rx_buffer_info)
+		rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info)
 		goto err;
 
@@ -2735,10 +2798,17 @@ int igb_setup_rx_resources(struct igb_ring *rx_ring)
 	rx_ring->size = rx_ring->count * desc_len;
 	rx_ring->size = ALIGN(rx_ring->size, 4096);
 
+	set_dev_node(dev, rx_ring->numa_node);
 	rx_ring->desc = dma_alloc_coherent(dev,
 					   rx_ring->size,
 					   &rx_ring->dma,
 					   GFP_KERNEL);
+	set_dev_node(dev, orig_node);
+	if (!rx_ring->desc)
+		rx_ring->desc = dma_alloc_coherent(dev,
+						   rx_ring->size,
+						   &rx_ring->dma,
+						   GFP_KERNEL);
 
 	if (!rx_ring->desc)
 		goto err;
-- 
1.7.6.4
