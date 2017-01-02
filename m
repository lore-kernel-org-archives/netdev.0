From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] rfkill: remove rfkill-regulator
Date: Mon,  2 Jan 2017 16:01:57 +0100
Message-ID: <20170102150157.26745-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guiming Zhuo <gmzhuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>,
        Paul Cercueil <paul-icTtO2rgO2OTuSrc4Mpeew@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Maarten ter Huurne <maarten-Ph2Y2OKCxY1M656bX5wj8A@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

There are no users of this ("vrfkill") in the tree, so it's just
dead code - remove it.

This also isn't really how rfkill is supposed to be used - it's
intended as a signalling mechanism to/from the device, which the
driver (and partially cfg80211) will handle - having a separate
rfkill instance for a regulator is confusing, the driver should
use the regulator instead to turn off the device when requested.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/rfkill-regulator.h |  48 ------------
 net/rfkill/Kconfig               |  11 ---
 net/rfkill/Makefile              |   1 -
 net/rfkill/rfkill-regulator.c    | 154 ---------------------------------------
 4 files changed, 214 deletions(-)
 delete mode 100644 include/linux/rfkill-regulator.h
 delete mode 100644 net/rfkill/rfkill-regulator.c

diff --git a/include/linux/rfkill-regulator.h b/include/linux/rfkill-regulator.h
deleted file mode 100644
index aca36bc83315..000000000000
--- a/include/linux/rfkill-regulator.h
+++ /dev/null
@@ -1,48 +0,0 @@
-/*
- * rfkill-regulator.c - Regulator consumer driver for rfkill
- *
- * Copyright (C) 2009  Guiming Zhuo <gmzhuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
- * Copyright (C) 2011  Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- */
-
-#ifndef __LINUX_RFKILL_REGULATOR_H
-#define __LINUX_RFKILL_REGULATOR_H
-
-/*
- * Use "vrfkill" as supply id when declaring the regulator consumer:
- *
- * static struct regulator_consumer_supply pcap_regulator_V6_consumers [] = {
- * 	{ .dev_name = "rfkill-regulator.0", .supply = "vrfkill" },
- * };
- *
- * If you have several regulator driven rfkill, you can append a numerical id to
- * .dev_name as done above, and use the same id when declaring the platform
- * device:
- *
- * static struct rfkill_regulator_platform_data ezx_rfkill_bt_data = {
- * 	.name  = "ezx-bluetooth",
- * 	.type  = RFKILL_TYPE_BLUETOOTH,
- * };
- *
- * static struct platform_device a910_rfkill = {
- * 	.name  = "rfkill-regulator",
- * 	.id    = 0,
- * 	.dev   = {
- * 		.platform_data = &ezx_rfkill_bt_data,
- * 	},
- * };
- */
-
-#include <linux/rfkill.h>
-
-struct rfkill_regulator_platform_data {
-	char *name;             /* the name for the rfkill switch */
-	enum rfkill_type type;  /* the type as specified in rfkill.h */
-};
-
-#endif /* __LINUX_RFKILL_REGULATOR_H */
diff --git a/net/rfkill/Kconfig b/net/rfkill/Kconfig
index 868f1ad0415a..060600b03fad 100644
--- a/net/rfkill/Kconfig
+++ b/net/rfkill/Kconfig
@@ -23,17 +23,6 @@ config RFKILL_INPUT
 	depends on INPUT = y || RFKILL = INPUT
 	default y if !EXPERT
 
-config RFKILL_REGULATOR
-	tristate "Generic rfkill regulator driver"
-	depends on RFKILL || !RFKILL
-	depends on REGULATOR
-	help
-          This options enable controlling radio transmitters connected to
-          voltage regulator using the regulator framework.
-
-          To compile this driver as a module, choose M here: the module will
-          be called rfkill-regulator.
-
 config RFKILL_GPIO
 	tristate "GPIO RFKILL driver"
 	depends on RFKILL
diff --git a/net/rfkill/Makefile b/net/rfkill/Makefile
index 311768783f4a..87a80aded0b3 100644
--- a/net/rfkill/Makefile
+++ b/net/rfkill/Makefile
@@ -5,5 +5,4 @@
 rfkill-y			+= core.o
 rfkill-$(CONFIG_RFKILL_INPUT)	+= input.o
 obj-$(CONFIG_RFKILL)		+= rfkill.o
-obj-$(CONFIG_RFKILL_REGULATOR)	+= rfkill-regulator.o
 obj-$(CONFIG_RFKILL_GPIO)	+= rfkill-gpio.o
diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
deleted file mode 100644
index 50cd26a48e87..000000000000
--- a/net/rfkill/rfkill-regulator.c
+++ /dev/null
@@ -1,154 +0,0 @@
-/*
- * rfkill-regulator.c - Regulator consumer driver for rfkill
- *
- * Copyright (C) 2009  Guiming Zhuo <gmzhuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
- * Copyright (C) 2011  Antonio Ospite <ospite-aNJ+ML1ZbiP93QAQaVx+gl6hYfS7NtTn@public.gmane.org>
- *
- * Implementation inspired by leds-regulator driver.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- */
-
-#include <linux/module.h>
-#include <linux/err.h>
-#include <linux/slab.h>
-#include <linux/platform_device.h>
-#include <linux/regulator/consumer.h>
-#include <linux/rfkill.h>
-#include <linux/rfkill-regulator.h>
-
-struct rfkill_regulator_data {
-	struct rfkill *rf_kill;
-	bool reg_enabled;
-
-	struct regulator *vcc;
-};
-
-static int rfkill_regulator_set_block(void *data, bool blocked)
-{
-	struct rfkill_regulator_data *rfkill_data = data;
-	int ret = 0;
-
-	pr_debug("%s: blocked: %d\n", __func__, blocked);
-
-	if (blocked) {
-		if (rfkill_data->reg_enabled) {
-			regulator_disable(rfkill_data->vcc);
-			rfkill_data->reg_enabled = false;
-		}
-	} else {
-		if (!rfkill_data->reg_enabled) {
-			ret = regulator_enable(rfkill_data->vcc);
-			if (!ret)
-				rfkill_data->reg_enabled = true;
-		}
-	}
-
-	pr_debug("%s: regulator_is_enabled after set_block: %d\n", __func__,
-		regulator_is_enabled(rfkill_data->vcc));
-
-	return ret;
-}
-
-static struct rfkill_ops rfkill_regulator_ops = {
-	.set_block = rfkill_regulator_set_block,
-};
-
-static int rfkill_regulator_probe(struct platform_device *pdev)
-{
-	struct rfkill_regulator_platform_data *pdata = pdev->dev.platform_data;
-	struct rfkill_regulator_data *rfkill_data;
-	struct regulator *vcc;
-	struct rfkill *rf_kill;
-	int ret = 0;
-
-	if (pdata == NULL) {
-		dev_err(&pdev->dev, "no platform data\n");
-		return -ENODEV;
-	}
-
-	if (pdata->name == NULL || pdata->type == 0) {
-		dev_err(&pdev->dev, "invalid name or type in platform data\n");
-		return -EINVAL;
-	}
-
-	vcc = regulator_get_exclusive(&pdev->dev, "vrfkill");
-	if (IS_ERR(vcc)) {
-		dev_err(&pdev->dev, "Cannot get vcc for %s\n", pdata->name);
-		ret = PTR_ERR(vcc);
-		goto out;
-	}
-
-	rfkill_data = kzalloc(sizeof(*rfkill_data), GFP_KERNEL);
-	if (rfkill_data == NULL) {
-		ret = -ENOMEM;
-		goto err_data_alloc;
-	}
-
-	rf_kill = rfkill_alloc(pdata->name, &pdev->dev,
-				pdata->type,
-				&rfkill_regulator_ops, rfkill_data);
-	if (rf_kill == NULL) {
-		ret = -ENOMEM;
-		goto err_rfkill_alloc;
-	}
-
-	if (regulator_is_enabled(vcc)) {
-		dev_dbg(&pdev->dev, "Regulator already enabled\n");
-		rfkill_data->reg_enabled = true;
-	}
-	rfkill_data->vcc = vcc;
-	rfkill_data->rf_kill = rf_kill;
-
-	ret = rfkill_register(rf_kill);
-	if (ret) {
-		dev_err(&pdev->dev, "Cannot register rfkill device\n");
-		goto err_rfkill_register;
-	}
-
-	platform_set_drvdata(pdev, rfkill_data);
-	dev_info(&pdev->dev, "%s initialized\n", pdata->name);
-
-	return 0;
-
-err_rfkill_register:
-	rfkill_destroy(rf_kill);
-err_rfkill_alloc:
-	kfree(rfkill_data);
-err_data_alloc:
-	regulator_put(vcc);
-out:
-	return ret;
-}
-
-static int rfkill_regulator_remove(struct platform_device *pdev)
-{
-	struct rfkill_regulator_data *rfkill_data = platform_get_drvdata(pdev);
-	struct rfkill *rf_kill = rfkill_data->rf_kill;
-
-	rfkill_unregister(rf_kill);
-	rfkill_destroy(rf_kill);
-	regulator_put(rfkill_data->vcc);
-	kfree(rfkill_data);
-
-	return 0;
-}
-
-static struct platform_driver rfkill_regulator_driver = {
-	.probe = rfkill_regulator_probe,
-	.remove = rfkill_regulator_remove,
-	.driver = {
-		.name = "rfkill-regulator",
-	},
-};
-
-module_platform_driver(rfkill_regulator_driver);
