From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 18/20] tg3 / broadcom: Add APD support for GPHYs
Date: Mon, 2 Nov 2009 16:32:12 -0800
Message-ID: <1257212009.22034@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1278 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932399AbZKCBdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an RXC auto power-down feature to the code that supports
the gphys.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |   51 ++++++++++++++++++++++++++++++++++++-------
 drivers/net/tg3.c          |    4 ++-
 2 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 7491433..7b10495 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -107,6 +107,11 @@
 /* 00101: Spare Control Register 3 */
 #define BCM54XX_SHD_SCR3		0x05
 #define  BCM54XX_SHD_SCR3_DEF_CLK125	0x0001
+#define  BCM54XX_SHD_SCR3_DLLAPD_DIS	0x0002
+
+/* 01010: Auto Power-Down */
+#define BCM54XX_SHD_APD			0x0a
+#define  BCM54XX_SHD_APD_EN		0x0020
 
 #define BCM5482_SHD_LEDS1	0x0d	/* 01101: LED Selector 1 */
 					/* LED3 / ~LINKSPD[2] selector */
@@ -321,9 +326,11 @@ error:
 static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 {
 	u32 val, orig;
+	bool clk125en = true;
 
 	/* Abort if we are using an untested phy. */
-	if (BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610 ||
+	if (BRCM_PHY_MODEL(phydev) != PHY_ID_BCM57780 ||
+	    BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610 ||
 	    BRCM_PHY_MODEL(phydev) != PHY_ID_BCM50610M)
 		return;
 
@@ -333,20 +340,45 @@ static void bcm54xx_adjust_rxrefclk(struct phy_device *phydev)
 
 	orig = val;
 
-	if (phydev->dev_flags & PHY_BRCM_RX_REFCLK_UNUSED) {
-		if ((BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610 ||
-		     BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610M) &&
-		    BRCM_PHY_REV(phydev) >= 0x3) {
-			/* Here, bit 0 _disables_ CLK125 when set */
-			val |= BCM54XX_SHD_SCR3_DEF_CLK125;
-		} else {
+	if ((BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610 ||
+	     BRCM_PHY_MODEL(phydev) == PHY_ID_BCM50610M) &&
+	    BRCM_PHY_REV(phydev) >= 0x3) {
+		/*
+		 * Here, bit 0 _disables_ CLK125 when set.
+		 * This bit is set by default.
+		 */
+		clk125en = false;
+	} else {
+		if (phydev->dev_flags & PHY_BRCM_RX_REFCLK_UNUSED) {
 			/* Here, bit 0 _enables_ CLK125 when set */
 			val &= ~BCM54XX_SHD_SCR3_DEF_CLK125;
+			clk125en = false;
 		}
 	}
 
+	if (clk125en == false ||
+	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
+		val &= ~BCM54XX_SHD_SCR3_DLLAPD_DIS;
+	else
+		val |= BCM54XX_SHD_SCR3_DLLAPD_DIS;
+
 	if (orig != val)
 		bcm54xx_shadow_write(phydev, BCM54XX_SHD_SCR3, val);
+
+	val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_APD);
+	if (val < 0)
+		return;
+
+	orig = val;
+
+	if (clk125en == false ||
+	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
+		val |= BCM54XX_SHD_APD_EN;
+	else
+		val &= ~BCM54XX_SHD_APD_EN;
+
+	if (orig != val)
+		bcm54xx_shadow_write(phydev, BCM54XX_SHD_APD, val);
 }
 
 static int bcm54xx_config_init(struct phy_device *phydev)
@@ -376,7 +408,8 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	    (phydev->dev_flags & PHY_BRCM_CLEAR_RGMII_MODE))
 		bcm54xx_shadow_write(phydev, BCM54XX_SHD_RGMII_MODE, 0);
 
-	if (phydev->dev_flags & PHY_BRCM_RX_REFCLK_UNUSED)
+	if ((phydev->dev_flags & PHY_BRCM_RX_REFCLK_UNUSED) ||
+	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
 		bcm54xx_adjust_rxrefclk(phydev);
 
 	bcm54xx_phydsp_config(phydev);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 369ddba..f74bf91 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1097,11 +1097,13 @@ static int tg3_mdio_init(struct tg3 *tp)
 	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
 	case TG3_PHY_ID_BCM57780:
 		phydev->interface = PHY_INTERFACE_MODE_GMII;
+		phydev->dev_flags |= PHY_BRCM_AUTO_PWRDWN_ENABLE;
 		break;
 	case TG3_PHY_ID_BCM50610:
 	case TG3_PHY_ID_BCM50610M:
 		phydev->dev_flags |= PHY_BRCM_CLEAR_RGMII_MODE |
-				     PHY_BRCM_RX_REFCLK_UNUSED;
+				     PHY_BRCM_RX_REFCLK_UNUSED |
+				     PHY_BRCM_AUTO_PWRDWN_ENABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
-- 
1.6.4.4


