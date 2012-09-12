From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 15/15] rtlwifi: rtl8192ce: rtl8192cu: rtl8192se: rtl81723ae: Turn on building of the new driver
Date: Wed, 12 Sep 2012 15:54:54 -0500
Message-ID: <1347483294-6943-16-git-send-email-Larry.Finger@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, <chaoming_li@realsil.com.cn>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:49952 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab2ILUzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 16:55:51 -0400
In-Reply-To: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch completes the addition of the new driver for the Realtek
RTL8723AE devices by adding the make file and by modifying Kconfig
and Makefile of rtlwifi. Some variable names were shortened to ease
the problem of limiting all lines to 80 characters, thus changes were
made to wifi.h and rtl8192{ce,cu,sw}/hw.c.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: <chaoming_li@realsil.com.cn>
---
 drivers/net/wireless/rtlwifi/Kconfig            |   19 +++-
 drivers/net/wireless/rtlwifi/Makefile           |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c     |   83 ++++++++++++++---
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c     |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c     |    6 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile |   23 +++++
 drivers/net/wireless/rtlwifi/wifi.h             |  112 +++++++++++++++++++++--
 7 files changed, 225 insertions(+), 32 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index cefac6a..5299ccf 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -1,6 +1,6 @@
 config RTL8192CE
 	tristate "Realtek RTL8192CE/RTL8188CE Wireless Network Adapter"
-	depends on MAC80211 && PCI && EXPERIMENTAL
+	depends on MAC80211 && PCI
 	select FW_LOADER
 	select RTLWIFI
 	select RTL8192C_COMMON
@@ -12,7 +12,7 @@ config RTL8192CE
 
 config RTL8192SE
 	tristate "Realtek RTL8192SE/RTL8191SE PCIe Wireless Network Adapter"
-	depends on MAC80211 && EXPERIMENTAL && PCI
+	depends on MAC80211 && PCI
 	select FW_LOADER
 	select RTLWIFI
 	---help---
@@ -23,7 +23,7 @@ config RTL8192SE
 
 config RTL8192DE
 	tristate "Realtek RTL8192DE/RTL8188DE PCIe Wireless Network Adapter"
-	depends on MAC80211 && EXPERIMENTAL && PCI
+	depends on MAC80211 && PCI
 	select FW_LOADER
 	select RTLWIFI
 	---help---
@@ -32,9 +32,20 @@ config RTL8192DE
 
 	If you choose to build it as a module, it will be called rtl8192de
 
+config RTL8723E:
+	tristate "Realtek RTL8723E PCIe Wireless Network Adapter"
+	depends on MAC80211 && EXPERIMENTAL && PCI
+	select FW_LOADER
+	select RTLWIFI
+	---help---
+	This is the driver for Realtek RTL8723E 802.11n PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called rtl8723ae
+
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
-	depends on MAC80211 && USB && EXPERIMENTAL
+	depends on MAC80211 && USB
 	select FW_LOADER
 	select RTLWIFI
 	select RTL8192C_COMMON
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wireless/rtlwifi/Makefile
index 97935c5..3371697 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -7,7 +7,8 @@ rtlwifi-objs	:=		\
 		efuse.o		\
 		ps.o		\
 		rc.o		\
-		regd.o
+		regd.o		\
+		stats.o
 
 rtl8192c_common-objs +=		\
 
@@ -24,5 +25,6 @@ obj-$(CONFIG_RTL8192CE)		+= rtl8192ce/
 obj-$(CONFIG_RTL8192CU)		+= rtl8192cu/
 obj-$(CONFIG_RTL8192SE)		+= rtl8192se/
 obj-$(CONFIG_RTL8192DE)		+= rtl8192de/
+obj-$(CONFIG_RTL8723E)		+= rtl8723ae/
 
 ccflags-y += -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index cc89582..a359b83 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -896,7 +896,6 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	static bool iqk_initialized; /* initialized to false */
 	bool rtstatus = true;
 	bool is92c;
 	int err;
@@ -921,9 +920,28 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 
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
@@ -945,11 +963,11 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 
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
@@ -994,8 +1012,23 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
 		version = (value32 & TYPE_ID) ? VERSION_A_CHIP_92C :
 			   VERSION_A_CHIP_88C;
 	} else {
-		version = (value32 & TYPE_ID) ? VERSION_B_CHIP_92C :
-			   VERSION_B_CHIP_88C;
+		version = (enum version_8192c) (CHIP_VER_B |
+				((value32 & TYPE_ID) ? CHIP_92C_BITMASK : 0) |
+				((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
+		if ((!IS_CHIP_VENDOR_UMC(version)) && (value32 &
+		     CHIP_VER_RTL_MASK)) {
+			version = (enum version_8192c)(version |
+				   ((((value32 & CHIP_VER_RTL_MASK) == BIT(12))
+				   ? CHIP_VENDOR_UMC_B_CUT : CHIP_UNKNOWN) |
+				   CHIP_VENDOR_UMC));
+		}
+		if (IS_92C_SERIAL(version)) {
+			value32 = rtl_read_dword(rtlpriv, REG_HPON_FSM);
+			version = (enum version_8192c)(version |
+				   ((CHIP_BONDING_IDENTIFIER(value32)
+				   == CHIP_BONDING_92C_1T2R) ?
+				   RF_TYPE_1T2R : 0));
+		}
 	}
 
 	switch (version) {
@@ -1011,12 +1044,30 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
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
@@ -1189,6 +1240,7 @@ static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	u8 u1b_tmp;
 	u32 u4b_tmp;
 
@@ -1217,7 +1269,8 @@ static void _rtl92ce_poweroff_adapter(struct ieee80211_hw *hw)
 	rtl_write_word(rtlpriv, REG_GPIO_IO_SEL, 0x0790);
 	rtl_write_word(rtlpriv, REG_LEDCFG0, 0x8080);
 	rtl_write_byte(rtlpriv, REG_AFE_PLL_CTRL, 0x80);
-	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
+	if (!IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
+		rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x23);
 	if (rtlpcipriv->bt_coexist.bt_coexistence) {
 		u4b_tmp = rtl_read_dword(rtlpriv, REG_AFE_XTAL_CTRL);
 		u4b_tmp |= 0x03824800;
@@ -1246,6 +1299,9 @@ void rtl92ce_card_disable(struct ieee80211_hw *hw)
 		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
 	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 	_rtl92ce_poweroff_adapter(hw);
+
+	/* after power off we should do iqk again */
+	rtlpriv->phy.iqk_initialized = false;
 }
 
 void rtl92ce_interrupt_recognized(struct ieee80211_hw *hw,
@@ -1347,9 +1403,9 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			tempval = hwinfo[EEPROM_TXPOWERHT40_2SDIFF + i];
 		else
 			tempval = EEPROM_DEFAULT_HT40_2SDIFF;
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_A][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_A][i] =
 		    (tempval & 0xf);
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_B][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_B][i] =
 		    ((tempval & 0xf0) >> 4);
 	}
 
@@ -1373,7 +1429,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
 				rtlefuse->
-				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
+				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
@@ -1388,14 +1444,14 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			if ((rtlefuse->
 			     eeprom_chnlarea_txpwr_ht40_1s[rf_path][index] -
 			     rtlefuse->
-			     eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][index])
+			     eprom_chnl_txpwr_ht40_2sdf[rf_path][index])
 			    > 0) {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
 				    rtlefuse->
 				    eeprom_chnlarea_txpwr_ht40_1s[rf_path]
 				    [index] -
 				    rtlefuse->
-				    eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
+				    eprom_chnl_txpwr_ht40_2sdf[rf_path]
 				    [index];
 			} else {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;
@@ -1904,6 +1960,8 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
 			ratr_bitmap &= 0x0f0ff0ff;
 		break;
 	}
+	sta_entry->ratr_index = ratr_index;
+
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "ratr_bitmap :%x\n", ratr_bitmap);
 	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
@@ -2283,3 +2341,4 @@ void rtl92ce_suspend(struct ieee80211_hw *hw)
 void rtl92ce_resume(struct ieee80211_hw *hw)
 {
 }
+
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 4bbb711..e06f1be 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -152,9 +152,9 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			tempval = hwinfo[EEPROM_TXPOWERHT40_2SDIFF + i];
 		else
 			tempval = EEPROM_DEFAULT_HT40_2SDIFF;
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_A][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_A][i] =
 		    (tempval & 0xf);
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_B][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_B][i] =
 		    ((tempval & 0xf0) >> 4);
 	}
 	for (rf_path = 0; rf_path < 2; rf_path++)
@@ -177,7 +177,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
 				rtlefuse->
-				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
+				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
 			index = _rtl92c_get_chnl_group((u8) i);
@@ -189,13 +189,13 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			if ((rtlefuse->
 			     eeprom_chnlarea_txpwr_ht40_1s[rf_path][index] -
 			     rtlefuse->
-			     eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][index])
+			     eprom_chnl_txpwr_ht40_2sdf[rf_path][index])
 			    > 0) {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
 				    rtlefuse->
 				    eeprom_chnlarea_txpwr_ht40_1s[rf_path]
 				    [index] - rtlefuse->
-				    eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
+				    eprom_chnl_txpwr_ht40_2sdf[rf_path]
 				    [index];
 			} else {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 4542e69..1d72779 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1697,7 +1697,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 			hwinfo[EEPROM_TXPOWERBASE + 6 + rf_path * 3 + i];
 
 			/* Read OFDM RF A & B Tx power for 2T */
-			rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]
+			rtlefuse->eprom_chnl_txpwr_ht40_2sdf[rf_path][i]
 				 = hwinfo[EEPROM_TXPOWERBASE + 12 +
 				   rf_path * 3 + i];
 		}
@@ -1722,7 +1722,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
 				[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
@@ -1748,7 +1748,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
 							[rf_path][index];
 			rtlefuse->txpwrlevel_ht40_2s[rf_path][i]  =
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
 							[rf_path][index];
 		}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile b/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
new file mode 100644
index 0000000..6a626c1
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
@@ -0,0 +1,23 @@
+obj-m := rtl8723ae.o
+
+
+rtl8723ae-objs :=		\
+		dm.o		\
+		fw.o		\
+		hal_btc.o	\
+		hal_bt_coexist.o\
+		hw.o		\
+		led.o		\
+		phy.o		\
+		pwrseq.o	\
+		pwrseqcmd.o	\
+		rf.o		\
+		sw.o		\
+		table.o		\
+		trx.o		\
+
+
+obj-$(CONFIG_RTL8723E) += rtl8723ae.o
+
+ccflags-y += -D__CHECK_ENDIAN__
+Index: wireless-testing-new/drivers/net/wireless/rtlwifi/Makefile
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index f1b6bc6..12950a1 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -350,6 +350,11 @@ enum rt_oem_id {
 	RT_CID_819x_WNC_COREGA = 31,
 	RT_CID_819x_Foxcoon = 32,
 	RT_CID_819x_DELL = 33,
+	RT_CID_819x_PRONETS = 34,
+	RT_CID_819x_Edimax_ASUS = 35,
+	RT_CID_NETGEAR = 36,
+	RT_CID_PLANEX = 37,
+	RT_CID_CC_C = 38,
 };
 
 enum hw_descs {
@@ -505,6 +510,7 @@ enum rtl_var_map {
 	RTL_IMR_ROK,		/*Receive DMA OK Interrupt */
 	RTL_IBSS_INT_MASKS,	/*(RTL_IMR_BcnInt | RTL_IMR_TBDOK |
 				 * RTL_IMR_TBDER) */
+	RTL_IMR_C2HCMD,		/*fw interrupt*/
 
 	/*CCK Rates, TxHT = 0 */
 	RTL_RC_CCK_RATE1M,
@@ -661,6 +667,11 @@ enum ba_action {
 	ACT_DELBA = 2,
 };
 
+enum rt_polarity_ctl {
+	RT_POLARITY_LOW_ACT = 0,
+	RT_POLARITY_HIGH_ACT = 1,
+};
+
 struct octet_string {
 	u8 *octet;
 	u16 length;
@@ -903,6 +914,8 @@ struct rtl_phy {
 	u8 num_total_rfpath;
 	struct phy_parameters hwparam_tables[MAX_TAB];
 	u16 rf_pathmap;
+
+	enum rt_polarity_ctl polarity_ctl;
 };
 
 #define MAX_TID_COUNT				9
@@ -1042,13 +1055,64 @@ struct rtl_mac {
 	/*QOS & EDCA */
 	struct ieee80211_tx_queue_params edca_param[RTL_MAC80211_NUM_QUEUE];
 	struct rtl_qos_parameters ac[AC_MAX];
+
+	/* counters */
+	u64 last_txok_cnt;
+	u64 last_rxok_cnt;
+	u32 last_bt_edca_ul;
+	u32 last_bt_edca_dl;
+};
+
+struct btdm_8723 {
+	bool all_off;
+	bool agc_table_en;
+	bool adc_back_off_on;
+	bool b2_ant_hid_en;
+	bool low_penalty_rate_adaptive;
+	bool rf_rx_lpf_shrink;
+	bool reject_aggre_pkt;
+	bool tra_tdma_on;
+	u8 tra_tdma_nav;
+	u8 tra_tdma_ant;
+	bool tdma_on;
+	u8 tdma_ant;
+	u8 tdma_nav;
+	u8 tdma_dac_swing;
+	u8 fw_dac_swing_lvl;
+	bool ps_tdma_on;
+	u8 ps_tdma_byte[5];
+	bool pta_on;
+	u32 val_0x6c0;
+	u32 val_0x6c8;
+	u32 val_0x6cc;
+	bool sw_dac_swing_on;
+	u32 sw_dac_swing_lvl;
+	u32 wlan_act_hi;
+	u32 wlan_act_lo;
+	u32 bt_retry_index;
+	bool dec_bt_pwr;
+	bool ignore_wlan_act;
+};
+
+struct bt_coexist_8723 {
+	u32 high_priority_tx;
+	u32 high_priority_rx;
+	u32 low_priority_tx;
+	u32 low_priority_rx;
+	u8 c2h_bt_info;
+	bool c2h_bt_info_req_sent;
+	bool c2h_bt_inquiry_page;
+	u32 bt_inq_page_start_time;
+	u8 bt_retry_cnt;
+	u8 c2h_bt_info_original;
+	u8 bt_inquiry_page_cnt;
+	struct btdm_8723 btdm;
 };
 
 struct rtl_hal {
 	struct ieee80211_hw *hw;
-
+	struct bt_coexist_8723 hal_coex_8723;
 	bool up_first_time;
-	bool first_init;
 	bool being_init_adapter;
 	bool bbrf_ready;
 
@@ -1209,7 +1273,7 @@ struct rtl_efuse {
 	u8 eeprom_pwrlimit_ht40[CHANNEL_GROUP_MAX];
 	u8 eeprom_chnlarea_txpwr_cck[2][CHANNEL_GROUP_MAX_2G];
 	u8 eeprom_chnlarea_txpwr_ht40_1s[2][CHANNEL_GROUP_MAX];
-	u8 eeprom_chnlarea_txpwr_ht40_2sdiif[2][CHANNEL_GROUP_MAX];
+	u8 eprom_chnl_txpwr_ht40_2sdf[2][CHANNEL_GROUP_MAX];
 	u8 txpwrlevel_cck[2][CHANNEL_MAX_NUMBER_2G];
 	u8 txpwrlevel_ht40_1s[2][CHANNEL_MAX_NUMBER];	/*For HT 40MHZ pwr */
 	u8 txpwrlevel_ht40_2s[2][CHANNEL_MAX_NUMBER];	/*For HT 40MHZ pwr */
@@ -1312,6 +1376,7 @@ struct rtl_ps_ctl {
 };
 
 struct rtl_stats {
+	u8 psaddr[ETH_ALEN];
 	u32 mac_time[2];
 	s8 rssi;
 	u8 signal;
@@ -1503,6 +1568,11 @@ struct rtl_hal_ops {
 	void (*phy_lc_calibrate) (struct ieee80211_hw *hw, bool is2t);
 	void (*phy_set_bw_mode_callback) (struct ieee80211_hw *hw);
 	void (*dm_dynamic_txpower) (struct ieee80211_hw *hw);
+	void (*c2h_command_handle) (struct ieee80211_hw *hw);
+	void (*bt_wifi_media_status_notify) (struct ieee80211_hw *hw,
+					     bool mstate);
+	void (*bt_turn_off_bt_coexist_before_enter_lps)
+					 (struct ieee80211_hw *hw);
 };
 
 struct rtl_intf_ops {
@@ -1781,9 +1851,22 @@ struct rtl_priv {
 	struct dig_t dm_digtable;
 	struct ps_t dm_pstable;
 
-	/* data buffer pointer for USB reads */
-	__le32 *usb_data;
-	int usb_data_index;
+	/* section shared by individual drivers */
+	union {
+		struct {	/* data buffer pointer for USB reads */
+			__le32 *usb_data;
+			int usb_data_index;
+			bool initialized;
+		};
+		struct {	/* section for 8723ae */
+			bool reg_init;	/* true if regs saved */
+			u32 reg_874;
+			u32 reg_c70;
+			u32 reg_85c;
+			u32 reg_a74;
+			bool bt_operation_on;
+		};
+	};
 
 	/*This must be the last item so
 	   that it points to the data allocated
@@ -1815,6 +1898,7 @@ enum bt_co_type {
 	BT_CSR_BC4 = 3,
 	BT_CSR_BC8 = 4,
 	BT_RTL8756 = 5,
+	BT_RTL8723A = 6,
 };
 
 enum bt_cur_state {
@@ -1873,13 +1957,27 @@ struct bt_coexist_info {
 
 	bool fw_coexist_all_off;
 	bool sw_coexist_all_off;
+	bool hw_coexist_all_off;
 	u32 current_state;
 	u32 previous_state;
+	u32 current_state_h;
+	u32 previous_state_h;
+
 	u8 bt_pre_rssi_state;
+	u8 bt_pre_rssi_state1;
 
 	u8 reg_bt_iso;
 	u8 reg_bt_sco;
-
+	bool balance_on;
+	u8 bt_active_zero_cnt;
+	bool cur_bt_disabled;
+	bool pre_bt_disabled;
+
+	u8 bt_profile_case;
+	u8 bt_profile_action;
+	bool bt_busy;
+	bool hold_for_bt_operation;
+	u8 lps_counter;
 };
 
 
-- 
1.7.10.4
