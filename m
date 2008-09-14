From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/5] mv643xx_eth: add support for chips without transmit bandwidth control
Date: Sun, 14 Sep 2008 19:14:59 +0200
Message-ID: <20080914171459.GG28798@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:47787 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbYINRPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 13:15:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for mv643xx_eth versions that have no transmit bandwidth
control registers at all, such as the ethernet block found in the
Marvell 88F6183 ARM SoC.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   89 +++++++++++++++++++++++++++++----------------
 1 files changed, 58 insertions(+), 31 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 6564be1..408827d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -271,9 +271,13 @@ struct mv643xx_eth_shared_private {
 	 */
 	unsigned int t_clk;
 	int extended_rx_coal_limit;
-	int tx_bw_control_moved;
+	int tx_bw_control;
 };
 
+#define TX_BW_CONTROL_ABSENT		0
+#define TX_BW_CONTROL_OLD_LAYOUT	1
+#define TX_BW_CONTROL_NEW_LAYOUT	2
+
 
 /* per-port *****************************************************************/
 struct mib_counters {
@@ -938,14 +942,17 @@ static void tx_set_rate(struct mv643xx_eth_private *mp, int rate, int burst)
 	if (bucket_size > 65535)
 		bucket_size = 65535;
 
-	if (mp->shared->tx_bw_control_moved) {
-		wrl(mp, TX_BW_RATE_MOVED(mp->port_num), token_rate);
-		wrl(mp, TX_BW_MTU_MOVED(mp->port_num), mtu);
-		wrl(mp, TX_BW_BURST_MOVED(mp->port_num), bucket_size);
-	} else {
+	switch (mp->shared->tx_bw_control) {
+	case TX_BW_CONTROL_OLD_LAYOUT:
 		wrl(mp, TX_BW_RATE(mp->port_num), token_rate);
 		wrl(mp, TX_BW_MTU(mp->port_num), mtu);
 		wrl(mp, TX_BW_BURST(mp->port_num), bucket_size);
+		break;
+	case TX_BW_CONTROL_NEW_LAYOUT:
+		wrl(mp, TX_BW_RATE_MOVED(mp->port_num), token_rate);
+		wrl(mp, TX_BW_MTU_MOVED(mp->port_num), mtu);
+		wrl(mp, TX_BW_BURST_MOVED(mp->port_num), bucket_size);
+		break;
 	}
 }
 
@@ -977,14 +984,21 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 	/*
 	 * Turn on fixed priority mode.
 	 */
-	if (mp->shared->tx_bw_control_moved)
-		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
-	else
+	off = 0;
+	switch (mp->shared->tx_bw_control) {
+	case TX_BW_CONTROL_OLD_LAYOUT:
 		off = TXQ_FIX_PRIO_CONF(mp->port_num);
+		break;
+	case TX_BW_CONTROL_NEW_LAYOUT:
+		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+		break;
+	}
 
-	val = rdl(mp, off);
-	val |= 1 << txq->index;
-	wrl(mp, off, val);
+	if (off) {
+		val = rdl(mp, off);
+		val |= 1 << txq->index;
+		wrl(mp, off, val);
+	}
 }
 
 static void txq_set_wrr(struct tx_queue *txq, int weight)
@@ -996,23 +1010,30 @@ static void txq_set_wrr(struct tx_queue *txq, int weight)
 	/*
 	 * Turn off fixed priority mode.
 	 */
-	if (mp->shared->tx_bw_control_moved)
-		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
-	else
+	off = 0;
+	switch (mp->shared->tx_bw_control) {
+	case TX_BW_CONTROL_OLD_LAYOUT:
 		off = TXQ_FIX_PRIO_CONF(mp->port_num);
+		break;
+	case TX_BW_CONTROL_NEW_LAYOUT:
+		off = TXQ_FIX_PRIO_CONF_MOVED(mp->port_num);
+		break;
+	}
 
-	val = rdl(mp, off);
-	val &= ~(1 << txq->index);
-	wrl(mp, off, val);
+	if (off) {
+		val = rdl(mp, off);
+		val &= ~(1 << txq->index);
+		wrl(mp, off, val);
 
-	/*
-	 * Configure WRR weight for this queue.
-	 */
-	off = TXQ_BW_WRR_CONF(mp->port_num, txq->index);
+		/*
+		 * Configure WRR weight for this queue.
+		 */
+		off = TXQ_BW_WRR_CONF(mp->port_num, txq->index);
 
-	val = rdl(mp, off);
-	val = (val & ~0xff) | (weight & 0xff);
-	wrl(mp, off, val);
+		val = rdl(mp, off);
+		val = (val & ~0xff) | (weight & 0xff);
+		wrl(mp, off, val);
+	}
 }
 
 
@@ -2288,14 +2309,20 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 		msp->extended_rx_coal_limit = 0;
 
 	/*
-	 * Check whether the TX rate control registers are in the
-	 * old or the new place.
+	 * Check whether the MAC supports TX rate control, and if
+	 * yes, whether its associated registers are in the old or
+	 * the new place.
 	 */
 	writel(1, msp->base + TX_BW_MTU_MOVED(0));
-	if (readl(msp->base + TX_BW_MTU_MOVED(0)) & 1)
-		msp->tx_bw_control_moved = 1;
-	else
-		msp->tx_bw_control_moved = 0;
+	if (readl(msp->base + TX_BW_MTU_MOVED(0)) & 1) {
+		msp->tx_bw_control = TX_BW_CONTROL_NEW_LAYOUT;
+	} else {
+		writel(7, msp->base + TX_BW_RATE(0));
+		if (readl(msp->base + TX_BW_RATE(0)) & 7)
+			msp->tx_bw_control = TX_BW_CONTROL_OLD_LAYOUT;
+		else
+			msp->tx_bw_control = TX_BW_CONTROL_ABSENT;
+	}
 }
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
-- 
1.5.6.4
