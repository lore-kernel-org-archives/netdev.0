From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v2 3/6] mv643xx.c: Add basic device tree support.
Date: Tue, 31 Jul 2012 16:45:26 +0100
Message-ID: <1343749529-17571-4-git-send-email-ian.molton@codethink.co.uk>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:59914 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab2GaPzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 11:55:12 -0400
In-Reply-To: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic device tree support to the mv643xx ethernet driver.

It should be enough for most current users of the device, and should allow
a fairly painless migration once proper support for clk devices is available
to those platforms.

Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 Documentation/devicetree/bindings/net/mv643xx.txt |   75 +++++++++++++
 arch/arm/mach-kirkwood/board-dt.c                 |    5 +
 drivers/net/ethernet/marvell/mv643xx_eth.c        |  119 ++++++++++++++++++---
 3 files changed, 185 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/mv643xx.txt

diff --git a/Documentation/devicetree/bindings/net/mv643xx.txt b/Documentation/devicetree/bindings/net/mv643xx.txt
new file mode 100644
index 0000000..2727f79
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/mv643xx.txt
@@ -0,0 +1,75 @@
+mv643xx related nodes.
+
+marvell,mdio-mv643xx:
+
+Required properties:
+
+ - interrupts : <a> where a is the SMI interrupt number.
+ - reg : the base address and size of the controllers register space.
+
+Optional properties:
+ - shared_smi : on some chips, the second PHY is "shared", meaning it is
+	really accessed via the first SMI controller. It is passed in this
+	way due to the present structure of the driver, which requires the
+	base address for the MAC to be passed in via the SMI controllers
+	platform data.
+ - tx_csum_limit : on some devices, this option is required for proper
+	operation wrt. jumbo frames.
+
+
+Example:
+
+smi0: mdio@72000 {
+	compatible = "marvell,mdio-mv643xx";
+	reg = <0x72000 0x4000>;
+	interrupts = <46>;
+	tx_csum_limit = <1600>;
+	status = "disabled";
+};
+
+smi1: mdio@76000 {
+	compatible = "marvell,mdio-mv643xx";
+	reg = <0x76000 0x4000>;
+	interrupts = <47>;
+	shared_smi = <&smi0>;
+	tx_csum_limit = <1600>;
+	status = "disabled";
+};
+
+
+
+marvell,mv643xx-eth:
+
+Required properties:
+ - interrupts : the port interrupt number.
+ - mdio : phandle of the smi device as drescribed above
+
+Optional properties:
+ - port_number : the port number on this bus.
+ - phy_addr : the PHY address.
+ - reg : should match the mdio reg this device is attached to.
+	this is a required hack for now due to the way the
+	driver is constructed. This allows the device clock to be
+	kept running so that the MAC is not lost after boot.
+
+
+Example:
+
+egiga0 {
+	compatible = "marvell,mv643xx-eth";
+	reg = <0x72000 0x4000>;
+	mdio = <&smi0>;
+	port_number = <0>;
+	phy_addr = <0x80>;
+	interrupts = <11>;
+};
+
+egiga1 {
+	compatible = "marvell,mv643xx-eth";
+	reg = <0x76000 0x4000>;
+	mdio = <&smi1>;
+	port_number = <0>;
+	phy_addr = <0x81>;
+	interrupts = <15>;
+};
+
diff --git a/arch/arm/mach-kirkwood/board-dt.c b/arch/arm/mach-kirkwood/board-dt.c
index 7679f7f..9816b85 100644
--- a/arch/arm/mach-kirkwood/board-dt.c
+++ b/arch/arm/mach-kirkwood/board-dt.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/of.h>
 #include <linux/of_platform.h>
+#include <linux/mv643xx_eth.h>
 #include <linux/kexec.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -33,6 +34,10 @@ struct of_dev_auxdata kirkwood_auxdata_lookup[] __initdata = {
 	OF_DEV_AUXDATA("marvell,orion-wdt", 0xf1020300, "orion_wdt", NULL),
 	OF_DEV_AUXDATA("marvell,orion-sata", 0xf1080000, "sata_mv.0", NULL),
 	OF_DEV_AUXDATA("marvell,orion-nand", 0xf4000000, "orion_nand", NULL),
+	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1072000, MV643XX_ETH_NAME ".0",
+			NULL),
+	OF_DEV_AUXDATA("marvell,mv643xx", 0xf1076000, MV643XX_ETH_NAME ".1",
+			NULL),
 	{},
 };
 
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 92497eb..733c69f 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -48,6 +48,9 @@
 #include <linux/ethtool.h>
 #include <linux/platform_device.h>
 #include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/of_irq.h>
 #include <linux/kernel.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
@@ -2601,11 +2604,11 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_eth_version_printed;
-	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
+	struct mv643xx_eth_shared_platform_data *pd;
 	struct mv643xx_eth_shared_private *msp;
 	const struct mbus_dram_target_info *dram;
 	struct resource *res;
-	int ret;
+	int ret, irq = -1;
 
 	if (!mv643xx_eth_version_printed++)
 		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
@@ -2625,6 +2628,26 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	if (msp->base == NULL)
 		goto out_free;
 
+	if (pdev->dev.of_node) {
+		struct device_node *np = NULL;
+
+		/* when all users of this driver use FDT, we can remove this */
+		pd = kzalloc(sizeof(*pd), GFP_KERNEL);
+		if (!pd) {
+			dev_dbg(&pdev->dev, "Could not allocate platform data\n");
+			goto out_free;
+		}
+
+		of_property_read_u32(pdev->dev.of_node,
+			"tx_csum_limit", &pd->tx_csum_limit);
+
+		np = of_parse_phandle(pdev->dev.of_node, "shared_smi", 0);
+		if (np)
+			pd->shared_smi = of_find_device_by_node(np);
+
+	} else {
+		pd = pdev->dev.platform_data;
+	}
 	/*
 	 * Set up and register SMI bus.
 	 */
@@ -2654,15 +2677,22 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	/*
 	 * Check whether the error interrupt is hooked up.
 	 */
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (res != NULL) {
+	if (pdev->dev.of_node) {
+		irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	} else {
+		res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+		if (res)
+			irq = res->start;
+	}
+
+	if (irq != -1) {
 		int err;
 
-		err = request_irq(res->start, mv643xx_eth_err_irq,
+		err = request_irq(irq, mv643xx_eth_err_irq,
 				  IRQF_SHARED, "mv643xx_eth", msp);
 		if (!err) {
 			writel(ERR_INT_SMI_DONE, msp->base + ERR_INT_MASK);
-			msp->err_interrupt = res->start;
+			msp->err_interrupt = irq;
 		}
 	}
 
@@ -2675,6 +2705,10 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	msp->tx_csum_limit = (pd != NULL && pd->tx_csum_limit) ?
 					pd->tx_csum_limit : 9 * 1024;
+
+	if (pdev->dev.of_node)
+		kfree(pd);  /* If we created a fake pd, free it now */
+
 	infer_hw_params(msp);
 
 	platform_set_drvdata(pdev, msp);
@@ -2708,12 +2742,21 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static struct of_device_id mv_mdio_dt_ids[] __devinitdata = {
+	{ .compatible = "marvell,mdio-mv643xx", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, mv_mdio_dt_ids);
+#endif
+
 static struct platform_driver mv643xx_eth_shared_driver = {
 	.probe		= mv643xx_eth_shared_probe,
 	.remove		= mv643xx_eth_shared_remove,
 	.driver = {
 		.name	= MV643XX_ETH_SHARED_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(mv_mdio_dt_ids),
 	},
 };
 
@@ -2873,7 +2916,36 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	struct resource *res;
 	int err;
 
-	pd = pdev->dev.platform_data;
+	if (pdev->dev.of_node) {
+		struct device_node *np = NULL;
+
+		/* when all users of this driver use FDT, we can remove this */
+		pd = kzalloc(sizeof(*pd), GFP_KERNEL);
+		if (!pd) {
+			dev_dbg(&pdev->dev, "Could not allocate platform data\n");
+			return -ENOMEM;
+		}
+
+		of_property_read_u32(pdev->dev.of_node,
+			"port_number", &pd->port_number);
+
+		if(!of_property_read_u32(pdev->dev.of_node,
+				"phy_addr", &pd->phy_addr))
+			pd->phy_addr = MV643XX_ETH_PHY_ADDR(pd->phy_addr);
+		else
+			pd->phy_addr = MV643XX_ETH_PHY_ADDR_DEFAULT;
+
+		np = of_parse_phandle(pdev->dev.of_node, "mdio", 0);
+		if (np) {
+			pd->shared = of_find_device_by_node(np);
+		} else {
+			kfree(pd);
+			return -ENODEV;
+		}
+	} else {
+		pd = pdev->dev.platform_data;
+	}
+
 	if (pd == NULL) {
 		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");
 		return -ENODEV;
@@ -2881,12 +2953,15 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	if (pd->shared == NULL) {
 		dev_err(&pdev->dev, "no mv643xx_eth_platform_data->shared\n");
-		return -ENODEV;
+		err = -ENODEV;
+		goto out_free_pd;
 	}
 
 	dev = alloc_etherdev_mq(sizeof(struct mv643xx_eth_private), 8);
-	if (!dev)
-		return -ENOMEM;
+	if (!dev) {
+		err = -ENOMEM;
+		goto out_free_pd;
+	}
 
 	mp = netdev_priv(dev);
 	platform_set_drvdata(pdev, mp);
@@ -2923,6 +2998,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	init_pscr(mp, pd->speed, pd->duplex);
 
+	if (pdev->dev.of_node)
+		kfree(pd); /* If we created a fake pd, free it now */
 
 	mib_counters_clear(mp);
 
@@ -2942,10 +3019,13 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->rx_oom.data = (unsigned long)mp;
 	mp->rx_oom.function = oom_timer_wrapper;
 
-
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	BUG_ON(!res);
-	dev->irq = res->start;
+	if (pdev->dev.of_node) {
+		dev->irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	} else {
+		res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+		BUG_ON(!res);
+		dev->irq = res->start;
+	}
 
 	dev->netdev_ops = &mv643xx_eth_netdev_ops;
 
@@ -2991,6 +3071,8 @@ out:
 	}
 #endif
 	free_netdev(dev);
+out_free_pd:
+	kfree(pd);
 
 	return err;
 }
@@ -3030,6 +3112,14 @@ static void mv643xx_eth_shutdown(struct platform_device *pdev)
 		port_reset(mp);
 }
 
+#ifdef CONFIG_OF
+static struct of_device_id mv_eth_dt_ids[] __devinitdata = {
+	{ .compatible = "marvell,mv643xx-eth", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, mv_eth_dt_ids);
+#endif
+
 static struct platform_driver mv643xx_eth_driver = {
 	.probe		= mv643xx_eth_probe,
 	.remove		= mv643xx_eth_remove,
@@ -3037,6 +3127,7 @@ static struct platform_driver mv643xx_eth_driver = {
 	.driver = {
 		.name	= MV643XX_ETH_NAME,
 		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(mv_eth_dt_ids),
 	},
 };
 
-- 
1.7.9.5
