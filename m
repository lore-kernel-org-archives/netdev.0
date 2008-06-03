From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 32/39] mv643xx_eth: allow multiple TX queues
Date: Tue,  3 Jun 2008 13:02:47 +0200
Message-ID: <1212490974-23719-33-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48749 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755380AbYFCMAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:36 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As with the multiple RX queue support, allow the platform code to
specify that the hardware we are running on supports multiple TX
queues.  This patch only uses the highest-numbered enabled queue
to send packets to for now, this can be extended later to enable
QoS and such.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c   |  146 ++++++++++++++++++++++++++++++-------------
 include/linux/mv643xx_eth.h |    3 +-
 2 files changed, 105 insertions(+), 44 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 267768c..fd9e492 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -94,16 +94,16 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define  INT_EXT_PHY			0x00010000
 #define  INT_EXT_TX_ERROR_0		0x00000100
 #define  INT_EXT_TX_0			0x00000001
-#define  INT_EXT_TX			0x00000101
+#define  INT_EXT_TX			0x0000ffff
 #define INT_MASK(p)			(0x0468 + ((p) << 10))
 #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
 #define RXQ_CURRENT_DESC_PTR(p, q)	(0x060c + ((p) << 10) + ((q) << 4))
 #define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
-#define TXQ_CURRENT_DESC_PTR(p)		(0x06c0 + ((p) << 10))
-#define TXQ_BW_TOKENS(p)		(0x0700 + ((p) << 10))
-#define TXQ_BW_CONF(p)			(0x0704 + ((p) << 10))
-#define TXQ_BW_WRR_CONF(p)		(0x0708 + ((p) << 10))
+#define TXQ_CURRENT_DESC_PTR(p, q)	(0x06c0 + ((p) << 10) + ((q) << 2))
+#define TXQ_BW_TOKENS(p, q)		(0x0700 + ((p) << 10) + ((q) << 4))
+#define TXQ_BW_CONF(p, q)		(0x0704 + ((p) << 10) + ((q) << 4))
+#define TXQ_BW_WRR_CONF(p, q)		(0x0708 + ((p) << 10) + ((q) << 4))
 #define MIB_COUNTERS(p)			(0x1000 + ((p) << 7))
 #define SPECIAL_MCAST_TABLE(p)		(0x1400 + ((p) << 10))
 #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
@@ -294,6 +294,8 @@ struct rx_queue {
 };
 
 struct tx_queue {
+	int index;
+
 	int tx_ring_size;
 
 	int tx_desc_count;
@@ -338,7 +340,9 @@ struct mv643xx_eth_private {
 	int default_tx_ring_size;
 	unsigned long tx_desc_sram_addr;
 	int tx_desc_sram_size;
-	struct tx_queue txq[1];
+	u8 txq_mask;
+	int txq_primary;
+	struct tx_queue txq[8];
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	int tx_clean_threshold;
 #endif
@@ -365,7 +369,7 @@ static struct mv643xx_eth_private *rxq_to_mep(struct rx_queue *rxq)
 
 static struct mv643xx_eth_private *txq_to_mep(struct tx_queue *txq)
 {
-	return container_of(txq, struct mv643xx_eth_private, txq[0]);
+	return container_of(txq, struct mv643xx_eth_private, txq[txq->index]);
 }
 
 static void rxq_enable(struct rx_queue *rxq)
@@ -387,13 +391,13 @@ static void rxq_disable(struct rx_queue *rxq)
 static void txq_enable(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mep = txq_to_mep(txq);
-	wrl(mep, TXQ_COMMAND(mep->port_num), 1);
+	wrl(mep, TXQ_COMMAND(mep->port_num), 1 << txq->index);
 }
 
 static void txq_disable(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mep = txq_to_mep(txq);
-	u8 mask = 1;
+	u8 mask = 1 << txq->index;
 
 	wrl(mep, TXQ_COMMAND(mep->port_num), mask << 8);
 	while (rdl(mep, TXQ_COMMAND(mep->port_num)) & mask)
@@ -404,6 +408,12 @@ static void __txq_maybe_wake(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mep = txq_to_mep(txq);
 
+	/*
+	 * netif_{stop,wake}_queue() flow control only applies to
+	 * the primary queue.
+	 */
+	BUG_ON(txq->index != mep->txq_primary);
+
 	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_DESCS_PER_SKB)
 		netif_wake_queue(mep->dev);
 }
@@ -575,8 +585,10 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	if (++mep->tx_clean_threshold > 5) {
-		txq_reclaim(mep->txq, 0);
 		mep->tx_clean_threshold = 0;
+		for (i = 0; i < 8; i++)
+			if (mep->txq_mask & (1 << i))
+				txq_reclaim(mep->txq + i, 0);
 	}
 #endif
 
@@ -736,8 +748,6 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct tx_queue *txq;
 	unsigned long flags;
 
-	BUG_ON(netif_queue_stopped(dev));
-
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
 		stats->tx_dropped++;
 		dev_printk(KERN_DEBUG, &dev->dev,
@@ -748,13 +758,15 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&mep->lock, flags);
 
-	txq = mep->txq;
+	txq = mep->txq + mep->txq_primary;
 
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB) {
-		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
-		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&mep->lock, flags);
-		return NETDEV_TX_BUSY;
+		if (txq->index == mep->txq_primary && net_ratelimit())
+			dev_printk(KERN_ERR, &dev->dev,
+				   "primary tx queue full?!\n");
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 
 	txq_submit_skb(txq, skb);
@@ -762,8 +774,13 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
-	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB)
-		netif_stop_queue(dev);
+	if (txq->index == mep->txq_primary) {
+		int entries_left;
+
+		entries_left = txq->tx_ring_size - txq->tx_desc_count;
+		if (entries_left < MAX_DESCS_PER_SKB)
+			netif_stop_queue(dev);
+	}
 
 	spin_unlock_irqrestore(&mep->lock, flags);
 
@@ -813,8 +830,8 @@ static void txq_set_rate(struct tx_queue *txq, int rate, int burst)
 	if (bucket_size > 65535)
 		bucket_size = 65535;
 
-	wrl(mep, TXQ_BW_TOKENS(mep->port_num), token_rate << 14);
-	wrl(mep, TXQ_BW_CONF(mep->port_num),
+	wrl(mep, TXQ_BW_TOKENS(mep->port_num, txq->index), token_rate << 14);
+	wrl(mep, TXQ_BW_CONF(mep->port_num, txq->index),
 			(bucket_size << 10) | token_rate);
 }
 
@@ -830,7 +847,7 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 	off = TXQ_FIX_PRIO_CONF(mep->port_num);
 
 	val = rdl(mep, off);
-	val |= 1;
+	val |= 1 << txq->index;
 	wrl(mep, off, val);
 }
 
@@ -846,13 +863,13 @@ static void txq_set_wrr(struct tx_queue *txq, int weight)
 	off = TXQ_FIX_PRIO_CONF(mep->port_num);
 
 	val = rdl(mep, off);
-	val &= ~1;
+	val &= ~(1 << txq->index);
 	wrl(mep, off, val);
 
 	/*
 	 * Configure WRR weight for this queue.
 	 */
-	off = TXQ_BW_WRR_CONF(mep->port_num);
+	off = TXQ_BW_WRR_CONF(mep->port_num, txq->index);
 
 	val = rdl(mep, off);
 	val = (val & ~0xff) | (weight & 0xff);
@@ -1396,13 +1413,15 @@ static void rxq_deinit(struct rx_queue *rxq)
 	kfree(rxq->rx_skb);
 }
 
-static int txq_init(struct mv643xx_eth_private *mep)
+static int txq_init(struct mv643xx_eth_private *mep, int index)
 {
-	struct tx_queue *txq = mep->txq;
+	struct tx_queue *txq = mep->txq + index;
 	struct tx_desc *tx_desc;
 	int size;
 	int i;
 
+	txq->index = index;
+
 	txq->tx_ring_size = mep->default_tx_ring_size;
 
 	txq->tx_desc_count = 0;
@@ -1411,7 +1430,7 @@ static int txq_init(struct mv643xx_eth_private *mep)
 
 	size = txq->tx_ring_size * sizeof(struct tx_desc);
 
-	if (size <= mep->tx_desc_sram_size) {
+	if (index == mep->txq_primary && size <= mep->tx_desc_sram_size) {
 		txq->tx_desc_area = ioremap(mep->tx_desc_sram_addr,
 						mep->tx_desc_sram_size);
 		txq->tx_desc_dma = mep->tx_desc_sram_addr;
@@ -1448,7 +1467,7 @@ static int txq_init(struct mv643xx_eth_private *mep)
 
 
 out_free:
-	if (size <= mep->tx_desc_sram_size)
+	if (index == mep->txq_primary && size <= mep->tx_desc_sram_size)
 		iounmap(txq->tx_desc_area);
 	else
 		dma_free_coherent(NULL, size,
@@ -1520,7 +1539,8 @@ static void txq_deinit(struct tx_queue *txq)
 
 	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
-	if (txq->tx_desc_area_size <= mep->tx_desc_sram_size)
+	if (txq->index == mep->txq_primary &&
+	    txq->tx_desc_area_size <= mep->tx_desc_sram_size)
 		iounmap(txq->tx_desc_area);
 	else
 		dma_free_coherent(NULL, txq->tx_desc_area_size,
@@ -1559,12 +1579,20 @@ static void update_pscr(struct mv643xx_eth_private *mep, int speed, int duplex)
 		if ((pscr_o & SERIAL_PORT_ENABLE) == 0)
 			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_n);
 		else {
-			txq_disable(mep->txq);
+			int i;
+
+			for (i = 0; i < 8; i++)
+				if (mep->txq_mask & (1 << i))
+					txq_disable(mep->txq + i);
+
 			pscr_o &= ~SERIAL_PORT_ENABLE;
 			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_o);
 			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_n);
 			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_n);
-			txq_enable(mep->txq);
+
+			for (i = 0; i < 8; i++)
+				if (mep->txq_mask & (1 << i))
+					txq_enable(mep->txq + i);
 		}
 	}
 }
@@ -1590,13 +1618,17 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
 		if (mii_link_ok(&mep->mii)) {
 			struct ethtool_cmd cmd;
+			int i;
 
 			mii_ethtool_gset(&mep->mii, &cmd);
 			update_pscr(mep, cmd.speed, cmd.duplex);
-			txq_enable(mep->txq);
+			for (i = 0; i < 8; i++)
+				if (mep->txq_mask & (1 << i))
+					txq_enable(mep->txq + i);
+
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
-				__txq_maybe_wake(mep->txq);
+				__txq_maybe_wake(mep->txq + mep->txq_primary);
 			}
 		} else if (netif_carrier_ok(dev)) {
 			netif_stop_queue(dev);
@@ -1624,9 +1656,17 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	}
 #endif
 
+	/*
+	 * TxBuffer or TxError set for any of the 8 queues?
+	 */
 	if (int_cause_ext & INT_EXT_TX) {
-		txq_reclaim(mep->txq, 0);
-		__txq_maybe_wake(mep->txq);
+		int i;
+
+		for (i = 0; i < 8; i++)
+			if (mep->txq_mask & (1 << i))
+				txq_reclaim(mep->txq + i, 0);
+
+		__txq_maybe_wake(mep->txq + mep->txq_primary);
 	}
 
 	return IRQ_HANDLED;
@@ -1677,11 +1717,14 @@ static void port_start(struct mv643xx_eth_private *mep)
 	 * Configure TX path and queues.
 	 */
 	tx_set_rate(mep, 1000000000, 16777216);
-	for (i = 0; i < 1; i++) {
-		struct tx_queue *txq = mep->txq;
-		int off = TXQ_CURRENT_DESC_PTR(mep->port_num);
+	for (i = 0; i < 8; i++) {
+		struct tx_queue *txq = mep->txq + i;
+		int off = TXQ_CURRENT_DESC_PTR(mep->port_num, i);
 		u32 addr;
 
+		if ((mep->txq_mask & (1 << i)) == 0)
+			continue;
+
 		addr = (u32)txq->tx_desc_dma;
 		addr += txq->tx_curr_desc * sizeof(struct tx_desc);
 		wrl(mep, off, addr);
@@ -1782,9 +1825,18 @@ static int mv643xx_eth_open(struct net_device *dev)
 		rxq_refill(mep->rxq + i);
 	}
 
-	err = txq_init(mep);
-	if (err)
-		goto out_free;
+	for (i = 0; i < 8; i++) {
+		if ((mep->txq_mask & (1 << i)) == 0)
+			continue;
+
+		err = txq_init(mep, i);
+		if (err) {
+			while (--i >= 0)
+				if (mep->txq_mask & (1 << i))
+					txq_deinit(mep->txq + i);
+			goto out_free;
+		}
+	}
 
 #ifdef MV643XX_ETH_NAPI
 	napi_enable(&mep->napi);
@@ -1821,8 +1873,9 @@ static void port_reset(struct mv643xx_eth_private *mep)
 	for (i = 0; i < 8; i++) {
 		if (mep->rxq_mask & (1 << i))
 			rxq_disable(mep->rxq + i);
+		if (mep->txq_mask & (1 << i))
+			txq_disable(mep->txq + i);
 	}
-	txq_disable(mep->txq);
 	while (!(rdl(mep, PORT_STATUS(mep->port_num)) & TX_FIFO_EMPTY))
 		udelay(10);
 
@@ -1856,8 +1909,9 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	for (i = 0; i < 8; i++) {
 		if (mep->rxq_mask & (1 << i))
 			rxq_deinit(mep->rxq + i);
+		if (mep->txq_mask & (1 << i))
+			txq_deinit(mep->txq + i);
 	}
-	txq_deinit(mep->txq);
 
 	return 0;
 }
@@ -1909,7 +1963,7 @@ static void tx_timeout_task(struct work_struct *ugly)
 		port_reset(mep);
 		port_start(mep);
 
-		__txq_maybe_wake(mep->txq);
+		__txq_maybe_wake(mep->txq + mep->txq_primary);
 	}
 }
 
@@ -2120,6 +2174,12 @@ static void set_params(struct mv643xx_eth_private *mep,
 		mep->default_tx_ring_size = pd->tx_queue_size;
 	mep->tx_desc_sram_addr = pd->tx_sram_addr;
 	mep->tx_desc_sram_size = pd->tx_sram_size;
+
+	if (pd->tx_queue_mask)
+		mep->txq_mask = pd->tx_queue_mask;
+	else
+		mep->txq_mask = 0x01;
+	mep->txq_primary = fls(mep->txq_mask) - 1;
 }
 
 static int phy_detect(struct mv643xx_eth_private *mep)
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 1afd7ba..1207857 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -49,9 +49,10 @@ struct mv643xx_eth_platform_data {
 	int			duplex;
 
 	/*
-	 * Which RX queues to use.
+	 * Which RX/TX queues to use.
 	 */
 	int			rx_queue_mask;
+	int			tx_queue_mask;
 
 	/*
 	 * Override default RX/TX queue sizes if nonzero.
-- 
1.5.3.4

