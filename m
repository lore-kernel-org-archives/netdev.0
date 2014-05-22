From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net] libphy: Add phy specific function to access mmd phy registers
Date: Thu, 22 May 2014 17:23:53 -0500
Message-ID: <1400797433-15256-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:51488 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbaEVW2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 18:28:08 -0400
Received: by mail-ob0-f177.google.com with SMTP id wp4so4435300obc.22
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 15:28:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libphy was originally written assuming all phy devices support clause 45
access extensions to the mmd registers through the indirection registers
located within the first 16 phy registers. This assumption is not true
in all cases, and one specific example is the Micrel ksz9021 10/100/1000
Mbps phy. Using the stmmac driver, accessing the mmd registers to query
and configure energy efficient Ethernet (EEE) features yielded unexpected
behavior.

This patch adds mmd access functions to the phy driver that can be
overriden by the phy specific driver if the phy does not support this
mechanism or uses it's own non-standard access mechanism. By default,
the IEEE Compatible clause 45 access mechanism described in clause 22
is used. With this patch, EEE query/configure functions as expected
using the stmmac and the Micrel ksz9021 phy.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/phy/micrel.c     |   15 +++++++++++++
 drivers/net/phy/phy.c        |   49 ++++++++++++++++++++++--------------------
 drivers/net/phy/phy_device.c |    6 ++++++
 include/linux/phy.h          |   10 +++++++++
 4 files changed, 57 insertions(+), 23 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index d849684..095d614 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -315,6 +315,19 @@ static int ksz8873mll_config_aneg(struct phy_device *phydev)
 {
 	return 0;
 }
+static int
+ksz9021_rd_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
+		      int regnum)
+{
+	return -1;
+}
+
+static void
+ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
+		      int regnum, u32 val)
+{
+	return;
+}
 
 static struct phy_driver ksphy_driver[] = {
 {
@@ -461,6 +474,8 @@ static struct phy_driver ksphy_driver[] = {
 	.config_intr	= ksz9021_config_intr,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
+	.rd_mmd_indirect = ksz9021_rd_mmd_phyreg,
+	.wr_mmd_indirect = ksz9021_wr_mmd_phyreg,
 	.driver		= { .owner = THIS_MODULE, },
 }, {
 	.phy_id		= PHY_ID_KSZ9031,
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3bc079a..fa649ac 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -932,13 +932,13 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
  * 3) Write reg 13 // MMD Data Command for MMD DEVAD
  * 3) Read  reg 14 // Read MMD data
  */
-static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
-				 int addr)
+int gen_rd_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
+			int addr)
 {
-	mmd_phy_indirect(bus, prtad, devad, addr);
+	mmd_phy_indirect(phydev->bus, prtad, devad, addr);
 
 	/* Read the content of the MMD's selected register */
-	return bus->read(bus, addr, MII_MMD_DATA);
+	return phydev->bus->read(phydev->bus, addr, MII_MMD_DATA);
 }
 
 /**
@@ -957,15 +957,14 @@ static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
  * 3) Write reg 13 // MMD Data Command for MMD DEVAD
  * 3) Write reg 14 // Write MMD data
  */
-static void phy_write_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
-				   int addr, u32 data)
+void gen_wr_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
+			 int addr, u32 data)
 {
-	mmd_phy_indirect(bus, prtad, devad, addr);
+	mmd_phy_indirect(phydev->bus, prtad, devad, addr);
 
 	/* Write the data into MMD's selected register */
-	bus->write(bus, addr, MII_MMD_DATA, data);
+	phydev->bus->write(phydev->bus, addr, MII_MMD_DATA, data);
 }
-
 /**
  * phy_init_eee - init and check the EEE feature
  * @phydev: target phy_device struct
@@ -978,6 +977,8 @@ static void phy_write_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
  */
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 {
+	struct phy_driver *phydrv = phydev ? phydev->drv : NULL;
+
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
 	 * Also EEE feature is active when core is operating with MII, GMII
 	 * or RGMII.
@@ -997,8 +998,9 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			return status;
 
 		/* First check if the EEE ability is supported */
-		eee_cap = phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
-						MDIO_MMD_PCS, phydev->addr);
+		eee_cap = phydrv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
+						  MDIO_MMD_PCS, phydev->addr);
+
 		if (eee_cap < 0)
 			return eee_cap;
 
@@ -1009,13 +1011,13 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		/* Check which link settings negotiated and verify it in
 		 * the EEE advertising registers.
 		 */
-		eee_lp = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
-					       MDIO_MMD_AN, phydev->addr);
+		eee_lp = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
+						 MDIO_MMD_AN, phydev->addr);
 		if (eee_lp < 0)
 			return eee_lp;
 
-		eee_adv = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV,
-						MDIO_MMD_AN, phydev->addr);
+		eee_adv = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
+						  MDIO_MMD_AN, phydev->addr);
 		if (eee_adv < 0)
 			return eee_adv;
 
@@ -1029,14 +1031,14 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			/* Configure the PHY to stop receiving xMII
 			 * clock while it is signaling LPI.
 			 */
-			int val = phy_read_mmd_indirect(phydev->bus, MDIO_CTRL1,
+			int val = phydrv->rd_mmd_indirect(phydev, MDIO_CTRL1,
 							MDIO_MMD_PCS,
 							phydev->addr);
 			if (val < 0)
 				return val;
 
 			val |= MDIO_PCS_CTRL1_CLKSTOP_EN;
-			phy_write_mmd_indirect(phydev->bus, MDIO_CTRL1,
+			phydrv->wr_mmd_indirect(phydev, MDIO_CTRL1,
 					       MDIO_MMD_PCS, phydev->addr, val);
 		}
 
@@ -1056,7 +1058,7 @@ EXPORT_SYMBOL(phy_init_eee);
  */
 int phy_get_eee_err(struct phy_device *phydev)
 {
-	return phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_WK_ERR,
+	return phydev->drv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR,
 				     MDIO_MMD_PCS, phydev->addr);
 }
 EXPORT_SYMBOL(phy_get_eee_err);
@@ -1072,23 +1074,24 @@ EXPORT_SYMBOL(phy_get_eee_err);
 int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val;
+	struct phy_driver *phydrv = phydev->drv;
 
 	/* Get Supported EEE */
-	val = phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
-				    MDIO_MMD_PCS, phydev->addr);
+	val = phydrv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
+				      MDIO_MMD_PCS, phydev->addr);
 	if (val < 0)
 		return val;
 	data->supported = mmd_eee_cap_to_ethtool_sup_t(val);
 
 	/* Get advertisement EEE */
-	val = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV,
+	val = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
 				    MDIO_MMD_AN, phydev->addr);
 	if (val < 0)
 		return val;
 	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
 
 	/* Get LP advertisement EEE */
-	val = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
+	val = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
 				    MDIO_MMD_AN, phydev->addr);
 	if (val < 0)
 		return val;
@@ -1109,7 +1112,7 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
 
-	phy_write_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
+	phydev->drv->wr_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
 			       phydev->addr, val);
 
 	return 0;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 4987a1c..ff26b5f 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1243,6 +1243,12 @@ int phy_driver_register(struct phy_driver *new_driver)
 	new_driver->driver.probe = phy_probe;
 	new_driver->driver.remove = phy_remove;
 
+	if (!new_driver->rd_mmd_indirect)
+		new_driver->rd_mmd_indirect = gen_rd_mmd_indirect;
+
+	if (!new_driver->wr_mmd_indirect)
+		new_driver->wr_mmd_indirect = gen_wr_mmd_indirect;
+
 	retval = driver_register(&new_driver->driver);
 	if (retval) {
 		pr_err("%s: Error %d in registering driver\n",
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 4d0221f..ee4480e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -529,6 +529,12 @@ struct phy_driver {
 	/* See set_wol, but for checking whether Wake on LAN is enabled. */
 	void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
 
+	int (*rd_mmd_indirect)(struct phy_device *dev, int ptrad, int devnum,
+			       int regnum);
+
+	void (*wr_mmd_indirect)(struct phy_device *dev, int ptrad, int devnum,
+				int regnum, u32 val);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
@@ -706,6 +712,10 @@ int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 void phy_ethtool_get_wol(struct phy_device *phydev,
 			 struct ethtool_wolinfo *wol);
 
+int gen_rd_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
+			int addr);
+void gen_wr_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
+			 int addr, u32 data);
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
-- 
1.7.9.5
