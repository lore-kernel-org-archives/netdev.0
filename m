From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 11/14] d80211: use list_for_each_entry{,_safe}
Date: Wed, 27 Sep 2006 17:50:56 +0200 (CEST)
Message-ID: <20060927155056.296C83BA255@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50572 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964976AbWI0Ptv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:51 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch changes (hopefully!) all occurrences in d80211 of
list_for_each to list_for_each_entry (and _safe variants where they were
used before).

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   33 ++++++++++++---------------------
 net/d80211/ieee80211_dev.c   |    6 ++----
 net/d80211/ieee80211_ioctl.c |   32 +++++++++++---------------------
 net/d80211/ieee80211_sta.c   |   24 ++++++------------------
 net/d80211/sta_info.c        |   13 ++++---------
 5 files changed, 35 insertions(+), 73 deletions(-)

871e88d24ff80e9521da300fd5c80e521b869ac9
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 4fee86c..4d989e2 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
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
@@ -3829,16 +3826,15 @@ ieee80211_rx_h_if_stats(struct ieee80211
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
@@ -3846,14 +3842,11 @@ static void ieee80211_stat_refresh(unsig
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
@@ -4563,7 +4556,7 @@ EXPORT_SYMBOL(ieee80211_update_hw);
 void ieee80211_unregister_hw(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-        struct list_head *ptr, *n;
+	struct ieee80211_sub_if_data *sdata, *tmp;
 	int i;
 
         tasklet_disable(&local->tasklet);
@@ -4576,11 +4569,9 @@ void ieee80211_unregister_hw(struct net_
 
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
diff --git a/net/d80211/ieee80211_dev.c b/net/d80211/ieee80211_dev.c
index 6c6ca91..69d8ada 100644
--- a/net/d80211/ieee80211_dev.c
+++ b/net/d80211/ieee80211_dev.c
@@ -38,7 +38,6 @@ static struct ieee80211_dev_list *__ieee
 
 int ieee80211_dev_alloc_index(struct ieee80211_local *local)
 {
-	struct list_head *i;
 	struct ieee80211_dev_list *dev_item, *new;
 	int index = 0;
 
@@ -47,14 +46,13 @@ int ieee80211_dev_alloc_index(struct iee
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
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index b47a014..445adad 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
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
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 92cbad7..2e82405 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1791,13 +1791,11 @@ void ieee80211_sta_rx_scan(struct net_de
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
@@ -1814,19 +1812,16 @@ static int ieee80211_sta_active_ibss(str
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
 
@@ -2181,7 +2176,6 @@ static int ieee80211_sta_find_ibss(struc
 	struct ieee80211_sta_bss *bss;
 	int found = 0;
 	u8 bssid[ETH_ALEN];
-	struct list_head *ptr;
 	int active_ibss;
 
 	if (ifsta->ssid_len == 0)
@@ -2193,8 +2187,7 @@ #ifdef CONFIG_D80211_IBSS_DEBUG
 	       dev->name, active_ibss);
 #endif /* CONFIG_D80211_IBSS_DEBUG */
 	spin_lock_bh(&local->sta_bss_lock);
-	list_for_each(ptr, &local->sta_bss_list) {
-		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
+	list_for_each_entry(bss, &local->sta_bss_list, list) {
 		if (ifsta->ssid_len != bss->ssid_len ||
 		    memcmp(ifsta->ssid, bss->ssid, bss->ssid_len) != 0
 		    || !(bss->capability & WLAN_CAPABILITY_IBSS))
@@ -2760,14 +2753,12 @@ ieee80211_sta_scan_result(struct net_dev
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
@@ -2809,7 +2800,6 @@ struct sta_info * ieee80211_ibss_add_sta
 					 u8 *addr)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct list_head *ptr;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata = NULL;
 	struct net_device *sta_dev = NULL;
@@ -2825,14 +2815,12 @@ struct sta_info * ieee80211_ibss_add_sta
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
index 5edbd0c..9397c48 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -337,8 +337,7 @@ static void sta_info_cleanup(unsigned lo
 static void sta_info_proc_add_task(void *data)
 {
 	struct ieee80211_local *local = data;
-	struct list_head *ptr;
-	struct sta_info *sta;
+	struct sta_info *sta, *tmp;
 
 	while (1) {
 		spin_lock_bh(&local->sta_lock);
@@ -356,8 +355,7 @@ static void sta_info_proc_add_task(void 
 
 	while (1) {
 		spin_lock_bh(&local->sta_lock);
-		list_for_each(ptr, &local->sta_list) {
-			sta = list_entry(ptr, struct sta_info, list);
+		list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
 			if (!sta->sysfs_registered) {
 				__sta_info_get(sta);
 				break;
@@ -445,14 +443,11 @@ void sta_info_remove_aid_ptr(struct sta_
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
-- 
1.3.0

