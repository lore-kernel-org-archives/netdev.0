From: Joseph Jezak <josejx@gentoo.org>
Subject: [PATCH] SoftMAC: Prevent multiple authentication attempts on the
 same network
Date: Sun, 11 Jun 2006 12:00:37 -0400
Message-ID: <448C3E25.3020905@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc11.comcast.net ([216.148.227.151]:12206 "EHLO
	rwcrmhc11.comcast.net") by vger.kernel.org with ESMTP
	id S1751316AbWFKQAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 12:00:39 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch addresses the "No queue exists" messages commonly seen during
authentication and associating.  These appear due to scheduling multiple
authentication attempts on the same network.  To prevent this, I added a
flag to stop multiple authentication attempts by the association layer.
I also added a check to the wx handler to see if we're connecting to a
different network than the one already in progress.  This scenario was
causing multiple requests on the same network because the network BSSID
was not being updated despite the fact that the ESSID changed.

Signed-off-by: Joseph Jezak <josejx@gentoo.org>

---

diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 052ed59..82a299a 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -101,6 +101,7 @@ struct ieee80211softmac_assoc_info {
 	 */
 	u8 static_essid:1,
 	   associating:1,
+	   assoc_wait:1,
 	   bssvalid:1,
 	   bssfixed:1;
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index 57ea9f6..aa65a7e 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -47,9 +47,7 @@ ieee80211softmac_assoc(struct ieee80211s
 	
 	dprintk(KERN_INFO PFX "sent association request!\n");
 
-	/* Change the state to associating */
 	spin_lock_irqsave(&mac->lock, flags);
-	mac->associnfo.associating = 1;
 	mac->associated = 0; /* just to make sure */
 
 	/* Set a timer for timeout */
@@ -181,6 +179,10 @@ ieee80211softmac_assoc_work(void *d)
 	/* meh */
 	if (mac->associated)
 		ieee80211softmac_disassoc(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
+	
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->associnfo.associating = 1;
+	spin_unlock_irqrestore(&mac->lock, flags);
 
 	/* try to find the requested network in our list, if we found one already */
 	if (mac->associnfo.bssvalid || mac->associnfo.bssfixed)
@@ -274,19 +276,32 @@ ieee80211softmac_assoc_work(void *d)
 	memcpy(mac->associnfo.associate_essid.data, found->essid.data, IW_ESSID_MAX_SIZE + 1);
 	
 	/* we found a network! authenticate (if necessary) and associate to it. */
-	if (!found->authenticated) {
+	if (found->authenticating) {
+		dprintk(KERN_INFO PFX "Already requested authentication, waiting...\n");
+		if(!mac->associnfo.assoc_wait) {
+			mac->associnfo.assoc_wait = 1;
+			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify, NULL, GFP_KERNEL);
+		}
+		return;
+	}
+	if (!found->authenticated && !found->authenticating) {
 		/* This relies on the fact that _auth_req only queues the work,
 		 * otherwise adding the notification would be racy. */
 		if (!ieee80211softmac_auth_req(mac, found)) {
-			dprintk(KERN_INFO PFX "cannot associate without being authenticated, requested authentication\n");
-			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify, NULL, GFP_KERNEL);
+			if(!mac->associnfo.assoc_wait) {
+				dprintk(KERN_INFO PFX "Cannot associate without being authenticated, requested authentication\n");
+				mac->associnfo.assoc_wait = 1;
+				ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify, NULL, GFP_KERNEL);
+			}
 		} else {
 			printkl(KERN_WARNING PFX "Not authenticated, but requesting authentication failed. Giving up to associate\n");
+			mac->associnfo.assoc_wait = 0;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, found);
 		}
 		return;
 	}
 	/* finally! now we can start associating */
+	mac->associnfo.assoc_wait = 0;
 	ieee80211softmac_assoc(mac, found);
 }
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 06e3326..23125ae 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -36,8 +36,9 @@ ieee80211softmac_auth_req(struct ieee802
 	struct ieee80211softmac_auth_queue_item *auth;
 	unsigned long flags;
 	
-	if (net->authenticating)
+	if (net->authenticating || net->authenticated) 
 		return 0;
+	net->authenticating = 1;
 
 	/* Add the network if it's not already added */
 	ieee80211softmac_add_network(mac, net);
@@ -92,7 +93,6 @@ ieee80211softmac_auth_queue(void *data)
 			return;
 		}
 		net->authenticated = 0;
-		net->authenticating = 1;
 		/* add a timeout call so we eventually give up waiting for an auth reply */
 		schedule_delayed_work(&auth->work, IEEE80211SOFTMAC_AUTH_TIMEOUT);
 		auth->retry--;
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 27edb2b..abd5f9c 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -70,12 +70,44 @@ ieee80211softmac_wx_set_essid(struct net
 			      char *extra)
 {
 	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
+	struct ieee80211softmac_network *n;
+	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
 	unsigned long flags;
-	
+
+	/* Check if we're already associating to this or another network
+	 * If it's another network, cancel and start over with our new network
+	 * If it's our network, ignore the change, we're already doing it!
+	 */
+	if((sm->associnfo.associating || sm->associated) && 
+	   (data->essid.flags && data->essid.length && extra)) {
+		/* Get the associating network */
+		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
+		if(n && n->essid.len == (data->essid.length - 1) && 
+		   !memcmp(n->essid.data, extra, n->essid.len)) {
+			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
+				MAC_ARG(sm->associnfo.bssid));
+			return 0;
+		} else {
+			dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
+			spin_lock_irqsave(&sm->lock,flags);
+			/* Cancel assoc work */
+			cancel_delayed_work(&sm->associnfo.work);
+			/* We don't have to do this, but it's a little cleaner */
+			list_for_each_entry(authptr, &sm->auth_queue, list)
+				cancel_delayed_work(&authptr->work);
+			sm->associnfo.bssvalid = 0;
+			sm->associnfo.bssfixed = 0;
+			spin_unlock_irqrestore(&sm->lock,flags);
+			flush_scheduled_work();
+		}
+	}
+
+
 	spin_lock_irqsave(&sm->lock, flags);
-	
+
 	sm->associnfo.static_essid = 0;
+	sm->associnfo.assoc_wait = 0;
 
 	if (data->essid.flags && data->essid.length && extra /*required?*/) {
 		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);

