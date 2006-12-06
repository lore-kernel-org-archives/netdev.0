From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] softmac: Fixed handling of deassociation from AP
Date: Wed, 06 Dec 2006 08:45:12 -0600
Message-ID: <4576D778.mailLQC18T1PN@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kune@deine-taler.de, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-02.rdc-kc.rr.com ([24.94.166.122]:48967 "EHLO
	ms-smtp-02.rdc-kc.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760646AbWLFOp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 09:45:56 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From:  Ulrich Kunitz <kune@deine-taler.de>
 
A deauthentication from the AP doesn't start a reassociation by
SoftMAC. To fix this mac->associnfo.associating must be set and the
ieee80211softmac_assoc_work function must be scheduled.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

 net/ieee80211/softmac/ieee80211softmac_assoc.c |   14 ++++++++++++--
 net/ieee80211/softmac/ieee80211softmac_auth.c  |    2 ++
 net/ieee80211/softmac/ieee80211softmac_priv.h  |    2 ++
 3 files changed, 16 insertions(+), 2 deletions(-)

Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -427,6 +427,17 @@ ieee80211softmac_handle_assoc_response(s
 	return 0;
 }
 
+void
+ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->associnfo.associating = 1;
+	schedule_work(&mac->associnfo.work);
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
 int
 ieee80211softmac_handle_disassoc(struct net_device * dev,
 				 struct ieee80211_disassoc *disassoc)
@@ -445,8 +456,7 @@ ieee80211softmac_handle_disassoc(struct 
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
 	ieee80211softmac_disassoc(mac);
 
-	/* try to reassociate */
-	schedule_work(&mac->associnfo.work);
+	ieee80211softmac_try_reassoc(mac);
 
 	return 0;
 }
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -334,6 +334,8 @@ ieee80211softmac_deauth_from_net(struct 
 	/* can't transmit data right now... */
 	netif_carrier_off(mac->dev);
 	spin_unlock_irqrestore(&mac->lock, flags);
+
+	ieee80211softmac_try_reassoc(mac);
 }
 
 /* 
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_priv.h
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_priv.h
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_priv.h
@@ -238,4 +238,6 @@ void ieee80211softmac_call_events_locked
 int ieee80211softmac_notify_internal(struct ieee80211softmac_device *mac,
 	int event, void *event_context, notify_function_ptr fun, void *context, gfp_t gfp_mask);
 
+void ieee80211softmac_try_reassoc(struct ieee80211softmac_device *mac);
+
 #endif /* IEEE80211SOFTMAC_PRIV_H_ */

---

