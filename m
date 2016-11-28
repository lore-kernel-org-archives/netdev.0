From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 1/2] net: macb: Add MDIO driver for accessing multiple PHY devices
Date: Mon, 28 Nov 2016 15:19:14 +0530
Message-ID: <1480326554-6041-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <harinik@xilinx.com>,
        <michals@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
        <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
        <ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>,
        <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to add support for the hardware with multiple ethernet
MAC controllers and a single MDIO bus connected to multiple PHY devices.
MDIO lines are connected to any one of the ethernet MAC controllers and
all the PHY devices will be accessed using the PHY maintenance interface
in that MAC controller. This handling along with PHY functionality is
moved to macb_mdio.c

Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/ethernet/cadence/Makefile    |   2 +-
 drivers/net/ethernet/cadence/macb.c      | 169 +++-----------------
 drivers/net/ethernet/cadence/macb.h      |   2 +
 drivers/net/ethernet/cadence/macb_mdio.c | 266 +++++++++++++++++++++++++++++++
 4 files changed, 294 insertions(+), 145 deletions(-)
 create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c

diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
index 91f79b1..75c3d84 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the Atmel network device drivers.
 #
 
-obj-$(CONFIG_MACB) += macb.o
+obj-$(CONFIG_MACB) += macb.o macb_mdio.o
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 80ccfc4..ae2a797 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -232,45 +232,6 @@ static void macb_get_hwaddr(struct macb *bp)
 	eth_hw_addr_random(bp->dev);
 }
 
-static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
-{
-	struct macb *bp = bus->priv;
-	int value;
-
-	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
-			      | MACB_BF(RW, MACB_MAN_READ)
-			      | MACB_BF(PHYA, mii_id)
-			      | MACB_BF(REGA, regnum)
-			      | MACB_BF(CODE, MACB_MAN_CODE)));
-
-	/* wait for end of transfer */
-	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
-		cpu_relax();
-
-	value = MACB_BFEXT(DATA, macb_readl(bp, MAN));
-
-	return value;
-}
-
-static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
-			   u16 value)
-{
-	struct macb *bp = bus->priv;
-
-	macb_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF)
-			      | MACB_BF(RW, MACB_MAN_WRITE)
-			      | MACB_BF(PHYA, mii_id)
-			      | MACB_BF(REGA, regnum)
-			      | MACB_BF(CODE, MACB_MAN_CODE)
-			      | MACB_BF(DATA, value)));
-
-	/* wait for end of transfer */
-	while (!MACB_BFEXT(IDLE, macb_readl(bp, NSR)))
-		cpu_relax();
-
-	return 0;
-}
-
 /**
  * macb_set_tx_clk() - Set a clock to a new frequency
  * @clk		Pointer to the clock to change
@@ -385,27 +346,19 @@ static void macb_handle_link_change(struct net_device *dev)
 static int macb_mii_probe(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
-	struct macb_platform_data *pdata;
 	struct phy_device *phydev;
-	int phy_irq;
 	int ret;
 
-	phydev = phy_find_first(bp->mii_bus);
+	if (dev->phydev)
+		return 0;
+
+	phydev = of_phy_find_device(bp->phy_node);
 	if (!phydev) {
 		netdev_err(dev, "no PHY found\n");
 		return -ENXIO;
 	}
-
-	pdata = dev_get_platdata(&bp->pdev->dev);
-	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
-		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin,
-					"phy int");
-		if (!ret) {
-			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
-			phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
-		}
-	}
-
+	if (bp->phy_irq)
+		phydev->irq = bp->phy_irq;
 	/* attach the mac to the phy */
 	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change,
 				 bp->phy_interface);
@@ -429,80 +382,9 @@ static int macb_mii_probe(struct net_device *dev)
 	bp->speed = 0;
 	bp->duplex = -1;
 
-	return 0;
-}
-
-static int macb_mii_init(struct macb *bp)
-{
-	struct macb_platform_data *pdata;
-	struct device_node *np;
-	int err = -ENXIO, i;
-
-	/* Enable management port */
-	macb_writel(bp, NCR, MACB_BIT(MPE));
-
-	bp->mii_bus = mdiobus_alloc();
-	if (!bp->mii_bus) {
-		err = -ENOMEM;
-		goto err_out;
-	}
-
-	bp->mii_bus->name = "MACB_mii_bus";
-	bp->mii_bus->read = &macb_mdio_read;
-	bp->mii_bus->write = &macb_mdio_write;
-	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		 bp->pdev->name, bp->pdev->id);
-	bp->mii_bus->priv = bp;
-	bp->mii_bus->parent = &bp->pdev->dev;
-	pdata = dev_get_platdata(&bp->pdev->dev);
-
-	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
-
-	np = bp->pdev->dev.of_node;
-	if (np) {
-		/* try dt phy registration */
-		err = of_mdiobus_register(bp->mii_bus, np);
-
-		/* fallback to standard phy registration if no phy were
-		 * found during dt phy registration
-		 */
-		if (!err && !phy_find_first(bp->mii_bus)) {
-			for (i = 0; i < PHY_MAX_ADDR; i++) {
-				struct phy_device *phydev;
-
-				phydev = mdiobus_scan(bp->mii_bus, i);
-				if (IS_ERR(phydev) &&
-				    PTR_ERR(phydev) != -ENODEV) {
-					err = PTR_ERR(phydev);
-					break;
-				}
-			}
-
-			if (err)
-				goto err_out_unregister_bus;
-		}
-	} else {
-		if (pdata)
-			bp->mii_bus->phy_mask = pdata->phy_mask;
-
-		err = mdiobus_register(bp->mii_bus);
-	}
-
-	if (err)
-		goto err_out_free_mdiobus;
-
-	err = macb_mii_probe(bp->dev);
-	if (err)
-		goto err_out_unregister_bus;
+	phy_attached_info(phydev);
 
 	return 0;
-
-err_out_unregister_bus:
-	mdiobus_unregister(bp->mii_bus);
-err_out_free_mdiobus:
-	mdiobus_free(bp->mii_bus);
-err_out:
-	return err;
 }
 
 static void macb_update_stats(struct macb *bp)
@@ -2060,7 +1942,8 @@ static int macb_open(struct net_device *dev)
 	netif_carrier_off(dev);
 
 	/* if the phy is not yet register, retry later*/
-	if (!dev->phydev)
+	err = macb_mii_probe(dev);
+	if (err)
 		return -EAGAIN;
 
 	/* RX buffers initialization */
@@ -3122,16 +3005,16 @@ static int macb_probe(struct platform_device *pdev)
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
 	bool native_io;
-	struct phy_device *phydev;
 	struct net_device *dev;
 	struct resource *regs;
 	void __iomem *mem;
 	const char *mac;
 	struct macb *bp;
+	int phy_irq;
 	int err;
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	mem = devm_ioremap_resource(&pdev->dev, regs);
+	mem = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
 	if (IS_ERR(mem))
 		return PTR_ERR(mem);
 
@@ -3250,21 +3133,26 @@ static int macb_probe(struct platform_device *pdev)
 	if (err)
 		goto err_out_free_netdev;
 
-	err = macb_mii_init(bp);
-	if (err)
-		goto err_out_free_netdev;
-
-	phydev = dev->phydev;
-
-	netif_carrier_off(dev);
-
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
 		goto err_out_unregister_mdio;
 	}
 
-	phy_attached_info(phydev);
+	bp->phy_node = of_parse_phandle(bp->pdev->dev.of_node,
+					"phy-handle", 0);
+
+	pdata = dev_get_platdata(&bp->pdev->dev);
+	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
+		err = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin,
+					"phy int");
+		if (!err) {
+			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
+			bp->phy_irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
+		}
+	}
+
+	netif_carrier_off(dev);
 
 	netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
 		    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
@@ -3273,10 +3161,6 @@ static int macb_probe(struct platform_device *pdev)
 	return 0;
 
 err_out_unregister_mdio:
-	phy_disconnect(dev->phydev);
-	mdiobus_unregister(bp->mii_bus);
-	mdiobus_free(bp->mii_bus);
-
 	/* Shutdown the PHY if there is a GPIO reset */
 	if (bp->reset_gpio)
 		gpiod_set_value(bp->reset_gpio, 0);
@@ -3304,9 +3188,6 @@ static int macb_remove(struct platform_device *pdev)
 		bp = netdev_priv(dev);
 		if (dev->phydev)
 			phy_disconnect(dev->phydev);
-		mdiobus_unregister(bp->mii_bus);
-		dev->phydev = NULL;
-		mdiobus_free(bp->mii_bus);
 
 		/* Shutdown the PHY if there is a GPIO reset */
 		if (bp->reset_gpio)
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d67adad..15e5c0f 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -874,6 +874,8 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+	struct device_node *phy_node;
+	int phy_irq;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
diff --git a/drivers/net/ethernet/cadence/macb_mdio.c b/drivers/net/ethernet/cadence/macb_mdio.c
new file mode 100644
index 0000000..1277ca3
--- /dev/null
+++ b/drivers/net/ethernet/cadence/macb_mdio.c
@@ -0,0 +1,266 @@
+/*
+ * Cadence Macb mdio controller driver
+ *
+ * Copyright (C) 2014 - 2016 Xilinx, Inc.
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
+#include <linux/io.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/ptp_clock_kernel.h>
+#include "macb.h"
+
+struct macb_mdio_data {
+	void __iomem *regs;
+
+	struct clk *pclk;
+	struct clk *hclk;
+};
+
+#define macb_mdio_reg_writel(bp, offset, value)	\
+	writel_relaxed(value, bp->regs + offset)
+#define macb_mdio_writel(bp, reg, value)	\
+	macb_mdio_reg_writel(bp, MACB_##reg, value)
+
+#define macb_mdio_reg_readl(bp, offset)	readl_relaxed(bp->regs + offset)
+#define macb_mdio_readl(bp, reg)	macb_mdio_reg_readl(bp, MACB_##reg)
+
+#define MACB_MDIO_TIMEOUT	1000
+
+static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct macb_mdio_data *bp = bus->priv;
+	unsigned int timeout = MACB_MDIO_TIMEOUT;
+	int value;
+
+	macb_mdio_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF) |
+				   MACB_BF(RW, MACB_MAN_READ) |
+				   MACB_BF(PHYA, mii_id) |
+				   MACB_BF(REGA, regnum) |
+				   MACB_BF(CODE, MACB_MAN_CODE)));
+
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_mdio_readl(bp, NSR)) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	if (!timeout)
+		return -ETIMEDOUT;
+
+	value = MACB_BFEXT(DATA, macb_mdio_readl(bp, MAN));
+
+	return value;
+}
+
+static int macb_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+			   u16 value)
+{
+	struct macb_mdio_data *bp = bus->priv;
+	unsigned int timeout = MACB_MDIO_TIMEOUT;
+
+	macb_mdio_writel(bp, MAN, (MACB_BF(SOF, MACB_MAN_SOF) |
+				   MACB_BF(RW, MACB_MAN_WRITE) |
+				   MACB_BF(PHYA, mii_id) |
+				   MACB_BF(REGA, regnum) |
+				   MACB_BF(CODE, MACB_MAN_CODE) |
+				   MACB_BF(DATA, value)));
+
+	/* wait for end of transfer */
+	while (!MACB_BFEXT(IDLE, macb_mdio_readl(bp, NSR)) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	if (!timeout)
+		return -ETIMEDOUT;
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
+	bp = bus->priv;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	bp->regs = devm_ioremap(&pdev->dev, res->start, resource_size(res));
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
+	platform_set_drvdata(pdev, bus);
+
+	/* Enable management port */
+	config = macb_mdio_readl(bp, NCR);
+	config |= MACB_BIT(MPE);
+	macb_mdio_writel(bp, NCR, config);
+	config = gem_mdc_clk_div(bp);
+	macb_mdio_writel(bp, NCFGR, config);
+
+	np = pdev->dev.of_node;
+	if (np) {
+		/* try dt phy registration */
+		ret = of_mdiobus_register(bus, np);
+
+		/* Fallback to standard phy registration if no phy were
+		 * found during dt phy registration
+		 */
+		if (!ret && !phy_find_first(bus)) {
+			for (i = 0; i < PHY_MAX_ADDR; i++) {
+				struct phy_device *phydev;
+
+				phydev = mdiobus_scan(bus, i);
+				if (IS_ERR(phydev) &&
+				    PTR_ERR(phydev) != -ENODEV) {
+					ret = PTR_ERR(phydev);
+					break;
+				}
+			}
+
+			if (ret)
+				goto err_out_unregister_bus;
+		}
+	} else {
+		for (i = 0; i < PHY_MAX_ADDR; i++)
+			bus->irq[i] = PHY_POLL;
+
+		ret = of_mdiobus_register(bus, np);
+	}
+
+	if (ret)
+		goto err_out_free_mdio_irq;
+
+	return 0;
+
+err_out_unregister_bus:
+	mdiobus_unregister(bus);
+err_out_free_mdio_irq:
+	kfree(bus->irq);
+err_disable_pclk:
+	clk_disable_unprepare(bp->pclk);
+	clk_disable_unprepare(bp->hclk);
+err_out_free_mdiobus:
+	mdiobus_free(bus);
+	return ret;
+}
+
+static int macb_mdio_remove(struct platform_device *pdev)
+{
+	struct mii_bus *bus = platform_get_drvdata(pdev);
+	struct macb_mdio_data *bp = bus->priv;
+	u32 config;
+
+	/* Disable management port */
+	config = macb_mdio_readl(bp, NCR);
+	config &= ~MACB_BIT(MPE);
+	macb_mdio_writel(bp, NCR, config);
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
+MODULE_DESCRIPTION("Cadence MACB MDIO driver");
+MODULE_AUTHOR("Xilinx");
-- 
2.7.4
