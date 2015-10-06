From: Arun Parameswaran <arunp@broadcom.com>
Subject: [PATCH v3 2/5] net: phy: Broadcom iProc MDIO bus driver
Date: Tue, 6 Oct 2015 12:25:47 -0700
Message-ID: <1444159550-3432-3-git-send-email-arunp@broadcom.com>
References: <1444159550-3432-1-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bcm-kernel-feedback-list@broadcom.com>,
	Arun Parameswaran <arunp@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444159550-3432-1-git-send-email-arunp@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the Broadcom iProc MDIO bus interface.
The MDIO interface can be found in the Broadcom iProc family Soc's.

The MDIO bus is accessed using a combination of command and data
registers. This MDIO driver provides access to the Etherent GPHY's
connected to the MDIO bus.

Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
---
 drivers/net/phy/Kconfig          |   9 ++
 drivers/net/phy/Makefile         |   1 +
 drivers/net/phy/mdio-bcm-iproc.c | 213 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 223 insertions(+)
 create mode 100644 drivers/net/phy/mdio-bcm-iproc.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index c5ad98a..b57f6c2 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -225,6 +225,15 @@ config MDIO_BCM_UNIMAC
 	  This hardware can be found in the Broadcom GENET Ethernet MAC
 	  controllers as well as some Broadcom Ethernet switches such as the
 	  Starfighter 2 switches.
+
+config MDIO_BCM_IPROC
+	tristate "Broadcom iProc MDIO bus controller"
+	depends on ARCH_BCM_IPROC || COMPILE_TEST
+	depends on HAS_IOMEM && OF_MDIO
+	help
+	  This module provides a driver for the MDIO busses found in the
+	  Broadcom iProc SoC's.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 87f079c..f4e6eb9 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -38,3 +38,4 @@ obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
 obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
+obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
diff --git a/drivers/net/phy/mdio-bcm-iproc.c b/drivers/net/phy/mdio-bcm-iproc.c
new file mode 100644
index 0000000..c0b4e65
--- /dev/null
+++ b/drivers/net/phy/mdio-bcm-iproc.c
@@ -0,0 +1,213 @@
+/*
+ * Copyright (C) 2015 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/sched.h>
+
+#define IPROC_GPHY_MDCDIV    0x1a
+
+#define MII_CTRL_OFFSET      0x000
+
+#define MII_CTRL_DIV_SHIFT   0
+#define MII_CTRL_PRE_SHIFT   7
+#define MII_CTRL_BUSY_SHIFT  8
+
+#define MII_DATA_OFFSET      0x004
+#define MII_DATA_MASK        0xffff
+#define MII_DATA_TA_SHIFT    16
+#define MII_DATA_TA_VAL      2
+#define MII_DATA_RA_SHIFT    18
+#define MII_DATA_PA_SHIFT    23
+#define MII_DATA_OP_SHIFT    28
+#define MII_DATA_OP_WRITE    1
+#define MII_DATA_OP_READ     2
+#define MII_DATA_SB_SHIFT    30
+
+struct iproc_mdio_priv {
+	struct mii_bus *mii_bus;
+	void __iomem *base;
+};
+
+static inline int iproc_mdio_wait_for_idle(void __iomem *base)
+{
+	u32 val;
+	unsigned int timeout = 1000; /* loop for 1s */
+
+	do {
+		val = readl(base + MII_CTRL_OFFSET);
+		if ((val & BIT(MII_CTRL_BUSY_SHIFT)) == 0)
+			return 0;
+
+		usleep_range(1000, 2000);
+	} while (timeout--);
+
+	return -ETIMEDOUT;
+}
+
+static inline void iproc_mdio_config_clk(void __iomem *base)
+{
+	u32 val;
+
+	val = (IPROC_GPHY_MDCDIV << MII_CTRL_DIV_SHIFT) |
+		  BIT(MII_CTRL_PRE_SHIFT);
+	writel(val, base + MII_CTRL_OFFSET);
+}
+
+static int iproc_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct iproc_mdio_priv *priv = bus->priv;
+	u32 cmd;
+	int rc;
+
+	rc = iproc_mdio_wait_for_idle(priv->base);
+	if (rc)
+		return rc;
+
+	iproc_mdio_config_clk(priv->base);
+
+	/* Prepare the read operation */
+	cmd = (MII_DATA_TA_VAL << MII_DATA_TA_SHIFT) |
+		(reg << MII_DATA_RA_SHIFT) |
+		(phy_id << MII_DATA_PA_SHIFT) |
+		BIT(MII_DATA_SB_SHIFT) |
+		(MII_DATA_OP_READ << MII_DATA_OP_SHIFT);
+
+	writel(cmd, priv->base + MII_DATA_OFFSET);
+
+	rc = iproc_mdio_wait_for_idle(priv->base);
+	if (rc)
+		return rc;
+
+	cmd = readl(priv->base + MII_DATA_OFFSET) & MII_DATA_MASK;
+
+	return cmd;
+}
+
+static int iproc_mdio_write(struct mii_bus *bus, int phy_id,
+			    int reg, u16 val)
+{
+	struct iproc_mdio_priv *priv = bus->priv;
+	u32 cmd;
+	int rc;
+
+	rc = iproc_mdio_wait_for_idle(priv->base);
+	if (rc)
+		return rc;
+
+	iproc_mdio_config_clk(priv->base);
+
+	/* Prepare the write operation */
+	cmd = (MII_DATA_TA_VAL << MII_DATA_TA_SHIFT) |
+		(reg << MII_DATA_RA_SHIFT) |
+		(phy_id << MII_DATA_PA_SHIFT) |
+		BIT(MII_DATA_SB_SHIFT) |
+		(MII_DATA_OP_WRITE << MII_DATA_OP_SHIFT) |
+		((u32)(val) & MII_DATA_MASK);
+
+	writel(cmd, priv->base + MII_DATA_OFFSET);
+
+	rc = iproc_mdio_wait_for_idle(priv->base);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int iproc_mdio_probe(struct platform_device *pdev)
+{
+	struct iproc_mdio_priv *priv;
+	struct mii_bus *bus;
+	struct resource *res;
+	int rc;
+
+	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	priv->base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(priv->base)) {
+		dev_err(&pdev->dev, "failed to ioremap register\n");
+		return PTR_ERR(priv->base);
+	}
+
+	priv->mii_bus = mdiobus_alloc();
+	if (!priv->mii_bus) {
+		dev_err(&pdev->dev, "MDIO bus alloc failed\n");
+		return -ENOMEM;
+	}
+
+	bus = priv->mii_bus;
+	bus->priv = priv;
+	bus->name = "iProc MDIO bus";
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d", pdev->name, pdev->id);
+	bus->parent = &pdev->dev;
+	bus->read = iproc_mdio_read;
+	bus->write = iproc_mdio_write;
+
+	rc = of_mdiobus_register(bus, pdev->dev.of_node);
+	if (rc) {
+		dev_err(&pdev->dev, "MDIO bus registration failed\n");
+		goto err_iproc_mdio;
+	}
+
+	platform_set_drvdata(pdev, priv);
+
+	dev_info(&pdev->dev, "Broadcom iProc MDIO bus at 0x%p\n", priv->base);
+
+	return 0;
+
+err_iproc_mdio:
+	mdiobus_free(bus);
+	return rc;
+}
+
+static int iproc_mdio_remove(struct platform_device *pdev)
+{
+	struct iproc_mdio_priv *priv = platform_get_drvdata(pdev);
+
+	mdiobus_unregister(priv->mii_bus);
+	mdiobus_free(priv->mii_bus);
+
+	return 0;
+}
+
+static const struct of_device_id iproc_mdio_of_match[] = {
+	{ .compatible = "brcm,iproc-mdio", },
+	{ /* sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, iproc_mdio_of_match);
+
+static struct platform_driver iproc_mdio_driver = {
+	.driver = {
+		.name = "iproc-mdio",
+		.of_match_table = iproc_mdio_of_match,
+	},
+	.probe = iproc_mdio_probe,
+	.remove = iproc_mdio_remove,
+};
+
+module_platform_driver(iproc_mdio_driver);
+
+MODULE_AUTHOR("Broadcom Corporation");
+MODULE_DESCRIPTION("Broadcom iProc MDIO bus controller");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:iproc-mdio");
-- 
2.5.2
