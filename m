From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH v3] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 23:46:45 +0100
Message-ID: <1455576405-16263-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Fabio Estevam <festevam@gmail.com>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pqgruber.com ([178.189.19.235]:35861 "EHLO
	mail.pqgruber.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbcBOWrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 17:47:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Changes from v2:
- Simplified marvell_config_init (No preemptive error handling)

---
 drivers/net/phy/marvell.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e3eb964..ab1d0fc 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -446,6 +446,12 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
+	return 0;
+}
+
+static int marvell_config_init(struct phy_device *phydev)
+{
+	/* Set registers from marvell,reg-init DT property */
 	return marvell_of_reg_init(phydev);
 }
 
@@ -495,7 +501,7 @@ static int m88e1116r_config_init(struct phy_device *phydev)
 
 	mdelay(500);
 
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 static int m88e3016_config_init(struct phy_device *phydev)
@@ -514,7 +520,7 @@ static int m88e3016_config_init(struct phy_device *phydev)
 	if (reg < 0)
 		return reg;
 
-	return 0;
+	return marvell_config_init(phydev);
 }
 
 static int m88e1111_config_init(struct phy_device *phydev)
@@ -1078,6 +1084,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.probe = marvell_probe,
 		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &marvell_config_init,
 		.config_aneg = &marvell_config_aneg,
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1149,6 +1156,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1121_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1167,6 +1175,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1318_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1259,6 +1268,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
@@ -1277,6 +1287,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &marvell_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
-- 
2.7.1
