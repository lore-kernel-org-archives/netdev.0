From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/14] d80211: add hardware scan callback
Date: Wed, 27 Sep 2006 17:50:46 +0200 (CEST)
Message-ID: <20060927155046.CE57B483B5@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:48780 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964965AbWI0Ptm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:42 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hong Liu <hong.liu@intel.com>

Add hardware scan callback to support cards like ipw3945 which
implements the scan command in firmware.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h       |    6 ++++++
 net/d80211/ieee80211_sta.c |   47 ++++++++++++++++++++++++++++++--------------
 2 files changed, 38 insertions(+), 15 deletions(-)

5b1756ecb9786baeb5127ca60cf0b3431e1d0e84
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 42fdbf7..36c58b4 100644
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
@@ -863,6 +867,8 @@ struct dev_mc_list *ieee80211_get_mc_lis
 struct ieee80211_conf *
 ieee80211_get_hw_conf(struct net_device *dev);
 
+/* called by driver to notify scan status completed */
+void ieee80211_scan_completed(struct net_device *dev);
 
 /* Return a pointer to the low-level private data area for the given device. */
 void * ieee80211_dev_hw_data(struct net_device *dev);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 557ba17..1f60a22 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2410,6 +2410,29 @@ static int ieee80211_active_scan(struct 
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
@@ -2418,7 +2441,6 @@ static void ieee80211_sta_scan_work(void
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int skip;
-	union iwreq_data wrqu;
 	unsigned long next_delay = 0;
 
 	if (!local->sta_scanning)
@@ -2435,20 +2457,8 @@ static void ieee80211_sta_scan_work(void
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
@@ -2549,6 +2559,13 @@ int ieee80211_sta_req_scan(struct net_de
 
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
-- 
1.3.0

