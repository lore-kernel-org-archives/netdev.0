From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] gianfar: Support NAPI for TX Frames
Date: Wed,  9 Apr 2008 19:37:51 -0500
Message-ID: <1207787871-9164-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:51949 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbYDJAhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 20:37:55 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id m3A0bqWU009078
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2008 17:37:53 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3A0bq7h012834
	for <netdev@vger.kernel.org>; Wed, 9 Apr 2008 19:37:52 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dai Haruki <dai.haruki@freescale.com>

Poll the completed TX frames in gfar_poll().  This prevents the tx
completion interrupt from interfering with processing of received
frames.

We also disable hardware rx coalescing when NAPI is enabled.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   56 ++++++++++++++++++++++++++++++++++++------------
 drivers/net/gianfar.h |   13 +++++++++-
 2 files changed, 53 insertions(+), 16 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 601f93e..c8c3df7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1250,17 +1250,12 @@ static void gfar_timeout(struct net_device *dev)
 }
 
 /* Interrupt Handler for Transmit complete */
-static irqreturn_t gfar_transmit(int irq, void *dev_id)
+int gfar_clean_tx_ring(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
 	struct txbd8 *bdp;
+	struct gfar_private *priv = netdev_priv(dev);
+	int howmany = 0;
 
-	/* Clear IEVENT */
-	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);
-
-	/* Lock priv */
-	spin_lock(&priv->txlock);
 	bdp = priv->dirty_tx;
 	while ((bdp->status & TXBD_READY) == 0) {
 		/* If dirty_tx and cur_tx are the same, then either the */
@@ -1269,7 +1264,7 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 		if ((bdp == priv->cur_tx) && (netif_queue_stopped(dev) == 0))
 			break;
 
-		dev->stats.tx_packets++;
+		howmany++;
 
 		/* Deferred means some collisions occurred during transmit, */
 		/* but we eventually sent the packet. */
@@ -1278,11 +1273,15 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 
 		/* Free the sk buffer associated with this TxBD */
 		dev_kfree_skb_irq(priv->tx_skbuff[priv->skb_dirtytx]);
+
 		priv->tx_skbuff[priv->skb_dirtytx] = NULL;
 		priv->skb_dirtytx =
 		    (priv->skb_dirtytx +
 		     1) & TX_RING_MOD_MASK(priv->tx_ring_size);
 
+		/* Clean BD length for empty detection */
+		bdp->length = 0;
+
 		/* update bdp to point at next bd in the ring (wrapping if necessary) */
 		if (bdp->status & TXBD_WRAP)
 			bdp = priv->tx_bd_base;
@@ -1297,6 +1296,25 @@ static irqreturn_t gfar_transmit(int irq, void *dev_id)
 			netif_wake_queue(dev);
 	} /* while ((bdp->status & TXBD_READY) == 0) */
 
+	dev->stats.tx_packets += howmany;
+
+	return howmany;
+}
+
+/* Interrupt Handler for Transmit complete */
+static irqreturn_t gfar_transmit(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *) dev_id;
+	struct gfar_private *priv = netdev_priv(dev);
+
+	/* Clear IEVENT */
+	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);
+
+	/* Lock priv */
+	spin_lock(&priv->txlock);
+
+	gfar_clean_tx_ring(dev);
+
 	/* If we are coalescing the interrupts, reset the timer */
 	/* Otherwise, clear it */
 	if (likely(priv->txcoalescing)) {
@@ -1392,15 +1410,15 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 	unsigned long flags;
 #endif
 
-	/* Clear IEVENT, so rx interrupt isn't called again
-	 * because of this interrupt */
-	gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
-
 	/* support NAPI */
 #ifdef CONFIG_GFAR_NAPI
+	/* Clear IEVENT, so interrupts aren't called again
+	 * because of the packets that have already arrived */
+	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
+
 	if (netif_rx_schedule_prep(dev, &priv->napi)) {
 		tempval = gfar_read(&priv->regs->imask);
-		tempval &= IMASK_RX_DISABLED;
+		tempval &= IMASK_RTX_DISABLED;
 		gfar_write(&priv->regs->imask, tempval);
 
 		__netif_rx_schedule(dev, &priv->napi);
@@ -1411,6 +1429,9 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 				gfar_read(&priv->regs->imask));
 	}
 #else
+	/* Clear IEVENT, so rx interrupt isn't called again
+	 * because of this interrupt */
+	gfar_write(&priv->regs->ievent, IEVENT_RX_MASK);
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 	gfar_clean_rx_ring(dev, priv->rx_ring_size);
@@ -1580,6 +1601,13 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	struct gfar_private *priv = container_of(napi, struct gfar_private, napi);
 	struct net_device *dev = priv->dev;
 	int howmany;
+	unsigned long flags;
+
+	/* If we fail to get the lock, don't bother with the TX BDs */
+	if (spin_trylock_irqsave(&priv->txlock, flags)) {
+		gfar_clean_tx_ring(dev);
+		spin_unlock_irqrestore(&priv->txlock, flags);
+	}
 
 	howmany = gfar_clean_rx_ring(dev, budget);
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index ea8671f..0d08836 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -126,9 +126,16 @@ extern const char gfar_driver_version[];
 #define DEFAULT_TXCOUNT	16
 #define DEFAULT_TXTIME	21
 
+#define DEFAULT_RXTIME	21
+
+/* Non NAPI Case */
+#ifndef CONFIG_GFAR_NAPI
 #define DEFAULT_RX_COALESCE 1
 #define DEFAULT_RXCOUNT	16
-#define DEFAULT_RXTIME	21
+#else
+#define DEFAULT_RX_COALESCE 0
+#define DEFAULT_RXCOUNT	0
+#endif /* CONFIG_GFAR_NAPI */
 
 #define TBIPA_VALUE		0x1f
 #define MIIMCFG_INIT_VALUE	0x00000007
@@ -242,6 +249,7 @@ extern const char gfar_driver_version[];
 #define IEVENT_PERR		0x00000001
 #define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0)
 #define IEVENT_TX_MASK          (IEVENT_TXB | IEVENT_TXF)
+#define IEVENT_RTX_MASK         (IEVENT_RX_MASK | IEVENT_TX_MASK)
 #define IEVENT_ERR_MASK         \
 (IEVENT_RXC | IEVENT_BSY | IEVENT_EBERR | IEVENT_MSRO | \
  IEVENT_BABT | IEVENT_TXC | IEVENT_TXE | IEVENT_LC \
@@ -269,11 +277,12 @@ extern const char gfar_driver_version[];
 #define IMASK_FIQ		0x00000004
 #define IMASK_DPE		0x00000002
 #define IMASK_PERR		0x00000001
-#define IMASK_RX_DISABLED ~(IMASK_RXFEN0 | IMASK_BSY)
 #define IMASK_DEFAULT  (IMASK_TXEEN | IMASK_TXFEN | IMASK_TXBEN | \
 		IMASK_RXFEN0 | IMASK_BSY | IMASK_EBERR | IMASK_BABR | \
 		IMASK_XFUN | IMASK_RXC | IMASK_BABT | IMASK_DPE \
 		| IMASK_PERR)
+#define IMASK_RTX_DISABLED ((~(IMASK_RXFEN0 | IMASK_TXFEN | IMASK_BSY)) \
+			   & IMASK_DEFAULT)
 
 /* Fifo management */
 #define FIFO_TX_THR_MASK	0x01ff
-- 
1.5.4.GIT

