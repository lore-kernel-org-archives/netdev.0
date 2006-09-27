From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/14] d80211: clean up those huge else if statements
Date: Wed, 27 Sep 2006 17:50:49 +0200 (CEST)
Message-ID: <20060927155049.EB9D23BA24A@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49804 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964972AbWI0Ptp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:45 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch replaces the if (...) else if (...) else if (...) ...
statements I complained about earlier with switches.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |   44 +++++++++++++++++++++---------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

361d9a9f51633c7128158d90a05a3b6cc43ee444
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 89a58e3..34fdf40 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1000,11 +1000,13 @@ static int ieee80211_ioctl_add_if(struct
         int left = param_len - ((u8 *) pos - (u8 *) param);
 	struct net_device *new_dev;
 	int res;
+	struct hostapd_if_wds *wds;
+	struct hostapd_if_bss *bss;
 
 	printk(KERN_WARNING "PRISM2_HOSTAPD_ADD_IF ioctl is deprecated!");
-        if (param->u.if_info.type == HOSTAP_IF_WDS) {
-                struct hostapd_if_wds *wds =
-			(struct hostapd_if_wds *) param->u.if_info.data;
+	switch (param->u.if_info.type) {
+	case HOSTAP_IF_WDS:
+		wds = (struct hostapd_if_wds *) param->u.if_info.data;
 
                 if (left < sizeof(struct hostapd_if_wds))
                         return -EPROTO;
@@ -1018,7 +1020,7 @@ static int ieee80211_ioctl_add_if(struct
 			__ieee80211_if_del(dev->ieee80211_ptr,
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 		return res;
-	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
+	case HOSTAP_IF_VLAN:
 		if (left < sizeof(struct hostapd_if_vlan))
 			return -EPROTO;
 
@@ -1033,9 +1035,8 @@ #if 0
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 #endif
 		return res;
-        } else if (param->u.if_info.type == HOSTAP_IF_BSS) {
-                struct hostapd_if_bss *bss =
-			(struct hostapd_if_bss *) param->u.if_info.data;
+	case HOSTAP_IF_BSS:
+		bss = (struct hostapd_if_bss *) param->u.if_info.data;
 
                 if (left < sizeof(struct hostapd_if_bss))
                         return -EPROTO;
@@ -1046,12 +1047,7 @@ #endif
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_AP);
 		memcpy(new_dev->dev_addr, bss->bssid, ETH_ALEN);
 		return 0;
-        } else if (param->u.if_info.type == HOSTAP_IF_STA) {
-#if 0
-                struct hostapd_if_sta *sta =
-			(struct hostapd_if_sta *) param->u.if_info.data;
-#endif
-
+	case HOSTAP_IF_STA:
                 if (left < sizeof(struct hostapd_if_sta))
                         return -EPROTO;
 
@@ -1060,34 +1056,38 @@ #endif
 			return res;
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_STA);
 		return 0;
-	} else
-                return -EINVAL;
+	default:
+		return -EINVAL;
+	}
 
 	return 0;
 }
 
-
 static int ieee80211_ioctl_remove_if(struct net_device *dev,
 				     struct prism2_hostapd_param *param)
 {
 	unsigned int type;
 
-	if (param->u.if_info.type == HOSTAP_IF_WDS) {
+	switch (param->u.if_info.type) {
+	case HOSTAP_IF_WDS:
 		type = IEEE80211_IF_TYPE_WDS;
-	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
+		break;
+	case HOSTAP_IF_VLAN:
 		type = IEEE80211_IF_TYPE_VLAN;
-	} else if (param->u.if_info.type == HOSTAP_IF_BSS) {
+		break;
+	case HOSTAP_IF_BSS:
 		type = IEEE80211_IF_TYPE_AP;
-	} else if (param->u.if_info.type == HOSTAP_IF_STA) {
+		break;
+	case HOSTAP_IF_STA:
 		type = IEEE80211_IF_TYPE_STA;
-	} else {
+		break;
+	default:
 		return -EINVAL;
 	}
 
 	return ieee80211_if_remove(dev, param->u.if_info.name, type);
 }
 
-
 static int ieee80211_ioctl_update_if(struct net_device *dev,
 				     struct prism2_hostapd_param *param,
 				     int param_len)
-- 
1.3.0

