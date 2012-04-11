From: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Subject: [PATCH 09/10] ath9k: Add more recv stats.
Date: Wed, 11 Apr 2012 10:52:17 -0700
Message-ID: <1334166738-28243-10-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334166738-28243-1-git-send-email-greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>

This adds counters in various places that can drop packets on
rx without otherwise incrementing a counter.  It also counts
some non-error cases, such as becons and fragments received.

Should help with figuring out where packets are (and are not)
dropped.

Signed-off-by: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
---
:100644 100644 186efc5... 189ac7f... M	drivers/net/wireless/ath/ath9k/debug.c
:100644 100644 fe2b487... 17f6cc2... M	drivers/net/wireless/ath/ath9k/debug.h
:100644 100644 8588017... 301ef3e... M	drivers/net/wireless/ath/ath9k/recv.c
 drivers/net/wireless/ath/ath9k/debug.c |   53 ++++++++++++++------------------
 drivers/net/wireless/ath/ath9k/debug.h |   18 +++++++++++
 drivers/net/wireless/ath/ath9k/recv.c  |   35 +++++++++++++++-----
 3 files changed, 67 insertions(+), 39 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 186efc5..189ac7f 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -881,36 +881,27 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 	len += snprintf(buf + len, size - len, "%22s : %10u\n", s, \
 			sc->debug.stats.rxstats.phy_err_stats[p]);
 
+#define RXS_ERR(s, e)				\
+	len += snprintf(buf + len, size - len,	\
+			"%22s : %10u\n", s, \
+			sc->debug.stats.rxstats.e);
+
 	struct ath_softc *sc = file->private_data;
 	char *buf;
-	unsigned int len = 0, size = 1600;
+	unsigned int len = 0, size = 3000;
 	ssize_t retval = 0;
 
 	buf = kzalloc(size, GFP_KERNEL);
 	if (buf == NULL)
 		return -ENOMEM;
 
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "CRC ERR",
-			sc->debug.stats.rxstats.crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "DECRYPT CRC ERR",
-			sc->debug.stats.rxstats.decrypt_crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "PHY ERR",
-			sc->debug.stats.rxstats.phy_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "MIC ERR",
-			sc->debug.stats.rxstats.mic_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "PRE-DELIM CRC ERR",
-			sc->debug.stats.rxstats.pre_delim_crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "POST-DELIM CRC ERR",
-			sc->debug.stats.rxstats.post_delim_crc_err);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "DECRYPT BUSY ERR",
-			sc->debug.stats.rxstats.decrypt_busy_err);
+	RXS_ERR("CRC ERR", crc_err);
+	RXS_ERR("DECRYPT CRC ERR", decrypt_crc_err);
+	RXS_ERR("PHY ERR", phy_err);
+	RXS_ERR("MIC ERR", mic_err);
+	RXS_ERR("PRE-DELIM CRC ERR", pre_delim_crc_err);
+	RXS_ERR("POST-DELIM CRC ERR", post_delim_crc_err);
+	RXS_ERR("DECRYPT BUSY ERR", decrypt_busy_err);
 
 	PHY_ERR("UNDERRUN ERR", ATH9K_PHYERR_UNDERRUN);
 	PHY_ERR("TIMING ERR", ATH9K_PHYERR_TIMING);
@@ -939,12 +930,16 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 	PHY_ERR("HT-LENGTH ERR", ATH9K_PHYERR_HT_LENGTH_ILLEGAL);
 	PHY_ERR("HT-RATE ERR", ATH9K_PHYERR_HT_RATE_ILLEGAL);
 
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-Pkts-All",
-			sc->debug.stats.rxstats.rx_pkts_all);
-	len += snprintf(buf + len, size - len,
-			"%22s : %10u\n", "RX-Bytes-All",
-			sc->debug.stats.rxstats.rx_bytes_all);
+	RXS_ERR("DECRYPT BUSY ERR", decrypt_busy_err);
+	RXS_ERR("RX-LENGTH-ERR", rx_len_err);
+	RXS_ERR("RX-OOM-ERR", rx_oom_err);
+	RXS_ERR("RX-RATE-ERR", rx_rate_err);
+	RXS_ERR("RX-DROP-RXFLUSH", rx_drop_rxflush);
+	RXS_ERR("RX-TOO-MANY-FRAGS", rx_too_many_frags_err);
+	RXS_ERR("RX-Pkts-All", rx_pkts_all);
+	RXS_ERR("RX-Bytes-All", rx_bytes_all);
+	RXS_ERR("RX-Beacons", rx_beacons);
+	RXS_ERR("RX-Frags", rx_frags);
 
 	if (len > size)
 		len = size;
@@ -959,7 +954,6 @@ static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 
 void ath_debug_stat_rx(struct ath_softc *sc, struct ath_rx_status *rs)
 {
-#define RX_STAT_INC(c) sc->debug.stats.rxstats.c++
 #define RX_PHY_ERR_INC(c) sc->debug.stats.rxstats.phy_err_stats[c]++
 #define RX_SAMP_DBG(c) (sc->debug.bb_mac_samp[sc->debug.sampidx].rs\
 			[sc->debug.rsidx].c)
@@ -1005,7 +999,6 @@ void ath_debug_stat_rx(struct ath_softc *sc, struct ath_rx_status *rs)
 
 #endif
 
-#undef RX_STAT_INC
 #undef RX_PHY_ERR_INC
 #undef RX_SAMP_DBG
 }
diff --git a/drivers/net/wireless/ath/ath9k/debug.h b/drivers/net/wireless/ath/ath9k/debug.h
index fe2b487..17f6cc2 100644
--- a/drivers/net/wireless/ath/ath9k/debug.h
+++ b/drivers/net/wireless/ath/ath9k/debug.h
@@ -139,6 +139,8 @@ struct ath_tx_stats {
 	u32 txfailed;
 };
 
+#define RX_STAT_INC(c) (sc->debug.stats.rxstats.c++)
+
 /**
  * struct ath_rx_stats - RX Statistics
  * @rx_pkts_all:  No. of total frames received, including ones that
@@ -155,6 +157,13 @@ struct ath_tx_stats {
  * @post_delim_crc_err: Post-Frame delimiter CRC error detections
  * @decrypt_busy_err: Decryption interruptions counter
  * @phy_err_stats: Individual PHY error statistics
+ * @rx_len_err:  No. of frames discarded due to bad length.
+ * @rx_oom_err:  No. of frames dropped due to OOM issues.
+ * @rx_rate_err:  No. of frames dropped due to rate errors.
+ * @rx_too_many_frags_err:  Frames dropped due to too-many-frags received.
+ * @rx_drop_rxflush: No. of frames dropped due to RX-FLUSH.
+ * @rx_beacons:  No. of beacons received.
+ * @rx_frags:  No. of rx-fragements received.
  */
 struct ath_rx_stats {
 	u32 rx_pkts_all;
@@ -167,6 +176,13 @@ struct ath_rx_stats {
 	u32 post_delim_crc_err;
 	u32 decrypt_busy_err;
 	u32 phy_err_stats[ATH9K_PHYERR_MAX];
+	u32 rx_len_err;
+	u32 rx_oom_err;
+	u32 rx_rate_err;
+	u32 rx_too_many_frags_err;
+	u32 rx_drop_rxflush;
+	u32 rx_beacons;
+	u32 rx_frags;
 };
 
 enum ath_reset_type {
@@ -250,6 +266,8 @@ void ath_debug_stat_rx(struct ath_softc *sc, struct ath_rx_status *rs);
 
 #else
 
+#define RX_STAT_INC(c) /* NOP */
+
 static inline int ath9k_init_debug(struct ath_hw *ah)
 {
 	return 0;
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 8588017..301ef3e 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -824,15 +824,20 @@ static bool ath9k_rx_accept(struct ath_common *common,
 	if (rx_stats->rs_keyix == ATH9K_RXKEYIX_INVALID)
 		rx_stats->rs_status &= ~ATH9K_RXERR_KEYMISS;
 
-	if (!rx_stats->rs_datalen)
+	if (!rx_stats->rs_datalen) {
+		RX_STAT_INC(rx_len_err);
 		return false;
+	}
+
         /*
          * rs_status follows rs_datalen so if rs_datalen is too large
          * we can take a hint that hardware corrupted it, so ignore
          * those frames.
          */
-	if (rx_stats->rs_datalen > (common->rx_bufsize - rx_status_len))
+	if (rx_stats->rs_datalen > (common->rx_bufsize - rx_status_len)) {
+		RX_STAT_INC(rx_len_err);
 		return false;
+	}
 
 	/* Only use error bits from the last fragment */
 	if (rx_stats->rs_more)
@@ -902,6 +907,7 @@ static int ath9k_process_rate(struct ath_common *common,
 	struct ieee80211_supported_band *sband;
 	enum ieee80211_band band;
 	unsigned int i = 0;
+	struct ath_softc *sc = (struct ath_softc *) common->priv;
 
 	band = hw->conf.channel->band;
 	sband = hw->wiphy->bands[band];
@@ -936,7 +942,7 @@ static int ath9k_process_rate(struct ath_common *common,
 	ath_dbg(common, ANY,
 		"unsupported hw bitrate detected 0x%02x using 1 Mbit\n",
 		rx_stats->rs_rate);
-
+	RX_STAT_INC(rx_rate_err);
 	return -EINVAL;
 }
 
@@ -1823,10 +1829,14 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 
 		hdr = (struct ieee80211_hdr *) (hdr_skb->data + rx_status_len);
 		rxs = IEEE80211_SKB_RXCB(hdr_skb);
-		if (ieee80211_is_beacon(hdr->frame_control) &&
-		    !is_zero_ether_addr(common->curbssid) &&
-		    !compare_ether_addr(hdr->addr3, common->curbssid))
-			rs.is_mybeacon = true;
+		if (ieee80211_is_beacon(hdr->frame_control)) {
+			RX_STAT_INC(rx_beacons);
+			if (!is_zero_ether_addr(common->curbssid) &&
+			    !compare_ether_addr(hdr->addr3, common->curbssid))
+				rs.is_mybeacon = true;
+			else
+				rs.is_mybeacon = false;
+		}
 		else
 			rs.is_mybeacon = false;
 
@@ -1836,8 +1846,10 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		 * If we're asked to flush receive queue, directly
 		 * chain it back at the queue without processing it.
 		 */
-		if (sc->sc_flags & SC_OP_RXFLUSH)
+		if (sc->sc_flags & SC_OP_RXFLUSH) {
+			RX_STAT_INC(rx_drop_rxflush);
 			goto requeue_drop_frag;
+		}
 
 		memset(rxs, 0, sizeof(struct ieee80211_rx_status));
 
@@ -1867,8 +1879,10 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		 * tell hardware it can give us a new frame using the old
 		 * skb and put it at the tail of the sc->rx.rxbuf list for
 		 * processing. */
-		if (!requeue_skb)
+		if (!requeue_skb) {
+			RX_STAT_INC(rx_oom_err);
 			goto requeue_drop_frag;
+		}
 
 		/* Unmap the frame */
 		dma_unmap_single(sc->dev, bf->bf_buf_addr,
@@ -1899,6 +1913,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 		}
 
 		if (rs.rs_more) {
+			RX_STAT_INC(rx_frags);
 			/*
 			 * rs_more indicates chained descriptors which can be
 			 * used to link buffers together for a sort of
@@ -1908,6 +1923,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 				/* too many fragments - cannot handle frame */
 				dev_kfree_skb_any(sc->rx.frag);
 				dev_kfree_skb_any(skb);
+				RX_STAT_INC(rx_too_many_frags_err);
 				skb = NULL;
 			}
 			sc->rx.frag = skb;
@@ -1919,6 +1935,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 
 			if (pskb_expand_head(hdr_skb, 0, space, GFP_ATOMIC) < 0) {
 				dev_kfree_skb(skb);
+				RX_STAT_INC(rx_oom_err);
 				goto requeue_drop_frag;
 			}
 
-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
