From: Vishal Thanki <vishalthanki@gmail.com>
Subject: [PATCH] net: phy: at803x: Add support to control PHY LEDs
Date: Thu, 17 Mar 2016 14:59:07 +0100
Message-ID: <1458223147-16142-2-git-send-email-vishalthanki@gmail.com>
References: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
Cc: Vishal Thanki <vishalthanki@gmail.com>
To: ujhelyi.m@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33209 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbcCQN7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 09:59:16 -0400
Received: by mail-wm0-f43.google.com with SMTP id l68so27510833wml.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 06:59:15 -0700 (PDT)
In-Reply-To: <1458223147-16142-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LEDs can be turned on and off by a sysfs interface
now. Write 0 to "led_enable" file to turn off the LEDs
and write 1 to turn on. The support is experimental
and can be enabled by kernel configuration option.

Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
---
 drivers/net/phy/Kconfig  |  7 +++++
 drivers/net/phy/at803x.c | 71 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 075a4cc..16f78cf 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -24,6 +24,13 @@ config AT803X_PHY
 	---help---
 	  Currently supports the AT8030 and AT8035 model
 
+config AT803X_PHY_LED_CONTROL
+	depends on AT803X_PHY
+	bool "Support for PHY LED control (Experimental)"
+	---help---
+	  This option enables a sysfs interface to turn on and off the link
+	  LEDs attached to phy.
+
 config AMD_PHY
 	tristate "Drivers for the AMD PHYs"
 	---help---
diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 1e901c7..a606d52 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -59,12 +59,19 @@
 #define ATH8031_PHY_ID 0x004dd074
 #define ATH8035_PHY_ID 0x004dd072
 
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+#define LED_OFF		0xF71F
+#endif
+
 MODULE_DESCRIPTION("Atheros 803x PHY driver");
 MODULE_AUTHOR("Matus Ujhelyi");
 MODULE_LICENSE("GPL");
 
 struct at803x_priv {
 	bool phy_reset:1;
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+	int led_status;
+#endif
 	struct gpio_desc *gpiod_reset;
 };
 
@@ -267,6 +274,42 @@ done:
 	return 0;
 }
 
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+static ssize_t at803x_led_get(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct phy_device *phydev = dev_get_drvdata(dev);
+	int read = phy_read(phydev, AT803X_LED_CONTROL);
+
+	read = (read == LED_OFF) ? 0 : 1;
+	return sprintf(buf, "%x\n", read);
+}
+
+static ssize_t at803x_led_set(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct phy_device *phydev = dev_get_drvdata(dev);
+	struct at803x_priv *priv = phydev->priv;
+	int val;
+
+	if (!strncmp(buf, "0", 1)) {
+		priv->led_status = phy_read(phydev, AT803X_LED_CONTROL);
+		val = LED_OFF;
+	} else if (!strncmp(buf, "1", 1)) {
+		val = priv->led_status;
+	} else {
+		return -EINVAL;
+	}
+
+	phy_write(phydev, AT803X_LED_CONTROL, val);
+
+	return count;
+}
+
+static DEVICE_ATTR(led_enable, 0600, at803x_led_get, at803x_led_set);
+#endif
+
 static int at803x_probe(struct phy_device *phydev)
 {
 	struct device *dev = &phydev->mdio.dev;
@@ -285,12 +328,31 @@ static int at803x_probe(struct phy_device *phydev)
 
 	phydev->priv = priv;
 
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+	dev_set_drvdata(dev, phydev);
+	return device_create_file(dev, &dev_attr_led_enable);
+#else
 	return 0;
+#endif
+}
+
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+static void at803x_remove(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->mdio.dev;
+	device_remove_file(dev, &dev_attr_led_enable);
 }
+#endif
 
 static int at803x_config_init(struct phy_device *phydev)
 {
 	int ret;
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+	struct at803x_priv *priv;
+
+	priv = phydev->priv;
+	priv->led_status = phy_read(phydev, AT803X_LED_CONTROL);
+#endif
 
 	ret = genphy_config_init(phydev);
 	if (ret < 0)
@@ -396,6 +458,9 @@ static struct phy_driver at803x_driver[] = {
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+	.remove			= at803x_remove,
+#endif
 	.ack_interrupt		= at803x_ack_interrupt,
 	.config_intr		= at803x_config_intr,
 }, {
@@ -414,6 +479,9 @@ static struct phy_driver at803x_driver[] = {
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+	.remove			= at803x_remove,
+#endif
 	.ack_interrupt		= at803x_ack_interrupt,
 	.config_intr		= at803x_config_intr,
 }, {
@@ -432,6 +500,9 @@ static struct phy_driver at803x_driver[] = {
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
+#ifdef CONFIG_AT803X_PHY_LED_CONTROL
+	.remove			= at803x_remove,
+#endif
 	.ack_interrupt		= &at803x_ack_interrupt,
 	.config_intr		= &at803x_config_intr,
 } };
-- 
2.4.3
