From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-03-31
Date: Wed, 31 Mar 2010 10:46:49 -0400
Message-ID: <20100331144649.GC3024@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.nt
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36797 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab0CaPAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 11:00:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a batch of fixes intended for 2.6.34.  Included are a few
device IDs, along with several almost-one-liners to fix a variety of
issues, including a NULL deref, a potential overflow, a misues of the
USB API, a regulatory error for iwlwifi, a race condition in mac80211,
and some other more minor fixes.

I saw your note about only "eats someones disk" bugs.  I'm not
sure all of these meet that test, but I hope you will take them.
I've been sitting on them a while and letting them cook in linux-next,
mostly to test one particular patch (which I backed-out yesterday).
I promise I'll tighten-up after this batch! :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit ce6fbdefb68d46db88170494b277551f955b48e2:
  Julia Lawall (1):
        drivers/net: Add missing unlock

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Ben Konrath (1):
      ar9170: add support for NEC WL300NU-G USB dongle

Benjamin Larsson (1):
      Add a pci-id to the mwl8k driver

Dan Carpenter (1):
      iwlwifi: range checking issue

Daniel Mack (1):
      net/wireless/libertas: do not call wiphy_unregister() w/o wiphy_register()

Gertjan van Wingerde (2):
      rt2x00: Fix typo in RF register programming of rt2800.
      rt2x00: Disable powersaving by default in rt2500usb.

Hans de Goede (1):
      Add USB ID for Thomson SpeedTouch 120g to p54usb id table

Johannes Berg (1):
      mac80211: move netdev queue enabling to correct spot

John W. Linville (2):
      wireless: convert reg_regdb_search_lock to mutex
      mac80211: correct typos in "unavailable upon resume" warning

Porsch, Marco (1):
      mac80211: fix PREQ processing and one small bug

Reinette Chatre (1):
      iwlwifi: fix regulatory

Shanyu Zhao (1):
      iwlwifi: clear unattended interrupts in tasklet

Valentin Longchamp (1):
      setup correct int pipe type in ar9170_usb_exec_cmd

Wey-Yi Guy (1):
      iwlwifi: counting number of tfds can be free for 4965

 drivers/net/wireless/ath/ar9170/usb.c       |    4 +++-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 ++----
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   12 ++++++++++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 ++--
 drivers/net/wireless/libertas/cfg.c         |    8 ++++++--
 drivers/net/wireless/libertas/dev.h         |    1 +
 drivers/net/wireless/mwl8k.c                |    1 +
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c     |    5 +++++
 drivers/net/wireless/rt2x00/rt2800lib.c     |    4 ++--
 net/mac80211/mesh_hwmp.c                    |    4 ++--
 net/mac80211/tx.c                           |    6 ++++++
 net/mac80211/util.c                         |   18 +++++++++---------
 net/wireless/reg.c                          |   12 +++++-------
 14 files changed, 55 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wireless/ath/ar9170/usb.c
index 4e30197..6b1cb70 100644
--- a/drivers/net/wireless/ath/ar9170/usb.c
+++ b/drivers/net/wireless/ath/ar9170/usb.c
@@ -94,6 +94,8 @@ static struct usb_device_id ar9170_usb_ids[] = {
 	{ USB_DEVICE(0x04bb, 0x093f) },
 	/* AVM FRITZ!WLAN USB Stick N */
 	{ USB_DEVICE(0x057C, 0x8401) },
+	/* NEC WL300NU-G */
+	{ USB_DEVICE(0x0409, 0x0249) },
 	/* AVM FRITZ!WLAN USB Stick N 2.4 */
 	{ USB_DEVICE(0x057C, 0x8402), .driver_info = AR9170_REQ_FW1_ONLY },
 
@@ -416,7 +418,7 @@ static int ar9170_usb_exec_cmd(struct ar9170 *ar, enum ar9170_cmd cmd,
 	spin_unlock_irqrestore(&aru->common.cmdlock, flags);
 
 	usb_fill_int_urb(urb, aru->udev,
-			 usb_sndbulkpipe(aru->udev, AR9170_EP_CMD),
+			 usb_sndintpipe(aru->udev, AR9170_EP_CMD),
 			 aru->common.cmdbuf, plen + 4,
 			 ar9170_usb_tx_urb_complete, NULL, 1);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 1bd2cd8..83c52a6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2041,16 +2041,14 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 				   tx_resp->failure_frame);
 
 		freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-		if (qc && likely(sta_id != IWL_INVALID_STATION))
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+		iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 		if (priv->mac80211_registered &&
 		    (iwl_queue_space(&txq->q) > txq->q.low_mark))
 			iwl_wake_queue(priv, txq_id);
 	}
 
-	if (qc && likely(sta_id != IWL_INVALID_STATION))
-		iwl_txq_check_empty(priv, sta_id, tid, txq_id);
+	iwl_txq_check_empty(priv, sta_id, tid, txq_id);
 
 	if (iwl_check_bits(status, TX_ABORT_REQUIRED_MSK))
 		IWL_ERR(priv, "TODO:  Implement Tx ABORT REQUIRED!!!\n");
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 818367b..e4c2e1e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1258,7 +1258,15 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 	/* Ack/clear/reset pending uCode interrupts.
 	 * Note:  Some bits in CSR_INT are "OR" of bits in CSR_FH_INT_STATUS,
 	 */
-	iwl_write32(priv, CSR_INT, priv->inta);
+	/* There is a hardware bug in the interrupt mask function that some
+	 * interrupts (i.e. CSR_INT_BIT_SCD) can still be generated even if
+	 * they are disabled in the CSR_INT_MASK register. Furthermore the
+	 * ICT interrupt handling mechanism has another bug that might cause
+	 * these unmasked interrupts fail to be detected. We workaround the
+	 * hardware bugs here by ACKing all the possible interrupts so that
+	 * interrupt coalescing can still be achieved.
+	 */
+	iwl_write32(priv, CSR_INT, priv->inta | ~priv->inta_mask);
 
 	inta = priv->inta;
 
@@ -2644,7 +2652,7 @@ static int iwl_mac_setup_register(struct iwl_priv *priv)
 		BIT(NL80211_IFTYPE_STATION) |
 		BIT(NL80211_IFTYPE_ADHOC);
 
-	hw->wiphy->flags |= WIPHY_FLAG_STRICT_REGULATORY |
+	hw->wiphy->flags |= WIPHY_FLAG_CUSTOM_REGULATORY |
 			    WIPHY_FLAG_DISABLE_BEACON_HINTS;
 
 	/*
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 54daa38..e276f2a 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1955,7 +1955,7 @@ static void iwl3945_init_hw_rates(struct iwl_priv *priv,
 {
 	int i;
 
-	for (i = 0; i < IWL_RATE_COUNT; i++) {
+	for (i = 0; i < IWL_RATE_COUNT_LEGACY; i++) {
 		rates[i].bitrate = iwl3945_rates[i].ieee * 5;
 		rates[i].hw_value = i; /* Rate scaling will work on indexes */
 		rates[i].hw_value_short = i;
@@ -3921,7 +3921,7 @@ static int iwl3945_setup_mac(struct iwl_priv *priv)
 		BIT(NL80211_IFTYPE_STATION) |
 		BIT(NL80211_IFTYPE_ADHOC);
 
-	hw->wiphy->flags |= WIPHY_FLAG_STRICT_REGULATORY |
+	hw->wiphy->flags |= WIPHY_FLAG_CUSTOM_REGULATORY |
 			    WIPHY_FLAG_DISABLE_BEACON_HINTS;
 
 	hw->wiphy->max_scan_ssids = PROBE_OPTION_MAX_3945;
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 4396dcc..82ebe14 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -172,6 +172,8 @@ int lbs_cfg_register(struct lbs_private *priv)
 	if (ret < 0)
 		lbs_pr_err("cannot register wiphy device\n");
 
+	priv->wiphy_registered = true;
+
 	ret = register_netdev(priv->dev);
 	if (ret)
 		lbs_pr_err("cannot register network device\n");
@@ -190,9 +192,11 @@ void lbs_cfg_free(struct lbs_private *priv)
 	if (!wdev)
 		return;
 
-	if (wdev->wiphy) {
+	if (priv->wiphy_registered)
 		wiphy_unregister(wdev->wiphy);
+
+	if (wdev->wiphy)
 		wiphy_free(wdev->wiphy);
-	}
+
 	kfree(wdev);
 }
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index 6977ee8..6875e14 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -36,6 +36,7 @@ struct lbs_private {
 
 	/* CFG80211 */
 	struct wireless_dev *wdev;
+	bool wiphy_registered;
 
 	/* Mesh */
 	struct net_device *mesh_dev; /* Virtual device */
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index ac65e13..4e58ebe 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -3851,6 +3851,7 @@ MODULE_FIRMWARE("mwl8k/helper_8366.fw");
 MODULE_FIRMWARE("mwl8k/fmimage_8366.fw");
 
 static DEFINE_PCI_DEVICE_TABLE(mwl8k_pci_id_table) = {
+	{ PCI_VDEVICE(MARVELL, 0x2a0a), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a0c), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a24), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a2b), .driver_data = MWL8687, },
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index b3c4fbd..e3cfc00 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -35,6 +35,7 @@ MODULE_FIRMWARE("isl3887usb");
 static struct usb_device_id p54u_table[] __devinitdata = {
 	/* Version 1 devices (pci chip + net2280) */
 	{USB_DEVICE(0x0506, 0x0a11)},	/* 3COM 3CRWE254G72 */
+	{USB_DEVICE(0x06b9, 0x0120)},	/* Thomson SpeedTouch 120g */
 	{USB_DEVICE(0x0707, 0xee06)},	/* SMC 2862W-G */
 	{USB_DEVICE(0x07aa, 0x001c)},	/* Corega CG-WLUSB2GT */
 	{USB_DEVICE(0x083a, 0x4501)},	/* Accton 802.11g WN4501 USB */
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index ee34c13..dbaa781 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1643,6 +1643,11 @@ static int rt2500usb_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 	unsigned int i;
 
 	/*
+	 * Disable powersaving as default.
+	 */
+	rt2x00dev->hw->wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
+
+	/*
 	 * Initialize all hw fields.
 	 */
 	rt2x00dev->hw->flags =
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 18d4d8e..326fce7 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -812,9 +812,9 @@ static void rt2800_config_channel_rt3x(struct rt2x00_dev *rt2x00dev,
 	rt2800_rfcsr_write(rt2x00dev, 24,
 			      rt2x00dev->calibration[conf_is_ht40(conf)]);
 
-	rt2800_rfcsr_read(rt2x00dev, 23, &rfcsr);
+	rt2800_rfcsr_read(rt2x00dev, 7, &rfcsr);
 	rt2x00_set_field8(&rfcsr, RFCSR7_RF_TUNING, 1);
-	rt2800_rfcsr_write(rt2x00dev, 23, rfcsr);
+	rt2800_rfcsr_write(rt2x00dev, 7, rfcsr);
 }
 
 static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index ce84237..ccff613 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -391,7 +391,7 @@ static u32 hwmp_route_info_get(struct ieee80211_sub_if_data *sdata,
 				if (SN_GT(mpath->sn, orig_sn) ||
 				    (mpath->sn == orig_sn &&
 				     action == MPATH_PREQ &&
-				     new_metric > mpath->metric)) {
+				     new_metric >= mpath->metric)) {
 					process = false;
 					fresh_info = false;
 				}
@@ -611,7 +611,7 @@ static void hwmp_prep_frame_process(struct ieee80211_sub_if_data *sdata,
 
 	mesh_path_sel_frame_tx(MPATH_PREP, flags, orig_addr,
 		cpu_to_le32(orig_sn), 0, target_addr,
-		cpu_to_le32(target_sn), mpath->next_hop->sta.addr, hopcount,
+		cpu_to_le32(target_sn), next_hop, hopcount,
 		ttl, cpu_to_le32(lifetime), cpu_to_le32(metric),
 		0, sdata);
 	rcu_read_unlock();
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index cbe53ed..cfc473e 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1991,6 +1991,7 @@ static bool ieee80211_tx_pending_skb(struct ieee80211_local *local,
 void ieee80211_tx_pending(unsigned long data)
 {
 	struct ieee80211_local *local = (struct ieee80211_local *)data;
+	struct ieee80211_sub_if_data *sdata;
 	unsigned long flags;
 	int i;
 	bool txok;
@@ -2029,6 +2030,11 @@ void ieee80211_tx_pending(unsigned long data)
 			if (!txok)
 				break;
 		}
+
+		if (skb_queue_empty(&local->pending[i]))
+			list_for_each_entry_rcu(sdata, &local->interfaces, list)
+				netif_tx_wake_queue(
+					netdev_get_tx_queue(sdata->dev, i));
 	}
 	spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index c453226..53af570 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -279,13 +279,13 @@ static void __ieee80211_wake_queue(struct ieee80211_hw *hw, int queue,
 		/* someone still has this queue stopped */
 		return;
 
-	if (!skb_queue_empty(&local->pending[queue]))
+	if (skb_queue_empty(&local->pending[queue])) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(sdata, &local->interfaces, list)
+			netif_tx_wake_queue(netdev_get_tx_queue(sdata->dev, queue));
+		rcu_read_unlock();
+	} else
 		tasklet_schedule(&local->tx_pending_tasklet);
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(sdata, &local->interfaces, list)
-		netif_tx_wake_queue(netdev_get_tx_queue(sdata->dev, queue));
-	rcu_read_unlock();
 }
 
 void ieee80211_wake_queue_by_reason(struct ieee80211_hw *hw, int queue,
@@ -1097,9 +1097,9 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		 */
 		res = drv_start(local);
 		if (res) {
-			WARN(local->suspended, "Harware became unavailable "
-			     "upon resume. This is could be a software issue"
-			     "prior to suspend or a hardware issue\n");
+			WARN(local->suspended, "Hardware became unavailable "
+			     "upon resume. This could be a software issue "
+			     "prior to suspend or a hardware issue.\n");
 			return res;
 		}
 
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index ed89c59..81fcafc 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -324,7 +324,7 @@ struct reg_regdb_search_request {
 };
 
 static LIST_HEAD(reg_regdb_search_list);
-static DEFINE_SPINLOCK(reg_regdb_search_lock);
+static DEFINE_MUTEX(reg_regdb_search_mutex);
 
 static void reg_regdb_search(struct work_struct *work)
 {
@@ -332,7 +332,7 @@ static void reg_regdb_search(struct work_struct *work)
 	const struct ieee80211_regdomain *curdom, *regdom;
 	int i, r;
 
-	spin_lock(&reg_regdb_search_lock);
+	mutex_lock(&reg_regdb_search_mutex);
 	while (!list_empty(&reg_regdb_search_list)) {
 		request = list_first_entry(&reg_regdb_search_list,
 					   struct reg_regdb_search_request,
@@ -346,18 +346,16 @@ static void reg_regdb_search(struct work_struct *work)
 				r = reg_copy_regd(&regdom, curdom);
 				if (r)
 					break;
-				spin_unlock(&reg_regdb_search_lock);
 				mutex_lock(&cfg80211_mutex);
 				set_regdom(regdom);
 				mutex_unlock(&cfg80211_mutex);
-				spin_lock(&reg_regdb_search_lock);
 				break;
 			}
 		}
 
 		kfree(request);
 	}
-	spin_unlock(&reg_regdb_search_lock);
+	mutex_unlock(&reg_regdb_search_mutex);
 }
 
 static DECLARE_WORK(reg_regdb_work, reg_regdb_search);
@@ -375,9 +373,9 @@ static void reg_regdb_query(const char *alpha2)
 
 	memcpy(request->alpha2, alpha2, 2);
 
-	spin_lock(&reg_regdb_search_lock);
+	mutex_lock(&reg_regdb_search_mutex);
 	list_add_tail(&request->list, &reg_regdb_search_list);
-	spin_unlock(&reg_regdb_search_lock);
+	mutex_unlock(&reg_regdb_search_mutex);
 
 	schedule_work(&reg_regdb_work);
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
