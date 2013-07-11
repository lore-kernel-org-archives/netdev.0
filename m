From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: [PATCH 2/2] drivers: net: phy: at803x: LED control via led subsystem
Date: Thu, 11 Jul 2013 13:57:35 +0200
Message-ID: <1373543855-31670-2-git-send-email-helmut.schaa@googlemail.com>
References: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
Cc: davem@davemloft.net, Helmut Schaa <helmut.schaa@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:57621 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab3GKL5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 07:57:47 -0400
Received: by mail-ee0-f43.google.com with SMTP id l10so5470427eei.2
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 04:57:45 -0700 (PDT)
In-Reply-To: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The AT8035 PHY allows to control the LED PIN behavior from software.
Expose this functionality by registering an LED device.

Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
---
 drivers/net/phy/Kconfig  |    7 ++++
 drivers/net/phy/at803x.c |   87 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 94 insertions(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 3a316b3..5e855b7 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -19,6 +19,13 @@ config AT803X_PHY
 	---help---
 	  Currently supports the AT8030 and AT8035 model
 
+config AT803X_LEDS
+	bool "Enable access to PHY connected LEDs"
+	depends on AT803X_PHY && LEDS_CLASS
+	---help---
+	  Select this to be able to control LEDs connected to the
+	  PHY from userspace
+
 config AMD_PHY
 	tristate "Drivers for the AMD PHYs"
 	---help---
diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index ac22283..49ef6306 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -16,6 +16,7 @@
 #include <linux/string.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/leds.h>
 
 #define AT803X_INTR_ENABLE			0x12
 #define AT803X_INTR_STATUS			0x13
@@ -31,6 +32,8 @@
 #define AT803X_DEBUG_DATA			0x1E
 #define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
 #define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
+#define AT8035_LED_CTRL				0x18
+#define AT8035_LED_CTRL_OFF			BIT(15)
 
 MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
@@ -152,6 +155,86 @@ static int at803x_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+#ifdef CONFIG_AT803X_LEDS
+
+struct at8035_priv {
+	struct led_classdev led;
+	struct phy_device *phydev;
+	struct work_struct led_work;
+	bool stop;
+};
+
+static void at8035_led_work(struct work_struct *work)
+{
+	struct at8035_priv *priv =
+		container_of(work, struct at8035_priv, led_work);
+	struct phy_device *phydev = priv->phydev;
+	int val;
+
+	if (priv->stop)
+		return;
+
+	val = phy_read(phydev, AT8035_LED_CTRL);
+
+	if (priv->led.brightness > 0)
+		phy_write(phydev, AT8035_LED_CTRL, val & ~AT8035_LED_CTRL_OFF);
+	else
+		phy_write(phydev, AT8035_LED_CTRL, val | AT8035_LED_CTRL_OFF);
+}
+
+static void at8035_led_brightness_set(struct led_classdev *led,
+				      enum led_brightness brightness)
+{
+	struct at8035_priv *priv = container_of(led, struct at8035_priv, led);
+
+	/* MDIO bus can only be used from process context */
+	if (!priv->stop)
+		schedule_work(&priv->led_work);
+}
+
+static int at8035_probe(struct phy_device *phydev)
+{
+	struct at8035_priv *priv;
+	int ret;
+
+	priv = kzalloc(sizeof(struct at8035_priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	INIT_WORK(&priv->led_work, at8035_led_work);
+
+	priv->phydev = phydev;
+	priv->led.brightness_set = at8035_led_brightness_set;
+	priv->led.max_brightness = 1;
+	priv->led.name = kasprintf(GFP_KERNEL, "at8035_%u::act", phydev->addr);
+
+	if (!priv->led.name) {
+		kfree(priv);
+		return -ENOMEM;
+	}
+
+	ret = led_classdev_register(&phydev->dev, &priv->led);
+	if (ret) {
+		kfree(priv->led.name);
+		kfree(priv);
+		return -ENOMEM;
+	}
+
+	phydev->priv = priv;
+	return 0;
+}
+
+static void at8035_remove(struct phy_device *phydev)
+{
+	struct at8035_priv *priv = phydev->priv;
+	priv->stop = true;
+	cancel_work_sync(&priv->led_work);
+	led_classdev_unregister(&priv->led);
+	kfree(priv->led.name);
+	kfree(priv);
+}
+#endif
+
 static struct phy_driver at803x_driver[] = {
 {
 	/* ATHEROS 8035 */
@@ -163,6 +246,10 @@ static struct phy_driver at803x_driver[] = {
 	.get_wol	= at803x_get_wol,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
+#ifdef CONFIG_AT803X_LEDS
+	.probe		= at8035_probe,
+	.remove		= at8035_remove,
+#endif
 	.config_aneg	= &genphy_config_aneg,
 	.read_status	= &genphy_read_status,
 	.driver		= {
-- 
1.7.10.4
