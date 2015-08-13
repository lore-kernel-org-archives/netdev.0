From: Igor Plyatov <plyatov@gmail.com>
Subject: [PATCH] net: phy: workaround for buggy cable detection by LAN8700 after cable plugging
Date: Thu, 13 Aug 2015 16:12:36 +0300
Message-ID: <1439471556-13760-1-git-send-email-plyatov@gmail.com>
Cc: Igor Plyatov <plyatov@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, joe@perches.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@KARO-electronics.de, Frank.Li@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
  Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
  set, the ENERGYON bit does not asserted sometimes). This is a common bug of
  LAN87xx family of PHY chips.
* The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
  algorythm still not reliable on 100 % and sometimes skip cable plugging.

Signed-off-by: Igor Plyatov <plyatov@gmail.com>
---
 drivers/net/phy/smsc.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index c0f6479..a380958 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -104,10 +104,12 @@ static int lan911x_config_init(struct phy_device *phydev)
 static int lan87xx_read_status(struct phy_device *phydev)
 {
 	int err = genphy_read_status(phydev);
+	int rc;
+	int i;
 
 	if (!phydev->link) {
 		/* Disable EDPD to wake up PHY */
-		int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+		rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
 		if (rc < 0)
 			return rc;
 
@@ -116,8 +118,16 @@ static int lan87xx_read_status(struct phy_device *phydev)
 		if (rc < 0)
 			return rc;
 
-		/* Sleep 64 ms to allow ~5 link test pulses to be sent */
-		msleep(64);
+		/* Wait max 640 ms to detect energy */
+		for (i = 0; i < 64; i++) {
+			/* Sleep to allow link test pulses to be sent */
+			msleep(10);
+			rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+			if (rc < 0)
+				return rc;
+			if (rc & MII_LAN83C185_ENERGYON)
+				break;
+		};
 
 		/* Re-enable EDPD */
 		rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
@@ -191,7 +201,7 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
+	.read_status	= lan87xx_read_status,
 	.config_init	= smsc_phy_config_init,
 	.soft_reset	= smsc_phy_reset,
 
-- 
1.7.9.5
