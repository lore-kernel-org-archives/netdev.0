From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-08-10
Date: Tue, 10 Aug 2010 16:42:51 -0400
Message-ID: <20100810204251.GB2728@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few more fixes intended for 2.6.36.  Included are a locking
fix for cfg80211, a fix for iwlagn to prevent it from using RTS/CTS
or CTS-to-self protection on every frame (even inappropriately),
a reversion of a mistakenly added PCI ID from p54, and a simple fix
for some build breakage some have been experiencing in libertas.
Also included are a handful of Bluetooth fixes by way of Marcel.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9871e50edd25e2adf69b369817100821cb1e6de8:

  net: Use NET_XMIT_SUCCESS where possible. (2010-08-10 02:51:11 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (2):
      cfg80211: fix locking in action frame TX
      iwlagn: fix rts cts protection

John W. Linville (3):
      Revert "p54pci: Add PCI ID for SMC2802W"
      libertas: fix build break by including linux/sched.h
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Mat Martineau (4):
      Bluetooth: Fix endianness issue with L2CAP MPS configuration
      Bluetooth: Change default L2CAP ERTM retransmit timeout
      Bluetooth: Fix incorrect setting of remote_tx_win for L2CAP ERTM
      Bluetooth: Use 3-DH5 payload size for default ERTM max PDU size

 drivers/net/wireless/iwlwifi/iwl-1000.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   18 +-----
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   10 ++--
 drivers/net/wireless/iwlwifi/iwl-6000.c     |   16 +++---
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c |   19 +++++-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |   20 +------
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   85 +++++++--------------------
 drivers/net/wireless/iwlwifi/iwl-core.c     |   29 ++++++++-
 drivers/net/wireless/iwlwifi/iwl-core.h     |   14 +++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    5 +-
 drivers/net/wireless/libertas/cfg.c         |    1 +
 drivers/net/wireless/p54/p54pci.c           |    2 -
 include/net/bluetooth/l2cap.h               |    4 +-
 net/bluetooth/l2cap.c                       |   11 ++--
 net/wireless/mlme.c                         |    8 ++-
 16 files changed, 102 insertions(+), 144 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index 8848333..fec0262 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -260,7 +260,7 @@ struct iwl_cfg iwl1000_bgn_cfg = {
 	.shadow_ram_support = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.support_ct_kill_exit = true,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_EXT_LONG_THRESHOLD_DEF,
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index a07310f..6950a78 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -769,22 +769,6 @@ void iwl3945_hw_build_tx_cmd_rate(struct iwl_priv *priv,
 		rts_retry_limit = data_retry_limit;
 	tx_cmd->rts_retry_limit = rts_retry_limit;
 
-	if (ieee80211_is_mgmt(fc)) {
-		switch (fc & cpu_to_le16(IEEE80211_FCTL_STYPE)) {
-		case cpu_to_le16(IEEE80211_STYPE_AUTH):
-		case cpu_to_le16(IEEE80211_STYPE_DEAUTH):
-		case cpu_to_le16(IEEE80211_STYPE_ASSOC_REQ):
-		case cpu_to_le16(IEEE80211_STYPE_REASSOC_REQ):
-			if (tx_flags & TX_CMD_FLG_RTS_MSK) {
-				tx_flags &= ~TX_CMD_FLG_RTS_MSK;
-				tx_flags |= TX_CMD_FLG_CTS_MSK;
-			}
-			break;
-		default:
-			break;
-		}
-	}
-
 	tx_cmd->rate = rate;
 	tx_cmd->tx_flags = tx_flags;
 
@@ -2717,7 +2701,7 @@ static struct iwl_lib_ops iwl3945_lib = {
 static struct iwl_hcmd_utils_ops iwl3945_hcmd_utils = {
 	.get_hcmd_size = iwl3945_get_hcmd_size,
 	.build_addsta_hcmd = iwl3945_build_addsta_hcmd,
-	.rts_tx_cmd_flag = iwlcore_rts_tx_cmd_flag,
+	.tx_cmd_protection = iwlcore_tx_cmd_protection,
 	.request_scan = iwl3945_request_scan,
 };
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index d6531ad..d6da356 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2223,7 +2223,7 @@ static struct iwl_hcmd_utils_ops iwl4965_hcmd_utils = {
 	.build_addsta_hcmd = iwl4965_build_addsta_hcmd,
 	.chain_noise_reset = iwl4965_chain_noise_reset,
 	.gain_computation = iwl4965_gain_computation,
-	.rts_tx_cmd_flag = iwlcore_rts_tx_cmd_flag,
+	.tx_cmd_protection = iwlcore_tx_cmd_protection,
 	.calc_rssi = iwl4965_calc_rssi,
 	.request_scan = iwlagn_request_scan,
 };
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 8093ce2..aacf377 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -506,7 +506,7 @@ struct iwl_cfg iwl5300_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
@@ -537,7 +537,7 @@ struct iwl_cfg iwl5100_bgn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
@@ -597,7 +597,7 @@ struct iwl_cfg iwl5100_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
@@ -628,7 +628,7 @@ struct iwl_cfg iwl5350_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
@@ -659,7 +659,7 @@ struct iwl_cfg iwl5150_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.plcp_delta_threshold = IWL_MAX_PLCP_ERR_LONG_THRESHOLD_DEF,
 	.chain_noise_scale = 1000,
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index 5827052..af4fd50 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -381,7 +381,7 @@ struct iwl_cfg iwl6000g2a_2agn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -489,7 +489,7 @@ struct iwl_cfg iwl6000g2b_2agn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -563,7 +563,7 @@ struct iwl_cfg iwl6000g2b_2bgn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -637,7 +637,7 @@ struct iwl_cfg iwl6000g2b_bgn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -714,7 +714,7 @@ struct iwl_cfg iwl6000i_2agn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -821,7 +821,7 @@ struct iwl_cfg iwl6050_2agn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -859,7 +859,7 @@ struct iwl_cfg iwl6050g2_bgn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
@@ -933,7 +933,7 @@ struct iwl_cfg iwl6000_3agn_cfg = {
 	.shadow_ram_support = true,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
-	.use_rts_for_ht = true, /* use rts/cts protection */
+	.use_rts_for_aggregation = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.supports_idle = true,
 	.adv_thermal_throttle = true,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c b/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
index a7216dd..75b901b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
@@ -211,10 +211,21 @@ static void iwlagn_chain_noise_reset(struct iwl_priv *priv)
 	}
 }
 
-static void iwlagn_rts_tx_cmd_flag(struct ieee80211_tx_info *info,
-			__le32 *tx_flags)
+static void iwlagn_tx_cmd_protection(struct iwl_priv *priv,
+				     struct ieee80211_tx_info *info,
+				     __le16 fc, __le32 *tx_flags)
 {
-	*tx_flags |= TX_CMD_FLG_PROT_REQUIRE_MSK;
+	if (info->control.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS ||
+	    info->control.rates[0].flags & IEEE80211_TX_RC_USE_CTS_PROTECT) {
+		*tx_flags |= TX_CMD_FLG_PROT_REQUIRE_MSK;
+		return;
+	}
+
+	if (priv->cfg->use_rts_for_aggregation &&
+	    info->flags & IEEE80211_TX_CTL_AMPDU) {
+		*tx_flags |= TX_CMD_FLG_PROT_REQUIRE_MSK;
+		return;
+	}
 }
 
 /* Calc max signal level (dBm) among 3 possible receivers */
@@ -268,7 +279,7 @@ struct iwl_hcmd_utils_ops iwlagn_hcmd_utils = {
 	.build_addsta_hcmd = iwlagn_build_addsta_hcmd,
 	.gain_computation = iwlagn_gain_computation,
 	.chain_noise_reset = iwlagn_chain_noise_reset,
-	.rts_tx_cmd_flag = iwlagn_rts_tx_cmd_flag,
+	.tx_cmd_protection = iwlagn_tx_cmd_protection,
 	.calc_rssi = iwlagn_calc_rssi,
 	.request_scan = iwlagn_request_scan,
 };
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
index d04502d..69155aa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -379,10 +379,7 @@ static void iwlagn_tx_cmd_build_basic(struct iwl_priv *priv,
 		tx_flags |= TX_CMD_FLG_SEQ_CTL_MSK;
 	}
 
-	priv->cfg->ops->utils->rts_tx_cmd_flag(info, &tx_flags);
-
-	if ((tx_flags & TX_CMD_FLG_RTS_MSK) || (tx_flags & TX_CMD_FLG_CTS_MSK))
-		tx_flags |= TX_CMD_FLG_FULL_TXOP_PROT_MSK;
+	priv->cfg->ops->utils->tx_cmd_protection(priv, info, fc, &tx_flags);
 
 	tx_flags &= ~(TX_CMD_FLG_ANT_SEL_MSK);
 	if (ieee80211_is_mgmt(fc)) {
@@ -456,21 +453,6 @@ static void iwlagn_tx_cmd_build_rate(struct iwl_priv *priv,
 	if ((rate_idx >= IWL_FIRST_CCK_RATE) && (rate_idx <= IWL_LAST_CCK_RATE))
 		rate_flags |= RATE_MCS_CCK_MSK;
 
-	/* Set up RTS and CTS flags for certain packets */
-	switch (fc & cpu_to_le16(IEEE80211_FCTL_STYPE)) {
-	case cpu_to_le16(IEEE80211_STYPE_AUTH):
-	case cpu_to_le16(IEEE80211_STYPE_DEAUTH):
-	case cpu_to_le16(IEEE80211_STYPE_ASSOC_REQ):
-	case cpu_to_le16(IEEE80211_STYPE_REASSOC_REQ):
-		if (tx_cmd->tx_flags & TX_CMD_FLG_RTS_MSK) {
-			tx_cmd->tx_flags &= ~TX_CMD_FLG_RTS_MSK;
-			tx_cmd->tx_flags |= TX_CMD_FLG_CTS_MSK;
-		}
-		break;
-	default:
-		break;
-	}
-
 	/* Set up antennas */
 	priv->mgmt_tx_ant = iwl_toggle_tx_ant(priv, priv->mgmt_tx_ant,
 					      priv->hw_params.valid_tx_ant);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 35337b1..c1882fd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -202,13 +202,6 @@ int iwl_commit_rxon(struct iwl_priv *priv)
 
 	priv->start_calib = 0;
 	if (new_assoc) {
-		/*
-		 * allow CTS-to-self if possible for new association.
-		 * this is relevant only for 5000 series and up,
-		 * but will not damage 4965
-		 */
-		priv->staging_rxon.flags |= RXON_FLG_SELF_CTS_EN;
-
 		/* Apply the new configuration
 		 * RXON assoc doesn't clear the station table in uCode,
 		 */
@@ -1618,45 +1611,9 @@ static ssize_t store_tx_power(struct device *d,
 
 static DEVICE_ATTR(tx_power, S_IWUSR | S_IRUGO, show_tx_power, store_tx_power);
 
-static ssize_t show_rts_ht_protection(struct device *d,
-			     struct device_attribute *attr, char *buf)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-
-	return sprintf(buf, "%s\n",
-		priv->cfg->use_rts_for_ht ? "RTS/CTS" : "CTS-to-self");
-}
-
-static ssize_t store_rts_ht_protection(struct device *d,
-			      struct device_attribute *attr,
-			      const char *buf, size_t count)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-	unsigned long val;
-	int ret;
-
-	ret = strict_strtoul(buf, 10, &val);
-	if (ret)
-		IWL_INFO(priv, "Input is not in decimal form.\n");
-	else {
-		if (!iwl_is_associated(priv))
-			priv->cfg->use_rts_for_ht = val ? true : false;
-		else
-			IWL_ERR(priv, "Sta associated with AP - "
-				"Change protection mechanism is not allowed\n");
-		ret = count;
-	}
-	return ret;
-}
-
-static DEVICE_ATTR(rts_ht_protection, S_IWUSR | S_IRUGO,
-			show_rts_ht_protection, store_rts_ht_protection);
-
-
 static struct attribute *iwl_sysfs_entries[] = {
 	&dev_attr_temperature.attr,
 	&dev_attr_tx_power.attr,
-	&dev_attr_rts_ht_protection.attr,
 #ifdef CONFIG_IWLWIFI_DEBUG
 	&dev_attr_debug_level.attr,
 #endif
@@ -3464,25 +3421,6 @@ static int iwl_mac_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	return ret;
 }
 
-/*
- * switch to RTS/CTS for TX
- */
-static void iwl_enable_rts_cts(struct iwl_priv *priv)
-{
-
-	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
-		return;
-
-	priv->staging_rxon.flags &= ~RXON_FLG_SELF_CTS_EN;
-	if (!test_bit(STATUS_SCANNING, &priv->status)) {
-		IWL_DEBUG_INFO(priv, "use RTS/CTS protection\n");
-		iwlcore_commit_rxon(priv);
-	} else {
-		/* scanning, defer the request until scan completed */
-		IWL_DEBUG_INFO(priv, "defer setting RTS/CTS protection\n");
-	}
-}
-
 static int iwl_mac_ampdu_action(struct ieee80211_hw *hw,
 				struct ieee80211_vif *vif,
 				enum ieee80211_ampdu_mlme_action action,
@@ -3529,14 +3467,33 @@ static int iwl_mac_ampdu_action(struct ieee80211_hw *hw,
 		}
 		if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 			ret = 0;
+		if (priv->cfg->use_rts_for_aggregation) {
+			struct iwl_station_priv *sta_priv =
+				(void *) sta->drv_priv;
+			/*
+			 * switch off RTS/CTS if it was previously enabled
+			 */
+
+			sta_priv->lq_sta.lq.general_params.flags &=
+				~LINK_QUAL_FLAGS_SET_STA_TLC_RTS_MSK;
+			iwl_send_lq_cmd(priv, &sta_priv->lq_sta.lq,
+				CMD_ASYNC, false);
+		}
 		break;
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
-		if (priv->cfg->use_rts_for_ht) {
+		if (priv->cfg->use_rts_for_aggregation) {
+			struct iwl_station_priv *sta_priv =
+				(void *) sta->drv_priv;
+
 			/*
 			 * switch to RTS/CTS if it is the prefer protection
 			 * method for HT traffic
 			 */
-			iwl_enable_rts_cts(priv);
+
+			sta_priv->lq_sta.lq.general_params.flags |=
+				LINK_QUAL_FLAGS_SET_STA_TLC_RTS_MSK;
+			iwl_send_lq_cmd(priv, &sta_priv->lq_sta.lq,
+				CMD_ASYNC, false);
 		}
 		ret = 0;
 		break;
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 8ccb6d2..2c03c6e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -401,21 +401,38 @@ void iwlcore_free_geos(struct iwl_priv *priv)
 EXPORT_SYMBOL(iwlcore_free_geos);
 
 /*
- *  iwlcore_rts_tx_cmd_flag: Set rts/cts. 3945 and 4965 only share this
+ *  iwlcore_tx_cmd_protection: Set rts/cts. 3945 and 4965 only share this
  *  function.
  */
-void iwlcore_rts_tx_cmd_flag(struct ieee80211_tx_info *info,
-				__le32 *tx_flags)
+void iwlcore_tx_cmd_protection(struct iwl_priv *priv,
+			       struct ieee80211_tx_info *info,
+			       __le16 fc, __le32 *tx_flags)
 {
 	if (info->control.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS) {
 		*tx_flags |= TX_CMD_FLG_RTS_MSK;
 		*tx_flags &= ~TX_CMD_FLG_CTS_MSK;
+		*tx_flags |= TX_CMD_FLG_FULL_TXOP_PROT_MSK;
+
+		if (!ieee80211_is_mgmt(fc))
+			return;
+
+		switch (fc & cpu_to_le16(IEEE80211_FCTL_STYPE)) {
+		case cpu_to_le16(IEEE80211_STYPE_AUTH):
+		case cpu_to_le16(IEEE80211_STYPE_DEAUTH):
+		case cpu_to_le16(IEEE80211_STYPE_ASSOC_REQ):
+		case cpu_to_le16(IEEE80211_STYPE_REASSOC_REQ):
+			*tx_flags &= ~TX_CMD_FLG_RTS_MSK;
+			*tx_flags |= TX_CMD_FLG_CTS_MSK;
+			break;
+		}
 	} else if (info->control.rates[0].flags & IEEE80211_TX_RC_USE_CTS_PROTECT) {
 		*tx_flags &= ~TX_CMD_FLG_RTS_MSK;
 		*tx_flags |= TX_CMD_FLG_CTS_MSK;
+		*tx_flags |= TX_CMD_FLG_FULL_TXOP_PROT_MSK;
 	}
 }
-EXPORT_SYMBOL(iwlcore_rts_tx_cmd_flag);
+EXPORT_SYMBOL(iwlcore_tx_cmd_protection);
+
 
 static bool is_single_rx_stream(struct iwl_priv *priv)
 {
@@ -1869,6 +1886,10 @@ void iwl_bss_info_changed(struct ieee80211_hw *hw,
 			priv->staging_rxon.flags |= RXON_FLG_TGG_PROTECT_MSK;
 		else
 			priv->staging_rxon.flags &= ~RXON_FLG_TGG_PROTECT_MSK;
+		if (bss_conf->use_cts_prot)
+			priv->staging_rxon.flags |= RXON_FLG_SELF_CTS_EN;
+		else
+			priv->staging_rxon.flags &= ~RXON_FLG_SELF_CTS_EN;
 	}
 
 	if (changes & BSS_CHANGED_BASIC_RATES) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index e9d23f2..4a71dfb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -104,8 +104,9 @@ struct iwl_hcmd_utils_ops {
 			u32 min_average_noise,
 			u8 default_chain);
 	void (*chain_noise_reset)(struct iwl_priv *priv);
-	void (*rts_tx_cmd_flag)(struct ieee80211_tx_info *info,
-			__le32 *tx_flags);
+	void (*tx_cmd_protection)(struct iwl_priv *priv,
+				  struct ieee80211_tx_info *info,
+				  __le16 fc, __le32 *tx_flags);
 	int  (*calc_rssi)(struct iwl_priv *priv,
 			  struct iwl_rx_phy_res *rx_resp);
 	void (*request_scan)(struct iwl_priv *priv, struct ieee80211_vif *vif);
@@ -249,7 +250,7 @@ struct iwl_mod_params {
  * @led_compensation: compensate on the led on/off time per HW according
  *	to the deviation to achieve the desired led frequency.
  *	The detail algorithm is described in iwl-led.c
- * @use_rts_for_ht: use rts/cts protection for HT traffic
+ * @use_rts_for_aggregation: use rts/cts protection for HT traffic
  * @chain_noise_num_beacons: number of beacons used to compute chain noise
  * @adv_thermal_throttle: support advance thermal throttle
  * @support_ct_kill_exit: support ct kill exit condition
@@ -318,7 +319,7 @@ struct iwl_cfg {
 	const bool ht_greenfield_support;
 	u16 led_compensation;
 	const bool broken_powersave;
-	bool use_rts_for_ht;
+	bool use_rts_for_aggregation;
 	int chain_noise_num_beacons;
 	const bool supports_idle;
 	bool adv_thermal_throttle;
@@ -390,8 +391,9 @@ void iwl_config_ap(struct iwl_priv *priv, struct ieee80211_vif *vif);
 void iwl_mac_reset_tsf(struct ieee80211_hw *hw);
 int iwl_alloc_txq_mem(struct iwl_priv *priv);
 void iwl_free_txq_mem(struct iwl_priv *priv);
-void iwlcore_rts_tx_cmd_flag(struct ieee80211_tx_info *info,
-				__le32 *tx_flags);
+void iwlcore_tx_cmd_protection(struct iwl_priv *priv,
+			       struct ieee80211_tx_info *info,
+			       __le16 fc, __le32 *tx_flags);
 #ifdef CONFIG_IWLWIFI_DEBUGFS
 int iwl_alloc_traffic_mem(struct iwl_priv *priv);
 void iwl_free_traffic_mem(struct iwl_priv *priv);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index d24eb47..70c4b8f 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -435,10 +435,7 @@ static void iwl3945_build_tx_cmd_basic(struct iwl_priv *priv,
 		tx_flags |= TX_CMD_FLG_SEQ_CTL_MSK;
 	}
 
-	priv->cfg->ops->utils->rts_tx_cmd_flag(info, &tx_flags);
-
-	if ((tx_flags & TX_CMD_FLG_RTS_MSK) || (tx_flags & TX_CMD_FLG_CTS_MSK))
-		tx_flags |= TX_CMD_FLG_FULL_TXOP_PROT_MSK;
+	priv->cfg->ops->utils->tx_cmd_protection(priv, info, fc, &tx_flags);
 
 	tx_flags &= ~(TX_CMD_FLG_ANT_SEL_MSK);
 	if (ieee80211_is_mgmt(fc)) {
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 8e9fbfd..51a96f5 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/slab.h>
+#include <linux/sched.h>
 #include <linux/ieee80211.h>
 #include <net/cfg80211.h>
 #include <asm/unaligned.h>
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 71a101f..822f8dc 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -43,8 +43,6 @@ static DEFINE_PCI_DEVICE_TABLE(p54p_table) = {
 	{ PCI_DEVICE(0x1260, 0x3886) },
 	/* Intersil PRISM Xbow Wireless LAN adapter (Symbol AP-300) */
 	{ PCI_DEVICE(0x1260, 0xffff) },
-	/* Standard Microsystems Corp SMC2802W Wireless PCI */
-	{ PCI_DEVICE(0x10b8, 0x2802) },
 	{ },
 };
 
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 636724b..6c24144 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -33,9 +33,9 @@
 #define L2CAP_DEFAULT_FLUSH_TO		0xffff
 #define L2CAP_DEFAULT_TX_WINDOW		63
 #define L2CAP_DEFAULT_MAX_TX		3
-#define L2CAP_DEFAULT_RETRANS_TO	1000    /* 1 second */
+#define L2CAP_DEFAULT_RETRANS_TO	2000    /* 2 seconds */
 #define L2CAP_DEFAULT_MONITOR_TO	12000   /* 12 seconds */
-#define L2CAP_DEFAULT_MAX_PDU_SIZE	672
+#define L2CAP_DEFAULT_MAX_PDU_SIZE	1009    /* Sized for 3-DH5 packet */
 #define L2CAP_DEFAULT_ACK_TO		200
 #define L2CAP_LOCAL_BUSY_TRIES		12
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 3e3cd9d..fadf26b 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2705,8 +2705,9 @@ done:
 		case L2CAP_MODE_ERTM:
 			pi->remote_tx_win = rfc.txwin_size;
 			pi->remote_max_tx = rfc.max_transmit;
-			if (rfc.max_pdu_size > pi->conn->mtu - 10)
-				rfc.max_pdu_size = le16_to_cpu(pi->conn->mtu - 10);
+
+			if (le16_to_cpu(rfc.max_pdu_size) > pi->conn->mtu - 10)
+				rfc.max_pdu_size = cpu_to_le16(pi->conn->mtu - 10);
 
 			pi->remote_mps = le16_to_cpu(rfc.max_pdu_size);
 
@@ -2723,8 +2724,8 @@ done:
 			break;
 
 		case L2CAP_MODE_STREAMING:
-			if (rfc.max_pdu_size > pi->conn->mtu - 10)
-				rfc.max_pdu_size = le16_to_cpu(pi->conn->mtu - 10);
+			if (le16_to_cpu(rfc.max_pdu_size) > pi->conn->mtu - 10)
+				rfc.max_pdu_size = cpu_to_le16(pi->conn->mtu - 10);
 
 			pi->remote_mps = le16_to_cpu(rfc.max_pdu_size);
 
@@ -2806,7 +2807,6 @@ static int l2cap_parse_conf_rsp(struct sock *sk, void *rsp, int len, void *data,
 	if (*result == L2CAP_CONF_SUCCESS) {
 		switch (rfc.mode) {
 		case L2CAP_MODE_ERTM:
-			pi->remote_tx_win   = rfc.txwin_size;
 			pi->retrans_timeout = le16_to_cpu(rfc.retrans_timeout);
 			pi->monitor_timeout = le16_to_cpu(rfc.monitor_timeout);
 			pi->mps    = le16_to_cpu(rfc.max_pdu_size);
@@ -2862,7 +2862,6 @@ static void l2cap_conf_rfc_get(struct sock *sk, void *rsp, int len)
 done:
 	switch (rfc.mode) {
 	case L2CAP_MODE_ERTM:
-		pi->remote_tx_win   = rfc.txwin_size;
 		pi->retrans_timeout = le16_to_cpu(rfc.retrans_timeout);
 		pi->monitor_timeout = le16_to_cpu(rfc.monitor_timeout);
 		pi->mps    = le16_to_cpu(rfc.max_pdu_size);
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index e74a1a2..d1a3fb9 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -843,13 +843,19 @@ int cfg80211_mlme_action(struct cfg80211_registered_device *rdev,
 		return -EINVAL;
 	if (mgmt->u.action.category != WLAN_CATEGORY_PUBLIC) {
 		/* Verify that we are associated with the destination AP */
+		wdev_lock(wdev);
+
 		if (!wdev->current_bss ||
 		    memcmp(wdev->current_bss->pub.bssid, mgmt->bssid,
 			   ETH_ALEN) != 0 ||
 		    (wdev->iftype == NL80211_IFTYPE_STATION &&
 		     memcmp(wdev->current_bss->pub.bssid, mgmt->da,
-			    ETH_ALEN) != 0))
+			    ETH_ALEN) != 0)) {
+			wdev_unlock(wdev);
 			return -ENOTCONN;
+		}
+
+		wdev_unlock(wdev);
 	}
 
 	if (memcmp(mgmt->sa, dev->dev_addr, ETH_ALEN) != 0)
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
