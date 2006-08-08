From: "John W. Linville" <linville@tuxdriver.com>
Subject: What's new in wireless-dev?
Date: Tue, 8 Aug 2006 19:41:28 -0400
Message-ID: <20060808234123.GB20706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:41736 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030335AbWHHXmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 19:42:08 -0400
Received: from bilbo.hq.tuxdriver.com ([70.61.120.53])
	by ra.tuxdriver.com (8.13.6/8.13.6) with ESMTP id k78NfZ5T014261
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 19:41:40 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k78NfTmc026768
	for <netdev@vger.kernel.org>; Tue, 8 Aug 2006 19:41:29 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k78NfTWD026767
	for netdev@vger.kernel.org; Tue, 8 Aug 2006 19:41:29 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit d2970f6c700f2291c1a80b061ebcd6041d2f3f1e:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

Ivo van Doorn:
      rt2x00 - pci request/release regions
      rt2x00 - ieee80211_hw->config no longer requires scheduling
      rt2x00 - optimize MAC reading & initialize perm_addr
      rt2x00 - txpower limits
      rt2x00 - misc fixes
      rt2x00 - scan handlers
      rfkill - Add rfkill driver to misc input devices
      rfkill - rt2x00 should use rfkill

Jiri Benc:
      d80211: fix wrong logical operations
      d80211: more correct WE support on master interface

Jouni Malinen:
      d80211: Fix RTS threshold use
      d80211: Fix PS-Poll frame dropping
      d80211: Fix PLCP header length comment
      d80211: Send Layer 2 Update frames in kernel
      d80211: Fix ieee80211_remove_tx_extra() if key not configured
      d80211: Fix TKIP replay protection

Michael Wu:
      d80211: Fix issues with QOS bitwise ops
      adm8211: Use ieee80211_*_queue functions
      d80211 drivers: Use IRQF_SHARED instead of SA_SHIRQ

 drivers/input/misc/Kconfig                         |   15 +
 drivers/input/misc/Makefile                        |    1 
 drivers/input/misc/rfkill.c                        |  210 ++++++++++++++++++++
 drivers/net/wireless/d80211/adm8211/adm8211.c      |   18 +-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 
 drivers/net/wireless/d80211/rt2x00/Kconfig         |   24 +-
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |  193 +++++++++---------
 drivers/net/wireless/d80211/rt2x00/rt2400pci.h     |    4 
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |  197 ++++++++++---------
 drivers/net/wireless/d80211/rt2x00/rt2500pci.h     |    4 
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |   99 +++------
 drivers/net/wireless/d80211/rt2x00/rt2500usb.h     |    4 
 drivers/net/wireless/d80211/rt2x00/rt2x00.h        |   62 +++++-
 drivers/net/wireless/d80211/rt2x00/rt2x00pci.h     |  111 -----------
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |  200 +++++++++----------
 drivers/net/wireless/d80211/rt2x00/rt61pci.h       |    4 
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |   92 +++------
 drivers/net/wireless/d80211/rt2x00/rt73usb.h       |    4 
 include/linux/input.h                              |    1 
 include/linux/rfkill.h                             |   98 +++++++++
 net/d80211/ieee80211.c                             |   26 +-
 net/d80211/ieee80211_i.h                           |    1 
 net/d80211/ieee80211_ioctl.c                       |   87 ++++++++
 net/d80211/tkip.c                                  |    1 
 net/d80211/wme.c                                   |    4 
 net/d80211/wpa.c                                   |    2 
 26 files changed, 868 insertions(+), 596 deletions(-)
 create mode 100644 drivers/input/misc/rfkill.c
 create mode 100644 include/linux/rfkill.h

diff --git a/drivers/input/misc/Kconfig b/drivers/input/misc/Kconfig
index a6dfc74..ac10c02 100644
--- a/drivers/input/misc/Kconfig
+++ b/drivers/input/misc/Kconfig
@@ -79,4 +79,19 @@ config HP_SDC_RTC
 	  Say Y here if you want to support the built-in real time clock
 	  of the HP SDC controller.
 
+config RFKILL
+	tristate "RF button support"
+	help
+	  If you say yes here, the rfkill driver will be build
+	  which allowed network devices to register their hardware
+	  RF button which controls the radio state. This driver
+	  will then create an input device for it.
+
+	  When the input device is not used, the rfkill driver
+	  will make sure that when the RF button is pressed the radio
+	  is enabled or disabled accordingly. When the input device
+	  has been opened by the user this radio control will be left
+	  to the user, and rfkill will only send the RF button status
+	  change to userspace.
+
 endif
diff --git a/drivers/input/misc/Makefile b/drivers/input/misc/Makefile
index 415c491..e788a1b 100644
--- a/drivers/input/misc/Makefile
+++ b/drivers/input/misc/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_INPUT_UINPUT)		+= uinput.o
 obj-$(CONFIG_INPUT_WISTRON_BTNS)	+= wistron_btns.o
 obj-$(CONFIG_HP_SDC_RTC)		+= hp_sdc_rtc.o
 obj-$(CONFIG_INPUT_IXP4XX_BEEPER)	+= ixp4xx-beeper.o
+obj-$(CONFIG_RFKILL)			+= rfkill.o
diff --git a/drivers/input/misc/rfkill.c b/drivers/input/misc/rfkill.c
new file mode 100644
index 0000000..7b78053
--- /dev/null
+++ b/drivers/input/misc/rfkill.c
@@ -0,0 +1,210 @@
+/*
+	Copyright (C) 2006 Ivo van Doorn
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/timer.h>
+#include <linux/rfkill.h>
+
+#include <asm/atomic.h>
+
+MODULE_AUTHOR("Ivo van Doorn <IvDoorn@gmail.com>");
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("RF button support");
+MODULE_LICENSE("GPL");
+
+/*
+ * List of all registered buttons.
+ */
+static struct list_head rfkill_list;
+static spinlock_t rfkill_list_lock;
+
+/*
+ * Polling timer, poll_delay and use count.
+ */
+static struct timer_list poll_timer;
+static atomic_t poll_required;
+
+static void rfkill_toggle_radio(int new_status)
+{
+	struct list_head *entry;
+	struct rfkill *rfkill;
+
+	/*
+	 * Go through the list of all radio's to toggle the radio state.
+	 */
+	list_for_each(entry, &rfkill_list) {
+		rfkill =  list_entry(entry, struct rfkill, entry);
+
+		rfkill->current_status = new_status;
+
+		/*
+		 * If the input_device has been opened
+		 * all radio events should be send to user space.
+		 */
+		if (rfkill->input_dev->users) {
+			input_report_key(rfkill->input_dev,
+				KEY_RFKILL, new_status);
+			input_sync(rfkill->input_dev);
+			continue;
+		}
+
+		/*
+		 * If the hardware does not toggle the radio status automaticly,
+		 * we should take care of it.
+		 */
+		if (new_status && rfkill->enable_radio)
+			rfkill->enable_radio(rfkill->data);
+		else if (!new_status && rfkill->disable_radio)
+			rfkill->disable_radio(rfkill->data);
+	}
+}
+
+static void rfkill_poll_button(unsigned long data)
+{
+	struct list_head *entry;
+	struct rfkill *rfkill;
+	int status;
+
+	spin_lock(&rfkill_list_lock);
+
+	list_for_each(entry, &rfkill_list) {
+		rfkill =  list_entry(entry, struct rfkill, entry);
+
+		if (!rfkill->poll)
+			continue;
+
+		status = !!rfkill->poll(rfkill->data);
+
+		if (status != rfkill->current_status) {
+			rfkill_toggle_radio(status);
+			break;
+		}
+	}
+
+	spin_unlock(&rfkill_list_lock);
+
+	/*
+	 * Check if polling is still required.
+	 */
+	if (atomic_read(&poll_required)) {
+		poll_timer.expires = jiffies + RFKILL_POLL_DELAY;
+		add_timer(&poll_timer);
+	}
+}
+
+void rfkill_button_event(struct rfkill *rfkill, int status)
+{
+	if (status != rfkill->current_status) {
+		spin_lock(&rfkill_list_lock);
+		rfkill_toggle_radio(status);
+		spin_unlock(&rfkill_list_lock);
+	}
+}
+EXPORT_SYMBOL(rfkill_button_event);
+
+int rfkill_add_device(struct rfkill *rfkill)
+{
+	int status;
+
+	/*
+	 * Allocate, initialize and register input device.
+	 */
+	rfkill->input_dev = input_allocate_device();
+	if (!rfkill->input_dev) {
+		printk(KERN_ERR "Failed to allocate input device %s.\n",
+			rfkill->dev_name);
+		return -ENOMEM;
+	}
+
+	rfkill->input_dev->name = "Radio button";
+	rfkill->input_dev->phys = rfkill->dev_name;
+	rfkill->input_dev->id.bustype = BUS_HOST;
+	set_bit(KEY_RFKILL, rfkill->input_dev->keybit);
+
+	status = input_register_device(rfkill->input_dev);
+	if (status) {
+		printk(KERN_ERR "Failed to register input device %s.\n",
+			rfkill->dev_name);
+		input_free_device(rfkill->input_dev);
+		return status;
+	}
+
+	INIT_LIST_HEAD(&rfkill->entry);
+
+	spin_lock(&rfkill_list_lock);
+	list_add(&rfkill->entry, &rfkill_list);
+	spin_unlock(&rfkill_list_lock);
+
+	/*
+	 * If polling is required the poll_required counter should be
+	 * increased. If it was previously 0 we should start the polling timer.
+	 */
+	if (rfkill->poll) {
+		if (!atomic_read(&poll_required)) {
+			poll_timer.expires = jiffies + RFKILL_POLL_DELAY;
+			add_timer(&poll_timer);
+		}
+		atomic_inc(&poll_required);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(rfkill_add_device);
+
+void rfkill_del_device(struct rfkill *rfkill)
+{
+	spin_lock(&rfkill_list_lock);
+
+	/*
+	 * Check if this button required polling and if this
+	 * was the last button that required polling.
+	 */
+	if (rfkill->poll && atomic_dec_and_test(&poll_required))
+		del_timer(&poll_timer);
+
+	list_del(&rfkill->entry);
+
+	spin_unlock(&rfkill_list_lock);
+}
+EXPORT_SYMBOL(rfkill_del_device);
+
+static int __init radiobtn_init(void)
+{
+	printk(KERN_INFO "Loading rfkill driver.\n");
+
+	INIT_LIST_HEAD(&rfkill_list);
+	spin_lock_init(&rfkill_list_lock);
+
+	init_timer(&poll_timer);
+	poll_timer.function = rfkill_poll_button;
+	poll_timer.data = 0;
+	atomic_set(&poll_required, 0);
+
+	return 0;
+}
+
+static void __exit radiobtn_exit(void)
+{
+	printk(KERN_INFO "Unloading rfkill driver.\n");
+}
+
+module_init(radiobtn_init);
+module_exit(radiobtn_exit);
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 748eb26..dcabeab 100644
--- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -452,7 +452,7 @@ static void adm8211_interrupt_tci(struct
 	}
 
 	if (priv->cur_tx - dirty_tx < priv->tx_ring_size - 2)
-		netif_wake_queue(dev);
+		ieee80211_wake_queue(dev, 0);
 
 	priv->dirty_tx = dirty_tx;
 	spin_unlock(&priv->lock);
@@ -1627,7 +1627,7 @@ static int adm8211_open(struct net_devic
 	adm8211_rf_set_channel(dev, priv->channel);
 
 	retval = request_irq(dev->irq, &adm8211_interrupt,
-			     SA_SHIRQ, dev->name, dev);
+			     IRQF_SHARED, dev->name, dev);
 	if (retval) {
 		printk(KERN_ERR "%s: failed to register IRQ handler\n",
 		       dev->name);
@@ -1765,17 +1765,13 @@ static void adm8211_tx_raw(struct net_de
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	if (priv->cur_tx - priv->dirty_tx < priv->tx_ring_size / 2)
+	if (priv->cur_tx - priv->dirty_tx == priv->tx_ring_size / 2)
 		flag = TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
-	else if (priv->cur_tx - priv->dirty_tx == priv->tx_ring_size / 2)
-		flag = TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
-	else if (priv->cur_tx - priv->dirty_tx < priv->tx_ring_size - 2)
+	else
 		flag = TDES1_CONTROL_LS | TDES1_CONTROL_FS;
-	else {
-		flag = TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
-		printk(KERN_DEBUG "%s: Yikes, this shouldn't happen!\n", dev->name);
-		netif_stop_queue(dev);
-	}
+
+	if (priv->cur_tx - priv->dirty_tx == priv->tx_ring_size - 2)
+		ieee80211_stop_queue(dev, 0);
 
 	entry = priv->cur_tx % priv->tx_ring_size;
 
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 59d137b..6366020 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -2295,7 +2295,7 @@ #ifdef CONFIG_BCM947XX
 	}
 #endif
 	err = request_irq(bcm->irq, bcm43xx_interrupt_handler,
-			  SA_SHIRQ, KBUILD_MODNAME, bcm);
+			  IRQF_SHARED, KBUILD_MODNAME, bcm);
 	if (err)
 		printk(KERN_ERR PFX "Cannot register IRQ%d\n", bcm->irq);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/Kconfig b/drivers/net/wireless/d80211/rt2x00/Kconfig
index d9b97f1..9e91fd6 100644
--- a/drivers/net/wireless/d80211/rt2x00/Kconfig
+++ b/drivers/net/wireless/d80211/rt2x00/Kconfig
@@ -17,12 +17,12 @@ config RT2400PCI
 
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
@@ -40,12 +40,12 @@ config RT2500PCI
 
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
@@ -63,12 +63,12 @@ config RT61PCI
 
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 709cdbf..96bcdf4 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -346,23 +346,6 @@ static void rt2x00_eeprom_multiread(cons
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
@@ -434,8 +417,63 @@ #endif /* CONFIG_RT2400PCI_DEBUG */
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt2400pci_get_eeprom_len,
 	.get_eeprom	= rt2400pci_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
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
@@ -1356,7 +1394,7 @@ static int rt2400pci_initialize(struct r
 	 * Register interrupt handler.
 	 */
 	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt2400pci_interrupt,
-		SA_SHIRQ, net_dev->name, rt2x00dev)) {
+		IRQF_SHARED, net_dev->name, rt2x00dev)) {
 		ERROR("IRQ %d allocation failed.\n",
 			rt2x00dev_pci(rt2x00dev)->irq);
 		goto exit_fail;
@@ -1380,10 +1418,8 @@ static void rt2400pci_uninitialize(struc
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1801,10 +1837,8 @@ static void rt2400pci_txdone(void *data)
 	if (rt2x00dev->scan &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_TX]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_ATIM]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2050,11 +2084,10 @@ static void rt2400pci_remove_interface(s
 		rt2400pci_disable_radio(rt2x00dev);
 }
 
-static void rt2400pci_config_update(void *data)
+static int rt2400pci_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2085,21 +2118,10 @@ static void rt2400pci_config_update(void
 		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
 		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt2400pci_enable_radio(rt2x00dev))
-			return;
-	}
-}
-
-static int rt2400pci_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	} else if (conf->radio_enabled)
+		return rt2400pci_enable_radio(rt2x00dev);
 
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static int rt2400pci_config_interface(struct net_device *net_dev, int if_id,
@@ -2164,14 +2186,7 @@ static void rt2400pci_scan(void *data)
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2243,13 +2258,7 @@ static int rt2400pci_passive_scan(struct
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
@@ -2521,25 +2530,29 @@ static int rt2400pci_init_eeprom(struct 
 static int rt2400pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u32 reg[2] = { 0, 0 };
+	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
-	rt2x00_register_multiread(rt2x00dev, CSR3, &reg[0], sizeof(reg));
+	/*
+	 * Read MAC address from MAC register.
+	 */
+	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field32(reg[0], CSR3_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field32(reg[0], CSR3_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field32(reg[0], CSR3_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field32(reg[0], CSR3_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field32(reg[1], CSR4_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field32(reg[1], CSR4_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&reg[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
+	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -2738,7 +2751,7 @@ static void rt2400pci_free_dev(struct ne
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
-	rt2x00pci_button_stop(rt2x00dev);
+	rt2400pci_button_stop(rt2x00dev);
 
 	/*
 	 * Free ring structures.
@@ -2798,11 +2811,6 @@ static int rt2400pci_alloc_dev(struct pc
 		goto exit;
 
 	/*
-	 * Initialize cofniguration work.
-	 */
-	INIT_WORK(&rt2x00dev->config_work, rt2400pci_config_update, rt2x00dev);
-
-	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
@@ -2832,7 +2840,7 @@ static int rt2400pci_alloc_dev(struct pc
 	/*
 	 * If required start hardware button polling.
 	 */
-	rt2x00pci_button_start(rt2x00dev, rt2400pci_button_poll);
+	rt2400pci_button_start(rt2x00dev);
 
 	return 0;
 
@@ -2851,10 +2859,16 @@ static int rt2400pci_probe(struct pci_de
 	struct net_device *net_dev;
 	int status;
 
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
+		ERROR("PCI request regions failed.\n");
+		return status;
+	}
+
 	status = pci_enable_device(pci_dev);
 	if (status) {
 		ERROR("Enable device failed.\n");
-		return status;
+		goto exit_release_regions;
 	}
 
 	pci_set_master(pci_dev);
@@ -2869,17 +2883,11 @@ static int rt2400pci_probe(struct pci_de
 		goto exit_disable_device;
 	}
 
-	status = pci_request_regions(pci_dev, pci_name(pci_dev));
-	if (status) {
-		ERROR("PCI request regions failed.\n");
-		goto exit_disable_device;
-	}
-
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
 	if (!net_dev) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
-		goto exit_release_regions;
+		goto exit_disable_device;
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2400pci_ethtool_ops);
@@ -2898,13 +2906,13 @@ static int rt2400pci_probe(struct pci_de
 exit_free_device:
 	ieee80211_free_hw(net_dev);
 
-exit_release_regions:
-	pci_release_regions(pci_dev);
-
 exit_disable_device:
 	if (status != -EBUSY)
 		pci_disable_device(pci_dev);
 
+exit_release_regions:
+	pci_release_regions(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return status;
@@ -2927,9 +2935,9 @@ static void rt2400pci_remove(struct pci_
 
 	pci_set_drvdata(pci_dev, NULL);
 
-	pci_release_regions(pci_dev);
-
 	pci_disable_device(pci_dev);
+
+	pci_release_regions(pci_dev);
 }
 
 #ifdef CONFIG_PM
@@ -3024,11 +3032,6 @@ module_param_named(debug, rt2x00_debug_l
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
index b592eef..ae0ea54 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
@@ -881,8 +881,8 @@ #define TXPOWER_FROM_DEV(__txpower) \
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
 		(__txpower) += MIN_TXPOWER; \
-		((__txpower) < MIN_TXPOWER) ? MAX_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MIN_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MAX_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MIN_TXPOWER : \
 		(MAX_TXPOWER - ((__txpower) - MIN_TXPOWER))); \
 	})
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 8a22968..20095aa 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -346,23 +346,6 @@ static void rt2x00_eeprom_multiread(cons
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
@@ -434,8 +417,63 @@ #endif /* CONFIG_RT2500PCI_DEBUG */
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt2500pci_get_eeprom_len,
 	.get_eeprom	= rt2500pci_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
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
@@ -1476,7 +1514,7 @@ static int rt2500pci_initialize(struct r
 	 * Register interrupt handler.
 	 */
 	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt2500pci_interrupt,
-		SA_SHIRQ, net_dev->name, rt2x00dev)) {
+		IRQF_SHARED, net_dev->name, rt2x00dev)) {
 		ERROR("IRQ %d allocation failed.\n",
 			rt2x00dev_pci(rt2x00dev)->irq);
 		goto exit_fail;
@@ -1500,10 +1538,8 @@ static void rt2500pci_uninitialize(struc
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1948,10 +1984,8 @@ static void rt2500pci_txdone(void *data)
 	if (rt2x00dev->scan &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_TX]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_ATIM]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2197,11 +2231,10 @@ static void rt2500pci_remove_interface(s
 		rt2500pci_disable_radio(rt2x00dev);
 }
 
-static void rt2500pci_config_update(void *data)
+static int rt2500pci_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2233,21 +2266,10 @@ static void rt2500pci_config_update(void
 		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
 		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt2500pci_enable_radio(rt2x00dev))
-			return;
-	}
-}
-
-static int rt2500pci_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	} else if (conf->radio_enabled)
+		return rt2500pci_enable_radio(rt2x00dev);
 
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static int rt2500pci_config_interface(struct net_device *net_dev, int if_id,
@@ -2312,14 +2334,7 @@ static void rt2500pci_scan(void *data)
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2337,7 +2352,7 @@ static void rt2500pci_scan(void *data)
 	} else {
 		rt2500pci_config_phymode(rt2x00dev,
 			rt2x00dev->scan->conf.running_phymode);
-	
+
 		rt2500pci_config_channel(rt2x00dev,
 			rt2x00dev->scan->conf.running_channel_val,
 			rt2x00dev->scan->conf.running_channel,
@@ -2387,13 +2402,7 @@ static int rt2500pci_passive_scan(struct
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
@@ -2673,25 +2682,29 @@ static int rt2500pci_init_eeprom(struct 
 static int rt2500pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u32 reg[2] = { 0, 0 };
+	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
-	rt2x00_register_multiread(rt2x00dev, CSR3, &reg[0], sizeof(reg));
+	/*
+	 * Read MAC address from MAC register.
+	 */
+	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field32(reg[0], CSR3_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field32(reg[0], CSR3_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field32(reg[0], CSR3_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field32(reg[0], CSR3_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field32(reg[1], CSR4_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field32(reg[1], CSR4_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&reg[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
+	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -2866,7 +2879,7 @@ static void rt2500pci_init_hw_channels(s
 		};
 
 		struct ieee80211_channel *chan = channels + 14;
-	
+
 		for (i = 0; i < ARRAY_SIZE(vals); i++)
 			(chan++)->val = cpu_to_le32(vals[i]);
 	}
@@ -3021,7 +3034,7 @@ static void rt2500pci_free_dev(struct ne
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
-	rt2x00pci_button_stop(rt2x00dev);
+	rt2500pci_button_stop(rt2x00dev);
 
 	/*
 	 * Free ring structures.
@@ -3081,11 +3094,6 @@ static int rt2500pci_alloc_dev(struct pc
 		goto exit;
 
 	/*
-	 * Initialize cofniguration work.
-	 */
-	INIT_WORK(&rt2x00dev->config_work, rt2500pci_config_update, rt2x00dev);
-
-	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
@@ -3115,7 +3123,7 @@ static int rt2500pci_alloc_dev(struct pc
 	/*
 	 * If required start hardware button polling.
 	 */
-	rt2x00pci_button_start(rt2x00dev, rt2500pci_button_poll);
+	rt2500pci_button_start(rt2x00dev);
 
 	return 0;
 
@@ -3134,10 +3142,16 @@ static int rt2500pci_probe(struct pci_de
 	struct net_device *net_dev;
 	int status;
 
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
+		ERROR("PCI request regions failed.\n");
+		return status;
+	}
+
 	status = pci_enable_device(pci_dev);
 	if (status) {
 		ERROR("Enable device failed.\n");
-		return status;
+		goto exit_release_regions;
 	}
 
 	pci_set_master(pci_dev);
@@ -3152,17 +3166,11 @@ static int rt2500pci_probe(struct pci_de
 		goto exit_disable_device;
 	}
 
-	status = pci_request_regions(pci_dev, pci_name(pci_dev));
-	if (status) {
-		ERROR("PCI request regions failed.\n");
-		goto exit_disable_device;
-	}
-
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
 	if (!net_dev) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
-		goto exit_release_regions;
+		goto exit_disable_device;
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt2500pci_ethtool_ops);
@@ -3181,13 +3189,13 @@ static int rt2500pci_probe(struct pci_de
 exit_free_device:
 	ieee80211_free_hw(net_dev);
 
-exit_release_regions:
-	pci_release_regions(pci_dev);
-
 exit_disable_device:
 	if (status != -EBUSY)
 		pci_disable_device(pci_dev);
 
+exit_release_regions:
+	pci_release_regions(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return status;
@@ -3210,9 +3218,9 @@ static void rt2500pci_remove(struct pci_
 
 	pci_set_drvdata(pci_dev, NULL);
 
-	pci_release_regions(pci_dev);
-
 	pci_disable_device(pci_dev);
+
+	pci_release_regions(pci_dev);
 }
 
 #ifdef CONFIG_PM
@@ -3307,11 +3315,6 @@ module_param_named(debug, rt2x00_debug_l
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
index 671265b..8ef5ae5 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
@@ -1142,8 +1142,8 @@ #define TXPOWER_FROM_DEV(__txpower) \
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index d15a33e..383f4a9 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -170,7 +170,8 @@ static void rt2x00_bbp_read(const struct
 	*value = 0xff;
 }
 
-static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev, const u32 value)
+static void rt2x00_rf_write(const struct rt2x00_dev *rt2x00dev,
+	const u32 value)
 {
 	u16 reg;
 	unsigned int i;
@@ -284,6 +285,7 @@ #endif /* CONFIG_RT2500USB_DEBUG */
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt2500usb_get_eeprom_len,
 	.get_eeprom	= rt2500usb_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -1263,10 +1265,8 @@ static void rt2500usb_uninitialize(struc
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1482,7 +1482,7 @@ static void rt2500usb_write_tx_desc(stru
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	if ((ieee80211hdr->seq_ctrl & IEEE80211_SCTL_FRAG) == 0)
+	if ((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) == 0)
 		rt2x00_set_field32(&txd->word0, TXD_W0_NEW_SEQ, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_NEW_SEQ, 0);
@@ -1712,10 +1712,8 @@ static void rt2500usb_txdone(void *data)
 	if (rt2x00dev->scan &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_TX]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_ATIM]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -1912,12 +1910,10 @@ static void rt2500usb_remove_interface(s
 		rt2500usb_disable_radio(rt2x00dev);
 }
 
-static void rt2500usb_config_update(void *data)
+static int rt2500usb_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev =
-		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u16 reg;
 
 	/*
@@ -1949,21 +1945,10 @@ static void rt2500usb_config_update(void
 		rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
 		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
-	} else if (conf->radio_enabled) {
-		if (rt2500usb_enable_radio(rt2x00dev))
-			return;
-	}
-}
-
-static int rt2500usb_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	} else if (conf->radio_enabled)
+		return rt2500usb_enable_radio(rt2x00dev);
 
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static void rt2500usb_interface_update(void *data)
@@ -2038,14 +2023,7 @@ static void rt2500usb_scan(void *data)
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2054,7 +2032,7 @@ static void rt2500usb_scan(void *data)
 	if (rt2x00dev->scan->state == IEEE80211_SCAN_START) {
 		rt2500usb_config_phymode(rt2x00dev,
 			rt2x00dev->scan->conf.scan_phymode);
-	
+
 		rt2500usb_config_channel(rt2x00dev,
 			rt2x00dev->scan->conf.scan_channel_val,
 			rt2x00dev->scan->conf.scan_channel,
@@ -2063,7 +2041,7 @@ static void rt2500usb_scan(void *data)
 	} else {
 		rt2500usb_config_phymode(rt2x00dev,
 			rt2x00dev->scan->conf.running_phymode);
-	
+
 		rt2500usb_config_channel(rt2x00dev,
 			rt2x00dev->scan->conf.running_channel_val,
 			rt2x00dev->scan->conf.running_channel,
@@ -2113,13 +2091,7 @@ static int rt2500usb_passive_scan(struct
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
@@ -2345,7 +2317,7 @@ static int rt2500usb_init_mac(struct rt2
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u16 eeprom[3] = { 0, 0, 0 };
+	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
@@ -2353,26 +2325,22 @@ static int rt2500usb_init_mac(struct rt2
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR, &eeprom[0], 6);
-
-	net_dev->dev_addr[0] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE5);
-
-	net_dev->addr_len = 6;
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
+		(u16*)&eeprom[0], 6);
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&eeprom[0]))
 		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	net_dev->addr_len = 6;
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -2738,9 +2706,8 @@ static int rt2500usb_alloc_dev(struct us
 		return -ENODEV;
 
 	/*
-	 * Initialize cofniguration work.
+	 * Initialize configuration work.
 	 */
-	INIT_WORK(&rt2x00dev->config_work, rt2500usb_config_update, rt2x00dev);
 	INIT_WORK(&rt2x00dev->interface.work,
 		rt2500usb_interface_update, rt2x00dev);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
index 42d44aa..917ba4c 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
@@ -679,8 +679,8 @@ #define TXPOWER_FROM_DEV(__txpower) \
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2x00.h b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
index 06fa2be..eb56aea 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
@@ -82,6 +82,16 @@ #define DEBUG(__message, __args...) \
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
@@ -734,7 +744,8 @@ struct scanning {
 	 * Flag to see if this scan has been cancelled.
 	 */
 	short status;
-#define SCANNING_READY		0x0001
+#define SCANNING_READY		0x0000
+#define SCANNING_WAITING	0x0001
 #define SCANNING_CANCELLED	0x0002
 
 	/*
@@ -743,6 +754,48 @@ #define SCANNING_CANCELLED	0x0002
 	struct work_struct work;
 };
 
+static inline void rt2x00_start_scan(struct scanning *scan,
+	struct ieee80211_scan_conf *conf, int state)
+{
+	init_completion(&scan->completion);
+
+	memcpy(&scan->conf, conf, sizeof(*conf));
+
+	scan->state = state;
+
+	/*
+	 * Set initial status to SCANNING_WAITING to prevent scanning
+	 * to begin while there are still TX packets queued.
+	 */
+	scan->status = SCANNING_WAITING;
+}
+
+static inline void rt2x00_signal_scan(struct scanning *scan, short status)
+{
+	scan->status = status;
+
+	complete_all(&scan->completion);
+}
+
+static inline int rt2x00_wait_scan(struct scanning *scan)
+{
+	/*
+	 * Only wait for completion when the status
+	 * indicates we should. The SCANNING_READY
+	 * and SCANNING_CANCELLED are both states
+	 * which indicate complete_all has already
+	 * been called.
+	 */
+	if (scan->status == SCANNING_WAITING)
+		wait_for_completion(&scan->completion);
+
+	/*
+	 * Status field will have been updated by the handler
+	 * that has called complete_all() on our complete structure.
+	 */
+	return scan->status;
+}
+
 /*
  * rt2x00 device structure.
  */
@@ -751,7 +804,7 @@ struct rt2x00_dev {
 	 * Device structure.
 	 * The structure stored in here depends on the
 	 * system bus (PCI or USB).
-	 * When accessing this variable, the rt2x00{pci,usb}_dev
+	 * When accessing this variable, the rt2x00dev_{pci,usb}
 	 * macro's should be used for correct typecasting.
 	 */
 	void *dev;
@@ -873,11 +926,6 @@ #endif /* CONFIG_RT2X00_BUTTON */
 	struct ieee80211_rx_status rx_params;
 
 	/*
-	 * work structure for configuration changes.
-	 */
-	struct work_struct config_work;
-
-	/*
 	 * Scanning structure.
 	 */
 	struct scanning *scan;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h b/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
index fe6f833..bd39395 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
@@ -44,115 +44,4 @@ #define EEPROM_WIDTH_93C66	8
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 8bb9de9..cc6789e 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -377,23 +377,6 @@ static void rt2x00_eeprom_multiread(cons
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
@@ -465,8 +448,63 @@ #endif /* CONFIG_RT61PCI_DEBUG */
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt61pci_get_eeprom_len,
 	.get_eeprom	= rt61pci_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
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
@@ -1902,7 +1940,7 @@ static int rt61pci_initialize(struct rt2
 	 * Register interrupt handler.
 	 */
 	if (request_irq(rt2x00dev_pci(rt2x00dev)->irq, rt61pci_interrupt,
-		SA_SHIRQ, net_dev->name, rt2x00dev)) {
+		IRQF_SHARED, net_dev->name, rt2x00dev)) {
 		ERROR("IRQ %d allocation failed.\n",
 			rt2x00dev_pci(rt2x00dev)->irq);
 		goto exit_fail;
@@ -1926,10 +1964,8 @@ static void rt61pci_uninitialize(struct 
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -2448,10 +2484,8 @@ static void rt61pci_txdone(void *data)
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VO]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 }
 
 static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
@@ -2675,11 +2709,10 @@ static void rt61pci_remove_interface(str
 		rt61pci_disable_radio(rt2x00dev);
 }
 
-static void rt61pci_config_update(void *data)
+static int rt61pci_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2711,21 +2744,10 @@ static void rt61pci_config_update(void *
 		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt61pci_enable_radio(rt2x00dev))
-			return;
-	}
-}
-
-static int rt61pci_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	} else if (conf->radio_enabled)
+		return rt61pci_enable_radio(rt2x00dev);
 
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static int rt61pci_config_interface(struct net_device *net_dev, int if_id,
@@ -2790,14 +2812,7 @@ static void rt61pci_scan(void *data)
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2865,13 +2880,7 @@ static int rt61pci_passive_scan(struct n
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
@@ -3198,7 +3207,7 @@ static int rt61pci_init_eeprom(struct rt
 static int rt61pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u16 eeprom[3] = { 0, 0, 0 };
+	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
@@ -3206,26 +3215,22 @@ static int rt61pci_init_mac(struct rt2x0
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR, &eeprom[0], 6);
-
-	net_dev->dev_addr[0] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE5);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
+		(u16*)&eeprom[0], 6);
 
-	net_dev->addr_len = 6;
-
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&eeprom[0]))
 		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	net_dev->addr_len = 6;
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -3491,7 +3496,6 @@ static int rt61pci_init_hw_modes(struct 
 	hw->modes[0].num_channels = 14;
 	hw->modes[0].num_rates = 12;
 
-
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
@@ -3547,7 +3551,7 @@ static void rt61pci_free_dev(struct net_
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
-	rt2x00pci_button_stop(rt2x00dev);
+	rt61pci_button_stop(rt2x00dev);
 
 	/*
 	 * Free ring structures.
@@ -3607,11 +3611,6 @@ static int rt61pci_alloc_dev(struct pci_
 		goto exit;
 
 	/*
-	 * Initialize configuration work.
-	 */
-	INIT_WORK(&rt2x00dev->config_work, rt61pci_config_update, rt2x00dev);
-
-	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
@@ -3646,7 +3645,7 @@ static int rt61pci_alloc_dev(struct pci_
 	/*
 	 * If required start hardware button polling.
 	 */
-	rt2x00pci_button_start(rt2x00dev, rt61pci_button_poll);
+	rt61pci_button_start(rt2x00dev);
 
 	return 0;
 
@@ -3665,10 +3664,16 @@ static int rt61pci_probe(struct pci_dev 
 	struct net_device *net_dev;
 	int status;
 
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
+		ERROR("PCI request regions failed.\n");
+		return status;
+	}
+
 	status = pci_enable_device(pci_dev);
 	if (status) {
 		ERROR("Enable device failed.\n");
-		return status;
+		goto exit_release_regions;
 	}
 
 	pci_set_master(pci_dev);
@@ -3683,17 +3688,11 @@ static int rt61pci_probe(struct pci_dev 
 		goto exit_disable_device;
 	}
 
-	status = pci_request_regions(pci_dev, pci_name(pci_dev));
-	if (status) {
-		ERROR("PCI request regions failed.\n");
-		goto exit_disable_device;
-	}
-
 	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
 	if (!net_dev) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
-		goto exit_release_regions;
+		goto exit_disable_device;
 	}
 
 	SET_ETHTOOL_OPS(net_dev, &rt61pci_ethtool_ops);
@@ -3712,13 +3711,13 @@ static int rt61pci_probe(struct pci_dev 
 exit_free_device:
 	ieee80211_free_hw(net_dev);
 
-exit_release_regions:
-	pci_release_regions(pci_dev);
-
 exit_disable_device:
 	if (status != -EBUSY)
 		pci_disable_device(pci_dev);
 
+exit_release_regions:
+	pci_release_regions(pci_dev);
+
 	pci_set_drvdata(pci_dev, NULL);
 
 	return status;
@@ -3741,9 +3740,9 @@ static void rt61pci_remove(struct pci_de
 
 	pci_set_drvdata(pci_dev, NULL);
 
-	pci_release_regions(pci_dev);
-
 	pci_disable_device(pci_dev);
+
+	pci_release_regions(pci_dev);
 }
 
 #ifdef CONFIG_PM
@@ -3844,11 +3843,6 @@ module_param_named(debug, rt2x00_debug_l
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.h b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
index d334390..2c5065b 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.h
@@ -1360,8 +1360,8 @@ #define TXPOWER_FROM_DEV(__txpower) \
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index acc5357..682d078 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -286,6 +286,7 @@ #endif /* CONFIG_RT2500USB_DEBUG */
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt73usb_get_eeprom_len,
 	.get_eeprom	= rt73usb_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -1524,10 +1525,8 @@ static void rt73usb_uninitialize(struct 
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1999,10 +1998,8 @@ static void rt73usb_txdone(void *data)
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VO]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2127,6 +2124,7 @@ static int rt73usb_tx(struct net_device 
 static int rt73usb_reset(struct net_device *net_dev)
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
 	rt73usb_disable_radio(rt2x00dev);
 	return rt73usb_enable_radio(rt2x00dev);
 }
@@ -2195,12 +2193,10 @@ static void rt73usb_remove_interface(str
 		rt73usb_disable_radio(rt2x00dev);
 }
 
-static void rt73usb_config_update(void *data)
+static int rt73usb_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev =
-		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2232,21 +2228,10 @@ static void rt73usb_config_update(void *
 		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt73usb_enable_radio(rt2x00dev))
-			return;
-	}
-}
-
-static int rt73usb_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	} else if (conf->radio_enabled)
+		return rt73usb_enable_radio(rt2x00dev);
 
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static void rt73usb_interface_update(void *data)
@@ -2321,14 +2306,7 @@ static void rt73usb_scan(void *data)
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2396,13 +2374,7 @@ static int rt73usb_passive_scan(struct n
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
@@ -2710,7 +2682,7 @@ static int rt73usb_init_mac(struct rt2x0
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u16 eeprom[3] = { 0, 0, 0 };
+	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
@@ -2718,26 +2690,22 @@ static int rt73usb_init_mac(struct rt2x0
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR, &eeprom[0], 6);
-
-	net_dev->dev_addr[0] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE5);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
+		(u16*)&eeprom[0], 6);
 
-	net_dev->addr_len = 6;
-
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&eeprom[0]))
 		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	net_dev->addr_len = 6;
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
@@ -3000,7 +2968,6 @@ static int rt73usb_init_hw_modes(struct 
 	hw->modes[0].num_channels = 14;
 	hw->modes[0].num_rates = 12;
 
-
 	/*
 	 * Intitialize 802.11b
 	 * Rates: CCK.
@@ -3095,9 +3062,8 @@ static int rt73usb_alloc_dev(struct usb_
 		return -ENODEV;
 
 	/*
-	 * Initialize cofniguration work.
+	 * Initialize configuration work.
 	 */
-	INIT_WORK(&rt2x00dev->config_work, rt73usb_config_update, rt2x00dev);
 	INIT_WORK(&rt2x00dev->interface.work,
 		rt73usb_interface_update, rt2x00dev);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.h b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
index 662ca30..5be5e14 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.h
@@ -939,8 +939,8 @@ #define TXPOWER_FROM_DEV(__txpower) \
 
 #define TXPOWER_TO_DEV(__txpower) \
 	({ \
-		((__txpower) < MIN_TXPOWER) ? MIN_TXPOWER : \
-		(((__txpower) > MAX_TXPOWER) ? MAX_TXPOWER : \
+		((__txpower) <= MIN_TXPOWER) ? MIN_TXPOWER : \
+		(((__txpower) >= MAX_TXPOWER) ? MAX_TXPOWER : \
 		(__txpower)); \
 	})
 
diff --git a/include/linux/input.h b/include/linux/input.h
index b3253ab..f16da66 100644
--- a/include/linux/input.h
+++ b/include/linux/input.h
@@ -488,6 +488,7 @@ #define KEY_PREVIOUS		0x19c
 #define KEY_DIGITS		0x19d
 #define KEY_TEEN		0x19e
 #define KEY_TWEN		0x19f
+#define KEY_RFKILL		0x1a0
 
 #define KEY_DEL_EOL		0x1c0
 #define KEY_DEL_EOS		0x1c1
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
new file mode 100644
index 0000000..2e1c740
--- /dev/null
+++ b/include/linux/rfkill.h
@@ -0,0 +1,98 @@
+/*
+	Copyright (C) 2006 Ivo van Doorn
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	RF button support
+	Laptops are quite often equiped with a RF button to enable or
+	disable the radio of the network device attached to that button.
+	This network device usually is an integrated wireless network device,
+	or bluetooth device.
+	Some of these devices will disable the radio automaticly when the
+	RF button has been pressed, while other devices need to be polled
+	for the RF button status.
+	But in all cases the only interface that will have its radio disabled
+	will be the device that has the RF button attached to it. But it could
+	be desired that userspace performs this disabling of all radios in case
+	there are also interfaces without a RF button that need to be disabled.
+
+	The rfkill driver will contain a list of all devices with a RF button,
+	hardware drivers need to register their hardware to teh rfkill
+	interface it can take care of everything. If the RF button requires
+	polling to obtain the status this will be handled by rfkill as well.
+	Once the status of the button has changed and the hardware does not
+	automaticly enable or disable the radio rfkill provides with the
+	interface to do this correctly.
+
+	For each registered hardware button an input device will be created.
+	If this input device has been opened by the user, rfkill will send a
+	signal to userspace instead of the hardware about the new button
+	status. This will allow userpace to perform the correct steps
+	in order to bring down all interfaces.
+ */
+
+#ifndef RFKILL_H
+#define RFKILL_H
+
+#include <linux/list.h>
+#include <linux/input.h>
+
+#define RFKILL_POLL_DELAY	( HZ / 10 ) /* 100 ms */
+
+/**
+ * struct rfkill - rfkill button control structure.
+ * @dev_name: Name of the interface. This will become the name
+ * 	of the input device which will be created for this button.
+ * @data: Private data which will be passed along with the radio and polling
+ * 	handlers.
+ * @poll(unsigned long data): Optional handler which will frequently be
+ * 	called to determine the current status of the RF button.
+ * @enable_radio(unsigned long data): Optional handler to enable the radio
+ * 	once the RF button has been pressed and the hardware does enable
+ * 	the radio automaticly.
+ * @disable_radio(unsigned long data): Optional handler to disable the radio
+ * 	once the RF button has been pressed and the hardware does disable
+ * 	the radio automaticly.
+ * @current_status: Contains the current status of the radio as it was
+ * 	previously indicated by the radio. This field may only be changed
+ * 	by the driver at initialization time.
+ */
+struct rfkill {
+	const char *dev_name;
+
+	unsigned long data;
+
+	int (*poll)(unsigned long data);
+	void (*enable_radio)(unsigned long data);
+	void (*disable_radio)(unsigned long data);
+
+	unsigned int current_status;
+
+	/*
+	 * These fields are private to rfkill, and
+	 * should not be used by the RF button driver.
+	 */
+	struct list_head entry;
+	struct input_dev *input_dev;
+};
+
+void rfkill_button_event(struct rfkill *rfkill, int status);
+int rfkill_add_device(struct rfkill *rfkill);
+void rfkill_del_device(struct rfkill *rfkill);
+
+#endif /* RFKILL_H */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 60eca90..11804d5 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -250,7 +250,7 @@ int ieee80211_get_hdrlen(u16 fc)
 	case IEEE80211_FTYPE_DATA:
 		if ((fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS))
 			hdrlen = 30; /* Addr4 */
-		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_QOS_DATA)
+		if (fc & IEEE80211_STYPE_QOS_DATA)
 			hdrlen += 2; /* QoS Control Field */
 		break;
 	case IEEE80211_FTYPE_CTL:
@@ -637,7 +637,7 @@ static int ieee80211_frame_duration(stru
 		 * 802.11 (DS): 15.3.3, 802.11b: 18.3.4
 		 * aSIFSTime = 10 usec
 		 * aPreambleLength = 144 usec or 72 usec with short preamble
-		 * aPLCPHeaderLength = 48 ms or 24 ms with short preamble
+		 * aPLCPHeaderLength = 48 usec or 24 usec with short preamble
 		 */
 		dur = 10; /* aSIFSTime = 10 usec */
 		dur += short_preamble ? (72 + 24) : (144 + 48);
@@ -762,7 +762,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 
 	if (!is_multicast_ether_addr(hdr->addr1)) {
-		if (tx->skb->len >= tx->local->rts_threshold &&
+		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
 			control->use_rts_cts = 1;
 			control->retry_limit =
@@ -1519,7 +1519,7 @@ static int ieee80211_subif_start_xmit(st
 	sta = sta_info_get(local, hdr.addr1);
 	if (sta) {
 		if (sta->flags & WLAN_STA_WME) {
-			fc |= IEEE80211_STYPE_QOS_DATA << 4;
+			fc |= IEEE80211_STYPE_QOS_DATA;
 			hdrlen += 2;
 		}
 		sta_info_put(sta);
@@ -3074,8 +3074,9 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		     rx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_ASSOC)))) {
 		if ((!(rx->fc & IEEE80211_FCTL_FROMDS) &&
-		     !(rx->fc & IEEE80211_FCTL_TODS)) ||
-		    !rx->u.rx.ra_match) {
+		     !(rx->fc & IEEE80211_FCTL_TODS) &&
+		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)
+		    || !rx->u.rx.ra_match) {
 			/* Drop IBSS frames and frames for other hosts
 			 * silently. */
 			return TXRX_DROP;
@@ -3976,11 +3977,11 @@ static void ieee80211_remove_tx_extra(st
 	pkt_data->requeue = control->requeue;
 	pkt_data->queue = control->queue;
 
-	if (key == NULL)
-		return;
-
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
 
+	if (key == NULL)
+		goto no_key;
+
 	switch (key->alg) {
 	case ALG_WEP:
 		iv_len = WEP_IV_LEN;
@@ -3995,7 +3996,7 @@ static void ieee80211_remove_tx_extra(st
 		mic_len = CCMP_MIC_LEN;
 		break;
 	default:
-		return;
+		goto no_key;
 	}
 
 	if (skb->len >= mic_len && key->force_sw_encrypt)
@@ -4005,11 +4006,12 @@ static void ieee80211_remove_tx_extra(st
 		skb_pull(skb, iv_len);
 	}
 
+no_key:
 	{
 		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 		u16 fc = le16_to_cpu(hdr->frame_control);
 		if ((fc & 0x8C) == 0x88) /* QoS Control Field */ {
-			fc &= ~(IEEE80211_STYPE_QOS_DATA << 4);
+			fc &= ~IEEE80211_STYPE_QOS_DATA;
 			hdr->frame_control = cpu_to_le16(fc);
 			memmove(skb->data + 2, skb->data, hdrlen - 2);
 			skb_pull(skb, 2);
@@ -4379,7 +4381,7 @@ struct net_device *ieee80211_alloc_hw(si
 
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
-		(struct iw_handler_def *) &ieee80211_iw_handler_def;
+		(struct iw_handler_def *) &ieee80211_iw_master_handler_def;
         mdev->do_ioctl = ieee80211_ioctl;
 	mdev->change_mtu = ieee80211_change_mtu;
         mdev->tx_timeout = ieee80211_tx_timeout;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 7e021ec..bdaaf5e 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -569,6 +569,7 @@ void ieee80211_if_mgmt_setup(struct net_
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 extern const struct iw_handler_def ieee80211_iw_handler_def;
+extern const struct iw_handler_def ieee80211_iw_master_handler_def;
 
 /* Set hw encryption from ieee80211 */
 int ieee80211_set_hw_encryption(struct net_device *dev,
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index dd52555..b983716 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -15,6 +15,7 @@ #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
+#include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
@@ -215,6 +216,52 @@ static int ieee80211_ioctl_flush(struct 
 }
 
 
+/* Layer 2 Update frame (802.2 Type 1 LLC XID Update response) */
+struct iapp_layer2_update {
+	u8 da[ETH_ALEN]; /* broadcast */
+	u8 sa[ETH_ALEN]; /* STA addr */
+	u16 len; /* 6 */
+	u8 dsap; /* 0 */
+	u8 ssap; /* 0 */
+	u8 control;
+	u8 xid_info[3];
+} __attribute__ ((packed));
+
+static void ieee80211_send_layer2_update(struct net_device *dev,
+					 const u8 *addr)
+{
+	struct iapp_layer2_update *msg;
+	struct sk_buff *skb;
+
+	/* Send Level 2 Update Frame to update forwarding tables in layer 2
+	 * bridge devices */
+
+	skb = dev_alloc_skb(sizeof(*msg));
+	if (skb == NULL)
+		return;
+	msg = (struct iapp_layer2_update *) skb_put(skb, sizeof(*msg));
+
+	/* 802.2 Type 1 Logical Link Control (LLC) Exchange Identifier (XID)
+	 * Update response frame; IEEE Std 802.2-1998, 5.4.1.2.1 */
+
+	memset(msg->da, 0xff, ETH_ALEN);
+	memcpy(msg->sa, addr, ETH_ALEN);
+	msg->len = htons(6);
+	msg->dsap = 0;
+	msg->ssap = 0x01; /* NULL LSAP, CR Bit: Response */
+	msg->control = 0xaf; /* XID response lsb.1111F101.
+			      * F=0 (no poll command; unsolicited frame) */
+	msg->xid_info[0] = 0x81; /* XID format identifier */
+	msg->xid_info[1] = 1; /* LLC types/classes: Type 1 LLC */
+	msg->xid_info[2] = 0; /* XID sender's receive window size (RW) */
+
+	skb->dev = dev;
+	skb->protocol = eth_type_trans(skb, dev);
+	memset(skb->cb, 0, sizeof(skb->cb));
+	netif_rx(skb);
+}
+
+
 static int ieee80211_ioctl_add_sta(struct net_device *dev,
 				   struct prism2_hostapd_param *param)
 {
@@ -296,6 +343,10 @@ static int ieee80211_ioctl_add_sta(struc
 
 	sta_info_put(sta);
 
+	if (sdata->type == IEEE80211_IF_TYPE_AP ||
+	    sdata->type == IEEE80211_IF_TYPE_VLAN)
+		ieee80211_send_layer2_update(dev, param->sta_addr);
+
 	return 0;
 }
 
@@ -1168,6 +1219,10 @@ #if 0
 			       dev->name, MAC_ARG(param->sta_addr),
                                new_vlan_dev->name);
 #endif
+			if (sta->dev != new_vlan_dev) {
+				ieee80211_send_layer2_update(new_vlan_dev,
+							     sta->addr);
+			}
                         sta->dev = new_vlan_dev;
 			sta->vlan_id = param->u.set_sta_vlan.vlan_id;
                         dev_put(new_vlan_dev);
@@ -2500,7 +2555,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2525,7 +2580,7 @@ static int ieee80211_ioctl_prism2_param(
 			sdata->u.sta.create_ibss = !!value;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2712,7 +2767,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2726,7 +2781,7 @@ static int ieee80211_ioctl_get_prism2_pa
 			*param = sdata->u.sta.key_mgmt;
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
+		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
@@ -2778,7 +2833,7 @@ static int ieee80211_ioctl_siwmlme(struc
 	struct iw_mlme *mlme = (struct iw_mlme *) extra;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata->type != IEEE80211_IF_TYPE_STA ||
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS)
 		return -EINVAL;
 
@@ -3129,3 +3184,25 @@ const struct iw_handler_def ieee80211_iw
 	.private	= (iw_handler *) ieee80211_private_handler,
 	.private_args	= (struct iw_priv_args *) ieee80211_ioctl_priv,
 };
+
+/* Wireless handlers for master interface */
+
+static const iw_handler ieee80211_master_handler[] =
+{
+	[SIOCGIWNAME  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwname,
+	[SIOCSIWFREQ  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwfreq,
+	[SIOCGIWFREQ  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwfreq,
+	[SIOCGIWRANGE - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwrange,
+	[SIOCSIWRTS   - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwrts,
+	[SIOCGIWRTS   - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwrts,
+	[SIOCSIWFRAG  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwfrag,
+	[SIOCGIWFRAG  - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwfrag,
+	[SIOCSIWRETRY - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_siwretry,
+	[SIOCGIWRETRY - SIOCIWFIRST] = (iw_handler) ieee80211_ioctl_giwretry,
+};
+
+const struct iw_handler_def ieee80211_iw_master_handler_def =
+{
+	.num_standard	= sizeof(ieee80211_master_handler) / sizeof(iw_handler),
+	.standard	= ieee80211_master_handler,
+};
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index 3f0cf57..c27a7fe 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -286,6 +286,7 @@ #endif /* CONFIG_TKIP_DEBUG */
 
 	if (only_iv) {
 		res = TKIP_DECRYPT_OK;
+		key->u.tkip.rx_initialized[queue] = 1;
 		goto done;
 	}
 
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index c3c961d..fc2a113 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -76,7 +76,7 @@ ieee80211_rx_h_remove_qos_control(struct
 	memmove(data + 2, data, ieee80211_get_hdrlen(fc) - 2);
 	hdr = (struct ieee80211_hdr *) skb_pull(rx->skb, 2);
 	/* change frame type to non QOS */
-	rx->fc = fc &= ~(IEEE80211_STYPE_QOS_DATA << 4);
+	rx->fc = fc &= ~IEEE80211_STYPE_QOS_DATA;
 	hdr->frame_control = cpu_to_le16(fc);
 
 	return TXRX_CONTINUE;
@@ -199,7 +199,7 @@ static inline int classify80211(struct s
 	}
 
 	/* is this a QoS frame? */
-	qos = fc & (IEEE80211_STYPE_QOS_DATA << 4);
+	qos = fc & IEEE80211_STYPE_QOS_DATA;
 
 	if (!qos) {
 		skb->priority = 0; /* required for correct WPA/11i MIC */
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 7919620..fe5861f 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -70,7 +70,7 @@ int ieee80211_get_hdr_info(const struct 
 	a4_included = (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
 		(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
 	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
-	    (fc & IEEE80211_FCTL_STYPE) & IEEE80211_STYPE_QOS_DATA) {
+	    fc & IEEE80211_STYPE_QOS_DATA) {
 		pos = (u8 *) &hdr->addr4;
 		if (a4_included)
 			pos += 6;
-- 
John W. Linville
linville@tuxdriver.com
