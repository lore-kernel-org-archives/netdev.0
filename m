From: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Subject: [PATCH v2 3/4] mac80211:  Framework to get wifi-driver stats via ethtool.
Date: Fri, 16 Mar 2012 12:59:11 -0700
Message-ID: <1331927952-8706-3-git-send-email-greearb@candelatech.com>
References: <1331927952-8706-1-git-send-email-greearb@candelatech.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331927952-8706-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>

This adds hooks to call into the driver to get additional
stats for the ethtool API.

Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
---
v2:  Add kdoc comments, trace support.
     Patch differs based on chaging of 2/4 patch as well.

:100644 100644 d49928b... a90cc8e... M	include/net/mac80211.h
:100644 100644 bb834d7... f82b285... M	net/mac80211/cfg.c
:100644 100644 b6ef8e7... c2d1661... M	net/mac80211/driver-ops.h
:100644 100644 6e9df8f... f05fc9c... M	net/mac80211/driver-trace.h
 include/net/mac80211.h      |   17 +++++++++++++++++
 net/mac80211/cfg.c          |   19 ++++++++++++++++---
 net/mac80211/driver-ops.h   |   37 +++++++++++++++++++++++++++++++++++++
 net/mac80211/driver-trace.h |   15 +++++++++++++++
 4 files changed, 85 insertions(+), 3 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index d49928b..a90cc8e 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -2108,6 +2108,14 @@ enum ieee80211_frame_release_type {
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
@@ -2236,6 +2244,15 @@ struct ieee80211_ops {
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
index bb834d7..f82b285 100644
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
index b6ef8e7..c2d1661 100644
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
index 6e9df8f..f05fc9c 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
