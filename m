From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH] net: phy: realtek: register/unregister multiple drivers properly
Date: Tue, 10 Jun 2014 12:50:12 +0900
Message-ID: <1402372212-19553-1-git-send-email-neidhard.kim@lge.com>
Cc: r58129@freescale.com, linux-kernel@vger.kernel.org,
	Jongsung Kim <neidhard.kim@lge.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using phy_drivers_register/_unregister functions is proper way to
handle multiple PHY drivers registration. For Realtek PHY drivers
module, it fixes incomplete current error-handlings up and adds
missed unregistration for the RTL8201CP driver.

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
---
 drivers/net/phy/realtek.c |   88 +++++++++++++++++++--------------------------
 1 files changed, 37 insertions(+), 51 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index fa1d69a..45483fd 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -64,65 +64,51 @@ static int rtl8211e_config_intr(struct phy_device *phydev)
 	return err;
 }
 
-/* RTL8201CP */
-static struct phy_driver rtl8201cp_driver = {
-	.phy_id         = 0x00008201,
-	.name           = "RTL8201CP Ethernet",
-	.phy_id_mask    = 0x0000ffff,
-	.features       = PHY_BASIC_FEATURES,
-	.flags          = PHY_HAS_INTERRUPT,
-	.config_aneg    = &genphy_config_aneg,
-	.read_status    = &genphy_read_status,
-	.driver         = { .owner = THIS_MODULE,},
-};
-
-/* RTL8211B */
-static struct phy_driver rtl8211b_driver = {
-	.phy_id		= 0x001cc912,
-	.name		= "RTL8211B Gigabit Ethernet",
-	.phy_id_mask	= 0x001fffff,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
-	.ack_interrupt	= &rtl821x_ack_interrupt,
-	.config_intr	= &rtl8211b_config_intr,
-	.driver		= { .owner = THIS_MODULE,},
-};
-
-/* RTL8211E */
-static struct phy_driver rtl8211e_driver = {
-	.phy_id		= 0x001cc915,
-	.name		= "RTL8211E Gigabit Ethernet",
-	.phy_id_mask	= 0x001fffff,
-	.features	= PHY_GBIT_FEATURES,
-	.flags		= PHY_HAS_INTERRUPT,
-	.config_aneg	= &genphy_config_aneg,
-	.read_status	= &genphy_read_status,
-	.ack_interrupt	= &rtl821x_ack_interrupt,
-	.config_intr	= &rtl8211e_config_intr,
-	.suspend	= genphy_suspend,
-	.resume		= genphy_resume,
-	.driver		= { .owner = THIS_MODULE,},
+static struct phy_driver realtek_drvs[] = {
+	{
+		.phy_id         = 0x00008201,
+		.name           = "RTL8201CP Ethernet",
+		.phy_id_mask    = 0x0000ffff,
+		.features       = PHY_BASIC_FEATURES,
+		.flags          = PHY_HAS_INTERRUPT,
+		.config_aneg    = &genphy_config_aneg,
+		.read_status    = &genphy_read_status,
+		.driver         = { .owner = THIS_MODULE,},
+	}, {
+		.phy_id		= 0x001cc912,
+		.name		= "RTL8211B Gigabit Ethernet",
+		.phy_id_mask	= 0x001fffff,
+		.features	= PHY_GBIT_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_aneg	= &genphy_config_aneg,
+		.read_status	= &genphy_read_status,
+		.ack_interrupt	= &rtl821x_ack_interrupt,
+		.config_intr	= &rtl8211b_config_intr,
+		.driver		= { .owner = THIS_MODULE,},
+	}, {
+		.phy_id		= 0x001cc915,
+		.name		= "RTL8211E Gigabit Ethernet",
+		.phy_id_mask	= 0x001fffff,
+		.features	= PHY_GBIT_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_aneg	= &genphy_config_aneg,
+		.read_status	= &genphy_read_status,
+		.ack_interrupt	= &rtl821x_ack_interrupt,
+		.config_intr	= &rtl8211e_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+		.driver		= { .owner = THIS_MODULE,},
+	},
 };
 
 static int __init realtek_init(void)
 {
-	int ret;
-
-	ret = phy_driver_register(&rtl8201cp_driver);
-	if (ret < 0)
-		return -ENODEV;
-	ret = phy_driver_register(&rtl8211b_driver);
-	if (ret < 0)
-		return -ENODEV;
-	return phy_driver_register(&rtl8211e_driver);
+	return phy_drivers_register(realtek_drvs, ARRAY_SIZE(realtek_drvs));
 }
 
 static void __exit realtek_exit(void)
 {
-	phy_driver_unregister(&rtl8211b_driver);
-	phy_driver_unregister(&rtl8211e_driver);
+	phy_drivers_unregister(realtek_drvs, ARRAY_SIZE(realtek_drvs));
 }
 
 module_init(realtek_init);
-- 
1.7.1
