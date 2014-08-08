From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH 1/2] ethernet: arc: Add support for specific SoC glue layer device tree bindings
Date: Fri,  8 Aug 2014 12:27:54 +0000
Message-ID: <1407500875-23851-1-git-send-email-romain.perier@gmail.com>
Cc: heiko@sntech.de, max.schwarz@online.de, b.galvani@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:39199 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989AbaHHM0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 08:26:13 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so5584241wgg.16
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 05:26:12 -0700 (PDT)
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
 drivers/net/ethernet/arc/Kconfig     |  10 +-
 drivers/net/ethernet/arc/Makefile    |   4 +-
 drivers/net/ethernet/arc/emac.h      |  81 +++++----
 drivers/net/ethernet/arc/emac_arc.c  |  79 +++++++++
 drivers/net/ethernet/arc/emac_main.c | 332 ++++++++++++++++-------------------
 drivers/net/ethernet/arc/emac_mdio.c |  62 +++----
 6 files changed, 317 insertions(+), 251 deletions(-)
 create mode 100644 drivers/net/ethernet/arc/emac_arc.c

diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index 514c57f..d73d971 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -5,6 +5,10 @@
 config NET_VENDOR_ARC
 	bool "ARC devices"
 	default y
+	select MII
+	select PHYLIB
+	depends on OF_IRQ
+	depends on OF_NET
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -18,11 +22,7 @@ config NET_VENDOR_ARC
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
index 00c8657..b6f15b4 100644
--- a/drivers/net/ethernet/arc/Makefile
+++ b/drivers/net/ethernet/arc/Makefile
@@ -2,5 +2,5 @@
 # Makefile for the ARC network device drivers.
 #
 
-arc_emac-objs := emac_main.o emac_mdio.o
-obj-$(CONFIG_ARC_EMAC) += arc_emac.o
+obj-$(CONFIG_NET_VENDOR_ARC) += emac_main.o emac_mdio.o
+obj-$(CONFIG_ARC_EMAC) += emac_arc.o
diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 53f85bf..3157174 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -1,11 +1,11 @@
 /*
  * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
  *
- * Registers and bits definitions of ARC EMAC
+ * Registers and bits definitions of EMAC
  */
 
-#ifndef ARC_EMAC_H
-#define ARC_EMAC_H
+#ifndef EMAC_H
+#define EMAC_H
 
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
@@ -48,7 +48,7 @@
 #define FOR_EMAC	OWN_MASK
 #define FOR_CPU		0
 
-/* ARC EMAC register set combines entries for MAC and MDIO */
+/* EMAC register set combines entries for MAC and MDIO */
 enum {
 	R_ID = 0,
 	R_STATUS,
@@ -68,17 +68,17 @@ enum {
 
 #define TX_TIMEOUT		(400*HZ/1000)	/* Transmission timeout */
 
-#define ARC_EMAC_NAPI_WEIGHT	40		/* Workload for NAPI */
+#define EMAC_NAPI_WEIGHT	40		/* Workload for NAPI */
 
 #define EMAC_BUFFER_SIZE	1536		/* EMAC buffer size */
 
 /**
- * struct arc_emac_bd - EMAC buffer descriptor (BD).
+ * struct emac_bd - EMAC buffer descriptor (BD).
  *
  * @info:	Contains status information on the buffer itself.
  * @data:	32-bit byte addressable pointer to the packet data.
  */
-struct arc_emac_bd {
+struct emac_bd {
 	__le32 info;
 	dma_addr_t data;
 };
@@ -87,8 +87,8 @@ struct arc_emac_bd {
 #define RX_BD_NUM	128
 #define TX_BD_NUM	128
 
-#define RX_RING_SZ	(RX_BD_NUM * sizeof(struct arc_emac_bd))
-#define TX_RING_SZ	(TX_BD_NUM * sizeof(struct arc_emac_bd))
+#define RX_RING_SZ	(RX_BD_NUM * sizeof(struct emac_bd))
+#define TX_RING_SZ	(TX_BD_NUM * sizeof(struct emac_bd))
 
 /**
  * struct buffer_state - Stores Rx/Tx buffer state.
@@ -102,12 +102,24 @@ struct buffer_state {
 	DEFINE_DMA_UNMAP_LEN(len);
 };
 
+/* of_data for SoC glue layer device tree bindings */
+struct emac_platform_data
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
- * struct arc_emac_priv - Storage of EMAC's private information.
+ * struct emac_priv - Storage of EMAC's private information.
  * @dev:	Pointer to the current device.
  * @ndev:	Pointer to the current network device.
  * @phy_dev:	Pointer to attached PHY device.
  * @bus:	Pointer to the current MII bus.
+ * @plat_data:	Pointer to SoC specific data.
  * @regs:	Base address of EMAC memory-mapped control registers.
  * @napi:	Structure for NAPI.
  * @stats:	Network device statistics.
@@ -124,21 +136,22 @@ struct buffer_state {
  * @duplex:	PHY's last set duplex mode.
  * @speed:	PHY's last set speed.
  */
-struct arc_emac_priv {
+struct emac_priv {
 	/* Devices */
 	struct device *dev;
 	struct net_device *ndev;
 	struct phy_device *phy_dev;
 	struct mii_bus *bus;
 
+	const struct emac_platform_data *plat_data;
+
 	void __iomem *regs;
-	struct clk *clk;
 
 	struct napi_struct napi;
 	struct net_device_stats stats;
 
-	struct arc_emac_bd *rxbd;
-	struct arc_emac_bd *txbd;
+	struct emac_bd *rxbd;
+	struct emac_bd *txbd;
 
 	dma_addr_t rxbd_dma;
 	dma_addr_t txbd_dma;
@@ -156,59 +169,61 @@ struct arc_emac_priv {
 };
 
 /**
- * arc_reg_set - Sets EMAC register with provided value.
- * @priv:	Pointer to ARC EMAC private data structure.
+ * emac_reg_set - Sets EMAC register with provided value.
+ * @priv:	Pointer to EMAC private data structure.
  * @reg:	Register offset from base address.
  * @value:	Value to set in register.
  */
-static inline void arc_reg_set(struct arc_emac_priv *priv, int reg, int value)
+static inline void emac_reg_set(struct emac_priv *priv, int reg, int value)
 {
 	iowrite32(value, priv->regs + reg * sizeof(int));
 }
 
 /**
- * arc_reg_get - Gets value of specified EMAC register.
- * @priv:	Pointer to ARC EMAC private data structure.
+ * emac_reg_get - Gets value of specified EMAC register.
+ * @priv:	Pointer to EMAC private data structure.
  * @reg:	Register offset from base address.
  *
  * returns:	Value of requested register.
  */
-static inline unsigned int arc_reg_get(struct arc_emac_priv *priv, int reg)
+static inline unsigned int emac_reg_get(struct emac_priv *priv, int reg)
 {
 	return ioread32(priv->regs + reg * sizeof(int));
 }
 
 /**
- * arc_reg_or - Applies mask to specified EMAC register - ("reg" | "mask").
- * @priv:	Pointer to ARC EMAC private data structure.
+ * emac_reg_or - Applies mask to specified EMAC register - ("reg" | "mask").
+ * @priv:	Pointer to EMAC private data structure.
  * @reg:	Register offset from base address.
  * @mask:	Mask to apply to specified register.
  *
  * This function reads initial register value, then applies provided mask
  * to it and then writes register back.
  */
-static inline void arc_reg_or(struct arc_emac_priv *priv, int reg, int mask)
+static inline void emac_reg_or(struct emac_priv *priv, int reg, int mask)
 {
-	unsigned int value = arc_reg_get(priv, reg);
-	arc_reg_set(priv, reg, value | mask);
+	unsigned int value = emac_reg_get(priv, reg);
+	emac_reg_set(priv, reg, value | mask);
 }
 
 /**
- * arc_reg_clr - Applies mask to specified EMAC register - ("reg" & ~"mask").
- * @priv:	Pointer to ARC EMAC private data structure.
+ * emac_reg_clr - Applies mask to specified EMAC register - ("reg" & ~"mask").
+ * @priv:	Pointer to EMAC private data structure.
  * @reg:	Register offset from base address.
  * @mask:	Mask to apply to specified register.
  *
  * This function reads initial register value, then applies provided mask
  * to it and then writes register back.
  */
-static inline void arc_reg_clr(struct arc_emac_priv *priv, int reg, int mask)
+static inline void emac_reg_clr(struct emac_priv *priv, int reg, int mask)
 {
-	unsigned int value = arc_reg_get(priv, reg);
-	arc_reg_set(priv, reg, value & ~mask);
+	unsigned int value = emac_reg_get(priv, reg);
+	emac_reg_set(priv, reg, value & ~mask);
 }
 
-int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv);
-int arc_mdio_remove(struct arc_emac_priv *priv);
+int emac_drv_probe(struct device *dev, const struct emac_platform_data *plat_data);
+int emac_drv_remove(struct net_device *ndev);
+int emac_mdio_probe(struct emac_priv *priv);
+int emac_mdio_remove(struct emac_priv *priv);
 
-#endif /* ARC_EMAC_H */
+#endif /* EMAC_H */
diff --git a/drivers/net/ethernet/arc/emac_arc.c b/drivers/net/ethernet/arc/emac_arc.c
new file mode 100644
index 0000000..80ebb52
--- /dev/null
+++ b/drivers/net/ethernet/arc/emac_arc.c
@@ -0,0 +1,79 @@
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
+#define DRV_NAME "arc_emac"
+#define DRV_VERSION "1.0"
+
+static int arc_emac_probe(struct platform_device *pdev)
+{
+	struct emac_platform_data *emac_plat_data = NULL;
+	struct device *dev = &pdev->dev;
+	int ret = 0;
+
+	emac_plat_data = devm_kzalloc(dev, sizeof(*emac_plat_data), GFP_KERNEL);
+	if (!emac_plat_data)
+		return -ENOMEM;
+	emac_plat_data->name = DRV_NAME;
+	emac_plat_data->version = DRV_VERSION;
+	emac_plat_data->set_mac_speed = NULL;
+	emac_plat_data->priv = emac;
+
+	emac_plat_data->interface = of_get_phy_mode(dev->of_node);
+
+	emac_plat_data->clk = of_clk_get(dev->of_node, 0);
+        if (IS_ERR(emac_plat_data->clk)) {
+		dev_err(dev, "failed to retrieve clock from device tree\n");
+		return PTR_ERR_OR_ZERO(emac_plat_data->clk);
+	}
+
+	return emac_drv_probe(dev, emac_plat_data);
+}
+
+static int arc_emac_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
+
+	return emac_drv_remove(ndev);
+}
+
+static const struct of_device_id arc_emac_dt_ids[] = {
+	{ .compatible = "snps,arc-emac" },
+	{ /* Sentinel */ }
+};
+
+static struct platform_driver arc_emac_driver = {
+	.probe = arc_emac_probe,
+	.remove = arc_emac_remove,
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+		.of_match_table  = arc_emac_dt_ids,
+	},
+};
+
+module_platform_driver(arc_emac_driver);
+
+MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
+MODULE_DESCRIPTION("ARC EMAC driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 18e2fac..ce04890 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -11,6 +11,7 @@
  *		Amit Bhor
  *		Sameer Dhavale
  *		Vineet Gupta
+ *		Romain Perier
  */
 
 #include <linux/crc32.h>
@@ -26,19 +27,17 @@
 
 #include "emac.h"
 
-#define DRV_NAME	"arc_emac"
-#define DRV_VERSION	"1.0"
 
 /**
- * arc_emac_adjust_link - Adjust the PHY link duplex.
+ * emac_adjust_link - Adjust the PHY link duplex.
  * @ndev:	Pointer to the net_device structure.
  *
  * This function is called to change the duplex setting after auto negotiation
  * is done by the PHY.
  */
-static void arc_emac_adjust_link(struct net_device *ndev)
+static void emac_adjust_link(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	struct phy_device *phy_dev = priv->phy_dev;
 	unsigned int reg, state_changed = 0;
 
@@ -50,17 +49,19 @@ static void arc_emac_adjust_link(struct net_device *ndev)
 	if (priv->speed != phy_dev->speed) {
 		priv->speed = phy_dev->speed;
 		state_changed = 1;
+		if (priv->plat_data->set_mac_speed)
+			priv->plat_data->set_mac_speed(priv->plat_data->priv, priv->speed);
 	}
 
 	if (priv->duplex != phy_dev->duplex) {
-		reg = arc_reg_get(priv, R_CTRL);
+		reg = emac_reg_get(priv, R_CTRL);
 
 		if (DUPLEX_FULL == phy_dev->duplex)
 			reg |= ENFL_MASK;
 		else
 			reg &= ~ENFL_MASK;
 
-		arc_reg_set(priv, R_CTRL, reg);
+		emac_reg_set(priv, R_CTRL, reg);
 		priv->duplex = phy_dev->duplex;
 		state_changed = 1;
 	}
@@ -70,7 +71,7 @@ static void arc_emac_adjust_link(struct net_device *ndev)
 }
 
 /**
- * arc_emac_get_settings - Get PHY settings.
+ * emac_get_settings - Get PHY settings.
  * @ndev:	Pointer to net_device structure.
  * @cmd:	Pointer to ethtool_cmd structure.
  *
@@ -79,16 +80,16 @@ static void arc_emac_adjust_link(struct net_device *ndev)
  * relevant PHY ethtool API to get the PHY settings.
  * Issue "ethtool ethX" under linux prompt to execute this function.
  */
-static int arc_emac_get_settings(struct net_device *ndev,
+static int emac_get_settings(struct net_device *ndev,
 				 struct ethtool_cmd *cmd)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 
 	return phy_ethtool_gset(priv->phy_dev, cmd);
 }
 
 /**
- * arc_emac_set_settings - Set PHY settings as passed in the argument.
+ * emac_set_settings - Set PHY settings as passed in the argument.
  * @ndev:	Pointer to net_device structure.
  * @cmd:	Pointer to ethtool_cmd structure.
  *
@@ -98,10 +99,10 @@ static int arc_emac_get_settings(struct net_device *ndev,
  * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt to execute this
  * function.
  */
-static int arc_emac_set_settings(struct net_device *ndev,
-				 struct ethtool_cmd *cmd)
+static int emac_set_settings(struct net_device *ndev,
+			     struct ethtool_cmd *cmd)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -110,42 +111,44 @@ static int arc_emac_set_settings(struct net_device *ndev,
 }
 
 /**
- * arc_emac_get_drvinfo - Get EMAC driver information.
+ * emac_get_drvinfo - Get EMAC driver information.
  * @ndev:	Pointer to net_device structure.
  * @info:	Pointer to ethtool_drvinfo structure.
  *
  * This implements ethtool command for getting the driver information.
  * Issue "ethtool -i ethX" under linux prompt to execute this function.
  */
-static void arc_emac_get_drvinfo(struct net_device *ndev,
+static void emac_get_drvinfo(struct net_device *ndev,
 				 struct ethtool_drvinfo *info)
 {
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
-	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	struct emac_priv *priv = netdev_priv(ndev);
+
+	strlcpy(info->driver, priv->plat_data->name, sizeof(info->driver));
+	strlcpy(info->version, priv->plat_data->version, sizeof(info->version));
 }
 
-static const struct ethtool_ops arc_emac_ethtool_ops = {
-	.get_settings	= arc_emac_get_settings,
-	.set_settings	= arc_emac_set_settings,
-	.get_drvinfo	= arc_emac_get_drvinfo,
+static const struct ethtool_ops emac_ethtool_ops = {
+	.get_settings	= emac_get_settings,
+	.set_settings	= emac_set_settings,
+	.get_drvinfo	= emac_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
 };
 
 #define FIRST_OR_LAST_MASK	(FIRST_MASK | LAST_MASK)
 
 /**
- * arc_emac_tx_clean - clears processed by EMAC Tx BDs.
+ * emac_tx_clean - clears processed by EMAC Tx BDs.
  * @ndev:	Pointer to the network device.
  */
-static void arc_emac_tx_clean(struct net_device *ndev)
+static void emac_tx_clean(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &priv->stats;
 	unsigned int i;
 
 	for (i = 0; i < TX_BD_NUM; i++) {
 		unsigned int *txbd_dirty = &priv->txbd_dirty;
-		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
+		struct emac_bd *txbd = &priv->txbd[*txbd_dirty];
 		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
 		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
@@ -187,7 +190,7 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 }
 
 /**
- * arc_emac_rx - processing of Rx packets.
+ * emac_rx - processing of Rx packets.
  * @ndev:	Pointer to the network device.
  * @budget:	How many BDs to process on 1 call.
  *
@@ -195,16 +198,16 @@ static void arc_emac_tx_clean(struct net_device *ndev)
  *
  * Iterate through Rx BDs and deliver received packages to upper layer.
  */
-static int arc_emac_rx(struct net_device *ndev, int budget)
+static int emac_rx(struct net_device *ndev, int budget)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	unsigned int work_done;
 
 	for (work_done = 0; work_done < budget; work_done++) {
 		unsigned int *last_rx_bd = &priv->last_rx_bd;
 		struct net_device_stats *stats = &priv->stats;
 		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
-		struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
+		struct emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
 		unsigned int pktlen, info = le32_to_cpu(rxbd->info);
 		struct sk_buff *skb;
 		dma_addr_t addr;
@@ -281,55 +284,55 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 }
 
 /**
- * arc_emac_poll - NAPI poll handler.
+ * emac_poll - NAPI poll handler.
  * @napi:	Pointer to napi_struct structure.
  * @budget:	How many BDs to process on 1 call.
  *
  * returns:	Number of processed BDs
  */
-static int arc_emac_poll(struct napi_struct *napi, int budget)
+static int emac_poll(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	unsigned int work_done;
 
-	arc_emac_tx_clean(ndev);
+	emac_tx_clean(ndev);
 
-	work_done = arc_emac_rx(ndev, budget);
+	work_done = emac_rx(ndev, budget);
 	if (work_done < budget) {
 		napi_complete(napi);
-		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
+		emac_reg_or(priv, R_ENABLE, RXINT_MASK);
 	}
 
 	return work_done;
 }
 
 /**
- * arc_emac_intr - Global interrupt handler for EMAC.
+ * emac_intr - Global interrupt handler for EMAC.
  * @irq:		irq number.
  * @dev_instance:	device instance.
  *
  * returns: IRQ_HANDLED for all cases.
  *
- * ARC EMAC has only 1 interrupt line, and depending on bits raised in
+ * EMAC has only 1 interrupt line, and depending on bits raised in
  * STATUS register we may tell what is a reason for interrupt to fire.
  */
-static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
+static irqreturn_t emac_intr(int irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &priv->stats;
 	unsigned int status;
 
-	status = arc_reg_get(priv, R_STATUS);
+	status = emac_reg_get(priv, R_STATUS);
 	status &= ~MDIO_MASK;
 
 	/* Reset all flags except "MDIO complete" */
-	arc_reg_set(priv, R_STATUS, status);
+	emac_reg_set(priv, R_STATUS, status);
 
 	if (status & RXINT_MASK) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
+			emac_reg_clr(priv, R_ENABLE, RXINT_MASK);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -364,16 +367,16 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void arc_emac_poll_controller(struct net_device *dev)
+static void emac_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	arc_emac_intr(dev->irq, dev);
+	emac_intr(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
 
 /**
- * arc_emac_open - Open the network device.
+ * emac_open - Open the network device.
  * @ndev:	Pointer to the network device.
  *
  * returns: 0, on success or non-zero error value on failure.
@@ -382,9 +385,9 @@ static void arc_emac_poll_controller(struct net_device *dev)
  * for the EMAC device and starts the Tx queue.
  * It also connects to the phy device.
  */
-static int arc_emac_open(struct net_device *ndev)
+static int emac_open(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	struct phy_device *phy_dev = priv->phy_dev;
 	int i;
 
@@ -399,7 +402,7 @@ static int arc_emac_open(struct net_device *ndev)
 	for (i = 0; i < RX_BD_NUM; i++) {
 		dma_addr_t addr;
 		unsigned int *last_rx_bd = &priv->last_rx_bd;
-		struct arc_emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
+		struct emac_bd *rxbd = &priv->rxbd[*last_rx_bd];
 		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
 
 		rx_buff->skb = netdev_alloc_skb_ip_align(ndev,
@@ -432,18 +435,18 @@ static int arc_emac_open(struct net_device *ndev)
 	memset(priv->txbd, 0, TX_RING_SZ);
 
 	/* Initialize logical address filter */
-	arc_reg_set(priv, R_LAFL, 0);
-	arc_reg_set(priv, R_LAFH, 0);
+	emac_reg_set(priv, R_LAFL, 0);
+	emac_reg_set(priv, R_LAFH, 0);
 
 	/* Set BD ring pointers for device side */
-	arc_reg_set(priv, R_RX_RING, (unsigned int)priv->rxbd_dma);
-	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
+	emac_reg_set(priv, R_RX_RING, (unsigned int)priv->rxbd_dma);
+	emac_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
 
 	/* Enable interrupts */
-	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+	emac_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
 
 	/* Set CONTROL */
-	arc_reg_set(priv, R_CTRL,
+	emac_reg_set(priv, R_CTRL,
 		     (RX_BD_NUM << 24) |	/* RX BD table length */
 		     (TX_BD_NUM << 16) |	/* TX BD table length */
 		     TXRN_MASK | RXRN_MASK);
@@ -451,7 +454,7 @@ static int arc_emac_open(struct net_device *ndev)
 	napi_enable(&priv->napi);
 
 	/* Enable EMAC */
-	arc_reg_or(priv, R_CTRL, EN_MASK);
+	emac_reg_or(priv, R_CTRL, EN_MASK);
 
 	phy_start_aneg(priv->phy_dev);
 
@@ -461,24 +464,24 @@ static int arc_emac_open(struct net_device *ndev)
 }
 
 /**
- * arc_emac_set_rx_mode - Change the receive filtering mode.
+ * emac_set_rx_mode - Change the receive filtering mode.
  * @ndev:	Pointer to the network device.
  *
  * This function enables/disables promiscuous or all-multicast mode
  * and updates the multicast filtering list of the network device.
  */
-static void arc_emac_set_rx_mode(struct net_device *ndev)
+static void emac_set_rx_mode(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 
 	if (ndev->flags & IFF_PROMISC) {
-		arc_reg_or(priv, R_CTRL, PROM_MASK);
+		emac_reg_or(priv, R_CTRL, PROM_MASK);
 	} else {
-		arc_reg_clr(priv, R_CTRL, PROM_MASK);
+		emac_reg_clr(priv, R_CTRL, PROM_MASK);
 
 		if (ndev->flags & IFF_ALLMULTI) {
-			arc_reg_set(priv, R_LAFL, ~0);
-			arc_reg_set(priv, R_LAFH, ~0);
+			emac_reg_set(priv, R_LAFL, ~0);
+			emac_reg_set(priv, R_LAFH, ~0);
 		} else {
 			struct netdev_hw_addr *ha;
 			unsigned int filter[2] = { 0, 0 };
@@ -489,52 +492,52 @@ static void arc_emac_set_rx_mode(struct net_device *ndev)
 				filter[bit >> 5] |= 1 << (bit & 31);
 			}
 
-			arc_reg_set(priv, R_LAFL, filter[0]);
-			arc_reg_set(priv, R_LAFH, filter[1]);
+			emac_reg_set(priv, R_LAFL, filter[0]);
+			emac_reg_set(priv, R_LAFH, filter[1]);
 		}
 	}
 }
 
 /**
- * arc_emac_stop - Close the network device.
+ * emac_stop - Close the network device.
  * @ndev:	Pointer to the network device.
  *
  * This function stops the Tx queue, disables interrupts and frees the IRQ for
  * the EMAC device.
  * It also disconnects the PHY device associated with the EMAC device.
  */
-static int arc_emac_stop(struct net_device *ndev)
+static int emac_stop(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 
 	napi_disable(&priv->napi);
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts */
-	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+	emac_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
 
 	/* Disable EMAC */
-	arc_reg_clr(priv, R_CTRL, EN_MASK);
+	emac_reg_clr(priv, R_CTRL, EN_MASK);
 
 	return 0;
 }
 
 /**
- * arc_emac_stats - Get system network statistics.
+ * emac_stats - Get system network statistics.
  * @ndev:	Pointer to net_device structure.
  *
  * Returns the address of the device statistics structure.
  * Statistics are updated in interrupt handler.
  */
-static struct net_device_stats *arc_emac_stats(struct net_device *ndev)
+static struct net_device_stats *emac_stats(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	struct net_device_stats *stats = &priv->stats;
 	unsigned long miss, rxerr;
 	u8 rxcrc, rxfram, rxoflow;
 
-	rxerr = arc_reg_get(priv, R_RXERR);
-	miss = arc_reg_get(priv, R_MISS);
+	rxerr = emac_reg_get(priv, R_RXERR);
+	miss = emac_reg_get(priv, R_MISS);
 
 	rxcrc = rxerr;
 	rxfram = rxerr >> 8;
@@ -552,7 +555,7 @@ static struct net_device_stats *arc_emac_stats(struct net_device *ndev)
 }
 
 /**
- * arc_emac_tx - Starts the data transmission.
+ * emac_tx - Starts the data transmission.
  * @skb:	sk_buff pointer that contains data to be Transmitted.
  * @ndev:	Pointer to net_device structure.
  *
@@ -561,9 +564,9 @@ static struct net_device_stats *arc_emac_stats(struct net_device *ndev)
  *
  * This function is invoked from upper layers to initiate transmission.
  */
-static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
+static int emac_tx(struct sk_buff *skb, struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	unsigned int len, *txbd_curr = &priv->txbd_curr;
 	struct net_device_stats *stats = &priv->stats;
 	__le32 *info = &priv->txbd[*txbd_curr].info;
@@ -614,25 +617,25 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely((le32_to_cpu(*info) & OWN_MASK) == FOR_EMAC))
 		netif_stop_queue(ndev);
 
-	arc_reg_set(priv, R_STATUS, TXPL_MASK);
+	emac_reg_set(priv, R_STATUS, TXPL_MASK);
 
 	return NETDEV_TX_OK;
 }
 
-static void arc_emac_set_address_internal(struct net_device *ndev)
+static void emac_set_address_internal(struct net_device *ndev)
 {
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 	unsigned int addr_low, addr_hi;
 
 	addr_low = le32_to_cpu(*(__le32 *) &ndev->dev_addr[0]);
 	addr_hi = le16_to_cpu(*(__le16 *) &ndev->dev_addr[4]);
 
-	arc_reg_set(priv, R_ADDRL, addr_low);
-	arc_reg_set(priv, R_ADDRH, addr_hi);
+	emac_reg_set(priv, R_ADDRL, addr_low);
+	emac_reg_set(priv, R_ADDRH, addr_hi);
 }
 
 /**
- * arc_emac_set_address - Set the MAC address for this device.
+ * emac_set_address - Set the MAC address for this device.
  * @ndev:	Pointer to net_device structure.
  * @p:		6 byte Address to be written as MAC address.
  *
@@ -642,7 +645,7 @@ static void arc_emac_set_address_internal(struct net_device *ndev)
  * returns:	-EBUSY if the net device is busy or 0 if the address is set
  *		successfully.
  */
-static int arc_emac_set_address(struct net_device *ndev, void *p)
+static int emac_set_address(struct net_device *ndev, void *p)
 {
 	struct sockaddr *addr = p;
 
@@ -654,141 +657,129 @@ static int arc_emac_set_address(struct net_device *ndev, void *p)
 
 	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
 
-	arc_emac_set_address_internal(ndev);
+	emac_set_address_internal(ndev);
 
 	return 0;
 }
 
-static const struct net_device_ops arc_emac_netdev_ops = {
-	.ndo_open		= arc_emac_open,
-	.ndo_stop		= arc_emac_stop,
-	.ndo_start_xmit		= arc_emac_tx,
-	.ndo_set_mac_address	= arc_emac_set_address,
-	.ndo_get_stats		= arc_emac_stats,
-	.ndo_set_rx_mode	= arc_emac_set_rx_mode,
+static const struct net_device_ops emac_netdev_ops = {
+	.ndo_open		= emac_open,
+	.ndo_stop		= emac_stop,
+	.ndo_start_xmit		= emac_tx,
+	.ndo_set_mac_address	= emac_set_address,
+	.ndo_get_stats		= emac_stats,
+	.ndo_set_rx_mode	= emac_set_rx_mode,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= arc_emac_poll_controller,
+	.ndo_poll_controller	= emac_poll_controller,
 #endif
 };
 
-static int arc_emac_probe(struct platform_device *pdev)
+int emac_drv_probe(struct device *dev, const struct emac_platform_data *plat_data)
 {
 	struct resource res_regs;
 	struct device_node *phy_node;
-	struct arc_emac_priv *priv;
+	struct emac_priv *priv;
 	struct net_device *ndev;
 	const char *mac_addr;
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
 
-	ndev = alloc_etherdev(sizeof(struct arc_emac_priv));
+	ndev = alloc_etherdev(sizeof(struct emac_priv));
 	if (!ndev)
 		return -ENOMEM;
 
-	platform_set_drvdata(pdev, ndev);
-	SET_NETDEV_DEV(ndev, &pdev->dev);
+	dev_set_drvdata(dev, ndev);
+	SET_NETDEV_DEV(ndev, dev);
 
-	ndev->netdev_ops = &arc_emac_netdev_ops;
-	ndev->ethtool_ops = &arc_emac_ethtool_ops;
+	ndev->netdev_ops = &emac_netdev_ops;
+	ndev->ethtool_ops = &emac_ethtool_ops;
 	ndev->watchdog_timeo = TX_TIMEOUT;
 	/* FIXME :: no multicast support yet */
 	ndev->flags &= ~IFF_MULTICAST;
 
 	priv = netdev_priv(ndev);
-	priv->dev = &pdev->dev;
+	priv->dev = dev;
 	priv->ndev = ndev;
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
+	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);
+
+	if (plat_data->clk) {
+		err = clk_prepare_enable(plat_data->clk);
 		if (err) {
-			dev_err(&pdev->dev, "failed to enable clock\n");
+			dev_err(dev, "failed to enable clock\n");
 			goto out_clkget;
 		}
-
-		clock_frequency = clk_get_rate(priv->clk);
+		clock_frequency = clk_get_rate(plat_data->clk);
 	}
 
-	id = arc_reg_get(priv, R_ID);
+	id = emac_reg_get(priv, R_ID);
 
 	/* Check for EMAC revision 5 or 7, magic number */
 	if (!(id == 0x0005fd02 || id == 0x0007fd02)) {
-		dev_err(&pdev->dev, "ARC EMAC not detected, id=0x%x\n", id);
+		dev_err(dev, "EMAC not detected, id=0x%x\n", id);
 		err = -ENODEV;
 		goto out_clken;
 	}
-	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
+	dev_info(dev, "EMAC detected with id: 0x%x\n", id);
 
 	/* Set poll rate so that it polls every 1 ms */
-	arc_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
+	emac_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
 
 	ndev->irq = irq;
-	dev_info(&pdev->dev, "IRQ is %d\n", ndev->irq);
+	dev_dbg(dev, "IRQ is %d\n", ndev->irq);
 
 	/* Register interrupt handler for device */
-	err = devm_request_irq(&pdev->dev, ndev->irq, arc_emac_intr, 0,
+	err = devm_request_irq(dev, ndev->irq, emac_intr, 0,
 			       ndev->name, ndev);
 	if (err) {
-		dev_err(&pdev->dev, "could not allocate IRQ\n");
+		dev_err(dev, "could not allocate IRQ\n");
 		goto out_clken;
 	}
 
 	/* Get MAC address from device tree */
-	mac_addr = of_get_mac_address(pdev->dev.of_node);
+	mac_addr = of_get_mac_address(dev->of_node);
 
 	if (mac_addr)
 		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
 	else
 		eth_hw_addr_random(ndev);
 
-	arc_emac_set_address_internal(ndev);
-	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
+	emac_set_address_internal(ndev);
+	dev_info(dev, "MAC address is now %pM\n", ndev->dev_addr);
 
 	/* Do 1 allocation instead of 2 separate ones for Rx and Tx BD rings */
-	priv->rxbd = dmam_alloc_coherent(&pdev->dev, RX_RING_SZ + TX_RING_SZ,
+	priv->rxbd = dmam_alloc_coherent(dev, RX_RING_SZ + TX_RING_SZ,
 					 &priv->rxbd_dma, GFP_KERNEL);
 
 	if (!priv->rxbd) {
-		dev_err(&pdev->dev, "failed to allocate data buffers\n");
+		dev_err(dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
 		goto out_clken;
 	}
@@ -796,31 +787,31 @@ static int arc_emac_probe(struct platform_device *pdev)
 	priv->txbd = priv->rxbd + RX_BD_NUM;
 
 	priv->txbd_dma = priv->rxbd_dma + RX_RING_SZ;
-	dev_dbg(&pdev->dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
+	dev_dbg(dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
 		(unsigned int)priv->rxbd_dma, (unsigned int)priv->txbd_dma);
 
-	err = arc_mdio_probe(pdev, priv);
+	err = emac_mdio_probe(priv);
 	if (err) {
-		dev_err(&pdev->dev, "failed to probe MII bus\n");
+		dev_err(dev, "failed to probe MII bus\n");
 		goto out_clken;
 	}
 
-	priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
-				       PHY_INTERFACE_MODE_MII);
+	priv->phy_dev = of_phy_connect(ndev, phy_node, emac_adjust_link, 0,
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
 
-	netif_napi_add(ndev, &priv->napi, arc_emac_poll, ARC_EMAC_NAPI_WEIGHT);
+	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_NAPI_WEIGHT);
 
 	err = register_netdev(ndev);
 	if (err) {
-		dev_err(&pdev->dev, "failed to register network device\n");
+		dev_err(dev, "failed to register network device\n");
 		goto out_netif_api;
 	}
 
@@ -831,32 +822,31 @@ out_netif_api:
 	phy_disconnect(priv->phy_dev);
 	priv->phy_dev = NULL;
 out_mdio:
-	arc_mdio_remove(priv);
+	emac_mdio_remove(priv);
 out_clken:
-	if (!IS_ERR(priv->clk))
-		clk_disable_unprepare(priv->clk);
+	if (!IS_ERR(plat_data->clk))
+		clk_disable_unprepare(plat_data->clk);
 out_clkget:
-	if (!IS_ERR(priv->clk))
-		clk_put(priv->clk);
+	if (!IS_ERR(plat_data->clk))
+		clk_put(plat_data->clk);
 out_netdev:
 	free_netdev(ndev);
 	return err;
 }
 
-static int arc_emac_remove(struct platform_device *pdev)
+int emac_drv_remove(struct net_device *ndev)
 {
-	struct net_device *ndev = platform_get_drvdata(pdev);
-	struct arc_emac_priv *priv = netdev_priv(ndev);
+	struct emac_priv *priv = netdev_priv(ndev);
 
 	phy_disconnect(priv->phy_dev);
 	priv->phy_dev = NULL;
-	arc_mdio_remove(priv);
+	emac_mdio_remove(priv);
 	unregister_netdev(ndev);
 	netif_napi_del(&priv->napi);
 
-	if (!IS_ERR(priv->clk)) {
-		clk_disable_unprepare(priv->clk);
-		clk_put(priv->clk);
+	if (priv->plat_data->clk) {
+		clk_disable_unprepare(priv->plat_data->clk);
+		clk_put(priv->plat_data->clk);
 	}
 
 	free_netdev(ndev);
@@ -864,24 +854,6 @@ static int arc_emac_remove(struct platform_device *pdev)
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
-
 MODULE_AUTHOR("Alexey Brodkin <abrodkin@synopsys.com>");
-MODULE_DESCRIPTION("ARC EMAC driver");
+MODULE_DESCRIPTION("EMAC driver");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
index 26ba242..b1397ea 100644
--- a/drivers/net/ethernet/arc/emac_mdio.c
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -1,7 +1,7 @@
 /*
  * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
  *
- * MDIO implementation for ARC EMAC
+ * MDIO implementation for EMAC
  */
 
 #include <linux/delay.h>
@@ -11,26 +11,26 @@
 #include "emac.h"
 
 /* Number of seconds we wait for "MDIO complete" flag to appear */
-#define ARC_MDIO_COMPLETE_POLL_COUNT	1
+#define EMAC_MDIO_COMPLETE_POLL_COUNT	1
 
 /**
- * arc_mdio_complete_wait - Waits until MDIO transaction is completed.
- * @priv:	Pointer to ARC EMAC private data structure.
+ * emac_mdio_complete_wait - Waits until MDIO transaction is completed.
+ * @priv:	Pointer to EMAC private data structure.
  *
  * returns:	0 on success, -ETIMEDOUT on a timeout.
  */
-static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
+static int emac_mdio_complete_wait(struct emac_priv *priv)
 {
 	unsigned int i;
 
-	for (i = 0; i < ARC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {
-		unsigned int status = arc_reg_get(priv, R_STATUS);
+	for (i = 0; i < EMAC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {
+		unsigned int status = emac_reg_get(priv, R_STATUS);
 
 		status &= MDIO_MASK;
 
 		if (status) {
 			/* Reset "MDIO complete" flag */
-			arc_reg_set(priv, R_STATUS, status);
+			emac_reg_set(priv, R_STATUS, status);
 			return 0;
 		}
 
@@ -41,7 +41,7 @@ static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
 }
 
 /**
- * arc_mdio_read - MDIO interface read function.
+ * emac_mdio_read - MDIO interface read function.
  * @bus:	Pointer to MII bus structure.
  * @phy_addr:	Address of the PHY device.
  * @reg_num:	PHY register to read.
@@ -51,29 +51,29 @@ static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
  * Reads the contents of the requested register from the requested PHY
  * address.
  */
-static int arc_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
+static int emac_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
 {
-	struct arc_emac_priv *priv = bus->priv;
+	struct emac_priv *priv = bus->priv;
 	unsigned int value;
 	int error;
 
-	arc_reg_set(priv, R_MDIO,
+	emac_reg_set(priv, R_MDIO,
 		    0x60020000 | (phy_addr << 23) | (reg_num << 18));
 
-	error = arc_mdio_complete_wait(priv);
+	error = emac_mdio_complete_wait(priv);
 	if (error < 0)
 		return error;
 
-	value = arc_reg_get(priv, R_MDIO) & 0xffff;
+	value = emac_reg_get(priv, R_MDIO) & 0xffff;
 
-	dev_dbg(priv->dev, "arc_mdio_read(phy_addr=%i, reg_num=%x) = %x\n",
+	dev_dbg(priv->dev, "emac_mdio_read(phy_addr=%i, reg_num=%x) = %x\n",
 		phy_addr, reg_num, value);
 
 	return value;
 }
 
 /**
- * arc_mdio_write - MDIO interface write function.
+ * emac_mdio_write - MDIO interface write function.
  * @bus:	Pointer to MII bus structure.
  * @phy_addr:	Address of the PHY device.
  * @reg_num:	PHY register to write to.
@@ -83,32 +83,32 @@ static int arc_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
  *
  * Writes the value to the requested register.
  */
-static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
+static int emac_mdio_write(struct mii_bus *bus, int phy_addr,
 			  int reg_num, u16 value)
 {
-	struct arc_emac_priv *priv = bus->priv;
+	struct emac_priv *priv = bus->priv;
 
 	dev_dbg(priv->dev,
-		"arc_mdio_write(phy_addr=%i, reg_num=%x, value=%x)\n",
+		"emac_mdio_write(phy_addr=%i, reg_num=%x, value=%x)\n",
 		phy_addr, reg_num, value);
 
-	arc_reg_set(priv, R_MDIO,
+	emac_reg_set(priv, R_MDIO,
 		     0x50020000 | (phy_addr << 23) | (reg_num << 18) | value);
 
-	return arc_mdio_complete_wait(priv);
+	return emac_mdio_complete_wait(priv);
 }
 
 /**
- * arc_mdio_probe - MDIO probe function.
+ * emac_mdio_probe - MDIO probe function.
  * @pdev:	Pointer to platform device.
- * @priv:	Pointer to ARC EMAC private data structure.
+ * @priv:	Pointer to EMAC private data structure.
  *
  * returns:	0 on success, -ENOMEM when mdiobus_alloc
  * (to allocate memory for MII bus structure) fails.
  *
  * Sets up and registers the MDIO interface.
  */
-int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
+int emac_mdio_probe(struct emac_priv *priv)
 {
 	struct mii_bus *bus;
 	int error;
@@ -121,12 +121,12 @@ int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
 	bus->priv = priv;
 	bus->parent = priv->dev;
 	bus->name = "Synopsys MII Bus",
-	bus->read = &arc_mdio_read;
-	bus->write = &arc_mdio_write;
+	bus->read = &emac_mdio_read;
+	bus->write = &emac_mdio_write;
 
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
 
-	error = of_mdiobus_register(bus, pdev->dev.of_node);
+	error = of_mdiobus_register(bus, priv->dev->of_node);
 	if (error) {
 		dev_err(priv->dev, "cannot register MDIO bus %s\n", bus->name);
 		mdiobus_free(bus);
@@ -137,12 +137,12 @@ int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv)
 }
 
 /**
- * arc_mdio_remove - MDIO remove function.
- * @priv:	Pointer to ARC EMAC private data structure.
+ * emac_mdio_remove - MDIO remove function.
+ * @priv:	Pointer to EMAC private data structure.
  *
  * Unregisters the MDIO and frees any associate memory for MII bus.
  */
-int arc_mdio_remove(struct arc_emac_priv *priv)
+int emac_mdio_remove(struct emac_priv *priv)
 {
 	mdiobus_unregister(priv->bus);
 	mdiobus_free(priv->bus);
-- 
1.9.1
