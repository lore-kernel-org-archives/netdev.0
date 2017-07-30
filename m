From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 5/7] net: phy: marvell: Refactor m88e1121 RGMII delay configuration
Date: Sun, 30 Jul 2017 22:41:48 +0200
Message-ID: <1501447310-24101-6-git-send-email-andrew@lunn.ch>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45284 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754442AbdG3UpV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:45:21 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turns out that MII_M1116R_CONTROL_REG_MAC is the same as
MII_88E1121_PHY_MSCR_REG. Refactor the code to set the RGMII delays
into a shared helper.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 62 +++++++++++++++++++++++++----------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 275647ebaa81..408442bdef0a 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -80,7 +80,7 @@
 #define MII_88E1121_PHY_MSCR_REG	21
 #define MII_88E1121_PHY_MSCR_RX_DELAY	BIT(5)
 #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
-#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(0x3 << 4))
+#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(BIT(5) || BIT(4)))
 
 #define MII_88E1121_MISC_TEST				0x1a
 #define MII_88E1510_MISC_TEST_TEMP_THRESHOLD_MASK	0x1f00
@@ -127,8 +127,6 @@
 #define MII_M1011_PHY_STATUS_RESOLVED	0x0800
 #define MII_M1011_PHY_STATUS_LINK	0x0400
 
-#define MII_M1116R_CONTROL_REG_MAC	21
-
 #define MII_88E3016_PHY_SPEC_CTRL	0x10
 #define MII_88E3016_DISABLE_SCRAMBLER	0x0200
 #define MII_88E3016_AUTO_MDIX_CROSSOVER	0x0030
@@ -442,7 +440,7 @@ static int marvell_of_reg_init(struct phy_device *phydev)
 }
 #endif /* CONFIG_OF_MDIO */
 
-static int m88e1121_config_aneg(struct phy_device *phydev)
+static int m88e1121_config_aneg_rgmii_delays(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
@@ -450,25 +448,40 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	if (oldpage < 0)
 		return oldpage;
 
-	if (phy_interface_is_rgmii(phydev)) {
-		mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
-			MII_88E1121_PHY_MSCR_DELAY_MASK;
-
-		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
-			mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
-				 MII_88E1121_PHY_MSCR_TX_DELAY);
-		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
-			mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
-		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
-			mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
-
-		err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
-		if (err < 0)
-			return err;
+	mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG);
+	if (mscr < 0) {
+		err = mscr;
+		goto out;
 	}
 
+	mscr &= MII_88E1121_PHY_MSCR_DELAY_MASK;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
+			 MII_88E1121_PHY_MSCR_TX_DELAY);
+	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+		mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
+	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+		mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
+
+	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
+
+out:
 	marvell_set_page(phydev, oldpage);
 
+	return err;
+}
+
+static int m88e1121_config_aneg(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (phy_interface_is_rgmii(phydev)) {
+		err = m88e1121_config_aneg_rgmii_delays(phydev);
+		if (err)
+			return err;
+	}
+
 	err = genphy_soft_reset(phydev);
 	if (err < 0)
 		return err;
@@ -650,16 +663,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = marvell_set_page(phydev, MII_MARVELL_MSCR_PAGE);
-	if (err < 0)
-		return err;
-	temp = phy_read(phydev, MII_M1116R_CONTROL_REG_MAC);
-	temp |= (1 << 5);
-	temp |= (1 << 4);
-	err = phy_write(phydev, MII_M1116R_CONTROL_REG_MAC, temp);
-	if (err < 0)
-		return err;
-	err = marvell_set_page(phydev, MII_MARVELL_COPPER_PAGE);
+	err = m88e1121_config_aneg_rgmii_delays(phydev);
 	if (err < 0)
 		return err;
 
-- 
2.13.2
