From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
Date: Thu, 10 Apr 2008 18:34:31 -0500
Message-ID: <1207870471-3601-1-git-send-email-afleming@freescale.com>
Cc: paul.gortmaker@windriver.com, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47124 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754605AbYDJXeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 19:34:36 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m3ANYXPW001421
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 16:34:34 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id m3ANYWFX018950
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 18:34:32 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TBIPA needs to be set to a value (on connected MDIO buses) that doesn't
conflict with PHYs on the bus.  By hardcoding it to 0x1f, we were preventing
boards with PHYs at 0x1f from working properly.  Instead, scan the bus when
it comes up, and find an address that doesn't have a PHY on it.  The TBI PHY
configuration code then trusts that the value in TBIPA is either safe, or
doesn't matter (ie - it's not an active bus with other PHYs).

Signed-off-by: Andy Fleming <afleming@freescale.com>
---

I think this should go in, but I'd like to see some testing first.  I don't
have hardware which is affected by this.  I've only confirmed that it doesn't
break current hardware.

 drivers/net/gianfar.c     |   25 +++++++++++++----------
 drivers/net/gianfar_mii.c |   47 ++++++++++++++++++++++++++++++++++++++++----
 drivers/net/gianfar_mii.h |    3 ++
 3 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c8c3df7..6661015 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -476,24 +476,30 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
+/*
+ * Initialize TBI PHY interface for communicating with the
+ * SERDES lynx PHY on the chip.  We communicate with this PHY
+ * through the MDIO bus on each controller, treating it as a
+ * "normal" PHY at the address found in the TBIPA register.  We assume
+ * that the TBIPA register is valid.  Either the MDIO bus code will set
+ * it to a value that doesn't conflict with other PHYs on the bus, or the
+ * value doesn't matter, as there are no other PHYs on the bus.
+ */
 static void gfar_configure_serdes(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar_mii __iomem *regs =
 			(void __iomem *)&priv->regs->gfar_mii_regs;
+	int tbipa = gfar_read(&priv->regs->tbipa);
 
-	/* Initialise TBI i/f to communicate with serdes (lynx phy) */
+	/* Single clk mode, mii mode off(for serdes communication) */
+	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
 
-	/* Single clk mode, mii mode off(for aerdes communication) */
-	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_TBICON, TBICON_CLK_SELECT);
-
-	/* Supported pause and full-duplex, no half-duplex */
-	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_ADVERTISE,
+	gfar_local_mdio_write(regs, tbipa, MII_ADVERTISE,
 			ADVERTISE_1000XFULL | ADVERTISE_1000XPAUSE |
 			ADVERTISE_1000XPSE_ASYM);
 
-	/* ANEG enable, restart ANEG, full duplex mode, speed[1] set */
-	gfar_local_mdio_write(regs, TBIPA_VALUE, MII_BMCR, BMCR_ANENABLE |
+	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
 }
 
@@ -540,9 +546,6 @@ static void init_registers(struct net_device *dev)
 
 	/* Initialize the Minimum Frame Length Register */
 	gfar_write(&priv->regs->minflr, MINFLR_INIT_SETTINGS);
-
-	/* Assign the TBI an address which won't conflict with the PHYs */
-	gfar_write(&priv->regs->tbipa, TBIPA_VALUE);
 }
 
 
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index b889892..e061738 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -78,7 +78,6 @@ int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
 int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum)
-
 {
 	u16 value;
 
@@ -122,7 +121,7 @@ int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 }
 
 /* Reset the MIIM registers, and wait for the bus to free */
-int gfar_mdio_reset(struct mii_bus *bus)
+static int gfar_mdio_reset(struct mii_bus *bus)
 {
 	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
@@ -152,14 +151,15 @@ int gfar_mdio_reset(struct mii_bus *bus)
 }
 
 
-int gfar_mdio_probe(struct device *dev)
+static int gfar_mdio_probe(struct device *dev)
 {
 	struct platform_device *pdev = to_platform_device(dev);
 	struct gianfar_mdio_data *pdata;
 	struct gfar_mii __iomem *regs;
+	struct gfar __iomem *enet_regs;
 	struct mii_bus *new_bus;
 	struct resource *r;
-	int err = 0;
+	int i, err = 0;
 
 	if (NULL == dev)
 		return -EINVAL;
@@ -199,6 +199,43 @@ int gfar_mdio_probe(struct device *dev)
 	new_bus->dev = dev;
 	dev_set_drvdata(dev, new_bus);
 
+	/*
+	 * This is mildly evil, but so is our hardware for doing this.
+	 * Also, we have to cast back to struct gfar_mii because of
+	 * definition weirdness done in gianfar.h.
+	 */
+	enet_regs = (struct gfar __iomem *)
+		((char *)regs - offsetof(struct gfar, gfar_mii_regs));
+
+	/* Scan the bus, looking for an empty spot for TBIPA */
+	gfar_write(&enet_regs->tbipa, 0);
+	for (i = PHY_MAX_ADDR; i > 0; i--) {
+		int physid1;
+		int physid2;
+		u32 phy_id;
+
+		physid1 = gfar_mdio_read(new_bus, i, MII_PHYSID1);
+
+		if (physid1 < 0)
+			return physid1;
+
+		physid2 = gfar_mdio_read(new_bus, i, MII_PHYSID2);
+
+		if (physid2 < 0)
+			return physid2;
+
+		phy_id = ((physid1 & 0xffff) << 16) | (physid2 & 0xffff);
+
+		if (phy_id == 0xffffffff)
+			break;
+	}
+
+	/* The bus is full.  We don't support using 31 PHYs, sorry */
+	if (i < 0)
+		return -EBUSY;
+
+	gfar_write(&enet_regs->tbipa, i);
+
 	err = mdiobus_register(new_bus);
 
 	if (0 != err) {
@@ -218,7 +255,7 @@ reg_map_fail:
 }
 
 
-int gfar_mdio_remove(struct device *dev)
+static int gfar_mdio_remove(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
 
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index b373091..2af28b1 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -41,6 +41,9 @@ struct gfar_mii {
 
 int gfar_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
+			  int regnum, u16 value);
+int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 int __init gfar_mdio_init(void);
 void gfar_mdio_exit(void);
 #endif /* GIANFAR_PHY_H */
-- 
1.5.4.GIT

