From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 7/9] net: bcmgenet: relax lock constraints to reduce IRQ latency
Date: Wed, 25 Oct 2017 15:04:17 -0700
Message-ID: <20171025220419.24951-8-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:54476 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932340AbdJYWFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 18:05:14 -0400
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the ring locks are not used in a hard IRQ context it is often
not necessary to disable global IRQs while waiting on a lock.

Using less restrictive lock and unlock calls improves the real-time
responsiveness of the system.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 747224714394..91f52c1b5108 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1405,11 +1405,10 @@ static unsigned int bcmgenet_tx_reclaim(struct net_device *dev,
 				struct bcmgenet_tx_ring *ring)
 {
 	unsigned int released;
-	unsigned long flags;
 
-	spin_lock_irqsave(&ring->lock, flags);
+	spin_lock_bh(&ring->lock);
 	released = __bcmgenet_tx_reclaim(dev, ring);
-	spin_unlock_irqrestore(&ring->lock, flags);
+	spin_unlock_bh(&ring->lock);
 
 	return released;
 }
@@ -1420,15 +1419,14 @@ static int bcmgenet_tx_poll(struct napi_struct *napi, int budget)
 		container_of(napi, struct bcmgenet_tx_ring, napi);
 	unsigned int work_done = 0;
 	struct netdev_queue *txq;
-	unsigned long flags;
 
-	spin_lock_irqsave(&ring->lock, flags);
+	spin_lock(&ring->lock);
 	work_done = __bcmgenet_tx_reclaim(ring->priv->dev, ring);
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
 		txq = netdev_get_tx_queue(ring->priv->dev, ring->queue);
 		netif_tx_wake_queue(txq);
 	}
-	spin_unlock_irqrestore(&ring->lock, flags);
+	spin_unlock(&ring->lock);
 
 	if (work_done == 0) {
 		napi_complete(napi);
@@ -1523,7 +1521,6 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bcmgenet_tx_ring *ring = NULL;
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
-	unsigned long flags = 0;
 	int nr_frags, index;
 	dma_addr_t mapping;
 	unsigned int size;
@@ -1550,7 +1547,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
-	spin_lock_irqsave(&ring->lock, flags);
+	spin_lock(&ring->lock);
 	if (ring->free_bds <= (nr_frags + 1)) {
 		if (!netif_tx_queue_stopped(txq)) {
 			netif_tx_stop_queue(txq);
@@ -1645,7 +1642,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		bcmgenet_tdma_ring_writel(priv, ring->index,
 					  ring->prod_index, TDMA_PROD_INDEX);
 out:
-	spin_unlock_irqrestore(&ring->lock, flags);
+	spin_unlock(&ring->lock);
 
 	return ret;
 
@@ -2520,17 +2517,16 @@ static int bcmgenet_init_dma(struct bcmgenet_priv *priv)
 /* Interrupt bottom half */
 static void bcmgenet_irq_task(struct work_struct *work)
 {
-	unsigned long flags;
 	unsigned int status;
 	struct bcmgenet_priv *priv = container_of(
 			work, struct bcmgenet_priv, bcmgenet_irq_work);
 
 	netif_dbg(priv, intr, priv->dev, "%s\n", __func__);
 
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irq(&priv->lock);
 	status = priv->irq0_stat;
 	priv->irq0_stat = 0;
-	spin_unlock_irqrestore(&priv->lock, flags);
+	spin_unlock_irq(&priv->lock);
 
 	/* Link UP/DOWN event */
 	if (status & UMAC_IRQ_LINK_EVENT)
@@ -2927,7 +2923,6 @@ static void bcmgenet_dump_tx_queue(struct bcmgenet_tx_ring *ring)
 	u32 p_index, c_index, intsts, intmsk;
 	struct netdev_queue *txq;
 	unsigned int free_bds;
-	unsigned long flags;
 	bool txq_stopped;
 
 	if (!netif_msg_tx_err(priv))
@@ -2935,7 +2930,7 @@ static void bcmgenet_dump_tx_queue(struct bcmgenet_tx_ring *ring)
 
 	txq = netdev_get_tx_queue(priv->dev, ring->queue);
 
-	spin_lock_irqsave(&ring->lock, flags);
+	spin_lock(&ring->lock);
 	if (ring->index == DESC_INDEX) {
 		intsts = ~bcmgenet_intrl2_0_readl(priv, INTRL2_CPU_MASK_STATUS);
 		intmsk = UMAC_IRQ_TXDMA_DONE | UMAC_IRQ_TXDMA_MBDONE;
@@ -2947,7 +2942,7 @@ static void bcmgenet_dump_tx_queue(struct bcmgenet_tx_ring *ring)
 	p_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_PROD_INDEX);
 	txq_stopped = netif_tx_queue_stopped(txq);
 	free_bds = ring->free_bds;
-	spin_unlock_irqrestore(&ring->lock, flags);
+	spin_unlock(&ring->lock);
 
 	netif_err(priv, tx_err, priv->dev, "Ring %d queue %d status summary\n"
 		  "TX queue status: %s, interrupts: %s\n"
-- 
2.14.1
