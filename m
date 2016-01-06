From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 03/22] phy: Use phy_read() instead of mdiobus_read()
Date: Wed,  6 Jan 2016 20:11:08 +0100
Message-ID: <1452107487-475-4-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42348 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbcAFTNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:13:00 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have a phydev, make use of it and the phy_read() function.
This will help with later refactoring.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Revert hunks in IOCTL, which prevented access to arbitrary MDIO
    addresses.
---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 104 ++++++++---------------
 1 file changed, 36 insertions(+), 68 deletions(-)

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
-- 
2.6.4
