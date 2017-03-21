From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH net-next 4/7] net: phy: switch remaining users to
 phy_(read|write)_mmd()
Date: Tue, 21 Mar 2017 16:36:53 +0000
Message-ID: <E1cqMmD-0006wq-AH@rmk-PC.armlinux.org.uk>
References: <20170321163555.GA21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, linux-usb@vger.kernel.org,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, Woojung Huh <woojung.huh@microchip.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54112 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932718AbdCUQhj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 12:37:39 -0400
In-Reply-To: <20170321163555.GA21222@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch everyone over to using phy_read_mmd() and phy_write_mmd() now
that they are able to handle both Clause 22 indirect addressing and
Clause 45 direct addressing methods to the MMD registers.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/bcm-phy-lib.c | 12 ++++--------
 drivers/net/phy/dp83867.c     | 25 +++++++++++--------------
 drivers/net/phy/intel-xway.c  | 26 +++++++++++++-------------
 drivers/net/phy/microchip.c   |  5 ++---
 drivers/net/phy/phy.c         | 25 ++++++++++---------------
 drivers/net/phy/phy_device.c  |  4 ++--
 6 files changed, 42 insertions(+), 55 deletions(-)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index 9656dbeb5de5..171010eb4d9c 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -201,8 +201,7 @@ int bcm_phy_set_eee(struct phy_device *phydev, bool enable)
 	int val;
 
 	/* Enable EEE at PHY level */
-	val = phy_read_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
-				    MDIO_MMD_AN);
+	val = phy_read_mmd(phydev, MDIO_MMD_AN, BRCM_CL45VEN_EEE_CONTROL);
 	if (val < 0)
 		return val;
 
@@ -211,12 +210,10 @@ int bcm_phy_set_eee(struct phy_device *phydev, bool enable)
 	else
 		val &= ~(LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X);
 
-	phy_write_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
-			       MDIO_MMD_AN, (u32)val);
+	phy_write_mmd(phydev, MDIO_MMD_AN, BRCM_CL45VEN_EEE_CONTROL, (u32)val);
 
 	/* Advertise EEE */
-	val = phy_read_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
-				    MDIO_MMD_AN);
+	val = phy_read_mmd(phydev, MDIO_MMD_AN, BCM_CL45VEN_EEE_ADV);
 	if (val < 0)
 		return val;
 
@@ -225,8 +222,7 @@ int bcm_phy_set_eee(struct phy_device *phydev, bool enable)
 	else
 		val &= ~(MDIO_EEE_100TX | MDIO_EEE_1000T);
 
-	phy_write_mmd_indirect(phydev, BCM_CL45VEN_EEE_ADV,
-			       MDIO_MMD_AN, (u32)val);
+	phy_write_mmd(phydev, MDIO_MMD_AN, BCM_CL45VEN_EEE_ADV, (u32)val);
 
 	return 0;
 }
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index 19865530e0b1..b57f20e552ba 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -133,14 +133,14 @@ static int dp83867_config_port_mirroring(struct phy_device *phydev)
 		(struct dp83867_private *)phydev->priv;
 	u16 val;
 
-	val = phy_read_mmd_indirect(phydev, DP83867_CFG4, DP83867_DEVADDR);
+	val = phy_read_mmd(phydev, DP83867_DEVADDR, DP83867_CFG4);
 
 	if (dp83867->port_mirroring == DP83867_PORT_MIRROING_EN)
 		val |= DP83867_CFG4_PORT_MIRROR_EN;
 	else
 		val &= ~DP83867_CFG4_PORT_MIRROR_EN;
 
-	phy_write_mmd_indirect(phydev, DP83867_CFG4, DP83867_DEVADDR, val);
+	phy_write_mmd(phydev, DP83867_DEVADDR, DP83867_CFG4, val);
 
 	return 0;
 }
@@ -231,8 +231,7 @@ static int dp83867_config_init(struct phy_device *phydev)
 		 * register's bit 11 (marked as RESERVED).
 		 */
 
-		bs = phy_read_mmd_indirect(phydev, DP83867_STRAP_STS1,
-					   DP83867_DEVADDR);
+		bs = phy_read_mmd(phydev, DP83867_DEVADDR, DP83867_STRAP_STS1);
 		if (bs & DP83867_STRAP_STS1_RESERVED)
 			val &= ~DP83867_PHYCR_RESERVED_MASK;
 
@@ -243,8 +242,7 @@ static int dp83867_config_init(struct phy_device *phydev)
 
 	if ((phydev->interface >= PHY_INTERFACE_MODE_RGMII_ID) &&
 	    (phydev->interface <= PHY_INTERFACE_MODE_RGMII_RXID)) {
-		val = phy_read_mmd_indirect(phydev, DP83867_RGMIICTL,
-					    DP83867_DEVADDR);
+		val = phy_read_mmd(phydev, DP83867_DEVADDR, DP83867_RGMIICTL);
 
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
 			val |= (DP83867_RGMII_TX_CLK_DELAY_EN | DP83867_RGMII_RX_CLK_DELAY_EN);
@@ -255,25 +253,24 @@ static int dp83867_config_init(struct phy_device *phydev)
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
 			val |= DP83867_RGMII_RX_CLK_DELAY_EN;
 
-		phy_write_mmd_indirect(phydev, DP83867_RGMIICTL,
-				       DP83867_DEVADDR, val);
+		phy_write_mmd(phydev, DP83867_DEVADDR, DP83867_RGMIICTL, val);
 
 		delay = (dp83867->rx_id_delay |
 			(dp83867->tx_id_delay << DP83867_RGMII_TX_CLK_DELAY_SHIFT));
 
-		phy_write_mmd_indirect(phydev, DP83867_RGMIIDCTL,
-				       DP83867_DEVADDR, delay);
+		phy_write_mmd(phydev, DP83867_DEVADDR, DP83867_RGMIIDCTL,
+			      delay);
 
 		if (dp83867->io_impedance >= 0) {
-			val = phy_read_mmd_indirect(phydev, DP83867_IO_MUX_CFG,
-						    DP83867_DEVADDR);
+			val = phy_read_mmd(phydev, DP83867_DEVADDR,
+					   DP83867_IO_MUX_CFG);
 
 			val &= ~DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL;
 			val |= dp83867->io_impedance &
 			       DP83867_IO_MUX_CFG_IO_IMPEDANCE_CTRL;
 
-			phy_write_mmd_indirect(phydev, DP83867_IO_MUX_CFG,
-					       DP83867_DEVADDR, val);
+			phy_write_mmd(phydev, DP83867_DEVADDR,
+				      DP83867_IO_MUX_CFG, val);
 		}
 	}
 
diff --git a/drivers/net/phy/intel-xway.c b/drivers/net/phy/intel-xway.c
index b1fd7bb0e4db..55f8c52dd2f1 100644
--- a/drivers/net/phy/intel-xway.c
+++ b/drivers/net/phy/intel-xway.c
@@ -166,13 +166,13 @@ static int xway_gphy_config_init(struct phy_device *phydev)
 	/* Clear all pending interrupts */
 	phy_read(phydev, XWAY_MDIO_ISTAT);
 
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LEDCH, MDIO_MMD_VEND2,
-			       XWAY_MMD_LEDCH_NACS_NONE |
-			       XWAY_MMD_LEDCH_SBF_F02HZ |
-			       XWAY_MMD_LEDCH_FBF_F16HZ);
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LEDCL, MDIO_MMD_VEND2,
-			       XWAY_MMD_LEDCH_CBLINK_NONE |
-			       XWAY_MMD_LEDCH_SCAN_NONE);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LEDCH,
+		      XWAY_MMD_LEDCH_NACS_NONE |
+		      XWAY_MMD_LEDCH_SBF_F02HZ |
+		      XWAY_MMD_LEDCH_FBF_F16HZ);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LEDCL,
+		      XWAY_MMD_LEDCH_CBLINK_NONE |
+		      XWAY_MMD_LEDCH_SCAN_NONE);
 
 	/**
 	 * In most cases only one LED is connected to this phy, so
@@ -183,12 +183,12 @@ static int xway_gphy_config_init(struct phy_device *phydev)
 	ledxh = XWAY_MMD_LEDxH_BLINKF_NONE | XWAY_MMD_LEDxH_CON_LINK10XX;
 	ledxl = XWAY_MMD_LEDxL_PULSE_TXACT | XWAY_MMD_LEDxL_PULSE_RXACT |
 		XWAY_MMD_LEDxL_BLINKS_NONE;
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LED0H, MDIO_MMD_VEND2, ledxh);
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LED0L, MDIO_MMD_VEND2, ledxl);
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LED1H, MDIO_MMD_VEND2, ledxh);
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LED1L, MDIO_MMD_VEND2, ledxl);
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LED2H, MDIO_MMD_VEND2, ledxh);
-	phy_write_mmd_indirect(phydev, XWAY_MMD_LED2L, MDIO_MMD_VEND2, ledxl);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LED0H, ledxh);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LED0L, ledxl);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LED1H, ledxh);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LED1L, ledxl);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LED2H, ledxh);
+	phy_write_mmd(phydev, MDIO_MMD_VEND2, XWAY_MMD_LED2L, ledxl);
 
 	return 0;
 }
diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 324fbf6ad8ff..2b2f543cf9f0 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -78,9 +78,8 @@ static int lan88xx_probe(struct phy_device *phydev)
 	priv->wolopts = 0;
 
 	/* these values can be used to identify internal PHY */
-	priv->chip_id = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_ID, 3);
-	priv->chip_rev = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_REV,
-					       3);
+	priv->chip_id = phy_read_mmd(phydev, 3, LAN88XX_MMD3_CHIP_ID);
+	priv->chip_rev = phy_read_mmd(phydev, 3, LAN88XX_MMD3_CHIP_REV);
 
 	phydev->priv = priv;
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index ffc28c42e2d1..ba4676ee9018 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1227,8 +1227,7 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			return status;
 
 		/* First check if the EEE ability is supported */
-		eee_cap = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
-						MDIO_MMD_PCS);
+		eee_cap = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_PCS_EEE_ABLE);
 		if (eee_cap <= 0)
 			goto eee_exit_err;
 
@@ -1239,13 +1238,11 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 		/* Check which link settings negotiated and verify it in
 		 * the EEE advertising registers.
 		 */
-		eee_lp = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
-					       MDIO_MMD_AN);
+		eee_lp = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_LPABLE);
 		if (eee_lp <= 0)
 			goto eee_exit_err;
 
-		eee_adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
-						MDIO_MMD_AN);
+		eee_adv = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
 		if (eee_adv <= 0)
 			goto eee_exit_err;
 
@@ -1258,14 +1255,12 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
 			/* Configure the PHY to stop receiving xMII
 			 * clock while it is signaling LPI.
 			 */
-			int val = phy_read_mmd_indirect(phydev, MDIO_CTRL1,
-							MDIO_MMD_PCS);
+			int val = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL1);
 			if (val < 0)
 				return val;
 
 			val |= MDIO_PCS_CTRL1_CLKSTOP_EN;
-			phy_write_mmd_indirect(phydev, MDIO_CTRL1,
-					       MDIO_MMD_PCS, val);
+			phy_write_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL1, val);
 		}
 
 		return 0; /* EEE supported */
@@ -1287,7 +1282,7 @@ int phy_get_eee_err(struct phy_device *phydev)
 	if (!phydev->drv)
 		return -EIO;
 
-	return phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR, MDIO_MMD_PCS);
+	return phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_PCS_EEE_WK_ERR);
 }
 EXPORT_SYMBOL(phy_get_eee_err);
 
@@ -1307,19 +1302,19 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data)
 		return -EIO;
 
 	/* Get Supported EEE */
-	val = phy_read_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE, MDIO_MMD_PCS);
+	val = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_PCS_EEE_ABLE);
 	if (val < 0)
 		return val;
 	data->supported = mmd_eee_cap_to_ethtool_sup_t(val);
 
 	/* Get advertisement EEE */
-	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN);
+	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
 	if (val < 0)
 		return val;
 	data->advertised = mmd_eee_adv_to_ethtool_adv_t(val);
 
 	/* Get LP advertisement EEE */
-	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE, MDIO_MMD_AN);
+	val = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_LPABLE);
 	if (val < 0)
 		return val;
 	data->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(val);
@@ -1345,7 +1340,7 @@ int phy_ethtool_set_eee(struct phy_device *phydev, struct ethtool_eee *data)
 	/* Mask prohibited EEE modes */
 	val &= ~phydev->eee_broken_modes;
 
-	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN, val);
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
 
 	return 0;
 }
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 5198ccfa347f..1219eeab69d1 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1217,7 +1217,7 @@ static int genphy_config_eee_advert(struct phy_device *phydev)
 	 * supported by the phy. If we read 0, EEE is not advertised
 	 * In both case, we don't need to continue
 	 */
-	adv = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN);
+	adv = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
 	if (adv <= 0)
 		return 0;
 
@@ -1228,7 +1228,7 @@ static int genphy_config_eee_advert(struct phy_device *phydev)
 	if (old_adv == adv)
 		return 0;
 
-	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV, MDIO_MMD_AN, adv);
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_EEE_ADV, adv);
 
 	return 1;
 }
-- 
2.7.4
