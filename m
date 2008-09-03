From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 07/17] mv643xx_eth: get rid of receive-side locking
Date: Wed,  3 Sep 2008 14:29:34 +0200
Message-ID: <1220444984-20150-8-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52897 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752433AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By having the receive out-of-memory handling timer schedule the napi
poll handler and then doing oom processing from the napi poll handler,
all code that touches receive state moves to napi context, letting us
get rid of all explicit locking in the receive paths since the only
mutual exclusion we need anymore at that point is protection against
reentering ourselves, which is provided by napi synchronisation.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  132 +++++++++++++++++++++++----------------------
 1 files changed, 68 insertions(+), 64 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2b7e76d..3831a8b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -329,8 +329,6 @@ struct rx_queue {
 	dma_addr_t rx_desc_dma;
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
-
-	struct timer_list rx_oom;
 };
 
 struct tx_queue {
@@ -372,6 +370,7 @@ struct mv643xx_eth_private {
 	u8 rxq_mask;
 	int rxq_primary;
 	struct napi_struct napi;
+	struct timer_list rx_oom;
 	struct rx_queue rxq[8];
 
 	/*
@@ -473,44 +472,43 @@ static void __txq_maybe_wake(struct tx_queue *txq)
 /* rx ***********************************************************************/
 static void txq_reclaim(struct tx_queue *txq, int force);
 
-static void rxq_refill(struct rx_queue *rxq)
+static int rxq_refill(struct rx_queue *rxq, int budget, int *oom)
 {
-	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
-	unsigned long flags;
+	int skb_size;
+	int refilled;
 
-	spin_lock_irqsave(&mp->lock, flags);
+	/*
+	 * Reserve 2+14 bytes for an ethernet header (the hardware
+	 * automatically prepends 2 bytes of dummy data to each
+	 * received packet), 16 bytes for up to four VLAN tags, and
+	 * 4 bytes for the trailing FCS -- 36 bytes total.
+	 */
+	skb_size = rxq_to_mp(rxq)->dev->mtu + 36;
+
+	/*
+	 * Make sure that the skb size is a multiple of 8 bytes, as
+	 * the lower three bits of the receive descriptor's buffer
+	 * size field are ignored by the hardware.
+	 */
+	skb_size = (skb_size + 7) & ~7;
 
-	while (rxq->rx_desc_count < rxq->rx_ring_size) {
-		int skb_size;
+	refilled = 0;
+	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
 		struct sk_buff *skb;
 		int unaligned;
 		int rx;
 
-		/*
-		 * Reserve 2+14 bytes for an ethernet header (the
-		 * hardware automatically prepends 2 bytes of dummy
-		 * data to each received packet), 16 bytes for up to
-		 * four VLAN tags, and 4 bytes for the trailing FCS
-		 * -- 36 bytes total.
-		 */
-		skb_size = mp->dev->mtu + 36;
-
-		/*
-		 * Make sure that the skb size is a multiple of 8
-		 * bytes, as the lower three bits of the receive
-		 * descriptor's buffer size field are ignored by
-		 * the hardware.
-		 */
-		skb_size = (skb_size + 7) & ~7;
-
 		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
-		if (skb == NULL)
+		if (skb == NULL) {
+			*oom = 1;
 			break;
+		}
 
 		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
 		if (unaligned)
 			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
 
+		refilled++;
 		rxq->rx_desc_count++;
 
 		rx = rxq->rx_used_desc++;
@@ -534,15 +532,7 @@ static void rxq_refill(struct rx_queue *rxq)
 		skb_reserve(skb, 2);
 	}
 
-	if (rxq->rx_desc_count != rxq->rx_ring_size)
-		mod_timer(&rxq->rx_oom, jiffies + (HZ / 10));
-
-	spin_unlock_irqrestore(&mp->lock, flags);
-}
-
-static inline void rxq_refill_timer_wrapper(unsigned long data)
-{
-	rxq_refill((struct rx_queue *)data);
+	return refilled;
 }
 
 static int rxq_process(struct rx_queue *rxq, int budget)
@@ -556,17 +546,12 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		struct rx_desc *rx_desc;
 		unsigned int cmd_sts;
 		struct sk_buff *skb;
-		unsigned long flags;
-
-		spin_lock_irqsave(&mp->lock, flags);
 
 		rx_desc = &rxq->rx_desc_area[rxq->rx_curr_desc];
 
 		cmd_sts = rx_desc->cmd_sts;
-		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
-			spin_unlock_irqrestore(&mp->lock, flags);
+		if (cmd_sts & BUFFER_OWNED_BY_DMA)
 			break;
-		}
 		rmb();
 
 		skb = rxq->rx_skb[rxq->rx_curr_desc];
@@ -576,8 +561,6 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		if (rxq->rx_curr_desc == rxq->rx_ring_size)
 			rxq->rx_curr_desc = 0;
 
-		spin_unlock_irqrestore(&mp->lock, flags);
-
 		dma_unmap_single(NULL, rx_desc->buf_ptr,
 				 rx_desc->buf_size, DMA_FROM_DEVICE);
 		rxq->rx_desc_count--;
@@ -635,15 +618,14 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		mp->dev->last_rx = jiffies;
 	}
 
-	rxq_refill(rxq);
-
 	return rx;
 }
 
 static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
 	struct mv643xx_eth_private *mp;
-	int rx;
+	int work_done;
+	int oom;
 	int i;
 
 	mp = container_of(napi, struct mv643xx_eth_private, napi);
@@ -663,17 +645,32 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 	}
 #endif
 
-	rx = 0;
-	for (i = 7; rx < budget && i >= 0; i--)
-		if (mp->rxq_mask & (1 << i))
-			rx += rxq_process(mp->rxq + i, budget - rx);
+	work_done = 0;
+	oom = 0;
+	for (i = 7; work_done < budget && i >= 0; i--) {
+		if (mp->rxq_mask & (1 << i)) {
+			struct rx_queue *rxq = mp->rxq + i;
 
-	if (rx < budget) {
+			work_done += rxq_process(rxq, budget - work_done);
+			work_done += rxq_refill(rxq, budget - work_done, &oom);
+		}
+	}
+
+	if (work_done < budget) {
+		if (oom)
+			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
 		netif_rx_complete(mp->dev, napi);
 		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 	}
 
-	return rx;
+	return work_done;
+}
+
+static inline void oom_timer_wrapper(unsigned long data)
+{
+	struct mv643xx_eth_private *mp = (void *)data;
+
+	napi_schedule(&mp->napi);
 }
 
 
@@ -1565,10 +1562,6 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct rx_desc);
 	}
 
-	init_timer(&rxq->rx_oom);
-	rxq->rx_oom.data = (unsigned long)rxq;
-	rxq->rx_oom.function = rxq_refill_timer_wrapper;
-
 	return 0;
 
 
@@ -1591,8 +1584,6 @@ static void rxq_deinit(struct rx_queue *rxq)
 
 	rxq_disable(rxq);
 
-	del_timer_sync(&rxq->rx_oom);
-
 	for (i = 0; i < rxq->rx_ring_size; i++) {
 		if (rxq->rx_skb[i]) {
 			dev_kfree_skb(rxq->rx_skb[i]);
@@ -1854,7 +1845,7 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
 		rdl(mp, INT_MASK(mp->port_num));
 
-		netif_rx_schedule(dev, &mp->napi);
+		napi_schedule(&mp->napi);
 	}
 
 	/*
@@ -2041,6 +2032,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int err;
+	int oom;
 	int i;
 
 	wrl(mp, INT_CAUSE(mp->port_num), 0);
@@ -2056,6 +2048,9 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	init_mac_tables(mp);
 
+	napi_enable(&mp->napi);
+
+	oom = 0;
 	for (i = 0; i < 8; i++) {
 		if ((mp->rxq_mask & (1 << i)) == 0)
 			continue;
@@ -2068,7 +2063,12 @@ static int mv643xx_eth_open(struct net_device *dev)
 			goto out;
 		}
 
-		rxq_refill(mp->rxq + i);
+		rxq_refill(mp->rxq + i, INT_MAX, &oom);
+	}
+
+	if (oom) {
+		mp->rx_oom.expires = jiffies + (HZ / 10);
+		add_timer(&mp->rx_oom);
 	}
 
 	for (i = 0; i < 8; i++) {
@@ -2084,8 +2084,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 		}
 	}
 
-	napi_enable(&mp->napi);
-
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
@@ -2150,6 +2148,8 @@ static int mv643xx_eth_stop(struct net_device *dev)
 
 	napi_disable(&mp->napi);
 
+	del_timer_sync(&mp->rx_oom);
+
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
@@ -2613,8 +2613,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	mp->dev = dev;
 
-	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 64);
-
 	set_params(mp, pd);
 
 	spin_lock_init(&mp->lock);
@@ -2633,6 +2631,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	}
 	init_pscr(mp, pd->speed, pd->duplex);
 
+	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 128);
+
+	init_timer(&mp->rx_oom);
+	mp->rx_oom.data = (unsigned long)mp;
+	mp->rx_oom.function = oom_timer_wrapper;
+
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	BUG_ON(!res);
-- 
1.5.6.4

