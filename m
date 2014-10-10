From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: enable driver to work without a device tree
Date: Fri, 10 Oct 2014 11:35:00 -0700 (PDT)
Message-ID: <20141010183501.0189F1008A3@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:56995 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbaJJSfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:35:03 -0400
Received: by mail-ig0-f201.google.com with SMTP id h15so594388igd.2
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:35:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom 7xxx MIPS-based STB platforms do not use device trees.
Modify bcmgenet driver so that it can be used on those platforms.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/Kconfig          |   1 -
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  30 +++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  11 ++
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 169 +++++++++++++++++++++----
 4 files changed, 179 insertions(+), 32 deletions(-)

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
index fff2634..1ec7a32 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2475,6 +2475,7 @@ static const struct of_device_id bcmgenet_match[] = {
 
 static int bcmgenet_probe(struct platform_device *pdev)
 {
+	struct bcmgenet_platform_data *pd = pdev->dev.platform_data;
 	struct device_node *dn = pdev->dev.of_node;
 	const struct of_device_id *of_id;
 	struct bcmgenet_priv *priv;
@@ -2490,9 +2491,13 @@ static int bcmgenet_probe(struct platform_device *pdev)
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
@@ -2504,11 +2509,15 @@ static int bcmgenet_probe(struct platform_device *pdev)
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
@@ -2548,7 +2557,10 @@ static int bcmgenet_probe(struct platform_device *pdev)
 
 	priv->dev = dev;
 	priv->pdev = pdev;
-	priv->version = (enum bcmgenet_version)of_id->data;
+	if (of_id)
+		priv->version = (enum bcmgenet_version)of_id->data;
+	else
+		priv->version = pd->genet_version;
 
 	priv->clk = devm_clk_get(&priv->pdev->dev, "enet");
 	if (IS_ERR(priv->clk))
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index dbf524e..5191e3f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -17,6 +17,17 @@
 #include <linux/if_vlan.h>
 #include <linux/phy.h>
 
+struct bcmgenet_platform_data {
+	void __iomem	*base_reg;
+	int		irq0;
+	int		irq1;
+	int		phy_type;
+	int		phy_addr;
+	int		phy_speed;
+	u8		macaddr[ETH_ALEN];
+	int		genet_version;
+};
+
 /* total number of Buffer Descriptors, same for Rx/Tx */
 #define TOTAL_DESC				256
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 9ff799a..e5ff913 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -157,6 +157,21 @@ static void bcmgenet_mii_setup(struct net_device *dev)
 	phy_print_status(phydev);
 }
 
+static int bcmgenet_moca_fphy_update(struct net_device *dev,
+				     struct fixed_phy_status *status)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+
+	/*
+	 * MoCA daemon updates phydev->autoneg to reflect the link status.
+	 * Update MoCA fixed PHY status accordingly, so that the PHY state
+	 * machine becomes aware of the real link status.
+	 */
+	status->link = phydev->autoneg;
+	return 0;
+}
+
 void bcmgenet_mii_reset(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
@@ -311,22 +326,6 @@ static int bcmgenet_mii_probe(struct net_device *dev)
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
 
@@ -336,11 +335,39 @@ static int bcmgenet_mii_probe(struct net_device *dev)
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
@@ -437,6 +464,104 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	return 0;
 }
 
+static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
+{
+	struct device *kdev = &priv->pdev->dev;
+	struct bcmgenet_platform_data *pd = kdev->platform_data;
+	struct mii_bus *mdio = priv->mii_bus;
+	int phy_addr = pd->phy_addr;
+	struct phy_device *phydev;
+	int ret;
+	int i;
+
+	/* Disable automatic MDIO bus scan */
+	mdio->phy_mask = ~0;
+
+	/* Clear all the IRQ properties */
+	if (mdio->irq)
+		for (i = 0; i < PHY_MAX_ADDR; i++)
+			mdio->irq[i] = PHY_POLL;
+
+	/* Register the MDIO bus */
+	ret = mdiobus_register(mdio);
+	if (ret) {
+		dev_err(kdev, "failed to register MDIO bus\n");
+		return ret;
+	}
+
+	/*
+	 * bcmgenet_platform_data needs to pass a valid PHY address for
+	 * internal/external PHY or -1 for MoCA PHY.
+	 */
+	if (phy_addr >= 0 && phy_addr < PHY_MAX_ADDR) {
+		/*
+		 * 10/100/1000 Ethernet port with external or internal PHY.
+		 */
+		phydev = get_phy_device(mdio, phy_addr, false);
+		if (!phydev || IS_ERR(phydev)) {
+			dev_err(kdev, "failed to create PHY device\n");
+			mdiobus_unregister(mdio);
+			return 1;
+		}
+
+		phydev->irq = PHY_POLL;
+
+		ret = phy_device_register(phydev);
+		if (ret) {
+			dev_err(kdev, "failed to register PHY device\n");
+			phy_device_free(phydev);
+			mdiobus_unregister(mdio);
+			return 1;
+		}
+
+		priv->phydev = phydev;
+		priv->phy_interface = pd->phy_type;
+	} else {
+		/*
+		 * MoCA port with no MDIO-accessible PHY.
+		 * We need to use 1000/HD fixed PHY to represent the link layer.
+		 * MoCA daemon interacts with this PHY via ethtool.
+		 */
+		struct fixed_phy_status moca_fphy_status = {
+			.link = 0,
+			.duplex = 0,
+			.speed = 1000,
+			.pause = 0,
+			.asym_pause = 0,
+		};
+
+		phydev = fixed_phy_register(PHY_POLL, &moca_fphy_status, NULL);
+		if (!phydev || IS_ERR(phydev)) {
+			dev_err(kdev, "failed to register fixed PHY device\n");
+			mdiobus_unregister(mdio);
+			return 1;
+		}
+
+		phydev->autoneg = AUTONEG_DISABLE;
+
+		ret = fixed_phy_set_link_update(phydev,
+						bcmgenet_moca_fphy_update);
+		if (ret) {
+			dev_err(kdev, "failed to set fixed PHY link update\n");
+		}
+
+		priv->phydev = phydev;
+		priv->phy_interface = PHY_INTERFACE_MODE_MOCA;
+	}
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
@@ -446,7 +571,7 @@ int bcmgenet_mii_init(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	ret = bcmgenet_mii_of_init(priv);
+	ret = bcmgenet_mii_bus_init(priv);
 	if (ret)
 		goto out_free;
 
-- 
2.1.0.rc2.206.gedb03e5
