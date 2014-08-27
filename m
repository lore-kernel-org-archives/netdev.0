From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v2] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 27 Aug 2014 06:55:27 +0000
Message-ID: <1409122527-17673-1-git-send-email-romain.perier@gmail.com>
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	arnd@arndb.de
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33975 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689AbaH0Gz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:55:26 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so15415437wgh.10
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 23:55:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch defines a platform glue layer for Rockchip SoCs which
support arc-emac driver. It ensures that regulator for the rmii is on
before trying to connect to the ethernet controller. It applies right
speed and mode changes to the grf when ethernet settings change.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/arc/Kconfig         |  15 +++
 drivers/net/ethernet/arc/Makefile        |   1 +
 drivers/net/ethernet/arc/emac.h          |   2 +
 drivers/net/ethernet/arc/emac_main.c     |   2 +
 drivers/net/ethernet/arc/emac_rockchip.c | 224 +++++++++++++++++++++++++++++++
 5 files changed, 244 insertions(+)
 create mode 100644 drivers/net/ethernet/arc/emac_rockchip.c

diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index 89e04fd..6d96a82 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -32,4 +32,19 @@ config ARC_EMAC
 	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
 	  Say Y here if you have such a board.  If unsure, say N.
 
+config EMAC_ROCKCHIP
+       tristate "Rockchip EMAC support"
+       select ARC_EMAC_CORE
+       depends on OF_IRQ
+       depends on OF_NET
+       depends on ARCH_ROCKCHIP
+       depends on REGULATOR_ACT8865
+       depends on SMSC_PHY
+       depends on MFD_SYSCON
+       ---help---
+         Support for Rockchip RK3066/RK3188 EMAC ethernet controllers.
+         This selects Rockchip SoC glue layer support for the
+         emac device driver. This driver is used for RK3066/RK3188
+         EMAC ethernet controller.
+
 endif # NET_VENDOR_ARC
diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
index 241bb80..79108af 100644
--- a/drivers/net/ethernet/arc/Makefile
+++ b/drivers/net/ethernet/arc/Makefile
@@ -5,3 +5,4 @@
 arc_emac-objs := emac_main.o emac_mdio.o
 obj-$(CONFIG_ARC_EMAC_CORE) += arc_emac.o
 obj-$(CONFIG_ARC_EMAC) += emac_arc.o
+obj-$(CONFIG_EMAC_ROCKCHIP) += emac_rockchip.o
diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 164b1c7..2bfe8c76 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -127,6 +127,8 @@ struct buffer_state {
 struct arc_emac_priv {
 	const char *drv_name;
 	const char *drv_version;
+	void (*set_mac_speed)(void *priv, unsigned int speed);
+
 	/* Devices */
 	struct device *dev;
 	struct phy_device *phy_dev;
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index b35c69e..a08f343 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -48,6 +48,8 @@ static void arc_emac_adjust_link(struct net_device *ndev)
 	if (priv->speed != phy_dev->speed) {
 		priv->speed = phy_dev->speed;
 		state_changed = 1;
+		if (priv->set_mac_speed)
+			priv->set_mac_speed(priv, priv->speed);
 	}
 
 	if (priv->duplex != phy_dev->duplex) {
diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
new file mode 100644
index 0000000..ff1a657
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac_rockchip.c
@@ -0,0 +1,224 @@
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
+#include <linux/etherdevice.h>
+#include <linux/mfd/syscon.h>
+#include <linux/module.h>
+#include <linux/of_net.h>
+#include <linux/platform_device.h>
+#include <linux/regmap.h>
+#include <linux/regulator/consumer.h>
+
+#include "emac.h"
+
+#define DRV_NAME        "rockchip_emac"
+#define DRV_VERSION     "1.0"
+
+#define GRF_MODE_MII   BIT(0)
+#define GRF_MODE_RMII  0x0
+#define GRF_SPEED_10M  0x0
+#define GRF_SPEED_100M BIT(1)
+
+struct emac_rockchip_soc_data {
+	int grf_offset;
+};
+
+struct rockchip_priv_data {
+	struct arc_emac_priv emac;
+	struct regmap *grf;
+	struct emac_rockchip_soc_data *soc_data;
+	struct regulator *regulator;
+	struct clk *refclk;
+};
+
+static const struct of_device_id emac_rockchip_dt_ids[];
+
+static void emac_rockchip_set_mac_speed(void *priv, unsigned int speed)
+{
+	struct rockchip_priv_data *emac = priv;
+	u32 data;
+	int err = 0;
+
+	/* write-enable bits */
+	data = BIT(17);
+
+	switch(speed) {
+	case 10:
+		data |= GRF_SPEED_10M;
+		break;
+	case 100:
+		data |= GRF_SPEED_100M;
+		break;
+	default:
+		pr_err("speed %u not supported\n", speed);
+		return;
+	}
+
+	err = regmap_write(emac->grf, emac->soc_data->grf_offset, data);
+	if (err)
+		pr_err("unable to apply speed %u to grf (%d)\n", speed, err);
+}
+
+static int emac_rockchip_probe(struct platform_device *pdev)
+{
+	struct device *dev = &pdev->dev;
+	struct net_device *ndev;
+	struct rockchip_priv_data *priv;
+	const struct of_device_id *match;
+	u32 data, rate;
+	int err, interface;
+
+	if (!pdev->dev.of_node)
+		return -ENODEV;
+
+	ndev = alloc_etherdev(sizeof(struct rockchip_priv_data));
+	if (!ndev)
+		return -ENOMEM;
+	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, dev);
+
+	priv = netdev_priv(ndev);
+	priv->emac.drv_name = DRV_NAME;
+	priv->emac.drv_version = DRV_VERSION;
+	priv->emac.set_mac_speed = emac_rockchip_set_mac_speed;
+
+	interface = of_get_phy_mode(dev->of_node);
+
+	/* RK3066 and RK3188 SoCs only support RMII */
+	if (interface != PHY_INTERFACE_MODE_RMII) {
+		dev_err(dev, "unsupported phy interface mode %d\n", interface);
+		err = -ENOTSUPP;
+		goto out_netdev;
+	}
+
+	priv->grf = syscon_regmap_lookup_by_phandle(dev->of_node, "rockchip,grf");
+	if (IS_ERR(priv->grf)) {
+		dev_err(dev, "failed to retrieve global register file from the device tree (%ld)\n", PTR_ERR(priv->grf));
+		err = PTR_ERR(priv->grf);
+		goto out_netdev;
+	}
+
+	match = of_match_node(emac_rockchip_dt_ids, dev->of_node);
+	priv->soc_data = (struct emac_rockchip_soc_data *)match->data;
+
+	priv->emac.clk = devm_clk_get(dev, "hclk");
+	if (IS_ERR(priv->emac.clk)) {
+		dev_err(dev, "failed to retrieve host clock from device tree (%ld)\n", PTR_ERR(priv->emac.clk));
+		err = PTR_ERR(priv->emac.clk);
+		goto out_netdev;
+	}
+
+	priv->refclk = devm_clk_get(dev, "macref");
+	if (IS_ERR(priv->refclk)) {
+		dev_err(dev, "failed to retrieve reference clock from device tree (%ld)\n", PTR_ERR(priv->refclk));
+		err = PTR_ERR(priv->refclk);
+		goto out_netdev;
+	}
+
+	err = clk_prepare_enable(priv->refclk);
+	if (err) {
+		dev_err(dev, "failed to enable reference clock (%d)\n", err);
+		goto out_netdev;
+	}
+
+        /* Optional regulator for PHY */
+	priv->regulator = devm_regulator_get_optional(dev, "phy");
+	if (IS_ERR(priv->regulator)) {
+		if (PTR_ERR(priv->regulator) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		dev_err(dev, "no regulator found\n");
+		priv->regulator = NULL;
+	}
+
+	if (priv->regulator) {
+		err = regulator_enable(priv->regulator);
+		if (err) {
+			dev_err(dev, "failed to enable phy-supply (%d)\n", err);
+			goto out_netdev;
+		}
+	}
+
+	err = arc_emac_probe(ndev, interface);
+	if (err)
+		goto out_netdev;
+
+	/* write-enable bits */
+	data = BIT(16) | BIT(17);
+
+	data |= GRF_SPEED_100M;
+	data |= GRF_MODE_RMII;
+	rate = 50000000;
+
+	err = regmap_write(priv->grf, priv->soc_data->grf_offset, data);
+	if (err) {
+		dev_err(dev, "unable to apply initial settings to grf (%d)\n", err);
+		goto out_netdev;
+	}
+
+	err = clk_set_rate(priv->refclk, rate);
+	if (err)
+		dev_err(dev, "failed to change reference clock rate (%d)\n", err);
+
+out_netdev:
+	if (err)
+		free_netdev(ndev);
+	return err;
+}
+
+static int emac_rockchip_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct rockchip_priv_data *priv = netdev_priv(ndev);
+	int err;
+
+	clk_disable_unprepare(priv->refclk);
+
+	if (priv->regulator)
+		regulator_disable(priv->regulator);
+	err = arc_emac_remove(ndev);
+	free_netdev(ndev);
+	return err;
+}
+
+static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
+	{ .grf_offset = 0x154 }, /* rk3066 */
+	{ .grf_offset = 0x0a4 }, /* rk3188 */
+};
+
+static const struct of_device_id emac_rockchip_dt_ids[] = {
+	{ .compatible = "rockchip,rk3066-emac", .data = (void *)&emac_rockchip_dt_data[0]},
+	{ .compatible = "rockchip,rk3188-emac", .data = (void *)&emac_rockchip_dt_data[1]},
+	{ /* Sentinel */ }
+};
+
+MODULE_DEVICE_TABLE(of, emac_rockchip_dt_ids);
+
+static struct platform_driver emac_rockchip_driver = {
+	.probe = emac_rockchip_probe,
+	.remove = emac_rockchip_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.of_match_table  = emac_rockchip_dt_ids,
+	},
+};
+
+module_platform_driver(emac_rockchip_driver);
+
+MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
+MODULE_DESCRIPTION("Rockchip EMAC platform driver");
+MODULE_LICENSE("GPL");
-- 
1.9.1
