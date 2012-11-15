From: Patrick Trantham <patrick.trantham@fuel7.com>
Subject: [PATCH] net: phy: smsc: Re-enable EDPD mode for LAN87xx
Date: Thu, 15 Nov 2012 13:00:57 -0600
Message-ID: <1353006057-7593-1-git-send-email-patrick.trantham@fuel7.com>
Cc: steve.glendinning@shawell.net, davem@davemloft.net,
	otavio@ossystems.com.br, marex@denx.de, chohnstaedt@innominate.com,
	jkosina@suse.cz, Patrick Trantham <patrick.trantham@fuel7.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fuel7.com ([74.222.0.51]:60728 "EHLO mail.fuel7.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768790Ab2KOTb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 14:31:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch re-enables Energy Detect Power Down (EDPD) mode for the
LAN8710/LAN8720.  EDPD mode was disabled in a previous commit,
(b629820d18fa65cc598390e4b9712fd5f83ee693), because it was causing the
PHY to not be able to detect a link when cold started without a cable
connected.

The LAN8710/LAN8720 requires a minimum of 2 link pulses within 64ms of
each other in order to set the ENERGYON bit and exit EDPD mode.  If a
link partner does send the pulses within this interval, the PHY will
remained powered down.

This workaround will manually toggle the PHY on/off upon calls to
read_status in order to generate link test pulses if the link is down.
If a link partner is present, it will respond to the pulses, which will
cause the ENERGYON bit to be set and will cause the EDPD mode to be
exited.

Signed-off-by: Patrick Trantham <patrick.trantham@fuel7.com>
---
 drivers/net/phy/smsc.c |   73 +++++++++++++++++++++++++++++-------------------
 1 file changed, 45 insertions(+), 28 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 88e3991..16dceed 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -56,37 +56,54 @@ static int smsc_phy_config_init(struct phy_device *phydev)
 	return smsc_phy_ack_interrupt (phydev);
 }
 
-static int lan87xx_config_init(struct phy_device *phydev)
-{
-	/*
-	 * Make sure the EDPWRDOWN bit is NOT set. Setting this bit on
-	 * LAN8710/LAN8720 PHY causes the PHY to misbehave, likely due
-	 * to a bug on the chip.
-	 *
-	 * When the system is powered on with the network cable being
-	 * disconnected all the way until after ifconfig ethX up is
-	 * issued for the LAN port with this PHY, connecting the cable
-	 * afterwards does not cause LINK change detection, while the
-	 * expected behavior is the Link UP being detected.
-	 */
-	int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
-	if (rc < 0)
-		return rc;
-
-	rc &= ~MII_LAN83C185_EDPWRDOWN;
-
-	rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS, rc);
-	if (rc < 0)
-		return rc;
-
-	return smsc_phy_ack_interrupt(phydev);
-}
-
 static int lan911x_config_init(struct phy_device *phydev)
 {
 	return smsc_phy_ack_interrupt(phydev);
 }
 
+/*
+ * The LAN8710/LAN8720 requires a minimum of 2 link pulses within 64ms of each
+ * other in order to set the ENERGYON bit and exit EDPD mode.  If a link partner
+ * does send the pulses within this interval, the PHY will remained powered
+ * down.
+ *
+ * This workaround will manually toggle the PHY on/off upon calls to read_status
+ * in order to generate link test pulses if the link is down.  If a link partner
+ * is present, it will respond to the pulses, which will cause the ENERGYON bit
+ * to be set and will cause the EDPD mode to be exited.
+ */
+static int lan87xx_read_status(struct phy_device *phydev)
+{
+	int err = genphy_read_status(phydev);
+
+	if (!phydev->link) {
+		/* Disable EDPD to wake up PHY */
+		int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+		if (rc < 0)
+			return rc;
+
+		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
+			       rc & ~MII_LAN83C185_EDPWRDOWN);
+		if (rc < 0)
+			return rc;
+
+		/* Sleep 64 ms to allow ~5 link test pulses to be sent */
+		msleep(64);
+
+		/* Re-enable EDPD */
+		rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
+		if (rc < 0)
+			return rc;
+
+		rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
+			       rc | MII_LAN83C185_EDPWRDOWN);
+		if (rc < 0)
+			return rc;
+	}
+
+	return err;
+}
+
 static struct phy_driver smsc_phy_driver[] = {
 {
 	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
@@ -187,8 +204,8 @@ static struct phy_driver smsc_phy_driver[] = {
 
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
-	.config_init	= lan87xx_config_init,
+	.read_status	= lan87xx_read_status,
+	.config_intr	= smsc_phy_config_intr,
 
 	/* IRQ related */
 	.ack_interrupt	= smsc_phy_ack_interrupt,
-- 
1.7.9.5
