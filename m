From: "John W. Linville" <linville@tuxdriver.com>
Subject: What's new in wireless-dev today? (29 September 2006)
Date: Fri, 29 Sep 2006 17:19:00 -0400
Message-ID: <20060929211853.GB14000@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:30474 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S964836AbWI2VTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 17:19:51 -0400
Received: from bilbo.hq.tuxdriver.com ([70.61.120.53])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id k8TLHjL1028170
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 17:17:50 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k8TLJ1ag025620
	for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 17:19:01 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k8TLJ1nB025604
	for netdev@vger.kernel.org; Fri, 29 Sep 2006 17:19:01 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is today's batch -- I'm still playing "catch-up" in the
wireless-dev tree.  Please bear with me...

---

The following changes since commit 0888451bf4108fbaa07b221649b1289d8f79ef0f:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

David Kimdon:
      d80211: fix multiple device ap support
      d80211: Fix type of prism2_hostapd_param crypt.alg
      d80211: allow vlan interfaces to receive ToDS frames

Hong Liu:
      d80211: fix wpa_supplicant reassoc problem
      d80211: add hardware scan callback
      d80211: fix "iwconfig key [x]" behavior

Ivo van Doorn:
      rt2x00: remove hardware button support

Jiri Benc:
      d80211: fix invalid pointer dereference

Johannes Berg:
      d80211: use BUILD_BUG_ON
      d80211: clean up those huge else if statements
      d80211: use list_for_each_entry{,_safe}
      d80211: LED triggers

John W. Linville:
      Merge branch 'fixes-for-linville' of http://bu3sch.de/git/wireless-dev
      Merge branch 'up' of rsync://rsync.kernel.org/.../jbenc/dscape

mabbas:
      d80211: diplay supported rates in readable format

Michael Buesch:
      ssb: fix init sprom read/write race
      add bcm43xx-d80211 MAINTAINERS entry

Michael Wu:
      d80211: fix WEP on big endian cpus

Mohamed Abbas:
      d80211: getting wrong freq value if we did hardware scan

 MAINTAINERS                                        |    8 +
 drivers/misc/ssb.c                                 |   29 +++--
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    6 +
 drivers/net/wireless/d80211/rt2x00/Kconfig         |   27 -----
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |   36 ------
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |   36 ------
 drivers/net/wireless/d80211/rt2x00/rt2x00.h        |    8 -
 drivers/net/wireless/d80211/rt2x00/rt2x00pci.h     |  111 --------------------
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |   36 ------
 include/linux/ssb.h                                |   15 +++
 include/net/d80211.h                               |   46 ++++++--
 net/d80211/Kconfig                                 |    9 ++
 net/d80211/Makefile                                |   10 +-
 net/d80211/hostapd_ioctl.h                         |    2 
 net/d80211/ieee80211.c                             |   73 +++++--------
 net/d80211/ieee80211_dev.c                         |    7 +
 net/d80211/ieee80211_i.h                           |    6 +
 net/d80211/ieee80211_iface.c                       |    2 
 net/d80211/ieee80211_ioctl.c                       |  108 ++++++++++---------
 net/d80211/ieee80211_led.c                         |   93 ++++++++++++++---
 net/d80211/ieee80211_led.h                         |   32 ++++++
 net/d80211/ieee80211_sta.c                         |  107 +++++++++++--------
 net/d80211/sta_info.c                              |   26 ++---
 net/d80211/wep.c                                   |   10 +-
 24 files changed, 371 insertions(+), 472 deletions(-)
 create mode 100644 net/d80211/ieee80211_led.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 3748cb1..2f06c7c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -464,6 +464,14 @@ L:	linux-hams@vger.kernel.org
 W:	http://www.baycom.org/~tom/ham/ham.html
 S:	Maintained
 
+BCM43XX WIRELESS DRIVER (DEVICESCAPE BASED VERSION)
+P:	Michael Buesch
+M:	mb@bu3sch.de
+P:	Stefano Brivio
+M:	st3@riseup.net
+W:	http://bcm43xx.berlios.de/
+S:	Maintained
+
 BCM43XX WIRELESS DRIVER (SOFTMAC BASED VERSION)
 P:	Larry Finger
 M:	Larry.Finger@lwfinger.net
diff --git a/drivers/misc/ssb.c b/drivers/misc/ssb.c
index 44ab647..6087977 100644
--- a/drivers/misc/ssb.c
+++ b/drivers/misc/ssb.c
@@ -516,8 +516,6 @@ int ssb_init(struct ssb *ssb,
 	     int (*device_suspend)(struct ssb *ssb),
 	     int (*device_resume)(struct ssb *ssb))
 {
-	int err;
-
 	if (!ssb || !pci_dev || !mmio ||
 	    !device_suspend || !device_resume)
 		return -EINVAL;
@@ -535,19 +533,12 @@ int ssb_init(struct ssb *ssb,
 	list_add(&ssb->list, &ssb_list);
 	mutex_unlock(&ssb_list_mutex);
 
-	err = device_create_file(&pci_dev->dev, &dev_attr_ssb_sprom);
-	if (err)
-		goto out;
-
-out:
-	return err;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(ssb_init);
 
 void ssb_exit(struct ssb *ssb)
 {
-	device_remove_file(&ssb->pci_dev->dev, &dev_attr_ssb_sprom);
-
 	mutex_lock(&ssb_list_mutex);
 	list_del(&ssb->list);
 	mutex_unlock(&ssb_list_mutex);
@@ -558,6 +549,24 @@ void ssb_exit(struct ssb *ssb)
 }
 EXPORT_SYMBOL_GPL(ssb_exit);
 
+int ssb_start(struct ssb *ssb)
+{
+	int err;
+
+	err = device_create_file(&ssb->pci_dev->dev,
+				 &dev_attr_ssb_sprom);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(ssb_start);
+
+void ssb_stop(struct ssb *ssb)
+{
+	device_remove_file(&ssb->pci_dev->dev,
+			   &dev_attr_ssb_sprom);
+}
+EXPORT_SYMBOL_GPL(ssb_stop);
+
 static int do_switch_core(struct ssb *ssb, u8 coreidx)
 {
 	int err;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index d71d797..82f1fd1 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -2600,6 +2600,7 @@ static int bcm43xx_shutdown_all_wireless
 /* This is the opposite of bcm43xx_init_board() */
 static void bcm43xx_free_board(struct bcm43xx_private *bcm)
 {
+	ssb_stop(&bcm->ssb);
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
@@ -3189,12 +3190,17 @@ static int bcm43xx_init_board(struct bcm
 	err = bcm43xx_sysfs_register(bcm);
 	if (err)
 		goto err_wlshutdown;
+	err = ssb_start(&bcm->ssb);
+	if (err)
+		goto err_sysfs_unreg;
 	bcm43xx_periodic_tasks_setup(bcm);
 out:
 	mutex_unlock(&bcm->mutex);
 
 	return err;
 
+err_sysfs_unreg:
+	bcm43xx_sysfs_unregister(bcm);
 err_wlshutdown:
 	bcm43xx_shutdown_all_wireless_cores(bcm);
 err_crystal_off:
diff --git a/drivers/net/wireless/d80211/rt2x00/Kconfig b/drivers/net/wireless/d80211/rt2x00/Kconfig
index d9b97f1..66bbb16 100644
--- a/drivers/net/wireless/d80211/rt2x00/Kconfig
+++ b/drivers/net/wireless/d80211/rt2x00/Kconfig
@@ -15,15 +15,6 @@ config RT2400PCI
 
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
@@ -38,15 +29,6 @@ config RT2500PCI
 
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
@@ -61,15 +43,6 @@ config RT61PCI
 
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 59163bf..a46b8b8 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -51,10 +51,6 @@ #ifdef CONFIG_RT2400PCI_DEBUG
 #define CONFIG_RT2X00_DEBUG
 #endif /* CONFIG_RT2400PCI_DEBUG */
 
-#ifdef CONFIG_RT2400PCI_BUTTON
-#define CONFIG_RT2X00_BUTTON
-#endif /* CONFIG_RT2400PCI_BUTTON */
-
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2400pci.h"
@@ -346,23 +342,6 @@ static void rt2x00_eeprom_multiread(cons
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
@@ -2750,11 +2729,6 @@ static void rt2400pci_free_dev(struct ne
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
@@ -2838,11 +2812,6 @@ static int rt2400pci_alloc_dev(struct pc
 		goto exit;
 	}
 
-	/*
-	 * If required start hardware button polling.
-	 */
-	rt2x00pci_button_start(rt2x00dev, rt2400pci_button_poll);
-
 	return 0;
 
 exit:
@@ -3048,11 +3017,6 @@ module_param_named(debug, rt2x00_debug_l
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 651fbec..c08b076 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -51,10 +51,6 @@ #ifdef CONFIG_RT2500PCI_DEBUG
 #define CONFIG_RT2X00_DEBUG
 #endif /* CONFIG_RT2500PCI_DEBUG */
 
-#ifdef CONFIG_RT2500PCI_BUTTON
-#define CONFIG_RT2X00_BUTTON
-#endif /* CONFIG_RT2500PCI_BUTTON */
-
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2500pci.h"
@@ -346,23 +342,6 @@ static void rt2x00_eeprom_multiread(cons
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
@@ -3035,11 +3014,6 @@ static void rt2500pci_free_dev(struct ne
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
@@ -3123,11 +3097,6 @@ static int rt2500pci_alloc_dev(struct pc
 		goto exit;
 	}
 
-	/*
-	 * If required start hardware button polling.
-	 */
-	rt2x00pci_button_start(rt2x00dev, rt2500pci_button_poll);
-
 	return 0;
 
 exit:
@@ -3333,11 +3302,6 @@ module_param_named(debug, rt2x00_debug_l
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
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2x00.h b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
index e0ae5fe..76845c8 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
@@ -866,14 +866,6 @@ #define CONFIG_DISABLE_BBP_TUNING	0x0002
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
index 9a0462a..3e1a702 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -52,10 +52,6 @@ #ifdef CONFIG_RT61PCI_DEBUG
 #define CONFIG_RT2X00_DEBUG
 #endif /* CONFIG_RT61PCI_DEBUG */
 
-#ifdef CONFIG_RT61PCI_BUTTON
-#define CONFIG_RT2X00_BUTTON
-#endif /* CONFIG_RT61PCI_BUTTON */
-
 #include "rt2x00.h"
 #include "rt2x00pci.h"
 #include "rt2x00crc.h"
@@ -377,23 +373,6 @@ static void rt2x00_eeprom_multiread(cons
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
@@ -3547,11 +3526,6 @@ static void rt61pci_free_dev(struct net_
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
@@ -3640,11 +3614,6 @@ static int rt61pci_alloc_dev(struct pci_
 		goto exit;
 	}
 
-	/*
-	 * If required start hardware button polling.
-	 */
-	rt2x00pci_button_start(rt2x00dev, rt61pci_button_poll);
-
 	return 0;
 
 exit:
@@ -3856,11 +3825,6 @@ module_param_named(debug, rt2x00_debug_l
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
diff --git a/include/linux/ssb.h b/include/linux/ssb.h
index a36dd75..09c28a8 100644
--- a/include/linux/ssb.h
+++ b/include/linux/ssb.h
@@ -504,7 +504,7 @@ #endif
 
 /**
  * ssb_init - Initialize struct ssb.
- * This does not init hardware. May fail and return NULL.
+ * Call this before initializing the hardware.
  * @ssb:	Pointer to struct ssb to init. This will usually
  * 		be embedded in the device's private struct.
  * @pci_dev:	Pointer to the PCI device.
@@ -521,6 +521,19 @@ int ssb_init(struct ssb *ssb,
 void ssb_exit(struct ssb *ssb);
 
 /**
+ * ssb_start - Start the ssb operation.
+ * Call this after initializing the hardware.
+ * @ssb:	Pointer to struct ssb.
+ */
+int ssb_start(struct ssb *ssb);
+/**
+ * ssb_stop - Stop the ssb operation.
+ * Call this before shutting down the hardware.
+ * @ssb:	Pointer to struct ssb.
+ */
+void ssb_stop(struct ssb *ssb);
+
+/**
  * struct ssb_nrcores_elem - Array element of the
  * "number of cores" fallback array.
  * This array is browsed, if there is no ChipCommon rev >= 4
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 42fdbf7..a80f48b 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -600,6 +600,10 @@ struct ieee80211_hw {
         int (*passive_scan)(struct net_device *dev, int state,
                             struct ieee80211_scan_conf *conf);
 
+	/* Ask the hardware to service the scan request, no need to start
+	 * the scan state machine in stack. */
+	int (*hw_scan)(struct net_device *dev, u8 *ssid, size_t len);
+
         /* return low-level statistics */
 	int (*get_stats)(struct net_device *dev,
 			 struct ieee80211_low_level_stats *stats);
@@ -699,6 +703,36 @@ struct net_device *ieee80211_alloc_hw(si
  * function. */
 int ieee80211_register_hw(struct net_device *dev, struct ieee80211_hw *hw);
 
+/* driver can use this and ieee80211_get_rx_led_name to get the
+ * name of the registered LEDs after ieee80211_register_hw
+ * was called.
+ * This is useful to set the default trigger on the LED class
+ * device that your driver should export for each LED the device
+ * has, that way the default behaviour will be as expected but
+ * the user can still change it/turn off the LED etc.
+ */
+#ifdef CONFIG_D80211_LEDS
+extern char *__ieee80211_get_tx_led_name(struct net_device *dev);
+extern char *__ieee80211_get_rx_led_name(struct net_device *dev);
+#endif
+static inline char *ieee80211_get_tx_led_name(struct net_device *dev)
+{
+#ifdef CONFIG_D80211_LEDS
+	return __ieee80211_get_tx_led_name(dev);
+#else
+	return NULL;
+#endif
+}
+
+static inline char *ieee80211_get_rx_led_name(struct net_device *dev)
+{
+#ifdef CONFIG_D80211_LEDS
+	return __ieee80211_get_rx_led_name(dev);
+#else
+	return NULL;
+#endif
+}
+
 /* This function is allowed to update hardware configuration (e.g., list of
  * supported operation modes and rates). */
 int ieee80211_update_hw(struct net_device *dev, struct ieee80211_hw *hw);
@@ -863,6 +897,8 @@ struct dev_mc_list *ieee80211_get_mc_lis
 struct ieee80211_conf *
 ieee80211_get_hw_conf(struct net_device *dev);
 
+/* called by driver to notify scan status completed */
+void ieee80211_scan_completed(struct net_device *dev);
 
 /* Return a pointer to the low-level private data area for the given device. */
 void * ieee80211_dev_hw_data(struct net_device *dev);
@@ -897,16 +933,6 @@ enum {
 	IEEE80211_TEST_PARAM_TX_ANT_SEL_RAW = 5,
 };
 
-/* ieee80211_tx_led called with state == 1 when the first frame is queued
- *   with state == 0 when the last frame is transmitted and tx queue is empty
- */
-void ieee80211_tx_led(int state, struct net_device *dev);
-/* ieee80211_rx_led is called each time frame is received, state is not used
- * (== 2)
- */
-void ieee80211_rx_led(int state, struct net_device *dev);
-
-
 /* IEEE 802.11 defines */
 
 #define FCS_LEN 4
diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index 2f3c0a3..0f07d41 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -7,6 +7,15 @@ config D80211
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
 
+config D80211_LEDS
+	bool "Enable LED triggers"
+	depends on D80211
+	select NEW_LEDS
+	select LEDS_TRIGGERS
+	---help---
+	This option enables a few LED triggers for different
+	packet receive/transmit events.
+
 config D80211_DEBUG
 	bool "Enable debugging output"
 	depends on D80211
diff --git a/net/d80211/Makefile b/net/d80211/Makefile
index c21e882..2a2a0c6 100644
--- a/net/d80211/Makefile
+++ b/net/d80211/Makefile
@@ -1,5 +1,7 @@
 obj-$(CONFIG_D80211) += 80211.o rate_control.o
 
+80211-objs-$(CONFIG_D80211_LEDS) += ieee80211_led.o
+
 80211-objs := \
 	ieee80211.o \
 	ieee80211_ioctl.o \
@@ -15,13 +17,9 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	michael.o \
 	tkip.o \
 	aes_ccm.o \
-	wme.o
+	wme.o \
+	$(80211-objs-y)
 
 ifeq ($(CONFIG_NET_SCHED),)
   80211-objs += fifo_qdisc.o
 endif
-
-ifeq ($(CONFIG_D80211_LEDS),y)
-  80211-objs += ieee80211_led.o
-endif
-
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index 7c7305c..d302790 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -207,7 +207,7 @@ #define IEEE80211_STA_DYNAMIC_ENC BIT(0)
 			u32 last_ack_rssi;
 		} get_info_sta;
 		struct {
-			u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
+			char alg[HOSTAP_CRYPT_ALG_NAME_LEN];
 			u32 flags;
 			u32 err;
 			u8 idx;
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 320272c..1ef2707 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -31,7 +31,7 @@ #include "wpa.h"
 #include "tkip.h"
 #include "wme.h"
 #include "aes_ccm.h"
-
+#include "ieee80211_led.h"
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
@@ -945,13 +945,12 @@ static void purge_old_ps_buffers(struct 
 {
 	int total = 0, purged = 0;
 	struct sk_buff *skb;
-	struct list_head *ptr;
+	struct ieee80211_sub_if_data *sdata;
+	struct sta_info *sta;
 
 	spin_lock_bh(&local->sub_if_lock);
-	list_for_each(ptr, &local->sub_if_list)	{
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
 		struct ieee80211_if_ap *ap;
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
 		if (sdata->dev == local->mdev ||
 		    sdata->type != IEEE80211_IF_TYPE_AP)
 			continue;
@@ -966,9 +965,7 @@ static void purge_old_ps_buffers(struct 
 	spin_unlock_bh(&local->sub_if_lock);
 
 	spin_lock_bh(&local->sta_lock);
-	list_for_each(ptr, &local->sta_list) {
-		struct sta_info *sta =
-			list_entry(ptr, struct sta_info, list);
+	list_for_each_entry(sta, &local->sta_list, list) {
 		skb = skb_dequeue(&sta->ps_tx_buf);
 		if (skb) {
 			purged++;
@@ -1183,11 +1180,7 @@ static int __ieee80211_tx(struct ieee802
 		ret = local->hw->tx(local->mdev, skb, control);
 		if (ret)
 			return IEEE80211_TX_AGAIN;
-#ifdef IEEE80211_LEDS
-		if (local->tx_led_counter++ == 0) {
-			ieee80211_tx_led(1, local->mdev);
-		}
-#endif /* IEEE80211_LEDS */
+		ieee80211_led_tx(local, 1);
 	}
 	if (tx->u.tx.extra_frag) {
 		control->use_rts_cts = 0;
@@ -1212,11 +1205,7 @@ #endif /* IEEE80211_LEDS */
 					    control);
 			if (ret)
 				return IEEE80211_TX_FRAG_AGAIN;
-#ifdef IEEE80211_LEDS
-			if (local->tx_led_counter++ == 0) {
-				ieee80211_tx_led(1, local->mdev);
-			}
-#endif /* IEEE80211_LEDS */
+			ieee80211_led_tx(local, 1);
 			tx->u.tx.extra_frag[i] = NULL;
 		}
 		kfree(tx->u.tx.extra_frag);
@@ -2374,7 +2363,8 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP)) {
+		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP &&
+			     sdata->type != IEEE80211_IF_TYPE_VLAN)) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
 			       MAC_FMT " SA=" MAC_FMT " DA=" MAC_FMT ")\n",
 			       dev->name, MAC_ARG(hdr->addr1),
@@ -3000,10 +2990,8 @@ ieee80211_rx_h_defragment(struct ieee802
 		rx->sta->rx_packets++;
 	if (is_multicast_ether_addr(hdr->addr1))
 		rx->local->dot11MulticastReceivedFrameCount++;
-#ifdef IEEE80211_LEDS
         else
-		ieee80211_rx_led(2, rx->dev);
-#endif /* IEEE80211_LEDS */
+		ieee80211_led_rx(rx->local);
 	return TXRX_CONTINUE;
 }
 
@@ -3828,16 +3816,15 @@ ieee80211_rx_h_if_stats(struct ieee80211
 static void ieee80211_stat_refresh(unsigned long data)
 {
 	struct ieee80211_local *local = (struct ieee80211_local *) data;
-        struct list_head *ptr, *n;
+	struct sta_info *sta;
+	struct ieee80211_sub_if_data *sdata;
 
 	if (!local->stat_time)
 		return;
 
 	/* go through all stations */
 	spin_lock_bh(&local->sta_lock);
-	list_for_each(ptr, &local->sta_list) {
-		struct sta_info *sta =
-			list_entry(ptr, struct sta_info, list);
+	list_for_each_entry(sta, &local->sta_list, list) {
 		sta->channel_use = (sta->channel_use_raw / local->stat_time) /
 			CHAN_UTIL_PER_10MS;
 		sta->channel_use_raw = 0;
@@ -3845,14 +3832,11 @@ static void ieee80211_stat_refresh(unsig
 	spin_unlock_bh(&local->sta_lock);
 
 	/* go through all subinterfaces */
-	list_for_each_safe(ptr, n, &local->sub_if_list) {
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
                 sdata->channel_use = (sdata->channel_use_raw /
 				      local->stat_time) / CHAN_UTIL_PER_10MS;
                 sdata->channel_use_raw = 0;
-
-        }
+	}
 
 	/* hardware interface */
 	local->channel_use = (local->channel_use_raw /
@@ -4106,11 +4090,8 @@ void ieee80211_tx_status(struct net_devi
 		rate_control_tx_status(dev, skb, status);
 	}
 
-#ifdef IEEE80211_LEDS
-        if (local->tx_led_counter && (local->tx_led_counter-- == 1)) {
-                ieee80211_tx_led(0, dev);
-        }
-#endif /* IEEE80211_LEDS */
+	ieee80211_led_tx(local, 0);
+
         /* SNMP counters
 	 * Fragments are passed to low-level drivers as separate skbs, so these
 	 * are actually fragments, not frames. Update frame counters only for
@@ -4507,6 +4488,8 @@ int ieee80211_register_hw(struct net_dev
 	local->reg_state = IEEE80211_DEV_REGISTERED;
 	rtnl_unlock();
 
+	ieee80211_led_init(local);
+
 	return 0;
 
 fail_rate_attrs:
@@ -4562,7 +4545,7 @@ EXPORT_SYMBOL(ieee80211_update_hw);
 void ieee80211_unregister_hw(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-        struct list_head *ptr, *n;
+	struct ieee80211_sub_if_data *sdata, *tmp;
 	int i;
 
         tasklet_disable(&local->tasklet);
@@ -4575,11 +4558,9 @@ void ieee80211_unregister_hw(struct net_
 
 	sysfs_remove_link(&local->class_dev.kobj, "master");
 
-	list_for_each_safe(ptr, n, &local->sub_if_list) {
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
+	list_for_each_entry_safe(sdata, tmp, &local->sub_if_list, list)
 		__ieee80211_if_del(local, sdata);
-	}
+
 	rtnl_unlock();
 
 	if (local->rate_limit)
@@ -4615,6 +4596,7 @@ void ieee80211_unregister_hw(struct net_
 	skb_queue_purge(&local->skb_queue_unreliable);
 
 	ieee80211_dev_free_index(local);
+	ieee80211_led_exit(local);
 }
 EXPORT_SYMBOL(ieee80211_unregister_hw);
 
@@ -4799,13 +4781,8 @@ static int __init ieee80211_init(void)
 	struct sk_buff *skb;
 	int ret;
 
-	if (sizeof(struct ieee80211_tx_packet_data) > (sizeof(skb->cb))) {
-		printk("80211: ieee80211_tx_packet_data is bigger "
-		       "than the skb->cb (%d > %d)\n",
-		       (int) sizeof(struct ieee80211_tx_packet_data),
-		       (int) sizeof(skb->cb));
-		return -EINVAL;
-	}
+	BUILD_BUG_ON(sizeof(struct ieee80211_tx_packet_data) > sizeof(skb->cb));
+
 	if ((ret = ieee80211_sysfs_init())) {
 		printk(KERN_WARNING "ieee80211_init: sysfs initialization "
 		       "failed\n");
diff --git a/net/d80211/ieee80211_dev.c b/net/d80211/ieee80211_dev.c
index 6c6ca91..48a5e56 100644
--- a/net/d80211/ieee80211_dev.c
+++ b/net/d80211/ieee80211_dev.c
@@ -13,6 +13,7 @@ #include <linux/if_ether.h>
 #include <linux/netdevice.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
+#include "ieee80211_led.h"
 
 struct ieee80211_dev_list {
 	struct list_head list;
@@ -38,7 +39,6 @@ static struct ieee80211_dev_list *__ieee
 
 int ieee80211_dev_alloc_index(struct ieee80211_local *local)
 {
-	struct list_head *i;
 	struct ieee80211_dev_list *dev_item, *new;
 	int index = 0;
 
@@ -47,14 +47,13 @@ int ieee80211_dev_alloc_index(struct iee
 		return -ENOMEM;
 	new->local = local;
 	spin_lock(&dev_list_lock);
-	list_for_each(i, &dev_list) {
-		dev_item = list_entry(i, struct ieee80211_dev_list, list);
+	list_for_each_entry(dev_item, &dev_list, list) {
 		if (index < dev_item->dev_index)
 			break;
 		index++;
 	}
 	new->dev_index = index;
-	list_add_tail(&new->list, i);
+	list_add_tail(&new->list, &dev_item->list);
 	spin_unlock(&dev_list_lock);
 	local->dev_index = index;
 	return index;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 0d2d79d..425fc9b 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -459,7 +459,11 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
         u32 dot11TransmittedFrameCount;
         u32 dot11WEPUndecryptableCount;
 
-        int tx_led_counter;
+#ifdef CONFIG_D80211_LEDS
+	int tx_led_counter, rx_led_counter;
+	struct led_trigger *tx_led, *rx_led;
+	char tx_led_name[32], rx_led_name[32];
+#endif
 
 	u32 channel_use;
 	u32 channel_use_raw;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index bdff4cd..0a10c86 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -122,7 +122,7 @@ int ieee80211_if_add_mgmt(struct net_dev
 	if (!ndev)
 		return -ENOMEM;
 	ret = dev_alloc_name(ndev, "wmgmt%d");
-	if (ret)
+	if (ret < 0)
 		goto fail;
 
 	ndev->ieee80211_ptr = local;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..445adad 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1000,11 +1000,13 @@ static int ieee80211_ioctl_add_if(struct
         int left = param_len - ((u8 *) pos - (u8 *) param);
 	struct net_device *new_dev;
 	int res;
+	struct hostapd_if_wds *wds;
+	struct hostapd_if_bss *bss;
 
 	printk(KERN_WARNING "PRISM2_HOSTAPD_ADD_IF ioctl is deprecated!");
-        if (param->u.if_info.type == HOSTAP_IF_WDS) {
-                struct hostapd_if_wds *wds =
-			(struct hostapd_if_wds *) param->u.if_info.data;
+	switch (param->u.if_info.type) {
+	case HOSTAP_IF_WDS:
+		wds = (struct hostapd_if_wds *) param->u.if_info.data;
 
                 if (left < sizeof(struct hostapd_if_wds))
                         return -EPROTO;
@@ -1018,7 +1020,7 @@ static int ieee80211_ioctl_add_if(struct
 			__ieee80211_if_del(dev->ieee80211_ptr,
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 		return res;
-	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
+	case HOSTAP_IF_VLAN:
 		if (left < sizeof(struct hostapd_if_vlan))
 			return -EPROTO;
 
@@ -1033,9 +1035,8 @@ #if 0
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 #endif
 		return res;
-        } else if (param->u.if_info.type == HOSTAP_IF_BSS) {
-                struct hostapd_if_bss *bss =
-			(struct hostapd_if_bss *) param->u.if_info.data;
+	case HOSTAP_IF_BSS:
+		bss = (struct hostapd_if_bss *) param->u.if_info.data;
 
                 if (left < sizeof(struct hostapd_if_bss))
                         return -EPROTO;
@@ -1046,12 +1047,7 @@ #endif
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_AP);
 		memcpy(new_dev->dev_addr, bss->bssid, ETH_ALEN);
 		return 0;
-        } else if (param->u.if_info.type == HOSTAP_IF_STA) {
-#if 0
-                struct hostapd_if_sta *sta =
-			(struct hostapd_if_sta *) param->u.if_info.data;
-#endif
-
+	case HOSTAP_IF_STA:
                 if (left < sizeof(struct hostapd_if_sta))
                         return -EPROTO;
 
@@ -1060,34 +1056,38 @@ #endif
 			return res;
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
 		return 0;
-	} else
-                return -EINVAL;
+	default:
+		return -EINVAL;
+	}
 
 	return 0;
 }
 
-
 static int ieee80211_ioctl_remove_if(struct net_device *dev,
 				     struct prism2_hostapd_param *param)
 {
 	unsigned int type;
 
-	if (param->u.if_info.type == HOSTAP_IF_WDS) {
+	switch (param->u.if_info.type) {
+	case HOSTAP_IF_WDS:
 		type = IEEE80211_IF_TYPE_WDS;
-	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
+		break;
+	case HOSTAP_IF_VLAN:
 		type = IEEE80211_IF_TYPE_VLAN;
-	} else if (param->u.if_info.type == HOSTAP_IF_BSS) {
+		break;
+	case HOSTAP_IF_BSS:
 		type = IEEE80211_IF_TYPE_AP;
-	} else if (param->u.if_info.type == HOSTAP_IF_STA) {
+		break;
+	case HOSTAP_IF_STA:
 		type = IEEE80211_IF_TYPE_STA;
-	} else {
+		break;
+	default:
 		return -EINVAL;
 	}
 
 	return ieee80211_if_remove(dev, param->u.if_info.name, type);
 }
 
-
 static int ieee80211_ioctl_update_if(struct net_device *dev,
 				     struct prism2_hostapd_param *param,
 				     int param_len)
@@ -2174,23 +2174,21 @@ static int ieee80211_ioctl_clear_keys(st
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_key_conf key;
-	struct list_head *ptr;
 	int i;
 	u8 addr[ETH_ALEN];
 	struct ieee80211_key_conf *keyconf;
+	struct ieee80211_sub_if_data *sdata;
+	struct sta_info *sta;
 
 	memset(addr, 0xff, ETH_ALEN);
-	list_for_each(ptr, &local->sub_if_list)	{
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
+	list_for_each_entry(sdata, &local->sub_if_list, list) {
 		for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
 			keyconf = NULL;
 			if (sdata->keys[i] &&
 			    !sdata->keys[i]->force_sw_encrypt &&
 			    local->hw->set_key &&
 			    (keyconf = ieee80211_key_data2conf(local,
-							       sdata->keys[i]))
-			    != NULL)
+							       sdata->keys[i])))
 				local->hw->set_key(dev, DISABLE_KEY, addr,
 						   keyconf, 0);
 			kfree(keyconf);
@@ -2201,14 +2199,11 @@ static int ieee80211_ioctl_clear_keys(st
 	}
 
 	spin_lock_bh(&local->sta_lock);
-	list_for_each(ptr, &local->sta_list) {
-		struct sta_info *sta =
-			list_entry(ptr, struct sta_info, list);
+	list_for_each_entry(sta, &local->sta_list, list) {
 		keyconf = NULL;
 		if (sta->key && !sta->key->force_sw_encrypt &&
 		    local->hw->set_key &&
-		    (keyconf = ieee80211_key_data2conf(local, sta->key))
-		    != NULL)
+		    (keyconf = ieee80211_key_data2conf(local, sta->key)))
 			local->hw->set_key(dev, DISABLE_KEY, sta->addr,
 					   keyconf, sta->aid);
 		kfree(keyconf);
@@ -2324,22 +2319,17 @@ static int ieee80211_ioctl_default_wep_o
 					    int value)
 {
 	int i;
-	struct list_head *ptr;
+	struct ieee80211_sub_if_data *sdata;
 
 	local->default_wep_only = value;
-	list_for_each(ptr, &local->sub_if_list)	{
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (value) {
+	list_for_each_entry(sdata, &local->sub_if_list, list)
+		for (i = 0; i < NUM_DEFAULT_KEYS; i++)
+			if (value)
 				ieee80211_key_enable_hwaccel(local,
 							     sdata->keys[i]);
-			} else {
+			else
 				ieee80211_key_disable_hwaccel(local,
 							      sdata->keys[i]);
-			}
-		}
-	}
 
 	return 0;
 }
@@ -2867,9 +2857,10 @@ static int ieee80211_ioctl_siwencode(str
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
@@ -2880,16 +2871,21 @@ static int ieee80211_ioctl_siwencode(str
 		alg = ALG_NONE;
 	else if (erq->length == 0) {
 		/* No key data - just set the default TX key index */
-		sdata->default_key = sdata->keys[idx];
+		if (sdata->default_key != sdata->keys[idx]) {
+			if (sdata->default_key)
+				ieee80211_key_sysfs_remove_default(sdata);
+			sdata->default_key = sdata->keys[idx];
+			if (sdata->default_key)
+				ieee80211_key_sysfs_add_default(sdata);
+		}
+		return 0;
 	}
 
 	return ieee80211_set_encryption(
 		dev, bcaddr,
-		idx, erq->length == 0 ? ALG_NONE : ALG_WEP,
+		idx, alg,
 		!sdata->default_key,
 		NULL, keybuf, erq->length);
-
-	return 0;
 }
 
 
@@ -2908,9 +2904,10 @@ static int ieee80211_ioctl_giwencode(str
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
@@ -2925,7 +2922,9 @@ static int ieee80211_ioctl_giwencode(str
 		return 0;
 	}
 
-	erq->length = 0;
+	memcpy(key, sdata->keys[idx]->key,
+	       min((int)erq->length, sdata->keys[idx]->keylen));
+	erq->length = sdata->keys[idx]->keylen;
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	return 0;
@@ -3054,9 +3053,10 @@ static int ieee80211_ioctl_siwencodeext(
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
diff --git a/net/d80211/ieee80211_led.c b/net/d80211/ieee80211_led.c
index de3f52c..073092a 100644
--- a/net/d80211/ieee80211_led.c
+++ b/net/d80211/ieee80211_led.c
@@ -1,32 +1,91 @@
 /*
- * Copyright 2002-2004, Instant802 Networks, Inc.
+ * Copyright 2006, Johannes Berg <johannes@sipsolutions.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
 
-#include <linux/config.h>
-#include <linux/netdevice.h>
-#include <linux/types.h>
+/* just for IFNAMSIZ */
+#include <linux/if.h>
+#include "ieee80211_led.h"
 
-#ifdef CONFIG_OAP_LEDS_WLAN
-extern void leds_wlan_set(int unit, int tx, int state);
-#endif
+void ieee80211_led_rx(struct ieee80211_local *local)
+{
+	if (unlikely(!local->rx_led))
+		return;
+	if (local->rx_led_counter++ % 2 == 0)
+		led_trigger_event(local->rx_led, LED_OFF);
+	else
+		led_trigger_event(local->rx_led, LED_FULL);
+}
+
+/* q is 1 if a packet was enqueued, 0 if it has been transmitted */
+void ieee80211_led_tx(struct ieee80211_local *local, int q)
+{
+	if (unlikely(!local->tx_led))
+		return;
+	/* not sure how this is supposed to work ... */
+	local->tx_led_counter += 2*q-1;
+	if (local->tx_led_counter % 2 == 0)
+		led_trigger_event(local->tx_led, LED_OFF);
+	else
+		led_trigger_event(local->tx_led, LED_FULL);
+}
 
-void ieee80211_rx_led(int state, struct net_device *dev) {
-#ifdef CONFIG_OAP_LEDS_WLAN
-	static unsigned int count = 0;
+void ieee80211_led_init(struct ieee80211_local *local)
+{
+	local->rx_led = kzalloc(sizeof(struct led_trigger), GFP_KERNEL);
+	if (!local->rx_led)
+		return;
+	snprintf(local->rx_led_name, sizeof(local->rx_led_name),
+		 "wiphy%drx", local->dev_index);
+	local->rx_led->name = local->rx_led_name;
+	if (led_trigger_register(local->rx_led)) {
+		kfree(local->rx_led);
+		local->rx_led = NULL;
+	}
 
-	if (state == 2) {
-		leds_wlan_set(0, 0, (++count) & 1);
+	local->tx_led = kzalloc(sizeof(struct led_trigger), GFP_KERNEL);
+	if (!local->tx_led)
+		return;
+	snprintf(local->tx_led_name, sizeof(local->tx_led_name),
+		 "wiphy%dtx", local->dev_index);
+	local->tx_led->name = local->tx_led_name;
+	if (led_trigger_register(local->tx_led)) {
+		kfree(local->tx_led);
+		local->tx_led = NULL;
 	}
-#endif
 }
 
-void ieee80211_tx_led(int state, struct net_device *dev) {
-#ifdef CONFIG_OAP_LEDS_WLAN
-        leds_wlan_set(0, 1, state);
-#endif
+void ieee80211_led_exit(struct ieee80211_local *local)
+{
+	if (local->tx_led) {
+		led_trigger_unregister(local->tx_led);
+		kfree(local->tx_led);
+	}
+	if (local->rx_led) {
+		led_trigger_unregister(local->rx_led);
+		kfree(local->rx_led);
+	}
 }
 
+char *__ieee80211_get_tx_led_name(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+
+	if (local->tx_led)
+		return local->tx_led_name;
+	return NULL;
+}
+EXPORT_SYMBOL(__ieee80211_get_tx_led_name);
+
+char *__ieee80211_get_rx_led_name(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+
+	if (local->rx_led)
+		return local->rx_led_name;
+	return NULL;
+}
+EXPORT_SYMBOL(__ieee80211_get_rx_led_name);
diff --git a/net/d80211/ieee80211_led.h b/net/d80211/ieee80211_led.h
new file mode 100644
index 0000000..2a539af
--- /dev/null
+++ b/net/d80211/ieee80211_led.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright 2006, Johannes Berg <johannes@sipsolutions.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/leds.h>
+#include "ieee80211_i.h"
+
+#ifdef CONFIG_D80211_LEDS
+extern void ieee80211_led_rx(struct ieee80211_local *local);
+extern void ieee80211_led_tx(struct ieee80211_local *local, int q);
+extern void ieee80211_led_init(struct ieee80211_local *local);
+extern void ieee80211_led_exit(struct ieee80211_local *local);
+#else
+static inline void ieee80211_led_rx(struct ieee80211_local *local)
+{
+}
+static inline void ieee80211_led_tx(struct ieee80211_local *local, int q)
+{
+}
+static inline void ieee80211_led_init(struct ieee80211_local *local)
+{
+}
+static inline void ieee80211_led_exit(struct ieee80211_local *local)
+{
+}
+#endif
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a933d92..dd95ce8 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -710,6 +710,8 @@ static void ieee80211_associated(struct 
 				       "range\n",
 				       dev->name, MAC_ARG(ifsta->bssid));
 				disassoc = 1;
+				sta_info_free(sta, 0);
+				ifsta->probereq_poll = 0;
 			} else {
 				ieee80211_send_probe_req(dev, ifsta->bssid,
 							 local->scan_ssid,
@@ -1539,12 +1541,12 @@ #endif
 	}
 
 
-	bss->hw_mode = local->conf.phymode;
+	bss->hw_mode = rx_status->phymode;
 	bss->channel = channel;
-	bss->freq = local->conf.freq;
-	if (channel != local->conf.channel &&
-	    (local->conf.phymode == MODE_IEEE80211G ||
-	     local->conf.phymode == MODE_IEEE80211B) &&
+	bss->freq = rx_status->freq;
+	if (channel != rx_status->channel &&
+	    (bss->hw_mode == MODE_IEEE80211G ||
+	     bss->hw_mode == MODE_IEEE80211B) &&
 	    channel >= 1 && channel <= 14) {
 		static const int freq_list[] = {
 			2412, 2417, 2422, 2427, 2432, 2437, 2442,
@@ -1789,13 +1791,11 @@ void ieee80211_sta_rx_scan(struct net_de
 static int ieee80211_sta_active_ibss(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct list_head *ptr;
 	int active = 0;
 	struct sta_info *sta;
 
 	spin_lock_bh(&local->sta_lock);
-	list_for_each(ptr, &local->sta_list) {
-		sta = list_entry(ptr, struct sta_info, list);
+	list_for_each_entry(sta, &local->sta_list, list) {
 		if (sta->dev == dev &&
 		    time_after(sta->last_rx + IEEE80211_IBSS_MERGE_INTERVAL,
 			       jiffies)) {
@@ -1812,19 +1812,16 @@ static int ieee80211_sta_active_ibss(str
 static void ieee80211_sta_expire(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct list_head *ptr, *n;
-	struct sta_info *sta;
+	struct sta_info *sta, *tmp;
 
 	spin_lock_bh(&local->sta_lock);
-	list_for_each_safe(ptr, n, &local->sta_list) {
-		sta = list_entry(ptr, struct sta_info, list);
+	list_for_each_entry_safe(sta, tmp, &local->sta_list, list)
 		if (time_after(jiffies, sta->last_rx +
 			       IEEE80211_IBSS_INACTIVITY_LIMIT)) {
 			printk(KERN_DEBUG "%s: expiring inactive STA " MAC_FMT
 			       "\n", dev->name, MAC_ARG(sta->addr));
 			sta_info_free(sta, 1);
 		}
-	}
 	spin_unlock_bh(&local->sta_lock);
 }
 
@@ -2179,7 +2176,6 @@ static int ieee80211_sta_find_ibss(struc
 	struct ieee80211_sta_bss *bss;
 	int found = 0;
 	u8 bssid[ETH_ALEN];
-	struct list_head *ptr;
 	int active_ibss;
 
 	if (ifsta->ssid_len == 0)
@@ -2191,8 +2187,7 @@ #ifdef CONFIG_D80211_IBSS_DEBUG
 	       dev->name, active_ibss);
 #endif /* CONFIG_D80211_IBSS_DEBUG */
 	spin_lock_bh(&local->sta_bss_lock);
-	list_for_each(ptr, &local->sta_bss_list) {
-		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
+	list_for_each_entry(bss, &local->sta_bss_list, list) {
 		if (ifsta->ssid_len != bss->ssid_len ||
 		    memcmp(ifsta->ssid, bss->ssid, bss->ssid_len) != 0
 		    || !(bss->capability & WLAN_CAPABILITY_IBSS))
@@ -2408,6 +2403,29 @@ static int ieee80211_active_scan(struct 
 }
 
 
+void ieee80211_scan_completed(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	union iwreq_data wrqu;
+
+	printk(KERN_DEBUG "%s: scan completed\n", dev->name);
+	local->sta_scanning = 0;
+	local->last_scan_completed = jiffies;
+
+	memset(&wrqu, 0, sizeof(wrqu));
+	wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
+
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+		if (!ifsta->bssid_set ||
+		    (!ifsta->state == IEEE80211_IBSS_JOINED &&
+		    !ieee80211_sta_active_ibss(dev)))
+			ieee80211_sta_find_ibss(dev, ifsta);
+	}
+}
+EXPORT_SYMBOL(ieee80211_scan_completed);
+
 static void ieee80211_sta_scan_work(void *ptr)
 {
 	struct net_device *dev = ptr;
@@ -2416,7 +2434,6 @@ static void ieee80211_sta_scan_work(void
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
-	union iwreq_data wrqu;
 	unsigned long next_delay = 0;
 
 	if (!local->sta_scanning)
@@ -2433,20 +2450,8 @@ static void ieee80211_sta_scan_work(void
 				       "operational channel after scan\n",
 				       dev->name);
 			}
-			printk(KERN_DEBUG "%s: scan completed\n", dev->name);
-			local->sta_scanning = 0;
-			local->last_scan_completed = jiffies;
-			memset(&wrqu, 0, sizeof(wrqu));
-			wireless_send_event(dev, SIOCGIWSCAN, &wrqu, NULL);
-			if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
-				struct ieee80211_sub_if_data *sdata =
-					IEEE80211_DEV_TO_SUB_IF(dev);
-				struct ieee80211_if_sta *ifsta = &sdata->u.sta;
-				if (!ifsta->bssid_set ||
-				    (ifsta->state == IEEE80211_IBSS_JOINED &&
-				     !ieee80211_sta_active_ibss(dev)))
-					ieee80211_sta_find_ibss(dev, ifsta);
-			}
+
+			ieee80211_scan_completed(dev);
 			return;
 		}
 		skip = !(local->enabled_modes & (1 << mode->mode));
@@ -2547,6 +2552,13 @@ int ieee80211_sta_req_scan(struct net_de
 
 	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
 
+	if (local->hw->hw_scan) {
+		int rc = local->hw->hw_scan(dev, ssid, ssid_len);
+		if (!rc)
+			local->sta_scanning = 1;
+		return rc;
+	}
+
 	ieee80211_sta_save_oper_chan(dev);
 
 	local->sta_scanning = 1;
@@ -2714,15 +2726,21 @@ ieee80211_sta_scan_result(struct net_dev
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
 						  buf);
 
-		p = buf;
-		p += sprintf(p, "supp_rates=");
-		for (i = 0; i < bss->supp_rates_len; i++)
-			p+= sprintf(p, "%02x", bss->supp_rates[i]);
-		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		/* dispaly all support rates in readable format */
+		p = current_ev + IW_EV_LCP_LEN;
+		iwe.cmd = SIOCGIWRATE;
+		/* Those two flags are ignored... */
+		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
+		for (i = 0; i < bss->supp_rates_len; i++) {
+			iwe.u.bitrate.value = ((bss->supp_rates[i] &
+							0x7f) * 500000);
+			p = iwe_stream_add_value(current_ev, p,
+					end_buf, &iwe, IW_EV_PARAM_LEN);
+		}
+		/* Check if we added any rate */
+		if((p - current_ev) > IW_EV_LCP_LEN)
+			current_ev = p;
 
 		kfree(buf);
 		break;
@@ -2735,14 +2753,12 @@ ieee80211_sta_scan_result(struct net_dev
 int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct list_head *ptr;
 	char *current_ev = buf;
 	char *end_buf = buf + len;
 	struct ieee80211_sta_bss *bss;
 
 	spin_lock_bh(&local->sta_bss_lock);
-	list_for_each(ptr, &local->sta_bss_list) {
-		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
+	list_for_each_entry(bss, &local->sta_bss_list, list) {
 		if (buf + len - current_ev <= IW_EV_ADDR_LEN) {
 			spin_unlock_bh(&local->sta_bss_lock);
 			return -E2BIG;
@@ -2784,7 +2800,6 @@ struct sta_info * ieee80211_ibss_add_sta
 					 u8 *addr)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct list_head *ptr;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata = NULL;
 	struct net_device *sta_dev = NULL;
@@ -2800,14 +2815,12 @@ struct sta_info * ieee80211_ibss_add_sta
 	}
 
 	spin_lock_bh(&local->sub_if_lock);
-	list_for_each(ptr, &local->sub_if_list) {
-		sdata = list_entry(ptr, struct ieee80211_sub_if_data, list);
+	list_for_each_entry(sdata, &local->sub_if_list, list)
 		if (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		    memcmp(bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
 			sta_dev = sdata->dev;
 			break;
 		}
-	}
 	spin_unlock_bh(&local->sub_if_lock);
 
 	if (!sta_dev)
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 622b234..a326c4a 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -197,6 +197,12 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	       local->mdev->name, MAC_ARG(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
+	if (sta->key) {
+		ieee80211_key_sysfs_remove(sta->key);
+		ieee80211_key_free(sta->key);
+		sta->key = NULL;
+	}
+
 	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
 	ieee80211_sta_sysfs_remove(sta);
 
@@ -244,8 +250,6 @@ void sta_info_free(struct sta_info *sta,
 				kfree(key);
 			}
 		}
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
 	} else if (sta->key_idx_compression != HW_KEY_IDX_INVALID) {
 		struct ieee80211_key_conf conf;
 		memset(&conf, 0, sizeof(conf));
@@ -333,8 +337,7 @@ static void sta_info_cleanup(unsigned lo
 static void sta_info_proc_add_task(void *data)
 {
 	struct ieee80211_local *local = data;
-	struct list_head *ptr;
-	struct sta_info *sta;
+	struct sta_info *sta, *tmp;
 
 	while (1) {
 		spin_lock_bh(&local->sta_lock);
@@ -351,14 +354,14 @@ static void sta_info_proc_add_task(void 
 	}
 
 	while (1) {
+		sta = NULL;
 		spin_lock_bh(&local->sta_lock);
-		list_for_each(ptr, &local->sta_list) {
-			sta = list_entry(ptr, struct sta_info, list);
-			if (!sta->sysfs_registered) {
+		list_for_each_entry(tmp, &local->sta_list, list) {
+			if (!tmp->sysfs_registered) {
+				sta = tmp;
 				__sta_info_get(sta);
 				break;
 			}
-			sta = NULL;
 		}
 		spin_unlock_bh(&local->sta_lock);
 
@@ -441,14 +444,11 @@ void sta_info_remove_aid_ptr(struct sta_
  */
 void sta_info_flush(struct ieee80211_local *local, struct net_device *dev)
 {
-        struct list_head *ptr, *n;
+	struct sta_info *sta, *tmp;
 
 	spin_lock_bh(&local->sta_lock);
-
-	list_for_each_safe(ptr, n, &local->sta_list) {
-		struct sta_info *sta = list_entry(ptr, struct sta_info, list);
+	list_for_each_entry_safe(sta, tmp, &local->sta_list, list)
 		if (!dev || dev == sta->dev)
 			sta_info_free(sta, 1);
-	}
 	spin_unlock_bh(&local->sta_lock);
 }
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index c3e4728..22c2e53 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -120,10 +120,10 @@ void ieee80211_wep_encrypt_data(struct c
 				size_t klen, u8 *data, size_t data_len)
 {
 	struct scatterlist sg;
-	u32 *icv;
+	__le32 *icv;
 
-	icv = (u32 *)(data + data_len);
-	*icv = ~crc32_le(~0, data, data_len);
+	icv = (__le32 *)(data + data_len);
+	*icv = cpu_to_le32(~crc32_le(~0, data, data_len));
 
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
@@ -187,7 +187,7 @@ int ieee80211_wep_decrypt_data(struct cr
 			       size_t klen, u8 *data, size_t data_len)
 {
 	struct scatterlist sg;
-	u32 crc;
+	__le32 crc;
 
 	crypto_cipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
@@ -195,7 +195,7 @@ int ieee80211_wep_decrypt_data(struct cr
 	sg.length = data_len + WEP_ICV_LEN;
 	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
 
-	crc = ~crc32_le(~0, data, data_len);
+	crc = cpu_to_le32(~crc32_le(~0, data, data_len));
 	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) != 0)
 		/* ICV mismatch */
 		return -1;
-- 
John W. Linville
linville@tuxdriver.com
