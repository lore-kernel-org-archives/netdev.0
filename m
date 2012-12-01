From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH] irda: ep7211-sir: Convert to platform_diver
Date: Sat,  1 Dec 2012 15:07:26 +0400
Message-ID: <1354360046-4818-1-git-send-email-shc_work@mail.ru>
Cc: Samuel Ortiz <samuel@sortiz.org>, Arnd Bergmann <arnd@arndb.de>,
	Alexander Shiyan <shc_work@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback6.mail.ru ([94.100.176.134]:36348 "EHLO
	fallback6.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab2LALHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 06:07:55 -0500
Received: from smtp41.i.mail.ru (smtp41.i.mail.ru [94.100.177.101])
	by fallback6.mail.ru (mPOP.Fallback_MX) with ESMTP id C09789C2928D
	for <netdev@vger.kernel.org>; Sat,  1 Dec 2012 15:07:51 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts ep7211-sir driver to platform_driver.
Since driver can be used not only for EP7211 CPU, function names
was be renamed to generic clps711x...

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 drivers/net/irda/ep7211-sir.c |   73 +++++++++++++++--------------------------
 1 files changed, 27 insertions(+), 46 deletions(-)

diff --git a/drivers/net/irda/ep7211-sir.c b/drivers/net/irda/ep7211-sir.c
index f83c5b8..5fe1f4d 100644
--- a/drivers/net/irda/ep7211-sir.c
+++ b/drivers/net/irda/ep7211-sir.c
@@ -1,52 +1,18 @@
 /*
- * IR port driver for the Cirrus Logic EP7211 processor.
+ * IR port driver for the Cirrus Logic CLPS711X processors
  *
  * Copyright 2001, Blue Mug Inc.  All rights reserved.
  * Copyright 2007, Samuel Ortiz <samuel@sortiz.org>
  */
-#include <linux/module.h>
-#include <linux/delay.h>
-#include <linux/tty.h>
-#include <linux/init.h>
-#include <linux/spinlock.h>
 
-#include <net/irda/irda.h>
-#include <net/irda/irda_device.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
 
-#include <asm/io.h>
 #include <mach/hardware.h>
 
 #include "sir-dev.h"
 
-#define MIN_DELAY 25      /* 15 us, but wait a little more to be sure */
-#define MAX_DELAY 10000   /* 1 ms */
-
-static int ep7211_open(struct sir_dev *dev);
-static int ep7211_close(struct sir_dev *dev);
-static int ep7211_change_speed(struct sir_dev *dev, unsigned speed);
-static int ep7211_reset(struct sir_dev *dev);
-
-static struct dongle_driver ep7211 = {
-	.owner		= THIS_MODULE,
-	.driver_name	= "EP7211 IR driver",
-	.type		= IRDA_EP7211_DONGLE,
-	.open		= ep7211_open,
-	.close		= ep7211_close,
-	.reset		= ep7211_reset,
-	.set_speed	= ep7211_change_speed,
-};
-
-static int __init ep7211_sir_init(void)
-{
-	return irda_register_dongle(&ep7211);
-}
-
-static void __exit ep7211_sir_cleanup(void)
-{
-	irda_unregister_dongle(&ep7211);
-}
-
-static int ep7211_open(struct sir_dev *dev)
+static int clps711x_dongle_open(struct sir_dev *dev)
 {
 	unsigned int syscon;
 
@@ -58,7 +24,7 @@ static int ep7211_open(struct sir_dev *dev)
 	return 0;
 }
 
-static int ep7211_close(struct sir_dev *dev)
+static int clps711x_dongle_close(struct sir_dev *dev)
 {
 	unsigned int syscon;
 
@@ -70,20 +36,35 @@ static int ep7211_close(struct sir_dev *dev)
 	return 0;
 }
 
-static int ep7211_change_speed(struct sir_dev *dev, unsigned speed)
+static struct dongle_driver clps711x_dongle = {
+	.owner		= THIS_MODULE,
+	.driver_name	= "EP7211 IR driver",
+	.type		= IRDA_EP7211_DONGLE,
+	.open		= clps711x_dongle_open,
+	.close		= clps711x_dongle_close,
+};
+
+static int clps711x_sir_probe(struct platform_device *pdev)
 {
-	return 0;
+	return irda_register_dongle(&clps711x_dongle);
 }
 
-static int ep7211_reset(struct sir_dev *dev)
+static int clps711x_sir_remove(struct platform_device *pdev)
 {
-	return 0;
+	return irda_unregister_dongle(&clps711x_dongle);
 }
 
+static struct platform_driver clps711x_sir_driver = {
+	.driver	= {
+		.name	= "sir-clps711x",
+		.owner	= THIS_MODULE,
+	},
+	.probe	= clps711x_sir_probe,
+	.remove	= clps711x_sir_remove,
+};
+module_platform_driver(clps711x_sir_driver);
+
 MODULE_AUTHOR("Samuel Ortiz <samuel@sortiz.org>");
 MODULE_DESCRIPTION("EP7211 IR dongle driver");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("irda-dongle-13"); /* IRDA_EP7211_DONGLE */
-
-module_init(ep7211_sir_init);
-module_exit(ep7211_sir_cleanup);
-- 
1.7.8.6
