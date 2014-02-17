From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v2 4/6] gianfar: Factor out enabling/disabling of hw interrupts
Date: Mon, 17 Feb 2014 12:53:17 +0200
Message-ID: <1392634399-5456-5-git-send-email-claudiu.manoil@freescale.com>
References: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:13336
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752134AbaBQKxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 05:53:51 -0500
In-Reply-To: <1392634399-5456-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Throughout the code there are places where the controller's
hw interrupt sources need to get disabled/enabled (masked/
un-masked) all at once.  The recommendation for disabling
the interrupts is to clear the ievent first then the imask
register (not the other way around).
Use the gfar_ints_enable/disable() helpers to make these
operations consistent.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 60 ++++++++++++++++----------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 987f323..385de80 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -448,6 +448,29 @@ static const struct net_device_ops gfar_netdev_ops = {
 #endif
 };
 
+static void gfar_ints_disable(struct gfar_private *priv)
+{
+	int i;
+	for (i = 0; i < priv->num_grps; i++) {
+		struct gfar __iomem *regs = priv->gfargrp[i].regs;
+		/* Clear IEVENT */
+		gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
+
+		/* Initialize IMASK */
+		gfar_write(&regs->imask, IMASK_INIT_CLEAR);
+	}
+}
+
+static void gfar_ints_enable(struct gfar_private *priv)
+{
+	int i;
+	for (i = 0; i < priv->num_grps; i++) {
+		struct gfar __iomem *regs = priv->gfargrp[i].regs;
+		/* Unmask the interrupts we look for */
+		gfar_write(&regs->imask, IMASK_DEFAULT);
+	}
+}
+
 void lock_rx_qs(struct gfar_private *priv)
 {
 	int i;
@@ -1548,19 +1571,10 @@ static void gfar_configure_serdes(struct net_device *dev)
 static void init_registers(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = NULL;
-	int i;
-
-	for (i = 0; i < priv->num_grps; i++) {
-		regs = priv->gfargrp[i].regs;
-		/* Clear IEVENT */
-		gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 
-		/* Initialize IMASK */
-		gfar_write(&regs->imask, IMASK_INIT_CLEAR);
-	}
+	gfar_ints_disable(priv);
 
-	regs = priv->gfargrp[0].regs;
 	/* Init hash registers to zero */
 	gfar_write(&regs->igaddr0, 0);
 	gfar_write(&regs->igaddr1, 0);
@@ -1622,20 +1636,11 @@ static int __gfar_is_rx_idle(struct gfar_private *priv)
 static void gfar_halt_nodisable(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct gfar __iomem *regs = NULL;
+	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 tempval;
-	int i;
-
-	for (i = 0; i < priv->num_grps; i++) {
-		regs = priv->gfargrp[i].regs;
-		/* Mask all interrupts */
-		gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
-		/* Clear all interrupts */
-		gfar_write(&regs->ievent, IEVENT_INIT_CLEAR);
-	}
+	gfar_ints_disable(priv);
 
-	regs = priv->gfargrp[0].regs;
 	/* Stop the DMA, and wait for it to stop */
 	tempval = gfar_read(&regs->dmactrl);
 	if ((tempval & (DMACTRL_GRS | DMACTRL_GTS)) !=
@@ -1823,10 +1828,10 @@ void gfar_start(struct net_device *dev)
 		/* Clear THLT/RHLT, so that the DMA starts polling now */
 		gfar_write(&regs->tstat, priv->gfargrp[i].tstat);
 		gfar_write(&regs->rstat, priv->gfargrp[i].rstat);
-		/* Unmask the interrupts we look for */
-		gfar_write(&regs->imask, IMASK_DEFAULT);
 	}
 
+	gfar_ints_enable(priv);
+
 	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
@@ -1931,15 +1936,10 @@ err_irq_fail:
 int startup_gfar(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
-	struct gfar __iomem *regs = NULL;
 	int err, i, j;
 
-	for (i = 0; i < priv->num_grps; i++) {
-		regs= priv->gfargrp[i].regs;
-		gfar_write(&regs->imask, IMASK_INIT_CLEAR);
-	}
+	gfar_ints_disable(priv);
 
-	regs= priv->gfargrp[0].regs;
 	err = gfar_alloc_skb_resources(ndev);
 	if (err)
 		return err;
-- 
1.7.11.7
