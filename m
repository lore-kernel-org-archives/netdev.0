From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [RFC] net: macb: Attempt to make fixed link working on macb
Date: Sun,  6 Mar 2016 11:49:38 -0800
Message-ID: <1457293778-13804-2-git-send-email-moritz.fischer@ettus.com>
References: <1457293778-13804-1-git-send-email-moritz.fischer@ettus.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457293778-13804-1-git-send-email-moritz.fischer@ettus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 63 ++++++++++++++++++++++++-------------
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 50c9410..4a3d45d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -375,27 +375,37 @@ static int macb_mii_probe(struct net_device *dev)
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
-	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
-		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin, "phy int");
-		if (!ret) {
-			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
-			phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+		pdata = dev_get_platdata(&bp->pdev->dev);
+		if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
+			ret = devm_gpio_request(&bp->pdev->dev,
+						pdata->phy_irq_pin, "phy int");
+			if (!ret) {
+				phy_irq = gpio_to_irq(pdata->phy_irq_pin);
+				phydev->irq = (phy_irq < 0)
+					? PHY_POLL : phy_irq;
+			}
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
@@ -2910,14 +2920,21 @@ static int macb_probe(struct platform_device *pdev)
 		macb_get_hwaddr(bp);
 
 	/* Power up the PHY if there is a GPIO reset */
-	phy_node =  of_get_next_available_child(np, NULL);
-	if (phy_node) {
+	phy_node = of_parse_phandle(np, "phy-handle", 0);
+	if (!phy_node && of_phy_is_fixed_link(np)) {
+		err = of_phy_register_fixed_link(np);
+		if (err < 0) {
+			dev_err(&pdev->dev, "broken fixed-link specification");
+			goto failed_phy;
+		}
+		phy_node = of_node_get(np);
+		bp->phy_node = phy_node;
+	} else {
 		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
 		if (gpio_is_valid(gpio))
 			bp->reset_gpio = gpio_to_desc(gpio);
 		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
 	}
-	of_node_put(phy_node);
 
 	err = of_get_phy_mode(np);
 	if (err < 0) {
@@ -2959,6 +2976,9 @@ static int macb_probe(struct platform_device *pdev)
 err_out_unregister_netdev:
 	unregister_netdev(dev);
 
+failed_phy:
+	of_node_put(phy_node);
+
 err_out_free_netdev:
 	free_netdev(dev);
 
@@ -2991,6 +3011,7 @@ static int macb_remove(struct platform_device *pdev)
 		clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
+		of_node_put(bp->phy_node);
 		free_netdev(dev);
 	}
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 0d4ecfc..0373aa47 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -822,6 +822,7 @@ struct macb {
 
 	struct mii_bus		*mii_bus;
 	struct phy_device	*phy_dev;
+	struct device_node	*phy_node;
 	int 			link;
 	int 			speed;
 	int 			duplex;
-- 
2.7.2
