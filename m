From: Johannes Berg <johannes@sipsolutions.net>
Subject: [patch 2/3] softmac: fix SIOCSIWAP
Date: Thu, 20 Apr 2006 20:02:03 +0200
Message-ID: <20060420180238.887053000@sipsolutions.net>
References: <20060420180201.092857000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:48875 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751228AbWDTSaH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 14:30:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Cc: softmac-dev@sipsolutions.net
Content-Disposition: inline; filename=fix-SIOCSIWAP.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some bugs in the current implementation of the SIOCSIWAP wext,
for example that when you do it twice and it fails, it may still try
another access point for some reason. This patch fixes this by introducing
a new flag that tells the association code that the bssid that is in use
was fixed by the user and shouldn't be deviated from.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-2.6.orig/include/net/ieee80211softmac.h	2006-04-13 15:48:12.000000000 +0200
+++ wireless-2.6/include/net/ieee80211softmac.h	2006-04-20 01:10:32.770882874 +0200
@@ -96,10 +96,13 @@ struct ieee80211softmac_assoc_info {
 	 *
 	 * bssvalid is true if we found a matching network
 	 * and saved it's BSSID into the bssid above.
+	 *
+	 * bssfixed is used for SIOCSIWAP.
 	 */
 	u8 static_essid:1,
 	   associating:1,
-	   bssvalid:1;
+	   bssvalid:1,
+	   bssfixed:1;
 
 	/* Scan retries remaining */
 	int scan_retry;
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-19 18:46:47.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-20 01:30:59.090882874 +0200
@@ -144,6 +144,12 @@ network_matches_request(struct ieee80211
 	if (!we_support_all_basic_rates(mac, net->rates_ex, net->rates_ex_len))
 		return 0;
 
+	/* assume that users know what they're doing ...
+	 * (note we don't let them select a net we're incompatible with) */
+	if (mac->associnfo.bssfixed) {
+		return !memcmp(mac->associnfo.bssid, net->bssid, ETH_ALEN);
+	}
+
 	/* if 'ANY' network requested, take any that doesn't have privacy enabled */
 	if (mac->associnfo.req_essid.len == 0 
 	    && !(net->capability & WLAN_CAPABILITY_PRIVACY))
@@ -176,7 +182,7 @@ ieee80211softmac_assoc_work(void *d)
 		ieee80211softmac_disassoc(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
 	/* try to find the requested network in our list, if we found one already */
-	if (mac->associnfo.bssvalid)
+	if (mac->associnfo.bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
 	
 	/* Search the ieee80211 networks for this network if we didn't find it by bssid,
@@ -241,19 +247,25 @@ ieee80211softmac_assoc_work(void *d)
 			if (ieee80211softmac_start_scan(mac))
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
 			return;
-		}
-		else {
+		} else {
 			spin_lock_irqsave(&mac->lock, flags);
 			mac->associnfo.associating = 0;
 			mac->associated = 0;
 			spin_unlock_irqrestore(&mac->lock, flags);
 
 			dprintk(KERN_INFO PFX "Unable to find matching network after scan!\n");
+			/* reset the retry counter for the next user request since we
+			 * break out and don't reschedule ourselves after this point. */
+			mac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_NET_NOT_FOUND, NULL);
 			return;
 		}
 	}
-	
+
+	/* reset the retry counter for the next user request since we
+	 * now found a net and will try to associate to it, but not
+	 * schedule this function again. */
+	mac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 	mac->associnfo.bssvalid = 1;
 	memcpy(mac->associnfo.bssid, found->bssid, ETH_ALEN);
 	/* copy the ESSID for displaying it */
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-04-19 18:48:52.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-04-20 15:27:26.122486954 +0200
@@ -27,7 +27,8 @@
 #include "ieee80211softmac_priv.h"
 
 #include <net/iw_handler.h>
-
+/* for is_broadcast_ether_addr and is_zero_ether_addr */
+#include <linux/etherdevice.h>
 
 int
 ieee80211softmac_wx_trigger_scan(struct net_device *net_dev,
@@ -83,7 +84,6 @@ ieee80211softmac_wx_set_essid(struct net
 			sm->associnfo.static_essid = 1;
 		}
 	}
-	sm->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 
 	/* set our requested ESSID length.
 	 * If applicable, we have already copied the data in */
@@ -310,8 +310,6 @@ ieee80211softmac_wx_set_wap(struct net_d
 			    char *extra)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
-	static const unsigned char any[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-	static const unsigned char off[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
 	unsigned long flags;
 
 	/* sanity check */
@@ -320,10 +318,17 @@ ieee80211softmac_wx_set_wap(struct net_d
 	}
 
 	spin_lock_irqsave(&mac->lock, flags);
-	if (!memcmp(any, data->ap_addr.sa_data, ETH_ALEN) ||
-	    !memcmp(off, data->ap_addr.sa_data, ETH_ALEN)) {
-		schedule_work(&mac->associnfo.work);
-		goto out;
+	if (is_broadcast_ether_addr(data->ap_addr.sa_data)) {
+		/* the bssid we have is not to be fixed any longer,
+		 * and we should reassociate to the best AP. */
+		mac->associnfo.bssfixed = 0;
+		/* force reassociation */
+		mac->associnfo.bssvalid = 0;
+		if (mac->associated)
+			schedule_work(&mac->associnfo.work);
+	} else if (is_zero_ether_addr(data->ap_addr.sa_data)) {
+		/* the bssid we have is no longer fixed */
+		mac->associnfo.bssfixed = 0;
         } else {
 		if (!memcmp(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN)) {
 			if (mac->associnfo.associating || mac->associated) {
@@ -333,12 +338,14 @@ ieee80211softmac_wx_set_wap(struct net_d
 		} else {
 			/* copy new value in data->ap_addr.sa_data to bssid */
 			memcpy(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN);
-		}	
+		}
+		/* tell the other code that this bssid should be used no matter what */
+		mac->associnfo.bssfixed = 1;
 		/* queue associate if new bssid or (old one again and not associated) */
 		schedule_work(&mac->associnfo.work);
         }
 
-out:
+ out:
 	spin_unlock_irqrestore(&mac->lock, flags);
 	return 0;
 }
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_module.c	2006-03-28 16:23:33.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_module.c	2006-04-20 01:24:54.550882874 +0200
@@ -45,6 +45,8 @@ struct net_device *alloc_ieee80211softma
 	softmac->ieee->handle_disassoc = ieee80211softmac_handle_disassoc;
 	softmac->scaninfo = NULL;
 
+	softmac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
+
 	/* TODO: initialise all the other callbacks in the ieee struct
 	 *	 (once they're written)
 	 */

--

