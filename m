From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
Subject: [RFC PATCH 1/2] net: macb: Add mdio driver for accessing multiple phy devices
Date: Mon, 13 Jul 2015 10:18:39 +0530
Message-ID: <1436762920-32107-2-git-send-email-punnaia@xilinx.com>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: harinik@xilinx.com, kpc528@gmail.com,
	kalluripunnaiahchoudary@gmail.com, netdev@vger.kernel.org,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: nicolas.ferre@atmel.com, michals@xilinx.com, anirudh@xilinx.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0061.outbound.protection.outlook.com ([157.56.110.61]:23211
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750786AbbGMEsz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2015 00:48:55 -0400
In-Reply-To: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add spoort for the design that has multiple ethernet
mac controllers and single mdio bus connected to multiple phy devices.
i.e mdio lines are connected to any of the ethernet mac controller and
all the phy devices will be accessed using the phy maintainance interface
in that mac controller.

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
---
 drivers/net/ethernet/cadence/Makefile    |    2 +-
 drivers/net/ethernet/cadence/macb.c      |   93 +-------------
 drivers/net/ethernet/cadence/macb.h      |    3 +-
 drivers/net/ethernet/cadence/macb_mdio.c |  204 ++++++++++++++++++++++++++++++
 4 files changed, 211 insertions(+), 91 deletions(-)
 create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c

diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
index 9068b83..73504f4 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o
-obj-$(CONFIG_MACB) += macb.o
+obj-$(CONFIG_MACB) += macb.o macb_mdio.o
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4833ba1..df1b928 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -320,7 +320,7 @@ static int macb_mii_probe(struct net_device *dev)
 	int phy_irq;
 	int ret;
 
-	phydev = phy_find_first(bp->mii_bus);
+	phydev = of_phy_find_device(bp->phy_node);
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
 		return -ENXIO;
@@ -359,89 +359,6 @@ static int macb_mii_probe(struct net_device *dev)
 	return 0;
 }
 
-int macb_mii_init(struct macb *bp)
-{
-	struct macb_platform_data *pdata;
-	struct device_node *np;
-	int err = -ENXIO, i;
-
-	/* Enable management port */
-	macb_writel(bp, NCR, MACB_BIT(MPE));
-
-	bp->mii_bus = mdiobus_alloc();
-	if (bp->mii_bus == NULL) {
-		err = -ENOMEM;
-		goto err_out;
-	}
-
-	bp->mii_bus->name = "MACB_mii_bus";
-	bp->mii_bus->read = &macb_mdio_read;
-	bp->mii_bus->write = &macb_mdio_write;
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		bp->pdev->name, bp->pdev->id);
-	bp->mii_bus->priv = bp;
-	bp->mii_bus->parent = &bp->dev->dev;
-	pdata = dev_get_platdata(&bp->pdev->dev);
-
-	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	if (!bp->mii_bus->irq) {
-		err = -ENOMEM;
-		goto err_out_free_mdiobus;
-	}
-
-	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
-
-	np = bp->pdev->dev.of_node;
-	if (np) {
-		/* try dt phy registration */
-		err = of_mdiobus_register(bp->mii_bus, np);
-
-		/* fallback to standard phy registration if no phy were
-		   found during dt phy registration */
-		if (!err && !phy_find_first(bp->mii_bus)) {
-			for (i = 0; i < PHY_MAX_ADDR; i++) {
-				struct phy_device *phydev;
-
-				phydev = mdiobus_scan(bp->mii_bus, i);
-				if (IS_ERR(phydev)) {
-					err = PTR_ERR(phydev);
-					break;
-				}
-			}
-
-			if (err)
-				goto err_out_unregister_bus;
-		}
-	} else {
-		for (i = 0; i < PHY_MAX_ADDR; i++)
-			bp->mii_bus->irq[i] = PHY_POLL;
-
-		if (pdata)
-			bp->mii_bus->phy_mask = pdata->phy_mask;
-
-		err = mdiobus_register(bp->mii_bus);
-	}
-
-	if (err)
-		goto err_out_free_mdio_irq;
-
-	err = macb_mii_probe(bp->dev);
-	if (err)
-		goto err_out_unregister_bus;
-
-	return 0;
-
-err_out_unregister_bus:
-	mdiobus_unregister(bp->mii_bus);
-err_out_free_mdio_irq:
-	kfree(bp->mii_bus->irq);
-err_out_free_mdiobus:
-	mdiobus_free(bp->mii_bus);
-err_out:
-	return err;
-}
-EXPORT_SYMBOL_GPL(macb_mii_init);
-
 static void macb_update_stats(struct macb *bp)
 {
 	u32 __iomem *reg = bp->regs + MACB_PFR;
@@ -2480,7 +2397,10 @@ static int macb_probe(struct platform_device *pdev)
 		goto err_out_free_netdev;
 	}
 
-	err = macb_mii_init(bp);
+	bp->phy_node = of_parse_phandle(bp->pdev->dev.of_node,
+						"phy-handle", 0);
+
+	err = macb_mii_probe(bp->dev);
 	if (err)
 		goto err_out_unregister_netdev;
 
@@ -2524,9 +2444,6 @@ static int macb_remove(struct platform_device *pdev)
 		bp = netdev_priv(dev);
 		if (bp->phy_dev)
 			phy_disconnect(bp->phy_dev);
-		mdiobus_unregister(bp->mii_bus);
-		kfree(bp->mii_bus->irq);
-		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
 		if (!IS_ERR(bp->tx_clk))
 			clk_disable_unprepare(bp->tx_clk);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index f0aa177..ba515ab 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -825,13 +825,12 @@ struct macb {
 	unsigned int		rx_frm_len_mask;
 	unsigned int		jumbo_max_len;
 	bool			isjumbo;
-
+	struct device_node *phy_node;
 	u64			ethtool_stats[GEM_STATS_LEN];
 };
 
 extern const struct ethtool_ops macb_ethtool_ops;
 
-int macb_mii_init(struct macb *bp);
 int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 struct net_device_stats *macb_get_stats(struct net_device *dev);
 void macb_set_rx_mode(struct net_device *dev);
diff --git a/drivers/net/ethernet/cadence/macb_mdio.c b/drivers/net/ethernet/cadence/macb_mdio.c
new file mode 100644
index 0000000..563ac52
--- /dev/null
+++ b/drivers/net/ethernet/cadence/macb_mdio.c
@@ -0,0 +1,204 @@
+/*
+ * Cadence Macb mdio controller driver
+ *
+ * Copyright (C) 2014 - 2015 Xilinx, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it under
+ * the terms of the GNU General Public License version 2 as published by the
+ * Free Software Foundation; either version 2 of the License, or (at your
+ * option) any later version.
+ */
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/netdevice.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include "macb.h"
+
+struct macb_mdio_data {
+	void __iomem *regs;
+	struct clk *pclk;
+	struct clk *hclk;
+};
+
+static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct macb_mdio_data *bp = bus->priv;
+	int value;
+
+	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
+			      | MACB_BF(RW, MACB_MAN_READ)
+			      | MACB_BF(PHYA, mii_id)
+			      | MACB_BF(REGA, regnum)
+			      | MACB_BF(CODE, MACB_MAN_CODE)));
+
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
+		cpu_relax();
+
+	value = MACB_BFEXT(DATA, macb_readl(bp, MAN));
+
+	return value;
+}
+
+static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+			   u16 value)
+{
+	struct macb_mdio_data *bp = bus->priv;
+
+	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
+			      | MACB_BF(RW, MACB_MAN_WRITE)
+			      | MACB_BF(PHYA, mii_id)
+			      | MACB_BF(REGA, regnum)
+			      | MACB_BF(CODE, MACB_MAN_CODE)
+			      | MACB_BF(DATA, value)));
+
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
+		cpu_relax();
+
+	return 0;
+}
+
+static u32 gem_mdc_clk_div(struct macb_mdio_data *bp)
+{
+	u32 config;
+	unsigned long pclk_hz = clk_get_rate(bp->pclk);
+
+	if (pclk_hz <= 20000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV8);
+	else if (pclk_hz <= 40000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV16);
+	else if (pclk_hz <= 80000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV32);
+	else if (pclk_hz <= 120000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV48);
+	else if (pclk_hz <= 160000000)
+		config = GEM_BF(CLK, GEM_CLK_DIV64);
+	else
+		config = GEM_BF(CLK, GEM_CLK_DIV96);
+
+	return config;
+}
+
+static int macb_mdio_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct mii_bus *bus;
+	struct macb_mdio_data *bp;
+	struct resource *res;
+	int ret;
+	u32 config, i;
+
+	bus = mdiobus_alloc_size(sizeof(*bp));
+	if (!bus)
+		return -ENOMEM;
+
+	bus->name = "macb_mii_bus";
+	bus->read = &macb_mdio_read;
+	bus->write = &macb_mdio_write;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
+	bus->parent = &pdev->dev;
+	bus->irq = devm_kzalloc(&pdev->dev, sizeof(int) * PHY_MAX_ADDR,
+				GFP_KERNEL);
+	if (!bus->irq) {
+		ret = -ENOMEM;
+		goto err_out_free_mdiobus;
+	}
+
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bus->irq[i] = PHY_POLL;
+
+	bp = bus->priv;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	bp->regs = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(bp->regs)) {
+		ret = PTR_ERR(bp->regs);
+		goto err_out_free_mdiobus;
+	}
+
+	bp->pclk = devm_clk_get(&pdev->dev, "pclk");
+	if (IS_ERR(bp->pclk)) {
+		ret = PTR_ERR(bp->pclk);
+		dev_err(&pdev->dev, "failed to get macb_clk (%u)\n", ret);
+		goto err_out_free_mdiobus;
+	}
+
+	bp->hclk = devm_clk_get(&pdev->dev, "hclk");
+	if (IS_ERR(bp->hclk)) {
+		ret = PTR_ERR(bp->hclk);
+		dev_err(&pdev->dev, "failed to get hclk (%u)\n", ret);
+		goto err_out_free_mdiobus;
+	}
+
+	ret = clk_prepare_enable(bp->pclk);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", ret);
+		goto err_out_free_mdiobus;
+	}
+
+	ret = clk_prepare_enable(bp->hclk);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to enable hclk (%u)\n", ret);
+		goto err_disable_pclk;
+	}
+
+	/* Enable management port */
+	macb_writel(bp, NCR, MACB_BIT(MPE));
+	config = gem_mdc_clk_div(bp);
+	macb_writel(bp, NCFGR, config);
+
+	ret = of_mdiobus_register(bus, np);
+	if (ret < 0)
+		goto err_out_free_mdiobus;
+
+	platform_set_drvdata(pdev, bus);
+
+	return 0;
+
+err_disable_pclk:
+	clk_disable_unprepare(bp->pclk);
+
+err_out_free_mdiobus:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int macb_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+	struct macb_mdio_data *bp = bus->priv;
+
+	mdiobus_unregister(bus);
+	clk_disable_unprepare(bp->hclk);
+	clk_disable_unprepare(bp->pclk);
+	mdiobus_free(bus);
+
+	return 0;
+}
+
+static const struct of_device_id macb_mdio_dt_ids[] = {
+	{ .compatible = "cdns,macb-mdio" },
+
+};
+MODULE_DEVICE_TABLE(of, macb_mdio_dt_ids);
+
+static struct platform_driver macb_mdio_driver = {
+	.probe = macb_mdio_probe,
+	.remove = macb_mdio_remove,
+	.driver = {
+		.name = "macb-mdio",
+		.of_match_table = macb_mdio_dt_ids,
+	},
+};
+
+module_platform_driver(macb_mdio_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
+MODULE_AUTHOR("Xilinx");
-- 
1.7.4
