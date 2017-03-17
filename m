From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] igb: Don't bother clearing Tx buffer_info in igb_clean_tx_ring
Date: Fri, 17 Mar 2017 12:58:09 -0700
Message-ID: <20170317195818.74912-5-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:63132 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751096AbdCQT60 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:26 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In the case of the Tx rings we need to only clear the Tx buffer_info when
we are resetting the rings.  Ideally we do this when we configure the ring
to bring it back up instead of when we are taking it down in order to avoid
dirtying pages we don't need to.

In addition we don't need to clear the Tx descriptor ring since we will
fully repopulate it when we begin transmitting frames and next_to_watch can
be cleared to prevent the ring from being cleaned beyond that point instead
of needing to touch anything in the Tx descriptor ring.

Finally with these changes we can avoid having to reset the skb member of
the Tx buffer_info structure in the cleanup path since the skb will always
be associated with the first buffer which has next_to_watch set.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |   1 -
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  11 ++-
 drivers/net/ethernet/intel/igb/igb_main.c    | 120 ++++++++++++++++-----------
 3 files changed, 83 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 87c9fe9d6f18..a638254f4e06 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -594,7 +594,6 @@ void igb_configure_rx_ring(struct igb_adapter *, struct igb_ring *);
 void igb_setup_tctl(struct igb_adapter *);
 void igb_setup_rctl(struct igb_adapter *);
 netdev_tx_t igb_xmit_frame_ring(struct sk_buff *, struct igb_ring *);
-void igb_unmap_and_free_tx_resource(struct igb_ring *, struct igb_tx_buffer *);
 void igb_alloc_rx_buffers(struct igb_ring *, u16);
 void igb_update_stats(struct igb_adapter *, struct rtnl_link_stats64 *);
 bool igb_has_link(struct igb_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 3f5f7744c90f..612cf13b7a3a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1833,7 +1833,16 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 
 		/* unmap buffer on Tx side */
 		tx_buffer_info = &tx_ring->tx_buffer_info[tx_ntc];
-		igb_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
+
+		/* Free all the Tx ring sk_buffs */
+		dev_kfree_skb_any(tx_buffer_info->skb);
+
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer_info, dma),
+				 dma_unmap_len(tx_buffer_info, len),
+				 DMA_TO_DEVICE);
+		dma_unmap_len_set(tx_buffer_info, len, 0);
 
 		/* increment Rx/Tx next to clean counters */
 		rx_ntc++;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 680f0d3d9b72..e541cccaae1b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3293,7 +3293,7 @@ int igb_setup_tx_resources(struct igb_ring *tx_ring)
 
 	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
 
-	tx_ring->tx_buffer_info = vzalloc(size);
+	tx_ring->tx_buffer_info = vmalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 
@@ -3404,6 +3404,10 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	txdctl |= IGB_TX_HTHRESH << 8;
 	txdctl |= IGB_TX_WTHRESH << 16;
 
+	/* reinitialize tx_buffer_info */
+	memset(ring->tx_buffer_info, 0,
+	       sizeof(struct igb_tx_buffer) * ring->count);
+
 	txdctl |= E1000_TXDCTL_QUEUE_ENABLE;
 	wr32(E1000_TXDCTL(reg_idx), txdctl);
 }
@@ -3831,55 +3835,63 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 			igb_free_tx_resources(adapter->tx_ring[i]);
 }
 
-void igb_unmap_and_free_tx_resource(struct igb_ring *ring,
-				    struct igb_tx_buffer *tx_buffer)
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
-	/* buffer_info must be completely set up in the transmit path */
-}
-
 /**
  *  igb_clean_tx_ring - Free Tx Buffers
  *  @tx_ring: ring to be cleaned
  **/
 static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 {
-	struct igb_tx_buffer *buffer_info;
-	unsigned long size;
-	u16 i;
+	u16 i = tx_ring->next_to_clean;
+	struct igb_tx_buffer *tx_buffer = &tx_ring->tx_buffer_info[i];
 
-	if (!tx_ring->tx_buffer_info)
-		return;
-	/* Free all the Tx ring sk_buffs */
+	while (i != tx_ring->next_to_use) {
+		union e1000_adv_tx_desc *eop_desc, *tx_desc;
 
-	for (i = 0; i < tx_ring->count; i++) {
-		buffer_info = &tx_ring->tx_buffer_info[i];
-		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
-	}
+		/* Free all the Tx ring sk_buffs */
+		dev_kfree_skb_any(tx_buffer->skb);
 
-	netdev_tx_reset_queue(txring_txq(tx_ring));
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
 
-	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
-	memset(tx_ring->tx_buffer_info, 0, size);
+		/* check for eop_desc to determine the end of the packet */
+		eop_desc = tx_buffer->next_to_watch;
+		tx_desc = IGB_TX_DESC(tx_ring, i);
 
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
+				tx_desc = IGB_TX_DESC(tx_ring, 0);
+			}
 
+			/* unmap any remaining paged data */
+			if (dma_unmap_len(tx_buffer, len))
+				dma_unmap_page(tx_ring->dev,
+					       dma_unmap_addr(tx_buffer, dma),
+					       dma_unmap_len(tx_buffer, len),
+					       DMA_TO_DEVICE);
+		}
+
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
@@ -5254,18 +5266,32 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
+	tx_buffer = &tx_ring->tx_buffer_info[i];
 
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
-		igb_unmap_and_free_tx_resource(tx_ring, tx_buffer);
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
+	dev_kfree_skb_any(tx_buffer->skb);
+	tx_buffer->skb = NULL;
+
 	tx_ring->next_to_use = i;
 }
 
@@ -5337,7 +5363,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 
 out_drop:
-	igb_unmap_and_free_tx_resource(tx_ring, first);
+	dev_kfree_skb_any(first->skb);
+	first->skb = NULL;
 
 	return NETDEV_TX_OK;
 }
@@ -6684,7 +6711,6 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector, int napi_budget)
 				 DMA_TO_DEVICE);
 
 		/* clear tx_buffer data */
-		tx_buffer->skb = NULL;
 		dma_unmap_len_set(tx_buffer, len, 0);
 
 		/* clear last DMA location and unmap remaining buffers */
-- 
2.12.0
