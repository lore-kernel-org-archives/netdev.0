From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next-2.6 2009-09-16
Date: Wed, 16 Sep 2009 16:41:51 -0400
Message-ID: <20090916204150.GG10634@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760067AbZIPUph@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a batch of fixes for 2.6.32...nothing too controversial
AFAICT...

Please let me know if there are problems!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 13af7a6ea502fcdd4c0e3d7de6e332b102309491:
  Dhananjay Phadke (1):
        netxen: update copyright

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Christian Lamparter (1):
      p54usb: add Zcomax XG-705A usbid

Daniel C Halperin (1):
      iwlwifi: fix HT operation in 2.4 GHz band

Holger Schurig (2):
      cfg80211: use cfg80211_wext_freq() for freq conversion
      cfg80211: minimal error handling for wext-compat freq scanning

Johannes Berg (2):
      iwlwifi: disable powersave for 4965
      cfg80211: fix SME connect

Larry Finger (1):
      ssb: Fix error when V1 SPROM extraction is forced

Luis R. Rodriguez (1):
      wireless: default CONFIG_WLAN to y

Martin Decky (1):
      hostap: Revert a toxic part of the conversion to net_device_ops

Michael Buesch (3):
      b43: Force-wake queues on init
      ssb: Disable verbose SDIO coreswitch
      b43: Fix resume failure

Pavel Roskin (1):
      rc80211_minstrel: fix contention window calculation

Randy Dunlap (1):
      ssb/sdio: fix printk format warnings

Reinette Chatre (1):
      iwlwifi: fix potential rx buffer loss

Sujith (1):
      ath9k: Fix bug in ANI channel handling

Wey-Yi Guy (1):
      iwlwifi: find the correct first antenna

 drivers/net/wireless/Kconfig                |    1 +
 drivers/net/wireless/ath/ath9k/ani.c        |    6 ++++--
 drivers/net/wireless/b43/main.c             |    8 +++-----
 drivers/net/wireless/hostap/hostap_main.c   |    3 ++-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |   10 +++++++++-
 drivers/net/wireless/iwlwifi/iwl-core.c     |    9 ++++++---
 drivers/net/wireless/iwlwifi/iwl-core.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c    |    5 +++--
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   24 +++++++++++++++++-------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   24 ++++++++++++++++--------
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/ssb/pci.c                           |    1 +
 drivers/ssb/sdio.c                          |    6 +++---
 net/mac80211/rc80211_minstrel.c             |    2 +-
 net/wireless/scan.c                         |    7 ++++++-
 net/wireless/sme.c                          |   21 +++++++++++++--------
 17 files changed, 88 insertions(+), 42 deletions(-)

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index ad89d23..49ea9c9 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -5,6 +5,7 @@
 menuconfig WLAN
 	bool "Wireless LAN"
 	depends on !S390
+	default y
 	---help---
 	  This section contains all the pre 802.11 and 802.11 wireless
 	  device drivers. For a complete list of drivers and documentation
diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index a7cbb07..2b49374 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -327,7 +327,8 @@ static void ath9k_hw_ani_ofdm_err_trigger(struct ath_hw *ah)
 					     aniState->firstepLevel + 1);
 		return;
 	} else {
-		if (conf->channel->band == IEEE80211_BAND_2GHZ) {
+		if ((conf->channel->band == IEEE80211_BAND_2GHZ) &&
+		    !conf_is_ht(conf)) {
 			if (!aniState->ofdmWeakSigDetectOff)
 				ath9k_hw_ani_control(ah,
 				     ATH9K_ANI_OFDM_WEAK_SIGNAL_DETECTION,
@@ -369,7 +370,8 @@ static void ath9k_hw_ani_cck_err_trigger(struct ath_hw *ah)
 			ath9k_hw_ani_control(ah, ATH9K_ANI_FIRSTEP_LEVEL,
 					     aniState->firstepLevel + 1);
 	} else {
-		if (conf->channel->band == IEEE80211_BAND_2GHZ) {
+		if ((conf->channel->band == IEEE80211_BAND_2GHZ) &&
+		    !conf_is_ht(conf)) {
 			if (aniState->firstepLevel > 0)
 				ath9k_hw_ani_control(ah,
 					     ATH9K_ANI_FIRSTEP_LEVEL, 0);
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 7a9a3fa..e789792 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2289,11 +2289,7 @@ static int b43_upload_microcode(struct b43_wldev *dev)
 			err = -ENODEV;
 			goto error;
 		}
-		msleep_interruptible(50);
-		if (signal_pending(current)) {
-			err = -EINTR;
-			goto error;
-		}
+		msleep(50);
 	}
 	b43_read32(dev, B43_MMIO_GEN_IRQ_REASON);	/* dummy read */
 
@@ -4287,6 +4283,8 @@ static int b43_wireless_core_init(struct b43_wldev *dev)
 	if (!dev->suspend_in_progress)
 		b43_rng_init(wl);
 
+	ieee80211_wake_queues(dev->wl->hw);
+
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
 	if (!dev->suspend_in_progress)
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 6fe122f..eb57d1e 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -875,15 +875,16 @@ void hostap_setup_dev(struct net_device *dev, local_info_t *local,
 
 	switch(type) {
 	case HOSTAP_INTERFACE_AP:
+		dev->tx_queue_len = 0;	/* use main radio device queue */
 		dev->netdev_ops = &hostap_mgmt_netdev_ops;
 		dev->type = ARPHRD_IEEE80211;
 		dev->header_ops = &hostap_80211_ops;
 		break;
 	case HOSTAP_INTERFACE_MASTER:
-		dev->tx_queue_len = 0;	/* use main radio device queue */
 		dev->netdev_ops = &hostap_master_ops;
 		break;
 	default:
+		dev->tx_queue_len = 0;	/* use main radio device queue */
 		dev->netdev_ops = &hostap_netdev_ops;
 	}
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 6a13bfb..ca61d37 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2346,6 +2346,7 @@ struct iwl_cfg iwl4965_agn_cfg = {
 	.mod_params = &iwl4965_mod_params,
 	.use_isr_legacy = true,
 	.ht_greenfield_support = false,
+	.broken_powersave = true,
 };
 
 /* Module firmware */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 40b207a..346dc06 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -760,6 +760,7 @@ static u32 rs_get_lower_rate(struct iwl_lq_sta *lq_sta,
 	u16 high_low;
 	u8 switch_to_legacy = 0;
 	u8 is_green = lq_sta->is_green;
+	struct iwl_priv *priv = lq_sta->drv;
 
 	/* check if we need to switch from HT to legacy rates.
 	 * assumption is that mandatory rates (1Mbps or 6Mbps)
@@ -773,7 +774,8 @@ static u32 rs_get_lower_rate(struct iwl_lq_sta *lq_sta,
 			tbl->lq_type = LQ_G;
 
 		if (num_of_ant(tbl->ant_type) > 1)
-			tbl->ant_type = ANT_A;/*FIXME:RS*/
+			tbl->ant_type =
+				first_antenna(priv->hw_params.valid_tx_ant);
 
 		tbl->is_ht40 = 0;
 		tbl->is_SGI = 0;
@@ -883,6 +885,12 @@ static void rs_tx_status(void *priv_r, struct ieee80211_supported_band *sband,
 		mac_index &= RATE_MCS_CODE_MSK;	/* Remove # of streams */
 		if (mac_index >= (IWL_RATE_9M_INDEX - IWL_FIRST_OFDM_RATE))
 			mac_index++;
+		/*
+		 * mac80211 HT index is always zero-indexed; we need to move
+		 * HT OFDM rates after CCK rates in 2.4 GHz band
+		 */
+		if (priv->band == IEEE80211_BAND_2GHZ)
+			mac_index += IWL_FIRST_OFDM_RATE;
 	}
 
 	if ((mac_index < 0) ||
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index acfd7b4..fd26c0d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1585,9 +1585,12 @@ int iwl_setup_mac(struct iwl_priv *priv)
 	hw->flags = IEEE80211_HW_SIGNAL_DBM |
 		    IEEE80211_HW_NOISE_DBM |
 		    IEEE80211_HW_AMPDU_AGGREGATION |
-		    IEEE80211_HW_SPECTRUM_MGMT |
-		    IEEE80211_HW_SUPPORTS_PS |
-		    IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
+		    IEEE80211_HW_SPECTRUM_MGMT;
+
+	if (!priv->cfg->broken_powersave)
+		hw->flags |= IEEE80211_HW_SUPPORTS_PS |
+			     IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
+
 	hw->wiphy->interface_modes =
 		BIT(NL80211_IFTYPE_STATION) |
 		BIT(NL80211_IFTYPE_ADHOC);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index c04d2a2..7ff9ffb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -252,6 +252,7 @@ struct iwl_cfg {
 	const u16 max_ll_items;
 	const bool shadow_ram_support;
 	const bool ht_greenfield_support;
+	const bool broken_powersave;
 };
 
 /***************************
diff --git a/drivers/net/wireless/iwlwifi/iwl-power.c b/drivers/net/wireless/iwlwifi/iwl-power.c
index 4ec6a83..60be976 100644
--- a/drivers/net/wireless/iwlwifi/iwl-power.c
+++ b/drivers/net/wireless/iwlwifi/iwl-power.c
@@ -292,8 +292,9 @@ int iwl_power_update_mode(struct iwl_priv *priv, bool force)
 	else
 		dtimper = 1;
 
-	/* TT power setting overwrites everything */
-	if (tt->state >= IWL_TI_1)
+	if (priv->cfg->broken_powersave)
+		iwl_power_sleep_cam_cmd(priv, &cmd);
+	else if (tt->state >= IWL_TI_1)
 		iwl_static_sleep_cmd(priv, &cmd, tt->tt_power_mode, dtimper);
 	else if (!enabled)
 		iwl_power_sleep_cam_cmd(priv, &cmd);
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index 8150c5c..b90adcb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -239,26 +239,22 @@ void iwl_rx_allocate(struct iwl_priv *priv, gfp_t priority)
 	struct iwl_rx_queue *rxq = &priv->rxq;
 	struct list_head *element;
 	struct iwl_rx_mem_buffer *rxb;
+	struct sk_buff *skb;
 	unsigned long flags;
 
 	while (1) {
 		spin_lock_irqsave(&rxq->lock, flags);
-
 		if (list_empty(&rxq->rx_used)) {
 			spin_unlock_irqrestore(&rxq->lock, flags);
 			return;
 		}
-		element = rxq->rx_used.next;
-		rxb = list_entry(element, struct iwl_rx_mem_buffer, list);
-		list_del(element);
-
 		spin_unlock_irqrestore(&rxq->lock, flags);
 
 		/* Alloc a new receive buffer */
-		rxb->skb = alloc_skb(priv->hw_params.rx_buf_size + 256,
+		skb = alloc_skb(priv->hw_params.rx_buf_size + 256,
 						priority);
 
-		if (!rxb->skb) {
+		if (!skb) {
 			IWL_CRIT(priv, "Can not allocate SKB buffers\n");
 			/* We don't reschedule replenish work here -- we will
 			 * call the restock method and if it still needs
@@ -266,6 +262,20 @@ void iwl_rx_allocate(struct iwl_priv *priv, gfp_t priority)
 			break;
 		}
 
+		spin_lock_irqsave(&rxq->lock, flags);
+
+		if (list_empty(&rxq->rx_used)) {
+			spin_unlock_irqrestore(&rxq->lock, flags);
+			dev_kfree_skb_any(skb);
+			return;
+		}
+		element = rxq->rx_used.next;
+		rxb = list_entry(element, struct iwl_rx_mem_buffer, list);
+		list_del(element);
+
+		spin_unlock_irqrestore(&rxq->lock, flags);
+
+		rxb->skb = skb;
 		/* Get physical address of RB/SKB */
 		rxb->real_dma_addr = pci_map_single(
 					priv->pci_dev,
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 2238c9f..0909668 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1134,6 +1134,7 @@ static void iwl3945_rx_allocate(struct iwl_priv *priv, gfp_t priority)
 	struct iwl_rx_queue *rxq = &priv->rxq;
 	struct list_head *element;
 	struct iwl_rx_mem_buffer *rxb;
+	struct sk_buff *skb;
 	unsigned long flags;
 
 	while (1) {
@@ -1143,17 +1144,11 @@ static void iwl3945_rx_allocate(struct iwl_priv *priv, gfp_t priority)
 			spin_unlock_irqrestore(&rxq->lock, flags);
 			return;
 		}
-
-		element = rxq->rx_used.next;
-		rxb = list_entry(element, struct iwl_rx_mem_buffer, list);
-		list_del(element);
 		spin_unlock_irqrestore(&rxq->lock, flags);
 
 		/* Alloc a new receive buffer */
-		rxb->skb =
-		    alloc_skb(priv->hw_params.rx_buf_size,
-				priority);
-		if (!rxb->skb) {
+		skb = alloc_skb(priv->hw_params.rx_buf_size, priority);
+		if (!skb) {
 			if (net_ratelimit())
 				IWL_CRIT(priv, ": Can not allocate SKB buffers\n");
 			/* We don't reschedule replenish work here -- we will
@@ -1162,6 +1157,19 @@ static void iwl3945_rx_allocate(struct iwl_priv *priv, gfp_t priority)
 			break;
 		}
 
+		spin_lock_irqsave(&rxq->lock, flags);
+		if (list_empty(&rxq->rx_used)) {
+			spin_unlock_irqrestore(&rxq->lock, flags);
+			dev_kfree_skb_any(skb);
+			return;
+		}
+		element = rxq->rx_used.next;
+		rxb = list_entry(element, struct iwl_rx_mem_buffer, list);
+		list_del(element);
+		spin_unlock_irqrestore(&rxq->lock, flags);
+
+		rxb->skb = skb;
+
 		/* If radiotap head is required, reserve some headroom here.
 		 * The physical head count is a variable rx_stats->phy_count.
 		 * We reserve 4 bytes here. Plus these extra bytes, the
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index e44460f..17e1995 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -67,6 +67,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0bf8, 0x1009)},   /* FUJITSU E-5400 USB D1700*/
 	{USB_DEVICE(0x0cde, 0x0006)},   /* Medion MD40900 */
 	{USB_DEVICE(0x0cde, 0x0008)},	/* Sagem XG703A */
+	{USB_DEVICE(0x0cde, 0x0015)},	/* Zcomax XG-705A */
 	{USB_DEVICE(0x0d8e, 0x3762)},	/* DLink DWL-G120 Cohiba */
 	{USB_DEVICE(0x124a, 0x4025)},	/* IOGear GWU513 (GW3887IK chip) */
 	{USB_DEVICE(0x1260, 0xee22)},	/* SMC 2862W-G version 2 */
diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index f853d56..9e50896 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -600,6 +600,7 @@ static int sprom_extract(struct ssb_bus *bus, struct ssb_sprom *out,
 			ssb_printk(KERN_WARNING PFX "Unsupported SPROM"
 				   "  revision %d detected. Will extract"
 				   " v1\n", out->revision);
+			out->revision = 1;
 			sprom_extract_r123(out, in);
 		}
 	}
diff --git a/drivers/ssb/sdio.c b/drivers/ssb/sdio.c
index 1140510..65a6080 100644
--- a/drivers/ssb/sdio.c
+++ b/drivers/ssb/sdio.c
@@ -21,7 +21,7 @@
 #include "ssb_private.h"
 
 /* Define the following to 1 to enable a printk on each coreswitch. */
-#define SSB_VERBOSE_SDIOCORESWITCH_DEBUG		1
+#define SSB_VERBOSE_SDIOCORESWITCH_DEBUG		0
 
 
 /* Hardware invariants CIS tuples */
@@ -333,7 +333,7 @@ static void ssb_sdio_block_read(struct ssb_device *dev, void *buffer,
 		goto out;
 
 err_out:
-	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%u), error %d\n",
+	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%zu), error %d\n",
 		bus->sdio_sbaddr >> 16, offset, reg_width, saved_count, error);
 out:
 	sdio_release_host(bus->host_sdio);
@@ -440,7 +440,7 @@ static void ssb_sdio_block_write(struct ssb_device *dev, const void *buffer,
 		goto out;
 
 err_out:
-	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%u), error %d\n",
+	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%zu), error %d\n",
 		bus->sdio_sbaddr >> 16, offset, reg_width, saved_count, error);
 out:
 	sdio_release_host(bus->host_sdio);
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 7c51429..6e5d68b 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -418,7 +418,7 @@ minstrel_rate_init(void *priv, struct ieee80211_supported_band *sband,
 
 			/* contention window */
 			tx_time_single += t_slot + min(cw, mp->cw_max);
-			cw = (cw + 1) << 1;
+			cw = (cw << 1) | 1;
 
 			tx_time += tx_time_single;
 			tx_time_cts += tx_time_single + mi->sp_ack_dur;
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 4c210c2..e5f92ee 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -662,7 +662,7 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 				int k;
 				int wiphy_freq = wiphy->bands[band]->channels[j].center_freq;
 				for (k = 0; k < wreq->num_channels; k++) {
-					int wext_freq = wreq->channel_list[k].m / 100000;
+					int wext_freq = cfg80211_wext_freq(wiphy, &wreq->channel_list[k]);
 					if (wext_freq == wiphy_freq)
 						goto wext_freq_found;
 				}
@@ -675,6 +675,11 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 		wext_freq_not_found: ;
 		}
 	}
+	/* No channels found? */
+	if (!i) {
+		err = -EINVAL;
+		goto out;
+	}
 
 	/* Set real number of channels specified in creq->channels[] */
 	creq->n_channels = i;
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 6830788..7fae7ee 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -188,7 +188,7 @@ void cfg80211_conn_work(struct work_struct *work)
 	rtnl_unlock();
 }
 
-static bool cfg80211_get_conn_bss(struct wireless_dev *wdev)
+static struct cfg80211_bss *cfg80211_get_conn_bss(struct wireless_dev *wdev)
 {
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
 	struct cfg80211_bss *bss;
@@ -205,7 +205,7 @@ static bool cfg80211_get_conn_bss(struct wireless_dev *wdev)
 			       WLAN_CAPABILITY_ESS | WLAN_CAPABILITY_PRIVACY,
 			       capa);
 	if (!bss)
-		return false;
+		return NULL;
 
 	memcpy(wdev->conn->bssid, bss->bssid, ETH_ALEN);
 	wdev->conn->params.bssid = wdev->conn->bssid;
@@ -213,14 +213,14 @@ static bool cfg80211_get_conn_bss(struct wireless_dev *wdev)
 	wdev->conn->state = CFG80211_CONN_AUTHENTICATE_NEXT;
 	schedule_work(&rdev->conn_work);
 
-	cfg80211_put_bss(bss);
-	return true;
+	return bss;
 }
 
 static void __cfg80211_sme_scan_done(struct net_device *dev)
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+	struct cfg80211_bss *bss;
 
 	ASSERT_WDEV_LOCK(wdev);
 
@@ -234,7 +234,10 @@ static void __cfg80211_sme_scan_done(struct net_device *dev)
 	    wdev->conn->state != CFG80211_CONN_SCAN_AGAIN)
 		return;
 
-	if (!cfg80211_get_conn_bss(wdev)) {
+	bss = cfg80211_get_conn_bss(wdev);
+	if (bss) {
+		cfg80211_put_bss(bss);
+	} else {
 		/* not found */
 		if (wdev->conn->state == CFG80211_CONN_SCAN_AGAIN)
 			schedule_work(&rdev->conn_work);
@@ -670,6 +673,7 @@ int __cfg80211_connect(struct cfg80211_registered_device *rdev,
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 	struct ieee80211_channel *chan;
+	struct cfg80211_bss *bss = NULL;
 	int err;
 
 	ASSERT_WDEV_LOCK(wdev);
@@ -760,7 +764,7 @@ int __cfg80211_connect(struct cfg80211_registered_device *rdev,
 
 		/* don't care about result -- but fill bssid & channel */
 		if (!wdev->conn->params.bssid || !wdev->conn->params.channel)
-			cfg80211_get_conn_bss(wdev);
+			bss = cfg80211_get_conn_bss(wdev);
 
 		wdev->sme_state = CFG80211_SME_CONNECTING;
 		wdev->connect_keys = connkeys;
@@ -770,10 +774,11 @@ int __cfg80211_connect(struct cfg80211_registered_device *rdev,
 			wdev->conn->prev_bssid_valid = true;
 		}
 
-		/* we're good if we have both BSSID and channel */
-		if (wdev->conn->params.bssid && wdev->conn->params.channel) {
+		/* we're good if we have a matching bss struct */
+		if (bss) {
 			wdev->conn->state = CFG80211_CONN_AUTHENTICATE_NEXT;
 			err = cfg80211_conn_do_work(wdev);
+			cfg80211_put_bss(bss);
 		} else {
 			/* otherwise we'll need to scan for the AP first */
 			err = cfg80211_conn_scan(wdev);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
