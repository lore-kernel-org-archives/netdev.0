From: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Subject: [PATCH 05/10] mac80211: Add more ethtools stats: survey, rates, etc
Date: Wed, 11 Apr 2012 10:52:13 -0700
Message-ID: <1334166738-28243-6-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334166738-28243-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>

The signal and noise are forced to be positive since ethtool
deals in unsigned 64-bit values and this number should be human
readable.  This gives easy access to some of the data formerly
exposed in the deprecated /proc/net/wireless file.

Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
---
:100644 100644 ea2e995... bbaf564... M	net/mac80211/cfg.c
 net/mac80211/cfg.c |  156 ++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 115 insertions(+), 41 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index ea2e995..bbaf564 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -19,6 +19,7 @@
 #include "cfg.h"
 #include "rate.h"
 #include "mesh.h"
+#include "../wireless/core.h"
 
 static struct net_device *ieee80211_add_iface(struct wiphy *wiphy, char *name,
 					      enum nl80211_iftype type,
@@ -117,7 +118,9 @@ static const char ieee80211_gstrings_sta_stats[][ETH_GSTRING_LEN] = {
 	"rx_duplicates", "rx_fragments", "rx_dropped",
 	"tx_packets", "tx_bytes", "tx_fragments",
 	"tx_filtered", "tx_retry_failed", "tx_retries",
-	"beacon_loss"
+	"beacon_loss", "txrate", "rxrate", "signal",
+	"channel", "noise", "ch_time", "ch_time_busy",
+	"ch_time_ext_busy", "ch_time_rx", "ch_time_tx"
 };
 #define STA_STATS_LEN	ARRAY_SIZE(ieee80211_gstrings_sta_stats)
 
@@ -138,46 +141,6 @@ static int ieee80211_get_et_sset_count(struct wiphy *wiphy,
 	return rv;
 }
 
-static void ieee80211_get_et_stats(struct wiphy *wiphy,
-				   struct net_device *dev,
-				   struct ethtool_stats *stats,
-				   u64 *data)
-{
-	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	struct sta_info *sta;
-	struct ieee80211_local *local = sdata->local;
-
-	memset(data, 0, sizeof(u64) * STA_STATS_LEN);
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(sta, &local->sta_list, list) {
-		int i = 0;
-
-		/* Make sure this station belongs to the proper dev */
-		if (sta->sdata->dev != dev)
-			continue;
-
-		data[i++] += sta->rx_packets;
-		data[i++] += sta->rx_bytes;
-		data[i++] += sta->wep_weak_iv_count;
-		data[i++] += sta->num_duplicates;
-		data[i++] += sta->rx_fragments;
-		data[i++] += sta->rx_dropped;
-
-		data[i++] += sta->tx_packets;
-		data[i++] += sta->tx_bytes;
-		data[i++] += sta->tx_fragments;
-		data[i++] += sta->tx_filtered_count;
-		data[i++] += sta->tx_retry_failed;
-		data[i++] += sta->tx_retry_count;
-		data[i++] += sta->beacon_loss_count;
-		BUG_ON(i != STA_STATS_LEN);
-	}
-	rcu_read_unlock();
-
-	drv_get_et_stats(sdata, stats, &(data[STA_STATS_LEN]));
-}
-
 static void ieee80211_get_et_strings(struct wiphy *wiphy,
 				     struct net_device *dev,
 				     u32 sset, u8 *data)
@@ -531,6 +494,117 @@ static void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo)
 		sinfo->sta_flags.set |= BIT(NL80211_STA_FLAG_TDLS_PEER);
 }
 
+static void ieee80211_get_et_stats(struct wiphy *wiphy,
+				   struct net_device *dev,
+				   struct ethtool_stats *stats,
+				   u64 *data)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct sta_info *sta;
+	struct ieee80211_local *local = sdata->local;
+	struct station_info sinfo;
+	struct survey_info survey;
+	bool do_once = true;
+	int i;
+#define STA_STATS_SURVEY_LEN 7
+
+	memset(data, 0, sizeof(u64) * STA_STATS_LEN);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sta, &local->sta_list, list) {
+		i = 0;
+
+		/* Make sure this station belongs to the proper dev */
+		if (sta->sdata->dev != dev)
+			continue;
+
+		data[i++] += sta->rx_packets;
+		data[i++] += sta->rx_bytes;
+		data[i++] += sta->wep_weak_iv_count;
+		data[i++] += sta->num_duplicates;
+		data[i++] += sta->rx_fragments;
+		data[i++] += sta->rx_dropped;
+
+		data[i++] += sta->tx_packets;
+		data[i++] += sta->tx_bytes;
+		data[i++] += sta->tx_fragments;
+		data[i++] += sta->tx_filtered_count;
+		data[i++] += sta->tx_retry_failed;
+		data[i++] += sta->tx_retry_count;
+		data[i++] += sta->beacon_loss_count;
+
+		if (!do_once) {
+			i += 3;
+			goto after_once;
+		}
+
+		do_once = false;
+		sinfo.filled = 0;
+		sta_set_sinfo(sta, &sinfo);
+
+		if (sinfo.filled | STATION_INFO_TX_BITRATE)
+			data[i] = 100000 *
+				cfg80211_calculate_bitrate(&sinfo.txrate);
+		i++;
+		if (sinfo.filled | STATION_INFO_RX_BITRATE)
+			data[i] = 100000 *
+				cfg80211_calculate_bitrate(&sinfo.rxrate);
+		i++;
+
+		if (sinfo.filled | STATION_INFO_SIGNAL_AVG)
+			data[i] = abs(sinfo.signal_avg);
+		i++;
+
+after_once:
+		if (WARN_ON(i != (STA_STATS_LEN - STA_STATS_SURVEY_LEN))) {
+			rcu_read_unlock();
+			return;
+		}
+	}
+
+	i = STA_STATS_LEN - STA_STATS_SURVEY_LEN;
+	/* Get survey stats for current channel only */
+	survey.filled = 0;
+	if (drv_get_survey(local, 0, &survey) != 0) {
+		survey.filled = 0;
+		data[i++] = 0;
+	} else {
+		data[i++] = survey.channel->center_freq;
+	}
+
+	if (survey.filled & SURVEY_INFO_NOISE_DBM)
+		data[i++] = abs(survey.noise);
+	else
+		data[i++] = -1LL;
+	if (survey.filled & SURVEY_INFO_CHANNEL_TIME)
+		data[i++] = survey.channel_time;
+	else
+		data[i++] = -1LL;
+	if (survey.filled & SURVEY_INFO_CHANNEL_TIME_BUSY)
+		data[i++] = survey.channel_time_busy;
+	else
+		data[i++] = -1LL;
+	if (survey.filled & SURVEY_INFO_CHANNEL_TIME_EXT_BUSY)
+		data[i++] = survey.channel_time_ext_busy;
+	else
+		data[i++] = -1LL;
+	if (survey.filled & SURVEY_INFO_CHANNEL_TIME_RX)
+		data[i++] = survey.channel_time_rx;
+	else
+		data[i++] = -1LL;
+	if (survey.filled & SURVEY_INFO_CHANNEL_TIME_TX)
+		data[i++] = survey.channel_time_tx;
+	else
+		data[i++] = -1LL;
+
+	if (WARN_ON(i != STA_STATS_LEN)) {
+		rcu_read_unlock();
+		return;
+	}
+
+	drv_get_et_stats(sdata, stats, &(data[STA_STATS_LEN]));
+}
+
 
 static int ieee80211_dump_station(struct wiphy *wiphy, struct net_device *dev,
 				 int idx, u8 *mac, struct station_info *sinfo)
-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
