From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH] phy, leds: add support for led triggers on phy link state change
Date: Wed, 17 Aug 2016 09:15:57 -0500
Message-ID: <1471443357-2582-1-git-send-email-zach.brown@ni.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	josh.cartwright@ni.com, nathan.sullivan@ni.com,
	Zach Brown <zach.brown@ni.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Cartwright <josh.cartwright@ni.com>

This introduces an option CONFIG_LED_TRIGGER_PHY (default n), which will
create a set of led triggers for each instantiated PHY device.  There is
one LED trigger per link-speed, per-phy.

This allows for a user to configure their system to allow a set of LEDs
to represent link state changes on the phy.

Signed-off-by: Josh Cartwright <josh.cartwright@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/phy/Kconfig            |  12 +++++
 drivers/net/phy/Makefile           |   1 +
 drivers/net/phy/phy.c              |   8 +++
 drivers/net/phy/phy_device.c       |   4 ++
 drivers/net/phy/phy_led_triggers.c | 107 +++++++++++++++++++++++++++++++++++++
 include/linux/phy.h                |   9 ++++
 include/linux/phy_led_triggers.h   |  42 +++++++++++++++
 7 files changed, 183 insertions(+)
 create mode 100644 drivers/net/phy/phy_led_triggers.c
 create mode 100644 include/linux/phy_led_triggers.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d66133bf..ebab7cc 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -169,6 +169,18 @@ config FIXED_PHY
 
 	  Currently tested with mpc866ads and mpc8349e-mitx.
 
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
+	  Where speed is one of: 10Mb, 100Mb, Gb, 2.5Gb, or 10GbE.
+
 config MDIO_BITBANG
 	tristate "Support for bitbanged MDIO buses"
 	help
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 73d65ce..0d69da7 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed_phy.o
+obj-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c5dc2c36..1baaf0f 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -934,6 +934,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->state = PHY_NOLINK;
 			netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
+			phy_led_trigger_change_speed(phydev);
 			break;
 		}
 
@@ -947,6 +948,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->state = PHY_RUNNING;
 			netif_carrier_on(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
+			phy_led_trigger_change_speed(phydev);
 
 		} else if (0 == phydev->link_timeout--)
 			needs_aneg = true;
@@ -974,6 +976,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->state = PHY_RUNNING;
 			netif_carrier_on(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
+			phy_led_trigger_change_speed(phydev);
 		}
 		break;
 	case PHY_FORCING:
@@ -990,6 +993,7 @@ void phy_state_machine(struct work_struct *work)
 		}
 
 		phydev->adjust_link(phydev->attached_dev);
+		phy_led_trigger_change_speed(phydev);
 		break;
 	case PHY_RUNNING:
 		/* Only register a CHANGE if we are polling and link changed
@@ -1019,6 +1023,7 @@ void phy_state_machine(struct work_struct *work)
 		}
 
 		phydev->adjust_link(phydev->attached_dev);
+		phy_led_trigger_change_speed(phydev);
 
 		if (phy_interrupt_is_valid(phydev))
 			err = phy_config_interrupt(phydev,
@@ -1029,6 +1034,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->link = 0;
 			netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
+			phy_led_trigger_change_speed(phydev);
 			do_suspend = true;
 		}
 		break;
@@ -1053,6 +1059,7 @@ void phy_state_machine(struct work_struct *work)
 					phydev->state = PHY_NOLINK;
 				}
 				phydev->adjust_link(phydev->attached_dev);
+				phy_led_trigger_change_speed(phydev);
 			} else {
 				phydev->state = PHY_AN;
 				phydev->link_timeout = PHY_AN_TIMEOUT;
@@ -1069,6 +1076,7 @@ void phy_state_machine(struct work_struct *work)
 				phydev->state = PHY_NOLINK;
 			}
 			phydev->adjust_link(phydev->attached_dev);
+			phy_led_trigger_change_speed(phydev);
 		}
 		break;
 	}
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
index 0000000..acbb7a9
--- /dev/null
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -0,0 +1,107 @@
+/* Copyright (C) 2012 National Instruments Corp.
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
+#include <linux/leds.h>
+#include <linux/phy.h>
+
+void phy_led_trigger_change_speed(struct phy_device *phy)
+{
+	struct phy_led_trigger *plt;
+
+	if (!phy->link) {
+		if (phy->last_triggered) {
+			led_trigger_event(&phy->last_triggered->trigger,
+					  LED_OFF);
+			phy->last_triggered = NULL;
+			return;
+		}
+		return;
+	}
+
+	switch (phy->speed) {
+	case SPEED_10:
+		plt = &phy->phy_led_trigger[0];
+		break;
+	case SPEED_100:
+		plt = &phy->phy_led_trigger[1];
+		break;
+	case SPEED_1000:
+		plt = &phy->phy_led_trigger[2];
+		break;
+	case SPEED_2500:
+		plt = &phy->phy_led_trigger[3];
+		break;
+	case SPEED_10000:
+		plt = &phy->phy_led_trigger[4];
+		break;
+	default:
+		plt = NULL;
+		break;
+	}
+
+	if (plt != phy->last_triggered) {
+		led_trigger_event(&phy->last_triggered->trigger, LED_OFF);
+		led_trigger_event(&plt->trigger, LED_FULL);
+		phy->last_triggered = plt;
+	}
+}
+
+static int phy_led_trigger_register(struct phy_device *phy,
+				    struct phy_led_trigger *plt, int i)
+{
+	static const char * const name_suffix[] = {
+		"10Mb",
+		"100Mb",
+		"Gb",
+		"2.5Gb",
+		"10GbE",
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
+
+void phy_led_triggers_unregister(struct phy_device *phy)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(phy->phy_led_trigger); i++)
+		phy_led_trigger_unregister(&phy->phy_led_trigger[i]);
+}
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2d24b28..315dd06 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,6 +25,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
+#include <linux/phy_led_triggers.h>
 
 #include <linux/atomic.h>
 
@@ -402,6 +403,14 @@ struct phy_device {
 
 	int link_timeout;
 
+#ifdef CONFIG_LED_TRIGGER_PHY
+	/*
+	 * A led_trigger per SPEED_*
+	 */
+	struct phy_led_trigger phy_led_trigger[5];
+	struct phy_led_trigger *last_triggered;
+#endif
+
 	/*
 	 * Interrupt number for this PHY
 	 * -1 means no interrupt
diff --git a/include/linux/phy_led_triggers.h b/include/linux/phy_led_triggers.h
new file mode 100644
index 0000000..8f27d99
--- /dev/null
+++ b/include/linux/phy_led_triggers.h
@@ -0,0 +1,42 @@
+/* Copyright (C) 2012 National Instruments Corp.
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
+struct phy_led_trigger {
+	struct led_trigger trigger;
+	char name[64];
+};
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
