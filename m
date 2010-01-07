From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 08/13] stmmac: move the dma out from the main
Date: Thu,  7 Jan 2010 10:07:18 +0100
Message-ID: <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:49496 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756332Ab0AGJHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:31 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0A07318D
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:26 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 54919BE2
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:25 +0000 (GMT)
In-Reply-To: <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the dma related functions (interrupt, start, stop etc.)
out from the main driver code. This will help to support new DMA
engines.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Makefile         |    2 +-
 drivers/net/stmmac/common.h         |  209 +++++++--------------------
 drivers/net/stmmac/dwmac_dma.h      |  107 ++++++++++++++
 drivers/net/stmmac/dwmac_lib.c      |  263 ++++++++++++++++++++++++++++++++++
 drivers/net/stmmac/gmac.c           |    9 ++
 drivers/net/stmmac/mac100.c         |    9 ++
 drivers/net/stmmac/stmmac_ethtool.c |    1 +
 drivers/net/stmmac/stmmac_main.c    |  268 +++++------------------------------
 8 files changed, 481 insertions(+), 387 deletions(-)
 create mode 100644 drivers/net/stmmac/dwmac_dma.h
 create mode 100644 drivers/net/stmmac/dwmac_lib.c

diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index b2d7a55..c8f499a 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
-stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o \
+stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o dwmac_lib.o \
 		mac100.o  gmac.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 95782cc..6f8fe64 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -25,131 +25,6 @@
 #include "descs.h"
 #include <linux/io.h>
 
-/* *********************************************
-   DMA CRS Control and Status Register Mapping
- * *********************************************/
-#define DMA_BUS_MODE		0x00001000	/* Bus Mode */
-#define DMA_XMT_POLL_DEMAND	0x00001004	/* Transmit Poll Demand */
-#define DMA_RCV_POLL_DEMAND	0x00001008	/* Received Poll Demand */
-#define DMA_RCV_BASE_ADDR	0x0000100c	/* Receive List Base */
-#define DMA_TX_BASE_ADDR	0x00001010	/* Transmit List Base */
-#define DMA_STATUS		0x00001014	/* Status Register */
-#define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
-#define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
-#define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
-#define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
-#define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
-
-/* ********************************
-   DMA Control register defines
- * ********************************/
-#define DMA_CONTROL_ST		0x00002000	/* Start/Stop Transmission */
-#define DMA_CONTROL_SR		0x00000002	/* Start/Stop Receive */
-
-/* **************************************
-   DMA Interrupt Enable register defines
- * **************************************/
-/**** NORMAL INTERRUPT ****/
-#define DMA_INTR_ENA_NIE 0x00010000	/* Normal Summary */
-#define DMA_INTR_ENA_TIE 0x00000001	/* Transmit Interrupt */
-#define DMA_INTR_ENA_TUE 0x00000004	/* Transmit Buffer Unavailable */
-#define DMA_INTR_ENA_RIE 0x00000040	/* Receive Interrupt */
-#define DMA_INTR_ENA_ERE 0x00004000	/* Early Receive */
-
-#define DMA_INTR_NORMAL	(DMA_INTR_ENA_NIE | DMA_INTR_ENA_RIE | \
-			DMA_INTR_ENA_TIE)
-
-/**** ABNORMAL INTERRUPT ****/
-#define DMA_INTR_ENA_AIE 0x00008000	/* Abnormal Summary */
-#define DMA_INTR_ENA_FBE 0x00002000	/* Fatal Bus Error */
-#define DMA_INTR_ENA_ETE 0x00000400	/* Early Transmit */
-#define DMA_INTR_ENA_RWE 0x00000200	/* Receive Watchdog */
-#define DMA_INTR_ENA_RSE 0x00000100	/* Receive Stopped */
-#define DMA_INTR_ENA_RUE 0x00000080	/* Receive Buffer Unavailable */
-#define DMA_INTR_ENA_UNE 0x00000020	/* Tx Underflow */
-#define DMA_INTR_ENA_OVE 0x00000010	/* Receive Overflow */
-#define DMA_INTR_ENA_TJE 0x00000008	/* Transmit Jabber */
-#define DMA_INTR_ENA_TSE 0x00000002	/* Transmit Stopped */
-
-#define DMA_INTR_ABNORMAL	(DMA_INTR_ENA_AIE | DMA_INTR_ENA_FBE | \
-				DMA_INTR_ENA_UNE)
-
-/* DMA default interrupt mask */
-#define DMA_INTR_DEFAULT_MASK	(DMA_INTR_NORMAL | DMA_INTR_ABNORMAL)
-
-/* ****************************
- *  DMA Status register defines
- * ****************************/
-#define DMA_STATUS_GPI		0x10000000	/* PMT interrupt */
-#define DMA_STATUS_GMI		0x08000000	/* MMC interrupt */
-#define DMA_STATUS_GLI		0x04000000	/* GMAC Line interface int. */
-#define DMA_STATUS_GMI		0x08000000
-#define DMA_STATUS_GLI		0x04000000
-#define DMA_STATUS_EB_MASK	0x00380000	/* Error Bits Mask */
-#define DMA_STATUS_EB_TX_ABORT	0x00080000	/* Error Bits - TX Abort */
-#define DMA_STATUS_EB_RX_ABORT	0x00100000	/* Error Bits - RX Abort */
-#define DMA_STATUS_TS_MASK	0x00700000	/* Transmit Process State */
-#define DMA_STATUS_TS_SHIFT	20
-#define DMA_STATUS_RS_MASK	0x000e0000	/* Receive Process State */
-#define DMA_STATUS_RS_SHIFT	17
-#define DMA_STATUS_NIS	0x00010000	/* Normal Interrupt Summary */
-#define DMA_STATUS_AIS	0x00008000	/* Abnormal Interrupt Summary */
-#define DMA_STATUS_ERI	0x00004000	/* Early Receive Interrupt */
-#define DMA_STATUS_FBI	0x00002000	/* Fatal Bus Error Interrupt */
-#define DMA_STATUS_ETI	0x00000400	/* Early Transmit Interrupt */
-#define DMA_STATUS_RWT	0x00000200	/* Receive Watchdog Timeout */
-#define DMA_STATUS_RPS	0x00000100	/* Receive Process Stopped */
-#define DMA_STATUS_RU	0x00000080	/* Receive Buffer Unavailable */
-#define DMA_STATUS_RI	0x00000040	/* Receive Interrupt */
-#define DMA_STATUS_UNF	0x00000020	/* Transmit Underflow */
-#define DMA_STATUS_OVF	0x00000010	/* Receive Overflow */
-#define DMA_STATUS_TJT	0x00000008	/* Transmit Jabber Timeout */
-#define DMA_STATUS_TU	0x00000004	/* Transmit Buffer Unavailable */
-#define DMA_STATUS_TPS	0x00000002	/* Transmit Process Stopped */
-#define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
-
-/* Other defines */
-#define HASH_TABLE_SIZE 64
-#define PAUSE_TIME 0x200
-
-/* Flow Control defines */
-#define FLOW_OFF	0
-#define FLOW_RX		1
-#define FLOW_TX		2
-#define FLOW_AUTO	(FLOW_TX | FLOW_RX)
-
-/* DMA STORE-AND-FORWARD Operation Mode */
-#define SF_DMA_MODE 1
-
-#define HW_CSUM 1
-#define NO_HW_CSUM 0
-
-/* GMAC TX FIFO is 8K, Rx FIFO is 16K */
-#define BUF_SIZE_16KiB 16384
-#define BUF_SIZE_8KiB 8192
-#define BUF_SIZE_4KiB 4096
-#define BUF_SIZE_2KiB 2048
-
-/* Power Down and WOL */
-#define PMT_NOT_SUPPORTED 0
-#define PMT_SUPPORTED 1
-
-/* Common MAC defines */
-#define MAC_CTRL_REG		0x00000000	/* MAC Control */
-#define MAC_ENABLE_TX		0x00000008	/* Transmitter Enable */
-#define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
-
-/* MAC Management Counters register */
-#define MMC_CONTROL		0x00000100	/* MMC Control */
-#define MMC_HIGH_INTR		0x00000104	/* MMC High Interrupt */
-#define MMC_LOW_INTR		0x00000108	/* MMC Low Interrupt */
-#define MMC_HIGH_INTR_MASK	0x0000010c	/* MMC High Interrupt Mask */
-#define MMC_LOW_INTR_MASK	0x00000110	/* MMC Low Interrupt Mask */
-
-#define MMC_CONTROL_MAX_FRM_MASK	0x0003ff8	/* Maximum Frame Size */
-#define MMC_CONTROL_MAX_FRM_SHIFT	3
-#define MMC_CONTROL_MAX_FRAME		0x7FF
-
 struct stmmac_extra_stats {
 	/* Transmit errors */
 	unsigned long tx_underflow ____cacheline_aligned;
@@ -198,46 +73,56 @@ struct stmmac_extra_stats {
 	unsigned long normal_irq_n;
 };
 
-/* GMAC core can compute the checksums in HW. */
-enum rx_frame_status {
+#define HASH_TABLE_SIZE 64
+#define PAUSE_TIME 0x200
+
+/* Flow Control defines */
+#define FLOW_OFF	0
+#define FLOW_RX		1
+#define FLOW_TX		2
+#define FLOW_AUTO	(FLOW_TX | FLOW_RX)
+
+#define SF_DMA_MODE 1 /* DMA STORE-AND-FORWARD Operation Mode */
+
+#define HW_CSUM 1
+#define NO_HW_CSUM 0
+enum rx_frame_status { /* IPC status */
 	good_frame = 0,
 	discard_frame = 1,
 	csum_none = 2,
 };
 
-static inline void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
-			 unsigned int high, unsigned int low)
-{
-	unsigned long data;
-
-	data = (addr[5] << 8) | addr[4];
-	writel(data, ioaddr + high);
-	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
-	writel(data, ioaddr + low);
+enum tx_dma_irq_status {
+	tx_hard_error = 1,
+	tx_hard_error_bump_tc = 2,
+	handle_tx_rx = 3,
+};
 
-	return;
-}
+/* GMAC TX FIFO is 8K, Rx FIFO is 16K */
+#define BUF_SIZE_16KiB 16384
+#define BUF_SIZE_8KiB 8192
+#define BUF_SIZE_4KiB 4096
+#define BUF_SIZE_2KiB 2048
 
-static inline void stmmac_get_mac_addr(unsigned long ioaddr,
-				unsigned char *addr, unsigned int high,
-				unsigned int low)
-{
-	unsigned int hi_addr, lo_addr;
+/* Power Down and WOL */
+#define PMT_NOT_SUPPORTED 0
+#define PMT_SUPPORTED 1
 
-	/* Read the MAC address from the hardware */
-	hi_addr = readl(ioaddr + high);
-	lo_addr = readl(ioaddr + low);
+/* Common MAC defines */
+#define MAC_CTRL_REG		0x00000000	/* MAC Control */
+#define MAC_ENABLE_TX		0x00000008	/* Transmitter Enable */
+#define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
 
-	/* Extract the MAC address from the high and low words */
-	addr[0] = lo_addr & 0xff;
-	addr[1] = (lo_addr >> 8) & 0xff;
-	addr[2] = (lo_addr >> 16) & 0xff;
-	addr[3] = (lo_addr >> 24) & 0xff;
-	addr[4] = hi_addr & 0xff;
-	addr[5] = (hi_addr >> 8) & 0xff;
+/* MAC Management Counters register */
+#define MMC_CONTROL		0x00000100	/* MMC Control */
+#define MMC_HIGH_INTR		0x00000104	/* MMC High Interrupt */
+#define MMC_LOW_INTR		0x00000108	/* MMC Low Interrupt */
+#define MMC_HIGH_INTR_MASK	0x0000010c	/* MMC High Interrupt Mask */
+#define MMC_LOW_INTR_MASK	0x00000110	/* MMC Low Interrupt Mask */
 
-	return;
-}
+#define MMC_CONTROL_MAX_FRM_MASK	0x0003ff8	/* Maximum Frame Size */
+#define MMC_CONTROL_MAX_FRM_SHIFT	3
+#define MMC_CONTROL_MAX_FRAME		0x7FF
 
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
@@ -287,6 +172,15 @@ struct stmmac_dma_ops {
 	/* To track extra statistic (if supported) */
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   unsigned long ioaddr);
+	void (*enable_dma_transmission) (unsigned long ioaddr);
+	void (*enable_dma_irq) (unsigned long ioaddr);
+	void (*disable_dma_irq) (unsigned long ioaddr);
+	void (*start_tx) (unsigned long ioaddr);
+	void (*stop_tx) (unsigned long ioaddr);
+	void (*start_rx) (unsigned long ioaddr);
+	void (*stop_rx) (unsigned long ioaddr);
+	int (*dma_interrupt) (unsigned long ioaddr,
+			      struct stmmac_extra_stats *x);
 };
 
 struct stmmac_ops {
@@ -332,3 +226,8 @@ struct mac_device_info {
 
 struct mac_device_info *gmac_setup(unsigned long addr);
 struct mac_device_info *mac100_setup(unsigned long addr);
+
+extern void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
+				unsigned int high, unsigned int low);
+extern void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
+				unsigned int high, unsigned int low);
diff --git a/drivers/net/stmmac/dwmac_dma.h b/drivers/net/stmmac/dwmac_dma.h
new file mode 100644
index 0000000..de848d9
--- /dev/null
+++ b/drivers/net/stmmac/dwmac_dma.h
@@ -0,0 +1,107 @@
+/*******************************************************************************
+  DWMAC DMA Header file.
+
+  Copyright (C) 2007-2009  STMicroelectronics Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+/* DMA CRS Control and Status Register Mapping */
+#define DMA_BUS_MODE		0x00001000	/* Bus Mode */
+#define DMA_XMT_POLL_DEMAND	0x00001004	/* Transmit Poll Demand */
+#define DMA_RCV_POLL_DEMAND	0x00001008	/* Received Poll Demand */
+#define DMA_RCV_BASE_ADDR	0x0000100c	/* Receive List Base */
+#define DMA_TX_BASE_ADDR	0x00001010	/* Transmit List Base */
+#define DMA_STATUS		0x00001014	/* Status Register */
+#define DMA_CONTROL		0x00001018	/* Ctrl (Operational Mode) */
+#define DMA_INTR_ENA		0x0000101c	/* Interrupt Enable */
+#define DMA_MISSED_FRAME_CTR	0x00001020	/* Missed Frame Counter */
+#define DMA_CUR_TX_BUF_ADDR	0x00001050	/* Current Host Tx Buffer */
+#define DMA_CUR_RX_BUF_ADDR	0x00001054	/* Current Host Rx Buffer */
+
+/* DMA Control register defines */
+#define DMA_CONTROL_ST		0x00002000	/* Start/Stop Transmission */
+#define DMA_CONTROL_SR		0x00000002	/* Start/Stop Receive */
+
+/* DMA Normal interrupt */
+#define DMA_INTR_ENA_NIE 0x00010000	/* Normal Summary */
+#define DMA_INTR_ENA_TIE 0x00000001	/* Transmit Interrupt */
+#define DMA_INTR_ENA_TUE 0x00000004	/* Transmit Buffer Unavailable */
+#define DMA_INTR_ENA_RIE 0x00000040	/* Receive Interrupt */
+#define DMA_INTR_ENA_ERE 0x00004000	/* Early Receive */
+
+#define DMA_INTR_NORMAL	(DMA_INTR_ENA_NIE | DMA_INTR_ENA_RIE | \
+			DMA_INTR_ENA_TIE)
+
+/* DMA Abnormal interrupt */
+#define DMA_INTR_ENA_AIE 0x00008000	/* Abnormal Summary */
+#define DMA_INTR_ENA_FBE 0x00002000	/* Fatal Bus Error */
+#define DMA_INTR_ENA_ETE 0x00000400	/* Early Transmit */
+#define DMA_INTR_ENA_RWE 0x00000200	/* Receive Watchdog */
+#define DMA_INTR_ENA_RSE 0x00000100	/* Receive Stopped */
+#define DMA_INTR_ENA_RUE 0x00000080	/* Receive Buffer Unavailable */
+#define DMA_INTR_ENA_UNE 0x00000020	/* Tx Underflow */
+#define DMA_INTR_ENA_OVE 0x00000010	/* Receive Overflow */
+#define DMA_INTR_ENA_TJE 0x00000008	/* Transmit Jabber */
+#define DMA_INTR_ENA_TSE 0x00000002	/* Transmit Stopped */
+
+#define DMA_INTR_ABNORMAL	(DMA_INTR_ENA_AIE | DMA_INTR_ENA_FBE | \
+				DMA_INTR_ENA_UNE)
+
+/* DMA default interrupt mask */
+#define DMA_INTR_DEFAULT_MASK	(DMA_INTR_NORMAL | DMA_INTR_ABNORMAL)
+
+/* DMA Status register defines */
+#define DMA_STATUS_GPI		0x10000000	/* PMT interrupt */
+#define DMA_STATUS_GMI		0x08000000	/* MMC interrupt */
+#define DMA_STATUS_GLI		0x04000000	/* GMAC Line interface int */
+#define DMA_STATUS_GMI		0x08000000
+#define DMA_STATUS_GLI		0x04000000
+#define DMA_STATUS_EB_MASK	0x00380000	/* Error Bits Mask */
+#define DMA_STATUS_EB_TX_ABORT	0x00080000	/* Error Bits - TX Abort */
+#define DMA_STATUS_EB_RX_ABORT	0x00100000	/* Error Bits - RX Abort */
+#define DMA_STATUS_TS_MASK	0x00700000	/* Transmit Process State */
+#define DMA_STATUS_TS_SHIFT	20
+#define DMA_STATUS_RS_MASK	0x000e0000	/* Receive Process State */
+#define DMA_STATUS_RS_SHIFT	17
+#define DMA_STATUS_NIS	0x00010000	/* Normal Interrupt Summary */
+#define DMA_STATUS_AIS	0x00008000	/* Abnormal Interrupt Summary */
+#define DMA_STATUS_ERI	0x00004000	/* Early Receive Interrupt */
+#define DMA_STATUS_FBI	0x00002000	/* Fatal Bus Error Interrupt */
+#define DMA_STATUS_ETI	0x00000400	/* Early Transmit Interrupt */
+#define DMA_STATUS_RWT	0x00000200	/* Receive Watchdog Timeout */
+#define DMA_STATUS_RPS	0x00000100	/* Receive Process Stopped */
+#define DMA_STATUS_RU	0x00000080	/* Receive Buffer Unavailable */
+#define DMA_STATUS_RI	0x00000040	/* Receive Interrupt */
+#define DMA_STATUS_UNF	0x00000020	/* Transmit Underflow */
+#define DMA_STATUS_OVF	0x00000010	/* Receive Overflow */
+#define DMA_STATUS_TJT	0x00000008	/* Transmit Jabber Timeout */
+#define DMA_STATUS_TU	0x00000004	/* Transmit Buffer Unavailable */
+#define DMA_STATUS_TPS	0x00000002	/* Transmit Process Stopped */
+#define DMA_STATUS_TI	0x00000001	/* Transmit Interrupt */
+
+extern void dwmac_enable_dma_transmission(unsigned long ioaddr);
+extern void dwmac_enable_dma_irq(unsigned long ioaddr);
+extern void dwmac_disable_dma_irq(unsigned long ioaddr);
+extern void dwmac_dma_start_tx(unsigned long ioaddr);
+extern void dwmac_dma_stop_tx(unsigned long ioaddr);
+extern void dwmac_dma_start_rx(unsigned long ioaddr);
+extern void dwmac_dma_stop_rx(unsigned long ioaddr);
+extern int dwmac_dma_interrupt(unsigned long ioaddr,
+				struct stmmac_extra_stats *x);
diff --git a/drivers/net/stmmac/dwmac_lib.c b/drivers/net/stmmac/dwmac_lib.c
new file mode 100644
index 0000000..d4adb1e
--- /dev/null
+++ b/drivers/net/stmmac/dwmac_lib.c
@@ -0,0 +1,263 @@
+/*******************************************************************************
+  Copyright (C) 2007-2009  STMicroelectronics Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#include <linux/io.h>
+#include "common.h"
+#include "dwmac_dma.h"
+
+#undef DWMAC_DMA_DEBUG
+#ifdef DWMAC_DMA_DEBUG
+#define DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define DBG(fmt, args...)  do { } while (0)
+#endif
+
+/* CSR1 enables the transmit DMA to check for new descriptor */
+void dwmac_enable_dma_transmission(unsigned long ioaddr)
+{
+	writel(1, ioaddr + DMA_XMT_POLL_DEMAND);
+}
+
+void dwmac_enable_dma_irq(unsigned long ioaddr)
+{
+	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
+}
+
+void dwmac_disable_dma_irq(unsigned long ioaddr)
+{
+	writel(0, ioaddr + DMA_INTR_ENA);
+}
+
+void dwmac_dma_start_tx(unsigned long ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CONTROL);
+	value |= DMA_CONTROL_ST;
+	writel(value, ioaddr + DMA_CONTROL);
+	return;
+}
+
+void dwmac_dma_stop_tx(unsigned long ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CONTROL);
+	value &= ~DMA_CONTROL_ST;
+	writel(value, ioaddr + DMA_CONTROL);
+	return;
+}
+
+void dwmac_dma_start_rx(unsigned long ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CONTROL);
+	value |= DMA_CONTROL_SR;
+	writel(value, ioaddr + DMA_CONTROL);
+
+	return;
+}
+
+void dwmac_dma_stop_rx(unsigned long ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CONTROL);
+	value &= ~DMA_CONTROL_SR;
+	writel(value, ioaddr + DMA_CONTROL);
+
+	return;
+}
+
+#ifdef DWMAC_DMA_DEBUG
+static void show_tx_process_state(unsigned int status)
+{
+	unsigned int state;
+	state = (status & DMA_STATUS_TS_MASK) >> DMA_STATUS_TS_SHIFT;
+
+	switch (state) {
+	case 0:
+		pr_info("- TX (Stopped): Reset or Stop command\n");
+		break;
+	case 1:
+		pr_info("- TX (Running):Fetching the Tx desc\n");
+		break;
+	case 2:
+		pr_info("- TX (Running): Waiting for end of tx\n");
+		break;
+	case 3:
+		pr_info("- TX (Running): Reading the data "
+		       "and queuing the data into the Tx buf\n");
+		break;
+	case 6:
+		pr_info("- TX (Suspended): Tx Buff Underflow "
+		       "or an unavailable Transmit descriptor\n");
+		break;
+	case 7:
+		pr_info("- TX (Running): Closing Tx descriptor\n");
+		break;
+	default:
+		break;
+	}
+	return;
+}
+
+static void show_rx_process_state(unsigned int status)
+{
+	unsigned int state;
+	state = (status & DMA_STATUS_RS_MASK) >> DMA_STATUS_RS_SHIFT;
+
+	switch (state) {
+	case 0:
+		pr_info("- RX (Stopped): Reset or Stop command\n");
+		break;
+	case 1:
+		pr_info("- RX (Running): Fetching the Rx desc\n");
+		break;
+	case 2:
+		pr_info("- RX (Running):Checking for end of pkt\n");
+		break;
+	case 3:
+		pr_info("- RX (Running): Waiting for Rx pkt\n");
+		break;
+	case 4:
+		pr_info("- RX (Suspended): Unavailable Rx buf\n");
+		break;
+	case 5:
+		pr_info("- RX (Running): Closing Rx descriptor\n");
+		break;
+	case 6:
+		pr_info("- RX(Running): Flushing the current frame"
+		       " from the Rx buf\n");
+		break;
+	case 7:
+		pr_info("- RX (Running): Queuing the Rx frame"
+		       " from the Rx buf into memory\n");
+		break;
+	default:
+		break;
+	}
+	return;
+}
+#endif
+
+int dwmac_dma_interrupt(unsigned long ioaddr,
+			struct stmmac_extra_stats *x)
+{
+	int ret = 0;
+	/* read the status register (CSR5) */
+	u32 intr_status = readl(ioaddr + DMA_STATUS);
+
+	DBG(INFO, "%s: [CSR5: 0x%08x]\n", __func__, intr_status);
+#ifdef DWMAC_DMA_DEBUG
+	/* It displays the DMA process states (CSR5 register) */
+	show_tx_process_state(intr_status);
+	show_rx_process_state(intr_status);
+#endif
+	/* ABNORMAL interrupts */
+	if (unlikely(intr_status & DMA_STATUS_AIS)) {
+		DBG(INFO, "CSR5[15] DMA ABNORMAL IRQ: ");
+		if (unlikely(intr_status & DMA_STATUS_UNF)) {
+			DBG(INFO, "transmit underflow\n");
+			ret = tx_hard_error_bump_tc;
+			x->tx_undeflow_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_TJT)) {
+			DBG(INFO, "transmit jabber\n");
+			x->tx_jabber_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_OVF)) {
+			DBG(INFO, "recv overflow\n");
+			x->rx_overflow_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_RU)) {
+			DBG(INFO, "receive buffer unavailable\n");
+			x->rx_buf_unav_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_RPS)) {
+			DBG(INFO, "receive process stopped\n");
+			x->rx_process_stopped_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_RWT)) {
+			DBG(INFO, "receive watchdog\n");
+			x->rx_watchdog_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_ETI)) {
+			DBG(INFO, "transmit early interrupt\n");
+			x->tx_early_irq++;
+		}
+		if (unlikely(intr_status & DMA_STATUS_TPS)) {
+			DBG(INFO, "transmit process stopped\n");
+			x->tx_process_stopped_irq++;
+			ret = tx_hard_error;
+		}
+		if (unlikely(intr_status & DMA_STATUS_FBI)) {
+			DBG(INFO, "fatal bus error\n");
+			x->fatal_bus_error_irq++;
+			ret = tx_hard_error;
+		}
+	}
+	/* TX/RX NORMAL interrupts */
+	if (intr_status & DMA_STATUS_NIS) {
+		x->normal_irq_n++;
+		if (likely((intr_status & DMA_STATUS_RI) ||
+			 (intr_status & (DMA_STATUS_TI))))
+				ret = handle_tx_rx;
+	}
+	/* Optional hardware blocks, interrupts should be disabled */
+	if (unlikely(intr_status &
+		     (DMA_STATUS_GPI | DMA_STATUS_GMI | DMA_STATUS_GLI)))
+		pr_info("%s: unexpected status %08x\n", __func__, intr_status);
+	/* Clear the interrupt by writing a logic 1 to the CSR5[15-0] */
+	writel((intr_status & 0x1ffff), ioaddr + DMA_STATUS);
+
+	DBG(INFO, "\n\n");
+	return ret;
+}
+
+
+void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
+			 unsigned int high, unsigned int low)
+{
+	unsigned long data;
+
+	data = (addr[5] << 8) | addr[4];
+	writel(data, ioaddr + high);
+	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
+	writel(data, ioaddr + low);
+
+	return;
+}
+
+void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
+			 unsigned int high, unsigned int low)
+{
+	unsigned int hi_addr, lo_addr;
+
+	/* Read the MAC address from the hardware */
+	hi_addr = readl(ioaddr + high);
+	lo_addr = readl(ioaddr + low);
+
+	/* Extract the MAC address from the high and low words */
+	addr[0] = lo_addr & 0xff;
+	addr[1] = (lo_addr >> 8) & 0xff;
+	addr[2] = (lo_addr >> 16) & 0xff;
+	addr[3] = (lo_addr >> 24) & 0xff;
+	addr[4] = hi_addr & 0xff;
+	addr[5] = (hi_addr >> 8) & 0xff;
+
+	return;
+}
+
diff --git a/drivers/net/stmmac/gmac.c b/drivers/net/stmmac/gmac.c
index cf199d9..0788092 100644
--- a/drivers/net/stmmac/gmac.c
+++ b/drivers/net/stmmac/gmac.c
@@ -31,6 +31,7 @@
 
 #include "stmmac.h"
 #include "gmac.h"
+#include "dwmac_dma.h"
 
 #undef GMAC_DEBUG
 /*#define GMAC_DEBUG*/
@@ -646,6 +647,14 @@ struct stmmac_dma_ops gmac_dma_ops = {
 	.dump_regs = gmac_dump_dma_regs,
 	.dma_mode = gmac_dma_operation_mode,
 	.dma_diagnostic_fr = gmac_dma_diagnostic_fr,
+	.enable_dma_transmission = dwmac_enable_dma_transmission,
+	.enable_dma_irq = dwmac_enable_dma_irq,
+	.disable_dma_irq = dwmac_disable_dma_irq,
+	.start_tx = dwmac_dma_start_tx,
+	.stop_tx = dwmac_dma_stop_tx,
+	.start_rx = dwmac_dma_start_rx,
+	.stop_rx = dwmac_dma_stop_rx,
+	.dma_interrupt = dwmac_dma_interrupt,
 };
 
 struct stmmac_desc_ops gmac_desc_ops = {
diff --git a/drivers/net/stmmac/mac100.c b/drivers/net/stmmac/mac100.c
index 45d0457..b675f7c 100644
--- a/drivers/net/stmmac/mac100.c
+++ b/drivers/net/stmmac/mac100.c
@@ -33,6 +33,7 @@
 
 #include "common.h"
 #include "mac100.h"
+#include "dwmac_dma.h"
 
 #undef MAC100_DEBUG
 /*#define MAC100_DEBUG*/
@@ -483,6 +484,14 @@ struct stmmac_dma_ops mac100_dma_ops = {
 	.dump_regs = mac100_dump_dma_regs,
 	.dma_mode = mac100_dma_operation_mode,
 	.dma_diagnostic_fr = mac100_dma_diagnostic_fr,
+	.enable_dma_transmission = dwmac_enable_dma_transmission,
+	.enable_dma_irq = dwmac_enable_dma_irq,
+	.disable_dma_irq = dwmac_disable_dma_irq,
+	.start_tx = dwmac_dma_start_tx,
+	.stop_tx = dwmac_dma_stop_tx,
+	.start_rx = dwmac_dma_start_rx,
+	.stop_rx = dwmac_dma_stop_rx,
+	.dma_interrupt = dwmac_dma_interrupt,
 };
 
 struct stmmac_desc_ops mac100_desc_ops = {
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 9c7ce1e..0abeff6 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -28,6 +28,7 @@
 #include <linux/phy.h>
 
 #include "stmmac.h"
+#include "dwmac_dma.h"
 
 #define REG_SPACE_SIZE	0x1054
 #define MAC100_ETHTOOL_NAME	"st_mac100"
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 86e9103..e6c5a3c 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -572,50 +572,6 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 }
 
 /**
- * stmmac_dma_start_tx
- * @ioaddr: device I/O address
- * Description:  this function starts the DMA tx process.
- */
-static void stmmac_dma_start_tx(unsigned long ioaddr)
-{
-	u32 value = readl(ioaddr + DMA_CONTROL);
-	value |= DMA_CONTROL_ST;
-	writel(value, ioaddr + DMA_CONTROL);
-	return;
-}
-
-static void stmmac_dma_stop_tx(unsigned long ioaddr)
-{
-	u32 value = readl(ioaddr + DMA_CONTROL);
-	value &= ~DMA_CONTROL_ST;
-	writel(value, ioaddr + DMA_CONTROL);
-	return;
-}
-
-/**
- * stmmac_dma_start_rx
- * @ioaddr: device I/O address
- * Description:  this function starts the DMA rx process.
- */
-static void stmmac_dma_start_rx(unsigned long ioaddr)
-{
-	u32 value = readl(ioaddr + DMA_CONTROL);
-	value |= DMA_CONTROL_SR;
-	writel(value, ioaddr + DMA_CONTROL);
-
-	return;
-}
-
-static void stmmac_dma_stop_rx(unsigned long ioaddr)
-{
-	u32 value = readl(ioaddr + DMA_CONTROL);
-	value &= ~DMA_CONTROL_SR;
-	writel(value, ioaddr + DMA_CONTROL);
-
-	return;
-}
-
-/**
  *  stmmac_dma_operation_mode - HW DMA operation mode
  *  @priv : pointer to the private device structure.
  *  Description: it sets the DMA operation mode: tx/rx DMA thresholds
@@ -646,88 +602,6 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 	return;
 }
 
-#ifdef STMMAC_DEBUG
-/**
- * show_tx_process_state
- * @status: tx descriptor status field
- * Description: it shows the Transmit Process State for CSR5[22:20]
- */
-static void show_tx_process_state(unsigned int status)
-{
-	unsigned int state;
-	state = (status & DMA_STATUS_TS_MASK) >> DMA_STATUS_TS_SHIFT;
-
-	switch (state) {
-	case 0:
-		pr_info("- TX (Stopped): Reset or Stop command\n");
-		break;
-	case 1:
-		pr_info("- TX (Running):Fetching the Tx desc\n");
-		break;
-	case 2:
-		pr_info("- TX (Running): Waiting for end of tx\n");
-		break;
-	case 3:
-		pr_info("- TX (Running): Reading the data "
-		       "and queuing the data into the Tx buf\n");
-		break;
-	case 6:
-		pr_info("- TX (Suspended): Tx Buff Underflow "
-		       "or an unavailable Transmit descriptor\n");
-		break;
-	case 7:
-		pr_info("- TX (Running): Closing Tx descriptor\n");
-		break;
-	default:
-		break;
-	}
-	return;
-}
-
-/**
- * show_rx_process_state
- * @status: rx descriptor status field
- * Description: it shows the  Receive Process State for CSR5[19:17]
- */
-static void show_rx_process_state(unsigned int status)
-{
-	unsigned int state;
-	state = (status & DMA_STATUS_RS_MASK) >> DMA_STATUS_RS_SHIFT;
-
-	switch (state) {
-	case 0:
-		pr_info("- RX (Stopped): Reset or Stop command\n");
-		break;
-	case 1:
-		pr_info("- RX (Running): Fetching the Rx desc\n");
-		break;
-	case 2:
-		pr_info("- RX (Running):Checking for end of pkt\n");
-		break;
-	case 3:
-		pr_info("- RX (Running): Waiting for Rx pkt\n");
-		break;
-	case 4:
-		pr_info("- RX (Suspended): Unavailable Rx buf\n");
-		break;
-	case 5:
-		pr_info("- RX (Running): Closing Rx descriptor\n");
-		break;
-	case 6:
-		pr_info("- RX(Running): Flushing the current frame"
-		       " from the Rx buf\n");
-		break;
-	case 7:
-		pr_info("- RX (Running): Queuing the Rx frame"
-		       " from the Rx buf into memory\n");
-		break;
-	default:
-		break;
-	}
-	return;
-}
-#endif
-
 /**
  * stmmac_tx:
  * @priv: private driver structure
@@ -811,7 +685,7 @@ static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 		priv->tm->timer_start(tmrate);
 	else
 #endif
-	writel(DMA_INTR_DEFAULT_MASK, priv->dev->base_addr + DMA_INTR_ENA);
+		priv->hw->dma->enable_dma_irq(priv->dev->base_addr);
 }
 
 static inline void stmmac_disable_irq(struct stmmac_priv *priv)
@@ -821,7 +695,7 @@ static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 		priv->tm->timer_stop();
 	else
 #endif
-	writel(0, priv->dev->base_addr + DMA_INTR_ENA);
+		priv->hw->dma->disable_dma_irq(priv->dev->base_addr);
 }
 
 static int stmmac_has_work(struct stmmac_priv *priv)
@@ -880,12 +754,12 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 {
 	netif_stop_queue(priv->dev);
 
-	stmmac_dma_stop_tx(priv->dev->base_addr);
+	priv->hw->dma->stop_tx(priv->dev->base_addr);
 	dma_free_tx_skbufs(priv);
 	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
-	stmmac_dma_start_tx(priv->dev->base_addr);
+	priv->hw->dma->start_tx(priv->dev->base_addr);
 
 	priv->dev->stats.tx_errors++;
 	netif_wake_queue(priv->dev);
@@ -893,95 +767,27 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	return;
 }
 
-/**
- * stmmac_dma_interrupt - Interrupt handler for the driver
- * @dev: net device structure
- * Description: Interrupt handler for the driver (DMA).
- */
-static void stmmac_dma_interrupt(struct net_device *dev)
-{
-	unsigned long ioaddr = dev->base_addr;
-	struct stmmac_priv *priv = netdev_priv(dev);
-	/* read the status register (CSR5) */
-	u32 intr_status = readl(ioaddr + DMA_STATUS);
-
-	DBG(intr, INFO, "%s: [CSR5: 0x%08x]\n", __func__, intr_status);
 
-#ifdef STMMAC_DEBUG
-	/* It displays the DMA transmit process state (CSR5 register) */
-	if (netif_msg_tx_done(priv))
-		show_tx_process_state(intr_status);
-	if (netif_msg_rx_status(priv))
-		show_rx_process_state(intr_status);
-#endif
-	/* ABNORMAL interrupts */
-	if (unlikely(intr_status & DMA_STATUS_AIS)) {
-		DBG(intr, INFO, "CSR5[15] DMA ABNORMAL IRQ: ");
-		if (unlikely(intr_status & DMA_STATUS_UNF)) {
-			DBG(intr, INFO, "transmit underflow\n");
-			if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
-				/* Try to bump up the threshold */
-				tc += 64;
-				priv->hw->dma->dma_mode(ioaddr, tc,
-							SF_DMA_MODE);
-				priv->xstats.threshold = tc;
-			}
-			stmmac_tx_err(priv);
-			priv->xstats.tx_undeflow_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_TJT)) {
-			DBG(intr, INFO, "transmit jabber\n");
-			priv->xstats.tx_jabber_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_OVF)) {
-			DBG(intr, INFO, "recv overflow\n");
-			priv->xstats.rx_overflow_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_RU)) {
-			DBG(intr, INFO, "receive buffer unavailable\n");
-			priv->xstats.rx_buf_unav_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_RPS)) {
-			DBG(intr, INFO, "receive process stopped\n");
-			priv->xstats.rx_process_stopped_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_RWT)) {
-			DBG(intr, INFO, "receive watchdog\n");
-			priv->xstats.rx_watchdog_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_ETI)) {
-			DBG(intr, INFO, "transmit early interrupt\n");
-			priv->xstats.tx_early_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_TPS)) {
-			DBG(intr, INFO, "transmit process stopped\n");
-			priv->xstats.tx_process_stopped_irq++;
-			stmmac_tx_err(priv);
-		}
-		if (unlikely(intr_status & DMA_STATUS_FBI)) {
-			DBG(intr, INFO, "fatal bus error\n");
-			priv->xstats.fatal_bus_error_irq++;
-			stmmac_tx_err(priv);
+static void stmmac_dma_interrupt(struct stmmac_priv *priv)
+{
+	unsigned long ioaddr = priv->dev->base_addr;
+	int status;
+
+	status = priv->hw->dma->dma_interrupt(priv->dev->base_addr,
+					      &priv->xstats);
+	if (likely(status == handle_tx_rx))
+		_stmmac_schedule(priv);
+
+	else if (unlikely(status == tx_hard_error_bump_tc)) {
+		/* Try to bump up the dma threshold on this failure */
+		if (unlikely(tc != SF_DMA_MODE) && (tc <= 256)) {
+			tc += 64;
+			priv->hw->dma->dma_mode(ioaddr, tc, SF_DMA_MODE);
+			priv->xstats.threshold = tc;
 		}
-	}
-
-	/* TX/RX NORMAL interrupts */
-	if (intr_status & DMA_STATUS_NIS) {
-		priv->xstats.normal_irq_n++;
-		if (likely((intr_status & DMA_STATUS_RI) ||
-			 (intr_status & (DMA_STATUS_TI))))
-				_stmmac_schedule(priv);
-	}
-
-	/* Optional hardware blocks, interrupts should be disabled */
-	if (unlikely(intr_status &
-		     (DMA_STATUS_GPI | DMA_STATUS_GMI | DMA_STATUS_GLI)))
-		pr_info("%s: unexpected status %08x\n", __func__, intr_status);
-
-	/* Clear the interrupt by writing a logic 1 to the CSR5[15-0] */
-	writel((intr_status & 0x1ffff), ioaddr + DMA_STATUS);
-
-	DBG(intr, INFO, "\n\n");
+		stmmac_tx_err(priv);
+	} else if (unlikely(status == tx_hard_error))
+		stmmac_tx_err(priv);
 
 	return;
 }
@@ -1089,8 +895,8 @@ static int stmmac_open(struct net_device *dev)
 
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
-	stmmac_dma_start_tx(ioaddr);
-	stmmac_dma_start_rx(ioaddr);
+	priv->hw->dma->start_tx(ioaddr);
+	priv->hw->dma->start_rx(ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
@@ -1142,8 +948,8 @@ static int stmmac_release(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
-	stmmac_dma_stop_tx(dev->base_addr);
-	stmmac_dma_stop_rx(dev->base_addr);
+	priv->hw->dma->stop_tx(dev->base_addr);
+	priv->hw->dma->stop_rx(dev->base_addr);
 
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
@@ -1227,7 +1033,6 @@ static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 		priv->hw->desc->prepare_tx_desc(desc, 0, buf2_size,
 						csum_insertion);
 		priv->hw->desc->set_tx_owner(desc);
-
 		priv->tx_skbuff[entry] = NULL;
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
@@ -1353,8 +1158,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->stats.tx_bytes += skb->len;
 
-	/* CSR1 enables the transmit DMA to check for new descriptor */
-	writel(1, dev->base_addr + DMA_XMT_POLL_DEMAND);
+	priv->hw->dma->enable_dma_transmission(dev->base_addr);
 
 	return NETDEV_TX_OK;
 }
@@ -1624,7 +1428,8 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 		/* To handle GMAC own interrupts */
 		priv->hw->mac->host_irq_status(ioaddr);
 	}
-	stmmac_dma_interrupt(dev);
+
+	stmmac_dma_interrupt(priv);
 
 	return IRQ_HANDLED;
 }
@@ -1988,12 +1793,13 @@ out:
 static int stmmac_dvr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct resource *res;
 
 	pr_info("%s:\n\tremoving driver", __func__);
 
-	stmmac_dma_stop_rx(ndev->base_addr);
-	stmmac_dma_stop_tx(ndev->base_addr);
+	priv->hw->dma->stop_rx(ndev->base_addr);
+	priv->hw->dma->stop_tx(ndev->base_addr);
 
 	stmmac_mac_disable_rx(ndev->base_addr);
 	stmmac_mac_disable_tx(ndev->base_addr);
@@ -2040,8 +1846,8 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 		napi_disable(&priv->napi);
 
 		/* Stop TX/RX DMA */
-		stmmac_dma_stop_tx(dev->base_addr);
-		stmmac_dma_stop_rx(dev->base_addr);
+		priv->hw->dma->stop_tx(dev->base_addr);
+		priv->hw->dma->stop_rx(dev->base_addr);
 		/* Clear the Rx/Tx descriptors */
 		priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
 					     dis_ic);
@@ -2101,8 +1907,8 @@ static int stmmac_resume(struct platform_device *pdev)
 	/* Enable the MAC and DMA */
 	stmmac_mac_enable_rx(ioaddr);
 	stmmac_mac_enable_tx(ioaddr);
-	stmmac_dma_start_tx(ioaddr);
-	stmmac_dma_start_rx(ioaddr);
+	priv->hw->dma->start_tx(ioaddr);
+	priv->hw->dma->start_rx(ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
-- 
1.6.0.4

