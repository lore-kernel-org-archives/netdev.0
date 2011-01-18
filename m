From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-01-18
Date: Tue, 18 Jan 2011 15:21:35 -0500
Message-ID: <20110118202135.GA15402@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch of fixes intended for 2.6.38.  Included are a
locking fix, and endian fix, a lockdep fix, an error code fix, a memory
leak fix, a type fix, and a couple of others.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 16c0f9362433a76f01d174bb8b9c87b9a96198ee:

  qeth: l3 hw tx csum circumvent hw bug (2011-01-15 20:45:57 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Amitkumar Karwar (1):
      ieee80211: correct IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK macro

Axel Lin (1):
      iwmc3200wifi: Return proper error for iwm_if_alloc

Bob Copeland (1):
      ath5k: fix locking in tx_complete_poll_work

Jesper Juhl (1):
      rt2x00: Don't leak mem in error path of rt2x00lib_request_firmware()

Johannes Berg (1):
      mac80211: fix lockdep warning

Luciano Coelho (1):
      mac80211: use maximum number of AMPDU frames as default in BA RX

Luis R. Rodriguez (1):
      ath9k_hw: ASPM interoperability fix for AR9380/AR9382

Rajkumar Manoharan (2):
      ath9k_htc: Fix endian issue in tx header
      ath9k_hw: do PA offset calibration only on longcal interval

Wey-Yi Guy (1):
      iwlwifi: fix valid chain reading from EEPROM

 drivers/net/wireless/ath/ath5k/base.c              |    4 ++++
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   10 +++++-----
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    4 ++--
 drivers/net/wireless/ath/ath9k/htc.h               |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    8 +++++---
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |    2 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c         |    2 ++
 drivers/net/wireless/rt2x00/rt2x00firmware.c       |    1 +
 include/linux/ieee80211.h                          |    2 +-
 net/mac80211/agg-rx.c                              |   11 ++---------
 net/mac80211/main.c                                |   12 +++++++++++-
 12 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 019a74d..09ae4ef 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -2294,6 +2294,8 @@ ath5k_tx_complete_poll_work(struct work_struct *work)
 	int i;
 	bool needreset = false;
 
+	mutex_lock(&sc->lock);
+
 	for (i = 0; i < ARRAY_SIZE(sc->txqs); i++) {
 		if (sc->txqs[i].setup) {
 			txq = &sc->txqs[i];
@@ -2321,6 +2323,8 @@ ath5k_tx_complete_poll_work(struct work_struct *work)
 		ath5k_reset(sc, NULL, true);
 	}
 
+	mutex_unlock(&sc->lock);
+
 	ieee80211_queue_delayed_work(sc->hw, &sc->tx_complete_work,
 		msecs_to_jiffies(ATH5K_TX_COMPLETE_POLL_INT));
 }
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index ea2e7d7..5e300bd 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -679,10 +679,6 @@ static bool ar9002_hw_calibrate(struct ath_hw *ah,
 
 	/* Do NF cal only at longer intervals */
 	if (longcal || nfcal_pending) {
-		/* Do periodic PAOffset Cal */
-		ar9002_hw_pa_cal(ah, false);
-		ar9002_hw_olc_temp_compensation(ah);
-
 		/*
 		 * Get the value from the previous NF cal and update
 		 * history buffer.
@@ -697,8 +693,12 @@ static bool ar9002_hw_calibrate(struct ath_hw *ah,
 			ath9k_hw_loadnf(ah, ah->curchan);
 		}
 
-		if (longcal)
+		if (longcal) {
 			ath9k_hw_start_nfcal(ah, false);
+			/* Do periodic PAOffset Cal */
+			ar9002_hw_pa_cal(ah, false);
+			ar9002_hw_olc_temp_compensation(ah);
+		}
 	}
 
 	return iscaldone;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
index 81f9cf2..9ecca93 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
@@ -1842,7 +1842,7 @@ static const u32 ar9300_2p2_soc_preamble[][2] = {
 
 static const u32 ar9300PciePhy_pll_on_clkreq_disable_L1_2p2[][2] = {
 	/* Addr      allmodes  */
-	{0x00004040, 0x08212e5e},
+	{0x00004040, 0x0821265e},
 	{0x00004040, 0x0008003b},
 	{0x00004044, 0x00000000},
 };
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_hw.c b/drivers/net/wireless/ath/ath9k/ar9003_hw.c
index 6137634..06fb2c8 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_hw.c
@@ -146,8 +146,8 @@ static void ar9003_hw_init_mode_regs(struct ath_hw *ah)
 		/* Sleep Setting */
 
 		INIT_INI_ARRAY(&ah->iniPcieSerdesLowPower,
-				ar9300PciePhy_clkreq_enable_L1_2p2,
-				ARRAY_SIZE(ar9300PciePhy_clkreq_enable_L1_2p2),
+				ar9300PciePhy_pll_on_clkreq_disable_L1_2p2,
+				ARRAY_SIZE(ar9300PciePhy_pll_on_clkreq_disable_L1_2p2),
 				2);
 
 		/* Fast clock modal settings */
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 1ce506f..780ac5e 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -78,7 +78,7 @@ struct tx_frame_hdr {
 	u8 node_idx;
 	u8 vif_idx;
 	u8 tidno;
-	u32 flags; /* ATH9K_HTC_TX_* */
+	__be32 flags; /* ATH9K_HTC_TX_* */
 	u8 key_type;
 	u8 keyix;
 	u8 reserved[26];
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 33f3602..7a5ffca 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -113,6 +113,7 @@ int ath9k_htc_tx_start(struct ath9k_htc_priv *priv, struct sk_buff *skb)
 
 	if (ieee80211_is_data(fc)) {
 		struct tx_frame_hdr tx_hdr;
+		u32 flags = 0;
 		u8 *qc;
 
 		memset(&tx_hdr, 0, sizeof(struct tx_frame_hdr));
@@ -136,13 +137,14 @@ int ath9k_htc_tx_start(struct ath9k_htc_priv *priv, struct sk_buff *skb)
 		/* Check for RTS protection */
 		if (priv->hw->wiphy->rts_threshold != (u32) -1)
 			if (skb->len > priv->hw->wiphy->rts_threshold)
-				tx_hdr.flags |= ATH9K_HTC_TX_RTSCTS;
+				flags |= ATH9K_HTC_TX_RTSCTS;
 
 		/* CTS-to-self */
-		if (!(tx_hdr.flags & ATH9K_HTC_TX_RTSCTS) &&
+		if (!(flags & ATH9K_HTC_TX_RTSCTS) &&
 		    (priv->op_flags & OP_PROTECT_ENABLE))
-			tx_hdr.flags |= ATH9K_HTC_TX_CTSONLY;
+			flags |= ATH9K_HTC_TX_CTSONLY;
 
+		tx_hdr.flags = cpu_to_be32(flags);
 		tx_hdr.key_type = ath9k_cmn_get_hw_crypto_keytype(skb);
 		if (tx_hdr.key_type == ATH9K_KEY_TYPE_CLEAR)
 			tx_hdr.keyix = (u8) ATH9K_TXKEYIX_INVALID;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c b/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
index 97906dd..14ceb4d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
@@ -168,7 +168,7 @@ int iwl_eeprom_check_sku(struct iwl_priv *priv)
 		/* not using .cfg overwrite */
 		radio_cfg = iwl_eeprom_query16(priv, EEPROM_RADIO_CONFIG);
 		priv->cfg->valid_tx_ant = EEPROM_RF_CFG_TX_ANT_MSK(radio_cfg);
-		priv->cfg->valid_rx_ant = EEPROM_RF_CFG_TX_ANT_MSK(radio_cfg);
+		priv->cfg->valid_rx_ant = EEPROM_RF_CFG_RX_ANT_MSK(radio_cfg);
 		if (!priv->cfg->valid_tx_ant || !priv->cfg->valid_rx_ant) {
 			IWL_ERR(priv, "Invalid chain (0X%x, 0X%x)\n",
 				priv->cfg->valid_tx_ant,
diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/wireless/iwmc3200wifi/netdev.c
index 13a69eb..5091d77 100644
--- a/drivers/net/wireless/iwmc3200wifi/netdev.c
+++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
@@ -126,6 +126,7 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 	ndev = alloc_netdev_mq(0, "wlan%d", ether_setup, IWM_TX_QUEUES);
 	if (!ndev) {
 		dev_err(dev, "no memory for network device instance\n");
+		ret = -ENOMEM;
 		goto out_priv;
 	}
 
@@ -138,6 +139,7 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
 				    GFP_KERNEL);
 	if (!iwm->umac_profile) {
 		dev_err(dev, "Couldn't alloc memory for profile\n");
+		ret = -ENOMEM;
 		goto out_profile;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00firmware.c b/drivers/net/wireless/rt2x00/rt2x00firmware.c
index f0e1eb7..be0ff78 100644
--- a/drivers/net/wireless/rt2x00/rt2x00firmware.c
+++ b/drivers/net/wireless/rt2x00/rt2x00firmware.c
@@ -58,6 +58,7 @@ static int rt2x00lib_request_firmware(struct rt2x00_dev *rt2x00dev)
 
 	if (!fw || !fw->size || !fw->data) {
 		ERROR(rt2x00dev, "Failed to read Firmware.\n");
+		release_firmware(fw);
 		return -ENOENT;
 	}
 
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 6042228..294169e 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -959,7 +959,7 @@ struct ieee80211_ht_info {
 /* block-ack parameters */
 #define IEEE80211_ADDBA_PARAM_POLICY_MASK 0x0002
 #define IEEE80211_ADDBA_PARAM_TID_MASK 0x003C
-#define IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK 0xFFA0
+#define IEEE80211_ADDBA_PARAM_BUF_SIZE_MASK 0xFFC0
 #define IEEE80211_DELBA_PARAM_TID_MASK 0xF000
 #define IEEE80211_DELBA_PARAM_INITIATOR_MASK 0x0800
 
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index f138b19..227ca82 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -185,8 +185,6 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 				     struct ieee80211_mgmt *mgmt,
 				     size_t len)
 {
-	struct ieee80211_hw *hw = &local->hw;
-	struct ieee80211_conf *conf = &hw->conf;
 	struct tid_ampdu_rx *tid_agg_rx;
 	u16 capab, tid, timeout, ba_policy, buf_size, start_seq_num, status;
 	u8 dialog_token;
@@ -231,13 +229,8 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 		goto end_no_lock;
 	}
 	/* determine default buffer size */
-	if (buf_size == 0) {
-		struct ieee80211_supported_band *sband;
-
-		sband = local->hw.wiphy->bands[conf->channel->band];
-		buf_size = IEEE80211_MIN_AMPDU_BUF;
-		buf_size = buf_size << sband->ht_cap.ampdu_factor;
-	}
+	if (buf_size == 0)
+		buf_size = IEEE80211_MAX_AMPDU_BUF;
 
 
 	/* examine state machine */
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 485d36b..a46ff06 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -39,6 +39,8 @@ module_param(ieee80211_disable_40mhz_24ghz, bool, 0644);
 MODULE_PARM_DESC(ieee80211_disable_40mhz_24ghz,
 		 "Disable 40MHz support in the 2.4GHz band");
 
+static struct lock_class_key ieee80211_rx_skb_queue_class;
+
 void ieee80211_configure_filter(struct ieee80211_local *local)
 {
 	u64 mc;
@@ -569,7 +571,15 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	spin_lock_init(&local->filter_lock);
 	spin_lock_init(&local->queue_stop_reason_lock);
 
-	skb_queue_head_init(&local->rx_skb_queue);
+	/*
+	 * The rx_skb_queue is only accessed from tasklets,
+	 * but other SKB queues are used from within IRQ
+	 * context. Therefore, this one needs a different
+	 * locking class so our direct, non-irq-safe use of
+	 * the queue's lock doesn't throw lockdep warnings.
+	 */
+	skb_queue_head_init_class(&local->rx_skb_queue,
+				  &ieee80211_rx_skb_queue_class);
 
 	INIT_DELAYED_WORK(&local->scan_work, ieee80211_scan_work);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
