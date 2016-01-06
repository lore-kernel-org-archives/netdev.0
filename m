From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 07/22] phy: phy_{read|write}_mmd_indirect: get addr from phydev
Date: Wed,  6 Jan 2016 20:11:12 +0100
Message-ID: <1452107487-475-8-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42401 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbcAFTOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:14:36 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The address of the device can be determined from the phydev structure,
rather than passing it as a parameter.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm-phy-lib.c |  8 ++++----
 drivers/net/phy/dp83867.c     |  6 +++---
 drivers/net/phy/microchip.c   |  5 ++---
 drivers/net/phy/phy.c         | 36 ++++++++++++++----------------------
 include/linux/phy.h           |  7 ++-----
 5 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index ddb377e53633..df0416db0b88 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -184,25 +184,25 @@ int bcm_phy_enable_eee(struct phy_device *phydev)
 
 	/* Enable EEE at PHY level */
 	val = phy_read_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
-				    MDIO_MMD_AN, phydev->addr);
+				    MDIO_MMD_AN);
 	if (val < 0)
 		return val;
 
 	val |= LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X;
 
 	phy_write_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
-			       MDIO_MMD_AN,  phydev->addr, (u32)val);
+			       MDIO_MMD_AN, (u32)val);
 
 	/* Advertise EEE */
 	val = phy_read_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
-				    MDIO_MMD_AN, phydev->addr);
+				    MDIO_MMD_AN);
 	if (val < 0)
 		return val;
 
 	val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
 
 	phy_write_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
-			       MDIO_MMD_AN,  phydev->addr, (u32)val);
+			       MDIO_MMD_AN, (u32)val);
 
 	return 0;
 }
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 4ebf601073d9..e4c0b0c0af02 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -160,7 +160,7 @@ static int dp83867_config_init(struct phy_device *phydev)
 	if ((phydev->interface >= PHY_INTERFACE_MODE_RGMII_ID) &&
 	    (phydev->interface <= PHY_INTERFACE_MODE_RGMII_RXID)) {
 		val = phy_read_mmd_indirect(phydev, DP83867_RGMIICTL,
-					    DP83867_DEVADDR, phydev->addr);
+					    DP83867_DEVADDR);
 
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
 			val |= (DP83867_RGMII_TX_CLK_DELAY_EN | DP83867_RGMII_RX_CLK_DELAY_EN);
@@ -172,13 +172,13 @@ static int dp83867_config_init(struct phy_device *phydev)
 			val |= DP83867_RGMII_RX_CLK_DELAY_EN;
 
 		phy_write_mmd_indirect(phydev, DP83867_RGMIICTL,
-				       DP83867_DEVADDR, phydev->addr, val);
+				       DP83867_DEVADDR, val);
 
 		delay = (dp83867->rx_id_delay |
 			(dp83867->tx_id_delay << DP83867_RGMII_TX_CLK_DELAY_SHIFT));
 
 		phy_write_mmd_indirect(phydev, DP83867_RGMIIDCTL,
-				       DP83867_DEVADDR, phydev->addr, delay);
+				       DP83867_DEVADDR, delay);
 	}
 
 	return 0;
diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index c0a20ebd083b..99df5bc47424 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -78,10 +78,9 @@ static int lan88xx_probe(struct phy_device *phydev)
 	priv->wolopts = 0;
 
 	/* these values can be used to identify internal PHY */
-	priv->chip_id = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_ID,
-					      3, phydev->addr);
+	priv->chip_id = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_ID, 3);
 	priv->chip_rev = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_REV,
-					       3, phydev->addr);
+					       3);
 
 	phydev->priv = priv;
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 9771941cf0ee..56c8dd8c0c85 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1029,7 +1029,6 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
  * @phydev: The PHY device bus
  * @prtad: MMD Address
  * @devad: MMD DEVAD
- * @addr: PHY address on the MII bus
  *
  * Description: it reads data from the MMD registers (clause 22 to access to
  * clause 45) of the specified phy address.
@@ -1039,10 +1038,10 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
  * 3) Write reg 13 // MMD Data Command for MMD DEVAD
  * 3) Read  reg 14 // Read MMD data
  */
-int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
-				 int devad, int addr)
+int phy_read_mmd_indirect(struct phy_device *phydev, int prtad, int devad)
 {
 	struct phy_driver *phydrv = phydev->drv;
+	int addr = phydev->addr;
 	int value = -1;
 
 	if (!phydrv->read_mmd_indirect) {
@@ -1066,7 +1065,6 @@ EXPORT_SYMBOL(phy_read_mmd_indirect);
  * @phydev: The PHY device
  * @prtad: MMD Address
  * @devad: MMD DEVAD
- * @addr: PHY address on the MII bus
  * @data: data to write in the MMD register
  *
  * Description: Write data from the MMD registers of the specified
@@ -1078,9 +1076,10 @@ EXPORT_SYMBOL(phy_read_mmd_indirect);
  * 3) Write reg 14 // Write MMD data
  */
 void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
-				   int devad, int addr, u32 data)
+				   int devad, u32 data)
 {
 	struct phy_driver *phydrv = phydev->drv;
+	int addr = phydev->addr;
 
 	if (!phydrv->write_mmd_indirect) {
 		struct mii_bus *bus = phydev->bus;
@@ -1130,7 +1129,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 
 		/* First check if the EEE ability is supported */
 		eee_cap = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
-						MDIO_MMD_PCS, phydev->addr);
+						MDIO_MMD_PCS);
 		if (eee_cap <= 0)
 			goto eee_exit_err;
 
@@ -1142,12 +1141,12 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		 * the EEE advertising registers.
 		 */
 		eee_lp = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
-					       MDIO_MMD_AN, phydev->addr);
+					       MDIO_MMD_AN);
 		if (eee_lp <= 0)
 			goto eee_exit_err;
 
 		eee_adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
-						MDIO_MMD_AN, phydev->addr);
+						MDIO_MMD_AN);
 		if (eee_adv <= 0)
 			goto eee_exit_err;
 
@@ -1161,15 +1160,13 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			 * clock while it is signaling LPI.
 			 */
 			int val = phy_read_mmd_indirect(phydev, MDIO_CTRL1,
-							MDIO_MMD_PCS,
-							phydev->addr);
+							MDIO_MMD_PCS);
 			if (val < 0)
 				return val;
 
 			val |= MDIO_PCS_CTRL1_CLKSTOP_EN;
 			phy_write_mmd_indirect(phydev, MDIO_CTRL1,
-					       MDIO_MMD_PCS, phydev->addr,
-					       val);
+					       MDIO_MMD_PCS, val);
 		}
 
 		return 0; /* EEE supported */
@@ -1188,8 +1185,7 @@ EXPORT_SYMBOL(phy_init_eee);
  */
 int phy_get_eee_err(struct phy_device *phydev)
 {
-	return phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR,
-				     MDIO_MMD_PCS, phydev->addr);
+	return phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR, MDIO_MMD_PCS);
 }
 EXPORT_SYMBOL(phy_get_eee_err);
 
@@ -1206,22 +1202,19 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
 	int val;
 
 	/* Get Supported EEE */
-	val = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
-				    MDIO_MMD_PCS, phydev->addr);
+	val = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE, MDIO_MMD_PCS);
 	if (val < 0)
 		return val;
 	data->supported = mmd_eee_cap_to_ethtool_sup_t(val);
 
 	/* Get advertisement EEE */
-	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
-				    MDIO_MMD_AN, phydev->addr);
+	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN);
 	if (val < 0)
 		return val;
 	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
 
 	/* Get LP advertisement EEE */
-	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
-				    MDIO_MMD_AN, phydev->addr);
+	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE, MDIO_MMD_AN);
 	if (val < 0)
 		return val;
 	data->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(val);
@@ -1241,8 +1234,7 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 {
 	int val = ethtool_adv_to_mmd_eee_adv_t(data->advertised);
 
-	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN,
-			       phydev->addr, val);
+	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN, val);
 
 	return 0;
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5f5cc3424b9e..08198ce98773 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -629,14 +629,12 @@ static inline int phy_read_mmd(struct phy_device *phydev, int devad, u32 regnum)
  * phy_read_mmd_indirect - reads data from the MMD registers
  * @phydev: The PHY device bus
  * @prtad: MMD Address
- * @devad: MMD DEVAD
  * @addr: PHY address on the MII bus
  *
  * Description: it reads data from the MMD registers (clause 22 to access to
  * clause 45) of the specified phy address.
  */
-int phy_read_mmd_indirect(struct phy_device *phydev, int prtad,
-			  int devad, int addr);
+int phy_read_mmd_indirect(struct phy_device *phydev, int prtad, int devad);
 
 /**
  * phy_read - Convenience function for reading a given PHY register
@@ -735,14 +733,13 @@ static inline int phy_write_mmd(struct phy_device *phydev, int devad,
  * @phydev: The PHY device
  * @prtad: MMD Address
  * @devad: MMD DEVAD
- * @addr: PHY address on the MII bus
  * @data: data to write in the MMD register
  *
  * Description: Write data from the MMD registers of the specified
  * phy address.
  */
 void phy_write_mmd_indirect(struct phy_device *phydev, int prtad,
-			    int devad, int addr, u32 data);
+			    int devad, u32 data);
 
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
-- 
2.6.4
