From: Victor Gallardo <vgallardo@amcc.com>
Subject: [PATCH] ibm_newemac: Add support for GPCS, SGMII and M88E1112 PHY
Date: Fri,  5 Sep 2008 16:55:26 -0700
Message-ID: <1220658926-14014-1-git-send-email-vgallardo@amcc.com>
Cc: netdev@vger.kernel.org, Victor Gallardo <vgallardo@amcc.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sdcmail02.amcc.com ([198.137.200.73]:44543 "EHLO
	sdcmail02.amcc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbYIEXzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 19:55:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GPCS, SGMII and M88E1112 PHY support
for the AMCC PPC460GT/EX processors.

Signed-off-by: Victor Gallardo <vgallardo@amcc.com>
---
 drivers/net/ibm_newemac/core.c |   40 +++++++++++++++----
 drivers/net/ibm_newemac/core.h |    3 +
 drivers/net/ibm_newemac/phy.c  |   84 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/ibm_newemac/phy.h  |    2 +
 4 files changed, 120 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 2e720f2..cef76fe 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -201,13 +201,15 @@ static inline int emac_phy_supports_gige(int phy_mode)
 {
 	return  phy_mode == PHY_MODE_GMII ||
 		phy_mode == PHY_MODE_RGMII ||
+		phy_mode == PHY_MODE_SGMII ||
 		phy_mode == PHY_MODE_TBI ||
 		phy_mode == PHY_MODE_RTBI;
 }
 
 static inline int emac_phy_gpcs(int phy_mode)
 {
-	return  phy_mode == PHY_MODE_TBI ||
+	return  phy_mode == PHY_MODE_SGMII ||
+		phy_mode == PHY_MODE_TBI ||
 		phy_mode == PHY_MODE_RTBI;
 }
 
@@ -547,8 +549,9 @@ static int emac_configure(struct emac_instance *dev)
 	switch (dev->phy.speed) {
 	case SPEED_1000:
 		if (emac_phy_gpcs(dev->phy.mode)) {
-			mr1 |= EMAC_MR1_MF_1000GPCS |
-				EMAC_MR1_MF_IPPA(dev->phy.address);
+			mr1 |= EMAC_MR1_MF_1000GPCS | EMAC_MR1_MF_IPPA(
+				(dev->phy.gpcs_address != 0xffffffff) ?
+				 dev->phy.gpcs_address : dev->phy.address);
 
 			/* Put some arbitrary OUI, Manuf & Rev IDs so we can
 			 * identify this GPCS PHY later.
@@ -660,8 +663,12 @@ static int emac_configure(struct emac_instance *dev)
 	out_be32(&p->iser,  r);
 
 	/* We need to take GPCS PHY out of isolate mode after EMAC reset */
-	if (emac_phy_gpcs(dev->phy.mode))
-		emac_mii_reset_phy(&dev->phy);
+	if (emac_phy_gpcs(dev->phy.mode)) {
+		if (dev->phy.gpcs_address != 0xffffffff)
+			emac_mii_reset_gpcs(&dev->phy);
+		else
+			emac_mii_reset_phy(&dev->phy);
+	}
 
 	/* Required for Pause packet support in EMAC */
 	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
@@ -869,7 +876,9 @@ static int emac_mdio_read(struct net_device *ndev, int id, int reg)
 	struct emac_instance *dev = netdev_priv(ndev);
 	int res;
 
-	res = __emac_mdio_read(dev->mdio_instance ? dev->mdio_instance : dev,
+	res = __emac_mdio_read((dev->mdio_instance &&
+				dev->phy.gpcs_address != id) ?
+				dev->mdio_instance : dev,
 			       (u8) id, (u8) reg);
 	return res;
 }
@@ -878,7 +887,9 @@ static void emac_mdio_write(struct net_device *ndev, int id, int reg, int val)
 {
 	struct emac_instance *dev = netdev_priv(ndev);
 
-	__emac_mdio_write(dev->mdio_instance ? dev->mdio_instance : dev,
+	__emac_mdio_write((dev->mdio_instance &&
+			   dev->phy.gpcs_address != id) ?
+			   dev->mdio_instance : dev,
 			  (u8) id, (u8) reg, (u16) val);
 }
 
@@ -2367,7 +2378,11 @@ static int __devinit emac_init_phy(struct emac_instance *dev)
 		 * XXX I probably should move these settings to the dev tree
 		 */
 		dev->phy.address = -1;
-		dev->phy.features = SUPPORTED_100baseT_Full | SUPPORTED_MII;
+		dev->phy.features = SUPPORTED_MII;
+		if (emac_phy_supports_gige(dev->phy_mode))
+			dev->phy.features |= SUPPORTED_1000baseT_Full;
+		else
+			dev->phy.features |= SUPPORTED_100baseT_Full;
 		dev->phy.pause = 1;
 
 		return 0;
@@ -2406,7 +2421,9 @@ static int __devinit emac_init_phy(struct emac_instance *dev)
 		 * Note that the busy_phy_map is currently global
 		 * while it should probably be per-ASIC...
 		 */
-		dev->phy.address = dev->cell_index;
+		dev->phy.gpcs_address = dev->gpcs_address;
+		if (dev->phy.gpcs_address == 0xffffffff)
+			dev->phy.address = dev->cell_index;
 	}
 
 	emac_configure(dev);
@@ -2516,6 +2533,8 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		dev->phy_address = 0xffffffff;
 	if (emac_read_uint_prop(np, "phy-map", &dev->phy_map, 0))
 		dev->phy_map = 0xffffffff;
+	if (emac_read_uint_prop(np, "gpcs-address", &dev->gpcs_address, 0))
+		dev->gpcs_address = 0xffffffff;
 	if (emac_read_uint_prop(np->parent, "clock-frequency", &dev->opb_bus_freq, 1))
 		return -ENXIO;
 	if (emac_read_uint_prop(np, "tah-device", &dev->tah_ph, 0))
@@ -2824,6 +2843,9 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	       ndev->dev_addr[0], ndev->dev_addr[1], ndev->dev_addr[2],
 	       ndev->dev_addr[3], ndev->dev_addr[4], ndev->dev_addr[5]);
 
+	if (dev->phy_mode == PHY_MODE_SGMII)
+		printk(KERN_NOTICE "%s: in SGMII mode\n", ndev->name);
+
 	if (dev->phy.address >= 0)
 		printk("%s: found %s PHY (0x%02x)\n", ndev->name,
 		       dev->phy.def->name, dev->phy.address);
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 6545e69..7312eac 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -190,6 +190,9 @@ struct emac_instance {
 	struct delayed_work		link_work;
 	int				link_polling;
 
+	/* GPCS PHY infos */
+	u32				gpcs_address;
+
 	/* Shared MDIO if any */
 	u32				mdio_ph;
 	struct of_device		*mdio_dev;
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index 37bfeea..606db53 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -38,6 +38,16 @@ static inline void phy_write(struct mii_phy *phy, int reg, int val)
 	phy->mdio_write(phy->dev, phy->address, reg, val);
 }
 
+static inline int gpcs_phy_read(struct mii_phy *phy, int reg)
+{
+	return phy->mdio_read(phy->dev, phy->gpcs_address, reg);
+}
+
+static inline void gpcs_phy_write(struct mii_phy *phy, int reg, int val)
+{
+	phy->mdio_write(phy->dev, phy->gpcs_address, reg, val);
+}
+
 int emac_mii_reset_phy(struct mii_phy *phy)
 {
 	int val;
@@ -62,6 +72,37 @@ int emac_mii_reset_phy(struct mii_phy *phy)
 	return limit <= 0;
 }
 
+int emac_mii_reset_gpcs(struct mii_phy *phy)
+{
+	int val;
+	int limit = 10000;
+
+	val = gpcs_phy_read(phy, MII_BMCR);
+	val &= ~(BMCR_ISOLATE | BMCR_ANENABLE);
+	val |= BMCR_RESET;
+	gpcs_phy_write(phy, MII_BMCR, val);
+
+	udelay(300);
+
+	while (limit--) {
+		val = gpcs_phy_read(phy, MII_BMCR);
+		if (val >= 0 && (val & BMCR_RESET) == 0)
+			break;
+		udelay(10);
+	}
+	if ((val & BMCR_ISOLATE) && limit > 0)
+		gpcs_phy_write(phy, MII_BMCR, val & ~BMCR_ISOLATE);
+
+	if (limit > 0 && phy->mode == PHY_MODE_SGMII) {
+		/* Configure GPCS interface to recommended setting for SGMII */
+		gpcs_phy_write(phy, 0x04, 0x8120); /* AsymPause, FDX */
+		gpcs_phy_write(phy, 0x07, 0x2801); /* msg_pg, toggle */
+		gpcs_phy_write(phy, 0x00, 0x0140); /* 1Gbps, FDX     */
+	}
+
+	return limit <= 0;
+}
+
 static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	int ctl, adv;
@@ -332,6 +373,33 @@ static int m88e1111_init(struct mii_phy *phy)
 	return  0;
 }
 
+static int m88e1112_init(struct mii_phy *phy)
+{
+	/*
+	 * Marvell 88E1112 PHY needs to have the SGMII MAC
+	 * interace (page 2) properly configured to
+	 * communicate with the 460EX/GT GPCS interface.
+	 */
+
+	u16 reg_short;
+
+	pr_debug("%s: Marvell 88E1112 Ethernet\n", __func__);
+
+	/* Set access to Page 2 */
+	phy_write(phy, 0x16, 0x0002);
+
+	phy_write(phy, 0x00, 0x0040); /* 1Gbps */
+	reg_short = (u16)(phy_read(phy, 0x1a));
+	reg_short |= 0x8000; /* bypass Auto-Negotiation */
+	phy_write(phy, 0x1a, reg_short);
+	emac_mii_reset_phy(phy); /* reset MAC interface */
+
+	/* Reset access to Page 0 */
+	phy_write(phy, 0x16, 0x0000);
+
+	return  0;
+}
+
 static int et1011c_init(struct mii_phy *phy)
 {
 	u16 reg_short;
@@ -384,11 +452,27 @@ static struct mii_phy_def m88e1111_phy_def = {
 	.ops		= &m88e1111_phy_ops,
 };
 
+static struct mii_phy_ops m88e1112_phy_ops = {
+	.init		= m88e1112_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link
+};
+
+static struct mii_phy_def m88e1112_phy_def = {
+	.phy_id		= 0x01410C90,
+	.phy_id_mask	= 0x0ffffff0,
+	.name		= "Marvell 88E1112 Ethernet",
+	.ops		= &m88e1112_phy_ops,
+};
+
 static struct mii_phy_def *mii_phy_table[] = {
 	&et1011c_phy_def,
 	&cis8201_phy_def,
 	&bcm5248_phy_def,
 	&m88e1111_phy_def,
+	&m88e1112_phy_def,
 	&genmii_phy_def,
 	NULL
 };
diff --git a/drivers/net/ibm_newemac/phy.h b/drivers/net/ibm_newemac/phy.h
index 1b65c81..5d2bf4c 100644
--- a/drivers/net/ibm_newemac/phy.h
+++ b/drivers/net/ibm_newemac/phy.h
@@ -57,6 +57,7 @@ struct mii_phy {
 				   or determined automaticaly */
 	int address;		/* PHY address */
 	int mode;		/* PHY mode */
+	int gpcs_address;	/* GPCS PHY address */
 
 	/* 1: autoneg enabled, 0: disabled */
 	int autoneg;
@@ -81,5 +82,6 @@ struct mii_phy {
  */
 int emac_mii_phy_probe(struct mii_phy *phy, int address);
 int emac_mii_reset_phy(struct mii_phy *phy);
+int emac_mii_reset_gpcs(struct mii_phy *phy);
 
 #endif /* __IBM_NEWEMAC_PHY_H */
-- 
1.5.5

