From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Thu, 25 Oct 2007 23:08:26 -0400
Message-ID: <20071026030826.GB14080@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff,

A few fixes for 2.6.24...

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik

---

The following changes since commit c9927c2bf4f45bb85e8b502ab3fb79ad6483c244:
  Linus Torvalds (1):
        Linux 2.6.24-rc1

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Anton Blanchard (3):
      ipw2100/ipw2200: jiffies_round -> jiffies_round_relative
      rt2x00: jiffies_round -> jiffies_round_relative
      b43/b43legacy: jiffies_round -> jiffies_round_relative

Michael Wu (1):
      rtl8187: Allow multicast frames

Mohamed Abbas (3):
      iwl4965: fix scan problem
      iwl3945: cancel scan on rxon command
      iwl3945: fix direct scan problem

Tomas Winkler (1):
      iwlwifi: fix sending probe request in iwl 4965

mabbas (1):
      iwl4965: fix driver hang related to hardware scan

 drivers/net/wireless/b43/main.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    2 +-
 drivers/net/wireless/ipw2100.c              |   11 +++--
 drivers/net/wireless/ipw2200.c              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   56 +++++++++++++++++++++++----
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   56 +++++++++++++++++++++++----
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    2 +-
 drivers/net/wireless/rtl8187_dev.c          |   20 +++++----
 9 files changed, 121 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 9d9ff76..5058e60 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2391,7 +2391,7 @@ out_requeue:
 	if (b43_debug(dev, B43_DBG_PWORK_FAST))
 		delay = msecs_to_jiffies(50);
 	else
-		delay = round_jiffies(HZ * 15);
+		delay = round_jiffies_relative(HZ * 15);
 	queue_delayed_work(wl->hw->workqueue, &dev->periodic_work, delay);
 out:
 	mutex_unlock(&wl->mutex);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index d09479e..f0e56df 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2260,7 +2260,7 @@ out_requeue:
 	if (b43legacy_debug(dev, B43legacy_DBG_PWORK_FAST))
 		delay = msecs_to_jiffies(50);
 	else
-		delay = round_jiffies(HZ);
+		delay = round_jiffies_relative(HZ);
 	queue_delayed_work(dev->wl->hw->workqueue,
 			   &dev->periodic_work, delay);
 out:
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index a6c7904..8d53d08 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -1769,7 +1769,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
 		if (priv->stop_rf_kill) {
 			priv->stop_rf_kill = 0;
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(HZ));
+					   round_jiffies_relative(HZ));
 		}
 
 		deferred = 1;
@@ -2086,7 +2086,8 @@ static void isr_indicate_rf_kill(struct ipw2100_priv *priv, u32 status)
 	/* Make sure the RF Kill check timer is running */
 	priv->stop_rf_kill = 0;
 	cancel_delayed_work(&priv->rf_kill);
-	queue_delayed_work(priv->workqueue, &priv->rf_kill, round_jiffies(HZ));
+	queue_delayed_work(priv->workqueue, &priv->rf_kill,
+			   round_jiffies_relative(HZ));
 }
 
 static void send_scan_event(void *data)
@@ -2123,7 +2124,7 @@ static void isr_scan_complete(struct ipw2100_priv *priv, u32 status)
 		if (!delayed_work_pending(&priv->scan_event_later))
 			queue_delayed_work(priv->workqueue,
 					&priv->scan_event_later,
-					round_jiffies(msecs_to_jiffies(4000)));
+					round_jiffies_relative(msecs_to_jiffies(4000)));
 	} else {
 		priv->user_requested_scan = 0;
 		cancel_delayed_work(&priv->scan_event_later);
@@ -4242,7 +4243,7 @@ static int ipw_radio_kill_sw(struct ipw2100_priv *priv, int disable_radio)
 			priv->stop_rf_kill = 0;
 			cancel_delayed_work(&priv->rf_kill);
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(HZ));
+					   round_jiffies_relative(HZ));
 		} else
 			schedule_reset(priv);
 	}
@@ -5981,7 +5982,7 @@ static void ipw2100_rf_kill(struct work_struct *work)
 		IPW_DEBUG_RF_KILL("RF Kill active, rescheduling GPIO check\n");
 		if (!priv->stop_rf_kill)
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(HZ));
+					   round_jiffies_relative(HZ));
 		goto exit_unlock;
 	}
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index e3c8284..54f44e5 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1753,7 +1753,7 @@ static int ipw_radio_kill_sw(struct ipw_priv *priv, int disable_radio)
 			/* Make sure the RF_KILL check timer is running */
 			cancel_delayed_work(&priv->rf_kill);
 			queue_delayed_work(priv->workqueue, &priv->rf_kill,
-					   round_jiffies(2 * HZ));
+					   round_jiffies_relative(2 * HZ));
 		} else
 			queue_work(priv->workqueue, &priv->up);
 	}
@@ -4364,7 +4364,7 @@ static void handle_scan_event(struct ipw_priv *priv)
 	if (!priv->user_requested_scan) {
 		if (!delayed_work_pending(&priv->scan_event))
 			queue_delayed_work(priv->workqueue, &priv->scan_event,
-					 round_jiffies(msecs_to_jiffies(4000)));
+					 round_jiffies_relative(msecs_to_jiffies(4000)));
 	} else {
 		union iwreq_data wrqu;
 
@@ -4728,7 +4728,7 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 				 && priv->status & STATUS_ASSOCIATED)
 				queue_delayed_work(priv->workqueue,
 						   &priv->request_scan,
-						   round_jiffies(HZ));
+						   round_jiffies_relative(HZ));
 
 			/* Send an empty event to user space.
 			 * We don't send the received data on the event because
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 557deeb..891f90d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -3232,9 +3232,7 @@ int iwl4965_tx_cmd(struct iwl_priv *priv, struct iwl_cmd *out_cmd,
 	tx->rate_n_flags = iwl_hw_set_rate_n_flags(iwl_rates[rate_index].plcp,
 						rate_flags);
 
-	if (ieee80211_is_probe_request(fc))
-		tx->tx_flags |= TX_CMD_FLG_TSF_MSK;
-	else if (ieee80211_is_back_request(fc))
+	if (ieee80211_is_back_request(fc))
 		tx->tx_flags |= TX_CMD_FLG_ACK_MSK |
 			TX_CMD_FLG_IMM_BA_RSP_MASK;
 #ifdef CONFIG_IWLWIFI_HT
@@ -3872,7 +3870,7 @@ static void iwl4965_rx_reply_rx(struct iwl_priv *priv,
 			 */
 		case IEEE80211_STYPE_ASSOC_RESP:
 		case IEEE80211_STYPE_REASSOC_RESP:
-			if (network_packet && iwl_is_associated(priv)) {
+			if (network_packet) {
 #ifdef CONFIG_IWLWIFI_HT
 				u8 *pos = NULL;
 				struct ieee802_11_elems elems;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 83019d1..4f22a71 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6478,8 +6478,9 @@ static void iwl_bg_scan_check(struct work_struct *data)
 		IWL_DEBUG(IWL_DL_INFO | IWL_DL_SCAN,
 			  "Scan completion watchdog resetting adapter (%dms)\n",
 			  jiffies_to_msecs(IWL_SCAN_CHECK_WATCHDOG));
+
 		if (!test_bit(STATUS_EXIT_PENDING, &priv->status))
-			queue_work(priv->workqueue, &priv->restart);
+			iwl_send_scan_abort(priv);
 	}
 	mutex_unlock(&priv->mutex);
 }
@@ -6575,7 +6576,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		spin_unlock_irqrestore(&priv->lock, flags);
 
 		scan->suspend_time = 0;
-		scan->max_out_time = cpu_to_le32(600 * 1024);
+		scan->max_out_time = cpu_to_le32(200 * 1024);
 		if (!interval)
 			interval = suspend_time;
 		/*
@@ -6605,7 +6606,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		memcpy(scan->direct_scan[0].ssid,
 		       priv->direct_ssid, priv->direct_ssid_len);
 		direct_mask = 1;
-	} else if (!iwl_is_associated(priv)) {
+	} else if (!iwl_is_associated(priv) && priv->essid_len) {
 		scan->direct_scan[0].id = WLAN_EID_SSID;
 		scan->direct_scan[0].len = priv->essid_len;
 		memcpy(scan->direct_scan[0].ssid, priv->essid, priv->essid_len);
@@ -6744,6 +6745,12 @@ static void iwl_bg_post_associate(struct work_struct *data)
 
 	mutex_lock(&priv->mutex);
 
+	if (!priv->interface_id || !priv->is_open) {
+		mutex_unlock(&priv->mutex);
+		return;
+	}
+	iwl_scan_cancel_timeout(priv, 200);
+
 	conf = ieee80211_get_hw_conf(priv->hw);
 
 	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
@@ -6882,9 +6889,19 @@ static void iwl_mac_stop(struct ieee80211_hw *hw)
 	struct iwl_priv *priv = hw->priv;
 
 	IWL_DEBUG_MAC80211("enter\n");
+
+
+	mutex_lock(&priv->mutex);
+	/* stop mac, cancel any scan request and clear
+	 * RXON_FILTER_ASSOC_MSK BIT
+	 */
 	priv->is_open = 0;
-	/*netif_stop_queue(dev); */
-	flush_workqueue(priv->workqueue);
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+	mutex_unlock(&priv->mutex);
+
 	IWL_DEBUG_MAC80211("leave\n");
 }
 
@@ -7169,8 +7186,6 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		if (priv->iw_mode == IEEE80211_IF_TYPE_AP)
 			iwl_config_ap(priv);
 		else {
-			priv->staging_rxon.filter_flags |=
-						RXON_FILTER_ASSOC_MSK;
 			rc = iwl_commit_rxon(priv);
 			if ((priv->iw_mode == IEEE80211_IF_TYPE_STA) && rc)
 				iwl_add_station(priv,
@@ -7178,6 +7193,7 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		}
 
 	} else {
+		iwl_scan_cancel_timeout(priv, 100);
 		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
 		iwl_commit_rxon(priv);
 	}
@@ -7217,6 +7233,12 @@ static void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 	IWL_DEBUG_MAC80211("enter\n");
 
 	mutex_lock(&priv->mutex);
+
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+
 	if (priv->interface_id == conf->if_id) {
 		priv->interface_id = 0;
 		memset(priv->bssid, 0, ETH_ALEN);
@@ -7238,6 +7260,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 	IWL_DEBUG_MAC80211("enter\n");
 
+	mutex_lock(&priv->mutex);
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!iwl_is_ready_rf(priv)) {
@@ -7268,7 +7291,8 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 		priv->direct_ssid_len = (u8)
 		    min((u8) len, (u8) IW_ESSID_MAX_SIZE);
 		memcpy(priv->direct_ssid, ssid, priv->direct_ssid_len);
-	}
+	} else
+		priv->one_direct_scan = 0;
 
 	rc = iwl_scan_initiate(priv);
 
@@ -7276,6 +7300,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 out_unlock:
 	spin_unlock_irqrestore(&priv->lock, flags);
+	mutex_unlock(&priv->mutex);
 
 	return rc;
 }
@@ -7310,6 +7335,8 @@ static int iwl_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	mutex_lock(&priv->mutex);
 
+	iwl_scan_cancel_timeout(priv, 100);
+
 	switch (cmd) {
 	case  SET_KEY:
 		rc = iwl_update_sta_key_info(priv, key, sta_id);
@@ -7479,8 +7506,18 @@ static void iwl_mac_reset_tsf(struct ieee80211_hw *hw)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
+	/* we are restarting association process
+	 * clear RXON_FILTER_ASSOC_MSK bit
+	*/
+	if (priv->iw_mode != IEEE80211_IF_TYPE_AP) {
+		iwl_scan_cancel_timeout(priv, 100);
+		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+		iwl_commit_rxon(priv);
+	}
+
 	/* Per mac80211.h: This is only used in IBSS mode... */
 	if (priv->iw_mode != IEEE80211_IF_TYPE_IBSS) {
+
 		IWL_DEBUG_MAC80211("leave - not in IBSS\n");
 		mutex_unlock(&priv->mutex);
 		return;
@@ -8558,6 +8595,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 		iwl_rate_control_unregister(priv->hw);
 	}
 
+	/*netif_stop_queue(dev); */
+	flush_workqueue(priv->workqueue);
+
 	/* ieee80211_unregister_hw calls iwl_mac_stop, which flushes
 	 * priv->workqueue... so we can't take down the workqueue
 	 * until now... */
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 5e12792..d60adcb 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6845,8 +6845,9 @@ static void iwl_bg_scan_check(struct work_struct *data)
 		IWL_DEBUG(IWL_DL_INFO | IWL_DL_SCAN,
 			  "Scan completion watchdog resetting adapter (%dms)\n",
 			  jiffies_to_msecs(IWL_SCAN_CHECK_WATCHDOG));
+
 		if (!test_bit(STATUS_EXIT_PENDING, &priv->status))
-			queue_work(priv->workqueue, &priv->restart);
+			iwl_send_scan_abort(priv);
 	}
 	mutex_unlock(&priv->mutex);
 }
@@ -6942,7 +6943,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		spin_unlock_irqrestore(&priv->lock, flags);
 
 		scan->suspend_time = 0;
-		scan->max_out_time = cpu_to_le32(600 * 1024);
+		scan->max_out_time = cpu_to_le32(200 * 1024);
 		if (!interval)
 			interval = suspend_time;
 
@@ -6965,7 +6966,7 @@ static void iwl_bg_request_scan(struct work_struct *data)
 		memcpy(scan->direct_scan[0].ssid,
 		       priv->direct_ssid, priv->direct_ssid_len);
 		direct_mask = 1;
-	} else if (!iwl_is_associated(priv)) {
+	} else if (!iwl_is_associated(priv) && priv->essid_len) {
 		scan->direct_scan[0].id = WLAN_EID_SSID;
 		scan->direct_scan[0].len = priv->essid_len;
 		memcpy(scan->direct_scan[0].ssid, priv->essid, priv->essid_len);
@@ -7118,6 +7119,12 @@ static void iwl_bg_post_associate(struct work_struct *data)
 
 	mutex_lock(&priv->mutex);
 
+	if (!priv->interface_id || !priv->is_open) {
+		mutex_unlock(&priv->mutex);
+		return;
+	}
+	iwl_scan_cancel_timeout(priv, 200);
+
 	conf = ieee80211_get_hw_conf(priv->hw);
 
 	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
@@ -7271,9 +7278,19 @@ static void iwl_mac_stop(struct ieee80211_hw *hw)
 	struct iwl_priv *priv = hw->priv;
 
 	IWL_DEBUG_MAC80211("enter\n");
+
+
+	mutex_lock(&priv->mutex);
+	/* stop mac, cancel any scan request and clear
+	 * RXON_FILTER_ASSOC_MSK BIT
+	 */
 	priv->is_open = 0;
-	/*netif_stop_queue(dev); */
-	flush_workqueue(priv->workqueue);
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+	mutex_unlock(&priv->mutex);
+
 	IWL_DEBUG_MAC80211("leave\n");
 }
 
@@ -7573,8 +7590,6 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		if (priv->iw_mode == IEEE80211_IF_TYPE_AP)
 			iwl_config_ap(priv);
 		else {
-			priv->staging_rxon.filter_flags |=
-						RXON_FILTER_ASSOC_MSK;
 			rc = iwl_commit_rxon(priv);
 			if ((priv->iw_mode == IEEE80211_IF_TYPE_STA) && rc)
 				iwl_rxon_add_station(
@@ -7582,6 +7597,7 @@ static int iwl_mac_config_interface(struct ieee80211_hw *hw, int if_id,
 		}
 
 	} else {
+		iwl_scan_cancel_timeout(priv, 100);
 		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
 		iwl_commit_rxon(priv);
 	}
@@ -7621,6 +7637,12 @@ static void iwl_mac_remove_interface(struct ieee80211_hw *hw,
 	IWL_DEBUG_MAC80211("enter\n");
 
 	mutex_lock(&priv->mutex);
+
+	iwl_scan_cancel_timeout(priv, 100);
+	cancel_delayed_work(&priv->post_associate);
+	priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+	iwl_commit_rxon(priv);
+
 	if (priv->interface_id == conf->if_id) {
 		priv->interface_id = 0;
 		memset(priv->bssid, 0, ETH_ALEN);
@@ -7642,6 +7664,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 	IWL_DEBUG_MAC80211("enter\n");
 
+	mutex_lock(&priv->mutex);
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!iwl_is_ready_rf(priv)) {
@@ -7672,7 +7695,8 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 		priv->direct_ssid_len = (u8)
 		    min((u8) len, (u8) IW_ESSID_MAX_SIZE);
 		memcpy(priv->direct_ssid, ssid, priv->direct_ssid_len);
-	}
+	} else
+		priv->one_direct_scan = 0;
 
 	rc = iwl_scan_initiate(priv);
 
@@ -7680,6 +7704,7 @@ static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 
 out_unlock:
 	spin_unlock_irqrestore(&priv->lock, flags);
+	mutex_unlock(&priv->mutex);
 
 	return rc;
 }
@@ -7713,6 +7738,8 @@ static int iwl_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	mutex_lock(&priv->mutex);
 
+	iwl_scan_cancel_timeout(priv, 100);
+
 	switch (cmd) {
 	case  SET_KEY:
 		rc = iwl_update_sta_key_info(priv, key, sta_id);
@@ -7903,8 +7930,18 @@ static void iwl_mac_reset_tsf(struct ieee80211_hw *hw)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
+	/* we are restarting association process
+	 * clear RXON_FILTER_ASSOC_MSK bit
+	 */
+	if (priv->iw_mode != IEEE80211_IF_TYPE_AP) {
+		iwl_scan_cancel_timeout(priv, 100);
+		priv->staging_rxon.filter_flags &= ~RXON_FILTER_ASSOC_MSK;
+		iwl_commit_rxon(priv);
+	}
+
 	/* Per mac80211.h: This is only used in IBSS mode... */
 	if (priv->iw_mode != IEEE80211_IF_TYPE_IBSS) {
+
 		IWL_DEBUG_MAC80211("leave - not in IBSS\n");
 		mutex_unlock(&priv->mutex);
 		return;
@@ -9152,6 +9189,9 @@ static void iwl_pci_remove(struct pci_dev *pdev)
 		iwl_rate_control_unregister(priv->hw);
 	}
 
+	/*netif_stop_queue(dev); */
+	flush_workqueue(priv->workqueue);
+
 	/* ieee80211_unregister_hw calls iwl_mac_stop, which flushes
 	 * priv->workqueue... so we can't take down the workqueue
 	 * until now... */
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index 298faa9..06d9bc0 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -30,7 +30,7 @@
  * Interval defines
  * Both the link tuner as the rfkill will be called once per second.
  */
-#define LINK_TUNE_INTERVAL	( round_jiffies(HZ) )
+#define LINK_TUNE_INTERVAL	( round_jiffies_relative(HZ) )
 #define RFKILL_POLL_INTERVAL	( 1000 )
 
 /*
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index de61c8f..e454ae8 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -433,6 +433,9 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 
 	rtl818x_iowrite16(priv, &priv->map->INT_MASK, 0xFFFF);
 
+	rtl818x_iowrite32(priv, &priv->map->MAR[0], ~0);
+	rtl818x_iowrite32(priv, &priv->map->MAR[1], ~0);
+
 	rtl8187_init_urbs(dev);
 
 	reg = RTL818X_RX_CONF_ONLYERLPKT |
@@ -582,32 +585,31 @@ static int rtl8187_config_interface(struct ieee80211_hw *dev, int if_id,
 static void rtl8187_configure_filter(struct ieee80211_hw *dev,
 				     unsigned int changed_flags,
 				     unsigned int *total_flags,
-				     int mc_count, struct dev_addr_list *mc_list)
+				     int mc_count, struct dev_addr_list *mclist)
 {
 	struct rtl8187_priv *priv = dev->priv;
 
-	*total_flags = 0;
-
-	if (changed_flags & FIF_ALLMULTI)
-		priv->rx_conf ^= RTL818X_RX_CONF_MULTICAST;
 	if (changed_flags & FIF_FCSFAIL)
 		priv->rx_conf ^= RTL818X_RX_CONF_FCS;
 	if (changed_flags & FIF_CONTROL)
 		priv->rx_conf ^= RTL818X_RX_CONF_CTRL;
 	if (changed_flags & FIF_OTHER_BSS)
 		priv->rx_conf ^= RTL818X_RX_CONF_MONITOR;
-
-	if (mc_count > 0)
+	if (*total_flags & FIF_ALLMULTI || mc_count > 0)
 		priv->rx_conf |= RTL818X_RX_CONF_MULTICAST;
+	else
+		priv->rx_conf &= ~RTL818X_RX_CONF_MULTICAST;
+
+	*total_flags = 0;
 
-	if (priv->rx_conf & RTL818X_RX_CONF_MULTICAST)
-		*total_flags |= FIF_ALLMULTI;
 	if (priv->rx_conf & RTL818X_RX_CONF_FCS)
 		*total_flags |= FIF_FCSFAIL;
 	if (priv->rx_conf & RTL818X_RX_CONF_CTRL)
 		*total_flags |= FIF_CONTROL;
 	if (priv->rx_conf & RTL818X_RX_CONF_MONITOR)
 		*total_flags |= FIF_OTHER_BSS;
+	if (priv->rx_conf & RTL818X_RX_CONF_MULTICAST)
+		*total_flags |= FIF_ALLMULTI;
 
 	rtl818x_iowrite32_async(priv, &priv->map->RX_CONF, priv->rx_conf);
 }
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
