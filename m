From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/4] soc: fsl: add GUTS driver for QorIQ platforms
Date: Mon, 30 May 2016 15:15:25 +0200
Message-ID: <5339448.D8rpq4ofAC@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com> <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Scott Wood <oss@buserror.net>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yangbo Lu <yangbo.lu@nxp.com>

The global utilities block controls power management, I/O device
enabling, power-onreset(POR) configuration monitoring, alternate
function selection for multiplexed signals,and clock control.

This patch adds GUTS driver to manage and access global utilities
block.

[arnd turned this into a platform_driver registering a soc_device
 rather than providing an ad-hoc interface for soc-id]

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
index cb58ef0d9b2c..7106463f118e 100644
--- a/drivers/soc/Kconfig
+++ b/drivers/soc/Kconfig
@@ -2,7 +2,7 @@ menu "SOC (System On Chip) specific Drivers"
 
 source "drivers/soc/bcm/Kconfig"
 source "drivers/soc/brcmstb/Kconfig"
-source "drivers/soc/fsl/qe/Kconfig"
+source "drivers/soc/fsl/Kconfig"
 source "drivers/soc/mediatek/Kconfig"
 source "drivers/soc/qcom/Kconfig"
 source "drivers/soc/rockchip/Kconfig"
diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
new file mode 100644
index 000000000000..33d331cac8d6
--- /dev/null
+++ b/drivers/soc/fsl/Kconfig
@@ -0,0 +1,15 @@
+#
+# Freescale SOC drivers
+#
+
+source "drivers/soc/fsl/qe/Kconfig"
+
+config FSL_GUTS
+	bool "NXP Layerscale SoC identification"
+	depends on PPC_FSL || SOC_LS1021A || ARCH_LAYERSCAPE || COMPILE_TEST
+	default PPC_FSL || SOC_LS1021A || ARCH_LAYERSCAPE
+	select SOC_BUS
+	help
+	  This registers a SoC device for NXP (formerly Freescale)
+	  Layerscape devices, making information about the system
+	  available in /sys/devices/soc/
diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
index 203307fd92c1..02afb7f980f6 100644
--- a/drivers/soc/fsl/Makefile
+++ b/drivers/soc/fsl/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_QUICC_ENGINE)		+= qe/
 obj-$(CONFIG_CPM)			+= qe/
+obj-$(CONFIG_FSL_GUTS)			+= guts.o
diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
new file mode 100644
index 000000000000..2f30698f5bcf
--- /dev/null
+++ b/drivers/soc/fsl/guts.c
@@ -0,0 +1,130 @@
+/*
+ * Freescale QorIQ Platforms GUTS Driver
+ *
+ * Copyright (C) 2016 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/io.h>
+#include <linux/platform_device.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+#include <linux/sys_soc.h>
+
+#define GUTS_PVR	0x0a0
+#define GUTS_SVR	0x0a4
+
+struct guts {
+	void __iomem *regs;
+	bool little_endian;
+	struct soc_device_attribute soc;
+};
+
+static u32 fsl_guts_get_svr(struct guts *guts)
+{
+	if (guts->little_endian)
+		return ioread32(guts->regs + GUTS_SVR);
+	else
+		return ioread32be(guts->regs + GUTS_SVR);
+}
+
+static u32 fsl_guts_get_pvr(struct guts *guts)
+{
+	if (guts->little_endian)
+		return ioread32(guts->regs + GUTS_PVR);
+	else
+		return ioread32be(guts->regs + GUTS_PVR);
+}
+
+/*
+ * Table for matching compatible strings, for device tree
+ * guts node, for Freescale QorIQ SOCs.
+ */
+static const struct of_device_id fsl_guts_of_match[] = {
+	/* For T4 & B4 Series SOCs */
+	{ .compatible = "fsl,qoriq-device-config-1.0", .data = "T4/B4 series" },
+	/* For P Series SOCs */
+	{ .compatible = "fsl,p1010-guts", .data = "P1010/P1014" },
+	{ .compatible = "fsl,p1020-guts", .data = "P1020/P1011" },
+	{ .compatible = "fsl,p1021-guts", .data = "P1021/P1012" },
+	{ .compatible = "fsl,p1022-guts", .data = "P1022/P1013" },
+	{ .compatible = "fsl,p1023-guts", .data = "P1013/P1017" },
+	{ .compatible = "fsl,p2020-guts", .data = "P2010/P2020" },
+	{ .compatible = "fsl,qoriq-device-config-2.0", .data = "P series" },
+	/* For BSC Series SOCs */
+	{ .compatible = "fsl,bsc9131-guts", .data = "BSC9131 Qonverge" },
+	{ .compatible = "fsl,bsc9132-guts", .data = "BSC9132 Qonverge" },
+	/* For MPC85xx Series SOCs */
+	{ .compatible = "fsl,mpc8536-guts", .data = "PowerPC MPC8536" },
+	{ .compatible = "fsl,mpc8544-guts", .data = "PowerPC MPC8544" },
+	{ .compatible = "fsl,mpc8548-guts", .data = "PowerPC MPC8548" },
+	{ .compatible = "fsl,mpc8568-guts", .data = "PowerPC MPC8568" },
+	{ .compatible = "fsl,mpc8569-guts", .data = "PowerPC MPC8569" },
+	{ .compatible = "fsl,mpc8572-guts", .data = "PowerPC MPC8572" },
+	/* For Layerscape Series SOCs */
+	{ .compatible = "fsl,ls1021a-dcfg", .data = "Layerscape LS1021A" },
+	{ .compatible = "fsl,ls1043a-dcfg", .data = "Layerscape LS1043A" },
+	{ .compatible = "fsl,ls2080a-dcfg", .data = "Layerscape LS2080A" },
+	{}
+};
+
+static void fsl_guts_init(struct device *dev, struct guts *guts)
+{
+	const struct of_device_id *id;
+	u32 svr = fsl_guts_get_svr(guts);
+
+	guts->soc.family = "NXP QorIQ";
+	id = of_match_node(fsl_guts_of_match, dev->of_node);
+	guts->soc.soc_id = devm_kasprintf(dev, "%s (ver 0x%06x)" id->data,
+					  svr >> 8;
+	guts->soc.revision = devm_kasprintf(dev, GFP_KERNEL, "0x%02x",
+					    svr & 0xff);
+}
+
+static int fsl_guts_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct guts *guts;
+	int ret;
+
+	guts = devm_kzalloc(dev, sizeof(*guts), GFP_KERNEL);
+	if (!guts) {
+		ret = -ENOMEM;
+		goto out;
+
+	}
+
+	/*
+	 * syscon devices default to little-endian, but on powerpc we have
+	 * existing device trees with big-endian maps and an absent endianess
+	 * "big-property"
+	 */
+	if (!IS_ENABLED(CONFIG_POWERPC) &&
+	    !of_property_read_bool(dev->of_node, "big-endian"))
+		guts->little_endian = true;
+
+	guts->regs = devm_ioremap_resource(dev, 0);
+	if (!guts->regs) {
+		ret = -ENOMEM;
+		kfree(guts);
+		goto out;
+	}
+
+	fsl_guts_init(dev, guts);
+	ret = 0;
+out:
+	return ret;
+}
+
+static struct platform_driver fsl_soc_guts = {
+	.probe = fsl_guts_probe,
+	.driver.of_match_table = fsl_guts_of_match,
+};
+
+module_platform_driver(fsl_soc_guts);

