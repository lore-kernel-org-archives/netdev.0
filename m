From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rt2x00: remove hardware button support
Date: Thu, 21 Sep 2006 20:28:22 +0200
Message-ID: <200609212028.23045.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:44516 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751336AbWIUS3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 14:29:00 -0400
Received: by nf-out-0910.google.com with SMTP id o25so838073nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 11:28:58 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

compilation was broken in rt2x00 due to rfkill
attributed sneaking into rt2x00dev structure.
rfkill will replace current hardware button support
evantually, but lets fix rt2x00 compilation and
remove hardware button support for this time
until rfkill has been finished.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/Kconfig
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-09-21 19:59:27.000000000 +0200
+++ wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-09-21 20:05:20.000000000 +0200
@@ -15,15 +15,6 @@
 
 	When compiled as a module, this driver will be called "rt2400pci.ko".
 
-config RT2400PCI_BUTTON
-	bool "Ralink rt2400 hardware button support"
-	depends on RT2400PCI && X86
-	---help---
-	In some notebooks the rt2400 chipset is integrated in the machine,
-	with this option enabled the device will periodically poll the
-	the status of this button and will send and ACPI event when
-	the button has been pressed.
-
 config RT2400PCI_DEBUG
 	bool "Ralink rt2400 debug output"
 	depends on RT2400PCI
@@ -38,15 +29,6 @@
 
 	When compiled as a module, this driver will be called "rt2500pci.ko".
 
-config RT2500PCI_BUTTON
-	bool "Ralink rt2500 hardware button support"
-	depends on RT2500PCI && X86
-	---help---
-	In some notebooks the rt2500 chipset is integrated in the machine,
-	with this option enabled the device will periodically poll the
-	the status of this button and will send and ACPI event when
-	the button has been pressed.
-
 config RT2500PCI_DEBUG
 	bool "Ralink rt2500 debug output"
 	depends on RT2500PCI
@@ -61,15 +43,6 @@
 
 	When compiled as a module, this driver will be called "rt61pci.ko".
 
-config RT61PCI_BUTTON
-	bool "Ralink rt61 hardware button support"
-	depends on RT61PCI && X86
-	---help---
-	In some notebooks the rt61 chipset is integrated in the machine,
-	with this option enabled the device will periodically poll the
-	the status of this button and will send and ACPI event when
-	the button has been pressed.
-
 config RT61PCI_DEBUG
 	bool "Ralink rt61 debug output"
 	depends on RT61PCI
diff -rU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-09-21 19:59:27.000000000 +0200
+++ wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-09-21 20:09:00.000000000 +0200
@@ -51,10 +51,6 @@
 #define CONFIG_RT2X00_DEBUG
 #endif /* CONFIG_RT2400PCI_DEBUG */
 
-#ifdef CONFIG_RT2400PCI_BUTTON
-#define CONFIG_RT2X00_BUTTON
-#endif /* CONFIG_RT2400PCI_BUTTON */
-
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2400pci.h"
@@ -346,23 +342,6 @@
 		rt2x00_eeprom_read(rt2x00dev, word + i, data++);
 }
 
-#ifdef CONFIG_RT2400PCI_BUTTON
-/*
- * Hardware button poll handler.
- */
-static void rt2400pci_button_poll(unsigned long data)
-{
-	struct rt2x00_dev *rt2x00dev = (struct rt2x00_dev*)data;
-	u32 reg;
-
-	rt2x00_register_read(rt2x00dev, GPIOCSR, &reg);
-	rt2x00pci_button_status(
-		rt2x00dev, rt2x00_get_field32(reg, GPIOCSR_BIT0));
-}
-#else /* CONFIG_RT2400PCI_BUTTON */
-static void rt2400pci_button_poll(unsigned long data){}
-#endif /* CONFIG_RT2400PCI_BUTTON */
-
 /*
  * Ethtool handlers.
  */
@@ -2750,11 +2729,6 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * Shutdown poll_timer for hardware button.
-	 */
-	rt2x00pci_button_stop(rt2x00dev);
-
-	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -2838,11 +2812,6 @@
 		goto exit;
 	}
 
-	/*
-	 * If required start hardware button polling.
-	 */
-	rt2x00pci_button_start(rt2x00dev, rt2400pci_button_poll);
-
 	return 0;
 
 exit:
@@ -3048,11 +3017,6 @@
 MODULE_PARM_DESC(debug, "Set this parameter to 1 to enable debug output.");
 #endif /* CONFIG_RT2400PCI_DEBUG */
 
-#ifdef CONFIG_RT2400PCI_BUTTON
-module_param_named(poll_delay, rt2x00_poll_delay, short, S_IRUGO);
-MODULE_PARM_DESC(debug, "Delay between WiFi button pollings (in 100ms).");
-#endif /* CONFIG_RT2400PCI_BUTTON */
-
 static struct pci_driver rt2400pci_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rt2400pci_device_table,
diff -rU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-09-21 19:59:27.000000000 +0200
+++ wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-09-21 20:09:12.000000000 +0200
@@ -51,10 +51,6 @@
 #define CONFIG_RT2X00_DEBUG
 #endif /* CONFIG_RT2500PCI_DEBUG */
 
-#ifdef CONFIG_RT2500PCI_BUTTON
-#define CONFIG_RT2X00_BUTTON
-#endif /* CONFIG_RT2500PCI_BUTTON */
-
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2500pci.h"
@@ -346,23 +342,6 @@
 		rt2x00_eeprom_read(rt2x00dev, word + i, data++);
 }
 
-#ifdef CONFIG_RT2500PCI_BUTTON
-/*
- * Hardware button poll handler.
- */
-static void rt2500pci_button_poll(unsigned long data)
-{
-	struct rt2x00_dev *rt2x00dev = (struct rt2x00_dev*)data;
-	u32 reg;
-
-	rt2x00_register_read(rt2x00dev, GPIOCSR, &reg);
-	rt2x00pci_button_status(
-		rt2x00dev, rt2x00_get_field32(reg, GPIOCSR_BIT0));
-}
-#else /* CONFIG_RT2500PCI_BUTTON */
-static void rt2500pci_button_poll(unsigned long data){}
-#endif /* CONFIG_RT2500PCI_BUTTON */
-
 /*
  * Ethtool handlers.
  */
@@ -3035,11 +3014,6 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * Shutdown poll_timer for hardware button.
-	 */
-	rt2x00pci_button_stop(rt2x00dev);
-
-	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -3123,11 +3097,6 @@
 		goto exit;
 	}
 
-	/*
-	 * If required start hardware button polling.
-	 */
-	rt2x00pci_button_start(rt2x00dev, rt2500pci_button_poll);
-
 	return 0;
 
 exit:
@@ -3333,11 +3302,6 @@
 MODULE_PARM_DESC(debug, "Set this parameter to 1 to enable debug output.");
 #endif /* CONFIG_RT2500PCI_DEBUG */
 
-#ifdef CONFIG_RT2500PCI_BUTTON
-module_param_named(poll_delay, rt2x00_poll_delay, short, S_IRUGO);
-MODULE_PARM_DESC(debug, "Delay between WiFi button pollings (in 100ms).");
-#endif /* CONFIG_RT2500PCI_BUTTON */
-
 static struct pci_driver rt2500pci_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rt2500pci_device_table,
diff -rU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-09-21 19:59:27.000000000 +0200
+++ wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-09-21 20:06:01.000000000 +0200
@@ -866,14 +866,6 @@
 	struct ieee80211_hw hw;
 
 	/*
-	 * If enabled, the structure for the
-	 * hardware button control.
-	 */
-#ifdef CONFIG_RT2X00_BUTTON
-	struct rfkill rfkill;
-#endif /* CONFIG_RT2X00_BUTTON */
-
-	/*
 	 * Queue for deferred work.
 	 */
 	struct workqueue_struct *workqueue;
diff -rU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-09-21 19:59:27.000000000 +0200
+++ wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-09-21 20:08:23.000000000 +0200
@@ -44,115 +44,4 @@
 #define EEPROM_WRITE_OPCODE	0x05
 #define EEPROM_READ_OPCODE	0x06
 
-/*
- * HW button structure.
- */
-#ifdef CONFIG_RT2X00_BUTTON
-#include <acpi/acpi_bus.h>
-
-struct rt2x00_button {
-	/*
-	 * ACPI device for generation of ACPI events.
-	 */
-	struct acpi_device acpi_dev;
-
-	/*
-	 * Timer for register polling.
-	 */
-	struct timer_list poll_timer;
-
-	/*
-	 * Timer delay.
-	 */
-	short poll_delay;
-
-	/*
-	 * Current status of button.
-	 */
-	short button_status:1;
-	short active_poll:1;
-	short __pad:14;
-};
-#endif /* CONFIG_RT2X00_BUTTON */
-
-/*
- * HW button variables & functions.
- * The delay between each poll is set by the module parameter.
- */
-#ifdef CONFIG_RT2X00_BUTTON
-/*
- * Module parameter.
- */
-static short rt2x00_poll_delay = 0;
-
-static inline void rt2x00pci_button_status(struct rt2x00_dev *rt2x00dev,
-	char status)
-{
-	struct rt2x00_button *button = &rt2x00dev->button;
-
-	if (!button->active_poll)
-		return;
-
-	if (status != button->button_status) {
-		button->button_status = status;
-		acpi_bus_generate_event(
-			&button->acpi_dev, ACPI_TYPE_EVENT, status);
-	}
-
-	button->poll_timer.expires = jiffies + button->poll_delay;
-
-	if (button->active_poll)
-		add_timer(&button->poll_timer);
-}
-
-static inline void rt2x00pci_button_start(struct rt2x00_dev *rt2x00dev,
-	void (*handler)(unsigned long data))
-{
-	struct rt2x00_button *button = &rt2x00dev->button;
-
-	/*
-	 * Only enable polling when the user has
-	 * set the poll delay module parameter,
-	 * and the device contains a hardware button.
-	 */
-	if(!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON) ||
-	   !rt2x00_poll_delay)
-		return;
-
-	strcpy(acpi_device_class(&button->acpi_dev), DRV_NAME "_button");
-	strcpy(acpi_device_bid(&button->acpi_dev), DRV_NAME);
-	strcpy(acpi_device_name(&button->acpi_dev), DRV_NAME);
-
-	init_timer(&button->poll_timer);
-
-	button->poll_delay = rt2x00_poll_delay * (HZ / 10);
-	button->button_status = 0;
-	button->active_poll = 1;
-
-	button->poll_timer.function = handler;
-	button->poll_timer.data = (unsigned long)rt2x00dev;
-	button->poll_timer.expires = jiffies + button->poll_delay;
-
-	add_timer(&button->poll_timer);
-}
-
-static inline void rt2x00pci_button_stop(struct rt2x00_dev *rt2x00dev)
-{
-	/*
-	 * Shutdown poll_timer for hardware button,
-	 * make sure only to disable polling when
-	 * it was enabled in the first place.
-	 */
-	if(!rt2x00dev->button.active_poll)
-		return;
-
-	rt2x00dev->button.active_poll = 0;
-	del_timer_sync(&rt2x00dev->button.poll_timer);
-}
-#else /* CONFIG_RT2X00_BUTTON */
-static inline void rt2x00pci_button_start(struct rt2x00_dev *rt2x00dev,
-	void (*handler)(unsigned long data)){}
-static inline void rt2x00pci_button_stop(struct rt2x00_dev *rt2x00dev){}
-#endif /* CONFIG_RT2X00_BUTTON */
-
 #endif /* RT2X00PCI_H */
diff -rU3 wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-09-21 19:59:27.000000000 +0200
+++ wireless-dev-rfkill/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-09-21 20:09:27.000000000 +0200
@@ -52,10 +52,6 @@
 #define CONFIG_RT2X00_DEBUG
 #endif /* CONFIG_RT61PCI_DEBUG */
 
-#ifdef CONFIG_RT61PCI_BUTTON
-#define CONFIG_RT2X00_BUTTON
-#endif /* CONFIG_RT61PCI_BUTTON */
-
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2x00crc.h"
@@ -377,23 +373,6 @@
 		rt2x00_eeprom_read(rt2x00dev, word + i, data++);
 }
 
-#ifdef CONFIG_RT61PCI_BUTTON
-/*
- * Hardware button poll handler.
- */
-static void rt61pci_button_poll(unsigned long data)
-{
-	struct rt2x00_dev *rt2x00dev = (struct rt2x00_dev*)data;
-	u32 reg;
-
-	rt2x00_register_read(rt2x00dev, MAC_CSR13, &reg);
-	rt2x00pci_button_status(
-		rt2x00dev, rt2x00_get_field32(reg, MAC_CSR13_BIT5));
-}
-#else /* CONFIG_RT61PCI_BUTTON */
-static void rt61pci_button_poll(unsigned long data){}
-#endif /* CONFIG_RT61PCI_BUTTON */
-
 /*
  * Ethtool handlers.
  */
@@ -3547,11 +3526,6 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * Shutdown poll_timer for hardware button.
-	 */
-	rt2x00pci_button_stop(rt2x00dev);
-
-	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -3640,11 +3614,6 @@
 		goto exit;
 	}
 
-	/*
-	 * If required start hardware button polling.
-	 */
-	rt2x00pci_button_start(rt2x00dev, rt61pci_button_poll);
-
 	return 0;
 
 exit:
@@ -3856,11 +3825,6 @@
 MODULE_PARM_DESC(debug, "Set this parameter to 1 to enable debug output.");
 #endif /* CONFIG_RT61PCI_DEBUG */
 
-#ifdef CONFIG_RT61PCI_BUTTON
-module_param_named(poll_delay, rt2x00_poll_delay, short, S_IRUGO);
-MODULE_PARM_DESC(debug, "Delay between WiFi button pollings (in 100ms).");
-#endif /* CONFIG_RT61PCI_BUTTON */
-
 static struct pci_driver rt61pci_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rt61pci_device_table,
