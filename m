From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 05/11 NEXT] rtlwifi: Modify base.{c,h} for new drivers
Date: Mon, 22 Sep 2014 09:39:21 -0500
Message-ID: <1411396767-20611-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/base.c | 647 +++++++++++++++++++++++-------------
 drivers/net/wireless/rtlwifi/base.h |  49 +--
 drivers/net/wireless/rtlwifi/wifi.h |  20 +-
 3 files changed, 464 insertions(+), 252 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 8234cdb..71621a1 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -34,7 +30,7 @@
 #include "cam.h"
 #include "ps.h"
 #include "regd.h"
-
+#include "pci.h"
 #include <linux/ip.h>
 #include <linux/module.h>
 #include <linux/udp.h>
@@ -211,7 +207,6 @@ static void _rtl_init_hw_ht_capab(struct ieee80211_hw *hw,
 	 *highest supported RX rate
 	 */
 	if (rtlpriv->dm.supp_phymode_switch) {
-
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
 			 "Support phy mode switch\n");
 
@@ -244,6 +239,83 @@ static void _rtl_init_hw_ht_capab(struct ieee80211_hw *hw,
 	}
 }
 
+static void _rtl_init_hw_vht_capab(struct ieee80211_hw *hw,
+				   struct ieee80211_sta_vht_cap *vht_cap)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8812AE) {
+		u16 mcs_map;
+
+		vht_cap->vht_supported = true;
+		vht_cap->cap =
+			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_3895 |
+			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_7991 |
+			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_11454 |
+			IEEE80211_VHT_CAP_SHORT_GI_80 |
+			IEEE80211_VHT_CAP_TXSTBC |
+			IEEE80211_VHT_CAP_RXSTBC_1 |
+			IEEE80211_VHT_CAP_SU_BEAMFORMER_CAPABLE |
+			IEEE80211_VHT_CAP_SU_BEAMFORMEE_CAPABLE |
+			IEEE80211_VHT_CAP_HTC_VHT |
+			IEEE80211_VHT_CAP_MAX_A_MPDU_LENGTH_EXPONENT_MASK |
+			IEEE80211_VHT_CAP_RX_ANTENNA_PATTERN |
+			IEEE80211_VHT_CAP_TX_ANTENNA_PATTERN |
+			0;
+
+		mcs_map = IEEE80211_VHT_MCS_SUPPORT_0_9 << 0 |
+			IEEE80211_VHT_MCS_SUPPORT_0_9 << 2 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 4 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 6 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 8 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 10 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 12 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 14;
+
+		vht_cap->vht_mcs.rx_mcs_map = cpu_to_le16(mcs_map);
+		vht_cap->vht_mcs.rx_highest =
+			cpu_to_le16(MAX_BIT_RATE_SHORT_GI_2NSS_80MHZ_MCS9);
+		vht_cap->vht_mcs.tx_mcs_map = cpu_to_le16(mcs_map);
+		vht_cap->vht_mcs.tx_highest =
+			cpu_to_le16(MAX_BIT_RATE_SHORT_GI_2NSS_80MHZ_MCS9);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		u16 mcs_map;
+
+		vht_cap->vht_supported = true;
+		vht_cap->cap =
+			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_3895 |
+			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_7991 |
+			IEEE80211_VHT_CAP_MAX_MPDU_LENGTH_11454 |
+			IEEE80211_VHT_CAP_SHORT_GI_80 |
+			IEEE80211_VHT_CAP_TXSTBC |
+			IEEE80211_VHT_CAP_RXSTBC_1 |
+			IEEE80211_VHT_CAP_SU_BEAMFORMER_CAPABLE |
+			IEEE80211_VHT_CAP_SU_BEAMFORMEE_CAPABLE |
+			IEEE80211_VHT_CAP_HTC_VHT |
+			IEEE80211_VHT_CAP_MAX_A_MPDU_LENGTH_EXPONENT_MASK |
+			IEEE80211_VHT_CAP_RX_ANTENNA_PATTERN |
+			IEEE80211_VHT_CAP_TX_ANTENNA_PATTERN |
+			0;
+
+		mcs_map = IEEE80211_VHT_MCS_SUPPORT_0_9 << 0 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 2 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 4 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 6 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 8 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 10 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 12 |
+			IEEE80211_VHT_MCS_NOT_SUPPORTED << 14;
+
+		vht_cap->vht_mcs.rx_mcs_map = cpu_to_le16(mcs_map);
+		vht_cap->vht_mcs.rx_highest =
+			cpu_to_le16(MAX_BIT_RATE_SHORT_GI_1NSS_80MHZ_MCS9);
+		vht_cap->vht_mcs.tx_mcs_map = cpu_to_le16(mcs_map);
+		vht_cap->vht_mcs.tx_highest =
+			cpu_to_le16(MAX_BIT_RATE_SHORT_GI_1NSS_80MHZ_MCS9);
+	}
+}
+
 static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -252,9 +324,8 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct ieee80211_supported_band *sband;
 
-
-	if (rtlhal->macphymode == SINGLEMAC_SINGLEPHY && rtlhal->bandset ==
-	    BAND_ON_BOTH) {
+	if (rtlhal->macphymode == SINGLEMAC_SINGLEPHY &&
+	    rtlhal->bandset == BAND_ON_BOTH) {
 		/* 1: 2.4 G bands */
 		/* <1> use  mac->bands as mem for hw->wiphy->bands */
 		sband = &(rtlmac->bands[IEEE80211_BAND_2GHZ]);
@@ -282,6 +353,7 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 		/* <3> init ht cap base on ant_num */
 		_rtl_init_hw_ht_capab(hw, &sband->ht_cap);
 
+		_rtl_init_hw_vht_capab(hw, &sband->vht_cap);
 		/* <4> set mac->sband to wiphy->sband */
 		hw->wiphy->bands[IEEE80211_BAND_5GHZ] = sband;
 	} else {
@@ -292,8 +364,8 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 			/* <2> set hw->wiphy->bands[IEEE80211_BAND_2GHZ]
 			 * to default value(1T1R) */
 			memcpy(&(rtlmac->bands[IEEE80211_BAND_2GHZ]),
-				 &rtl_band_2ghz,
-				 sizeof(struct ieee80211_supported_band));
+			       &rtl_band_2ghz,
+			       sizeof(struct ieee80211_supported_band));
 
 			/* <3> init ht cap base on ant_num */
 			_rtl_init_hw_ht_capab(hw, &sband->ht_cap);
@@ -307,12 +379,13 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 			/* <2> set hw->wiphy->bands[IEEE80211_BAND_5GHZ]
 			 * to default value(1T1R) */
 			memcpy(&(rtlmac->bands[IEEE80211_BAND_5GHZ]),
-				 &rtl_band_5ghz,
-				 sizeof(struct ieee80211_supported_band));
+			       &rtl_band_5ghz,
+			       sizeof(struct ieee80211_supported_band));
 
 			/* <3> init ht cap base on ant_num */
 			_rtl_init_hw_ht_capab(hw, &sband->ht_cap);
 
+			_rtl_init_hw_vht_capab(hw, &sband->vht_cap);
 			/* <4> set mac->sband to wiphy->sband */
 			hw->wiphy->bands[IEEE80211_BAND_5GHZ] = sband;
 		} else {
@@ -326,7 +399,6 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	    IEEE80211_HW_AMPDU_AGGREGATION |
 	    IEEE80211_HW_CONNECTION_MONITOR |
 	    /* IEEE80211_HW_SUPPORTS_CQM_RSSI | */
-	    IEEE80211_HW_CONNECTION_MONITOR |
 	    IEEE80211_HW_MFP_CAPABLE |
 	    IEEE80211_HW_REPORTS_TX_ACK_STATUS | 0;
 
@@ -336,7 +408,6 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 			IEEE80211_HW_PS_NULLFUNC_STACK |
 			/* IEEE80211_HW_SUPPORTS_DYNAMIC_PS | */
 			0;
-
 	hw->wiphy->interface_modes =
 	    BIT(NL80211_IFTYPE_AP) |
 	    BIT(NL80211_IFTYPE_STATION) |
@@ -344,8 +415,10 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	    BIT(NL80211_IFTYPE_MESH_POINT) |
 	    BIT(NL80211_IFTYPE_P2P_CLIENT) |
 	    BIT(NL80211_IFTYPE_P2P_GO);
-
 	hw->wiphy->flags |= WIPHY_FLAG_IBSS_RSN;
+
+	hw->wiphy->flags |= WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL;
+
 	hw->wiphy->rts_threshold = 2347;
 
 	hw->queues = AC_MAX;
@@ -358,6 +431,21 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 	/* hw->max_rates = 1; */
 	hw->sta_data_size = sizeof(struct rtl_sta_info);
 
+/* wowlan is not supported by kernel if CONFIG_PM is not defined */
+#ifdef CONFIG_PM
+	if (rtlpriv->psc.wo_wlan_mode) {
+		if (rtlpriv->psc.wo_wlan_mode & WAKE_ON_MAGIC_PACKET)
+			rtlpriv->wowlan.flags = WIPHY_WOWLAN_MAGIC_PKT;
+		if (rtlpriv->psc.wo_wlan_mode & WAKE_ON_PATTERN_MATCH) {
+			rtlpriv->wowlan.n_patterns =
+				MAX_SUPPORT_WOL_PATTERN_NUM;
+			rtlpriv->wowlan.pattern_min_len = MIN_WOL_PATTERN_SIZE;
+			rtlpriv->wowlan.pattern_max_len = MAX_WOL_PATTERN_SIZE;
+		}
+		hw->wiphy->wowlan = &rtlpriv->wowlan;
+	}
+#endif
+
 	/* <6> mac address */
 	if (is_valid_ether_addr(rtlefuse->dev_addr)) {
 		SET_IEEE80211_PERM_ADDR(hw, rtlefuse->dev_addr);
@@ -366,7 +454,6 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 		get_random_bytes((rtlmac1 + (ETH_ALEN - 1)), 1);
 		SET_IEEE80211_PERM_ADDR(hw, rtlmac1);
 	}
-
 }
 
 static void _rtl_init_deferred_work(struct ieee80211_hw *hw)
@@ -378,10 +465,9 @@ static void _rtl_init_deferred_work(struct ieee80211_hw *hw)
 		    rtl_watch_dog_timer_callback, (unsigned long)hw);
 	setup_timer(&rtlpriv->works.dualmac_easyconcurrent_retrytimer,
 		    rtl_easy_concurrent_retrytimer_callback, (unsigned long)hw);
-
 	/* <2> work queue */
 	rtlpriv->works.hw = hw;
-	rtlpriv->works.rtl_wq = alloc_workqueue("%s", 0, 0, rtlpriv->cfg->name);
+	rtlpriv->works.rtl_wq = alloc_workqueue(rtlpriv->cfg->name, 0, 0);
 	INIT_DELAYED_WORK(&rtlpriv->works.watchdog_wq,
 			  (void *)rtl_watchdog_wq_callback);
 	INIT_DELAYED_WORK(&rtlpriv->works.ips_nic_off_wq,
@@ -424,7 +510,7 @@ void rtl_init_rfkill(struct ieee80211_hw *hw)
 	radio_state = rtlpriv->cfg->ops->radio_onoff_checking(hw, &valid);
 
 	if (valid) {
-		pr_info("wireless switch is %s\n",
+		pr_info("rtlwifi: wireless switch is %s\n",
 			rtlpriv->rfkill.rfkill_state ? "on" : "off");
 
 		rtlpriv->rfkill.rfkill_state = radio_state;
@@ -466,22 +552,18 @@ int rtl_init_core(struct ieee80211_hw *hw)
 
 	/* <4> locks */
 	mutex_init(&rtlpriv->locks.conf_mutex);
-	mutex_init(&rtlpriv->locks.ps_mutex);
 	spin_lock_init(&rtlpriv->locks.ips_lock);
 	spin_lock_init(&rtlpriv->locks.irq_th_lock);
-	spin_lock_init(&rtlpriv->locks.irq_pci_lock);
-	spin_lock_init(&rtlpriv->locks.tx_lock);
 	spin_lock_init(&rtlpriv->locks.h2c_lock);
 	spin_lock_init(&rtlpriv->locks.rf_ps_lock);
 	spin_lock_init(&rtlpriv->locks.rf_lock);
 	spin_lock_init(&rtlpriv->locks.waitq_lock);
 	spin_lock_init(&rtlpriv->locks.entry_list_lock);
-	spin_lock_init(&rtlpriv->locks.fw_ps_lock);
 	spin_lock_init(&rtlpriv->locks.cck_and_rw_pagea_lock);
 	spin_lock_init(&rtlpriv->locks.check_sendpkt_lock);
 	spin_lock_init(&rtlpriv->locks.fw_ps_lock);
 	spin_lock_init(&rtlpriv->locks.lps_lock);
-
+	spin_lock_init(&rtlpriv->locks.iqk_lock);
 	/* <5> init list */
 	INIT_LIST_HEAD(&rtlpriv->entry_list);
 
@@ -539,6 +621,7 @@ static void _rtl_query_shortgi(struct ieee80211_hw *hw,
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u8 rate_flag = info->control.rates[0].flags;
 	u8 sgi_40 = 0, sgi_20 = 0, bw_40 = 0;
+	u8 sgi_80 = 0, bw_80 = 0;
 	tcb_desc->use_shortgi = false;
 
 	if (sta == NULL)
@@ -546,24 +629,35 @@ static void _rtl_query_shortgi(struct ieee80211_hw *hw,
 
 	sgi_40 = sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40;
 	sgi_20 = sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20;
+	sgi_80 = sta->vht_cap.cap & IEEE80211_VHT_CAP_SHORT_GI_80;
 
-	if (!(sta->ht_cap.ht_supported))
+	if ((!sta->ht_cap.ht_supported) && (!sta->vht_cap.vht_supported))
 		return;
 
 	if (!sgi_40 && !sgi_20)
 		return;
 
-	if (mac->opmode == NL80211_IFTYPE_STATION)
+	if (mac->opmode == NL80211_IFTYPE_STATION) {
 		bw_40 = mac->bw_40;
-	else if (mac->opmode == NL80211_IFTYPE_AP ||
+		bw_80 = mac->bw_80;
+	} else if (mac->opmode == NL80211_IFTYPE_AP ||
 		 mac->opmode == NL80211_IFTYPE_ADHOC ||
-		 mac->opmode == NL80211_IFTYPE_MESH_POINT)
-		bw_40 = sta->bandwidth >= IEEE80211_STA_RX_BW_40;
+		 mac->opmode == NL80211_IFTYPE_MESH_POINT) {
+		bw_40 = sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40;
+		bw_80 = sta->vht_cap.vht_supported;
+	}
 
-	if (bw_40 && sgi_40)
-		tcb_desc->use_shortgi = true;
-	else if ((bw_40 == false) && sgi_20)
-		tcb_desc->use_shortgi = true;
+	if (bw_80) {
+		if (sgi_80)
+			tcb_desc->use_shortgi = true;
+		else
+			tcb_desc->use_shortgi = false;
+	} else {
+		if (bw_40 && sgi_40)
+			tcb_desc->use_shortgi = true;
+		else if (!bw_40 && sgi_20)
+			tcb_desc->use_shortgi = true;
+	}
 
 	if (!(rate_flag & IEEE80211_TX_RC_SHORT_GI))
 		tcb_desc->use_shortgi = false;
@@ -613,7 +707,7 @@ static void _rtl_txrate_selectmode(struct ieee80211_hw *hw,
 		if (mac->opmode == NL80211_IFTYPE_STATION) {
 			tcb_desc->ratr_index = 0;
 		} else if (mac->opmode == NL80211_IFTYPE_ADHOC ||
-			   mac->opmode == NL80211_IFTYPE_MESH_POINT) {
+				mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 			if (tcb_desc->multicast || tcb_desc->broadcast) {
 				tcb_desc->hw_rate =
 				    rtlpriv->cfg->maps[RTL_RC_CCK_RATE2M];
@@ -634,7 +728,13 @@ static void _rtl_txrate_selectmode(struct ieee80211_hw *hw,
 		    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
 			tcb_desc->mac_id = 0;
 
-			if (mac->mode == WIRELESS_MODE_N_24G)
+			if (mac->mode == WIRELESS_MODE_AC_5G)
+				tcb_desc->ratr_index =
+					RATR_INX_WIRELESS_AC_5N;
+			else if (mac->mode == WIRELESS_MODE_AC_24G)
+				tcb_desc->ratr_index =
+					RATR_INX_WIRELESS_AC_24N;
+			else if (mac->mode == WIRELESS_MODE_N_24G)
 				tcb_desc->ratr_index = RATR_INX_WIRELESS_NGB;
 			else if (mac->mode == WIRELESS_MODE_N_5G)
 				tcb_desc->ratr_index = RATR_INX_WIRELESS_NG;
@@ -644,8 +744,9 @@ static void _rtl_txrate_selectmode(struct ieee80211_hw *hw,
 				tcb_desc->ratr_index = RATR_INX_WIRELESS_B;
 			else if (mac->mode & WIRELESS_MODE_A)
 				tcb_desc->ratr_index = RATR_INX_WIRELESS_G;
+
 		} else if (mac->opmode == NL80211_IFTYPE_AP ||
-			   mac->opmode == NL80211_IFTYPE_ADHOC) {
+			mac->opmode == NL80211_IFTYPE_ADHOC) {
 			if (NULL != sta) {
 				if (sta->aid > 0)
 					tcb_desc->mac_id = sta->aid + 1;
@@ -671,7 +772,8 @@ static void _rtl_query_bandwidth_mode(struct ieee80211_hw *hw,
 	if (mac->opmode == NL80211_IFTYPE_AP ||
 	    mac->opmode == NL80211_IFTYPE_ADHOC ||
 	    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
-		if (sta->bandwidth == IEEE80211_STA_RX_BW_20)
+		if (!(sta->ht_cap.ht_supported) ||
+		    !(sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40))
 			return;
 	} else if (mac->opmode == NL80211_IFTYPE_STATION) {
 		if (!mac->bw_40 || !(sta->ht_cap.ht_supported))
@@ -684,16 +786,74 @@ static void _rtl_query_bandwidth_mode(struct ieee80211_hw *hw,
 	if (tcb_desc->hw_rate <= rtlpriv->cfg->maps[RTL_RC_OFDM_RATE54M])
 		return;
 
-	tcb_desc->packet_bw = true;
+	tcb_desc->packet_bw = HT_CHANNEL_WIDTH_20_40;
+
+	if (rtlpriv->rtlhal.hw_type == HARDWARE_TYPE_RTL8812AE ||
+	    rtlpriv->rtlhal.hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (mac->opmode == NL80211_IFTYPE_AP ||
+		    mac->opmode == NL80211_IFTYPE_ADHOC ||
+		    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
+			if (!(sta->vht_cap.vht_supported))
+				return;
+		} else if (mac->opmode == NL80211_IFTYPE_STATION) {
+			if (!mac->bw_80 ||
+			    !(sta->vht_cap.vht_supported))
+				return;
+		}
+		if (tcb_desc->hw_rate <=
+			rtlpriv->cfg->maps[RTL_RC_HT_RATEMCS15])
+			return;
+		tcb_desc->packet_bw = HT_CHANNEL_WIDTH_80;
+	}
 }
 
-static u8 _rtl_get_highest_n_rate(struct ieee80211_hw *hw)
+static u8 _rtl_get_vht_highest_n_rate(struct ieee80211_hw *hw,
+				      struct ieee80211_sta *sta)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	u8 hw_rate;
+	u16 tx_mcs_map = le16_to_cpu(sta->vht_cap.vht_mcs.tx_mcs_map);
+
+	if ((get_rf_type(rtlphy) == RF_2T2R) &&
+	    (tx_mcs_map & 0x000c) != 0x000c) {
+		if ((tx_mcs_map & 0x000c) >> 2 ==
+			IEEE80211_VHT_MCS_SUPPORT_0_7)
+			hw_rate =
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS7];
+		else if ((tx_mcs_map  & 0x000c) >> 2 ==
+			IEEE80211_VHT_MCS_SUPPORT_0_8)
+			hw_rate =
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS9];
+		else
+			hw_rate =
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_2SS_MCS9];
+	} else {
+		if ((tx_mcs_map  & 0x0003) ==
+			IEEE80211_VHT_MCS_SUPPORT_0_7)
+			hw_rate =
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_1SS_MCS7];
+		else if ((tx_mcs_map  & 0x0003) ==
+			IEEE80211_VHT_MCS_SUPPORT_0_8)
+			hw_rate =
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_1SS_MCS9];
+		else
+			hw_rate =
+			rtlpriv->cfg->maps[RTL_RC_VHT_RATE_1SS_MCS9];
+	}
 
-	if (get_rf_type(rtlphy) == RF_2T2R)
+	return hw_rate;
+}
+
+static u8 _rtl_get_highest_n_rate(struct ieee80211_hw *hw,
+				  struct ieee80211_sta *sta)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	u8 hw_rate;
+
+	if ((get_rf_type(rtlphy) == RF_2T2R) &&
+	    (sta->ht_cap.mcs.rx_mask[1] != 0))
 		hw_rate = rtlpriv->cfg->maps[RTL_RC_HT_RATEMCS15];
 	else
 		hw_rate = rtlpriv->cfg->maps[RTL_RC_HT_RATEMCS7];
@@ -801,9 +961,7 @@ int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
 				break;
 			}
 		}
-
 	} else {
-
 		switch (desc_rate) {
 		case DESC92_RATEMCS0:
 			rate_idx = 0;
@@ -862,31 +1020,6 @@ int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL(rtlwifi_rate_mapping);
 
-bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb)
-{
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	__le16 fc = rtl_get_fc(skb);
-
-	if (rtlpriv->dm.supp_phymode_switch &&
-	    mac->link_state < MAC80211_LINKED &&
-	    (ieee80211_is_auth(fc) || ieee80211_is_probe_req(fc))) {
-		if (rtlpriv->cfg->ops->chk_switch_dmdp)
-			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
-	}
-	if (ieee80211_is_auth(fc)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
-		rtl_ips_nic_on(hw);
-
-		mac->link_state = MAC80211_LINKING;
-		/* Dual mac */
-		rtlpriv->phy.need_iqk = true;
-	}
-
-	return true;
-}
-EXPORT_SYMBOL_GPL(rtl_tx_mgmt_proc);
-
 void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 		      struct ieee80211_tx_info *info,
 		      struct ieee80211_sta *sta,
@@ -896,13 +1029,11 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 	struct rtl_mac *rtlmac = rtl_mac(rtl_priv(hw));
 	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
 	struct ieee80211_rate *txrate;
-	__le16 fc = hdr->frame_control;
+	__le16 fc = rtl_get_fc(skb);
 
 	txrate = ieee80211_get_tx_rate(hw, info);
 	if (txrate)
 		tcb_desc->hw_rate = txrate->hw_value;
-	else
-		tcb_desc->hw_rate = 0;
 
 	if (ieee80211_is_data(fc)) {
 		/*
@@ -929,15 +1060,21 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 			 *and N rate will all be controlled by FW
 			 *when tcb_desc->use_driver_rate = false
 			 */
-			if (sta && (sta->ht_cap.ht_supported)) {
-				tcb_desc->hw_rate = _rtl_get_highest_n_rate(hw);
+			if (sta && sta->vht_cap.vht_supported) {
+				tcb_desc->hw_rate =
+				_rtl_get_vht_highest_n_rate(hw, sta);
 			} else {
-				if (rtlmac->mode == WIRELESS_MODE_B) {
+				if (sta && (sta->ht_cap.ht_supported)) {
 					tcb_desc->hw_rate =
-					   rtlpriv->cfg->maps[RTL_RC_CCK_RATE11M];
+						_rtl_get_highest_n_rate(hw, sta);
 				} else {
-					tcb_desc->hw_rate =
-					   rtlpriv->cfg->maps[RTL_RC_OFDM_RATE54M];
+					if (rtlmac->mode == WIRELESS_MODE_B) {
+						tcb_desc->hw_rate =
+						    rtlpriv->cfg->maps[RTL_RC_CCK_RATE11M];
+					} else {
+						tcb_desc->hw_rate =
+						    rtlpriv->cfg->maps[RTL_RC_OFDM_RATE54M];
+					}
 				}
 			}
 		}
@@ -962,54 +1099,58 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL(rtl_get_tcb_desc);
 
-static bool addbareq_rx(struct ieee80211_hw *hw, struct sk_buff *skb)
+bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb)
 {
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct ieee80211_sta *sta = NULL;
-	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
-	struct rtl_sta_info *sta_entry = NULL;
-	struct ieee80211_mgmt *mgmt = (void *)skb->data;
-	u16 capab = 0, tid = 0;
-	struct rtl_tid_data *tid_data;
-	struct sk_buff *skb_delba = NULL;
-	struct ieee80211_rx_status rx_status = { 0 };
+	__le16 fc = rtl_get_fc(skb);
 
-	rcu_read_lock();
-	sta = rtl_find_sta(hw, hdr->addr3);
-	if (sta == NULL) {
-		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_EMERG,
-			 "sta is NULL\n");
-		rcu_read_unlock();
-		return true;
+	if (rtlpriv->dm.supp_phymode_switch &&
+	    mac->link_state < MAC80211_LINKED &&
+	    (ieee80211_is_auth(fc) || ieee80211_is_probe_req(fc))) {
+		if (rtlpriv->cfg->ops->chk_switch_dmdp)
+			rtlpriv->cfg->ops->chk_switch_dmdp(hw);
 	}
+	if (ieee80211_is_auth(fc)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
+		rtl_ips_nic_on(hw);
+
+		mac->link_state = MAC80211_LINKING;
+		/* Dul mac */
+		rtlpriv->phy.need_iqk = true;
 
-	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
-	if (!sta_entry) {
-		rcu_read_unlock();
-		return true;
 	}
-	capab = le16_to_cpu(mgmt->u.action.u.addba_req.capab);
-	tid = (capab & IEEE80211_ADDBA_PARAM_TID_MASK) >> 2;
-	tid_data = &sta_entry->tids[tid];
-	if (tid_data->agg.rx_agg_state == RTL_RX_AGG_START) {
-		skb_delba = rtl_make_del_ba(hw, hdr->addr2, hdr->addr3, tid);
-		if (skb_delba) {
-			rx_status.freq = hw->conf.chandef.chan->center_freq;
-			rx_status.band = hw->conf.chandef.chan->band;
-			rx_status.flag |= RX_FLAG_DECRYPTED;
-			rx_status.flag |= RX_FLAG_MACTIME_END;
-			rx_status.rate_idx = 0;
-			rx_status.signal = 50 + 10;
-			memcpy(IEEE80211_SKB_RXCB(skb_delba), &rx_status,
-			       sizeof(rx_status));
-			RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG,
-				      "fake del\n", skb_delba->data,
-				      skb_delba->len);
-			ieee80211_rx_irqsafe(hw, skb_delba);
-		}
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(rtl_tx_mgmt_proc);
+
+struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw, u8 *sa,
+				u8 *bssid, u16 tid);
+
+static void process_agg_start(struct ieee80211_hw *hw,
+			      struct ieee80211_hdr *hdr, u16 tid)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ieee80211_rx_status rx_status = { 0 };
+	struct sk_buff *skb_delba = NULL;
+
+	skb_delba = rtl_make_del_ba(hw, hdr->addr2, hdr->addr3, tid);
+	if (skb_delba) {
+		rx_status.freq = hw->conf.chandef.chan->center_freq;
+		rx_status.band = hw->conf.chandef.chan->band;
+		rx_status.flag |= RX_FLAG_DECRYPTED;
+		rx_status.flag |= RX_FLAG_MACTIME_START;
+		rx_status.rate_idx = 0;
+		rx_status.signal = 50 + 10;
+		memcpy(IEEE80211_SKB_RXCB(skb_delba),
+		       &rx_status, sizeof(rx_status));
+		RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG,
+			      "fake del\n",
+			      skb_delba->data,
+			      skb_delba->len);
+		ieee80211_rx_irqsafe(hw, skb_delba);
 	}
-	rcu_read_unlock();
-	return false;
 }
 
 bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
@@ -1017,8 +1158,8 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	__le16 fc = hdr->frame_control;
-	u8 *act = (u8 *)skb->data + MAC80211_3ADDR_LEN;
+	__le16 fc = rtl_get_fc(skb);
+	u8 *act = (u8 *)(((u8 *)skb->data + MAC80211_3ADDR_LEN));
 	u8 category;
 
 	if (!ieee80211_is_action(fc))
@@ -1034,18 +1175,47 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 				return false;
 
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 "%s ACT_ADDBAREQ From :%pM\n",
-				 is_tx ? "Tx" : "Rx", hdr->addr2);
+				"%s ACT_ADDBAREQ From :%pM\n",
+				is_tx ? "Tx" : "Rx", hdr->addr2);
 			RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "req\n",
-				      skb->data, skb->len);
-			if (!is_tx)
-				if (addbareq_rx(hw, skb))
+				skb->data, skb->len);
+			if (!is_tx) {
+				struct ieee80211_sta *sta = NULL;
+				struct rtl_sta_info *sta_entry = NULL;
+				struct rtl_tid_data *tid_data;
+				struct ieee80211_mgmt *mgmt = (void *)skb->data;
+				u16 capab = 0, tid = 0;
+
+				rcu_read_lock();
+				sta = rtl_find_sta(hw, hdr->addr3);
+				if (sta == NULL) {
+					RT_TRACE(rtlpriv, COMP_SEND | COMP_RECV,
+						 DBG_DMESG, "sta is NULL\n");
+					rcu_read_unlock();
+					return true;
+				}
+
+				sta_entry =
+					(struct rtl_sta_info *)sta->drv_priv;
+				if (!sta_entry) {
+					rcu_read_unlock();
 					return true;
+				}
+				capab =
+				  le16_to_cpu(mgmt->u.action.u.addba_req.capab);
+				tid = (capab &
+				       IEEE80211_ADDBA_PARAM_TID_MASK) >> 2;
+				tid_data = &sta_entry->tids[tid];
+				if (tid_data->agg.rx_agg_state ==
+				    RTL_RX_AGG_START)
+					process_agg_start(hw, hdr, tid);
+				rcu_read_unlock();
+			}
 			break;
 		case ACT_ADDBARSP:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
 				 "%s ACT_ADDBARSP From :%pM\n",
-				 is_tx ? "Tx" : "Rx", hdr->addr2);
+				  is_tx ? "Tx" : "Rx", hdr->addr2);
 			break;
 		case ACT_DELBA:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
@@ -1061,6 +1231,17 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 }
 EXPORT_SYMBOL_GPL(rtl_action_proc);
 
+static void setup_arp_tx(struct rtl_priv *rtlpriv, struct rtl_ps_ctl *ppsc)
+{
+	rtlpriv->ra.is_special_data = true;
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_special_packet_notify(
+					rtlpriv, 1);
+	rtlpriv->enter_ps = false;
+	schedule_work(&rtlpriv->works.lps_change_work);
+	ppsc->last_delaylps_stamp_jiffies = jiffies;
+}
+
 /*should call before software enc*/
 u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 {
@@ -1069,57 +1250,77 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 	__le16 fc = rtl_get_fc(skb);
 	u16 ether_type;
 	u8 mac_hdr_len = ieee80211_get_hdrlen_from_skb(skb);
+	u8 encrypt_header_len = 0;
+	u8 offset;
 	const struct iphdr *ip;
 
 	if (!ieee80211_is_data(fc))
-		return false;
-
-	ip = (const struct iphdr *)(skb->data + mac_hdr_len +
-				    SNAP_SIZE + PROTOC_TYPE_SIZE);
-	ether_type = be16_to_cpup((__be16 *)
-				  (skb->data + mac_hdr_len + SNAP_SIZE));
-
-	switch (ether_type) {
-	case ETH_P_IP: {
-		struct udphdr *udp;
-		u16 src;
-		u16 dst;
+		goto end;
 
-		if (ip->protocol != IPPROTO_UDP)
-			return false;
-		udp = (struct udphdr *)((u8 *)ip + (ip->ihl << 2));
-		src = be16_to_cpu(udp->source);
-		dst = be16_to_cpu(udp->dest);
-
-		/* If this case involves port 68 (UDP BOOTP client) connecting
-		 * with port 67 (UDP BOOTP server), then return true so that
-		 * the lowest speed is used.
-		 */
-		if (!((src == 68 && dst == 67) || (src == 67 && dst == 68)))
-			return false;
-
-		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-			 "dhcp %s !!\n", is_tx ? "Tx" : "Rx");
+	switch (rtlpriv->sec.pairwise_enc_algorithm) {
+	case WEP40_ENCRYPTION:
+	case WEP104_ENCRYPTION:
+		encrypt_header_len = 4;/*WEP_IV_LEN*/
 		break;
-	}
-	case ETH_P_ARP:
+	case TKIP_ENCRYPTION:
+		encrypt_header_len = 8;/*TKIP_IV_LEN*/
 		break;
-	case ETH_P_PAE:
-		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
+	case AESCCMP_ENCRYPTION:
+		encrypt_header_len = 8;/*CCMP_HDR_LEN;*/
 		break;
-	case ETH_P_IPV6:
-		/* TODO: Is this right? */
-		return false;
 	default:
-		return false;
+		break;
 	}
-	if (is_tx) {
-		rtlpriv->enter_ps = false;
-		schedule_work(&rtlpriv->works.lps_change_work);
-		ppsc->last_delaylps_stamp_jiffies = jiffies;
+
+	offset = mac_hdr_len + SNAP_SIZE + encrypt_header_len;
+	ether_type = be16_to_cpup((__be16 *)(skb->data + offset));
+
+	if (ETH_P_IP == ether_type) {
+		ip = (struct iphdr *)((u8 *)skb->data + offset +
+		     PROTOC_TYPE_SIZE);
+		if (IPPROTO_UDP == ip->protocol) {
+			struct udphdr *udp = (struct udphdr *)((u8 *)ip +
+							       (ip->ihl << 2));
+			if (((((u8 *)udp)[1] == 68) &&
+			     (((u8 *)udp)[3] == 67)) ||
+			    ((((u8 *)udp)[1] == 67) &&
+			     (((u8 *)udp)[3] == 68))) {
+				/* 68 : UDP BOOTP client
+				 * 67 : UDP BOOTP server
+				 */
+				RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV),
+					 DBG_DMESG, "dhcp %s !!\n",
+					 (is_tx) ? "Tx" : "Rx");
+
+				if (is_tx)
+					setup_arp_tx(rtlpriv, ppsc);
+				return true;
+			}
+		}
+	} else if (ETH_P_ARP == ether_type) {
+		if (is_tx)
+			setup_arp_tx(rtlpriv, ppsc);
+
+		return true;
+	} else if (ETH_P_PAE == ether_type) {
+		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
+			 "802.1X %s EAPOL pkt!!\n", (is_tx) ? "Tx" : "Rx");
+
+		if (is_tx) {
+			rtlpriv->ra.is_special_data = true;
+			rtlpriv->enter_ps = false;
+			schedule_work(&rtlpriv->works.lps_change_work);
+			ppsc->last_delaylps_stamp_jiffies = jiffies;
+		}
+
+		return true;
+	} else if (0x86DD == ether_type) {
+		return true;
 	}
-	return true;
+
+end:
+	rtlpriv->ra.is_special_data = false;
+	return false;
 }
 EXPORT_SYMBOL_GPL(rtl_is_special_data);
 
@@ -1133,7 +1334,6 @@ int rtl_tx_agg_start(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_tid_data *tid_data;
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_sta_info *sta_entry = NULL;
 
 	if (sta == NULL)
@@ -1147,14 +1347,14 @@ int rtl_tx_agg_start(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 		return -ENXIO;
 	tid_data = &sta_entry->tids[tid];
 
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "on ra = %pM tid = %d seq:%d\n",
-		 sta->addr, tid, tid_data->seq_number);
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
+		 "on ra = %pM tid = %d seq:%d\n", sta->addr, tid,
+		 tid_data->seq_number);
 
 	*ssn = tid_data->seq_number;
 	tid_data->agg.agg_state = RTL_AGG_START;
 
-	ieee80211_start_tx_ba_cb_irqsafe(mac->vif, sta->addr, tid);
-
+	ieee80211_start_tx_ba_cb_irqsafe(vif, sta->addr, tid);
 	return 0;
 }
 
@@ -1162,28 +1362,23 @@ int rtl_tx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 		    struct ieee80211_sta *sta, u16 tid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_tid_data *tid_data;
 	struct rtl_sta_info *sta_entry = NULL;
 
 	if (sta == NULL)
 		return -EINVAL;
 
-	if (!sta->addr) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "ra = NULL\n");
-		return -EINVAL;
-	}
-
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "on ra = %pM tid = %d\n",
-		 sta->addr, tid);
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
+		 "on ra = %pM tid = %d\n", sta->addr, tid);
 
 	if (unlikely(tid >= MAX_TID_COUNT))
 		return -EINVAL;
 
 	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
+	tid_data = &sta_entry->tids[tid];
 	sta_entry->tids[tid].agg.agg_state = RTL_AGG_STOP;
 
-	ieee80211_stop_tx_ba_cb_irqsafe(mac->vif, sta->addr, tid);
-
+	ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
 	return 0;
 }
 
@@ -1222,11 +1417,6 @@ int rtl_rx_agg_stop(struct ieee80211_hw *hw,
 	if (sta == NULL)
 		return -EINVAL;
 
-	if (!sta->addr) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "ra = NULL\n");
-		return -EINVAL;
-	}
-
 	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
 		 "on ra = %pM tid = %d\n", sta->addr, tid);
 
@@ -1238,7 +1428,6 @@ int rtl_rx_agg_stop(struct ieee80211_hw *hw,
 
 	return 0;
 }
-
 int rtl_tx_agg_oper(struct ieee80211_hw *hw,
 		struct ieee80211_sta *sta, u16 tid)
 {
@@ -1248,13 +1437,8 @@ int rtl_tx_agg_oper(struct ieee80211_hw *hw,
 	if (sta == NULL)
 		return -EINVAL;
 
-	if (!sta->addr) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "ra = NULL\n");
-		return -EINVAL;
-	}
-
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "on ra = %pM tid = %d\n",
-		 sta->addr, tid);
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
+		 "on ra = %pM tid = %d\n", sta->addr, tid);
 
 	if (unlikely(tid >= MAX_TID_COUNT))
 		return -EINVAL;
@@ -1292,7 +1476,7 @@ void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb)
 		return;
 
 	/* and only beacons from the associated BSSID, please */
-	if (!ether_addr_equal_64bits(hdr->addr3, rtlpriv->mac80211.bssid))
+	if (!ether_addr_equal(hdr->addr3, rtlpriv->mac80211.bssid))
 		return;
 
 	rtlpriv->link_info.bcn_rx_inperiod++;
@@ -1332,8 +1516,7 @@ void rtl_watchdog_wq_callback(void *data)
 		mac->cnt_after_linked = 0;
 	}
 
-	/*
-	 *<2> to check if traffic busy, if
+	/* <2> to check if traffic busy, if
 	 * busytraffic we don't change channel
 	 */
 	if (mac->link_state >= MAC80211_LINKED) {
@@ -1381,21 +1564,21 @@ void rtl_watchdog_wq_callback(void *data)
 		for (tid = 0; tid <= 7; tid++) {
 			for (idx = 0; idx <= 2; idx++)
 				rtlpriv->link_info.tidtx_in4period[tid][idx] =
-				  rtlpriv->link_info.tidtx_in4period[tid]
-				  [idx + 1];
+					rtlpriv->link_info.tidtx_in4period[tid]
+					[idx + 1];
 			rtlpriv->link_info.tidtx_in4period[tid][3] =
 				rtlpriv->link_info.tidtx_inperiod[tid];
 
 			for (idx = 0; idx <= 3; idx++)
 				tidtx_inp4eriod[tid] +=
-				  rtlpriv->link_info.tidtx_in4period[tid][idx];
+				   rtlpriv->link_info.tidtx_in4period[tid][idx];
 			aver_tidtx_inperiod[tid] = tidtx_inp4eriod[tid] / 4;
 			if (aver_tidtx_inperiod[tid] > 5000)
 				rtlpriv->link_info.higher_busytxtraffic[tid] =
-						   true;
+									true;
 			else
 				rtlpriv->link_info.higher_busytxtraffic[tid] =
-						   false;
+									false;
 		}
 
 		if (((rtlpriv->link_info.num_rx_inperiod +
@@ -1418,32 +1601,37 @@ void rtl_watchdog_wq_callback(void *data)
 	rtlpriv->link_info.higher_busyrxtraffic = higher_busyrxtraffic;
 
 	/* <3> DM */
-	rtlpriv->cfg->ops->dm_watchdog(hw);
+	if (!rtlpriv->cfg->mod_params->disable_watchdog)
+		rtlpriv->cfg->ops->dm_watchdog(hw);
 
 	/* <4> roaming */
 	if (mac->link_state == MAC80211_LINKED &&
 	    mac->opmode == NL80211_IFTYPE_STATION) {
 		if ((rtlpriv->link_info.bcn_rx_inperiod +
-		     rtlpriv->link_info.num_rx_inperiod) == 0) {
+		    rtlpriv->link_info.num_rx_inperiod) == 0) {
 			rtlpriv->link_info.roam_times++;
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
 				 "AP off for %d s\n",
-				 (rtlpriv->link_info.roam_times * 2));
+				(rtlpriv->link_info.roam_times * 2));
 
-			/* if we can't recv beacon for 6s, we should
-			 * reconnect this AP
+			/* if we can't recv beacon for 10s,
+			 * we should reconnect this AP
 			 */
-			if ((rtlpriv->link_info.roam_times >= 3) &&
-			    !is_zero_ether_addr(rtlpriv->mac80211.bssid)) {
+			if (rtlpriv->link_info.roam_times >= 5) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 					 "AP off, try to reconnect now\n");
 				rtlpriv->link_info.roam_times = 0;
-				ieee80211_connection_loss(rtlpriv->mac80211.vif);
+				ieee80211_connection_loss(
+					rtlpriv->mac80211.vif);
 			}
 		} else {
 			rtlpriv->link_info.roam_times = 0;
 		}
 	}
+
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);
+
 	rtlpriv->link_info.bcn_rx_inperiod = 0;
 }
 
@@ -1458,7 +1646,6 @@ void rtl_watch_dog_timer_callback(unsigned long data)
 	mod_timer(&rtlpriv->works.watchdog_timer,
 		  jiffies + MSECS(RTL_WATCH_DOG_TIME));
 }
-
 void rtl_fwevt_wq_callback(void *data)
 {
 	struct rtl_works *rtlworks =
@@ -1468,7 +1655,6 @@ void rtl_fwevt_wq_callback(void *data)
 
 	rtlpriv->cfg->ops->c2h_command_handle(hw);
 }
-
 void rtl_easy_concurrent_retrytimer_callback(unsigned long data)
 {
 	struct ieee80211_hw *hw = (struct ieee80211_hw *)data;
@@ -1480,7 +1666,6 @@ void rtl_easy_concurrent_retrytimer_callback(unsigned long data)
 
 	rtlpriv->cfg->ops->dualmac_easy_concurrent(hw);
 }
-
 /*********************************************************
  *
  * frame process functions
@@ -1508,7 +1693,8 @@ u8 *rtl_find_ie(u8 *data, unsigned int len, u8 ie)
 /* when we use 2 rx ants we send IEEE80211_SMPS_OFF */
 /* when we use 1 rx ant we send IEEE80211_SMPS_STATIC */
 static struct sk_buff *rtl_make_smps_action(struct ieee80211_hw *hw,
-		enum ieee80211_smps_mode smps, u8 *da, u8 *bssid)
+				     enum ieee80211_smps_mode smps,
+				     u8 *da, u8 *bssid)
 {
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct sk_buff *skb;
@@ -1533,6 +1719,9 @@ static struct sk_buff *rtl_make_smps_action(struct ieee80211_hw *hw,
 	case IEEE80211_SMPS_AUTOMATIC:/* 0 */
 	case IEEE80211_SMPS_NUM_MODES:/* 4 */
 		WARN_ON(1);
+	/* Here will get a 'MISSING_BREAK' in Coverity Test, just ignore it.
+	 * According to Kernel Code, here is right.
+	 */
 	case IEEE80211_SMPS_OFF:/* 1 */ /*MIMO_PS_NOLIMIT*/
 		action_frame->u.action.u.ht_smps.smps_control =
 				WLAN_HT_SMPS_CONTROL_DISABLED;/* 0 */
@@ -1551,8 +1740,8 @@ static struct sk_buff *rtl_make_smps_action(struct ieee80211_hw *hw,
 }
 
 int rtl_send_smps_action(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta,
-		enum ieee80211_smps_mode smps)
+			 struct ieee80211_sta *sta,
+			 enum ieee80211_smps_mode smps)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
@@ -1587,6 +1776,7 @@ int rtl_send_smps_action(struct ieee80211_hw *hw,
 		struct rtl_sta_info *sta_entry =
 			(struct rtl_sta_info *) sta->drv_priv;
 		sta_entry->mimo_ps = smps;
+		/* rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0); */
 
 		info->control.rates[0].idx = 0;
 		info->band = hw->conf.chandef.chan->band;
@@ -1628,10 +1818,10 @@ void rtl_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
 }
 EXPORT_SYMBOL(rtl_phy_scan_operation_backup);
 
-/* There seem to be issues in mac80211 regarding when del ba frames can be
- * received. As a work around, we make a fake del_ba if we receive a ba_req;
- * however, rx_agg was opened to let mac80211 release some ba related
- * resources. This del_ba is for tx only.
+/* because mac80211 have issues when can receive del ba
+ * so here we just make a fake del_ba if we receive a ba_req
+ * but rx_agg was opened to let mac80211 release some ba
+ * related resources, so please this del_ba for tx
  */
 struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
 				u8 *sa, u8 *bssid, u16 tid)
@@ -1657,7 +1847,7 @@ struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
 	action_frame->u.action.category = WLAN_CATEGORY_BACK;
 	action_frame->u.action.u.delba.action_code = WLAN_ACTION_DELBA;
 	params = (u16)(1 << 11);	/* bit 11 initiator */
-	params |= (u16)(tid << 12);		/* bit 15:12 TID number */
+	params |= (u16)(tid << 12);	/* bit 15:12 TID number */
 
 	action_frame->u.action.u.delba.params = cpu_to_le16(params);
 	action_frame->u.action.u.delba.reason_code =
@@ -1672,7 +1862,7 @@ struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
  *
  *********************************************************/
 static bool rtl_chk_vendor_ouisub(struct ieee80211_hw *hw,
-		struct octet_string vendor_ie)
+				  struct octet_string vendor_ie)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	bool matched = false;
@@ -1845,11 +2035,13 @@ static ssize_t rtl_store_debug_level(struct device *d,
 
 	ret = kstrtoul(buf, 0, &val);
 	if (ret) {
-		printk(KERN_DEBUG "%s is not in hex or decimal form.\n", buf);
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
+			 "%s is not in hex or decimal form.\n", buf);
 	} else {
 		rtlpriv->dbg.global_debuglevel = val;
-		printk(KERN_DEBUG "debuglevel:%x\n",
-		       rtlpriv->dbg.global_debuglevel);
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_DMESG,
+			 "debuglevel:%x\n",
+			 rtlpriv->dbg.global_debuglevel);
 	}
 
 	return strnlen(buf, count);
@@ -1889,7 +2081,7 @@ EXPORT_SYMBOL_GPL(rtl_global_var);
 static int __init rtl_core_module_init(void)
 {
 	if (rtl_rate_control_register())
-		pr_err("Unable to register rtl_rc, use default RC !!\n");
+		pr_err("rtl: Unable to register rtl_rc, use default RC !!\n");
 
 	/* init some global vars */
 	INIT_LIST_HEAD(&rtl_global_var.glb_priv_list);
@@ -1906,3 +2098,4 @@ static void __exit rtl_core_module_exit(void)
 
 module_init(rtl_core_module_init);
 module_exit(rtl_core_module_exit);
+
diff --git a/drivers/net/wireless/rtlwifi/base.h b/drivers/net/wireless/rtlwifi/base.h
index eaa5110..982f245 100644
--- a/drivers/net/wireless/rtlwifi/base.h
+++ b/drivers/net/wireless/rtlwifi/base.h
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
@@ -41,7 +37,7 @@ enum ap_peer {
 	PEER_MARV = 7,
 	PEER_AIRGO = 9,
 	PEER_MAX = 10,
-} ;
+};
 
 #define RTL_DUMMY_OFFSET	0
 #define RTL_DUMMY_UNIT		8
@@ -55,6 +51,16 @@ enum ap_peer {
 #define MAX_BIT_RATE_40MHZ_MCS15	300	/* Mbps */
 #define MAX_BIT_RATE_40MHZ_MCS7		150	/* Mbps */
 
+#define MAX_BIT_RATE_SHORT_GI_2NSS_80MHZ_MCS9	867	/* Mbps */
+#define MAX_BIT_RATE_SHORT_GI_2NSS_80MHZ_MCS7	650	/* Mbps */
+#define MAX_BIT_RATE_LONG_GI_2NSS_80MHZ_MCS9	780	/* Mbps */
+#define MAX_BIT_RATE_LONG_GI_2NSS_80MHZ_MCS7	585	/* Mbps */
+
+#define MAX_BIT_RATE_SHORT_GI_1NSS_80MHZ_MCS9	434	/* Mbps */
+#define MAX_BIT_RATE_SHORT_GI_1NSS_80MHZ_MCS7	325	/* Mbps */
+#define MAX_BIT_RATE_LONG_GI_1NSS_80MHZ_MCS9	390	/* Mbps */
+#define MAX_BIT_RATE_LONG_GI_1NSS_80MHZ_MCS7	293	/* Mbps */
+
 #define RTL_RATE_COUNT_LEGACY		12
 #define RTL_CHANNEL_COUNT		14
 
@@ -78,9 +84,9 @@ enum ap_peer {
 #define SET_80211_PS_POLL_AID(_hdr, _val)		\
 	(*(u16 *)((u8 *)(_hdr) + 2) = _val)
 #define SET_80211_PS_POLL_BSSID(_hdr, _val)		\
-	memcpy(((u8 *)(_hdr)) + 4, (u8 *)(_val), ETH_ALEN)
+	ether_addr_copy(((u8 *)(_hdr)) + 4, (u8 *)(_val))
 #define SET_80211_PS_POLL_TA(_hdr, _val)		\
-	memcpy(((u8 *)(_hdr)) + 10, (u8 *)(_val), ETH_ALEN)
+	ether_addr_copy(((u8 *)(_hdr))+10, (u8 *)(_val))
 
 #define SET_80211_HDR_DURATION(_hdr, _val)	\
 	(*(u16 *)((u8 *)(_hdr) + FRAME_OFFSET_DURATION) = le16_to_cpu(_val))
@@ -113,23 +119,27 @@ void rtl_init_rx_config(struct ieee80211_hw *hw);
 void rtl_init_rfkill(struct ieee80211_hw *hw);
 void rtl_deinit_rfkill(struct ieee80211_hw *hw);
 
-void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb);
+void rtl_watch_dog_timer_callback(unsigned long data);
 void rtl_deinit_deferred_work(struct ieee80211_hw *hw);
 
 bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx);
+int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
+			 bool isht, u8 desc_rate, bool first_ampdu);
+bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb);
 u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx);
 
+void rtl_beacon_statistic(struct ieee80211_hw *hw, struct sk_buff *skb);
 void rtl_watch_dog_timer_callback(unsigned long data);
 int rtl_tx_agg_start(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
-		     struct ieee80211_sta *sta, u16 tid, u16 *ssn);
+	struct ieee80211_sta *sta, u16 tid, u16 *ssn);
 int rtl_tx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
+	struct ieee80211_sta *sta, u16 tid);
+int rtl_tx_agg_oper(struct ieee80211_hw *hw,
+		    struct ieee80211_sta *sta, u16 tid);
+int rtl_rx_agg_start(struct ieee80211_hw *hw,
+		     struct ieee80211_sta *sta, u16 tid);
+int rtl_rx_agg_stop(struct ieee80211_hw *hw,
 		    struct ieee80211_sta *sta, u16 tid);
-int rtl_tx_agg_oper(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
-		    u16 tid);
-int rtl_rx_agg_start(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
-		     u16 tid);
-int rtl_rx_agg_stop(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
-		    u16 tid);
 void rtl_watchdog_wq_callback(void *data);
 void rtl_fwevt_wq_callback(void *data);
 
@@ -139,19 +149,14 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 		      struct sk_buff *skb, struct rtl_tcb_desc *tcb_desc);
 
 int rtl_send_smps_action(struct ieee80211_hw *hw,
-			 struct ieee80211_sta *sta,
-			 enum ieee80211_smps_mode smps);
+		struct ieee80211_sta *sta,
+		enum ieee80211_smps_mode smps);
 u8 *rtl_find_ie(u8 *data, unsigned int len, u8 ie);
 void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *data, unsigned int len);
 u8 rtl_tid_to_ac(u8 tid);
 extern struct attribute_group rtl_attribute_group;
 void rtl_easy_concurrent_retrytimer_callback(unsigned long data);
 extern struct rtl_global_var rtl_global_var;
-int rtlwifi_rate_mapping(struct ieee80211_hw *hw,
-			 bool isht, u8 desc_rate, bool first_ampdu);
-bool rtl_tx_mgmt_proc(struct ieee80211_hw *hw, struct sk_buff *skb);
-struct sk_buff *rtl_make_del_ba(struct ieee80211_hw *hw,
-				u8 *sa, u8 *bssid, u16 tid);
 void rtl_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 50bf739..1d58528 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -691,6 +691,13 @@ enum rtl_var_map {
 	RTL_RC_HT_RATEMCS7,
 	RTL_RC_HT_RATEMCS15,
 
+	RTL_RC_VHT_RATE_1SS_MCS7,
+	RTL_RC_VHT_RATE_1SS_MCS8,
+	RTL_RC_VHT_RATE_1SS_MCS9,
+	RTL_RC_VHT_RATE_2SS_MCS7,
+	RTL_RC_VHT_RATE_2SS_MCS8,
+	RTL_RC_VHT_RATE_2SS_MCS9,
+
 	/*keep it last */
 	RTL_VAR_MAP_MAX,
 };
@@ -1924,7 +1931,7 @@ struct rt_link_detect {
 };
 
 struct rtl_tcb_desc {
-	u8 packet_bw:1;
+	u8 packet_bw:2;
 	u8 multicast:1;
 	u8 broadcast:1;
 
@@ -2118,9 +2125,13 @@ struct rtl_mod_params {
 	/* default: 1 = using linked fw power save */
 	bool fwctrl_lps;
 
-	/* default: 0 = not using MSI interrupts mode */
-	/* submodules should set their own defalut value */
+	/* default: 0 = not using MSI interrupts mode
+	 * submodules should set their own default value
+	 */
 	bool msi_support;
+
+	/* default 0: 1 means disable */
+	bool disable_watchdog;
 };
 
 struct rtl_hal_usbint_cfg {
@@ -2503,6 +2514,9 @@ struct rtl_priv {
 	 */
 	bool use_new_trx_flow;
 
+#ifdef CONFIG_PM
+	struct wiphy_wowlan_support wowlan;
+#endif
 	/*This must be the last item so
 	   that it points to the data allocated
 	   beyond  this structure like:
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
