From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/7] net: phy: marvell: consolidate RGMII delay code
Date: Sun, 30 Jul 2017 22:41:46 +0200
Message-ID: <1501447310-24101-4-git-send-email-andrew@lunn.ch>
References: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45258 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754442AbdG3Ume (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:42:34 -0400
In-Reply-To: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same code is repeated for different PHY versions. Put it into a
help and call when needed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 54 +++++++++++++++++++----------------------------
 1 file changed, 22 insertions(+), 32 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 33a52532fac6..c1b724ab5f25 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -61,13 +61,6 @@
 #define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
 
 #define MII_M1145_PHY_EXT_SR		0x1b
-#define MII_M1145_PHY_EXT_CR		0x14
-#define MII_M1145_RGMII_RX_DELAY	0x0080
-#define MII_M1145_RGMII_TX_DELAY	0x0002
-#define MII_M1145_HWCFG_MODE_SGMII_NO_CLK	0x4
-#define MII_M1145_HWCFG_MODE_MASK		0xf
-#define MII_M1145_HWCFG_FIBER_COPPER_AUTO	0x8000
-
 #define MII_M1145_HWCFG_MODE_SGMII_NO_CLK	0x4
 #define MII_M1145_HWCFG_MODE_MASK		0xf
 #define MII_M1145_HWCFG_FIBER_COPPER_AUTO	0x8000
@@ -76,8 +69,8 @@
 #define MII_M1111_PHY_LED_DIRECT	0x4100
 #define MII_M1111_PHY_LED_COMBINE	0x411c
 #define MII_M1111_PHY_EXT_CR		0x14
-#define MII_M1111_RX_DELAY		0x80
-#define MII_M1111_TX_DELAY		0x2
+#define MII_M1111_RGMII_RX_DELAY	BIT(7)
+#define MII_M1111_RGMII_TX_DELAY	BIT(1)
 #define MII_M1111_PHY_EXT_SR		0x1b
 
 #define MII_M1111_HWCFG_MODE_MASK		0xf
@@ -700,9 +693,8 @@ static int m88e3016_config_init(struct phy_device *phydev)
 	return marvell_config_init(phydev);
 }
 
-static int m88e1111_config_init_rgmii(struct phy_device *phydev)
+static int m88e1111_config_init_rgmii_delays(struct phy_device *phydev)
 {
-	int err;
 	int temp;
 
 	temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
@@ -710,16 +702,24 @@ static int m88e1111_config_init_rgmii(struct phy_device *phydev)
 		return temp;
 
 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
-		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
+		temp |= (MII_M1111_RGMII_RX_DELAY | MII_M1111_RGMII_TX_DELAY);
 	} else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) {
-		temp &= ~MII_M1111_TX_DELAY;
-		temp |= MII_M1111_RX_DELAY;
+		temp &= ~MII_M1111_RGMII_TX_DELAY;
+		temp |= MII_M1111_RGMII_RX_DELAY;
 	} else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
-		temp &= ~MII_M1111_RX_DELAY;
-		temp |= MII_M1111_TX_DELAY;
+		temp &= ~MII_M1111_RGMII_RX_DELAY;
+		temp |= MII_M1111_RGMII_TX_DELAY;
 	}
 
-	err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+	return phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
+}
+
+static int m88e1111_config_init_rgmii(struct phy_device *phydev)
+{
+	int temp;
+	int err;
+
+	err = m88e1111_config_init_rgmii_delays(phydev);
 	if (err < 0)
 		return err;
 
@@ -760,16 +760,11 @@ static int m88e1111_config_init_sgmii(struct phy_device *phydev)
 
 static int m88e1111_config_init_rtbi(struct phy_device *phydev)
 {
-	int err;
 	int temp;
+	int err;
 
-	temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
-	if (temp < 0)
-		return temp;
-
-	temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
-	err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
-	if (err < 0)
+	err = m88e1111_config_init_rgmii_delays(phydev);
+	if (err)
 		return err;
 
 	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
@@ -969,15 +964,10 @@ static int m88e1149_config_init(struct phy_device *phydev)
 
 static int m88e1145_config_init_rgmii(struct phy_device *phydev)
 {
+	int temp;
 	int err;
-	int temp = phy_read(phydev, MII_M1145_PHY_EXT_CR);
-
-	if (temp < 0)
-		return temp;
-
-	temp |= (MII_M1145_RGMII_RX_DELAY | MII_M1145_RGMII_TX_DELAY);
 
-	err = phy_write(phydev, MII_M1145_PHY_EXT_CR, temp);
+	err = m88e1111_config_init_rgmii_delays(phydev);
 	if (err < 0)
 		return err;
 
-- 
2.13.2
