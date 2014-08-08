From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH 2/2] ethernet: arc: Add support for Rockchip SoC glue layer device tree bindings
Date: Fri,  8 Aug 2014 12:27:55 +0000
Message-ID: <1407500875-23851-2-git-send-email-romain.perier@gmail.com>
References: <1407500875-23851-1-git-send-email-romain.perier@gmail.com>
Cc: heiko@sntech.de, max.schwarz@online.de, b.galvani@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:38049 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756142AbaHHM0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 08:26:15 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so5381684wgh.21
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 05:26:13 -0700 (PDT)
In-Reply-To: <1407500875-23851-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch defines a platform glue layer for Rockchip SoCs which support
arc-emac driver. It ensures that regulator for the rmii is on before trying
to connect to the ethernet controller. It applies right speed and mode changes
to the grf when ethernet settings changes.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3188-radxarock.dts   |   2 +
 arch/arm/boot/dts/rk3xxx.dtsi            |   3 +
 drivers/net/ethernet/arc/Kconfig         |   9 ++
 drivers/net/ethernet/arc/Makefile        |   1 +
 drivers/net/ethernet/arc/emac_rockchip.c | 191 +++++++++++++++++++++++++++++++
 5 files changed, 206 insertions(+)
 create mode 100644 drivers/net/ethernet/arc/emac_rockchip.c

diff --git a/arch/arm/boot/dts/rk3188-radxarock.dts b/arch/arm/boot/dts/rk3188-radxarock.dts
index d149155..773a433 100644
--- a/arch/arm/boot/dts/rk3188-radxarock.dts
+++ b/arch/arm/boot/dts/rk3188-radxarock.dts
@@ -110,12 +110,14 @@
 
 &emac {
 	status = "okay";
+	compatible = "rockchip,rk3188-emac";
 
 	pinctrl-names = "default";
 	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&phy_int>;
 
 	mac-address = [ c6 ef 91 8e 60 4b ];
 	phy = <&phy0>;
+	phy-supply = <&vcc_rmii>;
 
 	phy0: ethernet-phy@0 {
 		reg = <0>;
diff --git a/arch/arm/boot/dts/rk3xxx.dtsi b/arch/arm/boot/dts/rk3xxx.dtsi
index 80ed3dc..66c8b85 100644
--- a/arch/arm/boot/dts/rk3xxx.dtsi
+++ b/arch/arm/boot/dts/rk3xxx.dtsi
@@ -101,8 +101,11 @@
 		#address-cells = <1>;
 		#size-cells = <0>;
 
+		rockchip,grf = <&grf>;
+
 		clocks = <&cru HCLK_EMAC>;
 		max-speed = <100>;
+		phy-mode = "rmii";
 
 		status = "disabled";
 	};
diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index d73d971..196e9e7 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -28,4 +28,13 @@ config ARC_EMAC
 	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
 	  Say Y here if you have such a board.  If unsure, say N.
 
+config EMAC_ROCKCHIP
+       tristate "Rockchip EMAC support"
+       depends on MFD_SYSCON && ARCH_ROCKCHIP
+       ---help---
+         Support for Rockchip RK3066/RK3188 EMAC ethernet controllers.
+         This selects Rockchip SoC glue layer support for the
+         emac device driver. This driver is used for RK3066/RK3188
+         EMAC ethernet controller.
+
 endif # NET_VENDOR_ARC
diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
index b6f15b4..cf10cf3 100644
--- a/drivers/net/ethernet/arc/Makefile
+++ b/drivers/net/ethernet/arc/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_NET_VENDOR_ARC) += emac_main.o emac_mdio.o
 obj-$(CONFIG_ARC_EMAC) += emac_arc.o
+obj-$(CONFIG_EMAC_ROCKCHIP) += emac_rockchip.o
diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
new file mode 100644
index 0000000..2ea724f
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac_rockchip.c
@@ -0,0 +1,191 @@
+/**
+ * emac-rockchip.c - Rockchip EMAC specific glue layer
+ *
+ * Copyright (C) 2014 Romain Perier
+ *
+ * Romain Perier  <romain.perier@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include "emac.h"
+#include <linux/of_net.h>
+#include <linux/platform_device.h>
+#include <linux/regulator/consumer.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
+#include <linux/module.h>
+#include <linux/clk.h>
+
+#define DRV_NAME        "rockchip_emac"
+#define DRV_VERSION     "1.0"
+
+#define GRF_MODE_MII   BIT(0)
+#define GRF_MODE_RMII  0x0
+#define GRF_SPEED_10M  0x0
+#define GRF_SPEED_100M BIT(1)
+
+struct rockchip_priv_data {
+	struct regmap *grf;
+	unsigned int grf_offset;
+	int interface;
+	struct regulator *regulator;
+};
+
+static const unsigned int rockchip_emac_soc_grf_offset[] = {
+	0x154, /* rk3066 */
+	0x0a4, /* rk3188 */
+};
+
+static const struct of_device_id rockchip_emac_dt_ids[] = {
+	{ .compatible = "rockchip,rk3066-emac", .data = (void *)rockchip_emac_soc_grf_offset },
+	{ .compatible = "rockchip,rk3188-emac", .data = (void *)rockchip_emac_soc_grf_offset + 1 },
+	{ /* Sentinel */ }
+};
+
+MODULE_DEVICE_TABLE(of, rockchip_emac_dt_ids);
+
+static int rockchip_grf_set_phy_speed(const struct rockchip_priv_data *emac, unsigned int speed)
+{
+	/* write-enable bits */
+	u32 data = BIT(17) | BIT(16);
+
+	switch(speed) {
+	case 10:
+		data |= GRF_SPEED_10M << 1;
+		break;
+	case 100:
+		data |= GRF_SPEED_100M << 1;
+		break;
+	default:
+		return -ENOTSUPP;
+	}
+
+	switch(emac->interface) {
+	case PHY_INTERFACE_MODE_RMII:
+		data |= GRF_MODE_RMII;
+		break;
+	case PHY_INTERFACE_MODE_MII:
+		data |= GRF_MODE_MII;
+		break;
+	default:
+		return -ENOTSUPP;
+	}
+
+	return regmap_write(emac->grf, emac->grf_offset, data);
+}
+
+static void rockchip_set_mac_speed(void *priv, unsigned int speed)
+{
+	struct rockchip_priv_data *emac = priv;
+	int ret = 0;
+
+	ret = rockchip_grf_set_phy_speed(emac, speed);
+	if (ret) {
+		if (ret == -ENOTSUPP)
+			pr_err("phy interface (%d) or speed (%u) not supported\n", emac->interface, speed);
+		return ret;
+	}
+}
+
+static int rockchip_emac_probe(struct platform_device *pdev)
+{
+	struct rockchip_priv_data *emac = NULL;
+	struct emac_platform_data *emac_plat_data = NULL;
+	struct device *dev = &pdev->dev;
+	const struct of_device_id *match = NULL;
+	int ret = 0;
+	u32 data = 0;
+
+	emac = dev_get_platdata(dev);
+
+	if (!emac) {
+		emac = devm_kzalloc(dev, sizeof(*emac), GFP_KERNEL);
+		if (!emac)
+			return -ENOMEM;
+	}
+
+	emac_plat_data = devm_kzalloc(dev, sizeof(*emac_plat_data), GFP_KERNEL);
+	if (!emac_plat_data)
+		return -ENOMEM;
+	emac_plat_data->name = DRV_NAME;
+	emac_plat_data->version = DRV_VERSION;
+	emac_plat_data->set_mac_speed = rockchip_set_mac_speed;
+	emac_plat_data->priv = emac;
+
+	emac->interface = of_get_phy_mode(dev->of_node);
+	emac_plat_data->interface = emac->interface;
+
+	emac->grf = syscon_regmap_lookup_by_phandle(dev->of_node, "rockchip,grf");
+	if (IS_ERR(emac->grf)) {
+		dev_err(dev, "unable to find syscon grf (%ld)\n", PTR_ERR(emac->grf));
+		return PTR_ERR_OR_ZERO(emac->grf);
+	}
+
+	match = of_match_node(rockchip_emac_dt_ids, dev->of_node);
+	emac->grf_offset = *(unsigned int *)match;
+
+	emac_plat_data->clk = of_clk_get(dev->of_node, 0);
+	if (IS_ERR(emac_plat_data->clk)) {
+		dev_err(dev, "failed to retrieve clock from device tree\n");
+		return PTR_ERR_OR_ZERO(emac_plat_data->clk);
+	}
+
+        /* Optional regulator for PHY */
+	emac->regulator = devm_regulator_get_optional(dev, "phy");
+	if (IS_ERR(emac->regulator)) {
+		if (PTR_ERR(emac->regulator) == -EPROBE_DEFER)
+			return ERR_PTR(-EPROBE_DEFER);
+		dev_info(dev, "no regulator found\n");
+		emac->regulator = NULL;
+	}
+
+	if (emac->regulator) {
+		ret = regulator_enable(emac->regulator);
+		if (ret)
+			return ret;
+	}
+
+	ret = rockchip_grf_set_phy_speed(emac, 100);
+	if (ret) {
+		if (ret == -ENOTSUPP)
+			dev_err(dev, "phy interface not supported (%d)\n", emac->interface);
+		return ret;
+	}
+
+	return emac_drv_probe(dev, emac_plat_data);
+}
+
+static int rockchip_emac_remove(struct platform_device *pdev)
+{
+	struct rockchip_priv_data *emac = dev_get_platdata(&pdev->dev);
+	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
+
+	if (emac->regulator)
+		regulator_disable(emac->regulator);
+	return emac_drv_remove(ndev);
+}
+
+static struct platform_driver rockchip_emac_driver = {
+	.probe = rockchip_emac_probe,
+	.remove = rockchip_emac_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table  = rockchip_emac_dt_ids,
+	},
+};
+
+module_platform_driver(rockchip_emac_driver);
+
+MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
+MODULE_DESCRIPTION("Rockchip EMAC driver");
+MODULE_LICENSE("GPL");
-- 
1.9.1
