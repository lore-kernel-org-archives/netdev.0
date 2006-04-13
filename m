From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 4] softmac: fix event sending
Date: Thu, 13 Apr 2006 02:42:42 +0200
Message-ID: <1144888962.4187.36.camel@localhost>
References: <20060411085805.949313000@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:27815 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932382AbWDMAn5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 20:43:57 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060411085805.949313000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Softmac is sending custom events to userspace already, but it
should _really_ be sending the right WEXT events instead. This
patch fixes that.

Signed-off-by: Dan Williams <dcbw@redhat.com>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Index: wireless-2.6/include/net/ieee80211softmac.h
===================================================================
--- wireless-2.6.orig/include/net/ieee80211softmac.h	2006-04-13 02:35:54.686229309 +0200
+++ wireless-2.6/include/net/ieee80211softmac.h	2006-04-13 02:37:17.676229309 +0200
@@ -267,8 +267,9 @@
 #define IEEE80211SOFTMAC_EVENT_AUTH_FAILED		5
 #define IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT		6
 #define IEEE80211SOFTMAC_EVENT_ASSOCIATE_NET_NOT_FOUND	7
+#define IEEE80211SOFTMAC_EVENT_DISASSOCIATED		8
 /* keep this updated! */
-#define IEEE80211SOFTMAC_EVENT_LAST			7
+#define IEEE80211SOFTMAC_EVENT_LAST			8
 /*
  * If you want to be notified of certain events, you can call
  * ieee80211softmac_notify[_atomic] with
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-13 02:35:54.686229309 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-13 02:37:17.686229309 +0200
@@ -101,6 +101,7 @@
 	/* Do NOT clear bssvalid as that will break ieee80211softmac_assoc_work! */
 	mac->associated = 0;
 	mac->associnfo.associating = 0;
+	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
@@ -373,6 +374,7 @@
 	spin_lock_irqsave(&mac->lock, flags);
 	mac->associnfo.bssvalid = 0;
 	mac->associated = 0;
+	ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_DISASSOCIATED, NULL);
 	schedule_work(&mac->associnfo.work);
 	spin_unlock_irqrestore(&mac->lock, flags);
 	
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-13 02:35:54.686229309 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-13 02:38:51.036229309 +0200
@@ -67,6 +67,7 @@
 	"authenticating failed",
 	"authenticating timed out",
 	"associating failed because no suitable network was found",
+	"disassociated",
 };
 
 
@@ -128,13 +129,36 @@
 ieee80211softmac_call_events_locked(struct ieee80211softmac_device *mac, int event, void *event_ctx)
 {
 	struct ieee80211softmac_event *eventptr, *tmp;
-	union iwreq_data wrqu;
-	char *msg;
+	struct ieee80211softmac_network *network;
 	
 	if (event >= 0) {
-		msg = event_descriptions[event];
-		wrqu.data.length = strlen(msg);
-		wireless_send_event(mac->dev, IWEVCUSTOM, &wrqu, msg);
+		union iwreq_data wrqu;
+		int we_event;
+		char *msg = NULL;
+
+		switch(event) {
+		case IEEE80211SOFTMAC_EVENT_ASSOCIATED:
+			network = (struct ieee80211softmac_network *)event_ctx;
+			wrqu.data.length = 0;
+			wrqu.data.flags = 0;
+			memcpy(wrqu.ap_addr.sa_data, &network->bssid[0], ETH_ALEN);
+			wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+			we_event = SIOCGIWAP;
+			break;
+		case IEEE80211SOFTMAC_EVENT_DISASSOCIATED:
+			wrqu.data.length = 0;
+			wrqu.data.flags = 0;
+			memset(&wrqu, '\0', sizeof (union iwreq_data));
+			wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+			we_event = SIOCGIWAP;
+			break;
+		default:
+			msg = event_descriptions[event];
+			wrqu.data.length = strlen(msg);
+			we_event = IWEVCUSTOM;
+			break;
+		}
+		wireless_send_event(mac->dev, we_event, &wrqu, msg);
 	}
 
 	if (!list_empty(&mac->events))


