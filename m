From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: [PATCH] phy: marvell: Fix reg-init bug on 88E1510
Date: Sun, 14 Feb 2016 21:31:25 +0100
Message-ID: <1455481885-11395-1-git-send-email-clemens.gruber@pqgruber.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function marvell_of_reg_init was called too late, in
m88e1510_config_aneg. This function was not reached, due to the phy
state machine being stuck at waiting for interrupts (which were not
enabled and off by default on the 88E1510)
It lead to the ethernet link not coming up at boot.

This commit moves the call of marvell_of_reg_init to config_init.
Now, a marvell,reg-init option to enable PHY interrupts on pin LED[2] is
set early on and the phy state machine does not get stuck anymore.
Tested on i.MX6Q boards with Marvell 88E1510 PHYs.

Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>
---
 drivers/net/phy/marvell.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index e3eb964..c6ef2da 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -446,7 +446,7 @@ static int m88e1510_config_aneg(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	return marvell_of_reg_init(phydev);
+	return 0;
 }
 
 static int m88e1116r_config_init(struct phy_device *phydev)
@@ -788,6 +788,17 @@ static int m88e1145_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int m88e1510_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	err = marvell_of_reg_init(phydev);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
 /* marvell_read_status
  *
  * Generic status code does not detect Fiber correctly!
@@ -1259,6 +1270,7 @@ static struct phy_driver marvell_drivers[] = {
 		.features = PHY_GBIT_FEATURES,
 		.flags = PHY_HAS_INTERRUPT,
 		.probe = marvell_probe,
+		.config_init = &m88e1510_config_init,
 		.config_aneg = &m88e1510_config_aneg,
 		.read_status = &marvell_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
-- 
2.7.1
