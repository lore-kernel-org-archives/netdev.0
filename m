From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: Fix handling of authentication failure
Date: Thu,  1 Jun 2006 15:37:22 +0100 (BST)
Message-ID: <20060601143722.D0B2C89CF47@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:46012 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750720AbWFAOh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 10:37:28 -0400
To: linville@tuxdriver.com
Cc: johannes@sipsolutions.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My router blew up earlier, but exhibited some interesting behaviour during
its dying moments. It was broadcasting beacons but wouldn't respond to
any authentication requests.

I noticed that softmac wasn't playing nice with this, as I couldn't make it try
to connect to other networks after it had timed out authenticating to my ill
router.

To resolve this, I modified the softmac event/notify API to pass the event
code to the callback, so that callbacks being notified from
IEEE80211SOFTMAC_EVENT_ANY masks can make some judgement. In this case, the
ieee80211softmac_assoc callback needs to make a decision based upon whether
the association passed or failed.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Acked-by: Johannes Berg <johannes@sipsolutions.net>

---

This may be worth considering for 2.6.17. The current code does not check the
response to an authentication request before associating, it just assumes it 
was successful. This patch adds validation on that.

Index: linux/include/net/ieee80211softmac.h
===================================================================
--- linux.orig/include/net/ieee80211softmac.h
+++ linux/include/net/ieee80211softmac.h
@@ -359,7 +359,7 @@ extern void ieee80211softmac_stop(struct
  *	- context set to the context data you want passed
  * The return value is 0, or an error.
  */
-typedef void (*notify_function_ptr)(struct net_device *dev, void *context);
+typedef void (*notify_function_ptr)(struct net_device *dev, int event_type, void *context);
 
 #define ieee80211softmac_notify(dev, event, fun, context) ieee80211softmac_notify_gfp(dev, event, fun, context, GFP_KERNEL);
 #define ieee80211softmac_notify_atomic(dev, event, fun, context) ieee80211softmac_notify_gfp(dev, event, fun, context, GFP_ATOMIC);
Index: linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -164,12 +164,28 @@ network_matches_request(struct ieee80211
 }
 
 static void
-ieee80211softmac_assoc_notify(struct net_device *dev, void *context)
+ieee80211softmac_assoc_notify_scan(struct net_device *dev, int event_type, void *context)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	ieee80211softmac_assoc_work((void*)mac);
 }
 
+static void
+ieee80211softmac_assoc_notify_auth(struct net_device *dev, int event_type, void *context)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+
+	switch (event_type) {
+	case IEEE80211SOFTMAC_EVENT_AUTHENTICATED:
+		ieee80211softmac_assoc_work((void*)mac);
+		break;
+	case IEEE80211SOFTMAC_EVENT_AUTH_FAILED:
+	case IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT:
+		ieee80211softmac_disassoc(mac);
+		break;
+	}
+}
+
 /* This function is called to handle userspace requests (asynchronously) */
 void
 ieee80211softmac_assoc_work(void *d)
@@ -249,7 +265,7 @@ ieee80211softmac_assoc_work(void *d)
 			 * Maybe we can hope to have more memory after scanning finishes ;)
 			 */
 			dprintk(KERN_INFO PFX "Associate: Scanning for networks first.\n");
-			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify, NULL);
+			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
 			if (ieee80211softmac_start_scan(mac))
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
 			return;
@@ -284,7 +300,7 @@ ieee80211softmac_assoc_work(void *d)
 		 * otherwise adding the notification would be racy. */
 		if (!ieee80211softmac_auth_req(mac, found)) {
 			dprintk(KERN_INFO PFX "cannot associate without being authenticated, requested authentication\n");
-			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify, NULL, GFP_KERNEL);
+			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify_auth, NULL, GFP_KERNEL);
 		} else {
 			printkl(KERN_WARNING PFX "Not authenticated, but requesting authentication failed. Giving up to associate\n");
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, found);
Index: linux/net/ieee80211/softmac/ieee80211softmac_event.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_event.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_event.c
@@ -77,7 +77,7 @@ ieee80211softmac_notify_callback(void *d
 	struct ieee80211softmac_event event = *(struct ieee80211softmac_event*) d;
 	kfree(d);
 	
-	event.fun(event.mac->dev, event.context);
+	event.fun(event.mac->dev, event.event_type, event.context);
 }
 
 int
@@ -172,6 +172,9 @@ ieee80211softmac_call_events_locked(stru
 			if ((eventptr->event_type == event || eventptr->event_type == -1)
 				&& (eventptr->event_context == NULL || eventptr->event_context == event_ctx)) {
 				list_del(&eventptr->list);
+				/* User may have subscribed to ANY event, so
+				 * we tell them which event triggered it. */
+				eventptr->event_type = event;
 				schedule_work(&eventptr->work);
 			}
 		}
