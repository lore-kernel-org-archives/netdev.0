From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 5/8] ethoc: rework interrupt handling
Date: Thu, 25 Nov 2010 13:30:29 +0100
Message-ID: <1290688232-25142-6-git-send-email-jonas@southpole.se>
References: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38973 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab0KYMag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:30:36 -0500
In-Reply-To: <1290688232-25142-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old interrupt handling was incorrect in that it did not account for the
fact that the interrupt source bits get set irregardless of whether or not
their corresponding mask is set.  This patch fixes that by masking off the
source bits for masked interrupts.

Furthermore, the handling of transmission events is moved to the NAPI polling
handler alongside the reception handler, thus preventing a whole bunch of
interrupts during heavy traffic.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |   76 +++++++++++++++++++++++++++++++++------------------
 1 files changed, 49 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index a12a07e..43431ff 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -495,29 +495,42 @@ static int ethoc_update_tx_stats(struct ethoc *dev, struct ethoc_bd *bd)
 	return 0;
 }
 
-static void ethoc_tx(struct net_device *dev)
+static int ethoc_tx(struct net_device *dev, int limit)
 {
 	struct ethoc *priv = netdev_priv(dev);
+	int count;
+	struct ethoc_bd bd;
 
-	spin_lock(&priv->lock);
+	for (count = 0; count < limit; ++count) {
+		unsigned int entry;
 
-	while (priv->dty_tx != priv->cur_tx) {
-		unsigned int entry = priv->dty_tx % priv->num_tx;
-		struct ethoc_bd bd;
+		entry = priv->dty_tx % priv->num_tx;
 
 		ethoc_read_bd(priv, entry, &bd);
-		if (bd.stat & TX_BD_READY)
-			break;
 
-		entry = (++priv->dty_tx) % priv->num_tx;
+		if (bd.stat & TX_BD_READY || (priv->dty_tx == priv->cur_tx)) {
+			ethoc_ack_irq(priv, INT_MASK_TX);
+			/* If interrupt came in between reading in the BD
+			 * and clearing the interrupt source, then we risk
+			 * missing the event as the TX interrupt won't trigger
+			 * right away when we reenable it; hence, check
+			 * BD_EMPTY here again to make sure there isn't such an
+			 * event pending...
+			 */
+			ethoc_read_bd(priv, entry, &bd);
+			if (bd.stat & TX_BD_READY ||
+			    (priv->dty_tx == priv->cur_tx))
+				break;
+		}
+
 		(void)ethoc_update_tx_stats(priv, &bd);
+		priv->dty_tx++;
 	}
 
 	if ((priv->cur_tx - priv->dty_tx) <= (priv->num_tx / 2))
 		netif_wake_queue(dev);
 
-	ethoc_ack_irq(priv, INT_MASK_TX);
-	spin_unlock(&priv->lock);
+	return count;
 }
 
 static irqreturn_t ethoc_interrupt(int irq, void *dev_id)
@@ -525,32 +538,38 @@ static irqreturn_t ethoc_interrupt(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	struct ethoc *priv = netdev_priv(dev);
 	u32 pending;
-
-	ethoc_disable_irq(priv, INT_MASK_ALL);
+	u32 mask;
+
+	/* Figure out what triggered the interrupt...
+	 * The tricky bit here is that the interrupt source bits get
+	 * set in INT_SOURCE for an event irregardless of whether that
+	 * event is masked or not.  Thus, in order to figure out what
+	 * triggered the interrupt, we need to remove the sources
+	 * for all events that are currently masked.  This behaviour
+	 * is not particularly well documented but reasonable...
+	 */
+	mask = ethoc_read(priv, INT_MASK);
 	pending = ethoc_read(priv, INT_SOURCE);
+	pending &= mask;
+
 	if (unlikely(pending == 0)) {
-		ethoc_enable_irq(priv, INT_MASK_ALL);
 		return IRQ_NONE;
 	}
 
 	ethoc_ack_irq(priv, pending);
 
+	/* We always handle the dropped packet interrupt */
 	if (pending & INT_MASK_BUSY) {
 		dev_err(&dev->dev, "packet dropped\n");
 		dev->stats.rx_dropped++;
 	}
 
-	if (pending & INT_MASK_RX) {
-		if (napi_schedule_prep(&priv->napi))
-			__napi_schedule(&priv->napi);
-	} else {
-		ethoc_enable_irq(priv, INT_MASK_RX);
+	/* Handle receive/transmit event by switching to polling */
+	if (pending & (INT_MASK_TX | INT_MASK_RX)) {
+		ethoc_disable_irq(priv, INT_MASK_TX | INT_MASK_RX);
+		napi_schedule(&priv->napi);
 	}
 
-	if (pending & INT_MASK_TX)
-		ethoc_tx(dev);
-
-	ethoc_enable_irq(priv, INT_MASK_ALL & ~INT_MASK_RX);
 	return IRQ_HANDLED;
 }
 
@@ -576,15 +595,18 @@ static int ethoc_get_mac_address(struct net_device *dev, void *addr)
 static int ethoc_poll(struct napi_struct *napi, int budget)
 {
 	struct ethoc *priv = container_of(napi, struct ethoc, napi);
-	int work_done = 0;
+	int rx_work_done = 0;
+	int tx_work_done = 0;
+
+	rx_work_done = ethoc_rx(priv->netdev, budget);
+	tx_work_done = ethoc_tx(priv->netdev, budget);
 
-	work_done = ethoc_rx(priv->netdev, budget);
-	if (work_done < budget) {
+	if (rx_work_done < budget && tx_work_done < budget) {
 		napi_complete(napi);
-		ethoc_enable_irq(priv, INT_MASK_RX);
+		ethoc_enable_irq(priv, INT_MASK_TX | INT_MASK_RX);
 	}
 
-	return work_done;
+	return rx_work_done;
 }
 
 static int ethoc_mdio_read(struct mii_bus *bus, int phy, int reg)
-- 
1.7.1

