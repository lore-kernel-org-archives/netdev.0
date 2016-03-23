From: Vishal Thanki <vishalthanki@gmail.com>
Subject: [PATCH 2/3] net: phy: at8030: Expose the Link and Activity LEDs
Date: Wed, 23 Mar 2016 18:51:39 +0100
Message-ID: <1458755500-15571-3-git-send-email-vishalthanki@gmail.com>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Cc: Vishal Thanki <vishalthanki@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com, ujhelyi.m@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36230 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbcCWRvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:51:48 -0400
Received: by mail-wm0-f53.google.com with SMTP id r129so146556866wmr.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:51:47 -0700 (PDT)
In-Reply-To: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose these LEDs by means of a platform device which
can be controlled by a suitable LED driver.

Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
---
 drivers/net/phy/at803x.c   | 55 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/phy/at803x.h | 45 +++++++++++++++++++++++++++++++++++++
 2 files changed, 99 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/phy/at803x.h

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 1e901c7..8fdb5ff 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -18,6 +18,8 @@
 #include <linux/etherdevice.h>
 #include <linux/of_gpio.h>
 #include <linux/gpio/consumer.h>
+#include <linux/platform_device.h>
+#include <linux/phy/at803x.h>
 
 #define AT803X_INTR_ENABLE			0x12
 #define AT803X_INTR_ENABLE_AUTONEG_ERR		BIT(15)
@@ -34,6 +36,7 @@
 
 #define AT803X_SMART_SPEED			0x14
 #define AT803X_LED_CONTROL			0x18
+#define AT803X_LED_MANUAL_CTRL			0x19
 
 #define AT803X_DEVICE_ADDR			0x03
 #define AT803X_LOC_MAC_ADDR_0_15_OFFSET		0x804C
@@ -117,6 +120,46 @@ static inline int at803x_enable_tx_delay(struct phy_device *phydev)
 					AT803X_DEBUG_TX_CLK_DLY_EN);
 }
 
+static struct at803x_phy_led leds[] = {
+	{
+		.cdev.name = "at803x-link",
+		.id = AT803X_LINK,
+		.reg = AT803X_LED_MANUAL_CTRL,
+	},
+	{
+		.cdev.name = "at803x-act",
+		.id = AT803X_ACT,
+		.reg = AT803X_LED_MANUAL_CTRL,
+	},
+};
+
+static struct at803x_phy_leds led_grp = {
+	.leds = leds,
+	.nr_leds = ARRAY_SIZE(leds),
+};
+
+static struct platform_device *pdev;
+
+static int at803x_led_init(struct phy_device *phydev)
+{
+	led_grp.phydev = phydev;
+
+	pdev = platform_device_alloc("at803x-led", 0);
+	if (!pdev) {
+		pr_info("Failed to allocate LED\n");
+		return -ENOMEM;
+	}
+
+	platform_set_drvdata(pdev, &led_grp);
+
+	return platform_device_add(pdev);
+}
+
+static void at803x_led_cleanup(struct phy_device *phydev)
+{
+	platform_device_del(pdev);
+}
+
 /* save relevant PHY registers to private copy */
 static void at803x_context_save(struct phy_device *phydev,
 				struct at803x_context *context)
@@ -285,9 +328,18 @@ static int at803x_probe(struct phy_device *phydev)
 
 	phydev->priv = priv;
 
+	if (phydev->drv->flags & PHY_HAS_LED_CTRL)
+		return at803x_led_init(phydev);
+
 	return 0;
 }
 
+static void at803x_remove(struct phy_device *phydev)
+{
+	if (phydev->drv->flags & PHY_HAS_LED_CTRL)
+		at803x_led_cleanup(phydev);
+}
+
 static int at803x_config_init(struct phy_device *phydev)
 {
 	int ret;
@@ -411,11 +463,12 @@ static struct phy_driver at803x_driver[] = {
 	.suspend		= at803x_suspend,
 	.resume			= at803x_resume,
 	.features		= PHY_BASIC_FEATURES,
-	.flags			= PHY_HAS_INTERRUPT,
+	.flags			= PHY_HAS_INTERRUPT | PHY_HAS_LED_CTRL,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
 	.ack_interrupt		= at803x_ack_interrupt,
 	.config_intr		= at803x_config_intr,
+	.remove			= at803x_remove,
 }, {
 	/* ATHEROS 8031 */
 	.phy_id			= ATH8031_PHY_ID,
diff --git a/include/linux/phy/at803x.h b/include/linux/phy/at803x.h
new file mode 100644
index 0000000..f33bfcf
--- /dev/null
+++ b/include/linux/phy/at803x.h
@@ -0,0 +1,45 @@
+#ifndef _AT803X_H
+#define _AT803X_H
+
+#include <linux/leds.h>
+#include <linux/phy/phy.h>
+#include <linux/workqueue.h>
+#include <linux/spinlock.h>
+
+enum at803x_led_type {
+	AT803X_LINK,
+	AT803X_ACT,
+};
+
+union at803x_led_manual_ctrl {
+	struct {
+		u16 led_tx:2;
+		u16 led_rx:2;
+		u16 res3:2;
+		u16 led_lnk_10_100_ctrl:2;
+		u16 res2:4;
+		u16 led_act_ctrl:1;
+		u16 res1:3;
+
+	} field;
+	u16 value;
+};
+
+struct at803x_phy_led {
+	struct work_struct work;
+	struct led_classdev cdev;
+	enum led_brightness value;
+	union at803x_led_manual_ctrl regval;
+	enum at803x_led_type id;
+	struct at803x_phy_leds *led_grp;
+	spinlock_t lock;
+	u16 reg;
+};
+
+struct at803x_phy_leds {
+	struct phy_device *phydev;
+	struct at803x_phy_led *leds;
+	int nr_leds;
+};
+
+#endif
-- 
2.4.3
