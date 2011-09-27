From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-09-27
Date: Tue, 27 Sep 2011 17:00:31 -0400
Message-ID: <20110927210031.GA2471@tuxdriver.com>
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

Here is another last (?) batch of fixes intended for 3.1.  Included is a
scanning-related regression fix that avoids a potential crash, a buffer
overflow fix in cfg80211, an fix for an uninitialized variable in
rtlwifi, a fix for a DMA-related WARNING in ath9k, a fix for a DMA hang
in ath9k, and two iwlegacy fixes backported from prior iwlagn fixes, one
for avoiding interruptible waits and another for avoiding a command
queue timeout.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit d93dc5c4478c1fd5de85a3e8aece9aad7bbae044:

  Linux 3.1-rc7 (2011-09-21 16:58:15 -0700)

are available in the git repository at:
  git://git.infradead.org/users/linville/wireless.git for-davem

Johannes Berg (1):
      iwlagn: fix dangling scan request

John W. Linville (1):
      Merge branch 'master' of git://git.infradead.org/users/linville/wireless into for-davem

Jouni Malinen (1):
      cfg80211: Fix validation of AKM suites

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix unitialized struct

Mohammed Shafi Shajakhan (1):
      ath9k: Fix a dma warning/memory leak

Rajkumar Manoharan (1):
      ath9k_hw: Fix Rx DMA stuck for AR9003 chips

Stanislaw Gruszka (2):
      iwlegacy: fix command queue timeout
      iwlegacy: do not use interruptible waits

 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   10 ++++++-
 drivers/net/wireless/iwlegacy/iwl-core.c           |    4 +-
 drivers/net/wireless/iwlegacy/iwl-hcmd.c           |    2 +-
 drivers/net/wireless/iwlegacy/iwl-tx.c             |    4 ++-
 drivers/net/wireless/iwlegacy/iwl3945-base.c       |    8 ++--
 drivers/net/wireless/iwlegacy/iwl4965-base.c       |   10 +++---
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   30 ++++++++++---------
 drivers/net/wireless/rtlwifi/usb.c                 |    1 +
 net/wireless/nl80211.c                             |    5 ++-
 10 files changed, 46 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
index 2339728..3e69c63 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
@@ -1514,7 +1514,7 @@ static const u32 ar9300_2p2_mac_core[][2] = {
 	{0x00008258, 0x00000000},
 	{0x0000825c, 0x40000000},
 	{0x00008260, 0x00080922},
-	{0x00008264, 0x9bc00010},
+	{0x00008264, 0x9d400010},
 	{0x00008268, 0xffffffff},
 	{0x0000826c, 0x0000ffff},
 	{0x00008270, 0x00000000},
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 9a48501..4c21f8c 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -205,14 +205,22 @@ static void ath_rx_remove_buffer(struct ath_softc *sc,
 
 static void ath_rx_edma_cleanup(struct ath_softc *sc)
 {
+	struct ath_hw *ah = sc->sc_ah;
+	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath_buf *bf;
 
 	ath_rx_remove_buffer(sc, ATH9K_RX_QUEUE_LP);
 	ath_rx_remove_buffer(sc, ATH9K_RX_QUEUE_HP);
 
 	list_for_each_entry(bf, &sc->rx.rxbuf, list) {
-		if (bf->bf_mpdu)
+		if (bf->bf_mpdu) {
+			dma_unmap_single(sc->dev, bf->bf_buf_addr,
+					common->rx_bufsize,
+					DMA_BIDIRECTIONAL);
 			dev_kfree_skb_any(bf->bf_mpdu);
+			bf->bf_buf_addr = 0;
+			bf->bf_mpdu = NULL;
+		}
 	}
 
 	INIT_LIST_HEAD(&sc->rx.rxbuf);
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.c b/drivers/net/wireless/iwlegacy/iwl-core.c
index 35cd253..e5971fe 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.c
+++ b/drivers/net/wireless/iwlegacy/iwl-core.c
@@ -937,7 +937,7 @@ void iwl_legacy_irq_handle_error(struct iwl_priv *priv)
 					&priv->contexts[IWL_RXON_CTX_BSS]);
 #endif
 
-	wake_up_interruptible(&priv->wait_command_queue);
+	wake_up(&priv->wait_command_queue);
 
 	/* Keep the restart process from trying to send host
 	 * commands by clearing the INIT status bit */
@@ -1746,7 +1746,7 @@ int iwl_legacy_force_reset(struct iwl_priv *priv, bool external)
 
 	/* Set the FW error flag -- cleared on iwl_down */
 	set_bit(STATUS_FW_ERROR, &priv->status);
-	wake_up_interruptible(&priv->wait_command_queue);
+	wake_up(&priv->wait_command_queue);
 	/*
 	 * Keep the restart process from trying to send host
 	 * commands by clearing the INIT status bit
diff --git a/drivers/net/wireless/iwlegacy/iwl-hcmd.c b/drivers/net/wireless/iwlegacy/iwl-hcmd.c
index 62b4b09..ce1fc9f 100644
--- a/drivers/net/wireless/iwlegacy/iwl-hcmd.c
+++ b/drivers/net/wireless/iwlegacy/iwl-hcmd.c
@@ -167,7 +167,7 @@ int iwl_legacy_send_cmd_sync(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 		goto out;
 	}
 
-	ret = wait_event_interruptible_timeout(priv->wait_command_queue,
+	ret = wait_event_timeout(priv->wait_command_queue,
 			!test_bit(STATUS_HCMD_ACTIVE, &priv->status),
 			HOST_COMPLETE_TIMEOUT);
 	if (!ret) {
diff --git a/drivers/net/wireless/iwlegacy/iwl-tx.c b/drivers/net/wireless/iwlegacy/iwl-tx.c
index 4fff995..ef9e268 100644
--- a/drivers/net/wireless/iwlegacy/iwl-tx.c
+++ b/drivers/net/wireless/iwlegacy/iwl-tx.c
@@ -625,6 +625,8 @@ iwl_legacy_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 	cmd = txq->cmd[cmd_index];
 	meta = &txq->meta[cmd_index];
 
+	txq->time_stamp = jiffies;
+
 	pci_unmap_single(priv->pci_dev,
 			 dma_unmap_addr(meta, mapping),
 			 dma_unmap_len(meta, len),
@@ -645,7 +647,7 @@ iwl_legacy_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 		clear_bit(STATUS_HCMD_ACTIVE, &priv->status);
 		IWL_DEBUG_INFO(priv, "Clearing HCMD_ACTIVE for command %s\n",
 			       iwl_legacy_get_cmd_string(cmd->hdr.cmd));
-		wake_up_interruptible(&priv->wait_command_queue);
+		wake_up(&priv->wait_command_queue);
 	}
 
 	/* Mark as unmapped */
diff --git a/drivers/net/wireless/iwlegacy/iwl3945-base.c b/drivers/net/wireless/iwlegacy/iwl3945-base.c
index 795826a..66ee1562 100644
--- a/drivers/net/wireless/iwlegacy/iwl3945-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl3945-base.c
@@ -841,7 +841,7 @@ static void iwl3945_rx_card_state_notif(struct iwl_priv *priv,
 		wiphy_rfkill_set_hw_state(priv->hw->wiphy,
 				test_bit(STATUS_RF_KILL_HW, &priv->status));
 	else
-		wake_up_interruptible(&priv->wait_command_queue);
+		wake_up(&priv->wait_command_queue);
 }
 
 /**
@@ -2269,7 +2269,7 @@ static void iwl3945_alive_start(struct iwl_priv *priv)
 	iwl3945_reg_txpower_periodic(priv);
 
 	IWL_DEBUG_INFO(priv, "ALIVE processing complete.\n");
-	wake_up_interruptible(&priv->wait_command_queue);
+	wake_up(&priv->wait_command_queue);
 
 	return;
 
@@ -2300,7 +2300,7 @@ static void __iwl3945_down(struct iwl_priv *priv)
 	iwl_legacy_clear_driver_stations(priv);
 
 	/* Unblock any waiting calls */
-	wake_up_interruptible_all(&priv->wait_command_queue);
+	wake_up_all(&priv->wait_command_queue);
 
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
@@ -2853,7 +2853,7 @@ static int iwl3945_mac_start(struct ieee80211_hw *hw)
 
 	/* Wait for START_ALIVE from ucode. Otherwise callbacks from
 	 * mac80211 will not be run successfully. */
-	ret = wait_event_interruptible_timeout(priv->wait_command_queue,
+	ret = wait_event_timeout(priv->wait_command_queue,
 			test_bit(STATUS_READY, &priv->status),
 			UCODE_READY_TIMEOUT);
 	if (!ret) {
diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
index 1433466..aa0c253 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -576,7 +576,7 @@ static void iwl4965_rx_card_state_notif(struct iwl_priv *priv,
 		wiphy_rfkill_set_hw_state(priv->hw->wiphy,
 			test_bit(STATUS_RF_KILL_HW, &priv->status));
 	else
-		wake_up_interruptible(&priv->wait_command_queue);
+		wake_up(&priv->wait_command_queue);
 }
 
 /**
@@ -926,7 +926,7 @@ static void iwl4965_irq_tasklet(struct iwl_priv *priv)
 		handled |= CSR_INT_BIT_FH_TX;
 		/* Wake up uCode load routine, now that load is complete */
 		priv->ucode_write_complete = 1;
-		wake_up_interruptible(&priv->wait_command_queue);
+		wake_up(&priv->wait_command_queue);
 	}
 
 	if (inta & ~handled) {
@@ -1795,7 +1795,7 @@ static void iwl4965_alive_start(struct iwl_priv *priv)
 	iwl4965_rf_kill_ct_config(priv);
 
 	IWL_DEBUG_INFO(priv, "ALIVE processing complete.\n");
-	wake_up_interruptible(&priv->wait_command_queue);
+	wake_up(&priv->wait_command_queue);
 
 	iwl_legacy_power_update_mode(priv, true);
 	IWL_DEBUG_INFO(priv, "Updated power mode\n");
@@ -1828,7 +1828,7 @@ static void __iwl4965_down(struct iwl_priv *priv)
 	iwl_legacy_clear_driver_stations(priv);
 
 	/* Unblock any waiting calls */
-	wake_up_interruptible_all(&priv->wait_command_queue);
+	wake_up_all(&priv->wait_command_queue);
 
 	/* Wipe out the EXIT_PENDING status bit if we are not actually
 	 * exiting the module */
@@ -2266,7 +2266,7 @@ int iwl4965_mac_start(struct ieee80211_hw *hw)
 
 	/* Wait for START_ALIVE from Run Time ucode. Otherwise callbacks from
 	 * mac80211 will not be run successfully. */
-	ret = wait_event_interruptible_timeout(priv->wait_command_queue,
+	ret = wait_event_timeout(priv->wait_command_queue,
 			test_bit(STATUS_READY, &priv->status),
 			UCODE_READY_TIMEOUT);
 	if (!ret) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index dd6937e..77e528f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -405,31 +405,33 @@ int iwl_mac_hw_scan(struct ieee80211_hw *hw,
 
 	mutex_lock(&priv->mutex);
 
-	if (test_bit(STATUS_SCANNING, &priv->status) &&
-	    priv->scan_type != IWL_SCAN_NORMAL) {
-		IWL_DEBUG_SCAN(priv, "Scan already in progress.\n");
-		ret = -EAGAIN;
-		goto out_unlock;
-	}
-
-	/* mac80211 will only ask for one band at a time */
-	priv->scan_request = req;
-	priv->scan_vif = vif;
-
 	/*
 	 * If an internal scan is in progress, just set
 	 * up the scan_request as per above.
 	 */
 	if (priv->scan_type != IWL_SCAN_NORMAL) {
-		IWL_DEBUG_SCAN(priv, "SCAN request during internal scan\n");
+		IWL_DEBUG_SCAN(priv,
+			       "SCAN request during internal scan - defer\n");
+		priv->scan_request = req;
+		priv->scan_vif = vif;
 		ret = 0;
-	} else
+	} else {
+		priv->scan_request = req;
+		priv->scan_vif = vif;
+		/*
+		 * mac80211 will only ask for one band at a time
+		 * so using channels[0] here is ok
+		 */
 		ret = iwl_scan_initiate(priv, vif, IWL_SCAN_NORMAL,
 					req->channels[0]->band);
+		if (ret) {
+			priv->scan_request = NULL;
+			priv->scan_vif = NULL;
+		}
+	}
 
 	IWL_DEBUG_MAC80211(priv, "leave\n");
 
-out_unlock:
 	mutex_unlock(&priv->mutex);
 
 	return ret;
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 8b1cef0..4bf3cf4 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -863,6 +863,7 @@ static void _rtl_usb_tx_preprocess(struct ieee80211_hw *hw, struct sk_buff *skb,
 	u8 tid = 0;
 	u16 seq_number = 0;
 
+	memset(&tcb_desc, 0, sizeof(struct rtl_tcb_desc));
 	if (ieee80211_is_auth(fc)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, ("MAC80211_LINKING\n"));
 		rtl_ips_nic_on(hw);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e83e7fe..ea40d54 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4113,9 +4113,12 @@ static int nl80211_crypto_settings(struct cfg80211_registered_device *rdev,
 		if (len % sizeof(u32))
 			return -EINVAL;
 
+		if (settings->n_akm_suites > NL80211_MAX_NR_AKM_SUITES)
+			return -EINVAL;
+
 		memcpy(settings->akm_suites, data, len);
 
-		for (i = 0; i < settings->n_ciphers_pairwise; i++)
+		for (i = 0; i < settings->n_akm_suites; i++)
 			if (!nl80211_valid_akm_suite(settings->akm_suites[i]))
 				return -EINVAL;
 	}
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
