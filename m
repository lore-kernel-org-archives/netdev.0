From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 4/8] net/stmmac: use generic recycling infrastructure
Date: Fri,  2 Jul 2010 21:20:17 +0200
Message-ID: <1278098421-21296-5-git-send-email-sebastian@breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41203 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756662Ab0GBTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:35 -0400
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/stmmac/stmmac.h      |    1 -
 drivers/net/stmmac/stmmac_main.c |   26 +++++++-------------------
 2 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index ebebc64..dbf9f95 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -44,7 +44,6 @@ struct stmmac_priv {
 	unsigned int dirty_rx;
 	struct sk_buff **rx_skbuff;
 	dma_addr_t *rx_skbuff_dma;
-	struct sk_buff_head rx_recycle;
 
 	struct net_device *dev;
 	int is_gmac;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a31d580..722a5e6 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -636,18 +636,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 			p->des3 = 0;
 
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
+			net_recycle_add(priv->dev, skb);
 			priv->tx_skbuff[entry] = NULL;
 		}
 
@@ -843,6 +832,9 @@ static int stmmac_open(struct net_device *dev)
 	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
 	init_dma_desc_rings(dev);
 
+	net_recycle_init(priv->dev, priv->dma_rx_size, priv->dma_buf_sz +
+			NET_IP_ALIGN);
+
 	/* DMA initialization and SW reset */
 	if (unlikely(priv->hw->dma->init(ioaddr, priv->pbl, priv->dma_tx_phy,
 					 priv->dma_rx_phy) < 0)) {
@@ -894,7 +886,6 @@ static int stmmac_open(struct net_device *dev)
 		phy_start(priv->phydev);
 
 	napi_enable(&priv->napi);
-	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
 	return 0;
 }
@@ -925,7 +916,7 @@ static int stmmac_release(struct net_device *dev)
 		kfree(priv->tm);
 #endif
 	napi_disable(&priv->napi);
-	skb_queue_purge(&priv->rx_recycle);
+	net_recycle_cleanup(priv->dev);
 
 	/* Free the IRQ lines */
 	free_irq(dev->irq, dev);
@@ -1157,13 +1148,10 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		if (likely(priv->rx_skbuff[entry] == NULL)) {
 			struct sk_buff *skb;
 
-			skb = __skb_dequeue(&priv->rx_recycle);
-			if (skb == NULL)
-				skb = netdev_alloc_skb_ip_align(priv->dev,
-								bfsize);
-
+			skb = net_recycle_get(priv->dev);
 			if (unlikely(skb == NULL))
 				break;
+			skb_reserve(skb, NET_IP_ALIGN);
 
 			priv->rx_skbuff[entry] = skb;
 			priv->rx_skbuff_dma[entry] =
-- 
1.6.6.1

