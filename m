From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/2] phy: IC+101G and PHY_HAS_INTERRUPT flag
Date: Wed, 22 Feb 2012 08:26:28 +0100
Message-ID: <1329895588-6191-1-git-send-email-peppe.cavallaro@st.com>
References: <1329895498-5810-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:36479 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752631Ab2BVH0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 02:26:38 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 74648A2
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 07:26:36 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 278C616A9
	for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 07:26:36 +0000 (GMT)
In-Reply-To: <1329895498-5810-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the PHY_HAS_INTERRUPT flag for IC+101 device series.
Also the patch does a simple dity-up to signal that
the driver actually is for IP101A LF and IP101G devices.
In fact, these are two similar PHYs that have the same IDs
and mainly differ for the EEE capability supported in the
G series.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/icplus.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 7ee4f58..0856e1b 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -30,16 +30,16 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-MODULE_DESCRIPTION("ICPlus IP175C/IP101A/IC1001 PHY drivers");
+MODULE_DESCRIPTION("ICPlus IP175C/IP101A/IP101G/IC1001 PHY drivers");
 MODULE_AUTHOR("Michael Barkowski");
 MODULE_LICENSE("GPL");
 
-/* IP101A/IP1001 */
-#define IP10XX_SPEC_CTRL_STATUS		16  /* Spec. Control Register */
-#define IP1001_SPEC_CTRL_STATUS_2	20  /* IP1001 Spec. Control Reg 2 */
-#define IP1001_PHASE_SEL_MASK		3 /* IP1001 RX/TXPHASE_SEL */
-#define IP1001_APS_ON			11  /* IP1001 APS Mode  bit */
-#define IP101A_APS_ON			2   /* IP101A APS Mode bit */
+/* IP101A/G - IP1001 */
+#define IP10XX_SPEC_CTRL_STATUS		16	/* Spec. Control Register */
+#define IP1001_SPEC_CTRL_STATUS_2	20	/* IP1001 Spec. Control Reg 2 */
+#define IP1001_PHASE_SEL_MASK		3	/* IP1001 RX/TXPHASE_SEL */
+#define IP1001_APS_ON			11	/* IP1001 APS Mode  bit */
+#define IP101A_G_APS_ON			2	/* IP101A/G APS Mode bit */
 
 static int ip175c_config_init(struct phy_device *phydev)
 {
@@ -151,7 +151,7 @@ static int ip1001_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static int ip101a_config_init(struct phy_device *phydev)
+static int ip101a_g_config_init(struct phy_device *phydev)
 {
 	int c;
 
@@ -161,7 +161,7 @@ static int ip101a_config_init(struct phy_device *phydev)
 
 	/* Enable Auto Power Saving mode */
 	c = phy_read(phydev, IP10XX_SPEC_CTRL_STATUS);
-	c |= IP101A_APS_ON;
+	c |= IP101A_G_APS_ON;
 	return c;
 }
 
@@ -203,6 +203,7 @@ static struct phy_driver ip1001_driver = {
 	.phy_id_mask	= 0x0ffffff0,
 	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_INTERRUPT,
 	.config_init	= &ip1001_config_init,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
@@ -211,13 +212,14 @@ static struct phy_driver ip1001_driver = {
 	.driver		= { .owner = THIS_MODULE,},
 };
 
-static struct phy_driver ip101a_driver = {
+static struct phy_driver ip101a_g_driver = {
 	.phy_id		= 0x02430c54,
-	.name		= "ICPlus IP101A",
+	.name		= "ICPlus IP101A/G",
 	.phy_id_mask	= 0x0ffffff0,
 	.features	= PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause,
-	.config_init	= &ip101a_config_init,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &ip101a_g_config_init,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
 	.suspend	= genphy_suspend,
@@ -233,7 +235,7 @@ static int __init icplus_init(void)
 	if (ret < 0)
 		return -ENODEV;
 
-	ret = phy_driver_register(&ip101a_driver);
+	ret = phy_driver_register(&ip101a_g_driver);
 	if (ret < 0)
 		return -ENODEV;
 
@@ -243,7 +245,7 @@ static int __init icplus_init(void)
 static void __exit icplus_exit(void)
 {
 	phy_driver_unregister(&ip1001_driver);
-	phy_driver_unregister(&ip101a_driver);
+	phy_driver_unregister(&ip101a_g_driver);
 	phy_driver_unregister(&ip175c_driver);
 }
 
@@ -253,6 +255,7 @@ module_exit(icplus_exit);
 static struct mdio_device_id __maybe_unused icplus_tbl[] = {
 	{ 0x02430d80, 0x0ffffff0 },
 	{ 0x02430d90, 0x0ffffff0 },
+	{ 0x02430c54, 0x0ffffff0 },
 	{ }
 };
 
-- 
1.7.4.4
