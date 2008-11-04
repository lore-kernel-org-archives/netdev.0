From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Tue, 04 Nov 2008 16:45:19 +0200
Message-ID: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Mike Frysinger <vapier.adi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-embedded-owner@vger.kernel.org>
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 4 Nov 2008 14:43:41 -0000
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make mdio-gpio work with non OpenFirmware gpio implementation.

Aditional changes to mdio-gpio:
- use gpio_request() and gpio_free()
- place irq[] array in struct mdio_gpio_info
- add module description, author and license
- add note about compiling this driver as module
- rename mdc and mdio function (were ugly names)
- change MII to MDIO in bus name
- add __init __exit to module (un)loading functions
- probe fails if no phys added to the bus
- kzalloc bitbang with sizeof(*bitbang)

Changes since v1:
- removed NO_IRQ
- reduced #idefs

Laurent, please test this driver under OF.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Cc: Laurent Pinchart <laurentp@cse-semaphore.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Mike Frysinger <vapier.adi@gmail.com>
---

 drivers/net/phy/Kconfig     |    5 +
 drivers/net/phy/mdio-gpio.c |  194 ++++++++++++++++++++++++++++++-------------
 include/linux/mdio-gpio.h   |   30 +++++++
 3 files changed, 169 insertions(+), 60 deletions(-)
 create mode 100644 include/linux/mdio-gpio.h


diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 0318077..c4c5a2f 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -86,8 +86,11 @@ config MDIO_BITBANG
 
 config MDIO_GPIO
 	tristate "Support for GPIO lib-based bitbanged MDIO buses"
-	depends on MDIO_BITBANG && OF_GPIO
+	depends on MDIO_BITBANG && GENERIC_GPIO
 	---help---
 	  Supports GPIO lib-based MDIO busses.
 
+	  To compile this driver as a module, choose M here: the module
+	  will be called mdio-gpio.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 2ff9775..bcc2cb7 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -1,9 +1,12 @@
 /*
- * OpenFirmware GPIO based MDIO bitbang driver.
+ * GPIO based MDIO bitbang driver.
+ * Supports OpenFirmware.
  *
  * Copyright (c) 2008 CSE Semaphore Belgium.
  *  by Laurent Pinchart <laurentp@cse-semaphore.com>
  *
+ * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
+ *
  * Based on earlier work by
  *
  * Copyright (c) 2003 Intracom S.A.
@@ -22,12 +25,19 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/mdio-bitbang.h>
-#include <linux/of_gpio.h>
-#include <linux/of_platform.h>
+#ifdef CONFIG_OF_GPIO
+# include <linux/of_gpio.h>
+# include <linux/of_platform.h>
+#else
+# include <linux/platform_device.h>
+# include <linux/gpio.h>
+# include <linux/mdio-gpio.h>
+#endif
 
 struct mdio_gpio_info {
 	struct mdiobb_ctrl ctrl;
 	int mdc, mdio;
+	int irq[PHY_MAX_ADDR];
 };
 
 static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
@@ -41,7 +51,7 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
 		gpio_direction_input(bitbang->mdio);
 }
 
-static int mdio_read(struct mdiobb_ctrl *ctrl)
+static int mdio_get(struct mdiobb_ctrl *ctrl)
 {
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
@@ -49,7 +59,7 @@ static int mdio_read(struct mdiobb_ctrl *ctrl)
 	return gpio_get_value(bitbang->mdio);
 }
 
-static void mdio(struct mdiobb_ctrl *ctrl, int what)
+static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
 {
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
@@ -57,7 +67,7 @@ static void mdio(struct mdiobb_ctrl *ctrl, int what)
 	gpio_set_value(bitbang->mdio, what);
 }
 
-static void mdc(struct mdiobb_ctrl *ctrl, int what)
+static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 {
 	struct mdio_gpio_info *bitbang =
 		container_of(ctrl, struct mdio_gpio_info, ctrl);
@@ -67,54 +77,46 @@ static void mdc(struct mdiobb_ctrl *ctrl, int what)
 
 static struct mdiobb_ops mdio_gpio_ops = {
 	.owner = THIS_MODULE,
-	.set_mdc = mdc,
+	.set_mdc = mdc_set,
 	.set_mdio_dir = mdio_dir,
-	.set_mdio_data = mdio,
-	.get_mdio_data = mdio_read,
+	.set_mdio_data = mdio_set,
+	.get_mdio_data = mdio_get,
 };
 
-static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
-                                         struct device_node *np)
+static void __devinit add_phy(struct mii_bus *bus, unsigned int phy_addr,
+			      int phy_irq)
 {
-	struct mdio_gpio_info *bitbang = bus->priv;
-
-	bitbang->mdc = of_get_gpio(np, 0);
-	bitbang->mdio = of_get_gpio(np, 1);
-
-	if (bitbang->mdc < 0 || bitbang->mdio < 0)
-		return -ENODEV;
-
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
-	return 0;
-}
-
-static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
-{
-	const u32 *data;
-	int len, id, irq;
-
-	data = of_get_property(np, "reg", &len);
-	if (!data || len != 4)
+	if (phy_addr >= PHY_MAX_ADDR) {
+		dev_err(bus->parent,
+			"Failed to add phy with invalid address: 0x%x",
+			phy_addr);
 		return;
+	}
 
-	id = *data;
-	bus->phy_mask &= ~(1 << id);
+	bus->phy_mask &= ~(1 << phy_addr);
 
-	irq = of_irq_to_resource(np, 0, NULL);
-	if (irq != NO_IRQ)
-		bus->irq[id] = irq;
+	if (phy_irq)
+		bus->irq[phy_addr] = phy_irq;
 }
 
+#ifdef CONFIG_OF_GPIO
 static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
                                         const struct of_device_id *match)
 {
 	struct device_node *np = NULL;
+	struct device *dev = &ofdev->dev;
+#else
+static int __devinit mdio_gpio_probe(struct platform_device *pdev)
+{
+	struct mdio_gpio_platform_data *pdata;
+	struct device *dev = &pdev->dev;
+#endif
 	struct mii_bus *new_bus;
 	struct mdio_gpio_info *bitbang;
 	int ret = -ENOMEM;
 	int i;
 
-	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
+	bitbang = kzalloc(sizeof(*bitbang), GFP_KERNEL);
 	if (!bitbang)
 		goto out;
 
@@ -124,36 +126,74 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 	if (!new_bus)
 		goto out_free_bitbang;
 
-	new_bus->name = "GPIO Bitbanged MII",
+	new_bus->name = "GPIO Bitbanged MDIO",
 
-	ret = mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
-	if (ret)
-		goto out_free_bus;
+	ret = -ENODEV;
 
 	new_bus->phy_mask = ~0;
-	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
-	if (!new_bus->irq)
-		goto out_free_bus;
+	new_bus->irq = bitbang->irq;
+	new_bus->parent = dev;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
-		new_bus->irq[i] = -1;
+		new_bus->irq[i] = PHY_POLL;
+
+#ifdef CONFIG_OF_GPIO
+	bitbang->mdc = of_get_gpio(ofdev->node, 0);
+	bitbang->mdio = of_get_gpio(ofdev->node, 1);
+
+	if (bitbang->mdc < 0 || bitbang->mdio < 0)
+		goto out_free_bus;
+
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
 
 	while ((np = of_get_next_child(ofdev->node, np)))
-		if (!strcmp(np->type, "ethernet-phy"))
-			add_phy(new_bus, np);
+		if (!strcmp(np->type, "ethernet-phy")) {
+			const u32 *data;
+			int len;
+
+			data = of_get_property(np, "reg", &len);
+			if (!data || len != 4)
+				continue;
+
+			add_phy(new_bus, *data,
+				of_irq_to_resource(np, 0, NULL));
+		}
+#else
+	pdata = dev->platform_data;
+	if (pdata == NULL)
+		goto out_free_bus;
+
+	bitbang->mdc = pdata->mdc;
+	bitbang->mdio = pdata->mdio;
 
-	new_bus->parent = &ofdev->dev;
-	dev_set_drvdata(&ofdev->dev, new_bus);
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", pdev->id);
+
+	for (i = 0; i < pdata->nr_phys; i++)
+		add_phy(new_bus, pdata->phys[i].addr, pdata->phys[i].irq);
+#endif
+
+	if (new_bus->phy_mask == ~0)
+		goto out_free_bus;
+
+	if (gpio_request(bitbang->mdc, "mdc"))
+		goto out_free_bus;
+
+	if (gpio_request(bitbang->mdio, "mdio"))
+		goto out_free_mdc;
+
+	dev_set_drvdata(dev, new_bus);
 
 	ret = mdiobus_register(new_bus);
 	if (ret)
-		goto out_free_irqs;
+		goto out_free_all;
 
 	return 0;
 
-out_free_irqs:
-	dev_set_drvdata(&ofdev->dev, NULL);
-	kfree(new_bus->irq);
+out_free_all:
+	dev_set_drvdata(dev, NULL);
+	gpio_free(bitbang->mdio);
+out_free_mdc:
+	gpio_free(bitbang->mdc);
 out_free_bus:
 	free_mdio_bitbang(new_bus);
 out_free_bitbang:
@@ -162,20 +202,29 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_OF_GPIO
 static int mdio_ofgpio_remove(struct of_device *ofdev)
 {
-	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
+	struct device *dev = &ofdev->dev;
+#else
+static int __devexit mdio_gpio_remove(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+#endif
+	struct mii_bus *bus = dev_get_drvdata(dev);
 	struct mdio_gpio_info *bitbang = bus->priv;
 
 	mdiobus_unregister(bus);
-	kfree(bus->irq);
 	free_mdio_bitbang(bus);
-	dev_set_drvdata(&ofdev->dev, NULL);
+	dev_set_drvdata(dev, NULL);
+	gpio_free(bitbang->mdc);
+	gpio_free(bitbang->mdio);
 	kfree(bitbang);
 
 	return 0;
 }
 
+#ifdef CONFIG_OF_GPIO
 static struct of_device_id mdio_ofgpio_match[] = {
 	{
 		.compatible = "virtual,mdio-gpio",
@@ -190,15 +239,42 @@ static struct of_platform_driver mdio_ofgpio_driver = {
 	.remove = mdio_ofgpio_remove,
 };
 
-static int mdio_ofgpio_init(void)
+static int __init mdio_ofgpio_init(void)
 {
 	return of_register_platform_driver(&mdio_ofgpio_driver);
 }
+module_init(mdio_ofgpio_init);
 
-static void mdio_ofgpio_exit(void)
+static void __exit mdio_ofgpio_exit(void)
 {
 	of_unregister_platform_driver(&mdio_ofgpio_driver);
 }
-
-module_init(mdio_ofgpio_init);
 module_exit(mdio_ofgpio_exit);
+#else
+static struct platform_driver mdio_gpio_driver = {
+	.probe = mdio_gpio_probe,
+	.remove = __devexit_p(mdio_gpio_remove),
+	.driver		= {
+		.name	= "mdio-gpio",
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init mdio_gpio_init(void)
+{
+	return platform_driver_register(&mdio_gpio_driver);
+}
+module_init(mdio_gpio_init);
+
+static void __exit mdio_gpio_exit(void)
+{
+	platform_driver_unregister(&mdio_gpio_driver);
+}
+module_exit(mdio_gpio_exit);
+
+MODULE_ALIAS("platform:mdio-gpio");
+#endif /* CONFIG_OF_GPIO */
+
+MODULE_AUTHOR("Laurent Pinchart, Paulius Zaleckas");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Generic driver for MDIO bus emulation using GPIO");
diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
new file mode 100644
index 0000000..6a8258d
--- /dev/null
+++ b/include/linux/mdio-gpio.h
@@ -0,0 +1,30 @@
+/*
+ * MDIO-GPIO bus platform data structures
+ *
+ * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#ifndef __LINUX_MDIO_GPIO_H
+#define __LINUX_MDIO_GPIO_H
+
+struct mdio_gpio_phy {
+	/* PHY address on MDIO bus */
+	unsigned int addr;
+	/* preconfigured irq connected to PHY */
+	int irq;
+};
+
+struct mdio_gpio_platform_data {
+	/* GPIO numbers for bus pins */
+	unsigned int mdc;
+	unsigned int mdio;
+
+	unsigned int nr_phys;
+	struct mdio_gpio_phy *phys;
+};
+
+#endif /* __LINUX_MDIO_GPIO_H */
