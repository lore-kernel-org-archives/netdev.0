From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 12/16] rtlwifi: rtl8723be: Add files for new driver - part 5
Date: Wed,  5 Feb 2014 13:54:56 -0600
Message-ID: <1391630100-13504-13-git-send-email-Larry.Finger@lwfinger.net>
References: <1391630100-13504-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:50815 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbaBETzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 14:55:44 -0500
In-Reply-To: <1391630100-13504-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c    | 106 +++++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h    | 305 +++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c | 140 ++++++
 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h |  95 ++++
 drivers/net/wireless/rtlwifi/rtl8723be/rf.c        | 504 +++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723be/rf.h        |  43 ++
 6 files changed, 1193 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723be/rf.h

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
new file mode 100644
index 0000000..b5167e7
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.c
@@ -0,0 +1,106 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#include "pwrseqcmd.h"
+#include "pwrseq.h"
+
+
+/* drivers should parse below arrays and do the corresponding actions */
+/*3 Power on  Array*/
+struct wlan_pwr_cfg rtl8723B_power_on_flow[RTL8723B_TRANS_CARDEMU_TO_ACT_STEPS +
+					   RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_CARDEMU_TO_ACT
+	RTL8723B_TRANS_END
+};
+
+/*3Radio off GPIO Array */
+struct wlan_pwr_cfg rtl8723B_radio_off_flow[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS
+					    + RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_ACT_TO_CARDEMU
+	RTL8723B_TRANS_END
+};
+
+/*3Card Disable Array*/
+struct wlan_pwr_cfg rtl8723B_card_disable_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS +
+				 RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_ACT_TO_CARDEMU
+	RTL8723B_TRANS_CARDEMU_TO_CARDDIS
+	RTL8723B_TRANS_END
+};
+
+/*3 Card Enable Array*/
+struct wlan_pwr_cfg rtl8723B_card_enable_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS +
+				 RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_CARDDIS_TO_CARDEMU
+	RTL8723B_TRANS_CARDEMU_TO_ACT
+	RTL8723B_TRANS_END
+};
+
+/*3Suspend Array*/
+struct wlan_pwr_cfg rtl8723B_suspend_flow[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+					  RTL8723B_TRANS_CARDEMU_TO_SUS_STEPS +
+					  RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_ACT_TO_CARDEMU
+	RTL8723B_TRANS_CARDEMU_TO_SUS
+	RTL8723B_TRANS_END
+};
+
+/*3 Resume Array*/
+struct wlan_pwr_cfg rtl8723B_resume_flow[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8723B_TRANS_CARDEMU_TO_SUS_STEPS +
+					 RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_SUS_TO_CARDEMU
+	RTL8723B_TRANS_CARDEMU_TO_ACT
+	RTL8723B_TRANS_END
+};
+
+/*3HWPDN Array*/
+struct wlan_pwr_cfg rtl8723B_hwpdn_flow[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+					RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS +
+					RTL8723B_TRANS_END_STEPS] = {
+	RTL8723B_TRANS_ACT_TO_CARDEMU
+	RTL8723B_TRANS_CARDEMU_TO_PDN
+	RTL8723B_TRANS_END
+};
+
+/*3 Enter LPS */
+struct wlan_pwr_cfg rtl8723B_enter_lps_flow[RTL8723B_TRANS_ACT_TO_LPS_STEPS +
+					    RTL8723B_TRANS_END_STEPS] = {
+	/*FW behavior*/
+	RTL8723B_TRANS_ACT_TO_LPS
+	RTL8723B_TRANS_END
+};
+
+/*3 Leave LPS */
+struct wlan_pwr_cfg rtl8723B_leave_lps_flow[RTL8723B_TRANS_LPS_TO_ACT_STEPS +
+					    RTL8723B_TRANS_END_STEPS] = {
+	/*FW behavior*/
+	RTL8723B_TRANS_LPS_TO_ACT
+	RTL8723B_TRANS_END
+};
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
new file mode 100644
index 0000000..960b408
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseq.h
@@ -0,0 +1,305 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#ifndef __RTL8723BE_PWRSEQ_H__
+#define __RTL8723BE_PWRSEQ_H__
+
+#include "pwrseqcmd.h"
+/*	Check document WM-20130425-JackieLau-RTL8723B_Power_Architecture v05.vsd
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
+ */
+#define	RTL8723B_TRANS_CARDEMU_TO_ACT_STEPS	23
+#define	RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS	15
+#define	RTL8723B_TRANS_CARDEMU_TO_SUS_STEPS	15
+#define	RTL8723B_TRANS_SUS_TO_CARDEMU_STEPS	15
+#define	RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS	15
+#define	RTL8723B_TRANS_PDN_TO_CARDEMU_STEPS	15
+#define	RTL8723B_TRANS_ACT_TO_LPS_STEPS		15
+#define	RTL8723B_TRANS_LPS_TO_ACT_STEPS		15
+#define	RTL8723B_TRANS_END_STEPS		1
+
+#define RTL8723B_TRANS_CARDEMU_TO_ACT					\
+	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	{0x0067, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	{0x0001, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
+	 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 1, PWRSEQ_DELAY_MS},		\
+	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), 0},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)|BIT(2)), 0},	\
+	{0x0075, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0) , 0},			\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	{0x0075, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0) , BIT(0)},		\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)), 0},		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0},			\
+	{0x0010, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6), BIT(6)},		\
+	{0x0049, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	{0x0063, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	{0x0062, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	{0x0058, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	{0x005A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	{0x0068, PWR_CUT_TESTCHIP_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3), BIT(3)},		\
+	{0x0069, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6), BIT(6)},
+
+#define RTL8723B_TRANS_ACT_TO_CARDEMU					\
+	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},			\
+	{0x004F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	{0x0049, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0},			\
+	{0x0010, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6), 0},			\
+	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
+	 PWR_CMD_WRITE, BIT(5), BIT(5)},				\
+	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
+	 PWR_CMD_WRITE, BIT(0), 0},
+
+#define RTL8723B_TRANS_CARDEMU_TO_SUS					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4) | BIT(3), (BIT(4) | BIT(3))}, \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
+	 PWR_CMD_WRITE, BIT(3) | BIT(4), BIT(3)},			\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(4), BIT(3) | BIT(4)},\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0},
+
+#define RTL8723B_TRANS_SUS_TO_CARDEMU					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(7), 0},		\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},			\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},
+
+#define RTL8723B_TRANS_CARDEMU_TO_CARDDIS				\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK,				\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), BIT(2)},		\
+	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 1},			\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0},
+
+#define RTL8723B_TRANS_CARDDIS_TO_CARDEMU				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3) | BIT(7), 0},		\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},			\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},		\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},
+
+#define RTL8723B_TRANS_CARDEMU_TO_PDN					\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), BIT(4)},		\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_SDIO_MSK | PWR_INTF_USB_MSK, PWR_BASEADDR_MAC,	\
+	 PWR_CMD_WRITE, 0xFF, 0x20},					\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)},
+
+#define RTL8723B_TRANS_PDN_TO_CARDEMU					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},
+
+#define RTL8723B_TRANS_ACT_TO_LPS					\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},			\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},			\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},		\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x03},			\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},			\
+	{0x0093, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00},			\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), BIT(5)},
+
+#define RTL8723B_TRANS_LPS_TO_ACT					\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84},		\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84},			\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84},			\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS},		\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},			\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0},		\
+	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6)|BIT(7), 0},		\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1) | BIT(0), BIT(1) | BIT(0)}, \
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},
+
+#define RTL8723B_TRANS_END						\
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, 0,	\
+	 PWR_CMD_END, 0, 0},
+
+extern struct wlan_pwr_cfg rtl8723B_power_on_flow
+				[RTL8723B_TRANS_CARDEMU_TO_ACT_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_radio_off_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_card_disable_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_card_enable_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_suspend_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_SUS_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_resume_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_SUS_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_hwpdn_flow
+				[RTL8723B_TRANS_ACT_TO_CARDEMU_STEPS +
+				 RTL8723B_TRANS_CARDEMU_TO_PDN_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_enter_lps_flow
+				[RTL8723B_TRANS_ACT_TO_LPS_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8723B_leave_lps_flow
+				[RTL8723B_TRANS_LPS_TO_ACT_STEPS +
+				 RTL8723B_TRANS_END_STEPS];
+
+/* RTL8723 Power Configuration CMDs for PCIe interface */
+#define RTL8723_NIC_PWR_ON_FLOW		rtl8723B_power_on_flow
+#define RTL8723_NIC_RF_OFF_FLOW		rtl8723B_radio_off_flow
+#define RTL8723_NIC_DISABLE_FLOW	rtl8723B_card_disable_flow
+#define RTL8723_NIC_ENABLE_FLOW		rtl8723B_card_enable_flow
+#define RTL8723_NIC_SUSPEND_FLOW	rtl8723B_suspend_flow
+#define RTL8723_NIC_RESUME_FLOW		rtl8723B_resume_flow
+#define RTL8723_NIC_PDN_FLOW		rtl8723B_hwpdn_flow
+#define RTL8723_NIC_LPS_ENTER_FLOW	rtl8723B_enter_lps_flow
+#define RTL8723_NIC_LPS_LEAVE_FLOW	rtl8723B_leave_lps_flow
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
new file mode 100644
index 0000000..50f8d60
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.c
@@ -0,0 +1,140 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#include "pwrseq.h"
+
+/*	Description:
+ *		This routine deal with the Power Configuration CMDs
+ *		 parsing for RTL8723/RTL8188E Series IC.
+ *	Assumption:
+ *		We should follow specific format which was released from HW SD.
+ *
+ *	2011.07.07, added by Roger.
+ */
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 fab_version, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[])
+
+{
+	struct wlan_pwr_cfg pwr_cfg_cmd = {0};
+	bool b_polling_bit = false;
+	u32 ary_idx = 0;
+	u8 value = 0;
+	u32 offset = 0;
+	u32 polling_count = 0;
+	u32 max_polling_cnt = 5000;
+
+	do {
+		pwr_cfg_cmd = pwrcfgcmd[ary_idx];
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "rtl_hal_pwrseqcmdparsing(): "
+			 "offset(%#x),cut_msk(%#x), fab_msk(%#x),"
+			 "interface_msk(%#x), base(%#x), "
+			 "cmd(%#x), msk(%#x), value(%#x)\n",
+			 GET_PWR_CFG_OFFSET(pwr_cfg_cmd),
+			 GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd),
+			 GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd),
+			 GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd),
+			 GET_PWR_CFG_BASE(pwr_cfg_cmd),
+			 GET_PWR_CFG_CMD(pwr_cfg_cmd),
+			 GET_PWR_CFG_MASK(pwr_cfg_cmd),
+			 GET_PWR_CFG_VALUE(pwr_cfg_cmd));
+
+		if ((GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd)&fab_version) &&
+		    (GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd)&cut_version) &&
+		    (GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd)&interface_type)) {
+			switch (GET_PWR_CFG_CMD(pwr_cfg_cmd)) {
+			case PWR_CMD_READ:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): "
+					  "PWR_CMD_READ\n");
+				break;
+			case PWR_CMD_WRITE:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): "
+					  "PWR_CMD_WRITE\n");
+				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
+
+				/*Read the value from system register*/
+				value = rtl_read_byte(rtlpriv, offset);
+				value &= (~(GET_PWR_CFG_MASK(pwr_cfg_cmd)));
+				value = value | (GET_PWR_CFG_VALUE(pwr_cfg_cmd)
+					& GET_PWR_CFG_MASK(pwr_cfg_cmd));
+
+				/*Write the value back to sytem register*/
+				rtl_write_byte(rtlpriv, offset, value);
+				break;
+			case PWR_CMD_POLLING:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): "
+					  "PWR_CMD_POLLING\n");
+				b_polling_bit = false;
+				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
+
+				do {
+					value = rtl_read_byte(rtlpriv, offset);
+
+					value &= GET_PWR_CFG_MASK(pwr_cfg_cmd);
+					if (value ==
+					    (GET_PWR_CFG_VALUE(pwr_cfg_cmd) &
+					     GET_PWR_CFG_MASK(pwr_cfg_cmd)))
+						b_polling_bit = true;
+					else
+						udelay(10);
+
+					if (polling_count++ > max_polling_cnt)
+						return false;
+
+				} while (!b_polling_bit);
+				break;
+			case PWR_CMD_DELAY:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): "
+					 "PWR_CMD_DELAY\n");
+				if (GET_PWR_CFG_VALUE(pwr_cfg_cmd) ==
+				    PWRSEQ_DELAY_US)
+					udelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
+				else
+					mdelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
+				break;
+			case PWR_CMD_END:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "rtl_hal_pwrseqcmdparsing(): "
+					 "PWR_CMD_END\n");
+				return true;
+				break;
+			default:
+				RT_ASSERT(false,
+					  "rtl_hal_pwrseqcmdparsing(): "
+					  "Unknown CMD!!\n");
+				break;
+			}
+		}
+
+		ary_idx++;
+	} while (1);
+
+	return true;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
new file mode 100644
index 0000000..edc4a81
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/pwrseqcmd.h
@@ -0,0 +1,95 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#ifndef __RTL8723BE_PWRSEQCMD_H__
+#define __RTL8723BE_PWRSEQCMD_H__
+
+#include "../wifi.h"
+/*---------------------------------------------*/
+/*The value of cmd: 4 bits */
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
+#define	PWR_INTF_SDIO_MSK	BIT(0)
+#define	PWR_INTF_USB_MSK	BIT(1)
+#define	PWR_INTF_PCI_MSK	BIT(2)
+#define	PWR_INTF_ALL_MSK	(BIT(0) | BIT(1) | BIT(2) | BIT(3))
+
+#define	PWR_FAB_TSMC_MSK	BIT(0)
+#define	PWR_FAB_UMC_MSK		BIT(1)
+#define	PWR_FAB_ALL_MSK		(BIT(0) | BIT(1) | BIT(2) | BIT(3))
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
+
+};
+
+#define	GET_PWR_CFG_OFFSET(__PWR_CMD)	__PWR_CMD.offset
+#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)	__PWR_CMD.cut_msk
+#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)	__PWR_CMD.fab_msk
+#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	__PWR_CMD.interface_msk
+#define	GET_PWR_CFG_BASE(__PWR_CMD)	__PWR_CMD.base
+#define	GET_PWR_CFG_CMD(__PWR_CMD)	__PWR_CMD.cmd
+#define	GET_PWR_CFG_MASK(__PWR_CMD)	__PWR_CMD.msk
+#define	GET_PWR_CFG_VALUE(__PWR_CMD)	__PWR_CMD.value
+
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 fab_version, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[]);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/rf.c b/drivers/net/wireless/rtlwifi/rtl8723be/rf.c
new file mode 100644
index 0000000..4862949
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/rf.c
@@ -0,0 +1,504 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#include "../wifi.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "rf.h"
+#include "dm.h"
+
+static bool _rtl8723be_phy_rf6052_config_parafile(struct ieee80211_hw *hw);
+
+void rtl8723be_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	switch (bandwidth) {
+	case HT_CHANNEL_WIDTH_20:
+		rtlphy->rfreg_chnlval[0] = ((rtlphy->rfreg_chnlval[0] &
+					     0xfffff3ff) | BIT(10) | BIT(11));
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, RFREG_OFFSET_MASK,
+			      rtlphy->rfreg_chnlval[0]);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		rtlphy->rfreg_chnlval[0] = ((rtlphy->rfreg_chnlval[0] &
+					     0xfffff3ff) | BIT(10));
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, RFREG_OFFSET_MASK,
+			      rtlphy->rfreg_chnlval[0]);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
+			 "unknown bandwidth: %#X\n", bandwidth);
+		break;
+	}
+}
+
+void rtl8723be_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u32 tx_agc[2] = {0, 0}, tmpval;
+	bool turbo_scanoff = false;
+	u8 idx1, idx2;
+	u8 *ptr;
+	u8 direction;
+	u32 pwrtrac_value;
+
+	if (rtlefuse->eeprom_regulatory != 0)
+		turbo_scanoff = true;
+
+	if (mac->act_scanning) {
+		tx_agc[RF90_PATH_A] = 0x3f3f3f3f;
+		tx_agc[RF90_PATH_B] = 0x3f3f3f3f;
+
+		if (turbo_scanoff) {
+			for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
+				tx_agc[idx1] = ppowerlevel[idx1] |
+					       (ppowerlevel[idx1] << 8) |
+					       (ppowerlevel[idx1] << 16) |
+					       (ppowerlevel[idx1] << 24);
+			}
+		}
+	} else {
+		for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
+			tx_agc[idx1] = ppowerlevel[idx1] |
+				       (ppowerlevel[idx1] << 8) |
+				       (ppowerlevel[idx1] << 16) |
+				       (ppowerlevel[idx1] << 24);
+		}
+		if (rtlefuse->eeprom_regulatory == 0) {
+			tmpval =
+			    (rtlphy->mcs_offset[0][6]) +
+			    (rtlphy->mcs_offset[0][7] << 8);
+			tx_agc[RF90_PATH_A] += tmpval;
+
+			tmpval = (rtlphy->mcs_offset[0][14]) +
+				 (rtlphy->mcs_offset[0][15] <<
+				  24);
+			tx_agc[RF90_PATH_B] += tmpval;
+		}
+	}
+	for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
+		ptr = (u8 *)(&(tx_agc[idx1]));
+		for (idx2 = 0; idx2 < 4; idx2++) {
+			if (*ptr > RF6052_MAX_TX_PWR)
+				*ptr = RF6052_MAX_TX_PWR;
+			ptr++;
+		}
+	}
+	rtl8723be_dm_txpower_track_adjust(hw, 1, &direction, &pwrtrac_value);
+	if (direction == 1) {
+		tx_agc[0] += pwrtrac_value;
+		tx_agc[1] += pwrtrac_value;
+	} else if (direction == 2) {
+		tx_agc[0] -= pwrtrac_value;
+		tx_agc[1] -= pwrtrac_value;
+	}
+	tmpval = tx_agc[RF90_PATH_A] & 0xff;
+	rtl_set_bbreg(hw, RTXAGC_A_CCK1_MCS32, MASKBYTE1, tmpval);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "CCK PWR 1M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
+		 RTXAGC_A_CCK1_MCS32);
+
+	tmpval = tx_agc[RF90_PATH_A] >> 8;
+
+	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, 0xffffff00, tmpval);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "CCK PWR 2~11M (rf-A) = 0x%x (reg 0x%x)\n", tmpval,
+		 RTXAGC_B_CCK11_A_CCK2_11);
+
+	tmpval = tx_agc[RF90_PATH_B] >> 24;
+	rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11, MASKBYTE0, tmpval);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "CCK PWR 11M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
+		 RTXAGC_B_CCK11_A_CCK2_11);
+
+	tmpval = tx_agc[RF90_PATH_B] & 0x00ffffff;
+	rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32, 0xffffff00, tmpval);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "CCK PWR 1~5.5M (rf-B) = 0x%x (reg 0x%x)\n", tmpval,
+		 RTXAGC_B_CCK1_55_MCS32);
+}
+
+static void rtl8723be_phy_get_power_base(struct ieee80211_hw *hw,
+					 u8 *ppowerlevel_ofdm,
+					 u8 *ppowerlevel_bw20,
+					 u8 *ppowerlevel_bw40,
+					 u8 channel, u32 *ofdmbase,
+					 u32 *mcsbase)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u32 powerbase0, powerbase1;
+	u8 i, powerlevel[2];
+
+	for (i = 0; i < 2; i++) {
+		powerbase0 = ppowerlevel_ofdm[i];
+
+		powerbase0 = (powerbase0 << 24) | (powerbase0 << 16) |
+		    (powerbase0 << 8) | powerbase0;
+		*(ofdmbase + i) = powerbase0;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 " [OFDM power base index rf(%c) = 0x%x]\n",
+			 ((i == 0) ? 'A' : 'B'), *(ofdmbase + i));
+	}
+
+	for (i = 0; i < 2; i++) {
+		if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20)
+			powerlevel[i] = ppowerlevel_bw20[i];
+		else
+			powerlevel[i] = ppowerlevel_bw40[i];
+		powerbase1 = powerlevel[i];
+		powerbase1 = (powerbase1 << 24) | (powerbase1 << 16) |
+			     (powerbase1 << 8) | powerbase1;
+
+		*(mcsbase + i) = powerbase1;
+
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			" [MCS power base index rf(%c) = 0x%x]\n",
+			((i == 0) ? 'A' : 'B'), *(mcsbase + i));
+	}
+}
+
+static void txpwr_by_regulatory(struct ieee80211_hw *hw, u8 channel, u8 index,
+				u32 *powerbase0, u32 *powerbase1,
+				u32 *p_outwriteval)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u8 i, chnlgroup = 0, pwr_diff_limit[4];
+	u8 pwr_diff = 0, customer_pwr_diff;
+	u32 writeval, customer_limit, rf;
+
+	for (rf = 0; rf < 2; rf++) {
+		switch (rtlefuse->eeprom_regulatory) {
+		case 0:
+			chnlgroup = 0;
+
+			writeval =
+			    rtlphy->mcs_offset[chnlgroup][index + (rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "RTK better performance, "
+				 "writeval(%c) = 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
+			break;
+		case 1:
+			if (rtlphy->pwrgroup_cnt == 1) {
+				chnlgroup = 0;
+			} else {
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
+			}
+			writeval = rtlphy->mcs_offset[chnlgroup]
+			    [index + (rf ? 8 : 0)] + ((index < 2) ?
+						      powerbase0[rf] :
+						      powerbase1[rf]);
+
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Realtek regulatory, 20MHz, "
+				 "writeval(%c) = 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
+
+			break;
+		case 2:
+			writeval =
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Better regulatory, "
+				 "writeval(%c) = 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
+			break;
+		case 3:
+			chnlgroup = 0;
+
+			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "customer's limit, 40MHz "
+					 "rf(%c) = 0x%x\n",
+					 ((rf == 0) ? 'A' : 'B'),
+					 rtlefuse->pwrgroup_ht40[rf]
+					 [channel-1]);
+			} else {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "customer's limit, 20MHz "
+					 "rf(%c) = 0x%x\n",
+					 ((rf == 0) ? 'A' : 'B'),
+					 rtlefuse->pwrgroup_ht20[rf]
+					 [channel-1]);
+			}
+
+			if (index < 2)
+				pwr_diff =
+				    rtlefuse->txpwr_legacyhtdiff[rf][channel-1];
+			else if (rtlphy->current_chan_bw ==
+				 HT_CHANNEL_WIDTH_20)
+				pwr_diff =
+				    rtlefuse->txpwr_ht20diff[rf][channel-1];
+
+			if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40)
+				customer_pwr_diff =
+					rtlefuse->pwrgroup_ht40[rf][channel-1];
+			else
+				customer_pwr_diff =
+					rtlefuse->pwrgroup_ht20[rf][channel-1];
+
+			if (pwr_diff > customer_pwr_diff)
+				pwr_diff = 0;
+			else
+				pwr_diff = customer_pwr_diff - pwr_diff;
+
+			for (i = 0; i < 4; i++) {
+				pwr_diff_limit[i] =
+				    (u8)((rtlphy->mcs_offset
+					  [chnlgroup][index + (rf ? 8 : 0)] &
+					  (0x7f << (i * 8))) >> (i * 8));
+
+					if (pwr_diff_limit[i] > pwr_diff)
+						pwr_diff_limit[i] = pwr_diff;
+			}
+
+			customer_limit = (pwr_diff_limit[3] << 24) |
+					 (pwr_diff_limit[2] << 16) |
+					 (pwr_diff_limit[1] << 8) |
+					 (pwr_diff_limit[0]);
+
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				"Customer's limit rf(%c) = 0x%x\n",
+				((rf == 0) ? 'A' : 'B'), customer_limit);
+
+			writeval = customer_limit + ((index < 2) ?
+						      powerbase0[rf] :
+						      powerbase1[rf]);
+
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Customer, writeval rf(%c)= 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
+			break;
+		default:
+			chnlgroup = 0;
+			writeval =
+			    rtlphy->mcs_offset[chnlgroup]
+			    [index + (rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "RTK better performance, writeval "
+				 "rf(%c) = 0x%x\n",
+				 ((rf == 0) ? 'A' : 'B'), writeval);
+			break;
+		}
+
+		if (rtlpriv->dm.dynamic_txhighpower_lvl == TXHIGHPWRLEVEL_BT1)
+			writeval = writeval - 0x06060606;
+		else if (rtlpriv->dm.dynamic_txhighpower_lvl ==
+			 TXHIGHPWRLEVEL_BT2)
+			writeval = writeval - 0x0c0c0c0c;
+		*(p_outwriteval + rf) = writeval;
+	}
+}
+
+static void _rtl8723be_write_ofdm_power_reg(struct ieee80211_hw *hw,
+					 u8 index, u32 *value)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u16 regoffset_a[6] = {
+		RTXAGC_A_RATE18_06, RTXAGC_A_RATE54_24,
+		RTXAGC_A_MCS03_MCS00, RTXAGC_A_MCS07_MCS04,
+		RTXAGC_A_MCS11_MCS08, RTXAGC_A_MCS15_MCS12
+	};
+	u16 regoffset_b[6] = {
+		RTXAGC_B_RATE18_06, RTXAGC_B_RATE54_24,
+		RTXAGC_B_MCS03_MCS00, RTXAGC_B_MCS07_MCS04,
+		RTXAGC_B_MCS11_MCS08, RTXAGC_B_MCS15_MCS12
+	};
+	u8 i, rf, pwr_val[4];
+	u32 writeval;
+	u16 regoffset;
+
+	for (rf = 0; rf < 2; rf++) {
+		writeval = value[rf];
+		for (i = 0; i < 4; i++) {
+			pwr_val[i] = (u8) ((writeval & (0x7f <<
+							(i * 8))) >> (i * 8));
+
+			if (pwr_val[i] > RF6052_MAX_TX_PWR)
+				pwr_val[i] = RF6052_MAX_TX_PWR;
+		}
+		writeval = (pwr_val[3] << 24) | (pwr_val[2] << 16) |
+		    (pwr_val[1] << 8) | pwr_val[0];
+
+		if (rf == 0)
+			regoffset = regoffset_a[index];
+		else
+			regoffset = regoffset_b[index];
+		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeval);
+
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Set 0x%x = %08x\n", regoffset, writeval);
+	}
+}
+
+void rtl8723be_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					   u8 *ppowerlevel_ofdm,
+					   u8 *ppowerlevel_bw20,
+					   u8 *ppowerlevel_bw40, u8 channel)
+{
+	u32 writeval[2], powerbase0[2], powerbase1[2];
+	u8 index;
+	u8 direction;
+	u32 pwrtrac_value;
+
+	rtl8723be_phy_get_power_base(hw, ppowerlevel_ofdm, ppowerlevel_bw20,
+				     ppowerlevel_bw40, channel,
+				     &powerbase0[0], &powerbase1[0]);
+
+	rtl8723be_dm_txpower_track_adjust(hw, 1, &direction, &pwrtrac_value);
+
+	for (index = 0; index < 6; index++) {
+		txpwr_by_regulatory(hw, channel, index, &powerbase0[0],
+				    &powerbase1[0], &writeval[0]);
+		if (direction == 1) {
+			writeval[0] += pwrtrac_value;
+			writeval[1] += pwrtrac_value;
+		} else if (direction == 2) {
+			writeval[0] -= pwrtrac_value;
+			writeval[1] -= pwrtrac_value;
+		}
+		_rtl8723be_write_ofdm_power_reg(hw, index, &writeval[0]);
+	}
+}
+
+bool rtl8723be_phy_rf6052_config(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	if (rtlphy->rf_type == RF_1T1R)
+		rtlphy->num_total_rfpath = 1;
+	else
+		rtlphy->num_total_rfpath = 2;
+
+	return _rtl8723be_phy_rf6052_config_parafile(hw);
+}
+
+static bool _rtl8723be_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct bb_reg_def *pphyreg;
+	u32 u4_regvalue = 0;
+	u8 rfpath;
+	bool rtstatus = true;
+
+	for (rfpath = 0; rfpath < rtlphy->num_total_rfpath; rfpath++) {
+		pphyreg = &rtlphy->phyreg_def[rfpath];
+
+		switch (rfpath) {
+		case RF90_PATH_A:
+		case RF90_PATH_C:
+			u4_regvalue = rtl_get_bbreg(hw, pphyreg->rfintfs,
+						    BRFSI_RFENV);
+			break;
+		case RF90_PATH_B:
+		case RF90_PATH_D:
+			u4_regvalue = rtl_get_bbreg(hw, pphyreg->rfintfs,
+						    BRFSI_RFENV << 16);
+			break;
+		}
+
+		rtl_set_bbreg(hw, pphyreg->rfintfe, BRFSI_RFENV << 16, 0x1);
+		udelay(1);
+
+		rtl_set_bbreg(hw, pphyreg->rfintfo, BRFSI_RFENV, 0x1);
+		udelay(1);
+
+		rtl_set_bbreg(hw, pphyreg->rfhssi_para2,
+			      B3WIREADDREAALENGTH, 0x0);
+		udelay(1);
+
+		rtl_set_bbreg(hw, pphyreg->rfhssi_para2, B3WIREDATALENGTH, 0x0);
+		udelay(1);
+
+		switch (rfpath) {
+		case RF90_PATH_A:
+			rtstatus = rtl8723be_phy_config_rf_with_headerfile(hw,
+						      (enum radio_path)rfpath);
+			break;
+		case RF90_PATH_B:
+			rtstatus = rtl8723be_phy_config_rf_with_headerfile(hw,
+						      (enum radio_path)rfpath);
+			break;
+		case RF90_PATH_C:
+			break;
+		case RF90_PATH_D:
+			break;
+		}
+
+		switch (rfpath) {
+		case RF90_PATH_A:
+		case RF90_PATH_C:
+			rtl_set_bbreg(hw, pphyreg->rfintfs,
+				      BRFSI_RFENV, u4_regvalue);
+			break;
+		case RF90_PATH_B:
+		case RF90_PATH_D:
+			rtl_set_bbreg(hw, pphyreg->rfintfs,
+				      BRFSI_RFENV << 16, u4_regvalue);
+			break;
+		}
+
+		if (!rtstatus) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+				 "Radio[%d] Fail!!", rfpath);
+			return false;
+		}
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "\n");
+	return rtstatus;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/rf.h b/drivers/net/wireless/rtlwifi/rtl8723be/rf.h
new file mode 100644
index 0000000..a6fea10
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/rf.h
@@ -0,0 +1,43 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2014  Realtek Corporation.
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
+#ifndef __RTL8723BE_RF_H__
+#define __RTL8723BE_RF_H__
+
+#define RF6052_MAX_TX_PWR		0x3F
+#define RF6052_MAX_REG			0x3F
+
+void rtl8723be_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
+					u8 bandwidth);
+void rtl8723be_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel);
+void rtl8723be_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					   u8 *ppowerlevel_ofdm,
+					   u8 *ppowerlevel_bw20,
+					   u8 *ppowerlevel_bw40,
+					   u8 channel);
+bool rtl8723be_phy_rf6052_config(struct ieee80211_hw *hw);
+
+#endif
-- 
1.8.4
