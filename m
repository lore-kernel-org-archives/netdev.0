From: Zach Brown <zach.brown@ni.com>
Subject: [RFC v3 3/3] phy,leds: add support for led triggers on phy link state change
Date: Fri, 7 Oct 2016 16:14:57 -0500
Message-ID: <1475874897-29720-4-git-send-email-zach.brown@ni.com>
References: <1475874897-29720-1-git-send-email-zach.brown@ni.com>
Cc: mlindner@marvell.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
        Larry.Finger@lwfinger.net, gregkh@linuxfoundation.org,
        rpurdie@rpsys.net, j.anaszewski@samsung.com,
        linux-leds@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:60325 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932778AbcJGVPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 17:15:16 -0400
In-Reply-To: <1475874897-29720-1-git-send-email-zach.brown@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Cartwright <josh.cartwright@ni.com>

Create an option CONFIG_LED_TRIGGER_PHY (default n), which will
create a set of led triggers for each instantiated PHY device.  There is
one LED trigger per link-speed, per-phy.

This allows for a user to configure their system to allow a set of LEDs
to represent link state changes on the phy.

Signed-off-by: Josh Cartwright <josh.cartwright@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/phy/Kconfig            |  13 +++-
 drivers/net/phy/Makefile           |   1 +
 drivers/net/phy/phy.c              |   1 +
 drivers/net/phy/phy_device.c       |   4 ++
 drivers/net/phy/phy_led_triggers.c | 121 +++++++++++++++++++++++++++++++++++++
 include/linux/phy.h                |   9 +++
 include/linux/phy_led_triggers.h   |  52 ++++++++++++++++
 7 files changed, 200 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/phy/phy_led_triggers.c
 create mode 100644 include/linux/phy_led_triggers.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 5078a0d..4fd912d 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -25,6 +25,18 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config LED_TRIGGER_PHY
+	bool "Support LED triggers for tracking link state"
+	depends on LEDS_TRIGGERS
+	---help---
+	  Adds support for a set of LED trigger events per-PHY.  Link
+	  state change will trigger the events, for consumption by an
+	  LED class driver.  There are triggers for each link speed,
+	  and are of the form:
+	       <mii bus id>:<phy>:<speed>
+
+	  Where speed is one of: 10Mbps, 100Mbps, 1Gbps, 2.5Gbps, or 10Gbps.
+
 config MDIO_BCM_UNIMAC
 	tristate "Broadcom UniMAC MDIO bus controller"
 	depends on HAS_IOMEM
@@ -40,7 +52,6 @@ config MDIO_BITBANG
 	  This module implements the MDIO bus protocol in software,
 	  for use by low level drivers that export the ability to
 	  drive the relevant pins.
-
 	  If in doubt, say N.
 
 config MDIO_BUS_MUX
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e58667d..86d12cd 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -2,6 +2,7 @@
 
 libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o
 libphy-$(CONFIG_SWPHY)		+= swphy.o
+libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 
 obj-$(CONFIG_PHYLIB)		+= libphy.o
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f5721db..e5f9fee7 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -896,6 +896,7 @@ EXPORT_SYMBOL(phy_start);
 static void phy_adjust_link(struct phy_device *phydev)
 {
 	phydev->adjust_link(phydev->attached_dev);
+	phy_led_trigger_change_speed(phydev);
 }
 
 /**
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e977ba9..4671c13 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -30,6 +30,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/phy_led_triggers.h>
 #include <linux/mdio.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
@@ -57,6 +58,7 @@ static void phy_mdio_device_free(struct mdio_device *mdiodev)
 
 static void phy_device_release(struct device *dev)
 {
+	phy_led_triggers_unregister(to_phy_device(dev));
 	kfree(to_phy_device(dev));
 }
 
@@ -345,6 +347,8 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 
 	dev->state = PHY_DOWN;
 
+	phy_led_triggers_register(dev);
+
 	mutex_init(&dev->lock);
 	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
 	INIT_WORK(&dev->phy_queue, phy_change);
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
new file mode 100644
index 0000000..32326d7
--- /dev/null
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -0,0 +1,121 @@
+/* Copyright (C) 2016 National Instruments Corp.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+  * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include <linux/leds.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+
+static struct phy_led_trigger *phy_speed_to_led_trigger(struct phy_device *phy,
+							unsigned int speed)
+{
+	switch (speed) {
+	case SPEED_10:
+		return &phy->phy_led_trigger[0];
+	case SPEED_100:
+		return &phy->phy_led_trigger[1];
+	case SPEED_1000:
+		return &phy->phy_led_trigger[2];
+	case SPEED_2500:
+		return &phy->phy_led_trigger[3];
+	case SPEED_10000:
+		return &phy->phy_led_trigger[4];
+	default:
+		return NULL;
+	}
+}
+
+void phy_led_trigger_change_speed(struct phy_device *phy)
+{
+	struct phy_led_trigger *plt;
+
+	if (!phy->link)
+		goto out_change_speed;
+
+	if (phy->speed == 0)
+		return;
+
+	plt = phy_speed_to_led_trigger(phy, phy->speed);
+	if (!plt) {
+		netdev_alert(phy->attached_dev,
+			     "Unsupported trigger speed %u (update phy_led_trigger.c)\n",
+			     phy->speed);
+		goto out_change_speed;
+	}
+
+	if (plt != phy->last_triggered) {
+		led_trigger_event(&phy->last_triggered->trigger, LED_OFF);
+		led_trigger_event(&plt->trigger, LED_FULL);
+		phy->last_triggered = plt;
+	}
+	return;
+
+out_change_speed:
+	if (phy->last_triggered) {
+		led_trigger_event(&phy->last_triggered->trigger,
+				  LED_OFF);
+		phy->last_triggered = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(phy_led_trigger_change_speed);
+
+static int phy_led_trigger_register(struct phy_device *phy,
+				    struct phy_led_trigger *plt, int i)
+{
+	static const char * const name_suffix[] = {
+		"10Mbps",
+		"100Mbps",
+		"1Gbps",
+		"2.5Gbps",
+		"10Gbps",
+	};
+	snprintf(plt->name, sizeof(plt->name), PHY_ID_FMT ":%s",
+		 phy->mdio.bus->id, phy->mdio.addr, name_suffix[i]);
+	plt->trigger.name = plt->name;
+	return led_trigger_register(&plt->trigger);
+}
+
+static void phy_led_trigger_unregister(struct phy_led_trigger *plt)
+{
+	led_trigger_unregister(&plt->trigger);
+}
+
+int phy_led_triggers_register(struct phy_device *phy)
+{
+	int i, err;
+
+	for (i = 0; i < ARRAY_SIZE(phy->phy_led_trigger); i++) {
+		err = phy_led_trigger_register(phy, &phy->phy_led_trigger[i],
+					       i);
+		if (err)
+			goto out_unreg;
+	}
+
+	phy->last_triggered = NULL;
+	phy_led_trigger_change_speed(phy);
+
+	return 0;
+
+out_unreg:
+	while (i--)
+		phy_led_trigger_unregister(&phy->phy_led_trigger[i]);
+	return err;
+}
+EXPORT_SYMBOL_GPL(phy_led_triggers_register);
+
+void phy_led_triggers_unregister(struct phy_device *phy)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(phy->phy_led_trigger); i++)
+		phy_led_trigger_unregister(&phy->phy_led_trigger[i]);
+}
+EXPORT_SYMBOL_GPL(phy_led_triggers_unregister);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e25f183..6af4d6d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,6 +25,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
+#include <linux/phy_led_triggers.h>
 
 #include <linux/atomic.h>
 
@@ -405,6 +406,14 @@ struct phy_device {
 
 	int link_timeout;
 
+#ifdef CONFIG_LED_TRIGGER_PHY
+	/*
+	 * A led_trigger per SPEED_*
+	 */
+	struct phy_led_trigger phy_led_trigger[PHY_LINK_LED_MAX_TRIGGERS];
+	struct phy_led_trigger *last_triggered;
+#endif
+
 	/*
 	 * Interrupt number for this PHY
 	 * -1 means no interrupt
diff --git a/include/linux/phy_led_triggers.h b/include/linux/phy_led_triggers.h
new file mode 100644
index 0000000..dfea5d6
--- /dev/null
+++ b/include/linux/phy_led_triggers.h
@@ -0,0 +1,52 @@
+/* Copyright (C) 2016 National Instruments Corp.
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
+ */
+#ifndef __PHY_LED_TRIGGERS
+#define __PHY_LED_TRIGGERS
+
+struct phy_device;
+
+#ifdef CONFIG_LED_TRIGGER_PHY
+
+#include <linux/leds.h>
+#include <linux/phy.h>
+
+#define PHY_LINK_LED_MAX_TRIGGERS	5
+#define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	7
+#define PHY_MII_BUS_ID_SIZE	(20 - 3)
+
+#define PHY_LINK_LED_TRIGGER_NAME_SIZE (PHY_MII_BUS_ID_SIZE + \
+				       FIELD_SIZEOF(struct mdio_device, addr)+\
+				       PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE)
+
+struct phy_led_trigger {
+	struct led_trigger trigger;
+	char name[PHY_LINK_LED_TRIGGER_NAME_SIZE];
+};
+
+
+extern int phy_led_triggers_register(struct phy_device *phy);
+extern void phy_led_triggers_unregister(struct phy_device *phy);
+extern void phy_led_trigger_change_speed(struct phy_device *phy);
+
+#else
+
+static inline int phy_led_triggers_register(struct phy_device *phy)
+{
+	return 0;
+}
+static inline void phy_led_triggers_unregister(struct phy_device *phy) { }
+static inline void phy_led_trigger_change_speed(struct phy_device *phy) { }
+
+#endif
+
+#endif
-- 
2.7.4
