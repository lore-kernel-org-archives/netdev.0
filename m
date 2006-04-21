From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/10] d80211: per-interface SSID
Date: Fri, 21 Apr 2006 22:53:25 +0200 (CEST)
Message-ID: <20060421205325.17922482C0@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46465 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932444AbWDUUw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:57 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow SSID to be set independently for each interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |    9 ++++++--
 net/d80211/ieee80211.c       |    6 ++++-
 net/d80211/ieee80211_i.h     |    3 +++
 net/d80211/ieee80211_ioctl.c |   47 +++++++++++++++++++++++++-----------------
 4 files changed, 43 insertions(+), 22 deletions(-)

41fbbdfe8770f3492f888fcd459b2f9d2d615b0b
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 3943e30..065b34c 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -251,8 +251,6 @@ struct ieee80211_conf {
 
         /* these fields are used by low level drivers for hardware
          * that generate beacons independently */
-        u8 *ssid;
-	size_t ssid_len;
 	u8 *generic_elem;
 	size_t generic_elem_len;
 
@@ -344,6 +342,11 @@ struct ieee80211_if_init_conf {
  *	during the live of the interface; this field is present only for
  *	convenience.
  * @bssid: BSSID of the network we are associated to/creating.
+ * @ssid: used (together with @ssid_len) by drivers for hardware that
+ *	generate beacons independently. The pointer is valid only during
+ *	config_interface() callback (so copy the value somewhere if you need
+ *	it).
+ * @ssid_len: length of the @ssid field.
  *
  * This structure is passed to config_interface() callback of
  * &struct ieee80211_hw.
@@ -351,6 +354,8 @@ struct ieee80211_if_init_conf {
 struct ieee80211_if_conf {
 	int type;
 	u8 *bssid;
+	u8 *ssid;
+	size_t ssid_len;
 };
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 425bd51..984c2b0 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1762,6 +1762,11 @@ int ieee80211_if_config(struct net_devic
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
 	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		conf.bssid = sdata->u.sta.bssid;
+		conf.ssid = sdata->u.sta.ssid;
+		conf.ssid_len = sdata->u.sta.ssid_len;
+	} else if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		conf.ssid = sdata->u.ap.ssid;
+		conf.ssid_len = sdata->u.ap.ssid_len;
 	}
 	return local->hw->config_interface(local->mdev, dev->ifindex, &conf);
 }
@@ -4337,7 +4342,6 @@ void ieee80211_unregister_hw(struct net_
 		kfree(local->basic_rates[i]);
         }
 
-	kfree(local->conf.ssid);
 	kfree(local->conf.generic_elem);
 
 	ieee80211_proc_deinit_interface(local);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index b29a5e8..e78beb2 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -192,6 +192,9 @@ struct ieee80211_if_ap {
 	u8 *beacon_head, *beacon_tail;
 	int beacon_head_len, beacon_tail_len;
 
+	u8 ssid[IEEE80211_MAX_SSID_LEN];
+	size_t ssid_len;
+
 	/* TODO: sta_aid could be replaced by 2008-bit large bitfield of
 	 * that could be used in TIM element generation. This would also
 	 * make TIM element generation a bit faster. */
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 792fcf4..6b73e27 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1746,7 +1746,6 @@ static int ieee80211_ioctl_siwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
-	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
         size_t len = data->length;
 
@@ -1759,14 +1758,14 @@ static int ieee80211_ioctl_siwessid(stru
 	    sdata->type == IEEE80211_IF_TYPE_IBSS)
 		return ieee80211_sta_set_ssid(dev, ssid, len);
 
-	kfree(local->conf.ssid);
-	local->conf.ssid = kmalloc(len + 1, GFP_KERNEL);
-	if (local->conf.ssid == NULL)
-		return -ENOMEM;
-	memcpy(local->conf.ssid, ssid, len);
-	local->conf.ssid[len] = '\0';
-	local->conf.ssid_len = len;
-	return ieee80211_hw_config(dev);
+	if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		memcpy(sdata->u.ap.ssid, ssid, len);
+		memset(sdata->u.ap.ssid + len, 0,
+		       IEEE80211_MAX_SSID_LEN - len);
+		sdata->u.ap.ssid_len = len;
+		return ieee80211_if_config(dev);
+	}
+	return -EOPNOTSUPP;
 }
 
 
@@ -1774,7 +1773,6 @@ static int ieee80211_ioctl_giwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
-	struct ieee80211_local *local = dev->priv;
 	size_t len;
 
 	struct ieee80211_sub_if_data *sdata;
@@ -1790,13 +1788,16 @@ static int ieee80211_ioctl_giwessid(stru
 		return res;
 	}
 
-	len = local->conf.ssid_len;
-	if (len > IW_ESSID_MAX_SIZE)
-		len = IW_ESSID_MAX_SIZE;
-	memcpy(ssid, local->conf.ssid, len);
-	data->length = len;
-	data->flags = 1;
-	return 0;
+	if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		len = sdata->u.ap.ssid_len;
+		if (len > IW_ESSID_MAX_SIZE)
+			len = IW_ESSID_MAX_SIZE;
+		memcpy(ssid, sdata->u.ap.ssid, len);
+		data->length = len;
+		data->flags = 1;
+		return 0;
+	}
+	return -EOPNOTSUPP;
 }
 
 
@@ -1848,12 +1849,20 @@ static int ieee80211_ioctl_siwscan(struc
 				   struct iw_point *data, char *extra)
 {
 	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	u8 *ssid = NULL;
 	size_t ssid_len = 0;
 
 	if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
-		ssid = local->conf.ssid;
-		ssid_len = local->conf.ssid_len;
+		if (sdata->type == IEEE80211_IF_TYPE_STA ||
+		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+			ssid = sdata->u.sta.ssid;
+			ssid_len = sdata->u.sta.ssid_len;
+		} else if (sdata == IEEE80211_IF_TYPE_AP) {
+			ssid = sdata->u.ap.ssid;
+			ssid_len = sdata->u.ap.ssid_len;
+		} else
+			return -EINVAL;
 	}
 	return ieee80211_sta_req_scan(dev, ssid, ssid_len);
 }
-- 
1.3.0

