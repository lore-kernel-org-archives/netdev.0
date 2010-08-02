From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 1/2] phy/marvell: add 88e1121 interface mode support
Date: Mon,  2 Aug 2010 15:44:53 -0400
Message-ID: <1280778294-2993-2-git-send-email-cyril@ti.com>
References: <1280778294-2993-1-git-send-email-cyril@ti.com>
Cc: Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:35662 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754492Ab0HBTo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 15:44:58 -0400
Received: from dlep33.itg.ti.com ([157.170.170.112])
	by comal.ext.ti.com (8.13.7/8.13.7) with ESMTP id o72Jiwox003212
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 14:44:58 -0500
In-Reply-To: <1280778294-2993-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for RGMII RX/TX delay configuration on marvell 88e1121
and derivatives.  With this patch, PHY_INTERFACE_MODE_RGMII_*ID modes are now
supported on these devices.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 drivers/net/phy/marvell.c |   35 ++++++++++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 78b74e8..b1413ae 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -69,6 +69,12 @@
 #define MII_M1111_COPPER		0
 #define MII_M1111_FIBER			1
 
+#define MII_88E1121_PHY_MSCR_PAGE	2
+#define MII_88E1121_PHY_MSCR_REG	21
+#define MII_88E1121_PHY_MSCR_RX_DELAY	BIT(5)
+#define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
+#define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(0x3 << 4))
+
 #define MII_88E1121_PHY_LED_CTRL	16
 #define MII_88E1121_PHY_LED_PAGE	3
 #define MII_88E1121_PHY_LED_DEF		0x0030
@@ -180,7 +186,30 @@ static int marvell_config_aneg(struct phy_device *phydev)
 
 static int m88e1121_config_aneg(struct phy_device *phydev)
 {
-	int err, temp;
+	int err, oldpage, mscr;
+
+	oldpage = phy_read(phydev, MII_88E1121_PHY_PAGE);
+
+	err = phy_write(phydev, MII_88E1121_PHY_PAGE,
+			MII_88E1121_PHY_MSCR_PAGE);
+	if (err < 0)
+		return err;
+	mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
+		MII_88E1121_PHY_MSCR_DELAY_MASK;
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
+	if (err < 0)
+		return err;
+
+	phy_write(phydev, MII_88E1121_PHY_PAGE, oldpage);
 
 	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
 	if (err < 0)
@@ -191,11 +220,11 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	temp = phy_read(phydev, MII_88E1121_PHY_PAGE);
+	oldpage = phy_read(phydev, MII_88E1121_PHY_PAGE);
 
 	phy_write(phydev, MII_88E1121_PHY_PAGE, MII_88E1121_PHY_LED_PAGE);
 	phy_write(phydev, MII_88E1121_PHY_LED_CTRL, MII_88E1121_PHY_LED_DEF);
-	phy_write(phydev, MII_88E1121_PHY_PAGE, temp);
+	phy_write(phydev, MII_88E1121_PHY_PAGE, oldpage);
 
 	err = genphy_config_aneg(phydev);
 
-- 
1.7.0.4

