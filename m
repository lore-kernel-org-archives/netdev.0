From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-01-16
Date: Fri, 16 Jan 2009 17:31:46 -0500
Message-ID: <20090116223145.GA8233@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52165 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755747AbZAPWpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 17:45:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another batch of fixes intended for 2.6.29.  Most of them are
simple/obvious and/or their changelog cites the bug they are fixing.
The "cfg80211: make handle_band() and handle_channel() wiphy specific"
patch is a pre-requisite to the other patches from Luis.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit a58c891a53aca81c78f9cbe0572a301042470e96:
  Eric Dumazet (1):
        b44: GFP_DMA skb should not escape from driver

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrey Yurovsky (1):
      libertas: Fix alignment issues in libertas core

Artur Skawina (1):
      p54: set_tim must be atomic.

Christian Lamparter (2):
      p54: fix oops caused by bad eeproms
      p54: fix p54_set_key's return code

Jouni Malinen (2):
      ath9k: Fix an operator typo in phy rate validation
      ath9k: Fix an operator typo in REG_DOMAIN_2GHZ_MASK

Luis R. Rodriguez (3):
      cfg80211: make handle_band() and handle_channel() wiphy specific
      cfg80211: Fix regression with 11d on bands
      cfg80211: Fix parsed country IE info for 5 GHz

Rami Rosen (1):
      rt2x00: fix a wrong parameter for __test_and_clear_bit() in rt2x00rfkill_free().

Randy Dunlap (1):
      mac80211: more kernel-doc fixes

Zhu Yi (1):
      iwlwifi: remove CMD_WANT_SKB flag if send_cmd_sync failure

 drivers/net/wireless/ath9k/rc.c             |    2 +-
 drivers/net/wireless/ath9k/regd_common.h    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
 drivers/net/wireless/libertas/hostcmd.h     |   91 ++++++++++----------
 drivers/net/wireless/p54/p54common.c        |    6 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c  |    2 +-
 include/net/mac80211.h                      |    1 -
 net/mac80211/sta_info.h                     |    1 -
 net/wireless/reg.c                          |  128 ++++++++++++++++++++++++---
 10 files changed, 170 insertions(+), 67 deletions(-)

diff --git a/arch/arm/mach-integrator/clock.h b/arch/arm/mach-integrator/clock.h
deleted file mode 100644
index e69de29..0000000
diff --git a/drivers/net/wireless/ath9k/rc.c b/drivers/net/wireless/ath9k/rc.c
index 04ab457..1b71b93 100644
--- a/drivers/net/wireless/ath9k/rc.c
+++ b/drivers/net/wireless/ath9k/rc.c
@@ -490,7 +490,7 @@ static inline int ath_rc_get_nextvalid_txrate(struct ath_rate_table *rate_table,
 
 static int ath_rc_valid_phyrate(u32 phy, u32 capflag, int ignore_cw)
 {
-	if (WLAN_RC_PHY_HT(phy) & !(capflag & WLAN_RC_HT_FLAG))
+	if (WLAN_RC_PHY_HT(phy) && !(capflag & WLAN_RC_HT_FLAG))
 		return 0;
 	if (WLAN_RC_PHY_DS(phy) && !(capflag & WLAN_RC_DS_FLAG))
 		return 0;
diff --git a/drivers/net/wireless/ath9k/regd_common.h b/drivers/net/wireless/ath9k/regd_common.h
index 9112c03..6df1b3b 100644
--- a/drivers/net/wireless/ath9k/regd_common.h
+++ b/drivers/net/wireless/ath9k/regd_common.h
@@ -228,7 +228,7 @@ enum {
 };
 
 #define REG_DOMAIN_2GHZ_MASK    (REQ_MASK & \
-	(!(ADHOC_NO_11A | DISALLOW_ADHOC_11A | DISALLOW_ADHOC_11A_TURB)))
+	(~(ADHOC_NO_11A | DISALLOW_ADHOC_11A | DISALLOW_ADHOC_11A_TURB)))
 #define REG_DOMAIN_5GHZ_MASK    REQ_MASK
 
 static struct reg_dmn_pair_mapping regDomainPairs[] = {
diff --git a/drivers/net/wireless/iwlwifi/iwl-hcmd.c b/drivers/net/wireless/iwlwifi/iwl-hcmd.c
index 8c71ad4..4b35b30 100644
--- a/drivers/net/wireless/iwlwifi/iwl-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-hcmd.c
@@ -224,7 +224,7 @@ int iwl_send_cmd_sync(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 		IWL_ERROR("Error: Response NULL in '%s'\n",
 			  get_cmd_string(cmd->id));
 		ret = -EIO;
-		goto out;
+		goto cancel;
 	}
 
 	ret = 0;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index d645808..15f5655 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -745,7 +745,7 @@ static int iwl3945_send_cmd_sync(struct iwl3945_priv *priv, struct iwl3945_host_
 		IWL_ERROR("Error: Response NULL in '%s'\n",
 			  get_cmd_string(cmd->id));
 		ret = -EIO;
-		goto out;
+		goto cancel;
 	}
 
 	ret = 0;
diff --git a/drivers/net/wireless/libertas/hostcmd.h b/drivers/net/wireless/libertas/hostcmd.h
index e173b1b..f6a79a6 100644
--- a/drivers/net/wireless/libertas/hostcmd.h
+++ b/drivers/net/wireless/libertas/hostcmd.h
@@ -32,7 +32,7 @@ struct txpd {
 	u8 pktdelay_2ms;
 	/* reserved */
 	u8 reserved1;
-};
+} __attribute__ ((packed));
 
 /* RxPD Descriptor */
 struct rxpd {
@@ -63,7 +63,7 @@ struct rxpd {
 	/* Pkt Priority */
 	u8 priority;
 	u8 reserved[3];
-};
+} __attribute__ ((packed));
 
 struct cmd_header {
 	__le16 command;
@@ -97,7 +97,7 @@ struct enc_key {
 struct lbs_offset_value {
 	u32 offset;
 	u32 value;
-};
+} __attribute__ ((packed));
 
 /* Define general data structure */
 /* cmd_DS_GEN */
@@ -107,7 +107,7 @@ struct cmd_ds_gen {
 	__le16 seqnum;
 	__le16 result;
 	void *cmdresp[0];
-};
+} __attribute__ ((packed));
 
 #define S_DS_GEN sizeof(struct cmd_ds_gen)
 
@@ -163,7 +163,7 @@ struct cmd_ds_802_11_subscribe_event {
 	 * bump this up a bit.
 	 */
 	uint8_t tlv[128];
-};
+} __attribute__ ((packed));
 
 /*
  * This scan handle Country Information IE(802.11d compliant)
@@ -180,7 +180,7 @@ struct cmd_ds_802_11_scan {
 	mrvlietypes_chanlistparamset_t ChanListParamSet;
 	mrvlietypes_ratesparamset_t OpRateSet;
 #endif
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_scan_rsp {
 	struct cmd_header hdr;
@@ -188,7 +188,7 @@ struct cmd_ds_802_11_scan_rsp {
 	__le16 bssdescriptsize;
 	uint8_t nr_sets;
 	uint8_t bssdesc_and_tlvbuffer[0];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_get_log {
 	struct cmd_header hdr;
@@ -206,33 +206,33 @@ struct cmd_ds_802_11_get_log {
 	__le32 fcserror;
 	__le32 txframe;
 	__le32 wepundecryptable;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_mac_control {
 	struct cmd_header hdr;
 	__le16 action;
 	u16 reserved;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_mac_multicast_adr {
 	struct cmd_header hdr;
 	__le16 action;
 	__le16 nr_of_adrs;
 	u8 maclist[ETH_ALEN * MRVDRV_MAX_MULTICAST_LIST_SIZE];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_authenticate {
 	u8 macaddr[ETH_ALEN];
 	u8 authtype;
 	u8 reserved[10];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_deauthenticate {
 	struct cmd_header hdr;
 
 	u8 macaddr[ETH_ALEN];
 	__le16 reasoncode;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_associate {
 	u8 peerstaaddr[6];
@@ -251,7 +251,7 @@ struct cmd_ds_802_11_associate {
 
 struct cmd_ds_802_11_associate_rsp {
 	struct ieeetypes_assocrsp assocRsp;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_set_wep {
 	struct cmd_header hdr;
@@ -265,7 +265,7 @@ struct cmd_ds_802_11_set_wep {
 	/* 40, 128bit or TXWEP */
 	uint8_t keytype[4];
 	uint8_t keymaterial[4][16];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_3_get_stat {
 	__le32 xmitok;
@@ -274,7 +274,7 @@ struct cmd_ds_802_3_get_stat {
 	__le32 rcverror;
 	__le32 rcvnobuffer;
 	__le32 rcvcrcerror;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_get_stat {
 	__le32 txfragmentcnt;
@@ -294,7 +294,7 @@ struct cmd_ds_802_11_get_stat {
 	__le32 txbeacon;
 	__le32 rxbeacon;
 	__le32 wepundecryptable;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_snmp_mib {
 	struct cmd_header hdr;
@@ -303,58 +303,58 @@ struct cmd_ds_802_11_snmp_mib {
 	__le16 oid;
 	__le16 bufsize;
 	u8 value[128];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_mac_reg_map {
 	__le16 buffersize;
 	u8 regmap[128];
 	__le16 reserved;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_bbp_reg_map {
 	__le16 buffersize;
 	u8 regmap[128];
 	__le16 reserved;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_rf_reg_map {
 	__le16 buffersize;
 	u8 regmap[64];
 	__le16 reserved;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_mac_reg_access {
 	__le16 action;
 	__le16 offset;
 	__le32 value;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_bbp_reg_access {
 	__le16 action;
 	__le16 offset;
 	u8 value;
 	u8 reserved[3];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_rf_reg_access {
 	__le16 action;
 	__le16 offset;
 	u8 value;
 	u8 reserved[3];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_radio_control {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 control;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_beacon_control {
 	__le16 action;
 	__le16 beacon_enable;
 	__le16 beacon_period;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_sleep_params {
 	struct cmd_header hdr;
@@ -379,7 +379,7 @@ struct cmd_ds_802_11_sleep_params {
 
 	/* reserved field, should be set to zero */
 	__le16 reserved;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_inactivity_timeout {
 	struct cmd_header hdr;
@@ -389,7 +389,7 @@ struct cmd_ds_802_11_inactivity_timeout {
 
 	/* Inactivity timeout in msec */
 	__le16 timeout;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_rf_channel {
 	struct cmd_header hdr;
@@ -399,7 +399,7 @@ struct cmd_ds_802_11_rf_channel {
 	__le16 rftype;      /* unused */
 	__le16 reserved;    /* unused */
 	u8 channellist[32]; /* unused */
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_rssi {
 	/* weighting factor */
@@ -408,21 +408,21 @@ struct cmd_ds_802_11_rssi {
 	__le16 reserved_0;
 	__le16 reserved_1;
 	__le16 reserved_2;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_rssi_rsp {
 	__le16 SNR;
 	__le16 noisefloor;
 	__le16 avgSNR;
 	__le16 avgnoisefloor;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_mac_address {
 	struct cmd_header hdr;
 
 	__le16 action;
 	u8 macadd[ETH_ALEN];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_rf_tx_power {
 	struct cmd_header hdr;
@@ -431,7 +431,7 @@ struct cmd_ds_802_11_rf_tx_power {
 	__le16 curlevel;
 	s8 maxlevel;
 	s8 minlevel;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_rf_antenna {
 	__le16 action;
@@ -439,33 +439,33 @@ struct cmd_ds_802_11_rf_antenna {
 	/* Number of antennas or 0xffff(diversity) */
 	__le16 antennamode;
 
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_monitor_mode {
 	__le16 action;
 	__le16 mode;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_set_boot2_ver {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 version;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_fw_wake_method {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 method;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_sleep_period {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 period;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_ps_mode {
 	__le16 action;
@@ -473,7 +473,7 @@ struct cmd_ds_802_11_ps_mode {
 	__le16 multipledtim;
 	__le16 reserved;
 	__le16 locallisteninterval;
-};
+} __attribute__ ((packed));
 
 struct cmd_confirm_sleep {
 	struct cmd_header hdr;
@@ -483,7 +483,7 @@ struct cmd_confirm_sleep {
 	__le16 multipledtim;
 	__le16 reserved;
 	__le16 locallisteninterval;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_data_rate {
 	struct cmd_header hdr;
@@ -491,14 +491,14 @@ struct cmd_ds_802_11_data_rate {
 	__le16 action;
 	__le16 reserved;
 	u8 rates[MAX_RATES];
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_rate_adapt_rateset {
 	struct cmd_header hdr;
 	__le16 action;
 	__le16 enablehwauto;
 	__le16 bitmap;
-};
+} __attribute__ ((packed));
 
 struct cmd_ds_802_11_ad_hoc_start {
 	struct cmd_header hdr;
@@ -520,7 +520,7 @@ struct cmd_ds_802_11_ad_hoc_result {
 
 	u8 pad[3];
 	u8 bssid[ETH_ALEN];
-};
+} __attribute__ ((packed));
 
 struct adhoc_bssdesc {
 	u8 bssid[ETH_ALEN];
@@ -578,7 +578,7 @@ struct MrvlIEtype_keyParamSet {
 
 	/* key material of size keylen */
 	u8 key[32];
-};
+} __attribute__ ((packed));
 
 #define MAX_WOL_RULES 		16
 
@@ -590,7 +590,7 @@ struct host_wol_rule {
 	__le16 reserve;
 	__be32 sig_mask;
 	__be32 signature;
-};
+} __attribute__ ((packed));
 
 struct wol_config {
 	uint8_t action;
@@ -598,8 +598,7 @@ struct wol_config {
 	uint8_t no_rules_in_cmd;
 	uint8_t result;
 	struct host_wol_rule rule[MAX_WOL_RULES];
-};
-
+} __attribute__ ((packed));
 
 struct cmd_ds_host_sleep {
 	struct cmd_header hdr;
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index c6a370f..12d0717 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -1147,7 +1147,7 @@ static int p54_set_tim(struct ieee80211_hw *dev, struct ieee80211_sta *sta,
 
 	skb = p54_alloc_skb(dev, P54_HDR_FLAG_CONTROL_OPSET,
 		      sizeof(struct p54_hdr) + sizeof(*tim),
-		      P54_CONTROL_TYPE_TIM, GFP_KERNEL);
+		      P54_CONTROL_TYPE_TIM, GFP_ATOMIC);
 	if (!skb)
 		return -ENOMEM;
 
@@ -1610,7 +1610,7 @@ static int p54_scan(struct ieee80211_hw *dev, u16 mode, u16 dwell)
 
  err:
 	printk(KERN_ERR "%s: frequency change failed\n", wiphy_name(dev->wiphy));
-	kfree_skb(skb);
+	p54_free_skb(dev, skb);
 	return -EINVAL;
 }
 
@@ -2077,7 +2077,7 @@ static int p54_set_key(struct ieee80211_hw *dev, enum set_key_cmd cmd,
 			algo = P54_CRYPTO_AESCCMP;
 			break;
 		default:
-			return -EINVAL;
+			return -EOPNOTSUPP;
 		}
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00rfkill.c b/drivers/net/wireless/rt2x00/rt2x00rfkill.c
index c3f53a9..3298cae 100644
--- a/drivers/net/wireless/rt2x00/rt2x00rfkill.c
+++ b/drivers/net/wireless/rt2x00/rt2x00rfkill.c
@@ -162,7 +162,7 @@ void rt2x00rfkill_allocate(struct rt2x00_dev *rt2x00dev)
 
 void rt2x00rfkill_free(struct rt2x00_dev *rt2x00dev)
 {
-	if (!test_bit(RFKILL_STATE_ALLOCATED, &rt2x00dev->flags))
+	if (!test_bit(RFKILL_STATE_ALLOCATED, &rt2x00dev->rfkill_state))
 		return;
 
 	cancel_delayed_work_sync(&rt2x00dev->rfkill_work);
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index b3bd00a..559422f 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -322,7 +322,6 @@ struct ieee80211_tx_rate {
  * @control: union for control data
  * @status: union for status data
  * @driver_data: array of driver_data pointers
- * @retry_count: number of retries
  * @ampdu_ack_len: number of aggregated frames.
  * 	relevant only if IEEE80211_TX_STATUS_AMPDU was set.
  * @ampdu_ack_map: block ack bit map for the aggregation.
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index dc2606d..e49a5b9 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -195,7 +195,6 @@ struct sta_ampdu_mlme {
  * @tx_packets: number of RX/TX MSDUs
  * @tx_bytes: number of bytes transmitted to this STA
  * @tx_fragments: number of transmitted MPDUs
- * @last_txrate: description of the last used transmit rate
  * @tid_seq: per-TID sequence numbers for sending to this STA
  * @ampdu_mlme: A-MPDU state machine state
  * @timer_to_tid: identity mapping to ID timers
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 4f87753..bc494ce 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -421,6 +421,31 @@ static u32 freq_max_bandwidth(const struct ieee80211_freq_range *freq_range,
 	return 0;
 }
 
+/**
+ * freq_in_rule_band - tells us if a frequency is in a frequency band
+ * @freq_range: frequency rule we want to query
+ * @freq_khz: frequency we are inquiring about
+ *
+ * This lets us know if a specific frequency rule is or is not relevant to
+ * a specific frequency's band. Bands are device specific and artificial
+ * definitions (the "2.4 GHz band" and the "5 GHz band"), however it is
+ * safe for now to assume that a frequency rule should not be part of a
+ * frequency's band if the start freq or end freq are off by more than 2 GHz.
+ * This resolution can be lowered and should be considered as we add
+ * regulatory rule support for other "bands".
+ **/
+static bool freq_in_rule_band(const struct ieee80211_freq_range *freq_range,
+	u32 freq_khz)
+{
+#define ONE_GHZ_IN_KHZ	1000000
+	if (abs(freq_khz - freq_range->start_freq_khz) <= (2 * ONE_GHZ_IN_KHZ))
+		return true;
+	if (abs(freq_khz - freq_range->end_freq_khz) <= (2 * ONE_GHZ_IN_KHZ))
+		return true;
+	return false;
+#undef ONE_GHZ_IN_KHZ
+}
+
 /* Converts a country IE to a regulatory domain. A regulatory domain
  * structure has a lot of information which the IE doesn't yet have,
  * so for the other values we use upper max values as we will intersect
@@ -538,6 +563,7 @@ static struct ieee80211_regdomain *country_ie_2_rd(
 
 	/* This time around we fill in the rd */
 	while (country_ie_len >= 3) {
+		int end_channel = 0;
 		struct ieee80211_country_ie_triplet *triplet =
 			(struct ieee80211_country_ie_triplet *) country_ie;
 		struct ieee80211_reg_rule *reg_rule = NULL;
@@ -559,6 +585,23 @@ static struct ieee80211_regdomain *country_ie_2_rd(
 
 		reg_rule->flags = flags;
 
+		/* 2 GHz */
+		if (triplet->chans.first_channel <= 14)
+			end_channel = triplet->chans.first_channel +
+				triplet->chans.num_channels;
+		else
+			/*
+			 * 5 GHz -- For example in country IEs if the first
+			 * channel given is 36 and the number of channels is 4
+			 * then the individual channel numbers defined for the
+			 * 5 GHz PHY by these parameters are: 36, 40, 44, and 48
+			 * and not 36, 37, 38, 39.
+			 *
+			 * See: http://tinyurl.com/11d-clarification
+			 */
+			end_channel =  triplet->chans.first_channel +
+				(4 * (triplet->chans.num_channels - 1));
+
 		/* The +10 is since the regulatory domain expects
 		 * the actual band edge, not the center of freq for
 		 * its start and end freqs, assuming 20 MHz bandwidth on
@@ -568,8 +611,7 @@ static struct ieee80211_regdomain *country_ie_2_rd(
 				triplet->chans.first_channel) - 10);
 		freq_range->end_freq_khz =
 			MHZ_TO_KHZ(ieee80211_channel_to_frequency(
-				triplet->chans.first_channel +
-					triplet->chans.num_channels) + 10);
+				end_channel) + 10);
 
 		/* Large arbitrary values, we intersect later */
 		/* Increment this if we ever support >= 40 MHz channels
@@ -748,12 +790,23 @@ static u32 map_regdom_flags(u32 rd_flags)
  * 	this value to the maximum allowed bandwidth.
  * @reg_rule: the regulatory rule which we have for this frequency
  *
- * Use this function to get the regulatory rule for a specific frequency.
+ * Use this function to get the regulatory rule for a specific frequency on
+ * a given wireless device. If the device has a specific regulatory domain
+ * it wants to follow we respect that unless a country IE has been received
+ * and processed already.
+ *
+ * Returns 0 if it was able to find a valid regulatory rule which does
+ * apply to the given center_freq otherwise it returns non-zero. It will
+ * also return -ERANGE if we determine the given center_freq does not even have
+ * a regulatory rule for a frequency range in the center_freq's band. See
+ * freq_in_rule_band() for our current definition of a band -- this is purely
+ * subjective and right now its 802.11 specific.
  */
 static int freq_reg_info(u32 center_freq, u32 *bandwidth,
 			 const struct ieee80211_reg_rule **reg_rule)
 {
 	int i;
+	bool band_rule_found = false;
 	u32 max_bandwidth = 0;
 
 	if (!cfg80211_regdomain)
@@ -767,7 +820,15 @@ static int freq_reg_info(u32 center_freq, u32 *bandwidth,
 		rr = &cfg80211_regdomain->reg_rules[i];
 		fr = &rr->freq_range;
 		pr = &rr->power_rule;
+
+		/* We only need to know if one frequency rule was
+		 * was in center_freq's band, that's enough, so lets
+		 * not overwrite it once found */
+		if (!band_rule_found)
+			band_rule_found = freq_in_rule_band(fr, center_freq);
+
 		max_bandwidth = freq_max_bandwidth(fr, center_freq);
+
 		if (max_bandwidth && *bandwidth <= max_bandwidth) {
 			*reg_rule = rr;
 			*bandwidth = max_bandwidth;
@@ -775,23 +836,64 @@ static int freq_reg_info(u32 center_freq, u32 *bandwidth,
 		}
 	}
 
+	if (!band_rule_found)
+		return -ERANGE;
+
 	return !max_bandwidth;
 }
 
-static void handle_channel(struct ieee80211_channel *chan)
+static void handle_channel(struct wiphy *wiphy, enum ieee80211_band band,
+			   unsigned int chan_idx)
 {
 	int r;
-	u32 flags = chan->orig_flags;
+	u32 flags;
 	u32 max_bandwidth = 0;
 	const struct ieee80211_reg_rule *reg_rule = NULL;
 	const struct ieee80211_power_rule *power_rule = NULL;
+	struct ieee80211_supported_band *sband;
+	struct ieee80211_channel *chan;
+
+	sband = wiphy->bands[band];
+	BUG_ON(chan_idx >= sband->n_channels);
+	chan = &sband->channels[chan_idx];
+
+	flags = chan->orig_flags;
 
 	r = freq_reg_info(MHZ_TO_KHZ(chan->center_freq),
 		&max_bandwidth, &reg_rule);
 
 	if (r) {
-		flags |= IEEE80211_CHAN_DISABLED;
-		chan->flags = flags;
+		/* This means no regulatory rule was found in the country IE
+		 * with a frequency range on the center_freq's band, since
+		 * IEEE-802.11 allows for a country IE to have a subset of the
+		 * regulatory information provided in a country we ignore
+		 * disabling the channel unless at least one reg rule was
+		 * found on the center_freq's band. For details see this
+		 * clarification:
+		 *
+		 * http://tinyurl.com/11d-clarification
+		 */
+		if (r == -ERANGE &&
+		    last_request->initiator == REGDOM_SET_BY_COUNTRY_IE) {
+#ifdef CONFIG_CFG80211_REG_DEBUG
+			printk(KERN_DEBUG "cfg80211: Leaving channel %d MHz "
+				"intact on %s - no rule found in band on "
+				"Country IE\n",
+				chan->center_freq, wiphy_name(wiphy));
+#endif
+		} else {
+		/* In this case we know the country IE has at least one reg rule
+		 * for the band so we respect its band definitions */
+#ifdef CONFIG_CFG80211_REG_DEBUG
+			if (last_request->initiator == REGDOM_SET_BY_COUNTRY_IE)
+				printk(KERN_DEBUG "cfg80211: Disabling "
+					"channel %d MHz on %s due to "
+					"Country IE\n",
+					chan->center_freq, wiphy_name(wiphy));
+#endif
+			flags |= IEEE80211_CHAN_DISABLED;
+			chan->flags = flags;
+		}
 		return;
 	}
 
@@ -808,12 +910,16 @@ static void handle_channel(struct ieee80211_channel *chan)
 		chan->max_power = (int) MBM_TO_DBM(power_rule->max_eirp);
 }
 
-static void handle_band(struct ieee80211_supported_band *sband)
+static void handle_band(struct wiphy *wiphy, enum ieee80211_band band)
 {
-	int i;
+	unsigned int i;
+	struct ieee80211_supported_band *sband;
+
+	BUG_ON(!wiphy->bands[band]);
+	sband = wiphy->bands[band];
 
 	for (i = 0; i < sband->n_channels; i++)
-		handle_channel(&sband->channels[i]);
+		handle_channel(wiphy, band, i);
 }
 
 static bool ignore_reg_update(struct wiphy *wiphy, enum reg_set_by setby)
@@ -840,7 +946,7 @@ void wiphy_update_regulatory(struct wiphy *wiphy, enum reg_set_by setby)
 	enum ieee80211_band band;
 	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
 		if (wiphy->bands[band])
-			handle_band(wiphy->bands[band]);
+			handle_band(wiphy, band);
 		if (wiphy->reg_notifier)
 			wiphy->reg_notifier(wiphy, setby);
 	}
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
