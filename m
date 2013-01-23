From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git] net: phy: realtek: add rtl8211e driver
Date: Wed, 23 Jan 2013 11:30:03 +0100
Message-ID: <1358937003-19553-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:38738 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754692Ab3AWKaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 05:30:13 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D03D0215
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 10:30:11 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 682A72BA3
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 10:30:11 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the minimal driver to manage the
Realtek RTL8211E 10/100/1000 Transceivers.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/realtek.c |   50 +++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 72f9347..8e7af83 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -23,6 +23,8 @@
 #define RTL821x_INER_INIT	0x6400
 #define RTL821x_INSR		0x13
 
+#define	RTL8211E_INER_LINK_STAT	0x10
+
 MODULE_DESCRIPTION("Realtek PHY driver");
 MODULE_AUTHOR("Johnson Leung");
 MODULE_LICENSE("GPL");
@@ -36,7 +38,7 @@ static int rtl821x_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
-static int rtl821x_config_intr(struct phy_device *phydev)
+static int rtl8211b_config_intr(struct phy_device *phydev)
 {
 	int err;
 
@@ -49,28 +51,63 @@ static int rtl821x_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+static int rtl8211e_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, RTL821x_INER,
+				RTL8211E_INER_LINK_STAT);
+	else
+		err = phy_write(phydev, RTL821x_INER, 0);
+
+	return err;
+}
+
 /* RTL8211B */
-static struct phy_driver rtl821x_driver = {
+static struct phy_driver rtl8211b_driver = {
 	.phy_id		= 0x001cc912,
-	.name		= "RTL821x Gigabit Ethernet",
+	.name		= "RTL8211B Gigabit Ethernet",
 	.phy_id_mask	= 0x001fffff,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
 	.ack_interrupt	= &rtl821x_ack_interrupt,
-	.config_intr	= &rtl821x_config_intr,
+	.config_intr	= &rtl8211b_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+/* RTL8211E */
+static struct phy_driver rtl8211e_driver = {
+	.phy_id		= 0x001cc915,
+	.name		= "RTL8211E Gigabit Ethernet",
+	.phy_id_mask	= 0x001fffff,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &rtl821x_ack_interrupt,
+	.config_intr	= &rtl8211e_config_intr,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
 static int __init realtek_init(void)
 {
-	return phy_driver_register(&rtl821x_driver);
+	int ret;
+
+	ret = phy_driver_register(&rtl8211b_driver);
+	if (ret < 0)
+		return -ENODEV;
+	return phy_driver_register(&rtl8211e_driver);
 }
 
 static void __exit realtek_exit(void)
 {
-	phy_driver_unregister(&rtl821x_driver);
+	phy_driver_unregister(&rtl8211b_driver);
+	phy_driver_unregister(&rtl8211e_driver);
 }
 
 module_init(realtek_init);
@@ -78,6 +115,7 @@ module_exit(realtek_exit);
 
 static struct mdio_device_id __maybe_unused realtek_tbl[] = {
 	{ 0x001cc912, 0x001fffff },
+	{ 0x001cc915, 0x001fffff },
 	{ }
 };
 
-- 
1.7.4.4
