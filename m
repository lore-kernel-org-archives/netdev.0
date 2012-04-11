From: greearb@candelatech.com
Subject: [PATCH 03/10] mac80211: Framework to get wifi-driver stats via ethtool.
Date: Wed, 11 Apr 2012 10:52:11 -0700
Message-ID: <1334166738-28243-4-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40894 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416Ab2DKRxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:53:00 -0400
In-Reply-To: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This adds hooks to call into the driver to get additional
stats for the ethtool API.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 ed55d89... b6822f9... M	include/net/mac80211.h
:100644 100644 d008666... ea2e995... M	net/mac80211/cfg.c
:100644 100644 8ad40f6... 047d8fe... M	net/mac80211/driver-ops.h
:100644 100644 d1f017a... 2722f8c... M	net/mac80211/driver-trace.h
 include/net/mac80211.h      |   17 +++++++++++++++++
 net/mac80211/cfg.c          |   19 ++++++++++++++++---
 net/mac80211/driver-ops.h   |   37 +++++++++++++++++++++++++++++++++++++
 net/mac80211/driver-trace.h |   15 +++++++++++++++
 4 files changed, 85 insertions(+), 3 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index ed55d89..b6822f9 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -2146,6 +2146,14 @@ enum ieee80211_rate_control_changed {
  *	The @tids parameter is a bitmap and tells the driver which TIDs the
  *	frames will be on; it will at most have two bits set.
  *	This callback must be atomic.
+ *
+ * @get_et_sset_count:  Ethtool API to get string-set count.
+ *
+ * @get_et_stats:  Ethtool API to get a set of u64 stats.
+ *
+ * @get_et_strings:  Ethtool API to get a set of strings to describe stats
+ *	and perhaps other supported types of ethtool data-sets.
+ *
  */
 struct ieee80211_ops {
 	void (*tx)(struct ieee80211_hw *hw, struct sk_buff *skb);
@@ -2275,6 +2283,15 @@ struct ieee80211_ops {
 					u16 tids, int num_frames,
 					enum ieee80211_frame_release_type reason,
 					bool more_data);
+
+	int	(*get_et_sset_count)(struct ieee80211_hw *hw,
+				     struct ieee80211_vif *vif, int sset);
+	void	(*get_et_stats)(struct ieee80211_hw *hw,
+				struct ieee80211_vif *vif,
+				struct ethtool_stats *stats, u64 *data);
+	void	(*get_et_strings)(struct ieee80211_hw *hw,
+				  struct ieee80211_vif *vif,
+				  u32 sset, u8 *data);
 };
 
 /**
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index d008666..ea2e995 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -125,10 +125,17 @@ static int ieee80211_get_et_sset_count(struct wiphy *wiphy,
 				       struct net_device *dev,
 				       int sset)
 {
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	int rv = 0;
+
 	if (sset == ETH_SS_STATS)
-		return STA_STATS_LEN;
+		rv += STA_STATS_LEN;
 
-	return -EOPNOTSUPP;
+	rv += drv_get_et_sset_count(sdata, sset);
+
+	if (rv == 0)
+		return -EOPNOTSUPP;
+	return rv;
 }
 
 static void ieee80211_get_et_stats(struct wiphy *wiphy,
@@ -167,16 +174,22 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
 		BUG_ON(i != STA_STATS_LEN);
 	}
 	rcu_read_unlock();
+
+	drv_get_et_stats(sdata, stats, &(data[STA_STATS_LEN]));
 }
 
 static void ieee80211_get_et_strings(struct wiphy *wiphy,
 				     struct net_device *dev,
 				     u32 sset, u8 *data)
 {
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	int sz_sta_stats = 0;
+
 	if (sset == ETH_SS_STATS) {
-		int sz_sta_stats = sizeof(ieee80211_gstrings_sta_stats);
+		sz_sta_stats = sizeof(ieee80211_gstrings_sta_stats);
 		memcpy(data, *ieee80211_gstrings_sta_stats, sz_sta_stats);
 	}
+	drv_get_et_strings(sdata, sset, &(data[sz_sta_stats]));
 }
 
 
diff --git a/net/mac80211/driver-ops.h b/net/mac80211/driver-ops.h
index 8ad40f6..047d8fe 100644
--- a/net/mac80211/driver-ops.h
+++ b/net/mac80211/driver-ops.h
@@ -35,6 +35,43 @@ static inline void drv_tx_frags(struct ieee80211_local *local,
 	local->ops->tx_frags(&local->hw, vif, sta, skbs);
 }
 
+static inline void drv_get_et_strings(struct ieee80211_sub_if_data *sdata,
+				      u32 sset, u8 *data)
+{
+	struct ieee80211_local *local = sdata->local;
+	if (local->ops->get_et_strings) {
+		trace_drv_get_et_strings(local, sset);
+		local->ops->get_et_strings(&local->hw, &sdata->vif, sset, data);
+		trace_drv_return_void(local);
+	}
+}
+
+static inline void drv_get_et_stats(struct ieee80211_sub_if_data *sdata,
+				    struct ethtool_stats *stats,
+				    u64 *data)
+{
+	struct ieee80211_local *local = sdata->local;
+	if (local->ops->get_et_stats) {
+		trace_drv_get_et_stats(local);
+		local->ops->get_et_stats(&local->hw, &sdata->vif, stats, data);
+		trace_drv_return_void(local);
+	}
+}
+
+static inline int drv_get_et_sset_count(struct ieee80211_sub_if_data *sdata,
+					int sset)
+{
+	struct ieee80211_local *local = sdata->local;
+	int rv = 0;
+	if (local->ops->get_et_sset_count) {
+		trace_drv_get_et_sset_count(local, sset);
+		rv = local->ops->get_et_sset_count(&local->hw, &sdata->vif,
+						   sset);
+		trace_drv_return_int(local, rv);
+	}
+	return rv;
+}
+
 static inline int drv_start(struct ieee80211_local *local)
 {
 	int ret;
diff --git a/net/mac80211/driver-trace.h b/net/mac80211/driver-trace.h
index d1f017a..2722f8c 100644
--- a/net/mac80211/driver-trace.h
+++ b/net/mac80211/driver-trace.h
@@ -161,6 +161,21 @@ DEFINE_EVENT(local_only_evt, drv_start,
 	TP_ARGS(local)
 );
 
+DEFINE_EVENT(local_u32_evt, drv_get_et_strings,
+	     TP_PROTO(struct ieee80211_local *local, u32 sset),
+	     TP_ARGS(local, sset)
+);
+
+DEFINE_EVENT(local_u32_evt, drv_get_et_sset_count,
+	     TP_PROTO(struct ieee80211_local *local, u32 sset),
+	     TP_ARGS(local, sset)
+);
+
+DEFINE_EVENT(local_only_evt, drv_get_et_stats,
+	     TP_PROTO(struct ieee80211_local *local),
+	     TP_ARGS(local)
+);
+
 DEFINE_EVENT(local_only_evt, drv_suspend,
 	TP_PROTO(struct ieee80211_local *local),
 	TP_ARGS(local)
-- 
1.7.3.4
