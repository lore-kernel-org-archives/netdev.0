From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v2 3/5] gianfar: Don't free/request irqs on device reset
Date: Mon, 24 Feb 2014 12:13:44 +0200
Message-ID: <1393236826-13059-4-git-send-email-claudiu.manoil@freescale.com>
References: <1393236826-13059-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:33539 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752451AbaBXKOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 05:14:47 -0500
In-Reply-To: <1393236826-13059-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resetting the device (stop_gfar()/startup_gfar()) should
be fast and to the point, in order to timely recover
from an error condition (like Tx timeout) or during
device reconfig.  The irq free/ request routines are just
redundant here, and they should be part of the device
close/ open routines instead.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 77 +++++++++++++++++++-------------
 1 file changed, 45 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 728078f..6c054b5 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1715,18 +1715,10 @@ void gfar_halt(struct gfar_private *priv)
 	gfar_write(&regs->maccfg1, tempval);
 }
 
-static void free_grp_irqs(struct gfar_priv_grp *grp)
-{
-	free_irq(gfar_irq(grp, TX)->irq, grp);
-	free_irq(gfar_irq(grp, RX)->irq, grp);
-	free_irq(gfar_irq(grp, ER)->irq, grp);
-}
-
 void stop_gfar(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	unsigned long flags;
-	int i;
 
 	phy_stop(priv->phydev);
 
@@ -1742,16 +1734,6 @@ void stop_gfar(struct net_device *dev)
 	unlock_tx_qs(priv);
 	local_irq_restore(flags);
 
-	/* Free the IRQs */
-	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		for (i = 0; i < priv->num_grps; i++)
-			free_grp_irqs(&priv->gfargrp[i]);
-	} else {
-		for (i = 0; i < priv->num_grps; i++)
-			free_irq(gfar_irq(&priv->gfargrp[i], TX)->irq,
-				 &priv->gfargrp[i]);
-	}
-
 	free_skb_resources(priv);
 }
 
@@ -1919,6 +1901,13 @@ void gfar_configure_coalescing_all(struct gfar_private *priv)
 	gfar_configure_coalescing(priv, 0xFF, 0xFF);
 }
 
+static void free_grp_irqs(struct gfar_priv_grp *grp)
+{
+	free_irq(gfar_irq(grp, TX)->irq, grp);
+	free_irq(gfar_irq(grp, RX)->irq, grp);
+	free_irq(gfar_irq(grp, ER)->irq, grp);
+}
+
 static int register_grp_irqs(struct gfar_priv_grp *grp)
 {
 	struct gfar_private *priv = grp->priv;
@@ -1975,11 +1964,42 @@ err_irq_fail:
 
 }
 
+static void gfar_free_irq(struct gfar_private *priv)
+{
+	int i;
+
+	/* Free the IRQs */
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+		for (i = 0; i < priv->num_grps; i++)
+			free_grp_irqs(&priv->gfargrp[i]);
+	} else {
+		for (i = 0; i < priv->num_grps; i++)
+			free_irq(gfar_irq(&priv->gfargrp[i], TX)->irq,
+				 &priv->gfargrp[i]);
+	}
+}
+
+static int gfar_request_irq(struct gfar_private *priv)
+{
+	int err, i, j;
+
+	for (i = 0; i < priv->num_grps; i++) {
+		err = register_grp_irqs(&priv->gfargrp[i]);
+		if (err) {
+			for (j = 0; j < i; j++)
+				free_grp_irqs(&priv->gfargrp[j]);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
 /* Bring the controller up and running */
 int startup_gfar(struct net_device *ndev)
 {
 	struct gfar_private *priv = netdev_priv(ndev);
-	int err, i, j;
+	int err;
 
 	gfar_mac_reset(priv);
 
@@ -1989,25 +2009,12 @@ int startup_gfar(struct net_device *ndev)
 
 	gfar_init_tx_rx_base(priv);
 
-	for (i = 0; i < priv->num_grps; i++) {
-		err = register_grp_irqs(&priv->gfargrp[i]);
-		if (err) {
-			for (j = 0; j < i; j++)
-				free_grp_irqs(&priv->gfargrp[j]);
-			goto irq_fail;
-		}
-	}
-
 	/* Start the controller */
 	gfar_start(priv);
 
 	phy_start(priv->phydev);
 
 	return 0;
-
-irq_fail:
-	free_skb_resources(priv);
-	return err;
 }
 
 /* Called when something needs to use the ethernet device
@@ -2027,6 +2034,10 @@ static int gfar_enet_open(struct net_device *dev)
 		return err;
 	}
 
+	err = gfar_request_irq(priv);
+	if (err)
+		return err;
+
 	err = startup_gfar(dev);
 	if (err) {
 		disable_napi(priv);
@@ -2369,6 +2380,8 @@ static int gfar_close(struct net_device *dev)
 
 	netif_tx_stop_all_queues(dev);
 
+	gfar_free_irq(priv);
+
 	return 0;
 }
 
-- 
1.7.11.7
