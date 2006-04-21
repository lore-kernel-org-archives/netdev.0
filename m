From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/10] d80211: per-interface generic_elem
Date: Fri, 21 Apr 2006 22:53:26 +0200 (CEST)
Message-ID: <20060421205326.20113482C1@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46721 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932442AbWDUUw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:58 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow generic element to be set independently for each interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |   12 +++++++-----
 net/d80211/ieee80211.c       |    6 ++++--
 net/d80211/ieee80211_i.h     |    2 ++
 net/d80211/ieee80211_iface.c |    1 +
 net/d80211/ieee80211_ioctl.c |   19 ++++++++++---------
 5 files changed, 24 insertions(+), 16 deletions(-)

330ee7fb14673a5c69000a2c31c83830d7c6c456
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 065b34c..4bdbdbe 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -249,11 +249,6 @@ struct ieee80211_conf {
 	int short_slot_time:1;		/* use IEEE 802.11g Short Slot Time */
         int ssid_hidden:1;		/* do not broadcast the ssid */
 
-        /* these fields are used by low level drivers for hardware
-         * that generate beacons independently */
-	u8 *generic_elem;
-	size_t generic_elem_len;
-
         u8 power_level;			/* transmit power limit for current
 					 * regulatory domain; in dBm */
         u8 antenna_max;			/* maximum antenna gain */
@@ -347,6 +342,11 @@ struct ieee80211_if_init_conf {
  *	config_interface() callback (so copy the value somewhere if you need
  *	it).
  * @ssid_len: length of the @ssid field.
+ * @generic_elem: used (together with @generic_elem_len) by drivers for
+ *	hardware that generate beacons independently. The pointer is valid
+ *	only during config_interface() callback (so copy the value somewhere
+ *	if you need it).
+ * @generic_elem_len: length of the generic element.
  *
  * This structure is passed to config_interface() callback of
  * &struct ieee80211_hw.
@@ -356,6 +356,8 @@ struct ieee80211_if_conf {
 	u8 *bssid;
 	u8 *ssid;
 	size_t ssid_len;
+	u8 *generic_elem;
+	size_t generic_elem_len;
 };
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 984c2b0..ad63bab 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1764,9 +1764,13 @@ int ieee80211_if_config(struct net_devic
 		conf.bssid = sdata->u.sta.bssid;
 		conf.ssid = sdata->u.sta.ssid;
 		conf.ssid_len = sdata->u.sta.ssid_len;
+		conf.generic_elem = sdata->u.sta.extra_ie;
+		conf.generic_elem_len = sdata->u.sta.extra_ie_len;
 	} else if (sdata->type == IEEE80211_IF_TYPE_AP) {
 		conf.ssid = sdata->u.ap.ssid;
 		conf.ssid_len = sdata->u.ap.ssid_len;
+		conf.generic_elem = sdata->u.ap.generic_elem;
+		conf.generic_elem_len = sdata->u.ap.generic_elem_len;
 	}
 	return local->hw->config_interface(local->mdev, dev->ifindex, &conf);
 }
@@ -4342,8 +4346,6 @@ void ieee80211_unregister_hw(struct net_
 		kfree(local->basic_rates[i]);
         }
 
-	kfree(local->conf.generic_elem);
-
 	ieee80211_proc_deinit_interface(local);
 
 	if (skb_queue_len(&local->skb_queue)
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index e78beb2..98c30ff 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -194,6 +194,8 @@ struct ieee80211_if_ap {
 
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	size_t ssid_len;
+	u8 *generic_elem;
+	size_t generic_elem_len;
 
 	/* TODO: sta_aid could be replaced by 2008-bit large bitfield of
 	 * that could be used in TIM element generation. This would also
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index dd809c2..42ea643 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -175,6 +175,7 @@ #endif
 
 		kfree(sdata->u.ap.beacon_head);
 		kfree(sdata->u.ap.beacon_tail);
+		kfree(sdata->u.ap.generic_elem);
 
 		if (dev != local->mdev) {
 			struct sk_buff *skb;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 6b73e27..3eaad0a 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1137,7 +1137,6 @@ #endif
 
 static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 {
-	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1145,14 +1144,16 @@ static int ieee80211_set_gen_ie(struct n
 	    sdata->type == IEEE80211_IF_TYPE_IBSS)
 		return ieee80211_sta_set_extra_ie(dev, ie, len);
 
-	kfree(local->conf.generic_elem);
-	local->conf.generic_elem = kmalloc(len, GFP_KERNEL);
-	if (local->conf.generic_elem == NULL)
-		return -ENOMEM;
-	memcpy(local->conf.generic_elem, ie, len);
-	local->conf.generic_elem_len = len;
-
-	return ieee80211_hw_config(dev);
+	if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		kfree(sdata->u.ap.generic_elem);
+		sdata->u.ap.generic_elem = kmalloc(len, GFP_KERNEL);
+		if (sdata->u.ap.generic_elem == NULL)
+			return -ENOMEM;
+		memcpy(sdata->u.ap.generic_elem, ie, len);
+		sdata->u.ap.generic_elem_len = len;
+		return ieee80211_if_config(dev);
+	}
+	return -EOPNOTSUPP;
 }
 
 
-- 
1.3.0

