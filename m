From: Matteo Croce <technoboy85@gmail.com>
Subject: Re: [PATCH][MIPS][6/6] AR7: leds driver
Date: Thu, 11 Oct 2007 03:01:30 +0200
Message-ID: <200710110301.31223.technoboy85@gmail.com>
References: <200710110248.33028.technoboy85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Konev <ejka@imfi.kspu.ru>, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:22136 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778AbXJKBBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 21:01:35 -0400
Received: by wx-out-0506.google.com with SMTP id h31so394255wxd
        for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 18:01:35 -0700 (PDT)
In-Reply-To: <200710110248.33028.technoboy85@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new led driver, uses leds-gpio now

Signed-off-by: Matteo Croce <technoboy85@gmail.com>
Signed-off-by: Nicolas Thill <nico@openwrt.org>

diff --git a/drivers/leds/leds-ar7.c b/drivers/leds/leds-ar7.c
new file mode 100644
index 0000000..72b958a
--- /dev/null
+++ b/drivers/leds/leds-ar7.c
@@ -0,0 +1,130 @@
+/*
+ * Copyright (C) 2007 Nicolas Thill <nico@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ */
+
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/platform_device.h>
+#include <linux/leds.h>
+#include <linux/err.h>
+#include <linux/io.h>
+#include <gpio.h>
+
+#define DRVNAME "ar7-leds"
+#define LONGNAME "TI AR7 LEDs driver"
+#define AR7_GPIO_BIT_STATUS_LED 8
+
+MODULE_AUTHOR("Nicolas Thill <nico@openwrt.org>");
+MODULE_DESCRIPTION(LONGNAME);
+MODULE_LICENSE("GPL");
+
+static void ar7_status_led_set(struct led_classdev *pled,
+		enum led_brightness value)
+{
+	gpio_set_value(AR7_GPIO_BIT_STATUS_LED, value ? 0 : 1);
+}
+
+static struct led_classdev ar7_status_led = {
+	.name		= "ar7:status",
+	.brightness_set	= ar7_status_led_set,
+};
+
+#ifdef CONFIG_PM
+static int ar7_leds_suspend(struct platform_device *dev,
+		pm_message_t state)
+{
+	led_classdev_suspend(&ar7_status_led);
+	return 0;
+}
+
+static int ar7_leds_resume(struct platform_device *dev)
+{
+	led_classdev_resume(&ar7_status_led);
+	return 0;
+}
+#else /* CONFIG_PM */
+#define ar7_leds_suspend NULL
+#define ar7_leds_resume NULL
+#endif /* CONFIG_PM */
+
+static int ar7_leds_probe(struct platform_device *pdev)
+{
+	int rc;
+
+	rc = led_classdev_register(&pdev->dev, &ar7_status_led);
+	if (rc < 0)
+		goto out;
+
+	ar7_gpio_enable(AR7_GPIO_BIT_STATUS_LED);
+	gpio_direction_output(AR7_GPIO_BIT_STATUS_LED, 0);
+
+out:
+	return rc;
+}
+
+static int ar7_leds_remove(struct platform_device *pdev)
+{
+	led_classdev_unregister(&ar7_status_led);
+
+	return 0;
+}
+
+static struct platform_device *ar7_leds_device;
+
+static struct platform_driver ar7_leds_driver = {
+	.probe		= ar7_leds_probe,
+	.remove		= ar7_leds_remove,
+	.suspend	= ar7_leds_suspend,
+	.resume		= ar7_leds_resume,
+	.driver		= {
+		.name		= DRVNAME,
+	},
+};
+
+static int __init ar7_leds_init(void)
+{
+	int rc;
+
+	ar7_leds_device = platform_device_alloc(DRVNAME, -1);
+	if (!ar7_leds_device)
+		return -ENOMEM;
+
+	rc = platform_device_add(ar7_leds_device);
+	if (rc < 0)
+		goto out_put;
+
+	rc = platform_driver_register(&ar7_leds_driver);
+	if (rc < 0)
+		goto out_put;
+
+	goto out;
+
+out_put:
+	platform_device_put(ar7_leds_device);
+out:
+	return rc;
+}
+
+static void __exit ar7_leds_exit(void)
+{
+	platform_driver_unregister(&ar7_leds_driver);
+	platform_device_unregister(ar7_leds_device);
+}
+
+module_init(ar7_leds_init);
+module_exit(ar7_leds_exit);
