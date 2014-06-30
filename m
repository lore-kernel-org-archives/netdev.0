From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v4 1/3] net: libphy: Add phy specific function to access mmd phy registers
Date: Sun, 29 Jun 2014 20:35:22 -0500
Message-ID: <1404092124-18704-2-git-send-email-vbridgers2013@gmail.com>
References: <1404092124-18704-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: f.fainelli@gmail.com, rdunlap@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34009 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886AbaF3BjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:39:17 -0400
Received: by mail-ob0-f178.google.com with SMTP id wn1so8169045obc.9
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 18:39:17 -0700 (PDT)
In-Reply-To: <1404092124-18704-1-git-send-email-vbridgers2013@gmail.com>
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
V4: None
V3: Align function arguments that I missed per review comments
V2: Split libphy and Micrel specific changes based on review comments
---
 drivers/net/phy/phy.c        |   73 +++++++++++++++++++++++-------------------
 drivers/net/phy/phy_device.c |    6 ++++
 include/linux/phy.h          |   23 +++++++++++++
 3 files changed, 69 insertions(+), 33 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f7c6181..d738376 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -921,8 +921,8 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
 }
 
 /**
- * phy_read_mmd_indirect - reads data from the MMD registers
- * @bus: the target MII bus
+ * gen_rd_mmd_indirect - reads data from the MMD registers
+ * @phydev: The PHY device bus
  * @prtad: MMD Address
  * @devad: MMD DEVAD
  * @addr: PHY address on the MII bus
@@ -935,18 +935,18 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
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
- * phy_write_mmd_indirect - writes data to the MMD registers
- * @bus: the target MII bus
+ * gen_wr_mmd_indirect - writes data to the MMD registers
+ * @phydev: The PHY device
  * @prtad: MMD Address
  * @devad: MMD DEVAD
  * @addr: PHY address on the MII bus
@@ -960,13 +960,13 @@ static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
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
 
 /**
@@ -981,6 +981,8 @@ static void phy_write_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
  */
 int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 {
+	struct phy_driver *phydrv = phydev ? phydev->drv : NULL;
+
 	/* According to 802.3az,the EEE is supported only in full duplex-mode.
 	 * Also EEE feature is active when core is operating with MII, GMII
 	 * or RGMII.
@@ -1000,8 +1002,8 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			return status;
 
 		/* First check if the EEE ability is supported */
-		eee_cap = phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
-						MDIO_MMD_PCS, phydev->addr);
+		eee_cap = phydrv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
+						  MDIO_MMD_PCS, phydev->addr);
 		if (eee_cap < 0)
 			return eee_cap;
 
@@ -1012,13 +1014,13 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
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
 
@@ -1032,15 +1034,16 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			/* Configure the PHY to stop receiving xMII
 			 * clock while it is signaling LPI.
 			 */
-			int val = phy_read_mmd_indirect(phydev->bus, MDIO_CTRL1,
-							MDIO_MMD_PCS,
-							phydev->addr);
+			int val = phydrv->rd_mmd_indirect(phydev, MDIO_CTRL1,
+							  MDIO_MMD_PCS,
+							  phydev->addr);
 			if (val < 0)
 				return val;
 
 			val |= MDIO_PCS_CTRL1_CLKSTOP_EN;
-			phy_write_mmd_indirect(phydev->bus, MDIO_CTRL1,
-					       MDIO_MMD_PCS, phydev->addr, val);
+			phydrv->wr_mmd_indirect(phydev, MDIO_CTRL1,
+						MDIO_MMD_PCS, phydev->addr,
+						val);
 		}
 
 		return 0; /* EEE supported */
@@ -1059,8 +1062,10 @@ EXPORT_SYMBOL(phy_init_eee);
  */
 int phy_get_eee_err(struct phy_device *phydev)
 {
-	return phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_WK_ERR,
-				     MDIO_MMD_PCS, phydev->addr);
+	struct phy_driver *phydrv = phydev->drv;
+
+	return phydrv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR,
+				       MDIO_MMD_PCS, phydev->addr);
 }
 EXPORT_SYMBOL(phy_get_eee_err);
 
@@ -1075,24 +1080,25 @@ EXPORT_SYMBOL(phy_get_eee_err);
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
-				    MDIO_MMD_AN, phydev->addr);
+	val = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
+				      MDIO_MMD_AN, phydev->addr);
 	if (val < 0)
 		return val;
 	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
 
 	/* Get LP advertisement EEE */
-	val = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
-				    MDIO_MMD_AN, phydev->addr);
+	val = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
+				      MDIO_MMD_AN, phydev->addr);
 	if (val < 0)
 		return val;
 	data->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(val);
@@ -1111,9 +1117,10 @@ EXPORT_SYMBOL(phy_ethtool_get_eee);
 int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
+	struct phy_driver *phydrv = phydev->drv;
 
-	phy_write_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
-			       phydev->addr, val);
+	phydrv->wr_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
+				phydev->addr, val);
 
 	return 0;
 }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 35d753d..a604bd7 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1275,6 +1275,12 @@ int phy_driver_register(struct phy_driver *new_driver)
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
index 6804144..5b04004 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -545,6 +545,24 @@ struct phy_driver {
 	 */
 	void (*link_change_notify)(struct phy_device *dev);
 
+	/* A function provided by a phy specific driver to override the
+	 * the PHY driver framework support for reading a MMD register
+	 * from the PHY. If not supported, return -1. This function is
+	 * optional for PHY specific drivers, if not provided then the
+	 * default MMD read function is used by the PHY framework.
+	 */
+	int (*rd_mmd_indirect)(struct phy_device *dev, int ptrad, int devnum,
+			       int regnum);
+
+	/* A function provided by a phy specific driver to override the
+	 * the PHY driver framework support for writing a MMD register
+	 * from the PHY. This function is optional for PHY specific drivers,
+	 * if not provided then the default MMD read function is used by
+	 * the PHY framework.
+	 */
+	void (*wr_mmd_indirect)(struct phy_device *dev, int ptrad, int devnum,
+				int regnum, u32 val);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
@@ -723,6 +741,11 @@ int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 void phy_ethtool_get_wol(struct phy_device *phydev,
 			 struct ethtool_wolinfo *wol);
 
+int gen_rd_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
+			int addr);
+void gen_wr_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
+			 int addr, u32 data);
+
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
-- 
1.7.9.5
