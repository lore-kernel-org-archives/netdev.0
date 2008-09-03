From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-09-03
Date: Wed, 3 Sep 2008 16:32:40 -0400
Message-ID: <20080903203239.GA21704@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43863 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbYICUpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 16:45:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another quick round of fixes for 2.6.27...the iwlwifi ones should be
familiar to you.  The ath9k ones are already in net-next-2.6, but I
think they are good fixes and they may play a part in eventually solving
bug 11394 at bugzilla.kernel.org.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 37b08e34a98c664bea86e3fae718ac45a46b7276:
  David S. Miller (1):
        ipsec: Fix deadlock in xfrm_state management.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Assaf Krauss (1):
      iwlwifi: W/A for the TSF correction in IBSS

Gregory Greenman (2):
      iwlwifi: call apm stop on exit
      iwlwifi: fix STATUS_EXIT_PENDING is not set on pci_remove

Jouni Malinen (2):
      ath9k: Fix TX status reporting
      ath9k: Fix TX control flag use for no ACK and RTS/CTS

Mohamed Abbas (1):
      iwlwifi: remove false rxon if rx chain changes

Ron Rindjunsky (2):
      iwlwifi: fix hidden ssid discovery in passive channels
      iwlwifi: fix station mimo power save values

Tomas Winkler (2):
      iwlwifi: fix rx_chain computation
      iwlwifi: fix Tx cmd memory allocation failure handling

 drivers/net/wireless/ath9k/main.c         |   12 ++++-
 drivers/net/wireless/ath9k/xmit.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c    |   27 ++++++-----
 drivers/net/wireless/iwlwifi/iwl-core.c   |   77 +++++++++++++++++------------
 drivers/net/wireless/iwlwifi/iwl-dev.h    |    1 -
 drivers/net/wireless/iwlwifi/iwl-rx.c     |    5 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c     |   27 ++++++----
 9 files changed, 97 insertions(+), 61 deletions(-)

diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index 95b3371..c5107f2 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -1067,8 +1067,16 @@ void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 		tx_info->flags |= IEEE80211_TX_STAT_AMPDU_NO_BACK;
 		tx_status->flags &= ~ATH_TX_BAR;
 	}
-	if (tx_status->flags)
-		tx_info->status.excessive_retries = 1;
+
+	if (tx_status->flags & (ATH_TX_ERROR | ATH_TX_XRETRY)) {
+		if (!(tx_info->flags & IEEE80211_TX_CTL_NO_ACK)) {
+			/* Frame was not ACKed, but an ACK was expected */
+			tx_info->status.excessive_retries = 1;
+		}
+	} else {
+		/* Frame was ACKed */
+		tx_info->flags |= IEEE80211_TX_STAT_ACK;
+	}
 
 	tx_info->status.retry_count = tx_status->retries;
 
diff --git a/drivers/net/wireless/ath9k/xmit.c b/drivers/net/wireless/ath9k/xmit.c
index 157f830..550129f 100644
--- a/drivers/net/wireless/ath9k/xmit.c
+++ b/drivers/net/wireless/ath9k/xmit.c
@@ -357,9 +357,9 @@ static int ath_tx_prepare(struct ath_softc *sc,
 	txctl->flags = ATH9K_TXDESC_CLRDMASK;    /* needed for crypto errors */
 
 	if (tx_info->flags & IEEE80211_TX_CTL_NO_ACK)
-		tx_info->flags |= ATH9K_TXDESC_NOACK;
+		txctl->flags |= ATH9K_TXDESC_NOACK;
 	if (tx_info->flags & IEEE80211_TX_CTL_USE_RTS_CTS)
-		tx_info->flags |= ATH9K_TXDESC_RTSENA;
+		txctl->flags |= ATH9K_TXDESC_RTSENA;
 
 	/*
 	 * Setup for rate calculations.
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 754fef5..90a2b6d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -1153,7 +1153,8 @@ static int rs_switch_to_mimo2(struct iwl_priv *priv,
 	    !sta->ht_info.ht_supported)
 		return -1;
 
-	if (priv->current_ht_config.tx_mimo_ps_mode == IWL_MIMO_PS_STATIC)
+	if (((sta->ht_info.cap & IEEE80211_HT_CAP_MIMO_PS) >> 2)
+						== IWL_MIMO_PS_STATIC)
 		return -1;
 
 	/* Need both Tx chains/antennas to support MIMO */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index c0b73c4..e01f048 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -181,14 +181,14 @@ static int iwl4965_check_rxon_cmd(struct iwl_rxon_cmd *rxon)
 }
 
 /**
- * iwl4965_full_rxon_required - check if full RXON (vs RXON_ASSOC) cmd is needed
+ * iwl_full_rxon_required - check if full RXON (vs RXON_ASSOC) cmd is needed
  * @priv: staging_rxon is compared to active_rxon
  *
  * If the RXON structure is changing enough to require a new tune,
  * or is clearing the RXON_FILTER_ASSOC_MSK, then return 1 to indicate that
  * a new tune (full RXON command, rather than RXON_ASSOC cmd) is required.
  */
-static int iwl4965_full_rxon_required(struct iwl_priv *priv)
+static int iwl_full_rxon_required(struct iwl_priv *priv)
 {
 
 	/* These items are only settable from the full RXON command */
@@ -207,7 +207,6 @@ static int iwl4965_full_rxon_required(struct iwl_priv *priv)
 	     priv->active_rxon.ofdm_ht_single_stream_basic_rates) ||
 	    (priv->staging_rxon.ofdm_ht_dual_stream_basic_rates !=
 	     priv->active_rxon.ofdm_ht_dual_stream_basic_rates) ||
-	    (priv->staging_rxon.rx_chain != priv->active_rxon.rx_chain) ||
 	    (priv->staging_rxon.assoc_id != priv->active_rxon.assoc_id))
 		return 1;
 
@@ -263,7 +262,7 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv)
 	/* If we don't need to send a full RXON, we can use
 	 * iwl4965_rxon_assoc_cmd which is used to reconfigure filter
 	 * and other flags for the current radio configuration. */
-	if (!iwl4965_full_rxon_required(priv)) {
+	if (!iwl_full_rxon_required(priv)) {
 		ret = iwl_send_rxon_assoc(priv);
 		if (ret) {
 			IWL_ERROR("Error setting RXON_ASSOC (%d)\n", ret);
@@ -587,8 +586,6 @@ static void iwl4965_ht_conf(struct iwl_priv *priv,
 		iwl_conf->supported_chan_width = 0;
 	}
 
-	iwl_conf->tx_mimo_ps_mode =
-		(u8)((ht_conf->cap & IEEE80211_HT_CAP_MIMO_PS) >> 2);
 	memcpy(iwl_conf->supp_mcs_set, ht_conf->supp_mcs_set, 16);
 
 	iwl_conf->control_channel = ht_bss_conf->primary_channel;
@@ -2190,7 +2187,10 @@ static void __iwl4965_down(struct iwl_priv *priv)
 	udelay(5);
 
 	/* FIXME: apm_ops.suspend(priv) */
-	priv->cfg->ops->lib->apm_ops.reset(priv);
+	if (exit_pending || test_bit(STATUS_IN_SUSPEND, &priv->status))
+		priv->cfg->ops->lib->apm_ops.stop(priv);
+	else
+		priv->cfg->ops->lib->apm_ops.reset(priv);
 	priv->cfg->ops->lib->free_shared_mem(priv);
 
  exit:
@@ -3588,7 +3588,7 @@ static int iwl4965_mac_beacon_update(struct ieee80211_hw *hw, struct sk_buff *sk
 
 	priv->assoc_id = 0;
 	timestamp = ((struct ieee80211_mgmt *)skb->data)->u.beacon.timestamp;
-	priv->timestamp = le64_to_cpu(timestamp) +  (priv->beacon_int * 1000);
+	priv->timestamp = le64_to_cpu(timestamp);
 
 	IWL_DEBUG_MAC80211("leave\n");
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -4372,15 +4372,18 @@ static void __devexit iwl4965_pci_remove(struct pci_dev *pdev)
 	iwl_dbgfs_unregister(priv);
 	sysfs_remove_group(&pdev->dev.kobj, &iwl4965_attribute_group);
 
+	/* ieee80211_unregister_hw call wil cause iwl4965_mac_stop to
+	 * to be called and iwl4965_down since we are removing the device
+	 * we need to set STATUS_EXIT_PENDING bit.
+	 */
+	set_bit(STATUS_EXIT_PENDING, &priv->status);
 	if (priv->mac80211_registered) {
 		ieee80211_unregister_hw(priv->hw);
 		priv->mac80211_registered = 0;
+	} else {
+		iwl4965_down(priv);
 	}
 
-	set_bit(STATUS_EXIT_PENDING, &priv->status);
-
-	iwl4965_down(priv);
-
 	/* make sure we flush any pending irq or
 	 * tasklet for the driver
 	 */
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index c72f725..80f2f84 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -592,12 +592,11 @@ static void iwlcore_free_geos(struct iwl_priv *priv)
 	clear_bit(STATUS_GEO_CONFIGURED, &priv->status);
 }
 
-static u8 is_single_rx_stream(struct iwl_priv *priv)
+static bool is_single_rx_stream(struct iwl_priv *priv)
 {
 	return !priv->current_ht_config.is_ht ||
 	       ((priv->current_ht_config.supp_mcs_set[1] == 0) &&
-		(priv->current_ht_config.supp_mcs_set[2] == 0)) ||
-	       priv->ps_mode == IWL_MIMO_PS_STATIC;
+		(priv->current_ht_config.supp_mcs_set[2] == 0));
 }
 
 static u8 iwl_is_channel_extension(struct iwl_priv *priv,
@@ -704,33 +703,39 @@ EXPORT_SYMBOL(iwl_set_rxon_ht);
  * MIMO (dual stream) requires at least 2, but works better with 3.
  * This does not determine *which* chains to use, just how many.
  */
-static int iwlcore_get_rx_chain_counter(struct iwl_priv *priv,
-					u8 *idle_state, u8 *rx_state)
+static int iwl_get_active_rx_chain_count(struct iwl_priv *priv)
 {
-	u8 is_single = is_single_rx_stream(priv);
-	u8 is_cam = test_bit(STATUS_POWER_PMI, &priv->status) ? 0 : 1;
+	bool is_single = is_single_rx_stream(priv);
+	bool is_cam = !test_bit(STATUS_POWER_PMI, &priv->status);
 
 	/* # of Rx chains to use when expecting MIMO. */
 	if (is_single || (!is_cam && (priv->ps_mode == IWL_MIMO_PS_STATIC)))
-		*rx_state = 2;
+		return 2;
 	else
-		*rx_state = 3;
+		return 3;
+}
 
+static int iwl_get_idle_rx_chain_count(struct iwl_priv *priv, int active_cnt)
+{
+	int idle_cnt;
+	bool is_cam = !test_bit(STATUS_POWER_PMI, &priv->status);
 	/* # Rx chains when idling and maybe trying to save power */
 	switch (priv->ps_mode) {
 	case IWL_MIMO_PS_STATIC:
 	case IWL_MIMO_PS_DYNAMIC:
-		*idle_state = (is_cam) ? 2 : 1;
+		idle_cnt = (is_cam) ? 2 : 1;
 		break;
 	case IWL_MIMO_PS_NONE:
-		*idle_state = (is_cam) ? *rx_state : 1;
+		idle_cnt = (is_cam) ? active_cnt : 1;
 		break;
+	case IWL_MIMO_PS_INVALID:
 	default:
-		*idle_state = 1;
+		IWL_ERROR("invalide mimo ps mode %d\n", priv->ps_mode);
+		WARN_ON(1);
+		idle_cnt = -1;
 		break;
 	}
-
-	return 0;
+	return idle_cnt;
 }
 
 /**
@@ -741,34 +746,44 @@ static int iwlcore_get_rx_chain_counter(struct iwl_priv *priv,
  */
 void iwl_set_rxon_chain(struct iwl_priv *priv)
 {
-	u8 is_single = is_single_rx_stream(priv);
-	u8 idle_state, rx_state;
-
-	priv->staging_rxon.rx_chain = 0;
-	rx_state = idle_state = 3;
+	bool is_single = is_single_rx_stream(priv);
+	bool is_cam = !test_bit(STATUS_POWER_PMI, &priv->status);
+	u8 idle_rx_cnt, active_rx_cnt;
+	u16 rx_chain;
 
 	/* Tell uCode which antennas are actually connected.
 	 * Before first association, we assume all antennas are connected.
 	 * Just after first association, iwl_chain_noise_calibration()
 	 *    checks which antennas actually *are* connected. */
-	priv->staging_rxon.rx_chain |=
-		    cpu_to_le16(priv->hw_params.valid_rx_ant <<
-						 RXON_RX_CHAIN_VALID_POS);
+	rx_chain = priv->hw_params.valid_rx_ant << RXON_RX_CHAIN_VALID_POS;
 
 	/* How many receivers should we use? */
-	iwlcore_get_rx_chain_counter(priv, &idle_state, &rx_state);
-	priv->staging_rxon.rx_chain |=
-		cpu_to_le16(rx_state << RXON_RX_CHAIN_MIMO_CNT_POS);
-	priv->staging_rxon.rx_chain |=
-		cpu_to_le16(idle_state << RXON_RX_CHAIN_CNT_POS);
-
-	if (!is_single && (rx_state >= 2) &&
-	    !test_bit(STATUS_POWER_PMI, &priv->status))
+	active_rx_cnt = iwl_get_active_rx_chain_count(priv);
+	idle_rx_cnt = iwl_get_idle_rx_chain_count(priv, active_rx_cnt);
+
+	/* correct rx chain count accoridng hw settings */
+	if (priv->hw_params.rx_chains_num < active_rx_cnt)
+		active_rx_cnt = priv->hw_params.rx_chains_num;
+
+	if (priv->hw_params.rx_chains_num < idle_rx_cnt)
+		idle_rx_cnt = priv->hw_params.rx_chains_num;
+
+	rx_chain |= active_rx_cnt << RXON_RX_CHAIN_MIMO_CNT_POS;
+	rx_chain |= idle_rx_cnt  << RXON_RX_CHAIN_CNT_POS;
+
+	priv->staging_rxon.rx_chain = cpu_to_le16(rx_chain);
+
+	if (!is_single && (active_rx_cnt >= 2) && is_cam)
 		priv->staging_rxon.rx_chain |= RXON_RX_CHAIN_MIMO_FORCE_MSK;
 	else
 		priv->staging_rxon.rx_chain &= ~RXON_RX_CHAIN_MIMO_FORCE_MSK;
 
-	IWL_DEBUG_ASSOC("rx chain %X\n", priv->staging_rxon.rx_chain);
+	IWL_DEBUG_ASSOC("rx_chain=0x%Xi active=%d idle=%d\n",
+			priv->staging_rxon.rx_chain,
+			active_rx_cnt, idle_rx_cnt);
+
+	WARN_ON(active_rx_cnt == 0 || idle_rx_cnt == 0 ||
+		active_rx_cnt < idle_rx_cnt);
 }
 EXPORT_SYMBOL(iwl_set_rxon_chain);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index c19db43..cdfb343 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -412,7 +412,6 @@ struct iwl_ht_info {
 	/* self configuration data */
 	u8 is_ht;
 	u8 supported_chan_width;
-	u16 tx_mimo_ps_mode;
 	u8 is_green_field;
 	u8 sgf;			/* HT_SHORT_GI_* short guard interval */
 	u8 max_amsdu_size;
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index f3f6ea4..e81bfc4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -1173,7 +1173,10 @@ void iwl_rx_reply_rx(struct iwl_priv *priv,
 
 	rx_status.antenna = 0;
 	rx_status.flag = 0;
-	rx_status.flag |= RX_FLAG_TSFT;
+
+	/* TSF isn't reliable. In order to allow smooth user experience,
+	 * this W/A doesn't propagate it to the mac80211 */
+	/*rx_status.flag |= RX_FLAG_TSFT;*/
 
 	if ((unlikely(rx_start->cfg_phy_cnt > 20))) {
 		IWL_DEBUG_DROP("dsp size out of range [0,20]: %d/n",
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 9bb6adb..6c8ac3a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -421,7 +421,7 @@ static int iwl_get_channels_for_scan(struct iwl_priv *priv,
 		else
 			scan_ch->type = SCAN_CHANNEL_TYPE_ACTIVE;
 
-		if ((scan_ch->type & SCAN_CHANNEL_TYPE_ACTIVE) && n_probes)
+		if (n_probes)
 			scan_ch->type |= IWL_SCAN_PROBE_MASK(n_probes);
 
 		scan_ch->active_dwell = cpu_to_le16(active_dwell);
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index ff879d4..78b1a7a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -402,12 +402,11 @@ static int iwl_hw_tx_queue_init(struct iwl_priv *priv,
 /**
  * iwl_tx_queue_init - Allocate and initialize one tx/cmd queue
  */
-static int iwl_tx_queue_init(struct iwl_priv *priv,
-			     struct iwl_tx_queue *txq,
+static int iwl_tx_queue_init(struct iwl_priv *priv, struct iwl_tx_queue *txq,
 			     int slots_num, u32 txq_id)
 {
 	int i, len;
-	int rc = 0;
+	int ret;
 
 	/*
 	 * Alloc buffer array for commands (Tx or other types of commands).
@@ -428,17 +427,14 @@ static int iwl_tx_queue_init(struct iwl_priv *priv,
 
 		txq->cmd[i] = kmalloc(len, GFP_KERNEL);
 		if (!txq->cmd[i])
-			return -ENOMEM;
+			goto err;
 	}
 
 	/* Alloc driver data array and TFD circular buffer */
-	rc = iwl_tx_queue_alloc(priv, txq, txq_id);
-	if (rc) {
-		for (i = 0; i < slots_num; i++)
-			kfree(txq->cmd[i]);
+	ret = iwl_tx_queue_alloc(priv, txq, txq_id);
+	if (ret)
+		goto err;
 
-		return -ENOMEM;
-	}
 	txq->need_update = 0;
 
 	/* TFD_QUEUE_SIZE_MAX must be power-of-two size, otherwise
@@ -452,6 +448,17 @@ static int iwl_tx_queue_init(struct iwl_priv *priv,
 	iwl_hw_tx_queue_init(priv, txq);
 
 	return 0;
+err:
+	for (i = 0; i < slots_num; i++) {
+		kfree(txq->cmd[i]);
+		txq->cmd[i] = NULL;
+	}
+
+	if (txq_id == IWL_CMD_QUEUE_NUM) {
+		kfree(txq->cmd[slots_num]);
+		txq->cmd[slots_num] = NULL;
+	}
+	return -ENOMEM;
 }
 /**
  * iwl_hw_txq_ctx_free - Free TXQ Context
-- 
John W. Linville
linville@tuxdriver.com
