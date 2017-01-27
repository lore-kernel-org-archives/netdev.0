From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 net-next] net: phy: broadcom: add support for BCM54210E
Date: Fri, 27 Jan 2017 14:07:01 +0100
Message-ID: <20170127130701.4191-1-zajec5@gmail.com>
References: <20170127104705.25162-1-zajec5@gmail.com>
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
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34716 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754800AbdA0NHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 08:07:19 -0500
Received: by mail-lf0-f65.google.com with SMTP id q89so26001203lfi.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 05:07:18 -0800 (PST)
In-Reply-To: <20170127104705.25162-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

It's Broadcom PHY simply described as single-port
RGMII 10/100/1000BASE-T PHY. It requires disabling delay skew and GTXCLK
bits.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
V2: Include include/linux/brcmphy.h change I forgot to commit
---
 drivers/net/phy/broadcom.c | 34 +++++++++++++++++++++++++++++++++-
 include/linux/brcmphy.h    |  1 +
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 97d1c057c0a1..794b9ec81ba5 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -30,6 +30,22 @@ MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
 
+static int bcm54210e_config_init(struct phy_device *phydev)
+{
+	int val;
+
+	val = bcm54xx_auxctl_read(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
+	val &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
+	val |= MII_BCM54XX_AUXCTL_MISC_WREN;
+	bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC, val);
+
+	val = bcm_phy_read_shadow(phydev, BCM54810_SHD_CLK_CTL);
+	val &= ~BCM54810_SHD_CLK_CTL_GTXCLK_EN;
+	bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, val);
+
+	return 0;
+}
+
 static int bcm54810_config(struct phy_device *phydev)
 {
 	int rc, val;
@@ -230,7 +246,11 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
 		bcm54xx_adjust_rxrefclk(phydev);
 
-	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
+	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54210E) {
+		err = bcm54210e_config_init(phydev);
+		if (err)
+			return err;
+	} else if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
 		err = bcm54810_config(phydev);
 		if (err)
 			return err;
@@ -542,6 +562,17 @@ static struct phy_driver broadcom_drivers[] = {
 	.ack_interrupt	= bcm_phy_ack_intr,
 	.config_intr	= bcm_phy_config_intr,
 }, {
+	.phy_id		= PHY_ID_BCM54210E,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM54210E",
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm_phy_ack_intr,
+	.config_intr	= bcm_phy_config_intr,
+}, {
 	.phy_id		= PHY_ID_BCM5461,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM5461",
@@ -680,6 +711,7 @@ module_phy_driver(broadcom_drivers);
 static struct mdio_device_id __maybe_unused broadcom_tbl[] = {
 	{ PHY_ID_BCM5411, 0xfffffff0 },
 	{ PHY_ID_BCM5421, 0xfffffff0 },
+	{ PHY_ID_BCM54210E, 0xfffffff0 },
 	{ PHY_ID_BCM5461, 0xfffffff0 },
 	{ PHY_ID_BCM54612E, 0xfffffff0 },
 	{ PHY_ID_BCM54616S, 0xfffffff0 },
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index cf93f1399d3e..5881d1fdc1fb 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -17,6 +17,7 @@
 #define PHY_ID_BCM5482			0x0143bcb0
 #define PHY_ID_BCM5411			0x00206070
 #define PHY_ID_BCM5421			0x002060e0
+#define PHY_ID_BCM54210E		0x600d84a0
 #define PHY_ID_BCM5464			0x002060b0
 #define PHY_ID_BCM5461			0x002060c0
 #define PHY_ID_BCM54612E		0x03625e60
-- 
2.11.0
