From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: [PATCH 3/6] net: mdio-mux: Add MDIO mux driver for NSP SoC
Date: Wed,  9 Nov 2016 04:33:11 -0500
Message-ID: <1478683994-12008-4-git-send-email-yendapally.reddy@broadcom.com>
References: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Yendapally Reddy Dhananjaya Reddy
        <yendapally.reddy@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478683994-12008-1-git-send-email-yendapally.reddy@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NSP SoC supports the mdio multiplexer which has the bus
selection  logic.

This multiplexer has child buses for PCIe, USB. The bus
could be internal or external to SOC where PHYs are attached.

Signed-off-by: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
---
 drivers/net/phy/Kconfig            |   9 +++
 drivers/net/phy/Makefile           |   1 +
 drivers/net/phy/mdio-mux-bcm-nsp.c | 121 +++++++++++++++++++++++++++++++++++++
 3 files changed, 131 insertions(+)
 create mode 100644 drivers/net/phy/mdio-mux-bcm-nsp.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 2651c8d..41cc583 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -63,6 +63,15 @@ config MDIO_BUS_MUX_BCM_IPROC
 	  child MDIO bus to a parent bus. Buses could be internal as well as
 	  external and selection logic lies inside the same multiplexer.
 
+config MDIO_BUS_MUX_BCM_NSP
+	tristate "Broadcom NSP MDIO bus controller"
+	depends on ARCH_BCM_NSP || COMPILE_TEST
+	depends on HAS_IOMEM && OF_MDIO
+	default ARCH_BCM_NSP
+	help
+	  This module provides a driver MDIO multiplexing the busses available
+	  in the Broadcom NSP SoC.
+
 config MDIO_BUS_MUX_GPIO
 	tristate "GPIO controlled MDIO bus multiplexers"
 	depends on OF_GPIO && OF_MDIO
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e58667d..d5969b2 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_MDIO_BUS_MUX)	+= mdio-mux.o
 obj-$(CONFIG_MDIO_BUS_MUX_BCM_IPROC)	+= mdio-mux-bcm-iproc.o
 obj-$(CONFIG_MDIO_BUS_MUX_GPIO)	+= mdio-mux-gpio.o
 obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
+obj-$(CONFIG_MDIO_BUS_MUX_BCM_NSP)	+= mdio-mux-bcm-nsp.o
 obj-$(CONFIG_MDIO_CAVIUM)	+= mdio-cavium.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_MDIO_HISI_FEMAC)	+= mdio-hisi-femac.o
diff --git a/drivers/net/phy/mdio-mux-bcm-nsp.c b/drivers/net/phy/mdio-mux-bcm-nsp.c
new file mode 100644
index 0000000..75dcb04
--- /dev/null
+++ b/drivers/net/phy/mdio-mux-bcm-nsp.c
@@ -0,0 +1,121 @@
+/*
+ * Copyright 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, version 2, as
+ * published by the Free Software Foundation (the "GPL").
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 (GPLv2) for more details.
+ */
+
+#include <linux/device.h>
+#include <linux/mdio-mux.h>
+#include <linux/module.h>
+#include <linux/of_address.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+
+#define NSP_MDIO_EXT_BUS_START_ADDR		16
+#define NSP_MDIO_EXT_SELECT_BIT			BIT(9)
+
+struct nsp_mdiomux_desc {
+	void __iomem *bus_ctrl;
+	void __iomem *mgmt_ctrl;
+	void *mux_handle;
+};
+
+static int mdio_mux_nsp_switch_fn(int current_child, int desired_child,
+				  void *priv)
+{
+	struct nsp_mdiomux_desc *md = priv;
+	u32 data, bus_id;
+
+	/* select internal or external bus */
+	data = readl(md->mgmt_ctrl);
+	if (desired_child == NSP_MDIO_EXT_BUS_START_ADDR)
+		data |= NSP_MDIO_EXT_SELECT_BIT;
+	else
+		data &= ~NSP_MDIO_EXT_SELECT_BIT;
+	writel(data, md->mgmt_ctrl);
+
+	/* select bus number */
+	if (md->bus_ctrl) {
+		bus_id = desired_child & (NSP_MDIO_EXT_BUS_START_ADDR - 1);
+		writel(bus_id, md->bus_ctrl);
+	}
+
+	return 0;
+}
+
+static int mdio_mux_nsp_probe(struct platform_device *pdev)
+{
+	struct nsp_mdiomux_desc *md;
+	struct resource *res;
+	int ret;
+
+	md = devm_kzalloc(&pdev->dev, sizeof(*md), GFP_KERNEL);
+	if (!md)
+		return -ENOMEM;
+
+	/* Bus control is not available in some SoC's */
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "bus-ctrl");
+	if (res) {
+		md->bus_ctrl = devm_ioremap_resource(&pdev->dev, res);
+		if (IS_ERR(md->bus_ctrl)) {
+			dev_err(&pdev->dev, "failed to ioremap register\n");
+			return PTR_ERR(md->bus_ctrl);
+		}
+	}
+
+	/* Get management control */
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "mgmt-ctrl");
+	if (!res)
+		return -EINVAL;
+
+	md->mgmt_ctrl = ioremap(res->start, resource_size(res));
+	if (!md->mgmt_ctrl)
+		return -ENOMEM;
+
+	ret = mdio_mux_init(&pdev->dev, mdio_mux_nsp_switch_fn,
+			    &md->mux_handle, md, NULL);
+	if (ret != 0) {
+		iounmap(md->mgmt_ctrl);
+		return ret;
+	}
+
+	pdev->dev.platform_data = md;
+	return 0;
+}
+
+static int mdio_mux_nsp_remove(struct platform_device *pdev)
+{
+	struct nsp_mdiomux_desc *md = dev_get_platdata(&pdev->dev);
+
+	iounmap(md->mgmt_ctrl);
+	mdio_mux_uninit(md->mux_handle);
+	return 0;
+}
+
+static const struct of_device_id mdio_mux_nsp_match[] = {
+	{ .compatible = "brcm,mdio-mux-nsp" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, mdio_mux_nsp_match);
+
+static struct platform_driver mdio_mux_nsp_driver = {
+	.driver = {
+		.name = "mdio-mux-nsp",
+		.of_match_table = mdio_mux_nsp_match,
+	},
+	.probe = mdio_mux_nsp_probe,
+	.remove = mdio_mux_nsp_remove,
+};
+
+module_platform_driver(mdio_mux_nsp_driver);
+
+MODULE_DESCRIPTION("NSP MDIO Mux Bus Driver");
+MODULE_AUTHOR("Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com");
+MODULE_LICENSE("GPL v2");
-- 
2.1.0
