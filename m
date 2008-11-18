From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/6] mv643xx_eth: introduce per-port register area pointer
Date: Tue, 18 Nov 2008 23:29:01 +0100
Message-ID: <20081118222859.GT5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53428 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbYKRW3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:29:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth driver uses the rdl()/wrl() macros to read and
write hardware registers.  Per-port registers are accessed in the
following way:

	#define PORT_STATUS(p)			(0x0444 + ((p) << 10))

	[...]

	static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
	{
		return readl(mp->shared->base + offset);
	}

	[...]

	port_status = rdl(mp, PORT_STATUS(mp->port_num));

By giving the per-port 'struct mv643xx_eth_private' its own
'void __iomem *base' pointer that points to the per-port register
area, we can get rid of both the double indirection and the << 10
that is done for every per-port register access -- this patch does
that.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  230 ++++++++++++++++++++++++---------------------
 1 files changed, 121 insertions(+), 109 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1d54ba3..0f73d85 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -78,16 +78,17 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define WINDOW_PROTECT(w)		(0x0294 + ((w) << 4))
 
 /*
- * Per-port registers.
+ * Main per-port registers.  These live at offset 0x0400 for
+ * port #0, 0x0800 for port #1, and 0x0c00 for port #2.
  */
-#define PORT_CONFIG(p)			(0x0400 + ((p) << 10))
+#define PORT_CONFIG			0x0000
 #define  UNICAST_PROMISCUOUS_MODE	0x00000001
-#define PORT_CONFIG_EXT(p)		(0x0404 + ((p) << 10))
-#define MAC_ADDR_LOW(p)			(0x0414 + ((p) << 10))
-#define MAC_ADDR_HIGH(p)		(0x0418 + ((p) << 10))
-#define SDMA_CONFIG(p)			(0x041c + ((p) << 10))
-#define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
-#define PORT_STATUS(p)			(0x0444 + ((p) << 10))
+#define PORT_CONFIG_EXT			0x0004
+#define MAC_ADDR_LOW			0x0014
+#define MAC_ADDR_HIGH			0x0018
+#define SDMA_CONFIG			0x001c
+#define PORT_SERIAL_CONTROL		0x003c
+#define PORT_STATUS			0x0044
 #define  TX_FIFO_EMPTY			0x00000400
 #define  TX_IN_PROGRESS			0x00000080
 #define  PORT_SPEED_MASK		0x00000030
@@ -97,31 +98,35 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define  FLOW_CONTROL_ENABLED		0x00000008
 #define  FULL_DUPLEX			0x00000004
 #define  LINK_UP			0x00000002
-#define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
-#define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
-#define TX_BW_RATE(p)			(0x0450 + ((p) << 10))
-#define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
-#define TX_BW_BURST(p)			(0x045c + ((p) << 10))
-#define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define TXQ_COMMAND			0x0048
+#define TXQ_FIX_PRIO_CONF		0x004c
+#define TX_BW_RATE			0x0050
+#define TX_BW_MTU			0x0058
+#define TX_BW_BURST			0x005c
+#define INT_CAUSE			0x0060
 #define  INT_TX_END			0x07f80000
 #define  INT_RX				0x000003fc
 #define  INT_EXT			0x00000002
-#define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
+#define INT_CAUSE_EXT			0x0064
 #define  INT_EXT_LINK_PHY		0x00110000
 #define  INT_EXT_TX			0x000000ff
-#define INT_MASK(p)			(0x0468 + ((p) << 10))
-#define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
-#define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
-#define TXQ_FIX_PRIO_CONF_MOVED(p)	(0x04dc + ((p) << 10))
-#define TX_BW_RATE_MOVED(p)		(0x04e0 + ((p) << 10))
-#define TX_BW_MTU_MOVED(p)		(0x04e8 + ((p) << 10))
-#define TX_BW_BURST_MOVED(p)		(0x04ec + ((p) << 10))
-#define RXQ_CURRENT_DESC_PTR(p, q)	(0x060c + ((p) << 10) + ((q) << 4))
-#define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
-#define TXQ_CURRENT_DESC_PTR(p, q)	(0x06c0 + ((p) << 10) + ((q) << 2))
-#define TXQ_BW_TOKENS(p, q)		(0x0700 + ((p) << 10) + ((q) << 4))
-#define TXQ_BW_CONF(p, q)		(0x0704 + ((p) << 10) + ((q) << 4))
-#define TXQ_BW_WRR_CONF(p, q)		(0x0708 + ((p) << 10) + ((q) << 4))
+#define INT_MASK			0x0068
+#define INT_MASK_EXT			0x006c
+#define TX_FIFO_URGENT_THRESHOLD	0x0074
+#define TXQ_FIX_PRIO_CONF_MOVED		0x00dc
+#define TX_BW_RATE_MOVED		0x00e0
+#define TX_BW_MTU_MOVED			0x00e8
+#define TX_BW_BURST_MOVED		0x00ec
+#define RXQ_CURRENT_DESC_PTR(q)		(0x020c + ((q) << 4))
+#define RXQ_COMMAND			0x0280
+#define TXQ_CURRENT_DESC_PTR(q)		(0x02c0 + ((q) << 2))
+#define TXQ_BW_TOKENS(q)		(0x0300 + ((q) << 4))
+#define TXQ_BW_CONF(q)			(0x0304 + ((q) << 4))
+#define TXQ_BW_WRR_CONF(q)		(0x0308 + ((q) << 4))
+
+/*
+ * Misc per-port registers.
+ */
 #define MIB_COUNTERS(p)			(0x1000 + ((p) << 7))
 #define SPECIAL_MCAST_TABLE(p)		(0x1400 + ((p) << 10))
 #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
@@ -351,6 +356,7 @@ struct tx_queue {
 
 struct mv643xx_eth_private {
 	struct mv643xx_eth_shared_private *shared;
+	void __iomem *base;
 	int port_num;
 
 	struct net_device *dev;
@@ -401,11 +407,21 @@ static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
 	return readl(mp->shared->base + offset);
 }
 
+static inline u32 rdlp(struct mv643xx_eth_private *mp, int offset)
+{
+	return readl(mp->base + offset);
+}
+
 static inline void wrl(struct mv643xx_eth_private *mp, int offset, u32 data)
 {
 	writel(data, mp->shared->base + offset);
 }
 
+static inline void wrlp(struct mv643xx_eth_private *mp, int offset, u32 data)
+{
+	writel(data, mp->base + offset);
+}
+
 
 /* rxq/txq helper functions *************************************************/
 static struct mv643xx_eth_private *rxq_to_mp(struct rx_queue *rxq)
@@ -421,7 +437,7 @@ static struct mv643xx_eth_private *txq_to_mp(struct tx_queue *txq)
 static void rxq_enable(struct rx_queue *rxq)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
-	wrl(mp, RXQ_COMMAND(mp->port_num), 1 << rxq->index);
+	wrlp(mp, RXQ_COMMAND, 1 << rxq->index);
 }
 
 static void rxq_disable(struct rx_queue *rxq)
@@ -429,26 +445,25 @@ static void rxq_disable(struct rx_queue *rxq)
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
 	u8 mask = 1 << rxq->index;
 
-	wrl(mp, RXQ_COMMAND(mp->port_num), mask << 8);
-	while (rdl(mp, RXQ_COMMAND(mp->port_num)) & mask)
+	wrlp(mp, RXQ_COMMAND, mask << 8);
+	while (rdlp(mp, RXQ_COMMAND) & mask)
 		udelay(10);
 }
 
 static void txq_reset_hw_ptr(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-	int off = TXQ_CURRENT_DESC_PTR(mp->port_num, txq->index);
 	u32 addr;
 
 	addr = (u32)txq->tx_desc_dma;
 	addr += txq->tx_curr_desc * sizeof(struct tx_desc);
-	wrl(mp, off, addr);
+	wrlp(mp, TXQ_CURRENT_DESC_PTR(txq->index), addr);
 }
 
 static void txq_enable(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-	wrl(mp, TXQ_COMMAND(mp->port_num), 1 << txq->index);
+	wrlp(mp, TXQ_COMMAND, 1 << txq->index);
 }
 
 static void txq_disable(struct tx_queue *txq)
@@ -456,8 +471,8 @@ static void txq_disable(struct tx_queue *txq)
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	u8 mask = 1 << txq->index;
 
-	wrl(mp, TXQ_COMMAND(mp->port_num), mask << 8);
-	while (rdl(mp, TXQ_COMMAND(mp->port_num)) & mask)
+	wrlp(mp, TXQ_COMMAND, mask << 8);
+	while (rdlp(mp, TXQ_COMMAND) & mask)
 		udelay(10);
 }
 
@@ -829,10 +844,10 @@ static void txq_kick(struct tx_queue *txq)
 
 	__netif_tx_lock(nq, smp_processor_id());
 
-	if (rdl(mp, TXQ_COMMAND(mp->port_num)) & (1 << txq->index))
+	if (rdlp(mp, TXQ_COMMAND) & (1 << txq->index))
 		goto out;
 
-	hw_desc_ptr = rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, txq->index));
+	hw_desc_ptr = rdlp(mp, TXQ_CURRENT_DESC_PTR(txq->index));
 	expected_ptr = (u32)txq->tx_desc_dma +
 				txq->tx_curr_desc * sizeof(struct tx_desc);
 
@@ -938,14 +953,14 @@ static void tx_set_rate(struct mv643xx_eth_private *mp, int rate, int burst)
 
 	switch (mp->shared->tx_bw_control) {
 	case TX_BW_CONTROL_OLD_LAYOUT:
-		wrl(mp, TX_BW_RATE(mp->port_num), token_rate);
-		wrl(mp, TX_BW_MTU(mp->port_num), mtu);
-		wrl(mp, TX_BW_BURST(mp->port_num), bucket_size);
+		wrlp(mp, TX_BW_RATE, token_rate);
+		wrlp(mp, TX_BW_MTU, mtu);
+		wrlp(mp, TX_BW_BURST, bucket_size);
 		break;
 	case TX_BW_CONTROL_NEW_LAYOUT:
-		wrl(mp, TX_BW_RATE_MOVED(mp->port_num), token_rate);
-		wrl(mp, TX_BW_MTU_MOVED(mp->port_num), mtu);
-		wrl(mp, TX_BW_BURST_MOVED(mp->port_num), bucket_size);
+		wrlp(mp, TX_BW_RATE_MOVED, token_rate);
+		wrlp(mp, TX_BW_MTU_MOVED, mtu);
+		wrlp(mp, TX_BW_BURST_MOVED, bucket_size);
 		break;
 	}
 }
@@ -964,9 +979,8 @@ static void txq_set_rate(struct tx_queue *txq, int rate, int burst)
 	if (bucket_size > 65535)
 		bucket_size = 65535;
 
-	wrl(mp, TXQ_BW_TOKENS(mp->port_num, txq->index), token_rate << 14);
-	wrl(mp, TXQ_BW_CONF(mp->port_num, txq->index),
-			(bucket_size << 10) | token_rate);
+	wrlp(mp, TXQ_BW_TOKENS(txq->index), token_rate << 14);
+	wrlp(mp, TXQ_BW_CONF(txq->index), (bucket_size << 10) | token_rate);
 }
 
 static void txq_set_fixed_prio_mode(struct tx_queue *txq)
@@ -981,17 +995,17 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 	off = 0;
 	switch (mp->shared->tx_bw_control) {
 	case TX_BW_CONTROL_OLD_LAYOUT:
-		off = TXQ_FIX_PRIO_CONF(mp->port_num);
+		off = TXQ_FIX_PRIO_CONF;
 		break;
 	case TX_BW_CONTROL_NEW_LAYOUT:
-		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+		off = TXQ_FIX_PRIO_CONF_MOVED;
 		break;
 	}
 
 	if (off) {
-		val = rdl(mp, off);
+		val = rdlp(mp, off);
 		val |= 1 << txq->index;
-		wrl(mp, off, val);
+		wrlp(mp, off, val);
 	}
 }
 
@@ -1007,26 +1021,25 @@ static void txq_set_wrr(struct tx_queue *txq, int weight)
 	off = 0;
 	switch (mp->shared->tx_bw_control) {
 	case TX_BW_CONTROL_OLD_LAYOUT:
-		off = TXQ_FIX_PRIO_CONF(mp->port_num);
+		off = TXQ_FIX_PRIO_CONF;
 		break;
 	case TX_BW_CONTROL_NEW_LAYOUT:
-		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+		off = TXQ_FIX_PRIO_CONF_MOVED;
 		break;
 	}
 
 	if (off) {
-		val = rdl(mp, off);
+		val = rdlp(mp, off);
 		val &= ~(1 << txq->index);
-		wrl(mp, off, val);
+		wrlp(mp, off, val);
 
 		/*
 		 * Configure WRR weight for this queue.
 		 */
-		off = TXQ_BW_WRR_CONF(mp->port_num, txq->index);
 
-		val = rdl(mp, off);
+		val = rdlp(mp, off);
 		val = (val & ~0xff) | (weight & 0xff);
-		wrl(mp, off, val);
+		wrlp(mp, TXQ_BW_WRR_CONF(txq->index), val);
 	}
 }
 
@@ -1294,7 +1307,7 @@ mv643xx_eth_get_settings_phyless(struct net_device *dev,
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 port_status;
 
-	port_status = rdl(mp, PORT_STATUS(mp->port_num));
+	port_status = rdlp(mp, PORT_STATUS);
 
 	cmd->supported = SUPPORTED_MII;
 	cmd->advertising = ADVERTISED_MII;
@@ -1449,8 +1462,8 @@ static void uc_addr_get(struct mv643xx_eth_private *mp, unsigned char *addr)
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = rdl(mp, MAC_ADDR_HIGH(mp->port_num));
-	mac_l = rdl(mp, MAC_ADDR_LOW(mp->port_num));
+	mac_h = rdlp(mp, MAC_ADDR_HIGH);
+	mac_l = rdlp(mp, MAC_ADDR_LOW);
 
 	addr[0] = (mac_h >> 24) & 0xff;
 	addr[1] = (mac_h >> 16) & 0xff;
@@ -1493,8 +1506,8 @@ static void uc_addr_set(struct mv643xx_eth_private *mp, unsigned char *addr)
 	mac_l = (addr[4] << 8) | addr[5];
 	mac_h = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3];
 
-	wrl(mp, MAC_ADDR_LOW(mp->port_num), mac_l);
-	wrl(mp, MAC_ADDR_HIGH(mp->port_num), mac_h);
+	wrlp(mp, MAC_ADDR_LOW, mac_l);
+	wrlp(mp, MAC_ADDR_HIGH, mac_h);
 
 	table = UNICAST_TABLE(mp->port_num);
 	set_filter_table_entry(mp, table, addr[5] & 0x0f);
@@ -1538,12 +1551,12 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 	struct dev_addr_list *addr;
 	int i;
 
-	port_config = rdl(mp, PORT_CONFIG(mp->port_num));
+	port_config = rdlp(mp, PORT_CONFIG);
 	if (dev->flags & IFF_PROMISC)
 		port_config |= UNICAST_PROMISCUOUS_MODE;
 	else
 		port_config &= ~UNICAST_PROMISCUOUS_MODE;
-	wrl(mp, PORT_CONFIG(mp->port_num), port_config);
+	wrlp(mp, PORT_CONFIG, port_config);
 
 	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
 		int port_num = mp->port_num;
@@ -1761,26 +1774,25 @@ static int mv643xx_eth_collect_events(struct mv643xx_eth_private *mp)
 	u32 int_cause;
 	u32 int_cause_ext;
 
-	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
-			(INT_TX_END | INT_RX | INT_EXT);
+	int_cause = rdlp(mp, INT_CAUSE) & (INT_TX_END | INT_RX | INT_EXT);
 	if (int_cause == 0)
 		return 0;
 
 	int_cause_ext = 0;
 	if (int_cause & INT_EXT)
-		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num));
+		int_cause_ext = rdlp(mp, INT_CAUSE_EXT);
 
 	int_cause &= INT_TX_END | INT_RX;
 	if (int_cause) {
-		wrl(mp, INT_CAUSE(mp->port_num), ~int_cause);
+		wrlp(mp, INT_CAUSE, ~int_cause);
 		mp->work_tx_end |= ((int_cause & INT_TX_END) >> 19) &
-				~(rdl(mp, TXQ_COMMAND(mp->port_num)) & 0xff);
+				~(rdlp(mp, TXQ_COMMAND) & 0xff);
 		mp->work_rx |= (int_cause & INT_RX) >> 2;
 	}
 
 	int_cause_ext &= INT_EXT_LINK_PHY | INT_EXT_TX;
 	if (int_cause_ext) {
-		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
+		wrlp(mp, INT_CAUSE_EXT, ~int_cause_ext);
 		if (int_cause_ext & INT_EXT_LINK_PHY)
 			mp->work_link = 1;
 		mp->work_tx |= int_cause_ext & INT_EXT_TX;
@@ -1797,7 +1809,7 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	if (unlikely(!mv643xx_eth_collect_events(mp)))
 		return IRQ_NONE;
 
-	wrl(mp, INT_MASK(mp->port_num), 0);
+	wrlp(mp, INT_MASK, 0);
 	napi_schedule(&mp->napi);
 
 	return IRQ_HANDLED;
@@ -1811,7 +1823,7 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 	int duplex;
 	int fc;
 
-	port_status = rdl(mp, PORT_STATUS(mp->port_num));
+	port_status = rdlp(mp, PORT_STATUS);
 	if (!(port_status & LINK_UP)) {
 		if (netif_carrier_ok(dev)) {
 			int i;
@@ -1911,7 +1923,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		if (mp->work_rx_oom)
 			mod_timer(&mp->rx_oom, jiffies + (HZ / 10));
 		napi_complete(napi);
-		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+		wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
 	}
 
 	return work_done;
@@ -1960,17 +1972,17 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Configure basic link parameters.
 	 */
-	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	pscr = rdlp(mp, PORT_SERIAL_CONTROL);
 
 	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
 	pscr |= DO_NOT_FORCE_LINK_FAIL;
 	if (mp->phy == NULL)
 		pscr |= FORCE_LINK_PASS;
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 
-	wrl(mp, SDMA_CONFIG(mp->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
+	wrlp(mp, SDMA_CONFIG, PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/*
 	 * Configure TX path and queues.
@@ -1994,24 +2006,23 @@ static void port_start(struct mv643xx_eth_private *mp)
 	 * frames to RX queue #0, and include the pseudo-header when
 	 * calculating receive checksums.
 	 */
-	wrl(mp, PORT_CONFIG(mp->port_num), 0x02000000);
+	wrlp(mp, PORT_CONFIG, 0x02000000);
 
 	/*
 	 * Treat BPDUs as normal multicasts, and disable partition mode.
 	 */
-	wrl(mp, PORT_CONFIG_EXT(mp->port_num), 0x00000000);
+	wrlp(mp, PORT_CONFIG_EXT, 0x00000000);
 
 	/*
 	 * Enable the receive queues.
 	 */
 	for (i = 0; i < mp->rxq_count; i++) {
 		struct rx_queue *rxq = mp->rxq + i;
-		int off = RXQ_CURRENT_DESC_PTR(mp->port_num, i);
 		u32 addr;
 
 		addr = (u32)rxq->rx_desc_dma;
 		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
-		wrl(mp, off, addr);
+		wrlp(mp, RXQ_CURRENT_DESC_PTR(i), addr);
 
 		rxq_enable(rxq);
 	}
@@ -2022,7 +2033,7 @@ static void set_rx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
 	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 	u32 val;
 
-	val = rdl(mp, SDMA_CONFIG(mp->port_num));
+	val = rdlp(mp, SDMA_CONFIG);
 	if (mp->shared->extended_rx_coal_limit) {
 		if (coal > 0xffff)
 			coal = 0xffff;
@@ -2035,7 +2046,7 @@ static void set_rx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
 		val &= ~0x003fff00;
 		val |= (coal & 0x3fff) << 8;
 	}
-	wrl(mp, SDMA_CONFIG(mp->port_num), val);
+	wrlp(mp, SDMA_CONFIG, val);
 }
 
 static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
@@ -2044,7 +2055,7 @@ static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
 
 	if (coal > 0x3fff)
 		coal = 0x3fff;
-	wrl(mp, TX_FIFO_URGENT_THRESHOLD(mp->port_num), (coal & 0x3fff) << 4);
+	wrlp(mp, TX_FIFO_URGENT_THRESHOLD, (coal & 0x3fff) << 4);
 }
 
 static void mv643xx_eth_recalc_skb_size(struct mv643xx_eth_private *mp)
@@ -2073,9 +2084,9 @@ static int mv643xx_eth_open(struct net_device *dev)
 	int err;
 	int i;
 
-	wrl(mp, INT_CAUSE(mp->port_num), 0);
-	wrl(mp, INT_CAUSE_EXT(mp->port_num), 0);
-	rdl(mp, INT_CAUSE_EXT(mp->port_num));
+	wrlp(mp, INT_CAUSE, 0);
+	wrlp(mp, INT_CAUSE_EXT, 0);
+	rdlp(mp, INT_CAUSE_EXT);
 
 	err = request_irq(dev->irq, mv643xx_eth_irq,
 			  IRQF_SHARED, dev->name, dev);
@@ -2124,8 +2135,8 @@ static int mv643xx_eth_open(struct net_device *dev)
 	set_rx_coal(mp, 0);
 	set_tx_coal(mp, 0);
 
-	wrl(mp, INT_MASK_EXT(mp->port_num), INT_EXT_LINK_PHY | INT_EXT_TX);
-	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+	wrlp(mp, INT_MASK_EXT, INT_EXT_LINK_PHY | INT_EXT_TX);
+	wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
 
 	return 0;
 
@@ -2150,7 +2161,7 @@ static void port_reset(struct mv643xx_eth_private *mp)
 		txq_disable(mp->txq + i);
 
 	while (1) {
-		u32 ps = rdl(mp, PORT_STATUS(mp->port_num));
+		u32 ps = rdlp(mp, PORT_STATUS);
 
 		if ((ps & (TX_IN_PROGRESS | TX_FIFO_EMPTY)) == TX_FIFO_EMPTY)
 			break;
@@ -2158,11 +2169,11 @@ static void port_reset(struct mv643xx_eth_private *mp)
 	}
 
 	/* Reset the Enable bit in the Configuration Register */
-	data = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	data = rdlp(mp, PORT_SERIAL_CONTROL);
 	data &= ~(SERIAL_PORT_ENABLE		|
 		  DO_NOT_FORCE_LINK_FAIL	|
 		  FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), data);
+	wrlp(mp, PORT_SERIAL_CONTROL, data);
 }
 
 static int mv643xx_eth_stop(struct net_device *dev)
@@ -2170,8 +2181,8 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
-	wrl(mp, INT_MASK(mp->port_num), 0x00000000);
-	rdl(mp, INT_MASK(mp->port_num));
+	wrlp(mp, INT_MASK, 0x00000000);
+	rdlp(mp, INT_MASK);
 
 	del_timer_sync(&mp->mib_counters_timer);
 
@@ -2264,12 +2275,12 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	wrl(mp, INT_MASK(mp->port_num), 0x00000000);
-	rdl(mp, INT_MASK(mp->port_num));
+	wrlp(mp, INT_MASK, 0x00000000);
+	rdlp(mp, INT_MASK);
 
 	mv643xx_eth_irq(dev->irq, dev);
 
-	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+	wrlp(mp, INT_MASK, INT_TX_END | INT_RX | INT_EXT);
 }
 #endif
 
@@ -2317,8 +2328,8 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	 * [21:8], or a 16-bit coal limit in bits [25,21:7] of the
 	 * SDMA config register.
 	 */
-	writel(0x02000000, msp->base + SDMA_CONFIG(0));
-	if (readl(msp->base + SDMA_CONFIG(0)) & 0x02000000)
+	writel(0x02000000, msp->base + 0x0400 + SDMA_CONFIG);
+	if (readl(msp->base + 0x0400 + SDMA_CONFIG) & 0x02000000)
 		msp->extended_rx_coal_limit = 1;
 	else
 		msp->extended_rx_coal_limit = 0;
@@ -2328,12 +2339,12 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	 * yes, whether its associated registers are in the old or
 	 * the new place.
 	 */
-	writel(1, msp->base + TX_BW_MTU_MOVED(0));
-	if (readl(msp->base + TX_BW_MTU_MOVED(0)) & 1) {
+	writel(1, msp->base + 0x0400 + TX_BW_MTU_MOVED);
+	if (readl(msp->base + 0x0400 + TX_BW_MTU_MOVED) & 1) {
 		msp->tx_bw_control = TX_BW_CONTROL_NEW_LAYOUT;
 	} else {
-		writel(7, msp->base + TX_BW_RATE(0));
-		if (readl(msp->base + TX_BW_RATE(0)) & 7)
+		writel(7, msp->base + 0x0400 + TX_BW_RATE);
+		if (readl(msp->base + 0x0400 + TX_BW_RATE) & 7)
 			msp->tx_bw_control = TX_BW_CONTROL_OLD_LAYOUT;
 		else
 			msp->tx_bw_control = TX_BW_CONTROL_ABSENT;
@@ -2566,10 +2577,10 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 {
 	u32 pscr;
 
-	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	pscr = rdlp(mp, PORT_SERIAL_CONTROL);
 	if (pscr & SERIAL_PORT_ENABLE) {
 		pscr &= ~SERIAL_PORT_ENABLE;
-		wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+		wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 	}
 
 	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
@@ -2587,7 +2598,7 @@ static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
 			pscr |= SET_FULL_DUPLEX_MODE;
 	}
 
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+	wrlp(mp, PORT_SERIAL_CONTROL, pscr);
 }
 
 static int mv643xx_eth_probe(struct platform_device *pdev)
@@ -2619,6 +2630,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, mp);
 
 	mp->shared = platform_get_drvdata(pd->shared);
+	mp->base = mp->shared->base + 0x0400 + (pd->port_number << 10);
 	mp->port_num = pd->port_number;
 
 	mp->dev = dev;
@@ -2723,8 +2735,8 @@ static void mv643xx_eth_shutdown(struct platform_device *pdev)
 	struct mv643xx_eth_private *mp = platform_get_drvdata(pdev);
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mp, INT_MASK(mp->port_num), 0);
-	rdl(mp, INT_MASK(mp->port_num));
+	wrlp(mp, INT_MASK, 0);
+	rdlp(mp, INT_MASK);
 
 	if (netif_running(mp->dev))
 		port_reset(mp);
-- 
1.5.6.4
