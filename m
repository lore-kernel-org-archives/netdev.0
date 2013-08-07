From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 1/2][net-next] gianfar: Fix pause frame handling for half duplex links
Date: Wed, 7 Aug 2013 13:24:15 +0300
Message-ID: <1375871056-10420-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:35305
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932491Ab3HGKY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 06:24:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MACCFG1 register bits to enable PAUSE frame handling are set by the
driver unconditionally. Per 802.3 standard, PAUSE frame handling is a
full duplex feature, and neither meaningful nor correct in half duplex.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 31 +++++++++++++++++++++++++++++--
 drivers/net/ethernet/freescale/gianfar.h |  2 ++
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index edf06f1..54cf9be 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -764,6 +764,9 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 				     FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
 				     FSL_GIANFAR_DEV_HAS_TIMER;
 
+	/* default pause frame settings */
+	priv->rx_pause = priv->tx_pause = true;
+
 	ctype = of_get_property(np, "phy-connection-type", NULL);
 
 	/* We only care about rgmii-id.  The rest are autodetected */
@@ -1016,8 +1019,10 @@ static int gfar_probe(struct platform_device *ofdev)
 	/* We need to delay at least 3 TX clocks */
 	udelay(2);
 
-	tempval = (MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
-	gfar_write(&regs->maccfg1, tempval);
+	/* the soft reset bit is not self-resetting, so we need to
+	 * clear it before resuming normal operation
+	 */
+	gfar_write(&regs->maccfg1, 0);
 
 	/* Initialize MACCFG2. */
 	tempval = MACCFG2_INIT_SETTINGS;
@@ -3025,6 +3030,25 @@ static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 	return IRQ_HANDLED;
 }
 
+/* toggle pause frame settings */
+void gfar_configure_pause(struct gfar_private *priv, bool en)
+{
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
+	u32 tempval = gfar_read(&regs->maccfg1);
+
+	if (en && priv->rx_pause)
+		tempval |= MACCFG1_RX_FLOW;
+	else
+		tempval &= ~MACCFG1_RX_FLOW;
+
+	if (en && priv->tx_pause)
+		tempval |= MACCFG1_TX_FLOW;
+	else
+		tempval &= ~MACCFG1_TX_FLOW;
+
+	gfar_write(&regs->maccfg1, tempval);
+}
+
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
  * information through variables in the phydev structure, and this
@@ -3056,6 +3080,9 @@ static void adjust_link(struct net_device *dev)
 			else
 				tempval |= MACCFG2_FULL_DUPLEX;
 
+			/* update pause frame settings */
+			gfar_configure_pause(priv, !!phydev->duplex);
+
 			priv->oldduplex = phydev->duplex;
 		}
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index ee19f2c..e6a03f4 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1084,6 +1084,8 @@ struct gfar_private {
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
+	bool rx_pause;
+	bool tx_pause;
 
 	/* Bitfield update lock */
 	spinlock_t bflock;
-- 
1.7.11.7
