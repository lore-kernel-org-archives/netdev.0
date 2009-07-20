From: Mark Ware <mware@elphinstone.net>
Subject: [RFC/PATCH] net: Rework mdio-ofgpio driver to use of_mdio infrastructure
Date: Mon, 20 Jul 2009 22:20:39 +1000
Message-ID: <4A646117.1030409@elphinstone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: grant.likely@secretlab.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl2.internode.on.net ([203.16.214.57]:48698 "EHLO
	ipmail04.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbZGTMUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 08:20:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to the fs_enet driver (aa73832c5a80d6c52c69b18af858d88fa595dd3c) cause kernel crashes when using the mdio-ofgpio driver.

The following patch is a fairly naive attempt to replicate similar changes made to the fs_enet mii-bitbang drivers.

Signed-of-by: Mark Ware <mware@elphinstone.net>
---

This patch probably misses some important details, but it does allow my mpc8280 based board to boot and use an NFS mounted root.

  drivers/net/phy/mdio-gpio.c |   39 +++++++++++++--------------------------
  1 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 33984b7..6568176 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -30,6 +30,7 @@

  #ifdef CONFIG_OF_GPIO
  #include <linux/of_gpio.h>
+#include <linux/of_mdio.h>
  #include <linux/of_platform.h>
  #endif

@@ -83,7 +84,8 @@ static struct mdiobb_ops mdio_gpio_ops = {

  static int __devinit mdio_gpio_bus_init(struct device *dev,
  					struct mdio_gpio_platform_data *pdata,
-					int bus_id)
+					int bus_id,
+                    void *ofdev)
  {
  	struct mii_bus *new_bus;
  	struct mdio_gpio_info *bitbang;
@@ -129,7 +131,14 @@ static int __devinit mdio_gpio_bus_init(struct device *dev,

  	dev_set_drvdata(dev, new_bus);

-	ret = mdiobus_register(new_bus);
+#ifdef CONFIG_OF_GPIO
+    if (ofdev)
+        ret = of_mdiobus_register(new_bus, ((struct of_device *) ofdev)->node);
+    else
+#else
+	    ret = mdiobus_register(new_bus);
+#endif
+
  	if (ret)
  		goto out_free_all;

@@ -168,7 +177,7 @@ static int __devinit mdio_gpio_probe(struct platform_device *pdev)
  	if (!pdata)
  		return -ENODEV;

-	return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
+	return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id, NULL);
  }

  static int __devexit mdio_gpio_remove(struct platform_device *pdev)
@@ -179,28 +188,10 @@ static int __devexit mdio_gpio_remove(struct platform_device *pdev)
  }

  #ifdef CONFIG_OF_GPIO
-static void __devinit add_phy(struct mdio_gpio_platform_data *pdata,
-			      struct device_node *np)
-{
-	const u32 *data;
-	int len, id, irq;
-
-	data = of_get_property(np, "reg", &len);
-	if (!data || len != 4)
-		return;
-
-	id = *data;
-	pdata->phy_mask &= ~(1 << id);
-
-	irq = of_irq_to_resource(np, 0, NULL);
-	if (irq)
-		pdata->irqs[id] = irq;
-}

  static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
                                          const struct of_device_id *match)
  {
-	struct device_node *np = NULL;
  	struct mdio_gpio_platform_data *pdata;
  	int ret;

@@ -218,11 +209,7 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
                  goto out_free;
  	pdata->mdio = ret;

-	while ((np = of_get_next_child(ofdev->node, np)))
-		if (!strcmp(np->type, "ethernet-phy"))
-			add_phy(pdata, np);
-
-	return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc);
+	return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc, ofdev);

  out_free:
  	kfree(pdata);
-- 
1.5.6.5
