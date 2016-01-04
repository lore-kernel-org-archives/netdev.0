From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 03/24] phy: Use phy_read() instead of mdiobus_read()
Date: Mon,  4 Jan 2016 18:36:41 +0100
Message-ID: <1451929022-5580-4-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34989 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137AbcADRim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:38:42 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have a phydev, make use of it and the phy_read() function.
This will help with later refactoring.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 104 ++++++++---------------
 drivers/net/phy/phy.c                            |   6 +-
 2 files changed, 38 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3b234176dd36..4eddbeb19307 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -77,18 +77,16 @@ static void hns_get_mdix_mode(struct net_device *net_dev,
 		return;
 	}
 
-	(void)mdiobus_write(phy_dev->bus, phy_dev->addr, HNS_PHY_PAGE_REG,
-			    HNS_PHY_PAGE_MDIX);
+	phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_MDIX);
 
-	retval = mdiobus_read(phy_dev->bus, phy_dev->addr, HNS_PHY_CSC_REG);
+	retval = phy_read(phy_dev, HNS_PHY_CSC_REG);
 	mdix_ctrl = hnae_get_field(retval, PHY_MDIX_CTRL_M, PHY_MDIX_CTRL_S);
 
-	retval = mdiobus_read(phy_dev->bus, phy_dev->addr, HNS_PHY_CSS_REG);
+	retval = phy_read(phy_dev, HNS_PHY_CSS_REG);
 	mdix = hnae_get_bit(retval, PHY_MDIX_STATUS_B);
 	is_resolved = hnae_get_bit(retval, PHY_SPEED_DUP_RESOLVE_B);
 
-	(void)mdiobus_write(phy_dev->bus, phy_dev->addr, HNS_PHY_PAGE_REG,
-			    HNS_PHY_PAGE_COPPER);
+	phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_COPPER);
 
 	switch (mdix_ctrl) {
 	case 0x0:
@@ -253,53 +251,36 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
 
 	if (en) {
 		/* speed : 1000M */
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    HNS_PHY_PAGE_REG, 2);
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    21, 0x1046);
+		phy_write(phy_dev, HNS_PHY_PAGE_REG, 2);
+		phy_write(phy_dev, 21, 0x1046);
 		/* Force Master */
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    9, 0x1F00);
+		phy_write(phy_dev, 9, 0x1F00);
 		/* Soft-reset */
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    0, 0x9140);
+		phy_write(phy_dev, 0, 0x9140);
 		/* If autoneg disabled,two soft-reset operations */
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    0, 0x9140);
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    22, 0xFA);
+		phy_write(phy_dev, 0, 0x9140);
+		phy_write(phy_dev, 22, 0xFA);
 
 		/* Default is 0x0400 */
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    1, 0x418);
+		phy_write(phy_dev, 1, 0x418);
 
 		/* Force 1000M Link, Default is 0x0200 */
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    7, 0x20C);
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    22, 0);
+		phy_write(phy_dev, 7, 0x20C);
+		phy_write(phy_dev, 22, 0);
 
 		/* Enable MAC loop-back */
-		val = (u16)mdiobus_read(phy_dev->bus, phy_dev->addr,
-					COPPER_CONTROL_REG);
+		val = phy_read(phy_dev, COPPER_CONTROL_REG);
 		val |= PHY_LOOP_BACK;
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    COPPER_CONTROL_REG, val);
+		phy_write(phy_dev, COPPER_CONTROL_REG, val);
 	} else {
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    22, 0xFA);
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    1, 0x400);
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    7, 0x200);
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    22, 0);
-
-		val = (u16)mdiobus_read(phy_dev->bus, phy_dev->addr,
-					COPPER_CONTROL_REG);
+		phy_write(phy_dev, 22, 0xFA);
+		phy_write(phy_dev, 1, 0x400);
+		phy_write(phy_dev, 7, 0x200);
+		phy_write(phy_dev, 22, 0);
+
+		val = phy_read(phy_dev, COPPER_CONTROL_REG);
 		val &= ~PHY_LOOP_BACK;
-		(void)mdiobus_write(phy_dev->bus, phy_dev->addr,
-				    COPPER_CONTROL_REG, val);
+		phy_write(phy_dev, COPPER_CONTROL_REG, val);
 	}
 	return 0;
 }
@@ -1018,16 +999,9 @@ int hns_phy_led_set(struct net_device *netdev, int value)
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct phy_device *phy_dev = priv->phy;
 
-	if (!phy_dev->bus) {
-		netdev_err(netdev, "phy_dev->bus is null!\n");
-		return -EINVAL;
-	}
-	retval = mdiobus_write(phy_dev->bus, phy_dev->addr,
-			       HNS_PHY_PAGE_REG, HNS_PHY_PAGE_LED);
-	retval = mdiobus_write(phy_dev->bus, phy_dev->addr, HNS_LED_FC_REG,
-			       value);
-	retval = mdiobus_write(phy_dev->bus, phy_dev->addr,
-			       HNS_PHY_PAGE_REG, HNS_PHY_PAGE_COPPER);
+	retval = phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_LED);
+	retval = phy_write(phy_dev, HNS_LED_FC_REG, value);
+	retval = phy_write(phy_dev, HNS_PHY_PAGE_REG, HNS_PHY_PAGE_COPPER);
 	if (retval) {
 		netdev_err(netdev, "mdiobus_write fail !\n");
 		return retval;
@@ -1052,19 +1026,15 @@ int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
 	if (phy_dev)
 		switch (state) {
 		case ETHTOOL_ID_ACTIVE:
-			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
-					    HNS_PHY_PAGE_REG,
-					    HNS_PHY_PAGE_LED);
+			ret = phy_write(phy_dev, HNS_PHY_PAGE_REG,
+					HNS_PHY_PAGE_LED);
 			if (ret)
 				return ret;
 
-			priv->phy_led_val = (u16)mdiobus_read(phy_dev->bus,
-							      phy_dev->addr,
-							      HNS_LED_FC_REG);
+			priv->phy_led_val = phy_read(phy_dev, HNS_LED_FC_REG);
 
-			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
-					    HNS_PHY_PAGE_REG,
-					    HNS_PHY_PAGE_COPPER);
+			ret = phy_write(phy_dev, HNS_PHY_PAGE_REG,
+					HNS_PHY_PAGE_COPPER);
 			if (ret)
 				return ret;
 			return 2;
@@ -1079,20 +1049,18 @@ int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
 				return ret;
 			break;
 		case ETHTOOL_ID_INACTIVE:
-			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
-					    HNS_PHY_PAGE_REG,
-					    HNS_PHY_PAGE_LED);
+			ret = phy_write(phy_dev, HNS_PHY_PAGE_REG,
+					HNS_PHY_PAGE_LED);
 			if (ret)
 				return ret;
 
-			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
-					    HNS_LED_FC_REG, priv->phy_led_val);
+			ret = phy_write(phy_dev, HNS_LED_FC_REG,
+					priv->phy_led_val);
 			if (ret)
 				return ret;
 
-			ret = mdiobus_write(phy_dev->bus, phy_dev->addr,
-					    HNS_PHY_PAGE_REG,
-					    HNS_PHY_PAGE_COPPER);
+			ret = phy_write(phy_dev, HNS_PHY_PAGE_REG,
+					HNS_PHY_PAGE_COPPER);
 			if (ret)
 				return ret;
 			break;
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 47cd306dbb3c..67a77956ae6f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -407,8 +407,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 		/* fall through */
 
 	case SIOCGMIIREG:
-		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
-						 mii_data->reg_num);
+		mii_data->val_out = phy_read(phydev, mii_data->reg_num);
 		return 0;
 
 	case SIOCSMIIREG:
@@ -445,8 +444,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 			}
 		}
 
-		mdiobus_write(phydev->bus, mii_data->phy_id,
-			      mii_data->reg_num, val);
+		phy_write(phydev, mii_data->reg_num, val);
 
 		if (mii_data->phy_id == phydev->addr &&
 		    mii_data->reg_num == MII_BMCR &&
-- 
2.6.4
