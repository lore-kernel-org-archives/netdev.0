From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 05/27] rtlwifi: Modify files for 2013.02.07 vendor version - part 4
Date: Mon, 25 Feb 2013 18:13:17 -0600
Message-ID: <1361837619-2985-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:51497 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759795Ab3BZAOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:12 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates files core.c, ps.c, rc.c, and wifi.h for
the changes in the newest vendor driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/core.c | 208 +++++++++++++++++++++++++++++-------
 drivers/net/wireless/rtlwifi/ps.c   |  28 ++---
 drivers/net/wireless/rtlwifi/rc.c   |   7 ++
 drivers/net/wireless/rtlwifi/wifi.h |  35 ++++--
 4 files changed, 218 insertions(+), 60 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index d3ce9fb..470a67d 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -104,9 +104,12 @@ static void rtl_op_stop(struct ieee80211_hw *hw)
 	if (is_hal_stop(rtlhal))
 		return;
 
+	/* here is must, because adhoc do stop and start,
+	 * but stop with RFOFF may cause something wrong,
+	 * like adhoc TP
+	 */
 	if (unlikely(ppsc->rfpwr_state == ERFOFF)) {
 		rtl_ips_nic_on(hw);
-		mdelay(1);
 	}
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
@@ -167,7 +170,11 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 	rtl_ips_nic_on(hw);
 
 	mutex_lock(&rtlpriv->locks.conf_mutex);
-	switch (vif->type) {
+
+	switch (ieee80211_vif_type_p2p(vif)) {
+	case NL80211_IFTYPE_P2P_CLIENT:
+		mac->p2p = P2P_ROLE_CLIENT;
+		/*fall through*/
 	case NL80211_IFTYPE_STATION:
 		if (mac->beacon_enabled == 1) {
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
@@ -192,6 +199,9 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 				(u8 *) (&mac->basic_rates));
 
 		break;
+	case NL80211_IFTYPE_P2P_GO:
+		mac->p2p = P2P_ROLE_GO;
+		/*fall through*/
 	case NL80211_IFTYPE_AP:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
 			 "NL80211_IFTYPE_AP\n");
@@ -205,6 +215,19 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
 				(u8 *) (&mac->basic_rates));
 		break;
+	case NL80211_IFTYPE_MESH_POINT:
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
+			 "NL80211_IFTYPE_MESH_POINT\n");
+
+		mac->link_state = MAC80211_LINKED;
+		rtlpriv->cfg->ops->set_bcn_reg(hw);
+		if (rtlpriv->rtlhal.current_bandtype == BAND_ON_2_4G)
+			mac->basic_rates = 0xfff;
+		else
+			mac->basic_rates = 0xff0;
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+				(u8 *)(&mac->basic_rates));
+		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "operation mode %d is not supported!\n", vif->type);
@@ -212,6 +235,13 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		goto out;
 	}
 
+	if (mac->p2p) {
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
+			 "p2p role %x\n", vif->type);
+		mac->basic_rates = 0xff0;/*disable cck rate for p2p*/
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BASIC_RATE,
+				(u8 *)(&mac->basic_rates));
+	}
 	mac->vif = vif;
 	mac->opmode = vif->type;
 	rtlpriv->cfg->ops->set_network_type(hw, vif->type);
@@ -232,9 +262,9 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 
 	/* Free beacon resources */
-	if ((mac->opmode == NL80211_IFTYPE_AP) ||
-	    (mac->opmode == NL80211_IFTYPE_ADHOC) ||
-	    (mac->opmode == NL80211_IFTYPE_MESH_POINT)) {
+	if ((vif->type == NL80211_IFTYPE_AP) ||
+	    (vif->type == NL80211_IFTYPE_ADHOC) ||
+	    (vif->type == NL80211_IFTYPE_MESH_POINT)) {
 		if (mac->beacon_enabled == 1) {
 			mac->beacon_enabled = 0;
 			rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
@@ -247,6 +277,7 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	 *Note: We assume NL80211_IFTYPE_UNSPECIFIED as
 	 *NO LINK for our hardware.
 	 */
+	mac->p2p = 0;
 	mac->vif = NULL;
 	mac->link_state = MAC80211_NOLINK;
 	memset(mac->bssid, 0, 6);
@@ -256,6 +287,22 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
 }
 
+static int rtl_op_change_interface(struct ieee80211_hw *hw,
+				      struct ieee80211_vif *vif,
+				      enum nl80211_iftype new_type, bool p2p)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int ret;
+	rtl_op_remove_interface(hw, vif);
+
+	vif->type = new_type;
+	vif->p2p = p2p;
+	ret = rtl_op_add_interface(hw, vif);
+	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
+		 "p2p %x\n", p2p);
+	return ret;
+}
+
 static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -264,6 +311,9 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct ieee80211_conf *conf = &hw->conf;
 
+	if (mac->skip_scan)
+		return 1;
+
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 	if (changed & IEEE80211_CONF_CHANGE_LISTEN_INTERVAL) {	/*BIT(2)*/
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
@@ -323,6 +373,16 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		struct ieee80211_channel *channel = hw->conf.channel;
 		u8 wide_chan = (u8) channel->hw_value;
 
+		if (mac->act_scanning)
+			mac->n_channels++;
+
+		if (rtlpriv->dm.supp_phymode_switch &&
+		    mac->link_state < MAC80211_LINKED &&
+		    !mac->act_scanning) {
+			if (rtlpriv->cfg->ops->chk_switch_dmdp)
+				rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+		}
+
 		/*
 		 *because we should back channel to
 		 *current_network.chan in in scanning,
@@ -373,13 +433,13 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		if (wide_chan <= 0)
 			wide_chan = 1;
 
-		/* In scanning, before we go offchannel we may send a ps=1 null
-		 * to AP, and then we may send a ps = 0 null to AP quickly, but
-		 * first null may have caused AP to put lots of packet to hw tx
-		 * buffer. These packets must be tx'd before we go off channel
-		 * so we must delay more time to let AP flush these packets
-		 * before going offchannel, or dis-association or delete BA will
-		 * happen by AP
+		/* In scanning, before we go offchannel we may send a ps = 1
+		 * null to AP, and then we may send a ps = 0 null to AP quickly,
+		 * but first null may have caused AP to put lots of packet to
+		 * hw tx buffer. These packets must be tx'd before we go off
+		 * channel so we must delay more time to let AP flush these
+		 * packets before going offchannel, or dis-association or
+		 * delete BA will be caused by AP
 		 */
 		if (rtlpriv->mac80211.offchan_delay) {
 			rtlpriv->mac80211.offchan_delay = false;
@@ -441,7 +501,8 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 	 * and nolink check bssid is set in set network_type */
 	if ((changed_flags & FIF_BCN_PRBRESP_PROMISC) &&
 		(mac->link_state >= MAC80211_LINKED)) {
-		if (mac->opmode != NL80211_IFTYPE_AP) {
+		if (mac->opmode != NL80211_IFTYPE_AP &&
+		    mac->opmode != NL80211_IFTYPE_MESH_POINT) {
 			if (*new_flags & FIF_BCN_PRBRESP_PROMISC) {
 				rtlpriv->cfg->ops->set_chk_bssid(hw, false);
 			} else {
@@ -481,32 +542,43 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_sta_info *sta_entry;
 
 	if (sta) {
 		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_add_tail(&sta_entry->list, &rtlpriv->entry_list);
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
 		if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 			sta_entry->wireless_mode = WIRELESS_MODE_G;
 			if (sta->supp_rates[0] <= 0xf)
 				sta_entry->wireless_mode = WIRELESS_MODE_B;
-			if (sta->ht_cap.ht_supported)
+			if (sta->ht_cap.ht_supported == true)
 				sta_entry->wireless_mode = WIRELESS_MODE_N_24G;
+
+			if (vif->type == NL80211_IFTYPE_ADHOC)
+				sta_entry->wireless_mode = WIRELESS_MODE_G;
 		} else if (rtlhal->current_bandtype == BAND_ON_5G) {
 			sta_entry->wireless_mode = WIRELESS_MODE_A;
-			if (sta->ht_cap.ht_supported)
+			if (sta->ht_cap.ht_supported == true)
 				sta_entry->wireless_mode = WIRELESS_MODE_N_24G;
-		}
 
-		/* I found some times mac80211 give wrong supp_rates for adhoc*/
-		if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_ADHOC)
-			sta_entry->wireless_mode = WIRELESS_MODE_G;
+			if (vif->type == NL80211_IFTYPE_ADHOC)
+				sta_entry->wireless_mode = WIRELESS_MODE_A;
+		}
+		/*disable cck rate for p2p*/
+		if (mac->p2p)
+			sta->supp_rates[0] &= 0xfffffff0;
 
+		memcpy(sta_entry->mac_addr, sta->addr, ETH_ALEN);
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 			 "Add sta addr is %pM\n", sta->addr);
 		rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 	}
 	return 0;
 }
+
 static int rtl_op_sta_remove(struct ieee80211_hw *hw,
 				struct ieee80211_vif *vif,
 				struct ieee80211_sta *sta)
@@ -519,9 +591,14 @@ static int rtl_op_sta_remove(struct ieee80211_hw *hw,
 		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 		sta_entry->wireless_mode = 0;
 		sta_entry->ratr_index = 0;
+
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_del(&sta_entry->list);
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
 	}
 	return 0;
 }
+
 static int _rtl_get_hal_qnum(u16 queue)
 {
 	int qnum;
@@ -547,8 +624,8 @@ static int _rtl_get_hal_qnum(u16 queue)
 }
 
 /*
- *for mac80211 VO=0, VI=1, BE=2, BK=3
- *for rtl819x  BE=0, BK=1, VI=2, VO=3
+ *for mac80211 VO = 0, VI = 1, BE = 2, BK = 3
+ *for rtl819x  BE = 0, BK = 1, VI = 2, VO = 3
  */
 static int rtl_op_conf_tx(struct ieee80211_hw *hw,
 		   struct ieee80211_vif *vif, u16 queue,
@@ -630,6 +707,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 	/*TODO: reference to enum ieee80211_bss_change */
 	if (changed & BSS_CHANGED_ASSOC) {
 		if (bss_conf->assoc) {
+			struct ieee80211_sta *sta = NULL;
 			/* we should reset all sec info & cam
 			 * before set cam after linked, we should not
 			 * reset in disassoc, that will cause tkip->wep
@@ -647,23 +725,37 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 			if (rtlpriv->cfg->ops->linked_set_reg)
 				rtlpriv->cfg->ops->linked_set_reg(hw);
-			if (mac->opmode == NL80211_IFTYPE_STATION && sta)
+			rcu_read_lock();
+			sta = ieee80211_find_sta(vif, (u8 *)bss_conf->bssid);
+
+			if (vif->type == NL80211_IFTYPE_STATION && sta)
 				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
+			RT_TRACE(rtlpriv, COMP_EASY_CONCURRENT, DBG_LOUD,
+				 "send PS STATIC frame\n");
+			if (rtlpriv->dm.supp_phymode_switch) {
+				if (sta->ht_cap.ht_supported)
+					rtl_send_smps_action(hw, sta,
+						 IEEE80211_SMPS_STATIC);
+			}
+			rcu_read_unlock();
+
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_ASSOC\n");
 		} else {
 			if (mac->link_state == MAC80211_LINKED)
-				rtl_lps_leave(hw);
+				schedule_work(&rtlpriv->works.lps_leave_work);
 
+			if (ppsc->p2p_ps_info.p2p_ps_mode > P2P_PS_NONE)
+				rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
 			mac->link_state = MAC80211_NOLINK;
 			memset(mac->bssid, 0, 6);
-
-			/* reset sec info */
-			rtl_cam_reset_sec_info(hw);
-
-			rtl_cam_reset_all_entry(hw);
 			mac->vendor = PEER_UNKNOWN;
 
+			if (rtlpriv->dm.supp_phymode_switch) {
+				if (rtlpriv->cfg->ops->chk_switch_dmdp)
+					rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+			}
+
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
 				 "BSS_CHANGED_UN_ASSOC\n");
 		}
@@ -778,7 +870,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		}
 
 		if (changed & BSS_CHANGED_BASIC_RATES) {
-			/* for 5G must << RATE_6M_INDEX=4,
+			/* for 5G must << RATE_6M_INDEX = 4,
 			 * because 5G have no cck rate*/
 			if (rtlhal->current_bandtype == BAND_ON_5G)
 				basic_rates = sta->supp_rates[1] << 4;
@@ -815,6 +907,9 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				ppsc->report_linked = false;
 			}
 		}
+		if (rtlpriv->cfg->ops->bt_wifi_media_status_notify)
+			rtlpriv->cfg->ops->bt_wifi_media_status_notify(hw,
+							 ppsc->report_linked);
 	}
 
 out:
@@ -885,7 +980,6 @@ static int rtl_op_ampdu_action(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_TX_STOP: TID:%d\n", tid);
 		return rtl_tx_agg_stop(hw, sta, tid);
-		break;
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_TX_OPERATIONAL:TID:%d\n", tid);
@@ -894,11 +988,11 @@ static int rtl_op_ampdu_action(struct ieee80211_hw *hw,
 	case IEEE80211_AMPDU_RX_START:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_RX_START:TID:%d\n", tid);
-		break;
+		return rtl_rx_agg_start(hw, sta, tid);
 	case IEEE80211_AMPDU_RX_STOP:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
 			 "IEEE80211_AMPDU_RX_STOP:TID:%d\n", tid);
-		break;
+		return rtl_rx_agg_stop(hw, sta, tid);
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "IEEE80211_AMPDU_ERR!!!!:\n");
@@ -912,12 +1006,19 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
-	mac->act_scanning = true;
-
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
+	mac->act_scanning = true;
+	if (rtlpriv->link_info.higher_busytraffic) {
+		mac->skip_scan = true;
+		return;
+	}
 
+	if (rtlpriv->dm.supp_phymode_switch) {
+		if (rtlpriv->cfg->ops->chk_switch_dmdp)
+			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
+	}
 	if (mac->link_state == MAC80211_LINKED) {
-		rtl_lps_leave(hw);
+		schedule_work(&rtlpriv->works.lps_leave_work);
 		mac->link_state = MAC80211_LINKED_SCANNING;
 	} else {
 		rtl_ips_nic_on(hw);
@@ -937,6 +1038,16 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
 	mac->act_scanning = false;
+	mac->skip_scan = false;
+	if (rtlpriv->link_info.higher_busytraffic)
+		return;
+
+	/*p2p will use 1/6/11 to scan */
+	if (mac->n_channels == 3)
+		mac->p2p_in_use = true;
+	else
+		mac->p2p_in_use = false;
+	mac->n_channels = 0;
 	/* Dual mac */
 	rtlpriv->rtlhal.load_imrandiqk_setting_for2g = false;
 
@@ -970,6 +1081,11 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			 "not open hw encryption\n");
 		return -ENOSPC;	/*User disabled HW-crypto */
 	}
+	/* To support IBSS, use sw-crypto for GTK */
+	if (((vif->type == NL80211_IFTYPE_ADHOC) ||
+	     (vif->type == NL80211_IFTYPE_MESH_POINT)) &&
+	      !(key->flags & IEEE80211_KEY_FLAG_PAIRWISE))
+		return -ENOSPC;
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 		 "%s hardware based encryption for keyidx: %d, mac: %pM\n",
 		 cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
@@ -996,6 +1112,14 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		key_type = AESCCMP_ENCRYPTION;
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:CCMP\n");
 		break;
+	case WLAN_CIPHER_SUITE_AES_CMAC:
+		/*HW doesn't support CMAC encryption, use software CMAC */
+		key_type = AESCMAC_ENCRYPTION;
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:CMAC\n");
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+			 "HW don't support CMAC encryption, use software CMAC\n");
+		err = -EOPNOTSUPP;
+		goto out_unlock;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "alg_err:%x!!!!\n",
 			 key->cipher);
@@ -1017,13 +1141,14 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	 * 1) wep only: is just for wep enc, in this condition
 	 * rtlpriv->sec.pairwise_enc_algorithm == NO_ENCRYPTION
 	 * will be true & enable_hw_sec will be set when wep
-	 * ke setting.
+	 * key setting.
 	 * 2) wep(group) + AES(pairwise): some AP like cisco
 	 * may use it, in this condition enable_hw_sec will not
 	 * be set when wep key setting */
 	/* we must reset sec_info after lingked before set key,
 	 * or some flag will be wrong*/
-	if (mac->opmode == NL80211_IFTYPE_AP) {
+	if (vif->type == NL80211_IFTYPE_AP ||
+	    vif->type == NL80211_IFTYPE_MESH_POINT) {
 		if (!group_key || key_type == WEP40_ENCRYPTION ||
 			key_type == WEP104_ENCRYPTION) {
 			if (group_key)
@@ -1098,12 +1223,16 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		key->hw_key_idx = key_idx;
 		if (key_type == TKIP_ENCRYPTION)
 			key->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
+		/*use software CCMP encryption for management frames (MFP) */
+		if (key_type == AESCCMP_ENCRYPTION)
+			key->flags |= IEEE80211_KEY_FLAG_SW_MGMT_TX;
 		break;
 	case DISABLE_KEY:
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 			 "disable key delete one entry\n");
 		/*set local buf about wep key. */
-		if (mac->opmode == NL80211_IFTYPE_AP) {
+		if (vif->type == NL80211_IFTYPE_AP ||
+		    vif->type == NL80211_IFTYPE_MESH_POINT) {
 			if (sta)
 				rtl_cam_del_entry(hw, sta->addr);
 		}
@@ -1163,7 +1292,7 @@ static void rtl_op_rfkill_poll(struct ieee80211_hw *hw)
 }
 
 /* this function is called by mac80211 to flush tx buffer
- * before switch channle or power save, or tx buffer packet
+ * before switch channel or power save, or tx buffer packet
  * maybe send after offchannel or rf sleep, this may cause
  * dis-association by AP */
 static void rtl_op_flush(struct ieee80211_hw *hw, bool drop)
@@ -1180,6 +1309,7 @@ const struct ieee80211_ops rtl_ops = {
 	.tx = rtl_op_tx,
 	.add_interface = rtl_op_add_interface,
 	.remove_interface = rtl_op_remove_interface,
+	.change_interface = rtl_op_change_interface,
 	.config = rtl_op_config,
 	.configure_filter = rtl_op_configure_filter,
 	.sta_add = rtl_op_sta_add,
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 101b569..884bcea 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -180,6 +180,9 @@ void rtl_ips_nic_off_wq_callback(void *data)
 		return;
 	}
 
+	if (mac->p2p_in_use)
+		return;
+
 	if (mac->link_state > MAC80211_NOLINK)
 		return;
 
@@ -334,14 +337,14 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "FW LPS leave ps_mode:%x\n",
 				 FW_PS_ACTIVE_MODE);
-				enter_fwlps = false;
-				ppsc->pwr_mode = FW_PS_ACTIVE_MODE;
-				ppsc->smart_ps = 0;
-				rtlpriv->cfg->ops->set_hw_reg(hw,
-							HW_VAR_FW_LPS_ACTION,
-							(u8 *)(&enter_fwlps));
-				if (ppsc->p2p_ps_info.opp_ps)
-					rtl_p2p_ps_cmd(hw, P2P_PS_ENABLE);
+			enter_fwlps = false;
+			ppsc->pwr_mode = FW_PS_ACTIVE_MODE;
+			ppsc->smart_ps = 0;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_FW_LPS_ACTION,
+						(u8 *)(&enter_fwlps));
+			if (ppsc->p2p_ps_info.opp_ps)
+				rtl_p2p_ps_cmd(hw, P2P_PS_ENABLE);
 
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
@@ -637,7 +640,8 @@ void rtl_swlps_wq_callback(void *data)
 	}
 }
 
-void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
+static void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data,
+			   unsigned int len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct ieee80211_mgmt *mgmt = (void *)data;
@@ -735,12 +739,12 @@ void rtl_p2p_noa_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
 	}
 }
 
-void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
+static void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data,
+			      unsigned int len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct ieee80211_mgmt *mgmt = (void *)data;
 	struct rtl_p2p_ps_info *p2pinfo = &(rtlpriv->psc.p2p_ps_info);
-	bool find_p2p_ie = false , find_p2p_ps_ie = false;
 	u8 noa_num, index, i, noa_index = 0;
 	u8 *pos, *end, *ie;
 	u16 noa_len;
@@ -757,7 +761,6 @@ void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
 
 	if (ie == NULL)
 		return;
-	find_p2p_ie = true;
 
 	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "action frame find P2P IE.\n");
 	/*to find noa ie*/
@@ -770,7 +773,6 @@ void rtl_p2p_action_ie(struct ieee80211_hw *hw, void *data, unsigned int len)
 			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "find NOA IE.\n");
 			RT_PRINT_DATA(rtlpriv, COMP_FW, DBG_LOUD, "noa ie ",
 				      ie, noa_len);
-			find_p2p_ps_ie = true;
 			if ((noa_len - 2) % 13 != 0) {
 				RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
 					 "P2P notice of absence: invalid length.%d\n",
diff --git a/drivers/net/wireless/rtlwifi/rc.c b/drivers/net/wireless/rtlwifi/rc.c
index c12a866..f9f059d 100644
--- a/drivers/net/wireless/rtlwifi/rc.c
+++ b/drivers/net/wireless/rtlwifi/rc.c
@@ -216,6 +216,12 @@ static void rtl_tx_status(void *ppriv,
 	}
 }
 
+static void rtl_rate_init(void *ppriv,
+			  struct ieee80211_supported_band *sband,
+			  struct ieee80211_sta *sta, void *priv_sta)
+{
+}
+
 static void *rtl_rate_alloc(struct ieee80211_hw *hw,
 		struct dentry *debugfsdir)
 {
@@ -260,6 +266,7 @@ static struct rate_control_ops rtl_rate_ops = {
 	.free = rtl_rate_free,
 	.alloc_sta = rtl_rate_alloc_sta,
 	.free_sta = rtl_rate_free_sta,
+	.rate_init = rtl_rate_init,
 	.tx_status = rtl_tx_status,
 	.get_rate = rtl_get_rate,
 };
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 944b5d2..9ec9c59 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -104,6 +104,7 @@
 /* for early mode */
 #define FCS_LEN				4
 #define EM_HDR_LEN			8
+
 enum intf_type {
 	INTF_PCI = 0,
 	INTF_USB = 1,
@@ -263,7 +264,7 @@ enum hw_variables {
 	HW_VAR_RATR_0,
 	HW_VAR_RRSR,
 	HW_VAR_CPU_RST,
-	HW_VAR_CECHK_BSSID,
+	HW_VAR_CHECK_BSSID,
 	HW_VAR_LBK_MODE,
 	HW_VAR_AES_11N_FIX,
 	HW_VAR_USB_RX_AGGR,
@@ -308,6 +309,7 @@ enum hw_variables {
 	HW_VAR_INT_AC,
 	HW_VAR_RF_TIMING,
 
+	HAL_DEF_WOWLAN,
 	HW_VAR_MRC,
 
 	HW_VAR_MGT_FILTER,
@@ -746,6 +748,11 @@ struct false_alarm_statistics {
 	u32 cnt_ofdm_fail;
 	u32 cnt_cck_fail;
 	u32 cnt_all;
+	u32 cnt_ofdm_cca;
+	u32 cnt_cck_cca;
+	u32 cnt_cca_all;
+	u32 cnt_bw_usc;
+	u32 cnt_bw_lsc;
 };
 
 struct init_gain {
@@ -887,8 +894,10 @@ struct p2p_ps_offload_t {
 	u8 discovery:1;
 	u8 reserved:1;
 };
- #define IQK_MATRIX_REG_NUM	8
+
+#define IQK_MATRIX_REG_NUM	8
 #define IQK_MATRIX_SETTINGS_NUM	(1 + 24 + 21)
+
 struct iqk_matrix_regs {
 	bool iqk_done;
 	long value[1][IQK_MATRIX_REG_NUM];
@@ -963,6 +972,8 @@ struct rtl_phy {
 	/* the current Tx power level */
 	u8 cur_cck_txpwridx;
 	u8 cur_ofdm24g_txpwridx;
+	u8 cur_bw20_txpwridx;
+	u8 cur_bw40_txpwridx;
 
 	u32 rfreg_chnlval[2];
 	bool apk_done;
@@ -1001,15 +1012,15 @@ struct rtl_ht_agg {
 	u8 rx_agg_state;
 };
 
+struct rssi_sta {
+	long undec_sm_pwdb;
+};
+
 struct rtl_tid_data {
 	u16 seq_number;
 	struct rtl_ht_agg agg;
 };
 
-struct rssi_sta {
-	long undec_sm_pwdb;
-};
-
 struct rtl_sta_info {
 	struct list_head list;
 	u8 ratr_index;
@@ -1083,7 +1094,6 @@ struct rtl_mac {
 	/* early mode */
 	/* skb wait queue */
 	struct sk_buff_head skb_waitq[MAX_TID_COUNT];
-	u8 earlymode_threshold;
 
 	/*RDG*/
 	bool rdg_en;
@@ -1107,6 +1117,7 @@ struct rtl_mac {
 	u8 retry_short;
 	u8 retry_long;
 	u16 assoc_id;
+	bool hiddenssid;
 
 	/*IBSS*/
 	int beacon_interval;
@@ -1176,10 +1187,13 @@ struct bt_coexist_8723 {
 
 struct rtl_hal {
 	struct ieee80211_hw *hw;
-	struct bt_coexist_8723 hal_coex_8723;
+	bool driver_is_goingto_unload;
 	bool up_first_time;
+	bool first_init;
 	bool being_init_adapter;
 	bool bbrf_ready;
+	bool mac_func_enable;
+	struct bt_coexist_8723 hal_coex_8723;
 
 	enum intf_type interface;
 	u16 hw_type;		/*92c or 92d or 92s and so on */
@@ -1187,6 +1201,7 @@ struct rtl_hal {
 	u8 oem_id;
 	u32 version;		/*version of chip */
 	u8 state;		/*stop 0, start 1 */
+	u8 board_type;
 
 	/*firmware */
 	u32 fwsize;
@@ -1206,6 +1221,10 @@ struct rtl_hal {
 	bool set_fwcmd_inprogress;
 	u8 current_fwcmd_io;
 
+	bool fw_clk_change_in_progress;
+	bool allow_sw_to_change_hwclc;
+	u8 fw_ps_state;
+	struct p2p_ps_offload_t p2p_ps_offload;
 	/**/
 	bool driver_going2unload;
 
-- 
1.8.1.4
