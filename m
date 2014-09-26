From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 4/7 NEXT] rtlwifi: rtl8723be: Update driver to match Realtek release of 06/28/14
Date: Fri, 26 Sep 2014 16:40:25 -0500
Message-ID: <1411767628-7965-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:50502 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756345AbaIZVky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:40:54 -0400
In-Reply-To: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the driver to match the latest Realtek release, and
it is an important step in getting the internal code source at Realtek to match
the code in the kernel. The primary reason for this is to make it easier for
Realtek to maintain the kernel source without requiring an intermediate like me.

In this process of merging the two source repositories, there are a lot
of changes in both, and this commit is rather large.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |   18 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/def.h       |  178 +-
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c        |  243 +--
 drivers/net/wireless/rtlwifi/rtl8723be/dm.h        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |  193 ++-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.h        |  200 +--
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        | 1319 +++++++++------
 drivers/net/wireless/rtlwifi/rtl8723be/hw.h        |    1 +
 drivers/net/wireless/rtlwifi/rtl8723be/led.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c       | 1783 +++++++++++++-------
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h       |  110 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h    |  131 +-
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h       | 1135 +++++++------
 drivers/net/wireless/rtlwifi/rtl8723be/rf.c        |  144 +-
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |   40 +-
 drivers/net/wireless/rtlwifi/rtl8723be/table.c     | 1053 ++++++------
 drivers/net/wireless/rtlwifi/rtl8723be/table.h     |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |  307 ++--
 drivers/net/wireless/rtlwifi/rtl8723be/trx.h       |   34 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |    8 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |   22 +-
 .../net/wireless/rtlwifi/rtl8723com/phy_common.c   |   19 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |    3 +
 drivers/net/wireless/rtlwifi/wifi.h                |    8 +-
 30 files changed, 3833 insertions(+), 3167 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 8f04817..c140123 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -125,7 +125,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 	u32 rssi, total_rssi = 0;
 	bool is_cck_rate;
 
-	is_cck_rate = RX_HAL_IS_CCK_RATE(pdesc);
+	is_cck_rate = RX_HAL_IS_CCK_RATE(pdesc->rxmcs);
 	pstats->packet_matchbssid = packet_match_bssid;
 	pstats->packet_toself = packet_toself;
 	pstats->is_cck = is_cck_rate;
@@ -361,7 +361,7 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 	stats->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
 	stats->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
 
-	stats->is_cck = RX_HAL_IS_CCK_RATE(pdesc);
+	stats->is_cck = RX_HAL_IS_CCK_RATE(pdesc->rxmcs);
 
 	rx_status->freq = hw->conf.chandef.chan->center_freq;
 	rx_status->band = hw->conf.chandef.chan->band;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index e26312f..4da4008 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -786,7 +786,7 @@ static void _rtl92c_query_rxphystatus(struct ieee80211_hw *hw,
 	bool is_cck_rate;
 	u8 *pdesc = (u8 *)p_desc;
 
-	is_cck_rate = RX_HAL_IS_CCK_RATE(p_desc);
+	is_cck_rate = RX_HAL_IS_CCK_RATE(p_desc->rxmcs);
 	pstats->packet_matchbssid = packet_match_bssid;
 	pstats->packet_toself = packet_toself;
 	pstats->packet_beacon = packet_beacon;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 99c2ab5..8efbcc7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -127,7 +127,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 	u32 rssi, total_rssi = 0;
 	bool is_cck_rate;
 
-	is_cck_rate = RX_HAL_IS_CCK_RATE(pdesc);
+	is_cck_rate = RX_HAL_IS_CCK_RATE(pdesc->rxmcs);
 	pstats->packet_matchbssid = packet_match_bssid;
 	pstats->packet_toself = packet_toself;
 	pstats->packet_beacon = packet_beacon;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
index ad70f2b..9d1fe25 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
@@ -34,7 +34,6 @@
 #define FW_8192C_END_ADDRESS			0x3FFF
 #define FW_8192C_PAGE_SIZE				4096
 #define FW_8192C_POLLING_DELAY			5
-#define FW_8192C_POLLING_TIMEOUT_COUNT	1000
 
 #define IS_FW_HEADER_EXIST(_pfwhdr)	\
 	((_pfwhdr->signature&0xFFFF) == 0x2300 ||\
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 9e1671c..aa08546 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -963,7 +963,7 @@ int rtl8723e_hw_init(struct ieee80211_hw *hw)
 		goto exit;
 	}
 
-	err = rtl8723_download_fw(hw, false, FW_8192C_POLLING_TIMEOUT_COUNT);
+	err = rtl8723_download_fw(hw, false, FW_8723A_POLLING_TIMEOUT_COUNT);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Failed to download FW. Init HW without FW now..\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
index 1e2fa93..d367097 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
@@ -1157,16 +1157,6 @@ static bool _rtl8723e_phy_simularity_compare(struct ieee80211_hw *hw,
 
 }
 
-static void rtl8723_phy_save_adda_registers(struct ieee80211_hw *hw,
-					    u32 *addareg, u32 *addabackup,
-					    u32 registernum)
-{
-	u32 i;
-
-	for (i = 0; i < registernum; i++)
-		addabackup[i] = rtl_get_bbreg(hw, addareg[i], MASKDWORD);
-}
-
 static void _rtl8723e_phy_iq_calibrate(struct ieee80211_hw *hw,
 				       long result[][8], u8 t, bool is2t)
 {
@@ -1192,8 +1182,8 @@ static void _rtl8723e_phy_iq_calibrate(struct ieee80211_hw *hw,
 	if (t == 0) {
 		bbvalue = rtl_get_bbreg(hw, 0x800, MASKDWORD);
 
-		rtl8723_phy_save_adda_registers(hw, adda_reg,
-						rtlphy->adda_backup, 16);
+		rtl8723_save_adda_registers(hw, adda_reg,
+					    rtlphy->adda_backup, 16);
 		rtl8723_phy_save_mac_registers(hw, iqk_mac_reg,
 					       rtlphy->iqk_mac_backup);
 	}
@@ -1472,8 +1462,8 @@ void rtl8723e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery)
 		rtl8723_phy_path_a_fill_iqk_matrix(hw, b_patha_ok, result,
 						   final_candidate,
 						   (reg_ea4 == 0));
-	rtl8723_phy_save_adda_registers(hw, iqk_bb_reg,
-					rtlphy->iqk_bb_backup, 10);
+	rtl8723_save_adda_registers(hw, iqk_bb_reg,
+				    rtlphy->iqk_bb_backup, 10);
 }
 
 void rtl8723e_phy_lc_calibrate(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index ca84150..1da2367 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -463,7 +463,7 @@ bool rtl8723e_rx_query_desc(struct ieee80211_hw *hw,
 	status->rx_is40Mhzpacket = (bool)GET_RX_DESC_BW(pdesc);
 	status->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
 
-	status->is_cck = RTL8723E_RX_HAL_IS_CCK_RATE(status->rate);
+	status->is_cck = RX_HAL_IS_CCK_RATE(status->rate);
 
 	rx_status->freq = hw->conf.chandef.chan->center_freq;
 	rx_status->band = hw->conf.chandef.chan->band;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/def.h b/drivers/net/wireless/rtlwifi/rtl8723be/def.h
index 3c30b74..025ea5c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/def.h
@@ -26,158 +26,24 @@
 #ifndef __RTL8723BE_DEF_H__
 #define __RTL8723BE_DEF_H__
 
-#define HAL_RETRY_LIMIT_INFRA				48
-#define HAL_RETRY_LIMIT_AP_ADHOC			7
-
-#define RESET_DELAY_8185				20
-
-#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
-#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
-
-#define NUM_OF_FIRMWARE_QUEUE			10
-#define NUM_OF_PAGES_IN_FW			0x100
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK		0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE		0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI		0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO		0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA		0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_CMD		0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT		0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH		0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_BCN		0x2
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB		0xA1
-
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM		0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM		0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM		0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM		0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM		0x00
-
-#define MAX_LINES_HWCONFIG_TXT			1000
-#define MAX_BYTES_LINE_HWCONFIG_TXT		256
-
-#define SW_THREE_WIRE				0
-#define HW_THREE_WIRE				2
-
-#define BT_DEMO_BOARD				0
-#define BT_QA_BOARD				1
-#define BT_FPGA					2
-
 #define HAL_PRIME_CHNL_OFFSET_DONT_CARE		0
 #define HAL_PRIME_CHNL_OFFSET_LOWER		1
 #define HAL_PRIME_CHNL_OFFSET_UPPER		2
 
-#define MAX_H2C_QUEUE_NUM			10
 
 #define RX_MPDU_QUEUE				0
-#define RX_CMD_QUEUE				1
-#define RX_MAX_QUEUE				2
-#define AC2QUEUEID(_AC)				(_AC)
-
-#define	C2H_RX_CMD_HDR_LEN			8
-#define	GET_C2H_CMD_CMD_LEN(__prxhdr)		\
-	LE_BITS_TO_4BYTE((__prxhdr), 0, 16)
-#define	GET_C2H_CMD_ELEMENT_ID(__prxhdr)	\
-	LE_BITS_TO_4BYTE((__prxhdr), 16, 8)
-#define	GET_C2H_CMD_CMD_SEQ(__prxhdr)		\
-	LE_BITS_TO_4BYTE((__prxhdr), 24, 7)
-#define	GET_C2H_CMD_CONTINUE(__prxhdr)		\
-	LE_BITS_TO_4BYTE((__prxhdr), 31, 1)
-#define	GET_C2H_CMD_CONTENT(__prxhdr)		\
-	((u8 *)(__prxhdr) + C2H_RX_CMD_HDR_LEN)
-
-#define	GET_C2H_CMD_FEEDBACK_ELEMENT_ID(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE((__pcmdfbhdr), 0, 8)
-#define	GET_C2H_CMD_FEEDBACK_CCX_LEN(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE((__pcmdfbhdr), 8, 8)
-#define	GET_C2H_CMD_FEEDBACK_CCX_CMD_CNT(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE((__pcmdfbhdr), 16, 16)
-#define	GET_C2H_CMD_FEEDBACK_CCX_MAC_ID(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 0, 5)
-#define	GET_C2H_CMD_FEEDBACK_CCX_VALID(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 7, 1)
-#define	GET_C2H_CMD_FEEDBACK_CCX_RETRY_CNT(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 8, 5)
-#define	GET_C2H_CMD_FEEDBACK_CCX_TOK(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 15, 1)
-#define	GET_C2H_CMD_FEEDBACK_CCX_QSEL(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 16, 4)
-#define	GET_C2H_CMD_FEEDBACK_CCX_SEQ(__pcmdfbhdr)	\
-	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
-
-#define CHIP_BONDING_IDENTIFIER(_value)	(((_value)>>22)&0x3)
-#define	CHIP_BONDING_92C_1T2R		0x1
-
-#define CHIP_8723			BIT(0)
-#define CHIP_8723B			(BIT(1) | BIT(2))
-#define NORMAL_CHIP			BIT(3)
-#define RF_TYPE_1T1R			(~(BIT(4) | BIT(5) | BIT(6)))
-#define RF_TYPE_1T2R			BIT(4)
-#define RF_TYPE_2T2R			BIT(5)
-#define CHIP_VENDOR_UMC			BIT(7)
-#define B_CUT_VERSION			BIT(12)
-#define C_CUT_VERSION			BIT(13)
-#define D_CUT_VERSION			((BIT(12) | BIT(13)))
-#define E_CUT_VERSION			BIT(14)
-#define	RF_RL_ID			(BIT(31) | BIT(30) | BIT(29) | BIT(28))
-
-/* MASK */
-#define IC_TYPE_MASK			(BIT(0) | BIT(1) | BIT(2))
-#define CHIP_TYPE_MASK			BIT(3)
-#define RF_TYPE_MASK			(BIT(4) | BIT(5) | BIT(6))
-#define MANUFACTUER_MASK		BIT(7)
-#define ROM_VERSION_MASK		(BIT(11) | BIT(10) | BIT(9) | BIT(8))
-#define CUT_VERSION_MASK		(BIT(15) | BIT(14) | BIT(13) | BIT(12))
-
-/* Get element */
-#define GET_CVID_IC_TYPE(version)	((version) & IC_TYPE_MASK)
-#define GET_CVID_CHIP_TYPE(version)	((version) & CHIP_TYPE_MASK)
-#define GET_CVID_RF_TYPE(version)	((version) & RF_TYPE_MASK)
-#define GET_CVID_MANUFACTUER(version)	((version) & MANUFACTUER_MASK)
-#define GET_CVID_ROM_VERSION(version)	((version) & ROM_VERSION_MASK)
-#define GET_CVID_CUT_VERSION(version)	((version) & CUT_VERSION_MASK)
-
-#define IS_92C_SERIAL(version)   ((IS_81XXC(version) && IS_2T2R(version)) ?\
-								true : false)
-#define IS_81XXC(version)	((GET_CVID_IC_TYPE(version) == 0) ?\
-							true : false)
-#define IS_8723_SERIES(version)	((GET_CVID_IC_TYPE(version) == CHIP_8723) ?\
-							true : false)
-#define IS_1T1R(version)	((GET_CVID_RF_TYPE(version)) ? false : true)
-#define IS_1T2R(version)	((GET_CVID_RF_TYPE(version) == RF_TYPE_1T2R)\
-							? true : false)
-#define IS_2T2R(version)	((GET_CVID_RF_TYPE(version) == RF_TYPE_2T2R)\
-							? true : false)
-enum rf_optype {
-	RF_OP_BY_SW_3WIRE = 0,
-	RF_OP_BY_FW,
-	RF_OP_MAX
-};
-
-enum rf_power_state {
-	RF_ON,
-	RF_OFF,
-	RF_SLEEP,
-	RF_SHUT_DOWN,
-};
-
-enum power_save_mode {
-	POWER_SAVE_MODE_ACTIVE,
-	POWER_SAVE_MODE_SAVE,
-};
+#define CHIP_8723B				(BIT(1) | BIT(2))
+#define NORMAL_CHIP				BIT(3)
+#define CHIP_VENDOR_SMIC			BIT(8)
+/* Currently only for RTL8723B */
+#define EXT_VENDOR_ID				(BIT(18) | BIT(19))
 
-enum power_polocy_config {
-	POWERCFG_MAX_POWER_SAVINGS,
-	POWERCFG_GLOBAL_POWER_SAVINGS,
-	POWERCFG_LOCAL_POWER_SAVINGS,
-	POWERCFG_LENOVO,
-};
-
-enum interface_select_pci {
-	INTF_SEL1_MINICARD = 0,
-	INTF_SEL0_PCIE = 1,
-	INTF_SEL2_RSV = 2,
-	INTF_SEL3_RSV = 3,
+enum rx_packet_type {
+	NORMAL_RX,
+	TX_REPORT1,
+	TX_REPORT2,
+	HIS_REPORT,
+	C2H_PACKET,
 };
 
 enum rtl_desc_qsel {
@@ -222,27 +88,5 @@ enum rtl_desc8723e_rate {
 	DESC92C_RATEMCS13 = 0x19,
 	DESC92C_RATEMCS14 = 0x1a,
 	DESC92C_RATEMCS15 = 0x1b,
-	DESC92C_RATEMCS15_SG = 0x1c,
-	DESC92C_RATEMCS32 = 0x20,
 };
-
-enum rx_packet_type {
-	NORMAL_RX,
-	TX_REPORT1,
-	TX_REPORT2,
-	HIS_REPORT,
-};
-
-struct phy_sts_cck_8723e_t {
-	u8 adc_pwdb_X[4];
-	u8 sq_rpt;
-	u8 cck_agc_rpt;
-};
-
-struct h2c_cmd_8723e {
-	u8 element_id;
-	u32 cmd_len;
-	u8 *p_cmdbuffer;
-};
-
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
index 13d53a1..dd7eb43 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
@@ -32,7 +32,6 @@
 #include "dm.h"
 #include "../rtl8723com/dm_common.h"
 #include "fw.h"
-#include "../rtl8723com/fw_common.h"
 #include "trx.h"
 #include "../btcoexist/rtl_btc.h"
 
@@ -209,7 +208,7 @@ void rtl8723be_dm_txpower_track_adjust(struct ieee80211_hw *hw, u8 type,
 		pwr_val = TXPWRTRACK_MAX_IDX;
 
 	*poutwrite_val = pwr_val | (pwr_val << 8) |
-			(pwr_val << 16) | (pwr_val << 24);
+		(pwr_val << 16) | (pwr_val << 24);
 }
 
 static void rtl8723be_dm_diginit(struct ieee80211_hw *hw)
@@ -218,8 +217,7 @@ static void rtl8723be_dm_diginit(struct ieee80211_hw *hw)
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	dm_digtable->dig_enable_flag = true;
-	dm_digtable->cur_igvalue = rtl_get_bbreg(hw,
-		ROFDM0_XAAGCCORE1, 0x7f);
+	dm_digtable->cur_igvalue = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f);
 	dm_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
 	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
 	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
@@ -234,8 +232,8 @@ static void rtl8723be_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->forbidden_igi = DM_DIG_MIN;
 	dm_digtable->large_fa_hit = 0;
 	dm_digtable->recover_cnt = 0;
-	dm_digtable->dig_min_0 = DM_DIG_MIN;
-	dm_digtable->dig_min_1 = DM_DIG_MIN;
+	dm_digtable->dig_dynamic_min = DM_DIG_MIN;
+	dm_digtable->dig_dynamic_min_1 = DM_DIG_MIN;
 	dm_digtable->media_connect_0 = false;
 	dm_digtable->media_connect_1 = false;
 	rtlpriv->dm.dm_initialgain_enable = true;
@@ -245,18 +243,18 @@ static void rtl8723be_dm_diginit(struct ieee80211_hw *hw)
 void rtl8723be_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rate_adaptive *ra = &(rtlpriv->ra);
+	struct rate_adaptive *p_ra = &rtlpriv->ra;
 
-	ra->ratr_state = DM_RATR_STA_INIT;
-	ra->pre_ratr_state = DM_RATR_STA_INIT;
+	p_ra->ratr_state = DM_RATR_STA_INIT;
+	p_ra->pre_ratr_state = DM_RATR_STA_INIT;
 
 	if (rtlpriv->dm.dm_type == DM_TYPE_BYDRIVER)
 		rtlpriv->dm.useramask = true;
 	else
 		rtlpriv->dm.useramask = false;
 
-	ra->high_rssi_thresh_for_ra = 50;
-	ra->low_rssi_thresh_for_ra40m = 20;
+	p_ra->high_rssi_thresh_for_ra = 50;
+	p_ra->low_rssi_thresh_for_ra40m = 20;
 }
 
 static void rtl8723be_dm_init_txpower_tracking(struct ieee80211_hw *hw)
@@ -279,7 +277,7 @@ static void rtl8723be_dm_init_txpower_tracking(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
 		 "  rtlpriv->dm.txpower_tracking = %d\n",
-		 rtlpriv->dm.txpower_tracking);
+		  rtlpriv->dm.txpower_tracking);
 }
 
 static void rtl8723be_dm_init_dynamic_atc_switch(struct ieee80211_hw *hw)
@@ -287,6 +285,7 @@ static void rtl8723be_dm_init_dynamic_atc_switch(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	rtlpriv->dm.crystal_cap = rtlpriv->efuse.crystalcap;
+
 	rtlpriv->dm.atc_status = rtl_get_bbreg(hw, ROFDM1_CFOTRACKING, 0x800);
 	rtlpriv->dm.cfo_threshold = CFO_THRESHOLD_XTAL;
 }
@@ -308,7 +307,7 @@ void rtl8723be_dm_init(struct ieee80211_hw *hw)
 static void rtl8723be_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *rtl_dm_dig = &(rtlpriv->dm_digtable);
+	struct dig_t *rtl_dm_dig = &rtlpriv->dm_digtable;
 	struct rtl_mac *mac = rtl_mac(rtlpriv);
 
 	/* Determine the minimum RSSI  */
@@ -325,20 +324,20 @@ static void rtl8723be_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 			    rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 rtlpriv->dm.entry_min_undec_sm_pwdb);
+			       rtlpriv->dm.entry_min_undec_sm_pwdb);
 		} else {
 			rtl_dm_dig->min_undec_pwdb_for_dm =
 			    rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%x\n",
-				 rtl_dm_dig->min_undec_pwdb_for_dm);
+				  rtl_dm_dig->min_undec_pwdb_for_dm);
 		}
 	} else {
 		rtl_dm_dig->min_undec_pwdb_for_dm =
 				rtlpriv->dm.entry_min_undec_sm_pwdb;
 		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 			 "AP Ext Port or disconnet PWDB = 0x%x\n",
-			 rtl_dm_dig->min_undec_pwdb_for_dm);
+			  rtl_dm_dig->min_undec_pwdb_for_dm);
 	}
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "MinUndecoratedPWDBForDM =%d\n",
 		 rtl_dm_dig->min_undec_pwdb_for_dm);
@@ -347,6 +346,7 @@ static void rtl8723be_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 static void rtl8723be_dm_check_rssi_monitor(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	struct rtl_sta_info *drv_priv;
 	u8 h2c_parameter[3] = { 0 };
 	long tmp_entry_max_pwdb = 0, tmp_entry_min_pwdb = 0xff;
@@ -367,69 +367,78 @@ static void rtl8723be_dm_check_rssi_monitor(struct ieee80211_hw *hw)
 
 	/* If associated entry is found */
 	if (tmp_entry_max_pwdb != 0) {
-		rtlpriv->dm.entry_max_undec_sm_pwdb = tmp_entry_max_pwdb;
-		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 "EntryMaxPWDB = 0x%lx(%ld)\n",
+		rtlpriv->dm.entry_max_undec_sm_pwdb =
+							tmp_entry_max_pwdb;
+		RTPRINT(rtlpriv, FDM, DM_PWDB,
+			"EntryMaxPWDB = 0x%lx(%ld)\n",
 			 tmp_entry_max_pwdb, tmp_entry_max_pwdb);
 	} else {
 		rtlpriv->dm.entry_max_undec_sm_pwdb = 0;
 	}
 	/* If associated entry is found */
 	if (tmp_entry_min_pwdb != 0xff) {
-		rtlpriv->dm.entry_min_undec_sm_pwdb = tmp_entry_min_pwdb;
-		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 "EntryMinPWDB = 0x%lx(%ld)\n",
+		rtlpriv->dm.entry_min_undec_sm_pwdb =
+							tmp_entry_min_pwdb;
+		RTPRINT(rtlpriv, FDM, DM_PWDB,
+			"EntryMinPWDB = 0x%lx(%ld)\n",
 			 tmp_entry_min_pwdb, tmp_entry_min_pwdb);
 	} else {
 		rtlpriv->dm.entry_min_undec_sm_pwdb = 0;
 	}
 	/* Indicate Rx signal strength to FW. */
 	if (rtlpriv->dm.useramask) {
-		h2c_parameter[2] = (u8) (rtlpriv->dm.undec_sm_pwdb & 0xFF);
+		h2c_parameter[2] =
+			(u8)(rtlpriv->dm.undec_sm_pwdb & 0xFF);
 		h2c_parameter[1] = 0x20;
 		h2c_parameter[0] = 0;
-		rtl8723be_fill_h2c_cmd(hw, H2C_RSSI_REPORT, 3, h2c_parameter);
+		rtl8723be_fill_h2c_cmd(hw, H2C_RSSIBE_REPORT, 3, h2c_parameter);
 	} else {
-		rtl_write_byte(rtlpriv, 0x4fe, rtlpriv->dm.undec_sm_pwdb);
+		rtl_write_byte(rtlpriv, 0x4fe,
+			       rtlpriv->dm.undec_sm_pwdb);
 	}
 	rtl8723be_dm_find_minimum_rssi(hw);
-	rtlpriv->dm_digtable.rssi_val_min =
-		rtlpriv->dm_digtable.min_undec_pwdb_for_dm;
+	dm_digtable->rssi_val_min =
+			rtlpriv->dm_digtable.min_undec_pwdb_for_dm;
 }
 
 void rtl8723be_dm_write_dig(struct ieee80211_hw *hw, u8 current_igi)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
-	if (rtlpriv->dm_digtable.cur_igvalue != current_igi) {
+	if (dm_digtable->stop_dig)
+		return;
+
+	if (dm_digtable->cur_igvalue != current_igi) {
 		rtl_set_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f, current_igi);
 		if (rtlpriv->phy.rf_type != RF_1T1R)
-			rtl_set_bbreg(hw, ROFDM0_XBAGCCORE1, 0x7f, current_igi);
+			rtl_set_bbreg(hw, ROFDM0_XBAGCCORE1,
+				      0x7f, current_igi);
 	}
-	rtlpriv->dm_digtable.pre_igvalue = rtlpriv->dm_digtable.cur_igvalue;
-	rtlpriv->dm_digtable.cur_igvalue = current_igi;
+	dm_digtable->pre_igvalue = dm_digtable->cur_igvalue;
+	dm_digtable->cur_igvalue = current_igi;
 }
 
 static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct dig_t *dm_digtable = &(rtlpriv->dm_digtable);
 	u8 dig_dynamic_min, dig_maxofmin;
-	bool firstconnect, firstdisconnect;
+	bool bfirstconnect, bfirstdisconnect;
 	u8 dm_dig_max, dm_dig_min;
 	u8 current_igi = dm_digtable->cur_igvalue;
 	u8 offset;
 
-	/* AP, BT */
+	/* AP,BT */
 	if (mac->act_scanning)
 		return;
 
-	dig_dynamic_min = dm_digtable->dig_min_0;
-	firstconnect = (mac->link_state >= MAC80211_LINKED) &&
+	dig_dynamic_min = dm_digtable->dig_dynamic_min;
+	bfirstconnect = (mac->link_state >= MAC80211_LINKED) &&
 			!dm_digtable->media_connect_0;
-	firstdisconnect = (mac->link_state < MAC80211_LINKED) &&
-			   dm_digtable->media_connect_0;
+	bfirstdisconnect = (mac->link_state < MAC80211_LINKED) &&
+			(dm_digtable->media_connect_0);
 
 	dm_dig_max = 0x5a;
 	dm_dig_min = DM_DIG_MIN;
@@ -457,6 +466,7 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 		} else {
 			dig_dynamic_min = dm_dig_min;
 		}
+
 	} else {
 		dm_digtable->rx_gain_max = dm_dig_max;
 		dig_dynamic_min = dm_dig_min;
@@ -506,7 +516,7 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 		dm_digtable->rx_gain_min = dm_digtable->rx_gain_max;
 
 	if (mac->link_state >= MAC80211_LINKED) {
-		if (firstconnect) {
+		if (bfirstconnect) {
 			if (dm_digtable->rssi_val_min <= dig_maxofmin)
 				current_igi = dm_digtable->rssi_val_min;
 			else
@@ -522,7 +532,7 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 				current_igi -= 2;
 		}
 	} else {
-		if (firstdisconnect) {
+		if (bfirstdisconnect) {
 			current_igi = dm_digtable->rx_gain_min;
 		} else {
 			if (rtlpriv->falsealm_cnt.cnt_all > 10000)
@@ -542,14 +552,15 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 	rtl8723be_dm_write_dig(hw, current_igi);
 	dm_digtable->media_connect_0 =
 		((mac->link_state >= MAC80211_LINKED) ? true : false);
-	dm_digtable->dig_min_0 = dig_dynamic_min;
+	dm_digtable->dig_dynamic_min = dig_dynamic_min;
 }
 
-static void rtl8723be_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
+static void rtl8723be_dm_false_alarm_counter_statistics(
+					struct ieee80211_hw *hw)
 {
 	u32 ret_value;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct false_alarm_statistics *falsealm_cnt = &(rtlpriv->falsealm_cnt);
+	struct false_alarm_statistics *falsealm_cnt = &rtlpriv->falsealm_cnt;
 
 	rtl_set_bbreg(hw, DM_REG_OFDM_FA_HOLDC_11N, BIT(31), 1);
 	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTD_11N, BIT(31), 1);
@@ -615,16 +626,14 @@ static void rtl8723be_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(15) | BIT(14), 2);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, "
-		 "cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
+		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
 		 falsealm_cnt->cnt_parity_fail,
 		 falsealm_cnt->cnt_rate_illegal,
 		 falsealm_cnt->cnt_crc8_fail,
 		 falsealm_cnt->cnt_mcs_fail);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "cnt_ofdm_fail = %x, cnt_cck_fail = %x,"
-		 " cnt_all = %x\n",
+		 "cnt_ofdm_fail = %x, cnt_cck_fail = %x, cnt_all = %x\n",
 		 falsealm_cnt->cnt_ofdm_fail,
 		 falsealm_cnt->cnt_cck_fail,
 		 falsealm_cnt->cnt_all);
@@ -690,7 +699,7 @@ static void rtl8723be_dm_tx_power_track_set_power(struct ieee80211_hw *hw,
 					u8 rfpath, u8 idx)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
 	u8 swing_idx_ofdm_limit = 36;
 
@@ -762,7 +771,8 @@ static void rtl8723be_dm_tx_power_track_set_power(struct ieee80211_hw *hw,
 	}
 }
 
-static void txpwr_track_cb_therm(struct ieee80211_hw *hw)
+static void rtl8723be_dm_txpower_tracking_callback_thermalmeter(
+							struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
@@ -773,30 +783,29 @@ static void txpwr_track_cb_therm(struct ieee80211_hw *hw)
 	int i = 0;
 
 	u8 ofdm_min_index = 6;
-	u8 index = 0;
+	u8 index_for_channel = 0;
 
-	char delta_swing_table_idx_tup_a[] = {
+	char delta_swing_table_idx_tup_a[TXSCALE_TABLE_SIZE] = {
 		0, 0, 1, 2, 2, 2, 3, 3, 3, 4,  5,
 		5, 6, 6, 7, 7, 8, 8, 9, 9, 9, 10,
 		10, 11, 11, 12, 12, 13, 14, 15};
-	char delta_swing_table_idx_tdown_a[] = {
+	char delta_swing_table_idx_tdown_a[TXSCALE_TABLE_SIZE] = {
 		0, 0, 1, 2, 2, 2, 3, 3, 3, 4,  5,
 		5, 6, 6, 6, 6, 7, 7, 7, 8, 8,  9,
 		9, 10, 10, 11, 12, 13, 14, 15};
 
-	/*Initilization ( 7 steps in total)*/
+	/*Initilization ( 7 steps in total )*/
 	rtlpriv->dm.txpower_trackinginit = true;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "rtl8723be_dm_txpower_tracking"
-		 "_callback_thermalmeter\n");
+		 "rtl8723be_dm_txpower_tracking_callback_thermalmeter\n");
 
-	thermalvalue = (u8)rtl_get_rfreg(hw, RF90_PATH_A, RF_T_METER, 0xfc00);
+	thermalvalue = (u8)rtl_get_rfreg(hw,
+		RF90_PATH_A, RF_T_METER, 0xfc00);
 	if (!rtlpriv->dm.txpower_track_control || thermalvalue == 0 ||
 	    rtlefuse->eeprom_thermalmeter == 0xFF)
 		return;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-		 "eeprom_thermalmeter 0x%x\n",
+		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x\n",
 		 thermalvalue, rtldm->thermalvalue,
 		 rtlefuse->eeprom_thermalmeter);
 	/*3 Initialize ThermalValues of RFCalibrateInfo*/
@@ -833,9 +842,7 @@ static void txpwr_track_cb_therm(struct ieee80211_hw *hw)
 		    (rtlpriv->dm.thermalvalue_iqk - thermalvalue);
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-		 "eeprom_thermalmeter 0x%x delta 0x%x "
-		 "delta_lck 0x%x delta_iqk 0x%x\n",
+		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x delta 0x%x delta_lck 0x%x delta_iqk 0x%x\n",
 		 thermalvalue, rtlpriv->dm.thermalvalue,
 		 rtlefuse->eeprom_thermalmeter, delta, delta_lck, delta_iqk);
 	/* 6 If necessary, do LCK.*/
@@ -905,10 +912,10 @@ static void txpwr_track_cb_therm(struct ieee80211_hw *hw)
 		rtldm->done_txpower = true;
 		if (thermalvalue > rtlefuse->eeprom_thermalmeter)
 			rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
-							      index);
+							     index_for_channel);
 		else
 			rtl8723be_dm_tx_power_track_set_power(hw, BBSWING, 0,
-							      index);
+							     index_for_channel);
 
 		rtldm->swing_idx_cck_base = rtldm->swing_idx_cck;
 		rtldm->swing_idx_ofdm_base[RF90_PATH_A] =
@@ -923,6 +930,7 @@ static void txpwr_track_cb_therm(struct ieee80211_hw *hw)
 
 	rtldm->txpowercount = 0;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "end\n");
+
 }
 
 void rtl8723be_dm_check_txpower_tracking(struct ieee80211_hw *hw)
@@ -943,7 +951,7 @@ void rtl8723be_dm_check_txpower_tracking(struct ieee80211_hw *hw)
 	} else {
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
 			 "Schedule TxPowerTracking !!\n");
-		txpwr_track_cb_therm(hw);
+		rtl8723be_dm_txpower_tracking_callback_thermalmeter(hw);
 		tm_trigger = 0;
 	}
 }
@@ -953,11 +961,11 @@ static void rtl8723be_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rate_adaptive *ra = &(rtlpriv->ra);
-	struct ieee80211_sta *sta = NULL;
-	u32 low_rssithresh_for_ra = ra->low2high_rssi_thresh_for_ra40m;
-	u32 high_rssithresh_for_ra = ra->high_rssi_thresh_for_ra;
+	struct rate_adaptive *p_ra = &rtlpriv->ra;
+	u32 low_rssithresh_for_ra = p_ra->low2high_rssi_thresh_for_ra40m;
+	u32 high_rssithresh_for_ra = p_ra->high_rssi_thresh_for_ra;
 	u8 go_up_gap = 5;
+	struct ieee80211_sta *sta = NULL;
 
 	if (is_hal_stop(rtlhal)) {
 		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
@@ -972,8 +980,8 @@ static void rtl8723be_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	}
 
 	if (mac->link_state == MAC80211_LINKED &&
-	    mac->opmode == NL80211_IFTYPE_STATION) {
-		switch (ra->pre_ratr_state) {
+		mac->opmode == NL80211_IFTYPE_STATION) {
+		switch (p_ra->pre_ratr_state) {
 		case DM_RATR_STA_MIDDLE:
 			high_rssithresh_for_ra += go_up_gap;
 			break;
@@ -987,31 +995,31 @@ static void rtl8723be_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 
 		if (rtlpriv->dm.undec_sm_pwdb >
 		    (long)high_rssithresh_for_ra)
-			ra->ratr_state = DM_RATR_STA_HIGH;
+			p_ra->ratr_state = DM_RATR_STA_HIGH;
 		else if (rtlpriv->dm.undec_sm_pwdb >
 			 (long)low_rssithresh_for_ra)
-			ra->ratr_state = DM_RATR_STA_MIDDLE;
+			p_ra->ratr_state = DM_RATR_STA_MIDDLE;
 		else
-			ra->ratr_state = DM_RATR_STA_LOW;
+			p_ra->ratr_state = DM_RATR_STA_LOW;
 
-		if (ra->pre_ratr_state != ra->ratr_state) {
+		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
 				 "RSSI = %ld\n",
 				 rtlpriv->dm.undec_sm_pwdb);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 "RSSI_LEVEL = %d\n", ra->ratr_state);
+				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
 				 "PreState = %d, CurState = %d\n",
-				 ra->pre_ratr_state, ra->ratr_state);
+				  p_ra->pre_ratr_state, p_ra->ratr_state);
 
 			rcu_read_lock();
 			sta = rtl_find_sta(hw, mac->bssid);
 			if (sta)
 				rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
-							   ra->ratr_state);
+							   p_ra->ratr_state);
 			rcu_read_unlock();
 
-			ra->pre_ratr_state = ra->ratr_state;
+			p_ra->pre_ratr_state = p_ra->ratr_state;
 		}
 	}
 }
@@ -1020,10 +1028,6 @@ static bool rtl8723be_dm_is_edca_turbo_disable(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (rtlpriv->cfg->ops->get_btc_status()) {
-		if (rtlpriv->btcoexist.btc_ops->btc_is_disable_edca_turbo(rtlpriv))
-			return true;
-	}
 	if (rtlpriv->mac80211.mode == WIRELESS_MODE_B)
 		return true;
 
@@ -1034,6 +1038,7 @@ static void rtl8723be_dm_check_edca_turbo(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+
 	static u64 last_txok_cnt;
 	static u64 last_rxok_cnt;
 	u64 cur_txok_cnt = 0;
@@ -1042,22 +1047,22 @@ static void rtl8723be_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	u32 edca_be_dl = 0x6ea42b;/*not sure*/
 	u32 edca_be = 0x5ea42b;
 	u32 iot_peer = 0;
-	bool is_cur_rdlstate;
-	bool last_is_cur_rdlstate = false;
-	bool bias_on_rx = false;
-	bool edca_turbo_on = false;
+	bool b_is_cur_rdlstate;
+	bool b_last_is_cur_rdlstate = false;
+	bool b_bias_on_rx = false;
+	bool b_edca_turbo_on = false;
 
-	last_is_cur_rdlstate = rtlpriv->dm.is_cur_rdlstate;
+	b_last_is_cur_rdlstate = rtlpriv->dm.is_cur_rdlstate;
 
 	cur_txok_cnt = rtlpriv->stats.txbytesunicast - last_txok_cnt;
 	cur_rxok_cnt = rtlpriv->stats.rxbytesunicast - last_rxok_cnt;
 
 	iot_peer = rtlpriv->mac80211.vendor;
-	bias_on_rx = (iot_peer == PEER_RAL || iot_peer == PEER_ATH) ?
-		     true : false;
-	edca_turbo_on = ((!rtlpriv->dm.is_any_nonbepkts) &&
-			 (!rtlpriv->dm.disable_framebursting)) ?
-			 true : false;
+	b_bias_on_rx = (iot_peer == PEER_RAL || iot_peer == PEER_ATH) ?
+		       true : false;
+	b_edca_turbo_on = ((!rtlpriv->dm.is_any_nonbepkts) &&
+			   (!rtlpriv->dm.disable_framebursting)) ?
+			   true : false;
 
 	if ((iot_peer == PEER_CISCO) &&
 	    (mac->mode == WIRELESS_MODE_N_24G)) {
@@ -1067,23 +1072,23 @@ static void rtl8723be_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	if (rtl8723be_dm_is_edca_turbo_disable(hw))
 		goto exit;
 
-	if (edca_turbo_on) {
-		if (bias_on_rx)
-			is_cur_rdlstate = (cur_txok_cnt > cur_rxok_cnt * 4) ?
-					  false : true;
+	if (b_edca_turbo_on) {
+		if (b_bias_on_rx)
+			b_is_cur_rdlstate = (cur_txok_cnt > cur_rxok_cnt * 4) ?
+					    false : true;
 		else
-			is_cur_rdlstate = (cur_rxok_cnt > cur_txok_cnt * 4) ?
-					  true : false;
+			b_is_cur_rdlstate = (cur_rxok_cnt > cur_txok_cnt * 4) ?
+					    true : false;
 
-		edca_be = (is_cur_rdlstate) ? edca_be_dl : edca_be_ul;
+		edca_be = (b_is_cur_rdlstate) ? edca_be_dl : edca_be_ul;
 		rtl_write_dword(rtlpriv, REG_EDCA_BE_PARAM, edca_be);
-		rtlpriv->dm.is_cur_rdlstate = is_cur_rdlstate;
+		rtlpriv->dm.is_cur_rdlstate = b_is_cur_rdlstate;
 		rtlpriv->dm.current_turbo_edca = true;
 	} else {
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      &tmp);
+						      (u8 *)(&tmp));
 		}
 		rtlpriv->dm.current_turbo_edca = false;
 	}
@@ -1097,13 +1102,14 @@ exit:
 static void rtl8723be_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	u8 cur_cck_cca_thresh;
 
 	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED) {
-		if (rtlpriv->dm_digtable.rssi_val_min > 25) {
+		if (dm_digtable->rssi_val_min > 25) {
 			cur_cck_cca_thresh = 0xcd;
-		} else if ((rtlpriv->dm_digtable.rssi_val_min <= 25) &&
-			   (rtlpriv->dm_digtable.rssi_val_min > 10)) {
+		} else if ((dm_digtable->rssi_val_min <= 25) &&
+			   (dm_digtable->rssi_val_min > 10)) {
 			cur_cck_cca_thresh = 0x83;
 		} else {
 			if (rtlpriv->falsealm_cnt.cnt_cck_fail > 1000)
@@ -1118,14 +1124,13 @@ static void rtl8723be_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 			cur_cck_cca_thresh = 0x40;
 	}
 
-	if (rtlpriv->dm_digtable.cur_cck_cca_thres != cur_cck_cca_thresh)
+	if (dm_digtable->cur_cck_cca_thres != cur_cck_cca_thresh)
 		rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2, cur_cck_cca_thresh);
 
-	rtlpriv->dm_digtable.pre_cck_cca_thres = rtlpriv->dm_digtable.cur_cck_cca_thres;
-	rtlpriv->dm_digtable.cur_cck_cca_thres = cur_cck_cca_thresh;
+	dm_digtable->pre_cck_cca_thres = dm_digtable->cur_cck_cca_thres;
+	dm_digtable->cur_cck_cca_thres = cur_cck_cca_thresh;
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "CCK cca thresh hold =%x\n",
-		 rtlpriv->dm_digtable.cur_cck_cca_thres);
+		 "CCK cca thresh hold =%x\n", dm_digtable->cur_cck_cca_thres);
 }
 
 static void rtl8723be_dm_dynamic_edcca(struct ieee80211_hw *hw)
@@ -1173,8 +1178,7 @@ static void rtl8723be_dm_dynamic_atc_switch(struct ieee80211_hw *hw)
 		if (rtlpriv->cfg->ops->get_btc_status()) {
 			if (!rtlpriv->btcoexist.btc_ops->btc_is_bt_disabled(rtlpriv)) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
-					 "odm_DynamicATCSwitch(): Disable"
-					 " CFO tracking for BT!!\n");
+					 "odm_DynamicATCSwitch(): Disable CFO tracking for BT!!\n");
 				return;
 			}
 		}
@@ -1207,9 +1211,8 @@ static void rtl8723be_dm_dynamic_atc_switch(struct ieee80211_hw *hw)
 		if (cfo_ave_diff > 20 && rtldm->large_cfo_hit == 0) {
 			rtldm->large_cfo_hit = 1;
 			return;
-		} else {
+		} else
 			rtldm->large_cfo_hit = 0;
-		}
 
 		rtldm->cfo_ave_pre = cfo_ave;
 
@@ -1263,20 +1266,20 @@ static void rtl8723be_dm_dynamic_atc_switch(struct ieee80211_hw *hw)
 static void rtl8723be_dm_common_info_self_update(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_sta_info *drv_priv;
 	u8 cnt = 0;
+	struct rtl_sta_info *drv_priv;
 
 	rtlpriv->dm.one_entry_only = false;
 
 	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_STATION &&
-	    rtlpriv->mac80211.link_state >= MAC80211_LINKED) {
+		rtlpriv->mac80211.link_state >= MAC80211_LINKED) {
 		rtlpriv->dm.one_entry_only = true;
 		return;
 	}
 
 	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP ||
-	    rtlpriv->mac80211.opmode == NL80211_IFTYPE_ADHOC ||
-	    rtlpriv->mac80211.opmode == NL80211_IFTYPE_MESH_POINT) {
+		rtlpriv->mac80211.opmode == NL80211_IFTYPE_ADHOC ||
+		rtlpriv->mac80211.opmode == NL80211_IFTYPE_MESH_POINT) {
 		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
 		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
 			cnt++;
@@ -1305,8 +1308,8 @@ void rtl8723be_dm_watchdog(struct ieee80211_hw *hw)
 		fw_ps_awake = false;
 
 	if ((ppsc->rfpwr_state == ERFON) &&
-	    ((!fw_current_inpsmode) && fw_ps_awake) &&
-	    (!ppsc->rfchange_inprogress)) {
+		((!fw_current_inpsmode) && fw_ps_awake) &&
+		(!ppsc->rfchange_inprogress)) {
 		rtl8723be_dm_common_info_self_update(hw);
 		rtl8723be_dm_false_alarm_counter_statistics(hw);
 		rtl8723be_dm_check_rssi_monitor(hw);
@@ -1318,8 +1321,6 @@ void rtl8723be_dm_watchdog(struct ieee80211_hw *hw)
 		rtl8723be_dm_dynamic_atc_switch(hw);
 		rtl8723be_dm_check_txpower_tracking(hw);
 		rtl8723be_dm_dynamic_txpower(hw);
-		if (rtlpriv->cfg->ops->get_btc_status())
-			rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);
 	}
 	rtlpriv->dm.dbginfo.num_qry_beacon_pkt = 0;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
index c6c2f2a..e4c0e8a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.h
@@ -141,7 +141,7 @@
 #define	DM_REG_TX_CCK_BBON_11N			0xE78
 #define	DM_REG_OFDM_RFON_11N			0xE7C
 #define	DM_REG_OFDM_BBON_11N			0xE80
-#define DM_REG_TX2RX_11N			0xE84
+#define		DM_REG_TX2RX_11N		0xE84
 #define	DM_REG_TX2TX_11N			0xE88
 #define	DM_REG_RX_CCK_11N			0xE8C
 #define	DM_REG_RX_OFDM_11N			0xED0
@@ -202,6 +202,7 @@
 #define DM_DIG_BACKOFF_MIN			-4
 #define DM_DIG_BACKOFF_DEFAULT			10
 
+#define RXPATHSELECTION_SS_TH_LOW		30
 #define RXPATHSELECTION_DIFF_TH			18
 
 #define DM_RATR_STA_INIT			0
@@ -212,6 +213,8 @@
 #define CTS2SELF_THVAL				30
 #define REGC38_TH				20
 
+#define WAIOTTHVAL				25
+
 #define TXHIGHPWRLEVEL_NORMAL			0
 #define TXHIGHPWRLEVEL_LEVEL1			1
 #define TXHIGHPWRLEVEL_LEVEL2			2
@@ -231,22 +234,6 @@
 #define	CFO_THRESHOLD_XTAL			10 /* kHz */
 #define	CFO_THRESHOLD_ATC			80 /* kHz */
 
-enum FAT_STATE {
-	FAT_NORMAL_STATE	= 0,
-	FAT_TRAINING_STATE	= 1,
-};
-
-enum tag_dynamic_init_gain_operation_type_definition {
-	DIG_TYPE_THRESH_HIGH	= 0,
-	DIG_TYPE_THRESH_LOW	= 1,
-	DIG_TYPE_BACKOFF	= 2,
-	DIG_TYPE_RX_GAIN_MIN	= 3,
-	DIG_TYPE_RX_GAIN_MAX	= 4,
-	DIG_TYPE_ENABLE		= 5,
-	DIG_TYPE_DISABLE	= 6,
-	DIG_OP_TYPE_MAX
-};
-
 enum dm_1r_cca_e {
 	CCA_1R		= 0,
 	CCA_2R		= 1,
@@ -292,12 +279,17 @@ enum pwr_track_control_method {
 #define BT_RSSI_STATE_SPECIAL_LOW       BIT_OFFSET_LEN_MASK_32(2, 1)
 #define BT_RSSI_STATE_BG_EDCA_LOW       BIT_OFFSET_LEN_MASK_32(3, 1)
 #define BT_RSSI_STATE_TXPOWER_LOW       BIT_OFFSET_LEN_MASK_32(4, 1)
+#define GET_UNDECORATED_AVERAGE_RSSI(_priv)     \
+	((((struct rtl_priv *)(_priv))->mac80211.opmode == \
+		NL80211_IFTYPE_ADHOC) ? \
+	(((struct rtl_priv *)(_priv))->dm.entry_min_undecoratedsmoothed_pwdb) :\
+	(((struct rtl_priv *)(_priv))->dm.undecorated_smoothed_pwdb))
 
 void rtl8723be_dm_set_tx_ant_by_tx_info(struct ieee80211_hw *hw, u8 *pdesc,
 					u32 mac_id);
 void rtl8723be_dm_ant_sel_statistics(struct ieee80211_hw *hw, u8 antsel_tr_mux,
 				     u32 mac_id, u32 rx_pwdb_all);
-void rtl8723be_dm_fast_antenna_trainning_callback(unsigned long data);
+void rtl8723be_dm_fast_antenna_training_callback(unsigned long data);
 void rtl8723be_dm_init(struct ieee80211_hw *hw);
 void rtl8723be_dm_watchdog(struct ieee80211_hw *hw);
 void rtl8723be_dm_write_dig(struct ieee80211_hw *hw, u8 current_igi);
@@ -305,6 +297,4 @@ void rtl8723be_dm_check_txpower_tracking(struct ieee80211_hw *hw);
 void rtl8723be_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
 void rtl8723be_dm_txpower_track_adjust(struct ieee80211_hw *hw, u8 type,
 				       u8 *pdirection, u32 *poutwrite_val);
-void rtl8723be_dm_init_edca_turbo(struct ieee80211_hw *hw);
-
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
index f856be6..0c07992 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/fw.c
@@ -55,8 +55,8 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 	bool isfw_read = false;
 	u8 buf_index = 0;
 	bool bwrite_sucess = false;
-	u8 wait_h2c_limit = 100;
-	u8 wait_writeh2c_limit = 100;
+	u8 wait_h2c_limmit = 100;
+	u8 wait_writeh2c_limmit = 100;
 	u8 boxcontent[4], boxextcontent[4];
 	u32 h2c_waitcounter = 0;
 	unsigned long flag;
@@ -68,8 +68,8 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 		if (rtlhal->h2c_setinprogress) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "H2C set in progress! Wait to set.."
-				 "element_id(%d).\n", element_id);
+				 "H2C set in progress! Wait to set..element_id(%d).\n",
+				 element_id);
 
 			while (rtlhal->h2c_setinprogress) {
 				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
@@ -92,14 +92,15 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		}
 	}
+
 	while (!bwrite_sucess) {
-		wait_writeh2c_limit--;
-		if (wait_writeh2c_limit == 0) {
+		wait_writeh2c_limmit--;
+		if (wait_writeh2c_limmit == 0) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "Write H2C fail because no trigger "
-				 "for FW INT!\n");
+				 "Write H2C fail because no trigger for FW INT!\n");
 			break;
 		}
+
 		boxnum = rtlhal->last_hmeboxnum;
 		switch (boxnum) {
 		case 0:
@@ -120,39 +121,43 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case not process\n");
 			break;
 		}
+
 		isfw_read = _rtl8723be_check_fw_read_last_h2c(hw, boxnum);
 		while (!isfw_read) {
-			wait_h2c_limit--;
-			if (wait_h2c_limit == 0) {
+			wait_h2c_limmit--;
+			if (wait_h2c_limmit == 0) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 "Wating too long for FW read "
-					 "clear HMEBox(%d)!\n", boxnum);
+					 "Waiting too long for FW read clear HMEBox(%d)!\n",
+					 boxnum);
 				break;
 			}
+
 			udelay(10);
 
 			isfw_read = _rtl8723be_check_fw_read_last_h2c(hw,
 								boxnum);
 			u1b_tmp = rtl_read_byte(rtlpriv, 0x130);
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Wating for FW read clear HMEBox(%d)!!! 0x130 = %2x\n",
+				 "Waiting for FW read clear HMEBox(%d)!!! 0x130 = %2x\n",
 				 boxnum, u1b_tmp);
 		}
+
 		if (!isfw_read) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Write H2C register BOX[%d] fail!!!!! "
-				 "Fw do not read.\n", boxnum);
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read.\n",
+				 boxnum);
 			break;
 		}
+
 		memset(boxcontent, 0, sizeof(boxcontent));
 		memset(boxextcontent, 0, sizeof(boxextcontent));
 		boxcontent[0] = element_id;
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "Write element_id box_reg(%4x) = %2x\n",
-			 box_reg, element_id);
+			  box_reg, element_id);
 
 		switch (cmd_len) {
 		case 1:
@@ -181,6 +186,7 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 				rtl_write_byte(rtlpriv, box_extreg + idx,
 					       boxextcontent[idx]);
 			}
+
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
 					       boxcontent[idx]);
@@ -191,6 +197,7 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 				 "switch case not process\n");
 			break;
 		}
+
 		bwrite_sucess = true;
 
 		rtlhal->last_hmeboxnum = boxnum + 1;
@@ -199,8 +206,9 @@ static void _rtl8723be_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
 
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "pHalData->last_hmeboxnum  = %d\n",
-			 rtlhal->last_hmeboxnum);
+			  rtlhal->last_hmeboxnum);
 	}
+
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 	rtlhal->h2c_setinprogress = false;
 	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
@@ -219,6 +227,7 @@ void rtl8723be_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
 			  "return H2C cmd because of Fw download fail!!!\n");
 		return;
 	}
+
 	memset(tmp_cmdbuf, 0, 8);
 	memcpy(tmp_cmdbuf, p_cmdbuffer, cmd_len);
 	_rtl8723be_fill_h2c_command(hw, element_id, cmd_len,
@@ -229,17 +238,17 @@ void rtl8723be_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
 void rtl8723be_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 u1_h2c_set_pwrmode[H2C_8723BE_PWEMODE_LENGTH] = { 0 };
+	u8 u1_h2c_set_pwrmode[H2C_PWEMODE_LENGTH] = { 0 };
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	u8 rlbm, power_state = 0;
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, ((mode) ? 1 : 0));
-	rlbm = 0;/*YJ, temp, 120316. FW now not support RLBM = 2.*/
+	rlbm = 0;/*YJ,temp,120316. FW now not support RLBM=2.*/
 	SET_H2CCMD_PWRMODE_PARM_RLBM(u1_h2c_set_pwrmode, rlbm);
 	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
 					 (rtlpriv->mac80211.p2p) ?
-					 ppsc->smart_ps : 1);
+					  ppsc->smart_ps : 1);
 	SET_H2CCMD_PWRMODE_PARM_AWAKE_INTERVAL(u1_h2c_set_pwrmode,
 					       ppsc->reg_max_lps_awakeintvl);
 	SET_H2CCMD_PWRMODE_PARM_ALL_QUEUE_UAPSD(u1_h2c_set_pwrmode, 0);
@@ -251,44 +260,26 @@ void rtl8723be_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
 		      "rtl92c_set_fw_pwrmode(): u1_h2c_set_pwrmode\n",
-		      u1_h2c_set_pwrmode, H2C_8723BE_PWEMODE_LENGTH);
-	rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_SETPWRMODE,
-			       H2C_8723BE_PWEMODE_LENGTH,
+		      u1_h2c_set_pwrmode, H2C_PWEMODE_LENGTH);
+	rtl8723be_fill_h2c_cmd(hw, H2C_8723B_SETPWRMODE, H2C_PWEMODE_LENGTH,
 			       u1_h2c_set_pwrmode);
 }
 
-static bool _rtl8723be_cmd_send_packet(struct ieee80211_hw *hw,
-				       struct sk_buff *skb)
+void rtl8723be_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw, u8 mstatus)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring;
-	struct rtl_tx_desc *pdesc;
-	struct sk_buff *pskb = NULL;
-	u8 own;
-	unsigned long flags;
-
-	ring = &rtlpci->tx_ring[BEACON_QUEUE];
-
-	pskb = __skb_dequeue(&ring->queue);
-	if (pskb)
-		kfree_skb(pskb);
-
-	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
-
-	pdesc = &ring->desc[0];
-	own = (u8) rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
-
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
-
-	__skb_queue_tail(&ring->queue, skb);
-
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
-
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
-
-	return true;
+	u8 parm[3] = { 0, 0, 0 };
+	/* parm[0]: bit0=0-->Disconnect, bit0=1-->Connect
+	 *          bit1=0-->update Media Status to MACID
+	 *          bit1=1-->update Media Status from MACID to MACID_End
+	 * parm[1]: MACID, if this is INFRA_STA, MacID = 0
+	 * parm[2]: MACID_End
+	*/
+	SET_H2CCMD_MSRRPT_PARM_OPMODE(parm, mstatus);
+	SET_H2CCMD_MSRRPT_PARM_MACID_IND(parm, 0);
+
+	rtl8723be_fill_h2c_cmd(hw, H2C_8723B_MSRRPT, 3, parm);
 }
+
 #define BEACON_PG		0 /* ->1 */
 #define PSPOLL_PG		2
 #define NULL_PG			3
@@ -407,7 +398,7 @@ static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] = {
 };
 
 void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
-				  bool dl_finished)
+				  bool b_dl_finished)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -416,7 +407,7 @@ void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 	u32 totalpacketlen;
 	bool rtstatus;
 	u8 u1rsvdpageloc[5] = { 0 };
-	bool dlok = false;
+	bool b_dlok = false;
 
 	u8 *beacon;
 	u8 *p_pspoll;
@@ -466,43 +457,40 @@ void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
 	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "rtl8723be_set_fw_rsvdpagepkt(): "
-		      "HW_VAR_SET_TX_CMD: ALL\n",
+		      "rtl8723be_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
 		      &reserved_page_packet[0], totalpacketlen);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl8723be_set_fw_rsvdpagepkt(): "
-		      "HW_VAR_SET_TX_CMD: ALL\n", u1rsvdpageloc, 3);
-
+		      "rtl8723be_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
 	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = _rtl8723be_cmd_send_packet(hw, skb);
+	rtstatus = rtl8723_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
-		dlok = true;
+		b_dlok = true;
 
-	if (dlok) {
+	if (b_dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "Set RSVD page location to Fw.\n");
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG, "H2C_RSVDPAGE:\n",
 			      u1rsvdpageloc, 3);
-		rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_RSVDPAGE,
+		rtl8723be_fill_h2c_cmd(hw, H2C_8723B_RSVDPAGE,
 				       sizeof(u1rsvdpageloc), u1rsvdpageloc);
-	} else {
+	} else
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
-	}
 }
 
 /*Should check FW support p2p or not.*/
 static void rtl8723be_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw,
 					     u8 ctwindow)
 {
-	u8 u1_ctwindow_period[1] = {ctwindow};
+	u8 u1_ctwindow_period[1] = { ctwindow};
 
-	rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_P2P_PS_CTW_CMD, 1,
+	rtl8723be_fill_h2c_cmd(hw, H2C_8723B_P2P_PS_CTW_CMD, 1,
 			       u1_ctwindow_period);
 }
 
@@ -521,7 +509,7 @@ void rtl8723be_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw,
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
-		memset(p2p_ps_offload, 0, sizeof(struct p2p_ps_offload_t));
+		memset(p2p_ps_offload, 0, sizeof(*p2p_ps_offload));
 		break;
 	case P2P_PS_ENABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
@@ -532,7 +520,7 @@ void rtl8723be_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw,
 			rtl8723be_set_p2p_ctw_period_cmd(hw, ctwindow);
 		}
 		/* hw only support 2 set of NoA */
-		for (i = 0; i < p2pinfo->noa_num; i++) {
+		for (i = 0 ; i < p2pinfo->noa_num ; i++) {
 			/* To control the register setting
 			 * for which NOA
 			 */
@@ -563,6 +551,7 @@ void rtl8723be_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw,
 			rtl_write_dword(rtlpriv, 0x5EC,
 					p2pinfo->noa_count_type[i]);
 		}
+
 		if ((p2pinfo->opp_ps == 1) ||
 		    (p2pinfo->noa_num > 0)) {
 			/* rst p2p circuit */
@@ -591,30 +580,60 @@ void rtl8723be_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw,
 	default:
 		break;
 	}
-	rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_P2P_PS_OFFLOAD, 1,
+
+	rtl8723be_fill_h2c_cmd(hw, H2C_8723B_P2P_PS_OFFLOAD, 1,
 			       (u8 *)p2p_ps_offload);
 }
 
-void rtl8723be_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
+static void _rtl8723be_c2h_content_parsing(struct ieee80211_hw *hw,
+					   u8 c2h_cmd_id,
+					   u8 c2h_cmd_len, u8 *tmp_buf)
 {
-	u8 u1_joinbssrpt_parm[1] = { 0 };
-
-	SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(u1_joinbssrpt_parm, mstatus);
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_JOINBSSRPT, 1,
-			       u1_joinbssrpt_parm);
+	switch (c2h_cmd_id) {
+	case C2H_8723B_DBG:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+			 "[C2H], C2H_8723BE_DBG!!\n");
+		break;
+	case C2H_8723B_TX_REPORT:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+			 "[C2H], C2H_8723BE_TX_REPORT!\n");
+		break;
+	case C2H_8723B_BT_INFO:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+			 "[C2H], C2H_8723BE_BT_INFO!!\n");
+		rtlpriv->btcoexist.btc_ops->btc_btinfo_notify(rtlpriv, tmp_buf,
+							      c2h_cmd_len);
+		break;
+	case C2H_8723B_BT_MP:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+			 "[C2H], C2H_8723BE_BT_MP!!\n");
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+			 "[C2H], Unkown packet!! CmdId(%#X)!\n", c2h_cmd_id);
+		break;
+	}
 }
 
-void rtl8723be_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
-				      u8 ap_offload_enable)
+void rtl8723be_c2h_packet_handler(struct ieee80211_hw *hw, u8 *buffer, u8 len)
 {
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	u8 u1_apoffload_parm[H2C_8723BE_AP_OFFLOAD_LENGTH] = { 0 };
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 c2h_cmd_id = 0, c2h_cmd_seq = 0, c2h_cmd_len = 0;
+	u8 *tmp_buf = NULL;
+
+	c2h_cmd_id = buffer[0];
+	c2h_cmd_seq = buffer[1];
+	c2h_cmd_len = len - 2;
+	tmp_buf = buffer + 2;
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
+		 "[C2H packet], c2hCmdId=0x%x, c2hCmdSeq=0x%x, c2hCmdLen=%d\n",
+		 c2h_cmd_id, c2h_cmd_seq, c2h_cmd_len);
 
-	SET_H2CCMD_AP_OFFLOAD_ON(u1_apoffload_parm, ap_offload_enable);
-	SET_H2CCMD_AP_OFFLOAD_HIDDEN(u1_apoffload_parm, mac->hiddenssid);
-	SET_H2CCMD_AP_OFFLOAD_DENYANY(u1_apoffload_parm, 0);
+	RT_PRINT_DATA(rtlpriv, COMP_FW, DBG_TRACE,
+		      "[C2H packet], Content Hex:\n", tmp_buf, c2h_cmd_len);
 
-	rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_AP_OFFLOAD,
-			       H2C_8723BE_AP_OFFLOAD_LENGTH, u1_apoffload_parm);
+	_rtl8723be_c2h_content_parsing(hw, c2h_cmd_id, c2h_cmd_len, tmp_buf);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/fw.h b/drivers/net/wireless/rtlwifi/rtl8723be/fw.h
index 31eec28..0674296 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/fw.h
@@ -30,50 +30,23 @@
 #define FW_8192C_END_ADDRESS			0x5FFF
 #define FW_8192C_PAGE_SIZE			4096
 #define FW_8192C_POLLING_DELAY			5
-#define FW_8192C_POLLING_TIMEOUT_COUNT		6000
 
-#define IS_FW_HEADER_EXIST(_pfwhdr)	\
-	((_pfwhdr->signature&0xFFF0) == 0x5300)
 #define USE_OLD_WOWLAN_DEBUG_FW			0
 
-#define H2C_8723BE_RSVDPAGE_LOC_LEN		5
-#define H2C_8723BE_PWEMODE_LENGTH		5
-#define H2C_8723BE_JOINBSSRPT_LENGTH		1
-#define H2C_8723BE_AP_OFFLOAD_LENGTH		3
-#define H2C_8723BE_WOWLAN_LENGTH		3
-#define H2C_8723BE_KEEP_ALIVE_CTRL_LENGTH	3
-#if (USE_OLD_WOWLAN_DEBUG_FW == 0)
-#define H2C_8723BE_REMOTE_WAKE_CTRL_LEN		1
-#else
-#define H2C_8723BE_REMOTE_WAKE_CTRL_LEN		3
-#endif
-#define H2C_8723BE_AOAC_GLOBAL_INFO_LEN		2
-#define H2C_8723BE_AOAC_RSVDPAGE_LOC_LEN	7
-
+#define H2C_PWEMODE_LENGTH			5
 
 /* Fw PS state for RPWM.
 *BIT[2:0] = HW state
 *BIT[3] = Protocol PS state, 1: register active state , 0: register sleep state
 *BIT[4] = sub-state
 */
-#define	FW_PS_GO_ON		BIT(0)
-#define	FW_PS_TX_NULL		BIT(1)
 #define	FW_PS_RF_ON		BIT(2)
 #define	FW_PS_REGISTER_ACTIVE	BIT(3)
 
-#define	FW_PS_DPS		BIT(0)
-#define	FW_PS_LCLK		(FW_PS_DPS)
-#define	FW_PS_RF_OFF		BIT(1)
-#define	FW_PS_ALL_ON		BIT(2)
-#define	FW_PS_ST_ACTIVE	BIT(3)
-#define	FW_PS_ISR_ENABLE	BIT(4)
-#define	FW_PS_IMR_ENABLE	BIT(5)
-
-
 #define	FW_PS_ACK		BIT(6)
 #define	FW_PS_TOGGLE		BIT(7)
 
- /* 88E RPWM value*/
+ /* 8723BE RPWM value*/
  /* BIT[0] = 1: 32k, 0: 40M*/
 #define	FW_PS_CLOCK_OFF		BIT(0)		/* 32k*/
 #define	FW_PS_CLOCK_ON		0		/*40M*/
@@ -83,75 +56,61 @@
 /*ISR_ENABLE, IMR_ENABLE, and PS mode should be inherited.*/
 #define	FW_PS_STATE_INT_MASK	(0x3F)
 
-#define	FW_PS_STATE(x)	(FW_PS_STATE_MASK & (x))
-#define	FW_PS_STATE_HW(x)	(FW_PS_STATE_HW_MASK & (x))
-#define	FW_PS_STATE_INT(x)	(FW_PS_STATE_INT_MASK & (x))
-#define	FW_PS_ISR_VAL(x)	((x) & 0x70)
-#define	FW_PS_IMR_MASK(x)	((x) & 0xDF)
-#define	FW_PS_KEEP_IMR(x)	((x) & 0x20)
-
-
-#define	FW_PS_STATE_S0		(FW_PS_DPS)
-#define	FW_PS_STATE_S1		(FW_PS_LCLK)
-#define	FW_PS_STATE_S2		(FW_PS_RF_OFF)
-#define	FW_PS_STATE_S3		(FW_PS_ALL_ON)
-#define	FW_PS_STATE_S4		((FW_PS_ST_ACTIVE) | (FW_PS_ALL_ON))
+#define	FW_PS_STATE(x)		(FW_PS_STATE_MASK & (x))
 
 /* ((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))*/
-#define	FW_PS_STATE_ALL_ON_88E	(FW_PS_CLOCK_ON)
+#define	FW_PS_STATE_ALL_ON	(FW_PS_CLOCK_ON)
 /* (FW_PS_RF_ON)*/
-#define	FW_PS_STATE_RF_ON_88E	(FW_PS_CLOCK_ON)
+#define	FW_PS_STATE_RF_ON	(FW_PS_CLOCK_ON)
 /* 0x0*/
-#define	FW_PS_STATE_RF_OFF_88E	(FW_PS_CLOCK_ON)
+#define	FW_PS_STATE_RF_OFF	(FW_PS_CLOCK_ON)
 /* (FW_PS_STATE_RF_OFF)*/
-#define	FW_PS_STATE_RF_OFF_LOW_PWR_88E	(FW_PS_CLOCK_OFF)
+#define	FW_PS_STATE_RF_OFF_LOW_PWR	(FW_PS_CLOCK_OFF)
 
-#define	FW_PS_STATE_ALL_ON_92C	(FW_PS_STATE_S4)
-#define	FW_PS_STATE_RF_ON_92C		(FW_PS_STATE_S3)
-#define	FW_PS_STATE_RF_OFF_92C	(FW_PS_STATE_S2)
-#define	FW_PS_STATE_RF_OFF_LOW_PWR_92C	(FW_PS_STATE_S1)
 
-
-/* For 88E H2C PwrMode Cmd ID 5.*/
+/* For 8723BE H2C PwrMode Cmd ID 5.*/
 #define	FW_PWR_STATE_ACTIVE	((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))
 #define	FW_PWR_STATE_RF_OFF	0
 
-#define	FW_PS_IS_ACK(x)	((x) & FW_PS_ACK)
-#define	FW_PS_IS_CLK_ON(x)	((x) & (FW_PS_RF_OFF | FW_PS_ALL_ON))
-#define	FW_PS_IS_RF_ON(x)	((x) & (FW_PS_ALL_ON))
-#define	FW_PS_IS_ACTIVE(x)	((x) & (FW_PS_ST_ACTIVE))
-#define	FW_PS_IS_CPWM_INT(x)	((x) & 0x40)
-
-#define	FW_CLR_PS_STATE(x)	((x) = ((x) & (0xF0)))
+#define	FW_PS_IS_ACK(x)		((x) & FW_PS_ACK)
 
-#define	IS_IN_LOW_POWER_STATE_88E(fwpsstate)		\
-			(FW_PS_STATE(fwpsstate) == FW_PS_CLOCK_OFF)
+#define	IS_IN_LOW_POWER_STATE(__fwpsstate)	\
+	(FW_PS_STATE(__fwpsstate) == FW_PS_CLOCK_OFF)
 
 #define	FW_PWR_STATE_ACTIVE	((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))
 #define	FW_PWR_STATE_RF_OFF	0
 
-#define pagenum_128(_len)	(u32)(((_len)>>7) + ((_len)&0x7F ? 1 : 0))
-
-#define SET_88E_H2CCMD_WOWLAN_FUNC_ENABLE(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_PATTERN_MATCH_ENABLE(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 1, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_MAGIC_PKT_ENABLE(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 2, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_UNICAST_PKT_ENABLE(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 3, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_ALL_PKT_DROP(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 4, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_GPIO_ACTIVE(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 5, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_REKEY_WAKE_UP(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 6, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_DISCONNECT_WAKE_UP(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 7, 1, __val)
-#define SET_88E_H2CCMD_WOWLAN_GPIONUM(__ph2ccmd, __val)			\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
-#define SET_88E_H2CCMD_WOWLAN_GPIO_DURATION(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
+enum rtl8723b_h2c_cmd {
+	H2C_8723B_RSVDPAGE = 0,
+	H2C_8723B_MSRRPT = 1,
+	H2C_8723B_SCAN = 2,
+	H2C_8723B_KEEP_ALIVE_CTRL = 3,
+	H2C_8723B_DISCONNECT_DECISION = 4,
+	H2C_8723B_BCN_RSVDPAGE = 9,
+	H2C_8723B_PROBERSP_RSVDPAGE = 10,
+
+	H2C_8723B_SETPWRMODE = 0x20,
+	H2C_8723B_PS_LPS_PARA = 0x23,
+	H2C_8723B_P2P_PS_OFFLOAD = 0x24,
+
+	H2C_8723B_RA_MASK = 0x40,
+	H2C_RSSIBE_REPORT = 0x42,
+	/*Not defined CTW CMD for P2P yet*/
+	H2C_8723B_P2P_PS_CTW_CMD,
+	MAX_8723B_H2CCMD
+};
+
+enum rtl8723b_c2h_evt {
+	C2H_8723B_DBG = 0,
+	C2H_8723B_LB = 1,
+	C2H_8723B_TXBF = 2,
+	C2H_8723B_TX_REPORT = 3,
+	C2H_8723B_BT_INFO = 9,
+	C2H_8723B_BT_MP = 11,
+	MAX_8723B_C2HEVENT
+};
+
+#define pagenum_128(_len) (u32)(((_len)>>7) + ((_len)&0x7F ? 1 : 0))
 
 
 #define SET_H2CCMD_PWRMODE_PARM_MODE(__ph2ccmd, __val)			\
@@ -169,8 +128,11 @@
 #define GET_88E_H2CCMD_PWRMODE_PARM_MODE(__ph2ccmd)			\
 	LE_BITS_TO_1BYTE(__ph2ccmd, 0, 8)
 
-#define SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
+#define SET_H2CCMD_MSRRPT_PARM_OPMODE(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 1, __val)
+#define SET_H2CCMD_MSRRPT_PARM_MACID_IND(__ph2ccmd, __val)	\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 1, 1, __val)
+
 #define SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(__ph2ccmd, __val)		\
 	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
 #define SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(__ph2ccmd, __val)		\
@@ -178,71 +140,13 @@
 #define SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(__ph2ccmd, __val)		\
 	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
 
-/* AP_OFFLOAD */
-#define SET_H2CCMD_AP_OFFLOAD_ON(__ph2ccmd, __val)			\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
-#define SET_H2CCMD_AP_OFFLOAD_HIDDEN(__ph2ccmd, __val)			\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
-#define SET_H2CCMD_AP_OFFLOAD_DENYANY(__ph2ccmd, __val)			\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
-#define SET_H2CCMD_AP_OFFLOAD_WAKEUP_EVT_RPT(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+3, 0, 8, __val)
 
-/* Keep Alive Control*/
-#define SET_88E_H2CCMD_KEEP_ALIVE_ENABLE(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 1, __val)
-#define SET_88E_H2CCMD_KEEP_ALIVE_ACCPEPT_USER_DEFINED(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 1, 1, __val)
-#define SET_88E_H2CCMD_KEEP_ALIVE_PERIOD(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
-
-/*REMOTE_WAKE_CTRL */
-#define SET_88E_H2CCMD_REMOTE_WAKE_CTRL_EN(__ph2ccmd, __val)		\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 1, __val)
-#if (USE_OLD_WOWLAN_DEBUG_FW == 0)
-#define SET_88E_H2CCMD_REMOTE_WAKE_CTRL_ARP_OFFLOAD_EN(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 1, 1, __val)
-#define SET_88E_H2CCMD_REMOTE_WAKE_CTRL_NDP_OFFLOAD_EN(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 2, 1, __val)
-#define SET_88E_H2CCMD_REMOTE_WAKE_CTRL_GTK_OFFLOAD_EN(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 3, 1, __val)
-#else
-#define SET_88E_H2CCMD_REMOTE_WAKE_CTRL_PAIRWISE_ENC_ALG(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
-#define SET_88E_H2CCMD_REMOTE_WAKE_CTRL_GROUP_ENC_ALG(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
-#endif
-
-/* GTK_OFFLOAD */
-#define SET_88E_H2CCMD_AOAC_GLOBAL_INFO_PAIRWISE_ENC_ALG(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
-#define SET_88E_H2CCMD_AOAC_GLOBAL_INFO_GROUP_ENC_ALG(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
-
-/* AOAC_RSVDPAGE_LOC */
-#define SET_88E_H2CCMD_AOAC_RSVDPAGE_LOC_REM_WAKE_CTRL_INFO(__ph2ccmd, __val)\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd), 0, 8, __val)
-#define SET_88E_H2CCMD_AOAC_RSVDPAGE_LOC_ARP_RSP(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
-#define SET_88E_H2CCMD_AOAC_RSVDPAGE_LOC_NEIGHBOR_ADV(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
-#define SET_88E_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_RSP(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+3, 0, 8, __val)
-#define SET_88E_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_INFO(__ph2ccmd, __val)	\
-	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+4, 0, 8, __val)
-
-void rtl8723be_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
-void rtl8723be_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
-				      u8 ap_offload_enable);
 void rtl8723be_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
 			    u32 cmd_len, u8 *p_cmdbuffer);
-void rtl8723be_firmware_selfreset(struct ieee80211_hw *hw);
-void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
-				  bool dl_finished);
-void rtl8723be_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
-int rtl8723be_download_fw(struct ieee80211_hw *hw,
-			  bool buse_wake_on_wlan_fw);
-void rtl8723be_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw,
-				      u8 p2p_ps_state);
+void rtl8723be_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
+void rtl8723be_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw, u8 mstatus);
+void rtl8723be_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
+void rtl8723be_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
+void rtl8723be_c2h_packet_handler(struct ieee80211_hw *hw, u8 *buffer, u8 len);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index d296b5c..6dad28e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -33,6 +33,7 @@
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
+#include "../rtl8723com/phy_common.h"
 #include "dm.h"
 #include "../rtl8723com/dm_common.h"
 #include "fw.h"
@@ -50,7 +51,9 @@ static void _rtl8723be_return_beacon_queue_skb(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[BEACON_QUEUE];
+	unsigned long flags;
 
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	while (skb_queue_len(&ring->queue)) {
 		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
 		struct sk_buff *skb = __skb_dequeue(&ring->queue);
@@ -62,6 +65,7 @@ static void _rtl8723be_return_beacon_queue_skb(struct ieee80211_hw *hw)
 		kfree_skb(skb);
 		ring->idx = (ring->idx + 1) % ring->entries;
 	}
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 }
 
 static void _rtl8723be_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
@@ -73,7 +77,7 @@ static void _rtl8723be_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
 	rtlpci->reg_bcn_ctrl_val |= set_bits;
 	rtlpci->reg_bcn_ctrl_val &= ~clear_bits;
 
-	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8) rtlpci->reg_bcn_ctrl_val);
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8)rtlpci->reg_bcn_ctrl_val);
 }
 
 static void _rtl8723be_stop_tx_beacon(struct ieee80211_hw *hw)
@@ -113,15 +117,15 @@ static void _rtl8723be_disable_bcn_sub_func(struct ieee80211_hw *hw)
 }
 
 static void _rtl8723be_set_fw_clock_on(struct ieee80211_hw *hw, u8 rpwm_val,
-				       bool need_turn_off_ckk)
+				       bool b_need_turn_off_ckk)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	bool support_remote_wake_up;
+	bool b_support_remote_wake_up;
 	u32 count = 0, isr_regaddr, content;
-	bool schedule_timer = need_turn_off_ckk;
+	bool b_schedule_timer = b_need_turn_off_ckk;
 	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
-				      (u8 *)(&support_remote_wake_up));
+				      (u8 *)(&b_support_remote_wake_up));
 
 	if (!rtlhal->fw_ready)
 		return;
@@ -146,9 +150,10 @@ static void _rtl8723be_set_fw_clock_on(struct ieee80211_hw *hw, u8 rpwm_val,
 			break;
 		}
 	}
-	if (IS_IN_LOW_POWER_STATE_88E(rtlhal->fw_ps_state)) {
+
+	if (IS_IN_LOW_POWER_STATE(rtlhal->fw_ps_state)) {
 		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_SET_RPWM,
-					      &rpwm_val);
+					      (u8 *)(&rpwm_val));
 		if (FW_PS_IS_ACK(rpwm_val)) {
 			isr_regaddr = REG_HISR;
 			content = rtl_read_dword(rtlpriv, isr_regaddr);
@@ -160,20 +165,19 @@ static void _rtl8723be_set_fw_clock_on(struct ieee80211_hw *hw, u8 rpwm_val,
 
 			if (content & IMR_CPWM) {
 				rtl_write_word(rtlpriv, isr_regaddr, 0x0100);
-				rtlhal->fw_ps_state = FW_PS_STATE_RF_ON_88E;
+				rtlhal->fw_ps_state = FW_PS_STATE_RF_ON;
 				RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-					 "Receive CPWM INT!!! Set "
-					 "pHalData->FwPSState = %X\n",
+					 "Receive CPWM INT!!! Set pHalData->FwPSState = %X\n",
 					 rtlhal->fw_ps_state);
 			}
 		}
+
 		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 		rtlhal->fw_clk_change_in_progress = false;
 		spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
-		if (schedule_timer) {
+		if (b_schedule_timer)
 			mod_timer(&rtlpriv->works.fw_clockoff_timer,
 				  jiffies + MSECS(10));
-		}
 	} else  {
 		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 		rtlhal->fw_clk_change_in_progress = false;
@@ -188,7 +192,7 @@ static void _rtl8723be_set_fw_clock_off(struct ieee80211_hw *hw, u8 rpwm_val)
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring;
 	enum rf_pwrstate rtstate;
-	bool schedule_timer = false;
+	bool b_schedule_timer = false;
 	u8 queue;
 
 	if (!rtlhal->fw_ready)
@@ -204,17 +208,18 @@ static void _rtl8723be_set_fw_clock_off(struct ieee80211_hw *hw, u8 rpwm_val)
 	for (queue = 0; queue < RTL_PCI_MAX_TX_QUEUE_COUNT; queue++) {
 		ring = &rtlpci->tx_ring[queue];
 		if (skb_queue_len(&ring->queue)) {
-			schedule_timer = true;
+			b_schedule_timer = true;
 			break;
 		}
 	}
-	if (schedule_timer) {
+
+	if (b_schedule_timer) {
 		mod_timer(&rtlpriv->works.fw_clockoff_timer,
 			  jiffies + MSECS(10));
 		return;
 	}
-	if (FW_PS_STATE(rtlhal->fw_ps_state) !=
-	    FW_PS_STATE_RF_OFF_LOW_PWR_88E) {
+
+	if (FW_PS_STATE(rtlhal->fw_ps_state) != FW_PS_STATE_RF_OFF_LOW_PWR) {
 		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 		if (!rtlhal->fw_clk_change_in_progress) {
 			rtlhal->fw_clk_change_in_progress = true;
@@ -222,7 +227,7 @@ static void _rtl8723be_set_fw_clock_off(struct ieee80211_hw *hw, u8 rpwm_val)
 			rtlhal->fw_ps_state = FW_PS_STATE(rpwm_val);
 			rtl_write_word(rtlpriv, REG_HISR, 0x0100);
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-						      &rpwm_val);
+						      (u8 *)(&rpwm_val));
 			spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 			rtlhal->fw_clk_change_in_progress = false;
 			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
@@ -232,12 +237,13 @@ static void _rtl8723be_set_fw_clock_off(struct ieee80211_hw *hw, u8 rpwm_val)
 				  jiffies + MSECS(10));
 		}
 	}
+
 }
 
 static void _rtl8723be_set_fw_ps_rf_on(struct ieee80211_hw *hw)
 {
 	u8 rpwm_val = 0;
-	rpwm_val |= (FW_PS_STATE_RF_OFF_88E | FW_PS_ACK);
+	rpwm_val |= (FW_PS_STATE_RF_OFF | FW_PS_ACK);
 	_rtl8723be_set_fw_clock_on(hw, rpwm_val, true);
 }
 
@@ -250,21 +256,23 @@ static void _rtl8723be_fwlps_leave(struct ieee80211_hw *hw)
 	u8 rpwm_val = 0, fw_pwrmode = FW_PS_ACTIVE_MODE;
 
 	if (ppsc->low_power_enable) {
-		rpwm_val = (FW_PS_STATE_ALL_ON_88E | FW_PS_ACK);/* RF on */
+		rpwm_val = (FW_PS_STATE_ALL_ON | FW_PS_ACK);/* RF on */
 		_rtl8723be_set_fw_clock_on(hw, rpwm_val, false);
 		rtlhal->allow_sw_to_change_hwclc = false;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      &fw_pwrmode);
+					      (u8 *)(&fw_pwrmode));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 	} else {
-		rpwm_val = FW_PS_STATE_ALL_ON_88E;	/* RF on */
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
+		rpwm_val = FW_PS_STATE_ALL_ON;	/* RF on */
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+					      (u8 *)(&rpwm_val));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      &fw_pwrmode);
+					      (u8 *)(&fw_pwrmode));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 	}
+
 }
 
 static void _rtl8723be_fwlps_enter(struct ieee80211_hw *hw)
@@ -276,22 +284,23 @@ static void _rtl8723be_fwlps_enter(struct ieee80211_hw *hw)
 	u8 rpwm_val;
 
 	if (ppsc->low_power_enable) {
-		rpwm_val = FW_PS_STATE_RF_OFF_LOW_PWR_88E;	/* RF off */
+		rpwm_val = FW_PS_STATE_RF_OFF_LOW_PWR;	/* RF off */
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      &ppsc->fwctrl_psmode);
+					      (u8 *)(&ppsc->fwctrl_psmode));
 		rtlhal->allow_sw_to_change_hwclc = true;
 		_rtl8723be_set_fw_clock_off(hw, rpwm_val);
-
 	} else {
-		rpwm_val = FW_PS_STATE_RF_OFF_88E;	/* RF off */
+		rpwm_val = FW_PS_STATE_RF_OFF;	/* RF off */
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
 					      (u8 *)(&fw_current_inps));
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-					      &ppsc->fwctrl_psmode);
-		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM, &rpwm_val);
+					      (u8 *)(&ppsc->fwctrl_psmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+					      (u8 *)(&rpwm_val));
 	}
+
 }
 
 void rtl8723be_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
@@ -307,13 +316,13 @@ void rtl8723be_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_RF_STATE:
 		*((enum rf_pwrstate *)(val)) = ppsc->rfpwr_state;
 		break;
-	case HW_VAR_FWLPS_RF_ON: {
-		enum rf_pwrstate rfstate;
+	case HW_VAR_FWLPS_RF_ON:{
+		enum rf_pwrstate rfState;
 		u32 val_rcr;
 
 		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RF_STATE,
-					      (u8 *)(&rfstate));
-		if (rfstate == ERFOFF) {
+					      (u8 *)(&rfState));
+		if (rfState == ERFOFF) {
 			*((bool *)(val)) = true;
 		} else {
 			val_rcr = rtl_read_dword(rtlpriv, REG_RCR);
@@ -323,11 +332,12 @@ void rtl8723be_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			else
 				*((bool *)(val)) = true;
 		}
-		break; }
+		}
+		break;
 	case HW_VAR_FW_PSMODE_STATUS:
 		*((bool *)(val)) = ppsc->fw_current_inpsmode;
 		break;
-	case HW_VAR_CORRECT_TSF: {
+	case HW_VAR_CORRECT_TSF:{
 		u64 tsf;
 		u32 *ptsf_low = (u32 *)&tsf;
 		u32 *ptsf_high = ((u32 *)&tsf) + 1;
@@ -336,15 +346,65 @@ void rtl8723be_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		*ptsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
 
 		*((u64 *)(val)) = tsf;
-
-		break; }
+		}
+		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "switch case not process %x\n", variable);
 		break;
 	}
 }
 
+static void _rtl8723be_download_rsvd_page(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 tmp_regcr, tmp_reg422, bcnvalid_reg;
+	u8 count = 0, dlbcn_count = 0;
+	bool b_recover = false;
+
+	tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1,
+		       (tmp_regcr | BIT(0)));
+
+	_rtl8723be_set_bcn_ctrl_reg(hw, 0, BIT(3));
+	_rtl8723be_set_bcn_ctrl_reg(hw, BIT(4), 0);
+
+	tmp_reg422 = rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp_reg422 & (~BIT(6)));
+	if (tmp_reg422 & BIT(6))
+		b_recover = true;
+
+	do {
+		bcnvalid_reg = rtl_read_byte(rtlpriv, REG_TDECTRL + 2);
+		rtl_write_byte(rtlpriv, REG_TDECTRL + 2,
+			       (bcnvalid_reg | BIT(0)));
+		_rtl8723be_return_beacon_queue_skb(hw);
+
+		rtl8723be_set_fw_rsvdpagepkt(hw, 0);
+		bcnvalid_reg = rtl_read_byte(rtlpriv, REG_TDECTRL + 2);
+		count = 0;
+		while (!(bcnvalid_reg & BIT(0)) && count < 20) {
+			count++;
+			udelay(10);
+			bcnvalid_reg = rtl_read_byte(rtlpriv,
+						     REG_TDECTRL + 2);
+		}
+		dlbcn_count++;
+	} while (!(bcnvalid_reg & BIT(0)) && dlbcn_count < 5);
+
+	if (bcnvalid_reg & BIT(0))
+		rtl_write_byte(rtlpriv, REG_TDECTRL + 2, BIT(0));
+
+	_rtl8723be_set_bcn_ctrl_reg(hw, BIT(3), 0);
+	_rtl8723be_set_bcn_ctrl_reg(hw, 0, BIT(4));
+
+	if (b_recover)
+		rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp_reg422);
+
+	tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, (tmp_regcr & ~(BIT(0))));
+}
+
 void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -359,22 +419,24 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		for (idx = 0; idx < ETH_ALEN; idx++)
 			rtl_write_byte(rtlpriv, (REG_MACID + idx), val[idx]);
 		break;
-	case HW_VAR_BASIC_RATE: {
-		u16 rate_cfg = ((u16 *)val)[0];
+	case HW_VAR_BASIC_RATE:{
+		u16 b_rate_cfg = ((u16 *)val)[0];
 		u8 rate_index = 0;
-		rate_cfg = rate_cfg & 0x15f;
-		rate_cfg |= 0x01;
-		rtl_write_byte(rtlpriv, REG_RRSR, rate_cfg & 0xff);
-		rtl_write_byte(rtlpriv, REG_RRSR + 1, (rate_cfg >> 8) & 0xff);
-		while (rate_cfg > 0x1) {
-			rate_cfg = (rate_cfg >> 1);
+		b_rate_cfg = b_rate_cfg & 0x15f;
+		b_rate_cfg |= 0x01;
+		rtl_write_byte(rtlpriv, REG_RRSR, b_rate_cfg & 0xff);
+		rtl_write_byte(rtlpriv, REG_RRSR + 1, (b_rate_cfg >> 8) & 0xff);
+		while (b_rate_cfg > 0x1) {
+			b_rate_cfg = (b_rate_cfg >> 1);
 			rate_index++;
 		}
 		rtl_write_byte(rtlpriv, REG_INIRTS_RATE_SEL, rate_index);
-		break; }
+		}
+		break;
 	case HW_VAR_BSSID:
 		for (idx = 0; idx < ETH_ALEN; idx++)
 			rtl_write_byte(rtlpriv, (REG_BSSID + idx), val[idx]);
+
 		break;
 	case HW_VAR_SIFS:
 		rtl_write_byte(rtlpriv, REG_SIFS_CTX + 1, val[0]);
@@ -389,7 +451,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
 				       *((u16 *)val));
 		break;
-	case HW_VAR_SLOT_TIME: {
+	case HW_VAR_SLOT_TIME:{
 		u8 e_aci;
 
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -399,12 +461,13 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      &e_aci);
+						      (u8 *)(&e_aci));
 		}
-		break; }
-	case HW_VAR_ACK_PREAMBLE: {
+		}
+		break;
+	case HW_VAR_ACK_PREAMBLE:{
 		u8 reg_tmp;
-		u8 short_preamble = (bool)*val;
+		u8 short_preamble = (bool)(*(u8 *)val);
 		reg_tmp = rtl_read_byte(rtlpriv, REG_TRXPTCL_CTL + 2);
 		if (short_preamble) {
 			reg_tmp |= 0x02;
@@ -413,15 +476,16 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			reg_tmp &= 0xFD;
 			rtl_write_byte(rtlpriv, REG_TRXPTCL_CTL + 2, reg_tmp);
 		}
-		break; }
+		}
+		break;
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
+		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *)val));
 		break;
-	case HW_VAR_AMPDU_MIN_SPACE: {
+	case HW_VAR_AMPDU_MIN_SPACE:{
 		u8 min_spacing_to_set;
 		u8 sec_min_space;
 
-		min_spacing_to_set = *val;
+		min_spacing_to_set = *((u8 *)val);
 		if (min_spacing_to_set <= 7) {
 			sec_min_space = 0;
 
@@ -435,26 +499,28 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
 				 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
-				 mac->min_space_cfg);
+				  mac->min_space_cfg);
 
 			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 				       mac->min_space_cfg);
 		}
-		break; }
-	case HW_VAR_SHORTGI_DENSITY: {
+		}
+		break;
+	case HW_VAR_SHORTGI_DENSITY:{
 		u8 density_to_set;
 
-		density_to_set = *val;
+		density_to_set = *((u8 *)val);
 		mac->min_space_cfg |= (density_to_set << 3);
 
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
 			 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
-			 mac->min_space_cfg);
+			  mac->min_space_cfg);
 
 		rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 			       mac->min_space_cfg);
-		break; }
-	case HW_VAR_AMPDU_FACTOR: {
+		}
+		break;
+	case HW_VAR_AMPDU_FACTOR:{
 		u8 regtoset_normal[4] = {0x41, 0xa8, 0x72, 0xb9};
 		u8 factor_toset;
 		u8 *p_regtoset = NULL;
@@ -462,7 +528,7 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		p_regtoset = regtoset_normal;
 
-		factor_toset = *val;
+		factor_toset = *((u8 *)val);
 		if (factor_toset <= 3) {
 			factor_toset = (1 << (factor_toset + 2));
 			if (factor_toset > 0xf)
@@ -483,22 +549,26 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				rtl_write_byte(rtlpriv,
 					       (REG_AGGLEN_LMT + index),
 					       p_regtoset[index]);
+
 			}
+
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
 				 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
-				 factor_toset);
+				  factor_toset);
 		}
-		break; }
-	case HW_VAR_AC_PARAM: {
-		u8 e_aci = *val;
+		}
+		break;
+	case HW_VAR_AC_PARAM:{
+		u8 e_aci = *((u8 *)val);
 		rtl8723_dm_init_edca_turbo(hw);
 
 		if (rtlpci->acm_method != EACMWAY2_SW)
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
-						      &e_aci);
-		break; }
-	case HW_VAR_ACM_CTRL: {
-		u8 e_aci = *val;
+						      (u8 *)(&e_aci));
+		}
+		break;
+	case HW_VAR_ACM_CTRL:{
+		u8 e_aci = *((u8 *)val);
 		union aci_aifsn *p_aci_aifsn =
 				(union aci_aifsn *)(&(mac->ac[0].aifs));
 		u8 acm = p_aci_aifsn->f.acm;
@@ -520,8 +590,8 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "HW_VAR_ACM_CTRL acm set "
-					  "failed: eACI is %d\n", acm);
+					 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+					 acm);
 				break;
 			}
 		} else {
@@ -536,27 +606,30 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				acm_ctrl &= (~ACMHW_BEQEN);
 				break;
 			default:
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 					 "switch case not process\n");
 				break;
 			}
 		}
+
 		RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
-			 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] "
-			 "Write 0x%X\n", acm_ctrl);
+			 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+			 acm_ctrl);
 		rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
-		break; }
+		}
+		break;
 	case HW_VAR_RCR:
 		rtl_write_dword(rtlpriv, REG_RCR, ((u32 *)(val))[0]);
 		rtlpci->receive_config = ((u32 *)(val))[0];
 		break;
-	case HW_VAR_RETRY_LIMIT: {
-		u8 retry_limit = *val;
+	case HW_VAR_RETRY_LIMIT:{
+		u8 retry_limit = ((u8 *)(val))[0];
 
 		rtl_write_word(rtlpriv, REG_RL,
 			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
 			       retry_limit << RETRY_LIMIT_LONG_SHIFT);
-		break; }
+		}
+		break;
 	case HW_VAR_DUAL_TSF_RST:
 		rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, (BIT(0) | BIT(1)));
 		break;
@@ -564,25 +637,27 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *)val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *val;
+		rtlefuse->efuse_usedpercentage = *((u8 *)val);
 		break;
 	case HW_VAR_IO_CMD:
 		rtl8723be_phy_set_io_cmd(hw, (*(enum io_type *)val));
 		break;
-	case HW_VAR_SET_RPWM: {
+	case HW_VAR_SET_RPWM:{
 		u8 rpwm_val;
 
 		rpwm_val = rtl_read_byte(rtlpriv, REG_PCIE_HRPWM);
 		udelay(1);
 
 		if (rpwm_val & BIT(7)) {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val);
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, (*(u8 *)val));
 		} else {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val | BIT(7));
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
+				       ((*(u8 *)val) | BIT(7)));
 		}
-		break; }
+		}
+		break;
 	case HW_VAR_H2C_FW_PWRMODE:
-		rtl8723be_set_fw_pwrmode_cmd(hw, *val);
+		rtl8723be_set_fw_pwrmode_cmd(hw, (*(u8 *)val));
 		break;
 	case HW_VAR_FW_PSMODE_STATUS:
 		ppsc->fw_current_inpsmode = *((bool *)val);
@@ -590,85 +665,38 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_RESUME_CLK_ON:
 		_rtl8723be_set_fw_ps_rf_on(hw);
 		break;
-	case HW_VAR_FW_LPS_ACTION: {
-		bool enter_fwlps = *((bool *)val);
+	case HW_VAR_FW_LPS_ACTION:{
+		bool b_enter_fwlps = *((bool *)val);
 
-		if (enter_fwlps)
+		if (b_enter_fwlps)
 			_rtl8723be_fwlps_enter(hw);
 		else
 			_rtl8723be_fwlps_leave(hw);
-
-		break; }
-	case HW_VAR_H2C_FW_JOINBSSRPT: {
-		u8 mstatus = *val;
-		u8 tmp_regcr, tmp_reg422, bcnvalid_reg;
-		u8 count = 0, dlbcn_count = 0;
-		bool recover = false;
+		}
+		break;
+	case HW_VAR_H2C_FW_JOINBSSRPT:{
+		u8 mstatus = (*(u8 *)val);
 
 		if (mstatus == RT_MEDIA_CONNECT) {
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID, NULL);
-
-			tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
-			rtl_write_byte(rtlpriv, REG_CR + 1,
-				       (tmp_regcr | BIT(0)));
-
-			_rtl8723be_set_bcn_ctrl_reg(hw, 0, BIT(3));
-			_rtl8723be_set_bcn_ctrl_reg(hw, BIT(4), 0);
-
-			tmp_reg422 = rtl_read_byte(rtlpriv,
-						   REG_FWHW_TXQ_CTRL + 2);
-			rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
-				       tmp_reg422 & (~BIT(6)));
-			if (tmp_reg422 & BIT(6))
-				recover = true;
-
-			do {
-				bcnvalid_reg = rtl_read_byte(rtlpriv,
-							     REG_TDECTRL + 2);
-				rtl_write_byte(rtlpriv, REG_TDECTRL + 2,
-					       (bcnvalid_reg | BIT(0)));
-				_rtl8723be_return_beacon_queue_skb(hw);
-
-				rtl8723be_set_fw_rsvdpagepkt(hw, 0);
-				bcnvalid_reg = rtl_read_byte(rtlpriv,
-							     REG_TDECTRL + 2);
-				count = 0;
-				while (!(bcnvalid_reg & BIT(0)) && count < 20) {
-					count++;
-					udelay(10);
-					bcnvalid_reg = rtl_read_byte(rtlpriv,
-							       REG_TDECTRL + 2);
-				}
-				dlbcn_count++;
-			} while (!(bcnvalid_reg & BIT(0)) && dlbcn_count < 5);
-
-			if (bcnvalid_reg & BIT(0))
-				rtl_write_byte(rtlpriv, REG_TDECTRL+2, BIT(0));
-
-			_rtl8723be_set_bcn_ctrl_reg(hw, BIT(3), 0);
-			_rtl8723be_set_bcn_ctrl_reg(hw, 0, BIT(4));
-
-			if (recover) {
-				rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
-					       tmp_reg422);
-			}
-			rtl_write_byte(rtlpriv, REG_CR + 1,
-				       (tmp_regcr & ~(BIT(0))));
+			_rtl8723be_download_rsvd_page(hw);
+		}
+		rtl8723be_set_fw_media_status_rpt_cmd(hw, mstatus);
 		}
-		rtl8723be_set_fw_joinbss_report_cmd(hw, *val);
-		break; }
+		break;
 	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
-		rtl8723be_set_p2p_ps_offload_cmd(hw, *val);
+		rtl8723be_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
 		break;
-	case HW_VAR_AID: {
+	case HW_VAR_AID:{
 		u16 u2btmp;
 		u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
 		u2btmp &= 0xC000;
 		rtl_write_word(rtlpriv, REG_BCN_PSR_RPT,
 			       (u2btmp | mac->assoc_id));
-		break; }
-	case HW_VAR_CORRECT_TSF: {
-		u8 btype_ibss = *val;
+		}
+		break;
+	case HW_VAR_CORRECT_TSF:{
+		u8 btype_ibss = ((u8 *)(val))[0];
 
 		if (btype_ibss)
 			_rtl8723be_stop_tx_beacon(hw);
@@ -684,16 +712,17 @@ void rtl8723be_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		if (btype_ibss)
 			_rtl8723be_resume_tx_beacon(hw);
-		break; }
-	case HW_VAR_KEEP_ALIVE: {
+		}
+		break;
+	case HW_VAR_KEEP_ALIVE:{
 		u8 array[2];
 		array[0] = 0xff;
-		array[1] = *val;
-		rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_KEEP_ALIVE_CTRL,
-				       2, array);
-		break; }
+		array[1] = *((u8 *)val);
+		rtl8723be_fill_h2c_cmd(hw, H2C_8723B_KEEP_ALIVE_CTRL, 2, array);
+		}
+		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "switch case not process %x\n",
 			 variable);
 		break;
@@ -704,7 +733,7 @@ static bool _rtl8723be_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	bool status = true;
-	int count = 0;
+	long count = 0;
 	u32 value = _LLT_INIT_ADDR(address) | _LLT_INIT_DATA(data) |
 		    _LLT_OP(_LLT_WRITE_ACCESS);
 
@@ -717,8 +746,8 @@ static bool _rtl8723be_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 
 		if (count > POLLING_LLT_THRESHOLD) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "Failed to polling write LLT done at "
-				  "address %d!\n", address);
+				 "Failed to polling write LLT done at address %d!\n",
+				 address);
 			status = false;
 			break;
 		}
@@ -732,10 +761,10 @@ static bool _rtl8723be_llt_table_init(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	unsigned short i;
 	u8 txpktbuf_bndy;
-	u8 maxpage;
+	u8 maxPage;
 	bool status;
 
-	maxpage = 255;
+	maxPage = 255;
 	txpktbuf_bndy = 245;
 
 	rtl_write_dword(rtlpriv, REG_TRXFF_BNDY,
@@ -754,17 +783,19 @@ static bool _rtl8723be_llt_table_init(struct ieee80211_hw *hw)
 		if (!status)
 			return status;
 	}
+
 	status = _rtl8723be_llt_write(hw, (txpktbuf_bndy - 1), 0xFF);
 
 	if (!status)
 		return status;
 
-	for (i = txpktbuf_bndy; i < maxpage; i++) {
+	for (i = txpktbuf_bndy; i < maxPage; i++) {
 		status = _rtl8723be_llt_write(hw, i, (i + 1));
 		if (!status)
 			return status;
 	}
-	status = _rtl8723be_llt_write(hw, maxpage, txpktbuf_bndy);
+
+	status = _rtl8723be_llt_write(hw, maxPage, txpktbuf_bndy);
 	if (!status)
 		return status;
 
@@ -796,11 +827,9 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	unsigned char bytetmp;
 	unsigned short wordtmp;
-	u16 retry = 0;
-	bool mac_func_enable;
 
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x00);
 
@@ -808,12 +837,6 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 	bytetmp = rtl_read_byte(rtlpriv, REG_APS_FSMCO + 1) & (~BIT(7));
 	rtl_write_byte(rtlpriv, REG_APS_FSMCO + 1, bytetmp);
 
-	bytetmp = rtl_read_byte(rtlpriv, REG_CR);
-	if (bytetmp == 0xFF)
-		mac_func_enable = true;
-	else
-		mac_func_enable = false;
-
 	/* HW Power on sequence */
 	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
 				      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
@@ -822,6 +845,10 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 			 "init MAC Fail as power on failure\n");
 		return false;
 	}
+
+	bytetmp = rtl_read_byte(rtlpriv, REG_MULTI_FUNC_CTRL);
+	rtl_write_byte(rtlpriv, REG_MULTI_FUNC_CTRL, bytetmp | BIT(3));
+
 	bytetmp = rtl_read_byte(rtlpriv, REG_APS_FSMCO) | BIT(4);
 	rtl_write_byte(rtlpriv, REG_APS_FSMCO, bytetmp);
 
@@ -838,25 +865,21 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 	bytetmp = rtl_read_byte(rtlpriv, REG_SYS_CFG + 3);
 	if (bytetmp & BIT(0)) {
 		bytetmp = rtl_read_byte(rtlpriv, 0x7c);
-		bytetmp |= BIT(6);
-		rtl_write_byte(rtlpriv, 0x7c, bytetmp);
+		rtl_write_byte(rtlpriv, 0x7c, bytetmp | BIT(6));
 	}
+
 	bytetmp = rtl_read_byte(rtlpriv, REG_SYS_CLKR);
-	bytetmp |= BIT(3);
-	rtl_write_byte(rtlpriv, REG_SYS_CLKR, bytetmp);
+	rtl_write_byte(rtlpriv, REG_SYS_CLKR, bytetmp | BIT(3));
 	bytetmp = rtl_read_byte(rtlpriv, REG_GPIO_MUXCFG + 1);
-	bytetmp &= ~BIT(4);
-	rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG + 1, bytetmp);
-
-	bytetmp = rtl_read_byte(rtlpriv, REG_PCIE_CTRL_REG+3);
-	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG+3, bytetmp | 0x77);
+	rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG + 1, bytetmp & (~BIT(4)));
 
 	rtl_write_word(rtlpriv, REG_CR, 0x2ff);
 
-	if (!mac_func_enable) {
-		if (!_rtl8723be_llt_table_init(hw))
+	if (!rtlhal->mac_func_enable) {
+		if (_rtl8723be_llt_table_init(hw) == false)
 			return false;
 	}
+
 	rtl_write_dword(rtlpriv, REG_HISR, 0xffffffff);
 	rtl_write_dword(rtlpriv, REG_HISRE, 0xffffffff);
 
@@ -874,8 +897,6 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 	rtl_write_word(rtlpriv, REG_RXFLTMAP2, 0xFFFF);
 	rtl_write_dword(rtlpriv, REG_TCR, rtlpci->transmit_config);
 
-	rtl_write_byte(rtlpriv, 0x4d0, 0x0);
-
 	rtl_write_dword(rtlpriv, REG_BCNQ_DESA,
 			((u64) rtlpci->tx_ring[BEACON_QUEUE].dma) &
 			DMA_BIT_MASK(32));
@@ -902,57 +923,213 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 
 	rtl_write_dword(rtlpriv, REG_INT_MIG, 0);
 
-	bytetmp = rtl_read_byte(rtlpriv, REG_APSD_CTRL);
-	rtl_write_byte(rtlpriv, REG_APSD_CTRL, bytetmp & ~BIT(6));
+	rtl_write_dword(rtlpriv, REG_MCUTST_1, 0x0);
 
 	rtl_write_byte(rtlpriv, REG_SECONDARY_CCA_CTRL, 0x3);
 
-	do {
-		retry++;
-		bytetmp = rtl_read_byte(rtlpriv, REG_APSD_CTRL);
-	} while ((retry < 200) && (bytetmp & BIT(7)));
-
-	_rtl8723be_gen_refresh_led_state(hw);
-
-	rtl_write_dword(rtlpriv, REG_MCUTST_1, 0x0);
+	/* <20130114, Kordan> The following setting is
+	 * only for DPDT and Fixed board type.
+	 * TODO:  A better solution is configure it
+	 * according EFUSE during the run-time.
+	 */
+	rtl_set_bbreg(hw, 0x64, BIT(20), 0x0);/* 0x66[4]=0 */
+	rtl_set_bbreg(hw, 0x64, BIT(24), 0x0);/* 0x66[8]=0 */
+	rtl_set_bbreg(hw, 0x40, BIT(4), 0x0)/* 0x40[4]=0 */;
+	rtl_set_bbreg(hw, 0x40, BIT(3), 0x1)/* 0x40[3]=1 */;
+	rtl_set_bbreg(hw, 0x4C, BIT(24) | BIT(23), 0x2)/* 0x4C[24:23]=10 */;
+	rtl_set_bbreg(hw, 0x944, BIT(1) | BIT(0), 0x3)/* 0x944[1:0]=11 */;
+	rtl_set_bbreg(hw, 0x930, MASKBYTE0, 0x77)/* 0x930[7:0]=77 */;
+	rtl_set_bbreg(hw, 0x38, BIT(11), 0x1)/* 0x38[11]=1 */;
 
 	bytetmp = rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
-	rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, bytetmp & ~BIT(2));
+	rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, bytetmp & (~BIT(2)));
 
+	_rtl8723be_gen_refresh_led_state(hw);
 	return true;
 }
 
 static void _rtl8723be_hw_configure(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 reg_bw_opmode;
-	u32 reg_ratr, reg_prsr;
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rrsr;
+
+	reg_rrsr = RATE_ALL_CCK | RATE_ALL_OFDM_AG;
+	/* Init value for RRSR. */
+	rtl_write_dword(rtlpriv, REG_RRSR, reg_rrsr);
+
+	/* ARFB table 9 for 11ac 5G 2SS */
+	rtl_write_dword(rtlpriv, REG_ARFR0 + 4, 0xfffff000);
+
+	/* ARFB table 10 for 11ac 5G 1SS */
+	rtl_write_dword(rtlpriv, REG_ARFR1 + 4, 0x003ff000);
+
+	/* CF-End setting. */
+	rtl_write_word(rtlpriv, REG_FWHW_TXQ_CTRL, 0x1F00);
+
+	/* 0x456 = 0x70, sugguested by Zhilin */
+	rtl_write_byte(rtlpriv, REG_AMPDU_MAX_TIME, 0x70);
+
+	/* Set retry limit */
+	rtl_write_word(rtlpriv, REG_RL, 0x0707);
+
+	/* Set Data / Response auto rate fallack retry count */
+	rtl_write_dword(rtlpriv, REG_DARFRC, 0x01000000);
+	rtl_write_dword(rtlpriv, REG_DARFRC + 4, 0x07060504);
+	rtl_write_dword(rtlpriv, REG_RARFRC, 0x01000000);
+	rtl_write_dword(rtlpriv, REG_RARFRC + 4, 0x07060504);
+
+	rtlpci->reg_bcn_ctrl_val = 0x1d;
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, rtlpci->reg_bcn_ctrl_val);
+
+	/* TBTT prohibit hold time. Suggested by designer TimChen. */
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1, 0xff); /* 8 ms */
+
+	rtl_write_word(rtlpriv, REG_NAV_PROT_LEN, 0x0040);
+
+	/*For Rx TP. Suggested by SD1 Richard. Added by tynli. 2010.04.12.*/
+	rtl_write_dword(rtlpriv, REG_FAST_EDCA_CTRL, 0x03086666);
 
-	reg_bw_opmode = BW_OPMODE_20MHZ;
-	reg_ratr = RATE_ALL_CCK | RATE_ALL_OFDM_AG |
-		   RATE_ALL_OFDM_1SS | RATE_ALL_OFDM_2SS;
-	reg_prsr = RATE_ALL_CCK | RATE_ALL_OFDM_AG;
+	rtl_write_byte(rtlpriv, REG_HT_SINGLE_AMPDU, 0x80);
 
-	rtl_write_dword(rtlpriv, REG_RRSR, reg_prsr);
-	rtl_write_byte(rtlpriv, REG_HWSEQ_CTRL, 0xFF);
+	rtl_write_byte(rtlpriv, REG_RX_PKT_LIMIT, 0x20);
+
+	rtl_write_byte(rtlpriv, REG_MAX_AGGR_NUM, 0x1F);
+}
+
+static u8 _rtl8723be_dbi_read(struct rtl_priv *rtlpriv, u16 addr)
+{
+	u16 read_addr = addr & 0xfffc;
+	u8 ret = 0, tmp = 0, count = 0;
+
+	rtl_write_word(rtlpriv, REG_DBI_ADDR, read_addr);
+	rtl_write_byte(rtlpriv, REG_DBI_FLAG, 0x2);
+	tmp = rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+	count = 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp = rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+		count++;
+	}
+	if (0 == tmp) {
+		read_addr = REG_DBI_RDATA + addr % 4;
+		ret = rtl_read_byte(rtlpriv, read_addr);
+	}
+
+	return ret;
+}
+
+static void _rtl8723be_dbi_write(struct rtl_priv *rtlpriv, u16 addr, u8 data)
+{
+	u8 tmp = 0, count = 0;
+	u16 write_addr = 0, remainder = addr % 4;
+
+	/* Write DBI 1Byte Data */
+	write_addr = REG_DBI_WDATA + remainder;
+	rtl_write_byte(rtlpriv, write_addr, data);
+
+	/* Write DBI 2Byte Address & Write Enable */
+	write_addr = (addr & 0xfffc) | (BIT(0) << (remainder + 12));
+	rtl_write_word(rtlpriv, REG_DBI_ADDR, write_addr);
+
+	/* Write DBI Write Flag */
+	rtl_write_byte(rtlpriv, REG_DBI_FLAG, 0x1);
+
+	tmp = rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+	count = 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp = rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+		count++;
+	}
+}
+
+static u16 _rtl8723be_mdio_read(struct rtl_priv *rtlpriv, u8 addr)
+{
+	u16 ret = 0;
+	u8 tmp = 0, count = 0;
+
+	rtl_write_byte(rtlpriv, REG_MDIO_CTL, addr | BIT(6));
+	tmp = rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(6);
+	count = 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp = rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(6);
+		count++;
+	}
+
+	if (0 == tmp)
+		ret = rtl_read_word(rtlpriv, REG_MDIO_RDATA);
+
+	return ret;
+}
+
+static void _rtl8723be_mdio_write(struct rtl_priv *rtlpriv, u8 addr, u16 data)
+{
+	u8 tmp = 0, count = 0;
+
+	rtl_write_word(rtlpriv, REG_MDIO_WDATA, data);
+	rtl_write_byte(rtlpriv, REG_MDIO_CTL, addr | BIT(5));
+	tmp = rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(5);
+	count = 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp = rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(5);
+		count++;
+	}
 }
 
 static void _rtl8723be_enable_aspm_back_door(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	u8 tmp8 = 0;
+	u16 tmp16 = 0;
 
-	rtl_write_byte(rtlpriv, 0x34b, 0x93);
-	rtl_write_word(rtlpriv, 0x350, 0x870c);
-	rtl_write_byte(rtlpriv, 0x352, 0x1);
+	/* <Roger_Notes> Overwrite following ePHY parameter for
+	 * some platform compatibility issue,
+	 * especially when CLKReq is enabled, 2012.11.09.
+	 */
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x01);
+	if (tmp16 != 0x0663)
+		_rtl8723be_mdio_write(rtlpriv, 0x01, 0x0663);
 
-	if (ppsc->support_backdoor)
-		rtl_write_byte(rtlpriv, 0x349, 0x1b);
-	else
-		rtl_write_byte(rtlpriv, 0x349, 0x03);
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x04);
+	if (tmp16 != 0x7544)
+		_rtl8723be_mdio_write(rtlpriv, 0x04, 0x7544);
+
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x06);
+	if (tmp16 != 0xB880)
+		_rtl8723be_mdio_write(rtlpriv, 0x06, 0xB880);
+
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x07);
+	if (tmp16 != 0x4000)
+		_rtl8723be_mdio_write(rtlpriv, 0x07, 0x4000);
+
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x08);
+	if (tmp16 != 0x9003)
+		_rtl8723be_mdio_write(rtlpriv, 0x08, 0x9003);
+
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x09);
+	if (tmp16 != 0x0D03)
+		_rtl8723be_mdio_write(rtlpriv, 0x09, 0x0D03);
+
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x0A);
+	if (tmp16 != 0x4037)
+		_rtl8723be_mdio_write(rtlpriv, 0x0A, 0x4037);
 
-	rtl_write_word(rtlpriv, 0x350, 0x2718);
-	rtl_write_byte(rtlpriv, 0x352, 0x1);
+	tmp16 = _rtl8723be_mdio_read(rtlpriv, 0x0B);
+	if (tmp16 != 0x0070)
+		_rtl8723be_mdio_write(rtlpriv, 0x0B, 0x0070);
+
+	/* Configuration Space offset 0x70f BIT7 is used to control L0S */
+	tmp8 = _rtl8723be_dbi_read(rtlpriv, 0x70f);
+	_rtl8723be_dbi_write(rtlpriv, 0x70f, tmp8 | BIT(7));
+
+	/* Configuration Space offset 0x719 Bit3 is for L1
+	 * BIT4 is for clock request
+	 */
+	tmp8 = _rtl8723be_dbi_read(rtlpriv, 0x719);
+	_rtl8723be_dbi_write(rtlpriv, 0x719, tmp8 | BIT(3) | BIT(4));
 }
 
 void rtl8723be_enable_hw_security_config(struct ieee80211_hw *hw)
@@ -962,30 +1139,208 @@ void rtl8723be_enable_hw_security_config(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		 "PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
-		 rtlpriv->sec.pairwise_enc_algorithm,
-		 rtlpriv->sec.group_enc_algorithm);
+		  rtlpriv->sec.pairwise_enc_algorithm,
+		  rtlpriv->sec.group_enc_algorithm);
 
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 			 "not open hw encryption\n");
 		return;
 	}
+
 	sec_reg_value = SCR_TXENCENABLE | SCR_RXDECENABLE;
 
 	if (rtlpriv->sec.use_defaultkey) {
 		sec_reg_value |= SCR_TXUSEDK;
 		sec_reg_value |= SCR_RXUSEDK;
 	}
+
 	sec_reg_value |= (SCR_RXBCUSEDK | SCR_TXBCUSEDK);
 
 	rtl_write_byte(rtlpriv, REG_CR + 1, 0x02);
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "The SECR-value %x\n",
-		 sec_reg_value);
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+		 "The SECR-value %x\n", sec_reg_value);
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 }
 
+static void _rtl8723be_poweroff_adapter(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u8 u1b_tmp;
+
+	rtlhal->mac_func_enable = false;
+	/* Combo (PCIe + USB) Card and PCIe-MF Card */
+	/* 1. Run LPS WL RFOFF flow */
+	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, RTL8723_NIC_LPS_ENTER_FLOW);
+
+	/* 2. 0x1F[7:0] = 0 */
+	/* turn off RF */
+	/* rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00); */
+	if ((rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) &&
+	    rtlhal->fw_ready) {
+		rtl8723be_firmware_selfreset(hw);
+	}
+
+	/* Reset MCU. Suggested by Filen. */
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp & (~BIT(2))));
+
+	/* g.	MCUFWDL 0x80[1:0]=0	 */
+	/* reset MCU ready status */
+	rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
+
+	/* HW card disable configuration. */
+	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, RTL8723_NIC_DISABLE_FLOW);
+
+	/* Reset MCU IO Wrapper */
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, u1b_tmp | BIT(0));
+
+	/* 7. RSV_CTRL 0x1C[7:0] = 0x0E */
+	/* lock ISO/CLK/Power control register */
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x0e);
+}
+
+static bool _rtl8723be_check_pcie_dma_hang(struct rtl_priv *rtlpriv)
+{
+	u8 tmp;
+
+	/* write reg 0x350 Bit[26]=1. Enable debug port. */
+	tmp = rtl_read_byte(rtlpriv, REG_DBI_CTRL + 3);
+	if (!(tmp & BIT(2))) {
+		rtl_write_byte(rtlpriv, REG_DBI_CTRL + 3, (tmp | BIT(2)));
+		mdelay(100); /* Suggested by DD Justin_tsai. */
+	}
+
+	/* read reg 0x350 Bit[25] if 1 : RX hang
+	 * read reg 0x350 Bit[24] if 1 : TX hang
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_DBI_CTRL + 3);
+	if ((tmp & BIT(0)) || (tmp & BIT(1))) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "CheckPcieDMAHang8723BE(): true!!\n");
+		return true;
+	}
+	return false;
+}
+
+static void _rtl8723be_reset_pcie_interface_dma(struct rtl_priv *rtlpriv,
+						bool mac_power_on)
+{
+	u8 tmp;
+	bool release_mac_rx_pause;
+	u8 backup_pcie_dma_pause;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "ResetPcieInterfaceDMA8723BE()\n");
+
+	/* Revise Note: Follow the document "PCIe RX DMA Hang Reset Flow_v03"
+	 * released by SD1 Alan.
+	 * 2013.05.07, by tynli.
+	 */
+
+	/* 1. disable register write lock
+	 *	write 0x1C bit[1:0] = 2'h0
+	 *	write 0xCC bit[2] = 1'b1
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL);
+	tmp &= ~(BIT(1) | BIT(0));
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, tmp);
+	tmp = rtl_read_byte(rtlpriv, REG_PMC_DBG_CTRL2);
+	tmp |= BIT(2);
+	rtl_write_byte(rtlpriv, REG_PMC_DBG_CTRL2, tmp);
+
+	/* 2. Check and pause TRX DMA
+	 *	write 0x284 bit[18] = 1'b1
+	 *	write 0x301 = 0xFF
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	if (tmp & BIT(2)) {
+		/* Already pause before the function for another purpose. */
+		release_mac_rx_pause = false;
+	} else {
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, (tmp | BIT(2)));
+		release_mac_rx_pause = true;
+	}
+
+	backup_pcie_dma_pause = rtl_read_byte(rtlpriv, REG_PCIE_CTRL_REG + 1);
+	if (backup_pcie_dma_pause != 0xFF)
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xFF);
+
+	if (mac_power_on) {
+		/* 3. reset TRX function
+		 *	write 0x100 = 0x00
+		 */
+		rtl_write_byte(rtlpriv, REG_CR, 0);
+	}
+
+	/* 4. Reset PCIe DMA
+	 *	write 0x003 bit[0] = 0
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	tmp &= ~(BIT(0));
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp);
+
+	/* 5. Enable PCIe DMA
+	 *	write 0x003 bit[0] = 1
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	tmp |= BIT(0);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp);
+
+	if (mac_power_on) {
+		/* 6. enable TRX function
+		 *	write 0x100 = 0xFF
+		 */
+		rtl_write_byte(rtlpriv, REG_CR, 0xFF);
+
+		/* We should init LLT & RQPN and
+		 * prepare Tx/Rx descrptor address later
+		 * because MAC function is reset.
+		 */
+	}
+
+	/* 7. Restore PCIe autoload down bit
+	 *	write 0xF8 bit[17] = 1'b1
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_MAC_PHY_CTRL_NORMAL + 2);
+	tmp |= BIT(1);
+	rtl_write_byte(rtlpriv, REG_MAC_PHY_CTRL_NORMAL + 2, tmp);
+
+	/* In MAC power on state, BB and RF maybe in ON state,
+	 * if we release TRx DMA here
+	 * it will cause packets to be started to Tx/Rx,
+	 * so we release Tx/Rx DMA later.
+	 */
+	if (!mac_power_on) {
+		/* 8. release TRX DMA
+		 *	write 0x284 bit[18] = 1'b0
+		 *	write 0x301 = 0x00
+		 */
+		if (release_mac_rx_pause) {
+			tmp = rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+			rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL,
+				       (tmp & (~BIT(2))));
+		}
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1,
+			       backup_pcie_dma_pause);
+	}
+
+	/* 9. lock system register
+	 *	write 0xCC bit[2] = 1'b0
+	 */
+	tmp = rtl_read_byte(rtlpriv, REG_PMC_DBG_CTRL2);
+	tmp &= ~(BIT(2));
+	rtl_write_byte(rtlpriv, REG_PMC_DBG_CTRL2, tmp);
+}
+
 int rtl8723be_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1003,33 +1358,51 @@ int rtl8723be_hw_init(struct ieee80211_hw *hw)
 	local_save_flags(flags);
 	local_irq_enable();
 
+	rtlhal->fw_ready = false;
 	rtlpriv->rtlhal.being_init_adapter = true;
 	rtlpriv->intf_ops->disable_aspm(hw);
+
+	tmp_u1b = rtl_read_byte(rtlpriv, REG_CR);
+	if (tmp_u1b != 0 && tmp_u1b != 0xea) {
+		rtlhal->mac_func_enable = true;
+	} else {
+		rtlhal->mac_func_enable = false;
+		rtlhal->fw_ps_state = FW_PS_STATE_ALL_ON;
+	}
+
+	if (_rtl8723be_check_pcie_dma_hang(rtlpriv)) {
+		_rtl8723be_reset_pcie_interface_dma(rtlpriv,
+						    rtlhal->mac_func_enable);
+		rtlhal->mac_func_enable = false;
+	}
+	if (rtlhal->mac_func_enable) {
+		_rtl8723be_poweroff_adapter(hw);
+		rtlhal->mac_func_enable = false;
+	}
 	rtstatus = _rtl8723be_init_mac(hw);
 	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err = 1;
 		goto exit;
 	}
+
 	tmp_u1b = rtl_read_byte(rtlpriv, REG_SYS_CFG);
-	tmp_u1b &= 0x7F;
-	rtl_write_byte(rtlpriv, REG_SYS_CFG, tmp_u1b);
+	rtl_write_byte(rtlpriv, REG_SYS_CFG, tmp_u1b & 0x7F);
 
-	err = rtl8723_download_fw(hw, true, FW_8192C_POLLING_TIMEOUT_COUNT);
+	err = rtl8723_download_fw(hw, true, FW_8723B_POLLING_TIMEOUT_COUNT);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Failed to download FW. Init HW without FW now..\n");
 		err = 1;
-		rtlhal->fw_ready = false;
 		goto exit;
-	} else {
-		rtlhal->fw_ready = true;
 	}
+	rtlhal->fw_ready = true;
+
 	rtlhal->last_hmeboxnum = 0;
 	rtl8723be_phy_mac_config(hw);
 	/* because last function modify RCR, so we update
 	 * rcr var here, or TP will unstable for receive_config
-	 * is wrong, RX RCR_ACRC32 will cause TP unstabel & Rx
+	 * is wrong, RX RCR_ACRC32 will cause TP unstable & Rx
 	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252
 	 */
 	rtlpci->receive_config = rtl_read_dword(rtlpriv, REG_RCR);
@@ -1037,7 +1410,6 @@ int rtl8723be_hw_init(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
 
 	rtl8723be_phy_bb_config(hw);
-	rtlphy->rf_mode = RF_OP_BY_SW_3WIRE;
 	rtl8723be_phy_rf_config(hw);
 
 	rtlphy->rfreg_chnlval[0] = rtl_get_rfreg(hw, (enum radio_path)0,
@@ -1047,10 +1419,8 @@ int rtl8723be_hw_init(struct ieee80211_hw *hw)
 	rtlphy->rfreg_chnlval[0] &= 0xFFF03FF;
 	rtlphy->rfreg_chnlval[0] |= (BIT(10) | BIT(11));
 
-	rtl_set_bbreg(hw, RFPGA0_RFMOD, BCCKEN, 0x1);
-	rtl_set_bbreg(hw, RFPGA0_RFMOD, BOFDMEN, 0x1);
-	rtl_set_bbreg(hw, RFPGA0_ANALOGPARAMETER2, BIT(10), 1);
 	_rtl8723be_hw_configure(hw);
+	rtlhal->mac_func_enable = true;
 	rtl_cam_reset_all_entry(hw);
 	rtl8723be_enable_hw_security_config(hw);
 
@@ -1062,36 +1432,32 @@ int rtl8723be_hw_init(struct ieee80211_hw *hw)
 
 	rtl8723be_bt_hw_init(hw);
 
-	rtl_set_bbreg(hw, 0x64, BIT(20), 0);
-	rtl_set_bbreg(hw, 0x64, BIT(24), 0);
-
-	rtl_set_bbreg(hw, 0x40, BIT(4), 0);
-	rtl_set_bbreg(hw, 0x40, BIT(3), 1);
-
-	rtl_set_bbreg(hw, 0x944, BIT(0)|BIT(1), 0x3);
-	rtl_set_bbreg(hw, 0x930, 0xff, 0x77);
-
-	rtl_set_bbreg(hw, 0x38, BIT(11), 0x1);
-
-	rtl_set_bbreg(hw, 0xb2c, 0xffffffff, 0x80000000);
-
 	if (ppsc->rfpwr_state == ERFON) {
+		rtl8723be_phy_set_rfpath_switch(hw, 1);
+		/* when use 1ant NIC, iqk will disturb BT music
+		 * root cause is not clear now, is something
+		 * related with 'mdelay' and Reg[0x948]
+		 */
+		if (rtlpriv->btcoexist.btc_info.ant_num == ANT_X2 ||
+		    !rtlpriv->cfg->ops->get_btc_status()) {
+			rtl8723be_phy_iq_calibrate(hw, false);
+			rtlphy->iqk_initialized = true;
+		}
 		rtl8723be_dm_check_txpower_tracking(hw);
 		rtl8723be_phy_lc_calibrate(hw);
 	}
-	tmp_u1b = efuse_read_1byte(hw, 0x1FA);
-	if (!(tmp_u1b & BIT(0))) {
-		rtl_set_rfreg(hw, RF90_PATH_A, 0x15, 0x0F, 0x05);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "PA BIAS path A\n");
-	}
-	if (!(tmp_u1b & BIT(4))) {
-		tmp_u1b = rtl_read_byte(rtlpriv, 0x16);
-		tmp_u1b &= 0x0F;
-		rtl_write_byte(rtlpriv, 0x16, tmp_u1b | 0x80);
-		udelay(10);
-		rtl_write_byte(rtlpriv, 0x16, tmp_u1b | 0x90);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "under 1.5V\n");
+	rtl_write_byte(rtlpriv, REG_NAV_UPPER, ((30000 + 127) / 128));
+
+	/* Release Rx DMA. */
+	tmp_u1b = rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	if (tmp_u1b & BIT(2)) {
+		/* Release Rx DMA if needed */
+		tmp_u1b &= (~BIT(2));
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, tmp_u1b);
 	}
+	/* Release Tx/Rx PCIE DMA. */
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0);
+
 	rtl8723be_dm_init(hw);
 exit:
 	local_irq_restore(flags);
@@ -1104,43 +1470,29 @@ static enum version_8723e _rtl8723be_read_chip_version(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	enum version_8723e version = VERSION_UNKNOWN;
-	u8 count = 0;
-	u8 value8;
 	u32 value32;
 
-	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0);
-
-	value8 = rtl_read_byte(rtlpriv, REG_APS_FSMCO + 2);
-	rtl_write_byte(rtlpriv, REG_APS_FSMCO + 2, value8 | BIT(0));
-
-	value8 = rtl_read_byte(rtlpriv, REG_APS_FSMCO + 1);
-	rtl_write_byte(rtlpriv, REG_APS_FSMCO + 1, value8 | BIT(0));
-
-	value8 = rtl_read_byte(rtlpriv, REG_APS_FSMCO + 1);
-	while (((value8 & BIT(0))) && (count++ < 100)) {
-		udelay(10);
-		value8 = rtl_read_byte(rtlpriv, REG_APS_FSMCO + 1);
-	}
-	count = 0;
-	value8 = rtl_read_byte(rtlpriv, REG_ROM_VERSION);
-	while ((value8 == 0) && (count++ < 50)) {
-		value8 = rtl_read_byte(rtlpriv, REG_ROM_VERSION);
-		mdelay(1);
-	}
 	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG1);
 	if ((value32 & (CHIP_8723B)) != CHIP_8723B)
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "unkown chip version\n");
 	else
-		version = (enum version_8723e) VERSION_TEST_CHIP_1T1R_8723B;
+		version = (enum version_8723e)CHIP_8723B;
 
-		rtlphy->rf_type = RF_1T1R;
+	rtlphy->rf_type = RF_1T1R;
+
+	/* treat rtl8723be chip as  MP version in default */
+	version = (enum version_8723e)(version | NORMAL_CHIP);
+
+	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG);
+	/* cut version */
+	version |= (enum version_8723e)(value32 & CHIP_VER_RTL_MASK);
+	/* Manufacture */
+	if (((value32 & EXT_VENDOR_ID) >> 18) == 0x01)
+		version = (enum version_8723e)(version | CHIP_VENDOR_SMIC);
 
-	value8 = rtl_read_byte(rtlpriv, REG_ROM_VERSION);
-	if (value8 >= 0x02)
-		version |= BIT(3);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "Chip RF Type: %s\n", (rtlphy->rf_type == RF_2T2R) ?
-		 "RF_2T2R" : "RF_1T1R");
+		  "RF_2T2R" : "RF_1T1R");
 
 	return version;
 }
@@ -1151,43 +1503,29 @@ static int _rtl8723be_set_media_status(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 bt_msr = rtl_read_byte(rtlpriv, MSR) & 0xfc;
 	enum led_ctl_mode ledaction = LED_CTL_NO_LINK;
+	u8 mode = MSR_NOLINK;
 
-	rtl_write_dword(rtlpriv, REG_BCN_CTRL, 0);
-	RT_TRACE(rtlpriv, COMP_BEACON, DBG_LOUD,
-		 "clear 0x550 when set HW_VAR_MEDIA_STATUS\n");
-
-	if (type == NL80211_IFTYPE_UNSPECIFIED ||
-	    type == NL80211_IFTYPE_STATION) {
-		_rtl8723be_stop_tx_beacon(hw);
-		_rtl8723be_enable_bcn_sub_func(hw);
-	} else if (type == NL80211_IFTYPE_ADHOC || type == NL80211_IFTYPE_AP) {
-		_rtl8723be_resume_tx_beacon(hw);
-		_rtl8723be_disable_bcn_sub_func(hw);
-	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "Set HW_VAR_MEDIA_STATUS: "
-			 "No such media status(%x).\n", type);
-	}
 	switch (type) {
 	case NL80211_IFTYPE_UNSPECIFIED:
-		bt_msr |= MSR_NOLINK;
-		ledaction = LED_CTL_LINK;
+		mode = MSR_NOLINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
-		bt_msr |= MSR_ADHOC;
+	case NL80211_IFTYPE_MESH_POINT:
+		mode = MSR_ADHOC;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
-		bt_msr |= MSR_INFRA;
+		mode = MSR_INFRA;
 		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
-		bt_msr |= MSR_AP;
+		mode = MSR_AP;
+		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Set Network type to AP!\n");
 		break;
@@ -1196,9 +1534,33 @@ static int _rtl8723be_set_media_status(struct ieee80211_hw *hw,
 			 "Network type %d not support!\n", type);
 		return 1;
 	}
-	rtl_write_byte(rtlpriv, (MSR), bt_msr);
+
+	/* MSR_INFRA == Link in infrastructure network;
+	 * MSR_ADHOC == Link in ad hoc network;
+	 * Therefore, check link state is necessary.
+	 *
+	 * MSR_AP == AP mode; link state is not cared here.
+	 */
+	if (mode != MSR_AP && rtlpriv->mac80211.link_state < MAC80211_LINKED) {
+		mode = MSR_NOLINK;
+		ledaction = LED_CTL_NO_LINK;
+	}
+
+	if (mode == MSR_NOLINK || mode == MSR_INFRA) {
+		_rtl8723be_stop_tx_beacon(hw);
+		_rtl8723be_enable_bcn_sub_func(hw);
+	} else if (mode == MSR_ADHOC || mode == MSR_AP) {
+		_rtl8723be_resume_tx_beacon(hw);
+		_rtl8723be_disable_bcn_sub_func(hw);
+	} else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x).\n",
+			 mode);
+	}
+
+	rtl_write_byte(rtlpriv, (MSR), bt_msr | mode);
 	rtlpriv->cfg->ops->led_control(hw, ledaction);
-	if ((bt_msr & MSR_MASK) == MSR_AP)
+	if (mode == MSR_AP)
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
 	else
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
@@ -1225,6 +1587,7 @@ void rtl8723be_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
 					      (u8 *)(&reg_rcr));
 	}
+
 }
 
 int rtl8723be_set_network_type(struct ieee80211_hw *hw,
@@ -1241,6 +1604,7 @@ int rtl8723be_set_network_type(struct ieee80211_hw *hw,
 	} else {
 		rtl8723be_set_check_bssid(hw, false);
 	}
+
 	return 0;
 }
 
@@ -1250,6 +1614,7 @@ int rtl8723be_set_network_type(struct ieee80211_hw *hw,
 void rtl8723be_set_qos(struct ieee80211_hw *hw, int aci)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
 	rtl8723_dm_init_edca_turbo(hw);
 	switch (aci) {
 	case AC1_BK:
@@ -1269,20 +1634,32 @@ void rtl8723be_set_qos(struct ieee80211_hw *hw, int aci)
 	}
 }
 
+static void rtl8723be_clear_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 tmp;
+
+	tmp = rtl_read_dword(rtlpriv, REG_HISR);
+	rtl_write_dword(rtlpriv, REG_HISR, tmp);
+
+	tmp = rtl_read_dword(rtlpriv, REG_HISRE);
+	rtl_write_dword(rtlpriv, REG_HISRE, tmp);
+
+	tmp = rtl_read_dword(rtlpriv, REG_HSISR);
+	rtl_write_dword(rtlpriv, REG_HSISR, tmp);
+}
+
 void rtl8723be_enable_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
+	rtl8723be_clear_interrupt(hw);/*clear it here first*/
+
 	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
 	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
 	rtlpci->irq_enabled = true;
-	/* there are some C2H CMDs have been sent
-	 * before system interrupt is enabled, e.g., C2H, CPWM.
-	 * So we need to clear all C2H events that FW has notified,
-	 * otherwise FW won't schedule any commands anymore.
-	 */
-	rtl_write_byte(rtlpriv, REG_C2HEVT_CLEAR, 0);
+
 	/*enable system interrupt*/
 	rtl_write_dword(rtlpriv, REG_HSIMR, rtlpci->sys_irq_mask & 0xFFFFFFFF);
 }
@@ -1295,48 +1672,7 @@ void rtl8723be_disable_interrupt(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, REG_HIMR, IMR_DISABLED);
 	rtl_write_dword(rtlpriv, REG_HIMRE, IMR_DISABLED);
 	rtlpci->irq_enabled = false;
-	synchronize_irq(rtlpci->pdev->irq);
-}
-
-static void _rtl8723be_poweroff_adapter(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 u1b_tmp;
-
-	/* Combo (PCIe + USB) Card and PCIe-MF Card */
-	/* 1. Run LPS WL RFOFF flow */
-	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK, RTL8723_NIC_LPS_ENTER_FLOW);
-
-	/* 2. 0x1F[7:0] = 0 */
-	/* turn off RF */
-	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00);
-	if ((rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) &&
-	    rtlhal->fw_ready)
-		rtl8723be_firmware_selfreset(hw);
-
-	/* Reset MCU. Suggested by Filen. */
-	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
-	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp & (~BIT(2))));
-
-	/* g.	MCUFWDL 0x80[1:0]= 0	 */
-	/* reset MCU ready status */
-	rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
-
-	/* HW card disable configuration. */
-	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK, RTL8723_NIC_DISABLE_FLOW);
-
-	/* Reset MCU IO Wrapper */
-	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
-	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
-	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
-	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, u1b_tmp | BIT(0));
-
-	/* 7. RSV_CTRL 0x1C[7:0] = 0x0E */
-	/* lock ISO/CLK/Power control register */
-	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x0e);
+	/*synchronize_irq(rtlpci->pdev->irq);*/
 }
 
 void rtl8723be_card_disable(struct ieee80211_hw *hw)
@@ -1443,10 +1779,9 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 	u32 path, addr = EEPROM_TX_PWR_INX, group, cnt = 0;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "hal_ReadPowerValueFromPROM8723BE(): "
-		 "PROMContent[0x%x]= 0x%x\n",
+		 "hal_ReadPowerValueFromPROM8723BE(): PROMContent[0x%x]=0x%x\n",
 		 (addr + 1), hwinfo[addr + 1]);
-	if (0xFF == hwinfo[addr + 1])  /*YJ, add, 120316*/
+	if (0xFF == hwinfo[addr + 1])  /*YJ,add,120316*/
 		autoload_fail = true;
 
 	if (autoload_fail) {
@@ -1454,7 +1789,7 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 			 "auto load fail : Use Default value!\n");
 		for (path = 0; path < MAX_RF_PATH; path++) {
 			/* 2.4G default value */
-			for (group = 0; group < MAX_CHNL_GROUP_24G; group++) {
+			for (group = 0 ; group < MAX_CHNL_GROUP_24G; group++) {
 				pw2g->index_cck_base[path][group] = 0x2D;
 				pw2g->index_bw40_base[path][group] = 0x2D;
 			}
@@ -1472,12 +1807,14 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 		}
 		return;
 	}
+
 	for (path = 0; path < MAX_RF_PATH; path++) {
 		/*2.4G default value*/
 		for (group = 0; group < MAX_CHNL_GROUP_24G; group++) {
 			pw2g->index_cck_base[path][group] = hwinfo[addr++];
 			if (pw2g->index_cck_base[path][group] == 0xFF)
 				pw2g->index_cck_base[path][group] = 0x2D;
+
 		}
 		for (group = 0; group < MAX_CHNL_GROUP_24G - 1; group++) {
 			pw2g->index_bw40_base[path][group] = hwinfo[addr++];
@@ -1494,8 +1831,10 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 						(hwinfo[addr] & 0xf0) >> 4;
 					/*bit sign number to 8 bit sign number*/
 					if (pw2g->bw20_diff[path][cnt] & BIT(3))
-						pw2g->bw20_diff[path][cnt] |= 0xF0;
+						pw2g->bw20_diff[path][cnt] |=
+									  0xF0;
 				}
+
 				if (hwinfo[addr] == 0xFF) {
 					pw2g->ofdm_diff[path][cnt] = 0x04;
 				} else {
@@ -1518,6 +1857,7 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 						pw2g->bw40_diff[path][cnt] |=
 									  0xF0;
 				}
+
 				if (hwinfo[addr] == 0xFF) {
 					pw2g->bw20_diff[path][cnt] = 0xFE;
 				} else {
@@ -1538,9 +1878,10 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 						pw2g->ofdm_diff[path][cnt] |=
 									  0xF0;
 				}
-				if (hwinfo[addr] == 0xFF) {
+
+				if (hwinfo[addr] == 0xFF)
 					pw2g->cck_diff[path][cnt] = 0xFE;
-				} else {
+				else {
 					pw2g->cck_diff[path][cnt] =
 							(hwinfo[addr] & 0x0f);
 					if (pw2g->cck_diff[path][cnt] & BIT(3))
@@ -1550,12 +1891,14 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 				addr++;
 			}
 		}
+
 		/*5G default value*/
 		for (group = 0; group < MAX_CHNL_GROUP_5G; group++) {
 			pw5g->index_bw40_base[path][group] = hwinfo[addr++];
 			if (pw5g->index_bw40_base[path][group] == 0xFF)
 				pw5g->index_bw40_base[path][group] = 0xFE;
 		}
+
 		for (cnt = 0; cnt < MAX_TX_COUNT; cnt++) {
 			if (cnt == 0) {
 				pw5g->bw40_diff[path][cnt] = 0;
@@ -1569,9 +1912,10 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 						pw5g->bw20_diff[path][cnt] |=
 									  0xF0;
 				}
-				if (hwinfo[addr] == 0xFF) {
+
+				if (hwinfo[addr] == 0xFF)
 					pw5g->ofdm_diff[path][cnt] = 0x04;
-				} else {
+				else {
 					pw5g->ofdm_diff[path][0] =
 							(hwinfo[addr] & 0x0f);
 					if (pw5g->ofdm_diff[path][cnt] & BIT(3))
@@ -1588,6 +1932,7 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 					if (pw5g->bw40_diff[path][cnt] & BIT(3))
 						pw5g->bw40_diff[path][cnt] |= 0xF0;
 				}
+
 				if (hwinfo[addr] == 0xFF) {
 					pw5g->bw20_diff[path][cnt] = 0xFE;
 				} else {
@@ -1599,6 +1944,7 @@ static void _rtl8723be_read_power_value_fromprom(struct ieee80211_hw *hw,
 				addr++;
 			}
 		}
+
 		if (hwinfo[addr] == 0xFF) {
 			pw5g->ofdm_diff[path][1] = 0xFE;
 			pw5g->ofdm_diff[path][2] = 0xFE;
@@ -1654,14 +2000,16 @@ static void _rtl8723be_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			rtlefuse->txpwr_legacyhtdiff[rf_path][i] =
 						pw2g.ofdm_diff[rf_path][i];
 		}
+
 		for (i = 0; i < 14; i++) {
-			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
-				"RF(%d)-Ch(%d) [CCK / HT40_1S ] = "
-				"[0x%x / 0x%x ]\n", rf_path, i,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
+				"RF(%d)-Ch(%d) [CCK / HT40_1S ] = [0x%x / 0x%x ]\n",
+				rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
 				rtlefuse->txpwrlevel_ht40_1s[rf_path][i]);
 		}
 	}
+
 	if (!autoload_fail)
 		rtlefuse->eeprom_thermalmeter =
 					hwinfo[EEPROM_THERMAL_METER_88E];
@@ -1672,8 +2020,9 @@ static void _rtl8723be_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->apk_thermalmeterignore = true;
 		rtlefuse->eeprom_thermalmeter = EEPROM_DEFAULT_THERMALMETER;
 	}
+
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
-	RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 
 	if (!autoload_fail) {
@@ -1684,7 +2033,7 @@ static void _rtl8723be_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	} else {
 		rtlefuse->eeprom_regulatory = 0;
 	}
-	RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 }
 
@@ -1744,6 +2093,7 @@ static void _rtl8723be_read_adapter_info(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 	}
+
 	if (rtlefuse->autoload_failflag)
 		return;
 
@@ -1959,100 +2309,10 @@ void rtl8723be_read_eeprom_info(struct ieee80211_hw *hw)
 	_rtl8723be_hal_customized_behavior(hw);
 }
 
-static void rtl8723be_update_hal_rate_table(struct ieee80211_hw *hw,
-					    struct ieee80211_sta *sta)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u32 ratr_value;
-	u8 ratr_index = 0;
-	u8 nmode = mac->ht_enable;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
-	u16 shortgi_rate;
-	u32 tmp_ratr_value;
-	u8 curtxbw_40mhz = mac->bw_40;
-	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
-			       1 : 0;
-	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
-			       1 : 0;
-	enum wireless_mode wirelessmode = mac->mode;
-
-	if (rtlhal->current_bandtype == BAND_ON_5G)
-		ratr_value = sta->supp_rates[1] << 4;
-	else
-		ratr_value = sta->supp_rates[0];
-	if (mac->opmode == NL80211_IFTYPE_ADHOC)
-		ratr_value = 0xfff;
-	ratr_value |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
-		       sta->ht_cap.mcs.rx_mask[0] << 12);
-	switch (wirelessmode) {
-	case WIRELESS_MODE_B:
-		if (ratr_value & 0x0000000c)
-			ratr_value &= 0x0000000d;
-		else
-			ratr_value &= 0x0000000f;
-		break;
-	case WIRELESS_MODE_G:
-		ratr_value &= 0x00000FF5;
-		break;
-	case WIRELESS_MODE_N_24G:
-	case WIRELESS_MODE_N_5G:
-		nmode = 1;
-		if (mimo_ps == IEEE80211_SMPS_STATIC) {
-			ratr_value &= 0x0007F005;
-		} else {
-			u32 ratr_mask;
-
-			if (get_rf_type(rtlphy) == RF_1T2R ||
-			    get_rf_type(rtlphy) == RF_1T1R)
-				ratr_mask = 0x000ff005;
-			else
-				ratr_mask = 0x0f0ff005;
-			ratr_value &= ratr_mask;
-		}
-		break;
-	default:
-		if (rtlphy->rf_type == RF_1T2R)
-			ratr_value &= 0x000ff0ff;
-		else
-			ratr_value &= 0x0f0ff0ff;
-		break;
-	}
-	if ((rtlpriv->btcoexist.bt_coexistence) &&
-	    (rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4) &&
-	    (rtlpriv->btcoexist.bt_cur_state) &&
-	    (rtlpriv->btcoexist.bt_ant_isolation) &&
-	    ((rtlpriv->btcoexist.bt_service == BT_SCO) ||
-	     (rtlpriv->btcoexist.bt_service == BT_BUSY)))
-		ratr_value &= 0x0fffcfc0;
-	else
-		ratr_value &= 0x0FFFFFFF;
-
-	if (nmode && ((curtxbw_40mhz && curshortgi_40mhz) ||
-		      (!curtxbw_40mhz && curshortgi_20mhz))) {
-		ratr_value |= 0x10000000;
-		tmp_ratr_value = (ratr_value >> 12);
-
-		for (shortgi_rate = 15; shortgi_rate > 0; shortgi_rate--) {
-			if ((1 << shortgi_rate) & tmp_ratr_value)
-				break;
-		}
-		shortgi_rate = (shortgi_rate << 12) | (shortgi_rate << 8) |
-			       (shortgi_rate << 4) | (shortgi_rate);
-	}
-	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
-
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 "%x\n", rtl_read_dword(rtlpriv, REG_ARFR0));
-}
-
 static u8 _rtl8723be_mrate_idx_to_arfr_id(struct ieee80211_hw *hw,
 					  u8 rate_index)
 {
 	u8 ret = 0;
-
 	switch (rate_index) {
 	case RATR_INX_WIRELESS_NGB:
 		ret = 1;
@@ -2091,16 +2351,15 @@ static void rtl8723be_update_hal_rate_mask(struct ieee80211_hw *hw,
 	u32 ratr_bitmap;
 	u8 ratr_index;
 	u8 curtxbw_40mhz = (sta->ht_cap.cap &
-			    IEEE80211_HT_CAP_SUP_WIDTH_20_40) ? 1 : 0;
+			      IEEE80211_HT_CAP_SUP_WIDTH_20_40) ? 1 : 0;
 	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
-			       1 : 0;
+				1 : 0;
 	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
-			       1 : 0;
+				1 : 0;
 	enum wireless_mode wirelessmode = 0;
 	bool shortgi = false;
 	u8 rate_mask[7];
 	u8 macid = 0;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
 
 	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
 	wirelessmode = sta_entry->wireless_mode;
@@ -2136,55 +2395,40 @@ static void rtl8723be_update_hal_rate_mask(struct ieee80211_hw *hw,
 		else
 			ratr_bitmap &= 0x00000ff5;
 		break;
-	case WIRELESS_MODE_A:
-		ratr_index = RATR_INX_WIRELESS_A;
-		ratr_bitmap &= 0x00000ff0;
-		break;
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		ratr_index = RATR_INX_WIRELESS_NGB;
-
-		if (mimo_ps == IEEE80211_SMPS_STATIC  ||
-		    mimo_ps == IEEE80211_SMPS_DYNAMIC) {
-			if (rssi_level == 1)
-				ratr_bitmap &= 0x00070000;
-			else if (rssi_level == 2)
-				ratr_bitmap &= 0x0007f000;
-			else
-				ratr_bitmap &= 0x0007f005;
+		if (rtlphy->rf_type == RF_1T1R) {
+			if (curtxbw_40mhz) {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x000f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x000ff000;
+				else
+					ratr_bitmap &= 0x000ff015;
+			} else {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x000f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x000ff000;
+				else
+					ratr_bitmap &= 0x000ff005;
+			}
 		} else {
-			if (rtlphy->rf_type == RF_1T1R) {
-				if (curtxbw_40mhz) {
-					if (rssi_level == 1)
-						ratr_bitmap &= 0x000f0000;
-					else if (rssi_level == 2)
-						ratr_bitmap &= 0x000ff000;
-					else
-						ratr_bitmap &= 0x000ff015;
-				} else {
-					if (rssi_level == 1)
-						ratr_bitmap &= 0x000f0000;
-					else if (rssi_level == 2)
-						ratr_bitmap &= 0x000ff000;
-					else
-						ratr_bitmap &= 0x000ff005;
-				}
+			if (curtxbw_40mhz) {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x0f8f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x0f8ff000;
+				else
+					ratr_bitmap &= 0x0f8ff015;
 			} else {
-				if (curtxbw_40mhz) {
-					if (rssi_level == 1)
-						ratr_bitmap &= 0x0f8f0000;
-					else if (rssi_level == 2)
-						ratr_bitmap &= 0x0f8ff000;
-					else
-						ratr_bitmap &= 0x0f8ff015;
-				} else {
-					if (rssi_level == 1)
-						ratr_bitmap &= 0x0f8f0000;
-					else if (rssi_level == 2)
-						ratr_bitmap &= 0x0f8ff000;
-					else
-						ratr_bitmap &= 0x0f8ff005;
-				}
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x0f8f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x0f8ff000;
+				else
+					ratr_bitmap &= 0x0f8ff005;
 			}
 		}
 		if ((curtxbw_40mhz && curshortgi_40mhz) ||
@@ -2204,18 +2448,17 @@ static void rtl8723be_update_hal_rate_mask(struct ieee80211_hw *hw,
 			ratr_bitmap &= 0x0f0ff0ff;
 		break;
 	}
+
 	sta_entry->ratr_index = ratr_index;
 
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "ratr_bitmap :%x\n", ratr_bitmap);
-	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) | (ratr_index << 28);
+	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
+				       (ratr_index << 28);
 	rate_mask[0] = macid;
 	rate_mask[1] = _rtl8723be_mrate_idx_to_arfr_id(hw, ratr_index) |
-						       (shortgi ? 0x80 : 0x00);
+						      (shortgi ? 0x80 : 0x00);
 	rate_mask[2] = curtxbw_40mhz;
-	/* if (prox_priv->proxim_modeinfo->power_output > 0)
-	 *	rate_mask[2] |= BIT(6);
-	 */
 
 	rate_mask[3] = (u8)(ratr_bitmap & 0x000000ff);
 	rate_mask[4] = (u8)((ratr_bitmap & 0x0000ff00) >> 8);
@@ -2229,7 +2472,7 @@ static void rtl8723be_update_hal_rate_mask(struct ieee80211_hw *hw,
 		 rate_mask[2], rate_mask[3],
 		 rate_mask[4], rate_mask[5],
 		 rate_mask[6]);
-	rtl8723be_fill_h2c_cmd(hw, H2C_8723BE_RA_MASK, 7, rate_mask);
+	rtl8723be_fill_h2c_cmd(hw, H2C_8723B_RA_MASK, 7, rate_mask);
 	_rtl8723be_set_bcn_ctrl_reg(hw, BIT(3), 0);
 }
 
@@ -2240,8 +2483,6 @@ void rtl8723be_update_hal_rate_tbl(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	if (rtlpriv->dm.useramask)
 		rtl8723be_update_hal_rate_mask(hw, sta, rssi_level);
-	else
-		rtl8723be_update_hal_rate_table(hw, sta);
 }
 
 void rtl8723be_update_channel_access_setting(struct ieee80211_hw *hw)
@@ -2265,7 +2506,7 @@ bool rtl8723be_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
 	u8 u1tmp;
-	bool actuallyset = false;
+	bool b_actuallyset = false;
 
 	if (rtlpriv->rtlhal.being_init_adapter)
 		return false;
@@ -2281,6 +2522,7 @@ bool rtl8723be_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		ppsc->rfchange_inprogress = true;
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
+
 	cur_rfstate = ppsc->rfpwr_state;
 
 	rtl_write_byte(rtlpriv, REG_GPIO_IO_SEL_2,
@@ -2293,24 +2535,23 @@ bool rtl8723be_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	else
 		e_rfpowerstate_toset = (u1tmp & BIT(1)) ? ERFON : ERFOFF;
 
-	if (ppsc->hwradiooff &&
-	    (e_rfpowerstate_toset == ERFON)) {
+	if ((ppsc->hwradiooff) && (e_rfpowerstate_toset == ERFON)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
 
 		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
-		actuallyset = true;
-	} else if (!ppsc->hwradiooff &&
-		   (e_rfpowerstate_toset == ERFOFF)) {
+		b_actuallyset = true;
+	} else if (!ppsc->hwradiooff && (e_rfpowerstate_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
 
 		e_rfpowerstate_toset = ERFOFF;
 		ppsc->hwradiooff = true;
-		actuallyset = true;
+		b_actuallyset = true;
 	}
-	if (actuallyset) {
+
+	if (b_actuallyset) {
 		spin_lock(&rtlpriv->locks.rf_ps_lock);
 		ppsc->rfchange_inprogress = false;
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
@@ -2322,8 +2563,10 @@ bool rtl8723be_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		ppsc->rfchange_inprogress = false;
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
+
 	*valid = 1;
 	return !ppsc->hwradiooff;
+
 }
 
 void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
@@ -2364,6 +2607,7 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 				rtlpriv->sec.key_len[idx] = 0;
 			}
 		}
+
 	} else {
 		switch (enc_algo) {
 		case WEP40_ENCRYPTION:
@@ -2379,7 +2623,7 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 			enc_algo = CAM_AES;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 				 "switch case not process\n");
 			enc_algo = CAM_TKIP;
 			break;
@@ -2399,22 +2643,22 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 					if (entry_id >=  TOTAL_CAM_ENTRY) {
 						RT_TRACE(rtlpriv, COMP_SEC,
 							 DBG_EMERG,
-							 "Can not find free"
-							 " hw security cam "
-							 "entry\n");
+							 "Can not find free hw security cam entry\n");
 						return;
 					}
 				} else {
 					entry_id = CAM_PAIRWISE_KEY_POSITION;
 				}
+
 				key_index = PAIRWISE_KEYIDX;
 				is_pairwise = true;
 			}
 		}
+
 		if (rtlpriv->sec.key_len[key_index] == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "delete one entry, entry_id is %d\n",
-				 entry_id);
+				  entry_id);
 			if (mac->opmode == NL80211_IFTYPE_AP)
 				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
@@ -2423,12 +2667,12 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 "add one entry\n");
 			if (is_pairwise) {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 "set Pairwise key\n");
+					 "set Pairwiase key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
-						      entry_id, enc_algo,
-						      CAM_CONFIG_NO_USEDK,
-						      rtlpriv->sec.key_buf[key_index]);
+					       entry_id, enc_algo,
+					       CAM_CONFIG_NO_USEDK,
+					       rtlpriv->sec.key_buf[key_index]);
 			} else {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 					 "set group key\n");
@@ -2443,10 +2687,11 @@ void rtl8723be_set_key(struct ieee80211_hw *hw, u32 key_index,
 						rtlpriv->sec.key_buf
 						[entry_id]);
 				}
+
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
-						      entry_id, enc_algo,
-						      CAM_CONFIG_NO_USEDK,
-						      rtlpriv->sec.key_buf[entry_id]);
+						entry_id, enc_algo,
+						CAM_CONFIG_NO_USEDK,
+						rtlpriv->sec.key_buf[entry_id]);
 			}
 		}
 	}
@@ -2465,7 +2710,7 @@ void rtl8723be_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
 			rtlpriv->btcoexist.btc_info.btcoexist = 1;
 		else
 			rtlpriv->btcoexist.btc_info.btcoexist = 0;
-		value = hwinfo[RF_OPTION4];
+		value = hwinfo[EEPROM_RF_BT_SETTING_8723B];
 		rtlpriv->btcoexist.btc_info.bt_type = BT_RTL8723B;
 		rtlpriv->btcoexist.btc_info.ant_num = (value & 0x1);
 	} else {
@@ -2473,6 +2718,7 @@ void rtl8723be_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlpriv->btcoexist.btc_info.bt_type = BT_RTL8723B;
 		rtlpriv->btcoexist.btc_info.ant_num = ANT_X2;
 	}
+
 }
 
 void rtl8723be_bt_reg_init(struct ieee80211_hw *hw)
@@ -2493,6 +2739,7 @@ void rtl8723be_bt_hw_init(struct ieee80211_hw *hw)
 
 	if (rtlpriv->cfg->ops->get_btc_status())
 		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+
 }
 
 void rtl8723be_suspend(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.h b/drivers/net/wireless/rtlwifi/rtl8723be/hw.h
index 64c7551..eae863d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.h
@@ -59,4 +59,5 @@ void rtl8723be_bt_reg_init(struct ieee80211_hw *hw);
 void rtl8723be_bt_hw_init(struct ieee80211_hw *hw);
 void rtl8723be_suspend(struct ieee80211_hw *hw);
 void rtl8723be_resume(struct ieee80211_hw *hw);
+
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/led.c b/drivers/net/wireless/rtlwifi/rtl8723be/led.c
index cb931a3..4196efb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/led.c
@@ -42,7 +42,7 @@ void rtl8723be_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 "LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin);
+		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
 
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
@@ -71,7 +71,7 @@ void rtl8723be_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	u8 ledcfg;
 
 	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 "LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin);
+		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
 
 	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 
@@ -100,7 +100,7 @@ void rtl8723be_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case not process\n");
 		break;
 	}
 	pled->ledon = false;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
index 1575ef9..20dcc25 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.c
@@ -26,224 +26,28 @@
 #include "../wifi.h"
 #include "../pci.h"
 #include "../ps.h"
-#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
 #include "../rtl8723com/phy_common.h"
 #include "rf.h"
 #include "dm.h"
+#include "../rtl8723com/dm_common.h"
 #include "table.h"
 #include "trx.h"
 
 static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw);
+static bool _rtl8723be_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
+static bool _rtl8723be_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+						     u8 configtype);
 static bool _rtl8723be_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
 						       u8 configtype);
-static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
-					      u8 channel, u8 *stage,
-					      u8 *step, u32 *delay);
-static bool _rtl8723be_check_condition(struct ieee80211_hw *hw,
-				       const u32  condition)
-{
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-	u32 _board = rtlefuse->board_type; /*need efuse define*/
-	u32 _interface = rtlhal->interface;
-	u32 _platform = 0x08;/*SupportPlatform */
-	u32 cond = condition;
-
-	if (condition == 0xCDCDCDCD)
-		return true;
-
-	cond = condition & 0xFF;
-	if ((_board & cond) == 0 && cond != 0x1F)
-		return false;
-
-	cond = condition & 0xFF00;
-	cond = cond >> 8;
-	if ((_interface & cond) == 0 && cond != 0x07)
-		return false;
-
-	cond = condition & 0xFF0000;
-	cond = cond >> 16;
-	if ((_platform & cond) == 0 && cond != 0x0F)
-		return false;
-	return true;
-}
-
-static bool _rtl8723be_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 i;
-	u32 arraylength;
-	u32 *ptrarray;
-
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read rtl8723beMACPHY_Array\n");
-	arraylength = RTL8723BEMAC_1T_ARRAYLEN;
-	ptrarray = RTL8723BEMAC_1T_ARRAY;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "Img:RTL8723bEMAC_1T_ARRAY LEN %d\n", arraylength);
-	for (i = 0; i < arraylength; i = i + 2)
-		rtl_write_byte(rtlpriv, ptrarray[i], (u8) ptrarray[i + 1]);
-	return true;
-}
-
-static bool _rtl8723be_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
-						     u8 configtype)
-{
-	#define READ_NEXT_PAIR(v1, v2, i) \
-		do { \
-			i += 2; \
-			v1 = array_table[i];\
-			v2 = array_table[i+1]; \
-		} while (0)
+static bool _rtl8723be_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+						u8 channel, u8 *stage,
+						u8 *step, u32 *delay);
 
-	int i;
-	u32 *array_table;
-	u16 arraylen;
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 v1 = 0, v2 = 0;
-
-	if (configtype == BASEBAND_CONFIG_PHY_REG) {
-		arraylen = RTL8723BEPHY_REG_1TARRAYLEN;
-		array_table = RTL8723BEPHY_REG_1TARRAY;
-
-		for (i = 0; i < arraylen; i = i + 2) {
-			v1 = array_table[i];
-			v2 = array_table[i+1];
-			if (v1 < 0xcdcdcdcd) {
-				rtl_bb_delay(hw, v1, v2);
-			} else {/*This line is the start line of branch.*/
-				if (!_rtl8723be_check_condition(hw, array_table[i])) {
-					/*Discard the following (offset, data) pairs*/
-					READ_NEXT_PAIR(v1, v2, i);
-					while (v2 != 0xDEAD &&
-					       v2 != 0xCDEF &&
-					       v2 != 0xCDCD &&
-					       i < arraylen - 2) {
-						READ_NEXT_PAIR(v1, v2, i);
-					}
-					i -= 2; /* prevent from for-loop += 2*/
-				/* Configure matched pairs and
-				 * skip to end of if-else.
-				 */
-				} else {
-					READ_NEXT_PAIR(v1, v2, i);
-					while (v2 != 0xDEAD &&
-					       v2 != 0xCDEF &&
-					       v2 != 0xCDCD &&
-					       i < arraylen - 2) {
-						rtl_bb_delay(hw,
-								    v1, v2);
-						READ_NEXT_PAIR(v1, v2, i);
-					}
-
-					while (v2 != 0xDEAD && i < arraylen - 2)
-						READ_NEXT_PAIR(v1, v2, i);
-				}
-			}
-		}
-	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
-		arraylen = RTL8723BEAGCTAB_1TARRAYLEN;
-		array_table = RTL8723BEAGCTAB_1TARRAY;
-
-		for (i = 0; i < arraylen; i = i + 2) {
-			v1 = array_table[i];
-			v2 = array_table[i+1];
-			if (v1 < 0xCDCDCDCD) {
-				rtl_set_bbreg(hw, array_table[i],
-					      MASKDWORD,
-					      array_table[i + 1]);
-				udelay(1);
-				continue;
-			} else {/*This line is the start line of branch.*/
-				if (!_rtl8723be_check_condition(hw, array_table[i])) {
-					/* Discard the following
-					 * (offset, data) pairs
-					 */
-					READ_NEXT_PAIR(v1, v2, i);
-					while (v2 != 0xDEAD &&
-					       v2 != 0xCDEF &&
-					       v2 != 0xCDCD &&
-					       i < arraylen - 2) {
-						READ_NEXT_PAIR(v1, v2, i);
-					}
-					i -= 2; /* prevent from for-loop += 2*/
-				/*Configure matched pairs and
-				 *skip to end of if-else.
-				 */
-				} else {
-					READ_NEXT_PAIR(v1, v2, i);
-					while (v2 != 0xDEAD &&
-					       v2 != 0xCDEF &&
-					       v2 != 0xCDCD &&
-					       i < arraylen - 2) {
-						rtl_set_bbreg(hw, array_table[i],
-							      MASKDWORD,
-							      array_table[i + 1]);
-						udelay(1);
-						READ_NEXT_PAIR(v1, v2, i);
-					}
-
-					while (v2 != 0xDEAD && i < arraylen - 2)
-						READ_NEXT_PAIR(v1, v2, i);
-				}
-			}
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "The agctab_array_table[0] is "
-				  "%x Rtl818EEPHY_REGArray[1] is %x\n",
-				  array_table[i], array_table[i + 1]);
-		}
-	}
-	return true;
-}
-
-static u8 _rtl8723be_get_rate_section_index(u32 regaddr)
-{
-	u8 index = 0;
-
-	switch (regaddr) {
-	case RTXAGC_A_RATE18_06:
-	case RTXAGC_B_RATE18_06:
-		index = 0;
-		break;
-	case RTXAGC_A_RATE54_24:
-	case RTXAGC_B_RATE54_24:
-		index = 1;
-		break;
-	case RTXAGC_A_CCK1_MCS32:
-	case RTXAGC_B_CCK1_55_MCS32:
-		index = 2;
-		break;
-	case RTXAGC_B_CCK11_A_CCK2_11:
-		index = 3;
-		break;
-	case RTXAGC_A_MCS03_MCS00:
-	case RTXAGC_B_MCS03_MCS00:
-		index = 4;
-		break;
-	case RTXAGC_A_MCS07_MCS04:
-	case RTXAGC_B_MCS07_MCS04:
-		index = 5;
-		break;
-	case RTXAGC_A_MCS11_MCS08:
-	case RTXAGC_B_MCS11_MCS08:
-		index = 6;
-		break;
-	case RTXAGC_A_MCS15_MCS12:
-	case RTXAGC_B_MCS15_MCS12:
-		index = 7;
-		break;
-	default:
-		regaddr &= 0xFFF;
-		if (regaddr >= 0xC20 && regaddr <= 0xC4C)
-			index = (u8) ((regaddr - 0xC20) / 4);
-		else if (regaddr >= 0xE20 && regaddr <= 0xE4C)
-			index = (u8) ((regaddr - 0xE20) / 4);
-		break;
-	};
-	return index;
-}
+static void rtl8723be_phy_set_rf_on(struct ieee80211_hw *hw);
+static void rtl8723be_phy_set_io(struct ieee80211_hw *hw);
 
 u32 rtl8723be_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 			       u32 regaddr, u32 bitmask)
@@ -265,9 +69,8 @@ u32 rtl8723be_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "regaddr(%#x), rfpath(%#x), "
-		  "bitmask(%#x), original_value(%#x)\n",
-		  regaddr, rfpath, bitmask, original_value);
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		 regaddr, rfpath, bitmask, original_value);
 
 	return readback_value;
 }
@@ -300,6 +103,7 @@ void rtl8723be_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path path,
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
 		  regaddr, bitmask, data, path);
+
 }
 
 bool rtl8723be_phy_mac_config(struct ieee80211_hw *hw)
@@ -316,7 +120,7 @@ bool rtl8723be_phy_bb_config(struct ieee80211_hw *hw)
 	bool rtstatus = true;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 regval;
-	u8 reg_hwparafile = 1;
+	u8 b_reg_hwparafile = 1;
 	u32 tmp;
 	u8 crystalcap = rtlpriv->efuse.crystalcap;
 	rtl8723_phy_init_bb_rf_reg_def(hw);
@@ -333,7 +137,7 @@ bool rtl8723be_phy_bb_config(struct ieee80211_hw *hw)
 
 	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL + 1, 0x80);
 
-	if (reg_hwparafile == 1)
+	if (b_reg_hwparafile == 1)
 		rtstatus = _rtl8723be_phy_bb8723b_config_parafile(hw);
 
 	crystalcap = crystalcap & 0x3F;
@@ -348,18 +152,49 @@ bool rtl8723be_phy_rf_config(struct ieee80211_hw *hw)
 	return rtl8723be_phy_rf6052_config(hw);
 }
 
+static bool _rtl8723be_check_condition(struct ieee80211_hw *hw,
+				       const u32  condition)
+{
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u32 _board = rtlefuse->board_type; /*need efuse define*/
+	u32 _interface = rtlhal->interface;
+	u32 _platform = 0x08;/*SupportPlatform */
+	u32 cond = condition;
+
+	if (condition == 0xCDCDCDCD)
+		return true;
+
+	cond = condition & 0xFF;
+	if ((_board & cond) == 0 && cond != 0x1F)
+		return false;
+
+	cond = condition & 0xFF00;
+	cond = cond >> 8;
+	if ((_interface & cond) == 0 && cond != 0x07)
+		return false;
+
+	cond = condition & 0xFF0000;
+	cond = cond >> 16;
+	if ((_platform & cond) == 0 && cond != 0x0F)
+		return false;
+	return true;
+}
+
 static void _rtl8723be_config_rf_reg(struct ieee80211_hw *hw, u32 addr,
 				     u32 data, enum radio_path rfpath,
 				     u32 regaddr)
 {
 	if (addr == 0xfe || addr == 0xffe) {
+		/* In order not to disturb BT music
+		 *	when wifi init.(1ant NIC only)
+		 */
 		mdelay(50);
 	} else {
 		rtl_set_rfreg(hw, rfpath, regaddr, RFREG_OFFSET_MASK, data);
 		udelay(1);
 	}
 }
-
 static void _rtl8723be_config_rf_radio_a(struct ieee80211_hw *hw,
 					 u32 addr, u32 data)
 {
@@ -368,12 +203,13 @@ static void _rtl8723be_config_rf_radio_a(struct ieee80211_hw *hw,
 
 	_rtl8723be_config_rf_reg(hw, addr, data, RF90_PATH_A,
 				 addr | maskforphyset);
+
 }
 
 static void _rtl8723be_phy_init_tx_power_by_rate(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	u8 band, path, txnum, section;
 
@@ -383,16 +219,38 @@ static void _rtl8723be_phy_init_tx_power_by_rate(struct ieee80211_hw *hw)
 				for (section = 0;
 				     section < TX_PWR_BY_RATE_NUM_SECTION;
 				     ++section)
-					rtlphy->tx_power_by_rate_offset[band]
-						[path][txnum][section] = 0;
+					rtlphy->tx_power_by_rate_offset
+					  [band][path][txnum][section] = 0;
+}
+
+static void _rtl8723be_config_bb_reg(struct ieee80211_hw *hw,
+				     u32 addr, u32 data)
+{
+	if (addr == 0xfe) {
+		mdelay(50);
+	} else if (addr == 0xfd) {
+		mdelay(5);
+	} else if (addr == 0xfc) {
+		mdelay(1);
+	} else if (addr == 0xfb) {
+		udelay(50);
+	} else if (addr == 0xfa) {
+		udelay(5);
+	} else if (addr == 0xf9) {
+		udelay(1);
+	} else {
+		rtl_set_bbreg(hw, addr, MASKDWORD, data);
+		udelay(1);
+	}
 }
 
-static void phy_set_txpwr_by_rate_base(struct ieee80211_hw *hw, u8 band,
-				       u8 path, u8 rate_section,
-				       u8 txnum, u8 value)
+static void _rtl8723be_phy_set_txpower_by_rate_base(struct ieee80211_hw *hw,
+						    u8 band,
+						    u8 path, u8 rate_section,
+						    u8 txnum, u8 value)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	if (path > RF90_PATH_D) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
@@ -417,23 +275,24 @@ static void phy_set_txpwr_by_rate_base(struct ieee80211_hw *hw, u8 band,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "Invalid RateSection %d in Band 2.4G, Rf Path"
-				  " %d, %dTx in PHY_SetTxPowerByRateBase()\n",
-				  rate_section, path, txnum);
+				 "Invalid RateSection %d in Band 2.4G, Rf Path %d, %dTx in PHY_SetTxPowerByRateBase()\n",
+				 rate_section, path, txnum);
 			break;
 		};
 	} else {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "Invalid Band %d in PHY_SetTxPowerByRateBase()\n",
-			  band);
+			 band);
 	}
+
 }
 
-static u8 phy_get_txpwr_by_rate_base(struct ieee80211_hw *hw, u8 band, u8 path,
-				     u8 txnum, u8 rate_section)
+static u8 _rtl8723be_phy_get_txpower_by_rate_base(struct ieee80211_hw *hw,
+						  u8 band, u8 path, u8 txnum,
+						  u8 rate_section)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 value = 0;
 	if (path > RF90_PATH_D) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
@@ -458,15 +317,14 @@ static u8 phy_get_txpwr_by_rate_base(struct ieee80211_hw *hw, u8 band, u8 path,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "Invalid RateSection %d in Band 2.4G, Rf Path"
-				  " %d, %dTx in PHY_GetTxPowerByRateBase()\n",
-				  rate_section, path, txnum);
+				 "Invalid RateSection %d in Band 2.4G, Rf Path %d, %dTx in PHY_GetTxPowerByRateBase()\n",
+				 rate_section, path, txnum);
 			break;
 		};
 	} else {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "Invalid Band %d in PHY_GetTxPowerByRateBase()\n",
-			  band);
+			 band);
 	}
 
 	return value;
@@ -475,45 +333,51 @@ static u8 phy_get_txpwr_by_rate_base(struct ieee80211_hw *hw, u8 band, u8 path,
 static void _rtl8723be_phy_store_txpower_by_rate_base(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	u16 raw_value = 0;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	u16 rawvalue = 0;
 	u8 base = 0, path = 0;
 
 	for (path = RF90_PATH_A; path <= RF90_PATH_B; ++path) {
 		if (path == RF90_PATH_A) {
-			raw_value = (u16) (rtlphy->tx_power_by_rate_offset
+			rawvalue = (u16)(rtlphy->tx_power_by_rate_offset
 				[BAND_ON_2_4G][path][RF_1TX][3] >> 24) & 0xFF;
-			base = (raw_value >> 4) * 10 + (raw_value & 0xF);
-			phy_set_txpwr_by_rate_base(hw, BAND_ON_2_4G, path, CCK,
-						   RF_1TX, base);
+			base = (rawvalue >> 4) * 10 + (rawvalue & 0xF);
+			_rtl8723be_phy_set_txpower_by_rate_base(hw,
+				BAND_ON_2_4G, path, CCK, RF_1TX, base);
 		} else if (path == RF90_PATH_B) {
-			raw_value = (u16) (rtlphy->tx_power_by_rate_offset
+			rawvalue = (u16)(rtlphy->tx_power_by_rate_offset
 				[BAND_ON_2_4G][path][RF_1TX][3] >> 0) & 0xFF;
-			base = (raw_value >> 4) * 10 + (raw_value & 0xF);
-			phy_set_txpwr_by_rate_base(hw, BAND_ON_2_4G, path,
-						   CCK, RF_1TX, base);
+			base = (rawvalue >> 4) * 10 + (rawvalue & 0xF);
+			_rtl8723be_phy_set_txpower_by_rate_base(hw,
+								BAND_ON_2_4G,
+								path, CCK,
+								RF_1TX, base);
 		}
-		raw_value = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-					  [path][RF_1TX][1] >> 24) & 0xFF;
-		base = (raw_value >> 4) * 10 + (raw_value & 0xF);
-		phy_set_txpwr_by_rate_base(hw, BAND_ON_2_4G, path, OFDM, RF_1TX,
-					   base);
-
-		raw_value = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-					  [path][RF_1TX][5] >> 24) & 0xFF;
-		base = (raw_value >> 4) * 10 + (raw_value & 0xF);
-		phy_set_txpwr_by_rate_base(hw, BAND_ON_2_4G, path, HT_MCS0_MCS7,
-					   RF_1TX, base);
-
-		raw_value = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-					  [path][RF_2TX][7] >> 24) & 0xFF;
-		base = (raw_value >> 4) * 10 + (raw_value & 0xF);
-		phy_set_txpwr_by_rate_base(hw, BAND_ON_2_4G, path,
-					   HT_MCS8_MCS15, RF_2TX, base);
+		rawvalue = (u16)(rtlphy->tx_power_by_rate_offset
+				[BAND_ON_2_4G][path][RF_1TX][1] >> 24) & 0xFF;
+		base = (rawvalue >> 4) * 10 + (rawvalue & 0xF);
+		_rtl8723be_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G,
+							path, OFDM, RF_1TX,
+							base);
+
+		rawvalue = (u16)(rtlphy->tx_power_by_rate_offset
+				[BAND_ON_2_4G][path][RF_1TX][5] >> 24) & 0xFF;
+		base = (rawvalue >> 4) * 10 + (rawvalue & 0xF);
+		_rtl8723be_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G,
+							path, HT_MCS0_MCS7,
+							RF_1TX, base);
+
+		rawvalue = (u16)(rtlphy->tx_power_by_rate_offset
+				[BAND_ON_2_4G][path][RF_2TX][7] >> 24) & 0xFF;
+		base = (rawvalue >> 4) * 10 + (rawvalue & 0xF);
+		_rtl8723be_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G,
+							path, HT_MCS8_MCS15,
+							RF_2TX, base);
 	}
 }
 
-static void phy_conv_dbm_to_rel(u32 *data, u8 start, u8 end, u8 base_val)
+static void _phy_convert_txpower_dbm_to_relative_value(u32 *data, u8 start,
+						u8 end, u8 base_val)
 {
 	char i = 0;
 	u8 temp_value = 0;
@@ -522,15 +386,15 @@ static void phy_conv_dbm_to_rel(u32 *data, u8 start, u8 end, u8 base_val)
 	for (i = 3; i >= 0; --i) {
 		if (i >= start && i <= end) {
 			/* Get the exact value */
-			temp_value = (u8) (*data >> (i * 8)) & 0xF;
-			temp_value += ((u8) ((*data >> (i*8 + 4)) & 0xF)) * 10;
+			temp_value = (u8)(*data >> (i * 8)) & 0xF;
+			temp_value += ((u8)((*data >> (i*8 + 4)) & 0xF)) * 10;
 
 			/* Change the value to a relative value */
 			temp_value = (temp_value > base_val) ?
 				     temp_value - base_val :
 				     base_val - temp_value;
 		} else {
-			temp_value = (u8) (*data >> (i * 8)) & 0xFF;
+			temp_value = (u8)(*data >> (i * 8)) & 0xFF;
 		}
 		temp_data <<= 8;
 		temp_data |= temp_value;
@@ -538,56 +402,65 @@ static void phy_conv_dbm_to_rel(u32 *data, u8 start, u8 end, u8 base_val)
 	*data = temp_data;
 }
 
-static void conv_dbm_to_rel(struct ieee80211_hw *hw)
+static void _rtl8723be_phy_convert_txpower_dbm_to_relative_value(
+							struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 base = 0, rfpath = RF90_PATH_A;
 
-	base = phy_get_txpwr_by_rate_base(hw, BAND_ON_2_4G, rfpath,
-					  RF_1TX, CCK);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_1TX][2]), 1, 1, base);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_1TX][3]), 1, 3, base);
-
-	base = phy_get_txpwr_by_rate_base(hw, BAND_ON_2_4G, rfpath,
-					  RF_1TX, OFDM);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_1TX][0]), 0, 3, base);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_1TX][1]), 0, 3, base);
-
-	base = phy_get_txpwr_by_rate_base(hw, BAND_ON_2_4G, rfpath,
-					  RF_1TX, HT_MCS0_MCS7);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_1TX][4]), 0, 3, base);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_1TX][5]), 0, 3, base);
-
-	base = phy_get_txpwr_by_rate_base(hw, BAND_ON_2_4G, rfpath,
-					  RF_2TX, HT_MCS8_MCS15);
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_2TX][6]), 0, 3, base);
-
-	phy_conv_dbm_to_rel(&(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G]
-			    [rfpath][RF_2TX][7]), 0, 3, base);
+	base = _rtl8723be_phy_get_txpower_by_rate_base(hw,
+			BAND_ON_2_4G, rfpath, RF_1TX, CCK);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_1TX][2],
+	    1, 1, base);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_1TX][3],
+	    1, 3, base);
+
+	base = _rtl8723be_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, rfpath,
+						       RF_1TX, OFDM);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_1TX][0],
+	    0, 3, base);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_1TX][1],
+	    0, 3, base);
+
+	base = _rtl8723be_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G,
+						rfpath, RF_1TX, HT_MCS0_MCS7);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_1TX][4],
+	    0, 3, base);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_1TX][5],
+	    0, 3, base);
+
+	base = _rtl8723be_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G,
+						       rfpath, RF_2TX,
+						       HT_MCS8_MCS15);
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_2TX][6],
+	    0, 3, base);
+
+	_phy_convert_txpower_dbm_to_relative_value(
+	    &rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfpath][RF_2TX][7],
+	    0, 3, base);
 
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-		 "<=== conv_dbm_to_rel()\n");
+	    "<===_rtl8723be_phy_convert_txpower_dbm_to_relative_value()\n");
 }
 
-static void _rtl8723be_phy_txpower_by_rate_configuration(
-							struct ieee80211_hw *hw)
+static void phy_txpower_by_rate_config(struct ieee80211_hw *hw)
 {
 	_rtl8723be_phy_store_txpower_by_rate_base(hw);
-	conv_dbm_to_rel(hw);
+	_rtl8723be_phy_convert_txpower_dbm_to_relative_value(hw);
 }
 
 static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	bool rtstatus;
 
@@ -603,7 +476,7 @@ static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw)
 		rtstatus = _rtl8723be_phy_config_bb_with_pgheaderfile(hw,
 						BASEBAND_CONFIG_PHY_REG);
 	}
-	_rtl8723be_phy_txpower_by_rate_configuration(hw);
+	phy_txpower_by_rate_config(hw);
 	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
 		return false;
@@ -614,39 +487,237 @@ static bool _rtl8723be_phy_bb8723b_config_parafile(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
-	rtlphy->cck_high_power = (bool) (rtl_get_bbreg(hw,
-						       RFPGA0_XA_HSSIPARAMETER2,
-						       0x200));
+	rtlphy->cck_high_power = (bool)(rtl_get_bbreg(hw,
+						      RFPGA0_XA_HSSIPARAMETER2,
+						      0x200));
+	return true;
+}
+
+static bool _rtl8723be_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 i;
+	u32 arraylength;
+	u32 *ptrarray;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read rtl8723beMACPHY_Array\n");
+	arraylength = RTL8723BEMAC_1T_ARRAYLEN;
+	ptrarray = RTL8723BEMAC_1T_ARRAY;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Img:RTL8723bEMAC_1T_ARRAY LEN %d\n", arraylength);
+	for (i = 0; i < arraylength; i = i + 2)
+		rtl_write_byte(rtlpriv, ptrarray[i], (u8)ptrarray[i + 1]);
+	return true;
+}
+
+static bool _rtl8723be_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+						     u8 configtype)
+{
+	#define READ_NEXT_PAIR(v1, v2, i) \
+		do { \
+			i += 2; \
+			v1 = array_table[i];\
+			v2 = array_table[i+1]; \
+		} while (0)
+
+	int i;
+	u32 *array_table;
+	u16 arraylen;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 v1 = 0, v2 = 0;
+
+	if (configtype == BASEBAND_CONFIG_PHY_REG) {
+		arraylen = RTL8723BEPHY_REG_1TARRAYLEN;
+		array_table = RTL8723BEPHY_REG_1TARRAY;
+
+		for (i = 0; i < arraylen; i = i + 2) {
+			v1 = array_table[i];
+			v2 = array_table[i+1];
+			if (v1 < 0xcdcdcdcd) {
+				_rtl8723be_config_bb_reg(hw, v1, v2);
+			} else {/*This line is the start line of branch.*/
+				/* to protect READ_NEXT_PAIR not overrun */
+				if (i >= arraylen - 2)
+					break;
+
+				if (!_rtl8723be_check_condition(hw,
+						array_table[i])) {
+					/*Discard the following
+					 *(offset, data) pairs
+					 */
+					READ_NEXT_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD &&
+					       i < arraylen - 2) {
+						READ_NEXT_PAIR(v1, v2, i);
+					}
+					i -= 2; /* prevent from for-loop += 2*/
+				/*Configure matched pairs and
+				 *skip to end of if-else.
+				 */
+				} else {
+					READ_NEXT_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD &&
+					       i < arraylen - 2) {
+						_rtl8723be_config_bb_reg(hw,
+								    v1, v2);
+						READ_NEXT_PAIR(v1, v2, i);
+					}
+
+					while (v2 != 0xDEAD && i < arraylen - 2)
+						READ_NEXT_PAIR(v1, v2, i);
+				}
+			}
+		}
+	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
+		arraylen = RTL8723BEAGCTAB_1TARRAYLEN;
+		array_table = RTL8723BEAGCTAB_1TARRAY;
+
+		for (i = 0; i < arraylen; i = i + 2) {
+			v1 = array_table[i];
+			v2 = array_table[i+1];
+			if (v1 < 0xCDCDCDCD) {
+				rtl_set_bbreg(hw, array_table[i],
+					      MASKDWORD,
+					      array_table[i + 1]);
+				udelay(1);
+				continue;
+			} else {/*This line is the start line of branch.*/
+				/* to protect READ_NEXT_PAIR not overrun */
+				if (i >= arraylen - 2)
+					break;
+
+				if (!_rtl8723be_check_condition(hw,
+					array_table[i])) {
+					/*Discard the following
+					 *(offset, data) pairs
+					 */
+					READ_NEXT_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD &&
+					       i < arraylen - 2) {
+						READ_NEXT_PAIR(v1, v2, i);
+					}
+					i -= 2; /* prevent from for-loop += 2*/
+				/*Configure matched pairs and
+				 *skip to end of if-else.
+				 */
+				} else {
+					READ_NEXT_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD &&
+					       i < arraylen - 2) {
+						rtl_set_bbreg(hw, array_table[i],
+							      MASKDWORD,
+							      array_table[i + 1]);
+						udelay(1);
+						READ_NEXT_PAIR(v1, v2, i);
+					}
+
+					while (v2 != 0xDEAD && i < arraylen - 2)
+						READ_NEXT_PAIR(v1, v2, i);
+				}
+			}
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+				 "The agctab_array_table[0] is %x Rtl818EEPHY_REGArray[1] is %x\n",
+				 array_table[i], array_table[i + 1]);
+		}
+	}
 	return true;
 }
 
+static u8 _rtl8723be_get_rate_section_index(u32 regaddr)
+{
+	u8 index = 0;
+
+	switch (regaddr) {
+	case RTXAGC_A_RATE18_06:
+		index = 0;
+	break;
+	case RTXAGC_A_RATE54_24:
+		index = 1;
+	break;
+	case RTXAGC_A_CCK1_MCS32:
+		index = 2;
+	break;
+	case RTXAGC_B_CCK11_A_CCK2_11:
+		index = 3;
+	break;
+	case RTXAGC_A_MCS03_MCS00:
+		index = 4;
+	break;
+	case RTXAGC_A_MCS07_MCS04:
+		index = 5;
+	break;
+	case RTXAGC_A_MCS11_MCS08:
+		index = 6;
+	break;
+	case RTXAGC_A_MCS15_MCS12:
+		index = 7;
+	break;
+	case RTXAGC_B_RATE18_06:
+		index = 0;
+	break;
+	case RTXAGC_B_RATE54_24:
+		index = 1;
+	break;
+	case RTXAGC_B_CCK1_55_MCS32:
+		index = 2;
+	break;
+	case RTXAGC_B_MCS03_MCS00:
+		index = 4;
+	break;
+	case RTXAGC_B_MCS07_MCS04:
+		index = 5;
+	break;
+	case RTXAGC_B_MCS11_MCS08:
+		index = 6;
+	break;
+	case RTXAGC_B_MCS15_MCS12:
+		index = 7;
+	break;
+	default:
+		regaddr &= 0xFFF;
+		if (regaddr >= 0xC20 && regaddr <= 0xC4C)
+			index = (u8)((regaddr - 0xC20) / 4);
+		else if (regaddr >= 0xE20 && regaddr <= 0xE4C)
+			index = (u8)((regaddr - 0xE20) / 4);
+		break;
+	};
+	return index;
+}
+
 static void _rtl8723be_store_tx_power_by_rate(struct ieee80211_hw *hw,
 					      u32 band, u32 rfpath,
 					      u32 txnum, u32 regaddr,
 					      u32 bitmask, u32 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 rate_section = _rtl8723be_get_rate_section_index(regaddr);
 
 	if (band != BAND_ON_2_4G && band != BAND_ON_5G) {
-		RT_TRACE(rtlpriv, COMP_POWER, PHY_TXPWR,
-			 "Invalid Band %d\n", band);
+		RT_TRACE(rtlpriv, FPHY, PHY_TXPWR, "Invalid Band %d\n", band);
 		return;
 	}
-
-	if (rfpath > TX_PWR_BY_RATE_NUM_RF) {
-		RT_TRACE(rtlpriv, COMP_POWER, PHY_TXPWR,
+	if (rfpath > MAX_RF_PATH - 1) {
+		RT_TRACE(rtlpriv, FPHY, PHY_TXPWR,
 			 "Invalid RfPath %d\n", rfpath);
 		return;
 	}
-	if (txnum > TX_PWR_BY_RATE_NUM_RF) {
-		RT_TRACE(rtlpriv, COMP_POWER, PHY_TXPWR,
-			 "Invalid TxNum %d\n", txnum);
+	if (txnum > MAX_RF_PATH - 1) {
+		RT_TRACE(rtlpriv, FPHY, PHY_TXPWR, "Invalid TxNum %d\n", txnum);
 		return;
 	}
+
 	rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][rate_section] =
 									data;
+
 }
 
 static bool _rtl8723be_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
@@ -678,21 +749,6 @@ static bool _rtl8723be_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
 					_rtl8723be_store_tx_power_by_rate(hw,
 							v1, v2, v3, v4, v5, v6);
 				continue;
-			} else {
-				/*don't need the hw_body*/
-				if (!_rtl8723be_check_condition(hw,
-						phy_regarray_table_pg[i])) {
-					i += 2; /* skip the pair of expression*/
-					v1 = phy_regarray_table_pg[i];
-					v2 = phy_regarray_table_pg[i+1];
-					v3 = phy_regarray_table_pg[i+2];
-					while (v2 != 0xDEAD) {
-						i += 3;
-						v1 = phy_regarray_table_pg[i];
-						v2 = phy_regarray_table_pg[i+1];
-						v3 = phy_regarray_table_pg[i+2];
-					}
-				}
 			}
 		}
 	} else {
@@ -733,22 +789,27 @@ bool rtl8723be_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 			v2 = radioa_array_table[i+1];
 			if (v1 < 0xcdcdcdcd) {
 				_rtl8723be_config_rf_radio_a(hw, v1, v2);
-			} else { /*This line is the start line of branch.*/
+			} else {/*This line is the start line of branch.*/
+				/* to protect READ_NEXT_PAIR not overrun */
+				if (i >= radioa_arraylen - 2)
+					break;
+
 				if (!_rtl8723be_check_condition(hw,
 						radioa_array_table[i])) {
-					/* Discard the following
-					 * (offset, data) pairs
+					/*Discard the following
+					 *(offset, data) pairs
 					 */
 					READ_NEXT_RF_PAIR(v1, v2, i);
 					while (v2 != 0xDEAD &&
 					       v2 != 0xCDEF &&
 					       v2 != 0xCDCD &&
-					       i < radioa_arraylen - 2)
+					       i < radioa_arraylen - 2) {
 						READ_NEXT_RF_PAIR(v1, v2, i);
+					}
 					i -= 2; /* prevent from for-loop += 2*/
 				} else {
-					/* Configure matched pairs
-					 * and skip to end of if-else.
+					/*Configure matched pairs
+					 *and skip to end of if-else.
 					 */
 					READ_NEXT_RF_PAIR(v1, v2, i);
 					while (v2 != 0xDEAD &&
@@ -770,18 +831,12 @@ bool rtl8723be_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 
 		if (rtlhal->oem_id == RT_CID_819X_HP)
 			_rtl8723be_config_rf_radio_a(hw, 0x52, 0x7E4BD);
-
 		break;
 	case RF90_PATH_B:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
 		break;
 	case RF90_PATH_D:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "switch case not process\n");
 		break;
 	}
@@ -791,26 +846,25 @@ bool rtl8723be_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 void rtl8723be_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	rtlphy->default_initialgain[0] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[1] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[2] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[3] =
-	    (u8) rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 "Default initial gain (c50 = 0x%x, "
-		  "c58 = 0x%x, c60 = 0x%x, c68 = 0x%x\n",
-		  rtlphy->default_initialgain[0],
-		  rtlphy->default_initialgain[1],
-		  rtlphy->default_initialgain[2],
-		  rtlphy->default_initialgain[3]);
-
-	rtlphy->framesync = (u8) rtl_get_bbreg(hw, ROFDM0_RXDETECTOR3,
+		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x\n",
+		 rtlphy->default_initialgain[0],
+		 rtlphy->default_initialgain[1],
+		 rtlphy->default_initialgain[2],
+		 rtlphy->default_initialgain[3]);
+
+	rtlphy->framesync = (u8)rtl_get_bbreg(hw, ROFDM0_RXDETECTOR3,
 					       MASKBYTE0);
 	rtlphy->framesync_c34 = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR2,
 					      MASKDWORD);
@@ -823,7 +877,7 @@ void rtl8723be_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 void rtl8723be_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 txpwr_level;
 	long txpwr_dbm;
 
@@ -854,6 +908,7 @@ static u8 _rtl8723be_phy_get_ratesection_intxpower_byrate(enum radio_path path,
 	case DESC92C_RATE1M:
 		rate_section = 2;
 		break;
+
 	case DESC92C_RATE2M:
 	case DESC92C_RATE5_5M:
 		if (path == RF90_PATH_A)
@@ -861,49 +916,58 @@ static u8 _rtl8723be_phy_get_ratesection_intxpower_byrate(enum radio_path path,
 		else if (path == RF90_PATH_B)
 			rate_section = 2;
 		break;
+
 	case DESC92C_RATE11M:
 		rate_section = 3;
 		break;
+
 	case DESC92C_RATE6M:
 	case DESC92C_RATE9M:
 	case DESC92C_RATE12M:
 	case DESC92C_RATE18M:
 		rate_section = 0;
 		break;
+
 	case DESC92C_RATE24M:
 	case DESC92C_RATE36M:
 	case DESC92C_RATE48M:
 	case DESC92C_RATE54M:
 		rate_section = 1;
 		break;
+
 	case DESC92C_RATEMCS0:
 	case DESC92C_RATEMCS1:
 	case DESC92C_RATEMCS2:
 	case DESC92C_RATEMCS3:
 		rate_section = 4;
 		break;
+
 	case DESC92C_RATEMCS4:
 	case DESC92C_RATEMCS5:
 	case DESC92C_RATEMCS6:
 	case DESC92C_RATEMCS7:
 		rate_section = 5;
 		break;
+
 	case DESC92C_RATEMCS8:
 	case DESC92C_RATEMCS9:
 	case DESC92C_RATEMCS10:
 	case DESC92C_RATEMCS11:
 		rate_section = 6;
 		break;
+
 	case DESC92C_RATEMCS12:
 	case DESC92C_RATEMCS13:
 	case DESC92C_RATEMCS14:
 	case DESC92C_RATEMCS15:
 		rate_section = 7;
 		break;
+
 	default:
 		RT_ASSERT(true, "Rate_Section is Illegal\n");
 		break;
 	}
+
 	return rate_section;
 }
 
@@ -912,7 +976,7 @@ static u8 _rtl8723be_get_txpower_by_rate(struct ieee80211_hw *hw,
 					 enum radio_path rfpath, u8 rate)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 shift = 0, rate_section, tx_num;
 	char tx_pwr_diff = 0;
 
@@ -988,7 +1052,7 @@ static u8 _rtl8723be_get_txpower_index(struct ieee80211_hw *hw, u8 path,
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
 			 "Illegal channel!\n");
 	}
-	if (RTL8723E_RX_HAL_IS_CCK_RATE(rate))
+	if (RX_HAL_IS_CCK_RATE(rate))
 		txpower = rtlefuse->txpwrlevel_cck[path][index];
 	else if (DESC92C_RATE6M <= rate)
 		txpower = rtlefuse->txpwrlevel_ht40_1s[path][index];
@@ -997,7 +1061,7 @@ static u8 _rtl8723be_get_txpower_index(struct ieee80211_hw *hw, u8 path,
 			 "invalid rate\n");
 
 	if (DESC92C_RATE6M <= rate && rate <= DESC92C_RATE54M &&
-	    !RTL8723E_RX_HAL_IS_CCK_RATE(rate))
+	    !RX_HAL_IS_CCK_RATE(rate))
 		txpower += rtlefuse->txpwr_legacyhtdiff[0][TX_1S];
 
 	if (bandwidth == HT_CHANNEL_WIDTH_20) {
@@ -1011,6 +1075,7 @@ static u8 _rtl8723be_get_txpower_index(struct ieee80211_hw *hw, u8 path,
 		if (DESC92C_RATEMCS8 <= rate && rate <= DESC92C_RATEMCS15)
 			txpower += rtlefuse->txpwr_ht40diff[0][TX_2S];
 	}
+
 	if (rtlefuse->eeprom_regulatory != 2)
 		power_diff_byrate = _rtl8723be_get_txpower_by_rate(hw,
 								   BAND_ON_2_4G,
@@ -1046,6 +1111,7 @@ static void _rtl8723be_phy_set_txpower_index(struct ieee80211_hw *hw,
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_B_CCK11_A_CCK2_11,
 					       MASKBYTE3, power_index);
 			break;
+
 		case DESC92C_RATE6M:
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_RATE18_06,
 					       MASKBYTE0, power_index);
@@ -1062,6 +1128,7 @@ static void _rtl8723be_phy_set_txpower_index(struct ieee80211_hw *hw,
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_RATE18_06,
 					       MASKBYTE3, power_index);
 			break;
+
 		case DESC92C_RATE24M:
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_RATE54_24,
 					       MASKBYTE0, power_index);
@@ -1078,6 +1145,7 @@ static void _rtl8723be_phy_set_txpower_index(struct ieee80211_hw *hw,
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_RATE54_24,
 					       MASKBYTE3, power_index);
 			break;
+
 		case DESC92C_RATEMCS0:
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_MCS03_MCS00,
 					       MASKBYTE0, power_index);
@@ -1094,6 +1162,7 @@ static void _rtl8723be_phy_set_txpower_index(struct ieee80211_hw *hw,
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_MCS03_MCS00,
 					       MASKBYTE3, power_index);
 			break;
+
 		case DESC92C_RATEMCS4:
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_MCS07_MCS04,
 					       MASKBYTE0, power_index);
@@ -1110,6 +1179,7 @@ static void _rtl8723be_phy_set_txpower_index(struct ieee80211_hw *hw,
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_MCS07_MCS04,
 					       MASKBYTE3, power_index);
 			break;
+
 		case DESC92C_RATEMCS8:
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_MCS11_MCS08,
 					       MASKBYTE0, power_index);
@@ -1126,9 +1196,9 @@ static void _rtl8723be_phy_set_txpower_index(struct ieee80211_hw *hw,
 			rtl8723_phy_set_bb_reg(hw, RTXAGC_A_MCS11_MCS08,
 					       MASKBYTE3, power_index);
 			break;
+
 		default:
-			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 "Invalid Rate!!\n");
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Invalid Rate!!\n");
 			break;
 		}
 	} else {
@@ -1192,10 +1262,11 @@ void rtl8723be_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
 
 	if (!is_hal_stop(rtlhal)) {
 		switch (operation) {
-		case SCAN_OPT_BACKUP:
-			iotype = IO_CMD_PAUSE_DM_BY_SCAN;
+		case SCAN_OPT_BACKUP_BAND0:
+			iotype = IO_CMD_PAUSE_BAND0_DM_BY_SCAN;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_IO_CMD,
 						      (u8 *)&iotype);
+
 			break;
 		case SCAN_OPT_RESTORE:
 			iotype = IO_CMD_RESUME_DM_BY_SCAN;
@@ -1214,15 +1285,15 @@ void rtl8723be_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u8 reg_bw_opmode;
 	u8 reg_prsr_rsc;
 
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
 		 "Switch to %s bandwidth\n",
-		 rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		 "20MHz" : "40MHz");
+		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
+		  "20MHz" : "40MHz");
 
 	if (is_hal_stop(rtlhal)) {
 		rtlphy->set_bwmode_inprogress = false;
@@ -1254,13 +1325,17 @@ void rtl8723be_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 	case HT_CHANNEL_WIDTH_20:
 		rtl_set_bbreg(hw, RFPGA0_RFMOD, BRFMOD, 0x0);
 		rtl_set_bbreg(hw, RFPGA1_RFMOD, BRFMOD, 0x0);
+	/*	rtl_set_bbreg(hw, RFPGA0_ANALOGPARAMETER2, BIT(10), 1);*/
 		break;
 	case HT_CHANNEL_WIDTH_20_40:
 		rtl_set_bbreg(hw, RFPGA0_RFMOD, BRFMOD, 0x1);
 		rtl_set_bbreg(hw, RFPGA1_RFMOD, BRFMOD, 0x1);
+
 		rtl_set_bbreg(hw, RCCK0_SYSTEM, BCCK_SIDEBAND,
 			      (mac->cur_40_prime_sc >> 1));
 		rtl_set_bbreg(hw, ROFDM1_LSTF, 0xC00, mac->cur_40_prime_sc);
+		/*rtl_set_bbreg(hw, RFPGA0_ANALOGPARAMETER2, BIT(10), 0);*/
+
 		rtl_set_bbreg(hw, 0x818, (BIT(26) | BIT(27)),
 			      (mac->cur_40_prime_sc ==
 			       HAL_PRIME_CHNL_OFFSET_LOWER) ? 2 : 1);
@@ -1279,7 +1354,7 @@ void rtl8723be_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 tmp_bw = rtlphy->current_chan_bw;
 
@@ -1300,7 +1375,7 @@ void rtl8723be_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 delay;
 
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
@@ -1310,11 +1385,11 @@ void rtl8723be_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 	do {
 		if (!rtlphy->sw_chnl_inprogress)
 			break;
-		if (!rtl8723be_phy_sw_chn_step_by_step(hw,
-						       rtlphy->current_channel,
-						       &rtlphy->sw_chnl_stage,
-						       &rtlphy->sw_chnl_step,
-						       &delay)) {
+		if (!_rtl8723be_phy_sw_chnl_step_by_step(hw,
+							 rtlphy->current_channel,
+							 &rtlphy->sw_chnl_stage,
+							 &rtlphy->sw_chnl_step,
+							 &delay)) {
 			if (delay > 0)
 				mdelay(delay);
 			else
@@ -1330,7 +1405,7 @@ void rtl8723be_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 u8 rtl8723be_phy_sw_chnl(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	if (rtlphy->sw_chnl_inprogress)
@@ -1345,25 +1420,23 @@ u8 rtl8723be_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl8723be_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schdule "
-			  "workitem current channel %d\n",
-			  rtlphy->current_channel);
+			 "sw_chnl_inprogress false schdule workitem current channel %d\n",
+			 rtlphy->current_channel);
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false driver sleep or"
-			  " unload\n");
+			 "sw_chnl_inprogress false driver sleep or unload\n");
 		rtlphy->sw_chnl_inprogress = false;
 	}
 	return 1;
 }
 
-static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
-					      u8 channel, u8 *stage,
-					      u8 *step, u32 *delay)
+static bool _rtl8723be_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+						u8 channel, u8 *stage,
+						u8 *step, u32 *delay)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct swchnlcmd precommoncmd[MAX_PRECMD_CNT];
 	u32 precommoncmdcnt;
 	struct swchnlcmd postcommoncmd[MAX_POSTCMD_CNT];
@@ -1381,10 +1454,13 @@ static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
 					 0, 0, 0);
 	rtl8723_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
 					 MAX_PRECMD_CNT, CMDID_END, 0, 0, 0);
+
 	postcommoncmdcnt = 0;
+
 	rtl8723_phy_set_sw_chnl_cmdarray(postcommoncmd, postcommoncmdcnt++,
 					 MAX_POSTCMD_CNT, CMDID_END,
-					 0, 0, 0);
+					    0, 0, 0);
+
 	rfdependcmdcnt = 0;
 
 	RT_ASSERT((channel >= 1 && channel <= 14),
@@ -1397,7 +1473,7 @@ static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
 
 	rtl8723_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
 					 MAX_RFDEPENDCMD_CNT,
-					 CMDID_END, 0, 0, 0);
+					    CMDID_END, 0, 0, 0);
 
 	do {
 		switch (*stage) {
@@ -1410,6 +1486,10 @@ static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
 		case 2:
 			currentcmd = &postcommoncmd[*step];
 			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Invalid 'stage' = %d, Check it!\n", *stage);
+			return true;
 		}
 
 		if (currentcmd->cmdid == CMDID_END) {
@@ -1432,11 +1512,11 @@ static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
 			break;
 		case CMDID_WRITEPORT_USHORT:
 			rtl_write_word(rtlpriv, currentcmd->para1,
-				       (u16) currentcmd->para2);
+				       (u16)currentcmd->para2);
 			break;
 		case CMDID_WRITEPORT_UCHAR:
 			rtl_write_byte(rtlpriv, currentcmd->para1,
-				       (u8) currentcmd->para2);
+				       (u8)currentcmd->para2);
 			break;
 		case CMDID_RF_WRITEREG:
 			for (rfpath = 0; rfpath < num_total_rfpath; rfpath++) {
@@ -1451,7 +1531,7 @@ static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
 			}
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 				 "switch case not process\n");
 			break;
 		}
@@ -1464,54 +1544,515 @@ static bool rtl8723be_phy_sw_chn_step_by_step(struct ieee80211_hw *hw,
 	return false;
 }
 
-static u8 _rtl8723be_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
+static u8 _rtl8723be_phy_path_a_iqk(struct ieee80211_hw *hw)
 {
-	u32 reg_eac, reg_e94, reg_e9c, reg_ea4;
+	u32 reg_eac, reg_e94, reg_e9c, tmp;
 	u8 result = 0x00;
 
-	rtl_set_bbreg(hw, 0xe30, MASKDWORD, 0x10008c1c);
-	rtl_set_bbreg(hw, 0xe34, MASKDWORD, 0x30008c1c);
-	rtl_set_bbreg(hw, 0xe38, MASKDWORD, 0x8214032a);
-	rtl_set_bbreg(hw, 0xe3c, MASKDWORD, 0x28160000);
-
-	rtl_set_bbreg(hw, 0xe4c, MASKDWORD, 0x00462911);
-	rtl_set_bbreg(hw, 0xe48, MASKDWORD, 0xf9000000);
-	rtl_set_bbreg(hw, 0xe48, MASKDWORD, 0xf8000000);
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	/* switch to path A */
+	rtl_set_bbreg(hw, 0x948, MASKDWORD, 0x00000000);
+	/* enable path A PA in TXIQK mode */
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x20000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0003f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xc7f87);
+
+	/* 1. TX IQK */
+	/* path-A IQK setting */
+	/* IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRX_IQK, MASKDWORD, 0x01004800);
+	/* path-A IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK_TONE_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTX_IQK_PI_A, MASKDWORD, 0x821403ea);
+	rtl_set_bbreg(hw, RRX_IQK_PI_A, MASKDWORD, 0x28160000);
+	rtl_set_bbreg(hw, RTX_IQK_PI_B, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_B, MASKDWORD, 0x28110000);
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x00462911);
+	/* enter IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* One shot, path A LOK & IQK */
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
 
 	mdelay(IQK_DELAY_TIME);
 
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	/* Check failed */
 	reg_eac = rtl_get_bbreg(hw, 0xeac, MASKDWORD);
 	reg_e94 = rtl_get_bbreg(hw, 0xe94, MASKDWORD);
 	reg_e9c = rtl_get_bbreg(hw, 0xe9c, MASKDWORD);
-	reg_ea4 = rtl_get_bbreg(hw, 0xea4, MASKDWORD);
 
 	if (!(reg_eac & BIT(28)) &&
 	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
 	    (((reg_e9c & 0x03FF0000) >> 16) != 0x42))
 		result |= 0x01;
+	else /* if Tx not OK, ignore Rx */
+		return result;
+
+	/* Allen 20131125 */
+	tmp = (reg_e9c & 0x03FF0000) >> 16;
+	if ((tmp & 0x200) > 0)
+		tmp = 0x400 - tmp;
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) < 0x110) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) > 0xf0) &&
+	    (tmp < 0xf))
+		result |= 0x01;
+	else /* if Tx not OK, ignore Rx */
+		return result;
+
 	return result;
 }
 
-static bool phy_similarity_cmp(struct ieee80211_hw *hw, long result[][8],
-			       u8 c1, u8 c2)
+/* bit0 = 1 => Tx OK, bit1 = 1 => Rx OK */
+static u8 _rtl8723be_phy_path_a_rx_iqk(struct ieee80211_hw *hw)
 {
-	u32 i, j, diff, simularity_bitmap, bound;
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u32 reg_eac, reg_e94, reg_e9c, reg_ea4, u32tmp, tmp;
+	u8 result = 0x00;
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	/* switch to path A */
+	rtl_set_bbreg(hw, 0x948, MASKDWORD, 0x00000000);
+
+	/* 1 Get TXIMR setting */
+	/* modify RXIQK mode table */
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, 0x80000, 0x1);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0001f);
+	/* LNA2 off, PA on for Dcut */
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7fb7);
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRX_IQK, MASKDWORD, 0x01004800);
+
+	/* path-A IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK_TONE_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTX_IQK_PI_A, MASKDWORD, 0x82160ff0);
+	rtl_set_bbreg(hw, RRX_IQK_PI_A, MASKDWORD, 0x28110000);
+	rtl_set_bbreg(hw, RTX_IQK_PI_B, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_B, MASKDWORD, 0x28110000);
+
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x0046a911);
+
+	/* enter IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* One shot, path A LOK & IQK */
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRX_POWER_AFTER_IQK_A_2, MASKDWORD);
+	reg_e94 = rtl_get_bbreg(hw, RTX_POWER_BEFORE_IQK_A, MASKDWORD);
+	reg_e9c = rtl_get_bbreg(hw, RTX_POWER_AFTER_IQK_A, MASKDWORD);
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_e9c & 0x03FF0000) >> 16) != 0x42))
+		result |= 0x01;
+	else /* if Tx not OK, ignore Rx */
+		return result;
+
+	/* Allen 20131125 */
+	tmp = (reg_e9c & 0x03FF0000) >> 16;
+	if ((tmp & 0x200) > 0)
+		tmp = 0x400 - tmp;
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) < 0x110) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) > 0xf0) &&
+	    (tmp < 0xf))
+		result |= 0x01;
+	else /* if Tx not OK, ignore Rx */
+		return result;
+
+	u32tmp = 0x80007C00 | (reg_e94 & 0x3FF0000) |
+		 ((reg_e9c & 0x3FF0000) >> 16);
+	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, u32tmp);
+
+	/* 1 RX IQK */
+	/* modify RXIQK mode table */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, 0x80000, 0x1);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0001f);
+	/* LAN2 on, PA off for Dcut */
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7d77);
+
+	/* PA, PAD setting */
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0xf80);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x55, RFREG_OFFSET_MASK, 0x4021f);
+
+	/* IQK setting */
+	rtl_set_bbreg(hw, RRX_IQK, MASKDWORD, 0x01004800);
+
+	/* path-A IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK_TONE_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RTX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTX_IQK_PI_A, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_A, MASKDWORD, 0x2816001f);
+	rtl_set_bbreg(hw, RTX_IQK_PI_B, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_B, MASKDWORD, 0x28110000);
+
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x0046a8d1);
+
+	/* enter IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* One shot, path A LOK & IQK */
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRX_POWER_AFTER_IQK_A_2, MASKDWORD);
+	reg_ea4 = rtl_get_bbreg(hw, RRX_POWER_BEFORE_IQK_A_2, MASKDWORD);
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0x780);
+
+	/* Allen 20131125 */
+	tmp = (reg_eac & 0x03FF0000) >> 16;
+		if ((tmp & 0x200) > 0)
+			tmp = 0x400 - tmp;
+	/* if Tx is OK, check whether Rx is OK */
+	if (!(reg_eac & BIT(27)) &&
+	    (((reg_ea4 & 0x03FF0000) >> 16) != 0x132) &&
+	    (((reg_eac & 0x03FF0000) >> 16) != 0x36))
+		result |= 0x02;
+	else if (!(reg_eac & BIT(27)) &&
+		 (((reg_ea4 & 0x03FF0000) >> 16) < 0x110) &&
+		 (((reg_ea4 & 0x03FF0000) >> 16) > 0xf0) &&
+		 (tmp < 0xf))
+		result |= 0x02;
+
+	return result;
+}
+
+static u8 _rtl8723be_phy_path_b_iqk(struct ieee80211_hw *hw)
+{
+	u32 reg_eac, reg_e94, reg_e9c, tmp;
+	u8 result = 0x00;
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	/* switch to path B */
+	rtl_set_bbreg(hw, 0x948, MASKDWORD, 0x00000280);
+
+	/* enable path B PA in TXIQK mode */
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xed, RFREG_OFFSET_MASK, 0x00020);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x43, RFREG_OFFSET_MASK, 0x40fc1);
+
+	/* 1 Tx IQK */
+	/* IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRX_IQK, MASKDWORD, 0x01004800);
+	/* path-A IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK_TONE_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTX_IQK_PI_A, MASKDWORD, 0x821403ea);
+	rtl_set_bbreg(hw, RRX_IQK_PI_A, MASKDWORD, 0x28110000);
+	rtl_set_bbreg(hw, RTX_IQK_PI_B, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_B, MASKDWORD, 0x28110000);
+
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x00462911);
+
+	/* enter IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* One shot, path B LOK & IQK */
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRX_POWER_AFTER_IQK_A_2, MASKDWORD);
+	reg_e94 = rtl_get_bbreg(hw, RTX_POWER_BEFORE_IQK_A, MASKDWORD);
+	reg_e9c = rtl_get_bbreg(hw, RTX_POWER_AFTER_IQK_A, MASKDWORD);
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_e9c & 0x03FF0000) >> 16) != 0x42))
+		result |= 0x01;
+	else
+		return result;
+
+	/* Allen 20131125 */
+	tmp = (reg_e9c & 0x03FF0000) >> 16;
+	if ((tmp & 0x200) > 0)
+		tmp = 0x400 - tmp;
 
-	u8 final_candidate[2] = { 0xFF, 0xFF };
-	bool bresult = true, is2t = IS_92C_SERIAL(rtlhal->version);
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) < 0x110) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) > 0xf0) &&
+	    (tmp < 0xf))
+		result |= 0x01;
+	else
+		return result;
+
+	return result;
+}
+
+/* bit0 = 1 => Tx OK, bit1 = 1 => Rx OK */
+static u8 _rtl8723be_phy_path_b_rx_iqk(struct ieee80211_hw *hw)
+{
+	u32 reg_e94, reg_e9c, reg_ea4, reg_eac, u32tmp, tmp;
+	u8 result = 0x00;
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	/* switch to path B */
+	rtl_set_bbreg(hw, 0x948, MASKDWORD, 0x00000280);
+
+	/* 1 Get TXIMR setting */
+	/* modify RXIQK mode table */
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0001f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7ff7);
+
+	/* open PA S1 & SMIXER */
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xed, RFREG_OFFSET_MASK, 0x00020);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x43, RFREG_OFFSET_MASK, 0x60fed);
+
+	/* IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRX_IQK, MASKDWORD, 0x01004800);
+
+	/* path-B IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK_TONE_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTX_IQK_PI_A, MASKDWORD, 0x82160ff0);
+	rtl_set_bbreg(hw, RRX_IQK_PI_A, MASKDWORD, 0x28110000);
+	rtl_set_bbreg(hw, RTX_IQK_PI_B, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_B, MASKDWORD, 0x28110000);
+
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x0046a911);
+	/* enter IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* One shot, path B TXIQK @ RXIQK */
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRX_POWER_AFTER_IQK_A_2, MASKDWORD);
+	reg_e94 = rtl_get_bbreg(hw, RTX_POWER_BEFORE_IQK_A, MASKDWORD);
+	reg_e9c = rtl_get_bbreg(hw, RTX_POWER_AFTER_IQK_A, MASKDWORD);
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_e9c & 0x03FF0000) >> 16) != 0x42))
+		result |= 0x01;
+	else	/* if Tx not OK, ignore Rx */
+		return result;
+
+	/* Allen 20131125 */
+	tmp = (reg_e9c & 0x03FF0000) >> 16;
+	if ((tmp & 0x200) > 0)
+		tmp = 0x400 - tmp;
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) < 0x110) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) > 0xf0) &&
+	    (tmp < 0xf))
+		result |= 0x01;
+	else
+		return result;
+
+	u32tmp = 0x80007C00 | (reg_e94 & 0x3FF0000)  |
+		 ((reg_e9c & 0x3FF0000) >> 16);
+	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, u32tmp);
+
+	/* 1 RX IQK */
+
+	/* <20121009, Kordan> RF Mode = 3 */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, 0x80000, 0x1);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0001f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7d77);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, 0x80000, 0x0);
+
+	/* open PA S1 & close SMIXER */
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xed, RFREG_OFFSET_MASK, 0x00020);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x43, RFREG_OFFSET_MASK, 0x60fbd);
+
+	/* IQK setting */
+	rtl_set_bbreg(hw, RRX_IQK, MASKDWORD, 0x01004800);
+
+	/* path-B IQK setting */
+	rtl_set_bbreg(hw, RTX_IQK_TONE_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RTX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRX_IQK_TONE_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTX_IQK_PI_A, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_A, MASKDWORD, 0x2816001f);
+	rtl_set_bbreg(hw, RTX_IQK_PI_B, MASKDWORD, 0x82110000);
+	rtl_set_bbreg(hw, RRX_IQK_PI_B, MASKDWORD, 0x28110000);
+
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x0046a8d1);
+	/* enter IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/* One shot, path B LOK & IQK */
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
 
-	if (is2t)
-		bound = 8;
+	mdelay(IQK_DELAY_TIME);
+
+	/* leave IQK mode */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRX_POWER_AFTER_IQK_A_2, MASKDWORD);
+	reg_ea4 = rtl_get_bbreg(hw, RRX_POWER_BEFORE_IQK_A_2, MASKDWORD);
+
+	/* Allen 20131125 */
+	tmp = (reg_eac & 0x03FF0000) >> 16;
+	if ((tmp & 0x200) > 0)
+		tmp = 0x400 - tmp;
+
+	/* if Tx is OK, check whether Rx is OK */
+	if (!(reg_eac & BIT(27)) &&
+	    (((reg_ea4 & 0x03FF0000) >> 16) != 0x132) &&
+	    (((reg_eac & 0x03FF0000) >> 16) != 0x36))
+		result |= 0x02;
+	else if (!(reg_eac & BIT(27)) &&
+		 (((reg_ea4 & 0x03FF0000) >> 16) < 0x110) &&
+		 (((reg_ea4 & 0x03FF0000) >> 16) > 0xf0) &&
+		 (tmp < 0xf))
+		result |= 0x02;
 	else
-		bound = 4;
+		return result;
+
+	return result;
+}
+
+static void _rtl8723be_phy_path_b_fill_iqk_matrix(struct ieee80211_hw *hw,
+						  bool b_iqk_ok,
+						  long result[][8],
+						  u8 final_candidate,
+						  bool btxonly)
+{
+	u32 oldval_1, x, tx1_a, reg;
+	long y, tx1_c;
+
+	if (final_candidate == 0xFF) {
+		return;
+	} else if (b_iqk_ok) {
+		oldval_1 = (rtl_get_bbreg(hw, ROFDM0_XBTXIQIMBALANCE,
+					  MASKDWORD) >> 22) & 0x3FF;
+		x = result[final_candidate][4];
+		if ((x & 0x00000200) != 0)
+			x = x | 0xFFFFFC00;
+		tx1_a = (x * oldval_1) >> 8;
+		rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE, 0x3FF, tx1_a);
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(27),
+			      ((x * oldval_1 >> 7) & 0x1));
+		y = result[final_candidate][5];
+		if ((y & 0x00000200) != 0)
+			y = y | 0xFFFFFC00;
+		tx1_c = (y * oldval_1) >> 8;
+		rtl_set_bbreg(hw, ROFDM0_XDTXAFE, 0xF0000000,
+			      ((tx1_c & 0x3C0) >> 6));
+		rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE, 0x003F0000,
+			      (tx1_c & 0x3F));
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(25),
+			      ((y * oldval_1 >> 7) & 0x1));
+		if (btxonly)
+			return;
+		reg = result[final_candidate][6];
+		rtl_set_bbreg(hw, ROFDM0_XBRXIQIMBALANCE, 0x3FF, reg);
+		reg = result[final_candidate][7] & 0x3F;
+		rtl_set_bbreg(hw, ROFDM0_XBRXIQIMBALANCE, 0xFC00, reg);
+		reg = (result[final_candidate][7] >> 6) & 0xF;
+		/* rtl_set_bbreg(hw, 0xca0, 0xF0000000, reg); */
+	}
+}
+
+static bool _rtl8723be_phy_simularity_compare(struct ieee80211_hw *hw,
+					      long result[][8], u8 c1, u8 c2)
+{
+	u32 i, j, diff, simularity_bitmap, bound = 0;
+
+	u8 final_candidate[2] = {0xFF, 0xFF}; /* for path A and path B */
+	bool bresult = true; /* is2t = true*/
+	s32 tmp1 = 0, tmp2 = 0;
+
+	bound = 8;
 
 	simularity_bitmap = 0;
 
 	for (i = 0; i < bound; i++) {
-		diff = (result[c1][i] > result[c2][i]) ?
-		    (result[c1][i] - result[c2][i]) :
-		    (result[c2][i] - result[c1][i]);
+		if ((i == 1) || (i == 3) || (i == 5) || (i == 7)) {
+			if ((result[c1][i] & 0x00000200) != 0)
+				tmp1 = result[c1][i] | 0xFFFFFC00;
+			else
+				tmp1 = result[c1][i];
+
+			if ((result[c2][i] & 0x00000200) != 0)
+				tmp2 = result[c2][i] | 0xFFFFFC00;
+			else
+				tmp2 = result[c2][i];
+		} else {
+			tmp1 = result[c1][i];
+			tmp2 = result[c2][i];
+		}
+
+		diff = (tmp1 > tmp2) ? (tmp1 - tmp2) : (tmp2 - tmp1);
 
 		if (diff > MAX_TOLERANCE) {
 			if ((i == 2 || i == 6) && !simularity_bitmap) {
@@ -1521,9 +2062,8 @@ static bool phy_similarity_cmp(struct ieee80211_hw *hw, long result[][8],
 					final_candidate[(i / 4)] = c1;
 				else
 					simularity_bitmap |= (1 << i);
-			} else {
+			} else
 				simularity_bitmap |= (1 << i);
-			}
 		}
 	}
 
@@ -1537,15 +2077,23 @@ static bool phy_similarity_cmp(struct ieee80211_hw *hw, long result[][8],
 			}
 		}
 		return bresult;
-	} else if (!(simularity_bitmap & 0x0F)) {
-		for (i = 0; i < 4; i++)
-			result[3][i] = result[c1][i];
-		return false;
-	} else if (!(simularity_bitmap & 0xF0) && is2t) {
-		for (i = 4; i < 8; i++)
-			result[3][i] = result[c1][i];
-		return false;
 	} else {
+		if (!(simularity_bitmap & 0x03)) { /* path A TX OK */
+			for (i = 0; i < 2; i++)
+				result[3][i] = result[c1][i];
+		}
+		if (!(simularity_bitmap & 0x0c)) { /* path A RX OK */
+			for (i = 2; i < 4; i++)
+				result[3][i] = result[c1][i];
+		}
+		if (!(simularity_bitmap & 0x30)) { /* path B TX OK */
+			for (i = 4; i < 6; i++)
+				result[3][i] = result[c1][i];
+		}
+		if (!(simularity_bitmap & 0xc0)) { /* path B RX OK */
+			for (i = 6; i < 8; i++)
+				result[3][i] = result[c1][i];
+		}
 		return false;
 	}
 }
@@ -1554,9 +2102,9 @@ static void _rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw,
 					long result[][8], u8 t, bool is2t)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 i;
-	u8 patha_ok;
+	u8 patha_ok, pathb_ok;
 	u32 adda_reg[IQK_ADDA_REG_NUM] = {
 		0x85c, 0xe6c, 0xe70, 0xe74,
 		0xe78, 0xe7c, 0xe80, 0xe84,
@@ -1571,10 +2119,12 @@ static void _rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw,
 		ROFDM0_TRXPATHENABLE, ROFDM0_TRMUXPAR,
 		RFPGA0_XCD_RFINTERFACESW, 0xb68, 0xb6c,
 		0x870, 0x860,
-		0x864, 0x800
+		0x864, 0xa04
 	};
 	const u32 retrycount = 2;
-	u32 path_sel_bb, path_sel_rf;
+
+	u32 path_sel_bb;/* path_sel_rf */
+
 	u8 tmp_reg_c50, tmp_reg_c58;
 
 	tmp_reg_c50 = rtl_get_bbreg(hw, 0xc50, MASKBYTE0);
@@ -1591,62 +2141,97 @@ static void _rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw,
 	}
 	rtl8723_phy_path_adda_on(hw, adda_reg, true, is2t);
 	if (t == 0) {
-		rtlphy->rfpi_enable = (u8) rtl_get_bbreg(hw,
+		rtlphy->rfpi_enable = (u8)rtl_get_bbreg(hw,
 						RFPGA0_XA_HSSIPARAMETER1,
 						BIT(8));
 	}
-	if (!rtlphy->rfpi_enable)
-		rtl8723_phy_pi_mode_switch(hw, true);
 
 	path_sel_bb = rtl_get_bbreg(hw, 0x948, MASKDWORD);
-	path_sel_rf = rtl_get_rfreg(hw, RF90_PATH_A, 0xb0, 0xfffff);
 
+	rtl8723_phy_mac_setting_calibration(hw, iqk_mac_reg,
+					    rtlphy->iqk_mac_backup);
 	/*BB Setting*/
-	rtl_set_bbreg(hw, 0x800, BIT(24), 0x00);
+	rtl_set_bbreg(hw, 0xa04, 0x0f000000, 0xf);
 	rtl_set_bbreg(hw, 0xc04, MASKDWORD, 0x03a05600);
 	rtl_set_bbreg(hw, 0xc08, MASKDWORD, 0x000800e4);
 	rtl_set_bbreg(hw, 0x874, MASKDWORD, 0x22204000);
 
-	rtl_set_bbreg(hw, 0x870, BIT(10), 0x01);
-	rtl_set_bbreg(hw, 0x870, BIT(26), 0x01);
-	rtl_set_bbreg(hw, 0x860, BIT(10), 0x00);
-	rtl_set_bbreg(hw, 0x864, BIT(10), 0x00);
-
-	if (is2t)
-		rtl_set_rfreg(hw, RF90_PATH_B, 0x00, MASKDWORD, 0x10000);
-	rtl8723_phy_mac_setting_calibration(hw, iqk_mac_reg,
-					    rtlphy->iqk_mac_backup);
-	rtl_set_bbreg(hw, 0xb68, MASKDWORD, 0x0f600000);
-
-	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x80800000);
-	rtl_set_bbreg(hw, 0xe40, MASKDWORD, 0x01007c00);
-	rtl_set_bbreg(hw, 0xe44, MASKDWORD, 0x81004800);
+	/* path A TX IQK */
 	for (i = 0; i < retrycount; i++) {
-		patha_ok = _rtl8723be_phy_path_a_iqk(hw, is2t);
+		patha_ok = _rtl8723be_phy_path_a_iqk(hw);
 		if (patha_ok == 0x01) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "Path A Tx IQK Success!!\n");
+				"Path A Tx IQK Success!!\n");
 			result[t][0] = (rtl_get_bbreg(hw, 0xe94, MASKDWORD) &
 					0x3FF0000) >> 16;
 			result[t][1] = (rtl_get_bbreg(hw, 0xe9c, MASKDWORD) &
 					0x3FF0000) >> 16;
 			break;
+		} else {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Path A Tx IQK Fail!!\n");
 		}
 	}
-
-	if (0 == patha_ok)
+	/* path A RX IQK */
+	for (i = 0; i < retrycount; i++) {
+		patha_ok = _rtl8723be_phy_path_a_rx_iqk(hw);
+		if (patha_ok == 0x03) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Path A Rx IQK Success!!\n");
+			result[t][2] = (rtl_get_bbreg(hw, 0xea4, MASKDWORD) &
+					0x3FF0000) >> 16;
+			result[t][3] = (rtl_get_bbreg(hw, 0xeac, MASKDWORD) &
+					0x3FF0000) >> 16;
+			break;
+		}
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 "Path A IQK Success!!\n");
+			 "Path A Rx IQK Fail!!\n");
+	}
+
+	if (0x00 == patha_ok)
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Path A IQK Fail!!\n");
+
 	if (is2t) {
-		rtl8723_phy_path_a_standby(hw);
-		rtl8723_phy_path_adda_on(hw, adda_reg, false, is2t);
+		/* path B TX IQK */
+		for (i = 0; i < retrycount; i++) {
+			pathb_ok = _rtl8723be_phy_path_b_iqk(hw);
+			if (pathb_ok == 0x01) {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "Path B Tx IQK Success!!\n");
+				result[t][4] = (rtl_get_bbreg(hw, 0xe94,
+							      MASKDWORD) &
+							      0x3FF0000) >> 16;
+				result[t][5] = (rtl_get_bbreg(hw, 0xe9c,
+							      MASKDWORD) &
+							      0x3FF0000) >> 16;
+				break;
+			}
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Path B Tx IQK Fail!!\n");
+		}
+		/* path B RX IQK */
+		for (i = 0; i < retrycount; i++) {
+			pathb_ok = _rtl8723be_phy_path_b_rx_iqk(hw);
+			if (pathb_ok == 0x03) {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "Path B Rx IQK Success!!\n");
+				result[t][6] = (rtl_get_bbreg(hw, 0xea4,
+							      MASKDWORD) &
+							      0x3FF0000) >> 16;
+				result[t][7] = (rtl_get_bbreg(hw, 0xeac,
+							      MASKDWORD) &
+							      0x3FF0000) >> 16;
+				break;
+			}
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Path B Rx IQK Fail!!\n");
+		}
 	}
 
-	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0);
+	/* Back to BB mode, load original value */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0);
 
 	if (t != 0) {
-		if (!rtlphy->rfpi_enable)
-			rtl8723_phy_pi_mode_switch(hw, false);
 		rtl8723_phy_reload_adda_registers(hw, adda_reg,
 						  rtlphy->adda_backup, 16);
 		rtl8723_phy_reload_mac_registers(hw, iqk_mac_reg,
@@ -1656,7 +2241,7 @@ static void _rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw,
 						  IQK_BB_REG_NUM);
 
 		rtl_set_bbreg(hw, 0x948, MASKDWORD, path_sel_bb);
-		rtl_set_rfreg(hw, RF90_PATH_B, 0xb0, 0xfffff, path_sel_rf);
+		/*rtl_set_rfreg(hw, RF90_PATH_B, 0xb0, 0xfffff, path_sel_rf);*/
 
 		rtl_set_bbreg(hw, 0xc50, MASKBYTE0, 0x50);
 		rtl_set_bbreg(hw, 0xc50, MASKBYTE0, tmp_reg_c50);
@@ -1670,11 +2255,33 @@ static void _rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "8723be IQK Finish!!\n");
 }
 
+static u8 _get_right_chnl_place_for_iqk(u8 chnl)
+{
+	u8 channel_all[TARGET_CHNL_NUM_2G_5G] = {
+			1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
+			13, 14, 36, 38, 40, 42, 44, 46,
+			48, 50, 52, 54, 56, 58, 60, 62, 64,
+			100, 102, 104, 106, 108, 110,
+			112, 114, 116, 118, 120, 122,
+			124, 126, 128, 130, 132, 134, 136,
+			138, 140, 149, 151, 153, 155, 157,
+			159, 161, 163, 165};
+	u8 place = chnl;
+
+	if (chnl > 14) {
+		for (place = 14; place < sizeof(channel_all); place++) {
+			if (channel_all[place] == chnl)
+				return place - 13;
+		}
+	}
+	return 0;
+}
+
 static void _rtl8723be_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmpreg;
 	u32 rf_a_mode = 0, rf_b_mode = 0, lc_cal;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	tmpreg = rtl_read_byte(rtlpriv, 0xd03);
 
@@ -1702,7 +2309,10 @@ static void _rtl8723be_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 	rtl_set_rfreg(hw, RF90_PATH_A, 0xb0, RFREG_OFFSET_MASK, 0xdfbe0);
 	rtl_set_rfreg(hw, RF90_PATH_A, 0x18, MASK12BITS, 0x8c0a);
 
-	mdelay(100);
+	/* In order not to disturb BT music when wifi init.(1ant NIC only) */
+	/*mdelay(100);*/
+	/* In order not to disturb BT music when wifi init.(1ant NIC only) */
+	mdelay(50);
 
 	rtl_set_rfreg(hw, RF90_PATH_A, 0xb0, RFREG_OFFSET_MASK, 0xdffe0);
 
@@ -1716,68 +2326,34 @@ static void _rtl8723be_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 	} else {
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
+RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
+
 }
 
 static void _rtl8723be_phy_set_rfpath_switch(struct ieee80211_hw *hw,
 					     bool bmain, bool is2t)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
 
-	if (is_hal_stop(rtlhal)) {
-		u8 u1btmp;
-		u1btmp = rtl_read_byte(rtlpriv, REG_LEDCFG0);
-		rtl_write_byte(rtlpriv, REG_LEDCFG0, u1btmp | BIT(7));
-		rtl_set_bbreg(hw, RFPGA0_XAB_RFPARAMETER, BIT(13), 0x01);
-	}
-	if (is2t) {
-		if (bmain)
-			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
-				      BIT(5) | BIT(6), 0x1);
-		else
-			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
-				      BIT(5) | BIT(6), 0x2);
-	} else {
-		rtl_set_bbreg(hw, RFPGA0_XAB_RFINTERFACESW, BIT(8) | BIT(9), 0);
-		rtl_set_bbreg(hw, 0x914, MASKLWORD, 0x0201);
-
-		/* We use the RF definition of MAIN and AUX,
-		 * left antenna and right antenna repectively.
-		 * Default output at AUX.
-		 */
-		if (bmain) {
-			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE,
-				      BIT(14) | BIT(13) | BIT(12), 0);
-			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
-				      BIT(5) | BIT(4) | BIT(3), 0);
-			if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
-				rtl_set_bbreg(hw, CONFIG_RAM64X16, BIT(31), 0);
-		} else {
-			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE,
-				      BIT(14) | BIT(13) | BIT(12), 1);
-			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
-				      BIT(5) | BIT(4) | BIT(3), 1);
-			if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
-				rtl_set_bbreg(hw, CONFIG_RAM64X16, BIT(31), 1);
-		}
-	}
+	if (bmain) /* left antenna */
+		rtl_set_bbreg(hw, 0x92C, MASKDWORD, 0x1);
+	else
+		rtl_set_bbreg(hw, 0x92C, MASKDWORD, 0x2);
 }
 
 #undef IQK_ADDA_REG_NUM
 #undef IQK_DELAY_TIME
-
-void rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
+/* IQK is merge from Merge Temp */
+void rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	long result[4][8];
-	u8 i, final_candidate;
-	bool patha_ok, pathb_ok;
-	long reg_e94, reg_e9c, reg_ea4, reg_eac, reg_eb4, reg_ebc, reg_ec4,
-	    reg_ecc, reg_tmp = 0;
+	u8 i, final_candidate, idx;
+	bool b_patha_ok, b_pathb_ok;
+	long reg_e94, reg_e9c, reg_ea4, reg_eac, reg_eb4, reg_ebc, reg_ec4;
+	long reg_ecc, reg_tmp = 0;
 	bool is12simular, is13simular, is23simular;
 	u32 iqk_bb_reg[9] = {
 		ROFDM0_XARXIQIMBALANCE,
@@ -1790,12 +2366,23 @@ void rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		ROFDM0_XDTXAFE,
 		ROFDM0_RXIQEXTANTA
 	};
+	u32 path_sel_bb = 0; /* path_sel_rf = 0 */
 
-	if (recovery) {
+	if (rtlphy->lck_inprogress)
+		return;
+
+	spin_lock(&rtlpriv->locks.iqk_lock);
+	rtlphy->lck_inprogress = true;
+	spin_unlock(&rtlpriv->locks.iqk_lock);
+
+	if (b_recovery) {
 		rtl8723_phy_reload_adda_registers(hw, iqk_bb_reg,
 						  rtlphy->iqk_bb_backup, 9);
 		return;
 	}
+	/* Save RF Path */
+	path_sel_bb = rtl_get_bbreg(hw, 0x948, MASKDWORD);
+	/* path_sel_rf = rtl_get_rfreg(hw, RF90_PATH_A, 0xb0, 0xfffff); */
 
 	for (i = 0; i < 8; i++) {
 		result[0][i] = 0;
@@ -1804,30 +2391,33 @@ void rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		result[3][i] = 0;
 	}
 	final_candidate = 0xff;
-	patha_ok = false;
-	pathb_ok = false;
+	b_patha_ok = false;
+	b_pathb_ok = false;
 	is12simular = false;
 	is23simular = false;
 	is13simular = false;
 	for (i = 0; i < 3; i++) {
-		if (get_rf_type(rtlphy) == RF_2T2R)
-			_rtl8723be_phy_iq_calibrate(hw, result, i, true);
-		else
-			_rtl8723be_phy_iq_calibrate(hw, result, i, false);
+		_rtl8723be_phy_iq_calibrate(hw, result, i, true);
 		if (i == 1) {
-			is12simular = phy_similarity_cmp(hw, result, 0, 1);
+			is12simular = _rtl8723be_phy_simularity_compare(hw,
+									result,
+									0, 1);
 			if (is12simular) {
 				final_candidate = 0;
 				break;
 			}
 		}
 		if (i == 2) {
-			is13simular = phy_similarity_cmp(hw, result, 0, 2);
+			is13simular = _rtl8723be_phy_simularity_compare(hw,
+									result,
+									0, 2);
 			if (is13simular) {
 				final_candidate = 0;
 				break;
 			}
-			is23simular = phy_similarity_cmp(hw, result, 1, 2);
+			is23simular = _rtl8723be_phy_simularity_compare(hw,
+									result,
+									1, 2);
 			if (is23simular) {
 				final_candidate = 1;
 			} else {
@@ -1864,32 +2454,48 @@ void rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		rtlphy->reg_ebc = reg_ebc;
 		reg_ec4 = result[final_candidate][6];
 		reg_ecc = result[final_candidate][7];
-		patha_ok = true;
-		pathb_ok = true;
+		b_patha_ok = true;
+		b_pathb_ok = true;
 	} else {
 		rtlphy->reg_e94 = 0x100;
 		rtlphy->reg_eb4 = 0x100;
 		rtlphy->reg_e9c = 0x0;
 		rtlphy->reg_ebc = 0x0;
 	}
-	if (reg_e94 != 0) /*&&(reg_ea4 != 0) */
-		rtl8723_phy_path_a_fill_iqk_matrix(hw, patha_ok, result,
+	if (reg_e94 != 0)
+		rtl8723_phy_path_a_fill_iqk_matrix(hw, b_patha_ok, result,
 						   final_candidate,
 						   (reg_ea4 == 0));
-	if (final_candidate != 0xFF) {
+	if (reg_eb4 != 0)
+		_rtl8723be_phy_path_b_fill_iqk_matrix(hw, b_pathb_ok, result,
+						      final_candidate,
+						      (reg_ec4 == 0));
+
+	idx = _get_right_chnl_place_for_iqk(rtlphy->current_channel);
+
+	if (final_candidate < 4) {
 		for (i = 0; i < IQK_MATRIX_REG_NUM; i++)
-			rtlphy->iqk_matrix[0].value[0][i] =
+			rtlphy->iqk_matrix[idx].value[0][i] =
 						result[final_candidate][i];
-		rtlphy->iqk_matrix[0].iqk_done = true;
+		rtlphy->iqk_matrix[idx].iqk_done = true;
+
 	}
-	rtl8723_save_adda_registers(hw, iqk_bb_reg, rtlphy->iqk_bb_backup, 9);
+	rtl8723_save_adda_registers(hw, iqk_bb_reg,
+				    rtlphy->iqk_bb_backup, 9);
+
+	rtl_set_bbreg(hw, 0x948, MASKDWORD, path_sel_bb);
+	/* rtl_set_rfreg(hw, RF90_PATH_A, 0xb0, 0xfffff, path_sel_rf); */
+
+	spin_lock(&rtlpriv->locks.iqk_lock);
+	rtlphy->lck_inprogress = false;
+	spin_unlock(&rtlpriv->locks.iqk_lock);
 }
 
 void rtl8723be_phy_lc_calibrate(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct rtl_hal *rtlhal = &(rtlpriv->rtlhal);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct rtl_hal *rtlhal = &rtlpriv->rtlhal;
 	u32 timeout = 2000, timecount = 0;
 
 	while (rtlpriv->mac80211.act_scanning && timecount < timeout) {
@@ -1898,68 +2504,25 @@ void rtl8723be_phy_lc_calibrate(struct ieee80211_hw *hw)
 	}
 
 	rtlphy->lck_inprogress = true;
-	RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,
 		"LCK:Start!!! currentband %x delay %d ms\n",
-		rtlhal->current_bandtype, timecount);
+		 rtlhal->current_bandtype, timecount);
 
 	_rtl8723be_phy_lc_calibrate(hw, false);
 
 	rtlphy->lck_inprogress = false;
 }
 
-void rtl23b_phy_ap_calibrate(struct ieee80211_hw *hw, char delta)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-
-	if (rtlphy->apk_done)
-		return;
-
-	return;
-}
-
 void rtl8723be_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain)
 {
-	_rtl8723be_phy_set_rfpath_switch(hw, bmain, false);
-}
-
-static void rtl8723be_phy_set_io(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
-		  rtlphy->current_io_type, rtlphy->set_io_inprogress);
-	switch (rtlphy->current_io_type) {
-	case IO_CMD_RESUME_DM_BY_SCAN:
-		rtlpriv->dm_digtable.cur_igvalue =
-				 rtlphy->initgain_backup.xaagccore1;
-		/*rtl92c_dm_write_dig(hw);*/
-		rtl8723be_phy_set_txpower_level(hw, rtlphy->current_channel);
-		rtl_set_bbreg(hw, RCCK0_CCA, 0xff0000, 0x83);
-		break;
-	case IO_CMD_PAUSE_DM_BY_SCAN:
-		rtlphy->initgain_backup.xaagccore1 =
-				 rtlpriv->dm_digtable.cur_igvalue;
-		rtlpriv->dm_digtable.cur_igvalue = 0x17;
-		rtl_set_bbreg(hw, RCCK0_CCA, 0xff0000, 0x40);
-		break;
-	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
-	}
-	rtlphy->set_io_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 "(%#x)\n", rtlphy->current_io_type);
+	_rtl8723be_phy_set_rfpath_switch(hw, bmain, true);
 }
 
 bool rtl8723be_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	bool postprocessing = false;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	bool b_postprocessing = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 		 "-->IO Cmd(%#x), set_io_inprogress(%d)\n",
@@ -1969,20 +2532,20 @@ bool rtl8723be_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 		case IO_CMD_RESUME_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 				 "[IO CMD] Resume DM after scan.\n");
-			postprocessing = true;
+			b_postprocessing = true;
 			break;
-		case IO_CMD_PAUSE_DM_BY_SCAN:
+		case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 				 "[IO CMD] Pause DM before scan.\n");
-			postprocessing = true;
+			b_postprocessing = true;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 				 "switch case not process\n");
 			break;
 		}
 	} while (false);
-	if (postprocessing && !rtlphy->set_io_inprogress) {
+	if (b_postprocessing && !rtlphy->set_io_inprogress) {
 		rtlphy->set_io_inprogress = true;
 		rtlphy->current_io_type = iotype;
 	} else {
@@ -1993,6 +2556,37 @@ bool rtl8723be_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 	return true;
 }
 
+static void rtl8723be_phy_set_io(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
+		  rtlphy->current_io_type, rtlphy->set_io_inprogress);
+	switch (rtlphy->current_io_type) {
+	case IO_CMD_RESUME_DM_BY_SCAN:
+		dm_digtable->cur_igvalue = rtlphy->initgain_backup.xaagccore1;
+		/*rtl92c_dm_write_dig(hw);*/
+		rtl8723be_phy_set_txpower_level(hw, rtlphy->current_channel);
+		rtl_set_bbreg(hw, RCCK0_CCA, 0xff0000, 0x83);
+		break;
+	case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
+		rtlphy->initgain_backup.xaagccore1 = dm_digtable->cur_igvalue;
+		dm_digtable->cur_igvalue = 0x17;
+		rtl_set_bbreg(hw, RCCK0_CCA, 0xff0000, 0x40);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
+		break;
+	}
+	rtlphy->set_io_inprogress = false;
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "(%#x)\n", rtlphy->current_io_type);
+}
+
 static void rtl8723be_phy_set_rf_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -2028,15 +2622,15 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 	switch (rfpwr_state) {
 	case ERFON:
 		if ((ppsc->rfpwr_state == ERFOFF) &&
-		    RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC)) {
+		     RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC)) {
 			bool rtstatus;
-			u32 initialize_count = 0;
+			u32 initializecount = 0;
 			do {
-				initialize_count++;
+				initializecount++;
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
-			} while (!rtstatus && (initialize_count < 10));
+			} while (!rtstatus && (initializecount < 10));
 				RT_CLEAR_PS_LEVEL(ppsc,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
@@ -2051,28 +2645,33 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 			rtlpriv->cfg->ops->led_control(hw, LED_CTL_LINK);
 		else
 			rtlpriv->cfg->ops->led_control(hw, LED_CTL_NO_LINK);
+
 		break;
+
 	case ERFOFF:
 		for (queue_id = 0, i = 0;
 		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
 			ring = &pcipriv->dev.tx_ring[queue_id];
-			if (skb_queue_len(&ring->queue) == 0) {
+			/* Don't check BEACON Q.
+			 * BEACON Q is always not empty,
+			 * because '_rtl8723be_cmd_send_packet'
+			 */
+			if (queue_id == BEACON_QUEUE ||
+			    skb_queue_len(&ring->queue) == 0) {
 				queue_id++;
 				continue;
 			} else {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "eRf Off/Sleep: %d times "
-					  "TcbBusyQueue[%d] =%d before "
-					  "doze!\n", (i + 1), queue_id,
-					  skb_queue_len(&ring->queue));
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+					 (i + 1), queue_id,
+					 skb_queue_len(&ring->queue));
 
 				udelay(10);
 				i++;
 			}
 			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "\n ERFSLEEP: %d times "
-					  "TcbBusyQueue[%d] = %d !\n",
+					 "ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
 					  MAX_DOZE_WAITING_TIMES_9x,
 					  queue_id,
 					  skb_queue_len(&ring->queue));
@@ -2095,6 +2694,7 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 			}
 		}
 		break;
+
 	case ERFSLEEP:
 		if (ppsc->rfpwr_state == ERFOFF)
 			break;
@@ -2106,21 +2706,19 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				continue;
 			} else {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "eRf Off/Sleep: %d times "
-					  "TcbBusyQueue[%d] =%d before "
-					  "doze!\n", (i + 1), queue_id,
-					  skb_queue_len(&ring->queue));
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+					 (i + 1), queue_id,
+					 skb_queue_len(&ring->queue));
 
 				udelay(10);
 				i++;
 			}
 			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "\n ERFSLEEP: %d times "
-					  "TcbBusyQueue[%d] = %d !\n",
-					  MAX_DOZE_WAITING_TIMES_9x,
-					  queue_id,
-					  skb_queue_len(&ring->queue));
+					 "ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+					 MAX_DOZE_WAITING_TIMES_9x,
+					 queue_id,
+					 skb_queue_len(&ring->queue));
 				break;
 			}
 		}
@@ -2131,8 +2729,9 @@ static bool _rtl8723be_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		ppsc->last_sleep_jiffies = jiffies;
 		_rtl8723be_phy_set_rf_sleep(hw);
 		break;
+
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "switch case not process\n");
 		bresult = false;
 		break;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/phy.h b/drivers/net/wireless/rtlwifi/rtl8723be/phy.h
index 444ef95..6339738 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/phy.h
@@ -26,22 +26,28 @@
 #ifndef __RTL8723BE_PHY_H__
 #define __RTL8723BE_PHY_H__
 
-/*It must always set to 4, otherwise read efuse table secquence will be wrong.*/
+/* MAX_TX_COUNT must always set to 4, otherwise read efuse table sequence
+ * will be wrong.
+ */
 #define MAX_TX_COUNT		4
 #define	TX_1S			0
 #define	TX_2S			1
+#define	TX_3S			2
+#define	TX_4S			3
 
 #define	MAX_POWER_INDEX		0x3F
 
 #define MAX_PRECMD_CNT			16
 #define MAX_RFDEPENDCMD_CNT		16
-#define MAX_POSTCMD_CNT		16
+#define MAX_POSTCMD_CNT			16
 
 #define MAX_DOZE_WAITING_TIMES_9x	64
 
 #define RT_CANNOT_IO(hw)		false
 #define HIGHPOWER_RADIOA_ARRAYLEN	22
 
+#define TARGET_CHNL_NUM_2G_5G		59
+
 #define IQK_ADDA_REG_NUM		16
 #define IQK_BB_REG_NUM			9
 #define MAX_TOLERANCE			5
@@ -83,104 +89,19 @@
 
 #define RTL92C_MAX_PATH_NUM			2
 
-enum hw90_block_e {
-	HW90_BLOCK_MAC = 0,
-	HW90_BLOCK_PHY0 = 1,
-	HW90_BLOCK_PHY1 = 2,
-	HW90_BLOCK_RF = 3,
-	HW90_BLOCK_MAXIMUM = 4,
-};
-
 enum baseband_config_type {
 	BASEBAND_CONFIG_PHY_REG = 0,
 	BASEBAND_CONFIG_AGC_TAB = 1,
 };
 
-enum ra_offset_area {
-	RA_OFFSET_LEGACY_OFDM1,
-	RA_OFFSET_LEGACY_OFDM2,
-	RA_OFFSET_HT_OFDM1,
-	RA_OFFSET_HT_OFDM2,
-	RA_OFFSET_HT_OFDM3,
-	RA_OFFSET_HT_OFDM4,
-	RA_OFFSET_HT_CCK,
-};
-
-enum antenna_path {
-	ANTENNA_NONE,
-	ANTENNA_D,
-	ANTENNA_C,
-	ANTENNA_CD,
-	ANTENNA_B,
-	ANTENNA_BD,
-	ANTENNA_BC,
-	ANTENNA_BCD,
-	ANTENNA_A,
-	ANTENNA_AD,
-	ANTENNA_AC,
-	ANTENNA_ACD,
-	ANTENNA_AB,
-	ANTENNA_ABD,
-	ANTENNA_ABC,
-	ANTENNA_ABCD
-};
-
-struct r_antenna_select_ofdm {
-	u32 r_tx_antenna:4;
-	u32 r_ant_l:4;
-	u32 r_ant_non_ht:4;
-	u32 r_ant_ht1:4;
-	u32 r_ant_ht2:4;
-	u32 r_ant_ht_s1:4;
-	u32 r_ant_non_ht_s1:4;
-	u32 ofdm_txsc:2;
-	u32 reserved:2;
-};
-
-struct r_antenna_select_cck {
-	u8 r_cckrx_enable_2:2;
-	u8 r_cckrx_enable:2;
-	u8 r_ccktx_enable:4;
-};
-
-
-struct efuse_contents {
-	u8 mac_addr[ETH_ALEN];
-	u8 cck_tx_power_idx[6];
-	u8 ht40_1s_tx_power_idx[6];
-	u8 ht40_2s_tx_power_idx_diff[3];
-	u8 ht20_tx_power_idx_diff[3];
-	u8 ofdm_tx_power_idx_diff[3];
-	u8 ht40_max_power_offset[3];
-	u8 ht20_max_power_offset[3];
-	u8 channel_plan;
-	u8 thermal_meter;
-	u8 rf_option[5];
-	u8 version;
-	u8 oem_id;
-	u8 regulatory;
-};
-
-struct tx_power_struct {
-	u8 cck[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 ht40_1s[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 ht40_2s[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 ht20_diff[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 legacy_ht_diff[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 legacy_ht_txpowerdiff;
-	u8 groupht20[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 groupht40[RTL92C_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
-	u8 pwrgroup_cnt;
-	u32 mcs_original_offset[4][16];
-};
-
-enum _ANT_DIV_TYPE {
-	NO_ANTDIV				= 0xFF,
-	CG_TRX_HW_ANTDIV		= 0x01,
-	CGCS_RX_HW_ANTDIV		= 0x02,
+enum ant_div_type {
+	NO_ANTDIV		= 0xFF,
+	CG_TRX_HW_ANTDIV	= 0x01,
+	CGCS_RX_HW_ANTDIV	= 0x02,
 	FIXED_HW_ANTDIV         = 0x03,
-	CG_TRX_SMART_ANTDIV		= 0x04,
-	CGCS_RX_SW_ANTDIV		= 0x05,
+	CG_TRX_SMART_ANTDIV	= 0x04,
+	CGCS_RX_SW_ANTDIV	= 0x05,
+
 };
 
 u32 rtl8723be_phy_query_rf_reg(struct ieee80211_hw *hw,
@@ -206,7 +127,6 @@ void rtl8723be_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 u8 rtl8723be_phy_sw_chnl(struct ieee80211_hw *hw);
 void rtl8723be_phy_iq_calibrate(struct ieee80211_hw *hw,
 				bool b_recovery);
-void rtl23b_phy_ap_calibrate(struct ieee80211_hw *hw, char delta);
 void rtl8723be_phy_lc_calibrate(struct ieee80211_hw *hw);
 void rtl8723be_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
 bool rtl8723be_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
index a62f43e..0fee5e0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
@@ -26,7 +26,9 @@
 #ifndef __RTL8723BE_PWRSEQ_H__
 #define __RTL8723BE_PWRSEQ_H__
 
-/*	Check document WM-20130425-JackieLau-RTL8723B_Power_Architecture v05.vsd
+#include "../pwrseqcmd.h"
+/**
+ *	Check document WM-20130425-JackieLau-RTL8723B_Power_Architecture v05.vsd
  *	There are 6 HW Power States:
  *	0: POFF--Power Off
  *	1: PDN--Power Down
@@ -35,7 +37,7 @@
  *	4: LPS--Low Power State
  *	5: SUS--Suspend
  *
- *	The transition from different states are defined below
+ *	The transision from different states are defined below
  *	TRANS_CARDEMU_TO_ACT
  *	TRANS_ACT_TO_CARDEMU
  *	TRANS_CARDEMU_TO_SUS
@@ -57,203 +59,320 @@
 #define	RTL8723B_TRANS_END_STEPS		1
 
 #define RTL8723B_TRANS_CARDEMU_TO_ACT					\
+	/* format */							\
+	/* comments here */						\
+	/* {offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value}, */\
+	/*0x20[0] = 1b'1 enable LDOA12 MACRO block for all interface*/  \
 	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/*0x67[0] = 0 to disable BT_GPS_SEL pins*/			\
 	{0x0067, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	/*Delay 1ms*/							\
 	{0x0001, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
 	 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 1, PWRSEQ_DELAY_MS},		\
+	/*0x00[5] = 1b'0 release analog Ips to digital ,1:isolation*/   \
 	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), 0},			\
+	/* disable SW LPS 0x04[10]=0 and WLSUS_EN 0x04[11]=0*/		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)|BIT(2)), 0},	\
+	/* Disable USB suspend */					\
 	{0x0075, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0) , 0},			\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0) , BIT(0)},		\
+	/* wait till 0x04[17] = 1    power ready*/			\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	/* Enable USB suspend */					\
 	{0x0075, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0) , BIT(0)},		\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0) , 0},			\
+	/* release WLON reset  0x04[16]=1*/				\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/* disable HWPDN 0x04[15]=0*/					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},			\
+	/* disable WL suspend*/						\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)), 0},		\
+	/* polling until return 0*/					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0},			\
+	/* Enable WL control XTAL setting*/				\
 	{0x0010, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6), BIT(6)},		\
+	/*Enable falling edge triggering interrupt*/			\
 	{0x0049, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	/*Enable GPIO9 interrupt mode*/					\
 	{0x0063, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	/*Enable GPIO9 input mode*/					\
 	{0x0062, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	/*Enable HSISR GPIO[C:0] interrupt*/				\
 	{0x0058, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/*Enable HSISR GPIO9 interrupt*/				\
 	{0x005A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	/*For GPIO9 internal pull high setting by test chip*/		\
 	{0x0068, PWR_CUT_TESTCHIP_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3), BIT(3)},		\
+	/*For GPIO9 internal pull high setting*/			\
 	{0x0069, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6), BIT(6)},
 
 #define RTL8723B_TRANS_ACT_TO_CARDEMU					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*0x1F[7:0] = 0 turn off RF*/					\
 	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},			\
+	/*0x4C[24] = 0x4F[0] = 0, */					\
+	/*switch DPDT_SEL_P output from register 0x65[2] */		\
 	{0x004F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	/*Enable rising edge triggering interrupt*/			\
 	{0x0049, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	 /*0x04[9] = 1 turn off MAC by HW state machine*/		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	 /*wait till 0x04[9] = 0 polling until return 0 to disable*/	\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0},			\
+	/* Enable BT control XTAL setting*/				\
 	{0x0010, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6), 0},			\
+	/*0x00[5] = 1b'1 analog Ips to digital ,1:isolation*/		\
 	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
 	 PWR_CMD_WRITE, BIT(5), BIT(5)},				\
+	/*0x20[0] = 1b'0 disable LDOA12 MACRO block*/			\
 	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
 	 PWR_CMD_WRITE, BIT(0), 0},
 
 #define RTL8723B_TRANS_CARDEMU_TO_SUS					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4) | BIT(3), (BIT(4) | BIT(3))}, \
+	/*0x04[12:11] = 2b'01 enable WL suspend*/			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
 	 PWR_CMD_WRITE, BIT(3) | BIT(4), BIT(3)},			\
+	/*0x23[4] = 1b'1 12H LDO enter sleep mode*/			\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	/*0x07[7:0] = 0x20 SDIO SOP option to disable BG/MB/ACK/SWR*/   \
 	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20},			\
+	/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(4), BIT(3) | BIT(4)},\
+	/*Set SDIO suspend local register*/				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/*wait power state to suspend*/					\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0},
 
 #define RTL8723B_TRANS_SUS_TO_CARDEMU					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*clear suspend enable and power down enable*/			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(7), 0},		\
+	/*Set SDIO suspend local register*/				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},			\
+	/*wait power state to suspend*/					\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	/*0x23[4] = 1b'0 12H LDO enter normal mode*/			\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	/*0x04[12:11] = 2b'01enable WL suspend*/			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},
 
 #define RTL8723B_TRANS_CARDEMU_TO_CARDDIS				\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*0x07=0x20 , SOP option to disable BG/MB*/			\
 	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20},			\
+	/*0x04[12:11] = 2b'01 enable WL suspend*/			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},	\
+	/*0x04[10] = 1, enable SW LPS*/					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), BIT(2)},		\
+	/*0x48[16] = 1 to enable GPIO9 as EXT WAKEUP*/			\
 	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 1},			\
+	/*0x23[4] = 1b'1 12H LDO enter sleep mode*/			\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	/*Set SDIO suspend local register*/				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/*wait power state to suspend*/					\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0},
 
 #define RTL8723B_TRANS_CARDDIS_TO_CARDEMU				\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*clear suspend enable and power down enable*/			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(7), 0},		\
+	/*Set SDIO suspend local register*/				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},			\
+	/*wait power state to suspend*/					\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	/*0x48[16] = 0 to disable GPIO9 as EXT WAKEUP*/			\
 	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	/*0x04[12:11] = 2b'01enable WL suspend*/			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},		\
+	/*0x23[4] = 1b'0 12H LDO enter normal mode*/			\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	/*PCIe DMA start*/						\
 	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},
 
 #define RTL8723B_TRANS_CARDEMU_TO_PDN					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*0x23[4] = 1b'1 12H LDO enter sleep mode*/			\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	/*0x07[7:0] = 0x20 SOP option to disable BG/MB/ACK/SWR*/	\
 	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	 PWR_INTF_SDIO_MSK | PWR_INTF_USB_MSK, PWR_BASEADDR_MAC,	\
 	 PWR_CMD_WRITE, 0xFF, 0x20},					\
+	/* 0x04[16] = 0*/						\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	/* 0x04[15] = 1*/						\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)},
 
 #define RTL8723B_TRANS_PDN_TO_CARDEMU					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/* 0x04[15] = 0*/						\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},
 
 #define RTL8723B_TRANS_ACT_TO_LPS					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*PCIe DMA stop*/						\
 	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	/*Tx Pause*/							\
 	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	/*Should be zero if no packet is transmitting*/			\
 	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	/*Should be zero if no packet is transmitting*/			\
 	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	/*Should be zero if no packet is transmitting*/			\
 	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	/*Should be zero if no packet is transmitting*/			\
 	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	/*CCK and OFDM are disabled,and clock are gated*/		\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	/*Delay 1us*/							\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},		\
+	/*Whole BB is reset*/						\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	/*Reset MAC TRX*/						\
 	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x03},			\
+	/*check if removed later*/					\
 	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	/*When driver enter Sus/ Disable, enable LOP for BT*/		\
 	{0x0093, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00},			\
+	/*Respond TxOK to scheduler*/					\
 	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), BIT(5)},
 
 #define RTL8723B_TRANS_LPS_TO_ACT					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	/*SDIO RPWM*/							\
 	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84},		\
+	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84},			\
+	/*USB RPWM*/							\
 	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84},			\
+	/*PCIe RPWM*/							\
 	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84},			\
+	/*Delay*/							\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS},		\
+	/*.	0x08[4] = 0		 switch TSF to 40M*/		\
 	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	/*Polling 0x109[7]=0  TSF in 40M*/				\
 	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0},		\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0},			\
+	/*.	0x29[7:6] = 2b'00	 enable BB clock*/		\
 	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6)|BIT(7), 0},		\
+	/*.	0x101[1] = 1*/						\
 	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	/*.	0x100[7:0] = 0xFF	 enable WMAC TRX*/		\
 	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	/*.	0x02[1:0] = 2b'11	 enable BB macro*/		\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1) | BIT(0), BIT(1) | BIT(0)}, \
+	/*.	0x522 = 0*/						\
 	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},
 
 #define RTL8723B_TRANS_END						\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
 	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, 0,	\
 	 PWR_CMD_END, 0, 0},
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/reg.h b/drivers/net/wireless/rtlwifi/rtl8723be/reg.h
index 3006849..03581d2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/reg.h
@@ -78,11 +78,11 @@
 #define REG_WOL_EVENT				0x0081
 #define REG_MCUTSTCFG				0x0084
 
-
 #define REG_HIMR				0x00B0
 #define REG_HISR				0x00B4
 #define REG_HIMRE				0x00B8
 #define REG_HISRE				0x00BC
+#define REG_PMC_DBG_CTRL2			0x00CC
 
 #define REG_EFUSE_ACCESS			0x00CF
 
@@ -95,7 +95,8 @@
 #define REG_HPON_FSM				0x00EC
 #define REG_SYS_CFG				0x00F0
 #define REG_GPIO_OUTSTS				0x00F4
-#define REG_SYS_CFG1				0x00F0
+#define REG_MAC_PHY_CTRL_NORMAL			0x00F8
+#define REG_SYS_CFG1				0x00FC
 #define REG_ROM_VERSION				0x00FD
 
 #define REG_CR					0x0100
@@ -170,8 +171,14 @@
 #define	REG_BKQ_DESA				0x0338
 #define	REG_RX_DESA				0x0340
 
-#define	REG_DBI					0x0348
-#define	REG_MDIO				0x0354
+#define	REG_DBI_WDATA				0x0348
+#define	REG_DBI_RDATA				0x034C
+#define	REG_DBI_CTRL				0x0350
+#define	REG_DBI_ADDR				0x0350
+#define	REG_DBI_FLAG				0x0352
+#define	REG_MDIO_WDATA				0x0354
+#define	REG_MDIO_RDATA				0x0356
+#define	REG_MDIO_CTL				0x0358
 #define	REG_DBG_SEL				0x0360
 #define	REG_PCIE_HRPWM				0x0361
 #define	REG_PCIE_HCPWM				0x0363
@@ -180,7 +187,6 @@
 #define	REG_UART_TX_DESA			0x0370
 #define	REG_UART_RX_DESA			0x0378
 
-
 #define	REG_HDAQ_DESA_NODEF			0x0000
 #define	REG_CMDQ_DESA_NODEF			0x0000
 
@@ -193,7 +199,6 @@
 #define REG_BCNQ_INFORMATION			0x0418
 #define REG_TXPKT_EMPTY				0x041A
 
-
 #define REG_CPU_MGQ_INFORMATION			0x041C
 #define REG_FWHW_TXQ_CTRL			0x0420
 #define REG_HWSEQ_CTRL				0x0423
@@ -207,9 +212,7 @@
 #define REG_RARFRC				0x0438
 #define REG_RRSR				0x0440
 #define REG_ARFR0				0x0444
-#define REG_ARFR1				0x0448
-#define REG_ARFR2				0x044C
-#define REG_ARFR3				0x0450
+#define REG_ARFR1				0x044C
 #define REG_AMPDU_MAX_TIME			0x0456
 #define REG_AGGLEN_LMT				0x0458
 #define REG_AMPDU_MIN_SPACE			0x045C
@@ -223,7 +226,10 @@
 #define REG_POWER_STAGE2			0x04B8
 #define REG_PKT_LIFE_TIME			0x04C0
 #define REG_STBC_SETTING			0x04C4
+#define REG_HT_SINGLE_AMPDU			0x04C7
+
 #define REG_PROT_MODE_CTRL			0x04C8
+#define REG_MAX_AGGR_NUM			0x04CA
 #define REG_BAR_MODE_CTRL			0x04CC
 #define REG_RA_TRY_RATE_AGG_LMT			0x04CF
 #define REG_EARLY_MODE_CONTROL			0x04D0
@@ -303,6 +309,7 @@
 #define REG_EIFS				0x0642
 
 #define REG_NAV_CTRL				0x0650
+#define	REG_NAV_UPPER				0x0652
 #define REG_BACAMCMD				0x0654
 #define REG_BACAMCONTENT			0x0658
 #define REG_LBDLY				0x0660
@@ -355,43 +362,43 @@
 #define REG_NORMAL_SIE_MAC_ADDR			0xFE70
 #define REG_NORMAL_SIE_STRING			0xFE80
 
-#define	CR9346					REG_9346CR
-#define	MSR					(REG_CR + 2)
-#define	ISR					REG_HISR
-#define	TSFR					REG_TSFTR
+#define	CR9346				REG_9346CR
+#define	MSR				(REG_CR + 2)
+#define	ISR				REG_HISR
+#define	TSFR				REG_TSFTR
 
-#define	MACIDR0					REG_MACID
-#define	MACIDR4					(REG_MACID + 4)
+#define	MACIDR0				REG_MACID
+#define	MACIDR4				(REG_MACID + 4)
 
-#define PBP					REG_PBP
+#define PBP				REG_PBP
 
-#define	IDR0					MACIDR0
-#define	IDR4					MACIDR4
+#define	IDR0				MACIDR0
+#define	IDR4				MACIDR4
 
-#define	UNUSED_REGISTER				0x1BF
-#define	DCAM					UNUSED_REGISTER
-#define	PSR					UNUSED_REGISTER
-#define BBADDR					UNUSED_REGISTER
-#define	PHYDATAR				UNUSED_REGISTER
+#define	UNUSED_REGISTER			0x1BF
+#define	DCAM				UNUSED_REGISTER
+#define	PSR				UNUSED_REGISTER
+#define BBADDR				UNUSED_REGISTER
+#define	PHYDATAR			UNUSED_REGISTER
 
-#define	INVALID_BBRF_VALUE			0x12345678
+#define	INVALID_BBRF_VALUE		0x12345678
 
-#define	MAX_MSS_DENSITY_2T			0x13
-#define	MAX_MSS_DENSITY_1T			0x0A
+#define	MAX_MSS_DENSITY_2T		0x13
+#define	MAX_MSS_DENSITY_1T		0x0A
 
-#define	CMDEEPROM_EN				BIT(5)
-#define	CMDEEPROM_SEL				BIT(4)
-#define	CMD9346CR_9356SEL			BIT(4)
-#define	AUTOLOAD_EEPROM				(CMDEEPROM_EN | CMDEEPROM_SEL)
-#define	AUTOLOAD_EFUSE				CMDEEPROM_EN
+#define	CMDEEPROM_EN			BIT(5)
+#define	CMDEEPROM_SEL			BIT(4)
+#define	CMD9346CR_9356SEL		BIT(4)
+#define	AUTOLOAD_EEPROM			(CMDEEPROM_EN | CMDEEPROM_SEL)
+#define	AUTOLOAD_EFUSE			CMDEEPROM_EN
 
-#define	GPIOSEL_GPIO				0
-#define	GPIOSEL_ENBT				BIT(5)
+#define	GPIOSEL_GPIO			0
+#define	GPIOSEL_ENBT			BIT(5)
 
-#define	GPIO_IN					REG_GPIO_PIN_CTRL
-#define	GPIO_OUT				(REG_GPIO_PIN_CTRL + 1)
-#define	GPIO_IO_SEL				(REG_GPIO_PIN_CTRL + 2)
-#define	GPIO_MOD				(REG_GPIO_PIN_CTRL + 3)
+#define	GPIO_IN				REG_GPIO_PIN_CTRL
+#define	GPIO_OUT			(REG_GPIO_PIN_CTRL + 1)
+#define	GPIO_IO_SEL			(REG_GPIO_PIN_CTRL + 2)
+#define	GPIO_MOD			(REG_GPIO_PIN_CTRL + 3)
 
 /* 8723/8188E Host System Interrupt Mask Register (offset 0x58, 32 byte) */
 #define	HSIMR_GPIO12_0_INT_EN			BIT(0)
@@ -400,8 +407,7 @@
 #define	HSIMR_PDN_INT_EN			BIT(7)
 #define	HSIMR_GPIO9_INT_EN			BIT(25)
 
-/* 8723/8188E Host System Interrupt Status Register (offset 0x5C, 32 byte) */
-
+/*  8723/8188E Host System Interrupt Status Register (offset 0x5C, 32 byte) */
 #define	HSISR_GPIO12_0_INT			BIT(0)
 #define	HSISR_SPS_OCP_INT			BIT(5)
 #define	HSISR_RON_INT_EN			BIT(6)
@@ -412,7 +418,6 @@
 #define	MSR_ADHOC				0x01
 #define	MSR_INFRA				0x02
 #define	MSR_AP					0x03
-#define	MSR_MASK				0x03
 
 #define	RRSR_RSC_OFFSET				21
 #define	RRSR_SHORT_OFFSET			23
@@ -542,7 +547,8 @@
 
 /*********************************************
 *       8723BE IMR/ISR bits
-**********************************************/
+*********************************************
+*/
 #define	IMR_DISABLED				0x0
 /* IMR DW0(0x0060-0063) Bit 0-31 */
 #define	IMR_TXCCK		BIT(30)	/* TXRPT interrupt when
@@ -644,7 +650,7 @@
 #define RF_OPTION1				0x79
 #define RF_OPTION2				0x7A
 #define RF_OPTION3				0x7B
-#define RF_OPTION4				0xC3
+#define EEPROM_RF_BT_SETTING_8723B		0xC3
 
 #define EEPROM_DEFAULT_PID			0x1234
 #define EEPROM_DEFAULT_VID			0x5678
@@ -678,14 +684,11 @@
 #define EEPROM_CLK				0x06
 #define EEPROM_TESTR				0x08
 
-
 #define EEPROM_TXPOWERCCK			0x10
 #define	EEPROM_TXPOWERHT40_1S			0x16
 #define EEPROM_TXPOWERHT20DIFF			0x1B
 #define EEPROM_TXPOWER_OFDMDIFF			0x1B
 
-
-
 #define	EEPROM_TX_PWR_INX			0x10
 
 #define	EEPROM_CHANNELPLAN			0xB8
@@ -1198,7 +1201,7 @@
 #define APP_MIC					BIT(30)
 #define APP_FCS					BIT(31)
 
-#define _MIN_SPACE(x)			((x) & 0x7)
+#define _MIN_SPACE(x)				((x) & 0x7)
 #define _SHORT_GI_PADDING(x)		(((x) & 0x1F) << 3)
 
 #define RXERR_TYPE_OFDM_PPDU		0
@@ -1216,105 +1219,105 @@
 #define RXERR_TYPE_HT_MPDU_FAIL		12
 #define RXERR_TYPE_RX_FULL_DROP		15
 
-#define RXERR_COUNTER_MASK		0xFFFFF
-#define RXERR_RPT_RST			BIT(27)
-#define _RXERR_RPT_SEL(type)		((type) << 28)
-
-#define	SCR_TXUSEDK			BIT(0)
-#define	SCR_RXUSEDK			BIT(1)
-#define	SCR_TXENCENABLE			BIT(2)
-#define	SCR_RXDECENABLE			BIT(3)
-#define	SCR_SKBYA2			BIT(4)
-#define	SCR_NOSKMC			BIT(5)
-#define SCR_TXBCUSEDK			BIT(6)
-#define SCR_RXBCUSEDK			BIT(7)
-
-#define XCLK_VLD			BIT(0)
-#define ACLK_VLD			BIT(1)
-#define UCLK_VLD			BIT(2)
-#define PCLK_VLD			BIT(3)
-#define PCIRSTB				BIT(4)
-#define V15_VLD				BIT(5)
-#define TRP_B15V_EN			BIT(7)
-#define SIC_IDLE			BIT(8)
-#define BD_MAC2				BIT(9)
-#define BD_MAC1				BIT(10)
-#define IC_MACPHY_MODE			BIT(11)
-#define BT_FUNC				BIT(16)
-#define VENDOR_ID			BIT(19)
-#define PAD_HWPD_IDN			BIT(22)
-#define TRP_VAUX_EN			BIT(23)
-#define TRP_BT_EN			BIT(24)
-#define BD_PKG_SEL			BIT(25)
-#define BD_HCI_SEL			BIT(26)
-#define TYPE_ID				BIT(27)
-
-#define USB_IS_HIGH_SPEED		0
-#define USB_IS_FULL_SPEED		1
-#define USB_SPEED_MASK			BIT(5)
-
-#define USB_NORMAL_SIE_EP_MASK		0xF
-#define USB_NORMAL_SIE_EP_SHIFT		4
-
-#define USB_TEST_EP_MASK		0x30
-#define USB_TEST_EP_SHIFT		4
-
-#define USB_AGG_EN			BIT(3)
-
-#define MAC_ADDR_LEN			6
-#define LAST_ENTRY_OF_TX_PKT_BUFFER	175/*255    88e*/
-
-#define POLLING_LLT_THRESHOLD		20
-#define POLLING_READY_TIMEOUT_COUNT	3000
+#define RXERR_COUNTER_MASK			0xFFFFF
+#define RXERR_RPT_RST				BIT(27)
+#define _RXERR_RPT_SEL(type)			((type) << 28)
 
-#define	MAX_MSS_DENSITY_2T		0x13
-#define	MAX_MSS_DENSITY_1T		0x0A
+#define	SCR_TXUSEDK				BIT(0)
+#define	SCR_RXUSEDK				BIT(1)
+#define	SCR_TXENCENABLE				BIT(2)
+#define	SCR_RXDECENABLE				BIT(3)
+#define	SCR_SKBYA2				BIT(4)
+#define	SCR_NOSKMC				BIT(5)
+#define SCR_TXBCUSEDK				BIT(6)
+#define SCR_RXBCUSEDK				BIT(7)
+
+#define XCLK_VLD				BIT(0)
+#define ACLK_VLD				BIT(1)
+#define UCLK_VLD				BIT(2)
+#define PCLK_VLD				BIT(3)
+#define PCIRSTB					BIT(4)
+#define V15_VLD					BIT(5)
+#define TRP_B15V_EN				BIT(7)
+#define SIC_IDLE				BIT(8)
+#define BD_MAC2					BIT(9)
+#define BD_MAC1					BIT(10)
+#define IC_MACPHY_MODE				BIT(11)
+#define BT_FUNC					BIT(16)
+#define VENDOR_ID				BIT(19)
+#define PAD_HWPD_IDN				BIT(22)
+#define TRP_VAUX_EN				BIT(23)
+#define TRP_BT_EN				BIT(24)
+#define BD_PKG_SEL				BIT(25)
+#define BD_HCI_SEL				BIT(26)
+#define TYPE_ID					BIT(27)
+
+#define USB_IS_HIGH_SPEED			0
+#define USB_IS_FULL_SPEED			1
+#define USB_SPEED_MASK				BIT(5)
+
+#define USB_NORMAL_SIE_EP_MASK			0xF
+#define USB_NORMAL_SIE_EP_SHIFT			4
+
+#define USB_TEST_EP_MASK			0x30
+#define USB_TEST_EP_SHIFT			4
+
+#define USB_AGG_EN				BIT(3)
+
+#define MAC_ADDR_LEN				6
+#define LAST_ENTRY_OF_TX_PKT_BUFFER		175/*255    88e*/
+
+#define POLLING_LLT_THRESHOLD			20
+#define POLLING_READY_TIMEOUT_COUNT		3000
+
+#define	MAX_MSS_DENSITY_2T			0x13
+#define	MAX_MSS_DENSITY_1T			0x0A
 
 #define EPROM_CMD_OPERATING_MODE_MASK	((1<<7)|(1<<6))
-#define EPROM_CMD_CONFIG		0x3
-#define EPROM_CMD_LOAD			1
-
-#define	HWSET_MAX_SIZE_92S		HWSET_MAX_SIZE
-
-#define	HAL_8192C_HW_GPIO_WPS_BIT	BIT(2)
-
-#define	RPMAC_RESET			0x100
-#define	RPMAC_TXSTART			0x104
-#define	RPMAC_TXLEGACYSIG		0x108
-#define	RPMAC_TXHTSIG1			0x10c
-#define	RPMAC_TXHTSIG2			0x110
-#define	RPMAC_PHYDEBUG			0x114
-#define	RPMAC_TXPACKETNUM		0x118
-#define	RPMAC_TXIDLE			0x11c
-#define	RPMAC_TXMACHEADER0		0x120
-#define	RPMAC_TXMACHEADER1		0x124
-#define	RPMAC_TXMACHEADER2		0x128
-#define	RPMAC_TXMACHEADER3		0x12c
-#define	RPMAC_TXMACHEADER4		0x130
-#define	RPMAC_TXMACHEADER5		0x134
-#define	RPMAC_TXDADATYPE		0x138
-#define	RPMAC_TXRANDOMSEED		0x13c
-#define	RPMAC_CCKPLCPPREAMBLE		0x140
-#define	RPMAC_CCKPLCPHEADER		0x144
-#define	RPMAC_CCKCRC16			0x148
-#define	RPMAC_OFDMRXCRC32OK		0x170
-#define	RPMAC_OFDMRXCRC32ER		0x174
-#define	RPMAC_OFDMRXPARITYER		0x178
-#define	RPMAC_OFDMRXCRC8ER		0x17c
-#define	RPMAC_CCKCRXRC16ER		0x180
-#define	RPMAC_CCKCRXRC32ER		0x184
-#define	RPMAC_CCKCRXRC32OK		0x188
-#define	RPMAC_TXSTATUS			0x18c
-
-#define	RFPGA0_RFMOD			0x800
-
-#define	RFPGA0_TXINFO			0x804
-#define	RFPGA0_PSDFUNCTION		0x808
-
-#define	RFPGA0_TXGAINSTAGE		0x80c
-
-#define	RFPGA0_RFTIMING1		0x810
-#define	RFPGA0_RFTIMING2		0x814
+#define EPROM_CMD_CONFIG			0x3
+#define EPROM_CMD_LOAD				1
+
+#define	HWSET_MAX_SIZE_92S			HWSET_MAX_SIZE
+
+#define	HAL_8192C_HW_GPIO_WPS_BIT		BIT(2)
+
+#define	RPMAC_RESET				0x100
+#define	RPMAC_TXSTART				0x104
+#define	RPMAC_TXLEGACYSIG			0x108
+#define	RPMAC_TXHTSIG1				0x10c
+#define	RPMAC_TXHTSIG2				0x110
+#define	RPMAC_PHYDEBUG				0x114
+#define	RPMAC_TXPACKETNUM			0x118
+#define	RPMAC_TXIDLE				0x11c
+#define	RPMAC_TXMACHEADER0			0x120
+#define	RPMAC_TXMACHEADER1			0x124
+#define	RPMAC_TXMACHEADER2			0x128
+#define	RPMAC_TXMACHEADER3			0x12c
+#define	RPMAC_TXMACHEADER4			0x130
+#define	RPMAC_TXMACHEADER5			0x134
+#define	RPMAC_TXDADATYPE			0x138
+#define	RPMAC_TXRANDOMSEED			0x13c
+#define	RPMAC_CCKPLCPPREAMBLE			0x140
+#define	RPMAC_CCKPLCPHEADER			0x144
+#define	RPMAC_CCKCRC16				0x148
+#define	RPMAC_OFDMRXCRC32OK			0x170
+#define	RPMAC_OFDMRXCRC32ER			0x174
+#define	RPMAC_OFDMRXPARITYER			0x178
+#define	RPMAC_OFDMRXCRC8ER			0x17c
+#define	RPMAC_CCKCRXRC16ER			0x180
+#define	RPMAC_CCKCRXRC32ER			0x184
+#define	RPMAC_CCKCRXRC32OK			0x188
+#define	RPMAC_TXSTATUS				0x18c
+
+#define	RFPGA0_RFMOD				0x800
+
+#define	RFPGA0_TXINFO				0x804
+#define	RFPGA0_PSDFUNCTION			0x808
+
+#define	RFPGA0_TXGAINSTAGE			0x80c
+
+#define	RFPGA0_RFTIMING1			0x810
+#define	RFPGA0_RFTIMING2			0x814
 
 #define	RFPGA0_XA_HSSIPARAMETER1	0x820
 #define	RFPGA0_XA_HSSIPARAMETER2	0x824
@@ -1385,7 +1388,6 @@
 #define	RCCK0_FACOUNTERUPPER		0xa58
 #define	RCCK0_CCA_CNT			0xa60
 
-
 /* PageB(0xB00) */
 #define	RPDP_ANTA			0xb00
 #define	RPDP_ANTA_4			0xb04
@@ -1399,7 +1401,7 @@
 #define	RPDP_ANTA_24			0xb24
 
 #define	RCONFIG_PMPD_ANTA		0xb28
-#define	CONFIG_RAM64X16			0xb2c
+#define	RCONFIG_ram64x16		0xb2c
 
 #define	RBNDA				0xb30
 #define	RHSSIPAR			0xb34
@@ -1494,7 +1496,6 @@
 #define	ROFDM0_FRAMESYNC		0xcf0
 #define	ROFDM0_DFSREPORT		0xcf4
 
-
 #define	ROFDM1_LSTF			0xd00
 #define	ROFDM1_TRXPATHENABLE		0xd04
 
@@ -1593,144 +1594,144 @@
 #define	RSLEEP				0xee0
 #define	RPMPD_ANAEN			0xeec
 
-#define	RZEBRA1_HSSIENABLE		0x0
-#define	RZEBRA1_TRXENABLE1		0x1
-#define	RZEBRA1_TRXENABLE2		0x2
-#define	RZEBRA1_AGC			0x4
-#define	RZEBRA1_CHARGEPUMP		0x5
-#define	RZEBRA1_CHANNEL			0x7
-
-#define	RZEBRA1_TXGAIN			0x8
-#define	RZEBRA1_TXLPF			0x9
-#define	RZEBRA1_RXLPF			0xb
-#define	RZEBRA1_RXHPFCORNER		0xc
-
-#define	RGLOBALCTRL			0
-#define	RRTL8256_TXLPF			19
-#define	RRTL8256_RXLPF			11
-#define	RRTL8258_TXLPF			0x11
-#define	RRTL8258_RXLPF			0x13
-#define	RRTL8258_RSSILPF		0xa
-
-#define	RF_AC				0x00
-
-#define	RF_IQADJ_G1			0x01
-#define	RF_IQADJ_G2			0x02
-#define	RF_POW_TRSW			0x05
-
-#define	RF_GAIN_RX			0x06
-#define	RF_GAIN_TX			0x07
-
-#define	RF_TXM_IDAC			0x08
-#define	RF_BS_IQGEN			0x0F
-
-#define	RF_MODE1			0x10
-#define	RF_MODE2			0x11
-
-#define	RF_RX_AGC_HP			0x12
-#define	RF_TX_AGC			0x13
-#define	RF_BIAS				0x14
-#define	RF_IPA				0x15
-#define	RF_POW_ABILITY			0x17
-#define	RF_MODE_AG			0x18
-#define	RRFCHANNEL			0x18
-#define	RF_CHNLBW			0x18
-#define	RF_TOP				0x19
-
-#define	RF_RX_G1			0x1A
-#define	RF_RX_G2			0x1B
-
-#define	RF_RX_BB2			0x1C
-#define	RF_RX_BB1			0x1D
-
-#define	RF_RCK1				0x1E
-#define	RF_RCK2				0x1F
-
-#define	RF_TX_G1			0x20
-#define	RF_TX_G2			0x21
-#define	RF_TX_G3			0x22
-
-#define	RF_TX_BB1			0x23
-#define	RF_T_METER			0x42
-
-#define	RF_SYN_G1			0x25
-#define	RF_SYN_G2			0x26
-#define	RF_SYN_G3			0x27
-#define	RF_SYN_G4			0x28
-#define	RF_SYN_G5			0x29
-#define	RF_SYN_G6			0x2A
-#define	RF_SYN_G7			0x2B
-#define	RF_SYN_G8			0x2C
-
-#define	RF_RCK_OS			0x30
-#define	RF_TXPA_G1			0x31
-#define	RF_TXPA_G2			0x32
-#define	RF_TXPA_G3			0x33
-
-#define	RF_TX_BIAS_A			0x35
-#define	RF_TX_BIAS_D			0x36
-#define	RF_LOBF_9			0x38
-#define	RF_RXRF_A3			0x3C
-#define	RF_TRSW				0x3F
-
-#define	RF_TXRF_A2			0x41
-#define	RF_TXPA_G4			0x46
-#define	RF_TXPA_A4			0x4B
-
-#define	RF_WE_LUT			0xEF
-
-#define	BBBRESETB			0x100
-#define	BGLOBALRESETB			0x200
-#define	BOFDMTXSTART			0x4
-#define	BCCKTXSTART			0x8
-#define	BCRC32DEBUG			0x100
-#define	BPMACLOOPBACK			0x10
-#define	BTXLSIG				0xffffff
-#define	BOFDMTXRATE			0xf
-#define	BOFDMTXRESERVED			0x10
-#define	BOFDMTXLENGTH			0x1ffe0
-#define	BOFDMTXPARITY			0x20000
-#define	BTXHTSIG1			0xffffff
-#define	BTXHTMCSRATE			0x7f
-#define	BTXHTBW				0x80
-#define	BTXHTLENGTH			0xffff00
-#define	BTXHTSIG2			0xffffff
-#define	BTXHTSMOOTHING			0x1
-#define	BTXHTSOUNDING			0x2
-#define	BTXHTRESERVED			0x4
-#define	BTXHTAGGREATION			0x8
-#define	BTXHTSTBC			0x30
-#define	BTXHTADVANCECODING		0x40
-#define	BTXHTSHORTGI			0x80
-#define	BTXHTNUMBERHT_LTF		0x300
-#define	BTXHTCRC8			0x3fc00
-#define	BCOUNTERRESET			0x10000
-#define	BNUMOFOFDMTX			0xffff
-#define	BNUMOFCCKTX			0xffff0000
-#define	BTXIDLEINTERVAL			0xffff
-#define	BOFDMSERVICE			0xffff0000
-#define	BTXMACHEADER			0xffffffff
-#define	BTXDATAINIT			0xff
-#define	BTXHTMODE			0x100
-#define	BTXDATATYPE			0x30000
-#define	BTXRANDOMSEED			0xffffffff
-#define	BCCKTXPREAMBLE			0x1
-#define	BCCKTXSFD			0xffff0000
-#define	BCCKTXSIG			0xff
-#define	BCCKTXSERVICE			0xff00
-#define	BCCKLENGTHEXT			0x8000
-#define	BCCKTXLENGHT			0xffff0000
-#define	BCCKTXCRC16			0xffff
-#define	BCCKTXSTATUS			0x1
-#define	BOFDMTXSTATUS			0x2
+#define	RZEBRA1_HSSIENABLE			0x0
+#define	RZEBRA1_TRXENABLE1			0x1
+#define	RZEBRA1_TRXENABLE2			0x2
+#define	RZEBRA1_AGC				0x4
+#define	RZEBRA1_CHARGEPUMP			0x5
+#define	RZEBRA1_CHANNEL				0x7
+
+#define	RZEBRA1_TXGAIN				0x8
+#define	RZEBRA1_TXLPF				0x9
+#define	RZEBRA1_RXLPF				0xb
+#define	RZEBRA1_RXHPFCORNER			0xc
+
+#define	RGLOBALCTRL				0
+#define	RRTL8256_TXLPF				19
+#define	RRTL8256_RXLPF				11
+#define	RRTL8258_TXLPF				0x11
+#define	RRTL8258_RXLPF				0x13
+#define	RRTL8258_RSSILPF			0xa
+
+#define	RF_AC					0x00
+
+#define	RF_IQADJ_G1				0x01
+#define	RF_IQADJ_G2				0x02
+#define	RF_POW_TRSW				0x05
+
+#define	RF_GAIN_RX				0x06
+#define	RF_GAIN_TX				0x07
+
+#define	RF_TXM_IDAC				0x08
+#define	RF_BS_IQGEN				0x0F
+
+#define	RF_MODE1				0x10
+#define	RF_MODE2				0x11
+
+#define	RF_RX_AGC_HP				0x12
+#define	RF_TX_AGC				0x13
+#define	RF_BIAS					0x14
+#define	RF_IPA					0x15
+#define	RF_POW_ABILITY				0x17
+#define	RF_MODE_AG				0x18
+#define	RRFCHANNEL				0x18
+#define	RF_CHNLBW				0x18
+#define	RF_TOP					0x19
+
+#define	RF_RX_G1				0x1A
+#define	RF_RX_G2				0x1B
+
+#define	RF_RX_BB2				0x1C
+#define	RF_RX_BB1				0x1D
+
+#define	RF_RCK1					0x1E
+#define	RF_RCK2					0x1F
+
+#define	RF_TX_G1				0x20
+#define	RF_TX_G2				0x21
+#define	RF_TX_G3				0x22
+
+#define	RF_TX_BB1				0x23
+#define	RF_T_METER				0x42
+
+#define	RF_SYN_G1				0x25
+#define	RF_SYN_G2				0x26
+#define	RF_SYN_G3				0x27
+#define	RF_SYN_G4				0x28
+#define	RF_SYN_G5				0x29
+#define	RF_SYN_G6				0x2A
+#define	RF_SYN_G7				0x2B
+#define	RF_SYN_G8				0x2C
+
+#define	RF_RCK_OS				0x30
+#define	RF_TXPA_G1				0x31
+#define	RF_TXPA_G2				0x32
+#define	RF_TXPA_G3				0x33
+
+#define	RF_TX_BIAS_A				0x35
+#define	RF_TX_BIAS_D				0x36
+#define	RF_LOBF_9				0x38
+#define	RF_RXRF_A3				0x3C
+#define	RF_TRSW					0x3F
+
+#define	RF_TXRF_A2				0x41
+#define	RF_TXPA_G4				0x46
+#define	RF_TXPA_A4				0x4B
+
+#define	RF_WE_LUT				0xEF
+
+#define	BBBRESETB				0x100
+#define	BGLOBALRESETB				0x200
+#define	BOFDMTXSTART				0x4
+#define	BCCKTXSTART				0x8
+#define	BCRC32DEBUG				0x100
+#define	BPMACLOOPBACK				0x10
+#define	BTXLSIG					0xffffff
+#define	BOFDMTXRATE				0xf
+#define	BOFDMTXRESERVED				0x10
+#define	BOFDMTXLENGTH				0x1ffe0
+#define	BOFDMTXPARITY				0x20000
+#define	BTXHTSIG1				0xffffff
+#define	BTXHTMCSRATE				0x7f
+#define	BTXHTBW					0x80
+#define	BTXHTLENGTH				0xffff00
+#define	BTXHTSIG2				0xffffff
+#define	BTXHTSMOOTHING				0x1
+#define	BTXHTSOUNDING				0x2
+#define	BTXHTRESERVED				0x4
+#define	BTXHTAGGREATION				0x8
+#define	BTXHTSTBC				0x30
+#define	BTXHTADVANCECODING			0x40
+#define	BTXHTSHORTGI				0x80
+#define	BTXHTNUMBERHT_LTF			0x300
+#define	BTXHTCRC8				0x3fc00
+#define	BCOUNTERRESET				0x10000
+#define	BNUMOFOFDMTX				0xffff
+#define	BNUMOFCCKTX				0xffff0000
+#define	BTXIDLEINTERVAL				0xffff
+#define	BOFDMSERVICE				0xffff0000
+#define	BTXMACHEADER				0xffffffff
+#define	BTXDATAINIT				0xff
+#define	BTXHTMODE				0x100
+#define	BTXDATATYPE				0x30000
+#define	BTXRANDOMSEED				0xffffffff
+#define	BCCKTXPREAMBLE				0x1
+#define	BCCKTXSFD				0xffff0000
+#define	BCCKTXSIG				0xff
+#define	BCCKTXSERVICE				0xff00
+#define	BCCKLENGTHEXT				0x8000
+#define	BCCKTXLENGHT				0xffff0000
+#define	BCCKTXCRC16				0xffff
+#define	BCCKTXSTATUS				0x1
+#define	BOFDMTXSTATUS				0x2
 #define IS_BB_REG_OFFSET_92S(_offset)	\
 	((_offset >= 0x800) && (_offset <= 0xfff))
 
-#define	BRFMOD				0x1
-#define	BJAPANMODE			0x2
-#define	BCCKTXSC			0x30
-#define	BCCKEN				0x1000000
-#define	BOFDMEN				0x2000000
+#define	BRFMOD					0x1
+#define	BJAPANMODE				0x2
+#define	BCCKTXSC				0x30
+#define	BCCKEN					0x1000000
+#define	BOFDMEN					0x2000000
 
 #define	BOFDMRXADCPHASE			0x10000
 #define	BOFDMTXDACPHASE			0x40000
@@ -1824,13 +1825,13 @@
 #define	BDA6SWING			0x380000
 
 #define	BADCLKPHASE			0x4000000
-#define	B80MCLKDELAY	0x18000000
-#define	BAFEWATCHDOGENABLE	0x20000000
+#define	B80MCLKDELAY			0x18000000
+#define	BAFEWATCHDOGENABLE		0x20000000
 
-#define	BXTALCAP01	0xc0000000
-#define	BXTALCAP23	0x3
+#define	BXTALCAP01			0xc0000000
+#define	BXTALCAP23			0x3
 #define	BXTALCAP92X			0x0f000000
-#define BXTALCAP	0x0f000000
+#define BXTALCAP			0x0f000000
 
 #define	BINTDIFCLKENABLE		0x400
 #define	BEXTSIGCLKENABLE		0x800
@@ -1857,7 +1858,7 @@
 #define	BCCKRX_AGC_FORMAT		0x200
 #define	BPSDFFT_SAMPLE_POINT		0xc000
 #define	BPSD_AVERAGE_NUM		0x3000
-#define	BIQPATH_CONTROL	0xc00
+#define	BIQPATH_CONTROL			0xc00
 #define	BPSD_FREQ			0x3ff
 #define	BPSD_ANTENNA_PATH		0x30
 #define	BPSD_IQ_SWITCH			0x40
@@ -1957,300 +1958,316 @@
 #define	BCCK_DEFAULT_RXPATH		0xc000000
 #define	BCCK_OPTION_RXPATH		0x3000000
 
-#define	BNUM_OFSTF	0x3
-#define	BSHIFT_L	0xc0
-#define	BGI_TH	0xc
-#define	BRXPATH_A	0x1
-#define	BRXPATH_B	0x2
-#define	BRXPATH_C	0x4
-#define	BRXPATH_D	0x8
-#define	BTXPATH_A	0x1
-#define	BTXPATH_B	0x2
-#define	BTXPATH_C	0x4
-#define	BTXPATH_D	0x8
-#define	BTRSSI_FREQ	0x200
-#define	BADC_BACKOFF	0x3000
-#define	BDFIR_BACKOFF	0xc000
-#define	BTRSSI_LATCH_PHASE	0x10000
-#define	BRX_LDC_OFFSET	0xff
-#define	BRX_QDC_OFFSET	0xff00
-#define	BRX_DFIR_MODE	0x1800000
-#define	BRX_DCNF_TYPE	0xe000000
-#define	BRXIQIMB_A	0x3ff
-#define	BRXIQIMB_B	0xfc00
-#define	BRXIQIMB_C	0x3f0000
-#define	BRXIQIMB_D	0xffc00000
-#define	BDC_DC_NOTCH	0x60000
-#define	BRXNB_NOTCH	0x1f000000
-#define	BPD_TH	0xf
-#define	BPD_TH_OPT2	0xc000
-#define	BPWED_TH	0x700
-#define	BIFMF_WIN_L	0x800
-#define	BPD_OPTION	0x1000
-#define	BMF_WIN_L	0xe000
-#define	BBW_SEARCH_L	0x30000
-#define	BWIN_ENH_L	0xc0000
-#define	BBW_TH	0x700000
-#define	BED_TH2	0x3800000
-#define	BBW_OPTION	0x4000000
-#define	BRADIO_TH	0x18000000
-#define	BWINDOW_L	0xe0000000
-#define	BSBD_OPTION	0x1
-#define	BFRAME_TH	0x1c
-#define	BFS_OPTION	0x60
-#define	BDC_SLOPE_CHECK	0x80
-#define	BFGUARD_COUNTER_DC_L	0xe00
-#define	BFRAME_WEIGHT_SHORT	0x7000
-#define	BSUB_TUNE	0xe00000
-#define	BFRAME_DC_LENGTH	0xe000000
-#define	BSBD_START_OFFSET	0x30000000
-#define	BFRAME_TH_2	0x7
-#define	BFRAME_GI2_TH	0x38
-#define	BGI2_SYNC_EN	0x40
-#define	BSARCH_SHORT_EARLY	0x300
-#define	BSARCH_SHORT_LATE	0xc00
-#define	BSARCH_GI2_LATE	0x70000
-#define	BCFOANTSUM	0x1
-#define	BCFOACC	0x2
-#define	BCFOSTARTOFFSET	0xc
-#define	BCFOLOOPBACK	0x70
-#define	BCFOSUMWEIGHT	0x80
-#define	BDAGCENABLE	0x10000
-#define	BTXIQIMB_A	0x3ff
-#define	BTXIQIMB_b	0xfc00
-#define	BTXIQIMB_C	0x3f0000
-#define	BTXIQIMB_D	0xffc00000
-#define	BTXIDCOFFSET	0xff
-#define	BTXIQDCOFFSET	0xff00
-#define	BTXDFIRMODE	0x10000
-#define	BTXPESUDO_NOISEON	0x4000000
-#define	BTXPESUDO_NOISE_A	0xff
-#define	BTXPESUDO_NOISE_B	0xff00
-#define	BTXPESUDO_NOISE_C	0xff0000
-#define	BTXPESUDO_NOISE_D	0xff000000
-#define	BCCA_DROPOPTION	0x20000
-#define	BCCA_DROPTHRES	0xfff00000
-#define	BEDCCA_H	0xf
-#define	BEDCCA_L	0xf0
-#define	BLAMBDA_ED	0x300
-#define	BRX_INITIALGAIN	0x7f
-#define	BRX_ANTDIV_EN	0x80
+#define	BNUM_OFSTF			0x3
+#define	BSHIFT_L			0xc0
+#define	BGI_TH				0xc
+#define	BRXPATH_A			0x1
+#define	BRXPATH_B			0x2
+#define	BRXPATH_C			0x4
+#define	BRXPATH_D			0x8
+#define	BTXPATH_A			0x1
+#define	BTXPATH_B			0x2
+#define	BTXPATH_C			0x4
+#define	BTXPATH_D			0x8
+#define	BTRSSI_FREQ			0x200
+#define	BADC_BACKOFF			0x3000
+#define	BDFIR_BACKOFF			0xc000
+#define	BTRSSI_LATCH_PHASE		0x10000
+#define	BRX_LDC_OFFSET			0xff
+#define	BRX_QDC_OFFSET			0xff00
+#define	BRX_DFIR_MODE			0x1800000
+#define	BRX_DCNF_TYPE			0xe000000
+#define	BRXIQIMB_A			0x3ff
+#define	BRXIQIMB_B			0xfc00
+#define	BRXIQIMB_C			0x3f0000
+#define	BRXIQIMB_D			0xffc00000
+#define	BDC_DC_NOTCH			0x60000
+#define	BRXNB_NOTCH			0x1f000000
+#define	BPD_TH				0xf
+#define	BPD_TH_OPT2			0xc000
+#define	BPWED_TH			0x700
+#define	BIFMF_WIN_L			0x800
+#define	BPD_OPTION			0x1000
+#define	BMF_WIN_L			0xe000
+#define	BBW_SEARCH_L			0x30000
+#define	BWIN_ENH_L			0xc0000
+#define	BBW_TH				0x700000
+#define	BED_TH2				0x3800000
+#define	BBW_OPTION			0x4000000
+#define	BRADIO_TH			0x18000000
+#define	BWINDOW_L			0xe0000000
+#define	BSBD_OPTION			0x1
+#define	BFRAME_TH			0x1c
+#define	BFS_OPTION			0x60
+#define	BDC_SLOPE_CHECK			0x80
+#define	BFGUARD_COUNTER_DC_L		0xe00
+#define	BFRAME_WEIGHT_SHORT		0x7000
+#define	BSUB_TUNE			0xe00000
+#define	BFRAME_DC_LENGTH		0xe000000
+#define	BSBD_START_OFFSET		0x30000000
+#define	BFRAME_TH_2			0x7
+#define	BFRAME_GI2_TH			0x38
+#define	BGI2_SYNC_EN			0x40
+#define	BSARCH_SHORT_EARLY		0x300
+#define	BSARCH_SHORT_LATE		0xc00
+#define	BSARCH_GI2_LATE			0x70000
+#define	BCFOANTSUM			0x1
+#define	BCFOACC				0x2
+#define	BCFOSTARTOFFSET			0xc
+#define	BCFOLOOPBACK			0x70
+#define	BCFOSUMWEIGHT			0x80
+#define	BDAGCENABLE			0x10000
+#define	BTXIQIMB_A			0x3ff
+#define	BTXIQIMB_b			0xfc00
+#define	BTXIQIMB_C			0x3f0000
+#define	BTXIQIMB_D			0xffc00000
+#define	BTXIDCOFFSET			0xff
+#define	BTXIQDCOFFSET			0xff00
+#define	BTXDFIRMODE			0x10000
+#define	BTXPESUDO_NOISEON		0x4000000
+#define	BTXPESUDO_NOISE_A		0xff
+#define	BTXPESUDO_NOISE_B		0xff00
+#define	BTXPESUDO_NOISE_C		0xff0000
+#define	BTXPESUDO_NOISE_D		0xff000000
+#define	BCCA_DROPOPTION			0x20000
+#define	BCCA_DROPTHRES			0xfff00000
+#define	BEDCCA_H			0xf
+#define	BEDCCA_L			0xf0
+#define	BLAMBDA_ED			0x300
+#define	BRX_INITIALGAIN			0x7f
+#define	BRX_ANTDIV_EN			0x80
 #define	BRX_AGC_ADDRESS_FOR_LNA		0x7f00
-#define	BRX_HIGHPOWER_FLOW	0x8000
+#define	BRX_HIGHPOWER_FLOW		0x8000
 #define	BRX_AGC_FREEZE_THRES		0xc0000
-#define	BRX_FREEZESTEP_AGC1	0x300000
-#define	BRX_FREEZESTEP_AGC2	0xc00000
-#define	BRX_FREEZESTEP_AGC3	0x3000000
-#define	BRX_FREEZESTEP_AGC0	0xc000000
-#define	BRXRSSI_CMP_EN	0x10000000
-#define	BRXQUICK_AGCEN	0x20000000
+#define	BRX_FREEZESTEP_AGC1		0x300000
+#define	BRX_FREEZESTEP_AGC2		0xc00000
+#define	BRX_FREEZESTEP_AGC3		0x3000000
+#define	BRX_FREEZESTEP_AGC0		0xc000000
+#define	BRXRSSI_CMP_EN			0x10000000
+#define	BRXQUICK_AGCEN			0x20000000
 #define	BRXAGC_FREEZE_THRES_MODE	0x40000000
-#define	BRX_OVERFLOW_CHECKTYPE	0x80000000
-#define	BRX_AGCSHIFT	0x7f
-#define	BTRSW_TRI_ONLY	0x80
-#define	BPOWER_THRES	0x300
-#define	BRXAGC_EN	0x1
-#define	BRXAGC_TOGETHER_EN	0x2
-#define	BRXAGC_MIN	0x4
-#define	BRXHP_INI	0x7
-#define	BRXHP_TRLNA	0x70
-#define	BRXHP_RSSI	0x700
-#define	BRXHP_BBP1	0x7000
-#define	BRXHP_BBP2	0x70000
-#define	BRXHP_BBP3	0x700000
-#define	BRSSI_H	0x7f0000
-#define	BRSSI_GEN	0x7f000000
-#define	BRXSETTLE_TRSW	0x7
-#define	BRXSETTLE_LNA	0x38
-#define	BRXSETTLE_RSSI	0x1c0
-#define	BRXSETTLE_BBP	0xe00
-#define	BRXSETTLE_RXHP	0x7000
-#define	BRXSETTLE_ANTSW_RSSI	0x38000
-#define	BRXSETTLE_ANTSW	0xc0000
-#define	BRXPROCESS_TIME_DAGC	0x300000
-#define	BRXSETTLE_HSSI	0x400000
-#define	BRXPROCESS_TIME_BBPPW	0x800000
-#define	BRXANTENNA_POWER_SHIFT	0x3000000
-#define	BRSSI_TABLE_SELECT	0xc000000
-#define	BRXHP_FINAL	0x7000000
-#define	BRXHPSETTLE_BBP	0x7
-#define	BRXHTSETTLE_HSSI	0x8
-#define	BRXHTSETTLE_RXHP	0x70
-#define	BRXHTSETTLE_BBPPW	0x80
-#define	BRXHTSETTLE_IDLE	0x300
-#define	BRXHTSETTLE_RESERVED	0x1c00
-#define	BRXHT_RXHP_EN	0x8000
-#define	BRXAGC_FREEZE_THRES	0x30000
-#define	BRXAGC_TOGETHEREN	0x40000
-#define	BRXHTAGC_MIN	0x80000
-#define	BRXHTAGC_EN	0x100000
-#define	BRXHTDAGC_EN	0x200000
-#define	BRXHT_RXHP_BBP	0x1c00000
-#define	BRXHT_RXHP_FINAL	0xe0000000
-#define	BRXPW_RADIO_TH	0x3
-#define	BRXPW_RADIO_EN	0x4
-#define	BRXMF_HOLD	0x3800
-#define	BRXPD_DELAY_TH1	0x38
-#define	BRXPD_DELAY_TH2	0x1c0
-#define	BRXPD_DC_COUNT_MAX	0x600
-#define	BRXPD_DELAY_TH	0x8000
-#define	BRXPROCESS_DELAY	0xf0000
+#define	BRX_OVERFLOW_CHECKTYPE		0x80000000
+#define	BRX_AGCSHIFT			0x7f
+#define	BTRSW_TRI_ONLY			0x80
+#define	BPOWER_THRES			0x300
+#define	BRXAGC_EN			0x1
+#define	BRXAGC_TOGETHER_EN		0x2
+#define	BRXAGC_MIN			0x4
+#define	BRXHP_INI			0x7
+#define	BRXHP_TRLNA			0x70
+#define	BRXHP_RSSI			0x700
+#define	BRXHP_BBP1			0x7000
+#define	BRXHP_BBP2			0x70000
+#define	BRXHP_BBP3			0x700000
+#define	BRSSI_H				0x7f0000
+#define	BRSSI_GEN			0x7f000000
+#define	BRXSETTLE_TRSW			0x7
+#define	BRXSETTLE_LNA			0x38
+#define	BRXSETTLE_RSSI			0x1c0
+#define	BRXSETTLE_BBP			0xe00
+#define	BRXSETTLE_RXHP			0x7000
+#define	BRXSETTLE_ANTSW_RSSI		0x38000
+#define	BRXSETTLE_ANTSW			0xc0000
+#define	BRXPROCESS_TIME_DAGC		0x300000
+#define	BRXSETTLE_HSSI			0x400000
+#define	BRXPROCESS_TIME_BBPPW		0x800000
+#define	BRXANTENNA_POWER_SHIFT		0x3000000
+#define	BRSSI_TABLE_SELECT		0xc000000
+#define	BRXHP_FINAL			0x7000000
+#define	BRXHPSETTLE_BBP			0x7
+#define	BRXHTSETTLE_HSSI		0x8
+#define	BRXHTSETTLE_RXHP		0x70
+#define	BRXHTSETTLE_BBPPW		0x80
+#define	BRXHTSETTLE_IDLE		0x300
+#define	BRXHTSETTLE_RESERVED		0x1c00
+#define	BRXHT_RXHP_EN			0x8000
+#define	BRXAGC_FREEZE_THRES		0x30000
+#define	BRXAGC_TOGETHEREN		0x40000
+#define	BRXHTAGC_MIN			0x80000
+#define	BRXHTAGC_EN			0x100000
+#define	BRXHTDAGC_EN			0x200000
+#define	BRXHT_RXHP_BBP			0x1c00000
+#define	BRXHT_RXHP_FINAL		0xe0000000
+#define	BRXPW_RADIO_TH			0x3
+#define	BRXPW_RADIO_EN			0x4
+#define	BRXMF_HOLD			0x3800
+#define	BRXPD_DELAY_TH1			0x38
+#define	BRXPD_DELAY_TH2			0x1c0
+#define	BRXPD_DC_COUNT_MAX		0x600
+#define	BRXPD_DELAY_TH			0x8000
+#define	BRXPROCESS_DELAY		0xf0000
 #define	BRXSEARCHRANGE_GI2_EARLY	0x700000
 #define	BRXFRAME_FUARD_COUNTER_L	0x3800000
-#define	BRXSGI_GUARD_L	0xc000000
-#define	BRXSGI_SEARCH_L	0x30000000
-#define	BRXSGI_TH	0xc0000000
-#define	BDFSCNT0	0xff
-#define	BDFSCNT1	0xff00
-#define	BDFSFLAG	0xf0000
-#define	BMF_WEIGHT_SUM	0x300000
-#define	BMINIDX_TH	0x7f000000
-#define	BDAFORMAT	0x40000
-#define	BTXCH_EMU_ENABLE	0x01000000
-#define	BTRSW_ISOLATION_A	0x7f
-#define	BTRSW_ISOLATION_B	0x7f00
-#define	BTRSW_ISOLATION_C	0x7f0000
-#define	BTRSW_ISOLATION_D	0x7f000000
-#define	BEXT_LNA_GAIN	0x7c00
-
-#define	BSTBC_EN	0x4
-#define	BANTENNA_MAPPING	0x10
-#define	BNSS	0x20
+#define	BRXSGI_GUARD_L			0xc000000
+#define	BRXSGI_SEARCH_L			0x30000000
+#define	BRXSGI_TH			0xc0000000
+#define	BDFSCNT0			0xff
+#define	BDFSCNT1			0xff00
+#define	BDFSFLAG			0xf0000
+#define	BMF_WEIGHT_SUM			0x300000
+#define	BMINIDX_TH			0x7f000000
+#define	BDAFORMAT			0x40000
+#define	BTXCH_EMU_ENABLE		0x01000000
+#define	BTRSW_ISOLATION_A		0x7f
+#define	BTRSW_ISOLATION_B		0x7f00
+#define	BTRSW_ISOLATION_C		0x7f0000
+#define	BTRSW_ISOLATION_D		0x7f000000
+#define	BEXT_LNA_GAIN			0x7c00
+
+#define	BSTBC_EN			0x4
+#define	BANTENNA_MAPPING		0x10
+#define	BNSS				0x20
 #define	BCFO_ANTSUM_ID			0x200
-#define	BPHY_COUNTER_RESET	0x8000000
-#define	BCFO_REPORT_GET	0x4000000
-#define	BOFDM_CONTINUE_TX	0x10000000
-#define	BOFDM_SINGLE_CARRIER	0x20000000
-#define	BOFDM_SINGLE_TONE	0x40000000
-#define	BHT_DETECT	0x100
-#define	BCFOEN	0x10000
-#define	BCFOVALUE	0xfff00000
-#define	BSIGTONE_RE	0x3f
-#define	BSIGTONE_IM	0x7f00
-#define	BCOUNTER_CCA	0xffff
-#define	BCOUNTER_PARITYFAIL	0xffff0000
-#define	BCOUNTER_RATEILLEGAL	0xffff
-#define	BCOUNTER_CRC8FAIL	0xffff0000
-#define	BCOUNTER_MCSNOSUPPORT	0xffff
-#define	BCOUNTER_FASTSYNC	0xffff
-#define	BSHORTCFO	0xfff
-#define	BSHORTCFOT_LENGTH	12
-#define	BSHORTCFOF_LENGTH	11
-#define	BLONGCFO	0x7ff
-#define	BLONGCFOT_LENGTH	11
-#define	BLONGCFOF_LENGTH	11
-#define	BTAILCFO	0x1fff
-#define	BTAILCFOT_LENGTH	13
-#define	BTAILCFOF_LENGTH	12
-#define	BNOISE_EN_PWDB	0xffff
-#define	BCC_POWER_DB	0xffff0000
-#define	BMOISE_PWDB	0xffff
-#define	BPOWERMEAST_LENGTH	10
-#define	BPOWERMEASF_LENGTH	3
-#define	BRX_HT_BW	0x1
-#define	BRXSC	0x6
-#define	BRX_HT	0x8
-#define	BNB_INTF_DET_ON	0x1
-#define	BINTF_WIN_LEN_CFG	0x30
-#define	BNB_INTF_TH_CFG	0x1c0
-#define	BRFGAIN	0x3f
-#define	BTABLESEL	0x40
-#define	BTRSW	0x80
-#define	BRXSNR_A	0xff
-#define	BRXSNR_B	0xff00
-#define	BRXSNR_C	0xff0000
-#define	BRXSNR_D	0xff000000
-#define	BSNR_EVMT_LENGTH	8
-#define	BSNR_EVMF_LENGTH	1
-#define	BCSI1ST	0xff
-#define	BCSI2ND	0xff00
-#define	BRXEVM1ST	0xff0000
-#define	BRXEVM2ND	0xff000000
-#define	BSIGEVM	0xff
-#define	BPWDB	0xff00
-#define	BSGIEN	0x10000
-
-#define	BSFACTOR_QMA1	0xf
-#define	BSFACTOR_QMA2	0xf0
-#define	BSFACTOR_QMA3	0xf00
-#define	BSFACTOR_QMA4	0xf000
-#define	BSFACTOR_QMA5	0xf0000
-#define	BSFACTOR_QMA6	0xf0000
-#define	BSFACTOR_QMA7	0xf00000
-#define	BSFACTOR_QMA8	0xf000000
-#define	BSFACTOR_QMA9	0xf0000000
-#define	BCSI_SCHEME	0x100000
+#define	BPHY_COUNTER_RESET		0x8000000
+#define	BCFO_REPORT_GET			0x4000000
+#define	BOFDM_CONTINUE_TX		0x10000000
+#define	BOFDM_SINGLE_CARRIER		0x20000000
+#define	BOFDM_SINGLE_TONE		0x40000000
+#define	BHT_DETECT			0x100
+#define	BCFOEN				0x10000
+#define	BCFOVALUE			0xfff00000
+#define	BSIGTONE_RE			0x3f
+#define	BSIGTONE_IM			0x7f00
+#define	BCOUNTER_CCA			0xffff
+#define	BCOUNTER_PARITYFAIL		0xffff0000
+#define	BCOUNTER_RATEILLEGAL		0xffff
+#define	BCOUNTER_CRC8FAIL		0xffff0000
+#define	BCOUNTER_MCSNOSUPPORT		0xffff
+#define	BCOUNTER_FASTSYNC		0xffff
+#define	BSHORTCFO			0xfff
+#define	BSHORTCFOT_LENGTH		12
+#define	BSHORTCFOF_LENGTH		11
+#define	BLONGCFO			0x7ff
+#define	BLONGCFOT_LENGTH		11
+#define	BLONGCFOF_LENGTH		11
+#define	BTAILCFO			0x1fff
+#define	BTAILCFOT_LENGTH		13
+#define	BTAILCFOF_LENGTH		12
+#define	BNOISE_EN_PWDB			0xffff
+#define	BCC_POWER_DB			0xffff0000
+#define	BMOISE_PWDB			0xffff
+#define	BPOWERMEAST_LENGTH		10
+#define	BPOWERMEASF_LENGTH		3
+#define	BRX_HT_BW			0x1
+#define	BRXSC				0x6
+#define	BRX_HT				0x8
+#define	BNB_INTF_DET_ON			0x1
+#define	BINTF_WIN_LEN_CFG		0x30
+#define	BNB_INTF_TH_CFG			0x1c0
+#define	BRFGAIN				0x3f
+#define	BTABLESEL			0x40
+#define	BTRSW				0x80
+#define	BRXSNR_A			0xff
+#define	BRXSNR_B			0xff00
+#define	BRXSNR_C			0xff0000
+#define	BRXSNR_D			0xff000000
+#define	BSNR_EVMT_LENGTH		8
+#define	BSNR_EVMF_LENGTH		1
+#define	BCSI1ST				0xff
+#define	BCSI2ND				0xff00
+#define	BRXEVM1ST			0xff0000
+#define	BRXEVM2ND			0xff000000
+#define	BSIGEVM				0xff
+#define	BPWDB				0xff00
+#define	BSGIEN				0x10000
+
+#define	BSFACTOR_QMA1			0xf
+#define	BSFACTOR_QMA2			0xf0
+#define	BSFACTOR_QMA3			0xf00
+#define	BSFACTOR_QMA4			0xf000
+#define	BSFACTOR_QMA5			0xf0000
+#define	BSFACTOR_QMA6			0xf0000
+#define	BSFACTOR_QMA7			0xf00000
+#define	BSFACTOR_QMA8			0xf000000
+#define	BSFACTOR_QMA9			0xf0000000
+#define	BCSI_SCHEME			0x100000
 
 #define	BNOISE_LVL_TOP_SET		0x3
-#define	BCHSMOOTH	0x4
-#define	BCHSMOOTH_CFG1	0x38
-#define	BCHSMOOTH_CFG2	0x1c0
-#define	BCHSMOOTH_CFG3	0xe00
-#define	BCHSMOOTH_CFG4	0x7000
-#define	BMRCMODE	0x800000
-#define	BTHEVMCFG	0x7000000
-
-#define	BLOOP_FIT_TYPE	0x1
-#define	BUPD_CFO	0x40
-#define	BUPD_CFO_OFFDATA	0x80
-#define	BADV_UPD_CFO	0x100
-#define	BADV_TIME_CTRL	0x800
-#define	BUPD_CLKO	0x1000
-#define	BFC	0x6000
-#define	BTRACKING_MODE	0x8000
-#define	BPHCMP_ENABLE	0x10000
-#define	BUPD_CLKO_LTF	0x20000
-#define	BCOM_CH_CFO	0x40000
-#define	BCSI_ESTI_MODE	0x80000
-#define	BADV_UPD_EQZ	0x100000
-#define	BUCHCFG	0x7000000
-#define	BUPDEQZ	0x8000000
+#define	BCHSMOOTH			0x4
+#define	BCHSMOOTH_CFG1			0x38
+#define	BCHSMOOTH_CFG2			0x1c0
+#define	BCHSMOOTH_CFG3			0xe00
+#define	BCHSMOOTH_CFG4			0x7000
+#define	BMRCMODE			0x800000
+#define	BTHEVMCFG			0x7000000
+
+#define	BLOOP_FIT_TYPE			0x1
+#define	BUPD_CFO			0x40
+#define	BUPD_CFO_OFFDATA		0x80
+#define	BADV_UPD_CFO			0x100
+#define	BADV_TIME_CTRL			0x800
+#define	BUPD_CLKO			0x1000
+#define	BFC				0x6000
+#define	BTRACKING_MODE			0x8000
+#define	BPHCMP_ENABLE			0x10000
+#define	BUPD_CLKO_LTF			0x20000
+#define	BCOM_CH_CFO			0x40000
+#define	BCSI_ESTI_MODE			0x80000
+#define	BADV_UPD_EQZ			0x100000
+#define	BUCHCFG				0x7000000
+#define	BUPDEQZ				0x8000000
 
 #define	BRX_PESUDO_NOISE_ON		0x20000000
-#define	BRX_PESUDO_NOISE_A	0xff
-#define	BRX_PESUDO_NOISE_B	0xff00
-#define	BRX_PESUDO_NOISE_C	0xff0000
-#define	BRX_PESUDO_NOISE_D	0xff000000
+#define	BRX_PESUDO_NOISE_A		0xff
+#define	BRX_PESUDO_NOISE_B		0xff00
+#define	BRX_PESUDO_NOISE_C		0xff0000
+#define	BRX_PESUDO_NOISE_D		0xff000000
 #define	BRX_PESUDO_NOISESTATE_A		0xffff
 #define	BRX_PESUDO_NOISESTATE_B		0xffff0000
 #define	BRX_PESUDO_NOISESTATE_C		0xffff
 #define	BRX_PESUDO_NOISESTATE_D		0xffff0000
 
-#define	BZEBRA1_HSSIENABLE	0x8
-#define	BZEBRA1_TRXCONTROL	0xc00
-#define	BZEBRA1_TRXGAINSETTING	0x07f
-#define	BZEBRA1_RXCOUNTER	0xc00
-#define	BZEBRA1_TXCHANGEPUMP	0x38
-#define	BZEBRA1_RXCHANGEPUMP	0x7
-#define	BZEBRA1_CHANNEL_NUM	0xf80
-#define	BZEBRA1_TXLPFBW	0x400
-#define	BZEBRA1_RXLPFBW	0x600
+#define	BZEBRA1_HSSIENABLE		0x8
+#define	BZEBRA1_TRXCONTROL		0xc00
+#define	BZEBRA1_TRXGAINSETTING		0x07f
+#define	BZEBRA1_RXCOUNTER		0xc00
+#define	BZEBRA1_TXCHANGEPUMP		0x38
+#define	BZEBRA1_RXCHANGEPUMP		0x7
+#define	BZEBRA1_CHANNEL_NUM		0xf80
+#define	BZEBRA1_TXLPFBW			0x400
+#define	BZEBRA1_RXLPFBW			0x600
 
 #define	BRTL8256REG_MODE_CTRL1		0x100
 #define	BRTL8256REG_MODE_CTRL0		0x40
 #define	BRTL8256REG_TXLPFBW		0x18
 #define	BRTL8256REG_RXLPFBW		0x600
 
-#define	BRTL8258_TXLPFBW	0xc
-#define	BRTL8258_RXLPFBW	0xc00
-#define	BRTL8258_RSSILPFBW	0xc0
-
-#define	BBYTE0	0x1
-#define	BBYTE1	0x2
-#define	BBYTE2	0x4
-#define	BBYTE3	0x8
-#define	BWORD0	0x3
-#define	BWORD1	0xc
-#define	BWORD	0xf
-
-#define	BENABLE	0x1
-#define	BDISABLE	0x0
-
-#define	LEFT_ANTENNA	0x0
-#define	RIGHT_ANTENNA	0x1
-
-#define	TCHECK_TXSTATUS	500
-#define	TUPDATE_RXCOUNTER	100
+#define	BRTL8258_TXLPFBW		0xc
+#define	BRTL8258_RXLPFBW		0xc00
+#define	BRTL8258_RSSILPFBW		0xc0
+
+#define	BBYTE0				0x1
+#define	BBYTE1				0x2
+#define	BBYTE2				0x4
+#define	BBYTE3				0x8
+#define	BWORD0				0x3
+#define	BWORD1				0xc
+#define	BWORD				0xf
+
+#define	MASKBYTE0			0xff
+#define	MASKBYTE1			0xff00
+#define	MASKBYTE2			0xff0000
+#define	MASKBYTE3			0xff000000
+#define	MASKHWORD			0xffff0000
+#define	MASKLWORD			0x0000ffff
+#define	MASKDWORD			0xffffffff
+#define	MASK12BITS			0xfff
+#define	MASKH4BITS			0xf0000000
+#define MASKOFDM_D			0xffc00000
+#define	MASKCCK				0x3f3f3f3f
+
+#define	MASK4BITS			0x0f
+#define	MASK20BITS			0xfffff
+#define RFREG_OFFSET_MASK		0xfffff
+
+#define	BENABLE				0x1
+#define	BDISABLE			0x0
+
+#define	LEFT_ANTENNA			0x0
+#define	RIGHT_ANTENNA			0x1
+
+#define	TCHECK_TXSTATUS			500
+#define	TUPDATE_RXCOUNTER		100
 
 #define	REG_UN_used_register		0x01bf
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/rf.c b/drivers/net/wireless/rtlwifi/rtl8723be/rf.c
index 4862949..5ed4492 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/rf.c
@@ -51,7 +51,7 @@ void rtl8723be_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 			      rtlphy->rfreg_chnlval[0]);
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "unknown bandwidth: %#X\n", bandwidth);
 		break;
 	}
@@ -93,18 +93,20 @@ void rtl8723be_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 				       (ppowerlevel[idx1] << 16) |
 				       (ppowerlevel[idx1] << 24);
 		}
+
 		if (rtlefuse->eeprom_regulatory == 0) {
 			tmpval =
-			    (rtlphy->mcs_offset[0][6]) +
-			    (rtlphy->mcs_offset[0][7] << 8);
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][6]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][7] << 8);
 			tx_agc[RF90_PATH_A] += tmpval;
 
-			tmpval = (rtlphy->mcs_offset[0][14]) +
-				 (rtlphy->mcs_offset[0][15] <<
+			tmpval = (rtlphy->mcs_txpwrlevel_origoffset[0][14]) +
+				 (rtlphy->mcs_txpwrlevel_origoffset[0][15] <<
 				  24);
 			tx_agc[RF90_PATH_B] += tmpval;
 		}
 	}
+
 	for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
 		ptr = (u8 *)(&(tx_agc[idx1]));
 		for (idx2 = 0; idx2 < 4; idx2++) {
@@ -124,30 +126,32 @@ void rtl8723be_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 	tmpval = tx_agc[RF90_PATH_A] & 0xff;
 	rtl_set_bbreg(hw, RTXAGC_A_CCK1_MCS32, MASKBYTE1, tmpval);
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
+	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+		"CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
 		 RTXAGC_A_CCK1_MCS32);
 
 	tmpval = tx_agc[RF90_PATH_A] >> 8;
 
+	/*tmpval = tmpval & 0xff00ffff;*/
+
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
+	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+		"CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
 		 RTXAGC_B_CCK11_A_CCK2_11);
 
 	tmpval = tx_agc[RF90_PATH_B] >> 24;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, MASKBYTE0, tmpval);
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
+	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+		"CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
 		 RTXAGC_B_CCK11_A_CCK2_11);
 
 	tmpval = tx_agc[RF90_PATH_B] & 0x00ffffff;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32, 0xffffff00, tmpval);
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
+	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+		"CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
 		 RTXAGC_B_CCK1_55_MCS32);
 }
 
@@ -169,8 +173,8 @@ static void rtl8723be_phy_get_power_base(struct ieee80211_hw *hw,
 		powerbase0 = (powerbase0 << 24) | (powerbase0 << 16) |
 		    (powerbase0 << 8) | powerbase0;
 		*(ofdmbase + i) = powerbase0;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 " [OFDM power base index rf(%c) = 0x%x]\n",
+		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+			" [OFDM power base index rf(%c) = 0x%x]\n",
 			 ((i == 0) ? 'A' : 'B'), *(ofdmbase + i));
 	}
 
@@ -179,27 +183,30 @@ static void rtl8723be_phy_get_power_base(struct ieee80211_hw *hw,
 			powerlevel[i] = ppowerlevel_bw20[i];
 		else
 			powerlevel[i] = ppowerlevel_bw40[i];
+
 		powerbase1 = powerlevel[i];
 		powerbase1 = (powerbase1 << 24) | (powerbase1 << 16) |
 			     (powerbase1 << 8) | powerbase1;
 
 		*(mcsbase + i) = powerbase1;
 
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 			" [MCS power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(mcsbase + i));
+			 ((i == 0) ? 'A' : 'B'), *(mcsbase + i));
 	}
 }
 
-static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
-				u32 *powerbase0, u32 *powerbase1,
-				u32 *p_outwriteval)
+static void _rtl8723be_get_txpower_writeval_by_regulatory(
+							struct ieee80211_hw *hw,
+							u8 channel, u8 index,
+							u32 *powerbase0,
+							u32 *powerbase1,
+							u32 *p_outwriteval)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-	u8 i, chnlgroup = 0, pwr_diff_limit[4];
-	u8 pwr_diff = 0, customer_pwr_diff;
+	u8 i, chnlgroup = 0, pwr_diff_limit[4], pwr_diff = 0, customer_pwr_diff;
 	u32 writeval, customer_limit, rf;
 
 	for (rf = 0; rf < 2; rf++) {
@@ -208,13 +215,13 @@ static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
 			chnlgroup = 0;
 
 			writeval =
-			    rtlphy->mcs_offset[chnlgroup][index + (rf ? 8 : 0)]
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup][index +
+								(rf ? 8 : 0)]
 			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "RTK better performance, "
-				 "writeval(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeval);
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"RTK better performance, writeval(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		case 1:
 			if (rtlphy->pwrgroup_cnt == 1) {
@@ -233,43 +240,41 @@ static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
 				else if (channel == 14)
 					chnlgroup = 5;
 			}
-			writeval = rtlphy->mcs_offset[chnlgroup]
+
+			writeval =
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
 			    [index + (rf ? 8 : 0)] + ((index < 2) ?
 						      powerbase0[rf] :
 						      powerbase1[rf]);
 
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "Realtek regulatory, 20MHz, "
-				 "writeval(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeval);
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Realtek regulatory, 20MHz, writeval(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 
 			break;
 		case 2:
 			writeval =
 			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "Better regulatory, "
-				 "writeval(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeval);
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Better regulatory, writeval(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		case 3:
 			chnlgroup = 0;
 
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-					 "customer's limit, 40MHz "
-					 "rf(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'),
-					 rtlefuse->pwrgroup_ht40[rf]
-					 [channel-1]);
+				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+					"customer's limit, 40MHz rf(%c) = 0x%x\n",
+					((rf == 0) ? 'A' : 'B'),
+					rtlefuse->pwrgroup_ht40
+					[rf][channel - 1]);
 			} else {
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-					 "customer's limit, 20MHz "
-					 "rf(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'),
-					 rtlefuse->pwrgroup_ht20[rf]
-					 [channel-1]);
+				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+					"customer's limit, 20MHz rf(%c) = 0x%x\n",
+					((rf == 0) ? 'A' : 'B'),
+					rtlefuse->pwrgroup_ht20
+					[rf][channel - 1]);
 			}
 
 			if (index < 2)
@@ -294,9 +299,9 @@ static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
 
 			for (i = 0; i < 4; i++) {
 				pwr_diff_limit[i] =
-				    (u8)((rtlphy->mcs_offset
-					  [chnlgroup][index + (rf ? 8 : 0)] &
-					  (0x7f << (i * 8))) >> (i * 8));
+				    (u8)((rtlphy->mcs_txpwrlevel_origoffset
+					   [chnlgroup][index + (rf ? 8 : 0)] &
+					      (0x7f << (i * 8))) >> (i * 8));
 
 					if (pwr_diff_limit[i] > pwr_diff)
 						pwr_diff_limit[i] = pwr_diff;
@@ -307,29 +312,28 @@ static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
 					 (pwr_diff_limit[1] << 8) |
 					 (pwr_diff_limit[0]);
 
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 				"Customer's limit rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), customer_limit);
+				 ((rf == 0) ? 'A' : 'B'), customer_limit);
 
 			writeval = customer_limit + ((index < 2) ?
 						      powerbase0[rf] :
 						      powerbase1[rf]);
 
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "Customer, writeval rf(%c)= 0x%x\n",
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Customer, writeval rf(%c)= 0x%x\n",
 				 ((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		default:
 			chnlgroup = 0;
 			writeval =
-			    rtlphy->mcs_offset[chnlgroup]
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
 			    [index + (rf ? 8 : 0)]
 			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 "RTK better performance, writeval "
-				 "rf(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeval);
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"RTK better performance, writeval rf(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		}
 
@@ -343,7 +347,7 @@ static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
 }
 
 static void _rtl8723be_write_ofdm_power_reg(struct ieee80211_hw *hw,
-					 u8 index, u32 *value)
+					 u8 index, u32 *pvalue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 regoffset_a[6] = {
@@ -361,9 +365,9 @@ static void _rtl8723be_write_ofdm_power_reg(struct ieee80211_hw *hw,
 	u16 regoffset;
 
 	for (rf = 0; rf < 2; rf++) {
-		writeval = value[rf];
+		writeval = pvalue[rf];
 		for (i = 0; i < 4; i++) {
-			pwr_val[i] = (u8) ((writeval & (0x7f <<
+			pwr_val[i] = (u8)((writeval & (0x7f <<
 							(i * 8))) >> (i * 8));
 
 			if (pwr_val[i] > RF6052_MAX_TX_PWR)
@@ -378,8 +382,8 @@ static void _rtl8723be_write_ofdm_power_reg(struct ieee80211_hw *hw,
 			regoffset = regoffset_b[index];
 		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeval);
 
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 "Set 0x%x = %08x\n", regoffset, writeval);
+		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+			"Set 0x%x = %08x\n", regoffset, writeval);
 	}
 }
 
@@ -400,8 +404,11 @@ void rtl8723be_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
 	rtl8723be_dm_txpower_track_adjust(hw, 1, &direction, &pwrtrac_value);
 
 	for (index = 0; index < 6; index++) {
-		txpwr_by_regulatory(hw, channel, index, &powerbase0[0],
-				    &powerbase1[0], &writeval[0]);
+		_rtl8723be_get_txpower_writeval_by_regulatory(hw,
+							      channel, index,
+							      &powerbase0[0],
+							      &powerbase1[0],
+							      &writeval[0]);
 		if (direction == 1) {
 			writeval[0] += pwrtrac_value;
 			writeval[1] += pwrtrac_value;
@@ -424,16 +431,17 @@ bool rtl8723be_phy_rf6052_config(struct ieee80211_hw *hw)
 		rtlphy->num_total_rfpath = 2;
 
 	return _rtl8723be_phy_rf6052_config_parafile(hw);
+
 }
 
 static bool _rtl8723be_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct bb_reg_def *pphyreg;
 	u32 u4_regvalue = 0;
 	u8 rfpath;
 	bool rtstatus = true;
+	struct bb_reg_def *pphyreg;
 
 	for (rfpath = 0; rfpath < rtlphy->num_total_rfpath; rfpath++) {
 		pphyreg = &rtlphy->phyreg_def[rfpath];
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index 8b4a5f3..223eb42 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -31,6 +31,7 @@
 #include "phy.h"
 #include "../rtl8723com/phy_common.h"
 #include "dm.h"
+#include "../rtl8723com/dm_common.h"
 #include "hw.h"
 #include "fw.h"
 #include "../rtl8723com/fw_common.h"
@@ -101,6 +102,8 @@ int rtl8723be_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->dm.thermalvalue = 0;
 	rtlpci->transmit_config = CFENDFORM | BIT(15) | BIT(24) | BIT(25);
 
+	rtlpriv->phy.lck_inprogress = false;
+
 	mac->ht_enable = true;
 
 	/* compatible 5G band 88ce just 2.4G band & smsp */
@@ -137,12 +140,19 @@ int rtl8723be_init_sw_vars(struct ieee80211_hw *hw)
 
 	rtlpci->irq_mask[1] = (u32)(IMR_RXFOVW | 0);
 
+	rtlpci->sys_irq_mask = (u32)(HSIMR_PDN_INT_EN	|
+				     HSIMR_RON_INT_EN	|
+				     0);
+
 	/* for debug level */
 	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
 	/* for LPS & IPS */
 	rtlpriv->psc.inactiveps = rtlpriv->cfg->mod_params->inactiveps;
 	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
 	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
+	rtlpci->msi_support = rtlpriv->cfg->mod_params->msi_support;
+	if (rtlpriv->cfg->mod_params->disable_watchdog)
+		pr_info("watchdog disabled\n");
 	rtlpriv->psc.reg_fwctrl_lps = 3;
 	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
 	/* for ASPM, you can close aspm through
@@ -157,6 +167,11 @@ int rtl8723be_init_sw_vars(struct ieee80211_hw *hw)
 	else if (rtlpriv->psc.reg_fwctrl_lps == 3)
 		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
 
+	/*low power: Disable 32k */
+	rtlpriv->psc.low_power_enable = false;
+
+	rtlpriv->rtlhal.earlymode_enable = false;
+
 	/* for firmware buf */
 	rtlpriv->rtlhal.pfirmware = vzalloc(0x8000);
 	if (!rtlpriv->rtlhal.pfirmware) {
@@ -182,8 +197,6 @@ void rtl8723be_deinit_sw_vars(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (rtlpriv->cfg->ops->get_btc_status())
-		rtlpriv->btcoexist.btc_ops->btc_halt_notify();
 	if (rtlpriv->rtlhal.pfirmware) {
 		vfree(rtlpriv->rtlhal.pfirmware);
 		rtlpriv->rtlhal.pfirmware = NULL;
@@ -245,6 +258,7 @@ static struct rtl_hal_ops rtl8723be_hal_ops = {
 	.set_rfreg = rtl8723be_phy_set_rf_reg,
 	.fill_h2c_cmd = rtl8723be_fill_h2c_cmd,
 	.get_btc_status = rtl8723be_get_btc_status,
+	.rx_command_packet = rtl8723be_rx_command_packet,
 	.is_fw_header = is_fw_header,
 };
 
@@ -253,8 +267,6 @@ static struct rtl_mod_params rtl8723be_mod_params = {
 	.inactiveps = true,
 	.swctrl_lps = false,
 	.fwctrl_lps = true,
-	.msi_support = false,
-	.debug = DBG_EMERG,
 };
 
 static struct rtl_hal_cfg rtl8723be_hal_cfg = {
@@ -272,6 +284,9 @@ static struct rtl_hal_cfg rtl8723be_hal_cfg = {
 	.maps[MAC_RCR_ACRC32] = ACRC32,
 	.maps[MAC_RCR_ACF] = ACF,
 	.maps[MAC_RCR_AAP] = AAP,
+	.maps[MAC_HIMR] = REG_HIMR,
+	.maps[MAC_HIMRE] = REG_HIMRE,
+	.maps[MAC_HSISR] = REG_HSISR,
 
 	.maps[EFUSE_ACCESS] = REG_EFUSE_ACCESS,
 
@@ -305,6 +320,7 @@ static struct rtl_hal_cfg rtl8723be_hal_cfg = {
 	.maps[RTL_IMR_BCNDMAINT3] = IMR_BCNDMAINT3,
 	.maps[RTL_IMR_BCNDMAINT2] = IMR_BCNDMAINT2,
 	.maps[RTL_IMR_BCNDMAINT1] = IMR_BCNDMAINT1,
+/*	.maps[RTL_IMR_BCNDOK8] = IMR_BCNDOK8,     */   /*need check*/
 	.maps[RTL_IMR_BCNDOK7] = IMR_BCNDOK7,
 	.maps[RTL_IMR_BCNDOK6] = IMR_BCNDOK6,
 	.maps[RTL_IMR_BCNDOK5] = IMR_BCNDOK5,
@@ -312,6 +328,8 @@ static struct rtl_hal_cfg rtl8723be_hal_cfg = {
 	.maps[RTL_IMR_BCNDOK3] = IMR_BCNDOK3,
 	.maps[RTL_IMR_BCNDOK2] = IMR_BCNDOK2,
 	.maps[RTL_IMR_BCNDOK1] = IMR_BCNDOK1,
+/*	.maps[RTL_IMR_TIMEOUT2] = IMR_TIMEOUT2,*/
+/*	.maps[RTL_IMR_TIMEOUT1] = IMR_TIMEOUT1,*/
 
 	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
 	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
@@ -329,6 +347,7 @@ static struct rtl_hal_cfg rtl8723be_hal_cfg = {
 	.maps[RTL_IMR_VIDOK] = IMR_VIDOK,
 	.maps[RTL_IMR_VODOK] = IMR_VODOK,
 	.maps[RTL_IMR_ROK] = IMR_ROK,
+	.maps[RTL_IMR_HSISR_IND] = IMR_HSISR_IND_ON_INT,
 	.maps[RTL_IBSS_INT_MASKS] = (IMR_BCNDMAINT0 | IMR_TBDOK | IMR_TBDER),
 
 	.maps[RTL_RC_CCK_RATE1M] = DESC92C_RATE1M,
@@ -348,12 +367,12 @@ static struct rtl_hal_cfg rtl8723be_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
 };
 
-static const struct pci_device_id rtl8723be_pci_id[] = {
-	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0xb723, rtl8723be_hal_cfg)},
+static struct pci_device_id rtl8723be_pci_ids[] = {
+	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0xB723, rtl8723be_hal_cfg)},
 	{},
 };
 
-MODULE_DEVICE_TABLE(pci, rtl8723be_pci_id);
+MODULE_DEVICE_TABLE(pci, rtl8723be_pci_ids);
 
 MODULE_AUTHOR("PageHe	<page_he@realsil.com.cn>");
 MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
@@ -366,21 +385,22 @@ module_param_named(debug, rtl8723be_mod_params.debug, int, 0444);
 module_param_named(ips, rtl8723be_mod_params.inactiveps, bool, 0444);
 module_param_named(swlps, rtl8723be_mod_params.swctrl_lps, bool, 0444);
 module_param_named(fwlps, rtl8723be_mod_params.fwctrl_lps, bool, 0444);
-module_param_named(msi, rtl8723be_mod_params.msi_support, bool, 0444);
+module_param_named(disable_watchdog, rtl8723be_mod_params.disable_watchdog,
+		   bool, 0444);
 MODULE_PARM_DESC(swenc, "using hardware crypto (default 0 [hardware])\n");
 MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
 MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is open)\n");
 MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 0)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
+MODULE_PARM_DESC(disable_watchdog, "Set to 1 to disable the watchdog (default 0)\n");
 
 static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
 
 static struct pci_driver rtl8723be_driver = {
 	.name = KBUILD_MODNAME,
-	.id_table = rtl8723be_pci_id,
+	.id_table = rtl8723be_pci_ids,
 	.probe = rtl_pci_probe,
 	.remove = rtl_pci_disconnect,
-
 	.driver.pm = &rtlwifi_pm_ops,
 };
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/table.c b/drivers/net/wireless/rtlwifi/rtl8723be/table.c
index 4b283cd..a180761 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/table.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/table.c
@@ -27,200 +27,201 @@
 
 #include "table.h"
 u32 RTL8723BEPHY_REG_1TARRAY[] = {
-	0x800, 0x80040000,
-	0x804, 0x00000003,
-	0x808, 0x0000FC00,
-	0x80C, 0x0000000A,
-	0x810, 0x10001331,
-	0x814, 0x020C3D10,
-	0x818, 0x02200385,
-	0x81C, 0x00000000,
-	0x820, 0x01000100,
-	0x824, 0x00390204,
-	0x828, 0x00000000,
-	0x82C, 0x00000000,
-	0x830, 0x00000000,
-	0x834, 0x00000000,
-	0x838, 0x00000000,
-	0x83C, 0x00000000,
-	0x840, 0x00010000,
-	0x844, 0x00000000,
-	0x848, 0x00000000,
-	0x84C, 0x00000000,
-	0x850, 0x00000000,
-	0x854, 0x00000000,
-	0x858, 0x569A11A9,
-	0x85C, 0x01000014,
-	0x860, 0x66F60110,
-	0x864, 0x061F0649,
-	0x868, 0x00000000,
-	0x86C, 0x27272700,
-	0x870, 0x07000760,
-	0x874, 0x25004000,
-	0x878, 0x00000808,
-	0x87C, 0x00000000,
-	0x880, 0xB0000C1C,
-	0x884, 0x00000001,
-	0x888, 0x00000000,
-	0x88C, 0xCCC000C0,
-	0x890, 0x00000800,
-	0x894, 0xFFFFFFFE,
-	0x898, 0x40302010,
-	0x89C, 0x00706050,
-	0x900, 0x00000000,
-	0x904, 0x00000023,
-	0x908, 0x00000000,
-	0x90C, 0x81121111,
-	0x910, 0x00000002,
-	0x914, 0x00000201,
-	0x948, 0x00000000,
-	0xA00, 0x00D047C8,
-	0xA04, 0x80FF000C,
-	0xA08, 0x8C838300,
-	0xA0C, 0x2E7F120F,
-	0xA10, 0x9500BB78,
-	0xA14, 0x1114D028,
-	0xA18, 0x00881117,
-	0xA1C, 0x89140F00,
-	0xA20, 0x1A1B0000,
-	0xA24, 0x090E1317,
-	0xA28, 0x00000204,
-	0xA2C, 0x00D30000,
-	0xA70, 0x101FBF00,
-	0xA74, 0x00000007,
-	0xA78, 0x00000900,
-	0xA7C, 0x225B0606,
-	0xA80, 0x21806490,
-	0xB2C, 0x00000000,
-	0xC00, 0x48071D40,
-	0xC04, 0x03A05611,
-	0xC08, 0x000000E4,
-	0xC0C, 0x6C6C6C6C,
-	0xC10, 0x08800000,
-	0xC14, 0x40000100,
-	0xC18, 0x08800000,
-	0xC1C, 0x40000100,
-	0xC20, 0x00000000,
-	0xC24, 0x00000000,
-	0xC28, 0x00000000,
-	0xC2C, 0x00000000,
-	0xC30, 0x69E9AC44,
-	0xC34, 0x469652AF,
-	0xC38, 0x49795994,
-	0xC3C, 0x0A97971C,
-	0xC40, 0x1F7C403F,
-	0xC44, 0x000100B7,
-	0xC48, 0xEC020107,
-	0xC4C, 0x007F037F,
-	0xC50, 0x69553420,
-	0xC54, 0x43BC0094,
-	0xC58, 0x00023169,
-	0xC5C, 0x00250492,
-	0xC60, 0x00000000,
-	0xC64, 0x7112848B,
-	0xC68, 0x47C00BFF,
-	0xC6C, 0x00000036,
-	0xC70, 0x2C7F000D,
-	0xC74, 0x020610DB,
-	0xC78, 0x0000001F,
-	0xC7C, 0x00B91612,
-	0xC80, 0x390000E4,
-	0xC84, 0x20F60000,
-	0xC88, 0x40000100,
-	0xC8C, 0x20200000,
-	0xC90, 0x00020E1A,
-	0xC94, 0x00000000,
-	0xC98, 0x00020E1A,
-	0xC9C, 0x00007F7F,
-	0xCA0, 0x00000000,
-	0xCA4, 0x000300A0,
-	0xCA8, 0x00000000,
-	0xCAC, 0x00000000,
-	0xCB0, 0x00000000,
-	0xCB4, 0x00000000,
-	0xCB8, 0x00000000,
-	0xCBC, 0x28000000,
-	0xCC0, 0x00000000,
-	0xCC4, 0x00000000,
-	0xCC8, 0x00000000,
-	0xCCC, 0x00000000,
-	0xCD0, 0x00000000,
-	0xCD4, 0x00000000,
-	0xCD8, 0x64B22427,
-	0xCDC, 0x00766932,
-	0xCE0, 0x00222222,
-	0xCE4, 0x00000000,
-	0xCE8, 0x37644302,
-	0xCEC, 0x2F97D40C,
-	0xD00, 0x00000740,
-	0xD04, 0x40020401,
-	0xD08, 0x0000907F,
-	0xD0C, 0x20010201,
-	0xD10, 0xA0633333,
-	0xD14, 0x3333BC53,
-	0xD18, 0x7A8F5B6F,
-	0xD2C, 0xCC979975,
-	0xD30, 0x00000000,
-	0xD34, 0x80608000,
-	0xD38, 0x00000000,
-	0xD3C, 0x00127353,
-	0xD40, 0x00000000,
-	0xD44, 0x00000000,
-	0xD48, 0x00000000,
-	0xD4C, 0x00000000,
-	0xD50, 0x6437140A,
-	0xD54, 0x00000000,
-	0xD58, 0x00000282,
-	0xD5C, 0x30032064,
-	0xD60, 0x4653DE68,
-	0xD64, 0x04518A3C,
-	0xD68, 0x00002101,
-	0xD6C, 0x2A201C16,
-	0xD70, 0x1812362E,
-	0xD74, 0x322C2220,
-	0xD78, 0x000E3C24,
-	0xE00, 0x2D2D2D2D,
-	0xE04, 0x2D2D2D2D,
-	0xE08, 0x0390272D,
-	0xE10, 0x2D2D2D2D,
-	0xE14, 0x2D2D2D2D,
-	0xE18, 0x2D2D2D2D,
-	0xE1C, 0x2D2D2D2D,
-	0xE28, 0x00000000,
-	0xE30, 0x1000DC1F,
-	0xE34, 0x10008C1F,
-	0xE38, 0x02140102,
-	0xE3C, 0x681604C2,
-	0xE40, 0x01007C00,
-	0xE44, 0x01004800,
-	0xE48, 0xFB000000,
-	0xE4C, 0x000028D1,
-	0xE50, 0x1000DC1F,
-	0xE54, 0x10008C1F,
-	0xE58, 0x02140102,
-	0xE5C, 0x28160D05,
-	0xE60, 0x00000008,
-	0xE68, 0x001B2556,
-	0xE6C, 0x00C00096,
-	0xE70, 0x00C00096,
-	0xE74, 0x01000056,
-	0xE78, 0x01000014,
-	0xE7C, 0x01000056,
-	0xE80, 0x01000014,
-	0xE84, 0x00C00096,
-	0xE88, 0x01000056,
-	0xE8C, 0x00C00096,
-	0xED0, 0x00C00096,
-	0xED4, 0x00C00096,
-	0xED8, 0x00C00096,
-	0xEDC, 0x000000D6,
-	0xEE0, 0x000000D6,
-	0xEEC, 0x01C00016,
-	0xF14, 0x00000003,
-	0xF4C, 0x00000000,
-	0xF00, 0x00000300,
-	0x820, 0x01000100,
-	0x800, 0x83040000,
+		0x800, 0x80040000,
+		0x804, 0x00000003,
+		0x808, 0x0000FC00,
+		0x80C, 0x0000000A,
+		0x810, 0x10001331,
+		0x814, 0x020C3D10,
+		0x818, 0x02200385,
+		0x81C, 0x00000000,
+		0x820, 0x01000100,
+		0x824, 0x00390204,
+		0x828, 0x00000000,
+		0x82C, 0x00000000,
+		0x830, 0x00000000,
+		0x834, 0x00000000,
+		0x838, 0x00000000,
+		0x83C, 0x00000000,
+		0x840, 0x00010000,
+		0x844, 0x00000000,
+		0x848, 0x00000000,
+		0x84C, 0x00000000,
+		0x850, 0x00000000,
+		0x854, 0x00000000,
+		0x858, 0x569A11A9,
+		0x85C, 0x01000014,
+		0x860, 0x66F60110,
+		0x864, 0x061F0649,
+		0x868, 0x00000000,
+		0x86C, 0x27272700,
+		0x870, 0x07000760,
+		0x874, 0x25004000,
+		0x878, 0x00000808,
+		0x87C, 0x00000000,
+		0x880, 0xB0000C1C,
+		0x884, 0x00000001,
+		0x888, 0x00000000,
+		0x88C, 0xCCC000C0,
+		0x890, 0x00000800,
+		0x894, 0xFFFFFFFE,
+		0x898, 0x40302010,
+		0x89C, 0x00706050,
+		0x900, 0x00000000,
+		0x904, 0x00000023,
+		0x908, 0x00000000,
+		0x90C, 0x81121111,
+		0x910, 0x00000002,
+		0x914, 0x00000201,
+		0x948, 0x00000280,
+		0xA00, 0x00D047C8,
+		0xA04, 0x80FF000C,
+		0xA08, 0x8C838300,
+		0xA0C, 0x2E7F120F,
+		0xA10, 0x9500BB78,
+		0xA14, 0x1114D028,
+		0xA18, 0x00881117,
+		0xA1C, 0x89140F00,
+		0xA20, 0x1A1B0000,
+		0xA24, 0x090E1317,
+		0xA28, 0x00000204,
+		0xA2C, 0x00D30000,
+		0xA70, 0x101FBF00,
+		0xA74, 0x00000007,
+		0xA78, 0x00000900,
+		0xA7C, 0x225B0606,
+		0xA80, 0x21806490,
+		0xB2C, 0x00000000,
+		0xC00, 0x48071D40,
+		0xC04, 0x03A05611,
+		0xC08, 0x000000E4,
+		0xC0C, 0x6C6C6C6C,
+		0xC10, 0x08800000,
+		0xC14, 0x40000100,
+		0xC18, 0x08800000,
+		0xC1C, 0x40000100,
+		0xC20, 0x00000000,
+		0xC24, 0x00000000,
+		0xC28, 0x00000000,
+		0xC2C, 0x00000000,
+		0xC30, 0x69E9AC44,
+		0xC34, 0x469652AF,
+		0xC38, 0x49795994,
+		0xC3C, 0x0A97971C,
+		0xC40, 0x1F7C403F,
+		0xC44, 0x000100B7,
+		0xC48, 0xEC020107,
+		0xC4C, 0x007F037F,
+		0xC50, 0x69553420,
+		0xC54, 0x43BC0094,
+		0xC58, 0x00023169,
+		0xC5C, 0x00250492,
+		0xC60, 0x00000000,
+		0xC64, 0x7112848B,
+		0xC68, 0x47C00BFF,
+		0xC6C, 0x00000036,
+		0xC70, 0x2C7F000D,
+		0xC74, 0x020610DB,
+		0xC78, 0x0000001F,
+		0xC7C, 0x00B91612,
+		0xC80, 0x390000E4,
+		0xC84, 0x20F60000,
+		0xC88, 0x40000100,
+		0xC8C, 0x20200000,
+		0xC90, 0x00020E1A,
+		0xC94, 0x00000000,
+		0xC98, 0x00020E1A,
+		0xC9C, 0x00007F7F,
+		0xCA0, 0x00000000,
+		0xCA4, 0x000300A0,
+		0xCA8, 0x00000000,
+		0xCAC, 0x00000000,
+		0xCB0, 0x00000000,
+		0xCB4, 0x00000000,
+		0xCB8, 0x00000000,
+		0xCBC, 0x28000000,
+		0xCC0, 0x00000000,
+		0xCC4, 0x00000000,
+		0xCC8, 0x00000000,
+		0xCCC, 0x00000000,
+		0xCD0, 0x00000000,
+		0xCD4, 0x00000000,
+		0xCD8, 0x64B22427,
+		0xCDC, 0x00766932,
+		0xCE0, 0x00222222,
+		0xCE4, 0x00000000,
+		0xCE8, 0x37644302,
+		0xCEC, 0x2F97D40C,
+		0xD00, 0x00000740,
+		0xD04, 0x40020401,
+		0xD08, 0x0000907F,
+		0xD0C, 0x20010201,
+		0xD10, 0xA0633333,
+		0xD14, 0x3333BC53,
+		0xD18, 0x7A8F5B6F,
+		0xD2C, 0xCC979975,
+		0xD30, 0x00000000,
+		0xD34, 0x80608000,
+		0xD38, 0x00000000,
+		0xD3C, 0x00127353,
+		0xD40, 0x00000000,
+		0xD44, 0x00000000,
+		0xD48, 0x00000000,
+		0xD4C, 0x00000000,
+		0xD50, 0x6437140A,
+		0xD54, 0x00000000,
+		0xD58, 0x00000282,
+		0xD5C, 0x30032064,
+		0xD60, 0x4653DE68,
+		0xD64, 0x04518A3C,
+		0xD68, 0x00002101,
+		0xD6C, 0x2A201C16,
+		0xD70, 0x1812362E,
+		0xD74, 0x322C2220,
+		0xD78, 0x000E3C24,
+		0xE00, 0x2D2D2D2D,
+		0xE04, 0x2D2D2D2D,
+		0xE08, 0x0390272D,
+		0xE10, 0x2D2D2D2D,
+		0xE14, 0x2D2D2D2D,
+		0xE18, 0x2D2D2D2D,
+		0xE1C, 0x2D2D2D2D,
+		0xE28, 0x00000000,
+		0xE30, 0x1000DC1F,
+		0xE34, 0x10008C1F,
+		0xE38, 0x02140102,
+		0xE3C, 0x681604C2,
+		0xE40, 0x01007C00,
+		0xE44, 0x01004800,
+		0xE48, 0xFB000000,
+		0xE4C, 0x000028D1,
+		0xE50, 0x1000DC1F,
+		0xE54, 0x10008C1F,
+		0xE58, 0x02140102,
+		0xE5C, 0x28160D05,
+		0xE60, 0x00000008,
+		0xE68, 0x001B2556,
+		0xE6C, 0x00C00096,
+		0xE70, 0x00C00096,
+		0xE74, 0x01000056,
+		0xE78, 0x01000014,
+		0xE7C, 0x01000056,
+		0xE80, 0x01000014,
+		0xE84, 0x00C00096,
+		0xE88, 0x01000056,
+		0xE8C, 0x00C00096,
+		0xED0, 0x00C00096,
+		0xED4, 0x00C00096,
+		0xED8, 0x00C00096,
+		0xEDC, 0x000000D6,
+		0xEE0, 0x000000D6,
+		0xEEC, 0x01C00016,
+		0xF14, 0x00000003,
+		0xF4C, 0x00000000,
+		0xF00, 0x00000300,
+		0x820, 0x01000100,
+		0x800, 0x83040000,
+
 };
 
 u32 RTL8723BEPHY_REG_ARRAY_PG[] = {
@@ -233,340 +234,344 @@ u32 RTL8723BEPHY_REG_ARRAY_PG[] = {
 };
 
 u32 RTL8723BE_RADIOA_1TARRAY[] = {
-	0x000, 0x00010000,
-	0x0B0, 0x000DFFE0,
-	0x0FE, 0x00000000,
-	0x0FE, 0x00000000,
-	0x0FE, 0x00000000,
-	0x0B1, 0x00000018,
-	0x0FE, 0x00000000,
-	0x0FE, 0x00000000,
-	0x0FE, 0x00000000,
-	0x0B2, 0x00084C00,
-	0x0B5, 0x0000D2CC,
-	0x0B6, 0x000925AA,
-	0x0B7, 0x00000010,
-	0x0B8, 0x0000907F,
-	0x05C, 0x00000002,
-	0x07C, 0x00000002,
-	0x07E, 0x00000005,
-	0x08B, 0x0006FC00,
-	0x0B0, 0x000FF9F0,
-	0x01C, 0x000739D2,
-	0x01E, 0x00000000,
-	0x0DF, 0x00000780,
-	0x050, 0x00067435,
-	0x051, 0x0006B04E,
-	0x052, 0x000007D2,
-	0x053, 0x00000000,
-	0x054, 0x00050400,
-	0x055, 0x0004026E,
-	0x0DD, 0x0000004C,
-	0x070, 0x00067435,
-	0x071, 0x0006B04E,
-	0x072, 0x000007D2,
-	0x073, 0x00000000,
-	0x074, 0x00050400,
-	0x075, 0x0004026E,
-	0x0EF, 0x00000100,
-	0x034, 0x0000ADD7,
-	0x035, 0x00005C00,
-	0x034, 0x00009DD4,
-	0x035, 0x00005000,
-	0x034, 0x00008DD1,
-	0x035, 0x00004400,
-	0x034, 0x00007DCE,
-	0x035, 0x00003800,
-	0x034, 0x00006CD1,
-	0x035, 0x00004400,
-	0x034, 0x00005CCE,
-	0x035, 0x00003800,
-	0x034, 0x000048CE,
-	0x035, 0x00004400,
-	0x034, 0x000034CE,
-	0x035, 0x00003800,
-	0x034, 0x00002451,
-	0x035, 0x00004400,
-	0x034, 0x0000144E,
-	0x035, 0x00003800,
-	0x034, 0x00000051,
-	0x035, 0x00004400,
-	0x0EF, 0x00000000,
-	0x0EF, 0x00000100,
-	0x0ED, 0x00000010,
-	0x044, 0x0000ADD7,
-	0x044, 0x00009DD4,
-	0x044, 0x00008DD1,
-	0x044, 0x00007DCE,
-	0x044, 0x00006CC1,
-	0x044, 0x00005CCE,
-	0x044, 0x000044D1,
-	0x044, 0x000034CE,
-	0x044, 0x00002451,
-	0x044, 0x0000144E,
-	0x044, 0x00000051,
-	0x0EF, 0x00000000,
-	0x0ED, 0x00000000,
-	0x0EF, 0x00002000,
-	0x03B, 0x000380EF,
-	0x03B, 0x000302FE,
-	0x03B, 0x00028CE6,
-	0x03B, 0x000200BC,
-	0x03B, 0x000188A5,
-	0x03B, 0x00010FBC,
-	0x03B, 0x00008F71,
-	0x03B, 0x00000900,
-	0x0EF, 0x00000000,
-	0x0ED, 0x00000001,
-	0x040, 0x000380EF,
-	0x040, 0x000302FE,
-	0x040, 0x00028CE6,
-	0x040, 0x000200BC,
-	0x040, 0x000188A5,
-	0x040, 0x00010FBC,
-	0x040, 0x00008F71,
-	0x040, 0x00000900,
-	0x0ED, 0x00000000,
-	0x082, 0x00080000,
-	0x083, 0x00008000,
-	0x084, 0x00048D80,
-	0x085, 0x00068000,
-	0x0A2, 0x00080000,
-	0x0A3, 0x00008000,
-	0x0A4, 0x00048D80,
-	0x0A5, 0x00068000,
-	0x000, 0x00033D80,
+		0x000, 0x00010000,
+		0x0B0, 0x000DFFE0,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0B1, 0x00000018,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0B2, 0x00084C00,
+		0x0B5, 0x0000D2CC,
+		0x0B6, 0x000925AA,
+		0x0B7, 0x00000010,
+		0x0B8, 0x0000907F,
+		0x05C, 0x00000002,
+		0x07C, 0x00000002,
+		0x07E, 0x00000005,
+		0x08B, 0x0006FC00,
+		0x0B0, 0x000FF9F0,
+		0x01C, 0x000739D2,
+		0x01E, 0x00000000,
+		0x0DF, 0x00000780,
+		0x050, 0x00067435,
+		0x051, 0x0006B04E,
+		0x052, 0x000007D2,
+		0x053, 0x00000000,
+		0x054, 0x00050400,
+		0x055, 0x0004026E,
+		0x0DD, 0x0000004C,
+		0x070, 0x00067435,
+		0x071, 0x0006B04E,
+		0x072, 0x000007D2,
+		0x073, 0x00000000,
+		0x074, 0x00050400,
+		0x075, 0x0004026E,
+		0x0EF, 0x00000100,
+		0x034, 0x0000ADD7,
+		0x035, 0x00005C00,
+		0x034, 0x00009DD4,
+		0x035, 0x00005000,
+		0x034, 0x00008DD1,
+		0x035, 0x00004400,
+		0x034, 0x00007DCE,
+		0x035, 0x00003800,
+		0x034, 0x00006CD1,
+		0x035, 0x00004400,
+		0x034, 0x00005CCE,
+		0x035, 0x00003800,
+		0x034, 0x000048CE,
+		0x035, 0x00004400,
+		0x034, 0x000034CE,
+		0x035, 0x00003800,
+		0x034, 0x00002451,
+		0x035, 0x00004400,
+		0x034, 0x0000144E,
+		0x035, 0x00003800,
+		0x034, 0x00000051,
+		0x035, 0x00004400,
+		0x0EF, 0x00000000,
+		0x0EF, 0x00000100,
+		0x0ED, 0x00000010,
+		0x044, 0x0000ADD7,
+		0x044, 0x00009DD4,
+		0x044, 0x00008DD1,
+		0x044, 0x00007DCE,
+		0x044, 0x00006CC1,
+		0x044, 0x00005CCE,
+		0x044, 0x000044D1,
+		0x044, 0x000034CE,
+		0x044, 0x00002451,
+		0x044, 0x0000144E,
+		0x044, 0x00000051,
+		0x0EF, 0x00000000,
+		0x0ED, 0x00000000,
+		0x0EF, 0x00002000,
+		0x03B, 0x000380EF,
+		0x03B, 0x000302FE,
+		0x03B, 0x00028CE6,
+		0x03B, 0x000200BC,
+		0x03B, 0x000188A5,
+		0x03B, 0x00010FBC,
+		0x03B, 0x00008F71,
+		0x03B, 0x00000900,
+		0x0EF, 0x00000000,
+		0x0ED, 0x00000001,
+		0x040, 0x000380EF,
+		0x040, 0x000302FE,
+		0x040, 0x00028CE6,
+		0x040, 0x000200BC,
+		0x040, 0x000188A5,
+		0x040, 0x00010FBC,
+		0x040, 0x00008F71,
+		0x040, 0x00000900,
+		0x0ED, 0x00000000,
+		0x082, 0x00080000,
+		0x083, 0x00008000,
+		0x084, 0x00048D80,
+		0x085, 0x00068000,
+		0x0A2, 0x00080000,
+		0x0A3, 0x00008000,
+		0x0A4, 0x00048D80,
+		0x0A5, 0x00068000,
+		0x000, 0x00033D80,
+
 };
 
 u32 RTL8723BEMAC_1T_ARRAY[] = {
-	0x02F, 0x00000030,
-	0x035, 0x00000000,
-	0x428, 0x0000000A,
-	0x429, 0x00000010,
-	0x430, 0x00000000,
-	0x431, 0x00000000,
-	0x432, 0x00000000,
-	0x433, 0x00000001,
-	0x434, 0x00000004,
-	0x435, 0x00000005,
-	0x436, 0x00000007,
-	0x437, 0x00000008,
-	0x43C, 0x00000004,
-	0x43D, 0x00000005,
-	0x43E, 0x00000007,
-	0x43F, 0x00000008,
-	0x440, 0x0000005D,
-	0x441, 0x00000001,
-	0x442, 0x00000000,
-	0x444, 0x00000010,
-	0x445, 0x00000000,
-	0x446, 0x00000000,
-	0x447, 0x00000000,
-	0x448, 0x00000000,
-	0x449, 0x000000F0,
-	0x44A, 0x0000000F,
-	0x44B, 0x0000003E,
-	0x44C, 0x00000010,
-	0x44D, 0x00000000,
-	0x44E, 0x00000000,
-	0x44F, 0x00000000,
-	0x450, 0x00000000,
-	0x451, 0x000000F0,
-	0x452, 0x0000000F,
-	0x453, 0x00000000,
-	0x456, 0x0000005E,
-	0x460, 0x00000066,
-	0x461, 0x00000066,
-	0x4C8, 0x000000FF,
-	0x4C9, 0x00000008,
-	0x4CC, 0x000000FF,
-	0x4CD, 0x000000FF,
-	0x4CE, 0x00000001,
-	0x500, 0x00000026,
-	0x501, 0x000000A2,
-	0x502, 0x0000002F,
-	0x503, 0x00000000,
-	0x504, 0x00000028,
-	0x505, 0x000000A3,
-	0x506, 0x0000005E,
-	0x507, 0x00000000,
-	0x508, 0x0000002B,
-	0x509, 0x000000A4,
-	0x50A, 0x0000005E,
-	0x50B, 0x00000000,
-	0x50C, 0x0000004F,
-	0x50D, 0x000000A4,
-	0x50E, 0x00000000,
-	0x50F, 0x00000000,
-	0x512, 0x0000001C,
-	0x514, 0x0000000A,
-	0x516, 0x0000000A,
-	0x525, 0x0000004F,
-	0x550, 0x00000010,
-	0x551, 0x00000010,
-	0x559, 0x00000002,
-	0x55C, 0x00000050,
-	0x55D, 0x000000FF,
-	0x605, 0x00000030,
-	0x608, 0x0000000E,
-	0x609, 0x0000002A,
-	0x620, 0x000000FF,
-	0x621, 0x000000FF,
-	0x622, 0x000000FF,
-	0x623, 0x000000FF,
-	0x624, 0x000000FF,
-	0x625, 0x000000FF,
-	0x626, 0x000000FF,
-	0x627, 0x000000FF,
-	0x638, 0x00000050,
-	0x63C, 0x0000000A,
-	0x63D, 0x0000000A,
-	0x63E, 0x0000000E,
-	0x63F, 0x0000000E,
-	0x640, 0x00000040,
-	0x642, 0x00000040,
-	0x643, 0x00000000,
-	0x652, 0x000000C8,
-	0x66E, 0x00000005,
-	0x700, 0x00000021,
-	0x701, 0x00000043,
-	0x702, 0x00000065,
-	0x703, 0x00000087,
-	0x708, 0x00000021,
-	0x709, 0x00000043,
-	0x70A, 0x00000065,
-	0x70B, 0x00000087,
+		0x02F, 0x00000030,
+		0x035, 0x00000000,
+		0x067, 0x00000020,
+		0x428, 0x0000000A,
+		0x429, 0x00000010,
+		0x430, 0x00000000,
+		0x431, 0x00000000,
+		0x432, 0x00000000,
+		0x433, 0x00000001,
+		0x434, 0x00000004,
+		0x435, 0x00000005,
+		0x436, 0x00000007,
+		0x437, 0x00000008,
+		0x43C, 0x00000004,
+		0x43D, 0x00000005,
+		0x43E, 0x00000007,
+		0x43F, 0x00000008,
+		0x440, 0x0000005D,
+		0x441, 0x00000001,
+		0x442, 0x00000000,
+		0x444, 0x00000010,
+		0x445, 0x00000000,
+		0x446, 0x00000000,
+		0x447, 0x00000000,
+		0x448, 0x00000000,
+		0x449, 0x000000F0,
+		0x44A, 0x0000000F,
+		0x44B, 0x0000003E,
+		0x44C, 0x00000010,
+		0x44D, 0x00000000,
+		0x44E, 0x00000000,
+		0x44F, 0x00000000,
+		0x450, 0x00000000,
+		0x451, 0x000000F0,
+		0x452, 0x0000000F,
+		0x453, 0x00000000,
+		0x456, 0x0000005E,
+		0x460, 0x00000066,
+		0x461, 0x00000066,
+		0x4C8, 0x000000FF,
+		0x4C9, 0x00000008,
+		0x4CC, 0x000000FF,
+		0x4CD, 0x000000FF,
+		0x4CE, 0x00000001,
+		0x500, 0x00000026,
+		0x501, 0x000000A2,
+		0x502, 0x0000002F,
+		0x503, 0x00000000,
+		0x504, 0x00000028,
+		0x505, 0x000000A3,
+		0x506, 0x0000005E,
+		0x507, 0x00000000,
+		0x508, 0x0000002B,
+		0x509, 0x000000A4,
+		0x50A, 0x0000005E,
+		0x50B, 0x00000000,
+		0x50C, 0x0000004F,
+		0x50D, 0x000000A4,
+		0x50E, 0x00000000,
+		0x50F, 0x00000000,
+		0x512, 0x0000001C,
+		0x514, 0x0000000A,
+		0x516, 0x0000000A,
+		0x525, 0x0000004F,
+		0x550, 0x00000010,
+		0x551, 0x00000010,
+		0x559, 0x00000002,
+		0x55C, 0x00000050,
+		0x55D, 0x000000FF,
+		0x605, 0x00000030,
+		0x608, 0x0000000E,
+		0x609, 0x0000002A,
+		0x620, 0x000000FF,
+		0x621, 0x000000FF,
+		0x622, 0x000000FF,
+		0x623, 0x000000FF,
+		0x624, 0x000000FF,
+		0x625, 0x000000FF,
+		0x626, 0x000000FF,
+		0x627, 0x000000FF,
+		0x638, 0x00000050,
+		0x63C, 0x0000000A,
+		0x63D, 0x0000000A,
+		0x63E, 0x0000000E,
+		0x63F, 0x0000000E,
+		0x640, 0x00000040,
+		0x642, 0x00000040,
+		0x643, 0x00000000,
+		0x652, 0x000000C8,
+		0x66E, 0x00000005,
+		0x700, 0x00000021,
+		0x701, 0x00000043,
+		0x702, 0x00000065,
+		0x703, 0x00000087,
+		0x708, 0x00000021,
+		0x709, 0x00000043,
+		0x70A, 0x00000065,
+		0x70B, 0x00000087,
+
 };
 
 u32 RTL8723BEAGCTAB_1TARRAY[] = {
-	0xC78, 0xFD000001,
-	0xC78, 0xFC010001,
-	0xC78, 0xFB020001,
-	0xC78, 0xFA030001,
-	0xC78, 0xF9040001,
-	0xC78, 0xF8050001,
-	0xC78, 0xF7060001,
-	0xC78, 0xF6070001,
-	0xC78, 0xF5080001,
-	0xC78, 0xF4090001,
-	0xC78, 0xF30A0001,
-	0xC78, 0xF20B0001,
-	0xC78, 0xF10C0001,
-	0xC78, 0xF00D0001,
-	0xC78, 0xEF0E0001,
-	0xC78, 0xEE0F0001,
-	0xC78, 0xED100001,
-	0xC78, 0xEC110001,
-	0xC78, 0xEB120001,
-	0xC78, 0xEA130001,
-	0xC78, 0xE9140001,
-	0xC78, 0xE8150001,
-	0xC78, 0xE7160001,
-	0xC78, 0xAA170001,
-	0xC78, 0xA9180001,
-	0xC78, 0xA8190001,
-	0xC78, 0xA71A0001,
-	0xC78, 0xA61B0001,
-	0xC78, 0xA51C0001,
-	0xC78, 0xA41D0001,
-	0xC78, 0xA31E0001,
-	0xC78, 0x671F0001,
-	0xC78, 0x66200001,
-	0xC78, 0x65210001,
-	0xC78, 0x64220001,
-	0xC78, 0x63230001,
-	0xC78, 0x62240001,
-	0xC78, 0x61250001,
-	0xC78, 0x47260001,
-	0xC78, 0x46270001,
-	0xC78, 0x45280001,
-	0xC78, 0x44290001,
-	0xC78, 0x432A0001,
-	0xC78, 0x422B0001,
-	0xC78, 0x292C0001,
-	0xC78, 0x282D0001,
-	0xC78, 0x272E0001,
-	0xC78, 0x262F0001,
-	0xC78, 0x25300001,
-	0xC78, 0x24310001,
-	0xC78, 0x09320001,
-	0xC78, 0x08330001,
-	0xC78, 0x07340001,
-	0xC78, 0x06350001,
-	0xC78, 0x05360001,
-	0xC78, 0x04370001,
-	0xC78, 0x03380001,
-	0xC78, 0x02390001,
-	0xC78, 0x013A0001,
-	0xC78, 0x003B0001,
-	0xC78, 0x003C0001,
-	0xC78, 0x003D0001,
-	0xC78, 0x003E0001,
-	0xC78, 0x003F0001,
-	0xC78, 0xFC400001,
-	0xC78, 0xFB410001,
-	0xC78, 0xFA420001,
-	0xC78, 0xF9430001,
-	0xC78, 0xF8440001,
-	0xC78, 0xF7450001,
-	0xC78, 0xF6460001,
-	0xC78, 0xF5470001,
-	0xC78, 0xF4480001,
-	0xC78, 0xF3490001,
-	0xC78, 0xF24A0001,
-	0xC78, 0xF14B0001,
-	0xC78, 0xF04C0001,
-	0xC78, 0xEF4D0001,
-	0xC78, 0xEE4E0001,
-	0xC78, 0xED4F0001,
-	0xC78, 0xEC500001,
-	0xC78, 0xEB510001,
-	0xC78, 0xEA520001,
-	0xC78, 0xE9530001,
-	0xC78, 0xE8540001,
-	0xC78, 0xE7550001,
-	0xC78, 0xE6560001,
-	0xC78, 0xE5570001,
-	0xC78, 0xAA580001,
-	0xC78, 0xA9590001,
-	0xC78, 0xA85A0001,
-	0xC78, 0xA75B0001,
-	0xC78, 0xA65C0001,
-	0xC78, 0xA55D0001,
-	0xC78, 0xA45E0001,
-	0xC78, 0x675F0001,
-	0xC78, 0x66600001,
-	0xC78, 0x65610001,
-	0xC78, 0x64620001,
-	0xC78, 0x63630001,
-	0xC78, 0x62640001,
-	0xC78, 0x61650001,
-	0xC78, 0x47660001,
-	0xC78, 0x46670001,
-	0xC78, 0x45680001,
-	0xC78, 0x44690001,
-	0xC78, 0x436A0001,
-	0xC78, 0x426B0001,
-	0xC78, 0x296C0001,
-	0xC78, 0x286D0001,
-	0xC78, 0x276E0001,
-	0xC78, 0x266F0001,
-	0xC78, 0x25700001,
-	0xC78, 0x24710001,
-	0xC78, 0x09720001,
-	0xC78, 0x08730001,
-	0xC78, 0x07740001,
-	0xC78, 0x06750001,
-	0xC78, 0x05760001,
-	0xC78, 0x04770001,
-	0xC78, 0x03780001,
-	0xC78, 0x02790001,
-	0xC78, 0x017A0001,
-	0xC78, 0x007B0001,
-	0xC78, 0x007C0001,
-	0xC78, 0x007D0001,
-	0xC78, 0x007E0001,
-	0xC78, 0x007F0001,
-	0xC50, 0x69553422,
-	0xC50, 0x69553420,
+		0xC78, 0xFD000001,
+		0xC78, 0xFC010001,
+		0xC78, 0xFB020001,
+		0xC78, 0xFA030001,
+		0xC78, 0xF9040001,
+		0xC78, 0xF8050001,
+		0xC78, 0xF7060001,
+		0xC78, 0xF6070001,
+		0xC78, 0xF5080001,
+		0xC78, 0xF4090001,
+		0xC78, 0xF30A0001,
+		0xC78, 0xF20B0001,
+		0xC78, 0xF10C0001,
+		0xC78, 0xF00D0001,
+		0xC78, 0xEF0E0001,
+		0xC78, 0xEE0F0001,
+		0xC78, 0xED100001,
+		0xC78, 0xEC110001,
+		0xC78, 0xEB120001,
+		0xC78, 0xEA130001,
+		0xC78, 0xE9140001,
+		0xC78, 0xE8150001,
+		0xC78, 0xE7160001,
+		0xC78, 0xAA170001,
+		0xC78, 0xA9180001,
+		0xC78, 0xA8190001,
+		0xC78, 0xA71A0001,
+		0xC78, 0xA61B0001,
+		0xC78, 0xA51C0001,
+		0xC78, 0xA41D0001,
+		0xC78, 0xA31E0001,
+		0xC78, 0x671F0001,
+		0xC78, 0x66200001,
+		0xC78, 0x65210001,
+		0xC78, 0x64220001,
+		0xC78, 0x63230001,
+		0xC78, 0x62240001,
+		0xC78, 0x61250001,
+		0xC78, 0x47260001,
+		0xC78, 0x46270001,
+		0xC78, 0x45280001,
+		0xC78, 0x44290001,
+		0xC78, 0x432A0001,
+		0xC78, 0x422B0001,
+		0xC78, 0x292C0001,
+		0xC78, 0x282D0001,
+		0xC78, 0x272E0001,
+		0xC78, 0x262F0001,
+		0xC78, 0x25300001,
+		0xC78, 0x24310001,
+		0xC78, 0x09320001,
+		0xC78, 0x08330001,
+		0xC78, 0x07340001,
+		0xC78, 0x06350001,
+		0xC78, 0x05360001,
+		0xC78, 0x04370001,
+		0xC78, 0x03380001,
+		0xC78, 0x02390001,
+		0xC78, 0x013A0001,
+		0xC78, 0x003B0001,
+		0xC78, 0x003C0001,
+		0xC78, 0x003D0001,
+		0xC78, 0x003E0001,
+		0xC78, 0x003F0001,
+		0xC78, 0xFC400001,
+		0xC78, 0xFB410001,
+		0xC78, 0xFA420001,
+		0xC78, 0xF9430001,
+		0xC78, 0xF8440001,
+		0xC78, 0xF7450001,
+		0xC78, 0xF6460001,
+		0xC78, 0xF5470001,
+		0xC78, 0xF4480001,
+		0xC78, 0xF3490001,
+		0xC78, 0xF24A0001,
+		0xC78, 0xF14B0001,
+		0xC78, 0xF04C0001,
+		0xC78, 0xEF4D0001,
+		0xC78, 0xEE4E0001,
+		0xC78, 0xED4F0001,
+		0xC78, 0xEC500001,
+		0xC78, 0xEB510001,
+		0xC78, 0xEA520001,
+		0xC78, 0xE9530001,
+		0xC78, 0xE8540001,
+		0xC78, 0xE7550001,
+		0xC78, 0xE6560001,
+		0xC78, 0xE5570001,
+		0xC78, 0xAA580001,
+		0xC78, 0xA9590001,
+		0xC78, 0xA85A0001,
+		0xC78, 0xA75B0001,
+		0xC78, 0xA65C0001,
+		0xC78, 0xA55D0001,
+		0xC78, 0xA45E0001,
+		0xC78, 0x675F0001,
+		0xC78, 0x66600001,
+		0xC78, 0x65610001,
+		0xC78, 0x64620001,
+		0xC78, 0x63630001,
+		0xC78, 0x62640001,
+		0xC78, 0x61650001,
+		0xC78, 0x47660001,
+		0xC78, 0x46670001,
+		0xC78, 0x45680001,
+		0xC78, 0x44690001,
+		0xC78, 0x436A0001,
+		0xC78, 0x426B0001,
+		0xC78, 0x296C0001,
+		0xC78, 0x286D0001,
+		0xC78, 0x276E0001,
+		0xC78, 0x266F0001,
+		0xC78, 0x25700001,
+		0xC78, 0x24710001,
+		0xC78, 0x09720001,
+		0xC78, 0x08730001,
+		0xC78, 0x07740001,
+		0xC78, 0x06750001,
+		0xC78, 0x05760001,
+		0xC78, 0x04770001,
+		0xC78, 0x03780001,
+		0xC78, 0x02790001,
+		0xC78, 0x017A0001,
+		0xC78, 0x007B0001,
+		0xC78, 0x007C0001,
+		0xC78, 0x007D0001,
+		0xC78, 0x007E0001,
+		0xC78, 0x007F0001,
+		0xC50, 0x69553422,
+		0xC50, 0x69553420,
+
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/table.h b/drivers/net/wireless/rtlwifi/rtl8723be/table.h
index 932760a..dc17001 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/table.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/table.h
@@ -35,7 +35,7 @@ extern u32 RTL8723BEPHY_REG_1TARRAY[];
 extern u32 RTL8723BEPHY_REG_ARRAY_PG[];
 #define	RTL8723BE_RADIOA_1TARRAYLEN	206
 extern u32 RTL8723BE_RADIOA_1TARRAY[];
-#define RTL8723BEMAC_1T_ARRAYLEN	194
+#define RTL8723BEMAC_1T_ARRAYLEN	196
 extern u32 RTL8723BEMAC_1T_ARRAY[];
 #define RTL8723BEAGCTAB_1TARRAYLEN	260
 extern u32 RTL8723BEAGCTAB_1TARRAY[];
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index 557b416..9679cd2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -33,6 +33,7 @@
 #include "trx.h"
 #include "led.h"
 #include "dm.h"
+#include "fw.h"
 
 static u8 _rtl8723be_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 {
@@ -207,196 +208,150 @@ static int _rtl8723be_rate_mapping(struct ieee80211_hw *hw,
 static void _rtl8723be_query_rxphystatus(struct ieee80211_hw *hw,
 					 struct rtl_stats *pstatus, u8 *pdesc,
 					 struct rx_fwinfo_8723be *p_drvinfo,
-					 bool packet_match_bssid,
-					 bool packet_toself,
+					 bool bpacket_match_bssid,
+					 bool bpacket_toself,
 					 bool packet_beacon)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
-	struct phy_sts_cck_8723e_t *cck_buf;
 	struct phy_status_rpt *p_phystrpt = (struct phy_status_rpt *)p_drvinfo;
-	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
 	char rx_pwr_all = 0, rx_pwr[4];
-	u8 rf_rx_num = 0, evm, pwdb_all;
+	u8 rf_rx_num = 0, evm, pwdb_all, pwdb_all_bt = 0;
 	u8 i, max_spatial_stream;
 	u32 rssi, total_rssi = 0;
 	bool is_cck = pstatus->is_cck;
 	u8 lan_idx, vga_idx;
 
 	/* Record it for next packet processing */
-	pstatus->packet_matchbssid = packet_match_bssid;
-	pstatus->packet_toself = packet_toself;
+	pstatus->packet_matchbssid = bpacket_match_bssid;
+	pstatus->packet_toself = bpacket_toself;
 	pstatus->packet_beacon = packet_beacon;
-	pstatus->rx_mimo_sig_qual[0] = -1;
-	pstatus->rx_mimo_sig_qual[1] = -1;
+	pstatus->rx_mimo_signalquality[0] = -1;
+	pstatus->rx_mimo_signalquality[1] = -1;
 
 	if (is_cck) {
 		u8 cck_highpwr;
 		u8 cck_agc_rpt;
-		/* CCK Driver info Structure is not the same as OFDM packet. */
-		cck_buf = (struct phy_sts_cck_8723e_t *)p_drvinfo;
-		cck_agc_rpt = cck_buf->cck_agc_rpt;
 
-		/* (1)Hardware does not provide RSSI for CCK
-		 * (2)PWDB, Average PWDB cacluated by
+		cck_agc_rpt = p_phystrpt->cck_agc_rpt_ofdm_cfosho_a;
+
+		/* (1)Hardware does not provide RSSI for CCK */
+		/* (2)PWDB, Average PWDB cacluated by
 		 * hardware (for rate adaptive)
 		 */
-		if (ppsc->rfpwr_state == ERFON)
-			cck_highpwr = (u8) rtl_get_bbreg(hw,
-						       RFPGA0_XA_HSSIPARAMETER2,
-						       BIT(9));
-		else
-			cck_highpwr = false;
+		cck_highpwr = (u8)rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2,
+						 BIT(9));
 
 		lan_idx = ((cck_agc_rpt & 0xE0) >> 5);
 		vga_idx = (cck_agc_rpt & 0x1f);
+
 		switch (lan_idx) {
-		case 7:
-			if (vga_idx <= 27)/*VGA_idx = 27~2*/
-				rx_pwr_all = -100 + 2 * (27 - vga_idx);
-			else
-				rx_pwr_all = -100;
-			break;
-		case 6:/*VGA_idx = 2~0*/
-			rx_pwr_all = -48 + 2 * (2 - vga_idx);
-			break;
-		case 5:/*VGA_idx = 7~5*/
-			rx_pwr_all = -42 + 2 * (7 - vga_idx);
-			break;
-		case 4:/*VGA_idx = 7~4*/
-			rx_pwr_all = -36 + 2 * (7 - vga_idx);
+		/* 46 53 73 95 201301231630 */
+		/* 46 53 77 99 201301241630 */
+		case 6:
+			rx_pwr_all = -34 - (2 * vga_idx);
 			break;
-		case 3:/*VGA_idx = 7~0*/
-			rx_pwr_all = -24 + 2 * (7 - vga_idx);
-			break;
-		case 2:
-			if (cck_highpwr)/*VGA_idx = 5~0*/
-				rx_pwr_all = -12 + 2 * (5 - vga_idx);
-			else
-				rx_pwr_all = -6 + 2 * (5 - vga_idx);
+		case 4:
+			rx_pwr_all = -14 - (2 * vga_idx);
 			break;
 		case 1:
-			rx_pwr_all = 8 - 2 * vga_idx;
+			rx_pwr_all = 6 - (2 * vga_idx);
 			break;
 		case 0:
-			rx_pwr_all = 14 - 2 * vga_idx;
+			rx_pwr_all = 16 - (2 * vga_idx);
 			break;
 		default:
 			break;
 		}
-		rx_pwr_all += 6;
+
 		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
-		/* CCK gain is smaller than OFDM/MCS gain,  */
-		/* so we add gain diff by experiences,
-		 * the val is 6
-		 */
-		pwdb_all += 6;
 		if (pwdb_all > 100)
 			pwdb_all = 100;
-		/* modify the offset to make the same gain index with OFDM. */
-		if (pwdb_all > 34 && pwdb_all <= 42)
-			pwdb_all -= 2;
-		else if (pwdb_all > 26 && pwdb_all <= 34)
-			pwdb_all -= 6;
-		else if (pwdb_all > 14 && pwdb_all <= 26)
-			pwdb_all -= 8;
-		else if (pwdb_all > 4 && pwdb_all <= 14)
-			pwdb_all -= 4;
-		if (!cck_highpwr) {
-			if (pwdb_all >= 80)
-				pwdb_all = ((pwdb_all - 80) << 1) +
-					   ((pwdb_all - 80) >> 1) + 80;
-			else if ((pwdb_all <= 78) && (pwdb_all >= 20))
-				pwdb_all += 3;
-			if (pwdb_all > 100)
-				pwdb_all = 100;
-		}
 
 		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->bt_rx_rssi_percentage = pwdb_all;
 		pstatus->recvsignalpower = rx_pwr_all;
 
 		/* (3) Get Signal Quality (EVM) */
-		if (packet_match_bssid) {
-			u8 sq;
-
+		if (bpacket_match_bssid) {
+			u8 sq, sq_rpt;
 			if (pstatus->rx_pwdb_all > 40) {
 				sq = 100;
 			} else {
-				sq = cck_buf->sq_rpt;
-				if (sq > 64)
+				sq_rpt = p_phystrpt->cck_sig_qual_ofdm_pwdb_all;
+				if (sq_rpt > 64)
 					sq = 0;
-				else if (sq < 20)
+				else if (sq_rpt < 20)
 					sq = 100;
 				else
-					sq = ((64 - sq) * 100) / 44;
+					sq = ((64 - sq_rpt) * 100) / 44;
 			}
-
 			pstatus->signalquality = sq;
-			pstatus->rx_mimo_sig_qual[0] = sq;
-			pstatus->rx_mimo_sig_qual[1] = -1;
+			pstatus->rx_mimo_signalquality[0] = sq;
+			pstatus->rx_mimo_signalquality[1] = -1;
 		}
 	} else {
-		rtlpriv->dm.rfpath_rxenable[0] = true;
-		rtlpriv->dm.rfpath_rxenable[1] = true;
-
 		/* (1)Get RSSI for HT rate */
 		for (i = RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
 			/* we will judge RF RX path now. */
 			if (rtlpriv->dm.rfpath_rxenable[i])
 				rf_rx_num++;
 
-			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f)*2) - 110;
+			rx_pwr[i] = ((p_phystrpt->path_agc[i].gain & 0x3f) * 2)
+				    - 110;
 
+			pstatus->rx_pwr[i] = rx_pwr[i];
 			/* Translate DBM to percentage. */
 			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 
-			/* Get Rx snr value in DB */
-			rtlpriv->stats.rx_snr_db[i] =
-					(long)(p_drvinfo->rxsnr[i] / 2);
-
-			/* Record Signal Strength for next packet */
-			if (packet_match_bssid)
-				pstatus->rx_mimo_signalstrength[i] = (u8) rssi;
+			pstatus->rx_mimo_signalstrength[i] = (u8)rssi;
 		}
 
-		/* (2)PWDB, Avg cacluated by hardware (for rate adaptive) */
-		rx_pwr_all = ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
+		rx_pwr_all = ((p_phystrpt->cck_sig_qual_ofdm_pwdb_all >> 1) &
+			     0x7f) - 110;
 
 		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
+		pwdb_all_bt = pwdb_all;
 		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->bt_rx_rssi_percentage = pwdb_all_bt;
 		pstatus->rxpower = rx_pwr_all;
 		pstatus->recvsignalpower = rx_pwr_all;
 
 		/* (3)EVM of HT rate */
-		if (pstatus->is_ht && pstatus->rate >= DESC92C_RATEMCS8 &&
+		if (pstatus->rate >= DESC92C_RATEMCS8 &&
 		    pstatus->rate <= DESC92C_RATEMCS15)
 			max_spatial_stream = 2;
 		else
 			max_spatial_stream = 1;
 
 		for (i = 0; i < max_spatial_stream; i++) {
-			evm = rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
+			evm = rtl_evm_db_to_percentage(
+						p_phystrpt->stream_rxevm[i]);
 
-			if (packet_match_bssid) {
+			if (bpacket_match_bssid) {
 				/* Fill value in RFD, Get the first
 				 * spatial stream only
 				 */
 				if (i == 0)
 					pstatus->signalquality =
-							(u8) (evm & 0xff);
-				pstatus->rx_mimo_sig_qual[i] =
-							(u8) (evm & 0xff);
+							(u8)(evm & 0xff);
+				pstatus->rx_mimo_signalquality[i] =
+							(u8)(evm & 0xff);
 			}
 		}
-		if (packet_match_bssid) {
+
+		if (bpacket_match_bssid) {
 			for (i = RF90_PATH_A; i <= RF90_PATH_B; i++)
 				rtl_priv(hw)->dm.cfo_tail[i] =
-					(char)p_phystrpt->path_cfotail[i];
+					(int)p_phystrpt->path_cfotail[i];
 
-			rtl_priv(hw)->dm.packet_count++;
 			if (rtl_priv(hw)->dm.packet_count == 0xffffffff)
 				rtl_priv(hw)->dm.packet_count = 0;
+			else
+				rtl_priv(hw)->dm.packet_count++;
 		}
 	}
 
@@ -409,10 +364,6 @@ static void _rtl8723be_query_rxphystatus(struct ieee80211_hw *hw,
 	else if (rf_rx_num != 0)
 		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
 						total_rssi /= rf_rx_num));
-	/*HW antenna diversity*/
-	rtldm->fat_table.antsel_rx_keep_0 = p_phystrpt->ant_sel;
-	rtldm->fat_table.antsel_rx_keep_1 = p_phystrpt->ant_sel_b;
-	rtldm->fat_table.antsel_rx_keep_2 = p_phystrpt->antsel_rx_keep_2;
 }
 
 static void _rtl8723be_translate_rx_signal_stuff(struct ieee80211_hw *hw,
@@ -440,14 +391,14 @@ static void _rtl8723be_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	memcpy(pstatus->psaddr, psaddr, ETH_ALEN);
 
 	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
-	     (!ether_addr_equal(mac->bssid, (fc & IEEE80211_FCTL_TODS) ?
-				hdr->addr1 : (fc & IEEE80211_FCTL_FROMDS) ?
-				hdr->addr2 : hdr->addr3)) &&
-				(!pstatus->hwerror) &&
-				(!pstatus->crc) && (!pstatus->icv));
+	     (ether_addr_equal(mac->bssid, (fc & IEEE80211_FCTL_TODS) ?
+				  hdr->addr1 : (fc & IEEE80211_FCTL_FROMDS) ?
+				  hdr->addr2 : hdr->addr3)) &&
+				  (!pstatus->hwerror) &&
+				  (!pstatus->crc) && (!pstatus->icv));
 
 	packet_toself = packet_matchbssid &&
-	    (!ether_addr_equal(praddr, rtlefuse->dev_addr));
+	    (ether_addr_equal(praddr, rtlefuse->dev_addr));
 
 	/* YP: packet_beacon is not initialized,
 	 * this assignment is neccesary,
@@ -531,30 +482,33 @@ bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr;
 
 	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
-	status->packet_report_type = (u8)GET_RX_STATUS_DESC_RPT_SEL(pdesc);
-	if (status->packet_report_type == TX_REPORT2)
-		status->length = (u16) GET_RX_RPT2_DESC_PKT_LEN(pdesc);
-	else
-		status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
-	status->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+
+	status->length = (u16)GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size = (u8)GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
 				  RX_DRV_INFO_SIZE_UNIT;
-	status->rx_bufshift = (u8) (GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->rx_bufshift = (u8)(GET_RX_DESC_SHIFT(pdesc) & 0x03);
 	status->icv = (u16) GET_RX_DESC_ICV(pdesc);
 	status->crc = (u16) GET_RX_DESC_CRC32(pdesc);
 	status->hwerror = (status->crc | status->icv);
 	status->decrypted = !GET_RX_DESC_SWDEC(pdesc);
-	status->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
-	status->shortpreamble = (u16) GET_RX_DESC_SPLCP(pdesc);
-	status->isampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
-	status->isfirst_ampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
-	if (status->packet_report_type == NORMAL_RX)
-		status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
-	status->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
+	status->rate = (u8)GET_RX_DESC_RXMCS(pdesc);
+	status->shortpreamble = (u16)GET_RX_DESC_SPLCP(pdesc);
+	status->isampdu = (bool)(GET_RX_DESC_PAGGR(pdesc) == 1);
+	status->isfirst_ampdu = (bool)(GET_RX_DESC_PAGGR(pdesc) == 1);
+	status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
+	status->rx_is40Mhzpacket = (bool)GET_RX_DESC_BW(pdesc);
+	status->bandwidth = (u8)GET_RX_DESC_BW(pdesc);
+	status->macid = GET_RX_DESC_MACID(pdesc);
 	status->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
 
-	status->is_cck = RTL8723E_RX_HAL_IS_CCK_RATE(status->rate);
+	status->is_cck = RX_HAL_IS_CCK_RATE(status->rate);
+
+	if (GET_RX_STATUS_DESC_RPT_SEL(pdesc))
+		status->packet_report_type = C2H_PACKET;
+	else
+		status->packet_report_type = NORMAL_RX;
+
 
-	status->macid = GET_RX_DESC_MACID(pdesc);
 	if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
 		status->wake_match = BIT(2);
 	else if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
@@ -565,12 +519,11 @@ bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 		status->wake_match = 0;
 	if (status->wake_match)
 		RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD,
-			 "GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch=%d\n",
-			 status->wake_match);
+		"GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch=%d\n",
+		status->wake_match);
 	rx_status->freq = hw->conf.chandef.chan->center_freq;
 	rx_status->band = hw->conf.chandef.chan->band;
 
-
 	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size +
 				       status->rx_bufshift);
 
@@ -596,22 +549,21 @@ bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 	if (status->decrypted) {
 		if (!hdr) {
 			WARN_ON_ONCE(true);
-			pr_err("decrypted is true but hdr NULL in skb %p\n",
+			pr_err("decrypted is true but hdr NULL, from skb %p\n",
 			       rtl_get_hdr(skb));
 			return false;
 		}
 
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
+		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
-			rx_status->flag &= ~RX_FLAG_DECRYPTED;
-		else
 			rx_status->flag |= RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 	}
 
 	/* rate_idx: index of data rate into band's
 	 * supported rates or MCS index if HT rates
 	 * are use (RX_FLAG_HT)
-	 * Notice: this is diff with windows define
 	 */
 	rx_status->rate_idx = _rtl8723be_rate_mapping(hw, status->is_ht,
 						      status->rate);
@@ -624,21 +576,19 @@ bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 		_rtl8723be_translate_rx_signal_stuff(hw, skb, status,
 						     pdesc, p_drvinfo);
 	}
-
-	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
 	if (status->packet_report_type == TX_REPORT2) {
 		status->macid_valid_entry[0] =
-			 GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
+		  GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
 		status->macid_valid_entry[1] =
-			 GET_RX_RPT2_DESC_MACID_VALID_2(pdesc);
+		  GET_RX_RPT2_DESC_MACID_VALID_2(pdesc);
 	}
 	return true;
 }
 
 void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 			    struct ieee80211_hdr *hdr, u8 *pdesc_tx,
-			    u8 *pbd_desc_tx, struct ieee80211_tx_info *info,
+			    u8 *txbd, struct ieee80211_tx_info *info,
 			    struct ieee80211_sta *sta, struct sk_buff *skb,
 			    u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
 {
@@ -646,16 +596,16 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	u8 *pdesc = pdesc_tx;
+	u8 *pdesc = (u8 *)pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	unsigned int buf_len = 0;
 	unsigned int skb_len = skb->len;
 	u8 fw_qsel = _rtl8723be_map_hwqueue_to_fwqueue(skb, hw_queue);
 	bool firstseg = ((hdr->seq_ctrl &
-			  cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+			    cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
 	bool lastseg = ((hdr->frame_control &
-			 cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+			   cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
 	dma_addr_t mapping;
 	u8 bw_40 = 0;
 	u8 short_gi = 0;
@@ -736,7 +686,7 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
 
 		if (bw_40) {
-			if (ptcb_desc->packet_bw) {
+			if (ptcb_desc->packet_bw == HT_CHANNEL_WIDTH_20_40) {
 				SET_TX_DESC_DATA_BW(pdesc, 1);
 				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
 			} else {
@@ -776,9 +726,12 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_DATA_RATE_FB_LIMIT(pdesc, 0x1F);
 		SET_TX_DESC_RTS_RATE_FB_LIMIT(pdesc, 0xF);
 		SET_TX_DESC_DISABLE_FB(pdesc, ptcb_desc->disable_ratefallback ?
-				       1 : 0);
+					      1 : 0);
 		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
 
+		/* Set TxRate and RTSRate in TxDesc  */
+		/* This prevent Tx initial rate of new-coming packets */
+		/* from being overwritten by retried  packet rate.*/
 		if (ieee80211_is_data_qos(fc)) {
 			if (mac->rdg_en) {
 				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
@@ -793,9 +746,14 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 	SET_TX_DESC_LAST_SEG(pdesc, (lastseg ? 1 : 0));
 	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) buf_len);
 	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
-	SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
-	SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
-
+	/* if (rtlpriv->dm.useramask) { */
+	if (1) {
+		SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+	} else {
+		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+	}
 	if (!ieee80211_is_data_qos(fc))  {
 		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
 		SET_TX_DESC_HWSEQ_SEL(pdesc, 0);
@@ -805,11 +763,12 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
 		SET_TX_DESC_BMC(pdesc, 1);
 	}
+
 	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
 }
 
 void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
-			       bool b_firstseg, bool b_lastseg,
+			       bool firstseg, bool lastseg,
 			       struct sk_buff *skb)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -849,16 +808,19 @@ void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 
 	SET_TX_DESC_OWN(pdesc, 1);
 
-	SET_TX_DESC_PKT_SIZE(pdesc, (u16)(skb->len));
+	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
 
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
 
 	SET_TX_DESC_USE_RATE(pdesc, 1);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "H2C Tx Cmd Content\n", pdesc, TX_DESC_SIZE);
 }
 
-void rtl8723be_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
-			u8 desc_name, u8 *val)
+void rtl8723be_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+			bool istx, u8 desc_name, u8 *val)
 {
 	if (istx) {
 		switch (desc_name) {
@@ -870,7 +832,7 @@ void rtl8723be_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 			break;
 		default:
 			RT_ASSERT(false, "ERR txdesc :%d not process\n",
-				  desc_name);
+					  desc_name);
 			break;
 		}
 	} else {
@@ -889,7 +851,7 @@ void rtl8723be_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
-				  desc_name);
+					  desc_name);
 			break;
 		}
 	}
@@ -909,7 +871,7 @@ u32 rtl8723be_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 			break;
 		default:
 			RT_ASSERT(false, "ERR txdesc :%d not process\n",
-				  desc_name);
+					  desc_name);
 			break;
 		}
 	} else {
@@ -920,6 +882,9 @@ u32 rtl8723be_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 		case HW_DESC_RXPKT_LEN:
 			ret = GET_RX_DESC_PKT_LEN(pdesc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret = GET_RX_DESC_BUFF_ADDR(pdesc);
+			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
@@ -935,16 +900,15 @@ bool rtl8723be_is_tx_desc_closed(struct ieee80211_hw *hw,
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
 	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
-	u8 own = (u8) rtl8723be_get_desc(entry, true, HW_DESC_OWN);
+	u8 own = (u8)rtl8723be_get_desc(entry, true, HW_DESC_OWN);
 
 	/*beacon packet will only use the first
-	 *descriptor by default, and the own may not
+	 *descriptor defautly,and the own may not
 	 *be cleared by the hardware
 	 */
 	if (own)
 		return false;
-	else
-		return true;
+	return true;
 }
 
 void rtl8723be_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
@@ -957,3 +921,28 @@ void rtl8723be_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 			       BIT(0) << (hw_queue));
 	}
 }
+
+u32 rtl8723be_rx_command_packet(struct ieee80211_hw *hw,
+				struct rtl_stats status,
+				struct sk_buff *skb)
+{
+	u32 result = 0;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	switch (status.packet_report_type) {
+	case NORMAL_RX:
+			result = 0;
+			break;
+	case C2H_PACKET:
+			rtl8723be_c2h_packet_handler(hw, skb->data,
+						     (u8)skb->len);
+			result = 1;
+			break;
+	default:
+			RT_TRACE(rtlpriv, COMP_RECV, DBG_TRACE,
+				 "No this packet type!!\n");
+			break;
+	}
+
+	return result;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.h b/drivers/net/wireless/rtlwifi/rtl8723be/trx.h
index 102f33d..45949ac 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.h
@@ -415,21 +415,25 @@ struct phy_status_rpt {
 } __packed;
 
 struct rx_fwinfo_8723be {
-	u8 gain_trsw[4];
+	u8 gain_trsw[2];
+	u16 chl_num:10;
+	u16 sub_chnl:4;
+	u16 r_rfmod:2;
 	u8 pwdb_all;
 	u8 cfosho[4];
 	u8 cfotail[4];
 	char rxevm[2];
-	char rxsnr[4];
+	char rxsnr[2];
+	u8 pcts_msk_rpt[2];
 	u8 pdsnr[2];
 	u8 csi_current[2];
-	u8 csi_target[2];
+	u8 rx_gain_c;
+	u8 rx_gain_d;
 	u8 sigevm;
-	u8 max_ex_pwr;
-	u8 ex_intf_flag:1;
-	u8 sgi_en:1;
-	u8 rxsc:2;
-	u8 reserve:4;
+	u8 resvd_0;
+	u8 antidx_anta:3;
+	u8 antidx_antb:3;
+	u8 resvd_1:2;
 } __packed;
 
 struct tx_desc_8723be {
@@ -597,21 +601,25 @@ struct rx_desc_8723be {
 } __packed;
 
 void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
-			    struct ieee80211_hdr *hdr, u8 *pdesc,
-			    u8 *pbd_desc_tx, struct ieee80211_tx_info *info,
+			    struct ieee80211_hdr *hdr,
+			    u8 *pdesc_tx, u8 *txbd,
+			    struct ieee80211_tx_info *info,
 			    struct ieee80211_sta *sta, struct sk_buff *skb,
 			    u8 hw_queue, struct rtl_tcb_desc *ptcb_desc);
 bool rtl8723be_rx_query_desc(struct ieee80211_hw *hw,
 			     struct rtl_stats *status,
 			     struct ieee80211_rx_status *rx_status,
 			     u8 *pdesc, struct sk_buff *skb);
-void rtl8723be_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
-			u8 desc_name, u8 *val);
+void rtl8723be_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+			bool istx, u8 desc_name, u8 *val);
 u32 rtl8723be_get_desc(u8 *pdesc, bool istx, u8 desc_name);
 bool rtl8723be_is_tx_desc_closed(struct ieee80211_hw *hw,
 				 u8 hw_queue, u16 index);
 void rtl8723be_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
 void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
-			       bool b_firstseg, bool b_lastseg,
+			       bool firstseg, bool lastseg,
 			       struct sk_buff *skb);
+u32 rtl8723be_rx_command_packet(struct ieee80211_hw *hw,
+				struct rtl_stats status,
+				struct sk_buff *skb);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
index 6f35506..dd698e7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
@@ -267,7 +267,7 @@ int rtl8723_download_fw(struct ieee80211_hw *hw,
 	pfwdata = rtlhal->pfirmware;
 	fwsize = rtlhal->fwsize;
 
-	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723AE)
+	if (!is_8723be)
 		max_page = 6;
 	else
 		max_page = 8;
@@ -275,10 +275,10 @@ int rtl8723_download_fw(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
 			 "Firmware Version(%d), Signature(%#x), Size(%d)\n",
 			 pfwheader->version, pfwheader->signature,
-			 (int)sizeof(struct rtl92c_firmware_header));
+			 (int)sizeof(struct rtl8723e_firmware_header));
 
-		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
-		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
+		pfwdata = pfwdata + sizeof(struct rtl8723e_firmware_header);
+		fwsize = fwsize - sizeof(struct rtl8723e_firmware_header);
 	}
 
 	if (rtl_read_byte(rtlpriv, REG_MCUFWDL)&BIT(7)) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
index f9bab10..3ebafc8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
@@ -30,7 +30,8 @@
 #define REG_MCUFWDL				0x0080
 #define FW_8192C_START_ADDRESS			0x1000
 #define FW_8192C_PAGE_SIZE			4096
-#define FW_8723A_POLLING_TIMEOUT_COUNT		6000
+#define FW_8723A_POLLING_TIMEOUT_COUNT		1000
+#define FW_8723B_POLLING_TIMEOUT_COUNT		6000
 #define FW_8192C_POLLING_DELAY			5
 
 #define MCUFWDL_RDY				BIT(1)
@@ -99,25 +100,6 @@ enum rtl8723be_cmd {
 	MAX_8723BE_H2CCMD
 };
 
-struct rtl92c_firmware_header {
-	u16 signature;
-	u8 category;
-	u8 function;
-	u16 version;
-	u8 subversion;
-	u8 rsvd1;
-	u8 month;
-	u8 date;
-	u8 hour;
-	u8 minute;
-	u16 ramcodesize;
-	u16 rsvd2;
-	u32 svnindex;
-	u32 rsvd3;
-	u32 rsvd4;
-	u32 rsvd5;
-};
-
 void rtl8723ae_firmware_selfreset(struct ieee80211_hw *hw);
 void rtl8723be_firmware_selfreset(struct ieee80211_hw *hw);
 void rtl8723_enable_fw_download(struct ieee80211_hw *hw, bool enable);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
index 56aff32..75cbd15 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
@@ -96,7 +96,7 @@ u32 rtl8723_phy_rf_serial_read(struct ieee80211_hw *hw,
 	u8 rfpi_enable = 0;
 	u32 retvalue;
 
-	offset &= 0x3f;
+	offset &= 0xff;
 	newoffset = offset;
 	if (RT_CANNOT_IO(hw)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "return all one\n");
@@ -150,7 +150,7 @@ void rtl8723_phy_rf_serial_write(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "stop\n");
 		return;
 	}
-	offset &= 0x3f;
+	offset &= 0xff;
 	newoffset = offset;
 	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
 	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
@@ -390,14 +390,21 @@ EXPORT_SYMBOL_GPL(rtl8723_phy_reload_mac_registers);
 void rtl8723_phy_path_adda_on(struct ieee80211_hw *hw, u32 *addareg,
 			      bool is_patha_on, bool is2t)
 {
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u32 pathon;
 	u32 i;
 
-	pathon = is_patha_on ? 0x04db25a4 : 0x0b1b25a4;
-	if (!is2t) {
-		pathon = 0x0bdb25a0;
-		rtl_set_bbreg(hw, addareg[0], MASKDWORD, 0x0b1b25a0);
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723AE) {
+		pathon = is_patha_on ? 0x04db25a4 : 0x0b1b25a4;
+		if (!is2t) {
+			pathon = 0x0bdb25a0;
+			rtl_set_bbreg(hw, addareg[0], MASKDWORD, 0x0b1b25a0);
+		} else {
+			rtl_set_bbreg(hw, addareg[0], MASKDWORD, pathon);
+		}
 	} else {
+		/* rtl8723be */
+		pathon = 0x01c00014;
 		rtl_set_bbreg(hw, addareg[0], MASKDWORD, pathon);
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
index 58bbaf4..310d316 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -48,7 +48,9 @@ static void _rtl8821ae_return_beacon_queue_skb(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[BEACON_QUEUE];
+	unsigned long flags;
 
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 	while (skb_queue_len(&ring->queue)) {
 		struct rtl_tx_desc *entry = &ring->desc[ring->idx];
 		struct sk_buff *skb = __skb_dequeue(&ring->queue);
@@ -60,6 +62,7 @@ static void _rtl8821ae_return_beacon_queue_skb(struct ieee80211_hw *hw)
 		kfree_skb(skb);
 		ring->idx = (ring->idx + 1) % ring->entries;
 	}
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 }
 
 static void _rtl8821ae_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 2f792ac..050a242 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -330,13 +330,7 @@ enum hardware_type {
 #define	IS_HARDWARE_TYPE_8723(rtlhal)			\
 (IS_HARDWARE_TYPE_8723E(rtlhal) || IS_HARDWARE_TYPE_8723U(rtlhal))
 
-#define RX_HAL_IS_CCK_RATE(_pdesc)\
-	(_pdesc->rxmcs == DESC92_RATE1M ||		\
-	 _pdesc->rxmcs == DESC92_RATE2M ||		\
-	 _pdesc->rxmcs == DESC92_RATE5_5M ||		\
-	 _pdesc->rxmcs == DESC92_RATE11M)
-
-#define RTL8723E_RX_HAL_IS_CCK_RATE(rxmcs)		\
+#define RX_HAL_IS_CCK_RATE(rxmcs)			\
 	((rxmcs) == DESC92_RATE1M ||			\
 	 (rxmcs) == DESC92_RATE2M ||			\
 	 (rxmcs) == DESC92_RATE5_5M ||			\
-- 
1.8.4.5
