From: Hong Liu <hong.liu@intel.com>
Subject: [PATCH 2/2]d80211: add hardware scan callback
Date: Fri, 25 Aug 2006 16:32:13 +0800
Message-ID: <1156494733.21483.14.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-lx71JlL9B3pW7TmW7fXg"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:65093 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932222AbWHYIgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 04:36:06 -0400
To: jbenc@suse.cz
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lx71JlL9B3pW7TmW7fXg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Add hardware scan callback to support cards like ipw3945 which
implements the scan command in firmware.

Thanks,
Hong

--=-lx71JlL9B3pW7TmW7fXg
Content-Disposition: attachment; filename=d80211-add-hw-scan-git.patch
Content-Type: text/x-patch; name=d80211-add-hw-scan-git.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/include/net/d80211.h b/include/net/d80211.h
index ba5cb4c..b369d12 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -595,6 +595,10 @@ struct ieee80211_hw {
         int (*passive_scan)(struct net_device *dev, int state,
                             struct ieee80211_scan_conf *conf);
 
+	/* Ask the hardware to service the scan request, no need to start
+	 * the scan state machine in stack. */
+	int (*hw_scan)(struct net_device *dev, u8 *ssid, size_t len);
+
         /* return low-level statistics */
 	int (*get_stats)(struct net_device *dev,
 			 struct ieee80211_low_level_stats *stats);
@@ -893,6 +897,8 @@ void ieee80211_tx_led(int state, struct 
  */
 void ieee80211_rx_led(int state, struct net_device *dev);
 
+/* set station scan completed */
+void ieee80211_set_scan_completed(struct net_device *dev);
 
 /* IEEE 802.11 defines */
 
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 60eca90..dc920c1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4831,6 +4831,7 @@ EXPORT_SYMBOL(sta_info_get);
 EXPORT_SYMBOL(sta_info_put);
 EXPORT_SYMBOL(ieee80211_radar_status);
 EXPORT_SYMBOL(ieee80211_get_mc_list_item);
+EXPORT_SYMBOL(ieee80211_set_scan_completed);
 
 module_init(ieee80211_init);
 module_exit(ieee80211_exit);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2144b34..4bb2234 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2426,6 +2426,28 @@ static int ieee80211_active_scan(struct 
 }
 
 
+void ieee80211_set_scan_completed(struct net_device *dev)
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
+
 static void ieee80211_sta_scan_work(void *ptr)
 {
 	struct net_device *dev = ptr;
@@ -2434,7 +2456,6 @@ static void ieee80211_sta_scan_work(void
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
-	union iwreq_data wrqu;
 	unsigned long next_delay = 0;
 
 	if (!local->sta_scanning)
@@ -2451,20 +2472,8 @@ static void ieee80211_sta_scan_work(void
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
+			ieee80211_set_scan_completed(dev);
 			return;
 		}
 		skip = !(local->enabled_modes & (1 << mode->mode));
@@ -2565,9 +2574,12 @@ int ieee80211_sta_req_scan(struct net_de
 
 	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
 
+	local->sta_scanning = 1;
+	if (local->hw->hw_scan)
+		return local->hw->hw_scan(dev, ssid, ssid_len);
+
 	ieee80211_sta_save_oper_chan(dev);
 
-	local->sta_scanning = 1;
 	/* TODO: stop TX queue? */
 
 	if (ssid) {

--=-lx71JlL9B3pW7TmW7fXg--
