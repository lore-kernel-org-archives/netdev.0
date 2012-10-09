From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-10-09
Date: Tue, 9 Oct 2012 14:38:44 -0400
Message-ID: <20121009183844.GB1993@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit c3e7724b6bc2f25e46c38dbe68f09d71fafeafb8

Dave,

Here is a batch of fixes intended for 3.7...

Amitkumar Karwar provides a couple of mwifiex fixes to correctly
report some reason codes for certain connection failures.  He also
provides a fix to cleanup after a scanning failure.  Bing Zhao rounds
that out with another mwifiex scanning fix.

Daniel Golle gives us a fix for a copy/paste error in rt2x00.

Felix Fietkau brings a couple of ath9k fixes related to suspend/resume,
and a couple of fixes to prevent memory leaks in ath9k and mac80211.

Ronald Wahl sends a carl9170 fix for a sleep in softirq context.

Thomas Pedersen reorders some code to prevent drv_get_tsf from being
called while holding a spinlock, now that it can sleep.

Finally, Wei Yongjun prevents a NULL pointer dereference in the
ath5k driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 6825a26c2dc21eb4f8df9c06d3786ddec97cf53b:

  ipv6: release reference of ip6_null_entry's dst entry in __ip6_del_rt (2012-10-04 16:00:07 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/master-2012-10-08

for you to fetch changes up to c3e7724b6bc2f25e46c38dbe68f09d71fafeafb8:

  mac80211: use ieee80211_free_txskb to fix possible skb leaks (2012-10-08 15:06:05 -0400)

----------------------------------------------------------------
Amitkumar Karwar (3):
      mwifiex: reset scan_processing flag in failure cases
      mwifiex: update cfg80211 with correct reason code when association fails
      mwifiex: update cfg80211 with correct reason code when connection is lost

Bing Zhao (1):
      mwifiex: return -EBUSY if scan request cannot be honored

Daniel Golle (1):
      rt2x00/rt3352: Fix lnagain assignment to use register 66.

Felix Fietkau (4):
      ath9k: fix ASPM initialization on resume
      ath9k: improve suspend/resume reliability
      ath9k: use ieee80211_free_txskb
      mac80211: use ieee80211_free_txskb to fix possible skb leaks

Ronald Wahl (1):
      carl9170: fix sleep in softirq context

Thomas Pedersen (1):
      mac80211: call drv_get_tsf() in sleepable context

Wei Yongjun (1):
      ath5k: fix potential NULL pointer dereference in ath5k_beacon_update()

 drivers/net/wireless/ath/ath5k/base.c        |  3 +-
 drivers/net/wireless/ath/ath9k/beacon.c      |  2 +-
 drivers/net/wireless/ath/ath9k/hw.c          |  5 +++
 drivers/net/wireless/ath/ath9k/hw.h          |  1 +
 drivers/net/wireless/ath/ath9k/main.c        | 15 +++-----
 drivers/net/wireless/ath/ath9k/pci.c         |  7 ++++
 drivers/net/wireless/ath/ath9k/xmit.c        | 53 +++++++++++++++-------------
 drivers/net/wireless/ath/carl9170/carl9170.h |  1 +
 drivers/net/wireless/ath/carl9170/main.c     | 29 ++++++++-------
 drivers/net/wireless/mwifiex/cfg80211.c      | 27 ++++++++++----
 drivers/net/wireless/mwifiex/join.c          |  6 ++--
 drivers/net/wireless/mwifiex/main.h          |  2 +-
 drivers/net/wireless/mwifiex/scan.c          | 38 +++++++++++---------
 drivers/net/wireless/mwifiex/sta_cmdresp.c   |  4 +--
 drivers/net/wireless/mwifiex/sta_event.c     | 31 ++++++++++------
 drivers/net/wireless/rt2x00/rt2800lib.c      |  4 +--
 net/mac80211/mesh_sync.c                     |  3 +-
 net/mac80211/status.c                        |  4 +--
 net/mac80211/tx.c                            | 22 ++++++------
 19 files changed, 151 insertions(+), 106 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 9fd6d9a..9f31cfa 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1804,7 +1804,7 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 {
 	int ret;
 	struct ath5k_hw *ah = hw->priv;
-	struct ath5k_vif *avf = (void *)vif->drv_priv;
+	struct ath5k_vif *avf;
 	struct sk_buff *skb;
 
 	if (WARN_ON(!vif)) {
@@ -1819,6 +1819,7 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 		goto out;
 	}
 
+	avf = (void *)vif->drv_priv;
 	ath5k_txbuf_free_skb(ah, avf->bbuf);
 	avf->bbuf->skb = skb;
 	ret = ath5k_beacon_setup(ah, avf->bbuf);
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index 76f07d8..1b48414 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -120,7 +120,7 @@ static void ath9k_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
 		ath_dbg(common, XMIT, "CABQ TX failed\n");
-		dev_kfree_skb_any(skb);
+		ieee80211_free_txskb(hw, skb);
 	}
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index f9a6ec5..8e1559a 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1450,9 +1450,14 @@ static bool ath9k_hw_set_reset_reg(struct ath_hw *ah, u32 type)
 	REG_WRITE(ah, AR_RTC_FORCE_WAKE,
 		  AR_RTC_FORCE_WAKE_EN | AR_RTC_FORCE_WAKE_ON_INT);
 
+	if (!ah->reset_power_on)
+		type = ATH9K_RESET_POWER_ON;
+
 	switch (type) {
 	case ATH9K_RESET_POWER_ON:
 		ret = ath9k_hw_set_reset_power_on(ah);
+		if (!ret)
+			ah->reset_power_on = true;
 		break;
 	case ATH9K_RESET_WARM:
 	case ATH9K_RESET_COLD:
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 566a4ce..dbc1b7a 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -741,6 +741,7 @@ struct ath_hw {
 	u32 rfkill_polarity;
 	u32 ah_flags;
 
+	bool reset_power_on;
 	bool htc_reset_init;
 
 	enum nl80211_iftype opmode;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 31ab82e..dd45edf 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -639,8 +639,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 		ath_err(common,
 			"Unable to reset hardware; reset status %d (freq %u MHz)\n",
 			r, curchan->center_freq);
-		spin_unlock_bh(&sc->sc_pcu_lock);
-		goto mutex_unlock;
+		ah->reset_power_on = false;
 	}
 
 	/* Setup our intr mask. */
@@ -665,11 +664,8 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	clear_bit(SC_OP_INVALID, &sc->sc_flags);
 	sc->sc_ah->is_monitoring = false;
 
-	if (!ath_complete_reset(sc, false)) {
-		r = -EIO;
-		spin_unlock_bh(&sc->sc_pcu_lock);
-		goto mutex_unlock;
-	}
+	if (!ath_complete_reset(sc, false))
+		ah->reset_power_on = false;
 
 	if (ah->led_pin >= 0) {
 		ath9k_hw_cfg_output(ah, ah->led_pin,
@@ -688,12 +684,11 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	if (ah->caps.pcie_lcr_extsync_en && common->bus_ops->extn_synch_en)
 		common->bus_ops->extn_synch_en(common);
 
-mutex_unlock:
 	mutex_unlock(&sc->mutex);
 
 	ath9k_ps_restore(sc);
 
-	return r;
+	return 0;
 }
 
 static void ath9k_tx(struct ieee80211_hw *hw,
@@ -770,7 +765,7 @@ static void ath9k_tx(struct ieee80211_hw *hw,
 
 	return;
 exit:
-	dev_kfree_skb_any(skb);
+	ieee80211_free_txskb(hw, skb);
 }
 
 static void ath9k_stop(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 0e630a9..f088f4b 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -324,6 +324,10 @@ static int ath_pci_suspend(struct device *device)
 static int ath_pci_resume(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
+	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
+	struct ath_softc *sc = hw->priv;
+	struct ath_hw *ah = sc->sc_ah;
+	struct ath_common *common = ath9k_hw_common(ah);
 	u32 val;
 
 	/*
@@ -335,6 +339,9 @@ static int ath_pci_resume(struct device *device)
 	if ((val & 0x0000ff00) != 0)
 		pci_write_config_dword(pdev, 0x40, val & 0xffff00ff);
 
+	ath_pci_aspm_init(common);
+	ah->reset_power_on = false;
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 36618e3..378bd70 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -66,8 +66,7 @@ static void ath_tx_update_baw(struct ath_softc *sc, struct ath_atx_tid *tid,
 static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
 					   struct ath_txq *txq,
 					   struct ath_atx_tid *tid,
-					   struct sk_buff *skb,
-					   bool dequeue);
+					   struct sk_buff *skb);
 
 enum {
 	MCS_HT20,
@@ -176,7 +175,15 @@ static void ath_tx_flush_tid(struct ath_softc *sc, struct ath_atx_tid *tid)
 		fi = get_frame_info(skb);
 		bf = fi->bf;
 
-		if (bf && fi->retries) {
+		if (!bf) {
+			bf = ath_tx_setup_buffer(sc, txq, tid, skb);
+			if (!bf) {
+				ieee80211_free_txskb(sc->hw, skb);
+				continue;
+			}
+		}
+
+		if (fi->retries) {
 			list_add_tail(&bf->list, &bf_head);
 			ath_tx_update_baw(sc, tid, bf->bf_state.seqno);
 			ath_tx_complete_buf(sc, bf, txq, &bf_head, &ts, 0);
@@ -785,10 +792,13 @@ static enum ATH_AGGR_STATUS ath_tx_form_aggr(struct ath_softc *sc,
 		fi = get_frame_info(skb);
 		bf = fi->bf;
 		if (!fi->bf)
-			bf = ath_tx_setup_buffer(sc, txq, tid, skb, true);
+			bf = ath_tx_setup_buffer(sc, txq, tid, skb);
 
-		if (!bf)
+		if (!bf) {
+			__skb_unlink(skb, &tid->buf_q);
+			ieee80211_free_txskb(sc->hw, skb);
 			continue;
+		}
 
 		bf->bf_state.bf_type = BUF_AMPDU | BUF_AGGR;
 		seqno = bf->bf_state.seqno;
@@ -1731,9 +1741,11 @@ static void ath_tx_send_ampdu(struct ath_softc *sc, struct ath_atx_tid *tid,
 		return;
 	}
 
-	bf = ath_tx_setup_buffer(sc, txctl->txq, tid, skb, false);
-	if (!bf)
+	bf = ath_tx_setup_buffer(sc, txctl->txq, tid, skb);
+	if (!bf) {
+		ieee80211_free_txskb(sc->hw, skb);
 		return;
+	}
 
 	bf->bf_state.bf_type = BUF_AMPDU;
 	INIT_LIST_HEAD(&bf_head);
@@ -1757,11 +1769,6 @@ static void ath_tx_send_normal(struct ath_softc *sc, struct ath_txq *txq,
 	struct ath_buf *bf;
 
 	bf = fi->bf;
-	if (!bf)
-		bf = ath_tx_setup_buffer(sc, txq, tid, skb, false);
-
-	if (!bf)
-		return;
 
 	INIT_LIST_HEAD(&bf_head);
 	list_add_tail(&bf->list, &bf_head);
@@ -1839,8 +1846,7 @@ u8 ath_txchainmask_reduction(struct ath_softc *sc, u8 chainmask, u32 rate)
 static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
 					   struct ath_txq *txq,
 					   struct ath_atx_tid *tid,
-					   struct sk_buff *skb,
-					   bool dequeue)
+					   struct sk_buff *skb)
 {
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_frame_info *fi = get_frame_info(skb);
@@ -1852,7 +1858,7 @@ static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
 	bf = ath_tx_get_buffer(sc);
 	if (!bf) {
 		ath_dbg(common, XMIT, "TX buffers are full\n");
-		goto error;
+		return NULL;
 	}
 
 	ATH_TXBUF_RESET(bf);
@@ -1881,18 +1887,12 @@ static struct ath_buf *ath_tx_setup_buffer(struct ath_softc *sc,
 		ath_err(ath9k_hw_common(sc->sc_ah),
 			"dma_mapping_error() on TX\n");
 		ath_tx_return_buffer(sc, bf);
-		goto error;
+		return NULL;
 	}
 
 	fi->bf = bf;
 
 	return bf;
-
-error:
-	if (dequeue)
-		__skb_unlink(skb, &tid->buf_q);
-	dev_kfree_skb_any(skb);
-	return NULL;
 }
 
 /* FIXME: tx power */
@@ -1921,9 +1921,14 @@ static void ath_tx_start_dma(struct ath_softc *sc, struct sk_buff *skb,
 		 */
 		ath_tx_send_ampdu(sc, tid, skb, txctl);
 	} else {
-		bf = ath_tx_setup_buffer(sc, txctl->txq, tid, skb, false);
-		if (!bf)
+		bf = ath_tx_setup_buffer(sc, txctl->txq, tid, skb);
+		if (!bf) {
+			if (txctl->paprd)
+				dev_kfree_skb_any(skb);
+			else
+				ieee80211_free_txskb(sc->hw, skb);
 			return;
+		}
 
 		bf->bf_state.bfs_paprd = txctl->paprd;
 
diff --git a/drivers/net/wireless/ath/carl9170/carl9170.h b/drivers/net/wireless/ath/carl9170/carl9170.h
index 2aa4a59..2df17f1 100644
--- a/drivers/net/wireless/ath/carl9170/carl9170.h
+++ b/drivers/net/wireless/ath/carl9170/carl9170.h
@@ -303,6 +303,7 @@ struct ar9170 {
 	unsigned long queue_stop_timeout[__AR9170_NUM_TXQ];
 	unsigned long max_queue_stop_timeout[__AR9170_NUM_TXQ];
 	bool needs_full_reset;
+	bool force_usb_reset;
 	atomic_t pending_restarts;
 
 	/* interface mode settings */
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 67997b3..25a1e2f 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -465,27 +465,26 @@ static void carl9170_restart_work(struct work_struct *work)
 {
 	struct ar9170 *ar = container_of(work, struct ar9170,
 					 restart_work);
-	int err;
+	int err = -EIO;
 
 	ar->usedkeys = 0;
 	ar->filter_state = 0;
 	carl9170_cancel_worker(ar);
 
 	mutex_lock(&ar->mutex);
-	err = carl9170_usb_restart(ar);
-	if (net_ratelimit()) {
-		if (err) {
-			dev_err(&ar->udev->dev, "Failed to restart device "
-				" (%d).\n", err);
-		 } else {
-			dev_info(&ar->udev->dev, "device restarted "
-				 "successfully.\n");
+	if (!ar->force_usb_reset) {
+		err = carl9170_usb_restart(ar);
+		if (net_ratelimit()) {
+			if (err)
+				dev_err(&ar->udev->dev, "Failed to restart device (%d).\n", err);
+			else
+				dev_info(&ar->udev->dev, "device restarted successfully.\n");
 		}
 	}
-
 	carl9170_zap_queues(ar);
 	mutex_unlock(&ar->mutex);
-	if (!err) {
+
+	if (!err && !ar->force_usb_reset) {
 		ar->restart_counter++;
 		atomic_set(&ar->pending_restarts, 0);
 
@@ -526,10 +525,10 @@ void carl9170_restart(struct ar9170 *ar, const enum carl9170_restart_reasons r)
 	if (!ar->registered)
 		return;
 
-	if (IS_ACCEPTING_CMD(ar) && !ar->needs_full_reset)
-		ieee80211_queue_work(ar->hw, &ar->restart_work);
-	else
-		carl9170_usb_reset(ar);
+	if (!IS_ACCEPTING_CMD(ar) || ar->needs_full_reset)
+		ar->force_usb_reset = true;
+
+	ieee80211_queue_work(ar->hw, &ar->restart_work);
 
 	/*
 	 * At this point, the device instance might have vanished/disabled.
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 2691620..0679458 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1596,8 +1596,9 @@ done:
 		}
 	}
 
-	if (mwifiex_bss_start(priv, bss, &req_ssid))
-		return -EFAULT;
+	ret = mwifiex_bss_start(priv, bss, &req_ssid);
+	if (ret)
+		return ret;
 
 	if (mode == NL80211_IFTYPE_ADHOC) {
 		/* Inform the BSS information to kernel, otherwise
@@ -1652,9 +1653,19 @@ done:
 			"info: association to bssid %pM failed\n",
 			priv->cfg_bssid);
 		memset(priv->cfg_bssid, 0, ETH_ALEN);
+
+		if (ret > 0)
+			cfg80211_connect_result(priv->netdev, priv->cfg_bssid,
+						NULL, 0, NULL, 0, ret,
+						GFP_KERNEL);
+		else
+			cfg80211_connect_result(priv->netdev, priv->cfg_bssid,
+						NULL, 0, NULL, 0,
+						WLAN_STATUS_UNSPECIFIED_FAILURE,
+						GFP_KERNEL);
 	}
 
-	return ret;
+	return 0;
 }
 
 /*
@@ -1802,7 +1813,7 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 {
 	struct net_device *dev = request->wdev->netdev;
 	struct mwifiex_private *priv = mwifiex_netdev_get_priv(dev);
-	int i, offset;
+	int i, offset, ret;
 	struct ieee80211_channel *chan;
 	struct ieee_types_header *ie;
 
@@ -1855,8 +1866,12 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 
 		priv->user_scan_cfg->chan_list[i].scan_time = 0;
 	}
-	if (mwifiex_scan_networks(priv, priv->user_scan_cfg))
-		return -EFAULT;
+
+	ret = mwifiex_scan_networks(priv, priv->user_scan_cfg);
+	if (ret) {
+		dev_err(priv->adapter->dev, "scan failed: %d\n", ret);
+		return ret;
+	}
 
 	if (request->ie && request->ie_len) {
 		for (i = 0; i < MWIFIEX_MAX_VSIE_NUM; i++) {
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwifiex/join.c
index 82e63ce..7b0858a 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -1180,16 +1180,18 @@ int mwifiex_ret_802_11_ad_hoc(struct mwifiex_private *priv,
 	struct mwifiex_adapter *adapter = priv->adapter;
 	struct host_cmd_ds_802_11_ad_hoc_result *adhoc_result;
 	struct mwifiex_bssdescriptor *bss_desc;
+	u16 reason_code;
 
 	adhoc_result = &resp->params.adhoc_result;
 
 	bss_desc = priv->attempted_bss_desc;
 
 	/* Join result code 0 --> SUCCESS */
-	if (le16_to_cpu(resp->result)) {
+	reason_code = le16_to_cpu(resp->result);
+	if (reason_code) {
 		dev_err(priv->adapter->dev, "ADHOC_RESP: failed\n");
 		if (priv->media_connected)
-			mwifiex_reset_connect_state(priv);
+			mwifiex_reset_connect_state(priv, reason_code);
 
 		memset(&priv->curr_bss_params.bss_descriptor,
 		       0x00, sizeof(struct mwifiex_bssdescriptor));
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwifiex/main.h
index bfb3fa6..c2d0ab1 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -847,7 +847,7 @@ int mwifiex_cmd_802_11_associate(struct mwifiex_private *priv,
 				 struct mwifiex_bssdescriptor *bss_desc);
 int mwifiex_ret_802_11_associate(struct mwifiex_private *priv,
 				 struct host_cmd_ds_command *resp);
-void mwifiex_reset_connect_state(struct mwifiex_private *priv);
+void mwifiex_reset_connect_state(struct mwifiex_private *priv, u16 reason);
 u8 mwifiex_band_to_radio_type(u8 band);
 int mwifiex_deauthenticate(struct mwifiex_private *priv, u8 *mac);
 int mwifiex_adhoc_start(struct mwifiex_private *priv,
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index e36a759..00b658d 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1296,7 +1296,7 @@ mwifiex_radio_type_to_band(u8 radio_type)
 int mwifiex_scan_networks(struct mwifiex_private *priv,
 			  const struct mwifiex_user_scan_cfg *user_scan_in)
 {
-	int ret = 0;
+	int ret;
 	struct mwifiex_adapter *adapter = priv->adapter;
 	struct cmd_ctrl_node *cmd_node;
 	union mwifiex_scan_cmd_config_tlv *scan_cfg_out;
@@ -1309,25 +1309,26 @@ int mwifiex_scan_networks(struct mwifiex_private *priv,
 	unsigned long flags;
 
 	if (adapter->scan_processing) {
-		dev_dbg(adapter->dev, "cmd: Scan already in process...\n");
-		return ret;
+		dev_err(adapter->dev, "cmd: Scan already in process...\n");
+		return -EBUSY;
 	}
 
-	spin_lock_irqsave(&adapter->mwifiex_cmd_lock, flags);
-	adapter->scan_processing = true;
-	spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, flags);
-
 	if (priv->scan_block) {
-		dev_dbg(adapter->dev,
+		dev_err(adapter->dev,
 			"cmd: Scan is blocked during association...\n");
-		return ret;
+		return -EBUSY;
 	}
 
+	spin_lock_irqsave(&adapter->mwifiex_cmd_lock, flags);
+	adapter->scan_processing = true;
+	spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, flags);
+
 	scan_cfg_out = kzalloc(sizeof(union mwifiex_scan_cmd_config_tlv),
 								GFP_KERNEL);
 	if (!scan_cfg_out) {
 		dev_err(adapter->dev, "failed to alloc scan_cfg_out\n");
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto done;
 	}
 
 	buf_size = sizeof(struct mwifiex_chan_scan_param_set) *
@@ -1336,7 +1337,8 @@ int mwifiex_scan_networks(struct mwifiex_private *priv,
 	if (!scan_chan_list) {
 		dev_err(adapter->dev, "failed to alloc scan_chan_list\n");
 		kfree(scan_cfg_out);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto done;
 	}
 
 	mwifiex_config_scan(priv, user_scan_in, &scan_cfg_out->config,
@@ -1364,14 +1366,16 @@ int mwifiex_scan_networks(struct mwifiex_private *priv,
 			spin_unlock_irqrestore(&adapter->scan_pending_q_lock,
 					       flags);
 		}
-	} else {
-		spin_lock_irqsave(&adapter->mwifiex_cmd_lock, flags);
-		adapter->scan_processing = true;
-		spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, flags);
 	}
 
 	kfree(scan_cfg_out);
 	kfree(scan_chan_list);
+done:
+	if (ret) {
+		spin_lock_irqsave(&adapter->mwifiex_cmd_lock, flags);
+		adapter->scan_processing = false;
+		spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, flags);
+	}
 	return ret;
 }
 
@@ -1430,8 +1434,8 @@ int mwifiex_check_network_compatibility(struct mwifiex_private *priv,
 			ret = mwifiex_is_network_compatible(priv, bss_desc,
 							    priv->bss_mode);
 			if (ret)
-				dev_err(priv->adapter->dev, "cannot find ssid "
-					"%s\n", bss_desc->ssid.ssid);
+				dev_err(priv->adapter->dev,
+					"Incompatible network settings\n");
 			break;
 		default:
 			ret = 0;
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index e380171..09e6a26 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -545,7 +545,7 @@ static int mwifiex_ret_802_11_deauthenticate(struct mwifiex_private *priv,
 	if (!memcmp(resp->params.deauth.mac_addr,
 		    &priv->curr_bss_params.bss_descriptor.mac_address,
 		    sizeof(resp->params.deauth.mac_addr)))
-		mwifiex_reset_connect_state(priv);
+		mwifiex_reset_connect_state(priv, WLAN_REASON_DEAUTH_LEAVING);
 
 	return 0;
 }
@@ -558,7 +558,7 @@ static int mwifiex_ret_802_11_deauthenticate(struct mwifiex_private *priv,
 static int mwifiex_ret_802_11_ad_hoc_stop(struct mwifiex_private *priv,
 					  struct host_cmd_ds_command *resp)
 {
-	mwifiex_reset_connect_state(priv);
+	mwifiex_reset_connect_state(priv, WLAN_REASON_DEAUTH_LEAVING);
 	return 0;
 }
 
diff --git a/drivers/net/wireless/mwifiex/sta_event.c b/drivers/net/wireless/mwifiex/sta_event.c
index aafde30..8132119 100644
--- a/drivers/net/wireless/mwifiex/sta_event.c
+++ b/drivers/net/wireless/mwifiex/sta_event.c
@@ -41,7 +41,7 @@
  *      - Sends a disconnect event to upper layers/applications.
  */
 void
-mwifiex_reset_connect_state(struct mwifiex_private *priv)
+mwifiex_reset_connect_state(struct mwifiex_private *priv, u16 reason_code)
 {
 	struct mwifiex_adapter *adapter = priv->adapter;
 
@@ -117,10 +117,10 @@ mwifiex_reset_connect_state(struct mwifiex_private *priv)
 	priv->media_connected = false;
 	dev_dbg(adapter->dev,
 		"info: successfully disconnected from %pM: reason code %d\n",
-		priv->cfg_bssid, WLAN_REASON_DEAUTH_LEAVING);
+		priv->cfg_bssid, reason_code);
 	if (priv->bss_mode == NL80211_IFTYPE_STATION) {
-		cfg80211_disconnected(priv->netdev, WLAN_REASON_DEAUTH_LEAVING,
-				      NULL, 0, GFP_KERNEL);
+		cfg80211_disconnected(priv->netdev, reason_code, NULL, 0,
+				      GFP_KERNEL);
 	}
 	memset(priv->cfg_bssid, 0, ETH_ALEN);
 
@@ -186,7 +186,7 @@ int mwifiex_process_sta_event(struct mwifiex_private *priv)
 	struct mwifiex_adapter *adapter = priv->adapter;
 	int ret = 0;
 	u32 eventcause = adapter->event_cause;
-	u16 ctrl;
+	u16 ctrl, reason_code;
 
 	switch (eventcause) {
 	case EVENT_DUMMY_HOST_WAKEUP_SIGNAL:
@@ -204,22 +204,31 @@ int mwifiex_process_sta_event(struct mwifiex_private *priv)
 	case EVENT_DEAUTHENTICATED:
 		dev_dbg(adapter->dev, "event: Deauthenticated\n");
 		adapter->dbg.num_event_deauth++;
-		if (priv->media_connected)
-			mwifiex_reset_connect_state(priv);
+		if (priv->media_connected) {
+			reason_code =
+				le16_to_cpu(*(__le16 *)adapter->event_body);
+			mwifiex_reset_connect_state(priv, reason_code);
+		}
 		break;
 
 	case EVENT_DISASSOCIATED:
 		dev_dbg(adapter->dev, "event: Disassociated\n");
 		adapter->dbg.num_event_disassoc++;
-		if (priv->media_connected)
-			mwifiex_reset_connect_state(priv);
+		if (priv->media_connected) {
+			reason_code =
+				le16_to_cpu(*(__le16 *)adapter->event_body);
+			mwifiex_reset_connect_state(priv, reason_code);
+		}
 		break;
 
 	case EVENT_LINK_LOST:
 		dev_dbg(adapter->dev, "event: Link lost\n");
 		adapter->dbg.num_event_link_lost++;
-		if (priv->media_connected)
-			mwifiex_reset_connect_state(priv);
+		if (priv->media_connected) {
+			reason_code =
+				le16_to_cpu(*(__le16 *)adapter->event_body);
+			mwifiex_reset_connect_state(priv, reason_code);
+		}
 		break;
 
 	case EVENT_PS_SLEEP:
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 540c94f..01dc889 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -2252,9 +2252,9 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 	 */
 	if (rt2x00_rt(rt2x00dev, RT3352)) {
 		rt2800_bbp_write(rt2x00dev, 27, 0x0);
-		rt2800_bbp_write(rt2x00dev, 62, 0x26 + rt2x00dev->lna_gain);
+		rt2800_bbp_write(rt2x00dev, 66, 0x26 + rt2x00dev->lna_gain);
 		rt2800_bbp_write(rt2x00dev, 27, 0x20);
-		rt2800_bbp_write(rt2x00dev, 62, 0x26 + rt2x00dev->lna_gain);
+		rt2800_bbp_write(rt2x00dev, 66, 0x26 + rt2x00dev->lna_gain);
 	} else {
 		rt2800_bbp_write(rt2x00dev, 62, 0x37 - rt2x00dev->lna_gain);
 		rt2800_bbp_write(rt2x00dev, 63, 0x37 - rt2x00dev->lna_gain);
diff --git a/net/mac80211/mesh_sync.c b/net/mac80211/mesh_sync.c
index accfa00..a16b7b4 100644
--- a/net/mac80211/mesh_sync.c
+++ b/net/mac80211/mesh_sync.c
@@ -56,7 +56,6 @@ void mesh_sync_adjust_tbtt(struct ieee80211_sub_if_data *sdata)
 	u64 tsfdelta;
 
 	spin_lock_bh(&ifmsh->sync_offset_lock);
-
 	if (ifmsh->sync_offset_clockdrift_max < beacon_int_fraction) {
 		msync_dbg(sdata, "TBTT : max clockdrift=%lld; adjusting\n",
 			  (long long) ifmsh->sync_offset_clockdrift_max);
@@ -69,11 +68,11 @@ void mesh_sync_adjust_tbtt(struct ieee80211_sub_if_data *sdata)
 		tsfdelta = -beacon_int_fraction;
 		ifmsh->sync_offset_clockdrift_max -= beacon_int_fraction;
 	}
+	spin_unlock_bh(&ifmsh->sync_offset_lock);
 
 	tsf = drv_get_tsf(local, sdata);
 	if (tsf != -1ULL)
 		drv_set_tsf(local, sdata, tsf + tsfdelta);
-	spin_unlock_bh(&ifmsh->sync_offset_lock);
 }
 
 static void mesh_sync_offset_rx_bcn_presp(struct ieee80211_sub_if_data *sdata,
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 2ce8973..3af0cc4 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -34,7 +34,7 @@ void ieee80211_tx_status_irqsafe(struct ieee80211_hw *hw,
 		skb_queue_len(&local->skb_queue_unreliable);
 	while (tmp > IEEE80211_IRQSAFE_QUEUE_LIMIT &&
 	       (skb = skb_dequeue(&local->skb_queue_unreliable))) {
-		dev_kfree_skb_irq(skb);
+		ieee80211_free_txskb(hw, skb);
 		tmp--;
 		I802_DEBUG_INC(local->tx_status_drop);
 	}
@@ -159,7 +159,7 @@ static void ieee80211_handle_filtered_frame(struct ieee80211_local *local,
 			   "dropped TX filtered frame, queue_len=%d PS=%d @%lu\n",
 			   skb_queue_len(&sta->tx_filtered[ac]),
 			   !!test_sta_flag(sta, WLAN_STA_PS_STA), jiffies);
-	dev_kfree_skb(skb);
+	ieee80211_free_txskb(&local->hw, skb);
 }
 
 static void ieee80211_check_pending_bar(struct sta_info *sta, u8 *addr, u8 tid)
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index e0e0d1d..c9bf83f 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -354,7 +354,7 @@ static void purge_old_ps_buffers(struct ieee80211_local *local)
 			total += skb_queue_len(&sta->ps_tx_buf[ac]);
 			if (skb) {
 				purged++;
-				dev_kfree_skb(skb);
+				ieee80211_free_txskb(&local->hw, skb);
 				break;
 			}
 		}
@@ -466,7 +466,7 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data *tx)
 			ps_dbg(tx->sdata,
 			       "STA %pM TX buffer for AC %d full - dropping oldest frame\n",
 			       sta->sta.addr, ac);
-			dev_kfree_skb(old);
+			ieee80211_free_txskb(&local->hw, old);
 		} else
 			tx->local->total_ps_buffered++;
 
@@ -1103,7 +1103,7 @@ static bool ieee80211_tx_prep_agg(struct ieee80211_tx_data *tx,
 		spin_unlock(&tx->sta->lock);
 
 		if (purge_skb)
-			dev_kfree_skb(purge_skb);
+			ieee80211_free_txskb(&tx->local->hw, purge_skb);
 	}
 
 	/* reset session timer */
@@ -1214,7 +1214,7 @@ static bool ieee80211_tx_frags(struct ieee80211_local *local,
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (WARN_ON_ONCE(q >= local->hw.queues)) {
 			__skb_unlink(skb, skbs);
-			dev_kfree_skb(skb);
+			ieee80211_free_txskb(&local->hw, skb);
 			continue;
 		}
 #endif
@@ -1356,7 +1356,7 @@ static int invoke_tx_handlers(struct ieee80211_tx_data *tx)
 	if (unlikely(res == TX_DROP)) {
 		I802_DEBUG_INC(tx->local->tx_handlers_drop);
 		if (tx->skb)
-			dev_kfree_skb(tx->skb);
+			ieee80211_free_txskb(&tx->local->hw, tx->skb);
 		else
 			__skb_queue_purge(&tx->skbs);
 		return -1;
@@ -1393,7 +1393,7 @@ static bool ieee80211_tx(struct ieee80211_sub_if_data *sdata,
 	res_prepare = ieee80211_tx_prepare(sdata, &tx, skb);
 
 	if (unlikely(res_prepare == TX_DROP)) {
-		dev_kfree_skb(skb);
+		ieee80211_free_txskb(&local->hw, skb);
 		goto out;
 	} else if (unlikely(res_prepare == TX_QUEUED)) {
 		goto out;
@@ -1465,7 +1465,7 @@ void ieee80211_xmit(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 	headroom = max_t(int, 0, headroom);
 
 	if (ieee80211_skb_resize(sdata, skb, headroom, may_encrypt)) {
-		dev_kfree_skb(skb);
+		ieee80211_free_txskb(&local->hw, skb);
 		rcu_read_unlock();
 		return;
 	}
@@ -2050,8 +2050,10 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		head_need += IEEE80211_ENCRYPT_HEADROOM;
 		head_need += local->tx_headroom;
 		head_need = max_t(int, 0, head_need);
-		if (ieee80211_skb_resize(sdata, skb, head_need, true))
-			goto fail;
+		if (ieee80211_skb_resize(sdata, skb, head_need, true)) {
+			ieee80211_free_txskb(&local->hw, skb);
+			return NETDEV_TX_OK;
+		}
 	}
 
 	if (encaps_data) {
@@ -2184,7 +2186,7 @@ void ieee80211_tx_pending(unsigned long data)
 			struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 			if (WARN_ON(!info->control.vif)) {
-				kfree_skb(skb);
+				ieee80211_free_txskb(&local->hw, skb);
 				continue;
 			}
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
