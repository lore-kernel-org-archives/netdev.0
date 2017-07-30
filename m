From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 6/7] net: phy: marvell: Use the set_polarity helper
Date: Sun, 30 Jul 2017 22:41:49 +0200
Message-ID: <1501447310-24101-7-git-send-email-andrew@lunn.ch>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45279 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754442AbdG3Uou (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:44:50 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the init functions unilaterally enable set auto cross over
without using the helper. Make use of the helper, and respect the
phydev MDI configuration.

Clean up the #define used while setting polarity, and the other
functions of the bits in the register.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 408442bdef0a..34fd15b904e7 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -55,10 +55,12 @@
 #define MII_M1011_IMASK_INIT		0x6400
 #define MII_M1011_IMASK_CLEAR		0x0000
 
-#define MII_M1011_PHY_SCR		0x10
-#define MII_M1011_PHY_SCR_MDI		0x0000
-#define MII_M1011_PHY_SCR_MDI_X		0x0020
-#define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
+#define MII_M1011_PHY_SCR			0x10
+#define MII_M1011_PHY_SCR_DOWNSHIFT_EN		BIT(11)
+#define MII_M1011_PHY_SCR_DOWNSHIFT_SHIFT	12
+#define MII_M1011_PHY_SCR_MDI			(0x0 << 5)
+#define MII_M1011_PHY_SCR_MDI_X			(0x1 << 5)
+#define MII_M1011_PHY_SCR_AUTO_CROSS		(0x3 << 5)
 
 #define MII_M1111_PHY_LED_CONTROL	0x18
 #define MII_M1111_PHY_LED_DIRECT	0x4100
@@ -486,8 +488,7 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_M1011_PHY_SCR,
-			MII_M1011_PHY_SCR_AUTO_CROSS);
+	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
 	if (err < 0)
 		return err;
 
@@ -655,10 +656,13 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
+	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
+	if (err < 0)
+		return err;
+
 	temp = phy_read(phydev, MII_M1011_PHY_SCR);
-	temp |= (7 << 12);	/* max number of gigabit attempts */
-	temp |= (1 << 11);	/* enable downshift */
-	temp |= MII_M1011_PHY_SCR_AUTO_CROSS;
+	temp |= (7 << MII_M1011_PHY_SCR_DOWNSHIFT_SHIFT);
+	temp |= MII_M1011_PHY_SCR_DOWNSHIFT_EN;
 	err = phy_write(phydev, MII_M1011_PHY_SCR, temp);
 	if (err < 0)
 		return err;
@@ -891,8 +895,7 @@ static int m88e1118_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_M1011_PHY_SCR,
-			MII_M1011_PHY_SCR_AUTO_CROSS);
+	err = marvell_set_polarity(phydev, phydev->mdix_ctrl);
 	if (err < 0)
 		return err;
 
-- 
2.13.2
