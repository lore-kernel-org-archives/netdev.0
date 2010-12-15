From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-12-15
Date: Wed, 15 Dec 2010 10:56:42 -0500
Message-ID: <20101215155642.GE2377@tuxdriver.com>
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

This is a batch of fixes intended for 2.6.37.

The biggest changes fix an issue where the iwlagn driver will misread
the EEPROM information for some devices that will soon be in the wild.
The initial impulse was to rewrite the EEPROM code, but I pushed back on
that for 2.6.37.  The compromise is to add the new EEPROM reading code,
but only to invoke it for the new devices.  Older devices will still use
the existing (and tested) EEPROM code.  Note that all devices will use
the new code in 2.6.38 and beyond.

This also includes a pull of bluetooth fixes from Gustavo Padovan.  That
includes a null pointer fix and a fix for a regression that broke the
DUN profile -- say goodbye to your emergency cell-phone Internet
connection without that!

Other patches include some device ID additions for p54usb, a fix to
avoid log spam resulting from suspend/resume with USB-based wireless
devices that don't define their own suspend hook, a null ptr fix for the
libertas driver, and another null pointer fix related to IBSS merges.

Please let me know if there are problems!

John

---

The following changes since commit 2a27a03d3a891e87ca33d27a858b4db734a4cbab:

  pppoe.c: Fix kernel panic caused by __pppoe_xmit (2010-12-12 15:06:16 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54usb: add 5 more USBIDs

Eduardo Costa (1):
      p54usb: New USB ID for Gemtek WUBI-100GW

Herton Ronaldo Krzesinski (1):
      mac80211: avoid calling ieee80211_work_work unconditionally

Johan Hedberg (1):
      Bluetooth: Fix initial RFCOMM DLC security level

Johannes Berg (1):
      iwlagn: rename enhanced txpower fields

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6

Jun Nie (1):
      Bluetooth: add NULL pointer check in HCI

Sven Neumann (1):
      libertas: fix potential NULL-pointer dereference

Tim Harvey (1):
      mac80211: Fix NULL-pointer deference on ibss merge when not ready

Wey-Yi Guy (1):
      iwlagn: implement layout-agnostic EEPROM reading

 drivers/bluetooth/hci_ldisc.c                 |    6 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c       |    2 +
 drivers/net/wireless/iwlwifi/iwl-6000.c       |   12 ++++
 drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c |   88 ++++++++++++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c    |    6 ++
 drivers/net/wireless/iwlwifi/iwl-core.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-eeprom.h     |   25 ++++++-
 drivers/net/wireless/libertas/cfg.c           |    2 +-
 drivers/net/wireless/p54/p54usb.c             |    6 ++
 net/bluetooth/rfcomm/core.c                   |    1 +
 net/mac80211/ibss.c                           |    4 +
 net/mac80211/work.c                           |    5 +-
 12 files changed, 148 insertions(+), 10 deletions(-)
diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index 7201482..3c6cabc 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -311,8 +311,10 @@ static void hci_uart_tty_close(struct tty_struct *tty)
 
 		if (test_and_clear_bit(HCI_UART_PROTO_SET, &hu->flags)) {
 			hu->proto->close(hu);
-			hci_unregister_dev(hdev);
-			hci_free_dev(hdev);
+			if (hdev) {
+				hci_unregister_dev(hdev);
+				hci_free_dev(hdev);
+			}
 		}
 	}
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index db54091..0e027f7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -315,6 +315,7 @@ struct iwl_cfg iwl100_bgn_cfg = {
 	.mod_params = &iwlagn_mod_params,
 	.base_params = &iwl1000_base_params,
 	.ht_params = &iwl1000_ht_params,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl100_bg_cfg = {
@@ -330,6 +331,7 @@ struct iwl_cfg iwl100_bg_cfg = {
 	.ops = &iwl1000_ops,
 	.mod_params = &iwlagn_mod_params,
 	.base_params = &iwl1000_base_params,
+	.use_new_eeprom_reading = true,
 };
 
 MODULE_FIRMWARE(IWL1000_MODULE_FIRMWARE(IWL1000_UCODE_API_MAX));
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index 11e6532..0ceeaac 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -561,6 +561,7 @@ struct iwl_cfg iwl6000g2a_2agn_cfg = {
 	.ht_params = &iwl6000_ht_params,
 	.need_dc_calib = true,
 	.need_temp_offset_calib = true,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2a_2abg_cfg = {
@@ -578,6 +579,7 @@ struct iwl_cfg iwl6000g2a_2abg_cfg = {
 	.base_params = &iwl6000_base_params,
 	.need_dc_calib = true,
 	.need_temp_offset_calib = true,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2a_2bg_cfg = {
@@ -595,6 +597,7 @@ struct iwl_cfg iwl6000g2a_2bg_cfg = {
 	.base_params = &iwl6000_base_params,
 	.need_dc_calib = true,
 	.need_temp_offset_calib = true,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2b_2agn_cfg = {
@@ -616,6 +619,7 @@ struct iwl_cfg iwl6000g2b_2agn_cfg = {
 	.need_temp_offset_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2b_2abg_cfg = {
@@ -636,6 +640,7 @@ struct iwl_cfg iwl6000g2b_2abg_cfg = {
 	.need_temp_offset_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2b_2bgn_cfg = {
@@ -657,6 +662,7 @@ struct iwl_cfg iwl6000g2b_2bgn_cfg = {
 	.need_temp_offset_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2b_2bg_cfg = {
@@ -677,6 +683,7 @@ struct iwl_cfg iwl6000g2b_2bg_cfg = {
 	.need_temp_offset_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2b_bgn_cfg = {
@@ -698,6 +705,7 @@ struct iwl_cfg iwl6000g2b_bgn_cfg = {
 	.need_temp_offset_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6000g2b_bg_cfg = {
@@ -718,6 +726,7 @@ struct iwl_cfg iwl6000g2b_bg_cfg = {
 	.need_temp_offset_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 /*
@@ -804,6 +813,7 @@ struct iwl_cfg iwl6050g2_bgn_cfg = {
 	.base_params = &iwl6050_base_params,
 	.ht_params = &iwl6000_ht_params,
 	.need_dc_calib = true,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl6050_2abg_cfg = {
@@ -857,6 +867,7 @@ struct iwl_cfg iwl130_bgn_cfg = {
 	.need_dc_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 struct iwl_cfg iwl130_bg_cfg = {
@@ -876,6 +887,7 @@ struct iwl_cfg iwl130_bg_cfg = {
 	.need_dc_calib = true,
 	/* Due to bluetooth, we transmit 2.4 GHz probes only on antenna A */
 	.scan_tx_antennas[IEEE80211_BAND_2GHZ] = ANT_A,
+	.use_new_eeprom_reading = true,
 };
 
 MODULE_FIRMWARE(IWL6000_MODULE_FIRMWARE(IWL6000_UCODE_API_MAX));
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c b/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
index a650bab..9eeeda1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c
@@ -392,7 +392,7 @@ static s8 iwl_update_channel_txpower(struct iwl_priv *priv,
 /**
  * iwlcore_eeprom_enhanced_txpower: process enhanced tx power info
  */
-void iwlcore_eeprom_enhanced_txpower(struct iwl_priv *priv)
+static void iwlcore_eeprom_enhanced_txpower_old(struct iwl_priv *priv)
 {
 	int eeprom_section_count = 0;
 	int section, element;
@@ -419,7 +419,8 @@ void iwlcore_eeprom_enhanced_txpower(struct iwl_priv *priv)
 		 * always check for valid entry before process
 		 * the information
 		 */
-		if (!enhanced_txpower->common || enhanced_txpower->reserved)
+		if (!(enhanced_txpower->flags || enhanced_txpower->channel) ||
+		    enhanced_txpower->delta_20_in_40)
 			continue;
 
 		for (element = 0; element < eeprom_section_count; element++) {
@@ -452,3 +453,86 @@ void iwlcore_eeprom_enhanced_txpower(struct iwl_priv *priv)
 		}
 	}
 }
+
+static void
+iwlcore_eeprom_enh_txp_read_element(struct iwl_priv *priv,
+				    struct iwl_eeprom_enhanced_txpwr *txp,
+				    s8 max_txpower_avg)
+{
+	int ch_idx;
+	bool is_ht40 = txp->flags & IWL_EEPROM_ENH_TXP_FL_40MHZ;
+	enum ieee80211_band band;
+
+	band = txp->flags & IWL_EEPROM_ENH_TXP_FL_BAND_52G ?
+		IEEE80211_BAND_5GHZ : IEEE80211_BAND_2GHZ;
+
+	for (ch_idx = 0; ch_idx < priv->channel_count; ch_idx++) {
+		struct iwl_channel_info *ch_info = &priv->channel_info[ch_idx];
+
+		/* update matching channel or from common data only */
+		if (txp->channel != 0 && ch_info->channel != txp->channel)
+			continue;
+
+		/* update matching band only */
+		if (band != ch_info->band)
+			continue;
+
+		if (ch_info->max_power_avg < max_txpower_avg && !is_ht40) {
+			ch_info->max_power_avg = max_txpower_avg;
+			ch_info->curr_txpow = max_txpower_avg;
+			ch_info->scan_power = max_txpower_avg;
+		}
+
+		if (is_ht40 && ch_info->ht40_max_power_avg < max_txpower_avg)
+			ch_info->ht40_max_power_avg = max_txpower_avg;
+	}
+}
+
+#define EEPROM_TXP_OFFS	(0x00 | INDIRECT_ADDRESS | INDIRECT_TXP_LIMIT)
+#define EEPROM_TXP_ENTRY_LEN sizeof(struct iwl_eeprom_enhanced_txpwr)
+#define EEPROM_TXP_SZ_OFFS (0x00 | INDIRECT_ADDRESS | INDIRECT_TXP_LIMIT_SIZE)
+
+static void iwlcore_eeprom_enhanced_txpower_new(struct iwl_priv *priv)
+{
+	struct iwl_eeprom_enhanced_txpwr *txp_array, *txp;
+	int idx, entries;
+	__le16 *txp_len;
+	s8 max_txp_avg, max_txp_avg_halfdbm;
+
+	BUILD_BUG_ON(sizeof(struct iwl_eeprom_enhanced_txpwr) != 8);
+
+	/* the length is in 16-bit words, but we want entries */
+	txp_len = (__le16 *) iwlagn_eeprom_query_addr(priv, EEPROM_TXP_SZ_OFFS);
+	entries = le16_to_cpup(txp_len) * 2 / EEPROM_TXP_ENTRY_LEN;
+
+	txp_array = (void *) iwlagn_eeprom_query_addr(priv, EEPROM_TXP_OFFS);
+	for (idx = 0; idx < entries; idx++) {
+		txp = &txp_array[idx];
+
+		/* skip invalid entries */
+		if (!(txp->flags & IWL_EEPROM_ENH_TXP_FL_VALID))
+			continue;
+
+		max_txp_avg = iwl_get_max_txpower_avg(priv, txp_array, idx,
+						      &max_txp_avg_halfdbm);
+
+		/*
+		 * Update the user limit values values to the highest
+		 * power supported by any channel
+		 */
+		if (max_txp_avg > priv->tx_power_user_lmt)
+			priv->tx_power_user_lmt = max_txp_avg;
+		if (max_txp_avg_halfdbm > priv->tx_power_lmt_in_half_dbm)
+			priv->tx_power_lmt_in_half_dbm = max_txp_avg_halfdbm;
+
+		iwlcore_eeprom_enh_txp_read_element(priv, txp, max_txp_avg);
+	}
+}
+
+void iwlcore_eeprom_enhanced_txpower(struct iwl_priv *priv)
+{
+	if (priv->cfg->use_new_eeprom_reading)
+		iwlcore_eeprom_enhanced_txpower_new(priv);
+	else
+		iwlcore_eeprom_enhanced_txpower_old(priv);
+}
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index b555edd..554afb7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -569,6 +569,12 @@ static u32 eeprom_indirect_address(const struct iwl_priv *priv, u32 address)
 	case INDIRECT_REGULATORY:
 		offset = iwl_eeprom_query16(priv, EEPROM_LINK_REGULATORY);
 		break;
+	case INDIRECT_TXP_LIMIT:
+		offset = iwl_eeprom_query16(priv, EEPROM_LINK_TXP_LIMIT);
+		break;
+	case INDIRECT_TXP_LIMIT_SIZE:
+		offset = iwl_eeprom_query16(priv, EEPROM_LINK_TXP_LIMIT_SIZE);
+		break;
 	case INDIRECT_CALIBRATION:
 		offset = iwl_eeprom_query16(priv, EEPROM_LINK_CALIBRATION);
 		break;
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 64527de..954ecc2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -390,6 +390,7 @@ struct iwl_cfg {
 	const bool need_temp_offset_calib; /* if used set to true */
 	u8 scan_rx_antennas[IEEE80211_NUM_BANDS];
 	u8 scan_tx_antennas[IEEE80211_NUM_BANDS];
+	const bool use_new_eeprom_reading; /* temporary, remove later */
 };
 
 /***************************
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
index d9b5906..e3a279d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
@@ -120,6 +120,17 @@ struct iwl_eeprom_channel {
 	s8 max_power_avg;	/* max power (dBm) on this chnl, limit 31 */
 } __packed;
 
+enum iwl_eeprom_enhanced_txpwr_flags {
+	IWL_EEPROM_ENH_TXP_FL_VALID		= BIT(0),
+	IWL_EEPROM_ENH_TXP_FL_BAND_52G		= BIT(1),
+	IWL_EEPROM_ENH_TXP_FL_OFDM		= BIT(2),
+	IWL_EEPROM_ENH_TXP_FL_40MHZ		= BIT(3),
+	IWL_EEPROM_ENH_TXP_FL_HT_AP		= BIT(4),
+	IWL_EEPROM_ENH_TXP_FL_RES1		= BIT(5),
+	IWL_EEPROM_ENH_TXP_FL_RES2		= BIT(6),
+	IWL_EEPROM_ENH_TXP_FL_COMMON_TYPE	= BIT(7),
+};
+
 /**
  * iwl_eeprom_enhanced_txpwr structure
  *    This structure presents the enhanced regulatory tx power limit layout
@@ -127,21 +138,23 @@ struct iwl_eeprom_channel {
  *    Enhanced regulatory tx power portion of eeprom image can be broken down
  *    into individual structures; each one is 8 bytes in size and contain the
  *    following information
- * @common: (desc + channel) not used by driver, should _NOT_ be "zero"
+ * @flags: entry flags
+ * @channel: channel number
  * @chain_a_max_pwr: chain a max power in 1/2 dBm
  * @chain_b_max_pwr: chain b max power in 1/2 dBm
  * @chain_c_max_pwr: chain c max power in 1/2 dBm
- * @reserved: not used, should be "zero"
+ * @delta_20_in_40: 20-in-40 deltas (hi/lo)
  * @mimo2_max_pwr: mimo2 max power in 1/2 dBm
  * @mimo3_max_pwr: mimo3 max power in 1/2 dBm
  *
  */
 struct iwl_eeprom_enhanced_txpwr {
-	__le16 common;
+	u8 flags;
+	u8 channel;
 	s8 chain_a_max;
 	s8 chain_b_max;
 	s8 chain_c_max;
-	s8 reserved;
+	u8 delta_20_in_40;
 	s8 mimo2_max;
 	s8 mimo3_max;
 } __packed;
@@ -186,6 +199,8 @@ struct iwl_eeprom_enhanced_txpwr {
 #define EEPROM_LINK_CALIBRATION      (2*0x67)
 #define EEPROM_LINK_PROCESS_ADJST    (2*0x68)
 #define EEPROM_LINK_OTHERS           (2*0x69)
+#define EEPROM_LINK_TXP_LIMIT        (2*0x6a)
+#define EEPROM_LINK_TXP_LIMIT_SIZE   (2*0x6b)
 
 /* agn regulatory - indirect access */
 #define EEPROM_REG_BAND_1_CHANNELS       ((0x08)\
@@ -389,6 +404,8 @@ struct iwl_eeprom_calib_info {
 #define INDIRECT_CALIBRATION        0x00040000
 #define INDIRECT_PROCESS_ADJST      0x00050000
 #define INDIRECT_OTHERS             0x00060000
+#define INDIRECT_TXP_LIMIT          0x00070000
+#define INDIRECT_TXP_LIMIT_SIZE     0x00080000
 #define INDIRECT_ADDRESS            0x00100000
 
 /* General */
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 373930a..113f4f2 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -619,7 +619,7 @@ static int lbs_ret_scan(struct lbs_private *priv, unsigned long dummy,
 				     print_ssid(ssid_buf, ssid, ssid_len),
 				     LBS_SCAN_RSSI_TO_MBM(rssi)/100);
 
-			if (channel ||
+			if (channel &&
 			    !(channel->flags & IEEE80211_CHAN_DISABLED))
 				cfg80211_inform_bss(wiphy, channel,
 					bssid, le64_to_cpu(*(__le64 *)tsfdesc),
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index d5bc21e..2325e56 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -43,6 +43,7 @@ MODULE_FIRMWARE("isl3887usb");
 
 static struct usb_device_id p54u_table[] __devinitdata = {
 	/* Version 1 devices (pci chip + net2280) */
+	{USB_DEVICE(0x0411, 0x0050)},	/* Buffalo WLI2-USB2-G54 */
 	{USB_DEVICE(0x045e, 0x00c2)},	/* Microsoft MN-710 */
 	{USB_DEVICE(0x0506, 0x0a11)},	/* 3COM 3CRWE254G72 */
 	{USB_DEVICE(0x06b9, 0x0120)},	/* Thomson SpeedTouch 120g */
@@ -56,9 +57,13 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0846, 0x4220)},	/* Netgear WG111 */
 	{USB_DEVICE(0x09aa, 0x1000)},	/* Spinnaker Proto board */
 	{USB_DEVICE(0x0cde, 0x0006)},	/* Medion 40900, Roper Europe */
+	{USB_DEVICE(0x0db0, 0x6826)},	/* MSI UB54G (MS-6826) */
 	{USB_DEVICE(0x107b, 0x55f2)},	/* Gateway WGU-210 (Gemtek) */
 	{USB_DEVICE(0x124a, 0x4023)},	/* Shuttle PN15, Airvast WM168g, IOGear GWU513 */
+	{USB_DEVICE(0x1435, 0x0210)},	/* Inventel UR054G */
+	{USB_DEVICE(0x15a9, 0x0002)},	/* Gemtek WUBI-100GW 802.11g */
 	{USB_DEVICE(0x1630, 0x0005)},	/* 2Wire 802.11g USB (v1) / Z-Com */
+	{USB_DEVICE(0x182d, 0x096b)},	/* Sitecom WL-107 */
 	{USB_DEVICE(0x1915, 0x2234)},	/* Linksys WUSB54G OEM */
 	{USB_DEVICE(0x1915, 0x2235)},	/* Linksys WUSB54G Portable OEM */
 	{USB_DEVICE(0x2001, 0x3701)},	/* DLink DWL-G120 Spinnaker */
@@ -94,6 +99,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
 	{USB_DEVICE(0x1668, 0x1050)},	/* Actiontec 802UIG-1 */
 	{USB_DEVICE(0x2001, 0x3704)},	/* DLink DWL-G122 rev A2 */
+	{USB_DEVICE(0x2001, 0x3705)},	/* D-Link DWL-G120 rev C1 */
 	{USB_DEVICE(0x413c, 0x5513)},	/* Dell WLA3310 USB Wireless Adapter */
 	{USB_DEVICE(0x413c, 0x8102)},	/* Spinnaker DUT */
 	{USB_DEVICE(0x413c, 0x8104)},	/* Cohiba Proto board */
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index fa642aa..432a9a6 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -311,6 +311,7 @@ static void rfcomm_dlc_clear_state(struct rfcomm_dlc *d)
 	d->state      = BT_OPEN;
 	d->flags      = 0;
 	d->mscex      = 0;
+	d->sec_level  = BT_SECURITY_LOW;
 	d->mtu        = RFCOMM_DEFAULT_MTU;
 	d->v24_sig    = RFCOMM_V24_RTC | RFCOMM_V24_RTR | RFCOMM_V24_DV;
 
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 239c483..077a93d 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -780,6 +780,9 @@ void ieee80211_ibss_rx_queued_mgmt(struct ieee80211_sub_if_data *sdata,
 
 	mutex_lock(&sdata->u.ibss.mtx);
 
+	if (!sdata->u.ibss.ssid_len)
+		goto mgmt_out; /* not ready to merge yet */
+
 	switch (fc & IEEE80211_FCTL_STYPE) {
 	case IEEE80211_STYPE_PROBE_REQ:
 		ieee80211_rx_mgmt_probe_req(sdata, mgmt, skb->len);
@@ -797,6 +800,7 @@ void ieee80211_ibss_rx_queued_mgmt(struct ieee80211_sub_if_data *sdata,
 		break;
 	}
 
+ mgmt_out:
 	mutex_unlock(&sdata->u.ibss.mtx);
 }
 
diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index ae344d1..146097c 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -1051,11 +1051,13 @@ void ieee80211_work_purge(struct ieee80211_sub_if_data *sdata)
 {
 	struct ieee80211_local *local = sdata->local;
 	struct ieee80211_work *wk;
+	bool cleanup = false;
 
 	mutex_lock(&local->mtx);
 	list_for_each_entry(wk, &local->work_list, list) {
 		if (wk->sdata != sdata)
 			continue;
+		cleanup = true;
 		wk->type = IEEE80211_WORK_ABORT;
 		wk->started = true;
 		wk->timeout = jiffies;
@@ -1063,7 +1065,8 @@ void ieee80211_work_purge(struct ieee80211_sub_if_data *sdata)
 	mutex_unlock(&local->mtx);
 
 	/* run cleanups etc. */
-	ieee80211_work_work(&local->work_work);
+	if (cleanup)
+		ieee80211_work_work(&local->work_work);
 
 	mutex_lock(&local->mtx);
 	list_for_each_entry(wk, &local->work_list, list) {
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
