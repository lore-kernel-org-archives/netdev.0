From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 9/11 V2 NEXT] rtlwifi: rtl8188ee: Update driver to match Realtek release of 06282014
Date: Sat, 27 Sep 2014 11:52:05 -0500
Message-ID: <1411836726-12699-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1411836726-12699-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:44956 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbaI0Qw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 12:52:27 -0400
In-Reply-To: <1411836726-12699-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not only does this patch update the driver to match the latest Realtek release,
it is an important step in getting the internal code source at Realtek to match
the code in the kernel. The primary reason for this is to make it easier for
Realtek to maintain the kernel source without requiring an intermediate like me.

In this process of merging the two source repositories, there are a lot
of changes in both, and this commit is rather large.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

This patch replaces patch 09/11 of the previous series. The duplicate
global problem reported by the zero-day kbuild test robot is fixed.

Larry
---

 drivers/net/wireless/rtlwifi/core.c                |   98 +
 drivers/net/wireless/rtlwifi/pwrseqcmd.h           |   94 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h       |   66 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        |  881 +++---
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h        |   23 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  231 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h        |   29 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 1259 +++++----
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c       |   49 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/led.h       |    4 -
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       | 2151 +++++++-------
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |   49 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |  102 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |  415 ++-
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c |  140 -
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |   93 -
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       | 2936 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c        |  282 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |   41 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/table.c     |    6 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/table.h     |   12 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  444 ++-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |   83 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |   98 -
 drivers/net/wireless/rtlwifi/rtl8723be/Makefile    |    1 -
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |   16 +-
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/wifi.h                |    5 +-
 35 files changed, 5051 insertions(+), 4580 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/pwrseqcmd.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
 delete mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h

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
diff --git a/drivers/net/wireless/rtlwifi/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/pwrseqcmd.h
new file mode 100644
index 0000000..cce0a41
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/pwrseqcmd.h
@@ -0,0 +1,94 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTLWIFI_PWRSEQCMD_H__
+#define __RTLWIFI_PWRSEQCMD_H__
+
+#include "wifi.h"
+/*---------------------------------------------
+ * 3 The value of cmd: 4 bits
+ *---------------------------------------------
+ */
+#define    PWR_CMD_READ		0x00
+#define    PWR_CMD_WRITE	0x01
+#define    PWR_CMD_POLLING	0x02
+#define    PWR_CMD_DELAY	0x03
+#define    PWR_CMD_END		0x04
+
+/* define the base address of each block */
+#define   PWR_BASEADDR_MAC	0x00
+#define   PWR_BASEADDR_USB	0x01
+#define   PWR_BASEADDR_PCIE	0x02
+#define   PWR_BASEADDR_SDIO	0x03
+
+#define	PWR_INTF_SDIO_MSK	BIT(0)
+#define	PWR_INTF_USB_MSK	BIT(1)
+#define	PWR_INTF_PCI_MSK	BIT(2)
+#define	PWR_INTF_ALL_MSK	(BIT(0)|BIT(1)|BIT(2)|BIT(3))
+
+#define	PWR_FAB_TSMC_MSK	BIT(0)
+#define	PWR_FAB_UMC_MSK		BIT(1)
+#define	PWR_FAB_ALL_MSK		(BIT(0)|BIT(1)|BIT(2)|BIT(3))
+
+#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
+#define	PWR_CUT_A_MSK		BIT(1)
+#define	PWR_CUT_B_MSK		BIT(2)
+#define	PWR_CUT_C_MSK		BIT(3)
+#define	PWR_CUT_D_MSK		BIT(4)
+#define	PWR_CUT_E_MSK		BIT(5)
+#define	PWR_CUT_F_MSK		BIT(6)
+#define	PWR_CUT_G_MSK		BIT(7)
+#define	PWR_CUT_ALL_MSK		0xFF
+
+enum pwrseq_delay_unit {
+	PWRSEQ_DELAY_US,
+	PWRSEQ_DELAY_MS,
+};
+
+struct wlan_pwr_cfg {
+	u16 offset;
+	u8 cut_msk;
+	u8 fab_msk:4;
+	u8 interface_msk:4;
+	u8 base:4;
+	u8 cmd:4;
+	u8 msk;
+	u8 value;
+};
+
+#define	GET_PWR_CFG_OFFSET(__PWR_CMD)	(__PWR_CMD.offset)
+#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)	(__PWR_CMD.cut_msk)
+#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)	(__PWR_CMD.fab_msk)
+#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	(__PWR_CMD.interface_msk)
+#define	GET_PWR_CFG_BASE(__PWR_CMD)	(__PWR_CMD.base)
+#define	GET_PWR_CFG_CMD(__PWR_CMD)	(__PWR_CMD.cmd)
+#define	GET_PWR_CFG_MASK(__PWR_CMD)	(__PWR_CMD.msk)
+#define	GET_PWR_CFG_VALUE(__PWR_CMD)	(__PWR_CMD.value)
+
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 fab_version, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[]);
+
+#endif
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
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/def.h b/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
index c764fff..d9ea9d0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
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
@@ -111,7 +107,6 @@
 
 #define CHIP_BONDING_IDENTIFIER(_value)	(((_value)>>22)&0x3)
 
-
 /* [15:12] IC version(CUT): A-cut=0, B-cut=1, C-cut=2, D-cut=3
  * [7] Manufacturer: TSMC=0, UMC=1
  * [6:4] RF type: 1T1R=0, 1T2R=1, 2T2R=2
@@ -130,7 +125,6 @@
 #define D_CUT_VERSION			((BIT(12)|BIT(13)))
 #define E_CUT_VERSION			BIT(14)
 
-
 /* MASK */
 #define IC_TYPE_MASK			(BIT(0)|BIT(1)|BIT(2))
 #define CHIP_TYPE_MASK			BIT(3)
@@ -147,7 +141,6 @@
 #define GET_CVID_ROM_VERSION(version)	((version) & ROM_VERSION_MASK)
 #define GET_CVID_CUT_VERSION(version)	((version) & CUT_VERSION_MASK)
 
-
 #define IS_81XXC(version)						\
 	((GET_CVID_IC_TYPE(version) == 0) ? true : false)
 #define IS_8723_SERIES(version)						\
@@ -174,7 +167,7 @@
 #define IS_81xxC_VENDOR_UMC_A_CUT(version)				\
 	(IS_81XXC(version) ? ((IS_CHIP_VENDOR_UMC(version)) ?		\
 	 ((GET_CVID_CUT_VERSION(version)) ? false : true) : false) : false)
-#define IS_81xxC_VENDOR_UMC_B_CUT(version)				\
+#define IS_81XXC_VENDOR_UMC_B_CUT(version)				\
 	(IS_81XXC(version) ? (IS_CHIP_VENDOR_UMC(version) ?		\
 	((GET_CVID_CUT_VERSION(version) == B_CUT_VERSION) ? true	\
 	: false) : false) : false)
@@ -225,44 +218,37 @@ enum power_polocy_config {
 };
 
 enum interface_select_pci {
-	INTF_SEL1_MINICARD,
-	INTF_SEL0_PCIE,
-	INTF_SEL2_RSV,
-	INTF_SEL3_RSV,
+	INTF_SEL1_MINICARD = 0,
+	INTF_SEL0_PCIE = 1,
+	INTF_SEL2_RSV = 2,
+	INTF_SEL3_RSV = 3,
 };
 
 enum hal_fw_c2h_cmd_id {
-	HAL_FW_C2H_CMD_Read_MACREG,
-	HAL_FW_C2H_CMD_Read_BBREG,
-	HAL_FW_C2H_CMD_Read_RFREG,
-	HAL_FW_C2H_CMD_Read_EEPROM,
-	HAL_FW_C2H_CMD_Read_EFUSE,
-	HAL_FW_C2H_CMD_Read_CAM,
-	HAL_FW_C2H_CMD_Get_BasicRate,
-	HAL_FW_C2H_CMD_Get_DataRate,
-	HAL_FW_C2H_CMD_Survey,
-	HAL_FW_C2H_CMD_SurveyDone,
-	HAL_FW_C2H_CMD_JoinBss,
-	HAL_FW_C2H_CMD_AddSTA,
-	HAL_FW_C2H_CMD_DelSTA,
-	HAL_FW_C2H_CMD_AtimDone,
-	HAL_FW_C2H_CMD_TX_Report,
-	HAL_FW_C2H_CMD_CCX_Report,
-	HAL_FW_C2H_CMD_DTM_Report,
-	HAL_FW_C2H_CMD_TX_Rate_Statistics,
-	HAL_FW_C2H_CMD_C2HLBK,
-	HAL_FW_C2H_CMD_C2HDBG,
-	HAL_FW_C2H_CMD_C2HFEEDBACK,
+	HAL_FW_C2H_CMD_READ_MACREG = 0,
+	HAL_FW_C2H_CMD_READ_BBREG = 1,
+	HAL_FW_C2H_CMD_READ_RFREG = 2,
+	HAL_FW_C2H_CMD_READ_EEPROM = 3,
+	HAL_FW_C2H_CMD_READ_EFUSE = 4,
+	HAL_FW_C2H_CMD_READ_CAM = 5,
+	HAL_FW_C2H_CMD_GET_BASICRATE = 6,
+	HAL_FW_C2H_CMD_GET_DATARATE = 7,
+	HAL_FW_C2H_CMD_SURVEY = 8,
+	HAL_FW_C2H_CMD_SURVEYDONE = 9,
+	HAL_FW_C2H_CMD_JOINBSS = 10,
+	HAL_FW_C2H_CMD_ADDSTA = 11,
+	HAL_FW_C2H_CMD_DELSTA = 12,
+	HAL_FW_C2H_CMD_ATIMDONE = 13,
+	HAL_FW_C2H_CMD_TX_REPORT = 14,
+	HAL_FW_C2H_CMD_CCX_REPORT = 15,
+	HAL_FW_C2H_CMD_DTM_REPORT = 16,
+	HAL_FW_C2H_CMD_TX_RATE_STATISTICS = 17,
+	HAL_FW_C2H_CMD_C2HLBK = 18,
+	HAL_FW_C2H_CMD_C2HDBG = 19,
+	HAL_FW_C2H_CMD_C2HFEEDBACK = 20,
 	HAL_FW_C2H_CMD_MAX
 };
 
-enum wake_on_wlan_mode {
-	ewowlandisable,
-	ewakeonmagicpacketonly,
-	ewakeonpatternmatchonly,
-	ewakeonbothtypepacket
-};
-
 enum rtl_desc_qsel {
 	QSLT_BK = 0x2,
 	QSLT_BE = 0x0,
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
index f8daa61..2aa34d9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
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
@@ -188,21 +184,24 @@ static void rtl88e_set_iqk_matrix(struct ieee80211_hw *hw,
 		switch (rfpath) {
 		case RF90_PATH_A:
 			value32 = (ele_d << 22)|((ele_c & 0x3F)<<16) | ele_a;
-			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBAL, MASKDWORD,
-				      value32);
+			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
+				      MASKDWORD, value32);
 			value32 = (ele_c & 0x000003C0) >> 6;
-			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS, value32);
+			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS,
+				      value32);
 			value32 = ((iqk_result_x * ele_d) >> 7) & 0x01;
-			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(24), value32);
+			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(24),
+				      value32);
 			break;
 		case RF90_PATH_B:
 			value32 = (ele_d << 22)|((ele_c & 0x3F)<<16) | ele_a;
-			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBAL,
-				      MASKDWORD, value32);
+			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE, MASKDWORD,
+				      value32);
 			value32 = (ele_c & 0x000003C0) >> 6;
 			rtl_set_bbreg(hw, ROFDM0_XDTXAFE, MASKH4BITS, value32);
 			value32 = ((iqk_result_x * ele_d) >> 7) & 0x01;
-			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(28), value32);
+			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(28),
+				      value32);
 			break;
 		default:
 			break;
@@ -210,16 +209,20 @@ static void rtl88e_set_iqk_matrix(struct ieee80211_hw *hw,
 	} else {
 		switch (rfpath) {
 		case RF90_PATH_A:
-			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBAL, MASKDWORD,
-				      ofdmswing_table[ofdm_index]);
-			rtl_set_bbreg(hw, ROFDM0_XCTXAFE, MASKH4BITS, 0x00);
-			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(24), 0x00);
+			rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
+				      MASKDWORD, ofdmswing_table[ofdm_index]);
+			rtl_set_bbreg(hw, ROFDM0_XCTXAFE,
+				      MASKH4BITS, 0x00);
+			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD,
+				      BIT(24), 0x00);
 			break;
 		case RF90_PATH_B:
-			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBAL, MASKDWORD,
-				      ofdmswing_table[ofdm_index]);
-			rtl_set_bbreg(hw, ROFDM0_XDTXAFE, MASKH4BITS, 0x00);
-			rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(28), 0x00);
+			rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE,
+				      MASKDWORD, ofdmswing_table[ofdm_index]);
+			rtl_set_bbreg(hw, ROFDM0_XDTXAFE,
+				      MASKH4BITS, 0x00);
+			rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD,
+				      BIT(28), 0x00);
 			break;
 		default:
 			break;
@@ -244,7 +247,7 @@ void rtl88e_dm_txpower_track_adjust(struct ieee80211_hw *hw,
 			pwr_val = ofdm_base - ofdm_val;
 		} else {
 			*pdirection = 2;
-			pwr_val = ofdm_val - ofdm_base;
+			pwr_val = ofdm_base - ofdm_val;
 		}
 	} else if (type == 1) {
 		if (cck_val <= cck_base) {
@@ -263,46 +266,75 @@ void rtl88e_dm_txpower_track_adjust(struct ieee80211_hw *hw,
 			 (pwr_val << 24);
 }
 
-
-static void rtl88e_chk_tx_track(struct ieee80211_hw *hw,
-				enum pwr_track_control_method method,
-				u8 rfpath, u8 index)
+static void dm_tx_pwr_track_set_pwr(struct ieee80211_hw *hw,
+				    enum pwr_track_control_method method,
+				    u8 rfpath, u8 channel_mapped_index)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	int jj = rtldm->swing_idx_cck;
-	int i;
 
 	if (method == TXAGC) {
-		if (rtldm->swing_flag_ofdm == true ||
-		    rtldm->swing_flag_cck == true) {
-			u8 chan = rtlphy->current_channel;
-			rtl88e_phy_set_txpower_level(hw, chan);
+		if (rtldm->swing_flag_ofdm ||
+		    rtldm->swing_flag_cck) {
+			rtl88e_phy_set_txpower_level(hw,
+						     rtlphy->current_channel);
 			rtldm->swing_flag_ofdm = false;
 			rtldm->swing_flag_cck = false;
 		}
 	} else if (method == BBSWING) {
 		if (!rtldm->cck_inch14) {
-			for (i = 0; i < 8; i++)
-				rtl_write_byte(rtlpriv, 0xa22 + i,
-					       cck_tbl_ch1_13[jj][i]);
+			rtl_write_byte(rtlpriv, 0xa22,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][0]);
+			rtl_write_byte(rtlpriv, 0xa23,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][1]);
+			rtl_write_byte(rtlpriv, 0xa24,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][2]);
+			rtl_write_byte(rtlpriv, 0xa25,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][3]);
+			rtl_write_byte(rtlpriv, 0xa26,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][4]);
+			rtl_write_byte(rtlpriv, 0xa27,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][5]);
+			rtl_write_byte(rtlpriv, 0xa28,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][6]);
+			rtl_write_byte(rtlpriv, 0xa29,
+				       cck_tbl_ch1_13[rtldm->swing_idx_cck][7]);
 		} else {
-			for (i = 0; i < 8; i++)
-				rtl_write_byte(rtlpriv, 0xa22 + i,
-					       cck_tbl_ch14[jj][i]);
+			rtl_write_byte(rtlpriv, 0xa22,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][0]);
+			rtl_write_byte(rtlpriv, 0xa23,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][1]);
+			rtl_write_byte(rtlpriv, 0xa24,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][2]);
+			rtl_write_byte(rtlpriv, 0xa25,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][3]);
+			rtl_write_byte(rtlpriv, 0xa26,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][4]);
+			rtl_write_byte(rtlpriv, 0xa27,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][5]);
+			rtl_write_byte(rtlpriv, 0xa28,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][6]);
+			rtl_write_byte(rtlpriv, 0xa29,
+				       cck_tbl_ch14[rtldm->swing_idx_cck][7]);
 		}
 
 		if (rfpath == RF90_PATH_A) {
-			long x = rtlphy->iqk_matrix[index].value[0][0];
-			long y = rtlphy->iqk_matrix[index].value[0][1];
-			u8 indx = rtldm->swing_idx_ofdm[rfpath];
-			rtl88e_set_iqk_matrix(hw, indx, rfpath, x, y);
+			rtl88e_set_iqk_matrix(hw, rtldm->swing_idx_ofdm[rfpath],
+					      rfpath, rtlphy->iqk_matrix
+					      [channel_mapped_index].
+					      value[0][0],
+					      rtlphy->iqk_matrix
+					      [channel_mapped_index].
+					      value[0][1]);
 		} else if (rfpath == RF90_PATH_B) {
-			u8 indx = rtldm->swing_idx_ofdm[rfpath];
-			long x = rtlphy->iqk_matrix[indx].value[0][4];
-			long y = rtlphy->iqk_matrix[indx].value[0][5];
-			rtl88e_set_iqk_matrix(hw, indx, rfpath, x, y);
+			rtl88e_set_iqk_matrix(hw, rtldm->swing_idx_ofdm[rfpath],
+					      rfpath, rtlphy->iqk_matrix
+					      [channel_mapped_index].
+					      value[0][4],
+					      rtlphy->iqk_matrix
+					      [channel_mapped_index].
+					      value[0][5]);
 		}
 	} else {
 		return;
@@ -317,7 +349,7 @@ static void rtl88e_dm_diginit(struct ieee80211_hw *hw)
 	dm_dig->dig_enable_flag = true;
 	dm_dig->cur_igvalue = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f);
 	dm_dig->pre_igvalue = 0;
-	dm_dig->cursta_cstate = DIG_STA_DISCONNECT;
+	dm_dig->cur_sta_cstate = DIG_STA_DISCONNECT;
 	dm_dig->presta_cstate = DIG_STA_DISCONNECT;
 	dm_dig->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
 	dm_dig->rssi_lowthresh = DM_DIG_THRESH_LOW;
@@ -348,22 +380,23 @@ static u8 rtl88e_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
 	long rssi_val_min = 0;
 
 	if ((dm_dig->curmultista_cstate == DIG_MULTISTA_CONNECT) &&
-	    (dm_dig->cursta_cstate == DIG_STA_CONNECT)) {
+	    (dm_dig->cur_sta_cstate == DIG_STA_CONNECT)) {
 		if (rtlpriv->dm.entry_min_undec_sm_pwdb != 0)
 			rssi_val_min =
 			    (rtlpriv->dm.entry_min_undec_sm_pwdb >
-			    rtlpriv->dm.undec_sm_pwdb) ?
+			     rtlpriv->dm.undec_sm_pwdb) ?
 			    rtlpriv->dm.undec_sm_pwdb :
 			    rtlpriv->dm.entry_min_undec_sm_pwdb;
 		else
 			rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
-	} else if (dm_dig->cursta_cstate == DIG_STA_CONNECT ||
-		   dm_dig->cursta_cstate == DIG_STA_BEFORE_CONNECT) {
+	} else if (dm_dig->cur_sta_cstate == DIG_STA_CONNECT ||
+		   dm_dig->cur_sta_cstate == DIG_STA_BEFORE_CONNECT) {
 		rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
 	} else if (dm_dig->curmultista_cstate ==
 		DIG_MULTISTA_CONNECT) {
 		rssi_val_min = rtlpriv->dm.entry_min_undec_sm_pwdb;
 	}
+
 	return (u8)rssi_val_min;
 }
 
@@ -371,57 +404,58 @@ static void rtl88e_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 {
 	u32 ret_value;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct false_alarm_statistics *alm_cnt = &(rtlpriv->falsealm_cnt);
+	struct false_alarm_statistics *falsealm_cnt = &rtlpriv->falsealm_cnt;
 
 	rtl_set_bbreg(hw, ROFDM0_LSTF, BIT(31), 1);
 	rtl_set_bbreg(hw, ROFDM1_LSTF, BIT(31), 1);
 
 	ret_value = rtl_get_bbreg(hw, ROFDM0_FRAMESYNC, MASKDWORD);
-	alm_cnt->cnt_fast_fsync_fail = (ret_value&0xffff);
-	alm_cnt->cnt_sb_search_fail = ((ret_value&0xffff0000)>>16);
+	falsealm_cnt->cnt_fast_fsync_fail = (ret_value&0xffff);
+	falsealm_cnt->cnt_sb_search_fail = ((ret_value&0xffff0000)>>16);
 
 	ret_value = rtl_get_bbreg(hw, ROFDM_PHYCOUNTER1, MASKDWORD);
-	alm_cnt->cnt_ofdm_cca = (ret_value&0xffff);
-	alm_cnt->cnt_parity_fail = ((ret_value & 0xffff0000) >> 16);
+	falsealm_cnt->cnt_ofdm_cca = (ret_value&0xffff);
+	falsealm_cnt->cnt_parity_fail = ((ret_value & 0xffff0000) >> 16);
 
 	ret_value = rtl_get_bbreg(hw, ROFDM_PHYCOUNTER2, MASKDWORD);
-	alm_cnt->cnt_rate_illegal = (ret_value & 0xffff);
-	alm_cnt->cnt_crc8_fail = ((ret_value & 0xffff0000) >> 16);
+	falsealm_cnt->cnt_rate_illegal = (ret_value & 0xffff);
+	falsealm_cnt->cnt_crc8_fail = ((ret_value & 0xffff0000) >> 16);
 
 	ret_value = rtl_get_bbreg(hw, ROFDM_PHYCOUNTER3, MASKDWORD);
-	alm_cnt->cnt_mcs_fail = (ret_value & 0xffff);
-	alm_cnt->cnt_ofdm_fail = alm_cnt->cnt_parity_fail +
-				 alm_cnt->cnt_rate_illegal +
-				 alm_cnt->cnt_crc8_fail +
-				 alm_cnt->cnt_mcs_fail +
-				 alm_cnt->cnt_fast_fsync_fail +
-				 alm_cnt->cnt_sb_search_fail;
+	falsealm_cnt->cnt_mcs_fail = (ret_value & 0xffff);
+	falsealm_cnt->cnt_ofdm_fail = falsealm_cnt->cnt_parity_fail +
+		falsealm_cnt->cnt_rate_illegal +
+		falsealm_cnt->cnt_crc8_fail +
+		falsealm_cnt->cnt_mcs_fail +
+		falsealm_cnt->cnt_fast_fsync_fail +
+		falsealm_cnt->cnt_sb_search_fail;
 
 	ret_value = rtl_get_bbreg(hw, REG_SC_CNT, MASKDWORD);
-	alm_cnt->cnt_bw_lsc = (ret_value & 0xffff);
-	alm_cnt->cnt_bw_usc = ((ret_value & 0xffff0000) >> 16);
+	falsealm_cnt->cnt_bw_lsc = (ret_value & 0xffff);
+	falsealm_cnt->cnt_bw_usc = ((ret_value & 0xffff0000) >> 16);
 
 	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, BIT(12), 1);
 	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, BIT(14), 1);
 
 	ret_value = rtl_get_bbreg(hw, RCCK0_FACOUNTERLOWER, MASKBYTE0);
-	alm_cnt->cnt_cck_fail = ret_value;
+	falsealm_cnt->cnt_cck_fail = ret_value;
 
 	ret_value = rtl_get_bbreg(hw, RCCK0_FACOUNTERUPPER, MASKBYTE3);
-	alm_cnt->cnt_cck_fail += (ret_value & 0xff) << 8;
+	falsealm_cnt->cnt_cck_fail += (ret_value & 0xff) << 8;
 
 	ret_value = rtl_get_bbreg(hw, RCCK0_CCA_CNT, MASKDWORD);
-	alm_cnt->cnt_cck_cca = ((ret_value & 0xff) << 8) |
-				((ret_value&0xFF00)>>8);
-
-	alm_cnt->cnt_all = alm_cnt->cnt_fast_fsync_fail +
-			   alm_cnt->cnt_sb_search_fail +
-			   alm_cnt->cnt_parity_fail +
-			   alm_cnt->cnt_rate_illegal +
-			   alm_cnt->cnt_crc8_fail +
-			   alm_cnt->cnt_mcs_fail +
-			   alm_cnt->cnt_cck_fail;
-	alm_cnt->cnt_cca_all = alm_cnt->cnt_ofdm_cca + alm_cnt->cnt_cck_cca;
+	falsealm_cnt->cnt_cck_cca = ((ret_value & 0xff) << 8) |
+		((ret_value&0xFF00)>>8);
+
+	falsealm_cnt->cnt_all = (falsealm_cnt->cnt_fast_fsync_fail +
+				falsealm_cnt->cnt_sb_search_fail +
+				falsealm_cnt->cnt_parity_fail +
+				falsealm_cnt->cnt_rate_illegal +
+				falsealm_cnt->cnt_crc8_fail +
+				falsealm_cnt->cnt_mcs_fail +
+				falsealm_cnt->cnt_cck_fail);
+	falsealm_cnt->cnt_cca_all = falsealm_cnt->cnt_ofdm_cca +
+		falsealm_cnt->cnt_cck_cca;
 
 	rtl_set_bbreg(hw, ROFDM0_TRSWISOLATION, BIT(31), 1);
 	rtl_set_bbreg(hw, ROFDM0_TRSWISOLATION, BIT(31), 0);
@@ -435,16 +469,15 @@ static void rtl88e_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, BIT(15)|BIT(14), 2);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, "
-		 "cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
-		 alm_cnt->cnt_parity_fail,
-		 alm_cnt->cnt_rate_illegal,
-		 alm_cnt->cnt_crc8_fail, alm_cnt->cnt_mcs_fail);
+		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
+		 falsealm_cnt->cnt_parity_fail,
+		 falsealm_cnt->cnt_rate_illegal,
+		 falsealm_cnt->cnt_crc8_fail, falsealm_cnt->cnt_mcs_fail);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
 		 "cnt_ofdm_fail = %x, cnt_cck_fail = %x, cnt_all = %x\n",
-		 alm_cnt->cnt_ofdm_fail,
-		 alm_cnt->cnt_cck_fail, alm_cnt->cnt_all);
+		 falsealm_cnt->cnt_ofdm_fail,
+		 falsealm_cnt->cnt_cck_fail, falsealm_cnt->cnt_all);
 }
 
 static void rtl88e_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
@@ -453,7 +486,7 @@ static void rtl88e_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
 	u8 cur_cck_cca_thresh;
 
-	if (dm_dig->cursta_cstate == DIG_STA_CONNECT) {
+	if (dm_dig->cur_sta_cstate == DIG_STA_CONNECT) {
 		dm_dig->rssi_val_min = rtl88e_dm_initial_gain_min_pwdb(hw);
 		if (dm_dig->rssi_val_min > 25) {
 			cur_cck_cca_thresh = 0xcd;
@@ -486,10 +519,10 @@ static void rtl88e_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-	u8 dig_min, dig_maxofmin;
+	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
+	u8 dig_dynamic_min, dig_maxofmin;
 	bool bfirstconnect;
 	u8 dm_dig_max, dm_dig_min;
 	u8 current_igi = dm_dig->cur_igvalue;
@@ -502,19 +535,19 @@ static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 		return;
 
 	if (mac->link_state >= MAC80211_LINKED)
-		dm_dig->cursta_cstate = DIG_STA_CONNECT;
+		dm_dig->cur_sta_cstate = DIG_STA_CONNECT;
 	else
-		dm_dig->cursta_cstate = DIG_STA_DISCONNECT;
+		dm_dig->cur_sta_cstate = DIG_STA_DISCONNECT;
 	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP ||
 	    rtlpriv->mac80211.opmode == NL80211_IFTYPE_ADHOC)
-		dm_dig->cursta_cstate = DIG_STA_DISCONNECT;
+		dm_dig->cur_sta_cstate = DIG_STA_DISCONNECT;
 
 	dm_dig_max = DM_DIG_MAX;
 	dm_dig_min = DM_DIG_MIN;
 	dig_maxofmin = DM_DIG_MAX_AP;
-	dig_min = dm_dig->dig_min_0;
+	dig_dynamic_min = dm_dig->dig_min_0;
 	bfirstconnect = ((mac->link_state >= MAC80211_LINKED) ? true : false) &&
-			 (dm_dig->media_connect_0 == false);
+			 !dm_dig->media_connect_0;
 
 	dm_dig->rssi_val_min =
 		rtl88e_dm_initial_gain_min_pwdb(hw);
@@ -528,18 +561,18 @@ static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 			dm_dig->rx_gain_max = dm_dig->rssi_val_min + 20;
 
 		if (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) {
-			dig_min  = dm_dig->antdiv_rssi_max;
+			dig_dynamic_min  = dm_dig->antdiv_rssi_max;
 		} else {
 			if (dm_dig->rssi_val_min < dm_dig_min)
-				dig_min = dm_dig_min;
+				dig_dynamic_min = dm_dig_min;
 			else if (dm_dig->rssi_val_min < dig_maxofmin)
-				dig_min = dig_maxofmin;
+				dig_dynamic_min = dig_maxofmin;
 			else
-				dig_min = dm_dig->rssi_val_min;
+				dig_dynamic_min = dm_dig->rssi_val_min;
 		}
 	} else {
 		dm_dig->rx_gain_max = dm_dig_max;
-		dig_min = dm_dig_min;
+		dig_dynamic_min = dm_dig_min;
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "no link\n");
 	}
 
@@ -551,10 +584,13 @@ static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 		}
 
 		if (dm_dig->large_fa_hit >= 3) {
-			if ((dm_dig->forbidden_igi + 1) > dm_dig->rx_gain_max)
-				dm_dig->rx_gain_min = dm_dig->rx_gain_max;
+			if ((dm_dig->forbidden_igi + 1) >
+				dm_dig->rx_gain_max)
+				dm_dig->rx_gain_min =
+					dm_dig->rx_gain_max;
 			else
-				dm_dig->rx_gain_min = dm_dig->forbidden_igi + 1;
+				dm_dig->rx_gain_min =
+					dm_dig->forbidden_igi + 1;
 			dm_dig->recover_cnt = 3600;
 		}
 	} else {
@@ -562,13 +598,14 @@ static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 			dm_dig->recover_cnt--;
 		} else {
 			if (dm_dig->large_fa_hit == 0) {
-				if ((dm_dig->forbidden_igi - 1) < dig_min) {
-					dm_dig->forbidden_igi = dig_min;
-					dm_dig->rx_gain_min = dig_min;
+				if ((dm_dig->forbidden_igi - 1) <
+				    dig_dynamic_min) {
+					dm_dig->forbidden_igi = dig_dynamic_min;
+					dm_dig->rx_gain_min = dig_dynamic_min;
 				} else {
 					dm_dig->forbidden_igi--;
 					dm_dig->rx_gain_min =
-						 dm_dig->forbidden_igi + 1;
+						dm_dig->forbidden_igi + 1;
 				}
 			} else if (dm_dig->large_fa_hit == 3) {
 				dm_dig->large_fa_hit = 0;
@@ -576,7 +613,7 @@ static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 		}
 	}
 
-	if (dm_dig->cursta_cstate == DIG_STA_CONNECT) {
+	if (dm_dig->cur_sta_cstate == DIG_STA_CONNECT) {
 		if (bfirstconnect) {
 			current_igi = dm_dig->rssi_val_min;
 		} else {
@@ -606,9 +643,9 @@ static void rtl88e_dm_dig(struct ieee80211_hw *hw)
 
 	dm_dig->cur_igvalue = current_igi;
 	rtl88e_dm_write_dig(hw);
-	dm_dig->media_connect_0 = ((mac->link_state >= MAC80211_LINKED) ?
-				    true : false);
-	dm_dig->dig_min_0 = dig_min;
+	dm_dig->media_connect_0 =
+		((mac->link_state >= MAC80211_LINKED) ? true : false);
+	dm_dig->dig_min_0 = dig_dynamic_min;
 
 	rtl88e_dm_cck_packet_detection_thresh(hw);
 }
@@ -626,7 +663,7 @@ static void rtl88e_dm_init_dynamic_txpower(struct ieee80211_hw *hw)
 static void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	long undec_sm_pwdb;
 
@@ -641,7 +678,7 @@ static void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 "Not connected\n");
+			 "Not connected to any\n");
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 
@@ -664,10 +701,12 @@ static void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 				  undec_sm_pwdb);
 		}
 	} else {
-		undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
+		undec_sm_pwdb =
+		    rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 "AP Ext Port PWDB = 0x%lx\n", undec_sm_pwdb);
+			 "AP Ext Port PWDB = 0x%lx\n",
+			  undec_sm_pwdb);
 	}
 
 	if (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
@@ -676,17 +715,20 @@ static void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr = 0x0)\n");
 	} else if ((undec_sm_pwdb <
 		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
-		   (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
+		   (undec_sm_pwdb >=
+		    TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr = 0x10)\n");
-	} else if (undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
+	} else if (undec_sm_pwdb <
+		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_NORMAL\n");
 	}
 
-	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
+	if ((rtlpriv->dm.dynamic_txhighpower_lvl !=
+		rtlpriv->dm.last_dtp_lvl)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
 			  rtlphy->current_channel);
@@ -702,10 +744,9 @@ void rtl88e_dm_write_dig(struct ieee80211_hw *hw)
 	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 "cur_igvalue = 0x%x, "
-		  "pre_igvalue = 0x%x, back_val = %d\n",
-		  dm_dig->cur_igvalue, dm_dig->pre_igvalue,
-		  dm_dig->back_val);
+		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, backoff_val = %d\n",
+		 dm_dig->cur_igvalue, dm_dig->pre_igvalue,
+		 dm_dig->back_val);
 
 	if (dm_dig->cur_igvalue > 0x3f)
 		dm_dig->cur_igvalue = 0x3f;
@@ -722,17 +763,19 @@ static void rtl88e_dm_pwdb_monitor(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_sta_info *drv_priv;
-	static u64 last_txok;
-	static u64 last_rx;
+	static u64 last_record_txok_cnt;
+	static u64 last_record_rxok_cnt;
 	long tmp_entry_max_pwdb = 0, tmp_entry_min_pwdb = 0xff;
 
 	if (rtlhal->oem_id == RT_CID_819X_HP) {
 		u64 cur_txok_cnt = 0;
 		u64 cur_rxok_cnt = 0;
-		cur_txok_cnt = rtlpriv->stats.txbytesunicast - last_txok;
-		cur_rxok_cnt = rtlpriv->stats.rxbytesunicast - last_rx;
-		last_txok = cur_txok_cnt;
-		last_rx = cur_rxok_cnt;
+		cur_txok_cnt = rtlpriv->stats.txbytesunicast -
+			last_record_txok_cnt;
+		cur_rxok_cnt = rtlpriv->stats.rxbytesunicast -
+			last_record_rxok_cnt;
+		last_record_txok_cnt = cur_txok_cnt;
+		last_record_rxok_cnt = cur_rxok_cnt;
 
 		if (cur_rxok_cnt > (cur_txok_cnt * 6))
 			rtl_write_dword(rtlpriv, REG_ARFR0, 0x8f015);
@@ -743,9 +786,11 @@ static void rtl88e_dm_pwdb_monitor(struct ieee80211_hw *hw)
 	/* AP & ADHOC & MESH */
 	spin_lock_bh(&rtlpriv->locks.entry_list_lock);
 	list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
-		if (drv_priv->rssi_stat.undec_sm_pwdb < tmp_entry_min_pwdb)
+		if (drv_priv->rssi_stat.undec_sm_pwdb <
+			tmp_entry_min_pwdb)
 			tmp_entry_min_pwdb = drv_priv->rssi_stat.undec_sm_pwdb;
-		if (drv_priv->rssi_stat.undec_sm_pwdb > tmp_entry_max_pwdb)
+		if (drv_priv->rssi_stat.undec_sm_pwdb >
+			tmp_entry_max_pwdb)
 			tmp_entry_max_pwdb = drv_priv->rssi_stat.undec_sm_pwdb;
 	}
 	spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
@@ -762,13 +807,19 @@ static void rtl88e_dm_pwdb_monitor(struct ieee80211_hw *hw)
 	if (tmp_entry_min_pwdb != 0xff) {
 		rtlpriv->dm.entry_min_undec_sm_pwdb = tmp_entry_min_pwdb;
 		RTPRINT(rtlpriv, FDM, DM_PWDB, "EntryMinPWDB = 0x%lx(%ld)\n",
-			tmp_entry_min_pwdb, tmp_entry_min_pwdb);
+					tmp_entry_min_pwdb, tmp_entry_min_pwdb);
 	} else {
 		rtlpriv->dm.entry_min_undec_sm_pwdb = 0;
 	}
 	/* Indicate Rx signal strength to FW. */
-	if (!rtlpriv->dm.useramask)
+	if (rtlpriv->dm.useramask) {
+		u8 h2c_parameter[3] = { 0 };
+
+		h2c_parameter[2] = (u8)(rtlpriv->dm.undec_sm_pwdb & 0xFF);
+		h2c_parameter[0] = 0x20;
+	} else {
 		rtl_write_byte(rtlpriv, 0x4fe, rtlpriv->dm.undec_sm_pwdb);
+	}
 }
 
 void rtl88e_dm_init_edca_turbo(struct ieee80211_hw *hw)
@@ -783,7 +834,6 @@ void rtl88e_dm_init_edca_turbo(struct ieee80211_hw *hw)
 static void rtl88e_dm_check_edca_turbo(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	static u64 last_txok_cnt;
 	static u64 last_rxok_cnt;
@@ -793,40 +843,33 @@ static void rtl88e_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	u64 cur_rxok_cnt = 0;
 	u32 edca_be_ul = 0x5ea42b;
 	u32 edca_be_dl = 0x5ea42b;
-	bool change_edca = false;
+	bool bt_change_edca = false;
 
-	if ((last_bt_edca_ul != rtlpcipriv->bt_coexist.bt_edca_ul) ||
-	    (last_bt_edca_dl != rtlpcipriv->bt_coexist.bt_edca_dl)) {
+	if ((last_bt_edca_ul != rtlpriv->btcoexist.bt_edca_ul) ||
+	    (last_bt_edca_dl != rtlpriv->btcoexist.bt_edca_dl)) {
 		rtlpriv->dm.current_turbo_edca = false;
-		last_bt_edca_ul = rtlpcipriv->bt_coexist.bt_edca_ul;
-		last_bt_edca_dl = rtlpcipriv->bt_coexist.bt_edca_dl;
+		last_bt_edca_ul = rtlpriv->btcoexist.bt_edca_ul;
+		last_bt_edca_dl = rtlpriv->btcoexist.bt_edca_dl;
 	}
 
-	if (rtlpcipriv->bt_coexist.bt_edca_ul != 0) {
-		edca_be_ul = rtlpcipriv->bt_coexist.bt_edca_ul;
-		change_edca = true;
+	if (rtlpriv->btcoexist.bt_edca_ul != 0) {
+		edca_be_ul = rtlpriv->btcoexist.bt_edca_ul;
+		bt_change_edca = true;
 	}
 
-	if (rtlpcipriv->bt_coexist.bt_edca_dl != 0) {
-		edca_be_ul = rtlpcipriv->bt_coexist.bt_edca_dl;
-		change_edca = true;
+	if (rtlpriv->btcoexist.bt_edca_dl != 0) {
+		edca_be_ul = rtlpriv->btcoexist.bt_edca_dl;
+		bt_change_edca = true;
 	}
 
 	if (mac->link_state != MAC80211_LINKED) {
 		rtlpriv->dm.current_turbo_edca = false;
 		return;
 	}
+	if ((bt_change_edca) ||
+	    ((!rtlpriv->dm.is_any_nonbepkts) &&
+	     (!rtlpriv->dm.disable_framebursting))) {
 
-	if ((!mac->ht_enable) && (!rtlpcipriv->bt_coexist.bt_coexistence)) {
-		if (!(edca_be_ul & 0xffff0000))
-			edca_be_ul |= 0x005e0000;
-
-		if (!(edca_be_dl & 0xffff0000))
-			edca_be_dl |= 0x005e0000;
-	}
-
-	if ((change_edca) || ((!rtlpriv->dm.is_any_nonbepkts) &&
-			      (!rtlpriv->dm.disable_framebursting))) {
 		cur_txok_cnt = rtlpriv->stats.txbytesunicast - last_txok_cnt;
 		cur_rxok_cnt = rtlpriv->stats.rxbytesunicast - last_rxok_cnt;
 
@@ -851,7 +894,9 @@ static void rtl88e_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	} else {
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_AC_PARAM,
 						      &tmp);
 			rtlpriv->dm.current_turbo_edca = false;
 		}
@@ -862,29 +907,29 @@ static void rtl88e_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	last_rxok_cnt = rtlpriv->stats.rxbytesunicast;
 }
 
-static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
-							     *hw)
+static void dm_txpower_track_cb_therm(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_dm	*rtldm = rtl_dm(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 thermalvalue = 0, delta, delta_lck, delta_iqk, off;
-	u8 th_avg_cnt = 0;
+	u8 thermalvalue = 0, delta, delta_lck, delta_iqk, offset;
+	u8 thermalvalue_avg_count = 0;
 	u32 thermalvalue_avg = 0;
 	long  ele_d, temp_cck;
-	char ofdm_index[2], cck_index = 0, ofdm_old[2] = {0, 0}, cck_old = 0;
+	char ofdm_index[2], cck_index = 0,
+		ofdm_index_old[2] = {0, 0}, cck_index_old = 0;
 	int i = 0;
-	bool is2t = false;
+	/*bool is2t = false;*/
 
-	u8 ofdm_min_index = 6, rf = (is2t) ? 2 : 1;
-	u8 index_for_channel;
-	enum _dec_inc {dec, power_inc};
+	u8 ofdm_min_index = 6, rf = 1;
+	/*u8 index_for_channel;*/
+	enum _power_dec_inc {power_dec, power_inc};
 
-	/* 0.1 the following TWO tables decide the final index of
-	 * OFDM/CCK swing table
+	/*0.1 the following TWO tables decide the
+	 *final index of OFDM/CCK swing table
 	 */
-	char del_tbl_idx[2][15] = {
+	char delta_swing_table_idx[2][15]  = {
 		{0, 0, 2, 3, 4, 4, 5, 6, 7, 7, 8, 9, 10, 10, 11},
 		{0, 0, -1, -2, -3, -4, -4, -4, -4, -5, -7, -8, -9, -9, -10}
 	};
@@ -896,9 +941,10 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 	/*Initilization (7 steps in total) */
 	rtlpriv->dm.txpower_trackinginit = true;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "rtl88e_dm_txpower_tracking_callback_thermalmeter\n");
+		 "dm_txpower_track_cb_therm\n");
 
-	thermalvalue = (u8) rtl_get_rfreg(hw, RF90_PATH_A, RF_T_METER, 0xfc00);
+	thermalvalue = (u8)rtl_get_rfreg(hw, RF90_PATH_A, RF_T_METER,
+					 0xfc00);
 	if (!thermalvalue)
 		return;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
@@ -907,55 +953,44 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 		 rtlefuse->eeprom_thermalmeter);
 
 	/*1. Query OFDM Default Setting: Path A*/
-	ele_d = rtl_get_bbreg(hw, ROFDM0_XATXIQIMBAL, MASKDWORD) & MASKOFDM_D;
+	ele_d = rtl_get_bbreg(hw, ROFDM0_XATXIQIMBALANCE, MASKDWORD) &
+			      MASKOFDM_D;
 	for (i = 0; i < OFDM_TABLE_LENGTH; i++) {
 		if (ele_d == (ofdmswing_table[i] & MASKOFDM_D)) {
-			ofdm_old[0] = (u8) i;
-			rtldm->swing_idx_ofdm_base[0] = (u8)i;
+			ofdm_index_old[0] = (u8)i;
+			rtldm->swing_idx_ofdm_base[RF90_PATH_A] = (u8)i;
 			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
 				 "Initial pathA ele_d reg0x%x = 0x%lx, ofdm_index = 0x%x\n",
-				 ROFDM0_XATXIQIMBAL,
-				 ele_d, ofdm_old[0]);
+				 ROFDM0_XATXIQIMBALANCE,
+				 ele_d, ofdm_index_old[0]);
 			break;
 		}
 	}
 
-	if (is2t) {
-		ele_d = rtl_get_bbreg(hw, ROFDM0_XBTXIQIMBAL,
-				      MASKDWORD) & MASKOFDM_D;
-		for (i = 0; i < OFDM_TABLE_LENGTH; i++) {
-			if (ele_d == (ofdmswing_table[i] & MASKOFDM_D)) {
-				ofdm_old[1] = (u8)i;
-
-				RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
-					 DBG_LOUD,
-					 "Initial pathB ele_d reg0x%x = 0x%lx, ofdm_index = 0x%x\n",
-					 ROFDM0_XBTXIQIMBAL, ele_d,
-					 ofdm_old[1]);
-				break;
-			}
-		}
-	}
 	/*2.Query CCK default setting From 0xa24*/
 	temp_cck = rtl_get_bbreg(hw, RCCK0_TXFILTER2, MASKDWORD) & MASKCCK;
 	for (i = 0; i < CCK_TABLE_LENGTH; i++) {
 		if (rtlpriv->dm.cck_inch14) {
 			if (memcmp(&temp_cck, &cck_tbl_ch14[i][2], 4) == 0) {
-				cck_old = (u8)i;
+				cck_index_old = (u8)i;
 				rtldm->swing_idx_cck_base = (u8)i;
-				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
+					 DBG_LOUD,
 					 "Initial reg0x%x = 0x%lx, cck_index = 0x%x, ch 14 %d\n",
-					 RCCK0_TXFILTER2, temp_cck, cck_old,
+					 RCCK0_TXFILTER2, temp_cck,
+					 cck_index_old,
 					 rtlpriv->dm.cck_inch14);
 				break;
 			}
 		} else {
 			if (memcmp(&temp_cck, &cck_tbl_ch1_13[i][2], 4) == 0) {
-				cck_old = (u8)i;
+				cck_index_old = (u8)i;
 				rtldm->swing_idx_cck_base = (u8)i;
-				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
+					 DBG_LOUD,
 					 "Initial reg0x%x = 0x%lx, cck_index = 0x%x, ch14 %d\n",
-					 RCCK0_TXFILTER2, temp_cck, cck_old,
+					 RCCK0_TXFILTER2, temp_cck,
+					 cck_index_old,
 					 rtlpriv->dm.cck_inch14);
 				break;
 			}
@@ -968,8 +1003,8 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 		rtlpriv->dm.thermalvalue_lck = thermalvalue;
 		rtlpriv->dm.thermalvalue_iqk = thermalvalue;
 		for (i = 0; i < rf; i++)
-			rtlpriv->dm.ofdm_index[i] = ofdm_old[i];
-		rtlpriv->dm.cck_index = cck_old;
+			rtlpriv->dm.ofdm_index[i] = ofdm_index_old[i];
+		rtlpriv->dm.cck_index = cck_index_old;
 	}
 
 	/*4 Calculate average thermal meter*/
@@ -981,12 +1016,12 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 	for (i = 0; i < AVG_THERMAL_NUM_88E; i++) {
 		if (rtldm->thermalvalue_avg[i]) {
 			thermalvalue_avg += rtldm->thermalvalue_avg[i];
-			th_avg_cnt++;
+			thermalvalue_avg_count++;
 		}
 	}
 
-	if (th_avg_cnt)
-		thermalvalue = (u8)(thermalvalue_avg / th_avg_cnt);
+	if (thermalvalue_avg_count)
+		thermalvalue = (u8)(thermalvalue_avg / thermalvalue_avg_count);
 
 	/* 5 Calculate delta, delta_LCK, delta_IQK.*/
 	if (rtlhal->reloadtxpowerindex) {
@@ -997,24 +1032,22 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 		rtlpriv->dm.done_txpower = false;
 	} else if (rtlpriv->dm.done_txpower) {
 		delta = (thermalvalue > rtlpriv->dm.thermalvalue) ?
-			(thermalvalue - rtlpriv->dm.thermalvalue) :
-			(rtlpriv->dm.thermalvalue - thermalvalue);
+		    (thermalvalue - rtlpriv->dm.thermalvalue) :
+		    (rtlpriv->dm.thermalvalue - thermalvalue);
 	} else {
 		delta = (thermalvalue > rtlefuse->eeprom_thermalmeter) ?
-			(thermalvalue - rtlefuse->eeprom_thermalmeter) :
-			(rtlefuse->eeprom_thermalmeter - thermalvalue);
+		    (thermalvalue - rtlefuse->eeprom_thermalmeter) :
+		    (rtlefuse->eeprom_thermalmeter - thermalvalue);
 	}
 	delta_lck = (thermalvalue > rtlpriv->dm.thermalvalue_lck) ?
-		    (thermalvalue - rtlpriv->dm.thermalvalue_lck) :
-		    (rtlpriv->dm.thermalvalue_lck - thermalvalue);
+	    (thermalvalue - rtlpriv->dm.thermalvalue_lck) :
+	    (rtlpriv->dm.thermalvalue_lck - thermalvalue);
 	delta_iqk = (thermalvalue > rtlpriv->dm.thermalvalue_iqk) ?
-		    (thermalvalue - rtlpriv->dm.thermalvalue_iqk) :
-		    (rtlpriv->dm.thermalvalue_iqk - thermalvalue);
+	    (thermalvalue - rtlpriv->dm.thermalvalue_iqk) :
+	    (rtlpriv->dm.thermalvalue_iqk - thermalvalue);
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-		 "eeprom_thermalmeter 0x%x delta 0x%x "
-		 "delta_lck 0x%x delta_iqk 0x%x\n",
+		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x delta 0x%x delta_lck 0x%x delta_iqk 0x%x\n",
 		 thermalvalue, rtlpriv->dm.thermalvalue,
 		 rtlefuse->eeprom_thermalmeter, delta, delta_lck,
 		 delta_iqk);
@@ -1024,28 +1057,35 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 		rtl88e_phy_lc_calibrate(hw);
 	}
 
-	/* 7 If necessary, move the index of swing table to adjust Tx power. */
+	/* 7 If necessary, move the index of
+	 * swing table to adjust Tx power.
+	 */
 	if (delta > 0 && rtlpriv->dm.txpower_track_control) {
 		delta = (thermalvalue > rtlefuse->eeprom_thermalmeter) ?
-			(thermalvalue - rtlefuse->eeprom_thermalmeter) :
-			(rtlefuse->eeprom_thermalmeter - thermalvalue);
+		    (thermalvalue - rtlefuse->eeprom_thermalmeter) :
+		    (rtlefuse->eeprom_thermalmeter - thermalvalue);
 
 		/* 7.1 Get the final CCK_index and OFDM_index for each
 		 * swing table.
 		 */
 		if (thermalvalue > rtlefuse->eeprom_thermalmeter) {
-			CAL_SWING_OFF(off, power_inc, IDX_MAP, delta);
+			CAL_SWING_OFF(offset, power_inc, INDEX_MAPPING_NUM,
+				      delta);
 			for (i = 0; i < rf; i++)
-				ofdm_index[i] = rtldm->ofdm_index[i] +
-						del_tbl_idx[power_inc][off];
+				ofdm_index[i] =
+				  rtldm->ofdm_index[i] +
+				  delta_swing_table_idx[power_inc][offset];
 			cck_index = rtldm->cck_index +
-				    del_tbl_idx[power_inc][off];
+				delta_swing_table_idx[power_inc][offset];
 		} else {
-			CAL_SWING_OFF(off, dec, IDX_MAP, delta);
+			CAL_SWING_OFF(offset, power_dec, INDEX_MAPPING_NUM,
+				      delta);
 			for (i = 0; i < rf; i++)
-				ofdm_index[i] = rtldm->ofdm_index[i] +
-						del_tbl_idx[dec][off];
-			cck_index = rtldm->cck_index + del_tbl_idx[dec][off];
+				ofdm_index[i] =
+				  rtldm->ofdm_index[i] +
+				  delta_swing_table_idx[power_dec][offset];
+			cck_index = rtldm->cck_index +
+				delta_swing_table_idx[power_dec][offset];
 		}
 
 		/* 7.2 Handle boundary conditions of index.*/
@@ -1056,8 +1096,8 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 				ofdm_index[i] = ofdm_min_index;
 		}
 
-		if (cck_index > CCK_TABLE_SIZE - 1)
-			cck_index = CCK_TABLE_SIZE - 1;
+		if (cck_index > CCK_TABLE_SIZE-1)
+			cck_index = CCK_TABLE_SIZE-1;
 		else if (cck_index < 0)
 			cck_index = 0;
 
@@ -1065,10 +1105,7 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 		if (rtlpriv->dm.txpower_track_control) {
 			rtldm->done_txpower = true;
 			rtldm->swing_idx_ofdm[RF90_PATH_A] =
-				 (u8)ofdm_index[RF90_PATH_A];
-			if (is2t)
-				rtldm->swing_idx_ofdm[RF90_PATH_B] =
-					 (u8)ofdm_index[RF90_PATH_B];
+				(u8)ofdm_index[RF90_PATH_A];
 			rtldm->swing_idx_cck = cck_index;
 			if (rtldm->swing_idx_ofdm_cur !=
 			    rtldm->swing_idx_ofdm[0]) {
@@ -1082,12 +1119,7 @@ static void rtl88e_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 				rtldm->swing_flag_cck = true;
 			}
 
-			rtl88e_chk_tx_track(hw, TXAGC, 0, 0);
-
-			if (is2t)
-				rtl88e_chk_tx_track(hw, BBSWING,
-						    RF90_PATH_B,
-						    index_for_channel);
+			dm_tx_pwr_track_set_pwr(hw, TXAGC, 0, 0);
 		}
 	}
 
@@ -1115,7 +1147,7 @@ static void rtl88e_dm_init_txpower_tracking(struct ieee80211_hw *hw)
 	rtlpriv->dm.swing_idx_ofdm_cur = 12;
 	rtlpriv->dm.swing_flag_ofdm = false;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 "  rtlpriv->dm.txpower_tracking = %d\n",
+		 "rtlpriv->dm.txpower_tracking = %d\n",
 		 rtlpriv->dm.txpower_tracking);
 }
 
@@ -1137,7 +1169,7 @@ void rtl88e_dm_check_txpower_tracking(struct ieee80211_hw *hw)
 	} else {
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
 			 "Schedule TxPowerTracking !!\n");
-		rtl88e_dm_txpower_tracking_callback_thermalmeter(hw);
+				dm_txpower_track_cb_therm(hw);
 		tm_trigger = 0;
 	}
 }
@@ -1145,7 +1177,7 @@ void rtl88e_dm_check_txpower_tracking(struct ieee80211_hw *hw)
 void rtl88e_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+	struct rate_adaptive *p_ra = &rtlpriv->ra;
 
 	p_ra->ratr_state = DM_RATR_STA_INIT;
 	p_ra->pre_ratr_state = DM_RATR_STA_INIT;
@@ -1161,9 +1193,9 @@ static void rtl88e_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+	struct rate_adaptive *p_ra = &rtlpriv->ra;
+	u32 low_rssithresh_for_ra, high_rssithresh_for_ra;
 	struct ieee80211_sta *sta = NULL;
-	u32 low_rssi, hi_rssi;
 
 	if (is_hal_stop(rtlhal)) {
 		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
@@ -1181,26 +1213,28 @@ static void rtl88e_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	    mac->opmode == NL80211_IFTYPE_STATION) {
 		switch (p_ra->pre_ratr_state) {
 		case DM_RATR_STA_HIGH:
-			hi_rssi = 50;
-			low_rssi = 20;
+			high_rssithresh_for_ra = 50;
+			low_rssithresh_for_ra = 20;
 			break;
 		case DM_RATR_STA_MIDDLE:
-			hi_rssi = 55;
-			low_rssi = 20;
+			high_rssithresh_for_ra = 55;
+			low_rssithresh_for_ra = 20;
 			break;
 		case DM_RATR_STA_LOW:
-			hi_rssi = 50;
-			low_rssi = 25;
+			high_rssithresh_for_ra = 50;
+			low_rssithresh_for_ra = 25;
 			break;
 		default:
-			hi_rssi = 50;
-			low_rssi = 20;
+			high_rssithresh_for_ra = 50;
+			low_rssithresh_for_ra = 20;
 			break;
 		}
 
-		if (rtlpriv->dm.undec_sm_pwdb > (long)hi_rssi)
+		if (rtlpriv->dm.undec_sm_pwdb >
+		    (long)high_rssithresh_for_ra)
 			p_ra->ratr_state = DM_RATR_STA_HIGH;
-		else if (rtlpriv->dm.undec_sm_pwdb > (long)low_rssi)
+		else if (rtlpriv->dm.undec_sm_pwdb >
+			 (long)low_rssithresh_for_ra)
 			p_ra->ratr_state = DM_RATR_STA_MIDDLE;
 		else
 			p_ra->ratr_state = DM_RATR_STA_LOW;
@@ -1208,7 +1242,7 @@ static void rtl88e_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
 				 "RSSI = %ld\n",
-				 rtlpriv->dm.undec_sm_pwdb);
+				  rtlpriv->dm.undec_sm_pwdb);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
 				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
@@ -1219,7 +1253,7 @@ static void rtl88e_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 			sta = rtl_find_sta(hw, mac->bssid);
 			if (sta)
 				rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
-						   p_ra->ratr_state);
+								   p_ra->ratr_state);
 			rcu_read_unlock();
 
 			p_ra->pre_ratr_state = p_ra->ratr_state;
@@ -1239,56 +1273,62 @@ static void rtl92c_dm_init_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 	dm_pstable->rssi_val_min = 0;
 }
 
-static void rtl88e_dm_update_rx_idle_ant(struct ieee80211_hw *hw, u8 ant)
+static void rtl88e_dm_update_rx_idle_ant(struct ieee80211_hw *hw,
+					 u8 ant)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
-	u32 def_ant, opt_ant;
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
+	u32 default_ant, optional_ant;
 
-	if (fat_tbl->rx_idle_ant != ant) {
+	if (pfat_table->rx_idle_ant != ant) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "need to update rx idle ant\n");
 		if (ant == MAIN_ANT) {
-			def_ant = (fat_tbl->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
-				   MAIN_ANT_CG_TRX : MAIN_ANT_CGCS_RX;
-			opt_ant = (fat_tbl->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
-				   AUX_ANT_CG_TRX : AUX_ANT_CGCS_RX;
+			default_ant =
+			  (pfat_table->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
+			  MAIN_ANT_CG_TRX : MAIN_ANT_CGCS_RX;
+			optional_ant =
+			  (pfat_table->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
+			  AUX_ANT_CG_TRX : AUX_ANT_CGCS_RX;
 		} else {
-			def_ant = (fat_tbl->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
-				   AUX_ANT_CG_TRX : AUX_ANT_CGCS_RX;
-			opt_ant = (fat_tbl->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
-				   MAIN_ANT_CG_TRX : MAIN_ANT_CGCS_RX;
+			default_ant =
+			   (pfat_table->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
+			   AUX_ANT_CG_TRX : AUX_ANT_CGCS_RX;
+			optional_ant =
+			   (pfat_table->rx_idle_ant == CG_TRX_HW_ANTDIV) ?
+			   MAIN_ANT_CG_TRX : MAIN_ANT_CGCS_RX;
 		}
 
 		if (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) {
-			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(5) |
-				      BIT(4) | BIT(3), def_ant);
-			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(8) |
-				      BIT(7) | BIT(6), opt_ant);
-			rtl_set_bbreg(hw, DM_REG_ANTSEL_CTRL_11N, BIT(14) |
-				      BIT(13) | BIT(12), def_ant);
-			rtl_set_bbreg(hw, DM_REG_RESP_TX_11N, BIT(6) | BIT(7),
-				      def_ant);
+			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+				      BIT(5) | BIT(4) | BIT(3), default_ant);
+			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+				      BIT(8) | BIT(7) | BIT(6), optional_ant);
+			rtl_set_bbreg(hw, DM_REG_ANTSEL_CTRL_11N,
+				      BIT(14) | BIT(13) | BIT(12),
+				      default_ant);
+			rtl_set_bbreg(hw, DM_REG_RESP_TX_11N,
+				      BIT(6) | BIT(7), default_ant);
 		} else if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV) {
-			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(5) |
-				      BIT(4) | BIT(3), def_ant);
-			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(8) |
-				      BIT(7) | BIT(6), opt_ant);
+			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+				      BIT(5) | BIT(4) | BIT(3), default_ant);
+			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+				      BIT(8) | BIT(7) | BIT(6), optional_ant);
 		}
 	}
-	fat_tbl->rx_idle_ant = ant;
+	pfat_table->rx_idle_ant = ant;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "RxIdleAnt %s\n",
-		 ((ant == MAIN_ANT) ? ("MAIN_ANT") : ("AUX_ANT")));
+		 (ant == MAIN_ANT) ? ("MAIN_ANT") : ("AUX_ANT"));
 }
 
 static void rtl88e_dm_update_tx_ant(struct ieee80211_hw *hw,
-	u8 ant, u32 mac_id)
+				    u8 ant, u32 mac_id)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 	u8 target_ant;
 
 	if (ant == MAIN_ANT)
@@ -1296,23 +1336,25 @@ static void rtl88e_dm_update_tx_ant(struct ieee80211_hw *hw,
 	else
 		target_ant = AUX_ANT_CG_TRX;
 
-	fat_tbl->antsel_a[mac_id] = target_ant & BIT(0);
-	fat_tbl->antsel_b[mac_id] = (target_ant & BIT(1)) >> 1;
-	fat_tbl->antsel_c[mac_id] = (target_ant & BIT(2)) >> 2;
+	pfat_table->antsel_a[mac_id] = target_ant & BIT(0);
+	pfat_table->antsel_b[mac_id] = (target_ant & BIT(1)) >> 1;
+	pfat_table->antsel_c[mac_id] = (target_ant & BIT(2)) >> 2;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "txfrominfo target ant %s\n",
-		 ((ant == MAIN_ANT) ? ("MAIN_ANT") : ("AUX_ANT")));
+		(ant == MAIN_ANT) ? ("MAIN_ANT") : ("AUX_ANT"));
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "antsel_tr_mux = 3'b%d%d%d\n",
-		 fat_tbl->antsel_c[mac_id],
-		 fat_tbl->antsel_b[mac_id], fat_tbl->antsel_a[mac_id]);
+		pfat_table->antsel_c[mac_id],
+		pfat_table->antsel_b[mac_id],
+		pfat_table->antsel_a[mac_id]);
 }
 
 static void rtl88e_dm_rx_hw_antena_div_init(struct ieee80211_hw *hw)
 {
 	u32  value32;
+
 	/*MAC Setting*/
 	value32 = rtl_get_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD);
-	rtl_set_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD, value32 |
-		     (BIT(23) | BIT(25)));
+	rtl_set_bbreg(hw, DM_REG_ANTSEL_PIN_11N,
+		      MASKDWORD, value32 | (BIT(23) | BIT(25)));
 	/*Pin Setting*/
 	rtl_set_bbreg(hw, DM_REG_PIN_CTRL_11N, BIT(9) | BIT(8), 0);
 	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(10), 0);
@@ -1333,8 +1375,8 @@ static void rtl88e_dm_trx_hw_antenna_div_init(struct ieee80211_hw *hw)
 
 	/*MAC Setting*/
 	value32 = rtl_get_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD);
-	rtl_set_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD, value32 |
-		     (BIT(23) | BIT(25)));
+	rtl_set_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD,
+		      value32 | (BIT(23) | BIT(25)));
 	/*Pin Setting*/
 	rtl_set_bbreg(hw, DM_REG_PIN_CTRL_11N, BIT(9) | BIT(8), 0);
 	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(10), 0);
@@ -1354,28 +1396,30 @@ static void rtl88e_dm_trx_hw_antenna_div_init(struct ieee80211_hw *hw)
 static void rtl88e_dm_fast_training_init(struct ieee80211_hw *hw)
 {
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
-	u32 ant_combo = 2;
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
+	u32 ant_combination = 2;
 	u32 value32, i;
 
 	for (i = 0; i < 6; i++) {
-		fat_tbl->bssid[i] = 0;
-		fat_tbl->ant_sum[i] = 0;
-		fat_tbl->ant_cnt[i] = 0;
-		fat_tbl->ant_ave[i] = 0;
+		pfat_table->bssid[i] = 0;
+		pfat_table->ant_sum[i] = 0;
+		pfat_table->ant_cnt[i] = 0;
+		pfat_table->ant_ave[i] = 0;
 	}
-	fat_tbl->train_idx = 0;
-	fat_tbl->fat_state = FAT_NORMAL_STATE;
+	pfat_table->train_idx = 0;
+	pfat_table->fat_state = FAT_NORMAL_STATE;
 
 	/*MAC Setting*/
 	value32 = rtl_get_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD);
-	rtl_set_bbreg(hw, DM_REG_ANTSEL_PIN_11N, MASKDWORD, value32 | (BIT(23) |
-		      BIT(25)));
-	value32 = rtl_get_bbreg(hw, DM_REG_ANT_TRAIN_2, MASKDWORD);
-	rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_2, MASKDWORD, value32 | (BIT(16) |
-		      BIT(17)));
-	rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_2, MASKLWORD, 0);
-	rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_1, MASKDWORD, 0);
+	rtl_set_bbreg(hw, DM_REG_ANTSEL_PIN_11N,
+		      MASKDWORD, value32 | (BIT(23) | BIT(25)));
+	value32 = rtl_get_bbreg(hw, DM_REG_ANT_TRAIN_PARA2_11N, MASKDWORD);
+	rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_PARA2_11N,
+		      MASKDWORD, value32 | (BIT(16) | BIT(17)));
+	rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_PARA2_11N,
+		      MASKLWORD, 0);
+	rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_PARA1_11N,
+		      MASKDWORD, 0);
 
 	/*Pin Setting*/
 	rtl_set_bbreg(hw, DM_REG_PIN_CTRL_11N, BIT(9) | BIT(8), 0);
@@ -1386,26 +1430,17 @@ static void rtl88e_dm_fast_training_init(struct ieee80211_hw *hw)
 	/*OFDM Setting*/
 	rtl_set_bbreg(hw, DM_REG_ANTDIV_PARA1_11N, MASKDWORD, 0x000000a0);
 	/*antenna mapping table*/
-	if (ant_combo == 2) {
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE0, 1);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE1, 2);
-	} else if (ant_combo == 7) {
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE0, 1);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE1, 2);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE2, 2);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE3, 3);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING2_11N, MASKBYTE0, 4);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING2_11N, MASKBYTE1, 5);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING2_11N, MASKBYTE2, 6);
-		rtl_set_bbreg(hw, DM_REG_ANT_MAPPING2_11N, MASKBYTE3, 7);
-	}
+	rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE0, 1);
+	rtl_set_bbreg(hw, DM_REG_ANT_MAPPING1_11N, MASKBYTE1, 2);
 
 	/*TX Setting*/
 	rtl_set_bbreg(hw, DM_REG_TX_ANT_CTRL_11N, BIT(21), 1);
-	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(5) | BIT(4) | BIT(3), 0);
-	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(8) | BIT(7) | BIT(6), 1);
-	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(2) | BIT(1) | BIT(0),
-		      (ant_combo - 1));
+	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+		      BIT(5) | BIT(4) | BIT(3), 0);
+	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+		      BIT(8) | BIT(7) | BIT(6), 1);
+	rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N,
+		      BIT(2) | BIT(1) | BIT(0), (ant_combination - 1));
 
 	rtl_set_bbreg(hw, DM_REG_IGI_A_11N, BIT(7), 1);
 }
@@ -1420,6 +1455,7 @@ static void rtl88e_dm_antenna_div_init(struct ieee80211_hw *hw)
 		rtl88e_dm_trx_hw_antenna_div_init(hw);
 	else if (rtlefuse->antenna_div_type == CG_TRX_SMART_ANTDIV)
 		rtl88e_dm_fast_training_init(hw);
+
 }
 
 void rtl88e_dm_set_tx_ant_by_tx_info(struct ieee80211_hw *hw,
@@ -1427,38 +1463,39 @@ void rtl88e_dm_set_tx_ant_by_tx_info(struct ieee80211_hw *hw,
 {
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 
 	if ((rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) ||
-	    (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV)) {
-		SET_TX_DESC_ANTSEL_A(pdesc, fat_tbl->antsel_a[mac_id]);
-		SET_TX_DESC_ANTSEL_B(pdesc, fat_tbl->antsel_b[mac_id]);
-		SET_TX_DESC_ANTSEL_C(pdesc, fat_tbl->antsel_c[mac_id]);
+	    (rtlefuse->antenna_div_type == CG_TRX_SMART_ANTDIV)) {
+		SET_TX_DESC_ANTSEL_A(pdesc, pfat_table->antsel_a[mac_id]);
+		SET_TX_DESC_ANTSEL_B(pdesc, pfat_table->antsel_b[mac_id]);
+		SET_TX_DESC_ANTSEL_C(pdesc, pfat_table->antsel_c[mac_id]);
 	}
 }
 
 void rtl88e_dm_ant_sel_statistics(struct ieee80211_hw *hw,
-				  u8 antsel_tr_mux, u32 mac_id, u32 rx_pwdb_all)
+				  u8 antsel_tr_mux, u32 mac_id,
+				  u32 rx_pwdb_all)
 {
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 
 	if (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) {
 		if (antsel_tr_mux == MAIN_ANT_CG_TRX) {
-			fat_tbl->main_ant_sum[mac_id] += rx_pwdb_all;
-			fat_tbl->main_ant_cnt[mac_id]++;
+			pfat_table->main_ant_sum[mac_id] += rx_pwdb_all;
+			pfat_table->main_ant_cnt[mac_id]++;
 		} else {
-			fat_tbl->aux_ant_sum[mac_id] += rx_pwdb_all;
-			fat_tbl->aux_ant_cnt[mac_id]++;
+			pfat_table->aux_ant_sum[mac_id] += rx_pwdb_all;
+			pfat_table->aux_ant_cnt[mac_id]++;
 		}
 	} else if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV) {
 		if (antsel_tr_mux == MAIN_ANT_CGCS_RX) {
-			fat_tbl->main_ant_sum[mac_id] += rx_pwdb_all;
-			fat_tbl->main_ant_cnt[mac_id]++;
+			pfat_table->main_ant_sum[mac_id] += rx_pwdb_all;
+			pfat_table->main_ant_cnt[mac_id]++;
 		} else {
-			fat_tbl->aux_ant_sum[mac_id] += rx_pwdb_all;
-			fat_tbl->aux_ant_cnt[mac_id]++;
+			pfat_table->aux_ant_sum[mac_id] += rx_pwdb_all;
+			pfat_table->aux_ant_cnt[mac_id]++;
 		}
 	}
 }
@@ -1466,43 +1503,43 @@ void rtl88e_dm_ant_sel_statistics(struct ieee80211_hw *hw,
 static void rtl88e_dm_hw_ant_div(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
 	struct rtl_sta_info *drv_priv;
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
-	u32 i, min_rssi = 0xff, ant_div_max_rssi = 0, max_rssi = 0;
-	u32 local_min_rssi, local_max_rssi;
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
+	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
+	u32 i, min_rssi = 0xff, ant_div_max_rssi = 0;
+	u32 max_rssi = 0, local_min_rssi, local_max_rssi;
 	u32 main_rssi, aux_rssi;
 	u8 rx_idle_ant = 0, target_ant = 7;
 
+	/*for sta its self*/
 	i = 0;
-	main_rssi = (fat_tbl->main_ant_cnt[i] != 0) ?
-		    (fat_tbl->main_ant_sum[i] /
-		     fat_tbl->main_ant_cnt[i]) : 0;
-	aux_rssi = (fat_tbl->aux_ant_cnt[i] != 0) ?
-		(fat_tbl->aux_ant_sum[i] / fat_tbl->aux_ant_cnt[i]) : 0;
+	main_rssi = (pfat_table->main_ant_cnt[i] != 0) ?
+		(pfat_table->main_ant_sum[i] / pfat_table->main_ant_cnt[i]) : 0;
+	aux_rssi = (pfat_table->aux_ant_cnt[i] != 0) ?
+		(pfat_table->aux_ant_sum[i] / pfat_table->aux_ant_cnt[i]) : 0;
 	target_ant = (main_rssi == aux_rssi) ?
-		     fat_tbl->rx_idle_ant : ((main_rssi >= aux_rssi) ?
-		     MAIN_ANT : AUX_ANT);
+		pfat_table->rx_idle_ant : ((main_rssi >= aux_rssi) ?
+		MAIN_ANT : AUX_ANT);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "main_ant_sum %d main_ant_cnt %d\n",
-		 fat_tbl->main_ant_sum[i], fat_tbl->main_ant_cnt[i]);
+		"main_ant_sum %d main_ant_cnt %d\n",
+		pfat_table->main_ant_sum[i],
+		pfat_table->main_ant_cnt[i]);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "aux_ant_sum %d aux_ant_cnt %d\n",
-		 fat_tbl->aux_ant_sum[i],
-		 fat_tbl->aux_ant_cnt[i]);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "main_rssi %d aux_rssi%d\n", main_rssi, aux_rssi);
+		 pfat_table->aux_ant_sum[i], pfat_table->aux_ant_cnt[i]);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "main_rssi %d aux_rssi%d\n",
+		 main_rssi, aux_rssi);
 	local_max_rssi = (main_rssi > aux_rssi) ? main_rssi : aux_rssi;
 	if ((local_max_rssi > ant_div_max_rssi) && (local_max_rssi < 40))
 		ant_div_max_rssi = local_max_rssi;
 	if (local_max_rssi > max_rssi)
 		max_rssi = local_max_rssi;
 
-	if ((fat_tbl->rx_idle_ant == MAIN_ANT) && (main_rssi == 0))
+	if ((pfat_table->rx_idle_ant == MAIN_ANT) && (main_rssi == 0))
 		main_rssi = aux_rssi;
-	else if ((fat_tbl->rx_idle_ant == AUX_ANT) && (aux_rssi == 0))
+	else if ((pfat_table->rx_idle_ant == AUX_ANT) && (aux_rssi == 0))
 		aux_rssi = main_rssi;
 
 	local_min_rssi = (main_rssi > aux_rssi) ? aux_rssi : main_rssi;
@@ -1518,32 +1555,33 @@ static void rtl88e_dm_hw_ant_div(struct ieee80211_hw *hw)
 		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
 		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
 			i++;
-			main_rssi = (fat_tbl->main_ant_cnt[i] != 0) ?
-				(fat_tbl->main_ant_sum[i] /
-				 fat_tbl->main_ant_cnt[i]) : 0;
-			aux_rssi = (fat_tbl->aux_ant_cnt[i] != 0) ?
-				   (fat_tbl->aux_ant_sum[i] /
-				    fat_tbl->aux_ant_cnt[i]) : 0;
+			main_rssi = (pfat_table->main_ant_cnt[i] != 0) ?
+				(pfat_table->main_ant_sum[i] /
+				pfat_table->main_ant_cnt[i]) : 0;
+			aux_rssi = (pfat_table->aux_ant_cnt[i] != 0) ?
+				(pfat_table->aux_ant_sum[i] /
+				pfat_table->aux_ant_cnt[i]) : 0;
 			target_ant = (main_rssi == aux_rssi) ?
-				      fat_tbl->rx_idle_ant : ((main_rssi >=
-				      aux_rssi) ? MAIN_ANT : AUX_ANT);
-
+				pfat_table->rx_idle_ant : ((main_rssi >=
+				aux_rssi) ? MAIN_ANT : AUX_ANT);
 
-			local_max_rssi = max_t(u32, main_rssi, aux_rssi);
+			local_max_rssi = (main_rssi > aux_rssi) ?
+					 main_rssi : aux_rssi;
 			if ((local_max_rssi > ant_div_max_rssi) &&
 			    (local_max_rssi < 40))
 				ant_div_max_rssi = local_max_rssi;
 			if (local_max_rssi > max_rssi)
 				max_rssi = local_max_rssi;
 
-			if ((fat_tbl->rx_idle_ant == MAIN_ANT) && !main_rssi)
+			if ((pfat_table->rx_idle_ant == MAIN_ANT) &&
+			    (main_rssi == 0))
 				main_rssi = aux_rssi;
-			else if ((fat_tbl->rx_idle_ant == AUX_ANT) &&
+			else if ((pfat_table->rx_idle_ant == AUX_ANT) &&
 				 (aux_rssi == 0))
 				aux_rssi = main_rssi;
 
 			local_min_rssi = (main_rssi > aux_rssi) ?
-					  aux_rssi : main_rssi;
+				aux_rssi : main_rssi;
 			if (local_min_rssi < min_rssi) {
 				min_rssi = local_min_rssi;
 				rx_idle_ant = target_ant;
@@ -1555,10 +1593,10 @@ static void rtl88e_dm_hw_ant_div(struct ieee80211_hw *hw)
 	}
 
 	for (i = 0; i < ASSOCIATE_ENTRY_NUM; i++) {
-		fat_tbl->main_ant_sum[i] = 0;
-		fat_tbl->aux_ant_sum[i] = 0;
-		fat_tbl->main_ant_cnt[i] = 0;
-		fat_tbl->aux_ant_cnt[i] = 0;
+		pfat_table->main_ant_sum[i] = 0;
+		pfat_table->aux_ant_sum[i] = 0;
+		pfat_table->main_ant_cnt[i] = 0;
+		pfat_table->aux_ant_cnt[i] = 0;
 	}
 
 	rtl88e_dm_update_rx_idle_ant(hw, rx_idle_ant);
@@ -1573,27 +1611,27 @@ static void rtl88e_set_next_mac_address_target(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
 	struct rtl_sta_info *drv_priv;
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 	u32 value32, i, j = 0;
 
 	if (mac->link_state >= MAC80211_LINKED) {
 		for (i = 0; i < ASSOCIATE_ENTRY_NUM; i++) {
-			if ((fat_tbl->train_idx + 1) == ASSOCIATE_ENTRY_NUM)
-				fat_tbl->train_idx = 0;
+			if ((pfat_table->train_idx + 1) == ASSOCIATE_ENTRY_NUM)
+				pfat_table->train_idx = 0;
 			else
-				fat_tbl->train_idx++;
+				pfat_table->train_idx++;
 
-			if (fat_tbl->train_idx == 0) {
+			if (pfat_table->train_idx == 0) {
 				value32 = (mac->mac_addr[5] << 8) |
-					   mac->mac_addr[4];
-				rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_2,
+					  mac->mac_addr[4];
+				rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_PARA2_11N,
 					      MASKLWORD, value32);
 
 				value32 = (mac->mac_addr[3] << 24) |
 					  (mac->mac_addr[2] << 16) |
 					  (mac->mac_addr[1] << 8) |
-					   mac->mac_addr[0];
-				rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_1,
+					  mac->mac_addr[0];
+				rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_PARA1_11N,
 					      MASKDWORD, value32);
 				break;
 			}
@@ -1602,28 +1640,29 @@ static void rtl88e_set_next_mac_address_target(struct ieee80211_hw *hw)
 			    NL80211_IFTYPE_STATION) {
 				spin_lock_bh(&rtlpriv->locks.entry_list_lock);
 				list_for_each_entry(drv_priv,
-						    &rtlpriv->entry_list,
-						    list) {
+						    &rtlpriv->entry_list, list) {
 					j++;
-					if (j != fat_tbl->train_idx)
+					if (j != pfat_table->train_idx)
 						continue;
 
 					value32 = (drv_priv->mac_addr[5] << 8) |
-						   drv_priv->mac_addr[4];
-					rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_2,
+						  drv_priv->mac_addr[4];
+					rtl_set_bbreg(hw,
+						      DM_REG_ANT_TRAIN_PARA2_11N,
 						      MASKLWORD, value32);
 
-					value32 = (drv_priv->mac_addr[3]<<24) |
-						  (drv_priv->mac_addr[2]<<16) |
-						  (drv_priv->mac_addr[1]<<8) |
-						   drv_priv->mac_addr[0];
-					rtl_set_bbreg(hw, DM_REG_ANT_TRAIN_1,
+					value32 = (drv_priv->mac_addr[3] << 24) |
+						  (drv_priv->mac_addr[2] << 16) |
+						  (drv_priv->mac_addr[1] << 8) |
+						  drv_priv->mac_addr[0];
+					rtl_set_bbreg(hw,
+						      DM_REG_ANT_TRAIN_PARA1_11N,
 						      MASKDWORD, value32);
 					break;
 				}
 				spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
 				/*find entry, break*/
-				if (j == fat_tbl->train_idx)
+				if (j == pfat_table->train_idx)
 					break;
 			}
 		}
@@ -1634,23 +1673,24 @@ static void rtl88e_dm_fast_ant_training(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 	u32 i, max_rssi = 0;
 	u8 target_ant = 2;
 	bool bpkt_filter_match = false;
 
-	if (fat_tbl->fat_state == FAT_TRAINING_STATE) {
+	if (pfat_table->fat_state == FAT_TRAINING_STATE) {
 		for (i = 0; i < 7; i++) {
-			if (fat_tbl->ant_cnt[i] == 0) {
-				fat_tbl->ant_ave[i] = 0;
+			if (pfat_table->ant_cnt[i] == 0) {
+				pfat_table->ant_ave[i] = 0;
 			} else {
-				fat_tbl->ant_ave[i] = fat_tbl->ant_sum[i] /
-					fat_tbl->ant_cnt[i];
+				pfat_table->ant_ave[i] =
+					pfat_table->ant_sum[i] /
+					pfat_table->ant_cnt[i];
 				bpkt_filter_match = true;
 			}
 
-			if (fat_tbl->ant_ave[i] > max_rssi) {
-				max_rssi = fat_tbl->ant_ave[i];
+			if (pfat_table->ant_ave[i] > max_rssi) {
+				max_rssi = pfat_table->ant_ave[i];
 				target_ant = (u8) i;
 			}
 		}
@@ -1664,32 +1704,33 @@ static void rtl88e_dm_fast_ant_training(struct ieee80211_hw *hw)
 				      BIT(16), 0);
 			rtl_set_bbreg(hw, DM_REG_RX_ANT_CTRL_11N, BIT(8) |
 				      BIT(7) | BIT(6), target_ant);
-			rtl_set_bbreg(hw, DM_REG_TX_ANT_CTRL_11N, BIT(21), 1);
+			rtl_set_bbreg(hw, DM_REG_TX_ANT_CTRL_11N,
+				      BIT(21), 1);
 
-			fat_tbl->antsel_a[fat_tbl->train_idx] =
-				  target_ant & BIT(0);
-			fat_tbl->antsel_b[fat_tbl->train_idx] =
-				 (target_ant & BIT(1)) >> 1;
-			fat_tbl->antsel_c[fat_tbl->train_idx] =
-				 (target_ant & BIT(2)) >> 2;
+			pfat_table->antsel_a[pfat_table->train_idx] =
+				target_ant & BIT(0);
+			pfat_table->antsel_b[pfat_table->train_idx] =
+				(target_ant & BIT(1)) >> 1;
+			pfat_table->antsel_c[pfat_table->train_idx] =
+				(target_ant & BIT(2)) >> 2;
 
 			if (target_ant == 0)
 				rtl_set_bbreg(hw, DM_REG_IGI_A_11N, BIT(7), 0);
 		}
 
 		for (i = 0; i < 7; i++) {
-			fat_tbl->ant_sum[i] = 0;
-			fat_tbl->ant_cnt[i] = 0;
+			pfat_table->ant_sum[i] = 0;
+			pfat_table->ant_cnt[i] = 0;
 		}
 
-		fat_tbl->fat_state = FAT_NORMAL_STATE;
+		pfat_table->fat_state = FAT_NORMAL_STATE;
 		return;
 	}
 
-	if (fat_tbl->fat_state == FAT_NORMAL_STATE) {
+	if (pfat_table->fat_state == FAT_NORMAL_STATE) {
 		rtl88e_set_next_mac_address_target(hw);
 
-		fat_tbl->fat_state = FAT_TRAINING_STATE;
+		pfat_table->fat_state = FAT_TRAINING_STATE;
 		rtl_set_bbreg(hw, DM_REG_TXAGC_A_1_MCS32_11N, BIT(16), 1);
 		rtl_set_bbreg(hw, DM_REG_IGI_A_11N, BIT(7), 1);
 
@@ -1711,11 +1752,11 @@ static void rtl88e_dm_antenna_diversity(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
-	struct fast_ant_training *fat_tbl = &(rtldm->fat_table);
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 
 	if (mac->link_state < MAC80211_LINKED) {
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "No Link\n");
-		if (fat_tbl->becomelinked == true) {
+		if (pfat_table->becomelinked) {
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 				 "need to turn off HW AntDiv\n");
 			rtl_set_bbreg(hw, DM_REG_IGI_A_11N, BIT(7), 0);
@@ -1724,12 +1765,13 @@ static void rtl88e_dm_antenna_diversity(struct ieee80211_hw *hw)
 			if (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV)
 				rtl_set_bbreg(hw, DM_REG_TX_ANT_CTRL_11N,
 					      BIT(21), 0);
-			fat_tbl->becomelinked =
-			  (mac->link_state == MAC80211_LINKED) ? true : false;
+			pfat_table->becomelinked =
+				(mac->link_state == MAC80211_LINKED) ?
+				true : false;
 		}
 		return;
 	} else {
-		if (fat_tbl->becomelinked == false) {
+		if (!pfat_table->becomelinked) {
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 				 "Need to turn on HW AntDiv\n");
 			rtl_set_bbreg(hw, DM_REG_IGI_A_11N, BIT(7), 1);
@@ -1738,8 +1780,9 @@ static void rtl88e_dm_antenna_diversity(struct ieee80211_hw *hw)
 			if (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV)
 				rtl_set_bbreg(hw, DM_REG_TX_ANT_CTRL_11N,
 					      BIT(21), 1);
-			fat_tbl->becomelinked =
-			   (mac->link_state >= MAC80211_LINKED) ? true : false;
+			pfat_table->becomelinked =
+				(mac->link_state >= MAC80211_LINKED) ?
+				true : false;
 		}
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
index 0e07f72..64f1f3ea 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
@@ -156,7 +156,6 @@
 #define	DM_REG_SLEEP_11N				0xEE0
 #define	DM_REG_PMPD_ANAEN_11N				0xEEC
 
-
 /*MAC REG LIST*/
 #define	DM_REG_BB_RST_11N				0x02
 #define	DM_REG_ANTSEL_PIN_11N				0x4C
@@ -168,8 +167,9 @@
 #define	DM_REG_EDCA_BK_11N				0x50C
 #define	DM_REG_TXPAUSE_11N				0x522
 #define	DM_REG_RESP_TX_11N				0x6D8
-#define	DM_REG_ANT_TRAIN_1				0x7b0
-#define	DM_REG_ANT_TRAIN_2				0x7b4
+#define	DM_REG_ANT_TRAIN_PARA1_11N			0x7b0
+#define	DM_REG_ANT_TRAIN_PARA2_11N			0x7b4
+
 
 /*DIG Related*/
 #define	DM_BIT_IGI_11N					0x0000007F
@@ -208,7 +208,7 @@
 #define DM_DIG_BACKOFF_MIN				-4
 #define DM_DIG_BACKOFF_DEFAULT				10
 
-#define RXPATHSELECTION_SS_TH_LOW			30
+#define RXPATHSELECTION_SS_TH_W				30
 #define RXPATHSELECTION_DIFF_TH				18
 
 #define DM_RATR_STA_INIT				0
@@ -232,20 +232,22 @@
 
 #define TX_POWER_NEAR_FIELD_THRESH_LVL2			74
 #define TX_POWER_NEAR_FIELD_THRESH_LVL1			67
-#define TXPWRTRACK_MAX_IDX				6
+#define TXPWRTRACK_MAX_IDX				 6
 
 struct swat_t {
 	u8 failure_cnt;
 	u8 try_flag;
 	u8 stop_trying;
+
 	long pre_rssi;
 	long trying_threshold;
 	u8 cur_antenna;
 	u8 pre_antenna;
+
 };
 
 enum FAT_STATE {
-	FAT_NORMAL_STATE	= 0,
+	FAT_NORMAL_STATE = 0,
 	FAT_TRAINING_STATE = 1,
 };
 
@@ -310,8 +312,9 @@ enum pwr_track_control_method {
 
 void rtl88e_dm_set_tx_ant_by_tx_info(struct ieee80211_hw *hw,
 				     u8 *pdesc, u32 mac_id);
-void rtl88e_dm_ant_sel_statistics(struct ieee80211_hw *hw, u8 antsel_tr_mux,
-				  u32 mac_id, u32 rx_pwdb_all);
+void rtl88e_dm_ant_sel_statistics(struct ieee80211_hw *hw,
+				  u8 antsel_tr_mux, u32 mac_id,
+				  u32 rx_pwdb_all);
 void rtl88e_dm_fast_antenna_training_callback(unsigned long data);
 void rtl88e_dm_init(struct ieee80211_hw *hw);
 void rtl88e_dm_watchdog(struct ieee80211_hw *hw);
@@ -320,7 +323,5 @@ void rtl88e_dm_init_edca_turbo(struct ieee80211_hw *hw);
 void rtl88e_dm_check_txpower_tracking(struct ieee80211_hw *hw);
 void rtl88e_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
 void rtl88e_dm_txpower_track_adjust(struct ieee80211_hw *hw,
-				    u8 type, u8 *pdirection,
-				    u32 *poutwrite_val);
-
+	u8 type, u8 *pdirection, u32 *poutwrite_val);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
index 4f9376a..eda6617 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
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
@@ -34,8 +30,6 @@
 #include "def.h"
 #include "fw.h"
 
-#include <linux/kmemleak.h>
-
 static void _rtl88e_enable_fw_download(struct ieee80211_hw *hw, bool enable)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -62,26 +56,26 @@ static void _rtl88e_fw_block_write(struct ieee80211_hw *hw,
 				   const u8 *buffer, u32 size)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 blk_sz = sizeof(u32);
-	u8 *buf_ptr = (u8 *)buffer;
+	u32 blocksize = sizeof(u32);
+	u8 *bufferptr = (u8 *)buffer;
 	u32 *pu4BytePtr = (u32 *)buffer;
-	u32 i, offset, blk_cnt, remain;
+	u32 i, offset, blockcount, remainsize;
 
-	blk_cnt = size / blk_sz;
-	remain = size % blk_sz;
+	blockcount = size / blocksize;
+	remainsize = size % blocksize;
 
-	for (i = 0; i < blk_cnt; i++) {
-		offset = i * blk_sz;
+	for (i = 0; i < blockcount; i++) {
+		offset = i * blocksize;
 		rtl_write_dword(rtlpriv, (FW_8192C_START_ADDRESS + offset),
 				*(pu4BytePtr + i));
 	}
 
-	if (remain) {
-		offset = blk_cnt * blk_sz;
-		buf_ptr += offset;
-		for (i = 0; i < remain; i++) {
+	if (remainsize) {
+		offset = blockcount * blocksize;
+		bufferptr += offset;
+		for (i = 0; i < remainsize; i++) {
 			rtl_write_byte(rtlpriv, (FW_8192C_START_ADDRESS +
-						 offset + i), *(buf_ptr + i));
+						 offset + i), *(bufferptr + i));
 		}
 	}
 }
@@ -119,32 +113,33 @@ static void _rtl88e_write_fw(struct ieee80211_hw *hw,
 			     enum version_8188e version, u8 *buffer, u32 size)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 *buf_ptr = buffer;
-	u32 page_no, remain;
+	u8 *bufferptr = (u8 *)buffer;
+	u32 pagenums, remainsize;
 	u32 page, offset;
 
 	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "FW size is %d bytes,\n", size);
 
-	_rtl88e_fill_dummy(buf_ptr, &size);
+	_rtl88e_fill_dummy(bufferptr, &size);
 
-	page_no = size / FW_8192C_PAGE_SIZE;
-	remain = size % FW_8192C_PAGE_SIZE;
+	pagenums = size / FW_8192C_PAGE_SIZE;
+	remainsize = size % FW_8192C_PAGE_SIZE;
 
-	if (page_no > 8) {
+	if (pagenums > 8) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Page numbers should not greater then 8\n");
 	}
 
-	for (page = 0; page < page_no; page++) {
+	for (page = 0; page < pagenums; page++) {
 		offset = page * FW_8192C_PAGE_SIZE;
-		_rtl88e_fw_page_write(hw, page, (buf_ptr + offset),
+		_rtl88e_fw_page_write(hw, page, (bufferptr + offset),
 				      FW_8192C_PAGE_SIZE);
 	}
 
-	if (remain) {
-		offset = page_no * FW_8192C_PAGE_SIZE;
-		page = page_no;
-		_rtl88e_fw_page_write(hw, page, (buf_ptr + offset), remain);
+	if (remainsize) {
+		offset = pagenums * FW_8192C_PAGE_SIZE;
+		page = pagenums;
+		_rtl88e_fw_page_write(hw, page, (bufferptr + offset),
+				      remainsize);
 	}
 }
 
@@ -199,7 +194,8 @@ exit:
 	return err;
 }
 
-int rtl88e_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_wlan_fw)
+int rtl88e_download_fw(struct ieee80211_hw *hw,
+		       bool buse_wake_on_wlan_fw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
@@ -221,8 +217,8 @@ int rtl88e_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_wlan_fw)
 	if (IS_FW_HEADER_EXIST(pfwheader)) {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
 			 "Firmware Version(%d), Signature(%#x), Size(%d)\n",
-			 pfwheader->version, pfwheader->signature,
-			 (int)sizeof(struct rtl92c_firmware_header));
+			  pfwheader->version, pfwheader->signature,
+			  (int)sizeof(struct rtl92c_firmware_header));
 
 		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
 		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
@@ -237,9 +233,14 @@ int rtl88e_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_wlan_fw)
 	_rtl88e_enable_fw_download(hw, false);
 
 	err = _rtl88e_fw_free_to_go(hw);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Firmware is not ready to run!\n");
+	} else {
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+			 "Firmware is ready to run!\n");
+	}
 
-	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-		 "Firmware is%s ready to run!\n", err ? " not" : "");
 	return 0;
 }
 
@@ -266,9 +267,9 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 	bool isfw_read = false;
 	u8 buf_index = 0;
 	bool write_sucess = false;
-	u8 wait_h2c_limit = 100;
+	u8 wait_h2c_limmit = 100;
 	u8 wait_writeh2c_limit = 100;
-	u8 boxc[4], boxext[2];
+	u8 boxcontent[4], boxextcontent[4];
 	u32 h2c_waitcounter = 0;
 	unsigned long flag;
 	u8 idx;
@@ -331,18 +332,17 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 			box_extreg = REG_HMEBOX_EXT_3;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
-
 		isfw_read = _rtl88e_check_fw_read_last_h2c(hw, boxnum);
 		while (!isfw_read) {
-			wait_h2c_limit--;
-			if (wait_h2c_limit == 0) {
+			wait_h2c_limmit--;
+			if (wait_h2c_limmit == 0) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 "Waiting too long for FW read "
-					 "clear HMEBox(%d)!\n", boxnum);
+					 "Waiting too long for FW read clear HMEBox(%d)!\n",
+					 boxnum);
 				break;
 			}
 
@@ -351,20 +351,20 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 			isfw_read = _rtl88e_check_fw_read_last_h2c(hw, boxnum);
 			u1b_tmp = rtl_read_byte(rtlpriv, 0x130);
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Waiting for FW read clear HMEBox(%d)!!! "
-				 "0x130 = %2x\n", boxnum, u1b_tmp);
+				 "Waiting for FW read clear HMEBox(%d)!!! 0x130 = %2x\n",
+				 boxnum, u1b_tmp);
 		}
 
 		if (!isfw_read) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Write H2C register BOX[%d] fail!!!!! "
-				 "Fw do not read.\n", boxnum);
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read.\n",
+				 boxnum);
 			break;
 		}
 
-		memset(boxc, 0, sizeof(boxc));
-		memset(boxext, 0, sizeof(boxext));
-		boxc[0] = element_id;
+		memset(boxcontent, 0, sizeof(boxcontent));
+		memset(boxextcontent, 0, sizeof(boxextcontent));
+		boxcontent[0] = element_id;
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "Write element_id box_reg(%4x) = %2x\n",
 			 box_reg, element_id);
@@ -373,33 +373,38 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 		case 1:
 		case 2:
 		case 3:
-			/*boxc[0] &= ~(BIT(7));*/
-			memcpy((u8 *)(boxc) + 1, cmd_b + buf_index, cmd_len);
+			/*boxcontent[0] &= ~(BIT(7));*/
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmd_b + buf_index, cmd_len);
 
-			for (idx = 0; idx < 4; idx++)
-				rtl_write_byte(rtlpriv, box_reg+idx, boxc[idx]);
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
 			break;
 		case 4:
 		case 5:
 		case 6:
 		case 7:
-			/*boxc[0] |= (BIT(7));*/
-			memcpy((u8 *)(boxext), cmd_b + buf_index+3, cmd_len-3);
-			memcpy((u8 *)(boxc) + 1, cmd_b + buf_index, 3);
+			/*boxcontent[0] |= (BIT(7));*/
+			memcpy((u8 *)(boxextcontent),
+			       cmd_b + buf_index+3, cmd_len-3);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmd_b + buf_index, 3);
 
 			for (idx = 0; idx < 2; idx++) {
 				rtl_write_byte(rtlpriv, box_extreg + idx,
-					       boxext[idx]);
+					       boxextcontent[idx]);
 			}
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
-					       boxc[idx]);
+					       boxcontent[idx]);
 			}
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
 
@@ -411,7 +416,7 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "pHalData->last_hmeboxnum  = %d\n",
-			 rtlhal->last_hmeboxnum);
+			  rtlhal->last_hmeboxnum);
 	}
 
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
@@ -422,18 +427,19 @@ static void _rtl88e_fill_h2c_command(struct ieee80211_hw *hw,
 }
 
 void rtl88e_fill_h2c_cmd(struct ieee80211_hw *hw,
-			 u8 element_id, u32 cmd_len, u8 *cmd_b)
+			 u8 element_id, u32 cmd_len, u8 *cmdbuffer)
 {
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u32 tmp_cmdbuf[2];
 
-	if (rtlhal->fw_ready == false) {
-		RT_ASSERT(false, "fail H2C cmd - Fw download fail!!!\n");
+	if (!rtlhal->fw_ready) {
+		RT_ASSERT(false,
+			  "return H2C cmd because of Fw download fail!!!\n");
 		return;
 	}
 
 	memset(tmp_cmdbuf, 0, 8);
-	memcpy(tmp_cmdbuf, cmd_b, cmd_len);
+	memcpy(tmp_cmdbuf, cmdbuffer, cmd_len);
 	_rtl88e_fill_h2c_command(hw, element_id, cmd_len, (u8 *)&tmp_cmdbuf);
 
 	return;
@@ -448,7 +454,8 @@ void rtl88e_firmware_selfreset(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1b_tmp & (~BIT(2))));
 	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1b_tmp | BIT(2)));
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "8051Reset88E(): 8051 reset success.\n");
+		 "8051Reset88E(): 8051 reset success\n");
+
 }
 
 void rtl88e_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
@@ -456,28 +463,29 @@ void rtl88e_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 u1_h2c_set_pwrmode[H2C_88E_PWEMODE_LENGTH] = { 0 };
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	u8 power_state = 0;
-
+	u8 rlbm, power_state = 0;
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
+
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, ((mode) ? 1 : 0));
-	SET_H2CCMD_PWRMODE_PARM_RLBM(u1_h2c_set_pwrmode, 0);
+	rlbm = 0;/*YJ, temp, 120316. FW now not support RLBM=2.*/
+	SET_H2CCMD_PWRMODE_PARM_RLBM(u1_h2c_set_pwrmode, rlbm);
 	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
-					 (rtlpriv->mac80211.p2p) ?
-					 ppsc->smart_ps : 1);
+		(rtlpriv->mac80211.p2p) ? ppsc->smart_ps : 1);
 	SET_H2CCMD_PWRMODE_PARM_AWAKE_INTERVAL(u1_h2c_set_pwrmode,
-					       ppsc->reg_max_lps_awakeintvl);
+		ppsc->reg_max_lps_awakeintvl);
 	SET_H2CCMD_PWRMODE_PARM_ALL_QUEUE_UAPSD(u1_h2c_set_pwrmode, 0);
 	if (mode == FW_PS_ACTIVE_MODE)
 		power_state |= FW_PWR_STATE_ACTIVE;
 	else
 		power_state |= FW_PWR_STATE_RF_OFF;
+
 	SET_H2CCMD_PWRMODE_PARM_PWR_STATE(u1_h2c_set_pwrmode, power_state);
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
 		      "rtl92c_set_fw_pwrmode(): u1_h2c_set_pwrmode\n",
 		      u1_h2c_set_pwrmode, H2C_88E_PWEMODE_LENGTH);
-	rtl88e_fill_h2c_cmd(hw, H2C_88E_SETPWRMODE, H2C_88E_PWEMODE_LENGTH,
-			    u1_h2c_set_pwrmode);
+	rtl88e_fill_h2c_cmd(hw, H2C_88E_SETPWRMODE,
+			    H2C_88E_PWEMODE_LENGTH, u1_h2c_set_pwrmode);
 }
 
 void rtl88e_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
@@ -499,8 +507,9 @@ void rtl88e_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
 	SET_H2CCMD_AP_OFFLOAD_HIDDEN(u1_apoffload_parm, mac->hiddenssid);
 	SET_H2CCMD_AP_OFFLOAD_DENYANY(u1_apoffload_parm, 0);
 
-	rtl88e_fill_h2c_cmd(hw, H2C_88E_AP_OFFLOAD, H2C_88E_AP_OFFLOAD_LENGTH,
-			    u1_apoffload_parm);
+	rtl88e_fill_h2c_cmd(hw, H2C_88E_AP_OFFLOAD,
+			    H2C_88E_AP_OFFLOAD_LENGTH, u1_apoffload_parm);
+
 }
 
 static bool _rtl88e_cmd_send_packet(struct ieee80211_hw *hw,
@@ -511,6 +520,7 @@ static bool _rtl88e_cmd_send_packet(struct ieee80211_hw *hw,
 	struct rtl8192_tx_ring *ring;
 	struct rtl_tx_desc *pdesc;
 	struct sk_buff *pskb = NULL;
+	u8 own;
 	unsigned long flags;
 
 	ring = &rtlpci->tx_ring[BEACON_QUEUE];
@@ -522,6 +532,7 @@ static bool _rtl88e_cmd_send_packet(struct ieee80211_hw *hw,
 	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
 
 	pdesc = &ring->desc[0];
+	own = (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OWN);
 
 	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
 
@@ -656,14 +667,15 @@ void rtl88e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct sk_buff *skb = NULL;
-
 	u32 totalpacketlen;
-	u8 u1RsvdPageLoc[5] = { 0 };
-
+	bool rtstatus;
+	u8 u1rsvdpageloc[5] = { 0 };
+	bool b_dlok = false;
 	u8 *beacon;
-	u8 *pspoll;
+	u8 *p_pspoll;
 	u8 *nullfunc;
-	u8 *probersp;
+	u8 *p_probersp;
+
 	/*---------------------------------------------------------
 	 *			(1) beacon
 	 *---------------------------------------------------------
@@ -676,12 +688,12 @@ void rtl88e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	 *			(2) ps-poll
 	 *--------------------------------------------------------
 	 */
-	pspoll = &reserved_page_packet[PSPOLL_PG * 128];
-	SET_80211_PS_POLL_AID(pspoll, (mac->assoc_id | 0xc000));
-	SET_80211_PS_POLL_BSSID(pspoll, mac->bssid);
-	SET_80211_PS_POLL_TA(pspoll, mac->mac_addr);
+	p_pspoll = &reserved_page_packet[PSPOLL_PG * 128];
+	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
+	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
+	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
 
-	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1RsvdPageLoc, PSPOLL_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1rsvdpageloc, PSPOLL_PG);
 
 	/*--------------------------------------------------------
 	 *			(3) null data
@@ -692,18 +704,18 @@ void rtl88e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
 	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
 
-	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1RsvdPageLoc, NULL_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1rsvdpageloc, NULL_PG);
 
 	/*---------------------------------------------------------
 	 *			(4) probe response
 	 *----------------------------------------------------------
 	 */
-	probersp = &reserved_page_packet[PROBERSP_PG * 128];
-	SET_80211_HDR_ADDRESS1(probersp, mac->bssid);
-	SET_80211_HDR_ADDRESS2(probersp, mac->mac_addr);
-	SET_80211_HDR_ADDRESS3(probersp, mac->bssid);
+	p_probersp = &reserved_page_packet[PROBERSP_PG * 128];
+	SET_80211_HDR_ADDRESS1(p_probersp, mac->bssid);
+	SET_80211_HDR_ADDRESS2(p_probersp, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(p_probersp, mac->bssid);
 
-	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1RsvdPageLoc, PROBERSP_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1rsvdpageloc, PROBERSP_PG);
 
 	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
 
@@ -712,33 +724,36 @@ void rtl88e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 		      &reserved_page_packet[0], totalpacketlen);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
 		      "rtl88e_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
-		      u1RsvdPageLoc, 3);
+		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	if (!skb)
-		return;
-	kmemleak_not_leak(skb);
 	memcpy(skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	if (_rtl88e_cmd_send_packet(hw, skb)) {
+	rtstatus = _rtl88e_cmd_send_packet(hw, skb);
+
+	if (rtstatus)
+		b_dlok = true;
+
+	if (b_dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "Set RSVD page location to Fw.\n");
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-			      "H2C_RSVDPAGE:\n", u1RsvdPageLoc, 3);
+			      "H2C_RSVDPAGE:\n", u1rsvdpageloc, 3);
 		rtl88e_fill_h2c_cmd(hw, H2C_88E_RSVDPAGE,
-				    sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
+				    sizeof(u1rsvdpageloc), u1rsvdpageloc);
 	} else
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
 }
 
-/*Shoud check FW support p2p or not.*/
+/*Should check FW support p2p or not.*/
 static void rtl88e_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, u8 ctwindow)
 {
-	u8 u1_ctwindow_period[1] = {ctwindow};
+	u8 u1_ctwindow_period[1] = { ctwindow};
 
 	rtl88e_fill_h2c_cmd(hw, H2C_88E_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
+
 }
 
 void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
@@ -755,7 +770,7 @@ void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
-		memset(p2p_ps_offload, 0, sizeof(struct p2p_ps_offload_t));
+		memset(p2p_ps_offload, 0, 1);
 		break;
 	case P2P_PS_ENABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
@@ -765,8 +780,9 @@ void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 			ctwindow = p2pinfo->ctwindow;
 			rtl88e_set_p2p_ctw_period_cmd(hw, ctwindow);
 		}
+
 		/* hw only support 2 set of NoA */
-		for (i = 0; i < p2pinfo->noa_num; i++) {
+		for (i = 0 ; i < p2pinfo->noa_num; i++) {
 			/* To control the register setting for which NOA*/
 			rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
 			if (i == 0)
@@ -785,7 +801,7 @@ void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 
 			start_time = p2pinfo->noa_start_time[i];
 			if (p2pinfo->noa_count_type[i] != 1) {
-				while (start_time <= (tsf_low + (50 * 1024))) {
+				while (start_time <= (tsf_low+(50*1024))) {
 					start_time += p2pinfo->noa_interval[i];
 					if (p2pinfo->noa_count_type[i] != 255)
 						p2pinfo->noa_count_type[i]--;
@@ -804,7 +820,7 @@ void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 
 			if (P2P_ROLE_GO == rtlpriv->mac80211.p2p) {
 				p2p_ps_offload->role = 1;
-				p2p_ps_offload->allstasleep = 0;
+				p2p_ps_offload->allstasleep = -1;
 			} else {
 				p2p_ps_offload->role = 0;
 			}
@@ -827,4 +843,5 @@ void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 
 	rtl88e_fill_h2c_cmd(hw, H2C_88E_P2P_PS_OFFLOAD, 1,
 			    (u8 *)p2p_ps_offload);
+
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.h b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.h
index 854a987..05e944e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/fw.h
@@ -55,10 +55,11 @@
 #define H2C_88E_AOAC_RSVDPAGE_LOC_LEN		7
 
 /* Fw PS state for RPWM.
- * BIT[2:0] = HW state
- * BIT[3] = Protocol PS state, 1: register active state, 0: register sleep state
- * BIT[4] = sub-state
- */
+*BIT[2:0] = HW state
+*BIT[3] = Protocol PS state,
+*1: register active state , 0: register sleep state
+*BIT[4] = sub-state
+*/
 #define	FW_PS_GO_ON			BIT(0)
 #define	FW_PS_TX_NULL			BIT(1)
 #define	FW_PS_RF_ON			BIT(2)
@@ -98,10 +99,13 @@
 #define	FW_PS_STATE_S2			(FW_PS_RF_OFF)
 #define	FW_PS_STATE_S3			(FW_PS_ALL_ON)
 #define	FW_PS_STATE_S4			((FW_PS_ST_ACTIVE) | (FW_PS_ALL_ON))
-
+/* ((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))*/
 #define	FW_PS_STATE_ALL_ON_88E		(FW_PS_CLOCK_ON)
+/* (FW_PS_RF_ON)*/
 #define	FW_PS_STATE_RF_ON_88E		(FW_PS_CLOCK_ON)
-#define	FW_PS_STATE_RF_OFF_88E		(FW_PS_CLOCK_ON)
+/* 0x0*/
+#define	FW_PS_STATE_RF_OFF_88E	(FW_PS_CLOCK_ON)
+/* (FW_PS_STATE_RF_OFF)*/
 #define	FW_PS_STATE_RF_OFF_LOW_PWR_88E	(FW_PS_CLOCK_OFF)
 
 #define	FW_PS_STATE_ALL_ON_92C		(FW_PS_STATE_S4)
@@ -146,7 +150,7 @@ struct rtl92c_firmware_header {
 	u32 rsvd5;
 };
 
-enum rtl8192c_h2c_cmd {
+enum rtl8188e_h2c_cmd {
 	H2C_88E_RSVDPAGE = 0,
 	H2C_88E_JOINBSSRPT = 1,
 	H2C_88E_SCAN = 2,
@@ -175,7 +179,7 @@ enum rtl8192c_h2c_cmd {
 	H2C_88E_AOAC_GLOBAL_INFO = 0x82,
 	H2C_88E_AOAC_RSVDPAGE = 0x83,
 #endif
-	/* Not defined in new 88E H2C CMD Format */
+	/*Not defined in new 88E H2C CMD Format*/
 	H2C_88E_RA_MASK,
 	H2C_88E_SELECTIVE_SUSPEND_ROF_CMD,
 	H2C_88E_P2P_PS_MODE,
@@ -289,13 +293,12 @@ enum rtl8192c_h2c_cmd {
 int rtl88e_download_fw(struct ieee80211_hw *hw,
 		       bool buse_wake_on_wlan_fw);
 void rtl88e_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
-			 u32 cmd_len, u8 *p_cmdbuffer);
+			 u32 cmd_len, u8 *cmdbuffer);
 void rtl88e_firmware_selfreset(struct ieee80211_hw *hw);
 void rtl88e_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
-void rtl88e_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw,
-				      u8 mstatus);
-void rtl88e_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,  u8 enable);
+void rtl88e_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
+void rtl88e_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
+				   u8 ap_offload_enable);
 void rtl88e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
 void rtl88e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
-
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index ba639bb..f74b7fb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
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
@@ -41,7 +37,6 @@
 #include "fw.h"
 #include "led.h"
 #include "hw.h"
-#include "pwrseqcmd.h"
 #include "pwrseq.h"
 
 #define LLT_CONFIG		5
@@ -114,16 +109,16 @@ static void _rtl88ee_disable_bcn_sub_func(struct ieee80211_hw *hw)
 }
 
 static void _rtl88ee_set_fw_clock_on(struct ieee80211_hw *hw,
-				     u8 rpwm_val, bool need_turn_off_ckk)
+				     u8 rpwm_val, bool b_need_turn_off_ckk)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	bool support_remote_wake_up;
+	bool b_support_remote_wake_up;
 	u32 count = 0, isr_regaddr, content;
-	bool schedule_timer = need_turn_off_ckk;
-
+	bool schedule_timer = b_need_turn_off_ckk;
 	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
-				      (u8 *)(&support_remote_wake_up));
+					(u8 *)(&b_support_remote_wake_up));
+
 	if (!rtlhal->fw_ready)
 		return;
 	if (!rtlpriv->psc.fw_current_inpsmode)
@@ -134,8 +129,9 @@ static void _rtl88ee_set_fw_clock_on(struct ieee80211_hw *hw,
 		if (rtlhal->fw_clk_change_in_progress) {
 			while (rtlhal->fw_clk_change_in_progress) {
 				spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+				count++;
 				udelay(100);
-				if (++count > 1000)
+				if (count > 1000)
 					return;
 				spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 			}
@@ -174,6 +170,7 @@ static void _rtl88ee_set_fw_clock_on(struct ieee80211_hw *hw,
 			mod_timer(&rtlpriv->works.fw_clockoff_timer,
 				  jiffies + MSECS(10));
 		}
+
 	} else  {
 		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
 		rtlhal->fw_clk_change_in_progress = false;
@@ -248,11 +245,9 @@ static void _rtl88ee_set_fw_ps_rf_on(struct ieee80211_hw *hw)
 static void _rtl88ee_set_fw_ps_rf_off_low_power(struct ieee80211_hw *hw)
 {
 	u8 rpwm_val = 0;
-
 	rpwm_val |= FW_PS_STATE_RF_OFF_LOW_PWR_88E;
 	_rtl88ee_set_fw_clock_off(hw, rpwm_val);
 }
-
 void rtl88ee_fw_clk_off_timer_callback(unsigned long data)
 {
 	struct ieee80211_hw *hw = (struct ieee80211_hw *)data;
@@ -326,23 +321,23 @@ void rtl88ee_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		*((enum rf_pwrstate *)(val)) = ppsc->rfpwr_state;
 		break;
 	case HW_VAR_FWLPS_RF_ON:{
-			enum rf_pwrstate rfstate;
-			u32 val_rcr;
-
-			rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RF_STATE,
-						      (u8 *)(&rfstate));
-			if (rfstate == ERFOFF) {
+		enum rf_pwrstate rfstate;
+		u32 val_rcr;
+
+		rtlpriv->cfg->ops->get_hw_reg(hw,
+					      HW_VAR_RF_STATE,
+					      (u8 *)(&rfstate));
+		if (rfstate == ERFOFF) {
+			*((bool *)(val)) = true;
+		} else {
+			val_rcr = rtl_read_dword(rtlpriv, REG_RCR);
+			val_rcr &= 0x00070000;
+			if (val_rcr)
+				*((bool *)(val)) = false;
+			else
 				*((bool *)(val)) = true;
-			} else {
-				val_rcr = rtl_read_dword(rtlpriv, REG_RCR);
-				val_rcr &= 0x00070000;
-				if (val_rcr)
-					*((bool *)(val)) = false;
-				else
-					*((bool *)(val)) = true;
-			}
-			break;
 		}
+		break; }
 	case HW_VAR_FW_PSMODE_STATUS:
 		*((bool *)(val)) = ppsc->fw_current_inpsmode;
 		break;
@@ -374,25 +369,32 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 	switch (variable) {
 	case HW_VAR_ETHER_ADDR:
-		for (idx = 0; idx < ETH_ALEN; idx++)
-			rtl_write_byte(rtlpriv, (REG_MACID + idx), val[idx]);
+		for (idx = 0; idx < ETH_ALEN; idx++) {
+			rtl_write_byte(rtlpriv, (REG_MACID + idx),
+				       val[idx]);
+		}
 		break;
 	case HW_VAR_BASIC_RATE:{
-		u16 rate_cfg = ((u16 *)val)[0];
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
+		rtl_write_byte(rtlpriv, REG_RRSR + 1,
+			       (b_rate_cfg >> 8) & 0xff);
+		while (b_rate_cfg > 0x1) {
+			b_rate_cfg = (b_rate_cfg >> 1);
 			rate_index++;
 		}
-		rtl_write_byte(rtlpriv, REG_INIRTS_RATE_SEL, rate_index);
-		break; }
+		rtl_write_byte(rtlpriv, REG_INIRTS_RATE_SEL,
+			       rate_index);
+		break;
+		}
 	case HW_VAR_BSSID:
-		for (idx = 0; idx < ETH_ALEN; idx++)
-			rtl_write_byte(rtlpriv, (REG_BSSID + idx), val[idx]);
+		for (idx = 0; idx < ETH_ALEN; idx++) {
+			rtl_write_byte(rtlpriv, (REG_BSSID + idx),
+				       val[idx]);
+		}
 		break;
 	case HW_VAR_SIFS:
 		rtl_write_byte(rtlpriv, REG_SIFS_CTX + 1, val[0]);
@@ -402,7 +404,8 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtl_write_byte(rtlpriv, REG_MAC_SPEC_SIFS + 1, val[0]);
 
 		if (!mac->ht_enable)
-			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM, 0x0e0e);
+			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
+				       0x0e0e);
 		else
 			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
 				       *((u16 *)val));
@@ -419,17 +422,20 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
 						      &e_aci);
 		}
-		break; }
+		break;
+		}
 	case HW_VAR_ACK_PREAMBLE:{
 		u8 reg_tmp;
 		u8 short_preamble = (bool)*val;
 		reg_tmp = rtl_read_byte(rtlpriv, REG_TRXPTCL_CTL+2);
 		if (short_preamble) {
 			reg_tmp |= 0x02;
-			rtl_write_byte(rtlpriv, REG_TRXPTCL_CTL + 2, reg_tmp);
+			rtl_write_byte(rtlpriv, REG_TRXPTCL_CTL +
+				       2, reg_tmp);
 		} else {
 			reg_tmp |= 0xFD;
-			rtl_write_byte(rtlpriv, REG_TRXPTCL_CTL + 2, reg_tmp);
+			rtl_write_byte(rtlpriv, REG_TRXPTCL_CTL +
+				       2, reg_tmp);
 		}
 		break; }
 	case HW_VAR_WPA_CONFIG:
@@ -447,7 +453,8 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				min_spacing_to_set = sec_min_space;
 
 			mac->min_space_cfg = ((mac->min_space_cfg &
-					       0xf8) | min_spacing_to_set);
+					       0xf8) |
+					      min_spacing_to_set);
 
 			*val = min_spacing_to_set;
 
@@ -471,35 +478,44 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 			       mac->min_space_cfg);
-		break; }
+		break;
+		}
 	case HW_VAR_AMPDU_FACTOR:{
 		u8 regtoset_normal[4] = { 0x41, 0xa8, 0x72, 0xb9 };
-		u8 factor;
-		u8 *reg = NULL;
-		u8 id = 0;
+		u8 factor_toset;
+		u8 *p_regtoset = NULL;
+		u8 index = 0;
+
+		p_regtoset = regtoset_normal;
+
+		factor_toset = *val;
+		if (factor_toset <= 3) {
+			factor_toset = (1 << (factor_toset + 2));
+			if (factor_toset > 0xf)
+				factor_toset = 0xf;
+
+			for (index = 0; index < 4; index++) {
+				if ((p_regtoset[index] & 0xf0) >
+				    (factor_toset << 4))
+					p_regtoset[index] =
+					    (p_regtoset[index] & 0x0f) |
+					    (factor_toset << 4);
+
+				if ((p_regtoset[index] & 0x0f) >
+				    factor_toset)
+					p_regtoset[index] =
+					    (p_regtoset[index] & 0xf0) |
+					    (factor_toset);
+
+				rtl_write_byte(rtlpriv,
+					       (REG_AGGLEN_LMT + index),
+					       p_regtoset[index]);
 
-		reg = regtoset_normal;
-
-		factor = *val;
-		if (factor <= 3) {
-			factor = (1 << (factor + 2));
-			if (factor > 0xf)
-				factor = 0xf;
-
-			for (id = 0; id < 4; id++) {
-				if ((reg[id] & 0xf0) > (factor << 4))
-					reg[id] = (reg[id] & 0x0f) |
-						  (factor << 4);
-
-				if ((reg[id] & 0x0f) > factor)
-					reg[id] = (reg[id] & 0xf0) | (factor);
-
-				rtl_write_byte(rtlpriv, (REG_AGGLEN_LMT + id),
-					       reg[id]);
 			}
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 "Set HW_VAR_AMPDU_FACTOR: %#x\n", factor);
+				 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
+				  factor_toset);
 		}
 		break; }
 	case HW_VAR_AC_PARAM:{
@@ -507,7 +523,8 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtl88e_dm_init_edca_turbo(hw);
 
 		if (rtlpci->acm_method != EACMWAY2_SW)
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_ACM_CTRL,
 						      &e_aci);
 		break; }
 	case HW_VAR_ACM_CTRL:{
@@ -517,7 +534,8 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		u8 acm = p_aci_aifsn->f.acm;
 		u8 acm_ctrl = rtl_read_byte(rtlpriv, REG_ACMHWCTRL);
 
-		acm_ctrl = acm_ctrl | ((rtlpci->acm_method == 2) ? 0x0 : 0x1);
+		acm_ctrl = acm_ctrl |
+			   ((rtlpci->acm_method == 2) ? 0x0 : 0x1);
 
 		if (acm) {
 			switch (e_aci) {
@@ -610,66 +628,76 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			_rtl88ee_fwlps_enter(hw);
 		 else
 			_rtl88ee_fwlps_leave(hw);
+
 		 break; }
 	case HW_VAR_H2C_FW_JOINBSSRPT:{
 		u8 mstatus = *val;
-		u8 tmp, tmp_reg422, uval;
+		u8 tmp_regcr, tmp_reg422, bcnvalid_reg;
 		u8 count = 0, dlbcn_count = 0;
-		bool recover = false;
+		bool b_recover = false;
 
 		if (mstatus == RT_MEDIA_CONNECT) {
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID, NULL);
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID,
+						      NULL);
 
-			tmp = rtl_read_byte(rtlpriv, REG_CR + 1);
-			rtl_write_byte(rtlpriv, REG_CR + 1, (tmp | BIT(0)));
+			tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
+			rtl_write_byte(rtlpriv, REG_CR + 1,
+				       (tmp_regcr | BIT(0)));
 
 			_rtl88ee_set_bcn_ctrl_reg(hw, 0, BIT(3));
 			_rtl88ee_set_bcn_ctrl_reg(hw, BIT(4), 0);
 
-			tmp_reg422 = rtl_read_byte(rtlpriv,
-						   REG_FWHW_TXQ_CTRL + 2);
+			tmp_reg422 =
+			    rtl_read_byte(rtlpriv,
+					  REG_FWHW_TXQ_CTRL + 2);
 			rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
 				       tmp_reg422 & (~BIT(6)));
 			if (tmp_reg422 & BIT(6))
-				recover = true;
+				b_recover = true;
 
 			do {
-				uval = rtl_read_byte(rtlpriv, REG_TDECTRL+2);
+				bcnvalid_reg = rtl_read_byte(rtlpriv,
+							     REG_TDECTRL+2);
 				rtl_write_byte(rtlpriv, REG_TDECTRL+2,
-					       (uval | BIT(0)));
+					       (bcnvalid_reg | BIT(0)));
 				_rtl88ee_return_beacon_queue_skb(hw);
 
 				rtl88e_set_fw_rsvdpagepkt(hw, 0);
-				uval = rtl_read_byte(rtlpriv, REG_TDECTRL+2);
+				bcnvalid_reg = rtl_read_byte(rtlpriv,
+							     REG_TDECTRL+2);
 				count = 0;
-				while (!(uval & BIT(0)) && count < 20) {
+				while (!(bcnvalid_reg & BIT(0)) && count < 20) {
 					count++;
 					udelay(10);
-					uval = rtl_read_byte(rtlpriv,
-							     REG_TDECTRL+2);
+					bcnvalid_reg =
+					  rtl_read_byte(rtlpriv, REG_TDECTRL+2);
 				}
 				dlbcn_count++;
-			} while (!(uval & BIT(0)) && dlbcn_count < 5);
+			} while (!(bcnvalid_reg & BIT(0)) && dlbcn_count < 5);
 
-			if (uval & BIT(0))
+			if (bcnvalid_reg & BIT(0))
 				rtl_write_byte(rtlpriv, REG_TDECTRL+2, BIT(0));
 
 			_rtl88ee_set_bcn_ctrl_reg(hw, BIT(3), 0);
 			_rtl88ee_set_bcn_ctrl_reg(hw, 0, BIT(4));
 
-			if (recover) {
-				rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
+			if (b_recover) {
+				rtl_write_byte(rtlpriv,
+					       REG_FWHW_TXQ_CTRL + 2,
 					       tmp_reg422);
 			}
-			rtl_write_byte(rtlpriv, REG_CR + 1, (tmp & ~(BIT(0))));
+
+			rtl_write_byte(rtlpriv, REG_CR + 1,
+				       (tmp_regcr & ~(BIT(0))));
 		}
-		rtl88e_set_fw_joinbss_report_cmd(hw, *val);
+		rtl88e_set_fw_joinbss_report_cmd(hw, (*(u8 *)val));
 		break; }
 	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
 		rtl88e_set_p2p_ps_offload_cmd(hw, *val);
 		break;
 	case HW_VAR_AID:{
 		u16 u2btmp;
+
 		u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
 		u2btmp &= 0xC000;
 		rtl_write_word(rtlpriv, REG_BCN_PSR_RPT, (u2btmp |
@@ -678,21 +706,29 @@ void rtl88ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_CORRECT_TSF:{
 		u8 btype_ibss = *val;
 
-		if (btype_ibss == true)
+		if (btype_ibss)
 			_rtl88ee_stop_tx_beacon(hw);
 
 		_rtl88ee_set_bcn_ctrl_reg(hw, 0, BIT(3));
 
 		rtl_write_dword(rtlpriv, REG_TSFTR,
-				(u32) (mac->tsf & 0xffffffff));
+				(u32)(mac->tsf & 0xffffffff));
 		rtl_write_dword(rtlpriv, REG_TSFTR + 4,
-				(u32) ((mac->tsf >> 32) & 0xffffffff));
+				(u32)((mac->tsf >> 32) & 0xffffffff));
 
 		_rtl88ee_set_bcn_ctrl_reg(hw, BIT(3), 0);
 
-		if (btype_ibss == true)
+		if (btype_ibss)
 			_rtl88ee_resume_tx_beacon(hw);
 		break; }
+	case HW_VAR_KEEP_ALIVE: {
+		u8 array[2];
+
+		array[0] = 0xff;
+		array[1] = *((u8 *)val);
+		rtl88e_fill_h2c_cmd(hw, H2C_88E_KEEP_ALIVE_CTRL,
+				    2, array);
+		break; }
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "switch case not process %x\n", variable);
@@ -741,7 +777,7 @@ static bool _rtl88ee_llt_table_init(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_RQPN_NPQ, 0x01);
 	rtl_write_dword(rtlpriv, REG_RQPN, 0x80730d29);
 
-
+	/*0x2600   MaxRxBuff=10k-max(TxReportSize(64*8), WOLPattern(16*24)) */
 	rtl_write_dword(rtlpriv, REG_TRXFF_BNDY, (0x25FF0000 | txpktbuf_bndy));
 	rtl_write_byte(rtlpriv, REG_TDECTRL + 1, txpktbuf_bndy);
 
@@ -798,10 +834,11 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+
 	u8 bytetmp;
 	u16 wordtmp;
 
-	/*Disable XTAL OUTPUT for power saving. YJ, add, 111206. */
+	/*Disable XTAL OUTPUT for power saving. YJ,add,111206. */
 	bytetmp = rtl_read_byte(rtlpriv, REG_XCK_OUT_CTRL) & (~BIT(0));
 	rtl_write_byte(rtlpriv, REG_XCK_OUT_CTRL, bytetmp);
 	/*Auto Power Down to CHIP-off State*/
@@ -810,9 +847,9 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x00);
 	/* HW Power on sequence */
-	if (!rtl88_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
-					PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
-					RTL8188E_NIC_ENABLE_FLOW)) {
+	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
+				      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
+				      RTL8188EE_NIC_ENABLE_FLOW)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "init MAC Fail as rtl_hal_pwrseqcmdparsing\n");
 		return false;
@@ -854,8 +891,6 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 			return false;
 		}
 	}
-
-
 	rtl_write_dword(rtlpriv, REG_HISR, 0xffffffff);
 	rtl_write_dword(rtlpriv, REG_HISRE, 0xffffffff);
 
@@ -890,9 +925,8 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 			DMA_BIT_MASK(32));
 
 	/* if we want to support 64 bit DMA, we should set it here,
-	 * but at the moment we do not support 64 bit DMA
+	 * but now we do not support 64 bit DMA
 	 */
-
 	rtl_write_dword(rtlpriv, REG_INT_MIG, 0);
 
 	rtl_write_dword(rtlpriv, REG_MCUTST_1, 0x0);
@@ -911,8 +945,12 @@ static bool _rtl88ee_init_mac(struct ieee80211_hw *hw)
 static void _rtl88ee_hw_configure(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 reg_prsr;
+	u8 reg_bw_opmode;
+	u32 reg_ratr, reg_prsr;
 
+	reg_bw_opmode = BW_OPMODE_20MHZ;
+	reg_ratr = RATE_ALL_CCK | RATE_ALL_OFDM_AG |
+	    RATE_ALL_OFDM_1SS | RATE_ALL_OFDM_2SS;
 	reg_prsr = RATE_ALL_CCK | RATE_ALL_OFDM_AG;
 
 	rtl_write_dword(rtlpriv, REG_RRSR, reg_prsr);
@@ -924,7 +962,7 @@ static void _rtl88ee_enable_aspm_back_door(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	u8 tmp1byte = 0;
-	u32 tmp4Byte = 0, count;
+	u32 tmp4byte = 0, count = 0;
 
 	rtl_write_word(rtlpriv, 0x354, 0x8104);
 	rtl_write_word(rtlpriv, 0x358, 0x24);
@@ -939,8 +977,8 @@ static void _rtl88ee_enable_aspm_back_door(struct ieee80211_hw *hw)
 		count++;
 	}
 	if (0 == tmp1byte) {
-		tmp4Byte = rtl_read_dword(rtlpriv, 0x34c);
-		rtl_write_dword(rtlpriv, 0x348, tmp4Byte|BIT(31));
+		tmp4byte = rtl_read_dword(rtlpriv, 0x34c);
+		rtl_write_dword(rtlpriv, 0x348, tmp4byte|BIT(31));
 		rtl_write_word(rtlpriv, 0x350, 0xf70c);
 		rtl_write_byte(rtlpriv, 0x352, 0x1);
 	}
@@ -962,12 +1000,14 @@ static void _rtl88ee_enable_aspm_back_door(struct ieee80211_hw *hw)
 		tmp1byte = rtl_read_byte(rtlpriv, 0x352);
 		count++;
 	}
+
 	if (ppsc->support_backdoor || (0 == tmp1byte)) {
-		tmp4Byte = rtl_read_dword(rtlpriv, 0x34c);
-		rtl_write_dword(rtlpriv, 0x348, tmp4Byte|BIT(11)|BIT(12));
+		tmp4byte = rtl_read_dword(rtlpriv, 0x34c);
+		rtl_write_dword(rtlpriv, 0x348, tmp4byte|BIT(11)|BIT(12));
 		rtl_write_word(rtlpriv, 0x350, 0xf718);
 		rtl_write_byte(rtlpriv, 0x352, 0x1);
 	}
+
 	tmp1byte = rtl_read_byte(rtlpriv, 0x352);
 	count = 0;
 	while (tmp1byte && count < 20) {
@@ -984,14 +1024,15 @@ void rtl88ee_enable_hw_security_config(struct ieee80211_hw *hw)
 
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
@@ -1005,6 +1046,7 @@ void rtl88ee_enable_hw_security_config(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 		 "The SECR-value %x\n", sec_reg_value);
+
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 }
 
@@ -1022,7 +1064,6 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 	u8 tmp_u1b, u1byte;
 	unsigned long flags;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Rtl8188EE hw init\n");
 	rtlpriv->rtlhal.being_init_adapter = true;
 	/* As this function can take a very long time (up to 350 ms)
 	 * and can be called with irqs disabled, reenable the irqs
@@ -1033,6 +1074,7 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 	 */
 	local_save_flags(flags);
 	local_irq_enable();
+	rtlhal->fw_ready = false;
 
 	rtlpriv->intf_ops->disable_aspm(hw);
 
@@ -1058,9 +1100,8 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 			 "Failed to download FW. Init HW without FW now..\n");
 		err = 1;
 		goto exit;
-	} else {
-		rtlhal->fw_ready = true;
 	}
+	rtlhal->fw_ready = true;
 	/*fw related variable initialize */
 	rtlhal->last_hmeboxnum = 0;
 	rtlhal->fw_ps_state = FW_PS_STATE_ALL_ON_88E;
@@ -1069,10 +1110,10 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 	ppsc->fw_current_inpsmode = false;
 
 	rtl88e_phy_mac_config(hw);
-	/* because last function modifies RCR, we update
-	 * rcr var here, or TP will be unstable for receive_config
-	 * is wrong, RX RCR_ACRC32 will cause TP unstable & Rx
-	 * RCR_APP_ICV will cause mac80211 disassoc for cisco 1252
+	/* because last function modify RCR, so we update
+	 * rcr var here, or TP will unstable for receive_config
+	 * is wrong, RX RCR_ACRC32 will cause TP unstabel & Rx
+	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252
 	 */
 	rtlpci->receive_config &= ~(RCR_ACRC32 | RCR_AICV);
 	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
@@ -1102,15 +1143,14 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 	if (ppsc->rfpwr_state == ERFON) {
 		if ((rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV) ||
 		    ((rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) &&
-		    (rtlhal->oem_id == RT_CID_819X_HP))) {
+		     (rtlhal->oem_id == RT_CID_819X_HP))) {
 			rtl88e_phy_set_rfpath_switch(hw, true);
 			rtlpriv->dm.fat_table.rx_idle_ant = MAIN_ANT;
 		} else {
 			rtl88e_phy_set_rfpath_switch(hw, false);
 			rtlpriv->dm.fat_table.rx_idle_ant = AUX_ANT;
 		}
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 "rx idle ant %s\n",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "rx idle ant %s\n",
 			 (rtlpriv->dm.fat_table.rx_idle_ant == MAIN_ANT) ?
 			 ("MAIN_ANT") : ("AUX_ANT"));
 
@@ -1120,6 +1160,7 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 			rtl88e_phy_iq_calibrate(hw, false);
 			rtlphy->iqk_initialized = true;
 		}
+
 		rtl88e_dm_check_txpower_tracking(hw);
 		rtl88e_phy_lc_calibrate(hw);
 	}
@@ -1143,8 +1184,6 @@ int rtl88ee_hw_init(struct ieee80211_hw *hw)
 exit:
 	local_irq_restore(flags);
 	rtlpriv->rtlhal.being_init_adapter = false;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "end of Rtl8188EE hw init %x\n",
-		 err);
 	return err;
 }
 
@@ -1177,62 +1216,67 @@ static int _rtl88ee_set_media_status(struct ieee80211_hw *hw,
 				     enum nl80211_iftype type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 bt_msr = rtl_read_byte(rtlpriv, MSR);
+	u8 bt_msr = rtl_read_byte(rtlpriv, MSR) & 0xfc;
 	enum led_ctl_mode ledaction = LED_CTL_NO_LINK;
-	bt_msr &= 0xfc;
-
-	if (type == NL80211_IFTYPE_UNSPECIFIED ||
-	    type == NL80211_IFTYPE_STATION) {
-		_rtl88ee_stop_tx_beacon(hw);
-		_rtl88ee_enable_bcn_sub_func(hw);
-	} else if (type == NL80211_IFTYPE_ADHOC ||
-		type == NL80211_IFTYPE_AP ||
-		type == NL80211_IFTYPE_MESH_POINT) {
-		_rtl88ee_resume_tx_beacon(hw);
-		_rtl88ee_disable_bcn_sub_func(hw);
-	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x).\n",
-			 type);
-	}
+	u8 mode = MSR_NOLINK;
 
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
-	case NL80211_IFTYPE_MESH_POINT:
-		bt_msr |= MSR_ADHOC;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Set Network type to Mesh Point!\n");
-		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Network type %d not support!\n", type);
 		return 1;
+		break;
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
+	}
+
+	if (mode == MSR_NOLINK || mode == MSR_INFRA) {
+		_rtl88ee_stop_tx_beacon(hw);
+		_rtl88ee_enable_bcn_sub_func(hw);
+	} else if (mode == MSR_ADHOC || mode == MSR_AP) {
+		_rtl88ee_resume_tx_beacon(hw);
+		_rtl88ee_disable_bcn_sub_func(hw);
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
@@ -1242,13 +1286,12 @@ static int _rtl88ee_set_media_status(struct ieee80211_hw *hw,
 void rtl88ee_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 reg_rcr;
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rcr = rtlpci->receive_config;
 
 	if (rtlpriv->psc.rfpwr_state != ERFON)
 		return;
 
-	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RCR, (u8 *)(&reg_rcr));
-
 	if (check_bssid == true) {
 		reg_rcr |= (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
@@ -1260,9 +1303,11 @@ void rtl88ee_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 		rtlpriv->cfg->ops->set_hw_reg(hw,
 			HW_VAR_RCR, (u8 *)(&reg_rcr));
 	}
+
 }
 
-int rtl88ee_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype type)
+int rtl88ee_set_network_type(struct ieee80211_hw *hw,
+			     enum nl80211_iftype type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
@@ -1280,7 +1325,9 @@ int rtl88ee_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype type)
 	return 0;
 }
 
-/* don't set REG_EDCA_BE_PARAM here because mac80211 will send pkt when scan */
+/* don't set REG_EDCA_BE_PARAM here
+ * because mac80211 will send pkt when scan
+ */
 void rtl88ee_set_qos(struct ieee80211_hw *hw, int aci)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1303,22 +1350,41 @@ void rtl88ee_set_qos(struct ieee80211_hw *hw, int aci)
 	}
 }
 
+static void rtl88ee_clear_interrupt(struct ieee80211_hw *hw)
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
 void rtl88ee_enable_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
-	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
-	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
+	rtl88ee_clear_interrupt(hw);/*clear it here first*/
+	rtl_write_dword(rtlpriv, REG_HIMR,
+			rtlpci->irq_mask[0] & 0xFFFFFFFF);
+	rtl_write_dword(rtlpriv, REG_HIMRE,
+			rtlpci->irq_mask[1] & 0xFFFFFFFF);
 	rtlpci->irq_enabled = true;
-	/* there are some C2H CMDs have been sent before system interrupt
-	 * is enabled, e.g., C2H, CPWM.
-	 * So we need to clear all C2H events that FW has notified, otherwise
-	 * FW won't schedule any commands anymore.
+	/* there are some C2H CMDs have been sent
+	 * before system interrupt is enabled, e.g., C2H, CPWM.
+	 * So we need to clear all C2H events that FW has notified,
+	 * otherwise FW won't schedule any commands anymore.
 	 */
 	rtl_write_byte(rtlpriv, REG_C2HEVT_CLEAR, 0);
 	/*enable system interrupt*/
-	rtl_write_dword(rtlpriv, REG_HSIMR, rtlpci->sys_irq_mask & 0xFFFFFFFF);
+	rtl_write_dword(rtlpriv, REG_HSIMR,
+			rtlpci->sys_irq_mask & 0xFFFFFFFF);
 }
 
 void rtl88ee_disable_interrupt(struct ieee80211_hw *hw)
@@ -1329,7 +1395,7 @@ void rtl88ee_disable_interrupt(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, REG_HIMR, IMR_DISABLED);
 	rtl_write_dword(rtlpriv, REG_HIMRE, IMR_DISABLED);
 	rtlpci->irq_enabled = false;
-	synchronize_irq(rtlpci->pdev->irq);
+	/*synchronize_irq(rtlpci->pdev->irq);*/
 }
 
 static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
@@ -1353,9 +1419,9 @@ static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
 	}
 	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG+1, 0xFF);
 
-	rtl88_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				   PWR_INTF_PCI_MSK,
-				   RTL8188E_NIC_LPS_ENTER_FLOW);
+	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK,
+				 RTL8188EE_NIC_LPS_ENTER_FLOW);
 
 	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00);
 
@@ -1369,8 +1435,8 @@ static void _rtl88ee_poweroff_adapter(struct ieee80211_hw *hw)
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_32K_CTRL);
 	rtl_write_byte(rtlpriv, REG_32K_CTRL, (u1b_tmp & (~BIT(0))));
 
-	rtl88_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-				   PWR_INTF_PCI_MSK, RTL8188E_NIC_DISABLE_FLOW);
+	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, RTL8188EE_NIC_DISABLE_FLOW);
 
 	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp & (~BIT(3))));
@@ -1427,6 +1493,7 @@ void rtl88ee_interrupt_recognized(struct ieee80211_hw *hw,
 
 	*p_intb = rtl_read_dword(rtlpriv, REG_HISRE) & rtlpci->irq_mask[1];
 	rtl_write_dword(rtlpriv, REG_HISRE, *p_intb);
+
 }
 
 void rtl88ee_set_beacon_related_registers(struct ieee80211_hw *hw)
@@ -1472,233 +1539,241 @@ void rtl88ee_update_interrupt_mask(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
 		 "add_msr:%x, rm_msr:%x\n", add_msr, rm_msr);
 
-	rtl88ee_disable_interrupt(hw);
 	if (add_msr)
 		rtlpci->irq_mask[0] |= add_msr;
 	if (rm_msr)
 		rtlpci->irq_mask[0] &= (~rm_msr);
+	rtl88ee_disable_interrupt(hw);
 	rtl88ee_enable_interrupt(hw);
 }
 
-static inline u8 get_chnl_group(u8 chnl)
+static u8 _rtl88e_get_chnl_group(u8 chnl)
 {
-	u8 group;
-
-	group = chnl / 3;
-	if (chnl == 14)
+	u8 group = 0;
+
+	if (chnl < 3)
+		group = 0;
+	else if (chnl < 6)
+		group = 1;
+	else if (chnl < 9)
+		group = 2;
+	else if (chnl < 12)
+		group = 3;
+	else if (chnl < 14)
+		group = 4;
+	else if (chnl == 14)
 		group = 5;
 
 	return group;
 }
 
-static void set_diff0_2g(struct txpower_info_2g *pwr2g, u8 *hwinfo, u32 path,
-			 u32 i, u32 eadr)
+static void set_24g_base(struct txpower_info_2g *pwrinfo24g, u32 rfpath)
 {
-	pwr2g->bw40_diff[path][i] = 0;
-	if (hwinfo[eadr] == 0xFF) {
-		pwr2g->bw20_diff[path][i] = 0x02;
-	} else {
-		pwr2g->bw20_diff[path][i] = (hwinfo[eadr]&0xf0)>>4;
-		/*bit sign number to 8 bit sign number*/
-		if (pwr2g->bw20_diff[path][i] & BIT(3))
-			pwr2g->bw20_diff[path][i] |= 0xF0;
-	}
+	int group, txcnt;
 
-	if (hwinfo[eadr] == 0xFF) {
-		pwr2g->ofdm_diff[path][i] = 0x04;
-	} else {
-		pwr2g->ofdm_diff[path][i] = (hwinfo[eadr] & 0x0f);
-		/*bit sign number to 8 bit sign number*/
-		if (pwr2g->ofdm_diff[path][i] & BIT(3))
-			pwr2g->ofdm_diff[path][i] |= 0xF0;
-	}
-	pwr2g->cck_diff[path][i] = 0;
-}
-
-static void set_diff0_5g(struct txpower_info_5g *pwr5g, u8 *hwinfo, u32 path,
-			 u32 i, u32 eadr)
-{
-	pwr5g->bw40_diff[path][i] = 0;
-	if (hwinfo[eadr] == 0xFF) {
-		pwr5g->bw20_diff[path][i] = 0;
-	} else {
-		pwr5g->bw20_diff[path][i] = (hwinfo[eadr]&0xf0)>>4;
-		/*bit sign number to 8 bit sign number*/
-		if (pwr5g->bw20_diff[path][i] & BIT(3))
-			pwr5g->bw20_diff[path][i] |= 0xF0;
+	for (group = 0 ; group < MAX_CHNL_GROUP_24G; group++) {
+		pwrinfo24g->index_cck_base[rfpath][group] = 0x2D;
+		pwrinfo24g->index_bw40_base[rfpath][group] = 0x2D;
 	}
-
-	if (hwinfo[eadr] == 0xFF) {
-		pwr5g->ofdm_diff[path][i] = 0x04;
-	} else {
-		pwr5g->ofdm_diff[path][i] = (hwinfo[eadr] & 0x0f);
-		/*bit sign number to 8 bit sign number*/
-		if (pwr5g->ofdm_diff[path][i] & BIT(3))
-			pwr5g->ofdm_diff[path][i] |= 0xF0;
-	}
-}
-
-static void set_diff1_2g(struct txpower_info_2g *pwr2g, u8 *hwinfo, u32 path,
-			 u32 i, u32 eadr)
-{
-	if (hwinfo[eadr] == 0xFF) {
-		pwr2g->bw40_diff[path][i] = 0xFE;
-	} else {
-		pwr2g->bw40_diff[path][i] = (hwinfo[eadr]&0xf0)>>4;
-		if (pwr2g->bw40_diff[path][i] & BIT(3))
-			pwr2g->bw40_diff[path][i] |= 0xF0;
-	}
-
-	if (hwinfo[eadr] == 0xFF) {
-		pwr2g->bw20_diff[path][i] = 0xFE;
-	} else {
-		pwr2g->bw20_diff[path][i] = (hwinfo[eadr]&0x0f);
-		if (pwr2g->bw20_diff[path][i] & BIT(3))
-			pwr2g->bw20_diff[path][i] |= 0xF0;
-	}
-}
-
-static void set_diff1_5g(struct txpower_info_5g *pwr5g, u8 *hwinfo, u32 path,
-			 u32 i, u32 eadr)
-{
-	if (hwinfo[eadr] == 0xFF) {
-		pwr5g->bw40_diff[path][i] = 0xFE;
-	} else {
-		pwr5g->bw40_diff[path][i] = (hwinfo[eadr]&0xf0)>>4;
-		if (pwr5g->bw40_diff[path][i] & BIT(3))
-			pwr5g->bw40_diff[path][i] |= 0xF0;
-	}
-
-	if (hwinfo[eadr] == 0xFF) {
-		pwr5g->bw20_diff[path][i] = 0xFE;
-	} else {
-		pwr5g->bw20_diff[path][i] = (hwinfo[eadr] & 0x0f);
-		if (pwr5g->bw20_diff[path][i] & BIT(3))
-			pwr5g->bw20_diff[path][i] |= 0xF0;
-	}
-}
-
-static void set_diff2_2g(struct txpower_info_2g *pwr2g, u8 *hwinfo, u32 path,
-			 u32 i, u32 eadr)
-{
-	if (hwinfo[eadr] == 0xFF) {
-		pwr2g->ofdm_diff[path][i] = 0xFE;
-	} else {
-		pwr2g->ofdm_diff[path][i] = (hwinfo[eadr]&0xf0)>>4;
-		if (pwr2g->ofdm_diff[path][i] & BIT(3))
-			pwr2g->ofdm_diff[path][i] |= 0xF0;
-	}
-
-	if (hwinfo[eadr] == 0xFF) {
-		pwr2g->cck_diff[path][i] = 0xFE;
-	} else {
-		pwr2g->cck_diff[path][i] = (hwinfo[eadr]&0x0f);
-		if (pwr2g->cck_diff[path][i] & BIT(3))
-			pwr2g->cck_diff[path][i] |= 0xF0;
+	for (txcnt = 0; txcnt < MAX_TX_COUNT; txcnt++) {
+		if (txcnt == 0) {
+			pwrinfo24g->bw20_diff[rfpath][0] = 0x02;
+			pwrinfo24g->ofdm_diff[rfpath][0] = 0x04;
+		} else {
+			pwrinfo24g->bw20_diff[rfpath][txcnt] = 0xFE;
+			pwrinfo24g->bw40_diff[rfpath][txcnt] = 0xFE;
+			pwrinfo24g->cck_diff[rfpath][txcnt] =	0xFE;
+			pwrinfo24g->ofdm_diff[rfpath][txcnt] = 0xFE;
+		}
 	}
 }
 
-static void _rtl8188e_read_power_value_fromprom(struct ieee80211_hw *hw,
-						struct txpower_info_2g *pwr2g,
-						struct txpower_info_5g *pwr5g,
-						bool autoload_fail,
-						u8 *hwinfo)
+static void read_power_value_fromprom(struct ieee80211_hw *hw,
+				      struct txpower_info_2g *pwrinfo24g,
+				      struct txpower_info_5g *pwrinfo5g,
+				      bool autoload_fail, u8 *hwinfo)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 path, eadr = EEPROM_TX_PWR_INX, i;
+	u32 rfpath, eeaddr = EEPROM_TX_PWR_INX, group, txcnt = 0;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "hal_ReadPowerValueFromPROM88E(): PROMContent[0x%x]= 0x%x\n",
-		 (eadr+1), hwinfo[eadr+1]);
-	if (0xFF == hwinfo[eadr+1])
+		 "hal_ReadPowerValueFromPROM88E():PROMContent[0x%x]=0x%x\n",
+		 (eeaddr+1), hwinfo[eeaddr+1]);
+	if (0xFF == hwinfo[eeaddr+1])  /*YJ,add,120316*/
 		autoload_fail = true;
 
 	if (autoload_fail) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "auto load fail : Use Default value!\n");
-		for (path = 0; path < MAX_RF_PATH; path++) {
+		for (rfpath = 0 ; rfpath < MAX_RF_PATH ; rfpath++) {
 			/* 2.4G default value */
-			for (i = 0; i < MAX_CHNL_GROUP_24G; i++) {
-				pwr2g->index_cck_base[path][i] = 0x2D;
-				pwr2g->index_bw40_base[path][i] = 0x2D;
-			}
-			for (i = 0; i < MAX_TX_COUNT; i++) {
-				if (i == 0) {
-					pwr2g->bw20_diff[path][0] = 0x02;
-					pwr2g->ofdm_diff[path][0] = 0x04;
-				} else {
-					pwr2g->bw20_diff[path][i] = 0xFE;
-					pwr2g->bw40_diff[path][i] = 0xFE;
-					pwr2g->cck_diff[path][i] = 0xFE;
-					pwr2g->ofdm_diff[path][i] = 0xFE;
-				}
-			}
+			set_24g_base(pwrinfo24g, rfpath);
 		}
 		return;
 	}
 
-	for (path = 0; path < MAX_RF_PATH; path++) {
+	for (rfpath = 0 ; rfpath < MAX_RF_PATH ; rfpath++) {
 		/*2.4G default value*/
-		for (i = 0; i < MAX_CHNL_GROUP_24G; i++) {
-			pwr2g->index_cck_base[path][i] = hwinfo[eadr++];
-			if (pwr2g->index_cck_base[path][i] == 0xFF)
-				pwr2g->index_cck_base[path][i] = 0x2D;
+		for (group = 0 ; group < MAX_CHNL_GROUP_24G; group++) {
+			pwrinfo24g->index_cck_base[rfpath][group] =
+			  hwinfo[eeaddr++];
+			if (pwrinfo24g->index_cck_base[rfpath][group] == 0xFF)
+				pwrinfo24g->index_cck_base[rfpath][group] =
+				  0x2D;
+		}
+		for (group = 0 ; group < MAX_CHNL_GROUP_24G-1; group++) {
+			pwrinfo24g->index_bw40_base[rfpath][group] =
+				hwinfo[eeaddr++];
+			if (pwrinfo24g->index_bw40_base[rfpath][group] == 0xFF)
+				pwrinfo24g->index_bw40_base[rfpath][group] =
+					0x2D;
 		}
-		for (i = 0; i < MAX_CHNL_GROUP_24G; i++) {
-			pwr2g->index_bw40_base[path][i] = hwinfo[eadr++];
-			if (pwr2g->index_bw40_base[path][i] == 0xFF)
-				pwr2g->index_bw40_base[path][i] = 0x2D;
+		pwrinfo24g->bw40_diff[rfpath][0] = 0;
+		if (hwinfo[eeaddr] == 0xFF) {
+			pwrinfo24g->bw20_diff[rfpath][0] = 0x02;
+		} else {
+			pwrinfo24g->bw20_diff[rfpath][0] =
+				(hwinfo[eeaddr]&0xf0)>>4;
+			/*bit sign number to 8 bit sign number*/
+			if (pwrinfo24g->bw20_diff[rfpath][0] & BIT(3))
+				pwrinfo24g->bw20_diff[rfpath][0] |= 0xF0;
+		}
+
+		if (hwinfo[eeaddr] == 0xFF) {
+			pwrinfo24g->ofdm_diff[rfpath][0] = 0x04;
+		} else {
+			pwrinfo24g->ofdm_diff[rfpath][0] =
+				(hwinfo[eeaddr]&0x0f);
+				/*bit sign number to 8 bit sign number*/
+			if (pwrinfo24g->ofdm_diff[rfpath][0] & BIT(3))
+				pwrinfo24g->ofdm_diff[rfpath][0] |= 0xF0;
 		}
-		for (i = 0; i < MAX_TX_COUNT; i++) {
-			if (i == 0) {
-				set_diff0_2g(pwr2g, hwinfo, path, i, eadr);
-				eadr++;
+		pwrinfo24g->cck_diff[rfpath][0] = 0;
+		eeaddr++;
+		for (txcnt = 1; txcnt < MAX_TX_COUNT; txcnt++) {
+			if (hwinfo[eeaddr] == 0xFF) {
+				pwrinfo24g->bw40_diff[rfpath][txcnt] = 0xFE;
+			} else {
+				pwrinfo24g->bw40_diff[rfpath][txcnt] =
+				  (hwinfo[eeaddr]&0xf0)>>4;
+				if (pwrinfo24g->bw40_diff[rfpath][txcnt] &
+				    BIT(3))
+					pwrinfo24g->bw40_diff[rfpath][txcnt] |=
+					  0xF0;
+			}
+
+			if (hwinfo[eeaddr] == 0xFF) {
+				pwrinfo24g->bw20_diff[rfpath][txcnt] =
+					0xFE;
 			} else {
-				set_diff1_2g(pwr2g, hwinfo, path, i, eadr);
-				eadr++;
+				pwrinfo24g->bw20_diff[rfpath][txcnt] =
+				  (hwinfo[eeaddr]&0x0f);
+				if (pwrinfo24g->bw20_diff[rfpath][txcnt] &
+				    BIT(3))
+					pwrinfo24g->bw20_diff[rfpath][txcnt] |=
+					  0xF0;
+			}
+			eeaddr++;
 
-				set_diff2_2g(pwr2g, hwinfo, path, i, eadr);
-				eadr++;
+			if (hwinfo[eeaddr] == 0xFF) {
+				pwrinfo24g->ofdm_diff[rfpath][txcnt] = 0xFE;
+			} else {
+				pwrinfo24g->ofdm_diff[rfpath][txcnt] =
+				  (hwinfo[eeaddr]&0xf0)>>4;
+				if (pwrinfo24g->ofdm_diff[rfpath][txcnt] &
+				    BIT(3))
+					pwrinfo24g->ofdm_diff[rfpath][txcnt] |=
+					  0xF0;
 			}
+
+			if (hwinfo[eeaddr] == 0xFF) {
+				pwrinfo24g->cck_diff[rfpath][txcnt] =	0xFE;
+			} else {
+				pwrinfo24g->cck_diff[rfpath][txcnt] =
+				  (hwinfo[eeaddr]&0x0f);
+				if (pwrinfo24g->cck_diff[rfpath][txcnt] &
+				    BIT(3))
+					pwrinfo24g->cck_diff[rfpath][txcnt] |=
+					  0xF0;
+			}
+			eeaddr++;
 		}
 
 		/*5G default value*/
-		for (i = 0; i < MAX_CHNL_GROUP_5G; i++) {
-			pwr5g->index_bw40_base[path][i] = hwinfo[eadr++];
-			if (pwr5g->index_bw40_base[path][i] == 0xFF)
-				pwr5g->index_bw40_base[path][i] = 0xFE;
+		for (group = 0 ; group < MAX_CHNL_GROUP_5G; group++) {
+			pwrinfo5g->index_bw40_base[rfpath][group] =
+				hwinfo[eeaddr++];
+			if (pwrinfo5g->index_bw40_base[rfpath][group] == 0xFF)
+				pwrinfo5g->index_bw40_base[rfpath][group] =
+				  0xFE;
 		}
 
-		for (i = 0; i < MAX_TX_COUNT; i++) {
-			if (i == 0) {
-				set_diff0_5g(pwr5g, hwinfo, path, i, eadr);
-				eadr++;
+		pwrinfo5g->bw40_diff[rfpath][0] = 0;
+
+		if (hwinfo[eeaddr] == 0xFF) {
+			pwrinfo5g->bw20_diff[rfpath][0] = 0;
+		} else {
+			pwrinfo5g->bw20_diff[rfpath][0] =
+			  (hwinfo[eeaddr]&0xf0)>>4;
+			if (pwrinfo5g->bw20_diff[rfpath][0] & BIT(3))
+				pwrinfo5g->bw20_diff[rfpath][0] |= 0xF0;
+		}
+
+		if (hwinfo[eeaddr] == 0xFF) {
+			pwrinfo5g->ofdm_diff[rfpath][0] = 0x04;
+		} else {
+			pwrinfo5g->ofdm_diff[rfpath][0] = (hwinfo[eeaddr]&0x0f);
+			if (pwrinfo5g->ofdm_diff[rfpath][0] & BIT(3))
+				pwrinfo5g->ofdm_diff[rfpath][0] |= 0xF0;
+		}
+		eeaddr++;
+		for (txcnt = 1; txcnt < MAX_TX_COUNT; txcnt++) {
+			if (hwinfo[eeaddr] == 0xFF) {
+				pwrinfo5g->bw40_diff[rfpath][txcnt] =	0xFE;
+			} else {
+				pwrinfo5g->bw40_diff[rfpath][txcnt] =
+				  (hwinfo[eeaddr]&0xf0)>>4;
+				if (pwrinfo5g->bw40_diff[rfpath][txcnt] &
+				    BIT(3))
+					pwrinfo5g->bw40_diff[rfpath][txcnt] |=
+					  0xF0;
+			}
+
+			if (hwinfo[eeaddr] == 0xFF) {
+				pwrinfo5g->bw20_diff[rfpath][txcnt] =	0xFE;
 			} else {
-				set_diff1_5g(pwr5g, hwinfo, path, i, eadr);
-				eadr++;
+				pwrinfo5g->bw20_diff[rfpath][txcnt] =
+				  (hwinfo[eeaddr]&0x0f);
+				if (pwrinfo5g->bw20_diff[rfpath][txcnt] &
+				    BIT(3))
+					pwrinfo5g->bw20_diff[rfpath][txcnt] |=
+					  0xF0;
 			}
+			eeaddr++;
 		}
 
-		if (hwinfo[eadr] == 0xFF) {
-			pwr5g->ofdm_diff[path][1] = 0xFE;
-			pwr5g->ofdm_diff[path][2] = 0xFE;
+		if (hwinfo[eeaddr] == 0xFF) {
+			pwrinfo5g->ofdm_diff[rfpath][1] = 0xFE;
+			pwrinfo5g->ofdm_diff[rfpath][2] = 0xFE;
 		} else {
-			pwr5g->ofdm_diff[path][1] = (hwinfo[eadr] & 0xf0) >> 4;
-			pwr5g->ofdm_diff[path][2] = (hwinfo[eadr] & 0x0f);
+			pwrinfo5g->ofdm_diff[rfpath][1] =
+					(hwinfo[eeaddr]&0xf0)>>4;
+			pwrinfo5g->ofdm_diff[rfpath][2] =
+					(hwinfo[eeaddr]&0x0f);
 		}
-		eadr++;
+		eeaddr++;
 
-		if (hwinfo[eadr] == 0xFF)
-			pwr5g->ofdm_diff[path][3] = 0xFE;
+		if (hwinfo[eeaddr] == 0xFF)
+			pwrinfo5g->ofdm_diff[rfpath][3] = 0xFE;
 		else
-			pwr5g->ofdm_diff[path][3] = (hwinfo[eadr]&0x0f);
-		eadr++;
-
-		for (i = 1; i < MAX_TX_COUNT; i++) {
-			if (pwr5g->ofdm_diff[path][i] == 0xFF)
-				pwr5g->ofdm_diff[path][i] = 0xFE;
-			else if (pwr5g->ofdm_diff[path][i] & BIT(3))
-				pwr5g->ofdm_diff[path][i] |= 0xF0;
+			pwrinfo5g->ofdm_diff[rfpath][3] = (hwinfo[eeaddr]&0x0f);
+		eeaddr++;
+
+		for (txcnt = 1; txcnt < MAX_TX_COUNT; txcnt++) {
+			if (pwrinfo5g->ofdm_diff[rfpath][txcnt] == 0xFF)
+				pwrinfo5g->ofdm_diff[rfpath][txcnt] =	0xFE;
+			else if (pwrinfo5g->ofdm_diff[rfpath][txcnt] & BIT(3))
+				pwrinfo5g->ofdm_diff[rfpath][txcnt] |= 0xF0;
 		}
 	}
 }
@@ -1713,41 +1788,36 @@ static void _rtl88ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	struct txpower_info_5g pwrinfo5g;
 	u8 rf_path, index;
 	u8 i;
-	int jj = EEPROM_RF_BOARD_OPTION_88E;
-	int kk = EEPROM_THERMAL_METER_88E;
 
-	_rtl8188e_read_power_value_fromprom(hw, &pwrinfo24g, &pwrinfo5g,
-					    autoload_fail, hwinfo);
+	read_power_value_fromprom(hw, &pwrinfo24g,
+				  &pwrinfo5g, autoload_fail, hwinfo);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = get_chnl_group(i+1);
+			index = _rtl88e_get_chnl_group(i+1);
 
 			rtlefuse->txpwrlevel_cck[rf_path][i] =
-				 pwrinfo24g.index_cck_base[rf_path][index];
-			if (i == 13)
-				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
-				     pwrinfo24g.index_bw40_base[rf_path][4];
-			else
-				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
-				     pwrinfo24g.index_bw40_base[rf_path][index];
+				pwrinfo24g.index_cck_base[rf_path][index];
+			rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
+				pwrinfo24g.index_bw40_base[rf_path][index];
 			rtlefuse->txpwr_ht20diff[rf_path][i] =
-				 pwrinfo24g.bw20_diff[rf_path][0];
+				pwrinfo24g.bw20_diff[rf_path][0];
 			rtlefuse->txpwr_legacyhtdiff[rf_path][i] =
-				 pwrinfo24g.ofdm_diff[rf_path][0];
+				pwrinfo24g.ofdm_diff[rf_path][0];
 		}
 
 		for (i = 0; i < 14; i++) {
 			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
-				"RF(%d)-Ch(%d) [CCK / HT40_1S ] = "
-				"[0x%x / 0x%x ]\n", rf_path, i,
+				"RF(%d)-Ch(%d) [CCK / HT40_1S ] = [0x%x / 0x%x ]\n",
+				rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
 				rtlefuse->txpwrlevel_ht40_1s[rf_path][i]);
 		}
 	}
 
 	if (!autoload_fail)
-		rtlefuse->eeprom_thermalmeter = hwinfo[kk];
+		rtlefuse->eeprom_thermalmeter =
+			hwinfo[EEPROM_THERMAL_METER_88E];
 	else
 		rtlefuse->eeprom_thermalmeter = EEPROM_DEFAULT_THERMALMETER;
 
@@ -1761,8 +1831,9 @@ static void _rtl88ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 
 	if (!autoload_fail) {
-		rtlefuse->eeprom_regulatory = hwinfo[jj] & 0x07;/*bit0~2*/
-		if (hwinfo[jj] == 0xFF)
+		rtlefuse->eeprom_regulatory =
+			hwinfo[EEPROM_RF_BOARD_OPTION_88E] & 0x07;/*bit0~2*/
+		if (hwinfo[EEPROM_RF_BOARD_OPTION_88E] == 0xFF)
 			rtlefuse->eeprom_regulatory = 0;
 	} else {
 		rtlefuse->eeprom_regulatory = 0;
@@ -1776,12 +1847,9 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_pci_priv *rppriv = rtl_pcipriv(hw);
 	u16 i, usvalue;
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
-	int jj = EEPROM_RF_BOARD_OPTION_88E;
-	int kk = EEPROM_RF_FEATURE_OPTION_88E;
 
 	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
 		rtl_efuse_shadow_map_update(hw);
@@ -1791,9 +1859,14 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	} else if (rtlefuse->epromtype == EEPROM_93C46) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "RTL819X Not boot from eeprom, check it !!");
+		return;
+	} else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "boot from neither eeprom nor efuse, check it !!");
+		return;
 	}
 
-	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, ("MAP\n"),
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
 		      hwinfo, HWSET_MAX_SIZE);
 
 	eeprom_id = *((u16 *)&hwinfo[0]);
@@ -1826,7 +1899,7 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	/*customer ID*/
 	rtlefuse->eeprom_oemid = hwinfo[EEPROM_CUSTOMER_ID];
 	if (rtlefuse->eeprom_oemid == 0xFF)
-		rtlefuse->eeprom_oemid = 0;
+		rtlefuse->eeprom_oemid =	0;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
@@ -1845,34 +1918,40 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 	/* set channel paln to world wide 13 */
 	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
 	/*tx power*/
-	_rtl88ee_read_txpower_info_from_hwpg(hw, rtlefuse->autoload_failflag,
+	_rtl88ee_read_txpower_info_from_hwpg(hw,
+					     rtlefuse->autoload_failflag,
 					     hwinfo);
 	rtlefuse->txpwr_fromeprom = true;
 
 	rtl8188ee_read_bt_coexist_info_from_hwpg(hw,
 						 rtlefuse->autoload_failflag,
 						 hwinfo);
+
 	/*board type*/
-	rtlefuse->board_type = (hwinfo[jj] & 0xE0) >> 5;
+	rtlefuse->board_type =
+		((hwinfo[EEPROM_RF_BOARD_OPTION_88E] & 0xE0) >> 5);
+	rtlhal->board_type = rtlefuse->board_type;
 	/*Wake on wlan*/
-	rtlefuse->wowlan_enable = ((hwinfo[kk] & 0x40) >> 6);
+	rtlefuse->wowlan_enable =
+		((hwinfo[EEPROM_RF_FEATURE_OPTION_88E] & 0x40) >> 6);
 	/*parse xtal*/
 	rtlefuse->crystalcap = hwinfo[EEPROM_XTAL_88E];
 	if (hwinfo[EEPROM_XTAL_88E])
 		rtlefuse->crystalcap = 0x20;
 	/*antenna diversity*/
-	rtlefuse->antenna_div_cfg = (hwinfo[jj] & 0x18) >> 3;
-	if (hwinfo[jj] == 0xFF)
+	rtlefuse->antenna_div_cfg =
+		(hwinfo[EEPROM_RF_BOARD_OPTION_88E] & 0x18) >> 3;
+	if (hwinfo[EEPROM_RF_BOARD_OPTION_88E] == 0xFF)
 		rtlefuse->antenna_div_cfg = 0;
-	if (rppriv->bt_coexist.eeprom_bt_coexist != 0 &&
-	    rppriv->bt_coexist.eeprom_bt_ant_num == ANT_X1)
+	if (rtlpriv->btcoexist.eeprom_bt_coexist != 0 &&
+	    rtlpriv->btcoexist.eeprom_bt_ant_num == ANT_X1)
 		rtlefuse->antenna_div_cfg = 0;
 
 	rtlefuse->antenna_div_type = hwinfo[EEPROM_RF_ANTENNA_OPT_88E];
 	if (rtlefuse->antenna_div_type == 0xFF)
 		rtlefuse->antenna_div_type = 0x01;
 	if (rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV ||
-	    rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
+		rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
 		rtlefuse->antenna_div_cfg = 1;
 
 	if (rtlhal->oem_id == RT_CID_DEFAULT) {
@@ -1882,12 +1961,12 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 				if (rtlefuse->eeprom_svid == 0x1025) {
 					rtlhal->oem_id = RT_CID_819X_ACER;
 				} else if ((rtlefuse->eeprom_svid == 0x10EC &&
-					    rtlefuse->eeprom_smid == 0x0179) ||
-					    (rtlefuse->eeprom_svid == 0x17AA &&
-					    rtlefuse->eeprom_smid == 0x0179)) {
+				     rtlefuse->eeprom_smid == 0x0179) ||
+				     (rtlefuse->eeprom_svid == 0x17AA &&
+				     rtlefuse->eeprom_smid == 0x0179)) {
 					rtlhal->oem_id = RT_CID_819X_LENOVO;
 				} else if (rtlefuse->eeprom_svid == 0x103c &&
-					 rtlefuse->eeprom_smid == 0x197d) {
+					   rtlefuse->eeprom_smid == 0x197d) {
 					rtlhal->oem_id = RT_CID_819X_HP;
 				} else {
 					rtlhal->oem_id = RT_CID_DEFAULT;
@@ -1906,6 +1985,7 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 		default:
 			rtlhal->oem_id = RT_CID_DEFAULT;
 			break;
+
 		}
 	}
 }
@@ -1944,14 +2024,13 @@ void rtl88ee_read_eeprom_info(struct ieee80211_hw *hw)
 	u8 tmp_u1b;
 
 	rtlhal->version = _rtl88ee_read_chip_version(hw);
-	if (get_rf_type(rtlphy) == RF_1T1R) {
-		rtlpriv->dm.rfpath_rxenable[0] = true;
-	} else {
+	if (get_rf_type(rtlphy) == RF_1T1R)
 		rtlpriv->dm.rfpath_rxenable[0] = true;
-		rtlpriv->dm.rfpath_rxenable[1] = true;
-	}
+	else
+		rtlpriv->dm.rfpath_rxenable[0] =
+		    rtlpriv->dm.rfpath_rxenable[1] = true;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "VersionID = 0x%4x\n",
-		 rtlhal->version);
+						rtlhal->version);
 	tmp_u1b = rtl_read_byte(rtlpriv, REG_9346CR);
 	if (tmp_u1b & BIT(4)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EEPROM\n");
@@ -1971,24 +2050,25 @@ void rtl88ee_read_eeprom_info(struct ieee80211_hw *hw)
 }
 
 static void rtl88ee_update_hal_rate_table(struct ieee80211_hw *hw,
-					  struct ieee80211_sta *sta)
+		struct ieee80211_sta *sta)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rppriv = rtl_pcipriv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u32 ratr_value;
 	u8 ratr_index = 0;
-	u8 nmode = mac->ht_enable;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
+	u8 b_nmode = mac->ht_enable;
+	/*u8 mimo_ps = IEEE80211_SMPS_OFF;*/
 	u16 shortgi_rate;
 	u32 tmp_ratr_value;
-	u8 ctx40 = mac->bw_40;
-	u16 cap = sta->ht_cap.cap;
-	u8 short40 = (cap & IEEE80211_HT_CAP_SGI_40) ?  1 : 0;
-	u8 short20 = (cap & IEEE80211_HT_CAP_SGI_20) ?  1 : 0;
+	u8 curtxbw_40mhz = mac->bw_40;
+	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+				1 : 0;
+	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+				1 : 0;
 	enum wireless_mode wirelessmode = mac->mode;
+	u32 ratr_mask;
 
 	if (rtlhal->current_bandtype == BAND_ON_5G)
 		ratr_value = sta->supp_rates[1] << 4;
@@ -1997,7 +2077,7 @@ static void rtl88ee_update_hal_rate_table(struct ieee80211_hw *hw,
 	if (mac->opmode == NL80211_IFTYPE_ADHOC)
 		ratr_value = 0xfff;
 	ratr_value |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
-			sta->ht_cap.mcs.rx_mask[0] << 12);
+		       sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
 	case WIRELESS_MODE_B:
 		if (ratr_value & 0x0000000c)
@@ -2010,20 +2090,14 @@ static void rtl88ee_update_hal_rate_table(struct ieee80211_hw *hw,
 		break;
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
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
+		b_nmode = 1;
+		if (get_rf_type(rtlphy) == RF_1T2R ||
+		    get_rf_type(rtlphy) == RF_1T1R)
+			ratr_mask = 0x000ff005;
+		else
+			ratr_mask = 0x0f0ff005;
 
-			ratr_value &= ratr_mask;
-		}
+		ratr_value &= ratr_mask;
 		break;
 	default:
 		if (rtlphy->rf_type == RF_1T2R)
@@ -2034,18 +2108,19 @@ static void rtl88ee_update_hal_rate_table(struct ieee80211_hw *hw,
 		break;
 	}
 
-	if ((rppriv->bt_coexist.bt_coexistence) &&
-	    (rppriv->bt_coexist.bt_coexist_type == BT_CSR_BC4) &&
-	    (rppriv->bt_coexist.bt_cur_state) &&
-	    (rppriv->bt_coexist.bt_ant_isolation) &&
-	    ((rppriv->bt_coexist.bt_service == BT_SCO) ||
-	    (rppriv->bt_coexist.bt_service == BT_BUSY)))
+	if ((rtlpriv->btcoexist.bt_coexistence) &&
+	    (rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4) &&
+	    (rtlpriv->btcoexist.bt_cur_state) &&
+	    (rtlpriv->btcoexist.bt_ant_isolation) &&
+	    ((rtlpriv->btcoexist.bt_service == BT_SCO) ||
+	     (rtlpriv->btcoexist.bt_service == BT_BUSY)))
 		ratr_value &= 0x0fffcfc0;
 	else
 		ratr_value &= 0x0FFFFFFF;
 
-	if (nmode && ((ctx40 && short40) ||
-		      (!ctx40 && short20))) {
+	if (b_nmode &&
+	    ((curtxbw_40mhz && curshortgi_40mhz) ||
+	     (!curtxbw_40mhz && curshortgi_20mhz))) {
 		ratr_value |= 0x10000000;
 		tmp_ratr_value = (ratr_value >> 12);
 
@@ -2065,7 +2140,7 @@ static void rtl88ee_update_hal_rate_table(struct ieee80211_hw *hw,
 }
 
 static void rtl88ee_update_hal_rate_mask(struct ieee80211_hw *hw,
-					 struct ieee80211_sta *sta, u8 rssi)
+		struct ieee80211_sta *sta, u8 rssi_level)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
@@ -2074,23 +2149,25 @@ static void rtl88ee_update_hal_rate_mask(struct ieee80211_hw *hw,
 	struct rtl_sta_info *sta_entry = NULL;
 	u32 ratr_bitmap;
 	u8 ratr_index;
-	u16 cap = sta->ht_cap.cap;
-	u8 ctx40 = (cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40) ? 1 : 0;
-	u8 short40 = (cap & IEEE80211_HT_CAP_SGI_40) ?  1 : 0;
-	u8 short20 = (cap & IEEE80211_HT_CAP_SGI_20) ?  1 : 0;
+	u8 curtxbw_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40)
+				? 1 : 0;
+	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+				1 : 0;
+	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+				1 : 0;
 	enum wireless_mode wirelessmode = 0;
-	bool shortgi = false;
+	bool b_shortgi = false;
 	u8 rate_mask[5];
 	u8 macid = 0;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
+	/*u8 mimo_ps = IEEE80211_SMPS_OFF;*/
 
 	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
 	wirelessmode = sta_entry->wireless_mode;
 	if (mac->opmode == NL80211_IFTYPE_STATION ||
-	    mac->opmode == NL80211_IFTYPE_MESH_POINT)
-		ctx40 = mac->bw_40;
+		mac->opmode == NL80211_IFTYPE_MESH_POINT)
+		curtxbw_40mhz = mac->bw_40;
 	else if (mac->opmode == NL80211_IFTYPE_AP ||
-		 mac->opmode == NL80211_IFTYPE_ADHOC)
+		mac->opmode == NL80211_IFTYPE_ADHOC)
 		macid = sta->aid + 1;
 
 	if (rtlhal->current_bandtype == BAND_ON_5G)
@@ -2112,70 +2189,59 @@ static void rtl88ee_update_hal_rate_mask(struct ieee80211_hw *hw,
 	case WIRELESS_MODE_G:
 		ratr_index = RATR_INX_WIRELESS_GB;
 
-		if (rssi == 1)
+		if (rssi_level == 1)
 			ratr_bitmap &= 0x00000f00;
-		else if (rssi == 2)
+		else if (rssi_level == 2)
 			ratr_bitmap &= 0x00000ff0;
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
-		if (mimo_ps == IEEE80211_SMPS_STATIC) {
-			if (rssi == 1)
-				ratr_bitmap &= 0x00070000;
-			else if (rssi == 2)
-				ratr_bitmap &= 0x0007f000;
-			else
-				ratr_bitmap &= 0x0007f005;
+		if (rtlphy->rf_type == RF_1T2R ||
+		    rtlphy->rf_type == RF_1T1R) {
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
-			if (rtlphy->rf_type == RF_1T2R ||
-			    rtlphy->rf_type == RF_1T1R) {
-				if (ctx40) {
-					if (rssi == 1)
-						ratr_bitmap &= 0x000f0000;
-					else if (rssi == 2)
-						ratr_bitmap &= 0x000ff000;
-					else
-						ratr_bitmap &= 0x000ff015;
-				} else {
-					if (rssi == 1)
-						ratr_bitmap &= 0x000f0000;
-					else if (rssi == 2)
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
-				if (ctx40) {
-					if (rssi == 1)
-						ratr_bitmap &= 0x0f8f0000;
-					else if (rssi == 2)
-						ratr_bitmap &= 0x0f8ff000;
-					else
-						ratr_bitmap &= 0x0f8ff015;
-				} else {
-					if (rssi == 1)
-						ratr_bitmap &= 0x0f8f0000;
-					else if (rssi == 2)
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
+		/*}*/
+
+		if ((curtxbw_40mhz && curshortgi_40mhz) ||
+		    (!curtxbw_40mhz && curshortgi_20mhz)) {
 
-		if ((ctx40 && short40) || (!ctx40 && short20)) {
 			if (macid == 0)
-				shortgi = true;
+				b_shortgi = true;
 			else if (macid == 1)
-				shortgi = false;
+				b_shortgi = false;
 		}
 		break;
 	default:
@@ -2193,22 +2259,24 @@ static void rtl88ee_update_hal_rate_mask(struct ieee80211_hw *hw,
 		 "ratr_bitmap :%x\n", ratr_bitmap);
 	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
 			     (ratr_index << 28);
-	rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
+	rate_mask[4] = macid | (b_shortgi ? 0x20 : 0x00) | 0x80;
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
-		 ratr_index, ratr_bitmap, rate_mask[0], rate_mask[1],
-		 rate_mask[2], rate_mask[3], rate_mask[4]);
+		 ratr_index, ratr_bitmap,
+		 rate_mask[0], rate_mask[1],
+		 rate_mask[2], rate_mask[3],
+		 rate_mask[4]);
 	rtl88e_fill_h2c_cmd(hw, H2C_88E_RA_MASK, 5, rate_mask);
 	_rtl88ee_set_bcn_ctrl_reg(hw, BIT(3), 0);
 }
 
 void rtl88ee_update_hal_rate_tbl(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u8 rssi)
+		struct ieee80211_sta *sta, u8 rssi_level)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (rtlpriv->dm.useramask)
-		rtl88ee_update_hal_rate_mask(hw, sta, rssi);
+		rtl88ee_update_hal_rate_mask(hw, sta, rssi_level);
 	else
 		rtl88ee_update_hal_rate_table(hw, sta);
 }
@@ -2231,9 +2299,9 @@ bool rtl88ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	enum rf_pwrstate state_toset;
+	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
 	u32 u4tmp;
-	bool actuallyset = false;
+	bool b_actuallyset = false;
 
 	if (rtlpriv->rtlhal.being_init_adapter)
 		return false;
@@ -2250,27 +2318,29 @@ bool rtl88ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
 
-	u4tmp = rtl_read_dword(rtlpriv, REG_GPIO_OUTPUT);
-	state_toset = (u4tmp & BIT(31)) ? ERFON : ERFOFF;
+	cur_rfstate = ppsc->rfpwr_state;
 
+	u4tmp = rtl_read_dword(rtlpriv, REG_GPIO_OUTPUT);
+	e_rfpowerstate_toset = (u4tmp & BIT(31)) ? ERFON : ERFOFF;
 
-	if ((ppsc->hwradiooff == true) && (state_toset == ERFON)) {
+	if (ppsc->hwradiooff && (e_rfpowerstate_toset == ERFON)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
 
-		state_toset = ERFON;
+		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
-		actuallyset = true;
-	} else if ((ppsc->hwradiooff == false) && (state_toset == ERFOFF)) {
+		b_actuallyset = true;
+	} else if ((!ppsc->hwradiooff) &&
+		   (e_rfpowerstate_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
 
-		state_toset = ERFOFF;
+		e_rfpowerstate_toset = ERFOFF;
 		ppsc->hwradiooff = true;
-		actuallyset = true;
+		b_actuallyset = true;
 	}
 
-	if (actuallyset) {
+	if (b_actuallyset) {
 		spin_lock(&rtlpriv->locks.rf_ps_lock);
 		ppsc->rfchange_inprogress = false;
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
@@ -2285,50 +2355,19 @@ bool rtl88ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 
 	*valid = 1;
 	return !ppsc->hwradiooff;
-}
 
-static void add_one_key(struct ieee80211_hw *hw, u8 *macaddr,
-			struct rtl_mac *mac, u32 key, u32 id,
-			u8 enc_algo, bool is_pairwise)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "add one entry\n");
-	if (is_pairwise) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "set Pairwise key\n");
-
-		rtl_cam_add_one_entry(hw, macaddr, key, id, enc_algo,
-				      CAM_CONFIG_NO_USEDK,
-				      rtlpriv->sec.key_buf[key]);
-	} else {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "set group key\n");
-
-		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			rtl_cam_add_one_entry(hw, rtlefuse->dev_addr,
-					      PAIRWISE_KEYIDX,
-					      CAM_PAIRWISE_KEY_POSITION,
-					      enc_algo,
-					      CAM_CONFIG_NO_USEDK,
-					      rtlpriv->sec.key_buf[id]);
-		}
-
-		rtl_cam_add_one_entry(hw, macaddr, key, id, enc_algo,
-				      CAM_CONFIG_NO_USEDK,
-				      rtlpriv->sec.key_buf[id]);
-	}
 }
 
-void rtl88ee_set_key(struct ieee80211_hw *hw, u32 key,
-		     u8 *mac_ad, bool is_group, u8 enc_algo,
+void rtl88ee_set_key(struct ieee80211_hw *hw, u32 key_index,
+		     u8 *p_macaddr, bool is_group, u8 enc_algo,
 		     bool is_wepkey, bool clear_all)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	u8 *macaddr = mac_ad;
-	u32 id = 0;
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u8 *macaddr = p_macaddr;
+	u32 entry_id = 0;
 	bool is_pairwise = false;
-
 	static u8 cam_const_addr[4][6] = {
 		{0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
 		{0x00, 0x00, 0x00, 0x00, 0x00, 0x01},
@@ -2373,122 +2412,176 @@ void rtl88ee_set_key(struct ieee80211_hw *hw, u32 key,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case not process\n");
 			enc_algo = CAM_TKIP;
 			break;
 		}
 
 		if (is_wepkey || rtlpriv->sec.use_defaultkey) {
-			macaddr = cam_const_addr[key];
-			id = key;
+			macaddr = cam_const_addr[key_index];
+			entry_id = key_index;
 		} else {
 			if (is_group) {
 				macaddr = cam_const_broad;
-				id = key;
+				entry_id = key_index;
 			} else {
 				if (mac->opmode == NL80211_IFTYPE_AP ||
 				    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
-					id = rtl_cam_get_free_entry(hw, mac_ad);
-					if (id >=  TOTAL_CAM_ENTRY) {
+					entry_id =
+					  rtl_cam_get_free_entry(hw, p_macaddr);
+					if (entry_id >=  TOTAL_CAM_ENTRY) {
 						RT_TRACE(rtlpriv, COMP_SEC,
 							 DBG_EMERG,
 							 "Can not find free hw security cam entry\n");
 						return;
 					}
 				} else {
-					id = CAM_PAIRWISE_KEY_POSITION;
+					entry_id = CAM_PAIRWISE_KEY_POSITION;
 				}
-
-				key = PAIRWISE_KEYIDX;
+				key_index = PAIRWISE_KEYIDX;
 				is_pairwise = true;
 			}
 		}
 
-		if (rtlpriv->sec.key_len[key] == 0) {
+		if (rtlpriv->sec.key_len[key_index] == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 "delete one entry, id is %d\n", id);
+				 "delete one entry, entry_id is %d\n",
+				 entry_id);
 			if (mac->opmode == NL80211_IFTYPE_AP ||
-			    mac->opmode == NL80211_IFTYPE_MESH_POINT)
-				rtl_cam_del_entry(hw, mac_ad);
-			rtl_cam_delete_one_entry(hw, mac_ad, id);
+				mac->opmode == NL80211_IFTYPE_MESH_POINT)
+				rtl_cam_del_entry(hw, p_macaddr);
+			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
-			add_one_key(hw, macaddr, mac, key, id, enc_algo,
-				    is_pairwise);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+				 "add one entry\n");
+			if (is_pairwise) {
+				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+					 "set Pairwise key\n");
+
+				rtl_cam_add_one_entry(hw, macaddr, key_index,
+						      entry_id, enc_algo,
+						      CAM_CONFIG_NO_USEDK,
+						      rtlpriv->sec.key_buf[key_index]);
+			} else {
+				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+					 "set group key\n");
+
+				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
+					rtl_cam_add_one_entry(hw,
+							rtlefuse->dev_addr,
+							PAIRWISE_KEYIDX,
+							CAM_PAIRWISE_KEY_POSITION,
+							enc_algo,
+							CAM_CONFIG_NO_USEDK,
+							rtlpriv->sec.key_buf
+							[entry_id]);
+				}
+
+				rtl_cam_add_one_entry(hw, macaddr, key_index,
+						      entry_id, enc_algo,
+						      CAM_CONFIG_NO_USEDK,
+						      rtlpriv->sec.key_buf[entry_id]);
+			}
+
 		}
 	}
 }
 
 static void rtl8188ee_bt_var_init(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rppriv = rtl_pcipriv(hw);
-	struct bt_coexist_info coexist = rppriv->bt_coexist;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	coexist.bt_coexistence = rppriv->bt_coexist.eeprom_bt_coexist;
-	coexist.bt_ant_num = coexist.eeprom_bt_ant_num;
-	coexist.bt_coexist_type = coexist.eeprom_bt_type;
+	rtlpriv->btcoexist.bt_coexistence =
+		rtlpriv->btcoexist.eeprom_bt_coexist;
+	rtlpriv->btcoexist.bt_ant_num = rtlpriv->btcoexist.eeprom_bt_ant_num;
+	rtlpriv->btcoexist.bt_coexist_type = rtlpriv->btcoexist.eeprom_bt_type;
 
-	if (coexist.reg_bt_iso == 2)
-		coexist.bt_ant_isolation = coexist.eeprom_bt_ant_isol;
+	if (rtlpriv->btcoexist.reg_bt_iso == 2)
+		rtlpriv->btcoexist.bt_ant_isolation =
+				rtlpriv->btcoexist.eeprom_bt_ant_isol;
 	else
-		coexist.bt_ant_isolation = coexist.reg_bt_iso;
-
-	coexist.bt_radio_shared_type = coexist.eeprom_bt_radio_shared;
-
-	if (coexist.bt_coexistence) {
-		if (coexist.reg_bt_sco == 1)
-			coexist.bt_service = BT_OTHER_ACTION;
-		else if (coexist.reg_bt_sco == 2)
-			coexist.bt_service = BT_SCO;
-		else if (coexist.reg_bt_sco == 4)
-			coexist.bt_service = BT_BUSY;
-		else if (coexist.reg_bt_sco == 5)
-			coexist.bt_service = BT_OTHERBUSY;
+		rtlpriv->btcoexist.bt_ant_isolation =
+				rtlpriv->btcoexist.reg_bt_iso;
+
+	rtlpriv->btcoexist.bt_radio_shared_type =
+		rtlpriv->btcoexist.eeprom_bt_radio_shared;
+
+	if (rtlpriv->btcoexist.bt_coexistence) {
+		if (rtlpriv->btcoexist.reg_bt_sco == 1)
+			rtlpriv->btcoexist.bt_service = BT_OTHER_ACTION;
+		else if (rtlpriv->btcoexist.reg_bt_sco == 2)
+			rtlpriv->btcoexist.bt_service = BT_SCO;
+		else if (rtlpriv->btcoexist.reg_bt_sco == 4)
+			rtlpriv->btcoexist.bt_service = BT_BUSY;
+		else if (rtlpriv->btcoexist.reg_bt_sco == 5)
+			rtlpriv->btcoexist.bt_service = BT_OTHERBUSY;
 		else
-			coexist.bt_service = BT_IDLE;
+			rtlpriv->btcoexist.bt_service = BT_IDLE;
 
-		coexist.bt_edca_ul = 0;
-		coexist.bt_edca_dl = 0;
-		coexist.bt_rssi_state = 0xff;
+		rtlpriv->btcoexist.bt_edca_ul = 0;
+		rtlpriv->btcoexist.bt_edca_dl = 0;
+		rtlpriv->btcoexist.bt_rssi_state = 0xff;
 	}
 }
 
 void rtl8188ee_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
 					      bool auto_load_fail, u8 *hwinfo)
 {
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 value;
+
+	if (!auto_load_fail) {
+		rtlpriv->btcoexist.eeprom_bt_coexist =
+			((hwinfo[EEPROM_RF_FEATURE_OPTION_88E] & 0xe0) >> 5);
+		if (hwinfo[EEPROM_RF_FEATURE_OPTION_88E] == 0xFF)
+			rtlpriv->btcoexist.eeprom_bt_coexist  = 0;
+		value = hwinfo[EEPROM_RF_BT_SETTING_88E];
+		rtlpriv->btcoexist.eeprom_bt_type = ((value & 0xe) >> 1);
+		rtlpriv->btcoexist.eeprom_bt_ant_num = (value & 0x1);
+		rtlpriv->btcoexist.eeprom_bt_ant_isol = ((value & 0x10) >> 4);
+		rtlpriv->btcoexist.eeprom_bt_radio_shared =
+				 ((value & 0x20) >> 5);
+	} else {
+		rtlpriv->btcoexist.eeprom_bt_coexist = 0;
+		rtlpriv->btcoexist.eeprom_bt_type = BT_2WIRE;
+		rtlpriv->btcoexist.eeprom_bt_ant_num = ANT_X2;
+		rtlpriv->btcoexist.eeprom_bt_ant_isol = 0;
+		rtlpriv->btcoexist.eeprom_bt_radio_shared = BT_RADIO_SHARED;
+	}
+
 	rtl8188ee_bt_var_init(hw);
 }
 
 void rtl8188ee_bt_reg_init(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rppriv = rtl_pcipriv(hw);
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	/* 0:Low, 1:High, 2:From Efuse. */
-	rppriv->bt_coexist.reg_bt_iso = 2;
+	rtlpriv->btcoexist.reg_bt_iso = 2;
 	/* 0:Idle, 1:None-SCO, 2:SCO, 3:From Counter. */
-	rppriv->bt_coexist.reg_bt_sco = 3;
+	rtlpriv->btcoexist.reg_bt_sco = 3;
 	/* 0:Disable BT control A-MPDU, 1:Enable BT control A-MPDU. */
-	rppriv->bt_coexist.reg_bt_sco = 0;
+	rtlpriv->btcoexist.reg_bt_sco = 0;
 }
 
 void rtl8188ee_bt_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct rtl_pci_priv *rppriv = rtl_pcipriv(hw);
-	struct bt_coexist_info coexist = rppriv->bt_coexist;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u8 u1_tmp;
 
-	if (coexist.bt_coexistence &&
-	    ((coexist.bt_coexist_type == BT_CSR_BC4) ||
-	      coexist.bt_coexist_type == BT_CSR_BC8)) {
-		if (coexist.bt_ant_isolation)
+	if (rtlpriv->btcoexist.bt_coexistence &&
+	    ((rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4) ||
+	      rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC8)) {
+		if (rtlpriv->btcoexist.bt_ant_isolation)
 			rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG, 0xa0);
 
 		u1_tmp = rtl_read_byte(rtlpriv, 0x4fd) &
-				       BIT_OFFSET_LEN_MASK_32(0, 1);
-		u1_tmp = u1_tmp | ((coexist.bt_ant_isolation == 1) ?
+			 BIT_OFFSET_LEN_MASK_32(0, 1);
+		u1_tmp = u1_tmp |
+			 ((rtlpriv->btcoexist.bt_ant_isolation == 1) ?
 			 0 : BIT_OFFSET_LEN_MASK_32(1, 1)) |
-			 ((coexist.bt_service == BT_SCO) ?
+			 ((rtlpriv->btcoexist.bt_service == BT_SCO) ?
 			 0 : BIT_OFFSET_LEN_MASK_32(2, 1));
 		rtl_write_byte(rtlpriv, 0x4fd, u1_tmp);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/led.c b/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
index c81a9cb..b504bd0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/led.c
@@ -32,8 +32,8 @@
 #include "reg.h"
 #include "led.h"
 
-static void rtl88ee_init_led(struct ieee80211_hw *hw,
-			     struct rtl_led *pled, enum rtl_led_pin ledpin)
+static void _rtl88ee_init_led(struct ieee80211_hw *hw,
+			      struct rtl_led *pled, enum rtl_led_pin ledpin)
 {
 	pled->hw = hw;
 	pled->ledpin = ledpin;
@@ -46,23 +46,23 @@ void rtl88ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 "LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin);
+		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
 
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
 		break;
 	case LED_PIN_LED0:
 		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
-		rtl_write_byte(rtlpriv, REG_LEDCFG2,
-			       (ledcfg & 0xf0) | BIT(5) | BIT(6));
+		rtl_write_byte(rtlpriv,
+			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5) | BIT(6));
 		break;
 	case LED_PIN_LED1:
 		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
 		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg & 0x10);
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
 		break;
 	}
 	pled->ledon = true;
@@ -73,10 +73,9 @@ void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	u8 ledcfg;
-	u8 val;
 
 	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 "LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin);
+		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
 
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
@@ -84,15 +83,15 @@ void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	case LED_PIN_LED0:
 		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 		ledcfg &= 0xf0;
-		val = ledcfg | BIT(3) | BIT(5) | BIT(6);
-		if (pcipriv->ledctl.led_opendrain == true) {
-			rtl_write_byte(rtlpriv, REG_LEDCFG2, val);
+		if (pcipriv->ledctl.led_opendrain) {
+			rtl_write_byte(rtlpriv, REG_LEDCFG2,
+				       (ledcfg | BIT(3) | BIT(5) | BIT(6)));
 			ledcfg = rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
-			val = ledcfg & 0xFE;
-			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG, val);
-		} else {
-			rtl_write_byte(rtlpriv, REG_LEDCFG2, val);
-		}
+			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG,
+				       (ledcfg & 0xFE));
+		} else
+			rtl_write_byte(rtlpriv, REG_LEDCFG2,
+				       (ledcfg | BIT(3) | BIT(5) | BIT(6)));
 		break;
 	case LED_PIN_LED1:
 		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
@@ -100,8 +99,8 @@ void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		rtl_write_byte(rtlpriv, REG_LEDCFG1, (ledcfg | BIT(3)));
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
 		break;
 	}
 	pled->ledon = false;
@@ -110,17 +109,15 @@ void rtl88ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 void rtl88ee_init_sw_leds(struct ieee80211_hw *hw)
 {
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
-
-	rtl88ee_init_led(hw, &(pcipriv->ledctl.sw_led0), LED_PIN_LED0);
-	rtl88ee_init_led(hw, &(pcipriv->ledctl.sw_led1), LED_PIN_LED1);
+	_rtl88ee_init_led(hw, &pcipriv->ledctl.sw_led0, LED_PIN_LED0);
+	_rtl88ee_init_led(hw, &pcipriv->ledctl.sw_led1, LED_PIN_LED1);
 }
 
-static void rtl88ee_sw_led_control(struct ieee80211_hw *hw,
+static void _rtl88ee_sw_led_control(struct ieee80211_hw *hw,
 				    enum led_ctl_mode ledaction)
 {
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
-
 	switch (ledaction) {
 	case LED_CTL_POWER_ON:
 	case LED_CTL_LINK:
@@ -152,6 +149,6 @@ void rtl88ee_led_control(struct ieee80211_hw *hw,
 		return;
 	}
 	RT_TRACE(rtlpriv, COMP_LED, DBG_TRACE, "ledaction %d,\n",
-		 ledaction);
-	rtl88ee_sw_led_control(hw, ledaction);
+				ledaction);
+	_rtl88ee_sw_led_control(hw, ledaction);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/led.h b/drivers/net/wireless/rtlwifi/rtl8188ee/led.h
index 4073f6f..4b325b7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/led.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/led.h
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
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
index 1cd6c16..3f6c59c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
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
@@ -29,7 +25,6 @@
 
 #include "../wifi.h"
 #include "../pci.h"
-#include "../core.h"
 #include "../ps.h"
 #include "reg.h"
 #include "def.h"
@@ -38,443 +33,32 @@
 #include "dm.h"
 #include "table.h"
 
-static void set_baseband_phy_config(struct ieee80211_hw *hw);
-static void set_baseband_agc_config(struct ieee80211_hw *hw);
-static void store_pwrindex_offset(struct ieee80211_hw *hw,
-				  u32 regaddr, u32 bitmask,
-				  u32 data);
-static bool check_cond(struct ieee80211_hw *hw, const u32  condition);
-
-static u32 rf_serial_read(struct ieee80211_hw *hw,
-			  enum radio_path rfpath, u32 offset)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct bb_reg_def *phreg = &rtlphy->phyreg_def[rfpath];
-	u32 newoffset;
-	u32 tmplong, tmplong2;
-	u8 rfpi_enable = 0;
-	u32 ret;
-	int jj = RF90_PATH_A;
-	int kk = RF90_PATH_B;
-
-	offset &= 0xff;
-	newoffset = offset;
-	if (RT_CANNOT_IO(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "return all one\n");
-		return 0xFFFFFFFF;
-	}
-	tmplong = rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD);
-	if (rfpath == jj)
-		tmplong2 = tmplong;
-	else
-		tmplong2 = rtl_get_bbreg(hw, phreg->rfhssi_para2, MASKDWORD);
-	tmplong2 = (tmplong2 & (~BLSSIREADADDRESS)) |
-	    (newoffset << 23) | BLSSIREADEDGE;
-	rtl_set_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD,
-		      tmplong & (~BLSSIREADEDGE));
-	mdelay(1);
-	rtl_set_bbreg(hw, phreg->rfhssi_para2, MASKDWORD, tmplong2);
-	mdelay(2);
-	if (rfpath == jj)
-		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
-						 BIT(8));
-	else if (rfpath == kk)
-		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
-						 BIT(8));
-	if (rfpi_enable)
-		ret = rtl_get_bbreg(hw, phreg->rf_rbpi, BLSSIREADBACKDATA);
-	else
-		ret = rtl_get_bbreg(hw, phreg->rf_rb, BLSSIREADBACKDATA);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x]= 0x%x\n",
-		 rfpath, phreg->rf_rb, ret);
-	return ret;
-}
-
-static void rf_serial_write(struct ieee80211_hw *hw,
-			    enum radio_path rfpath, u32 offset,
-			    u32 data)
-{
-	u32 data_and_addr;
-	u32 newoffset;
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct bb_reg_def *phreg = &rtlphy->phyreg_def[rfpath];
-
-	if (RT_CANNOT_IO(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "stop\n");
-		return;
-	}
-	offset &= 0xff;
-	newoffset = offset;
-	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
-	rtl_set_bbreg(hw, phreg->rf3wire_offset, MASKDWORD, data_and_addr);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFW-%d Addr[0x%x]= 0x%x\n",
-		 rfpath, phreg->rf3wire_offset, data_and_addr);
-}
-
-static u32 cal_bit_shift(u32 bitmask)
-{
-	u32 i;
-
-	for (i = 0; i <= 31; i++) {
-		if (((bitmask >> i) & 0x1) == 1)
-			break;
-	}
-	return i;
-}
-
-static bool config_bb_with_header(struct ieee80211_hw *hw,
-				  u8 configtype)
-{
-	if (configtype == BASEBAND_CONFIG_PHY_REG)
-		set_baseband_phy_config(hw);
-	else if (configtype == BASEBAND_CONFIG_AGC_TAB)
-		set_baseband_agc_config(hw);
-	return true;
-}
-
-static bool config_bb_with_pgheader(struct ieee80211_hw *hw,
-				    u8 configtype)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	int i;
-	u32 *table_pg;
-	u16 tbl_page_len;
-	u32 v1 = 0, v2 = 0;
-
-	tbl_page_len = RTL8188EEPHY_REG_ARRAY_PGLEN;
-	table_pg = RTL8188EEPHY_REG_ARRAY_PG;
-
-	if (configtype == BASEBAND_CONFIG_PHY_REG) {
-		for (i = 0; i < tbl_page_len; i = i + 3) {
-			v1 = table_pg[i];
-			v2 = table_pg[i + 1];
-
-			if (v1 < 0xcdcdcdcd) {
-				rtl_addr_delay(table_pg[i]);
-
-				store_pwrindex_offset(hw, table_pg[i],
-						      table_pg[i + 1],
-						      table_pg[i + 2]);
-				continue;
-			} else {
-				if (!check_cond(hw, table_pg[i])) {
-					/*don't need the hw_body*/
-					i += 2; /* skip the pair of expression*/
-					v1 = table_pg[i];
-					v2 = table_pg[i + 1];
-					while (v2 != 0xDEAD) {
-						i += 3;
-						v1 = table_pg[i];
-						v2 = table_pg[i + 1];
-					}
-				}
-			}
-		}
-	} else {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 "configtype != BaseBand_Config_PHY_REG\n");
-	}
-	return true;
-}
-
-static bool config_parafile(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct rtl_efuse *fuse = rtl_efuse(rtl_priv(hw));
-	bool rtstatus;
-
-	rtstatus = config_bb_with_header(hw, BASEBAND_CONFIG_PHY_REG);
-	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
-		return false;
-	}
-
-	if (fuse->autoload_failflag == false) {
-		rtlphy->pwrgroup_cnt = 0;
-		rtstatus = config_bb_with_pgheader(hw, BASEBAND_CONFIG_PHY_REG);
-	}
-	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
-		return false;
-	}
-	rtstatus = config_bb_with_header(hw, BASEBAND_CONFIG_AGC_TAB);
-	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
-		return false;
-	}
-	rtlphy->cck_high_power = (bool) (rtl_get_bbreg(hw,
-				 RFPGA0_XA_HSSIPARAMETER2, 0x200));
-
-	return true;
-}
-
-static void rtl88e_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	int jj = RF90_PATH_A;
-	int kk = RF90_PATH_B;
-
-	rtlphy->phyreg_def[jj].rfintfs = RFPGA0_XAB_RFINTERFACESW;
-	rtlphy->phyreg_def[kk].rfintfs = RFPGA0_XAB_RFINTERFACESW;
-	rtlphy->phyreg_def[RF90_PATH_C].rfintfs = RFPGA0_XCD_RFINTERFACESW;
-	rtlphy->phyreg_def[RF90_PATH_D].rfintfs = RFPGA0_XCD_RFINTERFACESW;
-
-	rtlphy->phyreg_def[jj].rfintfi = RFPGA0_XAB_RFINTERFACERB;
-	rtlphy->phyreg_def[kk].rfintfi = RFPGA0_XAB_RFINTERFACERB;
-	rtlphy->phyreg_def[RF90_PATH_C].rfintfi = RFPGA0_XCD_RFINTERFACERB;
-	rtlphy->phyreg_def[RF90_PATH_D].rfintfi = RFPGA0_XCD_RFINTERFACERB;
-
-	rtlphy->phyreg_def[jj].rfintfo = RFPGA0_XA_RFINTERFACEOE;
-	rtlphy->phyreg_def[kk].rfintfo = RFPGA0_XB_RFINTERFACEOE;
-
-	rtlphy->phyreg_def[jj].rfintfe = RFPGA0_XA_RFINTERFACEOE;
-	rtlphy->phyreg_def[kk].rfintfe = RFPGA0_XB_RFINTERFACEOE;
-
-	rtlphy->phyreg_def[jj].rf3wire_offset = RFPGA0_XA_LSSIPARAMETER;
-	rtlphy->phyreg_def[kk].rf3wire_offset = RFPGA0_XB_LSSIPARAMETER;
-
-	rtlphy->phyreg_def[jj].rflssi_select = rFPGA0_XAB_RFPARAMETER;
-	rtlphy->phyreg_def[kk].rflssi_select = rFPGA0_XAB_RFPARAMETER;
-	rtlphy->phyreg_def[RF90_PATH_C].rflssi_select = rFPGA0_XCD_RFPARAMETER;
-	rtlphy->phyreg_def[RF90_PATH_D].rflssi_select = rFPGA0_XCD_RFPARAMETER;
-
-	rtlphy->phyreg_def[jj].rftxgain_stage = RFPGA0_TXGAINSTAGE;
-	rtlphy->phyreg_def[kk].rftxgain_stage = RFPGA0_TXGAINSTAGE;
-	rtlphy->phyreg_def[RF90_PATH_C].rftxgain_stage = RFPGA0_TXGAINSTAGE;
-	rtlphy->phyreg_def[RF90_PATH_D].rftxgain_stage = RFPGA0_TXGAINSTAGE;
-
-	rtlphy->phyreg_def[jj].rfhssi_para1 = RFPGA0_XA_HSSIPARAMETER1;
-	rtlphy->phyreg_def[kk].rfhssi_para1 = RFPGA0_XB_HSSIPARAMETER1;
-
-	rtlphy->phyreg_def[jj].rfhssi_para2 = RFPGA0_XA_HSSIPARAMETER2;
-	rtlphy->phyreg_def[kk].rfhssi_para2 = RFPGA0_XB_HSSIPARAMETER2;
-
-	rtlphy->phyreg_def[jj].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[kk].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_C].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_D].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
-
-	rtlphy->phyreg_def[jj].rfagc_control1 = ROFDM0_XAAGCCORE1;
-	rtlphy->phyreg_def[kk].rfagc_control1 = ROFDM0_XBAGCCORE1;
-	rtlphy->phyreg_def[RF90_PATH_C].rfagc_control1 = ROFDM0_XCAGCCORE1;
-	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control1 = ROFDM0_XDAGCCORE1;
-
-	rtlphy->phyreg_def[jj].rfagc_control2 = ROFDM0_XAAGCCORE2;
-	rtlphy->phyreg_def[kk].rfagc_control2 = ROFDM0_XBAGCCORE2;
-	rtlphy->phyreg_def[RF90_PATH_C].rfagc_control2 = ROFDM0_XCAGCCORE2;
-	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control2 = ROFDM0_XDAGCCORE2;
-
-	rtlphy->phyreg_def[jj].rfrxiq_imbal = ROFDM0_XARXIQIMBAL;
-	rtlphy->phyreg_def[kk].rfrxiq_imbal = ROFDM0_XBRXIQIMBAL;
-	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbal = ROFDM0_XCRXIQIMBAL;
-	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbal = ROFDM0_XDRXIQIMBAL;
-
-	rtlphy->phyreg_def[jj].rfrx_afe = ROFDM0_XARXAFE;
-	rtlphy->phyreg_def[kk].rfrx_afe = ROFDM0_XBRXAFE;
-	rtlphy->phyreg_def[RF90_PATH_C].rfrx_afe = ROFDM0_XCRXAFE;
-	rtlphy->phyreg_def[RF90_PATH_D].rfrx_afe = ROFDM0_XDRXAFE;
-
-	rtlphy->phyreg_def[jj].rftxiq_imbal = ROFDM0_XATXIQIMBAL;
-	rtlphy->phyreg_def[kk].rftxiq_imbal = ROFDM0_XBTXIQIMBAL;
-	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbal = ROFDM0_XCTXIQIMBAL;
-	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbal = ROFDM0_XDTXIQIMBAL;
-
-	rtlphy->phyreg_def[jj].rftx_afe = ROFDM0_XATXAFE;
-	rtlphy->phyreg_def[kk].rftx_afe = ROFDM0_XBTXAFE;
-
-	rtlphy->phyreg_def[jj].rf_rb = RFPGA0_XA_LSSIREADBACK;
-	rtlphy->phyreg_def[kk].rf_rb = RFPGA0_XB_LSSIREADBACK;
-
-	rtlphy->phyreg_def[jj].rf_rbpi = TRANSCEIVEA_HSPI_READBACK;
-	rtlphy->phyreg_def[kk].rf_rbpi = TRANSCEIVEB_HSPI_READBACK;
-}
-
-static bool rtl88e_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
-					    u32 cmdtableidx, u32 cmdtablesz,
-					    enum swchnlcmd_id cmdid,
-					    u32 para1, u32 para2, u32 msdelay)
-{
-	struct swchnlcmd *pcmd;
-
-	if (cmdtable == NULL) {
-		RT_ASSERT(false, "cmdtable cannot be NULL.\n");
-		return false;
-	}
-
-	if (cmdtableidx >= cmdtablesz)
-		return false;
-
-	pcmd = cmdtable + cmdtableidx;
-	pcmd->cmdid = cmdid;
-	pcmd->para1 = para1;
-	pcmd->para2 = para2;
-	pcmd->msdelay = msdelay;
-	return true;
-}
-
-static bool chnl_step_by_step(struct ieee80211_hw *hw,
-			      u8 channel, u8 *stage, u8 *step,
-			      u32 *delay)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct swchnlcmd precommoncmd[MAX_PRECMD_CNT];
-	u32 precommoncmdcnt;
-	struct swchnlcmd postcommoncmd[MAX_POSTCMD_CNT];
-	u32 postcommoncmdcnt;
-	struct swchnlcmd rfdependcmd[MAX_RFDEPENDCMD_CNT];
-	u32 rfdependcmdcnt;
-	struct swchnlcmd *currentcmd = NULL;
-	u8 rfpath;
-	u8 num_total_rfpath = rtlphy->num_total_rfpath;
-
-	precommoncmdcnt = 0;
-	rtl88e_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
-					MAX_PRECMD_CNT,
-					CMDID_SET_TXPOWEROWER_LEVEL, 0, 0, 0);
-	rtl88e_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
-					MAX_PRECMD_CNT, CMDID_END, 0, 0, 0);
-
-	postcommoncmdcnt = 0;
-
-	rtl88e_phy_set_sw_chnl_cmdarray(postcommoncmd, postcommoncmdcnt++,
-					MAX_POSTCMD_CNT, CMDID_END, 0, 0, 0);
-
-	rfdependcmdcnt = 0;
-
-	RT_ASSERT((channel >= 1 && channel <= 14),
-		  "illegal channel for Zebra: %d\n", channel);
-
-	rtl88e_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
-					MAX_RFDEPENDCMD_CNT, CMDID_RF_WRITEREG,
-					RF_CHNLBW, channel, 10);
-
-	rtl88e_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
-					MAX_RFDEPENDCMD_CNT, CMDID_END, 0, 0,
-					 0);
-
-	do {
-		switch (*stage) {
-		case 0:
-			currentcmd = &precommoncmd[*step];
-			break;
-		case 1:
-			currentcmd = &rfdependcmd[*step];
-			break;
-		case 2:
-			currentcmd = &postcommoncmd[*step];
-			break;
-		}
-
-		if (currentcmd->cmdid == CMDID_END) {
-			if ((*stage) == 2) {
-				return true;
-			} else {
-				(*stage)++;
-				(*step) = 0;
-				continue;
-			}
-		}
-
-		switch (currentcmd->cmdid) {
-		case CMDID_SET_TXPOWEROWER_LEVEL:
-			rtl88e_phy_set_txpower_level(hw, channel);
-			break;
-		case CMDID_WRITEPORT_ULONG:
-			rtl_write_dword(rtlpriv, currentcmd->para1,
-					currentcmd->para2);
-			break;
-		case CMDID_WRITEPORT_USHORT:
-			rtl_write_word(rtlpriv, currentcmd->para1,
-				       (u16) currentcmd->para2);
-			break;
-		case CMDID_WRITEPORT_UCHAR:
-			rtl_write_byte(rtlpriv, currentcmd->para1,
-				       (u8) currentcmd->para2);
-			break;
-		case CMDID_RF_WRITEREG:
-			for (rfpath = 0; rfpath < num_total_rfpath; rfpath++) {
-				rtlphy->rfreg_chnlval[rfpath] =
-				    ((rtlphy->rfreg_chnlval[rfpath] &
-				      0xfffffc00) | currentcmd->para2);
-
-				rtl_set_rfreg(hw, (enum radio_path)rfpath,
-					      currentcmd->para1,
-					      RFREG_OFFSET_MASK,
-					      rtlphy->rfreg_chnlval[rfpath]);
-			}
-			break;
-		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
-			break;
-		}
-
-		break;
-	} while (true);
-
-	(*delay) = currentcmd->msdelay;
-	(*step)++;
-	return false;
-}
-
-static long rtl88e_pwr_idx_dbm(struct ieee80211_hw *hw,
-			       enum wireless_mode wirelessmode,
-			       u8 txpwridx)
-{
-	long offset;
-	long pwrout_dbm;
-
-	switch (wirelessmode) {
-	case WIRELESS_MODE_B:
-		offset = -7;
-		break;
-	case WIRELESS_MODE_G:
-	case WIRELESS_MODE_N_24G:
-		offset = -8;
-		break;
-	default:
-		offset = -8;
-		break;
-	}
-	pwrout_dbm = txpwridx / 2 + offset;
-	return pwrout_dbm;
-}
-
-static void rtl88e_phy_set_io(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
-
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
-		 rtlphy->current_io_type, rtlphy->set_io_inprogress);
-	switch (rtlphy->current_io_type) {
-	case IO_CMD_RESUME_DM_BY_SCAN:
-		dm_digtable->cur_igvalue = rtlphy->initgain_backup.xaagccore1;
-		/*rtl92c_dm_write_dig(hw);*/
-		rtl88e_phy_set_txpower_level(hw, rtlphy->current_channel);
-		rtl_set_bbreg(hw, RCCK0_CCA, 0xff0000, 0x83);
-		break;
-	case IO_CMD_PAUSE_DM_BY_SCAN:
-		rtlphy->initgain_backup.xaagccore1 = dm_digtable->cur_igvalue;
-		dm_digtable->cur_igvalue = 0x17;
-		rtl_set_bbreg(hw, RCCK0_CCA, 0xff0000, 0x40);
-		break;
-	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
-		break;
-	}
-	rtlphy->set_io_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 "(%#x)\n", rtlphy->current_io_type);
-}
+static u32 _rtl88e_phy_rf_serial_read(struct ieee80211_hw *hw,
+				      enum radio_path rfpath, u32 offset);
+static void _rtl88e_phy_rf_serial_write(struct ieee80211_hw *hw,
+					enum radio_path rfpath, u32 offset,
+					u32 data);
+static u32 _rtl88e_phy_calculate_bit_shift(u32 bitmask);
+static bool _rtl88e_phy_bb8188e_config_parafile(struct ieee80211_hw *hw);
+static bool _rtl88e_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
+static bool phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+					  u8 configtype);
+static bool phy_config_bb_with_pghdr(struct ieee80211_hw *hw,
+				     u8 configtype);
+static void _rtl88e_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw);
+static bool _rtl88e_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
+					     u32 cmdtableidx, u32 cmdtablesz,
+					     enum swchnlcmd_id cmdid, u32 para1,
+					     u32 para2, u32 msdelay);
+static bool _rtl88e_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+					     u8 channel, u8 *stage, u8 *step,
+					     u32 *delay);
+
+static long _rtl88e_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+					 enum wireless_mode wirelessmode,
+					 u8 txpwridx);
+static void rtl88ee_phy_set_rf_on(struct ieee80211_hw *hw);
+static void rtl88e_phy_set_io(struct ieee80211_hw *hw);
 
 u32 rtl88e_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 {
@@ -484,14 +68,15 @@ u32 rtl88e_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), bitmask(%#x)\n", regaddr, bitmask);
 	originalvalue = rtl_read_dword(rtlpriv, regaddr);
-	bitshift = cal_bit_shift(bitmask);
+	bitshift = _rtl88e_phy_calculate_bit_shift(bitmask);
 	returnvalue = (originalvalue & bitmask) >> bitshift;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "BBR MASK = 0x%x Addr[0x%x]= 0x%x\n", bitmask,
+		 "BBR MASK=0x%x Addr[0x%x]=0x%x\n", bitmask,
 		 regaddr, originalvalue);
 
 	return returnvalue;
+
 }
 
 void rtl88e_phy_set_bb_reg(struct ieee80211_hw *hw,
@@ -501,12 +86,12 @@ void rtl88e_phy_set_bb_reg(struct ieee80211_hw *hw,
 	u32 originalvalue, bitshift;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "regaddr(%#x), bitmask(%#x),data(%#x)\n",
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
 		 regaddr, bitmask, data);
 
 	if (bitmask != MASKDWORD) {
 		originalvalue = rtl_read_dword(rtlpriv, regaddr);
-		bitshift = cal_bit_shift(bitmask);
+		bitshift = _rtl88e_phy_calculate_bit_shift(bitmask);
 		data = ((originalvalue & (~bitmask)) | (data << bitshift));
 	}
 
@@ -531,8 +116,8 @@ u32 rtl88e_phy_query_rf_reg(struct ieee80211_hw *hw,
 	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
 
 
-	original_value = rf_serial_read(hw, rfpath, regaddr);
-	bitshift = cal_bit_shift(bitmask);
+	original_value = _rtl88e_phy_rf_serial_read(hw, rfpath, regaddr);
+	bitshift = _rtl88e_phy_calculate_bit_shift(bitmask);
 	readback_value = (original_value & bitmask) >> bitshift;
 
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
@@ -540,7 +125,6 @@ u32 rtl88e_phy_query_rf_reg(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
 		  regaddr, rfpath, bitmask, original_value);
-
 	return readback_value;
 }
 
@@ -559,13 +143,16 @@ void rtl88e_phy_set_rf_reg(struct ieee80211_hw *hw,
 	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
 
 	if (bitmask != RFREG_OFFSET_MASK) {
-			original_value = rf_serial_read(hw, rfpath, regaddr);
-			bitshift = cal_bit_shift(bitmask);
-			data = ((original_value & (~bitmask)) |
-				(data << bitshift));
+			original_value = _rtl88e_phy_rf_serial_read(hw,
+								    rfpath,
+								    regaddr);
+			bitshift = _rtl88e_phy_calculate_bit_shift(bitmask);
+			data =
+			    ((original_value & (~bitmask)) |
+			     (data << bitshift));
 		}
 
-	rf_serial_write(hw, rfpath, regaddr, data);
+	_rtl88e_phy_rf_serial_write(hw, rfpath, regaddr, data);
 
 
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
@@ -575,27 +162,91 @@ void rtl88e_phy_set_rf_reg(struct ieee80211_hw *hw,
 		 regaddr, bitmask, data, rfpath);
 }
 
-static bool config_mac_with_header(struct ieee80211_hw *hw)
+static u32 _rtl88e_phy_rf_serial_read(struct ieee80211_hw *hw,
+				      enum radio_path rfpath, u32 offset)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
+	u32 newoffset;
+	u32 tmplong, tmplong2;
+	u8 rfpi_enable = 0;
+	u32 retvalue;
+
+	offset &= 0xff;
+	newoffset = offset;
+	if (RT_CANNOT_IO(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "return all one\n");
+		return 0xFFFFFFFF;
+	}
+	tmplong = rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD);
+	if (rfpath == RF90_PATH_A)
+		tmplong2 = tmplong;
+	else
+		tmplong2 = rtl_get_bbreg(hw, pphyreg->rfhssi_para2, MASKDWORD);
+	tmplong2 = (tmplong2 & (~BLSSIREADADDRESS)) |
+	    (newoffset << 23) | BLSSIREADEDGE;
+	rtl_set_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD,
+		      tmplong & (~BLSSIREADEDGE));
+	mdelay(1);
+	rtl_set_bbreg(hw, pphyreg->rfhssi_para2, MASKDWORD, tmplong2);
+	mdelay(2);
+	if (rfpath == RF90_PATH_A)
+		rfpi_enable = (u8)rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
+						BIT(8));
+	else if (rfpath == RF90_PATH_B)
+		rfpi_enable = (u8)rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
+						BIT(8));
+	if (rfpi_enable)
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rbpi,
+					 BLSSIREADBACKDATA);
+	else
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
+					 BLSSIREADBACKDATA);
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "RFR-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf_rb, retvalue);
+	return retvalue;
+}
+
+static void _rtl88e_phy_rf_serial_write(struct ieee80211_hw *hw,
+					enum radio_path rfpath, u32 offset,
+					u32 data)
 {
+	u32 data_and_addr;
+	u32 newoffset;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
+
+	if (RT_CANNOT_IO(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "stop\n");
+		return;
+	}
+	offset &= 0xff;
+	newoffset = offset;
+	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
+	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "RFW-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf3wire_offset, data_and_addr);
+}
+
+static u32 _rtl88e_phy_calculate_bit_shift(u32 bitmask)
+{
 	u32 i;
-	u32 arraylength;
-	u32 *ptrarray;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read Rtl8188EMACPHY_Array\n");
-	arraylength = RTL8188EEMAC_1T_ARRAYLEN;
-	ptrarray = RTL8188EEMAC_1T_ARRAY;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "Img:RTL8188EEMAC_1T_ARRAY LEN %d\n", arraylength);
-	for (i = 0; i < arraylength; i = i + 2)
-		rtl_write_byte(rtlpriv, ptrarray[i], (u8) ptrarray[i + 1]);
-	return true;
+	for (i = 0; i <= 31; i++) {
+		if (((bitmask >> i) & 0x1) == 1)
+			break;
+	}
+	return i;
 }
 
 bool rtl88e_phy_mac_config(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	bool rtstatus = config_mac_with_header(hw);
+	bool rtstatus = _rtl88e_phy_config_mac_with_headerfile(hw);
 
 	rtl_write_byte(rtlpriv, 0x04CA, 0x0B);
 	return rtstatus;
@@ -606,9 +257,9 @@ bool rtl88e_phy_bb_config(struct ieee80211_hw *hw)
 	bool rtstatus = true;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 regval;
-	u8 reg_hwparafile = 1;
+	u8 b_reg_hwparafile = 1;
 	u32 tmp;
-	rtl88e_phy_init_bb_rf_register_definition(hw);
+	_rtl88e_phy_init_bb_rf_register_definition(hw);
 	regval = rtl_read_word(rtlpriv, REG_SYS_FUNC_EN);
 	rtl_write_word(rtlpriv, REG_SYS_FUNC_EN,
 		       regval | BIT(13) | BIT(0) | BIT(1));
@@ -619,8 +270,8 @@ bool rtl88e_phy_bb_config(struct ieee80211_hw *hw)
 		       FEN_BB_GLB_RSTN | FEN_BBRSTB);
 	tmp = rtl_read_dword(rtlpriv, 0x4c);
 	rtl_write_dword(rtlpriv, 0x4c, tmp | BIT(23));
-	if (reg_hwparafile == 1)
-		rtstatus = config_parafile(hw);
+	if (b_reg_hwparafile == 1)
+		rtstatus = _rtl88e_phy_bb8188e_config_parafile(hw);
 	return rtstatus;
 }
 
@@ -629,12 +280,12 @@ bool rtl88e_phy_rf_config(struct ieee80211_hw *hw)
 	return rtl88e_phy_rf6052_config(hw);
 }
 
-static bool check_cond(struct ieee80211_hw *hw,
+static bool _rtl88e_check_condition(struct ieee80211_hw *hw,
 				    const u32  condition)
 {
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_efuse *fuse = rtl_efuse(rtl_priv(hw));
-	u32 _board = fuse->board_type; /*need efuse define*/
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u32 _board = rtlefuse->board_type; /*need efuse define*/
 	u32 _interface = rtlhal->interface;
 	u32 _platform = 0x08;/*SupportPlatform */
 	u32 cond = condition;
@@ -658,450 +309,811 @@ static bool check_cond(struct ieee80211_hw *hw,
 	return true;
 }
 
-static void _rtl8188e_config_rf_reg(struct ieee80211_hw *hw,
-				    u32 addr, u32 data, enum radio_path rfpath,
+static void _rtl8188e_config_rf_reg(struct ieee80211_hw *hw, u32 addr,
+				    u32 data, enum radio_path rfpath,
 				    u32 regaddr)
 {
-	rtl_rfreg_delay(hw, rfpath, regaddr,
-			RFREG_OFFSET_MASK,
-			data);
+	if (addr == 0xffe) {
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
+		rtl_set_rfreg(hw, rfpath, regaddr,
+			      RFREG_OFFSET_MASK,
+			      data);
+		udelay(1);
+	}
 }
 
-static void rtl88_config_s(struct ieee80211_hw *hw,
-	u32 addr, u32 data)
+static void _rtl8188e_config_rf_radio_a(struct ieee80211_hw *hw,
+					u32 addr, u32 data)
 {
 	u32 content = 0x1000; /*RF Content: radio_a_txt*/
 	u32 maskforphyset = (u32)(content & 0xE000);
 
 	_rtl8188e_config_rf_reg(hw, addr, data, RF90_PATH_A,
-				addr | maskforphyset);
+		addr | maskforphyset);
+}
+
+static void _rtl8188e_config_bb_reg(struct ieee80211_hw *hw,
+				    u32 addr, u32 data)
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
 
-#define NEXT_PAIR(v1, v2, i)				\
+static bool _rtl88e_phy_bb8188e_config_parafile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	bool rtstatus;
+
+	rtstatus = phy_config_bb_with_headerfile(hw, BASEBAND_CONFIG_PHY_REG);
+	if (!rtstatus) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		return false;
+	}
+
+	if (!rtlefuse->autoload_failflag) {
+		rtlphy->pwrgroup_cnt = 0;
+		rtstatus =
+		  phy_config_bb_with_pghdr(hw, BASEBAND_CONFIG_PHY_REG);
+	}
+	if (!rtstatus) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		return false;
+	}
+	rtstatus =
+	  phy_config_bb_with_headerfile(hw, BASEBAND_CONFIG_AGC_TAB);
+	if (!rtstatus) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
+		return false;
+	}
+	rtlphy->cck_high_power =
+	  (bool)(rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, 0x200));
+
+	return true;
+}
+
+static bool _rtl88e_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 i;
+	u32 arraylength;
+	u32 *ptrarray;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read Rtl8188EMACPHY_Array\n");
+	arraylength = RTL8188EEMAC_1T_ARRAYLEN;
+	ptrarray = RTL8188EEMAC_1T_ARRAY;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Img:RTL8188EEMAC_1T_ARRAY LEN %d\n", arraylength);
+	for (i = 0; i < arraylength; i = i + 2)
+		rtl_write_byte(rtlpriv, ptrarray[i], (u8)ptrarray[i + 1]);
+	return true;
+}
+
+#define READ_NEXT_PAIR(v1, v2, i)			\
 	do {						\
 		i += 2; v1 = array_table[i];		\
-		v2 = array_table[i + 1];		\
+		v2 = array_table[i+1];			\
 	} while (0)
 
-static void set_baseband_agc_config(struct ieee80211_hw *hw)
+static void handle_branch1(struct ieee80211_hw *hw, u16 arraylen,
+			   u32 *array_table)
 {
+	u32 v1;
+	u32 v2;
 	int i;
-	u32 *array_table;
-	u16 arraylen;
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 v1 = 0, v2 = 0;
 
-	arraylen = RTL8188EEAGCTAB_1TARRAYLEN;
-	array_table = RTL8188EEAGCTAB_1TARRAY;
+	for (i = 0; i < arraylen; i = i + 2) {
+		v1 = array_table[i];
+		v2 = array_table[i+1];
+		if (v1 < 0xcdcdcdcd) {
+			_rtl8188e_config_bb_reg(hw, v1, v2);
+		} else { /*This line is the start line of branch.*/
+			/* to protect READ_NEXT_PAIR not overrun */
+			if (i >= arraylen - 2)
+				break;
+
+			if (!_rtl88e_check_condition(hw, array_table[i])) {
+				/*Discard the following (offset, data) pairs*/
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 != 0xDEAD &&
+				       v2 != 0xCDEF &&
+				       v2 != 0xCDCD && i < arraylen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -= 2; /* prevent from for-loop += 2*/
+			} else { /* Configure matched pairs and skip
+				  * to end of if-else.
+				  */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 != 0xDEAD &&
+				       v2 != 0xCDEF &&
+				       v2 != 0xCDCD && i < arraylen - 2)
+					_rtl8188e_config_bb_reg(hw, v1, v2);
+					READ_NEXT_PAIR(v1, v2, i);
+
+				while (v2 != 0xDEAD && i < arraylen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+			}
+		}
+	}
+}
+
+static void handle_branch2(struct ieee80211_hw *hw, u16 arraylen,
+			   u32 *array_table)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 v1;
+	u32 v2;
+	int i;
 
-	for (i = 0; i < arraylen; i += 2) {
+	for (i = 0; i < arraylen; i = i + 2) {
 		v1 = array_table[i];
-		v2 = array_table[i + 1];
+		v2 = array_table[i+1];
 		if (v1 < 0xCDCDCDCD) {
 			rtl_set_bbreg(hw, array_table[i], MASKDWORD,
 				      array_table[i + 1]);
 			udelay(1);
 			continue;
-		} else {/*This line is the start line of branch.*/
-			if (!check_cond(hw, array_table[i])) {
+		} else { /*This line is the start line of branch.*/
+			/* to protect READ_NEXT_PAIR not overrun */
+			if (i >= arraylen - 2)
+				break;
+
+			if (!_rtl88e_check_condition(hw, array_table[i])) {
 				/*Discard the following (offset, data) pairs*/
-				NEXT_PAIR(v1, v2, i);
-				while (v2 != 0xDEAD && v2 != 0xCDEF &&
-				       v2 != 0xCDCD && i < arraylen - 2) {
-					NEXT_PAIR(v1, v2, i);
-				}
-				i -= 2; /* compensate for loop's += 2*/
-			} else {
-				/* Configure matched pairs and skip to end */
-				NEXT_PAIR(v1, v2, i);
-				while (v2 != 0xDEAD && v2 != 0xCDEF &&
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 != 0xDEAD &&
+				       v2 != 0xCDEF &&
+				       v2 != 0xCDCD && i < arraylen - 2)
+					READ_NEXT_PAIR(v1, v2, i);
+				i -= 2; /* prevent from for-loop += 2*/
+			} else { /* Configure matched pairs and skip
+				  * to end of if-else.
+				  */
+				READ_NEXT_PAIR(v1, v2, i);
+				while (v2 != 0xDEAD &&
+				       v2 != 0xCDEF &&
 				       v2 != 0xCDCD && i < arraylen - 2) {
 					rtl_set_bbreg(hw, array_table[i],
 						      MASKDWORD,
 						      array_table[i + 1]);
 					udelay(1);
-					NEXT_PAIR(v1, v2, i);
+					READ_NEXT_PAIR(v1, v2, i);
 				}
 
 				while (v2 != 0xDEAD && i < arraylen - 2)
-					NEXT_PAIR(v1, v2, i);
+					READ_NEXT_PAIR(v1, v2, i);
 			}
 		}
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "The agctab_array_table[0] is %x Rtl818EEPHY_REGArray[1] is %x\n",
-			 array_table[i],
-			 array_table[i + 1]);
+			 array_table[i], array_table[i + 1]);
 	}
 }
 
-static void set_baseband_phy_config(struct ieee80211_hw *hw)
+static bool phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+					  u8 configtype)
 {
-	int i;
 	u32 *array_table;
 	u16 arraylen;
-	u32 v1 = 0, v2 = 0;
-
-	arraylen = RTL8188EEPHY_REG_1TARRAYLEN;
-	array_table = RTL8188EEPHY_REG_1TARRAY;
-
-	for (i = 0; i < arraylen; i += 2) {
-		v1 = array_table[i];
-		v2 = array_table[i + 1];
-		if (v1 < 0xcdcdcdcd) {
-			rtl_bb_delay(hw, v1, v2);
-		} else {/*This line is the start line of branch.*/
-			if (!check_cond(hw, array_table[i])) {
-				/*Discard the following (offset, data) pairs*/
-				NEXT_PAIR(v1, v2, i);
-				while (v2 != 0xDEAD &&
-				       v2 != 0xCDEF &&
-				       v2 != 0xCDCD && i < arraylen - 2)
-					NEXT_PAIR(v1, v2, i);
-				i -= 2; /* prevent from for-loop += 2*/
-			} else {
-				/* Configure matched pairs and skip to end */
-				NEXT_PAIR(v1, v2, i);
-				while (v2 != 0xDEAD &&
-				       v2 != 0xCDEF &&
-				       v2 != 0xCDCD && i < arraylen - 2) {
-					rtl_bb_delay(hw, v1, v2);
-					NEXT_PAIR(v1, v2, i);
-				}
 
-				while (v2 != 0xDEAD && i < arraylen - 2)
-					NEXT_PAIR(v1, v2, i);
-			}
-		}
+	if (configtype == BASEBAND_CONFIG_PHY_REG) {
+		arraylen = RTL8188EEPHY_REG_1TARRAYLEN;
+		array_table = RTL8188EEPHY_REG_1TARRAY;
+		handle_branch1(hw, arraylen, array_table);
+	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
+		arraylen = RTL8188EEAGCTAB_1TARRAYLEN;
+		array_table = RTL8188EEAGCTAB_1TARRAY;
+		handle_branch2(hw, arraylen, array_table);
 	}
+	return true;
 }
 
-static void store_pwrindex_offset(struct ieee80211_hw *hw,
-				  u32 regaddr, u32 bitmask,
-				  u32 data)
+static void store_pwrindex_rate_offset(struct ieee80211_hw *hw,
+				       u32 regaddr, u32 bitmask,
+				       u32 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	int count = rtlphy->pwrgroup_cnt;
 
 	if (regaddr == RTXAGC_A_RATE18_06) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][0] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][0] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][0] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][0]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][0]);
 	}
 	if (regaddr == RTXAGC_A_RATE54_24) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][1] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][1] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][1] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][1]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][1]);
 	}
 	if (regaddr == RTXAGC_A_CCK1_MCS32) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][6] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][6] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][6] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][6]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][6]);
 	}
 	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0xffffff00) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][7] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][7] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][7]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][7]);
 	}
 	if (regaddr == RTXAGC_A_MCS03_MCS00) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][2] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][2] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][2] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][2]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][2]);
 	}
 	if (regaddr == RTXAGC_A_MCS07_MCS04) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][3] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][3] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][3] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][3]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][3]);
 	}
 	if (regaddr == RTXAGC_A_MCS11_MCS08) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][4] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][4] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][4] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][4]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][4]);
 	}
 	if (regaddr == RTXAGC_A_MCS15_MCS12) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][5] = data;
-		if (get_rf_type(rtlphy) == RF_1T1R)
-			rtlphy->pwrgroup_cnt++;
+		rtlphy->mcs_txpwrlevel_origoffset[count][5] = data;
+		if (get_rf_type(rtlphy) == RF_1T1R) {
+			count++;
+			rtlphy->pwrgroup_cnt = count;
+		}
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][5] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][5]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][5]);
 	}
 	if (regaddr == RTXAGC_B_RATE18_06) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][8] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][8] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][8] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][8]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][8]);
 	}
 	if (regaddr == RTXAGC_B_RATE54_24) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][9] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][9] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][9] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][9]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][9]);
 	}
 	if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][14] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][14] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][14] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][14]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][14]);
 	}
 	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0x000000ff) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][15] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][15] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][15]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][15]);
 	}
 	if (regaddr == RTXAGC_B_MCS03_MCS00) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][10] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][10] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][10] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][10]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][10]);
 	}
 	if (regaddr == RTXAGC_B_MCS07_MCS04) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][11] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][11] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][11] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][11]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][11]);
 	}
 	if (regaddr == RTXAGC_B_MCS11_MCS08) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][12] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][12] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][12] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][12]);
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][12]);
 	}
 	if (regaddr == RTXAGC_B_MCS15_MCS12) {
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][13] = data;
+		rtlphy->mcs_txpwrlevel_origoffset[count][13] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][13] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][13]);
-		if (get_rf_type(rtlphy) != RF_1T1R)
-			rtlphy->pwrgroup_cnt++;
+			  count,
+			  rtlphy->mcs_txpwrlevel_origoffset[count][13]);
+		if (get_rf_type(rtlphy) != RF_1T1R) {
+			count++;
+			rtlphy->pwrgroup_cnt = count;
+		}
 	}
 }
 
-#define READ_NEXT_RF_PAIR(v1, v2, i)		\
-	do {					\
-		i += 2; v1 = a_table[i];	\
-		v2 = a_table[i + 1];		\
-	} while (0)
+static bool phy_config_bb_with_pghdr(struct ieee80211_hw *hw, u8 configtype)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int i;
+	u32 *phy_reg_page;
+	u16 phy_reg_page_len;
+	u32 v1 = 0, v2 = 0, v3 = 0;
+
+	phy_reg_page_len = RTL8188EEPHY_REG_ARRAY_PGLEN;
+	phy_reg_page = RTL8188EEPHY_REG_ARRAY_PG;
+
+	if (configtype == BASEBAND_CONFIG_PHY_REG) {
+		for (i = 0; i < phy_reg_page_len; i = i + 3) {
+			v1 = phy_reg_page[i];
+			v2 = phy_reg_page[i+1];
+			v3 = phy_reg_page[i+2];
+
+			if (v1 < 0xcdcdcdcd) {
+				if (phy_reg_page[i] == 0xfe)
+					mdelay(50);
+				else if (phy_reg_page[i] == 0xfd)
+					mdelay(5);
+				else if (phy_reg_page[i] == 0xfc)
+					mdelay(1);
+				else if (phy_reg_page[i] == 0xfb)
+					udelay(50);
+				else if (phy_reg_page[i] == 0xfa)
+					udelay(5);
+				else if (phy_reg_page[i] == 0xf9)
+					udelay(1);
+
+				store_pwrindex_rate_offset(hw, phy_reg_page[i],
+							   phy_reg_page[i + 1],
+							   phy_reg_page[i + 2]);
+				continue;
+			} else {
+				if (!_rtl88e_check_condition(hw,
+							     phy_reg_page[i])) {
+					/*don't need the hw_body*/
+				    i += 2; /* skip the pair of expression*/
+				    /* to protect 'i+1' 'i+2' not overrun */
+				    if (i >= phy_reg_page_len - 2)
+					break;
+
+				    v1 = phy_reg_page[i];
+				    v2 = phy_reg_page[i+1];
+				    v3 = phy_reg_page[i+2];
+				    while (v2 != 0xDEAD &&
+					   i < phy_reg_page_len - 5) {
+					i += 3;
+					v1 = phy_reg_page[i];
+					v2 = phy_reg_page[i+1];
+					v3 = phy_reg_page[i+2];
+				    }
+				}
+			}
+		}
+	} else {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "configtype != BaseBand_Config_PHY_REG\n");
+	}
+	return true;
+}
+
+#define READ_NEXT_RF_PAIR(v1, v2, i) \
+do { \
+	i += 2; \
+	v1 = radioa_array_table[i]; \
+	v2 = radioa_array_table[i+1]; \
+} while (0)
+
+static void process_path_a(struct ieee80211_hw *hw,
+			   u16  radioa_arraylen,
+			   u32 *radioa_array_table)
+{
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u32 v1, v2;
+	int i;
+
+	for (i = 0; i < radioa_arraylen; i = i + 2) {
+		v1 = radioa_array_table[i];
+		v2 = radioa_array_table[i+1];
+		if (v1 < 0xcdcdcdcd) {
+			_rtl8188e_config_rf_radio_a(hw, v1, v2);
+		} else { /*This line is the start line of branch.*/
+			/* to protect READ_NEXT_PAIR not overrun */
+			if (i >= radioa_arraylen - 2)
+				break;
+
+			if (!_rtl88e_check_condition(hw, radioa_array_table[i])) {
+				/*Discard the following (offset, data) pairs*/
+				READ_NEXT_RF_PAIR(v1, v2, i);
+				while (v2 != 0xDEAD &&
+				       v2 != 0xCDEF &&
+				       v2 != 0xCDCD &&
+				       i < radioa_arraylen - 2) {
+					READ_NEXT_RF_PAIR(v1, v2, i);
+				}
+				i -= 2; /* prevent from for-loop += 2*/
+			} else { /* Configure matched pairs and
+				  * skip to end of if-else.
+				  */
+				READ_NEXT_RF_PAIR(v1, v2, i);
+				while (v2 != 0xDEAD &&
+				       v2 != 0xCDEF &&
+				       v2 != 0xCDCD &&
+				       i < radioa_arraylen - 2) {
+					_rtl8188e_config_rf_radio_a(hw, v1, v2);
+					READ_NEXT_RF_PAIR(v1, v2, i);
+				}
+
+				while (v2 != 0xDEAD &&
+				       i < radioa_arraylen - 2)
+					READ_NEXT_RF_PAIR(v1, v2, i);
+			}
+		}
+	}
+
+	if (rtlhal->oem_id == RT_CID_819X_HP)
+		_rtl8188e_config_rf_radio_a(hw, 0x52, 0x7E4BD);
+}
 
 bool rtl88e_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 					  enum radio_path rfpath)
 {
-	int i;
-	u32 *a_table;
-	u16 a_len;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u32 v1 = 0, v2 = 0;
+	bool rtstatus = true;
+	u32 *radioa_array_table;
+	u16 radioa_arraylen;
 
-	a_len = RTL8188EE_RADIOA_1TARRAYLEN;
-	a_table = RTL8188EE_RADIOA_1TARRAY;
+	radioa_arraylen = RTL8188EE_RADIOA_1TARRAYLEN;
+	radioa_array_table = RTL8188EE_RADIOA_1TARRAY;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 "Radio_A:RTL8188EE_RADIOA_1TARRAY %d\n", a_len);
+		 "Radio_A:RTL8188EE_RADIOA_1TARRAY %d\n", radioa_arraylen);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Radio No %x\n", rfpath);
+	rtstatus = true;
 	switch (rfpath) {
 	case RF90_PATH_A:
-		for (i = 0; i < a_len; i = i + 2) {
-			v1 = a_table[i];
-			v2 = a_table[i + 1];
-			if (v1 < 0xcdcdcdcd) {
-				rtl88_config_s(hw, v1, v2);
-			} else {/*This line is the start line of branch.*/
-				if (!check_cond(hw, a_table[i])) {
-					/* Discard the following (offset, data)
-					 * pairs
-					 */
-					READ_NEXT_RF_PAIR(v1, v2, i);
-					while (v2 != 0xDEAD && v2 != 0xCDEF &&
-					       v2 != 0xCDCD && i < a_len - 2)
-						READ_NEXT_RF_PAIR(v1, v2, i);
-					i -= 2; /* prevent from for-loop += 2*/
-				} else {
-					/* Configure matched pairs and skip to
-					 * end of if-else.
-					 */
-					READ_NEXT_RF_PAIR(v1, v2, i);
-					while (v2 != 0xDEAD && v2 != 0xCDEF &&
-					       v2 != 0xCDCD && i < a_len - 2) {
-						rtl88_config_s(hw, v1, v2);
-						READ_NEXT_RF_PAIR(v1, v2, i);
-					}
-
-					while (v2 != 0xDEAD && i < a_len - 2)
-						READ_NEXT_RF_PAIR(v1, v2, i);
-				}
-			}
-		}
+		process_path_a(hw, radioa_arraylen, radioa_array_table);
+		break;
+	case RF90_PATH_B:
+	case RF90_PATH_C:
+	case RF90_PATH_D:
+		break;
+	}
+	return true;
+}
+
+void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+
+	rtlphy->default_initialgain[0] =
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[1] =
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[2] =
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[3] =
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x\n",
+		 rtlphy->default_initialgain[0],
+		 rtlphy->default_initialgain[1],
+		 rtlphy->default_initialgain[2],
+		 rtlphy->default_initialgain[3]);
+
+	rtlphy->framesync = (u8)rtl_get_bbreg(hw, ROFDM0_RXDETECTOR3,
+					      MASKBYTE0);
+	rtlphy->framesync_c34 = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR2,
+					      MASKDWORD);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "Default framesync (0x%x) = 0x%x\n",
+		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
+}
+
+static void _rtl88e_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfs = RFPGA0_XAB_RFINTERFACESW;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfs = RFPGA0_XAB_RFINTERFACESW;
+	rtlphy->phyreg_def[RF90_PATH_C].rfintfs = RFPGA0_XCD_RFINTERFACESW;
+	rtlphy->phyreg_def[RF90_PATH_D].rfintfs = RFPGA0_XCD_RFINTERFACESW;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfi = RFPGA0_XAB_RFINTERFACERB;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfi = RFPGA0_XAB_RFINTERFACERB;
+	rtlphy->phyreg_def[RF90_PATH_C].rfintfi = RFPGA0_XCD_RFINTERFACERB;
+	rtlphy->phyreg_def[RF90_PATH_D].rfintfi = RFPGA0_XCD_RFINTERFACERB;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfo = RFPGA0_XA_RFINTERFACEOE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfo = RFPGA0_XB_RFINTERFACEOE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfe = RFPGA0_XA_RFINTERFACEOE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfe = RFPGA0_XB_RFINTERFACEOE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf3wire_offset =
+	    RFPGA0_XA_LSSIPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_B].rf3wire_offset =
+	    RFPGA0_XB_LSSIPARAMETER;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rflssi_select = RFPGA0_XAB_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_B].rflssi_select = RFPGA0_XAB_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_C].rflssi_select = RFPGA0_XCD_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_D].rflssi_select = RFPGA0_XCD_RFPARAMETER;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rftxgain_stage = RFPGA0_TXGAINSTAGE;
+	rtlphy->phyreg_def[RF90_PATH_B].rftxgain_stage = RFPGA0_TXGAINSTAGE;
+	rtlphy->phyreg_def[RF90_PATH_C].rftxgain_stage = RFPGA0_TXGAINSTAGE;
+	rtlphy->phyreg_def[RF90_PATH_D].rftxgain_stage = RFPGA0_TXGAINSTAGE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfhssi_para1 = RFPGA0_XA_HSSIPARAMETER1;
+	rtlphy->phyreg_def[RF90_PATH_B].rfhssi_para1 = RFPGA0_XB_HSSIPARAMETER1;
 
-		if (rtlhal->oem_id == RT_CID_819X_HP)
-			rtl88_config_s(hw, 0x52, 0x7E4BD);
+	rtlphy->phyreg_def[RF90_PATH_A].rfhssi_para2 = RFPGA0_XA_HSSIPARAMETER2;
+	rtlphy->phyreg_def[RF90_PATH_B].rfhssi_para2 = RFPGA0_XB_HSSIPARAMETER2;
 
-		break;
+	rtlphy->phyreg_def[RF90_PATH_A].rfsw_ctrl =
+	    RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_B].rfsw_ctrl =
+	    RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_C].rfsw_ctrl =
+	    RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_D].rfsw_ctrl =
+	    RFPGA0_XCD_SWITCHCONTROL;
 
-	case RF90_PATH_B:
-	case RF90_PATH_C:
-	case RF90_PATH_D:
-	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
-		break;
-	}
-	return true;
-}
+	rtlphy->phyreg_def[RF90_PATH_A].rfagc_control1 = ROFDM0_XAAGCCORE1;
+	rtlphy->phyreg_def[RF90_PATH_B].rfagc_control1 = ROFDM0_XBAGCCORE1;
+	rtlphy->phyreg_def[RF90_PATH_C].rfagc_control1 = ROFDM0_XCAGCCORE1;
+	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control1 = ROFDM0_XDAGCCORE1;
 
-void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	rtlphy->phyreg_def[RF90_PATH_A].rfagc_control2 = ROFDM0_XAAGCCORE2;
+	rtlphy->phyreg_def[RF90_PATH_B].rfagc_control2 = ROFDM0_XBAGCCORE2;
+	rtlphy->phyreg_def[RF90_PATH_C].rfagc_control2 = ROFDM0_XCAGCCORE2;
+	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control2 = ROFDM0_XDAGCCORE2;
 
-	rtlphy->default_initialgain[0] = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1,
-						       MASKBYTE0);
-	rtlphy->default_initialgain[1] = rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1,
-						       MASKBYTE0);
-	rtlphy->default_initialgain[2] = rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1,
-						       MASKBYTE0);
-	rtlphy->default_initialgain[3] = rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1,
-						       MASKBYTE0);
+	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbal = ROFDM0_XARXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbal = ROFDM0_XBRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbal = ROFDM0_XCRXIQIMBANLANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbal = ROFDM0_XDRXIQIMBALANCE;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 "Default initial gain (c50 = 0x%x, c58 = 0x%x, c60 = 0x%x, c68 = 0x%x\n",
-		  rtlphy->default_initialgain[0],
-		  rtlphy->default_initialgain[1],
-		  rtlphy->default_initialgain[2],
-		  rtlphy->default_initialgain[3]);
-
-	rtlphy->framesync = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR3,
-					  MASKBYTE0);
-	rtlphy->framesync_c34 = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR2,
-					      MASKDWORD);
+	rtlphy->phyreg_def[RF90_PATH_A].rfrx_afe = ROFDM0_XARXAFE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfrx_afe = ROFDM0_XBRXAFE;
+	rtlphy->phyreg_def[RF90_PATH_C].rfrx_afe = ROFDM0_XCRXAFE;
+	rtlphy->phyreg_def[RF90_PATH_D].rfrx_afe = ROFDM0_XDRXAFE;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 "Default framesync (0x%x) = 0x%x\n",
-		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
+	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbal = ROFDM0_XATXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbal = ROFDM0_XBTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbal = ROFDM0_XCTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbal = ROFDM0_XDTXIQIMBALANCE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rftx_afe = ROFDM0_XATXAFE;
+	rtlphy->phyreg_def[RF90_PATH_B].rftx_afe = ROFDM0_XBTXAFE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rb = RFPGA0_XA_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rb = RFPGA0_XB_LSSIREADBACK;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rbpi = TRANSCEIVEA_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rbpi = TRANSCEIVEB_HSPI_READBACK;
 }
 
 void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	u8 level;
-	long dbm;
-
-	level = rtlphy->cur_cck_txpwridx;
-	dbm = rtl88e_pwr_idx_dbm(hw, WIRELESS_MODE_B, level);
-	level = rtlphy->cur_ofdm24g_txpwridx;
-	if (rtl88e_pwr_idx_dbm(hw, WIRELESS_MODE_G, level) > dbm)
-		dbm = rtl88e_pwr_idx_dbm(hw, WIRELESS_MODE_G, level);
-	level = rtlphy->cur_ofdm24g_txpwridx;
-	if (rtl88e_pwr_idx_dbm(hw, WIRELESS_MODE_N_24G, level) > dbm)
-		dbm = rtl88e_pwr_idx_dbm(hw, WIRELESS_MODE_N_24G, level);
-	*powerlevel = dbm;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	u8 txpwr_level;
+	long txpwr_dbm;
+
+	txpwr_level = rtlphy->cur_cck_txpwridx;
+	txpwr_dbm = _rtl88e_phy_txpwr_idx_to_dbm(hw,
+						 WIRELESS_MODE_B, txpwr_level);
+	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
+	if (_rtl88e_phy_txpwr_idx_to_dbm(hw,
+					 WIRELESS_MODE_G,
+					 txpwr_level) > txpwr_dbm)
+		txpwr_dbm =
+		    _rtl88e_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
+						 txpwr_level);
+	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
+	if (_rtl88e_phy_txpwr_idx_to_dbm(hw,
+					 WIRELESS_MODE_N_24G,
+					 txpwr_level) > txpwr_dbm)
+		txpwr_dbm =
+		    _rtl88e_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
+						 txpwr_level);
+	*powerlevel = txpwr_dbm;
+}
+
+static void handle_path_a(struct rtl_efuse *rtlefuse, u8 index,
+			  u8 *cckpowerlevel, u8 *ofdmpowerlevel,
+			  u8 *bw20powerlevel, u8 *bw40powerlevel)
+{
+	cckpowerlevel[RF90_PATH_A] =
+	    rtlefuse->txpwrlevel_cck[RF90_PATH_A][index];
+		/*-8~7 */
+	if (rtlefuse->txpwr_ht20diff[RF90_PATH_A][index] > 0x0f)
+		bw20powerlevel[RF90_PATH_A] =
+		  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_A][index] -
+		  (~(rtlefuse->txpwr_ht20diff[RF90_PATH_A][index]) + 1);
+	else
+		bw20powerlevel[RF90_PATH_A] =
+		  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_A][index] +
+		  rtlefuse->txpwr_ht20diff[RF90_PATH_A][index];
+	if (rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][index] > 0xf)
+		ofdmpowerlevel[RF90_PATH_A] =
+		  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_A][index] -
+		  (~(rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][index])+1);
+	else
+		ofdmpowerlevel[RF90_PATH_A] =
+		rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_A][index] +
+		  rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][index];
+	bw40powerlevel[RF90_PATH_A] =
+	  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_A][index];
 }
 
 static void _rtl88e_get_txpower_index(struct ieee80211_hw *hw, u8 channel,
-				      u8 *cckpower, u8 *ofdm, u8 *bw20_pwr,
-				      u8 *bw40_pwr)
+				      u8 *cckpowerlevel, u8 *ofdmpowerlevel,
+				      u8 *bw20powerlevel, u8 *bw40powerlevel)
 {
-	struct rtl_efuse *fuse = rtl_efuse(rtl_priv(hw));
-	u8 i = (channel - 1);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u8 index = (channel - 1);
 	u8 rf_path = 0;
-	int jj = RF90_PATH_A;
-	int kk = RF90_PATH_B;
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
-		if (rf_path == jj) {
-			cckpower[jj] = fuse->txpwrlevel_cck[jj][i];
-			if (fuse->txpwr_ht20diff[jj][i] > 0x0f) /*-8~7 */
-				bw20_pwr[jj] = fuse->txpwrlevel_ht40_1s[jj][i] -
-					(~(fuse->txpwr_ht20diff[jj][i]) + 1);
-			else
-				bw20_pwr[jj] = fuse->txpwrlevel_ht40_1s[jj][i] +
-					 fuse->txpwr_ht20diff[jj][i];
-			if (fuse->txpwr_legacyhtdiff[jj][i] > 0xf)
-				ofdm[jj] = fuse->txpwrlevel_ht40_1s[jj][i] -
-					(~(fuse->txpwr_legacyhtdiff[jj][i])+1);
-			else
-				ofdm[jj] = fuse->txpwrlevel_ht40_1s[jj][i] +
-					   fuse->txpwr_legacyhtdiff[jj][i];
-			bw40_pwr[jj] = fuse->txpwrlevel_ht40_1s[jj][i];
-
-		} else if (rf_path == kk) {
-			cckpower[kk] = fuse->txpwrlevel_cck[kk][i];
-			bw20_pwr[kk] = fuse->txpwrlevel_ht40_1s[kk][i] +
-				       fuse->txpwr_ht20diff[kk][i];
-			ofdm[kk] = fuse->txpwrlevel_ht40_1s[kk][i] +
-					fuse->txpwr_legacyhtdiff[kk][i];
-			bw40_pwr[kk] = fuse->txpwrlevel_ht40_1s[kk][i];
+		if (rf_path == RF90_PATH_A) {
+			handle_path_a(rtlefuse, index, cckpowerlevel,
+				      ofdmpowerlevel, bw20powerlevel,
+				      bw40powerlevel);
+		} else if (rf_path == RF90_PATH_B) {
+			cckpowerlevel[RF90_PATH_B] =
+			  rtlefuse->txpwrlevel_cck[RF90_PATH_B][index];
+			bw20powerlevel[RF90_PATH_B] =
+			  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_B][index] +
+			  rtlefuse->txpwr_ht20diff[RF90_PATH_B][index];
+			ofdmpowerlevel[RF90_PATH_B] =
+			  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_B][index] +
+			  rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][index];
+			bw40powerlevel[RF90_PATH_B] =
+			  rtlefuse->txpwrlevel_ht40_1s[RF90_PATH_B][index];
 		}
 	}
+
 }
 
 static void _rtl88e_ccxpower_index_check(struct ieee80211_hw *hw,
-					 u8 channel, u8 *cckpower,
-					 u8 *ofdm, u8 *bw20_pwr,
-					 u8 *bw40_pwr)
+					 u8 channel, u8 *cckpowerlevel,
+					 u8 *ofdmpowerlevel, u8 *bw20powerlevel,
+					 u8 *bw40powerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+
+	rtlphy->cur_cck_txpwridx = cckpowerlevel[0];
+	rtlphy->cur_ofdm24g_txpwridx = ofdmpowerlevel[0];
+	rtlphy->cur_bw20_txpwridx = bw20powerlevel[0];
+	rtlphy->cur_bw40_txpwridx = bw40powerlevel[0];
 
-	rtlphy->cur_cck_txpwridx = cckpower[0];
-	rtlphy->cur_ofdm24g_txpwridx = ofdm[0];
-	rtlphy->cur_bw20_txpwridx = bw20_pwr[0];
-	rtlphy->cur_bw40_txpwridx = bw40_pwr[0];
 }
 
 void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 {
-	struct rtl_efuse *fuse = rtl_efuse(rtl_priv(hw));
-	u8 cckpower[MAX_TX_COUNT]  = {0}, ofdm[MAX_TX_COUNT] = {0};
-	u8 bw20_pwr[MAX_TX_COUNT] = {0}, bw40_pwr[MAX_TX_COUNT] = {0};
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u8 cckpowerlevel[MAX_TX_COUNT]  = {0};
+	u8 ofdmpowerlevel[MAX_TX_COUNT] = {0};
+	u8 bw20powerlevel[MAX_TX_COUNT] = {0};
+	u8 bw40powerlevel[MAX_TX_COUNT] = {0};
 
-	if (fuse->txpwr_fromeprom == false)
+	if (!rtlefuse->txpwr_fromeprom)
 		return;
-	_rtl88e_get_txpower_index(hw, channel, &cckpower[0], &ofdm[0],
-				  &bw20_pwr[0], &bw40_pwr[0]);
-	_rtl88e_ccxpower_index_check(hw, channel, &cckpower[0], &ofdm[0],
-				     &bw20_pwr[0], &bw40_pwr[0]);
-	rtl88e_phy_rf6052_set_cck_txpower(hw, &cckpower[0]);
-	rtl88e_phy_rf6052_set_ofdm_txpower(hw, &ofdm[0], &bw20_pwr[0],
-					   &bw40_pwr[0], channel);
+	_rtl88e_get_txpower_index(hw, channel,
+				  &cckpowerlevel[0], &ofdmpowerlevel[0],
+				  &bw20powerlevel[0], &bw40powerlevel[0]);
+	_rtl88e_ccxpower_index_check(hw, channel,
+				     &cckpowerlevel[0], &ofdmpowerlevel[0],
+				     &bw20powerlevel[0], &bw40powerlevel[0]);
+	rtl88e_phy_rf6052_set_cck_txpower(hw, &cckpowerlevel[0]);
+	rtl88e_phy_rf6052_set_ofdm_txpower(hw, &ofdmpowerlevel[0],
+					   &bw20powerlevel[0],
+					   &bw40powerlevel[0], channel);
+}
+
+static long _rtl88e_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+					 enum wireless_mode wirelessmode,
+					 u8 txpwridx)
+{
+	long offset;
+	long pwrout_dbm;
+
+	switch (wirelessmode) {
+	case WIRELESS_MODE_B:
+		offset = -7;
+		break;
+	case WIRELESS_MODE_G:
+	case WIRELESS_MODE_N_24G:
+		offset = -8;
+		break;
+	default:
+		offset = -8;
+		break;
+	}
+	pwrout_dbm = txpwridx / 2 + offset;
+	return pwrout_dbm;
+}
+
+void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	enum io_type iotype;
+
+	if (!is_hal_stop(rtlhal)) {
+		switch (operation) {
+		case SCAN_OPT_BACKUP_BAND0:
+			iotype = IO_CMD_PAUSE_BAND0_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+
+			break;
+		case SCAN_OPT_RESTORE:
+			iotype = IO_CMD_RESUME_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Unknown Scan Backup operation.\n");
+			break;
+		}
+	}
 }
 
 void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
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
@@ -1162,7 +1174,7 @@ void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 tmp_bw = rtlphy->current_chan_bw;
 
@@ -1173,7 +1185,7 @@ void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 		rtl88e_phy_set_bw_mode_callback(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "FALSE driver sleep or unload\n");
+			 "false driver sleep or unload\n");
 		rtlphy->set_bwmode_inprogress = false;
 		rtlphy->current_chan_bw = tmp_bw;
 	}
@@ -1183,7 +1195,7 @@ void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 delay;
 
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
@@ -1193,9 +1205,9 @@ void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 	do {
 		if (!rtlphy->sw_chnl_inprogress)
 			break;
-		if (!chnl_step_by_step(hw, rtlphy->current_channel,
-				       &rtlphy->sw_chnl_stage,
-				       &rtlphy->sw_chnl_step, &delay)) {
+		if (!_rtl88e_phy_sw_chnl_step_by_step
+		    (hw, rtlphy->current_channel, &rtlphy->sw_chnl_stage,
+		     &rtlphy->sw_chnl_step, &delay)) {
 			if (delay > 0)
 				mdelay(delay);
 			else
@@ -1211,7 +1223,7 @@ void rtl88e_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	if (rtlphy->sw_chnl_inprogress)
@@ -1237,9 +1249,140 @@ u8 rtl88e_phy_sw_chnl(struct ieee80211_hw *hw)
 	return 1;
 }
 
+static bool _rtl88e_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+					     u8 channel, u8 *stage, u8 *step,
+					     u32 *delay)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct swchnlcmd precommoncmd[MAX_PRECMD_CNT];
+	u32 precommoncmdcnt;
+	struct swchnlcmd postcommoncmd[MAX_POSTCMD_CNT];
+	u32 postcommoncmdcnt;
+	struct swchnlcmd rfdependcmd[MAX_RFDEPENDCMD_CNT];
+	u32 rfdependcmdcnt;
+	struct swchnlcmd *currentcmd = NULL;
+	u8 rfpath;
+	u8 num_total_rfpath = rtlphy->num_total_rfpath;
+
+	precommoncmdcnt = 0;
+	_rtl88e_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
+					 MAX_PRECMD_CNT,
+					 CMDID_SET_TXPOWEROWER_LEVEL, 0, 0, 0);
+	_rtl88e_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
+					 MAX_PRECMD_CNT, CMDID_END, 0, 0, 0);
+
+	postcommoncmdcnt = 0;
+
+	_rtl88e_phy_set_sw_chnl_cmdarray(postcommoncmd, postcommoncmdcnt++,
+					 MAX_POSTCMD_CNT, CMDID_END, 0, 0, 0);
+
+	rfdependcmdcnt = 0;
+
+	RT_ASSERT((channel >= 1 && channel <= 14),
+		  "illegal channel for Zebra: %d\n", channel);
+
+	_rtl88e_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
+					 MAX_RFDEPENDCMD_CNT, CMDID_RF_WRITEREG,
+					 RF_CHNLBW, channel, 10);
+
+	_rtl88e_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
+					 MAX_RFDEPENDCMD_CNT, CMDID_END, 0, 0,
+					 0);
+
+	do {
+		switch (*stage) {
+		case 0:
+			currentcmd = &precommoncmd[*step];
+			break;
+		case 1:
+			currentcmd = &rfdependcmd[*step];
+			break;
+		case 2:
+			currentcmd = &postcommoncmd[*step];
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Invalid 'stage' = %d, Check it!\n", *stage);
+			return true;
+		}
+
+		if (currentcmd->cmdid == CMDID_END) {
+			if ((*stage) == 2)
+				return true;
+			(*stage)++;
+			(*step) = 0;
+			continue;
+		}
+
+		switch (currentcmd->cmdid) {
+		case CMDID_SET_TXPOWEROWER_LEVEL:
+			rtl88e_phy_set_txpower_level(hw, channel);
+			break;
+		case CMDID_WRITEPORT_ULONG:
+			rtl_write_dword(rtlpriv, currentcmd->para1,
+					currentcmd->para2);
+			break;
+		case CMDID_WRITEPORT_USHORT:
+			rtl_write_word(rtlpriv, currentcmd->para1,
+				       (u16)currentcmd->para2);
+			break;
+		case CMDID_WRITEPORT_UCHAR:
+			rtl_write_byte(rtlpriv, currentcmd->para1,
+				       (u8)currentcmd->para2);
+			break;
+		case CMDID_RF_WRITEREG:
+			for (rfpath = 0; rfpath < num_total_rfpath; rfpath++) {
+				rtlphy->rfreg_chnlval[rfpath] =
+				    ((rtlphy->rfreg_chnlval[rfpath] &
+				      0xfffffc00) | currentcmd->para2);
+
+				rtl_set_rfreg(hw, (enum radio_path)rfpath,
+					      currentcmd->para1,
+					      RFREG_OFFSET_MASK,
+					      rtlphy->rfreg_chnlval[rfpath]);
+			}
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
+			break;
+		}
+
+		break;
+	} while (true);
+
+	(*delay) = currentcmd->msdelay;
+	(*step)++;
+	return false;
+}
+
+static bool _rtl88e_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
+					     u32 cmdtableidx, u32 cmdtablesz,
+					     enum swchnlcmd_id cmdid,
+					     u32 para1, u32 para2, u32 msdelay)
+{
+	struct swchnlcmd *pcmd;
+
+	if (cmdtable == NULL) {
+		RT_ASSERT(false, "cmdtable cannot be NULL.\n");
+		return false;
+	}
+
+	if (cmdtableidx >= cmdtablesz)
+		return false;
+
+	pcmd = cmdtable + cmdtableidx;
+	pcmd->cmdid = cmdid;
+	pcmd->para1 = para1;
+	pcmd->para2 = para2;
+	pcmd->msdelay = msdelay;
+	return true;
+}
+
 static u8 _rtl88e_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
 {
-	u32 reg_eac, reg_e94, reg_e9c;
+	u32 reg_eac, reg_e94, reg_e9c, reg_ea4;
 	u8 result = 0x00;
 
 	rtl_set_bbreg(hw, 0xe30, MASKDWORD, 0x10008c1c);
@@ -1256,6 +1399,7 @@ static u8 _rtl88e_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
 	reg_eac = rtl_get_bbreg(hw, 0xeac, MASKDWORD);
 	reg_e94 = rtl_get_bbreg(hw, 0xe94, MASKDWORD);
 	reg_e9c = rtl_get_bbreg(hw, 0xe9c, MASKDWORD);
+	reg_ea4 = rtl_get_bbreg(hw, 0xea4, MASKDWORD);
 
 	if (!(reg_eac & BIT(28)) &&
 	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
@@ -1295,15 +1439,14 @@ static u8 _rtl88e_phy_path_a_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
 {
 	u32 reg_eac, reg_e94, reg_e9c, reg_ea4, u32temp;
 	u8 result = 0x00;
-	int jj = RF90_PATH_A;
 
 	/*Get TXIMR Setting*/
 	/*Modify RX IQK mode table*/
 	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
-	rtl_set_rfreg(hw, jj, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
-	rtl_set_rfreg(hw, jj, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
-	rtl_set_rfreg(hw, jj, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
-	rtl_set_rfreg(hw, jj, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf117b);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf117b);
 	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
 
 	/*IQK Setting*/
@@ -1318,7 +1461,7 @@ static u8 _rtl88e_phy_path_a_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
 
 	/*LO calibration Setting*/
 	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x0046a911);
-	/*one shot, path A LOK & iqk*/
+	/*one shot,path A LOK & iqk*/
 	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
 	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
 
@@ -1336,16 +1479,16 @@ static u8 _rtl88e_phy_path_a_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
 	else
 		return result;
 
-	u32temp = 0x80007C00 | (reg_e94&0x3FF0000)  |
+	u32temp = 0x80007C00 | (reg_e94&0x3FF0000) |
 		  ((reg_e9c&0x3FF0000) >> 16);
 	rtl_set_bbreg(hw, RTX_IQK, MASKDWORD, u32temp);
 	/*RX IQK*/
 	/*Modify RX IQK mode table*/
 	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
-	rtl_set_rfreg(hw, jj, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
-	rtl_set_rfreg(hw, jj, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
-	rtl_set_rfreg(hw, jj, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
-	rtl_set_rfreg(hw, jj, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7ffa);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7ffa);
 	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
 
 	/*IQK Setting*/
@@ -1359,7 +1502,7 @@ static u8 _rtl88e_phy_path_a_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
 
 	/*LO calibration Setting*/
 	rtl_set_bbreg(hw, RIQK_AGC_RSP, MASKDWORD, 0x0046a911);
-	/*one shot, path A LOK & iqk*/
+	/*one shot,path A LOK & iqk*/
 	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf9000000);
 	rtl_set_bbreg(hw, RIQK_AGC_PTS, MASKDWORD, 0xf8000000);
 
@@ -1377,57 +1520,58 @@ static u8 _rtl88e_phy_path_a_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
 	return result;
 }
 
-static void fill_iqk(struct ieee80211_hw *hw, bool iqk_ok, long result[][8],
-		     u8 final, bool btxonly)
+static void _rtl88e_phy_path_a_fill_iqk_matrix(struct ieee80211_hw *hw,
+					       bool iqk_ok, long result[][8],
+					       u8 final_candidate, bool btxonly)
 {
 	u32 oldval_0, x, tx0_a, reg;
 	long y, tx0_c;
 
-	if (final == 0xFF) {
+	if (final_candidate == 0xFF) {
 		return;
 	} else if (iqk_ok) {
-		oldval_0 = (rtl_get_bbreg(hw, ROFDM0_XATXIQIMBAL,
+		oldval_0 = (rtl_get_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
 					  MASKDWORD) >> 22) & 0x3FF;
-		x = result[final][0];
+		x = result[final_candidate][0];
 		if ((x & 0x00000200) != 0)
 			x = x | 0xFFFFFC00;
 		tx0_a = (x * oldval_0) >> 8;
-		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBAL, 0x3FF, tx0_a);
-		rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(31),
+		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE, 0x3FF, tx0_a);
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(31),
 			      ((x * oldval_0 >> 7) & 0x1));
-		y = result[final][1];
+		y = result[final_candidate][1];
 		if ((y & 0x00000200) != 0)
-			y |= 0xFFFFFC00;
+			y = y | 0xFFFFFC00;
 		tx0_c = (y * oldval_0) >> 8;
 		rtl_set_bbreg(hw, ROFDM0_XCTXAFE, 0xF0000000,
 			      ((tx0_c & 0x3C0) >> 6));
-		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBAL, 0x003F0000,
+		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE, 0x003F0000,
 			      (tx0_c & 0x3F));
-		rtl_set_bbreg(hw, ROFDM0_ECCATHRES, BIT(29),
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(29),
 			      ((y * oldval_0 >> 7) & 0x1));
 		if (btxonly)
 			return;
-		reg = result[final][2];
-		rtl_set_bbreg(hw, ROFDM0_XARXIQIMBAL, 0x3FF, reg);
-		reg = result[final][3] & 0x3F;
-		rtl_set_bbreg(hw, ROFDM0_XARXIQIMBAL, 0xFC00, reg);
-		reg = (result[final][3] >> 6) & 0xF;
+		reg = result[final_candidate][2];
+		rtl_set_bbreg(hw, ROFDM0_XARXIQIMBALANCE, 0x3FF, reg);
+		reg = result[final_candidate][3] & 0x3F;
+		rtl_set_bbreg(hw, ROFDM0_XARXIQIMBALANCE, 0xFC00, reg);
+		reg = (result[final_candidate][3] >> 6) & 0xF;
 		rtl_set_bbreg(hw, 0xca0, 0xF0000000, reg);
 	}
 }
 
-static void save_adda_reg(struct ieee80211_hw *hw,
-			  const u32 *addareg, u32 *backup,
-			  u32 registernum)
+static void _rtl88e_phy_save_adda_registers(struct ieee80211_hw *hw,
+					    u32 *addareg, u32 *addabackup,
+					    u32 registernum)
 {
 	u32 i;
 
 	for (i = 0; i < registernum; i++)
-		backup[i] = rtl_get_bbreg(hw, addareg[i], MASKDWORD);
+		addabackup[i] = rtl_get_bbreg(hw, addareg[i], MASKDWORD);
 }
 
-static void save_mac_reg(struct ieee80211_hw *hw, const u32 *macreg,
-			 u32 *macbackup)
+static void _rtl88e_phy_save_mac_registers(struct ieee80211_hw *hw,
+					   u32 *macreg, u32 *macbackup)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
@@ -1437,17 +1581,18 @@ static void save_mac_reg(struct ieee80211_hw *hw, const u32 *macreg,
 	macbackup[i] = rtl_read_dword(rtlpriv, macreg[i]);
 }
 
-static void reload_adda(struct ieee80211_hw *hw, const u32 *addareg,
-		        u32 *backup, u32 reg_num)
+static void _rtl88e_phy_reload_adda_registers(struct ieee80211_hw *hw,
+					      u32 *addareg, u32 *addabackup,
+					      u32 regiesternum)
 {
 	u32 i;
 
-	for (i = 0; i < reg_num; i++)
-		rtl_set_bbreg(hw, addareg[i], MASKDWORD, backup[i]);
+	for (i = 0; i < regiesternum; i++)
+		rtl_set_bbreg(hw, addareg[i], MASKDWORD, addabackup[i]);
 }
 
-static void reload_mac(struct ieee80211_hw *hw, const u32 *macreg,
-		       u32 *macbackup)
+static void _rtl88e_phy_reload_mac_registers(struct ieee80211_hw *hw,
+					     u32 *macreg, u32 *macbackup)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
@@ -1458,8 +1603,7 @@ static void reload_mac(struct ieee80211_hw *hw, const u32 *macreg,
 }
 
 static void _rtl88e_phy_path_adda_on(struct ieee80211_hw *hw,
-				     const u32 *addareg, bool is_patha_on,
-				     bool is2t)
+				     u32 *addareg, bool is_patha_on, bool is2t)
 {
 	u32 pathon;
 	u32 i;
@@ -1477,8 +1621,7 @@ static void _rtl88e_phy_path_adda_on(struct ieee80211_hw *hw,
 }
 
 static void _rtl88e_phy_mac_setting_calibration(struct ieee80211_hw *hw,
-						const u32 *macreg,
-						u32 *macbackup)
+						u32 *macreg, u32 *macbackup)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i = 0;
@@ -1507,12 +1650,13 @@ static void _rtl88e_phy_pi_mode_switch(struct ieee80211_hw *hw, bool pi_mode)
 	rtl_set_bbreg(hw, 0x828, MASKDWORD, mode);
 }
 
-static bool sim_comp(struct ieee80211_hw *hw, long result[][8], u8 c1, u8 c2)
+static bool _rtl88e_phy_simularity_compare(struct ieee80211_hw *hw,
+					   long result[][8], u8 c1, u8 c2)
 {
-	u32 i, j, diff, bitmap, bound;
+	u32 i, j, diff, simularity_bitmap, bound;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
-	u8 final[2] = {0xFF, 0xFF};
+	u8 final_candidate[2] = { 0xFF, 0xFF };
 	bool bresult = true, is2t = IS_92C_SERIAL(rtlhal->version);
 
 	if (is2t)
@@ -1520,81 +1664,88 @@ static bool sim_comp(struct ieee80211_hw *hw, long result[][8], u8 c1, u8 c2)
 	else
 		bound = 4;
 
-	bitmap = 0;
+	simularity_bitmap = 0;
 
 	for (i = 0; i < bound; i++) {
 		diff = (result[c1][i] > result[c2][i]) ?
-		       (result[c1][i] - result[c2][i]) :
-		       (result[c2][i] - result[c1][i]);
+		    (result[c1][i] - result[c2][i]) :
+		    (result[c2][i] - result[c1][i]);
 
 		if (diff > MAX_TOLERANCE) {
-			if ((i == 2 || i == 6) && !bitmap) {
+			if ((i == 2 || i == 6) && !simularity_bitmap) {
 				if (result[c1][i] + result[c1][i + 1] == 0)
-					final[(i / 4)] = c2;
+					final_candidate[(i / 4)] = c2;
 				else if (result[c2][i] + result[c2][i + 1] == 0)
-					final[(i / 4)] = c1;
+					final_candidate[(i / 4)] = c1;
 				else
-					bitmap = bitmap | (1 << i);
-			} else {
-				bitmap = bitmap | (1 << i);
-			}
+					simularity_bitmap = simularity_bitmap |
+					    (1 << i);
+			} else
+				simularity_bitmap =
+				    simularity_bitmap | (1 << i);
 		}
 	}
 
-	if (bitmap == 0) {
+	if (simularity_bitmap == 0) {
 		for (i = 0; i < (bound / 4); i++) {
-			if (final[i] != 0xFF) {
+			if (final_candidate[i] != 0xFF) {
 				for (j = i * 4; j < (i + 1) * 4 - 2; j++)
-					result[3][j] = result[final[i]][j];
+					result[3][j] =
+					    result[final_candidate[i]][j];
 				bresult = false;
 			}
 		}
 		return bresult;
-	} else if (!(bitmap & 0x0F)) {
+	} else if (!(simularity_bitmap & 0x0F)) {
 		for (i = 0; i < 4; i++)
 			result[3][i] = result[c1][i];
 		return false;
-	} else if (!(bitmap & 0xF0) && is2t) {
+	} else if (!(simularity_bitmap & 0xF0) && is2t) {
 		for (i = 4; i < 8; i++)
 			result[3][i] = result[c1][i];
 		return false;
 	} else {
 		return false;
 	}
+
 }
 
 static void _rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw,
 				     long result[][8], u8 t, bool is2t)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 i;
 	u8 patha_ok, pathb_ok;
-	const u32 adda_reg[IQK_ADDA_REG_NUM] = {
+	u32 adda_reg[IQK_ADDA_REG_NUM] = {
 		0x85c, 0xe6c, 0xe70, 0xe74,
 		0xe78, 0xe7c, 0xe80, 0xe84,
 		0xe88, 0xe8c, 0xed0, 0xed4,
 		0xed8, 0xedc, 0xee0, 0xeec
 	};
-	const u32 iqk_mac_reg[IQK_MAC_REG_NUM] = {
+	u32 iqk_mac_reg[IQK_MAC_REG_NUM] = {
 		0x522, 0x550, 0x551, 0x040
 	};
-	const u32 iqk_bb_reg[IQK_BB_REG_NUM] = {
-		ROFDM0_TRXPATHENABLE, ROFDM0_TRMUXPAR, RFPGA0_XCD_RFINTERFACESW,
-		0xb68, 0xb6c, 0x870, 0x860, 0x864, 0x800
+	u32 iqk_bb_reg[IQK_BB_REG_NUM] = {
+		ROFDM0_TRXPATHENABLE, ROFDM0_TRMUXPAR,
+		RFPGA0_XCD_RFINTERFACESW, 0xb68, 0xb6c,
+		0x870, 0x860, 0x864, 0x800
 	};
 	const u32 retrycount = 2;
 
 	if (t == 0) {
-		save_adda_reg(hw, adda_reg, rtlphy->adda_backup, 16);
-		save_mac_reg(hw, iqk_mac_reg, rtlphy->iqk_mac_backup);
-		save_adda_reg(hw, iqk_bb_reg, rtlphy->iqk_bb_backup,
-			      IQK_BB_REG_NUM);
+		_rtl88e_phy_save_adda_registers(hw, adda_reg,
+						rtlphy->adda_backup, 16);
+		_rtl88e_phy_save_mac_registers(hw, iqk_mac_reg,
+					       rtlphy->iqk_mac_backup);
+		_rtl88e_phy_save_adda_registers(hw, iqk_bb_reg,
+						rtlphy->iqk_bb_backup,
+						IQK_BB_REG_NUM);
 	}
 	_rtl88e_phy_path_adda_on(hw, adda_reg, true, is2t);
 	if (t == 0) {
-		rtlphy->rfpi_enable = (u8) rtl_get_bbreg(hw,
-					   RFPGA0_XA_HSSIPARAMETER1, BIT(8));
+		rtlphy->rfpi_enable =
+		  (u8)rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1, BIT(8));
 	}
 
 	if (!rtlphy->rfpi_enable)
@@ -1652,10 +1803,9 @@ static void _rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw,
 		}
 	}
 
-	if (0 == patha_ok) {
+	if (0 == patha_ok)
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 			 "Path A IQK Success!!\n");
-	}
 	if (is2t) {
 		_rtl88e_phy_path_a_standby(hw);
 		_rtl88e_phy_path_adda_on(hw, adda_reg, false, is2t);
@@ -1663,21 +1813,23 @@ static void _rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw,
 			pathb_ok = _rtl88e_phy_path_b_iqk(hw);
 			if (pathb_ok == 0x03) {
 				result[t][4] = (rtl_get_bbreg(hw,
-						0xeb4, MASKDWORD) &
+							      0xeb4,
+							      MASKDWORD) &
 						0x3FF0000) >> 16;
 				result[t][5] =
 				    (rtl_get_bbreg(hw, 0xebc, MASKDWORD) &
-						   0x3FF0000) >> 16;
+				     0x3FF0000) >> 16;
 				result[t][6] =
 				    (rtl_get_bbreg(hw, 0xec4, MASKDWORD) &
-						   0x3FF0000) >> 16;
+				     0x3FF0000) >> 16;
 				result[t][7] =
 				    (rtl_get_bbreg(hw, 0xecc, MASKDWORD) &
-						   0x3FF0000) >> 16;
+				     0x3FF0000) >> 16;
 				break;
 			} else if (i == (retrycount - 1) && pathb_ok == 0x01) {
 				result[t][4] = (rtl_get_bbreg(hw,
-						0xeb4, MASKDWORD) &
+							      0xeb4,
+							      MASKDWORD) &
 						0x3FF0000) >> 16;
 			}
 			result[t][5] = (rtl_get_bbreg(hw, 0xebc, MASKDWORD) &
@@ -1690,10 +1842,13 @@ static void _rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw,
 	if (t != 0) {
 		if (!rtlphy->rfpi_enable)
 			_rtl88e_phy_pi_mode_switch(hw, false);
-		reload_adda(hw, adda_reg, rtlphy->adda_backup, 16);
-		reload_mac(hw, iqk_mac_reg, rtlphy->iqk_mac_backup);
-		reload_adda(hw, iqk_bb_reg, rtlphy->iqk_bb_backup,
-			    IQK_BB_REG_NUM);
+		_rtl88e_phy_reload_adda_registers(hw, adda_reg,
+						  rtlphy->adda_backup, 16);
+		_rtl88e_phy_reload_mac_registers(hw, iqk_mac_reg,
+						 rtlphy->iqk_mac_backup);
+		_rtl88e_phy_reload_adda_registers(hw, iqk_bb_reg,
+						  rtlphy->iqk_bb_backup,
+						  IQK_BB_REG_NUM);
 
 		rtl_set_bbreg(hw, 0x840, MASKDWORD, 0x00032ed3);
 		if (is2t)
@@ -1709,8 +1864,6 @@ static void _rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 	u8 tmpreg;
 	u32 rf_a_mode = 0, rf_b_mode = 0, lc_cal;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	int jj = RF90_PATH_A;
-	int kk = RF90_PATH_B;
 
 	tmpreg = rtl_read_byte(rtlpriv, 0xd03);
 
@@ -1720,51 +1873,52 @@ static void _rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0xFF);
 
 	if ((tmpreg & 0x70) != 0) {
-		rf_a_mode = rtl_get_rfreg(hw, jj, 0x00, MASK12BITS);
+		rf_a_mode = rtl_get_rfreg(hw, RF90_PATH_A, 0x00, MASK12BITS);
 
 		if (is2t)
-			rf_b_mode = rtl_get_rfreg(hw, kk, 0x00,
+			rf_b_mode = rtl_get_rfreg(hw, RF90_PATH_B, 0x00,
 						  MASK12BITS);
 
-		rtl_set_rfreg(hw, jj, 0x00, MASK12BITS,
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x00, MASK12BITS,
 			      (rf_a_mode & 0x8FFFF) | 0x10000);
 
 		if (is2t)
-			rtl_set_rfreg(hw, kk, 0x00, MASK12BITS,
+			rtl_set_rfreg(hw, RF90_PATH_B, 0x00, MASK12BITS,
 				      (rf_b_mode & 0x8FFFF) | 0x10000);
 	}
-	lc_cal = rtl_get_rfreg(hw, jj, 0x18, MASK12BITS);
+	lc_cal = rtl_get_rfreg(hw, RF90_PATH_A, 0x18, MASK12BITS);
 
-	rtl_set_rfreg(hw, jj, 0x18, MASK12BITS, lc_cal | 0x08000);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x18, MASK12BITS, lc_cal | 0x08000);
 
 	mdelay(100);
 
 	if ((tmpreg & 0x70) != 0) {
 		rtl_write_byte(rtlpriv, 0xd03, tmpreg);
-		rtl_set_rfreg(hw, jj, 0x00, MASK12BITS, rf_a_mode);
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x00, MASK12BITS, rf_a_mode);
 
 		if (is2t)
-			rtl_set_rfreg(hw, kk, 0x00, MASK12BITS,
+			rtl_set_rfreg(hw, RF90_PATH_B, 0x00, MASK12BITS,
 				      rf_b_mode);
 	} else {
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
+RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
+
 }
 
-static void rfpath_switch(struct ieee80211_hw *hw,
-			  bool bmain, bool is2t)
+static void _rtl88e_phy_set_rfpath_switch(struct ieee80211_hw *hw,
+					  bool bmain, bool is2t)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_efuse *fuse = rtl_efuse(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
 
 	if (is_hal_stop(rtlhal)) {
 		u8 u1btmp;
 		u1btmp = rtl_read_byte(rtlpriv, REG_LEDCFG0);
 		rtl_write_byte(rtlpriv, REG_LEDCFG0, u1btmp | BIT(7));
-		rtl_set_bbreg(hw, rFPGA0_XAB_RFPARAMETER, BIT(13), 0x01);
+		rtl_set_bbreg(hw, RFPGA0_XAB_RFPARAMETER, BIT(13), 0x01);
 	}
 	if (is2t) {
 		if (bmain)
@@ -1777,24 +1931,24 @@ static void rfpath_switch(struct ieee80211_hw *hw,
 		rtl_set_bbreg(hw, RFPGA0_XAB_RFINTERFACESW, BIT(8) | BIT(9), 0);
 		rtl_set_bbreg(hw, 0x914, MASKLWORD, 0x0201);
 
-		/* We use the RF definition of MAIN and AUX, left antenna and
-		 * right antenna repectively.
+		/* We use the RF definition of MAIN and AUX,
+		 * left antenna and right antenna repectively.
 		 * Default output at AUX.
 		 */
 		if (bmain) {
-			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE, BIT(14) |
-				      BIT(13) | BIT(12), 0);
-			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE, BIT(5) |
-				      BIT(4) | BIT(3), 0);
-			if (fuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
-				rtl_set_bbreg(hw, RCONFIG_RAM64X16, BIT(31), 0);
+			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE,
+				      BIT(14) | BIT(13) | BIT(12), 0);
+			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
+				      BIT(5) | BIT(4) | BIT(3), 0);
+			if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
+				rtl_set_bbreg(hw, RCONFIG_RAM64x16, BIT(31), 0);
 		} else {
-			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE, BIT(14) |
-				      BIT(13) | BIT(12), 1);
-			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE, BIT(5) |
-				      BIT(4) | BIT(3), 1);
-			if (fuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
-				rtl_set_bbreg(hw, RCONFIG_RAM64X16, BIT(31), 1);
+			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE,
+				      BIT(14) | BIT(13) | BIT(12), 1);
+			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
+				      BIT(5) | BIT(4) | BIT(3), 1);
+			if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
+				rtl_set_bbreg(hw, RCONFIG_RAM64x16, BIT(31), 1);
 		}
 	}
 }
@@ -1802,35 +1956,44 @@ static void rfpath_switch(struct ieee80211_hw *hw,
 #undef IQK_ADDA_REG_NUM
 #undef IQK_DELAY_TIME
 
-void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
+void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	long result[4][8];
-	u8 i, final;
-	bool patha_ok;
-	long reg_e94, reg_e9c, reg_ea4, reg_eb4, reg_ebc, reg_tmp = 0;
+	u8 i, final_candidate;
+	bool b_patha_ok, b_pathb_ok;
+	long reg_e94, reg_e9c, reg_ea4, reg_eac, reg_eb4, reg_ebc, reg_ec4,
+	    reg_ecc, reg_tmp = 0;
 	bool is12simular, is13simular, is23simular;
 	u32 iqk_bb_reg[9] = {
-		ROFDM0_XARXIQIMBAL,
-		ROFDM0_XBRXIQIMBAL,
-		ROFDM0_ECCATHRES,
+		ROFDM0_XARXIQIMBALANCE,
+		ROFDM0_XBRXIQIMBALANCE,
+		ROFDM0_ECCATHRESHOLD,
 		ROFDM0_AGCRSSITABLE,
-		ROFDM0_XATXIQIMBAL,
-		ROFDM0_XBTXIQIMBAL,
+		ROFDM0_XATXIQIMBALANCE,
+		ROFDM0_XBTXIQIMBALANCE,
 		ROFDM0_XCTXAFE,
 		ROFDM0_XDTXAFE,
 		ROFDM0_RXIQEXTANTA
 	};
 
-	if (recovery) {
-		reload_adda(hw, iqk_bb_reg, rtlphy->iqk_bb_backup, 9);
+	if (b_recovery) {
+		_rtl88e_phy_reload_adda_registers(hw,
+						  iqk_bb_reg,
+						  rtlphy->iqk_bb_backup, 9);
 		return;
 	}
 
-	memset(result, 0, 32 * sizeof(long));
-	final = 0xff;
-	patha_ok = false;
+	for (i = 0; i < 8; i++) {
+		result[0][i] = 0;
+		result[1][i] = 0;
+		result[2][i] = 0;
+		result[3][i] = 0;
+	}
+	final_candidate = 0xff;
+	b_patha_ok = false;
+	b_pathb_ok = false;
 	is12simular = false;
 	is23simular = false;
 	is13simular = false;
@@ -1840,29 +2003,32 @@ void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		else
 			_rtl88e_phy_iq_calibrate(hw, result, i, false);
 		if (i == 1) {
-			is12simular = sim_comp(hw, result, 0, 1);
+			is12simular =
+			  _rtl88e_phy_simularity_compare(hw, result, 0, 1);
 			if (is12simular) {
-				final = 0;
+				final_candidate = 0;
 				break;
 			}
 		}
 		if (i == 2) {
-			is13simular = sim_comp(hw, result, 0, 2);
+			is13simular =
+			  _rtl88e_phy_simularity_compare(hw, result, 0, 2);
 			if (is13simular) {
-				final = 0;
+				final_candidate = 0;
 				break;
 			}
-			is23simular = sim_comp(hw, result, 1, 2);
+			is23simular =
+			   _rtl88e_phy_simularity_compare(hw, result, 1, 2);
 			if (is23simular) {
-				final = 1;
+				final_candidate = 1;
 			} else {
 				for (i = 0; i < 8; i++)
 					reg_tmp += result[3][i];
 
 				if (reg_tmp != 0)
-					final = 3;
+					final_candidate = 3;
 				else
-					final = 0xFF;
+					final_candidate = 0xFF;
 			}
 		}
 	}
@@ -1870,47 +2036,55 @@ void rtl88e_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		reg_e94 = result[i][0];
 		reg_e9c = result[i][1];
 		reg_ea4 = result[i][2];
+		reg_eac = result[i][3];
 		reg_eb4 = result[i][4];
 		reg_ebc = result[i][5];
+		reg_ec4 = result[i][6];
+		reg_ecc = result[i][7];
 	}
-	if (final != 0xff) {
-		reg_e94 = result[final][0];
-		rtlphy->reg_e94 = reg_e94;
-		reg_e9c = result[final][1];
-		rtlphy->reg_e9c = reg_e9c;
-		reg_ea4 = result[final][2];
-		reg_eb4 = result[final][4];
+	if (final_candidate != 0xff) {
+		reg_e94 = result[final_candidate][0];
+		reg_e9c = result[final_candidate][1];
+		reg_ea4 = result[final_candidate][2];
+		reg_eac = result[final_candidate][3];
+		reg_eb4 = result[final_candidate][4];
+		reg_ebc = result[final_candidate][5];
+		reg_ec4 = result[final_candidate][6];
+		reg_ecc = result[final_candidate][7];
 		rtlphy->reg_eb4 = reg_eb4;
-		reg_ebc = result[final][5];
 		rtlphy->reg_ebc = reg_ebc;
-		patha_ok = true;
+		rtlphy->reg_e94 = reg_e94;
+		rtlphy->reg_e9c = reg_e9c;
+		b_patha_ok = true;
+		b_pathb_ok = true;
 	} else {
 		rtlphy->reg_e94 = 0x100;
 		rtlphy->reg_eb4 = 0x100;
-		rtlphy->reg_ebc = 0x0;
 		rtlphy->reg_e9c = 0x0;
+		rtlphy->reg_ebc = 0x0;
 	}
 	if (reg_e94 != 0) /*&&(reg_ea4 != 0) */
-		fill_iqk(hw, patha_ok, result, final, (reg_ea4 == 0));
-	if (final != 0xFF) {
+		_rtl88e_phy_path_a_fill_iqk_matrix(hw, b_patha_ok, result,
+						   final_candidate,
+						   (reg_ea4 == 0));
+	if (final_candidate != 0xFF) {
 		for (i = 0; i < IQK_MATRIX_REG_NUM; i++)
-			rtlphy->iqk_matrix[0].value[0][i] = result[final][i];
+			rtlphy->iqk_matrix[0].value[0][i] =
+				result[final_candidate][i];
 		rtlphy->iqk_matrix[0].iqk_done = true;
+
 	}
-	save_adda_reg(hw, iqk_bb_reg, rtlphy->iqk_bb_backup, 9);
+	_rtl88e_phy_save_adda_registers(hw, iqk_bb_reg,
+					rtlphy->iqk_bb_backup, 9);
 }
 
 void rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	struct rtl_hal *rtlhal = &(rtlpriv->rtlhal);
-	bool start_conttx = false, singletone = false;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct rtl_hal *rtlhal = &rtlpriv->rtlhal;
 	u32 timeout = 2000, timecount = 0;
 
-	if (start_conttx || singletone)
-		return;
-
 	while (rtlpriv->mac80211.act_scanning && timecount < timeout) {
 		udelay(50);
 		timecount += 50;
@@ -1928,18 +2102,18 @@ void rtl88e_phy_lc_calibrate(struct ieee80211_hw *hw)
 
 void rtl88e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain)
 {
-	rfpath_switch(hw, bmain, false);
+	_rtl88e_phy_set_rfpath_switch(hw, bmain, false);
 }
 
 bool rtl88e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	bool postprocessing = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 		 "-->IO Cmd(%#x), set_io_inprogress(%d)\n",
-		 iotype, rtlphy->set_io_inprogress);
+		  iotype, rtlphy->set_io_inprogress);
 	do {
 		switch (iotype) {
 		case IO_CMD_RESUME_DM_BY_SCAN:
@@ -1947,14 +2121,14 @@ bool rtl88e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 				 "[IO CMD] Resume DM after scan.\n");
 			postprocessing = true;
 			break;
-		case IO_CMD_PAUSE_DM_BY_SCAN:
+		case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 				 "[IO CMD] Pause DM before scan.\n");
 			postprocessing = true;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			break;
 		}
 	} while (false);
@@ -1969,6 +2143,37 @@ bool rtl88e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 	return true;
 }
 
+static void rtl88e_phy_set_io(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
+		  rtlphy->current_io_type, rtlphy->set_io_inprogress);
+	switch (rtlphy->current_io_type) {
+	case IO_CMD_RESUME_DM_BY_SCAN:
+		dm_digtable->cur_igvalue = rtlphy->initgain_backup.xaagccore1;
+		/*rtl92c_dm_write_dig(hw);*/
+		rtl88e_phy_set_txpower_level(hw, rtlphy->current_channel);
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
 static void rtl88ee_phy_set_rf_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1984,10 +2189,9 @@ static void rtl88ee_phy_set_rf_on(struct ieee80211_hw *hw)
 static void _rtl88ee_phy_set_rf_sleep(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	int jj = RF90_PATH_A;
 
 	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0xFF);
-	rtl_set_rfreg(hw, jj, 0x00, RFREG_OFFSET_MASK, 0x00);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x00, RFREG_OFFSET_MASK, 0x00);
 	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
 	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x22);
 }
@@ -1999,42 +2203,49 @@ static bool _rtl88ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	struct rtl8192_tx_ring *ring = NULL;
 	bool bresult = true;
 	u8 i, queue_id;
+	struct rtl8192_tx_ring *ring = NULL;
 
 	switch (rfpwr_state) {
-	case ERFON:{
+	case ERFON:
 		if ((ppsc->rfpwr_state == ERFOFF) &&
 		    RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC)) {
 			bool rtstatus;
-			u32 init = 0;
+			u32 initializecount = 0;
+
 			do {
-				init++;
+				initializecount++;
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
-			} while ((rtstatus != true) && (init < 10));
+			} while (!rtstatus &&
+				 (initializecount < 10));
 			RT_CLEAR_PS_LEVEL(ppsc,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "Set ERFON sleeped:%d ms\n",
-				 jiffies_to_msecs(jiffies - ppsc->
-						  last_sleep_jiffies));
+				  jiffies_to_msecs(jiffies -
+						   ppsc->
+						   last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
 			rtl88ee_phy_set_rf_on(hw);
 		}
-		if (mac->link_state == MAC80211_LINKED)
-			rtlpriv->cfg->ops->led_control(hw, LED_CTL_LINK);
-		else
-			rtlpriv->cfg->ops->led_control(hw, LED_CTL_NO_LINK);
-		break; }
-	case ERFOFF:{
+		if (mac->link_state == MAC80211_LINKED) {
+			rtlpriv->cfg->ops->led_control(hw,
+						       LED_CTL_LINK);
+		} else {
+			rtlpriv->cfg->ops->led_control(hw,
+						       LED_CTL_NO_LINK);
+		}
+		break;
+	case ERFOFF:
 		for (queue_id = 0, i = 0;
 		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
 			ring = &pcipriv->dev.tx_ring[queue_id];
-			if (skb_queue_len(&ring->queue) == 0) {
+			if (queue_id == BEACON_QUEUE ||
+			    skb_queue_len(&ring->queue) == 0) {
 				queue_id++;
 				continue;
 			} else {
@@ -2055,6 +2266,7 @@ static bool _rtl88ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				break;
 			}
 		}
+
 		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "IPS Set eRf nic disable\n");
@@ -2063,49 +2275,51 @@ static bool _rtl88ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		} else {
 			if (ppsc->rfoff_reason == RF_CHANGE_BY_IPS) {
 				rtlpriv->cfg->ops->led_control(hw,
-						LED_CTL_NO_LINK);
+							       LED_CTL_NO_LINK);
 			} else {
 				rtlpriv->cfg->ops->led_control(hw,
-						LED_CTL_POWER_OFF);
+							       LED_CTL_POWER_OFF);
 			}
 		}
-		break; }
+		break;
 	case ERFSLEEP:{
-		if (ppsc->rfpwr_state == ERFOFF)
-			break;
-		for (queue_id = 0, i = 0;
-		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
-			ring = &pcipriv->dev.tx_ring[queue_id];
-			if (skb_queue_len(&ring->queue) == 0) {
-				queue_id++;
-				continue;
-			} else {
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
-					 (i + 1), queue_id,
-					 skb_queue_len(&ring->queue));
-
-				udelay(10);
-				i++;
-			}
-			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "\n ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
-					 MAX_DOZE_WAITING_TIMES_9x,
-					 queue_id,
-					 skb_queue_len(&ring->queue));
+			if (ppsc->rfpwr_state == ERFOFF)
 				break;
+			for (queue_id = 0, i = 0;
+			     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
+				ring = &pcipriv->dev.tx_ring[queue_id];
+				if (skb_queue_len(&ring->queue) == 0) {
+					queue_id++;
+					continue;
+				} else {
+					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+						 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+						 (i + 1), queue_id,
+						 skb_queue_len(&ring->queue));
+
+					udelay(10);
+					i++;
+				}
+				if (i >= MAX_DOZE_WAITING_TIMES_9x) {
+					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+						 "\n ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+						 MAX_DOZE_WAITING_TIMES_9x,
+						 queue_id,
+						 skb_queue_len(&ring->queue));
+					break;
+				}
 			}
+			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
+				 "Set ERFSLEEP awaked:%d ms\n",
+				  jiffies_to_msecs(jiffies -
+				  ppsc->last_awake_jiffies));
+			ppsc->last_sleep_jiffies = jiffies;
+			_rtl88ee_phy_set_rf_sleep(hw);
+			break;
 		}
-		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 "Set ERFSLEEP awaked:%d ms\n",
-			 jiffies_to_msecs(jiffies - ppsc->last_awake_jiffies));
-		ppsc->last_sleep_jiffies = jiffies;
-		_rtl88ee_phy_set_rf_sleep(hw);
-		break; }
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
 		bresult = false;
 		break;
 	}
@@ -2118,10 +2332,11 @@ bool rtl88e_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				   enum rf_pwrstate rfpwr_state)
 {
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	bool bresult;
+
+	bool bresult = false;
 
 	if (rfpwr_state == ppsc->rfpwr_state)
-		return false;
+		return bresult;
 	bresult = _rtl88ee_phy_set_rf_power_state(hw, rfpwr_state);
 	return bresult;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
index 89f0f1e..b29bd77 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
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
@@ -30,33 +26,35 @@
 #ifndef __RTL92C_PHY_H__
 #define __RTL92C_PHY_H__
 
-/*It must always set to 4, otherwise read efuse table secquence will be wrong.*/
-#define	MAX_TX_COUNT				4
+/* MAX_TX_COUNT must always set to 4, otherwise read efuse
+ * table secquence will be wrong.
+ */
+#define		MAX_TX_COUNT				4
 
 #define MAX_PRECMD_CNT				16
-#define MAX_RFDEPENDCMD_CNT			16
+#define MAX_RFDEPENDCMD_CNT		16
 #define MAX_POSTCMD_CNT				16
 
-#define MAX_DOZE_WAITING_TIMES_9x		64
+#define MAX_DOZE_WAITING_TIMES_9x	64
 
 #define RT_CANNOT_IO(hw)			false
-#define HIGHPOWER_RADIOA_ARRAYLEN		22
+#define HIGHPOWER_RADIOA_ARRAYLEN	22
 
 #define IQK_ADDA_REG_NUM			16
 #define IQK_BB_REG_NUM				9
 #define MAX_TOLERANCE				5
 #define	IQK_DELAY_TIME				10
-#define	IDX_MAP					15
+#define	INDEX_MAPPING_NUM	15
 
 #define	APK_BB_REG_NUM				5
 #define	APK_AFE_REG_NUM				16
 #define	APK_CURVE_REG_NUM			4
-#define	PATH_NUM				2
+#define	PATH_NUM					2
 
-#define LOOP_LIMIT				5
+#define LOOP_LIMIT					5
 #define MAX_STALL_TIME				50
-#define ANTENNADIVERSITYVALUE			0x80
-#define MAX_TXPWR_IDX_NMODE_92S			63
+#define ANTENNADIVERSITYVALUE		0x80
+#define MAX_TXPWR_IDX_NMODE_92S		63
 #define RESET_CNT_LIMIT				3
 
 #define IQK_ADDA_REG_NUM			16
@@ -66,8 +64,8 @@
 
 #define CT_OFFSET_MAC_ADDR			0X16
 
-#define CT_OFFSET_CCK_TX_PWR_IDX		0x5A
-#define CT_OFFSET_HT401S_TX_PWR_IDX		0x60
+#define CT_OFFSET_CCK_TX_PWR_IDX			0x5A
+#define CT_OFFSET_HT401S_TX_PWR_IDX			0x60
 #define CT_OFFSET_HT402S_TX_PWR_IDX_DIFF	0x66
 #define CT_OFFSET_HT20_TX_PWR_IDX_DIFF		0x69
 #define CT_OFFSET_OFDM_TX_PWR_IDX_DIFF		0x6C
@@ -75,13 +73,13 @@
 #define CT_OFFSET_HT40_MAX_PWR_OFFSET		0x6F
 #define CT_OFFSET_HT20_MAX_PWR_OFFSET		0x72
 
-#define CT_OFFSET_CHANNEL_PLAH			0x75
-#define CT_OFFSET_THERMAL_METER			0x78
-#define CT_OFFSET_RF_OPTION			0x79
-#define CT_OFFSET_VERSION			0x7E
-#define CT_OFFSET_CUSTOMER_ID			0x7F
+#define CT_OFFSET_CHANNEL_PLAH				0x75
+#define CT_OFFSET_THERMAL_METER				0x78
+#define CT_OFFSET_RF_OPTION					0x79
+#define CT_OFFSET_VERSION					0x7E
+#define CT_OFFSET_CUSTOMER_ID				0x7F
 
-#define RTL92C_MAX_PATH_NUM			2
+#define RTL92C_MAX_PATH_NUM					2
 
 enum swchnlcmd_id {
 	CMDID_END,
@@ -160,7 +158,6 @@ struct r_antenna_select_cck {
 	u8 r_ccktx_enable:4;
 };
 
-
 struct efuse_contents {
 	u8 mac_addr[ETH_ALEN];
 	u8 cck_tx_power_idx[6];
@@ -192,10 +189,10 @@ struct tx_power_struct {
 };
 
 enum _ANT_DIV_TYPE {
-	NO_ANTDIV			= 0xFF,
+	NO_ANTDIV				= 0xFF,
 	CG_TRX_HW_ANTDIV		= 0x01,
 	CGCS_RX_HW_ANTDIV		= 0x02,
-	FIXED_HW_ANTDIV			= 0x03,
+	FIXED_HW_ANTDIV         = 0x03,
 	CG_TRX_SMART_ANTDIV		= 0x04,
 	CGCS_RX_SW_ANTDIV		= 0x05,
 };
@@ -217,6 +214,8 @@ void rtl88e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
 void rtl88e_phy_get_txpower_level(struct ieee80211_hw *hw,
 				  long *powerlevel);
 void rtl88e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
+void rtl88e_phy_scan_operation_backup(struct ieee80211_hw *hw,
+				      u8 operation);
 void rtl88e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
 void rtl88e_phy_set_bw_mode(struct ieee80211_hw *hw,
 			    enum nl80211_channel_type ch_type);
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
index 6dc4e3a..02013df 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
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
@@ -27,83 +23,83 @@
  *
  *****************************************************************************/
 
-#include "pwrseqcmd.h"
+#include "../pwrseqcmd.h"
 #include "pwrseq.h"
 
 /* drivers should parse below arrays and do the corresponding actions */
 /*3 Power on  Array*/
-struct wlan_pwr_cfg rtl8188e_power_on_flow[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS +
-					   RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_CARDEMU_TO_ACT
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_power_on_flow[RTL8188EE_TRANS_CARDEMU_TO_ACT_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_CARDEMU_TO_ACT
+	RTL8188EE_TRANS_END
 };
 
 /*3Radio off GPIO Array */
-struct wlan_pwr_cfg rtl8188e_radio_off_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
-					    + RTL8188E_TRANS_END_STEPS] = {
-	RTL8188E_TRANS_ACT_TO_CARDEMU
-	RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_radio_off_flow[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS
+					+ RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_ACT_TO_CARDEMU
+	RTL8188EE_TRANS_END
 };
 
 /*3Card Disable Array*/
-struct wlan_pwr_cfg rtl8188e_card_disable_flow
-	[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-	RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-	RTL8188E_TRANS_END_STEPS] = {
-		RTL8188E_TRANS_ACT_TO_CARDEMU
-		RTL8188E_TRANS_CARDEMU_TO_CARDDIS
-		RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_card_disable_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_ACT_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_CARDDIS
+	RTL8188EE_TRANS_END
 };
 
 /*3 Card Enable Array*/
-struct wlan_pwr_cfg rtl8188e_card_enable_flow
-	[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-	RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-	RTL8188E_TRANS_END_STEPS] = {
-		RTL8188E_TRANS_CARDDIS_TO_CARDEMU
-		RTL8188E_TRANS_CARDEMU_TO_ACT
-		RTL8188E_TRANS_END
+struct wlan_pwr_cfg rtl8188ee_card_enable_flow
+		[RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8188EE_TRANS_END_STEPS] = {
+	RTL8188EE_TRANS_CARDDIS_TO_CARDEMU
+	RTL8188EE_TRANS_CARDEMU_TO_ACT
+	RTL8188EE_TRANS_END
 };
 
 /*3Suspend Array*/
-struct wlan_pwr_cfg rtl8188e_suspend_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
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
-struct wlan_pwr_cfg rtl8188e_resume_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
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
-struct wlan_pwr_cfg rtl8188e_hwpdn_flow[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS
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
-struct wlan_pwr_cfg rtl8188e_enter_lps_flow[RTL8188E_TRANS_ACT_TO_LPS_STEPS
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
-struct wlan_pwr_cfg rtl8188e_leave_lps_flow[RTL8188E_TRANS_LPS_TO_ACT_STEPS
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
index 45c7f4a..4a6c777 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
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
@@ -30,297 +26,286 @@
 #ifndef __RTL8723E_PWRSEQ_H__
 #define __RTL8723E_PWRSEQ_H__
 
-/*
-	Check document WM-20110607-Paul-RTL8188E_Power_Architecture-R02.vsd
-	There are 6 HW Power States:
-	0: POFF--Power Off
-	1: PDN--Power Down
-	2: CARDEMU--Card Emulation
-	3: ACT--Active Mode
-	4: LPS--Low Power State
-	5: SUS--Suspend
-
-	The transision from different states are defined below
-	TRANS_CARDEMU_TO_ACT
-	TRANS_ACT_TO_CARDEMU
-	TRANS_CARDEMU_TO_SUS
-	TRANS_SUS_TO_CARDEMU
-	TRANS_CARDEMU_TO_PDN
-	TRANS_ACT_TO_LPS
-	TRANS_LPS_TO_ACT
-
-	TRANS_END
-	PWR SEQ Version: rtl8188e_PwrSeq_V09.h
-*/
-
-#define	RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS	10
-#define	RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS	10
-#define	RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS	10
-#define	RTL8188E_TRANS_SUS_TO_CARDEMU_STEPS	10
-#define	RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS	10
-#define	RTL8188E_TRANS_PDN_TO_CARDEMU_STEPS	10
-#define	RTL8188E_TRANS_ACT_TO_LPS_STEPS		15
-#define	RTL8188E_TRANS_LPS_TO_ACT_STEPS		15
-#define	RTL8188E_TRANS_END_STEPS		1
+#include "../pwrseqcmd.h"
+/* Check document WM-20110607-Paul-RTL8188E_Power_Architecture-R02.vsd
+ *	There are 6 HW Power States:
+ *	0: POFF--Power Off
+ *	1: PDN--Power Down
+ *	2: CARDEMU--Card Emulation
+ *	3: ACT--Active Mode
+ *	4: LPS--Low Power State
+ *	5: SUS--Suspend
+ *
+ *	The transition from different states are defined below
+ *	TRANS_CARDEMU_TO_ACT
+ *	TRANS_ACT_TO_CARDEMU
+ *	TRANS_CARDEMU_TO_SUS
+ *	TRANS_SUS_TO_CARDEMU
+ *	TRANS_CARDEMU_TO_PDN
+ *	TRANS_ACT_TO_LPS
+ *	TRANS_LPS_TO_ACT
+ *
+ *	TRANS_END
+ *	PWR SEQ Version: rtl8188E_PwrSeq_V09.h
+ */
 
+#define	RTL8188EE_TRANS_CARDEMU_TO_ACT_STEPS	10
+#define	RTL8188EE_TRANS_ACT_TO_CARDEMU_STEPS	10
+#define	RTL8188EE_TRANS_CARDEMU_TO_SUS_STEPS	10
+#define	RTL8188EE_TRANS_SUS_TO_CARDEMU_STEPS	10
+#define	RTL8188EE_TRANS_CARDEMU_TO_PDN_STEPS	10
+#define	RTL8188EE_TRANS_PDN_TO_CARDEMU_STEPS	10
+#define	RTL8188EE_TRANS_ACT_TO_LPS_STEPS	15
+#define	RTL8188EE_TRANS_LPS_TO_ACT_STEPS	15
+#define	RTL8188EE_TRANS_END_STEPS		1
 
-#define RTL8188E_TRANS_CARDEMU_TO_ACT					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+/* The following macros have the following format:
+ * { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value
+ *   comments },
+ */
+#define RTL8188EE_TRANS_CARDEMU_TO_ACT					\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/* wait till 0x04[17] = 1    power ready*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)		\
+	/* wait till 0x04[17] = 1    power ready*/},			\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/* 0x02[1:0] = 0	reset BB*/				\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0)|BIT(1), 0},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0)|BIT(1), 0		\
+	/* 0x02[1:0] = 0	reset BB*/},				\
 	{0x0026, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*0x24[23] = 2b'01 schmit trigger */				\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)			\
+	/*0x24[23] = 2b'01 schmit trigger */},				\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/* 0x04[15] = 0 disable HWPDN (control by DRV)*/		\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0			\
+	/* 0x04[15] = 0 disable HWPDN (control by DRV)*/},		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*0x04[12:11] = 2b'00 disable WL suspend*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4)|BIT(3), 0},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4)|BIT(3), 0		\
+	/*0x04[12:11] = 2b'00 disable WL suspend*/},			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*0x04[8] = 1 polling until return 0*/				\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)			\
+	/*0x04[8] = 1 polling until return 0*/},			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*wait till 0x04[8] = 0*/					\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0			\
+	/*wait till 0x04[8] = 0*/},					\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0}, /*LDO normal mode*/\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0			\
+	/*LDO normal mode*/},						\
 	{0x0074, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)}, /*SDIO Driving*/\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)			\
+	/*SDIO Driving*/},
 
-#define RTL8188E_TRANS_ACT_TO_CARDEMU					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+#define RTL8188EE_TRANS_ACT_TO_CARDEMU					\
 	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},/*0x1F[7:0] = 0 turn off RF*/\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0			\
+	/*0x1F[7:0] = 0 turn off RF*/},					\
 	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)}, /*LDO Sleep mode*/\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)			\
+	/*LDO Sleep mode*/},						\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*0x04[9] = 1 turn off MAC by HW state machine*/		\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)			\
+	/*0x04[9] = 1 turn off MAC by HW state machine*/},		\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*wait till 0x04[9] = 0 polling until return 0 to disable*/	\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0			\
+	/*wait till 0x04[9] = 0 polling until return 0 to disable*/},
 
-
-#define RTL8188E_TRANS_CARDEMU_TO_SUS					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+#define RTL8188EE_TRANS_CARDEMU_TO_SUS					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*0x04[12:11] = 2b'01enable WL suspend*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)		\
+	/*0x04[12:11] = 2b'01enable WL suspend*/},			\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-	/*0x04[12:11] = 2b'11enable WL suspend for PCIe*/		\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)|BIT(4)},\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)|BIT(4)	\
+	/*0x04[12:11] = 2b'11enable WL suspend for PCIe*/},		\
 	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*  0x04[31:30] = 2b'10 enable enable bandgap mbias in suspend */\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, BIT(7)},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, BIT(7)			\
+	/*  0x04[31:30] = 2b'10 enable enable bandgap mbias in suspend */},\
 	{0x0041, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*Clear SIC_EN register 0x40[12] = 1'b0 */			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0			\
+	/*Clear SIC_EN register 0x40[12] = 1'b0 */},			\
 	{0xfe10, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*Set USB suspend enable local register  0xfe10[4]= 1 */	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)			\
+	/*Set USB suspend enable local register  0xfe10[4]=1 */},	\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	/*Set SDIO suspend local register*/				\
-	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)		\
+	/*Set SDIO suspend local register*/},				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	/*wait power state to suspend*/					\
-	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0},
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0			\
+	/*wait power state to suspend*/},
 
-#define RTL8188E_TRANS_SUS_TO_CARDEMU					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+#define RTL8188EE_TRANS_SUS_TO_CARDEMU					\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	/*Set SDIO suspend local register*/				\
-	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},			\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0			\
+	/*Set SDIO suspend local register*/},				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	/*wait power state to suspend*/					\
-	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)		\
+	/*wait power state to suspend*/},				\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*0x04[12:11] = 2b'01enable WL suspend*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(4), 0		\
+	/*0x04[12:11] = 2b'01enable WL suspend*/},
 
-#define RTL8188E_TRANS_CARDEMU_TO_CARDDIS				\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+#define RTL8188EE_TRANS_CARDEMU_TO_CARDDIS				\
 	{0x0026, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*0x24[23] = 2b'01 schmit trigger */				\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)			\
+	/*0x24[23] = 2b'01 schmit trigger */},				\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*0x04[12:11] = 2b'01 enable WL suspend*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(4), BIT(3)	\
+	/*0x04[12:11] = 2b'01 enable WL suspend*/},			\
 	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*  0x04[31:30] = 2b'10 enable enable bandgap mbias in suspend */\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0			\
+	/*  0x04[31:30] = 2b'10 enable enable bandgap mbias in suspend */},\
 	{0x0041, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
 	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-	/*Clear SIC_EN register 0x40[12] = 1'b0 */			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0			\
+	/*Clear SIC_EN register 0x40[12] = 1'b0 */},			\
 	{0xfe10, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
-	/*Set USB suspend enable local register  0xfe10[4]= 1 */	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)			\
+	/*Set USB suspend enable local register  0xfe10[4]=1 */},	\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	/*Set SDIO suspend local register*/				\
-	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)		\
+	/*Set SDIO suspend local register*/},				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	PWR_CMD_POLLING, BIT(1), 0}, /*wait power state to suspend*/
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0			\
+	/*wait power state to suspend*/},
 
-#define RTL8188E_TRANS_CARDDIS_TO_CARDEMU				\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+#define RTL8188EE_TRANS_CARDDIS_TO_CARDEMU				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	PWR_BASEADDR_SDIO,\
-	PWR_CMD_WRITE, BIT(0), 0}, /*Set SDIO suspend local register*/	\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0			\
+	/*Set SDIO suspend local register*/},				\
 	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	PWR_BASEADDR_SDIO,\
-	PWR_CMD_POLLING, BIT(1), BIT(1)}, /*wait power state to suspend*/\
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)		\
+	/*wait power state to suspend*/},				\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC,						\
-	PWR_CMD_WRITE, BIT(3)|BIT(4), 0},				\
-	/*0x04[12:11] = 2b'01enable WL suspend*/
-
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0		\
+	/*0x04[12:11] = 2b'01enable WL suspend*/},
 
-#define RTL8188E_TRANS_CARDEMU_TO_PDN					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+#define RTL8188EE_TRANS_CARDEMU_TO_PDN					\
 	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},/* 0x04[16] = 0*/	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0/* 0x04[16] = 0*/},	\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)},/* 0x04[15] = 1*/
-
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)			\
+	/* 0x04[15] = 1*/},
 
-#define RTL8188E_TRANS_PDN_TO_CARDEMU					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+#define RTL8188EE_TRANS_PDN_TO_CARDEMU					\
 	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},/* 0x04[15] = 0*/
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0/* 0x04[15] = 0*/},
 
-
-#define RTL8188E_TRANS_ACT_TO_LPS					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+#define RTL8188EE_TRANS_ACT_TO_LPS					\
 	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x7F},/*Tx Pause*/	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x7F			\
+	/*Tx Pause*/},							\
 	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*zero if no pkt is tx*/\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0			\
+	/*Should be zero if no packet is transmitting*/},		\
 	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*Should be zero if no packet is transmitting*/	\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0			\
+	/*Should be zero if no packet is transmitting*/},		\
 	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*Should be zero if no packet is transmitting*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0			\
+	/*Should be zero if no packet is transmitting*/},		\
 	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*Should be zero if no packet is transmitting*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0			\
+	/*Should be zero if no packet is transmitting*/},		\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*CCK and OFDM are disabled, and clock are gated*/		\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0			\
+	/*CCK and OFDM are disabled,and clock are gated*/},		\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},/*Delay 1us*/\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US		\
+	/*Delay 1us*/},							\
 	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x3F},/*Reset MAC TRX*/	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x3F			\
+	/*Reset MAC TRX*/},						\
 	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*check if removed later*/					\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0			\
+	/*check if removed later*/},					\
 	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*Respond TxOK to scheduler*/					\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), BIT(5)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), BIT(5)			\
+	/*Respond TxOK to scheduler*/},
 
 
-#define RTL8188E_TRANS_LPS_TO_ACT					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+#define RTL8188EE_TRANS_LPS_TO_ACT					\
 	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84}, /*SDIO RPWM*/	\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84			\
+	/*SDIO RPWM*/},							\
 	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84}, /*USB RPWM*/	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84			\
+	/*USB RPWM*/},							\
 	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84}, /*PCIe RPWM*/	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84			\
+	/*PCIe RPWM*/},							\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS}, /*Delay*/	\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS		\
+	/*Delay*/},							\
 	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*.	0x08[4] = 0		 switch TSF to 40M*/		\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0			\
+	/*.	0x08[4] = 0		 switch TSF to 40M*/},		\
 	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*Polling 0x109[7]= 0  TSF in 40M*/				\
-	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0},			\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0			\
+	/*Polling 0x109[7]=0  TSF in 40M*/},				\
 	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*. 0x29[7:6] = 2b'00	 enable BB clock*/			\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6)|BIT(7), 0},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6)|BIT(7), 0		\
+	/*.	0x29[7:6] = 2b'00	 enable BB clock*/},		\
 	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*.	0x101[1] = 1*/\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)			\
+	/*.	0x101[1] = 1*/},					\
 	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*.	0x100[7:0] = 0xFF	 enable WMAC TRX*/\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF			\
+	/*.	0x100[7:0] = 0xFF	 enable WMAC TRX*/},		\
 	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-	/*. 0x02[1:0] = 2b'11  enable BB macro*/\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1)|BIT(0), BIT(1)|BIT(0)},	\
-	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
-	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0}, /*.	0x522 = 0*/
-
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1)|BIT(0), BIT(1)|BIT(0)	\
+	/*.	0x02[1:0] = 2b'11	 enable BB macro*/},		\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0			\
+	/*.	0x522 = 0*/},
 
-#define RTL8188E_TRANS_END						\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+#define RTL8188EE_TRANS_END		\
 	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
 	0, PWR_CMD_END, 0, 0}
 
-extern struct wlan_pwr_cfg rtl8188e_power_on_flow
-		[RTL8188E_TRANS_CARDEMU_TO_ACT_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_radio_off_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_card_disable_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_card_enable_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_suspend_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_resume_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		RTL8188E_TRANS_CARDEMU_TO_SUS_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_hwpdn_flow
-		[RTL8188E_TRANS_ACT_TO_CARDEMU_STEPS +
-		RTL8188E_TRANS_CARDEMU_TO_PDN_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_enter_lps_flow
-		[RTL8188E_TRANS_ACT_TO_LPS_STEPS +
-		RTL8188E_TRANS_END_STEPS];
-extern struct wlan_pwr_cfg rtl8188e_leave_lps_flow
-		[RTL8188E_TRANS_LPS_TO_ACT_STEPS +
-		RTL8188E_TRANS_END_STEPS];
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
-#define RTL8188E_NIC_PWR_ON_FLOW	rtl8188e_power_on_flow
-#define RTL8188E_NIC_RF_OFF_FLOW	rtl8188e_radio_off_flow
-#define RTL8188E_NIC_DISABLE_FLOW	rtl8188e_card_disable_flow
-#define RTL8188E_NIC_ENABLE_FLOW	rtl8188e_card_enable_flow
-#define RTL8188E_NIC_SUSPEND_FLOW	rtl8188e_suspend_flow
-#define RTL8188E_NIC_RESUME_FLOW	rtl8188e_resume_flow
-#define RTL8188E_NIC_PDN_FLOW		rtl8188e_hwpdn_flow
-#define RTL8188E_NIC_LPS_ENTER_FLOW	rtl8188e_enter_lps_flow
-#define RTL8188E_NIC_LPS_LEAVE_FLOW	rtl8188e_leave_lps_flow
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
index 3a95ddb..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
+++ /dev/null
@@ -1,140 +0,0 @@
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
-
-/*	Description:
- *		This routine deal with the Power Configuration CMDs
- *		 parsing for RTL8723/RTL8188E Series IC.
- *	Assumption:
- *		We should follow specific format which was released from HW SD.
- *
- *	2011.07.07, added by Roger.
- */
-
-bool rtl88_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-				u8 fab_version, u8 interface_type,
-				struct wlan_pwr_cfg pwrcfgcmd[])
-{
-	struct wlan_pwr_cfg cmd = {0};
-	bool polling_bit = false;
-	u32 ary_idx = 0;
-	u8 val = 0;
-	u32 offset = 0;
-	u32 polling_count = 0;
-	u32 max_polling_cnt = 5000;
-
-	do {
-		cmd = pwrcfgcmd[ary_idx];
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "rtl88_hal_pwrseqcmdparsing(): offset(%#x), cut_msk(%#x), fab_msk(%#x),"
-			 "interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), val(%#x)\n",
-			 GET_PWR_CFG_OFFSET(cmd),
-			 GET_PWR_CFG_CUT_MASK(cmd),
-			 GET_PWR_CFG_FAB_MASK(cmd),
-			 GET_PWR_CFG_INTF_MASK(cmd),
-			 GET_PWR_CFG_BASE(cmd),
-			 GET_PWR_CFG_CMD(cmd),
-			 GET_PWR_CFG_MASK(cmd),
-			 GET_PWR_CFG_VALUE(cmd));
-
-		if ((GET_PWR_CFG_FAB_MASK(cmd) & fab_version) &&
-		    (GET_PWR_CFG_CUT_MASK(cmd) & cut_version) &&
-		    (GET_PWR_CFG_INTF_MASK(cmd) & interface_type)) {
-			switch (GET_PWR_CFG_CMD(cmd)) {
-			case PWR_CMD_READ:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl88_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
-				break;
-			case PWR_CMD_WRITE: {
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl88_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
-				offset = GET_PWR_CFG_OFFSET(cmd);
-
-					/*Read the val from system register*/
-					val = rtl_read_byte(rtlpriv, offset);
-					val &= (~(GET_PWR_CFG_MASK(cmd)));
-					val |= (GET_PWR_CFG_VALUE(cmd) &
-						GET_PWR_CFG_MASK(cmd));
-
-					/*Write the val back to sytem register*/
-					rtl_write_byte(rtlpriv, offset, val);
-				}
-				break;
-			case PWR_CMD_POLLING:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl88_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
-				polling_bit = false;
-				offset = GET_PWR_CFG_OFFSET(cmd);
-
-				do {
-					val = rtl_read_byte(rtlpriv, offset);
-
-					val = val & GET_PWR_CFG_MASK(cmd);
-					if (val == (GET_PWR_CFG_VALUE(cmd) &
-						    GET_PWR_CFG_MASK(cmd)))
-						polling_bit = true;
-					else
-						udelay(10);
-
-					if (polling_count++ > max_polling_cnt) {
-						RT_TRACE(rtlpriv, COMP_INIT,
-							 DBG_LOUD,
-							 "polling fail in pwrseqcmd\n");
-						return false;
-					}
-				} while (!polling_bit);
-
-				break;
-			case PWR_CMD_DELAY:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl88_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
-				if (GET_PWR_CFG_VALUE(cmd) == PWRSEQ_DELAY_US)
-					udelay(GET_PWR_CFG_OFFSET(cmd));
-				else
-					mdelay(GET_PWR_CFG_OFFSET(cmd));
-				break;
-			case PWR_CMD_END:
-				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 "rtl88_hal_pwrseqcmdparsing(): PWR_CMD_END\n");
-				return true;
-			default:
-				RT_ASSERT(false,
-					  "rtl88_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
-				break;
-			}
-		}
-
-		ary_idx++;
-	} while (1);
-
-	return true;
-}
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
deleted file mode 100644
index a6cdb0d..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
+++ /dev/null
@@ -1,93 +0,0 @@
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
-#define PWR_INTF_SDIO_MSK	BIT(0)
-#define PWR_INTF_USB_MSK	BIT(1)
-#define PWR_INTF_PCI_MSK	BIT(2)
-#define PWR_INTF_ALL_MSK	(BIT(0)|BIT(1)|BIT(2)|BIT(3))
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
-#define	GET_PWR_CFG_OFFSET(__PWR)	(__PWR.offset)
-#define	GET_PWR_CFG_CUT_MASK(__PWR)	(__PWR.cut_msk)
-#define	GET_PWR_CFG_FAB_MASK(__PWR)	(__PWR.fab_msk)
-#define	GET_PWR_CFG_INTF_MASK(__PWR)	(__PWR.interface_msk)
-#define	GET_PWR_CFG_BASE(__PWR)		(__PWR.base)
-#define	GET_PWR_CFG_CMD(__PWR)		(__PWR.cmd)
-#define	GET_PWR_CFG_MASK(__PWR)		(__PWR.msk)
-#define	GET_PWR_CFG_VALUE(__PWR)	(__PWR.value)
-
-bool rtl88_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
-				u8 fab_version, u8 interface_type,
-				struct wlan_pwr_cfg pwrcfgcmd[]);
-
-#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h b/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
index cd7e7a5..15400ee 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
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
@@ -30,62 +26,60 @@
 #ifndef __RTL92C_REG_H__
 #define __RTL92C_REG_H__
 
-#define TXPKT_BUF_SELECT			0x69
-#define RXPKT_BUF_SELECT			0xA5
-#define DISABLE_TRXPKT_BUF_ACCESS		0x0
+#define TXPKT_BUF_SELECT				0x69
+#define RXPKT_BUF_SELECT				0xA5
+#define DISABLE_TRXPKT_BUF_ACCESS			0x0
 
 #define REG_SYS_ISO_CTRL			0x0000
 #define REG_SYS_FUNC_EN				0x0002
 #define REG_APS_FSMCO				0x0004
 #define REG_SYS_CLKR				0x0008
-#define REG_9346CR				0x000A
-#define REG_EE_VPD				0x000C
+#define REG_9346CR					0x000A
+#define REG_EE_VPD					0x000C
 #define REG_AFE_MISC				0x0010
 #define REG_SPS0_CTRL				0x0011
 #define REG_SPS_OCP_CFG				0x0018
 #define REG_RSV_CTRL				0x001C
-#define REG_RF_CTRL				0x001F
+#define REG_RF_CTRL					0x001F
 #define REG_LDOA15_CTRL				0x0020
 #define REG_LDOV12D_CTRL			0x0021
 #define REG_LDOHCI12_CTRL			0x0022
 #define REG_LPLDO_CTRL				0x0023
 #define REG_AFE_XTAL_CTRL			0x0024
-#define REG_AFE_LDO_CTRL			0x0027 /* 1.5v for 8188EE test
-							* chip, 1.4v for MP chip
-							*/
+/* 1.5v for 8188EE test chip, 1.4v for MP chip */
+#define REG_AFE_LDO_CTRL			0x0027
 #define REG_AFE_PLL_CTRL			0x0028
 #define REG_EFUSE_CTRL				0x0030
 #define REG_EFUSE_TEST				0x0034
 #define REG_PWR_DATA				0x0038
 #define REG_CAL_TIMER				0x003C
 #define REG_ACLK_MON				0x003E
-#define REG_GPIO_MUXCFG				0x0040
+#define REG_GPIO_MUXCFG			0x0040
 #define REG_GPIO_IO_SEL				0x0042
-#define REG_MAC_PINMUX_CFG			0x0043
+#define REG_MAC_PINMUX_CFG		0x0043
 #define REG_GPIO_PIN_CTRL			0x0044
 #define REG_GPIO_INTM				0x0048
-#define REG_LEDCFG0				0x004C
-#define REG_LEDCFG1				0x004D
-#define REG_LEDCFG2				0x004E
-#define REG_LEDCFG3				0x004F
-#define REG_FSIMR				0x0050
-#define REG_FSISR				0x0054
-#define REG_HSIMR				0x0058
-#define REG_HSISR				0x005c
-#define REG_GPIO_PIN_CTRL_2			0x0060
+#define REG_LEDCFG0					0x004C
+#define REG_LEDCFG1					0x004D
+#define REG_LEDCFG2					0x004E
+#define REG_LEDCFG3					0x004F
+#define REG_FSIMR					0x0050
+#define REG_FSISR					0x0054
+#define REG_HSIMR					0x0058
+#define REG_HSISR					0x005c
+#define REG_GPIO_PIN_CTRL_2		0x0060
 #define REG_GPIO_IO_SEL_2			0x0062
-#define REG_GPIO_OUTPUT				0x006c
-#define REG_AFE_XTAL_CTRL_EXT			0x0078
+#define REG_GPIO_OUTPUT			0x006c
+#define REG_AFE_XTAL_CTRL_EXT		0x0078
 #define REG_XCK_OUT_CTRL			0x007c
 #define REG_MCUFWDL				0x0080
 #define REG_WOL_EVENT				0x0081
 #define REG_MCUTSTCFG				0x0084
 
-
-#define REG_HIMR				0x00B0
-#define REG_HISR				0x00B4
-#define REG_HIMRE				0x00B8
-#define REG_HISRE				0x00BC
+#define REG_HIMR					0x00B0
+#define REG_HISR					0x00B4
+#define REG_HIMRE					0x00B8
+#define REG_HISRE					0x00BC
 
 #define REG_EFUSE_ACCESS			0x00CF
 
@@ -96,23 +90,23 @@
 #define REG_PCIE_MIO_INTF			0x00E4
 #define REG_PCIE_MIO_INTD			0x00E8
 #define REG_HPON_FSM				0x00EC
-#define REG_SYS_CFG				0x00F0
+#define REG_SYS_CFG					0x00F0
 
-#define REG_CR					0x0100
-#define REG_PBP					0x0104
-#define REG_PKT_BUFF_ACCESS_CTRL		0x0106
+#define REG_CR						0x0100
+#define REG_PBP						0x0104
+#define REG_PKT_BUFF_ACCESS_CTRL	0x0106
 #define REG_TRXDMA_CTRL				0x010C
 #define REG_TRXFF_BNDY				0x0114
 #define REG_TRXFF_STATUS			0x0118
 #define REG_RXFF_PTR				0x011C
 
-#define REG_CPWM				0x012F
-#define REG_FWIMR				0x0130
-#define REG_FWISR				0x0134
+#define REG_CPWM					0x012F
+#define REG_FWIMR					0x0130
+#define REG_FWISR					0x0134
 #define REG_PKTBUF_DBG_CTRL			0x0140
-#define REG_PKTBUF_DBG_DATA_L			0x0144
-#define REG_PKTBUF_DBG_DATA_H			0x0148
-#define REG_RXPKTBUF_CTRL			(REG_PKTBUF_DBG_CTRL+2)
+#define REG_PKTBUF_DBG_DATA_L		0x0144
+#define REG_PKTBUF_DBG_DATA_H		0x0148
+#define REG_RXPKTBUF_CTRL	(REG_PKTBUF_DBG_CTRL+2)
 
 #define REG_TC0_CTRL				0x0150
 #define REG_TC1_CTRL				0x0154
@@ -123,13 +117,13 @@
 #define REG_MBIST_START				0x0174
 #define REG_MBIST_DONE				0x0178
 #define REG_MBIST_FAIL				0x017C
-#define REG_32K_CTRL				0x0194
-#define REG_C2HEVT_MSG_NORMAL			0x01A0
+#define REG_32K_CTRL					0x0194
+#define REG_C2HEVT_MSG_NORMAL		0x01A0
 #define REG_C2HEVT_CLEAR			0x01AF
 #define REG_C2HEVT_MSG_TEST			0x01B8
 #define REG_MCUTST_1				0x01c0
-#define REG_FMETHR				0x01C8
-#define REG_HMETFR				0x01CC
+#define REG_FMETHR					0x01C8
+#define REG_HMETFR					0x01CC
 #define REG_HMEBOX_0				0x01D0
 #define REG_HMEBOX_1				0x01D4
 #define REG_HMEBOX_2				0x01D8
@@ -144,36 +138,37 @@
 #define REG_HMEBOX_EXT_2			0x01F8
 #define REG_HMEBOX_EXT_3			0x01FC
 
-#define REG_RQPN				0x0200
+#define REG_RQPN					0x0200
 #define REG_FIFOPAGE				0x0204
-#define REG_TDECTRL				0x0208
-#define REG_TXDMA_OFFSET_CHK			0x020C
+#define REG_TDECTRL					0x0208
+#define REG_TXDMA_OFFSET_CHK		0x020C
 #define REG_TXDMA_STATUS			0x0210
 #define REG_RQPN_NPQ				0x0214
 
-#define REG_RXDMA_AGG_PG_TH			0x0280
-#define REG_FW_UPD_RDPTR			0x0284 /* FW shall update this
-						* register before FW * write
-						* RXPKT_RELEASE_POLL to 1
-						*/
-#define REG_RXDMA_CONTROL			0x0286 /* Control the RX DMA.*/
-#define REG_RXPKT_NUM				0x0287 /* The number of packets
-							* in RXPKTBUF.
-							 */
+#define REG_RXDMA_AGG_PG_TH		0x0280
+/* FW shall update this register before
+ * FW write RXPKT_RELEASE_POLL to 1
+ */
+#define REG_FW_UPD_RDPTR			0x0284
+/* Control the RX DMA.*/
+#define REG_RXDMA_CONTROL			0x0286
+/* The number of packets in RXPKTBUF.	*/
+#define REG_RXPKT_NUM				0x0287
+
 #define	REG_PCIE_CTRL_REG			0x0300
-#define	REG_INT_MIG				0x0304
+#define	REG_INT_MIG					0x0304
 #define	REG_BCNQ_DESA				0x0308
-#define	REG_HQ_DESA				0x0310
+#define	REG_HQ_DESA					0x0310
 #define	REG_MGQ_DESA				0x0318
 #define	REG_VOQ_DESA				0x0320
 #define	REG_VIQ_DESA				0x0328
 #define	REG_BEQ_DESA				0x0330
 #define	REG_BKQ_DESA				0x0338
-#define	REG_RX_DESA				0x0340
+#define	REG_RX_DESA					0x0340
 
-#define	REG_DBI					0x0348
-#define	REG_MDIO				0x0354
-#define	REG_DBG_SEL				0x0360
+#define	REG_DBI						0x0348
+#define	REG_MDIO					0x0354
+#define	REG_DBG_SEL					0x0360
 #define	REG_PCIE_HRPWM				0x0361
 #define	REG_PCIE_HCPWM				0x0363
 #define	REG_UART_CTRL				0x0364
@@ -181,7 +176,6 @@
 #define	REG_UART_TX_DESA			0x0370
 #define	REG_UART_RX_DESA			0x0378
 
-
 #define	REG_HDAQ_DESA_NODEF			0x0000
 #define	REG_CMDQ_DESA_NODEF			0x0000
 
@@ -191,33 +185,32 @@
 #define REG_BKQ_INFORMATION			0x040C
 #define REG_MGQ_INFORMATION			0x0410
 #define REG_HGQ_INFORMATION			0x0414
-#define REG_BCNQ_INFORMATION			0x0418
+#define REG_BCNQ_INFORMATION		0x0418
 #define REG_TXPKT_EMPTY				0x041A
 
-
-#define REG_CPU_MGQ_INFORMATION			0x041C
+#define REG_CPU_MGQ_INFORMATION		0x041C
 #define REG_FWHW_TXQ_CTRL			0x0420
 #define REG_HWSEQ_CTRL				0x0423
-#define REG_TXPKTBUF_BCNQ_BDNY			0x0424
-#define REG_TXPKTBUF_MGQ_BDNY			0x0425
+#define REG_TXPKTBUF_BCNQ_BDNY		0x0424
+#define REG_TXPKTBUF_MGQ_BDNY		0x0425
 #define REG_MULTI_BCNQ_EN			0x0426
-#define REG_MULTI_BCNQ_OFFSET			0x0427
+#define REG_MULTI_BCNQ_OFFSET		0x0427
 #define REG_SPEC_SIFS				0x0428
-#define REG_RL					0x042A
-#define REG_DARFRC				0x0430
-#define REG_RARFRC				0x0438
-#define REG_RRSR				0x0440
-#define REG_ARFR0				0x0444
-#define REG_ARFR1				0x0448
-#define REG_ARFR2				0x044C
-#define REG_ARFR3				0x0450
+#define REG_RL						0x042A
+#define REG_DARFRC					0x0430
+#define REG_RARFRC					0x0438
+#define REG_RRSR					0x0440
+#define REG_ARFR0					0x0444
+#define REG_ARFR1					0x0448
+#define REG_ARFR2					0x044C
+#define REG_ARFR3					0x0450
 #define REG_AGGLEN_LMT				0x0458
 #define REG_AMPDU_MIN_SPACE			0x045C
-#define REG_TXPKTBUF_WMAC_LBK_BF_HD		0x045D
+#define REG_TXPKTBUF_WMAC_LBK_BF_HD	0x045D
 #define REG_FAST_EDCA_CTRL			0x0460
 #define REG_RD_RESP_PKT_TH			0x0463
 #define REG_INIRTS_RATE_SEL			0x0480
-#define REG_INIDATA_RATE_SEL			0x0484
+#define REG_INIDATA_RATE_SEL		0x0484
 #define REG_POWER_STATUS			0x04A4
 #define REG_POWER_STAGE1			0x04B4
 #define REG_POWER_STAGE2			0x04B8
@@ -225,32 +218,32 @@
 #define REG_STBC_SETTING			0x04C4
 #define REG_PROT_MODE_CTRL			0x04C8
 #define REG_BAR_MODE_CTRL			0x04CC
-#define REG_RA_TRY_RATE_AGG_LMT			0x04CF
-#define REG_EARLY_MODE_CONTROL			0x04D0
+#define REG_RA_TRY_RATE_AGG_LMT		0x04CF
+#define REG_EARLY_MODE_CONTROL		0x04D0
 #define REG_NQOS_SEQ				0x04DC
-#define REG_QOS_SEQ				0x04DE
+#define REG_QOS_SEQ					0x04DE
 #define REG_NEED_CPU_HANDLE			0x04E0
 #define REG_PKT_LOSE_RPT			0x04E1
 #define REG_PTCL_ERR_STATUS			0x04E2
 #define REG_TX_RPT_CTRL				0x04EC
 #define REG_TX_RPT_TIME				0x04F0
-#define REG_DUMMY				0x04FC
+#define REG_DUMMY					0x04FC
 
 #define REG_EDCA_VO_PARAM			0x0500
 #define REG_EDCA_VI_PARAM			0x0504
 #define REG_EDCA_BE_PARAM			0x0508
 #define REG_EDCA_BK_PARAM			0x050C
-#define REG_BCNTCFG				0x0510
-#define REG_PIFS				0x0512
+#define REG_BCNTCFG					0x0510
+#define REG_PIFS					0x0512
 #define REG_RDG_PIFS				0x0513
 #define REG_SIFS_CTX				0x0514
 #define REG_SIFS_TRX				0x0516
 #define REG_AGGR_BREAK_TIME			0x051A
-#define REG_SLOT				0x051B
+#define REG_SLOT					0x051B
 #define REG_TX_PTCL_CTRL			0x0520
-#define REG_TXPAUSE				0x0522
+#define REG_TXPAUSE					0x0522
 #define REG_DIS_TXREQ_CLR			0x0523
-#define REG_RD_CTRL				0x0524
+#define REG_RD_CTRL					0x0524
 #define REG_TBTT_PROHIBIT			0x0540
 #define REG_RD_NAV_NXT				0x0544
 #define REG_NAV_PROT_LEN			0x0546
@@ -259,21 +252,21 @@
 #define REG_MBID_NUM				0x0552
 #define REG_DUAL_TSF_RST			0x0553
 #define REG_BCN_INTERVAL			0x0554
-#define REG_MBSSID_BCN_SPACE			0x0554
+#define REG_MBSSID_BCN_SPACE		0x0554
 #define REG_DRVERLYINT				0x0558
 #define REG_BCNDMATIM				0x0559
-#define REG_ATIMWND				0x055A
+#define REG_ATIMWND					0x055A
 #define REG_BCN_MAX_ERR				0x055D
-#define REG_RXTSF_OFFSET_CCK			0x055E
-#define REG_RXTSF_OFFSET_OFDM			0x055F
-#define REG_TSFTR				0x0560
+#define REG_RXTSF_OFFSET_CCK		0x055E
+#define REG_RXTSF_OFFSET_OFDM		0x055F
+#define REG_TSFTR					0x0560
 #define REG_INIT_TSFTR				0x0564
-#define REG_PSTIMER				0x0580
-#define REG_TIMER0				0x0584
-#define REG_TIMER1				0x0588
+#define REG_PSTIMER					0x0580
+#define REG_TIMER0					0x0584
+#define REG_TIMER1					0x0588
 #define REG_ACMHWCTRL				0x05C0
 #define REG_ACMRSTCTRL				0x05C1
-#define REG_ACMAVG				0x05C2
+#define REG_ACMAVG					0x05C2
 #define REG_VO_ADMTIME				0x05C4
 #define REG_VI_ADMTIME				0x05C6
 #define REG_BE_ADMTIME				0x05C8
@@ -282,38 +275,38 @@
 
 #define REG_APSD_CTRL				0x0600
 #define REG_BWOPMODE				0x0603
-#define REG_TCR					0x0604
-#define REG_RCR					0x0608
+#define REG_TCR						0x0604
+#define REG_RCR						0x0608
 #define REG_RX_PKT_LIMIT			0x060C
 #define REG_RX_DLK_TIME				0x060D
 #define REG_RX_DRVINFO_SZ			0x060F
 
-#define REG_MACID				0x0610
-#define REG_BSSID				0x0618
-#define REG_MAR					0x0620
+#define REG_MACID					0x0610
+#define REG_BSSID					0x0618
+#define REG_MAR						0x0620
 #define REG_MBIDCAMCFG				0x0628
 
 #define REG_USTIME_EDCA				0x0638
 #define REG_MAC_SPEC_SIFS			0x063A
 #define REG_RESP_SIFS_CCK			0x063C
 #define REG_RESP_SIFS_OFDM			0x063E
-#define REG_ACKTO				0x0640
-#define REG_CTS2TO				0x0641
-#define REG_EIFS				0x0642
+#define REG_ACKTO					0x0640
+#define REG_CTS2TO					0x0641
+#define REG_EIFS					0x0642
 
 #define REG_NAV_CTRL				0x0650
 #define REG_BACAMCMD				0x0654
 #define REG_BACAMCONTENT			0x0658
-#define REG_LBDLY				0x0660
-#define REG_FWDLY				0x0661
+#define REG_LBDLY					0x0660
+#define REG_FWDLY					0x0661
 #define REG_RXERR_RPT				0x0664
 #define REG_TRXPTCL_CTL				0x0668
 
-#define REG_CAMCMD				0x0670
+#define REG_CAMCMD					0x0670
 #define REG_CAMWRITE				0x0674
-#define REG_CAMREAD				0x0678
-#define REG_CAMDBG				0x067C
-#define REG_SECCFG				0x0680
+#define REG_CAMREAD					0x0678
+#define REG_CAMDBG					0x067C
+#define REG_SECCFG					0x0680
 
 #define REG_WOW_CTRL				0x0690
 #define REG_PSSTATUS				0x0691
@@ -329,10 +322,10 @@
 #define REG_CALB32K_CTRL			0x06AC
 #define REG_PKT_MON_CTRL			0x06B4
 #define REG_BT_COEX_TABLE			0x06C0
-#define REG_WMAC_RESP_TXINFO			0x06D8
+#define REG_WMAC_RESP_TXINFO		0x06D8
 
 #define REG_USB_INFO				0xFE17
-#define REG_USB_SPECIAL_OPTION			0xFE55
+#define REG_USB_SPECIAL_OPTION		0xFE55
 #define REG_USB_DMA_AGG_TO			0xFE5B
 #define REG_USB_AGG_TO				0xFE5C
 #define REG_USB_AGG_TH				0xFE5D
@@ -340,523 +333,545 @@
 #define REG_TEST_USB_TXQS			0xFE48
 #define REG_TEST_SIE_VID			0xFE60
 #define REG_TEST_SIE_PID			0xFE62
-#define REG_TEST_SIE_OPTIONAL			0xFE64
-#define REG_TEST_SIE_CHIRP_K			0xFE65
+#define REG_TEST_SIE_OPTIONAL		0xFE64
+#define REG_TEST_SIE_CHIRP_K		0xFE65
 #define REG_TEST_SIE_PHY			0xFE66
-#define REG_TEST_SIE_MAC_ADDR			0xFE70
+#define REG_TEST_SIE_MAC_ADDR		0xFE70
 #define REG_TEST_SIE_STRING			0xFE80
 
 #define REG_NORMAL_SIE_VID			0xFE60
 #define REG_NORMAL_SIE_PID			0xFE62
-#define REG_NORMAL_SIE_OPTIONAL			0xFE64
+#define REG_NORMAL_SIE_OPTIONAL		0xFE64
 #define REG_NORMAL_SIE_EP			0xFE65
 #define REG_NORMAL_SIE_PHY			0xFE68
-#define REG_NORMAL_SIE_MAC_ADDR			0xFE70
-#define REG_NORMAL_SIE_STRING			0xFE80
+#define REG_NORMAL_SIE_MAC_ADDR		0xFE70
+#define REG_NORMAL_SIE_STRING		0xFE80
 
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
-#define	AUTOLOAD_EEPROM				(CMDEEPROM_EN|CMDEEPROM_SEL)
-#define	AUTOLOAD_EFUSE				CMDEEPROM_EN
+#define	CMDEEPROM_EN			BIT(5)
+#define	CMDEEPROM_SEL			BIT(4)
+#define	CMD9346CR_9356SEL		BIT(4)
+#define	AUTOLOAD_EEPROM			(CMDEEPROM_EN|CMDEEPROM_SEL)
+#define	AUTOLOAD_EFUSE			CMDEEPROM_EN
 
-#define	GPIOSEL_GPIO				0
-#define	GPIOSEL_ENBT				BIT(5)
+#define	GPIOSEL_GPIO			0
+#define	GPIOSEL_ENBT			BIT(5)
 
-#define	GPIO_IN					REG_GPIO_PIN_CTRL
-#define	GPIO_OUT				(REG_GPIO_PIN_CTRL+1)
-#define	GPIO_IO_SEL				(REG_GPIO_PIN_CTRL+2)
-#define	GPIO_MOD				(REG_GPIO_PIN_CTRL+3)
+#define	GPIO_IN				REG_GPIO_PIN_CTRL
+#define	GPIO_OUT			(REG_GPIO_PIN_CTRL+1)
+#define	GPIO_IO_SEL			(REG_GPIO_PIN_CTRL+2)
+#define	GPIO_MOD			(REG_GPIO_PIN_CTRL+3)
 
-/* 8723/8188E Host System Interrupt Mask Register (offset 0x58, 32 byte) */
+/*8723/8188E Host System Interrupt
+ *Mask Register (offset 0x58, 32 byte)
+ */
 #define	HSIMR_GPIO12_0_INT_EN			BIT(0)
 #define	HSIMR_SPS_OCP_INT_EN			BIT(5)
 #define	HSIMR_RON_INT_EN			BIT(6)
 #define	HSIMR_PDN_INT_EN			BIT(7)
 #define	HSIMR_GPIO9_INT_EN			BIT(25)
 
-
-/* 8723/8188E Host System Interrupt Status Register (offset 0x5C, 32 byte) */
+/*       8723/8188E Host System Interrupt
+ *		Status Register (offset 0x5C, 32 byte)
+ */
 #define	HSISR_GPIO12_0_INT			BIT(0)
 #define	HSISR_SPS_OCP_INT			BIT(5)
 #define	HSISR_RON_INT_EN			BIT(6)
 #define	HSISR_PDNINT				BIT(7)
 #define	HSISR_GPIO9_INT				BIT(25)
 
-#define	MSR_NOLINK				0x00
-#define	MSR_ADHOC				0x01
-#define	MSR_INFRA				0x02
-#define	MSR_AP					0x03
-#define	MSR_MASK				0x03
+#define	MSR_NOLINK					0x00
+#define	MSR_ADHOC					0x01
+#define	MSR_INFRA					0x02
+#define	MSR_AP						0x03
 
 #define	RRSR_RSC_OFFSET				21
 #define	RRSR_SHORT_OFFSET			23
 #define	RRSR_RSC_BW_40M				0x600000
 #define	RRSR_RSC_UPSUBCHNL			0x400000
 #define	RRSR_RSC_LOWSUBCHNL			0x200000
-#define	RRSR_SHORT				0x800000
-#define	RRSR_1M					BIT(0)
-#define	RRSR_2M					BIT(1)
-#define	RRSR_5_5M				BIT(2)
-#define	RRSR_11M				BIT(3)
-#define	RRSR_6M					BIT(4)
-#define	RRSR_9M					BIT(5)
-#define	RRSR_12M				BIT(6)
-#define	RRSR_18M				BIT(7)
-#define	RRSR_24M				BIT(8)
-#define	RRSR_36M				BIT(9)
-#define	RRSR_48M				BIT(10)
-#define	RRSR_54M				BIT(11)
-#define	RRSR_MCS0				BIT(12)
-#define	RRSR_MCS1				BIT(13)
-#define	RRSR_MCS2				BIT(14)
-#define	RRSR_MCS3				BIT(15)
-#define	RRSR_MCS4				BIT(16)
-#define	RRSR_MCS5				BIT(17)
-#define	RRSR_MCS6				BIT(18)
-#define	RRSR_MCS7				BIT(19)
+#define	RRSR_SHORT					0x800000
+#define	RRSR_1M						BIT(0)
+#define	RRSR_2M						BIT(1)
+#define	RRSR_5_5M					BIT(2)
+#define	RRSR_11M					BIT(3)
+#define	RRSR_6M						BIT(4)
+#define	RRSR_9M						BIT(5)
+#define	RRSR_12M					BIT(6)
+#define	RRSR_18M					BIT(7)
+#define	RRSR_24M					BIT(8)
+#define	RRSR_36M					BIT(9)
+#define	RRSR_48M					BIT(10)
+#define	RRSR_54M					BIT(11)
+#define	RRSR_MCS0					BIT(12)
+#define	RRSR_MCS1					BIT(13)
+#define	RRSR_MCS2					BIT(14)
+#define	RRSR_MCS3					BIT(15)
+#define	RRSR_MCS4					BIT(16)
+#define	RRSR_MCS5					BIT(17)
+#define	RRSR_MCS6					BIT(18)
+#define	RRSR_MCS7					BIT(19)
 #define	BRSR_ACKSHORTPMB			BIT(23)
 
-#define	RATR_1M					0x00000001
-#define	RATR_2M					0x00000002
-#define	RATR_55M				0x00000004
-#define	RATR_11M				0x00000008
-#define	RATR_6M					0x00000010
-#define	RATR_9M					0x00000020
-#define	RATR_12M				0x00000040
-#define	RATR_18M				0x00000080
-#define	RATR_24M				0x00000100
-#define	RATR_36M				0x00000200
-#define	RATR_48M				0x00000400
-#define	RATR_54M				0x00000800
-#define	RATR_MCS0				0x00001000
-#define	RATR_MCS1				0x00002000
-#define	RATR_MCS2				0x00004000
-#define	RATR_MCS3				0x00008000
-#define	RATR_MCS4				0x00010000
-#define	RATR_MCS5				0x00020000
-#define	RATR_MCS6				0x00040000
-#define	RATR_MCS7				0x00080000
-#define	RATR_MCS8				0x00100000
-#define	RATR_MCS9				0x00200000
-#define	RATR_MCS10				0x00400000
-#define	RATR_MCS11				0x00800000
-#define	RATR_MCS12				0x01000000
-#define	RATR_MCS13				0x02000000
-#define	RATR_MCS14				0x04000000
-#define	RATR_MCS15				0x08000000
-
-#define RATE_1M					BIT(0)
-#define RATE_2M					BIT(1)
-#define RATE_5_5M				BIT(2)
-#define RATE_11M				BIT(3)
-#define RATE_6M					BIT(4)
-#define RATE_9M					BIT(5)
-#define RATE_12M				BIT(6)
-#define RATE_18M				BIT(7)
-#define RATE_24M				BIT(8)
-#define RATE_36M				BIT(9)
-#define RATE_48M				BIT(10)
-#define RATE_54M				BIT(11)
-#define RATE_MCS0				BIT(12)
-#define RATE_MCS1				BIT(13)
-#define RATE_MCS2				BIT(14)
-#define RATE_MCS3				BIT(15)
-#define RATE_MCS4				BIT(16)
-#define RATE_MCS5				BIT(17)
-#define RATE_MCS6				BIT(18)
-#define RATE_MCS7				BIT(19)
-#define RATE_MCS8				BIT(20)
-#define RATE_MCS9				BIT(21)
-#define RATE_MCS10				BIT(22)
-#define RATE_MCS11				BIT(23)
-#define RATE_MCS12				BIT(24)
-#define RATE_MCS13				BIT(25)
-#define RATE_MCS14				BIT(26)
-#define RATE_MCS15				BIT(27)
+#define	RATR_1M						0x00000001
+#define	RATR_2M						0x00000002
+#define	RATR_55M					0x00000004
+#define	RATR_11M					0x00000008
+#define	RATR_6M						0x00000010
+#define	RATR_9M						0x00000020
+#define	RATR_12M					0x00000040
+#define	RATR_18M					0x00000080
+#define	RATR_24M					0x00000100
+#define	RATR_36M					0x00000200
+#define	RATR_48M					0x00000400
+#define	RATR_54M					0x00000800
+#define	RATR_MCS0					0x00001000
+#define	RATR_MCS1					0x00002000
+#define	RATR_MCS2					0x00004000
+#define	RATR_MCS3					0x00008000
+#define	RATR_MCS4					0x00010000
+#define	RATR_MCS5					0x00020000
+#define	RATR_MCS6					0x00040000
+#define	RATR_MCS7					0x00080000
+#define	RATR_MCS8					0x00100000
+#define	RATR_MCS9					0x00200000
+#define	RATR_MCS10					0x00400000
+#define	RATR_MCS11					0x00800000
+#define	RATR_MCS12					0x01000000
+#define	RATR_MCS13					0x02000000
+#define	RATR_MCS14					0x04000000
+#define	RATR_MCS15					0x08000000
+
+#define RATE_1M						BIT(0)
+#define RATE_2M						BIT(1)
+#define RATE_5_5M					BIT(2)
+#define RATE_11M					BIT(3)
+#define RATE_6M						BIT(4)
+#define RATE_9M						BIT(5)
+#define RATE_12M					BIT(6)
+#define RATE_18M					BIT(7)
+#define RATE_24M					BIT(8)
+#define RATE_36M					BIT(9)
+#define RATE_48M					BIT(10)
+#define RATE_54M					BIT(11)
+#define RATE_MCS0					BIT(12)
+#define RATE_MCS1					BIT(13)
+#define RATE_MCS2					BIT(14)
+#define RATE_MCS3					BIT(15)
+#define RATE_MCS4					BIT(16)
+#define RATE_MCS5					BIT(17)
+#define RATE_MCS6					BIT(18)
+#define RATE_MCS7					BIT(19)
+#define RATE_MCS8					BIT(20)
+#define RATE_MCS9					BIT(21)
+#define RATE_MCS10					BIT(22)
+#define RATE_MCS11					BIT(23)
+#define RATE_MCS12					BIT(24)
+#define RATE_MCS13					BIT(25)
+#define RATE_MCS14					BIT(26)
+#define RATE_MCS15					BIT(27)
 
 #define	RATE_ALL_CCK		(RATR_1M | RATR_2M | RATR_55M | RATR_11M)
-#define	RATE_ALL_OFDM_AG	(RATR_6M | RATR_9M | RATR_12M | RATR_18M | \
+#define	RATE_ALL_OFDM_AG	(RATR_6M | RATR_9M | RATR_12M | RATR_18M |\
 				RATR_24M | RATR_36M | RATR_48M | RATR_54M)
-#define	RATE_ALL_OFDM_1SS	(RATR_MCS0 | RATR_MCS1 | RATR_MCS2 | \
-				RATR_MCS3 | RATR_MCS4 | RATR_MCS5 | \
+#define	RATE_ALL_OFDM_1SS	(RATR_MCS0 | RATR_MCS1 | RATR_MCS2 |\
+				RATR_MCS3 | RATR_MCS4 | RATR_MCS5 |\
 				RATR_MCS6 | RATR_MCS7)
-#define	RATE_ALL_OFDM_2SS	(RATR_MCS8 | RATR_MCS9 | RATR_MCS10 | \
-				RATR_MCS11 | RATR_MCS12 | RATR_MCS13 | \
+#define	RATE_ALL_OFDM_2SS	(RATR_MCS8 | RATR_MCS9 | RATR_MCS10 |\
+				RATR_MCS11 | RATR_MCS12 | RATR_MCS13 |\
 				RATR_MCS14 | RATR_MCS15)
 
 #define	BW_OPMODE_20MHZ				BIT(2)
 #define	BW_OPMODE_5G				BIT(1)
 #define	BW_OPMODE_11J				BIT(0)
 
-#define	CAM_VALID				BIT(15)
+#define	CAM_VALID					BIT(15)
 #define	CAM_NOTVALID				0x0000
-#define	CAM_USEDK				BIT(5)
+#define	CAM_USEDK					BIT(5)
 
-#define	CAM_NONE				0x0
-#define	CAM_WEP40				0x01
-#define	CAM_TKIP				0x02
-#define	CAM_AES					0x04
-#define	CAM_WEP104				0x05
+#define	CAM_NONE					0x0
+#define	CAM_WEP40					0x01
+#define	CAM_TKIP					0x02
+#define	CAM_AES						0x04
+#define	CAM_WEP104					0x05
 
 #define	TOTAL_CAM_ENTRY				32
 #define	HALF_CAM_ENTRY				16
 
-#define	CAM_WRITE				BIT(16)
-#define	CAM_READ				0x00000000
+#define	CAM_WRITE					BIT(16)
+#define	CAM_READ					0x00000000
 #define	CAM_POLLINIG				BIT(31)
 
-#define	SCR_USEDK				0x01
+#define	SCR_USEDK					0x01
 #define	SCR_TXSEC_ENABLE			0x02
 #define	SCR_RXSEC_ENABLE			0x04
 
-#define	WOW_PMEN				BIT(0)
-#define	WOW_WOMEN				BIT(1)
-#define	WOW_MAGIC				BIT(2)
-#define	WOW_UWF					BIT(3)
+#define	WOW_PMEN					BIT(0)
+#define	WOW_WOMEN					BIT(1)
+#define	WOW_MAGIC					BIT(2)
+#define	WOW_UWF						BIT(3)
 
 /*********************************************
 *       8188 IMR/ISR bits
 **********************************************/
-#define	IMR_DISABLED				0x0
+#define	IMR_DISABLED			0x0
 /* IMR DW0(0x0060-0063) Bit 0-31 */
-#define	IMR_TXCCK		BIT(30) /* TXRPT interrupt when CCX bit of
-					 * the packet is set
-					 */
-#define	IMR_PSTIMEOUT		BIT(29)	/* Power Save Time Out Interrupt */
-#define	IMR_GTINT4		BIT(28)	/* When GTIMER4 expires,
-					 * this bit is set to 1
-					 */
-#define	IMR_GTINT3		BIT(27)	/* When GTIMER3 expires,
-					 * this bit is set to 1
-					 */
-#define	IMR_TBDER		BIT(26)	/* Transmit Beacon0 Error */
-#define	IMR_TBDOK		BIT(25)	/* Transmit Beacon0 OK	*/
-#define	IMR_TSF_BIT32_TOGGLE	BIT(24)	/* TSF Timer BIT32 toggle ind int */
-#define	IMR_BCNDMAINT0		BIT(20)	/* Beacon DMA Interrupt 0 */
-#define	IMR_BCNDOK0		BIT(16)	/* Beacon Queue DMA OK0	*/
-#define	IMR_HSISR_IND_ON_INT	BIT(15)	/* HSISR Indicator (HSIMR & HSISR is
-					 * true, this bit is set to 1)
-					 */
-#define	IMR_BCNDMAINT_E		BIT(14)	/* Beacon DMA Int Extension for Win7 */
-#define	IMR_ATIMEND		BIT(12)	/* CTWidnow End or ATIM Window End */
-#define	IMR_HISR1_IND_INT	BIT(11)	/* HISR1 Indicator (HISR1 & HIMR1 is
-					 * true, this bit is set to 1)
-					 */
-#define	IMR_C2HCMD		BIT(10)	/* CPU to Host Command INT Status,
-					 * Write 1 clear
-					 */
-#define	IMR_CPWM2		BIT(9)	/* CPU power Mode exchange INT Status,
-					 * Write 1 clear
-					 */
-#define	IMR_CPWM		BIT(8)	/* CPU power Mode exchange INT Status,
-					 * Write 1 clear
-					 */
-#define	IMR_HIGHDOK		BIT(7)	/* High Queue DMA OK	*/
-#define	IMR_MGNTDOK		BIT(6)	/* Management Queue DMA OK */
-#define	IMR_BKDOK		BIT(5)	/* AC_BK DMA OK		*/
-#define	IMR_BEDOK		BIT(4)	/* AC_BE DMA OK	*/
-#define	IMR_VIDOK		BIT(3)	/* AC_VI DMA OK	*/
-#define	IMR_VODOK		BIT(2)	/* AC_VO DMA OK	*/
-#define	IMR_RDU			BIT(1)	/* Rx Descriptor Unavailable */
-#define	IMR_ROK			BIT(0)	/* Receive DMA OK */
+/* TXRPT interrupt when CCX bit of the packet is set	*/
+#define	IMR_TXCCK				BIT(30)
+/* Power Save Time Out Interrupt */
+#define	IMR_PSTIMEOUT			BIT(29)
+/* When GTIMER4 expires, this bit is set to 1	*/
+#define	IMR_GTINT4				BIT(28)
+/* When GTIMER3 expires, this bit is set to 1	*/
+#define	IMR_GTINT3				BIT(27)
+/* Transmit Beacon0 Error			*/
+#define	IMR_TBDER				BIT(26)
+/* Transmit Beacon0 OK			*/
+#define	IMR_TBDOK				BIT(25)
+/* TSF Timer BIT32 toggle indication interrupt	*/
+#define	IMR_TSF_BIT32_TOGGLE		BIT(24)
+/* Beacon DMA Interrupt 0			*/
+#define	IMR_BCNDMAINT0			BIT(20)
+/* Beacon Queue DMA OK0			*/
+#define	IMR_BCNDOK0				BIT(16)
+/* HSISR Indicator (HSIMR & HSISR is true, this bit is set to 1)	*/
+#define	IMR_HSISR_IND_ON_INT		BIT(15)
+/* Beacon DMA Interrupt Extension for Win7			*/
+#define	IMR_BCNDMAINT_E			BIT(14)
+/* CTWidnow End or ATIM Window End */
+#define	IMR_ATIMEND				BIT(12)
+/* HISR1 Indicator (HISR1 & HIMR1 is true, this bit is set to 1)*/
+#define	IMR_HISR1_IND_INT			BIT(11)
+/* CPU to Host Command INT Status, Write 1 clear	*/
+#define	IMR_C2HCMD				BIT(10)
+/* CPU power Mode exchange INT Status, Write 1 clear	*/
+#define	IMR_CPWM2			BIT(9)
+/* CPU power Mode exchange INT Status, Write 1 clear	*/
+#define	IMR_CPWM				BIT(8)
+/* High Queue DMA OK	*/
+#define	IMR_HIGHDOK				BIT(7)
+/* Management Queue DMA OK	*/
+#define	IMR_MGNTDOK				BIT(6)
+/* AC_BK DMA OK		*/
+#define	IMR_BKDOK				BIT(5)
+/* AC_BE DMA OK	*/
+#define	IMR_BEDOK				BIT(4)
+/* AC_VI DMA OK	*/
+#define	IMR_VIDOK				BIT(3)
+/* AC_VO DMA OK	*/
+#define	IMR_VODOK				BIT(2)
+/* Rx Descriptor Unavailable	*/
+#define	IMR_RDU				BIT(1)
+/* Receive DMA OK */
+#define	IMR_ROK				BIT(0)
 
 /* IMR DW1(0x00B4-00B7) Bit 0-31 */
-#define	IMR_BCNDMAINT7		BIT(27)	/* Beacon DMA Interrupt 7 */
-#define	IMR_BCNDMAINT6		BIT(26)	/* Beacon DMA Interrupt 6 */
-#define	IMR_BCNDMAINT5		BIT(25)	/* Beacon DMA Interrupt 5 */
-#define	IMR_BCNDMAINT4		BIT(24)	/* Beacon DMA Interrupt 4 */
-#define	IMR_BCNDMAINT3		BIT(23)	/* Beacon DMA Interrupt 3 */
-#define	IMR_BCNDMAINT2		BIT(22)	/* Beacon DMA Interrupt 2 */
-#define	IMR_BCNDMAINT1		BIT(21)	/* Beacon DMA Interrupt 1 */
-#define	IMR_BCNDOK7		BIT(20)	/* Beacon Queue DMA OK Interrup 7 */
-#define	IMR_BCNDOK6		BIT(19)	/* Beacon Queue DMA OK Interrup 6 */
-#define	IMR_BCNDOK5		BIT(18)	/* Beacon Queue DMA OK Interrup 5 */
-#define	IMR_BCNDOK4		BIT(17)	/* Beacon Queue DMA OK Interrup 4 */
-#define	IMR_BCNDOK3		BIT(16)	/* Beacon Queue DMA OK Interrup 3 */
-#define	IMR_BCNDOK2		BIT(15)	/* Beacon Queue DMA OK Interrup 2 */
-#define	IMR_BCNDOK1		BIT(14)	/* Beacon Queue DMA OK Interrup 1 */
-#define	IMR_ATIMEND_E		BIT(13)	/* ATIM Window End Extension for Win7 */
-#define	IMR_TXERR		BIT(11)	/* Tx Err Flag Int Status,
-					 * write 1 clear.
-					 */
-#define	IMR_RXERR		BIT(10)	/* Rx Err Flag INT Status,
-					 * Write 1 clear
-					 */
-#define	IMR_TXFOVW		BIT(9)	/* Transmit FIFO Overflow */
-#define	IMR_RXFOVW		BIT(8)	/* Receive FIFO Overflow */
-
+/* Beacon DMA Interrupt 7	*/
+#define	IMR_BCNDMAINT7			BIT(27)
+/* Beacon DMA Interrupt 6		*/
+#define	IMR_BCNDMAINT6			BIT(26)
+/* Beacon DMA Interrupt 5		*/
+#define	IMR_BCNDMAINT5			BIT(25)
+/* Beacon DMA Interrupt 4		*/
+#define	IMR_BCNDMAINT4			BIT(24)
+/* Beacon DMA Interrupt 3		*/
+#define	IMR_BCNDMAINT3			BIT(23)
+/* Beacon DMA Interrupt 2		*/
+#define	IMR_BCNDMAINT2			BIT(22)
+/* Beacon DMA Interrupt 1		*/
+#define	IMR_BCNDMAINT1			BIT(21)
+/* Beacon Queue DMA OK Interrup 7 */
+#define	IMR_BCNDOK7				BIT(20)
+/* Beacon Queue DMA OK Interrup 6 */
+#define	IMR_BCNDOK6				BIT(19)
+/* Beacon Queue DMA OK Interrup 5 */
+#define	IMR_BCNDOK5				BIT(18)
+/* Beacon Queue DMA OK Interrup 4 */
+#define	IMR_BCNDOK4				BIT(17)
+/* Beacon Queue DMA OK Interrup 3 */
+#define	IMR_BCNDOK3				BIT(16)
+/* Beacon Queue DMA OK Interrup 2 */
+#define	IMR_BCNDOK2				BIT(15)
+/* Beacon Queue DMA OK Interrup 1 */
+#define	IMR_BCNDOK1				BIT(14)
+/* ATIM Window End Extension for Win7 */
+#define	IMR_ATIMEND_E		BIT(13)
+/* Tx Error Flag Interrupt Status, write 1 clear. */
+#define	IMR_TXERR				BIT(11)
+/* Rx Error Flag INT Status, Write 1 clear */
+#define	IMR_RXERR				BIT(10)
+/* Transmit FIFO Overflow */
+#define	IMR_TXFOVW				BIT(9)
+/* Receive FIFO Overflow */
+#define	IMR_RXFOVW				BIT(8)
 
 #define	HWSET_MAX_SIZE				512
 #define   EFUSE_MAX_SECTION			64
-#define   EFUSE_REAL_CONTENT_LEN		256
-#define	EFUSE_OOB_PROTECT_BYTES			18 /* PG data exclude header,
-						    * dummy 7 bytes frome CP
-						    * test and reserved 1byte.
-						    */
-
-#define	EEPROM_DEFAULT_TSSI			0x0
-#define EEPROM_DEFAULT_TXPOWERDIFF		0x0
-#define EEPROM_DEFAULT_CRYSTALCAP		0x5
-#define EEPROM_DEFAULT_BOARDTYPE		0x02
-#define EEPROM_DEFAULT_TXPOWER			0x1010
-#define	EEPROM_DEFAULT_HT2T_TXPWR		0x10
+#define   EFUSE_REAL_CONTENT_LEN			256
+/* PG data exclude header, dummy 7 bytes frome CP test and reserved 1byte.*/
+#define		EFUSE_OOB_PROTECT_BYTES		18
+
+#define	EEPROM_DEFAULT_TSSI					0x0
+#define EEPROM_DEFAULT_TXPOWERDIFF			0x0
+#define EEPROM_DEFAULT_CRYSTALCAP			0x5
+#define EEPROM_DEFAULT_BOARDTYPE			0x02
+#define EEPROM_DEFAULT_TXPOWER				0x1010
+#define	EEPROM_DEFAULT_HT2T_TXPWR			0x10
 
 #define	EEPROM_DEFAULT_LEGACYHTTXPOWERDIFF	0x3
-#define	EEPROM_DEFAULT_THERMALMETER		0x18
+#define	EEPROM_DEFAULT_THERMALMETER			0x18
 #define	EEPROM_DEFAULT_ANTTXPOWERDIFF		0x0
 #define	EEPROM_DEFAULT_TXPWDIFF_CRYSTALCAP	0x5
-#define	EEPROM_DEFAULT_TXPOWERLEVEL		0x22
-#define	EEPROM_DEFAULT_HT40_2SDIFF		0x0
-#define EEPROM_DEFAULT_HT20_DIFF		2
+#define	EEPROM_DEFAULT_TXPOWERLEVEL			0x22
+#define	EEPROM_DEFAULT_HT40_2SDIFF			0x0
+#define EEPROM_DEFAULT_HT20_DIFF			2
 #define	EEPROM_DEFAULT_LEGACYHTTXPOWERDIFF	0x3
 #define EEPROM_DEFAULT_HT40_PWRMAXOFFSET	0
 #define EEPROM_DEFAULT_HT20_PWRMAXOFFSET	0
 
-#define RF_OPTION1				0x79
-#define RF_OPTION2				0x7A
-#define RF_OPTION3				0x7B
-#define RF_OPTION4				0x7C
+#define RF_OPTION1							0x79
+#define RF_OPTION2							0x7A
+#define RF_OPTION3							0x7B
+#define RF_OPTION4							0x7C
 
-#define EEPROM_DEFAULT_PID			0x1234
-#define EEPROM_DEFAULT_VID			0x5678
-#define EEPROM_DEFAULT_CUSTOMERID		0xAB
+#define EEPROM_DEFAULT_PID					0x1234
+#define EEPROM_DEFAULT_VID					0x5678
+#define EEPROM_DEFAULT_CUSTOMERID			0xAB
 #define EEPROM_DEFAULT_SUBCUSTOMERID		0xCD
-#define EEPROM_DEFAULT_VERSION			0
-
-#define	EEPROM_CHANNEL_PLAN_FCC			0x0
-#define	EEPROM_CHANNEL_PLAN_IC			0x1
-#define	EEPROM_CHANNEL_PLAN_ETSI		0x2
-#define	EEPROM_CHANNEL_PLAN_SPAIN		0x3
-#define	EEPROM_CHANNEL_PLAN_FRANCE		0x4
-#define	EEPROM_CHANNEL_PLAN_MKK			0x5
-#define	EEPROM_CHANNEL_PLAN_MKK1		0x6
-#define	EEPROM_CHANNEL_PLAN_ISRAEL		0x7
-#define	EEPROM_CHANNEL_PLAN_TELEC		0x8
+#define EEPROM_DEFAULT_VERSION				0
+
+#define	EEPROM_CHANNEL_PLAN_FCC				0x0
+#define	EEPROM_CHANNEL_PLAN_IC				0x1
+#define	EEPROM_CHANNEL_PLAN_ETSI			0x2
+#define	EEPROM_CHANNEL_PLAN_SPAIN			0x3
+#define	EEPROM_CHANNEL_PLAN_FRANCE			0x4
+#define	EEPROM_CHANNEL_PLAN_MKK				0x5
+#define	EEPROM_CHANNEL_PLAN_MKK1			0x6
+#define	EEPROM_CHANNEL_PLAN_ISRAEL			0x7
+#define	EEPROM_CHANNEL_PLAN_TELEC			0x8
 #define	EEPROM_CHANNEL_PLAN_GLOBAL_DOMAIN	0x9
 #define	EEPROM_CHANNEL_PLAN_WORLD_WIDE_13	0xA
-#define	EEPROM_CHANNEL_PLAN_NCC			0xB
+#define	EEPROM_CHANNEL_PLAN_NCC				0xB
 #define	EEPROM_CHANNEL_PLAN_BY_HW_MASK		0x80
 
-#define EEPROM_CID_DEFAULT			0x0
-#define EEPROM_CID_TOSHIBA			0x4
-#define	EEPROM_CID_CCX				0x10
-#define	EEPROM_CID_QMI				0x0D
-#define EEPROM_CID_WHQL				0xFE
+#define EEPROM_CID_DEFAULT					0x0
+#define EEPROM_CID_TOSHIBA					0x4
+#define	EEPROM_CID_CCX						0x10
+#define	EEPROM_CID_QMI						0x0D
+#define EEPROM_CID_WHQL						0xFE
 
-#define	RTL8188E_EEPROM_ID			0x8129
+#define	RTL8188E_EEPROM_ID					0x8129
 
-#define EEPROM_HPON				0x02
-#define EEPROM_CLK				0x06
-#define EEPROM_TESTR				0x08
+#define EEPROM_HPON							0x02
+#define EEPROM_CLK							0x06
+#define EEPROM_TESTR						0x08
 
 #define EEPROM_TXPOWERCCK			0x10
-#define	EEPROM_TXPOWERHT40_1S			0x16
-#define EEPROM_TXPOWERHT20DIFF			0x1B
-#define EEPROM_TXPOWER_OFDMDIFF			0x1B
+#define	EEPROM_TXPOWERHT40_1S		0x16
+#define EEPROM_TXPOWERHT20DIFF		0x1B
+#define EEPROM_TXPOWER_OFDMDIFF		0x1B
 
-#define	EEPROM_TX_PWR_INX			0x10
+#define	EEPROM_TX_PWR_INX				0x10
 
-#define	EEPROM_CHANNELPLAN			0xB8
-#define	EEPROM_XTAL_88E				0xB9
-#define	EEPROM_THERMAL_METER_88E		0xBA
-#define	EEPROM_IQK_LCK_88E			0xBB
+#define	EEPROM_CHANNELPLAN					0xB8
+#define	EEPROM_XTAL_88E						0xB9
+#define	EEPROM_THERMAL_METER_88E			0xBA
+#define	EEPROM_IQK_LCK_88E					0xBB
 
-#define	EEPROM_RF_BOARD_OPTION_88E		0xC1
+#define	EEPROM_RF_BOARD_OPTION_88E			0xC1
 #define	EEPROM_RF_FEATURE_OPTION_88E		0xC2
-#define	EEPROM_RF_BT_SETTING_88E		0xC3
-#define	EEPROM_VERSION				0xC4
-#define	EEPROM_CUSTOMER_ID			0xC5
-#define	EEPROM_RF_ANTENNA_OPT_88E		0xC9
-
-#define	EEPROM_MAC_ADDR				0xD0
-#define EEPROM_VID				0xD6
-#define EEPROM_DID				0xD8
-#define EEPROM_SVID				0xDA
-#define EEPROM_SMID				0xDC
-
-#define	STOPBECON				BIT(6)
-#define	STOPHIGHT				BIT(5)
-#define	STOPMGT					BIT(4)
-#define	STOPVO					BIT(3)
-#define	STOPVI					BIT(2)
-#define	STOPBE					BIT(1)
-#define	STOPBK					BIT(0)
-
-#define	RCR_APPFCS				BIT(31)
-#define	RCR_APP_MIC				BIT(30)
-#define	RCR_APP_ICV				BIT(29)
+#define	EEPROM_RF_BT_SETTING_88E				0xC3
+#define	EEPROM_VERSION					0xC4
+#define	EEPROM_CUSTOMER_ID					0xC5
+#define	EEPROM_RF_ANTENNA_OPT_88E			0xC9
+
+#define	EEPROM_MAC_ADDR					0xD0
+#define EEPROM_VID							0xD6
+#define EEPROM_DID							0xD8
+#define EEPROM_SVID							0xDA
+#define EEPROM_SMID						0xDC
+
+#define	STOPBECON					BIT(6)
+#define	STOPHIGHT					BIT(5)
+#define	STOPMGT						BIT(4)
+#define	STOPVO						BIT(3)
+#define	STOPVI						BIT(2)
+#define	STOPBE						BIT(1)
+#define	STOPBK						BIT(0)
+
+#define	RCR_APPFCS					BIT(31)
+#define	RCR_APP_MIC					BIT(30)
+#define	RCR_APP_ICV					BIT(29)
 #define	RCR_APP_PHYST_RXFF			BIT(28)
 #define	RCR_APP_BA_SSN				BIT(27)
-#define	RCR_ENMBID				BIT(24)
-#define	RCR_LSIGEN				BIT(23)
-#define	RCR_MFBEN				BIT(22)
+#define	RCR_ENMBID					BIT(24)
+#define	RCR_LSIGEN					BIT(23)
+#define	RCR_MFBEN					BIT(22)
 #define	RCR_HTC_LOC_CTRL			BIT(14)
-#define	RCR_AMF					BIT(13)
-#define	RCR_ACF					BIT(12)
-#define	RCR_ADF					BIT(11)
-#define	RCR_AICV				BIT(9)
-#define	RCR_ACRC32				BIT(8)
+#define	RCR_AMF						BIT(13)
+#define	RCR_ACF						BIT(12)
+#define	RCR_ADF						BIT(11)
+#define	RCR_AICV					BIT(9)
+#define	RCR_ACRC32					BIT(8)
 #define	RCR_CBSSID_BCN				BIT(7)
 #define	RCR_CBSSID_DATA				BIT(6)
-#define	RCR_CBSSID				RCR_CBSSID_DATA
-#define	RCR_APWRMGT				BIT(5)
-#define	RCR_ADD3				BIT(4)
-#define	RCR_AB					BIT(3)
-#define	RCR_AM					BIT(2)
-#define	RCR_APM					BIT(1)
-#define	RCR_AAP					BIT(0)
+#define	RCR_CBSSID					RCR_CBSSID_DATA
+#define	RCR_APWRMGT					BIT(5)
+#define	RCR_ADD3					BIT(4)
+#define	RCR_AB						BIT(3)
+#define	RCR_AM						BIT(2)
+#define	RCR_APM						BIT(1)
+#define	RCR_AAP						BIT(0)
 #define	RCR_MXDMA_OFFSET			8
 #define	RCR_FIFO_OFFSET				13
 
-#define RSV_CTRL				0x001C
-#define RD_CTRL					0x0524
+#define RSV_CTRL					0x001C
+#define RD_CTRL						0x0524
 
 #define REG_USB_INFO				0xFE17
-#define REG_USB_SPECIAL_OPTION			0xFE55
+#define REG_USB_SPECIAL_OPTION		0xFE55
 #define REG_USB_DMA_AGG_TO			0xFE5B
 #define REG_USB_AGG_TO				0xFE5C
 #define REG_USB_AGG_TH				0xFE5D
 
-#define REG_USB_VID				0xFE60
-#define REG_USB_PID				0xFE62
+#define REG_USB_VID					0xFE60
+#define REG_USB_PID					0xFE62
 #define REG_USB_OPTIONAL			0xFE64
 #define REG_USB_CHIRP_K				0xFE65
-#define REG_USB_PHY				0xFE66
+#define REG_USB_PHY					0xFE66
 #define REG_USB_MAC_ADDR			0xFE70
 #define REG_USB_HRPWM				0xFE58
 #define REG_USB_HCPWM				0xFE57
 
-#define SW18_FPWM				BIT(3)
+#define SW18_FPWM					BIT(3)
 
-#define ISO_MD2PP				BIT(0)
-#define ISO_UA2USB				BIT(1)
-#define ISO_UD2CORE				BIT(2)
-#define ISO_PA2PCIE				BIT(3)
-#define ISO_PD2CORE				BIT(4)
-#define ISO_IP2MAC				BIT(5)
-#define ISO_DIOP				BIT(6)
-#define ISO_DIOE				BIT(7)
-#define ISO_EB2CORE				BIT(8)
-#define ISO_DIOR				BIT(9)
+#define ISO_MD2PP					BIT(0)
+#define ISO_UA2USB					BIT(1)
+#define ISO_UD2CORE					BIT(2)
+#define ISO_PA2PCIE					BIT(3)
+#define ISO_PD2CORE					BIT(4)
+#define ISO_IP2MAC					BIT(5)
+#define ISO_DIOP					BIT(6)
+#define ISO_DIOE					BIT(7)
+#define ISO_EB2CORE					BIT(8)
+#define ISO_DIOR					BIT(9)
 
-#define PWC_EV25V				BIT(14)
-#define PWC_EV12V				BIT(15)
+#define PWC_EV25V					BIT(14)
+#define PWC_EV12V					BIT(15)
 
-#define FEN_BBRSTB				BIT(0)
+#define FEN_BBRSTB					BIT(0)
 #define FEN_BB_GLB_RSTN				BIT(1)
-#define FEN_USBA				BIT(2)
-#define FEN_UPLL				BIT(3)
-#define FEN_USBD				BIT(4)
+#define FEN_USBA					BIT(2)
+#define FEN_UPLL					BIT(3)
+#define FEN_USBD					BIT(4)
 #define FEN_DIO_PCIE				BIT(5)
-#define FEN_PCIEA				BIT(6)
-#define FEN_PPLL				BIT(7)
-#define FEN_PCIED				BIT(8)
-#define FEN_DIOE				BIT(9)
-#define FEN_CPUEN				BIT(10)
-#define FEN_DCORE				BIT(11)
-#define FEN_ELDR				BIT(12)
-#define FEN_DIO_RF				BIT(13)
-#define FEN_HWPDN				BIT(14)
-#define FEN_MREGEN				BIT(15)
-
-#define PFM_LDALL				BIT(0)
-#define PFM_ALDN				BIT(1)
-#define PFM_LDKP				BIT(2)
-#define PFM_WOWL				BIT(3)
-#define ENPDN					BIT(4)
-#define PDN_PL					BIT(5)
-#define APFM_ONMAC				BIT(8)
-#define APFM_OFF				BIT(9)
-#define APFM_RSM				BIT(10)
-#define AFSM_HSUS				BIT(11)
-#define AFSM_PCIE				BIT(12)
-#define APDM_MAC				BIT(13)
-#define APDM_HOST				BIT(14)
-#define APDM_HPDN				BIT(15)
-#define RDY_MACON				BIT(16)
-#define SUS_HOST				BIT(17)
-#define ROP_ALD					BIT(20)
-#define ROP_PWR					BIT(21)
-#define ROP_SPS					BIT(22)
-#define SOP_MRST				BIT(25)
-#define SOP_FUSE				BIT(26)
-#define SOP_ABG					BIT(27)
-#define SOP_AMB					BIT(28)
-#define SOP_RCK					BIT(29)
-#define SOP_A8M					BIT(30)
-#define XOP_BTCK				BIT(31)
-
-#define ANAD16V_EN				BIT(0)
-#define ANA8M					BIT(1)
-#define MACSLP					BIT(4)
+#define FEN_PCIEA					BIT(6)
+#define FEN_PPLL					BIT(7)
+#define FEN_PCIED					BIT(8)
+#define FEN_DIOE					BIT(9)
+#define FEN_CPUEN					BIT(10)
+#define FEN_DCORE					BIT(11)
+#define FEN_ELDR					BIT(12)
+#define FEN_DIO_RF					BIT(13)
+#define FEN_HWPDN					BIT(14)
+#define FEN_MREGEN					BIT(15)
+
+#define PFM_LDALL					BIT(0)
+#define PFM_ALDN					BIT(1)
+#define PFM_LDKP					BIT(2)
+#define PFM_WOWL					BIT(3)
+#define ENPDN						BIT(4)
+#define PDN_PL						BIT(5)
+#define APFM_ONMAC					BIT(8)
+#define APFM_OFF					BIT(9)
+#define APFM_RSM					BIT(10)
+#define AFSM_HSUS					BIT(11)
+#define AFSM_PCIE					BIT(12)
+#define APDM_MAC					BIT(13)
+#define APDM_HOST					BIT(14)
+#define APDM_HPDN					BIT(15)
+#define RDY_MACON					BIT(16)
+#define SUS_HOST					BIT(17)
+#define ROP_ALD						BIT(20)
+#define ROP_PWR						BIT(21)
+#define ROP_SPS						BIT(22)
+#define SOP_MRST					BIT(25)
+#define SOP_FUSE					BIT(26)
+#define SOP_ABG						BIT(27)
+#define SOP_AMB						BIT(28)
+#define SOP_RCK						BIT(29)
+#define SOP_A8M						BIT(30)
+#define XOP_BTCK					BIT(31)
+
+#define ANAD16V_EN					BIT(0)
+#define ANA8M						BIT(1)
+#define MACSLP						BIT(4)
 #define LOADER_CLK_EN				BIT(5)
 #define _80M_SSC_DIS				BIT(7)
 #define _80M_SSC_EN_HO				BIT(8)
 #define PHY_SSC_RSTB				BIT(9)
-#define SEC_CLK_EN				BIT(10)
-#define MAC_CLK_EN				BIT(11)
-#define SYS_CLK_EN				BIT(12)
-#define RING_CLK_EN				BIT(13)
+#define SEC_CLK_EN					BIT(10)
+#define MAC_CLK_EN					BIT(11)
+#define SYS_CLK_EN					BIT(12)
+#define RING_CLK_EN					BIT(13)
 
 #define	BOOT_FROM_EEPROM			BIT(4)
-#define	EEPROM_EN				BIT(5)
+#define	EEPROM_EN					BIT(5)
 
-#define AFE_BGEN				BIT(0)
-#define AFE_MBEN				BIT(1)
-#define MAC_ID_EN				BIT(7)
+#define AFE_BGEN					BIT(0)
+#define AFE_MBEN					BIT(1)
+#define MAC_ID_EN					BIT(7)
 
-#define WLOCK_ALL				BIT(0)
-#define WLOCK_00				BIT(1)
-#define WLOCK_04				BIT(2)
-#define WLOCK_08				BIT(3)
-#define WLOCK_40				BIT(4)
+#define WLOCK_ALL					BIT(0)
+#define WLOCK_00					BIT(1)
+#define WLOCK_04					BIT(2)
+#define WLOCK_08					BIT(3)
+#define WLOCK_40					BIT(4)
 #define R_DIS_PRST_0				BIT(5)
 #define R_DIS_PRST_1				BIT(6)
-#define LOCK_ALL_EN				BIT(7)
+#define LOCK_ALL_EN					BIT(7)
 
-#define RF_EN					BIT(0)
-#define RF_RSTB					BIT(1)
-#define RF_SDMRSTB				BIT(2)
+#define RF_EN						BIT(0)
+#define RF_RSTB						BIT(1)
+#define RF_SDMRSTB					BIT(2)
 
-#define LDA15_EN				BIT(0)
-#define LDA15_STBY				BIT(1)
-#define LDA15_OBUF				BIT(2)
+#define LDA15_EN					BIT(0)
+#define LDA15_STBY					BIT(1)
+#define LDA15_OBUF					BIT(2)
 #define LDA15_REG_VOS				BIT(3)
 #define _LDA15_VOADJ(x)				(((x) & 0x7) << 4)
 
-#define LDV12_EN				BIT(0)
-#define LDV12_SDBY				BIT(1)
-#define LPLDO_HSM				BIT(2)
+#define LDV12_EN					BIT(0)
+#define LDV12_SDBY					BIT(1)
+#define LPLDO_HSM					BIT(2)
 #define LPLDO_LSM_DIS				BIT(3)
 #define _LDV12_VADJ(x)				(((x) & 0xF) << 4)
 
-#define XTAL_EN					BIT(0)
-#define XTAL_BSEL				BIT(1)
+#define XTAL_EN						BIT(0)
+#define XTAL_BSEL					BIT(1)
 #define _XTAL_BOSC(x)				(((x) & 0x3) << 2)
 #define _XTAL_CADJ(x)				(((x) & 0xF) << 4)
 #define XTAL_GATE_USB				BIT(8)
@@ -871,145 +886,145 @@
 #define _XTAL_BT_DRV(x)				(((x) & 0x3) << 21)
 #define _XTAL_GPIO(x)				(((x) & 0x7) << 23)
 
-#define CKDLY_AFE				BIT(26)
-#define CKDLY_USB				BIT(27)
-#define CKDLY_DIG				BIT(28)
-#define CKDLY_BT				BIT(29)
+#define CKDLY_AFE					BIT(26)
+#define CKDLY_USB					BIT(27)
+#define CKDLY_DIG					BIT(28)
+#define CKDLY_BT					BIT(29)
 
-#define APLL_EN					BIT(0)
-#define APLL_320_EN				BIT(1)
+#define APLL_EN						BIT(0)
+#define APLL_320_EN					BIT(1)
 #define APLL_FREF_SEL				BIT(2)
 #define APLL_EDGE_SEL				BIT(3)
-#define APLL_WDOGB				BIT(4)
-#define APLL_LPFEN				BIT(5)
+#define APLL_WDOGB					BIT(4)
+#define APLL_LPFEN					BIT(5)
 
 #define APLL_REF_CLK_13MHZ			0x1
-#define APLL_REF_CLK_19_2MHZ			0x2
+#define APLL_REF_CLK_19_2MHZ		0x2
 #define APLL_REF_CLK_20MHZ			0x3
 #define APLL_REF_CLK_25MHZ			0x4
 #define APLL_REF_CLK_26MHZ			0x5
-#define APLL_REF_CLK_38_4MHZ			0x6
+#define APLL_REF_CLK_38_4MHZ		0x6
 #define APLL_REF_CLK_40MHZ			0x7
 
-#define APLL_320EN				BIT(14)
-#define APLL_80EN				BIT(15)
-#define APLL_1MEN				BIT(24)
-
-#define ALD_EN					BIT(18)
-#define EF_PD					BIT(19)
-#define EF_FLAG					BIT(31)
-
-#define EF_TRPT					BIT(7)
-#define LDOE25_EN				BIT(31)
-
-#define RSM_EN					BIT(0)
-#define TIMER_EN				BIT(4)
-
-#define TRSW0EN					BIT(2)
-#define TRSW1EN					BIT(3)
-#define EROM_EN					BIT(4)
-#define ENBT					BIT(5)
-#define ENUART					BIT(8)
-#define UART_910				BIT(9)
-#define ENPMAC					BIT(10)
-#define SIC_SWRST				BIT(11)
-#define ENSIC					BIT(12)
-#define SIC_23					BIT(13)
-#define ENHDP					BIT(14)
-#define SIC_LBK					BIT(15)
-
-#define LED0PL					BIT(4)
-#define LED1PL					BIT(12)
-#define LED0DIS					BIT(7)
-
-#define MCUFWDL_EN				BIT(0)
-#define MCUFWDL_RDY				BIT(1)
+#define APLL_320EN					BIT(14)
+#define APLL_80EN					BIT(15)
+#define APLL_1MEN					BIT(24)
+
+#define ALD_EN						BIT(18)
+#define EF_PD						BIT(19)
+#define EF_FLAG						BIT(31)
+
+#define EF_TRPT						BIT(7)
+#define LDOE25_EN					BIT(31)
+
+#define RSM_EN						BIT(0)
+#define TIMER_EN					BIT(4)
+
+#define TRSW0EN						BIT(2)
+#define TRSW1EN						BIT(3)
+#define EROM_EN						BIT(4)
+#define ENBT						BIT(5)
+#define ENUART						BIT(8)
+#define UART_910					BIT(9)
+#define ENPMAC						BIT(10)
+#define SIC_SWRST					BIT(11)
+#define ENSIC						BIT(12)
+#define SIC_23						BIT(13)
+#define ENHDP						BIT(14)
+#define SIC_LBK						BIT(15)
+
+#define LED0PL						BIT(4)
+#define LED1PL						BIT(12)
+#define LED0DIS						BIT(7)
+
+#define MCUFWDL_EN					BIT(0)
+#define MCUFWDL_RDY					BIT(1)
 #define FWDL_CHKSUM_RPT				BIT(2)
-#define MACINI_RDY				BIT(3)
-#define BBINI_RDY				BIT(4)
-#define RFINI_RDY				BIT(5)
-#define WINTINI_RDY				BIT(6)
-#define CPRST					BIT(23)
-
-#define XCLK_VLD				BIT(0)
-#define ACLK_VLD				BIT(1)
-#define UCLK_VLD				BIT(2)
-#define PCLK_VLD				BIT(3)
-#define PCIRSTB					BIT(4)
-#define V15_VLD					BIT(5)
-#define TRP_B15V_EN				BIT(7)
-#define SIC_IDLE				BIT(8)
-#define BD_MAC2					BIT(9)
-#define BD_MAC1					BIT(10)
+#define MACINI_RDY					BIT(3)
+#define BBINI_RDY					BIT(4)
+#define RFINI_RDY					BIT(5)
+#define WINTINI_RDY					BIT(6)
+#define CPRST						BIT(23)
+
+#define XCLK_VLD					BIT(0)
+#define ACLK_VLD					BIT(1)
+#define UCLK_VLD					BIT(2)
+#define PCLK_VLD					BIT(3)
+#define PCIRSTB						BIT(4)
+#define V15_VLD						BIT(5)
+#define TRP_B15V_EN					BIT(7)
+#define SIC_IDLE					BIT(8)
+#define BD_MAC2						BIT(9)
+#define BD_MAC1						BIT(10)
 #define IC_MACPHY_MODE				BIT(11)
-#define VENDOR_ID				BIT(19)
+#define VENDOR_ID					BIT(19)
 #define PAD_HWPD_IDN				BIT(22)
-#define TRP_VAUX_EN				BIT(23)
-#define TRP_BT_EN				BIT(24)
-#define BD_PKG_SEL				BIT(25)
-#define BD_HCI_SEL				BIT(26)
-#define TYPE_ID					BIT(27)
+#define TRP_VAUX_EN					BIT(23)
+#define TRP_BT_EN					BIT(24)
+#define BD_PKG_SEL					BIT(25)
+#define BD_HCI_SEL					BIT(26)
+#define TYPE_ID						BIT(27)
 
 #define CHIP_VER_RTL_MASK			0xF000
 #define CHIP_VER_RTL_SHIFT			12
 
-#define REG_LBMODE				(REG_CR + 3)
+#define REG_LBMODE					(REG_CR + 3)
 
 #define HCI_TXDMA_EN				BIT(0)
 #define HCI_RXDMA_EN				BIT(1)
-#define TXDMA_EN				BIT(2)
-#define RXDMA_EN				BIT(3)
-#define PROTOCOL_EN				BIT(4)
-#define SCHEDULE_EN				BIT(5)
-#define MACTXEN					BIT(6)
-#define MACRXEN					BIT(7)
-#define ENSWBCN					BIT(8)
-#define ENSEC					BIT(9)
-
-#define _NETTYPE(x)				(((x) & 0x3) << 16)
+#define TXDMA_EN					BIT(2)
+#define RXDMA_EN					BIT(3)
+#define PROTOCOL_EN					BIT(4)
+#define SCHEDULE_EN					BIT(5)
+#define MACTXEN						BIT(6)
+#define MACRXEN						BIT(7)
+#define ENSWBCN						BIT(8)
+#define ENSEC						BIT(9)
+
+#define _NETTYPE(x)					(((x) & 0x3) << 16)
 #define MASK_NETTYPE				0x30000
-#define NT_NO_LINK				0x0
+#define NT_NO_LINK					0x0
 #define NT_LINK_AD_HOC				0x1
-#define NT_LINK_AP				0x2
-#define NT_AS_AP				0x3
+#define NT_LINK_AP					0x2
+#define NT_AS_AP					0x3
 
-#define _LBMODE(x)				(((x) & 0xF) << 24)
-#define MASK_LBMODE				0xF000000
+#define _LBMODE(x)					(((x) & 0xF) << 24)
+#define MASK_LBMODE					0xF000000
 #define LOOPBACK_NORMAL				0x0
-#define LOOPBACK_IMMEDIATELY			0xB
+#define LOOPBACK_IMMEDIATELY		0xB
 #define LOOPBACK_MAC_DELAY			0x3
 #define LOOPBACK_PHY				0x1
 #define LOOPBACK_DMA				0x7
 
 #define GET_RX_PAGE_SIZE(value)		((value) & 0xF)
 #define GET_TX_PAGE_SIZE(value)		(((value) & 0xF0) >> 4)
-#define _PSRX_MASK				0xF
-#define _PSTX_MASK				0xF0
-#define _PSRX(x)				(x)
-#define _PSTX(x)				((x) << 4)
+#define _PSRX_MASK					0xF
+#define _PSTX_MASK					0xF0
+#define _PSRX(x)					(x)
+#define _PSTX(x)					((x) << 4)
 
-#define PBP_64					0x0
-#define PBP_128					0x1
-#define PBP_256					0x2
-#define PBP_512					0x3
-#define PBP_1024				0x4
+#define PBP_64						0x0
+#define PBP_128						0x1
+#define PBP_256						0x2
+#define PBP_512						0x3
+#define PBP_1024					0x4
 
 #define RXDMA_ARBBW_EN				BIT(0)
-#define RXSHFT_EN				BIT(1)
+#define RXSHFT_EN					BIT(1)
 #define RXDMA_AGG_EN				BIT(2)
-#define QS_VO_QUEUE				BIT(8)
-#define QS_VI_QUEUE				BIT(9)
-#define QS_BE_QUEUE				BIT(10)
-#define QS_BK_QUEUE				BIT(11)
+#define QS_VO_QUEUE					BIT(8)
+#define QS_VI_QUEUE					BIT(9)
+#define QS_BE_QUEUE					BIT(10)
+#define QS_BK_QUEUE					BIT(11)
 #define QS_MANAGER_QUEUE			BIT(12)
 #define QS_HIGH_QUEUE				BIT(13)
 
-#define HQSEL_VOQ				BIT(0)
-#define HQSEL_VIQ				BIT(1)
-#define HQSEL_BEQ				BIT(2)
-#define HQSEL_BKQ				BIT(3)
-#define HQSEL_MGTQ				BIT(4)
-#define HQSEL_HIQ				BIT(5)
+#define HQSEL_VOQ					BIT(0)
+#define HQSEL_VIQ					BIT(1)
+#define HQSEL_BEQ					BIT(2)
+#define HQSEL_BKQ					BIT(3)
+#define HQSEL_MGTQ					BIT(4)
+#define HQSEL_HIQ					BIT(5)
 
 #define _TXDMA_HIQ_MAP(x)			(((x)&0x3) << 14)
 #define _TXDMA_MGQ_MAP(x)			(((x)&0x3) << 12)
@@ -1018,9 +1033,9 @@
 #define _TXDMA_VIQ_MAP(x)			(((x)&0x3) << 6)
 #define _TXDMA_VOQ_MAP(x)			(((x)&0x3) << 4)
 
-#define QUEUE_LOW				1
+#define QUEUE_LOW					1
 #define QUEUE_NORMAL				2
-#define QUEUE_HIGH				3
+#define QUEUE_HIGH					3
 
 #define _LLT_NO_ACTIVE				0x0
 #define _LLT_WRITE_ACCESS			0x1
@@ -1028,25 +1043,25 @@
 
 #define _LLT_INIT_DATA(x)			((x) & 0xFF)
 #define _LLT_INIT_ADDR(x)			(((x) & 0xFF) << 8)
-#define _LLT_OP(x)				(((x) & 0x3) << 30)
+#define _LLT_OP(x)					(((x) & 0x3) << 30)
 #define _LLT_OP_VALUE(x)			(((x) >> 30) & 0x3)
 
 #define BB_WRITE_READ_MASK			(BIT(31) | BIT(30))
-#define BB_WRITE_EN				BIT(30)
-#define BB_READ_EN				BIT(31)
+#define BB_WRITE_EN					BIT(30)
+#define BB_READ_EN					BIT(31)
 
-#define _HPQ(x)					((x) & 0xFF)
-#define _LPQ(x)					(((x) & 0xFF) << 8)
-#define _PUBQ(x)				(((x) & 0xFF) << 16)
-#define _NPQ(x)					((x) & 0xFF)
+#define _HPQ(x)			((x) & 0xFF)
+#define _LPQ(x)			(((x) & 0xFF) << 8)
+#define _PUBQ(x)		(((x) & 0xFF) << 16)
+#define _NPQ(x)			((x) & 0xFF)
 
-#define HPQ_PUBLIC_DIS				BIT(24)
-#define LPQ_PUBLIC_DIS				BIT(25)
-#define LD_RQPN					BIT(31)
+#define HPQ_PUBLIC_DIS		BIT(24)
+#define LPQ_PUBLIC_DIS		BIT(25)
+#define LD_RQPN			BIT(31)
 
-#define BCN_VALID				BIT(16)
-#define BCN_HEAD(x)				(((x) & 0xFF) << 8)
-#define	BCN_HEAD_MASK				0xFF00
+#define BCN_VALID		BIT(16)
+#define BCN_HEAD(x)		(((x) & 0xFF) << 8)
+#define	BCN_HEAD_MASK		0xFF00
 
 #define BLK_DESC_NUM_SHIFT			4
 #define BLK_DESC_NUM_MASK			0xF
@@ -1066,9 +1081,9 @@
 
 #define _RRSR_RSC(x)				(((x) & 0x3) << 21)
 #define RRSR_RSC_RESERVED			0x0
-#define RRSR_RSC_UPPER_SUBCHANNEL		0x1
-#define RRSR_RSC_LOWER_SUBCHANNEL		0x2
-#define RRSR_RSC_DUPLICATE_MODE			0x3
+#define RRSR_RSC_UPPER_SUBCHANNEL	0x1
+#define RRSR_RSC_LOWER_SUBCHANNEL	0x2
+#define RRSR_RSC_DUPLICATE_MODE		0x3
 
 #define USE_SHORT_G1				BIT(20)
 
@@ -1081,8 +1096,8 @@
 #define _AGGLMT_MCS6(x)				(((x) & 0xF) << 24)
 #define _AGGLMT_MCS7(x)				(((x) & 0xF) << 28)
 
-#define	RETRY_LIMIT_SHORT_SHIFT			8
-#define	RETRY_LIMIT_LONG_SHIFT			0
+#define	RETRY_LIMIT_SHORT_SHIFT		8
+#define	RETRY_LIMIT_LONG_SHIFT		0
 
 #define _DARF_RC1(x)				((x) & 0x1F)
 #define _DARF_RC2(x)				(((x) & 0x1F) << 8)
@@ -1102,20 +1117,20 @@
 #define _RARF_RC7(x)				(((x) & 0x1F) << 16)
 #define _RARF_RC8(x)				(((x) & 0x1F) << 24)
 
-#define AC_PARAM_TXOP_LIMIT_OFFSET		16
-#define AC_PARAM_ECW_MAX_OFFSET			12
-#define AC_PARAM_ECW_MIN_OFFSET			8
-#define AC_PARAM_AIFS_OFFSET			0
+#define AC_PARAM_TXOP_LIMIT_OFFSET	16
+#define AC_PARAM_ECW_MAX_OFFSET		12
+#define AC_PARAM_ECW_MIN_OFFSET		8
+#define AC_PARAM_AIFS_OFFSET		0
 
-#define _AIFS(x)				(x)
+#define _AIFS(x)					(x)
 #define _ECW_MAX_MIN(x)				((x) << 8)
 #define _TXOP_LIMIT(x)				((x) << 16)
 
-#define _BCNIFS(x)				((x) & 0xFF)
-#define _BCNECW(x)				((((x) & 0xF)) << 8)
+#define _BCNIFS(x)					((x) & 0xFF)
+#define _BCNECW(x)					((((x) & 0xF)) << 8)
 
-#define _LRL(x)					((x) & 0x3F)
-#define _SRL(x)					(((x) & 0x3F) << 8)
+#define _LRL(x)						((x) & 0x3F)
+#define _SRL(x)						(((x) & 0x3F) << 8)
 
 #define _SIFS_CCK_CTX(x)			((x) & 0xFF)
 #define _SIFS_CCK_TRX(x)			(((x) & 0xFF) << 8);
@@ -1123,102 +1138,102 @@
 #define _SIFS_OFDM_CTX(x)			((x) & 0xFF)
 #define _SIFS_OFDM_TRX(x)			(((x) & 0xFF) << 8);
 
-#define _TBTT_PROHIBIT_HOLD(x)			(((x) & 0xFF) << 8)
+#define _TBTT_PROHIBIT_HOLD(x)		(((x) & 0xFF) << 8)
 
 #define DIS_EDCA_CNT_DWN			BIT(11)
 
-#define EN_MBSSID				BIT(1)
+#define EN_MBSSID					BIT(1)
 #define EN_TXBCN_RPT				BIT(2)
 #define	EN_BCN_FUNCTION				BIT(3)
 
-#define TSFTR_RST				BIT(0)
-#define TSFTR1_RST				BIT(1)
+#define TSFTR_RST					BIT(0)
+#define TSFTR1_RST					BIT(1)
 
-#define STOP_BCNQ				BIT(6)
+#define STOP_BCNQ					BIT(6)
 
-#define	DIS_TSF_UDT0_NORMAL_CHIP		BIT(4)
-#define	DIS_TSF_UDT0_TEST_CHIP			BIT(5)
+#define	DIS_TSF_UDT0_NORMAL_CHIP	BIT(4)
+#define	DIS_TSF_UDT0_TEST_CHIP		BIT(5)
 
-#define	ACMHW_HWEN				BIT(0)
-#define	ACMHW_BEQEN				BIT(1)
-#define	ACMHW_VIQEN				BIT(2)
-#define	ACMHW_VOQEN				BIT(3)
+#define	ACMHW_HWEN					BIT(0)
+#define	ACMHW_BEQEN					BIT(1)
+#define	ACMHW_VIQEN					BIT(2)
+#define	ACMHW_VOQEN					BIT(3)
 #define	ACMHW_BEQSTATUS				BIT(4)
 #define	ACMHW_VIQSTATUS				BIT(5)
 #define	ACMHW_VOQSTATUS				BIT(6)
 
-#define APSDOFF					BIT(6)
+#define APSDOFF						BIT(6)
 #define APSDOFF_STATUS				BIT(7)
 
-#define BW_20MHZ				BIT(2)
+#define BW_20MHZ					BIT(2)
 
 #define RATE_BITMAP_ALL				0xFFFFF
 
-#define RATE_RRSR_CCK_ONLY_1M			0xFFFF1
+#define RATE_RRSR_CCK_ONLY_1M		0xFFFF1
 
-#define TSFRST					BIT(0)
-#define DIS_GCLK				BIT(1)
-#define PAD_SEL					BIT(2)
-#define PWR_ST					BIT(6)
+#define TSFRST						BIT(0)
+#define DIS_GCLK					BIT(1)
+#define PAD_SEL						BIT(2)
+#define PWR_ST						BIT(6)
 #define PWRBIT_OW_EN				BIT(7)
-#define ACRC					BIT(8)
-#define CFENDFORM				BIT(9)
-#define ICV					BIT(10)
-
-#define AAP					BIT(0)
-#define APM					BIT(1)
-#define AM					BIT(2)
-#define AB					BIT(3)
-#define ADD3					BIT(4)
-#define APWRMGT					BIT(5)
-#define CBSSID					BIT(6)
-#define CBSSID_DATA				BIT(6)
-#define CBSSID_BCN				BIT(7)
-#define ACRC32					BIT(8)
-#define AICV					BIT(9)
-#define ADF					BIT(11)
-#define ACF					BIT(12)
-#define AMF					BIT(13)
+#define ACRC						BIT(8)
+#define CFENDFORM					BIT(9)
+#define ICV							BIT(10)
+
+#define AAP							BIT(0)
+#define APM							BIT(1)
+#define AM							BIT(2)
+#define AB							BIT(3)
+#define ADD3						BIT(4)
+#define APWRMGT						BIT(5)
+#define CBSSID						BIT(6)
+#define CBSSID_DATA					BIT(6)
+#define CBSSID_BCN					BIT(7)
+#define ACRC32						BIT(8)
+#define AICV						BIT(9)
+#define ADF							BIT(11)
+#define ACF							BIT(12)
+#define AMF							BIT(13)
 #define HTC_LOC_CTRL				BIT(14)
-#define UC_DATA_EN				BIT(16)
-#define BM_DATA_EN				BIT(17)
-#define MFBEN					BIT(22)
-#define LSIGEN					BIT(23)
-#define ENMBID					BIT(24)
-#define APP_BASSN				BIT(27)
-#define APP_PHYSTS				BIT(28)
-#define APP_ICV					BIT(29)
-#define APP_MIC					BIT(30)
-#define APP_FCS					BIT(31)
+#define UC_DATA_EN					BIT(16)
+#define BM_DATA_EN					BIT(17)
+#define MFBEN						BIT(22)
+#define LSIGEN						BIT(23)
+#define ENMBID						BIT(24)
+#define APP_BASSN					BIT(27)
+#define APP_PHYSTS					BIT(28)
+#define APP_ICV						BIT(29)
+#define APP_MIC						BIT(30)
+#define APP_FCS						BIT(31)
 
 #define _MIN_SPACE(x)				((x) & 0x7)
-#define _SHORT_GI_PADDING(x)			(((x) & 0x1F) << 3)
+#define _SHORT_GI_PADDING(x)		(((x) & 0x1F) << 3)
 
-#define RXERR_TYPE_OFDM_PPDU			0
-#define RXERR_TYPE_OFDM_FALSE_ALARM		1
-#define	RXERR_TYPE_OFDM_MPDU_OK			2
-#define RXERR_TYPE_OFDM_MPDU_FAIL		3
+#define RXERR_TYPE_OFDM_PPDU		0
+#define RXERR_TYPE_OFDM_FALSE_ALARM	1
+#define	RXERR_TYPE_OFDM_MPDU_OK		2
+#define RXERR_TYPE_OFDM_MPDU_FAIL	3
 #define RXERR_TYPE_CCK_PPDU			4
-#define RXERR_TYPE_CCK_FALSE_ALARM		5
-#define RXERR_TYPE_CCK_MPDU_OK			6
-#define RXERR_TYPE_CCK_MPDU_FAIL		7
+#define RXERR_TYPE_CCK_FALSE_ALARM	5
+#define RXERR_TYPE_CCK_MPDU_OK		6
+#define RXERR_TYPE_CCK_MPDU_FAIL	7
 #define RXERR_TYPE_HT_PPDU			8
-#define RXERR_TYPE_HT_FALSE_ALARM		9
-#define RXERR_TYPE_HT_MPDU_TOTAL		10
-#define RXERR_TYPE_HT_MPDU_OK			11
-#define RXERR_TYPE_HT_MPDU_FAIL			12
-#define RXERR_TYPE_RX_FULL_DROP			15
+#define RXERR_TYPE_HT_FALSE_ALARM	9
+#define RXERR_TYPE_HT_MPDU_TOTAL	10
+#define RXERR_TYPE_HT_MPDU_OK		11
+#define RXERR_TYPE_HT_MPDU_FAIL		12
+#define RXERR_TYPE_RX_FULL_DROP		15
 
 #define RXERR_COUNTER_MASK			0xFFFFF
 #define RXERR_RPT_RST				BIT(27)
-#define _RXERR_RPT_SEL(type)			((type) << 28)
+#define _RXERR_RPT_SEL(type)		((type) << 28)
 
-#define	SCR_TXUSEDK				BIT(0)
-#define	SCR_RXUSEDK				BIT(1)
+#define	SCR_TXUSEDK					BIT(0)
+#define	SCR_RXUSEDK					BIT(1)
 #define	SCR_TXENCENABLE				BIT(2)
 #define	SCR_RXDECENABLE				BIT(3)
-#define	SCR_SKBYA2				BIT(4)
-#define	SCR_NOSKMC				BIT(5)
+#define	SCR_SKBYA2					BIT(4)
+#define	SCR_NOSKMC					BIT(5)
 #define SCR_TXBCUSEDK				BIT(6)
 #define SCR_RXBCUSEDK				BIT(7)
 
@@ -1226,32 +1241,32 @@
 #define USB_IS_FULL_SPEED			1
 #define USB_SPEED_MASK				BIT(5)
 
-#define USB_NORMAL_SIE_EP_MASK			0xF
-#define USB_NORMAL_SIE_EP_SHIFT			4
+#define USB_NORMAL_SIE_EP_MASK		0xF
+#define USB_NORMAL_SIE_EP_SHIFT		4
 
 #define USB_TEST_EP_MASK			0x30
 #define USB_TEST_EP_SHIFT			4
 
-#define USB_AGG_EN				BIT(3)
+#define USB_AGG_EN					BIT(3)
 
 #define MAC_ADDR_LEN				6
-#define LAST_ENTRY_OF_TX_PKT_BUFFER		175/*255    88e*/
+#define LAST_ENTRY_OF_TX_PKT_BUFFER	175/*255    88e*/
 
-#define POLLING_LLT_THRESHOLD			20
+#define POLLING_LLT_THRESHOLD		20
 #define POLLING_READY_TIMEOUT_COUNT		3000
 
 #define	MAX_MSS_DENSITY_2T			0x13
 #define	MAX_MSS_DENSITY_1T			0x0A
 
-#define EPROM_CMD_OPERATING_MODE_MASK		((1<<7)|(1<<6))
+#define EPROM_CMD_OPERATING_MODE_MASK	((1<<7)|(1<<6))
 #define EPROM_CMD_CONFIG			0x3
 #define EPROM_CMD_LOAD				1
 
 #define	HWSET_MAX_SIZE_92S			HWSET_MAX_SIZE
 
-#define	HAL_8192C_HW_GPIO_WPS_BIT		BIT(2)
+#define	HAL_8192C_HW_GPIO_WPS_BIT	BIT(2)
 
-#define	RPMAC_RESET				0x100
+#define	RPMAC_RESET					0x100
 #define	RPMAC_TXSTART				0x104
 #define	RPMAC_TXLEGACYSIG			0x108
 #define	RPMAC_TXHTSIG1				0x10c
@@ -1267,12 +1282,12 @@
 #define	RPMAC_TXMACHEADER5			0x134
 #define	RPMAC_TXDADATYPE			0x138
 #define	RPMAC_TXRANDOMSEED			0x13c
-#define	RPMAC_CCKPLCPPREAMBLE			0x140
+#define	RPMAC_CCKPLCPPREAMBLE		0x140
 #define	RPMAC_CCKPLCPHEADER			0x144
 #define	RPMAC_CCKCRC16				0x148
 #define	RPMAC_OFDMRXCRC32OK			0x170
-#define	RPMAC_OFDMRXCRC32Er			0x174
-#define	RPMAC_OFDMRXPARITYER			0x178
+#define	RPMAC_OFDMRXCRC32ER			0x174
+#define	RPMAC_OFDMRXPARITYER		0x178
 #define	RPMAC_OFDMRXCRC8ER			0x17c
 #define	RPMAC_CCKCRXRC16ER			0x180
 #define	RPMAC_CCKCRXRC32ER			0x184
@@ -1289,45 +1304,45 @@
 #define	RFPGA0_RFTIMING1			0x810
 #define	RFPGA0_RFTIMING2			0x814
 
-#define	RFPGA0_XA_HSSIPARAMETER1		0x820
-#define	RFPGA0_XA_HSSIPARAMETER2		0x824
-#define	RFPGA0_XB_HSSIPARAMETER1		0x828
-#define	RFPGA0_XB_HSSIPARAMETER2		0x82c
+#define	RFPGA0_XA_HSSIPARAMETER1	0x820
+#define	RFPGA0_XA_HSSIPARAMETER2	0x824
+#define	RFPGA0_XB_HSSIPARAMETER1	0x828
+#define	RFPGA0_XB_HSSIPARAMETER2	0x82c
 
-#define	RFPGA0_XA_LSSIPARAMETER			0x840
-#define	RFPGA0_XB_LSSIPARAMETER			0x844
+#define	RFPGA0_XA_LSSIPARAMETER		0x840
+#define	RFPGA0_XB_LSSIPARAMETER		0x844
 
-#define	RFPGA0_RFWAKEUPPARAMETER		0x850
-#define	RFPGA0_RFSLEEPUPPARAMETER		0x854
+#define	RFPGA0_RFWAKEUPPARAMETER	0x850
+#define	RFPGA0_RFSLEEPUPPARAMETER	0x854
 
-#define	RFPGA0_XAB_SWITCHCONTROL		0x858
-#define	RFPGA0_XCD_SWITCHCONTROL		0x85c
+#define	RFPGA0_XAB_SWITCHCONTROL	0x858
+#define	RFPGA0_XCD_SWITCHCONTROL	0x85c
 
-#define	RFPGA0_XA_RFINTERFACEOE			0x860
-#define	RFPGA0_XB_RFINTERFACEOE			0x864
+#define	RFPGA0_XA_RFINTERFACEOE		0x860
+#define	RFPGA0_XB_RFINTERFACEOE		0x864
 
-#define	RFPGA0_XAB_RFINTERFACESW		0x870
-#define	RFPGA0_XCD_RFINTERFACESW		0x874
+#define	RFPGA0_XAB_RFINTERFACESW	0x870
+#define	RFPGA0_XCD_RFINTERFACESW	0x874
 
-#define	rFPGA0_XAB_RFPARAMETER			0x878
-#define	rFPGA0_XCD_RFPARAMETER			0x87c
+#define	RFPGA0_XAB_RFPARAMETER		0x878
+#define	RFPGA0_XCD_RFPARAMETER		0x87c
 
-#define	RFPGA0_ANALOGPARAMETER1			0x880
-#define	RFPGA0_ANALOGPARAMETER2			0x884
-#define	RFPGA0_ANALOGPARAMETER3			0x888
-#define	RFPGA0_ANALOGPARAMETER4			0x88c
+#define	RFPGA0_ANALOGPARAMETER1		0x880
+#define	RFPGA0_ANALOGPARAMETER2		0x884
+#define	RFPGA0_ANALOGPARAMETER3		0x888
+#define	RFPGA0_ANALOGPARAMETER4		0x88c
 
-#define	RFPGA0_XA_LSSIREADBACK			0x8a0
-#define	RFPGA0_XB_LSSIREADBACK			0x8a4
-#define	RFPGA0_XC_LSSIREADBACK			0x8a8
-#define	RFPGA0_XD_LSSIREADBACK			0x8ac
+#define	RFPGA0_XA_LSSIREADBACK		0x8a0
+#define	RFPGA0_XB_LSSIREADBACK		0x8a4
+#define	RFPGA0_XC_LSSIREADBACK		0x8a8
+#define	RFPGA0_XD_LSSIREADBACK		0x8ac
 
 #define	RFPGA0_PSDREPORT			0x8b4
-#define	TRANSCEIVEA_HSPI_READBACK		0x8b8
-#define	TRANSCEIVEB_HSPI_READBACK		0x8bc
-#define	REG_SC_CNT				0x8c4
-#define	RFPGA0_XAB_RFINTERFACERB		0x8e0
-#define	RFPGA0_XCD_RFINTERFACERB		0x8e4
+#define	TRANSCEIVEA_HSPI_READBACK	0x8b8
+#define	TRANSCEIVEB_HSPI_READBACK	0x8bc
+#define	REG_SC_CNT						0x8c4
+#define	RFPGA0_XAB_RFINTERFACERB	0x8e0
+#define	RFPGA0_XCD_RFINTERFACERB	0x8e4
 
 #define	RFPGA1_RFMOD				0x900
 
@@ -1338,12 +1353,12 @@
 #define	RCCK0_SYSTEM				0xa00
 
 #define	RCCK0_AFESETTING			0xa04
-#define	RCCK0_CCA				0xa08
+#define	RCCK0_CCA					0xa08
 
 #define	RCCK0_RXAGC1				0xa0c
 #define	RCCK0_RXAGC2				0xa10
 
-#define	RCCK0_RXHP				0xa14
+#define	RCCK0_RXHP					0xa14
 
 #define	RCCK0_DSPPARAMETER1			0xa18
 #define	RCCK0_DSPPARAMETER2			0xa1c
@@ -1351,75 +1366,74 @@
 #define	RCCK0_TXFILTER1				0xa20
 #define	RCCK0_TXFILTER2				0xa24
 #define	RCCK0_DEBUGPORT				0xa28
-#define	RCCK0_FALSEALARMREPORT			0xa2c
-#define	RCCK0_TRSSIREPORT			0xa50
-#define	RCCK0_RXREPORT				0xa54
-#define	RCCK0_FACOUNTERLOWER			0xa5c
-#define	RCCK0_FACOUNTERUPPER			0xa58
-#define	RCCK0_CCA_CNT				0xa60
-
+#define	RCCK0_FALSEALARMREPORT		0xa2c
+#define	RCCK0_TRSSIREPORT		0xa50
+#define	RCCK0_RXREPORT			0xa54
+#define	RCCK0_FACOUNTERLOWER		0xa5c
+#define	RCCK0_FACOUNTERUPPER		0xa58
+#define	RCCK0_CCA_CNT			0xa60
 
 /* PageB(0xB00) */
-#define	RPDP_ANTA				0xb00
+#define	RPDP_ANTA					0xb00
 #define	RPDP_ANTA_4				0xb04
 #define	RPDP_ANTA_8				0xb08
 #define	RPDP_ANTA_C				0xb0c
-#define	RPDP_ANTA_10				0xb10
-#define	RPDP_ANTA_14				0xb14
-#define	RPDP_ANTA_18				0xb18
-#define	RPDP_ANTA_1C				0xb1c
-#define	RPDP_ANTA_20				0xb20
-#define	RPDP_ANTA_24				0xb24
+#define	RPDP_ANTA_10					0xb10
+#define	RPDP_ANTA_14					0xb14
+#define	RPDP_ANTA_18					0xb18
+#define	RPDP_ANTA_1C					0xb1c
+#define	RPDP_ANTA_20					0xb20
+#define	RPDP_ANTA_24					0xb24
 
 #define	RCONFIG_PMPD_ANTA			0xb28
-#define	RCONFIG_RAM64X16			0xb2c
+#define	RCONFIG_RAM64x16				0xb2c
 
-#define	RBNDA					0xb30
-#define	RHSSIPAR				0xb34
+#define	RBNDA						0xb30
+#define	RHSSIPAR						0xb34
 
-#define	RCONFIG_ANTA				0xb68
-#define	RCONFIG_ANTB				0xb6c
+#define	RCONFIG_ANTA					0xb68
+#define	RCONFIG_ANTB					0xb6c
 
-#define	RPDP_ANTB				0xb70
-#define	RPDP_ANTB_4				0xb74
-#define	RPDP_ANTB_8				0xb78
-#define	RPDP_ANTB_C				0xb7c
-#define	RPDP_ANTB_10				0xb80
-#define	RPDP_ANTB_14				0xb84
-#define	RPDP_ANTB_18				0xb88
-#define	RPDP_ANTB_1C				0xb8c
-#define	RPDP_ANTB_20				0xb90
-#define	RPDP_ANTB_24				0xb94
+#define	RPDP_ANTB					0xb70
+#define	RPDP_ANTB_4					0xb74
+#define	RPDP_ANTB_8					0xb78
+#define	RPDP_ANTB_C					0xb7c
+#define	RPDP_ANTB_10					0xb80
+#define	RPDP_ANTB_14					0xb84
+#define	RPDP_ANTB_18					0xb88
+#define	RPDP_ANTB_1C					0xb8c
+#define	RPDP_ANTB_20					0xb90
+#define	RPDP_ANTB_24					0xb94
 
 #define	RCONFIG_PMPD_ANTB			0xb98
 
-#define	RBNDB					0xba0
+#define	RBNDB						0xba0
 
-#define	RAPK					0xbd8
-#define	rPm_Rx0_AntA				0xbdc
-#define	rPm_Rx1_AntA				0xbe0
-#define	rPm_Rx2_AntA				0xbe4
-#define	rPm_Rx3_AntA				0xbe8
-#define	rPm_Rx0_AntB				0xbec
-#define	rPm_Rx1_AntB				0xbf0
-#define	rPm_Rx2_AntB				0xbf4
-#define	rPm_Rx3_AntB				0xbf8
+#define	RAPK							0xbd8
+#define	RPM_RX0_ANTA				0xbdc
+#define	RPM_RX1_ANTA				0xbe0
+#define	RPM_RX2_ANTA				0xbe4
+#define	RPM_RX3_ANTA				0xbe8
+#define	RPM_RX0_ANTB				0xbec
+#define	RPM_RX1_ANTB				0xbf0
+#define	RPM_RX2_ANTB				0xbf4
+#define	RPM_RX3_ANTB				0xbf8
 
 /*Page C*/
-#define	ROFDM0_LSTF				0xc00
+#define	ROFDM0_LSTF					0xc00
 
-#define	ROFDM0_TRXPATHENABLE			0xc04
+#define	ROFDM0_TRXPATHENABLE		0xc04
 #define	ROFDM0_TRMUXPAR				0xc08
-#define	ROFDM0_TRSWISOLATION			0xc0c
+#define	ROFDM0_TRSWISOLATION		0xc0c
 
 #define	ROFDM0_XARXAFE				0xc10
-#define	ROFDM0_XARXIQIMBAL			0xc14
-#define	ROFDM0_XBRXAFE				0xc18
-#define	ROFDM0_XBRXIQIMBAL			0xc1c
-#define	ROFDM0_XCRXAFE				0xc20
-#define	ROFDM0_XCRXIQIMBAL			0xc24
-#define	ROFDM0_XDRXAFE				0xc28
-#define	ROFDM0_XDRXIQIMBAL			0xc2c
+#define	ROFDM0_XARXIQIMBALANCE		0xc14
+#define	ROFDM0_XBRXAFE			0xc18
+#define	ROFDM0_XBRXIQIMBALANCE		0xc1c
+#define	ROFDM0_XCRXAFE			0xc20
+#define	ROFDM0_XCRXIQIMBANLANCE		0xc24
+#define	ROFDM0_XDRXAFE			0xc28
+#define	ROFDM0_XDRXIQIMBALANCE		0xc2c
 
 #define	ROFDM0_RXDETECTOR1			0xc30
 #define	ROFDM0_RXDETECTOR2			0xc34
@@ -1428,8 +1442,8 @@
 
 #define	ROFDM0_RXDSP				0xc40
 #define	ROFDM0_CFOANDDAGC			0xc44
-#define	ROFDM0_CCADROPTHRES			0xc48
-#define	ROFDM0_ECCATHRES			0xc4c
+#define	ROFDM0_CCADROPTHRESHOLD		0xc48
+#define	ROFDM0_ECCATHRESHOLD		0xc4c
 
 #define	ROFDM0_XAAGCCORE1			0xc50
 #define	ROFDM0_XAAGCCORE2			0xc54
@@ -1440,18 +1454,18 @@
 #define	ROFDM0_XDAGCCORE1			0xc68
 #define	ROFDM0_XDAGCCORE2			0xc6c
 
-#define	ROFDM0_AGCPARAMETER1			0xc70
-#define	ROFDM0_AGCPARAMETER2			0xc74
+#define	ROFDM0_AGCPARAMETER1		0xc70
+#define	ROFDM0_AGCPARAMETER2		0xc74
 #define	ROFDM0_AGCRSSITABLE			0xc78
 #define	ROFDM0_HTSTFAGC				0xc7c
 
-#define	ROFDM0_XATXIQIMBAL			0xc80
+#define	ROFDM0_XATXIQIMBALANCE		0xc80
 #define	ROFDM0_XATXAFE				0xc84
-#define	ROFDM0_XBTXIQIMBAL			0xc88
+#define	ROFDM0_XBTXIQIMBALANCE		0xc88
 #define	ROFDM0_XBTXAFE				0xc8c
-#define	ROFDM0_XCTXIQIMBAL			0xc90
-#define	ROFDM0_XCTXAFE				0xc94
-#define	ROFDM0_XDTXIQIMBAL			0xc98
+#define	ROFDM0_XCTXIQIMBALANCE		0xc90
+#define	ROFDM0_XCTXAFE			0xc94
+#define	ROFDM0_XDTXIQIMBALANCE		0xc98
 #define	ROFDM0_XDTXAFE				0xc9c
 
 #define ROFDM0_RXIQEXTANTA			0xca0
@@ -1462,25 +1476,24 @@
 #define	ROFDM0_TXCOEFF5				0xcb4
 #define	ROFDM0_TXCOEFF6				0xcb8
 
-#define	ROFDM0_RXHPPARAMETER			0xce0
-#define	ROFDM0_TXPSEUDONOISEWGT			0xce4
+#define	ROFDM0_RXHPPARAMETER		0xce0
+#define	ROFDM0_TXPSEUDONOISEWGT		0xce4
 #define	ROFDM0_FRAMESYNC			0xcf0
 #define	ROFDM0_DFSREPORT			0xcf4
 
+#define	ROFDM1_LSTF					0xd00
+#define	ROFDM1_TRXPATHENABLE		0xd04
 
-#define	ROFDM1_LSTF				0xd00
-#define	ROFDM1_TRXPATHENABLE			0xd04
-
-#define	ROFDM1_CF0				0xd08
-#define	ROFDM1_CSI1				0xd10
-#define	ROFDM1_SBD				0xd14
-#define	ROFDM1_CSI2				0xd18
+#define	ROFDM1_CF0					0xd08
+#define	ROFDM1_CSI1					0xd10
+#define	ROFDM1_SBD					0xd14
+#define	ROFDM1_CSI2					0xd18
 #define	ROFDM1_CFOTRACKING			0xd2c
 #define	ROFDM1_TRXMESAURE1			0xd34
 #define	ROFDM1_INTFDET				0xd3c
-#define	ROFDM1_PSEUDONOISESTATEAB		0xd50
-#define	ROFDM1_PSEUDONOISESTATECD		0xd54
-#define	ROFDM1_RXPSEUDONOISEWGT			0xd58
+#define	ROFDM1_PSEUDONOISESTATEAB	0xd50
+#define	ROFDM1_PSEUDONOISESTATECD	0xd54
+#define	ROFDM1_RXPSEUDONOISEWGT		0xd58
 
 #define	ROFDM_PHYCOUNTER1			0xda0
 #define	ROFDM_PHYCOUNTER2			0xda4
@@ -1492,84 +1505,84 @@
 #define	ROFDM_LONGCFOCD				0xdb8
 #define	ROFDM_TAILCF0AB				0xdbc
 #define	ROFDM_TAILCF0CD				0xdc0
-#define	ROFDM_PWMEASURE1			0xdc4
-#define	ROFDM_PWMEASURE2			0xdc8
+#define	ROFDM_PWMEASURE1		0xdc4
+#define	ROFDM_PWMEASURE2		0xdc8
 #define	ROFDM_BWREPORT				0xdcc
 #define	ROFDM_AGCREPORT				0xdd0
-#define	ROFDM_RXSNR				0xdd4
+#define	ROFDM_RXSNR					0xdd4
 #define	ROFDM_RXEVMCSI				0xdd8
 #define	ROFDM_SIGREPORT				0xddc
 
 #define	RTXAGC_A_RATE18_06			0xe00
 #define	RTXAGC_A_RATE54_24			0xe04
 #define	RTXAGC_A_CCK1_MCS32			0xe08
-#define	RTXAGC_A_MCS03_MCS00			0xe10
-#define	RTXAGC_A_MCS07_MCS04			0xe14
-#define	RTXAGC_A_MCS11_MCS08			0xe18
-#define	RTXAGC_A_MCS15_MCS12			0xe1c
+#define	RTXAGC_A_MCS03_MCS00		0xe10
+#define	RTXAGC_A_MCS07_MCS04		0xe14
+#define	RTXAGC_A_MCS11_MCS08		0xe18
+#define	RTXAGC_A_MCS15_MCS12		0xe1c
 
 #define	RTXAGC_B_RATE18_06			0x830
 #define	RTXAGC_B_RATE54_24			0x834
-#define	RTXAGC_B_CCK1_55_MCS32			0x838
-#define	RTXAGC_B_MCS03_MCS00			0x83c
-#define	RTXAGC_B_MCS07_MCS04			0x848
-#define	RTXAGC_B_MCS11_MCS08			0x84c
-#define	RTXAGC_B_MCS15_MCS12			0x868
-#define	RTXAGC_B_CCK11_A_CCK2_11		0x86c
-
-#define	RFPGA0_IQK				0xe28
+#define	RTXAGC_B_CCK1_55_MCS32		0x838
+#define	RTXAGC_B_MCS03_MCS00		0x83c
+#define	RTXAGC_B_MCS07_MCS04		0x848
+#define	RTXAGC_B_MCS11_MCS08		0x84c
+#define	RTXAGC_B_MCS15_MCS12		0x868
+#define	RTXAGC_B_CCK11_A_CCK2_11	0x86c
+
+#define	RFPGA0_IQK					0xe28
 #define	RTX_IQK_TONE_A				0xe30
 #define	RRX_IQK_TONE_A				0xe34
-#define	RTX_IQK_PI_A				0xe38
-#define	RRX_IQK_PI_A				0xe3c
+#define	RTX_IQK_PI_A					0xe38
+#define	RRX_IQK_PI_A					0xe3c
 
-#define	RTX_IQK					0xe40
-#define	RRX_IQK					0xe44
-#define	RIQK_AGC_PTS				0xe48
-#define	RIQK_AGC_RSP				0xe4c
+#define	RTX_IQK							0xe40
+#define	RRX_IQK						0xe44
+#define	RIQK_AGC_PTS					0xe48
+#define	RIQK_AGC_RSP					0xe4c
 #define	RTX_IQK_TONE_B				0xe50
 #define	RRX_IQK_TONE_B				0xe54
-#define	RTX_IQK_PI_B				0xe58
-#define	RRX_IQK_PI_B				0xe5c
+#define	RTX_IQK_PI_B					0xe58
+#define	RRX_IQK_PI_B					0xe5c
 #define	RIQK_AGC_CONT				0xe60
 
-#define	RBLUE_TOOTH				0xe6c
-#define	RRX_WAIT_CCA				0xe70
-#define	RTX_CCK_RFON				0xe74
+#define	RBLUE_TOOTH					0xe6c
+#define	RRX_WAIT_CCA					0xe70
+#define	RTX_CCK_RFON					0xe74
 #define	RTX_CCK_BBON				0xe78
 #define	RTX_OFDM_RFON				0xe7c
 #define	RTX_OFDM_BBON				0xe80
-#define	RTX_TO_RX				0xe84
-#define	RTX_TO_TX				0xe88
-#define	RRX_CCK					0xe8c
+#define	RTX_TO_RX					0xe84
+#define	RTX_TO_TX					0xe88
+#define	RRX_CCK						0xe8c
 
-#define	RTX_POWER_BEFORE_IQK_A			0xe94
+#define	RTX_POWER_BEFORE_IQK_A		0xe94
 #define	RTX_POWER_AFTER_IQK_A			0xe9c
 
-#define	RRX_POWER_BEFORE_IQK_A			0xea0
+#define	RRX_POWER_BEFORE_IQK_A		0xea0
 #define	RRX_POWER_BEFORE_IQK_A_2		0xea4
 #define	RRX_POWER_AFTER_IQK_A			0xea8
-#define	RRX_POWER_AFTER_IQK_A_2			0xeac
+#define	RRX_POWER_AFTER_IQK_A_2		0xeac
 
-#define	RTX_POWER_BEFORE_IQK_B			0xeb4
+#define	RTX_POWER_BEFORE_IQK_B		0xeb4
 #define	RTX_POWER_AFTER_IQK_B			0xebc
 
-#define	RRX_POWER_BEFORE_IQK_B			0xec0
+#define	RRX_POWER_BEFORE_IQK_B		0xec0
 #define	RRX_POWER_BEFORE_IQK_B_2		0xec4
 #define	RRX_POWER_AFTER_IQK_B			0xec8
-#define	RRX_POWER_AFTER_IQK_B_2			0xecc
+#define	RRX_POWER_AFTER_IQK_B_2		0xecc
 
-#define	RRX_OFDM				0xed0
+#define	RRX_OFDM					0xed0
 #define	RRX_WAIT_RIFS				0xed4
-#define	RRX_TO_RX				0xed8
-#define	RSTANDBY				0xedc
-#define	RSLEEP					0xee0
+#define	RRX_TO_RX					0xed8
+#define	RSTANDBY						0xedc
+#define	RSLEEP						0xee0
 #define	RPMPD_ANAEN				0xeec
 
 #define	RZEBRA1_HSSIENABLE			0x0
 #define	RZEBRA1_TRXENABLE1			0x1
 #define	RZEBRA1_TRXENABLE2			0x2
-#define	RZEBRA1_AGC				0x4
+#define	RZEBRA1_AGC					0x4
 #define	RZEBRA1_CHARGEPUMP			0x5
 #define	RZEBRA1_CHANNEL				0x7
 
@@ -1578,666 +1591,681 @@
 #define	RZEBRA1_RXLPF				0xb
 #define	RZEBRA1_RXHPFCORNER			0xc
 
-#define	RGLOBALCTRL				0
+#define	RGLOBALCTRL					0
 #define	RRTL8256_TXLPF				19
 #define	RRTL8256_RXLPF				11
 #define	RRTL8258_TXLPF				0x11
 #define	RRTL8258_RXLPF				0x13
 #define	RRTL8258_RSSILPF			0xa
 
-#define	RF_AC					0x00
+#define	RF_AC						0x00
 
-#define	RF_IQADJ_G1				0x01
-#define	RF_IQADJ_G2				0x02
-#define	RF_POW_TRSW				0x05
+#define	RF_IQADJ_G1					0x01
+#define	RF_IQADJ_G2					0x02
+#define	RF_POW_TRSW					0x05
 
-#define	RF_GAIN_RX				0x06
-#define	RF_GAIN_TX				0x07
+#define	RF_GAIN_RX					0x06
+#define	RF_GAIN_TX					0x07
 
-#define	RF_TXM_IDAC				0x08
-#define	RF_BS_IQGEN				0x0F
+#define	RF_TXM_IDAC					0x08
+#define	RF_BS_IQGEN					0x0F
 
-#define	RF_MODE1				0x10
-#define	RF_MODE2				0x11
+#define	RF_MODE1					0x10
+#define	RF_MODE2					0x11
 
 #define	RF_RX_AGC_HP				0x12
-#define	RF_TX_AGC				0x13
-#define	RF_BIAS					0x14
-#define	RF_IPA					0x15
+#define	RF_TX_AGC					0x13
+#define	RF_BIAS						0x14
+#define	RF_IPA						0x15
 #define	RF_POW_ABILITY				0x17
-#define	RF_MODE_AG				0x18
-#define	RRFCHANNEL				0x18
-#define	RF_CHNLBW				0x18
-#define	RF_TOP					0x19
-
-#define	RF_RX_G1				0x1A
-#define	RF_RX_G2				0x1B
-
-#define	RF_RX_BB2				0x1C
-#define	RF_RX_BB1				0x1D
-
-#define	RF_RCK1					0x1E
-#define	RF_RCK2					0x1F
-
-#define	RF_TX_G1				0x20
-#define	RF_TX_G2				0x21
-#define	RF_TX_G3				0x22
-
-#define	RF_TX_BB1				0x23
-#define	RF_T_METER				0x42
-
-#define	RF_SYN_G1				0x25
-#define	RF_SYN_G2				0x26
-#define	RF_SYN_G3				0x27
-#define	RF_SYN_G4				0x28
-#define	RF_SYN_G5				0x29
-#define	RF_SYN_G6				0x2A
-#define	RF_SYN_G7				0x2B
-#define	RF_SYN_G8				0x2C
-
-#define	RF_RCK_OS				0x30
-#define	RF_TXPA_G1				0x31
-#define	RF_TXPA_G2				0x32
-#define	RF_TXPA_G3				0x33
-
-#define	RF_TX_BIAS_A				0x35
-#define	RF_TX_BIAS_D				0x36
-#define	RF_LOBF_9				0x38
-#define	RF_RXRF_A3				0x3C
-#define	RF_TRSW					0x3F
-
-#define	RF_TXRF_A2				0x41
-#define	RF_TXPA_G4				0x46
-#define	RF_TXPA_A4				0x4B
-
-#define	RF_WE_LUT				0xEF
-
-#define	BBBRESETB				0x100
+#define	RF_MODE_AG					0x18
+#define	RRFCHANNEL					0x18
+#define	RF_CHNLBW					0x18
+#define	RF_TOP						0x19
+
+#define	RF_RX_G1					0x1A
+#define	RF_RX_G2					0x1B
+
+#define	RF_RX_BB2					0x1C
+#define	RF_RX_BB1					0x1D
+
+#define	RF_RCK1						0x1E
+#define	RF_RCK2						0x1F
+
+#define	RF_TX_G1					0x20
+#define	RF_TX_G2					0x21
+#define	RF_TX_G3					0x22
+
+#define	RF_TX_BB1					0x23
+#define	RF_T_METER					0x42
+
+#define	RF_SYN_G1					0x25
+#define	RF_SYN_G2					0x26
+#define	RF_SYN_G3					0x27
+#define	RF_SYN_G4					0x28
+#define	RF_SYN_G5					0x29
+#define	RF_SYN_G6					0x2A
+#define	RF_SYN_G7					0x2B
+#define	RF_SYN_G8					0x2C
+
+#define	RF_RCK_OS					0x30
+#define	RF_TXPA_G1					0x31
+#define	RF_TXPA_G2					0x32
+#define	RF_TXPA_G3					0x33
+
+#define	RF_TX_BIAS_A					0x35
+#define	RF_TX_BIAS_D					0x36
+#define	RF_LOBF_9					0x38
+#define	RF_RXRF_A3					0x3C
+#define	RF_TRSW						0x3F
+
+#define	RF_TXRF_A2					0x41
+#define	RF_TXPA_G4					0x46
+#define	RF_TXPA_A4					0x4B
+
+#define	RF_WE_LUT					0xEF
+
+#define	BBBRESETB					0x100
 #define	BGLOBALRESETB				0x200
 #define	BOFDMTXSTART				0x4
-#define	BCCKTXSTART				0x8
-#define	BCRC32DEBUG				0x100
+#define	BCCKTXSTART					0x8
+#define	BCRC32DEBUG					0x100
 #define	BPMACLOOPBACK				0x10
-#define	BTXLSIG					0xffffff
-#define	BOFDMTXRATE				0xf
+#define	BTXLSIG						0xffffff
+#define	BOFDMTXRATE					0xf
 #define	BOFDMTXRESERVED				0x10
 #define	BOFDMTXLENGTH				0x1ffe0
 #define	BOFDMTXPARITY				0x20000
-#define	BTXHTSIG1				0xffffff
+#define	BTXHTSIG1					0xffffff
 #define	BTXHTMCSRATE				0x7f
-#define	BTXHTBW					0x80
-#define	BTXHTLENGTH				0xffff00
-#define	BTXHTSIG2				0xffffff
+#define	BTXHTBW						0x80
+#define	BTXHTLENGTH					0xffff00
+#define	BTXHTSIG2					0xffffff
 #define	BTXHTSMOOTHING				0x1
 #define	BTXHTSOUNDING				0x2
 #define	BTXHTRESERVED				0x4
 #define	BTXHTAGGREATION				0x8
-#define	BTXHTSTBC				0x30
+#define	BTXHTSTBC					0x30
 #define	BTXHTADVANCECODING			0x40
 #define	BTXHTSHORTGI				0x80
 #define	BTXHTNUMBERHT_LTF			0x300
-#define	BTXHTCRC8				0x3fc00
+#define	BTXHTCRC8					0x3fc00
 #define	BCOUNTERRESET				0x10000
 #define	BNUMOFOFDMTX				0xffff
-#define	BNUMOFCCKTX				0xffff0000
+#define	BNUMOFCCKTX					0xffff0000
 #define	BTXIDLEINTERVAL				0xffff
 #define	BOFDMSERVICE				0xffff0000
 #define	BTXMACHEADER				0xffffffff
-#define	BTXDATAINIT				0xff
-#define	BTXHTMODE				0x100
-#define	BTXDATATYPE				0x30000
+#define	BTXDATAINIT					0xff
+#define	BTXHTMODE					0x100
+#define	BTXDATATYPE					0x30000
 #define	BTXRANDOMSEED				0xffffffff
 #define	BCCKTXPREAMBLE				0x1
-#define	BCCKTXSFD				0xffff0000
-#define	BCCKTXSIG				0xff
+#define	BCCKTXSFD					0xffff0000
+#define	BCCKTXSIG					0xff
 #define	BCCKTXSERVICE				0xff00
 #define	BCCKLENGTHEXT				0x8000
 #define	BCCKTXLENGHT				0xffff0000
-#define	BCCKTXCRC16				0xffff
+#define	BCCKTXCRC16					0xffff
 #define	BCCKTXSTATUS				0x1
 #define	BOFDMTXSTATUS				0x2
 #define IS_BB_REG_OFFSET_92S(_offset)	\
 	((_offset >= 0x800) && (_offset <= 0xfff))
 
-#define	BRFMOD					0x1
-#define	BJAPANMODE				0x2
-#define	BCCKTXSC				0x30
-#define	BCCKEN					0x1000000
-#define	BOFDMEN					0x2000000
-
-#define	BOFDMRXADCPHASE				0x10000
-#define	BOFDMTXDACPHASE				0x40000
-#define	BXATXAGC				0x3f
-
-#define	BXBTXAGC				0xf00
-#define	BXCTXAGC				0xf000
-#define	BXDTXAGC				0xf0000
-
-#define	BPASTART				0xf0000000
-#define	BTRSTART				0x00f00000
-#define	BRFSTART				0x0000f000
-#define	BBBSTART				0x000000f0
-#define	BBBCCKSTART				0x0000000f
-#define	BPAEND					0xf
-#define	BTREND					0x0f000000
-#define	BRFEND					0x000f0000
-#define	BCCAMASK				0x000000f0
-#define	BR2RCCAMASK				0x00000f00
-#define	BHSSI_R2TDELAY				0xf8000000
-#define	BHSSI_T2RDELAY				0xf80000
-#define	BCONTXHSSI				0x400
-#define	BIGFROMCCK				0x200
-#define	BAGCADDRESS				0x3f
-#define	BRXHPTX					0x7000
-#define	BRXHP2RX				0x38000
-#define	BRXHPCCKINI				0xc0000
-#define	BAGCTXCODE				0xc00000
-#define	BAGCRXCODE				0x300000
-
-#define	B3WIREDATALENGTH			0x800
-#define	B3WIREADDREAALENGTH			0x400
-
-#define	B3WIRERFPOWERDOWN			0x1
-#define	B5GPAPEPOLARITY				0x40000000
-#define	B2GPAPEPOLARITY				0x80000000
-#define	BRFSW_TXDEFAULTANT			0x3
-#define	BRFSW_TXOPTIONANT			0x30
-#define	BRFSW_RXDEFAULTANT			0x300
-#define	BRFSW_RXOPTIONANT			0x3000
-#define	BRFSI_3WIREDATA				0x1
-#define	BRFSI_3WIRECLOCK			0x2
-#define	BRFSI_3WIRELOAD				0x4
-#define	BRFSI_3WIRERW				0x8
-#define	BRFSI_3WIRE				0xf
-
-#define	BRFSI_RFENV				0x10
-
-#define	BRFSI_TRSW				0x20
-#define	BRFSI_TRSWB				0x40
-#define	BRFSI_ANTSW				0x100
-#define	BRFSI_ANTSWB				0x200
-#define	BRFSI_PAPE				0x400
-#define	BRFSI_PAPE5G				0x800
-#define	BBANDSELECT				0x1
-#define	BHTSIG2_GI				0x80
-#define	BHTSIG2_SMOOTHING			0x01
-#define	BHTSIG2_SOUNDING			0x02
-#define	BHTSIG2_AGGREATON			0x08
-#define	BHTSIG2_STBC				0x30
-#define	BHTSIG2_ADVCODING			0x40
-#define	BHTSIG2_NUMOFHTLTF			0x300
-#define	BHTSIG2_CRC8				0x3fc
-#define	BHTSIG1_MCS				0x7f
-#define	BHTSIG1_BANDWIDTH			0x80
-#define	BHTSIG1_HTLENGTH			0xffff
-#define	BLSIG_RATE				0xf
-#define	BLSIG_RESERVED				0x10
-#define	BLSIG_LENGTH				0x1fffe
-#define	BLSIG_PARITY				0x20
-#define	BCCKRXPHASE				0x4
-
-#define	BLSSIREADADDRESS			0x7f800000
-#define	BLSSIREADEDGE				0x80000000
-
-#define	BLSSIREADBACKDATA			0xfffff
-
-#define	BLSSIREADOKFLAG				0x1000
-#define	BCCKSAMPLERATE				0x8
-#define	BREGULATOR0STANDBY			0x1
-#define	BREGULATORPLLSTANDBY			0x2
-#define	BREGULATOR1STANDBY			0x4
-#define	BPLLPOWERUP				0x8
-#define	BDPLLPOWERUP				0x10
-#define	BDA10POWERUP				0x20
-#define	BAD7POWERUP				0x200
-#define	BDA6POWERUP				0x2000
-#define	BXTALPOWERUP				0x4000
-#define	B40MDCLKPOWERUP				0x8000
-#define	BDA6DEBUGMODE				0x20000
-#define	BDA6SWING				0x380000
-
-#define	BADCLKPHASE				0x4000000
-#define	B80MCLKDELAY				0x18000000
-#define	BAFEWATCHDOGENABLE			0x20000000
-
-#define	BXTALCAP01				0xc0000000
-#define	BXTALCAP23				0x3
-#define	BXTALCAP92X				0x0f000000
-#define BXTALCAP				0x0f000000
-
-#define	BINTDIFCLKENABLE			0x400
-#define	BEXTSIGCLKENABLE			0x800
-#define	BBANDGAP_MBIAS_POWERUP			0x10000
-#define	BAD11SH_GAIN				0xc0000
-#define	BAD11NPUT_RANGE				0x700000
-#define	BAD110P_CURRENT				0x3800000
-#define	BLPATH_LOOPBACK				0x4000000
-#define	BQPATH_LOOPBACK				0x8000000
-#define	BAFE_LOOPBACK				0x10000000
-#define	BDA10_SWING				0x7e0
-#define	BDA10_REVERSE				0x800
-#define	BDA_CLK_SOURCE				0x1000
-#define	BDA7INPUT_RANGE				0x6000
-#define	BDA7_GAIN				0x38000
-#define	BDA7OUTPUT_CM_MODE			0x40000
-#define	BDA7INPUT_CM_MODE			0x380000
-#define	BDA7CURRENT				0xc00000
-#define	BREGULATOR_ADJUST			0x7000000
-#define	BAD11POWERUP_ATTX			0x1
-#define	BDA10PS_ATTX				0x10
-#define	BAD11POWERUP_ATRX			0x100
-#define	BDA10PS_ATRX				0x1000
-#define	BCCKRX_AGC_FORMAT			0x200
-#define	BPSDFFT_SAMPLE_POINT			0xc000
-#define	BPSD_AVERAGE_NUM			0x3000
-#define	BIQPATH_CONTROL				0xc00
-#define	BPSD_FREQ				0x3ff
-#define	BPSD_ANTENNA_PATH			0x30
-#define	BPSD_IQ_SWITCH				0x40
-#define	BPSD_RX_TRIGGER				0x400000
-#define	BPSD_TX_TRIGGERCW			0x80000000
-#define	BPSD_SINE_TONE_SCALE			0x7f000000
-#define	BPSD_REPORT				0xffff
-
-#define	BOFDM_TXSC				0x30000000
-#define	BCCK_TXON				0x1
-#define	BOFDM_TXON				0x2
-#define	BDEBUG_PAGE				0xfff
-#define	BDEBUG_ITEM				0xff
-#define	BANTL					0x10
-#define	BANT_NONHT				0x100
-#define	BANT_HT1				0x1000
-#define	BANT_HT2				0x10000
-#define	BANT_HT1S1				0x100000
-#define	BANT_NONHTS1				0x1000000
-
-#define	BCCK_BBMODE				0x3
-#define	BCCK_TXPOWERSAVING			0x80
-#define	BCCK_RXPOWERSAVING			0x40
-
-#define	BCCK_SIDEBAND				0x10
-
-#define	BCCK_SCRAMBLE				0x8
-#define	BCCK_ANTDIVERSITY			0x8000
-#define	BCCK_CARRIER_RECOVERY			0x4000
-#define	BCCK_TXRATE				0x3000
-#define	BCCK_DCCANCEL				0x0800
-#define	BCCK_ISICANCEL				0x0400
-#define	BCCK_MATCH_FILTER			0x0200
-#define	BCCK_EQUALIZER				0x0100
-#define	BCCK_PREAMBLE_DETECT			0x800000
-#define	BCCK_FAST_FALSECCA			0x400000
-#define	BCCK_CH_ESTSTART			0x300000
-#define	BCCK_CCA_COUNT				0x080000
-#define	BCCK_CS_LIM				0x070000
-#define	BCCK_BIST_MODE				0x80000000
-#define	BCCK_CCAMASK				0x40000000
-#define	BCCK_TX_DAC_PHASE			0x4
-#define	BCCK_RX_ADC_PHASE			0x20000000
-#define	BCCKR_CP_MODE				0x0100
-#define	BCCK_TXDC_OFFSET			0xf0
-#define	BCCK_RXDC_OFFSET			0xf
-#define	BCCK_CCA_MODE				0xc000
-#define	BCCK_FALSECS_LIM			0x3f00
-#define	BCCK_CS_RATIO				0xc00000
-#define	BCCK_CORGBIT_SEL			0x300000
-#define	BCCK_PD_LIM				0x0f0000
-#define	BCCK_NEWCCA				0x80000000
-#define	BCCK_RXHP_OF_IG				0x8000
-#define	BCCK_RXIG				0x7f00
-#define	BCCK_LNA_POLARITY			0x800000
-#define	BCCK_RX1ST_BAIN				0x7f0000
-#define	BCCK_RF_EXTEND				0x20000000
-#define	BCCK_RXAGC_SATLEVEL			0x1f000000
-#define	BCCK_RXAGC_SATCOUNT			0xe0
-#define	BCCKRXRFSETTLE				0x1f
-#define	BCCK_FIXED_RXAGC			0x8000
-#define	BCCK_ANTENNA_POLARITY			0x2000
-#define	BCCK_TXFILTER_TYPE			0x0c00
-#define	BCCK_RXAGC_REPORTTYPE			0x0300
-#define	BCCK_RXDAGC_EN				0x80000000
-#define	BCCK_RXDAGC_PERIOD			0x20000000
-#define	BCCK_RXDAGC_SATLEVEL			0x1f000000
-#define	BCCK_TIMING_RECOVERY			0x800000
-#define	BCCK_TXC0				0x3f0000
-#define	BCCK_TXC1				0x3f000000
-#define	BCCK_TXC2				0x3f
-#define	BCCK_TXC3				0x3f00
-#define	BCCK_TXC4				0x3f0000
-#define	BCCK_TXC5				0x3f000000
-#define	BCCK_TXC6				0x3f
-#define	BCCK_TXC7				0x3f00
-#define	BCCK_DEBUGPORT				0xff0000
-#define	BCCK_DAC_DEBUG				0x0f000000
-#define	BCCK_FALSEALARM_ENABLE			0x8000
-#define	BCCK_FALSEALARM_READ			0x4000
-#define	BCCK_TRSSI				0x7f
-#define	BCCK_RXAGC_REPORT			0xfe
-#define	BCCK_RXREPORT_ANTSEL			0x80000000
-#define	BCCK_RXREPORT_MFOFF			0x40000000
-#define	BCCK_RXREPORT_SQLOSS			0x20000000
-#define	BCCK_RXREPORT_PKTLOSS			0x10000000
-#define	BCCK_RXREPORT_LOCKEDBIT			0x08000000
-#define	BCCK_RXREPORT_RATEERROR			0x04000000
-#define	BCCK_RXREPORT_RXRATE			0x03000000
-#define	BCCK_RXFA_COUNTER_LOWER			0xff
-#define	BCCK_RXFA_COUNTER_UPPER			0xff000000
-#define	BCCK_RXHPAGC_START			0xe000
-#define	BCCK_RXHPAGC_FINAL			0x1c00
-#define	BCCK_RXFALSEALARM_ENABLE		0x8000
-#define	BCCK_FACOUNTER_FREEZE			0x4000
-#define	BCCK_TXPATH_SEL				0x10000000
-#define	BCCK_DEFAULT_RXPATH			0xc000000
-#define	BCCK_OPTION_RXPATH			0x3000000
-
-#define	BNUM_OFSTF				0x3
-#define	BSHIFT_L				0xc0
-#define	BGI_TH					0xc
-#define	BRXPATH_A				0x1
-#define	BRXPATH_B				0x2
-#define	BRXPATH_C				0x4
-#define	BRXPATH_D				0x8
-#define	BTXPATH_A				0x1
-#define	BTXPATH_B				0x2
-#define	BTXPATH_C				0x4
-#define	BTXPATH_D				0x8
-#define	BTRSSI_FREQ				0x200
-#define	BADC_BACKOFF				0x3000
-#define	BDFIR_BACKOFF				0xc000
-#define	BTRSSI_LATCH_PHASE			0x10000
-#define	BRX_LDC_OFFSET				0xff
-#define	BRX_QDC_OFFSET				0xff00
-#define	BRX_DFIR_MODE				0x1800000
-#define	BRX_DCNF_TYPE				0xe000000
-#define	BRXIQIMB_A				0x3ff
-#define	BRXIQIMB_B				0xfc00
-#define	BRXIQIMB_C				0x3f0000
-#define	BRXIQIMB_D				0xffc00000
-#define	BDC_DC_NOTCH				0x60000
-#define	BRXNB_NOTCH				0x1f000000
-#define	BPD_TH					0xf
-#define	BPD_TH_OPT2				0xc000
-#define	BPWED_TH				0x700
-#define	BIFMF_WIN_L				0x800
-#define	BPD_OPTION				0x1000
-#define	BMF_WIN_L				0xe000
-#define	BBW_SEARCH_L				0x30000
-#define	BWIN_ENH_L				0xc0000
-#define	BBW_TH					0x700000
-#define	BED_TH2					0x3800000
-#define	BBW_OPTION				0x4000000
-#define	BRADIO_TH				0x18000000
-#define	BWINDOW_L				0xe0000000
-#define	BSBD_OPTION				0x1
-#define	BFRAME_TH				0x1c
-#define	BFS_OPTION				0x60
-#define	BDC_SLOPE_CHECK				0x80
-#define	BFGUARD_COUNTER_DC_L			0xe00
-#define	BFRAME_WEIGHT_SHORT			0x7000
-#define	BSUB_TUNE				0xe00000
-#define	BFRAME_DC_LENGTH			0xe000000
-#define	BSBD_START_OFFSET			0x30000000
-#define	BFRAME_TH_2				0x7
-#define	BFRAME_GI2_TH				0x38
-#define	BGI2_SYNC_EN				0x40
-#define	BSARCH_SHORT_EARLY			0x300
-#define	BSARCH_SHORT_LATE			0xc00
-#define	BSARCH_GI2_LATE				0x70000
-#define	BCFOANTSUM				0x1
-#define	BCFOACC					0x2
-#define	BCFOSTARTOFFSET				0xc
-#define	BCFOLOOPBACK				0x70
-#define	BCFOSUMWEIGHT				0x80
-#define	BDAGCENABLE				0x10000
-#define	BTXIQIMB_A				0x3ff
-#define	BTXIQIMB_B				0xfc00
-#define	BTXIQIMB_C				0x3f0000
-#define	BTXIQIMB_D				0xffc00000
-#define	BTXIDCOFFSET				0xff
-#define	BTXIQDCOFFSET				0xff00
-#define	BTXDFIRMODE				0x10000
-#define	BTXPESUDO_NOISEON			0x4000000
-#define	BTXPESUDO_NOISE_A			0xff
-#define	BTXPESUDO_NOISE_B			0xff00
-#define	BTXPESUDO_NOISE_C			0xff0000
-#define	BTXPESUDO_NOISE_D			0xff000000
-#define	BCCA_DROPOPTION				0x20000
-#define	BCCA_DROPTHRES				0xfff00000
-#define	BEDCCA_H				0xf
-#define	BEDCCA_L				0xf0
-#define	BLAMBDA_ED				0x300
-#define	BRX_INITIALGAIN				0x7f
-#define	BRX_ANTDIV_EN				0x80
-#define	BRX_AGC_ADDRESS_FOR_LNA			0x7f00
-#define	BRX_HIGHPOWER_FLOW			0x8000
-#define	BRX_AGC_FREEZE_THRES			0xc0000
-#define	BRX_FREEZESTEP_AGC1			0x300000
-#define	BRX_FREEZESTEP_AGC2			0xc00000
-#define	BRX_FREEZESTEP_AGC3			0x3000000
-#define	BRX_FREEZESTEP_AGC0			0xc000000
-#define	BRXRSSI_CMP_EN				0x10000000
-#define	BRXQUICK_AGCEN				0x20000000
-#define	BRXAGC_FREEZE_THRES_MODE		0x40000000
-#define	BRX_OVERFLOW_CHECKTYPE			0x80000000
-#define	BRX_AGCSHIFT				0x7f
-#define	BTRSW_TRI_ONLY				0x80
-#define	BPOWER_THRES				0x300
-#define	BRXAGC_EN				0x1
-#define	BRXAGC_TOGETHER_EN			0x2
-#define	BRXAGC_MIN				0x4
-#define	BRXHP_INI				0x7
-#define	BRXHP_TRLNA				0x70
-#define	BRXHP_RSSI				0x700
-#define	BRXHP_BBP1				0x7000
-#define	BRXHP_BBP2				0x70000
-#define	BRXHP_BBP3				0x700000
-#define	BRSSI_H					0x7f0000
-#define	BRSSI_GEN				0x7f000000
-#define	BRXSETTLE_TRSW				0x7
-#define	BRXSETTLE_LNA				0x38
-#define	BRXSETTLE_RSSI				0x1c0
-#define	BRXSETTLE_BBP				0xe00
-#define	BRXSETTLE_RXHP				0x7000
-#define	BRXSETTLE_ANTSW_RSSI			0x38000
-#define	BRXSETTLE_ANTSW				0xc0000
-#define	BRXPROCESS_TIME_DAGC			0x300000
-#define	BRXSETTLE_HSSI				0x400000
-#define	BRXPROCESS_TIME_BBPPW			0x800000
-#define	BRXANTENNA_POWER_SHIFT			0x3000000
-#define	BRSSI_TABLE_SELECT			0xc000000
-#define	BRXHP_FINAL				0x7000000
-#define	BRXHPSETTLE_BBP				0x7
-#define	BRXHTSETTLE_HSSI			0x8
-#define	BRXHTSETTLE_RXHP			0x70
-#define	BRXHTSETTLE_BBPPW			0x80
-#define	BRXHTSETTLE_IDLE			0x300
-#define	BRXHTSETTLE_RESERVED			0x1c00
-#define	BRXHT_RXHP_EN				0x8000
-#define	BRXAGC_FREEZE_THRES			0x30000
-#define	BRXAGC_TOGETHEREN			0x40000
-#define	BRXHTAGC_MIN				0x80000
-#define	BRXHTAGC_EN				0x100000
-#define	BRXHTDAGC_EN				0x200000
-#define	BRXHT_RXHP_BBP				0x1c00000
-#define	BRXHT_RXHP_FINAL			0xe0000000
-#define	BRXPW_RADIO_TH				0x3
-#define	BRXPW_RADIO_EN				0x4
-#define	BRXMF_HOLD				0x3800
-#define	BRXPD_DELAY_TH1				0x38
-#define	BRXPD_DELAY_TH2				0x1c0
-#define	BRXPD_DC_COUNT_MAX			0x600
-#define	BRXPD_DELAY_TH				0x8000
-#define	BRXPROCESS_DELAY			0xf0000
-#define	BRXSEARCHRANGE_GI2_EARLY		0x700000
-#define	BRXFRAME_FUARD_COUNTER_L		0x3800000
-#define	BRXSGI_GUARD_L				0xc000000
-#define	BRXSGI_SEARCH_L				0x30000000
-#define	BRXSGI_TH				0xc0000000
-#define	BDFSCNT0				0xff
-#define	BDFSCNT1				0xff00
-#define	BDFSFLAG				0xf0000
-#define	BMF_WEIGHT_SUM				0x300000
-#define	BMINIDX_TH				0x7f000000
-#define	BDAFORMAT				0x40000
-#define	BTXCH_EMU_ENABLE			0x01000000
-#define	BTRSW_ISOLATION_A			0x7f
-#define	BTRSW_ISOLATION_B			0x7f00
-#define	BTRSW_ISOLATION_C			0x7f0000
-#define	BTRSW_ISOLATION_D			0x7f000000
-#define	BEXT_LNA_GAIN				0x7c00
-
-#define	BSTBC_EN				0x4
-#define	BANTENNA_MAPPING			0x10
-#define	BNSS					0x20
-#define	BCFO_ANTSUM_ID				0x200
-#define	BPHY_COUNTER_RESET			0x8000000
-#define	BCFO_REPORT_GET				0x4000000
-#define	BOFDM_CONTINUE_TX			0x10000000
-#define	BOFDM_SINGLE_CARRIER			0x20000000
-#define	BOFDM_SINGLE_TONE			0x40000000
-#define	BHT_DETECT				0x100
-#define	BCFOEN					0x10000
-#define	BCFOVALUE				0xfff00000
-#define	BSIGTONE_RE				0x3f
-#define	BSIGTONE_IM				0x7f00
-#define	BCOUNTER_CCA				0xffff
-#define	BCOUNTER_PARITYFAIL			0xffff0000
-#define	BCOUNTER_RATEILLEGAL			0xffff
-#define	BCOUNTER_CRC8FAIL			0xffff0000
-#define	BCOUNTER_MCSNOSUPPORT			0xffff
-#define	BCOUNTER_FASTSYNC			0xffff
-#define	BSHORTCFO				0xfff
-#define	BSHORTCFOT_LENGTH			12
-#define	BSHORTCFOF_LENGTH			11
-#define	BLONGCFO				0x7ff
-#define	BLONGCFOT_LENGTH			11
-#define	BLONGCFOF_LENGTH			11
-#define	BTAILCFO				0x1fff
-#define	BTAILCFOT_LENGTH			13
-#define	BTAILCFOF_LENGTH			12
-#define	BNOISE_EN_PWDB				0xffff
-#define	BCC_POWER_DB				0xffff0000
-#define	BMOISE_PWDB				0xffff
-#define	BPOWERMEAST_LENGTH			10
-#define	BPOWERMEASF_LENGTH			3
-#define	BRX_HT_BW				0x1
-#define	BRXSC					0x6
-#define	BRX_HT					0x8
-#define	BNB_INTF_DET_ON				0x1
-#define	BINTF_WIN_LEN_CFG			0x30
-#define	BNB_INTF_TH_CFG				0x1c0
-#define	BRFGAIN					0x3f
-#define	BTABLESEL				0x40
-#define	BTRSW					0x80
-#define	BRXSNR_A				0xff
-#define	BRXSNR_B				0xff00
-#define	BRXSNR_C				0xff0000
-#define	BRXSNR_D				0xff000000
-#define	BSNR_EVMT_LENGTH			8
-#define	BSNR_EVMF_LENGTH			1
-#define	BCSI1ST					0xff
-#define	BCSI2ND					0xff00
-#define	BRXEVM1ST				0xff0000
-#define	BRXEVM2ND				0xff000000
-#define	BSIGEVM					0xff
-#define	BPWDB					0xff00
-#define	BSGIEN					0x10000
-
-#define	BSFACTOR_QMA1				0xf
-#define	BSFACTOR_QMA2				0xf0
-#define	BSFACTOR_QMA3				0xf00
-#define	BSFACTOR_QMA4				0xf000
-#define	BSFACTOR_QMA5				0xf0000
-#define	BSFACTOR_QMA6				0xf0000
-#define	BSFACTOR_QMA7				0xf00000
-#define	BSFACTOR_QMA8				0xf000000
-#define	BSFACTOR_QMA9				0xf0000000
-#define	BCSI_SCHEME				0x100000
-
-#define	BNOISE_LVL_TOP_SET			0x3
-#define	BCHSMOOTH				0x4
-#define	BCHSMOOTH_CFG1				0x38
-#define	BCHSMOOTH_CFG2				0x1c0
-#define	BCHSMOOTH_CFG3				0xe00
-#define	BCHSMOOTH_CFG4				0x7000
-#define	BMRCMODE				0x800000
-#define	BTHEVMCFG				0x7000000
-
-#define	BLOOP_FIT_TYPE				0x1
-#define	BUPD_CFO				0x40
-#define	BUPD_CFO_OFFDATA			0x80
-#define	BADV_UPD_CFO				0x100
-#define	BADV_TIME_CTRL				0x800
-#define	BUPD_CLKO				0x1000
-#define	BFC					0x6000
-#define	BTRACKING_MODE				0x8000
-#define	BPHCMP_ENABLE				0x10000
-#define	BUPD_CLKO_LTF				0x20000
-#define	BCOM_CH_CFO				0x40000
-#define	BCSI_ESTI_MODE				0x80000
-#define	BADV_UPD_EQZ				0x100000
-#define	BUCHCFG					0x7000000
-#define	BUPDEQZ					0x8000000
-
-#define	BRX_PESUDO_NOISE_ON			0x20000000
-#define	BRX_PESUDO_NOISE_A			0xff
-#define	BRX_PESUDO_NOISE_B			0xff00
-#define	BRX_PESUDO_NOISE_C			0xff0000
-#define	BRX_PESUDO_NOISE_D			0xff000000
-#define	BRX_PESUDO_NOISESTATE_A			0xffff
-#define	BRX_PESUDO_NOISESTATE_B			0xffff0000
-#define	BRX_PESUDO_NOISESTATE_C			0xffff
-#define	BRX_PESUDO_NOISESTATE_D			0xffff0000
-
-#define	BZEBRA1_HSSIENABLE			0x8
-#define	BZEBRA1_TRXCONTROL			0xc00
-#define	BZEBRA1_TRXGAINSETTING			0x07f
-#define	BZEBRA1_RXCOUNTER			0xc00
-#define	BZEBRA1_TXCHANGEPUMP			0x38
-#define	BZEBRA1_RXCHANGEPUMP			0x7
-#define	BZEBRA1_CHANNEL_NUM			0xf80
-#define	BZEBRA1_TXLPFBW				0x400
-#define	BZEBRA1_RXLPFBW				0x600
-
-#define	BRTL8256REG_MODE_CTRL1			0x100
-#define	BRTL8256REG_MODE_CTRL0			0x40
-#define	BRTL8256REG_TXLPFBW			0x18
-#define	BRTL8256REG_RXLPFBW			0x600
-
-#define	BRTL8258_TXLPFBW			0xc
-#define	BRTL8258_RXLPFBW			0xc00
-#define	BRTL8258_RSSILPFBW			0xc0
-
-#define	BBYTE0					0x1
-#define	BBYTE1					0x2
-#define	BBYTE2					0x4
-#define	BBYTE3					0x8
-#define	BWORD0					0x3
-#define	BWORD1					0xc
-#define	BWORD					0xf
-
-#define	BENABLE					0x1
-#define	BDISABLE				0x0
-
-#define	LEFT_ANTENNA				0x0
-#define	RIGHT_ANTENNA				0x1
-
-#define	TCHECK_TXSTATUS				500
-#define	TUPDATE_RXCOUNTER			100
-
-#define	REG_UN_USED_REGISTER			0x01bf
+#define	BRFMOD						0x1
+#define	BJAPANMODE					0x2
+#define	BCCKTXSC					0x30
+#define	BCCKEN						0x1000000
+#define	BOFDMEN						0x2000000
+
+#define	BOFDMRXADCPHASE			0x10000
+#define	BOFDMTXDACPHASE			0x40000
+#define	BXATXAGC			0x3f
+
+#define	BXBTXAGC			0xf00
+#define	BXCTXAGC			0xf000
+#define	BXDTXAGC			0xf0000
+
+#define	BPASTART			0xf0000000
+#define	BTRSTART			0x00f00000
+#define	BRFSTART			0x0000f000
+#define	BBBSTART			0x000000f0
+#define	BBBCCKSTART			0x0000000f
+#define	BPAEND				0xf
+#define	BTREND				0x0f000000
+#define	BRFEND				0x000f0000
+#define	BCCAMASK			0x000000f0
+#define	BR2RCCAMASK			0x00000f00
+#define	BHSSI_R2TDELAY			0xf8000000
+#define	BHSSI_T2RDELAY			0xf80000
+#define	BCONTXHSSI			0x400
+#define	BIGFROMCCK			0x200
+#define	BAGCADDRESS			0x3f
+#define	BRXHPTX				0x7000
+#define	BRXHP2RX			0x38000
+#define	BRXHPCCKINI			0xc0000
+#define	BAGCTXCODE			0xc00000
+#define	BAGCRXCODE			0x300000
+
+#define	B3WIREDATALENGTH		0x800
+#define	B3WIREADDREAALENGTH		0x400
+
+#define	B3WIRERFPOWERDOWN		0x1
+#define	B5GPAPEPOLARITY			0x40000000
+#define	B2GPAPEPOLARITY			0x80000000
+#define	BRFSW_TXDEFAULTANT		0x3
+#define	BRFSW_TXOPTIONANT		0x30
+#define	BRFSW_RXDEFAULTANT		0x300
+#define	BRFSW_RXOPTIONANT		0x3000
+#define	BRFSI_3WIREDATA			0x1
+#define	BRFSI_3WIRECLOCK		0x2
+#define	BRFSI_3WIRELOAD			0x4
+#define	BRFSI_3WIRERW			0x8
+#define	BRFSI_3WIRE			0xf
+
+#define	BRFSI_RFENV			0x10
+
+#define	BRFSI_TRSW			0x20
+#define	BRFSI_TRSWB			0x40
+#define	BRFSI_ANTSW			0x100
+#define	BRFSI_ANTSWB			0x200
+#define	BRFSI_PAPE			0x400
+#define	BRFSI_PAPE5G			0x800
+#define	BBANDSELECT			0x1
+#define	BHTSIG2_GI			0x80
+#define	BHTSIG2_SMOOTHING		0x01
+#define	BHTSIG2_SOUNDING		0x02
+#define	BHTSIG2_AGGREATON		0x08
+#define	BHTSIG2_STBC			0x30
+#define	BHTSIG2_ADVCODING		0x40
+#define	BHTSIG2_NUMOFHTLTF		0x300
+#define	BHTSIG2_CRC8			0x3fc
+#define	BHTSIG1_MCS			0x7f
+#define	BHTSIG1_BANDWIDTH		0x80
+#define	BHTSIG1_HTLENGTH		0xffff
+#define	BLSIG_RATE			0xf
+#define	BLSIG_RESERVED			0x10
+#define	BLSIG_LENGTH			0x1fffe
+#define	BLSIG_PARITY			0x20
+#define	BCCKRXPHASE			0x4
+
+#define	BLSSIREADADDRESS		0x7f800000
+#define	BLSSIREADEDGE			0x80000000
+
+#define	BLSSIREADBACKDATA		0xfffff
+
+#define	BLSSIREADOKFLAG			0x1000
+#define	BCCKSAMPLERATE			0x8
+#define	BREGULATOR0STANDBY		0x1
+#define	BREGULATORPLLSTANDBY		0x2
+#define	BREGULATOR1STANDBY		0x4
+#define	BPLLPOWERUP			0x8
+#define	BDPLLPOWERUP			0x10
+#define	BDA10POWERUP			0x20
+#define	BAD7POWERUP			0x200
+#define	BDA6POWERUP			0x2000
+#define	BXTALPOWERUP			0x4000
+#define	B40MDCLKPOWERUP			0x8000
+#define	BDA6DEBUGMODE			0x20000
+#define	BDA6SWING			0x380000
+
+#define	BADCLKPHASE			0x4000000
+#define	B80MCLKDELAY			0x18000000
+#define	BAFEWATCHDOGENABLE		0x20000000
+
+#define	BXTALCAP01			0xc0000000
+#define	BXTALCAP23			0x3
+#define	BXTALCAP92X					0x0f000000
+#define BXTALCAP			0x0f000000
+
+#define	BINTDIFCLKENABLE		0x400
+#define	BEXTSIGCLKENABLE		0x800
+#define	BBANDGAP_MBIAS_POWERUP      0x10000
+#define	BAD11SH_GAIN			0xc0000
+#define	BAD11NPUT_RANGE			0x700000
+#define	BAD110P_CURRENT			0x3800000
+#define	BLPATH_LOOPBACK			0x4000000
+#define	BQPATH_LOOPBACK			0x8000000
+#define	BAFE_LOOPBACK			0x10000000
+#define	BDA10_SWING			0x7e0
+#define	BDA10_REVERSE			0x800
+#define	BDA_CLK_SOURCE              0x1000
+#define	BDA7INPUT_RANGE			0x6000
+#define	BDA7_GAIN			0x38000
+#define	BDA7OUTPUT_CM_MODE          0x40000
+#define	BDA7INPUT_CM_MODE           0x380000
+#define	BDA7CURRENT			0xc00000
+#define	BREGULATOR_ADJUST		0x7000000
+#define	BAD11POWERUP_ATTX		0x1
+#define	BDA10PS_ATTX			0x10
+#define	BAD11POWERUP_ATRX		0x100
+#define	BDA10PS_ATRX			0x1000
+#define	BCCKRX_AGC_FORMAT           0x200
+#define	BPSDFFT_SAMPLE_POINT		0xc000
+#define	BPSD_AVERAGE_NUM            0x3000
+#define	BIQPATH_CONTROL			0xc00
+#define	BPSD_FREQ			0x3ff
+#define	BPSD_ANTENNA_PATH           0x30
+#define	BPSD_IQ_SWITCH              0x40
+#define	BPSD_RX_TRIGGER             0x400000
+#define	BPSD_TX_TRIGGER             0x80000000
+#define	BPSD_SINE_TONE_SCALE        0x7f000000
+#define	BPSD_REPORT			0xffff
+
+#define	BOFDM_TXSC			0x30000000
+#define	BCCK_TXON			0x1
+#define	BOFDM_TXON			0x2
+#define	BDEBUG_PAGE			0xfff
+#define	BDEBUG_ITEM			0xff
+#define	BANTL				0x10
+#define	BANT_NONHT		    0x100
+#define	BANT_HT1			0x1000
+#define	BANT_HT2			0x10000
+#define	BANT_HT1S1			0x100000
+#define	BANT_NONHTS1			0x1000000
+
+#define	BCCK_BBMODE			0x3
+#define	BCCK_TXPOWERSAVING		0x80
+#define	BCCK_RXPOWERSAVING		0x40
+
+#define	BCCK_SIDEBAND			0x10
+
+#define	BCCK_SCRAMBLE			0x8
+#define	BCCK_ANTDIVERSITY		0x8000
+#define	BCCK_CARRIER_RECOVERY		0x4000
+#define	BCCK_TXRATE			0x3000
+#define	BCCK_DCCANCEL			0x0800
+#define	BCCK_ISICANCEL			0x0400
+#define	BCCK_MATCH_FILTER           0x0200
+#define	BCCK_EQUALIZER			0x0100
+#define	BCCK_PREAMBLE_DETECT		0x800000
+#define	BCCK_FAST_FALSECCA          0x400000
+#define	BCCK_CH_ESTSTART            0x300000
+#define	BCCK_CCA_COUNT              0x080000
+#define	BCCK_CS_LIM			0x070000
+#define	BCCK_BIST_MODE              0x80000000
+#define	BCCK_CCAMASK			0x40000000
+#define	BCCK_TX_DAC_PHASE		0x4
+#define	BCCK_RX_ADC_PHASE		0x20000000
+#define	BCCKR_CP_MODE			0x0100
+#define	BCCK_TXDC_OFFSET		0xf0
+#define	BCCK_RXDC_OFFSET		0xf
+#define	BCCK_CCA_MODE			0xc000
+#define	BCCK_FALSECS_LIM		0x3f00
+#define	BCCK_CS_RATIO			0xc00000
+#define	BCCK_CORGBIT_SEL		0x300000
+#define	BCCK_PD_LIM			0x0f0000
+#define	BCCK_NEWCCA			0x80000000
+#define	BCCK_RXHP_OF_IG             0x8000
+#define	BCCK_RXIG			0x7f00
+#define	BCCK_LNA_POLARITY           0x800000
+#define	BCCK_RX1ST_BAIN             0x7f0000
+#define	BCCK_RF_EXTEND              0x20000000
+#define	BCCK_RXAGC_SATLEVEL		0x1f000000
+#define	BCCK_RXAGC_SATCOUNT		0xe0
+#define	BCCKRXRFSETTLE			0x1f
+#define	BCCK_FIXED_RXAGC		0x8000
+#define	BCCK_ANTENNA_POLARITY		0x2000
+#define	BCCK_TXFILTER_TYPE          0x0c00
+#define	BCCK_RXAGC_REPORTTYPE		0x0300
+#define	BCCK_RXDAGC_EN              0x80000000
+#define	BCCK_RXDAGC_PERIOD		0x20000000
+#define	BCCK_RXDAGC_SATLEVEL		0x1f000000
+#define	BCCK_TIMING_RECOVERY		0x800000
+#define	BCCK_TXC0			0x3f0000
+#define	BCCK_TXC1			0x3f000000
+#define	BCCK_TXC2			0x3f
+#define	BCCK_TXC3			0x3f00
+#define	BCCK_TXC4			0x3f0000
+#define	BCCK_TXC5			0x3f000000
+#define	BCCK_TXC6			0x3f
+#define	BCCK_TXC7			0x3f00
+#define	BCCK_DEBUGPORT			0xff0000
+#define	BCCK_DAC_DEBUG              0x0f000000
+#define	BCCK_FALSEALARM_ENABLE      0x8000
+#define	BCCK_FALSEALARM_READ        0x4000
+#define	BCCK_TRSSI			0x7f
+#define	BCCK_RXAGC_REPORT           0xfe
+#define	BCCK_RXREPORT_ANTSEL		0x80000000
+#define	BCCK_RXREPORT_MFOFF		0x40000000
+#define	BCCK_RXREPORT_SQLOSS		0x20000000
+#define	BCCK_RXREPORT_PKTLOSS		0x10000000
+#define	BCCK_RXREPORT_LOCKEDBIT		0x08000000
+#define	BCCK_RXREPORT_RATEERROR		0x04000000
+#define	BCCK_RXREPORT_RXRATE		0x03000000
+#define	BCCK_RXFA_COUNTER_LOWER     0xff
+#define	BCCK_RXFA_COUNTER_UPPER     0xff000000
+#define	BCCK_RXHPAGC_START          0xe000
+#define	BCCK_RXHPAGC_FINAL          0x1c00
+#define	BCCK_RXFALSEALARM_ENABLE    0x8000
+#define	BCCK_FACOUNTER_FREEZE       0x4000
+#define	BCCK_TXPATH_SEL             0x10000000
+#define	BCCK_DEFAULT_RXPATH         0xc000000
+#define	BCCK_OPTION_RXPATH          0x3000000
+
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
+#define	BRX_AGC_ADDRESS_FOR_LNA     0x7f00
+#define	BRX_HIGHPOWER_FLOW		0x8000
+#define	BRX_AGC_FREEZE_THRES        0xc0000
+#define	BRX_FREEZESTEP_AGC1		0x300000
+#define	BRX_FREEZESTEP_AGC2		0xc00000
+#define	BRX_FREEZESTEP_AGC3		0x3000000
+#define	BRX_FREEZESTEP_AGC0		0xc000000
+#define	BRXRSSI_CMP_EN			0x10000000
+#define	BRXQUICK_AGCEN			0x20000000
+#define	BRXAGC_FREEZE_THRES_MODE    0x40000000
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
+#define	BRXSEARCHRANGE_GI2_EARLY	0x700000
+#define	BRXFRAME_FUARD_COUNTER_L	0x3800000
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
+#define	BCFO_ANTSUM_ID              0x200
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
+
+#define	BNOISE_LVL_TOP_SET          0x3
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
+
+#define	BRX_PESUDO_NOISE_ON         0x20000000
+#define	BRX_PESUDO_NOISE_A		0xff
+#define	BRX_PESUDO_NOISE_B		0xff00
+#define	BRX_PESUDO_NOISE_C		0xff0000
+#define	BRX_PESUDO_NOISE_D		0xff000000
+#define	BRX_PESUDO_NOISESTATE_A     0xffff
+#define	BRX_PESUDO_NOISESTATE_B     0xffff0000
+#define	BRX_PESUDO_NOISESTATE_C     0xffff
+#define	BRX_PESUDO_NOISESTATE_D     0xffff0000
+
+#define	BZEBRA1_HSSIENABLE		0x8
+#define	BZEBRA1_TRXCONTROL		0xc00
+#define	BZEBRA1_TRXGAINSETTING		0x07f
+#define	BZEBRA1_RXCOUNTER		0xc00
+#define	BZEBRA1_TXCHANGEPUMP		0x38
+#define	BZEBRA1_RXCHANGEPUMP		0x7
+#define	BZEBRA1_CHANNEL_NUM		0xf80
+#define	BZEBRA1_TXLPFBW			0x400
+#define	BZEBRA1_RXLPFBW			0x600
+
+#define	BRTL8256REG_MODE_CTRL1      0x100
+#define	BRTL8256REG_MODE_CTRL0      0x40
+#define	BRTL8256REG_TXLPFBW         0x18
+#define	BRTL8256REG_RXLPFBW         0x600
+
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
+#define	MASKDWORD					0xffffffff
+#define	MASK12BITS					0xfff
+#define	MASKH4BITS					0xf0000000
+#define MASKOFDM_D					0xffc00000
+#define	MASKCCK						0x3f3f3f3f
+
+#define	MASK4BITS			0x0f
+#define	MASK20BITS			0xfffff
+#define RFREG_OFFSET_MASK			0xfffff
+
+#define	BENABLE				0x1
+#define	BDISABLE			0x0
+
+#define	LEFT_ANTENNA			0x0
+#define	RIGHT_ANTENNA			0x1
+
+#define	TCHECK_TXSTATUS			500
+#define	TUPDATE_RXCOUNTER		100
+
+#define	REG_UN_used_register		0x01bf
 
 /* WOL bit information */
 #define	HAL92C_WOL_PTK_UPDATE_EVENT		BIT(0)
 #define	HAL92C_WOL_GTK_UPDATE_EVENT		BIT(1)
 #define	HAL92C_WOL_DISASSOC_EVENT		BIT(2)
 #define	HAL92C_WOL_DEAUTH_EVENT			BIT(3)
-#define	HAL92C_WOL_FW_DISCONNECT_EVENT		BIT(4)
+#define	HAL92C_WOL_FW_DISCONNECT_EVENT	BIT(4)
 
 #define		WOL_REASON_PTK_UPDATE		BIT(0)
 #define		WOL_REASON_GTK_UPDATE		BIT(1)
-#define		WOL_REASON_DISASSOC		BIT(2)
-#define		WOL_REASON_DEAUTH		BIT(3)
+#define		WOL_REASON_DISASSOC			BIT(2)
+#define		WOL_REASON_DEAUTH			BIT(3)
 #define		WOL_REASON_FW_DISCONNECT	BIT(4)
-
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
index 4faafdb..40893ce 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
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
@@ -34,6 +30,8 @@
 #include "rf.h"
 #include "dm.h"
 
+static bool _rtl88e_phy_rf6052_config_parafile(struct ieee80211_hw *hw);
+
 void rtl88e_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -60,7 +58,7 @@ void rtl88e_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 }
 
 void rtl88e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-				       u8 *plevel)
+				       u8 *ppowerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
@@ -82,32 +80,36 @@ void rtl88e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 
 		if (turbo_scanoff) {
 			for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
-				tx_agc[idx1] = plevel[idx1] |
-					       (plevel[idx1] << 8) |
-					       (plevel[idx1] << 16) |
-					       (plevel[idx1] << 24);
+				tx_agc[idx1] = ppowerlevel[idx1] |
+				    (ppowerlevel[idx1] << 8) |
+				    (ppowerlevel[idx1] << 16) |
+				    (ppowerlevel[idx1] << 24);
 			}
 		}
 	} else {
 		for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
-			tx_agc[idx1] = plevel[idx1] | (plevel[idx1] << 8) |
-				       (plevel[idx1] << 16) |
-				       (plevel[idx1] << 24);
+			tx_agc[idx1] = ppowerlevel[idx1] |
+			    (ppowerlevel[idx1] << 8) |
+			    (ppowerlevel[idx1] << 16) |
+			    (ppowerlevel[idx1] << 24);
 		}
 
 		if (rtlefuse->eeprom_regulatory == 0) {
-			tmpval = (rtlphy->mcs_offset[0][6]) +
-				 (rtlphy->mcs_offset[0][7] << 8);
+			tmpval =
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][6]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][7] <<
+			     8);
 			tx_agc[RF90_PATH_A] += tmpval;
 
-			tmpval = (rtlphy->mcs_offset[0][14]) +
-				 (rtlphy->mcs_offset[0][15] << 24);
+			tmpval = (rtlphy->mcs_txpwrlevel_origoffset[0][14]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][15] <<
+			     24);
 			tx_agc[RF90_PATH_B] += tmpval;
 		}
 	}
 
 	for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
-		ptr = (u8 *)(&(tx_agc[idx1]));
+		ptr = (u8 *)(&tx_agc[idx1]);
 		for (idx2 = 0; idx2 < 4; idx2++) {
 			if (*ptr > RF6052_MAX_TX_PWR)
 				*ptr = RF6052_MAX_TX_PWR;
@@ -127,10 +129,12 @@ void rtl88e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 		"CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_A_CCK1_MCS32);
+		 RTXAGC_A_CCK1_MCS32);
 
 	tmpval = tx_agc[RF90_PATH_A] >> 8;
 
+	/*tmpval = tmpval & 0xff00ffff;*/
+
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
@@ -153,148 +157,180 @@ void rtl88e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 }
 
 static void rtl88e_phy_get_power_base(struct ieee80211_hw *hw,
-				      u8 *pwrlvlofdm, u8 *pwrlvlbw20,
-				      u8 *pwrlvlbw40, u8 channel,
+				      u8 *ppowerlevel_ofdm,
+				      u8 *ppowerlevel_bw20,
+				      u8 *ppowerlevel_bw40, u8 channel,
 				      u32 *ofdmbase, u32 *mcsbase)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	u32 base0, base1;
+	u32 powerbase0, powerbase1;
 	u8 i, powerlevel[2];
 
 	for (i = 0; i < 2; i++) {
-		base0 = pwrlvlofdm[i];
+		powerbase0 = ppowerlevel_ofdm[i];
 
-		base0 = (base0 << 24) | (base0 << 16) |
-			     (base0 << 8) | base0;
-		*(ofdmbase + i) = base0;
+		powerbase0 = (powerbase0 << 24) | (powerbase0 << 16) |
+		    (powerbase0 << 8) | powerbase0;
+		*(ofdmbase + i) = powerbase0;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			"[OFDM power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(ofdmbase + i));
+			" [OFDM power base index rf(%c) = 0x%x]\n",
+			 ((i == 0) ? 'A' : 'B'), *(ofdmbase + i));
 	}
 
 	for (i = 0; i < 2; i++) {
 		if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20)
-			powerlevel[i] = pwrlvlbw20[i];
+			powerlevel[i] = ppowerlevel_bw20[i];
 		else
-			powerlevel[i] = pwrlvlbw40[i];
-		base1 = powerlevel[i];
-		base1 = (base1 << 24) |
-		    (base1 << 16) | (base1 << 8) | base1;
+			powerlevel[i] = ppowerlevel_bw40[i];
 
-		*(mcsbase + i) = base1;
+		powerbase1 = powerlevel[i];
+		powerbase1 = (powerbase1 << 24) |
+		    (powerbase1 << 16) | (powerbase1 << 8) | powerbase1;
+
+		*(mcsbase + i) = powerbase1;
 
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			"[MCS power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(mcsbase + i));
+			" [MCS power base index rf(%c) = 0x%x]\n",
+			 ((i == 0) ? 'A' : 'B'), *(mcsbase + i));
 	}
 }
 
-static void get_txpwr_by_reg(struct ieee80211_hw *hw, u8 chan, u8 index,
-			     u32 *base0, u32 *base1, u32 *outval)
+static void _rtl88e_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
+						       u8 channel, u8 index,
+						       u32 *powerbase0,
+						       u32 *powerbase1,
+						       u32 *p_outwriteval)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-	u8 i, chg = 0, pwr_lim[4], pwr_diff = 0, cust_pwr_dif;
-	u32 writeval, cust_lim, rf, tmp;
-	u8 ch = chan - 1;
-	u8 j;
+	u8 i, chnlgroup = 0, pwr_diff_limit[4], pwr_diff = 0, customer_pwr_diff;
+	u32 writeval, customer_limit, rf;
 
 	for (rf = 0; rf < 2; rf++) {
-		j = index + (rf ? 8 : 0);
-		tmp = ((index < 2) ? base0[rf] : base1[rf]);
 		switch (rtlefuse->eeprom_regulatory) {
 		case 0:
-			chg = 0;
+			chnlgroup = 0;
 
-			writeval = rtlphy->mcs_offset[chg][j] + tmp;
+			writeval =
+			    rtlphy->mcs_txpwrlevel_origoffset
+				[chnlgroup][index + (rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"RTK better performance, "
-				"writeval(%c) = 0x%x\n",
+				"RTK better performance, writeval(%c) = 0x%x\n",
 				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		case 1:
 			if (rtlphy->pwrgroup_cnt == 1) {
-				chg = 0;
+				chnlgroup = 0;
 			} else {
-				chg = chan / 3;
-				if (chan == 14)
-					chg = 5;
+				if (channel < 3)
+					chnlgroup = 0;
+				else if (channel < 6)
+					chnlgroup = 1;
+				else if (channel < 9)
+					chnlgroup = 2;
+				else if (channel < 12)
+					chnlgroup = 3;
+				else if (channel < 14)
+					chnlgroup = 4;
+				else if (channel == 14)
+					chnlgroup = 5;
 			}
-			writeval = rtlphy->mcs_offset[chg][j] + tmp;
+
+			writeval =
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			    [index + (rf ? 8 : 0)] + ((index < 2) ?
+						      powerbase0[rf] :
+						      powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 				"Realtek regulatory, 20MHz, writeval(%c) = 0x%x\n",
 				 ((rf == 0) ? 'A' : 'B'), writeval);
+
 			break;
 		case 2:
-			writeval = ((index < 2) ? base0[rf] : base1[rf]);
+			writeval =
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 				"Better regulatory, writeval(%c) = 0x%x\n",
-				 ((rf == 0) ? 'A' : 'B'), writeval);
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		case 3:
-			chg = 0;
+			chnlgroup = 0;
 
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 					"customer's limit, 40MHz rf(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'),
-					 rtlefuse->pwrgroup_ht40[rf][ch]);
+					((rf == 0) ? 'A' : 'B'),
+					rtlefuse->pwrgroup_ht40[rf][channel -
+								    1]);
 			} else {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 					"customer's limit, 20MHz rf(%c) = 0x%x\n",
-					 ((rf == 0) ? 'A' : 'B'),
-					 rtlefuse->pwrgroup_ht20[rf][ch]);
+					((rf == 0) ? 'A' : 'B'),
+					rtlefuse->pwrgroup_ht20[rf][channel -
+								    1]);
 			}
 
 			if (index < 2)
-				pwr_diff = rtlefuse->txpwr_legacyhtdiff[rf][ch];
+				pwr_diff =
+				   rtlefuse->txpwr_legacyhtdiff[rf][channel-1];
 			else if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20)
-				pwr_diff = rtlefuse->txpwr_ht20diff[rf][ch];
+				pwr_diff =
+					rtlefuse->txpwr_ht20diff[rf][channel-1];
 
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40)
-				cust_pwr_dif = rtlefuse->pwrgroup_ht40[rf][ch];
+				customer_pwr_diff =
+					rtlefuse->pwrgroup_ht40[rf][channel-1];
 			else
-				cust_pwr_dif = rtlefuse->pwrgroup_ht20[rf][ch];
+				customer_pwr_diff =
+					rtlefuse->pwrgroup_ht20[rf][channel-1];
 
-			if (pwr_diff > cust_pwr_dif)
+			if (pwr_diff > customer_pwr_diff)
 				pwr_diff = 0;
 			else
-				pwr_diff = cust_pwr_dif - pwr_diff;
+				pwr_diff = customer_pwr_diff - pwr_diff;
 
 			for (i = 0; i < 4; i++) {
-				pwr_lim[i] = (u8)((rtlphy->mcs_offset[chg][j] &
-					     (0x7f << (i * 8))) >> (i * 8));
-
-				if (pwr_lim[i] > pwr_diff)
-					pwr_lim[i] = pwr_diff;
+				pwr_diff_limit[i] =
+				    (u8)((rtlphy->mcs_txpwrlevel_origoffset
+					  [chnlgroup][index +
+					  (rf ? 8 : 0)] & (0x7f <<
+					  (i * 8))) >> (i * 8));
+
+				if (pwr_diff_limit[i] > pwr_diff)
+					pwr_diff_limit[i] = pwr_diff;
 			}
 
-			cust_lim = (pwr_lim[3] << 24) | (pwr_lim[2] << 16) |
-				   (pwr_lim[1] << 8) | (pwr_lim[0]);
+			customer_limit = (pwr_diff_limit[3] << 24) |
+			    (pwr_diff_limit[2] << 16) |
+			    (pwr_diff_limit[1] << 8) | (pwr_diff_limit[0]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 				"Customer's limit rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), cust_lim);
+				 ((rf == 0) ? 'A' : 'B'), customer_limit);
 
-			writeval = cust_lim + tmp;
+			writeval = customer_limit +
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"Customer, writeval rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeval);
+				"Customer, writeval rf(%c)= 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		default:
-			chg = 0;
-			writeval = rtlphy->mcs_offset[chg][j] + tmp;
+			chnlgroup = 0;
+			writeval =
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			    [index + (rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"RTK better performance, writeval "
-				"rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeval);
+				"RTK better performance, writeval rf(%c) = 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		}
 
@@ -302,12 +338,13 @@ static void get_txpwr_by_reg(struct ieee80211_hw *hw, u8 chan, u8 index,
 			writeval = writeval - 0x06060606;
 		else if (rtlpriv->dm.dynamic_txhighpower_lvl ==
 			 TXHIGHPWRLEVEL_BT2)
-			writeval -= 0x0c0c0c0c;
-		*(outval + rf) = writeval;
+			writeval = writeval - 0x0c0c0c0c;
+		*(p_outwriteval + rf) = writeval;
 	}
 }
 
-static void write_ofdm_pwr(struct ieee80211_hw *hw, u8 index, u32 *pvalue)
+static void _rtl88e_write_ofdm_power_reg(struct ieee80211_hw *hw,
+					 u8 index, u32 *value)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u16 regoffset_a[6] = {
@@ -325,16 +362,16 @@ static void write_ofdm_pwr(struct ieee80211_hw *hw, u8 index, u32 *pvalue)
 	u16 regoffset;
 
 	for (rf = 0; rf < 2; rf++) {
-		writeval = pvalue[rf];
+		writeval = value[rf];
 		for (i = 0; i < 4; i++) {
-			pwr_val[i] = (u8) ((writeval & (0x7f <<
-				     (i * 8))) >> (i * 8));
+			pwr_val[i] = (u8)((writeval & (0x7f <<
+					   (i * 8))) >> (i * 8));
 
 			if (pwr_val[i] > RF6052_MAX_TX_PWR)
 				pwr_val[i] = RF6052_MAX_TX_PWR;
 		}
 		writeval = (pwr_val[3] << 24) | (pwr_val[2] << 16) |
-			   (pwr_val[1] << 8) | pwr_val[0];
+		    (pwr_val[1] << 8) | pwr_val[0];
 
 		if (rf == 0)
 			regoffset = regoffset_a[index];
@@ -348,24 +385,27 @@ static void write_ofdm_pwr(struct ieee80211_hw *hw, u8 index, u32 *pvalue)
 }
 
 void rtl88e_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-					u8 *pwrlvlofdm,
-					u8 *pwrlvlbw20,
-					u8 *pwrlvlbw40, u8 chan)
+					u8 *ppowerlevel_ofdm,
+					u8 *ppowerlevel_bw20,
+					u8 *ppowerlevel_bw40, u8 channel)
 {
-	u32 writeval[2], base0[2], base1[2];
+	u32 writeval[2], powerbase0[2], powerbase1[2];
 	u8 index;
 	u8 direction;
 	u32 pwrtrac_value;
 
-	rtl88e_phy_get_power_base(hw, pwrlvlofdm, pwrlvlbw20,
-				  pwrlvlbw40, chan, &base0[0],
-				  &base1[0]);
+	rtl88e_phy_get_power_base(hw, ppowerlevel_ofdm,
+				  ppowerlevel_bw20, ppowerlevel_bw40,
+				  channel, &powerbase0[0], &powerbase1[0]);
 
 	rtl88e_dm_txpower_track_adjust(hw, 1, &direction, &pwrtrac_value);
 
 	for (index = 0; index < 6; index++) {
-		get_txpwr_by_reg(hw, chan, index, &base0[0], &base1[0],
-				 &writeval[0]);
+		_rtl88e_get_txpower_writeval_by_regulatory(hw,
+							   channel, index,
+							   &powerbase0[0],
+							   &powerbase1[0],
+							   &writeval[0]);
 		if (direction == 1) {
 			writeval[0] += pwrtrac_value;
 			writeval[1] += pwrtrac_value;
@@ -373,15 +413,28 @@ void rtl88e_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
 			writeval[0] -= pwrtrac_value;
 			writeval[1] -= pwrtrac_value;
 		}
-		write_ofdm_pwr(hw, index, &writeval[0]);
+		_rtl88e_write_ofdm_power_reg(hw, index, &writeval[0]);
 	}
 }
 
-static bool rf6052_conf_para(struct ieee80211_hw *hw)
+bool rtl88e_phy_rf6052_config(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	u32 u4val = 0;
+
+	if (rtlphy->rf_type == RF_1T1R)
+		rtlphy->num_total_rfpath = 1;
+	else
+		rtlphy->num_total_rfpath = 2;
+
+	return _rtl88e_phy_rf6052_config_parafile(hw);
+}
+
+static bool _rtl88e_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	u32 u4_regvalue = 0;
 	u8 rfpath;
 	bool rtstatus = true;
 	struct bb_reg_def *pphyreg;
@@ -392,12 +445,12 @@ static bool rf6052_conf_para(struct ieee80211_hw *hw)
 		switch (rfpath) {
 		case RF90_PATH_A:
 		case RF90_PATH_C:
-			u4val = rtl_get_bbreg(hw, pphyreg->rfintfs,
+			u4_regvalue = rtl_get_bbreg(hw, pphyreg->rfintfs,
 						    BRFSI_RFENV);
 			break;
 		case RF90_PATH_B:
 		case RF90_PATH_D:
-			u4val = rtl_get_bbreg(hw, pphyreg->rfintfs,
+			u4_regvalue = rtl_get_bbreg(hw, pphyreg->rfintfs,
 						    BRFSI_RFENV << 16);
 			break;
 		}
@@ -418,11 +471,11 @@ static bool rf6052_conf_para(struct ieee80211_hw *hw)
 		switch (rfpath) {
 		case RF90_PATH_A:
 			rtstatus = rtl88e_phy_config_rf_with_headerfile(hw,
-					(enum radio_path)rfpath);
+						(enum radio_path)rfpath);
 			break;
 		case RF90_PATH_B:
 			rtstatus = rtl88e_phy_config_rf_with_headerfile(hw,
-					(enum radio_path)rfpath);
+						(enum radio_path)rfpath);
 			break;
 		case RF90_PATH_C:
 			break;
@@ -433,12 +486,13 @@ static bool rf6052_conf_para(struct ieee80211_hw *hw)
 		switch (rfpath) {
 		case RF90_PATH_A:
 		case RF90_PATH_C:
-			rtl_set_bbreg(hw, pphyreg->rfintfs, BRFSI_RFENV, u4val);
+			rtl_set_bbreg(hw, pphyreg->rfintfs,
+				      BRFSI_RFENV, u4_regvalue);
 			break;
 		case RF90_PATH_B:
 		case RF90_PATH_D:
-			rtl_set_bbreg(hw, pphyreg->rfintfs, BRFSI_RFENV << 16,
-				      u4val);
+			rtl_set_bbreg(hw, pphyreg->rfintfs,
+				      BRFSI_RFENV << 16, u4_regvalue);
 			break;
 		}
 
@@ -447,21 +501,9 @@ static bool rf6052_conf_para(struct ieee80211_hw *hw)
 				 "Radio[%d] Fail!!", rfpath);
 			return false;
 		}
+
 	}
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "\n");
 	return rtstatus;
 }
-
-bool rtl88e_phy_rf6052_config(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-
-	if (rtlphy->rf_type == RF_1T1R)
-		rtlphy->num_total_rfpath = 1;
-	else
-		rtlphy->num_total_rfpath = 2;
-
-	return rf6052_conf_para(hw);
-}
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
index a39a2a3..5c1472d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
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
@@ -40,7 +36,8 @@ void rtl88e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 void rtl88e_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
 					u8 *ppowerlevel_ofdm,
 					u8 *ppowerlevel_bw20,
-					u8 *ppowerlevel_bw40, u8 channel);
+					u8 *ppowerlevel_bw40,
+					u8 channel);
 bool rtl88e_phy_rf6052_config(struct ieee80211_hw *hw);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index 631b690..ab7dbfb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
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
@@ -30,7 +26,6 @@
 #include "../wifi.h"
 #include "../core.h"
 #include "../pci.h"
-#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -122,7 +117,7 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 				  0);
 
 	rtlpci->irq_mask[0] =
-				(u32) (IMR_PSTIMEOUT	|
+				(u32)(IMR_PSTIMEOUT	|
 				IMR_HSISR_IND_ON_INT	|
 				IMR_C2HCMD		|
 				IMR_HIGHDOK		|
@@ -143,6 +138,8 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->psc.inactiveps = rtlpriv->cfg->mod_params->inactiveps;
 	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
 	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
+	if (rtlpriv->cfg->mod_params->disable_watchdog)
+		pr_info("watchdog disabled\n");
 	if (!rtlpriv->psc.inactiveps)
 		pr_info("rtl8188ee: Power Save off (module option)\n");
 	if (!rtlpriv->psc.fwctrl_lps)
@@ -199,7 +196,7 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	init_timer(&rtlpriv->works.fast_antenna_training_timer);
 	setup_timer(&rtlpriv->works.fast_antenna_training_timer,
 		    rtl88e_dm_fast_antenna_training_callback,
-		    (unsigned long)hw);
+			(unsigned long)hw);
 	return err;
 }
 
@@ -218,6 +215,12 @@ void rtl88e_deinit_sw_vars(struct ieee80211_hw *hw)
 	del_timer_sync(&rtlpriv->works.fast_antenna_training_timer);
 }
 
+/* get bt coexist status */
+bool rtl88e_get_btc_status(void)
+{
+	return false;
+}
+
 static struct rtl_hal_ops rtl8188ee_hal_ops = {
 	.init_sw_vars = rtl88e_init_sw_vars,
 	.deinit_sw_vars = rtl88e_deinit_sw_vars,
@@ -246,11 +249,12 @@ static struct rtl_hal_ops rtl8188ee_hal_ops = {
 	.set_bw_mode = rtl88e_phy_set_bw_mode,
 	.switch_channel = rtl88e_phy_sw_chnl,
 	.dm_watchdog = rtl88e_dm_watchdog,
-	.scan_operation_backup = rtl_phy_scan_operation_backup,
+	.scan_operation_backup = rtl88e_phy_scan_operation_backup,
 	.set_rf_power_state = rtl88e_phy_set_rf_power_state,
 	.led_control = rtl88ee_led_control,
 	.set_desc = rtl88ee_set_desc,
 	.get_desc = rtl88ee_get_desc,
+	.is_tx_desc_closed = rtl88ee_is_tx_desc_closed,
 	.tx_polling = rtl88ee_tx_polling,
 	.enable_hw_sec = rtl88ee_enable_hw_security_config,
 	.set_key = rtl88ee_set_key,
@@ -259,14 +263,17 @@ static struct rtl_hal_ops rtl8188ee_hal_ops = {
 	.set_bbreg = rtl88e_phy_set_bb_reg,
 	.get_rfreg = rtl88e_phy_query_rf_reg,
 	.set_rfreg = rtl88e_phy_set_rf_reg,
+	.get_btc_status = rtl88e_get_btc_status,
+	.rx_command_packet = rtl88ee_rx_command_packet,
+
 };
 
 static struct rtl_mod_params rtl88ee_mod_params = {
 	.sw_crypto = false,
-	.inactiveps = true,
+	.inactiveps = false,
 	.swctrl_lps = false,
-	.fwctrl_lps = true,
-	.msi_support = false,
+	.fwctrl_lps = false,
+	.msi_support = true,
 	.debug = DBG_EMERG,
 };
 
@@ -274,6 +281,7 @@ static struct rtl_hal_cfg rtl88ee_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
 	.name = "rtl88e_pci",
+	.fw_name = "rtlwifi/rtl8188efw.bin",
 	.ops = &rtl8188ee_hal_ops,
 	.mod_params = &rtl88ee_mod_params,
 
@@ -285,6 +293,9 @@ static struct rtl_hal_cfg rtl88ee_hal_cfg = {
 	.maps[MAC_RCR_ACRC32] = ACRC32,
 	.maps[MAC_RCR_ACF] = ACF,
 	.maps[MAC_RCR_AAP] = AAP,
+	.maps[MAC_HIMR] = REG_HIMR,
+	.maps[MAC_HIMRE] = REG_HIMRE,
+	.maps[MAC_HSISR] = REG_HSISR,
 
 	.maps[EFUSE_ACCESS] = REG_EFUSE_ACCESS,
 
@@ -345,6 +356,7 @@ static struct rtl_hal_cfg rtl88ee_hal_cfg = {
 	.maps[RTL_IMR_VIDOK] = IMR_VIDOK,
 	.maps[RTL_IMR_VODOK] = IMR_VODOK,
 	.maps[RTL_IMR_ROK] = IMR_ROK,
+	.maps[RTL_IMR_HSISR_IND] = IMR_HSISR_IND_ON_INT,
 	.maps[RTL_IBSS_INT_MASKS] = (IMR_BCNDMAINT0 | IMR_TBDOK | IMR_TBDER),
 
 	.maps[RTL_RC_CCK_RATE1M] = DESC92C_RATE1M,
@@ -364,7 +376,7 @@ static struct rtl_hal_cfg rtl88ee_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
 };
 
-static const struct pci_device_id rtl88ee_pci_ids[] = {
+static struct pci_device_id rtl88ee_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8179, rtl88ee_hal_cfg)},
 	{},
 };
@@ -384,12 +396,15 @@ module_param_named(ips, rtl88ee_mod_params.inactiveps, bool, 0444);
 module_param_named(swlps, rtl88ee_mod_params.swctrl_lps, bool, 0444);
 module_param_named(fwlps, rtl88ee_mod_params.fwctrl_lps, bool, 0444);
 module_param_named(msi, rtl88ee_mod_params.msi_support, bool, 0444);
+module_param_named(disable_watchdog, rtl88ee_mod_params.disable_watchdog,
+		   bool, 0444);
 MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
 MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)\n");
 MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (default 0)\n");
 MODULE_PARM_DESC(fwlps, "Set to 1 to use FW control power save (default 1)\n");
-MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 0)\n");
+MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 1)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
+MODULE_PARM_DESC(disable_watchdog, "Set to 1 to disable the watchdog (default 0)\n");
 
 static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.h b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.h
index 85e02b3..22398c3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.h
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
@@ -32,5 +28,7 @@
 
 int rtl88e_init_sw_vars(struct ieee80211_hw *hw);
 void rtl88e_deinit_sw_vars(struct ieee80211_hw *hw);
+bool rtl88e_get_btc_status(void);
+
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/table.c b/drivers/net/wireless/rtlwifi/rtl8188ee/table.c
index fad373f..68bcb7f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/table.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/table.c
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
@@ -30,7 +26,6 @@
  *****************************************************************************/
 
 #include "table.h"
-
 u32 RTL8188EEPHY_REG_1TARRAY[] = {
 		0x800, 0x80040000,
 		0x804, 0x00000003,
@@ -640,4 +635,5 @@ u32 RTL8188EEAGCTAB_1TARRAY[] = {
 		0xC78, 0x407D0001,
 		0xC78, 0x407E0001,
 		0xC78, 0x407F0001,
+
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/table.h b/drivers/net/wireless/rtlwifi/rtl8188ee/table.h
index c1218e83..403c4dd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/table.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/table.h
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
 #include <linux/types.h>
 #define  RTL8188EEPHY_REG_1TARRAYLEN	382
 extern u32 RTL8188EEPHY_REG_1TARRAY[];
-#define RTL8188EEPHY_REG_ARRAY_PGLEN	264
+#define RTL8188EEPHY_REG_ARRAY_PGLEN 264
 extern u32 RTL8188EEPHY_REG_ARRAY_PG[];
-#define	RTL8188EE_RADIOA_1TARRAYLEN	190
+#define	RTL8188EE_RADIOA_1TARRAYLEN 190
 extern u32 RTL8188EE_RADIOA_1TARRAY[];
-#define RTL8188EEMAC_1T_ARRAYLEN	180
+#define RTL8188EEMAC_1T_ARRAYLEN  180
 extern u32 RTL8188EEMAC_1T_ARRAY[];
-#define RTL8188EEAGCTAB_1TARRAYLEN	256
+#define RTL8188EEAGCTAB_1TARRAYLEN 256
 extern u32 RTL8188EEAGCTAB_1TARRAY[];
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index 5b4c225..cf56ec8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
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
@@ -37,6 +33,7 @@
 #include "trx.h"
 #include "led.h"
 #include "dm.h"
+#include "phy.h"
 
 static u8 _rtl88ee_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 {
@@ -50,6 +47,164 @@ static u8 _rtl88ee_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 	return skb->priority;
 }
 
+/* mac80211's rate_idx is like this:
+ *
+ * 2.4G band:rx_status->band == IEEE80211_BAND_2GHZ
+ *
+ * B/G rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE1M-->DESC92C_RATE54M ==> idx is 0-->11,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ *
+ * 5G band:rx_status->band == IEEE80211_BAND_5GHZ
+ * A rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE6M-->DESC92C_RATE54M ==> idx is 0-->7,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ */
+static int _rtl88ee_rate_mapping(struct ieee80211_hw *hw,
+				 bool isht, u8 desc_rate)
+{
+	int rate_idx;
+
+	if (!isht) {
+		if (IEEE80211_BAND_2GHZ == hw->conf.chandef.chan->band) {
+			switch (desc_rate) {
+			case DESC92C_RATE1M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE2M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE5_5M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE11M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE6M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 7;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 8;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 9;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 10;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 11;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		} else {
+			switch (desc_rate) {
+			case DESC92C_RATE6M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 7;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		}
+	} else {
+		switch (desc_rate) {
+		case DESC92C_RATEMCS0:
+			rate_idx = 0;
+			break;
+		case DESC92C_RATEMCS1:
+			rate_idx = 1;
+			break;
+		case DESC92C_RATEMCS2:
+			rate_idx = 2;
+			break;
+		case DESC92C_RATEMCS3:
+			rate_idx = 3;
+			break;
+		case DESC92C_RATEMCS4:
+			rate_idx = 4;
+			break;
+		case DESC92C_RATEMCS5:
+			rate_idx = 5;
+			break;
+		case DESC92C_RATEMCS6:
+			rate_idx = 6;
+			break;
+		case DESC92C_RATEMCS7:
+			rate_idx = 7;
+			break;
+		case DESC92C_RATEMCS8:
+			rate_idx = 8;
+			break;
+		case DESC92C_RATEMCS9:
+			rate_idx = 9;
+			break;
+		case DESC92C_RATEMCS10:
+			rate_idx = 10;
+			break;
+		case DESC92C_RATEMCS11:
+			rate_idx = 11;
+			break;
+		case DESC92C_RATEMCS12:
+			rate_idx = 12;
+			break;
+		case DESC92C_RATEMCS13:
+			rate_idx = 13;
+			break;
+		case DESC92C_RATEMCS14:
+			rate_idx = 14;
+			break;
+		case DESC92C_RATEMCS15:
+			rate_idx = 15;
+			break;
+		default:
+			rate_idx = 0;
+			break;
+		}
+	}
+	return rate_idx;
+}
+
 static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 			struct rtl_stats *pstatus, u8 *pdesc,
 			struct rx_fwinfo_88e *p_drvinfo,
@@ -59,7 +214,8 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
 	struct phy_sts_cck_8192s_t *cck_buf;
-	struct phy_status_rpt *phystrpt = (struct phy_status_rpt *)p_drvinfo;
+	struct phy_status_rpt *phystrpt =
+		(struct phy_status_rpt *)p_drvinfo;
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
 	char rx_pwr_all = 0, rx_pwr[4];
 	u8 rf_rx_num = 0, evm, pwdb_all;
@@ -72,11 +228,11 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 	pstatus->packet_matchbssid = bpacket_match_bssid;
 	pstatus->packet_toself = bpacket_toself;
 	pstatus->packet_beacon = packet_beacon;
-	pstatus->rx_mimo_sig_qual[0] = -1;
-	pstatus->rx_mimo_sig_qual[1] = -1;
+	pstatus->rx_mimo_signalquality[0] = -1;
+	pstatus->rx_mimo_signalquality[1] = -1;
 
 	if (is_cck) {
-		u8 cck_hipwr;
+		u8 cck_highpwr;
 		u8 cck_agc_rpt;
 		/* CCK Driver info Structure is not the same as OFDM packet. */
 		cck_buf = (struct phy_sts_cck_8192s_t *)p_drvinfo;
@@ -87,53 +243,58 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 		 * hardware (for rate adaptive)
 		 */
 		if (ppsc->rfpwr_state == ERFON)
-			cck_hipwr = rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2,
+			cck_highpwr =
+				(u8)rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2,
 						  BIT(9));
 		else
-			cck_hipwr = false;
+			cck_highpwr = false;
 
 		lan_idx = ((cck_agc_rpt & 0xE0) >> 5);
 		vga_idx = (cck_agc_rpt & 0x1f);
 		switch (lan_idx) {
 		case 7:
 			if (vga_idx <= 27)
-				rx_pwr_all = -100 + 2 * (27 - vga_idx);
+				/*VGA_idx = 27~2*/
+				rx_pwr_all = -100 + 2*(27-vga_idx);
 			else
 				rx_pwr_all = -100;
 			break;
 		case 6:
-			rx_pwr_all = -48 + 2 * (2 - vga_idx); /*VGA_idx = 2~0*/
+			/*VGA_idx = 2~0*/
+			rx_pwr_all = -48 + 2*(2-vga_idx);
 			break;
 		case 5:
-			rx_pwr_all = -42 + 2 * (7 - vga_idx); /*VGA_idx = 7~5*/
+			/*VGA_idx = 7~5*/
+			rx_pwr_all = -42 + 2*(7-vga_idx);
 			break;
 		case 4:
-			rx_pwr_all = -36 + 2 * (7 - vga_idx); /*VGA_idx = 7~4*/
+			/*VGA_idx = 7~4*/
+			rx_pwr_all = -36 + 2*(7-vga_idx);
 			break;
 		case 3:
-			rx_pwr_all = -24 + 2 * (7 - vga_idx); /*VGA_idx = 7~0*/
+			/*VGA_idx = 7~0*/
+			rx_pwr_all = -24 + 2*(7-vga_idx);
 			break;
 		case 2:
-			if (cck_hipwr)
-				rx_pwr_all = -12 + 2 * (5 - vga_idx);
+			if (cck_highpwr)
+				/*VGA_idx = 5~0*/
+				rx_pwr_all = -12 + 2*(5-vga_idx);
 			else
-				rx_pwr_all = -6 + 2 * (5 - vga_idx);
+				rx_pwr_all = -6 + 2*(5-vga_idx);
 			break;
 		case 1:
-			rx_pwr_all = 8 - 2 * vga_idx;
+			rx_pwr_all = 8-2*vga_idx;
 			break;
 		case 0:
-			rx_pwr_all = 14 - 2 * vga_idx;
+			rx_pwr_all = 14-2*vga_idx;
 			break;
 		default:
 			break;
 		}
 		rx_pwr_all += 6;
 		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
-		/* CCK gain is smaller than OFDM/MCS gain,
-		 * so we add gain diff by experiences,
-		 * the val is 6
-		 */
+		/* CCK gain is smaller than OFDM/MCS gain,  */
+		/* so we add gain diff by experiences, the val is 6 */
 		pwdb_all += 6;
 		if (pwdb_all > 100)
 			pwdb_all = 100;
@@ -148,10 +309,10 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 			pwdb_all -= 8;
 		else if (pwdb_all > 4 && pwdb_all <= 14)
 			pwdb_all -= 4;
-		if (cck_hipwr == false) {
+		if (!cck_highpwr) {
 			if (pwdb_all >= 80)
-				pwdb_all = ((pwdb_all - 80)<<1) +
-					   ((pwdb_all - 80)>>1) + 80;
+				pwdb_all = ((pwdb_all-80)<<1) +
+					   ((pwdb_all-80)>>1) + 80;
 			else if ((pwdb_all <= 78) && (pwdb_all >= 20))
 				pwdb_all += 3;
 			if (pwdb_all > 100)
@@ -165,9 +326,9 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 		if (bpacket_match_bssid) {
 			u8 sq;
 
-			if (pstatus->rx_pwdb_all > 40) {
+			if (pstatus->rx_pwdb_all > 40)
 				sq = 100;
-			} else {
+			else {
 				sq = cck_buf->sq_rpt;
 				if (sq > 64)
 					sq = 0;
@@ -178,8 +339,8 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 			}
 
 			pstatus->signalquality = sq;
-			pstatus->rx_mimo_sig_qual[0] = sq;
-			pstatus->rx_mimo_sig_qual[1] = -1;
+			pstatus->rx_mimo_signalquality[0] = sq;
+			pstatus->rx_mimo_signalquality[1] = -1;
 		}
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] =
@@ -191,18 +352,20 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 			if (rtlpriv->dm.rfpath_rxenable[i])
 				rf_rx_num++;
 
-			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f) * 2)-110;
+			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] &
+				      0x3f) * 2) - 110;
 
 			/* Translate DBM to percentage. */
 			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 
 			/* Get Rx snr value in DB */
-			rtlpriv->stats.rx_snr_db[i] = p_drvinfo->rxsnr[i] / 2;
+			rtlpriv->stats.rx_snr_db[i] =
+				(long)(p_drvinfo->rxsnr[i] / 2);
 
 			/* Record Signal Strength for next packet */
 			if (bpacket_match_bssid)
-				pstatus->rx_mimo_signalstrength[i] = (u8) rssi;
+				pstatus->rx_mimo_signalstrength[i] = (u8)rssi;
 		}
 
 		/* (2)PWDB, Average PWDB cacluated by
@@ -227,11 +390,13 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 
 			if (bpacket_match_bssid) {
 				/* Fill value in RFD, Get the first
-				 * spatial stream only
+				 * spatial stream onlyi
 				 */
 				if (i == 0)
-					pstatus->signalquality = evm & 0xff;
-				pstatus->rx_mimo_sig_qual[i] = evm & 0xff;
+					pstatus->signalquality =
+						(u8)(evm & 0xff);
+				pstatus->rx_mimo_signalquality[i] =
+					(u8)(evm & 0xff);
 			}
 		}
 	}
@@ -241,10 +406,10 @@ static void _rtl88ee_query_rxphystatus(struct ieee80211_hw *hw,
 	 */
 	if (is_cck)
 		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-					  pwdb_all));
+			pwdb_all));
 	else if (rf_rx_num != 0)
 		pstatus->signalstrength = (u8)(rtl_signal_scale_mapping(hw,
-					  total_rssi /= rf_rx_num));
+			total_rssi /= rf_rx_num));
 	/*HW antenna diversity*/
 	rtldm->fat_table.antsel_rx_keep_0 = phystrpt->ant_sel;
 	rtldm->fat_table.antsel_rx_keep_1 = phystrpt->ant_sel_b;
@@ -256,34 +421,39 @@ static void _rtl88ee_smart_antenna(struct ieee80211_hw *hw,
 {
 	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-	u8 ant_mux;
-	struct fast_ant_training *pfat = &(rtldm->fat_table);
+	u8 antsel_tr_mux;
+	struct fast_ant_training *pfat_table = &rtldm->fat_table;
 
 	if (rtlefuse->antenna_div_type == CG_TRX_SMART_ANTDIV) {
-		if (pfat->fat_state == FAT_TRAINING_STATE) {
+		if (pfat_table->fat_state == FAT_TRAINING_STATE) {
 			if (pstatus->packet_toself) {
-				ant_mux = (pfat->antsel_rx_keep_2 << 2) |
-						(pfat->antsel_rx_keep_1 << 1) |
-						 pfat->antsel_rx_keep_0;
-				pfat->ant_sum[ant_mux] += pstatus->rx_pwdb_all;
-				pfat->ant_cnt[ant_mux]++;
+				antsel_tr_mux =
+					(pfat_table->antsel_rx_keep_2 << 2) |
+					(pfat_table->antsel_rx_keep_1 << 1) |
+					pfat_table->antsel_rx_keep_0;
+				pfat_table->ant_sum[antsel_tr_mux] +=
+					pstatus->rx_pwdb_all;
+				pfat_table->ant_cnt[antsel_tr_mux]++;
 			}
 		}
 	} else if ((rtlefuse->antenna_div_type == CG_TRX_HW_ANTDIV) ||
-		   (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)) {
+	(rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)) {
 		if (pstatus->packet_toself || pstatus->packet_matchbssid) {
-			ant_mux = (pfat->antsel_rx_keep_2 << 2) |
-				  (pfat->antsel_rx_keep_1 << 1) |
-				   pfat->antsel_rx_keep_0;
-			rtl88e_dm_ant_sel_statistics(hw, ant_mux, 0,
+			antsel_tr_mux = (pfat_table->antsel_rx_keep_2 << 2) |
+					(pfat_table->antsel_rx_keep_1 << 1) |
+					pfat_table->antsel_rx_keep_0;
+			rtl88e_dm_ant_sel_statistics(hw, antsel_tr_mux, 0,
 						     pstatus->rx_pwdb_all);
 		}
+
 	}
 }
 
 static void _rtl88ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
-		struct sk_buff *skb, struct rtl_stats *pstatus,
-		u8 *pdesc, struct rx_fwinfo_88e *p_drvinfo)
+					       struct sk_buff *skb,
+					       struct rtl_stats *pstatus,
+					       u8 *pdesc,
+					       struct rx_fwinfo_88e *p_drvinfo)
 {
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
@@ -292,42 +462,42 @@ static void _rtl88ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
 	u8 *praddr;
 	u8 *psaddr;
 	__le16 fc;
-	u16 type, ufc;
-	bool match_bssid, packet_toself, packet_beacon = false, addr;
+	bool packet_matchbssid, packet_toself, packet_beacon;
 
 	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
 
 	hdr = (struct ieee80211_hdr *)tmp_buf;
 	fc = hdr->frame_control;
-	ufc = le16_to_cpu(fc);
-	type = WLAN_FC_GET_TYPE(fc);
 	praddr = hdr->addr1;
 	psaddr = ieee80211_get_SA(hdr);
 	memcpy(pstatus->psaddr, psaddr, ETH_ALEN);
 
-	addr = ether_addr_equal(mac->bssid,
-				(ufc & IEEE80211_FCTL_TODS) ? hdr->addr1 :
-				(ufc & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
-				hdr->addr3);
-	match_bssid = ((IEEE80211_FTYPE_CTL != type) && (!pstatus->hwerror) &&
-		       (!pstatus->crc) && (!pstatus->icv)) && addr;
+	packet_matchbssid = ((!ieee80211_is_ctl(fc)) &&
+	     (ether_addr_equal(mac->bssid, ieee80211_has_tods(fc) ?
+			       hdr->addr1 : ieee80211_has_fromds(fc) ?
+			       hdr->addr2 : hdr->addr3)) &&
+			       (!pstatus->hwerror) &&
+			       (!pstatus->crc) && (!pstatus->icv));
 
-	addr = ether_addr_equal(praddr, rtlefuse->dev_addr);
-	packet_toself = match_bssid && addr;
+	packet_toself = packet_matchbssid &&
+	    (ether_addr_equal(praddr, rtlefuse->dev_addr));
 
-	if (ieee80211_is_beacon(fc))
+	if (ieee80211_is_beacon(hdr->frame_control))
 		packet_beacon = true;
+	else
+		packet_beacon = false;
 
 	_rtl88ee_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
-				   match_bssid, packet_toself, packet_beacon);
+				   packet_matchbssid, packet_toself,
+				   packet_beacon);
 	_rtl88ee_smart_antenna(hw, pstatus);
 	rtl_process_phyinfo(hw, tmp_buf, pstatus);
 }
 
-static void insert_em(struct rtl_tcb_desc *ptcb_desc, u8 *virtualaddress)
+static void _rtl88ee_insert_emcontent(struct rtl_tcb_desc *ptcb_desc,
+				      u8 *virtualaddress)
 {
 	u32 dwtmp = 0;
-
 	memset(virtualaddress, 0, 8);
 
 	SET_EARLYMODE_PKTNUM(virtualaddress, ptcb_desc->empkt_num);
@@ -335,7 +505,7 @@ static void insert_em(struct rtl_tcb_desc *ptcb_desc, u8 *virtualaddress)
 		dwtmp = ptcb_desc->empkt_len[0];
 	} else {
 		dwtmp = ptcb_desc->empkt_len[0];
-		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ((dwtmp%4) ? (4-dwtmp%4) : 0)+4;
 		dwtmp += ptcb_desc->empkt_len[1];
 	}
 	SET_EARLYMODE_LEN0(virtualaddress, dwtmp);
@@ -344,7 +514,7 @@ static void insert_em(struct rtl_tcb_desc *ptcb_desc, u8 *virtualaddress)
 		dwtmp = ptcb_desc->empkt_len[2];
 	} else {
 		dwtmp = ptcb_desc->empkt_len[2];
-		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ((dwtmp%4) ? (4-dwtmp%4) : 0)+4;
 		dwtmp += ptcb_desc->empkt_len[3];
 	}
 	SET_EARLYMODE_LEN1(virtualaddress, dwtmp);
@@ -352,7 +522,7 @@ static void insert_em(struct rtl_tcb_desc *ptcb_desc, u8 *virtualaddress)
 		dwtmp = ptcb_desc->empkt_len[4];
 	} else {
 		dwtmp = ptcb_desc->empkt_len[4];
-		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ((dwtmp%4) ? (4-dwtmp%4) : 0)+4;
 		dwtmp += ptcb_desc->empkt_len[5];
 	}
 	SET_EARLYMODE_LEN2_1(virtualaddress, dwtmp & 0xF);
@@ -361,7 +531,7 @@ static void insert_em(struct rtl_tcb_desc *ptcb_desc, u8 *virtualaddress)
 		dwtmp = ptcb_desc->empkt_len[6];
 	} else {
 		dwtmp = ptcb_desc->empkt_len[6];
-		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ((dwtmp%4) ? (4-dwtmp%4) : 0)+4;
 		dwtmp += ptcb_desc->empkt_len[7];
 	}
 	SET_EARLYMODE_LEN3(virtualaddress, dwtmp);
@@ -369,7 +539,7 @@ static void insert_em(struct rtl_tcb_desc *ptcb_desc, u8 *virtualaddress)
 		dwtmp = ptcb_desc->empkt_len[8];
 	} else {
 		dwtmp = ptcb_desc->empkt_len[8];
-		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ((dwtmp%4) ? (4-dwtmp%4) : 0)+4;
 		dwtmp += ptcb_desc->empkt_len[9];
 	}
 	SET_EARLYMODE_LEN4(virtualaddress, dwtmp);
@@ -387,21 +557,21 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
 	status->packet_report_type = (u8)GET_RX_STATUS_DESC_RPT_SEL(pdesc);
 	if (status->packet_report_type == TX_REPORT2)
-		status->length = (u16) GET_RX_RPT2_DESC_PKT_LEN(pdesc);
+		status->length = (u16)GET_RX_RPT2_DESC_PKT_LEN(pdesc);
 	else
-		status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
-	status->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
-				       RX_DRV_INFO_SIZE_UNIT;
-	status->rx_bufshift = (u8) (GET_RX_DESC_SHIFT(pdesc) & 0x03);
-	status->icv = (u16) GET_RX_DESC_ICV(pdesc);
-	status->crc = (u16) GET_RX_DESC_CRC32(pdesc);
+		status->length = (u16)GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size = (u8)GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+	    RX_DRV_INFO_SIZE_UNIT;
+	status->rx_bufshift = (u8)(GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->icv = (u16)GET_RX_DESC_ICV(pdesc);
+	status->crc = (u16)GET_RX_DESC_CRC32(pdesc);
 	status->hwerror = (status->crc | status->icv);
 	status->decrypted = !GET_RX_DESC_SWDEC(pdesc);
-	status->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
-	status->shortpreamble = (u16) GET_RX_DESC_SPLCP(pdesc);
+	status->rate = (u8)GET_RX_DESC_RXMCS(pdesc);
+	status->shortpreamble = (u16)GET_RX_DESC_SPLCP(pdesc);
 	status->isampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
-	status->isfirst_ampdu = (bool) ((GET_RX_DESC_PAGGR(pdesc) == 1) &&
-					(GET_RX_DESC_FAGGR(pdesc) == 1));
+	status->isfirst_ampdu = (bool)((GET_RX_DESC_PAGGR(pdesc) == 1) &&
+				(GET_RX_DESC_FAGGR(pdesc) == 1));
 	if (status->packet_report_type == NORMAL_RX)
 		status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
 	status->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
@@ -420,11 +590,14 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 		status->wake_match = 0;
 	if (status->wake_match)
 		RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD,
-			 "Get Wakeup Packet!! WakeMatch =%d\n",
-			 status->wake_match);
+		"GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch=%d\n",
+		status->wake_match);
 	rx_status->freq = hw->conf.chandef.chan->center_freq;
 	rx_status->band = hw->conf.chandef.chan->band;
 
+	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size
+			+ status->rx_bufshift);
+
 	if (status->crc)
 		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
 
@@ -445,18 +618,18 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		hdr = (struct ieee80211_hdr *)(skb->data +
-		       status->rx_drvinfo_size + status->rx_bufshift);
-
 		if (!hdr) {
-			/* During testing, hdr was NULL */
+			WARN_ON_ONCE(true);
+			pr_err("decrypted is true but hdr NULL, from skb %p\n",
+			       rtl_get_hdr(skb));
 			return false;
 		}
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
+
+		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
 		    (ieee80211_has_protected(hdr->frame_control)))
-			rx_status->flag &= ~RX_FLAG_DECRYPTED;
-		else
 			rx_status->flag |= RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 	}
 
 	/* rate_idx: index of data rate into band's
@@ -464,19 +637,18 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 	 * are use (RX_FLAG_HT)
 	 * Notice: this is diff with windows define
 	 */
-	rx_status->rate_idx = rtlwifi_rate_mapping(hw, status->is_ht,
-						   status->rate, false);
+	rx_status->rate_idx = _rtl88ee_rate_mapping(hw,
+				status->is_ht, status->rate);
 
 	rx_status->mactime = status->timestamp_low;
 	if (phystatus == true) {
 		p_drvinfo = (struct rx_fwinfo_88e *)(skb->data +
 						     status->rx_bufshift);
 
-		_rtl88ee_translate_rx_signal_stuff(hw, skb, status, pdesc,
+		_rtl88ee_translate_rx_signal_stuff(hw,
+						   skb, status, pdesc,
 						   p_drvinfo);
 	}
-
-	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
 	if (status->packet_report_type == TX_REPORT2) {
 		status->macid_valid_entry[0] =
@@ -489,15 +661,17 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 
 void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 			  struct ieee80211_hdr *hdr, u8 *pdesc_tx,
-			  u8 *pbd_desc_tx, struct ieee80211_tx_info *info,
-			  struct ieee80211_sta *sta, struct sk_buff *skb,
+			  u8 *txbd, struct ieee80211_tx_info *info,
+			  struct ieee80211_sta *sta,
+			  struct sk_buff *skb,
 			  u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
+
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	u8 *pdesc = pdesc_tx;
+	u8 *pdesc = (u8 *)pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	unsigned int buf_len = 0;
@@ -547,8 +721,9 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 			if (ptcb_desc->empkt_num) {
 				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
 					 "Insert 8 byte.pTcb->EMPktNum:%d\n",
-					 ptcb_desc->empkt_num);
-				insert_em(ptcb_desc, (u8 *)(skb->data));
+					  ptcb_desc->empkt_num);
+				_rtl88ee_insert_emcontent(ptcb_desc,
+							  (u8 *)(skb->data));
 			}
 		} else {
 			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
@@ -560,6 +735,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 			short_gi = (ptcb_desc->use_shortgi) ? 1 : 0;
 		else
 			short_gi = (ptcb_desc->use_shortpreamble) ? 1 : 0;
+
 		SET_TX_DESC_DATA_SHORTGI(pdesc, short_gi);
 
 		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
@@ -568,7 +744,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 		}
 		SET_TX_DESC_SEQ(pdesc, seq_number);
 		SET_TX_DESC_RTS_ENABLE(pdesc, ((ptcb_desc->rts_enable &&
-					      !ptcb_desc->cts_enable) ? 1 : 0));
+						!ptcb_desc->cts_enable) ? 1 : 0));
 		SET_TX_DESC_HW_RTS_ENABLE(pdesc, 0);
 		SET_TX_DESC_CTS2SELF(pdesc, ((ptcb_desc->cts_enable) ? 1 : 0));
 		SET_TX_DESC_RTS_STBC(pdesc, ((ptcb_desc->rts_stbc) ? 1 : 0));
@@ -581,17 +757,17 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 			(ptcb_desc->rts_use_shortpreamble ? 1 : 0) :
 			(ptcb_desc->rts_use_shortgi ? 1 : 0)));
 
-		if (ptcb_desc->btx_enable_sw_calc_duration)
+		if (ptcb_desc->tx_enable_sw_calc_duration)
 			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
 
 		if (bw_40) {
-			if (ptcb_desc->packet_bw) {
+			if (ptcb_desc->packet_bw == HT_CHANNEL_WIDTH_20_40) {
 				SET_TX_DESC_DATA_BW(pdesc, 1);
 				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
 			} else {
 				SET_TX_DESC_DATA_BW(pdesc, 0);
 				SET_TX_DESC_TX_SUB_CARRIER(pdesc,
-						   mac->cur_40_prime_sc);
+							   mac->cur_40_prime_sc);
 			}
 		} else {
 			SET_TX_DESC_DATA_BW(pdesc, 0);
@@ -599,13 +775,14 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 		}
 
 		SET_TX_DESC_LINIP(pdesc, 0);
-		SET_TX_DESC_PKT_SIZE(pdesc, (u16) skb_len);
+		SET_TX_DESC_PKT_SIZE(pdesc, (u16)skb_len);
 		if (sta) {
 			u8 ampdu_density = sta->ht_cap.ampdu_density;
 			SET_TX_DESC_AMPDU_DENSITY(pdesc, ampdu_density);
 		}
 		if (info->control.hw_key) {
 			struct ieee80211_key_conf *keyconf;
+
 			keyconf = info->control.hw_key;
 			switch (keyconf->cipher) {
 			case WLAN_CIPHER_SUITE_WEP40:
@@ -619,6 +796,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 			default:
 				SET_TX_DESC_SEC_TYPE(pdesc, 0x0);
 				break;
+
 			}
 		}
 
@@ -629,6 +807,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 				       1 : 0);
 		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
 
+		/*SET_TX_DESC_PWR_STATUS(pdesc, pwr_status);*/
 		/* Set TxRate and RTSRate in TxDesc  */
 		/* This prevent Tx initial rate of new-coming packets */
 		/* from being overwritten by retried  packet rate.*/
@@ -639,7 +818,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 		if (ieee80211_is_data_qos(fc)) {
 			if (mac->rdg_en) {
 				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-					 "Enable RDG function.\n");
+					"Enable RDG function.\n");
 				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
 				SET_TX_DESC_HTC(pdesc, 1);
 			}
@@ -648,7 +827,7 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 
 	SET_TX_DESC_FIRST_SEG(pdesc, (firstseg ? 1 : 0));
 	SET_TX_DESC_LAST_SEG(pdesc, (lastseg ? 1 : 0));
-	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) buf_len);
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)buf_len);
 	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
 	if (rtlpriv->dm.useramask) {
 		SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
@@ -664,8 +843,9 @@ void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
 	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
 	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
-	    is_broadcast_ether_addr(ieee80211_get_DA(hdr)))
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
 		SET_TX_DESC_BMC(pdesc, 1);
+	}
 
 	rtl88e_dm_set_tx_ant_by_tx_info(hw, pdesc, ptcb_desc->mac_id);
 	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
@@ -733,8 +913,8 @@ void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
 		      pdesc, TX_DESC_SIZE);
 }
 
-void rtl88ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
-		      u8 desc_name, u8 *val)
+void rtl88ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+		      bool istx, u8 desc_name, u8 *val)
 {
 	if (istx == true) {
 		switch (desc_name) {
@@ -745,7 +925,7 @@ void rtl88ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *)val);
 			break;
 		default:
-			RT_ASSERT(false, "ERR txdesc :%d not processed\n",
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
 				  desc_name);
 			break;
 		}
@@ -764,7 +944,7 @@ void rtl88ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 			SET_RX_DESC_EOR(pdesc, 1);
 			break;
 		default:
-			RT_ASSERT(false, "ERR rxdesc :%d not processed\n",
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
 			break;
 		}
@@ -784,7 +964,7 @@ u32 rtl88ee_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 			ret = GET_TX_DESC_TX_BUFFER_ADDRESS(pdesc);
 			break;
 		default:
-			RT_ASSERT(false, "ERR txdesc :%d not processed\n",
+			RT_ASSERT(false, "ERR txdesc :%d not process\n",
 				  desc_name);
 			break;
 		}
@@ -796,8 +976,11 @@ u32 rtl88ee_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 		case HW_DESC_RXPKT_LEN:
 			ret = GET_RX_DESC_PKT_LEN(pdesc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret = GET_RX_DESC_BUFF_ADDR(pdesc);
+			break;
 		default:
-			RT_ASSERT(false, "ERR rxdesc :%d not processed\n",
+			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
 			break;
 		}
@@ -805,6 +988,22 @@ u32 rtl88ee_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 	return ret;
 }
 
+bool rtl88ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
+	u8 own = (u8)rtl88ee_get_desc(entry, true, HW_DESC_OWN);
+
+	/*beacon packet will only use the first
+	 *descriptor defautly,and the own may not
+	 *be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	return true;
+}
+
 void rtl88ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -815,3 +1014,10 @@ void rtl88ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 			       BIT(0) << (hw_queue));
 	}
 }
+
+u32 rtl88ee_rx_command_packet(struct ieee80211_hw *hw,
+			      struct rtl_stats status,
+			      struct sk_buff *skb)
+{
+	return 0;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
index 8c26094..eab5ae0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
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
@@ -30,59 +26,59 @@
 #ifndef __RTL92CE_TRX_H__
 #define __RTL92CE_TRX_H__
 
-#define TX_DESC_SIZE				64
+#define TX_DESC_SIZE					64
 #define TX_DESC_AGGR_SUBFRAME_SIZE		32
 
-#define RX_DESC_SIZE				32
+#define RX_DESC_SIZE					32
 #define RX_DRV_INFO_SIZE_UNIT			8
 
 #define	TX_DESC_NEXT_DESC_OFFSET		40
 #define USB_HWDESC_HEADER_LEN			32
-#define CRCLENGTH				4
+#define CRCLENGTH						4
 
 #define SET_TX_DESC_PKT_SIZE(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 16, __val)
-#define SET_TX_DESC_OFFSET(__pdesc, __val)		\
+#define SET_TX_DESC_OFFSET(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 16, 8, __val)
-#define SET_TX_DESC_BMC(__pdesc, __val)			\
+#define SET_TX_DESC_BMC(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 24, 1, __val)
-#define SET_TX_DESC_HTC(__pdesc, __val)			\
+#define SET_TX_DESC_HTC(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 25, 1, __val)
 #define SET_TX_DESC_LAST_SEG(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 26, 1, __val)
 #define SET_TX_DESC_FIRST_SEG(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 27, 1, __val)
-#define SET_TX_DESC_LINIP(__pdesc, __val)		\
+#define SET_TX_DESC_LINIP(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 28, 1, __val)
-#define SET_TX_DESC_NO_ACM(__pdesc, __val)		\
+#define SET_TX_DESC_NO_ACM(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 29, 1, __val)
-#define SET_TX_DESC_GF(__pdesc, __val)			\
+#define SET_TX_DESC_GF(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
-#define SET_TX_DESC_OWN(__pdesc, __val)			\
+#define SET_TX_DESC_OWN(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
 
-#define GET_TX_DESC_PKT_SIZE(__pdesc)			\
+#define GET_TX_DESC_PKT_SIZE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 0, 16)
-#define GET_TX_DESC_OFFSET(__pdesc)			\
+#define GET_TX_DESC_OFFSET(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 16, 8)
-#define GET_TX_DESC_BMC(__pdesc)			\
+#define GET_TX_DESC_BMC(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 24, 1)
-#define GET_TX_DESC_HTC(__pdesc)			\
+#define GET_TX_DESC_HTC(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 25, 1)
-#define GET_TX_DESC_LAST_SEG(__pdesc)			\
+#define GET_TX_DESC_LAST_SEG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
-#define GET_TX_DESC_FIRST_SEG(__pdesc)			\
+#define GET_TX_DESC_FIRST_SEG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
-#define GET_TX_DESC_LINIP(__pdesc)			\
+#define GET_TX_DESC_LINIP(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
-#define GET_TX_DESC_NO_ACM(__pdesc)			\
+#define GET_TX_DESC_NO_ACM(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
-#define GET_TX_DESC_GF(__pdesc)				\
+#define GET_TX_DESC_GF(__pdesc)						\
 	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
-#define GET_TX_DESC_OWN(__pdesc)			\
+#define GET_TX_DESC_OWN(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
 
-#define SET_TX_DESC_MACID(__pdesc, __val)		\
+#define SET_TX_DESC_MACID(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 6, __val)
 #define SET_TX_DESC_QUEUE_SEL(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 8, 5, __val)
@@ -90,11 +86,11 @@
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 13, 1, __val)
 #define SET_TX_DESC_LSIG_TXOP_EN(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 14, 1, __val)
-#define SET_TX_DESC_PIFS(__pdesc, __val)		\
+#define SET_TX_DESC_PIFS(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 15, 1, __val)
 #define SET_TX_DESC_RATE_ID(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 16, 4, __val)
-#define SET_TX_DESC_NAV_USE_HDR(__pdesc, __val)	\
+#define SET_TX_DESC_NAV_USE_HDR(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 20, 1, __val)
 #define SET_TX_DESC_EN_DESC_ID(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 21, 1, __val)
@@ -102,10 +98,10 @@
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 22, 2, __val)
 #define SET_TX_DESC_PKT_OFFSET(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 26, 5, __val)
-#define SET_TX_DESC_PADDING_LEN(__pdesc, __val)		\
+#define SET_TX_DESC_PADDING_LEN(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 24, 8, __val)
 
-#define GET_TX_DESC_MACID(__pdesc)				\
+#define GET_TX_DESC_MACID(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
 #define GET_TX_DESC_AGG_ENABLE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 5, 1)
@@ -119,7 +115,7 @@
 	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
 #define GET_TX_DESC_LSIG_TXOP_EN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
-#define GET_TX_DESC_PIFS(__pdesc)				\
+#define GET_TX_DESC_PIFS(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
 #define GET_TX_DESC_RATE_ID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
@@ -205,7 +201,6 @@
 #define SET_TX_DESC_HWSEQ_EN(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 31, 1, __val)
 
-
 #define GET_TX_DESC_NEXT_HEAP_PAGE(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+12, 0, 8)
 #define GET_TX_DESC_TAIL_PAGE(__pdesc)				\
@@ -213,7 +208,6 @@
 #define GET_TX_DESC_SEQ(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+12, 16, 12)
 
-
 #define SET_TX_DESC_RTS_RATE(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 5, __val)
 #define SET_TX_DESC_AP_DCFE(__pdesc, __val)		\
@@ -386,7 +380,6 @@
 #define GET_TX_DESC_TX_BUFFER_SIZE(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+28, 0, 16)
 
-
 #define SET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+32, 0, 32, __val)
 #define SET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc, __val) \
@@ -549,8 +542,10 @@ do {								\
 	 rxmcs == DESC92C_RATE5_5M ||\
 	 rxmcs == DESC92C_RATE11M)
 
+#define IS_LITTLE_ENDIAN	1
+
 struct phy_rx_agc_info_t {
-	#ifdef __LITTLE_ENDIAN
+	#if IS_LITTLE_ENDIAN
 		u8	gain:7, trsw:1;
 	#else
 		u8	trsw:1, gain:7;
@@ -562,7 +557,7 @@ struct phy_status_rpt {
 	u8	cck_sig_qual_ofdm_pwdb_all;
 	u8	cck_agc_rpt_ofdm_cfosho_a;
 	u8	cck_rpt_b_ofdm_cfosho_b;
-	u8	rsvd_1;
+	u8	rsvd_1;/* ch_corr_msb; */
 	u8	noise_power_db_msb;
 	u8	path_cfotail[2];
 	u8	pcts_mask[2];
@@ -574,7 +569,7 @@ struct phy_status_rpt {
 	u8	stream_target_csi[2];
 	u8	sig_evm;
 	u8	rsvd_3;
-#ifdef __LITTLE_ENDIAN
+#if IS_LITTLE_ENDIAN
 	u8	antsel_rx_keep_2:1;	/*ex_intf_flg:1;*/
 	u8	sgi_en:1;
 	u8	rxsc:2;
@@ -777,19 +772,25 @@ struct rx_desc_88e {
 
 void rtl88ee_tx_fill_desc(struct ieee80211_hw *hw,
 			  struct ieee80211_hdr *hdr, u8 *pdesc_tx,
-			  u8 *pbd_desc_tx, struct ieee80211_tx_info *info,
-			  struct ieee80211_sta *sta, struct sk_buff *skb,
+			  u8 *txbd, struct ieee80211_tx_info *info,
+			  struct ieee80211_sta *sta,
+			  struct sk_buff *skb,
 			  u8 hw_queue, struct rtl_tcb_desc *ptcb_desc);
 bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 			   struct rtl_stats *status,
 			   struct ieee80211_rx_status *rx_status,
 			   u8 *pdesc, struct sk_buff *skb);
-void rtl88ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
-		      u8 desc_name, u8 *val);
+void rtl88ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+		      bool istx, u8 desc_name, u8 *val);
 u32 rtl88ee_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl88ee_is_tx_desc_closed(struct ieee80211_hw *hw,
+			       u8 hw_queue, u16 index);
 void rtl88ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
 void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
-			     bool b_firstseg, bool b_lastseg,
+			     bool firstseg, bool lastseg,
 			     struct sk_buff *skb);
+u32 rtl88ee_rx_command_packet(struct ieee80211_hw *hw,
+			      struct rtl_stats status,
+			      struct sk_buff *skb);
 
 #endif
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
 
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
index 969eaea..557b416 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/trx.c
@@ -732,7 +732,7 @@ void rtl8723be_tx_fill_desc(struct ieee80211_hw *hw,
 			 (ptcb_desc->rts_use_shortpreamble ? 1 : 0) :
 			 (ptcb_desc->rts_use_shortgi ? 1 : 0)));
 
-		if (ptcb_desc->btx_enable_sw_calc_duration)
+		if (ptcb_desc->tx_enable_sw_calc_duration)
 			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
 
 		if (bw_40) {
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index af7c6f2..06b5741 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1160,6 +1160,8 @@ struct rtl_phy {
 
 	u8 pwrgroup_cnt;
 	u8 cck_high_power;
+	/* this is for 88E & 8723A */
+	u32 mcs_txpwrlevel_origoffset[MAX_PG_GROUP][16];
 	/* MAX_PG_GROUP groups of pwr diff by rates */
 	u32 mcs_offset[MAX_PG_GROUP][16];
 	u32 tx_power_by_rate_offset[TX_PWR_BY_RATE_NUM_BAND]
@@ -1890,6 +1892,7 @@ struct rtl_stats {
 	bool rx_is40Mhzpacket;
 	u32 rx_pwdb_all;
 	u8 rx_mimo_signalstrength[4];	/*in 0~100 index */
+	s8 rx_mimo_signalquality[4];
 	u8 rx_mimo_evm_dbm[4];
 	u16 cfo_short[4];		/* per-path's Cfo_short */
 	u16 cfo_tail[4];
@@ -1966,7 +1969,7 @@ struct rtl_tcb_desc {
 	u8 empkt_num;
 	/* The max value by HW */
 	u32 empkt_len[10];
-	bool btx_enable_sw_calc_duration;
+	bool tx_enable_sw_calc_duration;
 };
 
 struct rtl92c_firmware_header;
-- 
1.8.4.5
