From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Wed, 14 Nov 2007 21:51:50 -0500
Message-ID: <20071115025150.GA738@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a few fixes for 2.6.24.  I don't think there is anything
controversial here.

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem/

---

The following changes since commit dbeeb816e805091e7cfc03baf36dc40b4adb2bbd:
  Linus Torvalds (1):
        Linux 2.6.24-rc2

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Helmut Schaa (1):
      mac80211: Fix queuing of scan containing a SSID

Ivo van Doorn (1):
      rt2x00: Fix chipset revision validation

Mohamed Abbas (1):
      iwl3945: place CCK rates in front of OFDM for supported rates

Oliver Neukum (1):
      iwl4965: fix not correctly dealing with hotunplug

 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |   56 ++++++++++--
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h  |   29 +++++-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |  126 +++++++++++++++------------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    8 +-
 drivers/net/wireless/rt2x00/rt2500pci.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2x00.h        |    8 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +-
 net/mac80211/ieee80211_i.h                  |    2 +
 net/mac80211/ieee80211_sta.c                |    8 ++-
 11 files changed, 167 insertions(+), 84 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index 262ab0b..c48b1b5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -71,19 +71,19 @@ struct iwl_rate_scale_priv {
 };
 
 static s32 iwl_expected_tpt_g[IWL_RATE_COUNT] = {
-	0, 0, 76, 104, 130, 168, 191, 202, 7, 13, 35, 58
+	7, 13, 35, 58, 0, 0, 76, 104, 130, 168, 191, 202
 };
 
 static s32 iwl_expected_tpt_g_prot[IWL_RATE_COUNT] = {
-	0, 0, 0, 80, 93, 113, 123, 125, 7, 13, 35, 58
+	7, 13, 35, 58, 0, 0, 0, 80, 93, 113, 123, 125
 };
 
 static s32 iwl_expected_tpt_a[IWL_RATE_COUNT] = {
-	40, 57, 72, 98, 121, 154, 177, 186, 0, 0, 0, 0
+	0, 0, 0, 0, 40, 57, 72, 98, 121, 154, 177, 186
 };
 
 static s32 iwl_expected_tpt_b[IWL_RATE_COUNT] = {
-	0, 0, 0, 0, 0, 0, 0, 0, 7, 13, 35, 58
+	7, 13, 35, 58, 0, 0, 0, 0, 0, 0, 0, 0
 };
 
 struct iwl_tpt_entry {
@@ -350,6 +350,10 @@ static void rs_rate_init(void *priv_rate, void *priv_sta,
 
 	sta->last_txrate = sta->txrate;
 
+	/* For MODE_IEEE80211A mode it start at IWL_FIRST_OFDM_RATE */
+        if (local->hw.conf.phymode == MODE_IEEE80211A)
+                sta->last_txrate += IWL_FIRST_OFDM_RATE;
+
 	IWL_DEBUG_RATE("leave\n");
 }
 
@@ -417,6 +421,33 @@ static void rs_free_sta(void *priv, void *priv_sta)
 	IWL_DEBUG_RATE("leave\n");
 }
 
+
+/*
+ * get ieee prev rate from rate scale table.
+ * for A and B mode we need to overright prev
+ * value
+ */
+static int rs_adjust_next_rate(struct iwl_priv *priv, int rate)
+{
+	int next_rate = iwl_get_prev_ieee_rate(rate);
+
+	switch (priv->phymode) {
+	case MODE_IEEE80211A:
+		if (rate == IWL_RATE_12M_INDEX)
+			next_rate = IWL_RATE_9M_INDEX;
+		else if (rate == IWL_RATE_6M_INDEX)
+			next_rate = IWL_RATE_6M_INDEX;
+		break;
+	case MODE_IEEE80211B:
+		if (rate == IWL_RATE_11M_INDEX_TABLE)
+			next_rate = IWL_RATE_5M_INDEX_TABLE;
+		break;
+	default:
+		break;
+	}
+
+	return next_rate;
+}
 /**
  * rs_tx_status - Update rate control values based on Tx results
  *
@@ -479,7 +510,8 @@ static void rs_tx_status(void *priv_rate,
 			last_index = scale_rate_index;
 		} else {
 			current_count = priv->retry_rate;
-			last_index = iwl_get_prev_ieee_rate(scale_rate_index);
+			last_index = rs_adjust_next_rate(priv,
+							 scale_rate_index);
 		}
 
 		/* Update this rate accounting for as many retries
@@ -494,9 +526,10 @@ static void rs_tx_status(void *priv_rate,
 
 		if (retries)
 			scale_rate_index =
-			    iwl_get_prev_ieee_rate(scale_rate_index);
+			    rs_adjust_next_rate(priv, scale_rate_index);
 	}
 
+
 	/* Update the last index window with success/failure based on ACK */
 	IWL_DEBUG_RATE("Update rate %d with %s.\n",
 		       last_index,
@@ -672,7 +705,10 @@ static struct ieee80211_rate *rs_get_rate(void *priv_rate,
 	}
 
 	rate_mask = sta->supp_rates;
-	index = min(sta->txrate & 0xffff, IWL_RATE_COUNT - 1);
+	index = min(sta->last_txrate & 0xffff, IWL_RATE_COUNT - 1);
+
+	if (priv->phymode == (u8) MODE_IEEE80211A)
+		rate_mask = rate_mask << IWL_FIRST_OFDM_RATE;
 
 	rs_priv = (void *)sta->rate_ctrl_priv;
 
@@ -801,7 +837,11 @@ static struct ieee80211_rate *rs_get_rate(void *priv_rate,
  out:
 
 	sta->last_txrate = index;
-	sta->txrate = sta->last_txrate;
+	if (priv->phymode == (u8) MODE_IEEE80211A)
+		sta->txrate = sta->last_txrate - IWL_FIRST_OFDM_RATE;
+	else
+		sta->txrate = sta->last_txrate;
+
 	sta_info_put(sta);
 
 	IWL_DEBUG_RATE("leave: %d\n", index);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.h b/drivers/net/wireless/iwlwifi/iwl-3945-rs.h
index b926738..bec4d3f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.h
@@ -36,10 +36,17 @@ struct iwl_rate_info {
 	u8 next_rs;		/* next rate used in rs algo */
 	u8 prev_rs_tgg;		/* previous rate used in TGG rs algo */
 	u8 next_rs_tgg;		/* next rate used in TGG rs algo */
+        u8 table_rs_index;	/* index in rate scale table cmd */
+        u8 prev_table_rs;	/* prev in rate table cmd */
+
 };
 
 enum {
-	IWL_RATE_6M_INDEX = 0,
+	IWL_RATE_1M_INDEX = 0,
+	IWL_RATE_2M_INDEX,
+	IWL_RATE_5M_INDEX,
+	IWL_RATE_11M_INDEX,
+	IWL_RATE_6M_INDEX,
 	IWL_RATE_9M_INDEX,
 	IWL_RATE_12M_INDEX,
 	IWL_RATE_18M_INDEX,
@@ -47,16 +54,28 @@ enum {
 	IWL_RATE_36M_INDEX,
 	IWL_RATE_48M_INDEX,
 	IWL_RATE_54M_INDEX,
-	IWL_RATE_1M_INDEX,
-	IWL_RATE_2M_INDEX,
-	IWL_RATE_5M_INDEX,
-	IWL_RATE_11M_INDEX,
 	IWL_RATE_COUNT,
 	IWL_RATE_INVM_INDEX,
 	IWL_RATE_INVALID = IWL_RATE_INVM_INDEX
 };
 
 enum {
+	IWL_RATE_6M_INDEX_TABLE = 0,
+	IWL_RATE_9M_INDEX_TABLE,
+	IWL_RATE_12M_INDEX_TABLE,
+	IWL_RATE_18M_INDEX_TABLE,
+	IWL_RATE_24M_INDEX_TABLE,
+	IWL_RATE_36M_INDEX_TABLE,
+	IWL_RATE_48M_INDEX_TABLE,
+	IWL_RATE_54M_INDEX_TABLE,
+	IWL_RATE_1M_INDEX_TABLE,
+	IWL_RATE_2M_INDEX_TABLE,
+	IWL_RATE_5M_INDEX_TABLE,
+	IWL_RATE_11M_INDEX_TABLE,
+	IWL_RATE_INVM_INDEX_TABLE = IWL_RATE_INVM_INDEX,
+};
+
+enum {
 	IWL_FIRST_OFDM_RATE = IWL_RATE_6M_INDEX,
 	IWL_LAST_OFDM_RATE = IWL_RATE_54M_INDEX,
 	IWL_FIRST_CCK_RATE = IWL_RATE_1M_INDEX,
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 19bcb01..3a45fe9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -54,7 +54,9 @@
 				    IWL_RATE_##rp##M_INDEX, \
 				    IWL_RATE_##rn##M_INDEX, \
 				    IWL_RATE_##pp##M_INDEX, \
-				    IWL_RATE_##np##M_INDEX }
+				    IWL_RATE_##np##M_INDEX, \
+				    IWL_RATE_##r##M_INDEX_TABLE, \
+				    IWL_RATE_##ip##M_INDEX_TABLE }
 
 /*
  * Parameter order:
@@ -65,6 +67,10 @@
  *
  */
 const struct iwl_rate_info iwl_rates[IWL_RATE_COUNT] = {
+	IWL_DECLARE_RATE_INFO(1, INV, 2, INV, 2, INV, 2),    /*  1mbps */
+	IWL_DECLARE_RATE_INFO(2, 1, 5, 1, 5, 1, 5),          /*  2mbps */
+	IWL_DECLARE_RATE_INFO(5, 2, 6, 2, 11, 2, 11),        /*5.5mbps */
+	IWL_DECLARE_RATE_INFO(11, 9, 12, 5, 12, 5, 18),      /* 11mbps */
 	IWL_DECLARE_RATE_INFO(6, 5, 9, 5, 11, 5, 11),        /*  6mbps */
 	IWL_DECLARE_RATE_INFO(9, 6, 11, 5, 11, 5, 11),       /*  9mbps */
 	IWL_DECLARE_RATE_INFO(12, 11, 18, 11, 18, 11, 18),   /* 12mbps */
@@ -73,10 +79,6 @@ const struct iwl_rate_info iwl_rates[IWL_RATE_COUNT] = {
 	IWL_DECLARE_RATE_INFO(36, 24, 48, 24, 48, 24, 48),   /* 36mbps */
 	IWL_DECLARE_RATE_INFO(48, 36, 54, 36, 54, 36, 54),   /* 48mbps */
 	IWL_DECLARE_RATE_INFO(54, 48, INV, 48, INV, 48, INV),/* 54mbps */
-	IWL_DECLARE_RATE_INFO(1, INV, 2, INV, 2, INV, 2),    /*  1mbps */
-	IWL_DECLARE_RATE_INFO(2, 1, 5, 1, 5, 1, 5),          /*  2mbps */
-	IWL_DECLARE_RATE_INFO(5, 2, 6, 2, 11, 2, 11),        /*5.5mbps */
-	IWL_DECLARE_RATE_INFO(11, 9, 12, 5, 12, 5, 18),      /* 11mbps */
 };
 
 /* 1 = enable the iwl_disable_events() function */
@@ -662,10 +664,11 @@ void iwl_hw_build_tx_cmd_rate(struct iwl_priv *priv,
 	cmd->cmd.tx.tx_flags = tx_flags;
 
 	/* OFDM */
-	cmd->cmd.tx.supp_rates[0] = rate_mask & IWL_OFDM_RATES_MASK;
+	cmd->cmd.tx.supp_rates[0] =
+	   ((rate_mask & IWL_OFDM_RATES_MASK) >> IWL_FIRST_OFDM_RATE) & 0xFF;
 
 	/* CCK */
-	cmd->cmd.tx.supp_rates[1] = (rate_mask >> 8) & 0xF;
+	cmd->cmd.tx.supp_rates[1] = (rate_mask & 0xF);
 
 	IWL_DEBUG_RATE("Tx sta id: %d, rate: %d (plcp), flags: 0x%4X "
 		       "cck/ofdm mask: 0x%x/0x%x\n", sta_id,
@@ -1432,7 +1435,7 @@ static void iwl_hw_reg_set_scan_power(struct iwl_priv *priv, u32 scan_tbl_index,
 	/* use this channel group's 6Mbit clipping/saturation pwr,
 	 *   but cap at regulatory scan power restriction (set during init
 	 *   based on eeprom channel data) for this channel.  */
-	power = min(ch_info->scan_power, clip_pwrs[IWL_RATE_6M_INDEX]);
+	power = min(ch_info->scan_power, clip_pwrs[IWL_RATE_6M_INDEX_TABLE]);
 
 	/* further limit to user's max power preference.
 	 * FIXME:  Other spectrum management power limitations do not
@@ -1447,7 +1450,7 @@ static void iwl_hw_reg_set_scan_power(struct iwl_priv *priv, u32 scan_tbl_index,
 	 *   *index*. */
 	power_index = ch_info->power_info[rate_index].power_table_index
 	    - (power - ch_info->power_info
-	       [IWL_RATE_6M_INDEX].requested_power) * 2;
+	       [IWL_RATE_6M_INDEX_TABLE].requested_power) * 2;
 
 	/* store reference index that we use when adjusting *all* scan
 	 *   powers.  So we can accommodate user (all channel) or spectrum
@@ -1476,7 +1479,7 @@ static void iwl_hw_reg_set_scan_power(struct iwl_priv *priv, u32 scan_tbl_index,
  */
 int iwl_hw_reg_send_txpower(struct iwl_priv *priv)
 {
-	int rate_idx;
+	int rate_idx, i;
 	const struct iwl_channel_info *ch_info = NULL;
 	struct iwl_txpowertable_cmd txpower = {
 		.channel = priv->active_rxon.channel,
@@ -1500,20 +1503,36 @@ int iwl_hw_reg_send_txpower(struct iwl_priv *priv)
 	}
 
 	/* fill cmd with power settings for all rates for current channel */
-	for (rate_idx = 0; rate_idx < IWL_RATE_COUNT; rate_idx++) {
-		txpower.power[rate_idx].tpc = ch_info->power_info[rate_idx].tpc;
-		txpower.power[rate_idx].rate = iwl_rates[rate_idx].plcp;
+	/* Fill OFDM rate */
+	for (rate_idx = IWL_FIRST_OFDM_RATE, i = 0;
+	     rate_idx <= IWL_LAST_OFDM_RATE; rate_idx++, i++) {
+
+		txpower.power[i].tpc = ch_info->power_info[i].tpc;
+		txpower.power[i].rate = iwl_rates[rate_idx].plcp;
 
 		IWL_DEBUG_POWER("ch %d:%d rf %d dsp %3d rate code 0x%02x\n",
 				le16_to_cpu(txpower.channel),
 				txpower.band,
-				txpower.power[rate_idx].tpc.tx_gain,
-				txpower.power[rate_idx].tpc.dsp_atten,
-				txpower.power[rate_idx].rate);
+				txpower.power[i].tpc.tx_gain,
+				txpower.power[i].tpc.dsp_atten,
+				txpower.power[i].rate);
+	}
+	/* Fill CCK rates */
+	for (rate_idx = IWL_FIRST_CCK_RATE;
+	     rate_idx <= IWL_LAST_CCK_RATE; rate_idx++, i++) {
+		txpower.power[i].tpc = ch_info->power_info[i].tpc;
+		txpower.power[i].rate = iwl_rates[rate_idx].plcp;
+
+		IWL_DEBUG_POWER("ch %d:%d rf %d dsp %3d rate code 0x%02x\n",
+				le16_to_cpu(txpower.channel),
+				txpower.band,
+				txpower.power[i].tpc.tx_gain,
+				txpower.power[i].tpc.dsp_atten,
+				txpower.power[i].rate);
 	}
 
 	return iwl_send_cmd_pdu(priv, REPLY_TX_PWR_TABLE_CMD,
-				sizeof(struct iwl_txpowertable_cmd), &txpower);
+			sizeof(struct iwl_txpowertable_cmd), &txpower);
 
 }
 
@@ -1549,7 +1568,7 @@ static int iwl_hw_reg_set_new_power(struct iwl_priv *priv,
 	power_info = ch_info->power_info;
 
 	/* update OFDM Txpower settings */
-	for (i = IWL_FIRST_OFDM_RATE; i <= IWL_LAST_OFDM_RATE;
+	for (i = IWL_RATE_6M_INDEX_TABLE; i <= IWL_RATE_54M_INDEX_TABLE;
 	     i++, ++power_info) {
 		int delta_idx;
 
@@ -1573,14 +1592,14 @@ static int iwl_hw_reg_set_new_power(struct iwl_priv *priv,
 	 *    ... all CCK power settings for a given channel are the *same*. */
 	if (power_changed) {
 		power =
-		    ch_info->power_info[IWL_RATE_12M_INDEX].
+		    ch_info->power_info[IWL_RATE_12M_INDEX_TABLE].
 		    requested_power + IWL_CCK_FROM_OFDM_POWER_DIFF;
 
 		/* do all CCK rates' iwl_channel_power_info structures */
-		for (i = IWL_FIRST_CCK_RATE; i <= IWL_LAST_CCK_RATE; i++) {
+		for (i = IWL_RATE_1M_INDEX_TABLE; i <= IWL_RATE_11M_INDEX_TABLE; i++) {
 			power_info->requested_power = power;
 			power_info->base_power_index =
-			    ch_info->power_info[IWL_RATE_12M_INDEX].
+			    ch_info->power_info[IWL_RATE_12M_INDEX_TABLE].
 			    base_power_index + IWL_CCK_FROM_OFDM_INDEX_DIFF;
 			++power_info;
 		}
@@ -1674,7 +1693,7 @@ static int iwl_hw_reg_comp_txpower_temp(struct iwl_priv *priv)
 		for (scan_tbl_index = 0;
 		     scan_tbl_index < IWL_NUM_SCAN_RATES; scan_tbl_index++) {
 			s32 actual_index = (scan_tbl_index == 0) ?
-			    IWL_RATE_1M_INDEX : IWL_RATE_6M_INDEX;
+			    IWL_RATE_1M_INDEX_TABLE : IWL_RATE_6M_INDEX_TABLE;
 			iwl_hw_reg_set_scan_power(priv, scan_tbl_index,
 					   actual_index, clip_pwrs,
 					   ch_info, a_band);
@@ -1905,19 +1924,19 @@ static void iwl_hw_reg_init_channel_groups(struct iwl_priv *priv)
 		for (rate_index = 0;
 		     rate_index < IWL_RATE_COUNT; rate_index++, clip_pwrs++) {
 			switch (rate_index) {
-			case IWL_RATE_36M_INDEX:
+			case IWL_RATE_36M_INDEX_TABLE:
 				if (i == 0)	/* B/G */
 					*clip_pwrs = satur_pwr;
 				else	/* A */
 					*clip_pwrs = satur_pwr - 5;
 				break;
-			case IWL_RATE_48M_INDEX:
+			case IWL_RATE_48M_INDEX_TABLE:
 				if (i == 0)
 					*clip_pwrs = satur_pwr - 7;
 				else
 					*clip_pwrs = satur_pwr - 10;
 				break;
-			case IWL_RATE_54M_INDEX:
+			case IWL_RATE_54M_INDEX_TABLE:
 				if (i == 0)
 					*clip_pwrs = satur_pwr - 9;
 				else
@@ -2031,7 +2050,7 @@ int iwl3945_txpower_set_from_eeprom(struct iwl_priv *priv)
 		}
 
 		/* set tx power for CCK rates, based on OFDM 12 Mbit settings*/
-		pwr_info = &ch_info->power_info[IWL_RATE_12M_INDEX];
+		pwr_info = &ch_info->power_info[IWL_RATE_12M_INDEX_TABLE];
 		power = pwr_info->requested_power +
 			IWL_CCK_FROM_OFDM_POWER_DIFF;
 		pwr_index = pwr_info->power_table_index +
@@ -2047,9 +2066,9 @@ int iwl3945_txpower_set_from_eeprom(struct iwl_priv *priv)
 		/* fill each CCK rate's iwl_channel_power_info structure
 		 * NOTE:  All CCK-rate Txpwrs are the same for a given chnl!
 		 * NOTE:  CCK rates start at end of OFDM rates! */
-		for (rate_index = IWL_OFDM_RATES;
-		     rate_index < IWL_RATE_COUNT; rate_index++) {
-			pwr_info = &ch_info->power_info[rate_index];
+		for (rate_index = 0;
+		     rate_index < IWL_CCK_RATES; rate_index++) {
+			pwr_info = &ch_info->power_info[rate_index+IWL_OFDM_RATES];
 			pwr_info->requested_power = power;
 			pwr_info->power_table_index = pwr_index;
 			pwr_info->base_power_index = base_pwr_index;
@@ -2061,7 +2080,7 @@ int iwl3945_txpower_set_from_eeprom(struct iwl_priv *priv)
 		for (scan_tbl_index = 0;
 		     scan_tbl_index < IWL_NUM_SCAN_RATES; scan_tbl_index++) {
 			s32 actual_index = (scan_tbl_index == 0) ?
-				IWL_RATE_1M_INDEX : IWL_RATE_6M_INDEX;
+				IWL_RATE_1M_INDEX_TABLE : IWL_RATE_6M_INDEX_TABLE;
 			iwl_hw_reg_set_scan_power(priv, scan_tbl_index,
 				actual_index, clip_pwrs, ch_info, a_band);
 		}
@@ -2139,17 +2158,20 @@ int iwl_hw_get_rx_read(struct iwl_priv *priv)
  */
 int iwl3945_init_hw_rate_table(struct iwl_priv *priv)
 {
-	int rc, i;
+	int rc, i, index, prev_index;
 	struct iwl_rate_scaling_cmd rate_cmd = {
 		.reserved = {0, 0, 0},
 	};
 	struct iwl_rate_scaling_info *table = rate_cmd.table;
 
 	for (i = 0; i < ARRAY_SIZE(iwl_rates); i++) {
-		table[i].rate_n_flags =
+		index = iwl_rates[i].table_rs_index;
+
+		table[index].rate_n_flags =
 			iwl_hw_set_rate_n_flags(iwl_rates[i].plcp, 0);
-		table[i].try_cnt = priv->retry_rate;
-		table[i].next_rate_index = iwl_get_prev_ieee_rate(i);
+		table[index].try_cnt = priv->retry_rate;
+		prev_index = iwl_get_prev_ieee_rate(i);
+		table[index].next_rate_index = iwl_rates[prev_index].table_rs_index;
 	}
 
 	switch (priv->phymode) {
@@ -2157,26 +2179,26 @@ int iwl3945_init_hw_rate_table(struct iwl_priv *priv)
 		IWL_DEBUG_RATE("Select A mode rate scale\n");
 		/* If one of the following CCK rates is used,
 		 * have it fall back to the 6M OFDM rate */
-		for (i = IWL_FIRST_CCK_RATE; i <= IWL_LAST_CCK_RATE; i++)
-			table[i].next_rate_index = IWL_FIRST_OFDM_RATE;
+		for (i = IWL_RATE_1M_INDEX_TABLE; i <= IWL_RATE_11M_INDEX_TABLE; i++)
+			table[i].next_rate_index = iwl_rates[IWL_FIRST_OFDM_RATE].table_rs_index;
 
 		/* Don't fall back to CCK rates */
-		table[IWL_RATE_12M_INDEX].next_rate_index = IWL_RATE_9M_INDEX;
+		table[IWL_RATE_12M_INDEX_TABLE].next_rate_index = IWL_RATE_9M_INDEX_TABLE;
 
 		/* Don't drop out of OFDM rates */
-		table[IWL_FIRST_OFDM_RATE].next_rate_index =
-		    IWL_FIRST_OFDM_RATE;
+		table[IWL_RATE_6M_INDEX_TABLE].next_rate_index =
+		    iwl_rates[IWL_FIRST_OFDM_RATE].table_rs_index;
 		break;
 
 	case MODE_IEEE80211B:
 		IWL_DEBUG_RATE("Select B mode rate scale\n");
 		/* If an OFDM rate is used, have it fall back to the
 		 * 1M CCK rates */
-		for (i = IWL_FIRST_OFDM_RATE; i <= IWL_LAST_OFDM_RATE; i++)
-			table[i].next_rate_index = IWL_FIRST_CCK_RATE;
+		for (i = IWL_RATE_6M_INDEX_TABLE; i <= IWL_RATE_54M_INDEX_TABLE; i++)
+			table[i].next_rate_index = iwl_rates[IWL_FIRST_CCK_RATE].table_rs_index;
 
 		/* CCK shouldn't fall back to OFDM... */
-		table[IWL_RATE_11M_INDEX].next_rate_index = IWL_RATE_5M_INDEX;
+		table[IWL_RATE_11M_INDEX_TABLE].next_rate_index = IWL_RATE_5M_INDEX_TABLE;
 		break;
 
 	default:
@@ -2248,22 +2270,12 @@ unsigned int iwl_hw_get_beacon_cmd(struct iwl_priv *priv,
 	tx_beacon_cmd->tx.tx_flags = (TX_CMD_FLG_SEQ_CTL_MSK |
 				      TX_CMD_FLG_TSF_MSK);
 
-	/* supp_rates[0] == OFDM  */
-	tx_beacon_cmd->tx.supp_rates[0] = IWL_OFDM_BASIC_RATES_MASK;
-
-	/* supp_rates[1] == CCK
-	 *
-	 * NOTE:  IWL_*_RATES_MASK are not in the order that supp_rates
-	 * expects so we have to shift them around.
-	 *
-	 * supp_rates expects:
-	 * CCK rates are bit0..3
-	 *
-	 * However IWL_*_RATES_MASK has:
-	 * CCK rates are bit8..11
-	 */
+	/* supp_rates[0] == OFDM start at IWL_FIRST_OFDM_RATE*/
+	tx_beacon_cmd->tx.supp_rates[0] =
+		(IWL_OFDM_BASIC_RATES_MASK >> IWL_FIRST_OFDM_RATE) & 0xFF;
+
 	tx_beacon_cmd->tx.supp_rates[1] =
-		(IWL_CCK_BASIC_RATES_MASK >> 8) & 0xF;
+		(IWL_CCK_BASIC_RATES_MASK & 0xF);
 
 	return (sizeof(struct iwl_tx_beacon_cmd) + frame_size);
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4f22a71..e4ddbc9 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -5331,13 +5331,13 @@ static int iwl_init_geos(struct iwl_priv *priv)
 	/* 5.2GHz channels start after the 2.4GHz channels */
 	modes[A].mode = MODE_IEEE80211A;
 	modes[A].channels = &channels[ARRAY_SIZE(iwl_eeprom_band_1)];
-	modes[A].rates = rates;
+	modes[A].rates = &rates[4];
 	modes[A].num_rates = 8;	/* just OFDM */
 	modes[A].num_channels = 0;
 
 	modes[B].mode = MODE_IEEE80211B;
 	modes[B].channels = channels;
-	modes[B].rates = &rates[8];
+	modes[B].rates = rates;
 	modes[B].num_rates = 4;	/* just CCK */
 	modes[B].num_channels = 0;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index d60adcb..d5107bb 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -5156,9 +5156,10 @@ static irqreturn_t iwl_isr(int irq, void *data)
 	}
 
 	if ((inta == 0xFFFFFFFF) || ((inta & 0xFFFFFFF0) == 0xa5a5a5a0)) {
-		/* Hardware disappeared */
+		/* Hardware disappeared. It might have already raised
+		 * an interrupt */
 		IWL_WARNING("HARDWARE GONE?? INTA == 0x%080x\n", inta);
-		goto none;
+		goto unplugged;
 	}
 
 	IWL_DEBUG_ISR("ISR inta 0x%08x, enabled 0x%08x, fh 0x%08x\n",
@@ -5166,8 +5167,9 @@ static irqreturn_t iwl_isr(int irq, void *data)
 
 	/* iwl_irq_tasklet() will service interrupts and re-enable them */
 	tasklet_schedule(&priv->irq_tasklet);
-	spin_unlock(&priv->lock);
 
+ unplugged:
+	spin_unlock(&priv->lock);
 	return IRQ_HANDLED;
 
  none:
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index ff2d632..702321c 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -620,7 +620,7 @@ static void rt2500pci_link_tuner(struct rt2x00_dev *rt2x00dev)
 	 * up to version C the link tuning should halt after 20
 	 * seconds.
 	 */
-	if (rt2x00_get_rev(&rt2x00dev->chip) < RT2560_VERSION_D &&
+	if (rt2x00_rev(&rt2x00dev->chip) < RT2560_VERSION_D &&
 	    rt2x00dev->link.count > 20)
 		return;
 
@@ -630,7 +630,7 @@ static void rt2500pci_link_tuner(struct rt2x00_dev *rt2x00dev)
 	 * Chipset versions C and lower should directly continue
 	 * to the dynamic CCA tuning.
 	 */
-	if (rt2x00_get_rev(&rt2x00dev->chip) < RT2560_VERSION_D)
+	if (rt2x00_rev(&rt2x00dev->chip) < RT2560_VERSION_D)
 		goto dynamic_cca_tune;
 
 	/*
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 7cdc80a..277a020 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -753,7 +753,7 @@ static int rt2500usb_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field16(&reg, MAC_CSR1_HOST_READY, 1);
 	rt2500usb_register_write(rt2x00dev, MAC_CSR1, reg);
 
-	if (rt2x00_get_rev(&rt2x00dev->chip) >= RT2570_VERSION_C) {
+	if (rt2x00_rev(&rt2x00dev->chip) >= RT2570_VERSION_C) {
 		rt2500usb_register_read(rt2x00dev, PHY_CSR2, &reg);
 		reg &= ~0x0002;
 	} else {
@@ -1257,7 +1257,7 @@ static int rt2500usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	rt2500usb_register_read(rt2x00dev, MAC_CSR0, &reg);
 	rt2x00_set_chip(rt2x00dev, RT2570, value, reg);
 
-	if (rt2x00_rev(&rt2x00dev->chip, 0xffff0)) {
+	if (!rt2x00_check_rev(&rt2x00dev->chip, 0)) {
 		ERROR(rt2x00dev, "Invalid RT chipset detected.\n");
 		return -ENODEV;
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 9845e58..d1ad525 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -751,14 +751,16 @@ static inline char rt2x00_rf(const struct rt2x00_chip *chipset, const u16 chip)
 	return (chipset->rf == chip);
 }
 
-static inline u16 rt2x00_get_rev(const struct rt2x00_chip *chipset)
+static inline u16 rt2x00_rev(const struct rt2x00_chip *chipset)
 {
 	return chipset->rev;
 }
 
-static inline u16 rt2x00_rev(const struct rt2x00_chip *chipset, const u32 mask)
+static inline u16 rt2x00_check_rev(const struct rt2x00_chip *chipset,
+				   const u32 rev)
 {
-	return chipset->rev & mask;
+	return (((chipset->rev & 0xffff0) == rev) &&
+		!!(chipset->rev & 0x0000f));
 }
 
 /*
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 46c8c08..dc640bf 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1486,7 +1486,7 @@ static int rt73usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 	rt73usb_register_read(rt2x00dev, MAC_CSR0, &reg);
 	rt2x00_set_chip(rt2x00dev, RT2571, value, reg);
 
-	if (!rt2x00_rev(&rt2x00dev->chip, 0x25730)) {
+	if (!rt2x00_check_rev(&rt2x00dev->chip, 0x25730)) {
 		ERROR(rt2x00dev, "Invalid RT chipset detected.\n");
 		return -ENODEV;
 	}
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 4b4ed2a..d575ccd 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -241,6 +241,8 @@ struct ieee80211_if_sta {
 	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	size_t ssid_len;
+	u8 scan_ssid[IEEE80211_MAX_SSID_LEN];
+	size_t scan_ssid_len;
 	u16 aid;
 	u16 ap_capab, capab;
 	u8 *extra_ie; /* to be added to the end of AssocReq */
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index fda0e06..fc6a3ff 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -1998,7 +1998,10 @@ void ieee80211_sta_work(struct work_struct *work)
 	if (ifsta->state != IEEE80211_AUTHENTICATE &&
 	    ifsta->state != IEEE80211_ASSOCIATE &&
 	    test_and_clear_bit(IEEE80211_STA_REQ_SCAN, &ifsta->request)) {
-		ieee80211_sta_start_scan(dev, NULL, 0);
+		if (ifsta->scan_ssid_len)
+			ieee80211_sta_start_scan(dev, ifsta->scan_ssid, ifsta->scan_ssid_len);
+		else
+			ieee80211_sta_start_scan(dev, NULL, 0);
 		return;
 	}
 
@@ -2868,6 +2871,9 @@ int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 		return -EBUSY;
 	}
 
+	ifsta->scan_ssid_len = ssid_len;
+	if (ssid_len)
+		memcpy(ifsta->scan_ssid, ssid, ssid_len);
 	set_bit(IEEE80211_STA_REQ_SCAN, &ifsta->request);
 	queue_work(local->hw.workqueue, &ifsta->work);
 	return 0;
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
