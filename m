From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 08/15] rtlwifi: rtl8723ae: Add new driver - Part 8
Date: Mon, 17 Sep 2012 16:18:47 -0500
Message-ID: <1347916754-9219-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, <chaoming_li@realsil.com.cn>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50901 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528Ab2IQVTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 17:19:38 -0400
In-Reply-To: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is part 8 of the addition of files for a new driver to handle
the Realtek RTL8723AE wireless device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: <chaoming_li@realsil.com.cn>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |  113 +++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  313 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c |  145 +++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |  101 +++++++
 4 files changed, 672 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h

Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
@@ -0,0 +1,111 @@
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
+#include "pwrseqcmd.h"
+#include "pwrseq.h"
+
+
+/*
+    drivers should parse below arrays and do the corresponding actions
+*/
+/*3 Power on  Array*/
+struct wlan_pwr_cfg rtl8723A_power_on_flow[RTL8723A_TRANS_CARDEMU_TO_ACT_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_CARDEMU_TO_ACT
+	RTL8723A_TRANS_END
+};
+
+/*3Radio off GPIO Array */
+struct wlan_pwr_cfg rtl8723A_radio_off_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_END
+};
+
+/*3Card Disable Array*/
+struct wlan_pwr_cfg
+rtl8723A_card_disable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+			  + RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
+			  + RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_CARDDIS
+	RTL8723A_TRANS_END
+};
+
+/*3 Card Enable Array*/
+struct wlan_pwr_cfg rtl8723A_card_enable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+					+ RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_CARDDIS_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_ACT
+	RTL8723A_TRANS_END
+};
+
+/*3Suspend Array*/
+struct wlan_pwr_cfg rtl8723A_suspend_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+					+ RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_SUS
+	RTL8723A_TRANS_END
+};
+
+/*3 Resume Array*/
+struct wlan_pwr_cfg rtl8723A_resume_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+					+ RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_SUS_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_ACT
+	RTL8723A_TRANS_END
+};
+
+/*3HWPDN Array*/
+struct wlan_pwr_cfg rtl8723A_hwpdn_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+				+ RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
+				+ RTL8723A_TRANS_END_STPS] = {
+	RTL8723A_TRANS_ACT_TO_CARDEMU
+	RTL8723A_TRANS_CARDEMU_TO_PDN
+	RTL8723A_TRANS_END
+};
+
+/*3 Enter LPS */
+struct wlan_pwr_cfg rtl8723A_enter_lps_flow[RTL8723A_TRANS_ACT_TO_LPS_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	/*FW behavior*/
+	RTL8723A_TRANS_ACT_TO_LPS
+	RTL8723A_TRANS_END
+};
+
+/*3 Leave LPS */
+struct wlan_pwr_cfg rtl8723A_leave_lps_flow[RTL8723A_TRANS_LPS_TO_ACT_STPS
+					+ RTL8723A_TRANS_END_STPS] = {
+	/*FW behavior*/
+	RTL8723A_TRANS_LPS_TO_ACT
+	RTL8723A_TRANS_END
+};
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
@@ -0,0 +1,311 @@
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
+#ifndef __RTL8723E_PWRSEQ_H__
+#define __RTL8723E_PWRSEQ_H__
+
+#include "pwrseqcmd.h"
+/*
+	Check document WM-20110607-Paul-RTL8723A_Power_Architecture-R02.vsd
+	There are 6 HW Power States:
+	0: POFF--Power Off
+	1: PDN--Power Down
+	2: CARDEMU--Card Emulation
+	3: ACT--Active Mode
+	4: LPS--Low Power State
+	5: SUS--Suspend
+
+	The transision from different states are defined below
+	TRANS_CARDEMU_TO_ACT
+	TRANS_ACT_TO_CARDEMU
+	TRANS_CARDEMU_TO_SUS
+	TRANS_SUS_TO_CARDEMU
+	TRANS_CARDEMU_TO_PDN
+	TRANS_ACT_TO_LPS
+	TRANS_LPS_TO_ACT
+
+	TRANS_END
+*/
+
+#define	RTL8723A_TRANS_CARDEMU_TO_ACT_STPS	10
+#define	RTL8723A_TRANS_ACT_TO_CARDEMU_STPS	10
+#define	RTL8723A_TRANS_CARDEMU_TO_SUS_STPS	10
+#define	RTL8723A_TRANS_SUS_TO_CARDEMU_STPS	10
+#define	RTL8723A_TRANS_CARDEMU_TO_PDN_STPS	10
+#define	RTL8723A_TRANS_PDN_TO_CARDEMU_STPS	10
+#define	RTL8723A_TRANS_ACT_TO_LPS_STPS		15
+#define	RTL8723A_TRANS_LPS_TO_ACT_STPS		15
+#define	RTL8723A_TRANS_END_STPS		1
+
+
+#define RTL8723A_TRANS_CARDEMU_TO_ACT					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, \
+	 *  comments here*/						\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), 0},		\
+		/* disable SW LPS 0x04[10]=0*/				\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), BIT(1)},	\
+		/* wait till 0x04[17] = 1    power ready*/		\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},	\
+		/* release WLON reset  0x04[16]=1*/			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},		\
+		/* disable HWPDN 0x04[15]=0*/				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT(4)|BIT(3)), 0},	\
+	/* disable WL suspend*/						\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), BIT(0)},	\
+		/* polling until return 0*/				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(0), 0},
+
+#define RTL8723A_TRANS_ACT_TO_CARDEMU					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, \
+	 *  comments here*/						\
+	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},		\
+		/*0x1F[7:0] = 0 turn off RF*/				\
+	{0x004E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(1), 0},
+
+#define RTL8723A_TRANS_CARDEMU_TO_SUS					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, \
+	 *  comments here*/						\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4)|BIT(3),		\
+		(BIT(4)|BIT(3))},					\
+		/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK |	\
+		PWR_INTF_SDIO_MSK,					\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},\
+		 /*0x04[12:11] = 2b'01 enable WL suspend*/		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+		PWR_BASEADDR_MAC,					\
+		PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)|BIT(4)},		\
+		 /*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO,					\
+		PWR_CMD_WRITE, BIT(0), BIT(0)},				\
+		/*Set SDIO suspend local register*/			\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO,					\
+		PWR_CMD_POLLING, BIT(1), 0},				\
+		/*wait power state to suspend*/
+
+#define RTL8723A_TRANS_SUS_TO_CARDEMU					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},		\
+		/*Set SDIO suspend local register*/			\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},	\
+		/*wait power state to suspend*/				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},	\
+		/*0x04[12:11] = 2b'01enable WL suspend*/
+
+#define RTL8723A_TRANS_CARDEMU_TO_CARDDIS				\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,				\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},\
+		/*0x04[12:11] = 2b'01 enable WL suspend*/		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(2), BIT(2)},	\
+		/*0x04[10] = 1, enable SW LPS*/				\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), BIT(0)},	\
+		/*Set SDIO suspend local register*/			\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), 0},		\
+		/*wait power state to suspend*/
+
+#define RTL8723A_TRANS_CARDDIS_TO_CARDEMU				\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT(0), 0},		\
+		/*Set SDIO suspend local register*/			\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT(1), BIT(1)},	\
+		/*wait power state to suspend*/				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(3)|BIT(4), 0},	\
+		/*0x04[12:11] = 2b'00enable WL suspend*/		\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0},/*PCIe DMA start*/
+
+#define RTL8723A_TRANS_CARDEMU_TO_PDN					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},/* 0x04[16] = 0*/\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), BIT(7)},	\
+		/* 0x04[15] = 1*/
+
+#define RTL8723A_TRANS_PDN_TO_CARDEMU					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(7), 0},/* 0x04[15] = 0*/
+
+#define RTL8723A_TRANS_ACT_TO_LPS					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},/*PCIe DMA stop*/\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x7F},/*Tx Pause*/\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
+		/*Should be zero if no packet is transmitting*/		\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
+		/*Should be zero if no packet is transmitting*/		\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
+		/*Should be zero if no packet is transmitting*/		\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0},		\
+		/*Should be zero if no packet is transmitting*/		\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(0), 0},		\
+		/*CCK and OFDM are disabled,and clock are gated*/	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},	\
+		/*Delay 1us*/						\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},		\
+		/*Whole BB is reset*/					\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x3F},/*Reset MAC TRX*/\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), 0},		\
+		/*check if removed later*/				\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(5), BIT(5)},	\
+		/*Respond TxOK to scheduler*/
+
+#define RTL8723A_TRANS_LPS_TO_ACT					\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+		 PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84}, /*SDIO RPWM*/\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84}, /*USB RPWM*/\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84}, /*PCIe RPWM*/\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		 PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS},	\
+		/*Delay*/						\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(4), 0},		\
+		/* 0x08[4] = 0 switch TSF to 40M*/			\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT(7), 0},		\
+		/*Polling 0x109[7]=0  TSF in 40M*/			\
+	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(6)|BIT(7), 0},	\
+		/*.	0x29[7:6] = 2b'00	 enable BB clock*/	\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1), BIT(1)},	\
+		/*.	0x101[1] = 1*/					\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF},		\
+		/* 0x100[7:0] = 0xFF enable WMAC TRX*/			\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT(1)|BIT(0),		\
+		BIT(1)|BIT(0)}, /* 0x02[1:0] = 2b'11  enable BB macro*/	\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+		PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0}, /*.	0x522 = 0*/
+
+#define RTL8723A_TRANS_END						\
+	/* format */							\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value }, */\
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	0, PWR_CMD_END, 0, 0}
+
+extern struct
+wlan_pwr_cfg rtl8723A_power_on_flow[RTL8723A_TRANS_CARDEMU_TO_ACT_STPS
+				    + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_radio_off_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+				     + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_card_disable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+					+ RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
+					+ RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_card_enable_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+				       + RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
+				       + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_suspend_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+				   + RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
+				   + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_resume_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+				  + RTL8723A_TRANS_CARDEMU_TO_SUS_STPS
+				  + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_hwpdn_flow[RTL8723A_TRANS_ACT_TO_CARDEMU_STPS
+				 + RTL8723A_TRANS_CARDEMU_TO_PDN_STPS
+				 + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_enter_lps_flow[RTL8723A_TRANS_ACT_TO_LPS_STPS
+				     + RTL8723A_TRANS_END_STPS];
+extern struct
+wlan_pwr_cfg rtl8723A_leave_lps_flow[RTL8723A_TRANS_LPS_TO_ACT_STPS
+				     + RTL8723A_TRANS_END_STPS];
+
+/* RTL8723 Power Configuration CMDs for PCIe interface */
+#define Rtl8723_NIC_PWR_ON_FLOW		rtl8723A_power_on_flow
+#define Rtl8723_NIC_RF_OFF_FLOW		rtl8723A_radio_off_flow
+#define Rtl8723_NIC_DISABLE_FLOW	rtl8723A_card_disable_flow
+#define Rtl8723_NIC_ENABLE_FLOW		rtl8723A_card_enable_flow
+#define Rtl8723_NIC_SUSPEND_FLOW	rtl8723A_suspend_flow
+#define Rtl8723_NIC_RESUME_FLOW		rtl8723A_resume_flow
+#define Rtl8723_NIC_PDN_FLOW		rtl8723A_hwpdn_flow
+#define Rtl8723_NIC_LPS_ENTER_FLOW	rtl8723A_enter_lps_flow
+#define Rtl8723_NIC_LPS_LEAVE_FLOW	rtl8723A_leave_lps_flow
+
+#endif
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
@@ -0,0 +1,137 @@
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
+/*
+*	Description:
+*		This routine deal with the Power Configuration CMDs
+*		 parsing for RTL8723/RTL8188E Series IC.
+*	Assumption:
+*		We should follow specific format which was released from HW SD.
+*
+*	2011.07.07, added by Roger.
+*/
+bool rtl_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 faversion, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[])
+
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
+			"rtl_hal_pwrseqcmdparsing(): offset(%#x),cut_msk(%#x), famsk(%#x),"
+			"interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
+			GET_PWR_CFG_OFFSET(cfg_cmd),
+					   GET_PWR_CFG_CUT_MASK(cfg_cmd),
+			GET_PWR_CFG_FAB_MASK(cfg_cmd),
+					     GET_PWR_CFG_INTF_MASK(cfg_cmd),
+			GET_PWR_CFG_BASE(cfg_cmd), GET_PWR_CFG_CMD(cfg_cmd),
+			GET_PWR_CFG_MASK(cfg_cmd), GET_PWR_CFG_VALUE(cfg_cmd));
+
+		if ((GET_PWR_CFG_FAB_MASK(cfg_cmd)&faversion) &&
+		    (GET_PWR_CFG_CUT_MASK(cfg_cmd)&cut_version) &&
+		    (GET_PWR_CFG_INTF_MASK(cfg_cmd)&interface_type)) {
+			switch (GET_PWR_CFG_CMD(cfg_cmd)) {
+			case PWR_CMD_READ:
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_READ\n");
+				break;
+			case PWR_CMD_WRITE: {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_WRITE\n");
+				offset = GET_PWR_CFG_OFFSET(cfg_cmd);
+
+					/*Read the value from system register*/
+					value = rtl_read_byte(rtlpriv, offset);
+					value &= (~(GET_PWR_CFG_MASK(cfg_cmd)));
+					value |= (GET_PWR_CFG_VALUE(cfg_cmd) &
+						  GET_PWR_CFG_MASK(cfg_cmd));
+
+					/*Write the value back to sytem
+					 * register*/
+					rtl_write_byte(rtlpriv, offset, value);
+				}
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
+					    (GET_PWR_CFG_VALUE(cfg_cmd)
+					    & GET_PWR_CFG_MASK(cfg_cmd)))
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
+					"rtl_hal_pwrseqcmdparsing(): PWR_CMD_DELAY\n");
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
+					 "rtl_hal_pwrseqcmdparsing(): Unknown CMD!!\n");
+				break;
+			}
+
+		}
+
+		ary_idx++;
+	} while (1);
+
+	return true;
+}
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
@@ -0,0 +1,99 @@
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
+#include "../wifi.h"
+/*---------------------------------------------
+ * 3 The value of cmd: 4 bits
+ *---------------------------------------------*/
+#define  PWR_CMD_READ		0x00
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
