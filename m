From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-11-14
Date: Mon, 14 Nov 2011 14:32:54 -0500
Message-ID: <20111114193253.GA2499@tuxdriver.com>
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

Here is another batch of fixes intended for 3.2.  This includes an
mwifiex fix to enable association with "hidden" APs, a fix for avoiding
an unhandled RF kill interrupt when unloading iwlwifi, a NULL pointer
fix in the mac80211 radiotap code, a fix for ieee80211_build_probe_req
to pass-up a proper return code when ieee80211_probereq_get fails, a
race fix for mac80211 to avoid a WARNING in ieee80211_can_queue_work, a
NULL pointer fix in the cfg80211 regulatory code, and a fix for an
unaligned memory access in the libertas driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1e49570171117e547e6324c58371db4a0dc2f1db:

  net: Fix references to deleted NET_ETHERNET Kconfig setting. (2011-11-09 19:26:53 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Amitkumar Karwar (1):
      mwifiex: fix association issue with AP configured in hidden SSID mode

Emmanuel Grumbach (1):
      iwlwifi: avoid a panic when unloading the module with RF Kill

Johannes Berg (3):
      mac80211: fix NULL dereference in radiotap code
      mac80211: fix bug in ieee80211_build_probe_req
      mac80211: fix race between connection monitor & suspend

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Luis R. Rodriguez (1):
      cfg80211: fix bug on regulatory core exit on access to last_request

Steven Miao (1):
      wireless: libertas: fix unaligned le64 accesses

 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c |   33 +++++++++++++------------
 drivers/net/wireless/libertas/cfg.c           |    2 +-
 drivers/net/wireless/mwifiex/scan.c           |    6 +++-
 net/mac80211/mlme.c                           |    2 +-
 net/mac80211/rx.c                             |    9 ++++--
 net/mac80211/util.c                           |    4 +++
 net/wireless/reg.c                            |    3 ++
 7 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
index da34110..ce91898 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -990,29 +990,16 @@ static int iwl_trans_tx_stop(struct iwl_trans *trans)
 	return 0;
 }
 
-static void iwl_trans_pcie_disable_sync_irq(struct iwl_trans *trans)
+static void iwl_trans_pcie_stop_device(struct iwl_trans *trans)
 {
 	unsigned long flags;
-	struct iwl_trans_pcie *trans_pcie =
-		IWL_TRANS_GET_PCIE_TRANS(trans);
+	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
 
+	/* tell the device to stop sending interrupts */
 	spin_lock_irqsave(&trans->shrd->lock, flags);
 	iwl_disable_interrupts(trans);
 	spin_unlock_irqrestore(&trans->shrd->lock, flags);
 
-	/* wait to make sure we flush pending tasklet*/
-	synchronize_irq(bus(trans)->irq);
-	tasklet_kill(&trans_pcie->irq_tasklet);
-}
-
-static void iwl_trans_pcie_stop_device(struct iwl_trans *trans)
-{
-	/* stop and reset the on-board processor */
-	iwl_write32(bus(trans), CSR_RESET, CSR_RESET_REG_FLAG_NEVO_RESET);
-
-	/* tell the device to stop sending interrupts */
-	iwl_trans_pcie_disable_sync_irq(trans);
-
 	/* device going down, Stop using ICT table */
 	iwl_disable_ict(trans);
 
@@ -1039,6 +1026,20 @@ static void iwl_trans_pcie_stop_device(struct iwl_trans *trans)
 
 	/* Stop the device, and put it in low power state */
 	iwl_apm_stop(priv(trans));
+
+	/* Upon stop, the APM issues an interrupt if HW RF kill is set.
+	 * Clean again the interrupt here
+	 */
+	spin_lock_irqsave(&trans->shrd->lock, flags);
+	iwl_disable_interrupts(trans);
+	spin_unlock_irqrestore(&trans->shrd->lock, flags);
+
+	/* wait to make sure we flush pending tasklet*/
+	synchronize_irq(bus(trans)->irq);
+	tasklet_kill(&trans_pcie->irq_tasklet);
+
+	/* stop and reset the on-board processor */
+	iwl_write32(bus(trans), CSR_RESET, CSR_RESET_REG_FLAG_NEVO_RESET);
 }
 
 static int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 4fcd653..a7f1ab2 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -634,7 +634,7 @@ static int lbs_ret_scan(struct lbs_private *priv, unsigned long dummy,
 			if (channel &&
 			    !(channel->flags & IEEE80211_CHAN_DISABLED))
 				cfg80211_inform_bss(wiphy, channel,
-					bssid, le64_to_cpu(*(__le64 *)tsfdesc),
+					bssid, get_unaligned_le64(tsfdesc),
 					capa, intvl, ie, ielen,
 					LBS_SCAN_RSSI_TO_MBM(rssi),
 					GFP_KERNEL);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index 8a3f959..8d3ab37 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -819,8 +819,10 @@ mwifiex_scan_setup_scan_config(struct mwifiex_private *priv,
 			wildcard_ssid_tlv->header.len = cpu_to_le16(
 				(u16) (ssid_len + sizeof(wildcard_ssid_tlv->
 							 max_ssid_length)));
-			wildcard_ssid_tlv->max_ssid_length =
-				user_scan_in->ssid_list[ssid_idx].max_len;
+
+			/* max_ssid_length = 0 tells firmware to perform
+			   specific scan for the SSID filled */
+			wildcard_ssid_tlv->max_ssid_length = 0;
 
 			memcpy(wildcard_ssid_tlv->ssid,
 			       user_scan_in->ssid_list[ssid_idx].ssid,
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 234ffc2..b1b1bb3 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2288,6 +2288,7 @@ void ieee80211_sta_quiesce(struct ieee80211_sub_if_data *sdata)
 
 	cancel_work_sync(&ifmgd->request_smps_work);
 
+	cancel_work_sync(&ifmgd->monitor_work);
 	cancel_work_sync(&ifmgd->beacon_connection_loss_work);
 	if (del_timer_sync(&ifmgd->timer))
 		set_bit(TMR_RUNNING_TIMER, &ifmgd->timers_running);
@@ -2296,7 +2297,6 @@ void ieee80211_sta_quiesce(struct ieee80211_sub_if_data *sdata)
 	if (del_timer_sync(&ifmgd->chswitch_timer))
 		set_bit(TMR_RUNNING_CHANSW, &ifmgd->timers_running);
 
-	cancel_work_sync(&ifmgd->monitor_work);
 	/* these will just be re-established on connection */
 	del_timer_sync(&ifmgd->conn_mon_timer);
 	del_timer_sync(&ifmgd->bcn_mon_timer);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index bb53726..fb123e2 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -141,8 +141,9 @@ ieee80211_add_rx_radiotap_header(struct ieee80211_local *local,
 	pos++;
 
 	/* IEEE80211_RADIOTAP_RATE */
-	if (status->flag & RX_FLAG_HT) {
+	if (!rate || status->flag & RX_FLAG_HT) {
 		/*
+		 * Without rate information don't add it. If we have,
 		 * MCS information is a separate field in radiotap,
 		 * added below. The byte here is needed as padding
 		 * for the channel though, so initialise it to 0.
@@ -163,12 +164,14 @@ ieee80211_add_rx_radiotap_header(struct ieee80211_local *local,
 	else if (status->flag & RX_FLAG_HT)
 		put_unaligned_le16(IEEE80211_CHAN_DYN | IEEE80211_CHAN_2GHZ,
 				   pos);
-	else if (rate->flags & IEEE80211_RATE_ERP_G)
+	else if (rate && rate->flags & IEEE80211_RATE_ERP_G)
 		put_unaligned_le16(IEEE80211_CHAN_OFDM | IEEE80211_CHAN_2GHZ,
 				   pos);
-	else
+	else if (rate)
 		put_unaligned_le16(IEEE80211_CHAN_CCK | IEEE80211_CHAN_2GHZ,
 				   pos);
+	else
+		put_unaligned_le16(IEEE80211_CHAN_2GHZ, pos);
 	pos += 2;
 
 	/* IEEE80211_RADIOTAP_DBM_ANTSIGNAL */
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 51e256c..eca0fad 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -881,6 +881,8 @@ struct sk_buff *ieee80211_build_probe_req(struct ieee80211_sub_if_data *sdata,
 	skb = ieee80211_probereq_get(&local->hw, &sdata->vif,
 				     ssid, ssid_len,
 				     buf, buf_len);
+	if (!skb)
+		goto out;
 
 	if (dst) {
 		mgmt = (struct ieee80211_mgmt *) skb->data;
@@ -889,6 +891,8 @@ struct sk_buff *ieee80211_build_probe_req(struct ieee80211_sub_if_data *sdata,
 	}
 
 	IEEE80211_SKB_CB(skb)->flags |= IEEE80211_TX_INTFL_DONT_ENCRYPT;
+
+ out:
 	kfree(buf);
 
 	return skb;
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 6acba9d..e71f5a6 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2265,6 +2265,9 @@ void /* __init_or_exit */ regulatory_exit(void)
 
 	kfree(last_request);
 
+	last_request = NULL;
+	dev_set_uevent_suppress(&reg_pdev->dev, true);
+
 	platform_device_unregister(reg_pdev);
 
 	spin_lock_bh(&reg_pending_beacons_lock);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
