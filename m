From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 3/3] softmac: clean up event handling code
Date: Thu, 20 Apr 2006 20:02:04 +0200
Message-ID: <20060420180240.591313000@sipsolutions.net>
References: <20060420180201.092857000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42987 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751209AbWDTS34
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 14:29:56 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Cc: softmac-dev@sipsolutions.net
Content-Disposition: inline; filename=fix-event-code.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch cleans up the event handling code in ieee80211softmac_event.c and
makes the module slightly smaller by removing some strings that are not used
any more and consolidating some code.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-20 18:51:24.190142823 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_event.c	2006-04-20 18:54:07.540142823 +0200
@@ -38,7 +38,8 @@
  * The event context is private and can only be used from
  * within this module. Its meaning varies with the event
  * type:
- *  SCAN_FINISHED:	no special meaning
+ *  SCAN_FINISHED,
+ *  DISASSOCIATED:	NULL
  *  ASSOCIATED,
  *  ASSOCIATE_FAILED,
  *  ASSOCIATE_TIMEOUT,
@@ -59,15 +60,15 @@
  */
 
 static char *event_descriptions[IEEE80211SOFTMAC_EVENT_LAST+1] = {
-	"scan finished",
-	"associated",
+	NULL, /* scan finished */
+	NULL, /* associated */
 	"associating failed",
 	"associating timed out",
 	"authenticated",
 	"authenticating failed",
 	"authenticating timed out",
 	"associating failed because no suitable network was found",
-	"disassociated",
+	NULL, /* disassociated */
 };
 
 
@@ -136,30 +137,24 @@ ieee80211softmac_call_events_locked(stru
 		int we_event;
 		char *msg = NULL;
 
+		memset(&wrqu, '\0', sizeof (union iwreq_data));
+
 		switch(event) {
 		case IEEE80211SOFTMAC_EVENT_ASSOCIATED:
 			network = (struct ieee80211softmac_network *)event_ctx;
-			wrqu.data.length = 0;
-			wrqu.data.flags = 0;
 			memcpy(wrqu.ap_addr.sa_data, &network->bssid[0], ETH_ALEN);
-			wrqu.ap_addr.sa_family = ARPHRD_ETHER;
-			we_event = SIOCGIWAP;
-			break;
+			/* fall through */
 		case IEEE80211SOFTMAC_EVENT_DISASSOCIATED:
-			wrqu.data.length = 0;
-			wrqu.data.flags = 0;
-			memset(&wrqu, '\0', sizeof (union iwreq_data));
 			wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 			we_event = SIOCGIWAP;
 			break;
 		case IEEE80211SOFTMAC_EVENT_SCAN_FINISHED:
-			wrqu.data.length = 0;
-			wrqu.data.flags = 0;
-			memset(&wrqu, '\0', sizeof (union iwreq_data));
 			we_event = SIOCGIWSCAN;
 			break;
 		default:
 			msg = event_descriptions[event];
+			if (!msg)
+				msg = "SOFTMAC EVENT BUG";
 			wrqu.data.length = strlen(msg);
 			we_event = IWEVCUSTOM;
 			break;

--

