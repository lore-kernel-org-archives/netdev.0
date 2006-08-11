From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] d80211 LED handling
Date: Fri, 11 Aug 2006 09:55:53 +0200
Message-ID: <44DC3809.10705@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040007080201080901090603"
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:62139 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750763AbWHKH4K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 03:56:10 -0400
To: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040007080201080901090603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached (sorry, can't seem to figure out how to convince thunderbird to 
not mangle things under windows) is a patch to make d80211 have some LED 
triggers.

However, I'm not sure where I should call the _init and _exit functions 
and if I really should be using the local struct. It seems I shouldn't 
be and should be using the master interface directly or something.

Anyway, food for though and comments.

johannes

--------------040007080201080901090603
Content-Type: text/plain;
 name="d80211-led.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="d80211-led.patch"

--- wireless-dev.orig/include/net/d80211.h	2006-08-10 20:02:20.159652863 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-10 20:02:22.439652863 +0200
@@ -884,16 +884,6 @@ enum {
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
--- wireless-dev.orig/net/d80211/Kconfig	2006-08-10 20:02:20.199652863 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-10 20:02:22.439652863 +0200
@@ -7,6 +7,13 @@ config D80211
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
 
+config D80211_LEDS
+	bool "Enable LED triggers"
+	select LEDS_TRIGGERS
+	---help---
+	This option enables a few LED triggers for different
+	packet receive/transmit events.
+
 config D80211_DEBUG
 	bool "Enable debugging output"
 	depends on D80211
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-10 20:02:20.279652863 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-10 20:02:22.449652863 +0200
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
--- wireless-dev.orig/net/d80211/ieee80211_dev.c	2006-08-10 20:02:20.309652863 +0200
+++ wireless-dev/net/d80211/ieee80211_dev.c	2006-08-10 21:54:44.300216256 +0200
@@ -13,6 +13,7 @@
 #include <linux/netdevice.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
+#include "ieee80211_led.h"
 
 struct ieee80211_dev_list {
 	struct list_head list;
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-10 20:02:20.399652863 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-10 20:03:22.939652863 +0200
@@ -460,7 +460,10 @@ struct ieee80211_local {
         u32 dot11TransmittedFrameCount;
         u32 dot11WEPUndecryptableCount;
 
-        int tx_led_counter;
+#ifdef CONFIG_D80211_LEDS
+	int tx_led_counter, rx_led_counter;
+	struct led_trigger *tx_led, *rx_led;
+#endif
 
 	u32 channel_use;
 	u32 channel_use_raw;
--- wireless-dev.orig/net/d80211/ieee80211_led.c	2006-08-10 20:02:20.429652863 +0200
+++ wireless-dev/net/d80211/ieee80211_led.c	2006-08-10 20:25:19.659652863 +0200
@@ -1,32 +1,70 @@
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
 
-	if (state == 2) {
-		leds_wlan_set(0, 0, (++count) & 1);
-	}
-#endif
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
 }
 
-void ieee80211_tx_led(int state, struct net_device *dev) {
-#ifdef CONFIG_OAP_LEDS_WLAN
-        leds_wlan_set(0, 1, state);
-#endif
+void ieee80211_led_init(struct ieee80211_local *local)
+{
+	char *name;
+	local->rx_led = kzalloc(sizeof(struct led_trigger) + IFNAMSIZ + 2, GFP_KERNEL);
+	if (!local->rx_led)
+		return;
+	name = (char*) local->rx_led+1;
+	snprintf(name, IFNAMSIZ + 2, "%srx", local->mdev->name);
+	if (led_trigger_register(local->rx_led)) {
+		kfree(local->rx_led);
+		local->rx_led = NULL;
+	}
+
+	local->tx_led = kzalloc(sizeof(struct led_trigger) + IFNAMSIZ + 2, GFP_KERNEL);
+	if (!local->tx_led)
+		return;
+	name = (char*) local->tx_led+1;
+	snprintf(name, IFNAMSIZ + 2, "%stx", local->mdev->name);
+	if (led_trigger_register(local->tx_led)) {
+		kfree(local->tx_led);
+		local->tx_led = NULL;
+	}
 }
 
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
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ wireless-dev/net/d80211/ieee80211_led.h	2006-08-10 20:24:54.849652863 +0200
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

--------------040007080201080901090603--
