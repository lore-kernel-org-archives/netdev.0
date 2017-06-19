From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] rtlwifi: Use temporary ops variable to reduce code size
Date: Mon, 19 Jun 2017 13:18:14 -0700
Message-ID: <bb0fa76d17f2e49dc7f8054a91c0383db2f66634.1497903396.git.joe@perches.com>
References: <cover.1497903396.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1497903396.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtlpriv->cfg->ops-><fn> is used frequently in the source.

Repeated use of this multiply dereferenced table creates larger objects.

Using a temporary reduces code size as well as source code line length.

$ size -t drivers/net/wireless/realtek/rtlwifi/*.o.defconfig.new
   text	   data	    bss	    dec	    hex	filename
  12652	   3024	     24	  15700	   3d54	[...]/base.o.defconfig.new
  16700	     83	      0	  16783	   418f	[...]/core.o.defconfig.new
  10794	      0	      4	  10798	   2a2e	[...]/efuse.o.defconfig.new
  20988	      5	      0	  20993	   5201	[...]/pci.o.defconfig.new
   6182	      8	      0	   6190	   182e	[...]/ps.o.defconfig.new
   8410	      1	      4	   8415	   20df	[...]/usb.o.defconfig.new
  75726	   3121	     32	  78879	  1341f	(TOTALS)

$ size -t drivers/net/wireless/realtek/rtlwifi/*.o.defconfig.old
   text	   data	    bss	    dec	    hex	filename
  12604	   3024	     24	  15652	   3d24	[...]/base.o.defconfig.old
  16892	     83	      0	  16975	   424f	[...]/core.o.defconfig.old
  10794	      0	      4	  10798	   2a2e	[...]/efuse.o.defconfig.old
  21161	      5	      0	  21166	   52ae	[...]/pci.o.defconfig.old
   6262	      8	      0	   6270	   187e	[...]/ps.o.defconfig.old
   8435	      1	      4	   8440	   20f8	[...]/usb.o.defconfig.old
  76148	   3121	     32	  79301	  135c5	(TOTALS)

Miscellanea around modified code:

o Fix a few misindented code blocks
o Realign arguments
o Ignored 80 column checkpatch warnings

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/base.c  |  45 ++---
 drivers/net/wireless/realtek/rtlwifi/core.c  | 187 +++++++++++----------
 drivers/net/wireless/realtek/rtlwifi/efuse.c |   9 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c   | 236 ++++++++++++++-------------
 drivers/net/wireless/realtek/rtlwifi/ps.c    |  75 +++++----
 drivers/net/wireless/realtek/rtlwifi/usb.c   |  40 +++--
 6 files changed, 313 insertions(+), 279 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/base.c b/drivers/net/wireless/realtek/rtlwifi/base.c
index 710e5b447cff..4436addcace3 100644
--- a/drivers/net/wireless/realtek/rtlwifi/base.c
+++ b/drivers/net/wireless/realtek/rtlwifi/base.c
@@ -498,7 +498,7 @@ EXPORT_SYMBOL_GPL(rtl_deinit_deferred_work);
 void rtl_init_rfkill(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	bool radio_state;
 	bool blocked;
 	u8 valid = 0;
@@ -507,7 +507,7 @@ void rtl_init_rfkill(struct ieee80211_hw *hw)
 	rtlpriv->rfkill.rfkill_state = true;
 	wiphy_rfkill_set_hw_state(hw->wiphy, 0);
 
-	radio_state = rtlpriv->cfg->ops->radio_onoff_checking(hw, &valid);
+	radio_state = ops->radio_onoff_checking(hw, &valid);
 
 	if (valid) {
 		pr_info("rtlwifi: wireless switch is %s\n",
@@ -588,8 +588,9 @@ void rtl_init_rx_config(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
-	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RCR, (u8 *) (&mac->rx_conf));
+	ops->get_hw_reg(hw, HW_VAR_RCR, (u8 *)&mac->rx_conf);
 }
 EXPORT_SYMBOL_GPL(rtl_init_rx_config);
 
@@ -1178,13 +1179,14 @@ bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb)
 {
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	__le16 fc = rtl_get_fc(skb);
 
 	if (rtlpriv->dm.supp_phymode_switch &&
 	    mac->link_state < MAC80211_LINKED &&
 	    (ieee80211_is_auth(fc) || ieee80211_is_probe_req(fc))) {
-		if (rtlpriv->cfg->ops->chk_switch_dmdp)
-			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+		if (ops->chk_switch_dmdp)
+			ops->chk_switch_dmdp(hw);
 	}
 	if (ieee80211_is_auth(fc)) {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
@@ -1309,11 +1311,12 @@ EXPORT_SYMBOL_GPL(rtl_action_proc);
 static void setup_arp_tx(struct rtl_priv *rtlpriv, struct rtl_ps_ctl *ppsc)
 {
 	struct ieee80211_hw *hw = rtlpriv->hw;
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
 	rtlpriv->ra.is_special_data = true;
-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_special_packet_notify(
-					rtlpriv, 1);
+			rtlpriv, 1);
 	rtl_lps_leave(hw);
 	ppsc->last_delaylps_stamp_jiffies = jiffies;
 }
@@ -1571,6 +1574,7 @@ void rtl_watchdog_wq_callback(void *data)
 							    watchdog_wq);
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	bool busytraffic = false;
@@ -1683,7 +1687,7 @@ void rtl_watchdog_wq_callback(void *data)
 
 	/* <3> DM */
 	if (!rtlpriv->cfg->mod_params->disable_watchdog)
-		rtlpriv->cfg->ops->dm_watchdog(hw);
+		ops->dm_watchdog(hw);
 
 	/* <4> roaming */
 	if (mac->link_state == MAC80211_LINKED &&
@@ -1709,7 +1713,7 @@ void rtl_watchdog_wq_callback(void *data)
 		}
 	}
 
-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);
 
 	rtlpriv->link_info.bcn_rx_inperiod = 0;
@@ -1732,8 +1736,9 @@ void rtl_fwevt_wq_callback(void *data)
 		container_of_dwork_rtl(data, struct rtl_works, fwevt_wq);
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
-	rtlpriv->cfg->ops->c2h_command_handle(hw);
+	ops->c2h_command_handle(hw);
 }
 
 void rtl_c2hcmd_enqueue(struct ieee80211_hw *hw, u8 tag, u8 len, u8 *val)
@@ -1783,6 +1788,7 @@ EXPORT_SYMBOL(rtl_c2hcmd_enqueue);
 void rtl_c2hcmd_launcher(struct ieee80211_hw *hw, int exec)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	unsigned long flags;
 	struct rtl_c2hcmd *c2hcmd;
 	int i;
@@ -1803,9 +1809,9 @@ void rtl_c2hcmd_launcher(struct ieee80211_hw *hw, int exec)
 		if (!c2hcmd)
 			break;
 
-		if (rtlpriv->cfg->ops->c2h_content_parsing && exec)
-			rtlpriv->cfg->ops->c2h_content_parsing(hw,
-					c2hcmd->tag, c2hcmd->len, c2hcmd->val);
+		if (ops->c2h_content_parsing && exec)
+			ops->c2h_content_parsing(hw, c2hcmd->tag, c2hcmd->len,
+						 c2hcmd->val);
 
 		/* free */
 		kfree(c2hcmd->val);
@@ -1828,12 +1834,13 @@ void rtl_easy_concurrent_retrytimer_callback(unsigned long data)
 {
 	struct ieee80211_hw *hw = (struct ieee80211_hw *)data;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_priv *buddy_priv = rtlpriv->buddy_priv;
 
 	if (buddy_priv == NULL)
 		return;
 
-	rtlpriv->cfg->ops->dualmac_easy_concurrent(hw);
+	ops->dualmac_easy_concurrent(hw);
 }
 /*********************************************************
  *
@@ -1944,7 +1951,6 @@ int rtl_send_smps_action(struct ieee80211_hw *hw,
 		struct rtl_sta_info *sta_entry =
 			(struct rtl_sta_info *) sta->drv_priv;
 		sta_entry->mimo_ps = smps;
-		/* rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0); */
 
 		info->control.rates[0].idx = 0;
 		info->band = hw->conf.chandef.chan->band;
@@ -1960,6 +1966,7 @@ EXPORT_SYMBOL(rtl_send_smps_action);
 void rtl_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	enum io_type iotype;
 
@@ -1967,15 +1974,11 @@ void rtl_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
 		switch (operation) {
 		case SCAN_OPT_BACKUP:
 			iotype = IO_CMD_PAUSE_DM_BY_SCAN;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_IO_CMD,
-						      (u8 *)&iotype);
+			ops->set_hw_reg(hw, HW_VAR_IO_CMD, (u8 *)&iotype);
 			break;
 		case SCAN_OPT_RESTORE:
 			iotype = IO_CMD_RESUME_DM_BY_SCAN;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_IO_CMD,
-						      (u8 *)&iotype);
+			ops->set_hw_reg(hw, HW_VAR_IO_CMD, (u8 *)&iotype);
 			break;
 		default:
 			pr_err("Unknown Scan Backup operation.\n");
diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index a4f8e326a2bc..63f5c0cd6935 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -168,6 +168,7 @@ static int rtl_op_start(struct ieee80211_hw *hw)
 static void rtl_op_stop(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -176,8 +177,7 @@ static void rtl_op_stop(struct ieee80211_hw *hw)
 	if (is_hal_stop(rtlhal))
 		return;
 
-	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
-				      (u8 *)(&support_remote_wakeup));
+	ops->get_hw_reg(hw, HAL_DEF_WOWLAN, (u8 *)(&support_remote_wakeup));
 	/* here is must, because adhoc do stop and start,
 	 * but stop with RFOFF may cause something wrong,
 	 * like adhoc TP
@@ -231,6 +231,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		struct ieee80211_vif *vif)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	int err = 0;
 	u8 retry_limit = 0x30;
@@ -255,8 +256,8 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 				 "NL80211_IFTYPE_STATION\n");
 			mac->beacon_enabled = 0;
-			rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
-					rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
+			ops->update_interrupt_mask(hw, 0,
+						   rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
 		}
 		break;
 	case NL80211_IFTYPE_ADHOC:
@@ -264,12 +265,12 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 			 "NL80211_IFTYPE_ADHOC\n");
 
 		mac->link_state = MAC80211_LINKED;
-		rtlpriv->cfg->ops->set_bcn_reg(hw);
+		ops->set_bcn_reg(hw);
 		if (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G)
 			mac->basic_rates = 0xfff;
 		else
 			mac->basic_rates = 0xff0;
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+		ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
 				(u8 *)(&mac->basic_rates));
 
 		retry_limit = 0x07;
@@ -282,13 +283,13 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 			 "NL80211_IFTYPE_AP\n");
 
 		mac->link_state = MAC80211_LINKED;
-		rtlpriv->cfg->ops->set_bcn_reg(hw);
+		ops->set_bcn_reg(hw);
 		if (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G)
 			mac->basic_rates = 0xfff;
 		else
 			mac->basic_rates = 0xff0;
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
-					      (u8 *)(&mac->basic_rates));
+		ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+				(u8 *)(&mac->basic_rates));
 
 		retry_limit = 0x07;
 		break;
@@ -297,12 +298,12 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 			 "NL80211_IFTYPE_MESH_POINT\n");
 
 		mac->link_state = MAC80211_LINKED;
-		rtlpriv->cfg->ops->set_bcn_reg(hw);
+		ops->set_bcn_reg(hw);
 		if (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G)
 			mac->basic_rates = 0xfff;
 		else
 			mac->basic_rates = 0xff0;
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+		ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
 				(u8 *)(&mac->basic_rates));
 
 		retry_limit = 0x07;
@@ -318,19 +319,18 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 			 "p2p role %x\n", vif->type);
 		mac->basic_rates = 0xff0;/*disable cck rate for p2p*/
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+		ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
 				(u8 *)(&mac->basic_rates));
 	}
 	mac->vif = vif;
 	mac->opmode = vif->type;
-	rtlpriv->cfg->ops->set_network_type(hw, vif->type);
+	ops->set_network_type(hw, vif->type);
 	memcpy(mac->mac_addr, vif->addr, ETH_ALEN);
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR, mac->mac_addr);
+	ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR, mac->mac_addr);
 
 	mac->retry_long = retry_limit;
 	mac->retry_short = retry_limit;
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
-			(u8 *)(&retry_limit));
+	ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT, (u8 *)(&retry_limit));
 out:
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 	return err;
@@ -340,6 +340,7 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 		struct ieee80211_vif *vif)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
@@ -350,8 +351,8 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	    (vif->type == NL80211_IFTYPE_MESH_POINT)) {
 		if (mac->beacon_enabled == 1) {
 			mac->beacon_enabled = 0;
-			rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
-					rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
+			ops->update_interrupt_mask(hw, 0,
+						   rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
 		}
 	}
 
@@ -365,7 +366,7 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	eth_zero_addr(mac->bssid);
 	mac->vendor = PEER_UNKNOWN;
 	mac->opmode = NL80211_IFTYPE_UNSPECIFIED;
-	rtlpriv->cfg->ops->set_network_type(hw, mac->opmode);
+	ops->set_network_type(hw, mac->opmode);
 
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 }
@@ -438,6 +439,7 @@ static void _rtl_add_wowlan_patterns(struct ieee80211_hw *hw,
 				     struct cfg80211_wowlan *wow)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = &rtlpriv->mac80211;
 	struct cfg80211_pkt_pattern *patterns = wow->patterns;
 	struct rtl_wow_pattern rtl_pattern;
@@ -538,7 +540,7 @@ static void _rtl_add_wowlan_patterns(struct ieee80211_hw *hw,
 			 "CRC_Remainder = 0x%x\n", rtl_pattern.crc);
 
 		/* 4. write crc & mask_for_hw to hw */
-		rtlpriv->cfg->ops->add_wowlan_pattern(hw, &rtl_pattern, i);
+		ops->add_wowlan_pattern(hw, &rtl_pattern, i);
 	}
 	rtl_write_byte(rtlpriv, 0x698, wow->n_patterns);
 }
@@ -599,6 +601,7 @@ static int rtl_op_resume(struct ieee80211_hw *hw)
 static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -661,8 +664,8 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		if (changed != ~0) {
 			mac->retry_long = hw->conf.long_frame_max_tx_count;
 			mac->retry_short = hw->conf.long_frame_max_tx_count;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
-				(u8 *)(&hw->conf.long_frame_max_tx_count));
+			ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
+					(u8 *)&hw->conf.long_frame_max_tx_count);
 		}
 	}
 
@@ -683,8 +686,8 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		if (rtlpriv->dm.supp_phymode_switch &&
 			mac->link_state < MAC80211_LINKED &&
 			!mac->act_scanning) {
-			if (rtlpriv->cfg->ops->chk_switch_dmdp)
-				rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+			if (ops->chk_switch_dmdp)
+				ops->chk_switch_dmdp(hw);
 		}
 
 		/*
@@ -802,9 +805,9 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 
 		rtlphy->current_channel = wide_chan;
 
-		rtlpriv->cfg->ops->switch_channel(hw);
-		rtlpriv->cfg->ops->set_channel_access(hw);
-		rtlpriv->cfg->ops->set_bw_mode(hw, channel_type);
+		ops->switch_channel(hw);
+		ops->set_channel_access(hw);
+		ops->set_bw_mode(hw, channel_type);
 	}
 
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
@@ -818,6 +821,7 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 {
 	bool update_rcr = false;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	*new_flags &= RTL_SUPPORTED_FILTERS;
@@ -863,9 +867,9 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 		if (mac->opmode != NL80211_IFTYPE_AP &&
 		    mac->opmode != NL80211_IFTYPE_MESH_POINT) {
 			if (*new_flags & FIF_BCN_PRBRESP_PROMISC)
-				rtlpriv->cfg->ops->set_chk_bssid(hw, false);
+				ops->set_chk_bssid(hw, false);
 			else
-				rtlpriv->cfg->ops->set_chk_bssid(hw, true);
+				ops->set_chk_bssid(hw, true);
 			if (update_rcr)
 				update_rcr = false;
 		}
@@ -901,14 +905,15 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 	}
 
 	if (update_rcr)
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
-					      (u8 *)(&mac->rx_conf));
+		ops->set_hw_reg(hw, HW_VAR_RCR,
+				(u8 *)(&mac->rx_conf));
 }
 static int rtl_op_sta_add(struct ieee80211_hw *hw,
 			 struct ieee80211_vif *vif,
 			 struct ieee80211_sta *sta)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_sta_info *sta_entry;
@@ -944,7 +949,7 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 		memcpy(sta_entry->mac_addr, sta->addr, ETH_ALEN);
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 			"Add sta addr is %pM\n", sta->addr);
-		rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
+		ops->update_rate_tbl(hw, sta, 0);
 	}
 
 	return 0;
@@ -1001,6 +1006,7 @@ static int rtl_op_conf_tx(struct ieee80211_hw *hw,
 			  const struct ieee80211_tx_queue_params *param)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	int aci;
 
@@ -1016,7 +1022,7 @@ static int rtl_op_conf_tx(struct ieee80211_hw *hw,
 	mac->ac[aci].cw_max = cpu_to_le16(param->cw_max);
 	mac->ac[aci].tx_op = cpu_to_le16(param->txop);
 	memcpy(&mac->edca_param[aci], param, sizeof(*param));
-	rtlpriv->cfg->ops->set_qos(hw, aci);
+	ops->set_qos(hw, aci);
 	return 0;
 }
 
@@ -1039,6 +1045,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				    u32 changed)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -1055,14 +1062,14 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 					 "BSS_CHANGED_BEACON_ENABLED\n");
 
 				/*start hw beacon interrupt. */
-				/*rtlpriv->cfg->ops->set_bcn_reg(hw); */
+				/*ops->set_bcn_reg(hw); */
 				mac->beacon_enabled = 1;
-				rtlpriv->cfg->ops->update_interrupt_mask(hw,
-						rtlpriv->cfg->maps
-						[RTL_IBSS_INT_MASKS], 0);
+				ops->update_interrupt_mask(hw,
+							   rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS],
+							   0);
 
-				if (rtlpriv->cfg->ops->linked_set_reg)
-					rtlpriv->cfg->ops->linked_set_reg(hw);
+				if (ops->linked_set_reg)
+					ops->linked_set_reg(hw);
 				send_beacon_frame(hw, vif);
 			}
 		}
@@ -1073,16 +1080,15 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 					 "ADHOC DISABLE BEACON\n");
 
 				mac->beacon_enabled = 0;
-				rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
-						rtlpriv->cfg->maps
-						[RTL_IBSS_INT_MASKS]);
+				ops->update_interrupt_mask(hw, 0,
+							   rtlpriv->cfg->maps[RTL_IBSS_INT_MASKS]);
 			}
 		}
 		if (changed & BSS_CHANGED_BEACON_INT) {
 			RT_TRACE(rtlpriv, COMP_BEACON, DBG_TRACE,
 				 "BSS_CHANGED_BEACON_INT\n");
 			mac->beacon_interval = bss_conf->beacon_int;
-			rtlpriv->cfg->ops->set_bcn_intv(hw);
+			ops->set_bcn_intv(hw);
 		}
 	}
 
@@ -1109,8 +1115,8 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			mac->assoc_id = bss_conf->aid;
 			memcpy(mac->bssid, bss_conf->bssid, ETH_ALEN);
 
-			if (rtlpriv->cfg->ops->linked_set_reg)
-				rtlpriv->cfg->ops->linked_set_reg(hw);
+			if (ops->linked_set_reg)
+				ops->linked_set_reg(hw);
 
 			rcu_read_lock();
 			sta = ieee80211_find_sta(vif, (u8 *)bss_conf->bssid);
@@ -1150,13 +1156,12 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			}
 
 			if (vif->type == NL80211_IFTYPE_STATION)
-				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
+				ops->update_rate_tbl(hw, sta, 0);
 			rcu_read_unlock();
 
 			/* to avoid AP Disassociation caused by inactivity */
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_KEEP_ALIVE,
-						      (u8 *)(&keep_alive));
+			ops->set_hw_reg(hw, HW_VAR_KEEP_ALIVE,
+					(u8 *)(&keep_alive));
 
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_ASSOC\n");
@@ -1173,25 +1178,23 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			mac->mode = 0;
 
 			if (rtlpriv->dm.supp_phymode_switch) {
-				if (rtlpriv->cfg->ops->chk_switch_dmdp)
-					rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+				if (ops->chk_switch_dmdp)
+					ops->chk_switch_dmdp(hw);
 			}
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_UN_ASSOC\n");
 		}
-		rtlpriv->cfg->ops->set_network_type(hw, vif->type);
+		ops->set_network_type(hw, vif->type);
 		/* For FW LPS:
 		 * To tell firmware we have connected or disconnected
 		 */
-		rtlpriv->cfg->ops->set_hw_reg(hw,
-					      HW_VAR_H2C_FW_JOINBSSRPT,
-					      (u8 *)(&mstatus));
+		ops->set_hw_reg(hw, HW_VAR_H2C_FW_JOINBSSRPT, (u8 *)(&mstatus));
 		ppsc->report_linked = (mstatus == RT_MEDIA_CONNECT) ?
 				      true : false;
 
-		if (rtlpriv->cfg->ops->get_btc_status())
+		if (ops->get_btc_status())
 			rtlpriv->btcoexist.btc_ops->btc_mediastatus_notify(
-							rtlpriv, mstatus);
+				rtlpriv, mstatus);
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
@@ -1206,8 +1209,8 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			  bss_conf->use_short_preamble);
 
 		mac->short_preamble = bss_conf->use_short_preamble;
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACK_PREAMBLE,
-					      (u8 *)(&mac->short_preamble));
+		ops->set_hw_reg(hw, HW_VAR_ACK_PREAMBLE,
+				(u8 *)(&mac->short_preamble));
 	}
 
 	if (changed & BSS_CHANGED_ERP_SLOT) {
@@ -1219,8 +1222,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		else
 			mac->slot_time = RTL_SLOT_TIME_20;
 
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-					      (u8 *)(&mac->slot_time));
+		ops->set_hw_reg(hw, HW_VAR_SLOT_TIME, (u8 *)(&mac->slot_time));
 	}
 
 	if (changed & BSS_CHANGED_HT) {
@@ -1243,20 +1245,19 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		}
 		rcu_read_unlock();
 
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SHORTGI_DENSITY,
-					      (u8 *)(&mac->max_mss_density));
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AMPDU_FACTOR,
-					      &mac->current_ampdu_factor);
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AMPDU_MIN_SPACE,
-					      &mac->current_ampdu_density);
+		ops->set_hw_reg(hw, HW_VAR_SHORTGI_DENSITY,
+				(u8 *)(&mac->max_mss_density));
+		ops->set_hw_reg(hw, HW_VAR_AMPDU_FACTOR,
+				&mac->current_ampdu_factor);
+		ops->set_hw_reg(hw, HW_VAR_AMPDU_MIN_SPACE,
+				&mac->current_ampdu_density);
 	}
 
 	if (changed & BSS_CHANGED_BSSID) {
 		u32 basic_rates;
 		struct ieee80211_sta *sta = NULL;
 
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BSSID,
-					      (u8 *)bss_conf->bssid);
+		ops->set_hw_reg(hw, HW_VAR_BSSID, (u8 *)bss_conf->bssid);
 
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 			 "bssid: %pM\n", bss_conf->bssid);
@@ -1325,7 +1326,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				basic_rates = sta->supp_rates[0];
 
 			mac->basic_rates = basic_rates;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+			ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
 					(u8 *)(&basic_rates));
 		}
 		rcu_read_unlock();
@@ -1337,9 +1338,10 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 static u64 rtl_op_get_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	u64 tsf;
 
-	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *)(&tsf));
+	ops->get_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *)(&tsf));
 	return tsf;
 }
 
@@ -1347,19 +1349,21 @@ static void rtl_op_set_tsf(struct ieee80211_hw *hw,
 			   struct ieee80211_vif *vif, u64 tsf)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u8 bibss = (mac->opmode == NL80211_IFTYPE_ADHOC) ? 1 : 0;
 
 	mac->tsf = tsf;
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *)(&bibss));
+	ops->set_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *)(&bibss));
 }
 
 static void rtl_op_reset_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	u8 tmp = 0;
 
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_DUAL_TSF_RST, (u8 *)(&tmp));
+	ops->set_hw_reg(hw, HW_VAR_DUAL_TSF_RST, (u8 *)(&tmp));
 }
 
 static void rtl_op_sta_notify(struct ieee80211_hw *hw,
@@ -1423,6 +1427,7 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 				 const u8 *mac_addr)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
@@ -1432,12 +1437,12 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 		return;
 	}
 
-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 1);
 
 	if (rtlpriv->dm.supp_phymode_switch) {
-		if (rtlpriv->cfg->ops->chk_switch_dmdp)
-			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+		if (ops->chk_switch_dmdp)
+			ops->chk_switch_dmdp(hw);
 	}
 
 	if (mac->link_state == MAC80211_LINKED) {
@@ -1450,14 +1455,15 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw,
 	/* Dul mac */
 	rtlpriv->rtlhal.load_imrandiqk_setting_for2g = false;
 
-	rtlpriv->cfg->ops->led_control(hw, LED_CTL_SITE_SURVEY);
-	rtlpriv->cfg->ops->scan_operation_backup(hw, SCAN_OPT_BACKUP_BAND0);
+	ops->led_control(hw, LED_CTL_SITE_SURVEY);
+	ops->scan_operation_backup(hw, SCAN_OPT_BACKUP_BAND0);
 }
 
 static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw,
 				    struct ieee80211_vif *vif)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
@@ -1479,12 +1485,12 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw,
 		mac->link_state = MAC80211_LINKED;
 		if (mac->opmode == NL80211_IFTYPE_STATION) {
 			/* fix fwlps issue */
-			rtlpriv->cfg->ops->set_network_type(hw, mac->opmode);
+			ops->set_network_type(hw, mac->opmode);
 		}
 	}
 
-	rtlpriv->cfg->ops->scan_operation_backup(hw, SCAN_OPT_RESTORE);
-	if (rtlpriv->cfg->ops->get_btc_status())
+	ops->scan_operation_backup(hw, SCAN_OPT_RESTORE);
+	if (ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_scan_notify(rtlpriv, 0);
 }
 
@@ -1493,6 +1499,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			  struct ieee80211_key_conf *key)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	u8 key_type = NO_ENCRYPTION;
 	u8 key_idx;
 	bool group_key = false;
@@ -1579,7 +1586,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			key_type == WEP104_ENCRYPTION) {
 			if (group_key)
 				wep_only = true;
-			rtlpriv->cfg->ops->enable_hw_sec(hw);
+			ops->enable_hw_sec(hw);
 		}
 	} else {
 		if ((!group_key) || (vif->type == NL80211_IFTYPE_ADHOC) ||
@@ -1593,7 +1600,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "set enable_hw_sec, key_type:%x(OPEN:0 WEP40:1 TKIP:2 AES:4 WEP104:5)\n",
 				 key_type);
-			rtlpriv->cfg->ops->enable_hw_sec(hw);
+			ops->enable_hw_sec(hw);
 		}
 	}
 	/* <4> set key based on cmd */
@@ -1640,9 +1647,9 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			    rtlpriv->sec.key_buf[PAIRWISE_KEYIDX];
 			memcpy(mac_addr, sta->addr, ETH_ALEN);
 		}
-		rtlpriv->cfg->ops->set_key(hw, key_idx, mac_addr,
-					   group_key, key_type, wep_only,
-					   false);
+		ops->set_key(hw, key_idx, mac_addr,
+			     group_key, key_type, wep_only,
+			     false);
 		/* <5> tell mac80211 do something: */
 		/*must use sw generate IV, or can not work !!!!. */
 		key->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
@@ -1684,6 +1691,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 static void rtl_op_rfkill_poll(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
 	bool radio_state;
 	bool blocked;
@@ -1695,7 +1703,7 @@ static void rtl_op_rfkill_poll(struct ieee80211_hw *hw)
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 
 	/*if Radio On return true here */
-	radio_state = rtlpriv->cfg->ops->radio_onoff_checking(hw, &valid);
+	radio_state = ops->radio_onoff_checking(hw, &valid);
 
 	if (valid) {
 		if (unlikely(radio_state != rtlpriv->rfkill.rfkill_state)) {
@@ -1829,6 +1837,7 @@ EXPORT_SYMBOL(rtl_hal_pwrseqcmdparsing);
 bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring;
 	struct rtl_tx_desc *pdesc;
@@ -1845,13 +1854,13 @@ bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb)
 	/*this is wrong, fill_tx_cmddesc needs update*/
 	pdesc = &ring->desc[0];
 
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
+	ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
 
 	__skb_queue_tail(&ring->queue, skb);
 
 	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
+	ops->tx_polling(hw, BEACON_QUEUE);
 
 	return true;
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/efuse.c b/drivers/net/wireless/realtek/rtlwifi/efuse.c
index ef9acd466cca..7d5eb55031cf 100644
--- a/drivers/net/wireless/realtek/rtlwifi/efuse.c
+++ b/drivers/net/wireless/realtek/rtlwifi/efuse.c
@@ -229,6 +229,7 @@ EXPORT_SYMBOL_GPL(read_efuse_byte);
 void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 *efuse_tbl;
 	u8 rtemp8[1];
@@ -365,10 +366,10 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	rtlefuse->efuse_usedbytes = efuse_utilized;
 	efuse_usage = (u8) ((efuse_utilized * 100) / efuse_len);
 	rtlefuse->efuse_usedpercentage = efuse_usage;
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_EFUSE_BYTES,
-				      (u8 *)&efuse_utilized);
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_EFUSE_USAGE,
-				      &efuse_usage);
+	ops->set_hw_reg(hw, HW_VAR_EFUSE_BYTES,
+			(u8 *)&efuse_utilized);
+	ops->set_hw_reg(hw, HW_VAR_EFUSE_USAGE,
+			&efuse_usage);
 done:
 	for (i = 0; i < EFUSE_MAX_WORD_UNIT; i++)
 		kfree(efuse_word[i]);
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index 0c1f8307e179..81c36978df8a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -556,6 +556,7 @@ static void _rtl_pci_tx_chk_waitq(struct ieee80211_hw *hw)
 static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[prio];
@@ -572,22 +573,21 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 		else
 			entry = (u8 *)(&ring->desc[ring->idx]);
 
-		if (rtlpriv->cfg->ops->get_available_desc &&
-		    rtlpriv->cfg->ops->get_available_desc(hw, prio) <= 1) {
+		if (ops->get_available_desc &&
+		    ops->get_available_desc(hw, prio) <= 1) {
 			RT_TRACE(rtlpriv, (COMP_INTR | COMP_SEND), DBG_DMESG,
 				 "no available desc!\n");
 			return;
 		}
 
-		if (!rtlpriv->cfg->ops->is_tx_desc_closed(hw, prio, ring->idx))
+		if (!ops->is_tx_desc_closed(hw, prio, ring->idx))
 			return;
 		ring->idx = (ring->idx + 1) % ring->entries;
 
 		skb = __skb_dequeue(&ring->queue);
 		pci_unmap_single(rtlpci->pdev,
-				 rtlpriv->cfg->ops->
-					     get_desc((u8 *)entry, true,
-						      HW_DESC_TXBUFF_ADDR),
+				 ops->get_desc((u8 *)entry, true,
+					       HW_DESC_TXBUFF_ADDR),
 				 skb->len, PCI_DMA_TODEVICE);
 
 		/* remove early mode header */
@@ -668,6 +668,7 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 				    int rxring_idx, int desc_idx)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	u32 bufferaddress;
 	u8 tmp_one = 1;
@@ -691,19 +692,19 @@ static int _rtl_pci_init_one_rxdesc(struct ieee80211_hw *hw,
 		return 0;
 	rtlpci->rx_ring[rxring_idx].rx_buf[desc_idx] = skb;
 	if (rtlpriv->use_new_trx_flow) {
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-					    HW_DESC_RX_PREPARE,
-					    (u8 *)&bufferaddress);
+		ops->set_desc(hw, (u8 *)entry, false,
+			      HW_DESC_RX_PREPARE,
+			      (u8 *)&bufferaddress);
 	} else {
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-					    HW_DESC_RXBUFF_ADDR,
-					    (u8 *)&bufferaddress);
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-					    HW_DESC_RXPKT_LEN,
-					    (u8 *)&rtlpci->rxbuffersize);
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-					    HW_DESC_RXOWN,
-					    (u8 *)&tmp_one);
+		ops->set_desc(hw, (u8 *)entry, false,
+			      HW_DESC_RXBUFF_ADDR,
+			      (u8 *)&bufferaddress);
+		ops->set_desc(hw, (u8 *)entry, false,
+			      HW_DESC_RXPKT_LEN,
+			      (u8 *)&rtlpci->rxbuffersize);
+		ops->set_desc(hw, (u8 *)entry, false,
+			      HW_DESC_RXOWN,
+			      (u8 *)&tmp_one);
 	}
 	return 1;
 }
@@ -758,6 +759,7 @@ static void _rtl_pci_hs_interrupt(struct ieee80211_hw *hw)
 static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	int rxring_idx = RTL_PCI_RX_MPDU_QUEUE;
 	struct ieee80211_rx_status rx_status = { 0 };
@@ -788,8 +790,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 
 		if (rtlpriv->use_new_trx_flow) {
 			rx_remained_cnt =
-				rtlpriv->cfg->ops->rx_desc_buff_remained_cnt(hw,
-								      hw_queue);
+				ops->rx_desc_buff_remained_cnt(hw,
+							       hw_queue);
 			if (rx_remained_cnt == 0)
 				return;
 			buffer_desc = &rtlpci->rx_ring[rxring_idx].buffer_desc[
@@ -799,9 +801,9 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			pdesc = &rtlpci->rx_ring[rxring_idx].desc[
 				rtlpci->rx_ring[rxring_idx].idx];
 
-			own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc,
-							      false,
-							      HW_DESC_OWN);
+			own = (u8)ops->get_desc((u8 *)pdesc,
+						false,
+						HW_DESC_OWN);
 			if (own) /* wait data to be filled by hardware */
 				return;
 		}
@@ -818,16 +820,16 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		if (unlikely(!new_skb))
 			goto no_new;
 		memset(&rx_status , 0 , sizeof(rx_status));
-		rtlpriv->cfg->ops->query_rx_desc(hw, &stats,
-						 &rx_status, (u8 *)pdesc, skb);
+		ops->query_rx_desc(hw, &stats,
+				   &rx_status, (u8 *)pdesc, skb);
 
 		if (rtlpriv->use_new_trx_flow)
-			rtlpriv->cfg->ops->rx_check_dma_ok(hw,
-							   (u8 *)buffer_desc,
-							   hw_queue);
+			ops->rx_check_dma_ok(hw,
+					     (u8 *)buffer_desc,
+					     hw_queue);
 
-		len = rtlpriv->cfg->ops->get_desc((u8 *)pdesc, false,
-						  HW_DESC_RXPKT_LEN);
+		len = ops->get_desc((u8 *)pdesc, false,
+				    HW_DESC_RXPKT_LEN);
 
 		if (skb->end - skb->tail > len) {
 			skb_put(skb, len);
@@ -845,10 +847,10 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			goto new_trx_end;
 		}
 		/* handle command packet here */
-		if (rtlpriv->cfg->ops->rx_command_packet &&
-		    rtlpriv->cfg->ops->rx_command_packet(hw, &stats, skb)) {
-				dev_kfree_skb_any(skb);
-				goto new_trx_end;
+		if (ops->rx_command_packet &&
+		    ops->rx_command_packet(hw, &stats, skb)) {
+			dev_kfree_skb_any(skb);
+			goto new_trx_end;
 		}
 
 		/*
@@ -876,7 +878,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 			rtl_is_special_data(hw, skb, false, true);
 
 			if (ieee80211_is_data(fc)) {
-				rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
+				ops->led_control(hw, LED_CTL_RX);
 				if (unicast)
 					rtlpriv->link_info.num_rx_inperiod++;
 			}
@@ -924,10 +926,10 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 						 rtlpci->rx_ring[rxring_idx].idx);
 			if (rtlpci->rx_ring[rxring_idx].idx ==
 			    rtlpci->rxringcount - 1)
-				rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc,
-							    false,
-							    HW_DESC_RXERO,
-							    (u8 *)&tmp_one);
+				ops->set_desc(hw, (u8 *)pdesc,
+					      false,
+					      HW_DESC_RXERO,
+					      (u8 *)&tmp_one);
 		}
 		rtlpci->rx_ring[rxring_idx].idx =
 				(rtlpci->rx_ring[rxring_idx].idx + 1) %
@@ -940,6 +942,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 	struct ieee80211_hw *hw = dev_id;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	unsigned long flags;
 	u32 inta = 0;
@@ -950,10 +953,10 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		return ret;
 
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock , flags);
-	rtlpriv->cfg->ops->disable_interrupt(hw);
+	ops->disable_interrupt(hw);
 
 	/*read ISR: 4/8bytes */
-	rtlpriv->cfg->ops->interrupt_recognized(hw, &inta, &intb);
+	ops->interrupt_recognized(hw, &inta, &intb);
 
 	/*Shared IRQ or HW disappared */
 	if (!inta || inta == 0xffff)
@@ -1084,7 +1087,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		tasklet_schedule(&rtlpriv->works.irq_tasklet);
 
 done:
-	rtlpriv->cfg->ops->enable_interrupt(hw);
+	ops->enable_interrupt(hw);
 	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 	return ret;
 }
@@ -1097,6 +1100,7 @@ static void _rtl_pci_irq_tasklet(struct ieee80211_hw *hw)
 static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl8192_tx_ring *ring = NULL;
@@ -1119,8 +1123,8 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 		entry = (u8 *)(&ring->desc[ring->idx]);
 	if (pskb) {
 		pci_unmap_single(rtlpci->pdev,
-				 rtlpriv->cfg->ops->get_desc(
-				 (u8 *)entry, true, HW_DESC_TXBUFF_ADDR),
+				 ops->get_desc((u8 *)entry, true,
+					       HW_DESC_TXBUFF_ADDR),
 				 pskb->len, PCI_DMA_TODEVICE);
 		kfree_skb(pskb);
 	}
@@ -1135,19 +1139,19 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	if (rtlpriv->use_new_trx_flow)
 		pbuffer_desc = &ring->buffer_desc[0];
 
-	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *)pdesc,
-					(u8 *)pbuffer_desc, info, NULL, pskb,
-					BEACON_QUEUE, &tcb_desc);
+	ops->fill_tx_desc(hw, hdr, (u8 *)pdesc,
+			  (u8 *)pbuffer_desc, info, NULL, pskb,
+			  BEACON_QUEUE, &tcb_desc);
 
 	__skb_queue_tail(&ring->queue, pskb);
 
 	if (rtlpriv->use_new_trx_flow) {
 		temp_one = 4;
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pbuffer_desc, true,
-					    HW_DESC_OWN, (u8 *)&temp_one);
+		ops->set_desc(hw, (u8 *)pbuffer_desc, true,
+			      HW_DESC_OWN, (u8 *)&temp_one);
 	} else {
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true, HW_DESC_OWN,
-					    &temp_one);
+		ops->set_desc(hw, (u8 *)pdesc, true, HW_DESC_OWN,
+			      &temp_one);
 	}
 	return;
 }
@@ -1235,6 +1239,7 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_tx_buffer_desc *buffer_desc;
 	struct rtl_tx_desc *desc;
 	dma_addr_t buffer_desc_dma, desc_dma;
@@ -1288,10 +1293,10 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 					  ((i +	1) % entries) *
 					  sizeof(*desc);
 
-			rtlpriv->cfg->ops->set_desc(hw, (u8 *)&desc[i],
-						    true,
-						    HW_DESC_TX_NEXTDESC_ADDR,
-						    (u8 *)&nextdescaddress);
+			ops->set_desc(hw, (u8 *)&desc[i],
+				      true,
+				      HW_DESC_TX_NEXTDESC_ADDR,
+				      (u8 *)&nextdescaddress);
 		}
 	}
 	return 0;
@@ -1301,6 +1306,7 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	int i;
 
 	if (rtlpriv->use_new_trx_flow) {
@@ -1351,8 +1357,8 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw, int rxring_idx)
 				return -ENOMEM;
 		}
 
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-					    HW_DESC_RXERO, &tmp_one);
+		ops->set_desc(hw, (u8 *)entry, false,
+			      HW_DESC_RXERO, &tmp_one);
 	}
 	return 0;
 }
@@ -1485,6 +1491,7 @@ static int _rtl_pci_deinit_trx_ring(struct ieee80211_hw *hw)
 int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	int i, rxring_idx;
 	unsigned long flags;
@@ -1505,33 +1512,29 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 			for (i = 0; i < rtlpci->rxringcount; i++) {
 				entry = &rtlpci->rx_ring[rxring_idx].desc[i];
 				bufferaddress =
-				  rtlpriv->cfg->ops->get_desc((u8 *)entry,
-				  false , HW_DESC_RXBUFF_ADDR);
+					ops->get_desc((u8 *)entry, false,
+						      HW_DESC_RXBUFF_ADDR);
 				memset((u8 *)entry , 0 ,
 				       sizeof(*rtlpci->rx_ring
 				       [rxring_idx].desc));/*clear one entry*/
 				if (rtlpriv->use_new_trx_flow) {
-					rtlpriv->cfg->ops->set_desc(hw,
-					    (u8 *)entry, false,
-					    HW_DESC_RX_PREPARE,
-					    (u8 *)&bufferaddress);
+					ops->set_desc(hw, (u8 *)entry, false,
+						      HW_DESC_RX_PREPARE,
+						      (u8 *)&bufferaddress);
 				} else {
-					rtlpriv->cfg->ops->set_desc(hw,
-					    (u8 *)entry, false,
-					    HW_DESC_RXBUFF_ADDR,
-					    (u8 *)&bufferaddress);
-					rtlpriv->cfg->ops->set_desc(hw,
-					    (u8 *)entry, false,
-					    HW_DESC_RXPKT_LEN,
-					    (u8 *)&rtlpci->rxbuffersize);
-					rtlpriv->cfg->ops->set_desc(hw,
-					    (u8 *)entry, false,
-					    HW_DESC_RXOWN,
-					    (u8 *)&tmp_one);
+					ops->set_desc(hw, (u8 *)entry, false,
+						      HW_DESC_RXBUFF_ADDR,
+						      (u8 *)&bufferaddress);
+					ops->set_desc(hw, (u8 *)entry, false,
+						      HW_DESC_RXPKT_LEN,
+						      (u8 *)&rtlpci->rxbuffersize);
+					ops->set_desc(hw, (u8 *)entry, false,
+						      HW_DESC_RXOWN,
+						      (u8 *)&tmp_one);
 				}
 			}
-			rtlpriv->cfg->ops->set_desc(hw, (u8 *)entry, false,
-					    HW_DESC_RXERO, (u8 *)&tmp_one);
+			ops->set_desc(hw, (u8 *)entry, false,
+				      HW_DESC_RXERO, (u8 *)&tmp_one);
 		}
 		rtlpci->rx_ring[rxring_idx].idx = 0;
 	}
@@ -1557,11 +1560,9 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 					entry = (u8 *)(&ring->desc[ring->idx]);
 
 				pci_unmap_single(rtlpci->pdev,
-						 rtlpriv->cfg->ops->
-							 get_desc((u8 *)
-							 entry,
-							 true,
-							 HW_DESC_TXBUFF_ADDR),
+						 ops->get_desc((u8 *)entry,
+							       true,
+							       HW_DESC_TXBUFF_ADDR),
 						 skb->len, PCI_DMA_TODEVICE);
 				dev_kfree_skb_irq(skb);
 				ring->idx = (ring->idx + 1) % ring->entries;
@@ -1619,6 +1620,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 		      struct rtl_tcb_desc *ptcb_desc)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_sta_info *sta_entry = NULL;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct rtl8192_tx_ring *ring;
@@ -1671,8 +1673,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 	if (rtlpriv->use_new_trx_flow) {
 		ptx_bd_desc = &ring->buffer_desc[idx];
 	} else {
-		own = (u8) rtlpriv->cfg->ops->get_desc((u8 *)pdesc,
-				true, HW_DESC_OWN);
+		own = (u8)ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
 
 		if ((own == 1) && (hw_queue != BEACON_QUEUE)) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
@@ -1686,13 +1687,12 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 		}
 	}
 
-	if (rtlpriv->cfg->ops->get_available_desc &&
-	    rtlpriv->cfg->ops->get_available_desc(hw, hw_queue) == 0) {
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-				 "get_available_desc fail\n");
-			spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock,
-					       flags);
-			return skb->len;
+	if (ops->get_available_desc &&
+	    ops->get_available_desc(hw, hw_queue) == 0) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "get_available_desc fail\n");
+		spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+		return skb->len;
 	}
 
 	if (ieee80211_is_data_qos(fc)) {
@@ -1709,19 +1709,19 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 	}
 
 	if (ieee80211_is_data(fc))
-		rtlpriv->cfg->ops->led_control(hw, LED_CTL_TX);
+		ops->led_control(hw, LED_CTL_TX);
 
-	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *)pdesc,
-			(u8 *)ptx_bd_desc, info, sta, skb, hw_queue, ptcb_desc);
+	ops->fill_tx_desc(hw, hdr, (u8 *)pdesc, (u8 *)ptx_bd_desc, info,
+			  sta, skb, hw_queue, ptcb_desc);
 
 	__skb_queue_tail(&ring->queue, skb);
 
 	if (rtlpriv->use_new_trx_flow) {
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true,
-					    HW_DESC_OWN, &hw_queue);
+		ops->set_desc(hw, (u8 *)pdesc, true,
+			      HW_DESC_OWN, &hw_queue);
 	} else {
-		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true,
-					    HW_DESC_OWN, &temp_one);
+		ops->set_desc(hw, (u8 *)pdesc, true,
+			      HW_DESC_OWN, &temp_one);
 	}
 
 	if ((ring->entries - skb_queue_len(&ring->queue)) < 2 &&
@@ -1736,7 +1736,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw,
 
 	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 
-	rtlpriv->cfg->ops->tx_polling(hw, hw_queue);
+	ops->tx_polling(hw, hw_queue);
 
 	return 0;
 }
@@ -1813,6 +1813,7 @@ static int rtl_pci_init(struct ieee80211_hw *hw, struct pci_dev *pdev)
 static int rtl_pci_start(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -1823,21 +1824,21 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 	rtl_pci_reset_trx_ring(hw);
 
 	rtlpci->driver_is_goingto_unload = false;
-	if (rtlpriv->cfg->ops->get_btc_status &&
-	    rtlpriv->cfg->ops->get_btc_status()) {
+	if (ops->get_btc_status &&
+	    ops->get_btc_status()) {
 		rtlpriv->btcoexist.btc_ops->btc_init_variables(rtlpriv);
 		rtlpriv->btcoexist.btc_ops->btc_init_hal_vars(rtlpriv);
 	}
-	err = rtlpriv->cfg->ops->hw_init(hw);
+	err = ops->hw_init(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			 "Failed to config hardware!\n");
 		return err;
 	}
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
+	ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
 			&rtlmac->retry_long);
 
-	rtlpriv->cfg->ops->enable_interrupt(hw);
+	ops->enable_interrupt(hw);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "enable_interrupt OK\n");
 
 	rtl_init_rx_config(hw);
@@ -1856,13 +1857,14 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 static void rtl_pci_stop(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	unsigned long flags;
 	u8 RFInProgressTimeOut = 0;
 
-	if (rtlpriv->cfg->ops->get_btc_status())
+	if (ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_halt_notify();
 
 	/*
@@ -1872,7 +1874,7 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	set_hal_stop(rtlhal);
 
 	rtlpci->driver_is_goingto_unload = true;
-	rtlpriv->cfg->ops->disable_interrupt(hw);
+	ops->disable_interrupt(hw);
 	cancel_work_sync(&rtlpriv->works.lps_change_work);
 
 	spin_lock_irqsave(&rtlpriv->locks.rf_ps_lock, flags);
@@ -1889,11 +1891,11 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	ppsc->rfchange_inprogress = true;
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_ps_lock, flags);
 
-	rtlpriv->cfg->ops->hw_disable(hw);
+	ops->hw_disable(hw);
 	/* some things are not needed if firmware not available */
 	if (!rtlpriv->max_fw_size)
 		return;
-	rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
+	ops->led_control(hw, LED_CTL_POWER_OFF);
 
 	spin_lock_irqsave(&rtlpriv->locks.rf_ps_lock, flags);
 	ppsc->rfchange_inprogress = false;
@@ -2166,6 +2168,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	struct ieee80211_hw *hw = NULL;
 
 	struct rtl_priv *rtlpriv = NULL;
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci_priv *pcipriv = NULL;
 	struct rtl_pci *rtlpci;
 	unsigned long pmem_start, pmem_len, pmem_flags;
@@ -2261,14 +2264,14 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	_rtl_pci_io_handler_init(&pdev->dev, hw);
 
 	/*like read eeprom and so on */
-	rtlpriv->cfg->ops->read_eeprom_info(hw);
+	ops->read_eeprom_info(hw);
 
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+	if (ops->init_sw_vars(hw)) {
 		pr_err("Can't init_sw_vars\n");
 		err = -ENODEV;
 		goto fail3;
 	}
-	rtlpriv->cfg->ops->init_sw_leds(hw);
+	ops->init_sw_leds(hw);
 
 	/*aspm */
 	rtl_pci_init_aspm(hw);
@@ -2337,6 +2340,7 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
 	struct rtl_mac *rtlmac = rtl_mac(rtlpriv);
 
@@ -2352,14 +2356,14 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 		rtl_deinit_deferred_work(hw);
 		rtlpriv->intf_ops->adapter_stop(hw);
 	}
-	rtlpriv->cfg->ops->disable_interrupt(hw);
+	ops->disable_interrupt(hw);
 
 	/*deinit rfkill */
 	rtl_deinit_rfkill(hw);
 
 	rtl_pci_deinit(hw);
 	rtl_deinit_core(hw);
-	rtlpriv->cfg->ops->deinit_sw_vars(hw);
+	ops->deinit_sw_vars(hw);
 
 	if (rtlpci->irq_alloc) {
 		free_irq(rtlpci->pdev->irq, hw);
@@ -2406,8 +2410,9 @@ int rtl_pci_suspend(struct device *dev)
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
-	rtlpriv->cfg->ops->hw_suspend(hw);
+	ops->hw_suspend(hw);
 	rtl_deinit_rfkill(hw);
 
 	return 0;
@@ -2419,8 +2424,9 @@ int rtl_pci_resume(struct device *dev)
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
-	rtlpriv->cfg->ops->hw_resume(hw);
+	ops->hw_resume(hw);
 	rtl_init_rfkill(hw);
 	return 0;
 }
diff --git a/drivers/net/wireless/realtek/rtlwifi/ps.c b/drivers/net/wireless/realtek/rtlwifi/ps.c
index 0d152877d969..5a51e56c5f47 100644
--- a/drivers/net/wireless/realtek/rtlwifi/ps.c
+++ b/drivers/net/wireless/realtek/rtlwifi/ps.c
@@ -32,6 +32,7 @@
 bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *rtlmac = rtl_mac(rtl_priv(hw));
@@ -45,14 +46,14 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 			 "Driver is already down!\n");
 
 	/*<2> Enable Adapter */
-	if (rtlpriv->cfg->ops->hw_init(hw))
+	if (ops->hw_init(hw))
 		return false;
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
+	ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
 			&rtlmac->retry_long);
 	RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 
 	/*<3> Enable Interrupt */
-	rtlpriv->cfg->ops->enable_interrupt(hw);
+	ops->enable_interrupt(hw);
 
 	/*<enable timer> */
 	rtl_watch_dog_timer_callback((unsigned long)hw);
@@ -64,16 +65,17 @@ EXPORT_SYMBOL(rtl_ps_enable_nic);
 bool rtl_ps_disable_nic(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
 	/*<1> Stop all timer */
 	rtl_deinit_deferred_work(hw);
 
 	/*<2> Disable Interrupt */
-	rtlpriv->cfg->ops->disable_interrupt(hw);
+	ops->disable_interrupt(hw);
 	tasklet_kill(&rtlpriv->works.irq_tasklet);
 
 	/*<3> Disable Adapter */
-	rtlpriv->cfg->ops->hw_disable(hw);
+	ops->hw_disable(hw);
 
 	return true;
 }
@@ -84,6 +86,7 @@ static bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 				u32 changesource)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	enum rf_pwrstate rtstate;
 	bool actionallowed = false;
@@ -158,7 +161,7 @@ static bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 	}
 
 	if (actionallowed)
-		rtlpriv->cfg->ops->set_rf_power_state(hw, state_toset);
+		ops->set_rf_power_state(hw, state_toset);
 
 	spin_lock(&rtlpriv->locks.rf_ps_lock);
 	ppsc->rfchange_inprogress = false;
@@ -206,6 +209,7 @@ void rtl_ips_nic_off_wq_callback(void *data)
 	    container_of_dwork_rtl(data, struct rtl_works, ips_nic_off_wq);
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -229,8 +233,8 @@ void rtl_ips_nic_off_wq_callback(void *data)
 	if (rtlpriv->sec.being_setkey)
 		return;
 
-	if (rtlpriv->cfg->ops->bt_coex_off_before_lps)
-		rtlpriv->cfg->ops->bt_coex_off_before_lps(hw);
+	if (ops->bt_coex_off_before_lps)
+		ops->bt_coex_off_before_lps(hw);
 
 	if (ppsc->inactiveps) {
 		rtstate = ppsc->rfpwr_state;
@@ -256,9 +260,9 @@ void rtl_ips_nic_off_wq_callback(void *data)
 			ppsc->in_powersavemode = true;
 
 			/* call before RF off */
-			if (rtlpriv->cfg->ops->get_btc_status())
+			if (ops->get_btc_status())
 				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
-									ppsc->inactive_pwrstate);
+									   ppsc->inactive_pwrstate);
 
 			/*rtl_pci_reset_trx_ring(hw); */
 			_rtl_ps_inactive_ps(hw);
@@ -284,6 +288,7 @@ void rtl_ips_nic_off(struct ieee80211_hw *hw)
 void rtl_ips_nic_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	enum rf_pwrstate rtstate;
 
@@ -301,9 +306,9 @@ void rtl_ips_nic_on(struct ieee80211_hw *hw)
 			ppsc->in_powersavemode = false;
 			_rtl_ps_inactive_ps(hw);
 			/* call after RF on */
-			if (rtlpriv->cfg->ops->get_btc_status())
+			if (ops->get_btc_status())
 				rtlpriv->btcoexist.btc_ops->btc_ips_notify(rtlpriv,
-									ppsc->inactive_pwrstate);
+									   ppsc->inactive_pwrstate);
 		}
 	}
 	spin_unlock(&rtlpriv->locks.ips_lock);
@@ -346,6 +351,7 @@ static bool rtl_get_fwlps_doze(struct ieee80211_hw *hw)
 void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	bool enter_fwlps;
@@ -380,26 +386,26 @@ void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 			enter_fwlps = false;
 			ppsc->pwr_mode = FW_PS_ACTIVE_MODE;
 			ppsc->smart_ps = 0;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_LPS_ACTION,
-						      (u8 *)(&enter_fwlps));
+			ops->set_hw_reg(hw, HW_VAR_FW_LPS_ACTION,
+					(u8 *)(&enter_fwlps));
 			if (ppsc->p2p_ps_info.opp_ps)
 				rtl_p2p_ps_cmd(hw , P2P_PS_ENABLE);
 
-			if (rtlpriv->cfg->ops->get_btc_status())
+			if (ops->get_btc_status())
 				rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "FW LPS enter ps_mode:%x\n",
 					 ppsc->fwctrl_psmode);
-				if (rtlpriv->cfg->ops->get_btc_status())
+				if (ops->get_btc_status())
 					rtlpriv->btcoexist.btc_ops->btc_lps_notify(rtlpriv, rt_psmode);
 				enter_fwlps = true;
 				ppsc->pwr_mode = ppsc->fwctrl_psmode;
 				ppsc->smart_ps = 2;
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-							HW_VAR_FW_LPS_ACTION,
-							(u8 *)(&enter_fwlps));
+				ops->set_hw_reg(hw,
+						HW_VAR_FW_LPS_ACTION,
+						(u8 *)(&enter_fwlps));
 
 			} else {
 				/* Reset the power save related parameters. */
@@ -461,7 +467,7 @@ static void rtl_lps_leave_core(struct ieee80211_hw *hw)
 		if (ppsc->dot11_psmode != EACTIVE) {
 
 			/*FIX ME */
-			/*rtlpriv->cfg->ops->enable_interrupt(hw); */
+			/*ops->enable_interrupt(hw); */
 
 			if (ppsc->reg_rfps_level & RT_RF_LPS_LEVEL_ASPM &&
 			    RT_IN_PS_LEVEL(ppsc, RT_PS_LEVEL_ASPM) &&
@@ -914,6 +920,7 @@ static void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data,
 void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
 	struct rtl_p2p_ps_info  *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
 
@@ -921,8 +928,8 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state)
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		p2pinfo->p2p_ps_state = p2p_ps_state;
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
-					      &p2p_ps_state);
+		ops->set_hw_reg(hw, HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+				&p2p_ps_state);
 		p2pinfo->noa_index = 0;
 		p2pinfo->ctwindow = 0;
 		p2pinfo->opp_ps = 0;
@@ -931,9 +938,9 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state)
 		if (rtlps->fw_current_inpsmode) {
 			if (rtlps->smart_ps == 0) {
 				rtlps->smart_ps = 2;
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-					 HW_VAR_H2C_FW_PWRMODE,
-					 &rtlps->pwr_mode);
+				ops->set_hw_reg(hw,
+						HW_VAR_H2C_FW_PWRMODE,
+						&rtlps->pwr_mode);
 			}
 
 		}
@@ -945,14 +952,14 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state)
 			if (p2pinfo->ctwindow > 0) {
 				if (rtlps->smart_ps != 0) {
 					rtlps->smart_ps = 0;
-					rtlpriv->cfg->ops->set_hw_reg(hw,
-						 HW_VAR_H2C_FW_PWRMODE,
-						 &rtlps->pwr_mode);
+					ops->set_hw_reg(hw,
+							HW_VAR_H2C_FW_PWRMODE,
+							&rtlps->pwr_mode);
 				}
 			}
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
-				 &p2p_ps_state);
+			ops->set_hw_reg(hw,
+					HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+					&p2p_ps_state);
 
 		}
 		break;
@@ -961,9 +968,9 @@ void rtl_p2p_ps_cmd(struct ieee80211_hw *hw , u8 p2p_ps_state)
 	case P2P_PS_ALLSTASLEEP:
 		if (p2pinfo->p2p_ps_mode > P2P_PS_NONE) {
 			p2pinfo->p2p_ps_state = p2p_ps_state;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-				 HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
-				 &p2p_ps_state);
+			ops->set_hw_reg(hw,
+					HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
+					&p2p_ps_state);
 		}
 		break;
 	default:
diff --git a/drivers/net/wireless/realtek/rtlwifi/usb.c b/drivers/net/wireless/realtek/rtlwifi/usb.c
index 5590d07d0918..1da29bf07318 100644
--- a/drivers/net/wireless/realtek/rtlwifi/usb.c
+++ b/drivers/net/wireless/realtek/rtlwifi/usb.c
@@ -442,6 +442,7 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 				    struct sk_buff *skb)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	u8 *rxdesc = skb->data;
 	struct ieee80211_hdr *hdr;
 	bool unicast = false;
@@ -453,7 +454,7 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 	};
 
 	skb_pull(skb, RTL_RX_DESC_SIZE);
-	rtlpriv->cfg->ops->query_rx_desc(hw, &stats, &rx_status, rxdesc, skb);
+	ops->query_rx_desc(hw, &stats, &rx_status, rxdesc, skb);
 	skb_pull(skb, (stats.rx_drvinfo_size + stats.rx_bufshift));
 	hdr = (struct ieee80211_hdr *)(skb->data);
 	fc = hdr->frame_control;
@@ -470,7 +471,7 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 		}
 
 		if (ieee80211_is_data(fc)) {
-			rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
+			ops->led_control(hw, LED_CTL_RX);
 
 			if (unicast)
 				rtlpriv->link_info.num_rx_inperiod++;
@@ -484,6 +485,7 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 				      struct sk_buff *skb)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	u8 *rxdesc = skb->data;
 	struct ieee80211_hdr *hdr;
 	bool unicast = false;
@@ -495,7 +497,7 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 	};
 
 	skb_pull(skb, RTL_RX_DESC_SIZE);
-	rtlpriv->cfg->ops->query_rx_desc(hw, &stats, &rx_status, rxdesc, skb);
+	ops->query_rx_desc(hw, &stats, &rx_status, rxdesc, skb);
 	skb_pull(skb, (stats.rx_drvinfo_size + stats.rx_bufshift));
 	hdr = (struct ieee80211_hdr *)(skb->data);
 	fc = hdr->frame_control;
@@ -512,7 +514,7 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 		}
 
 		if (ieee80211_is_data(fc)) {
-			rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
+			ops->led_control(hw, LED_CTL_RX);
 
 			if (unicast)
 				rtlpriv->link_info.num_rx_inperiod++;
@@ -755,10 +757,11 @@ static int rtl_usb_start(struct ieee80211_hw *hw)
 {
 	int err;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_usb *rtlusb = rtl_usbdev(rtl_usbpriv(hw));
 
-	err = rtlpriv->cfg->ops->hw_init(hw);
+	err = ops->hw_init(hw);
 	if (!err) {
 		rtl_init_rx_config(hw);
 
@@ -816,6 +819,7 @@ static void rtl_usb_deinit(struct ieee80211_hw *hw)
 static void rtl_usb_stop(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_usb *rtlusb = rtl_usbdev(rtl_usbpriv(hw));
 	struct urb *urb;
@@ -842,7 +846,7 @@ static void rtl_usb_stop(struct ieee80211_hw *hw)
 		usb_free_urb(urb);
 	}
 
-	rtlpriv->cfg->ops->hw_disable(hw);
+	ops->hw_disable(hw);
 }
 
 static void _rtl_submit_tx_urb(struct ieee80211_hw *hw, struct urb *_urb)
@@ -952,6 +956,7 @@ static void _rtl_usb_tx_preprocess(struct ieee80211_hw *hw,
 				   u16 hw_queue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct rtl_tx_desc *pdesc = NULL;
@@ -991,14 +996,14 @@ static void _rtl_usb_tx_preprocess(struct ieee80211_hw *hw,
 		seq_number += 1;
 		seq_number <<= 4;
 	}
-	rtlpriv->cfg->ops->fill_tx_desc(hw, hdr, (u8 *)pdesc, NULL, info, sta, skb,
-					hw_queue, &tcb_desc);
+	ops->fill_tx_desc(hw, hdr, (u8 *)pdesc, NULL, info, sta, skb,
+			  hw_queue, &tcb_desc);
 	if (!ieee80211_has_morefrags(hdr->frame_control)) {
 		if (qc)
 			mac->tids[tid].seq_number = seq_number;
 	}
 	if (ieee80211_is_data(fc))
-		rtlpriv->cfg->ops->led_control(hw, LED_CTL_TX);
+		ops->led_control(hw, LED_CTL_TX);
 }
 
 static int rtl_usb_tx(struct ieee80211_hw *hw,
@@ -1037,8 +1042,9 @@ static void rtl_fill_h2c_cmd_work_callback(struct work_struct *work)
 	    container_of(work, struct rtl_works, fill_h2c_cmd);
 	struct ieee80211_hw *hw = rtlworks->hw;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 
-	rtlpriv->cfg->ops->fill_h2c_cmd(hw, H2C_RA_MASK, 5, rtlpriv->rate_mask);
+	ops->fill_h2c_cmd(hw, H2C_RA_MASK, 5, rtlpriv->rate_mask);
 }
 
 static const struct rtl_intf_ops rtl_usb_ops = {
@@ -1055,6 +1061,7 @@ int rtl_usb_probe(struct usb_interface *intf,
 	int err;
 	struct ieee80211_hw *hw = NULL;
 	struct rtl_priv *rtlpriv = NULL;
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct usb_device	*udev;
 	struct rtl_usb_priv *usb_priv;
 
@@ -1094,9 +1101,9 @@ int rtl_usb_probe(struct usb_interface *intf,
 	rtlpriv->intf_ops = &rtl_usb_ops;
 	/* Init IO handler */
 	_rtl_usb_io_handler_init(&udev->dev, hw);
-	rtlpriv->cfg->ops->read_chip_version(hw);
+	ops->read_chip_version(hw);
 	/*like read eeprom and so on */
-	rtlpriv->cfg->ops->read_eeprom_info(hw);
+	ops->read_eeprom_info(hw);
 	err = _rtl_usb_init(hw);
 	if (err)
 		goto error_out;
@@ -1107,11 +1114,11 @@ int rtl_usb_probe(struct usb_interface *intf,
 		pr_err("Can't allocate sw for mac80211\n");
 		goto error_out;
 	}
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+	if (ops->init_sw_vars(hw)) {
 		pr_err("Can't init_sw_vars\n");
 		goto error_out;
 	}
-	rtlpriv->cfg->ops->init_sw_leds(hw);
+	ops->init_sw_leds(hw);
 
 	err = ieee80211_register_hw(hw);
 	if (err) {
@@ -1137,6 +1144,7 @@ void rtl_usb_disconnect(struct usb_interface *intf)
 {
 	struct ieee80211_hw *hw = usb_get_intfdata(intf);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal_ops *ops = rtlpriv->cfg->ops;
 	struct rtl_mac *rtlmac = rtl_mac(rtl_priv(hw));
 	struct rtl_usb *rtlusb = rtl_usbdev(rtl_usbpriv(hw));
 
@@ -1158,8 +1166,8 @@ void rtl_usb_disconnect(struct usb_interface *intf)
 	rtl_usb_deinit(hw);
 	rtl_deinit_core(hw);
 	kfree(rtlpriv->usb_data);
-	rtlpriv->cfg->ops->deinit_sw_leds(hw);
-	rtlpriv->cfg->ops->deinit_sw_vars(hw);
+	ops->deinit_sw_leds(hw);
+	ops->deinit_sw_vars(hw);
 	_rtl_usb_io_handler_release(hw);
 	usb_put_dev(rtlusb->udev);
 	usb_set_intfdata(intf, NULL);
-- 
2.10.0.rc2.1.g053435c
