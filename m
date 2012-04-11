From: greearb@candelatech.com
Subject: [PATCH 02/10] mac80211: Support getting sta_info stats via ethtool.
Date: Wed, 11 Apr 2012 10:52:10 -0700
Message-ID: <1334166738-28243-3-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40892 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932754Ab2DKRww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:52:52 -0400
In-Reply-To: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This lets ethtool print out stats related to stations
connected to the interface.  Does not yet get stats
from the underlying driver.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 83e08dc... d008666... M	net/mac80211/cfg.c
 net/mac80211/cfg.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 83e08dc..d008666 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -112,6 +112,74 @@ static int ieee80211_set_noack_map(struct wiphy *wiphy,
 	return 0;
 }
 
+static const char ieee80211_gstrings_sta_stats[][ETH_GSTRING_LEN] = {
+	"rx_packets", "rx_bytes", "wep_weak_iv_count",
+	"rx_duplicates", "rx_fragments", "rx_dropped",
+	"tx_packets", "tx_bytes", "tx_fragments",
+	"tx_filtered", "tx_retry_failed", "tx_retries",
+	"beacon_loss"
+};
+#define STA_STATS_LEN	ARRAY_SIZE(ieee80211_gstrings_sta_stats)
+
+static int ieee80211_get_et_sset_count(struct wiphy *wiphy,
+				       struct net_device *dev,
+				       int sset)
+{
+	if (sset == ETH_SS_STATS)
+		return STA_STATS_LEN;
+
+	return -EOPNOTSUPP;
+}
+
+static void ieee80211_get_et_stats(struct wiphy *wiphy,
+				   struct net_device *dev,
+				   struct ethtool_stats *stats,
+				   u64 *data)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct sta_info *sta;
+	struct ieee80211_local *local = sdata->local;
+
+	memset(data, 0, sizeof(u64) * STA_STATS_LEN);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sta, &local->sta_list, list) {
+		int i = 0;
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
+		BUG_ON(i != STA_STATS_LEN);
+	}
+	rcu_read_unlock();
+}
+
+static void ieee80211_get_et_strings(struct wiphy *wiphy,
+				     struct net_device *dev,
+				     u32 sset, u8 *data)
+{
+	if (sset == ETH_SS_STATS) {
+		int sz_sta_stats = sizeof(ieee80211_gstrings_sta_stats);
+		memcpy(data, *ieee80211_gstrings_sta_stats, sz_sta_stats);
+	}
+}
+
+
 static int ieee80211_add_key(struct wiphy *wiphy, struct net_device *dev,
 			     u8 key_idx, bool pairwise, const u8 *mac_addr,
 			     struct key_params *params)
@@ -2749,4 +2817,7 @@ struct cfg80211_ops mac80211_config_ops = {
 	.probe_client = ieee80211_probe_client,
 	.get_channel = ieee80211_wiphy_get_channel,
 	.set_noack_map = ieee80211_set_noack_map,
+	.get_et_sset_count = ieee80211_get_et_sset_count,
+	.get_et_stats = ieee80211_get_et_stats,
+	.get_et_strings = ieee80211_get_et_strings,
 };
-- 
1.7.3.4
