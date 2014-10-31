From: David Miller <davem@davemloft.net>
Subject: Re: DMA-API warning from sunhme - unchecked dma_map_single error
Date: Fri, 31 Oct 2014 13:43:54 -0400 (EDT)
Message-ID: <20141031.134354.207893264084946385.davem@davemloft.net>
References: <alpine.SOC.1.00.1311291036050.3807@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: mroos@linux.ee
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <alpine.SOC.1.00.1311291036050.3807@math.ut.ee>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Fri, 29 Nov 2013 10:40:40 +0200 (EET)

> It seems to be correct warning - dma_map_single is used unchecked in 
> sunhme.c. I can try fixing it - the error handling will be the only 
> problem. Is it considered worthwile?

Can you test this patch?

====================
sunhme: Add DMA mapping error checks.

Reported-by: Meelis Roos <mroos@linux.ee>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/sun/sunhme.c | 62 +++++++++++++++++++++++++++++++++++----
 1 file changed, 57 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 72c8525..9c01480 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -1262,6 +1262,7 @@ static void happy_meal_init_rings(struct happy_meal *hp)
 	HMD(("init rxring, "));
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
+		u32 mapping;
 
 		skb = happy_meal_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
 		if (!skb) {
@@ -1272,10 +1273,16 @@ static void happy_meal_init_rings(struct happy_meal *hp)
 
 		/* Because we reserve afterwards. */
 		skb_put(skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
+		mapping = dma_map_single(hp->dma_dev, skb->data, RX_BUF_ALLOC_SIZE,
+					 DMA_FROM_DEVICE);
+		if (dma_mapping_error(hp->dma_dev, mapping)) {
+			dev_kfree_skb_any(skb);
+			hme_write_rxd(hp, &hb->happy_meal_rxd[i], 0, 0);
+			continue;
+		}
 		hme_write_rxd(hp, &hb->happy_meal_rxd[i],
 			      (RXFLAG_OWN | ((RX_BUF_ALLOC_SIZE - RX_OFFSET) << 16)),
-			      dma_map_single(hp->dma_dev, skb->data, RX_BUF_ALLOC_SIZE,
-					     DMA_FROM_DEVICE));
+			      mapping);
 		skb_reserve(skb, RX_OFFSET);
 	}
 
@@ -2020,6 +2027,7 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 		skb = hp->rx_skbs[elem];
 		if (len > RX_COPY_THRESHOLD) {
 			struct sk_buff *new_skb;
+			u32 mapping;
 
 			/* Now refill the entry, if we can. */
 			new_skb = happy_meal_alloc_skb(RX_BUF_ALLOC_SIZE, GFP_ATOMIC);
@@ -2027,13 +2035,21 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 				drops++;
 				goto drop_it;
 			}
+			skb_put(new_skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
+			mapping = dma_map_single(hp->dma_dev, new_skb->data,
+						 RX_BUF_ALLOC_SIZE,
+						 DMA_FROM_DEVICE);
+			if (unlikely(dma_mapping_error(hp->dma_dev, mapping))) {
+				dev_kfree_skb_any(new_skb);
+				drops++;
+				goto drop_it;
+			}
+
 			dma_unmap_single(hp->dma_dev, dma_addr, RX_BUF_ALLOC_SIZE, DMA_FROM_DEVICE);
 			hp->rx_skbs[elem] = new_skb;
-			skb_put(new_skb, (ETH_FRAME_LEN + RX_OFFSET + 4));
 			hme_write_rxd(hp, this,
 				      (RXFLAG_OWN|((RX_BUF_ALLOC_SIZE-RX_OFFSET)<<16)),
-				      dma_map_single(hp->dma_dev, new_skb->data, RX_BUF_ALLOC_SIZE,
-						     DMA_FROM_DEVICE));
+				      mapping);
 			skb_reserve(new_skb, RX_OFFSET);
 
 			/* Trim the original skb for the netif. */
@@ -2248,6 +2264,25 @@ static void happy_meal_tx_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
+static void unmap_partial_tx_skb(struct happy_meal *hp, u32 first_mapping,
+				 u32 first_len, u32 first_entry, u32 entry)
+{
+	struct happy_meal_txd *txbase = &hp->happy_block->happy_meal_txd[0];
+
+	dma_unmap_single(hp->dma_dev, first_mapping, first_len, DMA_TO_DEVICE);
+
+	first_entry = NEXT_TX(first_entry);
+	while (first_entry != entry) {
+		struct happy_meal_txd *this = &txbase[first_entry];
+		u32 addr, len;
+
+		addr = hme_read_desc32(hp, &this->tx_addr);
+		len = hme_read_desc32(hp, &this->tx_flags);
+		len &= TXFLAG_SIZE;
+		dma_unmap_page(hp->dma_dev, addr, len, DMA_TO_DEVICE);
+	}
+}
+
 static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 					 struct net_device *dev)
 {
@@ -2284,6 +2319,8 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 
 		len = skb->len;
 		mapping = dma_map_single(hp->dma_dev, skb->data, len, DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(hp->dma_dev, mapping)))
+			goto out_dma_error;
 		tx_flags |= (TXFLAG_SOP | TXFLAG_EOP);
 		hme_write_txd(hp, &hp->happy_block->happy_meal_txd[entry],
 			      (tx_flags | (len & TXFLAG_SIZE)),
@@ -2299,6 +2336,8 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 		first_len = skb_headlen(skb);
 		first_mapping = dma_map_single(hp->dma_dev, skb->data, first_len,
 					       DMA_TO_DEVICE);
+		if (unlikely(dma_mapping_error(hp->dma_dev, first_mapping)))
+			goto out_dma_error;
 		entry = NEXT_TX(entry);
 
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
@@ -2308,6 +2347,11 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 			len = skb_frag_size(this_frag);
 			mapping = skb_frag_dma_map(hp->dma_dev, this_frag,
 						   0, len, DMA_TO_DEVICE);
+			if (unlikely(dma_mapping_error(hp->dma_dev, mapping))) {
+				unmap_partial_tx_skb(hp, first_mapping, first_len,
+						     first_entry, entry);
+				goto out_dma_error;
+			}
 			this_txflags = tx_flags;
 			if (frag == skb_shinfo(skb)->nr_frags - 1)
 				this_txflags |= TXFLAG_EOP;
@@ -2333,6 +2377,14 @@ static netdev_tx_t happy_meal_start_xmit(struct sk_buff *skb,
 
 	tx_add_log(hp, TXLOG_ACTION_TXMIT, 0);
 	return NETDEV_TX_OK;
+
+out_dma_error:
+	hp->tx_skbs[hp->tx_new] = NULL;
+	spin_unlock_irq(&hp->happy_lock);
+
+	dev_kfree_skb_any(skb);
+	dev->stats.tx_dropped++;
+	return NETDEV_TX_OK;
 }
 
 static struct net_device_stats *happy_meal_get_stats(struct net_device *dev)
-- 
1.9.3

