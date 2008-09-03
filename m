From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 09/17] mv643xx_eth: require contiguous receive and transmit queue numbering
Date: Wed,  3 Sep 2008 14:29:36 +0200
Message-ID: <1220444984-20150-10-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52899 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752558AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify receive and transmit queue handling by requiring the set
of queue numbers to be contiguous starting from zero.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c   |  123 +++++++++++++++---------------------------
 include/linux/mv643xx_eth.h |    6 +-
 2 files changed, 47 insertions(+), 82 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 53cfd01..c41541d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -360,8 +360,7 @@ struct mv643xx_eth_private {
 	int default_rx_ring_size;
 	unsigned long rx_desc_sram_addr;
 	int rx_desc_sram_size;
-	u8 rxq_mask;
-	int rxq_primary;
+	int rxq_count;
 	struct napi_struct napi;
 	struct timer_list rx_oom;
 	struct rx_queue rxq[8];
@@ -372,8 +371,7 @@ struct mv643xx_eth_private {
 	int default_tx_ring_size;
 	unsigned long tx_desc_sram_addr;
 	int tx_desc_sram_size;
-	u8 txq_mask;
-	int txq_primary;
+	int txq_count;
 	struct tx_queue txq[8];
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	int tx_clean_threshold;
@@ -455,7 +453,7 @@ static void __txq_maybe_wake(struct tx_queue *txq)
 	 * netif_{stop,wake}_queue() flow control only applies to
 	 * the primary queue.
 	 */
-	BUG_ON(txq->index != mp->txq_primary);
+	BUG_ON(txq->index != 0);
 
 	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
 		netif_wake_queue(mp->dev);
@@ -626,13 +624,12 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	if (++mp->tx_clean_threshold > 5) {
 		mp->tx_clean_threshold = 0;
-		for (i = 0; i < 8; i++)
-			if (mp->txq_mask & (1 << i))
-				txq_reclaim(mp->txq + i, 0);
+		for (i = 0; i < mp->txq_count; i++)
+			txq_reclaim(mp->txq + i, 0);
 
 		if (netif_carrier_ok(mp->dev)) {
 			spin_lock_irq(&mp->lock);
-			__txq_maybe_wake(mp->txq + mp->txq_primary);
+			__txq_maybe_wake(mp->txq);
 			spin_unlock_irq(&mp->lock);
 		}
 	}
@@ -640,13 +637,11 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 	work_done = 0;
 	oom = 0;
-	for (i = 7; work_done < budget && i >= 0; i--) {
-		if (mp->rxq_mask & (1 << i)) {
-			struct rx_queue *rxq = mp->rxq + i;
+	for (i = mp->rxq_count - 1; work_done < budget && i >= 0; i--) {
+		struct rx_queue *rxq = mp->rxq + i;
 
-			work_done += rxq_process(rxq, budget - work_done);
-			work_done += rxq_refill(rxq, budget - work_done, &oom);
-		}
+		work_done += rxq_process(rxq, budget - work_done);
+		work_done += rxq_refill(rxq, budget - work_done, &oom);
 	}
 
 	if (work_done < budget) {
@@ -846,11 +841,11 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&mp->lock, flags);
 
-	txq = mp->txq + mp->txq_primary;
+	txq = mp->txq;
 
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
 		spin_unlock_irqrestore(&mp->lock, flags);
-		if (txq->index == mp->txq_primary && net_ratelimit())
+		if (txq->index == 0 && net_ratelimit())
 			dev_printk(KERN_ERR, &dev->dev,
 				   "primary tx queue full?!\n");
 		kfree_skb(skb);
@@ -862,7 +857,7 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
-	if (txq->index == mp->txq_primary) {
+	if (txq->index == 0) {
 		int entries_left;
 
 		entries_left = txq->tx_ring_size - txq->tx_desc_count;
@@ -1517,7 +1512,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 
 	size = rxq->rx_ring_size * sizeof(struct rx_desc);
 
-	if (index == mp->rxq_primary && size <= mp->rx_desc_sram_size) {
+	if (index == 0 && size <= mp->rx_desc_sram_size) {
 		rxq->rx_desc_area = ioremap(mp->rx_desc_sram_addr,
 						mp->rx_desc_sram_size);
 		rxq->rx_desc_dma = mp->rx_desc_sram_addr;
@@ -1559,7 +1554,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 
 
 out_free:
-	if (index == mp->rxq_primary && size <= mp->rx_desc_sram_size)
+	if (index == 0 && size <= mp->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
 		dma_free_coherent(NULL, size,
@@ -1590,7 +1585,7 @@ static void rxq_deinit(struct rx_queue *rxq)
 			   rxq->rx_desc_count);
 	}
 
-	if (rxq->index == mp->rxq_primary &&
+	if (rxq->index == 0 &&
 	    rxq->rx_desc_area_size <= mp->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
@@ -1617,7 +1612,7 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	size = txq->tx_ring_size * sizeof(struct tx_desc);
 
-	if (index == mp->txq_primary && size <= mp->tx_desc_sram_size) {
+	if (index == 0 && size <= mp->tx_desc_sram_size) {
 		txq->tx_desc_area = ioremap(mp->tx_desc_sram_addr,
 						mp->tx_desc_sram_size);
 		txq->tx_desc_dma = mp->tx_desc_sram_addr;
@@ -1661,7 +1656,7 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 
 out_free:
-	if (index == mp->txq_primary && size <= mp->tx_desc_sram_size)
+	if (index == 0 && size <= mp->tx_desc_sram_size)
 		iounmap(txq->tx_desc_area);
 	else
 		dma_free_coherent(NULL, size,
@@ -1738,7 +1733,7 @@ static void txq_deinit(struct tx_queue *txq)
 
 	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
-	if (txq->index == mp->txq_primary &&
+	if (txq->index == 0 &&
 	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
 		iounmap(txq->tx_desc_area);
 	else
@@ -1768,13 +1763,11 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 			netif_carrier_off(dev);
 			netif_stop_queue(dev);
 
-			for (i = 0; i < 8; i++) {
+			for (i = 0; i < mp->txq_count; i++) {
 				struct tx_queue *txq = mp->txq + i;
 
-				if (mp->txq_mask & (1 << i)) {
-					txq_reclaim(txq, 1);
-					txq_reset_hw_ptr(txq);
-				}
+				txq_reclaim(txq, 1);
+				txq_reset_hw_ptr(txq);
 			}
 		}
 		return;
@@ -1847,9 +1840,8 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	if (int_cause_ext & INT_EXT_TX) {
 		int i;
 
-		for (i = 0; i < 8; i++)
-			if (mp->txq_mask & (1 << i))
-				txq_reclaim(mp->txq + i, 0);
+		for (i = 0; i < mp->txq_count; i++)
+			txq_reclaim(mp->txq + i, 0);
 
 		/*
 		 * Enough space again in the primary TX queue for a
@@ -1857,7 +1849,7 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		 */
 		if (netif_carrier_ok(dev)) {
 			spin_lock(&mp->lock);
-			__txq_maybe_wake(mp->txq + mp->txq_primary);
+			__txq_maybe_wake(mp->txq);
 			spin_unlock(&mp->lock);
 		}
 	}
@@ -1945,12 +1937,9 @@ static void port_start(struct mv643xx_eth_private *mp)
 	 * Configure TX path and queues.
 	 */
 	tx_set_rate(mp, 1000000000, 16777216);
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < mp->txq_count; i++) {
 		struct tx_queue *txq = mp->txq + i;
 
-		if ((mp->txq_mask & (1 << i)) == 0)
-			continue;
-
 		txq_reset_hw_ptr(txq);
 		txq_set_rate(txq, 1000000000, 16777216);
 		txq_set_fixed_prio_mode(txq);
@@ -1975,14 +1964,11 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Enable the receive queues.
 	 */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < mp->rxq_count; i++) {
 		struct rx_queue *rxq = mp->rxq + i;
 		int off = RXQ_CURRENT_DESC_PTR(mp->port_num, i);
 		u32 addr;
 
-		if ((mp->rxq_mask & (1 << i)) == 0)
-			continue;
-
 		addr = (u32)rxq->rx_desc_dma;
 		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
 		wrl(mp, off, addr);
@@ -2044,15 +2030,11 @@ static int mv643xx_eth_open(struct net_device *dev)
 	napi_enable(&mp->napi);
 
 	oom = 0;
-	for (i = 0; i < 8; i++) {
-		if ((mp->rxq_mask & (1 << i)) == 0)
-			continue;
-
+	for (i = 0; i < mp->rxq_count; i++) {
 		err = rxq_init(mp, i);
 		if (err) {
 			while (--i >= 0)
-				if (mp->rxq_mask & (1 << i))
-					rxq_deinit(mp->rxq + i);
+				rxq_deinit(mp->rxq + i);
 			goto out;
 		}
 
@@ -2064,15 +2046,11 @@ static int mv643xx_eth_open(struct net_device *dev)
 		add_timer(&mp->rx_oom);
 	}
 
-	for (i = 0; i < 8; i++) {
-		if ((mp->txq_mask & (1 << i)) == 0)
-			continue;
-
+	for (i = 0; i < mp->txq_count; i++) {
 		err = txq_init(mp, i);
 		if (err) {
 			while (--i >= 0)
-				if (mp->txq_mask & (1 << i))
-					txq_deinit(mp->txq + i);
+				txq_deinit(mp->txq + i);
 			goto out_free;
 		}
 	}
@@ -2094,9 +2072,8 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 
 out_free:
-	for (i = 0; i < 8; i++)
-		if (mp->rxq_mask & (1 << i))
-			rxq_deinit(mp->rxq + i);
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_deinit(mp->rxq + i);
 out:
 	free_irq(dev->irq, dev);
 
@@ -2108,12 +2085,10 @@ static void port_reset(struct mv643xx_eth_private *mp)
 	unsigned int data;
 	int i;
 
-	for (i = 0; i < 8; i++) {
-		if (mp->rxq_mask & (1 << i))
-			rxq_disable(mp->rxq + i);
-		if (mp->txq_mask & (1 << i))
-			txq_disable(mp->txq + i);
-	}
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_disable(mp->rxq + i);
+	for (i = 0; i < mp->txq_count; i++)
+		txq_disable(mp->txq + i);
 
 	while (1) {
 		u32 ps = rdl(mp, PORT_STATUS(mp->port_num));
@@ -2151,12 +2126,10 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	port_reset(mp);
 	mib_counters_update(mp);
 
-	for (i = 0; i < 8; i++) {
-		if (mp->rxq_mask & (1 << i))
-			rxq_deinit(mp->rxq + i);
-		if (mp->txq_mask & (1 << i))
-			txq_deinit(mp->txq + i);
-	}
+	for (i = 0; i < mp->rxq_count; i++)
+		rxq_deinit(mp->rxq + i);
+	for (i = 0; i < mp->txq_count; i++)
+		txq_deinit(mp->txq + i);
 
 	return 0;
 }
@@ -2211,7 +2184,7 @@ static void tx_timeout_task(struct work_struct *ugly)
 		port_reset(mp);
 		port_start(mp);
 
-		__txq_maybe_wake(mp->txq + mp->txq_primary);
+		__txq_maybe_wake(mp->txq);
 	}
 }
 
@@ -2453,11 +2426,7 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->rx_desc_sram_addr = pd->rx_sram_addr;
 	mp->rx_desc_sram_size = pd->rx_sram_size;
 
-	if (pd->rx_queue_mask)
-		mp->rxq_mask = pd->rx_queue_mask;
-	else
-		mp->rxq_mask = 0x01;
-	mp->rxq_primary = fls(mp->rxq_mask) - 1;
+	mp->rxq_count = pd->rx_queue_count ? : 1;
 
 	mp->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
@@ -2465,11 +2434,7 @@ static void set_params(struct mv643xx_eth_private *mp,
 	mp->tx_desc_sram_addr = pd->tx_sram_addr;
 	mp->tx_desc_sram_size = pd->tx_sram_size;
 
-	if (pd->tx_queue_mask)
-		mp->txq_mask = pd->tx_queue_mask;
-	else
-		mp->txq_mask = 0x01;
-	mp->txq_primary = fls(mp->txq_mask) - 1;
+	mp->txq_count = pd->tx_queue_count ? : 1;
 }
 
 static int phy_detect(struct mv643xx_eth_private *mp)
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 1207857..eb78b00 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -49,10 +49,10 @@ struct mv643xx_eth_platform_data {
 	int			duplex;
 
 	/*
-	 * Which RX/TX queues to use.
+	 * How many RX/TX queues to use.
 	 */
-	int			rx_queue_mask;
-	int			tx_queue_mask;
+	int			rx_queue_count;
+	int			tx_queue_count;
 
 	/*
 	 * Override default RX/TX queue sizes if nonzero.
-- 
1.5.6.4

