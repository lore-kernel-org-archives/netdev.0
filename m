From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-09-15
Date: Thu, 15 Sep 2011 15:48:15 -0400
Message-ID: <20110915194814.GC24589@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60558 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934532Ab1IOUA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 16:00:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a batch of fixes intended for 3.1.  Included is a calibration
fix for ath9k that avoids a hang, a couple of rtlwifi fixes for
connection failures, a mac80211 locking fix, a couple of iwlagn fixes
(including a corruption fix), an ath9k oops fix, an initialization
fix for AR9330 hardware in ath9k, and a patch to avoid a needless
BUG_ON in iwlegacy.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 31dda0ae933bb9fea9cfe000b698c41af0417cac:

  net: don't clear IFF_XMIT_DST_RELEASE in ether_setup (2011-09-15 14:49:44 -0400)

are available in the git repository at:
  git://git.infradead.org/users/linville/wireless.git for-davem

Felix Fietkau (1):
      ath9k_hw: fix calibration on 5 ghz

George (2):
      rtlwifi: rtl8192su: Fix problem connecting to HT-enabled AP
      rtlwifi: Fix problem when switching connections

Johannes Berg (3):
      mac80211: fix missing sta_lock in __sta_info_destroy
      iwlagn: fix stack corruption
      iwlagn: fix command queue timeout

John W. Linville (1):
      Merge branch 'master' of git://git.infradead.org/users/linville/wireless into for-davem

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic on unplugging the device

Rajkumar Manoharan (1):
      ath9k_hw: Fix init mode register regression

Stanislaw Gruszka (1):
      iwlegacy: fix BUG_ON(info->control.rates[0].idx < 0)

 drivers/net/wireless/ath/ath9k/ar9002_calib.c    |    3 ++-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c      |    2 +-
 drivers/net/wireless/ath/ath9k/main.c            |    6 ++++++
 drivers/net/wireless/iwlegacy/iwl-3945-rs.c      |   13 ++++++++-----
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c |    2 ++
 drivers/net/wireless/rtlwifi/core.c              |    8 ++++++++
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c     |   11 ++++++-----
 net/mac80211/sta_info.c                          |    2 +-
 9 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index 2d4c091..2d394af 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -41,7 +41,8 @@ static bool ar9002_hw_is_cal_supported(struct ath_hw *ah,
 	case ADC_DC_CAL:
 		/* Run ADC Gain Cal for non-CCK & non 2GHz-HT20 only */
 		if (!IS_CHAN_B(chan) &&
-		    !(IS_CHAN_2GHZ(chan) && IS_CHAN_HT20(chan)))
+		    !((IS_CHAN_2GHZ(chan) || IS_CHAN_A_FAST_CLOCK(ah, chan)) &&
+		      IS_CHAN_HT20(chan)))
 			supported = true;
 		break;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index 1baca8e..fcafec0 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -671,7 +671,7 @@ static int ar9003_hw_process_ini(struct ath_hw *ah,
 		REG_WRITE_ARRAY(&ah->iniModesAdditional,
 				modesIndex, regWrites);
 
-	if (AR_SREV_9300(ah))
+	if (AR_SREV_9330(ah))
 		REG_WRITE_ARRAY(&ah->iniModesAdditional, 1, regWrites);
 
 	if (AR_SREV_9340(ah) && !ah->is_clk_25mhz)
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 6530694..722967b 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2303,6 +2303,12 @@ static void ath9k_flush(struct ieee80211_hw *hw, bool drop)
 	mutex_lock(&sc->mutex);
 	cancel_delayed_work_sync(&sc->tx_complete_work);
 
+	if (ah->ah_flags & AH_UNPLUGGED) {
+		ath_dbg(common, ATH_DBG_ANY, "Device has been unplugged!\n");
+		mutex_unlock(&sc->mutex);
+		return;
+	}
+
 	if (sc->sc_flags & SC_OP_INVALID) {
 		ath_dbg(common, ATH_DBG_ANY, "Device not present\n");
 		mutex_unlock(&sc->mutex);
diff --git a/drivers/net/wireless/iwlegacy/iwl-3945-rs.c b/drivers/net/wireless/iwlegacy/iwl-3945-rs.c
index 977bd24..164bcae 100644
--- a/drivers/net/wireless/iwlegacy/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlegacy/iwl-3945-rs.c
@@ -822,12 +822,15 @@ static void iwl3945_rs_get_rate(void *priv_r, struct ieee80211_sta *sta,
 
  out:
 
-	rs_sta->last_txrate_idx = index;
-	if (sband->band == IEEE80211_BAND_5GHZ)
-		info->control.rates[0].idx = rs_sta->last_txrate_idx -
-				IWL_FIRST_OFDM_RATE;
-	else
+	if (sband->band == IEEE80211_BAND_5GHZ) {
+		if (WARN_ON_ONCE(index < IWL_FIRST_OFDM_RATE))
+			index = IWL_FIRST_OFDM_RATE;
+		rs_sta->last_txrate_idx = index;
+		info->control.rates[0].idx = index - IWL_FIRST_OFDM_RATE;
+	} else {
+		rs_sta->last_txrate_idx = index;
 		info->control.rates[0].idx = rs_sta->last_txrate_idx;
+	}
 
 	IWL_DEBUG_RATE(priv, "leave: %d\n", index);
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-ucode.c b/drivers/net/wireless/iwlwifi/iwl-agn-ucode.c
index a895a09..5621100 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-ucode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-ucode.c
@@ -167,7 +167,7 @@ static int iwlagn_set_temperature_offset_calib(struct iwl_priv *priv)
 
 	memset(&cmd, 0, sizeof(cmd));
 	iwl_set_calib_hdr(&cmd.hdr, IWL_PHY_CALIBRATE_TEMP_OFFSET_CMD);
-	memcpy(&cmd.radio_sensor_offset, offset_calib, sizeof(offset_calib));
+	memcpy(&cmd.radio_sensor_offset, offset_calib, sizeof(*offset_calib));
 	if (!(cmd.radio_sensor_offset))
 		cmd.radio_sensor_offset = DEFAULT_RADIO_SENSOR_OFFSET;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c b/drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c
index a6b2b1d..222d410 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-tx-pcie.c
@@ -771,6 +771,8 @@ void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 	cmd = txq->cmd[cmd_index];
 	meta = &txq->meta[cmd_index];
 
+	txq->time_stamp = jiffies;
+
 	iwlagn_unmap_tfd(priv, meta, &txq->tfds[index], DMA_BIDIRECTIONAL);
 
 	/* Input error checking is done when commands are added to queue. */
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 1bdc1aa..04c4e9e 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -610,6 +610,11 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 			mac->link_state = MAC80211_NOLINK;
 			memset(mac->bssid, 0, 6);
+
+			/* reset sec info */
+			rtl_cam_reset_sec_info(hw);
+
+			rtl_cam_reset_all_entry(hw);
 			mac->vendor = PEER_UNKNOWN;
 
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
@@ -1063,6 +1068,9 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		 *or clear all entry here.
 		 */
 		rtl_cam_delete_one_entry(hw, mac_addr, key_idx);
+
+		rtl_cam_reset_sec_info(hw);
+
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 906e7aa..3e52a54 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -549,15 +549,16 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 			       (tcb_desc->rts_use_shortpreamble ? 1 : 0)
 			       : (tcb_desc->rts_use_shortgi ? 1 : 0)));
 	if (mac->bw_40) {
-		if (tcb_desc->packet_bw) {
+		if (rate_flag & IEEE80211_TX_RC_DUP_DATA) {
 			SET_TX_DESC_DATA_BW(txdesc, 1);
 			SET_TX_DESC_DATA_SC(txdesc, 3);
+		} else if(rate_flag & IEEE80211_TX_RC_40_MHZ_WIDTH){
+			SET_TX_DESC_DATA_BW(txdesc, 1);
+			SET_TX_DESC_DATA_SC(txdesc, mac->cur_40_prime_sc);
 		} else {
 			SET_TX_DESC_DATA_BW(txdesc, 0);
-				if (rate_flag & IEEE80211_TX_RC_DUP_DATA)
-					SET_TX_DESC_DATA_SC(txdesc,
-							  mac->cur_40_prime_sc);
-			}
+			SET_TX_DESC_DATA_SC(txdesc, 0);
+		}
 	} else {
 		SET_TX_DESC_DATA_BW(txdesc, 0);
 		SET_TX_DESC_DATA_SC(txdesc, 0);
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 3db78b6..21070e9 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -665,7 +665,7 @@ static int __must_check __sta_info_destroy(struct sta_info *sta)
 		BUG_ON(!sdata->bss);
 
 		atomic_dec(&sdata->bss->num_sta_ps);
-		__sta_info_clear_tim_bit(sdata->bss, sta);
+		sta_info_clear_tim_bit(sta);
 	}
 
 	local->num_sta--;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
