From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 13/14] gianfar: Merge Tx and Rx interrupt for scheduling clean up ring
Date: Tue, 16 Dec 2008 17:21:06 -0600
Message-ID: <1229469667-25002-14-git-send-email-afleming@freescale.com>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
 <1229469667-25002-2-git-send-email-afleming@freescale.com>
 <1229469667-25002-3-git-send-email-afleming@freescale.com>
 <1229469667-25002-4-git-send-email-afleming@freescale.com>
 <1229469667-25002-5-git-send-email-afleming@freescale.com>
 <1229469667-25002-6-git-send-email-afleming@freescale.com>
 <1229469667-25002-7-git-send-email-afleming@freescale.com>
 <1229469667-25002-8-git-send-email-afleming@freescale.com>
 <1229469667-25002-9-git-send-email-afleming@freescale.com>
 <1229469667-25002-10-git-send-email-afleming@freescale.com>
 <1229469667-25002-11-git-send-email-afleming@freescale.com>
 <1229469667-25002-12-git-send-email-afleming@freescale.com>
 <1229469667-25002-13-git-send-email-afleming@freescale.com>
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:39702 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbYLPXVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:21:23 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBGNLAqL013552
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 16:21:10 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBGNL8Bk006135
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:21:09 -0600 (CST)
In-Reply-To: <1229469667-25002-13-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

No clean up function is executed in the interrupt context by this patch.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   59 +++++++++++++++----------------------------------
 drivers/net/gianfar.h |    2 +-
 2 files changed, 19 insertions(+), 42 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1cd3b89..b96aa52 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1604,29 +1604,19 @@ static int gfar_clean_tx_ring(struct net_device *dev)
 	return howmany;
 }
 
-/* Interrupt Handler for Transmit complete */
-static irqreturn_t gfar_transmit(int irq, void *dev_id)
+static void gfar_schedule_cleanup(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
 	struct gfar_private *priv = netdev_priv(dev);
-
-	/* Clear IEVENT */
-	gfar_write(&priv->regs->ievent, IEVENT_TX_MASK);
-
-	/* Lock priv */
-	spin_lock(&priv->txlock);
-
-	gfar_clean_tx_ring(dev);
-
-	/* If we are coalescing the interrupts, reset the timer */
-	/* Otherwise, clear it */
-	if (likely(priv->txcoalescing)) {
-		gfar_write(&priv->regs->txic, 0);
-		gfar_write(&priv->regs->txic, priv->txic);
+	if (netif_rx_schedule_prep(dev, &priv->napi)) {
+		gfar_write(&priv->regs->imask, IMASK_RTX_DISABLED);
+		__netif_rx_schedule(dev, &priv->napi);
 	}
+}
 
-	spin_unlock(&priv->txlock);
-
+/* Interrupt Handler for Transmit complete */
+static irqreturn_t gfar_transmit(int irq, void *dev_id)
+{
+	gfar_schedule_cleanup((struct net_device *)dev_id);
 	return IRQ_HANDLED;
 }
 
@@ -1713,28 +1703,7 @@ static inline void count_errors(unsigned short status, struct net_device *dev)
 
 irqreturn_t gfar_receive(int irq, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct gfar_private *priv = netdev_priv(dev);
-	u32 tempval;
-
-	/* support NAPI */
-	/* Clear IEVENT, so interrupts aren't called again
-	 * because of the packets that have already arrived */
-	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
-
-	if (netif_rx_schedule_prep(dev, &priv->napi)) {
-		tempval = gfar_read(&priv->regs->imask);
-		tempval &= IMASK_RTX_DISABLED;
-		gfar_write(&priv->regs->imask, tempval);
-
-		__netif_rx_schedule(dev, &priv->napi);
-	} else {
-		if (netif_msg_rx_err(priv))
-			printk(KERN_DEBUG "%s: receive called twice (%x)[%x]\n",
-				dev->name, gfar_read(&priv->regs->ievent),
-				gfar_read(&priv->regs->imask));
-	}
-
+	gfar_schedule_cleanup((struct net_device *)dev_id);
 	return IRQ_HANDLED;
 }
 
@@ -1880,6 +1849,10 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	int howmany;
 	unsigned long flags;
 
+	/* Clear IEVENT, so interrupts aren't called again
+	 * because of the packets that have already arrived */
+	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
+
 	/* If we fail to get the lock, don't bother with the TX BDs */
 	if (spin_trylock_irqsave(&priv->txlock, flags)) {
 		gfar_clean_tx_ring(dev);
@@ -1902,6 +1875,10 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 			gfar_write(&priv->regs->rxic, 0);
 			gfar_write(&priv->regs->rxic, priv->rxic);
 		}
+		if (likely(priv->txcoalescing)) {
+			gfar_write(&priv->regs->txic, 0);
+			gfar_write(&priv->regs->txic, priv->txic);
+		}
 	}
 
 	return howmany;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 06bac34..b1a8334 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -251,7 +251,7 @@ extern const char gfar_driver_version[];
 #define IEVENT_FIQ		0x00000004
 #define IEVENT_DPE		0x00000002
 #define IEVENT_PERR		0x00000001
-#define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0)
+#define IEVENT_RX_MASK          (IEVENT_RXB0 | IEVENT_RXF0 | IEVENT_BSY)
 #define IEVENT_TX_MASK          (IEVENT_TXB | IEVENT_TXF)
 #define IEVENT_RTX_MASK         (IEVENT_RX_MASK | IEVENT_TX_MASK)
 #define IEVENT_ERR_MASK         \
-- 
1.5.4.GIT

