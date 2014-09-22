From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/11 NEXT] rtlwifi: Fix problems with building an allyesconfig
Date: Mon, 22 Sep 2014 09:39:27 -0500
Message-ID: <1411396767-20611-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:54190 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171AbaIVOkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:40:18 -0400
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/core.c                |  98 +++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |   1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   7 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       |   4 -
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |   1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |  96 +++++++-------
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    | 126 +++++++++----------
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c | 135 --------------------
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |  94 --------------
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |   1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |   2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c | 130 -------------------
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |  98 ---------------
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |   1 -
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |  16 +--
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    |   2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c | 140 ---------------------
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h |  95 --------------
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c        |   7 --
 20 files changed, 223 insertions(+), 833 deletions(-)
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 40738e3..d30f416 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -28,6 +28,7 @@
 #include "cam.h"
 #include "base.h"
 #include "ps.h"
+#include "pwrseqcmd.h"
 
 #include "btcoexist/rtl_btc.h"
 #include <linux/firmware.h>
@@ -1700,3 +1701,100 @@ const struct ieee80211_ops rtl_ops = {
 };
 EXPORT_SYMBOL_GPL(rtl_ops);
 
+/*	Description:
+ *		This routine deals with the Power Configuration CMD
+ *		 parsing for RTL8723/RTL8188E Series IC.
+ *	Assumption:
+ *		We should follow specific format that was released from HW SD.
+ */
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 faversion, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[])
+{
+	struct wlan_pwr_cfg cfg_cmd = {0};
+	bool polling_bit = false;
+	u32 ary_idx = 0;
+	u8 value = 0;
+	u32 offset = 0;
+	u32 polling_count = 0;
+	u32 max_polling_cnt = 5000;
+
+	do {
+		cfg_cmd = pwrcfgcmd[ary_idx];
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "rtl_hal_pwrseqcmdparsing(): offset(%#x),cut_msk(%#x), famsk(%#x), interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
+			 GET_PWR_CFG_OFFSET(cfg_cmd),
+					    GET_PWR_CFG_CUT_MASK(cfg_cmd),
+			 GET_PWR_CFG_FAB_MASK(cfg_cmd),
+					      GET_PWR_CFG_INTF_MASK(cfg_cmd),
+			 GET_PWR_CFG_BASE(cfg_cmd), GET_PWR_CFG_CMD(cfg_cmd),
+			 GET_PWR_CFG_MASK(cfg_cmd), GET_PWR_CFG_VALUE(cfg_cmd));
+
+		if ((GET_PWR_CFG_FAB_MASK(cfg_cmd)&faversion) &&
+		    (GET_PWR_CFG_CUT_MASK(cfg_cmd)&cut_version) &&
+		    (GET_PWR_CFG_INTF_MASK(cfg_cmd)&interface_type)) {
+			switch (GET_PWR_CFG_CMD(cfg_cmd)) {
+			case PWR_CMD_READ:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
+				break;
+			case PWR_CMD_WRITE:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
+				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
+
+				/*Read the value from system register*/
+				value = rtl_read_byte(rtlpriv, offset);
+				value &= (~(GET_PWR_CFG_MASK(cfg_cmd)));
+				value |= (GET_PWR_CFG_VALUE(cfg_cmd) &
+					  GET_PWR_CFG_MASK(cfg_cmd));
+
+				/*Write the value back to sytem register*/
+				rtl_write_byte(rtlpriv, offset, value);
+				break;
+			case PWR_CMD_POLLING:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
+				polling_bit = false;
+				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
+
+				do {
+					value = rtl_read_byte(rtlpriv, offset);
+
+					value &= GET_PWR_CFG_MASK(cfg_cmd);
+					if (value ==
+					    (GET_PWR_CFG_VALUE(cfg_cmd) &
+					     GET_PWR_CFG_MASK(cfg_cmd)))
+						polling_bit = true;
+					else
+						udelay(10);
+
+					if (polling_count++ > max_polling_cnt)
+						return false;
+				} while (!polling_bit);
+				break;
+			case PWR_CMD_DELAY:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
+				if (GET_PWR_CFG_VALUE(cfg_cmd) ==
+				    PWRSEQ_DELAY_US)
+					udelay(GET_PWR_CFG_OFFSET(cfg_cmd));
+				else
+					mdelay(GET_PWR_CFG_OFFSET(cfg_cmd));
+				break;
+			case PWR_CMD_END:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_END\n");
+				return true;
+			default:
+				RT_ASSERT(false,
+					  "rtl_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
+				break;
+			}
+		}
+		ary_idx++;
+	} while (1);
+
+	return true;
+}
+EXPORT_SYMBOL(rtl_hal_pwrseqcmdparsing);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile b/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
index 5b194e9..a85419a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
@@ -5,7 +5,6 @@ rtl8188ee-objs :=		\
 		led.o		\
 		phy.o		\
 		pwrseq.o	\
-		pwrseqcmd.o	\
 		rf.o		\
 		sw.o		\
 		table.o		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index d4709e1..f74b7fb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -37,7 +37,6 @@
 #include "fw.h"
 #include "led.h"
 #include "hw.h"
-#include "pwrseqcmd.h"
 #include "pwrseq.h"
 
 #define LLT_CONFIG		5
@@ -850,7 +849,7 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 	/* HW Power on sequence */
 	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
 				      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
-				      RTL8188E_NIC_ENABLE_FLOW)) {
+				      RTL8188EE_NIC_ENABLE_FLOW)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "init MAC Fail as rtl_hal_pwrseqcmdparsing\n");
 		return false;
@@ -1422,7 +1421,7 @@ static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
 
 	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
 				 PWR_INTF_PCI_MSK,
-				 RTL8188E_NIC_LPS_ENTER_FLOW);
+				 RTL8188EE_NIC_LPS_ENTER_FLOW);
 
 	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00);
 
@@ -1437,7 +1436,7 @@ static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_32K_CTRL, (u1b_tmp & (~BIT(0))));
 
 	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				 PWR_INTF_PCI_MSK, RTL8188E_NIC_DISABLE_FLOW);
+				 PWR_INTF_PCI_MSK, RTL8188EE_NIC_DISABLE_FLOW);
 
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp & (~BIT(3))));
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
index 785401a..3044269 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
@@ -2100,10 +2100,6 @@ void rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw)
 	rtlphy->lck_inprogress = false;
 }
 
-void rtl92c_phy_ap_calibrate(struct ieee80211_hw *hw, char delta)
-{
-}
-
 void rtl88e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain)
 {
 	_rtl88e_phy_set_rfpath_switch(hw, bmain, false);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
index 4dae55b..b29bd77 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
@@ -222,7 +222,6 @@ void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw);
 u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw);
 void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
-void rtl92c_phy_ap_calibrate(struct ieee80211_hw *hw, char delta);
 void rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw);
 void rtl88e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
 bool rtl88e_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
index e4e0306..ef28c8e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
@@ -28,78 +28,78 @@
 
 /* drivers should parse below arrays and do the corresponding actions */
 /*3 Power on  Array*/
-struct wlan_pwr_cfg rtl8188E_power_on_flow[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS
-					+ RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_CARDEMU_TO_ACT
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_power_on_flow[RTL8188EE_TRANS_CARDEMU_TO_ACT_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_CARDEMU_TO_ACT
+	RTL8188EE_TRANS_END
 };
 
 /*3Radio off GPIO Array */
-struct wlan_pwr_cfg rtl8188E_radio_off_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
-					+ RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_ACT_TO_CARDEMU
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_radio_off_flow[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_ACT_TO_CARDEMU
+	RTL8188EE_TRANS_END
 };
 
 /*3Card Disable Array*/
-struct wlan_pwr_cfg rtl8188E_card_disable_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		 RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_ACT_TO_CARDEMU
-	RTL8188E_TRANS_CARDEMU_TO_CARDDIS
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_card_disable_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_ACT_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_CARDDIS
+	RTL8188EE_TRANS_END
 };
 
 /*3 Card Enable Array*/
-struct wlan_pwr_cfg rtl8188E_card_enable_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		 RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_CARDDIS_TO_CARDEMU
-	RTL8188E_TRANS_CARDEMU_TO_ACT
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_card_enable_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_CARDDIS_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_ACT
+	RTL8188EE_TRANS_END
 };
 
 /*3Suspend Array*/
-struct wlan_pwr_cfg rtl8188E_suspend_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
-					+ RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS
-					+ RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_ACT_TO_CARDEMU
-	RTL8188E_TRANS_CARDEMU_TO_SUS
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_suspend_flow[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS
+					+ RTL8188EE_TRANS_CARDEMU_TO_SUS_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_ACT_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_SUS
+	RTL8188EE_TRANS_END
 };
 
 /*3 Resume Array*/
-struct wlan_pwr_cfg rtl8188E_resume_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
-					+ RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS
-					+ RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_SUS_TO_CARDEMU
-	RTL8188E_TRANS_CARDEMU_TO_ACT
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_resume_flow[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS
+					+ RTL8188EE_TRANS_CARDEMU_TO_SUS_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_SUS_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_ACT
+	RTL8188EE_TRANS_END
 };
 
 /*3HWPDN Array*/
-struct wlan_pwr_cfg rtl8188E_hwpdn_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
-				+ RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS
-				+ RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_ACT_TO_CARDEMU
-	RTL8188E_TRANS_CARDEMU_TO_PDN
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_hwpdn_flow[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS
+				+ RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS
+				+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_ACT_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_PDN
+	RTL8188EE_TRANS_END
 };
 
 /*3 Enter LPS */
-struct wlan_pwr_cfg rtl8188E_enter_lps_flow[RTL8188E_TRANS_ACT_TO_LPS_STEPS
-					+ RTL8188E_TRANS_END_STEPS] = {
+struct wlan_pwr_cfg rtl8188ee_enter_lps_flow[RTL8188EE_TRANS_ACT_TO_LPS_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
 	/*FW behavior*/
-	RTL8188E_TRANS_ACT_TO_LPS
-	RTL8188E_TRANS_END
+	RTL8188EE_TRANS_ACT_TO_LPS
+	RTL8188EE_TRANS_END
 };
 
 /*3 Leave LPS */
-struct wlan_pwr_cfg rtl8188E_leave_lps_flow[RTL8188E_TRANS_LPS_TO_ACT_STEPS
-					+ RTL8188E_TRANS_END_STEPS] = {
+struct wlan_pwr_cfg rtl8188ee_leave_lps_flow[RTL8188EE_TRANS_LPS_TO_ACT_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
 	/*FW behavior*/
-	RTL8188E_TRANS_LPS_TO_ACT
-	RTL8188E_TRANS_END
+	RTL8188EE_TRANS_LPS_TO_ACT
+	RTL8188EE_TRANS_END
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
index 970afe6..7910334 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
@@ -27,7 +27,7 @@
 #define __RTL8723E_PWRSEQ_H__
 
 #include "pwrseqcmd.h"
-/* Check document WM-20110607-Paul-RTL8188E_Power_Architecture-R02.vsd
+/* Check document WM-20110607-Paul-RTL8188EE_Power_Architecture-R02.vsd
  *	There are 6 HW Power States:
  *	0: POFF--Power Off
  *	1: PDN--Power Down
@@ -46,24 +46,24 @@
  *	TRANS_LPS_TO_ACT
  *
  *	TRANS_END
- *	PWR SEQ Version: rtl8188E_PwrSeq_V09.h
+ *	PWR SEQ Version: rtl8188ee_PwrSeq_V09.h
  */
 
-#define	RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS	10
-#define	RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS	10
-#define	RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS	10
-#define	RTL8188E_TRANS_SUS_TO_CARDEMU_STEPS	10
-#define	RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS	10
-#define	RTL8188E_TRANS_PDN_TO_CARDEMU_STEPS	10
-#define	RTL8188E_TRANS_ACT_TO_LPS_STEPS		15
-#define	RTL8188E_TRANS_LPS_TO_ACT_STEPS		15
-#define	RTL8188E_TRANS_END_STEPS		1
+#define	RTL8188EE_TRANS_CARDEMU_TO_ACT_STEPS	10
+#define	RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS	10
+#define	RTL8188EE_TRANS_CARDEMU_TO_SUS_STEPS	10
+#define	RTL8188EE_TRANS_SUS_TO_CARDEMU_STEPS	10
+#define	RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS	10
+#define	RTL8188EE_TRANS_PDN_TO_CARDEMU_STEPS	10
+#define	RTL8188EE_TRANS_ACT_TO_LPS_STEPS		15
+#define	RTL8188EE_TRANS_LPS_TO_ACT_STEPS		15
+#define	RTL8188EE_TRANS_END_STEPS		1
 
 /* The following macros have the following format:
  * { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value
  *   comments },
  */
-#define RTL8188E_TRANS_CARDEMU_TO_ACT					\
+#define RTL8188EE_TRANS_CARDEMU_TO_ACT					\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)		\
 	/* wait till 0x04[17] = 1    power ready*/},			\
@@ -92,7 +92,7 @@
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)			\
 	/*SDIO Driving*/},
 
-#define RTL8188E_TRANS_ACT_TO_CARDEMU					\
+#define RTL8188EE_TRANS_ACT_TO_CARDEMU					\
 	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0			\
 	/*0x1F[7:0] = 0 turn off RF*/},					\
@@ -106,7 +106,7 @@
 	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0			\
 	/*wait till 0x04[9] = 0 polling until return 0 to disable*/},
 
-#define RTL8188E_TRANS_CARDEMU_TO_SUS					\
+#define RTL8188EE_TRANS_CARDEMU_TO_SUS					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)		\
@@ -133,7 +133,7 @@
 	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0			\
 	/*wait power state to suspend*/},
 
-#define RTL8188E_TRANS_SUS_TO_CARDEMU					\
+#define RTL8188EE_TRANS_SUS_TO_CARDEMU					\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0			\
 	/*Set SDIO suspend local register*/},				\
@@ -144,7 +144,7 @@
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(4), 0		\
 	/*0x04[12:11] = 2b'01enable WL suspend*/},
 
-#define RTL8188E_TRANS_CARDEMU_TO_CARDDIS				\
+#define RTL8188EE_TRANS_CARDEMU_TO_CARDDIS				\
 	{0x0026, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)			\
 	/*0x24[23] = 2b'01 schmit trigger */},				\
@@ -170,7 +170,7 @@
 	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0			\
 	/*wait power state to suspend*/},
 
-#define RTL8188E_TRANS_CARDDIS_TO_CARDEMU				\
+#define RTL8188EE_TRANS_CARDDIS_TO_CARDEMU				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0			\
 	/*Set SDIO suspend local register*/},				\
@@ -181,18 +181,18 @@
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0		\
 	/*0x04[12:11] = 2b'01enable WL suspend*/},
 
-#define RTL8188E_TRANS_CARDEMU_TO_PDN					\
+#define RTL8188EE_TRANS_CARDEMU_TO_PDN					\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0/* 0x04[16] = 0*/},	\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)			\
 	/* 0x04[15] = 1*/},
 
-#define RTL8188E_TRANS_PDN_TO_CARDEMU					\
+#define RTL8188EE_TRANS_PDN_TO_CARDEMU					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0/* 0x04[15] = 0*/},
 
-#define RTL8188E_TRANS_ACT_TO_LPS					\
+#define RTL8188EE_TRANS_ACT_TO_LPS					\
 	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x7F			\
 	/*Tx Pause*/},							\
@@ -225,7 +225,7 @@
 	/*Respond TxOK to scheduler*/},
 
 
-#define RTL8188E_TRANS_LPS_TO_ACT					\
+#define RTL8188EE_TRANS_LPS_TO_ACT					\
 	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
 	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84			\
 	/*SDIO RPWM*/},							\
@@ -260,52 +260,52 @@
 	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0			\
 	/*.	0x522 = 0*/},
 
-#define RTL8188E_TRANS_END		\
+#define RTL8188EE_TRANS_END		\
 	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
 	0, PWR_CMD_END, 0, 0}
 
-extern struct wlan_pwr_cfg rtl8188E_power_on_flow
-		[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_radio_off_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_card_disable_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_card_enable_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_suspend_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_resume_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_hwpdn_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		 RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_enter_lps_flow
-		[RTL8188E_TRANS_ACT_TO_LPS_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188E_leave_lps_flow
-		[RTL8188E_TRANS_LPS_TO_ACT_STEPS +
-		 RTL8188E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_power_on_flow
+		[RTL8188EE_TRANS_CARDEMU_TO_ACT_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_radio_off_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_card_disable_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_card_enable_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_suspend_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_resume_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_hwpdn_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_enter_lps_flow
+		[RTL8188EE_TRANS_ACT_TO_LPS_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8188ee_leave_lps_flow
+		[RTL8188EE_TRANS_LPS_TO_ACT_STEPS +
+		 RTL8188EE_TRANS_END_STEPS];
 
 /* RTL8723 Power Configuration CMDs for PCIe interface */
-#define RTL8188E_NIC_PWR_ON_FLOW	rtl8188E_power_on_flow
-#define RTL8188E_NIC_RF_OFF_FLOW	rtl8188E_radio_off_flow
-#define RTL8188E_NIC_DISABLE_FLOW	rtl8188E_card_disable_flow
-#define RTL8188E_NIC_ENABLE_FLOW	rtl8188E_card_enable_flow
-#define RTL8188E_NIC_SUSPEND_FLOW	rtl8188E_suspend_flow
-#define RTL8188E_NIC_RESUME_FLOW	rtl8188E_resume_flow
-#define RTL8188E_NIC_PDN_FLOW		rtl8188E_hwpdn_flow
-#define RTL8188E_NIC_LPS_ENTER_FLOW	rtl8188E_enter_lps_flow
-#define RTL8188E_NIC_LPS_LEAVE_FLOW	rtl8188E_leave_lps_flow
+#define RTL8188EE_NIC_PWR_ON_FLOW	rtl8188ee_power_on_flow
+#define RTL8188EE_NIC_RF_OFF_FLOW	rtl8188ee_radio_off_flow
+#define RTL8188EE_NIC_DISABLE_FLOW	rtl8188ee_card_disable_flow
+#define RTL8188EE_NIC_ENABLE_FLOW	rtl8188ee_card_enable_flow
+#define RTL8188EE_NIC_SUSPEND_FLOW	rtl8188ee_suspend_flow
+#define RTL8188EE_NIC_RESUME_FLOW	rtl8188ee_resume_flow
+#define RTL8188EE_NIC_PDN_FLOW		rtl8188ee_hwpdn_flow
+#define RTL8188EE_NIC_LPS_ENTER_FLOW	rtl8188ee_enter_lps_flow
+#define RTL8188EE_NIC_LPS_LEAVE_FLOW	rtl8188ee_leave_lps_flow
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
deleted file mode 100644
index eceedcd..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
+++ /dev/null
@@ -1,135 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2009-2013  Realtek Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae@realtek.com>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger@lwfinger.net>
- *
- *****************************************************************************/
-
-#include "pwrseqcmd.h"
-#include "pwrseq.h"
-
-
-/*	Description:
-*		This routine deal with the Power Configuration CMDs
-*		 parsing for RTL8723/RTL8188E Series IC.
-*	Assumption:
-*		We should follow specific format which was released from HW SD.
-*
-*	2011.07.07, added by Roger.
-*/
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 fab_version, u8 interface_type,
-			      struct wlan_pwr_cfg pwrcfgcmd[])
-
-{
-	struct wlan_pwr_cfg pwr_cfg_cmd = {0};
-	bool b_polling_bit = false;
-	u32 ary_idx = 0;
-	u8 value = 0;
-	u32 offset = 0;
-	u32 polling_count = 0;
-	u32 max_polling_cnt = 5000;
-
-	do {
-		pwr_cfg_cmd = pwrcfgcmd[ary_idx];
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			"rtl_hal_pwrseqcmdparsing(): offset(%#x),cut_msk(%#x), fab_msk(%#x), interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
-			GET_PWR_CFG_OFFSET(pwr_cfg_cmd),
-				GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd),
-			GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd),
-				GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd),
-			GET_PWR_CFG_BASE(pwr_cfg_cmd),
-				GET_PWR_CFG_CMD(pwr_cfg_cmd),
-			GET_PWR_CFG_MASK(pwr_cfg_cmd),
-				GET_PWR_CFG_VALUE(pwr_cfg_cmd));
-
-		if ((GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd)&fab_version) &&
-		    (GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd)&cut_version) &&
-		    (GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd)&interface_type)) {
-			switch (GET_PWR_CFG_CMD(pwr_cfg_cmd)) {
-			case PWR_CMD_READ:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
-				break;
-			case PWR_CMD_WRITE:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
-				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
-
-				/*Read the value from system register*/
-				value = rtl_read_byte(rtlpriv, offset);
-				value &= (~(GET_PWR_CFG_MASK(pwr_cfg_cmd)));
-				value |= (GET_PWR_CFG_VALUE(pwr_cfg_cmd)
-				      & GET_PWR_CFG_MASK(pwr_cfg_cmd));
-
-				/*Write the back to sytem register*/
-				rtl_write_byte(rtlpriv, offset, value);
-				break;
-			case PWR_CMD_POLLING:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
-				b_polling_bit = false;
-				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
-
-				do {
-					value = rtl_read_byte(rtlpriv, offset);
-
-					value &= GET_PWR_CFG_MASK(pwr_cfg_cmd);
-					if (value ==
-					    (GET_PWR_CFG_VALUE(pwr_cfg_cmd) &
-					     GET_PWR_CFG_MASK(pwr_cfg_cmd)))
-						b_polling_bit = true;
-					else
-						udelay(10);
-
-					if (polling_count++ > max_polling_cnt) {
-						RT_TRACE(rtlpriv, COMP_INIT,
-							 DBG_LOUD,
-							 "polling fail in pwrseqcmd\n");
-						return false;
-					}
-				} while (!b_polling_bit);
-
-				break;
-			case PWR_CMD_DELAY:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
-				if (GET_PWR_CFG_VALUE(pwr_cfg_cmd) ==
-				    PWRSEQ_DELAY_US)
-					udelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
-				else
-					mdelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
-				break;
-			case PWR_CMD_END:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_END\n");
-				return true;
-			default:
-				RT_ASSERT(false,
-					"rtl_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
-				break;
-			}
-		}
-		ary_idx++;
-	} while (1);
-
-	return true;
-}
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
deleted file mode 100644
index dff77a5..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
+++ /dev/null
@@ -1,94 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2009-2013  Realtek Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae@realtek.com>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger@lwfinger.net>
- *
- *****************************************************************************/
-
-#ifndef __RTL8723E_PWRSEQCMD_H__
-#define __RTL8723E_PWRSEQCMD_H__
-
-#include "../wifi.h"
-/*---------------------------------------------*/
-/* The value of cmd: 4 bits */
-/*---------------------------------------------*/
-#define  PWR_CMD_READ		0x00
-#define    PWR_CMD_WRITE	0x01
-#define    PWR_CMD_POLLING	0x02
-#define    PWR_CMD_DELAY	0x03
-#define    PWR_CMD_END		0x04
-
-/* define the base address of each block */
-#define   PWR_BASEADDR_MAC	0x00
-#define   PWR_BASEADDR_USB	0x01
-#define   PWR_BASEADDR_PCIE	0x02
-#define   PWR_BASEADDR_SDIO	0x03
-
-#define	PWR_INTF_SDIO_MSK	BIT(0)
-#define	PWR_INTF_USB_MSK	BIT(1)
-#define	PWR_INTF_PCI_MSK	BIT(2)
-#define	PWR_INTF_ALL_MSK	(BIT(0)|BIT(1)|BIT(2)|BIT(3))
-
-#define	PWR_FAB_TSMC_MSK	BIT(0)
-#define	PWR_FAB_UMC_MSK		BIT(1)
-#define	PWR_FAB_ALL_MSK		(BIT(0)|BIT(1)|BIT(2)|BIT(3))
-
-#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
-#define	PWR_CUT_A_MSK		BIT(1)
-#define	PWR_CUT_B_MSK		BIT(2)
-#define	PWR_CUT_C_MSK		BIT(3)
-#define	PWR_CUT_D_MSK		BIT(4)
-#define	PWR_CUT_E_MSK		BIT(5)
-#define	PWR_CUT_F_MSK		BIT(6)
-#define	PWR_CUT_G_MSK		BIT(7)
-#define	PWR_CUT_ALL_MSK		0xFF
-
-enum pwrseq_delay_unit {
-	PWRSEQ_DELAY_US,
-	PWRSEQ_DELAY_MS,
-};
-
-struct wlan_pwr_cfg {
-	u16 offset;
-	u8 cut_msk;
-	u8 fab_msk:4;
-	u8 interface_msk:4;
-	u8 base:4;
-	u8 cmd:4;
-	u8 msk;
-	u8 value;
-
-};
-
-#define	GET_PWR_CFG_OFFSET(__PWR_CMD)	__PWR_CMD.offset
-#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)	__PWR_CMD.cut_msk
-#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)	__PWR_CMD.fab_msk
-#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	__PWR_CMD.interface_msk
-#define	GET_PWR_CFG_BASE(__PWR_CMD)	__PWR_CMD.base
-#define	GET_PWR_CFG_CMD(__PWR_CMD)	__PWR_CMD.cmd
-#define	GET_PWR_CFG_MASK(__PWR_CMD)	__PWR_CMD.msk
-#define	GET_PWR_CFG_VALUE(__PWR_CMD)	__PWR_CMD.value
-
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 fab_version, u8 interface_type,
-			struct wlan_pwr_cfg pwrcfgcmd[]);
-
-#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile b/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
index 4ed731f..9c34a85 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
@@ -10,7 +10,6 @@ rtl8723ae-objs :=		\
 		led.o		\
 		phy.o		\
 		pwrseq.o	\
-		pwrseqcmd.o	\
 		rf.o		\
 		sw.o		\
 		table.o		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index dd8e76c..3338206a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
@@ -43,7 +43,7 @@
 #include "../rtl8723com/fw_common.h"
 #include "led.h"
 #include "hw.h"
-#include "pwrseqcmd.h"
+#include "../pwrseqcmd.h"
 #include "pwrseq.h"
 #include "btc.h"
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
index df6ca9a..f907d7f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
@@ -27,7 +27,7 @@
  *
  *****************************************************************************/
 
-#include "pwrseqcmd.h"
+#include "../pwrseqcmd.h"
 #include "pwrseq.h"
 
 /* drivers should parse arrays below and do the corresponding actions */
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
deleted file mode 100644
index 239eb44..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
+++ /dev/null
@@ -1,130 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2009-2012  Realtek Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae@realtek.com>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger@lwfinger.net>
- *
- *****************************************************************************/
-
-#include "pwrseqcmd.h"
-#include "pwrseq.h"
-
-/*	Description:
- *		This routine deals with the Power Configuration CMD
- *		 parsing for RTL8723/RTL8188E Series IC.
- *	Assumption:
- *		We should follow specific format that was released from HW SD.
- */
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 faversion, u8 interface_type,
-			      struct wlan_pwr_cfg pwrcfgcmd[])
-{
-	struct wlan_pwr_cfg cfg_cmd = {0};
-	bool polling_bit = false;
-	u32 ary_idx = 0;
-	u8 value = 0;
-	u32 offset = 0;
-	u32 polling_count = 0;
-	u32 max_polling_cnt = 5000;
-
-	do {
-		cfg_cmd = pwrcfgcmd[ary_idx];
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			"rtl_hal_pwrseqcmdparsing(): offset(%#x),cut_msk(%#x), famsk(%#x),"
-			"interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
-			GET_PWR_CFG_OFFSET(cfg_cmd),
-					   GET_PWR_CFG_CUT_MASK(cfg_cmd),
-			GET_PWR_CFG_FAB_MASK(cfg_cmd),
-					     GET_PWR_CFG_INTF_MASK(cfg_cmd),
-			GET_PWR_CFG_BASE(cfg_cmd), GET_PWR_CFG_CMD(cfg_cmd),
-			GET_PWR_CFG_MASK(cfg_cmd), GET_PWR_CFG_VALUE(cfg_cmd));
-
-		if ((GET_PWR_CFG_FAB_MASK(cfg_cmd)&faversion) &&
-		    (GET_PWR_CFG_CUT_MASK(cfg_cmd)&cut_version) &&
-		    (GET_PWR_CFG_INTF_MASK(cfg_cmd)&interface_type)) {
-			switch (GET_PWR_CFG_CMD(cfg_cmd)) {
-			case PWR_CMD_READ:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
-				break;
-			case PWR_CMD_WRITE:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
-				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
-
-				/*Read the value from system register*/
-				value = rtl_read_byte(rtlpriv, offset);
-				value &= (~(GET_PWR_CFG_MASK(cfg_cmd)));
-				value |= (GET_PWR_CFG_VALUE(cfg_cmd) &
-					  GET_PWR_CFG_MASK(cfg_cmd));
-
-				/*Write the value back to sytem register*/
-				rtl_write_byte(rtlpriv, offset, value);
-				break;
-			case PWR_CMD_POLLING:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
-				polling_bit = false;
-				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
-
-				do {
-					value = rtl_read_byte(rtlpriv, offset);
-
-					value &= GET_PWR_CFG_MASK(cfg_cmd);
-					if (value ==
-					    (GET_PWR_CFG_VALUE(cfg_cmd)
-					    & GET_PWR_CFG_MASK(cfg_cmd)))
-						polling_bit = true;
-					else
-						udelay(10);
-
-					if (polling_count++ > max_polling_cnt)
-						return false;
-				} while (!polling_bit);
-				break;
-			case PWR_CMD_DELAY:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
-				if (GET_PWR_CFG_VALUE(cfg_cmd) ==
-				    PWRSEQ_DELAY_US)
-					udelay(GET_PWR_CFG_OFFSET(cfg_cmd));
-				else
-					mdelay(GET_PWR_CFG_OFFSET(cfg_cmd));
-				break;
-			case PWR_CMD_END:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_END\n");
-				return true;
-			default:
-				RT_ASSERT(false,
-					 "rtl_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
-				break;
-			}
-
-		}
-		ary_idx++;
-	} while (1);
-
-	return true;
-}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
deleted file mode 100644
index 6e0f3ea..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
+++ /dev/null
@@ -1,98 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2009-2012  Realtek Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae@realtek.com>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger@lwfinger.net>
- *
- *****************************************************************************/
-
-#ifndef __RTL8723E_PWRSEQCMD_H__
-#define __RTL8723E_PWRSEQCMD_H__
-
-#include "../wifi.h"
-/*---------------------------------------------
- * 3 The value of cmd: 4 bits
- *---------------------------------------------
- */
-#define    PWR_CMD_READ		0x00
-#define    PWR_CMD_WRITE	0x01
-#define    PWR_CMD_POLLING	0x02
-#define    PWR_CMD_DELAY	0x03
-#define    PWR_CMD_END		0x04
-
-/* define the base address of each block */
-#define   PWR_BASEADDR_MAC	0x00
-#define   PWR_BASEADDR_USB	0x01
-#define   PWR_BASEADDR_PCIE	0x02
-#define   PWR_BASEADDR_SDIO	0x03
-
-#define	PWR_INTF_SDIO_MSK	BIT(0)
-#define	PWR_INTF_USB_MSK	BIT(1)
-#define	PWR_INTF_PCI_MSK	BIT(2)
-#define	PWR_INTF_ALL_MSK	(BIT(0)|BIT(1)|BIT(2)|BIT(3))
-
-#define	PWR_FAB_TSMC_MSK	BIT(0)
-#define	PWR_FAB_UMC_MSK		BIT(1)
-#define	PWR_FAB_ALL_MSK		(BIT(0)|BIT(1)|BIT(2)|BIT(3))
-
-#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
-#define	PWR_CUT_A_MSK		BIT(1)
-#define	PWR_CUT_B_MSK		BIT(2)
-#define	PWR_CUT_C_MSK		BIT(3)
-#define	PWR_CUT_D_MSK		BIT(4)
-#define	PWR_CUT_E_MSK		BIT(5)
-#define	PWR_CUT_F_MSK		BIT(6)
-#define	PWR_CUT_G_MSK		BIT(7)
-#define	PWR_CUT_ALL_MSK		0xFF
-
-enum pwrseq_delay_unit {
-	PWRSEQ_DELAY_US,
-	PWRSEQ_DELAY_MS,
-};
-
-struct wlan_pwr_cfg {
-	u16 offset;
-	u8 cut_msk;
-	u8 fab_msk:4;
-	u8 interface_msk:4;
-	u8 base:4;
-	u8 cmd:4;
-	u8 msk;
-	u8 value;
-};
-
-#define	GET_PWR_CFG_OFFSET(__PWR_CMD)	(__PWR_CMD.offset)
-#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)	(__PWR_CMD.cut_msk)
-#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)	(__PWR_CMD.fab_msk)
-#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	(__PWR_CMD.interface_msk)
-#define	GET_PWR_CFG_BASE(__PWR_CMD)	(__PWR_CMD.base)
-#define	GET_PWR_CFG_CMD(__PWR_CMD)	(__PWR_CMD.cmd)
-#define	GET_PWR_CFG_MASK(__PWR_CMD)	(__PWR_CMD.msk)
-#define	GET_PWR_CFG_VALUE(__PWR_CMD)	(__PWR_CMD.value)
-
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 fab_version, u8 interface_type,
-			      struct wlan_pwr_cfg pwrcfgcmd[]);
-
-#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/Makefile b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
index 4a75aab..59e416a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/Makefile
@@ -8,7 +8,6 @@ rtl8723be-objs :=		\
 		led.o		\
 		phy.o		\
 		pwrseq.o	\
-		pwrseqcmd.o	\
 		rf.o		\
 		sw.o		\
 		table.o		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index 1b93918..c0689c1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -39,7 +39,7 @@
 #include "../rtl8723com/fw_common.h"
 #include "led.h"
 #include "hw.h"
-#include "pwrseqcmd.h"
+#include "../pwrseqcmd.h"
 #include "pwrseq.h"
 #include "../btcoexist/rtl_btc.h"
 
@@ -815,9 +815,9 @@ static bool _rtl8723be_init_mac(struct ieee80211_hw *hw)
 		mac_func_enable = false;
 
 	/* HW Power on sequence */
-	if (!rtlbe_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
-					PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
-					RTL8723_NIC_ENABLE_FLOW)) {
+	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
+				      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
+				      RTL8723_NIC_ENABLE_FLOW)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "init MAC Fail as power on failure\n");
 		return false;
@@ -1306,8 +1306,8 @@ static void _rtl8723be_poweroff_adapter(struct ieee80211_hw *hw)
 
 	/* Combo (PCIe + USB) Card and PCIe-MF Card */
 	/* 1. Run LPS WL RFOFF flow */
-	rtlbe_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				   PWR_INTF_PCI_MSK, RTL8723_NIC_LPS_ENTER_FLOW);
+	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, RTL8723_NIC_LPS_ENTER_FLOW);
 
 	/* 2. 0x1F[7:0] = 0 */
 	/* turn off RF */
@@ -1325,8 +1325,8 @@ static void _rtl8723be_poweroff_adapter(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
 
 	/* HW card disable configuration. */
-	rtlbe_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				   PWR_INTF_PCI_MSK, RTL8723_NIC_DISABLE_FLOW);
+	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, RTL8723_NIC_DISABLE_FLOW);
 
 	/* Reset MCU IO Wrapper */
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
index b5167e7..a1bb1f6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
@@ -23,7 +23,7 @@
  *
  *****************************************************************************/
 
-#include "pwrseqcmd.h"
+#include "../pwrseqcmd.h"
 #include "pwrseq.h"
 
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
deleted file mode 100644
index cf57a49..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
+++ /dev/null
@@ -1,140 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2009-2014  Realtek Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae@realtek.com>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger@lwfinger.net>
- *
- *****************************************************************************/
-
-#include "pwrseqcmd.h"
-#include "pwrseq.h"
-
-/*	Description:
- *		This routine deal with the Power Configuration CMDs
- *		 parsing for RTL8723/RTL8188E Series IC.
- *	Assumption:
- *		We should follow specific format which was released from HW SD.
- *
- *	2011.07.07, added by Roger.
- */
-bool rtlbe_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-				 u8 fab_version, u8 interface_type,
-				 struct wlan_pwr_cfg pwrcfgcmd[])
-
-{
-	struct wlan_pwr_cfg pwr_cfg_cmd = {0};
-	bool b_polling_bit = false;
-	u32 ary_idx = 0;
-	u8 value = 0;
-	u32 offset = 0;
-	u32 polling_count = 0;
-	u32 max_polling_cnt = 5000;
-
-	do {
-		pwr_cfg_cmd = pwrcfgcmd[ary_idx];
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "rtlbe_hal_pwrseqcmdparsing(): "
-			 "offset(%#x),cut_msk(%#x), fab_msk(%#x),"
-			 "interface_msk(%#x), base(%#x), "
-			 "cmd(%#x), msk(%#x), value(%#x)\n",
-			 GET_PWR_CFG_OFFSET(pwr_cfg_cmd),
-			 GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd),
-			 GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd),
-			 GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd),
-			 GET_PWR_CFG_BASE(pwr_cfg_cmd),
-			 GET_PWR_CFG_CMD(pwr_cfg_cmd),
-			 GET_PWR_CFG_MASK(pwr_cfg_cmd),
-			 GET_PWR_CFG_VALUE(pwr_cfg_cmd));
-
-		if ((GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd)&fab_version) &&
-		    (GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd)&cut_version) &&
-		    (GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd)&interface_type)) {
-			switch (GET_PWR_CFG_CMD(pwr_cfg_cmd)) {
-			case PWR_CMD_READ:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtlbe_hal_pwrseqcmdparsing(): "
-					  "PWR_CMD_READ\n");
-				break;
-			case PWR_CMD_WRITE:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtlbe_hal_pwrseqcmdparsing(): "
-					  "PWR_CMD_WRITE\n");
-				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
-
-				/*Read the value from system register*/
-				value = rtl_read_byte(rtlpriv, offset);
-				value &= (~(GET_PWR_CFG_MASK(pwr_cfg_cmd)));
-				value = value | (GET_PWR_CFG_VALUE(pwr_cfg_cmd)
-					& GET_PWR_CFG_MASK(pwr_cfg_cmd));
-
-				/*Write the value back to sytem register*/
-				rtl_write_byte(rtlpriv, offset, value);
-				break;
-			case PWR_CMD_POLLING:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtlbe_hal_pwrseqcmdparsing(): "
-					  "PWR_CMD_POLLING\n");
-				b_polling_bit = false;
-				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
-
-				do {
-					value = rtl_read_byte(rtlpriv, offset);
-
-					value &= GET_PWR_CFG_MASK(pwr_cfg_cmd);
-					if (value ==
-					    (GET_PWR_CFG_VALUE(pwr_cfg_cmd) &
-					     GET_PWR_CFG_MASK(pwr_cfg_cmd)))
-						b_polling_bit = true;
-					else
-						udelay(10);
-
-					if (polling_count++ > max_polling_cnt)
-						return false;
-
-				} while (!b_polling_bit);
-				break;
-			case PWR_CMD_DELAY:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtlbe_hal_pwrseqcmdparsing(): "
-					 "PWR_CMD_DELAY\n");
-				if (GET_PWR_CFG_VALUE(pwr_cfg_cmd) ==
-				    PWRSEQ_DELAY_US)
-					udelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
-				else
-					mdelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
-				break;
-			case PWR_CMD_END:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtlbe_hal_pwrseqcmdparsing(): "
-					 "PWR_CMD_END\n");
-				return true;
-			default:
-				RT_ASSERT(false,
-					  "rtlbe_hal_pwrseqcmdparsing(): "
-					  "Unknown CMD!!\n");
-				break;
-			}
-		}
-
-		ary_idx++;
-	} while (1);
-
-	return true;
-}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
deleted file mode 100644
index ce14a3b..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
+++ /dev/null
@@ -1,95 +0,0 @@
-/******************************************************************************
- *
- * Copyright(c) 2009-2014  Realtek Corporation.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- * Contact Information:
- * wlanfae <wlanfae@realtek.com>
- * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
- * Hsinchu 300, Taiwan.
- *
- * Larry Finger <Larry.Finger@lwfinger.net>
- *
- *****************************************************************************/
-
-#ifndef __RTL8723BE_PWRSEQCMD_H__
-#define __RTL8723BE_PWRSEQCMD_H__
-
-#include "../wifi.h"
-/*---------------------------------------------*/
-/*The value of cmd: 4 bits */
-/*---------------------------------------------*/
-#define PWR_CMD_READ		0x00
-#define PWR_CMD_WRITE		0x01
-#define PWR_CMD_POLLING		0x02
-#define PWR_CMD_DELAY		0x03
-#define PWR_CMD_END		0x04
-
-/* define the base address of each block */
-#define PWR_BASEADDR_MAC	0x00
-#define PWR_BASEADDR_USB	0x01
-#define PWR_BASEADDR_PCIE	0x02
-#define PWR_BASEADDR_SDIO	0x03
-
-#define	PWR_INTF_SDIO_MSK	BIT(0)
-#define	PWR_INTF_USB_MSK	BIT(1)
-#define	PWR_INTF_PCI_MSK	BIT(2)
-#define	PWR_INTF_ALL_MSK	(BIT(0) | BIT(1) | BIT(2) | BIT(3))
-
-#define	PWR_FAB_TSMC_MSK	BIT(0)
-#define	PWR_FAB_UMC_MSK		BIT(1)
-#define	PWR_FAB_ALL_MSK		(BIT(0) | BIT(1) | BIT(2) | BIT(3))
-
-#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
-#define	PWR_CUT_A_MSK		BIT(1)
-#define	PWR_CUT_B_MSK		BIT(2)
-#define	PWR_CUT_C_MSK		BIT(3)
-#define	PWR_CUT_D_MSK		BIT(4)
-#define	PWR_CUT_E_MSK		BIT(5)
-#define	PWR_CUT_F_MSK		BIT(6)
-#define	PWR_CUT_G_MSK		BIT(7)
-#define	PWR_CUT_ALL_MSK		0xFF
-
-
-enum pwrseq_delay_unit {
-	PWRSEQ_DELAY_US,
-	PWRSEQ_DELAY_MS,
-};
-
-struct wlan_pwr_cfg {
-	u16 offset;
-	u8 cut_msk;
-	u8 fab_msk:4;
-	u8 interface_msk:4;
-	u8 base:4;
-	u8 cmd:4;
-	u8 msk;
-	u8 value;
-
-};
-
-#define	GET_PWR_CFG_OFFSET(__PWR_CMD)	__PWR_CMD.offset
-#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)	__PWR_CMD.cut_msk
-#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)	__PWR_CMD.fab_msk
-#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	__PWR_CMD.interface_msk
-#define	GET_PWR_CFG_BASE(__PWR_CMD)	__PWR_CMD.base
-#define	GET_PWR_CFG_CMD(__PWR_CMD)	__PWR_CMD.cmd
-#define	GET_PWR_CFG_MASK(__PWR_CMD)	__PWR_CMD.msk
-#define	GET_PWR_CFG_VALUE(__PWR_CMD)	__PWR_CMD.value
-
-bool rtlbe_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-				 u8 fab_version, u8 interface_type,
-				 struct wlan_pwr_cfg pwrcfgcmd[]);
-
-#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
index edb7557..58bbaf4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -43,13 +43,6 @@
 
 #define LLT_CONFIG	5
 
-bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-			      u8 faversion, u8 interface_type,
-			      struct wlan_pwr_cfg pwrcfgcmd[])
-{
-	return false;
-}
-
 static void _rtl8821ae_return_beacon_queue_skb(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-- 
1.8.4.5
