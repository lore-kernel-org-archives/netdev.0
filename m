From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 08/11 NEXT] rtlwifi: Finish modifying core routines for new drivers
Date: Mon, 22 Sep 2014 09:39:24 -0500
Message-ID: <1411396767-20611-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Addition of the new drivers and the update to a new version for the others
lead to changes in all the core routines.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/debug.c |  10 +---
 drivers/net/wireless/rtlwifi/debug.h |  10 +---
 drivers/net/wireless/rtlwifi/rc.c    |  98 ++++++++++++++++++-------------
 drivers/net/wireless/rtlwifi/rc.h    |   9 +--
 drivers/net/wireless/rtlwifi/regd.c  | 109 ++++++++++++++++++++---------------
 drivers/net/wireless/rtlwifi/regd.h  |  11 ++--
 drivers/net/wireless/rtlwifi/stats.c |  51 +++++++++-------
 drivers/net/wireless/rtlwifi/stats.h |   8 +--
 drivers/net/wireless/rtlwifi/wifi.h  |   5 ++
 9 files changed, 178 insertions(+), 133 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.c b/drivers/net/wireless/rtlwifi/debug.c
index 76e2086..fd25aba 100644
--- a/drivers/net/wireless/rtlwifi/debug.c
+++ b/drivers/net/wireless/rtlwifi/debug.c
@@ -2,20 +2,16 @@
  *
  * Copyright(c) 2009-2012  Realtek Corporation.
  *
- * Tmis program is free software; you can redistribute it and/or modify it
+ * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License as
  * published by the Free Software Foundation.
  *
- * Tmis program is distributed in the hope that it will be useful, but WITHOUT
+ * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * tmis program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- * Tme full GNU General Public License is included in this distribution in the
+ * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
  * Contact Information:
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 6d66936..534c224 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -2,20 +2,16 @@
  *
  * Copyright(c) 2009-2012  Realtek Corporation.
  *
- * Tmis program is free software; you can redistribute it and/or modify it
+ * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License as
  * published by the Free Software Foundation.
  *
- * Tmis program is distributed in the hope that it will be useful, but WITHOUT
+ * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  *
- * You should have received a copy of the GNU General Public License along with
- * tmis program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- * Tme full GNU General Public License is included in this distribution in the
+ * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
  *
  * Contact Information:
diff --git a/drivers/net/wireless/rtlwifi/rc.c b/drivers/net/wireless/rtlwifi/rc.c
index ee28a1a..a42a236 100644
--- a/drivers/net/wireless/rtlwifi/rc.c
+++ b/drivers/net/wireless/rtlwifi/rc.c
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
@@ -35,13 +31,13 @@
  *Finds the highest rate index we can use
  *if skb is special data like DHCP/EAPOL, we set should
  *it to lowest rate CCK_1M, otherwise we set rate to
- *CCK11M or OFDM_54M based on wireless mode.
+ *highest rate based on wireless mode used for iwconfig
+ *show Tx rate.
  */
 static u8 _rtl_rc_get_highest_rix(struct rtl_priv *rtlpriv,
 				  struct ieee80211_sta *sta,
 				  struct sk_buff *skb, bool not_data)
 {
-	struct rtl_mac *rtlmac = rtl_mac(rtlpriv);
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_sta_info *sta_entry = NULL;
@@ -54,21 +50,13 @@ static u8 _rtl_rc_get_highest_rix(struct rtl_priv *rtlpriv,
 	 *2.in rtl_get_tcb_desc when we check rate is
 	 *      1M we will not use FW rate but user rate.
 	 */
-	if (rtlmac->opmode == NL80211_IFTYPE_AP ||
-	    rtlmac->opmode == NL80211_IFTYPE_ADHOC ||
-	    rtlmac->opmode == NL80211_IFTYPE_MESH_POINT) {
-		if (sta) {
-			sta_entry = (struct rtl_sta_info *) sta->drv_priv;
-			wireless_mode = sta_entry->wireless_mode;
-		} else {
-			return 0;
-		}
-	} else {
-		wireless_mode = rtlmac->mode;
+
+	if (sta) {
+		sta_entry = (struct rtl_sta_info *)sta->drv_priv;
+		wireless_mode = sta_entry->wireless_mode;
 	}
 
-	if (rtl_is_special_data(rtlpriv->mac80211.hw, skb, true) ||
-			not_data) {
+	if (rtl_is_special_data(rtlpriv->mac80211.hw, skb, true) || not_data) {
 		return 0;
 	} else {
 		if (rtlhal->current_bandtype == BAND_ON_2_4G) {
@@ -76,21 +64,27 @@ static u8 _rtl_rc_get_highest_rix(struct rtl_priv *rtlpriv,
 				return B_MODE_MAX_RIX;
 			} else if (wireless_mode == WIRELESS_MODE_G) {
 				return G_MODE_MAX_RIX;
-			} else {
+			} else if (wireless_mode == WIRELESS_MODE_N_24G) {
 				if (get_rf_type(rtlphy) != RF_2T2R)
 					return N_MODE_MCS7_RIX;
 				else
 					return N_MODE_MCS15_RIX;
+			} else if (wireless_mode == WIRELESS_MODE_AC_24G) {
+				return AC_MODE_MCS9_RIX;
 			}
+			return 0;
 		} else {
 			if (wireless_mode == WIRELESS_MODE_A) {
 				return A_MODE_MAX_RIX;
-			} else {
+			} else if (wireless_mode == WIRELESS_MODE_N_5G) {
 				if (get_rf_type(rtlphy) != RF_2T2R)
 					return N_MODE_MCS7_RIX;
 				else
 					return N_MODE_MCS15_RIX;
+			} else if (wireless_mode == WIRELESS_MODE_AC_5G) {
+				return AC_MODE_MCS9_RIX;
 			}
+			return 0;
 		}
 	}
 }
@@ -103,35 +97,52 @@ static void _rtl_rc_rate_set_series(struct rtl_priv *rtlpriv,
 				    bool not_data)
 {
 	struct rtl_mac *mac = rtl_mac(rtlpriv);
-	u8 sgi_20 = 0, sgi_40 = 0;
+	struct rtl_sta_info *sta_entry = NULL;
+	u8 wireless_mode = 0;
+	u8 sgi_20 = 0, sgi_40 = 0, sgi_80 = 0;
 
 	if (sta) {
 		sgi_20 = sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20;
 		sgi_40 = sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40;
+		sgi_80 = sta->vht_cap.cap & IEEE80211_VHT_CAP_SHORT_GI_80;
+		sta_entry = (struct rtl_sta_info *)sta->drv_priv;
+		wireless_mode = sta_entry->wireless_mode;
 	}
 	rate->count = tries;
 	rate->idx = rix >= 0x00 ? rix : 0x00;
+	if (rtlpriv->rtlhal.hw_type == HARDWARE_TYPE_RTL8812AE &&
+	    wireless_mode == WIRELESS_MODE_AC_5G)
+		rate->idx += 0x10;/*2NSS for 8812AE*/
 
 	if (!not_data) {
 		if (txrc->short_preamble)
 			rate->flags |= IEEE80211_TX_RC_USE_SHORT_PREAMBLE;
 		if (mac->opmode == NL80211_IFTYPE_AP ||
-		    mac->opmode == NL80211_IFTYPE_ADHOC) {
-			if (sta && (sta->bandwidth >= IEEE80211_STA_RX_BW_40))
+			mac->opmode == NL80211_IFTYPE_ADHOC) {
+			if (sta && (sta->ht_cap.cap &
+				    IEEE80211_HT_CAP_SUP_WIDTH_20_40))
 				rate->flags |= IEEE80211_TX_RC_40_MHZ_WIDTH;
+			if (sta && (sta->vht_cap.vht_supported))
+				rate->flags |= IEEE80211_TX_RC_80_MHZ_WIDTH;
 		} else {
 			if (mac->bw_40)
 				rate->flags |= IEEE80211_TX_RC_40_MHZ_WIDTH;
+			if (mac->bw_80)
+				rate->flags |= IEEE80211_TX_RC_80_MHZ_WIDTH;
 		}
-		if (sgi_20 || sgi_40)
+
+		if (sgi_20 || sgi_40 || sgi_80)
 			rate->flags |= IEEE80211_TX_RC_SHORT_GI;
-		if (sta && sta->ht_cap.ht_supported)
+		if (sta && sta->ht_cap.ht_supported &&
+		    ((wireless_mode == WIRELESS_MODE_N_5G) ||
+		     (wireless_mode == WIRELESS_MODE_N_24G)))
 			rate->flags |= IEEE80211_TX_RC_MCS;
 	}
 }
 
 static void rtl_get_rate(void *ppriv, struct ieee80211_sta *sta,
-			 void *priv_sta, struct ieee80211_tx_rate_control *txrc)
+			 void *priv_sta,
+			 struct ieee80211_tx_rate_control *txrc)
 {
 	struct rtl_priv *rtlpriv = ppriv;
 	struct sk_buff *skb = txrc->skb;
@@ -158,7 +169,7 @@ static void rtl_get_rate(void *ppriv, struct ieee80211_sta *sta,
 }
 
 static bool _rtl_tx_aggr_check(struct rtl_priv *rtlpriv,
-		struct rtl_sta_info *sta_entry, u16 tid)
+			       struct rtl_sta_info *sta_entry, u16 tid)
 {
 	struct rtl_mac *mac = rtl_mac(rtlpriv);
 
@@ -166,7 +177,7 @@ static bool _rtl_tx_aggr_check(struct rtl_priv *rtlpriv,
 		return false;
 
 	if (mac->opmode == NL80211_IFTYPE_STATION &&
-		mac->cnt_after_linked < 3)
+	    mac->cnt_after_linked < 3)
 		return false;
 
 	if (sta_entry->tids[tid].agg.agg_state == RTL_AGG_STOP)
@@ -193,23 +204,23 @@ static void rtl_tx_status(void *ppriv,
 	if (rtl_is_special_data(mac->hw, skb, true))
 		return;
 
-	if (is_multicast_ether_addr(ieee80211_get_DA(hdr))
-	    || is_broadcast_ether_addr(ieee80211_get_DA(hdr)))
+	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr)))
 		return;
 
 	if (sta) {
 		/* Check if aggregation has to be enabled for this tid */
 		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 		if ((sta->ht_cap.ht_supported) &&
-				!(skb->protocol == cpu_to_be16(ETH_P_PAE))) {
+		    !(skb->protocol == cpu_to_be16(ETH_P_PAE))) {
 			if (ieee80211_is_data_qos(fc)) {
 				u8 tid = rtl_get_tid(skb);
 				if (_rtl_tx_aggr_check(rtlpriv, sta_entry,
-				    tid)) {
+						       tid)) {
 					sta_entry->tids[tid].agg.agg_state =
-							 RTL_AGG_PROGRESS;
-					ieee80211_start_tx_ba_session(sta,
-								 tid, 5000);
+						RTL_AGG_PROGRESS;
+					ieee80211_start_tx_ba_session(sta, tid,
+								      5000);
 				}
 			}
 		}
@@ -223,8 +234,15 @@ static void rtl_rate_init(void *ppriv,
 {
 }
 
-static void *rtl_rate_alloc(struct ieee80211_hw *hw,
-		struct dentry *debugfsdir)
+static void rtl_rate_update(void *ppriv,
+			    struct ieee80211_supported_band *sband,
+			    struct cfg80211_chan_def *chandef,
+			    struct ieee80211_sta *sta, void *priv_sta,
+			    u32 changed)
+{
+}
+
+static void *rtl_rate_alloc(struct ieee80211_hw *hw, struct dentry *debugfsdir)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	return rtlpriv;
@@ -260,13 +278,14 @@ static void rtl_rate_free_sta(void *rtlpriv,
 	kfree(rate_priv);
 }
 
-static const struct rate_control_ops rtl_rate_ops = {
+static struct rate_control_ops rtl_rate_ops = {
 	.name = "rtl_rc",
 	.alloc = rtl_rate_alloc,
 	.free = rtl_rate_free,
 	.alloc_sta = rtl_rate_alloc_sta,
 	.free_sta = rtl_rate_free_sta,
 	.rate_init = rtl_rate_init,
+	.rate_update = rtl_rate_update,
 	.tx_status = rtl_tx_status,
 	.get_rate = rtl_get_rate,
 };
@@ -280,3 +299,4 @@ void rtl_rate_control_unregister(void)
 {
 	ieee80211_rate_control_unregister(&rtl_rate_ops);
 }
+
diff --git a/drivers/net/wireless/rtlwifi/rc.h b/drivers/net/wireless/rtlwifi/rc.h
index 4d61761..f29643d 100644
--- a/drivers/net/wireless/rtlwifi/rc.h
+++ b/drivers/net/wireless/rtlwifi/rc.h
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
@@ -38,10 +34,15 @@
 #define N_MODE_MCS7_RIX 7
 #define N_MODE_MCS15_RIX 15
 
+#define AC_MODE_MCS7_RIX 7
+#define AC_MODE_MCS8_RIX 8
+#define AC_MODE_MCS9_RIX 9
+
 struct rtl_rate_priv {
 	u8 ht_cap;
 };
 
 int rtl_rate_control_register(void);
 void rtl_rate_control_unregister(void);
+
 #endif
diff --git a/drivers/net/wireless/rtlwifi/regd.c b/drivers/net/wireless/rtlwifi/regd.c
index a4eb9b2..aca003a 100644
--- a/drivers/net/wireless/rtlwifi/regd.c
+++ b/drivers/net/wireless/rtlwifi/regd.c
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
@@ -59,26 +55,23 @@ static struct country_code_to_enum_rd allCountries[] = {
  */
 #define RTL819x_2GHZ_CH12_13	\
 	REG_RULE(2467-10, 2472+10, 40, 0, 20,\
-		 NL80211_RRF_NO_IR)
+	NL80211_RRF_PASSIVE_SCAN)
 
 #define RTL819x_2GHZ_CH14	\
 	REG_RULE(2484-10, 2484+10, 40, 0, 20, \
-		 NL80211_RRF_NO_IR | NL80211_RRF_NO_OFDM)
+	NL80211_RRF_PASSIVE_SCAN | \
+	NL80211_RRF_NO_OFDM)
+
 
 /* 5G chan 36 - chan 64*/
 #define RTL819x_5GHZ_5150_5350	\
-	REG_RULE(5150-10, 5350+10, 40, 0, 30, \
-		 NL80211_RRF_NO_IR)
-
+	REG_RULE(5150-10, 5350+10, 80, 0, 30, 0)
 /* 5G chan 100 - chan 165*/
 #define RTL819x_5GHZ_5470_5850	\
-	REG_RULE(5470-10, 5850+10, 40, 0, 30, \
-		 NL80211_RRF_NO_IR)
-
+	REG_RULE(5470-10, 5850+10, 80, 0, 30, 0)
 /* 5G chan 149 - chan 165*/
 #define RTL819x_5GHZ_5725_5850	\
-	REG_RULE(5725-10, 5850+10, 40, 0, 30, \
-		 NL80211_RRF_NO_IR)
+	REG_RULE(5725-10, 5850+10, 80, 0, 30, 0)
 
 #define RTL819x_5GHZ_ALL	\
 	(RTL819x_5GHZ_5150_5350, RTL819x_5GHZ_5470_5850)
@@ -143,7 +136,7 @@ static const struct ieee80211_regdomain rtl_regdom_14 = {
 
 static bool _rtl_is_radar_freq(u16 center_freq)
 {
-	return (center_freq >= 5260 && center_freq <= 5700);
+	return center_freq >= 5260 && center_freq <= 5700;
 }
 
 static void _rtl_reg_apply_beaconing_flags(struct wiphy *wiphy,
@@ -169,10 +162,9 @@ static void _rtl_reg_apply_beaconing_flags(struct wiphy *wiphy,
 				continue;
 			if (initiator == NL80211_REGDOM_SET_BY_COUNTRY_IE) {
 				reg_rule = freq_reg_info(wiphy,
-							 MHZ_TO_KHZ(ch->center_freq));
+							 ch->center_freq);
 				if (IS_ERR(reg_rule))
 					continue;
-
 				/*
 				 *If 11d had a rule for this channel ensure
 				 *we enable adhoc/beaconing if it allows us to
@@ -182,11 +174,16 @@ static void _rtl_reg_apply_beaconing_flags(struct wiphy *wiphy,
 				 *regulatory_hint().
 				 */
 
-				if (!(reg_rule->flags & NL80211_RRF_NO_IR))
-					ch->flags &= ~IEEE80211_CHAN_NO_IR;
+				if (!(reg_rule->flags & NL80211_RRF_NO_IBSS))
+					ch->flags &= ~IEEE80211_CHAN_NO_IBSS;
+				if (!(reg_rule->flags &
+				      NL80211_RRF_PASSIVE_SCAN))
+					ch->flags &=
+					    ~IEEE80211_CHAN_PASSIVE_SCAN;
 			} else {
 				if (ch->beacon_found)
-					ch->flags &= ~IEEE80211_CHAN_NO_IR;
+					ch->flags &= ~(IEEE80211_CHAN_NO_IBSS |
+						   IEEE80211_CHAN_PASSIVE_SCAN);
 			}
 		}
 	}
@@ -211,35 +208,35 @@ static void _rtl_reg_apply_active_scan_flags(struct wiphy *wiphy,
 	 */
 	if (initiator != NL80211_REGDOM_SET_BY_COUNTRY_IE) {
 		ch = &sband->channels[11];	/* CH 12 */
-		if (ch->flags & IEEE80211_CHAN_NO_IR)
-			ch->flags &= ~IEEE80211_CHAN_NO_IR;
+		if (ch->flags & IEEE80211_CHAN_PASSIVE_SCAN)
+			ch->flags &= ~IEEE80211_CHAN_PASSIVE_SCAN;
 		ch = &sband->channels[12];	/* CH 13 */
-		if (ch->flags & IEEE80211_CHAN_NO_IR)
-			ch->flags &= ~IEEE80211_CHAN_NO_IR;
+		if (ch->flags & IEEE80211_CHAN_PASSIVE_SCAN)
+			ch->flags &= ~IEEE80211_CHAN_PASSIVE_SCAN;
 		return;
 	}
 
 	/*
-	 *If a country IE has been received check its rule for this
+	 *If a country IE has been recieved check its rule for this
 	 *channel first before enabling active scan. The passive scan
 	 *would have been enforced by the initial processing of our
 	 *custom regulatory domain.
 	 */
 
 	ch = &sband->channels[11];	/* CH 12 */
-	reg_rule = freq_reg_info(wiphy, MHZ_TO_KHZ(ch->center_freq));
+	reg_rule = freq_reg_info(wiphy, ch->center_freq);
 	if (!IS_ERR(reg_rule)) {
-		if (!(reg_rule->flags & NL80211_RRF_NO_IR))
-			if (ch->flags & IEEE80211_CHAN_NO_IR)
-				ch->flags &= ~IEEE80211_CHAN_NO_IR;
+		if (!(reg_rule->flags & NL80211_RRF_PASSIVE_SCAN))
+			if (ch->flags & IEEE80211_CHAN_PASSIVE_SCAN)
+				ch->flags &= ~IEEE80211_CHAN_PASSIVE_SCAN;
 	}
 
 	ch = &sband->channels[12];	/* CH 13 */
-	reg_rule = freq_reg_info(wiphy, MHZ_TO_KHZ(ch->center_freq));
+	reg_rule = freq_reg_info(wiphy, ch->center_freq);
 	if (!IS_ERR(reg_rule)) {
-		if (!(reg_rule->flags & NL80211_RRF_NO_IR))
-			if (ch->flags & IEEE80211_CHAN_NO_IR)
-				ch->flags &= ~IEEE80211_CHAN_NO_IR;
+		if (!(reg_rule->flags & NL80211_RRF_PASSIVE_SCAN))
+			if (ch->flags & IEEE80211_CHAN_PASSIVE_SCAN)
+				ch->flags &= ~IEEE80211_CHAN_PASSIVE_SCAN;
 	}
 }
 
@@ -276,7 +273,8 @@ static void _rtl_reg_apply_radar_flags(struct wiphy *wiphy)
 		 */
 		if (!(ch->flags & IEEE80211_CHAN_DISABLED))
 			ch->flags |= IEEE80211_CHAN_RADAR |
-				     IEEE80211_CHAN_NO_IR;
+			    IEEE80211_CHAN_NO_IBSS |
+			    IEEE80211_CHAN_PASSIVE_SCAN;
 	}
 }
 
@@ -289,9 +287,25 @@ static void _rtl_reg_apply_world_flags(struct wiphy *wiphy,
 	return;
 }
 
-static void _rtl_reg_notifier_apply(struct wiphy *wiphy,
-				    struct regulatory_request *request,
-				    struct rtl_regulatory *reg)
+static void _rtl_dump_channel_map(struct wiphy *wiphy)
+{
+	enum ieee80211_band band;
+	struct ieee80211_supported_band *sband;
+	struct ieee80211_channel *ch;
+	unsigned int i;
+
+	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
+		if (!wiphy->bands[band])
+			continue;
+		sband = wiphy->bands[band];
+		for (i = 0; i < sband->n_channels; i++)
+			ch = &sband->channels[i];
+	}
+}
+
+static int _rtl_reg_notifier_apply(struct wiphy *wiphy,
+				   struct regulatory_request *request,
+				   struct rtl_regulatory *reg)
 {
 	/* We always apply this */
 	_rtl_reg_apply_radar_flags(wiphy);
@@ -305,10 +319,14 @@ static void _rtl_reg_notifier_apply(struct wiphy *wiphy,
 		_rtl_reg_apply_world_flags(wiphy, request->initiator, reg);
 		break;
 	}
+
+	_rtl_dump_channel_map(wiphy);
+
+	return 0;
 }
 
 static const struct ieee80211_regdomain *_rtl_regdomain_select(
-					       struct rtl_regulatory *reg)
+						struct rtl_regulatory *reg)
 {
 	switch (reg->country_code) {
 	case COUNTRY_CODE_FCC:
@@ -337,9 +355,9 @@ static const struct ieee80211_regdomain *_rtl_regdomain_select(
 
 static int _rtl_regd_init_wiphy(struct rtl_regulatory *reg,
 				struct wiphy *wiphy,
-				void (*reg_notifier) (struct wiphy *wiphy,
-						      struct regulatory_request *
-						      request))
+				void (*reg_notifier)(struct wiphy *wiphy,
+						     struct regulatory_request *
+						     request))
 {
 	const struct ieee80211_regdomain *regd;
 
@@ -348,7 +366,6 @@ static int _rtl_regd_init_wiphy(struct rtl_regulatory *reg,
 	wiphy->regulatory_flags |= REGULATORY_CUSTOM_REG;
 	wiphy->regulatory_flags &= ~REGULATORY_STRICT_REG;
 	wiphy->regulatory_flags &= ~REGULATORY_DISABLE_BEACON_HINTS;
-
 	regd = _rtl_regdomain_select(reg);
 	wiphy_apply_custom_regulatory(wiphy, regd);
 	_rtl_reg_apply_radar_flags(wiphy);
@@ -368,7 +385,7 @@ static struct country_code_to_enum_rd *_rtl_regd_find_country(u16 countrycode)
 }
 
 int rtl_regd_init(struct ieee80211_hw *hw,
-		  void (*reg_notifier) (struct wiphy *wiphy,
+		  void (*reg_notifier)(struct wiphy *wiphy,
 				       struct regulatory_request *request))
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -382,7 +399,8 @@ int rtl_regd_init(struct ieee80211_hw *hw,
 	rtlpriv->regd.country_code = rtlpriv->efuse.channel_plan;
 
 	RT_TRACE(rtlpriv, COMP_REGD, DBG_TRACE,
-		 "rtl: EEPROM regdomain: 0x%0x\n", rtlpriv->regd.country_code);
+		 "rtl: EEPROM regdomain: 0x%0x\n",
+		  rtlpriv->regd.country_code);
 
 	if (rtlpriv->regd.country_code >= COUNTRY_CODE_MAX) {
 		RT_TRACE(rtlpriv, COMP_REGD, DBG_DMESG,
@@ -403,7 +421,7 @@ int rtl_regd_init(struct ieee80211_hw *hw,
 
 	RT_TRACE(rtlpriv, COMP_REGD, DBG_TRACE,
 		 "rtl: Country alpha2 being used: %c%c\n",
-		 rtlpriv->regd.alpha2[0], rtlpriv->regd.alpha2[1]);
+		  rtlpriv->regd.alpha2[0], rtlpriv->regd.alpha2[1]);
 
 	_rtl_regd_init_wiphy(&rtlpriv->regd, wiphy, reg_notifier);
 
@@ -419,3 +437,4 @@ void rtl_reg_notifier(struct wiphy *wiphy, struct regulatory_request *request)
 
 	_rtl_reg_notifier_apply(wiphy, request, &rtlpriv->regd);
 }
+
diff --git a/drivers/net/wireless/rtlwifi/regd.h b/drivers/net/wireless/rtlwifi/regd.h
index 4e1f4f00..3bbbaaa 100644
--- a/drivers/net/wireless/rtlwifi/regd.h
+++ b/drivers/net/wireless/rtlwifi/regd.h
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
@@ -30,6 +26,10 @@
 #ifndef __RTL_REGD_H__
 #define __RTL_REGD_H__
 
+/* for kernel 3.14 , both value are changed to IEEE80211_CHAN_NO_IR*/
+#define IEEE80211_CHAN_NO_IBSS IEEE80211_CHAN_NO_IR
+#define IEEE80211_CHAN_PASSIVE_SCAN IEEE80211_CHAN_NO_IR
+
 struct country_code_to_enum_rd {
 	u16 countrycode;
 	const char *iso_name;
@@ -56,6 +56,7 @@ enum country_code_type_t {
 
 int rtl_regd_init(struct ieee80211_hw *hw,
 		  void (*reg_notifier) (struct wiphy *wiphy,
-					struct regulatory_request *request));
+		  struct regulatory_request *request));
 void rtl_reg_notifier(struct wiphy *wiphy, struct regulatory_request *request);
+
 #endif
diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index 4f083fc..6541683 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
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
@@ -59,8 +55,23 @@ u8 rtl_evm_db_to_percentage(char value)
 }
 EXPORT_SYMBOL(rtl_evm_db_to_percentage);
 
+u8 rtl_evm_dbm_jaguar(char value)
+{
+	char ret_val = value;
+
+	/* -33dB~0dB to 33dB ~ 0dB*/
+	if (ret_val == -128)
+		ret_val = 127;
+	else if (ret_val < 0)
+		ret_val = 0 - ret_val;
+
+	ret_val  = ret_val >> 1;
+	return ret_val;
+}
+EXPORT_SYMBOL(rtl_evm_dbm_jaguar);
+
 static long rtl_translate_todbm(struct ieee80211_hw *hw,
-				u8 signal_strength_index)
+			 u8 signal_strength_index)
 {
 	long signal_power;
 
@@ -106,6 +117,10 @@ static void rtl_process_ui_rssi(struct ieee80211_hw *hw,
 	u8 rfpath;
 	u32 last_rssi, tmpval;
 
+	if (!pstatus->packet_toself && !pstatus->packet_beacon)
+		return;
+
+	rtlpriv->stats.pwdb_all_cnt += pstatus->rx_pwdb_all;
 	rtlpriv->stats.rssi_calculate_cnt++;
 
 	if (rtlpriv->stats.ui_rssi.total_num++ >= PHY_RSSI_SLID_WIN_MAX) {
@@ -151,6 +166,12 @@ static void rtl_process_ui_rssi(struct ieee80211_hw *hw,
 			     (pstatus->rx_mimo_signalstrength[rfpath])) /
 			    (RX_SMOOTH_FACTOR);
 		}
+		rtlpriv->stats.rx_snr_db[rfpath] = pstatus->rx_snr[rfpath];
+		rtlpriv->stats.rx_evm_dbm[rfpath] =
+					pstatus->rx_mimo_evm_dbm[rfpath];
+		rtlpriv->stats.rx_cfo_short[rfpath] =
+					pstatus->cfo_short[rfpath];
+		rtlpriv->stats.rx_cfo_tail[rfpath] = pstatus->cfo_tail[rfpath];
 	}
 }
 
@@ -176,7 +197,6 @@ static void rtl_process_pwdb(struct ieee80211_hw *hw, struct rtl_stats *pstatus)
 	struct rtl_sta_info *drv_priv = NULL;
 	struct ieee80211_sta *sta = NULL;
 	long undec_sm_pwdb;
-	long undec_sm_cck;
 
 	rcu_read_lock();
 	if (rtlpriv->mac80211.opmode != NL80211_IFTYPE_STATION)
@@ -186,33 +206,21 @@ static void rtl_process_pwdb(struct ieee80211_hw *hw, struct rtl_stats *pstatus)
 	if (sta) {
 		drv_priv = (struct rtl_sta_info *) sta->drv_priv;
 		undec_sm_pwdb = drv_priv->rssi_stat.undec_sm_pwdb;
-		undec_sm_cck = drv_priv->rssi_stat.undec_sm_cck;
 	} else {
 		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
-		undec_sm_cck = rtlpriv->dm.undec_sm_cck;
 	}
 
 	if (undec_sm_pwdb < 0)
 		undec_sm_pwdb = pstatus->rx_pwdb_all;
-	if (undec_sm_cck < 0)
-		undec_sm_cck = pstatus->rx_pwdb_all;
 	if (pstatus->rx_pwdb_all > (u32) undec_sm_pwdb) {
 		undec_sm_pwdb = (((undec_sm_pwdb) *
 		      (RX_SMOOTH_FACTOR - 1)) +
 		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 		undec_sm_pwdb = undec_sm_pwdb + 1;
 	} else {
-		undec_sm_pwdb = (((undec_sm_pwdb) * (RX_SMOOTH_FACTOR - 1)) +
-		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-	}
-	if (pstatus->rx_pwdb_all > (u32) undec_sm_cck) {
-		undec_sm_cck = (((undec_sm_pwdb) *
+		undec_sm_pwdb = (((undec_sm_pwdb) *
 		      (RX_SMOOTH_FACTOR - 1)) +
 		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-		undec_sm_cck = undec_sm_cck + 1;
-	} else {
-		undec_sm_pwdb = (((undec_sm_cck) * (RX_SMOOTH_FACTOR - 1)) +
-		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 	}
 
 	if (sta) {
@@ -245,7 +253,7 @@ static void rtl_process_ui_link_quality(struct ieee80211_hw *hw,
 	rtlpriv->stats.ui_link_quality.total_val += pstatus->signalquality;
 	rtlpriv->stats.ui_link_quality.elements[
 		rtlpriv->stats.ui_link_quality.index++] =
-						 pstatus->signalquality;
+							pstatus->signalquality;
 	if (rtlpriv->stats.ui_link_quality.index >=
 	    PHY_LINKQUALITY_SLID_WIN_MAX)
 		rtlpriv->stats.ui_link_quality.index = 0;
@@ -269,7 +277,7 @@ static void rtl_process_ui_link_quality(struct ieee80211_hw *hw,
 }
 
 void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
-	struct rtl_stats *pstatus)
+			 struct rtl_stats *pstatus)
 {
 
 	if (!pstatus->packet_matchbssid)
@@ -280,3 +288,4 @@ void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
 	rtl_process_ui_link_quality(hw, pstatus);
 }
 EXPORT_SYMBOL(rtl_process_phyinfo);
+
diff --git a/drivers/net/wireless/rtlwifi/stats.h b/drivers/net/wireless/rtlwifi/stats.h
index 0dbdc52..6d0cbaa 100644
--- a/drivers/net/wireless/rtlwifi/stats.h
+++ b/drivers/net/wireless/rtlwifi/stats.h
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
@@ -39,8 +35,10 @@
 
 u8 rtl_query_rxpwrpercentage(char antpower);
 u8 rtl_evm_db_to_percentage(char value);
+u8 rtl_evm_dbm_jaguar(char value);
 long rtl_signal_scale_mapping(struct ieee80211_hw *hw, long currsig);
 void rtl_process_phyinfo(struct ieee80211_hw *hw, u8 *buffer,
-	struct rtl_stats *pstatus);
+			 struct rtl_stats *pstatus);
 
 #endif
+
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 1d58528..af7c6f2 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -951,6 +951,7 @@ struct wireless_stats {
 	long last_sigstrength_inpercent;
 
 	u32 rssi_calculate_cnt;
+	u32 pwdb_all_cnt;
 
 	/*Transformed, in dbm. Beautified signal
 	   strength for UI, not correct. */
@@ -1889,6 +1890,10 @@ struct rtl_stats {
 	bool rx_is40Mhzpacket;
 	u32 rx_pwdb_all;
 	u8 rx_mimo_signalstrength[4];	/*in 0~100 index */
+	u8 rx_mimo_evm_dbm[4];
+	u16 cfo_short[4];		/* per-path's Cfo_short */
+	u16 cfo_tail[4];
+
 	s8 rx_mimo_sig_qual[4];
 	u8 rx_pwr[4]; /* per-path's pwdb */
 	u8 rx_snr[4]; /* per-path's SNR */
-- 
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
