From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH] net: macb: add fixed-link node support
Date: Fri, 16 Jun 2017 10:55:36 +0200
Message-ID: <20170616085536.20442-1-m.grzeschik@pengutronix.de>
Cc: nicolas.ferre@microchip.com, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59221 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752385AbdFPIzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 04:55:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the MACB is directly connected to a
non-mdio PHY/device, it should be possible to provide
a fixed link configuration in the DT.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/ethernet/cadence/macb.c | 21 +++++++++++++++++++++
 drivers/net/ethernet/cadence/macb.h |  2 +-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 91f7492623d3f..91e36efe1d5fb 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -425,6 +425,16 @@ static int macb_mii_probe(struct net_device *dev)
 	int phy_irq;
 	int ret;
 
+	if (bp->phy_node) {
+		phydev = of_phy_connect(dev, bp->phy_node,
+					&macb_handle_link_change, 0,
+					bp->phy_interface);
+		if (!phydev)
+			return -ENODEV;
+
+		return 0;
+	}
+
 	phydev = phy_find_first(bp->mii_bus);
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
@@ -498,6 +508,17 @@ static int macb_mii_init(struct macb *bp)
 	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
 
 	np = bp->pdev->dev.of_node;
+	if (of_phy_is_fixed_link(np)) {
+		if (of_phy_register_fixed_link(np) < 0) {
+			dev_err(&bp->pdev->dev,
+				"broken fixed-link specification\n");
+			goto err_out_unregister_bus;
+		}
+		bp->phy_node = of_node_get(np);
+
+		np = NULL;
+	}
+
 	if (np) {
 		/* try dt phy registration */
 		err = of_mdiobus_register(bp->mii_bus, np);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index ec037b0fa2a4d..7efc726e0a113 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -928,7 +928,7 @@ struct macb {
 	dma_addr_t		rx_buffers_dma;
 
 	struct macb_or_gem_ops	macbgem_ops;
-
+	struct device_node	*phy_node;
 	struct mii_bus		*mii_bus;
 	int 			link;
 	int 			speed;
-- 
2.11.0
