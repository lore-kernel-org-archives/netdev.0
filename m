From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH v2] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 21:01:00 +0100
Message-ID: <1455566460-31291-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the Marvell 88E1510, marvell_of_reg_init was called too late, in the
config_aneg function.
Since commit 113c74d83eef ("net: phy: turn carrier off on phy attach"),
this lead to the link not coming up at boot anymore, due to the phy
state machine being stuck at waiting for interrupts (off by default on
the 88E1510).
For seven other Marvell PHYs, marvell_of_reg_init was not called at all.

Add a generic marvell_config_init function, which in turn calls
marvell_of_reg_init.
PHYs, which already have a specific config_init function with a call to
marvell_of_reg_init, are left untouched. The generic marvell_config_init
function is called for all the others, to get consistent behavior across
all Marvell PHYs.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---

Changes since v1:
- No longer touch the PHYs that already call marvell_of_reg_init
- No more reset in marvell_config_init.
- Moved the function block to avoid a predeclaration

---
 drivers/net/phy/marvell.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e3eb964..bfef5d1 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -446,7 +446,19 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	return marvell_of_reg_init(phydev);
+	return 0;
+}
+
+static int marvell_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	/* Set registers from marvell,reg-init DT property */
+	err = marvell_of_reg_init(phydev);
+	if (err < 0)
+		return err;
+
+	return 0;
 }
 
 static int m88e1116r_config_init(struct phy_device *phydev)
@@ -495,7 +507,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 
 	mdelay(500);
 
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 static int m88e3016_config_init(struct phy_device *phydev)
@@ -514,7 +526,7 @@ static int m88e3016_config_init(struct phy_device *phydev)
 	if (reg < 0)
 		return reg;
 
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 static int m88e1111_config_init(struct phy_device *phydev)
@@ -1078,6 +1090,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.probe = marvell_probe,
 		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &marvell_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1149,6 +1162,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1167,6 +1181,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1318_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1259,6 +1274,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1277,6 +1293,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
-- 
2.7.1
