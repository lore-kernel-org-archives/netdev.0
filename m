From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 13/15] broadcom: Refine expansion register access
 routine
Date: Mon, 3 Nov 2008 02:27:58 -0800
Message-ID: <1225751630.6202@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4898 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698AbYKCWeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:34:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the expansion register access routines a little more
formal.  They will be used by the following bcm50610 support patch.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |   60 +++++++++++++++++++++++++-------------------
 1 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 0fe3749..7e93592 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -128,36 +128,35 @@ static int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow, u16 val)
 			 MII_BCM54XX_SHD_DATA(val));
 }
 
-/*
- * Indirect register access functions for the Expansion Registers
- * and Secondary SerDes registers (when sec_serdes=1).
- */
-static int bcm54xx_exp_read(struct phy_device *phydev,
-			    int sec_serdes, u8 regnum)
+/* Indirect register access functions for the Expansion Registers */
+static int bcm54xx_exp_read(struct phy_device *phydev, u8 regnum)
 {
 	int val;
 
-	phy_write(phydev, MII_BCM54XX_EXP_SEL,
-		  (sec_serdes ? MII_BCM54XX_EXP_SEL_SSD :
-				MII_BCM54XX_EXP_SEL_ER) |
-		  regnum);
+	val = phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+	if (val < 0)
+		return val;
+
 	val = phy_read(phydev, MII_BCM54XX_EXP_DATA);
-	phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+
+	/* Restore default value.  It's O.K. if this write fails. */
+	phy_write(phydev, MII_BCM54XX_EXP_SEL, 0);
 
 	return val;
 }
 
-static int bcm54xx_exp_write(struct phy_device *phydev,
-			     int sec_serdes, u8 regnum, u16 val)
+static int bcm54xx_exp_write(struct phy_device *phydev, u8 regnum, u16 val)
 {
 	int ret;
 
-	phy_write(phydev, MII_BCM54XX_EXP_SEL,
-		  (sec_serdes ? MII_BCM54XX_EXP_SEL_SSD :
-				MII_BCM54XX_EXP_SEL_ER) |
-		  regnum);
+	ret = phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+	if (ret < 0)
+		return ret;
+
 	ret = phy_write(phydev, MII_BCM54XX_EXP_DATA, val);
-	phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+
+	/* Restore default value.  It's O.K. if this write fails. */
+	phy_write(phydev, MII_BCM54XX_EXP_SEL, 0);
 
 	return ret;
 }
@@ -205,18 +204,27 @@ static int bcm5482_config_init(struct phy_device *phydev)
 		/*
 		 * Enable SGMII slave mode and auto-detection
 		 */
-		reg = bcm54xx_exp_read(phydev, 1, BCM5482_SSD_SGMII_SLAVE);
-		bcm54xx_exp_write(phydev, 1, BCM5482_SSD_SGMII_SLAVE,
-				  reg |
-				  BCM5482_SSD_SGMII_SLAVE_EN |
-				  BCM5482_SSD_SGMII_SLAVE_AD);
+		reg = BCM5482_SSD_SGMII_SLAVE | MII_BCM54XX_EXP_SEL_SSD;
+		err = bcm54xx_exp_read(phydev, reg);
+		if (err < 0)
+			return err;
+		err = bcm54xx_exp_write(phydev, reg, err |
+					BCM5482_SSD_SGMII_SLAVE_EN |
+					BCM5482_SSD_SGMII_SLAVE_AD);
+		if (err < 0)
+			return err;
 
 		/*
 		 * Disable secondary SerDes powerdown
 		 */
-		reg = bcm54xx_exp_read(phydev, 1, BCM5482_SSD_1000BX_CTL);
-		bcm54xx_exp_write(phydev, 1, BCM5482_SSD_1000BX_CTL,
-				  reg & ~BCM5482_SSD_1000BX_CTL_PWRDOWN);
+		reg = BCM5482_SSD_1000BX_CTL | MII_BCM54XX_EXP_SEL_SSD;
+		err = bcm54xx_exp_read(phydev, reg);
+		if (err < 0)
+			return err;
+		err = bcm54xx_exp_write(phydev, reg,
+					err & ~BCM5482_SSD_1000BX_CTL_PWRDOWN);
+		if (err < 0)
+			return err;
 
 		/*
 		 * Select 1000BASE-X register set (primary SerDes)
-- 
1.5.6.4



