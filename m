From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 17/25] rtlwifi: rtl8188ee: Add files for new driver - part 8
Date: Sun, 24 Mar 2013 22:06:49 -0500
Message-ID: <1364180817-8028-18-git-send-email-Larry.Finger@lwfinger.net>
References: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz, zhiyuan_yang@realsil.com.cn, page_he@realsil.com.cn
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34216 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756343Ab3CYDHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:07:43 -0400
In-Reply-To: <1364180817-8028-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
Cc: zhiyuan_yang@realsil.com.cn
Cc: page_he@realsil.com.cn
---
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c | 140 +++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |  97 ++++++++++++++
 2 files changed, 237 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
new file mode 100644
index 0000000..4798000
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
@@ -0,0 +1,140 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
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
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
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
+#include "pwrseq.h"
+
+
+/*	Description:
+ *		This routine deal with the Power Configuration CMDs
+ *		 parsing for RTL8723/RTL8188E Series IC.
+ *	Assumption:
+ *		We should follow specific format which was released from HW SD.
+ *
+ *	2011.07.07, added by Roger.
+ */
+
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 fab_version, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[])
+{
+	struct wlan_pwr_cfg cmd = {0};
+	bool polling_bit = false;
+	u32 ary_idx = 0;
+	u8 val = 0;
+	u32 offset = 0;
+	u32 polling_count = 0;
+	u32 max_polling_cnt = 5000;
+
+	do {
+		cmd = pwrcfgcmd[ary_idx];
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "rtl_hal_pwrseqcmdparsing(): offset(%#x), cut_msk(%#x), fab_msk(%#x),"
+			 "interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), val(%#x)\n",
+			 GET_PWR_CFG_OFFSET(cmd),
+			 GET_PWR_CFG_CUT_MASK(cmd),
+			 GET_PWR_CFG_FAB_MASK(cmd),
+			 GET_PWR_CFG_INTF_MASK(cmd),
+			 GET_PWR_CFG_BASE(cmd),
+			 GET_PWR_CFG_CMD(cmd),
+			 GET_PWR_CFG_MASK(cmd),
+			 GET_PWR_CFG_VALUE(cmd));
+
+		if ((GET_PWR_CFG_FAB_MASK(cmd) & fab_version) &&
+		    (GET_PWR_CFG_CUT_MASK(cmd) & cut_version) &&
+		    (GET_PWR_CFG_INTF_MASK(cmd) & interface_type)) {
+			switch (GET_PWR_CFG_CMD(cmd)) {
+			case PWR_CMD_READ:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
+				break;
+			case PWR_CMD_WRITE: {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
+				offset = GET_PWR_CFG_OFFSET(cmd);
+
+					/*Read the val from system register*/
+					val = rtl_read_byte(rtlpriv, offset);
+					val &= (~(GET_PWR_CFG_MASK(cmd)));
+					val |= (GET_PWR_CFG_VALUE(cmd) &
+						GET_PWR_CFG_MASK(cmd));
+
+					/*Write the val back to sytem register*/
+					rtl_write_byte(rtlpriv, offset, val);
+				}
+				break;
+			case PWR_CMD_POLLING:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_POLLING\n");
+				polling_bit = false;
+				offset = GET_PWR_CFG_OFFSET(cmd);
+
+				do {
+					val = rtl_read_byte(rtlpriv, offset);
+
+					val = val & GET_PWR_CFG_MASK(cmd);
+					if (val == (GET_PWR_CFG_VALUE(cmd) &
+						    GET_PWR_CFG_MASK(cmd)))
+						polling_bit = true;
+					else
+						udelay(10);
+
+					if (polling_count++ > max_polling_cnt) {
+						RT_TRACE(rtlpriv, COMP_INIT,
+							 DBG_LOUD,
+							 "polling fail in pwrseqcmd\n");
+						return false;
+					}
+				} while (!polling_bit);
+
+				break;
+			case PWR_CMD_DELAY:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
+				if (GET_PWR_CFG_VALUE(cmd) == PWRSEQ_DELAY_US)
+					udelay(GET_PWR_CFG_OFFSET(cmd));
+				else
+					mdelay(GET_PWR_CFG_OFFSET(cmd));
+				break;
+			case PWR_CMD_END:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): PWR_CMD_END\n");
+				return true;
+				break;
+			default:
+				RT_ASSERT(false,
+					  "rtl_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
+				break;
+			}
+		}
+
+		ary_idx++;
+	} while (1);
+
+	return true;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
new file mode 100644
index 0000000..622ea7e
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
@@ -0,0 +1,97 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2013  Realtek Corporation.
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
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
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
+#ifndef __RTL8723E_PWRSEQCMD_H__
+#define __RTL8723E_PWRSEQCMD_H__
+
+#include "wifi.h"
+/*---------------------------------------------*/
+/* The value of cmd: 4 bits */
+/*---------------------------------------------*/
+#define PWR_CMD_READ		0x00
+#define PWR_CMD_WRITE		0x01
+#define PWR_CMD_POLLING		0x02
+#define PWR_CMD_DELAY		0x03
+#define PWR_CMD_END		0x04
+
+/* define the base address of each block */
+#define PWR_BASEADDR_MAC	0x00
+#define PWR_BASEADDR_USB	0x01
+#define PWR_BASEADDR_PCIE	0x02
+#define PWR_BASEADDR_SDIO	0x03
+
+#define PWR_INTF_SDIO_MSK	BIT(0)
+#define PWR_INTF_USB_MSK	BIT(1)
+#define PWR_INTF_PCI_MSK	BIT(2)
+#define PWR_INTF_ALL_MSK	(BIT(0)|BIT(1)|BIT(2)|BIT(3))
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
+#define	GET_PWR_CFG_OFFSET(__PWR)	(__PWR.offset)
+#define	GET_PWR_CFG_CUT_MASK(__PWR)	(__PWR.cut_msk)
+#define	GET_PWR_CFG_FAB_MASK(__PWR)	(__PWR.fab_msk)
+#define	GET_PWR_CFG_INTF_MASK(__PWR)	(__PWR.interface_msk)
+#define	GET_PWR_CFG_BASE(__PWR)		(__PWR.base)
+#define	GET_PWR_CFG_CMD(__PWR)		(__PWR.cmd)
+#define	GET_PWR_CFG_MASK(__PWR)		(__PWR.msk)
+#define	GET_PWR_CFG_VALUE(__PWR)	(__PWR.value)
+
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 fab_version, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[]);
+
+#endif
-- 
1.8.1.4
