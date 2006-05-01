From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH resend] softmac: deauthentication implies deassociation
Date: Mon,  1 May 2006 22:23:27 +0100 (BST)
Message-ID: <20060501212327.364A3887A34@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:59435 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932272AbWEAVX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 17:23:26 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: softmac-dev@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 802.11 specs state that deauthenticating also implies disassociating. This
patch implements that, which improve the behaviour of SIOCSIWMLME.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

--

Sorry, missed a file (ieee80211softmac_priv.h) in the last attempt.

Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -82,28 +82,37 @@ ieee80211softmac_assoc_timeout(void *d)
 	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, NULL);
 }
 
-/* Sends out a disassociation request to the desired AP */
 void
-ieee80211softmac_disassoc(struct ieee80211softmac_device *mac, u16 reason)
+ieee80211softmac_disassoc(struct ieee80211softmac_device *mac)
 {
 	unsigned long flags;
+
+	spin_lock_irqsave(&mac->lock, flags);
+	if (mac->associnfo.associating)
+		cancel_delayed_work(&mac->associnfo.timeout);
+
+	netif_carrier_off(mac->dev);
+
+	mac->associated = 0;
+	mac->associnfo.bssvalid = 0;
+	mac->associnfo.associating = 0;
+	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
+/* Sends out a disassociation request to the desired AP */
+void
+ieee80211softmac_send_disassoc_req(struct ieee80211softmac_device *mac, u16 reason)
+{
 	struct ieee80211softmac_network *found;
 
 	if (mac->associnfo.bssvalid && mac->associated) {
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);
 		if (found)
 			ieee80211softmac_send_mgt_frame(mac, found, IEEE80211_STYPE_DISASSOC, reason);
-	} else if (mac->associnfo.associating) {
-		cancel_delayed_work(&mac->associnfo.timeout);
 	}
 
-	/* Change our state */
-	spin_lock_irqsave(&mac->lock, flags);
-	/* Do NOT clear bssvalid as that will break ieee80211softmac_assoc_work! */
-	mac->associated = 0;
-	mac->associnfo.associating = 0;
-	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
-	spin_unlock_irqrestore(&mac->lock, flags);
+	ieee80211softmac_disassoc(mac);
 }
 
 static inline int
@@ -176,14 +185,18 @@ ieee80211softmac_assoc_work(void *d)
 	struct ieee80211softmac_device *mac = (struct ieee80211softmac_device *)d;
 	struct ieee80211softmac_network *found = NULL;
 	struct ieee80211_network *net = NULL, *best = NULL;
+	int bssvalid;
 	unsigned long flags;
-	
+
+	/* ieee80211_disassoc might clear this */
+	bssvalid = mac->associnfo.bssvalid;
+
 	/* meh */
 	if (mac->associated)
-		ieee80211softmac_disassoc(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
+		ieee80211softmac_send_disassoc_req(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
 	/* try to find the requested network in our list, if we found one already */
-	if (mac->associnfo.bssvalid || mac->associnfo.bssfixed)
+	if (bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
 	
 	/* Search the ieee80211 networks for this network if we didn't find it by bssid,
@@ -380,7 +393,6 @@ ieee80211softmac_handle_disassoc(struct 
 				 struct ieee80211_disassoc *disassoc)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
-	unsigned long flags;
 
 	if (unlikely(!mac->running))
 		return -ENODEV;
@@ -392,14 +404,11 @@ ieee80211softmac_handle_disassoc(struct 
 		return 0;
 
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
-	netif_carrier_off(dev);
-	spin_lock_irqsave(&mac->lock, flags);
-	mac->associnfo.bssvalid = 0;
-	mac->associated = 0;
-	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
+	ieee80211softmac_disassoc(mac);
+
+	/* try to reassociate */
 	schedule_work(&mac->associnfo.work);
-	spin_unlock_irqrestore(&mac->lock, flags);
-	
+
 	return 0;
 }
 
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -279,6 +279,9 @@ ieee80211softmac_deauth_from_net(struct 
 	struct list_head *list_ptr;
 	unsigned long flags;
 
+	/* deauthentication implies disassociation */
+	ieee80211softmac_disassoc(mac);
+
 	/* Lock and reset status flags */
 	spin_lock_irqsave(&mac->lock, flags);
 	net->authenticating = 0;
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_wx.c
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -456,7 +456,7 @@ ieee80211softmac_wx_set_mlme(struct net_
 		}
 		return ieee80211softmac_deauth_req(mac, net, reason);
 	case IW_MLME_DISASSOC:
-		ieee80211softmac_disassoc(mac, reason);
+		ieee80211softmac_send_disassoc_req(mac, reason);
 		return 0;
 	default:
 		return -EOPNOTSUPP;
Index: linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_priv.h
===================================================================
--- linux-2.6.17-rc3.orig/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ linux-2.6.17-rc3/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -150,7 +150,8 @@ int ieee80211softmac_handle_disassoc(str
 int ieee80211softmac_handle_reassoc_req(struct net_device * dev,
 				        struct ieee80211_reassoc_request * reassoc);
 void ieee80211softmac_assoc_timeout(void *d);
-void ieee80211softmac_disassoc(struct ieee80211softmac_device *mac, u16 reason);
+void ieee80211softmac_send_disassoc_req(struct ieee80211softmac_device *mac, u16 reason);
+void ieee80211softmac_disassoc(struct ieee80211softmac_device *mac);
 
 /* some helper functions */
 static inline int ieee80211softmac_scan_handlers_check_self(struct ieee80211softmac_device *sm)
