From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH] RFC: Broadcom PHY forcing fix
Date: Thu, 25 Jan 2007 17:22:11 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0701251718270.4944@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarizk@kernel.crashing.org, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43286 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030244AbXAYXYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 18:24:16 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej,

I've got a BCM5461 that requires this fix to be able to force the speeds 
on the PHY.  Not sure if its needed on the other variants or not.  The 
problem is the genphy_config_aneg resets the PHY when forcing the speed 
and once we reset the BCM5461 it doesn't remember any of its settings.

Let me know if this works for you or not.

- k

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 29666c8..bf752f4 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -99,6 +99,61 @@ static int bcm54xx_config_intr(struct ph
 	return err;
 }
 
+/* bcm_setup_forced
+ *
+ * description: Configures MII_BMCR to force speed/duplex
+ *   to the values in phydev. Assumes that the values are valid.
+ *   Please see phy_sanitize_settings() */
+static int bcm54xx_setup_forced(struct phy_device *phydev)
+{
+	int ctl = 0;
+	phydev->pause = phydev->asym_pause = 0;
+
+	if (SPEED_100 == phydev->speed)
+		ctl |= BMCR_SPEED100;
+
+	if (DUPLEX_FULL == phydev->duplex)
+		ctl |= BMCR_FULLDPLX;
+	
+	ctl = phy_write(phydev, MII_BMCR, ctl);
+
+	if (ctl < 0)
+		return ctl;
+
+	return ctl;
+}
+
+int bcm54xx_config_aneg(struct phy_device *phydev)
+{
+	int err = 0;
+
+	if (AUTONEG_ENABLE == phydev->autoneg) {
+		err = genphy_config_advert(phydev);
+
+		if (err < 0)
+			return err;
+
+		err = genphy_restart_aneg(phydev);
+	} else {
+		if (SPEED_1000 == phydev->speed) {
+			int adv;
+			adv = phy_read(phydev, MII_ADVERTISE);
+			adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+
+			err = phy_write(phydev, MII_ADVERTISE, adv);
+
+			if (err < 0)
+				return err;
+
+			err = genphy_restart_aneg(phydev);
+		} else {
+			err = bcm54xx_setup_forced(phydev);
+		}
+	}
+
+	return err;
+}
+
 static struct phy_driver bcm5411_driver = {
 	.phy_id		= 0x00206070,
 	.phy_id_mask	= 0xfffffff0,
@@ -106,7 +161,7 @@ static struct phy_driver bcm5411_driver 
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
+	.config_aneg	= bcm54xx_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -120,7 +175,7 @@ static struct phy_driver bcm5421_driver 
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
+	.config_aneg	= bcm54xx_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
@@ -134,7 +189,7 @@ static struct phy_driver bcm5461_driver 
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= genphy_config_aneg,
+	.config_aneg	= bcm54xx_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
