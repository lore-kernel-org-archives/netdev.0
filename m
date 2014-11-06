From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3 3.18] rtlwifi: rtl8192se: Fix connection problems
Date: Wed,  5 Nov 2014 19:10:54 -0600
Message-ID: <1415236254-12274-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:47623 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaKFBLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 20:11:21 -0500
In-Reply-To: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in the vendor driver were added to rtlwifi, but some updates
to rtl8192se were missed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c  | 129 +++++++++++++--------------
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c |   8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  |   4 +
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  23 +++++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.h |   4 +
 5 files changed, 100 insertions(+), 68 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 00e0670..4626203 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1170,27 +1170,32 @@ static int _rtl92se_set_media_status(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 bt_msr = rtl_read_byte(rtlpriv, MSR);
+	enum led_ctl_mode ledaction = LED_CTL_NO_LINK;
 	u32 temp;
+	u8 mode = MSR_NOLINK;
+
 	bt_msr &= ~MSR_LINK_MASK;
 
 	switch (type) {
 	case NL80211_IFTYPE_UNSPECIFIED:
-		bt_msr |= (MSR_LINK_NONE << MSR_LINK_SHIFT);
+		mode = MSR_NOLINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
-		bt_msr |= (MSR_LINK_ADHOC << MSR_LINK_SHIFT);
+		mode = MSR_ADHOC;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
-		bt_msr |= (MSR_LINK_MANAGED << MSR_LINK_SHIFT);
+		mode = MSR_INFRA;
+		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
-		bt_msr |= (MSR_LINK_MASTER << MSR_LINK_SHIFT);
+		mode = MSR_AP;
+		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to AP!\n");
 		break;
@@ -1201,7 +1206,17 @@ static int _rtl92se_set_media_status(struct ieee80211_hw *hw,
 
 	}
 
-	rtl_write_byte(rtlpriv, (MSR), bt_msr);
+	/* MSR_INFRA == Link in infrastructure network;
+	 * MSR_ADHOC == Link in ad hoc network;
+	 * Therefore, check link state is necessary.
+	 *
+	 * MSR_AP == AP mode; link state is not cared here.
+	 */
+	if (mode != MSR_AP && rtlpriv->mac80211.link_state < MAC80211_LINKED) {
+		mode = MSR_NOLINK;
+		ledaction = LED_CTL_NO_LINK;
+}
+	rtl_write_byte(rtlpriv, (MSR), bt_msr | mode);
 
 	temp = rtl_read_dword(rtlpriv, TCR);
 	rtl_write_dword(rtlpriv, TCR, temp & (~BIT(8)));
@@ -1262,6 +1277,7 @@ void rtl92se_enable_interrupt(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, INTA_MASK, rtlpci->irq_mask[0]);
 	/* Support Bit 32-37(Assign as Bit 0-5) interrupt setting now */
 	rtl_write_dword(rtlpriv, INTA_MASK + 4, rtlpci->irq_mask[1] & 0x3F);
+	rtlpci->irq_enabled = true;
 }
 
 void rtl92se_disable_interrupt(struct ieee80211_hw *hw)
@@ -1276,8 +1292,7 @@ void rtl92se_disable_interrupt(struct ieee80211_hw *hw)
 	rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	rtl_write_dword(rtlpriv, INTA_MASK, 0);
 	rtl_write_dword(rtlpriv, INTA_MASK + 4, 0);
-
-	synchronize_irq(rtlpci->pdev->irq);
+	rtlpci->irq_enabled = false;
 }
 
 static u8 _rtl92s_set_sysclk(struct ieee80211_hw *hw, u8 data)
@@ -2035,9 +2050,9 @@ static void rtl92se_update_hal_rate_table(struct ieee80211_hw *hw,
 	u32 ratr_value;
 	u8 ratr_index = 0;
 	u8 nmode = mac->ht_enable;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
 	u16 shortgi_rate = 0;
 	u32 tmp_ratr_value = 0;
+	u32 ratr_mask;
 	u8 curtxbw_40mhz = mac->bw_40;
 	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
 				1 : 0;
@@ -2063,26 +2078,21 @@ static void rtl92se_update_hal_rate_table(struct ieee80211_hw *hw,
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		nmode = 1;
-		if (mimo_ps == IEEE80211_SMPS_STATIC) {
-			ratr_value &= 0x0007F005;
-		} else {
-			u32 ratr_mask;
 
-			if (get_rf_type(rtlphy) == RF_1T2R ||
-			    get_rf_type(rtlphy) == RF_1T1R) {
-				if (curtxbw_40mhz)
-					ratr_mask = 0x000ff015;
-				else
-					ratr_mask = 0x000ff005;
-			} else {
-				if (curtxbw_40mhz)
-					ratr_mask = 0x0f0ff015;
-				else
-					ratr_mask = 0x0f0ff005;
-			}
-
-			ratr_value &= ratr_mask;
+		if (get_rf_type(rtlphy) == RF_1T2R ||
+		    get_rf_type(rtlphy) == RF_1T1R) {
+			if (curtxbw_40mhz)
+				ratr_mask = 0x000ff015;
+			else
+				ratr_mask = 0x000ff005;
+		} else {
+			if (curtxbw_40mhz)
+				ratr_mask = 0x0f0ff015;
+			else
+				ratr_mask = 0x0f0ff005;
 		}
+
+		ratr_value &= ratr_mask;
 		break;
 	default:
 		if (rtlphy->rf_type == RF_1T2R)
@@ -2137,7 +2147,8 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 	struct rtl_sta_info *sta_entry = NULL;
 	u32 ratr_bitmap;
 	u8 ratr_index = 0;
-	u8 curtxbw_40mhz = (sta->bandwidth >= IEEE80211_STA_RX_BW_40) ? 1 : 0;
+	u8 curtxbw_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40)
+				? 1 : 0;
 	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
 				1 : 0;
 	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
@@ -2148,9 +2159,7 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 	u8 shortgi_rate = 0;
 	u32 mask = 0;
 	u32 band = 0;
-	bool bmulticast = false;
 	u8 macid = 0;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
 
 	sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 	wirelessmode = sta_entry->wireless_mode;
@@ -2198,41 +2207,32 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 		band |= (WIRELESS_11N | WIRELESS_11G | WIRELESS_11B);
 		ratr_index = RATR_INX_WIRELESS_NGB;
 
-		if (mimo_ps == IEEE80211_SMPS_STATIC) {
-			if (rssi_level == 1)
-				ratr_bitmap &= 0x00070000;
-			else if (rssi_level == 2)
-				ratr_bitmap &= 0x0007f000;
-			else
-				ratr_bitmap &= 0x0007f005;
+		if (rtlphy->rf_type == RF_1T2R ||
+			rtlphy->rf_type == RF_1T1R) {
+			if (rssi_level == 1) {
+					ratr_bitmap &= 0x000f0000;
+			} else if (rssi_level == 3) {
+				ratr_bitmap &= 0x000fc000;
+			} else if (rssi_level == 5) {
+					ratr_bitmap &= 0x000ff000;
+			} else {
+				if (curtxbw_40mhz)
+					ratr_bitmap &= 0x000ff015;
+				else
+					ratr_bitmap &= 0x000ff005;
+			}
 		} else {
-			if (rtlphy->rf_type == RF_1T2R ||
-				rtlphy->rf_type == RF_1T1R) {
-				if (rssi_level == 1) {
-						ratr_bitmap &= 0x000f0000;
-				} else if (rssi_level == 3) {
-					ratr_bitmap &= 0x000fc000;
-				} else if (rssi_level == 5) {
-						ratr_bitmap &= 0x000ff000;
-				} else {
-					if (curtxbw_40mhz)
-						ratr_bitmap &= 0x000ff015;
-					else
-						ratr_bitmap &= 0x000ff005;
-				}
+			if (rssi_level == 1) {
+				ratr_bitmap &= 0x0f8f0000;
+			} else if (rssi_level == 3) {
+				ratr_bitmap &= 0x0f8fc000;
+			} else if (rssi_level == 5) {
+				ratr_bitmap &= 0x0f8ff000;
 			} else {
-				if (rssi_level == 1) {
-					ratr_bitmap &= 0x0f8f0000;
-				} else if (rssi_level == 3) {
-					ratr_bitmap &= 0x0f8fc000;
-				} else if (rssi_level == 5) {
-					ratr_bitmap &= 0x0f8ff000;
-				} else {
-					if (curtxbw_40mhz)
-						ratr_bitmap &= 0x0f8ff015;
-					else
-						ratr_bitmap &= 0x0f8ff005;
-				}
+				if (curtxbw_40mhz)
+					ratr_bitmap &= 0x0f8ff015;
+				else
+					ratr_bitmap &= 0x0f8ff005;
 			}
 		}
 
@@ -2275,15 +2275,12 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 		rtl_write_byte(rtlpriv, SG_RATE, shortgi_rate);
 	}
 
-	mask |= (bmulticast ? 1 : 0) << 9 | (macid & 0x1f) << 4 | (band & 0xf);
+	mask |= (macid & 0x1f) << 4 | (band & 0xf);
 
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_TRACE, "mask = %x, bitmap = %x\n",
 		 mask, ratr_bitmap);
 	rtl_write_dword(rtlpriv, 0x2c4, ratr_bitmap);
 	rtl_write_dword(rtlpriv, WFM5, (FW_RA_UPDATE_MASK | (mask << 8)));
-
-	if (macid != 0)
-		sta_entry->ratr_index = ratr_index;
 }
 
 void rtl92se_update_hal_rate_tbl(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index 77c5b5f..e382cef 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -399,6 +399,11 @@ static bool _rtl92s_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 		case 2:
 			currentcmd = &postcommoncmd[*step];
 			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "Invalid 'stage' = %d, Check it!\n",
+				 *stage);
+			return true;
 		}
 
 		if (currentcmd->cmdid == CMDID_END) {
@@ -602,7 +607,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		}
 	case ERFSLEEP:
 			if (ppsc->rfpwr_state == ERFOFF)
-				return false;
+				break;
 
 			for (queue_id = 0, i = 0;
 			     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
@@ -1064,7 +1069,6 @@ bool rtl92s_phy_bb_config(struct ieee80211_hw *hw)
 	/* Check BB/RF confiuration setting. */
 	/* We only need to configure RF which is turned on. */
 	path1 = (u8)(rtl92s_phy_query_bb_reg(hw, RFPGA0_TXINFO, 0xf));
-	mdelay(10);
 	path2 = (u8)(rtl92s_phy_query_bb_reg(hw, ROFDM0_TRXPATHENABLE, 0xf));
 	pathmap = path1 | path2;
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index aadba29..3c4238e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -269,6 +269,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops = {
 	.led_control = rtl92se_led_control,
 	.set_desc = rtl92se_set_desc,
 	.get_desc = rtl92se_get_desc,
+	.is_tx_desc_closed = rtl92se_is_tx_desc_closed,
 	.tx_polling = rtl92se_tx_polling,
 	.enable_hw_sec = rtl92se_enable_hw_security_config,
 	.set_key = rtl92se_set_key,
@@ -278,6 +279,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops = {
 	.get_rfreg = rtl92s_phy_query_rf_reg,
 	.set_rfreg = rtl92s_phy_set_rf_reg,
 	.get_btc_status = rtl_btc_status_false,
+	.rx_command_packet = rtl92se_rx_command_packet,
 };
 
 static struct rtl_mod_params rtl92se_mod_params = {
@@ -306,6 +308,8 @@ static struct rtl_hal_cfg rtl92se_hal_cfg = {
 	.maps[MAC_RCR_ACRC32] = RCR_ACRC32,
 	.maps[MAC_RCR_ACF] = RCR_ACF,
 	.maps[MAC_RCR_AAP] = RCR_AAP,
+	.maps[MAC_HIMR] = INTA_MASK,
+	.maps[MAC_HIMRE] = INTA_MASK + 4,
 
 	.maps[EFUSE_TEST] = REG_EFUSE_TEST,
 	.maps[EFUSE_CTRL] = REG_EFUSE_CTRL,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 672fd3b..2014b18 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -652,8 +652,31 @@ u32 rtl92se_get_desc(u8 *desc, bool istx, u8 desc_name)
 	return ret;
 }
 
+bool rtl92se_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
+	u8 own = (u8)rtl92se_get_desc(entry, true, HW_DESC_OWN);
+
+	/* beacon packet will only use the first
+	 * descriptor iby default, and the own bit may not
+	 * be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	return true;
+}
+
 void rtl92se_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	rtl_write_word(rtlpriv, TP_POLL, BIT(0) << (hw_queue));
 }
+
+u32 rtl92se_rx_command_packet(struct ieee80211_hw *hw,
+			      struct rtl_stats status,
+			      struct sk_buff *skb)
+{
+	return 0;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.h b/drivers/net/wireless/rtlwifi/rtl8192se/trx.h
index 5a13f17..bd9f4bf 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.h
@@ -43,6 +43,10 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 void rtl92se_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 		      u8 desc_name, u8 *val);
 u32 rtl92se_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl92se_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index);
 void rtl92se_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
+u32 rtl92se_rx_command_packet(struct ieee80211_hw *hw,
+			      struct rtl_stats status,
+			      struct sk_buff *skb);
 
 #endif
-- 
2.1.2
