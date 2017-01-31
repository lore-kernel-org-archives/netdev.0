From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] net: phy: broadcom: rehook BCM54612E specific init
Date: Tue, 31 Jan 2017 22:54:54 +0100
Message-ID: <20170131215454.7932-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35678 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdAaVzT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:55:19 -0500
Received: by mail-lf0-f68.google.com with SMTP id v186so35024793lfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 13:55:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

This extra BCM54612E code in PHY driver isn't really aneg specific. Even
without it aneg works OK but the problem is no packets pass through PHY.

Moreover putting this code inside config_aneg callback didn't allow
resuming PHY correctly. When driver called phy_stop and phy_start it was
putting PHY machine into RESUMING state. After that machine was
switching into AN and NOLINK without ever calling phy_start_aneg. This
prevented this extra setup from being called and PHY didn't work.

This change has been verified to fix network on BCM47186B0 SoC device
with BCM54612E.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/phy/broadcom.c | 67 +++++++++++++++++++++++-----------------------
 1 file changed, 33 insertions(+), 34 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 794b9ec81ba5..9cd8b27d1292 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -46,6 +46,34 @@ static int bcm54210e_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm54612e_config_init(struct phy_device *phydev)
+{
+	/* Clear TX internal delay unless requested. */
+	if ((phydev->interface != PHY_INTERFACE_MODE_RGMII_ID) &&
+	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_TXID)) {
+		/* Disable TXD to GTXCLK clock delay (default set) */
+		/* Bit 9 is the only field in shadow register 00011 */
+		bcm_phy_write_shadow(phydev, 0x03, 0);
+	}
+
+	/* Clear RX internal delay unless requested. */
+	if ((phydev->interface != PHY_INTERFACE_MODE_RGMII_ID) &&
+	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_RXID)) {
+		u16 reg;
+
+		reg = bcm54xx_auxctl_read(phydev,
+					  MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
+		/* Disable RXD to RXC delay (default set) */
+		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
+		/* Clear shadow selector field */
+		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MASK;
+		bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
+				     MII_BCM54XX_AUXCTL_MISC_WREN | reg);
+	}
+
+	return 0;
+}
+
 static int bcm54810_config(struct phy_device *phydev)
 {
 	int rc, val;
@@ -250,6 +278,10 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 		err = bcm54210e_config_init(phydev);
 		if (err)
 			return err;
+	} else if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54612E) {
+		err = bcm54612e_config_init(phydev);
+		if (err)
+			return err;
 	} else if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
 		err = bcm54810_config(phydev);
 		if (err)
@@ -395,39 +427,6 @@ static int bcm5481_config_aneg(struct phy_device *phydev)
 	return ret;
 }
 
-static int bcm54612e_config_aneg(struct phy_device *phydev)
-{
-	int ret;
-
-	/* First, auto-negotiate. */
-	ret = genphy_config_aneg(phydev);
-
-	/* Clear TX internal delay unless requested. */
-	if ((phydev->interface != PHY_INTERFACE_MODE_RGMII_ID) &&
-	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_TXID)) {
-		/* Disable TXD to GTXCLK clock delay (default set) */
-		/* Bit 9 is the only field in shadow register 00011 */
-		bcm_phy_write_shadow(phydev, 0x03, 0);
-	}
-
-	/* Clear RX internal delay unless requested. */
-	if ((phydev->interface != PHY_INTERFACE_MODE_RGMII_ID) &&
-	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_RXID)) {
-		u16 reg;
-
-		reg = bcm54xx_auxctl_read(phydev,
-					  MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
-		/* Disable RXD to RXC delay (default set) */
-		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
-		/* Clear shadow selector field */
-		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MASK;
-		bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
-				     MII_BCM54XX_AUXCTL_MISC_WREN | reg);
-	}
-
-	return ret;
-}
-
 static int brcm_phy_setbits(struct phy_device *phydev, int reg, int set)
 {
 	int val;
@@ -590,7 +589,7 @@ static struct phy_driver broadcom_drivers[] = {
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.config_init	= bcm54xx_config_init,
-	.config_aneg	= bcm54612e_config_aneg,
+	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
-- 
2.11.0
