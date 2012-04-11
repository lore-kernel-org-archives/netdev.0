From: greearb@candelatech.com
Subject: [PATCH 04/10] ath9k: Support ethtool getstats api.
Date: Wed, 11 Apr 2012 10:52:12 -0700
Message-ID: <1334166738-28243-5-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40897 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932416Ab2DKRxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:53:07 -0400
In-Reply-To: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This returns many of the values that formerly could
only be obtained from debugfs.  This should be an
improvement when trying to access these counters
programatically.  Currently this support is only
enabled when DEBUGFS is enabled because otherwise
these stats are not accumulated.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 ba5af8e... 39f8f7c... M	drivers/net/wireless/ath/ath9k/main.c
 drivers/net/wireless/ath/ath9k/main.c |  134 +++++++++++++++++++++++++++++++++
 1 files changed, 134 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index ba5af8e..39f8f7c 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2404,6 +2404,134 @@ static int ath9k_get_antenna(struct ieee80211_hw *hw, u32 *tx_ant, u32 *rx_ant)
 	return 0;
 }
 
+#ifdef CONFIG_ATH9K_DEBUGFS
+
+/* Ethtool support for get-stats */
+
+#define AMKSTR(nm) #nm "_BE", #nm "_BK", #nm "_VI", #nm "_VO"
+static const char ath9k_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"tx_pkts_nic",
+	"tx_bytes_nic",
+	"rx_pkts_nic",
+	"rx_bytes_nic",
+	AMKSTR(d_tx_pkts),
+	AMKSTR(d_tx_bytes),
+	AMKSTR(d_tx_mpdus_queued),
+	AMKSTR(d_tx_mpdus_completed),
+	AMKSTR(d_tx_mpdu_xretries),
+	AMKSTR(d_tx_aggregates),
+	AMKSTR(d_tx_ampdus_queued_hw),
+	AMKSTR(d_tx_ampdus_queued_sw),
+	AMKSTR(d_tx_ampdus_completed),
+	AMKSTR(d_tx_ampdu_retries),
+	AMKSTR(d_tx_ampdu_xretries),
+	AMKSTR(d_tx_fifo_underrun),
+	AMKSTR(d_tx_op_exceeded),
+	AMKSTR(d_tx_timer_expiry),
+	AMKSTR(d_tx_desc_cfg_err),
+	AMKSTR(d_tx_data_underrun),
+	AMKSTR(d_tx_delim_underrun),
+
+	"d_rx_decrypt_crc_err",
+	"d_rx_phy_err",
+	"d_rx_mic_err",
+	"d_rx_pre_delim_crc_err",
+	"d_rx_post_delim_crc_err",
+	"d_rx_decrypt_busy_err",
+
+	"d_rx_phyerr_radar",
+	"d_rx_phyerr_ofdm_timing",
+	"d_rx_phyerr_cck_timing",
+
+};
+#define ATH9K_SSTATS_LEN ARRAY_SIZE(ath9k_gstrings_stats)
+
+static void ath9k_get_et_strings(struct ieee80211_hw *hw,
+				 struct ieee80211_vif *vif,
+				 u32 sset, u8 *data)
+{
+	if (sset == ETH_SS_STATS)
+		memcpy(data, *ath9k_gstrings_stats,
+		       sizeof(ath9k_gstrings_stats));
+}
+
+static int ath9k_get_et_sset_count(struct ieee80211_hw *hw,
+				   struct ieee80211_vif *vif, int sset)
+{
+	if (sset == ETH_SS_STATS)
+		return ATH9K_SSTATS_LEN;
+	return 0;
+}
+
+#define PR_QNUM(_n) (sc->tx.txq_map[_n]->axq_qnum)
+#define AWDATA(elem)							\
+	do {								\
+		data[i++] = sc->debug.stats.txstats[PR_QNUM(WME_AC_BE)].elem; \
+		data[i++] = sc->debug.stats.txstats[PR_QNUM(WME_AC_BK)].elem; \
+		data[i++] = sc->debug.stats.txstats[PR_QNUM(WME_AC_VI)].elem; \
+		data[i++] = sc->debug.stats.txstats[PR_QNUM(WME_AC_VO)].elem; \
+	} while (0)
+
+#define AWDATA_RX(elem)						\
+	do {							\
+		data[i++] = sc->debug.stats.rxstats.elem;	\
+	} while (0)
+
+static void ath9k_get_et_stats(struct ieee80211_hw *hw,
+			       struct ieee80211_vif *vif,
+			       struct ethtool_stats *stats, u64 *data)
+{
+	struct ath_softc *sc = hw->priv;
+	int i = 0;
+
+	data[i++] = (sc->debug.stats.txstats[PR_QNUM(WME_AC_BE)].tx_pkts_all +
+		     sc->debug.stats.txstats[PR_QNUM(WME_AC_BK)].tx_pkts_all +
+		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VI)].tx_pkts_all +
+		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VO)].tx_pkts_all);
+	data[i++] = (sc->debug.stats.txstats[PR_QNUM(WME_AC_BE)].tx_bytes_all +
+		     sc->debug.stats.txstats[PR_QNUM(WME_AC_BK)].tx_bytes_all +
+		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VI)].tx_bytes_all +
+		     sc->debug.stats.txstats[PR_QNUM(WME_AC_VO)].tx_bytes_all);
+	AWDATA_RX(rx_pkts_all);
+	AWDATA_RX(rx_bytes_all);
+
+	AWDATA(tx_pkts_all);
+	AWDATA(tx_bytes_all);
+	AWDATA(queued);
+	AWDATA(completed);
+	AWDATA(xretries);
+	AWDATA(a_aggr);
+	AWDATA(a_queued_hw);
+	AWDATA(a_queued_sw);
+	AWDATA(a_completed);
+	AWDATA(a_retries);
+	AWDATA(a_xretries);
+	AWDATA(fifo_underrun);
+	AWDATA(xtxop);
+	AWDATA(timer_exp);
+	AWDATA(desc_cfg_err);
+	AWDATA(data_underrun);
+	AWDATA(delim_underrun);
+
+	AWDATA_RX(decrypt_crc_err);
+	AWDATA_RX(phy_err);
+	AWDATA_RX(mic_err);
+	AWDATA_RX(pre_delim_crc_err);
+	AWDATA_RX(post_delim_crc_err);
+	AWDATA_RX(decrypt_busy_err);
+
+	AWDATA_RX(phy_err_stats[ATH9K_PHYERR_RADAR]);
+	AWDATA_RX(phy_err_stats[ATH9K_PHYERR_OFDM_TIMING]);
+	AWDATA_RX(phy_err_stats[ATH9K_PHYERR_CCK_TIMING]);
+
+	BUG_ON(i != ATH9K_SSTATS_LEN);
+}
+
+/* End of ethtool get-stats functions */
+
+#endif
+
+
 struct ieee80211_ops ath9k_ops = {
 	.tx 		    = ath9k_tx,
 	.start 		    = ath9k_start,
@@ -2432,4 +2560,10 @@ struct ieee80211_ops ath9k_ops = {
 	.get_stats	    = ath9k_get_stats,
 	.set_antenna	    = ath9k_set_antenna,
 	.get_antenna	    = ath9k_get_antenna,
+
+#ifdef CONFIG_ATH9K_DEBUGFS
+	.get_et_sset_count  = ath9k_get_et_sset_count,
+	.get_et_stats  = ath9k_get_et_stats,
+	.get_et_strings  = ath9k_get_et_strings,
+#endif
 };
-- 
1.7.3.4
