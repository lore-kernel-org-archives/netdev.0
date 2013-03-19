From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v6] net: sh_eth: Add support of device tree probe
Date: Tue, 19 Mar 2013 15:39:56 +0900
Message-ID: <1363675196-8940-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: devicetree-discuss@lists.ozlabs.org, magnus.damm@gmail.com,
	kda@linux-powerpc.org, horms+renesas@verge.net.au,
	mark.rutland@arm.com, grant.likely@secretlab.ca,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:59289 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351Ab3CSGkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 02:40:09 -0400
Received: by mail-da0-f54.google.com with SMTP id p1so115442dad.27
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 23:40:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support of device tree probe for Renesas sh-ether driver.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

V6: - Add renesas,sh-eth-gigabit, renesas,sh-eth-sh4 and
      renesas,sh-eth-sh3-sh2 to compatible string.
	- Remove sh-eth,register-type. This is supplemented by the
      compatible string.
    - Use the of_property_read_bool instead of of_find_property.
    - Add sanity chheck for of_property_read_u32.
    - Update document.
V5: - Rewrite sh_eth_parse_dt().
      Remove of_device_is_available() and CONFIG_OF from support OF
      checking function and re-add empty sh_eth_parse_dt().
    - Add CONFIG_PM to definition of dev_pm_ops.
	- Add CONFIG_OF to definition of of_device_id.
V4: - Remove empty sh_eth_parse_dt().
V3: - Remove empty sh_eth_parse_dt().
V3: - Removed sentnece of "needs-init" from document.
V2: - Removed ether_setup().
    - Fixed typo from "sh-etn" to "sh-eth".
	- Removed "needs-init" and sh-eth,endian from definition of DT.
	- Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
	  in definition of DT.
---
 Documentation/devicetree/bindings/net/sh_ether.txt |   48 +++++++
 drivers/net/ethernet/renesas/sh_eth.c              |  145 ++++++++++++++++----
 2 files changed, 168 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt

diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt b/Documentation/devicetree/bindings/net/sh_ether.txt
new file mode 100644
index 0000000..d1f961c
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/sh_ether.txt
@@ -0,0 +1,48 @@
+* Renesas Electronics SuperH EMAC
+
+This file provides information, what the device node
+for the sh_eth interface contains.
+
+Required properties:
+- compatible:                   "renesas,sh-eth-gigabit": If a device has
+                                            a function of gigabit, you should
+											set this.
+                                "renesas,sh-eth-sh4": If this is provided by
+                                            SH4, you should set this.
+                                "renesas,sh-eth-sh3-sh2": If this is provided
+                                            by SH3 or SH2, you should set this.
+
+- interrupt-parent:             The phandle for the interrupt controller that
+                                services interrupts for this device.
+
+- reg:                          Offset and length of the register set for the
+                                device. If device has TSU registers, you need
+                                to set up two register information here.
+
+- interrupts:                   Interrupt mapping for the sh_eth interrupt
+                                sources (vector id). You can set one value.
+
+- phy-mode:                     String, operation mode of the PHY interface
+                                (a string that of_get_phy_mode() can understand).
+
+- sh-eth,phy-id:                PHY id.
+
+Optional properties:
+- local-mac-address:            6 bytes, mac address
+- sh-eth,no-ether-link:         Set link control by software. When device does
+                                not support ether-link, set.
+- sh-eth,ether-link-active-low: Set link check method.
+                                When detection of link is treated as active-low,
+                                set.
+- sh-eth,edmac-big-endian:      Set big endian for sh_eth dmac.
+                                It work as little endian when this is not set.
+
+Example (armadillo800eva):
+	sh-eth@e9a00000 {
+		compatible = "renesas,sh-eth-gigabit";
+		interrupt-parent = <&intca>;
+		reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
+		interrupts = <0x500>;
+		phy-mode = "mii";
+		sh-eth,phy-id = <0>;
+	};
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 7a6471d..d9df68e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1,7 +1,7 @@
 /*
  *  SuperH Ethernet device driver
  *
- *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
+ *  Copyright (C) 2006-2013 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2012 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -31,6 +31,12 @@
 #include <linux/platform_device.h>
 #include <linux/mdio-bitbang.h>
 #include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_platform.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
 #include <linux/phy.h>
 #include <linux/cache.h>
 #include <linux/io.h>
@@ -2340,26 +2346,88 @@ static const struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
+#ifdef CONFIG_OF
+static struct sh_eth_plat_data *
+sh_eth_parse_dt(struct device *dev, struct net_device *ndev,
+				struct device_node *np)
+{
+	struct sh_eth_plat_data *pdata;
+
+	pdata = devm_kzalloc(dev, sizeof(struct sh_eth_plat_data),
+					GFP_KERNEL);
+	if (!pdata) {
+		dev_err(dev, "%s: failed to allocate config data\n", __func__);
+		return NULL;
+	}
+
+	pdata->phy_interface = of_get_phy_mode(np);
+
+	if (of_property_read_u32(np, "sh-eth,phy-id", &pdata->phy))
+		goto error;
+
+	pdata->edmac_endian =
+		of_property_read_bool(np, "sh-eth,edmac-big-endian");
+
+	pdata->no_ether_link =
+		of_property_read_bool(np, "sh-eth,no-ether-link");
+
+	pdata->ether_link_active_low =
+		of_property_read_bool(np, "sh-eth,ether-link-active-low");
+
+	if (of_device_is_compatible(np, "renesas,sh-eth-gigabit"))
+		pdata->register_type = SH_ETH_REG_GIGABIT;
+	else if (of_device_is_compatible(np, "renesas,sh-eth-sh4"))
+		pdata->register_type = SH_ETH_REG_FAST_SH4;
+	else if (of_device_is_compatible(np, "renesas,sh-eth-sh3-sh2"))
+		pdata->register_type = SH_ETH_REG_FAST_SH3_SH2;
+	else
+		pdata->register_type = -EINVAL;
+
+#ifdef CONFIG_OF_NET
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		const char *macaddr = of_get_mac_address(np);
+		if (macaddr)
+			memcpy(pdata->mac_addr, macaddr, ETH_ALEN);
+	}
+#endif
+
+	return pdata;
+
+error:
+	devm_kfree(dev, pdata);
+	return NULL;
+}
+#else
+static inline struct sh_eth_plat_data *
+sh_eth_parse_dt(struct device *dev, struct net_device *ndev,
+				struct device_node *np)
+{
+	return NULL;
+}
+#endif
+
 static int sh_eth_drv_probe(struct platform_device *pdev)
 {
-	int ret, devno = 0;
+	int ret = 0, devno = 0;
 	struct resource *res;
 	struct net_device *ndev = NULL;
 	struct sh_eth_private *mdp = NULL;
 	struct sh_eth_plat_data *pd;
+	struct device_node *np = pdev->dev.of_node;
+
+	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
+	if (!ndev) {
+		ret = -ENOMEM;
+		goto out;
+	}
 
+	mdp = netdev_priv(ndev);
 	/* get base addr */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (unlikely(res == NULL)) {
 		dev_err(&pdev->dev, "invalid resource\n");
 		ret = -EINVAL;
-		goto out;
-	}
-
-	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
-	if (!ndev) {
-		ret = -ENOMEM;
-		goto out;
+		goto out_release;
 	}
 
 	/* The sh Ether-specific entries in the device structure. */
@@ -2376,14 +2444,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	}
 	ndev->irq = ret;
 
-	SET_NETDEV_DEV(ndev, &pdev->dev);
-
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(ndev);
-
-	mdp = netdev_priv(ndev);
-	mdp->num_tx_ring = TX_RING_SIZE;
-	mdp->num_rx_ring = RX_RING_SIZE;
 	mdp->addr = ioremap(res->start, resource_size(res));
 	if (mdp->addr == NULL) {
 		ret = -ENOMEM;
@@ -2391,12 +2451,33 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out_release;
 	}
 
+	if (np) {
+		pd = sh_eth_parse_dt(&pdev->dev, ndev, np);
+		if (pdev->dev.platform_data && pd) {
+			struct sh_eth_plat_data *tmp =
+				pdev->dev.platform_data;
+			pd->set_mdio_gate = tmp->set_mdio_gate;
+			pd->needs_init = tmp->needs_init;
+		}
+	} else
+		pd = pdev->dev.platform_data;
+
+	if (!pd) {
+		dev_err(&pdev->dev, "no setup data defined\n");
+		ret = -EINVAL;
+		goto out_release;
+	}
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	mdp->num_tx_ring = TX_RING_SIZE;
+	mdp->num_rx_ring = RX_RING_SIZE;
+
 	spin_lock_init(&mdp->lock);
 	mdp->pdev = pdev;
 	pm_runtime_enable(&pdev->dev);
 	pm_runtime_resume(&pdev->dev);
 
-	pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
 	/* get PHY ID */
 	mdp->phy_id = pd->phy;
 	mdp->phy_interface = pd->phy_interface;
@@ -2405,6 +2486,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp->no_ether_link = pd->no_ether_link;
 	mdp->ether_link_active_low = pd->ether_link_active_low;
 	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);
+	/* read and set MAC address */
+	read_mac_address(ndev, pd->mac_addr);
 
 	/* set cpu data */
 #if defined(SH_ETH_HAS_BOTH_MODULES)
@@ -2422,20 +2505,16 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* debug message level */
 	mdp->msg_enable = SH_ETH_DEF_MSG_ENABLE;
 
-	/* read and set MAC address */
-	read_mac_address(ndev, pd->mac_addr);
-
 	/* ioremap the TSU registers */
 	if (mdp->cd->tsu) {
 		struct resource *rtsu;
 		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 		if (!rtsu) {
 			dev_err(&pdev->dev, "Not found TSU resource\n");
-			ret = -ENODEV;
 			goto out_release;
 		}
 		mdp->tsu_addr = ioremap(rtsu->start,
-					resource_size(rtsu));
+				resource_size(rtsu));
 		mdp->port = devno % 2;
 		ndev->features = NETIF_F_HW_VLAN_FILTER;
 	}
@@ -2502,6 +2581,7 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int sh_eth_runtime_nop(struct device *dev)
 {
 	/*
@@ -2515,17 +2595,32 @@ static int sh_eth_runtime_nop(struct device *dev)
 	return 0;
 }
 
-static struct dev_pm_ops sh_eth_dev_pm_ops = {
+static const struct dev_pm_ops sh_eth_dev_pm_ops = {
 	.runtime_suspend = sh_eth_runtime_nop,
 	.runtime_resume = sh_eth_runtime_nop,
 };
+#define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
+#else
+#define SH_ETH_PM_OPS NULL
+#endif
+
+#ifdef CONFIG_OF
+static const struct of_device_id sh_eth_match[] = {
+	{ .compatible = "renesas,sh-eth-gigabit", },
+	{ .compatible = "renesas,sh-eth-sh4", },
+	{ .compatible = "renesas,sh-eth-sh3-sh2", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, sh_eth_match);
+#endif
 
 static struct platform_driver sh_eth_driver = {
 	.probe = sh_eth_drv_probe,
 	.remove = sh_eth_drv_remove,
 	.driver = {
 		   .name = CARDNAME,
-		   .pm = &sh_eth_dev_pm_ops,
+		   .pm = SH_ETH_PM_OPS,
+		   .of_match_table = of_match_ptr(sh_eth_match),
 	},
 };
 
-- 
1.7.10.4
