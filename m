From: Mark Ware <mware@elphinstone.net>
Subject: [PATCH v3 RESEND] net: Rework mdio-ofgpio driver to use of_mdio
	infrastructure
Date: Thu, 23 Jul 2009 21:20:27 +1000
Message-ID: <4A68477B.4090505@elphinstone.net>
References: <4A66400F.3090309@elphinstone.net>
	<20090722.094059.113003489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090722.094059.113003489.davem@davemloft.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Changes to the fs_enet driver (aa73832c5a80d6c52c69b18af858d88fa595dd3c) cause kernel crashes when using the mdio-ofgpio driver.
 
This patch replicates similar changes made to the fs_enet mii-bitbang drivers.  It has been tested on a custom mpc8280 based board using an NFS mounted root.
 
Signed-off-by: Mark Ware <mware@elphinstone.net>
Acked-by: Grant Likely <grant.likely@secretlab.ca>
---
 
The only changes in v3 are to the commit message.
Resent due to patch mangling by mail client.
This time for sure...
 
 drivers/net/phy/mdio-gpio.c |   77 ++++++++++++++++++++-----------------------
 1 files changed, 36 insertions(+), 41 deletions(-)
 
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 33984b7..22cdd45 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -30,6 +30,7 @@
 
 #ifdef CONFIG_OF_GPIO
 #include <linux/of_gpio.h>
+#include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 #endif
 
@@ -81,13 +82,12 @@ static struct mdiobb_ops mdio_gpio_ops = {
 	.get_mdio_data = mdio_get,
 };
 
-static int __devinit mdio_gpio_bus_init(struct device *dev,
+static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *dev,
 					struct mdio_gpio_platform_data *pdata,
 					int bus_id)
 {
 	struct mii_bus *new_bus;
 	struct mdio_gpio_info *bitbang;
-	int ret = -ENOMEM;
 	int i;
 
 	bitbang = kzalloc(sizeof(*bitbang), GFP_KERNEL);
@@ -104,8 +104,6 @@ static int __devinit mdio_gpio_bus_init(struct device *dev,
 
 	new_bus->name = "GPIO Bitbanged MDIO",
 
-	ret = -ENODEV;
-
 	new_bus->phy_mask = pdata->phy_mask;
 	new_bus->irq = pdata->irqs;
 	new_bus->parent = dev;
@@ -129,15 +127,8 @@ static int __devinit mdio_gpio_bus_init(struct device *dev,
 
 	dev_set_drvdata(dev, new_bus);
 
-	ret = mdiobus_register(new_bus);
-	if (ret)
-		goto out_free_all;
-
-	return 0;
+	return new_bus;
 
-out_free_all:
-	dev_set_drvdata(dev, NULL);
-	gpio_free(bitbang->mdio);
 out_free_mdc:
 	gpio_free(bitbang->mdc);
 out_free_bus:
@@ -145,30 +136,47 @@ out_free_bus:
 out_free_bitbang:
 	kfree(bitbang);
 out:
-	return ret;
+	return NULL;
 }
 
-static void __devexit mdio_gpio_bus_destroy(struct device *dev)
+static void __devinit mdio_gpio_bus_deinit(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
 	struct mdio_gpio_info *bitbang = bus->priv;
 
-	mdiobus_unregister(bus);
-	free_mdio_bitbang(bus);
 	dev_set_drvdata(dev, NULL);
-	gpio_free(bitbang->mdc);
 	gpio_free(bitbang->mdio);
+	gpio_free(bitbang->mdc);
+	free_mdio_bitbang(bus);
 	kfree(bitbang);
 }
 
+static void __devexit mdio_gpio_bus_destroy(struct device *dev)
+{
+	struct mii_bus *bus = dev_get_drvdata(dev);
+
+	mdiobus_unregister(bus);
+	mdio_gpio_bus_deinit(dev);
+}
+
 static int __devinit mdio_gpio_probe(struct platform_device *pdev)
 {
 	struct mdio_gpio_platform_data *pdata = pdev->dev.platform_data;
+	struct mii_bus *new_bus;
+	int ret;
 
 	if (!pdata)
 		return -ENODEV;
 
-	return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
+	new_bus = mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
+	if (!new_bus)
+		return -ENODEV;
+
+	ret = mdiobus_register(new_bus);
+	if (ret)
+		mdio_gpio_bus_deinit(&pdev->dev);
+
+	return ret;
 }
 
 static int __devexit mdio_gpio_remove(struct platform_device *pdev)
@@ -179,29 +187,12 @@ static int __devexit mdio_gpio_remove(struct platform_device *pdev)
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
+	struct mii_bus *new_bus;
 	int ret;
 
 	pdata = kzalloc(sizeof(*pdata), GFP_KERNEL);
@@ -215,14 +206,18 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 
 	ret = of_get_gpio(ofdev->node, 1);
 	if (ret < 0)
-                goto out_free;
+		goto out_free;
 	pdata->mdio = ret;
 
-	while ((np = of_get_next_child(ofdev->node, np)))
-		if (!strcmp(np->type, "ethernet-phy"))
-			add_phy(pdata, np);
+	new_bus = mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc);
+	if (!new_bus)
+		return -ENODEV;
 
-	return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc);
+	ret = of_mdiobus_register(new_bus, ofdev->node);
+	if (ret)
+		mdio_gpio_bus_deinit(&ofdev->dev);
+
+	return ret;
 
 out_free:
 	kfree(pdata);
-- 
1.5.6.5
