From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-06-06
Date: Wed, 6 Jun 2012 14:36:13 -0400
Message-ID: <20120606183613.GD2338@tuxdriver.com>
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

Here is a batch of wireless/bluetooth fixes intended for 3.5...

Amitkumar Karwar gives us a cfg80211 fix that changes some state
tracking in order to avoid a WARNING.

Arik Nemtsov provide a mac80211 fix for an RCU-related race.

Avinash Patil shares a pair of mwifiex fixes, one which invalidates
some stale configuration data before a channel change and another to
restrict hidden SSID support to zero-length SSIDs only.

Chun-Yeow Yeoh brings a mac80211 fix for a mesh problem triggered
when combining multiple mesh networks into one.

Felix Fietkau provides a mac80211 lockdep fix.

Joe Perches fixes a couple of thinkos related to bitwise operations.

Johannes Berg comes through with a flurry of fixes.  The iwlwifi ones
address a problem Linus recently reported, and some of the fallout
discovered while fixing it.  The mac80211 fix properly cleans-up
remain-on-channel work on an interface that is stopped.  The others
are clean-ups for regressions caused by stricter checking of possible
virtual interfaces supported by wireless drivers.

Meenakshi Venkataraman provides a mac80211 fix for an off-by-one error.

Seth Forshee provides a fix to make the wireless adapters used in
some Mac boxes work after being in S3 power saving state.

Stanislaw Gruszka offers a copule of fixes, a fix for a mac80211
scanning regression and an rt2x00 fix to avoid some lockdep spew.

Last but not least, Vinicius Costa Gomes provides a bluetooth fix
for a typo that "was preventing important features of Bluetooth
from working".

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit dd03cff23d694cfb0fdae80cb618e7ced05ea696:

  net: sierra_net: device IDs for Aircard 320U++ (2012-06-06 10:40:32 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Amitkumar Karwar (1):
      cfg80211: use sme_state in ibss start/join path

Arik Nemtsov (1):
      mac80211: fix non RCU-safe sta_list manipulation

Avinash Patil (2):
      mwifiex: invalidate bss config before setting channel for uAP
      mwifiex: support NL80211_HIDDEN_SSID_ZERO_LEN for uAP

Chun-Yeow Yeoh (1):
      mac80211: Fix Unreachable Mesh Station Problem when joining to another MBSS

Felix Fietkau (1):
      mac80211: add missing rcu_read_lock/unlock in agg-rx session timer

Joe Perches (2):
      mac80211: Fix likely misuse of | for &
      brcmfmac: Fix likely misuse of | for &

Johannes Berg (7):
      iwlwifi: fix TX power antenna access
      mac80211_hwsim: advertise interface combinations
      mac80211: clean up remain-on-channel on interface stop
      iwlwifi: disable WoWLAN if !CONFIG_PM_SLEEP
      iwlwifi: fix double free/complete in firmware loading
      iwlwifi: unregister LEDs if mac80211 registration fails
      cfg80211: fix interface combinations check

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Meenakshi Venkataraman (1):
      mac80211: fix error in station state transitions during reconfig

Seth Forshee (1):
      bcma: add ext PA workaround for BCM4331 and BCM43431

Stanislaw Gruszka (2):
      mac80211: run scan after finish connection monitoring
      rt2x00: use atomic variable for seqno

Vinicius Costa Gomes (1):
      Bluetooth: Fix checking the wrong flag when accepting a socket

 drivers/bcma/driver_chipcommon_pmu.c             |    4 ++-
 drivers/bcma/sprom.c                             |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c           |    9 ++++-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c        |   18 +++++-----
 drivers/net/wireless/iwlwifi/iwl-mac80211.c      |    3 ++
 drivers/net/wireless/mac80211_hwsim.c            |   21 +++++++++++++
 drivers/net/wireless/mwifiex/cfg80211.c          |   13 ++++++++
 drivers/net/wireless/mwifiex/fw.h                |    6 ++++
 drivers/net/wireless/mwifiex/uap_cmd.c           |   10 ++++++
 drivers/net/wireless/rt2x00/rt2x00.h             |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |    1 -
 drivers/net/wireless/rt2x00/rt2x00queue.c        |   13 ++++----
 net/bluetooth/af_bluetooth.c                     |    2 +-
 net/mac80211/agg-rx.c                            |    7 ++++-
 net/mac80211/cfg.c                               |    6 ++--
 net/mac80211/iface.c                             |   12 +++++++
 net/mac80211/mlme.c                              |   36 ++++++++++++++++-----
 net/mac80211/offchannel.c                        |   16 ++++++++++
 net/mac80211/sta_info.c                          |    4 +-
 net/mac80211/tx.c                                |    9 ++++--
 net/mac80211/util.c                              |    2 +-
 net/wireless/ibss.c                              |    6 +++-
 net/wireless/util.c                              |   19 +++++++++++-
 24 files changed, 180 insertions(+), 48 deletions(-)

diff --git a/drivers/bcma/driver_chipcommon_pmu.c b/drivers/bcma/driver_chipcommon_pmu.c
index a058842..61ce405 100644
--- a/drivers/bcma/driver_chipcommon_pmu.c
+++ b/drivers/bcma/driver_chipcommon_pmu.c
@@ -139,7 +139,9 @@ void bcma_pmu_workarounds(struct bcma_drv_cc *cc)
 		bcma_chipco_chipctl_maskset(cc, 0, ~0, 0x7);
 		break;
 	case 0x4331:
-		/* BCM4331 workaround is SPROM-related, we put it in sprom.c */
+	case 43431:
+		/* Ext PA lines must be enabled for tx on BCM4331 */
+		bcma_chipco_bcm4331_ext_pa_lines_ctl(cc, true);
 		break;
 	case 43224:
 		if (bus->chipinfo.rev == 0) {
diff --git a/drivers/bcma/sprom.c b/drivers/bcma/sprom.c
index c7f9335..f16f42d 100644
--- a/drivers/bcma/sprom.c
+++ b/drivers/bcma/sprom.c
@@ -579,13 +579,13 @@ int bcma_sprom_get(struct bcma_bus *bus)
 	if (!sprom)
 		return -ENOMEM;
 
-	if (bus->chipinfo.id == 0x4331)
+	if (bus->chipinfo.id == 0x4331 || bus->chipinfo.id == 43431)
 		bcma_chipco_bcm4331_ext_pa_lines_ctl(&bus->drv_cc, false);
 
 	pr_debug("SPROM offset 0x%x\n", offset);
 	bcma_sprom_read(bus, offset, sprom);
 
-	if (bus->chipinfo.id == 0x4331)
+	if (bus->chipinfo.id == 0x4331 || bus->chipinfo.id == 43431)
 		bcma_chipco_bcm4331_ext_pa_lines_ctl(&bus->drv_cc, true);
 
 	err = bcma_sprom_valid(sprom);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index e2480d1..8e7e692 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -89,9 +89,9 @@ int brcmf_sdio_intr_register(struct brcmf_sdio_dev *sdiodev)
 	data |= 1 << SDIO_FUNC_1 | 1 << SDIO_FUNC_2 | 1;
 	brcmf_sdio_regwb(sdiodev, SDIO_CCCR_IENx, data, &ret);
 
-	/* redirect, configure ane enable io for interrupt signal */
+	/* redirect, configure and enable io for interrupt signal */
 	data = SDIO_SEPINT_MASK | SDIO_SEPINT_OE;
-	if (sdiodev->irq_flags | IRQF_TRIGGER_HIGH)
+	if (sdiodev->irq_flags & IRQF_TRIGGER_HIGH)
 		data |= SDIO_SEPINT_ACT_HI;
 	brcmf_sdio_regwb(sdiodev, SDIO_CCCR_BRCM_SEPINT, data, &ret);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-drv.c b/drivers/net/wireless/iwlwifi/iwl-drv.c
index d742900..fac67a5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/iwlwifi/iwl-drv.c
@@ -861,13 +861,18 @@ static void iwl_ucode_callback(const struct firmware *ucode_raw, void *context)
 
 	/* We have our copies now, allow OS release its copies */
 	release_firmware(ucode_raw);
-	complete(&drv->request_firmware_complete);
 
 	drv->op_mode = iwl_dvm_ops.start(drv->trans, drv->cfg, &drv->fw);
 
 	if (!drv->op_mode)
-		goto out_free_fw;
+		goto out_unbind;
 
+	/*
+	 * Complete the firmware request last so that
+	 * a driver unbind (stop) doesn't run while we
+	 * are doing the start() above.
+	 */
+	complete(&drv->request_firmware_complete);
 	return;
 
  try_again:
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.c b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
index 50c5891..b8e2b22 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.c
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
@@ -568,28 +568,28 @@ static int iwl_find_otp_image(struct iwl_trans *trans,
  * iwl_get_max_txpower_avg - get the highest tx power from all chains.
  *     find the highest tx power from all chains for the channel
  */
-static s8 iwl_get_max_txpower_avg(const struct iwl_cfg *cfg,
+static s8 iwl_get_max_txpower_avg(struct iwl_priv *priv,
 		struct iwl_eeprom_enhanced_txpwr *enhanced_txpower,
 		int element, s8 *max_txpower_in_half_dbm)
 {
 	s8 max_txpower_avg = 0; /* (dBm) */
 
 	/* Take the highest tx power from any valid chains */
-	if ((cfg->valid_tx_ant & ANT_A) &&
+	if ((priv->hw_params.valid_tx_ant & ANT_A) &&
 	    (enhanced_txpower[element].chain_a_max > max_txpower_avg))
 		max_txpower_avg = enhanced_txpower[element].chain_a_max;
-	if ((cfg->valid_tx_ant & ANT_B) &&
+	if ((priv->hw_params.valid_tx_ant & ANT_B) &&
 	    (enhanced_txpower[element].chain_b_max > max_txpower_avg))
 		max_txpower_avg = enhanced_txpower[element].chain_b_max;
-	if ((cfg->valid_tx_ant & ANT_C) &&
+	if ((priv->hw_params.valid_tx_ant & ANT_C) &&
 	    (enhanced_txpower[element].chain_c_max > max_txpower_avg))
 		max_txpower_avg = enhanced_txpower[element].chain_c_max;
-	if (((cfg->valid_tx_ant == ANT_AB) |
-	    (cfg->valid_tx_ant == ANT_BC) |
-	    (cfg->valid_tx_ant == ANT_AC)) &&
+	if (((priv->hw_params.valid_tx_ant == ANT_AB) |
+	    (priv->hw_params.valid_tx_ant == ANT_BC) |
+	    (priv->hw_params.valid_tx_ant == ANT_AC)) &&
 	    (enhanced_txpower[element].mimo2_max > max_txpower_avg))
 		max_txpower_avg =  enhanced_txpower[element].mimo2_max;
-	if ((cfg->valid_tx_ant == ANT_ABC) &&
+	if ((priv->hw_params.valid_tx_ant == ANT_ABC) &&
 	    (enhanced_txpower[element].mimo3_max > max_txpower_avg))
 		max_txpower_avg = enhanced_txpower[element].mimo3_max;
 
@@ -691,7 +691,7 @@ static void iwl_eeprom_enhanced_txpower(struct iwl_priv *priv)
 				 ((txp->delta_20_in_40 & 0xf0) >> 4),
 				 (txp->delta_20_in_40 & 0x0f));
 
-		max_txp_avg = iwl_get_max_txpower_avg(priv->cfg, txp_array, idx,
+		max_txp_avg = iwl_get_max_txpower_avg(priv, txp_array, idx,
 						      &max_txp_avg_halfdbm);
 
 		/*
diff --git a/drivers/net/wireless/iwlwifi/iwl-mac80211.c b/drivers/net/wireless/iwlwifi/iwl-mac80211.c
index ab2f4d7..3ee23134 100644
--- a/drivers/net/wireless/iwlwifi/iwl-mac80211.c
+++ b/drivers/net/wireless/iwlwifi/iwl-mac80211.c
@@ -199,6 +199,7 @@ int iwlagn_mac_setup_register(struct iwl_priv *priv,
 			    WIPHY_FLAG_DISABLE_BEACON_HINTS |
 			    WIPHY_FLAG_IBSS_RSN;
 
+#ifdef CONFIG_PM_SLEEP
 	if (priv->fw->img[IWL_UCODE_WOWLAN].sec[0].len &&
 	    priv->trans->ops->wowlan_suspend &&
 	    device_can_wakeup(priv->trans->dev)) {
@@ -217,6 +218,7 @@ int iwlagn_mac_setup_register(struct iwl_priv *priv,
 		hw->wiphy->wowlan.pattern_max_len =
 					IWLAGN_WOWLAN_MAX_PATTERN_LEN;
 	}
+#endif
 
 	if (iwlwifi_mod_params.power_save)
 		hw->wiphy->flags |= WIPHY_FLAG_PS_ON_BY_DEFAULT;
@@ -249,6 +251,7 @@ int iwlagn_mac_setup_register(struct iwl_priv *priv,
 	ret = ieee80211_register_hw(priv->hw);
 	if (ret) {
 		IWL_ERR(priv, "Failed to register hw (error %d)\n", ret);
+		iwl_leds_exit(priv);
 		return ret;
 	}
 	priv->mac80211_registered = 1;
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index fb787df..4c9336c 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1721,6 +1721,24 @@ static void hwsim_exit_netlink(void)
 		       "unregister family %i\n", ret);
 }
 
+static const struct ieee80211_iface_limit hwsim_if_limits[] = {
+	{ .max = 1, .types = BIT(NL80211_IFTYPE_ADHOC) },
+	{ .max = 2048,  .types = BIT(NL80211_IFTYPE_STATION) |
+				 BIT(NL80211_IFTYPE_P2P_CLIENT) |
+#ifdef CONFIG_MAC80211_MESH
+				 BIT(NL80211_IFTYPE_MESH_POINT) |
+#endif
+				 BIT(NL80211_IFTYPE_AP) |
+				 BIT(NL80211_IFTYPE_P2P_GO) },
+};
+
+static const struct ieee80211_iface_combination hwsim_if_comb = {
+	.limits = hwsim_if_limits,
+	.n_limits = ARRAY_SIZE(hwsim_if_limits),
+	.max_interfaces = 2048,
+	.num_different_channels = 1,
+};
+
 static int __init init_mac80211_hwsim(void)
 {
 	int i, err = 0;
@@ -1782,6 +1800,9 @@ static int __init init_mac80211_hwsim(void)
 		hw->wiphy->n_addresses = 2;
 		hw->wiphy->addresses = data->addresses;
 
+		hw->wiphy->iface_combinations = &hwsim_if_comb;
+		hw->wiphy->n_iface_combinations = 1;
+
 		if (fake_hw_scan) {
 			hw->wiphy->max_scan_ssids = 255;
 			hw->wiphy->max_scan_ie_len = IEEE80211_MAX_DATA_LEN;
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 8767144..015fec3 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -948,6 +948,19 @@ static int mwifiex_cfg80211_start_ap(struct wiphy *wiphy,
 		bss_cfg->ssid.ssid_len = params->ssid_len;
 	}
 
+	switch (params->hidden_ssid) {
+	case NL80211_HIDDEN_SSID_NOT_IN_USE:
+		bss_cfg->bcast_ssid_ctl = 1;
+		break;
+	case NL80211_HIDDEN_SSID_ZERO_LEN:
+		bss_cfg->bcast_ssid_ctl = 0;
+		break;
+	case NL80211_HIDDEN_SSID_ZERO_CONTENTS:
+		/* firmware doesn't support this type of hidden SSID */
+	default:
+		return -EINVAL;
+	}
+
 	if (mwifiex_set_secure_params(priv, bss_cfg, params)) {
 		kfree(bss_cfg);
 		wiphy_err(wiphy, "Failed to parse secuirty parameters!\n");
diff --git a/drivers/net/wireless/mwifiex/fw.h b/drivers/net/wireless/mwifiex/fw.h
index 9f674bb..561452a 100644
--- a/drivers/net/wireless/mwifiex/fw.h
+++ b/drivers/net/wireless/mwifiex/fw.h
@@ -122,6 +122,7 @@ enum MWIFIEX_802_11_PRIVACY_FILTER {
 #define TLV_TYPE_CHANNELBANDLIST    (PROPRIETARY_TLV_BASE_ID + 42)
 #define TLV_TYPE_UAP_BEACON_PERIOD  (PROPRIETARY_TLV_BASE_ID + 44)
 #define TLV_TYPE_UAP_DTIM_PERIOD    (PROPRIETARY_TLV_BASE_ID + 45)
+#define TLV_TYPE_UAP_BCAST_SSID     (PROPRIETARY_TLV_BASE_ID + 48)
 #define TLV_TYPE_UAP_RTS_THRESHOLD  (PROPRIETARY_TLV_BASE_ID + 51)
 #define TLV_TYPE_UAP_WPA_PASSPHRASE (PROPRIETARY_TLV_BASE_ID + 60)
 #define TLV_TYPE_UAP_ENCRY_PROTOCOL (PROPRIETARY_TLV_BASE_ID + 64)
@@ -1209,6 +1210,11 @@ struct host_cmd_tlv_ssid {
 	u8 ssid[0];
 } __packed;
 
+struct host_cmd_tlv_bcast_ssid {
+	struct host_cmd_tlv tlv;
+	u8 bcast_ctl;
+} __packed;
+
 struct host_cmd_tlv_beacon_period {
 	struct host_cmd_tlv tlv;
 	__le16 period;
diff --git a/drivers/net/wireless/mwifiex/uap_cmd.c b/drivers/net/wireless/mwifiex/uap_cmd.c
index 76dfbc4..8173ab6 100644
--- a/drivers/net/wireless/mwifiex/uap_cmd.c
+++ b/drivers/net/wireless/mwifiex/uap_cmd.c
@@ -132,6 +132,7 @@ mwifiex_uap_bss_param_prepare(u8 *tlv, void *cmd_buf, u16 *param_size)
 	struct host_cmd_tlv_dtim_period *dtim_period;
 	struct host_cmd_tlv_beacon_period *beacon_period;
 	struct host_cmd_tlv_ssid *ssid;
+	struct host_cmd_tlv_bcast_ssid *bcast_ssid;
 	struct host_cmd_tlv_channel_band *chan_band;
 	struct host_cmd_tlv_frag_threshold *frag_threshold;
 	struct host_cmd_tlv_rts_threshold *rts_threshold;
@@ -153,6 +154,14 @@ mwifiex_uap_bss_param_prepare(u8 *tlv, void *cmd_buf, u16 *param_size)
 		cmd_size += sizeof(struct host_cmd_tlv) +
 			    bss_cfg->ssid.ssid_len;
 		tlv += sizeof(struct host_cmd_tlv) + bss_cfg->ssid.ssid_len;
+
+		bcast_ssid = (struct host_cmd_tlv_bcast_ssid *)tlv;
+		bcast_ssid->tlv.type = cpu_to_le16(TLV_TYPE_UAP_BCAST_SSID);
+		bcast_ssid->tlv.len =
+				cpu_to_le16(sizeof(bcast_ssid->bcast_ctl));
+		bcast_ssid->bcast_ctl = bss_cfg->bcast_ssid_ctl;
+		cmd_size += sizeof(struct host_cmd_tlv_bcast_ssid);
+		tlv += sizeof(struct host_cmd_tlv_bcast_ssid);
 	}
 	if (bss_cfg->channel && bss_cfg->channel <= MAX_CHANNEL_BAND_BG) {
 		chan_band = (struct host_cmd_tlv_channel_band *)tlv;
@@ -416,6 +425,7 @@ int mwifiex_uap_set_channel(struct mwifiex_private *priv, int channel)
 	if (!bss_cfg)
 		return -ENOMEM;
 
+	mwifiex_set_sys_config_invalid_data(bss_cfg);
 	bss_cfg->band_cfg = BAND_CONFIG_MANUAL;
 	bss_cfg->channel = channel;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index ca36ccc..8f75402 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -396,8 +396,7 @@ struct rt2x00_intf {
 	 * for hardware which doesn't support hardware
 	 * sequence counting.
 	 */
-	spinlock_t seqlock;
-	u16 seqno;
+	atomic_t seqno;
 };
 
 static inline struct rt2x00_intf* vif_to_intf(struct ieee80211_vif *vif)
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index b49773e..dd24b26 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -277,7 +277,6 @@ int rt2x00mac_add_interface(struct ieee80211_hw *hw,
 	else
 		rt2x00dev->intf_sta_count++;
 
-	spin_lock_init(&intf->seqlock);
 	mutex_init(&intf->beacon_skb_mutex);
 	intf->beacon = entry;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 4c662ec..2fd8301 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -207,6 +207,7 @@ static void rt2x00queue_create_tx_descriptor_seq(struct rt2x00_dev *rt2x00dev,
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct rt2x00_intf *intf = vif_to_intf(tx_info->control.vif);
+	u16 seqno;
 
 	if (!(tx_info->flags & IEEE80211_TX_CTL_ASSIGN_SEQ))
 		return;
@@ -238,15 +239,13 @@ static void rt2x00queue_create_tx_descriptor_seq(struct rt2x00_dev *rt2x00dev,
 	 * sequence counting per-frame, since those will override the
 	 * sequence counter given by mac80211.
 	 */
-	spin_lock(&intf->seqlock);
-
 	if (test_bit(ENTRY_TXD_FIRST_FRAGMENT, &txdesc->flags))
-		intf->seqno += 0x10;
-	hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
-	hdr->seq_ctrl |= cpu_to_le16(intf->seqno);
-
-	spin_unlock(&intf->seqlock);
+		seqno = atomic_add_return(0x10, &intf->seqno);
+	else
+		seqno = atomic_read(&intf->seqno);
 
+	hdr->seq_ctrl &= cpu_to_le16(IEEE80211_SCTL_FRAG);
+	hdr->seq_ctrl |= cpu_to_le16(seqno);
 }
 
 static void rt2x00queue_create_tx_descriptor_plcp(struct rt2x00_dev *rt2x00dev,
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 46e7f86..3e18af4 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -210,7 +210,7 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock)
 		}
 
 		if (sk->sk_state == BT_CONNECTED || !newsock ||
-		    test_bit(BT_DEFER_SETUP, &bt_sk(parent)->flags)) {
+		    test_bit(BT_SK_DEFER_SETUP, &bt_sk(parent)->flags)) {
 			bt_accept_unlink(sk);
 			if (newsock)
 				sock_graft(sk, newsock);
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index 26ddb69..c649188 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -145,15 +145,20 @@ static void sta_rx_agg_session_timer_expired(unsigned long data)
 	struct tid_ampdu_rx *tid_rx;
 	unsigned long timeout;
 
+	rcu_read_lock();
 	tid_rx = rcu_dereference(sta->ampdu_mlme.tid_rx[*ptid]);
-	if (!tid_rx)
+	if (!tid_rx) {
+		rcu_read_unlock();
 		return;
+	}
 
 	timeout = tid_rx->last_rx + TU_TO_JIFFIES(tid_rx->timeout);
 	if (time_is_after_jiffies(timeout)) {
 		mod_timer(&tid_rx->session_timer, timeout);
+		rcu_read_unlock();
 		return;
 	}
+	rcu_read_unlock();
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
 	printk(KERN_DEBUG "rx session timer expired on tid %d\n", (u16)*ptid);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 495831e..e9cecca 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -533,16 +533,16 @@ static void ieee80211_get_et_stats(struct wiphy *wiphy,
 		sinfo.filled = 0;
 		sta_set_sinfo(sta, &sinfo);
 
-		if (sinfo.filled | STATION_INFO_TX_BITRATE)
+		if (sinfo.filled & STATION_INFO_TX_BITRATE)
 			data[i] = 100000 *
 				cfg80211_calculate_bitrate(&sinfo.txrate);
 		i++;
-		if (sinfo.filled | STATION_INFO_RX_BITRATE)
+		if (sinfo.filled & STATION_INFO_RX_BITRATE)
 			data[i] = 100000 *
 				cfg80211_calculate_bitrate(&sinfo.rxrate);
 		i++;
 
-		if (sinfo.filled | STATION_INFO_SIGNAL_AVG)
+		if (sinfo.filled & STATION_INFO_SIGNAL_AVG)
 			data[i] = (u8)sinfo.signal_avg;
 		i++;
 	} else {
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index d4c19a7..8664111 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -637,6 +637,18 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 		ieee80211_configure_filter(local);
 		break;
 	default:
+		mutex_lock(&local->mtx);
+		if (local->hw_roc_dev == sdata->dev &&
+		    local->hw_roc_channel) {
+			/* ignore return value since this is racy */
+			drv_cancel_remain_on_channel(local);
+			ieee80211_queue_work(&local->hw, &local->hw_roc_done);
+		}
+		mutex_unlock(&local->mtx);
+
+		flush_work(&local->hw_roc_start);
+		flush_work(&local->hw_roc_done);
+
 		flush_work(&sdata->work);
 		/*
 		 * When we get here, the interface is marked down.
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 04c3063..d94627c 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1220,6 +1220,22 @@ static void ieee80211_sta_wmm_params(struct ieee80211_local *local,
 	sdata->vif.bss_conf.qos = true;
 }
 
+static void __ieee80211_stop_poll(struct ieee80211_sub_if_data *sdata)
+{
+	lockdep_assert_held(&sdata->local->mtx);
+
+	sdata->u.mgd.flags &= ~(IEEE80211_STA_CONNECTION_POLL |
+				IEEE80211_STA_BEACON_POLL);
+	ieee80211_run_deferred_scan(sdata->local);
+}
+
+static void ieee80211_stop_poll(struct ieee80211_sub_if_data *sdata)
+{
+	mutex_lock(&sdata->local->mtx);
+	__ieee80211_stop_poll(sdata);
+	mutex_unlock(&sdata->local->mtx);
+}
+
 static u32 ieee80211_handle_bss_capability(struct ieee80211_sub_if_data *sdata,
 					   u16 capab, bool erp_valid, u8 erp)
 {
@@ -1285,8 +1301,7 @@ static void ieee80211_set_associated(struct ieee80211_sub_if_data *sdata,
 	sdata->u.mgd.flags |= IEEE80211_STA_RESET_SIGNAL_AVE;
 
 	/* just to be sure */
-	sdata->u.mgd.flags &= ~(IEEE80211_STA_CONNECTION_POLL |
-				IEEE80211_STA_BEACON_POLL);
+	ieee80211_stop_poll(sdata);
 
 	ieee80211_led_assoc(local, 1);
 
@@ -1456,8 +1471,7 @@ static void ieee80211_reset_ap_probe(struct ieee80211_sub_if_data *sdata)
 		return;
 	}
 
-	ifmgd->flags &= ~(IEEE80211_STA_CONNECTION_POLL |
-			  IEEE80211_STA_BEACON_POLL);
+	__ieee80211_stop_poll(sdata);
 
 	mutex_lock(&local->iflist_mtx);
 	ieee80211_recalc_ps(local, -1);
@@ -1477,7 +1491,6 @@ static void ieee80211_reset_ap_probe(struct ieee80211_sub_if_data *sdata)
 		  round_jiffies_up(jiffies +
 				   IEEE80211_CONNECTION_IDLE_TIME));
 out:
-	ieee80211_run_deferred_scan(local);
 	mutex_unlock(&local->mtx);
 }
 
@@ -2408,7 +2421,11 @@ static void ieee80211_rx_mgmt_beacon(struct ieee80211_sub_if_data *sdata,
 		net_dbg_ratelimited("%s: cancelling probereq poll due to a received beacon\n",
 				    sdata->name);
 #endif
+		mutex_lock(&local->mtx);
 		ifmgd->flags &= ~IEEE80211_STA_BEACON_POLL;
+		ieee80211_run_deferred_scan(local);
+		mutex_unlock(&local->mtx);
+
 		mutex_lock(&local->iflist_mtx);
 		ieee80211_recalc_ps(local, -1);
 		mutex_unlock(&local->iflist_mtx);
@@ -2595,8 +2612,7 @@ static void ieee80211_sta_connection_lost(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
 	u8 frame_buf[DEAUTH_DISASSOC_LEN];
 
-	ifmgd->flags &= ~(IEEE80211_STA_CONNECTION_POLL |
-			  IEEE80211_STA_BEACON_POLL);
+	ieee80211_stop_poll(sdata);
 
 	ieee80211_set_disassoc(sdata, IEEE80211_STYPE_DEAUTH, reason,
 			       false, frame_buf);
@@ -2874,8 +2890,7 @@ static void ieee80211_restart_sta_timer(struct ieee80211_sub_if_data *sdata)
 	u32 flags;
 
 	if (sdata->vif.type == NL80211_IFTYPE_STATION) {
-		sdata->u.mgd.flags &= ~(IEEE80211_STA_BEACON_POLL |
-					IEEE80211_STA_CONNECTION_POLL);
+		__ieee80211_stop_poll(sdata);
 
 		/* let's probe the connection once */
 		flags = sdata->local->hw.flags;
@@ -2944,7 +2959,10 @@ void ieee80211_sta_restart(struct ieee80211_sub_if_data *sdata)
 	if (test_and_clear_bit(TMR_RUNNING_CHANSW, &ifmgd->timers_running))
 		add_timer(&ifmgd->chswitch_timer);
 	ieee80211_sta_reset_beacon_monitor(sdata);
+
+	mutex_lock(&sdata->local->mtx);
 	ieee80211_restart_sta_timer(sdata);
+	mutex_unlock(&sdata->local->mtx);
 }
 #endif
 
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index f054e94..935aa4b 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -234,6 +234,22 @@ static void ieee80211_hw_roc_done(struct work_struct *work)
 		return;
 	}
 
+	/* was never transmitted */
+	if (local->hw_roc_skb) {
+		u64 cookie;
+
+		cookie = local->hw_roc_cookie ^ 2;
+
+		cfg80211_mgmt_tx_status(local->hw_roc_dev, cookie,
+					local->hw_roc_skb->data,
+					local->hw_roc_skb->len, false,
+					GFP_KERNEL);
+
+		kfree_skb(local->hw_roc_skb);
+		local->hw_roc_skb = NULL;
+		local->hw_roc_skb_for_status = NULL;
+	}
+
 	if (!local->hw_roc_for_tx)
 		cfg80211_remain_on_channel_expired(local->hw_roc_dev,
 						   local->hw_roc_cookie,
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index f5b1638..de455f8 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -378,7 +378,7 @@ static int sta_info_insert_finish(struct sta_info *sta) __acquires(RCU)
 	/* make the station visible */
 	sta_info_hash_add(local, sta);
 
-	list_add(&sta->list, &local->sta_list);
+	list_add_rcu(&sta->list, &local->sta_list);
 
 	set_sta_flag(sta, WLAN_STA_INSERTED);
 
@@ -688,7 +688,7 @@ int __must_check __sta_info_destroy(struct sta_info *sta)
 	if (ret)
 		return ret;
 
-	list_del(&sta->list);
+	list_del_rcu(&sta->list);
 
 	mutex_lock(&local->key_mtx);
 	for (i = 0; i < NUM_DEFAULT_KEYS; i++)
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 847215b..e453212 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1737,7 +1737,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	__le16 fc;
 	struct ieee80211_hdr hdr;
 	struct ieee80211s_hdr mesh_hdr __maybe_unused;
-	struct mesh_path __maybe_unused *mppath = NULL;
+	struct mesh_path __maybe_unused *mppath = NULL, *mpath = NULL;
 	const u8 *encaps_data;
 	int encaps_len, skip_header_bytes;
 	int nh_pos, h_pos;
@@ -1803,8 +1803,11 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 			goto fail;
 		}
 		rcu_read_lock();
-		if (!is_multicast_ether_addr(skb->data))
-			mppath = mpp_path_lookup(skb->data, sdata);
+		if (!is_multicast_ether_addr(skb->data)) {
+			mpath = mesh_path_lookup(skb->data, sdata);
+			if (!mpath)
+				mppath = mpp_path_lookup(skb->data, sdata);
+		}
 
 		/*
 		 * Use address extension if it is a packet from
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index a44c680..8dd4712 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1271,7 +1271,7 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 			enum ieee80211_sta_state state;
 
 			for (state = IEEE80211_STA_NOTEXIST;
-			     state < sta->sta_state - 1; state++)
+			     state < sta->sta_state; state++)
 				WARN_ON(drv_sta_state(local, sta->sdata, sta,
 						      state, state + 1));
 		}
diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index d2a19b0..89baa33 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -42,6 +42,7 @@ void __cfg80211_ibss_joined(struct net_device *dev, const u8 *bssid)
 	cfg80211_hold_bss(bss_from_pub(bss));
 	wdev->current_bss = bss_from_pub(bss);
 
+	wdev->sme_state = CFG80211_SME_CONNECTED;
 	cfg80211_upload_connect_keys(wdev);
 
 	nl80211_send_ibss_bssid(wiphy_to_dev(wdev->wiphy), dev, bssid,
@@ -60,7 +61,7 @@ void cfg80211_ibss_joined(struct net_device *dev, const u8 *bssid, gfp_t gfp)
 	struct cfg80211_event *ev;
 	unsigned long flags;
 
-	CFG80211_DEV_WARN_ON(!wdev->ssid_len);
+	CFG80211_DEV_WARN_ON(wdev->sme_state != CFG80211_SME_CONNECTING);
 
 	ev = kzalloc(sizeof(*ev), gfp);
 	if (!ev)
@@ -115,9 +116,11 @@ int __cfg80211_join_ibss(struct cfg80211_registered_device *rdev,
 #ifdef CONFIG_CFG80211_WEXT
 	wdev->wext.ibss.channel = params->channel;
 #endif
+	wdev->sme_state = CFG80211_SME_CONNECTING;
 	err = rdev->ops->join_ibss(&rdev->wiphy, dev, params);
 	if (err) {
 		wdev->connect_keys = NULL;
+		wdev->sme_state = CFG80211_SME_IDLE;
 		return err;
 	}
 
@@ -169,6 +172,7 @@ static void __cfg80211_clear_ibss(struct net_device *dev, bool nowext)
 	}
 
 	wdev->current_bss = NULL;
+	wdev->sme_state = CFG80211_SME_IDLE;
 	wdev->ssid_len = 0;
 #ifdef CONFIG_CFG80211_WEXT
 	if (!nowext)
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 55d9946..8f2d68f 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -935,6 +935,7 @@ int cfg80211_can_change_interface(struct cfg80211_registered_device *rdev,
 				  enum nl80211_iftype iftype)
 {
 	struct wireless_dev *wdev_iter;
+	u32 used_iftypes = BIT(iftype);
 	int num[NUM_NL80211_IFTYPES];
 	int total = 1;
 	int i, j;
@@ -961,6 +962,7 @@ int cfg80211_can_change_interface(struct cfg80211_registered_device *rdev,
 
 		num[wdev_iter->iftype]++;
 		total++;
+		used_iftypes |= BIT(wdev_iter->iftype);
 	}
 	mutex_unlock(&rdev->devlist_mtx);
 
@@ -970,6 +972,7 @@ int cfg80211_can_change_interface(struct cfg80211_registered_device *rdev,
 	for (i = 0; i < rdev->wiphy.n_iface_combinations; i++) {
 		const struct ieee80211_iface_combination *c;
 		struct ieee80211_iface_limit *limits;
+		u32 all_iftypes = 0;
 
 		c = &rdev->wiphy.iface_combinations[i];
 
@@ -984,6 +987,7 @@ int cfg80211_can_change_interface(struct cfg80211_registered_device *rdev,
 			if (rdev->wiphy.software_iftypes & BIT(iftype))
 				continue;
 			for (j = 0; j < c->n_limits; j++) {
+				all_iftypes |= limits[j].types;
 				if (!(limits[j].types & BIT(iftype)))
 					continue;
 				if (limits[j].max < num[iftype])
@@ -991,7 +995,20 @@ int cfg80211_can_change_interface(struct cfg80211_registered_device *rdev,
 				limits[j].max -= num[iftype];
 			}
 		}
-		/* yay, it fits */
+
+		/*
+		 * Finally check that all iftypes that we're currently
+		 * using are actually part of this combination. If they
+		 * aren't then we can't use this combination and have
+		 * to continue to the next.
+		 */
+		if ((all_iftypes & used_iftypes) != used_iftypes)
+			goto cont;
+
+		/*
+		 * This combination covered all interface types and
+		 * supported the requested numbers, so we're good.
+		 */
 		kfree(limits);
 		return 0;
  cont:
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
