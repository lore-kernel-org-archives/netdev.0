From: Igor Plyatov <plyatov@gmail.com>
Subject: [PATCH v3] net: phy: workaround for buggy cable detection by LAN8700 after cable plugging
Date: Fri, 14 Aug 2015 20:11:02 +0300
Message-ID: <1439572262-10705-1-git-send-email-plyatov@gmail.com>
Cc: Igor Plyatov <plyatov@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, joe@perches.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@KARO-electronics.de, Frank.Li@freescale.com, mhei@heimpold.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:34689 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339AbbHNRLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 13:11:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
  Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
  set, the ENERGYON bit does not asserted sometimes). This is a common bug of
  LAN87xx family of PHY chips.
* The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
  algorythm still not reliable on 100 % and sometimes skip cable plugging.

Signed-off-by: Igor Plyatov <plyatov@gmail.com>
---
 drivers/net/phy/smsc.c |   31 +++++++++++++++++++------------
 1 file changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index c0f6479..d64f016 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -91,19 +91,18 @@ static int lan911x_config_init(struct phy_device *phydev)
 }
 
 /*
- * The LAN8710/LAN8720 requires a minimum of 2 link pulses within 64ms of each
- * other in order to set the ENERGYON bit and exit EDPD mode.  If a link partner
- * does send the pulses within this interval, the PHY will remained powered
- * down.
- *
- * This workaround will manually toggle the PHY on/off upon calls to read_status
- * in order to generate link test pulses if the link is down.  If a link partner
- * is present, it will respond to the pulses, which will cause the ENERGYON bit
- * to be set and will cause the EDPD mode to be exited.
+ * The LAN87xx suffers from rare absence of the ENERGYON-bit when Ethernet cable
+ * plugs in while LAN87xx is in Energy Detect Power-Down mode. This leads to
+ * unstable detection of plugging in Ethernet cable.
+ * This workaround disables Energy Detect Power-Down mode and waiting for
+ * response on link pulses to detect presence of plugged Ethernet cable.
+ * The Energy Detect Power-Down mode is enabled again in the end of procedure to
+ * save approximately 220 mW of power if cable is unplugged.
  */
 static int lan87xx_read_status(struct phy_device *phydev)
 {
 	int err = genphy_read_status(phydev);
+	int i;
 
 	if (!phydev->link) {
 		/* Disable EDPD to wake up PHY */
@@ -116,8 +115,16 @@ static int lan87xx_read_status(struct phy_device *phydev)
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
@@ -191,7 +198,7 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
+	.read_status	= lan87xx_read_status,
 	.config_init	= smsc_phy_config_init,
 	.soft_reset	= smsc_phy_reset,
 
-- 
1.7.9.5
