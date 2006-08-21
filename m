From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 15/18] d80211:  surface IBSS debug
Date: Mon, 21 Aug 2006 09:41:22 +0200
Message-ID: <20060821075202.380638097@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50368 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030314AbWHUICD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:03 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-ibss-debug.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch surfaces the IBSS debug switch in Kconfig.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/Kconfig	2006-08-20 17:38:37.978192788 +0200
+++ wireless-dev/net/d80211/Kconfig	2006-08-20 17:39:14.728192788 +0200
@@ -53,3 +53,9 @@ config D80211_DEBUG_COUNTERS
 config HOSTAPD_WPA_TESTING
 	bool "Support for TKIP countermeasures testing"
 	depends on D80211_DEBUG
+
+config D80211_IBSS_DEBUG
+	bool "Support for IBSS testing"
+	depends on D80211_DEBUG
+	---help---
+	  Say Y here if you intend to debug the IBSS code.
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-08-20 17:38:01.488192788 +0200
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-08-20 17:38:27.758192788 +0200
@@ -31,8 +31,6 @@
 #include "rate_control.h"
 #include "hostapd_ioctl.h"
 
-/* #define IEEE80211_IBSS_DEBUG */
-
 #define IEEE80211_AUTH_TIMEOUT (HZ / 5)
 #define IEEE80211_AUTH_MAX_TRIES 3
 #define IEEE80211_ASSOC_TIMEOUT (HZ / 5)
@@ -1353,7 +1351,7 @@ static void ieee80211_rx_bss_info(struct
 
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS && beacon &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
 		u64 tsf;
 		if (local->hw->get_tsf)
@@ -1368,7 +1366,7 @@ static void ieee80211_rx_bss_info(struct
 			       tsf, timestamp, tsf - timestamp, jiffies);
 			last_tsf_debug = jiffies;
 		}
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	}
 
 	if (ieee802_11_parse_elems(mgmt->u.beacon.variable, len - baselen,
@@ -1648,12 +1646,12 @@ static void ieee80211_rx_mgmt_probe_req(
 	else
 		tx_last_beacon = 1;
 
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: RX ProbeReq SA=" MAC_FMT " DA=" MAC_FMT " BSSID="
 	       MAC_FMT " (tx_last_beacon=%d)\n",
 	       dev->name, MAC_ARG(mgmt->sa), MAC_ARG(mgmt->da),
 	       MAC_ARG(mgmt->bssid), tx_last_beacon);
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 
 	if (!tx_last_beacon)
 		return;
@@ -1687,10 +1685,10 @@ static void ieee80211_rx_mgmt_probe_req(
 
 	resp = (struct ieee80211_mgmt *) skb->data;
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: Sending ProbeResp to " MAC_FMT "\n",
 	       dev->name, MAC_ARG(resp->da));
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	ieee80211_sta_tx(dev, skb, 0, 1);
 }
 
@@ -2187,10 +2185,10 @@ static int ieee80211_sta_find_ibss(struc
 		return -EINVAL;
 
 	active_ibss = ieee80211_sta_active_ibss(dev);
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "%s: sta_find_ibss (active_ibss=%d)\n",
 	       dev->name, active_ibss);
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	spin_lock_bh(&local->sta_bss_lock);
 	list_for_each(ptr, &local->sta_bss_list) {
 		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
@@ -2198,10 +2196,10 @@ static int ieee80211_sta_find_ibss(struc
 		    memcmp(ifsta->ssid, bss->ssid, bss->ssid_len) != 0
 		    || !(bss->capability & WLAN_CAPABILITY_IBSS))
 			continue;
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 		printk(KERN_DEBUG "   bssid=" MAC_FMT " found\n",
 		       MAC_ARG(bss->bssid));
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 		memcpy(bssid, bss->bssid, ETH_ALEN);
 		found = 1;
 		if (active_ibss || memcmp(bssid, ifsta->bssid, ETH_ALEN) != 0)
@@ -2209,10 +2207,10 @@ static int ieee80211_sta_find_ibss(struc
 	}
 	spin_unlock_bh(&local->sta_bss_lock);
 
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "   sta_find_ibss: selected " MAC_FMT " current "
 	       MAC_FMT "\n", MAC_ARG(bssid), MAC_ARG(ifsta->bssid));
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 	if (found && memcmp(ifsta->bssid, bssid, ETH_ALEN) != 0 &&
 	    (bss = ieee80211_rx_bss_get(dev, bssid))) {
 		printk(KERN_DEBUG "%s: Selected IBSS BSSID " MAC_FMT
@@ -2220,9 +2218,9 @@ static int ieee80211_sta_find_ibss(struc
 		       dev->name, MAC_ARG(bssid));
 		return ieee80211_sta_join_ibss(dev, ifsta, bss);
 	}
-#ifdef IEEE80211_IBSS_DEBUG
+#ifdef CONFIG_D80211_IBSS_DEBUG
 	printk(KERN_DEBUG "   did not try to join ibss\n");
-#endif /* IEEE80211_IBSS_DEBUG */
+#endif /* CONFIG_D80211_IBSS_DEBUG */
 
 	/* Selected IBSS not found in current scan results - try to scan */
 	if (ifsta->state == IEEE80211_IBSS_JOINED &&

--
