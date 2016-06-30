From: Maxim Altshul <maxim.altshul@ti.com>
Subject: [PATCH v2] mac80211: mesh: Add support for HW RC implementation
Date: Thu, 30 Jun 2016 18:30:53 +0300
Message-ID: <20160630153055.26497-1-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maxim Altshul <maxim.altshul@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47958 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932196AbcF3P22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:28:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mesh HWMP module will be able to rely on the HW
RC algorithm if it exists, for path metric calculations.

This allows the metric calculation mechanism to calculate
a correct metric, based on PER and last TX rate both via
HW RC algorithm if it exists or via parameters collected
by the SW.

Signed-off-by: Maxim Altshul <maxim.altshul@ti.com>
---
Changed the function to return u32, I agree that this
is much clearer.
As for the rate, two things:
1. I had to divide the returned value by 100, since
drv_get_expected_throughput returns values in units of Kbps.
On the contrary, the function cfg80211_calculate_bitrate
returns in units of 100Kbps, so a correction is needed.
2. Why return the value into rate?
As I understand, rate here is actually bitrate,
and so, we have two possible outcomes:
- A SW/HW RC algo does exist, and an estimated throughput is
returned. err is set to 0 (as it is already included in the RC algo)
and the airtime is calculated using the estimated throughput.
- A SW/HW RC algo does not exist, and thus the regular calculation
takes place, in which an estimated throughput is calculated
using the bitrate and the err parameter.
>From this calculation the airtime is calculated.

 net/mac80211/mesh_hwmp.c | 25 +++++++++++++++++--------
 net/mac80211/sta_info.c  | 23 +++++++++++++++++++----
 net/mac80211/sta_info.h  |  2 ++
 3 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index c6be0b4..ad67f46 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -322,19 +322,28 @@ static u32 airtime_link_metric_get(struct ieee80211_local *local,
 	int device_constant = 1 << ARITH_SHIFT;
 	int test_frame_len = TEST_FRAME_LEN << ARITH_SHIFT;
 	int s_unit = 1 << ARITH_SHIFT;
-	int rate, err;
+	int rate = 0, err = 0;
 	u32 tx_time, estimated_retx;
 	u64 result;
 
-	if (sta->mesh->fail_avg >= 100)
-		return MAX_METRIC;
+	/* Try to get rate based on HW/SW RC algorithm.
+	 * Rate is returned in units of Kbps, correct this
+	 * to comply with airtime calculation units
+	 */
+	rate = sta_get_expected_throughput(sta) / 100;
+
+	/* if we did not get a rate */
+	if (!rate) {
+		if (sta->mesh->fail_avg >= 100)
+			return MAX_METRIC;
 
-	sta_set_rate_info_tx(sta, &sta->tx_stats.last_rate, &rinfo);
-	rate = cfg80211_calculate_bitrate(&rinfo);
-	if (WARN_ON(!rate))
-		return MAX_METRIC;
+		sta_set_rate_info_tx(sta, &sta->tx_stats.last_rate, &rinfo);
+		rate = cfg80211_calculate_bitrate(&rinfo);
+		if (WARN_ON(!rate))
+			return MAX_METRIC;
 
-	err = (sta->mesh->fail_avg << ARITH_SHIFT) / 100;
+		err = (sta->mesh->fail_avg << ARITH_SHIFT) / 100;
+	}
 
 	/* bitrate is in units of 100 Kbps, while we need rate in units of
 	 * 1Mbps. This will be corrected on tx_time computation.
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 63ea6cb..fa2c507 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -2069,14 +2069,29 @@ void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo)
 	if (test_sta_flag(sta, WLAN_STA_TDLS_PEER))
 		sinfo->sta_flags.set |= BIT(NL80211_STA_FLAG_TDLS_PEER);
 
+	thr = sta_get_expected_throughput(sta);
+
+	if (thr != 0) {
+		sinfo->filled |= BIT(NL80211_STA_INFO_EXPECTED_THROUGHPUT);
+		sinfo->expected_throughput = thr;
+	}
+}
+
+u32 sta_get_expected_throughput(struct sta_info *sta)
+{
+	struct ieee80211_sub_if_data *sdata = sta->sdata;
+	struct ieee80211_local *local = sdata->local;
+	struct rate_control_ref *ref = NULL;
+	u32 thr = 0;
+
+	if (test_sta_flag(sta, WLAN_STA_RATE_CONTROL))
+		ref = local->rate_ctrl;
+
 	/* check if the driver has a SW RC implementation */
 	if (ref && ref->ops->get_expected_throughput)
 		thr = ref->ops->get_expected_throughput(sta->rate_ctrl_priv);
 	else
 		thr = drv_get_expected_throughput(local, &sta->sta);
 
-	if (thr != 0) {
-		sinfo->filled |= BIT(NL80211_STA_INFO_EXPECTED_THROUGHPUT);
-		sinfo->expected_throughput = thr;
-	}
+	return thr;
 }
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 2cafb21..5c9c8be 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -661,6 +661,8 @@ void sta_set_rate_info_tx(struct sta_info *sta,
 			  struct rate_info *rinfo);
 void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo);
 
+u32 sta_get_expected_throughput(struct sta_info *sta);
+
 void ieee80211_sta_expire(struct ieee80211_sub_if_data *sdata,
 			  unsigned long exp_time);
 u8 sta_info_tx_streams(struct sta_info *sta);
-- 
2.9.0
