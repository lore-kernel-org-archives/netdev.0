From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH v5 4/4] net: phy: leds: add support for led triggers on phy
 link state change
Date: Mon, 17 Oct 2016 10:49:55 -0500
Message-ID: <1476719395-28273-5-git-send-email-zach.brown@ni.com>
References: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 andrew@lunn.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 rpurdie@rpsys.net, gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net,
 j.anaszewski@samsung.com, linux-leds@vger.kernel.org, mlindner@marvell.com
To: <f.fainelli@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Create an option CONFIG_LED_TRIGGER_PHY (default n), which will create a
set of led triggers for each instantiated PHY device. There is one LED
trigger per link-speed, per-phy.
The triggers are registered during phy_attach and unregistered during
phy_detach.

This allows for a user to configure their system to allow a set of LEDs
not controlled by the phy to represent link state changes on the phy.
LEDS controlled by the phy are unaffected.

For example, we have a board where some of the leds in the
RJ45 socket are controlled by the phy, but others are not. Using the
triggers provided by this patch the leds not controlled by the phy can
be configured to show the current speed of the ethernet connection. The
leds controlled by the phy are unaffected.

Signed-off-by: Josh Cartwright <josh.cartwright@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/phy/Kconfig            |  13 ++++
 drivers/net/phy/Makefile           |   1 +
 drivers/net/phy/phy.c              |   1 +
 drivers/net/phy/phy_device.c       |   5 ++
 drivers/net/phy/phy_led_triggers.c | 136 +++++++++++++++++++++++++++++++++++++
 include/linux/phy.h                |   7 ++
 include/linux/phy_led_triggers.h   |  51 ++++++++++++++
 7 files changed, 214 insertions(+)
 create mode 100644 drivers/net/phy/phy_led_triggers.c
 create mode 100644 include/linux/phy_led_triggers.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 5078a0d..54c8eb8 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -15,6 +15,19 @@ if PHYLIB
 config SWPHY
 	bool
 
+config LED_TRIGGER_PHY
+	bool "Support LED triggers for tracking link state"
+	depends on LEDS_TRIGGERS
+	---help---
+	  Adds support for a set of LED trigger events per-PHY.  Link
+	  state change will trigger the events, for consumption by an
+	  LED class driver.  There are triggers for each link speed currently
+	  supported by the phy, and are of the form:
+	       <mii bus id>:<phy>:<speed>
+
+	  Where speed is in the form:
+		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
+
 comment "MDIO bus device drivers"
 
 config MDIO_BCM_IPROC
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
index 82ee233..ef0e3d0 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -931,6 +931,7 @@ EXPORT_SYMBOL(phy_start);
 static void phy_adjust_link(struct phy_device *phydev)
 {
 	phydev->adjust_link(phydev->attached_dev);
+	phy_led_trigger_change_speed(phydev);
 }
 
 /**
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e977ba9..b41ebd5 100644
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
@@ -916,6 +917,8 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	else
 		phy_resume(phydev);
 
+	phy_led_triggers_register(phydev);
+
 	return err;
 
 error:
@@ -989,6 +992,8 @@ void phy_detach(struct phy_device *phydev)
 		}
 	}
 
+	phy_led_triggers_unregister(phydev);
+
 	/*
 	 * The phydev might go away on the put_device() below, so avoid
 	 * a use-after-free bug by reading the underlying bus first.
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
new file mode 100644
index 0000000..cda600a
--- /dev/null
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -0,0 +1,136 @@
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
+	unsigned int i;
+
+	for (i = 0; i < phy->phy_num_led_triggers; i++) {
+		if (phy->phy_led_triggers[i].speed == speed)
+			return &phy->phy_led_triggers[i];
+	}
+	return NULL;
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
+			     "No phy led trigger registered for speed(%d)\n",
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
+				    struct phy_led_trigger *plt,
+				    unsigned int speed)
+{
+	char name_suffix[PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE];
+
+	plt->speed = speed;
+
+	if (speed < SPEED_1000)
+		snprintf(name_suffix, sizeof(name_suffix), "%dMbps", speed);
+	else if (speed == SPEED_2500)
+		snprintf(name_suffix, sizeof(name_suffix), "2.5Gbps");
+	else
+		snprintf(name_suffix, sizeof(name_suffix), "%dGbps",
+			 DIV_ROUND_CLOSEST(speed, 1000));
+
+	snprintf(plt->name, sizeof(plt->name), PHY_ID_FMT ":%s",
+		 phy->mdio.bus->id, phy->mdio.addr, name_suffix);
+	plt->trigger.name = plt->name;
+
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
+	unsigned int speeds[50];
+
+	phy->phy_num_led_triggers = phy_supported_speeds(phy, speeds,
+							 ARRAY_SIZE(speeds));
+	if (!phy->phy_num_led_triggers)
+		return 0;
+
+	phy->phy_led_triggers = devm_kzalloc(&phy->mdio.dev,
+					    sizeof(struct phy_led_trigger) *
+						   phy->phy_num_led_triggers,
+					    GFP_KERNEL);
+	if (!phy->phy_led_triggers)
+		return -ENOMEM;
+
+	for (i = 0; i < phy->phy_num_led_triggers; i++) {
+		err = phy_led_trigger_register(phy, &phy->phy_led_triggers[i],
+					       speeds[i]);
+		if (err)
+			goto out_unreg;
+	}
+
+	phy->last_triggered = NULL;
+	phy_led_trigger_change_speed(phy);
+
+	return 0;
+out_unreg:
+	while (i--)
+		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
+	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
+	return err;
+}
+EXPORT_SYMBOL_GPL(phy_led_triggers_register);
+
+void phy_led_triggers_unregister(struct phy_device *phy)
+{
+	int i;
+
+	for (i = 0; i < phy->phy_num_led_triggers; i++)
+		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
+
+	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
+}
+EXPORT_SYMBOL_GPL(phy_led_triggers_unregister);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 8761f30..8ecfd75 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,6 +25,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
+#include <linux/phy_led_triggers.h>
 
 #include <linux/atomic.h>
 
@@ -420,6 +421,12 @@ struct phy_device {
 
 	int link_timeout;
 
+#ifdef CONFIG_LED_TRIGGER_PHY
+	struct phy_led_trigger *phy_led_triggers;
+	unsigned int phy_num_led_triggers;
+	struct phy_led_trigger *last_triggered;
+#endif
+
 	/*
 	 * Interrupt number for this PHY
 	 * -1 means no interrupt
diff --git a/include/linux/phy_led_triggers.h b/include/linux/phy_led_triggers.h
new file mode 100644
index 0000000..a2daea0
--- /dev/null
+++ b/include/linux/phy_led_triggers.h
@@ -0,0 +1,51 @@
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
+
+#define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	10
+#define PHY_MII_BUS_ID_SIZE	(20 - 3)
+
+#define PHY_LINK_LED_TRIGGER_NAME_SIZE (PHY_MII_BUS_ID_SIZE + \
+				       FIELD_SIZEOF(struct mdio_device, addr)+\
+				       PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE)
+
+struct phy_led_trigger {
+	struct led_trigger trigger;
+	char name[PHY_LINK_LED_TRIGGER_NAME_SIZE];
+	unsigned int speed;
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
