From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Tue, 11 Jul 2006 00:54:33 +0200
Message-ID: <200607110054.36520.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:64206
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965283AbWGJWzt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 18:55:49 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev.
Note that this is the second try to submit this patch.
The first try contained a little bug. I'm sorry for that.
If you already applied the first one, I can provide an incremental patch.

Note2 that this patch depends on the
[PATCH] cancel_rearming_delayed_work infinite loop fix
I just sent out to the lists and akpm.

--

This patch makes sleeping in the hw->config callback possible
by removing the only atomic caller. The atomic caller was
a timer and is replaced by a workqueue.

In general, allowing to sleep in the config callback is a
good thing. bcm43xx must be able to sleep here, as it is
required to lock a mutex.
But there are other good reasons to sleep here. We might
want to sleep for a grace period on channel switch, for example.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev-dscapeports/net/d80211/ieee80211.c
===================================================================
--- wireless-dev-dscapeports.orig/net/d80211/ieee80211.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/net/d80211/ieee80211.c	2006-07-11 00:53:44.000000000 +0200
@@ -4327,8 +4327,8 @@
 		del_timer_sync(&local->rate_limit_timer);
 	if (local->stat_time)
 		del_timer_sync(&local->stat_timer);
-	if (local->scan_timer.data)
-		del_timer_sync(&local->scan_timer);
+	if (local->scan_work.data)
+		cancel_rearming_delayed_work(&local->scan_work);
 	ieee80211_rx_bss_list_deinit(dev);
 
 	rtnl_lock();
Index: wireless-dev-dscapeports/net/d80211/ieee80211_i.h
===================================================================
--- wireless-dev-dscapeports.orig/net/d80211/ieee80211_i.h	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/net/d80211/ieee80211_i.h	2006-07-09 19:52:07.000000000 +0200
@@ -17,6 +17,7 @@
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/workqueue.h>
 #include "ieee80211_key.h"
 #include "sta_info.h"
 
@@ -407,7 +408,7 @@
 	int scan_channel_idx;
 	enum { SCAN_SET_CHANNEL, SCAN_SEND_PROBE } scan_state;
 	unsigned long last_scan_completed;
-	struct timer_list scan_timer;
+	struct work_struct scan_work;
 	int scan_oper_channel;
 	int scan_oper_channel_val;
 	int scan_oper_power_level;
Index: wireless-dev-dscapeports/net/d80211/ieee80211_iface.c
===================================================================
--- wireless-dev-dscapeports.orig/net/d80211/ieee80211_iface.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/net/d80211/ieee80211_iface.c	2006-07-09 20:03:32.000000000 +0200
@@ -271,8 +271,8 @@
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
 		del_timer_sync(&sdata->u.sta.timer);
-		if (local->scan_timer.data == (unsigned long) sdata->dev)
-			del_timer_sync(&local->scan_timer);
+		if (local->scan_work.data == sdata->dev)
+			cancel_rearming_delayed_work(&local->scan_work);
 		kfree(sdata->u.sta.extra_ie);
 		sdata->u.sta.extra_ie = NULL;
 		kfree(sdata->u.sta.assocreq_ies);
Index: wireless-dev-dscapeports/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev-dscapeports.orig/net/d80211/ieee80211_sta.c	2006-06-17 21:26:10.000000000 +0200
+++ wireless-dev-dscapeports/net/d80211/ieee80211_sta.c	2006-07-09 20:21:44.000000000 +0200
@@ -2422,15 +2422,16 @@
 }
 
 
-static void ieee80211_sta_scan_timer(unsigned long ptr)
+static void ieee80211_sta_scan_work(void *_data)
 {
-	struct net_device *dev = (struct net_device *) ptr;
+	struct net_device *dev = _data;
 	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
 	union iwreq_data wrqu;
+	unsigned long next_delay = 0;
 
 	if (!local->sta_scanning)
 		return;
@@ -2498,29 +2499,27 @@
 			local->scan_channel_idx = 0;
 		}
 
-		if (skip) {
-			local->scan_timer.expires = jiffies;
+		if (skip)
 			break;
-		}
 
-		local->scan_timer.expires = jiffies + IEEE80211_PROBE_DELAY;
+		next_delay = IEEE80211_PROBE_DELAY;
 		local->scan_state = SCAN_SEND_PROBE;
 		break;
 	case SCAN_SEND_PROBE:
 		if (ieee80211_active_scan(local)) {
 			ieee80211_send_probe_req(dev, NULL, local->scan_ssid,
 						 local->scan_ssid_len);
-			local->scan_timer.expires =
-				jiffies + IEEE80211_CHANNEL_TIME;
-		} else {
-			local->scan_timer.expires =
-				jiffies + IEEE80211_PASSIVE_CHANNEL_TIME;
-		}
+			next_delay = IEEE80211_CHANNEL_TIME;
+		} else
+			next_delay = IEEE80211_PASSIVE_CHANNEL_TIME;
 		local->scan_state = SCAN_SET_CHANNEL;
 		break;
 	}
 
-	add_timer(&local->scan_timer);
+	if (next_delay)
+		schedule_delayed_work(&local->scan_work, next_delay);
+	else
+		schedule_work(&local->scan_work);
 }
 
 
@@ -2569,11 +2568,8 @@
 	local->scan_state = SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx = 0;
 	local->scan_channel_idx = 0;
-	init_timer(&local->scan_timer);
-	local->scan_timer.data = (unsigned long) dev;
-	local->scan_timer.function = ieee80211_sta_scan_timer;
-	local->scan_timer.expires = jiffies + 1;
-	add_timer(&local->scan_timer);
+	INIT_WORK(&local->scan_work, ieee80211_sta_scan_work, dev);
+	schedule_work(&local->scan_work);
 
 	return 0;
 }

-- 
Greetings Michael.
