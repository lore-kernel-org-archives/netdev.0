From: Nathan Rossi <nathan@nathanrossi.com>
Subject: [PATCH] net: macb: Add support for phy-handle binding
Date: Sun, 14 Feb 2016 02:02:48 +1000
Message-ID: <1455379368-18739-1-git-send-email-nathan@nathanrossi.com>
Cc: Nathan Rossi <nathan@nathanrossi.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36106 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbcBMQDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 11:03:02 -0500
Received: by mail-pf0-f176.google.com with SMTP id e127so63448376pfe.3
        for <netdev@vger.kernel.org>; Sat, 13 Feb 2016 08:03:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the 'phy-handle' binding which allows for a
system to specifically select a phy which can be attached via any MDIO
bus available in the system.

Signed-off-by: Nathan Rossi <nathan@nathanrossi.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 58 ++++++++++++++++++++++---------------
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 50c9410..ea8ec32 100644
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
+			return -EPROBE_DEFER;
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
+				phydev->irq = (phy_irq < 0) ? PHY_POLL :
+						phy_irq;
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
@@ -2821,7 +2831,6 @@ static int macb_probe(struct platform_device *pdev)
 					      = macb_clk_init;
 	int (*init)(struct platform_device *) = macb_init;
 	struct device_node *np = pdev->dev.of_node;
-	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
 	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
 	unsigned int queue_mask, num_queues;
@@ -2909,15 +2918,18 @@ static int macb_probe(struct platform_device *pdev)
 	else
 		macb_get_hwaddr(bp);
 
+	bp->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+	/* If phy-handle not provided assume first child is the phy node. */
+	if (!bp->phy_node)
+		bp->phy_node = of_get_next_available_child(np, NULL);
+
 	/* Power up the PHY if there is a GPIO reset */
-	phy_node =  of_get_next_available_child(np, NULL);
-	if (phy_node) {
-		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
+	if (bp->phy_node) {
+		int gpio = of_get_named_gpio(bp->phy_node, "reset-gpios", 0);
 		if (gpio_is_valid(gpio))
 			bp->reset_gpio = gpio_to_desc(gpio);
 		gpiod_set_value(bp->reset_gpio, GPIOD_OUT_HIGH);
 	}
-	of_node_put(phy_node);
 
 	err = of_get_phy_mode(np);
 	if (err < 0) {
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
2.7.0
