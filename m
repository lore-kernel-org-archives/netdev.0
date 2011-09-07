From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] net/phy: add IC+ IP101A and support APS.
Date: Wed,  7 Sep 2011 08:14:50 +0200
Message-ID: <1315376090-17081-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:50713 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754318Ab1IGGPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2011 02:15:04 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C74132A8
	for <netdev@vger.kernel.org>; Wed,  7 Sep 2011 06:14:58 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5C0E31738
	for <netdev@vger.kernel.org>; Wed,  7 Sep 2011 06:14:58 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the IC+ IP101A Single port 10/100 PHY
and supports the APS (i.e. power saving mode while link is down)
for both IP1001 and IP101A (where this mode is supported).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   79 +++++++++++++++++++++++++++++++++++++++------
 1 files changed, 68 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index d4cbc29..6e344e5 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -30,10 +30,17 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-MODULE_DESCRIPTION("ICPlus IP175C/IC1001 PHY drivers");
+MODULE_DESCRIPTION("ICPlus IP175C/IP101A/IC1001 PHY drivers");
 MODULE_AUTHOR("Michael Barkowski");
 MODULE_LICENSE("GPL");
 
+/* IP101A/IP1001 */
+#define IP10XX_SPEC_CTRL_STATUS		16  /* Spec. Control Register */
+#define IP1001_SPEC_CTRL_STATUS_2	20  /* IP1001 Spec. Control Reg 2 */
+#define IP1001_PHASE_SEL_MASK		3 /* IP1001 RX/TXPHASE_SEL */
+#define IP1001_APS_ON			11  /* IP1001 APS Mode  bit */
+#define IP101A_APS_ON			2   /* IP101A APS Mode bit */
+
 static int ip175c_config_init(struct phy_device *phydev)
 {
 	int err, i;
@@ -89,27 +96,58 @@ static int ip175c_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static int ip1001_config_init(struct phy_device *phydev)
+static int ip1xx_reset(struct phy_device *phydev)
 {
-	int err, value;
+	int err, bmcr;
 
 	/* Software Reset PHY */
-	value = phy_read(phydev, MII_BMCR);
-	value |= BMCR_RESET;
-	err = phy_write(phydev, MII_BMCR, value);
+	bmcr = phy_read(phydev, MII_BMCR);
+	bmcr |= BMCR_RESET;
+	err = phy_write(phydev, MII_BMCR, bmcr);
 	if (err < 0)
 		return err;
 
 	do {
-		value = phy_read(phydev, MII_BMCR);
-	} while (value & BMCR_RESET);
+		bmcr = phy_read(phydev, MII_BMCR);
+	} while (bmcr & BMCR_RESET);
+
+	return err;
+}
+
+static int ip1001_config_init(struct phy_device *phydev)
+{
+	int c;
+
+	c = ip1xx_reset(phydev);
+	if (c < 0)
+		return c;
+
+	/* Enable Auto Power Saving mode */
+	c = phy_read(phydev, IP1001_SPEC_CTRL_STATUS_2);
+	c |= IP1001_APS_ON;
+	if (c < 0)
+		return c;
 
 	/* Additional delay (2ns) used to adjust RX clock phase
 	 * at GMII/ RGMII interface */
-	value = phy_read(phydev, 16);
-	value |= 0x3;
+	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
+	c |= IP1001_PHASE_SEL_MASK;
+
+	return phy_write(phydev, IP10XX_SPEC_CTRL_STATUS, c);
+}
+
+static int ip101a_config_init(struct phy_device *phydev)
+{
+	int c;
 
-	return phy_write(phydev, 16, value);
+	c = ip1xx_reset(phydev);
+	if (c < 0)
+		return c;
+
+	/* Enable Auto Power Saving mode */
+	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
+	c |= IP101A_APS_ON;
+	return c;
 }
 
 static int ip175c_read_status(struct phy_device *phydev)
@@ -158,6 +196,20 @@ static struct phy_driver ip1001_driver = {
 	.driver		= { .owner = THIS_MODULE,},
 };
 
+static struct phy_driver ip101a_driver = {
+	.phy_id		= 0x02430c54,
+	.name		= "ICPlus IP101A",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES | SUPPORTED_Pause |
+			  SUPPORTED_Asym_Pause,
+	.config_init	= &ip101a_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
 static int __init icplus_init(void)
 {
 	int ret = 0;
@@ -166,12 +218,17 @@ static int __init icplus_init(void)
 	if (ret < 0)
 		return -ENODEV;
 
+	ret = phy_driver_register(&ip101a_driver);
+	if (ret < 0)
+		return -ENODEV;
+
 	return phy_driver_register(&ip175c_driver);
 }
 
 static void __exit icplus_exit(void)
 {
 	phy_driver_unregister(&ip1001_driver);
+	phy_driver_unregister(&ip101a_driver);
 	phy_driver_unregister(&ip175c_driver);
 }
 
-- 
1.7.4.4
