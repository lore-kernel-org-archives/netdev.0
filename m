From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 16/17] mv643xx_eth: switch to netif tx queue lock, get rid of private spinlock
Date: Wed,  3 Sep 2008 14:29:43 +0200
Message-ID: <1220444984-20150-17-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52896 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753027AbYICM3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:49 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since our ->hard_start_xmit() method is already called under spinlock
protection (the netif tx queue lock), we can simply make that lock
cover the private transmit state (descriptor ring indexes et al.) as
well, which avoids having to use a private lock to protect that state.

Since this was the last user of the driver-private spinlock, it can
be killed off.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   85 +++++++++++++++++++++++++++++----------------
 1 files changed, 55 insertions(+), 30 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 632f4b4..af69b77 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -337,6 +337,10 @@ struct tx_queue {
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
 	struct sk_buff **tx_skb;
+
+	unsigned long tx_packets;
+	unsigned long tx_bytes;
+	unsigned long tx_dropped;
 };
 
 struct mv643xx_eth_private {
@@ -347,8 +351,6 @@ struct mv643xx_eth_private {
 
 	int phy_addr;
 
-	spinlock_t lock;
-
 	struct mib_counters mib_counters;
 	struct work_struct tx_timeout_task;
 	struct mii_if_info mii;
@@ -453,10 +455,12 @@ static void txq_maybe_wake(struct tx_queue *txq)
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 
-	spin_lock(&mp->lock);
-	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
-		netif_tx_wake_queue(nq);
-	spin_unlock(&mp->lock);
+	if (netif_tx_queue_stopped(nq)) {
+		__netif_tx_lock(nq, smp_processor_id());
+		if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
+			netif_tx_wake_queue(nq);
+		__netif_tx_unlock(nq);
+	}
 }
 
 
@@ -785,28 +789,24 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
 	int queue;
 	struct tx_queue *txq;
 	struct netdev_queue *nq;
 	int entries_left;
 
+	queue = skb_get_queue_mapping(skb);
+	txq = mp->txq + queue;
+	nq = netdev_get_tx_queue(dev, queue);
+
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
-		stats->tx_dropped++;
+		txq->tx_dropped++;
 		dev_printk(KERN_DEBUG, &dev->dev,
 			   "failed to linearize skb with tiny "
 			   "unaligned fragment\n");
 		return NETDEV_TX_BUSY;
 	}
 
-	queue = skb_get_queue_mapping(skb);
-	txq = mp->txq + queue;
-	nq = netdev_get_tx_queue(dev, queue);
-
-	spin_lock(&mp->lock);
-
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
-		spin_unlock(&mp->lock);
 		if (net_ratelimit())
 			dev_printk(KERN_ERR, &dev->dev, "tx queue full?!\n");
 		kfree_skb(skb);
@@ -814,16 +814,14 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	txq_submit_skb(txq, skb);
-	stats->tx_bytes += skb->len;
-	stats->tx_packets++;
+	txq->tx_bytes += skb->len;
+	txq->tx_packets++;
 	dev->trans_start = jiffies;
 
 	entries_left = txq->tx_ring_size - txq->tx_desc_count;
 	if (entries_left < MAX_SKB_FRAGS + 1)
 		netif_tx_stop_queue(nq);
 
-	spin_unlock(&mp->lock);
-
 	return NETDEV_TX_OK;
 }
 
@@ -832,10 +830,11 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 static void txq_kick(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 	u32 hw_desc_ptr;
 	u32 expected_ptr;
 
-	spin_lock(&mp->lock);
+	__netif_tx_lock(nq, smp_processor_id());
 
 	if (rdl(mp, TXQ_COMMAND(mp->port_num)) & (1 << txq->index))
 		goto out;
@@ -848,7 +847,7 @@ static void txq_kick(struct tx_queue *txq)
 		txq_enable(txq);
 
 out:
-	spin_unlock(&mp->lock);
+	__netif_tx_unlock(nq);
 
 	mp->work_tx_end &= ~(1 << txq->index);
 }
@@ -856,9 +855,10 @@ out:
 static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 	int reclaimed;
 
-	spin_lock(&mp->lock);
+	__netif_tx_lock(nq, smp_processor_id());
 
 	reclaimed = 0;
 	while (reclaimed < budget && txq->tx_desc_count > 0) {
@@ -897,9 +897,9 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		}
 
 		/*
-		 * Drop mp->lock while we free the skb.
+		 * Drop tx queue lock while we free the skb.
 		 */
-		spin_unlock(&mp->lock);
+		__netif_tx_unlock(nq);
 
 		if (cmd_sts & TX_FIRST_DESC)
 			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
@@ -909,14 +909,14 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		if (skb)
 			dev_kfree_skb(skb);
 
-		spin_lock(&mp->lock);
+		__netif_tx_lock(nq, smp_processor_id());
 	}
 
+	__netif_tx_unlock(nq);
+
 	if (reclaimed < budget)
 		mp->work_tx &= ~(1 << txq->index);
 
-	spin_unlock(&mp->lock);
-
 	return reclaimed;
 }
 
@@ -1123,7 +1123,31 @@ static int smi_reg_write(struct mv643xx_eth_private *mp, unsigned int addr,
 }
 
 
-/* mib counters *************************************************************/
+/* statistics ***************************************************************/
+static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *dev)
+{
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned long tx_packets = 0;
+	unsigned long tx_bytes = 0;
+	unsigned long tx_dropped = 0;
+	int i;
+
+	for (i = 0; i < mp->txq_count; i++) {
+		struct tx_queue *txq = mp->txq + i;
+
+		tx_packets += txq->tx_packets;
+		tx_bytes += txq->tx_bytes;
+		tx_dropped += txq->tx_dropped;
+	}
+
+	stats->tx_packets = tx_packets;
+	stats->tx_bytes = tx_bytes;
+	stats->tx_dropped = tx_dropped;
+
+	return stats;
+}
+
 static inline u32 mib_read(struct mv643xx_eth_private *mp, int offset)
 {
 	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
@@ -1355,6 +1379,7 @@ static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
+	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
 
 	for (i = 0; i < ARRAY_SIZE(mv643xx_eth_stats); i++) {
@@ -2139,6 +2164,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	port_reset(mp);
+	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
 
 	for (i = 0; i < mp->rxq_count; i++)
@@ -2586,8 +2612,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	set_params(mp, pd);
 	dev->real_num_tx_queues = mp->txq_count;
 
-	spin_lock_init(&mp->lock);
-
 	mib_counters_clear(mp);
 	INIT_WORK(&mp->tx_timeout_task, tx_timeout_task);
 
@@ -2613,6 +2637,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	BUG_ON(!res);
 	dev->irq = res->start;
 
+	dev->get_stats = mv643xx_eth_get_stats;
 	dev->hard_start_xmit = mv643xx_eth_xmit;
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
-- 
1.5.6.4

