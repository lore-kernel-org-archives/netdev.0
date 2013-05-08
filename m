From: Jongsung Kim <neidhard.kim@lge.com>
Subject: net: phy: realtek: add rtl8201f driver
Date: Wed, 8 May 2013 19:10:27 +0900
Message-ID: <201305081910.27203.neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the minimal driver to manage the
Realtek RTL8201F 10/100Mbps Transceivers.

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
---
 drivers/net/phy/realtek.c |   60 +++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 53 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 8e7af83..27847ca 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -16,9 +16,13 @@
 #include <linux/phy.h>
 #include <linux/module.h>
 
-#define RTL821x_PHYSR		0x11
-#define RTL821x_PHYSR_DUPLEX	0x2000
-#define RTL821x_PHYSR_SPEED	0xc000
+/* page 0 register 30 - interrupt indicators and SNR display register */
+#define RTL8201F_ISR		0x1e
+/* page 0 register 31 - page select register */
+#define RTL8201F_PSR		0x1f
+/* page 7 register 19 - interrupt, WOL enable, and LEDs function register */
+#define RTL8201F_IER		0x13
+
 #define RTL821x_INER		0x12
 #define RTL821x_INER_INIT	0x6400
 #define RTL821x_INSR		0x13
@@ -29,6 +33,15 @@ MODULE_DESCRIPTION("Realtek PHY driver");
 MODULE_AUTHOR("Johnson Leung");
 MODULE_LICENSE("GPL");
 
+static int rtl8201f_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, RTL8201F_ISR);
+
+	return (err < 0) ? err : 0;
+}
+
 static int rtl821x_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -38,6 +51,24 @@ static int rtl821x_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
+static int rtl8201f_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	phy_write(phydev, RTL8201F_PSR, 0x0007);	/* select page 7 */
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, RTL8201F_IER, 0x3800 |
+		                phy_read(phydev, RTL8201F_IER));
+	else
+		err = phy_write(phydev, RTL8201F_IER, ~0x3800 &
+		                phy_read(phydev, RTL8201F_IER));
+
+	phy_write(phydev, RTL8201F_PSR, 0x0000);	/* back to page 0 */
+
+	return err;
+}
+
 static int rtl8211b_config_intr(struct phy_device *phydev)
 {
 	int err;
@@ -64,6 +95,20 @@ static int rtl8211e_config_intr(struct phy_device *phydev)
 	return err;
 }
 
+/* RTL8201F */
+static struct phy_driver rtl8201f_driver = {
+	.phy_id		= 0x001cc816,
+	.name		= "RTL8201F 10/100Mbps Ethernet",
+	.phy_id_mask	= 0x001fffff,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &rtl8201f_ack_interrupt,
+	.config_intr	= &rtl8201f_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
 /* RTL8211B */
 static struct phy_driver rtl8211b_driver = {
 	.phy_id		= 0x001cc912,
@@ -96,16 +141,16 @@ static struct phy_driver rtl8211e_driver = {
 
 static int __init realtek_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&rtl8211b_driver);
-	if (ret < 0)
+	if(phy_driver_register(&rtl8201f_driver) < 0)
+		return -ENODEV;
+	if(phy_driver_register(&rtl8211b_driver) < 0)
 		return -ENODEV;
 	return phy_driver_register(&rtl8211e_driver);
 }
 
 static void __exit realtek_exit(void)
 {
+	phy_driver_unregister(&rtl8201f_driver);
 	phy_driver_unregister(&rtl8211b_driver);
 	phy_driver_unregister(&rtl8211e_driver);
 }
@@ -114,6 +159,7 @@ module_init(realtek_init);
 module_exit(realtek_exit);
 
 static struct mdio_device_id __maybe_unused realtek_tbl[] = {
+	{ 0x001cc816, 0x001fffff },
 	{ 0x001cc912, 0x001fffff },
 	{ 0x001cc915, 0x001fffff },
 	{ }
