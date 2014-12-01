From: Petri Gynther <pgynther@google.com>
Subject: [PATCH v2 net-next] net: bcmgenet: enable driver to work without a device tree
Date: Mon,  1 Dec 2014 14:08:28 -0800 (PST)
Message-ID: <20141201220828.942A7220726@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:47630 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934AbaLAWIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 17:08:30 -0500
Received: by mail-ie0-f202.google.com with SMTP id rl12so1202594iec.3
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 14:08:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom 7xxx MIPS-based STB platforms do not use device trees.
Modify bcmgenet driver so that it can be used on those platforms.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/Kconfig          |   1 -
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  31 ++++--
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 134 +++++++++++++++++++++----
 include/linux/platform_data/bcmgenet.h         |  18 ++++
 4 files changed, 152 insertions(+), 32 deletions(-)
 create mode 100644 include/linux/platform_data/bcmgenet.h

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index c3e260c..888247a 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -62,7 +62,6 @@ config BCM63XX_ENET
 
 config BCMGENET
 	tristate "Broadcom GENET internal MAC support"
-	depends on OF
 	select MII
 	select PHYLIB
 	select FIXED_PHY if BCMGENET=y
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f2fadb0..861c298 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -42,6 +42,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/phy.h>
+#include <linux/platform_data/bcmgenet.h>
 
 #include <asm/unaligned.h>
 
@@ -2586,6 +2587,7 @@ static const struct of_device_id bcmgenet_match[] = {
 
 static int bcmgenet_probe(struct platform_device *pdev)
 {
+	struct bcmgenet_platform_data *pd = pdev->dev.platform_data;
 	struct device_node *dn = pdev->dev.of_node;
 	const struct of_device_id *of_id;
 	struct bcmgenet_priv *priv;
@@ -2601,9 +2603,13 @@ static int bcmgenet_probe(struct platform_device *pdev)
 		return -ENOMEM;
 	}
 
-	of_id = of_match_node(bcmgenet_match, dn);
-	if (!of_id)
-		return -EINVAL;
+	if (dn) {
+		of_id = of_match_node(bcmgenet_match, dn);
+		if (!of_id)
+			return -EINVAL;
+	} else {
+		of_id = NULL;
+	}
 
 	priv = netdev_priv(dev);
 	priv->irq0 = platform_get_irq(pdev, 0);
@@ -2615,11 +2621,15 @@ static int bcmgenet_probe(struct platform_device *pdev)
 		goto err;
 	}
 
-	macaddr = of_get_mac_address(dn);
-	if (!macaddr) {
-		dev_err(&pdev->dev, "can't find MAC address\n");
-		err = -EINVAL;
-		goto err;
+	if (dn) {
+		macaddr = of_get_mac_address(dn);
+		if (!macaddr) {
+			dev_err(&pdev->dev, "can't find MAC address\n");
+			err = -EINVAL;
+			goto err;
+		}
+	} else {
+		macaddr = pd->macaddr;
 	}
 
 	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2659,7 +2669,10 @@ static int bcmgenet_probe(struct platform_device *pdev)
 
 	priv->dev = dev;
 	priv->pdev = pdev;
-	priv->version = (enum bcmgenet_version)of_id->data;
+	if (of_id)
+		priv->version = (enum bcmgenet_version)of_id->data;
+	else
+		priv->version = pd->genet_version;
 
 	priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
 	if (IS_ERR(priv->clk))
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 933cd7e..f758686 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -23,6 +23,7 @@
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
+#include <linux/platform_data/bcmgenet.h>
 
 #include "bcmgenet.h"
 
@@ -312,22 +313,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	u32 phy_flags;
 	int ret;
 
-	if (priv->phydev) {
-		pr_info("PHY already attached\n");
-		return 0;
-	}
-
-	/* In the case of a fixed PHY, the DT node associated
-	 * to the PHY is the Ethernet MAC DT node.
-	 */
-	if (!priv->phy_dn && of_phy_is_fixed_link(dn)) {
-		ret = of_phy_register_fixed_link(dn);
-		if (ret)
-			return ret;
-
-		priv->phy_dn = of_node_get(dn);
-	}
-
 	/* Communicate the integrated PHY revision */
 	phy_flags = priv->gphy_rev;
 
@@ -337,11 +322,39 @@ static int bcmgenet_mii_probe(struct net_device *dev)
 	priv->old_duplex = -1;
 	priv->old_pause = -1;
 
-	phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup,
-				phy_flags, priv->phy_interface);
-	if (!phydev) {
-		pr_err("could not attach to PHY\n");
-		return -ENODEV;
+	if (dn) {
+		if (priv->phydev) {
+			pr_info("PHY already attached\n");
+			return 0;
+		}
+
+		/* In the case of a fixed PHY, the DT node associated
+		 * to the PHY is the Ethernet MAC DT node.
+		 */
+		if (!priv->phy_dn && of_phy_is_fixed_link(dn)) {
+			ret = of_phy_register_fixed_link(dn);
+			if (ret)
+				return ret;
+
+			priv->phy_dn = of_node_get(dn);
+		}
+
+		phydev = of_phy_connect(dev, priv->phy_dn, bcmgenet_mii_setup,
+					phy_flags, priv->phy_interface);
+		if (!phydev) {
+			pr_err("could not attach to PHY\n");
+			return -ENODEV;
+		}
+	} else {
+		phydev = priv->phydev;
+		phydev->dev_flags = phy_flags;
+
+		ret = phy_connect_direct(dev, phydev, bcmgenet_mii_setup,
+					 priv->phy_interface);
+		if (ret) {
+			pr_err("could not attach to PHY\n");
+			return -ENODEV;
+		}
 	}
 
 	priv->phydev = phydev;
@@ -438,6 +451,83 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	return 0;
 }
 
+static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
+{
+	struct device *kdev = &priv->pdev->dev;
+	struct bcmgenet_platform_data *pd = kdev->platform_data;
+	struct mii_bus *mdio = priv->mii_bus;
+	struct phy_device *phydev;
+	int ret;
+	int i;
+
+	if (pd->phy_type != PHY_INTERFACE_MODE_MOCA && pd->mdio_enabled) {
+		/*
+		 * Internal or external PHY with MDIO access
+		 */
+		if (pd->phy_addr >= 0 && pd->phy_addr < PHY_MAX_ADDR)
+			mdio->phy_mask = ~(1 << pd->phy_addr);
+		else
+			mdio->phy_mask = 0;
+
+		ret = mdiobus_register(mdio);
+		if (ret) {
+			dev_err(kdev, "failed to register MDIO bus\n");
+			return ret;
+		}
+
+		if (pd->phy_addr >= 0 && pd->phy_addr < PHY_MAX_ADDR) {
+			phydev = mdio->phy_map[pd->phy_addr];
+		} else {
+			phydev = NULL;
+			for (i = 0; i < PHY_MAX_ADDR; i++) {
+				if (mdio->phy_map[i]) {
+					phydev = mdio->phy_map[i];
+					break;
+				}
+			}
+		}
+
+		if (!phydev) {
+			dev_err(kdev, "failed to register PHY device\n");
+			mdiobus_unregister(mdio);
+			return -ENODEV;
+		}
+	} else {
+		/*
+		 * MoCA port or no MDIO access.
+		 * Use 1000/FD fixed PHY to represent the link layer.
+		 */
+		struct fixed_phy_status fphy_status = {
+			.link = 1,
+			.duplex = DUPLEX_FULL,
+			.speed = SPEED_1000,
+			.pause = 0,
+			.asym_pause = 0,
+		};
+
+		phydev = fixed_phy_register(PHY_POLL, &fphy_status, NULL);
+		if (!phydev || IS_ERR(phydev)) {
+			dev_err(kdev, "failed to register fixed PHY device\n");
+			return -ENODEV;
+		}
+	}
+
+	priv->phydev = phydev;
+	priv->phy_interface = pd->phy_type;
+
+	return 0;
+}
+
+static int bcmgenet_mii_bus_init(struct bcmgenet_priv *priv)
+{
+	struct device_node *dn = priv->pdev->dev.of_node;
+
+	if (dn)
+		return bcmgenet_mii_of_init(priv);
+	else
+		return bcmgenet_mii_pd_init(priv);
+}
+
 int bcmgenet_mii_init(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -447,7 +537,7 @@ int bcmgenet_mii_init(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	ret = bcmgenet_mii_of_init(priv);
+	ret = bcmgenet_mii_bus_init(priv);
 	if (ret)
 		goto out_free;
 
diff --git a/include/linux/platform_data/bcmgenet.h b/include/linux/platform_data/bcmgenet.h
new file mode 100644
index 0000000..3660133
--- /dev/null
+++ b/include/linux/platform_data/bcmgenet.h
@@ -0,0 +1,18 @@
+#ifndef __LINUX_PLATFORM_DATA_BCMGENET_H__
+#define __LINUX_PLATFORM_DATA_BCMGENET_H__
+
+#include <linux/compiler.h>
+#include <linux/if_ether.h>
+
+struct bcmgenet_platform_data {
+	void __iomem *base_reg;
+	int           irq0;
+	int           irq1;
+	bool          mdio_enabled;
+	int           phy_type;
+	int           phy_addr;
+	u8            macaddr[ETH_ALEN];
+	int           genet_version;
+};
+
+#endif
-- 
2.2.0.rc0.207.ga3a616c
