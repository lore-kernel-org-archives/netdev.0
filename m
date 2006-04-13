From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 3/6] ieee80211: export list of bit rates with standard WEXT procddures
Date: Thu, 13 Apr 2006 17:17:26 +0800
Message-ID: <20060413091726.GA28657@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:40112 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964833AbWDMJYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:24:32 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch replace the way to export the list of bit rates in scan results
from IWEVCUSTOM to SIOCGIWRATE. It also removes the max_rate item exported
with SIOCGIWRATE since this should be done by userspace.

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_wx.c |   44 ++++++++++++++++++++----------------------
 1 files changed, 21 insertions(+), 23 deletions(-)

d0da9825b30b4db3df3bbe2718e220f4119e0b64
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index b885fd1..0ea55cb 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -50,7 +50,8 @@ static char *ieee80211_translate_scan(st
 	char *p;
 	struct iw_event iwe;
 	int i, j;
-	u8 max_rate, rate;
+	char *current_val;	/* For rates */
+	u8 rate;
 
 	/* First entry *MUST* be the AP MAC address */
 	iwe.cmd = SIOCGIWAP;
@@ -107,9 +108,13 @@ static char *ieee80211_translate_scan(st
 	start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
 
 	/* Add basic and extended rates */
-	max_rate = 0;
-	p = custom;
-	p += snprintf(p, MAX_CUSTOM_LEN - (p - custom), " Rates (Mb/s): ");
+	/* Rate : stuffing multiple values in a single event require a bit
+	 * more of magic - Jean II */
+	current_val = start + IW_EV_LCP_LEN;
+	iwe.cmd = SIOCGIWRATE;
+	/* Those two flags are ignored... */
+	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
 	for (i = 0, j = 0; i < network->rates_len;) {
 		if (j < network->rates_ex_len &&
 		    ((network->rates_ex[j] & 0x7F) <
@@ -117,28 +122,21 @@ static char *ieee80211_translate_scan(st
 			rate = network->rates_ex[j++] & 0x7F;
 		else
 			rate = network->rates[i++] & 0x7F;
-		if (rate > max_rate)
-			max_rate = rate;
-		p += snprintf(p, MAX_CUSTOM_LEN - (p - custom),
-			      "%d%s ", rate >> 1, (rate & 1) ? ".5" : "");
+		/* Bit rate given in 500 kb/s units (+ 0x80) */
+		iwe.u.bitrate.value = ((rate & 0x7f) * 500000);
+		/* Add new value to event */
+		current_val = iwe_stream_add_value(start, current_val, stop, &iwe, IW_EV_PARAM_LEN);
 	}
 	for (; j < network->rates_ex_len; j++) {
 		rate = network->rates_ex[j] & 0x7F;
-		p += snprintf(p, MAX_CUSTOM_LEN - (p - custom),
-			      "%d%s ", rate >> 1, (rate & 1) ? ".5" : "");
-		if (rate > max_rate)
-			max_rate = rate;
-	}
-
-	iwe.cmd = SIOCGIWRATE;
-	iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
-	iwe.u.bitrate.value = max_rate * 500000;
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_PARAM_LEN);
-
-	iwe.cmd = IWEVCUSTOM;
-	iwe.u.data.length = p - custom;
-	if (iwe.u.data.length)
-		start = iwe_stream_add_point(start, stop, &iwe, custom);
+		/* Bit rate given in 500 kb/s units (+ 0x80) */
+		iwe.u.bitrate.value = ((rate & 0x7f) * 500000);
+		/* Add new value to event */
+		current_val = iwe_stream_add_value(start, current_val, stop, &iwe, IW_EV_PARAM_LEN);
+	}
+	/* Check if we added any rate */
+	if((current_val - start) > IW_EV_LCP_LEN)
+		start = current_val;
 
 	/* Add quality statistics */
 	iwe.cmd = IWEVQUAL;
-- 
1.2.6

