From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: clean up those huge else if statements
Date: Wed, 30 Aug 2006 10:41:00 +0200
Message-ID: <1156927261.4013.53.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55234 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750701AbWH3IkZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 04:40:25 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the if (...) else if (...) else if (...) ...
statements I complained about earlier with switches.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-08-25 22:49:45.518728753 +0200
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-08-25 22:59:28.838728753 +0200
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
 
@@ -1033,9 +1035,8 @@ static int ieee80211_ioctl_add_if(struct
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
@@ -1046,12 +1047,7 @@ static int ieee80211_ioctl_add_if(struct
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
 
@@ -1060,34 +1056,38 @@ static int ieee80211_ioctl_add_if(struct
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

