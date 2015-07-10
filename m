From: David Thomson <david.thomson@alliedtelesis.co.nz>
Subject: [PATCH] net: phy: Support setting polarity in marvell phy driver
Date: Fri, 10 Jul 2015 16:28:25 +1200
Message-ID: <1436502505-5697-1-git-send-email-david.thomson@alliedtelesis.co.nz>
Cc: netdev@vger.kernel.org,
	David Thomson <david.thomson@alliedtelesis.co.nz>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:45492 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbbGJE2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 00:28:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support manually setting the polarity to mdi or mdix

Signed-off-by: David Thomson <david.thomson@alliedtelesis.co.nz>
---
 drivers/net/phy/marvell.c | 42 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/phy/phy.c     |  1 +
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index f721444..3320a17 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -48,6 +48,8 @@
 #define MII_M1011_IMASK_CLEAR		0x0000
 
 #define MII_M1011_PHY_SCR		0x10
+#define MII_M1011_PHY_SCR_MDI		0x0000
+#define MII_M1011_PHY_SCR_MDI_X		0x0020
 #define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
 
 #define MII_M1145_PHY_EXT_SR		0x1b
@@ -159,6 +161,43 @@ static int marvell_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static int marvell_set_polarity(struct phy_device *phydev, int polarity)
+{
+	int reg;
+	int err;
+	int val;
+
+	/* get the current settings */
+	reg = phy_read(phydev, MII_M1011_PHY_SCR);
+	if (reg < 0)
+		return reg;
+
+	val = reg;
+	val &= ~MII_M1011_PHY_SCR_AUTO_CROSS;
+	switch (polarity) {
+	case ETH_TP_MDI:
+		val |= MII_M1011_PHY_SCR_MDI;
+		break;
+	case ETH_TP_MDI_X:
+		val |= MII_M1011_PHY_SCR_MDI_X;
+		break;
+	case ETH_TP_MDI_AUTO:
+	case ETH_TP_MDI_INVALID:
+	default:
+		val |= MII_M1011_PHY_SCR_AUTO_CROSS;
+		break;
+	}
+
+	if (val != reg) {
+		/* Set the new polarity value in the register */
+		err = phy_write(phydev, MII_M1011_PHY_SCR, val);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int marvell_config_aneg(struct phy_device *phydev)
 {
 	int err;
@@ -191,8 +230,7 @@ static int marvell_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_M1011_PHY_SCR,
-			MII_M1011_PHY_SCR_AUTO_CROSS);
+	err = marvell_set_polarity(phydev, phydev->mdix);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 47693a9..84b1fba 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -379,6 +379,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->transceiver = phy_is_internal(phydev) ?
 		XCVR_INTERNAL : XCVR_EXTERNAL;
 	cmd->autoneg = phydev->autoneg;
+	cmd->eth_tp_mdix_ctrl = phydev->mdix;
 
 	return 0;
 }
-- 
1.9.1
