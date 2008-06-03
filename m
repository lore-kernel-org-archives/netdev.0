From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 31/39] mv643xx_eth: allow multiple RX queues
Date: Tue,  3 Jun 2008 13:02:46 +0200
Message-ID: <1212490974-23719-32-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48759 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755596AbYFCMAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:33 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the platform code to specify that we are running on hardware
that is capable of supporting multiple RX queues.  If this option
is used, initialise all of the given RX queues instead of just RX
queue zero.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c   |   99 ++++++++++++++++++++++++++++++++-----------
 include/linux/mv643xx_eth.h |    5 ++
 2 files changed, 79 insertions(+), 25 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 24426fc..267768c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -87,7 +87,7 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
-#define  INT_RX				0x00000804
+#define  INT_RX				0x0007fbfc
 #define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
 #define  INT_EXT_LINK			0x00100000
@@ -98,7 +98,7 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define INT_MASK(p)			(0x0468 + ((p) << 10))
 #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
-#define RXQ_CURRENT_DESC_PTR(p)		(0x060c + ((p) << 10))
+#define RXQ_CURRENT_DESC_PTR(p, q)	(0x060c + ((p) << 10) + ((q) << 4))
 #define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
 #define TXQ_CURRENT_DESC_PTR(p)		(0x06c0 + ((p) << 10))
 #define TXQ_BW_TOKENS(p)		(0x0700 + ((p) << 10))
@@ -277,6 +277,8 @@ struct mib_counters {
 };
 
 struct rx_queue {
+	int index;
+
 	int rx_ring_size;
 
 	int rx_desc_count;
@@ -325,8 +327,10 @@ struct mv643xx_eth_private {
 	int default_rx_ring_size;
 	unsigned long rx_desc_sram_addr;
 	int rx_desc_sram_size;
+	u8 rxq_mask;
+	int rxq_primary;
 	struct napi_struct napi;
-	struct rx_queue rxq[1];
+	struct rx_queue rxq[8];
 
 	/*
 	 * TX state.
@@ -356,7 +360,7 @@ static inline void wrl(struct mv643xx_eth_private *mep, int offset, u32 data)
 /* rxq/txq helper functions *************************************************/
 static struct mv643xx_eth_private *rxq_to_mep(struct rx_queue *rxq)
 {
-	return container_of(rxq, struct mv643xx_eth_private, rxq[0]);
+	return container_of(rxq, struct mv643xx_eth_private, rxq[rxq->index]);
 }
 
 static struct mv643xx_eth_private *txq_to_mep(struct tx_queue *txq)
@@ -367,13 +371,13 @@ static struct mv643xx_eth_private *txq_to_mep(struct tx_queue *txq)
 static void rxq_enable(struct rx_queue *rxq)
 {
 	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
-	wrl(mep, RXQ_COMMAND(mep->port_num), 1);
+	wrl(mep, RXQ_COMMAND(mep->port_num), 1 << rxq->index);
 }
 
 static void rxq_disable(struct rx_queue *rxq)
 {
 	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
-	u8 mask = 1;
+	u8 mask = 1 << rxq->index;
 
 	wrl(mep, RXQ_COMMAND(mep->port_num), mask << 8);
 	while (rdl(mep, RXQ_COMMAND(mep->port_num)) & mask)
@@ -565,6 +569,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
 	struct mv643xx_eth_private *mep;
 	int rx;
+	int i;
 
 	mep = container_of(napi, struct mv643xx_eth_private, napi);
 
@@ -575,7 +580,10 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 	}
 #endif
 
-	rx = rxq_process(mep->rxq, budget);
+	rx = 0;
+	for (i = 7; rx < budget && i >= 0; i--)
+		if (mep->rxq_mask & (1 << i))
+			rx += rxq_process(mep->rxq + i, budget - rx);
 
 	if (rx < budget) {
 		netif_rx_complete(mep->dev, napi);
@@ -1287,13 +1295,15 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 
 
 /* rx/tx queue initialisation ***********************************************/
-static int rxq_init(struct mv643xx_eth_private *mep)
+static int rxq_init(struct mv643xx_eth_private *mep, int index)
 {
-	struct rx_queue *rxq = mep->rxq;
+	struct rx_queue *rxq = mep->rxq + index;
 	struct rx_desc *rx_desc;
 	int size;
 	int i;
 
+	rxq->index = index;
+
 	rxq->rx_ring_size = mep->default_rx_ring_size;
 
 	rxq->rx_desc_count = 0;
@@ -1302,7 +1312,7 @@ static int rxq_init(struct mv643xx_eth_private *mep)
 
 	size = rxq->rx_ring_size * sizeof(struct rx_desc);
 
-	if (size <= mep->rx_desc_sram_size) {
+	if (index == mep->rxq_primary && size <= mep->rx_desc_sram_size) {
 		rxq->rx_desc_area = ioremap(mep->rx_desc_sram_addr,
 						mep->rx_desc_sram_size);
 		rxq->rx_desc_dma = mep->rx_desc_sram_addr;
@@ -1343,7 +1353,7 @@ static int rxq_init(struct mv643xx_eth_private *mep)
 
 
 out_free:
-	if (size <= mep->rx_desc_sram_size)
+	if (index == mep->rxq_primary && size <= mep->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
 		dma_free_coherent(NULL, size,
@@ -1376,7 +1386,8 @@ static void rxq_deinit(struct rx_queue *rxq)
 			   rxq->rx_desc_count);
 	}
 
-	if (rxq->rx_desc_area_size <= mep->rx_desc_sram_size)
+	if (rxq->index == mep->rxq_primary &&
+	    rxq->rx_desc_area_size <= mep->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
 		dma_free_coherent(NULL, rxq->rx_desc_area_size,
@@ -1593,6 +1604,9 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		}
 	}
 
+	/*
+	 * RxBuffer or RxError set for any of the 8 queues?
+	 */
 #ifdef MV643XX_ETH_NAPI
 	if (int_cause & INT_RX) {
 		wrl(mep, INT_MASK(mep->port_num), 0x00000000);
@@ -1601,8 +1615,13 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		netif_rx_schedule(dev, &mep->napi);
 	}
 #else
-	if (int_cause & INT_RX)
-		rxq_process(mep->rxq, INT_MAX);
+	if (int_cause & INT_RX) {
+		int i;
+
+		for (i = 7; i >= 0; i--)
+			if (mep->rxq_mask & (1 << i))
+				rxq_process(mep->rxq + i, INT_MAX);
+	}
 #endif
 
 	if (int_cause_ext & INT_EXT_TX) {
@@ -1688,13 +1707,16 @@ static void port_start(struct mv643xx_eth_private *mep)
 	wrl(mep, PORT_CONFIG_EXT(mep->port_num), 0x00000000);
 
 	/*
-	 * Enable the receive queue.
+	 * Enable the receive queues.
 	 */
-	for (i = 0; i < 1; i++) {
-		struct rx_queue *rxq = mep->rxq;
-		int off = RXQ_CURRENT_DESC_PTR(mep->port_num);
+	for (i = 0; i < 8; i++) {
+		struct rx_queue *rxq = mep->rxq + i;
+		int off = RXQ_CURRENT_DESC_PTR(mep->port_num, i);
 		u32 addr;
 
+		if ((mep->rxq_mask & (1 << i)) == 0)
+			continue;
+
 		addr = (u32)rxq->rx_desc_dma;
 		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
 		wrl(mep, off, addr);
@@ -1729,6 +1751,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int err;
+	int i;
 
 	wrl(mep, INT_CAUSE(mep->port_num), 0);
 	wrl(mep, INT_CAUSE_EXT(mep->port_num), 0);
@@ -1744,10 +1767,20 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	init_mac_tables(mep);
 
-	err = rxq_init(mep);
-	if (err)
-		goto out;
-	rxq_refill(mep->rxq);
+	for (i = 0; i < 8; i++) {
+		if ((mep->rxq_mask & (1 << i)) == 0)
+			continue;
+
+		err = rxq_init(mep, i);
+		if (err) {
+			while (--i >= 0)
+				if (mep->rxq_mask & (1 << i))
+					rxq_deinit(mep->rxq + i);
+			goto out;
+		}
+
+		rxq_refill(mep->rxq + i);
+	}
 
 	err = txq_init(mep);
 	if (err)
@@ -1771,7 +1804,9 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 
 out_free:
-	rxq_deinit(mep->rxq);
+	for (i = 0; i < 8; i++)
+		if (mep->rxq_mask & (1 << i))
+			rxq_deinit(mep->rxq + i);
 out:
 	free_irq(dev->irq, dev);
 
@@ -1781,9 +1816,13 @@ out:
 static void port_reset(struct mv643xx_eth_private *mep)
 {
 	unsigned int data;
+	int i;
 
+	for (i = 0; i < 8; i++) {
+		if (mep->rxq_mask & (1 << i))
+			rxq_disable(mep->rxq + i);
+	}
 	txq_disable(mep->txq);
-	rxq_disable(mep->rxq);
 	while (!(rdl(mep, PORT_STATUS(mep->port_num)) & TX_FIFO_EMPTY))
 		udelay(10);
 
@@ -1798,6 +1837,7 @@ static void port_reset(struct mv643xx_eth_private *mep)
 static int mv643xx_eth_stop(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	int i;
 
 	wrl(mep, INT_MASK(mep->port_num), 0x00000000);
 	rdl(mep, INT_MASK(mep->port_num));
@@ -1813,8 +1853,11 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	port_reset(mep);
 	mib_counters_update(mep);
 
+	for (i = 0; i < 8; i++) {
+		if (mep->rxq_mask & (1 << i))
+			rxq_deinit(mep->rxq + i);
+	}
 	txq_deinit(mep->txq);
-	rxq_deinit(mep->rxq);
 
 	return 0;
 }
@@ -2066,6 +2109,12 @@ static void set_params(struct mv643xx_eth_private *mep,
 	mep->rx_desc_sram_addr = pd->rx_sram_addr;
 	mep->rx_desc_sram_size = pd->rx_sram_size;
 
+	if (pd->rx_queue_mask)
+		mep->rxq_mask = pd->rx_queue_mask;
+	else
+		mep->rxq_mask = 0x01;
+	mep->rxq_primary = fls(mep->rxq_mask) - 1;
+
 	mep->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
 		mep->default_tx_ring_size = pd->tx_queue_size;
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 6461776..1afd7ba 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -49,6 +49,11 @@ struct mv643xx_eth_platform_data {
 	int			duplex;
 
 	/*
+	 * Which RX queues to use.
+	 */
+	int			rx_queue_mask;
+
+	/*
 	 * Override default RX/TX queue sizes if nonzero.
 	 */
 	int			rx_queue_size;
-- 
1.5.3.4

