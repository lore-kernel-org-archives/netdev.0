From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] average: change to declare precision, not factor
Date: Wed, 15 Feb 2017 09:49:26 +0100
Message-ID: <20170215084926.29482-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael S . Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
        Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>,
        Antonio Quartulli <a@unstable.cc>,
        Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Declaring the factor is counter-intuitive, and people are prone
to using small(-ish) values even when that makes no sense.

Change the DECLARE_EWMA() macro to take the fractional precision,
in bits, rather than a factor, and update all users.

While at it, add some more documentation.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
Unless I hear any objections, I will take this through my tree.
---
 drivers/net/virtio_net.c                    |  2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h      |  2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h |  2 +-
 include/linux/average.h                     | 61 +++++++++++++++++++----------
 net/batman-adv/types.h                      |  2 +-
 net/mac80211/ieee80211_i.h                  |  2 +-
 net/mac80211/sta_info.h                     |  6 +--
 7 files changed, 49 insertions(+), 28 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 11e28530c83c..5e0cc9ec0f81 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -49,7 +49,7 @@ module_param(gso, bool, 0444);
  * at once, the weight is chosen so that the EWMA will be insensitive to short-
  * term, transient changes in packet size.
  */
-DECLARE_EWMA(pkt_len, 1, 64)
+DECLARE_EWMA(pkt_len, 0, 64)
 
 /* With mergeable buffers we align buffer address and use the low bits to
  * encode its true size. Buffer size is up to 1 page so we need to align to
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index 67fedb61fcc0..979800c6f57f 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1252,7 +1252,7 @@ struct ath5k_statistics {
 #define ATH5K_TXQ_LEN_MAX	(ATH_TXBUF / 4)		/* bufs per queue */
 #define ATH5K_TXQ_LEN_LOW	(ATH5K_TXQ_LEN_MAX / 2)	/* low mark */
 
-DECLARE_EWMA(beacon_rssi, 1024, 8)
+DECLARE_EWMA(beacon_rssi, 10, 8)
 
 /* Driver state associated with an instance of a device */
 struct ath5k_hw {
diff --git a/drivers/net/wireless/ralink/rt2x00/rt2x00.h b/drivers/net/wireless/ralink/rt2x00/rt2x00.h
index 26869b3bef45..340787894c69 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/ralink/rt2x00/rt2x00.h
@@ -257,7 +257,7 @@ struct link_qual {
 	int tx_failed;
 };
 
-DECLARE_EWMA(rssi, 1024, 8)
+DECLARE_EWMA(rssi, 10, 8)
 
 /*
  * Antenna settings about the currently active link.
diff --git a/include/linux/average.h b/include/linux/average.h
index d04aa58280de..7ddaf340d2ac 100644
--- a/include/linux/average.h
+++ b/include/linux/average.h
@@ -1,45 +1,66 @@
 #ifndef _LINUX_AVERAGE_H
 #define _LINUX_AVERAGE_H
 
-/* Exponentially weighted moving average (EWMA) */
+/*
+ * Exponentially weighted moving average (EWMA)
+ *
+ * This implements a fixed-precision EWMA algorithm, with both the
+ * precision and fall-off coefficient determined at compile-time
+ * and built into the generated helper funtions.
+ *
+ * The first argument to the macro is the name that will be used
+ * for the struct and helper functions.
+ *
+ * The second argument, the precision, expresses how many bits are
+ * used for the fractional part of the fixed-precision values.
+ *
+ * The third argument, the weight reciprocal, determines how the
+ * new values will be weighed vs. the old state, new values will
+ * get weight 1/weight_rcp and old values 1-1/weight_rcp. Note
+ * that this parameter must be a power of two for efficiency.
+ */
 
-#define DECLARE_EWMA(name, _factor, _weight)				\
+#define DECLARE_EWMA(name, _precision, _weight_rcp)			\
 	struct ewma_##name {						\
 		unsigned long internal;					\
 	};								\
 	static inline void ewma_##name##_init(struct ewma_##name *e)	\
 	{								\
-		BUILD_BUG_ON(!__builtin_constant_p(_factor));		\
-		BUILD_BUG_ON(!__builtin_constant_p(_weight));		\
-		BUILD_BUG_ON_NOT_POWER_OF_2(_factor);			\
-		BUILD_BUG_ON_NOT_POWER_OF_2(_weight);			\
+		BUILD_BUG_ON(!__builtin_constant_p(_precision));	\
+		BUILD_BUG_ON(!__builtin_constant_p(_weight_rcp));	\
+		/*							\
+		 * Even if you want to feed it just 0/1 you should have	\
+		 * some bits for the non-fractional part...		\
+		 */							\
+		BUILD_BUG_ON((_precision) > 30);			\
+		BUILD_BUG_ON_NOT_POWER_OF_2(_weight_rcp);		\
 		e->internal = 0;					\
 	}								\
 	static inline unsigned long					\
 	ewma_##name##_read(struct ewma_##name *e)			\
 	{								\
-		BUILD_BUG_ON(!__builtin_constant_p(_factor));		\
-		BUILD_BUG_ON(!__builtin_constant_p(_weight));		\
-		BUILD_BUG_ON_NOT_POWER_OF_2(_factor);			\
-		BUILD_BUG_ON_NOT_POWER_OF_2(_weight);			\
-		return e->internal >> ilog2(_factor);			\
+		BUILD_BUG_ON(!__builtin_constant_p(_precision));	\
+		BUILD_BUG_ON(!__builtin_constant_p(_weight_rcp));	\
+		BUILD_BUG_ON((_precision) > 30);			\
+		BUILD_BUG_ON_NOT_POWER_OF_2(_weight_rcp);		\
+		return e->internal >> (_precision);			\
 	}								\
 	static inline void ewma_##name##_add(struct ewma_##name *e,	\
 					     unsigned long val)		\
 	{								\
 		unsigned long internal = ACCESS_ONCE(e->internal);	\
-		unsigned long weight = ilog2(_weight);			\
-		unsigned long factor = ilog2(_factor);			\
+		unsigned long weight_rcp = ilog2(_weight_rcp);		\
+		unsigned long precision = _precision;			\
 									\
-		BUILD_BUG_ON(!__builtin_constant_p(_factor));		\
-		BUILD_BUG_ON(!__builtin_constant_p(_weight));		\
-		BUILD_BUG_ON_NOT_POWER_OF_2(_factor);			\
-		BUILD_BUG_ON_NOT_POWER_OF_2(_weight);			\
+		BUILD_BUG_ON(!__builtin_constant_p(_precision));	\
+		BUILD_BUG_ON(!__builtin_constant_p(_weight_rcp));	\
+		BUILD_BUG_ON((_precision) > 30);			\
+		BUILD_BUG_ON_NOT_POWER_OF_2(_weight_rcp);		\
 									\
 		ACCESS_ONCE(e->internal) = internal ?			\
-			(((internal << weight) - internal) +		\
-				(val << factor)) >> weight :		\
-			(val << factor);				\
+			(((internal << weight_rcp) - internal) +	\
+				(val << precision)) >> weight_rcp :	\
+			(val << precision);				\
 	}
 
 #endif /* _LINUX_AVERAGE_H */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8f64a5c01345..66b25e410a41 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -402,7 +402,7 @@ struct batadv_gw_node {
 	struct rcu_head rcu;
 };
 
-DECLARE_EWMA(throughput, 1024, 8)
+DECLARE_EWMA(throughput, 10, 8)
 
 /**
  * struct batadv_hardif_neigh_node_bat_v - B.A.T.M.A.N. V private neighbor
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 159a1a733725..0e718437d080 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -428,7 +428,7 @@ struct ieee80211_sta_tx_tspec {
 	bool downgraded;
 };
 
-DECLARE_EWMA(beacon_signal, 16, 4)
+DECLARE_EWMA(beacon_signal, 4, 4)
 
 struct ieee80211_if_managed {
 	struct timer_list timer;
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 71fa41a1368a..90a2c4deb00c 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -322,8 +322,8 @@ struct ieee80211_fast_rx {
 	struct rcu_head rcu_head;
 };
 
-/* we use only values in the range 0-100, so pick a large factor */
-DECLARE_EWMA(mesh_fail_avg, 1048576, 8)
+/* we use only values in the range 0-100, so pick a large precision */
+DECLARE_EWMA(mesh_fail_avg, 20, 8)
 
 /**
  * struct mesh_sta - mesh STA information
@@ -373,7 +373,7 @@ struct mesh_sta {
 	struct ewma_mesh_fail_avg fail_avg;
 };
 
-DECLARE_EWMA(signal, 1024, 8)
+DECLARE_EWMA(signal, 10, 8)
 
 struct ieee80211_sta_rx_stats {
 	unsigned long packets;
-- 
2.9.3
