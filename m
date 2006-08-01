From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/5] d80211: make sleeping in hw->config possible
Date: Tue,  1 Aug 2006 21:16:55 +0200 (CEST)
Message-ID: <20060801191655.DBA07483A5@silver.suse.cz>
References: <20060801211530.150852000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49112 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751820AbWHATQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:16:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801211530.150852000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes sleeping in the hw->config callback possible by removing
the only atomic caller. The atomic caller was a timer and is replaced by
a workqueue.

This is based on a patch from Michael Buesch <mb@bu3sch.de>.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   23 +++++++++++++++--------
 net/d80211/ieee80211_i.h     |    3 ++-
 net/d80211/ieee80211_iface.c |   10 ++++++++--
 net/d80211/ieee80211_sta.c   |   37 +++++++++++++++++--------------------
 4 files changed, 42 insertions(+), 31 deletions(-)

d0d2b7a8ddc378ddea499f1537f6aea83d96d003
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 4e80767..9f883a4 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4552,14 +4552,6 @@ void ieee80211_unregister_hw(struct net_
         tasklet_disable(&local->tasklet);
         /* TODO: skb_queue should be empty here, no need to do anything? */
 
-	if (local->rate_limit)
-		del_timer_sync(&local->rate_limit_timer);
-	if (local->stat_time)
-		del_timer_sync(&local->stat_timer);
-	if (local->scan_timer.data)
-		del_timer_sync(&local->scan_timer);
-	ieee80211_rx_bss_list_deinit(dev);
-
 	rtnl_lock();
 	local->reg_state = IEEE80211_DEV_UNREGISTERED;
 	if (local->apdev)
@@ -4572,6 +4564,21 @@ void ieee80211_unregister_hw(struct net_
 	}
 	rtnl_unlock();
 
+	if (local->rate_limit)
+		del_timer_sync(&local->rate_limit_timer);
+	if (local->stat_time)
+		del_timer_sync(&local->stat_timer);
+	if (local->scan_work.data) {
+		local->sta_scanning = 0;
+		cancel_delayed_work(&local->scan_work);
+		flush_scheduled_work();
+		/* The scan_work is guaranteed not to be called at this
+		 * point. It is not scheduled and not running now. It can be
+		 * scheduled again only by some sta_timer (all of them are
+		 * stopped by now) or under rtnl lock. */
+	}
+
+	ieee80211_rx_bss_list_deinit(dev);
 	ieee80211_clear_tx_pending(local);
 	sta_info_stop(local);
 	rate_control_remove_attrs(local, local->rate_ctrl_priv,
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 016a2b1..5a2c6e8 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -17,6 +17,7 @@ #include <linux/interrupt.h>
 #include <linux/list.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
+#include <linux/workqueue.h>
 #include "ieee80211_key.h"
 #include "sta_info.h"
 
@@ -425,7 +426,7 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int scan_channel_idx;
 	enum { SCAN_SET_CHANNEL, SCAN_SEND_PROBE } scan_state;
 	unsigned long last_scan_completed;
-	struct timer_list scan_timer;
+	struct work_struct scan_work;
 	int scan_oper_channel;
 	int scan_oper_channel_val;
 	int scan_oper_power_level;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index fa3d9e2..12b9d4f 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -287,8 +287,14 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
 		del_timer_sync(&sdata->u.sta.timer);
-		if (local->scan_timer.data == (unsigned long) sdata->dev)
-			del_timer_sync(&local->scan_timer);
+		if (local->scan_work.data == sdata->dev) {
+			local->sta_scanning = 0;
+			cancel_delayed_work(&local->scan_work);
+			flush_scheduled_work();
+			/* see comment in ieee80211_unregister_hw to
+			 * understand why this works */
+			local->scan_work.data = NULL;
+		}
 		kfree(sdata->u.sta.extra_ie);
 		sdata->u.sta.extra_ie = NULL;
 		kfree(sdata->u.sta.assocreq_ies);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index b0cfff1..22f9599 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2417,15 +2417,16 @@ static int ieee80211_active_scan(struct 
 }
 
 
-static void ieee80211_sta_scan_timer(unsigned long ptr)
+static void ieee80211_sta_scan_work(void *ptr)
 {
-	struct net_device *dev = (struct net_device *) ptr;
+	struct net_device *dev = ptr;
 	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
 	union iwreq_data wrqu;
+	unsigned long next_delay = 0;
 
 	if (!local->sta_scanning)
 		return;
@@ -2493,31 +2494,30 @@ #endif
 			local->scan_channel_idx = 0;
 		}
 
-		if (skip) {
-			local->scan_timer.expires = jiffies;
+		if (skip)
 			break;
-		}
 
-		local->scan_timer.expires =
-			jiffies + IEEE80211_PROBE_DELAY +
-			usecs_to_jiffies(local->hw->channel_change_time);
+		next_delay = IEEE80211_PROBE_DELAY +
+			     usecs_to_jiffies(local->hw->channel_change_time);
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
+	if (local->sta_scanning) {
+		if (next_delay)
+			schedule_delayed_work(&local->scan_work, next_delay);
+		else
+			schedule_work(&local->scan_work);
+	}
 }
 
 
@@ -2566,11 +2566,8 @@ int ieee80211_sta_req_scan(struct net_de
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
1.3.0

