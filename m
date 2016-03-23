From: Vishal Thanki <vishalthanki@gmail.com>
Subject: [PATCH 3/3] led: at8030: Add LED driver for AT8030 ethernet PHY
Date: Wed, 23 Mar 2016 18:51:40 +0100
Message-ID: <1458755500-15571-4-git-send-email-vishalthanki@gmail.com>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Cc: Vishal Thanki <vishalthanki@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com, ujhelyi.m@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37205 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756338AbcCWRvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:51:49 -0400
Received: by mail-wm0-f51.google.com with SMTP id p65so34368254wmp.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:51:48 -0700 (PDT)
In-Reply-To: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for controlling the Link and
Activity LED of AT8030 ethernet PHY through LED subsystem.

Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
---
 drivers/leds/Kconfig       |   7 ++
 drivers/leds/Makefile      |   1 +
 drivers/leds/leds-at803x.c | 158 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 166 insertions(+)
 create mode 100644 drivers/leds/leds-at803x.c

diff --git a/drivers/leds/Kconfig b/drivers/leds/Kconfig
index 1f64151..07781ac 100644
--- a/drivers/leds/Kconfig
+++ b/drivers/leds/Kconfig
@@ -615,6 +615,13 @@ config LEDS_VERSATILE
 	  This option enabled support for the LEDs on the ARM Versatile
 	  and RealView boards. Say Y to enabled these.
 
+config LEDS_AT803X
+	tristate "LED support for the AT803X Ethernet PHY (Experimental)"
+	depends on LEDS_CLASS
+	help
+	  This option enabled support for the LEDs on AT803X ethernet PHY.
+
+
 comment "LED Triggers"
 source "drivers/leds/trigger/Kconfig"
 
diff --git a/drivers/leds/Makefile b/drivers/leds/Makefile
index cb2013d..2d1ae65 100644
--- a/drivers/leds/Makefile
+++ b/drivers/leds/Makefile
@@ -67,6 +67,7 @@ obj-$(CONFIG_LEDS_KTD2692)		+= leds-ktd2692.o
 obj-$(CONFIG_LEDS_POWERNV)		+= leds-powernv.o
 obj-$(CONFIG_LEDS_SEAD3)		+= leds-sead3.o
 obj-$(CONFIG_LEDS_IS31FL32XX)		+= leds-is31fl32xx.o
+obj-$(CONFIG_LEDS_AT803X)		+= leds-at803x.o
 
 # LED SPI Drivers
 obj-$(CONFIG_LEDS_DAC124S085)		+= leds-dac124s085.o
diff --git a/drivers/leds/leds-at803x.c b/drivers/leds/leds-at803x.c
new file mode 100644
index 0000000..58eb0c4
--- /dev/null
+++ b/drivers/leds/leds-at803x.c
@@ -0,0 +1,158 @@
+#include <linux/kernel.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/leds.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/phy/at803x.h>
+
+#define LED_TX_NORMAL		0x0
+#define LED_TX_BLINK		0x1
+#define LED_TX_OFF		0x2
+#define LED_TX_ON		0x3
+
+#define LED_RX_NORMAL		0x0
+#define LED_RX_BLINK		0x1
+#define LED_RX_OFF		0x2
+#define LED_RX_ON		0x3
+
+#define LED_ACT_BLINK		0x1
+
+#define LED_LINK_NORMAL		0x0
+#define LED_LINK_BLINK		LED_ACT_BLINK
+#define LED_LINK_OFF		0x2
+#define LED_LINK_ON		0x3
+
+#define LED_ACT_ACTIVE		0x0
+#define LED_ACT_LINK		0x1
+
+static void at803x_led_work(struct work_struct *work)
+{
+	struct at803x_phy_led *led =
+		container_of(work, struct at803x_phy_led, work);
+	union at803x_led_manual_ctrl regval = led->regval;
+
+	phy_write(led->led_grp->phydev, led->reg, regval.value);
+}
+
+static int at803x_blink_set(struct led_classdev *cdev,
+	unsigned long *delay_on,
+	unsigned long *delay_off)
+{
+	struct at803x_phy_led *led =
+		container_of(cdev, struct at803x_phy_led, cdev);
+	union at803x_led_manual_ctrl regval = {.value = 0};
+	int id = led->id;
+	unsigned long flags;
+
+	spin_lock_irqsave(&led->lock, flags);
+	switch (id) {
+	case AT803X_LINK:
+		/* Can't configure LED_LINK to blink */
+		break;
+	case AT803X_ACT:
+		/*
+		 * LED will be ON when link is established
+		 * and it will blink when link is active.
+		 * delay_on/delay_off values are ignored.
+		 */
+		regval.field.led_act_ctrl = LED_ACT_LINK;
+		break;
+	}
+	led->regval = regval;
+
+	schedule_work(&led->work);
+	spin_unlock_irqrestore(&led->lock, flags);
+	return 0;
+}
+
+
+static void at803x_phy_led_brightness_set(struct led_classdev *led_cdev,
+		enum led_brightness value)
+{
+	struct at803x_phy_led *led =
+		container_of(led_cdev, struct at803x_phy_led, cdev);
+	union at803x_led_manual_ctrl regval = led->regval;
+	int id = led->id;
+	unsigned long flags;
+
+	spin_lock_irqsave(&led->lock, flags);
+	switch (id) {
+	case AT803X_LINK:
+		regval.field.led_lnk_10_100_ctrl = value == LED_FULL ?
+			LED_LINK_ON : LED_LINK_OFF;
+		break;
+	case AT803X_ACT:
+		/* LED_ACT status is controlled via LED_TX and LED_RX */
+		regval.field.led_tx = value == LED_FULL ?
+			LED_TX_ON : LED_TX_OFF;
+		regval.field.led_rx = value == LED_FULL ?
+			LED_RX_ON : LED_RX_OFF;
+		break;
+	}
+
+	led->value = value;
+	led->regval = regval;
+	schedule_work(&led->work);
+	spin_unlock_irqrestore(&led->lock, flags);
+}
+
+static int at803x_phy_led_probe(struct platform_device *pdev)
+{
+	int i;
+	int ret;
+	struct at803x_phy_leds *led_grp = platform_get_drvdata(pdev);
+	struct at803x_phy_led *leds = led_grp->leds;
+
+	for (i = 0; i < led_grp->nr_leds; i++) {
+
+		leds[i].cdev.brightness_set = at803x_phy_led_brightness_set;
+		leds[i].cdev.blink_set = at803x_blink_set;
+
+		ret = led_classdev_register(&pdev->dev, &leds[i].cdev);
+		if (ret < 0)
+			goto err;
+
+		leds[i].led_grp = led_grp;
+		leds[i].regval.value = phy_read(led_grp->phydev, leds[i].reg);
+		INIT_WORK(&leds[i].work, at803x_led_work);
+		spin_lock_init(&leds[i].lock);
+
+	}
+
+	return 0;
+
+err:
+	for (i = i - 1; i >= 0; i--)
+		led_classdev_unregister(&leds[i].cdev);
+
+	return ret;
+}
+
+static int at803x_phy_led_remove(struct platform_device *pdev)
+{
+	int i;
+	struct at803x_phy_leds *led_grp = platform_get_drvdata(pdev);
+	struct at803x_phy_led *leds = led_grp->leds;
+
+
+	for (i = 0; i < led_grp->nr_leds; i++)
+		led_classdev_unregister(&leds[i].cdev);
+
+	return 0;
+}
+
+static struct platform_driver at803x_phy_led_driver = {
+	.probe		= at803x_phy_led_probe,
+	.remove		= at803x_phy_led_remove,
+	.driver		= {
+		.name	= "at803x-led",
+	},
+};
+
+module_platform_driver(at803x_phy_led_driver);
+
+MODULE_DESCRIPTION("at803x PHY LED driver");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:leds-at803x");
-- 
2.4.3
