From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 14/15] broadcom: Add support for BCM50610
Date: Mon, 3 Nov 2008 04:21:41 -0800
Message-ID: <1225751631.6205@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4905 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697AbYKCWeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:34:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the BCM50610 to the list of phys supported by the
broadcom driver.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/phy/broadcom.c |  119 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 118 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 7e93592..fd4fc66 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -17,6 +17,8 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 
+#define PHY_ID_BCM50610		0x0143bd60
+
 #define MII_BCM54XX_ECR		0x10	/* BCM54xx extended control register */
 #define MII_BCM54XX_ECR_IM	0x1000	/* Interrupt mask */
 #define MII_BCM54XX_ECR_IF	0x0800	/* Interrupt force */
@@ -54,6 +56,21 @@
 #define MII_BCM54XX_SHD_DATA(x)	((x & 0x3ff) << 0)
 
 /*
+ * AUXILIARY CONTROL SHADOW ACCESS REGISTERS.  (PHY REG 0x18)
+ */
+#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
+#define MII_BCM54XX_AUXCTL_ACTL_TX_6DB		0x0400
+#define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
+
+#define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
+#define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
+#define MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC	0x7000
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
+
+#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
+
+
+/*
  * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
  * BCM5482, and possibly some others.
  */
@@ -88,6 +105,24 @@
 #define BCM5482_SHD_MODE_1000BX	0x0001	/* Enable 1000BASE-X registers */
 
 /*
+ * EXPANSION SHADOW ACCESS REGISTERS.  (PHY REG 0x15, 0x16, and 0x17)
+ */
+#define MII_BCM54XX_EXP_AADJ1CH0		0x001f
+#define  MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN	0x0200
+#define  MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF	0x0100
+#define MII_BCM54XX_EXP_AADJ1CH3		0x601f
+#define  MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ	0x0002
+#define MII_BCM54XX_EXP_EXP08			0x0F08
+#define  MII_BCM54XX_EXP_EXP08_RJCT_2MHZ	0x0001
+#define  MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE	0x0200
+#define MII_BCM54XX_EXP_EXP75			0x0f75
+#define  MII_BCM54XX_EXP_EXP75_VDACCTRL		0x003c
+#define MII_BCM54XX_EXP_EXP96			0x0f96
+#define  MII_BCM54XX_EXP_EXP96_MYST		0x0010
+#define MII_BCM54XX_EXP_EXP97			0x0f97
+#define  MII_BCM54XX_EXP_EXP97_MYST		0x0c0c
+
+/*
  * BCM5482: Secondary SerDes registers
  */
 #define BCM5482_SSD_1000BX_CTL		0x00	/* 1000BASE-X Control */
@@ -145,7 +180,7 @@ static int bcm54xx_exp_read(struct phy_device *phydev, u8 regnum)
 	return val;
 }
 
-static int bcm54xx_exp_write(struct phy_device *phydev, u8 regnum, u16 val)
+static int bcm54xx_exp_write(struct phy_device *phydev, u16 regnum, u16 val)
 {
 	int ret;
 
@@ -161,6 +196,60 @@ static int bcm54xx_exp_write(struct phy_device *phydev, u8 regnum, u16 val)
 	return ret;
 }
 
+static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
+{
+	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
+}
+
+static int bcm50610_a0_workaround(struct phy_device *phydev)
+{
+	int err;
+
+	err = bcm54xx_auxctl_write(phydev,
+				   MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
+				   MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA |
+				   MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
+	if (err < 0)
+		return err;
+
+	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP08,
+				MII_BCM54XX_EXP_EXP08_RJCT_2MHZ	|
+				MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE);
+	if (err < 0)
+		goto error;
+
+	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH0,
+				MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN |
+				MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF);
+	if (err < 0)
+		goto error;
+
+	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_AADJ1CH3,
+					MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ);
+	if (err < 0)
+		goto error;
+
+	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP75,
+				MII_BCM54XX_EXP_EXP75_VDACCTRL);
+	if (err < 0)
+		goto error;
+
+	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP96,
+				MII_BCM54XX_EXP_EXP96_MYST);
+	if (err < 0)
+		goto error;
+
+	err = bcm54xx_exp_write(phydev, MII_BCM54XX_EXP_EXP97,
+				MII_BCM54XX_EXP_EXP97_MYST);
+
+error:
+	bcm54xx_auxctl_write(phydev,
+			     MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL,
+			     MII_BCM54XX_AUXCTL_ACTL_TX_6DB);
+
+	return err;
+}
+
 static int bcm54xx_config_init(struct phy_device *phydev)
 {
 	int reg, err;
@@ -182,6 +271,13 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	err = phy_write(phydev, MII_BCM54XX_IMR, reg);
 	if (err < 0)
 		return err;
+
+	if (phydev->drv->phy_id == PHY_ID_BCM50610) {
+		err = bcm50610_a0_workaround(phydev);
+		if (err < 0)
+			return err;
+	}
+
 	return 0;
 }
 
@@ -429,6 +525,21 @@ static struct phy_driver bcm5482_driver = {
 	.driver 	= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcm50610_driver = {
+	.phy_id		= PHY_ID_BCM50610,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM50610",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= bcm54xx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= bcm54xx_ack_interrupt,
+	.config_intr	= bcm54xx_config_intr,
+	.driver 	= { .owner = THIS_MODULE },
+};
+
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -451,8 +562,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm5482_driver);
 	if (ret)
 		goto out_5482;
+	ret = phy_driver_register(&bcm50610_driver);
+	if (ret)
+		goto out_50610;
 	return ret;
 
+out_50610:
+	phy_driver_unregister(&bcm5482_driver);
 out_5482:
 	phy_driver_unregister(&bcm5481_driver);
 out_5481:
@@ -469,6 +585,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcm50610_driver);
 	phy_driver_unregister(&bcm5482_driver);
 	phy_driver_unregister(&bcm5481_driver);
 	phy_driver_unregister(&bcm5464_driver);
-- 
1.5.6.4



