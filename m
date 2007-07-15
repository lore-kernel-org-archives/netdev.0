From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 2/2] mac80211: implement ERP info change notifications
Date: Sun, 15 Jul 2007 15:08:22 +0100 (BST)
Message-ID: <20070715140822.C9DC07B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jbenc-AlSwsSmVLrQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

zd1211rw and bcm43xx are interested in being notified when ERP IE conditions
change, so that they can reprogram a register which affects how control frames
are transmitted.

This patch adds an interface similar to the one that can be found in softmac.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>

---
No changes since first submission, just resubmitting to complete the series

Index: wireless-dev/include/net/mac80211.h
===================================================================
--- wireless-dev.orig/include/net/mac80211.h
+++ wireless-dev/include/net/mac80211.h
@@ -685,6 +685,14 @@ struct ieee80211_ops {
 	void (*sta_table_notification)(struct ieee80211_hw *hw,
 				       int num_sta);
 
+	/* Handle ERP IE change notifications. Must be atomic. */
+	void (*erp_ie_changed)(struct ieee80211_hw *hw, u8 changes,
+			       int cts_protection, int preamble);
+
+	/* Flags for the erp_ie_changed changes parameter */
+#define IEEE80211_ERP_CHANGE_PROTECTION (1<<0) /* protection flag changed */
+#define IEEE80211_ERP_CHANGE_PREAMBLE (1<<1) /* barker preamble mode changed */
+
 	/* Configure TX queue parameters (EDCF (aifs, cw_min, cw_max),
 	 * bursting) for a hardware TX queue.
 	 * queue = IEEE80211_TX_QUEUE_*.
Index: wireless-dev/net/mac80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211.c
+++ wireless-dev/net/mac80211/ieee80211.c
@@ -2178,6 +2178,26 @@ int ieee80211_hw_config(struct ieee80211
 	return ret;
 }
 
+void ieee80211_erp_info_change_notify(struct net_device *dev, u8 changes)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (local->ops->erp_ie_changed)
+		local->ops->erp_ie_changed(local_to_hw(local), changes,
+					   sdata->use_protection,
+					   !sdata->short_preamble);
+}
+
+void ieee80211_reset_erp_info(struct net_device *dev)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	sdata->short_preamble = 0;
+	sdata->use_protection = 0;
+	ieee80211_erp_info_change_notify(dev,
+					 IEEE80211_ERP_CHANGE_PROTECTION |
+					 IEEE80211_ERP_CHANGE_PREAMBLE);
+}
 
 static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -2519,8 +2539,10 @@ static int ieee80211_open(struct net_dev
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR) {
 		local->monitors++;
 		local->hw.conf.flags |= IEEE80211_CONF_RADIOTAP;
-	} else
+	} else {
 		ieee80211_if_config(dev);
+		ieee80211_reset_erp_info(dev);
+	}
 
 	if (sdata->type == IEEE80211_IF_TYPE_STA &&
 	    !local->user_space_mlme)
Index: wireless-dev/net/mac80211/ieee80211_i.h
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_i.h
+++ wireless-dev/net/mac80211/ieee80211_i.h
@@ -892,6 +892,8 @@ struct sta_info *dls_info_get(struct iee
 void dls_info_add(struct ieee80211_if_sta *ifsta, struct sta_info *dls);
 void dls_info_stop(struct ieee80211_if_sta *ifsta);
 int dls_link_status(struct ieee80211_local *local, u8 *addr);
+void ieee80211_erp_info_change_notify(struct net_device *dev, u8 changes);
+void ieee80211_reset_erp_info(struct net_device *dev);
 
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
Index: wireless-dev/net/mac80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_ioctl.c
+++ wireless-dev/net/mac80211/ieee80211_ioctl.c
@@ -2316,10 +2316,12 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_CTS_PROTECT_ERP_FRAMES:
-		if (sdata->type != IEEE80211_IF_TYPE_AP)
+		if (sdata->type == IEEE80211_IF_TYPE_AP) {
+			sdata->use_protection = !!value;
+			ieee80211_erp_info_change_notify(dev, IEEE80211_ERP_CHANGE_PROTECTION);
+		} else {
 			ret = -ENOENT;
-		else
-			sdata->use_protection = value;
+		}
 		break;
 
 	case PRISM2_PARAM_DROP_UNENCRYPTED:
@@ -2327,10 +2329,12 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_PREAMBLE:
-		if (sdata->type != IEEE80211_IF_TYPE_AP)
+		if (sdata->type != IEEE80211_IF_TYPE_AP) {
+			sdata->short_preamble = !!value;
+			ieee80211_erp_info_change_notify(dev, IEEE80211_ERP_CHANGE_PREAMBLE);
+		} else {
 			ret = -ENOENT;
-		else
-			sdata->short_preamble = value;
+		}
 		break;
 
 	case PRISM2_PARAM_STAT_TIME:
Index: wireless-dev/net/mac80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_sta.c
+++ wireless-dev/net/mac80211/ieee80211_sta.c
@@ -358,6 +358,7 @@ static void ieee80211_handle_erp_ie(stru
 	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
 	int use_protection = (erp_value & WLAN_ERP_USE_PROTECTION) != 0;
 	int preamble_mode = (erp_value & WLAN_ERP_BARKER_PREAMBLE) != 0;
+	u8 changes = 0;
 
 	if (use_protection != sdata->use_protection) {
 		if (net_ratelimit()) {
@@ -368,6 +369,7 @@ static void ieee80211_handle_erp_ie(stru
 			       MAC_ARG(ifsta->bssid));
 		}
 		sdata->use_protection = use_protection;
+		changes |= IEEE80211_ERP_CHANGE_PROTECTION;
 	}
 
 	if (!preamble_mode != sdata->short_preamble) {
@@ -380,7 +382,11 @@ static void ieee80211_handle_erp_ie(stru
 			       MAC_ARG(ifsta->bssid));
 		}
 		sdata->short_preamble = !preamble_mode;
+		changes |= IEEE80211_ERP_CHANGE_PREAMBLE;
 	}
+
+	if (changes)
+		ieee80211_erp_info_change_notify(dev, changes);
 }
 
 
@@ -439,7 +445,6 @@ static void ieee80211_set_associated(str
 				     struct ieee80211_if_sta *ifsta, int assoc)
 {
 	union iwreq_data wrqu;
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (ifsta->associated == assoc)
 		return;
@@ -467,8 +472,7 @@ static void ieee80211_set_associated(str
 		ieee80211_sta_send_associnfo(dev, ifsta);
 	} else {
 		netif_carrier_off(dev);
-		sdata->short_preamble = 0;
-		sdata->use_protection = 0;
+		ieee80211_reset_erp_info(dev);
 		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
 	}
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
