From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH resend] softmac: make non-operational after being stopped
Date: Sun, 30 Apr 2006 22:09:07 +0100 (BST)
Message-ID: <20060430210907.1E25A886B67@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:25055 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751221AbWD3VJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 17:09:11 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Cc: softmac-dev@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zd1211 with softmac and wpa_supplicant revealed an issue with softmac and the
use of workqueues. Some of the work functions actually reschedule themselves,
so this meant that there could still be pending work after
flush_scheduled_work() had been called during ieee80211softmac_stop().

This patch introduces a "running" flag which is used to ensure that
rescheduling does not happen in this situation.

I also used this flag to ensure that softmac's hooks into ieee80211 are
non-operational once the stop operation has been started. This simply makes
softmac a little more robust, because I could crash it easily by receiving
frames in the short timeframe after shutting down softmac and before turning
off the ZD1211 radio. (ZD1211 is now fixed as well!)

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

--

Sorry, the first version was mangled by my mailer (backslashes missing). This
one should be better.

Index: linux/net/ieee80211/softmac/ieee80211softmac_module.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_module.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -89,6 +89,8 @@ ieee80211softmac_clear_pending_work(stru
 	ieee80211softmac_wait_for_scan(sm);
 	
 	spin_lock_irqsave(&sm->lock, flags);
+	sm->running = 0;
+
 	/* Free all pending assoc work items */
 	cancel_delayed_work(&sm->associnfo.work);
 	
@@ -204,6 +206,8 @@ void ieee80211softmac_start(struct net_d
 		assert(0);
 	if (mac->txrates_change)
 		mac->txrates_change(dev, change, &oldrates);
+
+	mac->running = 1;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_start);
 
Index: linux/include/net/ieee80211softmac.h
===================================================================
--- linux.orig/include/net/ieee80211softmac.h
+++ linux/include/net/ieee80211softmac.h
@@ -204,7 +204,8 @@ struct ieee80211softmac_device {
 	
 	/* couple of flags */
 	u8 scanning:1, /* protects scanning from being done multiple times at once */
-	   associated:1;
+	   associated:1,
+	   running:1;
 	
 	struct ieee80211softmac_scaninfo *scaninfo;
 	struct ieee80211softmac_assoc_info associnfo;
Index: linux/net/ieee80211/softmac/ieee80211softmac_auth.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -86,6 +86,11 @@ ieee80211softmac_auth_queue(void *data)
 		
 		/* Lock and set flags */
 		spin_lock_irqsave(&mac->lock, flags);
+		if (unlikely(!mac->running)) {
+			/* Prevent reschedule on workqueue flush */
+			spin_unlock_irqrestore(&mac->lock, flags);
+			return;
+		}
 		net->authenticated = 0;
 		net->authenticating = 1;
 		/* add a timeout call so we eventually give up waiting for an auth reply */
@@ -124,6 +129,9 @@ ieee80211softmac_auth_resp(struct net_de
 	unsigned long flags;
 	u8 * data;
 	
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	/* Find correct auth queue item */
 	spin_lock_irqsave(&mac->lock, flags);
 	list_for_each(list_ptr, &mac->auth_queue) {
@@ -338,6 +346,9 @@ ieee80211softmac_deauth_resp(struct net_
 	struct ieee80211softmac_network *net = NULL;
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	if (!deauth) {
 		dprintk("deauth without deauth packet. eek!\n");
 		return 0;
Index: linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -51,11 +51,12 @@ ieee80211softmac_assoc(struct ieee80211s
 	spin_lock_irqsave(&mac->lock, flags);
 	mac->associnfo.associating = 1;
 	mac->associated = 0; /* just to make sure */
-	spin_unlock_irqrestore(&mac->lock, flags);
 
 	/* Set a timer for timeout */
 	/* FIXME: make timeout configurable */
-	schedule_delayed_work(&mac->associnfo.timeout, 5 * HZ);
+	if (likely(mac->running))
+		schedule_delayed_work(&mac->associnfo.timeout, 5 * HZ);
+	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
 void
@@ -319,6 +320,9 @@ ieee80211softmac_handle_assoc_response(s
 	u16 status = le16_to_cpup(&resp->status);
 	struct ieee80211softmac_network *network = NULL;
 	unsigned long flags;
+
+	if (unlikely(!mac->running))
+		return -ENODEV;
 	
 	spin_lock_irqsave(&mac->lock, flags);
 
@@ -377,10 +381,16 @@ ieee80211softmac_handle_disassoc(struct 
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	unsigned long flags;
+
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	if (memcmp(disassoc->header.addr2, mac->associnfo.bssid, ETH_ALEN))
 		return 0;
+
 	if (memcmp(disassoc->header.addr1, mac->dev->dev_addr, ETH_ALEN))
 		return 0;
+
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
 	netif_carrier_off(dev);
 	spin_lock_irqsave(&mac->lock, flags);
@@ -400,6 +410,9 @@ ieee80211softmac_handle_reassoc_req(stru
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	struct ieee80211softmac_network *network;
 
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	network = ieee80211softmac_get_network_by_bssid(mac, resp->header.addr3);
 	if (!network) {
 		dprintkl(KERN_INFO PFX "reassoc request from unknown network\n");
Index: linux/net/ieee80211/softmac/ieee80211softmac_scan.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_scan.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_scan.c
@@ -115,7 +115,15 @@ void ieee80211softmac_scan(void *d)
 			// TODO: is this if correct, or should we do this only if scanning from assoc request?
 			if (sm->associnfo.req_essid.len)
 				ieee80211softmac_send_mgt_frame(sm, &sm->associnfo.req_essid, IEEE80211_STYPE_PROBE_REQ, 0);
+
+			spin_lock_irqsave(&sm->lock, flags);
+			if (unlikely(!sm->running)) {
+				/* Prevent reschedule on workqueue flush */
+				spin_unlock_irqrestore(&sm->lock, flags);
+				break;
+			}
 			schedule_delayed_work(&si->softmac_scan, IEEE80211SOFTMAC_PROBE_DELAY);
+			spin_unlock_irqrestore(&sm->lock, flags);
 			return;
 		} else {
 			dprintk(PFX "Not probing Channel %d (not allowed here)\n", si->channels[current_channel_idx].channel);
