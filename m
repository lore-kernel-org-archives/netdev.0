From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 30/39] mv643xx_eth: add tx rate control
Date: Tue,  3 Jun 2008 13:02:45 +0200
Message-ID: <1212490974-23719-31-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48754 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754404AbYFCMA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:29 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an interface for the hardware's per-port and per-subqueue
TX rate control.  In this stage, this is mainly so that we can
disable the bandwidth limits during initialisation of the port.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  104 ++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 103 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index ff31cd8..24426fc 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -82,7 +82,10 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
 #define  TX_FIFO_EMPTY			0x00000400
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
+#define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
+#define TX_BW_RATE(p)			(0x0450 + ((p) << 10))
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
+#define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
 #define  INT_RX				0x00000804
 #define  INT_EXT			0x00000002
@@ -98,6 +101,9 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define RXQ_CURRENT_DESC_PTR(p)		(0x060c + ((p) << 10))
 #define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
 #define TXQ_CURRENT_DESC_PTR(p)		(0x06c0 + ((p) << 10))
+#define TXQ_BW_TOKENS(p)		(0x0700 + ((p) << 10))
+#define TXQ_BW_CONF(p)			(0x0704 + ((p) << 10))
+#define TXQ_BW_WRR_CONF(p)		(0x0708 + ((p) << 10))
 #define MIB_COUNTERS(p)			(0x1000 + ((p) << 7))
 #define SPECIAL_MCAST_TABLE(p)		(0x1400 + ((p) << 10))
 #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
@@ -757,6 +763,95 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 
+/* tx rate control **********************************************************/
+/*
+ * Set total maximum TX rate (shared by all TX queues for this port)
+ * to 'rate' bits per second, with a maximum burst of 'burst' bytes.
+ */
+static void tx_set_rate(struct mv643xx_eth_private *mep, int rate, int burst)
+{
+	int token_rate;
+	int mtu;
+	int bucket_size;
+
+	token_rate = ((rate / 1000) * 64) / (mep->shared->t_clk / 1000);
+	if (token_rate > 1023)
+		token_rate = 1023;
+
+	mtu = (mep->dev->mtu + 255) >> 8;
+	if (mtu > 63)
+		mtu = 63;
+
+	bucket_size = (burst + 255) >> 8;
+	if (bucket_size > 65535)
+		bucket_size = 65535;
+
+	wrl(mep, TX_BW_RATE(mep->port_num), token_rate);
+	wrl(mep, TX_BW_MTU(mep->port_num), mtu);
+	wrl(mep, TX_BW_BURST(mep->port_num), bucket_size);
+}
+
+static void txq_set_rate(struct tx_queue *txq, int rate, int burst)
+{
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
+	int token_rate;
+	int bucket_size;
+
+	token_rate = ((rate / 1000) * 64) / (mep->shared->t_clk / 1000);
+	if (token_rate > 1023)
+		token_rate = 1023;
+
+	bucket_size = (burst + 255) >> 8;
+	if (bucket_size > 65535)
+		bucket_size = 65535;
+
+	wrl(mep, TXQ_BW_TOKENS(mep->port_num), token_rate << 14);
+	wrl(mep, TXQ_BW_CONF(mep->port_num),
+			(bucket_size << 10) | token_rate);
+}
+
+static void txq_set_fixed_prio_mode(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
+	int off;
+	u32 val;
+
+	/*
+	 * Turn on fixed priority mode.
+	 */
+	off = TXQ_FIX_PRIO_CONF(mep->port_num);
+
+	val = rdl(mep, off);
+	val |= 1;
+	wrl(mep, off, val);
+}
+
+static void txq_set_wrr(struct tx_queue *txq, int weight)
+{
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
+	int off;
+	u32 val;
+
+	/*
+	 * Turn off fixed priority mode.
+	 */
+	off = TXQ_FIX_PRIO_CONF(mep->port_num);
+
+	val = rdl(mep, off);
+	val &= ~1;
+	wrl(mep, off, val);
+
+	/*
+	 * Configure WRR weight for this queue.
+	 */
+	off = TXQ_BW_WRR_CONF(mep->port_num);
+
+	val = rdl(mep, off);
+	val = (val & ~0xff) | (weight & 0xff);
+	wrl(mep, off, val);
+}
+
+
 /* mii management interface *************************************************/
 #define SMI_BUSY		0x10000000
 #define SMI_READ_VALID		0x08000000
@@ -1562,7 +1657,7 @@ static void port_start(struct mv643xx_eth_private *mep)
 	/*
 	 * Configure TX path and queues.
 	 */
-	wrl(mep, TX_BW_MTU(mep->port_num), 0);
+	tx_set_rate(mep, 1000000000, 16777216);
 	for (i = 0; i < 1; i++) {
 		struct tx_queue *txq = mep->txq;
 		int off = TXQ_CURRENT_DESC_PTR(mep->port_num);
@@ -1571,6 +1666,9 @@ static void port_start(struct mv643xx_eth_private *mep)
 		addr = (u32)txq->tx_desc_dma;
 		addr += txq->tx_curr_desc * sizeof(struct tx_desc);
 		wrl(mep, off, addr);
+
+		txq_set_rate(txq, 1000000000, 16777216);
+		txq_set_fixed_prio_mode(txq);
 	}
 
 	/*
@@ -1730,10 +1828,14 @@ static int mv643xx_eth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+
 	if (new_mtu < 64 || new_mtu > 9500)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
+	tx_set_rate(mep, 1000000000, 16777216);
+
 	if (!netif_running(dev))
 		return 0;
 
-- 
1.5.3.4

