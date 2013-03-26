From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1] enet: fec: fix fail resume from suspend state
Date: Tue, 26 Mar 2013 10:14:57 +0800
Message-ID: <1364264097-26157-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <shawn.guo@linaro.org>, <lznuaa@gmail.com>,
	<u.kleine-koenig@pengutronix.de>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:36907 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756255Ab3CZD0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 23:26:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch
1. boot with nfs (no_console_suspend)
2. echo mem >/sys/power/state
3. wakeup by wakesource
4. print "eth0: tx queue full"

This fix above problem by reinit bd queue at restart function

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |   82 ++++++++++++++++++++-------------
 1 files changed, 50 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 069a155..78b25db 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -345,6 +345,53 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return NETDEV_TX_OK;
 }
 
+/* Init RX & TX buffer descriptors
+ */
+static void fec_enet_bd_init(struct net_device *dev)
+{
+	struct fec_enet_private *fep = netdev_priv(dev);
+	struct bufdesc *bdp;
+	int i;
+
+	/* Initialize the receive buffer descriptors. */
+	bdp = fep->rx_bd_base;
+	for (i = 0; i < RX_RING_SIZE; i++) {
+
+		/* Initialize the BD for every fragment in the page. */
+		if (bdp->cbd_bufaddr)
+			bdp->cbd_sc = BD_ENET_RX_EMPTY;
+		else
+			bdp->cbd_sc = 0;
+		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
+	}
+
+	/* Set the last buffer to wrap */
+	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
+	bdp->cbd_sc |= BD_SC_WRAP;
+
+	fep->cur_rx = fep->rx_bd_base;
+
+	/* ...and the same for transmit */
+	bdp = fep->tx_bd_base;
+	fep->cur_tx = bdp;
+	for (i = 0; i < TX_RING_SIZE; i++) {
+
+		/* Initialize the BD for every fragment in the page. */
+		bdp->cbd_sc = 0;
+		if (bdp->cbd_bufaddr && fep->tx_skbuff[i]) {
+			dev_kfree_skb_any(fep->tx_skbuff[i]);
+			fep->tx_skbuff[i] = NULL;
+		}
+		bdp->cbd_bufaddr = 0;
+		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
+	}
+
+	/* Set the last buffer to wrap */
+	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
+	bdp->cbd_sc |= BD_SC_WRAP;
+	fep->dirty_tx = bdp;
+}
+
 /* This function is called to start or restart the FEC during a link
  * change.  This only happens when switching between half and full
  * duplex.
@@ -388,6 +435,8 @@ fec_restart(struct net_device *ndev, int duplex)
 	/* Set maximum receive buffer size. */
 	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
 
+	fec_enet_bd_init(ndev);
+
 	/* Set receive and transmit descriptor base. */
 	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
 	if (fep->bufdesc_ex)
@@ -397,7 +446,6 @@ fec_restart(struct net_device *ndev, int duplex)
 		writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc)
 			* RX_RING_SIZE,	fep->hwp + FEC_X_DES_START);
 
-	fep->cur_rx = fep->rx_bd_base;
 
 	for (i = 0; i <= TX_RING_MOD_MASK; i++) {
 		if (fep->tx_skbuff[i]) {
@@ -1592,8 +1640,6 @@ static int fec_enet_init(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct bufdesc *cbd_base;
-	struct bufdesc *bdp;
-	int i;
 
 	/* Allocate memory for buffer descriptors. */
 	cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
@@ -1603,6 +1649,7 @@ static int fec_enet_init(struct net_device *ndev)
 		return -ENOMEM;
 	}
 
+	memset(cbd_base, 0, PAGE_SIZE);
 	spin_lock_init(&fep->hw_lock);
 
 	fep->netdev = ndev;
@@ -1626,35 +1673,6 @@ static int fec_enet_init(struct net_device *ndev)
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
 
-	/* Initialize the receive buffer descriptors. */
-	bdp = fep->rx_bd_base;
-	for (i = 0; i < RX_RING_SIZE; i++) {
-
-		/* Initialize the BD for every fragment in the page. */
-		bdp->cbd_sc = 0;
-		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
-	}
-
-	/* Set the last buffer to wrap */
-	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
-	bdp->cbd_sc |= BD_SC_WRAP;
-
-	/* ...and the same for transmit */
-	bdp = fep->tx_bd_base;
-	fep->cur_tx = bdp;
-	for (i = 0; i < TX_RING_SIZE; i++) {
-
-		/* Initialize the BD for every fragment in the page. */
-		bdp->cbd_sc = 0;
-		bdp->cbd_bufaddr = 0;
-		bdp = fec_enet_get_nextdesc(bdp, fep->bufdesc_ex);
-	}
-
-	/* Set the last buffer to wrap */
-	bdp = fec_enet_get_prevdesc(bdp, fep->bufdesc_ex);
-	bdp->cbd_sc |= BD_SC_WRAP;
-	fep->dirty_tx = bdp;
-
 	fec_restart(ndev, 0);
 
 	return 0;
-- 
1.7.1
