From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-08-19
Date: Thu, 19 Aug 2010 13:46:38 -0400
Message-ID: <20100819174638.GC2672@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33489 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab0HSR7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 13:59:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This collection of fixes intended for 2.6.36 includes a few that look
bigger than they really are.  The one from Joe Perches corrects a number
of inadvertant upper->lower case conversion from an earlier patch
already in 2.6.36.  The ones from Wey-Yi Guy change a timer value in a
number of device-dependent data structures in order to avoid excessive
firmware resets for those devices.

In addition to those, the one from Johannes Berg gives iwl3945 its own
filter flag function since sharing the iwlagn version has created
regressions for iwl3945.  The one from me corrects a DMA API misuse in
ipw2100 that results in warning backtraces.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 0645bab7da3cb021157e5c661ef35f1d1226785a:

  ibmveth: Fix opps during MTU change on an active device (2010-08-19 00:09:48 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Joe Perches (1):
      drivers/net/wireless: Restore upper case words in wiphy_<level> messages

Johannes Berg (1):
      iwlwifi: fix 3945 filter flags

John W. Linville (1):
      ipw2100: don't sync status queue entries

Wey-Yi Guy (3):
      iwlwifi: long monitor timer
      iwlwifi: use long monitor timer to avoid un-necessary reload
      iwlwifi: use long monitor timer for 5300 series

 drivers/net/wireless/adm8211.c                 |    8 ++--
 drivers/net/wireless/at76c50x-usb.c            |   22 +++++-----
 drivers/net/wireless/ath/ar9170/main.c         |    4 +-
 drivers/net/wireless/ipw2x00/ipw2100.c         |    8 ----
 drivers/net/wireless/iwlwifi/iwl-1000.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c        |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c        |   14 +++---
 drivers/net/wireless/iwlwifi/iwl-6000.c        |   32 +++++++-------
 drivers/net/wireless/iwlwifi/iwl-agn.c         |   45 ++++++++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-core.c        |   45 ---------------------
 drivers/net/wireless/iwlwifi/iwl-core.h        |    3 -
 drivers/net/wireless/iwlwifi/iwl-dev.h         |    3 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |   51 +++++++++++++++++++++++-
 drivers/net/wireless/mac80211_hwsim.c          |    2 +-
 drivers/net/wireless/mwl8k.c                   |   34 ++++++++--------
 drivers/net/wireless/p54/eeprom.c              |    6 +-
 drivers/net/wireless/p54/fwio.c                |    2 +-
 drivers/net/wireless/p54/led.c                 |    4 +-
 drivers/net/wireless/p54/p54pci.c              |    2 +-
 drivers/net/wireless/p54/txrx.c                |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c     |    6 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |    4 +-
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |    4 +-
 24 files changed, 174 insertions(+), 137 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index a105087..f9aa1bc 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -732,7 +732,7 @@ static int adm8211_rf_set_channel(struct ieee80211_hw *dev, unsigned int chan)
 
 	/* Nothing to do for ADMtek BBP */
 	} else if (priv->bbp_type != ADM8211_TYPE_ADMTEK)
-		wiphy_debug(dev->wiphy, "unsupported bbp type %d\n",
+		wiphy_debug(dev->wiphy, "unsupported BBP type %d\n",
 			    priv->bbp_type);
 
 	ADM8211_RESTORE();
@@ -1032,7 +1032,7 @@ static int adm8211_hw_init_bbp(struct ieee80211_hw *dev)
 			break;
 		}
 	} else
-		wiphy_debug(dev->wiphy, "unsupported bbp %d\n", priv->bbp_type);
+		wiphy_debug(dev->wiphy, "unsupported BBP %d\n", priv->bbp_type);
 
 	ADM8211_CSR_WRITE(SYNRF, 0);
 
@@ -1525,7 +1525,7 @@ static int adm8211_start(struct ieee80211_hw *dev)
 	retval = request_irq(priv->pdev->irq, adm8211_interrupt,
 			     IRQF_SHARED, "adm8211", dev);
 	if (retval) {
-		wiphy_err(dev->wiphy, "failed to register irq handler\n");
+		wiphy_err(dev->wiphy, "failed to register IRQ handler\n");
 		goto fail;
 	}
 
@@ -1902,7 +1902,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 		goto err_free_eeprom;
 	}
 
-	wiphy_info(dev->wiphy, "hwaddr %pm, rev 0x%02x\n",
+	wiphy_info(dev->wiphy, "hwaddr %pM, Rev 0x%02x\n",
 		   dev->wiphy->perm_addr, pdev->revision);
 
 	return 0;
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index d5140a8..1128fa8 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -655,7 +655,7 @@ static int at76_get_hw_config(struct at76_priv *priv)
 exit:
 	kfree(hwcfg);
 	if (ret < 0)
-		wiphy_err(priv->hw->wiphy, "cannot get hw config (error %d)\n",
+		wiphy_err(priv->hw->wiphy, "cannot get HW Config (error %d)\n",
 			  ret);
 
 	return ret;
@@ -960,7 +960,7 @@ static void at76_dump_mib_mac_addr(struct at76_priv *priv)
 			   sizeof(struct mib_mac_addr));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (mac_addr) failed: %d\n", ret);
+			  "at76_get_mib (MAC_ADDR) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -989,7 +989,7 @@ static void at76_dump_mib_mac_wep(struct at76_priv *priv)
 			   sizeof(struct mib_mac_wep));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (mac_wep) failed: %d\n", ret);
+			  "at76_get_mib (MAC_WEP) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1026,7 +1026,7 @@ static void at76_dump_mib_mac_mgmt(struct at76_priv *priv)
 			   sizeof(struct mib_mac_mgmt));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (mac_mgmt) failed: %d\n", ret);
+			  "at76_get_mib (MAC_MGMT) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1062,7 +1062,7 @@ static void at76_dump_mib_mac(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_MAC, m, sizeof(struct mib_mac));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (mac) failed: %d\n", ret);
+			  "at76_get_mib (MAC) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1099,7 +1099,7 @@ static void at76_dump_mib_phy(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_PHY, m, sizeof(struct mib_phy));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (phy) failed: %d\n", ret);
+			  "at76_get_mib (PHY) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1132,7 +1132,7 @@ static void at76_dump_mib_local(struct at76_priv *priv)
 	ret = at76_get_mib(priv->udev, MIB_LOCAL, m, sizeof(struct mib_local));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (local) failed: %d\n", ret);
+			  "at76_get_mib (LOCAL) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1158,7 +1158,7 @@ static void at76_dump_mib_mdomain(struct at76_priv *priv)
 			   sizeof(struct mib_mdomain));
 	if (ret < 0) {
 		wiphy_err(priv->hw->wiphy,
-			  "at76_get_mib (mdomain) failed: %d\n", ret);
+			  "at76_get_mib (MDOMAIN) failed: %d\n", ret);
 		goto exit;
 	}
 
@@ -1229,7 +1229,7 @@ static int at76_submit_rx_urb(struct at76_priv *priv)
 	struct sk_buff *skb = priv->rx_skb;
 
 	if (!priv->rx_urb) {
-		wiphy_err(priv->hw->wiphy, "%s: priv->rx_urb is null\n",
+		wiphy_err(priv->hw->wiphy, "%s: priv->rx_urb is NULL\n",
 			  __func__);
 		return -EFAULT;
 	}
@@ -1792,7 +1792,7 @@ static int at76_mac80211_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 		wiphy_err(priv->hw->wiphy, "error in tx submit urb: %d\n", ret);
 		if (ret == -EINVAL)
 			wiphy_err(priv->hw->wiphy,
-				  "-einval: tx urb %p hcpriv %p complete %p\n",
+				  "-EINVAL: tx urb %p hcpriv %p complete %p\n",
 				  priv->tx_urb,
 				  priv->tx_urb->hcpriv, priv->tx_urb->complete);
 	}
@@ -2310,7 +2310,7 @@ static int at76_init_new_device(struct at76_priv *priv,
 
 	priv->mac80211_registered = 1;
 
-	wiphy_info(priv->hw->wiphy, "usb %s, mac %pm, firmware %d.%d.%d-%d\n",
+	wiphy_info(priv->hw->wiphy, "USB %s, MAC %pM, firmware %d.%d.%d-%d\n",
 		   dev_name(&interface->dev), priv->mac_addr,
 		   priv->fw_version.major, priv->fw_version.minor,
 		   priv->fw_version.patch, priv->fw_version.build);
diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
index c67b05f..debfb0f 100644
--- a/drivers/net/wireless/ath/ar9170/main.c
+++ b/drivers/net/wireless/ath/ar9170/main.c
@@ -245,7 +245,7 @@ static void __ar9170_dump_txstats(struct ar9170 *ar)
 {
 	int i;
 
-	wiphy_debug(ar->hw->wiphy, "qos queue stats\n");
+	wiphy_debug(ar->hw->wiphy, "QoS queue stats\n");
 
 	for (i = 0; i < __AR9170_NUM_TXQ; i++)
 		wiphy_debug(ar->hw->wiphy,
@@ -387,7 +387,7 @@ static struct sk_buff *ar9170_get_queued_skb(struct ar9170 *ar,
 		if (mac && compare_ether_addr(ieee80211_get_DA(hdr), mac)) {
 #ifdef AR9170_QUEUE_DEBUG
 			wiphy_debug(ar->hw->wiphy,
-				    "skip frame => da %pm != %pm\n",
+				    "skip frame => DA %pM != %pM\n",
 				    mac, ieee80211_get_DA(hdr));
 			ar9170_print_txheader(ar, skb);
 #endif /* AR9170_QUEUE_DEBUG */
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 1189dbb..996e9d7 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -2723,14 +2723,6 @@ static void __ipw2100_rx_process(struct ipw2100_priv *priv)
 
 		packet = &priv->rx_buffers[i];
 
-		/* Sync the DMA for the STATUS buffer so CPU is sure to get
-		 * the correct values */
-		pci_dma_sync_single_for_cpu(priv->pci_dev,
-					    sq->nic +
-					    sizeof(struct ipw2100_status) * i,
-					    sizeof(struct ipw2100_status),
-					    PCI_DMA_FROMDEVICE);
-
 		/* Sync the DMA for the RX buffer so CPU is sure to get
 		 * the correct values */
 		pci_dma_sync_single_for_cpu(priv->pci_dev, packet->dma_addr,
diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index fec0262..0b779a4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -265,7 +265,7 @@ struct iwl_cfg iwl1000_bgn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_EXT_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 128,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -297,7 +297,7 @@ struct iwl_cfg iwl1000_bg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_EXT_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 128,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 6950a78..8ccfcd0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2731,7 +2731,7 @@ static struct iwl_cfg iwl3945_bg_cfg = {
 	.led_compensation = 64,
 	.broken_powersave = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.tx_power_by_driver = true,
 };
@@ -2752,7 +2752,7 @@ static struct iwl_cfg iwl3945_abg_cfg = {
 	.led_compensation = 64,
 	.broken_powersave = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.tx_power_by_driver = true,
 };
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index d6da356..d92b729 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2322,7 +2322,7 @@ struct iwl_cfg iwl4965_agn_cfg = {
 	.led_compensation = 61,
 	.chain_noise_num_beacons = IWL4965_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.temperature_kelvin = true,
 	.max_event_log_size = 512,
 	.tx_power_by_driver = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index aacf377..48bdcd8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -510,7 +510,7 @@ struct iwl_cfg iwl5300_agn_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -541,7 +541,7 @@ struct iwl_cfg iwl5100_bgn_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -570,7 +570,7 @@ struct iwl_cfg iwl5100_abg_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -601,7 +601,7 @@ struct iwl_cfg iwl5100_agn_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -632,7 +632,7 @@ struct iwl_cfg iwl5350_agn_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -663,7 +663,7 @@ struct iwl_cfg iwl5150_agn_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -693,7 +693,7 @@ struct iwl_cfg iwl5150_abg_cfg = {
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index af4fd50..cee06b9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -388,7 +388,7 @@ struct iwl_cfg iwl6000g2a_2agn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -424,7 +424,7 @@ struct iwl_cfg iwl6000g2a_2abg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -459,7 +459,7 @@ struct iwl_cfg iwl6000g2a_2bg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -496,7 +496,7 @@ struct iwl_cfg iwl6000g2b_2agn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -532,7 +532,7 @@ struct iwl_cfg iwl6000g2b_2abg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -570,7 +570,7 @@ struct iwl_cfg iwl6000g2b_2bgn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -606,7 +606,7 @@ struct iwl_cfg iwl6000g2b_2bg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -644,7 +644,7 @@ struct iwl_cfg iwl6000g2b_bgn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -680,7 +680,7 @@ struct iwl_cfg iwl6000g2b_bg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_LONG_MONITORING_PERIOD,
 	.max_event_log_size = 512,
 	.sensitivity_calib_by_driver = true,
 	.chain_noise_calib_by_driver = true,
@@ -721,7 +721,7 @@ struct iwl_cfg iwl6000i_2agn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -756,7 +756,7 @@ struct iwl_cfg iwl6000i_2abg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -791,7 +791,7 @@ struct iwl_cfg iwl6000i_2bg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -828,7 +828,7 @@ struct iwl_cfg iwl6050_2agn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1500,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -866,7 +866,7 @@ struct iwl_cfg iwl6050g2_bgn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1500,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -902,7 +902,7 @@ struct iwl_cfg iwl6050_2abg_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1500,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
@@ -940,7 +940,7 @@ struct iwl_cfg iwl6000_3agn_cfg = {
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
-	.monitor_recover_period = IWL_MONITORING_PERIOD,
+	.monitor_recover_period = IWL_DEF_MONITORING_PERIOD,
 	.max_event_log_size = 1024,
 	.ucode_tracing = true,
 	.sensitivity_calib_by_driver = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index c1882fd..10d7b9b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3667,6 +3667,49 @@ out_exit:
 	IWL_DEBUG_MAC80211(priv, "leave\n");
 }
 
+static void iwlagn_configure_filter(struct ieee80211_hw *hw,
+				    unsigned int changed_flags,
+				    unsigned int *total_flags,
+				    u64 multicast)
+{
+	struct iwl_priv *priv = hw->priv;
+	__le32 filter_or = 0, filter_nand = 0;
+
+#define CHK(test, flag)	do { \
+	if (*total_flags & (test))		\
+		filter_or |= (flag);		\
+	else					\
+		filter_nand |= (flag);		\
+	} while (0)
+
+	IWL_DEBUG_MAC80211(priv, "Enter: changed: 0x%x, total: 0x%x\n",
+			changed_flags, *total_flags);
+
+	CHK(FIF_OTHER_BSS | FIF_PROMISC_IN_BSS, RXON_FILTER_PROMISC_MSK);
+	CHK(FIF_CONTROL, RXON_FILTER_CTL2HOST_MSK);
+	CHK(FIF_BCN_PRBRESP_PROMISC, RXON_FILTER_BCON_AWARE_MSK);
+
+#undef CHK
+
+	mutex_lock(&priv->mutex);
+
+	priv->staging_rxon.filter_flags &= ~filter_nand;
+	priv->staging_rxon.filter_flags |= filter_or;
+
+	iwlcore_commit_rxon(priv);
+
+	mutex_unlock(&priv->mutex);
+
+	/*
+	 * Receiving all multicast frames is always enabled by the
+	 * default flags setup in iwl_connection_init_rx_config()
+	 * since we currently do not support programming multicast
+	 * filters into the device.
+	 */
+	*total_flags &= FIF_OTHER_BSS | FIF_ALLMULTI | FIF_PROMISC_IN_BSS |
+			FIF_BCN_PRBRESP_PROMISC | FIF_CONTROL;
+}
+
 static void iwl_mac_flush(struct ieee80211_hw *hw, bool drop)
 {
 	struct iwl_priv *priv = hw->priv;
@@ -3867,7 +3910,7 @@ static struct ieee80211_ops iwl_hw_ops = {
 	.add_interface = iwl_mac_add_interface,
 	.remove_interface = iwl_mac_remove_interface,
 	.config = iwl_mac_config,
-	.configure_filter = iwl_configure_filter,
+	.configure_filter = iwlagn_configure_filter,
 	.set_key = iwl_mac_set_key,
 	.update_tkip_key = iwl_mac_update_tkip_key,
 	.conf_tx = iwl_mac_conf_tx,
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 2c03c6e..07dbc27 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1328,51 +1328,6 @@ out:
 EXPORT_SYMBOL(iwl_apm_init);
 
 
-
-void iwl_configure_filter(struct ieee80211_hw *hw,
-			  unsigned int changed_flags,
-			  unsigned int *total_flags,
-			  u64 multicast)
-{
-	struct iwl_priv *priv = hw->priv;
-	__le32 filter_or = 0, filter_nand = 0;
-
-#define CHK(test, flag)	do { \
-	if (*total_flags & (test))		\
-		filter_or |= (flag);		\
-	else					\
-		filter_nand |= (flag);		\
-	} while (0)
-
-	IWL_DEBUG_MAC80211(priv, "Enter: changed: 0x%x, total: 0x%x\n",
-			changed_flags, *total_flags);
-
-	CHK(FIF_OTHER_BSS | FIF_PROMISC_IN_BSS, RXON_FILTER_PROMISC_MSK);
-	CHK(FIF_CONTROL, RXON_FILTER_CTL2HOST_MSK);
-	CHK(FIF_BCN_PRBRESP_PROMISC, RXON_FILTER_BCON_AWARE_MSK);
-
-#undef CHK
-
-	mutex_lock(&priv->mutex);
-
-	priv->staging_rxon.filter_flags &= ~filter_nand;
-	priv->staging_rxon.filter_flags |= filter_or;
-
-	iwlcore_commit_rxon(priv);
-
-	mutex_unlock(&priv->mutex);
-
-	/*
-	 * Receiving all multicast frames is always enabled by the
-	 * default flags setup in iwl_connection_init_rx_config()
-	 * since we currently do not support programming multicast
-	 * filters into the device.
-	 */
-	*total_flags &= FIF_OTHER_BSS | FIF_ALLMULTI | FIF_PROMISC_IN_BSS |
-			FIF_BCN_PRBRESP_PROMISC | FIF_CONTROL;
-}
-EXPORT_SYMBOL(iwl_configure_filter);
-
 int iwl_set_hw_params(struct iwl_priv *priv)
 {
 	priv->hw_params.max_rxq_size = RX_QUEUE_SIZE;
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 4a71dfb..5e6ee3d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -372,9 +372,6 @@ int iwl_set_decrypted_flag(struct iwl_priv *priv,
 			   u32 decrypt_res,
 			   struct ieee80211_rx_status *stats);
 void iwl_irq_handle_error(struct iwl_priv *priv);
-void iwl_configure_filter(struct ieee80211_hw *hw,
-			  unsigned int changed_flags,
-			  unsigned int *total_flags, u64 multicast);
 int iwl_set_hw_params(struct iwl_priv *priv);
 void iwl_post_associate(struct iwl_priv *priv, struct ieee80211_vif *vif);
 void iwl_bss_info_changed(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index f35bcad..2e97cd2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -1049,7 +1049,8 @@ struct iwl_event_log {
 #define IWL_DELAY_NEXT_FORCE_FW_RELOAD (HZ*5)
 
 /* timer constants use to monitor and recover stuck tx queues in mSecs */
-#define IWL_MONITORING_PERIOD  (1000)
+#define IWL_DEF_MONITORING_PERIOD	(1000)
+#define IWL_LONG_MONITORING_PERIOD	(5000)
 #define IWL_ONE_HUNDRED_MSECS   (100)
 #define IWL_SIXTY_SECS          (60000)
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 70c4b8f..59a308b 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -3391,6 +3391,55 @@ static int iwl3945_mac_sta_add(struct ieee80211_hw *hw,
 
 	return 0;
 }
+
+static void iwl3945_configure_filter(struct ieee80211_hw *hw,
+				     unsigned int changed_flags,
+				     unsigned int *total_flags,
+				     u64 multicast)
+{
+	struct iwl_priv *priv = hw->priv;
+	__le32 filter_or = 0, filter_nand = 0;
+
+#define CHK(test, flag)	do { \
+	if (*total_flags & (test))		\
+		filter_or |= (flag);		\
+	else					\
+		filter_nand |= (flag);		\
+	} while (0)
+
+	IWL_DEBUG_MAC80211(priv, "Enter: changed: 0x%x, total: 0x%x\n",
+			changed_flags, *total_flags);
+
+	CHK(FIF_OTHER_BSS | FIF_PROMISC_IN_BSS, RXON_FILTER_PROMISC_MSK);
+	CHK(FIF_CONTROL, RXON_FILTER_CTL2HOST_MSK);
+	CHK(FIF_BCN_PRBRESP_PROMISC, RXON_FILTER_BCON_AWARE_MSK);
+
+#undef CHK
+
+	mutex_lock(&priv->mutex);
+
+	priv->staging_rxon.filter_flags &= ~filter_nand;
+	priv->staging_rxon.filter_flags |= filter_or;
+
+	/*
+	 * Committing directly here breaks for some reason,
+	 * but we'll eventually commit the filter flags
+	 * change anyway.
+	 */
+
+	mutex_unlock(&priv->mutex);
+
+	/*
+	 * Receiving all multicast frames is always enabled by the
+	 * default flags setup in iwl_connection_init_rx_config()
+	 * since we currently do not support programming multicast
+	 * filters into the device.
+	 */
+	*total_flags &= FIF_OTHER_BSS | FIF_ALLMULTI | FIF_PROMISC_IN_BSS |
+			FIF_BCN_PRBRESP_PROMISC | FIF_CONTROL;
+}
+
+
 /*****************************************************************************
  *
  * sysfs attributes
@@ -3796,7 +3845,7 @@ static struct ieee80211_ops iwl3945_hw_ops = {
 	.add_interface = iwl_mac_add_interface,
 	.remove_interface = iwl_mac_remove_interface,
 	.config = iwl_mac_config,
-	.configure_filter = iwl_configure_filter,
+	.configure_filter = iwl3945_configure_filter,
 	.set_key = iwl3945_mac_set_key,
 	.conf_tx = iwl_mac_conf_tx,
 	.reset_tsf = iwl_mac_reset_tsf,
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 01ad7f7..86fa8ab 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -486,7 +486,7 @@ static bool mac80211_hwsim_tx_frame(struct ieee80211_hw *hw,
 	struct ieee80211_rx_status rx_status;
 
 	if (data->idle) {
-		wiphy_debug(hw->wiphy, "trying to tx when idle - reject\n");
+		wiphy_debug(hw->wiphy, "Trying to TX when idle - reject\n");
 		return false;
 	}
 
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index d761ed2..f152a25 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -910,14 +910,14 @@ static int mwl8k_rxq_init(struct ieee80211_hw *hw, int index)
 
 	rxq->rxd = pci_alloc_consistent(priv->pdev, size, &rxq->rxd_dma);
 	if (rxq->rxd == NULL) {
-		wiphy_err(hw->wiphy, "failed to alloc rx descriptors\n");
+		wiphy_err(hw->wiphy, "failed to alloc RX descriptors\n");
 		return -ENOMEM;
 	}
 	memset(rxq->rxd, 0, size);
 
 	rxq->buf = kmalloc(MWL8K_RX_DESCS * sizeof(*rxq->buf), GFP_KERNEL);
 	if (rxq->buf == NULL) {
-		wiphy_err(hw->wiphy, "failed to alloc rx skbuff list\n");
+		wiphy_err(hw->wiphy, "failed to alloc RX skbuff list\n");
 		pci_free_consistent(priv->pdev, size, rxq->rxd, rxq->rxd_dma);
 		return -ENOMEM;
 	}
@@ -1145,14 +1145,14 @@ static int mwl8k_txq_init(struct ieee80211_hw *hw, int index)
 
 	txq->txd = pci_alloc_consistent(priv->pdev, size, &txq->txd_dma);
 	if (txq->txd == NULL) {
-		wiphy_err(hw->wiphy, "failed to alloc tx descriptors\n");
+		wiphy_err(hw->wiphy, "failed to alloc TX descriptors\n");
 		return -ENOMEM;
 	}
 	memset(txq->txd, 0, size);
 
 	txq->skb = kmalloc(MWL8K_TX_DESCS * sizeof(*txq->skb), GFP_KERNEL);
 	if (txq->skb == NULL) {
-		wiphy_err(hw->wiphy, "failed to alloc tx skbuff list\n");
+		wiphy_err(hw->wiphy, "failed to alloc TX skbuff list\n");
 		pci_free_consistent(priv->pdev, size, txq->txd, txq->txd_dma);
 		return -ENOMEM;
 	}
@@ -1573,7 +1573,7 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 					PCI_DMA_BIDIRECTIONAL);
 
 	if (!timeout) {
-		wiphy_err(hw->wiphy, "command %s timeout after %u ms\n",
+		wiphy_err(hw->wiphy, "Command %s timeout after %u ms\n",
 			  mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
 			  MWL8K_CMD_TIMEOUT_MS);
 		rc = -ETIMEDOUT;
@@ -1584,11 +1584,11 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 
 		rc = cmd->result ? -EINVAL : 0;
 		if (rc)
-			wiphy_err(hw->wiphy, "command %s error 0x%x\n",
+			wiphy_err(hw->wiphy, "Command %s error 0x%x\n",
 				  mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
 				  le16_to_cpu(cmd->result));
 		else if (ms > 2000)
-			wiphy_notice(hw->wiphy, "command %s took %d ms\n",
+			wiphy_notice(hw->wiphy, "Command %s took %d ms\n",
 				     mwl8k_cmd_name(cmd->code,
 						    buf, sizeof(buf)),
 				     ms);
@@ -3210,7 +3210,7 @@ static int mwl8k_start(struct ieee80211_hw *hw)
 	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
-		wiphy_err(hw->wiphy, "failed to register irq handler\n");
+		wiphy_err(hw->wiphy, "failed to register IRQ handler\n");
 		return -EIO;
 	}
 
@@ -3926,7 +3926,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 
 	priv->sram = pci_iomap(pdev, 0, 0x10000);
 	if (priv->sram == NULL) {
-		wiphy_err(hw->wiphy, "cannot map device sram\n");
+		wiphy_err(hw->wiphy, "Cannot map device SRAM\n");
 		goto err_iounmap;
 	}
 
@@ -3938,7 +3938,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	if (priv->regs == NULL) {
 		priv->regs = pci_iomap(pdev, 2, 0x10000);
 		if (priv->regs == NULL) {
-			wiphy_err(hw->wiphy, "cannot map device registers\n");
+			wiphy_err(hw->wiphy, "Cannot map device registers\n");
 			goto err_iounmap;
 		}
 	}
@@ -3950,14 +3950,14 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	/* Ask userland hotplug daemon for the device firmware */
 	rc = mwl8k_request_firmware(priv);
 	if (rc) {
-		wiphy_err(hw->wiphy, "firmware files not found\n");
+		wiphy_err(hw->wiphy, "Firmware files not found\n");
 		goto err_stop_firmware;
 	}
 
 	/* Load firmware into hardware */
 	rc = mwl8k_load_firmware(hw);
 	if (rc) {
-		wiphy_err(hw->wiphy, "cannot start firmware\n");
+		wiphy_err(hw->wiphy, "Cannot start firmware\n");
 		goto err_stop_firmware;
 	}
 
@@ -4047,7 +4047,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
-		wiphy_err(hw->wiphy, "failed to register irq handler\n");
+		wiphy_err(hw->wiphy, "failed to register IRQ handler\n");
 		goto err_free_queues;
 	}
 
@@ -4067,7 +4067,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 		rc = mwl8k_cmd_get_hw_spec_sta(hw);
 	}
 	if (rc) {
-		wiphy_err(hw->wiphy, "cannot initialise firmware\n");
+		wiphy_err(hw->wiphy, "Cannot initialise firmware\n");
 		goto err_free_irq;
 	}
 
@@ -4081,14 +4081,14 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	/* Turn radio off */
 	rc = mwl8k_cmd_radio_disable(hw);
 	if (rc) {
-		wiphy_err(hw->wiphy, "cannot disable\n");
+		wiphy_err(hw->wiphy, "Cannot disable\n");
 		goto err_free_irq;
 	}
 
 	/* Clear MAC address */
 	rc = mwl8k_cmd_set_mac_addr(hw, NULL, "\x00\x00\x00\x00\x00\x00");
 	if (rc) {
-		wiphy_err(hw->wiphy, "cannot clear mac address\n");
+		wiphy_err(hw->wiphy, "Cannot clear MAC address\n");
 		goto err_free_irq;
 	}
 
@@ -4098,7 +4098,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 
 	rc = ieee80211_register_hw(hw);
 	if (rc) {
-		wiphy_err(hw->wiphy, "cannot register device\n");
+		wiphy_err(hw->wiphy, "Cannot register device\n");
 		goto err_free_queues;
 	}
 
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index d687cb7..78347041 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -167,7 +167,7 @@ static int p54_generate_band(struct ieee80211_hw *dev,
 	}
 
 	if (j == 0) {
-		wiphy_err(dev->wiphy, "disabling totally damaged %d GHz band\n",
+		wiphy_err(dev->wiphy, "Disabling totally damaged %d GHz band\n",
 			  (band == IEEE80211_BAND_2GHZ) ? 2 : 5);
 
 		ret = -ENODATA;
@@ -695,12 +695,12 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 		u8 perm_addr[ETH_ALEN];
 
 		wiphy_warn(dev->wiphy,
-			   "invalid hwaddr! using randomly generated mac addr\n");
+			   "Invalid hwaddr! Using randomly generated MAC addr\n");
 		random_ether_addr(perm_addr);
 		SET_IEEE80211_PERM_ADDR(dev, perm_addr);
 	}
 
-	wiphy_info(dev->wiphy, "hwaddr %pm, mac:isl38%02x rf:%s\n",
+	wiphy_info(dev->wiphy, "hwaddr %pM, MAC:isl38%02x RF:%s\n",
 		   dev->wiphy->perm_addr, priv->version,
 		   p54_rf_chips[priv->rxhw]);
 
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index 47006bc..15b20c2 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -125,7 +125,7 @@ int p54_parse_firmware(struct ieee80211_hw *dev, const struct firmware *fw)
 
 	if (fw_version)
 		wiphy_info(priv->hw->wiphy,
-			   "fw rev %s - softmac protocol %x.%x\n",
+			   "FW rev %s - Softmac protocol %x.%x\n",
 			   fw_version, priv->fw_var >> 8, priv->fw_var & 0xff);
 
 	if (priv->fw_var < 0x500)
diff --git a/drivers/net/wireless/p54/led.c b/drivers/net/wireless/p54/led.c
index ea91f5c..3837e1e 100644
--- a/drivers/net/wireless/p54/led.c
+++ b/drivers/net/wireless/p54/led.c
@@ -58,7 +58,7 @@ static void p54_update_leds(struct work_struct *work)
 	err = p54_set_leds(priv);
 	if (err && net_ratelimit())
 		wiphy_err(priv->hw->wiphy,
-			  "failed to update leds (%d).\n", err);
+			  "failed to update LEDs (%d).\n", err);
 
 	if (rerun)
 		ieee80211_queue_delayed_work(priv->hw, &priv->led_work,
@@ -103,7 +103,7 @@ static int p54_register_led(struct p54_common *priv,
 	err = led_classdev_register(wiphy_dev(priv->hw->wiphy), &led->led_dev);
 	if (err)
 		wiphy_err(priv->hw->wiphy,
-			  "failed to register %s led.\n", name);
+			  "Failed to register %s LED.\n", name);
 	else
 		led->registered = 1;
 
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 822f8dc..1eacba4 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -466,7 +466,7 @@ static int p54p_open(struct ieee80211_hw *dev)
 	P54P_READ(dev_int);
 
 	if (!wait_for_completion_interruptible_timeout(&priv->boot_comp, HZ)) {
-		wiphy_err(dev->wiphy, "cannot boot firmware!\n");
+		wiphy_err(dev->wiphy, "Cannot boot firmware!\n");
 		p54p_stop(dev);
 		return -ETIMEDOUT;
 	}
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 427b46f..173aec3 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -540,7 +540,7 @@ static void p54_rx_trap(struct p54_common *priv, struct sk_buff *skb)
 	case P54_TRAP_BEACON_TX:
 		break;
 	case P54_TRAP_RADAR:
-		wiphy_info(priv->hw->wiphy, "radar (freq:%d mhz)\n", freq);
+		wiphy_info(priv->hw->wiphy, "radar (freq:%d MHz)\n", freq);
 		break;
 	case P54_TRAP_NO_BEACON:
 		if (priv->vif)
diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/wireless/rtl818x/rtl8180_dev.c
index b50c39a..30107ce 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -445,7 +445,7 @@ static int rtl8180_init_rx_ring(struct ieee80211_hw *dev)
 					     &priv->rx_ring_dma);
 
 	if (!priv->rx_ring || (unsigned long)priv->rx_ring & 0xFF) {
-		wiphy_err(dev->wiphy, "cannot allocate rx ring\n");
+		wiphy_err(dev->wiphy, "Cannot allocate RX ring\n");
 		return -ENOMEM;
 	}
 
@@ -502,7 +502,7 @@ static int rtl8180_init_tx_ring(struct ieee80211_hw *dev,
 
 	ring = pci_alloc_consistent(priv->pdev, sizeof(*ring) * entries, &dma);
 	if (!ring || (unsigned long)ring & 0xFF) {
-		wiphy_err(dev->wiphy, "cannot allocate tx ring (prio = %d)\n",
+		wiphy_err(dev->wiphy, "Cannot allocate TX ring (prio = %d)\n",
 			  prio);
 		return -ENOMEM;
 	}
@@ -568,7 +568,7 @@ static int rtl8180_start(struct ieee80211_hw *dev)
 	ret = request_irq(priv->pdev->irq, rtl8180_interrupt,
 			  IRQF_SHARED, KBUILD_MODNAME, dev);
 	if (ret) {
-		wiphy_err(dev->wiphy, "failed to register irq handler\n");
+		wiphy_err(dev->wiphy, "failed to register IRQ handler\n");
 		goto err_free_rings;
 	}
 
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 5738a55..98e0351 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -573,7 +573,7 @@ static int rtl8187_cmd_reset(struct ieee80211_hw *dev)
 	} while (--i);
 
 	if (!i) {
-		wiphy_err(dev->wiphy, "reset timeout!\n");
+		wiphy_err(dev->wiphy, "Reset timeout!\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1526,7 +1526,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	mutex_init(&priv->conf_mutex);
 	skb_queue_head_init(&priv->b_tx_status.queue);
 
-	wiphy_info(dev->wiphy, "hwaddr %pm, %s v%d + %s, rfkill mask %d\n",
+	wiphy_info(dev->wiphy, "hwaddr %pM, %s V%d + %s, rfkill mask %d\n",
 		   mac_addr, chip_name, priv->asic_rev, priv->rf->name,
 		   priv->rfkill_mask);
 
diff --git a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
index fd96f91..97eebdc 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
@@ -366,7 +366,7 @@ static void rtl8225_rf_init(struct ieee80211_hw *dev)
 		rtl8225_write(dev, 0x02, 0x044d);
 		msleep(100);
 		if (!(rtl8225_read(dev, 6) & (1 << 7)))
-			wiphy_warn(dev->wiphy, "rf calibration failed! %x\n",
+			wiphy_warn(dev->wiphy, "RF Calibration Failed! %x\n",
 				   rtl8225_read(dev, 6));
 	}
 
@@ -735,7 +735,7 @@ static void rtl8225z2_rf_init(struct ieee80211_hw *dev)
 		rtl8225_write(dev, 0x02, 0x044D);
 		msleep(100);
 		if (!(rtl8225_read(dev, 6) & (1 << 7)))
-			wiphy_warn(dev->wiphy, "rf calibration failed! %x\n",
+			wiphy_warn(dev->wiphy, "RF Calibration Failed! %x\n",
 				   rtl8225_read(dev, 6));
 	}
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
