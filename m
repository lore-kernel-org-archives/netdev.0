From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next v10 2/3] net: hisilicon: new hip04 MDIO driver
Date: Mon, 5 Jan 2015 14:51:30 +0800
Message-ID: <1420440691-20928-3-git-send-email-dingtianhong@huawei.com>
References: <1420440691-20928-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: <arnd-r2nGTMty4D4@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420440691-20928-1-git-send-email-dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

Hisilicon hip04 platform mdio driver
Reuse Marvell phy drivers/net/phy/marvell.c

Signed-off-by: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/hisilicon/Kconfig      |   9 ++
 drivers/net/ethernet/hisilicon/Makefile     |   1 +
 drivers/net/ethernet/hisilicon/hip04_mdio.c | 186 ++++++++++++++++++++++++++++
 3 files changed, 196 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index e942173..a54d897 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -24,4 +24,13 @@ config HIX5HD2_GMAC
 	help
 	  This selects the hix5hd2 mac family network device.
 
+config HIP04_ETH
+	tristate "HISILICON P04 Ethernet support"
+	select PHYLIB
+	select MARVELL_PHY
+	select MFD_SYSCON
+	---help---
+	  If you wish to compile a kernel for a hardware with hisilicon p04 SoC and
+	  want to use the internal ethernet then you should answer Y to this.
+
 endif # NET_VENDOR_HISILICON
diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
index 9175e846..40115a7 100644
--- a/drivers/net/ethernet/hisilicon/Makefile
+++ b/drivers/net/ethernet/hisilicon/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
+obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o
diff --git a/drivers/net/ethernet/hisilicon/hip04_mdio.c b/drivers/net/ethernet/hisilicon/hip04_mdio.c
new file mode 100644
index 0000000..b3bac25
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hip04_mdio.c
@@ -0,0 +1,186 @@
+/* Copyright (c) 2014 Linaro Ltd.
+ * Copyright (c) 2014 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/io.h>
+#include <linux/of_mdio.h>
+#include <linux/delay.h>
+
+#define MDIO_CMD_REG		0x0
+#define MDIO_ADDR_REG		0x4
+#define MDIO_WDATA_REG		0x8
+#define MDIO_RDATA_REG		0xc
+#define MDIO_STA_REG		0x10
+
+#define MDIO_START		BIT(14)
+#define MDIO_R_VALID		BIT(1)
+#define MDIO_READ	        (BIT(12) | BIT(11) | MDIO_START)
+#define MDIO_WRITE	        (BIT(12) | BIT(10) | MDIO_START)
+
+struct hip04_mdio_priv {
+	void __iomem *base;
+};
+
+#define WAIT_TIMEOUT 10
+static int hip04_mdio_wait_ready(struct mii_bus *bus)
+{
+	struct hip04_mdio_priv *priv = bus->priv;
+	int i;
+
+	for (i = 0; readl_relaxed(priv->base + MDIO_CMD_REG) & MDIO_START; i++) {
+		if (i == WAIT_TIMEOUT)
+			return -ETIMEDOUT;
+		msleep(20);
+	}
+
+	return 0;
+}
+
+static int hip04_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct hip04_mdio_priv *priv = bus->priv;
+	u32 val;
+	int ret;
+
+	ret = hip04_mdio_wait_ready(bus);
+	if (ret < 0)
+		goto out;
+
+	val = regnum | (mii_id << 5) | MDIO_READ;
+	writel_relaxed(val, priv->base + MDIO_CMD_REG);
+
+	ret = hip04_mdio_wait_ready(bus);
+	if (ret < 0)
+		goto out;
+
+	val = readl_relaxed(priv->base + MDIO_STA_REG);
+	if (val & MDIO_R_VALID) {
+		dev_err(bus->parent, "SMI bus read not valid\n");
+		ret = -ENODEV;
+		goto out;
+	}
+
+	val = readl_relaxed(priv->base + MDIO_RDATA_REG);
+	ret = val & 0xFFFF;
+out:
+	return ret;
+}
+
+static int hip04_mdio_write(struct mii_bus *bus, int mii_id,
+			    int regnum, u16 value)
+{
+	struct hip04_mdio_priv *priv = bus->priv;
+	u32 val;
+	int ret;
+
+	ret = hip04_mdio_wait_ready(bus);
+	if (ret < 0)
+		goto out;
+
+	writel_relaxed(value, priv->base + MDIO_WDATA_REG);
+	val = regnum | (mii_id << 5) | MDIO_WRITE;
+	writel_relaxed(val, priv->base + MDIO_CMD_REG);
+out:
+	return ret;
+}
+
+static int hip04_mdio_reset(struct mii_bus *bus)
+{
+	int temp, i;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++) {
+		hip04_mdio_write(bus, i, 22, 0);
+		temp = hip04_mdio_read(bus, i, MII_BMCR);
+		if (temp < 0)
+			continue;
+
+		temp |= BMCR_RESET;
+		if (hip04_mdio_write(bus, i, MII_BMCR, temp) < 0)
+			continue;
+	}
+
+	mdelay(500);
+	return 0;
+}
+
+static int hip04_mdio_probe(struct platform_device *pdev)
+{
+	struct resource *r;
+	struct mii_bus *bus;
+	struct hip04_mdio_priv *priv;
+	int ret;
+
+	bus = mdiobus_alloc_size(sizeof(struct hip04_mdio_priv));
+	if (!bus) {
+		dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
+		return -ENOMEM;
+	}
+
+	bus->name = "hip04_mdio_bus";
+	bus->read = hip04_mdio_read;
+	bus->write = hip04_mdio_write;
+	bus->reset = hip04_mdio_reset;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
+	bus->parent = &pdev->dev;
+	priv = bus->priv;
+
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	priv->base = devm_ioremap_resource(&pdev->dev, r);
+	if (IS_ERR(priv->base)) {
+		ret = PTR_ERR(priv->base);
+		goto out_mdio;
+	}
+
+	ret = of_mdiobus_register(bus, pdev->dev.of_node);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Cannot register MDIO bus (%d)\n", ret);
+		goto out_mdio;
+	}
+
+	platform_set_drvdata(pdev, bus);
+
+	return 0;
+
+out_mdio:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int hip04_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+
+	mdiobus_unregister(bus);
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static const struct of_device_id hip04_mdio_match[] = {
+	{ .compatible = "hisilicon,hip04-mdio" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, hip04_mdio_match);
+
+static struct platform_driver hip04_mdio_driver = {
+	.probe = hip04_mdio_probe,
+	.remove = hip04_mdio_remove,
+	.driver = {
+		.name = "hip04-mdio",
+		.owner = THIS_MODULE,
+		.of_match_table = hip04_mdio_match,
+	},
+};
+
+module_platform_driver(hip04_mdio_driver);
+
+MODULE_DESCRIPTION("HISILICON P04 MDIO interface driver");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:hip04-mdio");
-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
