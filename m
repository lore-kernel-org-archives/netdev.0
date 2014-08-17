From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v2] ethernet: arc: Add support for specific SoC glue layer device tree bindings
Date: Sun, 17 Aug 2014 14:48:02 +0000
Message-ID: <1408286882-10186-1-git-send-email-romain.perier@gmail.com>
Cc: heiko@sntech.de, tklauser@distanz.ch, b.galvani@gmail.com,
	eric.dumazet@gmail.com, yongjun_wei@trendmicro.com.cn,
	f.fainelli@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:45462 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbaHQOqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 10:46:10 -0400
Received: by mail-wi0-f182.google.com with SMTP id d1so2581604wiv.3
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2014 07:46:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some platforms have special bank registers which might be used to select
the correct clock or the right mode for Media Indepent Interface controllers.
Sometimes, it is also required to activate vcc regulators in the right order to supply
the ethernet controller at the right time. This patch is a refactoring of the arc-emac
device driver, it adds a new software architecture design which allows to add specific
platform glue layer. Each platform has now its own module which performs custom initialization
and remove for the target and then calls to the core driver.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/arc/Kconfig     |  13 ++--
 drivers/net/ethernet/arc/Makefile    |   3 +-
 drivers/net/ethernet/arc/emac.h      |  21 ++++-
 drivers/net/ethernet/arc/emac_arc.c  |  77 +++++++++++++++++++
 drivers/net/ethernet/arc/emac_main.c | 145 +++++++++++++++--------------------
 drivers/net/ethernet/arc/emac_mdio.c |  11 ++-
 6 files changed, 170 insertions(+), 100 deletions(-)
 create mode 100644 drivers/net/ethernet/arc/emac_arc.c

diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index 514c57f..ecaff9c 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -3,8 +3,11 @@
 #
 
 config NET_VENDOR_ARC
-	bool "ARC devices"
-	default y
+	tristate "ARC devices"
+	select MII
+	select PHYLIB
+	depends on OF_IRQ
+	depends on OF_NET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -18,11 +21,7 @@ config NET_VENDOR_ARC
 if NET_VENDOR_ARC
 
 config ARC_EMAC
-	tristate "ARC EMAC support"
-	select MII
-	select PHYLIB
-	depends on OF_IRQ
-	depends on OF_NET
+	tristate "ARC EMAC support
 	---help---
 	  On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
 	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
index 00c8657..462a8e9 100644
--- a/drivers/net/ethernet/arc/Makefile
+++ b/drivers/net/ethernet/arc/Makefile
@@ -3,4 +3,5 @@
 #
 
 arc_emac-objs := emac_main.o emac_mdio.o
-obj-$(CONFIG_ARC_EMAC) += arc_emac.o
+obj-$(CONFIG_NET_VENDOR_ARC) += arc_emac.o
+obj-$(CONFIG_ARC_EMAC) += emac_arc.o
diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 36cc9bd..9f46a39 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -102,11 +102,23 @@ struct buffer_state {
 	DEFINE_DMA_UNMAP_LEN(len);
 };
 
+/* Platform data for SoC glue layer device tree bindings */
+struct arc_emac_platform_data
+{
+	const char *name;
+	const char *version;
+	int interface;
+	struct clk *clk;
+	void (*set_mac_speed)(void *priv, unsigned int speed);
+	void *priv;
+};
+
 /**
  * struct arc_emac_priv - Storage of EMAC's private information.
  * @dev:	Pointer to the current device.
  * @phy_dev:	Pointer to attached PHY device.
  * @bus:	Pointer to the current MII bus.
+ * @plat_data:	Pointer to SoC specific data.
  * @regs:	Base address of EMAC memory-mapped control registers.
  * @napi:	Structure for NAPI.
  * @rxbd:	Pointer to Rx BD ring.
@@ -128,8 +140,9 @@ struct arc_emac_priv {
 	struct phy_device *phy_dev;
 	struct mii_bus *bus;
 
+	const struct arc_emac_platform_data *plat_data;
+
 	void __iomem *regs;
-	struct clk *clk;
 
 	struct napi_struct napi;
 
@@ -191,7 +204,7 @@ static inline void arc_reg_or(struct arc_emac_priv *priv, int reg, int mask)
 
 /**
  * arc_reg_clr - Applies mask to specified EMAC register - ("reg" & ~"mask").
- * @priv:	Pointer to ARC EMAC private data structure.
+ * @priv:	Pointer to EMAC private data structure.
  * @reg:	Register offset from base address.
  * @mask:	Mask to apply to specified register.
  *
@@ -204,7 +217,9 @@ static inline void arc_reg_clr(struct arc_emac_priv *priv, int reg, int mask)
 	arc_reg_set(priv, reg, value & ~mask);
 }
 
-int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv);
+int arc_emac_probe(struct device *dev, const struct arc_emac_platform_data *plat_data);
+int arc_emac_remove(struct net_device *ndev);
+int arc_mdio_probe(struct arc_emac_priv *priv);
 int arc_mdio_remove(struct arc_emac_priv *priv);
 
 #endif /* ARC_EMAC_H */
diff --git a/drivers/net/ethernet/arc/emac_arc.c b/drivers/net/ethernet/arc/emac_arc.c
new file mode 100644
index 0000000..be10943
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac_arc.c
@@ -0,0 +1,77 @@
+/**
+ * emac_arc.c - ARC EMAC specific glue layer
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
+#include <linux/module.h>
+#include <linux/clk.h>
+
+#define DRV_NAME "emac_arc"
+#define DRV_VERSION "1.0"
+
+static int emac_arc_probe(struct platform_device *pdev)
+{
+	struct arc_emac_platform_data *plat_data = NULL;
+	struct device *dev = &pdev->dev;
+
+	plat_data = devm_kzalloc(dev, sizeof(*plat_data), GFP_KERNEL);
+	if (!plat_data)
+		return -ENOMEM;
+	plat_data->name = DRV_NAME;
+	plat_data->version = DRV_VERSION;
+
+	plat_data->interface = of_get_phy_mode(dev->of_node);
+	if (plat_data->interface < 0)
+		plat_data->interface = PHY_INTERFACE_MODE_MII;
+
+	plat_data->clk = devm_clk_get(dev, "hclk");
+        if (IS_ERR(plat_data->clk)) {
+		dev_err(dev, "failed to retrieve host clock from device tree\n");
+		return PTR_ERR_OR_ZERO(plat_data->clk);
+	}
+
+	return arc_emac_probe(dev, plat_data);
+}
+
+static int emac_arc_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
+
+	return arc_emac_remove(ndev);
+}
+
+static const struct of_device_id emac_arc_dt_ids[] = {
+	{ .compatible = "snps,arc-emac" },
+	{ /* Sentinel */ }
+};
+
+static struct platform_driver emac_arc_driver = {
+	.probe = emac_arc_probe,
+	.remove = emac_arc_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.of_match_table  = emac_arc_dt_ids,
+	},
+};
+
+module_platform_driver(emac_arc_driver);
+
+MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
+MODULE_DESCRIPTION("ARC EMAC platform driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index fe5cfea..09ce366 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -11,6 +11,7 @@
  *		Amit Bhor
  *		Sameer Dhavale
  *		Vineet Gupta
+ *		Romain Perier
  */
 
 #include <linux/crc32.h>
@@ -26,8 +27,6 @@
 
 #include "emac.h"
 
-#define DRV_NAME	"arc_emac"
-#define DRV_VERSION	"1.0"
 
 /**
  * arc_emac_adjust_link - Adjust the PHY link duplex.
@@ -50,6 +49,8 @@ static void arc_emac_adjust_link(struct net_device *ndev)
 	if (priv->speed != phy_dev->speed) {
 		priv->speed = phy_dev->speed;
 		state_changed = 1;
+		if (priv->plat_data->set_mac_speed)
+			priv->plat_data->set_mac_speed(priv->plat_data->priv, priv->speed);
 	}
 
 	if (priv->duplex != phy_dev->duplex) {
@@ -120,8 +121,10 @@ static int arc_emac_set_settings(struct net_device *ndev,
 static void arc_emac_get_drvinfo(struct net_device *ndev,
 				 struct ethtool_drvinfo *info)
 {
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	struct arc_emac_priv *priv = netdev_priv(ndev);
+
+	strlcpy(info->driver, priv->plat_data->name, sizeof(info->driver));
+	strlcpy(info->version, priv->plat_data->version, sizeof(info->version));
 }
 
 static const struct ethtool_ops arc_emac_ethtool_ops = {
@@ -671,7 +674,7 @@ static const struct net_device_ops arc_emac_netdev_ops = {
 #endif
 };
 
-static int arc_emac_probe(struct platform_device *pdev)
+int arc_emac_probe(struct device *dev, const struct arc_emac_platform_data *plat_data)
 {
 	struct resource res_regs;
 	struct device_node *phy_node;
@@ -681,27 +684,24 @@ static int arc_emac_probe(struct platform_device *pdev)
 	unsigned int id, clock_frequency, irq;
 	int err;
 
-	if (!pdev->dev.of_node)
-		return -ENODEV;
-
 	/* Get PHY from device tree */
-	phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
+	phy_node = of_parse_phandle(dev->of_node, "phy", 0);
 	if (!phy_node) {
-		dev_err(&pdev->dev, "failed to retrieve phy description from device tree\n");
+		dev_err(dev, "failed to retrieve phy description from device tree\n");
 		return -ENODEV;
 	}
 
 	/* Get EMAC registers base address from device tree */
-	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
+	err = of_address_to_resource(dev->of_node, 0, &res_regs);
 	if (err) {
-		dev_err(&pdev->dev, "failed to retrieve registers base from device tree\n");
+		dev_err(dev, "failed to retrieve registers base from device tree\n");
 		return -ENODEV;
 	}
 
 	/* Get IRQ from device tree */
-	irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	irq = irq_of_parse_and_map(dev->of_node, 0);
 	if (!irq) {
-		dev_err(&pdev->dev, "failed to retrieve <irq> value from device tree\n");
+		dev_err(dev, "failed to retrieve <irq> value from device tree\n");
 		return -ENODEV;
 	}
 
@@ -709,8 +709,8 @@ static int arc_emac_probe(struct platform_device *pdev)
 	if (!ndev)
 		return -ENOMEM;
 
-	platform_set_drvdata(pdev, ndev);
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+	dev_set_drvdata(dev, ndev);
+	SET_NETDEV_DEV(ndev, dev);
 
 	ndev->netdev_ops = &arc_emac_netdev_ops;
 	ndev->ethtool_ops = &arc_emac_ethtool_ops;
@@ -719,60 +719,56 @@ static int arc_emac_probe(struct platform_device *pdev)
 	ndev->flags &= ~IFF_MULTICAST;
 
 	priv = netdev_priv(ndev);
-	priv->dev = &pdev->dev;
+	priv->dev = dev;
+	priv->plat_data = plat_data;
 
-	priv->regs = devm_ioremap_resource(&pdev->dev, &res_regs);
+	priv->regs = devm_ioremap_resource(dev, &res_regs);
 	if (IS_ERR(priv->regs)) {
 		err = PTR_ERR(priv->regs);
 		goto out_netdev;
 	}
-	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs);
-
-	priv->clk = of_clk_get(pdev->dev.of_node, 0);
-	if (IS_ERR(priv->clk)) {
-		/* Get CPU clock frequency from device tree */
-		if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
-					&clock_frequency)) {
-			dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from device tree\n");
-			err = -EINVAL;
-			goto out_netdev;
-		}
-	} else {
-		err = clk_prepare_enable(priv->clk);
-		if (err) {
-			dev_err(&pdev->dev, "failed to enable clock\n");
-			goto out_clkget;
-		}
 
-		clock_frequency = clk_get_rate(priv->clk);
+	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);
+
+	if (!plat_data->clk) {
+		dev_err(dev, "no clock provided to the core driver\n");
+		goto out_netdev;
 	}
 
+	err = clk_prepare_enable(plat_data->clk);
+	if (err) {
+		dev_err(dev, "failed to enable host clock provided to the core driver (%d)\n", err);
+		goto out_netdev;
+	}
+
+	clock_frequency = clk_get_rate(plat_data->clk);
+
 	id = arc_reg_get(priv, R_ID);
 
 	/* Check for EMAC revision 5 or 7, magic number */
 	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
-		dev_err(&pdev->dev, "ARC EMAC not detected, id=0x%x\n", id);
+		dev_err(dev, "EMAC not detected, id=0x%x\n", id);
 		err = -ENODEV;
-		goto out_clken;
+		goto out_clk;
 	}
-	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
+	dev_info(dev, "EMAC detected with id: 0x%x\n", id);
 
 	/* Set poll rate so that it polls every 1 ms */
 	arc_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
 
 	ndev->irq = irq;
-	dev_info(&pdev->dev, "IRQ is %d\n", ndev->irq);
+	dev_dbg(dev, "IRQ is %d\n", ndev->irq);
 
 	/* Register interrupt handler for device */
-	err = devm_request_irq(&pdev->dev, ndev->irq, arc_emac_intr, 0,
+	err = devm_request_irq(dev, ndev->irq, arc_emac_intr, 0,
 			       ndev->name, ndev);
 	if (err) {
-		dev_err(&pdev->dev, "could not allocate IRQ\n");
-		goto out_clken;
+		dev_err(dev, "could not allocate IRQ\n");
+		goto out_clk;
 	}
 
 	/* Get MAC address from device tree */
-	mac_addr = of_get_mac_address(pdev->dev.of_node);
+	mac_addr = of_get_mac_address(dev->of_node);
 
 	if (mac_addr)
 		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
@@ -780,46 +776,46 @@ static int arc_emac_probe(struct platform_device *pdev)
 		eth_hw_addr_random(ndev);
 
 	arc_emac_set_address_internal(ndev);
-	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
+	dev_info(dev, "MAC address is now %pM\n", ndev->dev_addr);
 
 	/* Do 1 allocation instead of 2 separate ones for Rx and Tx BD rings */
-	priv->rxbd = dmam_alloc_coherent(&pdev->dev, RX_RING_SZ + TX_RING_SZ,
+	priv->rxbd = dmam_alloc_coherent(dev, RX_RING_SZ + TX_RING_SZ,
 					 &priv->rxbd_dma, GFP_KERNEL);
 
 	if (!priv->rxbd) {
-		dev_err(&pdev->dev, "failed to allocate data buffers\n");
+		dev_err(dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
-		goto out_clken;
+		goto out_clk;
 	}
 
 	priv->txbd = priv->rxbd + RX_BD_NUM;
 
 	priv->txbd_dma = priv->rxbd_dma + RX_RING_SZ;
-	dev_dbg(&pdev->dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
+	dev_dbg(dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
 		(unsigned int)priv->rxbd_dma, (unsigned int)priv->txbd_dma);
 
-	err = arc_mdio_probe(pdev, priv);
+	err = arc_mdio_probe(priv);
 	if (err) {
-		dev_err(&pdev->dev, "failed to probe MII bus\n");
-		goto out_clken;
+		dev_err(dev, "failed to probe MII bus\n");
+		goto out_clk;
 	}
 
 	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
-				       PHY_INTERFACE_MODE_MII);
+				       plat_data->interface);
 	if (!priv->phy_dev) {
-		dev_err(&pdev->dev, "of_phy_connect() failed\n");
+		dev_err(dev, "of_phy_connect() failed\n");
 		err = -ENODEV;
 		goto out_mdio;
 	}
 
-	dev_info(&pdev->dev, "connected to %s phy with id 0x%x\n",
+	dev_info(dev, "connected to %s phy with id 0x%x\n",
 		 priv->phy_dev->drv->name, priv->phy_dev->phy_id);
 
 	netif_napi_add(ndev, &priv->napi, arc_emac_poll, ARC_EMAC_NAPI_WEIGHT);
 
 	err = register_netdev(ndev);
 	if (err) {
-		dev_err(&pdev->dev, "failed to register network device\n");
+		dev_err(dev, "failed to register network device\n");
 		goto out_netif_api;
 	}
 
@@ -831,20 +827,17 @@ out_netif_api:
 	priv->phy_dev = NULL;
 out_mdio:
 	arc_mdio_remove(priv);
-out_clken:
-	if (!IS_ERR(priv->clk))
-		clk_disable_unprepare(priv->clk);
-out_clkget:
-	if (!IS_ERR(priv->clk))
-		clk_put(priv->clk);
+out_clk:
+	clk_disable_unprepare(plat_data->clk);
 out_netdev:
 	free_netdev(ndev);
 	return err;
 }
 
-static int arc_emac_remove(struct platform_device *pdev)
+EXPORT_SYMBOL_GPL(arc_emac_probe);
+
+int arc_emac_remove(struct net_device *ndev)
 {
-	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 
 	phy_disconnect(priv->phy_dev);
@@ -853,33 +846,15 @@ static int arc_emac_remove(struct platform_device *pdev)
 	unregister_netdev(ndev);
 	netif_napi_del(&priv->napi);
 
-	if (!IS_ERR(priv->clk)) {
-		clk_disable_unprepare(priv->clk);
-		clk_put(priv->clk);
-	}
+	if (priv->plat_data->clk)
+		clk_disable_unprepare(priv->plat_data->clk);
 
 	free_netdev(ndev);
 
 	return 0;
 }
 
-static const struct of_device_id arc_emac_dt_ids[] = {
-	{ .compatible = "snps,arc-emac" },
-	{ /* Sentinel */ }
-};
-MODULE_DEVICE_TABLE(of, arc_emac_dt_ids);
-
-static struct platform_driver arc_emac_driver = {
-	.probe = arc_emac_probe,
-	.remove = arc_emac_remove,
-	.driver = {
-		.name = DRV_NAME,
-		.owner = THIS_MODULE,
-		.of_match_table  = arc_emac_dt_ids,
-		},
-};
-
-module_platform_driver(arc_emac_driver);
+EXPORT_SYMBOL_GPL(arc_emac_remove);
 
 MODULE_AUTHOR("Alexey Brodkin <abrodkin@synopsys.com>");
 MODULE_DESCRIPTION("ARC EMAC driver");
diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
index 26ba242..48d6fa4 100644
--- a/drivers/net/ethernet/arc/emac_mdio.c
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -2,6 +2,9 @@
  * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
  *
  * MDIO implementation for ARC EMAC
+ *
+ * Contributors:
+ *		Romain Perier
  */
 
 #include <linux/delay.h>
@@ -93,7 +96,7 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
 		phy_addr, reg_num, value);
 
 	arc_reg_set(priv, R_MDIO,
-		     0x50020000 | (phy_addr << 23) | (reg_num << 18) | value);
+		    0x50020000 | (phy_addr << 23) | (reg_num << 18) | value);
 
 	return arc_mdio_complete_wait(priv);
 }
@@ -108,7 +111,7 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
  *
  * Sets up and registers the MDIO interface.
  */
-int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
+int arc_mdio_probe(struct arc_emac_priv *priv)
 {
 	struct mii_bus *bus;
 	int error;
@@ -124,9 +127,9 @@ int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
 	bus->read = &arc_mdio_read;
 	bus->write = &arc_mdio_write;
 
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
 
-	error = of_mdiobus_register(bus, pdev->dev.of_node);
+	error = of_mdiobus_register(bus, priv->dev->of_node);
 	if (error) {
 		dev_err(priv->dev, "cannot register MDIO bus %s\n", bus->name);
 		mdiobus_free(bus);
-- 
1.9.1
