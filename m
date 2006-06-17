From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: allow NULL for control in beacon_get
Date: Sat, 17 Jun 2006 23:10:10 +0200
Message-ID: <200606172310.10690.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50318
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750908AbWFQVNW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 17:13:22 -0400
To: linville@tuxdriver.com, Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bcm43xx has no use for the "control" data provided by
ieee80211_beacon_get(), so allow passing a NULL pointer
to avoid setting up a dummy struct and throwing the data
away afterwards in the driver.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-06-17 22:51:20.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-06-17 23:03:54.000000000 +0200
@@ -1683,28 +1683,30 @@
 		memcpy(skb_put(skb, bt_len), b_tail, bt_len);
 	}
 
-	memset(&extra, 0, sizeof(extra));
-	extra.endidx = local->num_curr_rates;
+	if (control) {
+		memset(&extra, 0, sizeof(extra));
+		extra.endidx = local->num_curr_rates;
 
-	rate = rate_control_get_rate(dev, skb, &extra);
-	if (rate == NULL) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
-			       "found\n", dev->name);
+		rate = rate_control_get_rate(dev, skb, &extra);
+		if (rate == NULL) {
+			if (net_ratelimit()) {
+				printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
+				       "found\n", dev->name);
+			}
+			dev_kfree_skb(skb);
+			return NULL;
 		}
-		dev_kfree_skb(skb);
-		return NULL;
-	}
 
-	control->tx_rate = (local->short_preamble &&
-			    (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
-		rate->val2 : rate->val;
-	control->antenna_sel = local->conf.antenna_sel;
-	control->power_level = local->conf.power_level;
-	control->no_ack = 1;
-	control->retry_limit = 1;
-	control->rts_cts_duration = 0;
-	control->clear_dst_mask = 1;
+		control->tx_rate = (local->short_preamble &&
+				    (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
+			rate->val2 : rate->val;
+		control->antenna_sel = local->conf.antenna_sel;
+		control->power_level = local->conf.power_level;
+		control->no_ack = 1;
+		control->retry_limit = 1;
+		control->rts_cts_duration = 0;
+		control->clear_dst_mask = 1;
+	}
 
 	ap->num_beacons++;
 	return skb;


-- 
Greetings Michael.
