From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/2] rfkill - rt2x00 should use rfkill
Date: Tue, 8 Aug 2006 16:30:13 +0200
Message-ID: <200608081630.13432.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:20693 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964919AbWHHOan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 10:30:43 -0400
Received: by nf-out-0910.google.com with SMTP id q29so188381nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 07:30:42 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now rfkill is available rt2x00 should make use of it let
the hardware button status be periodically probed by rfkill.
This makes the ACPI implementation as done in rt2x00 no longer required.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rNU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/Kconfig wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/Kconfig
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-08-08 16:09:13.000000000 +0200
+++ wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-08-08 16:03:41.000000000 +0200
@@ -17,12 +17,12 @@
 
 config RT2400PCI_BUTTON
 	bool "Ralink rt2400 hardware button support"
-	depends on RT2400PCI && X86
+	depends on RT2400PCI && RFKILL
 	---help---
 	In some notebooks the rt2400 chipset is integrated in the machine,
-	with this option enabled the device will periodically poll the
-	the status of this button and will send and ACPI event when
-	the button has been pressed.
+	with this option enabled the driver will register itself to the
+	rfkill driver for periodical polling of the hardware button
+	status, and the correct handling of button press events.
 
 config RT2400PCI_DEBUG
 	bool "Ralink rt2400 debug output"
@@ -40,12 +40,12 @@
 
 config RT2500PCI_BUTTON
 	bool "Ralink rt2500 hardware button support"
-	depends on RT2500PCI && X86
+	depends on RT2500PCI && RFKILL
 	---help---
 	In some notebooks the rt2500 chipset is integrated in the machine,
-	with this option enabled the device will periodically poll the
-	the status of this button and will send and ACPI event when
-	the button has been pressed.
+	with this option enabled the driver will register itself to the
+	rfkill driver for periodical polling of the hardware button
+	status, and the correct handling of button press events.
 
 config RT2500PCI_DEBUG
 	bool "Ralink rt2500 debug output"
@@ -64,12 +64,12 @@
 
 config RT61PCI_BUTTON
 	bool "Ralink rt61 hardware button support"
-	depends on RT61PCI && X86
+	depends on RT61PCI && RFKILL
 	---help---
 	In some notebooks the rt61 chipset is integrated in the machine,
-	with this option enabled the device will periodically poll the
-	the status of this button and will send and ACPI event when
-	the button has been pressed.
+	with this option enabled the driver will register itself to the
+	rfkill driver for periodical polling of the hardware button
+	status, and the correct handling of button press events.
 
 config RT61PCI_DEBUG
 	bool "Ralink rt61 debug output"
diff -rNU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 16:09:02.000000000 +0200
+++ wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 16:00:28.000000000 +0200
@@ -346,23 +346,6 @@
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
@@ -437,6 +420,60 @@
 	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
+#ifdef CONFIG_RT2400PCI_BUTTON
+static int rt2400pci_button_poll(unsigned long data)
+{
+	struct rt2x00_dev *rt2x00dev = (struct rt2x00_dev*)data;
+	u32 reg;
+
+	rt2x00_register_read(rt2x00dev, GPIOCSR, &reg);
+	return rt2x00_get_field32(reg, GPIOCSR_BIT0);
+}
+
+static void rt2400pci_button_enable_radio(unsigned long data)
+{
+	rt2400pci_enable_radio((struct rt2x00_dev*)data);
+}
+
+static void rt2400pci_button_disable_radio(unsigned long data)
+{
+	rt2400pci_disable_radio((struct rt2x00_dev*)data);
+}
+
+static void rt2400pci_button_start(struct rt2x00_dev *rt2x00dev)
+{
+	struct rfkill *rfkill = &rt2x00dev->rfkill;
+
+	/*
+	 * Only start the button polling when
+	 * the hardware button is present.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON))
+		return;
+
+	rfkill->dev_name	= "rt2400pci";
+	rfkill->data		= (unsigned long)rt2x00dev;
+	rfkill->poll		= rt2400pci_button_poll;
+	rfkill->enable_radio	= rt2400pci_button_enable_radio;
+	rfkill->disable_radio	= rt2400pci_button_disable_radio;
+	rfkill->current_status	= !!rt2400pci_button_poll(rfkill->data);
+
+	if (rfkill_add_device(rfkill))
+		ERROR("Failed to register button handler.\n");
+}
+
+static void rt2400pci_button_stop(struct rt2x00_dev *rt2x00dev)
+{
+	if (!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON))
+		return;
+
+	rfkill_del_device(&rt2x00dev->rfkill);
+}
+#else /* CONFIG_RT2400PCI_BUTTON */
+static void rt2400pci_button_start(struct rt2x00_dev *rt2x00dev){}
+static void rt2400pci_button_stop(struct rt2x00_dev *rt2x00dev){}
+#endif /* CONFIG_RT2400PCI_BUTTON */
+
 /*
  * Configuration handlers.
  */
@@ -2714,7 +2751,7 @@
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
-	rt2x00pci_button_stop(rt2x00dev);
+	rt2400pci_button_stop(rt2x00dev);
 
 	/*
 	 * Free ring structures.
@@ -2803,7 +2840,7 @@
 	/*
 	 * If required start hardware button polling.
 	 */
-	rt2x00pci_button_start(rt2x00dev, rt2400pci_button_poll);
+	rt2400pci_button_start(rt2x00dev);
 
 	return 0;
 
@@ -2995,11 +3032,6 @@
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
diff -rNU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 16:09:03.000000000 +0200
+++ wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 16:00:26.000000000 +0200
@@ -346,23 +346,6 @@
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
@@ -437,6 +420,60 @@
 	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
+#ifdef CONFIG_RT2500PCI_BUTTON
+static int rt2500pci_button_poll(unsigned long data)
+{
+	struct rt2x00_dev *rt2x00dev = (struct rt2x00_dev*)data;
+	u32 reg;
+
+	rt2x00_register_read(rt2x00dev, GPIOCSR, &reg);
+	return rt2x00_get_field32(reg, GPIOCSR_BIT0);
+}
+
+static void rt2500pci_button_enable_radio(unsigned long data)
+{
+	rt2500pci_enable_radio((struct rt2x00_dev*)data);
+}
+
+static void rt2500pci_button_disable_radio(unsigned long data)
+{
+	rt2500pci_disable_radio((struct rt2x00_dev*)data);
+}
+
+static void rt2500pci_button_start(struct rt2x00_dev *rt2x00dev)
+{
+	struct rfkill *rfkill = &rt2x00dev->rfkill;
+
+	/*
+	 * Only start the button polling when
+	 * the hardware button is present.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON))
+		return;
+
+	rfkill->dev_name	= "rt2500pci";
+	rfkill->data		= (unsigned long)rt2x00dev;
+	rfkill->poll		= rt2500pci_button_poll;
+	rfkill->enable_radio	= rt2500pci_button_enable_radio;
+	rfkill->disable_radio	= rt2500pci_button_disable_radio;
+	rfkill->current_status	= !!rt2500pci_button_poll(rfkill->data);
+
+	if (rfkill_add_device(rfkill))
+		ERROR("Failed to register button handler.\n");
+}
+
+static void rt2500pci_button_stop(struct rt2x00_dev *rt2x00dev)
+{
+	if (!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON))
+		return;
+
+	rfkill_del_device(&rt2x00dev->rfkill);
+}
+#else /* CONFIG_RT2500PCI_BUTTON */
+static void rt2500pci_button_start(struct rt2x00_dev *rt2x00dev){}
+static void rt2500pci_button_stop(struct rt2x00_dev *rt2x00dev){}
+#endif /* CONFIG_RT2500PCI_BUTTON */
+
 /*
  * Configuration handlers.
  */
@@ -2997,7 +3034,7 @@
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
-	rt2x00pci_button_stop(rt2x00dev);
+	rt2500pci_button_stop(rt2x00dev);
 
 	/*
 	 * Free ring structures.
@@ -3086,7 +3123,7 @@
 	/*
 	 * If required start hardware button polling.
 	 */
-	rt2x00pci_button_start(rt2x00dev, rt2500pci_button_poll);
+	rt2500pci_button_start(rt2x00dev);
 
 	return 0;
 
@@ -3278,11 +3315,6 @@
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
diff -rNU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 16:09:03.000000000 +0200
+++ wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 16:00:57.000000000 +0200
@@ -82,6 +82,16 @@
 		__FUNCTION__, ##__args);
 
 /*
+ * Hardware button support (through radiobtn)
+ * The delay between each poll can be set by the user
+ * using the module parameter. Default value is 0,
+ * which means polling is disabled.
+ */
+#ifdef CONFIG_RT2X00_BUTTON
+#include <linux/rfkill.h>
+#endif /* CONFIG_RT2X00_BUTTON */
+
+/*
  * Ring sizes.
  * Ralink PCI devices demand the Frame size to be a multiple of 128 bytes.
  * DATA_FRAME_SIZE is used for TX, RX, ATIM and PRIO rings.
diff -rNU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-08-08 16:01:16.000000000 +0200
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
diff -rNU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 16:09:13.000000000 +0200
+++ wireless-dev-rt2x00-rfkill/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 16:02:22.000000000 +0200
@@ -377,23 +377,6 @@
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
@@ -468,6 +451,60 @@
 	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
+#ifdef CONFIG_RT61PCI_BUTTON
+static int rt61pci_button_poll(unsigned long data)
+{
+	struct rt2x00_dev *rt2x00dev = (struct rt2x00_dev*)data;
+	u32 reg;
+
+	rt2x00_register_read(rt2x00dev, MAC_CSR13, &reg);
+	return rt2x00_get_field32(reg, MAC_CSR13_BIT5);
+}
+
+static void rt61pci_button_enable_radio(unsigned long data)
+{
+	rt61pci_enable_radio((struct rt2x00_dev*)data);
+}
+
+static void rt61pci_button_disable_radio(unsigned long data)
+{
+	rt61pci_disable_radio((struct rt2x00_dev*)data);
+}
+
+static void rt61pci_button_start(struct rt2x00_dev *rt2x00dev)
+{
+	struct rfkill *rfkill = &rt2x00dev->rfkill;
+
+	/*
+	 * Only start the button polling when
+	 * the hardware button is present.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON))
+		return;
+
+	rfkill->dev_name	= "rt61pci";
+	rfkill->data		= (unsigned long)rt2x00dev;
+	rfkill->poll		= rt61pci_button_poll;
+	rfkill->enable_radio	= rt61pci_button_enable_radio;
+	rfkill->disable_radio	= rt61pci_button_disable_radio;
+	rfkill->current_status	= !!rt61pci_button_poll(rfkill->data);
+
+	if (rfkill_add_device(rfkill))
+		ERROR("Failed to register button handler.\n");
+}
+
+static void rt61pci_button_stop(struct rt2x00_dev *rt2x00dev)
+{
+	if (!GET_FLAG(rt2x00dev, DEVICE_SUPPORT_HW_BUTTON))
+		return;
+
+	rfkill_del_device(&rt2x00dev->rfkill);
+}
+#else /* CONFIG_RT61PCI_BUTTON */
+static void rt61pci_button_start(struct rt2x00_dev *rt2x00dev){}
+static void rt61pci_button_stop(struct rt2x00_dev *rt2x00dev){}
+#endif /* CONFIG_RT61PCI_BUTTON */
+
 /*
  * Configuration handlers.
  */
@@ -3514,7 +3551,7 @@
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
-	rt2x00pci_button_stop(rt2x00dev);
+	rt61pci_button_stop(rt2x00dev);
 
 	/*
 	 * Free ring structures.
@@ -3608,7 +3645,7 @@
 	/*
 	 * If required start hardware button polling.
 	 */
-	rt2x00pci_button_start(rt2x00dev, rt61pci_button_poll);
+	rt61pci_button_start(rt2x00dev);
 
 	return 0;
 
@@ -3806,11 +3843,6 @@
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
