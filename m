From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: bcmgenet: manipulate netdev_queue directly
Date: Thu, 20 Mar 2014 10:53:23 -0700
Message-ID: <1395338003-17982-5-git-send-email-f.fainelli@gmail.com>
References: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:42281 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759402AbaCTRxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:53:40 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so1234862pdj.22
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:53:39 -0700 (PDT)
In-Reply-To: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of always invoking netdev_get_tx_queue() in bcmgenet_xmit() and
bcmgenet_tx_reclaim(), just get the corresponding netdev_queue pointer
once and for all and manipulate it throughout bcmgenet_xmit() and
bcmgenet_tx_reclaim().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index cfcb046f4de5..8f87fe001541 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -868,10 +868,12 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	int last_tx_cn, last_c_index, num_tx_bds;
 	struct enet_cb *tx_cb_ptr;
+	struct netdev_queue *txq;
 	unsigned int c_index;
 
 	/* Compute how many buffers are transmited since last xmit call */
 	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX);
+	txq = netdev_get_tx_queue(dev, ring->queue);
 
 	last_c_index = ring->c_index;
 	num_tx_bds = ring->size;
@@ -917,8 +919,8 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1))
 		ring->int_disable(priv, ring);
 
-	if (__netif_subqueue_stopped(dev, ring->queue))
-		netif_wake_subqueue(dev, ring->queue);
+	if (netif_tx_queue_stopped(txq))
+		netif_tx_wake_queue(txq);
 
 	ring->c_index = c_index;
 }
@@ -1106,6 +1108,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct bcmgenet_tx_ring *ring = NULL;
+	struct netdev_queue *txq;
 	unsigned long flags = 0;
 	int nr_frags, index;
 	u16 dma_desc_flags;
@@ -1127,10 +1130,11 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	ring = &priv->tx_rings[index];
+	txq = netdev_get_tx_queue(dev, ring->queue);
 
 	spin_lock_irqsave(&ring->lock, flags);
 	if (ring->free_bds <= nr_frags + 1) {
-		netif_stop_subqueue(dev, ring->queue);
+		netif_tx_stop_queue(txq);
 		netdev_err(dev, "%s: tx ring %d full when queue %d awake\n",
 				__func__, index, ring->queue);
 		ret = NETDEV_TX_BUSY;
@@ -1177,7 +1181,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 			ring->prod_index, TDMA_PROD_INDEX);
 
 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1)) {
-		netif_stop_subqueue(dev, ring->queue);
+		netif_tx_stop_queue(txq);
 		ring->int_enable(priv, ring);
 	}
 
-- 
1.8.3.2
