From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH v2] net: macb: add fixed-link node support
Date: Fri, 23 Jun 2017 16:54:10 +0200
Message-ID: <20170623145410.581-1-m.grzeschik@pengutronix.de>
Cc: nicolas.ferre@microchip.com, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53689 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750932AbdFWOyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:54:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case the MACB is directly connected to a
non-mdio PHY/device, it should be possible to provide
a fixed link configuration in the DT.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
  v1 -> v2: - moved of_phy_connect case and phy_connect_direct into if else cases
            - moved of_pphy_register_fixed_link into if(np) case
	    - added of_node_put(bp->phy_node); into macb_remove
---
 drivers/net/ethernet/cadence/macb.c | 98 ++++++++++++++++++++++---------------
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 60 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 91f7492623d3f..5781f1ede8c6e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -425,32 +425,40 @@ static int macb_mii_probe(struct net_device *dev)
 	int phy_irq;
 	int ret;
 
-	phydev = phy_find_first(bp->mii_bus);
-	if (!phydev) {
-		netdev_err(dev, "no PHY found\n");
-		return -ENXIO;
-	}
+	if (bp->phy_node) {
+		phydev = of_phy_connect(dev, bp->phy_node,
+					&macb_handle_link_change, 0,
+					bp->phy_interface);
+		if (!phydev)
+			return -ENODEV;
+	} else {
+		phydev = phy_find_first(bp->mii_bus);
+		if (!phydev) {
+			netdev_err(dev, "no PHY found\n");
+			return -ENXIO;
+		}
 
-	pdata = dev_get_platdata(&bp->pdev->dev);
-	if (pdata) {
-		if (gpio_is_valid(pdata->phy_irq_pin)) {
-			ret = devm_gpio_request(&bp->pdev->dev,
-						pdata->phy_irq_pin, "phy int");
-			if (!ret) {
-				phy_irq = gpio_to_irq(pdata->phy_irq_pin);
-				phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+		pdata = dev_get_platdata(&bp->pdev->dev);
+		if (pdata) {
+			if (gpio_is_valid(pdata->phy_irq_pin)) {
+				ret = devm_gpio_request(&bp->pdev->dev,
+							pdata->phy_irq_pin, "phy int");
+				if (!ret) {
+					phy_irq = gpio_to_irq(pdata->phy_irq_pin);
+					phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+				}
+			} else {
+				phydev->irq = PHY_POLL;
 			}
-		} else {
-			phydev->irq = PHY_POLL;
 		}
-	}
 
-	/* attach the mac to the phy */
-	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change,
-				 bp->phy_interface);
-	if (ret) {
-		netdev_err(dev, "Could not attach to PHY\n");
-		return ret;
+		/* attach the mac to the phy */
+		ret = phy_connect_direct(dev, phydev, &macb_handle_link_change,
+					 bp->phy_interface);
+		if (ret) {
+			netdev_err(dev, "Could not attach to PHY\n");
+			return ret;
+		}
 	}
 
 	/* mask with MAC supported features */
@@ -499,26 +507,37 @@ static int macb_mii_init(struct macb *bp)
 
 	np = bp->pdev->dev.of_node;
 	if (np) {
-		/* try dt phy registration */
-		err = of_mdiobus_register(bp->mii_bus, np);
+		if (of_phy_is_fixed_link(np)) {
+			if (of_phy_register_fixed_link(np) < 0) {
+				dev_err(&bp->pdev->dev,
+					"broken fixed-link specification\n");
+				goto err_out_unregister_bus;
+			}
+			bp->phy_node = of_node_get(np);
 
-		/* fallback to standard phy registration if no phy were
-		 * found during dt phy registration
-		 */
-		if (!err && !phy_find_first(bp->mii_bus)) {
-			for (i = 0; i < PHY_MAX_ADDR; i++) {
-				struct phy_device *phydev;
-
-				phydev = mdiobus_scan(bp->mii_bus, i);
-				if (IS_ERR(phydev) &&
-				    PTR_ERR(phydev) != -ENODEV) {
-					err = PTR_ERR(phydev);
-					break;
+			err = mdiobus_register(bp->mii_bus);
+		} else {
+			/* try dt phy registration */
+			err = of_mdiobus_register(bp->mii_bus, np);
+
+			/* fallback to standard phy registration if no phy were
+			 * found during dt phy registration
+			 */
+			if (!err && !phy_find_first(bp->mii_bus)) {
+				for (i = 0; i < PHY_MAX_ADDR; i++) {
+					struct phy_device *phydev;
+
+					phydev = mdiobus_scan(bp->mii_bus, i);
+					if (IS_ERR(phydev) &&
+					    PTR_ERR(phydev) != -ENODEV) {
+						err = PTR_ERR(phydev);
+						break;
+					}
 				}
-			}
 
-			if (err)
-				goto err_out_unregister_bus;
+				if (err)
+					goto err_out_unregister_bus;
+			}
 		}
 	} else {
 		for (i = 0; i < PHY_MAX_ADDR; i++)
@@ -3438,6 +3457,7 @@ static int macb_remove(struct platform_device *pdev)
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
 		clk_disable_unprepare(bp->rx_clk);
+		of_node_put(bp->phy_node);
 		free_netdev(dev);
 	}
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index ec037b0fa2a4d..2510661102bad 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -930,6 +930,7 @@ struct macb {
 	struct macb_or_gem_ops	macbgem_ops;
 
 	struct mii_bus		*mii_bus;
+	struct device_node	*phy_node;
 	int 			link;
 	int 			speed;
 	int 			duplex;
-- 
2.11.0
