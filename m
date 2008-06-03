From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 35/39] mv643xx_eth: detect alternate TX BW control register location
Date: Tue,  3 Jun 2008 13:02:50 +0200
Message-ID: <1212490974-23719-36-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48753 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754396AbYFCMA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:28 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some SoCs have the TX bandwidth control registers in a slightly
different place.  This patch detects that case at run time, and
re-directs accesses to those registers to the proper place at
run time if needed.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   37 ++++++++++++++++++++++++++++++++-----
 1 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4168a8a..a7c5421 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -99,6 +99,10 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define INT_MASK(p)			(0x0468 + ((p) << 10))
 #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
+#define TXQ_FIX_PRIO_CONF_MOVED(p)	(0x04dc + ((p) << 10))
+#define TX_BW_RATE_MOVED(p)		(0x04e0 + ((p) << 10))
+#define TX_BW_MTU_MOVED(p)		(0x04e8 + ((p) << 10))
+#define TX_BW_BURST_MOVED(p)		(0x04ec + ((p) << 10))
 #define RXQ_CURRENT_DESC_PTR(p, q)	(0x060c + ((p) << 10) + ((q) << 4))
 #define RXQ_COMMAND(p)			(0x0680 + ((p) << 10))
 #define TXQ_CURRENT_DESC_PTR(p, q)	(0x06c0 + ((p) << 10) + ((q) << 2))
@@ -241,6 +245,7 @@ struct mv643xx_eth_shared_private {
 	 */
 	unsigned int t_clk;
 	int extended_rx_coal_limit;
+	int tx_bw_control_moved;
 };
 
 
@@ -813,9 +818,15 @@ static void tx_set_rate(struct mv643xx_eth_private *mep, int rate, int burst)
 	if (bucket_size > 65535)
 		bucket_size = 65535;
 
-	wrl(mep, TX_BW_RATE(mep->port_num), token_rate);
-	wrl(mep, TX_BW_MTU(mep->port_num), mtu);
-	wrl(mep, TX_BW_BURST(mep->port_num), bucket_size);
+	if (mep->shared->tx_bw_control_moved) {
+		wrl(mep, TX_BW_RATE_MOVED(mep->port_num), token_rate);
+		wrl(mep, TX_BW_MTU_MOVED(mep->port_num), mtu);
+		wrl(mep, TX_BW_BURST_MOVED(mep->port_num), bucket_size);
+	} else {
+		wrl(mep, TX_BW_RATE(mep->port_num), token_rate);
+		wrl(mep, TX_BW_MTU(mep->port_num), mtu);
+		wrl(mep, TX_BW_BURST(mep->port_num), bucket_size);
+	}
 }
 
 static void txq_set_rate(struct tx_queue *txq, int rate, int burst)
@@ -846,7 +857,10 @@ static void txq_set_fixed_prio_mode(struct tx_queue *txq)
 	/*
 	 * Turn on fixed priority mode.
 	 */
-	off = TXQ_FIX_PRIO_CONF(mep->port_num);
+	if (mep->shared->tx_bw_control_moved)
+		off = TXQ_FIX_PRIO_CONF_MOVED(mep->port_num);
+	else
+		off = TXQ_FIX_PRIO_CONF(mep->port_num);
 
 	val = rdl(mep, off);
 	val |= 1 << txq->index;
@@ -862,7 +876,10 @@ static void txq_set_wrr(struct tx_queue *txq, int weight)
 	/*
 	 * Turn off fixed priority mode.
 	 */
-	off = TXQ_FIX_PRIO_CONF(mep->port_num);
+	if (mep->shared->tx_bw_control_moved)
+		off = TXQ_FIX_PRIO_CONF_MOVED(mep->port_num);
+	else
+		off = TXQ_FIX_PRIO_CONF(mep->port_num);
 
 	val = rdl(mep, off);
 	val &= ~(1 << txq->index);
@@ -2089,6 +2106,16 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *mesp)
 		mesp->extended_rx_coal_limit = 1;
 	else
 		mesp->extended_rx_coal_limit = 0;
+
+	/*
+	 * Check whether the TX rate control registers are in the
+	 * old or the new place.
+	 */
+	writel(1, mesp->base + TX_BW_MTU_MOVED(0));
+	if (readl(mesp->base + TX_BW_MTU_MOVED(0)) & 1)
+		mesp->tx_bw_control_moved = 1;
+	else
+		mesp->tx_bw_control_moved = 0;
 }
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
-- 
1.5.3.4

