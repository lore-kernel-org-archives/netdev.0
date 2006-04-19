From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] softmac: add SIOCSIWMLME
Date: Wed, 19 Apr 2006 19:13:23 +0200
Message-ID: <1145466804.8721.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: softmac-dev@sipsolutions.net,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:7847 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751115AbWDSRNa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 13:13:30 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the SIOCSIWMLME wext to softmac, this functionality
appears to be used by wpa_supplicant and is softmac-specific.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_priv.h	2006-04-19 18:44:51.710074158 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_priv.h	2006-04-19 18:46:38.000074158 +0200
@@ -150,6 +150,7 @@ int ieee80211softmac_handle_disassoc(str
 int ieee80211softmac_handle_reassoc_req(struct net_device * dev,
 				        struct ieee80211_reassoc_request * reassoc);
 void ieee80211softmac_assoc_timeout(void *d);
+void ieee80211softmac_disassoc(struct ieee80211softmac_device *mac, u16 reason);
 
 /* some helper functions */
 static inline int ieee80211softmac_scan_handlers_check_self(struct ieee80211softmac_device *sm)
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-04-19 18:44:51.710074158 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-04-19 18:48:52.200074158 +0200
@@ -424,3 +424,35 @@ ieee80211softmac_wx_get_genie(struct net
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_genie);
 
+int
+ieee80211softmac_wx_set_mlme(struct net_device *dev,
+			     struct iw_request_info *info,
+			     union iwreq_data *wrqu,
+			     char *extra)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+	struct iw_mlme *mlme = (struct iw_mlme *)extra;
+	u16 reason = cpu_to_le16(mlme->reason_code);
+	struct ieee80211softmac_network *net;
+
+	if (memcmp(mac->associnfo.bssid, mlme->addr.sa_data, ETH_ALEN)) {
+		printk(KERN_DEBUG PFX "wx_set_mlme: requested operation on net we don't use\n");
+		return -EINVAL;
+	}
+
+	switch (mlme->cmd) {
+	case IW_MLME_DEAUTH:
+		net = ieee80211softmac_get_network_by_bssid_locked(mac, mlme->addr.sa_data);
+		if (!net) {
+			printk(KERN_DEBUG PFX "wx_set_mlme: we should know the net here...\n");
+			return -EINVAL;
+		}
+		return ieee80211softmac_deauth_req(mac, net, reason);
+	case IW_MLME_DISASSOC:
+		ieee80211softmac_disassoc(mac, reason);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_mlme);
--- wireless-2.6.orig/include/net/ieee80211softmac_wx.h	2006-03-28 16:23:31.000000000 +0200
+++ wireless-2.6/include/net/ieee80211softmac_wx.h	2006-04-19 18:48:30.640074158 +0200
@@ -91,4 +91,9 @@ ieee80211softmac_wx_get_genie(struct net
 			      struct iw_request_info *info,
 			      union iwreq_data *wrqu,
 			      char *extra);
+extern int
+ieee80211softmac_wx_set_mlme(struct net_device *dev,
+			     struct iw_request_info *info,
+			     union iwreq_data *wrqu,
+			     char *extra);
 #endif /* _IEEE80211SOFTMAC_WX */
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-19 18:46:29.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-19 18:46:47.300074158 +0200
@@ -82,7 +82,7 @@ ieee80211softmac_assoc_timeout(void *d)
 }
 
 /* Sends out a disassociation request to the desired AP */
-static void
+void
 ieee80211softmac_disassoc(struct ieee80211softmac_device *mac, u16 reason)
 {
 	unsigned long flags;


