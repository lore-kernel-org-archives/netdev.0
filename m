From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/5] d80211: allow NULL for control in beacon_get
Date: Fri, 23 Jun 2006 15:01:22 +0200 (CEST)
Message-ID: <20060623130122.CC037483B0@silver.suse.cz>
References: <20060623150047.368594000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11911 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964804AbWFWM77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:59:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060623150047.368594000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Buesch <mb@bu3sch.de>

bcm43xx has no use for the "control" data provided by
ieee80211_beacon_get(), so allow passing a NULL pointer
to avoid setting up a dummy struct and throwing the data
away afterwards in the driver.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |   40 +++++++++++++++++++++-------------------
 1 files changed, 21 insertions(+), 19 deletions(-)

634f9d6f4bbafbcf218ac303087a0e83c5c95cda
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 9fc3518..ffb0f18 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1806,28 +1806,30 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
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
1.3.0

