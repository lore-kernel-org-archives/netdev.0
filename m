From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT V3] rtlwifi: rtl8192c: rtl8192ce: Add support for B-CUT version of RTL8188CE
Date: Tue, 25 Sep 2012 16:51:13 -0500
Message-ID: <1348609873-16084-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Anisse Astier <anisse@astier.eu>,
	Li Chaoming <chaoming_li@realsil.com.cn>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42046 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab2IYVv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 17:51:27 -0400
Received: by ieak13 with SMTP id k13so15257916iea.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 14:51:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realtek devices with designation RTL8188CE-VL have the so-called B-cut
of the wireless chip. This patch adds the special programming needed by
these devices. In addition, a variable that was static has been moved into
the private data area as it is now needed in two different routines. This
change also fixes a minor bug that would be present if a system had more
than one RTL81{88,92}CE devices. Other drivers in the rtlwifi family had
already made this change, thus the variable already exists in the private
data structure.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Anisse Astier <anisse@astier.eu>
Cc: Li Chaoming <chaoming_li@realsil.com.cn>
---
 rtl8192c/phy_common.c |   21 +++++++++++++++++
 rtl8192ce/def.h       |    3 ++
 rtl8192ce/hw.c        |   60 +++++++++++++++++++++++++++++++++++++++++++++-----
 rtl8192ce/phy.c       |    2 +
 rtl8192ce/sw.c        |    6 +----
 rtl8192ce/trx.c       |    4 +--
 6 files changed, 85 insertions(+), 11 deletions(-)
---
V1 => V2	Remove extraneous white space.
V2 => V3	A change that is not part of the B-cut change and was introduced
		in V2 is moved to a separate patch. 

John,

This patch is too invasive to backport to the stable kernels, thus it should
be applied to 3.7.

Thanks,

Larry
---

Index: wireless-next/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
===================================================================
--- wireless-next.orig/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ wireless-next/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -724,6 +724,26 @@ u8 rtl92c_phy_sw_chnl(struct ieee80211_h
 }
 EXPORT_SYMBOL(rtl92c_phy_sw_chnl);
 
+static void _rtl92c_phy_sw_rf_setting(struct ieee80211_hw *hw, u8 channel)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+
+	if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
+		if (channel == 6 && rtlphy->current_chan_bw ==
+		    HT_CHANNEL_WIDTH_20)
+			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD,
+				      0x00255);
+		else{
+			u32 backupRF0x1A = (u32)rtl_get_rfreg(hw, RF90_PATH_A,
+					    RF_RX_G1, RFREG_OFFSET_MASK);
+			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD,
+				      backupRF0x1A);
+		}
+	}
+}
+
 static bool _rtl92c_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
 					     u32 cmdtableidx, u32 cmdtablesz,
 					     enum swchnlcmd_id cmdid,
@@ -837,6 +857,7 @@ bool _rtl92c_phy_sw_chnl_step_by_step(st
 					      currentcmd->para1,
 					      RFREG_OFFSET_MASK,
 					      rtlphy->rfreg_chnlval[rfpath]);
+			_rtl92c_phy_sw_rf_setting(hw, channel);
 			}
 			break;
 		default:
Index: wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
===================================================================
--- wireless-next.orig/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -116,6 +116,9 @@
 	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
 
 #define CHIP_VER_B			BIT(4)
+#define CHIP_BONDING_IDENTIFIER(_value) (((_value) >> 22) & 0x3)
+#define CHIP_BONDING_92C_1T2R		0x1
+#define RF_TYPE_1T2R			BIT(1)
 #define CHIP_92C_BITMASK		BIT(0)
 #define CHIP_92C_1T2R			0x03
 #define CHIP_92C			0x01
Index: wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
===================================================================
--- wireless-next.orig/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -896,7 +896,6 @@ int rtl92ce_hw_init(struct ieee80211_hw
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	static bool iqk_initialized; /* initialized to false */
 	bool rtstatus = true;
 	bool is92c;
 	int err;
@@ -921,9 +920,28 @@ int rtl92ce_hw_init(struct ieee80211_hw
 
 	rtlhal->last_hmeboxnum = 0;
 	rtl92c_phy_mac_config(hw);
+	/* because last function modify RCR, so we update
+	 * rcr var here, or TP will unstable for receive_config
+	 * is wrong, RX RCR_ACRC32 will cause TP unstabel & Rx
+	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252*/
+	rtlpci->receive_config = rtl_read_dword(rtlpriv, REG_RCR);
+	rtlpci->receive_config &= ~(RCR_ACRC32 | RCR_AICV);
+	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
 	rtl92c_phy_bb_config(hw);
 	rtlphy->rf_mode = RF_OP_BY_SW_3WIRE;
 	rtl92c_phy_rf_config(hw);
+	if (IS_VENDOR_UMC_A_CUT(rtlhal->version) &&
+	    !IS_92C_SERIAL(rtlhal->version)) {
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD, 0x30255);
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G2, MASKDWORD, 0x50a00);
+	} else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x0C, MASKDWORD, 0x894AE);
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x0A, MASKDWORD, 0x1AF31);
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_IPA, MASKDWORD, 0x8F425);
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_SYN_G2, MASKDWORD, 0x4F200);
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK1, MASKDWORD, 0x44053);
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK2, MASKDWORD, 0x80201);
+	}
 	rtlphy->rfreg_chnlval[0] = rtl_get_rfreg(hw, (enum radio_path)0,
 						 RF_CHNLBW, RFREG_OFFSET_MASK);
 	rtlphy->rfreg_chnlval[1] = rtl_get_rfreg(hw, (enum radio_path)1,
@@ -945,11 +963,11 @@ int rtl92ce_hw_init(struct ieee80211_hw
 
 	if (ppsc->rfpwr_state == ERFON) {
 		rtl92c_phy_set_rfpath_switch(hw, 1);
-		if (iqk_initialized) {
+		if (rtlphy->iqk_initialized) {
 			rtl92c_phy_iq_calibrate(hw, true);
 		} else {
 			rtl92c_phy_iq_calibrate(hw, false);
-			iqk_initialized = true;
+			rtlphy->iqk_initialized = true;
 		}
 
 		rtl92c_dm_check_txpower_tracking(hw);
@@ -1011,12 +1029,30 @@ static enum version_8192c _rtl92ce_read_
 	case VERSION_A_CHIP_88C:
 		versionid = "A_CHIP_88C";
 		break;
+	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_A_CUT:
+		versionid = "A_CUT_92C_1T2R";
+		break;
+	case VERSION_NORMAL_UMC_CHIP_92C_A_CUT:
+		versionid = "A_CUT_92C";
+		break;
+	case VERSION_NORMAL_UMC_CHIP_88C_A_CUT:
+		versionid = "A_CUT_88C";
+		break;
+	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_B_CUT:
+		versionid = "B_CUT_92C_1T2R";
+		break;
+	case VERSION_NORMAL_UMC_CHIP_92C_B_CUT:
+		versionid = "B_CUT_92C";
+		break;
+	case VERSION_NORMAL_UMC_CHIP_88C_B_CUT:
+		versionid = "B_CUT_88C";
+		break;
 	default:
 		versionid = "Unknown. Bug?";
 		break;
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
 		 "Chip Version ID: %s\n", versionid);
 
 	switch (version & 0x3) {
@@ -1189,6 +1225,7 @@ static void _rtl92ce_poweroff_adapter(st
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	u8 u1b_tmp;
 	u32 u4b_tmp;
 
@@ -1217,7 +1254,8 @@ static void _rtl92ce_poweroff_adapter(st
 	rtl_write_word(rtlpriv, REG_GPIO_IO_SEL, 0x0790);
 	rtl_write_word(rtlpriv, REG_LEDCFG0, 0x8080);
 	rtl_write_byte(rtlpriv, REG_AFE_PLL_CTRL, 0x80);
-	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
+	if (!IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
+		rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
 	if (rtlpcipriv->bt_coexist.bt_coexistence) {
 		u4b_tmp = rtl_read_dword(rtlpriv, REG_AFE_XTAL_CTRL);
 		u4b_tmp |= 0x03824800;
@@ -1246,6 +1284,9 @@ void rtl92ce_card_disable(struct ieee802
 		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
 	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 	_rtl92ce_poweroff_adapter(hw);
+
+	/* after power off we should do iqk again */
+	rtlpriv->phy.iqk_initialized = false;
 }
 
 void rtl92ce_interrupt_recognized(struct ieee80211_hw *hw,
@@ -1340,6 +1381,13 @@ static void _rtl92ce_read_txpower_info_f
 				    EEPROM_DEFAULT_TXPOWERLEVEL;
 			}
 		}
+		if (IS_92C_SERIAL(version)) {
+			value32 = rtl_read_dword(rtlpriv, REG_HPON_FSM);
+			version = (enum version_8192c)(version |
+				   ((CHIP_BONDING_IDENTIFIER(value32)
+				   == CHIP_BONDING_92C_1T2R) ?
+				   RF_TYPE_1T2R : 0));
+		}
 	}
 
 	for (i = 0; i < 3; i++) {
@@ -1904,6 +1952,8 @@ static void rtl92ce_update_hal_rate_mask
 			ratr_bitmap &= 0x0f0ff0ff;
 		break;
 	}
+	sta_entry->ratr_index = ratr_index;
+
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "ratr_bitmap :%x\n", ratr_bitmap);
 	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
Index: wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
===================================================================
--- wireless-next.orig/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -82,6 +82,8 @@ bool rtl92c_phy_mac_config(struct ieee80
 
 	if (is92c)
 		rtl_write_byte(rtlpriv, 0x14, 0x71);
+	else
+		rtl_write_byte(rtlpriv, 0x04CA, 0x0A);
 	return rtstatus;
 }
 
Index: wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
===================================================================
--- wireless-next.orig/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ wireless-next/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -127,11 +127,11 @@ static void _rtl92ce_query_rxphystatus(s
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct phy_sts_cck_8192s_t *cck_buf;
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
 	s8 rx_pwr_all = 0, rx_pwr[4];
 	u8 evm, pwdb_all, rf_rx_num = 0;
 	u8 i, max_spatial_stream;
 	u32 rssi, total_rssi = 0;
-	bool in_powersavemode = false;
 	bool is_cck_rate;
 
 	is_cck_rate = RX_HAL_IS_CCK_RATE(pdesc);
@@ -147,7 +147,7 @@ static void _rtl92ce_query_rxphystatus(s
 		u8 report, cck_highpwr;
 		cck_buf = (struct phy_sts_cck_8192s_t *)p_drvinfo;
 
-		if (!in_powersavemode)
+		if (ppsc->rfpwr_state == ERFON)
 			cck_highpwr = (u8) rtl_get_bbreg(hw,
 						 RFPGA0_XA_HSSIPARAMETER2,
 						 BIT(9));
