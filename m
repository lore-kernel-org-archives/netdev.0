From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/12] broadcom: Make the 57780 IEEE compliant
Date: Tue, 25 Aug 2009 13:11:26 -0700
Message-ID: <1251232430.25419@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4230 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756068AbZHYUeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This brings the 57780's phy into IEEE compliance by suppressing the
common mode oscillation.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/phy/broadcom.c |   37 +++++++++++++++++++++++++++++++++++--
 1 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 3262a24..f81e532 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -19,6 +19,11 @@
 
 #define PHY_ID_BCM50610		0x0143bd60
 #define PHY_ID_BCM50610M	0x0143bd70
+#define PHY_ID_BCM57780		0x03625d90
+
+#define BRCM_PHY_MODEL(phydev) \
+	((phydev)->drv->phy_id & (phydev)->drv->phy_id_mask)
+
 
 #define MII_BCM54XX_ECR		0x10	/* BCM54xx extended control register */
 #define MII_BCM54XX_ECR_IM	0x1000	/* Interrupt mask */
@@ -118,6 +123,7 @@
 #define  MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE	0x0200
 #define MII_BCM54XX_EXP_EXP75			0x0f75
 #define  MII_BCM54XX_EXP_EXP75_VDACCTRL		0x003c
+#define  MII_BCM54XX_EXP_EXP75_CM_OSC		0x0001
 #define MII_BCM54XX_EXP_EXP96			0x0f96
 #define  MII_BCM54XX_EXP_EXP96_MYST		0x0010
 #define MII_BCM54XX_EXP_EXP97			0x0f97
@@ -194,7 +200,7 @@ static int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow, u16 val)
 }
 
 /* Indirect register access functions for the Expansion Registers */
-static int bcm54xx_exp_read(struct phy_device *phydev, u8 regnum)
+static int bcm54xx_exp_read(struct phy_device *phydev, u16 regnum)
 {
 	int val;
 
@@ -308,6 +314,33 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 			return err;
 	}
 
+	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM57780) {
+		int err2;
+
+		err = bcm54xx_auxctl_write(phydev,
+					   MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
+					   MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA |
+					   MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
+		if (err < 0)
+			return err;
+
+		reg = bcm54xx_exp_read(phydev, MII_BCM54XX_EXP_EXP75);
+		if (reg < 0)
+			goto error;
+
+		reg |= MII_BCM54XX_EXP_EXP75_CM_OSC;
+		err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75, reg);
+
+error:
+		err2 = bcm54xx_auxctl_write(phydev,
+					    MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
+					    MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
+		if (err)
+			return err;
+		if (err2)
+			return err2;
+	}
+
 	return 0;
 }
 
@@ -694,7 +727,7 @@ static struct phy_driver bcm50610m_driver = {
 };
 
 static struct phy_driver bcm57780_driver = {
-	.phy_id		= 0x03625d90,
+	.phy_id		= PHY_ID_BCM57780,
 	.phy_id_mask	= 0xfffffff0,
 	.name		= "Broadcom BCM57780",
 	.features	= PHY_GBIT_FEATURES |
-- 
1.6.3.3


