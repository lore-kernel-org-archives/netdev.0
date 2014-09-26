From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/7 NEXT] rtlwifi: rtl8723ae: Update driver to match 06/28/14 Realtek version
Date: Fri, 26 Sep 2014 16:40:24 -0500
Message-ID: <1411767628-7965-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54833 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344AbaIZVkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:40:51 -0400
In-Reply-To: <1411767628-7965-1-git-send-email-Larry.Finger@lwfinger.net>
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
 drivers/net/wireless/rtlwifi/pci.c                 |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |   13 -
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h        |   12 -
 drivers/net/wireless/rtlwifi/rtl8192se/fw.h        |    1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h       |    7 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |  197 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  422 ++-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |   50 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  254 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |   55 +-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |  414 ++-
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h    |   38 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   | 1232 +++++----
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |   66 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 1512 ++++++-----
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   66 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |   54 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h       |   13 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |  894 ++++---
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |   67 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |   91 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  543 ++--
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       | 2718 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c        |  261 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  220 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h        |   12 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/table.c     |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/table.h     |    8 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  458 +++-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |  325 +--
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c        |    2 +-
 .../net/wireless/rtlwifi/rtl8723com/dm_common.c    |   14 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.c    |   84 +-
 .../net/wireless/rtlwifi/rtl8723com/fw_common.h    |   39 +-
 .../net/wireless/rtlwifi/rtl8723com/phy_common.c   |   46 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   19 +-
 38 files changed, 5403 insertions(+), 4836 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 37a78bf..1dbb22b 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -952,10 +952,8 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 	rtlpriv->cfg->ops->interrupt_recognized(hw, &inta, &intb);
 
 	/*Shared IRQ or HW disappared */
-	if (!inta || inta == 0xffff) {
-		ret = IRQ_NONE;
+	if (!inta || inta == 0xffff)
 		goto done;
-	}
 
 	/*<1> beacon related */
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_TBDOK]) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
index 15b2055..695a3bd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h
@@ -60,19 +60,6 @@ struct rtl92c_firmware_header {
 	__le32 rsvd5;
 };
 
-enum rtl8192c_h2c_cmd {
-	H2C_AP_OFFLOAD = 0,
-	H2C_SETPWRMODE = 1,
-	H2C_JOINBSSRPT = 2,
-	H2C_RSVDPAGE = 3,
-	H2C_RSSI_REPORT = 5,
-	H2C_RA_MASK = 6,
-	H2C_MACID_PS_MODE = 7,
-	H2C_P2P_PS_OFFLOAD = 8,
-	H2C_P2P_PS_CTW_CMD = 32,
-	MAX_H2CCMD
-};
-
 #define pagenum_128(_len)	(u32)(((_len)>>7) + ((_len)&0x7F ? 1 : 0))
 
 #define SET_H2CCMD_PWRMODE_PARM_MODE(__ph2ccmd, __val)			\
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.h b/drivers/net/wireless/rtlwifi/rtl8192de/fw.h
index 1ffacdd..a55a803 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.h
@@ -132,18 +132,6 @@ struct rtl92d_firmware_header {
 	u32 rsvd5;
 };
 
-enum rtl8192d_h2c_cmd {
-	H2C_AP_OFFLOAD = 0,
-	H2C_SETPWRMODE = 1,
-	H2C_JOINBSSRPT = 2,
-	H2C_RSVDPAGE = 3,
-	H2C_RSSI_REPORT = 5,
-	H2C_RA_MASK = 6,
-	H2C_MAC_MODE_SEL = 9,
-	H2C_PWRM = 15,
-	MAX_H2CCMD
-};
-
 int rtl92d_download_fw(struct ieee80211_hw *hw);
 void rtl92d_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
 			 u32 cmd_len, u8 *p_cmdbuffer);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
index d53f433..b1e44b8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.h
@@ -336,7 +336,6 @@ enum fw_h2c_cmd {
 	H2C_TMP3,
 	H2C_WOWLAN_UPDATE_IV_CMD,			/*50*/
 	H2C_TMP4,
-	MAX_H2CCMD					/*52*/
 };
 
 /* The following macros are used for FW
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/btc.h b/drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
index 417afee..06c448c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
@@ -11,10 +11,6 @@
  ** FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  ** more details.
  **
- ** You should have received a copy of the GNU General Public License along with
- ** this program; if not, write to the Free Software Foundation, Inc.,
- ** 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- **
  ** The full GNU General Public License is included in this distribution in the
  ** file called LICENSE.
  **
@@ -24,8 +20,7 @@
  ** Hsinchu 300, Taiwan.
  ** Larry Finger <Larry.Finger@lwfinger.net>
  **
- *****************************************************************************
- */
+ ******************************************************************************/
 
 #ifndef __RTL8723E_BTC_H__
 #define __RTL8723E_BTC_H__
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/def.h b/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
index debe261..94bdd4b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
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
@@ -25,55 +21,145 @@
  *
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 
 #ifndef __RTL8723E_DEF_H__
 #define __RTL8723E_DEF_H__
 
+#define HAL_RETRY_LIMIT_INFRA				48
+#define HAL_RETRY_LIMIT_AP_ADHOC			7
+
+#define RESET_DELAY_8185					20
+
+#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
+#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
+
+#define NUM_OF_FIRMWARE_QUEUE				10
+#define NUM_OF_PAGES_IN_FW					0x100
+#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA		0x0
+#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
+#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT		0x02
+#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH		0x02
+#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
+#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
+
+#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM		0x026
+#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM		0x048
+#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM		0x048
+#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM		0x026
+#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM		0x00
+
+#define MAX_LINES_HWCONFIG_TXT				1000
+#define MAX_BYTES_LINE_HWCONFIG_TXT			256
+
+#define SW_THREE_WIRE						0
+#define HW_THREE_WIRE						2
+
+#define BT_DEMO_BOARD						0
+#define BT_QA_BOARD							1
+#define BT_FPGA								2
+
+#define HAL_PRIME_CHNL_OFFSET_DONT_CARE		0
 #define HAL_PRIME_CHNL_OFFSET_LOWER			1
+#define HAL_PRIME_CHNL_OFFSET_UPPER			2
 
-#define RX_MPDU_QUEUE					0
+#define MAX_H2C_QUEUE_NUM					10
 
-#define CHIP_8723			BIT(0)
-#define NORMAL_CHIP			BIT(3)
-#define RF_TYPE_1T2R			BIT(4)
-#define RF_TYPE_2T2R			BIT(5)
-#define CHIP_VENDOR_UMC			BIT(7)
-#define B_CUT_VERSION			BIT(12)
-#define C_CUT_VERSION			BIT(13)
-#define D_CUT_VERSION			((BIT(12)|BIT(13)))
-#define E_CUT_VERSION			BIT(14)
-#define	RF_RL_ID			(BIT(31)|BIT(30)|BIT(29)|BIT(28))
+#define RX_MPDU_QUEUE						0
+#define RX_CMD_QUEUE						1
+#define RX_MAX_QUEUE						2
+#define AC2QUEUEID(_AC)						(_AC)
 
+#define	C2H_RX_CMD_HDR_LEN					8
+#define	GET_C2H_CMD_CMD_LEN(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 0, 16)
+#define	GET_C2H_CMD_ELEMENT_ID(__prxhdr)	\
+	LE_BITS_TO_4BYTE((__prxhdr), 16, 8)
+#define	GET_C2H_CMD_CMD_SEQ(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 24, 7)
+#define	GET_C2H_CMD_CONTINUE(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 31, 1)
+#define	GET_C2H_CMD_CONTENT(__prxhdr)		\
+	((u8 *)(__prxhdr) + C2H_RX_CMD_HDR_LEN)
+
+#define	GET_C2H_CMD_FEEDBACK_ELEMENT_ID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 0, 8)
+#define	GET_C2H_CMD_FEEDBACK_CCX_LEN(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 8, 8)
+#define	GET_C2H_CMD_FEEDBACK_CCX_CMD_CNT(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 16, 16)
+#define	GET_C2H_CMD_FEEDBACK_CCX_MAC_ID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 0, 5)
+#define	GET_C2H_CMD_FEEDBACK_CCX_VALID(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 7, 1)
+#define	GET_C2H_CMD_FEEDBACK_CCX_RETRY_CNT(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 8, 5)
+#define	GET_C2H_CMD_FEEDBACK_CCX_TOK(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 15, 1)
+#define	GET_C2H_CMD_FEEDBACK_CCX_QSEL(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 16, 4)
+#define	GET_C2H_CMD_FEEDBACK_CCX_SEQ(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
+
+#define CHIP_BONDING_IDENTIFIER(_value)	(((_value)>>22)&0x3)
+#define	CHIP_BONDING_92C_1T2R		0x1
+
+#define CHIP_8723		BIT(0)
+#define NORMAL_CHIP		BIT(3)
+#define RF_TYPE_1T1R		(~(BIT(4)|BIT(5)|BIT(6)))
+#define RF_TYPE_1T2R		BIT(4)
+#define RF_TYPE_2T2R		BIT(5)
+#define CHIP_VENDOR_UMC		BIT(7)
+#define B_CUT_VERSION		BIT(12)
+#define C_CUT_VERSION		BIT(13)
+#define D_CUT_VERSION		((BIT(12)|BIT(13)))
+#define E_CUT_VERSION		BIT(14)
+#define	RF_RL_ID		(BIT(31)|BIT(30)|BIT(29)|BIT(28))
 
 /* MASK */
-#define IC_TYPE_MASK			(BIT(0)|BIT(1)|BIT(2))
-#define CHIP_TYPE_MASK			BIT(3)
-#define RF_TYPE_MASK			(BIT(4)|BIT(5)|BIT(6))
-#define MANUFACTUER_MASK		BIT(7)
-#define ROM_VERSION_MASK		(BIT(11)|BIT(10)|BIT(9)|BIT(8))
-#define CUT_VERSION_MASK		(BIT(15)|BIT(14)|BIT(13)|BIT(12))
+#define IC_TYPE_MASK		(BIT(0)|BIT(1)|BIT(2))
+#define CHIP_TYPE_MASK		BIT(3)
+#define RF_TYPE_MASK		(BIT(4)|BIT(5)|BIT(6))
+#define MANUFACTUER_MASK	BIT(7)
+#define ROM_VERSION_MASK	(BIT(11)|BIT(10)|BIT(9)|BIT(8))
+#define CUT_VERSION_MASK	(BIT(15)|BIT(14)|BIT(13)|BIT(12))
 
 /* Get element */
 #define GET_CVID_IC_TYPE(version)	((version) & IC_TYPE_MASK)
+#define GET_CVID_CHIP_TYPE(version)	((version) & CHIP_TYPE_MASK)
+#define GET_CVID_RF_TYPE(version)	((version) & RF_TYPE_MASK)
 #define GET_CVID_MANUFACTUER(version)	((version) & MANUFACTUER_MASK)
+#define GET_CVID_ROM_VERSION(version)	((version) & ROM_VERSION_MASK)
 #define GET_CVID_CUT_VERSION(version)	((version) & CUT_VERSION_MASK)
 
-#define IS_81XXC(version)		((GET_CVID_IC_TYPE(version) == 0) ?\
-					true : false)
-#define IS_8723_SERIES(version)						\
-		((GET_CVID_IC_TYPE(version) == CHIP_8723) ? true : false)
-#define IS_CHIP_VENDOR_UMC(version)					\
-		((GET_CVID_MANUFACTUER(version)) ? true : false)
-
-#define IS_VENDOR_UMC_A_CUT(version)	((IS_CHIP_VENDOR_UMC(version)) ? \
-		((GET_CVID_CUT_VERSION(version)) ? false : true) : false)
-#define IS_VENDOR_8723_A_CUT(version)	((IS_8723_SERIES(version)) ?	\
-		((GET_CVID_CUT_VERSION(version)) ? false : true) : false)
-#define IS_81xxC_VENDOR_UMC_B_CUT(version)	((IS_CHIP_VENDOR_UMC(version)) \
-		? ((GET_CVID_CUT_VERSION(version) == B_CUT_VERSION) ? \
-		true : false) : false)
+#define IS_81XXC(version)	((GET_CVID_IC_TYPE(version) == 0) ?\
+						true : false)
+#define IS_8723_SERIES(version)	((GET_CVID_IC_TYPE(version) == CHIP_8723) ? \
+						true : false)
+#define IS_1T1R(version)	((GET_CVID_RF_TYPE(version)) ? false : true)
+#define IS_1T2R(version)	((GET_CVID_RF_TYPE(version) == RF_TYPE_1T2R)\
+						? true : false)
+#define IS_2T2R(version)	((GET_CVID_RF_TYPE(version) == RF_TYPE_2T2R)\
+						? true : false)
+#define IS_CHIP_VENDOR_UMC(version)	((GET_CVID_MANUFACTUER(version)) ? \
+						true : false)
+
+#define IS_VENDOR_UMC_A_CUT(version)	((IS_CHIP_VENDOR_UMC(version))\
+					? ((GET_CVID_CUT_VERSION(version)) ? \
+					false : true) : false)
+#define IS_VENDOR_8723_A_CUT(version)	((IS_8723_SERIES(version))\
+					? ((GET_CVID_CUT_VERSION(version)) ? \
+					false : true) : false)
+#define IS_VENDOR_8723A_B_CUT(version)	((IS_8723_SERIES(version))\
+		? ((GET_CVID_CUT_VERSION(version) == \
+		B_CUT_VERSION) ? true : false) : false)
+#define IS_81xxC_VENDOR_UMC_B_CUT(version)	((IS_CHIP_VENDOR_UMC(version))\
+		? ((GET_CVID_CUT_VERSION(version) == \
+		B_CUT_VERSION) ? true : false) : false)
 
 enum rf_optype {
 	RF_OP_BY_SW_3WIRE = 0,
@@ -93,7 +179,7 @@ enum power_save_mode {
 	POWER_SAVE_MODE_SAVE,
 };
 
-enum power_polocy_config {
+enum power_policy_config {
 	POWERCFG_MAX_POWER_SAVINGS,
 	POWERCFG_GLOBAL_POWER_SAVINGS,
 	POWERCFG_LOCAL_POWER_SAVINGS,
@@ -143,6 +229,41 @@ enum rtl_desc_qsel {
 	QSLT_CMD = 0x13,
 };
 
+enum rtl_desc8723e_rate {
+	DESC92C_RATE1M = 0x00,
+	DESC92C_RATE2M = 0x01,
+	DESC92C_RATE5_5M = 0x02,
+	DESC92C_RATE11M = 0x03,
+
+	DESC92C_RATE6M = 0x04,
+	DESC92C_RATE9M = 0x05,
+	DESC92C_RATE12M = 0x06,
+	DESC92C_RATE18M = 0x07,
+	DESC92C_RATE24M = 0x08,
+	DESC92C_RATE36M = 0x09,
+	DESC92C_RATE48M = 0x0a,
+	DESC92C_RATE54M = 0x0b,
+
+	DESC92C_RATEMCS0 = 0x0c,
+	DESC92C_RATEMCS1 = 0x0d,
+	DESC92C_RATEMCS2 = 0x0e,
+	DESC92C_RATEMCS3 = 0x0f,
+	DESC92C_RATEMCS4 = 0x10,
+	DESC92C_RATEMCS5 = 0x11,
+	DESC92C_RATEMCS6 = 0x12,
+	DESC92C_RATEMCS7 = 0x13,
+	DESC92C_RATEMCS8 = 0x14,
+	DESC92C_RATEMCS9 = 0x15,
+	DESC92C_RATEMCS10 = 0x16,
+	DESC92C_RATEMCS11 = 0x17,
+	DESC92C_RATEMCS12 = 0x18,
+	DESC92C_RATEMCS13 = 0x19,
+	DESC92C_RATEMCS14 = 0x1a,
+	DESC92C_RATEMCS15 = 0x1b,
+	DESC92C_RATEMCS15_SG = 0x1c,
+	DESC92C_RATEMCS32 = 0x20,
+};
+
 struct phy_sts_cck_8723e_t {
 	u8 adc_pwdb_X[4];
 	u8 sq_rpt;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
index 25cc830..a0e8692 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
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
@@ -25,8 +21,7 @@
  *
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 
 #include "../wifi.h"
 #include "../base.h"
@@ -151,7 +146,7 @@ static const u8 cckswing_table_ch14[CCK_TABLE_SIZE][8] = {
 	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}
 };
 
-static void rtl8723ae_dm_diginit(struct ieee80211_hw *hw)
+static void rtl8723e_dm_diginit(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
@@ -176,7 +171,7 @@ static void rtl8723ae_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
 }
 
-static u8 rtl_init_gain_min_pwdb(struct ieee80211_hw *hw)
+static u8 rtl8723e_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
@@ -195,14 +190,15 @@ static u8 rtl_init_gain_min_pwdb(struct ieee80211_hw *hw)
 	} else if (dm_digtable->cursta_cstate == DIG_STA_CONNECT ||
 		   dm_digtable->cursta_cstate == DIG_STA_BEFORE_CONNECT) {
 		rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
-	} else if (dm_digtable->curmultista_cstate == DIG_MULTISTA_CONNECT) {
+	} else if (dm_digtable->curmultista_cstate ==
+		DIG_MULTISTA_CONNECT) {
 		rssi_val_min = rtlpriv->dm.entry_min_undec_sm_pwdb;
 	}
 
 	return (u8) rssi_val_min;
 }
 
-static void rtl8723ae_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
+static void rtl8723e_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 {
 	u32 ret_value;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -239,8 +235,7 @@ static void rtl8723ae_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, 0x0000c000, 2);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, "
-		 "cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
+		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
 		 falsealm_cnt->cnt_parity_fail,
 		 falsealm_cnt->cnt_rate_illegal,
 		 falsealm_cnt->cnt_crc8_fail, falsealm_cnt->cnt_mcs_fail);
@@ -263,52 +258,60 @@ static void rtl92c_dm_ctrl_initgain_by_fa(struct ieee80211_hw *hw)
 		value_igi += 0;
 	else if (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH2)
 		value_igi++;
-	else
+	else if (rtlpriv->falsealm_cnt.cnt_all >= DM_DIG_FA_TH2)
 		value_igi += 2;
-
-	value_igi = clamp(value_igi, (u8)DM_DIG_FA_LOWER, (u8)DM_DIG_FA_UPPER);
+	if (value_igi > DM_DIG_FA_UPPER)
+		value_igi = DM_DIG_FA_UPPER;
+	else if (value_igi < DM_DIG_FA_LOWER)
+		value_igi = DM_DIG_FA_LOWER;
 	if (rtlpriv->falsealm_cnt.cnt_all > 10000)
 		value_igi = 0x32;
 
 	dm_digtable->cur_igvalue = value_igi;
-	rtl8723ae_dm_write_dig(hw);
+	rtl8723e_dm_write_dig(hw);
 }
 
 static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dgtbl = &rtlpriv->dm_digtable;
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
-	if (rtlpriv->falsealm_cnt.cnt_all > dgtbl->fa_highthresh) {
-		if ((dgtbl->back_val - 2) < dgtbl->back_range_min)
-			dgtbl->back_val = dgtbl->back_range_min;
+	if (rtlpriv->falsealm_cnt.cnt_all > dm_digtable->fa_highthresh) {
+		if ((dm_digtable->back_val - 2) <
+		    dm_digtable->back_range_min)
+			dm_digtable->back_val =
+			    dm_digtable->back_range_min;
 		else
-			dgtbl->back_val -= 2;
-	} else if (rtlpriv->falsealm_cnt.cnt_all < dgtbl->fa_lowthresh) {
-		if ((dgtbl->back_val + 2) > dgtbl->back_range_max)
-			dgtbl->back_val = dgtbl->back_range_max;
+			dm_digtable->back_val -= 2;
+	} else if (rtlpriv->falsealm_cnt.cnt_all < dm_digtable->fa_lowthresh) {
+		if ((dm_digtable->back_val + 2) >
+		    dm_digtable->back_range_max)
+			dm_digtable->back_val =
+			    dm_digtable->back_range_max;
 		else
-			dgtbl->back_val += 2;
+			dm_digtable->back_val += 2;
 	}
 
-	if ((dgtbl->rssi_val_min + 10 - dgtbl->back_val) >
-	    dgtbl->rx_gain_max)
-		dgtbl->cur_igvalue = dgtbl->rx_gain_max;
-	else if ((dgtbl->rssi_val_min + 10 -
-		  dgtbl->back_val) < dgtbl->rx_gain_min)
-		dgtbl->cur_igvalue = dgtbl->rx_gain_min;
+	if ((dm_digtable->rssi_val_min + 10 - dm_digtable->back_val) >
+	    dm_digtable->rx_gain_max)
+		dm_digtable->cur_igvalue = dm_digtable->rx_gain_max;
+	else if ((dm_digtable->rssi_val_min + 10 -
+		  dm_digtable->back_val) < dm_digtable->rx_gain_min)
+		dm_digtable->cur_igvalue = dm_digtable->rx_gain_min;
 	else
-		dgtbl->cur_igvalue = dgtbl->rssi_val_min + 10 - dgtbl->back_val;
+		dm_digtable->cur_igvalue = dm_digtable->rssi_val_min + 10 -
+		    dm_digtable->back_val;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
 		 "rssi_val_min = %x back_val %x\n",
-		 dgtbl->rssi_val_min, dgtbl->back_val);
+		  dm_digtable->rssi_val_min, dm_digtable->back_val);
 
-	rtl8723ae_dm_write_dig(hw);
+	rtl8723e_dm_write_dig(hw);
 }
 
-static void rtl8723ae_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
+static void rtl8723e_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 {
+	static u8 binitialized;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
@@ -318,16 +321,15 @@ static void rtl8723ae_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 	if (mac->opmode == NL80211_IFTYPE_ADHOC)
 		multi_sta = true;
 
-	if ((!multi_sta) ||
-	    (dm_digtable->cursta_cstate != DIG_STA_DISCONNECT)) {
-		rtlpriv->initialized = false;
+	if (!multi_sta || (dm_digtable->cursta_cstate != DIG_STA_DISCONNECT)) {
+		binitialized = false;
 		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 		return;
-	} else if (!rtlpriv->initialized) {
-		rtlpriv->initialized = true;
+	} else if (!binitialized) {
+		binitialized = true;
 		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_0;
 		dm_digtable->cur_igvalue = 0x20;
-		rtl8723ae_dm_write_dig(hw);
+		rtl8723e_dm_write_dig(hw);
 	}
 
 	if (dm_digtable->curmultista_cstate == DIG_MULTISTA_CONNECT) {
@@ -337,7 +339,7 @@ static void rtl8723ae_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 			if (dm_digtable->dig_ext_port_stage ==
 			    DIG_EXT_PORT_STAGE_2) {
 				dm_digtable->cur_igvalue = 0x20;
-				rtl8723ae_dm_write_dig(hw);
+				rtl8723e_dm_write_dig(hw);
 			}
 
 			dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_1;
@@ -348,7 +350,7 @@ static void rtl8723ae_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 	} else if (dm_digtable->dig_ext_port_stage != DIG_EXT_PORT_STAGE_0) {
 		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_0;
 		dm_digtable->cur_igvalue = 0x20;
-		rtl8723ae_dm_write_dig(hw);
+		rtl8723e_dm_write_dig(hw);
 	}
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
@@ -357,22 +359,22 @@ static void rtl8723ae_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 		 dm_digtable->dig_ext_port_stage);
 }
 
-static void rtl8723ae_dm_initial_gain_sta(struct ieee80211_hw *hw)
+static void rtl8723e_dm_initial_gain_sta(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
 		 "presta_cstate = %x, cursta_cstate = %x\n",
-		 dm_digtable->presta_cstate,
-		 dm_digtable->cursta_cstate);
+		  dm_digtable->presta_cstate,
+		  dm_digtable->cursta_cstate);
 
 	if (dm_digtable->presta_cstate == dm_digtable->cursta_cstate ||
 	    dm_digtable->cursta_cstate == DIG_STA_BEFORE_CONNECT ||
 	    dm_digtable->cursta_cstate == DIG_STA_CONNECT) {
-
 		if (dm_digtable->cursta_cstate != DIG_STA_DISCONNECT) {
-			dm_digtable->rssi_val_min = rtl_init_gain_min_pwdb(hw);
+			dm_digtable->rssi_val_min =
+			    rtl8723e_dm_initial_gain_min_pwdb(hw);
 			rtl92c_dm_ctrl_initgain_by_rssi(hw);
 		}
 	} else {
@@ -381,16 +383,17 @@ static void rtl8723ae_dm_initial_gain_sta(struct ieee80211_hw *hw)
 		dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
 		dm_digtable->cur_igvalue = 0x20;
 		dm_digtable->pre_igvalue = 0;
-		rtl8723ae_dm_write_dig(hw);
+		rtl8723e_dm_write_dig(hw);
 	}
 }
-static void rtl8723ae_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
+
+static void rtl8723e_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	if (dm_digtable->cursta_cstate == DIG_STA_CONNECT) {
-		dm_digtable->rssi_val_min = rtl_init_gain_min_pwdb(hw);
+		dm_digtable->rssi_val_min = rtl8723e_dm_initial_gain_min_pwdb(hw);
 
 		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LowRssi) {
 			if (dm_digtable->rssi_val_min <= 25)
@@ -418,12 +421,11 @@ static void rtl8723ae_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 				    CCK_FA_STAGE_High;
 			else
 				dm_digtable->cur_cck_fa_state =
-							 CCK_FA_STAGE_Low;
-
+				    CCK_FA_STAGE_LOW;
 			if (dm_digtable->pre_cck_fa_state !=
 			    dm_digtable->cur_cck_fa_state) {
 				if (dm_digtable->cur_cck_fa_state ==
-				    CCK_FA_STAGE_Low)
+				    CCK_FA_STAGE_LOW)
 					rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2,
 						      0x83);
 				else
@@ -449,13 +451,13 @@ static void rtl8723ae_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 
 }
 
-static void rtl8723ae_dm_ctrl_initgain_by_twoport(struct ieee80211_hw *hw)
+static void rtl8723e_dm_ctrl_initgain_by_twoport(struct ieee80211_hw *hw)
 {
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
-	if (mac->act_scanning == true)
+	if (mac->act_scanning)
 		return;
 
 	if (mac->link_state >= MAC80211_LINKED)
@@ -463,28 +465,29 @@ static void rtl8723ae_dm_ctrl_initgain_by_twoport(struct ieee80211_hw *hw)
 	else
 		dm_digtable->cursta_cstate = DIG_STA_DISCONNECT;
 
-	rtl8723ae_dm_initial_gain_sta(hw);
-	rtl8723ae_dm_initial_gain_multi_sta(hw);
-	rtl8723ae_dm_cck_packet_detection_thresh(hw);
+	rtl8723e_dm_initial_gain_sta(hw);
+	rtl8723e_dm_initial_gain_multi_sta(hw);
+	rtl8723e_dm_cck_packet_detection_thresh(hw);
 
 	dm_digtable->presta_cstate = dm_digtable->cursta_cstate;
 
 }
 
-static void rtl8723ae_dm_dig(struct ieee80211_hw *hw)
+static void rtl8723e_dm_dig(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
-	if (rtlpriv->dm.dm_initialgain_enable == false)
+	if (!rtlpriv->dm.dm_initialgain_enable)
 		return;
-	if (dm_digtable->dig_enable_flag == false)
+	if (!dm_digtable->dig_enable_flag)
 		return;
 
-	rtl8723ae_dm_ctrl_initgain_by_twoport(hw);
+	rtl8723e_dm_ctrl_initgain_by_twoport(hw);
+
 }
 
-static void rtl8723ae_dm_dynamic_txpower(struct ieee80211_hw *hw)
+static void rtl8723e_dm_dynamic_txpower(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
@@ -502,7 +505,7 @@ static void rtl8723ae_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 "Not connected\n");
+			 "Not connected to any\n");
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 
@@ -512,18 +515,21 @@ static void rtl8723ae_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
+			undec_sm_pwdb =
+			    rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 undec_sm_pwdb);
+				  undec_sm_pwdb);
 		} else {
-			undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
+			undec_sm_pwdb =
+			    rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 undec_sm_pwdb);
+				  undec_sm_pwdb);
 		}
 	} else {
-		undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
+		undec_sm_pwdb =
+		    rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
@@ -534,37 +540,39 @@ static void rtl8723ae_dm_dynamic_txpower(struct ieee80211_hw *hw)
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
-	} else if ((undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
-		   (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
+	} else if ((undec_sm_pwdb <
+		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
+		   (undec_sm_pwdb >=
+		    TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
-	} else if (undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
+	} else if (undec_sm_pwdb <
+		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_NORMAL\n");
 	}
 
-	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
+	if (rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
 			  rtlphy->current_channel);
-		rtl8723ae_phy_set_txpower_level(hw, rtlphy->current_channel);
+		rtl8723e_phy_set_txpower_level(hw, rtlphy->current_channel);
 	}
 
 	rtlpriv->dm.last_dtp_lvl = rtlpriv->dm.dynamic_txhighpower_lvl;
 }
 
-void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw)
+void rtl8723e_dm_write_dig(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 "cur_igvalue = 0x%x, "
-		 "pre_igvalue = 0x%x, back_val = %d\n",
-		 dm_digtable->cur_igvalue, dm_digtable->pre_igvalue,
-		 dm_digtable->back_val);
+		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, back_val = %d\n",
+		  dm_digtable->cur_igvalue, dm_digtable->pre_igvalue,
+		  dm_digtable->back_val);
 
 	if (dm_digtable->pre_igvalue != dm_digtable->cur_igvalue) {
 		rtl_set_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f,
@@ -576,32 +584,39 @@ void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw)
 	}
 }
 
-static void rtl8723ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
+static void rtl8723e_dm_pwdb_monitor(struct ieee80211_hw *hw)
+{
+}
+
+static void rtl8723e_dm_check_edca_turbo(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
+	static u64 last_txok_cnt;
+	static u64 last_rxok_cnt;
+	static u32 last_bt_edca_ul;
+	static u32 last_bt_edca_dl;
 	u64 cur_txok_cnt = 0;
 	u64 cur_rxok_cnt = 0;
 	u32 edca_be_ul = 0x5ea42b;
 	u32 edca_be_dl = 0x5ea42b;
 	bool bt_change_edca = false;
 
-	if ((mac->last_bt_edca_ul != rtlpcipriv->bt_coexist.bt_edca_ul) ||
-	    (mac->last_bt_edca_dl != rtlpcipriv->bt_coexist.bt_edca_dl)) {
+	if ((last_bt_edca_ul != rtlpriv->btcoexist.bt_edca_ul) ||
+	    (last_bt_edca_dl != rtlpriv->btcoexist.bt_edca_dl)) {
 		rtlpriv->dm.current_turbo_edca = false;
-		mac->last_bt_edca_ul = rtlpcipriv->bt_coexist.bt_edca_ul;
-		mac->last_bt_edca_dl = rtlpcipriv->bt_coexist.bt_edca_dl;
+		last_bt_edca_ul = rtlpriv->btcoexist.bt_edca_ul;
+		last_bt_edca_dl = rtlpriv->btcoexist.bt_edca_dl;
 	}
 
-	if (rtlpcipriv->bt_coexist.bt_edca_ul != 0) {
-		edca_be_ul = rtlpcipriv->bt_coexist.bt_edca_ul;
+	if (rtlpriv->btcoexist.bt_edca_ul != 0) {
+		edca_be_ul = rtlpriv->btcoexist.bt_edca_ul;
 		bt_change_edca = true;
 	}
 
-	if (rtlpcipriv->bt_coexist.bt_edca_dl != 0) {
-		edca_be_ul = rtlpcipriv->bt_coexist.bt_edca_dl;
+	if (rtlpriv->btcoexist.bt_edca_dl != 0) {
+		edca_be_ul = rtlpriv->btcoexist.bt_edca_dl;
 		bt_change_edca = true;
 	}
 
@@ -609,22 +624,11 @@ static void rtl8723ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
 		rtlpriv->dm.current_turbo_edca = false;
 		return;
 	}
-
-	if ((!mac->ht_enable) && (!rtlpcipriv->bt_coexist.bt_coexistence)) {
-		if (!(edca_be_ul & 0xffff0000))
-			edca_be_ul |= 0x005e0000;
-
-		if (!(edca_be_dl & 0xffff0000))
-			edca_be_dl |= 0x005e0000;
-	}
-
 	if ((bt_change_edca) || ((!rtlpriv->dm.is_any_nonbepkts) &&
 	     (!rtlpriv->dm.disable_framebursting))) {
 
-		cur_txok_cnt = rtlpriv->stats.txbytesunicast -
-			       mac->last_txok_cnt;
-		cur_rxok_cnt = rtlpriv->stats.rxbytesunicast -
-			       mac->last_rxok_cnt;
+		cur_txok_cnt = rtlpriv->stats.txbytesunicast - last_txok_cnt;
+		cur_rxok_cnt = rtlpriv->stats.rxbytesunicast - last_rxok_cnt;
 
 		if (cur_rxok_cnt > 4 * cur_txok_cnt) {
 			if (!rtlpriv->dm.is_cur_rdlstate ||
@@ -647,18 +651,20 @@ static void rtl8723ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	} else {
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      &tmp);
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_AC_PARAM,
+						      (u8 *)(&tmp));
 			rtlpriv->dm.current_turbo_edca = false;
 		}
 	}
 
 	rtlpriv->dm.is_any_nonbepkts = false;
-	mac->last_txok_cnt = rtlpriv->stats.txbytesunicast;
-	mac->last_rxok_cnt = rtlpriv->stats.rxbytesunicast;
+	last_txok_cnt = rtlpriv->stats.txbytesunicast;
+	last_rxok_cnt = rtlpriv->stats.rxbytesunicast;
 }
 
-static void rtl8723ae_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
+static void rtl8723e_dm_initialize_txpower_tracking_thermalmeter(
+				struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
@@ -667,10 +673,20 @@ static void rtl8723ae_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
 		 "pMgntInfo->txpower_tracking = %d\n",
-		 rtlpriv->dm.txpower_tracking);
+		  rtlpriv->dm.txpower_tracking);
 }
 
-void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
+static void rtl8723e_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
+{
+	rtl8723e_dm_initialize_txpower_tracking_thermalmeter(hw);
+}
+
+void rtl8723e_dm_check_txpower_tracking(struct ieee80211_hw *hw)
+{
+	return;
+}
+
+void rtl8723e_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rate_adaptive *p_ra = &(rtlpriv->ra);
@@ -682,101 +698,32 @@ void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 		rtlpriv->dm.useramask = true;
 	else
 		rtlpriv->dm.useramask = false;
-}
 
-static void rtl8723ae_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rate_adaptive *p_ra = &(rtlpriv->ra);
-	u32 low_rssithresh_for_ra, high_rssithresh_for_ra;
-	struct ieee80211_sta *sta = NULL;
-
-	if (is_hal_stop(rtlhal)) {
-		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-			 " driver is going to unload\n");
-		return;
-	}
-
-	if (!rtlpriv->dm.useramask) {
-		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-			 " driver does not control rate adaptive mask\n");
-		return;
-	}
-
-	if (mac->link_state == MAC80211_LINKED &&
-	    mac->opmode == NL80211_IFTYPE_STATION) {
-		switch (p_ra->pre_ratr_state) {
-		case DM_RATR_STA_HIGH:
-			high_rssithresh_for_ra = 50;
-			low_rssithresh_for_ra = 20;
-			break;
-		case DM_RATR_STA_MIDDLE:
-			high_rssithresh_for_ra = 55;
-			low_rssithresh_for_ra = 20;
-			break;
-		case DM_RATR_STA_LOW:
-			high_rssithresh_for_ra = 50;
-			low_rssithresh_for_ra = 25;
-			break;
-		default:
-			high_rssithresh_for_ra = 50;
-			low_rssithresh_for_ra = 20;
-			break;
-		}
-
-		if (rtlpriv->dm.undec_sm_pwdb > high_rssithresh_for_ra)
-			p_ra->ratr_state = DM_RATR_STA_HIGH;
-		else if (rtlpriv->dm.undec_sm_pwdb > low_rssithresh_for_ra)
-			p_ra->ratr_state = DM_RATR_STA_MIDDLE;
-		else
-			p_ra->ratr_state = DM_RATR_STA_LOW;
-
-		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 "RSSI = %ld\n",
-				 rtlpriv->dm.undec_sm_pwdb);
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 "PreState = %d, CurState = %d\n",
-				 p_ra->pre_ratr_state, p_ra->ratr_state);
-
-			rcu_read_lock();
-			sta = rtl_find_sta(hw, mac->bssid);
-			if (sta)
-				rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
-							   p_ra->ratr_state);
-			rcu_read_unlock();
-
-			p_ra->pre_ratr_state = p_ra->ratr_state;
-		}
-	}
 }
 
-void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 force_in_normal)
+void rtl8723e_dm_rf_saving(struct ieee80211_hw *hw, u8 bforce_in_normal)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct ps_t *dm_pstable = &rtlpriv->dm_pstable;
+	static u8 initialize;
+	static u32 reg_874, reg_c70, reg_85c, reg_a74;
 
-	if (!rtlpriv->reg_init) {
-		rtlpriv->reg_874 = (rtl_get_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
-				    MASKDWORD) & 0x1CC000) >> 14;
+	if (initialize == 0) {
+		reg_874 = (rtl_get_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+					 MASKDWORD) & 0x1CC000) >> 14;
 
-		rtlpriv->reg_c70 = (rtl_get_bbreg(hw, ROFDM0_AGCPARAMETER1,
-				    MASKDWORD) & BIT(3)) >> 3;
+		reg_c70 = (rtl_get_bbreg(hw, ROFDM0_AGCPARAMETER1,
+					 MASKDWORD) & BIT(3)) >> 3;
 
-		rtlpriv->reg_85c = (rtl_get_bbreg(hw, RFPGA0_XCD_SWITCHCONTROL,
-				    MASKDWORD) & 0xFF000000) >> 24;
+		reg_85c = (rtl_get_bbreg(hw, RFPGA0_XCD_SWITCHCONTROL,
+					 MASKDWORD) & 0xFF000000) >> 24;
 
-		rtlpriv->reg_a74 = (rtl_get_bbreg(hw, 0xa74, MASKDWORD) &
-				   0xF000) >> 12;
+		reg_a74 = (rtl_get_bbreg(hw, 0xa74, MASKDWORD) & 0xF000) >> 12;
 
-		rtlpriv->reg_init = true;
+		initialize = 1;
 	}
 
-	if (!force_in_normal) {
+	if (!bforce_in_normal) {
 		if (dm_pstable->rssi_val_min != 0) {
 			if (dm_pstable->pre_rfstate == RF_NORMAL) {
 				if (dm_pstable->rssi_val_min >= 30)
@@ -798,7 +745,6 @@ void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 force_in_normal)
 
 	if (dm_pstable->pre_rfstate != dm_pstable->cur_rfstate) {
 		if (dm_pstable->cur_rfstate == RF_SAVE) {
-
 			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
 				      BIT(5), 0x1);
 			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
@@ -813,12 +759,12 @@ void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 force_in_normal)
 			rtl_set_bbreg(hw, 0x818, BIT(28), 0x1);
 		} else {
 			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
-				      0x1CC000, rtlpriv->reg_874);
+				      0x1CC000, reg_874);
 			rtl_set_bbreg(hw, ROFDM0_AGCPARAMETER1, BIT(3),
-				      rtlpriv->reg_c70);
+				      reg_c70);
 			rtl_set_bbreg(hw, RFPGA0_XCD_SWITCHCONTROL, 0xFF000000,
-				      rtlpriv->reg_85c);
-			rtl_set_bbreg(hw, 0xa74, 0xF000, rtlpriv->reg_a74);
+				      reg_85c);
+			rtl_set_bbreg(hw, 0xa74, 0xF000, reg_a74);
 			rtl_set_bbreg(hw, 0x818, BIT(28), 0x0);
 			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
 				      BIT(5), 0x0);
@@ -828,7 +774,7 @@ void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 force_in_normal)
 	}
 }
 
-static void rtl8723ae_dm_dynamic_bpowersaving(struct ieee80211_hw *hw)
+static void rtl8723e_dm_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -847,48 +793,49 @@ static void rtl8723ae_dm_dynamic_bpowersaving(struct ieee80211_hw *hw)
 			    rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 dm_pstable->rssi_val_min);
+				  dm_pstable->rssi_val_min);
 		} else {
-			dm_pstable->rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
+			dm_pstable->rssi_val_min =
+			    rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 dm_pstable->rssi_val_min);
+				  dm_pstable->rssi_val_min);
 		}
 	} else {
-		dm_pstable->rssi_val_min = rtlpriv->dm.entry_min_undec_sm_pwdb;
+		dm_pstable->rssi_val_min =
+		    rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
-			 dm_pstable->rssi_val_min);
+			  dm_pstable->rssi_val_min);
 	}
 
-	rtl8723ae_dm_rf_saving(hw, false);
+	rtl8723e_dm_rf_saving(hw, false);
 }
 
-void rtl8723ae_dm_init(struct ieee80211_hw *hw)
+void rtl8723e_dm_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
-	rtl8723ae_dm_diginit(hw);
+	rtl8723e_dm_diginit(hw);
 	rtl8723_dm_init_dynamic_txpower(hw);
 	rtl8723_dm_init_edca_turbo(hw);
-	rtl8723ae_dm_init_rate_adaptive_mask(hw);
-	rtl8723ae_dm_initialize_txpower_tracking(hw);
+	rtl8723e_dm_init_rate_adaptive_mask(hw);
+	rtl8723e_dm_initialize_txpower_tracking(hw);
 	rtl8723_dm_init_dynamic_bb_powersaving(hw);
 }
 
-void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
+void rtl8723e_dm_watchdog(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	bool fw_current_inpsmode = false;
 	bool fw_ps_awake = true;
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
-				      (u8 *) (&fw_current_inpsmode));
+				      (u8 *)(&fw_current_inpsmode));
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
-				      (u8 *) (&fw_ps_awake));
+				      (u8 *)(&fw_ps_awake));
 
 	if (ppsc->p2p_ps_info.p2p_ps_mode)
 		fw_ps_awake = false;
@@ -896,58 +843,57 @@ void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
 	if ((ppsc->rfpwr_state == ERFON) &&
 	    ((!fw_current_inpsmode) && fw_ps_awake) &&
 	    (!ppsc->rfchange_inprogress)) {
-		rtl8723ae_dm_dig(hw);
-		rtl8723ae_dm_false_alarm_counter_statistics(hw);
-		rtl8723ae_dm_dynamic_bpowersaving(hw);
-		rtl8723ae_dm_dynamic_txpower(hw);
-		rtl8723ae_dm_refresh_rate_adaptive_mask(hw);
-		rtl8723ae_dm_bt_coexist(hw);
-		rtl8723ae_dm_check_edca_turbo(hw);
+		rtl8723e_dm_pwdb_monitor(hw);
+		rtl8723e_dm_dig(hw);
+		rtl8723e_dm_false_alarm_counter_statistics(hw);
+		rtl8723e_dm_dynamic_bb_powersaving(hw);
+		rtl8723e_dm_dynamic_txpower(hw);
+		rtl8723e_dm_check_txpower_tracking(hw);
+		/* rtl92c_dm_refresh_rate_adaptive_mask(hw); */
+		rtl8723e_dm_bt_coexist(hw);
+		rtl8723e_dm_check_edca_turbo(hw);
 	}
-	if (rtlpcipriv->bt_coexist.init_set)
+	if (rtlpriv->btcoexist.init_set)
 		rtl_write_byte(rtlpriv, 0x76e, 0xc);
 }
 
-static void rtl8723ae_dm_init_bt_coexist(struct ieee80211_hw *hw)
+static void rtl8723e_dm_init_bt_coexist(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 
-	rtlpcipriv->bt_coexist.bt_rfreg_origin_1e
+	rtlpriv->btcoexist.bt_rfreg_origin_1e
 		= rtl_get_rfreg(hw, (enum radio_path)0, RF_RCK1, 0xfffff);
-	rtlpcipriv->bt_coexist.bt_rfreg_origin_1f
+	rtlpriv->btcoexist.bt_rfreg_origin_1f
 		= rtl_get_rfreg(hw, (enum radio_path)0, RF_RCK2, 0xf0);
 
-	rtlpcipriv->bt_coexist.cstate = 0;
-	rtlpcipriv->bt_coexist.previous_state = 0;
-	rtlpcipriv->bt_coexist.cstate_h = 0;
-	rtlpcipriv->bt_coexist.previous_state_h = 0;
-	rtlpcipriv->bt_coexist.lps_counter = 0;
+	rtlpriv->btcoexist.cstate = 0;
+	rtlpriv->btcoexist.previous_state = 0;
+	rtlpriv->btcoexist.cstate_h = 0;
+	rtlpriv->btcoexist.previous_state_h = 0;
+	rtlpriv->btcoexist.lps_counter = 0;
 
 	/*  Enable counter statistics */
 	rtl_write_byte(rtlpriv, 0x76e, 0x4);
 	rtl_write_byte(rtlpriv, 0x778, 0x3);
 	rtl_write_byte(rtlpriv, 0x40, 0x20);
 
-	rtlpcipriv->bt_coexist.init_set = true;
+	rtlpriv->btcoexist.init_set = true;
 }
 
-void rtl8723ae_dm_bt_coexist(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_coexist(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	u8 tmp_byte = 0;
-	if (!rtlpcipriv->bt_coexist.bt_coexistence) {
+	if (!rtlpriv->btcoexist.bt_coexistence) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
 			 "[DM]{BT], BT not exist!!\n");
 		return;
 	}
 
-	if (!rtlpcipriv->bt_coexist.init_set) {
+	if (!rtlpriv->btcoexist.init_set) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
-			 "[DM][BT], rtl8723ae_dm_bt_coexist()\n");
-
-		rtl8723ae_dm_init_bt_coexist(hw);
+			 "[DM][BT], rtl8723e_dm_bt_coexist()\n");
+		rtl8723e_dm_init_bt_coexist(hw);
 	}
 
 	tmp_byte = rtl_read_byte(rtlpriv, 0x40);
@@ -955,5 +901,5 @@ void rtl8723ae_dm_bt_coexist(struct ieee80211_hw *hw)
 		 "[DM][BT], 0x40 is 0x%x", tmp_byte);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 		 "[DM][BT], bt_dm_coexist start");
-	rtl8723ae_dm_bt_coexist_8723(hw);
+	rtl8723e_dm_bt_coexist_8723(hw);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
index d253bb5..6fa0feb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
@@ -25,17 +25,23 @@
  *
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 
 #ifndef	__RTL8723E_DM_H__
 #define __RTL8723E_DM_H__
 
+#define HAL_DM_DIG_DISABLE			BIT(0)
 #define HAL_DM_HIPWR_DISABLE			BIT(1)
 
+#define OFDM_TABLE_LENGTH			37
+#define CCK_TABLE_LENGTH			33
+
 #define OFDM_TABLE_SIZE				37
 #define CCK_TABLE_SIZE				33
 
+#define BW_AUTO_SWITCH_HIGH_LOW			25
+#define BW_AUTO_SWITCH_LOW_HIGH			30
+
 #define DM_DIG_THRESH_HIGH			40
 #define DM_DIG_THRESH_LOW			35
 
@@ -63,12 +69,18 @@
 #define DM_RATR_STA_MIDDLE			2
 #define DM_RATR_STA_LOW				3
 
+#define CTS2SELF_THVAL				30
+#define REGC38_TH				20
+
+#define WAIOTTHVAL				25
+
 #define TXHIGHPWRLEVEL_NORMAL			0
 #define TXHIGHPWRLEVEL_LEVEL1			1
 #define TXHIGHPWRLEVEL_LEVEL2			2
 #define TXHIGHPWRLEVEL_BT1			3
 #define TXHIGHPWRLEVEL_BT2			4
 
+#define DM_TYPE_BYFW				0
 #define DM_TYPE_BYDRIVER			1
 
 #define TX_POWER_NEAR_FIELD_THRESH_LVL2		74
@@ -82,6 +94,7 @@ struct swat_t {
 	long trying_threshold;
 	u8 cur_antenna;
 	u8 pre_antenna;
+
 };
 
 enum tag_dynamic_init_gain_operation_type_definition {
@@ -98,7 +111,7 @@ enum tag_dynamic_init_gain_operation_type_definition {
 enum tag_cck_packet_detection_threshold_type_definition {
 	CCK_PD_STAGE_LowRssi = 0,
 	CCK_PD_STAGE_HighRssi = 1,
-	CCK_FA_STAGE_Low = 2,
+	CCK_FA_STAGE_LOW = 2,
 	CCK_FA_STAGE_High = 3,
 	CCK_PD_STAGE_MAX = 4,
 };
@@ -138,17 +151,24 @@ enum dm_dig_connect_e {
 	DIG_CONNECT_MAX
 };
 
+#define BT_RSSI_STATE_NORMAL_POWER      BIT_OFFSET_LEN_MASK_32(0, 1)
+#define BT_RSSI_STATE_AMDPU_OFF         BIT_OFFSET_LEN_MASK_32(1, 1)
+#define BT_RSSI_STATE_SPECIAL_LOW       BIT_OFFSET_LEN_MASK_32(2, 1)
+#define BT_RSSI_STATE_BG_EDCA_LOW       BIT_OFFSET_LEN_MASK_32(3, 1)
+#define BT_RSSI_STATE_TXPOWER_LOW       BIT_OFFSET_LEN_MASK_32(4, 1)
 #define GET_UNDECORATED_AVERAGE_RSSI(_priv)     \
-	((((struct rtl_priv *)(_priv))->mac80211.opmode ==	\
-	NL80211_IFTYPE_ADHOC) ?  \
-	(((struct rtl_priv *)(_priv))->dm.entry_min_undec_sm_pwdb) \
-	: (((struct rtl_priv *)(_priv))->dm.undec_sm_pwdb))
-
-void rtl8723ae_dm_init(struct ieee80211_hw *hw);
-void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw);
-void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw);
-void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
-void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 bforce_in_normal);
-void rtl8723ae_dm_bt_coexist(struct ieee80211_hw *hw);
-
+	( \
+	(((struct rtl_priv *)(_priv))->mac80211.opmode ==		\
+			     NL80211_IFTYPE_ADHOC) ?			\
+	(((struct rtl_priv *)(_priv))->dm.entry_min_undec_sm_pwdb) :	\
+	(((struct rtl_priv *)(_priv))->dm.undec_sm_pwdb)		\
+	)
+
+void rtl8723e_dm_init(struct ieee80211_hw *hw);
+void rtl8723e_dm_watchdog(struct ieee80211_hw *hw);
+void rtl8723e_dm_write_dig(struct ieee80211_hw *hw);
+void rtl8723e_dm_check_txpower_tracking(struct ieee80211_hw *hw);
+void rtl8723e_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
+void rtl8723e_dm_rf_saving(struct ieee80211_hw *hw, u8 bforce_in_normal);
+void rtl8723e_dm_bt_coexist(struct ieee80211_hw *hw);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
index 728b756..97d92e2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
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
@@ -25,8 +21,7 @@
  *
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 
 #include "../wifi.h"
 #include "../pci.h"
@@ -36,7 +31,8 @@
 #include "fw.h"
 #include "../rtl8723com/fw_common.h"
 
-static bool rtl8723ae_check_fw_read_last_h2c(struct ieee80211_hw *hw, u8 boxnum)
+static bool _rtl8723e_check_fw_read_last_h2c(struct ieee80211_hw *hw,
+					     u8 boxnum)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 val_hmetfr, val_mcutst_1;
@@ -50,17 +46,17 @@ static bool rtl8723ae_check_fw_read_last_h2c(struct ieee80211_hw *hw, u8 boxnum)
 	return result;
 }
 
-static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
-					u8 element_id, u32 cmd_len,
-					u8 *p_cmdbuffer)
+static void _rtl8723e_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
+				       u32 cmd_len, u8 *cmdbuffer)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 boxnum;
 	u16 box_reg = 0, box_extreg = 0;
-	u8 u1tmp;
-	bool isfw_rd = false;
-	bool bwrite_success = false;
+	u8 u1b_tmp;
+	bool isfw_read = false;
+	u8 buf_index = 0;
+	bool bwrite_sucess = false;
 	u8 wait_h2c_limmit = 100;
 	u8 wait_writeh2c_limmit = 100;
 	u8 boxcontent[4], boxextcontent[2];
@@ -83,7 +79,7 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 				h2c_waitcounter++;
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 					 "Wait 100 us (%d times)...\n",
-					 h2c_waitcounter);
+					  h2c_waitcounter);
 				udelay(100);
 
 				if (h2c_waitcounter > 1000)
@@ -99,12 +95,11 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 		}
 	}
 
-	while (!bwrite_success) {
+	while (!bwrite_sucess) {
 		wait_writeh2c_limmit--;
 		if (wait_writeh2c_limmit == 0) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "Write H2C fail because no trigger "
-				 "for FW INT!\n");
+				 "Write H2C fail because no trigger for FW INT!\n");
 			break;
 		}
 
@@ -128,34 +123,35 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+				 "switch case not process\n");
 			break;
 		}
 
-		isfw_rd = rtl8723ae_check_fw_read_last_h2c(hw, boxnum);
-		while (!isfw_rd) {
+		isfw_read = _rtl8723e_check_fw_read_last_h2c(hw, boxnum);
+		while (!isfw_read) {
 
 			wait_h2c_limmit--;
 			if (wait_h2c_limmit == 0) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 "Waiting too long for FW read clear HMEBox(%d)!\n",
+					 "Wating too long for FW read clear HMEBox(%d)!\n",
 					 boxnum);
 				break;
 			}
 
 			udelay(10);
 
-			isfw_rd = rtl8723ae_check_fw_read_last_h2c(hw, boxnum);
-			u1tmp = rtl_read_byte(rtlpriv, 0x1BF);
+			isfw_read = _rtl8723e_check_fw_read_last_h2c(hw,
+								boxnum);
+			u1b_tmp = rtl_read_byte(rtlpriv, 0x1BF);
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Waiting for FW read clear HMEBox(%d)!!! "
-				 "0x1BF = %2x\n", boxnum, u1tmp);
+				 "Waiting for FW read clear HMEBox(%d)!!! 0x1BF = %2x\n",
+				 boxnum, u1b_tmp);
 		}
 
-		if (!isfw_rd) {
+		if (!isfw_read) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 "Write H2C register BOX[%d] fail!!!!! "
-				 "Fw do not read.\n", boxnum);
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read.\n",
+				 boxnum);
 			break;
 		}
 
@@ -169,8 +165,8 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 		switch (cmd_len) {
 		case 1:
 			boxcontent[0] &= ~(BIT(7));
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer, 1);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 1);
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
@@ -179,8 +175,8 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 2:
 			boxcontent[0] &= ~(BIT(7));
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer, 2);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 2);
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
@@ -189,8 +185,8 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 3:
 			boxcontent[0] &= ~(BIT(7));
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer, 3);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 3);
 
 			for (idx = 0; idx < 4; idx++) {
 				rtl_write_byte(rtlpriv, box_reg + idx,
@@ -199,10 +195,10 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 4:
 			boxcontent[0] |= (BIT(7));
-			memcpy((u8 *) (boxextcontent),
-			       p_cmdbuffer, 2);
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer + 2, 2);
+			memcpy((u8 *)(boxextcontent),
+			       cmdbuffer + buf_index, 2);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index + 2, 2);
 
 			for (idx = 0; idx < 2; idx++) {
 				rtl_write_byte(rtlpriv, box_extreg + idx,
@@ -216,10 +212,10 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		case 5:
 			boxcontent[0] |= (BIT(7));
-			memcpy((u8 *) (boxextcontent),
-			       p_cmdbuffer, 2);
-			memcpy((u8 *) (boxcontent) + 1,
-			       p_cmdbuffer + 2, 3);
+			memcpy((u8 *)(boxextcontent),
+			       cmdbuffer + buf_index, 2);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index + 2, 3);
 
 			for (idx = 0; idx < 2; idx++) {
 				rtl_write_byte(rtlpriv, box_extreg + idx,
@@ -237,7 +233,7 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		}
 
-		bwrite_success = true;
+		bwrite_sucess = true;
 
 		rtlhal->last_hmeboxnum = boxnum + 1;
 		if (rtlhal->last_hmeboxnum == 4)
@@ -245,7 +241,7 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
 			 "pHalData->last_hmeboxnum  = %d\n",
-			 rtlhal->last_hmeboxnum);
+			  rtlhal->last_hmeboxnum);
 	}
 
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
@@ -255,52 +251,49 @@ static void _rtl8723ae_fill_h2c_command(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "go out\n");
 }
 
-void rtl8723ae_fill_h2c_cmd(struct ieee80211_hw *hw,
-			    u8 element_id, u32 cmd_len, u8 *p_cmdbuffer)
+void rtl8723e_fill_h2c_cmd(struct ieee80211_hw *hw,
+			   u8 element_id, u32 cmd_len, u8 *cmdbuffer)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u32 tmp_cmdbuf[2];
 
-	if (rtlhal->fw_ready == false) {
+	if (!rtlhal->fw_ready) {
 		RT_ASSERT(false,
-			 "return H2C cmd because of Fw download fail!!!\n");
+			  "return H2C cmd because of Fw download fail!!!\n");
 		return;
 	}
-
-	_rtl8723ae_fill_h2c_command(hw, element_id, cmd_len, p_cmdbuffer);
-	return;
+	memset(tmp_cmdbuf, 0, 8);
+	memcpy(tmp_cmdbuf, cmdbuffer, cmd_len);
+	_rtl8723e_fill_h2c_command(hw, element_id, cmd_len,
+				   (u8 *)&tmp_cmdbuf);
 }
 
-static bool _rtl8723ae_cmd_send_packet(struct ieee80211_hw *hw,
-				       struct sk_buff *skb)
+void rtl8723e_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct rtl8192_tx_ring *ring;
-	struct rtl_tx_desc *pdesc;
-	unsigned long flags;
-	struct sk_buff *pskb = NULL;
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
+	u8 u1_h2c_set_pwrmode[3] = { 0 };
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 
-	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *) pdesc, 1, 1, skb);
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
-	__skb_queue_tail(&ring->queue, skb);
+	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
+	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
+		(rtlpriv->mac80211.p2p) ? ppsc->smart_ps : 1);
+	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
+					      ppsc->reg_max_lps_awakeintvl);
 
-	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+		      "rtl8723e_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode\n",
+		      u1_h2c_set_pwrmode, 3);
+	rtl8723e_fill_h2c_cmd(hw, H2C_SETPWRMODE, 3, u1_h2c_set_pwrmode);
+}
 
-	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
+#define BEACON_PG		0 /* ->1 */
+#define PSPOLL_PG		2
+#define NULL_PG			3
+#define PROBERSP_PG		4 /* ->5 */
 
-	return true;
-}
+#define TOTAL_RESERVED_PKT_LEN	768
 
 static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] = {
 	/* page 0 beacon */
@@ -412,111 +405,111 @@ static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] = {
 	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 };
 
-void rtl8723ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
+void rtl8723e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct sk_buff *skb = NULL;
-
 	u32 totalpacketlen;
 	bool rtstatus;
-	u8 u1RsvdPageLoc[3] = { 0 };
-	bool dlok = false;
-
+	u8 u1rsvdpageloc[3] = { 0 };
+	bool b_dlok = false;
 	u8 *beacon;
 	u8 *p_pspoll;
 	u8 *nullfunc;
 	u8 *p_probersp;
+
 	/*---------------------------------------------------------
-				(1) beacon
-	---------------------------------------------------------
-	*/
+	 *			(1) beacon
+	 *---------------------------------------------------------
+	 */
 	beacon = &reserved_page_packet[BEACON_PG * 128];
 	SET_80211_HDR_ADDRESS2(beacon, mac->mac_addr);
 	SET_80211_HDR_ADDRESS3(beacon, mac->bssid);
 
 	/*-------------------------------------------------------
-				(2) ps-poll
-	--------------------------------------------------------
-	*/
+	 *			(2) ps-poll
+	 *--------------------------------------------------------
+	 */
 	p_pspoll = &reserved_page_packet[PSPOLL_PG * 128];
 	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
 	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
 	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
 
-	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1RsvdPageLoc, PSPOLL_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1rsvdpageloc, PSPOLL_PG);
 
 	/*--------------------------------------------------------
-				(3) null data
-	---------------------------------------------------------i
-	*/
+	 *			(3) null data
+	 *---------------------------------------------------------
+	 */
 	nullfunc = &reserved_page_packet[NULL_PG * 128];
 	SET_80211_HDR_ADDRESS1(nullfunc, mac->bssid);
 	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
 	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
 
-	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1RsvdPageLoc, NULL_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1rsvdpageloc, NULL_PG);
 
 	/*---------------------------------------------------------
-				(4) probe response
-	----------------------------------------------------------
-	*/
+	 *			(4) probe response
+	 *----------------------------------------------------------
+	 */
 	p_probersp = &reserved_page_packet[PROBERSP_PG * 128];
 	SET_80211_HDR_ADDRESS1(p_probersp, mac->bssid);
 	SET_80211_HDR_ADDRESS2(p_probersp, mac->mac_addr);
 	SET_80211_HDR_ADDRESS3(p_probersp, mac->bssid);
 
-	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1RsvdPageLoc, PROBERSP_PG);
+	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1rsvdpageloc, PROBERSP_PG);
 
 	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "rtl8723ae_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      "rtl8723e_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
 		      &reserved_page_packet[0], totalpacketlen);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl8723ae_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
-		      u1RsvdPageLoc, 3);
+		      "rtl8723e_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      u1rsvdpageloc, 3);
 
 	skb = dev_alloc_skb(totalpacketlen);
-	memcpy((u8 *) skb_put(skb, totalpacketlen),
+	memcpy((u8 *)skb_put(skb, totalpacketlen),
 	       &reserved_page_packet, totalpacketlen);
 
-	rtstatus = _rtl8723ae_cmd_send_packet(hw, skb);
+	rtstatus = rtl8723_cmd_send_packet(hw, skb);
 
 	if (rtstatus)
-		dlok = true;
+		b_dlok = true;
 
-	if (dlok) {
+	if (b_dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "Set RSVD page location to Fw.\n");
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-				"H2C_RSVDPAGE:\n",
-				u1RsvdPageLoc, 3);
-		rtl8723ae_fill_h2c_cmd(hw, H2C_RSVDPAGE,
-				       sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
+			      "H2C_RSVDPAGE:\n",
+			      u1rsvdpageloc, 3);
+		rtl8723e_fill_h2c_cmd(hw, H2C_RSVDPAGE,
+				      sizeof(u1rsvdpageloc), u1rsvdpageloc);
 	} else
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
 }
 
-void rtl8723ae_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
+void rtl8723e_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
 {
 	u8 u1_joinbssrpt_parm[1] = { 0 };
 
 	SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(u1_joinbssrpt_parm, mstatus);
 
-	rtl8723ae_fill_h2c_cmd(hw, H2C_JOINBSSRPT, 1, u1_joinbssrpt_parm);
+	rtl8723e_fill_h2c_cmd(hw, H2C_JOINBSSRPT, 1, u1_joinbssrpt_parm);
 }
 
 static void rtl8723e_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw,
 					    u8 ctwindow)
 {
-	u8 u1_ctwindow_period[1] = {ctwindow};
+	u8 u1_ctwindow_period[1] = { ctwindow};
+
+	rtl8723e_fill_h2c_cmd(hw, H2C_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
 
-	rtl8723ae_fill_h2c_cmd(hw, H2C_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
 }
 
-void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
+void rtl8723e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
@@ -530,7 +523,7 @@ void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	switch (p2p_ps_state) {
 	case P2P_PS_DISABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
-		memset(p2p_ps_offload, 0, sizeof(struct p2p_ps_offload_t));
+		memset(p2p_ps_offload, 0, sizeof(*p2p_ps_offload));
 		break;
 	case P2P_PS_ENABLE:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
@@ -542,7 +535,7 @@ void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 		}
 
 		/* hw only support 2 set of NoA */
-		for (i = 0; i < p2pinfo->noa_num; i++) {
+		for (i = 0 ; i < p2pinfo->noa_num ; i++) {
 			/* To control the register setting for which NOA*/
 			rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
 			if (i == 0)
@@ -561,27 +554,33 @@ void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 
 			start_time = p2pinfo->noa_start_time[i];
 			if (p2pinfo->noa_count_type[i] != 1) {
-				while (start_time <= (tsf_low+(50*1024))) {
-					start_time += p2pinfo->noa_interval[i];
+				while (start_time <=
+					(tsf_low+(50*1024))) {
+					start_time +=
+						p2pinfo->noa_interval[i];
 					if (p2pinfo->noa_count_type[i] != 255)
 						p2pinfo->noa_count_type[i]--;
 				}
 			}
 			rtl_write_dword(rtlpriv, 0x5E8, start_time);
 			rtl_write_dword(rtlpriv, 0x5EC,
-					p2pinfo->noa_count_type[i]);
+				p2pinfo->noa_count_type[i]);
+
 		}
+
 		if ((p2pinfo->opp_ps == 1) || (p2pinfo->noa_num > 0)) {
 			/* rst p2p circuit */
 			rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, BIT(4));
 
 			p2p_ps_offload->offload_en = 1;
+
 			if (P2P_ROLE_GO == rtlpriv->mac80211.p2p) {
 				p2p_ps_offload->role = 1;
 				p2p_ps_offload->allstasleep = 0;
 			} else {
 				p2p_ps_offload->role = 0;
 			}
+
 			p2p_ps_offload->discovery = 0;
 		}
 		break;
@@ -597,26 +596,7 @@ void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
 	default:
 		break;
 	}
-	rtl8723ae_fill_h2c_cmd(hw, H2C_P2P_PS_OFFLOAD, 1, (u8 *)p2p_ps_offload);
-}
-
-void rtl8723ae_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 u1_h2c_set_pwrmode[3] = { 0 };
-	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-
-	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
-	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
-	SET_H2CCMD_PWRMODE_PARM_SMART_PS_23A(u1_h2c_set_pwrmode,
-					     (rtlpriv->mac80211.p2p) ?
-					     ppsc->smart_ps : 1);
-	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
-					      ppsc->reg_max_lps_awakeintvl);
+	rtl8723e_fill_h2c_cmd(hw, H2C_P2P_PS_OFFLOAD, 1, (u8 *)p2p_ps_offload);
 
-	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl8723ae_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode\n",
-		      u1_h2c_set_pwrmode, 3);
-	rtl8723ae_fill_h2c_cmd(hw, H2C_SETPWRMODE, 3, u1_h2c_set_pwrmode);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
index d355b85..ad70f2b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
@@ -24,50 +24,28 @@
  * Hsinchu 300, Taiwan.
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 
 #ifndef __RTL92C__FW__H__
 #define __RTL92C__FW__H__
 
+#define FW_8192C_SIZE					0x3000
 #define FW_8192C_START_ADDRESS			0x1000
 #define FW_8192C_END_ADDRESS			0x3FFF
-#define FW_8192C_PAGE_SIZE			4096
+#define FW_8192C_PAGE_SIZE				4096
 #define FW_8192C_POLLING_DELAY			5
-#define FW_8192C_POLLING_TIMEOUT_COUNT		6000
+#define FW_8192C_POLLING_TIMEOUT_COUNT	1000
 
-#define BEACON_PG				0
-#define PSPOLL_PG				2
-#define NULL_PG					3
-#define PROBERSP_PG				4 /* ->5 */
+#define IS_FW_HEADER_EXIST(_pfwhdr)	\
+	((_pfwhdr->signature&0xFFFF) == 0x2300 ||\
+	(_pfwhdr->signature&0xFFFF) == 0x2301 ||\
+	(_pfwhdr->signature&0xFFFF) == 0x2302)
 
-#define TOTAL_RESERVED_PKT_LEN			768
-
-#define IS_FW_HEADER_EXIST(_pfwhdr)		\
-	((_pfwhdr->signature&0xFF00) == 0x2300)
-
-struct rtl8723ae_firmware_header {
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
-	u16 ramcodeSize;
-	u16 rsvd2;
-	u32 svnindex;
-	u32 rsvd3;
-	u32 rsvd4;
-	u32 rsvd5;
-};
+#define pagenum_128(_len)	(u32)(((_len)>>7) + ((_len)&0x7F ? 1 : 0))
 
 #define SET_H2CCMD_PWRMODE_PARM_MODE(__ph2ccmd, __val)			\
 	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
-#define SET_H2CCMD_PWRMODE_PARM_SMART_PS_23A(__ph2ccmd, __val)		\
+#define SET_H2CCMD_PWRMODE_PARM_SMART_PS(__ph2ccmd, __val)		\
 	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
 #define SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(__ph2ccmd, __val)	\
 	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
@@ -80,11 +58,10 @@ struct rtl8723ae_firmware_header {
 #define SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(__ph2ccmd, __val)		\
 	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
 
-void rtl8723ae_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
-			    u32 cmd_len, u8 *p_cmdbuffer);
-void rtl8723ae_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
-void rtl8723ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
-void rtl8723ae_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
-void rtl8723ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
-
+void rtl8723e_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
+			   u32 cmd_len, u8 *p_cmdbuffer);
+void rtl8723e_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
+void rtl8723e_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
+void rtl8723e_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus);
+void rtl8723e_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
index 5b4a714..5aac45d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
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
@@ -31,96 +27,102 @@
 #include "../pci.h"
 #include "dm.h"
 #include "fw.h"
-#include "../rtl8723com/fw_common.h"
 #include "phy.h"
 #include "reg.h"
 #include "hal_btc.h"
 
-void rtl8723ae_dm_bt_reject_ap_aggregated_packet(struct ieee80211_hw *hw,
-						 bool reject)
+static bool bt_operation_on;
+
+void rtl8723e_dm_bt_reject_ap_aggregated_packet(struct ieee80211_hw *hw,
+						bool b_reject)
 {
 }
 
 void _rtl8723_dm_bt_check_wifi_state(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
 	if (rtlpriv->link_info.busytraffic) {
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_WIFI_IDLE;
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_IDLE;
 
 		if (rtlpriv->link_info.tx_busy_traffic)
-			rtlpcipriv->bt_coexist.cstate |=
-					BT_COEX_STATE_WIFI_UPLINK;
+			rtlpriv->btcoexist.cstate |=
+				BT_COEX_STATE_WIFI_UPLINK;
 		else
-			rtlpcipriv->bt_coexist.cstate &=
-					~BT_COEX_STATE_WIFI_UPLINK;
+			rtlpriv->btcoexist.cstate &=
+				~BT_COEX_STATE_WIFI_UPLINK;
 
 		if (rtlpriv->link_info.rx_busy_traffic)
-			rtlpcipriv->bt_coexist.cstate |=
-					BT_COEX_STATE_WIFI_DOWNLINK;
+			rtlpriv->btcoexist.cstate |=
+				BT_COEX_STATE_WIFI_DOWNLINK;
 		else
-			rtlpcipriv->bt_coexist.cstate &=
-					~BT_COEX_STATE_WIFI_DOWNLINK;
+			rtlpriv->btcoexist.cstate &=
+				~BT_COEX_STATE_WIFI_DOWNLINK;
 	} else {
-		rtlpcipriv->bt_coexist.cstate |= BT_COEX_STATE_WIFI_IDLE;
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_WIFI_UPLINK;
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_WIFI_DOWNLINK;
+		rtlpriv->btcoexist.cstate |= BT_COEX_STATE_WIFI_IDLE;
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_UPLINK;
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_DOWNLINK;
 	}
 
 	if (rtlpriv->mac80211.mode == WIRELESS_MODE_G ||
 	    rtlpriv->mac80211.mode == WIRELESS_MODE_B) {
-		rtlpcipriv->bt_coexist.cstate |= BT_COEX_STATE_WIFI_LEGACY;
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_WIFI_HT20;
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_WIFI_HT40;
+		rtlpriv->btcoexist.cstate |=
+			BT_COEX_STATE_WIFI_LEGACY;
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_HT20;
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_HT40;
 	} else {
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_WIFI_LEGACY;
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_LEGACY;
 		if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
-			rtlpcipriv->bt_coexist.cstate |=
-					BT_COEX_STATE_WIFI_HT40;
-			rtlpcipriv->bt_coexist.cstate &=
-					~BT_COEX_STATE_WIFI_HT20;
+			rtlpriv->btcoexist.cstate |=
+				BT_COEX_STATE_WIFI_HT40;
+			rtlpriv->btcoexist.cstate &=
+				~BT_COEX_STATE_WIFI_HT20;
 		} else {
-			rtlpcipriv->bt_coexist.cstate |=
-					BT_COEX_STATE_WIFI_HT20;
-			rtlpcipriv->bt_coexist.cstate &=
-					~BT_COEX_STATE_WIFI_HT40;
+			rtlpriv->btcoexist.cstate |=
+				BT_COEX_STATE_WIFI_HT20;
+			rtlpriv->btcoexist.cstate &=
+				~BT_COEX_STATE_WIFI_HT40;
 		}
 	}
 
-	if (rtlpriv->bt_operation_on)
-		rtlpcipriv->bt_coexist.cstate |= BT_COEX_STATE_BT30;
+	if (bt_operation_on)
+		rtlpriv->btcoexist.cstate |= BT_COEX_STATE_BT30;
 	else
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_BT30;
+		rtlpriv->btcoexist.cstate &= ~BT_COEX_STATE_BT30;
 }
 
-u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
-					  u8 level_num, u8 rssi_thresh,
-					  u8 rssi_thresh1)
+u8 rtl8723e_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
+					 u8 level_num, u8 rssi_thresh,
+					 u8 rssi_thresh1)
 
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	long smooth;
+	long undecoratedsmoothed_pwdb;
 	u8 bt_rssi_state = 0;
 
-	smooth =  rtl8723ae_dm_bt_get_rx_ss(hw);
+	undecoratedsmoothed_pwdb = rtl8723e_dm_bt_get_rx_ss(hw);
 
 	if (level_num == 2) {
-		rtlpcipriv->bt_coexist.cstate &=
-				~BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
-
-		if ((rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_LOW) ||
-		    (rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_STAY_LOW)) {
-			if (smooth >= (rssi_thresh +
-			    BT_FW_COEX_THRESH_TOL)) {
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
+
+		if ((rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_LOW) ||
+		    (rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_STAY_LOW)) {
+			if (undecoratedsmoothed_pwdb >=
+			    (rssi_thresh + BT_FW_COEX_THRESH_TOL)) {
 				bt_rssi_state = BT_RSSI_STATE_HIGH;
-				rtlpcipriv->bt_coexist.cstate |=
+				rtlpriv->btcoexist.cstate |=
 					BT_COEX_STATE_WIFI_RSSI_1_HIGH;
-				rtlpcipriv->bt_coexist.cstate &=
+				rtlpriv->btcoexist.cstate &=
 					~BT_COEX_STATE_WIFI_RSSI_1_LOW;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state switch to High\n");
@@ -130,12 +132,12 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
 					 "[DM][BT], RSSI_1 state stay at Low\n");
 			}
 		} else {
-			if (smooth < rssi_thresh) {
+			if (undecoratedsmoothed_pwdb < rssi_thresh) {
 				bt_rssi_state = BT_RSSI_STATE_LOW;
-				rtlpcipriv->bt_coexist.cstate |=
-					 BT_COEX_STATE_WIFI_RSSI_1_LOW;
-				rtlpcipriv->bt_coexist.cstate &=
-					 ~BT_COEX_STATE_WIFI_RSSI_1_HIGH;
+				rtlpriv->btcoexist.cstate |=
+					BT_COEX_STATE_WIFI_RSSI_1_LOW;
+				rtlpriv->btcoexist.cstate &=
+					~BT_COEX_STATE_WIFI_RSSI_1_HIGH;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state switch to Low\n");
 			} else {
@@ -148,22 +150,22 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
 		if (rssi_thresh > rssi_thresh1) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "[DM][BT], RSSI_1 thresh error!!\n");
-			return rtlpcipriv->bt_coexist.bt_pre_rssi_state;
+			return rtlpriv->btcoexist.bt_pre_rssi_state;
 		}
 
-		if ((rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_LOW) ||
-		    (rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_STAY_LOW)) {
-			if (smooth >=
+		if ((rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_LOW) ||
+		    (rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_STAY_LOW)) {
+			if (undecoratedsmoothed_pwdb >=
 			    (rssi_thresh+BT_FW_COEX_THRESH_TOL)) {
 				bt_rssi_state = BT_RSSI_STATE_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate |=
-					 BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate &=
-					 ~BT_COEX_STATE_WIFI_RSSI_1_LOW;
-				rtlpcipriv->bt_coexist.cstate &=
-					 ~BT_COEX_STATE_WIFI_RSSI_1_HIGH;
+				rtlpriv->btcoexist.cstate |=
+					BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
+				rtlpriv->btcoexist.cstate &=
+					~BT_COEX_STATE_WIFI_RSSI_1_LOW;
+				rtlpriv->btcoexist.cstate &=
+					~BT_COEX_STATE_WIFI_RSSI_1_HIGH;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state switch to Medium\n");
 			} else {
@@ -171,28 +173,28 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state stay at Low\n");
 			}
-		} else if ((rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-			   BT_RSSI_STATE_MEDIUM) ||
-			   (rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-			   BT_RSSI_STATE_STAY_MEDIUM)) {
-			if (smooth >= (rssi_thresh1 +
-			    BT_FW_COEX_THRESH_TOL)) {
+		} else if ((rtlpriv->btcoexist.bt_pre_rssi_state ==
+			    BT_RSSI_STATE_MEDIUM) ||
+			   (rtlpriv->btcoexist.bt_pre_rssi_state ==
+			    BT_RSSI_STATE_STAY_MEDIUM)) {
+			if (undecoratedsmoothed_pwdb >=
+			    (rssi_thresh1 + BT_FW_COEX_THRESH_TOL)) {
 				bt_rssi_state = BT_RSSI_STATE_HIGH;
-				rtlpcipriv->bt_coexist.cstate |=
-					 BT_COEX_STATE_WIFI_RSSI_1_HIGH;
-				rtlpcipriv->bt_coexist.cstate &=
-					 ~BT_COEX_STATE_WIFI_RSSI_1_LOW;
-				rtlpcipriv->bt_coexist.cstate &=
-					 ~BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
+				rtlpriv->btcoexist.cstate |=
+					BT_COEX_STATE_WIFI_RSSI_1_HIGH;
+				rtlpriv->btcoexist.cstate &=
+					~BT_COEX_STATE_WIFI_RSSI_1_LOW;
+				rtlpriv->btcoexist.cstate &=
+					~BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state switch to High\n");
-			} else if (smooth < rssi_thresh) {
+			} else if (undecoratedsmoothed_pwdb < rssi_thresh) {
 				bt_rssi_state = BT_RSSI_STATE_LOW;
-				rtlpcipriv->bt_coexist.cstate |=
+				rtlpriv->btcoexist.cstate |=
 					BT_COEX_STATE_WIFI_RSSI_1_LOW;
-				rtlpcipriv->bt_coexist.cstate &=
+				rtlpriv->btcoexist.cstate &=
 					~BT_COEX_STATE_WIFI_RSSI_1_HIGH;
-				rtlpcipriv->bt_coexist.cstate &=
+				rtlpriv->btcoexist.cstate &=
 					~BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state switch to Low\n");
@@ -202,13 +204,13 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
 					 "[DM][BT], RSSI_1 state stay at Medium\n");
 			}
 		} else {
-			if (smooth < rssi_thresh1) {
+			if (undecoratedsmoothed_pwdb < rssi_thresh1) {
 				bt_rssi_state = BT_RSSI_STATE_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate |=
+				rtlpriv->btcoexist.cstate |=
 					BT_COEX_STATE_WIFI_RSSI_1_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate &=
+				rtlpriv->btcoexist.cstate &=
 					~BT_COEX_STATE_WIFI_RSSI_1_HIGH;
-				rtlpcipriv->bt_coexist.cstate &=
+				rtlpriv->btcoexist.cstate &=
 					~BT_COEX_STATE_WIFI_RSSI_1_LOW;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI_1 state switch to Medium\n");
@@ -219,38 +221,37 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
 			}
 		}
 	}
-
-	rtlpcipriv->bt_coexist.bt_pre_rssi_state1 = bt_rssi_state;
+	rtlpriv->btcoexist.bt_pre_rssi_state1 = bt_rssi_state;
 
 	return bt_rssi_state;
 }
 
-u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
-					 u8 level_num, u8 rssi_thresh,
-					 u8 rssi_thresh1)
+u8 rtl8723e_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
+					u8 level_num,
+					u8 rssi_thresh,
+					u8 rssi_thresh1)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	long smooth;
+	long undecoratedsmoothed_pwdb = 0;
 	u8 bt_rssi_state = 0;
 
-	smooth = rtl8723ae_dm_bt_get_rx_ss(hw);
+	undecoratedsmoothed_pwdb = rtl8723e_dm_bt_get_rx_ss(hw);
 
 	if (level_num == 2) {
-		rtlpcipriv->bt_coexist.cstate &=
-					 ~BT_COEX_STATE_WIFI_RSSI_MEDIUM;
-
-		if ((rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_LOW) ||
-		    (rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_STAY_LOW)){
-			if (smooth >=
+		rtlpriv->btcoexist.cstate &=
+			~BT_COEX_STATE_WIFI_RSSI_MEDIUM;
+
+		if ((rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_LOW) ||
+		    (rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_STAY_LOW)) {
+			if (undecoratedsmoothed_pwdb >=
 			    (rssi_thresh + BT_FW_COEX_THRESH_TOL)) {
 				bt_rssi_state = BT_RSSI_STATE_HIGH;
-				rtlpcipriv->bt_coexist.cstate |=
-					BT_COEX_STATE_WIFI_RSSI_HIGH;
-				rtlpcipriv->bt_coexist.cstate &=
-					~BT_COEX_STATE_WIFI_RSSI_LOW;
+				rtlpriv->btcoexist.cstate
+					|= BT_COEX_STATE_WIFI_RSSI_HIGH;
+				rtlpriv->btcoexist.cstate
+					&= ~BT_COEX_STATE_WIFI_RSSI_LOW;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state switch to High\n");
 			} else {
@@ -259,12 +260,12 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
 					 "[DM][BT], RSSI state stay at Low\n");
 			}
 		} else {
-			if (smooth < rssi_thresh) {
+			if (undecoratedsmoothed_pwdb < rssi_thresh) {
 				bt_rssi_state = BT_RSSI_STATE_LOW;
-				rtlpcipriv->bt_coexist.cstate |=
-					BT_COEX_STATE_WIFI_RSSI_LOW;
-				rtlpcipriv->bt_coexist.cstate &=
-					~BT_COEX_STATE_WIFI_RSSI_HIGH;
+				rtlpriv->btcoexist.cstate
+					|= BT_COEX_STATE_WIFI_RSSI_LOW;
+				rtlpriv->btcoexist.cstate
+					&= ~BT_COEX_STATE_WIFI_RSSI_HIGH;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state switch to Low\n");
 			} else {
@@ -277,20 +278,20 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
 		if (rssi_thresh > rssi_thresh1) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "[DM][BT], RSSI thresh error!!\n");
-			return rtlpcipriv->bt_coexist.bt_pre_rssi_state;
+			return rtlpriv->btcoexist.bt_pre_rssi_state;
 		}
-		if ((rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_LOW) ||
-		    (rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-		    BT_RSSI_STATE_STAY_LOW)) {
-			if (smooth >=
+		if ((rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_LOW) ||
+		    (rtlpriv->btcoexist.bt_pre_rssi_state ==
+		     BT_RSSI_STATE_STAY_LOW)) {
+			if (undecoratedsmoothed_pwdb >=
 			    (rssi_thresh + BT_FW_COEX_THRESH_TOL)) {
 				bt_rssi_state = BT_RSSI_STATE_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					|= BT_COEX_STATE_WIFI_RSSI_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_LOW;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_HIGH;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state switch to Medium\n");
@@ -299,28 +300,28 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state stay at Low\n");
 			}
-		} else if ((rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-			   BT_RSSI_STATE_MEDIUM) ||
-			   (rtlpcipriv->bt_coexist.bt_pre_rssi_state ==
-			   BT_RSSI_STATE_STAY_MEDIUM)) {
-			if (smooth >=
+		} else if ((rtlpriv->btcoexist.bt_pre_rssi_state ==
+				BT_RSSI_STATE_MEDIUM) ||
+			(rtlpriv->btcoexist.bt_pre_rssi_state ==
+				BT_RSSI_STATE_STAY_MEDIUM)) {
+			if (undecoratedsmoothed_pwdb >=
 			    (rssi_thresh1 + BT_FW_COEX_THRESH_TOL)) {
 				bt_rssi_state = BT_RSSI_STATE_HIGH;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					|= BT_COEX_STATE_WIFI_RSSI_HIGH;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_LOW;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_MEDIUM;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state switch to High\n");
-			} else if (smooth < rssi_thresh) {
+			} else if (undecoratedsmoothed_pwdb < rssi_thresh) {
 				bt_rssi_state = BT_RSSI_STATE_LOW;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					|= BT_COEX_STATE_WIFI_RSSI_LOW;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_HIGH;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_MEDIUM;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state switch to Low\n");
@@ -330,13 +331,13 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
 					 "[DM][BT], RSSI state stay at Medium\n");
 			}
 		} else {
-			if (smooth < rssi_thresh1) {
+			if (undecoratedsmoothed_pwdb < rssi_thresh1) {
 				bt_rssi_state = BT_RSSI_STATE_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					|= BT_COEX_STATE_WIFI_RSSI_MEDIUM;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_HIGH;
-				rtlpcipriv->bt_coexist.cstate
+				rtlpriv->btcoexist.cstate
 					&= ~BT_COEX_STATE_WIFI_RSSI_LOW;
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 					 "[DM][BT], RSSI state switch to Medium\n");
@@ -347,31 +348,32 @@ u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
 			}
 		}
 	}
-
-	rtlpcipriv->bt_coexist.bt_pre_rssi_state = bt_rssi_state;
+	rtlpriv->btcoexist.bt_pre_rssi_state = bt_rssi_state;
 	return bt_rssi_state;
 }
 
-long rtl8723ae_dm_bt_get_rx_ss(struct ieee80211_hw *hw)
+long rtl8723e_dm_bt_get_rx_ss(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	long smooth = 0;
-
-	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
-		smooth = GET_UNDECORATED_AVERAGE_RSSI(rtlpriv);
-	else
-		smooth = rtlpriv->dm.entry_min_undec_sm_pwdb;
+	long undecoratedsmoothed_pwdb = 0;
 
+	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED) {
+		undecoratedsmoothed_pwdb =
+			GET_UNDECORATED_AVERAGE_RSSI(rtlpriv);
+	} else {
+		undecoratedsmoothed_pwdb
+			= rtlpriv->dm.entry_min_undec_sm_pwdb;
+	}
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_get_rx_ss() = %ld\n", smooth);
+		 "rtl8723e_dm_bt_get_rx_ss() = %ld\n",
+		 undecoratedsmoothed_pwdb);
 
-	return smooth;
+	return undecoratedsmoothed_pwdb;
 }
 
-void rtl8723ae_dm_bt_balance(struct ieee80211_hw *hw,
-			     bool balance_on, u8 ms0, u8 ms1)
+void rtl8723e_dm_bt_balance(struct ieee80211_hw *hw,
+			    bool balance_on, u8 ms0, u8 ms1)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter[3] = {0};
 
@@ -379,27 +381,26 @@ void rtl8723ae_dm_bt_balance(struct ieee80211_hw *hw,
 		h2c_parameter[2] = 1;
 		h2c_parameter[1] = ms1;
 		h2c_parameter[0] = ms0;
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	} else {
 		h2c_parameter[2] = 0;
 		h2c_parameter[1] = 0;
 		h2c_parameter[0] = 0;
 	}
-	rtlpcipriv->bt_coexist.balance_on = balance_on;
+	rtlpriv->btcoexist.balance_on = balance_on;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 		 "[DM][BT], Balance=[%s:%dms:%dms], write 0xc=0x%x\n",
-		 balance_on ? "ON" : "OFF", ms0, ms1,
-		 h2c_parameter[0]<<16 | h2c_parameter[1]<<8 | h2c_parameter[2]);
+		 balance_on ? "ON" : "OFF", ms0, ms1, h2c_parameter[0]<<16 |
+		 h2c_parameter[1]<<8 | h2c_parameter[2]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0xc, 3, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0xc, 3, h2c_parameter);
 }
 
 
-void rtl8723ae_dm_bt_agc_table(struct ieee80211_hw *hw, u8 type)
+void rtl8723e_dm_bt_agc_table(struct ieee80211_hw *hw, u8 type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 
 	if (type == BT_AGCTABLE_OFF) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
@@ -410,15 +411,15 @@ void rtl8723ae_dm_bt_agc_table(struct ieee80211_hw *hw, u8 type)
 		rtl_write_dword(rtlpriv, 0xc78, 0x611f0001);
 		rtl_write_dword(rtlpriv, 0xc78, 0x60200001);
 
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0x32000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0x71000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0xb0000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0xfc000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_G1, 0xfffff, 0x30355);
 	} else if (type == BT_AGCTABLE_ON) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
@@ -429,25 +430,24 @@ void rtl8723ae_dm_bt_agc_table(struct ieee80211_hw *hw, u8 type)
 		rtl_write_dword(rtlpriv, 0xc78, 0x4b1f0001);
 		rtl_write_dword(rtlpriv, 0xc78, 0x4a200001);
 
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0xdc000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0x90000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0x51000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_AGC_HP, 0xfffff, 0x12000);
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A,
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A,
 					RF_RX_G1, 0xfffff, 0x00355);
 
-		rtlpcipriv->bt_coexist.sw_coexist_all_off = false;
+		rtlpriv->btcoexist.sw_coexist_all_off = false;
 	}
 }
 
-void rtl8723ae_dm_bt_bback_off_level(struct ieee80211_hw *hw, u8 type)
+void rtl8723e_dm_bt_bb_back_off_level(struct ieee80211_hw *hw, u8 type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 
 	if (type == BT_BB_BACKOFF_OFF) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
@@ -457,87 +457,81 @@ void rtl8723ae_dm_bt_bback_off_level(struct ieee80211_hw *hw, u8 type)
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "[BT]BBBackOffLevel On!\n");
 		rtl_write_dword(rtlpriv, 0xc04, 0x3a07611);
-		rtlpcipriv->bt_coexist.sw_coexist_all_off = false;
+		rtlpriv->btcoexist.sw_coexist_all_off = false;
 	}
 }
 
-void rtl8723ae_dm_bt_fw_coex_all_off(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_fw_coex_all_off(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_fw_coex_all_off()\n");
+		 "rtl8723e_dm_bt_fw_coex_all_off()\n");
 
-	if (rtlpcipriv->bt_coexist.fw_coexist_all_off)
+	if (rtlpriv->btcoexist.fw_coexist_all_off)
 		return;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_fw_coex_all_off(), real Do\n");
-	rtl8723ae_dm_bt_fw_coex_all_off_8723a(hw);
-	rtlpcipriv->bt_coexist.fw_coexist_all_off = true;
+		 "rtl8723e_dm_bt_fw_coex_all_off(), real Do\n");
+	rtl8723e_dm_bt_fw_coex_all_off_8723a(hw);
+	rtlpriv->btcoexist.fw_coexist_all_off = true;
 }
 
-void rtl8723ae_dm_bt_sw_coex_all_off(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_sw_coex_all_off(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_sw_coex_all_off()\n");
+		 "rtl8723e_dm_bt_sw_coex_all_off()\n");
 
-	if (rtlpcipriv->bt_coexist.sw_coexist_all_off)
+	if (rtlpriv->btcoexist.sw_coexist_all_off)
 		return;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_sw_coex_all_off(), real Do\n");
-	rtl8723ae_dm_bt_sw_coex_all_off_8723a(hw);
-	rtlpcipriv->bt_coexist.sw_coexist_all_off = true;
+		 "rtl8723e_dm_bt_sw_coex_all_off(), real Do\n");
+	rtl8723e_dm_bt_sw_coex_all_off_8723a(hw);
+	rtlpriv->btcoexist.sw_coexist_all_off = true;
 }
 
-void rtl8723ae_dm_bt_hw_coex_all_off(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_hw_coex_all_off(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_hw_coex_all_off()\n");
+		 "rtl8723e_dm_bt_hw_coex_all_off()\n");
 
-	if (rtlpcipriv->bt_coexist.hw_coexist_all_off)
+	if (rtlpriv->btcoexist.hw_coexist_all_off)
 		return;
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "rtl8723ae_dm_bt_hw_coex_all_off(), real Do\n");
+		 "rtl8723e_dm_bt_hw_coex_all_off(), real Do\n");
 
-	rtl8723ae_dm_bt_hw_coex_all_off_8723a(hw);
+	rtl8723e_dm_bt_hw_coex_all_off_8723a(hw);
 
-	rtlpcipriv->bt_coexist.hw_coexist_all_off = true;
+	rtlpriv->btcoexist.hw_coexist_all_off = true;
 }
 
-void rtl8723ae_btdm_coex_all_off(struct ieee80211_hw *hw)
+void rtl8723e_btdm_coex_all_off(struct ieee80211_hw *hw)
 {
-	rtl8723ae_dm_bt_fw_coex_all_off(hw);
-	rtl8723ae_dm_bt_sw_coex_all_off(hw);
-	rtl8723ae_dm_bt_hw_coex_all_off(hw);
+	rtl8723e_dm_bt_fw_coex_all_off(hw);
+	rtl8723e_dm_bt_sw_coex_all_off(hw);
+	rtl8723e_dm_bt_hw_coex_all_off(hw);
 }
 
-bool rtl8723ae_dm_bt_is_coexist_state_changed(struct ieee80211_hw *hw)
+bool rtl8723e_dm_bt_is_coexist_state_changed(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if ((rtlpcipriv->bt_coexist.previous_state ==
-	    rtlpcipriv->bt_coexist.cstate) &&
-	    (rtlpcipriv->bt_coexist.previous_state_h ==
-	    rtlpcipriv->bt_coexist.cstate_h))
+	if ((rtlpriv->btcoexist.previous_state == rtlpriv->btcoexist.cstate) &&
+	    (rtlpriv->btcoexist.previous_state_h ==
+	     rtlpriv->btcoexist.cstate_h))
 		return false;
-	else
-		return true;
+	return true;
 }
 
-bool rtl8723ae_dm_bt_is_wifi_up_link(struct ieee80211_hw *hw)
+bool rtl8723e_dm_bt_is_wifi_up_link(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (rtlpriv->link_info.tx_busy_traffic)
 		return true;
-	else
-		return false;
+	return false;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h
index 76f4d12..bcd64a2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h
@@ -53,8 +53,8 @@
 #define BT_COEX_STATE_WIFI_LEGACY		BIT(3)
 
 #define BT_COEX_STATE_WIFI_RSSI_LOW		BIT(4)
-#define BT_COEX_STATE_WIFI_RSSI_MEDIUM		BIT(5)
-#define BT_COEX_STATE_WIFI_RSSI_HIGH		BIT(6)
+#define BT_COEX_STATE_WIFI_RSSI_MEDIUM	BIT(5)
+#define BT_COEX_STATE_WIFI_RSSI_HIGH	BIT(6)
 #define BT_COEX_STATE_DEC_BT_POWER		BIT(7)
 
 #define BT_COEX_STATE_WIFI_IDLE			BIT(8)
@@ -78,7 +78,7 @@
 #define BT_COEX_STATE_WIFI_RSSI_1_MEDIUM	BIT(25)
 #define BT_COEX_STATE_WIFI_RSSI_1_HIGH		BIT(26)
 
-#define BT_COEX_STATE_BTINFO_COMMON		BIT(30)
+#define BT_COEX_STATE_BTINFO_COMMON			BIT(30)
 #define BT_COEX_STATE_BTINFO_B_HID_SCOESCO	BIT(31)
 #define BT_COEX_STATE_BTINFO_B_FTP_A2DP		BIT(29)
 
@@ -133,28 +133,26 @@
 #define	BTINFO_B_SCO_ESCO			BIT(1)
 #define	BTINFO_B_CONNECTION			BIT(0)
 
+void rtl8723e_btdm_coex_all_off(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_fw_coex_all_off(struct ieee80211_hw *hw);
 
-void rtl8723ae_btdm_coex_all_off(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_fw_coex_all_off(struct ieee80211_hw *hw);
-
-void rtl8723ae_dm_bt_sw_coex_all_off(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_hw_coex_all_off(struct ieee80211_hw *hw);
-long rtl8723ae_dm_bt_get_rx_ss(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_balance(struct ieee80211_hw *hw,
+void rtl8723e_dm_bt_sw_coex_all_off(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_hw_coex_all_off(struct ieee80211_hw *hw);
+long rtl8723e_dm_bt_get_rx_ss(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_balance(struct ieee80211_hw *hw,
 			    bool balance_on, u8 ms0, u8 ms1);
-void rtl8723ae_dm_bt_agc_table(struct ieee80211_hw *hw, u8 type);
-void rtl8723ae_dm_bt_bback_off_level(struct ieee80211_hw *hw, u8 type);
-u8 rtl8723ae_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
+void rtl8723e_dm_bt_agc_table(struct ieee80211_hw *hw, u8 tyep);
+void rtl8723e_dm_bt_bb_back_off_level(struct ieee80211_hw *hw, u8 type);
+u8 rtl8723e_dm_bt_check_coex_rssi_state(struct ieee80211_hw *hw,
 					u8 level_num, u8 rssi_thresh,
 					u8 rssi_thresh1);
-u8 rtl8723ae_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
-					 u8  level_num, u8 rssi_thresh,
+u8 rtl8723e_dm_bt_check_coex_rssi_state1(struct ieee80211_hw *hw,
+					 u8 level_num, u8 rssi_thresh,
 					 u8 rssi_thresh1);
 void _rtl8723_dm_bt_check_wifi_state(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_reject_ap_aggregated_packet(struct ieee80211_hw *hw,
-						bool reject);
-
-bool rtl8723ae_dm_bt_is_coexist_state_changed(struct ieee80211_hw *hw);
-bool rtl8723ae_dm_bt_is_wifi_up_link(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_reject_ap_aggregated_packet(struct ieee80211_hw *hw,
+						bool b_reject);
+bool rtl8723e_dm_bt_is_coexist_state_changed(struct ieee80211_hw *hw);
+bool rtl8723e_dm_bt_is_wifi_up_link(struct ieee80211_hw *hw);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c
index f76c50f..747958a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c
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
@@ -25,34 +21,33 @@
  *
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 #include "hal_btc.h"
 #include "../pci.h"
 #include "phy.h"
-#include "../rtl8723com/phy_common.h"
 #include "fw.h"
-#include "../rtl8723com/fw_common.h"
 #include "reg.h"
 #include "def.h"
+#include "../rtl8723com/phy_common.h"
+
+static struct bt_coexist_8723 hal_coex_8723;
 
-void rtl8723ae_bt_coex_off_before_lps(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_turn_off_bt_coexist_before_enter_lps(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 
-	if (!rtlpcipriv->bt_coexist.bt_coexistence)
+	if (!rtlpriv->btcoexist.bt_coexistence)
 		return;
 
 	if (ppsc->inactiveps) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BT][DM], Before enter IPS, turn off all Coexist DM\n");
-		rtlpcipriv->bt_coexist.cstate = 0;
-		rtlpcipriv->bt_coexist.previous_state = 0;
-		rtlpcipriv->bt_coexist.cstate_h = 0;
-		rtlpcipriv->bt_coexist.previous_state_h = 0;
-		rtl8723ae_btdm_coex_all_off(hw);
+			"[BT][DM], Before enter IPS, turn off all Coexist DM\n");
+		rtlpriv->btcoexist.cstate = 0;
+		rtlpriv->btcoexist.previous_state = 0;
+		rtlpriv->btcoexist.cstate_h = 0;
+		rtlpriv->btcoexist.previous_state_h = 0;
+		rtl8723e_btdm_coex_all_off(hw);
 	}
 }
 
@@ -60,10 +55,8 @@ static enum rt_media_status mgnt_link_status_query(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	enum rt_media_status m_status = RT_MEDIA_DISCONNECT;
-
+	enum rt_media_status    m_status = RT_MEDIA_DISCONNECT;
 	u8 bibss = (mac->opmode == NL80211_IFTYPE_ADHOC) ? 1 : 0;
-
 	if (bibss || rtlpriv->mac80211.link_state >= MAC80211_LINKED)
 		m_status = RT_MEDIA_CONNECT;
 
@@ -71,15 +64,14 @@ static enum rt_media_status mgnt_link_status_query(struct ieee80211_hw *hw)
 }
 
 void rtl_8723e_bt_wifi_media_status_notify(struct ieee80211_hw *hw,
-					   bool mstatus)
+						bool mstatus)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	u8 h2c_parameter[3] = {0};
 	u8 chnl;
 
-	if (!rtlpcipriv->bt_coexist.bt_coexistence)
+	if (!rtlpriv->btcoexist.bt_coexistence)
 		return;
 
 	if (RT_MEDIA_CONNECT == mstatus)
@@ -98,14 +90,13 @@ void rtl_8723e_bt_wifi_media_status_notify(struct ieee80211_hw *hw,
 		h2c_parameter[2] = 0x20;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "[BTCoex], FW write 0x19 = 0x%x\n",
+		 "[BTCoex], FW write 0x19=0x%x\n",
 		 h2c_parameter[0]<<16|h2c_parameter[1]<<8|h2c_parameter[2]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x19, 3, h2c_parameter);
-
+	rtl8723e_fill_h2c_cmd(hw, 0x19, 3, h2c_parameter);
 }
 
-static bool rtl8723ae_dm_bt_is_wifi_busy(struct ieee80211_hw *hw)
+static bool rtl8723e_dm_bt_is_wifi_busy(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	if (rtlpriv->link_info.busytraffic ||
@@ -116,12 +107,12 @@ static bool rtl8723ae_dm_bt_is_wifi_busy(struct ieee80211_hw *hw)
 		return false;
 }
 
-static void rtl8723ae_dm_bt_set_fw_3a(struct ieee80211_hw *hw,
-				      u8 byte1, u8 byte2, u8 byte3,
-				      u8 byte4, u8 byte5)
+static void rtl8723e_dm_bt_set_fw_3a(struct ieee80211_hw *hw,
+				     u8 byte1, u8 byte2, u8 byte3, u8 byte4,
+				     u8 byte5)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u8 h2c_parameter[5] = {0};
+	u8 h2c_parameter[5];
 
 	h2c_parameter[0] = byte1;
 	h2c_parameter[1] = byte2;
@@ -129,37 +120,37 @@ static void rtl8723ae_dm_bt_set_fw_3a(struct ieee80211_hw *hw,
 	h2c_parameter[3] = byte4;
 	h2c_parameter[4] = byte5;
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], FW write 0x3a(4bytes) = 0x%x%8x\n",
-		 h2c_parameter[0], h2c_parameter[1]<<24 | h2c_parameter[2]<<16 |
-		 h2c_parameter[3]<<8 | h2c_parameter[4]);
-	rtl8723ae_fill_h2c_cmd(hw, 0x3a, 5, h2c_parameter);
+		"[BTCoex], FW write 0x3a(4bytes)=0x%x%8x\n",
+		h2c_parameter[0], h2c_parameter[1]<<24 |
+		h2c_parameter[2]<<16 | h2c_parameter[3]<<8 |
+		h2c_parameter[4]);
+	rtl8723e_fill_h2c_cmd(hw, 0x3a, 5, h2c_parameter);
 }
 
-static bool rtl8723ae_dm_bt_need_to_dec_bt_pwr(struct ieee80211_hw *hw)
+static bool rtl8723e_dm_bt_need_to_dec_bt_pwr(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (mgnt_link_status_query(hw) == RT_MEDIA_CONNECT) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "Need to decrease bt power\n");
-		rtlpcipriv->bt_coexist.cstate |= BT_COEX_STATE_DEC_BT_POWER;
-		return true;
+			"Need to decrease bt power\n");
+			rtlpriv->btcoexist.cstate |=
+			BT_COEX_STATE_DEC_BT_POWER;
+			return true;
 	}
 
-	rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_DEC_BT_POWER;
+	rtlpriv->btcoexist.cstate &= ~BT_COEX_STATE_DEC_BT_POWER;
 	return false;
 }
 
-static bool rtl8723ae_dm_bt_is_same_coexist_state(struct ieee80211_hw *hw)
+static bool rtl8723e_dm_bt_is_same_coexist_state(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 
-	if ((rtlpcipriv->bt_coexist.previous_state ==
-	    rtlpcipriv->bt_coexist.cstate) &&
-	    (rtlpcipriv->bt_coexist.previous_state_h ==
-	    rtlpcipriv->bt_coexist.cstate_h)) {
+	if ((rtlpriv->btcoexist.previous_state ==
+	     rtlpriv->btcoexist.cstate) &&
+	    (rtlpriv->btcoexist.previous_state_h ==
+	     rtlpriv->btcoexist.cstate_h)) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[DM][BT], Coexist state do not chang!!\n");
 		return true;
@@ -170,86 +161,84 @@ static bool rtl8723ae_dm_bt_is_same_coexist_state(struct ieee80211_hw *hw)
 	}
 }
 
-static void rtl8723ae_dm_bt_set_coex_table(struct ieee80211_hw *hw,
-					   u32 val_0x6c0, u32 val_0x6c8,
-					   u32 val_0x6cc)
+static void rtl8723e_dm_bt_set_coex_table(struct ieee80211_hw *hw,
+					  u32 val_0x6c0, u32 val_0x6c8,
+					  u32 val_0x6cc)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "set coex table, set 0x6c0 = 0x%x\n", val_0x6c0);
+		 "set coex table, set 0x6c0=0x%x\n", val_0x6c0);
 	rtl_write_dword(rtlpriv, 0x6c0, val_0x6c0);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "set coex table, set 0x6c8 = 0x%x\n", val_0x6c8);
+		 "set coex table, set 0x6c8=0x%x\n", val_0x6c8);
 	rtl_write_dword(rtlpriv, 0x6c8, val_0x6c8);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "set coex table, set 0x6cc = 0x%x\n", val_0x6cc);
+		 "set coex table, set 0x6cc=0x%x\n", val_0x6cc);
 	rtl_write_byte(rtlpriv, 0x6cc, val_0x6cc);
 }
 
-static void rtl8723ae_dm_bt_set_hw_pta_mode(struct ieee80211_hw *hw, bool mode)
+static void rtl8723e_dm_bt_set_hw_pta_mode(struct ieee80211_hw *hw, bool b_mode)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (BT_PTA_MODE_ON == mode) {
+	if (BT_PTA_MODE_ON == b_mode) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE, "PTA mode on, ");
 		/*  Enable GPIO 0/1/2/3/8 pins for bt */
 		rtl_write_byte(rtlpriv, 0x40, 0x20);
-		rtlpcipriv->bt_coexist.hw_coexist_all_off = false;
+		rtlpriv->btcoexist.hw_coexist_all_off = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE, "PTA mode off\n");
 		rtl_write_byte(rtlpriv, 0x40, 0x0);
 	}
 }
 
-static void rtl8723ae_dm_bt_set_sw_rf_rx_lpf_corner(struct ieee80211_hw *hw,
-						    u8 type)
+static void rtl8723e_dm_bt_set_sw_rf_rx_lpf_corner(struct ieee80211_hw *hw,
+						   u8 type)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (BT_RF_RX_LPF_CORNER_SHRINK == type) {
-		/* Shrink RF Rx LPF corner, 0x1e[7:4]=1111 ==> [11:4] by Jenyu*/
+		/* Shrink RF Rx LPF corner, 0x1e[7:4]=1111 ==> [11:4] */
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "Shrink RF Rx LPF corner!!\n");
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A, 0x1e, 0xfffff,
-					0xf0ff7);
-		rtlpcipriv->bt_coexist.sw_coexist_all_off = false;
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A, 0x1e,
+					0xfffff, 0xf0ff7);
+		rtlpriv->btcoexist.sw_coexist_all_off = false;
 	} else if (BT_RF_RX_LPF_CORNER_RESUME == type) {
 		/*Resume RF Rx LPF corner*/
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "Resume RF Rx LPF corner!!\n");
-		rtl8723ae_phy_set_rf_reg(hw, RF90_PATH_A, 0x1e, 0xfffff,
-			rtlpcipriv->bt_coexist.bt_rfreg_origin_1e);
+		rtl8723e_phy_set_rf_reg(hw, RF90_PATH_A, 0x1e, 0xfffff,
+					rtlpriv->btcoexist.bt_rfreg_origin_1e);
 	}
 }
 
-static void rtl8723ae_bt_set_penalty_tx_rate_adap(struct ieee80211_hw *hw,
-						  u8 ra_type)
+static void dm_bt_set_sw_penalty_tx_rate_adapt(struct ieee80211_hw *hw,
+					       u8 ra_type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
-	u8 tmu1;
+	u8 tmp_u1;
 
-	tmu1 = rtl_read_byte(rtlpriv, 0x4fd);
-	tmu1 |= BIT(0);
+	tmp_u1 = rtl_read_byte(rtlpriv, 0x4fd);
+	tmp_u1 |= BIT(0);
 	if (BT_TX_RATE_ADAPTIVE_LOW_PENALTY == ra_type) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "Tx rate adaptive, set low penalty!!\n");
-		tmu1 &= ~BIT(2);
-		rtlpcipriv->bt_coexist.sw_coexist_all_off = false;
+			"Tx rate adaptive, set low penalty!!\n");
+		tmp_u1 &= ~BIT(2);
+		rtlpriv->btcoexist.sw_coexist_all_off = false;
 	} else if (BT_TX_RATE_ADAPTIVE_NORMAL == ra_type) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "Tx rate adaptive, set normal!!\n");
-		tmu1 |= BIT(2);
+			"Tx rate adaptive, set normal!!\n");
+		tmp_u1 |= BIT(2);
 	}
-	rtl_write_byte(rtlpriv, 0x4fd, tmu1);
+
+	rtl_write_byte(rtlpriv, 0x4fd, tmp_u1);
 }
 
-static void rtl8723ae_dm_bt_btdm_structure_reload(struct ieee80211_hw *hw,
+static void rtl8723e_dm_bt_btdm_structure_reload(struct ieee80211_hw *hw,
 						 struct btdm_8723 *btdm)
 {
 	btdm->all_off = false;
@@ -292,32 +281,31 @@ static void rtl8723ae_dm_bt_btdm_structure_reload(struct ieee80211_hw *hw,
 	btdm->dec_bt_pwr = false;
 }
 
-static void dm_bt_btdm_structure_reload_all_off(struct ieee80211_hw *hw,
-						struct btdm_8723 *btdm)
+static void rtl8723e_dm_bt_btdm_structure_reload_all_off(struct ieee80211_hw *hw,
+							 struct btdm_8723 *btdm)
 {
-	rtl8723ae_dm_bt_btdm_structure_reload(hw, btdm);
+	rtl8723e_dm_bt_btdm_structure_reload(hw, btdm);
 	btdm->all_off = true;
 	btdm->pta_on = false;
 	btdm->wlan_act_hi = 0x10;
 }
 
-static bool rtl8723ae_dm_bt_is_2_ant_common_action(struct ieee80211_hw *hw)
+static bool rtl8723e_dm_bt_is_2_ant_common_action(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct btdm_8723 btdm8723;
-	bool common = false;
+	bool b_common = false;
 
-	rtl8723ae_dm_bt_btdm_structure_reload(hw, &btdm8723);
+	rtl8723e_dm_bt_btdm_structure_reload(hw, &btdm8723);
 
-	if (!rtl8723ae_dm_bt_is_wifi_busy(hw)
-	    && !rtlpcipriv->bt_coexist.bt_busy) {
+	if (!rtl8723e_dm_bt_is_wifi_busy(hw) &&
+	    !rtlpriv->btcoexist.bt_busy) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "Wifi idle + Bt idle, bt coex mechanism always off!!\n");
-		dm_bt_btdm_structure_reload_all_off(hw, &btdm8723);
-		common = true;
-	} else if (rtl8723ae_dm_bt_is_wifi_busy(hw)
-		   && !rtlpcipriv->bt_coexist.bt_busy) {
+		rtl8723e_dm_bt_btdm_structure_reload_all_off(hw, &btdm8723);
+		b_common = true;
+	} else if (rtl8723e_dm_bt_is_wifi_busy(hw) &&
+		   !rtlpriv->btcoexist.bt_busy) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "Wifi non-idle + Bt disabled/idle!!\n");
 		btdm8723.low_penalty_rate_adaptive = true;
@@ -338,17 +326,17 @@ static bool rtl8723ae_dm_bt_is_2_ant_common_action(struct ieee80211_hw *hw)
 		btdm8723.tdma_dac_swing = TDMA_DAC_SWING_OFF;
 		btdm8723.b2_ant_hid_en = false;
 
-		common = true;
-	} else if (rtlpcipriv->bt_coexist.bt_busy) {
+		b_common = true;
+	} else if (rtlpriv->btcoexist.bt_busy) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "Bt non-idle!\n");
+			"Bt non-idle!\n");
 		if (mgnt_link_status_query(hw) == RT_MEDIA_CONNECT) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "Wifi connection exist\n");
-			common = false;
+				"Wifi connection exist\n");
+			b_common = false;
 		} else {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "No Wifi connection!\n");
+				"No Wifi connection!\n");
 			btdm8723.rf_rx_lpf_shrink = true;
 			btdm8723.low_penalty_rate_adaptive = false;
 			btdm8723.reject_aggre_pkt = false;
@@ -367,27 +355,28 @@ static bool rtl8723ae_dm_bt_is_2_ant_common_action(struct ieee80211_hw *hw)
 			btdm8723.tdma_dac_swing = TDMA_DAC_SWING_OFF;
 			btdm8723.b2_ant_hid_en = false;
 
-			common = true;
+			b_common = true;
 		}
 	}
 
-	if (rtl8723ae_dm_bt_need_to_dec_bt_pwr(hw))
+	if (rtl8723e_dm_bt_need_to_dec_bt_pwr(hw))
 		btdm8723.dec_bt_pwr = true;
 
-	if (common)
-		rtlpcipriv->bt_coexist.cstate |= BT_COEX_STATE_BTINFO_COMMON;
+	if (b_common)
+		rtlpriv->btcoexist.cstate |=
+			BT_COEX_STATE_BTINFO_COMMON;
 
-	if (common && rtl8723ae_dm_bt_is_coexist_state_changed(hw))
-		rtl8723ae_dm_bt_set_bt_dm(hw, &btdm8723);
+	if (b_common && rtl8723e_dm_bt_is_coexist_state_changed(hw))
+		rtl8723e_dm_bt_set_bt_dm(hw, &btdm8723);
 
-	return common;
+	return b_common;
 }
 
-static void rtl8723ae_dm_bt_set_sw_full_time_dac_swing(struct ieee80211_hw *hw,
-						       bool sw_dac_swing_on,
-						       u32 sw_dac_swing_lvl)
+static void rtl8723e_dm_bt_set_sw_full_time_dac_swing(
+		struct ieee80211_hw *hw,
+		bool sw_dac_swing_on,
+		u32 sw_dac_swing_lvl)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (sw_dac_swing_on) {
@@ -395,7 +384,7 @@ static void rtl8723ae_dm_bt_set_sw_full_time_dac_swing(struct ieee80211_hw *hw,
 			 "[BTCoex], SwDacSwing = 0x%x\n", sw_dac_swing_lvl);
 		rtl8723_phy_set_bb_reg(hw, 0x880, 0xff000000,
 				       sw_dac_swing_lvl);
-		rtlpcipriv->bt_coexist.sw_coexist_all_off = false;
+		rtlpriv->btcoexist.sw_coexist_all_off = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "[BTCoex], SwDacSwing Off!\n");
@@ -403,10 +392,9 @@ static void rtl8723ae_dm_bt_set_sw_full_time_dac_swing(struct ieee80211_hw *hw,
 	}
 }
 
-static void rtl8723ae_dm_bt_set_fw_dec_bt_pwr(struct ieee80211_hw *hw,
-					      bool dec_bt_pwr)
+static void rtl8723e_dm_bt_set_fw_dec_bt_pwr(
+		struct ieee80211_hw *hw, bool dec_bt_pwr)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter[1] = {0};
 
@@ -414,87 +402,86 @@ static void rtl8723ae_dm_bt_set_fw_dec_bt_pwr(struct ieee80211_hw *hw,
 
 	if (dec_bt_pwr) {
 		h2c_parameter[0] |= BIT(1);
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	}
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], decrease Bt Power : %s, write 0x21 = 0x%x\n",
+		 "[BTCoex], decrease Bt Power : %s, write 0x21=0x%x\n",
 		 (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x21, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x21, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_2_ant_hid(struct ieee80211_hw *hw,
-					    bool enable, bool dac_swing_on)
+static void rtl8723e_dm_bt_set_fw_2_ant_hid(struct ieee80211_hw *hw,
+					    bool b_enable, bool b_dac_swing_on)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter[1] = {0};
 
-	if (enable) {
+	if (b_enable) {
 		h2c_parameter[0] |= BIT(0);
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	}
-	if (dac_swing_on)
+	if (b_dac_swing_on)
 		h2c_parameter[0] |= BIT(1); /* Dac Swing default enable */
+
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], turn 2-Ant+HID mode %s, DACSwing:%s, write 0x15 = 0x%x\n",
-		 (enable ? "ON!!" : "OFF!!"), (dac_swing_on ? "ON" : "OFF"),
+		 "[BTCoex], turn 2-Ant+HID mode %s, DACSwing:%s, write 0x15=0x%x\n",
+		 (b_enable ? "ON!!" : "OFF!!"), (b_dac_swing_on ? "ON" : "OFF"),
 		 h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x15, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x15, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_tdma_ctrl(struct ieee80211_hw *hw,
-					     bool enable, u8 ant_num, u8 nav_en,
-					     u8 dac_swing_en)
+static void rtl8723e_dm_bt_set_fw_tdma_ctrl(struct ieee80211_hw *hw,
+					    bool b_enable, u8 ant_num,
+					    u8 nav_en, u8 dac_swing_en)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	u8 h2c_parameter[1] = {0};
 	u8 h2c_parameter1[1] = {0};
 
 	h2c_parameter[0] = 0;
 	h2c_parameter1[0] = 0;
 
-	if (enable) {
+	if (b_enable) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "[BTCoex], set BT PTA update manager to trigger update!!\n");
 		h2c_parameter1[0] |= BIT(0);
 
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], turn TDMA mode ON!!\n");
+			"[BTCoex], turn TDMA mode ON!!\n");
 		h2c_parameter[0] |= BIT(0);		/* function enable */
 		if (TDMA_1ANT == ant_num) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TDMA_1ANT\n");
+			"[BTCoex], TDMA_1ANT\n");
 			h2c_parameter[0] |= BIT(1);
 		} else if (TDMA_2ANT == ant_num) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TDMA_2ANT\n");
+			"[BTCoex], TDMA_2ANT\n");
 		} else {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], Unknown Ant\n");
+			"[BTCoex], Unknown Ant\n");
 		}
 
 		if (TDMA_NAV_OFF == nav_en) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TDMA_NAV_OFF\n");
+			"[BTCoex], TDMA_NAV_OFF\n");
 		} else if (TDMA_NAV_ON == nav_en) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TDMA_NAV_ON\n");
+			"[BTCoex], TDMA_NAV_ON\n");
 			h2c_parameter[0] |= BIT(2);
 		}
 
 		if (TDMA_DAC_SWING_OFF == dac_swing_en) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TDMA_DAC_SWING_OFF\n");
+				"[BTCoex], TDMA_DAC_SWING_OFF\n");
 		} else if (TDMA_DAC_SWING_ON == dac_swing_en) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TDMA_DAC_SWING_ON\n");
+				"[BTCoex], TDMA_DAC_SWING_ON\n");
 			h2c_parameter[0] |= BIT(4);
 		}
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "[BTCoex], set BT PTA update manager to no update!!\n");
@@ -503,46 +490,46 @@ static void rtl8723ae_dm_bt_set_fw_tdma_ctrl(struct ieee80211_hw *hw,
 	}
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], FW2AntTDMA, write 0x26 = 0x%x\n",
+		 "[BTCoex], FW2AntTDMA, write 0x26=0x%x\n",
 		 h2c_parameter1[0]);
-	rtl8723ae_fill_h2c_cmd(hw, 0x26, 1, h2c_parameter1);
+	rtl8723e_fill_h2c_cmd(hw, 0x26, 1, h2c_parameter1);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], FW2AntTDMA, write 0x14 = 0x%x\n", h2c_parameter[0]);
-	rtl8723ae_fill_h2c_cmd(hw, 0x14, 1, h2c_parameter);
+		"[BTCoex], FW2AntTDMA, write 0x14=0x%x\n",
+		h2c_parameter[0]);
+	rtl8723e_fill_h2c_cmd(hw, 0x14, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_ignore_wlan_act(struct ieee80211_hw *hw,
-						   bool enable)
+static void rtl8723e_dm_bt_set_fw_ignore_wlan_act(struct ieee80211_hw *hw,
+						  bool b_enable)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	u8 h2c_parameter[1] = {0};
 
-	if (enable) {
+	if (b_enable) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], BT Ignore Wlan_Act !!\n");
+			"[BTCoex], BT Ignore Wlan_Act !!\n");
 		h2c_parameter[0] |= BIT(0);		/* function enable */
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], BT don't ignore Wlan_Act !!\n");
+			"[BTCoex], BT don't ignore Wlan_Act !!\n");
 	}
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], set FW for BT Ignore Wlan_Act, write 0x25 = 0x%x\n",
+		 "[BTCoex], set FW for BT Ignore Wlan_Act, write 0x25=0x%x\n",
 		 h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x25, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x25, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(struct ieee80211_hw *hw,
-						 bool enable, u8 ant_num,
-						 u8 nav_en)
+static void rtl8723e_dm_bt_set_fw_tra_tdma_ctrl(struct ieee80211_hw *hw,
+						bool b_enable, u8 ant_num,
+						u8 nav_en)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+
 	u8 h2c_parameter[2] = {0};
 
 	/* Only 8723 B cut should do this */
@@ -552,460 +539,467 @@ static void rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(struct ieee80211_hw *hw,
 		return;
 	}
 
-	if (enable) {
+	if (b_enable) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "[BTCoex], turn TTDMA mode ON!!\n");
-		h2c_parameter[0] |= BIT(0);		/* function enable */
+		h2c_parameter[0] |= BIT(0);	/* function enable */
 		if (TDMA_1ANT == ant_num) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "[BTCoex], TTDMA_1ANT\n");
 			h2c_parameter[0] |= BIT(1);
 		} else if (TDMA_2ANT == ant_num) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TTDMA_2ANT\n");
+			"[BTCoex], TTDMA_2ANT\n");
 		} else {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], Unknown Ant\n");
+			"[BTCoex], Unknown Ant\n");
 		}
 
 		if (TDMA_NAV_OFF == nav_en) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TTDMA_NAV_OFF\n");
+			"[BTCoex], TTDMA_NAV_OFF\n");
 		} else if (TDMA_NAV_ON == nav_en) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex], TTDMA_NAV_ON\n");
+			"[BTCoex], TTDMA_NAV_ON\n");
 			h2c_parameter[1] |= BIT(0);
 		}
 
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], turn TTDMA mode OFF!!\n");
+			"[BTCoex], turn TTDMA mode OFF!!\n");
 	}
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], FW Traditional TDMA, write 0x33 = 0x%x\n",
-		 h2c_parameter[0] << 8 | h2c_parameter[1]);
+		"[BTCoex], FW Traditional TDMA, write 0x33=0x%x\n",
+		h2c_parameter[0] << 8 | h2c_parameter[1]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x33, 2, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x33, 2, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_dac_swing_level(struct ieee80211_hw *hw,
-						   u8 dac_swing_lvl)
+static void rtl8723e_dm_bt_set_fw_dac_swing_level(struct ieee80211_hw *hw,
+						  u8 dac_swing_lvl)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter[1] = {0};
-
 	h2c_parameter[0] = dac_swing_lvl;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swing_lvl);
+		"[BTCoex], Set Dac Swing Level=0x%x\n", dac_swing_lvl);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], write 0x29 = 0x%x\n", h2c_parameter[0]);
+		"[BTCoex], write 0x29=0x%x\n", h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x29, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x29, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_bt_hid_info(struct ieee80211_hw *hw,
-					       bool enable)
+static void rtl8723e_dm_bt_set_fw_bt_hid_info(struct ieee80211_hw *hw,
+					      bool b_enable)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter[1] = {0};
-
 	h2c_parameter[0] = 0;
 
-	if (enable) {
+	if (b_enable) {
 		h2c_parameter[0] |= BIT(0);
-		rtlpcipriv->bt_coexist.fw_coexist_all_off = false;
+		rtlpriv->btcoexist.fw_coexist_all_off = false;
 	}
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], Set BT HID information = 0x%x\n", enable);
+		"[BTCoex], Set BT HID information=0x%x\n", b_enable);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], write 0x24 = 0x%x\n", h2c_parameter[0]);
+		"[BTCoex], write 0x24=0x%x\n", h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x24, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x24, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_bt_retry_index(struct ieee80211_hw *hw,
-						  u8 retry_index)
+static void rtl8723e_dm_bt_set_fw_bt_retry_index(struct ieee80211_hw *hw,
+						 u8 retry_index)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter[1] = {0};
-
 	h2c_parameter[0] = retry_index;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], Set BT Retry Index=%d\n", retry_index);
+		"[BTCoex], Set BT Retry Index=%d\n", retry_index);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], write 0x23 = 0x%x\n", h2c_parameter[0]);
+		"[BTCoex], write 0x23=0x%x\n", h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x23, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x23, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_set_fw_wlan_act(struct ieee80211_hw *hw,
-					    u8 wlan_act_hi, u8 wlan_act_lo)
+static void rtl8723e_dm_bt_set_fw_wlan_act(struct ieee80211_hw *hw,
+					   u8 wlan_act_hi, u8 wlan_act_lo)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 h2c_parameter_hi[1] = {0};
 	u8 h2c_parameter_lo[1] = {0};
-
 	h2c_parameter_hi[0] = wlan_act_hi;
 	h2c_parameter_lo[0] = wlan_act_lo;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], Set WLAN_ACT Hi:Lo = 0x%x/0x%x\n", wlan_act_hi,
-		 wlan_act_lo);
+		"[BTCoex], Set WLAN_ACT Hi:Lo=0x%x/0x%x\n",
+		wlan_act_hi, wlan_act_lo);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], write 0x22 = 0x%x\n", h2c_parameter_hi[0]);
+		"[BTCoex], write 0x22=0x%x\n", h2c_parameter_hi[0]);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "[BTCoex], write 0x11 = 0x%x\n", h2c_parameter_lo[0]);
+		"[BTCoex], write 0x11=0x%x\n", h2c_parameter_lo[0]);
 
 	/* WLAN_ACT = High duration, unit:ms */
-	rtl8723ae_fill_h2c_cmd(hw, 0x22, 1, h2c_parameter_hi);
+	rtl8723e_fill_h2c_cmd(hw, 0x22, 1, h2c_parameter_hi);
 	/*  WLAN_ACT = Low duration, unit:3*625us */
-	rtl8723ae_fill_h2c_cmd(hw, 0x11, 1, h2c_parameter_lo);
+	rtl8723e_fill_h2c_cmd(hw, 0x11, 1, h2c_parameter_lo);
 }
 
-void rtl8723ae_dm_bt_set_bt_dm(struct ieee80211_hw *hw, struct btdm_8723 *btdm)
+void rtl8723e_dm_bt_set_bt_dm(struct ieee80211_hw *hw,
+			      struct btdm_8723 *btdm)
 {
-	struct rtl_pci_priv	*rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv	*rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	struct btdm_8723 *btdm_8723 = &rtlhal->hal_coex_8723.btdm;
+	struct btdm_8723 *btdm_8723 = &hal_coex_8723.btdm;
 	u8 i;
+
 	bool fw_current_inpsmode = false;
 	bool fw_ps_awake = true;
 
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
-				      (u8 *)(&fw_current_inpsmode));
+					      (u8 *)(&fw_current_inpsmode));
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
-				      (u8 *)(&fw_ps_awake));
+					      (u8 *)(&fw_ps_awake));
 
-	/* check new setting is different than the old one,
-	 * if all the same, don't do the setting again.
-	 */
+	/* check new setting is different with the old one, */
+	/* if all the same, don't do the setting again. */
 	if (memcmp(btdm_8723, btdm, sizeof(struct btdm_8723)) == 0) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], the same coexist setting, return!!\n");
+			"[BTCoex], the same coexist setting, return!!\n");
 		return;
 	} else {	/* save the new coexist setting */
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], UPDATE TO NEW COEX SETTING!!\n");
+			"[BTCoex], UPDATE TO NEW COEX SETTING!!\n");
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bAllOff = 0x%x/ 0x%x\n",
-			 btdm_8723->all_off, btdm->all_off);
+			"[BTCoex], original/new bAllOff=0x%x/ 0x%x\n",
+			btdm_8723->all_off, btdm->all_off);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new agc_table_en = 0x%x/ 0x%x\n",
-			 btdm_8723->agc_table_en, btdm->agc_table_en);
+			"[BTCoex], original/new agc_table_en=0x%x/ 0x%x\n",
+			btdm_8723->agc_table_en, btdm->agc_table_en);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new adc_back_off_on = 0x%x/ 0x%x\n",
-			 btdm_8723->adc_back_off_on, btdm->adc_back_off_on);
+			 "[BTCoex], original/new adc_back_off_on=0x%x/ 0x%x\n",
+			 btdm_8723->adc_back_off_on,
+			 btdm->adc_back_off_on);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new b2_ant_hid_en = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new b2_ant_hid_en=0x%x/ 0x%x\n",
 			 btdm_8723->b2_ant_hid_en, btdm->b2_ant_hid_en);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bLowPenaltyRateAdaptive = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new bLowPenaltyRateAdaptive=0x%x/ 0x%x\n",
 			 btdm_8723->low_penalty_rate_adaptive,
 			 btdm->low_penalty_rate_adaptive);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bRfRxLpfShrink = 0x%x/ 0x%x\n",
-			 btdm_8723->rf_rx_lpf_shrink, btdm->rf_rx_lpf_shrink);
+			 "[BTCoex], original/new bRfRxLpfShrink=0x%x/ 0x%x\n",
+			 btdm_8723->rf_rx_lpf_shrink,
+			 btdm->rf_rx_lpf_shrink);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bRejectAggrePkt = 0x%x/ 0x%x\n",
-			 btdm_8723->reject_aggre_pkt, btdm->reject_aggre_pkt);
+			 "[BTCoex], original/new bRejectAggrePkt=0x%x/ 0x%x\n",
+			 btdm_8723->reject_aggre_pkt,
+			 btdm->reject_aggre_pkt);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new tdma_on = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new tdma_on=0x%x/ 0x%x\n",
 			 btdm_8723->tdma_on, btdm->tdma_on);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new tdmaAnt = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new tdmaAnt=0x%x/ 0x%x\n",
 			 btdm_8723->tdma_ant, btdm->tdma_ant);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new tdmaNav = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new tdmaNav=0x%x/ 0x%x\n",
 			 btdm_8723->tdma_nav, btdm->tdma_nav);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new tdma_dac_swing = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new tdma_dac_swing=0x%x/ 0x%x\n",
 			 btdm_8723->tdma_dac_swing, btdm->tdma_dac_swing);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new fwDacSwingLvl = 0x%x/ 0x%x\n",
-			 btdm_8723->fw_dac_swing_lvl, btdm->fw_dac_swing_lvl);
+			 "[BTCoex], original/new fw_dac_swing_lvl=0x%x/ 0x%x\n",
+			 btdm_8723->fw_dac_swing_lvl,
+			 btdm->fw_dac_swing_lvl);
 
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bTraTdmaOn = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new bTraTdmaOn=0x%x/ 0x%x\n",
 			 btdm_8723->tra_tdma_on, btdm->tra_tdma_on);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new traTdmaAnt = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new traTdmaAnt=0x%x/ 0x%x\n",
 			 btdm_8723->tra_tdma_ant, btdm->tra_tdma_ant);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new traTdmaNav = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new traTdmaNav=0x%x/ 0x%x\n",
 			 btdm_8723->tra_tdma_nav, btdm->tra_tdma_nav);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bPsTdmaOn = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new bPsTdmaOn=0x%x/ 0x%x\n",
 			 btdm_8723->ps_tdma_on, btdm->ps_tdma_on);
 		for (i = 0; i < 5; i++) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "[BTCoex], original/new psTdmaByte[i] = 0x%x/ 0x%x\n",
+				 "[BTCoex], original/new psTdmaByte[i]=0x%x/ 0x%x\n",
 				 btdm_8723->ps_tdma_byte[i],
 				 btdm->ps_tdma_byte[i]);
 		}
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bIgnoreWlanAct = 0x%x/ 0x%x\n",
-			 btdm_8723->ignore_wlan_act, btdm->ignore_wlan_act);
+			"[BTCoex], original/new bIgnoreWlanAct=0x%x/ 0x%x\n",
+			btdm_8723->ignore_wlan_act,
+			btdm->ignore_wlan_act);
+
 
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new bPtaOn = 0x%x/ 0x%x\n",
-			 btdm_8723->pta_on, btdm->pta_on);
+			"[BTCoex], original/new bPtaOn=0x%x/ 0x%x\n",
+			btdm_8723->pta_on, btdm->pta_on);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new val_0x6c0 = 0x%x/ 0x%x\n",
-			 btdm_8723->val_0x6c0, btdm->val_0x6c0);
+			"[BTCoex], original/new val_0x6c0=0x%x/ 0x%x\n",
+			btdm_8723->val_0x6c0, btdm->val_0x6c0);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new val_0x6c8 = 0x%x/ 0x%x\n",
-			 btdm_8723->val_0x6c8, btdm->val_0x6c8);
+			"[BTCoex], original/new val_0x6c8=0x%x/ 0x%x\n",
+			btdm_8723->val_0x6c8, btdm->val_0x6c8);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new val_0x6cc = 0x%x/ 0x%x\n",
-			 btdm_8723->val_0x6cc, btdm->val_0x6cc);
+			"[BTCoex], original/new val_0x6cc=0x%x/ 0x%x\n",
+			btdm_8723->val_0x6cc, btdm->val_0x6cc);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new sw_dac_swing_on = 0x%x/ 0x%x\n",
-			 btdm_8723->sw_dac_swing_on, btdm->sw_dac_swing_on);
+			 "[BTCoex], original/new sw_dac_swing_on=0x%x/ 0x%x\n",
+			 btdm_8723->sw_dac_swing_on,
+			 btdm->sw_dac_swing_on);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new sw_dac_swing_lvl = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new sw_dac_swing_lvl=0x%x/ 0x%x\n",
 			 btdm_8723->sw_dac_swing_lvl,
 			 btdm->sw_dac_swing_lvl);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new wlanActHi = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new wlanActHi=0x%x/ 0x%x\n",
 			 btdm_8723->wlan_act_hi, btdm->wlan_act_hi);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new wlanActLo = 0x%x/ 0x%x\n",
+			 "[BTCoex], original/new wlanActLo=0x%x/ 0x%x\n",
 			 btdm_8723->wlan_act_lo, btdm->wlan_act_lo);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], original/new btRetryIndex = 0x%x/ 0x%x\n",
-			btdm_8723->bt_retry_index, btdm->bt_retry_index);
+			 "[BTCoex], original/new btRetryIndex=0x%x/ 0x%x\n",
+			 btdm_8723->bt_retry_index, btdm->bt_retry_index);
 
 		memcpy(btdm_8723, btdm, sizeof(struct btdm_8723));
 	}
-	/*
-	 * Here we only consider when Bt Operation
+	/* Here we only consider when Bt Operation
 	 * inquiry/paging/pairing is ON
 	 * we only need to turn off TDMA
 	 */
 
-	if (rtlpcipriv->bt_coexist.hold_for_bt_operation) {
+	if (rtlpriv->btcoexist.hold_for_bt_operation) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], set to ignore wlanAct for BT OP!!\n");
-		rtl8723ae_dm_bt_set_fw_ignore_wlan_act(hw, true);
+			"[BTCoex], set to ignore wlanAct for BT OP!!\n");
+		rtl8723e_dm_bt_set_fw_ignore_wlan_act(hw, true);
 		return;
 	}
 
 	if (btdm->all_off) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], disable all coexist mechanism !!\n");
-		rtl8723ae_btdm_coex_all_off(hw);
+			"[BTCoex], disable all coexist mechanism !!\n");
+		rtl8723e_btdm_coex_all_off(hw);
 		return;
 	}
 
-	rtl8723ae_dm_bt_reject_ap_aggregated_packet(hw, btdm->reject_aggre_pkt);
+	rtl8723e_dm_bt_reject_ap_aggregated_packet(hw, btdm->reject_aggre_pkt);
 
 	if (btdm->low_penalty_rate_adaptive)
-		rtl8723ae_bt_set_penalty_tx_rate_adap(hw,
-			BT_TX_RATE_ADAPTIVE_LOW_PENALTY);
+		dm_bt_set_sw_penalty_tx_rate_adapt(hw, BT_TX_RATE_ADAPTIVE_LOW_PENALTY);
 	else
-		rtl8723ae_bt_set_penalty_tx_rate_adap(hw,
-			BT_TX_RATE_ADAPTIVE_NORMAL);
+		dm_bt_set_sw_penalty_tx_rate_adapt(hw,
+						   BT_TX_RATE_ADAPTIVE_NORMAL);
 
 	if (btdm->rf_rx_lpf_shrink)
-		rtl8723ae_dm_bt_set_sw_rf_rx_lpf_corner(hw,
-					 BT_RF_RX_LPF_CORNER_SHRINK);
+		rtl8723e_dm_bt_set_sw_rf_rx_lpf_corner(hw,
+				BT_RF_RX_LPF_CORNER_SHRINK);
 	else
-		rtl8723ae_dm_bt_set_sw_rf_rx_lpf_corner(hw,
-					 BT_RF_RX_LPF_CORNER_RESUME);
+		rtl8723e_dm_bt_set_sw_rf_rx_lpf_corner(hw,
+				BT_RF_RX_LPF_CORNER_RESUME);
 
 	if (btdm->agc_table_en)
-		rtl8723ae_dm_bt_agc_table(hw, BT_AGCTABLE_ON);
+		rtl8723e_dm_bt_agc_table(hw, BT_AGCTABLE_ON);
 	else
-		rtl8723ae_dm_bt_agc_table(hw, BT_AGCTABLE_OFF);
+		rtl8723e_dm_bt_agc_table(hw, BT_AGCTABLE_OFF);
 
 	if (btdm->adc_back_off_on)
-		rtl8723ae_dm_bt_bback_off_level(hw, BT_BB_BACKOFF_ON);
+		rtl8723e_dm_bt_bb_back_off_level(hw, BT_BB_BACKOFF_ON);
 	else
-		rtl8723ae_dm_bt_bback_off_level(hw, BT_BB_BACKOFF_OFF);
+		rtl8723e_dm_bt_bb_back_off_level(hw, BT_BB_BACKOFF_OFF);
 
-	rtl8723ae_dm_bt_set_fw_bt_retry_index(hw, btdm->bt_retry_index);
+	rtl8723e_dm_bt_set_fw_bt_retry_index(hw, btdm->bt_retry_index);
 
-	rtl8723ae_dm_bt_set_fw_dac_swing_level(hw, btdm->fw_dac_swing_lvl);
-	rtl8723ae_dm_bt_set_fw_wlan_act(hw, btdm->wlan_act_hi,
+	rtl8723e_dm_bt_set_fw_dac_swing_level(hw, btdm->fw_dac_swing_lvl);
+	rtl8723e_dm_bt_set_fw_wlan_act(hw, btdm->wlan_act_hi,
 				       btdm->wlan_act_lo);
 
-	rtl8723ae_dm_bt_set_coex_table(hw, btdm->val_0x6c0,
-		btdm->val_0x6c8, btdm->val_0x6cc);
-	rtl8723ae_dm_bt_set_hw_pta_mode(hw, btdm->pta_on);
+	rtl8723e_dm_bt_set_coex_table(hw, btdm->val_0x6c0,
+				      btdm->val_0x6c8, btdm->val_0x6cc);
+	rtl8723e_dm_bt_set_hw_pta_mode(hw, btdm->pta_on);
 
 	/* Note: There is a constraint between TDMA and 2AntHID
-	 * Only one of 2AntHid and tdma can be turned on
-	 * We should turn off those mechanisms first
-	 * and then turn on them on.
+	 * Only one of 2AntHid and tdma can be turn on
+	 * We should turn off those mechanisms should be turned off first
+	 * and then turn on those mechanisms should be turned on.
 	*/
 	if (btdm->b2_ant_hid_en) {
 		/* turn off tdma */
-		rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
+		rtl8723e_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
 						    btdm->tra_tdma_ant,
 						    btdm->tra_tdma_nav);
-		rtl8723ae_dm_bt_set_fw_tdma_ctrl(hw, false, btdm->tdma_ant,
+		rtl8723e_dm_bt_set_fw_tdma_ctrl(hw, false, btdm->tdma_ant,
 						btdm->tdma_nav,
 						btdm->tdma_dac_swing);
 
 		/* turn off Pstdma */
-		rtl8723ae_dm_bt_set_fw_ignore_wlan_act(hw,
+		rtl8723e_dm_bt_set_fw_ignore_wlan_act(hw,
 						      btdm->ignore_wlan_act);
 		/* Antenna control by PTA, 0x870 = 0x300. */
-		rtl8723ae_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
+		rtl8723e_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
 
 		/* turn on 2AntHid */
-		rtl8723ae_dm_bt_set_fw_bt_hid_info(hw, true);
-		rtl8723ae_dm_bt_set_fw_2_ant_hid(hw, true, true);
+		rtl8723e_dm_bt_set_fw_bt_hid_info(hw, true);
+		rtl8723e_dm_bt_set_fw_2_ant_hid(hw, true, true);
 	} else if (btdm->tdma_on) {
 		/* turn off 2AntHid */
-		rtl8723ae_dm_bt_set_fw_bt_hid_info(hw, false);
-		rtl8723ae_dm_bt_set_fw_2_ant_hid(hw, false, false);
+		rtl8723e_dm_bt_set_fw_bt_hid_info(hw, false);
+		rtl8723e_dm_bt_set_fw_2_ant_hid(hw, false, false);
 
 		/* turn off pstdma */
-		rtl8723ae_dm_bt_set_fw_ignore_wlan_act(hw,
+		rtl8723e_dm_bt_set_fw_ignore_wlan_act(hw,
 						      btdm->ignore_wlan_act);
 		/* Antenna control by PTA, 0x870 = 0x300. */
-		rtl8723ae_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
+		rtl8723e_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
 
 		/* turn on tdma */
-		rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
-				 btdm->tra_tdma_ant, btdm->tra_tdma_nav);
-		rtl8723ae_dm_bt_set_fw_tdma_ctrl(hw, true, btdm->tdma_ant,
-				 btdm->tdma_nav, btdm->tdma_dac_swing);
+		rtl8723e_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
+						    btdm->tra_tdma_ant,
+						    btdm->tra_tdma_nav);
+		rtl8723e_dm_bt_set_fw_tdma_ctrl(hw, true, btdm->tdma_ant,
+						btdm->tdma_nav,
+						btdm->tdma_dac_swing);
 	} else if (btdm->ps_tdma_on) {
 		/* turn off 2AntHid */
-		rtl8723ae_dm_bt_set_fw_bt_hid_info(hw, false);
-		rtl8723ae_dm_bt_set_fw_2_ant_hid(hw, false, false);
+		rtl8723e_dm_bt_set_fw_bt_hid_info(hw, false);
+		rtl8723e_dm_bt_set_fw_2_ant_hid(hw, false, false);
 
 		/* turn off tdma */
-		rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
-				 btdm->tra_tdma_ant, btdm->tra_tdma_nav);
-		rtl8723ae_dm_bt_set_fw_tdma_ctrl(hw, false, btdm->tdma_ant,
-				 btdm->tdma_nav, btdm->tdma_dac_swing);
+		rtl8723e_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
+						    btdm->tra_tdma_ant,
+						    btdm->tra_tdma_nav);
+		rtl8723e_dm_bt_set_fw_tdma_ctrl(hw, false, btdm->tdma_ant,
+						btdm->tdma_nav,
+						btdm->tdma_dac_swing);
 
 		/* turn on pstdma */
-		rtl8723ae_dm_bt_set_fw_ignore_wlan_act(hw,
-				 btdm->ignore_wlan_act);
-		rtl8723ae_dm_bt_set_fw_3a(hw,
-			btdm->ps_tdma_byte[0],
-			btdm->ps_tdma_byte[1],
-			btdm->ps_tdma_byte[2],
-			btdm->ps_tdma_byte[3],
-			btdm->ps_tdma_byte[4]);
+		rtl8723e_dm_bt_set_fw_ignore_wlan_act(hw,
+						      btdm->ignore_wlan_act);
+		rtl8723e_dm_bt_set_fw_3a(hw, btdm->ps_tdma_byte[0],
+					 btdm->ps_tdma_byte[1],
+					 btdm->ps_tdma_byte[2],
+					 btdm->ps_tdma_byte[3],
+					 btdm->ps_tdma_byte[4]);
 	} else {
 		/* turn off 2AntHid */
-		rtl8723ae_dm_bt_set_fw_bt_hid_info(hw, false);
-		rtl8723ae_dm_bt_set_fw_2_ant_hid(hw, false, false);
+		rtl8723e_dm_bt_set_fw_bt_hid_info(hw, false);
+		rtl8723e_dm_bt_set_fw_2_ant_hid(hw, false, false);
 
 		/* turn off tdma */
-		rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
-				 btdm->tra_tdma_ant, btdm->tra_tdma_nav);
-		rtl8723ae_dm_bt_set_fw_tdma_ctrl(hw, false, btdm->tdma_ant,
-				 btdm->tdma_nav, btdm->tdma_dac_swing);
+		rtl8723e_dm_bt_set_fw_tra_tdma_ctrl(hw, btdm->tra_tdma_on,
+						    btdm->tra_tdma_ant,
+						    btdm->tra_tdma_nav);
+		rtl8723e_dm_bt_set_fw_tdma_ctrl(hw, false, btdm->tdma_ant,
+						btdm->tdma_nav,
+						btdm->tdma_dac_swing);
 
 		/* turn off pstdma */
-		rtl8723ae_dm_bt_set_fw_ignore_wlan_act(hw,
-						      btdm->ignore_wlan_act);
+		rtl8723e_dm_bt_set_fw_ignore_wlan_act(hw,
+						btdm->ignore_wlan_act);
 		/* Antenna control by PTA, 0x870 = 0x300. */
-		rtl8723ae_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
+		rtl8723e_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
 	}
 
 	/* Note:
-	 * We should add delay for making sure sw DacSwing can be set
-	 *  sucessfully. Because of that rtl8723ae_dm_bt_set_fw_2_ant_hid()
-	 * and rtl8723ae_dm_bt_set_fw_tdma_ctrl()
+	 * We should add delay for making sure
+	 *	sw DacSwing can be set sucessfully.
+	 * because of that rtl8723e_dm_bt_set_fw_2_ant_hid()
+	 *	and rtl8723e_dm_bt_set_fw_tdma_ctrl()
 	 * will overwrite the reg 0x880.
 	*/
 	mdelay(30);
-	rtl8723ae_dm_bt_set_sw_full_time_dac_swing(hw,
-		btdm->sw_dac_swing_on, btdm->sw_dac_swing_lvl);
-	rtl8723ae_dm_bt_set_fw_dec_bt_pwr(hw, btdm->dec_bt_pwr);
+	rtl8723e_dm_bt_set_sw_full_time_dac_swing(hw, btdm->sw_dac_swing_on,
+						  btdm->sw_dac_swing_lvl);
+	rtl8723e_dm_bt_set_fw_dec_bt_pwr(hw, btdm->dec_bt_pwr);
 }
 
-/*============================================================
- * extern function start with BTDM_
- *============================================================
+/* ============================================================ */
+/* extern function start with BTDM_ */
+/* ============================================================i
  */
-static u32 rtl8723ae_dm_bt_tx_rx_couter_h(struct ieee80211_hw *hw)
+static u32 rtl8723e_dm_bt_tx_rx_couter_h(struct ieee80211_hw *hw)
 {
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u32 counters = 0;
+	u32	counters = 0;
 
-	counters = rtlhal->hal_coex_8723.high_priority_tx +
-		   rtlhal->hal_coex_8723.high_priority_rx;
+	counters = hal_coex_8723.high_priority_tx +
+			hal_coex_8723.high_priority_rx;
 	return counters;
 }
 
-static u32 rtl8723ae_dm_bt_tx_rx_couter_l(struct ieee80211_hw *hw)
+static u32 rtl8723e_dm_bt_tx_rx_couter_l(struct ieee80211_hw *hw)
 {
-	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u32 counters = 0;
 
-	return rtlhal->hal_coex_8723.low_priority_tx +
-	       rtlhal->hal_coex_8723.low_priority_rx;
+	counters = hal_coex_8723.low_priority_tx +
+			hal_coex_8723.low_priority_rx;
+	return counters;
 }
 
-static u8 rtl8723ae_dm_bt_bt_tx_rx_counter_level(struct ieee80211_hw *hw)
+static u8 rtl8723e_dm_bt_bt_tx_rx_counter_level(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
-	u32 bt_tx_rx_cnt = 0;
-	u8 bt_tx_rx_cnt_lvl = 0;
+	u32	bt_tx_rx_cnt = 0;
+	u8	bt_tx_rx_cnt_lvl = 0;
 
-	bt_tx_rx_cnt = rtl8723ae_dm_bt_tx_rx_couter_h(hw) +
-		       rtl8723ae_dm_bt_tx_rx_couter_l(hw);
+	bt_tx_rx_cnt = rtl8723e_dm_bt_tx_rx_couter_h(hw)
+				+ rtl8723e_dm_bt_tx_rx_couter_l(hw);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 		 "[BTCoex], BT TxRx Counters = %d\n", bt_tx_rx_cnt);
 
-	rtlpcipriv->bt_coexist.cstate_h &=
-		 ~(BT_COEX_STATE_BT_CNT_LEVEL_0 | BT_COEX_STATE_BT_CNT_LEVEL_1 |
+	rtlpriv->btcoexist.cstate_h &= ~
+		 (BT_COEX_STATE_BT_CNT_LEVEL_0 | BT_COEX_STATE_BT_CNT_LEVEL_1|
 		  BT_COEX_STATE_BT_CNT_LEVEL_2);
 
 	if (bt_tx_rx_cnt >= BT_TXRX_CNT_THRES_3) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], BT TxRx Counters at level 3\n");
 		bt_tx_rx_cnt_lvl = BT_TXRX_CNT_LEVEL_3;
-		rtlpcipriv->bt_coexist.cstate_h |= BT_COEX_STATE_BT_CNT_LEVEL_3;
+		rtlpriv->btcoexist.cstate_h |=
+			BT_COEX_STATE_BT_CNT_LEVEL_3;
 	} else if (bt_tx_rx_cnt >= BT_TXRX_CNT_THRES_2) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], BT TxRx Counters at level 2\n");
 		bt_tx_rx_cnt_lvl = BT_TXRX_CNT_LEVEL_2;
-		rtlpcipriv->bt_coexist.cstate_h |= BT_COEX_STATE_BT_CNT_LEVEL_2;
+		rtlpriv->btcoexist.cstate_h |=
+			BT_COEX_STATE_BT_CNT_LEVEL_2;
 	} else if (bt_tx_rx_cnt >= BT_TXRX_CNT_THRES_1) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], BT TxRx Counters at level 1\n");
 		bt_tx_rx_cnt_lvl = BT_TXRX_CNT_LEVEL_1;
-		rtlpcipriv->bt_coexist.cstate_h |= BT_COEX_STATE_BT_CNT_LEVEL_1;
+		rtlpriv->btcoexist.cstate_h  |=
+			BT_COEX_STATE_BT_CNT_LEVEL_1;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], BT TxRx Counters at level 0\n");
 		bt_tx_rx_cnt_lvl = BT_TXRX_CNT_LEVEL_0;
-		rtlpcipriv->bt_coexist.cstate_h |= BT_COEX_STATE_BT_CNT_LEVEL_0;
+		rtlpriv->btcoexist.cstate_h |=
+			BT_COEX_STATE_BT_CNT_LEVEL_0;
 	}
 	return bt_tx_rx_cnt_lvl;
 }
 
-static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct btdm_8723 btdm8723;
 	u8 bt_rssi_state, bt_rssi_state1;
-	u8 bt_tx_rx_cnt_lvl;
+	u8	bt_tx_rx_cnt_lvl = 0;
 
-	rtl8723ae_dm_bt_btdm_structure_reload(hw, &btdm8723);
+	rtl8723e_dm_bt_btdm_structure_reload(hw, &btdm8723);
 
 	btdm8723.rf_rx_lpf_shrink = true;
 	btdm8723.low_penalty_rate_adaptive = true;
 	btdm8723.reject_aggre_pkt = false;
 
-	bt_tx_rx_cnt_lvl = rtl8723ae_dm_bt_bt_tx_rx_counter_level(hw);
+	bt_tx_rx_cnt_lvl = rtl8723e_dm_bt_bt_tx_rx_counter_level(hw);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 		 "[BTCoex], BT TxRx Counters = %d\n", bt_tx_rx_cnt_lvl);
 
@@ -1051,10 +1045,10 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "HT20 or Legacy\n");
-		bt_rssi_state = rtl8723ae_dm_bt_check_coex_rssi_state(hw, 2,
-								     47, 0);
-		bt_rssi_state1 = rtl8723ae_dm_bt_check_coex_rssi_state1(hw, 2,
-								       27, 0);
+		bt_rssi_state =
+		  rtl8723e_dm_bt_check_coex_rssi_state(hw, 2, 47, 0);
+		bt_rssi_state1 =
+		  rtl8723e_dm_bt_check_coex_rssi_state1(hw, 2, 27, 0);
 
 		/* coex table */
 		btdm8723.val_0x6c0 = 0x55555555;
@@ -1063,15 +1057,15 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 
 		/* sw mechanism */
 		if ((bt_rssi_state == BT_RSSI_STATE_HIGH) ||
-		    (bt_rssi_state == BT_RSSI_STATE_STAY_HIGH)) {
+			(bt_rssi_state == BT_RSSI_STATE_STAY_HIGH)) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "Wifi rssi high\n");
+					"Wifi rssi high\n");
 			btdm8723.agc_table_en = true;
 			btdm8723.adc_back_off_on = true;
 			btdm8723.sw_dac_swing_on = false;
 		} else {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "Wifi rssi low\n");
+					"Wifi rssi low\n");
 			btdm8723.agc_table_en = false;
 			btdm8723.adc_back_off_on = false;
 			btdm8723.sw_dac_swing_on = false;
@@ -1080,16 +1074,15 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 		/* fw mechanism */
 		btdm8723.ps_tdma_on = true;
 		if ((bt_rssi_state1 == BT_RSSI_STATE_HIGH) ||
-		    (bt_rssi_state1 == BT_RSSI_STATE_STAY_HIGH)) {
+			(bt_rssi_state1 == BT_RSSI_STATE_STAY_HIGH)) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 				 "Wifi rssi-1 high\n");
-			/* only rssi high we need to do this,
-			 * when rssi low, the value will modified by fw
-			 */
+			/* only rssi high we need to do this, */
+			/* when rssi low, the value will modified by fw */
 			rtl_write_byte(rtlpriv, 0x883, 0x40);
 			if (bt_tx_rx_cnt_lvl == BT_TXRX_CNT_LEVEL_2) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-					 "[BTCoex], BT TxRx Counters >= 1400\n");
+				"[BTCoex], BT TxRx Counters >= 1400\n");
 				btdm8723.ps_tdma_byte[0] = 0xa3;
 				btdm8723.ps_tdma_byte[1] = 0x5;
 				btdm8723.ps_tdma_byte[2] = 0x5;
@@ -1097,7 +1090,7 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 				btdm8723.ps_tdma_byte[4] = 0x80;
 			} else if (bt_tx_rx_cnt_lvl == BT_TXRX_CNT_LEVEL_1) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-					 "[BTCoex], BT TxRx Counters >= 1200 && < 1400\n");
+					 "[BTCoex], BT TxRx Counters>= 1200 && < 1400\n");
 				btdm8723.ps_tdma_byte[0] = 0xa3;
 				btdm8723.ps_tdma_byte[1] = 0xa;
 				btdm8723.ps_tdma_byte[2] = 0xa;
@@ -1114,7 +1107,7 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 			}
 		} else {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "Wifi rssi-1 low\n");
+					"Wifi rssi-1 low\n");
 			if (bt_tx_rx_cnt_lvl == BT_TXRX_CNT_LEVEL_2) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 					 "[BTCoex], BT TxRx Counters >= 1400\n");
@@ -1143,16 +1136,15 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 		}
 	}
 
-	if (rtl8723ae_dm_bt_need_to_dec_bt_pwr(hw))
+	if (rtl8723e_dm_bt_need_to_dec_bt_pwr(hw))
 		btdm8723.dec_bt_pwr = true;
 
 	/* Always ignore WlanAct if bHid|bSCOBusy|bSCOeSCO */
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 		 "[BTCoex], BT btInqPageStartTime = 0x%x, btTxRxCntLvl = %d\n",
-		 rtlhal->hal_coex_8723.bt_inq_page_start_time,
-		 bt_tx_rx_cnt_lvl);
-	if ((rtlhal->hal_coex_8723.bt_inq_page_start_time) ||
+		 hal_coex_8723.bt_inq_page_start_time, bt_tx_rx_cnt_lvl);
+	if ((hal_coex_8723.bt_inq_page_start_time) ||
 	    (BT_TXRX_CNT_LEVEL_3 == bt_tx_rx_cnt_lvl)) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], Set BT inquiry / page scan 0x3a setting\n");
@@ -1164,33 +1156,35 @@ static void rtl8723ae_dm_bt_2_ant_hid_sco_esco(struct ieee80211_hw *hw)
 		btdm8723.ps_tdma_byte[4] = 0x80;
 	}
 
-	if (rtl8723ae_dm_bt_is_coexist_state_changed(hw))
-		rtl8723ae_dm_bt_set_bt_dm(hw, &btdm8723);
+	if (rtl8723e_dm_bt_is_coexist_state_changed(hw))
+		rtl8723e_dm_bt_set_bt_dm(hw, &btdm8723);
+
 }
 
-static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_2_ant_ftp_a2dp(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct btdm_8723 btdm8723;
+
 	u8 bt_rssi_state, bt_rssi_state1;
-	u32 bt_tx_rx_cnt_lvl;
+	u32 bt_tx_rx_cnt_lvl = 0;
+
+	rtl8723e_dm_bt_btdm_structure_reload(hw, &btdm8723);
 
-	rtl8723ae_dm_bt_btdm_structure_reload(hw, &btdm8723);
 	btdm8723.rf_rx_lpf_shrink = true;
 	btdm8723.low_penalty_rate_adaptive = true;
 	btdm8723.reject_aggre_pkt = false;
 
-	bt_tx_rx_cnt_lvl = rtl8723ae_dm_bt_bt_tx_rx_counter_level(hw);
+	bt_tx_rx_cnt_lvl = rtl8723e_dm_bt_bt_tx_rx_counter_level(hw);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "[BTCoex], BT TxRx Counters = %d\n", bt_tx_rx_cnt_lvl);
+	"[BTCoex], BT TxRx Counters = %d\n", bt_tx_rx_cnt_lvl);
 
 	if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG, "HT40\n");
-		bt_rssi_state = rtl8723ae_dm_bt_check_coex_rssi_state(hw, 2,
-								     37, 0);
+		bt_rssi_state =
+		  rtl8723e_dm_bt_check_coex_rssi_state(hw, 2, 37, 0);
 
 		/* coex table */
 		btdm8723.val_0x6c0 = 0x55555555;
@@ -1205,12 +1199,12 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 		/* fw mechanism */
 		btdm8723.ps_tdma_on = true;
 		if ((bt_rssi_state == BT_RSSI_STATE_HIGH) ||
-		    (bt_rssi_state == BT_RSSI_STATE_STAY_HIGH)) {
+			(bt_rssi_state == BT_RSSI_STATE_STAY_HIGH)) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "Wifi rssi high\n");
+						"Wifi rssi high\n");
 			if (bt_tx_rx_cnt_lvl == BT_TXRX_CNT_LEVEL_2) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-					 "[BTCoex], BT TxRx Counters >= 1400\n");
+				"[BTCoex], BT TxRx Counters >= 1400\n");
 				btdm8723.ps_tdma_byte[0] = 0xa3;
 				btdm8723.ps_tdma_byte[1] = 0x5;
 				btdm8723.ps_tdma_byte[2] = 0x5;
@@ -1244,7 +1238,8 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 				btdm8723.ps_tdma_byte[2] = 0x5;
 				btdm8723.ps_tdma_byte[3] = 0x0;
 				btdm8723.ps_tdma_byte[4] = 0x80;
-			} else if (bt_tx_rx_cnt_lvl == BT_TXRX_CNT_LEVEL_1) {
+			} else if (bt_tx_rx_cnt_lvl ==
+				BT_TXRX_CNT_LEVEL_1) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 					 "[BTCoex], BT TxRx Counters >= 1200 && < 1400\n");
 				btdm8723.ps_tdma_byte[0] = 0xa3;
@@ -1265,10 +1260,10 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "HT20 or Legacy\n");
-		bt_rssi_state = rtl8723ae_dm_bt_check_coex_rssi_state(hw, 2,
-								     47, 0);
-		bt_rssi_state1 = rtl8723ae_dm_bt_check_coex_rssi_state1(hw, 2,
-								       27, 0);
+		bt_rssi_state =
+		  rtl8723e_dm_bt_check_coex_rssi_state(hw, 2, 47, 0);
+		bt_rssi_state1 =
+		  rtl8723e_dm_bt_check_coex_rssi_state1(hw, 2, 27, 0);
 
 		/* coex table */
 		btdm8723.val_0x6c0 = 0x55555555;
@@ -1277,7 +1272,7 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 
 		/* sw mechanism */
 		if ((bt_rssi_state == BT_RSSI_STATE_HIGH) ||
-		    (bt_rssi_state == BT_RSSI_STATE_STAY_HIGH)) {
+			(bt_rssi_state == BT_RSSI_STATE_STAY_HIGH)) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 				 "Wifi rssi high\n");
 			btdm8723.agc_table_en = true;
@@ -1294,12 +1289,11 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 		/* fw mechanism */
 		btdm8723.ps_tdma_on = true;
 		if ((bt_rssi_state1 == BT_RSSI_STATE_HIGH) ||
-		    (bt_rssi_state1 == BT_RSSI_STATE_STAY_HIGH)) {
+			(bt_rssi_state1 == BT_RSSI_STATE_STAY_HIGH)) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 				 "Wifi rssi-1 high\n");
-			/* only rssi high we need to do this,
-			 * when rssi low, the value will modified by fw
-			 */
+			/* only rssi high we need to do this, */
+			/* when rssi low, the value will modified by fw */
 			rtl_write_byte(rtlpriv, 0x883, 0x40);
 			if (bt_tx_rx_cnt_lvl == BT_TXRX_CNT_LEVEL_2) {
 				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
@@ -1357,15 +1351,14 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 		}
 	}
 
-	if (rtl8723ae_dm_bt_need_to_dec_bt_pwr(hw))
+	if (rtl8723e_dm_bt_need_to_dec_bt_pwr(hw))
 		btdm8723.dec_bt_pwr = true;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 		 "[BTCoex], BT btInqPageStartTime = 0x%x, btTxRxCntLvl = %d\n",
-		 rtlhal->hal_coex_8723.bt_inq_page_start_time,
-		 bt_tx_rx_cnt_lvl);
+		 hal_coex_8723.bt_inq_page_start_time, bt_tx_rx_cnt_lvl);
 
-	if ((rtlhal->hal_coex_8723.bt_inq_page_start_time) ||
+	if ((hal_coex_8723.bt_inq_page_start_time) ||
 	    (BT_TXRX_CNT_LEVEL_3 == bt_tx_rx_cnt_lvl)) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], Set BT inquiry / page scan 0x3a setting\n");
@@ -1377,379 +1370,373 @@ static void rtl8723ae_dm_bt_2_ant_fta2dp(struct ieee80211_hw *hw)
 		btdm8723.ps_tdma_byte[4] = 0x80;
 	}
 
-	if (rtl8723ae_dm_bt_is_coexist_state_changed(hw))
-		rtl8723ae_dm_bt_set_bt_dm(hw, &btdm8723);
+	if (rtl8723e_dm_bt_is_coexist_state_changed(hw))
+		rtl8723e_dm_bt_set_bt_dm(hw, &btdm8723);
+
 }
 
-static void rtl8723ae_dm_bt_inq_page_monitor(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_inq_page_monitor(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	u32 cur_time = jiffies;
+	u32 cur_time;
 
-	if (rtlhal->hal_coex_8723.c2h_bt_inquiry_page) {
+	cur_time = jiffies;
+	if (hal_coex_8723.c2h_bt_inquiry_page) {
 		/* bt inquiry or page is started. */
-		if (rtlhal->hal_coex_8723.bt_inq_page_start_time == 0) {
-			rtlpcipriv->bt_coexist.cstate |=
-					 BT_COEX_STATE_BT_INQ_PAGE;
-			rtlhal->hal_coex_8723.bt_inq_page_start_time = cur_time;
+		if (hal_coex_8723.bt_inq_page_start_time == 0) {
+			rtlpriv->btcoexist.cstate  |=
+			BT_COEX_STATE_BT_INQ_PAGE;
+			hal_coex_8723.bt_inq_page_start_time = cur_time;
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 				 "[BTCoex], BT Inquiry/page is started at time : 0x%x\n",
-				 rtlhal->hal_coex_8723.bt_inq_page_start_time);
+				 hal_coex_8723.bt_inq_page_start_time);
 		}
 	}
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 		 "[BTCoex], BT Inquiry/page started time : 0x%x, cur_time : 0x%x\n",
-		 rtlhal->hal_coex_8723.bt_inq_page_start_time, cur_time);
+		 hal_coex_8723.bt_inq_page_start_time, cur_time);
 
-	if (rtlhal->hal_coex_8723.bt_inq_page_start_time) {
+	if (hal_coex_8723.bt_inq_page_start_time) {
 		if ((((long)cur_time -
-		    (long)rtlhal->hal_coex_8723.bt_inq_page_start_time) / HZ) >=
-		    10) {
+			(long)hal_coex_8723.bt_inq_page_start_time) / HZ)
+			>= 10) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "[BTCoex], BT Inquiry/page >= 10sec!!!");
-			rtlhal->hal_coex_8723.bt_inq_page_start_time = 0;
-			rtlpcipriv->bt_coexist.cstate &=
-						 ~BT_COEX_STATE_BT_INQ_PAGE;
+				"[BTCoex], BT Inquiry/page >= 10sec!!!");
+			hal_coex_8723.bt_inq_page_start_time = 0;
+			rtlpriv->btcoexist.cstate &=
+				~BT_COEX_STATE_BT_INQ_PAGE;
 		}
 	}
 }
 
-static void rtl8723ae_dm_bt_reset_action_profile_state(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_reset_action_profile_state(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	rtlpcipriv->bt_coexist.cstate &=
-		~(BT_COEX_STATE_PROFILE_HID | BT_COEX_STATE_PROFILE_A2DP |
+	rtlpriv->btcoexist.cstate &= ~
+		(BT_COEX_STATE_PROFILE_HID | BT_COEX_STATE_PROFILE_A2DP|
 		BT_COEX_STATE_PROFILE_PAN | BT_COEX_STATE_PROFILE_SCO);
 
-	rtlpcipriv->bt_coexist.cstate &=
-		~(BT_COEX_STATE_BTINFO_COMMON |
-		BT_COEX_STATE_BTINFO_B_HID_SCOESCO |
+	rtlpriv->btcoexist.cstate &= ~
+		(BT_COEX_STATE_BTINFO_COMMON |
+		BT_COEX_STATE_BTINFO_B_HID_SCOESCO|
 		BT_COEX_STATE_BTINFO_B_FTP_A2DP);
 }
 
-static void _rtl8723ae_dm_bt_coexist_2_ant(struct ieee80211_hw *hw)
+static void _rtl8723e_dm_bt_coexist_2_ant(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	u8 bt_retry_cnt;
 	u8 bt_info_original;
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "[BTCoex] Get bt info by fw!!\n");
+		"[BTCoex] Get bt info by fw!!\n");
 
 	_rtl8723_dm_bt_check_wifi_state(hw);
 
-	if (rtlhal->hal_coex_8723.c2h_bt_info_req_sent) {
+	if (hal_coex_8723.c2h_bt_info_req_sent) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "[BTCoex] c2h for btInfo not rcvd yet!!\n");
+				"[BTCoex] c2h for bt_info not rcvd yet!!\n");
 	}
 
-	bt_info_original = rtlhal->hal_coex_8723.c2h_bt_info_original;
+	bt_retry_cnt = hal_coex_8723.bt_retry_cnt;
+	bt_info_original = hal_coex_8723.c2h_bt_info_original;
 
-	/* when bt inquiry or page scan, we have to set h2c 0x25
-	 * ignore wlanact for continuous 4x2secs
-	 */
-	rtl8723ae_dm_bt_inq_page_monitor(hw);
-	rtl8723ae_dm_bt_reset_action_profile_state(hw);
-
-	if (rtl8723ae_dm_bt_is_2_ant_common_action(hw)) {
-		rtlpcipriv->bt_coexist.bt_profile_case = BT_COEX_MECH_COMMON;
-		rtlpcipriv->bt_coexist.bt_profile_action = BT_COEX_MECH_COMMON;
+	/* when bt inquiry or page scan, we have to set h2c 0x25 */
+	/* ignore wlanact for continuous 4x2secs */
+	rtl8723e_dm_bt_inq_page_monitor(hw);
+	rtl8723e_dm_bt_reset_action_profile_state(hw);
 
+	if (rtl8723e_dm_bt_is_2_ant_common_action(hw)) {
+		rtlpriv->btcoexist.bt_profile_case = BT_COEX_MECH_COMMON;
+		rtlpriv->btcoexist.bt_profile_action = BT_COEX_MECH_COMMON;
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "Action 2-Ant common.\n");
+		"Action 2-Ant common.\n");
 	} else {
 		if ((bt_info_original & BTINFO_B_HID) ||
-		    (bt_info_original & BTINFO_B_SCO_BUSY) ||
-		    (bt_info_original & BTINFO_B_SCO_ESCO)) {
-			rtlpcipriv->bt_coexist.cstate |=
+			(bt_info_original & BTINFO_B_SCO_BUSY) ||
+			(bt_info_original & BTINFO_B_SCO_ESCO)) {
+				rtlpriv->btcoexist.cstate |=
 					BT_COEX_STATE_BTINFO_B_HID_SCOESCO;
-			rtlpcipriv->bt_coexist.bt_profile_case =
+				rtlpriv->btcoexist.bt_profile_case =
 					BT_COEX_MECH_HID_SCO_ESCO;
-			rtlpcipriv->bt_coexist.bt_profile_action =
+				rtlpriv->btcoexist.bt_profile_action =
 					BT_COEX_MECH_HID_SCO_ESCO;
-			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "[BTCoex], BTInfo: bHid|bSCOBusy|bSCOeSCO\n");
-			rtl8723ae_dm_bt_2_ant_hid_sco_esco(hw);
+				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
+					 "[BTCoex], BTInfo: bHid|bSCOBusy|bSCOeSCO\n");
+				rtl8723e_dm_bt_2_ant_hid_sco_esco(hw);
 		} else if ((bt_info_original & BTINFO_B_FTP) ||
-			   (bt_info_original & BTINFO_B_A2DP)) {
-			rtlpcipriv->bt_coexist.cstate |=
+				(bt_info_original & BTINFO_B_A2DP)) {
+				rtlpriv->btcoexist.cstate |=
 					BT_COEX_STATE_BTINFO_B_FTP_A2DP;
-			rtlpcipriv->bt_coexist.bt_profile_case =
+				rtlpriv->btcoexist.bt_profile_case =
 					BT_COEX_MECH_FTP_A2DP;
-			rtlpcipriv->bt_coexist.bt_profile_action =
+				rtlpriv->btcoexist.bt_profile_action =
 					BT_COEX_MECH_FTP_A2DP;
-			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "BTInfo: bFTP|bA2DP\n");
-			rtl8723ae_dm_bt_2_ant_fta2dp(hw);
+				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
+					 "BTInfo: bFTP|bA2DP\n");
+				rtl8723e_dm_bt_2_ant_ftp_a2dp(hw);
 		} else {
-			rtlpcipriv->bt_coexist.cstate |=
-					 BT_COEX_STATE_BTINFO_B_HID_SCOESCO;
-			rtlpcipriv->bt_coexist.bt_profile_case =
-					 BT_COEX_MECH_NONE;
-			rtlpcipriv->bt_coexist.bt_profile_action =
-					 BT_COEX_MECH_NONE;
-			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-				 "[BTCoex], BTInfo: undefined case!!!!\n");
-			rtl8723ae_dm_bt_2_ant_hid_sco_esco(hw);
+				rtlpriv->btcoexist.cstate |=
+					BT_COEX_STATE_BTINFO_B_HID_SCOESCO;
+				rtlpriv->btcoexist.bt_profile_case =
+					BT_COEX_MECH_NONE;
+				rtlpriv->btcoexist.bt_profile_action =
+					BT_COEX_MECH_NONE;
+				RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
+					 "[BTCoex], BTInfo: undefined case!!!!\n");
+				rtl8723e_dm_bt_2_ant_hid_sco_esco(hw);
 		}
 	}
 }
 
-static void _rtl8723ae_dm_bt_coexist_1_ant(struct ieee80211_hw *hw)
+static void _rtl8723e_dm_bt_coexist_1_ant(struct ieee80211_hw *hw)
 {
+	return;
 }
 
-void rtl8723ae_dm_bt_hw_coex_all_off_8723a(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_hw_coex_all_off_8723a(struct ieee80211_hw *hw)
 {
-	rtl8723ae_dm_bt_set_coex_table(hw, 0x5a5aaaaa, 0xcc, 0x3);
-	rtl8723ae_dm_bt_set_hw_pta_mode(hw, true);
+	rtl8723e_dm_bt_set_coex_table(hw, 0x5a5aaaaa, 0xcc, 0x3);
+	rtl8723e_dm_bt_set_hw_pta_mode(hw, true);
 }
 
-void rtl8723ae_dm_bt_fw_coex_all_off_8723a(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_fw_coex_all_off_8723a(struct ieee80211_hw *hw)
 {
-	rtl8723ae_dm_bt_set_fw_ignore_wlan_act(hw, false);
-	rtl8723ae_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
-	rtl8723ae_dm_bt_set_fw_2_ant_hid(hw, false, false);
-	rtl8723ae_dm_bt_set_fw_tra_tdma_ctrl(hw, false,
-					     TDMA_2ANT, TDMA_NAV_OFF);
-	rtl8723ae_dm_bt_set_fw_tdma_ctrl(hw, false, TDMA_2ANT,
-				TDMA_NAV_OFF, TDMA_DAC_SWING_OFF);
-	rtl8723ae_dm_bt_set_fw_dac_swing_level(hw, 0);
-	rtl8723ae_dm_bt_set_fw_bt_hid_info(hw, false);
-	rtl8723ae_dm_bt_set_fw_bt_retry_index(hw, 2);
-	rtl8723ae_dm_bt_set_fw_wlan_act(hw, 0x10, 0x10);
-	rtl8723ae_dm_bt_set_fw_dec_bt_pwr(hw, false);
+	rtl8723e_dm_bt_set_fw_ignore_wlan_act(hw, false);
+	rtl8723e_dm_bt_set_fw_3a(hw, 0x0, 0x0, 0x0, 0x8, 0x0);
+	rtl8723e_dm_bt_set_fw_2_ant_hid(hw, false, false);
+	rtl8723e_dm_bt_set_fw_tra_tdma_ctrl(hw, false, TDMA_2ANT,
+					    TDMA_NAV_OFF);
+	rtl8723e_dm_bt_set_fw_tdma_ctrl(hw, false, TDMA_2ANT, TDMA_NAV_OFF,
+					TDMA_DAC_SWING_OFF);
+	rtl8723e_dm_bt_set_fw_dac_swing_level(hw, 0);
+	rtl8723e_dm_bt_set_fw_bt_hid_info(hw, false);
+	rtl8723e_dm_bt_set_fw_bt_retry_index(hw, 2);
+	rtl8723e_dm_bt_set_fw_wlan_act(hw, 0x10, 0x10);
+	rtl8723e_dm_bt_set_fw_dec_bt_pwr(hw, false);
 }
 
-void rtl8723ae_dm_bt_sw_coex_all_off_8723a(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_sw_coex_all_off_8723a(struct ieee80211_hw *hw)
 {
-	rtl8723ae_dm_bt_agc_table(hw, BT_AGCTABLE_OFF);
-	rtl8723ae_dm_bt_bback_off_level(hw, BT_BB_BACKOFF_OFF);
-	rtl8723ae_dm_bt_reject_ap_aggregated_packet(hw, false);
+	rtl8723e_dm_bt_agc_table(hw, BT_AGCTABLE_OFF);
+	rtl8723e_dm_bt_bb_back_off_level(hw, BT_BB_BACKOFF_OFF);
+	rtl8723e_dm_bt_reject_ap_aggregated_packet(hw, false);
 
-	rtl8723ae_bt_set_penalty_tx_rate_adap(hw, BT_TX_RATE_ADAPTIVE_NORMAL);
-	rtl8723ae_dm_bt_set_sw_rf_rx_lpf_corner(hw, BT_RF_RX_LPF_CORNER_RESUME);
-	rtl8723ae_dm_bt_set_sw_full_time_dac_swing(hw, false, 0xc0);
+	dm_bt_set_sw_penalty_tx_rate_adapt(hw, BT_TX_RATE_ADAPTIVE_NORMAL);
+	rtl8723e_dm_bt_set_sw_rf_rx_lpf_corner(hw, BT_RF_RX_LPF_CORNER_RESUME);
+	rtl8723e_dm_bt_set_sw_full_time_dac_swing(hw, false, 0xc0);
 }
 
-static void rtl8723ae_dm_bt_query_bt_information(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_query_bt_information(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	u8 h2c_parameter[1] = {0};
 
-	rtlhal->hal_coex_8723.c2h_bt_info_req_sent = true;
+	hal_coex_8723.c2h_bt_info_req_sent = true;
 
 	h2c_parameter[0] |=  BIT(0);
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-		 "Query Bt information, write 0x38 = 0x%x\n",
-		 h2c_parameter[0]);
+		"Query Bt information, write 0x38=0x%x\n", h2c_parameter[0]);
 
-	rtl8723ae_fill_h2c_cmd(hw, 0x38, 1, h2c_parameter);
+	rtl8723e_fill_h2c_cmd(hw, 0x38, 1, h2c_parameter);
 }
 
-static void rtl8723ae_dm_bt_bt_hw_counters_monitor(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_bt_hw_counters_monitor(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
-	u32 reg_htx_rx, reg_ltx_rx, u32_tmp;
-	u32 reg_htx, reg_hrx, reg_ltx, reg_lrx;
-
-	reg_htx_rx = REG_HIGH_PRIORITY_TXRX;
-	reg_ltx_rx = REG_LOW_PRIORITY_TXRX;
-
-	u32_tmp = rtl_read_dword(rtlpriv, reg_htx_rx);
-	reg_htx = u32_tmp & MASKLWORD;
-	reg_hrx = (u32_tmp & MASKHWORD)>>16;
-
-	u32_tmp = rtl_read_dword(rtlpriv, reg_ltx_rx);
-	reg_ltx = u32_tmp & MASKLWORD;
-	reg_lrx = (u32_tmp & MASKHWORD)>>16;
-
-	if (rtlpcipriv->bt_coexist.lps_counter > 1) {
-		reg_htx %= rtlpcipriv->bt_coexist.lps_counter;
-		reg_hrx %= rtlpcipriv->bt_coexist.lps_counter;
-		reg_ltx %= rtlpcipriv->bt_coexist.lps_counter;
-		reg_lrx %= rtlpcipriv->bt_coexist.lps_counter;
+	u32 reg_hp_tx_rx, reg_lp_tx_rx, u32_tmp;
+	u32 reg_hp_tx = 0, reg_hp_rx = 0, reg_lp_tx = 0, reg_lp_rx = 0;
+
+	reg_hp_tx_rx = REG_HIGH_PRIORITY_TXRX;
+	reg_lp_tx_rx = REG_LOW_PRIORITY_TXRX;
+
+	u32_tmp = rtl_read_dword(rtlpriv, reg_hp_tx_rx);
+	reg_hp_tx = u32_tmp & MASKLWORD;
+	reg_hp_rx = (u32_tmp & MASKHWORD)>>16;
+
+	u32_tmp = rtl_read_dword(rtlpriv, reg_lp_tx_rx);
+	reg_lp_tx = u32_tmp & MASKLWORD;
+	reg_lp_rx = (u32_tmp & MASKHWORD)>>16;
+
+	if (rtlpriv->btcoexist.lps_counter > 1) {
+		reg_hp_tx %= rtlpriv->btcoexist.lps_counter;
+		reg_hp_rx %= rtlpriv->btcoexist.lps_counter;
+		reg_lp_tx %= rtlpriv->btcoexist.lps_counter;
+		reg_lp_rx %= rtlpriv->btcoexist.lps_counter;
 	}
 
-	rtlhal->hal_coex_8723.high_priority_tx = reg_htx;
-	rtlhal->hal_coex_8723.high_priority_rx = reg_hrx;
-	rtlhal->hal_coex_8723.low_priority_tx = reg_ltx;
-	rtlhal->hal_coex_8723.low_priority_rx = reg_lrx;
+	hal_coex_8723.high_priority_tx = reg_hp_tx;
+	hal_coex_8723.high_priority_rx = reg_hp_rx;
+	hal_coex_8723.low_priority_tx = reg_lp_tx;
+	hal_coex_8723.low_priority_rx = reg_lp_rx;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "High Priority Tx/Rx (reg 0x%x)=%x(%d)/%x(%d)\n",
-		 reg_htx_rx, reg_htx, reg_htx, reg_hrx, reg_hrx);
+		"High Priority Tx/Rx (reg 0x%x)=%x(%d)/%x(%d)\n",
+		reg_hp_tx_rx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "Low Priority Tx/Rx (reg 0x%x)=%x(%d)/%x(%d)\n",
-		 reg_ltx_rx, reg_ltx, reg_ltx, reg_lrx, reg_lrx);
-	rtlpcipriv->bt_coexist.lps_counter = 0;
+		"Low Priority Tx/Rx (reg 0x%x)=%x(%d)/%x(%d)\n",
+		reg_lp_tx_rx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
+	rtlpriv->btcoexist.lps_counter = 0;
+	/* rtl_write_byte(rtlpriv, 0x76e, 0xc); */
 }
 
-static void rtl8723ae_dm_bt_bt_enable_disable_check(struct ieee80211_hw *hw)
+static void rtl8723e_dm_bt_bt_enable_disable_check(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	bool bt_alife = true;
 
-	if (rtlhal->hal_coex_8723.high_priority_tx == 0 &&
-	    rtlhal->hal_coex_8723.high_priority_rx == 0 &&
-	    rtlhal->hal_coex_8723.low_priority_tx == 0 &&
-	    rtlhal->hal_coex_8723.low_priority_rx == 0)
+	if (hal_coex_8723.high_priority_tx == 0 &&
+	    hal_coex_8723.high_priority_rx == 0 &&
+	    hal_coex_8723.low_priority_tx == 0 &&
+	    hal_coex_8723.low_priority_rx == 0) {
 		bt_alife = false;
-	if (rtlhal->hal_coex_8723.high_priority_tx == 0xeaea &&
-	    rtlhal->hal_coex_8723.high_priority_rx == 0xeaea &&
-	    rtlhal->hal_coex_8723.low_priority_tx == 0xeaea &&
-	    rtlhal->hal_coex_8723.low_priority_rx == 0xeaea)
+	}
+	if (hal_coex_8723.high_priority_tx == 0xeaea &&
+	    hal_coex_8723.high_priority_rx == 0xeaea &&
+	    hal_coex_8723.low_priority_tx == 0xeaea &&
+	    hal_coex_8723.low_priority_rx == 0xeaea) {
 		bt_alife = false;
-	if (rtlhal->hal_coex_8723.high_priority_tx == 0xffff &&
-	    rtlhal->hal_coex_8723.high_priority_rx == 0xffff &&
-	    rtlhal->hal_coex_8723.low_priority_tx == 0xffff &&
-	    rtlhal->hal_coex_8723.low_priority_rx == 0xffff)
+	}
+	if (hal_coex_8723.high_priority_tx == 0xffff &&
+	    hal_coex_8723.high_priority_rx == 0xffff &&
+	    hal_coex_8723.low_priority_tx == 0xffff &&
+	    hal_coex_8723.low_priority_rx == 0xffff) {
 		bt_alife = false;
+	}
 	if (bt_alife) {
-		rtlpcipriv->bt_coexist.bt_active_zero_cnt = 0;
-		rtlpcipriv->bt_coexist.cur_bt_disabled = false;
+		rtlpriv->btcoexist.bt_active_zero_cnt = 0;
+		rtlpriv->btcoexist.cur_bt_disabled = false;
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "8723A BT is enabled !!\n");
 	} else {
-		rtlpcipriv->bt_coexist.bt_active_zero_cnt++;
+		rtlpriv->btcoexist.bt_active_zero_cnt++;
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "8723A bt all counters = 0, %d times!!\n",
-			 rtlpcipriv->bt_coexist.bt_active_zero_cnt);
-		if (rtlpcipriv->bt_coexist.bt_active_zero_cnt >= 2) {
-			rtlpcipriv->bt_coexist.cur_bt_disabled = true;
+			 "8723A bt all counters=0, %d times!!\n",
+			 rtlpriv->btcoexist.bt_active_zero_cnt);
+		if (rtlpriv->btcoexist.bt_active_zero_cnt >= 2) {
+			rtlpriv->btcoexist.cur_bt_disabled = true;
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "8723A BT is disabled !!\n");
 		}
 	}
-	if (rtlpcipriv->bt_coexist.pre_bt_disabled !=
-		rtlpcipriv->bt_coexist.cur_bt_disabled) {
-		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "8723A BT is from %s to %s!!\n",
-			 (rtlpcipriv->bt_coexist.pre_bt_disabled ?
-			 "disabled" : "enabled"),
-			 (rtlpcipriv->bt_coexist.cur_bt_disabled ?
-			 "disabled" : "enabled"));
-		rtlpcipriv->bt_coexist.pre_bt_disabled
-			= rtlpcipriv->bt_coexist.cur_bt_disabled;
+	if (rtlpriv->btcoexist.pre_bt_disabled !=
+		rtlpriv->btcoexist.cur_bt_disabled) {
+		RT_TRACE(rtlpriv, COMP_BT_COEXIST,
+			 DBG_TRACE, "8723A BT is from %s to %s!!\n",
+			 (rtlpriv->btcoexist.pre_bt_disabled ?
+				"disabled" : "enabled"),
+			 (rtlpriv->btcoexist.cur_bt_disabled ?
+				"disabled" : "enabled"));
+		rtlpriv->btcoexist.pre_bt_disabled
+			= rtlpriv->btcoexist.cur_bt_disabled;
 	}
 }
 
 
-void rtl8723ae_dm_bt_coexist_8723(struct ieee80211_hw *hw)
+void rtl8723e_dm_bt_coexist_8723(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 
-	rtl8723ae_dm_bt_query_bt_information(hw);
-	rtl8723ae_dm_bt_bt_hw_counters_monitor(hw);
-	rtl8723ae_dm_bt_bt_enable_disable_check(hw);
+	rtl8723e_dm_bt_query_bt_information(hw);
+	rtl8723e_dm_bt_bt_hw_counters_monitor(hw);
+	rtl8723e_dm_bt_bt_enable_disable_check(hw);
 
-	if (rtlpcipriv->bt_coexist.bt_ant_num == ANT_X2) {
+	if (rtlpriv->btcoexist.bt_ant_num == ANT_X2) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTCoex], 2 Ant mechanism\n");
-		_rtl8723ae_dm_bt_coexist_2_ant(hw);
+			"[BTCoex], 2 Ant mechanism\n");
+		_rtl8723e_dm_bt_coexist_2_ant(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-			 "[BTCoex], 1 Ant mechanism\n");
-		_rtl8723ae_dm_bt_coexist_1_ant(hw);
+			"[BTCoex], 1 Ant mechanism\n");
+		_rtl8723e_dm_bt_coexist_1_ant(hw);
 	}
 
-	if (!rtl8723ae_dm_bt_is_same_coexist_state(hw)) {
+	if (!rtl8723e_dm_bt_is_same_coexist_state(hw)) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
 			 "[BTCoex], Coexist State[bitMap] change from 0x%x%8x to 0x%x%8x\n",
-			 rtlpcipriv->bt_coexist.previous_state_h,
-			 rtlpcipriv->bt_coexist.previous_state,
-			 rtlpcipriv->bt_coexist.cstate_h,
-			 rtlpcipriv->bt_coexist.cstate);
-		rtlpcipriv->bt_coexist.previous_state
-			= rtlpcipriv->bt_coexist.cstate;
-		rtlpcipriv->bt_coexist.previous_state_h
-			= rtlpcipriv->bt_coexist.cstate_h;
+			 rtlpriv->btcoexist.previous_state_h,
+			 rtlpriv->btcoexist.previous_state,
+			 rtlpriv->btcoexist.cstate_h,
+			 rtlpriv->btcoexist.cstate);
+		rtlpriv->btcoexist.previous_state
+			= rtlpriv->btcoexist.cstate;
+		rtlpriv->btcoexist.previous_state_h
+			= rtlpriv->btcoexist.cstate_h;
 	}
 }
 
-static void rtl8723ae_dm_bt_parse_bt_info(struct ieee80211_hw *hw,
-					  u8 *tmbuf, u8 len)
+static void rtl8723e_dm_bt_parse_bt_info(struct ieee80211_hw *hw,
+					 u8 *tmp_buf, u8 len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
-	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
 	u8 bt_info;
 	u8 i;
 
-	rtlhal->hal_coex_8723.c2h_bt_info_req_sent = false;
-	rtlhal->hal_coex_8723.bt_retry_cnt = 0;
+	hal_coex_8723.c2h_bt_info_req_sent = false;
+	hal_coex_8723.bt_retry_cnt = 0;
 	for (i = 0; i < len; i++) {
 		if (i == 0)
-			rtlhal->hal_coex_8723.c2h_bt_info_original = tmbuf[i];
+			hal_coex_8723.c2h_bt_info_original = tmp_buf[i];
 		else if (i == 1)
-			rtlhal->hal_coex_8723.bt_retry_cnt = tmbuf[i];
-		if (i == len-1) {
+			hal_coex_8723.bt_retry_cnt = tmp_buf[i];
+		if (i == len-1)
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "0x%2x]", tmbuf[i]);
-		} else {
+				 "0x%2x]", tmp_buf[i]);
+		else
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
-				 "0x%2x, ", tmbuf[i]);
-		}
+				 "0x%2x, ", tmp_buf[i]);
+
 	}
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-		 "BT info bt_info (Data)= 0x%x\n",
-		 rtlhal->hal_coex_8723.c2h_bt_info_original);
-	bt_info = rtlhal->hal_coex_8723.c2h_bt_info_original;
+		"BT info bt_info (Data)= 0x%x\n",
+			hal_coex_8723.c2h_bt_info_original);
+	bt_info = hal_coex_8723.c2h_bt_info_original;
 
 	if (bt_info & BIT(2))
-		rtlhal->hal_coex_8723.c2h_bt_inquiry_page = true;
+		hal_coex_8723.c2h_bt_inquiry_page = true;
 	else
-		rtlhal->hal_coex_8723.c2h_bt_inquiry_page = false;
+		hal_coex_8723.c2h_bt_inquiry_page = false;
+
 
 	if (bt_info & BTINFO_B_CONNECTION) {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTC2H], BTInfo: bConnect=true\n");
-		rtlpcipriv->bt_coexist.bt_busy = true;
-		rtlpcipriv->bt_coexist.cstate &= ~BT_COEX_STATE_BT_IDLE;
+			"[BTC2H], BTInfo: bConnect=true\n");
+		rtlpriv->btcoexist.bt_busy = true;
+		rtlpriv->btcoexist.cstate &= ~BT_COEX_STATE_BT_IDLE;
 	} else {
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
-			 "[BTC2H], BTInfo: bConnect=false\n");
-		rtlpcipriv->bt_coexist.bt_busy = false;
-		rtlpcipriv->bt_coexist.cstate |= BT_COEX_STATE_BT_IDLE;
+			"[BTC2H], BTInfo: bConnect=false\n");
+		rtlpriv->btcoexist.bt_busy = false;
+		rtlpriv->btcoexist.cstate |= BT_COEX_STATE_BT_IDLE;
 	}
 }
 void rtl_8723e_c2h_command_handle(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct c2h_evt_hdr c2h_event;
-	u8 *ptmbuf;
-	u8 index;
-	u8 u1tmp;
-
+	u8 *ptmp_buf = NULL;
+	u8 index = 0;
+	u8 u1b_tmp = 0;
 	memset(&c2h_event, 0, sizeof(c2h_event));
-	u1tmp = rtl_read_byte(rtlpriv, REG_C2HEVT_MSG_NORMAL);
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_C2HEVT_MSG_NORMAL);
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-		 "&&&&&&: REG_C2HEVT_MSG_NORMAL is 0x%x\n", u1tmp);
-	c2h_event.cmd_id = u1tmp & 0xF;
-	c2h_event.cmd_len = (u1tmp & 0xF0) >> 4;
+		"&&&&&&: REG_C2HEVT_MSG_NORMAL is 0x%x\n", u1b_tmp);
+	c2h_event.cmd_id = u1b_tmp & 0xF;
+	c2h_event.cmd_len = (u1b_tmp & 0xF0) >> 4;
 	c2h_event.cmd_seq = rtl_read_byte(rtlpriv, REG_C2HEVT_MSG_NORMAL + 1);
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
 		 "cmd_id: %d, cmd_len: %d, cmd_seq: %d\n",
 		 c2h_event.cmd_id , c2h_event.cmd_len, c2h_event.cmd_seq);
-	u1tmp = rtl_read_byte(rtlpriv, 0x01AF);
-	if (u1tmp == C2H_EVT_HOST_CLOSE) {
+	u1b_tmp = rtl_read_byte(rtlpriv, 0x01AF);
+	if (u1b_tmp == C2H_EVT_HOST_CLOSE) {
 		return;
-	} else if (u1tmp != C2H_EVT_FW_CLOSE) {
+	} else if (u1b_tmp != C2H_EVT_FW_CLOSE) {
 		rtl_write_byte(rtlpriv, 0x1AF, 0x00);
 		return;
 	}
-	ptmbuf = kmalloc(c2h_event.cmd_len, GFP_KERNEL);
-	if (ptmbuf == NULL) {
+	ptmp_buf = kmalloc(c2h_event.cmd_len, GFP_KERNEL);
+	if (ptmp_buf == NULL) {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
 			 "malloc cmd buf failed\n");
 		return;
@@ -1757,30 +1744,37 @@ void rtl_8723e_c2h_command_handle(struct ieee80211_hw *hw)
 
 	/* Read the content */
 	for (index = 0; index < c2h_event.cmd_len; index++)
-		ptmbuf[index] = rtl_read_byte(rtlpriv, REG_C2HEVT_MSG_NORMAL +
-				  2 + index);
+		ptmp_buf[index] = rtl_read_byte(rtlpriv,
+					REG_C2HEVT_MSG_NORMAL + 2 + index);
+
 
 	switch (c2h_event.cmd_id) {
 	case C2H_BT_RSSI:
-		break;
+			break;
 
 	case C2H_BT_OP_MODE:
 			break;
 
 	case BT_INFO:
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 "BT info Byte[0] (ID) is 0x%x\n", c2h_event.cmd_id);
+			"BT info Byte[0] (ID) is 0x%x\n",
+			c2h_event.cmd_id);
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 "BT info Byte[1] (Seq) is 0x%x\n", c2h_event.cmd_seq);
+			"BT info Byte[1] (Seq) is 0x%x\n",
+			c2h_event.cmd_seq);
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 "BT info Byte[2] (Data)= 0x%x\n", ptmbuf[0]);
+			"BT info Byte[2] (Data)= 0x%x\n", ptmp_buf[0]);
+
+		rtl8723e_dm_bt_parse_bt_info(hw, ptmp_buf, c2h_event.cmd_len);
+
+		if (rtlpriv->cfg->ops->get_btc_status())
+			rtlpriv->btcoexist.btc_ops->btc_periodical(rtlpriv);
 
-		rtl8723ae_dm_bt_parse_bt_info(hw, ptmbuf, c2h_event.cmd_len);
 		break;
 	default:
 		break;
 	}
-	kfree(ptmbuf);
+	kfree(ptmp_buf);
 
 	rtl_write_byte(rtlpriv, 0x01AF, C2H_EVT_HOST_CLOSE);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
index 4325ecd..3723d74 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
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
@@ -24,8 +20,7 @@
  * Hsinchu 300, Taiwan.
  * Larry Finger <Larry.Finger@lwfinger.net>
  *
- ****************************************************************************
- */
+ *****************************************************************************/
 
 #ifndef __RTL8723E_HAL_BTC_H__
 #define __RTL8723E_HAL_BTC_H__
@@ -34,21 +29,31 @@
 #include "btc.h"
 #include "hal_bt_coexist.h"
 
-#define	BT_TXRX_CNT_THRES_1		1200
-#define	BT_TXRX_CNT_THRES_2		1400
-#define	BT_TXRX_CNT_THRES_3		3000
-#define	BT_TXRX_CNT_LEVEL_0		0	/* < 1200 */
-#define	BT_TXRX_CNT_LEVEL_1		1	/* >= 1200 && < 1400 */
-#define	BT_TXRX_CNT_LEVEL_2		2	/* >= 1400 */
-#define	BT_TXRX_CNT_LEVEL_3		3
+#define	BT_TXRX_CNT_THRES_1			1200
+#define	BT_TXRX_CNT_THRES_2			1400
+#define	BT_TXRX_CNT_THRES_3			3000
+/* < 1200 */
+#define	BT_TXRX_CNT_LEVEL_0			0
+/* >= 1200 && < 1400 */
+#define	BT_TXRX_CNT_LEVEL_1			1
+/* >= 1400 */
+#define	BT_TXRX_CNT_LEVEL_2			2
+#define	BT_TXRX_CNT_LEVEL_3			3
+
+#define	BT_COEX_DISABLE			0
+#define	BT_Q_PKT_OFF			0
+#define	BT_Q_PKT_ON			1
+
+#define	BT_TX_PWR_OFF			0
+#define	BT_TX_PWR_ON			1
 
 /* TDMA mode definition */
-#define	TDMA_2ANT		0
-#define	TDMA_1ANT		1
-#define	TDMA_NAV_OFF		0
-#define	TDMA_NAV_ON		1
-#define	TDMA_DAC_SWING_OFF	0
-#define	TDMA_DAC_SWING_ON	1
+#define	TDMA_2ANT			0
+#define	TDMA_1ANT			1
+#define	TDMA_NAV_OFF			0
+#define	TDMA_NAV_ON			1
+#define	TDMA_DAC_SWING_OFF		0
+#define	TDMA_DAC_SWING_ON		1
 
 /* PTA mode related definition */
 #define	BT_PTA_MODE_OFF		0
@@ -80,6 +85,7 @@ enum bt_traffic_mode_profile {
 	BT_PROFILE_SCO
 };
 
+/*
 enum hci_ext_bt_operation {
 	HCI_BT_OP_NONE = 0x0,
 	HCI_BT_OP_INQUIRE_START	= 0x1,
@@ -93,6 +99,7 @@ enum hci_ext_bt_operation {
 	HCI_BT_OP_BT_DEV_DISABLE = 0x9,
 	HCI_BT_OP_MAX,
 };
+*/
 
 enum bt_spec {
 	BT_SPEC_1_0_b = 0x00,
@@ -123,12 +130,12 @@ enum bt_state {
 	BT_INFO_STATE_MAX = 7
 };
 
-enum rtl8723ae_c2h_evt {
+enum rtl8723e_c2h_evt {
 	C2H_DBG = 0,
 	C2H_TSF = 1,
 	C2H_AP_RPT_RSP = 2,
-	C2H_CCX_TX_RPT = 3,	/* The FW notify the report of the specific */
-				/* tx packet. */
+	/* The FW notify the report of the specific tx packet. */
+	C2H_CCX_TX_RPT = 3,
 	C2H_BT_RSSI = 4,
 	C2H_BT_OP_MODE = 5,
 	C2H_HW_INFO_EXCH = 10,
@@ -137,15 +144,16 @@ enum rtl8723ae_c2h_evt {
 	MAX_C2HEVENT
 };
 
-void rtl8723ae_dm_bt_fw_coex_all_off_8723a(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_sw_coex_all_off_8723a(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_hw_coex_all_off_8723a(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_coexist_8723(struct ieee80211_hw *hw);
-void rtl8723ae_dm_bt_set_bt_dm(struct ieee80211_hw *hw,
+void rtl8723e_dm_bt_fw_coex_all_off_8723a(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_sw_coex_all_off_8723a(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_hw_coex_all_off_8723a(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_coexist_8723(struct ieee80211_hw *hw);
+void rtl8723e_dm_bt_set_bt_dm(struct ieee80211_hw *hw,
 			      struct btdm_8723 *p_btdm);
 void rtl_8723e_c2h_command_handle(struct ieee80211_hw *hw);
 void rtl_8723e_bt_wifi_media_status_notify(struct ieee80211_hw *hw,
-					   bool mstatus);
-void rtl8723ae_bt_coex_off_before_lps(struct ieee80211_hw *hw);
+					bool mstatus);
+void rtl8723e_dm_bt_turn_off_bt_coexist_before_enter_lps(
+				struct ieee80211_hw *hw);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
index 3338206a..9e1671c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
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
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
+#include "../rtl8723com/phy_common.h"
 #include "dm.h"
 #include "../rtl8723com/dm_common.h"
 #include "fw.h"
@@ -47,8 +44,10 @@
 #include "pwrseq.h"
 #include "btc.h"
 
-static void _rtl8723ae_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
-					u8 set_bits, u8 clear_bits)
+#define LLT_CONFIG	5
+
+static void _rtl8723e_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
+				       u8 set_bits, u8 clear_bits)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -59,7 +58,7 @@ static void _rtl8723ae_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
 	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8) rtlpci->reg_bcn_ctrl_val);
 }
 
-static void _rtl8723ae_stop_tx_beacon(struct ieee80211_hw *hw)
+static void _rtl8723e_stop_tx_beacon(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmp1byte;
@@ -72,7 +71,7 @@ static void _rtl8723ae_stop_tx_beacon(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 2, tmp1byte);
 }
 
-static void _rtl8723ae_resume_tx_beacon(struct ieee80211_hw *hw)
+static void _rtl8723e_resume_tx_beacon(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmp1byte;
@@ -85,17 +84,17 @@ static void _rtl8723ae_resume_tx_beacon(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 2, tmp1byte);
 }
 
-static void _rtl8723ae_enable_bcn_sufunc(struct ieee80211_hw *hw)
+static void _rtl8723e_enable_bcn_sub_func(struct ieee80211_hw *hw)
 {
-	_rtl8723ae_set_bcn_ctrl_reg(hw, 0, BIT(1));
+	_rtl8723e_set_bcn_ctrl_reg(hw, 0, BIT(1));
 }
 
-static void _rtl8723ae_disable_bcn_sufunc(struct ieee80211_hw *hw)
+static void _rtl8723e_disable_bcn_sub_func(struct ieee80211_hw *hw)
 {
-	_rtl8723ae_set_bcn_ctrl_reg(hw, BIT(1), 0);
+	_rtl8723e_set_bcn_ctrl_reg(hw, BIT(1), 0);
 }
 
-void rtl8723ae_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
+void rtl8723e_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -103,54 +102,55 @@ void rtl8723ae_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 	switch (variable) {
 	case HW_VAR_RCR:
-		*((u32 *) (val)) = rtlpci->receive_config;
+		*((u32 *)(val)) = rtlpci->receive_config;
 		break;
 	case HW_VAR_RF_STATE:
 		*((enum rf_pwrstate *)(val)) = ppsc->rfpwr_state;
 		break;
 	case HW_VAR_FWLPS_RF_ON:{
-		enum rf_pwrstate rfState;
-		u32 val_rcr;
-
-		rtlpriv->cfg->ops->get_hw_reg(hw,
-					      HW_VAR_RF_STATE,
-					      (u8 *) (&rfState));
-		if (rfState == ERFOFF) {
-			*((bool *) (val)) = true;
-		} else {
-			val_rcr = rtl_read_dword(rtlpriv, REG_RCR);
-			val_rcr &= 0x00070000;
-			if (val_rcr)
-				*((bool *) (val)) = false;
-			else
-				*((bool *) (val)) = true;
+			enum rf_pwrstate rfstate;
+			u32 val_rcr;
+
+			rtlpriv->cfg->ops->get_hw_reg(hw,
+						      HW_VAR_RF_STATE,
+						      (u8 *)(&rfstate));
+			if (rfstate == ERFOFF) {
+				*((bool *)(val)) = true;
+			} else {
+				val_rcr = rtl_read_dword(rtlpriv, REG_RCR);
+				val_rcr &= 0x00070000;
+				if (val_rcr)
+					*((bool *)(val)) = false;
+				else
+					*((bool *)(val)) = true;
+			}
+			break;
 		}
-		break; }
 	case HW_VAR_FW_PSMODE_STATUS:
-		*((bool *) (val)) = ppsc->fw_current_inpsmode;
+		*((bool *)(val)) = ppsc->fw_current_inpsmode;
 		break;
 	case HW_VAR_CORRECT_TSF:{
-		u64 tsf;
-		u32 *ptsf_low = (u32 *)&tsf;
-		u32 *ptsf_high = ((u32 *)&tsf) + 1;
+			u64 tsf;
+			u32 *ptsf_low = (u32 *)&tsf;
+			u32 *ptsf_high = ((u32 *)&tsf) + 1;
 
-		*ptsf_high = rtl_read_dword(rtlpriv, (REG_TSFTR + 4));
-		*ptsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
+			*ptsf_high = rtl_read_dword(rtlpriv, (REG_TSFTR + 4));
+			*ptsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
 
-		*((u64 *) (val)) = tsf;
+			*((u64 *)(val)) = tsf;
 
-		break; }
+			break;
+		}
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "switch case not process\n");
 		break;
 	}
 }
 
-void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
+void rtl8723e_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
@@ -158,362 +158,400 @@ void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	u8 idx;
 
 	switch (variable) {
-	case HW_VAR_ETHER_ADDR:
-		for (idx = 0; idx < ETH_ALEN; idx++) {
-			rtl_write_byte(rtlpriv, (REG_MACID + idx),
-				       val[idx]);
+	case HW_VAR_ETHER_ADDR:{
+			for (idx = 0; idx < ETH_ALEN; idx++) {
+				rtl_write_byte(rtlpriv, (REG_MACID + idx),
+					       val[idx]);
+			}
+			break;
 		}
-		break;
 	case HW_VAR_BASIC_RATE:{
-		u16 rate_cfg = ((u16 *) val)[0];
-		u8 rate_index = 0;
-		rate_cfg = rate_cfg & 0x15f;
-		rate_cfg |= 0x01;
-		rtl_write_byte(rtlpriv, REG_RRSR, rate_cfg & 0xff);
-		rtl_write_byte(rtlpriv, REG_RRSR + 1,
-			       (rate_cfg >> 8) & 0xff);
-		while (rate_cfg > 0x1) {
-			rate_cfg = (rate_cfg >> 1);
-			rate_index++;
+			u16 b_rate_cfg = ((u16 *)val)[0];
+			u8 rate_index = 0;
+
+			b_rate_cfg = b_rate_cfg & 0x15f;
+			b_rate_cfg |= 0x01;
+			rtl_write_byte(rtlpriv, REG_RRSR, b_rate_cfg & 0xff);
+			rtl_write_byte(rtlpriv, REG_RRSR + 1,
+				       (b_rate_cfg >> 8) & 0xff);
+			while (b_rate_cfg > 0x1) {
+				b_rate_cfg = (b_rate_cfg >> 1);
+				rate_index++;
+			}
+			rtl_write_byte(rtlpriv, REG_INIRTS_RATE_SEL,
+				       rate_index);
+			break;
 		}
-		rtl_write_byte(rtlpriv, REG_INIRTS_RATE_SEL,
-			       rate_index);
-		break; }
-	case HW_VAR_BSSID:
-		for (idx = 0; idx < ETH_ALEN; idx++) {
-			rtl_write_byte(rtlpriv, (REG_BSSID + idx),
-				       val[idx]);
+	case HW_VAR_BSSID:{
+			for (idx = 0; idx < ETH_ALEN; idx++) {
+				rtl_write_byte(rtlpriv, (REG_BSSID + idx),
+					       val[idx]);
+			}
+			break;
 		}
-		break;
-	case HW_VAR_SIFS:
-		rtl_write_byte(rtlpriv, REG_SIFS_CTX + 1, val[0]);
-		rtl_write_byte(rtlpriv, REG_SIFS_TRX + 1, val[1]);
+	case HW_VAR_SIFS:{
+			rtl_write_byte(rtlpriv, REG_SIFS_CTX + 1, val[0]);
+			rtl_write_byte(rtlpriv, REG_SIFS_TRX + 1, val[1]);
 
-		rtl_write_byte(rtlpriv, REG_SPEC_SIFS + 1, val[0]);
-		rtl_write_byte(rtlpriv, REG_MAC_SPEC_SIFS + 1, val[0]);
+			rtl_write_byte(rtlpriv, REG_SPEC_SIFS + 1, val[0]);
+			rtl_write_byte(rtlpriv, REG_MAC_SPEC_SIFS + 1, val[0]);
 
-		if (!mac->ht_enable)
-			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
-				       0x0e0e);
-		else
-			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
-				       *((u16 *) val));
-		break;
+			if (!mac->ht_enable)
+				rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
+					       0x0e0e);
+			else
+				rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
+					       *((u16 *)val));
+			break;
+		}
 	case HW_VAR_SLOT_TIME:{
-		u8 e_aci;
+			u8 e_aci;
 
-		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-			 "HW_VAR_SLOT_TIME %x\n", val[0]);
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+				 "HW_VAR_SLOT_TIME %x\n", val[0]);
 
-		rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
+			rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
 
-		for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      &e_aci);
+			for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+							      HW_VAR_AC_PARAM,
+							      (u8 *)(&e_aci));
+			}
+			break;
 		}
-		break; }
 	case HW_VAR_ACK_PREAMBLE:{
-		u8 reg_tmp;
-		u8 short_preamble = (bool)*val;
-		reg_tmp = (mac->cur_40_prime_sc) << 5;
-		if (short_preamble)
-			reg_tmp |= 0x80;
-
-		rtl_write_byte(rtlpriv, REG_RRSR + 2, reg_tmp);
-		break; }
+			u8 reg_tmp;
+			u8 short_preamble = (bool)(*(u8 *)val);
+
+			reg_tmp = (mac->cur_40_prime_sc) << 5;
+			if (short_preamble)
+				reg_tmp |= 0x80;
+
+			rtl_write_byte(rtlpriv, REG_RRSR + 2, reg_tmp);
+			break;
+		}
 	case HW_VAR_AMPDU_MIN_SPACE:{
-		u8 min_spacing_to_set;
-		u8 sec_min_space;
+			u8 min_spacing_to_set;
+			u8 sec_min_space;
 
-		min_spacing_to_set = *val;
-		if (min_spacing_to_set <= 7) {
-			sec_min_space = 0;
+			min_spacing_to_set = *((u8 *)val);
+			if (min_spacing_to_set <= 7) {
+				sec_min_space = 0;
 
-			if (min_spacing_to_set < sec_min_space)
-				min_spacing_to_set = sec_min_space;
+				if (min_spacing_to_set < sec_min_space)
+					min_spacing_to_set = sec_min_space;
 
-			mac->min_space_cfg = ((mac->min_space_cfg &
-					       0xf8) |
-					      min_spacing_to_set);
+				mac->min_space_cfg = ((mac->min_space_cfg &
+						       0xf8) |
+						      min_spacing_to_set);
 
-			*val = min_spacing_to_set;
+				*val = min_spacing_to_set;
 
-			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
-				  mac->min_space_cfg);
+				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+					 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+					  mac->min_space_cfg);
 
-			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
-				       mac->min_space_cfg);
+				rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
+					       mac->min_space_cfg);
+			}
+			break;
 		}
-		break; }
 	case HW_VAR_SHORTGI_DENSITY:{
-		u8 density_to_set;
+			u8 density_to_set;
 
-		density_to_set = *val;
-		mac->min_space_cfg |= (density_to_set << 3);
+			density_to_set = *((u8 *)val);
+			mac->min_space_cfg |= (density_to_set << 3);
 
-		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-			 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
-			 mac->min_space_cfg);
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+				 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
+				  mac->min_space_cfg);
 
-		rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
-			       mac->min_space_cfg);
+			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
+				       mac->min_space_cfg);
 
-		break; }
+			break;
+		}
 	case HW_VAR_AMPDU_FACTOR:{
-		u8 regtoset_normal[4] = {0x41, 0xa8, 0x72, 0xb9};
-		u8 regtoset_bt[4] = {0x31, 0x74, 0x42, 0x97};
-		u8 factor_toset;
-		u8 *p_regtoset = NULL;
-		u8 index;
-
-		if ((pcipriv->bt_coexist.bt_coexistence) &&
-		    (pcipriv->bt_coexist.bt_coexist_type == BT_CSR_BC4))
-			p_regtoset = regtoset_bt;
-		else
-			p_regtoset = regtoset_normal;
-
-		factor_toset = *val;
-		if (factor_toset <= 3) {
-			factor_toset = (1 << (factor_toset + 2));
-			if (factor_toset > 0xf)
-				factor_toset = 0xf;
-
-			for (index = 0; index < 4; index++) {
-				if ((p_regtoset[index] & 0xf0) >
-				    (factor_toset << 4))
-					p_regtoset[index] =
-					    (p_regtoset[index] & 0x0f) |
-					    (factor_toset << 4);
-
-				if ((p_regtoset[index] & 0x0f) >
-				    factor_toset)
-					p_regtoset[index] =
-					    (p_regtoset[index] & 0xf0) |
-					    (factor_toset);
-
-				rtl_write_byte(rtlpriv,
-					       (REG_AGGLEN_LMT + index),
-					       p_regtoset[index]);
+			u8 regtoset_normal[4] = { 0x41, 0xa8, 0x72, 0xb9 };
+			u8 regtoset_bt[4] = {0x31, 0x74, 0x42, 0x97};
+			u8 factor_toset;
+			u8 *p_regtoset = NULL;
+			u8 index = 0;
+
+			if ((rtlpriv->btcoexist.bt_coexistence) &&
+			    (rtlpriv->btcoexist.bt_coexist_type ==
+				BT_CSR_BC4))
+				p_regtoset = regtoset_bt;
+			else
+				p_regtoset = regtoset_normal;
+
+			factor_toset = *((u8 *)val);
+			if (factor_toset <= 3) {
+				factor_toset = (1 << (factor_toset + 2));
+				if (factor_toset > 0xf)
+					factor_toset = 0xf;
+
+				for (index = 0; index < 4; index++) {
+					if ((p_regtoset[index] & 0xf0) >
+					    (factor_toset << 4))
+						p_regtoset[index] =
+						    (p_regtoset[index] & 0x0f) |
+						    (factor_toset << 4);
+
+					if ((p_regtoset[index] & 0x0f) >
+					    factor_toset)
+						p_regtoset[index] =
+						    (p_regtoset[index] & 0xf0) |
+						    (factor_toset);
+
+					rtl_write_byte(rtlpriv,
+						       (REG_AGGLEN_LMT + index),
+						       p_regtoset[index]);
+				}
 
+				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+					 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
+					  factor_toset);
 			}
-
-			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
-				 factor_toset);
+			break;
 		}
-		break; }
 	case HW_VAR_AC_PARAM:{
-		u8 e_aci = *val;
-		rtl8723_dm_init_edca_turbo(hw);
+			u8 e_aci = *((u8 *)val);
 
-		if (rtlpci->acm_method != EACMWAY2_SW)
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
-						      &e_aci);
-		break; }
+			rtl8723_dm_init_edca_turbo(hw);
+
+			if (rtlpci->acm_method != EACMWAY2_SW)
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+							      HW_VAR_ACM_CTRL,
+							      (u8 *)(&e_aci));
+			break;
+		}
 	case HW_VAR_ACM_CTRL:{
-		u8 e_aci = *val;
-		union aci_aifsn *p_aci_aifsn =
-		    (union aci_aifsn *)(&(mac->ac[0].aifs));
-		u8 acm = p_aci_aifsn->f.acm;
-		u8 acm_ctrl = rtl_read_byte(rtlpriv, REG_ACMHWCTRL);
-
-		acm_ctrl |= ((rtlpci->acm_method == 2) ? 0x0 : 0x1);
-
-		if (acm) {
-			switch (e_aci) {
-			case AC0_BE:
-				acm_ctrl |= AcmHw_BeqEn;
-				break;
-			case AC2_VI:
-				acm_ctrl |= AcmHw_ViqEn;
-				break;
-			case AC3_VO:
-				acm_ctrl |= AcmHw_VoqEn;
-				break;
-			default:
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
-					 acm);
-				break;
-			}
-		} else {
-			switch (e_aci) {
-			case AC0_BE:
-				acm_ctrl &= (~AcmHw_BeqEn);
-				break;
-			case AC2_VI:
-				acm_ctrl &= (~AcmHw_ViqEn);
-				break;
-			case AC3_VO:
-				acm_ctrl &= (~AcmHw_BeqEn);
-				break;
-			default:
-				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					 "switch case not processed\n");
-				break;
+			u8 e_aci = *((u8 *)val);
+			union aci_aifsn *p_aci_aifsn =
+			    (union aci_aifsn *)(&mac->ac[0].aifs);
+			u8 acm = p_aci_aifsn->f.acm;
+			u8 acm_ctrl = rtl_read_byte(rtlpriv, REG_ACMHWCTRL);
+
+			acm_ctrl =
+			    acm_ctrl | ((rtlpci->acm_method == 2) ? 0x0 : 0x1);
+
+			if (acm) {
+				switch (e_aci) {
+				case AC0_BE:
+					acm_ctrl |= ACMHW_BEQEN;
+					break;
+				case AC2_VI:
+					acm_ctrl |= ACMHW_VIQEN;
+					break;
+				case AC3_VO:
+					acm_ctrl |= ACMHW_VOQEN;
+					break;
+				default:
+					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+						 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+						 acm);
+					break;
+				}
+			} else {
+				switch (e_aci) {
+				case AC0_BE:
+					acm_ctrl &= (~ACMHW_BEQEN);
+					break;
+				case AC2_VI:
+					acm_ctrl &= (~ACMHW_VIQEN);
+					break;
+				case AC3_VO:
+					acm_ctrl &= (~ACMHW_BEQEN);
+					break;
+				default:
+					RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+						 "switch case not process\n");
+					break;
+				}
 			}
-		}
 
-		RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
-			 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
-			 acm_ctrl);
-		rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
-		break; }
-	case HW_VAR_RCR:
-		rtl_write_dword(rtlpriv, REG_RCR, ((u32 *) (val))[0]);
-		rtlpci->receive_config = ((u32 *) (val))[0];
-		break;
+			RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
+				 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+				 acm_ctrl);
+			rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
+			break;
+		}
+	case HW_VAR_RCR:{
+			rtl_write_dword(rtlpriv, REG_RCR, ((u32 *)(val))[0]);
+			rtlpci->receive_config = ((u32 *)(val))[0];
+			break;
+		}
 	case HW_VAR_RETRY_LIMIT:{
-		u8 retry_limit = *val;
+			u8 retry_limit = ((u8 *)(val))[0];
 
-		rtl_write_word(rtlpriv, REG_RL,
-			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
-			       retry_limit << RETRY_LIMIT_LONG_SHIFT);
-		break; }
+			rtl_write_word(rtlpriv, REG_RL,
+				       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
+				       retry_limit << RETRY_LIMIT_LONG_SHIFT);
+			break;
+		}
 	case HW_VAR_DUAL_TSF_RST:
 		rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, (BIT(0) | BIT(1)));
 		break;
 	case HW_VAR_EFUSE_BYTES:
-		rtlefuse->efuse_usedbytes = *((u16 *) val);
+		rtlefuse->efuse_usedbytes = *((u16 *)val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *val;
+		rtlefuse->efuse_usedpercentage = *((u8 *)val);
 		break;
 	case HW_VAR_IO_CMD:
-		rtl8723ae_phy_set_io_cmd(hw, (*(enum io_type *)val));
+		rtl8723e_phy_set_io_cmd(hw, (*(enum io_type *)val));
 		break;
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
+		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *)val));
 		break;
 	case HW_VAR_SET_RPWM:{
-		u8 rpwm_val;
+			u8 rpwm_val;
 
-		rpwm_val = rtl_read_byte(rtlpriv, REG_PCIE_HRPWM);
-		udelay(1);
+			rpwm_val = rtl_read_byte(rtlpriv, REG_PCIE_HRPWM);
+			udelay(1);
 
-		if (rpwm_val & BIT(7)) {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val);
-		} else {
-			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val | BIT(7));
-		}
+			if (rpwm_val & BIT(7)) {
+				rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
+					       (*(u8 *)val));
+			} else {
+				rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
+					       ((*(u8 *)val) | BIT(7)));
+			}
 
-		break; }
+			break;
+		}
 	case HW_VAR_H2C_FW_PWRMODE:{
-		u8 psmode = *val;
+			u8 psmode = (*(u8 *)val);
 
-		if (psmode != FW_PS_ACTIVE_MODE)
-			rtl8723ae_dm_rf_saving(hw, true);
+			if (psmode != FW_PS_ACTIVE_MODE)
+				rtl8723e_dm_rf_saving(hw, true);
 
-		rtl8723ae_set_fw_pwrmode_cmd(hw, *val);
-		break; }
+			rtl8723e_set_fw_pwrmode_cmd(hw, (*(u8 *)val));
+			break;
+		}
 	case HW_VAR_FW_PSMODE_STATUS:
-		ppsc->fw_current_inpsmode = *((bool *) val);
+		ppsc->fw_current_inpsmode = *((bool *)val);
 		break;
 	case HW_VAR_H2C_FW_JOINBSSRPT:{
-		u8 mstatus = *val;
-		u8 tmp_regcr, tmp_reg422;
-		bool recover = false;
-
-		if (mstatus == RT_MEDIA_CONNECT) {
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID, NULL);
-
-			tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
-			rtl_write_byte(rtlpriv, REG_CR + 1,
-				       (tmp_regcr | BIT(0)));
-
-			_rtl8723ae_set_bcn_ctrl_reg(hw, 0, BIT(3));
-			_rtl8723ae_set_bcn_ctrl_reg(hw, BIT(4), 0);
+			u8 mstatus = (*(u8 *)val);
+			u8 tmp_regcr, tmp_reg422;
+			bool b_recover = false;
+
+			if (mstatus == RT_MEDIA_CONNECT) {
+				rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID,
+							      NULL);
+
+				tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
+				rtl_write_byte(rtlpriv, REG_CR + 1,
+					       (tmp_regcr | BIT(0)));
+
+				_rtl8723e_set_bcn_ctrl_reg(hw, 0, BIT(3));
+				_rtl8723e_set_bcn_ctrl_reg(hw, BIT(4), 0);
+
+				tmp_reg422 =
+				    rtl_read_byte(rtlpriv,
+						  REG_FWHW_TXQ_CTRL + 2);
+				if (tmp_reg422 & BIT(6))
+					b_recover = true;
+				rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
+					       tmp_reg422 & (~BIT(6)));
 
-			tmp_reg422 = rtl_read_byte(rtlpriv,
-				     REG_FWHW_TXQ_CTRL + 2);
-			if (tmp_reg422 & BIT(6))
-				recover = true;
-			rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
-				       tmp_reg422 & (~BIT(6)));
+				rtl8723e_set_fw_rsvdpagepkt(hw, 0);
 
-			rtl8723ae_set_fw_rsvdpagepkt(hw, 0);
+				_rtl8723e_set_bcn_ctrl_reg(hw, BIT(3), 0);
+				_rtl8723e_set_bcn_ctrl_reg(hw, 0, BIT(4));
 
-			_rtl8723ae_set_bcn_ctrl_reg(hw, BIT(3), 0);
-			_rtl8723ae_set_bcn_ctrl_reg(hw, 0, BIT(4));
+				if (b_recover) {
+					rtl_write_byte(rtlpriv,
+						       REG_FWHW_TXQ_CTRL + 2,
+						       tmp_reg422);
+				}
 
-			if (recover)
-				rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
-					       tmp_reg422);
+				rtl_write_byte(rtlpriv, REG_CR + 1,
+					       (tmp_regcr & ~(BIT(0))));
+			}
+			rtl8723e_set_fw_joinbss_report_cmd(hw, (*(u8 *)val));
 
-			rtl_write_byte(rtlpriv, REG_CR + 1,
-				       (tmp_regcr & ~(BIT(0))));
+			break;
 		}
-		rtl8723ae_set_fw_joinbss_report_cmd(hw, *val);
-
-		break; }
-	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
-		rtl8723ae_set_p2p_ps_offload_cmd(hw, *val);
+	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:{
+		rtl8723e_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
 		break;
+	}
 	case HW_VAR_AID:{
-		u16 u2btmp;
-		u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
-		u2btmp &= 0xC000;
-		rtl_write_word(rtlpriv, REG_BCN_PSR_RPT, (u2btmp |
-				mac->assoc_id));
-		break; }
+			u16 u2btmp;
+
+			u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
+			u2btmp &= 0xC000;
+			rtl_write_word(rtlpriv, REG_BCN_PSR_RPT,
+				       (u2btmp | mac->assoc_id));
+
+			break;
+		}
 	case HW_VAR_CORRECT_TSF:{
-		u8 btype_ibss = *val;
-
-		if (btype_ibss == true)
-			_rtl8723ae_stop_tx_beacon(hw);
-
-		_rtl8723ae_set_bcn_ctrl_reg(hw, 0, BIT(3));
-
-		rtl_write_dword(rtlpriv, REG_TSFTR,
-				(u32) (mac->tsf & 0xffffffff));
-		rtl_write_dword(rtlpriv, REG_TSFTR + 4,
-				(u32) ((mac->tsf >> 32) & 0xffffffff));
-
-		_rtl8723ae_set_bcn_ctrl_reg(hw, BIT(3), 0);
-
-		if (btype_ibss == true)
-			_rtl8723ae_resume_tx_beacon(hw);
-		break; }
-	case HW_VAR_FW_LPS_ACTION: {
-		bool enter_fwlps = *((bool *)val);
-		u8 rpwm_val, fw_pwrmode;
-		bool fw_current_inps;
-
-		if (enter_fwlps) {
-			rpwm_val = 0x02;	/* RF off */
-			fw_current_inps = true;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_FW_PSMODE_STATUS,
-					(u8 *)(&fw_current_inps));
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_H2C_FW_PWRMODE,
-					&ppsc->fwctrl_psmode);
-
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-						      &rpwm_val);
-		} else {
-			rpwm_val = 0x0C;	/* RF on */
-			fw_pwrmode = FW_PS_ACTIVE_MODE;
-			fw_current_inps = false;
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-						      &rpwm_val);
-			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
-						      &fw_pwrmode);
-
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-					HW_VAR_FW_PSMODE_STATUS,
-					(u8 *)(&fw_current_inps));
+			u8 btype_ibss = ((u8 *)(val))[0];
+
+			if (btype_ibss)
+				_rtl8723e_stop_tx_beacon(hw);
+
+			_rtl8723e_set_bcn_ctrl_reg(hw, 0, BIT(3));
+
+			rtl_write_dword(rtlpriv, REG_TSFTR,
+					(u32)(mac->tsf & 0xffffffff));
+			rtl_write_dword(rtlpriv, REG_TSFTR + 4,
+					(u32)((mac->tsf >> 32) & 0xffffffff));
+
+			_rtl8723e_set_bcn_ctrl_reg(hw, BIT(3), 0);
+
+			if (btype_ibss)
+				_rtl8723e_resume_tx_beacon(hw);
+
+			break;
+		}
+	case HW_VAR_FW_LPS_ACTION:{
+			bool b_enter_fwlps = *((bool *)val);
+			u8 rpwm_val, fw_pwrmode;
+			bool fw_current_inps;
+
+			if (b_enter_fwlps) {
+				rpwm_val = 0x02;	/* RF off */
+				fw_current_inps = true;
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_FW_PSMODE_STATUS,
+						(u8 *)(&fw_current_inps));
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_H2C_FW_PWRMODE,
+						(u8 *)(&ppsc->fwctrl_psmode));
+
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_SET_RPWM,
+						(u8 *)(&rpwm_val));
+			} else {
+				rpwm_val = 0x0C;	/* RF on */
+				fw_pwrmode = FW_PS_ACTIVE_MODE;
+				fw_current_inps = false;
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+							      HW_VAR_SET_RPWM,
+							      (u8 *)(&rpwm_val));
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_H2C_FW_PWRMODE,
+						(u8 *)(&fw_pwrmode));
+
+				rtlpriv->cfg->ops->set_hw_reg(hw,
+						HW_VAR_FW_PSMODE_STATUS,
+						(u8 *)(&fw_current_inps));
+			}
+			 break;
 		}
-		break; }
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
 		break;
 	}
 }
 
-static bool _rtl8723ae_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
+static bool _rtl8723e_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	bool status = true;
@@ -540,24 +578,49 @@ static bool _rtl8723ae_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 	return status;
 }
 
-static bool _rtl8723ae_llt_table_init(struct ieee80211_hw *hw)
+static bool _rtl8723e_llt_table_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	unsigned short i;
 	u8 txpktbuf_bndy;
-	u8 maxPage;
+	u8 maxpage;
 	bool status;
 	u8 ubyte;
 
-	maxPage = 255;
+#if LLT_CONFIG == 1
+	maxpage = 255;
+	txpktbuf_bndy = 252;
+#elif LLT_CONFIG == 2
+	maxpage = 127;
+	txpktbuf_bndy = 124;
+#elif LLT_CONFIG == 3
+	maxpage = 255;
+	txpktbuf_bndy = 174;
+#elif LLT_CONFIG == 4
+	maxpage = 255;
 	txpktbuf_bndy = 246;
+#elif LLT_CONFIG == 5
+	maxpage = 255;
+	txpktbuf_bndy = 246;
+#endif
 
 	rtl_write_byte(rtlpriv, REG_CR, 0x8B);
 
+#if LLT_CONFIG == 1
+	rtl_write_byte(rtlpriv, REG_RQPN_NPQ, 0x1c);
+	rtl_write_dword(rtlpriv, REG_RQPN, 0x80a71c1c);
+#elif LLT_CONFIG == 2
+	rtl_write_dword(rtlpriv, REG_RQPN, 0x845B1010);
+#elif LLT_CONFIG == 3
+	rtl_write_dword(rtlpriv, REG_RQPN, 0x84838484);
+#elif LLT_CONFIG == 4
+	rtl_write_dword(rtlpriv, REG_RQPN, 0x80bd1c1c);
+#elif LLT_CONFIG == 5
 	rtl_write_word(rtlpriv, REG_RQPN_NPQ, 0x0000);
 
 	rtl_write_dword(rtlpriv, REG_RQPN, 0x80ac1c29);
 	rtl_write_byte(rtlpriv, REG_RQPN_NPQ, 0x03);
+#endif
 
 	rtl_write_dword(rtlpriv, REG_TRXFF_BNDY, (0x27FF0000 | txpktbuf_bndy));
 	rtl_write_byte(rtlpriv, REG_TDECTRL + 1, txpktbuf_bndy);
@@ -570,22 +633,22 @@ static bool _rtl8723ae_llt_table_init(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_RX_DRVINFO_SZ, 0x4);
 
 	for (i = 0; i < (txpktbuf_bndy - 1); i++) {
-		status = _rtl8723ae_llt_write(hw, i, i + 1);
+		status = _rtl8723e_llt_write(hw, i, i + 1);
 		if (true != status)
 			return status;
 	}
 
-	status = _rtl8723ae_llt_write(hw, (txpktbuf_bndy - 1), 0xFF);
+	status = _rtl8723e_llt_write(hw, (txpktbuf_bndy - 1), 0xFF);
 	if (true != status)
 		return status;
 
-	for (i = txpktbuf_bndy; i < maxPage; i++) {
-		status = _rtl8723ae_llt_write(hw, i, (i + 1));
+	for (i = txpktbuf_bndy; i < maxpage; i++) {
+		status = _rtl8723e_llt_write(hw, i, (i + 1));
 		if (true != status)
 			return status;
 	}
 
-	status = _rtl8723ae_llt_write(hw, maxPage, txpktbuf_bndy);
+	status = _rtl8723e_llt_write(hw, maxpage, txpktbuf_bndy);
 	if (true != status)
 		return status;
 
@@ -596,28 +659,29 @@ static bool _rtl8723ae_llt_table_init(struct ieee80211_hw *hw)
 	return true;
 }
 
-static void _rtl8723ae_gen_refresh_led_state(struct ieee80211_hw *hw)
+static void _rtl8723e_gen_refresh_led_state(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
+	struct rtl_led *pled0 = &pcipriv->ledctl.sw_led0;
 
 	if (rtlpriv->rtlhal.up_first_time)
 		return;
 
 	if (ppsc->rfoff_reason == RF_CHANGE_BY_IPS)
-		rtl8723ae_sw_led_on(hw, pLed0);
+		rtl8723e_sw_led_on(hw, pled0);
 	else if (ppsc->rfoff_reason == RF_CHANGE_BY_INIT)
-		rtl8723ae_sw_led_on(hw, pLed0);
+		rtl8723e_sw_led_on(hw, pled0);
 	else
-		rtl8723ae_sw_led_off(hw, pLed0);
+		rtl8723e_sw_led_off(hw, pled0);
 }
 
 static bool _rtl8712e_init_mac(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
 	unsigned char bytetmp;
 	unsigned short wordtmp;
 	u16 retry = 0;
@@ -631,7 +695,6 @@ static bool _rtl8712e_init_mac(struct ieee80211_hw *hw)
 	else
 		mac_func_enable = false;
 
-
 	/* HW Power on sequence */
 	if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
 		PWR_INTF_PCI_MSK, Rtl8723_NIC_ENABLE_FLOW))
@@ -670,7 +733,7 @@ static bool _rtl8712e_init_mac(struct ieee80211_hw *hw)
 	rtl_write_word(rtlpriv, REG_CR + 1, 0x06);
 
 	if (!mac_func_enable) {
-		if (_rtl8723ae_llt_table_init(hw) == false)
+		if (!_rtl8723e_llt_table_init(hw))
 			return false;
 	}
 
@@ -679,7 +742,8 @@ static bool _rtl8712e_init_mac(struct ieee80211_hw *hw)
 
 	rtl_write_word(rtlpriv, REG_TRXFF_BNDY + 2, 0x27ff);
 
-	wordtmp = rtl_read_word(rtlpriv, REG_TRXDMA_CTRL) & 0xf;
+	wordtmp = rtl_read_word(rtlpriv, REG_TRXDMA_CTRL);
+	wordtmp &= 0xf;
 	wordtmp |= 0xF771;
 	rtl_write_word(rtlpriv, REG_TRXDMA_CTRL, wordtmp);
 
@@ -722,22 +786,23 @@ static bool _rtl8712e_init_mac(struct ieee80211_hw *hw)
 		bytetmp = rtl_read_byte(rtlpriv, REG_APSD_CTRL);
 	} while ((retry < 200) && (bytetmp & BIT(7)));
 
-	_rtl8723ae_gen_refresh_led_state(hw);
+	_rtl8723e_gen_refresh_led_state(hw);
 
 	rtl_write_dword(rtlpriv, REG_MCUTST_1, 0x0);
 
 	return true;
 }
 
-static void _rtl8723ae_hw_configure(struct ieee80211_hw *hw)
+static void _rtl8723e_hw_configure(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	u8 reg_bw_opmode;
-	u32 reg_prsr;
+	u32 reg_ratr, reg_prsr;
 
 	reg_bw_opmode = BW_OPMODE_20MHZ;
+	reg_ratr = RATE_ALL_CCK | RATE_ALL_OFDM_AG |
+	    RATE_ALL_OFDM_1SS | RATE_ALL_OFDM_2SS;
 	reg_prsr = RATE_ALL_CCK | RATE_ALL_OFDM_AG;
 
 	rtl_write_byte(rtlpriv, REG_INIRTS_RATE_SEL, 0x8);
@@ -763,8 +828,8 @@ static void _rtl8723ae_hw_configure(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, REG_RARFRC, 0x01000000);
 	rtl_write_dword(rtlpriv, REG_RARFRC + 4, 0x07060504);
 
-	if ((pcipriv->bt_coexist.bt_coexistence) &&
-	    (pcipriv->bt_coexist.bt_coexist_type == BT_CSR_BC4))
+	if ((rtlpriv->btcoexist.bt_coexistence) &&
+	    (rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4))
 		rtl_write_dword(rtlpriv, REG_AGGLEN_LMT, 0x97427431);
 	else
 		rtl_write_dword(rtlpriv, REG_AGGLEN_LMT, 0xb972a841);
@@ -783,8 +848,8 @@ static void _rtl8723ae_hw_configure(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_PIFS, 0x1C);
 	rtl_write_byte(rtlpriv, REG_AGGR_BREAK_TIME, 0x16);
 
-	if ((pcipriv->bt_coexist.bt_coexistence) &&
-	    (pcipriv->bt_coexist.bt_coexist_type == BT_CSR_BC4)) {
+	if ((rtlpriv->btcoexist.bt_coexistence) &&
+	    (rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4)) {
 		rtl_write_word(rtlpriv, REG_NAV_PROT_LEN, 0x0020);
 		rtl_write_word(rtlpriv, REG_PROT_MODE_CTRL, 0x0402);
 	} else {
@@ -792,8 +857,8 @@ static void _rtl8723ae_hw_configure(struct ieee80211_hw *hw)
 		rtl_write_word(rtlpriv, REG_NAV_PROT_LEN, 0x0020);
 	}
 
-	if ((pcipriv->bt_coexist.bt_coexistence) &&
-	     (pcipriv->bt_coexist.bt_coexist_type == BT_CSR_BC4))
+	if ((rtlpriv->btcoexist.bt_coexistence) &&
+	    (rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4))
 		rtl_write_dword(rtlpriv, REG_FAST_EDCA_CTRL, 0x03086666);
 	else
 		rtl_write_dword(rtlpriv, REG_FAST_EDCA_CTRL, 0x086666);
@@ -813,7 +878,7 @@ static void _rtl8723ae_hw_configure(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, 0x394, 0x1);
 }
 
-static void _rtl8723ae_enable_aspm_back_door(struct ieee80211_hw *hw)
+static void _rtl8723e_enable_aspm_back_door(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -831,15 +896,15 @@ static void _rtl8723ae_enable_aspm_back_door(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, 0x352, 0x1);
 }
 
-void rtl8723ae_enable_hw_security_config(struct ieee80211_hw *hw)
+void rtl8723e_enable_hw_security_config(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 sec_reg_value;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		 "PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
-		 rtlpriv->sec.pairwise_enc_algorithm,
-		 rtlpriv->sec.group_enc_algorithm);
+		  rtlpriv->sec.pairwise_enc_algorithm,
+		  rtlpriv->sec.group_enc_algorithm);
 
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
@@ -847,11 +912,11 @@ void rtl8723ae_enable_hw_security_config(struct ieee80211_hw *hw)
 		return;
 	}
 
-	sec_reg_value = SCR_TxEncEnable | SCR_RxDecEnable;
+	sec_reg_value = SCR_TXENCENABLE | SCR_RXDECENABLE;
 
 	if (rtlpriv->sec.use_defaultkey) {
-		sec_reg_value |= SCR_TxUseDK;
-		sec_reg_value |= SCR_RxUseDK;
+		sec_reg_value |= SCR_TXUSEDK;
+		sec_reg_value |= SCR_RXUSEDK;
 	}
 
 	sec_reg_value |= (SCR_RXBCUSEDK | SCR_TXBCUSEDK);
@@ -865,7 +930,7 @@ void rtl8723ae_enable_hw_security_config(struct ieee80211_hw *hw)
 
 }
 
-int rtl8723ae_hw_init(struct ieee80211_hw *hw)
+int rtl8723e_hw_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
@@ -888,6 +953,7 @@ int rtl8723ae_hw_init(struct ieee80211_hw *hw)
 	 */
 	local_save_flags(flags);
 	local_irq_enable();
+	rtlhal->fw_ready = false;
 
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus = _rtl8712e_init_mac(hw);
@@ -897,20 +963,19 @@ int rtl8723ae_hw_init(struct ieee80211_hw *hw)
 		goto exit;
 	}
 
-	err = rtl8723_download_fw(hw, false);
+	err = rtl8723_download_fw(hw, false, FW_8192C_POLLING_TIMEOUT_COUNT);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Failed to download FW. Init HW without FW now..\n");
 		err = 1;
 		goto exit;
-	} else {
-		rtlhal->fw_ready = true;
 	}
+	rtlhal->fw_ready = true;
 
 	rtlhal->last_hmeboxnum = 0;
-	rtl8723ae_phy_mac_config(hw);
-	/* because the last function modifies RCR, we update
-	 * rcr var here, or TP will be unstable as ther receive_config
+	rtl8723e_phy_mac_config(hw);
+	/* because last function modify RCR, so we update
+	 * rcr var here, or TP will unstable for receive_config
 	 * is wrong, RX RCR_ACRC32 will cause TP unstable & Rx
 	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252
 	 */
@@ -918,9 +983,9 @@ int rtl8723ae_hw_init(struct ieee80211_hw *hw)
 	rtlpci->receive_config &= ~(RCR_ACRC32 | RCR_AICV);
 	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
 
-	rtl8723ae_phy_bb_config(hw);
+	rtl8723e_phy_bb_config(hw);
 	rtlphy->rf_mode = RF_OP_BY_SW_3WIRE;
-	rtl8723ae_phy_rf_config(hw);
+	rtl8723e_phy_rf_config(hw);
 	if (IS_VENDOR_UMC_A_CUT(rtlhal->version)) {
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD, 0x30255);
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G2, MASKDWORD, 0x50a00);
@@ -939,28 +1004,29 @@ int rtl8723ae_hw_init(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, RFPGA0_RFMOD, BCCKEN, 0x1);
 	rtl_set_bbreg(hw, RFPGA0_RFMOD, BOFDMEN, 0x1);
 	rtl_set_bbreg(hw, RFPGA0_ANALOGPARAMETER2, BIT(10), 1);
-	_rtl8723ae_hw_configure(hw);
+	_rtl8723e_hw_configure(hw);
 	rtl_cam_reset_all_entry(hw);
-	rtl8723ae_enable_hw_security_config(hw);
+	rtl8723e_enable_hw_security_config(hw);
 
 	ppsc->rfpwr_state = ERFON;
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR, mac->mac_addr);
-	_rtl8723ae_enable_aspm_back_door(hw);
+	_rtl8723e_enable_aspm_back_door(hw);
 	rtlpriv->intf_ops->enable_aspm(hw);
 
-	rtl8723ae_bt_hw_init(hw);
+	rtl8723e_bt_hw_init(hw);
 
 	if (ppsc->rfpwr_state == ERFON) {
-		rtl8723ae_phy_set_rfpath_switch(hw, 1);
+		rtl8723e_phy_set_rfpath_switch(hw, 1);
 		if (rtlphy->iqk_initialized) {
-			rtl8723ae_phy_iq_calibrate(hw, true);
+			rtl8723e_phy_iq_calibrate(hw, true);
 		} else {
-			rtl8723ae_phy_iq_calibrate(hw, false);
+			rtl8723e_phy_iq_calibrate(hw, false);
 			rtlphy->iqk_initialized = true;
 		}
 
-		rtl8723ae_phy_lc_calibrate(hw);
+		rtl8723e_dm_check_txpower_tracking(hw);
+		rtl8723e_phy_lc_calibrate(hw);
 	}
 
 	tmp_u1b = efuse_read_1byte(hw, 0x1FA);
@@ -970,20 +1036,21 @@ int rtl8723ae_hw_init(struct ieee80211_hw *hw)
 	}
 
 	if (!(tmp_u1b & BIT(4))) {
-		tmp_u1b = rtl_read_byte(rtlpriv, 0x16) & 0x0F;
+		tmp_u1b = rtl_read_byte(rtlpriv, 0x16);
+		tmp_u1b &= 0x0F;
 		rtl_write_byte(rtlpriv, 0x16, tmp_u1b | 0x80);
 		udelay(10);
 		rtl_write_byte(rtlpriv, 0x16, tmp_u1b | 0x90);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "under 1.5V\n");
 	}
-	rtl8723ae_dm_init(hw);
+	rtl8723e_dm_init(hw);
 exit:
 	local_irq_restore(flags);
 	rtlpriv->rtlhal.being_init_adapter = false;
 	return err;
 }
 
-static enum version_8723e _rtl8723ae_read_chip_version(struct ieee80211_hw *hw)
+static enum version_8723e _rtl8723e_read_chip_version(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
@@ -993,41 +1060,41 @@ static enum version_8723e _rtl8723ae_read_chip_version(struct ieee80211_hw *hw)
 	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG);
 	if (value32 & TRP_VAUX_EN) {
 		version = (enum version_8723e)(version |
-			  ((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
+			((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
 		/* RTL8723 with BT function. */
 		version = (enum version_8723e)(version |
-			  ((value32 & BT_FUNC) ? CHIP_8723 : 0));
+			((value32 & BT_FUNC) ? CHIP_8723 : 0));
 
 	} else {
 		/* Normal mass production chip. */
 		version = (enum version_8723e) NORMAL_CHIP;
 		version = (enum version_8723e)(version |
-			  ((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
+			((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
 		/* RTL8723 with BT function. */
 		version = (enum version_8723e)(version |
-			  ((value32 & BT_FUNC) ? CHIP_8723 : 0));
+			((value32 & BT_FUNC) ? CHIP_8723 : 0));
 		if (IS_CHIP_VENDOR_UMC(version))
 			version = (enum version_8723e)(version |
 			((value32 & CHIP_VER_RTL_MASK)));/* IC version (CUT) */
 		if (IS_8723_SERIES(version)) {
 			value32 = rtl_read_dword(rtlpriv, REG_GPIO_OUTSTS);
-			/* ROM code version */
+			/* ROM code version. */
 			version = (enum version_8723e)(version |
-				  ((value32 & RF_RL_ID)>>20));
+				((value32 & RF_RL_ID)>>20));
 		}
 	}
 
 	if (IS_8723_SERIES(version)) {
 		value32 = rtl_read_dword(rtlpriv, REG_MULTI_FUNC_CTRL);
 		rtlphy->polarity_ctl = ((value32 & WL_HWPDN_SL) ?
-				       RT_POLARITY_HIGH_ACT :
-				       RT_POLARITY_LOW_ACT);
+					RT_POLARITY_HIGH_ACT :
+					RT_POLARITY_LOW_ACT);
 	}
 	switch (version) {
 	case VERSION_TEST_UMC_CHIP_8723:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Chip Version ID: VERSION_TEST_UMC_CHIP_8723.\n");
-		break;
+			break;
 	case VERSION_NORMAL_UMC_CHIP_8723_1T1R_A_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_8723_1T1R_A_CUT.\n");
@@ -1051,113 +1118,124 @@ static enum version_8723e _rtl8723ae_read_chip_version(struct ieee80211_hw *hw)
 	return version;
 }
 
-static int _rtl8723ae_set_media_status(struct ieee80211_hw *hw,
-				     enum nl80211_iftype type)
+static int _rtl8723e_set_media_status(struct ieee80211_hw *hw,
+				      enum nl80211_iftype type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 bt_msr = rtl_read_byte(rtlpriv, MSR) & 0xfc;
 	enum led_ctl_mode ledaction = LED_CTL_NO_LINK;
+	u8 mode = MSR_NOLINK;
 
 	rtl_write_dword(rtlpriv, REG_BCN_CTRL, 0);
 	RT_TRACE(rtlpriv, COMP_BEACON, DBG_LOUD,
-		 "clear 0x550 when set HW_VAR_MEDIA_STATUS\n");
-
-	if (type == NL80211_IFTYPE_UNSPECIFIED ||
-	    type == NL80211_IFTYPE_STATION) {
-		_rtl8723ae_stop_tx_beacon(hw);
-		_rtl8723ae_enable_bcn_sufunc(hw);
-	} else if (type == NL80211_IFTYPE_ADHOC ||
-		type == NL80211_IFTYPE_AP) {
-		_rtl8723ae_resume_tx_beacon(hw);
-		_rtl8723ae_disable_bcn_sufunc(hw);
-	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x).\n",
-			 type);
-	}
+		"clear 0x550 when set HW_VAR_MEDIA_STATUS\n");
 
 	switch (type) {
 	case NL80211_IFTYPE_UNSPECIFIED:
-		bt_msr |= MSR_NOLINK;
-		ledaction = LED_CTL_LINK;
+		mode = MSR_NOLINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Set Network type to NO LINK!\n");
+			"Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
-		bt_msr |= MSR_ADHOC;
+		mode = MSR_ADHOC;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Set Network type to Ad Hoc!\n");
+			"Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
-		bt_msr |= MSR_INFRA;
+		mode = MSR_INFRA;
 		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Set Network type to STA!\n");
+			"Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
-		bt_msr |= MSR_AP;
+		mode = MSR_AP;
+		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Set Network type to AP!\n");
+			"Set Network type to AP!\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Network type %d not supported!\n",
-			 type);
+			"Network type %d not support!\n", type);
 		return 1;
+		break;
+	}
 
+	/* MSR_INFRA == Link in infrastructure network;
+	 * MSR_ADHOC == Link in ad hoc network;
+	 * Therefore, check link state is necessary.
+	 *
+	 * MSR_AP == AP mode; link state is not cared here.
+	 */
+	if (mode != MSR_AP &&
+	    rtlpriv->mac80211.link_state < MAC80211_LINKED) {
+		mode = MSR_NOLINK;
+		ledaction = LED_CTL_NO_LINK;
+	}
+	if (mode == MSR_NOLINK || mode == MSR_INFRA) {
+		_rtl8723e_stop_tx_beacon(hw);
+		_rtl8723e_enable_bcn_sub_func(hw);
+	} else if (mode == MSR_ADHOC || mode == MSR_AP) {
+		_rtl8723e_resume_tx_beacon(hw);
+		_rtl8723e_disable_bcn_sub_func(hw);
+	} else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x).\n",
+			 mode);
 	}
 
-	rtl_write_byte(rtlpriv, (MSR), bt_msr);
+	rtl_write_byte(rtlpriv, (MSR), bt_msr | mode);
 	rtlpriv->cfg->ops->led_control(hw, ledaction);
-	if ((bt_msr & MSR_MASK) == MSR_AP)
+	if (mode == MSR_AP)
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
 	else
 		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
 	return 0;
 }
 
-void rtl8723ae_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
+void rtl8723e_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 reg_rcr;
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rcr = rtlpci->receive_config;
 
 	if (rtlpriv->psc.rfpwr_state != ERFON)
 		return;
 
-	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RCR, (u8 *)(&reg_rcr));
-
-	if (check_bssid == true) {
+	if (check_bssid) {
 		reg_rcr |= (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
 					      (u8 *)(&reg_rcr));
-		_rtl8723ae_set_bcn_ctrl_reg(hw, 0, BIT(4));
-	} else if (check_bssid == false) {
+		_rtl8723e_set_bcn_ctrl_reg(hw, 0, BIT(4));
+	} else if (!check_bssid) {
 		reg_rcr &= (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
-		_rtl8723ae_set_bcn_ctrl_reg(hw, BIT(4), 0);
+		_rtl8723e_set_bcn_ctrl_reg(hw, BIT(4), 0);
 		rtlpriv->cfg->ops->set_hw_reg(hw,
-			HW_VAR_RCR, (u8 *) (&reg_rcr));
+			HW_VAR_RCR, (u8 *)(&reg_rcr));
 	}
 }
 
-int rtl8723ae_set_network_type(struct ieee80211_hw *hw,
-			       enum nl80211_iftype type)
+int rtl8723e_set_network_type(struct ieee80211_hw *hw,
+			      enum nl80211_iftype type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	if (_rtl8723ae_set_media_status(hw, type))
+	if (_rtl8723e_set_media_status(hw, type))
 		return -EOPNOTSUPP;
 
 	if (rtlpriv->mac80211.link_state == MAC80211_LINKED) {
 		if (type != NL80211_IFTYPE_AP)
-			rtl8723ae_set_check_bssid(hw, true);
+			rtl8723e_set_check_bssid(hw, true);
 	} else {
-		rtl8723ae_set_check_bssid(hw, false);
+		rtl8723e_set_check_bssid(hw, false);
 	}
+
 	return 0;
 }
 
-/* don't set REG_EDCA_BE_PARAM here because mac80211 will send pkt when scan */
-void rtl8723ae_set_qos(struct ieee80211_hw *hw, int aci)
+/* don't set REG_EDCA_BE_PARAM here
+ * because mac80211 will send pkt when scan
+ */
+void rtl8723e_set_qos(struct ieee80211_hw *hw, int aci)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
@@ -1167,7 +1245,6 @@ void rtl8723ae_set_qos(struct ieee80211_hw *hw, int aci)
 		rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM, 0xa44f);
 		break;
 	case AC0_BE:
-		/* rtl_write_dword(rtlpriv, REG_EDCA_BE_PARAM, u4ac_param); */
 		break;
 	case AC2_VI:
 		rtl_write_dword(rtlpriv, REG_EDCA_VI_PARAM, 0x5e4322);
@@ -1181,7 +1258,19 @@ void rtl8723ae_set_qos(struct ieee80211_hw *hw, int aci)
 	}
 }
 
-void rtl8723ae_enable_interrupt(struct ieee80211_hw *hw)
+static void rtl8723e_clear_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 tmp;
+
+	tmp = rtl_read_dword(rtlpriv, REG_HISR);
+	rtl_write_dword(rtlpriv, REG_HISR, tmp);
+
+	tmp = rtl_read_dword(rtlpriv, REG_HISRE);
+	rtl_write_dword(rtlpriv, REG_HISRE, tmp);
+}
+
+void rtl8723e_enable_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
@@ -1191,37 +1280,39 @@ void rtl8723ae_enable_interrupt(struct ieee80211_hw *hw)
 	rtlpci->irq_enabled = true;
 }
 
-void rtl8723ae_disable_interrupt(struct ieee80211_hw *hw)
+void rtl8723e_disable_interrupt(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-
+	rtl8723e_clear_interrupt(hw);/*clear it here first*/
 	rtl_write_dword(rtlpriv, 0x3a8, IMR8190_DISABLED);
 	rtl_write_dword(rtlpriv, 0x3ac, IMR8190_DISABLED);
 	rtlpci->irq_enabled = false;
-	synchronize_irq(rtlpci->pdev->irq);
+	/*synchronize_irq(rtlpci->pdev->irq);*/
 }
 
-static void _rtl8723ae_poweroff_adapter(struct ieee80211_hw *hw)
+static void _rtl8723e_poweroff_adapter(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 u1tmp;
+	u8 u1b_tmp;
 
 	/* Combo (PCIe + USB) Card and PCIe-MF Card */
 	/* 1. Run LPS WL RFOFF flow */
 	rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
-		PWR_INTF_PCI_MSK, Rtl8723_NIC_LPS_ENTER_FLOW);
+				 PWR_INTF_PCI_MSK, Rtl8723_NIC_LPS_ENTER_FLOW);
 
 	/* 2. 0x1F[7:0] = 0 */
 	/* turn off RF */
 	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00);
-	if ((rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) && rtlhal->fw_ready)
+	if ((rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) &&
+	    rtlhal->fw_ready) {
 		rtl8723ae_firmware_selfreset(hw);
+	}
 
 	/* Reset MCU. Suggested by Filen. */
-	u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN+1);
-	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1tmp & (~BIT(2))));
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN+1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1b_tmp & (~BIT(2))));
 
 	/* g.	MCUFWDL 0x80[1:0]=0	 */
 	/* reset MCU ready status */
@@ -1232,39 +1323,38 @@ static void _rtl8723ae_poweroff_adapter(struct ieee80211_hw *hw)
 		PWR_INTF_PCI_MSK, Rtl8723_NIC_DISABLE_FLOW);
 
 	/* Reset MCU IO Wrapper */
-	u1tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
-	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1tmp & (~BIT(0))));
-	u1tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
-	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, u1tmp | BIT(0));
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, u1b_tmp | BIT(0));
 
 	/* 7. RSV_CTRL 0x1C[7:0] = 0x0E */
 	/* lock ISO/CLK/Power control register */
 	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x0e);
 }
 
-void rtl8723ae_card_disable(struct ieee80211_hw *hw)
+void rtl8723e_card_disable(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	enum nl80211_iftype opmode;
 
 	mac->link_state = MAC80211_NOLINK;
 	opmode = NL80211_IFTYPE_UNSPECIFIED;
-	_rtl8723ae_set_media_status(hw, opmode);
-	if (rtlpci->driver_is_goingto_unload ||
+	_rtl8723e_set_media_status(hw, opmode);
+	if (rtlpriv->rtlhal.driver_is_goingto_unload ||
 	    ppsc->rfoff_reason > RF_CHANGE_BY_PS)
 		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
 	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
-	_rtl8723ae_poweroff_adapter(hw);
+	_rtl8723e_poweroff_adapter(hw);
 
 	/* after power off we should do iqk again */
 	rtlpriv->phy.iqk_initialized = false;
 }
 
-void rtl8723ae_interrupt_recognized(struct ieee80211_hw *hw,
-				    u32 *p_inta, u32 *p_intb)
+void rtl8723e_interrupt_recognized(struct ieee80211_hw *hw,
+				   u32 *p_inta, u32 *p_intb)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
@@ -1273,7 +1363,7 @@ void rtl8723ae_interrupt_recognized(struct ieee80211_hw *hw,
 	rtl_write_dword(rtlpriv, 0x3a0, *p_inta);
 }
 
-void rtl8723ae_set_beacon_related_registers(struct ieee80211_hw *hw)
+void rtl8723e_set_beacon_related_registers(struct ieee80211_hw *hw)
 {
 
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1282,17 +1372,17 @@ void rtl8723ae_set_beacon_related_registers(struct ieee80211_hw *hw)
 
 	bcn_interval = mac->beacon_interval;
 	atim_window = 2;	/*FIX MERGE */
-	rtl8723ae_disable_interrupt(hw);
+	rtl8723e_disable_interrupt(hw);
 	rtl_write_word(rtlpriv, REG_ATIMWND, atim_window);
 	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
 	rtl_write_word(rtlpriv, REG_BCNTCFG, 0x660f);
 	rtl_write_byte(rtlpriv, REG_RXTSF_OFFSET_CCK, 0x18);
 	rtl_write_byte(rtlpriv, REG_RXTSF_OFFSET_OFDM, 0x18);
 	rtl_write_byte(rtlpriv, 0x606, 0x30);
-	rtl8723ae_enable_interrupt(hw);
+	rtl8723e_enable_interrupt(hw);
 }
 
-void rtl8723ae_set_beacon_interval(struct ieee80211_hw *hw)
+void rtl8723e_set_beacon_interval(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -1300,13 +1390,13 @@ void rtl8723ae_set_beacon_interval(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_BEACON, DBG_DMESG,
 		 "beacon_interval:%d\n", bcn_interval);
-	rtl8723ae_disable_interrupt(hw);
+	rtl8723e_disable_interrupt(hw);
 	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
-	rtl8723ae_enable_interrupt(hw);
+	rtl8723e_enable_interrupt(hw);
 }
 
-void rtl8723ae_update_interrupt_mask(struct ieee80211_hw *hw,
-				     u32 add_msr, u32 rm_msr)
+void rtl8723e_update_interrupt_mask(struct ieee80211_hw *hw,
+				    u32 add_msr, u32 rm_msr)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
@@ -1318,11 +1408,11 @@ void rtl8723ae_update_interrupt_mask(struct ieee80211_hw *hw,
 		rtlpci->irq_mask[0] |= add_msr;
 	if (rm_msr)
 		rtlpci->irq_mask[0] &= (~rm_msr);
-	rtl8723ae_disable_interrupt(hw);
-	rtl8723ae_enable_interrupt(hw);
+	rtl8723e_disable_interrupt(hw);
+	rtl8723e_enable_interrupt(hw);
 }
 
-static u8 _rtl8723ae_get_chnl_group(u8 chnl)
+static u8 _rtl8723e_get_chnl_group(u8 chnl)
 {
 	u8 group;
 
@@ -1335,9 +1425,9 @@ static u8 _rtl8723ae_get_chnl_group(u8 chnl)
 	return group;
 }
 
-static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
-						   bool autoload_fail,
-						   u8 *hwinfo)
+static void _rtl8723e_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
+						  bool autoload_fail,
+						  u8 *hwinfo)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
@@ -1347,19 +1437,14 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	for (rf_path = 0; rf_path < 1; rf_path++) {
 		for (i = 0; i < 3; i++) {
 			if (!autoload_fail) {
-				rtlefuse->eeprom_chnlarea_txpwr_cck
-				    [rf_path][i] =
+				rtlefuse->eeprom_chnlarea_txpwr_cck[rf_path][i] =
 				    hwinfo[EEPROM_TXPOWERCCK + rf_path * 3 + i];
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
-				    [rf_path][i] =
-				    hwinfo[EEPROM_TXPOWERHT40_1S + rf_path *
-				    3 + i];
+				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s[rf_path][i] =
+				    hwinfo[EEPROM_TXPOWERHT40_1S + rf_path * 3 + i];
 			} else {
-				rtlefuse->eeprom_chnlarea_txpwr_cck
-				    [rf_path][i] =
+				rtlefuse->eeprom_chnlarea_txpwr_cck[rf_path][i] =
 				    EEPROM_DEFAULT_TXPOWERLEVEL;
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
-				    [rf_path][i] =
+				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s[rf_path][i] =
 				    EEPROM_DEFAULT_TXPOWERLEVEL;
 			}
 		}
@@ -1380,43 +1465,43 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
 				"RF(%d) EEPROM CCK Area(%d) = 0x%x\n", rf_path,
-				i, rtlefuse->eeprom_chnlarea_txpwr_cck
-				[rf_path][i]);
+				 i, rtlefuse->eeprom_chnlarea_txpwr_cck
+					[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
 				"RF(%d) EEPROM HT40 1S Area(%d) = 0x%x\n",
 				rf_path, i,
 				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
-				[rf_path][i]);
+					[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++)
 		for (i = 0; i < 3; i++)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
-				rf_path, i,
-				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
-				[rf_path][i]);
+				 rf_path, i,
+				 rtlefuse->eprom_chnl_txpwr_ht40_2sdf
+					[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = _rtl8723ae_get_chnl_group((u8) i);
+			index = _rtl8723e_get_chnl_group((u8)i);
 
 			rtlefuse->txpwrlevel_cck[rf_path][i] =
 				rtlefuse->eeprom_chnlarea_txpwr_cck
-							[rf_path][index];
+					[rf_path][index];
 			rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
 				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
-							[rf_path][index];
+					[rf_path][index];
 
 			if ((rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
-			    [rf_path][index] -
-			    rtlefuse->eprom_chnl_txpwr_ht40_2sdf[rf_path]
-			    [index]) > 0) {
-				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
-					rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
 					[rf_path][index] -
-					rtlefuse->eprom_chnl_txpwr_ht40_2sdf
-					[rf_path][index];
+			     rtlefuse->eprom_chnl_txpwr_ht40_2sdf
+					[rf_path][index]) > 0) {
+				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
+				  rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
+				  [rf_path][index] -
+				  rtlefuse->eprom_chnl_txpwr_ht40_2sdf
+				  [rf_path][index];
 			} else {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;
 			}
@@ -1424,8 +1509,8 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 		for (i = 0; i < 14; i++) {
 			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
-				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = "
-				"[0x%x / 0x%x / 0x%x]\n", rf_path, i,
+				"RF(%d)-Ch(%d) [CCK / HT40_1S / HT40_2S] = [0x%x / 0x%x / 0x%x]\n",
+				rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
 				rtlefuse->txpwrlevel_ht40_1s[rf_path][i],
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i]);
@@ -1446,22 +1531,20 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
-			index = _rtl8723ae_get_chnl_group((u8) i);
+			index = _rtl8723e_get_chnl_group((u8)i);
 
 			if (rf_path == RF90_PATH_A) {
 				rtlefuse->pwrgroup_ht20[rf_path][i] =
-				    (rtlefuse->eeprom_pwrlimit_ht20[index] &
-				    0xf);
+				  (rtlefuse->eeprom_pwrlimit_ht20[index] & 0xf);
 				rtlefuse->pwrgroup_ht40[rf_path][i] =
-				    (rtlefuse->eeprom_pwrlimit_ht40[index] &
-				    0xf);
+				  (rtlefuse->eeprom_pwrlimit_ht40[index] & 0xf);
 			} else if (rf_path == RF90_PATH_B) {
 				rtlefuse->pwrgroup_ht20[rf_path][i] =
-				    ((rtlefuse->eeprom_pwrlimit_ht20[index] &
-				    0xf0) >> 4);
+				  ((rtlefuse->eeprom_pwrlimit_ht20[index] &
+				   0xf0) >> 4);
 				rtlefuse->pwrgroup_ht40[rf_path][i] =
-				    ((rtlefuse->eeprom_pwrlimit_ht40[index] &
-				    0xf0) >> 4);
+				  ((rtlefuse->eeprom_pwrlimit_ht40[index] &
+				   0xf0) >> 4);
 			}
 
 			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
@@ -1474,7 +1557,7 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	}
 
 	for (i = 0; i < 14; i++) {
-		index = _rtl8723ae_get_chnl_group((u8) i);
+		index = _rtl8723e_get_chnl_group((u8)i);
 
 		if (!autoload_fail)
 			tempval = hwinfo[EEPROM_TXPOWERHT20DIFF + index];
@@ -1491,7 +1574,7 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		if (rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] & BIT(3))
 			rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] |= 0xF0;
 
-		index = _rtl8723ae_get_chnl_group((u8) i);
+		index = _rtl8723e_get_chnl_group((u8)i);
 
 		if (!autoload_fail)
 			tempval = hwinfo[EEPROM_TXPOWER_OFDMDIFF + index];
@@ -1509,19 +1592,19 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
+			 rtlefuse->txpwr_ht20diff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-A Legacy to Ht40 Diff[%d] = 0x%x\n", i,
-			rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
+			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Ht20 to HT40 Diff[%d] = 0x%x\n", i,
-			rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
+			 rtlefuse->txpwr_ht20diff[RF90_PATH_B][i]);
 	for (i = 0; i < 14; i++)
 		RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 			"RF-B Legacy to HT40 Diff[%d] = 0x%x\n", i,
-			rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
+			 rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i]);
 
 	if (!autoload_fail)
 		rtlefuse->eeprom_regulatory = (hwinfo[RF_OPTION1] & 0x7);
@@ -1534,10 +1617,11 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = hwinfo[EEPROM_TSSI_A];
 	else
 		rtlefuse->eeprom_tssi[RF90_PATH_A] = EEPROM_DEFAULT_TSSI;
+
 	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"TSSI_A = 0x%x, TSSI_B = 0x%x\n",
-		rtlefuse->eeprom_tssi[RF90_PATH_A],
-		rtlefuse->eeprom_tssi[RF90_PATH_B]);
+		 rtlefuse->eeprom_tssi[RF90_PATH_A],
+		 rtlefuse->eeprom_tssi[RF90_PATH_B]);
 
 	if (!autoload_fail)
 		tempval = hwinfo[EEPROM_THERMAL_METER];
@@ -1553,8 +1637,8 @@ static void _rtl8723ae_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 }
 
-static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
-					 bool pseudo_test)
+static void _rtl8723e_read_adapter_info(struct ieee80211_hw *hw,
+					bool b_pseudo_test)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
@@ -1563,7 +1647,7 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 	u8 hwinfo[HWSET_MAX_SIZE];
 	u16 eeprom_id;
 
-	if (pseudo_test) {
+	if (b_pseudo_test) {
 		/* need add */
 		return;
 	}
@@ -1577,7 +1661,7 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 			 "RTL819X Not boot from eeprom, check it !!");
 	}
 
-	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, ("MAP\n"),
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
 		      hwinfo, HWSET_MAX_SIZE);
 
 	eeprom_id = *((u16 *)&hwinfo[0]);
@@ -1590,13 +1674,13 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 		rtlefuse->autoload_failflag = false;
 	}
 
-	if (rtlefuse->autoload_failflag == true)
+	if (rtlefuse->autoload_failflag)
 		return;
 
-	rtlefuse->eeprom_vid = *(u16 *) &hwinfo[EEPROM_VID];
-	rtlefuse->eeprom_did = *(u16 *) &hwinfo[EEPROM_DID];
-	rtlefuse->eeprom_svid = *(u16 *) &hwinfo[EEPROM_SVID];
-	rtlefuse->eeprom_smid = *(u16 *) &hwinfo[EEPROM_SMID];
+	rtlefuse->eeprom_vid = *(u16 *)&hwinfo[EEPROM_VID];
+	rtlefuse->eeprom_did = *(u16 *)&hwinfo[EEPROM_DID];
+	rtlefuse->eeprom_svid = *(u16 *)&hwinfo[EEPROM_SVID];
+	rtlefuse->eeprom_smid = *(u16 *)&hwinfo[EEPROM_SMID];
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROMId = 0x%4x\n", eeprom_id);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
@@ -1610,16 +1694,16 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 
 	for (i = 0; i < 6; i += 2) {
 		usvalue = *(u16 *)&hwinfo[EEPROM_MAC_ADDR + i];
-		*((u16 *) (&rtlefuse->dev_addr[i])) = usvalue;
+		*((u16 *)(&rtlefuse->dev_addr[i])) = usvalue;
 	}
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		 "dev_addr: %pM\n", rtlefuse->dev_addr);
 
-	_rtl8723ae_read_txpower_info_from_hwpg(hw,
-			rtlefuse->autoload_failflag, hwinfo);
+	_rtl8723e_read_txpower_info_from_hwpg(hw, rtlefuse->autoload_failflag,
+					      hwinfo);
 
-	rtl8723ae_read_bt_coexist_info_from_hwpg(hw,
+	rtl8723e_read_bt_coexist_info_from_hwpg(hw,
 			rtlefuse->autoload_failflag, hwinfo);
 
 	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
@@ -1645,6 +1729,14 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 				    CHK_SVID_SMID(0x10EC, 0x6178) ||
 				    CHK_SVID_SMID(0x10EC, 0x6179) ||
 				    CHK_SVID_SMID(0x10EC, 0x6180) ||
+				    CHK_SVID_SMID(0x10EC, 0x7151) ||
+				    CHK_SVID_SMID(0x10EC, 0x7152) ||
+				    CHK_SVID_SMID(0x10EC, 0x7154) ||
+				    CHK_SVID_SMID(0x10EC, 0x7155) ||
+				    CHK_SVID_SMID(0x10EC, 0x7177) ||
+				    CHK_SVID_SMID(0x10EC, 0x7178) ||
+				    CHK_SVID_SMID(0x10EC, 0x7179) ||
+				    CHK_SVID_SMID(0x10EC, 0x7180) ||
 				    CHK_SVID_SMID(0x10EC, 0x8151) ||
 				    CHK_SVID_SMID(0x10EC, 0x8152) ||
 				    CHK_SVID_SMID(0x10EC, 0x8154) ||
@@ -1672,7 +1764,10 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 					 CHK_SVID_SMID(0x10EC, 0x7193) ||
 					 CHK_SVID_SMID(0x10EC, 0x8191) ||
 					 CHK_SVID_SMID(0x10EC, 0x8192) ||
-					 CHK_SVID_SMID(0x10EC, 0x8193))
+					 CHK_SVID_SMID(0x10EC, 0x8193) ||
+					 CHK_SVID_SMID(0x10EC, 0x9191) ||
+					 CHK_SVID_SMID(0x10EC, 0x9192) ||
+					 CHK_SVID_SMID(0x10EC, 0x9193))
 					rtlhal->oem_id = RT_CID_819X_SAMSUNG;
 				else if (CHK_SVID_SMID(0x10EC, 0x8195) ||
 					 CHK_SVID_SMID(0x10EC, 0x9195) ||
@@ -1729,7 +1824,7 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 				else
 					rtlhal->oem_id = RT_CID_DEFAULT;
 			} else {
-					rtlhal->oem_id = RT_CID_DEFAULT;
+				rtlhal->oem_id = RT_CID_DEFAULT;
 			}
 			break;
 		case EEPROM_CID_TOSHIBA:
@@ -1751,18 +1846,31 @@ static void _rtl8723ae_read_adapter_info(struct ieee80211_hw *hw,
 	}
 }
 
-static void _rtl8723ae_hal_customized_behavior(struct ieee80211_hw *hw)
+static void _rtl8723e_hal_customized_behavior(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	pcipriv->ledctl.led_opendrain = true;
+	switch (rtlhal->oem_id) {
+	case RT_CID_819X_HP:
+		pcipriv->ledctl.led_opendrain = true;
+		break;
+	case RT_CID_819X_LENOVO:
+	case RT_CID_DEFAULT:
+	case RT_CID_TOSHIBA:
+	case RT_CID_CCX:
+	case RT_CID_819X_ACER:
+	case RT_CID_WHQL:
+	default:
+		break;
+	}
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		 "RT Customized ID: 0x%02X\n", rtlhal->oem_id);
 }
 
-void rtl8723ae_read_eeprom_info(struct ieee80211_hw *hw)
+void rtl8723e_read_eeprom_info(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
@@ -1775,7 +1883,7 @@ void rtl8723ae_read_eeprom_info(struct ieee80211_hw *hw)
 	value32 = (value32 & ~EFUSE_SEL_MASK) | EFUSE_SEL(EFUSE_WIFI_SEL_0);
 	rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[EFUSE_TEST], value32);
 
-	rtlhal->version = _rtl8723ae_read_chip_version(hw);
+	rtlhal->version = _rtl8723e_read_chip_version(hw);
 
 	if (get_rf_type(rtlphy) == RF_1T1R)
 		rtlpriv->dm.rfpath_rxenable[0] = true;
@@ -1783,7 +1891,7 @@ void rtl8723ae_read_eeprom_info(struct ieee80211_hw *hw)
 		rtlpriv->dm.rfpath_rxenable[0] =
 		    rtlpriv->dm.rfpath_rxenable[1] = true;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "VersionID = 0x%4x\n",
-		 rtlhal->version);
+						rtlhal->version);
 
 	tmp_u1b = rtl_read_byte(rtlpriv, REG_9346CR);
 	if (tmp_u1b & BIT(4)) {
@@ -1796,33 +1904,34 @@ void rtl8723ae_read_eeprom_info(struct ieee80211_hw *hw)
 	if (tmp_u1b & BIT(5)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
-		_rtl8723ae_read_adapter_info(hw, false);
+		_rtl8723e_read_adapter_info(hw, false);
 	} else {
 		rtlefuse->autoload_failflag = true;
-		_rtl8723ae_read_adapter_info(hw, false);
+		_rtl8723e_read_adapter_info(hw, false);
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Autoload ERR!!\n");
 	}
-	_rtl8723ae_hal_customized_behavior(hw);
+	_rtl8723e_hal_customized_behavior(hw);
 }
 
-static void rtl8723ae_update_hal_rate_table(struct ieee80211_hw *hw,
-					    struct ieee80211_sta *sta)
+static void rtl8723e_update_hal_rate_table(struct ieee80211_hw *hw,
+					   struct ieee80211_sta *sta)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u32 ratr_value;
 	u8 ratr_index = 0;
-	u8 nmode = mac->ht_enable;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
+	u8 b_nmode = mac->ht_enable;
+	u16 shortgi_rate;
+	u32 tmp_ratr_value;
 	u8 curtxbw_40mhz = mac->bw_40;
 	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
 				1 : 0;
 	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
 				1 : 0;
 	enum wireless_mode wirelessmode = mac->mode;
+	u32 ratr_mask;
 
 	if (rtlhal->current_bandtype == BAND_ON_5G)
 		ratr_value = sta->supp_rates[1] << 4;
@@ -1831,7 +1940,7 @@ static void rtl8723ae_update_hal_rate_table(struct ieee80211_hw *hw,
 	if (mac->opmode == NL80211_IFTYPE_ADHOC)
 		ratr_value = 0xfff;
 	ratr_value |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
-		       sta->ht_cap.mcs.rx_mask[0] << 12);
+			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
 	case WIRELESS_MODE_B:
 		if (ratr_value & 0x0000000c)
@@ -1844,20 +1953,14 @@ static void rtl8723ae_update_hal_rate_table(struct ieee80211_hw *hw,
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
@@ -1868,19 +1971,30 @@ static void rtl8723ae_update_hal_rate_table(struct ieee80211_hw *hw,
 		break;
 	}
 
-	if ((pcipriv->bt_coexist.bt_coexistence) &&
-	    (pcipriv->bt_coexist.bt_coexist_type == BT_CSR_BC4) &&
-	    (pcipriv->bt_coexist.bt_cur_state) &&
-	    (pcipriv->bt_coexist.bt_ant_isolation) &&
-	    ((pcipriv->bt_coexist.bt_service == BT_SCO) ||
-	    (pcipriv->bt_coexist.bt_service == BT_BUSY)))
+	if ((rtlpriv->btcoexist.bt_coexistence) &&
+	    (rtlpriv->btcoexist.bt_coexist_type == BT_CSR_BC4) &&
+	    (rtlpriv->btcoexist.bt_cur_state) &&
+	    (rtlpriv->btcoexist.bt_ant_isolation) &&
+	    ((rtlpriv->btcoexist.bt_service == BT_SCO) ||
+	    (rtlpriv->btcoexist.bt_service == BT_BUSY)))
 		ratr_value &= 0x0fffcfc0;
 	else
 		ratr_value &= 0x0FFFFFFF;
 
-	if (nmode && ((curtxbw_40mhz && curshortgi_40mhz) ||
-	   (!curtxbw_40mhz && curshortgi_20mhz)))
+	if (b_nmode &&
+	    ((curtxbw_40mhz && curshortgi_40mhz) ||
+	     (!curtxbw_40mhz && curshortgi_20mhz))) {
 		ratr_value |= 0x10000000;
+		tmp_ratr_value = (ratr_value >> 12);
+
+		for (shortgi_rate = 15; shortgi_rate > 0; shortgi_rate--) {
+			if ((1 << shortgi_rate) & tmp_ratr_value)
+				break;
+		}
+
+		shortgi_rate = (shortgi_rate << 12) | (shortgi_rate << 8) |
+		    (shortgi_rate << 4) | (shortgi_rate);
+	}
 
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
 
@@ -1888,8 +2002,9 @@ static void rtl8723ae_update_hal_rate_table(struct ieee80211_hw *hw,
 		 "%x\n", rtl_read_dword(rtlpriv, REG_ARFR0));
 }
 
-static void rtl8723ae_update_hal_rate_mask(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u8 rssi_level)
+static void rtl8723e_update_hal_rate_mask(struct ieee80211_hw *hw,
+					  struct ieee80211_sta *sta,
+					  u8 rssi_level)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
@@ -1898,7 +2013,8 @@ static void rtl8723ae_update_hal_rate_mask(struct ieee80211_hw *hw,
 	struct rtl_sta_info *sta_entry = NULL;
 	u32 ratr_bitmap;
 	u8 ratr_index;
-	u8 curtxbw_40mhz = (sta->bandwidth >= IEEE80211_STA_RX_BW_40) ? 1 : 0;
+	u8 curtxbw_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40)
+				? 1 : 0;
 	u8 curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
 				1 : 0;
 	u8 curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
@@ -1907,9 +2023,9 @@ static void rtl8723ae_update_hal_rate_mask(struct ieee80211_hw *hw,
 	bool shortgi = false;
 	u8 rate_mask[5];
 	u8 macid = 0;
-	u8 mimo_ps = IEEE80211_SMPS_OFF;
+	/*u8 mimo_ps = IEEE80211_SMPS_OFF;*/
 
-	sta_entry = (struct rtl_sta_info *) sta->drv_priv;
+	sta_entry = (struct rtl_sta_info *)sta->drv_priv;
 	wirelessmode = sta_entry->wireless_mode;
 	if (mac->opmode == NL80211_IFTYPE_STATION)
 		curtxbw_40mhz = mac->bw_40;
@@ -1944,54 +2060,44 @@ static void rtl8723ae_update_hal_rate_mask(struct ieee80211_hw *hw,
 			ratr_bitmap &= 0x00000ff5;
 		break;
 	case WIRELESS_MODE_A:
-		ratr_index = RATR_INX_WIRELESS_A;
+		ratr_index = RATR_INX_WIRELESS_G;
 		ratr_bitmap &= 0x00000ff0;
 		break;
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		ratr_index = RATR_INX_WIRELESS_NGB;
-
-		if (mimo_ps == IEEE80211_SMPS_STATIC) {
-			if (rssi_level == 1)
-				ratr_bitmap &= 0x00070000;
-			else if (rssi_level == 2)
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
+					ratr_bitmap &= 0x0f0f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x0f0ff000;
+				else
+					ratr_bitmap &= 0x0f0ff015;
 			} else {
-				if (curtxbw_40mhz) {
-					if (rssi_level == 1)
-						ratr_bitmap &= 0x0f0f0000;
-					else if (rssi_level == 2)
-						ratr_bitmap &= 0x0f0ff000;
-					else
-						ratr_bitmap &= 0x0f0ff015;
-				} else {
-					if (rssi_level == 1)
-						ratr_bitmap &= 0x0f0f0000;
-					else if (rssi_level == 2)
-						ratr_bitmap &= 0x0f0ff000;
-					else
-						ratr_bitmap &= 0x0f0ff005;
-				}
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x0f0f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x0f0ff000;
+				else
+					ratr_bitmap &= 0x0f0ff005;
 			}
 		}
 
@@ -2016,30 +2122,30 @@ static void rtl8723ae_update_hal_rate_mask(struct ieee80211_hw *hw,
 
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "ratr_bitmap :%x\n", ratr_bitmap);
-	/* convert ratr_bitmap to le byte array */
-	rate_mask[0] = ratr_bitmap;
-	rate_mask[1] = (ratr_bitmap >>= 8);
-	rate_mask[2] = (ratr_bitmap >>= 8);
-	rate_mask[3] = ((ratr_bitmap >> 8) & 0x0f) | (ratr_index << 4);
+	*(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
+			     (ratr_index << 28);
 	rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 "Rate_index:%x, ratr_bitmap: %*phC\n",
-		 ratr_index, 5, rate_mask);
-	rtl8723ae_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
+		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
+		  ratr_index, ratr_bitmap,
+		  rate_mask[0], rate_mask[1],
+		  rate_mask[2], rate_mask[3],
+		  rate_mask[4]);
+	rtl8723e_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
 }
 
-void rtl8723ae_update_hal_rate_tbl(struct ieee80211_hw *hw,
-		struct ieee80211_sta *sta, u8 rssi_level)
+void rtl8723e_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				  struct ieee80211_sta *sta, u8 rssi_level)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	if (rtlpriv->dm.useramask)
-		rtl8723ae_update_hal_rate_mask(hw, sta, rssi_level);
+		rtl8723e_update_hal_rate_mask(hw, sta, rssi_level);
 	else
-		rtl8723ae_update_hal_rate_table(hw, sta);
+		rtl8723e_update_hal_rate_table(hw, sta);
 }
 
-void rtl8723ae_update_channel_access_setting(struct ieee80211_hw *hw)
+void rtl8723e_update_channel_access_setting(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -2053,14 +2159,14 @@ void rtl8723ae_update_channel_access_setting(struct ieee80211_hw *hw)
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SIFS, (u8 *)&sifs_timer);
 }
 
-bool rtl8723ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
+bool rtl8723e_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	enum rf_pwrstate e_rfpowerstate_toset;
+	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
 	u8 u1tmp;
-	bool actuallyset = false;
+	bool b_actuallyset = false;
 
 	if (rtlpriv->rtlhal.being_init_adapter)
 		return false;
@@ -2077,6 +2183,8 @@ bool rtl8723ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
 	}
 
+	cur_rfstate = ppsc->rfpwr_state;
+
 	rtl_write_byte(rtlpriv, REG_GPIO_IO_SEL_2,
 		       rtl_read_byte(rtlpriv, REG_GPIO_IO_SEL_2)&~(BIT(1)));
 
@@ -2087,24 +2195,23 @@ bool rtl8723ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	else
 		e_rfpowerstate_toset = (u1tmp & BIT(1)) ? ERFON : ERFOFF;
 
-	if ((ppsc->hwradiooff == true) && (e_rfpowerstate_toset == ERFON)) {
+	if (ppsc->hwradiooff && (e_rfpowerstate_toset == ERFON)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
 
 		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
-		actuallyset = true;
-	} else if ((ppsc->hwradiooff == false)
-		   && (e_rfpowerstate_toset == ERFOFF)) {
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
+	if (b_actuallyset) {
 		spin_lock(&rtlpriv->locks.rf_ps_lock);
 		ppsc->rfchange_inprogress = false;
 		spin_unlock(&rtlpriv->locks.rf_ps_lock);
@@ -2119,11 +2226,12 @@ bool rtl8723ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 
 	*valid = 1;
 	return !ppsc->hwradiooff;
+
 }
 
-void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
-		       u8 *p_macaddr, bool is_group, u8 enc_algo,
-		       bool is_wepkey, bool clear_all)
+void rtl8723e_set_key(struct ieee80211_hw *hw, u32 key_index,
+		      u8 *p_macaddr, bool is_group, u8 enc_algo,
+		      bool is_wepkey, bool clear_all)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
@@ -2131,6 +2239,7 @@ void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 	u8 *macaddr = p_macaddr;
 	u32 entry_id = 0;
 	bool is_pairwise = false;
+
 	static u8 cam_const_addr[4][6] = {
 		{0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
 		{0x00, 0x00, 0x00, 0x00, 0x00, 0x01},
@@ -2158,6 +2267,7 @@ void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 				rtlpriv->sec.key_len[idx] = 0;
 			}
 		}
+
 	} else {
 		switch (enc_algo) {
 		case WEP40_ENCRYPTION:
@@ -2173,8 +2283,8 @@ void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 			enc_algo = CAM_AES;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 "switch case not processed\n");
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
 			enc_algo = CAM_TKIP;
 			break;
 		}
@@ -2188,8 +2298,8 @@ void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 				entry_id = key_index;
 			} else {
 				if (mac->opmode == NL80211_IFTYPE_AP) {
-					entry_id = rtl_cam_get_free_entry(hw,
-								macaddr);
+					entry_id =
+					  rtl_cam_get_free_entry(hw, p_macaddr);
 					if (entry_id >=  TOTAL_CAM_ENTRY) {
 						RT_TRACE(rtlpriv, COMP_SEC,
 							 DBG_EMERG,
@@ -2220,22 +2330,22 @@ void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 					 "set Pairwiase key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
-					entry_id, enc_algo,
-					CAM_CONFIG_NO_USEDK,
-					rtlpriv->sec.key_buf[key_index]);
+						      entry_id, enc_algo,
+						      CAM_CONFIG_NO_USEDK,
+						      rtlpriv->sec.key_buf[key_index]);
 			} else {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 					 "set group key\n");
 
 				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 					rtl_cam_add_one_entry(hw,
-						rtlefuse->dev_addr,
-						PAIRWISE_KEYIDX,
-						CAM_PAIRWISE_KEY_POSITION,
-						enc_algo,
-						CAM_CONFIG_NO_USEDK,
-						rtlpriv->sec.key_buf
-						[entry_id]);
+							rtlefuse->dev_addr,
+							PAIRWISE_KEYIDX,
+							CAM_PAIRWISE_KEY_POSITION,
+							enc_algo,
+							CAM_CONFIG_NO_USEDK,
+							rtlpriv->sec.key_buf
+							[entry_id]);
 				}
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
@@ -2248,45 +2358,43 @@ void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
 	}
 }
 
-static void rtl8723ae_bt_var_init(struct ieee80211_hw *hw)
+static void rtl8723e_bt_var_init(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	pcipriv->bt_coexist.bt_coexistence =
-					pcipriv->bt_coexist.eeprom_bt_coexist;
-	pcipriv->bt_coexist.bt_ant_num =
-					pcipriv->bt_coexist.eeprom_bt_ant_num;
-	pcipriv->bt_coexist.bt_coexist_type =
-					pcipriv->bt_coexist.eeprom_bt_type;
+	rtlpriv->btcoexist.bt_coexistence =
+		rtlpriv->btcoexist.eeprom_bt_coexist;
+	rtlpriv->btcoexist.bt_ant_num =
+		rtlpriv->btcoexist.eeprom_bt_ant_num;
+	rtlpriv->btcoexist.bt_coexist_type =
+		rtlpriv->btcoexist.eeprom_bt_type;
 
-		pcipriv->bt_coexist.bt_ant_isolation =
-				pcipriv->bt_coexist.eeprom_bt_ant_isol;
+	rtlpriv->btcoexist.bt_ant_isolation =
+		rtlpriv->btcoexist.eeprom_bt_ant_isol;
 
-	pcipriv->bt_coexist.bt_radio_shared_type =
-				pcipriv->bt_coexist.eeprom_bt_radio_shared;
+	rtlpriv->btcoexist.bt_radio_shared_type =
+		rtlpriv->btcoexist.eeprom_bt_radio_shared;
 
 	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 		 "BT Coexistance = 0x%x\n",
-		 pcipriv->bt_coexist.bt_coexistence);
+		 rtlpriv->btcoexist.bt_coexistence);
 
-	if (pcipriv->bt_coexist.bt_coexistence) {
-		pcipriv->bt_coexist.bt_busy_traffic = false;
-		pcipriv->bt_coexist.bt_traffic_mode_set = false;
-		pcipriv->bt_coexist.bt_non_traffic_mode_set = false;
+	if (rtlpriv->btcoexist.bt_coexistence) {
+		rtlpriv->btcoexist.bt_busy_traffic = false;
+		rtlpriv->btcoexist.bt_traffic_mode_set = false;
+		rtlpriv->btcoexist.bt_non_traffic_mode_set = false;
 
-		pcipriv->bt_coexist.cstate = 0;
-		pcipriv->bt_coexist.previous_state = 0;
+		rtlpriv->btcoexist.cstate = 0;
+		rtlpriv->btcoexist.previous_state = 0;
 
-		if (pcipriv->bt_coexist.bt_ant_num == ANT_X2) {
+		if (rtlpriv->btcoexist.bt_ant_num == ANT_X2) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "BlueTooth BT_Ant_Num = Antx2\n");
-		} else if (pcipriv->bt_coexist.bt_ant_num == ANT_X1) {
+		} else if (rtlpriv->btcoexist.bt_ant_num == ANT_X1) {
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "BlueTooth BT_Ant_Num = Antx1\n");
 		}
-
-		switch (pcipriv->bt_coexist.bt_coexist_type) {
+		switch (rtlpriv->btcoexist.bt_coexist_type) {
 		case BT_2WIRE:
 			RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 				 "BlueTooth BT_CoexistType = BT_2Wire\n");
@@ -2318,20 +2426,19 @@ static void rtl8723ae_bt_var_init(struct ieee80211_hw *hw)
 		}
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "BlueTooth BT_Ant_isolation = %d\n",
-			 pcipriv->bt_coexist.bt_ant_isolation);
+			 rtlpriv->btcoexist.bt_ant_isolation);
 		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_TRACE,
 			 "BT_RadioSharedType = 0x%x\n",
-			 pcipriv->bt_coexist.bt_radio_shared_type);
-		pcipriv->bt_coexist.bt_active_zero_cnt = 0;
-		pcipriv->bt_coexist.cur_bt_disabled = false;
-		pcipriv->bt_coexist.pre_bt_disabled = false;
+			 rtlpriv->btcoexist.bt_radio_shared_type);
+		rtlpriv->btcoexist.bt_active_zero_cnt = 0;
+		rtlpriv->btcoexist.cur_bt_disabled = false;
+		rtlpriv->btcoexist.pre_bt_disabled = false;
 	}
 }
 
-void rtl8723ae_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
-					      bool auto_load_fail, u8 *hwinfo)
+void rtl8723e_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
+					     bool auto_load_fail, u8 *hwinfo)
 {
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 value;
 	u32 tmpu_32;
@@ -2339,47 +2446,50 @@ void rtl8723ae_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
 	if (!auto_load_fail) {
 		tmpu_32 = rtl_read_dword(rtlpriv, REG_MULTI_FUNC_CTRL);
 		if (tmpu_32 & BIT(18))
-			pcipriv->bt_coexist.eeprom_bt_coexist = 1;
+			rtlpriv->btcoexist.eeprom_bt_coexist = 1;
 		else
-			pcipriv->bt_coexist.eeprom_bt_coexist = 0;
+			rtlpriv->btcoexist.eeprom_bt_coexist = 0;
 		value = hwinfo[RF_OPTION4];
-		pcipriv->bt_coexist.eeprom_bt_type = BT_RTL8723A;
-		pcipriv->bt_coexist.eeprom_bt_ant_num = (value & 0x1);
-		pcipriv->bt_coexist.eeprom_bt_ant_isol = ((value & 0x10) >> 4);
-		pcipriv->bt_coexist.eeprom_bt_radio_shared =
-				((value & 0x20) >> 5);
+		rtlpriv->btcoexist.eeprom_bt_type = BT_RTL8723A;
+		rtlpriv->btcoexist.eeprom_bt_ant_num = (value & 0x1);
+		rtlpriv->btcoexist.eeprom_bt_ant_isol = ((value & 0x10) >> 4);
+		rtlpriv->btcoexist.eeprom_bt_radio_shared =
+		  ((value & 0x20) >> 5);
 	} else {
-		pcipriv->bt_coexist.eeprom_bt_coexist = 0;
-		pcipriv->bt_coexist.eeprom_bt_type = BT_RTL8723A;
-		pcipriv->bt_coexist.eeprom_bt_ant_num = ANT_X2;
-		pcipriv->bt_coexist.eeprom_bt_ant_isol = 0;
-		pcipriv->bt_coexist.eeprom_bt_radio_shared = BT_RADIO_SHARED;
+		rtlpriv->btcoexist.eeprom_bt_coexist = 0;
+		rtlpriv->btcoexist.eeprom_bt_type = BT_RTL8723A;
+		rtlpriv->btcoexist.eeprom_bt_ant_num = ANT_X2;
+		rtlpriv->btcoexist.eeprom_bt_ant_isol = 0;
+		rtlpriv->btcoexist.eeprom_bt_radio_shared = BT_RADIO_SHARED;
 	}
 
-	rtl8723ae_bt_var_init(hw);
+	rtl8723e_bt_var_init(hw);
 }
 
-void rtl8723ae_bt_reg_init(struct ieee80211_hw *hw)
+void rtl8723e_bt_reg_init(struct ieee80211_hw *hw)
 {
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	/* 0:Low, 1:High, 2:From Efuse. */
-	pcipriv->bt_coexist.reg_bt_iso = 2;
+	rtlpriv->btcoexist.reg_bt_iso = 2;
 	/* 0:Idle, 1:None-SCO, 2:SCO, 3:From Counter. */
-	pcipriv->bt_coexist.reg_bt_sco = 3;
+	rtlpriv->btcoexist.reg_bt_sco = 3;
 	/* 0:Disable BT control A-MPDU, 1:Enable BT control A-MPDU. */
-	pcipriv->bt_coexist.reg_bt_sco = 0;
+	rtlpriv->btcoexist.reg_bt_sco = 0;
 }
 
-
-void rtl8723ae_bt_hw_init(struct ieee80211_hw *hw)
+void rtl8723e_bt_hw_init(struct ieee80211_hw *hw)
 {
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
 }
 
-void rtl8723ae_suspend(struct ieee80211_hw *hw)
+void rtl8723e_suspend(struct ieee80211_hw *hw)
 {
 }
 
-void rtl8723ae_resume(struct ieee80211_hw *hw)
+void rtl8723e_resume(struct ieee80211_hw *hw)
 {
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.h b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.h
index d3bc39f..32c1ace 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/hw.h
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
@@ -34,38 +30,38 @@
 	((rtlefuse->eeprom_svid == (_val1)) &&			\
 	 (rtlefuse->eeprom_smid == (_val2)))
 
-void rtl8723ae_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
-void rtl8723ae_read_eeprom_info(struct ieee80211_hw *hw);
+void rtl8723e_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
+void rtl8723e_read_eeprom_info(struct ieee80211_hw *hw);
 
-void rtl8723ae_interrupt_recognized(struct ieee80211_hw *hw,
-				    u32 *p_inta, u32 *p_intb);
-int rtl8723ae_hw_init(struct ieee80211_hw *hw);
-void rtl8723ae_card_disable(struct ieee80211_hw *hw);
-void rtl8723ae_enable_interrupt(struct ieee80211_hw *hw);
-void rtl8723ae_disable_interrupt(struct ieee80211_hw *hw);
-int rtl8723ae_set_network_type(struct ieee80211_hw *hw,
-			       enum nl80211_iftype type);
-void rtl8723ae_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid);
-void rtl8723ae_set_qos(struct ieee80211_hw *hw, int aci);
-void rtl8723ae_set_beacon_related_registers(struct ieee80211_hw *hw);
-void rtl8723ae_set_beacon_interval(struct ieee80211_hw *hw);
-void rtl8723ae_update_interrupt_mask(struct ieee80211_hw *hw,
-				     u32 add_msr, u32 rm_msr);
-void rtl8723ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
-void rtl8723ae_update_hal_rate_tbl(struct ieee80211_hw *hw,
-				   struct ieee80211_sta *sta, u8 rssi_level);
-void rtl8723ae_update_channel_access_setting(struct ieee80211_hw *hw);
-bool rtl8723ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid);
-void rtl8723ae_enable_hw_security_config(struct ieee80211_hw *hw);
-void rtl8723ae_set_key(struct ieee80211_hw *hw, u32 key_index,
-		       u8 *p_macaddr, bool is_group, u8 enc_algo,
-		       bool is_wepkey, bool clear_all);
+void rtl8723e_interrupt_recognized(struct ieee80211_hw *hw,
+				   u32 *p_inta, u32 *p_intb);
+int rtl8723e_hw_init(struct ieee80211_hw *hw);
+void rtl8723e_card_disable(struct ieee80211_hw *hw);
+void rtl8723e_enable_interrupt(struct ieee80211_hw *hw);
+void rtl8723e_disable_interrupt(struct ieee80211_hw *hw);
+int rtl8723e_set_network_type(struct ieee80211_hw *hw,
+			      enum nl80211_iftype type);
+void rtl8723e_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid);
+void rtl8723e_set_qos(struct ieee80211_hw *hw, int aci);
+void rtl8723e_set_beacon_related_registers(struct ieee80211_hw *hw);
+void rtl8723e_set_beacon_interval(struct ieee80211_hw *hw);
+void rtl8723e_update_interrupt_mask(struct ieee80211_hw *hw,
+				    u32 add_msr, u32 rm_msr);
+void rtl8723e_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
+void rtl8723e_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				  struct ieee80211_sta *sta, u8 rssi_level);
+void rtl8723e_update_channel_access_setting(struct ieee80211_hw *hw);
+bool rtl8723e_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid);
+void rtl8723e_enable_hw_security_config(struct ieee80211_hw *hw);
+void rtl8723e_set_key(struct ieee80211_hw *hw, u32 key_index,
+		      u8 *p_macaddr, bool is_group, u8 enc_algo,
+		      bool is_wepkey, bool clear_all);
 
-void rtl8723ae_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
-					      bool autoload_fail, u8 *hwinfo);
-void rtl8723ae_bt_reg_init(struct ieee80211_hw *hw);
-void rtl8723ae_bt_hw_init(struct ieee80211_hw *hw);
-void rtl8723ae_suspend(struct ieee80211_hw *hw);
-void rtl8723ae_resume(struct ieee80211_hw *hw);
+void rtl8723e_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
+					     bool autoload_fail, u8 *hwinfo);
+void rtl8723e_bt_reg_init(struct ieee80211_hw *hw);
+void rtl8723e_bt_hw_init(struct ieee80211_hw *hw);
+void rtl8723e_suspend(struct ieee80211_hw *hw);
+void rtl8723e_resume(struct ieee80211_hw *hw);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/led.c b/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
index 061526f..1317335 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/led.c
@@ -32,44 +32,44 @@
 #include "reg.h"
 #include "led.h"
 
-static void _rtl8723ae_init_led(struct ieee80211_hw *hw,
-				struct rtl_led *pled, enum rtl_led_pin ledpin)
+static void _rtl8723e_init_led(struct ieee80211_hw *hw,
+			       struct rtl_led *pled, enum rtl_led_pin ledpin)
 {
 	pled->hw = hw;
 	pled->ledpin = ledpin;
 	pled->ledon = false;
 }
 
-void rtl8723ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
+void rtl8723e_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 ledcfg;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
 		 "LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin);
 
-	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
-
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
 		break;
 	case LED_PIN_LED0:
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 		ledcfg &= ~BIT(6);
 		rtl_write_byte(rtlpriv,
 			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5));
 		break;
 	case LED_PIN_LED1:
-		rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg & 0x0f) | BIT(5));
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg & 0x10);
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case not process\n");
 		break;
 	}
 	pled->ledon = true;
 }
 
-void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
+void rtl8723e_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
@@ -86,7 +86,7 @@ void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	case LED_PIN_LED0:
 		ledcfg &= 0xf0;
 		if (pcipriv->ledctl.led_opendrain) {
-			ledcfg &= 0x90;
+			ledcfg &= 0x90; /* Set to software control. */
 			rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg|BIT(3)));
 			ledcfg = rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
 			ledcfg &= 0xFE;
@@ -94,50 +94,51 @@ void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		} else {
 			ledcfg &= ~BIT(6);
 			rtl_write_byte(rtlpriv, REG_LEDCFG2,
-				       (ledcfg | BIT(3) | BIT(5)));
+					(ledcfg | BIT(3) | BIT(5)));
 		}
 		break;
 	case LED_PIN_LED1:
-		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1) & 0x10;
-		rtl_write_byte(rtlpriv, REG_LEDCFG1, (ledcfg | BIT(3)));
+		ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		ledcfg &= 0x10; /* Set to software control. */
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg|BIT(3));
+
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+			 "switch case not process\n");
 		break;
 	}
 	pled->ledon = false;
 }
 
-void rtl8723ae_init_sw_leds(struct ieee80211_hw *hw)
+void rtl8723e_init_sw_leds(struct ieee80211_hw *hw)
 {
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
-
-	_rtl8723ae_init_led(hw, &(pcipriv->ledctl.sw_led0), LED_PIN_LED0);
-	_rtl8723ae_init_led(hw, &(pcipriv->ledctl.sw_led1), LED_PIN_LED1);
+	_rtl8723e_init_led(hw, &pcipriv->ledctl.sw_led0, LED_PIN_LED0);
+	_rtl8723e_init_led(hw, &pcipriv->ledctl.sw_led1, LED_PIN_LED1);
 }
 
-static void _rtl8723ae_sw_led_control(struct ieee80211_hw *hw,
-				    enum led_ctl_mode ledaction)
+static void _rtl8723e_sw_led_control(struct ieee80211_hw *hw,
+				     enum led_ctl_mode ledaction)
 {
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
-
 	switch (ledaction) {
 	case LED_CTL_POWER_ON:
 	case LED_CTL_LINK:
 	case LED_CTL_NO_LINK:
-		rtl8723ae_sw_led_on(hw, pLed0);
+		rtl8723e_sw_led_on(hw, pLed0);
 		break;
 	case LED_CTL_POWER_OFF:
-		rtl8723ae_sw_led_off(hw, pLed0);
+		rtl8723e_sw_led_off(hw, pLed0);
 		break;
 	default:
 		break;
 	}
 }
 
-void rtl8723ae_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction)
+void rtl8723e_led_control(struct ieee80211_hw *hw,
+			  enum led_ctl_mode ledaction)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
@@ -152,6 +153,7 @@ void rtl8723ae_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction)
 	     ledaction == LED_CTL_POWER_ON)) {
 		return;
 	}
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d,\n", ledaction);
-	_rtl8723ae_sw_led_control(hw, ledaction);
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d,\n",
+		 ledaction);
+	_rtl8723e_sw_led_control(hw, ledaction);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/led.h b/drivers/net/wireless/rtlwifi/rtl8723ae/led.h
index 2cb88e7..c22b19f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/led.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/led.h
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
@@ -30,10 +26,9 @@
 #ifndef __RTL92CE_LED_H__
 #define __RTL92CE_LED_H__
 
-void rtl8723ae_init_sw_leds(struct ieee80211_hw *hw);
-void rtl8723ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled);
-void rtl8723ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled);
-void rtl8723ae_led_control(struct ieee80211_hw *hw,
-			   enum led_ctl_mode ledaction);
+void rtl8723e_init_sw_leds(struct ieee80211_hw *hw);
+void rtl8723e_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl8723e_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl8723e_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
index 3ea78af..1e2fa93 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
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
 #include "../pci.h"
 #include "../ps.h"
-#include "../core.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -39,29 +34,31 @@
 #include "table.h"
 #include "../rtl8723com/phy_common.h"
 
-/* static forward definitions */
-static u32 _phy_fw_rf_serial_read(struct ieee80211_hw *hw,
-				  enum radio_path rfpath, u32 offset);
-static void _phy_fw_rf_serial_write(struct ieee80211_hw *hw,
-				    enum radio_path rfpath,
-				    u32 offset, u32 data);
-static bool _phy_bb8192c_config_parafile(struct ieee80211_hw *hw);
-static bool _phy_cfg_mac_w_header(struct ieee80211_hw *hw);
-static bool _phy_cfg_bb_w_header(struct ieee80211_hw *hw, u8 configtype);
-static bool _phy_cfg_bb_w_pgheader(struct ieee80211_hw *hw, u8 configtype);
-static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
-				      u8 *stage, u8 *step, u32 *delay);
-static u8 _phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
-				enum wireless_mode wirelessmode,
-				long power_indbm);
-static void rtl8723ae_phy_set_io(struct ieee80211_hw *hw);
-
-u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
-			       enum radio_path rfpath, u32 regaddr, u32 bitmask)
+static void _rtl8723e_phy_fw_rf_serial_write(struct ieee80211_hw *hw,
+					     enum radio_path rfpath, u32 offset,
+					     u32 data);
+static bool _rtl8723e_phy_bb8192c_config_parafile(struct ieee80211_hw *hw);
+static bool _rtl8723e_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
+static bool _rtl8723e_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+						    u8 configtype);
+static bool _rtl8723e_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
+						      u8 configtype);
+static bool _rtl8723e_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+					       u8 channel, u8 *stage, u8 *step,
+					       u32 *delay);
+static u8 _rtl8723e_phy_dbm_to_txpwr_idx(struct ieee80211_hw *hw,
+					 enum wireless_mode wirelessmode,
+					 long power_indbm);
+static void rtl8723e_phy_set_rf_on(struct ieee80211_hw *hw);
+static void rtl8723e_phy_set_io(struct ieee80211_hw *hw);
+
+u32 rtl8723e_phy_query_rf_reg(struct ieee80211_hw *hw,
+			      enum radio_path rfpath,
+			      u32 regaddr, u32 bitmask)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	u32 original_value, readback_value, bitshift;
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u32 original_value = 0, readback_value, bitshift;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	unsigned long flags;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
@@ -70,10 +67,10 @@ u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
 
 	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
 
-	if (rtlphy->rf_mode != RF_OP_BY_FW)
-		original_value = rtl8723_phy_rf_serial_read(hw, rfpath, regaddr);
-	else
-		original_value = _phy_fw_rf_serial_read(hw, rfpath, regaddr);
+	if (rtlphy->rf_mode != RF_OP_BY_FW) {
+		original_value = rtl8723_phy_rf_serial_read(hw,
+							    rfpath, regaddr);
+	}
 
 	bitshift = rtl8723_phy_calculate_bit_shift(bitmask);
 	readback_value = (original_value & bitmask) >> bitshift;
@@ -82,45 +79,46 @@ u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
-		 regaddr, rfpath, bitmask, original_value);
+		  regaddr, rfpath, bitmask, original_value);
 
 	return readback_value;
 }
 
-void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
-			      enum radio_path rfpath,
-			      u32 regaddr, u32 bitmask, u32 data)
+void rtl8723e_phy_set_rf_reg(struct ieee80211_hw *hw,
+			     enum radio_path rfpath,
+			   u32 regaddr, u32 bitmask, u32 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
-	u32 original_value, bitshift;
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+	u32 original_value = 0, bitshift;
 	unsigned long flags;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
-		 regaddr, bitmask, data, rfpath);
+		  regaddr, bitmask, data, rfpath);
 
 	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
 
 	if (rtlphy->rf_mode != RF_OP_BY_FW) {
 		if (bitmask != RFREG_OFFSET_MASK) {
-			original_value = rtl8723_phy_rf_serial_read(hw, rfpath,
+			original_value = rtl8723_phy_rf_serial_read(hw,
+								    rfpath,
 								    regaddr);
 			bitshift = rtl8723_phy_calculate_bit_shift(bitmask);
-			data = ((original_value & (~bitmask)) |
-			       (data << bitshift));
+			data =
+			    ((original_value & (~bitmask)) |
+			     (data << bitshift));
 		}
 
 		rtl8723_phy_rf_serial_write(hw, rfpath, regaddr, data);
 	} else {
 		if (bitmask != RFREG_OFFSET_MASK) {
-			original_value = _phy_fw_rf_serial_read(hw, rfpath,
-								regaddr);
 			bitshift = rtl8723_phy_calculate_bit_shift(bitmask);
-			data = ((original_value & (~bitmask)) |
-			       (data << bitshift));
+			data =
+			    ((original_value & (~bitmask)) |
+			     (data << bitshift));
 		}
-		_phy_fw_rf_serial_write(hw, rfpath, regaddr, data);
+		_rtl8723e_phy_fw_rf_serial_write(hw, rfpath, regaddr, data);
 	}
 
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
@@ -128,23 +126,17 @@ void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
 		 regaddr, bitmask, data, rfpath);
-}
 
-static u32 _phy_fw_rf_serial_read(struct ieee80211_hw *hw,
-					    enum radio_path rfpath, u32 offset)
-{
-	RT_ASSERT(false, "deprecated!\n");
-	return 0;
 }
 
-static void _phy_fw_rf_serial_write(struct ieee80211_hw *hw,
-				    enum radio_path rfpath,
-				    u32 offset, u32 data)
+static void _rtl8723e_phy_fw_rf_serial_write(struct ieee80211_hw *hw,
+					     enum radio_path rfpath, u32 offset,
+					     u32 data)
 {
 	RT_ASSERT(false, "deprecated!\n");
 }
 
-static void _rtl8723ae_phy_bb_config_1t(struct ieee80211_hw *hw)
+static void _rtl8723e_phy_bb_config_1t(struct ieee80211_hw *hw)
 {
 	rtl_set_bbreg(hw, RFPGA0_TXINFO, 0x3, 0x2);
 	rtl_set_bbreg(hw, RFPGA1_TXINFO, 0x300033, 0x200022);
@@ -158,20 +150,20 @@ static void _rtl8723ae_phy_bb_config_1t(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, 0xe88, 0x0c000000, 0x2);
 }
 
-bool rtl8723ae_phy_mac_config(struct ieee80211_hw *hw)
+bool rtl8723e_phy_mac_config(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	bool rtstatus = _phy_cfg_mac_w_header(hw);
+	bool rtstatus = _rtl8723e_phy_config_mac_with_headerfile(hw);
 	rtl_write_byte(rtlpriv, 0x04CA, 0x0A);
 	return rtstatus;
 }
 
-bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw)
+bool rtl8723e_phy_bb_config(struct ieee80211_hw *hw)
 {
 	bool rtstatus = true;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmpu1b;
-	u8 reg_hwparafile = 1;
+	u8 b_reg_hwparafile = 1;
 
 	rtl8723_phy_init_bb_rf_reg_def(hw);
 
@@ -186,67 +178,72 @@ bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw)
 
 	/* 3. 0x02[1:0] = 2b'11 */
 	tmpu1b = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN);
-	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, (tmpu1b |
-		       FEN_BB_GLB_RSTn | FEN_BBRSTB));
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN,
+		       (tmpu1b | FEN_BB_GLB_RSTN | FEN_BBRSTB));
 
 	/* 4. 0x25[6] = 0 */
 	tmpu1b = rtl_read_byte(rtlpriv, REG_AFE_XTAL_CTRL+1);
-	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL+1, (tmpu1b&(~BIT(6))));
+	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL+1, (tmpu1b & (~BIT(6))));
 
-	/* 5. 0x24[20] = 0	Advised by SD3 Alex Wang. 2011.02.09. */
+	/* 5. 0x24[20] = 0	//Advised by SD3 Alex Wang. 2011.02.09. */
 	tmpu1b = rtl_read_byte(rtlpriv, REG_AFE_XTAL_CTRL+2);
-	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL+2, (tmpu1b&(~BIT(4))));
+	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL+2, (tmpu1b & (~BIT(4))));
 
 	/* 6. 0x1f[7:0] = 0x07 */
 	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x07);
 
-	if (reg_hwparafile == 1)
-		rtstatus = _phy_bb8192c_config_parafile(hw);
+	if (b_reg_hwparafile == 1)
+		rtstatus = _rtl8723e_phy_bb8192c_config_parafile(hw);
 	return rtstatus;
 }
 
-bool rtl8723ae_phy_rf_config(struct ieee80211_hw *hw)
+bool rtl8723e_phy_rf_config(struct ieee80211_hw *hw)
 {
-	return rtl8723ae_phy_rf6052_config(hw);
+	return rtl8723e_phy_rf6052_config(hw);
 }
 
-static bool _phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
+static bool _rtl8723e_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	bool rtstatus;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "==>\n");
-	rtstatus = _phy_cfg_bb_w_header(hw, BASEBAND_CONFIG_PHY_REG);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "\n");
+	rtstatus = _rtl8723e_phy_config_bb_with_headerfile(hw,
+						BASEBAND_CONFIG_PHY_REG);
 	if (rtstatus != true) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
 		return false;
 	}
 
 	if (rtlphy->rf_type == RF_1T2R) {
-		_rtl8723ae_phy_bb_config_1t(hw);
+		_rtl8723e_phy_bb_config_1t(hw);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Config to 1T!!\n");
 	}
 	if (rtlefuse->autoload_failflag == false) {
 		rtlphy->pwrgroup_cnt = 0;
-		rtstatus = _phy_cfg_bb_w_pgheader(hw, BASEBAND_CONFIG_PHY_REG);
+		rtstatus = _rtl8723e_phy_config_bb_with_pgheaderfile(hw,
+					BASEBAND_CONFIG_PHY_REG);
 	}
 	if (rtstatus != true) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
 		return false;
 	}
-	rtstatus = _phy_cfg_bb_w_header(hw, BASEBAND_CONFIG_AGC_TAB);
+	rtstatus =
+	  _rtl8723e_phy_config_bb_with_headerfile(hw, BASEBAND_CONFIG_AGC_TAB);
 	if (rtstatus != true) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
 	rtlphy->cck_high_power = (bool) (rtl_get_bbreg(hw,
-					 RFPGA0_XA_HSSIPARAMETER2, 0x200));
+					RFPGA0_XA_HSSIPARAMETER2,
+					0x200));
+
 	return true;
 }
 
-static bool _phy_cfg_mac_w_header(struct ieee80211_hw *hw)
+static bool _rtl8723e_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 i;
@@ -264,7 +261,8 @@ static bool _phy_cfg_mac_w_header(struct ieee80211_hw *hw)
 	return true;
 }
 
-static bool _phy_cfg_bb_w_header(struct ieee80211_hw *hw, u8 configtype)
+static bool _rtl8723e_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+						    u8 configtype)
 {
 	int i;
 	u32 *phy_regarray_table;
@@ -278,13 +276,23 @@ static bool _phy_cfg_bb_w_header(struct ieee80211_hw *hw, u8 configtype)
 	phy_regarray_table = RTL8723EPHY_REG_1TARRAY;
 	if (configtype == BASEBAND_CONFIG_PHY_REG) {
 		for (i = 0; i < phy_reg_arraylen; i = i + 2) {
-			rtl_addr_delay(phy_regarray_table[i]);
+			if (phy_regarray_table[i] == 0xfe)
+				mdelay(50);
+			else if (phy_regarray_table[i] == 0xfd)
+				mdelay(5);
+			else if (phy_regarray_table[i] == 0xfc)
+				mdelay(1);
+			else if (phy_regarray_table[i] == 0xfb)
+				udelay(50);
+			else if (phy_regarray_table[i] == 0xfa)
+				udelay(5);
+			else if (phy_regarray_table[i] == 0xf9)
+				udelay(1);
 			rtl_set_bbreg(hw, phy_regarray_table[i], MASKDWORD,
 				      phy_regarray_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "The phy_regarray_table[0] is %x"
-				 " Rtl819XPHY_REGArray[1] is %x\n",
+				 "The phy_regarray_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
 				 phy_regarray_table[i],
 				 phy_regarray_table[i + 1]);
 		}
@@ -294,8 +302,7 @@ static bool _phy_cfg_bb_w_header(struct ieee80211_hw *hw, u8 configtype)
 				      agctab_array_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "The agctab_array_table[0] is "
-				 "%x Rtl819XPHY_REGArray[1] is %x\n",
+				 "The agctab_array_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
 				 agctab_array_table[i],
 				 agctab_array_table[i + 1]);
 		}
@@ -303,132 +310,163 @@ static bool _phy_cfg_bb_w_header(struct ieee80211_hw *hw, u8 configtype)
 	return true;
 }
 
-static void _st_pwrIdx_dfrate_off(struct ieee80211_hw *hw, u32 regaddr,
-				  u32 bitmask, u32 data)
+static void store_pwrindex_diffrate_offset(struct ieee80211_hw *hw,
+					   u32 regaddr, u32 bitmask,
+					   u32 data)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
-	switch (regaddr) {
-	case RTXAGC_A_RATE18_06:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][0] = data;
+	if (regaddr == RTXAGC_A_RATE18_06) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][0] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][0] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][0]);
-		break;
-	case RTXAGC_A_RATE54_24:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][1] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][0]);
+	}
+	if (regaddr == RTXAGC_A_RATE54_24) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][1] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][1] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][1]);
-		break;
-	case RTXAGC_A_CCK1_MCS32:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][6] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][1]);
+	}
+	if (regaddr == RTXAGC_A_CCK1_MCS32) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][6] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][6] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][6]);
-		break;
-	case RTXAGC_B_CCK11_A_CCK2_11:
-		if (bitmask == 0xffffff00) {
-			rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][7] = data;
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
-				 rtlphy->pwrgroup_cnt,
-				 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][7]);
-		}
-		if (bitmask == 0x000000ff) {
-			rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][15] = data;
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
-				 rtlphy->pwrgroup_cnt,
-				 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][15]);
-		}
-		break;
-	case RTXAGC_A_MCS03_MCS00:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][2] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][6]);
+	}
+	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0xffffff00) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][7] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][7]);
+	}
+	if (regaddr == RTXAGC_A_MCS03_MCS00) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][2] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][2] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][2]);
-		break;
-	case RTXAGC_A_MCS07_MCS04:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][3] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][2]);
+	}
+	if (regaddr == RTXAGC_A_MCS07_MCS04) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][3] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][3] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][3]);
-		break;
-	case RTXAGC_A_MCS11_MCS08:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][4] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][3]);
+	}
+	if (regaddr == RTXAGC_A_MCS11_MCS08) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][4] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][4] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][4]);
-		break;
-	case RTXAGC_A_MCS15_MCS12:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][5] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][4]);
+	}
+	if (regaddr == RTXAGC_A_MCS15_MCS12) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][5] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][5] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][5]);
-		break;
-	case RTXAGC_B_RATE18_06:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][8] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][5]);
+	}
+	if (regaddr == RTXAGC_B_RATE18_06) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][8] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][8] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][8]);
-		break;
-	case RTXAGC_B_RATE54_24:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][9] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][8]);
+	}
+	if (regaddr == RTXAGC_B_RATE54_24) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][9] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][9] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][9]);
-		break;
-	case RTXAGC_B_CCK1_55_MCS32:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][14] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][9]);
+	}
+	if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][14] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][14] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][14]);
-		break;
-	case RTXAGC_B_MCS03_MCS00:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][10] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][14]);
+	}
+	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0x000000ff) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][15] =
+		    data;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][15]);
+	}
+	if (regaddr == RTXAGC_B_MCS03_MCS00) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][10] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][10] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][10]);
-		break;
-	case RTXAGC_B_MCS07_MCS04:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][11] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][10]);
+	}
+	if (regaddr == RTXAGC_B_MCS07_MCS04) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][11] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][11] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][11]);
-		break;
-	case RTXAGC_B_MCS11_MCS08:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][12] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][11]);
+	}
+	if (regaddr == RTXAGC_B_MCS11_MCS08) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][12] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][12] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][12]);
-		break;
-	case RTXAGC_B_MCS15_MCS12:
-		rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][13] = data;
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][12]);
+	}
+	if (regaddr == RTXAGC_B_MCS15_MCS12) {
+		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][13] =
+		    data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 			 "MCSTxPowerLevelOriginalOffset[%d][13] = 0x%x\n",
-			 rtlphy->pwrgroup_cnt,
-			 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][13]);
+			  rtlphy->pwrgroup_cnt,
+			  rtlphy->mcs_txpwrlevel_origoffset[rtlphy->
+							    pwrgroup_cnt][13]);
+
 		rtlphy->pwrgroup_cnt++;
-		break;
 	}
 }
 
-static bool _phy_cfg_bb_w_pgheader(struct ieee80211_hw *hw, u8 configtype)
+static bool _rtl8723e_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
+						      u8 configtype)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	int i;
@@ -440,11 +478,23 @@ static bool _phy_cfg_bb_w_pgheader(struct ieee80211_hw *hw, u8 configtype)
 
 	if (configtype == BASEBAND_CONFIG_PHY_REG) {
 		for (i = 0; i < phy_regarray_pg_len; i = i + 3) {
-			rtl_addr_delay(phy_regarray_table_pg[i]);
-
-			_st_pwrIdx_dfrate_off(hw, phy_regarray_table_pg[i],
-					      phy_regarray_table_pg[i + 1],
-					      phy_regarray_table_pg[i + 2]);
+			if (phy_regarray_table_pg[i] == 0xfe)
+				mdelay(50);
+			else if (phy_regarray_table_pg[i] == 0xfd)
+				mdelay(5);
+			else if (phy_regarray_table_pg[i] == 0xfc)
+				mdelay(1);
+			else if (phy_regarray_table_pg[i] == 0xfb)
+				udelay(50);
+			else if (phy_regarray_table_pg[i] == 0xfa)
+				udelay(5);
+			else if (phy_regarray_table_pg[i] == 0xf9)
+				udelay(1);
+
+			store_pwrindex_diffrate_offset(hw,
+						phy_regarray_table_pg[i],
+						phy_regarray_table_pg[i + 1],
+						phy_regarray_table_pg[i + 2]);
 		}
 	} else {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
@@ -453,45 +503,57 @@ static bool _phy_cfg_bb_w_pgheader(struct ieee80211_hw *hw, u8 configtype)
 	return true;
 }
 
-bool rtl8723ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
-					     enum radio_path rfpath)
+bool rtl8723e_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+					    enum radio_path rfpath)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	int i;
+	bool rtstatus = true;
 	u32 *radioa_array_table;
-	u16 radioa_arraylen;
+	u32 *radiob_array_table;
+	u16 radioa_arraylen, radiob_arraylen;
 
-	radioa_arraylen = Rtl8723ERADIOA_1TARRAYLENGTH;
+	radioa_arraylen = RTL8723ERADIOA_1TARRAYLENGTH;
 	radioa_array_table = RTL8723E_RADIOA_1TARRAY;
+	radiob_arraylen = RTL8723E_RADIOB_1TARRAYLENGTH;
+	radiob_array_table = RTL8723E_RADIOB_1TARRAY;
+
+	rtstatus = true;
 
 	switch (rfpath) {
 	case RF90_PATH_A:
 		for (i = 0; i < radioa_arraylen; i = i + 2) {
-			rtl_rfreg_delay(hw, rfpath, radioa_array_table[i],
-					RFREG_OFFSET_MASK,
-					radioa_array_table[i + 1]);
+			if (radioa_array_table[i] == 0xfe) {
+				mdelay(50);
+			} else if (radioa_array_table[i] == 0xfd) {
+				mdelay(5);
+			} else if (radioa_array_table[i] == 0xfc) {
+				mdelay(1);
+			} else if (radioa_array_table[i] == 0xfb) {
+				udelay(50);
+			} else if (radioa_array_table[i] == 0xfa) {
+				udelay(5);
+			} else if (radioa_array_table[i] == 0xf9) {
+				udelay(1);
+			} else {
+				rtl_set_rfreg(hw, rfpath, radioa_array_table[i],
+					      RFREG_OFFSET_MASK,
+					      radioa_array_table[i + 1]);
+				udelay(1);
+			}
 		}
 		break;
 	case RF90_PATH_B:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
 	case RF90_PATH_C:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
-		break;
 	case RF90_PATH_D:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not process\n");
 		break;
 	}
 	return true;
 }
 
-void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
+void rtl8723e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	rtlphy->default_initialgain[0] =
 	    (u8) rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
@@ -504,10 +566,10 @@ void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x\n",
-		  rtlphy->default_initialgain[0],
-		  rtlphy->default_initialgain[1],
-		  rtlphy->default_initialgain[2],
-		  rtlphy->default_initialgain[3]);
+		 rtlphy->default_initialgain[0],
+		 rtlphy->default_initialgain[1],
+		 rtlphy->default_initialgain[2],
+		 rtlphy->default_initialgain[3]);
 
 	rtlphy->framesync = (u8) rtl_get_bbreg(hw,
 					       ROFDM0_RXDETECTOR3, MASKBYTE0);
@@ -516,37 +578,43 @@ void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 		 "Default framesync (0x%x) = 0x%x\n",
-		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
+		  ROFDM0_RXDETECTOR3, rtlphy->framesync);
 }
 
-void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
+void rtl8723e_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 txpwr_level;
 	long txpwr_dbm;
 
 	txpwr_level = rtlphy->cur_cck_txpwridx;
-	txpwr_dbm = rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_B, txpwr_level);
+	txpwr_dbm = rtl8723_phy_txpwr_idx_to_dbm(hw,
+						 WIRELESS_MODE_B, txpwr_level);
 	txpwr_level = rtlphy->cur_ofdm24g_txpwridx +
 	    rtlefuse->legacy_ht_txpowerdiff;
-	if (rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G, txpwr_level) > txpwr_dbm)
-		txpwr_dbm = rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
-						  txpwr_level);
+	if (rtl8723_phy_txpwr_idx_to_dbm(hw,
+					 WIRELESS_MODE_G,
+					 txpwr_level) > txpwr_dbm)
+		txpwr_dbm =
+		    rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
+						 txpwr_level);
 	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
-	if (rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G, txpwr_level) >
-	    txpwr_dbm)
-		txpwr_dbm = rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
-							 txpwr_level);
+	if (rtl8723_phy_txpwr_idx_to_dbm(hw,
+					 WIRELESS_MODE_N_24G,
+					 txpwr_level) > txpwr_dbm)
+		txpwr_dbm =
+		    rtl8723_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
+						 txpwr_level);
 	*powerlevel = txpwr_dbm;
 }
 
-static void _rtl8723ae_get_txpower_index(struct ieee80211_hw *hw, u8 channel,
-					 u8 *cckpowerlevel, u8 *ofdmpowerlevel)
+static void _rtl8723e_get_txpower_index(struct ieee80211_hw *hw, u8 channel,
+					u8 *cckpowerlevel, u8 *ofdmpowerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 index = (channel - 1);
 
@@ -567,66 +635,70 @@ static void _rtl8723ae_get_txpower_index(struct ieee80211_hw *hw, u8 channel,
 	}
 }
 
-static void _rtl8723ae_ccxpower_index_check(struct ieee80211_hw *hw,
-					    u8 channel, u8 *cckpowerlevel,
-					    u8 *ofdmpowerlevel)
+static void _rtl8723e_ccxpower_index_check(struct ieee80211_hw *hw,
+					   u8 channel, u8 *cckpowerlevel,
+					   u8 *ofdmpowerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	rtlphy->cur_cck_txpwridx = cckpowerlevel[0];
 	rtlphy->cur_ofdm24g_txpwridx = ofdmpowerlevel[0];
+
 }
 
-void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
+void rtl8723e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
 {
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 cckpowerlevel[2], ofdmpowerlevel[2];
 
 	if (rtlefuse->txpwr_fromeprom == false)
 		return;
-	_rtl8723ae_get_txpower_index(hw, channel, &cckpowerlevel[0],
-				     &ofdmpowerlevel[0]);
-	_rtl8723ae_ccxpower_index_check(hw, channel, &cckpowerlevel[0],
-					&ofdmpowerlevel[0]);
-	rtl8723ae_phy_rf6052_set_cck_txpower(hw, &cckpowerlevel[0]);
-	rtl8723ae_phy_rf6052_set_ofdm_txpower(hw, &ofdmpowerlevel[0], channel);
+	_rtl8723e_get_txpower_index(hw, channel,
+				    &cckpowerlevel[0], &ofdmpowerlevel[0]);
+	_rtl8723e_ccxpower_index_check(hw,
+				       channel, &cckpowerlevel[0],
+				       &ofdmpowerlevel[0]);
+	rtl8723e_phy_rf6052_set_cck_txpower(hw, &cckpowerlevel[0]);
+	rtl8723e_phy_rf6052_set_ofdm_txpower(hw, &ofdmpowerlevel[0], channel);
 }
 
-bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm)
+bool rtl8723e_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 idx;
 	u8 rf_path;
-	u8 ccktxpwridx = _phy_dbm_to_txpwr_Idx(hw, WIRELESS_MODE_B,
-					       power_indbm);
-	u8 ofdmtxpwridx = _phy_dbm_to_txpwr_Idx(hw, WIRELESS_MODE_N_24G,
-						power_indbm);
+	u8 ccktxpwridx = _rtl8723e_phy_dbm_to_txpwr_idx(hw,
+						      WIRELESS_MODE_B,
+						      power_indbm);
+	u8 ofdmtxpwridx = _rtl8723e_phy_dbm_to_txpwr_idx(hw,
+						       WIRELESS_MODE_N_24G,
+						       power_indbm);
 	if (ofdmtxpwridx - rtlefuse->legacy_ht_txpowerdiff > 0)
 		ofdmtxpwridx -= rtlefuse->legacy_ht_txpowerdiff;
 	else
 		ofdmtxpwridx = 0;
 	RT_TRACE(rtlpriv, COMP_TXAGC, DBG_TRACE,
 		 "%lx dBm, ccktxpwridx = %d, ofdmtxpwridx = %d\n",
-		 power_indbm, ccktxpwridx, ofdmtxpwridx);
+		  power_indbm, ccktxpwridx, ofdmtxpwridx);
 	for (idx = 0; idx < 14; idx++) {
 		for (rf_path = 0; rf_path < 2; rf_path++) {
 			rtlefuse->txpwrlevel_cck[rf_path][idx] = ccktxpwridx;
 			rtlefuse->txpwrlevel_ht40_1s[rf_path][idx] =
-							    ofdmtxpwridx;
+			    ofdmtxpwridx;
 			rtlefuse->txpwrlevel_ht40_2s[rf_path][idx] =
-							    ofdmtxpwridx;
+			    ofdmtxpwridx;
 		}
 	}
-	rtl8723ae_phy_set_txpower_level(hw, rtlphy->current_channel);
+	rtl8723e_phy_set_txpower_level(hw, rtlphy->current_channel);
 	return true;
 }
 
-static u8 _phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
-				enum wireless_mode wirelessmode,
-				long power_indbm)
+static u8 _rtl8723e_phy_dbm_to_txpwr_idx(struct ieee80211_hw *hw,
+					 enum wireless_mode wirelessmode,
+					 long power_indbm)
 {
 	u8 txpwridx;
 	long offset;
@@ -645,7 +717,7 @@ static u8 _phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
 	}
 
 	if ((power_indbm - offset) > 0)
-		txpwridx = (u8) ((power_indbm - offset) * 2);
+		txpwridx = (u8)((power_indbm - offset) * 2);
 	else
 		txpwridx = 0;
 
@@ -655,19 +727,48 @@ static u8 _phy_dbm_to_txpwr_Idx(struct ieee80211_hw *hw,
 	return txpwridx;
 }
 
-void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
+void rtl8723e_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
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
+}
+
+void rtl8723e_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
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
@@ -719,16 +820,16 @@ void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
-	rtl8723ae_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
+	rtl8723e_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
 	rtlphy->set_bwmode_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "\n");
 }
 
-void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
-			       enum nl80211_channel_type ch_type)
+void rtl8723e_phy_set_bw_mode(struct ieee80211_hw *hw,
+			      enum nl80211_channel_type ch_type)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 tmp_bw = rtlphy->current_chan_bw;
 
@@ -736,20 +837,20 @@ void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
 		return;
 	rtlphy->set_bwmode_inprogress = true;
 	if ((!is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
-		rtl8723ae_phy_set_bw_mode_callback(hw);
+		rtl8723e_phy_set_bw_mode_callback(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 "FALSE driver sleep or unload\n");
+			 "false driver sleep or unload\n");
 		rtlphy->set_bwmode_inprogress = false;
 		rtlphy->current_chan_bw = tmp_bw;
 	}
 }
 
-void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw)
+void rtl8723e_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 delay;
 
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
@@ -759,7 +860,7 @@ void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 	do {
 		if (!rtlphy->sw_chnl_inprogress)
 			break;
-		if (!_phy_sw_chnl_step_by_step
+		if (!_rtl8723e_phy_sw_chnl_step_by_step
 		    (hw, rtlphy->current_channel, &rtlphy->sw_chnl_stage,
 		     &rtlphy->sw_chnl_step, &delay)) {
 			if (delay > 0)
@@ -771,13 +872,13 @@ void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 		}
 		break;
 	} while (true);
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "\n");
 }
 
-u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw)
+u8 rtl8723e_phy_sw_chnl(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	if (rtlphy->sw_chnl_inprogress)
@@ -790,9 +891,9 @@ u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw)
 	rtlphy->sw_chnl_stage = 0;
 	rtlphy->sw_chnl_step = 0;
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
-		rtl8723ae_phy_sw_chnl_callback(hw);
+		rtl8723e_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 "sw_chnl_inprogress false schedule workitem\n");
+			 "sw_chnl_inprogress false schdule workitem\n");
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
@@ -802,31 +903,33 @@ u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw)
 	return 1;
 }
 
-static void _rtl8723ae_phy_sw_rf_seting(struct ieee80211_hw *hw, u8 channel)
+static void _rtl8723e_phy_sw_rf_seting(struct ieee80211_hw *hw, u8 channel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
 		if (channel == 6 && rtlphy->current_chan_bw ==
-		    HT_CHANNEL_WIDTH_20)
-			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD,
-				      0x00255);
+				HT_CHANNEL_WIDTH_20)
+			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1,
+				      MASKDWORD, 0x00255);
 		else{
-			u32 backupRF0x1A = (u32)rtl_get_rfreg(hw, RF90_PATH_A,
-					   RF_RX_G1, RFREG_OFFSET_MASK);
-			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1, MASKDWORD,
-				      backupRF0x1A);
+			u32 backuprf0x1a = (u32)rtl_get_rfreg(hw,
+					RF90_PATH_A, RF_RX_G1,
+					RFREG_OFFSET_MASK);
+			rtl_set_rfreg(hw, RF90_PATH_A, RF_RX_G1,
+				      MASKDWORD, backuprf0x1a);
 		}
 	}
 }
 
-static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
-				      u8 *stage, u8 *step, u32 *delay)
+static bool _rtl8723e_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+					       u8 channel, u8 *stage, u8 *step,
+					       u32 *delay)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct swchnlcmd precommoncmd[MAX_PRECMD_CNT];
 	u32 precommoncmdcnt;
 	struct swchnlcmd postcommoncmd[MAX_POSTCMD_CNT];
@@ -839,14 +942,16 @@ static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
 
 	precommoncmdcnt = 0;
 	rtl8723_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
-					 MAX_PRECMD_CNT, CMDID_SET_TXPOWEROWER_LEVEL,
-					 0, 0, 0);
+					 MAX_PRECMD_CNT,
+					 CMDID_SET_TXPOWEROWER_LEVEL, 0, 0, 0);
 	rtl8723_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
 					 MAX_PRECMD_CNT, CMDID_END, 0, 0, 0);
+
 	postcommoncmdcnt = 0;
 
 	rtl8723_phy_set_sw_chnl_cmdarray(postcommoncmd, postcommoncmdcnt++,
 					 MAX_POSTCMD_CNT, CMDID_END, 0, 0, 0);
+
 	rfdependcmdcnt = 0;
 
 	RT_ASSERT((channel >= 1 && channel <= 14),
@@ -854,10 +959,11 @@ static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
 
 	rtl8723_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
 					 MAX_RFDEPENDCMD_CNT, CMDID_RF_WRITEREG,
-				  RF_CHNLBW, channel, 10);
+					 RF_CHNLBW, channel, 10);
 
 	rtl8723_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
-					 MAX_RFDEPENDCMD_CNT, CMDID_END, 0, 0, 0);
+					 MAX_RFDEPENDCMD_CNT, CMDID_END, 0, 0,
+					 0);
 
 	do {
 		switch (*stage) {
@@ -870,6 +976,10 @@ static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
 		case 2:
 			currentcmd = &postcommoncmd[*step];
 			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Invalid 'stage' = %d, Check it!\n", *stage);
+			return true;
 		}
 
 		if (currentcmd->cmdid == CMDID_END) {
@@ -884,7 +994,7 @@ static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
 
 		switch (currentcmd->cmdid) {
 		case CMDID_SET_TXPOWEROWER_LEVEL:
-			rtl8723ae_phy_set_txpower_level(hw, channel);
+			rtl8723e_phy_set_txpower_level(hw, channel);
 			break;
 		case CMDID_WRITEPORT_ULONG:
 			rtl_write_dword(rtlpriv, currentcmd->para1,
@@ -909,10 +1019,10 @@ static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
 					      RFREG_OFFSET_MASK,
 					      rtlphy->rfreg_chnlval[rfpath]);
 			}
-			_rtl8723ae_phy_sw_rf_seting(hw, channel);
+			_rtl8723e_phy_sw_rf_seting(hw, channel);
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 				 "switch case not process\n");
 			break;
 		}
@@ -925,7 +1035,7 @@ static bool _phy_sw_chnl_step_by_step(struct ieee80211_hw *hw, u8 channel,
 	return false;
 }
 
-static u8 _rtl8723ae_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
+static u8 _rtl8723e_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
 {
 	u32 reg_eac, reg_e94, reg_e9c, reg_ea4;
 	u8 result = 0x00;
@@ -968,7 +1078,7 @@ static u8 _rtl8723ae_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
 	return result;
 }
 
-static u8 _rtl8723ae_phy_path_b_iqk(struct ieee80211_hw *hw)
+static u8 _rtl8723e_phy_path_b_iqk(struct ieee80211_hw *hw)
 {
 	u32 reg_eac, reg_eb4, reg_ebc, reg_ec4, reg_ecc;
 	u8 result = 0x00;
@@ -995,8 +1105,8 @@ static u8 _rtl8723ae_phy_path_b_iqk(struct ieee80211_hw *hw)
 	return result;
 }
 
-static bool phy_simularity_comp(struct ieee80211_hw *hw, long result[][8],
-				u8 c1, u8 c2)
+static bool _rtl8723e_phy_simularity_compare(struct ieee80211_hw *hw,
+					     long result[][8], u8 c1, u8 c2)
 {
 	u32 i, j, diff, simularity_bitmap, bound;
 
@@ -1047,11 +1157,21 @@ static bool phy_simularity_comp(struct ieee80211_hw *hw, long result[][8],
 
 }
 
-static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
-					long result[][8], u8 t, bool is2t)
+static void rtl8723_phy_save_adda_registers(struct ieee80211_hw *hw,
+					    u32 *addareg, u32 *addabackup,
+					    u32 registernum)
+{
+	u32 i;
+
+	for (i = 0; i < registernum; i++)
+		addabackup[i] = rtl_get_bbreg(hw, addareg[i], MASKDWORD);
+}
+
+static void _rtl8723e_phy_iq_calibrate(struct ieee80211_hw *hw,
+				       long result[][8], u8 t, bool is2t)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 i;
 	u8 patha_ok, pathb_ok;
 	u32 adda_reg[IQK_ADDA_REG_NUM] = {
@@ -1060,22 +1180,28 @@ static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
 		0xe88, 0xe8c, 0xed0, 0xed4,
 		0xed8, 0xedc, 0xee0, 0xeec
 	};
+
 	u32 iqk_mac_reg[IQK_MAC_REG_NUM] = {
 		0x522, 0x550, 0x551, 0x040
 	};
+
 	const u32 retrycount = 2;
 
+	u32 bbvalue;
+
 	if (t == 0) {
-		rtl8723_save_adda_registers(hw, adda_reg, rtlphy->adda_backup,
-					    16);
+		bbvalue = rtl_get_bbreg(hw, 0x800, MASKDWORD);
+
+		rtl8723_phy_save_adda_registers(hw, adda_reg,
+						rtlphy->adda_backup, 16);
 		rtl8723_phy_save_mac_registers(hw, iqk_mac_reg,
 					       rtlphy->iqk_mac_backup);
 	}
 	rtl8723_phy_path_adda_on(hw, adda_reg, true, is2t);
 	if (t == 0) {
 		rtlphy->rfpi_enable = (u8) rtl_get_bbreg(hw,
-						 RFPGA0_XA_HSSIPARAMETER1,
-						 BIT(8));
+					RFPGA0_XA_HSSIPARAMETER1,
+					BIT(8));
 	}
 
 	if (!rtlphy->rfpi_enable)
@@ -1101,7 +1227,7 @@ static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
 	rtl_set_bbreg(hw, 0xe40, MASKDWORD, 0x01007c00);
 	rtl_set_bbreg(hw, 0xe44, MASKDWORD, 0x01004800);
 	for (i = 0; i < retrycount; i++) {
-		patha_ok = _rtl8723ae_phy_path_a_iqk(hw, is2t);
+		patha_ok = _rtl8723e_phy_path_a_iqk(hw, is2t);
 		if (patha_ok == 0x03) {
 			result[t][0] = (rtl_get_bbreg(hw, 0xe94, MASKDWORD) &
 					0x3FF0000) >> 16;
@@ -1115,7 +1241,8 @@ static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
 		} else if (i == (retrycount - 1) && patha_ok == 0x01)
 
 			result[t][0] = (rtl_get_bbreg(hw, 0xe94,
-					MASKDWORD) & 0x3FF0000) >> 16;
+						      MASKDWORD) & 0x3FF0000) >>
+			    16;
 		result[t][1] =
 		    (rtl_get_bbreg(hw, 0xe9c, MASKDWORD) & 0x3FF0000) >> 16;
 
@@ -1125,11 +1252,12 @@ static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
 		rtl8723_phy_path_a_standby(hw);
 		rtl8723_phy_path_adda_on(hw, adda_reg, false, is2t);
 		for (i = 0; i < retrycount; i++) {
-			pathb_ok = _rtl8723ae_phy_path_b_iqk(hw);
+			pathb_ok = _rtl8723e_phy_path_b_iqk(hw);
 			if (pathb_ok == 0x03) {
-				result[t][4] =
-				    (rtl_get_bbreg(hw, 0xeb4, MASKDWORD) &
-				     0x3FF0000) >> 16;
+				result[t][4] = (rtl_get_bbreg(hw,
+							      0xeb4,
+							      MASKDWORD) &
+						0x3FF0000) >> 16;
 				result[t][5] =
 				    (rtl_get_bbreg(hw, 0xebc, MASKDWORD) &
 				     0x3FF0000) >> 16;
@@ -1141,9 +1269,10 @@ static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
 				     0x3FF0000) >> 16;
 				break;
 			} else if (i == (retrycount - 1) && pathb_ok == 0x01) {
-				result[t][4] =
-				    (rtl_get_bbreg(hw, 0xeb4, MASKDWORD) &
-				     0x3FF0000) >> 16;
+				result[t][4] = (rtl_get_bbreg(hw,
+							      0xeb4,
+							      MASKDWORD) &
+						0x3FF0000) >> 16;
 			}
 			result[t][5] = (rtl_get_bbreg(hw, 0xebc, MASKDWORD) &
 					0x3FF0000) >> 16;
@@ -1166,11 +1295,11 @@ static void _rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw,
 	}
 }
 
-static void _rtl8723ae_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
+static void _rtl8723e_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmpreg;
 	u32 rf_a_mode = 0, rf_b_mode = 0, lc_cal;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	tmpreg = rtl_read_byte(rtlpriv, 0xd03);
 
@@ -1211,14 +1340,14 @@ static void _rtl8723ae_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
 	}
 }
 
-static void _rtl8723ae_phy_set_rfpath_switch(struct ieee80211_hw *hw,
-					     bool bmain, bool is2t)
+static void _rtl8723e_phy_set_rfpath_switch(struct ieee80211_hw *hw,
+					    bool bmain, bool is2t)
 {
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	if (is_hal_stop(rtlhal)) {
 		rtl_set_bbreg(hw, REG_LEDCFG0, BIT(23), 0x01);
-		rtl_set_bbreg(hw, rFPGA0_XAB_RFPARAMETER, BIT(13), 0x01);
+		rtl_set_bbreg(hw, RFPGA0_XAB_RFPARAMETER, BIT(13), 0x01);
 	}
 	if (is2t) {
 		if (bmain)
@@ -1234,21 +1363,23 @@ static void _rtl8723ae_phy_set_rfpath_switch(struct ieee80211_hw *hw,
 			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE, 0x300, 0x1);
 
 	}
+
 }
 
 #undef IQK_ADDA_REG_NUM
 #undef IQK_DELAY_TIME
 
-void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
+void rtl8723e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+
 	long result[4][8];
 	u8 i, final_candidate;
-	bool patha_ok, pathb_ok;
-	long reg_e94, reg_e9c, reg_ea4, reg_eb4, reg_ebc, reg_tmp = 0;
+	bool b_patha_ok, b_pathb_ok;
+	long reg_e94, reg_e9c, reg_ea4, reg_eac, reg_eb4, reg_ebc, reg_ec4,
+	    reg_ecc, reg_tmp = 0;
 	bool is12simular, is13simular, is23simular;
-	bool start_conttx = false, singletone = false;
 	u32 iqk_bb_reg[10] = {
 		ROFDM0_XARXIQIMBALANCE,
 		ROFDM0_XBRXIQIMBALANCE,
@@ -1262,13 +1393,12 @@ void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		ROFDM0_RXIQEXTANTA
 	};
 
-	if (recovery) {
-		rtl8723_phy_reload_adda_registers(hw, iqk_bb_reg,
+	if (b_recovery) {
+		rtl8723_phy_reload_adda_registers(hw,
+						  iqk_bb_reg,
 						  rtlphy->iqk_bb_backup, 10);
 		return;
 	}
-	if (start_conttx || singletone)
-		return;
 	for (i = 0; i < 8; i++) {
 		result[0][i] = 0;
 		result[1][i] = 0;
@@ -1276,30 +1406,33 @@ void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
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
-		_rtl8723ae_phy_iq_calibrate(hw, result, i, false);
+		_rtl8723e_phy_iq_calibrate(hw, result, i, false);
 		if (i == 1) {
-			is12simular = phy_simularity_comp(hw, result, 0, 1);
+			is12simular =
+			  _rtl8723e_phy_simularity_compare(hw, result, 0, 1);
 			if (is12simular) {
 				final_candidate = 0;
 				break;
 			}
 		}
 		if (i == 2) {
-			is13simular = phy_simularity_comp(hw, result, 0, 2);
+			is13simular =
+			  _rtl8723e_phy_simularity_compare(hw, result, 0, 2);
 			if (is13simular) {
 				final_candidate = 0;
 				break;
 			}
-			is23simular = phy_simularity_comp(hw, result, 1, 2);
-			if (is23simular) {
+			is23simular =
+			  _rtl8723e_phy_simularity_compare(hw, result, 1, 2);
+			if (is23simular)
 				final_candidate = 1;
-			} else {
+			else {
 				for (i = 0; i < 8; i++)
 					reg_tmp += result[3][i];
 
@@ -1314,50 +1447,54 @@ void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery)
 		reg_e94 = result[i][0];
 		reg_e9c = result[i][1];
 		reg_ea4 = result[i][2];
+		reg_eac = result[i][3];
 		reg_eb4 = result[i][4];
 		reg_ebc = result[i][5];
+		reg_ec4 = result[i][6];
+		reg_ecc = result[i][7];
 	}
 	if (final_candidate != 0xff) {
 		rtlphy->reg_e94 = reg_e94 = result[final_candidate][0];
 		rtlphy->reg_e9c = reg_e9c = result[final_candidate][1];
 		reg_ea4 = result[final_candidate][2];
+		reg_eac = result[final_candidate][3];
 		rtlphy->reg_eb4 = reg_eb4 = result[final_candidate][4];
 		rtlphy->reg_ebc = reg_ebc = result[final_candidate][5];
-		patha_ok = pathb_ok = true;
+		reg_ec4 = result[final_candidate][6];
+		reg_ecc = result[final_candidate][7];
+		b_patha_ok = true;
+		b_pathb_ok = true;
 	} else {
 		rtlphy->reg_e94 = rtlphy->reg_eb4 = 0x100;
 		rtlphy->reg_e9c = rtlphy->reg_ebc = 0x0;
 	}
-	if (reg_e94 != 0) /*&&(reg_ea4 != 0) */
-		rtl8723_phy_path_a_fill_iqk_matrix(hw, patha_ok, result,
+	if (reg_e94 != 0)
+		rtl8723_phy_path_a_fill_iqk_matrix(hw, b_patha_ok, result,
 						   final_candidate,
 						   (reg_ea4 == 0));
-	rtl8723_save_adda_registers(hw, iqk_bb_reg, rtlphy->iqk_bb_backup, 10);
+	rtl8723_phy_save_adda_registers(hw, iqk_bb_reg,
+					rtlphy->iqk_bb_backup, 10);
 }
 
-void rtl8723ae_phy_lc_calibrate(struct ieee80211_hw *hw)
+void rtl8723e_phy_lc_calibrate(struct ieee80211_hw *hw)
 {
-	bool start_conttx = false, singletone = false;
-
-	if (start_conttx || singletone)
-		return;
-	_rtl8723ae_phy_lc_calibrate(hw, false);
+	_rtl8723e_phy_lc_calibrate(hw, false);
 }
 
-void rtl8723ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain)
+void rtl8723e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain)
 {
-	_rtl8723ae_phy_set_rfpath_switch(hw, bmain, false);
+	_rtl8723e_phy_set_rfpath_switch(hw, bmain, false);
 }
 
-bool rtl8723ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
+bool rtl8723e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
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
@@ -1365,13 +1502,13 @@ bool rtl8723ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
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
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 				 "switch case not process\n");
 			break;
 		}
@@ -1382,42 +1519,42 @@ bool rtl8723ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 	} else {
 		return false;
 	}
-	rtl8723ae_phy_set_io(hw);
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<--IO Type(%#x)\n", iotype);
+	rtl8723e_phy_set_io(hw);
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "IO Type(%#x)\n", iotype);
 	return true;
 }
 
-static void rtl8723ae_phy_set_io(struct ieee80211_hw *hw)
+static void rtl8723e_phy_set_io(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
 		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
-		 rtlphy->current_io_type, rtlphy->set_io_inprogress);
+		  rtlphy->current_io_type, rtlphy->set_io_inprogress);
 	switch (rtlphy->current_io_type) {
 	case IO_CMD_RESUME_DM_BY_SCAN:
 		dm_digtable->cur_igvalue = rtlphy->initgain_backup.xaagccore1;
-		rtl8723ae_dm_write_dig(hw);
-		rtl8723ae_phy_set_txpower_level(hw, rtlphy->current_channel);
+		rtl8723e_dm_write_dig(hw);
+		rtl8723e_phy_set_txpower_level(hw, rtlphy->current_channel);
 		break;
-	case IO_CMD_PAUSE_DM_BY_SCAN:
+	case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
 		rtlphy->initgain_backup.xaagccore1 = dm_digtable->cur_igvalue;
 		dm_digtable->cur_igvalue = 0x17;
-		rtl8723ae_dm_write_dig(hw);
+		rtl8723e_dm_write_dig(hw);
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "switch case not process\n");
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 "<---(%#x)\n", rtlphy->current_io_type);
+		 "(%#x)\n", rtlphy->current_io_type);
 }
 
-static void rtl8723ae_phy_set_rf_on(struct ieee80211_hw *hw)
+static void rtl8723e_phy_set_rf_on(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
@@ -1429,11 +1566,11 @@ static void rtl8723ae_phy_set_rf_on(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 }
 
-static void _rtl8723ae_phy_set_rf_sleep(struct ieee80211_hw *hw)
+static void _rtl8723e_phy_set_rf_sleep(struct ieee80211_hw *hw)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 u4b_tmp;
 	u8 delay = 5;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0xFF);
 	rtl_set_rfreg(hw, RF90_PATH_A, 0x00, RFREG_OFFSET_MASK, 0x00);
@@ -1459,45 +1596,47 @@ static void _rtl8723ae_phy_set_rf_sleep(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x22);
 }
 
-static bool _rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
-					      enum rf_pwrstate rfpwr_state)
+static bool _rtl8723e_phy_set_rf_power_state(struct ieee80211_hw *hw,
+					     enum rf_pwrstate rfpwr_state)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	struct rtl8192_tx_ring *ring = NULL;
 	bool bresult = true;
 	u8 i, queue_id;
+	struct rtl8192_tx_ring *ring = NULL;
 
 	switch (rfpwr_state) {
 	case ERFON:
 		if ((ppsc->rfpwr_state == ERFOFF) &&
 		    RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC)) {
 			bool rtstatus;
-			u32 InitializeCount = 0;
+			u32 initializecount = 0;
+
 			do {
-				InitializeCount++;
+				initializecount++;
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
-			} while ((rtstatus != true) && (InitializeCount < 10));
+			} while (!rtstatus && (initializecount < 10));
 			RT_CLEAR_PS_LEVEL(ppsc,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 				 "Set ERFON sleeped:%d ms\n",
-				 jiffies_to_msecs(jiffies -
-				 ppsc->last_sleep_jiffies));
+				  jiffies_to_msecs(jiffies -
+						   ppsc->
+						   last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
-			rtl8723ae_phy_set_rf_on(hw);
+			rtl8723e_phy_set_rf_on(hw);
 		}
 		if (mac->link_state == MAC80211_LINKED) {
 			rtlpriv->cfg->ops->led_control(hw,
-					LED_CTL_LINK);
+						       LED_CTL_LINK);
 		} else {
 			rtlpriv->cfg->ops->led_control(hw,
-					LED_CTL_NO_LINK);
+						       LED_CTL_NO_LINK);
 		}
 		break;
 	case ERFOFF:
@@ -1509,10 +1648,10 @@ static bool _rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		} else {
 			if (ppsc->rfoff_reason == RF_CHANGE_BY_IPS) {
 				rtlpriv->cfg->ops->led_control(hw,
-					LED_CTL_NO_LINK);
+						LED_CTL_NO_LINK);
 			} else {
 				rtlpriv->cfg->ops->led_control(hw,
-					LED_CTL_POWER_OFF);
+						LED_CTL_POWER_OFF);
 			}
 		}
 		break;
@@ -1522,7 +1661,8 @@ static bool _rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
 		for (queue_id = 0, i = 0;
 		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
 			ring = &pcipriv->dev.tx_ring[queue_id];
-			if (skb_queue_len(&ring->queue) == 0) {
+			if (queue_id == BEACON_QUEUE ||
+			    skb_queue_len(&ring->queue) == 0) {
 				queue_id++;
 				continue;
 			} else {
@@ -1536,22 +1676,23 @@ static bool _rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
 			}
 			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 "\n ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
-					 MAX_DOZE_WAITING_TIMES_9x,
-					 queue_id,
-					 skb_queue_len(&ring->queue));
+					 "ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+					  MAX_DOZE_WAITING_TIMES_9x,
+					  queue_id,
+					  skb_queue_len(&ring->queue));
 				break;
 			}
 		}
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
 			 "Set ERFSLEEP awaked:%d ms\n",
-			 jiffies_to_msecs(jiffies - ppsc->last_awake_jiffies));
+			  jiffies_to_msecs(jiffies -
+					   ppsc->last_awake_jiffies));
 		ppsc->last_sleep_jiffies = jiffies;
-		_rtl8723ae_phy_set_rf_sleep(hw);
+		_rtl8723e_phy_set_rf_sleep(hw);
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "switch case not processed\n");
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
 		bresult = false;
 		break;
 	}
@@ -1560,14 +1701,15 @@ static bool _rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
 	return bresult;
 }
 
-bool rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
-				      enum rf_pwrstate rfpwr_state)
+bool rtl8723e_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				     enum rf_pwrstate rfpwr_state)
 {
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+
 	bool bresult = false;
 
 	if (rfpwr_state == ppsc->rfpwr_state)
 		return bresult;
-	bresult = _rtl8723ae_phy_set_rf_power_state(hw, rfpwr_state);
+	bresult = _rtl8723e_phy_set_rf_power_state(hw, rfpwr_state);
 	return bresult;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
index cd43139..b85f5c7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
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
@@ -39,6 +35,7 @@
 #define RT_CANNOT_IO(hw)			false
 #define HIGHPOWER_RADIOA_ARRAYLEN		22
 
+#define IQK_ADDA_REG_NUM			16
 #define MAX_TOLERANCE				5
 #define	IQK_DELAY_TIME				1
 
@@ -49,12 +46,15 @@
 
 #define LOOP_LIMIT				5
 #define MAX_STALL_TIME				50
-#define AntennaDiversityValue			0x80
+#define ANTENNADIVERSITYVALUE			0x80
 #define MAX_TXPWR_IDX_NMODE_92S			63
 #define Reset_Cnt_Limit				3
 
+#define IQK_ADDA_REG_NUM			16
 #define IQK_MAC_REG_NUM				4
 
+#define IQK_DELAY_TIME				1
+
 #define RF6052_MAX_PATH				2
 
 #define CT_OFFSET_MAC_ADDR			0X16
@@ -166,36 +166,37 @@ struct tx_power_struct {
 	u32 mcs_original_offset[4][16];
 };
 
-u32 rtl8723ae_phy_query_rf_reg(struct ieee80211_hw *hw,
-			       enum radio_path rfpath, u32 regaddr,
-			       u32 bitmask);
-void rtl8723ae_phy_set_rf_reg(struct ieee80211_hw *hw,
+u32 rtl8723e_phy_query_rf_reg(struct ieee80211_hw *hw,
 			      enum radio_path rfpath, u32 regaddr,
-			      u32 bitmask, u32 data);
-bool rtl8723ae_phy_mac_config(struct ieee80211_hw *hw);
-bool rtl8723ae_phy_bb_config(struct ieee80211_hw *hw);
-bool rtl8723ae_phy_rf_config(struct ieee80211_hw *hw);
+			      u32 bitmask);
+void rtl8723e_phy_set_rf_reg(struct ieee80211_hw *hw,
+			     enum radio_path rfpath, u32 regaddr,
+			     u32 bitmask, u32 data);
+bool rtl8723e_phy_mac_config(struct ieee80211_hw *hw);
+bool rtl8723e_phy_bb_config(struct ieee80211_hw *hw);
+bool rtl8723e_phy_rf_config(struct ieee80211_hw *hw);
 bool rtl92c_phy_config_rf_with_feaderfile(struct ieee80211_hw *hw,
 					  enum radio_path rfpath);
-void rtl8723ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
-void rtl8723ae_phy_get_txpower_level(struct ieee80211_hw *hw,
-				     long *powerlevel);
-void rtl8723ae_phy_set_txpower_level(struct ieee80211_hw *hw,
-				     u8 channel);
-bool rtl8723ae_phy_update_txpower_dbm(struct ieee80211_hw *hw,
-				      long power_indbm);
-void rtl8723ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
-void rtl8723ae_phy_set_bw_mode(struct ieee80211_hw *hw,
-			       enum nl80211_channel_type ch_type);
-void rtl8723ae_phy_sw_chnl_callback(struct ieee80211_hw *hw);
-u8 rtl8723ae_phy_sw_chnl(struct ieee80211_hw *hw);
-void rtl8723ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool recovery);
-void rtl8723ae_phy_lc_calibrate(struct ieee80211_hw *hw);
-void rtl8723ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
-bool rtl8723ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
-					     enum radio_path rfpath);
-bool rtl8723ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
-bool rtl8723ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
-				      enum rf_pwrstate rfpwr_state);
+void rtl8723e_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
+void rtl8723e_phy_get_txpower_level(struct ieee80211_hw *hw,
+				    long *powerlevel);
+void rtl8723e_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
+bool rtl8723e_phy_update_txpower_dbm(struct ieee80211_hw *hw,
+				     long power_indbm);
+void rtl8723e_phy_scan_operation_backup(struct ieee80211_hw *hw,
+					u8 operation);
+void rtl8723e_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+void rtl8723e_phy_set_bw_mode(struct ieee80211_hw *hw,
+			      enum nl80211_channel_type ch_type);
+void rtl8723e_phy_sw_chnl_callback(struct ieee80211_hw *hw);
+u8 rtl8723e_phy_sw_chnl(struct ieee80211_hw *hw);
+void rtl8723e_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
+void rtl8723e_phy_lc_calibrate(struct ieee80211_hw *hw);
+void rtl8723e_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
+bool rtl8723e_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+					    enum radio_path rfpath);
+bool rtl8723e_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
+bool rtl8723e_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				     enum rf_pwrstate rfpwr_state);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
index f907d7f..2f7f81a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
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
@@ -30,80 +26,87 @@
 #include "../pwrseqcmd.h"
 #include "pwrseq.h"
 
-/* drivers should parse arrays below and do the corresponding actions */
-
+/* drivers should parse below arrays and do the corresponding actions */
 /*3 Power on  Array*/
-struct wlan_pwr_cfg rtl8723A_power_on_flow[RTL8723A_TRANS_CARDEMU_TO_ACT_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_CARDEMU_TO_ACT,
+struct wlan_pwr_cfg rtl8723A_power_on_flow
+		[RTL8723A_TRANS_CARDEMU_TO_ACT_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_CARDEMU_TO_ACT
 	RTL8723A_TRANS_END
 };
 
 /*3Radio off GPIO Array */
-struct wlan_pwr_cfg rtl8723A_radio_off_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_ACT_TO_CARDEMU,
+struct wlan_pwr_cfg rtl8723A_radio_off_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
 	RTL8723A_TRANS_END
 };
 
 /*3Card Disable Array*/
-struct wlan_pwr_cfg
-rtl8723A_card_disable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-			  + RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
-			  + RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_ACT_TO_CARDEMU,
-	RTL8723A_TRANS_CARDEMU_TO_CARDDIS,
+struct wlan_pwr_cfg rtl8723A_card_disable_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_CARDDIS
 	RTL8723A_TRANS_END
 };
 
 /*3 Card Enable Array*/
-struct wlan_pwr_cfg rtl8723A_card_enable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-					+ RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_CARDDIS_TO_CARDEMU,
-	RTL8723A_TRANS_CARDEMU_TO_ACT,
+struct wlan_pwr_cfg rtl8723A_card_enable_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_CARDDIS_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_ACT
 	RTL8723A_TRANS_END
 };
 
 /*3Suspend Array*/
-struct wlan_pwr_cfg rtl8723A_suspend_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-					+ RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_ACT_TO_CARDEMU,
-	RTL8723A_TRANS_CARDEMU_TO_SUS,
+struct wlan_pwr_cfg rtl8723A_suspend_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_SUS
 	RTL8723A_TRANS_END
 };
 
 /*3 Resume Array*/
-struct wlan_pwr_cfg rtl8723A_resume_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-					+ RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_SUS_TO_CARDEMU,
-	RTL8723A_TRANS_CARDEMU_TO_ACT,
+struct wlan_pwr_cfg rtl8723A_resume_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_SUS_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_ACT
 	RTL8723A_TRANS_END
 };
 
 /*3HWPDN Array*/
-struct wlan_pwr_cfg rtl8723A_hwpdn_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-				+ RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
-				+ RTL8723A_TRANS_END_STPS] = {
-	RTL8723A_TRANS_ACT_TO_CARDEMU,
-	RTL8723A_TRANS_CARDEMU_TO_PDN,
+struct wlan_pwr_cfg rtl8723A_hwpdn_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_PDN
 	RTL8723A_TRANS_END
 };
 
 /*3 Enter LPS */
-struct wlan_pwr_cfg rtl8723A_enter_lps_flow[RTL8723A_TRANS_ACT_TO_LPS_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
+struct wlan_pwr_cfg rtl8723A_enter_lps_flow
+		[RTL8723A_TRANS_ACT_TO_LPS_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
 	/*FW behavior*/
-	RTL8723A_TRANS_ACT_TO_LPS,
+	RTL8723A_TRANS_ACT_TO_LPS
 	RTL8723A_TRANS_END
 };
 
 /*3 Leave LPS */
-struct wlan_pwr_cfg rtl8723A_leave_lps_flow[RTL8723A_TRANS_LPS_TO_ACT_STPS
-					+ RTL8723A_TRANS_END_STPS] = {
+struct wlan_pwr_cfg rtl8723A_leave_lps_flow
+		[RTL8723A_TRANS_LPS_TO_ACT_STEPS +
+		 RTL8723A_TRANS_END_STEPS] = {
 	/*FW behavior*/
-	RTL8723A_TRANS_LPS_TO_ACT,
+	RTL8723A_TRANS_LPS_TO_ACT
 	RTL8723A_TRANS_END
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
index a418acb..4ac7db5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
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
@@ -30,282 +26,305 @@
 #ifndef __RTL8723E_PWRSEQ_H__
 #define __RTL8723E_PWRSEQ_H__
 
+#include "../pwrseqcmd.h"
 /*
-	Check document WM-20110607-Paul-RTL8723A_Power_Architecture-R02.vsd
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
+ *	Check document WM-20110607-Paul-RTL8723A_Power_Architecture-R02.vsd
+ *	There are 6 HW Power States:
+ *	0: POFF--Power Off
+ *	1: PDN--Power Down
+ *	2: CARDEMU--Card Emulation
+ *	3: ACT--Active Mode
+ *	4: LPS--Low Power State
+ *	5: SUS--Suspend
+ *
+ *	The transision from different states are defined below
+ *	TRANS_CARDEMU_TO_ACT
+ *	TRANS_ACT_TO_CARDEMU
+ *	TRANS_CARDEMU_TO_SUS
+ *	TRANS_SUS_TO_CARDEMU
+ *	TRANS_CARDEMU_TO_PDN
+ *	TRANS_ACT_TO_LPS
+ *	TRANS_LPS_TO_ACT
+ *
+ *	TRANS_END
+ */
 
-	TRANS_END
-*/
+#define	RTL8723A_TRANS_CARDEMU_TO_ACT_STEPS	10
+#define	RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS	10
+#define	RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS	10
+#define	RTL8723A_TRANS_SUS_TO_CARDEMU_STEPS	10
+#define	RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS	10
+#define	RTL8723A_TRANS_PDN_TO_CARDEMU_STEPS	10
+#define	RTL8723A_TRANS_ACT_TO_LPS_STEPS		15
+#define	RTL8723A_TRANS_LPS_TO_ACT_STEPS		15
+#define	RTL8723A_TRANS_END_STEPS		1
 
-#define	RTL8723A_TRANS_CARDEMU_TO_ACT_STPS	10
-#define	RTL8723A_TRANS_ACT_TO_CARDEMU_STPS	10
-#define	RTL8723A_TRANS_CARDEMU_TO_SUS_STPS	10
-#define	RTL8723A_TRANS_SUS_TO_CARDEMU_STPS	10
-#define	RTL8723A_TRANS_CARDEMU_TO_PDN_STPS	10
-#define	RTL8723A_TRANS_PDN_TO_CARDEMU_STPS	10
-#define	RTL8723A_TRANS_ACT_TO_LPS_STPS		15
-#define	RTL8723A_TRANS_LPS_TO_ACT_STPS		15
-#define	RTL8723A_TRANS_END_STPS			1
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }*/
 
+#define RTL8723A_TRANS_CARDEMU_TO_ACT	\
+	/* disable SW LPS 0x04[10]=0*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), 0},\
+	/* wait till 0x04[17] = 1    power ready*/	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)},\
+	/* release WLON reset  0x04[16]=1*/	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},\
+	/* disable HWPDN 0x04[15]=0*/ \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},\
+	/* disable WL suspend*/ \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)), 0},\
+	/* polling until return 0*/ \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0},
 
-#define RTL8723A_TRANS_CARDEMU_TO_ACT					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, \
-	 *  comments here*/						\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), 0},		\
-		/* disable SW LPS 0x04[10]=0*/				\
-	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)},	\
-		/* wait till 0x04[17] = 1    power ready*/		\
-	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},	\
-		/* release WLON reset  0x04[16]=1*/			\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},		\
-		/* disable HWPDN 0x04[15]=0*/				\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)), 0},	\
-	/* disable WL suspend*/						\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},	\
-		/* polling until return 0*/				\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0}
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
 
-#define RTL8723A_TRANS_ACT_TO_CARDEMU					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, \
-	 *  comments here*/						\
-	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},		\
-		/*0x1F[7:0] = 0 turn off RF*/				\
-	{0x004E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},		\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},	\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0}
+#define RTL8723A_TRANS_ACT_TO_CARDEMU	\
+	/*0x1F[7:0] = 0 turn off RF*/ \
+	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},	\
+	{0x004E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)}, \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0},
 
-#define RTL8723A_TRANS_CARDEMU_TO_SUS					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, \
-	 *  comments here*/						\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4)|BIT(3),		\
-		(BIT(4)|BIT(3))},					\
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/
+#define RTL8723A_TRANS_CARDEMU_TO_SUS			\
 		/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/	\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK |	\
-		PWR_INTF_SDIO_MSK,					\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},\
-		 /*0x04[12:11] = 2b'01 enable WL suspend*/		\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-		PWR_BASEADDR_MAC,					\
-		PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)|BIT(4)},		\
-		 /*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/	\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO,					\
-		PWR_CMD_WRITE, BIT(0), BIT(0)},				\
-		/*Set SDIO suspend local register*/			\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO,					\
-		PWR_CMD_POLLING, BIT(1), 0}				\
-		/*wait power state to suspend*/
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, \
+		BIT(4)|BIT(3), (BIT(4)|BIT(3))},\
+/*0x04[12:11] = 2b'01 enable WL suspend*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK| \
+		PWR_INTF_SDIO_MSK,\
+		PWR_BASEADDR_MAC, \
+		PWR_CMD_WRITE, \
+		BIT(3)|BIT(4), BIT(3)}, \
+/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/ \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_PCI_MSK, PWR_BASEADDR_MAC, \
+		PWR_CMD_WRITE, BIT(3)|BIT(4), \
+		BIT(3)|BIT(4)}, \
+/*Set SDIO suspend local register*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_WRITE, BIT(0), BIT(0)}, \
+/*wait power state to suspend*/ \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_POLLING, BIT(1), 0},
+
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
+
+#define RTL8723A_TRANS_SUS_TO_CARDEMU	\
+ /*Set SDIO suspend local register*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},\
+ /*wait power state to suspend*/ \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},\
+ /*0x04[12:11] = 2b'01enable WL suspend*/ \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},
+
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
+
+#define RTL8723A_TRANS_CARDEMU_TO_CARDDIS \
+ /*0x04[12:11] = 2b'01 enable WL suspend*/	 \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK, \
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)}, \
+/*0x04[10] = 1, enable SW LPS*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_PCI_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(2), BIT(2)}, \
+/*Set SDIO suspend local register*/ \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_WRITE, BIT(0), BIT(0)}, \
+ /*wait power state to suspend*/ \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_POLLING, BIT(1), 0},
+
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
 
-#define RTL8723A_TRANS_SUS_TO_CARDEMU					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},		\
-		/*Set SDIO suspend local register*/			\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},	\
-		/*wait power state to suspend*/				\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0}	\
-		/*0x04[12:11] = 2b'01enable WL suspend*/
+#define RTL8723A_TRANS_CARDDIS_TO_CARDEMU\
+/*Set SDIO suspend local register*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_WRITE, BIT(0), 0}, \
+ /*wait power state to suspend*/ \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_POLLING, BIT(1), BIT(1)},\
+ /*0x04[12:11] = 2b'00enable WL suspend*/ \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(3)|BIT(4), 0},\
+/*PCIe DMA start*/ \
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0},
 
-#define RTL8723A_TRANS_CARDEMU_TO_CARDDIS				\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
-	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},\
-		/*0x04[12:11] = 2b'01 enable WL suspend*/		\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), BIT(2)},	\
-		/*0x04[10] = 1, enable SW LPS*/				\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},	\
-		/*Set SDIO suspend local register*/			\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0}		\
-		/*wait power state to suspend*/
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
+#define RTL8723A_TRANS_CARDEMU_TO_PDN	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(0), 0},/* 0x04[16] = 0*/\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(7), BIT(7)},/* 0x04[15] = 1*/
 
-#define RTL8723A_TRANS_CARDDIS_TO_CARDEMU				\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},		\
-		/*Set SDIO suspend local register*/			\
-	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},	\
-		/*wait power state to suspend*/				\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},	\
-		/*0x04[12:11] = 2b'00enable WL suspend*/		\
-	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0}		\
-		/*PCIe DMA start*/
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
+#define RTL8723A_TRANS_PDN_TO_CARDEMU	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(7), 0},/* 0x04[15] = 0*/
 
-#define RTL8723A_TRANS_CARDEMU_TO_PDN					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},		\
-		/* 0x04[16] = 0*/\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)}	\
-		/* 0x04[15] = 1*/
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
 
-#define RTL8723A_TRANS_PDN_TO_CARDEMU					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0}		\
-		/* 0x04[15] = 0*/
+#define RTL8723A_TRANS_ACT_TO_LPS	\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0xFF},/*PCIe DMA stop*/	\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0x7F},/*Tx Pause*/	\
+	/*Should be zero if no packet is transmitting*/	\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_POLLING, 0xFF, 0},\
+	/*Should be zero if no packet is transmitting*/	\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_POLLING, 0xFF, 0},\
+	/*Should be zero if no packet is transmitting*/	\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_POLLING, 0xFF, 0},\
+	/*Should be zero if no packet is transmitting*/	\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_POLLING, 0xFF, 0},\
+	/*CCK and OFDM are disabled,and clock are gated*/ \
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(0), 0},\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},/*Delay 1us*/\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(1), 0},/*Whole BB is reset*/	\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0x3F},/*Reset MAC TRX*/	\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(1), 0},/*check if removed later*/	\
+	/*Respond TxOK to scheduler*/	\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(5), BIT(5)},\
 
-#define RTL8723A_TRANS_ACT_TO_LPS					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},		\
-		/*PCIe DMA stop*/					\
-	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x7F},		\
-		/*Tx Pause*/						\
-	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
-		/*Should be zero if no packet is transmitting*/		\
-	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
-		/*Should be zero if no packet is transmitting*/		\
-	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
-		/*Should be zero if no packet is transmitting*/		\
-	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
-		/*Should be zero if no packet is transmitting*/		\
-	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},		\
-		/*CCK and OFDM are disabled,and clock are gated*/	\
-	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},	\
-		/*Delay 1us*/						\
-	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},		\
-		/*Whole BB is reset*/					\
-	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x3F},		\
-		/*Reset MAC TRX*/					\
-	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},		\
-		/*check if removed later*/				\
-	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), BIT(5)}	\
-		/*Respond TxOK to scheduler*/
+#define RTL8723A_TRANS_LPS_TO_ACT\
+/* format */	\
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */	\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_SDIO_MSK, PWR_BASEADDR_SDIO,\
+		PWR_CMD_WRITE, 0xFF, 0x84}, /*SDIO RPWM*/\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_USB_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0x84}, /*USB RPWM*/\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_PCI_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0x84}, /*PCIe RPWM*/\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS}, /*Delay*/\
+	/*.	0x08[4] = 0		 switch TSF to 40M*/\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(4), 0},  \
+	/*Polling 0x109[7]=0  TSF in 40M*/\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_POLLING, BIT(7), 0}, \
+	/*.	0x29[7:6] = 2b'00	 enable BB clock*/\
+	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(6)|BIT(7), 0},\
+	 /*.	0x101[1] = 1*/\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(1), BIT(1)},\
+	 /*.	0x100[7:0] = 0xFF	 enable WMAC TRX*/\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0xFF},\
+	 /*.	0x02[1:0] = 2b'11	 enable BB macro*/\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, BIT(1)|BIT(0), BIT(1)|BIT(0)},\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, \
+		PWR_INTF_ALL_MSK, PWR_BASEADDR_MAC,\
+		PWR_CMD_WRITE, 0xFF, 0}, /*.	0x522 = 0*/
 
-#define RTL8723A_TRANS_LPS_TO_ACT					\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
-		 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84},		\
-		 /*SDIO RPWM*/						\
-	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84},		\
-		/*USB RPWM*/						\
-	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84},		\
-		/*PCIe RPWM*/						\
-	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS},	\
-		/*Delay*/						\
-	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},		\
-		/* 0x08[4] = 0 switch TSF to 40M*/			\
-	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0},		\
-		/*Polling 0x109[7]=0  TSF in 40M*/			\
-	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6)|BIT(7), 0},	\
-		/*.	0x29[7:6] = 2b'00	 enable BB clock*/	\
-	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},	\
-		/*.	0x101[1] = 1*/					\
-	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},		\
-		/* 0x100[7:0] = 0xFF enable WMAC TRX*/			\
-	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1)|BIT(0),		\
-		BIT(1)|BIT(0)},						\
-		/* 0x02[1:0] = 2b'11  enable BB macro*/			\
-	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
-		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0}		\
-		/*.	0x522 = 0*/
+/* format */
+/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */
 
-#define RTL8723A_TRANS_END						\
-	/* format */							\
-	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
-	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+#define RTL8723A_TRANS_END \
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
 	0, PWR_CMD_END, 0, 0}
 
-extern struct
-wlan_pwr_cfg rtl8723A_power_on_flow[RTL8723A_TRANS_CARDEMU_TO_ACT_STPS
-				    + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_radio_off_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-				     + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_card_disable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-					+ RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
-					+ RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_card_enable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-				       + RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
-				       + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_suspend_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-				   + RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
-				   + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_resume_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-				  + RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
-				  + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_hwpdn_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
-				 + RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
-				 + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_enter_lps_flow[RTL8723A_TRANS_ACT_TO_LPS_STPS
-				     + RTL8723A_TRANS_END_STPS];
-extern struct
-wlan_pwr_cfg rtl8723A_leave_lps_flow[RTL8723A_TRANS_LPS_TO_ACT_STPS
-				     + RTL8723A_TRANS_END_STPS];
+extern struct wlan_pwr_cfg rtl8723A_power_on_flow
+		[RTL8723A_TRANS_CARDEMU_TO_ACT_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_radio_off_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_card_disable_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_card_enable_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_suspend_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_resume_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_hwpdn_flow
+		[RTL8723A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8723A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_enter_lps_flow
+		[RTL8723A_TRANS_ACT_TO_LPS_STEPS + RTL8723A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723A_leave_lps_flow
+		[RTL8723A_TRANS_LPS_TO_ACT_STEPS + RTL8723A_TRANS_END_STEPS];
 
 /* RTL8723 Power Configuration CMDs for PCIe interface */
 #define Rtl8723_NIC_PWR_ON_FLOW		rtl8723A_power_on_flow
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h b/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
index ce2c66f..306059f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
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
@@ -34,13 +30,13 @@
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
@@ -57,12 +53,12 @@
 #define REG_MAC_PINMUX_CFG			0x0043
 #define REG_GPIO_PIN_CTRL			0x0044
 #define REG_GPIO_INTM				0x0048
-#define REG_LEDCFG0				0x004C
-#define REG_LEDCFG1				0x004D
-#define REG_LEDCFG2				0x004E
-#define REG_LEDCFG3				0x004F
-#define REG_FSIMR				0x0050
-#define REG_FSISR				0x0054
+#define REG_LEDCFG0					0x004C
+#define REG_LEDCFG1					0x004D
+#define REG_LEDCFG2					0x004E
+#define REG_LEDCFG3					0x004F
+#define REG_FSIMR					0x0050
+#define REG_FSISR					0x0054
 #define REG_GPIO_PIN_CTRL_2			0x0060
 #define REG_GPIO_IO_SEL_2			0x0062
 #define REG_MULTI_FUNC_CTRL			0x0068
@@ -80,25 +76,25 @@
 #define REG_USB_SIE_INTF			0x00E0
 #define REG_PCIE_MIO_INTF			0x00E4
 #define REG_PCIE_MIO_INTD			0x00E8
-#define REG_SYS_CFG				0x00F0
+#define REG_SYS_CFG					0x00F0
 #define REG_GPIO_OUTSTS				0x00F4
 
-#define REG_CR					0x0100
-#define REG_PBP					0x0104
+#define REG_CR						0x0100
+#define REG_PBP						0x0104
 #define REG_TRXDMA_CTRL				0x010C
 #define REG_TRXFF_BNDY				0x0114
 #define REG_TRXFF_STATUS			0x0118
 #define REG_RXFF_PTR				0x011C
-#define REG_HIMR				0x0120
-#define REG_HISR				0x0124
-#define REG_HIMRE				0x0128
-#define REG_HISRE				0x012C
-#define REG_CPWM				0x012F
-#define REG_FWIMR				0x0130
-#define REG_FWISR				0x0134
+#define REG_HIMR					0x0120
+#define REG_HISR					0x0124
+#define REG_HIMRE					0x0128
+#define REG_HISRE					0x012C
+#define REG_CPWM					0x012F
+#define REG_FWIMR					0x0130
+#define REG_FWISR					0x0134
 #define REG_PKTBUF_DBG_CTRL			0x0140
-#define REG_PKTBUF_DBG_DATA_L			0x0144
-#define REG_PKTBUF_DBG_DATA_H			0x0148
+#define REG_PKTBUF_DBG_DATA_L		0x0144
+#define REG_PKTBUF_DBG_DATA_H		0x0148
 
 #define REG_TC0_CTRL				0x0150
 #define REG_TC1_CTRL				0x0154
@@ -109,11 +105,11 @@
 #define REG_MBIST_START				0x0174
 #define REG_MBIST_DONE				0x0178
 #define REG_MBIST_FAIL				0x017C
-#define REG_C2HEVT_MSG_NORMAL			0x01A0
+#define REG_C2HEVT_MSG_NORMAL		0x01A0
 #define REG_C2HEVT_MSG_TEST			0x01B8
 #define REG_MCUTST_1				0x01c0
-#define REG_FMETHR				0x01C8
-#define REG_HMETFR				0x01CC
+#define REG_FMETHR					0x01C8
+#define REG_HMETFR					0x01CC
 #define REG_HMEBOX_0				0x01D0
 #define REG_HMEBOX_1				0x01D4
 #define REG_HMEBOX_2				0x01D8
@@ -123,10 +119,10 @@
 #define REG_BB_ACCEESS_CTRL			0x01E8
 #define REG_BB_ACCESS_DATA			0x01EC
 
-#define REG_RQPN				0x0200
+#define REG_RQPN					0x0200
 #define REG_FIFOPAGE				0x0204
-#define REG_TDECTRL				0x0208
-#define REG_TXDMA_OFFSET_CHK			0x020C
+#define REG_TDECTRL					0x0208
+#define REG_TXDMA_OFFSET_CHK		0x020C
 #define REG_TXDMA_STATUS			0x0210
 #define REG_RQPN_NPQ				0x0214
 
@@ -135,18 +131,18 @@
 #define REG_RXDMA_STATUS			0x0288
 
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
-#define	REG_DBI					0x0348
-#define	REG_MDIO				0x0354
-#define	REG_DBG_SEL				0x0360
+#define	REG_RX_DESA					0x0340
+#define	REG_DBI						0x0348
+#define	REG_MDIO					0x0354
+#define	REG_DBG_SEL					0x0360
 #define	REG_PCIE_HRPWM				0x0361
 #define	REG_PCIE_HCPWM				0x0363
 #define	REG_UART_CTRL				0x0364
@@ -162,31 +158,31 @@
 #define REG_BKQ_INFORMATION			0x040C
 #define REG_MGQ_INFORMATION			0x0410
 #define REG_HGQ_INFORMATION			0x0414
-#define REG_BCNQ_INFORMATION			0x0418
+#define REG_BCNQ_INFORMATION		0x0418
 
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
@@ -194,29 +190,29 @@
 #define REG_STBC_SETTING			0x04C4
 #define REG_PROT_MODE_CTRL			0x04C8
 #define REG_BAR_MODE_CTRL			0x04CC
-#define REG_RA_TRY_RATE_AGG_LMT			0x04CF
+#define REG_RA_TRY_RATE_AGG_LMT		0x04CF
 #define REG_NQOS_SEQ				0x04DC
-#define REG_QOS_SEQ				0x04DE
+#define REG_QOS_SEQ					0x04DE
 #define REG_NEED_CPU_HANDLE			0x04E0
 #define REG_PKT_LOSE_RPT			0x04E1
 #define REG_PTCL_ERR_STATUS			0x04E2
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
@@ -225,21 +221,21 @@
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
@@ -248,38 +244,38 @@
 
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
-#define REG_WMAC_TRXPTCL_CTL			0x0668
+#define REG_WMAC_TRXPTCL_CTL		0x0668
 
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
@@ -294,10 +290,10 @@
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
@@ -305,120 +301,148 @@
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
 #define	RATE_ALL_OFDM_AG	(RATR_6M | RATR_9M | RATR_12M | RATR_18M |\
@@ -434,31 +458,31 @@
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
 
 #define	IMR8190_DISABLED			0x0
 #define	IMR_BCNDMAINT6				BIT(31)
@@ -467,180 +491,179 @@
 #define	IMR_BCNDMAINT3				BIT(28)
 #define	IMR_BCNDMAINT2				BIT(27)
 #define	IMR_BCNDMAINT1				BIT(26)
-#define	IMR_BCNDOK8				BIT(25)
-#define	IMR_BCNDOK7				BIT(24)
-#define	IMR_BCNDOK6				BIT(23)
-#define	IMR_BCNDOK5				BIT(22)
-#define	IMR_BCNDOK4				BIT(21)
-#define	IMR_BCNDOK3				BIT(20)
-#define	IMR_BCNDOK2				BIT(19)
-#define	IMR_BCNDOK1				BIT(18)
+#define	IMR_BCNDOK8					BIT(25)
+#define	IMR_BCNDOK7					BIT(24)
+#define	IMR_BCNDOK6					BIT(23)
+#define	IMR_BCNDOK5					BIT(22)
+#define	IMR_BCNDOK4					BIT(21)
+#define	IMR_BCNDOK3					BIT(20)
+#define	IMR_BCNDOK2					BIT(19)
+#define	IMR_BCNDOK1					BIT(18)
 #define	IMR_TIMEOUT2				BIT(17)
 #define	IMR_TIMEOUT1				BIT(16)
-#define	IMR_TXFOVW				BIT(15)
+#define	IMR_TXFOVW					BIT(15)
 #define	IMR_PSTIMEOUT				BIT(14)
-#define	IMR_BCNINT				BIT(13)
-#define	IMR_RXFOVW				BIT(12)
-#define	IMR_RDU					BIT(11)
-#define	IMR_ATIMEND				BIT(10)
-#define	IMR_BDOK				BIT(9)
-#define	IMR_HIGHDOK				BIT(8)
-#define	IMR_TBDOK				BIT(7)
-#define	IMR_MGNTDOK				BIT(6)
-#define	IMR_TBDER				BIT(5)
-#define	IMR_BKDOK				BIT(4)
-#define	IMR_BEDOK				BIT(3)
-#define	IMR_VIDOK				BIT(2)
-#define	IMR_VODOK				BIT(1)
-#define	IMR_ROK					BIT(0)
-
-#define	IMR_TXERR				BIT(11)
-#define	IMR_RXERR				BIT(10)
-#define	IMR_CPWM				BIT(8)
-#define	IMR_OCPINT				BIT(1)
-#define	IMR_WLANOFF				BIT(0)
+#define	IMR_BCNINT					BIT(13)
+#define	IMR_RXFOVW					BIT(12)
+#define	IMR_RDU						BIT(11)
+#define	IMR_ATIMEND					BIT(10)
+#define	IMR_BDOK					BIT(9)
+#define	IMR_HIGHDOK					BIT(8)
+#define	IMR_TBDOK					BIT(7)
+#define	IMR_MGNTDOK					BIT(6)
+#define	IMR_TBDER					BIT(5)
+#define	IMR_BKDOK					BIT(4)
+#define	IMR_BEDOK					BIT(3)
+#define	IMR_VIDOK					BIT(2)
+#define	IMR_VODOK					BIT(1)
+#define	IMR_ROK						BIT(0)
+
+#define	IMR_TXERR					BIT(11)
+#define	IMR_RXERR					BIT(10)
+#define	IMR_CPWM					BIT(8)
+#define	IMR_OCPINT					BIT(1)
+#define	IMR_WLANOFF					BIT(0)
 
 /* 8723E series PCIE Host IMR/ISR bit */
 /* IMR DW0 Bit 0-31 */
-#define	PHIMR_TIMEOUT2				BIT(31)
-#define	PHIMR_TIMEOUT1				BIT(30)
+#define	PHIMR_TIMEOUT2					BIT(31)
+#define	PHIMR_TIMEOUT1					BIT(30)
 #define	PHIMR_PSTIMEOUT				BIT(29)
-#define	PHIMR_GTINT4				BIT(28)
-#define	PHIMR_GTINT3				BIT(27)
-#define	PHIMR_TXBCNERR				BIT(26)
-#define	PHIMR_TXBCNOK				BIT(25)
+#define	PHIMR_GTINT4					BIT(28)
+#define	PHIMR_GTINT3					BIT(27)
+#define	PHIMR_TXBCNERR					BIT(26)
+#define	PHIMR_TXBCNOK					BIT(25)
 #define	PHIMR_TSF_BIT32_TOGGLE			BIT(24)
-#define	PHIMR_BCNDMAINT3			BIT(23)
-#define	PHIMR_BCNDMAINT2			BIT(22)
-#define	PHIMR_BCNDMAINT1			BIT(21)
-#define	PHIMR_BCNDMAINT0			BIT(20)
-#define	PHIMR_BCNDOK3				BIT(19)
-#define	PHIMR_BCNDOK2				BIT(18)
-#define	PHIMR_BCNDOK1				BIT(17)
-#define	PHIMR_BCNDOK0				BIT(16)
+#define	PHIMR_BCNDMAINT3				BIT(23)
+#define	PHIMR_BCNDMAINT2				BIT(22)
+#define	PHIMR_BCNDMAINT1				BIT(21)
+#define	PHIMR_BCNDMAINT0				BIT(20)
+#define	PHIMR_BCNDOK3					BIT(19)
+#define	PHIMR_BCNDOK2					BIT(18)
+#define	PHIMR_BCNDOK1					BIT(17)
+#define	PHIMR_BCNDOK0					BIT(16)
 #define	PHIMR_HSISR_IND_ON			BIT(15)
-#define	PHIMR_BCNDMAINT_E			BIT(14)
+#define	PHIMR_BCNDMAINT_E				BIT(14)
 #define	PHIMR_ATIMEND_E				BIT(13)
 #define	PHIMR_ATIM_CTW_END			BIT(12)
 #define	PHIMR_HISRE_IND				BIT(11)
-#define	PHIMR_C2HCMD				BIT(10)
-#define	PHIMR_CPWM2				BIT(9)
-#define	PHIMR_CPWM				BIT(8)
-#define	PHIMR_HIGHDOK				BIT(7)
-#define	PHIMR_MGNTDOK				BIT(6)
-#define	PHIMR_BKDOK				BIT(5)
-#define	PHIMR_BEDOK				BIT(4)
-#define	PHIMR_VIDOK				BIT(3)
-#define	PHIMR_VODOK				BIT(2)
-#define	PHIMR_RDU				BIT(1)
-#define	PHIMR_ROK				BIT(0)
+#define	PHIMR_C2HCMD					BIT(10)
+#define	PHIMR_CPWM2					BIT(9)
+#define	PHIMR_CPWM					BIT(8)
+#define	PHIMR_HIGHDOK					BIT(7)
+#define	PHIMR_MGNTDOK					BIT(6)
+#define	PHIMR_BKDOK					BIT(5)
+#define	PHIMR_BEDOK					BIT(4)
+#define	PHIMR_VIDOK					BIT(3)
+#define	PHIMR_VODOK					BIT(2)
+#define	PHIMR_RDU						BIT(1)
+#define	PHIMR_ROK						BIT(0)
 
 /* PCIE Host Interrupt Status Extension bit */
-#define	PHIMR_BCNDMAINT7			BIT(23)
-#define	PHIMR_BCNDMAINT6			BIT(22)
-#define	PHIMR_BCNDMAINT5			BIT(21)
-#define	PHIMR_BCNDMAINT4			BIT(20)
-#define	PHIMR_BCNDOK7				BIT(19)
-#define	PHIMR_BCNDOK6				BIT(18)
-#define	PHIMR_BCNDOK5				BIT(17)
-#define	PHIMR_BCNDOK4				BIT(16)
+#define	PHIMR_BCNDMAINT7				BIT(23)
+#define	PHIMR_BCNDMAINT6				BIT(22)
+#define	PHIMR_BCNDMAINT5				BIT(21)
+#define	PHIMR_BCNDMAINT4				BIT(20)
+#define	PHIMR_BCNDOK7					BIT(19)
+#define	PHIMR_BCNDOK6					BIT(18)
+#define	PHIMR_BCNDOK5					BIT(17)
+#define	PHIMR_BCNDOK4					BIT(16)
 /* bit12-15: RSVD */
-#define	PHIMR_TXERR				BIT(11)
-#define	PHIMR_RXERR				BIT(10)
-#define	PHIMR_TXFOVW				BIT(9)
-#define	PHIMR_RXFOVW				BIT(8)
-/* bit2-7: RSV */
-#define	PHIMR_OCPINT				BIT(1)
+#define	PHIMR_TXERR					BIT(11)
+#define	PHIMR_RXERR					BIT(10)
+#define	PHIMR_TXFOVW					BIT(9)
+#define	PHIMR_RXFOVW					BIT(8)
+/* bit2-7: RSVD */
+#define	PHIMR_OCPINT					BIT(1)
 
 #define	HWSET_MAX_SIZE				256
 #define EFUSE_MAX_SECTION			32
 #define EFUSE_REAL_CONTENT_LEN			512
 #define EFUSE_OOB_PROTECT_BYTES			15
 
-#define	EEPROM_DEFAULT_TSSI			0x0
-#define EEPROM_DEFAULT_TXPOWERDIFF		0x0
-#define EEPROM_DEFAULT_CRYSTALCAP		0x5
-#define EEPROM_DEFAULT_BOARDTYPE		0x02
-#define EEPROM_DEFAULT_TXPOWER			0x1010
-#define	EEPROM_DEFAULT_HT2T_TXPWR		0x10
+#define	EEPROM_DEFAULT_TSSI					0x0
+#define EEPROM_DEFAULT_TXPOWERDIFF			0x0
+#define EEPROM_DEFAULT_CRYSTALCAP			0x5
+#define EEPROM_DEFAULT_BOARDTYPE			0x02
+#define EEPROM_DEFAULT_TXPOWER				0x1010
+#define	EEPROM_DEFAULT_HT2T_TXPWR			0x10
 
 #define	EEPROM_DEFAULT_LEGACYHTTXPOWERDIFF	0x3
-#define	EEPROM_DEFAULT_THERMALMETER		0x12
+#define	EEPROM_DEFAULT_THERMALMETER			0x12
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
 
-
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
 
-#define	RTL8192_EEPROM_ID			0x8129
+#define	RTL8192_EEPROM_ID					0x8129
 
-#define RTL8190_EEPROM_ID			0x8129
-#define EEPROM_HPON				0x02
-#define EEPROM_CLK				0x06
-#define EEPROM_TESTR				0x08
+#define RTL8190_EEPROM_ID					0x8129
+#define EEPROM_HPON							0x02
+#define EEPROM_CLK							0x06
+#define EEPROM_TESTR						0x08
 
-#define EEPROM_VID				0x49
-#define EEPROM_DID				0x4B
-#define EEPROM_SVID				0x4D
-#define EEPROM_SMID				0x4F
+#define EEPROM_VID							0x49
+#define EEPROM_DID							0x4B
+#define EEPROM_SVID							0x4D
+#define EEPROM_SMID							0x4F
 
-#define EEPROM_MAC_ADDR				0x67
+#define EEPROM_MAC_ADDR						0x67
 
-#define EEPROM_CCK_TX_PWR_INX			0x5A
-#define EEPROM_HT40_1S_TX_PWR_INX		0x60
+#define EEPROM_CCK_TX_PWR_INX				0x5A
+#define EEPROM_HT40_1S_TX_PWR_INX			0x60
 #define EEPROM_HT40_2S_TX_PWR_INX_DIFF		0x66
-#define EEPROM_HT20_TX_PWR_INX_DIFF		0x69
-#define EEPROM_OFDM_TX_PWR_INX_DIFF		0x6C
-#define EEPROM_HT40_MAX_PWR_OFFSET		0x25
-#define EEPROM_HT20_MAX_PWR_OFFSET		0x22
-
-#define EEPROM_THERMAL_METER			0x2a
-#define EEPROM_XTAL_K				0x78
-#define EEPROM_RF_OPT1				0x79
-#define EEPROM_RF_OPT2				0x7A
-#define EEPROM_RF_OPT3				0x7B
-#define EEPROM_RF_OPT4				0x7C
-#define EEPROM_CHANNEL_PLAN			0x28
-#define EEPROM_VERSION				0x30
-#define EEPROM_CUSTOMER_ID			0x31
+#define EEPROM_HT20_TX_PWR_INX_DIFF			0x69
+#define EEPROM_OFDM_TX_PWR_INX_DIFF			0x6C
+#define EEPROM_HT40_MAX_PWR_OFFSET			0x25
+#define EEPROM_HT20_MAX_PWR_OFFSET			0x22
+
+#define EEPROM_THERMAL_METER				0x2a
+#define EEPROM_XTAL_K						0x78
+#define EEPROM_RF_OPT1						0x79
+#define EEPROM_RF_OPT2						0x7A
+#define EEPROM_RF_OPT3						0x7B
+#define EEPROM_RF_OPT4						0x7C
+#define EEPROM_CHANNEL_PLAN					0x28
+#define EEPROM_VERSION						0x30
+#define EEPROM_CUSTOMER_ID					0x31
 
 #define EEPROM_PWRDIFF				0x54
 
 #define EEPROM_TXPOWERCCK			0x10
-#define	EEPROM_TXPOWERHT40_1S			0x16
-#define	EEPROM_TXPOWERHT40_2SDIFF		0x66
-#define EEPROM_TXPOWERHT20DIFF			0x1C
-#define EEPROM_TXPOWER_OFDMDIFF			0x1F
+#define	EEPROM_TXPOWERHT40_1S		0x16
+#define	EEPROM_TXPOWERHT40_2SDIFF	0x66
+#define EEPROM_TXPOWERHT20DIFF		0x1C
+#define EEPROM_TXPOWER_OFDMDIFF		0x1F
 
 #define	EEPROM_TXPWR_GROUP			0x22
 
@@ -649,169 +672,169 @@
 
 #define EEPROM_CHANNELPLAN			0x28
 
-#define RF_OPTION1				0x2B
-#define RF_OPTION2				0x2C
-#define RF_OPTION3				0x2D
-#define RF_OPTION4				0x2E
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
+#define RF_OPTION1					0x2B
+#define RF_OPTION2					0x2C
+#define RF_OPTION3					0x2D
+#define RF_OPTION4					0x2E
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
-
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
-
-#define PWC_EV25V				BIT(14)
-#define PWC_EV12V				BIT(15)
-
-#define FEN_BBRSTB				BIT(0)
-#define FEN_BB_GLB_RSTn				BIT(1)
-#define FEN_USBA				BIT(2)
-#define FEN_UPLL				BIT(3)
-#define FEN_USBD				BIT(4)
+#define SW18_FPWM					BIT(3)
+
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
+
+#define PWC_EV25V					BIT(14)
+#define PWC_EV12V					BIT(15)
+
+#define FEN_BBRSTB					BIT(0)
+#define FEN_BB_GLB_RSTN				BIT(1)
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
-#define EnPDN					BIT(4)
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
@@ -826,146 +849,146 @@
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
-#define Timer_EN				BIT(4)
-
-#define TRSW0EN					BIT(2)
-#define TRSW1EN					BIT(3)
-#define EROM_EN					BIT(4)
-#define EnBT					BIT(5)
-#define EnUart					BIT(8)
-#define Uart_910				BIT(9)
-#define EnPMAC					BIT(10)
-#define SIC_SWRST				BIT(11)
-#define EnSIC					BIT(12)
-#define SIC_23					BIT(13)
-#define EnHDP					BIT(14)
-#define SIC_LBK					BIT(15)
-
-#define LED0PL					BIT(4)
-#define LED1PL					BIT(12)
-#define LED0DIS					BIT(7)
-
-#define MCUFWDL_EN				BIT(0)
-#define MCUFWDL_RDY				BIT(1)
-#define FWDL_ChkSum_rpt				BIT(2)
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
+#define FWDL_CHKSUM_RPT				BIT(2)
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
-#define BT_FUNC					BIT(16)
-#define VENDOR_ID				BIT(19)
+#define BT_FUNC						BIT(16)
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
 
-#define GET_RX_PAGE_SIZE(value)			((value) & 0xF)
-#define GET_TX_PAGE_SIZE(value)			(((value) & 0xF0) >> 4)
-#define _PSRX_MASK				0xF
-#define _PSTX_MASK				0xF0
-#define _PSRX(x)				(x)
-#define _PSTX(x)				((x) << 4)
+#define GET_RX_PAGE_SIZE(value)		((value) & 0xF)
+#define GET_TX_PAGE_SIZE(value)		(((value) & 0xF0) >> 4)
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
@@ -974,9 +997,9 @@
 #define _TXDMA_VIQ_MAP(x)			(((x)&0x3) << 6)
 #define _TXDMA_VOQ_MAP(x)			(((x)&0x3) << 4)
 
-#define QUEUE_LOW				1
+#define QUEUE_LOW					1
 #define QUEUE_NORMAL				2
-#define QUEUE_HIGH				3
+#define QUEUE_HIGH					3
 
 #define _LLT_NO_ACTIVE				0x0
 #define _LLT_WRITE_ACCESS			0x1
@@ -984,25 +1007,25 @@
 
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
@@ -1022,9 +1045,9 @@
 
 #define _RRSR_RSC(x)				(((x) & 0x3) << 21)
 #define RRSR_RSC_RESERVED			0x0
-#define RRSR_RSC_UPPER_SUBCHANNEL		0x1
-#define RRSR_RSC_LOWER_SUBCHANNEL		0x2
-#define RRSR_RSC_DUPLICATE_MODE			0x3
+#define RRSR_RSC_UPPER_SUBCHANNEL	0x1
+#define RRSR_RSC_LOWER_SUBCHANNEL	0x2
+#define RRSR_RSC_DUPLICATE_MODE		0x3
 
 #define USE_SHORT_G1				BIT(20)
 
@@ -1037,8 +1060,8 @@
 #define _AGGLMT_MCS6(x)				(((x) & 0xF) << 24)
 #define _AGGLMT_MCS7(x)				(((x) & 0xF) << 28)
 
-#define	RETRY_LIMIT_SHORT_SHIFT			8
-#define	RETRY_LIMIT_LONG_SHIFT			0
+#define	RETRY_LIMIT_SHORT_SHIFT		8
+#define	RETRY_LIMIT_LONG_SHIFT		0
 
 #define _DARF_RC1(x)				((x) & 0x1F)
 #define _DARF_RC2(x)				(((x) & 0x1F) << 8)
@@ -1058,123 +1081,123 @@
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
-#define _SIFS_CCK_TRX(x)			(((x) & 0xFF) << 8);
+#define _SIFS_CCK_TRX(x)			(((x) & 0xFF) << 8)
 
 #define _SIFS_OFDM_CTX(x)			((x) & 0xFF)
-#define _SIFS_OFDM_TRX(x)			(((x) & 0xFF) << 8);
+#define _SIFS_OFDM_TRX(x)			(((x) & 0xFF) << 8)
 
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
 
-#define	AcmHw_HwEn				BIT(0)
-#define	AcmHw_BeqEn				BIT(1)
-#define	AcmHw_ViqEn				BIT(2)
-#define	AcmHw_VoqEn				BIT(3)
-#define	AcmHw_BeqStatus				BIT(4)
-#define	AcmHw_ViqStatus				BIT(5)
-#define	AcmHw_VoqStatus				BIT(6)
+#define	ACMHW_HWEN					BIT(0)
+#define	ACMHW_BEQEN					BIT(1)
+#define	ACMHW_VIQEN					BIT(2)
+#define	ACMHW_VOQEN					BIT(3)
+#define	ACMHW_BEQSTATUS				BIT(4)
+#define	ACMHW_VIQSTATUS				BIT(5)
+#define	ACMHW_VOQSTATUS				BIT(6)
 
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
-#define EnMBID					BIT(24)
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
-
-#define	SCR_TxUseDK				BIT(0)
-#define	SCR_RxUseDK				BIT(1)
-#define	SCR_TxEncEnable				BIT(2)
-#define	SCR_RxDecEnable				BIT(3)
-#define	SCR_SKByA2				BIT(4)
-#define	SCR_NoSKMC				BIT(5)
+#define _RXERR_RPT_SEL(type)		((type) << 28)
+
+#define	SCR_TXUSEDK					BIT(0)
+#define	SCR_RXUSEDK					BIT(1)
+#define	SCR_TXENCENABLE				BIT(2)
+#define	SCR_RXDECENABLE				BIT(3)
+#define	SCR_SKBYA2					BIT(4)
+#define	SCR_NOSKMC					BIT(5)
 #define SCR_TXBCUSEDK				BIT(6)
 #define SCR_RXBCUSEDK				BIT(7)
 
@@ -1182,32 +1205,32 @@
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
-#define LAST_ENTRY_OF_TX_PKT_BUFFER		255
+#define LAST_ENTRY_OF_TX_PKT_BUFFER	255
 
-#define POLLING_LLT_THRESHOLD			20
-#define POLLING_READY_TIMEOUT_COUNT		1000
+#define POLLING_LLT_THRESHOLD		20
+#define POLLING_READY_TIMEOUT_COUNT	1000
 
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
@@ -1223,12 +1246,12 @@
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
@@ -1245,44 +1268,44 @@
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
-#define	RFPGA0_XAB_RFINTERFACERB		0x8e0
-#define	RFPGA0_XCD_RFINTERFACERB		0x8e4
+#define	TRANSCEIVEA_HSPI_READBACK	0x8b8
+#define	TRANSCEIVEB_HSPI_READBACK	0x8bc
+#define	RFPGA0_XAB_RFINTERFACERB	0x8e0
+#define	RFPGA0_XCD_RFINTERFACERB	0x8e4
 
 #define	RFPGA1_RFMOD				0x900
 
@@ -1293,12 +1316,12 @@
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
@@ -1306,26 +1329,26 @@
 #define	RCCK0_TXFILTER1				0xa20
 #define	RCCK0_TXFILTER2				0xa24
 #define	RCCK0_DEBUGPORT				0xa28
-#define	RCCK0_FALSEALARMREPORT			0xa2c
-#define	RCCK0_TRSSIREPORT			0xa50
-#define	RCCK0_RXREPORT				0xa54
-#define	RCCK0_FACOUNTERLOWER			0xa5c
-#define	RCCK0_FACOUNTERUPPER			0xa58
+#define	RCCK0_FALSEALARMREPORT		0xa2c
+#define	RCCK0_TRSSIREPORT		0xa50
+#define	RCCK0_RXREPORT			0xa54
+#define	RCCK0_FACOUNTERLOWER		0xa5c
+#define	RCCK0_FACOUNTERUPPER		0xa58
 
-#define	ROFDM0_LSTF				0xc00
+#define	ROFDM0_LSTF					0xc00
 
-#define	ROFDM0_TRXPATHENABLE			0xc04
+#define	ROFDM0_TRXPATHENABLE		0xc04
 #define	ROFDM0_TRMUXPAR				0xc08
-#define	ROFDM0_TRSWISOLATION			0xc0c
+#define	ROFDM0_TRSWISOLATION		0xc0c
 
 #define	ROFDM0_XARXAFE				0xc10
-#define	ROFDM0_XARXIQIMBALANCE			0xc14
-#define	ROFDM0_XBRXAFE				0xc18
-#define	ROFDM0_XBRXIQIMBALANCE			0xc1c
-#define	ROFDM0_XCRXAFE				0xc20
-#define	ROFDM0_XCRXIQIMBANLANCE			0xc24
-#define	ROFDM0_XDRXAFE				0xc28
-#define	ROFDM0_XDRXIQIMBALANCE			0xc2c
+#define	ROFDM0_XARXIQIMBALANCE		0xc14
+#define	ROFDM0_XBRXAFE			0xc18
+#define	ROFDM0_XBRXIQIMBALANCE		0xc1c
+#define	ROFDM0_XCRXAFE			0xc20
+#define	ROFDM0_XCRXIQIMBANLANCE		0xc24
+#define	ROFDM0_XDRXAFE			0xc28
+#define	ROFDM0_XDRXIQIMBALANCE		0xc2c
 
 #define	ROFDM0_RXDETECTOR1			0xc30
 #define	ROFDM0_RXDETECTOR2			0xc34
@@ -1334,8 +1357,8 @@
 
 #define	ROFDM0_RXDSP				0xc40
 #define	ROFDM0_CFOANDDAGC			0xc44
-#define	ROFDM0_CCADROPTHRESHOLD			0xc48
-#define	ROFDM0_ECCATHRESHOLD			0xc4c
+#define	ROFDM0_CCADROPTHRESHOLD		0xc48
+#define	ROFDM0_ECCATHRESHOLD		0xc4c
 
 #define	ROFDM0_XAAGCCORE1			0xc50
 #define	ROFDM0_XAAGCCORE2			0xc54
@@ -1346,24 +1369,24 @@
 #define	ROFDM0_XDAGCCORE1			0xc68
 #define	ROFDM0_XDAGCCORE2			0xc6c
 
-#define	ROFDM0_AGCPARAMETER1			0xc70
-#define	ROFDM0_AGCPARAMETER2			0xc74
+#define	ROFDM0_AGCPARAMETER1		0xc70
+#define	ROFDM0_AGCPARAMETER2		0xc74
 #define	ROFDM0_AGCRSSITABLE			0xc78
 #define	ROFDM0_HTSTFAGC				0xc7c
 
-#define	ROFDM0_XATXIQIMBALANCE			0xc80
+#define	ROFDM0_XATXIQIMBALANCE		0xc80
 #define	ROFDM0_XATXAFE				0xc84
-#define	ROFDM0_XBTXIQIMBALANCE			0xc88
+#define	ROFDM0_XBTXIQIMBALANCE		0xc88
 #define	ROFDM0_XBTXAFE				0xc8c
-#define	ROFDM0_XCTXIQIMBALANCE			0xc90
-#define	ROFDM0_XCTXAFE				0xc94
-#define	ROFDM0_XDTXIQIMBALANCE			0xc98
+#define	ROFDM0_XCTXIQIMBALANCE		0xc90
+#define	ROFDM0_XCTXAFE			0xc94
+#define	ROFDM0_XDTXIQIMBALANCE		0xc98
 #define	ROFDM0_XDTXAFE				0xc9c
 
 #define ROFDM0_RXIQEXTANTA			0xca0
 
-#define	ROFDM0_RXHPPARAMETER			0xce0
-#define	ROFDM0_TXPSEUDONOISEWGT			0xce4
+#define	ROFDM0_RXHPPARAMETER		0xce0
+#define	ROFDM0_TXPSEUDONOISEWGT		0xce4
 #define	ROFDM0_FRAMESYNC			0xcf0
 #define	ROFDM0_DFSREPORT			0xcf4
 #define	ROFDM0_TXCOEFF1				0xca4
@@ -1373,19 +1396,19 @@
 #define	ROFDM0_TXCOEFF5				0xcb4
 #define	ROFDM0_TXCOEFF6				0xcb8
 
-#define	ROFDM1_LSTF				0xd00
-#define	ROFDM1_TRXPATHENABLE			0xd04
+#define	ROFDM1_LSTF					0xd00
+#define	ROFDM1_TRXPATHENABLE		0xd04
 
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
@@ -1397,35 +1420,35 @@
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
+#define	RTXAGC_B_CCK1_55_MCS32		0x838
+#define	RTXAGC_B_MCS03_MCS00		0x83c
+#define	RTXAGC_B_MCS07_MCS04		0x848
+#define	RTXAGC_B_MCS11_MCS08		0x84c
+#define	RTXAGC_B_MCS15_MCS12		0x868
+#define	RTXAGC_B_CCK11_A_CCK2_11	0x86c
 
 #define	RZEBRA1_HSSIENABLE			0x0
 #define	RZEBRA1_TRXENABLE1			0x1
 #define	RZEBRA1_TRXENABLE2			0x2
-#define	RZEBRA1_AGC				0x4
+#define	RZEBRA1_AGC					0x4
 #define	RZEBRA1_CHARGEPUMP			0x5
 #define	RZEBRA1_CHANNEL				0x7
 
@@ -1434,649 +1457,664 @@
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
-#define	RF_T_METER				0x24
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
+#define	RF_T_METER					0x24
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
-#define IS_BB_REG_OFFSET_92S(_Offset)	\
-	((_Offset >= 0x800) && (_Offset <= 0xfff))
-
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
-#define	BPSD_TX_TRIGGER				0x80000000
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
-#define	BCCK_FAST_FALSECCAi			0x400000
-#define	BCCK_CH_ESTSTARTi			0x300000
-#define	BCCK_CCA_COUNTi				0x080000
-#define	BCCK_CS_LIM				0x070000
-#define	BCCK_BIST_MODEi				0x80000000
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
-#define	bCCKRxRFSettle				0x1f
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
-#define	BTXIQIMB_b				0xfc00
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
+#define IS_BB_REG_OFFSET_92S(_offset)	\
+	((_offset >= 0x800) && (_offset <= 0xfff))
+
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
 
 /* 2 EFUSE_TEST (For RTL8723 partially) */
-#define EFUSE_SEL(x)				(((x) & 0x3) << 8)
+#define EFUSE_SEL(x)					(((x) & 0x3) << 8)
 #define EFUSE_SEL_MASK				0x300
-#define EFUSE_WIFI_SEL_0			0x0
-
+#define EFUSE_WIFI_SEL_0				0x0
 /* Enable GPIO[9] as WiFi HW PDn source*/
-#define	WL_HWPDN_EN				BIT(0)
+#define	WL_HWPDN_EN					BIT(0)
 /* WiFi HW PDn polarity control*/
-#define	WL_HWPDN_SL				BIT(1)
+#define	WL_HWPDN_SL					BIT(1)
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.c b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.c
index 50dd2fb..9ebc828 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.c
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
@@ -34,10 +30,12 @@
 #include "rf.h"
 #include "dm.h"
 
-void rtl8723ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
+static bool _rtl8723e_phy_rf6052_config_parafile(struct ieee80211_hw *hw);
+
+void rtl8723e_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	switch (bandwidth) {
 	case HT_CHANNEL_WIDTH_20:
@@ -59,11 +57,11 @@ void rtl8723ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 	}
 }
 
-void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-					  u8 *ppowerlevel)
+void rtl8723e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					 u8 *ppowerlevel)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u32 tx_agc[2] = {0, 0}, tmpval;
@@ -79,7 +77,8 @@ void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 		tx_agc[RF90_PATH_B] = 0x3f3f3f3f;
 
 		if (turbo_scanoff) {
-			for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
+			for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B;
+				idx1++) {
 				tx_agc[idx1] = ppowerlevel[idx1] |
 				    (ppowerlevel[idx1] << 8) |
 				    (ppowerlevel[idx1] << 16) |
@@ -89,24 +88,27 @@ void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 	} else {
 		for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
 			tx_agc[idx1] = ppowerlevel[idx1] |
-				       (ppowerlevel[idx1] << 8) |
-				       (ppowerlevel[idx1] << 16) |
-				       (ppowerlevel[idx1] << 24);
+			    (ppowerlevel[idx1] << 8) |
+			    (ppowerlevel[idx1] << 16) |
+			    (ppowerlevel[idx1] << 24);
 		}
 
 		if (rtlefuse->eeprom_regulatory == 0) {
-			tmpval = (rtlphy->mcs_offset[0][6]) +
-				(rtlphy->mcs_offset[0][7] << 8);
+			tmpval =
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][6]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][7] <<
+			     8);
 			tx_agc[RF90_PATH_A] += tmpval;
 
-			tmpval = (rtlphy->mcs_offset[0][14]) +
-			    (rtlphy->mcs_offset[0][15] << 24);
+			tmpval = (rtlphy->mcs_txpwrlevel_origoffset[0][14]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][15] <<
+			     24);
 			tx_agc[RF90_PATH_B] += tmpval;
 		}
 	}
 
 	for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
-		ptr = (u8 *) (&(tx_agc[idx1]));
+		ptr = (u8 *)&tx_agc[idx1];
 		for (idx2 = 0; idx2 < 4; idx2++) {
 			if (*ptr > RF6052_MAX_TX_PWR)
 				*ptr = RF6052_MAX_TX_PWR;
@@ -119,7 +121,7 @@ void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 		"CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_A_CCK1_MCS32);
+		 RTXAGC_A_CCK1_MCS32);
 
 	tmpval = tx_agc[RF90_PATH_A] >> 8;
 
@@ -129,100 +131,99 @@ void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 		"CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_B_CCK11_A_CCK2_11);
+		 RTXAGC_B_CCK11_A_CCK2_11);
 
 	tmpval = tx_agc[RF90_PATH_B] >> 24;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, MASKBYTE0, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 		"CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_B_CCK11_A_CCK2_11);
+		 RTXAGC_B_CCK11_A_CCK2_11);
 
 	tmpval = tx_agc[RF90_PATH_B] & 0x00ffffff;
 	rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32, 0xffffff00, tmpval);
 
 	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 		"CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
-		RTXAGC_B_CCK1_55_MCS32);
+		 RTXAGC_B_CCK1_55_MCS32);
 }
 
-static void rtl8723ae_phy_get_power_base(struct ieee80211_hw *hw,
-					 u8 *ppowerlevel, u8 channel,
-					 u32 *ofdmbase, u32 *mcsbase)
+static void rtl8723e_phy_get_power_base(struct ieee80211_hw *hw,
+					u8 *ppowerlevel, u8 channel,
+					u32 *ofdmbase, u32 *mcsbase)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
-	u32 powerBase0, powerBase1;
+	u32 powerbase0, powerbase1;
 	u8 legacy_pwrdiff, ht20_pwrdiff;
 	u8 i, powerlevel[2];
 
 	for (i = 0; i < 2; i++) {
 		powerlevel[i] = ppowerlevel[i];
 		legacy_pwrdiff = rtlefuse->txpwr_legacyhtdiff[i][channel - 1];
-		powerBase0 = powerlevel[i] + legacy_pwrdiff;
+		powerbase0 = powerlevel[i] + legacy_pwrdiff;
 
-		powerBase0 = (powerBase0 << 24) | (powerBase0 << 16) |
-		    (powerBase0 << 8) | powerBase0;
-		*(ofdmbase + i) = powerBase0;
+		powerbase0 = (powerbase0 << 24) | (powerbase0 << 16) |
+		    (powerbase0 << 8) | powerbase0;
+		*(ofdmbase + i) = powerbase0;
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 			" [OFDM power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(ofdmbase + i));
+			 ((i == 0) ? 'A' : 'B'), *(ofdmbase + i));
 	}
 
 	for (i = 0; i < 2; i++) {
 		if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20) {
-			ht20_pwrdiff = rtlefuse->txpwr_ht20diff[i][channel - 1];
+			ht20_pwrdiff =
+				rtlefuse->txpwr_ht20diff[i][channel - 1];
 			powerlevel[i] += ht20_pwrdiff;
 		}
-		powerBase1 = powerlevel[i];
-		powerBase1 = (powerBase1 << 24) |
-		    (powerBase1 << 16) | (powerBase1 << 8) | powerBase1;
+		powerbase1 = powerlevel[i];
+		powerbase1 = (powerbase1 << 24) |
+		    (powerbase1 << 16) | (powerbase1 << 8) | powerbase1;
 
-		*(mcsbase + i) = powerBase1;
+		*(mcsbase + i) = powerbase1;
 
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 			" [MCS power base index rf(%c) = 0x%x]\n",
-			((i == 0) ? 'A' : 'B'), *(mcsbase + i));
+			 ((i == 0) ? 'A' : 'B'), *(mcsbase + i));
 	}
 }
 
-static void rtl8723ae_get_txpwr_val_by_reg(struct ieee80211_hw *hw,
-					   u8 channel, u8 index,
-					   u32 *powerBase0,
-					   u32 *powerBase1,
-					   u32 *p_outwriteval)
+static void get_txpower_writeval_by_reg(struct ieee80211_hw *hw,
+					u8 channel, u8 index,
+					u32 *powerbase0,
+					u32 *powerbase1,
+					u32 *p_outwriteval)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 i, chnlgroup = 0, pwr_diff_limit[4];
-	u32 writeVal, customer_limit, rf;
+	u32 writeval, customer_limit, rf;
 
 	for (rf = 0; rf < 2; rf++) {
 		switch (rtlefuse->eeprom_regulatory) {
 		case 0:
 			chnlgroup = 0;
 
-			writeVal = rtlphy->mcs_offset[chnlgroup]
-				   [index + (rf ? 8 : 0)] +
-				   ((index < 2) ? powerBase0[rf] :
-				   powerBase1[rf]);
+			writeval =
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup][index +
+								(rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"RTK better performance, "
-				"writeVal(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal);
+				"RTK better performance, writeval(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		case 1:
 			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
-				writeVal = ((index < 2) ? powerBase0[rf] :
-					    powerBase1[rf]);
+				writeval = ((index < 2) ? powerbase0[rf] :
+					    powerbase1[rf]);
 
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					"Realtek regulatory, 40MHz, "
-					"writeVal(%c) = 0x%x\n",
-					((rf == 0) ? 'A' : 'B'), writeVal);
+					"Realtek regulatory, 40MHz, writeval(%c) = 0x%x\n",
+					((rf == 0) ? 'A' : 'B'), writeval);
 			} else {
 				if (rtlphy->pwrgroup_cnt == 1)
 					chnlgroup = 0;
@@ -234,29 +235,30 @@ static void rtl8723ae_get_txpwr_val_by_reg(struct ieee80211_hw *hw,
 					else if (channel > 9)
 						chnlgroup = 2;
 					if (rtlphy->current_chan_bw ==
-					    HT_CHANNEL_WIDTH_20)
+						HT_CHANNEL_WIDTH_20)
 						chnlgroup++;
 					else
 						chnlgroup += 4;
 				}
 
-				writeVal = rtlphy->mcs_offset[chnlgroup]
+				writeval =
+				    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
 				    [index + (rf ? 8 : 0)] + ((index < 2) ?
-							      powerBase0[rf] :
-							      powerBase1[rf]);
+							      powerbase0[rf] :
+							      powerbase1[rf]);
 
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-					"Realtek regulatory, 20MHz, writeVal(%c) = 0x%x\n",
-					((rf == 0) ? 'A' : 'B'), writeVal);
+					"Realtek regulatory, 20MHz, writeval(%c) = 0x%x\n",
+					((rf == 0) ? 'A' : 'B'), writeval);
 			}
 			break;
 		case 2:
-			writeVal =
-			    ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
+			writeval =
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"Better regulatory, writeVal(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal);
+				"Better regulatory, writeval(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		case 3:
 			chnlgroup = 0;
@@ -265,18 +267,21 @@ static void rtl8723ae_get_txpwr_val_by_reg(struct ieee80211_hw *hw,
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 					"customer's limit, 40MHz rf(%c) = 0x%x\n",
 					((rf == 0) ? 'A' : 'B'),
-					rtlefuse->pwrgroup_ht40[rf][channel-1]);
+					rtlefuse->pwrgroup_ht40[rf][channel -
+								     1]);
 			} else {
 				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 					"customer's limit, 20MHz rf(%c) = 0x%x\n",
 					((rf == 0) ? 'A' : 'B'),
-					rtlefuse->pwrgroup_ht20[rf][channel-1]);
+					rtlefuse->pwrgroup_ht20[rf][channel -
+								     1]);
 			}
 			for (i = 0; i < 4; i++) {
 				pwr_diff_limit[i] =
-					(u8) ((rtlphy->mcs_offset
-					[chnlgroup][index + (rf ? 8 : 0)] &
-					(0x7f << (i * 8))) >> (i * 8));
+				    (u8)((rtlphy->mcs_txpwrlevel_origoffset
+					  [chnlgroup][index +
+						(rf ? 8 : 0)] & (0x7f <<
+						(i * 8))) >> (i * 8));
 
 				if (rtlphy->current_chan_bw ==
 				    HT_CHANNEL_WIDTH_20_40) {
@@ -302,41 +307,42 @@ static void rtl8723ae_get_txpwr_val_by_reg(struct ieee80211_hw *hw,
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
 				"Customer's limit rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), customer_limit);
+				 ((rf == 0) ? 'A' : 'B'), customer_limit);
 
-			writeVal = customer_limit +
-			    ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
+			writeval = customer_limit +
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"Customer, writeVal rf(%c)= 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal);
+				"Customer, writeval rf(%c)= 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		default:
 			chnlgroup = 0;
-			writeVal = rtlphy->mcs_offset[chnlgroup][index +
-			    (rf ? 8 : 0)] + ((index < 2) ? powerBase0[rf] :
-			    powerBase1[rf]);
+			writeval =
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			    [index + (rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
 
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-				"RTK better performance, writeVal rf(%c) = 0x%x\n",
-				((rf == 0) ? 'A' : 'B'), writeVal);
+				"RTK better performance, writeval rf(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), writeval);
 			break;
 		}
 
 		if (rtlpriv->dm.dynamic_txhighpower_lvl == TXHIGHPWRLEVEL_BT1)
-			writeVal = writeVal - 0x06060606;
+			writeval = writeval - 0x06060606;
 		else if (rtlpriv->dm.dynamic_txhighpower_lvl ==
 			 TXHIGHPWRLEVEL_BT2)
-			writeVal = writeVal - 0x0c0c0c0c;
-		*(p_outwriteval + rf) = writeVal;
+			writeval = writeval - 0x0c0c0c0c;
+		*(p_outwriteval + rf) = writeval;
 	}
 }
 
-static void _rtl8723ae_write_ofdm_power_reg(struct ieee80211_hw *hw,
-					    u8 index, u32 *pValue)
+static void _rtl8723e_write_ofdm_power_reg(struct ieee80211_hw *hw,
+					   u8 index, u32 *pvalue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 
 	u16 regoffset_a[6] = {
 		RTXAGC_A_RATE18_06, RTXAGC_A_RATE54_24,
@@ -349,29 +355,29 @@ static void _rtl8723ae_write_ofdm_power_reg(struct ieee80211_hw *hw,
 		RTXAGC_B_MCS11_MCS08, RTXAGC_B_MCS15_MCS12
 	};
 	u8 i, rf, pwr_val[4];
-	u32 writeVal;
+	u32 writeval;
 	u16 regoffset;
 
 	for (rf = 0; rf < 2; rf++) {
-		writeVal = pValue[rf];
+		writeval = pvalue[rf];
 		for (i = 0; i < 4; i++) {
-			pwr_val[i] = (u8) ((writeVal & (0x7f <<
-							(i * 8))) >> (i * 8));
+			pwr_val[i] = (u8)((writeval & (0x7f <<
+					   (i * 8))) >> (i * 8));
 
 			if (pwr_val[i] > RF6052_MAX_TX_PWR)
 				pwr_val[i] = RF6052_MAX_TX_PWR;
 		}
-		writeVal = (pwr_val[3] << 24) | (pwr_val[2] << 16) |
+		writeval = (pwr_val[3] << 24) | (pwr_val[2] << 16) |
 		    (pwr_val[1] << 8) | pwr_val[0];
 
 		if (rf == 0)
 			regoffset = regoffset_a[index];
 		else
 			regoffset = regoffset_b[index];
-		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeVal);
+		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeval);
 
 		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
-			"Set 0x%x = %08x\n", regoffset, writeVal);
+			"Set 0x%x = %08x\n", regoffset, writeval);
 
 		if (((get_rf_type(rtlphy) == RF_2T2R) &&
 		     (regoffset == RTXAGC_A_MCS15_MCS12 ||
@@ -380,7 +386,7 @@ static void _rtl8723ae_write_ofdm_power_reg(struct ieee80211_hw *hw,
 		     (regoffset == RTXAGC_A_MCS07_MCS04 ||
 		      regoffset == RTXAGC_B_MCS07_MCS04))) {
 
-			writeVal = pwr_val[3];
+			writeval = pwr_val[3];
 			if (regoffset == RTXAGC_A_MCS15_MCS12 ||
 			    regoffset == RTXAGC_A_MCS07_MCS04)
 				regoffset = 0xc90;
@@ -389,37 +395,49 @@ static void _rtl8723ae_write_ofdm_power_reg(struct ieee80211_hw *hw,
 				regoffset = 0xc98;
 
 			for (i = 0; i < 3; i++) {
-				writeVal = (writeVal > 6) ? (writeVal - 6) : 0;
+				writeval = (writeval > 6) ? (writeval - 6) : 0;
 				rtl_write_byte(rtlpriv, (u32) (regoffset + i),
-					       (u8) writeVal);
+					       (u8)writeval);
 			}
 		}
 	}
 }
 
-void rtl8723ae_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-					   u8 *ppowerlevel, u8 channel)
+void rtl8723e_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel, u8 channel)
 {
-	u32 writeVal[2], powerBase0[2], powerBase1[2];
+	u32 writeval[2], powerbase0[2], powerbase1[2];
 	u8 index;
 
-	rtl8723ae_phy_get_power_base(hw, ppowerlevel,
-				  channel, &powerBase0[0], &powerBase1[0]);
+	rtl8723e_phy_get_power_base(hw, ppowerlevel,
+				    channel, &powerbase0[0], &powerbase1[0]);
 
 	for (index = 0; index < 6; index++) {
-		rtl8723ae_get_txpwr_val_by_reg(hw, channel, index,
-					      &powerBase0[0],
-					      &powerBase1[0],
-					      &writeVal[0]);
+		get_txpower_writeval_by_reg(hw, channel, index, &powerbase0[0],
+					    &powerbase1[0],
+					    &writeval[0]);
 
-		_rtl8723ae_write_ofdm_power_reg(hw, index, &writeVal[0]);
+		_rtl8723e_write_ofdm_power_reg(hw, index, &writeval[0]);
 	}
 }
 
-static bool _rtl8723ae_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
+bool rtl8723e_phy_rf6052_config(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
+
+	if (rtlphy->rf_type == RF_1T1R)
+		rtlphy->num_total_rfpath = 1;
+	else
+		rtlphy->num_total_rfpath = 2;
+
+	return _rtl8723e_phy_rf6052_config_parafile(hw);
+}
+
+static bool _rtl8723e_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &rtlpriv->phy;
 	u32 u4_regvalue = 0;
 	u8 rfpath;
 	bool rtstatus = true;
@@ -457,11 +475,12 @@ static bool _rtl8723ae_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		switch (rfpath) {
 		case RF90_PATH_A:
-			rtstatus = rtl8723ae_phy_config_rf_with_headerfile(hw,
+			rtstatus = rtl8723e_phy_config_rf_with_headerfile(hw,
 						(enum radio_path)rfpath);
 			break;
 		case RF90_PATH_B:
-			rtstatus = rtl8723ae_phy_config_rf_with_headerfile(hw,
+			rtstatus =
+			  rtl8723e_phy_config_rf_with_headerfile(hw,
 						(enum radio_path)rfpath);
 			break;
 		case RF90_PATH_C:
@@ -469,6 +488,7 @@ static bool _rtl8723ae_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 		case RF90_PATH_D:
 			break;
 		}
+
 		switch (rfpath) {
 		case RF90_PATH_A:
 		case RF90_PATH_C:
@@ -481,25 +501,14 @@ static bool _rtl8723ae_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 				      BRFSI_RFENV << 16, u4_regvalue);
 			break;
 		}
+
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 				 "Radio[%d] Fail!!", rfpath);
 			return false;
 		}
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "<---\n");
-	return rtstatus;
-}
-
-bool rtl8723ae_phy_rf6052_config(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
-	if (rtlphy->rf_type == RF_1T1R)
-		rtlphy->num_total_rfpath = 1;
-	else
-		rtlphy->num_total_rfpath = 2;
-
-	return _rtl8723ae_phy_rf6052_config_parafile(hw);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "\n");
+	return rtstatus;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
index 57f1933..f3f45b1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
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
@@ -31,12 +27,14 @@
 #define __RTL8723E_RF_H__
 
 #define RF6052_MAX_TX_PWR		0x3F
+#define RF6052_MAX_REG			0x3F
 
-void rtl8723ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth);
-void rtl8723ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
-					  u8 *ppowerlevel);
-void rtl8723ae_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
-					   u8 *ppowerlevel, u8 channel);
-bool rtl8723ae_phy_rf6052_config(struct ieee80211_hw *hw);
+void rtl8723e_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
+				       u8 bandwidth);
+void rtl8723e_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					 u8 *ppowerlevel);
+void rtl8723e_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel, u8 channel);
+bool rtl8723e_phy_rf6052_config(struct ieee80211_hw *hw);
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
index 73cba1e..d8f8cc4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
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
@@ -28,34 +24,35 @@
  *****************************************************************************/
 
 #include "../wifi.h"
-#include <linux/vmalloc.h>
-#include <linux/module.h>
-
 #include "../core.h"
 #include "../pci.h"
-#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
-#include "../rtl8723com/phy_common.h"
 #include "dm.h"
-#include "hw.h"
 #include "fw.h"
 #include "../rtl8723com/fw_common.h"
+#include "hw.h"
 #include "sw.h"
 #include "trx.h"
 #include "led.h"
 #include "table.h"
 #include "hal_btc.h"
+#include "../btcoexist/rtl_btc.h"
+#include "../rtl8723com/phy_common.h"
 
-static void rtl8723ae_init_aspm_vars(struct ieee80211_hw *hw)
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+
+static void rtl8723e_init_aspm_vars(struct ieee80211_hw *hw)
 {
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
 	/*close ASPM for AMD defaultly */
 	rtlpci->const_amdpci_aspm = 0;
 
-	/* ASPM PS mode.
+	/**
+	 * ASPM PS mode.
 	 * 0 - Disable ASPM,
 	 * 1 - Enable ASPM without Clock Req,
 	 * 2 - Enable ASPM with Clock Req,
@@ -71,7 +68,8 @@ static void rtl8723ae_init_aspm_vars(struct ieee80211_hw *hw)
 	/*Setting for PCI-E bridge */
 	rtlpci->const_hostpci_aspm_setting = 0x02;
 
-	/* In Hw/Sw Radio Off situation.
+	/**
+	 * In Hw/Sw Radio Off situation.
 	 * 0 - Default,
 	 * 1 - From ASPM setting without low Mac Pwr,
 	 * 2 - From ASPM setting with low Mac Pwr,
@@ -80,7 +78,8 @@ static void rtl8723ae_init_aspm_vars(struct ieee80211_hw *hw)
 	 */
 	rtlpci->const_hwsw_rfoff_d3 = 0;
 
-	/* This setting works for those device with
+	/**
+	 * This setting works for those device with
 	 * backdoor ASPM setting such as EPHY setting.
 	 * 0 - Not support ASPM,
 	 * 1 - Support ASPM,
@@ -89,14 +88,17 @@ static void rtl8723ae_init_aspm_vars(struct ieee80211_hw *hw)
 	rtlpci->const_support_pciaspm = 1;
 }
 
-int rtl8723ae_init_sw_vars(struct ieee80211_hw *hw)
+int rtl8723e_init_sw_vars(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	int err;
+	int err = 0;
+
+	rtl8723e_bt_reg_init(hw);
+
+	rtlpriv->btcoexist.btc_ops = rtl_btc_get_ops_pointer();
 
-	rtl8723ae_bt_reg_init(hw);
 	rtlpriv->dm.dm_initialgain_enable = 1;
 	rtlpriv->dm.dm_flag = 0;
 	rtlpriv->dm.disable_framebursting = 0;
@@ -138,7 +140,9 @@ int rtl8723ae_init_sw_vars(struct ieee80211_hw *hw)
 		   PHIMR_PSTIMEOUT |
 		   0);
 
-	rtlpci->irq_mask[1] = (u32)(PHIMR_RXFOVW | 0);
+	rtlpci->irq_mask[1]	=
+		 (u32)(PHIMR_RXFOVW |
+				0);
 
 	/* for debug level */
 	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
@@ -146,12 +150,11 @@ int rtl8723ae_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->psc.inactiveps = rtlpriv->cfg->mod_params->inactiveps;
 	rtlpriv->psc.swctrl_lps = rtlpriv->cfg->mod_params->swctrl_lps;
 	rtlpriv->psc.fwctrl_lps = rtlpriv->cfg->mod_params->fwctrl_lps;
+	if (rtlpriv->cfg->mod_params->disable_watchdog)
+		pr_info("watchdog disabled\n");
 	rtlpriv->psc.reg_fwctrl_lps = 3;
 	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
-	/* for ASPM, you can close aspm through
-	 * set const_support_pciaspm = 0
-	 */
-	rtl8723ae_init_aspm_vars(hw);
+	rtl8723e_init_aspm_vars(hw);
 
 	if (rtlpriv->psc.reg_fwctrl_lps == 1)
 		rtlpriv->psc.fwctrl_psmode = FW_PS_MIN_MODE;
@@ -186,7 +189,7 @@ int rtl8723ae_init_sw_vars(struct ieee80211_hw *hw)
 	return 0;
 }
 
-void rtl8723ae_deinit_sw_vars(struct ieee80211_hw *hw)
+void rtl8723e_deinit_sw_vars(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
@@ -196,59 +199,69 @@ void rtl8723ae_deinit_sw_vars(struct ieee80211_hw *hw)
 	}
 }
 
-static bool is_fw_header(struct rtl92c_firmware_header *hdr)
+/* get bt coexist status */
+bool rtl8723e_get_btc_status(void)
+{
+	return true;
+}
+
+static bool is_fw_header(struct rtl8723e_firmware_header *hdr)
 {
 	return (hdr->signature & 0xfff0) == 0x2300;
 }
 
-static struct rtl_hal_ops rtl8723ae_hal_ops = {
-	.init_sw_vars = rtl8723ae_init_sw_vars,
-	.deinit_sw_vars = rtl8723ae_deinit_sw_vars,
-	.read_eeprom_info = rtl8723ae_read_eeprom_info,
-	.interrupt_recognized = rtl8723ae_interrupt_recognized,
-	.hw_init = rtl8723ae_hw_init,
-	.hw_disable = rtl8723ae_card_disable,
-	.hw_suspend = rtl8723ae_suspend,
-	.hw_resume = rtl8723ae_resume,
-	.enable_interrupt = rtl8723ae_enable_interrupt,
-	.disable_interrupt = rtl8723ae_disable_interrupt,
-	.set_network_type = rtl8723ae_set_network_type,
-	.set_chk_bssid = rtl8723ae_set_check_bssid,
-	.set_qos = rtl8723ae_set_qos,
-	.set_bcn_reg = rtl8723ae_set_beacon_related_registers,
-	.set_bcn_intv = rtl8723ae_set_beacon_interval,
-	.update_interrupt_mask = rtl8723ae_update_interrupt_mask,
-	.get_hw_reg = rtl8723ae_get_hw_reg,
-	.set_hw_reg = rtl8723ae_set_hw_reg,
-	.update_rate_tbl = rtl8723ae_update_hal_rate_tbl,
-	.fill_tx_desc = rtl8723ae_tx_fill_desc,
-	.fill_tx_cmddesc = rtl8723ae_tx_fill_cmddesc,
-	.query_rx_desc = rtl8723ae_rx_query_desc,
-	.set_channel_access = rtl8723ae_update_channel_access_setting,
-	.radio_onoff_checking = rtl8723ae_gpio_radio_on_off_checking,
-	.set_bw_mode = rtl8723ae_phy_set_bw_mode,
-	.switch_channel = rtl8723ae_phy_sw_chnl,
-	.dm_watchdog = rtl8723ae_dm_watchdog,
-	.scan_operation_backup = rtl_phy_scan_operation_backup,
-	.set_rf_power_state = rtl8723ae_phy_set_rf_power_state,
-	.led_control = rtl8723ae_led_control,
-	.set_desc = rtl8723ae_set_desc,
-	.get_desc = rtl8723ae_get_desc,
-	.tx_polling = rtl8723ae_tx_polling,
-	.enable_hw_sec = rtl8723ae_enable_hw_security_config,
-	.set_key = rtl8723ae_set_key,
-	.init_sw_leds = rtl8723ae_init_sw_leds,
+static struct rtl_hal_ops rtl8723e_hal_ops = {
+	.init_sw_vars = rtl8723e_init_sw_vars,
+	.deinit_sw_vars = rtl8723e_deinit_sw_vars,
+	.read_eeprom_info = rtl8723e_read_eeprom_info,
+	.interrupt_recognized = rtl8723e_interrupt_recognized,
+	.hw_init = rtl8723e_hw_init,
+	.hw_disable = rtl8723e_card_disable,
+	.hw_suspend = rtl8723e_suspend,
+	.hw_resume = rtl8723e_resume,
+	.enable_interrupt = rtl8723e_enable_interrupt,
+	.disable_interrupt = rtl8723e_disable_interrupt,
+	.set_network_type = rtl8723e_set_network_type,
+	.set_chk_bssid = rtl8723e_set_check_bssid,
+	.set_qos = rtl8723e_set_qos,
+	.set_bcn_reg = rtl8723e_set_beacon_related_registers,
+	.set_bcn_intv = rtl8723e_set_beacon_interval,
+	.update_interrupt_mask = rtl8723e_update_interrupt_mask,
+	.get_hw_reg = rtl8723e_get_hw_reg,
+	.set_hw_reg = rtl8723e_set_hw_reg,
+	.update_rate_tbl = rtl8723e_update_hal_rate_tbl,
+	.fill_tx_desc = rtl8723e_tx_fill_desc,
+	.fill_tx_cmddesc = rtl8723e_tx_fill_cmddesc,
+	.query_rx_desc = rtl8723e_rx_query_desc,
+	.set_channel_access = rtl8723e_update_channel_access_setting,
+	.radio_onoff_checking = rtl8723e_gpio_radio_on_off_checking,
+	.set_bw_mode = rtl8723e_phy_set_bw_mode,
+	.switch_channel = rtl8723e_phy_sw_chnl,
+	.dm_watchdog = rtl8723e_dm_watchdog,
+	.scan_operation_backup = rtl8723e_phy_scan_operation_backup,
+	.set_rf_power_state = rtl8723e_phy_set_rf_power_state,
+	.led_control = rtl8723e_led_control,
+	.set_desc = rtl8723e_set_desc,
+	.get_desc = rtl8723e_get_desc,
+	.is_tx_desc_closed = rtl8723e_is_tx_desc_closed,
+	.tx_polling = rtl8723e_tx_polling,
+	.enable_hw_sec = rtl8723e_enable_hw_security_config,
+	.set_key = rtl8723e_set_key,
+	.init_sw_leds = rtl8723e_init_sw_leds,
 	.get_bbreg = rtl8723_phy_query_bb_reg,
 	.set_bbreg = rtl8723_phy_set_bb_reg,
-	.get_rfreg = rtl8723ae_phy_query_rf_reg,
-	.set_rfreg = rtl8723ae_phy_set_rf_reg,
+	.get_rfreg = rtl8723e_phy_query_rf_reg,
+	.set_rfreg = rtl8723e_phy_set_rf_reg,
 	.c2h_command_handle = rtl_8723e_c2h_command_handle,
 	.bt_wifi_media_status_notify = rtl_8723e_bt_wifi_media_status_notify,
-	.bt_coex_off_before_lps = rtl8723ae_bt_coex_off_before_lps,
+	.bt_coex_off_before_lps =
+		rtl8723e_dm_bt_turn_off_bt_coexist_before_enter_lps,
+	.get_btc_status = rtl8723e_get_btc_status,
+	.rx_command_packet = rtl8723e_rx_command_packet,
 	.is_fw_header = is_fw_header,
 };
 
-static struct rtl_mod_params rtl8723ae_mod_params = {
+static struct rtl_mod_params rtl8723e_mod_params = {
 	.sw_crypto = false,
 	.inactiveps = true,
 	.swctrl_lps = false,
@@ -256,13 +269,13 @@ static struct rtl_mod_params rtl8723ae_mod_params = {
 	.debug = DBG_EMERG,
 };
 
-static struct rtl_hal_cfg rtl8723ae_hal_cfg = {
+static struct rtl_hal_cfg rtl8723e_hal_cfg = {
 	.bar_id = 2,
 	.write_readback = true,
-	.name = "rtl8723ae_pci",
-	.fw_name = "rtlwifi/rtl8723fw.bin",
-	.ops = &rtl8723ae_hal_ops,
-	.mod_params = &rtl8723ae_mod_params,
+	.name = "rtl8723e_pci",
+	.fw_name = "rtlwifi/rtl8723efw.bin",
+	.ops = &rtl8723e_hal_ops,
+	.mod_params = &rtl8723e_mod_params,
 	.maps[SYS_ISO_CTRL] = REG_SYS_ISO_CTRL,
 	.maps[SYS_FUNC_EN] = REG_SYS_FUNC_EN,
 	.maps[SYS_CLK] = REG_SYS_CLKR,
@@ -271,6 +284,8 @@ static struct rtl_hal_cfg rtl8723ae_hal_cfg = {
 	.maps[MAC_RCR_ACRC32] = ACRC32,
 	.maps[MAC_RCR_ACF] = ACF,
 	.maps[MAC_RCR_AAP] = AAP,
+	.maps[MAC_HIMR] = REG_HIMR,
+	.maps[MAC_HIMRE] = REG_HIMRE,
 	.maps[EFUSE_TEST] = REG_EFUSE_TEST,
 	.maps[EFUSE_CTRL] = REG_EFUSE_CTRL,
 	.maps[EFUSE_CLK] = 0,
@@ -328,62 +343,63 @@ static struct rtl_hal_cfg rtl8723ae_hal_cfg = {
 	.maps[RTL_IMR_VIDOK] = PHIMR_VIDOK,
 	.maps[RTL_IMR_VODOK] = PHIMR_VODOK,
 	.maps[RTL_IMR_ROK] = PHIMR_ROK,
-	.maps[RTL_IBSS_INT_MASKS] = (PHIMR_BCNDMAINT0 |
-				     PHIMR_TXBCNOK | PHIMR_TXBCNERR),
+	.maps[RTL_IBSS_INT_MASKS] =
+		(PHIMR_BCNDMAINT0 | PHIMR_TXBCNOK | PHIMR_TXBCNERR),
 	.maps[RTL_IMR_C2HCMD] = PHIMR_C2HCMD,
 
 
-	.maps[RTL_RC_CCK_RATE1M] = DESC92_RATE1M,
-	.maps[RTL_RC_CCK_RATE2M] = DESC92_RATE2M,
-	.maps[RTL_RC_CCK_RATE5_5M] = DESC92_RATE5_5M,
-	.maps[RTL_RC_CCK_RATE11M] = DESC92_RATE11M,
-	.maps[RTL_RC_OFDM_RATE6M] = DESC92_RATE6M,
-	.maps[RTL_RC_OFDM_RATE9M] = DESC92_RATE9M,
-	.maps[RTL_RC_OFDM_RATE12M] = DESC92_RATE12M,
-	.maps[RTL_RC_OFDM_RATE18M] = DESC92_RATE18M,
-	.maps[RTL_RC_OFDM_RATE24M] = DESC92_RATE24M,
-	.maps[RTL_RC_OFDM_RATE36M] = DESC92_RATE36M,
-	.maps[RTL_RC_OFDM_RATE48M] = DESC92_RATE48M,
-	.maps[RTL_RC_OFDM_RATE54M] = DESC92_RATE54M,
-
-	.maps[RTL_RC_HT_RATEMCS7] = DESC92_RATEMCS7,
-	.maps[RTL_RC_HT_RATEMCS15] = DESC92_RATEMCS15,
+	.maps[RTL_RC_CCK_RATE1M] = DESC92C_RATE1M,
+	.maps[RTL_RC_CCK_RATE2M] = DESC92C_RATE2M,
+	.maps[RTL_RC_CCK_RATE5_5M] = DESC92C_RATE5_5M,
+	.maps[RTL_RC_CCK_RATE11M] = DESC92C_RATE11M,
+	.maps[RTL_RC_OFDM_RATE6M] = DESC92C_RATE6M,
+	.maps[RTL_RC_OFDM_RATE9M] = DESC92C_RATE9M,
+	.maps[RTL_RC_OFDM_RATE12M] = DESC92C_RATE12M,
+	.maps[RTL_RC_OFDM_RATE18M] = DESC92C_RATE18M,
+	.maps[RTL_RC_OFDM_RATE24M] = DESC92C_RATE24M,
+	.maps[RTL_RC_OFDM_RATE36M] = DESC92C_RATE36M,
+	.maps[RTL_RC_OFDM_RATE48M] = DESC92C_RATE48M,
+	.maps[RTL_RC_OFDM_RATE54M] = DESC92C_RATE54M,
+
+	.maps[RTL_RC_HT_RATEMCS7] = DESC92C_RATEMCS7,
+	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
 };
 
-static struct pci_device_id rtl8723ae_pci_ids[] = {
-	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8723, rtl8723ae_hal_cfg)},
+static struct pci_device_id rtl8723e_pci_ids[] = {
+	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8723, rtl8723e_hal_cfg)},
 	{},
 };
 
-MODULE_DEVICE_TABLE(pci, rtl8723ae_pci_ids);
+MODULE_DEVICE_TABLE(pci, rtl8723e_pci_ids);
 
 MODULE_AUTHOR("lizhaoming	<chaoming_li@realsil.com.cn>");
 MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
-MODULE_AUTHOR("Larry Finger	<Larry.Finger@lwfinger.net>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Realtek 8723E 802.11n PCI wireless");
-MODULE_FIRMWARE("rtlwifi/rtl8723fw.bin");
-MODULE_FIRMWARE("rtlwifi/rtl8723fw_B.bin");
-
-module_param_named(swenc, rtl8723ae_mod_params.sw_crypto, bool, 0444);
-module_param_named(debug, rtl8723ae_mod_params.debug, int, 0444);
-module_param_named(ips, rtl8723ae_mod_params.inactiveps, bool, 0444);
-module_param_named(swlps, rtl8723ae_mod_params.swctrl_lps, bool, 0444);
-module_param_named(fwlps, rtl8723ae_mod_params.fwctrl_lps, bool, 0444);
+MODULE_FIRMWARE("rtlwifi/rtl8723efw.bin");
+
+module_param_named(swenc, rtl8723e_mod_params.sw_crypto, bool, 0444);
+module_param_named(debug, rtl8723e_mod_params.debug, int, 0444);
+module_param_named(ips, rtl8723e_mod_params.inactiveps, bool, 0444);
+module_param_named(swlps, rtl8723e_mod_params.swctrl_lps, bool, 0444);
+module_param_named(fwlps, rtl8723e_mod_params.fwctrl_lps, bool, 0444);
+module_param_named(disable_watchdog, rtl8723e_mod_params.disable_watchdog,
+		   bool, 0444);
 MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
 MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)\n");
 MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (default 0)\n");
 MODULE_PARM_DESC(fwlps, "Set to 1 to use FW control power save (default 1)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
+MODULE_PARM_DESC(disable_watchdog, "Set to 1 to disable the watchdog (default 0)\n");
 
 static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
 
-static struct pci_driver rtl8723ae_driver = {
+static struct pci_driver rtl8723e_driver = {
 	.name = KBUILD_MODNAME,
-	.id_table = rtl8723ae_pci_ids,
+	.id_table = rtl8723e_pci_ids,
 	.probe = rtl_pci_probe,
 	.remove = rtl_pci_disconnect,
 	.driver.pm = &rtlwifi_pm_ops,
 };
 
-module_pci_driver(rtl8723ae_driver);
+module_pci_driver(rtl8723e_driver);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.h b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.h
index fc4fde5..4647878 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.h
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
@@ -30,8 +26,10 @@
 #ifndef __RTL8723E_SW_H__
 #define __RTL8723E_SW_H__
 
-int rtl8723ae_init_sw_vars(struct ieee80211_hw *hw);
-void rtl8723ae_deinit_sw_vars(struct ieee80211_hw *hw);
-void rtl8723ae_init_var_map(struct ieee80211_hw *hw);
+int rtl8723e_init_sw_vars(struct ieee80211_hw *hw);
+void rtl8723e_deinit_sw_vars(struct ieee80211_hw *hw);
+void rtl8723e_init_var_map(struct ieee80211_hw *hw);
+bool rtl8723e_get_btc_status(void);
+
 
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/table.c b/drivers/net/wireless/rtlwifi/rtl8723ae/table.c
index 9b0b50c..61e8604 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/table.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/table.c
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
@@ -335,7 +331,7 @@ u32 RTL8723EPHY_REG_ARRAY_PG[RTL8723E_PHY_REG_ARRAY_PGLENGTH] = {
 	0x868, 0xffffffff, 0x00000000,
 };
 
-u32 RTL8723E_RADIOA_1TARRAY[Rtl8723ERADIOA_1TARRAYLENGTH] = {
+u32 RTL8723E_RADIOA_1TARRAY[RTL8723ERADIOA_1TARRAYLENGTH] = {
 	0x000, 0x00030159,
 	0x001, 0x00031284,
 	0x002, 0x00098000,
@@ -479,12 +475,10 @@ u32 RTL8723E_RADIOA_1TARRAY[Rtl8723ERADIOA_1TARRAYLENGTH] = {
 	0x000, 0x00030159,
 };
 
-
 u32 RTL8723E_RADIOB_1TARRAY[RTL8723E_RADIOB_1TARRAYLENGTH] = {
 	0x0,
 };
 
-
 u32 RTL8723EMAC_ARRAY[RTL8723E_MACARRAYLENGTH] = {
 	0x420, 0x00000080,
 	0x423, 0x00000000,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/table.h b/drivers/net/wireless/rtlwifi/rtl8723ae/table.h
index f5ce713..57a548c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/table.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/table.h
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
@@ -38,8 +34,8 @@
 extern u32 RTL8723EPHY_REG_1TARRAY[RTL8723E_PHY_REG_1TARRAY_LENGTH];
 #define RTL8723E_PHY_REG_ARRAY_PGLENGTH		336
 extern u32 RTL8723EPHY_REG_ARRAY_PG[RTL8723E_PHY_REG_ARRAY_PGLENGTH];
-#define Rtl8723ERADIOA_1TARRAYLENGTH		 282
-extern u32 RTL8723E_RADIOA_1TARRAY[Rtl8723ERADIOA_1TARRAYLENGTH];
+#define RTL8723ERADIOA_1TARRAYLENGTH		282
+extern u32 RTL8723E_RADIOA_1TARRAY[RTL8723ERADIOA_1TARRAYLENGTH];
 #define RTL8723E_RADIOB_1TARRAYLENGTH		1
 extern u32 RTL8723E_RADIOB_1TARRAY[RTL8723E_RADIOB_1TARRAYLENGTH];
 #define RTL8723E_MACARRAYLENGTH			172
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index 10b7577..ca84150 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
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
@@ -37,7 +33,7 @@
 #include "trx.h"
 #include "led.h"
 
-static u8 _rtl8723ae_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
+static u8 _rtl8723e_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 {
 	__le16 fc = rtl_get_fc(skb);
 
@@ -49,16 +45,174 @@ static u8 _rtl8723ae_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
 	return skb->priority;
 }
 
-static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
-			struct rtl_stats *pstatus, u8 *pdesc,
-			struct rx_fwinfo_8723e *p_drvinfo,
-			bool bpacket_match_bssid,
-			bool bpacket_toself, bool packet_beacon)
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
+static int _rtl8723e_rate_mapping(struct ieee80211_hw *hw,
+				  bool isht, u8 desc_rate)
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
+static void _rtl8723e_query_rxphystatus(struct ieee80211_hw *hw,
+					struct rtl_stats *pstatus, u8 *pdesc,
+					struct rx_fwinfo_8723e *p_drvinfo,
+					bool bpacket_match_bssid,
+					bool bpacket_toself, bool packet_beacon)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
 	struct phy_sts_cck_8723e_t *cck_buf;
-	s8 rx_pwr_all, rx_pwr[4];
+	s8 rx_pwr_all = 0, rx_pwr[4];
 	u8 rf_rx_num = 0, evm, pwdb_all;
 	u8 i, max_spatial_stream;
 	u32 rssi, total_rssi = 0;
@@ -68,8 +222,8 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 	pstatus->packet_matchbssid = bpacket_match_bssid;
 	pstatus->packet_toself = bpacket_toself;
 	pstatus->packet_beacon = packet_beacon;
-	pstatus->rx_mimo_sig_qual[0] = -1;
-	pstatus->rx_mimo_sig_qual[1] = -1;
+	pstatus->rx_mimo_signalquality[0] = -1;
+	pstatus->rx_mimo_signalquality[1] = -1;
 
 	if (is_cck) {
 		u8 report, cck_highpwr;
@@ -77,14 +231,14 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 		/* CCK Driver info Structure is not the same as OFDM packet. */
 		cck_buf = (struct phy_sts_cck_8723e_t *)p_drvinfo;
 
-		/* (1)Hardware does not provide RSSI for CCK
-		 * (2)PWDB, Average PWDB cacluated by
+		/* (1)Hardware does not provide RSSI for CCK */
+		/* (2)PWDB, Average PWDB cacluated by
 		 * hardware (for rate adaptive)
 		 */
 		if (ppsc->rfpwr_state == ERFON)
-			cck_highpwr = (u8) rtl_get_bbreg(hw,
-						 RFPGA0_XA_HSSIPARAMETER2,
-						 BIT(9));
+			cck_highpwr = (u8)rtl_get_bbreg(hw,
+					RFPGA0_XA_HSSIPARAMETER2,
+					BIT(9));
 		else
 			cck_highpwr = false;
 
@@ -127,8 +281,9 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 		}
 
 		pwdb_all = rtl_query_rxpwrpercentage(rx_pwr_all);
-		/* CCK gain is smaller than OFDM/MCS gain,
-		 * so we add gain diff. From experience, the val is 6
+		/* CCK gain is smaller than OFDM/MCS gain,  */
+		/* so we add gain diff by experiences,
+		 * the val is 6
 		 */
 		pwdb_all += 6;
 		if (pwdb_all > 100)
@@ -152,9 +307,9 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
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
@@ -165,8 +320,8 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 			}
 
 			pstatus->signalquality = sq;
-			pstatus->rx_mimo_sig_qual[0] = sq;
-			pstatus->rx_mimo_sig_qual[1] = -1;
+			pstatus->rx_mimo_signalquality[0] = sq;
+			pstatus->rx_mimo_signalquality[1] = -1;
 		}
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] =
@@ -179,18 +334,20 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 			if (rtlpriv->dm.rfpath_rxenable[i])
 				rf_rx_num++;
 
-			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] & 0x3f)*2) - 110;
+			rx_pwr[i] = ((p_drvinfo->gain_trsw[i] &
+				      0x3f) * 2) - 110;
 
 			/* Translate DBM to percentage. */
 			rssi = rtl_query_rxpwrpercentage(rx_pwr[i]);
 			total_rssi += rssi;
 
 			/* Get Rx snr value in DB */
-			rtlpriv->stats.rx_snr_db[i] = (p_drvinfo->rxsnr[i] / 2);
+			rtlpriv->stats.rx_snr_db[i] =
+				(long)(p_drvinfo->rxsnr[i] / 2);
 
 			/* Record Signal Strength for next packet */
 			if (bpacket_match_bssid)
-				pstatus->rx_mimo_signalstrength[i] = (u8) rssi;
+				pstatus->rx_mimo_signalstrength[i] = (u8)rssi;
 		}
 
 		/* (2)PWDB, Average PWDB cacluated by
@@ -204,8 +361,8 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 		pstatus->recvsignalpower = rx_pwr_all;
 
 		/* (3)EVM of HT rate */
-		if (pstatus->is_ht && pstatus->rate >= DESC92_RATEMCS8 &&
-		    pstatus->rate <= DESC92_RATEMCS15)
+		if (pstatus->is_ht && pstatus->rate >= DESC92C_RATEMCS8 &&
+		    pstatus->rate <= DESC92C_RATEMCS15)
 			max_spatial_stream = 2;
 		else
 			max_spatial_stream = 1;
@@ -218,8 +375,10 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 				 * spatial stream only
 				 */
 				if (i == 0)
-					pstatus->signalquality = (evm & 0xff);
-				pstatus->rx_mimo_sig_qual[i] = (evm & 0xff);
+					pstatus->signalquality =
+						(u8)(evm & 0xff);
+				pstatus->rx_mimo_signalquality[i] =
+					(u8)(evm & 0xff);
 			}
 		}
 	}
@@ -235,71 +394,73 @@ static void _rtl8723ae_query_rxphystatus(struct ieee80211_hw *hw,
 			total_rssi /= rf_rx_num));
 }
 
-static void _rtl8723ae_translate_rx_signal_stuff(struct ieee80211_hw *hw,
-		struct sk_buff *skb, struct rtl_stats *pstatus,
-		u8 *pdesc, struct rx_fwinfo_8723e *p_drvinfo)
+static void translate_rx_signal_stuff(struct ieee80211_hw *hw,
+				      struct sk_buff *skb,
+				      struct rtl_stats *pstatus, u8 *pdesc,
+				      struct rx_fwinfo_8723e *p_drvinfo)
 {
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	struct ieee80211_hdr *hdr;
 	u8 *tmp_buf;
 	u8 *praddr;
-	__le16 fc;
-	u16 type;
-	bool packet_matchbssid, packet_toself, packet_beacon = false;
+	/*u8 *psaddr;*/
+	u16 fc, type;
+	bool packet_matchbssid, packet_toself, packet_beacon;
 
 	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
 
 	hdr = (struct ieee80211_hdr *)tmp_buf;
-	fc = hdr->frame_control;
-	type = WLAN_FC_GET_TYPE(fc);
+	fc = le16_to_cpu(hdr->frame_control);
+	type = WLAN_FC_GET_TYPE(hdr->frame_control);
 	praddr = hdr->addr1;
 
-	packet_matchbssid =
-		((IEEE80211_FTYPE_CTL != type) &&
-		 ether_addr_equal(mac->bssid,
-				  (le16_to_cpu(fc) & IEEE80211_FCTL_TODS) ? hdr->addr1 :
-				  (le16_to_cpu(fc) & IEEE80211_FCTL_FROMDS) ? hdr->addr2 :
-				  hdr->addr3) &&
-		 (!pstatus->hwerror) && (!pstatus->crc) && (!pstatus->icv));
+	packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
+		(ether_addr_equal(mac->bssid, (fc & IEEE80211_FCTL_TODS) ?
+		 hdr->addr1 : (fc & IEEE80211_FCTL_FROMDS) ?
+		 hdr->addr2 : hdr->addr3)) &&
+		 (!pstatus->hwerror) &&
+		 (!pstatus->crc) && (!pstatus->icv));
 
-	packet_toself = (packet_matchbssid &&
-			 ether_addr_equal(praddr, rtlefuse->dev_addr));
+	packet_toself = packet_matchbssid &&
+	    (ether_addr_equal(praddr, rtlefuse->dev_addr));
 
-	if (ieee80211_is_beacon(fc))
+	if (ieee80211_is_beacon(hdr->frame_control))
 		packet_beacon = true;
+	else
+		packet_beacon = false;
 
-	_rtl8723ae_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
-				   packet_matchbssid, packet_toself,
-				   packet_beacon);
+	_rtl8723e_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
+				    packet_matchbssid, packet_toself,
+				    packet_beacon);
 
 	rtl_process_phyinfo(hw, tmp_buf, pstatus);
 }
 
-bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
-			     struct rtl_stats *status,
-			     struct ieee80211_rx_status *rx_status,
-			     u8 *pdesc, struct sk_buff *skb)
+bool rtl8723e_rx_query_desc(struct ieee80211_hw *hw,
+			    struct rtl_stats *status,
+			    struct ieee80211_rx_status *rx_status,
+			    u8 *pdesc, struct sk_buff *skb)
 {
 	struct rx_fwinfo_8723e *p_drvinfo;
 	struct ieee80211_hdr *hdr;
 	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
 
-	status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
-	status->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
-				   RX_DRV_INFO_SIZE_UNIT;
-	status->rx_bufshift = (u8) (GET_RX_DESC_SHIFT(pdesc) & 0x03);
-	status->icv = (u16) GET_RX_DESC_ICV(pdesc);
-	status->crc = (u16) GET_RX_DESC_CRC32(pdesc);
+	status->length = (u16)GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size = (u8)GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+	    RX_DRV_INFO_SIZE_UNIT;
+	status->rx_bufshift = (u8)(GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->icv = (u16)GET_RX_DESC_ICV(pdesc);
+	status->crc = (u16)GET_RX_DESC_CRC32(pdesc);
 	status->hwerror = (status->crc | status->icv);
 	status->decrypted = !GET_RX_DESC_SWDEC(pdesc);
-	status->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
-	status->shortpreamble = (u16) GET_RX_DESC_SPLCP(pdesc);
-	status->isampdu = (bool) (GET_RX_DESC_PAGGR(pdesc) == 1);
-	status->isfirst_ampdu = (bool) ((GET_RX_DESC_PAGGR(pdesc) == 1)
-				 && (GET_RX_DESC_FAGGR(pdesc) == 1));
+	status->rate = (u8)GET_RX_DESC_RXMCS(pdesc);
+	status->shortpreamble = (u16)GET_RX_DESC_SPLCP(pdesc);
+	status->isampdu = (bool)(GET_RX_DESC_PAGGR(pdesc) == 1);
+	status->isfirst_ampdu = (bool)((GET_RX_DESC_PAGGR(pdesc) == 1) &&
+				       (GET_RX_DESC_FAGGR(pdesc) == 1));
 	status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
-	status->rx_is40Mhzpacket = (bool) GET_RX_DESC_BW(pdesc);
+	status->rx_is40Mhzpacket = (bool)GET_RX_DESC_BW(pdesc);
 	status->is_ht = (bool)GET_RX_DESC_RXHT(pdesc);
 
 	status->is_cck = RTL8723E_RX_HAL_IS_CCK_RATE(status->rate);
@@ -307,6 +468,9 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
 	rx_status->freq = hw->conf.chandef.chan->center_freq;
 	rx_status->band = hw->conf.chandef.chan->band;
 
+	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size
+			+ status->rx_bufshift);
+
 	if (status->crc)
 		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
 
@@ -320,69 +484,68 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
 
 	/* hw will set status->decrypted true, if it finds the
 	 * frame is open data frame or mgmt frame.
-	 * Thus hw will not decrypt a robust managment frame
+	 * So hw will not decryption robust managment frame
 	 * for IEEE80211w but still set status->decrypted
 	 * true, so here we should set it back to undecrypted
 	 * for IEEE80211w frame, and mac80211 sw will help
 	 * to decrypt it
 	 */
 	if (status->decrypted) {
-		hdr = (struct ieee80211_hdr *)(skb->data +
-		       status->rx_drvinfo_size + status->rx_bufshift);
-
 		if (!hdr) {
-			/* during testing, hdr could be NULL here */
+			WARN_ON_ONCE(true);
+			pr_err("decrypted is true but hdr NULL, from skb %p\n",
+			       rtl_get_hdr(skb));
 			return false;
 		}
-		if ((_ieee80211_is_robust_mgmt_frame(hdr)) &&
-			(ieee80211_has_protected(hdr->frame_control)))
-			rx_status->flag &= ~RX_FLAG_DECRYPTED;
-		else
+		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
+		    (ieee80211_has_protected(hdr->frame_control)))
 			rx_status->flag |= RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
 	}
 
 	/* rate_idx: index of data rate into band's
 	 * supported rates or MCS index if HT rates
 	 * are use (RX_FLAG_HT)
+	 * Notice: this is diff with windows define
 	 */
-	rx_status->rate_idx = rtlwifi_rate_mapping(hw, status->is_ht,
-						   status->rate, false);
+	rx_status->rate_idx = _rtl8723e_rate_mapping(hw,
+				status->is_ht, status->rate);
 
 	rx_status->mactime = status->timestamp_low;
 	if (phystatus == true) {
 		p_drvinfo = (struct rx_fwinfo_8723e *)(skb->data +
-			     status->rx_bufshift);
+						     status->rx_bufshift);
 
-		_rtl8723ae_translate_rx_signal_stuff(hw,
-			   skb, status, pdesc, p_drvinfo);
+		translate_rx_signal_stuff(hw, skb, status, pdesc, p_drvinfo);
 	}
-
-	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
-
 	return true;
 }
 
-void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
-			    struct ieee80211_hdr *hdr, u8 *pdesc_tx,
-			    u8 *pbd_desc_tx, struct ieee80211_tx_info *info,
-			    struct ieee80211_sta *sta,
-			    struct sk_buff *skb, u8 hw_queue,
-			    struct rtl_tcb_desc *ptcdesc)
+void rtl8723e_tx_fill_desc(struct ieee80211_hw *hw,
+			   struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			   u8 *txbd, struct ieee80211_tx_info *info,
+			   struct ieee80211_sta *sta,
+			   struct sk_buff *skb,
+			   u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
-	bool defaultadapter = true;
-	u8 *pdesc = pdesc_tx;
+	bool b_defaultadapter = true;
+	/* bool b_trigger_ac = false; */
+	u8 *pdesc = (u8 *)pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
-	u8 fw_qsel = _rtl8723ae_map_hwqueue_to_fwqueue(skb, hw_queue);
+	u8 fw_qsel = _rtl8723e_map_hwqueue_to_fwqueue(skb, hw_queue);
 	bool firstseg = ((hdr->seq_ctrl &
-			    cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+			  cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+
 	bool lastseg = ((hdr->frame_control &
-			   cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+			 cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+
 	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
 					    skb->data, skb->len,
 					    PCI_DMA_TODEVICE);
@@ -398,12 +561,13 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 	} else if (mac->opmode == NL80211_IFTYPE_AP ||
 		mac->opmode == NL80211_IFTYPE_ADHOC) {
 		if (sta)
-			bw_40 = sta->bandwidth >= IEEE80211_STA_RX_BW_40;
+			bw_40 = sta->ht_cap.cap &
+				IEEE80211_HT_CAP_SUP_WIDTH_20_40;
 	}
 
 	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
 
-	rtl_get_tcb_desc(hw, info, sta, skb, ptcdesc);
+	rtl_get_tcb_desc(hw, info, sta, skb, ptcb_desc);
 
 	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_8723e));
 
@@ -415,9 +579,9 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 	if (firstseg) {
 		SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
 
-		SET_TX_DESC_TX_RATE(pdesc, ptcdesc->hw_rate);
+		SET_TX_DESC_TX_RATE(pdesc, ptcb_desc->hw_rate);
 
-		if (ptcdesc->use_shortgi || ptcdesc->use_shortpreamble)
+		if (ptcb_desc->use_shortgi || ptcb_desc->use_shortpreamble)
 			SET_TX_DESC_DATA_SHORTGI(pdesc, 1);
 
 		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
@@ -426,31 +590,33 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 		}
 		SET_TX_DESC_SEQ(pdesc, seq_number);
 
-		SET_TX_DESC_RTS_ENABLE(pdesc, ((ptcdesc->rts_enable &&
-						!ptcdesc->
-						cts_enable) ? 1 : 0));
+		SET_TX_DESC_RTS_ENABLE(pdesc,
+				       ((ptcb_desc->rts_enable &&
+					!ptcb_desc->cts_enable) ? 1 : 0));
 		SET_TX_DESC_HW_RTS_ENABLE(pdesc,
-					  ((ptcdesc->rts_enable
-					    || ptcdesc->cts_enable) ? 1 : 0));
-		SET_TX_DESC_CTS2SELF(pdesc, ((ptcdesc->cts_enable) ? 1 : 0));
-		SET_TX_DESC_RTS_STBC(pdesc, ((ptcdesc->rts_stbc) ? 1 : 0));
-
-		SET_TX_DESC_RTS_RATE(pdesc, ptcdesc->rts_rate);
+					  ((ptcb_desc->rts_enable ||
+					  ptcb_desc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_CTS2SELF(pdesc,
+				     ((ptcb_desc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_RTS_STBC(pdesc,
+				     ((ptcb_desc->rts_stbc) ? 1 : 0));
+
+		SET_TX_DESC_RTS_RATE(pdesc, ptcb_desc->rts_rate);
 		SET_TX_DESC_RTS_BW(pdesc, 0);
-		SET_TX_DESC_RTS_SC(pdesc, ptcdesc->rts_sc);
+		SET_TX_DESC_RTS_SC(pdesc, ptcb_desc->rts_sc);
 		SET_TX_DESC_RTS_SHORT(pdesc,
-				      ((ptcdesc->rts_rate <= DESC92_RATE54M) ?
-				       (ptcdesc->rts_use_shortpreamble ? 1 : 0)
-				       : (ptcdesc->rts_use_shortgi ? 1 : 0)));
+				((ptcb_desc->rts_rate <= DESC92C_RATE54M) ?
+				(ptcb_desc->rts_use_shortpreamble ? 1 : 0)
+				: (ptcb_desc->rts_use_shortgi ? 1 : 0)));
 
 		if (bw_40) {
-			if (ptcdesc->packet_bw) {
+			if (ptcb_desc->packet_bw == HT_CHANNEL_WIDTH_20_40) {
 				SET_TX_DESC_DATA_BW(pdesc, 1);
 				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
 			} else {
 				SET_TX_DESC_DATA_BW(pdesc, 0);
 				SET_TX_DESC_TX_SUB_CARRIER(pdesc,
-							 mac->cur_40_prime_sc);
+					mac->cur_40_prime_sc);
 			}
 		} else {
 			SET_TX_DESC_DATA_BW(pdesc, 0);
@@ -481,6 +647,7 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 			default:
 				SET_TX_DESC_SEC_TYPE(pdesc, 0x0);
 				break;
+
 			}
 		}
 
@@ -490,7 +657,7 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_DATA_RATE_FB_LIMIT(pdesc, 0x1F);
 		SET_TX_DESC_RTS_RATE_FB_LIMIT(pdesc, 0xF);
 		SET_TX_DESC_DISABLE_FB(pdesc, 0);
-		SET_TX_DESC_USE_RATE(pdesc, ptcdesc->use_driver_rate ? 1 : 0);
+		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
 
 		if (ieee80211_is_data_qos(fc)) {
 			if (mac->rdg_en) {
@@ -510,18 +677,21 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
 
 	if (rtlpriv->dm.useramask) {
-		SET_TX_DESC_RATE_ID(pdesc, ptcdesc->ratr_index);
-		SET_TX_DESC_MACID(pdesc, ptcdesc->mac_id);
+		SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
 	} else {
-		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcdesc->ratr_index);
-		SET_TX_DESC_MACID(pdesc, ptcdesc->ratr_index);
+		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->ratr_index);
 	}
 
 	if ((!ieee80211_is_data_qos(fc)) && ppsc->fwctrl_lps) {
 		SET_TX_DESC_HWSEQ_EN_8723(pdesc, 1);
+		/* SET_TX_DESC_HWSEQ_EN(pdesc, 1); */
+		/* SET_TX_DESC_PKT_ID(pdesc, 8); */
 
-		if (!defaultadapter)
+		if (!b_defaultadapter)
 			SET_TX_DESC_HWSEQ_SEL_8723(pdesc, 1);
+	/* SET_TX_DESC_QOS(pdesc, 1); */
 	}
 
 	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
@@ -534,17 +704,19 @@ void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
 	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
 }
 
-void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
+void rtl8723e_tx_fill_cmddesc(struct ieee80211_hw *hw,
 			      u8 *pdesc, bool firstseg,
 			      bool lastseg, struct sk_buff *skb)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
-	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)(skb->data);
 	u8 fw_queue = QSLT_BEACON;
+
 	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
 					    skb->data, skb->len,
 					    PCI_DMA_TODEVICE);
+
+	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)(skb->data);
 	__le16 fc = hdr->frame_control;
 
 	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
@@ -557,7 +729,7 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	if (firstseg)
 		SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
 
-	SET_TX_DESC_TX_RATE(pdesc, DESC92_RATE1M);
+	SET_TX_DESC_TX_RATE(pdesc, DESC92C_RATE1M);
 
 	SET_TX_DESC_SEQ(pdesc, 0);
 
@@ -577,7 +749,7 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	SET_TX_DESC_OWN(pdesc, 1);
 
-	SET_TX_DESC_PKT_SIZE(pdesc, (u16) (skb->len));
+	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
 
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
@@ -597,8 +769,8 @@ void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
 		      pdesc, TX_DESC_SIZE);
 }
 
-void rtl8723ae_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
-			u8 desc_name, u8 *val)
+void rtl8723e_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+		       bool istx, u8 desc_name, u8 *val)
 {
 	if (istx == true) {
 		switch (desc_name) {
@@ -635,7 +807,7 @@ void rtl8723ae_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 	}
 }
 
-u32 rtl8723ae_get_desc(u8 *pdesc, bool istx, u8 desc_name)
+u32 rtl8723e_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 {
 	u32 ret = 0;
 
@@ -660,6 +832,9 @@ u32 rtl8723ae_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 		case HW_DESC_RXPKT_LEN:
 			ret = GET_RX_DESC_PKT_LEN(pdesc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret = GET_RX_DESC_BUFF_ADDR(pdesc);
+			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
@@ -669,7 +844,25 @@ u32 rtl8723ae_get_desc(u8 *pdesc, bool istx, u8 desc_name)
 	return ret;
 }
 
-void rtl8723ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
+bool rtl8723e_is_tx_desc_closed(struct ieee80211_hw *hw,
+				u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+	u8 *entry = (u8 *)(&ring->desc[ring->idx]);
+	u8 own = (u8)rtl8723e_get_desc(entry, true, HW_DESC_OWN);
+
+	/**
+	 *beacon packet will only use the first
+	 *descriptor defautly,and the own may not
+	 *be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	return true;
+}
+
+void rtl8723e_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	if (hw_queue == BEACON_QUEUE) {
@@ -679,3 +872,10 @@ void rtl8723ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 			       BIT(0) << (hw_queue));
 	}
 }
+
+u32 rtl8723e_rx_command_packet(struct ieee80211_hw *hw,
+			       struct rtl_stats status,
+			       struct sk_buff *skb)
+{
+	return 0;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.h b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
index 4380b7d..017da7e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
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
@@ -30,77 +26,77 @@
 #ifndef __RTL8723E_TRX_H__
 #define __RTL8723E_TRX_H__
 
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
-#define SET_TX_DESC_BMC(__pdesc, __val)		\
+#define SET_TX_DESC_BMC(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 24, 1, __val)
-#define SET_TX_DESC_HTC(__pdesc, __val)		\
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
-#define SET_TX_DESC_OWN(__pdesc, __val)		\
+#define SET_TX_DESC_OWN(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
 
-#define GET_TX_DESC_PKT_SIZE(__pdesc)			\
+#define GET_TX_DESC_PKT_SIZE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 0, 16)
-#define GET_TX_DESC_OFFSET(__pdesc)			\
+#define GET_TX_DESC_OFFSET(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 16, 8)
-#define GET_TX_DESC_BMC(__pdesc)			\
+#define GET_TX_DESC_BMC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 24, 1)
-#define GET_TX_DESC_HTC(__pdesc)			\
+#define GET_TX_DESC_HTC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 25, 1)
-#define GET_TX_DESC_LAST_SEG(__pdesc)			\
+#define GET_TX_DESC_LAST_SEG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
-#define GET_TX_DESC_FIRST_SEG(__pdesc)			\
+#define GET_TX_DESC_FIRST_SEG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
-#define GET_TX_DESC_LINIP(__pdesc)			\
+#define GET_TX_DESC_LINIP(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
-#define GET_TX_DESC_NO_ACM(__pdesc)			\
+#define GET_TX_DESC_NO_ACM(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
-#define GET_TX_DESC_GF(__pdesc)				\
+#define GET_TX_DESC_GF(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
-#define GET_TX_DESC_OWN(__pdesc)			\
+#define GET_TX_DESC_OWN(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
 
-#define SET_TX_DESC_MACID(__pdesc, __val)		\
+#define SET_TX_DESC_MACID(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 5, __val)
 #define SET_TX_DESC_AGG_BREAK(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 5, 1, __val)
-#define SET_TX_DESC_BK(__pdesc, __val)			\
+#define SET_TX_DESC_BK(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 6, 1, __val)
 #define SET_TX_DESC_RDG_ENABLE(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 7, 1, __val)
 #define SET_TX_DESC_QUEUE_SEL(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 8, 5, __val)
-#define SET_TX_DESC_RDG_NAV_EXT(__pdesc, __val)	\
+#define SET_TX_DESC_RDG_NAV_EXT(__pdesc, __val)		\
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
@@ -109,34 +105,34 @@
 #define SET_TX_DESC_PKT_OFFSET(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+4, 24, 8, __val)
 
-#define GET_TX_DESC_MACID(__pdesc)			\
+#define GET_TX_DESC_MACID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
-#define GET_TX_DESC_AGG_ENABLE(__pdesc)		\
+#define GET_TX_DESC_AGG_ENABLE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 5, 1)
-#define GET_TX_DESC_AGG_BREAK(__pdesc)			\
+#define GET_TX_DESC_AGG_BREAK(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 6, 1)
-#define GET_TX_DESC_RDG_ENABLE(__pdesc)		\
+#define GET_TX_DESC_RDG_ENABLE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 7, 1)
-#define GET_TX_DESC_QUEUE_SEL(__pdesc)			\
+#define GET_TX_DESC_QUEUE_SEL(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 8, 5)
-#define GET_TX_DESC_RDG_NAV_EXT(__pdesc)		\
+#define GET_TX_DESC_RDG_NAV_EXT(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
-#define GET_TX_DESC_LSIG_TXOP_EN(__pdesc)		\
+#define GET_TX_DESC_LSIG_TXOP_EN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
-#define GET_TX_DESC_PIFS(__pdesc)			\
+#define GET_TX_DESC_PIFS(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
-#define GET_TX_DESC_RATE_ID(__pdesc)			\
+#define GET_TX_DESC_RATE_ID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
-#define GET_TX_DESC_NAV_USE_HDR(__pdesc)		\
+#define GET_TX_DESC_NAV_USE_HDR(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 20, 1)
-#define GET_TX_DESC_EN_DESC_ID(__pdesc)		\
+#define GET_TX_DESC_EN_DESC_ID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 21, 1)
-#define GET_TX_DESC_SEC_TYPE(__pdesc)			\
+#define GET_TX_DESC_SEC_TYPE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 22, 2)
-#define GET_TX_DESC_PKT_OFFSET(__pdesc)		\
+#define GET_TX_DESC_PKT_OFFSET(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 24, 8)
 
-#define SET_TX_DESC_RTS_RC(__pdesc, __val)		\
+#define SET_TX_DESC_RTS_RC(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 6, __val)
 #define SET_TX_DESC_DATA_RC(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 6, 6, __val)
@@ -144,9 +140,9 @@
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 14, 2, __val)
 #define SET_TX_DESC_MORE_FRAG(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 17, 1, __val)
-#define SET_TX_DESC_RAW(__pdesc, __val)		\
+#define SET_TX_DESC_RAW(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 18, 1, __val)
-#define SET_TX_DESC_CCX(__pdesc, __val)		\
+#define SET_TX_DESC_CCX(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 19, 1, __val)
 #define SET_TX_DESC_AMPDU_DENSITY(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 20, 3, __val)
@@ -161,62 +157,62 @@
 #define SET_TX_DESC_TX_ANT_HT(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+8, 30, 2, __val)
 
-#define GET_TX_DESC_RTS_RC(__pdesc)			\
+#define GET_TX_DESC_RTS_RC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 0, 6)
-#define GET_TX_DESC_DATA_RC(__pdesc)			\
+#define GET_TX_DESC_DATA_RC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 6, 6)
-#define GET_TX_DESC_BAR_RTY_TH(__pdesc)		\
+#define GET_TX_DESC_BAR_RTY_TH(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 14, 2)
-#define GET_TX_DESC_MORE_FRAG(__pdesc)			\
+#define GET_TX_DESC_MORE_FRAG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 17, 1)
-#define GET_TX_DESC_RAW(__pdesc)			\
+#define GET_TX_DESC_RAW(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 18, 1)
-#define GET_TX_DESC_CCX(__pdesc)			\
+#define GET_TX_DESC_CCX(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 19, 1)
-#define GET_TX_DESC_AMPDU_DENSITY(__pdesc)		\
+#define GET_TX_DESC_AMPDU_DENSITY(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+8, 20, 3)
-#define GET_TX_DESC_ANTSEL_A(__pdesc)			\
+#define GET_TX_DESC_ANTSEL_A(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 24, 1)
-#define GET_TX_DESC_ANTSEL_B(__pdesc)			\
+#define GET_TX_DESC_ANTSEL_B(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 25, 1)
-#define GET_TX_DESC_TX_ANT_CCK(__pdesc)		\
+#define GET_TX_DESC_TX_ANT_CCK(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 26, 2)
-#define GET_TX_DESC_TX_ANTL(__pdesc)			\
+#define GET_TX_DESC_TX_ANTL(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 28, 2)
-#define GET_TX_DESC_TX_ANT_HT(__pdesc)			\
+#define GET_TX_DESC_TX_ANT_HT(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 30, 2)
 
 #define SET_TX_DESC_NEXT_HEAP_PAGE(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 0, 8, __val)
 #define SET_TX_DESC_TAIL_PAGE(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 8, 8, __val)
-#define SET_TX_DESC_SEQ(__pdesc, __val)		\
+#define SET_TX_DESC_SEQ(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 16, 12, __val)
-#define SET_TX_DESC_PKT_ID(__pdesc, __val)		\
+#define SET_TX_DESC_PKT_ID(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 28, 4, __val)
 
 #define GET_TX_DESC_NEXT_HEAP_PAGE(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+12, 0, 8)
-#define GET_TX_DESC_TAIL_PAGE(__pdesc)			\
+#define GET_TX_DESC_TAIL_PAGE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 8, 8)
-#define GET_TX_DESC_SEQ(__pdesc)			\
+#define GET_TX_DESC_SEQ(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 16, 12)
-#define GET_TX_DESC_PKT_ID(__pdesc)			\
+#define GET_TX_DESC_PKT_ID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 28, 4)
 
 /* For RTL8723 */
 #define SET_TX_DESC_TRIGGER_INT(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 30, 1, __val)
-#define SET_TX_DESC_HWSEQ_EN_8723(__pdesc, __val)	\
+#define SET_TX_DESC_HWSEQ_EN_8723(__pdesc, __val)   \
 	SET_BITS_TO_LE_4BYTE(__pdesc+12, 31, 1, __val)
-#define SET_TX_DESC_HWSEQ_SEL_8723(__pTxDesc, __Value)	\
-	SET_BITS_TO_LE_4BYTE(__pTxDesc+16, 6, 2, __Value)
+#define SET_TX_DESC_HWSEQ_SEL_8723(__txdesc, __value) \
+	SET_BITS_TO_LE_4BYTE(__txdesc+16, 6, 2, __value)
 
 #define SET_TX_DESC_RTS_RATE(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 5, __val)
 #define SET_TX_DESC_AP_DCFE(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 5, 1, __val)
-#define SET_TX_DESC_QOS(__pdesc, __val)		\
+#define SET_TX_DESC_QOS(__pdesc, __val)				\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 6, 1, __val)
 #define SET_TX_DESC_HWSEQ_EN(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 7, 1, __val)
@@ -248,54 +244,54 @@
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 25, 1, __val)
 #define SET_TX_DESC_RTS_SHORT(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 26, 1, __val)
-#define SET_TX_DESC_RTS_BW(__pdesc, __val)		\
+#define SET_TX_DESC_RTS_BW(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 27, 1, __val)
-#define SET_TX_DESC_RTS_SC(__pdesc, __val)		\
+#define SET_TX_DESC_RTS_SC(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 28, 2, __val)
 #define SET_TX_DESC_RTS_STBC(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+16, 30, 2, __val)
 
-#define GET_TX_DESC_RTS_RATE(__pdesc)			\
+#define GET_TX_DESC_RTS_RATE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 0, 5)
-#define GET_TX_DESC_AP_DCFE(__pdesc)			\
+#define GET_TX_DESC_AP_DCFE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 5, 1)
-#define GET_TX_DESC_QOS(__pdesc)			\
+#define GET_TX_DESC_QOS(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 6, 1)
-#define GET_TX_DESC_HWSEQ_EN(__pdesc)			\
+#define GET_TX_DESC_HWSEQ_EN(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 7, 1)
-#define GET_TX_DESC_USE_RATE(__pdesc)			\
+#define GET_TX_DESC_USE_RATE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 8, 1)
 #define GET_TX_DESC_DISABLE_RTS_FB(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+16, 9, 1)
-#define GET_TX_DESC_DISABLE_FB(__pdesc)		\
+#define GET_TX_DESC_DISABLE_FB(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 10, 1)
-#define GET_TX_DESC_CTS2SELF(__pdesc)			\
+#define GET_TX_DESC_CTS2SELF(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 11, 1)
-#define GET_TX_DESC_RTS_ENABLE(__pdesc)		\
+#define GET_TX_DESC_RTS_ENABLE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 12, 1)
-#define GET_TX_DESC_HW_RTS_ENABLE(__pdesc)		\
+#define GET_TX_DESC_HW_RTS_ENABLE(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+16, 13, 1)
-#define GET_TX_DESC_PORT_ID(__pdesc)			\
+#define GET_TX_DESC_PORT_ID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 14, 1)
-#define GET_TX_DESC_WAIT_DCTS(__pdesc)			\
+#define GET_TX_DESC_WAIT_DCTS(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 18, 1)
-#define GET_TX_DESC_CTS2AP_EN(__pdesc)			\
+#define GET_TX_DESC_CTS2AP_EN(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 19, 1)
 #define GET_TX_DESC_TX_SUB_CARRIER(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+16, 20, 2)
-#define GET_TX_DESC_TX_STBC(__pdesc)			\
+#define GET_TX_DESC_TX_STBC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 22, 2)
-#define GET_TX_DESC_DATA_SHORT(__pdesc)		\
+#define GET_TX_DESC_DATA_SHORT(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 24, 1)
-#define GET_TX_DESC_DATA_BW(__pdesc)			\
+#define GET_TX_DESC_DATA_BW(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 25, 1)
-#define GET_TX_DESC_RTS_SHORT(__pdesc)			\
+#define GET_TX_DESC_RTS_SHORT(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 26, 1)
-#define GET_TX_DESC_RTS_BW(__pdesc)			\
+#define GET_TX_DESC_RTS_BW(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 27, 1)
-#define GET_TX_DESC_RTS_SC(__pdesc)			\
+#define GET_TX_DESC_RTS_SC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 28, 2)
-#define GET_TX_DESC_RTS_STBC(__pdesc)			\
+#define GET_TX_DESC_RTS_STBC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 30, 2)
 
 #define SET_TX_DESC_TX_RATE(__pdesc, __val)		\
@@ -315,17 +311,17 @@
 #define SET_TX_DESC_USB_TXAGG_NUM(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+20, 24, 8, __val)
 
-#define GET_TX_DESC_TX_RATE(__pdesc)			\
+#define GET_TX_DESC_TX_RATE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+20, 0, 6)
-#define GET_TX_DESC_DATA_SHORTGI(__pdesc)		\
+#define GET_TX_DESC_DATA_SHORTGI(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+20, 6, 1)
-#define GET_TX_DESC_CCX_TAG(__pdesc)			\
+#define GET_TX_DESC_CCX_TAG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+20, 7, 1)
-#define GET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc)	\
+#define GET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+20, 8, 5)
 #define GET_TX_DESC_RTS_RATE_FB_LIMIT(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+20, 13, 4)
-#define GET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc)	\
+#define GET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+20, 17, 1)
 #define GET_TX_DESC_DATA_RETRY_LIMIT(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+20, 18, 6)
@@ -336,9 +332,9 @@
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 5, __val)
 #define SET_TX_DESC_TXAGC_B(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 5, 5, __val)
-#define SET_TX_DESC_USE_MAX_LEN(__pdesc, __val)	\
+#define SET_TX_DESC_USE_MAX_LEN(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 10, 1, __val)
-#define SET_TX_DESC_MAX_AGG_NUM(__pdesc, __val)	\
+#define SET_TX_DESC_MAX_AGG_NUM(__pdesc, __val)		\
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 11, 5, __val)
 #define SET_TX_DESC_MCSG1_MAX_LEN(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 16, 4, __val)
@@ -349,19 +345,19 @@
 #define SET_TX_DESC_MCS7_SGI_MAX_LEN(__pdesc, __val)\
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 28, 4, __val)
 
-#define GET_TX_DESC_TXAGC_A(__pdesc)			\
+#define GET_TX_DESC_TXAGC_A(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+24, 0, 5)
-#define GET_TX_DESC_TXAGC_B(__pdesc)			\
+#define GET_TX_DESC_TXAGC_B(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+24, 5, 5)
-#define GET_TX_DESC_USE_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_USE_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+24, 10, 1)
-#define GET_TX_DESC_MAX_AGG_NUM(__pdesc)		\
+#define GET_TX_DESC_MAX_AGG_NUM(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+24, 11, 5)
-#define GET_TX_DESC_MCSG1_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_MCSG1_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+24, 16, 4)
-#define GET_TX_DESC_MCSG2_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_MCSG2_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+24, 20, 4)
-#define GET_TX_DESC_MCSG3_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_MCSG3_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+24, 24, 4)
 #define GET_TX_DESC_MCS7_SGI_MAX_LEN(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+24, 28, 4)
@@ -379,11 +375,11 @@
 
 #define GET_TX_DESC_TX_BUFFER_SIZE(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+28, 0, 16)
-#define GET_TX_DESC_MCSG4_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_MCSG4_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+28, 16, 4)
-#define GET_TX_DESC_MCSG5_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_MCSG5_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+28, 20, 4)
-#define GET_TX_DESC_MCSG6_MAX_LEN(__pdesc)		\
+#define GET_TX_DESC_MCSG6_MAX_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+28, 24, 4)
 #define GET_TX_DESC_MCS15_SGI_MAX_LEN(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+28, 28, 4)
@@ -395,7 +391,7 @@
 
 #define GET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+32, 0, 32)
-#define GET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc)	\
+#define GET_TX_DESC_TX_BUFFER_ADDRESS64(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+36, 0, 32)
 
 #define SET_TX_DESC_NEXT_DESC_ADDRESS(__pdesc, __val)	\
@@ -410,97 +406,97 @@
 
 #define GET_RX_DESC_PKT_LEN(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc, 0, 14)
-#define GET_RX_DESC_CRC32(__pdesc)			\
+#define GET_RX_DESC_CRC32(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 14, 1)
-#define GET_RX_DESC_ICV(__pdesc)			\
+#define GET_RX_DESC_ICV(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 15, 1)
 #define GET_RX_DESC_DRV_INFO_SIZE(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc, 16, 4)
 #define GET_RX_DESC_SECURITY(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc, 20, 3)
-#define GET_RX_DESC_QOS(__pdesc)			\
+#define GET_RX_DESC_QOS(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 23, 1)
-#define GET_RX_DESC_SHIFT(__pdesc)			\
+#define GET_RX_DESC_SHIFT(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 24, 2)
-#define GET_RX_DESC_PHYST(__pdesc)			\
+#define GET_RX_DESC_PHYST(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
-#define GET_RX_DESC_SWDEC(__pdesc)			\
+#define GET_RX_DESC_SWDEC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
-#define GET_RX_DESC_LS(__pdesc)				\
+#define GET_RX_DESC_LS(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
-#define GET_RX_DESC_FS(__pdesc)				\
+#define GET_RX_DESC_FS(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
-#define GET_RX_DESC_EOR(__pdesc)			\
+#define GET_RX_DESC_EOR(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
-#define GET_RX_DESC_OWN(__pdesc)			\
+#define GET_RX_DESC_OWN(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
 
-#define SET_RX_DESC_PKT_LEN(__pdesc, __val)		\
+#define SET_RX_DESC_PKT_LEN(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 14, __val)
 #define SET_RX_DESC_EOR(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
 #define SET_RX_DESC_OWN(__pdesc, __val)			\
 	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
 
-#define GET_RX_DESC_MACID(__pdesc)			\
+#define GET_RX_DESC_MACID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
-#define GET_RX_DESC_TID(__pdesc)			\
+#define GET_RX_DESC_TID(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 5, 4)
 #define GET_RX_DESC_HWRSVD(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 9, 5)
-#define GET_RX_DESC_PAGGR(__pdesc)			\
+#define GET_RX_DESC_PAGGR(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
-#define GET_RX_DESC_FAGGR(__pdesc)			\
+#define GET_RX_DESC_FAGGR(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
 #define GET_RX_DESC_A1_FIT(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
 #define GET_RX_DESC_A2_FIT(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+4, 20, 4)
-#define GET_RX_DESC_PAM(__pdesc)			\
+#define GET_RX_DESC_PAM(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 24, 1)
-#define GET_RX_DESC_PWR(__pdesc)			\
+#define GET_RX_DESC_PWR(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 25, 1)
-#define GET_RX_DESC_MD(__pdesc)				\
+#define GET_RX_DESC_MD(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+4, 26, 1)
-#define GET_RX_DESC_MF(__pdesc)				\
+#define GET_RX_DESC_MF(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+4, 27, 1)
-#define GET_RX_DESC_TYPE(__pdesc)			\
+#define GET_RX_DESC_TYPE(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+4, 28, 2)
-#define GET_RX_DESC_MC(__pdesc)				\
+#define GET_RX_DESC_MC(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+4, 30, 1)
-#define GET_RX_DESC_BC(__pdesc)				\
+#define GET_RX_DESC_BC(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+4, 31, 1)
-#define GET_RX_DESC_SEQ(__pdesc)			\
+#define GET_RX_DESC_SEQ(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 0, 12)
-#define GET_RX_DESC_FRAG(__pdesc)			\
+#define GET_RX_DESC_FRAG(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
 #define GET_RX_DESC_NEXT_PKT_LEN(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+8, 16, 14)
 #define GET_RX_DESC_NEXT_IND(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+8, 30, 1)
-#define GET_RX_DESC_RSVD(__pdesc)			\
+#define GET_RX_DESC_RSVD(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+8, 31, 1)
 
-#define GET_RX_DESC_RXMCS(__pdesc)			\
+#define GET_RX_DESC_RXMCS(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 0, 6)
-#define GET_RX_DESC_RXHT(__pdesc)			\
+#define GET_RX_DESC_RXHT(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 6, 1)
-#define GET_RX_DESC_SPLCP(__pdesc)			\
+#define GET_RX_DESC_SPLCP(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 8, 1)
-#define GET_RX_DESC_BW(__pdesc)				\
+#define GET_RX_DESC_BW(__pdesc)					\
 	LE_BITS_TO_4BYTE(__pdesc+12, 9, 1)
-#define GET_RX_DESC_HTC(__pdesc)			\
+#define GET_RX_DESC_HTC(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 10, 1)
 #define GET_RX_DESC_HWPC_ERR(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+12, 14, 1)
 #define GET_RX_DESC_HWPC_IND(__pdesc)			\
 	LE_BITS_TO_4BYTE(__pdesc+12, 15, 1)
-#define GET_RX_DESC_IV0(__pdesc)			\
+#define GET_RX_DESC_IV0(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+12, 16, 16)
 
-#define GET_RX_DESC_IV1(__pdesc)			\
+#define GET_RX_DESC_IV1(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+16, 0, 32)
-#define GET_RX_DESC_TSFL(__pdesc)			\
+#define GET_RX_DESC_TSFL(__pdesc)				\
 	LE_BITS_TO_4BYTE(__pdesc+20, 0, 32)
 
 #define GET_RX_DESC_BUFF_ADDR(__pdesc)			\
@@ -508,17 +504,17 @@
 #define GET_RX_DESC_BUFF_ADDR64(__pdesc)		\
 	LE_BITS_TO_4BYTE(__pdesc+28, 0, 32)
 
-#define SET_RX_DESC_BUFF_ADDR(__pdesc, __val)		\
+#define SET_RX_DESC_BUFF_ADDR(__pdesc, __val)	\
 	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 32, __val)
-#define SET_RX_DESC_BUFF_ADDR64(__pdesc, __val)		\
+#define SET_RX_DESC_BUFF_ADDR64(__pdesc, __val) \
 	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 32, __val)
 
-#define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)	\
-do {							\
-	if (_size > TX_DESC_NEXT_DESC_OFFSET)		\
+#define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)		\
+do {								\
+	if (_size > TX_DESC_NEXT_DESC_OFFSET)			\
 		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
-	else						\
-		memset(__pdesc, 0, _size);		\
+	else							\
+		memset(__pdesc, 0, _size);			\
 } while (0)
 
 struct rx_fwinfo_8723e {
@@ -699,22 +695,27 @@ struct rx_desc_8723e {
 
 } __packed;
 
-void rtl8723ae_tx_fill_desc(struct ieee80211_hw *hw,
-			    struct ieee80211_hdr *hdr, u8 *pdesc,
-			    u8 *pbd_desc_tx, struct ieee80211_tx_info *info,
-			    struct ieee80211_sta *sta,
-			    struct sk_buff *skb, u8 hw_queue,
-			    struct rtl_tcb_desc *ptcb_desc);
-bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
-			     struct rtl_stats *status,
-			     struct ieee80211_rx_status *rx_status,
-			     u8 *pdesc, struct sk_buff *skb);
-void rtl8723ae_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
-			u8 desc_name, u8 *val);
-u32 rtl8723ae_get_desc(u8 *pdesc, bool istx, u8 desc_name);
-void rtl8723ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
-void rtl8723ae_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
-			       bool b_firstseg, bool b_lastseg,
+void rtl8723e_tx_fill_desc(struct ieee80211_hw *hw,
+			   struct ieee80211_hdr *hdr,
+			   u8 *pdesc, u8 *txbd,
+			   struct ieee80211_tx_info *info,
+			   struct ieee80211_sta *sta,
+			   struct sk_buff *skb, u8 hw_queue,
+			   struct rtl_tcb_desc *ptcb_desc);
+bool rtl8723e_rx_query_desc(struct ieee80211_hw *hw,
+			    struct rtl_stats *status,
+			    struct ieee80211_rx_status *rx_status,
+			    u8 *pdesc, struct sk_buff *skb);
+void rtl8723e_set_desc(struct ieee80211_hw *hw,
+		       u8 *pdesc, bool istx, u8 desc_name, u8 *val);
+u32 rtl8723e_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl8723e_is_tx_desc_closed(struct ieee80211_hw *hw,
+				u8 hw_queue, u16 index);
+void rtl8723e_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
+void rtl8723e_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
+			      bool firstseg, bool lastseg,
+			      struct sk_buff *skb);
+u32 rtl8723e_rx_command_packet(struct ieee80211_hw *hw,
+			       struct rtl_stats status,
 			       struct sk_buff *skb);
-
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
index c0689c1..d296b5c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/hw.c
@@ -1015,7 +1015,7 @@ int rtl8723be_hw_init(struct ieee80211_hw *hw)
 	tmp_u1b &= 0x7F;
 	rtl_write_byte(rtlpriv, REG_SYS_CFG, tmp_u1b);
 
-	err = rtl8723_download_fw(hw, true);
+	err = rtl8723_download_fw(hw, true, FW_8192C_POLLING_TIMEOUT_COUNT);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
 			 "Failed to download FW. Init HW without FW now..\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index 532913c..8b4a5f3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -196,7 +196,7 @@ bool rtl8723be_get_btc_status(void)
 	return true;
 }
 
-static bool is_fw_header(struct rtl92c_firmware_header *hdr)
+static bool is_fw_header(struct rtl8723e_firmware_header *hdr)
 {
 	return (hdr->signature & 0xfff0) == 0x5300;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
index 4e254b7..0643406 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/dm_common.c
@@ -44,7 +44,6 @@ EXPORT_SYMBOL_GPL(rtl8723_dm_init_dynamic_txpower);
 void rtl8723_dm_init_edca_turbo(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-
 	rtlpriv->dm.current_turbo_edca = false;
 	rtlpriv->dm.is_any_nonbepkts = false;
 	rtlpriv->dm.is_cur_rdlstate = false;
@@ -54,12 +53,13 @@ EXPORT_SYMBOL_GPL(rtl8723_dm_init_edca_turbo);
 void rtl8723_dm_init_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ps_t *dm_pstable = &rtlpriv->dm_pstable;
 
-	rtlpriv->dm_pstable.pre_ccastate = CCA_MAX;
-	rtlpriv->dm_pstable.cur_ccasate = CCA_MAX;
-	rtlpriv->dm_pstable.pre_rfstate = RF_MAX;
-	rtlpriv->dm_pstable.cur_rfstate = RF_MAX;
-	rtlpriv->dm_pstable.rssi_val_min = 0;
-	rtlpriv->dm_pstable.initialize = 0;
+	dm_pstable->pre_ccastate = CCA_MAX;
+	dm_pstable->cur_ccasate = CCA_MAX;
+	dm_pstable->pre_rfstate = RF_MAX;
+	dm_pstable->cur_rfstate = RF_MAX;
+	dm_pstable->rssi_val_min = 0;
+	dm_pstable->initialize = 0;
 }
 EXPORT_SYMBOL_GPL(rtl8723_dm_init_dynamic_bb_powersaving);
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
index 540278f..6f35506 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.c
@@ -36,7 +36,8 @@ void rtl8723_enable_fw_download(struct ieee80211_hw *hw, bool enable)
 
 	if (enable) {
 		tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
-		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp | 0x04);
+		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1,
+			       tmp | 0x04);
 
 		tmp = rtl_read_byte(rtlpriv, REG_MCUFWDL);
 		rtl_write_byte(rtlpriv, REG_MCUFWDL, tmp | 0x01);
@@ -95,7 +96,7 @@ void rtl8723_fw_page_write(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL_GPL(rtl8723_fw_page_write);
 
-static void rtl8723_fill_dummy(u8 *pfwbuf, u32 *pfwlen)
+void rtl8723_fill_dummy(u8 *pfwbuf, u32 *pfwlen)
 {
 	u32 fwlen = *pfwlen;
 	u8 remain = (u8) (fwlen % 4);
@@ -109,60 +110,64 @@ static void rtl8723_fill_dummy(u8 *pfwbuf, u32 *pfwlen)
 	}
 	*pfwlen = fwlen;
 }
+EXPORT_SYMBOL(rtl8723_fill_dummy);
 
 void rtl8723_write_fw(struct ieee80211_hw *hw,
 		      enum version_8723e version,
-		      u8 *buffer, u32 size)
+		      u8 *buffer, u32 size, u8 max_page)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 *bufferptr = buffer;
-	u32 pagenums, remainsize;
+	u32 page_nums, remain_size;
 	u32 page, offset;
 
-	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "FW size is %d bytes,\n", size);
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW size is %d bytes,\n", size);
 
 	rtl8723_fill_dummy(bufferptr, &size);
 
-	pagenums = size / FW_8192C_PAGE_SIZE;
-	remainsize = size % FW_8192C_PAGE_SIZE;
+	page_nums = size / FW_8192C_PAGE_SIZE;
+	remain_size = size % FW_8192C_PAGE_SIZE;
 
-	if (pagenums > 8) {
+	if (page_nums > max_page) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Page numbers should not greater then 8\n");
+			 "Page numbers should not greater than %d\n", max_page);
 	}
-	for (page = 0; page < pagenums; page++) {
+	for (page = 0; page < page_nums; page++) {
 		offset = page * FW_8192C_PAGE_SIZE;
 		rtl8723_fw_page_write(hw, page, (bufferptr + offset),
 				      FW_8192C_PAGE_SIZE);
 	}
-	if (remainsize) {
-		offset = pagenums * FW_8192C_PAGE_SIZE;
-		page = pagenums;
+
+	if (remain_size) {
+		offset = page_nums * FW_8192C_PAGE_SIZE;
+		page = page_nums;
 		rtl8723_fw_page_write(hw, page, (bufferptr + offset),
-				      remainsize);
+				      remain_size);
 	}
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW write done.\n");
 }
 EXPORT_SYMBOL_GPL(rtl8723_write_fw);
 
 void rtl8723ae_firmware_selfreset(struct ieee80211_hw *hw)
 {
-	u8 u1tmp;
+	u8 u1b_tmp;
 	u8 delay = 100;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	rtl_write_byte(rtlpriv, REG_HMETFR + 3, 0x20);
-	u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
 
-	while (u1tmp & BIT(2)) {
+	while (u1b_tmp & BIT(2)) {
 		delay--;
 		if (delay == 0)
 			break;
 		udelay(50);
-		u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+		u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
 	}
 	if (delay == 0) {
-		u1tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
-		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, u1tmp&(~BIT(2)));
+		u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1,
+			       u1b_tmp&(~BIT(2)));
 	}
 }
 EXPORT_SYMBOL_GPL(rtl8723ae_firmware_selfreset);
@@ -190,7 +195,8 @@ void rtl8723be_firmware_selfreset(struct ieee80211_hw *hw)
 }
 EXPORT_SYMBOL_GPL(rtl8723be_firmware_selfreset);
 
-int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be)
+int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be,
+			  int max_count)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	int err = -EIO;
@@ -199,10 +205,10 @@ int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be)
 
 	do {
 		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
-	} while ((counter++ < FW_8192C_POLLING_TIMEOUT_COUNT) &&
+	} while ((counter++ < max_count) &&
 		 (!(value32 & FWDL_CHKSUM_RPT)));
 
-	if (counter >= FW_8192C_POLLING_TIMEOUT_COUNT) {
+	if (counter >= max_count) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "chksum report fail ! REG_MCUFWDL:0x%08x .\n",
 			 value32);
@@ -223,15 +229,15 @@ int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be)
 		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
 		if (value32 & WINTINI_RDY) {
 			RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-				 "Polling FW ready success!! "
-				 "REG_MCUFWDL:0x%08x .\n",
+				 "Polling FW ready success!! REG_MCUFWDL:0x%08x .\n",
 				 value32);
 			err = 0;
 			goto exit;
 		}
-		udelay(FW_8192C_POLLING_DELAY);
 
-	} while (counter++ < FW_8192C_POLLING_TIMEOUT_COUNT);
+		mdelay(FW_8192C_POLLING_DELAY);
+
+	} while (counter++ < max_count);
 
 	RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 		 "Polling FW ready fail!! REG_MCUFWDL:0x%08x .\n",
@@ -243,25 +249,28 @@ exit:
 EXPORT_SYMBOL_GPL(rtl8723_fw_free_to_go);
 
 int rtl8723_download_fw(struct ieee80211_hw *hw,
-			bool is_8723be)
+			bool is_8723be, int max_count)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	struct rtl92c_firmware_header *pfwheader;
+	struct rtl8723e_firmware_header *pfwheader;
 	u8 *pfwdata;
 	u32 fwsize;
 	int err;
 	enum version_8723e version = rtlhal->version;
+	int max_page;
 
 	if (!rtlhal->pfirmware)
 		return 1;
 
-	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
+	pfwheader = (struct rtl8723e_firmware_header *)rtlhal->pfirmware;
 	pfwdata = rtlhal->pfirmware;
 	fwsize = rtlhal->fwsize;
-	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-		 "normal Firmware SIZE %d\n", fwsize);
 
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723AE)
+		max_page = 6;
+	else
+		max_page = 8;
 	if (rtlpriv->cfg->ops->is_fw_header(pfwheader)) {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
 			 "Firmware Version(%d), Signature(%#x), Size(%d)\n",
@@ -271,23 +280,24 @@ int rtl8723_download_fw(struct ieee80211_hw *hw,
 		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
 		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
 	}
-	if (rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) {
-		rtl_write_byte(rtlpriv, REG_MCUFWDL, 0);
+
+	if (rtl_read_byte(rtlpriv, REG_MCUFWDL)&BIT(7)) {
 		if (is_8723be)
 			rtl8723be_firmware_selfreset(hw);
 		else
 			rtl8723ae_firmware_selfreset(hw);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
 	}
 	rtl8723_enable_fw_download(hw, true);
-	rtl8723_write_fw(hw, version, pfwdata, fwsize);
+	rtl8723_write_fw(hw, version, pfwdata, fwsize, max_page);
 	rtl8723_enable_fw_download(hw, false);
 
-	err = rtl8723_fw_free_to_go(hw, is_8723be);
+	err = rtl8723_fw_free_to_go(hw, is_8723be, max_count);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 "Firmware is not ready to run!\n");
 	} else {
-		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
 			 "Firmware is ready to run!\n");
 	}
 	return 0;
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
index cf1cc58..f9bab10 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/fw_common.h
@@ -30,7 +30,7 @@
 #define REG_MCUFWDL				0x0080
 #define FW_8192C_START_ADDRESS			0x1000
 #define FW_8192C_PAGE_SIZE			4096
-#define FW_8192C_POLLING_TIMEOUT_COUNT		6000
+#define FW_8723A_POLLING_TIMEOUT_COUNT		6000
 #define FW_8192C_POLLING_DELAY			5
 
 #define MCUFWDL_RDY				BIT(1)
@@ -49,16 +49,23 @@ enum version_8723e {
 	VERSION_UNKNOWN = 0xFF,
 };
 
-enum rtl8723ae_h2c_cmd {
-	H2C_AP_OFFLOAD = 0,
-	H2C_SETPWRMODE = 1,
-	H2C_JOINBSSRPT = 2,
-	H2C_RSVDPAGE = 3,
-	H2C_RSSI_REPORT = 4,
-	H2C_P2P_PS_CTW_CMD = 5,
-	H2C_P2P_PS_OFFLOAD = 6,
-	H2C_RA_MASK = 7,
-	MAX_H2CCMD
+struct rtl8723e_firmware_header {
+	u16 signature;
+	u8 category;
+	u8 function;
+	u16 version;
+	u8 subversion;
+	u8 rsvd1;
+	u8 month;
+	u8 date;
+	u8 hour;
+	u8 minute;
+	u16 ramcodesize;
+	u16 rsvd2;
+	u32 svnindex;
+	u32 rsvd3;
+	u32 rsvd4;
+	u32 rsvd5;
 };
 
 enum rtl8723be_cmd {
@@ -120,7 +127,11 @@ void rtl8723_fw_page_write(struct ieee80211_hw *hw,
 			   u32 page, const u8 *buffer, u32 size);
 void rtl8723_write_fw(struct ieee80211_hw *hw,
 		      enum version_8723e version,
-		      u8 *buffer, u32 size);
-int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be);
-int rtl8723_download_fw(struct ieee80211_hw *hw, bool is_8723be);
+		      u8 *buffer, u32 size, u8 max_page);
+int rtl8723_fw_free_to_go(struct ieee80211_hw *hw, bool is_8723be, int count);
+int rtl8723_download_fw(struct ieee80211_hw *hw, bool is_8723be, int count);
+bool rtl8723_cmd_send_packet(struct ieee80211_hw *hw,
+			     struct sk_buff *skb);
+void rtl8723_fill_dummy(u8 *pfwbuf, u32 *pfwlen);
+
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
index d73b659..56aff32 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723com/phy_common.c
@@ -43,9 +43,8 @@ u32 rtl8723_phy_query_bb_reg(struct ieee80211_hw *hw,
 	returnvalue = (originalvalue & bitmask) >> bitshift;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "BBR MASK = 0x%x Addr[0x%x]= 0x%x\n",
-		  bitmask, regaddr, originalvalue);
-
+		 "BBR MASK=0x%x Addr[0x%x]=0x%x\n", bitmask,
+		 regaddr, originalvalue);
 	return returnvalue;
 }
 EXPORT_SYMBOL_GPL(rtl8723_phy_query_bb_reg);
@@ -57,8 +56,8 @@ void rtl8723_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
 	u32 originalvalue, bitshift;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
-		  regaddr, bitmask, data);
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n", regaddr, bitmask,
+		 data);
 
 	if (bitmask != MASKDWORD) {
 		originalvalue = rtl_read_dword(rtlpriv, regaddr);
@@ -70,7 +69,7 @@ void rtl8723_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
 		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
-		  regaddr, bitmask, data);
+		 regaddr, bitmask, data);
 }
 EXPORT_SYMBOL_GPL(rtl8723_phy_set_bb_reg);
 
@@ -97,7 +96,7 @@ u32 rtl8723_phy_rf_serial_read(struct ieee80211_hw *hw,
 	u8 rfpi_enable = 0;
 	u32 retvalue;
 
-	offset &= 0xff;
+	offset &= 0x3f;
 	newoffset = offset;
 	if (RT_CANNOT_IO(hw)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "return all one\n");
@@ -109,12 +108,15 @@ u32 rtl8723_phy_rf_serial_read(struct ieee80211_hw *hw,
 	else
 		tmplong2 = rtl_get_bbreg(hw, pphyreg->rfhssi_para2, MASKDWORD);
 	tmplong2 = (tmplong2 & (~BLSSIREADADDRESS)) |
-		   (newoffset << 23) | BLSSIREADEDGE;
+	    (newoffset << 23) | BLSSIREADEDGE;
 	rtl_set_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD,
 		      tmplong & (~BLSSIREADEDGE));
 	mdelay(1);
 	rtl_set_bbreg(hw, pphyreg->rfhssi_para2, MASKDWORD, tmplong2);
-	mdelay(2);
+	mdelay(1);
+	rtl_set_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD,
+		      tmplong | BLSSIREADEDGE);
+	mdelay(1);
 	if (rfpath == RF90_PATH_A)
 		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
 						 BIT(8));
@@ -128,8 +130,8 @@ u32 rtl8723_phy_rf_serial_read(struct ieee80211_hw *hw,
 		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
 					 BLSSIREADBACKDATA);
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "RFR-%d Addr[0x%x]= 0x%x\n",
-		  rfpath, pphyreg->rf_rb, retvalue);
+		 "RFR-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf_rb, retvalue);
 	return retvalue;
 }
 EXPORT_SYMBOL_GPL(rtl8723_phy_rf_serial_read);
@@ -148,13 +150,14 @@ void rtl8723_phy_rf_serial_write(struct ieee80211_hw *hw,
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "stop\n");
 		return;
 	}
-	offset &= 0xff;
+	offset &= 0x3f;
 	newoffset = offset;
 	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
 	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 "RFW-%d Addr[0x%x]= 0x%x\n", rfpath,
-		   pphyreg->rf3wire_offset, data_and_addr);
+		 "RFW-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf3wire_offset,
+		 data_and_addr);
 }
 EXPORT_SYMBOL_GPL(rtl8723_phy_rf_serial_write);
 
@@ -171,6 +174,8 @@ long rtl8723_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
 		break;
 	case WIRELESS_MODE_G:
 	case WIRELESS_MODE_N_24G:
+		offset = -8;
+		break;
 	default:
 		offset = -8;
 		break;
@@ -202,14 +207,14 @@ void rtl8723_phy_init_bb_rf_reg_def(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_B].rfintfe = RFPGA0_XB_RFINTERFACEOE;
 
 	rtlphy->phyreg_def[RF90_PATH_A].rf3wire_offset =
-			    RFPGA0_XA_LSSIPARAMETER;
+	    RFPGA0_XA_LSSIPARAMETER;
 	rtlphy->phyreg_def[RF90_PATH_B].rf3wire_offset =
-			    RFPGA0_XB_LSSIPARAMETER;
+	    RFPGA0_XB_LSSIPARAMETER;
 
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_select = rFPGA0_XAB_RFPARAMETER;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_select = rFPGA0_XAB_RFPARAMETER;
-	rtlphy->phyreg_def[RF90_PATH_C].rflssi_select = rFPGA0_XCD_RFPARAMETER;
-	rtlphy->phyreg_def[RF90_PATH_D].rflssi_select = rFPGA0_XCD_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_A].rflssi_select = RFPGA0_XAB_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_B].rflssi_select = RFPGA0_XAB_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_C].rflssi_select = RFPGA0_XCD_RFPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_D].rflssi_select = RFPGA0_XCD_RFPARAMETER;
 
 	rtlphy->phyreg_def[RF90_PATH_A].rftxgain_stage = RFPGA0_TXGAINSTAGE;
 	rtlphy->phyreg_def[RF90_PATH_B].rftxgain_stage = RFPGA0_TXGAINSTAGE;
@@ -264,6 +269,7 @@ void rtl8723_phy_init_bb_rf_reg_def(struct ieee80211_hw *hw)
 
 	rtlphy->phyreg_def[RF90_PATH_A].rf_rbpi = TRANSCEIVEA_HSPI_READBACK;
 	rtlphy->phyreg_def[RF90_PATH_B].rf_rbpi = TRANSCEIVEB_HSPI_READBACK;
+
 }
 EXPORT_SYMBOL_GPL(rtl8723_phy_init_bb_rf_reg_def);
 
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 84a710d..2f792ac 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -143,6 +143,21 @@
 #define FCS_LEN				4
 #define EM_HDR_LEN			8
 
+enum rtl8192c_h2c_cmd {
+	H2C_AP_OFFLOAD = 0,
+	H2C_SETPWRMODE = 1,
+	H2C_JOINBSSRPT = 2,
+	H2C_RSVDPAGE = 3,
+	H2C_RSSI_REPORT = 5,
+	H2C_RA_MASK = 6,
+	H2C_MACID_PS_MODE = 7,
+	H2C_P2P_PS_OFFLOAD = 8,
+	H2C_MAC_MODE_SEL = 9,
+	H2C_PWRM = 15,
+	H2C_P2P_PS_CTW_CMD = 24,
+	MAX_H2CCMD
+};
+
 #define MAX_TX_COUNT			4
 #define MAX_REGULATION_NUM		4
 #define MAX_RF_PATH_NUM			4
@@ -2041,6 +2056,8 @@ struct rtl_wow_pattern {
 	u32 mask[4];
 };
 
+struct rtl8723e_firmware_header;
+
 struct rtl_hal_ops {
 	int (*init_sw_vars) (struct ieee80211_hw *hw);
 	void (*deinit_sw_vars) (struct ieee80211_hw *hw);
@@ -2145,7 +2162,7 @@ struct rtl_hal_ops {
 	void (*fill_h2c_cmd) (struct ieee80211_hw *hw, u8 element_id,
 			      u32 cmd_len, u8 *p_cmdbuffer);
 	bool (*get_btc_status) (void);
-	bool (*is_fw_header) (struct rtl92c_firmware_header *hdr);
+	bool (*is_fw_header)(struct rtl8723e_firmware_header *hdr);
 	u32 (*rx_command_packet)(struct ieee80211_hw *hw,
 				 struct rtl_stats status, struct sk_buff *skb);
 	void (*add_wowlan_pattern)(struct ieee80211_hw *hw,
-- 
1.8.4.5
