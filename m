From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/14] d80211: diplay supported rates in readable format
Date: Wed, 27 Sep 2006 17:50:47 +0200 (CEST)
Message-ID: <20060927155047.E15783AA6B6@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49292 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964963AbWI0Ptn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:43 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: mabbas <mabbas@linux.intel.com>

This patch modify d80211 to report supported rates in readable
format in iwlist scan command.

Signed-off-by: Mohamed Abbas <mabbas@linux.intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_sta.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

f99ee9c93d75118c2dc54085ff2218407bd8601c
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 1f60a22..92cbad7 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2733,15 +2733,21 @@ ieee80211_sta_scan_result(struct net_dev
 		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
 						  buf);
 
-		p = buf;
-		p += sprintf(p, "supp_rates=");
-		for (i = 0; i < bss->supp_rates_len; i++)
-			p+= sprintf(p, "%02x", bss->supp_rates[i]);
-		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe,
-						  buf);
+		/* dispaly all support rates in readable format */
+		p = current_ev + IW_EV_LCP_LEN;
+		iwe.cmd = SIOCGIWRATE;
+		/* Those two flags are ignored... */
+		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
+		for (i = 0; i < bss->supp_rates_len; i++) {
+			iwe.u.bitrate.value = ((bss->supp_rates[i] &
+							0x7f) * 500000);
+			p = iwe_stream_add_value(current_ev, p,
+					end_buf, &iwe, IW_EV_PARAM_LEN);
+		}
+		/* Check if we added any rate */
+		if((p - current_ev) > IW_EV_LCP_LEN)
+			current_ev = p;
 
 		kfree(buf);
 		break;
-- 
1.3.0

