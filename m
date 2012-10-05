From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: remove skb recycling
Date: Fri, 05 Oct 2012 18:23:55 +0200
Message-ID: <1349454235.21172.132.camel@edumazet-glaptop>
References: <20120829002548.GA7063@aldebaran.gro-tsen.net>
	 <alpine.LSU.2.00.1208311900330.1936@eggly.anvils>
	 <1349366521.2532.12.camel@sakura.staff.proxad.net>
	 <1349368171.16011.79.camel@edumazet-glaptop>
	 <1349422868.21172.38.camel@edumazet-glaptop>
	 <1349434194.16710.44.camel@sakura.staff.proxad.net>
	 <1349439732.21172.52.camel@edumazet-glaptop>
	 <1349441509.28867.17.camel@sakura.staff.proxad.net>
	 <1349442173.21172.66.camel@edumazet-glaptop>
	 <1349448659.28867.27.camel@sakura.staff.proxad.net>
	 <1349449440.21172.118.camel@edumazet-glaptop>
	 <1349450151.28867.33.camel@sakura.staff.proxad.net>
	 <1349451425.21172.119.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Madore <david+ml@madore.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	netdev <netdev@vger.kernel.org>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39286 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976Ab2JEQYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 12:24:00 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1031093bkc.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 09:23:59 -0700 (PDT)
In-Reply-To: <1349451425.21172.119.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Over time, skb recycling infrastructure got litle interest and
many bugs. Generic rx path skb allocation is now using page
fragments for efficient GRO / TCP coalescing, and recyling
a tx skb for rx path is not worth the pain.

Last identified bug is that fat skbs can be recycled
and it can endup using high order pages after few iterations.

With help from Maxime Bizon, who pointed out that commit
87151b8689d (net: allow pskb_expand_head() to get maximum tailroom)
introduced this regression for recycled skbs.

Instead of fixing this bug, lets remove skb recycling.

Drivers wanting really hot skbs should use build_skb() anyway,
to allocate/populate sk_buff right before netif_receive_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maxime Bizon <mbizon@freebox.fr>
---
 drivers/net/ethernet/calxeda/xgmac.c              |   19 ----
 drivers/net/ethernet/freescale/gianfar.c          |   27 +-----
 drivers/net/ethernet/freescale/gianfar.h          |    2 
 drivers/net/ethernet/freescale/ucc_geth.c         |   29 +------
 drivers/net/ethernet/freescale/ucc_geth.h         |    2 
 drivers/net/ethernet/marvell/mv643xx_eth.c        |   18 ----
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   20 -----
 include/linux/skbuff.h                            |   24 ------
 net/core/skbuff.c                                 |   47 ------------
 10 files changed, 16 insertions(+), 173 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 2b4b4f5..16814b3 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -375,7 +375,6 @@ struct xgmac_priv {
 	unsigned int tx_tail;
 
 	void __iomem *base;
-	struct sk_buff_head rx_recycle;
 	unsigned int dma_buf_sz;
 	dma_addr_t dma_rx_phy;
 	dma_addr_t dma_tx_phy;
@@ -672,9 +671,7 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
 		p = priv->dma_rx + entry;
 
 		if (priv->rx_skbuff[entry] == NULL) {
-			skb = __skb_dequeue(&priv->rx_recycle);
-			if (skb == NULL)
-				skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
+			skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
 			if (unlikely(skb == NULL))
 				break;
 
@@ -887,17 +884,7 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
 				       desc_get_buf_len(p), DMA_TO_DEVICE);
 		}
 
-		/*
-		 * If there's room in the queue (limit it to size)
-		 * we add this skb back into the pool,
-		 * if it's the right size.
-		 */
-		if ((skb_queue_len(&priv->rx_recycle) <
-			DMA_RX_RING_SZ) &&
-			skb_recycle_check(skb, priv->dma_buf_sz))
-			__skb_queue_head(&priv->rx_recycle, skb);
-		else
-			dev_kfree_skb(skb);
+		dev_kfree_skb(skb);
 	}
 
 	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) >
@@ -1016,7 +1003,6 @@ static int xgmac_open(struct net_device *dev)
 			dev->dev_addr);
 	}
 
-	skb_queue_head_init(&priv->rx_recycle);
 	memset(&priv->xstats, 0, sizeof(struct xgmac_extra_stats));
 
 	/* Initialize the XGMAC and descriptors */
@@ -1053,7 +1039,6 @@ static int xgmac_stop(struct net_device *dev)
 		napi_disable(&priv->napi);
 
 	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
-	skb_queue_purge(&priv->rx_recycle);
 
 	/* Disable the MAC core */
 	xgmac_mac_disable(priv->base);
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a1b52ec..1d03dcd 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1765,7 +1765,6 @@ static void free_skb_resources(struct gfar_private *priv)
 			  sizeof(struct rxbd8) * priv->total_rx_ring_size,
 			  priv->tx_queue[0]->tx_bd_base,
 			  priv->tx_queue[0]->tx_bd_dma_base);
-	skb_queue_purge(&priv->rx_recycle);
 }
 
 void gfar_start(struct net_device *dev)
@@ -1943,8 +1942,6 @@ static int gfar_enet_open(struct net_device *dev)
 
 	enable_napi(priv);
 
-	skb_queue_head_init(&priv->rx_recycle);
-
 	/* Initialize a bunch of registers */
 	init_registers(dev);
 
@@ -2533,16 +2530,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		bytes_sent += skb->len;
 
-		/* If there's room in the queue (limit it to rx_buffer_size)
-		 * we add this skb back into the pool, if it's the right size
-		 */
-		if (skb_queue_len(&priv->rx_recycle) < rx_queue->rx_ring_size &&
-		    skb_recycle_check(skb, priv->rx_buffer_size +
-				      RXBUF_ALIGNMENT)) {
-			gfar_align_skb(skb);
-			skb_queue_head(&priv->rx_recycle, skb);
-		} else
-			dev_kfree_skb_any(skb);
+		dev_kfree_skb_any(skb);
 
 		tx_queue->tx_skbuff[skb_dirtytx] = NULL;
 
@@ -2608,7 +2596,7 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
 static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 
 	skb = netdev_alloc_skb(dev, priv->rx_buffer_size + RXBUF_ALIGNMENT);
 	if (!skb)
@@ -2621,14 +2609,7 @@ static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
 
 struct sk_buff *gfar_new_skb(struct net_device *dev)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-	struct sk_buff *skb = NULL;
-
-	skb = skb_dequeue(&priv->rx_recycle);
-	if (!skb)
-		skb = gfar_alloc_skb(dev);
-
-	return skb;
+	return gfar_alloc_skb(dev);
 }
 
 static inline void count_errors(unsigned short status, struct net_device *dev)
@@ -2787,7 +2768,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb)
-				skb_queue_head(&priv->rx_recycle, skb);
+				dev_kfree_skb(skb);
 		} else {
 			/* Increment the number of packets */
 			rx_queue->stats.rx_packets++;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 4141ef2..22eabc1 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1080,8 +1080,6 @@ struct gfar_private {
 
 	u32 cur_filer_idx;
 
-	struct sk_buff_head rx_recycle;
-
 	/* RX queue filer rule set*/
 	struct ethtool_rx_list rx_list;
 	struct mutex rx_queue_access;
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 1642884..dfa0aaa 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -209,14 +209,12 @@ static struct list_head *dequeue(struct list_head *lh)
 static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 		u8 __iomem *bd)
 {
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 
-	skb = __skb_dequeue(&ugeth->rx_recycle);
+	skb = netdev_alloc_skb(ugeth->ndev,
+			       ugeth->ug_info->uf_info.max_rx_buf_length +
+			       UCC_GETH_RX_DATA_BUF_ALIGNMENT);
 	if (!skb)
-		skb = netdev_alloc_skb(ugeth->ndev,
-				      ugeth->ug_info->uf_info.max_rx_buf_length +
-				      UCC_GETH_RX_DATA_BUF_ALIGNMENT);
-	if (skb == NULL)
 		return NULL;
 
 	/* We need the data buffer to be aligned properly.  We will reserve
@@ -2020,8 +2018,6 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		iounmap(ugeth->ug_regs);
 		ugeth->ug_regs = NULL;
 	}
-
-	skb_queue_purge(&ugeth->rx_recycle);
 }
 
 static void ucc_geth_set_multi(struct net_device *dev)
@@ -2230,8 +2226,6 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 
-	skb_queue_head_init(&ugeth->rx_recycle);
-
 	return 0;
 }
 
@@ -3274,12 +3268,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 			if (netif_msg_rx_err(ugeth))
 				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
 					   __func__, __LINE__, (u32) skb);
-			if (skb) {
-				skb->data = skb->head + NET_SKB_PAD;
-				skb->len = 0;
-				skb_reset_tail_pointer(skb);
-				__skb_queue_head(&ugeth->rx_recycle, skb);
-			}
+			dev_free_skb(skb);
 
 			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
 			dev->stats.rx_dropped++;
@@ -3349,13 +3338,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		dev->stats.tx_packets++;
 
-		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
-			     skb_recycle_check(skb,
-				    ugeth->ug_info->uf_info.max_rx_buf_length +
-				    UCC_GETH_RX_DATA_BUF_ALIGNMENT))
-			__skb_queue_head(&ugeth->rx_recycle, skb);
-		else
-			dev_kfree_skb(skb);
+		dev_kfree_skb(skb);
 
 		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
 		ugeth->skb_dirtytx[txQ] =
diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index f71b3e7..75f3371 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -1214,8 +1214,6 @@ struct ucc_geth_private {
 	/* index of the first skb which hasn't been transmitted yet. */
 	u16 skb_dirtytx[NUM_TX_QUEUES];
 
-	struct sk_buff_head rx_recycle;
-
 	struct ugeth_mii_info *mii_info;
 	struct phy_device *phydev;
 	phy_interface_t phy_interface;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 087b9e0..84c1326 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -412,7 +412,6 @@ struct mv643xx_eth_private {
 	u8 work_rx_refill;
 
 	int skb_size;
-	struct sk_buff_head rx_recycle;
 
 	/*
 	 * RX state.
@@ -673,9 +672,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		struct rx_desc *rx_desc;
 		int size;
 
-		skb = __skb_dequeue(&mp->rx_recycle);
-		if (skb == NULL)
-			skb = netdev_alloc_skb(mp->dev, mp->skb_size);
+		skb = netdev_alloc_skb(mp->dev, mp->skb_size);
 
 		if (skb == NULL) {
 			mp->oom = 1;
@@ -989,14 +986,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 				       desc->byte_cnt, DMA_TO_DEVICE);
 		}
 
-		if (skb != NULL) {
-			if (skb_queue_len(&mp->rx_recycle) <
-					mp->rx_ring_size &&
-			    skb_recycle_check(skb, mp->skb_size))
-				__skb_queue_head(&mp->rx_recycle, skb);
-			else
-				dev_kfree_skb(skb);
-		}
+		dev_kfree_skb(skb);
 	}
 
 	__netif_tx_unlock(nq);
@@ -2349,8 +2339,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	napi_enable(&mp->napi);
 
-	skb_queue_head_init(&mp->rx_recycle);
-
 	mp->int_mask = INT_EXT;
 
 	for (i = 0; i < mp->rxq_count; i++) {
@@ -2445,8 +2433,6 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mib_counters_update(mp);
 	del_timer_sync(&mp->mib_counters_timer);
 
-	skb_queue_purge(&mp->rx_recycle);
-
 	for (i = 0; i < mp->rxq_count; i++)
 		rxq_deinit(mp->rxq + i);
 	for (i = 0; i < mp->txq_count; i++)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index e872e1d..7d51a65 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -50,7 +50,6 @@ struct stmmac_priv {
 	unsigned int dirty_rx;
 	struct sk_buff **rx_skbuff;
 	dma_addr_t *rx_skbuff_dma;
-	struct sk_buff_head rx_recycle;
 
 	struct net_device *dev;
 	dma_addr_t dma_rx_phy;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 3be8833..c6cdbc4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -747,18 +747,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		priv->hw->ring->clean_desc3(p);
 
 		if (likely(skb != NULL)) {
-			/*
-			 * If there's room in the queue (limit it to size)
-			 * we add this skb back into the pool,
-			 * if it's the right size.
-			 */
-			if ((skb_queue_len(&priv->rx_recycle) <
-				priv->dma_rx_size) &&
-				skb_recycle_check(skb, priv->dma_buf_sz))
-				__skb_queue_head(&priv->rx_recycle, skb);
-			else
-				dev_kfree_skb(skb);
-
+			dev_kfree_skb(skb);
 			priv->tx_skbuff[entry] = NULL;
 		}
 
@@ -1169,7 +1158,6 @@ static int stmmac_open(struct net_device *dev)
 	priv->eee_enabled = stmmac_eee_init(priv);
 
 	napi_enable(&priv->napi);
-	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
 
 	return 0;
@@ -1222,7 +1210,6 @@ static int stmmac_release(struct net_device *dev)
 		kfree(priv->tm);
 #endif
 	napi_disable(&priv->napi);
-	skb_queue_purge(&priv->rx_recycle);
 
 	/* Free the IRQ lines */
 	free_irq(dev->irq, dev);
@@ -1388,10 +1375,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		if (likely(priv->rx_skbuff[entry] == NULL)) {
 			struct sk_buff *skb;
 
-			skb = __skb_dequeue(&priv->rx_recycle);
-			if (skb == NULL)
-				skb = netdev_alloc_skb_ip_align(priv->dev,
-								bfsize);
+			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
 
 			if (unlikely(skb == NULL))
 				break;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b33a3a1..6a2c34e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -589,9 +589,6 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
-extern void skb_recycle(struct sk_buff *skb);
-extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
-
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 extern int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
@@ -2645,27 +2642,6 @@ static inline void skb_checksum_none_assert(const struct sk_buff *skb)
 
 bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
-static inline bool skb_is_recycleable(const struct sk_buff *skb, int skb_size)
-{
-	if (irqs_disabled())
-		return false;
-
-	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)
-		return false;
-
-	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
-		return false;
-
-	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
-	if (skb_end_offset(skb) < skb_size)
-		return false;
-
-	if (skb_shared(skb) || skb_cloned(skb))
-		return false;
-
-	return true;
-}
-
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
  * @skb: skb to check
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cdc2859..6e04b1f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -655,53 +655,6 @@ void consume_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(consume_skb);
 
-/**
- * 	skb_recycle - clean up an skb for reuse
- * 	@skb: buffer
- *
- * 	Recycles the skb to be reused as a receive buffer. This
- * 	function does any necessary reference count dropping, and
- * 	cleans up the skbuff as if it just came from __alloc_skb().
- */
-void skb_recycle(struct sk_buff *skb)
-{
-	struct skb_shared_info *shinfo;
-
-	skb_release_head_state(skb);
-
-	shinfo = skb_shinfo(skb);
-	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
-	atomic_set(&shinfo->dataref, 1);
-
-	memset(skb, 0, offsetof(struct sk_buff, tail));
-	skb->data = skb->head + NET_SKB_PAD;
-	skb_reset_tail_pointer(skb);
-}
-EXPORT_SYMBOL(skb_recycle);
-
-/**
- *	skb_recycle_check - check if skb can be reused for receive
- *	@skb: buffer
- *	@skb_size: minimum receive buffer size
- *
- *	Checks that the skb passed in is not shared or cloned, and
- *	that it is linear and its head portion at least as large as
- *	skb_size so that it can be recycled as a receive buffer.
- *	If these conditions are met, this function does any necessary
- *	reference count dropping and cleans up the skbuff as if it
- *	just came from __alloc_skb().
- */
-bool skb_recycle_check(struct sk_buff *skb, int skb_size)
-{
-	if (!skb_is_recycleable(skb, skb_size))
-		return false;
-
-	skb_recycle(skb);
-
-	return true;
-}
-EXPORT_SYMBOL(skb_recycle_check);
-
 static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 	new->tstamp		= old->tstamp;
