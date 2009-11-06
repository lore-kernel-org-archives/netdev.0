From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC] move dma_head/dma_maps out of skb_shared_info and into sk_buff
Date: Thu, 05 Nov 2009 16:54:33 -0800
Message-ID: <4AF373C9.7040700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45178 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215AbZKFAy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:54:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During testing we found issues with the use of skb_dma_map/unmap on
systems that had iommu enabled and were configured to use a bridge.  The
issue is that if two ports are members of the same bridge, and a
broadcast packet is sent out on the bridge skb_clone will be used to
send a copy to all ports, but the clones run into issues because the
dma mappings for the cloned skbs all share the shared_info structure
where the dma mappings are stored.

To resolve that this patch moves those dma mappings out of the
shared_info structure and into the sk_buff itself.  This allows cloned
skbs to be mapped separately without causing dma unmapping errors.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 539d23b..fb80e6b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5688,7 +5688,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 		dev_kfree_skb(skb);
 		return -EIO;
 	}
-	map = skb_shinfo(skb)->dma_head;
+	map = skb->dma_head;
 
 	REG_WR(bp, BNX2_HC_COMMAND,
 	       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
@@ -6373,7 +6373,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	sp = skb_shinfo(skb);
-	mapping = sp->dma_head;
+	mapping = skb->dma_head;
 
 	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = skb;
@@ -6397,7 +6397,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbd = &txr->tx_desc_ring[ring_prod];
 
 		len = frag->size;
-		mapping = sp->dma_maps[i];
+		mapping = skb->dma_maps[i];
 
 		txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
 		txbd->tx_bd_haddr_lo = (u64) mapping & 0xffffffff;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c938114..86fb526 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2696,7 +2696,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps;
+	map = skb->dma_maps;
 	offset = 0;
 
 	while (len) {
@@ -2735,7 +2735,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		buffer_info->length = size;
 		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		buffer_info->dma = skb->dma_head + offset;
 		buffer_info->next_to_watch = i;
 
 		len -= size;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3769248..90266c2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3884,7 +3884,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps;
+	map = skb->dma_maps;
 	offset = 0;
 
 	while (len) {
@@ -3894,7 +3894,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		buffer_info->length = size;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		buffer_info->dma = skb->dma_head + offset;
 		count++;
 
 		len -= size;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f01f5af..cf28f11 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3570,7 +3570,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps;
+	map = skb->dma_maps;
 
 	buffer_info = &tx_ring->buffer_info[i];
 	BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
@@ -3578,7 +3578,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = skb_shinfo(skb)->dma_head;
+	buffer_info->dma = skb->dma_head;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index fad7f34..d7bb712 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2100,7 +2100,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps;
+	map = skb->dma_maps;
 
 	buffer_info = &tx_ring->buffer_info[i];
 	BUG_ON(len >= IGBVF_MAX_DATA_PER_TXD);
@@ -2108,7 +2108,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = skb_shinfo(skb)->dma_head;
+	buffer_info->dma = skb->dma_head;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 1bd0ca1..bc401cf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1288,7 +1288,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps;
+	map = skb->dma_maps;
 
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
@@ -1301,7 +1301,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		buffer_info->length = size;
 		WARN_ON(buffer_info->dma != 0);
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		buffer_info->dma = skb->dma_head + offset;
 			pci_map_single(adapter->pdev,
 				skb->data + offset,
 				size,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 45c5faf..d857030 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4953,7 +4953,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps;
+	map = skb->dma_maps;
 
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE)
 		/* excluding fcoe_crc_eof for FCoE */
@@ -4965,7 +4965,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 		tx_buffer_info->length = size;
-		tx_buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		tx_buffer_info->dma = skb->dma_head + offset;
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 47a4f09..559898b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5145,7 +5145,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 		/* New SKB is guaranteed to be linear. */
 		entry = *start;
 		ret = skb_dma_map(&tp->pdev->dev, new_skb, DMA_TO_DEVICE);
-		new_addr = skb_shinfo(new_skb)->dma_head;
+		new_addr = new_skb->dma_head;
 
 		/* Make sure new skb does not cross any 4G boundaries.
 		 * Drop the packet if it does.
@@ -5294,7 +5294,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 
 	sp = skb_shinfo(skb);
 
-	mapping = sp->dma_head;
+	mapping = skb->dma_head;
 
 	tnapi->tx_buffers[entry].skb = skb;
 
@@ -5318,7 +5318,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb,
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			len = frag->size;
-			mapping = sp->dma_maps[i];
+			mapping = skb->dma_maps[i];
 			tnapi->tx_buffers[entry].skb = NULL;
 
 			tg3_set_txd(tnapi, entry, mapping, len,
@@ -5482,7 +5482,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 
 	sp = skb_shinfo(skb);
 
-	mapping = sp->dma_head;
+	mapping = skb->dma_head;
 
 	tnapi->tx_buffers[entry].skb = skb;
 
@@ -5516,7 +5516,7 @@ static netdev_tx_t tg3_start_xmit_dma_bug(struct sk_buff *skb,
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			len = frag->size;
-			mapping = sp->dma_maps[i];
+			mapping = skb->dma_maps[i];
 
 			tnapi->tx_buffers[entry].skb = NULL;
 
@@ -10422,7 +10422,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	num_pkts = 0;
 
 	tg3_set_txd(tnapi, tnapi->tx_prod,
-		    skb_shinfo(skb)->dma_head, tx_len, 0, 1);
+		    skb->dma_head, tx_len, 0, 1);
 
 	tnapi->tx_prod++;
 	num_pkts++;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d0448c5..57c7e81 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -190,9 +190,6 @@ struct skb_shared_info {
 	atomic_t	dataref;
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
-#ifdef CONFIG_HAS_DMA
-	dma_addr_t	dma_head;
-#endif
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
@@ -201,9 +198,6 @@ struct skb_shared_info {
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
-#ifdef CONFIG_HAS_DMA
-	dma_addr_t	dma_maps[MAX_SKB_FRAGS];
-#endif
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
 	void *		destructor_arg;
@@ -399,6 +393,10 @@ struct sk_buff {
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
+#ifdef CONFIG_HAS_DMA
+	dma_addr_t	dma_head;
+	dma_addr_t	dma_maps[MAX_SKB_FRAGS];
+#endif
 	/* These elements must be at the end, see alloc_skb() for details.  */
 	sk_buff_data_t		tail;
 	sk_buff_data_t		end;
diff --git a/net/core/skb_dma_map.c b/net/core/skb_dma_map.c
index 79687df..64d3639 100644
--- a/net/core/skb_dma_map.c
+++ b/net/core/skb_dma_map.c
@@ -20,7 +20,7 @@ int skb_dma_map(struct device *dev, struct sk_buff *skb,
 	if (dma_mapping_error(dev, map))
 		goto out_err;
 
-	sp->dma_head = map;
+	skb->dma_head = map;
 	for (i = 0; i < sp->nr_frags; i++) {
 		skb_frag_t *fp = &sp->frags[i];
 
@@ -28,7 +28,7 @@ int skb_dma_map(struct device *dev, struct sk_buff *skb,
 				   fp->size, dir);
 		if (dma_mapping_error(dev, map))
 			goto unwind;
-		sp->dma_maps[i] = map;
+		skb->dma_maps[i] = map;
 	}
 
 	return 0;
@@ -37,10 +37,10 @@ unwind:
 	while (--i >= 0) {
 		skb_frag_t *fp = &sp->frags[i];
 
-		dma_unmap_page(dev, sp->dma_maps[i],
+		dma_unmap_page(dev, skb->dma_maps[i],
 			       fp->size, dir);
 	}
-	dma_unmap_single(dev, sp->dma_head,
+	dma_unmap_single(dev, skb->dma_head,
 			 skb_headlen(skb), dir);
 out_err:
 	return -ENOMEM;
@@ -53,12 +53,12 @@ void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 	struct skb_shared_info *sp = skb_shinfo(skb);
 	int i;
 
-	dma_unmap_single(dev, sp->dma_head,
+	dma_unmap_single(dev, skb->dma_head,
 			 skb_headlen(skb), dir);
 	for (i = 0; i < sp->nr_frags; i++) {
 		skb_frag_t *fp = &sp->frags[i];
 
-		dma_unmap_page(dev, sp->dma_maps[i],
+		dma_unmap_page(dev, skb->dma_maps[i],
 			       fp->size, dir);
 	}
 }

