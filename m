From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [next PATCH 11/11] ixgbe: Don't bother clearing buffer memory for
 descriptor rings
Date: Fri, 06 Jan 2017 08:07:53 -0800
Message-ID: <20170106160751.1501.83692.stgit@localhost.localdomain>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33180 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967239AbdAFQH4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:07:56 -0500
Received: by mail-pg0-f67.google.com with SMTP id g1so44421102pgn.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 08:07:55 -0800 (PST)
In-Reply-To: <20170106155448.1501.31298.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes it so that we don't need to bother with clearing the
memory out for the descriptor rings.  The general idea is to only free
buffers associated with buffers in use which are located between the
next_to_clean and next_to_use or next_to_alloc values.  Everything outside
of those regions can be safely ignored since they should have no buffers
associated with them.

The advantage to doing things this way is that is should speed up bring-up
and tear-down of the rings.  Specifically we can avoid the 512 or more
cycles required to memset the rings in tear-down.  In the bring-up phase we
then clear the memory as a part of initialization.  The general idea is
that the clearing in initialization can act as a prefetch of sorts for the
buffer info structures so they are in the local CPU when we go to populate
them.  This should help to improve overall time needed to perform a
suspend/resume.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  158 ++++++++++++----------
 2 files changed, 98 insertions(+), 71 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 6466d828bc6f..8c6f40d4db6f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1945,7 +1945,16 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 
 		/* unmap buffer on Tx side */
 		tx_buffer = &tx_ring->tx_buffer_info[tx_ntc];
-		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer);
+
+		/* Free all the Tx ring sk_buffs */
+		dev_kfree_skb_any(tx_buffer->skb);
+
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
+		dma_unmap_len_set(tx_buffer, len, 0);
 
 		/* increment Rx/Tx next to clean counters */
 		rx_ntc++;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index dd04b76ae0bd..6ec0ebf7f174 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -958,28 +958,6 @@ static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
 	}
 }
 
-void ixgbe_unmap_and_free_tx_resource(struct ixgbe_ring *ring,
-				      struct ixgbe_tx_buffer *tx_buffer)
-{
-	if (tx_buffer->skb) {
-		dev_kfree_skb_any(tx_buffer->skb);
-		if (dma_unmap_len(tx_buffer, len))
-			dma_unmap_single(ring->dev,
-					 dma_unmap_addr(tx_buffer, dma),
-					 dma_unmap_len(tx_buffer, len),
-					 DMA_TO_DEVICE);
-	} else if (dma_unmap_len(tx_buffer, len)) {
-		dma_unmap_page(ring->dev,
-			       dma_unmap_addr(tx_buffer, dma),
-			       dma_unmap_len(tx_buffer, len),
-			       DMA_TO_DEVICE);
-	}
-	tx_buffer->next_to_watch = NULL;
-	tx_buffer->skb = NULL;
-	dma_unmap_len_set(tx_buffer, len, 0);
-	/* tx_buffer must be completely set up in the transmit path */
-}
-
 static void ixgbe_update_xoff_rx_lfc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1211,7 +1189,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 				 DMA_TO_DEVICE);
 
 		/* clear tx_buffer data */
-		tx_buffer->skb = NULL;
 		dma_unmap_len_set(tx_buffer, len, 0);
 
 		/* unmap remaining buffers */
@@ -3345,6 +3322,10 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 
 	clear_bit(__IXGBE_HANG_CHECK_ARMED, &ring->state);
 
+	/* reinitialize tx_buffer_info */
+	memset(ring->tx_buffer_info, 0,
+	       sizeof(struct ixgbe_tx_buffer) * ring->count);
+
 	/* enable queue */
 	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), txdctl);
 
@@ -3865,6 +3846,10 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 #endif
 	}
 
+	/* initialize rx_buffer_info */
+	memset(ring->rx_buffer_info, 0,
+	       sizeof(struct ixgbe_rx_buffer) * ring->count);
+
 	/* initialize Rx descriptor 0 */
 	rx_desc = IXGBE_RX_DESC(ring, 0);
 	rx_desc->wb.upper.length = 0;
@@ -5049,33 +5034,22 @@ static void ixgbe_fwd_psrtype(struct ixgbe_fwd_adapter *vadapter)
  **/
 static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 {
-	struct device *dev = rx_ring->dev;
-	unsigned long size;
-	u16 i;
-
-	/* ring already cleared, nothing to do */
-	if (!rx_ring->rx_buffer_info)
-		return;
+	u16 i = rx_ring->next_to_clean;
+	struct ixgbe_rx_buffer *rx_buffer = &rx_ring->rx_buffer_info[i];
 
 	/* Free all the Rx ring sk_buffs */
-	for (i = 0; i < rx_ring->count; i++) {
-		struct ixgbe_rx_buffer *rx_buffer = &rx_ring->rx_buffer_info[i];
-
+	while (i != rx_ring->next_to_alloc) {
 		if (rx_buffer->skb) {
 			struct sk_buff *skb = rx_buffer->skb;
 			if (IXGBE_CB(skb)->page_released)
-				dma_unmap_page_attrs(dev,
+				dma_unmap_page_attrs(rx_ring->dev,
 						     IXGBE_CB(skb)->dma,
 						     ixgbe_rx_pg_size(rx_ring),
 						     DMA_FROM_DEVICE,
 						     IXGBE_RX_DMA_ATTR);
 			dev_kfree_skb(skb);
-			rx_buffer->skb = NULL;
 		}
 
-		if (!rx_buffer->page)
-			continue;
-
 		/* Invalidate cache lines that may have been written to by
 		 * device so that we avoid corrupting memory.
 		 */
@@ -5086,19 +5060,21 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 					      DMA_FROM_DEVICE);
 
 		/* free resources associated with mapping */
-		dma_unmap_page_attrs(dev, rx_buffer->dma,
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
 				     ixgbe_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE,
 				     IXGBE_RX_DMA_ATTR);
 		__page_frag_cache_drain(rx_buffer->page,
 					rx_buffer->pagecnt_bias);
 
-		rx_buffer->page = NULL;
+		i++;
+		rx_buffer++;
+		if (i == rx_ring->count) {
+			i = 0;
+			rx_buffer = rx_ring->rx_buffer_info;
+		}
 	}
 
-	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	memset(rx_ring->rx_buffer_info, 0, size);
-
 	rx_ring->next_to_alloc = 0;
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
@@ -5567,28 +5543,57 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_clean_tx_ring(struct ixgbe_ring *tx_ring)
 {
-	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned long size;
-	u16 i;
+	u16 i = tx_ring->next_to_clean;
+	struct ixgbe_tx_buffer *tx_buffer = &tx_ring->tx_buffer_info[i];
 
-	/* ring already cleared, nothing to do */
-	if (!tx_ring->tx_buffer_info)
-		return;
+	while (i != tx_ring->next_to_use) {
+		union ixgbe_adv_tx_desc *eop_desc, *tx_desc;
 
-	/* Free all the Tx ring sk_buffs */
-	for (i = 0; i < tx_ring->count; i++) {
-		tx_buffer_info = &tx_ring->tx_buffer_info[i];
-		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
-	}
+		/* Free all the Tx ring sk_buffs */
+		dev_kfree_skb_any(tx_buffer->skb);
 
-	netdev_tx_reset_queue(txring_txq(tx_ring));
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
 
-	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
-	memset(tx_ring->tx_buffer_info, 0, size);
+		/* check for eop_desc to determine the end of the packet */
+		eop_desc = tx_buffer->next_to_watch;
+		tx_desc = IXGBE_TX_DESC(tx_ring, i);
 
-	/* Zero out the descriptor ring */
-	memset(tx_ring->desc, 0, tx_ring->size);
+		/* unmap remaining buffers */
+		while (tx_desc != eop_desc) {
+			tx_buffer++;
+			tx_desc++;
+			i++;
+			if (unlikely(i == tx_ring->count)) {
+				i = 0;
+				tx_buffer = tx_ring->tx_buffer_info;
+				tx_desc = IXGBE_TX_DESC(tx_ring, 0);
+			}
+
+			/* unmap any remaining paged data */
+			if (dma_unmap_len(tx_buffer, len))
+				dma_unmap_page(tx_ring->dev,
+					       dma_unmap_addr(tx_buffer, dma),
+					       dma_unmap_len(tx_buffer, len),
+					       DMA_TO_DEVICE);
+		}
 
+		/* move us one more past the eop_desc for start of next pkt */
+		tx_buffer++;
+		i++;
+		if (unlikely(i == tx_ring->count)) {
+			i = 0;
+			tx_buffer = tx_ring->tx_buffer_info;
+		}
+	}
+
+	/* reset BQL for queue */
+	netdev_tx_reset_queue(txring_txq(tx_ring));
+
+	/* reset next_to_use and next_to_clean */
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 }
@@ -6034,9 +6039,9 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 	if (tx_ring->q_vector)
 		ring_node = tx_ring->q_vector->numa_node;
 
-	tx_ring->tx_buffer_info = vzalloc_node(size, ring_node);
+	tx_ring->tx_buffer_info = vmalloc_node(size, ring_node);
 	if (!tx_ring->tx_buffer_info)
-		tx_ring->tx_buffer_info = vzalloc(size);
+		tx_ring->tx_buffer_info = vmalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 
@@ -6116,9 +6121,9 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	if (rx_ring->q_vector)
 		ring_node = rx_ring->q_vector->numa_node;
 
-	rx_ring->rx_buffer_info = vzalloc_node(size, ring_node);
+	rx_ring->rx_buffer_info = vmalloc_node(size, ring_node);
 	if (!rx_ring->rx_buffer_info)
-		rx_ring->rx_buffer_info = vzalloc(size);
+		rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info)
 		goto err;
 
@@ -7836,16 +7841,29 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
 
 	/* clear dma mappings for failed tx_buffer_info map */
-	for (;;) {
+	while (tx_buffer != first) {
+		if (dma_unmap_len(tx_buffer, len))
+			dma_unmap_page(tx_ring->dev,
+				       dma_unmap_addr(tx_buffer, dma),
+				       dma_unmap_len(tx_buffer, len),
+				       DMA_TO_DEVICE);
+		dma_unmap_len_set(tx_buffer, len, 0);
+
+		if (i--)
+			i += tx_ring->count;
 		tx_buffer = &tx_ring->tx_buffer_info[i];
-		ixgbe_unmap_and_free_tx_resource(tx_ring, tx_buffer);
-		if (tx_buffer == first)
-			break;
-		if (i == 0)
-			i = tx_ring->count;
-		i--;
 	}
 
+	if (dma_unmap_len(tx_buffer, len))
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
+	dma_unmap_len_set(tx_buffer, len, 0);
+
+	dev_kfree_skb_any(first->skb);
+	first->skb = NULL;
+
 	tx_ring->next_to_use = i;
 }
 
