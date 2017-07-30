From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 7/7] net: phy: marvell: Refactor setting downshift into a helper
Date: Sun, 30 Jul 2017 22:41:50 +0200
Message-ID: <1501447310-24101-8-git-send-email-andrew@lunn.ch>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45289 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754442AbdG3Upx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:45:53 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 1116r has code to set downshift. Refactor this into a helper, so
in future other marvell PHYs can use it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 34fd15b904e7..361fe9927ef2 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -58,6 +58,7 @@
 #define MII_M1011_PHY_SCR			0x10
 #define MII_M1011_PHY_SCR_DOWNSHIFT_EN		BIT(11)
 #define MII_M1011_PHY_SCR_DOWNSHIFT_SHIFT	12
+#define MII_M1011_PHY_SRC_DOWNSHIFT_MASK	0x7800
 #define MII_M1011_PHY_SCR_MDI			(0x0 << 5)
 #define MII_M1011_PHY_SCR_MDI_X			(0x1 << 5)
 #define MII_M1011_PHY_SCR_AUTO_CROSS		(0x3 << 5)
@@ -263,6 +264,23 @@ static int marvell_set_polarity(struct phy_device *phydev, int polarity)
 	return 0;
 }
 
+static int marvell_set_downshift(struct phy_device *phydev, bool enable,
+				 u8 retries)
+{
+	int reg;
+
+	reg = phy_read(phydev, MII_M1011_PHY_SCR);
+	if (reg < 0)
+		return reg;
+
+	reg &= MII_M1011_PHY_SRC_DOWNSHIFT_MASK;
+	reg |= ((retries - 1) << MII_M1011_PHY_SCR_DOWNSHIFT_SHIFT);
+	if (enable)
+		reg |= MII_M1011_PHY_SCR_DOWNSHIFT_EN;
+
+	return phy_write(phydev, MII_M1011_PHY_SCR, reg);
+}
+
 static int marvell_config_aneg(struct phy_device *phydev)
 {
 	int err;
@@ -643,7 +661,6 @@ static int marvell_config_init(struct phy_device *phydev)
 
 static int m88e1116r_config_init(struct phy_device *phydev)
 {
-	int temp;
 	int err;
 
 	err = genphy_soft_reset(phydev);
@@ -660,10 +677,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	temp = phy_read(phydev, MII_M1011_PHY_SCR);
-	temp |= (7 << MII_M1011_PHY_SCR_DOWNSHIFT_SHIFT);
-	temp |= MII_M1011_PHY_SCR_DOWNSHIFT_EN;
-	err = phy_write(phydev, MII_M1011_PHY_SCR, temp);
+	err = marvell_set_downshift(phydev, true, 8);
 	if (err < 0)
 		return err;
 
-- 
2.13.2
