From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] d80211: ieee80211_hw handlers should be allowed to sleep
Date: Sat, 7 Oct 2006 11:23:15 +0200
Message-ID: <200610071123.15561.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Kiszka <jan.kiszka@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:48236 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750699AbWJGJYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Oct 2006 05:24:12 -0400
Received: by ug-out-1314.google.com with SMTP id o38so414942ugd
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2006 02:24:10 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the ieee80211_if_sta timer structure
into a workqueue. This will allow the config(), reset_tsf()
and config_interface() handlers in the ieee80211_hw
structure to sleep. This is especially required for USB
drivers that have to sleep for all register access.

Signed-off-by Jan Kiszka <jan.kiszka@web.de>
Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

Note that this patch is created against the dscape git tree,
this patch will likley not apply cleanly against the wireless-dev git tree.

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 86062c9..aad1a34 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2075,15 +2075,15 @@ void ieee80211_if_shutdown(struct net_de
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
 		sdata->u.sta.state = IEEE80211_DISABLED;
-		del_timer_sync(&sdata->u.sta.timer);
+		cancel_delayed_work(&sdata->u.sta.work);
 		if (local->scan_work.data == sdata->dev) {
 			local->sta_scanning = 0;
 			cancel_delayed_work(&local->scan_work);
-			flush_scheduled_work();
 			/* see comment in ieee80211_unregister_hw to
 			 * understand why this works */
 			local->scan_work.data = NULL;
 		}
+		flush_scheduled_work();
 		break;
 	}
 }
@@ -4603,8 +4603,8 @@ void ieee80211_unregister_hw(struct net_
 		flush_scheduled_work();
 		/* The scan_work is guaranteed not to be called at this
 		 * point. It is not scheduled and not running now. It can be
-		 * scheduled again only by some sta_timer (all of them are
-		 * stopped by now) or under rtnl lock. */
+		 * scheduled again only by sta_work (stopped by now) or under
+		 * rtnl lock. */
 	}
 
 	ieee80211_rx_bss_list_deinit(dev);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 89666ec..5b48ce2 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -240,7 +240,7 @@ struct ieee80211_if_sta {
 		IEEE80211_ASSOCIATE, IEEE80211_ASSOCIATED,
 		IEEE80211_IBSS_SEARCH, IEEE80211_IBSS_JOINED
 	} state;
-	struct timer_list timer;
+	struct work_struct work;
 	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	size_t ssid_len;
@@ -621,7 +621,7 @@ int ieee80211_set_compression(struct iee
 			      struct net_device *dev, struct sta_info *sta);
 int ieee80211_init_client(struct net_device *dev);
 /* ieee80211_sta.c */
-void ieee80211_sta_timer(unsigned long ptr);
+void ieee80211_sta_work(void *ptr);
 void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 			   struct ieee80211_rx_status *rx_status);
 int ieee80211_sta_set_ssid(struct net_device *dev, char *ssid, size_t len);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 9a187af..4dd480f 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -194,9 +194,7 @@ void ieee80211_if_set_type(struct net_de
 		struct ieee80211_if_sta *ifsta;
 
 		ifsta = &sdata->u.sta;
-		init_timer(&ifsta->timer);
-		ifsta->timer.data = (unsigned long) dev;
-		ifsta->timer.function = ieee80211_sta_timer;
+		INIT_WORK(&ifsta->work, ieee80211_sta_work, dev);
 
 		ifsta->capab = WLAN_CAPABILITY_ESS;
 		ifsta->auth_algs = IEEE80211_AUTH_ALG_OPEN |
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 480e9c9..bda4f75 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -457,7 +457,7 @@ static void ieee80211_authenticate(struc
 
 	ieee80211_send_auth(dev, ifsta, 1, NULL, 0, 0);
 
-	mod_timer(&ifsta->timer, jiffies + IEEE80211_AUTH_TIMEOUT);
+	schedule_delayed_work(&ifsta->work, IEEE80211_AUTH_TIMEOUT);
 }
 
 
@@ -677,7 +677,7 @@ static void ieee80211_associate(struct n
 
 	ieee80211_send_assoc(dev, ifsta);
 
-	mod_timer(&ifsta->timer, jiffies + IEEE80211_ASSOC_TIMEOUT);
+	schedule_delayed_work(&ifsta->work, IEEE80211_ASSOC_TIMEOUT);
 }
 
 
@@ -735,11 +735,11 @@ static void ieee80211_associated(struct 
 		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
 		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 		wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
-		mod_timer(&ifsta->timer,
-			  jiffies + IEEE80211_MONITORING_INTERVAL + 30 * HZ);
+		schedule_delayed_work(&ifsta->work,
+				      IEEE80211_MONITORING_INTERVAL + 30 * HZ);
 	} else {
-		mod_timer(&ifsta->timer,
-			  jiffies + IEEE80211_MONITORING_INTERVAL);
+		schedule_delayed_work(&ifsta->work,
+				      IEEE80211_MONITORING_INTERVAL);
 	}
 }
 
@@ -1019,8 +1019,8 @@ static void ieee80211_rx_mgmt_deauth(str
 	    ifsta->state == IEEE80211_ASSOCIATE ||
 	    ifsta->state == IEEE80211_ASSOCIATED) {
 		ifsta->state = IEEE80211_AUTHENTICATE;
-		mod_timer(&ifsta->timer,
-			  jiffies + IEEE80211_RETRY_AUTH_INTERVAL);
+		schedule_delayed_work(&ifsta->work,
+				      IEEE80211_RETRY_AUTH_INTERVAL);
 	}
 
 	ieee80211_set_associated(dev, ifsta, 0);
@@ -1062,8 +1062,8 @@ static void ieee80211_rx_mgmt_disassoc(s
 
 	if (ifsta->state == IEEE80211_ASSOCIATED) {
 		ifsta->state = IEEE80211_ASSOCIATE;
-		mod_timer(&ifsta->timer,
-			  jiffies + IEEE80211_RETRY_AUTH_INTERVAL);
+		schedule_delayed_work(&ifsta->work,
+				      IEEE80211_RETRY_AUTH_INTERVAL);
 	}
 
 	ieee80211_set_associated(dev, ifsta, 0);
@@ -1829,7 +1829,7 @@ static void ieee80211_sta_expire(struct 
 static void ieee80211_sta_merge_ibss(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta)
 {
-	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
+	schedule_delayed_work(&ifsta->work, IEEE80211_IBSS_MERGE_INTERVAL);
 
 	ieee80211_sta_expire(dev);
 	if (ieee80211_sta_active_ibss(dev))
@@ -1841,20 +1841,19 @@ static void ieee80211_sta_merge_ibss(str
 }
 
 
-void ieee80211_sta_timer(unsigned long ptr)
+void ieee80211_sta_work(void *ptr)
 {
-	struct net_device *dev;
+	struct net_device *dev = ptr;
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
 
-	dev = (struct net_device *) ptr;
 	if (!netif_running(dev))
 		return;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS) {
-		printk(KERN_DEBUG "%s: ieee80211_sta_timer: non-STA interface "
+		printk(KERN_DEBUG "%s: ieee80211_sta_work: non-STA interface "
 		       "(type=%d)\n", dev->name, sdata->type);
 		return;
 	}
@@ -1879,7 +1878,7 @@ void ieee80211_sta_timer(unsigned long p
 		ieee80211_sta_merge_ibss(dev, ifsta);
 		break;
 	default:
-		printk(KERN_DEBUG "ieee80211_sta_timer: Unknown state %d\n",
+		printk(KERN_DEBUG "ieee80211_sta_work: Unknown state %d\n",
 		       ifsta->state);
 		break;
 	}
@@ -2107,7 +2106,7 @@ static int ieee80211_sta_join_ibss(struc
 	}
 
 	ifsta->state = IEEE80211_IBSS_JOINED;
-	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
+	schedule_delayed_work(&ifsta->work, IEEE80211_IBSS_MERGE_INTERVAL);
 
 	ieee80211_rx_bss_put(dev, bss);
 
@@ -2224,8 +2223,8 @@ #endif /* CONFIG_D80211_IBSS_DEBUG */
 	/* Selected IBSS not found in current scan results - try to scan */
 	if (ifsta->state == IEEE80211_IBSS_JOINED &&
 	    !ieee80211_sta_active_ibss(dev)) {
-		mod_timer(&ifsta->timer,
-			  jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
+		schedule_delayed_work(&ifsta->work,
+				      IEEE80211_IBSS_MERGE_INTERVAL);
 	} else if (time_after(jiffies, local->last_scan_completed +
 			      IEEE80211_SCAN_INTERVAL)) {
 		printk(KERN_DEBUG "%s: Trigger new scan to find an IBSS to "
@@ -2253,7 +2252,7 @@ #endif /* CONFIG_D80211_IBSS_DEBUG */
 		}
 
 		ifsta->state = IEEE80211_IBSS_SEARCH;
-		mod_timer(&ifsta->timer, jiffies + interval);
+		schedule_delayed_work(&ifsta->work, interval);
 		return 0;
 	}
 
