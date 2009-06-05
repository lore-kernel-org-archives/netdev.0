From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2] net: skb_shared_info optimization
Date: Fri, 05 Jun 2009 16:04:16 +0200
Message-ID: <4A2925E0.6060508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51349 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbZFEOER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 10:04:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_dma_unmap() is quite expensive for small packets, 
because we use two different cache lines from skb_shared_info.

One to access nr_frags, one to access dma_maps[0]

Instead of dma_maps being an array of MAX_SKB_FRAGS + 1 elements,
let dma_head alone in a new dma_head field, close to nr_frags,
to reduce cache lines misses.

Tested on my dev machine (bnx2 & tg3 adapters), nice speedup !

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bnx2.c             |    6 +++---
 drivers/net/e1000/e1000_main.c |    4 ++--
 drivers/net/e1000e/netdev.c    |    4 ++--
 drivers/net/igb/igb_main.c     |    5 ++---
 drivers/net/igbvf/netdev.c     |    5 ++---
 drivers/net/ixgb/ixgb_main.c   |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 drivers/net/tg3.c              |   10 +++++-----
 include/linux/skbuff.h         |    5 ++++-
 net/core/skb_dma_map.c         |   12 ++++++------
 10 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7485058..aad484c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -189,6 +189,9 @@ struct skb_shared_info {
 	atomic_t	dataref;
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
+#ifdef CONFIG_HAS_DMA
+	dma_addr_t	dma_head;
+#endif
 	/* Warning: this field is not always filled in (UFO)! */
 	unsigned short	gso_segs;
 	unsigned short  gso_type;
@@ -198,7 +201,7 @@ struct skb_shared_info {
 	struct skb_shared_hwtstamps hwtstamps;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 #ifdef CONFIG_HAS_DMA
-	dma_addr_t	dma_maps[MAX_SKB_FRAGS + 1];
+	dma_addr_t	dma_maps[MAX_SKB_FRAGS];
 #endif
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f530172..391d2d4 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5487,7 +5487,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 		dev_kfree_skb(skb);
 		return -EIO;
 	}
-	map = skb_shinfo(skb)->dma_maps[0];
+	map = skb_shinfo(skb)->dma_head;
 
 	REG_WR(bp, BNX2_HC_COMMAND,
 	       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
@@ -6167,7 +6167,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	sp = skb_shinfo(skb);
-	mapping = sp->dma_maps[0];
+	mapping = sp->dma_head;
 
 	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = skb;
@@ -6191,7 +6191,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbd = &txr->tx_desc_ring[ring_prod];
 
 		len = frag->size;
-		mapping = sp->dma_maps[i + 1];
+		mapping = sp->dma_maps[i];
 
 		txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
 		txbd->tx_bd_haddr_lo = (u64) mapping & 0xffffffff;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 05e87a5..8d36743 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2998,7 +2998,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			size -= 4;
 
 		buffer_info->length = size;
-		buffer_info->dma = map[0] + offset;
+		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
 
@@ -3039,7 +3039,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 				size -= 4;
 
 			buffer_info->length = size;
-			buffer_info->dma = map[f + 1] + offset;
+			buffer_info->dma = map[f] + offset;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = i;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 38694c7..9043f1b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3916,7 +3916,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		buffer_info->length = size;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
-		buffer_info->dma = map[0] + offset;
+		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
 		count++;
 
 		len -= size;
@@ -3947,7 +3947,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = i;
-			buffer_info->dma = map[f + 1] + offset;
+			buffer_info->dma = map[f] + offset;
 
 			len -= size;
 			offset += size;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 958b287..ea17319 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3139,8 +3139,7 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = map[count];
-	count++;
+	buffer_info->dma = skb_shinfo(skb)->dma_head;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
@@ -3164,7 +3163,7 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
-	return count;
+	return count + 1;
 }
 
 static inline void igb_tx_queue_adv(struct igb_adapter *adapter,
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 5f7ba1a..22aadb7 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2119,8 +2119,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = map[count];
-	count++;
+	buffer_info->dma = skb_shinfo(skb)->dma_head;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
@@ -2144,7 +2143,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
-	return count;
+	return count + 1;
 }
 
 static inline void igbvf_tx_queue_adv(struct igbvf_adapter *adapter,
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6eb7f37..9c897cf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1300,7 +1300,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		buffer_info->length = size;
 		WARN_ON(buffer_info->dma != 0);
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = map[0] + offset;
+		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
 			pci_map_single(adapter->pdev,
 				skb->data + offset,
 				size,
@@ -1340,7 +1340,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
-			buffer_info->dma = map[f + 1] + offset;
+			buffer_info->dma = map[f] + offset;
 			buffer_info->next_to_watch = 0;
 
 			len -= size;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index de70a2d..fe55adc 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4619,7 +4619,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 		tx_buffer_info->length = size;
-		tx_buffer_info->dma = map[0] + offset;
+		tx_buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
@@ -4651,7 +4651,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 			tx_buffer_info->length = size;
-			tx_buffer_info->dma = map[f + 1] + offset;
+			tx_buffer_info->dma = map[f] + offset;
 			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index a39b534..46a3f86 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5021,7 +5021,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 		/* New SKB is guaranteed to be linear. */
 		entry = *start;
 		ret = skb_dma_map(&tp->pdev->dev, new_skb, DMA_TO_DEVICE);
-		new_addr = skb_shinfo(new_skb)->dma_maps[0];
+		new_addr = skb_shinfo(new_skb)->dma_head;
 
 		/* Make sure new skb does not cross any 4G boundaries.
 		 * Drop the packet if it does.
@@ -5155,7 +5155,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	sp = skb_shinfo(skb);
 
-	mapping = sp->dma_maps[0];
+	mapping = sp->dma_head;
 
 	tp->tx_buffers[entry].skb = skb;
 
@@ -5173,7 +5173,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			len = frag->size;
-			mapping = sp->dma_maps[i + 1];
+			mapping = sp->dma_maps[i];
 			tp->tx_buffers[entry].skb = NULL;
 
 			tg3_set_txd(tp, entry, mapping, len,
@@ -5331,7 +5331,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 
 	sp = skb_shinfo(skb);
 
-	mapping = sp->dma_maps[0];
+	mapping = sp->dma_head;
 
 	tp->tx_buffers[entry].skb = skb;
 
@@ -5356,7 +5356,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			len = frag->size;
-			mapping = sp->dma_maps[i + 1];
+			mapping = sp->dma_maps[i];
 
 			tp->tx_buffers[entry].skb = NULL;
 
diff --git a/net/core/skb_dma_map.c b/net/core/skb_dma_map.c
index 7adb623..79687df 100644
--- a/net/core/skb_dma_map.c
+++ b/net/core/skb_dma_map.c
@@ -20,7 +20,7 @@ int skb_dma_map(struct device *dev, struct sk_buff *skb,
 	if (dma_mapping_error(dev, map))
 		goto out_err;
 
-	sp->dma_maps[0] = map;
+	sp->dma_head = map;
 	for (i = 0; i < sp->nr_frags; i++) {
 		skb_frag_t *fp = &sp->frags[i];
 
@@ -28,7 +28,7 @@ int skb_dma_map(struct device *dev, struct sk_buff *skb,
 				   fp->size, dir);
 		if (dma_mapping_error(dev, map))
 			goto unwind;
-		sp->dma_maps[i + 1] = map;
+		sp->dma_maps[i] = map;
 	}
 
 	return 0;
@@ -37,10 +37,10 @@ unwind:
 	while (--i >= 0) {
 		skb_frag_t *fp = &sp->frags[i];
 
-		dma_unmap_page(dev, sp->dma_maps[i + 1],
+		dma_unmap_page(dev, sp->dma_maps[i],
 			       fp->size, dir);
 	}
-	dma_unmap_single(dev, sp->dma_maps[0],
+	dma_unmap_single(dev, sp->dma_head,
 			 skb_headlen(skb), dir);
 out_err:
 	return -ENOMEM;
@@ -53,12 +53,12 @@ void skb_dma_unmap(struct device *dev, struct sk_buff *skb,
 	struct skb_shared_info *sp = skb_shinfo(skb);
 	int i;
 
-	dma_unmap_single(dev, sp->dma_maps[0],
+	dma_unmap_single(dev, sp->dma_head,
 			 skb_headlen(skb), dir);
 	for (i = 0; i < sp->nr_frags; i++) {
 		skb_frag_t *fp = &sp->frags[i];
 
-		dma_unmap_page(dev, sp->dma_maps[i + 1],
+		dma_unmap_page(dev, sp->dma_maps[i],
 			       fp->size, dir);
 	}
 }
