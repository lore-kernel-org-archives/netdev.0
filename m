From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH 1/5] stmmac: create of compatible mdio bus for stmacc driver
Date: Fri,  4 Dec 2015 17:08:41 +0800
Message-ID: <1449220125-67417-2-git-send-email-preid@electromag.com.au>
References: <1449220125-67417-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:52048 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755835AbbLDJIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 04:08:50 -0500
In-Reply-To: <1449220125-67417-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DSA driver needs to be passed a reference to an mdio bus. Typically
the mac is configured to use a fixed link but the mdio bus still needs
to be registered so that it con configure the switch.
This patch follows the same process as the altera tse ethernet driver for
creation of the mdio bus.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 Documentation/devicetree/bindings/net/stmmac.txt   | 10 ++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 32 ++++++++++++++++------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  2 +-
 3 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index f34fc3c..0056c4c 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -47,7 +47,8 @@ Optional properties:
 - snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
 - tx-fifo-depth: See ethernet.txt file in the same directory
 - rx-fifo-depth: See ethernet.txt file in the same directory
-
+- mdio: with compatible = "snps,dwmac-mdio", create and register mdio bus.
+  
 Examples:
 
 	gmac0: ethernet@e0800000 {
@@ -65,4 +66,11 @@ Examples:
 		tx-fifo-depth = <16384>;
 		clocks = <&clock>;
 		clock-names = "stmmaceth";
+		mdio0: mdio@0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "snps,dwmac-mdio";
+			phy1: ethernet-phy@0 {
+			};
+		};    
 	};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index bba670c..1d972e3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -29,7 +29,7 @@
 #include <linux/slab.h>
 #include <linux/of.h>
 #include <linux/of_gpio.h>
-
+#include <linux/of_mdio.h>
 #include <asm/io.h>
 
 #include "stmmac.h"
@@ -201,6 +201,25 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
 	int addr, found;
 
+#ifdef CONFIG_OF
+	struct device_node *mdio_node = NULL;
+	struct device_node *child_node = NULL;
+
+	for_each_child_of_node(priv->device->of_node, child_node) {
+		if (of_device_is_compatible(child_node, "snps,dwmac-mdio")) {
+			mdio_node = child_node;
+			break;
+		}
+	}
+
+	if (mdio_node) {
+		netdev_dbg(ndev, "FOUND MDIO subnode\n");
+	} else {
+		netdev_err(ndev, "NO MDIO subnode\n");
+		return 0;
+	}
+#endif
+
 	if (!mdio_bus_data)
 		return 0;
 
@@ -231,7 +250,11 @@ int stmmac_mdio_register(struct net_device *ndev)
 	new_bus->irq = irqlist;
 	new_bus->phy_mask = mdio_bus_data->phy_mask;
 	new_bus->parent = priv->device;
+#ifdef CONFIG_OF
+	err = of_mdiobus_register(new_bus, mdio_node);	
+#else
 	err = mdiobus_register(new_bus);
+#endif
 	if (err != 0) {
 		pr_err("%s: Cannot register as MDIO bus\n", new_bus->name);
 		goto bus_register_fail;
@@ -284,13 +307,6 @@ int stmmac_mdio_register(struct net_device *ndev)
 		}
 	}
 
-	if (!found) {
-		pr_warn("%s: No PHY found\n", ndev->name);
-		mdiobus_unregister(new_bus);
-		mdiobus_free(new_bus);
-		return -ENODEV;
-	}
-
 	priv->mii = new_bus;
 
 	return 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index d02691b..6863420 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -146,7 +146,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr) == 0)
 		dev_warn(&pdev->dev, "snps,phy-addr property is deprecated\n");
 
-	if (plat->phy_node || plat->phy_bus_name)
+	if (plat->phy_bus_name)
 		plat->mdio_bus_data = NULL;
 	else
 		plat->mdio_bus_data =
-- 
1.8.3.1
