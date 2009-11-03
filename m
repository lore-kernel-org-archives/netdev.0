From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/20] broadcom: Isolate phy dsp accesses
Date: Mon, 2 Nov 2009 16:28:04 -0800
Message-ID: <1257212001.22013@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1518 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757601AbZKCBd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch consolidates the code that requires the SMDSP clock to be
enabled into a single function that (hopefully) makes the dependency
obvious.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |   90 ++++++++++++++++++++-----------------------
 1 files changed, 42 insertions(+), 48 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f81e532..9e574ce 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -237,53 +237,78 @@ static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
 	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
 }
 
+/* Needs SMDSP clock enabled via bcm54xx_phydsp_config() */
 static int bcm50610_a0_workaround(struct phy_device *phydev)
 {
 	int err;
 
-	err = bcm54xx_auxctl_write(phydev,
-				   MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
-				   MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA |
-				   MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
-	if (err < 0)
-		return err;
-
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP08,
 				MII_BCM54XX_EXP_EXP08_RJCT_2MHZ	|
 				MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE);
 	if (err < 0)
-		goto error;
+		return err;
 
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH0,
 				MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN |
 				MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF);
 	if (err < 0)
-		goto error;
+		return err;
 
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH3,
 					MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ);
 	if (err < 0)
-		goto error;
+		return err;
 
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75,
 				MII_BCM54XX_EXP_EXP75_VDACCTRL);
 	if (err < 0)
-		goto error;
+		return err;
 
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP96,
 				MII_BCM54XX_EXP_EXP96_MYST);
 	if (err < 0)
-		goto error;
+		return err;
 
 	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP97,
 				MII_BCM54XX_EXP_EXP97_MYST);
 
+	return err;
+}
+
+static int bcm54xx_phydsp_config(struct phy_device *phydev)
+{
+	int err, err2;
+
+	/* Enable the SMDSP clock */
+	err = bcm54xx_auxctl_write(phydev,
+				   MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
+				   MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA |
+				   MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
+	if (err < 0)
+		return err;
+
+	if (phydev->drv->phy_id == PHY_ID_BCM50610)
+		err = bcm50610_a0_workaround(phydev);
+
+	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM57780) {
+		int val;
+
+		val = bcm54xx_exp_read(phydev, MII_BCM54XX_EXP_EXP75);
+		if (val < 0)
+			goto error;
+
+		val |= MII_BCM54XX_EXP_EXP75_CM_OSC;
+		err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75, val);
+	}
+
 error:
-	bcm54xx_auxctl_write(phydev,
-			     MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
-			     MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
+	/* Disable the SMDSP clock */
+	err2 = bcm54xx_auxctl_write(phydev,
+				    MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
+				    MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
 
-	return err;
+	/* Return the first error reported. */
+	return err ? err : err2;
 }
 
 static int bcm54xx_config_init(struct phy_device *phydev)
@@ -308,38 +333,7 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	if (phydev->drv->phy_id == PHY_ID_BCM50610) {
-		err = bcm50610_a0_workaround(phydev);
-		if (err < 0)
-			return err;
-	}
-
-	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM57780) {
-		int err2;
-
-		err = bcm54xx_auxctl_write(phydev,
-					   MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
-					   MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA |
-					   MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
-		if (err < 0)
-			return err;
-
-		reg = bcm54xx_exp_read(phydev, MII_BCM54XX_EXP_EXP75);
-		if (reg < 0)
-			goto error;
-
-		reg |= MII_BCM54XX_EXP_EXP75_CM_OSC;
-		err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75, reg);
-
-error:
-		err2 = bcm54xx_auxctl_write(phydev,
-					    MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
-					    MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
-		if (err)
-			return err;
-		if (err2)
-			return err2;
-	}
+	bcm54xx_phydsp_config(phydev);
 
 	return 0;
 }
-- 
1.6.4.4


