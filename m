From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH 1/1] phy: marvell: Fix 88E1510 initialization
Date: Tue, 23 Feb 2016 20:16:58 +0100
Message-ID: <1456255018-9632-2-git-send-email-clemens.gruber@pqgruber.com>
References: <1456255018-9632-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: netdev@vger.kernel.org,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pqgruber.com ([178.189.19.235]:21928 "EHLO
	mail.pqgruber.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754353AbcBWTRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:17:21 -0500
In-Reply-To: <1456255018-9632-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bug was introduced in the merge commit b633353115e3 ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
The generic marvell_config_init (and therefore marvell_of_reg_init) is
not called anymore for the Marvell 88E1510 (in net-next).

This patch calls marvell_config_init and moves the specific init
function for the 88E1510 below the marvell_config_init function to avoid
adding a function predeclaration.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---
 drivers/net/phy/marvell.c | 70 +++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 9fb9d80..280e879 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -443,41 +443,6 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 	return m88e1121_config_aneg(phydev);
 }
 
-static int m88e1510_config_init(struct phy_device *phydev)
-{
-	int err;
-	int temp;
-
-	/* SGMII-to-Copper mode initialization */
-	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
-		/* Select page 18 */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 18);
-		if (err < 0)
-			return err;
-
-		/* In reg 20, write MODE[2:0] = 0x1 (SGMII to Copper) */
-		temp = phy_read(phydev, MII_88E1510_GEN_CTRL_REG_1);
-		temp &= ~MII_88E1510_GEN_CTRL_REG_1_MODE_MASK;
-		temp |= MII_88E1510_GEN_CTRL_REG_1_MODE_SGMII;
-		err = phy_write(phydev, MII_88E1510_GEN_CTRL_REG_1, temp);
-		if (err < 0)
-			return err;
-
-		/* PHY reset is necessary after changing MODE[2:0] */
-		temp |= MII_88E1510_GEN_CTRL_REG_1_RESET;
-		err = phy_write(phydev, MII_88E1510_GEN_CTRL_REG_1, temp);
-		if (err < 0)
-			return err;
-
-		/* Reset page selection */
-		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
-		if (err < 0)
-			return err;
-	}
-
-	return 0;
-}
-
 static int m88e1510_config_aneg(struct phy_device *phydev)
 {
 	int err;
@@ -671,6 +636,41 @@ static int m88e1111_config_init(struct phy_device *phydev)
 	return phy_write(phydev, MII_BMCR, BMCR_RESET);
 }
 
+static int m88e1510_config_init(struct phy_device *phydev)
+{
+	int err;
+	int temp;
+
+	/* SGMII-to-Copper mode initialization */
+	if (phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+		/* Select page 18 */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 18);
+		if (err < 0)
+			return err;
+
+		/* In reg 20, write MODE[2:0] = 0x1 (SGMII to Copper) */
+		temp = phy_read(phydev, MII_88E1510_GEN_CTRL_REG_1);
+		temp &= ~MII_88E1510_GEN_CTRL_REG_1_MODE_MASK;
+		temp |= MII_88E1510_GEN_CTRL_REG_1_MODE_SGMII;
+		err = phy_write(phydev, MII_88E1510_GEN_CTRL_REG_1, temp);
+		if (err < 0)
+			return err;
+
+		/* PHY reset is necessary after changing MODE[2:0] */
+		temp |= MII_88E1510_GEN_CTRL_REG_1_RESET;
+		err = phy_write(phydev, MII_88E1510_GEN_CTRL_REG_1, temp);
+		if (err < 0)
+			return err;
+
+		/* Reset page selection */
+		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+		if (err < 0)
+			return err;
+	}
+
+	return marvell_config_init(phydev);
+}
+
 static int m88e1118_config_aneg(struct phy_device *phydev)
 {
 	int err;
-- 
2.7.1
