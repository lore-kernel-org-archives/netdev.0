From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 01/11] net: phy: add generic UniMAC MDIO bus driver
Date: Tue, 13 May 2014 22:00:27 -0700
Message-ID: <1400043637-9799-2-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:39233 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaENFBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:13 -0400
Received: by mail-pb0-f43.google.com with SMTP id up15so1200900pbc.30
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:12 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a generic UniMAC MDIO bus driver which can be used by the BCMGENET
driver as-is, and with some extend by the Starfighter 2 MDIO bus
controller.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../bindings/net/broadcom-mdio-unimac.txt          |  33 ++++
 drivers/net/phy/Kconfig                            |   6 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-unimac.c                      | 210 +++++++++++++++++++++
 4 files changed, 250 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt
 create mode 100644 drivers/net/phy/mdio-unimac.c

diff --git a/Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt b/Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt
new file mode 100644
index 000000000000..ac5767552960
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/broadcom-mdio-unimac.txt
@@ -0,0 +1,33 @@
+* Broadcom UniMAC MDIO bus controller
+
+Required properties:
+- compatible: should be "brcm,unimac-mdio"
+- reg: address and length of the regsiter set for the device, first one is the
+  base register, and the second one is optional and for indirect accesses
+- reg-names: name(s) of the register must be "mdio" and optional "mdio_indir_rw"
+- #size-cells: must be 1
+- #address-cells: must be 0
+
+Optional properties:
+- interrupts: must be two interrupts, one for MDIO done, one for MDIO error
+- interrupt-names: must be "mdio_done" for the first interrupt and "mdio_error"
+  for the second
+
+Child nodes of this MDIO bus controller node are standard Ethernet PHY device
+nodes as described in Documentation/devicetree/bindings/net/phy.txt
+
+Example:
+
+mdio@403c0 {
+	compatible = "brcm,unimac-mdio";
+	reg = <0x403c0 0x8 0x40300 0x18>;
+	reg-names = "mdio", "mdio_indir_rw";
+	#size-cells = <1>;
+	#address-cells = <0>;
+
+	...
+	phy@0 {
+		compatible = "ethernet-phy-ieee802.3-c22";
+		reg = <0>;
+	};
+};
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6a17f92153b3..6ad46e27b8ca 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -199,6 +199,12 @@ config MDIO_BUS_MUX_MMIOREG
 
 	  Currently, only 8-bit registers are supported.
 
+config MDIO_UNIMAC
+	tristate "Broadcom UniMAC MDIO bus controller"
+	help
+	  This module provides a driver for the Broadcom UniMAC MDIO busses.
+	  It is required by the Broadcom GENET Ethernet device drivers.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 07d24024863e..0f132ebd16f5 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -33,3 +33,4 @@ obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
 obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
 obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
 obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
+obj-$(CONFIG_MDIO_UNIMAC)	+= mdio-unimac.o
diff --git a/drivers/net/phy/mdio-unimac.c b/drivers/net/phy/mdio-unimac.c
new file mode 100644
index 000000000000..fb59e8049c41
--- /dev/null
+++ b/drivers/net/phy/mdio-unimac.c
@@ -0,0 +1,210 @@
+/*
+ * Broadcom UniMAC MDIO bus controller driver
+ *
+ * Copyright (C) 2014, Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/of_mdio.h>
+
+#define MDIO_CMD		0x00
+#define  MDIO_START_BUSY	(1 << 29)
+#define  MDIO_READ_FAIL		(1 << 28)
+#define  MDIO_RD		(2 << 26)
+#define  MDIO_WR		(1 << 26)
+#define  MDIO_PMD_SHIFT		21
+#define  MDIO_PMD_MASK		0x1F
+#define  MDIO_REG_SHIFT		16
+#define  MDIO_REG_MASK		0x1F
+
+#define MDIO_CFG		0x04
+#define  MDIO_C22		(1 << 0)
+#define  MDIO_C45		0
+#define  MDIO_CLK_DIV_SHIFT	4
+#define  MDIO_CLK_DIV_MASK	0x3F
+#define  MDIO_SUPP_PREAMBLE	(1 << 12)
+
+struct unimac_mdio_priv {
+	struct mii_bus		*mii_bus;
+	void __iomem		*base;
+	unsigned int		complete_handler;
+};
+
+static inline void unimac_mdio_start(struct unimac_mdio_priv *priv)
+{
+	u32 reg;
+
+	reg = __raw_readl(priv->base + MDIO_CMD);
+	reg |= MDIO_START_BUSY;
+	__raw_writel(reg, priv->base + MDIO_CMD);
+}
+
+static inline unsigned int unimac_mdio_busy(struct unimac_mdio_priv *priv)
+{
+	return __raw_readl(priv->base + MDIO_CMD) & MDIO_START_BUSY;
+}
+
+static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct unimac_mdio_priv *priv = bus->priv;
+	unsigned int timeout = 1000;
+	u32 cmd;
+
+	/* Prepare the read operation */
+	cmd = MDIO_RD | (phy_id << MDIO_PMD_SHIFT) | (reg << MDIO_REG_SHIFT);
+	__raw_writel(cmd, priv->base + MDIO_CMD);
+
+	/* Start MDIO transaction */
+	unimac_mdio_start(priv);
+
+	do {
+		if (!unimac_mdio_busy(priv))
+			break;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	if (!timeout)
+		return -ETIMEDOUT;
+
+	cmd = __raw_readl(priv->base + MDIO_CMD);
+	if (cmd & MDIO_READ_FAIL)
+		return -EIO;
+
+	return cmd & 0xffff;
+}
+
+static int unimac_mdio_write(struct mii_bus *bus, int phy_id,
+			int reg, u16 val)
+{
+	struct unimac_mdio_priv *priv = bus->priv;
+	unsigned int timeout = 1000;
+	u32 cmd;
+
+	/* Prepare the write operation */
+	cmd = MDIO_WR | (phy_id << MDIO_PMD_SHIFT) |
+		(reg << MDIO_REG_SHIFT) | (0xffff & val);
+	__raw_writel(cmd, priv->base + MDIO_CMD);
+
+	unimac_mdio_start(priv);
+
+	do {
+		if (!unimac_mdio_busy(priv))
+			break;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	if (!timeout)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int unimac_mdio_probe(struct platform_device *pdev)
+{
+	struct unimac_mdio_priv *priv;
+	struct device_node *np;
+	struct mii_bus *bus;
+	struct resource *r;
+	int ret;
+
+	np = pdev->dev.of_node;
+
+	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
+	/* Just ioremap, as this MDIO block is usually integrated into an
+	 * Ethernet MAC controller register range
+	 */
+	priv->base = devm_ioremap(&pdev->dev, r->start, resource_size(r));
+	if (!priv->base) {
+		dev_err(&pdev->dev, "failed to remap register\n");
+		return -ENOMEM;
+	}
+
+	priv->mii_bus = mdiobus_alloc();
+	if (!priv->mii_bus)
+		return -ENOMEM;
+
+	bus = priv->mii_bus;
+	bus->priv = priv;
+	bus->name = "unimac MII bus";
+	bus->parent = &pdev->dev;
+	bus->read = unimac_mdio_read;
+	bus->write = unimac_mdio_write;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+
+	bus->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	if (!bus->irq) {
+		ret = -ENOMEM;
+		goto out_mdio_free;
+	}
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret) {
+		dev_err(&pdev->dev, "MDIO bus registration failed\n");
+		goto out_mdio_irq;
+	}
+
+	platform_set_drvdata(pdev, priv);
+
+	dev_info(&pdev->dev, "Broadcom UniMAC MDIO bus at 0x%p\n", priv->base);
+
+	return 0;
+
+out_mdio_irq:
+	kfree(bus->irq);
+out_mdio_free:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int unimac_mdio_remove(struct platform_device *pdev)
+{
+	struct unimac_mdio_priv *priv = platform_get_drvdata(pdev);
+
+	mdiobus_unregister(priv->mii_bus);
+	kfree(priv->mii_bus->irq);
+	mdiobus_free(priv->mii_bus);
+
+	return 0;
+}
+
+static struct of_device_id unimac_mdio_ids[] = {
+	{ .compatible = "brcm,genet-mdio-v4", },
+	{ .compatible = "brcm,unimac-mdio", },
+};
+
+static struct platform_driver unimac_mdio_driver = {
+	.driver = {
+		.name = "unimac-mdio",
+		.owner = THIS_MODULE,
+		.of_match_table = unimac_mdio_ids,
+	},
+	.probe	= unimac_mdio_probe,
+	.remove	= unimac_mdio_remove,
+};
+module_platform_driver(unimac_mdio_driver);
+
+MODULE_AUTHOR("Broadcom Corporation");
+MODULE_DESCRIPTION("Broadcom UniMAC MDIO bus controller");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:unimac-mdio");
-- 
1.9.1
