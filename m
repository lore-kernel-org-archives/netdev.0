From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 01/18] d80211:  LED triggers
Date: Mon, 21 Aug 2006 09:41:08 +0200
Message-ID: <20060821075158.728615077@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2497 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030344AbWHUIC2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:28 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-led.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes d80211 export LED triggers for rx/tx and introduces
functions to allow device drivers to query the trigger names for setting
default triggers. It also cleans up the Makefile LED related stuff.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-08-20 14:56:10.708192788 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-20 16:27:03.988192788 +0200
@@ -695,6 +695,36 @@ struct net_device *ieee80211_alloc_hw(si
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
@@ -884,16 +914,6 @@ enum {
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
--- wireless-dev.orig/net/d80211/Kconfig	2006-08-20 14:56:10.728192788 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-20 16:27:27.578192788 +0200
@@ -7,6 +7,14 @@ config D80211
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
 
+config D80211_LEDS
+	bool "Enable LED triggers"
+	depends on D80211
+	select LEDS_TRIGGERS
+	---help---
+	This option enables a few LED triggers for different
+	packet receive/transmit events.
+
 config D80211_DEBUG
 	bool "Enable debugging output"
 	depends on D80211
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 14:56:10.768192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 16:27:08.548192788 +0200
@@ -31,7 +31,7 @@
 #include "tkip.h"
 #include "wme.h"
 #include "aes_ccm.h"
-
+#include "ieee80211_led.h"
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
@@ -1181,11 +1181,7 @@ static int __ieee80211_tx(struct ieee802
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
@@ -1210,11 +1206,7 @@ static int __ieee80211_tx(struct ieee802
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
@@ -2998,10 +2990,8 @@ ieee80211_rx_h_defragment(struct ieee802
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
 
@@ -4104,11 +4094,8 @@ void ieee80211_tx_status(struct net_devi
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
@@ -4500,6 +4487,8 @@ int ieee80211_register_hw(struct net_dev
 	local->reg_state = IEEE80211_DEV_REGISTERED;
 	rtnl_unlock();
 
+	ieee80211_led_init(local);
+
 	return 0;
 
 fail_rate_attrs:
@@ -4603,6 +4592,7 @@ void ieee80211_unregister_hw(struct net_
 	skb_queue_purge(&local->skb_queue_unreliable);
 
 	ieee80211_dev_free_index(local);
+	ieee80211_led_exit(local);
 }
 
 void ieee80211_free_hw(struct net_device *dev)
--- wireless-dev.orig/net/d80211/ieee80211_dev.c	2006-08-20 14:56:10.818192788 +0200
+++ wireless-dev/net/d80211/ieee80211_dev.c	2006-08-20 14:56:15.978192788 +0200
@@ -13,6 +13,7 @@
 #include <linux/netdevice.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
+#include "ieee80211_led.h"
 
 struct ieee80211_dev_list {
 	struct list_head list;
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-20 14:56:10.838192788 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-20 16:27:06.458192788 +0200
@@ -460,7 +460,11 @@ struct ieee80211_local {
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
--- wireless-dev.orig/net/d80211/ieee80211_led.c	2006-08-20 14:56:10.878192788 +0200
+++ wireless-dev/net/d80211/ieee80211_led.c	2006-08-20 14:56:15.978192788 +0200
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
-
-#ifdef CONFIG_OAP_LEDS_WLAN
-extern void leds_wlan_set(int unit, int tx, int state);
-#endif
-
-void ieee80211_rx_led(int state, struct net_device *dev) {
-#ifdef CONFIG_OAP_LEDS_WLAN
-	static unsigned int count = 0;
+/* just for IFNAMSIZ */
+#include <linux/if.h>
+#include "ieee80211_led.h"
+
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
+
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
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_led.h	2006-08-20 14:56:15.978192788 +0200
@@ -0,0 +1,30 @@
+/*
+ * Copyright 2006, Johannes Berg <johannes@sipsolutions.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
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
--- wireless-dev.orig/net/d80211/Makefile	2006-08-20 14:56:10.958192788 +0200
+++ wireless-dev/net/d80211/Makefile	2006-08-20 16:27:06.898192788 +0200
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

--
