From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2010-02-26
Date: Fri, 26 Feb 2010 18:01:50 -0500
Message-ID: <20100226230149.GA10987@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is one final round of wireless bits for the 2.6.34 merge window.
Basically these would qualify as fixes anyway (more or less), but we
might as well get them in now.

Please let me know if there are problems!

Thanks!

John

---

The following changes since commit 8266d7127c1b0bdf924066c19c71be4d351e9583:
  Jeff Garzik (1):
        net: Delete isa-skeleton net driver

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Abhijeet Kolekar (1):
      iwlwifi: increase command buffer size

Felix Fietkau (1):
      ath9k: disable RIFS search for AR91xx based chips

Helmut Schaa (1):
      mac80211: use listen interval 5 as default

John W. Linville (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      netdevice.h: check for CONFIG_WLAN instead of CONFIG_WLAN_80211

Juuso Oikarinen (1):
      mac80211: fix direct probe loop on ieee80211_work_purge

Lennert Buytenhek (1):
      MAINTAINERS: update mwl8k maintenance status

Linus Torvalds (1):
      b43: fall back gracefully to PIO mode after fatal DMA errors

Reinette Chatre (1):
      Revert "iwlwifi: Monitor and recover the aggregation TX flow failure"

 MAINTAINERS                                 |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c         |   10 +++++
 drivers/net/wireless/ath/ath9k/phy.h        |    3 ++
 drivers/net/wireless/ath/ath9k/xmit.c       |    4 +-
 drivers/net/wireless/b43/Kconfig            |   17 ++++++++-
 drivers/net/wireless/b43/b43.h              |    7 ++++
 drivers/net/wireless/b43/main.c             |   14 ++++---
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    8 ++---
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   14 +-------
 drivers/net/wireless/iwlwifi/iwl-commands.h |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    3 --
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   51 ++------------------------
 drivers/net/wireless/iwlwifi/iwl-tx.c       |   33 ++++++++++++++---
 drivers/net/wireless/iwmc3200wifi/rx.c      |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c  |    1 +
 include/linux/netdevice.h                   |    2 +-
 net/mac80211/main.c                         |    6 +++-
 net/mac80211/rate.c                         |    3 ++
 net/mac80211/work.c                         |    1 +
 22 files changed, 100 insertions(+), 90 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 2b4a4d2..cb0a800 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3450,9 +3450,9 @@ F:	drivers/net/mv643xx_eth.*
 F:	include/linux/mv643xx.h
 
 MARVELL MWL8K WIRELESS DRIVER
-M:	Lennert Buytenhek <buytenh@marvell.com>
+M:	Lennert Buytenhek <buytenh@wantstofly.org>
 L:	linux-wireless@vger.kernel.org
-S:	Supported
+S:	Maintained
 F:	drivers/net/wireless/mwl8k.c
 
 MARVELL SOC MMC/SD/SDIO CONTROLLER DRIVER
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index f00f5c7..2e767cf 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1310,6 +1310,16 @@ static void ath9k_hw_override_ini(struct ath_hw *ah,
 	 * Necessary to avoid issues on AR5416 2.0
 	 */
 	REG_WRITE(ah, 0x9800 + (651 << 2), 0x11);
+
+	/*
+	 * Disable RIFS search on some chips to avoid baseband
+	 * hang issues.
+	 */
+	if (AR_SREV_9100(ah) || AR_SREV_9160(ah)) {
+		val = REG_READ(ah, AR_PHY_HEAVY_CLIP_FACTOR_RIFS);
+		val &= ~AR_PHY_RIFS_INIT_DELAY;
+		REG_WRITE(ah, AR_PHY_HEAVY_CLIP_FACTOR_RIFS, val);
+	}
 }
 
 static u32 ath9k_hw_def_ini_fixup(struct ath_hw *ah,
diff --git a/drivers/net/wireless/ath/ath9k/phy.h b/drivers/net/wireless/ath/ath9k/phy.h
index 31de27d..0999a49 100644
--- a/drivers/net/wireless/ath/ath9k/phy.h
+++ b/drivers/net/wireless/ath/ath9k/phy.h
@@ -384,6 +384,9 @@ bool ath9k_hw_set_rf_regs(struct ath_hw *ah,
 
 #define AR_PHY_HEAVY_CLIP_ENABLE         0x99E0
 
+#define AR_PHY_HEAVY_CLIP_FACTOR_RIFS    0x99EC
+#define AR_PHY_RIFS_INIT_DELAY         0x03ff0000
+
 #define AR_PHY_M_SLEEP      0x99f0
 #define AR_PHY_REFCLKDLY    0x99f4
 #define AR_PHY_REFCLKPD     0x99f8
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index f5cbbcb..47294f9 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1610,7 +1610,7 @@ static int ath_tx_setup_buffer(struct ieee80211_hw *hw, struct ath_buf *bf,
 		bf->bf_frmlen -= padsize;
 	}
 
-	if (conf_is_ht(&hw->conf) && !is_pae(skb))
+	if (conf_is_ht(&hw->conf))
 		bf->bf_state.bf_type |= BUF_HT;
 
 	bf->bf_flags = setup_tx_flags(sc, skb, txctl->txq);
@@ -1696,7 +1696,7 @@ static void ath_tx_start_dma(struct ath_softc *sc, struct ath_buf *bf,
 			goto tx_done;
 		}
 
-		if (tx_info->flags & IEEE80211_TX_CTL_AMPDU) {
+		if ((tx_info->flags & IEEE80211_TX_CTL_AMPDU) && !is_pae(skb)) {
 			/*
 			 * Try aggregation if it's a unicast data frame
 			 * and the destination is HT capable.
diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kconfig
index 073be56..0a00d42 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -3,7 +3,6 @@ config B43
 	depends on SSB_POSSIBLE && MAC80211 && HAS_DMA
 	select SSB
 	select FW_LOADER
-	select SSB_BLOCKIO
 	---help---
 	  b43 is a driver for the Broadcom 43xx series wireless devices.
 
@@ -79,6 +78,14 @@ config B43_SDIO
 
 	  If unsure, say N.
 
+#Data transfers to the device via PIO. We want it as a fallback even
+# if we can do DMA.
+config B43_PIO
+	bool
+	depends on B43
+	select SSB_BLOCKIO
+	default y
+
 config B43_NPHY
 	bool "Pre IEEE 802.11n support (BROKEN)"
 	depends on B43 && EXPERIMENTAL && BROKEN
@@ -130,4 +137,12 @@ config B43_DEBUG
 	  for production use.
 	  Only say Y, if you are debugging a problem in the b43 driver sourcecode.
 
+config B43_FORCE_PIO
+	bool "Force usage of PIO instead of DMA"
+	depends on B43 && B43_DEBUG
+	---help---
+	  This will disable DMA and always enable PIO instead.
 
+	  Say N!
+	  This is only for debugging the PIO engine code. You do
+	  _NOT_ want to enable this.
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index 6a6ab0f..b8807fb 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -702,6 +702,7 @@ struct b43_wldev {
 	bool radio_hw_enable;	/* saved state of radio hardware enabled state */
 	bool qos_enabled;		/* TRUE, if QoS is used. */
 	bool hwcrypto_enabled;		/* TRUE, if HW crypto acceleration is enabled. */
+	bool use_pio;			/* TRUE if next init should use PIO */
 
 	/* PHY/Radio device. */
 	struct b43_phy phy;
@@ -886,6 +887,12 @@ static inline bool b43_using_pio_transfers(struct b43_wldev *dev)
 	return dev->__using_pio_transfers;
 }
 
+#ifdef CONFIG_B43_FORCE_PIO
+# define B43_PIO_DEFAULT 1
+#else
+# define B43_PIO_DEFAULT 0
+#endif
+
 /* Message printing */
 void b43info(struct b43_wl *wl, const char *fmt, ...)
     __attribute__ ((format(printf, 2, 3)));
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 8f7a8c0..16580d0 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -107,9 +107,9 @@ int b43_modparam_verbose = B43_VERBOSITY_DEFAULT;
 module_param_named(verbose, b43_modparam_verbose, int, 0644);
 MODULE_PARM_DESC(verbose, "Log message verbosity: 0=error, 1=warn, 2=info(default), 3=debug");
 
-static int modparam_pio;
-module_param_named(pio, modparam_pio, int, 0444);
-MODULE_PARM_DESC(pio, "enable(1) / disable(0) PIO mode");
+int b43_modparam_pio = B43_PIO_DEFAULT;
+module_param_named(pio, b43_modparam_pio, int, 0644);
+MODULE_PARM_DESC(pio, "Use PIO accesses by default: 0=DMA, 1=PIO");
 
 static const struct ssb_device_id b43_ssb_tbl[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 5),
@@ -1804,8 +1804,9 @@ static void b43_do_interrupt_thread(struct b43_wldev *dev)
 			       dma_reason[4], dma_reason[5]);
 			b43err(dev->wl, "This device does not support DMA "
 			       "on your system. Please use PIO instead.\n");
-			b43err(dev->wl, "Unload the b43 module and reload "
-			       "with 'pio=1'\n");
+			/* Fall back to PIO transfers if we get fatal DMA errors! */
+			dev->use_pio = 1;
+			b43_controller_restart(dev, "DMA error");
 			return;
 		}
 		if (merged_dma_reason & B43_DMAIRQ_NONFATALMASK) {
@@ -4357,7 +4358,7 @@ static int b43_wireless_core_init(struct b43_wldev *dev)
 
 	if ((dev->dev->bus->bustype == SSB_BUSTYPE_PCMCIA) ||
 	    (dev->dev->bus->bustype == SSB_BUSTYPE_SDIO) ||
-	    modparam_pio) {
+	    dev->use_pio) {
 		dev->__using_pio_transfers = 1;
 		err = b43_pio_init(dev);
 	} else {
@@ -4824,6 +4825,7 @@ static int b43_one_core_attach(struct ssb_device *dev, struct b43_wl *wl)
 	if (!wldev)
 		goto out;
 
+	wldev->use_pio = b43_modparam_pio;
 	wldev->dev = dev;
 	wldev->wl = wl;
 	b43_set_status(wldev, B43_STAT_UNINIT);
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 17e91ad..1bd2cd8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2015,7 +2015,7 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 			IWL_DEBUG_TX_REPLY(priv, "Retry scheduler reclaim scd_ssn "
 					   "%d index %d\n", scd_ssn , index);
 			freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+			iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 			if (priv->mac80211_registered &&
 			    (iwl_queue_space(&txq->q) > txq->q.low_mark) &&
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 94fc836..e476acb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -1123,7 +1123,7 @@ static void iwl5000_rx_reply_tx(struct iwl_priv *priv,
 					scd_ssn , index, txq_id, txq->swq_id);
 
 			freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+			iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 			if (priv->mac80211_registered &&
 			    (iwl_queue_space(&txq->q) > txq->q.low_mark) &&
@@ -1151,16 +1151,14 @@ static void iwl5000_rx_reply_tx(struct iwl_priv *priv,
 				   tx_resp->failure_frame);
 
 		freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-		if (ieee80211_is_data_qos(tx_resp->frame_ctrl))
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+		iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 		if (priv->mac80211_registered &&
 		    (iwl_queue_space(&txq->q) > txq->q.low_mark))
 			iwl_wake_queue(priv, txq_id);
 	}
 
-	if (ieee80211_is_data_qos(tx_resp->frame_ctrl))
-		iwl_txq_check_empty(priv, sta_id, tid, txq_id);
+	iwl_txq_check_empty(priv, sta_id, tid, txq_id);
 
 	if (iwl_check_bits(status, TX_ABORT_REQUIRED_MSK))
 		IWL_ERR(priv, "TODO:  Implement Tx ABORT REQUIRED!!!\n");
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index c5b724e..1fac015 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2941,21 +2941,10 @@ static int iwl_mac_ampdu_action(struct ieee80211_hw *hw,
 			return ret;
 	case IEEE80211_AMPDU_TX_START:
 		IWL_DEBUG_HT(priv, "start Tx\n");
-		ret = iwl_tx_agg_start(priv, sta->addr, tid, ssn);
-		if (ret == 0) {
-			priv->agg_tids_count++;
-			IWL_DEBUG_HT(priv, "priv->agg_tids_count = %u\n",
-				priv->agg_tids_count);
-		}
-		return ret;
+		return iwl_tx_agg_start(priv, sta->addr, tid, ssn);
 	case IEEE80211_AMPDU_TX_STOP:
 		IWL_DEBUG_HT(priv, "stop Tx\n");
 		ret = iwl_tx_agg_stop(priv, sta->addr, tid);
-		if ((ret == 0) && (priv->agg_tids_count > 0)) {
-			priv->agg_tids_count--;
-			IWL_DEBUG_HT(priv, "priv->agg_tids_count = %u\n",
-				priv->agg_tids_count);
-		}
 		if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 			return 0;
 		else
@@ -3376,7 +3365,6 @@ static int iwl_init_drv(struct iwl_priv *priv)
 	priv->iw_mode = NL80211_IFTYPE_STATION;
 	priv->current_ht_config.smps = IEEE80211_SMPS_STATIC;
 	priv->missed_beacon_threshold = IWL_MISSED_BEACON_THRESHOLD_DEF;
-	priv->agg_tids_count = 0;
 
 	/* initialize force reset */
 	priv->force_reset[IWL_RF_RESET].reset_duration =
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index ab3c77b..6383d9f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -2623,6 +2623,7 @@ struct iwl_ssid_ie {
 #define TX_CMD_LIFE_TIME_INFINITE	cpu_to_le32(0xFFFFFFFF)
 #define IWL_GOOD_CRC_TH			cpu_to_le16(1)
 #define IWL_MAX_SCAN_SIZE 1024
+#define IWL_MAX_CMD_SIZE 4096
 #define IWL_MAX_PROBE_REQUEST		200
 
 /*
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 55252a6..112149e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -2787,8 +2787,8 @@ int iwl_mac_config(struct ieee80211_hw *hw, u32 changed)
 		if ((le16_to_cpu(priv->staging_rxon.channel) != ch))
 			priv->staging_rxon.flags = 0;
 
-		iwl_set_rxon_ht(priv, ht_conf);
 		iwl_set_rxon_channel(priv, conf->channel);
+		iwl_set_rxon_ht(priv, ht_conf);
 
 		iwl_set_flags_for_band(priv, conf->channel->band);
 		spin_unlock_irqrestore(&priv->lock, flags);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 3df7933..4ef7739 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -451,6 +451,8 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb);
 void iwl_hw_txq_ctx_free(struct iwl_priv *priv);
 int iwl_hw_tx_queue_init(struct iwl_priv *priv,
 			 struct iwl_tx_queue *txq);
+void iwl_free_tfds_in_queue(struct iwl_priv *priv,
+			    int sta_id, int tid, int freed);
 void iwl_txq_update_write_ptr(struct iwl_priv *priv, struct iwl_tx_queue *txq);
 int iwl_tx_queue_init(struct iwl_priv *priv, struct iwl_tx_queue *txq,
 		      int slots_num, u32 txq_id);
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index 7914d65..ab891b9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -1084,9 +1084,6 @@ struct iwl_priv {
 	/* storing the jiffies when the plcp error rate is received */
 	unsigned long plcp_jiffies;
 
-	/* reporting the number of tids has AGG on. 0 means no AGGREGATION */
-	u8 agg_tids_count;
-
 	/* force reset */
 	struct iwl_force_reset force_reset[IWL_MAX_FORCE_RESET];
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index fed554a..df257bc 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -616,11 +616,6 @@ static void iwl_accumulative_statistics(struct iwl_priv *priv,
 
 #define REG_RECALIB_PERIOD (60)
 
-/* the threshold ratio of actual_ack_cnt to expected_ack_cnt in percent */
-#define ACK_CNT_RATIO (50)
-#define BA_TIMEOUT_CNT (5)
-#define BA_TIMEOUT_MAX (16)
-
 #define PLCP_MSG "plcp_err exceeded %u, %u, %u, %u, %u, %d, %u mSecs\n"
 void iwl_rx_statistics(struct iwl_priv *priv,
 			      struct iwl_rx_mem_buffer *rxb)
@@ -630,9 +625,6 @@ void iwl_rx_statistics(struct iwl_priv *priv,
 	int combined_plcp_delta;
 	unsigned int plcp_msec;
 	unsigned long plcp_received_jiffies;
-	int actual_ack_cnt_delta;
-	int expected_ack_cnt_delta;
-	int ba_timeout_delta;
 
 	IWL_DEBUG_RX(priv, "Statistics notification received (%d vs %d).\n",
 		     (int)sizeof(priv->statistics),
@@ -647,44 +639,6 @@ void iwl_rx_statistics(struct iwl_priv *priv,
 #ifdef CONFIG_IWLWIFI_DEBUG
 	iwl_accumulative_statistics(priv, (__le32 *)&pkt->u.stats);
 #endif
-	actual_ack_cnt_delta = le32_to_cpu(pkt->u.stats.tx.actual_ack_cnt) -
-		le32_to_cpu(priv->statistics.tx.actual_ack_cnt);
-	expected_ack_cnt_delta = le32_to_cpu(
-			pkt->u.stats.tx.expected_ack_cnt) -
-		le32_to_cpu(priv->statistics.tx.expected_ack_cnt);
-	ba_timeout_delta = le32_to_cpu(
-			pkt->u.stats.tx.agg.ba_timeout) -
-		le32_to_cpu(priv->statistics.tx.agg.ba_timeout);
-	if ((priv->agg_tids_count > 0) &&
-		(expected_ack_cnt_delta > 0) &&
-		(((actual_ack_cnt_delta * 100) / expected_ack_cnt_delta) <
-			ACK_CNT_RATIO) &&
-		(ba_timeout_delta > BA_TIMEOUT_CNT)) {
-		IWL_DEBUG_RADIO(priv,
-			"actual_ack_cnt delta = %d, expected_ack_cnt = %d\n",
-			actual_ack_cnt_delta, expected_ack_cnt_delta);
-
-#ifdef CONFIG_IWLWIFI_DEBUG
-		IWL_DEBUG_RADIO(priv, "rx_detected_cnt delta = %d\n",
-			priv->delta_statistics.tx.rx_detected_cnt);
-		IWL_DEBUG_RADIO(priv,
-			"ack_or_ba_timeout_collision delta = %d\n",
-			priv->delta_statistics.tx.ack_or_ba_timeout_collision);
-#endif
-		IWL_DEBUG_RADIO(priv, "agg ba_timeout delta = %d\n",
-			ba_timeout_delta);
-		if ((actual_ack_cnt_delta == 0) &&
-			(ba_timeout_delta >=
-				BA_TIMEOUT_MAX)) {
-			IWL_DEBUG_RADIO(priv,
-				"call iwl_force_reset(IWL_FW_RESET)\n");
-			iwl_force_reset(priv, IWL_FW_RESET);
-		} else {
-			IWL_DEBUG_RADIO(priv,
-				"call iwl_force_reset(IWL_RF_RESET)\n");
-			iwl_force_reset(priv, IWL_RF_RESET);
-		}
-	}
 	/*
 	 * check for plcp_err and trigger radio reset if it exceeds
 	 * the plcp error threshold plcp_delta.
@@ -1054,7 +1008,10 @@ static void iwl_pass_packet_to_mac80211(struct iwl_priv *priv,
 	if (ieee80211_is_mgmt(fc) ||
 	    ieee80211_has_protected(fc) ||
 	    ieee80211_has_morefrags(fc) ||
-	    le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG)
+	    le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG ||
+	    (ieee80211_is_data_qos(fc) &&
+	     *ieee80211_get_qos_ctl(hdr) &
+	     IEEE80211_QOS_CONTROL_A_MSDU_PRESENT))
 		ret = skb_linearize(skb);
 	else
 		ret = __pskb_pull_tail(skb, min_t(u16, IWL_LINK_HDR_MAX, len)) ?
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 38655ad..1ed5206 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -118,6 +118,20 @@ void iwl_txq_update_write_ptr(struct iwl_priv *priv, struct iwl_tx_queue *txq)
 EXPORT_SYMBOL(iwl_txq_update_write_ptr);
 
 
+void iwl_free_tfds_in_queue(struct iwl_priv *priv,
+			    int sta_id, int tid, int freed)
+{
+	if (priv->stations[sta_id].tid[tid].tfds_in_queue >= freed)
+		priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+	else {
+		IWL_ERR(priv, "free more than tfds_in_queue (%u:%d)\n",
+			priv->stations[sta_id].tid[tid].tfds_in_queue,
+			freed);
+		priv->stations[sta_id].tid[tid].tfds_in_queue = 0;
+	}
+}
+EXPORT_SYMBOL(iwl_free_tfds_in_queue);
+
 /**
  * iwl_tx_queue_free - Deallocate DMA queue.
  * @txq: Transmit queue to deallocate.
@@ -350,7 +364,7 @@ int iwl_tx_queue_init(struct iwl_priv *priv, struct iwl_tx_queue *txq,
 	for (i = 0; i < actual_slots; i++) {
 		/* only happens for cmd queue */
 		if (i == slots_num)
-			len += IWL_MAX_SCAN_SIZE;
+			len = IWL_MAX_CMD_SIZE;
 
 		txq->cmd[i] = kmalloc(len, GFP_KERNEL);
 		if (!txq->cmd[i])
@@ -1009,9 +1023,12 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 
 	/* If any of the command structures end up being larger than
 	 * the TFD_MAX_PAYLOAD_SIZE, and it sent as a 'small' command then
-	 * we will need to increase the size of the TFD entries */
+	 * we will need to increase the size of the TFD entries
+	 * Also, check to see if command buffer should not exceed the size
+	 * of device_cmd and max_cmd_size. */
 	BUG_ON((fix_size > TFD_MAX_PAYLOAD_SIZE) &&
 	       !(cmd->flags & CMD_SIZE_HUGE));
+	BUG_ON(fix_size > IWL_MAX_CMD_SIZE);
 
 	if (iwl_is_rfkill(priv) || iwl_is_ctkill(priv)) {
 		IWL_WARN(priv, "Not sending command - %s KILL\n",
@@ -1055,8 +1072,8 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 	if (cmd->flags & CMD_SIZE_HUGE)
 		out_cmd->hdr.sequence |= SEQ_HUGE_FRAME;
 	len = sizeof(struct iwl_device_cmd);
-	len += (idx == TFD_CMD_SLOTS) ?  IWL_MAX_SCAN_SIZE : 0;
-
+	if (idx == TFD_CMD_SLOTS)
+		len = IWL_MAX_CMD_SIZE;
 
 #ifdef CONFIG_IWLWIFI_DEBUG
 	switch (out_cmd->hdr.cmd) {
@@ -1127,6 +1144,7 @@ int iwl_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 	struct iwl_queue *q = &txq->q;
 	struct iwl_tx_info *tx_info;
 	int nfreed = 0;
+	struct ieee80211_hdr *hdr;
 
 	if ((index >= q->n_bd) || (iwl_queue_used(q, index) == 0)) {
 		IWL_ERR(priv, "Read index for DMA queue txq id (%d), index %d, "
@@ -1141,13 +1159,16 @@ int iwl_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 
 		tx_info = &txq->txb[txq->q.read_ptr];
 		iwl_tx_status(priv, tx_info->skb[0]);
+
+		hdr = (struct ieee80211_hdr *)tx_info->skb[0]->data;
+		if (hdr && ieee80211_is_data_qos(hdr->frame_control))
+			nfreed++;
 		tx_info->skb[0] = NULL;
 
 		if (priv->cfg->ops->lib->txq_inval_byte_cnt_tbl)
 			priv->cfg->ops->lib->txq_inval_byte_cnt_tbl(priv, txq);
 
 		priv->cfg->ops->lib->txq_free_tfd(priv, txq);
-		nfreed++;
 	}
 	return nfreed;
 }
@@ -1561,7 +1582,7 @@ void iwl_rx_reply_compressed_ba(struct iwl_priv *priv,
 	if (txq->q.read_ptr != (ba_resp_scd_ssn & 0xff)) {
 		/* calculate mac80211 ampdu sw queue to wake */
 		int freed = iwl_tx_queue_reclaim(priv, scd_flow, index);
-		priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+		iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 		if ((iwl_queue_space(&txq->q) > txq->q.low_mark) &&
 		    priv->mac80211_registered &&
diff --git a/drivers/net/wireless/iwmc3200wifi/rx.c b/drivers/net/wireless/iwmc3200wifi/rx.c
index fd399e6..6b53ae1 100644
--- a/drivers/net/wireless/iwmc3200wifi/rx.c
+++ b/drivers/net/wireless/iwmc3200wifi/rx.c
@@ -794,7 +794,7 @@ static int iwm_mlme_update_bss_table(struct iwm_priv *iwm, u8 *buf,
 	}
 
 	bss->bss = kzalloc(bss_len, GFP_KERNEL);
-	if (!bss) {
+	if (!bss->bss) {
 		kfree(bss);
 		IWM_ERR(iwm, "Couldn't allocate bss\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index a053825..0fb850e 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -65,6 +65,7 @@ static struct usb_device_id rtl8187_table[] __devinitdata = {
 	/* Sitecom */
 	{USB_DEVICE(0x0df6, 0x000d), .driver_info = DEVICE_RTL8187},
 	{USB_DEVICE(0x0df6, 0x0028), .driver_info = DEVICE_RTL8187B},
+	{USB_DEVICE(0x0df6, 0x0029), .driver_info = DEVICE_RTL8187B},
 	/* Sphairon Access Systems GmbH */
 	{USB_DEVICE(0x114B, 0x0150), .driver_info = DEVICE_RTL8187},
 	/* Dick Smith Electronics */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..99914e6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -136,7 +136,7 @@ static inline bool dev_xmit_complete(int rc)
  *	used.
  */
 
-#if defined(CONFIG_WLAN_80211) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if defined(CONFIG_WLAN) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 # if defined(CONFIG_MAC80211_MESH)
 #  define LL_MAX_HEADER 128
 # else
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index ec8f767..06c33b6 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -558,8 +558,12 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	debugfs_hw_add(local);
 
+	/*
+	 * if the driver doesn't specify a max listen interval we
+	 * use 5 which should be a safe default
+	 */
 	if (local->hw.max_listen_interval == 0)
-		local->hw.max_listen_interval = 1;
+		local->hw.max_listen_interval = 5;
 
 	local->hw.conf.listen_interval = local->hw.max_listen_interval;
 
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 99ab24c..0b299d2 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -303,6 +303,9 @@ void rate_control_get_rate(struct ieee80211_sub_if_data *sdata,
 		info->control.rates[i].count = 1;
 	}
 
+	if (sdata->local->hw.flags & IEEE80211_HW_HAS_RATE_CONTROL)
+		return;
+
 	ref->ops->get_rate(ref->priv, ista, priv_sta, txrc);
 
 	/*
diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index 7e708d5..1e1ea30 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -869,6 +869,7 @@ static void ieee80211_work_work(struct work_struct *work)
 			break;
 		case IEEE80211_WORK_ABORT:
 			rma = WORK_ACT_TIMEOUT;
+			break;
 		case IEEE80211_WORK_DIRECT_PROBE:
 			rma = ieee80211_direct_probe(wk);
 			break;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
