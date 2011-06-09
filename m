From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-06-09
Date: Thu, 9 Jun 2011 15:16:32 -0400
Message-ID: <20110609191632.GA16198@tuxdriver.com>
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

Here are some more fixes intended for 3.0...

There are two reverts, both in mac80211.  One was found to cause a
regression.  The other revert was requested by the mac80211 maintainer
(Johannes) on the basis of API abuse and a lack of faith that the
implementation actual did anything useful. :-(

This includes a fix for an IBSS-related race condition from Johannes,
and a fix for an nl80211 integer overflow from Luca.  Also included
are a couple of rtlwifi fixes from Mike McCormack, one that fixes a
packet dropping error, and another that avoids incorrectly modifying
a resubmitted skb.  But the big hero this round is Stanislaw, who
not only identified a fix from Wey-Yi that need to go for 3.0 rather
than 3.1, but he also fixed an rmmod crash in rt2x00, a locking issue
in iwlgacy, a power setting bug in iwl4965, and an 802.11n general
instability issue on iwlagn.  As a result, I am researching popular
beers in the Czech Republic... :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 0c1ad04aecb975f2a2014e1bc5a2fa23923ecbd9:

  netpoll: prevent netpoll setup on slave devices (2011-06-09 00:28:13 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git for-davem

Johannes Berg (1):
      mac80211: fix IBSS teardown race

John W. Linville (3):
      Revert "mac80211: Skip tailroom reservation for full HW-crypto devices"
      Revert "mac80211: stop queues before rate control updation"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Luciano Coelho (1):
      nl80211: fix overflow in ssid_len

Mike McCormack (2):
      rtlwifi: Fix logic in rx_interrupt
      rtlwifi: Avoid modifying skbs that are resubmitted

Stanislaw Gruszka (4):
      iwlagn: use cts-to-self protection on 5000 adapters series
      rt2x00: fix rmmod crash
      iwl4965: set tx power after rxon_assoc
      iwlegacy: fix channel switch locking

Wey-Yi Guy (1):
      iwlagn: send tx power command if defer cause by RXON not match

 drivers/net/wireless/iwlegacy/iwl-4965.c     |   12 ++++------
 drivers/net/wireless/iwlegacy/iwl-core.c     |   30 +++++++++++--------------
 drivers/net/wireless/iwlegacy/iwl-core.h     |    2 +-
 drivers/net/wireless/iwlegacy/iwl-dev.h      |   13 +----------
 drivers/net/wireless/iwlegacy/iwl4965-base.c |   20 ++++++++--------
 drivers/net/wireless/iwlwifi/iwl-5000.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c  |   12 +--------
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c  |   13 +++++++++++
 drivers/net/wireless/rt2x00/rt2x00config.c   |    3 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c      |    4 +++
 drivers/net/wireless/rtlwifi/pci.c           |   30 ++++++++++++-------------
 net/mac80211/ibss.c                          |    6 +++-
 net/mac80211/ieee80211_i.h                   |    3 --
 net/mac80211/key.c                           |   21 +----------------
 net/mac80211/mlme.c                          |    6 -----
 net/mac80211/tx.c                            |    7 +++++-
 net/wireless/nl80211.c                       |    9 +++----
 17 files changed, 81 insertions(+), 111 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl-4965.c b/drivers/net/wireless/iwlegacy/iwl-4965.c
index f9db25b..facc94e 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965.c
@@ -1218,10 +1218,10 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *c
 	 * receive commit_rxon request
 	 * abort any previous channel switch if still in process
 	 */
-	if (priv->switch_rxon.switch_in_progress &&
-	    (priv->switch_rxon.channel != ctx->staging.channel)) {
+	if (test_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status) &&
+	    (priv->switch_channel != ctx->staging.channel)) {
 		IWL_DEBUG_11H(priv, "abort channel switch on %d\n",
-		      le16_to_cpu(priv->switch_rxon.channel));
+		      le16_to_cpu(priv->switch_channel));
 		iwl_legacy_chswitch_done(priv, false);
 	}
 
@@ -1237,7 +1237,7 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *c
 
 		memcpy(active_rxon, &ctx->staging, sizeof(*active_rxon));
 		iwl_legacy_print_rx_config_cmd(priv, ctx);
-		return 0;
+		goto set_tx_power;
 	}
 
 	/* If we are currently associated and the new config requires
@@ -1317,6 +1317,7 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *c
 
 	iwl4965_init_sensitivity(priv);
 
+set_tx_power:
 	/* If we issue a new RXON command which required a tune then we must
 	 * send a new TXPOWER command or we won't be able to Tx any frames */
 	ret = iwl_legacy_set_tx_power(priv, priv->tx_power_next, true);
@@ -1403,9 +1404,6 @@ static int iwl4965_hw_channel_switch(struct iwl_priv *priv,
 		return rc;
 	}
 
-	priv->switch_rxon.channel = cmd.channel;
-	priv->switch_rxon.switch_in_progress = true;
-
 	return iwl_legacy_send_cmd_pdu(priv,
 			 REPLY_CHANNEL_SWITCH, sizeof(cmd), &cmd);
 }
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.c b/drivers/net/wireless/iwlegacy/iwl-core.c
index 42df832..3be76bd 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.c
+++ b/drivers/net/wireless/iwlegacy/iwl-core.c
@@ -859,12 +859,8 @@ void iwl_legacy_chswitch_done(struct iwl_priv *priv, bool is_success)
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return;
 
-	if (priv->switch_rxon.switch_in_progress) {
+	if (test_and_clear_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status))
 		ieee80211_chswitch_done(ctx->vif, is_success);
-		mutex_lock(&priv->mutex);
-		priv->switch_rxon.switch_in_progress = false;
-		mutex_unlock(&priv->mutex);
-	}
 }
 EXPORT_SYMBOL(iwl_legacy_chswitch_done);
 
@@ -876,19 +872,19 @@ void iwl_legacy_rx_csa(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 	struct iwl_rxon_context *ctx = &priv->contexts[IWL_RXON_CTX_BSS];
 	struct iwl_legacy_rxon_cmd *rxon = (void *)&ctx->active;
 
-	if (priv->switch_rxon.switch_in_progress) {
-		if (!le32_to_cpu(csa->status) &&
-		    (csa->channel == priv->switch_rxon.channel)) {
-			rxon->channel = csa->channel;
-			ctx->staging.channel = csa->channel;
-			IWL_DEBUG_11H(priv, "CSA notif: channel %d\n",
-			      le16_to_cpu(csa->channel));
-			iwl_legacy_chswitch_done(priv, true);
-		} else {
-			IWL_ERR(priv, "CSA notif (fail) : channel %d\n",
+	if (!test_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status))
+		return;
+
+	if (!le32_to_cpu(csa->status) && csa->channel == priv->switch_channel) {
+		rxon->channel = csa->channel;
+		ctx->staging.channel = csa->channel;
+		IWL_DEBUG_11H(priv, "CSA notif: channel %d\n",
 			      le16_to_cpu(csa->channel));
-			iwl_legacy_chswitch_done(priv, false);
-		}
+		iwl_legacy_chswitch_done(priv, true);
+	} else {
+		IWL_ERR(priv, "CSA notif (fail) : channel %d\n",
+			le16_to_cpu(csa->channel));
+		iwl_legacy_chswitch_done(priv, false);
 	}
 }
 EXPORT_SYMBOL(iwl_legacy_rx_csa);
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.h b/drivers/net/wireless/iwlegacy/iwl-core.h
index bc66c60..c5fbda0 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.h
+++ b/drivers/net/wireless/iwlegacy/iwl-core.h
@@ -560,7 +560,7 @@ void iwl_legacy_free_geos(struct iwl_priv *priv);
 #define STATUS_SCAN_HW		15
 #define STATUS_POWER_PMI	16
 #define STATUS_FW_ERROR		17
-
+#define STATUS_CHANNEL_SWITCH_PENDING 18
 
 static inline int iwl_legacy_is_ready(struct iwl_priv *priv)
 {
diff --git a/drivers/net/wireless/iwlegacy/iwl-dev.h b/drivers/net/wireless/iwlegacy/iwl-dev.h
index be0106c..ea30122 100644
--- a/drivers/net/wireless/iwlegacy/iwl-dev.h
+++ b/drivers/net/wireless/iwlegacy/iwl-dev.h
@@ -855,17 +855,6 @@ struct traffic_stats {
 };
 
 /*
- * iwl_switch_rxon: "channel switch" structure
- *
- * @ switch_in_progress: channel switch in progress
- * @ channel: new channel
- */
-struct iwl_switch_rxon {
-	bool switch_in_progress;
-	__le16 channel;
-};
-
-/*
  * schedule the timer to wake up every UCODE_TRACE_PERIOD milliseconds
  * to perform continuous uCode event logging operation if enabled
  */
@@ -1115,7 +1104,7 @@ struct iwl_priv {
 
 	struct iwl_rxon_context contexts[NUM_IWL_RXON_CTX];
 
-	struct iwl_switch_rxon switch_rxon;
+	__le16 switch_channel;
 
 	/* 1st responses from initialize and runtime uCode images.
 	 * _4965's initialize alive response contains some calibration data. */
diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
index af2ae22..7157ba5 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -2861,16 +2861,13 @@ void iwl4965_mac_channel_switch(struct ieee80211_hw *hw,
 		goto out;
 
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status) ||
-	    test_bit(STATUS_SCANNING, &priv->status))
+	    test_bit(STATUS_SCANNING, &priv->status) ||
+	    test_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status))
 		goto out;
 
 	if (!iwl_legacy_is_associated_ctx(ctx))
 		goto out;
 
-	/* channel switch in progress */
-	if (priv->switch_rxon.switch_in_progress == true)
-		goto out;
-
 	if (priv->cfg->ops->lib->set_channel_switch) {
 
 		ch = channel->hw_value;
@@ -2919,15 +2916,18 @@ void iwl4965_mac_channel_switch(struct ieee80211_hw *hw,
 			 * at this point, staging_rxon has the
 			 * configuration for channel switch
 			 */
-			if (priv->cfg->ops->lib->set_channel_switch(priv,
-								    ch_switch))
-				priv->switch_rxon.switch_in_progress = false;
+			set_bit(STATUS_CHANNEL_SWITCH_PENDING, &priv->status);
+			priv->switch_channel = cpu_to_le16(ch);
+			if (priv->cfg->ops->lib->set_channel_switch(priv, ch_switch)) {
+				clear_bit(STATUS_CHANNEL_SWITCH_PENDING,
+					  &priv->status);
+				priv->switch_channel = 0;
+				ieee80211_chswitch_done(ctx->vif, false);
+			}
 		}
 	}
 out:
 	mutex_unlock(&priv->mutex);
-	if (!priv->switch_rxon.switch_in_progress)
-		ieee80211_chswitch_done(ctx->vif, false);
 	IWL_DEBUG_MAC80211(priv, "leave\n");
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 5b721c5..f99f9c1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -423,7 +423,6 @@ static struct iwl_base_params iwl5000_base_params = {
 };
 static struct iwl_ht_params iwl5000_ht_params = {
 	.ht_greenfield_support = true,
-	.use_rts_for_aggregation = true, /* use rts/cts protection */
 };
 
 #define IWL_DEVICE_5000						\
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c b/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
index b12c72d..23fa93d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
@@ -163,17 +163,9 @@ static void iwlagn_tx_cmd_protection(struct iwl_priv *priv,
 				     __le16 fc, __le32 *tx_flags)
 {
 	if (info->control.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS ||
-	    info->control.rates[0].flags & IEEE80211_TX_RC_USE_CTS_PROTECT) {
+	    info->control.rates[0].flags & IEEE80211_TX_RC_USE_CTS_PROTECT ||
+	    info->flags & IEEE80211_TX_CTL_AMPDU)
 		*tx_flags |= TX_CMD_FLG_PROT_REQUIRE_MSK;
-		return;
-	}
-
-	if (priv->cfg->ht_params &&
-	    priv->cfg->ht_params->use_rts_for_aggregation &&
-	    info->flags & IEEE80211_TX_CTL_AMPDU) {
-		*tx_flags |= TX_CMD_FLG_PROT_REQUIRE_MSK;
-		return;
-	}
 }
 
 /* Calc max signal level (dBm) among 3 possible receivers */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index 2532c7d..09f679d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -325,6 +325,14 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *ctx)
 			return 0;
 	}
 
+	/*
+	 * force CTS-to-self frames protection if RTS-CTS is not preferred
+	 * one aggregation protection method
+	 */
+	if (!(priv->cfg->ht_params &&
+	      priv->cfg->ht_params->use_rts_for_aggregation))
+		ctx->staging.flags |= RXON_FLG_SELF_CTS_EN;
+
 	if ((ctx->vif && ctx->vif->bss_conf.use_short_slot) ||
 	    !(ctx->staging.flags & RXON_FLG_BAND_24G_MSK))
 		ctx->staging.flags |= RXON_FLG_SHORT_SLOT_MSK;
@@ -362,6 +370,11 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct iwl_rxon_context *ctx)
 		}
 
 		memcpy(active, &ctx->staging, sizeof(*active));
+		/*
+		 * We do not commit tx power settings while channel changing,
+		 * do it now if after settings changed.
+		 */
+		iwl_set_tx_power(priv, priv->tx_power_next, false);
 		return 0;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00config.c b/drivers/net/wireless/rt2x00/rt2x00config.c
index 555180d..b704e5b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00config.c
+++ b/drivers/net/wireless/rt2x00/rt2x00config.c
@@ -250,7 +250,8 @@ void rt2x00lib_config(struct rt2x00_dev *rt2x00dev,
 	if (ieee80211_flags & IEEE80211_CONF_CHANGE_CHANNEL)
 		rt2x00link_reset_tuner(rt2x00dev, false);
 
-	if (test_bit(REQUIRE_PS_AUTOWAKE, &rt2x00dev->cap_flags) &&
+	if (test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags) &&
+	    test_bit(REQUIRE_PS_AUTOWAKE, &rt2x00dev->cap_flags) &&
 	    (ieee80211_flags & IEEE80211_CONF_CHANGE_PS) &&
 	    (conf->flags & IEEE80211_CONF_PS)) {
 		beacon_diff = (long)jiffies - (long)rt2x00dev->last_beacon;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index c018d67..939821b 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -146,6 +146,9 @@ static void rt2x00lib_autowakeup(struct work_struct *work)
 	struct rt2x00_dev *rt2x00dev =
 	    container_of(work, struct rt2x00_dev, autowakeup_work.work);
 
+	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		return;
+
 	if (rt2x00dev->ops->lib->set_device_state(rt2x00dev, STATE_AWAKE))
 		ERROR(rt2x00dev, "Device failed to wakeup.\n");
 	clear_bit(CONFIG_POWERSAVING, &rt2x00dev->flags);
@@ -1160,6 +1163,7 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00dev)
 	 * Stop all work.
 	 */
 	cancel_work_sync(&rt2x00dev->intf_work);
+	cancel_delayed_work_sync(&rt2x00dev->autowakeup_work);
 	if (rt2x00_is_usb(rt2x00dev)) {
 		del_timer_sync(&rt2x00dev->txstatus_timer);
 		cancel_work_sync(&rt2x00dev->rxdone_work);
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 89100e7..9f8ccae 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -669,6 +669,19 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 							 &rx_status,
 							 (u8 *) pdesc, skb);
 
+			new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
+			if (unlikely(!new_skb)) {
+				RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV),
+					 DBG_DMESG,
+					 ("can't alloc skb for rx\n"));
+				goto done;
+			}
+
+			pci_unmap_single(rtlpci->pdev,
+					 *((dma_addr_t *) skb->cb),
+					 rtlpci->rxbuffersize,
+					 PCI_DMA_FROMDEVICE);
+
 			skb_put(skb, rtlpriv->cfg->ops->get_desc((u8 *) pdesc,
 							 false,
 							 HW_DESC_RXPKT_LEN));
@@ -685,22 +698,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			hdr = rtl_get_hdr(skb);
 			fc = rtl_get_fc(skb);
 
-			/* try for new buffer - if allocation fails, drop
-			 * frame and reuse old buffer
-			 */
-			new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
-			if (unlikely(!new_skb)) {
-				RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV),
-					 DBG_DMESG,
-					 ("can't alloc skb for rx\n"));
-				goto done;
-			}
-			pci_unmap_single(rtlpci->pdev,
-					 *((dma_addr_t *) skb->cb),
-					 rtlpci->rxbuffersize,
-					 PCI_DMA_FROMDEVICE);
-
-			if (!stats.crc || !stats.hwerror) {
+			if (!stats.crc && !stats.hwerror) {
 				memcpy(IEEE80211_SKB_RXCB(skb), &rx_status,
 				       sizeof(rx_status));
 
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 421eaa6..56c24ca 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -965,6 +965,10 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_data *sdata)
 
 	mutex_lock(&sdata->u.ibss.mtx);
 
+	sdata->u.ibss.state = IEEE80211_IBSS_MLME_SEARCH;
+	memset(sdata->u.ibss.bssid, 0, ETH_ALEN);
+	sdata->u.ibss.ssid_len = 0;
+
 	active_ibss = ieee80211_sta_active_ibss(sdata);
 
 	if (!active_ibss && !is_zero_ether_addr(ifibss->bssid)) {
@@ -999,8 +1003,6 @@ int ieee80211_ibss_leave(struct ieee80211_sub_if_data *sdata)
 	kfree_skb(skb);
 
 	skb_queue_purge(&sdata->skb_queue);
-	memset(sdata->u.ibss.bssid, 0, ETH_ALEN);
-	sdata->u.ibss.ssid_len = 0;
 
 	del_timer_sync(&sdata->u.ibss.timer);
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 2025af5..090b0ec 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -775,9 +775,6 @@ struct ieee80211_local {
 
 	int tx_headroom; /* required headroom for hardware/radiotap */
 
-	/* count for keys needing tailroom space allocation */
-	int crypto_tx_tailroom_needed_cnt;
-
 	/* Tasklet and skb queue to process calls from IRQ mode. All frames
 	 * added to skb_queue will be processed, but frames in
 	 * skb_queue_unreliable may be dropped if the total length of these
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 31afd712..f825e2f 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -101,11 +101,6 @@ static int ieee80211_key_enable_hw_accel(struct ieee80211_key *key)
 
 	if (!ret) {
 		key->flags |= KEY_FLAG_UPLOADED_TO_HARDWARE;
-
-		if (!((key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_MMIC) ||
-		      (key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV)))
-			key->local->crypto_tx_tailroom_needed_cnt--;
-
 		return 0;
 	}
 
@@ -161,10 +156,6 @@ static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
 			  key->conf.keyidx, sta ? sta->addr : bcast_addr, ret);
 
 	key->flags &= ~KEY_FLAG_UPLOADED_TO_HARDWARE;
-
-	if (!((key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_MMIC) ||
-	      (key->conf.flags & IEEE80211_KEY_FLAG_GENERATE_IV)))
-		key->local->crypto_tx_tailroom_needed_cnt++;
 }
 
 void ieee80211_key_removed(struct ieee80211_key_conf *key_conf)
@@ -403,10 +394,8 @@ static void __ieee80211_key_destroy(struct ieee80211_key *key)
 		ieee80211_aes_key_free(key->u.ccmp.tfm);
 	if (key->conf.cipher == WLAN_CIPHER_SUITE_AES_CMAC)
 		ieee80211_aes_cmac_key_free(key->u.aes_cmac.tfm);
-	if (key->local) {
+	if (key->local)
 		ieee80211_debugfs_key_remove(key);
-		key->local->crypto_tx_tailroom_needed_cnt--;
-	}
 
 	kfree(key);
 }
@@ -468,8 +457,6 @@ int ieee80211_key_link(struct ieee80211_key *key,
 
 	ieee80211_debugfs_key_add(key);
 
-	key->local->crypto_tx_tailroom_needed_cnt++;
-
 	ret = ieee80211_key_enable_hw_accel(key);
 
 	mutex_unlock(&sdata->local->key_mtx);
@@ -511,12 +498,8 @@ void ieee80211_enable_keys(struct ieee80211_sub_if_data *sdata)
 
 	mutex_lock(&sdata->local->key_mtx);
 
-	sdata->local->crypto_tx_tailroom_needed_cnt = 0;
-
-	list_for_each_entry(key, &sdata->key_list, list) {
-		sdata->local->crypto_tx_tailroom_needed_cnt++;
+	list_for_each_entry(key, &sdata->key_list, list)
 		ieee80211_key_enable_hw_accel(key);
-	}
 
 	mutex_unlock(&sdata->local->key_mtx);
 }
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 456cccf..d595265 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -232,9 +232,6 @@ static u32 ieee80211_enable_ht(struct ieee80211_sub_if_data *sdata,
 		WARN_ON(!ieee80211_set_channel_type(local, sdata, channel_type));
 	}
 
-	ieee80211_stop_queues_by_reason(&sdata->local->hw,
-					IEEE80211_QUEUE_STOP_REASON_CSA);
-
 	/* channel_type change automatically detected */
 	ieee80211_hw_config(local, 0);
 
@@ -248,9 +245,6 @@ static u32 ieee80211_enable_ht(struct ieee80211_sub_if_data *sdata,
 		rcu_read_unlock();
 	}
 
-	ieee80211_wake_queues_by_reason(&sdata->local->hw,
-					IEEE80211_QUEUE_STOP_REASON_CSA);
-
 	ht_opmode = le16_to_cpu(hti->operation_mode);
 
 	/* if bss configuration changed store the new one */
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 64e0f75..3104c84 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1480,7 +1480,12 @@ static int ieee80211_skb_resize(struct ieee80211_local *local,
 {
 	int tail_need = 0;
 
-	if (may_encrypt && local->crypto_tx_tailroom_needed_cnt) {
+	/*
+	 * This could be optimised, devices that do full hardware
+	 * crypto (including TKIP MMIC) need no tailroom... But we
+	 * have no drivers for such devices currently.
+	 */
+	if (may_encrypt) {
 		tail_need = IEEE80211_ENCRYPT_TAILROOM;
 		tail_need -= skb_tailroom(skb);
 		tail_need = max_t(int, tail_need, 0);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 88a565f..98fa8eb 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -3406,11 +3406,11 @@ static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 	i = 0;
 	if (info->attrs[NL80211_ATTR_SCAN_SSIDS]) {
 		nla_for_each_nested(attr, info->attrs[NL80211_ATTR_SCAN_SSIDS], tmp) {
-			request->ssids[i].ssid_len = nla_len(attr);
-			if (request->ssids[i].ssid_len > IEEE80211_MAX_SSID_LEN) {
+			if (nla_len(attr) > IEEE80211_MAX_SSID_LEN) {
 				err = -EINVAL;
 				goto out_free;
 			}
+			request->ssids[i].ssid_len = nla_len(attr);
 			memcpy(request->ssids[i].ssid, nla_data(attr), nla_len(attr));
 			i++;
 		}
@@ -3572,12 +3572,11 @@ static int nl80211_start_sched_scan(struct sk_buff *skb,
 	if (info->attrs[NL80211_ATTR_SCAN_SSIDS]) {
 		nla_for_each_nested(attr, info->attrs[NL80211_ATTR_SCAN_SSIDS],
 				    tmp) {
-			request->ssids[i].ssid_len = nla_len(attr);
-			if (request->ssids[i].ssid_len >
-			    IEEE80211_MAX_SSID_LEN) {
+			if (nla_len(attr) > IEEE80211_MAX_SSID_LEN) {
 				err = -EINVAL;
 				goto out_free;
 			}
+			request->ssids[i].ssid_len = nla_len(attr);
 			memcpy(request->ssids[i].ssid, nla_data(attr),
 			       nla_len(attr));
 			i++;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
