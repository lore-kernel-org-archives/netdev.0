From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH v3 04/10] net: davinci_emac: switch to new mdio
Date: Tue,  7 Sep 2010 16:25:36 -0400
Message-ID: <1283891142-15522-5-git-send-email-cyril@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com>
Cc: davem@davemloft.net, khilman@deeprootsystems.com, tony@atomide.com,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:55218 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758268Ab0IGUZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 16:25:50 -0400
In-Reply-To: <1283891142-15522-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch switches the emac implementation over to the newly separated
MDIO driver.

With this, the mdio bus frequency defaults to a safe 2.2MHz.  Boards may
optionally specify a bus frequency via platform data.

The phy identification scheme has been modified to use a phy bus id instead
of a mask.  This largely serves to eliminate the "phy search" code in emac
init.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig          |    1 +
 drivers/net/davinci_emac.c   |   88 ++++++++++++++---------------------------
 include/linux/davinci_emac.h |    1 +
 3 files changed, 32 insertions(+), 58 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c5c86e0..911e7f1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -951,6 +951,7 @@ config NET_NETX
 config TI_DAVINCI_EMAC
 	tristate "TI DaVinci EMAC Support"
 	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	select TI_DAVINCI_MDIO
 	select PHYLIB
 	help
 	  This driver supports TI's DaVinci Ethernet .
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 7fbd052..6ed779d 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -500,6 +500,7 @@ struct emac_priv {
 	u32 phy_mask;
 	/* mii_bus,phy members */
 	struct mii_bus *mii_bus;
+	const char *phy_id;
 	struct phy_device *phydev;
 	spinlock_t lock;
 	/*platform specific members*/
@@ -686,7 +687,7 @@ static int emac_get_settings(struct net_device *ndev,
 			     struct ethtool_cmd *ecmd)
 {
 	struct emac_priv *priv = netdev_priv(ndev);
-	if (priv->phy_mask)
+	if (priv->phydev)
 		return phy_ethtool_gset(priv->phydev, ecmd);
 	else
 		return -EOPNOTSUPP;
@@ -704,7 +705,7 @@ static int emac_get_settings(struct net_device *ndev,
 static int emac_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct emac_priv *priv = netdev_priv(ndev);
-	if (priv->phy_mask)
+	if (priv->phydev)
 		return phy_ethtool_sset(priv->phydev, ecmd);
 	else
 		return -EOPNOTSUPP;
@@ -841,7 +842,7 @@ static void emac_update_phystatus(struct emac_priv *priv)
 	mac_control = emac_read(EMAC_MACCONTROL);
 	cur_duplex = (mac_control & EMAC_MACCONTROL_FULLDUPLEXEN) ?
 			DUPLEX_FULL : DUPLEX_HALF;
-	if (priv->phy_mask)
+	if (priv->phydev)
 		new_duplex = priv->phydev->duplex;
 	else
 		new_duplex = DUPLEX_FULL;
@@ -2485,6 +2486,11 @@ static int emac_devioctl(struct net_device *ndev, struct ifreq *ifrq, int cmd)
 	return -EOPNOTSUPP;
 }
 
+static int match_first_device(struct device *dev, void *data)
+{
+	return 1;
+}
+
 /**
  * emac_dev_open: EMAC device open
  * @ndev: The DaVinci EMAC network adapter
@@ -2499,7 +2505,6 @@ static int emac_dev_open(struct net_device *ndev)
 {
 	struct device *emac_dev = &ndev->dev;
 	u32 rc, cnt, ch;
-	int phy_addr;
 	struct resource *res;
 	int q, m;
 	int i = 0;
@@ -2560,28 +2565,26 @@ static int emac_dev_open(struct net_device *ndev)
 		emac_set_coalesce(ndev, &coal);
 	}
 
-	/* find the first phy */
 	priv->phydev = NULL;
-	if (priv->phy_mask) {
-		emac_mii_reset(priv->mii_bus);
-		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
-			if (priv->mii_bus->phy_map[phy_addr]) {
-				priv->phydev = priv->mii_bus->phy_map[phy_addr];
-				break;
-			}
-		}
+	/* use the first phy on the bus if pdata did not give us a phy id */
+	if (!priv->phy_id) {
+		struct device *phy;
 
-		if (!priv->phydev) {
-			printk(KERN_ERR "%s: no PHY found\n", ndev->name);
-			return -1;
-		}
+		phy = bus_find_device(&mdio_bus_type, NULL, NULL,
+				      match_first_device);
+		if (phy)
+			priv->phy_id = dev_name(phy);
+	}
 
-		priv->phydev = phy_connect(ndev, dev_name(&priv->phydev->dev),
-				&emac_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+	if (priv->phy_id) {
+		priv->phydev = phy_connect(ndev, priv->phy_id,
+					   &emac_adjust_link, 0,
+					   PHY_INTERFACE_MODE_MII);
 
 		if (IS_ERR(priv->phydev)) {
-			printk(KERN_ERR "%s: Could not attach to PHY\n",
-								ndev->name);
+			dev_err(emac_dev, "could not connect to phy %s\n",
+				priv->phy_id);
+			priv->phydev = NULL;
 			return PTR_ERR(priv->phydev);
 		}
 
@@ -2589,12 +2592,13 @@ static int emac_dev_open(struct net_device *ndev)
 		priv->speed = 0;
 		priv->duplex = ~0;
 
-		printk(KERN_INFO "%s: attached PHY driver [%s] "
-			"(mii_bus:phy_addr=%s, id=%x)\n", ndev->name,
+		dev_info(emac_dev, "attached PHY driver [%s] "
+			"(mii_bus:phy_addr=%s, id=%x)\n",
 			priv->phydev->drv->name, dev_name(&priv->phydev->dev),
 			priv->phydev->phy_id);
-	} else{
+	} else {
 		/* No PHY , fix the link, speed and duplex settings */
+		dev_notice(emac_dev, "no phy, defaulting to 100/full\n");
 		priv->link = 1;
 		priv->speed = SPEED_100;
 		priv->duplex = DUPLEX_FULL;
@@ -2607,7 +2611,7 @@ static int emac_dev_open(struct net_device *ndev)
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: Opened %s\n", ndev->name);
 
-	if (priv->phy_mask)
+	if (priv->phydev)
 		phy_start(priv->phydev);
 
 	return 0;
@@ -2794,7 +2798,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	/* MAC addr and PHY mask , RMII enable info from platform_data */
 	memcpy(priv->mac_addr, pdata->mac_addr, 6);
-	priv->phy_mask = pdata->phy_mask;
+	priv->phy_id = pdata->phy_id;
 	priv->rmii_en = pdata->rmii_en;
 	priv->version = pdata->version;
 	priv->int_enable = pdata->interrupt_enable;
@@ -2871,32 +2875,6 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	}
 
 
-	/* MII/Phy intialisation, mdio bus registration */
-	emac_mii = mdiobus_alloc();
-	if (emac_mii == NULL) {
-		dev_err(emac_dev, "DaVinci EMAC: Error allocating mii_bus\n");
-		rc = -ENOMEM;
-		goto mdio_alloc_err;
-	}
-
-	priv->mii_bus = emac_mii;
-	emac_mii->name  = "emac-mii",
-	emac_mii->read  = emac_mii_read,
-	emac_mii->write = emac_mii_write,
-	emac_mii->reset = emac_mii_reset,
-	emac_mii->irq   = mii_irqs,
-	emac_mii->phy_mask = ~(priv->phy_mask);
-	emac_mii->parent = &pdev->dev;
-	emac_mii->priv = priv->remap_addr + pdata->mdio_reg_offset;
-	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%x", priv->pdev->id);
-	mdio_max_freq = pdata->mdio_max_freq;
-	emac_mii->reset(emac_mii);
-
-	/* Register the MII bus */
-	rc = mdiobus_register(emac_mii);
-	if (rc)
-		goto mdiobus_quit;
-
 	if (netif_msg_probe(priv)) {
 		dev_notice(emac_dev, "DaVinci EMAC Probe found device "\
 			   "(regs: %p, irq: %d)\n",
@@ -2904,11 +2882,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	}
 	return 0;
 
-mdiobus_quit:
-	mdiobus_free(emac_mii);
-
 netdev_reg_err:
-mdio_alloc_err:
 	clk_disable(emac_clk);
 no_irq_res:
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2938,8 +2912,6 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	mdiobus_unregister(priv->mii_bus);
-	mdiobus_free(priv->mii_bus);
 
 	release_mem_region(res->start, res->end - res->start + 1);
 
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index a04fd8c..6bcd247 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -28,6 +28,7 @@ struct emac_platform_data {
 	u32 ctrl_ram_size;
 	u32 phy_mask;
 	u32 mdio_max_freq;
+	const char *phy_id;
 	u8 rmii_en;
 	u8 version;
 	void (*interrupt_enable) (void);
-- 
1.7.0.4

