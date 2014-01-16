From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 4/6] ixgbevf: Convert ring storage form pointer to an array to array of pointers
Date: Thu, 16 Jan 2014 02:30:08 -0800
Message-ID: <1389868210-24035-5-git-send-email-aaron.f.brown@intel.com>
References: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388AbaAPKag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:30:36 -0500
In-Reply-To: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This will change how we store rings arrays in the adapter sturct.
We use to have a pointer to an array now we will be using an array
of pointers.  This will allow us to support multiple queues on
muliple nodes at some point we would be able to reallocate the rings
so that each is on a local node if needed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  30 ++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 150 ++++++++++++----------
 3 files changed, 98 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 54d9ace..515ba4e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -286,9 +286,9 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 
 	if (!netif_running(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].count = new_tx_count;
+			adapter->tx_ring[i]->count = new_tx_count;
 		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].count = new_rx_count;
+			adapter->rx_ring[i]->count = new_rx_count;
 		adapter->tx_ring_count = new_tx_count;
 		adapter->rx_ring_count = new_rx_count;
 		goto clear_reset;
@@ -303,7 +303,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 
 		for (i = 0; i < adapter->num_tx_queues; i++) {
 			/* clone ring and setup updated count */
-			tx_ring[i] = adapter->tx_ring[i];
+			tx_ring[i] = *adapter->tx_ring[i];
 			tx_ring[i].count = new_tx_count;
 			err = ixgbevf_setup_tx_resources(adapter, &tx_ring[i]);
 			if (!err)
@@ -329,7 +329,7 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			/* clone ring and setup updated count */
-			rx_ring[i] = adapter->rx_ring[i];
+			rx_ring[i] = *adapter->rx_ring[i];
 			rx_ring[i].count = new_rx_count;
 			err = ixgbevf_setup_rx_resources(adapter, &rx_ring[i]);
 			if (!err)
@@ -352,9 +352,8 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 	/* Tx */
 	if (tx_ring) {
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			ixgbevf_free_tx_resources(adapter,
-						  &adapter->tx_ring[i]);
-			adapter->tx_ring[i] = tx_ring[i];
+			ixgbevf_free_tx_resources(adapter, adapter->tx_ring[i]);
+			*adapter->tx_ring[i] = tx_ring[i];
 		}
 		adapter->tx_ring_count = new_tx_count;
 
@@ -365,9 +364,8 @@ static int ixgbevf_set_ringparam(struct net_device *netdev,
 	/* Rx */
 	if (rx_ring) {
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			ixgbevf_free_rx_resources(adapter,
-						  &adapter->rx_ring[i]);
-			adapter->rx_ring[i] = rx_ring[i];
+			ixgbevf_free_rx_resources(adapter, adapter->rx_ring[i]);
+			*adapter->rx_ring[i] = rx_ring[i];
 		}
 		adapter->rx_ring_count = new_rx_count;
 
@@ -413,15 +411,15 @@ static void ixgbevf_get_ethtool_stats(struct net_device *netdev,
 	    tx_yields = 0, tx_cleaned = 0, tx_missed = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rx_yields += adapter->rx_ring[i].bp_yields;
-		rx_cleaned += adapter->rx_ring[i].bp_cleaned;
-		rx_yields += adapter->rx_ring[i].bp_yields;
+		rx_yields += adapter->rx_ring[i]->bp_yields;
+		rx_cleaned += adapter->rx_ring[i]->bp_cleaned;
+		rx_yields += adapter->rx_ring[i]->bp_yields;
 	}
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		tx_yields += adapter->tx_ring[i].bp_yields;
-		tx_cleaned += adapter->tx_ring[i].bp_cleaned;
-		tx_yields += adapter->tx_ring[i].bp_yields;
+		tx_yields += adapter->tx_ring[i]->bp_yields;
+		tx_cleaned += adapter->tx_ring[i]->bp_cleaned;
+		tx_yields += adapter->tx_ring[i]->bp_yields;
 	}
 
 	adapter->bp_rx_yields = rx_yields;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index d7cec1d..0547e40 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -327,7 +327,7 @@ struct ixgbevf_adapter {
 	u32 eims_other;
 
 	/* TX */
-	struct ixgbevf_ring *tx_ring;	/* One per active queue */
+	struct ixgbevf_ring *tx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	int num_tx_queues;
 	u64 restart_queue;
 	u64 hw_csum_tx_good;
@@ -337,7 +337,7 @@ struct ixgbevf_adapter {
 	u32 tx_timeout_count;
 
 	/* RX */
-	struct ixgbevf_ring *rx_ring;	/* One per active queue */
+	struct ixgbevf_ring *rx_ring[MAX_TX_QUEUES]; /* One per active queue */
 	int num_rx_queues;
 	u64 hw_csum_rx_error;
 	u64 hw_rx_no_dma_resources;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 74af295..202fc47 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -848,8 +848,8 @@ static inline void map_vector_to_rxq(struct ixgbevf_adapter *a, int v_idx,
 {
 	struct ixgbevf_q_vector *q_vector = a->q_vector[v_idx];
 
-	a->rx_ring[r_idx].next = q_vector->rx.ring;
-	q_vector->rx.ring = &a->rx_ring[r_idx];
+	a->rx_ring[r_idx]->next = q_vector->rx.ring;
+	q_vector->rx.ring = a->rx_ring[r_idx];
 	q_vector->rx.count++;
 }
 
@@ -858,8 +858,8 @@ static inline void map_vector_to_txq(struct ixgbevf_adapter *a, int v_idx,
 {
 	struct ixgbevf_q_vector *q_vector = a->q_vector[v_idx];
 
-	a->tx_ring[t_idx].next = q_vector->tx.ring;
-	q_vector->tx.ring = &a->tx_ring[t_idx];
+	a->tx_ring[t_idx]->next = q_vector->tx.ring;
+	q_vector->tx.ring = a->tx_ring[t_idx];
 	q_vector->tx.count++;
 }
 
@@ -1100,7 +1100,7 @@ static void ixgbevf_configure_tx(struct ixgbevf_adapter *adapter)
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct ixgbevf_ring *ring = &adapter->tx_ring[i];
+		struct ixgbevf_ring *ring = adapter->tx_ring[i];
 		j = ring->reg_idx;
 		tdba = ring->dma;
 		tdlen = ring->count * sizeof(union ixgbe_adv_tx_desc);
@@ -1130,7 +1130,7 @@ static void ixgbevf_configure_srrctl(struct ixgbevf_adapter *adapter, int index)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 srrctl;
 
-	rx_ring = &adapter->rx_ring[index];
+	rx_ring = adapter->rx_ring[index];
 
 	srrctl = IXGBE_SRRCTL_DROP_EN;
 
@@ -1188,7 +1188,7 @@ static void ixgbevf_set_rx_buffer_len(struct ixgbevf_adapter *adapter)
 		rx_buf_len = IXGBEVF_RXBUFFER_10K;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
+		adapter->rx_ring[i]->rx_buf_len = rx_buf_len;
 }
 
 /**
@@ -1212,7 +1212,7 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbevf_ring *ring = &adapter->rx_ring[i];
+		struct ixgbevf_ring *ring = adapter->rx_ring[i];
 		rdba = ring->dma;
 		j = ring->reg_idx;
 		rdlen = ring->count * sizeof(union ixgbe_adv_rx_desc);
@@ -1389,7 +1389,7 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
 
 	if (num_tcs > 1) {
 		/* update default Tx ring register index */
-		adapter->tx_ring[0].reg_idx = def_q;
+		adapter->tx_ring[0]->reg_idx = def_q;
 
 		/* we need as many queues as traffic classes */
 		num_rx_queues = num_tcs;
@@ -1421,7 +1421,7 @@ static void ixgbevf_configure(struct ixgbevf_adapter *adapter)
 	ixgbevf_configure_tx(adapter);
 	ixgbevf_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbevf_ring *ring = &adapter->rx_ring[i];
+		struct ixgbevf_ring *ring = adapter->rx_ring[i];
 		ixgbevf_alloc_rx_buffers(adapter, ring,
 					 ixgbevf_desc_unused(ring));
 	}
@@ -1429,24 +1429,23 @@ static void ixgbevf_configure(struct ixgbevf_adapter *adapter)
 
 #define IXGBEVF_MAX_RX_DESC_POLL 10
 static void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
-					 int rxr)
+					 struct ixgbevf_ring *ring)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int wait_loop = IXGBEVF_MAX_RX_DESC_POLL;
 	u32 rxdctl;
-	int j = adapter->rx_ring[rxr].reg_idx;
+	u8 reg_idx = ring->reg_idx;
 
 	do {
 		usleep_range(1000, 2000);
-		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
+		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(reg_idx));
 	} while (--wait_loop && !(rxdctl & IXGBE_RXDCTL_ENABLE));
 
 	if (!wait_loop)
 		hw_dbg(hw, "RXDCTL.ENABLE queue %d not set while polling\n",
-		       rxr);
+		       reg_idx);
 
-	ixgbevf_release_rx_desc(&adapter->rx_ring[rxr],
-				(adapter->rx_ring[rxr].count - 1));
+	ixgbevf_release_rx_desc(ring, ring->count - 1);
 }
 
 static void ixgbevf_disable_rx_queue(struct ixgbevf_adapter *adapter,
@@ -1541,7 +1540,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	u32 txdctl, rxdctl;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_VFTXDCTL(j));
 		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
 		txdctl |= (8 << 16);
@@ -1549,14 +1548,14 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	}
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_VFTXDCTL(j));
 		txdctl |= IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_VFTXDCTL(j), txdctl);
 	}
 
 	for (i = 0; i < num_rx_rings; i++) {
-		j = adapter->rx_ring[i].reg_idx;
+		j = adapter->rx_ring[i]->reg_idx;
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
 		rxdctl |= IXGBE_RXDCTL_ENABLE | IXGBE_RXDCTL_VME;
 		if (hw->mac.type == ixgbe_mac_X540_vf) {
@@ -1565,7 +1564,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 				   IXGBE_RXDCTL_RLPML_EN);
 		}
 		IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(j), rxdctl);
-		ixgbevf_rx_desc_queue_enable(adapter, i);
+		ixgbevf_rx_desc_queue_enable(adapter, adapter->rx_ring[i]);
 	}
 
 	ixgbevf_configure_msix(adapter);
@@ -1686,7 +1685,7 @@ static void ixgbevf_clean_all_rx_rings(struct ixgbevf_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbevf_clean_rx_ring(adapter, &adapter->rx_ring[i]);
+		ixgbevf_clean_rx_ring(adapter, adapter->rx_ring[i]);
 }
 
 /**
@@ -1698,7 +1697,7 @@ static void ixgbevf_clean_all_tx_rings(struct ixgbevf_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbevf_clean_tx_ring(adapter, &adapter->tx_ring[i]);
+		ixgbevf_clean_tx_ring(adapter, adapter->tx_ring[i]);
 }
 
 void ixgbevf_down(struct ixgbevf_adapter *adapter)
@@ -1713,7 +1712,7 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 
 	/* disable all enabled rx queues */
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbevf_disable_rx_queue(adapter, &adapter->rx_ring[i]);
+		ixgbevf_disable_rx_queue(adapter, adapter->rx_ring[i]);
 
 	netif_tx_disable(netdev);
 
@@ -1734,7 +1733,7 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_VFTXDCTL(j));
 		IXGBE_WRITE_REG(hw, IXGBE_VFTXDCTL(j),
 				(txdctl & ~IXGBE_TXDCTL_ENABLE));
@@ -1875,40 +1874,50 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
  **/
 static int ixgbevf_alloc_queues(struct ixgbevf_adapter *adapter)
 {
-	int i;
+	struct ixgbevf_ring *ring;
+	int rx = 0, tx = 0;
 
-	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
-				   sizeof(struct ixgbevf_ring), GFP_KERNEL);
-	if (!adapter->tx_ring)
-		goto err_tx_ring_allocation;
+	for (; tx < adapter->num_tx_queues; tx++) {
+		ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+		if (!ring)
+			goto err_allocation;
 
-	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
-				   sizeof(struct ixgbevf_ring), GFP_KERNEL);
-	if (!adapter->rx_ring)
-		goto err_rx_ring_allocation;
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+		ring->count = adapter->tx_ring_count;
+		ring->queue_index = tx;
+		ring->reg_idx = tx;
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i].count = adapter->tx_ring_count;
-		adapter->tx_ring[i].queue_index = i;
-		/* reg_idx may be remapped later by DCB config */
-		adapter->tx_ring[i].reg_idx = i;
-		adapter->tx_ring[i].dev = &adapter->pdev->dev;
-		adapter->tx_ring[i].netdev = adapter->netdev;
+		adapter->tx_ring[tx] = ring;
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i].count = adapter->rx_ring_count;
-		adapter->rx_ring[i].queue_index = i;
-		adapter->rx_ring[i].reg_idx = i;
-		adapter->rx_ring[i].dev = &adapter->pdev->dev;
-		adapter->rx_ring[i].netdev = adapter->netdev;
+	for (; rx < adapter->num_rx_queues; rx++) {
+		ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+		if (!ring)
+			goto err_allocation;
+
+		ring->dev = &adapter->pdev->dev;
+		ring->netdev = adapter->netdev;
+
+		ring->count = adapter->rx_ring_count;
+		ring->queue_index = rx;
+		ring->reg_idx = rx;
+
+		adapter->rx_ring[rx] = ring;
 	}
 
 	return 0;
 
-err_rx_ring_allocation:
-	kfree(adapter->tx_ring);
-err_tx_ring_allocation:
+err_allocation:
+	while (tx) {
+		kfree(adapter->tx_ring[--tx]);
+		adapter->tx_ring[tx] = NULL;
+	}
+
+	while (rx) {
+		kfree(adapter->rx_ring[--rx]);
+		adapter->rx_ring[rx] = NULL;
+	}
 	return -ENOMEM;
 }
 
@@ -2099,6 +2108,17 @@ err_set_interrupt:
  **/
 static void ixgbevf_clear_interrupt_scheme(struct ixgbevf_adapter *adapter)
 {
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		kfree(adapter->tx_ring[i]);
+		adapter->tx_ring[i] = NULL;
+	}
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		kfree(adapter->rx_ring[i]);
+		adapter->rx_ring[i] = NULL;
+	}
+
 	adapter->num_tx_queues = 0;
 	adapter->num_rx_queues = 0;
 
@@ -2229,11 +2249,11 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 
 	for (i = 0;  i  < adapter->num_rx_queues;  i++) {
 		adapter->hw_csum_rx_error +=
-			adapter->rx_ring[i].hw_csum_rx_error;
+			adapter->rx_ring[i]->hw_csum_rx_error;
 		adapter->hw_csum_rx_good +=
-			adapter->rx_ring[i].hw_csum_rx_good;
-		adapter->rx_ring[i].hw_csum_rx_error = 0;
-		adapter->rx_ring[i].hw_csum_rx_good = 0;
+			adapter->rx_ring[i]->hw_csum_rx_good;
+		adapter->rx_ring[i]->hw_csum_rx_error = 0;
+		adapter->rx_ring[i]->hw_csum_rx_good = 0;
 	}
 }
 
@@ -2413,10 +2433,8 @@ static void ixgbevf_free_all_tx_resources(struct ixgbevf_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		if (adapter->tx_ring[i].desc)
-			ixgbevf_free_tx_resources(adapter,
-						  &adapter->tx_ring[i]);
-
+		if (adapter->tx_ring[i]->desc)
+			ixgbevf_free_tx_resources(adapter, adapter->tx_ring[i]);
 }
 
 /**
@@ -2471,7 +2489,7 @@ static int ixgbevf_setup_all_tx_resources(struct ixgbevf_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		err = ixgbevf_setup_tx_resources(adapter, &adapter->tx_ring[i]);
+		err = ixgbevf_setup_tx_resources(adapter, adapter->tx_ring[i]);
 		if (!err)
 			continue;
 		hw_dbg(&adapter->hw,
@@ -2533,7 +2551,7 @@ static int ixgbevf_setup_all_rx_resources(struct ixgbevf_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = ixgbevf_setup_rx_resources(adapter, &adapter->rx_ring[i]);
+		err = ixgbevf_setup_rx_resources(adapter, adapter->rx_ring[i]);
 		if (!err)
 			continue;
 		hw_dbg(&adapter->hw,
@@ -2577,9 +2595,8 @@ static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		if (adapter->rx_ring[i].desc)
-			ixgbevf_free_rx_resources(adapter,
-						  &adapter->rx_ring[i]);
+		if (adapter->rx_ring[i]->desc)
+			ixgbevf_free_rx_resources(adapter, adapter->rx_ring[i]);
 }
 
 /**
@@ -3069,7 +3086,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	tx_ring = &adapter->tx_ring[r_idx];
+	tx_ring = adapter->tx_ring[r_idx];
 
 	/*
 	 * need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
@@ -3282,7 +3299,7 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	stats->multicast = adapter->stats.vfmprc - adapter->stats.base_vfmprc;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		ring = &adapter->rx_ring[i];
+		ring = adapter->rx_ring[i];
 		do {
 			start = u64_stats_fetch_begin_bh(&ring->syncp);
 			bytes = ring->total_bytes;
@@ -3293,7 +3310,7 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 	}
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		ring = &adapter->tx_ring[i];
+		ring = adapter->tx_ring[i];
 		do {
 			start = u64_stats_fetch_begin_bh(&ring->syncp);
 			bytes = ring->total_bytes;
@@ -3528,9 +3545,6 @@ static void ixgbevf_remove(struct pci_dev *pdev)
 
 	hw_dbg(&adapter->hw, "Remove complete\n");
 
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-
 	free_netdev(netdev);
 
 	pci_disable_device(pdev);
-- 
1.8.5.GIT
