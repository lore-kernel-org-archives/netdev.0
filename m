From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 18:52:59 +0100
Message-ID: <1455558779-15953-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the Marvell 88E1510, marvell_of_reg_init was called too late (in
m88e1510_config_aneg), which lead to the phy state machine being stuck
at waiting for interrupts, which are off by default on the 88E1510.
This further lead to the ethernet link not coming up at boot.
For some Marvell PHYs, marvell_of_reg_init was not called at all.

Add a generic marvell_config_init function, which in turn calls
marvell_of_reg_init and resets the PHY, to get more consistent behavior
across all Marvell PHYs.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---
 drivers/net/phy/marvell.c | 65 +++++++++++++++++++++++------------------------
 1 file changed, 32 insertions(+), 33 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e3eb964..473beaa 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -153,6 +153,8 @@ struct marvell_priv {
 	u64 stats[ARRAY_SIZE(marvell_hw_stats)];
 };
 
+static int marvell_of_reg_init(struct phy_device *phydev);
+
 static int marvell_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -215,6 +217,24 @@ static int marvell_set_polarity(struct phy_device *phydev, int polarity)
 	return 0;
 }
 
+static int marvell_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	/* Set page to 0 */
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0);
+	if (err < 0)
+		return err;
+
+	/* Set registers from marvell,reg-init DT property */
+	err = marvell_of_reg_init(phydev);
+	if (err < 0)
+		return err;
+
+	/* Reset the PHY (The page is 0 already) */
+	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+}
+
 static int marvell_config_aneg(struct phy_device *phydev)
 {
 	int err;
@@ -446,7 +466,7 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	return marvell_of_reg_init(phydev);
+	return 0;
 }
 
 static int m88e1116r_config_init(struct phy_device *phydev)
@@ -495,7 +515,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 
 	mdelay(500);
 
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 static int m88e3016_config_init(struct phy_device *phydev)
@@ -514,7 +534,7 @@ static int m88e3016_config_init(struct phy_device *phydev)
 	if (reg < 0)
 		return reg;
 
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 static int m88e1111_config_init(struct phy_device *phydev)
@@ -618,11 +638,7 @@ static int m88e1111_config_init(struct phy_device *phydev)
 			return err;
 	}
 
-	err = marvell_of_reg_init(phydev);
-	if (err < 0)
-		return err;
-
-	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+	return marvell_config_init(phydev);
 }
 
 static int m88e1118_config_aneg(struct phy_device *phydev)
@@ -669,16 +685,7 @@ static int m88e1118_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = marvell_of_reg_init(phydev);
-	if (err < 0)
-		return err;
-
-	/* Reset address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0);
-	if (err < 0)
-		return err;
-
-	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+	return marvell_config_init(phydev);
 }
 
 static int m88e1149_config_init(struct phy_device *phydev)
@@ -695,16 +702,7 @@ static int m88e1149_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = marvell_of_reg_init(phydev);
-	if (err < 0)
-		return err;
-
-	/* Reset address */
-	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0x0);
-	if (err < 0)
-		return err;
-
-	return phy_write(phydev, MII_BMCR, BMCR_RESET);
+	return marvell_config_init(phydev);
 }
 
 static int m88e1145_config_init(struct phy_device *phydev)
@@ -781,11 +779,7 @@ static int m88e1145_config_init(struct phy_device *phydev)
 			return err;
 	}
 
-	err = marvell_of_reg_init(phydev);
-	if (err < 0)
-		return err;
-
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 /* marvell_read_status
@@ -1078,6 +1072,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.probe = marvell_probe,
 		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &marvell_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1149,6 +1144,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1167,6 +1163,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1318_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1259,6 +1256,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1277,6 +1275,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
-- 
2.7.1
