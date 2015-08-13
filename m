From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/2] mac80211: use DECLARE_EWMA
Date: Thu, 13 Aug 2015 11:11:49 +0200
Message-ID: <1439457109-21833-2-git-send-email-johannes@sipsolutions.net>
References: <1439457109-21833-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1439457109-21833-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Instead of using the out-of-line average calculation, use the new
DECLARE_EWMA() macro to declare a signal EWMA, and use that.

This actually *reduces* the code size slightly (on x86-64) while
also reducing the station info size by 80 bytes.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/Kconfig      | 1 -
 net/mac80211/mesh_plink.c | 2 +-
 net/mac80211/rx.c         | 4 ++--
 net/mac80211/sta_info.c   | 9 +++++----
 net/mac80211/sta_info.h   | 6 ++++--
 5 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 086de496a4c1..3891cbd2adea 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -7,7 +7,6 @@ config MAC80211
 	select CRYPTO_CCM
 	select CRYPTO_GCM
 	select CRC32
-	select AVERAGE
 	---help---
 	  This option enables the hardware independent IEEE 802.11
 	  networking stack.
diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index 1a7d98398626..6fa6606fce55 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -64,7 +64,7 @@ static bool rssi_threshold_check(struct ieee80211_sub_if_data *sdata,
 {
 	s32 rssi_threshold = sdata->u.mesh.mshcfg.rssi_threshold;
 	return rssi_threshold == 0 ||
-	       (sta && (s8) -ewma_read(&sta->avg_signal) > rssi_threshold);
+	       (sta && (s8) -ewma_signal_read(&sta->avg_signal) > rssi_threshold);
 }
 
 /**
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 3a1462810c8e..e3cff02bde07 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1428,7 +1428,7 @@ ieee80211_rx_h_sta_process(struct ieee80211_rx_data *rx)
 	sta->rx_bytes += rx->skb->len;
 	if (!(status->flag & RX_FLAG_NO_SIGNAL_VAL)) {
 		sta->last_signal = status->signal;
-		ewma_add(&sta->avg_signal, -status->signal);
+		ewma_signal_add(&sta->avg_signal, -status->signal);
 	}
 
 	if (status->chains) {
@@ -1440,7 +1440,7 @@ ieee80211_rx_h_sta_process(struct ieee80211_rx_data *rx)
 				continue;
 
 			sta->chain_signal_last[i] = signal;
-			ewma_add(&sta->chain_signal_avg[i], -signal);
+			ewma_signal_add(&sta->chain_signal_avg[i], -signal);
 		}
 	}
 
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 9da7d2bc271a..dd9541c51de1 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -341,9 +341,9 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 
 	ktime_get_ts(&uptime);
 	sta->last_connected = uptime.tv_sec;
-	ewma_init(&sta->avg_signal, 1024, 8);
+	ewma_signal_init(&sta->avg_signal);
 	for (i = 0; i < ARRAY_SIZE(sta->chain_signal_avg); i++)
-		ewma_init(&sta->chain_signal_avg[i], 1024, 8);
+		ewma_signal_init(&sta->chain_signal_avg[i]);
 
 	if (local->ops->wake_tx_queue) {
 		void *txq_data;
@@ -1899,7 +1899,8 @@ void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo)
 		}
 
 		if (!(sinfo->filled & BIT(NL80211_STA_INFO_SIGNAL_AVG))) {
-			sinfo->signal_avg = (s8) -ewma_read(&sta->avg_signal);
+			sinfo->signal_avg =
+				(s8) -ewma_signal_read(&sta->avg_signal);
 			sinfo->filled |= BIT(NL80211_STA_INFO_SIGNAL_AVG);
 		}
 	}
@@ -1914,7 +1915,7 @@ void sta_set_sinfo(struct sta_info *sta, struct station_info *sinfo)
 		for (i = 0; i < ARRAY_SIZE(sinfo->chain_signal); i++) {
 			sinfo->chain_signal[i] = sta->chain_signal_last[i];
 			sinfo->chain_signal_avg[i] =
-				(s8) -ewma_read(&sta->chain_signal_avg[i]);
+				(s8) -ewma_signal_read(&sta->chain_signal_avg[i]);
 		}
 	}
 
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 6dcb33484eac..1c5333448bde 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -318,6 +318,8 @@ struct mesh_sta {
 	unsigned int fail_avg;
 };
 
+DECLARE_EWMA(signal, 1024, 8)
+
 /**
  * struct sta_info - STA information
  *
@@ -460,12 +462,12 @@ struct sta_info {
 	unsigned long rx_fragments;
 	unsigned long rx_dropped;
 	int last_signal;
-	struct ewma avg_signal;
+	struct ewma_signal avg_signal;
 	int last_ack_signal;
 
 	u8 chains;
 	s8 chain_signal_last[IEEE80211_MAX_CHAINS];
-	struct ewma chain_signal_avg[IEEE80211_MAX_CHAINS];
+	struct ewma_signal chain_signal_avg[IEEE80211_MAX_CHAINS];
 
 	/* Plus 1 for non-QoS frames */
 	__le16 last_seq_ctrl[IEEE80211_NUM_TIDS + 1];
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
