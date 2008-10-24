From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] phylib: add mdio-gpio bus driver
Date: Fri, 24 Oct 2008 18:21:12 +0300
Message-ID: <20081024152112.11695.74341.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:43897 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753369AbYJXPVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 11:21:13 -0400
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 24 Oct 2008 15:20:09 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Useful for machines where PHY control is connected to GPIO.
This driver also supports interrupts from PHY.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---

 drivers/net/phy/Kconfig     |    6 +
 drivers/net/phy/Makefile    |    1 
 drivers/net/phy/mdio-gpio.c |  202 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 209 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/mdio-gpio.c


diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d55932a..b6a0350 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -84,6 +84,12 @@ config MDIO_BITBANG
 
 	  If in doubt, say N.
 
+config MDIO_GPIO
+	tristate "Support for GPIO bitbanged MDIO buses"
+	depends on MDIO_BITBANG && GENERIC_GPIO
+	help
+	  Supports MDIO busses connected to GPIO.
+
 config MDIO_OF_GPIO
 	tristate "Support for GPIO lib-based bitbanged MDIO buses"
 	depends on MDIO_BITBANG && OF_GPIO
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index eee329f..8629b09 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -15,4 +15,5 @@ obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
+obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_MDIO_OF_GPIO)	+= mdio-ofgpio.o
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
new file mode 100644
index 0000000..d98046f
--- /dev/null
+++ b/drivers/net/phy/mdio-gpio.c
@@ -0,0 +1,202 @@
+/*
+ * GPIO based MDIO bitbang driver.
+ *
+ * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
+ *
+ * Based on mdio-ofgpio.c:
+ *
+ * Copyright (c) 2008 CSE Semaphore Belgium.
+ *  by Laurent Pinchart <laurentp@cse-semaphore.com>
+ *
+ * Copyright (c) 2003 Intracom S.A.
+ *  by Pantelis Antoniou <panto@intracom.gr>
+ *
+ * 2005 (c) MontaVista Software, Inc.
+ * Vitaly Bordug <vbordug@ru.mvista.com>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/gpio.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/mdio-gpio.h>
+
+struct mdio_gpio_info {
+	struct mdiobb_ctrl ctrl;
+	unsigned int mdc, mdio;
+};
+
+static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	if (dir)
+		gpio_direction_output(bitbang->mdio, 1);
+	else
+		gpio_direction_input(bitbang->mdio);
+}
+
+static int mdio_read(struct mdiobb_ctrl *ctrl)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	return gpio_get_value(bitbang->mdio);
+}
+
+static void mdio(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	gpio_set_value(bitbang->mdio, what);
+}
+
+static void mdc(struct mdiobb_ctrl *ctrl, int what)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(ctrl, struct mdio_gpio_info, ctrl);
+
+	gpio_set_value(bitbang->mdc, what);
+}
+
+static struct mdiobb_ops mdio_gpio_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = mdc,
+	.set_mdio_dir = mdio_dir,
+	.set_mdio_data = mdio,
+	.get_mdio_data = mdio_read,
+};
+
+static int __devinit mdio_gpio_bitbang_init(struct mii_bus *bus, void *data)
+{
+	struct mdio_gpio_info *bitbang =
+		container_of(bus->priv, struct mdio_gpio_info, ctrl);
+	struct mdio_gpio_platform_data *pdata = data;
+	unsigned int i;
+
+	if (pdata == NULL)
+		goto out;
+
+	bitbang->mdc = pdata->mdc;
+	bitbang->mdio = pdata->mdio;
+
+	if (gpio_request(bitbang->mdc, "mdc"))
+		goto out;
+
+	if (gpio_request(bitbang->mdio, "mdio"))
+		goto out_free_mdc;
+
+	for (i = 0; i < pdata->nr_phys; i++) {
+		unsigned int phy_addr = pdata->phys[i].addr;
+
+		BUG_ON(phy_addr >= PHY_MAX_ADDR);
+
+		bus->phy_mask &= ~(1 << phy_addr);
+		bus->irq[phy_addr] = pdata->phys[i].irq;
+	}
+
+	return 0;
+
+out_free_mdc:
+	gpio_free(bitbang->mdc);
+out:
+	return -ENODEV;
+}
+
+static int __devinit mdio_gpio_probe(struct platform_device *pdev)
+{
+	struct mii_bus *new_bus;
+	struct mdio_gpio_info *bitbang;
+	int ret = -ENOMEM;
+	int i;
+
+	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
+	if (!bitbang)
+		goto out;
+
+	bitbang->ctrl.ops = &mdio_gpio_ops;
+
+	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
+	if (!new_bus)
+		goto out_free_bitbang;
+
+	new_bus->name = "GPIO Bitbanged MII",
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", pdev->id);
+
+	new_bus->phy_mask = ~0;
+	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!new_bus->irq)
+		goto out_free_bus;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		new_bus->irq[i] = PHY_POLL;
+
+	ret = mdio_gpio_bitbang_init(new_bus, pdev->dev.platform_data);
+	if (ret)
+		goto out_free_irqs;
+
+	new_bus->dev = &pdev->dev;
+	platform_set_drvdata(pdev, new_bus);
+
+	ret = mdiobus_register(new_bus);
+	if (ret)
+		goto out_free_all;
+
+	return 0;
+
+out_free_all:
+	platform_set_drvdata(pdev, NULL);
+out_free_irqs:
+	kfree(new_bus->irq);
+out_free_bus:
+	free_mdio_bitbang(new_bus);
+out_free_bitbang:
+	kfree(bitbang);
+out:
+	return ret;
+}
+
+static int __devexit mdio_gpio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+	struct mdio_gpio_info *bitbang = bus->priv;
+
+	mdiobus_unregister(bus);
+	kfree(bus->irq);
+	free_mdio_bitbang(bus);
+	platform_set_drvdata(pdev, NULL);
+	gpio_free(bitbang->mdc);
+	gpio_free(bitbang->mdio);
+	kfree(bitbang);
+
+	return 0;
+}
+
+static struct platform_driver mdio_gpio_driver = {
+	.probe = mdio_gpio_probe,
+	.remove = __devexit_p(mdio_gpio_remove),
+	.driver		= {
+		.name	= "mdio-gpio",
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int mdio_gpio_init(void)
+{
+	return platform_driver_register(&mdio_gpio_driver);
+}
+
+static void mdio_gpio_exit(void)
+{
+	platform_driver_unregister(&mdio_gpio_driver);
+}
+
+module_init(mdio_gpio_init);
+module_exit(mdio_gpio_exit);

