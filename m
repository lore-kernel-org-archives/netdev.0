From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/4] stmmac: thinking about a generic driver for Synopsys Controllers.
Date: Thu,  3 Dec 2009 11:40:02 +0100
Message-ID: <1259836805-7512-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:60106 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755926AbZLCKkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:40:18 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id EC2F3233
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 10:40:16 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3C9B9A6D
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 10:40:16 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea behind this patch is to start thinking about a
generic driver for Synopsys Ethernet Controllers
starting from the stmmac device driver.
In the future, the stmmac could be also renamed as "synmac";
I'd like to see it working on other systems with other CPUs
(ARM, SH) and other Synopsys Ethernet IPs.

This patch moves specific dma parts, HW initialisations,
platform setup etc. from the main source to other files
splitting more and more common parts, dma engine and supports.
Its goal is to make easier future developments to extend
the driver.

This driver's structure is:
o Kconfig
o Makefile
o stmmac_main.c
o stmmac_mdio.c
o stmmac_ethtool.c
o stmmac_timer.[ch]
  Timer code used for mitigating the driver dma interrupts.
  New chips have an embedded watchdog that is not supported
  in this implementation. On SH an external timer has been used
  for this job. In particular it's possible to use either the TMU
  (channel 2) or the RTC;
o stmmac.h: private driver structure;
o common.h: common definitions and VFTs;
o descs.h: descriptor structures. Note that the GMAC uses the enhanced
  structure;
o dwmac1000_core.c: GMAC core funtions;
o dwmac1000_dma.c:  DMAC dma funtions;
  Voluntarily this has been moved out from the core because it seems
  that on some platforms somebody could use another dma engine.
  So this could actually make easier a future work on this area;
o dwmac1000.h: specific header file for the GMAC;
o dwmac100.[ch]: MAC 100 core and dma code;
o dwmac_dma.h: common dma functions and macro for mac and gmac;
o dwmac_lib.c:
  the dma functions have been moved out from the main source
  to this file. For example the dma interrupt function.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig          |   14 +-
 drivers/net/stmmac/Makefile         |    5 +-
 drivers/net/stmmac/common.h         |  278 +++++----------
 drivers/net/stmmac/descs.h          |    4 +-
 drivers/net/stmmac/dwmac100.c       |  539 +++++++++++++++++++++++++++
 drivers/net/stmmac/dwmac100.h       |  116 ++++++
 drivers/net/stmmac/dwmac1000.h      |  220 +++++++++++
 drivers/net/stmmac/dwmac1000_core.c |  253 +++++++++++++
 drivers/net/stmmac/dwmac1000_dma.c  |  473 ++++++++++++++++++++++++
 drivers/net/stmmac/dwmac_dma.h      |  107 ++++++
 drivers/net/stmmac/dwmac_lib.c      |  263 +++++++++++++
 drivers/net/stmmac/gmac.c           |  693 -----------------------------------
 drivers/net/stmmac/gmac.h           |  204 ----------
 drivers/net/stmmac/mac100.c         |  517 --------------------------
 drivers/net/stmmac/mac100.h         |  116 ------
 drivers/net/stmmac/stmmac.h         |   28 ++-
 drivers/net/stmmac/stmmac_ethtool.c |    7 +-
 drivers/net/stmmac/stmmac_main.c    |  436 ++++++----------------
 drivers/net/stmmac/stmmac_mdio.c    |   11 +-
 19 files changed, 2231 insertions(+), 2053 deletions(-)
 create mode 100644 drivers/net/stmmac/dwmac100.c
 create mode 100644 drivers/net/stmmac/dwmac100.h
 create mode 100644 drivers/net/stmmac/dwmac1000.h
 create mode 100644 drivers/net/stmmac/dwmac1000_core.c
 create mode 100644 drivers/net/stmmac/dwmac1000_dma.c
 create mode 100644 drivers/net/stmmac/dwmac_dma.h
 create mode 100644 drivers/net/stmmac/dwmac_lib.c
 delete mode 100644 drivers/net/stmmac/gmac.c
 delete mode 100644 drivers/net/stmmac/gmac.h
 delete mode 100644 drivers/net/stmmac/mac100.c
 delete mode 100644 drivers/net/stmmac/mac100.h

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 35eaa52..5cfefde 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -2,10 +2,11 @@ config STMMAC_ETH
 	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
 	select MII
 	select PHYLIB
-	depends on NETDEVICES && CPU_SUBTYPE_ST40
+	depends on NETDEVICES && EXPERIMENTAL && CPU_SUBTYPE_ST40
 	help
-	  This is the driver for the ST MAC 10/100/1000 on-chip Ethernet
-	  controllers. ST Ethernet IPs are built around a Synopsys IP Core.
+	  This is the driver for the Ethernet IPs are built around a
+	  Synopsys IP Core and fully tested on the STMicroelectronics
+	  platforms.
 
 if STMMAC_ETH
 
@@ -19,9 +20,9 @@ config STMMAC_DA
 	  (rx:tx priority is 1:1).
 
 config STMMAC_DUAL_MAC
-	bool "STMMAC: dual mac support (EXPERIMENTAL)"
+	bool "STMMAC: dual mac support"
 	default n
-        depends on EXPERIMENTAL && STMMAC_ETH && !STMMAC_TIMER
+        depends on CPU_SH4 && STMMAC_ETH && !STMMAC_TIMER
 	help
 	  Some ST SoCs (for example the stx7141 and stx7200c2) have two
 	  Ethernet Controllers. This option turns on the second Ethernet
@@ -32,7 +33,8 @@ config STMMAC_TIMER
 	default n
 	help
 	  Use an external timer for mitigating the number of network
-	  interrupts.
+	  interrupts. Currently, for SH architectures, it is possible
+	  to use the TMU channel 2 and the SH-RTC device.
 
 choice
         prompt "Select Timer device"
diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index b2d7a55..c776af1 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
-stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o \
-		mac100.o  gmac.o $(stmmac-y)
+stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
+	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
+	      dwmac100.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index e49e518..00a9067 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -1,6 +1,4 @@
 /*******************************************************************************
-  STMMAC Common Header File
-
   Copyright (C) 2007-2009  STMicroelectronics Ltd
 
   This program is free software; you can redistribute it and/or modify it
@@ -23,133 +21,9 @@
 *******************************************************************************/
 
 #include "descs.h"
-#include <linux/io.h>
-
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
+#include <linux/netdevice.h>
 
+/* Ethtool Extra stats */
 struct stmmac_extra_stats {
 	/* Transmit errors */
 	unsigned long tx_underflow ____cacheline_aligned;
@@ -198,66 +72,62 @@ struct stmmac_extra_stats {
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
 
-struct stmmac_ops {
-	/* MAC core initialization */
-	void (*core_init) (unsigned long ioaddr) ____cacheline_aligned;
-	/* DMA core initialization */
-	int (*dma_init) (unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx);
-	/* Dump MAC registers */
-	void (*dump_mac_regs) (unsigned long ioaddr);
-	/* Dump DMA registers */
-	void (*dump_dma_regs) (unsigned long ioaddr);
-	/* Set tx/rx threshold in the csr6 register
-	 * An invalid value enables the store-and-forward mode */
-	void (*dma_mode) (unsigned long ioaddr, int txmode, int rxmode);
-	/* To track extra statistic (if supported) */
-	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
-				   unsigned long ioaddr);
-	/* RX descriptor ring initialization */
+struct stmmac_desc_ops {
+	/* DMA RX descriptor ring initialization */
 	void (*init_rx_desc) (struct dma_desc *p, unsigned int ring_size,
-				int disable_rx_ic);
-	/* TX descriptor ring initialization */
+			      int disable_rx_ic);
+	/* DMA TX descriptor ring initialization */
 	void (*init_tx_desc) (struct dma_desc *p, unsigned int ring_size);
 
 	/* Invoked by the xmit function to prepare the tx descriptor */
@@ -281,7 +151,6 @@ struct stmmac_ops {
 	/* Get the buffer size from the descriptor */
 	int (*get_tx_len) (struct dma_desc *p);
 	/* Handle extra events on specific interrupts hw dependent */
-	void (*host_irq_status) (unsigned long ioaddr);
 	int (*get_rx_owner) (struct dma_desc *p);
 	void (*set_rx_owner) (struct dma_desc *p);
 	/* Get the receive frame size */
@@ -289,6 +158,37 @@ struct stmmac_ops {
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
 			  struct dma_desc *p);
+};
+
+struct stmmac_dma_ops {
+	/* DMA core initialization */
+	int (*init) (unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx);
+	/* Dump DMA registers */
+	void (*dump_regs) (unsigned long ioaddr);
+	/* Set tx/rx threshold in the csr6 register
+	 * An invalid value enables the store-and-forward mode */
+	void (*dma_mode) (unsigned long ioaddr, int txmode, int rxmode);
+	/* To track extra statistic (if supported) */
+	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
+				   unsigned long ioaddr);
+	void (*enable_dma_transmission) (unsigned long ioaddr);
+	void (*enable_dma_irq) (unsigned long ioaddr);
+	void (*disable_dma_irq) (unsigned long ioaddr);
+	void (*start_tx) (unsigned long ioaddr);
+	void (*stop_tx) (unsigned long ioaddr);
+	void (*start_rx) (unsigned long ioaddr);
+	void (*stop_rx) (unsigned long ioaddr);
+	int (*dma_interrupt) (unsigned long ioaddr,
+			      struct stmmac_extra_stats *x);
+};
+
+struct stmmac_ops {
+	/* MAC core initialization */
+	void (*core_init) (unsigned long ioaddr) ____cacheline_aligned;
+	/* Dump MAC registers */
+	void (*dump_regs) (unsigned long ioaddr);
+	/* Handle extra events on specific interrupts hw dependent */
+	void (*host_irq_status) (unsigned long ioaddr);
 	/* Multicast filter setting */
 	void (*set_filter) (struct net_device *dev);
 	/* Flow control setting */
@@ -298,9 +198,9 @@ struct stmmac_ops {
 	void (*pmt) (unsigned long ioaddr, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
 	void (*set_umac_addr) (unsigned long ioaddr, unsigned char *addr,
-			     unsigned int reg_n);
+			       unsigned int reg_n);
 	void (*get_umac_addr) (unsigned long ioaddr, unsigned char *addr,
-			     unsigned int reg_n);
+			       unsigned int reg_n);
 };
 
 struct mac_link {
@@ -314,17 +214,19 @@ struct mii_regs {
 	unsigned int data;	/* MII Data */
 };
 
-struct hw_cap {
-	unsigned int version;	/* Core Version register (GMAC) */
-	unsigned int pmt;	/* Power-Down mode (GMAC) */
-	struct mac_link link;
-	struct mii_regs mii;
-};
-
 struct mac_device_info {
-	struct hw_cap hw;
-	struct stmmac_ops *ops;
+	struct stmmac_ops	*mac;
+	struct stmmac_desc_ops	*desc;
+	struct stmmac_dma_ops	*dma;
+	unsigned int pmt;	/* support Power-Down */
+	struct mii_regs mii;	/* MII register Addresses */
+	struct mac_link link;
 };
 
 struct mac_device_info *gmac_setup(unsigned long addr);
 struct mac_device_info *mac100_setup(unsigned long addr);
+
+extern void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
+				unsigned int high, unsigned int low);
+extern void stmmac_get_mac_addr(unsigned long ioaddr, unsigned char *addr,
+				unsigned int high, unsigned int low);
diff --git a/drivers/net/stmmac/descs.h b/drivers/net/stmmac/descs.h
index 6d2a0b2..63a03e2 100644
--- a/drivers/net/stmmac/descs.h
+++ b/drivers/net/stmmac/descs.h
@@ -1,6 +1,6 @@
 /*******************************************************************************
-  Header File to describe the DMA descriptors
-  Use enhanced descriptors in case of GMAC Cores.
+  Header File to describe the DMA descriptors.
+  Enhanced descriptors have been in case of DWMAC1000 Cores.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
new file mode 100644
index 0000000..540b9ce
--- /dev/null
+++ b/drivers/net/stmmac/dwmac100.c
@@ -0,0 +1,539 @@
+/*******************************************************************************
+  This is the driver for the MAC 10/100 on-chip Ethernet controller
+  currently tested on all the ST boards based on STb7109 and stx7200 SoCs.
+
+  DWC Ether MAC 10/100 Universal version 4.0 has been used for developing
+  this code.
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
+#include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#include "common.h"
+#include "dwmac100.h"
+#include "dwmac_dma.h"
+
+#undef MAC100_DEBUG
+/*#define MAC100_DEBUG*/
+#ifdef MAC100_DEBUG
+#define DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define DBG(fmt, args...)  do { } while (0)
+#endif
+
+static void mac100_core_init(unsigned long ioaddr)
+{
+	u32 value = readl(ioaddr + MAC_CONTROL);
+
+	writel((value | MAC_CORE_INIT), ioaddr + MAC_CONTROL);
+
+#ifdef STMMAC_VLAN_TAG_USED
+	writel(ETH_P_8021Q, ioaddr + MAC_VLAN1);
+#endif
+	return;
+}
+
+static void mac100_dump_mac_regs(unsigned long ioaddr)
+{
+	pr_info("\t----------------------------------------------\n"
+		"\t  MAC100 CSR (base addr = 0x%8x)\n"
+		"\t----------------------------------------------\n",
+		(unsigned int)ioaddr);
+	pr_info("\tcontrol reg (offset 0x%x): 0x%08x\n", MAC_CONTROL,
+		readl(ioaddr + MAC_CONTROL));
+	pr_info("\taddr HI (offset 0x%x): 0x%08x\n ", MAC_ADDR_HIGH,
+		readl(ioaddr + MAC_ADDR_HIGH));
+	pr_info("\taddr LO (offset 0x%x): 0x%08x\n", MAC_ADDR_LOW,
+		readl(ioaddr + MAC_ADDR_LOW));
+	pr_info("\tmulticast hash HI (offset 0x%x): 0x%08x\n",
+		MAC_HASH_HIGH, readl(ioaddr + MAC_HASH_HIGH));
+	pr_info("\tmulticast hash LO (offset 0x%x): 0x%08x\n",
+		MAC_HASH_LOW, readl(ioaddr + MAC_HASH_LOW));
+	pr_info("\tflow control (offset 0x%x): 0x%08x\n",
+		MAC_FLOW_CTRL, readl(ioaddr + MAC_FLOW_CTRL));
+	pr_info("\tVLAN1 tag (offset 0x%x): 0x%08x\n", MAC_VLAN1,
+		readl(ioaddr + MAC_VLAN1));
+	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
+		readl(ioaddr + MAC_VLAN2));
+	pr_info("\n\tMAC management counter registers\n");
+	pr_info("\t MMC crtl (offset 0x%x): 0x%08x\n",
+		MMC_CONTROL, readl(ioaddr + MMC_CONTROL));
+	pr_info("\t MMC High Interrupt (offset 0x%x): 0x%08x\n",
+		MMC_HIGH_INTR, readl(ioaddr + MMC_HIGH_INTR));
+	pr_info("\t MMC Low Interrupt (offset 0x%x): 0x%08x\n",
+		MMC_LOW_INTR, readl(ioaddr + MMC_LOW_INTR));
+	pr_info("\t MMC High Interrupt Mask (offset 0x%x): 0x%08x\n",
+		MMC_HIGH_INTR_MASK, readl(ioaddr + MMC_HIGH_INTR_MASK));
+	pr_info("\t MMC Low Interrupt Mask (offset 0x%x): 0x%08x\n",
+		MMC_LOW_INTR_MASK, readl(ioaddr + MMC_LOW_INTR_MASK));
+	return;
+}
+
+static int mac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
+			   u32 dma_rx)
+{
+	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	/* DMA SW reset */
+	value |= DMA_BUS_MODE_SFT_RESET;
+	writel(value, ioaddr + DMA_BUS_MODE);
+	do {} while ((readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET));
+
+	/* Enable Application Access by writing to DMA CSR0 */
+	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
+	       ioaddr + DMA_BUS_MODE);
+
+	/* Mask interrupts by writing to CSR7 */
+	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
+
+	/* The base address of the RX/TX descriptor lists must be written into
+	 * DMA CSR3 and CSR4, respectively. */
+	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
+	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
+
+	return 0;
+}
+
+/* Store and Forward capability is not used at all..
+ * The transmit threshold can be programmed by
+ * setting the TTC bits in the DMA control register.*/
+static void mac100_dma_operation_mode(unsigned long ioaddr, int txmode,
+				      int rxmode)
+{
+	u32 csr6 = readl(ioaddr + DMA_CONTROL);
+
+	if (txmode <= 32)
+		csr6 |= DMA_CONTROL_TTC_32;
+	else if (txmode <= 64)
+		csr6 |= DMA_CONTROL_TTC_64;
+	else
+		csr6 |= DMA_CONTROL_TTC_128;
+
+	writel(csr6, ioaddr + DMA_CONTROL);
+
+	return;
+}
+
+static void mac100_dump_dma_regs(unsigned long ioaddr)
+{
+	int i;
+
+	DBG(KERN_DEBUG "MAC100 DMA CSR \n");
+	for (i = 0; i < 9; i++)
+		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
+		       (DMA_BUS_MODE + i * 4),
+		       readl(ioaddr + DMA_BUS_MODE + i * 4));
+	DBG(KERN_DEBUG "\t CSR20 (offset 0x%x): 0x%08x\n",
+	    DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
+	DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
+	    DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
+	return;
+}
+
+/* DMA controller has two counters to track the number of
+ * the receive missed frames. */
+static void mac100_dma_diagnostic_fr(void *data,
+				     struct stmmac_extra_stats *x,
+				     unsigned long ioaddr)
+{
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+	u32 csr8 = readl(ioaddr + DMA_MISSED_FRAME_CTR);
+
+	if (unlikely(csr8)) {
+		if (csr8 & DMA_MISSED_FRAME_OVE) {
+			stats->rx_over_errors += 0x800;
+			x->rx_overflow_cntr += 0x800;
+		} else {
+			unsigned int ove_cntr;
+			ove_cntr = ((csr8 & DMA_MISSED_FRAME_OVE_CNTR) >> 17);
+			stats->rx_over_errors += ove_cntr;
+			x->rx_overflow_cntr += ove_cntr;
+		}
+
+		if (csr8 & DMA_MISSED_FRAME_OVE_M) {
+			stats->rx_missed_errors += 0xffff;
+			x->rx_missed_cntr += 0xffff;
+		} else {
+			unsigned int miss_f = (csr8 & DMA_MISSED_FRAME_M_CNTR);
+			stats->rx_missed_errors += miss_f;
+			x->rx_missed_cntr += miss_f;
+		}
+	}
+	return;
+}
+
+static int mac100_get_tx_frame_status(void *data,
+				      struct stmmac_extra_stats *x,
+				      struct dma_desc *p, unsigned long ioaddr)
+{
+	int ret = 0;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.tx.error_summary)) {
+		if (unlikely(p->des01.tx.underflow_error)) {
+			x->tx_underflow++;
+			stats->tx_fifo_errors++;
+		}
+		if (unlikely(p->des01.tx.no_carrier)) {
+			x->tx_carrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely(p->des01.tx.loss_carrier)) {
+			x->tx_losscarrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely((p->des01.tx.excessive_deferral) ||
+			     (p->des01.tx.excessive_collisions) ||
+			     (p->des01.tx.late_collision)))
+			stats->collisions += p->des01.tx.collision_count;
+		ret = -1;
+	}
+	if (unlikely(p->des01.tx.heartbeat_fail)) {
+		x->tx_heartbeat++;
+		stats->tx_heartbeat_errors++;
+		ret = -1;
+	}
+	if (unlikely(p->des01.tx.deferred))
+		x->tx_deferred++;
+
+	return ret;
+}
+
+static int mac100_get_tx_len(struct dma_desc *p)
+{
+	return p->des01.tx.buffer1_size;
+}
+
+/* This function verifies if each incoming frame has some errors
+ * and, if required, updates the multicast statistics.
+ * In case of success, it returns csum_none becasue the device
+ * is not able to compute the csum in HW. */
+static int mac100_get_rx_frame_status(void *data,
+				      struct stmmac_extra_stats *x,
+				      struct dma_desc *p)
+{
+	int ret = csum_none;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.rx.last_descriptor == 0)) {
+		pr_warning("mac100 Error: Oversized Ethernet "
+			   "frame spanned multiple buffers\n");
+		stats->rx_length_errors++;
+		return discard_frame;
+	}
+
+	if (unlikely(p->des01.rx.error_summary)) {
+		if (unlikely(p->des01.rx.descriptor_error))
+			x->rx_desc++;
+		if (unlikely(p->des01.rx.partial_frame_error))
+			x->rx_partial++;
+		if (unlikely(p->des01.rx.run_frame))
+			x->rx_runt++;
+		if (unlikely(p->des01.rx.frame_too_long))
+			x->rx_toolong++;
+		if (unlikely(p->des01.rx.collision)) {
+			x->rx_collision++;
+			stats->collisions++;
+		}
+		if (unlikely(p->des01.rx.crc_error)) {
+			x->rx_crc++;
+			stats->rx_crc_errors++;
+		}
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.rx.dribbling))
+		ret = discard_frame;
+
+	if (unlikely(p->des01.rx.length_error)) {
+		x->rx_lenght++;
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.rx.mii_error)) {
+		x->rx_mii++;
+		ret = discard_frame;
+	}
+	if (p->des01.rx.multicast_frame) {
+		x->rx_multicast++;
+		stats->multicast++;
+	}
+	return ret;
+}
+
+static void mac100_irq_status(unsigned long ioaddr)
+{
+	return;
+}
+
+static void mac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+			  unsigned int reg_n)
+{
+	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
+}
+
+static void mac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+			  unsigned int reg_n)
+{
+	stmmac_get_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
+}
+
+static void mac100_set_filter(struct net_device *dev)
+{
+	unsigned long ioaddr = dev->base_addr;
+	u32 value = readl(ioaddr + MAC_CONTROL);
+
+	if (dev->flags & IFF_PROMISC) {
+		value |= MAC_CONTROL_PR;
+		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_IF | MAC_CONTROL_HO |
+			   MAC_CONTROL_HP);
+	} else if ((dev->mc_count > HASH_TABLE_SIZE)
+		   || (dev->flags & IFF_ALLMULTI)) {
+		value |= MAC_CONTROL_PM;
+		value &= ~(MAC_CONTROL_PR | MAC_CONTROL_IF | MAC_CONTROL_HO);
+		writel(0xffffffff, ioaddr + MAC_HASH_HIGH);
+		writel(0xffffffff, ioaddr + MAC_HASH_LOW);
+	} else if (dev->mc_count == 0) {	/* no multicast */
+		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF |
+			   MAC_CONTROL_HO | MAC_CONTROL_HP);
+	} else {
+		int i;
+		u32 mc_filter[2];
+		struct dev_mc_list *mclist;
+
+		/* Perfect filter mode for physical address and Hash
+		   filter for multicast */
+		value |= MAC_CONTROL_HP;
+		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR |
+			   MAC_CONTROL_IF | MAC_CONTROL_HO);
+
+		memset(mc_filter, 0, sizeof(mc_filter));
+		for (i = 0, mclist = dev->mc_list;
+		     mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+			/* The upper 6 bits of the calculated CRC are used to
+			 * index the contens of the hash table */
+			int bit_nr =
+			    ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
+			/* The most significant bit determines the register to
+			 * use (H/L) while the other 5 bits determine the bit
+			 * within the register. */
+			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+		}
+		writel(mc_filter[0], ioaddr + MAC_HASH_LOW);
+		writel(mc_filter[1], ioaddr + MAC_HASH_HIGH);
+	}
+
+	writel(value, ioaddr + MAC_CONTROL);
+
+	DBG(KERN_INFO "%s: CTRL reg: 0x%08x Hash regs: "
+	    "HI 0x%08x, LO 0x%08x\n",
+	    __func__, readl(ioaddr + MAC_CONTROL),
+	    readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
+	return;
+}
+
+static void mac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
+			     unsigned int fc, unsigned int pause_time)
+{
+	unsigned int flow = MAC_FLOW_CTRL_ENABLE;
+
+	if (duplex)
+		flow |= (pause_time << MAC_FLOW_CTRL_PT_SHIFT);
+	writel(flow, ioaddr + MAC_FLOW_CTRL);
+
+	return;
+}
+
+/* No PMT module supported for this Ethernet Controller.
+ * Tested on ST platforms only.
+ */
+static void mac100_pmt(unsigned long ioaddr, unsigned long mode)
+{
+	return;
+}
+
+static void mac100_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				int disable_rx_ic)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.rx.own = 1;
+		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
+		if (i == ring_size - 1)
+			p->des01.rx.end_ring = 1;
+		if (disable_rx_ic)
+			p->des01.rx.disable_ic = 1;
+		p++;
+	}
+	return;
+}
+
+static void mac100_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.tx.own = 0;
+		if (i == ring_size - 1)
+			p->des01.tx.end_ring = 1;
+		p++;
+	}
+	return;
+}
+
+static int mac100_get_tx_owner(struct dma_desc *p)
+{
+	return p->des01.tx.own;
+}
+
+static int mac100_get_rx_owner(struct dma_desc *p)
+{
+	return p->des01.rx.own;
+}
+
+static void mac100_set_tx_owner(struct dma_desc *p)
+{
+	p->des01.tx.own = 1;
+}
+
+static void mac100_set_rx_owner(struct dma_desc *p)
+{
+	p->des01.rx.own = 1;
+}
+
+static int mac100_get_tx_ls(struct dma_desc *p)
+{
+	return p->des01.tx.last_segment;
+}
+
+static void mac100_release_tx_desc(struct dma_desc *p)
+{
+	int ter = p->des01.tx.end_ring;
+
+	/* clean field used within the xmit */
+	p->des01.tx.first_segment = 0;
+	p->des01.tx.last_segment = 0;
+	p->des01.tx.buffer1_size = 0;
+
+	/* clean status reported */
+	p->des01.tx.error_summary = 0;
+	p->des01.tx.underflow_error = 0;
+	p->des01.tx.no_carrier = 0;
+	p->des01.tx.loss_carrier = 0;
+	p->des01.tx.excessive_deferral = 0;
+	p->des01.tx.excessive_collisions = 0;
+	p->des01.tx.late_collision = 0;
+	p->des01.tx.heartbeat_fail = 0;
+	p->des01.tx.deferred = 0;
+
+	/* set termination field */
+	p->des01.tx.end_ring = ter;
+
+	return;
+}
+
+static void mac100_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				   int csum_flag)
+{
+	p->des01.tx.first_segment = is_fs;
+	p->des01.tx.buffer1_size = len;
+}
+
+static void mac100_clear_tx_ic(struct dma_desc *p)
+{
+	p->des01.tx.interrupt = 0;
+}
+
+static void mac100_close_tx_desc(struct dma_desc *p)
+{
+	p->des01.tx.last_segment = 1;
+	p->des01.tx.interrupt = 1;
+}
+
+static int mac100_get_rx_frame_len(struct dma_desc *p)
+{
+	return p->des01.rx.frame_length;
+}
+
+struct stmmac_ops mac100_ops = {
+	.core_init = mac100_core_init,
+	.dump_regs = mac100_dump_mac_regs,
+	.host_irq_status = mac100_irq_status,
+	.set_filter = mac100_set_filter,
+	.flow_ctrl = mac100_flow_ctrl,
+	.pmt = mac100_pmt,
+	.set_umac_addr = mac100_set_umac_addr,
+	.get_umac_addr = mac100_get_umac_addr,
+};
+
+struct stmmac_dma_ops mac100_dma_ops = {
+	.init = mac100_dma_init,
+	.dump_regs = mac100_dump_dma_regs,
+	.dma_mode = mac100_dma_operation_mode,
+	.dma_diagnostic_fr = mac100_dma_diagnostic_fr,
+	.enable_dma_transmission = dwmac_enable_dma_transmission,
+	.enable_dma_irq = dwmac_enable_dma_irq,
+	.disable_dma_irq = dwmac_disable_dma_irq,
+	.start_tx = dwmac_dma_start_tx,
+	.stop_tx = dwmac_dma_stop_tx,
+	.start_rx = dwmac_dma_start_rx,
+	.stop_rx = dwmac_dma_stop_rx,
+	.dma_interrupt = dwmac_dma_interrupt,
+};
+
+struct stmmac_desc_ops mac100_desc_ops = {
+	.tx_status = mac100_get_tx_frame_status,
+	.rx_status = mac100_get_rx_frame_status,
+	.get_tx_len = mac100_get_tx_len,
+	.init_rx_desc = mac100_init_rx_desc,
+	.init_tx_desc = mac100_init_tx_desc,
+	.get_tx_owner = mac100_get_tx_owner,
+	.get_rx_owner = mac100_get_rx_owner,
+	.release_tx_desc = mac100_release_tx_desc,
+	.prepare_tx_desc = mac100_prepare_tx_desc,
+	.clear_tx_ic = mac100_clear_tx_ic,
+	.close_tx_desc = mac100_close_tx_desc,
+	.get_tx_ls = mac100_get_tx_ls,
+	.set_tx_owner = mac100_set_tx_owner,
+	.set_rx_owner = mac100_set_rx_owner,
+	.get_rx_frame_len = mac100_get_rx_frame_len,
+};
+
+struct mac_device_info *mac100_setup(unsigned long ioaddr)
+{
+	struct mac_device_info *mac;
+
+	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+
+	pr_info("\tDWMAC100\n");
+
+	mac->mac = &mac100_ops;
+	mac->desc = &mac100_desc_ops;
+	mac->dma = &mac100_dma_ops;
+
+	mac->pmt = PMT_NOT_SUPPORTED;
+	mac->link.port = MAC_CONTROL_PS;
+	mac->link.duplex = MAC_CONTROL_F;
+	mac->link.speed = 0;
+	mac->mii.addr = MAC_MII_ADDR;
+	mac->mii.data = MAC_MII_DATA;
+
+	return mac;
+}
diff --git a/drivers/net/stmmac/dwmac100.h b/drivers/net/stmmac/dwmac100.h
new file mode 100644
index 0000000..0f8f110
--- /dev/null
+++ b/drivers/net/stmmac/dwmac100.h
@@ -0,0 +1,116 @@
+/*******************************************************************************
+  MAC 10/100 Header File
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
+/*----------------------------------------------------------------------------
+ *	 			MAC BLOCK defines
+ *---------------------------------------------------------------------------*/
+/* MAC CSR offset */
+#define MAC_CONTROL	0x00000000	/* MAC Control */
+#define MAC_ADDR_HIGH	0x00000004	/* MAC Address High */
+#define MAC_ADDR_LOW	0x00000008	/* MAC Address Low */
+#define MAC_HASH_HIGH	0x0000000c	/* Multicast Hash Table High */
+#define MAC_HASH_LOW	0x00000010	/* Multicast Hash Table Low */
+#define MAC_MII_ADDR	0x00000014	/* MII Address */
+#define MAC_MII_DATA	0x00000018	/* MII Data */
+#define MAC_FLOW_CTRL	0x0000001c	/* Flow Control */
+#define MAC_VLAN1	0x00000020	/* VLAN1 Tag */
+#define MAC_VLAN2	0x00000024	/* VLAN2 Tag */
+
+/* MAC CTRL defines */
+#define MAC_CONTROL_RA	0x80000000	/* Receive All Mode */
+#define MAC_CONTROL_BLE	0x40000000	/* Endian Mode */
+#define MAC_CONTROL_HBD	0x10000000	/* Heartbeat Disable */
+#define MAC_CONTROL_PS	0x08000000	/* Port Select */
+#define MAC_CONTROL_DRO	0x00800000	/* Disable Receive Own */
+#define MAC_CONTROL_EXT_LOOPBACK 0x00400000	/* Reserved (ext loopback?) */
+#define MAC_CONTROL_OM	0x00200000	/* Loopback Operating Mode */
+#define MAC_CONTROL_F	0x00100000	/* Full Duplex Mode */
+#define MAC_CONTROL_PM	0x00080000	/* Pass All Multicast */
+#define MAC_CONTROL_PR	0x00040000	/* Promiscuous Mode */
+#define MAC_CONTROL_IF	0x00020000	/* Inverse Filtering */
+#define MAC_CONTROL_PB	0x00010000	/* Pass Bad Frames */
+#define MAC_CONTROL_HO	0x00008000	/* Hash Only Filtering Mode */
+#define MAC_CONTROL_HP	0x00002000	/* Hash/Perfect Filtering Mode */
+#define MAC_CONTROL_LCC	0x00001000	/* Late Collision Control */
+#define MAC_CONTROL_DBF	0x00000800	/* Disable Broadcast Frames */
+#define MAC_CONTROL_DRTY	0x00000400	/* Disable Retry */
+#define MAC_CONTROL_ASTP	0x00000100	/* Automatic Pad Stripping */
+#define MAC_CONTROL_BOLMT_10	0x00000000	/* Back Off Limit 10 */
+#define MAC_CONTROL_BOLMT_8	0x00000040	/* Back Off Limit 8 */
+#define MAC_CONTROL_BOLMT_4	0x00000080	/* Back Off Limit 4 */
+#define MAC_CONTROL_BOLMT_1	0x000000c0	/* Back Off Limit 1 */
+#define MAC_CONTROL_DC		0x00000020	/* Deferral Check */
+#define MAC_CONTROL_TE		0x00000008	/* Transmitter Enable */
+#define MAC_CONTROL_RE		0x00000004	/* Receiver Enable */
+
+#define MAC_CORE_INIT (MAC_CONTROL_HBD | MAC_CONTROL_ASTP)
+
+/* MAC FLOW CTRL defines */
+#define MAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
+#define MAC_FLOW_CTRL_PT_SHIFT	16
+#define MAC_FLOW_CTRL_PASS	0x00000004	/* Pass Control Frames */
+#define MAC_FLOW_CTRL_ENABLE	0x00000002	/* Flow Control Enable */
+#define MAC_FLOW_CTRL_PAUSE	0x00000001	/* Flow Control Busy ... */
+
+/* MII ADDR  defines */
+#define MAC_MII_ADDR_WRITE	0x00000002	/* MII Write */
+#define MAC_MII_ADDR_BUSY	0x00000001	/* MII Busy */
+
+/*----------------------------------------------------------------------------
+ * 				DMA BLOCK defines
+ *---------------------------------------------------------------------------*/
+
+/* DMA Bus Mode register defines */
+#define DMA_BUS_MODE_DBO	0x00100000	/* Descriptor Byte Ordering */
+#define DMA_BUS_MODE_BLE	0x00000080	/* Big Endian/Little Endian */
+#define DMA_BUS_MODE_PBL_MASK	0x00003f00	/* Programmable Burst Len */
+#define DMA_BUS_MODE_PBL_SHIFT	8
+#define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
+#define DMA_BUS_MODE_DSL_SHIFT	2	/*   (in DWORDS)      */
+#define DMA_BUS_MODE_BAR_BUS	0x00000002	/* Bar-Bus Arbitration */
+#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
+#define DMA_BUS_MODE_DEFAULT	0x00000000
+
+/* DMA Control register defines */
+#define DMA_CONTROL_SF		0x00200000	/* Store And Forward */
+
+/* Transmit Threshold Control */
+enum ttc_control {
+	DMA_CONTROL_TTC_DEFAULT = 0x00000000,	/* Threshold is 32 DWORDS */
+	DMA_CONTROL_TTC_64 = 0x00004000,	/* Threshold is 64 DWORDS */
+	DMA_CONTROL_TTC_128 = 0x00008000,	/* Threshold is 128 DWORDS */
+	DMA_CONTROL_TTC_256 = 0x0000c000,	/* Threshold is 256 DWORDS */
+	DMA_CONTROL_TTC_18 = 0x00400000,	/* Threshold is 18 DWORDS */
+	DMA_CONTROL_TTC_24 = 0x00404000,	/* Threshold is 24 DWORDS */
+	DMA_CONTROL_TTC_32 = 0x00408000,	/* Threshold is 32 DWORDS */
+	DMA_CONTROL_TTC_40 = 0x0040c000,	/* Threshold is 40 DWORDS */
+	DMA_CONTROL_SE = 0x00000008,	/* Stop On Empty */
+	DMA_CONTROL_OSF = 0x00000004,	/* Operate On 2nd Frame */
+};
+
+/* STMAC110 DMA Missed Frame Counter register defines */
+#define DMA_MISSED_FRAME_OVE	0x10000000	/* FIFO Overflow Overflow */
+#define DMA_MISSED_FRAME_OVE_CNTR 0x0ffe0000	/* Overflow Frame Counter */
+#define DMA_MISSED_FRAME_OVE_M	0x00010000	/* Missed Frame Overflow */
+#define DMA_MISSED_FRAME_M_CNTR	0x0000ffff	/* Missed Frame Couinter */
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
new file mode 100644
index 0000000..e747012
--- /dev/null
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -0,0 +1,220 @@
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
+#include <linux/phy.h>
+#include "common.h"
+
+#define GMAC_CONTROL		0x00000000	/* Configuration */
+#define GMAC_FRAME_FILTER	0x00000004	/* Frame Filter */
+#define GMAC_HASH_HIGH		0x00000008	/* Multicast Hash Table High */
+#define GMAC_HASH_LOW		0x0000000c	/* Multicast Hash Table Low */
+#define GMAC_MII_ADDR		0x00000010	/* MII Address */
+#define GMAC_MII_DATA		0x00000014	/* MII Data */
+#define GMAC_FLOW_CTRL		0x00000018	/* Flow Control */
+#define GMAC_VLAN_TAG		0x0000001c	/* VLAN Tag */
+#define GMAC_VERSION		0x00000020	/* GMAC CORE Version */
+#define GMAC_WAKEUP_FILTER	0x00000028	/* Wake-up Frame Filter */
+
+#define GMAC_INT_STATUS		0x00000038	/* interrupt status register */
+enum gmac_irq_status {
+	time_stamp_irq = 0x0200,
+	mmc_rx_csum_offload_irq = 0x0080,
+	mmc_tx_irq = 0x0040,
+	mmc_rx_irq = 0x0020,
+	mmc_irq = 0x0010,
+	pmt_irq = 0x0008,
+	pcs_ane_irq = 0x0004,
+	pcs_link_irq = 0x0002,
+	rgmii_irq = 0x0001,
+};
+#define GMAC_INT_MASK		0x0000003c	/* interrupt mask register */
+
+/* PMT Control and Status */
+#define GMAC_PMT		0x0000002c
+enum power_event {
+	pointer_reset = 0x80000000,
+	global_unicast = 0x00000200,
+	wake_up_rx_frame = 0x00000040,
+	magic_frame = 0x00000020,
+	wake_up_frame_en = 0x00000004,
+	magic_pkt_en = 0x00000002,
+	power_down = 0x00000001,
+};
+
+/* GMAC HW ADDR regs */
+#define GMAC_ADDR_HIGH(reg)		(0x00000040+(reg * 8))
+#define GMAC_ADDR_LOW(reg)		(0x00000044+(reg * 8))
+#define GMAC_MAX_UNICAST_ADDRESSES	16
+
+#define GMAC_AN_CTRL	0x000000c0	/* AN control */
+#define GMAC_AN_STATUS	0x000000c4	/* AN status */
+#define GMAC_ANE_ADV	0x000000c8	/* Auto-Neg. Advertisement */
+#define GMAC_ANE_LINK	0x000000cc	/* Auto-Neg. link partener ability */
+#define GMAC_ANE_EXP	0x000000d0	/* ANE expansion */
+#define GMAC_TBI	0x000000d4	/* TBI extend status */
+#define GMAC_GMII_STATUS 0x000000d8	/* S/R-GMII status */
+
+/* GMAC Configuration defines */
+#define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
+#define GMAC_CONTROL_WD	0x00800000	/* Disable Watchdog on receive */
+#define GMAC_CONTROL_JD	0x00400000	/* Jabber disable */
+#define GMAC_CONTROL_BE	0x00200000	/* Frame Burst Enable */
+#define GMAC_CONTROL_JE	0x00100000	/* Jumbo frame */
+enum inter_frame_gap {
+	GMAC_CONTROL_IFG_88 = 0x00040000,
+	GMAC_CONTROL_IFG_80 = 0x00020000,
+	GMAC_CONTROL_IFG_40 = 0x000e0000,
+};
+#define GMAC_CONTROL_DCRS	0x00010000 /* Disable carrier sense during tx */
+#define GMAC_CONTROL_PS		0x00008000 /* Port Select 0:GMI 1:MII */
+#define GMAC_CONTROL_FES	0x00004000 /* Speed 0:10 1:100 */
+#define GMAC_CONTROL_DO		0x00002000 /* Disable Rx Own */
+#define GMAC_CONTROL_LM		0x00001000 /* Loop-back mode */
+#define GMAC_CONTROL_DM		0x00000800 /* Duplex Mode */
+#define GMAC_CONTROL_IPC	0x00000400 /* Checksum Offload */
+#define GMAC_CONTROL_DR		0x00000200 /* Disable Retry */
+#define GMAC_CONTROL_LUD	0x00000100 /* Link up/down */
+#define GMAC_CONTROL_ACS	0x00000080 /* Automatic Pad Stripping */
+#define GMAC_CONTROL_DC		0x00000010 /* Deferral Check */
+#define GMAC_CONTROL_TE		0x00000008 /* Transmitter Enable */
+#define GMAC_CONTROL_RE		0x00000004 /* Receiver Enable */
+
+#define GMAC_CORE_INIT (GMAC_CONTROL_JD | GMAC_CONTROL_PS | GMAC_CONTROL_ACS | \
+			GMAC_CONTROL_IPC | GMAC_CONTROL_JE | GMAC_CONTROL_BE)
+
+/* GMAC Frame Filter defines */
+#define GMAC_FRAME_FILTER_PR	0x00000001	/* Promiscuous Mode */
+#define GMAC_FRAME_FILTER_HUC	0x00000002	/* Hash Unicast */
+#define GMAC_FRAME_FILTER_HMC	0x00000004	/* Hash Multicast */
+#define GMAC_FRAME_FILTER_DAIF	0x00000008	/* DA Inverse Filtering */
+#define GMAC_FRAME_FILTER_PM	0x00000010	/* Pass all multicast */
+#define GMAC_FRAME_FILTER_DBF	0x00000020	/* Disable Broadcast frames */
+#define GMAC_FRAME_FILTER_SAIF	0x00000100	/* Inverse Filtering */
+#define GMAC_FRAME_FILTER_SAF	0x00000200	/* Source Address Filter */
+#define GMAC_FRAME_FILTER_HPF	0x00000400	/* Hash or perfect Filter */
+#define GMAC_FRAME_FILTER_RA	0x80000000	/* Receive all mode */
+/* GMII ADDR  defines */
+#define GMAC_MII_ADDR_WRITE	0x00000002	/* MII Write */
+#define GMAC_MII_ADDR_BUSY	0x00000001	/* MII Busy */
+/* GMAC FLOW CTRL defines */
+#define GMAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
+#define GMAC_FLOW_CTRL_PT_SHIFT	16
+#define GMAC_FLOW_CTRL_RFE	0x00000004	/* Rx Flow Control Enable */
+#define GMAC_FLOW_CTRL_TFE	0x00000002	/* Tx Flow Control Enable */
+#define GMAC_FLOW_CTRL_FCB_BPA	0x00000001	/* Flow Control Busy ... */
+
+/*--- DMA BLOCK defines ---*/
+/* DMA Bus Mode register defines */
+#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
+#define DMA_BUS_MODE_DA		0x00000002	/* Arbitration scheme */
+#define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
+#define DMA_BUS_MODE_DSL_SHIFT	2	/*   (in DWORDS)      */
+/* Programmable burst length (passed thorugh platform)*/
+#define DMA_BUS_MODE_PBL_MASK	0x00003f00	/* Programmable Burst Len */
+#define DMA_BUS_MODE_PBL_SHIFT	8
+
+enum rx_tx_priority_ratio {
+	double_ratio = 0x00004000,	/*2:1 */
+	triple_ratio = 0x00008000,	/*3:1 */
+	quadruple_ratio = 0x0000c000,	/*4:1 */
+};
+
+#define DMA_BUS_MODE_FB		0x00010000	/* Fixed burst */
+#define DMA_BUS_MODE_RPBL_MASK	0x003e0000	/* Rx-Programmable Burst Len */
+#define DMA_BUS_MODE_RPBL_SHIFT	17
+#define DMA_BUS_MODE_USP	0x00800000
+#define DMA_BUS_MODE_4PBL	0x01000000
+#define DMA_BUS_MODE_AAL	0x02000000
+
+/* DMA CRS Control and Status Register Mapping */
+#define DMA_HOST_TX_DESC	  0x00001048	/* Current Host Tx descriptor */
+#define DMA_HOST_RX_DESC	  0x0000104c	/* Current Host Rx descriptor */
+/*  DMA Bus Mode register defines */
+#define DMA_BUS_PR_RATIO_MASK	  0x0000c000	/* Rx/Tx priority ratio */
+#define DMA_BUS_PR_RATIO_SHIFT	  14
+#define DMA_BUS_FB	  	  0x00010000	/* Fixed Burst */
+
+/* DMA operation mode defines (start/stop tx/rx are placed in common header)*/
+#define DMA_CONTROL_DT		0x04000000 /* Disable Drop TCP/IP csum error */
+#define DMA_CONTROL_RSF		0x02000000 /* Receive Store and Forward */
+#define DMA_CONTROL_DFF		0x01000000 /* Disaable flushing */
+/* Theshold for Activating the FC */
+enum rfa {
+	act_full_minus_1 = 0x00800000,
+	act_full_minus_2 = 0x00800200,
+	act_full_minus_3 = 0x00800400,
+	act_full_minus_4 = 0x00800600,
+};
+/* Theshold for Deactivating the FC */
+enum rfd {
+	deac_full_minus_1 = 0x00400000,
+	deac_full_minus_2 = 0x00400800,
+	deac_full_minus_3 = 0x00401000,
+	deac_full_minus_4 = 0x00401800,
+};
+#define DMA_CONTROL_TSF		0x00200000 /* Transmit  Store and Forward */
+#define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
+
+enum ttc_control {
+	DMA_CONTROL_TTC_64 = 0x00000000,
+	DMA_CONTROL_TTC_128 = 0x00004000,
+	DMA_CONTROL_TTC_192 = 0x00008000,
+	DMA_CONTROL_TTC_256 = 0x0000c000,
+	DMA_CONTROL_TTC_40 = 0x00010000,
+	DMA_CONTROL_TTC_32 = 0x00014000,
+	DMA_CONTROL_TTC_24 = 0x00018000,
+	DMA_CONTROL_TTC_16 = 0x0001c000,
+};
+#define DMA_CONTROL_TC_TX_MASK	0xfffe3fff
+
+#define DMA_CONTROL_EFC		0x00000100
+#define DMA_CONTROL_FEF		0x00000080
+#define DMA_CONTROL_FUF		0x00000040
+
+enum rtc_control {
+	DMA_CONTROL_RTC_64 = 0x00000000,
+	DMA_CONTROL_RTC_32 = 0x00000008,
+	DMA_CONTROL_RTC_96 = 0x00000010,
+	DMA_CONTROL_RTC_128 = 0x00000018,
+};
+#define DMA_CONTROL_TC_RX_MASK	0xffffffe7
+
+#define DMA_CONTROL_OSF	0x00000004	/* Operate on second frame */
+
+/* MMC registers offset */
+#define GMAC_MMC_CTRL      0x100
+#define GMAC_MMC_RX_INTR   0x104
+#define GMAC_MMC_TX_INTR   0x108
+#define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
+
+#undef GMAC_DEBUG
+/* #define GMAC_DEBUG */
+#undef FRAME_FILTER_DEBUG
+/* #define FRAME_FILTER_DEBUG */
+#ifdef GMAC_DEBUG
+#define DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define DBG(fmt, args...)  do { } while (0)
+#endif
+
+extern struct stmmac_dma_ops gmac_dma_ops;
+extern struct stmmac_desc_ops gmac_desc_ops;
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
new file mode 100644
index 0000000..3752e1e
--- /dev/null
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -0,0 +1,253 @@
+/*******************************************************************************
+  This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
+  DWC Ether MAC 10/100/1000 Universal version 3.41a  has been used for
+  developing this code.
+
+  This only implements the mac core functions for this chip.
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
+#include <linux/crc32.h>
+#include "dwmac1000.h"
+
+static void gmac_core_init(unsigned long ioaddr)
+{
+	u32 value = readl(ioaddr + GMAC_CONTROL);
+	value |= GMAC_CORE_INIT;
+	writel(value, ioaddr + GMAC_CONTROL);
+
+	/* STBus Bridge Configuration */
+	/*writel(0xc5608, ioaddr + 0x00007000);*/
+
+	/* Freeze MMC counters */
+	writel(0x8, ioaddr + GMAC_MMC_CTRL);
+	/* Mask GMAC interrupts */
+	writel(0x207, ioaddr + GMAC_INT_MASK);
+
+#ifdef STMMAC_VLAN_TAG_USED
+	/* Tag detection without filtering */
+	writel(0x0, ioaddr + GMAC_VLAN_TAG);
+#endif
+	return;
+}
+
+static void gmac_dump_regs(unsigned long ioaddr)
+{
+	int i;
+	pr_info("\tGMAC registers (base addr = 0x%8x)\n", (unsigned int)ioaddr);
+
+	for (i = 0; i < 55; i++) {
+		int offset = i * 4;
+		pr_info("\tReg No. %d (offset 0x%x): 0x%08x\n", i,
+			offset, readl(ioaddr + offset));
+	}
+	return;
+}
+
+static void gmac_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+				unsigned int reg_n)
+{
+	stmmac_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
+				GMAC_ADDR_LOW(reg_n));
+}
+
+static void gmac_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+				unsigned int reg_n)
+{
+	stmmac_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
+				GMAC_ADDR_LOW(reg_n));
+}
+
+static void gmac_set_filter(struct net_device *dev)
+{
+	unsigned long ioaddr = dev->base_addr;
+	unsigned int value = 0;
+
+	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
+	    __func__, dev->mc_count, dev->uc_count);
+
+	if (dev->flags & IFF_PROMISC)
+		value = GMAC_FRAME_FILTER_PR;
+	else if ((dev->mc_count > HASH_TABLE_SIZE)
+		   || (dev->flags & IFF_ALLMULTI)) {
+		value = GMAC_FRAME_FILTER_PM;	/* pass all multi */
+		writel(0xffffffff, ioaddr + GMAC_HASH_HIGH);
+		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
+	} else if (dev->mc_count > 0) {
+		int i;
+		u32 mc_filter[2];
+		struct dev_mc_list *mclist;
+
+		/* Hash filter for multicast */
+		value = GMAC_FRAME_FILTER_HMC;
+
+		memset(mc_filter, 0, sizeof(mc_filter));
+		for (i = 0, mclist = dev->mc_list;
+		     mclist && i < dev->mc_count; i++, mclist = mclist->next) {
+			/* The upper 6 bits of the calculated CRC are used to
+			   index the contens of the hash table */
+			int bit_nr =
+			    bitrev32(~crc32_le(~0, mclist->dmi_addr, 6)) >> 26;
+			/* The most significant bit determines the register to
+			 * use (H/L) while the other 5 bits determine the bit
+			 * within the register. */
+			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+		}
+		writel(mc_filter[0], ioaddr + GMAC_HASH_LOW);
+		writel(mc_filter[1], ioaddr + GMAC_HASH_HIGH);
+	}
+
+	/* Handle multiple unicast addresses (perfect filtering)*/
+	if (dev->uc_count > GMAC_MAX_UNICAST_ADDRESSES)
+		/* Switch to promiscuous mode is more than 16 addrs
+		   are required */
+		value |= GMAC_FRAME_FILTER_PR;
+	else {
+		int i;
+		struct dev_addr_list *uc_ptr = dev->uc_list;
+
+			for (i = 0; i < dev->uc_count; i++) {
+				gmac_set_umac_addr(ioaddr, uc_ptr->da_addr,
+						i + 1);
+
+				DBG(KERN_INFO "\t%d "
+				"- Unicast addr %02x:%02x:%02x:%02x:%02x:"
+				"%02x\n", i + 1,
+				uc_ptr->da_addr[0], uc_ptr->da_addr[1],
+				uc_ptr->da_addr[2], uc_ptr->da_addr[3],
+				uc_ptr->da_addr[4], uc_ptr->da_addr[5]);
+				uc_ptr = uc_ptr->next;
+		}
+	}
+
+#ifdef FRAME_FILTER_DEBUG
+	/* Enable Receive all mode (to debug filtering_fail errors) */
+	value |= GMAC_FRAME_FILTER_RA;
+#endif
+	writel(value, ioaddr + GMAC_FRAME_FILTER);
+
+	DBG(KERN_INFO "\tFrame Filter reg: 0x%08x\n\tHash regs: "
+	    "HI 0x%08x, LO 0x%08x\n", readl(ioaddr + GMAC_FRAME_FILTER),
+	    readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
+
+	return;
+}
+
+static void gmac_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
+			   unsigned int fc, unsigned int pause_time)
+{
+	unsigned int flow = 0;
+
+	DBG(KERN_DEBUG "GMAC Flow-Control:\n");
+	if (fc & FLOW_RX) {
+		DBG(KERN_DEBUG "\tReceive Flow-Control ON\n");
+		flow |= GMAC_FLOW_CTRL_RFE;
+	}
+	if (fc & FLOW_TX) {
+		DBG(KERN_DEBUG "\tTransmit Flow-Control ON\n");
+		flow |= GMAC_FLOW_CTRL_TFE;
+	}
+
+	if (duplex) {
+		DBG(KERN_DEBUG "\tduplex mode: pause time: %d\n", pause_time);
+		flow |= (pause_time << GMAC_FLOW_CTRL_PT_SHIFT);
+	}
+
+	writel(flow, ioaddr + GMAC_FLOW_CTRL);
+	return;
+}
+
+static void gmac_pmt(unsigned long ioaddr, unsigned long mode)
+{
+	unsigned int pmt = 0;
+
+	if (mode == WAKE_MAGIC) {
+		DBG(KERN_DEBUG "GMAC: WOL Magic frame\n");
+		pmt |= power_down | magic_pkt_en;
+	} else if (mode == WAKE_UCAST) {
+		DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
+		pmt |= global_unicast;
+	}
+
+	writel(pmt, ioaddr + GMAC_PMT);
+	return;
+}
+
+
+static void gmac_irq_status(unsigned long ioaddr)
+{
+	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
+
+	/* Not used events (e.g. MMC interrupts) are not handled. */
+	if ((intr_status & mmc_tx_irq))
+		DBG(KERN_DEBUG "GMAC: MMC tx interrupt: 0x%08x\n",
+		    readl(ioaddr + GMAC_MMC_TX_INTR));
+	if (unlikely(intr_status & mmc_rx_irq))
+		DBG(KERN_DEBUG "GMAC: MMC rx interrupt: 0x%08x\n",
+		    readl(ioaddr + GMAC_MMC_RX_INTR));
+	if (unlikely(intr_status & mmc_rx_csum_offload_irq))
+		DBG(KERN_DEBUG "GMAC: MMC rx csum offload: 0x%08x\n",
+		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
+	if (unlikely(intr_status & pmt_irq)) {
+		DBG(KERN_DEBUG "GMAC: received Magic frame\n");
+		/* clear the PMT bits 5 and 6 by reading the PMT
+		 * status register. */
+		readl(ioaddr + GMAC_PMT);
+	}
+
+	return;
+}
+
+struct stmmac_ops gmac_ops = {
+	.core_init = gmac_core_init,
+	.dump_regs = gmac_dump_regs,
+	.host_irq_status = gmac_irq_status,
+	.set_filter = gmac_set_filter,
+	.flow_ctrl = gmac_flow_ctrl,
+	.pmt = gmac_pmt,
+	.set_umac_addr = gmac_set_umac_addr,
+	.get_umac_addr = gmac_get_umac_addr,
+};
+
+struct mac_device_info *gmac_setup(unsigned long ioaddr)
+{
+	struct mac_device_info *mac;
+	u32 uid = readl(ioaddr + GMAC_VERSION);
+
+	pr_info("\tDWMAC1000 - user ID: 0x%x, Synopsys ID: 0x%x\n",
+		((uid & 0x0000ff00) >> 8), (uid & 0x000000ff));
+
+	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+
+	mac->mac = &gmac_ops;
+	mac->desc = &gmac_desc_ops;
+	mac->dma = &gmac_dma_ops;
+
+	mac->pmt = PMT_SUPPORTED;
+	mac->link.port = GMAC_CONTROL_PS;
+	mac->link.duplex = GMAC_CONTROL_DM;
+	mac->link.speed = GMAC_CONTROL_FES;
+	mac->mii.addr = GMAC_MII_ADDR;
+	mac->mii.data = GMAC_MII_DATA;
+
+	return mac;
+}
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
new file mode 100644
index 0000000..0ffe2dc
--- /dev/null
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -0,0 +1,473 @@
+/*******************************************************************************
+  This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
+  DWC Ether MAC 10/100/1000 Universal version 3.41a  has been used for
+  developing this code.
+
+  This contains the functions to handle the dma and descriptors.
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
+#include "dwmac1000.h"
+#include "dwmac_dma.h"
+
+static int gmac_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx)
+{
+	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	/* DMA SW reset */
+	value |= DMA_BUS_MODE_SFT_RESET;
+	writel(value, ioaddr + DMA_BUS_MODE);
+	do {} while ((readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET));
+
+	value = /* DMA_BUS_MODE_FB | */ DMA_BUS_MODE_4PBL |
+	    ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
+	     (pbl << DMA_BUS_MODE_RPBL_SHIFT));
+
+#ifdef CONFIG_STMMAC_DA
+	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
+#endif
+	writel(value, ioaddr + DMA_BUS_MODE);
+
+	/* Mask interrupts by writing to CSR7 */
+	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
+
+	/* The base address of the RX/TX descriptor lists must be written into
+	 * DMA CSR3 and CSR4, respectively. */
+	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
+	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
+
+	return 0;
+}
+
+/* Transmit FIFO flush operation */
+static void gmac_flush_tx_fifo(unsigned long ioaddr)
+{
+	u32 csr6 = readl(ioaddr + DMA_CONTROL);
+	writel((csr6 | DMA_CONTROL_FTF), ioaddr + DMA_CONTROL);
+
+	do {} while ((readl(ioaddr + DMA_CONTROL) & DMA_CONTROL_FTF));
+}
+
+static void gmac_dma_operation_mode(unsigned long ioaddr, int txmode,
+				    int rxmode)
+{
+	u32 csr6 = readl(ioaddr + DMA_CONTROL);
+
+	if (txmode == SF_DMA_MODE) {
+		DBG(KERN_DEBUG "GMAC: enabling TX store and forward mode\n");
+		/* Transmit COE type 2 cannot be done in cut-through mode. */
+		csr6 |= DMA_CONTROL_TSF;
+		/* Operating on second frame increase the performance
+		 * especially when transmit store-and-forward is used.*/
+		csr6 |= DMA_CONTROL_OSF;
+	} else {
+		DBG(KERN_DEBUG "GMAC: disabling TX store and forward mode"
+			      " (threshold = %d)\n", txmode);
+		csr6 &= ~DMA_CONTROL_TSF;
+		csr6 &= DMA_CONTROL_TC_TX_MASK;
+		/* Set the transmit threashold */
+		if (txmode <= 32)
+			csr6 |= DMA_CONTROL_TTC_32;
+		else if (txmode <= 64)
+			csr6 |= DMA_CONTROL_TTC_64;
+		else if (txmode <= 128)
+			csr6 |= DMA_CONTROL_TTC_128;
+		else if (txmode <= 192)
+			csr6 |= DMA_CONTROL_TTC_192;
+		else
+			csr6 |= DMA_CONTROL_TTC_256;
+	}
+
+	if (rxmode == SF_DMA_MODE) {
+		DBG(KERN_DEBUG "GMAC: enabling RX store and forward mode\n");
+		csr6 |= DMA_CONTROL_RSF;
+	} else {
+		DBG(KERN_DEBUG "GMAC: disabling RX store and forward mode"
+			      " (threshold = %d)\n", rxmode);
+		csr6 &= ~DMA_CONTROL_RSF;
+		csr6 &= DMA_CONTROL_TC_RX_MASK;
+		if (rxmode <= 32)
+			csr6 |= DMA_CONTROL_RTC_32;
+		else if (rxmode <= 64)
+			csr6 |= DMA_CONTROL_RTC_64;
+		else if (rxmode <= 96)
+			csr6 |= DMA_CONTROL_RTC_96;
+		else
+			csr6 |= DMA_CONTROL_RTC_128;
+	}
+
+	writel(csr6, ioaddr + DMA_CONTROL);
+	return;
+}
+
+/* Not yet implemented --- no RMON module */
+static void gmac_dma_diagnostic_fr(void *data,
+		  struct stmmac_extra_stats *x, unsigned long ioaddr)
+{
+	return;
+}
+
+static void gmac_dump_dma_regs(unsigned long ioaddr)
+{
+	int i;
+	pr_info(" DMA registers\n");
+	for (i = 0; i < 22; i++) {
+		if ((i < 9) || (i > 17)) {
+			int offset = i * 4;
+			pr_err("\t Reg No. %d (offset 0x%x): 0x%08x\n", i,
+			       (DMA_BUS_MODE + offset),
+			       readl(ioaddr + DMA_BUS_MODE + offset));
+		}
+	}
+	return;
+}
+
+static int gmac_get_tx_frame_status(void *data,
+				struct stmmac_extra_stats *x,
+				struct dma_desc *p, unsigned long ioaddr)
+{
+	int ret = 0;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.etx.error_summary)) {
+		DBG(KERN_ERR "GMAC TX error... 0x%08x\n", p->des01.etx);
+		if (unlikely(p->des01.etx.jabber_timeout)) {
+			DBG(KERN_ERR "\tjabber_timeout error\n");
+			x->tx_jabber++;
+		}
+
+		if (unlikely(p->des01.etx.frame_flushed)) {
+			DBG(KERN_ERR "\tframe_flushed error\n");
+			x->tx_frame_flushed++;
+			gmac_flush_tx_fifo(ioaddr);
+		}
+
+		if (unlikely(p->des01.etx.loss_carrier)) {
+			DBG(KERN_ERR "\tloss_carrier error\n");
+			x->tx_losscarrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely(p->des01.etx.no_carrier)) {
+			DBG(KERN_ERR "\tno_carrier error\n");
+			x->tx_carrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely(p->des01.etx.late_collision)) {
+			DBG(KERN_ERR "\tlate_collision error\n");
+			stats->collisions += p->des01.etx.collision_count;
+		}
+		if (unlikely(p->des01.etx.excessive_collisions)) {
+			DBG(KERN_ERR "\texcessive_collisions\n");
+			stats->collisions += p->des01.etx.collision_count;
+		}
+		if (unlikely(p->des01.etx.excessive_deferral)) {
+			DBG(KERN_INFO "\texcessive tx_deferral\n");
+			x->tx_deferred++;
+		}
+
+		if (unlikely(p->des01.etx.underflow_error)) {
+			DBG(KERN_ERR "\tunderflow error\n");
+			gmac_flush_tx_fifo(ioaddr);
+			x->tx_underflow++;
+		}
+
+		if (unlikely(p->des01.etx.ip_header_error)) {
+			DBG(KERN_ERR "\tTX IP header csum error\n");
+			x->tx_ip_header_error++;
+		}
+
+		if (unlikely(p->des01.etx.payload_error)) {
+			DBG(KERN_ERR "\tAddr/Payload csum error\n");
+			x->tx_payload_error++;
+			gmac_flush_tx_fifo(ioaddr);
+		}
+
+		ret = -1;
+	}
+
+	if (unlikely(p->des01.etx.deferred)) {
+		DBG(KERN_INFO "GMAC TX status: tx deferred\n");
+		x->tx_deferred++;
+	}
+#ifdef STMMAC_VLAN_TAG_USED
+	if (p->des01.etx.vlan_frame) {
+		DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
+		x->tx_vlan++;
+	}
+#endif
+
+	return ret;
+}
+
+static int gmac_get_tx_len(struct dma_desc *p)
+{
+	return p->des01.etx.buffer1_size;
+}
+
+static int gmac_coe_rdes0(int ipc_err, int type, int payload_err)
+{
+	int ret = good_frame;
+	u32 status = (type << 2 | ipc_err << 1 | payload_err) & 0x7;
+
+	/* bits 5 7 0 | Frame status
+	 * ----------------------------------------------------------
+	 *      0 0 0 | IEEE 802.3 Type frame (lenght < 1536 octects)
+	 *      1 0 0 | IPv4/6 No CSUM errorS.
+	 *      1 0 1 | IPv4/6 CSUM PAYLOAD error
+	 *      1 1 0 | IPv4/6 CSUM IP HR error
+	 *      1 1 1 | IPv4/6 IP PAYLOAD AND HEADER errorS
+	 *      0 0 1 | IPv4/6 unsupported IP PAYLOAD
+	 *      0 1 1 | COE bypassed.. no IPv4/6 frame
+	 *      0 1 0 | Reserved.
+	 */
+	if (status == 0x0) {
+		DBG(KERN_INFO "RX Des0 status: IEEE 802.3 Type frame.\n");
+		ret = good_frame;
+	} else if (status == 0x4) {
+		DBG(KERN_INFO "RX Des0 status: IPv4/6 No CSUM errorS.\n");
+		ret = good_frame;
+	} else if (status == 0x5) {
+		DBG(KERN_ERR "RX Des0 status: IPv4/6 Payload Error.\n");
+		ret = csum_none;
+	} else if (status == 0x6) {
+		DBG(KERN_ERR "RX Des0 status: IPv4/6 Header Error.\n");
+		ret = csum_none;
+	} else if (status == 0x7) {
+		DBG(KERN_ERR
+		    "RX Des0 status: IPv4/6 Header and Payload Error.\n");
+		ret = csum_none;
+	} else if (status == 0x1) {
+		DBG(KERN_ERR
+		    "RX Des0 status: IPv4/6 unsupported IP PAYLOAD.\n");
+		ret = discard_frame;
+	} else if (status == 0x3) {
+		DBG(KERN_ERR "RX Des0 status: No IPv4, IPv6 frame.\n");
+		ret = discard_frame;
+	}
+	return ret;
+}
+
+static int gmac_get_rx_frame_status(void *data,
+			struct stmmac_extra_stats *x, struct dma_desc *p)
+{
+	int ret = good_frame;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.erx.error_summary)) {
+		DBG(KERN_ERR "GMAC RX Error Summary... 0x%08x\n", p->des01.erx);
+		if (unlikely(p->des01.erx.descriptor_error)) {
+			DBG(KERN_ERR "\tdescriptor error\n");
+			x->rx_desc++;
+			stats->rx_length_errors++;
+		}
+		if (unlikely(p->des01.erx.overflow_error)) {
+			DBG(KERN_ERR "\toverflow error\n");
+			x->rx_gmac_overflow++;
+		}
+
+		if (unlikely(p->des01.erx.ipc_csum_error))
+			DBG(KERN_ERR "\tIPC Csum Error/Giant frame\n");
+
+		if (unlikely(p->des01.erx.late_collision)) {
+			DBG(KERN_ERR "\tlate_collision error\n");
+			stats->collisions++;
+			stats->collisions++;
+		}
+		if (unlikely(p->des01.erx.receive_watchdog)) {
+			DBG(KERN_ERR "\treceive_watchdog error\n");
+			x->rx_watchdog++;
+		}
+		if (unlikely(p->des01.erx.error_gmii)) {
+			DBG(KERN_ERR "\tReceive Error\n");
+			x->rx_mii++;
+		}
+		if (unlikely(p->des01.erx.crc_error)) {
+			DBG(KERN_ERR "\tCRC error\n");
+			x->rx_crc++;
+			stats->rx_crc_errors++;
+		}
+		ret = discard_frame;
+	}
+
+	/* After a payload csum error, the ES bit is set.
+	 * It doesn't match with the information reported into the databook.
+	 * At any rate, we need to understand if the CSUM hw computation is ok
+	 * and report this info to the upper layers. */
+	ret = gmac_coe_rdes0(p->des01.erx.ipc_csum_error,
+		p->des01.erx.frame_type, p->des01.erx.payload_csum_error);
+
+	if (unlikely(p->des01.erx.dribbling)) {
+		DBG(KERN_ERR "GMAC RX: dribbling error\n");
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.erx.sa_filter_fail)) {
+		DBG(KERN_ERR "GMAC RX : Source Address filter fail\n");
+		x->sa_rx_filter_fail++;
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.erx.da_filter_fail)) {
+		DBG(KERN_ERR "GMAC RX : Destination Address filter fail\n");
+		x->da_rx_filter_fail++;
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.erx.length_error)) {
+		DBG(KERN_ERR "GMAC RX: length_error error\n");
+		x->rx_lenght++;
+		ret = discard_frame;
+	}
+#ifdef STMMAC_VLAN_TAG_USED
+	if (p->des01.erx.vlan_tag) {
+		DBG(KERN_INFO "GMAC RX: VLAN frame tagged\n");
+		x->rx_vlan++;
+	}
+#endif
+	return ret;
+}
+
+static void gmac_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				int disable_rx_ic)
+{
+	int i;
+	for (i = 0; i < ring_size; i++) {
+		p->des01.erx.own = 1;
+		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
+		/* To support jumbo frames */
+		p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
+		if (i == ring_size - 1)
+			p->des01.erx.end_ring = 1;
+		if (disable_rx_ic)
+			p->des01.erx.disable_ic = 1;
+		p++;
+	}
+	return;
+}
+
+static void gmac_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
+{
+	int i;
+
+	for (i = 0; i < ring_size; i++) {
+		p->des01.etx.own = 0;
+		if (i == ring_size - 1)
+			p->des01.etx.end_ring = 1;
+		p++;
+	}
+
+	return;
+}
+
+static int gmac_get_tx_owner(struct dma_desc *p)
+{
+	return p->des01.etx.own;
+}
+
+static int gmac_get_rx_owner(struct dma_desc *p)
+{
+	return p->des01.erx.own;
+}
+
+static void gmac_set_tx_owner(struct dma_desc *p)
+{
+	p->des01.etx.own = 1;
+}
+
+static void gmac_set_rx_owner(struct dma_desc *p)
+{
+	p->des01.erx.own = 1;
+}
+
+static int gmac_get_tx_ls(struct dma_desc *p)
+{
+	return p->des01.etx.last_segment;
+}
+
+static void gmac_release_tx_desc(struct dma_desc *p)
+{
+	int ter = p->des01.etx.end_ring;
+
+	memset(p, 0, sizeof(struct dma_desc));
+	p->des01.etx.end_ring = ter;
+
+	return;
+}
+
+static void gmac_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				 int csum_flag)
+{
+	p->des01.etx.first_segment = is_fs;
+	if (unlikely(len > BUF_SIZE_4KiB)) {
+		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
+		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
+	} else {
+		p->des01.etx.buffer1_size = len;
+	}
+	if (likely(csum_flag))
+		p->des01.etx.checksum_insertion = cic_full;
+}
+
+static void gmac_clear_tx_ic(struct dma_desc *p)
+{
+	p->des01.etx.interrupt = 0;
+}
+
+static void gmac_close_tx_desc(struct dma_desc *p)
+{
+	p->des01.etx.last_segment = 1;
+	p->des01.etx.interrupt = 1;
+}
+
+static int gmac_get_rx_frame_len(struct dma_desc *p)
+{
+	return p->des01.erx.frame_length;
+}
+
+struct stmmac_dma_ops gmac_dma_ops = {
+	.init = gmac_dma_init,
+	.dump_regs = gmac_dump_dma_regs,
+	.dma_mode = gmac_dma_operation_mode,
+	.dma_diagnostic_fr = gmac_dma_diagnostic_fr,
+	.enable_dma_transmission = dwmac_enable_dma_transmission,
+	.enable_dma_irq = dwmac_enable_dma_irq,
+	.disable_dma_irq = dwmac_disable_dma_irq,
+	.start_tx = dwmac_dma_start_tx,
+	.stop_tx = dwmac_dma_stop_tx,
+	.start_rx = dwmac_dma_start_rx,
+	.stop_rx = dwmac_dma_stop_rx,
+	.dma_interrupt = dwmac_dma_interrupt,
+};
+
+struct stmmac_desc_ops gmac_desc_ops = {
+	.tx_status = gmac_get_tx_frame_status,
+	.rx_status = gmac_get_rx_frame_status,
+	.get_tx_len = gmac_get_tx_len,
+	.init_rx_desc = gmac_init_rx_desc,
+	.init_tx_desc = gmac_init_tx_desc,
+	.get_tx_owner = gmac_get_tx_owner,
+	.get_rx_owner = gmac_get_rx_owner,
+	.release_tx_desc = gmac_release_tx_desc,
+	.prepare_tx_desc = gmac_prepare_tx_desc,
+	.clear_tx_ic = gmac_clear_tx_ic,
+	.close_tx_desc = gmac_close_tx_desc,
+	.get_tx_ls = gmac_get_tx_ls,
+	.set_tx_owner = gmac_set_tx_owner,
+	.set_rx_owner = gmac_set_rx_owner,
+	.get_rx_frame_len = gmac_get_rx_frame_len,
+};
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
deleted file mode 100644
index b624bb5..0000000
--- a/drivers/net/stmmac/gmac.c
+++ /dev/null
@@ -1,693 +0,0 @@
-/*******************************************************************************
-  This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
-  DWC Ether MAC 10/100/1000 Universal version 3.41a  has been used for
-  developing this code.
-
-  Copyright (C) 2007-2009  STMicroelectronics Ltd
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
-*******************************************************************************/
-
-#include <linux/netdevice.h>
-#include <linux/crc32.h>
-#include <linux/mii.h>
-#include <linux/phy.h>
-
-#include "stmmac.h"
-#include "gmac.h"
-
-#undef GMAC_DEBUG
-/*#define GMAC_DEBUG*/
-#undef FRAME_FILTER_DEBUG
-/*#define FRAME_FILTER_DEBUG*/
-#ifdef GMAC_DEBUG
-#define DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define DBG(fmt, args...)  do { } while (0)
-#endif
-
-static void gmac_dump_regs(unsigned long ioaddr)
-{
-	int i;
-	pr_info("\t----------------------------------------------\n"
-	       "\t  GMAC registers (base addr = 0x%8x)\n"
-	       "\t----------------------------------------------\n",
-	       (unsigned int)ioaddr);
-
-	for (i = 0; i < 55; i++) {
-		int offset = i * 4;
-		pr_info("\tReg No. %d (offset 0x%x): 0x%08x\n", i,
-		       offset, readl(ioaddr + offset));
-	}
-	return;
-}
-
-static int gmac_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx, u32 dma_rx)
-{
-	u32 value = readl(ioaddr + DMA_BUS_MODE);
-	/* DMA SW reset */
-	value |= DMA_BUS_MODE_SFT_RESET;
-	writel(value, ioaddr + DMA_BUS_MODE);
-	do {} while ((readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET));
-
-	value = /* DMA_BUS_MODE_FB | */ DMA_BUS_MODE_4PBL |
-	    ((pbl << DMA_BUS_MODE_PBL_SHIFT) |
-	     (pbl << DMA_BUS_MODE_RPBL_SHIFT));
-
-#ifdef CONFIG_STMMAC_DA
-	value |= DMA_BUS_MODE_DA;	/* Rx has priority over tx */
-#endif
-	writel(value, ioaddr + DMA_BUS_MODE);
-
-	/* Mask interrupts by writing to CSR7 */
-	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
-
-	/* The base address of the RX/TX descriptor lists must be written into
-	 * DMA CSR3 and CSR4, respectively. */
-	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
-	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
-
-	return 0;
-}
-
-/* Transmit FIFO flush operation */
-static void gmac_flush_tx_fifo(unsigned long ioaddr)
-{
-	u32 csr6 = readl(ioaddr + DMA_CONTROL);
-	writel((csr6 | DMA_CONTROL_FTF), ioaddr + DMA_CONTROL);
-
-	do {} while ((readl(ioaddr + DMA_CONTROL) & DMA_CONTROL_FTF));
-}
-
-static void gmac_dma_operation_mode(unsigned long ioaddr, int txmode,
-				    int rxmode)
-{
-	u32 csr6 = readl(ioaddr + DMA_CONTROL);
-
-	if (txmode == SF_DMA_MODE) {
-		DBG(KERN_DEBUG "GMAC: enabling TX store and forward mode\n");
-		/* Transmit COE type 2 cannot be done in cut-through mode. */
-		csr6 |= DMA_CONTROL_TSF;
-		/* Operating on second frame increase the performance
-		 * especially when transmit store-and-forward is used.*/
-		csr6 |= DMA_CONTROL_OSF;
-	} else {
-		DBG(KERN_DEBUG "GMAC: disabling TX store and forward mode"
-			      " (threshold = %d)\n", txmode);
-		csr6 &= ~DMA_CONTROL_TSF;
-		csr6 &= DMA_CONTROL_TC_TX_MASK;
-		/* Set the transmit threashold */
-		if (txmode <= 32)
-			csr6 |= DMA_CONTROL_TTC_32;
-		else if (txmode <= 64)
-			csr6 |= DMA_CONTROL_TTC_64;
-		else if (txmode <= 128)
-			csr6 |= DMA_CONTROL_TTC_128;
-		else if (txmode <= 192)
-			csr6 |= DMA_CONTROL_TTC_192;
-		else
-			csr6 |= DMA_CONTROL_TTC_256;
-	}
-
-	if (rxmode == SF_DMA_MODE) {
-		DBG(KERN_DEBUG "GMAC: enabling RX store and forward mode\n");
-		csr6 |= DMA_CONTROL_RSF;
-	} else {
-		DBG(KERN_DEBUG "GMAC: disabling RX store and forward mode"
-			      " (threshold = %d)\n", rxmode);
-		csr6 &= ~DMA_CONTROL_RSF;
-		csr6 &= DMA_CONTROL_TC_RX_MASK;
-		if (rxmode <= 32)
-			csr6 |= DMA_CONTROL_RTC_32;
-		else if (rxmode <= 64)
-			csr6 |= DMA_CONTROL_RTC_64;
-		else if (rxmode <= 96)
-			csr6 |= DMA_CONTROL_RTC_96;
-		else
-			csr6 |= DMA_CONTROL_RTC_128;
-	}
-
-	writel(csr6, ioaddr + DMA_CONTROL);
-	return;
-}
-
-/* Not yet implemented --- no RMON module */
-static void gmac_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
-				   unsigned long ioaddr)
-{
-	return;
-}
-
-static void gmac_dump_dma_regs(unsigned long ioaddr)
-{
-	int i;
-	pr_info(" DMA registers\n");
-	for (i = 0; i < 22; i++) {
-		if ((i < 9) || (i > 17)) {
-			int offset = i * 4;
-			pr_err("\t Reg No. %d (offset 0x%x): 0x%08x\n", i,
-			       (DMA_BUS_MODE + offset),
-			       readl(ioaddr + DMA_BUS_MODE + offset));
-		}
-	}
-	return;
-}
-
-static int gmac_get_tx_frame_status(void *data, struct stmmac_extra_stats *x,
-				    struct dma_desc *p, unsigned long ioaddr)
-{
-	int ret = 0;
-	struct net_device_stats *stats = (struct net_device_stats *)data;
-
-	if (unlikely(p->des01.etx.error_summary)) {
-		DBG(KERN_ERR "GMAC TX error... 0x%08x\n", p->des01.etx);
-		if (unlikely(p->des01.etx.jabber_timeout)) {
-			DBG(KERN_ERR "\tjabber_timeout error\n");
-			x->tx_jabber++;
-		}
-
-		if (unlikely(p->des01.etx.frame_flushed)) {
-			DBG(KERN_ERR "\tframe_flushed error\n");
-			x->tx_frame_flushed++;
-			gmac_flush_tx_fifo(ioaddr);
-		}
-
-		if (unlikely(p->des01.etx.loss_carrier)) {
-			DBG(KERN_ERR "\tloss_carrier error\n");
-			x->tx_losscarrier++;
-			stats->tx_carrier_errors++;
-		}
-		if (unlikely(p->des01.etx.no_carrier)) {
-			DBG(KERN_ERR "\tno_carrier error\n");
-			x->tx_carrier++;
-			stats->tx_carrier_errors++;
-		}
-		if (unlikely(p->des01.etx.late_collision)) {
-			DBG(KERN_ERR "\tlate_collision error\n");
-			stats->collisions += p->des01.etx.collision_count;
-		}
-		if (unlikely(p->des01.etx.excessive_collisions)) {
-			DBG(KERN_ERR "\texcessive_collisions\n");
-			stats->collisions += p->des01.etx.collision_count;
-		}
-		if (unlikely(p->des01.etx.excessive_deferral)) {
-			DBG(KERN_INFO "\texcessive tx_deferral\n");
-			x->tx_deferred++;
-		}
-
-		if (unlikely(p->des01.etx.underflow_error)) {
-			DBG(KERN_ERR "\tunderflow error\n");
-			gmac_flush_tx_fifo(ioaddr);
-			x->tx_underflow++;
-		}
-
-		if (unlikely(p->des01.etx.ip_header_error)) {
-			DBG(KERN_ERR "\tTX IP header csum error\n");
-			x->tx_ip_header_error++;
-		}
-
-		if (unlikely(p->des01.etx.payload_error)) {
-			DBG(KERN_ERR "\tAddr/Payload csum error\n");
-			x->tx_payload_error++;
-			gmac_flush_tx_fifo(ioaddr);
-		}
-
-		ret = -1;
-	}
-
-	if (unlikely(p->des01.etx.deferred)) {
-		DBG(KERN_INFO "GMAC TX status: tx deferred\n");
-		x->tx_deferred++;
-	}
-#ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.etx.vlan_frame) {
-		DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
-		x->tx_vlan++;
-	}
-#endif
-
-	return ret;
-}
-
-static int gmac_get_tx_len(struct dma_desc *p)
-{
-	return p->des01.etx.buffer1_size;
-}
-
-static int gmac_coe_rdes0(int ipc_err, int type, int payload_err)
-{
-	int ret = good_frame;
-	u32 status = (type << 2 | ipc_err << 1 | payload_err) & 0x7;
-
-	/* bits 5 7 0 | Frame status
-	 * ----------------------------------------------------------
-	 *      0 0 0 | IEEE 802.3 Type frame (lenght < 1536 octects)
-	 *      1 0 0 | IPv4/6 No CSUM errorS.
-	 *      1 0 1 | IPv4/6 CSUM PAYLOAD error
-	 *      1 1 0 | IPv4/6 CSUM IP HR error
-	 *      1 1 1 | IPv4/6 IP PAYLOAD AND HEADER errorS
-	 *      0 0 1 | IPv4/6 unsupported IP PAYLOAD
-	 *      0 1 1 | COE bypassed.. no IPv4/6 frame
-	 *      0 1 0 | Reserved.
-	 */
-	if (status == 0x0) {
-		DBG(KERN_INFO "RX Des0 status: IEEE 802.3 Type frame.\n");
-		ret = good_frame;
-	} else if (status == 0x4) {
-		DBG(KERN_INFO "RX Des0 status: IPv4/6 No CSUM errorS.\n");
-		ret = good_frame;
-	} else if (status == 0x5) {
-		DBG(KERN_ERR "RX Des0 status: IPv4/6 Payload Error.\n");
-		ret = csum_none;
-	} else if (status == 0x6) {
-		DBG(KERN_ERR "RX Des0 status: IPv4/6 Header Error.\n");
-		ret = csum_none;
-	} else if (status == 0x7) {
-		DBG(KERN_ERR
-		    "RX Des0 status: IPv4/6 Header and Payload Error.\n");
-		ret = csum_none;
-	} else if (status == 0x1) {
-		DBG(KERN_ERR
-		    "RX Des0 status: IPv4/6 unsupported IP PAYLOAD.\n");
-		ret = discard_frame;
-	} else if (status == 0x3) {
-		DBG(KERN_ERR "RX Des0 status: No IPv4, IPv6 frame.\n");
-		ret = discard_frame;
-	}
-	return ret;
-}
-
-static int gmac_get_rx_frame_status(void *data, struct stmmac_extra_stats *x,
-				    struct dma_desc *p)
-{
-	int ret = good_frame;
-	struct net_device_stats *stats = (struct net_device_stats *)data;
-
-	if (unlikely(p->des01.erx.error_summary)) {
-		DBG(KERN_ERR "GMAC RX Error Summary... 0x%08x\n", p->des01.erx);
-		if (unlikely(p->des01.erx.descriptor_error)) {
-			DBG(KERN_ERR "\tdescriptor error\n");
-			x->rx_desc++;
-			stats->rx_length_errors++;
-		}
-		if (unlikely(p->des01.erx.overflow_error)) {
-			DBG(KERN_ERR "\toverflow error\n");
-			x->rx_gmac_overflow++;
-		}
-
-		if (unlikely(p->des01.erx.ipc_csum_error))
-			DBG(KERN_ERR "\tIPC Csum Error/Giant frame\n");
-
-		if (unlikely(p->des01.erx.late_collision)) {
-			DBG(KERN_ERR "\tlate_collision error\n");
-			stats->collisions++;
-			stats->collisions++;
-		}
-		if (unlikely(p->des01.erx.receive_watchdog)) {
-			DBG(KERN_ERR "\treceive_watchdog error\n");
-			x->rx_watchdog++;
-		}
-		if (unlikely(p->des01.erx.error_gmii)) {
-			DBG(KERN_ERR "\tReceive Error\n");
-			x->rx_mii++;
-		}
-		if (unlikely(p->des01.erx.crc_error)) {
-			DBG(KERN_ERR "\tCRC error\n");
-			x->rx_crc++;
-			stats->rx_crc_errors++;
-		}
-		ret = discard_frame;
-	}
-
-	/* After a payload csum error, the ES bit is set.
-	 * It doesn't match with the information reported into the databook.
-	 * At any rate, we need to understand if the CSUM hw computation is ok
-	 * and report this info to the upper layers. */
-	ret = gmac_coe_rdes0(p->des01.erx.ipc_csum_error,
-		p->des01.erx.frame_type, p->des01.erx.payload_csum_error);
-
-	if (unlikely(p->des01.erx.dribbling)) {
-		DBG(KERN_ERR "GMAC RX: dribbling error\n");
-		ret = discard_frame;
-	}
-	if (unlikely(p->des01.erx.sa_filter_fail)) {
-		DBG(KERN_ERR "GMAC RX : Source Address filter fail\n");
-		x->sa_rx_filter_fail++;
-		ret = discard_frame;
-	}
-	if (unlikely(p->des01.erx.da_filter_fail)) {
-		DBG(KERN_ERR "GMAC RX : Destination Address filter fail\n");
-		x->da_rx_filter_fail++;
-		ret = discard_frame;
-	}
-	if (unlikely(p->des01.erx.length_error)) {
-		DBG(KERN_ERR "GMAC RX: length_error error\n");
-		x->rx_lenght++;
-		ret = discard_frame;
-	}
-#ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.erx.vlan_tag) {
-		DBG(KERN_INFO "GMAC RX: VLAN frame tagged\n");
-		x->rx_vlan++;
-	}
-#endif
-	return ret;
-}
-
-static void gmac_irq_status(unsigned long ioaddr)
-{
-	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
-
-	/* Not used events (e.g. MMC interrupts) are not handled. */
-	if ((intr_status & mmc_tx_irq))
-		DBG(KERN_DEBUG "GMAC: MMC tx interrupt: 0x%08x\n",
-		    readl(ioaddr + GMAC_MMC_TX_INTR));
-	if (unlikely(intr_status & mmc_rx_irq))
-		DBG(KERN_DEBUG "GMAC: MMC rx interrupt: 0x%08x\n",
-		    readl(ioaddr + GMAC_MMC_RX_INTR));
-	if (unlikely(intr_status & mmc_rx_csum_offload_irq))
-		DBG(KERN_DEBUG "GMAC: MMC rx csum offload: 0x%08x\n",
-		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
-	if (unlikely(intr_status & pmt_irq)) {
-		DBG(KERN_DEBUG "GMAC: received Magic frame\n");
-		/* clear the PMT bits 5 and 6 by reading the PMT
-		 * status register. */
-		readl(ioaddr + GMAC_PMT);
-	}
-
-	return;
-}
-
-static void gmac_core_init(unsigned long ioaddr)
-{
-	u32 value = readl(ioaddr + GMAC_CONTROL);
-	value |= GMAC_CORE_INIT;
-	writel(value, ioaddr + GMAC_CONTROL);
-
-	/* STBus Bridge Configuration */
-	/*writel(0xc5608, ioaddr + 0x00007000);*/
-
-	/* Freeze MMC counters */
-	writel(0x8, ioaddr + GMAC_MMC_CTRL);
-	/* Mask GMAC interrupts */
-	writel(0x207, ioaddr + GMAC_INT_MASK);
-
-#ifdef STMMAC_VLAN_TAG_USED
-	/* Tag detection without filtering */
-	writel(0x0, ioaddr + GMAC_VLAN_TAG);
-#endif
-	return;
-}
-
-static void gmac_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
-				unsigned int reg_n)
-{
-	stmmac_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
-				GMAC_ADDR_LOW(reg_n));
-}
-
-static void gmac_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
-				unsigned int reg_n)
-{
-	stmmac_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
-				GMAC_ADDR_LOW(reg_n));
-}
-
-static void gmac_set_filter(struct net_device *dev)
-{
-	unsigned long ioaddr = dev->base_addr;
-	unsigned int value = 0;
-
-	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-	    __func__, dev->mc_count, dev->uc_count);
-
-	if (dev->flags & IFF_PROMISC)
-		value = GMAC_FRAME_FILTER_PR;
-	else if ((dev->mc_count > HASH_TABLE_SIZE)
-		   || (dev->flags & IFF_ALLMULTI)) {
-		value = GMAC_FRAME_FILTER_PM;	/* pass all multi */
-		writel(0xffffffff, ioaddr + GMAC_HASH_HIGH);
-		writel(0xffffffff, ioaddr + GMAC_HASH_LOW);
-	} else if (dev->mc_count > 0) {
-		int i;
-		u32 mc_filter[2];
-		struct dev_mc_list *mclist;
-
-		/* Hash filter for multicast */
-		value = GMAC_FRAME_FILTER_HMC;
-
-		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < dev->mc_count; i++, mclist = mclist->next) {
-			/* The upper 6 bits of the calculated CRC are used to
-			   index the contens of the hash table */
-			int bit_nr =
-			    bitrev32(~crc32_le(~0, mclist->dmi_addr, 6)) >> 26;
-			/* The most significant bit determines the register to
-			 * use (H/L) while the other 5 bits determine the bit
-			 * within the register. */
-			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
-		}
-		writel(mc_filter[0], ioaddr + GMAC_HASH_LOW);
-		writel(mc_filter[1], ioaddr + GMAC_HASH_HIGH);
-	}
-
-	/* Handle multiple unicast addresses (perfect filtering)*/
-	if (dev->uc_count > GMAC_MAX_UNICAST_ADDRESSES)
-		/* Switch to promiscuous mode is more than 16 addrs
-		   are required */
-		value |= GMAC_FRAME_FILTER_PR;
-	else {
-		int i;
-		struct dev_addr_list *uc_ptr = dev->uc_list;
-
-			for (i = 0; i < dev->uc_count; i++) {
-				gmac_set_umac_addr(ioaddr, uc_ptr->da_addr,
-						i + 1);
-
-				DBG(KERN_INFO "\t%d "
-				"- Unicast addr %02x:%02x:%02x:%02x:%02x:"
-				"%02x\n", i + 1,
-				uc_ptr->da_addr[0], uc_ptr->da_addr[1],
-				uc_ptr->da_addr[2], uc_ptr->da_addr[3],
-				uc_ptr->da_addr[4], uc_ptr->da_addr[5]);
-				uc_ptr = uc_ptr->next;
-		}
-	}
-
-#ifdef FRAME_FILTER_DEBUG
-	/* Enable Receive all mode (to debug filtering_fail errors) */
-	value |= GMAC_FRAME_FILTER_RA;
-#endif
-	writel(value, ioaddr + GMAC_FRAME_FILTER);
-
-	DBG(KERN_INFO "\tFrame Filter reg: 0x%08x\n\tHash regs: "
-	    "HI 0x%08x, LO 0x%08x\n", readl(ioaddr + GMAC_FRAME_FILTER),
-	    readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
-
-	return;
-}
-
-static void gmac_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
-			   unsigned int fc, unsigned int pause_time)
-{
-	unsigned int flow = 0;
-
-	DBG(KERN_DEBUG "GMAC Flow-Control:\n");
-	if (fc & FLOW_RX) {
-		DBG(KERN_DEBUG "\tReceive Flow-Control ON\n");
-		flow |= GMAC_FLOW_CTRL_RFE;
-	}
-	if (fc & FLOW_TX) {
-		DBG(KERN_DEBUG "\tTransmit Flow-Control ON\n");
-		flow |= GMAC_FLOW_CTRL_TFE;
-	}
-
-	if (duplex) {
-		DBG(KERN_DEBUG "\tduplex mode: pause time: %d\n", pause_time);
-		flow |= (pause_time << GMAC_FLOW_CTRL_PT_SHIFT);
-	}
-
-	writel(flow, ioaddr + GMAC_FLOW_CTRL);
-	return;
-}
-
-static void gmac_pmt(unsigned long ioaddr, unsigned long mode)
-{
-	unsigned int pmt = 0;
-
-	if (mode == WAKE_MAGIC) {
-		DBG(KERN_DEBUG "GMAC: WOL Magic frame\n");
-		pmt |= power_down | magic_pkt_en;
-	} else if (mode == WAKE_UCAST) {
-		DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
-		pmt |= global_unicast;
-	}
-
-	writel(pmt, ioaddr + GMAC_PMT);
-	return;
-}
-
-static void gmac_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-				int disable_rx_ic)
-{
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.erx.own = 1;
-		p->des01.erx.buffer1_size = BUF_SIZE_8KiB - 1;
-		/* To support jumbo frames */
-		p->des01.erx.buffer2_size = BUF_SIZE_8KiB - 1;
-		if (i == ring_size - 1)
-			p->des01.erx.end_ring = 1;
-		if (disable_rx_ic)
-			p->des01.erx.disable_ic = 1;
-		p++;
-	}
-	return;
-}
-
-static void gmac_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
-{
-	int i;
-
-	for (i = 0; i < ring_size; i++) {
-		p->des01.etx.own = 0;
-		if (i == ring_size - 1)
-			p->des01.etx.end_ring = 1;
-		p++;
-	}
-
-	return;
-}
-
-static int gmac_get_tx_owner(struct dma_desc *p)
-{
-	return p->des01.etx.own;
-}
-
-static int gmac_get_rx_owner(struct dma_desc *p)
-{
-	return p->des01.erx.own;
-}
-
-static void gmac_set_tx_owner(struct dma_desc *p)
-{
-	p->des01.etx.own = 1;
-}
-
-static void gmac_set_rx_owner(struct dma_desc *p)
-{
-	p->des01.erx.own = 1;
-}
-
-static int gmac_get_tx_ls(struct dma_desc *p)
-{
-	return p->des01.etx.last_segment;
-}
-
-static void gmac_release_tx_desc(struct dma_desc *p)
-{
-	int ter = p->des01.etx.end_ring;
-
-	memset(p, 0, sizeof(struct dma_desc));
-	p->des01.etx.end_ring = ter;
-
-	return;
-}
-
-static void gmac_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				 int csum_flag)
-{
-	p->des01.etx.first_segment = is_fs;
-	if (unlikely(len > BUF_SIZE_4KiB)) {
-		p->des01.etx.buffer1_size = BUF_SIZE_4KiB;
-		p->des01.etx.buffer2_size = len - BUF_SIZE_4KiB;
-	} else {
-		p->des01.etx.buffer1_size = len;
-	}
-	if (likely(csum_flag))
-		p->des01.etx.checksum_insertion = cic_full;
-}
-
-static void gmac_clear_tx_ic(struct dma_desc *p)
-{
-	p->des01.etx.interrupt = 0;
-}
-
-static void gmac_close_tx_desc(struct dma_desc *p)
-{
-	p->des01.etx.last_segment = 1;
-	p->des01.etx.interrupt = 1;
-}
-
-static int gmac_get_rx_frame_len(struct dma_desc *p)
-{
-	return p->des01.erx.frame_length;
-}
-
-struct stmmac_ops gmac_driver = {
-	.core_init = gmac_core_init,
-	.dump_mac_regs = gmac_dump_regs,
-	.dma_init = gmac_dma_init,
-	.dump_dma_regs = gmac_dump_dma_regs,
-	.dma_mode = gmac_dma_operation_mode,
-	.dma_diagnostic_fr = gmac_dma_diagnostic_fr,
-	.tx_status = gmac_get_tx_frame_status,
-	.rx_status = gmac_get_rx_frame_status,
-	.get_tx_len = gmac_get_tx_len,
-	.set_filter = gmac_set_filter,
-	.flow_ctrl = gmac_flow_ctrl,
-	.pmt = gmac_pmt,
-	.init_rx_desc = gmac_init_rx_desc,
-	.init_tx_desc = gmac_init_tx_desc,
-	.get_tx_owner = gmac_get_tx_owner,
-	.get_rx_owner = gmac_get_rx_owner,
-	.release_tx_desc = gmac_release_tx_desc,
-	.prepare_tx_desc = gmac_prepare_tx_desc,
-	.clear_tx_ic = gmac_clear_tx_ic,
-	.close_tx_desc = gmac_close_tx_desc,
-	.get_tx_ls = gmac_get_tx_ls,
-	.set_tx_owner = gmac_set_tx_owner,
-	.set_rx_owner = gmac_set_rx_owner,
-	.get_rx_frame_len = gmac_get_rx_frame_len,
-	.host_irq_status = gmac_irq_status,
-	.set_umac_addr = gmac_set_umac_addr,
-	.get_umac_addr = gmac_get_umac_addr,
-};
-
-struct mac_device_info *gmac_setup(unsigned long ioaddr)
-{
-	struct mac_device_info *mac;
-	u32 uid = readl(ioaddr + GMAC_VERSION);
-
-	pr_info("\tGMAC - user ID: 0x%x, Synopsys ID: 0x%x\n",
-	       ((uid & 0x0000ff00) >> 8), (uid & 0x000000ff));
-
-	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
-
-	mac->ops = &gmac_driver;
-	mac->hw.pmt = PMT_SUPPORTED;
-	mac->hw.link.port = GMAC_CONTROL_PS;
-	mac->hw.link.duplex = GMAC_CONTROL_DM;
-	mac->hw.link.speed = GMAC_CONTROL_FES;
-	mac->hw.mii.addr = GMAC_MII_ADDR;
-	mac->hw.mii.data = GMAC_MII_DATA;
-
-	return mac;
-}
diff --git a/drivers/net/stmmac/gmac.h b/drivers/net/stmmac/gmac.h
deleted file mode 100644
index 684a363..0000000
--- a/drivers/net/stmmac/gmac.h
+++ /dev/null
@@ -1,204 +0,0 @@
-/*******************************************************************************
-  Copyright (C) 2007-2009  STMicroelectronics Ltd
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
-*******************************************************************************/
-
-#define GMAC_CONTROL		0x00000000	/* Configuration */
-#define GMAC_FRAME_FILTER	0x00000004	/* Frame Filter */
-#define GMAC_HASH_HIGH		0x00000008	/* Multicast Hash Table High */
-#define GMAC_HASH_LOW		0x0000000c	/* Multicast Hash Table Low */
-#define GMAC_MII_ADDR		0x00000010	/* MII Address */
-#define GMAC_MII_DATA		0x00000014	/* MII Data */
-#define GMAC_FLOW_CTRL		0x00000018	/* Flow Control */
-#define GMAC_VLAN_TAG		0x0000001c	/* VLAN Tag */
-#define GMAC_VERSION		0x00000020	/* GMAC CORE Version */
-#define GMAC_WAKEUP_FILTER	0x00000028	/* Wake-up Frame Filter */
-
-#define GMAC_INT_STATUS		0x00000038	/* interrupt status register */
-enum gmac_irq_status {
-	time_stamp_irq = 0x0200,
-	mmc_rx_csum_offload_irq = 0x0080,
-	mmc_tx_irq = 0x0040,
-	mmc_rx_irq = 0x0020,
-	mmc_irq = 0x0010,
-	pmt_irq = 0x0008,
-	pcs_ane_irq = 0x0004,
-	pcs_link_irq = 0x0002,
-	rgmii_irq = 0x0001,
-};
-#define GMAC_INT_MASK		0x0000003c	/* interrupt mask register */
-
-/* PMT Control and Status */
-#define GMAC_PMT		0x0000002c
-enum power_event {
-	pointer_reset = 0x80000000,
-	global_unicast = 0x00000200,
-	wake_up_rx_frame = 0x00000040,
-	magic_frame = 0x00000020,
-	wake_up_frame_en = 0x00000004,
-	magic_pkt_en = 0x00000002,
-	power_down = 0x00000001,
-};
-
-/* GMAC HW ADDR regs */
-#define GMAC_ADDR_HIGH(reg)		(0x00000040+(reg * 8))
-#define GMAC_ADDR_LOW(reg)		(0x00000044+(reg * 8))
-#define GMAC_MAX_UNICAST_ADDRESSES	16
-
-#define GMAC_AN_CTRL	0x000000c0	/* AN control */
-#define GMAC_AN_STATUS	0x000000c4	/* AN status */
-#define GMAC_ANE_ADV	0x000000c8	/* Auto-Neg. Advertisement */
-#define GMAC_ANE_LINK	0x000000cc	/* Auto-Neg. link partener ability */
-#define GMAC_ANE_EXP	0x000000d0	/* ANE expansion */
-#define GMAC_TBI	0x000000d4	/* TBI extend status */
-#define GMAC_GMII_STATUS 0x000000d8	/* S/R-GMII status */
-
-/* GMAC Configuration defines */
-#define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
-#define GMAC_CONTROL_WD	0x00800000	/* Disable Watchdog on receive */
-#define GMAC_CONTROL_JD	0x00400000	/* Jabber disable */
-#define GMAC_CONTROL_BE	0x00200000	/* Frame Burst Enable */
-#define GMAC_CONTROL_JE	0x00100000	/* Jumbo frame */
-enum inter_frame_gap {
-	GMAC_CONTROL_IFG_88 = 0x00040000,
-	GMAC_CONTROL_IFG_80 = 0x00020000,
-	GMAC_CONTROL_IFG_40 = 0x000e0000,
-};
-#define GMAC_CONTROL_DCRS	0x00010000 /* Disable carrier sense during tx */
-#define GMAC_CONTROL_PS		0x00008000 /* Port Select 0:GMI 1:MII */
-#define GMAC_CONTROL_FES	0x00004000 /* Speed 0:10 1:100 */
-#define GMAC_CONTROL_DO		0x00002000 /* Disable Rx Own */
-#define GMAC_CONTROL_LM		0x00001000 /* Loop-back mode */
-#define GMAC_CONTROL_DM		0x00000800 /* Duplex Mode */
-#define GMAC_CONTROL_IPC	0x00000400 /* Checksum Offload */
-#define GMAC_CONTROL_DR		0x00000200 /* Disable Retry */
-#define GMAC_CONTROL_LUD	0x00000100 /* Link up/down */
-#define GMAC_CONTROL_ACS	0x00000080 /* Automatic Pad Stripping */
-#define GMAC_CONTROL_DC		0x00000010 /* Deferral Check */
-#define GMAC_CONTROL_TE		0x00000008 /* Transmitter Enable */
-#define GMAC_CONTROL_RE		0x00000004 /* Receiver Enable */
-
-#define GMAC_CORE_INIT (GMAC_CONTROL_JD | GMAC_CONTROL_PS | GMAC_CONTROL_ACS | \
-			GMAC_CONTROL_IPC | GMAC_CONTROL_JE | GMAC_CONTROL_BE)
-
-/* GMAC Frame Filter defines */
-#define GMAC_FRAME_FILTER_PR	0x00000001	/* Promiscuous Mode */
-#define GMAC_FRAME_FILTER_HUC	0x00000002	/* Hash Unicast */
-#define GMAC_FRAME_FILTER_HMC	0x00000004	/* Hash Multicast */
-#define GMAC_FRAME_FILTER_DAIF	0x00000008	/* DA Inverse Filtering */
-#define GMAC_FRAME_FILTER_PM	0x00000010	/* Pass all multicast */
-#define GMAC_FRAME_FILTER_DBF	0x00000020	/* Disable Broadcast frames */
-#define GMAC_FRAME_FILTER_SAIF	0x00000100	/* Inverse Filtering */
-#define GMAC_FRAME_FILTER_SAF	0x00000200	/* Source Address Filter */
-#define GMAC_FRAME_FILTER_HPF	0x00000400	/* Hash or perfect Filter */
-#define GMAC_FRAME_FILTER_RA	0x80000000	/* Receive all mode */
-/* GMII ADDR  defines */
-#define GMAC_MII_ADDR_WRITE	0x00000002	/* MII Write */
-#define GMAC_MII_ADDR_BUSY	0x00000001	/* MII Busy */
-/* GMAC FLOW CTRL defines */
-#define GMAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
-#define GMAC_FLOW_CTRL_PT_SHIFT	16
-#define GMAC_FLOW_CTRL_RFE	0x00000004	/* Rx Flow Control Enable */
-#define GMAC_FLOW_CTRL_TFE	0x00000002	/* Tx Flow Control Enable */
-#define GMAC_FLOW_CTRL_FCB_BPA	0x00000001	/* Flow Control Busy ... */
-
-/*--- DMA BLOCK defines ---*/
-/* DMA Bus Mode register defines */
-#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
-#define DMA_BUS_MODE_DA		0x00000002	/* Arbitration scheme */
-#define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
-#define DMA_BUS_MODE_DSL_SHIFT	2	/*   (in DWORDS)      */
-/* Programmable burst length (passed thorugh platform)*/
-#define DMA_BUS_MODE_PBL_MASK	0x00003f00	/* Programmable Burst Len */
-#define DMA_BUS_MODE_PBL_SHIFT	8
-
-enum rx_tx_priority_ratio {
-	double_ratio = 0x00004000,	/*2:1 */
-	triple_ratio = 0x00008000,	/*3:1 */
-	quadruple_ratio = 0x0000c000,	/*4:1 */
-};
-
-#define DMA_BUS_MODE_FB		0x00010000	/* Fixed burst */
-#define DMA_BUS_MODE_RPBL_MASK	0x003e0000	/* Rx-Programmable Burst Len */
-#define DMA_BUS_MODE_RPBL_SHIFT	17
-#define DMA_BUS_MODE_USP	0x00800000
-#define DMA_BUS_MODE_4PBL	0x01000000
-#define DMA_BUS_MODE_AAL	0x02000000
-
-/* DMA CRS Control and Status Register Mapping */
-#define DMA_HOST_TX_DESC	  0x00001048	/* Current Host Tx descriptor */
-#define DMA_HOST_RX_DESC	  0x0000104c	/* Current Host Rx descriptor */
-/*  DMA Bus Mode register defines */
-#define DMA_BUS_PR_RATIO_MASK	  0x0000c000	/* Rx/Tx priority ratio */
-#define DMA_BUS_PR_RATIO_SHIFT	  14
-#define DMA_BUS_FB	  	  0x00010000	/* Fixed Burst */
-
-/* DMA operation mode defines (start/stop tx/rx are placed in common header)*/
-#define DMA_CONTROL_DT		0x04000000 /* Disable Drop TCP/IP csum error */
-#define DMA_CONTROL_RSF		0x02000000 /* Receive Store and Forward */
-#define DMA_CONTROL_DFF		0x01000000 /* Disaable flushing */
-/* Theshold for Activating the FC */
-enum rfa {
-	act_full_minus_1 = 0x00800000,
-	act_full_minus_2 = 0x00800200,
-	act_full_minus_3 = 0x00800400,
-	act_full_minus_4 = 0x00800600,
-};
-/* Theshold for Deactivating the FC */
-enum rfd {
-	deac_full_minus_1 = 0x00400000,
-	deac_full_minus_2 = 0x00400800,
-	deac_full_minus_3 = 0x00401000,
-	deac_full_minus_4 = 0x00401800,
-};
-#define DMA_CONTROL_TSF		0x00200000 /* Transmit  Store and Forward */
-#define DMA_CONTROL_FTF		0x00100000 /* Flush transmit FIFO */
-
-enum ttc_control {
-	DMA_CONTROL_TTC_64 = 0x00000000,
-	DMA_CONTROL_TTC_128 = 0x00004000,
-	DMA_CONTROL_TTC_192 = 0x00008000,
-	DMA_CONTROL_TTC_256 = 0x0000c000,
-	DMA_CONTROL_TTC_40 = 0x00010000,
-	DMA_CONTROL_TTC_32 = 0x00014000,
-	DMA_CONTROL_TTC_24 = 0x00018000,
-	DMA_CONTROL_TTC_16 = 0x0001c000,
-};
-#define DMA_CONTROL_TC_TX_MASK	0xfffe3fff
-
-#define DMA_CONTROL_EFC		0x00000100
-#define DMA_CONTROL_FEF		0x00000080
-#define DMA_CONTROL_FUF		0x00000040
-
-enum rtc_control {
-	DMA_CONTROL_RTC_64 = 0x00000000,
-	DMA_CONTROL_RTC_32 = 0x00000008,
-	DMA_CONTROL_RTC_96 = 0x00000010,
-	DMA_CONTROL_RTC_128 = 0x00000018,
-};
-#define DMA_CONTROL_TC_RX_MASK	0xffffffe7
-
-#define DMA_CONTROL_OSF	0x00000004	/* Operate on second frame */
-
-/* MMC registers offset */
-#define GMAC_MMC_CTRL      0x100
-#define GMAC_MMC_RX_INTR   0x104
-#define GMAC_MMC_TX_INTR   0x108
-#define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
diff --git a/drivers/net/stmmac/mac100.c b/drivers/net/stmmac/mac100.c
deleted file mode 100644
index 625171b..0000000
--- a/drivers/net/stmmac/mac100.c
+++ /dev/null
@@ -1,517 +0,0 @@
-/*******************************************************************************
-  This is the driver for the MAC 10/100 on-chip Ethernet controller
-  currently tested on all the ST boards based on STb7109 and stx7200 SoCs.
-
-  DWC Ether MAC 10/100 Universal version 4.0 has been used for developing
-  this code.
-
-  Copyright (C) 2007-2009  STMicroelectronics Ltd
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
-*******************************************************************************/
-
-#include <linux/netdevice.h>
-#include <linux/crc32.h>
-#include <linux/mii.h>
-#include <linux/phy.h>
-
-#include "common.h"
-#include "mac100.h"
-
-#undef MAC100_DEBUG
-/*#define MAC100_DEBUG*/
-#ifdef MAC100_DEBUG
-#define DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define DBG(fmt, args...)  do { } while (0)
-#endif
-
-static void mac100_core_init(unsigned long ioaddr)
-{
-	u32 value = readl(ioaddr + MAC_CONTROL);
-
-	writel((value | MAC_CORE_INIT), ioaddr + MAC_CONTROL);
-
-#ifdef STMMAC_VLAN_TAG_USED
-	writel(ETH_P_8021Q, ioaddr + MAC_VLAN1);
-#endif
-	return;
-}
-
-static void mac100_dump_mac_regs(unsigned long ioaddr)
-{
-	pr_info("\t----------------------------------------------\n"
-	       "\t  MAC100 CSR (base addr = 0x%8x)\n"
-	       "\t----------------------------------------------\n",
-	       (unsigned int)ioaddr);
-	pr_info("\tcontrol reg (offset 0x%x): 0x%08x\n", MAC_CONTROL,
-	       readl(ioaddr + MAC_CONTROL));
-	pr_info("\taddr HI (offset 0x%x): 0x%08x\n ", MAC_ADDR_HIGH,
-	       readl(ioaddr + MAC_ADDR_HIGH));
-	pr_info("\taddr LO (offset 0x%x): 0x%08x\n", MAC_ADDR_LOW,
-	       readl(ioaddr + MAC_ADDR_LOW));
-	pr_info("\tmulticast hash HI (offset 0x%x): 0x%08x\n",
-			MAC_HASH_HIGH, readl(ioaddr + MAC_HASH_HIGH));
-	pr_info("\tmulticast hash LO (offset 0x%x): 0x%08x\n",
-			MAC_HASH_LOW, readl(ioaddr + MAC_HASH_LOW));
-	pr_info("\tflow control (offset 0x%x): 0x%08x\n",
-		MAC_FLOW_CTRL, readl(ioaddr + MAC_FLOW_CTRL));
-	pr_info("\tVLAN1 tag (offset 0x%x): 0x%08x\n", MAC_VLAN1,
-	       readl(ioaddr + MAC_VLAN1));
-	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
-	       readl(ioaddr + MAC_VLAN2));
-	pr_info("\n\tMAC management counter registers\n");
-	pr_info("\t MMC crtl (offset 0x%x): 0x%08x\n",
-	       MMC_CONTROL, readl(ioaddr + MMC_CONTROL));
-	pr_info("\t MMC High Interrupt (offset 0x%x): 0x%08x\n",
-	       MMC_HIGH_INTR, readl(ioaddr + MMC_HIGH_INTR));
-	pr_info("\t MMC Low Interrupt (offset 0x%x): 0x%08x\n",
-	       MMC_LOW_INTR, readl(ioaddr + MMC_LOW_INTR));
-	pr_info("\t MMC High Interrupt Mask (offset 0x%x): 0x%08x\n",
-	       MMC_HIGH_INTR_MASK, readl(ioaddr + MMC_HIGH_INTR_MASK));
-	pr_info("\t MMC Low Interrupt Mask (offset 0x%x): 0x%08x\n",
-	       MMC_LOW_INTR_MASK, readl(ioaddr + MMC_LOW_INTR_MASK));
-	return;
-}
-
-static int mac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
-			   u32 dma_rx)
-{
-	u32 value = readl(ioaddr + DMA_BUS_MODE);
-	/* DMA SW reset */
-	value |= DMA_BUS_MODE_SFT_RESET;
-	writel(value, ioaddr + DMA_BUS_MODE);
-	do {} while ((readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET));
-
-	/* Enable Application Access by writing to DMA CSR0 */
-	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
-	       ioaddr + DMA_BUS_MODE);
-
-	/* Mask interrupts by writing to CSR7 */
-	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
-
-	/* The base address of the RX/TX descriptor lists must be written into
-	 * DMA CSR3 and CSR4, respectively. */
-	writel(dma_tx, ioaddr + DMA_TX_BASE_ADDR);
-	writel(dma_rx, ioaddr + DMA_RCV_BASE_ADDR);
-
-	return 0;
-}
-
-/* Store and Forward capability is not used at all..
- * The transmit threshold can be programmed by
- * setting the TTC bits in the DMA control register.*/
-static void mac100_dma_operation_mode(unsigned long ioaddr, int txmode,
-				      int rxmode)
-{
-	u32 csr6 = readl(ioaddr + DMA_CONTROL);
-
-	if (txmode <= 32)
-		csr6 |= DMA_CONTROL_TTC_32;
-	else if (txmode <= 64)
-		csr6 |= DMA_CONTROL_TTC_64;
-	else
-		csr6 |= DMA_CONTROL_TTC_128;
-
-	writel(csr6, ioaddr + DMA_CONTROL);
-
-	return;
-}
-
-static void mac100_dump_dma_regs(unsigned long ioaddr)
-{
-	int i;
-
-	DBG(KERN_DEBUG "MAC100 DMA CSR \n");
-	for (i = 0; i < 9; i++)
-		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
-		       (DMA_BUS_MODE + i * 4),
-		       readl(ioaddr + DMA_BUS_MODE + i * 4));
-	DBG(KERN_DEBUG "\t CSR20 (offset 0x%x): 0x%08x\n",
-	    DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
-	DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
-	    DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
-	return;
-}
-
-/* DMA controller has two counters to track the number of
-   the receive missed frames. */
-static void mac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
-				     unsigned long ioaddr)
-{
-	struct net_device_stats *stats = (struct net_device_stats *)data;
-	u32 csr8 = readl(ioaddr + DMA_MISSED_FRAME_CTR);
-
-	if (unlikely(csr8)) {
-		if (csr8 & DMA_MISSED_FRAME_OVE) {
-			stats->rx_over_errors += 0x800;
-			x->rx_overflow_cntr += 0x800;
-		} else {
-			unsigned int ove_cntr;
-			ove_cntr = ((csr8 & DMA_MISSED_FRAME_OVE_CNTR) >> 17);
-			stats->rx_over_errors += ove_cntr;
-			x->rx_overflow_cntr += ove_cntr;
-		}
-
-		if (csr8 & DMA_MISSED_FRAME_OVE_M) {
-			stats->rx_missed_errors += 0xffff;
-			x->rx_missed_cntr += 0xffff;
-		} else {
-			unsigned int miss_f = (csr8 & DMA_MISSED_FRAME_M_CNTR);
-			stats->rx_missed_errors += miss_f;
-			x->rx_missed_cntr += miss_f;
-		}
-	}
-	return;
-}
-
-static int mac100_get_tx_frame_status(void *data, struct stmmac_extra_stats *x,
-				      struct dma_desc *p, unsigned long ioaddr)
-{
-	int ret = 0;
-	struct net_device_stats *stats = (struct net_device_stats *)data;
-
-	if (unlikely(p->des01.tx.error_summary)) {
-		if (unlikely(p->des01.tx.underflow_error)) {
-			x->tx_underflow++;
-			stats->tx_fifo_errors++;
-		}
-		if (unlikely(p->des01.tx.no_carrier)) {
-			x->tx_carrier++;
-			stats->tx_carrier_errors++;
-		}
-		if (unlikely(p->des01.tx.loss_carrier)) {
-			x->tx_losscarrier++;
-			stats->tx_carrier_errors++;
-		}
-		if (unlikely((p->des01.tx.excessive_deferral) ||
-			     (p->des01.tx.excessive_collisions) ||
-			     (p->des01.tx.late_collision)))
-			stats->collisions += p->des01.tx.collision_count;
-		ret = -1;
-	}
-	if (unlikely(p->des01.tx.heartbeat_fail)) {
-		x->tx_heartbeat++;
-		stats->tx_heartbeat_errors++;
-		ret = -1;
-	}
-	if (unlikely(p->des01.tx.deferred))
-		x->tx_deferred++;
-
-	return ret;
-}
-
-static int mac100_get_tx_len(struct dma_desc *p)
-{
-	return p->des01.tx.buffer1_size;
-}
-
-/* This function verifies if each incoming frame has some errors
- * and, if required, updates the multicast statistics.
- * In case of success, it returns csum_none becasue the device
- * is not able to compute the csum in HW. */
-static int mac100_get_rx_frame_status(void *data, struct stmmac_extra_stats *x,
-				      struct dma_desc *p)
-{
-	int ret = csum_none;
-	struct net_device_stats *stats = (struct net_device_stats *)data;
-
-	if (unlikely(p->des01.rx.last_descriptor == 0)) {
-		pr_warning("mac100 Error: Oversized Ethernet "
-			   "frame spanned multiple buffers\n");
-		stats->rx_length_errors++;
-		return discard_frame;
-	}
-
-	if (unlikely(p->des01.rx.error_summary)) {
-		if (unlikely(p->des01.rx.descriptor_error))
-			x->rx_desc++;
-		if (unlikely(p->des01.rx.partial_frame_error))
-			x->rx_partial++;
-		if (unlikely(p->des01.rx.run_frame))
-			x->rx_runt++;
-		if (unlikely(p->des01.rx.frame_too_long))
-			x->rx_toolong++;
-		if (unlikely(p->des01.rx.collision)) {
-			x->rx_collision++;
-			stats->collisions++;
-		}
-		if (unlikely(p->des01.rx.crc_error)) {
-			x->rx_crc++;
-			stats->rx_crc_errors++;
-		}
-		ret = discard_frame;
-	}
-	if (unlikely(p->des01.rx.dribbling))
-		ret = discard_frame;
-
-	if (unlikely(p->des01.rx.length_error)) {
-		x->rx_lenght++;
-		ret = discard_frame;
-	}
-	if (unlikely(p->des01.rx.mii_error)) {
-		x->rx_mii++;
-		ret = discard_frame;
-	}
-	if (p->des01.rx.multicast_frame) {
-		x->rx_multicast++;
-		stats->multicast++;
-	}
-	return ret;
-}
-
-static void mac100_irq_status(unsigned long ioaddr)
-{
-	return;
-}
-
-static void mac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
-			  unsigned int reg_n)
-{
-	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
-}
-
-static void mac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
-			  unsigned int reg_n)
-{
-	stmmac_get_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
-}
-
-static void mac100_set_filter(struct net_device *dev)
-{
-	unsigned long ioaddr = dev->base_addr;
-	u32 value = readl(ioaddr + MAC_CONTROL);
-
-	if (dev->flags & IFF_PROMISC) {
-		value |= MAC_CONTROL_PR;
-		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_IF | MAC_CONTROL_HO |
-			   MAC_CONTROL_HP);
-	} else if ((dev->mc_count > HASH_TABLE_SIZE)
-		   || (dev->flags & IFF_ALLMULTI)) {
-		value |= MAC_CONTROL_PM;
-		value &= ~(MAC_CONTROL_PR | MAC_CONTROL_IF | MAC_CONTROL_HO);
-		writel(0xffffffff, ioaddr + MAC_HASH_HIGH);
-		writel(0xffffffff, ioaddr + MAC_HASH_LOW);
-	} else if (dev->mc_count == 0) {	/* no multicast */
-		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF |
-			   MAC_CONTROL_HO | MAC_CONTROL_HP);
-	} else {
-		int i;
-		u32 mc_filter[2];
-		struct dev_mc_list *mclist;
-
-		/* Perfect filter mode for physical address and Hash
-		   filter for multicast */
-		value |= MAC_CONTROL_HP;
-		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF
-			   | MAC_CONTROL_HO);
-
-		memset(mc_filter, 0, sizeof(mc_filter));
-		for (i = 0, mclist = dev->mc_list;
-		     mclist && i < dev->mc_count; i++, mclist = mclist->next) {
-			/* The upper 6 bits of the calculated CRC are used to
-			 * index the contens of the hash table */
-			int bit_nr =
-			    ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
-			/* The most significant bit determines the register to
-			 * use (H/L) while the other 5 bits determine the bit
-			 * within the register. */
-			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
-		}
-		writel(mc_filter[0], ioaddr + MAC_HASH_LOW);
-		writel(mc_filter[1], ioaddr + MAC_HASH_HIGH);
-	}
-
-	writel(value, ioaddr + MAC_CONTROL);
-
-	DBG(KERN_INFO "%s: CTRL reg: 0x%08x Hash regs: "
-	    "HI 0x%08x, LO 0x%08x\n",
-	    __func__, readl(ioaddr + MAC_CONTROL),
-	    readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
-	return;
-}
-
-static void mac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
-			     unsigned int fc, unsigned int pause_time)
-{
-	unsigned int flow = MAC_FLOW_CTRL_ENABLE;
-
-	if (duplex)
-		flow |= (pause_time << MAC_FLOW_CTRL_PT_SHIFT);
-	writel(flow, ioaddr + MAC_FLOW_CTRL);
-
-	return;
-}
-
-/* No PMT module supported in our SoC  for the Ethernet Controller. */
-static void mac100_pmt(unsigned long ioaddr, unsigned long mode)
-{
-	return;
-}
-
-static void mac100_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-				int disable_rx_ic)
-{
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.rx.own = 1;
-		p->des01.rx.buffer1_size = BUF_SIZE_2KiB - 1;
-		if (i == ring_size - 1)
-			p->des01.rx.end_ring = 1;
-		if (disable_rx_ic)
-			p->des01.rx.disable_ic = 1;
-		p++;
-	}
-	return;
-}
-
-static void mac100_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
-{
-	int i;
-	for (i = 0; i < ring_size; i++) {
-		p->des01.tx.own = 0;
-		if (i == ring_size - 1)
-			p->des01.tx.end_ring = 1;
-		p++;
-	}
-	return;
-}
-
-static int mac100_get_tx_owner(struct dma_desc *p)
-{
-	return p->des01.tx.own;
-}
-
-static int mac100_get_rx_owner(struct dma_desc *p)
-{
-	return p->des01.rx.own;
-}
-
-static void mac100_set_tx_owner(struct dma_desc *p)
-{
-	p->des01.tx.own = 1;
-}
-
-static void mac100_set_rx_owner(struct dma_desc *p)
-{
-	p->des01.rx.own = 1;
-}
-
-static int mac100_get_tx_ls(struct dma_desc *p)
-{
-	return p->des01.tx.last_segment;
-}
-
-static void mac100_release_tx_desc(struct dma_desc *p)
-{
-	int ter = p->des01.tx.end_ring;
-
-	/* clean field used within the xmit */
-	p->des01.tx.first_segment = 0;
-	p->des01.tx.last_segment = 0;
-	p->des01.tx.buffer1_size = 0;
-
-	/* clean status reported */
-	p->des01.tx.error_summary = 0;
-	p->des01.tx.underflow_error = 0;
-	p->des01.tx.no_carrier = 0;
-	p->des01.tx.loss_carrier = 0;
-	p->des01.tx.excessive_deferral = 0;
-	p->des01.tx.excessive_collisions = 0;
-	p->des01.tx.late_collision = 0;
-	p->des01.tx.heartbeat_fail = 0;
-	p->des01.tx.deferred = 0;
-
-	/* set termination field */
-	p->des01.tx.end_ring = ter;
-
-	return;
-}
-
-static void mac100_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				   int csum_flag)
-{
-	p->des01.tx.first_segment = is_fs;
-	p->des01.tx.buffer1_size = len;
-}
-
-static void mac100_clear_tx_ic(struct dma_desc *p)
-{
-	p->des01.tx.interrupt = 0;
-}
-
-static void mac100_close_tx_desc(struct dma_desc *p)
-{
-	p->des01.tx.last_segment = 1;
-	p->des01.tx.interrupt = 1;
-}
-
-static int mac100_get_rx_frame_len(struct dma_desc *p)
-{
-	return p->des01.rx.frame_length;
-}
-
-struct stmmac_ops mac100_driver = {
-	.core_init = mac100_core_init,
-	.dump_mac_regs = mac100_dump_mac_regs,
-	.dma_init = mac100_dma_init,
-	.dump_dma_regs = mac100_dump_dma_regs,
-	.dma_mode = mac100_dma_operation_mode,
-	.dma_diagnostic_fr = mac100_dma_diagnostic_fr,
-	.tx_status = mac100_get_tx_frame_status,
-	.rx_status = mac100_get_rx_frame_status,
-	.get_tx_len = mac100_get_tx_len,
-	.set_filter = mac100_set_filter,
-	.flow_ctrl = mac100_flow_ctrl,
-	.pmt = mac100_pmt,
-	.init_rx_desc = mac100_init_rx_desc,
-	.init_tx_desc = mac100_init_tx_desc,
-	.get_tx_owner = mac100_get_tx_owner,
-	.get_rx_owner = mac100_get_rx_owner,
-	.release_tx_desc = mac100_release_tx_desc,
-	.prepare_tx_desc = mac100_prepare_tx_desc,
-	.clear_tx_ic = mac100_clear_tx_ic,
-	.close_tx_desc = mac100_close_tx_desc,
-	.get_tx_ls = mac100_get_tx_ls,
-	.set_tx_owner = mac100_set_tx_owner,
-	.set_rx_owner = mac100_set_rx_owner,
-	.get_rx_frame_len = mac100_get_rx_frame_len,
-	.host_irq_status = mac100_irq_status,
-	.set_umac_addr = mac100_set_umac_addr,
-	.get_umac_addr = mac100_get_umac_addr,
-};
-
-struct mac_device_info *mac100_setup(unsigned long ioaddr)
-{
-	struct mac_device_info *mac;
-
-	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
-
-	pr_info("\tMAC 10/100\n");
-
-	mac->ops = &mac100_driver;
-	mac->hw.pmt = PMT_NOT_SUPPORTED;
-	mac->hw.link.port = MAC_CONTROL_PS;
-	mac->hw.link.duplex = MAC_CONTROL_F;
-	mac->hw.link.speed = 0;
-	mac->hw.mii.addr = MAC_MII_ADDR;
-	mac->hw.mii.data = MAC_MII_DATA;
-
-	return mac;
-}
diff --git a/drivers/net/stmmac/mac100.h b/drivers/net/stmmac/mac100.h
deleted file mode 100644
index 0f8f110..0000000
--- a/drivers/net/stmmac/mac100.h
+++ /dev/null
@@ -1,116 +0,0 @@
-/*******************************************************************************
-  MAC 10/100 Header File
-
-  Copyright (C) 2007-2009  STMicroelectronics Ltd
-
-  This program is free software; you can redistribute it and/or modify it
-  under the terms and conditions of the GNU General Public License,
-  version 2, as published by the Free Software Foundation.
-
-  This program is distributed in the hope it will be useful, but WITHOUT
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
-  more details.
-
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
-  The full GNU General Public License is included in this distribution in
-  the file called "COPYING".
-
-  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
-*******************************************************************************/
-
-/*----------------------------------------------------------------------------
- *	 			MAC BLOCK defines
- *---------------------------------------------------------------------------*/
-/* MAC CSR offset */
-#define MAC_CONTROL	0x00000000	/* MAC Control */
-#define MAC_ADDR_HIGH	0x00000004	/* MAC Address High */
-#define MAC_ADDR_LOW	0x00000008	/* MAC Address Low */
-#define MAC_HASH_HIGH	0x0000000c	/* Multicast Hash Table High */
-#define MAC_HASH_LOW	0x00000010	/* Multicast Hash Table Low */
-#define MAC_MII_ADDR	0x00000014	/* MII Address */
-#define MAC_MII_DATA	0x00000018	/* MII Data */
-#define MAC_FLOW_CTRL	0x0000001c	/* Flow Control */
-#define MAC_VLAN1	0x00000020	/* VLAN1 Tag */
-#define MAC_VLAN2	0x00000024	/* VLAN2 Tag */
-
-/* MAC CTRL defines */
-#define MAC_CONTROL_RA	0x80000000	/* Receive All Mode */
-#define MAC_CONTROL_BLE	0x40000000	/* Endian Mode */
-#define MAC_CONTROL_HBD	0x10000000	/* Heartbeat Disable */
-#define MAC_CONTROL_PS	0x08000000	/* Port Select */
-#define MAC_CONTROL_DRO	0x00800000	/* Disable Receive Own */
-#define MAC_CONTROL_EXT_LOOPBACK 0x00400000	/* Reserved (ext loopback?) */
-#define MAC_CONTROL_OM	0x00200000	/* Loopback Operating Mode */
-#define MAC_CONTROL_F	0x00100000	/* Full Duplex Mode */
-#define MAC_CONTROL_PM	0x00080000	/* Pass All Multicast */
-#define MAC_CONTROL_PR	0x00040000	/* Promiscuous Mode */
-#define MAC_CONTROL_IF	0x00020000	/* Inverse Filtering */
-#define MAC_CONTROL_PB	0x00010000	/* Pass Bad Frames */
-#define MAC_CONTROL_HO	0x00008000	/* Hash Only Filtering Mode */
-#define MAC_CONTROL_HP	0x00002000	/* Hash/Perfect Filtering Mode */
-#define MAC_CONTROL_LCC	0x00001000	/* Late Collision Control */
-#define MAC_CONTROL_DBF	0x00000800	/* Disable Broadcast Frames */
-#define MAC_CONTROL_DRTY	0x00000400	/* Disable Retry */
-#define MAC_CONTROL_ASTP	0x00000100	/* Automatic Pad Stripping */
-#define MAC_CONTROL_BOLMT_10	0x00000000	/* Back Off Limit 10 */
-#define MAC_CONTROL_BOLMT_8	0x00000040	/* Back Off Limit 8 */
-#define MAC_CONTROL_BOLMT_4	0x00000080	/* Back Off Limit 4 */
-#define MAC_CONTROL_BOLMT_1	0x000000c0	/* Back Off Limit 1 */
-#define MAC_CONTROL_DC		0x00000020	/* Deferral Check */
-#define MAC_CONTROL_TE		0x00000008	/* Transmitter Enable */
-#define MAC_CONTROL_RE		0x00000004	/* Receiver Enable */
-
-#define MAC_CORE_INIT (MAC_CONTROL_HBD | MAC_CONTROL_ASTP)
-
-/* MAC FLOW CTRL defines */
-#define MAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
-#define MAC_FLOW_CTRL_PT_SHIFT	16
-#define MAC_FLOW_CTRL_PASS	0x00000004	/* Pass Control Frames */
-#define MAC_FLOW_CTRL_ENABLE	0x00000002	/* Flow Control Enable */
-#define MAC_FLOW_CTRL_PAUSE	0x00000001	/* Flow Control Busy ... */
-
-/* MII ADDR  defines */
-#define MAC_MII_ADDR_WRITE	0x00000002	/* MII Write */
-#define MAC_MII_ADDR_BUSY	0x00000001	/* MII Busy */
-
-/*----------------------------------------------------------------------------
- * 				DMA BLOCK defines
- *---------------------------------------------------------------------------*/
-
-/* DMA Bus Mode register defines */
-#define DMA_BUS_MODE_DBO	0x00100000	/* Descriptor Byte Ordering */
-#define DMA_BUS_MODE_BLE	0x00000080	/* Big Endian/Little Endian */
-#define DMA_BUS_MODE_PBL_MASK	0x00003f00	/* Programmable Burst Len */
-#define DMA_BUS_MODE_PBL_SHIFT	8
-#define DMA_BUS_MODE_DSL_MASK	0x0000007c	/* Descriptor Skip Length */
-#define DMA_BUS_MODE_DSL_SHIFT	2	/*   (in DWORDS)      */
-#define DMA_BUS_MODE_BAR_BUS	0x00000002	/* Bar-Bus Arbitration */
-#define DMA_BUS_MODE_SFT_RESET	0x00000001	/* Software Reset */
-#define DMA_BUS_MODE_DEFAULT	0x00000000
-
-/* DMA Control register defines */
-#define DMA_CONTROL_SF		0x00200000	/* Store And Forward */
-
-/* Transmit Threshold Control */
-enum ttc_control {
-	DMA_CONTROL_TTC_DEFAULT = 0x00000000,	/* Threshold is 32 DWORDS */
-	DMA_CONTROL_TTC_64 = 0x00004000,	/* Threshold is 64 DWORDS */
-	DMA_CONTROL_TTC_128 = 0x00008000,	/* Threshold is 128 DWORDS */
-	DMA_CONTROL_TTC_256 = 0x0000c000,	/* Threshold is 256 DWORDS */
-	DMA_CONTROL_TTC_18 = 0x00400000,	/* Threshold is 18 DWORDS */
-	DMA_CONTROL_TTC_24 = 0x00404000,	/* Threshold is 24 DWORDS */
-	DMA_CONTROL_TTC_32 = 0x00408000,	/* Threshold is 32 DWORDS */
-	DMA_CONTROL_TTC_40 = 0x0040c000,	/* Threshold is 40 DWORDS */
-	DMA_CONTROL_SE = 0x00000008,	/* Stop On Empty */
-	DMA_CONTROL_OSF = 0x00000004,	/* Operate On 2nd Frame */
-};
-
-/* STMAC110 DMA Missed Frame Counter register defines */
-#define DMA_MISSED_FRAME_OVE	0x10000000	/* FIFO Overflow Overflow */
-#define DMA_MISSED_FRAME_OVE_CNTR 0x0ffe0000	/* Overflow Frame Counter */
-#define DMA_MISSED_FRAME_OVE_M	0x00010000	/* Missed Frame Overflow */
-#define DMA_MISSED_FRAME_M_CNTR	0x0000ffff	/* Missed Frame Couinter */
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 6d2eae3..c2b7ee4 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -20,7 +20,8 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#define DRV_MODULE_VERSION	"Oct_09"
+#define DRV_MODULE_VERSION	"Dec_09"
+#include <linux/stmmac.h>
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define STMMAC_VLAN_TAG_USED
@@ -57,7 +58,7 @@ struct stmmac_priv {
 	int rx_csum;
 	unsigned int dma_buf_sz;
 	struct device *device;
-	struct mac_device_info *mac_type;
+	struct mac_device_info *hw;
 
 	struct stmmac_extra_stats xstats;
 	struct napi_struct napi;
@@ -69,6 +70,7 @@ struct stmmac_priv {
 	int phy_mask;
 	int (*phy_reset) (void *priv);
 	void (*fix_mac_speed) (void *priv, unsigned int speed);
+	void (*bus_setup)(unsigned long ioaddr);
 	void *bsp_priv;
 
 	int phy_irq;
@@ -96,3 +98,25 @@ struct stmmac_priv {
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
+
+#ifdef CONFIG_STM_DRIVERS
+#include <linux/stm/pad.h>
+static inline int stmmac_claim_resource(struct platform_device *pdev)
+{
+	int ret = 0;
+	struct plat_stmmacenet_data *plat_dat = pdev->dev.platform_data;
+
+	/* Pad routing setup */
+	if (IS_ERR(devm_stm_pad_claim(&pdev->dev, plat_dat->pad_config,
+			dev_name(&pdev->dev)))) {
+		printk(KERN_ERR "%s: Failed to request pads!\n", __func__);
+		ret = -ENODEV;
+	}
+	return ret;
+}
+#else
+static inline int stmmac_claim_resource(struct platform_device *pdev)
+{
+	return 0;
+}
+#endif
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 694ebe6..2421284 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -28,6 +28,7 @@
 #include <linux/phy.h>
 
 #include "stmmac.h"
+#include "dwmac_dma.h"
 
 #define REG_SPACE_SIZE	0x1054
 #define MAC100_ETHTOOL_NAME	"st_mac100"
@@ -268,7 +269,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		}
 	} else {
 		unsigned long ioaddr = netdev->base_addr;
-		priv->mac_type->ops->flow_ctrl(ioaddr, phy->duplex,
+		priv->hw->mac->flow_ctrl(ioaddr, phy->duplex,
 					       priv->flow_ctrl, priv->pause);
 	}
 	spin_unlock(&priv->lock);
@@ -283,8 +284,8 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 	int i;
 
 	/* Update HW stats if supported */
-	priv->mac_type->ops->dma_diagnostic_fr(&dev->stats, &priv->xstats,
-					       ioaddr);
+	priv->hw->dma->dma_diagnostic_fr(&dev->stats,
+		(void *) &priv->xstats, ioaddr);
 
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 9542995..d9cad02 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -32,7 +32,6 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
 #include <linux/ip.h>
@@ -45,7 +44,6 @@
 #include <linux/phy.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
-#include <linux/stm/soc.h>
 #include "stmmac.h"
 
 #define STMMAC_RESOURCE_NAME	"stmmaceth"
@@ -226,40 +224,41 @@ static void stmmac_adjust_link(struct net_device *dev)
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
 			if (!(phydev->duplex))
-				ctrl &= ~priv->mac_type->hw.link.duplex;
+				ctrl &= ~priv->hw->link.duplex;
 			else
-				ctrl |= priv->mac_type->hw.link.duplex;
+				ctrl |= priv->hw->link.duplex;
 			priv->oldduplex = phydev->duplex;
 		}
 		/* Flow Control operation */
 		if (phydev->pause)
-			priv->mac_type->ops->flow_ctrl(ioaddr, phydev->duplex,
-						       fc, pause_time);
+			priv->hw->mac->flow_ctrl(ioaddr,
+					phydev->duplex, fc, pause_time);
 
 		if (phydev->speed != priv->speed) {
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
 				if (likely(priv->is_gmac))
-					ctrl &= ~priv->mac_type->hw.link.port;
+					ctrl &= ~priv->hw->link.port;
 				break;
 			case 100:
 			case 10:
 				if (priv->is_gmac) {
-					ctrl |= priv->mac_type->hw.link.port;
+					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
 						ctrl |=
-						    priv->mac_type->hw.link.
+						    priv->hw->link.
 						    speed;
 					} else {
 						ctrl &=
-						    ~(priv->mac_type->hw.
+						    ~(priv->hw->
 						      link.speed);
 					}
 				} else {
-					ctrl &= ~priv->mac_type->hw.link.port;
+					ctrl &= ~priv->hw->link.port;
 				}
-				priv->fix_mac_speed(priv->bsp_priv,
+				if (likely(priv->fix_mac_speed))
+					priv->fix_mac_speed(priv->bsp_priv,
 						    phydev->speed);
 				break;
 			default:
@@ -418,6 +417,11 @@ static void init_dma_desc_rings(struct net_device *dev)
 	unsigned int bfsize = priv->dma_buf_sz;
 	int buff2_needed = 0, dis_ic = 0;
 
+#ifdef CONFIG_STMMAC_TIMER
+	if (likely(priv->tm->enable))
+		dis_ic = 1;
+#endif
+
 	/* Set the Buffer size according to the MTU;
 	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
 	 */
@@ -432,11 +436,6 @@ static void init_dma_desc_rings(struct net_device *dev)
 	else
 		bfsize = DMA_BUFFER_SIZE;
 
-#ifdef CONFIG_STMMAC_TIMER
-	/* Disable interrupts on completion for the reception if timer is on */
-	if (likely(priv->tm->enable))
-		dis_ic = 1;
-#endif
 	/* If the MTU exceeds 8k so use the second buffer in the chain */
 	if (bfsize >= BUF_SIZE_8KiB)
 		buff2_needed = 1;
@@ -508,8 +507,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	priv->cur_tx = 0;
 
 	/* Clear the Rx/Tx descriptors */
-	priv->mac_type->ops->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
-	priv->mac_type->ops->init_tx_desc(priv->dma_tx, txsize);
+	priv->hw->desc->init_rx_desc(priv->dma_rx, rxsize, dis_ic);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, txsize);
 
 	if (netif_msg_hw(priv)) {
 		pr_info("RX descriptor ring:\n");
@@ -544,7 +543,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 			struct dma_desc *p = priv->dma_tx + i;
 			if (p->des2)
 				dma_unmap_single(priv->device, p->des2,
-				 priv->mac_type->ops->get_tx_len(p),
+				 priv->hw->desc->get_tx_len(p),
 				 DMA_TO_DEVICE);
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
@@ -575,50 +574,6 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
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
@@ -629,18 +584,18 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
 	if (!priv->is_gmac) {
 		/* MAC 10/100 */
-		priv->mac_type->ops->dma_mode(priv->dev->base_addr, tc, 0);
+		priv->hw->dma->dma_mode(priv->dev->base_addr, tc, 0);
 		priv->tx_coe = NO_HW_CSUM;
 	} else {
 		if ((priv->dev->mtu <= ETH_DATA_LEN) && (tx_coe)) {
-			priv->mac_type->ops->dma_mode(priv->dev->base_addr,
-						      SF_DMA_MODE, SF_DMA_MODE);
+			priv->hw->dma->dma_mode(priv->dev->base_addr,
+						SF_DMA_MODE, SF_DMA_MODE);
 			tc = SF_DMA_MODE;
 			priv->tx_coe = HW_CSUM;
 		} else {
 			/* Checksum computation is performed in software. */
-			priv->mac_type->ops->dma_mode(priv->dev->base_addr, tc,
-						      SF_DMA_MODE);
+			priv->hw->dma->dma_mode(priv->dev->base_addr, tc,
+						SF_DMA_MODE);
 			priv->tx_coe = NO_HW_CSUM;
 		}
 	}
@@ -649,88 +604,6 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
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
@@ -748,16 +621,15 @@ static void stmmac_tx(struct stmmac_priv *priv)
 		struct dma_desc *p = priv->dma_tx + entry;
 
 		/* Check if the descriptor is owned by the DMA. */
-		if (priv->mac_type->ops->get_tx_owner(p))
+		if (priv->hw->desc->get_tx_owner(p))
 			break;
 
 		/* Verify tx error by looking at the last segment */
-		last = priv->mac_type->ops->get_tx_ls(p);
+		last = priv->hw->desc->get_tx_ls(p);
 		if (likely(last)) {
 			int tx_error =
-			    priv->mac_type->ops->tx_status(&priv->dev->stats,
-							   &priv->xstats,
-							   p, ioaddr);
+			    priv->hw->desc->tx_status(&priv->dev->stats,
+						      &priv->xstats, p, ioaddr);
 			if (likely(tx_error == 0)) {
 				priv->dev->stats.tx_packets++;
 				priv->xstats.tx_pkt_n++;
@@ -769,7 +641,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 		if (likely(p->des2))
 			dma_unmap_single(priv->device, p->des2,
-					 priv->mac_type->ops->get_tx_len(p),
+					 priv->hw->desc->get_tx_len(p),
 					 DMA_TO_DEVICE);
 		if (unlikely(p->des3))
 			p->des3 = 0;
@@ -790,7 +662,7 @@ static void stmmac_tx(struct stmmac_priv *priv)
 			priv->tx_skbuff[entry] = NULL;
 		}
 
-		priv->mac_type->ops->release_tx_desc(p);
+		priv->hw->desc->release_tx_desc(p);
 
 		entry = (++priv->dirty_tx) % txsize;
 	}
@@ -814,7 +686,7 @@ static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 		priv->tm->timer_start(tmrate);
 	else
 #endif
-	writel(DMA_INTR_DEFAULT_MASK, priv->dev->base_addr + DMA_INTR_ENA);
+		priv->hw->dma->enable_dma_irq(priv->dev->base_addr);
 }
 
 static inline void stmmac_disable_irq(struct stmmac_priv *priv)
@@ -824,7 +696,7 @@ static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 		priv->tm->timer_stop();
 	else
 #endif
-	writel(0, priv->dev->base_addr + DMA_INTR_ENA);
+		priv->hw->dma->disable_dma_irq(priv->dev->base_addr);
 }
 
 static int stmmac_has_work(struct stmmac_priv *priv)
@@ -832,7 +704,7 @@ static int stmmac_has_work(struct stmmac_priv *priv)
 	unsigned int has_work = 0;
 	int rxret, tx_work = 0;
 
-	rxret = priv->mac_type->ops->get_rx_owner(priv->dma_rx +
+	rxret = priv->hw->desc->get_rx_owner(priv->dma_rx +
 		(priv->cur_rx % priv->dma_rx_size));
 
 	if (priv->dirty_tx != priv->cur_tx)
@@ -883,12 +755,12 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 {
 	netif_stop_queue(priv->dev);
 
-	stmmac_dma_stop_tx(priv->dev->base_addr);
+	priv->hw->dma->stop_tx(priv->dev->base_addr);
 	dma_free_tx_skbufs(priv);
-	priv->mac_type->ops->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
+	priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
-	stmmac_dma_start_tx(priv->dev->base_addr);
+	priv->hw->dma->start_tx(priv->dev->base_addr);
 
 	priv->dev->stats.tx_errors++;
 	netif_wake_queue(priv->dev);
@@ -896,96 +768,27 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
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
-			if (unlikely(tc != SF_DMA_MODE)
-			    && (tc <= 256)) {
-				/* Try to bump up the threshold */
-				tc += 64;
-				priv->mac_type->ops->dma_mode(ioaddr, tc,
-					      SF_DMA_MODE);
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
@@ -1041,9 +844,9 @@ static int stmmac_open(struct net_device *dev)
 	priv->tm->freq = tmrate;
 
 	/* Test if the external timer can be actually used.
-	 * In case of failure continue without timer. */
+	 * In case of failure continue with no timer. */
 	if (unlikely((stmmac_open_ext_timer(dev, priv->tm)) < 0)) {
-		pr_warning("stmmaceth: cannot attach the external timer.\n");
+		pr_warning("stmmaceth: cannot attach the external timer\n");
 		tmrate = 0;
 		priv->tm->freq = 0;
 		priv->tm->timer_start = stmmac_no_timer_started;
@@ -1059,7 +862,7 @@ static int stmmac_open(struct net_device *dev)
 	init_dma_desc_rings(dev);
 
 	/* DMA initialization and SW reset */
-	if (unlikely(priv->mac_type->ops->dma_init(ioaddr,
+	if (unlikely(priv->hw->dma->init(ioaddr,
 		priv->pbl, priv->dma_tx_phy, priv->dma_rx_phy) < 0)) {
 
 		pr_err("%s: DMA initialization failed\n", __func__);
@@ -1067,9 +870,12 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 	/* Copy the MAC addr into the HW  */
-	priv->mac_type->ops->set_umac_addr(ioaddr, dev->dev_addr, 0);
+	priv->hw->mac->set_umac_addr(ioaddr, dev->dev_addr, 0);
+	/* If required, perform hw setup of the bus. */
+	if (priv->bus_setup)
+		priv->bus_setup(ioaddr);
 	/* Initialize the MAC Core */
-	priv->mac_type->ops->core_init(ioaddr);
+	priv->hw->mac->core_init(ioaddr);
 
 	priv->shutdown = 0;
 
@@ -1090,16 +896,16 @@ static int stmmac_open(struct net_device *dev)
 
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
-	stmmac_dma_start_tx(ioaddr);
-	stmmac_dma_start_rx(ioaddr);
+	priv->hw->dma->start_tx(ioaddr);
+	priv->hw->dma->start_rx(ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
 #endif
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
-		priv->mac_type->ops->dump_mac_regs(ioaddr);
-		priv->mac_type->ops->dump_dma_regs(ioaddr);
+		priv->hw->mac->dump_regs(ioaddr);
+		priv->hw->dma->dump_regs(ioaddr);
 	}
 
 	if (priv->phydev)
@@ -1143,8 +949,8 @@ static int stmmac_release(struct net_device *dev)
 	free_irq(dev->irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
-	stmmac_dma_stop_tx(dev->base_addr);
-	stmmac_dma_stop_rx(dev->base_addr);
+	priv->hw->dma->stop_tx(dev->base_addr);
+	priv->hw->dma->stop_rx(dev->base_addr);
 
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
@@ -1215,8 +1021,8 @@ static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					    BUF_SIZE_8KiB, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->mac_type->ops->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
-						     csum_insertion);
+		priv->hw->desc->prepare_tx_desc(desc, 1, BUF_SIZE_8KiB,
+						csum_insertion);
 
 		entry = (++priv->cur_tx) % txsize;
 		desc = priv->dma_tx + entry;
@@ -1225,16 +1031,16 @@ static unsigned int stmmac_handle_jumbo_frames(struct sk_buff *skb,
 					skb->data + BUF_SIZE_8KiB,
 					buf2_size, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->mac_type->ops->prepare_tx_desc(desc, 0,
-						     buf2_size, csum_insertion);
-		priv->mac_type->ops->set_tx_owner(desc);
+		priv->hw->desc->prepare_tx_desc(desc, 0, buf2_size,
+						csum_insertion);
+		priv->hw->desc->set_tx_owner(desc);
 		priv->tx_skbuff[entry] = NULL;
 	} else {
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
 		desc->des3 = desc->des2 + BUF_SIZE_4KiB;
-		priv->mac_type->ops->prepare_tx_desc(desc, 1, nopaged_len,
-						     csum_insertion);
+		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
+						csum_insertion);
 	}
 	return entry;
 }
@@ -1302,7 +1108,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		unsigned int nopaged_len = skb_headlen(skb);
 		desc->des2 = dma_map_single(priv->device, skb->data,
 					nopaged_len, DMA_TO_DEVICE);
-		priv->mac_type->ops->prepare_tx_desc(desc, 1, nopaged_len,
+		priv->hw->desc->prepare_tx_desc(desc, 1, nopaged_len,
 						     csum_insertion);
 	}
 
@@ -1318,21 +1124,22 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 					  frag->page_offset,
 					  len, DMA_TO_DEVICE);
 		priv->tx_skbuff[entry] = NULL;
-		priv->mac_type->ops->prepare_tx_desc(desc, 0, len,
+		priv->hw->desc->prepare_tx_desc(desc, 0, len,
 						     csum_insertion);
-		priv->mac_type->ops->set_tx_owner(desc);
+		priv->hw->desc->set_tx_owner(desc);
 	}
 
 	/* Interrupt on completition only for the latest segment */
-	priv->mac_type->ops->close_tx_desc(desc);
+	priv->hw->desc->close_tx_desc(desc);
 
 #ifdef CONFIG_STMMAC_TIMER
 	/* Clean IC while using timer */
 	if (likely(priv->tm->enable))
-		priv->mac_type->ops->clear_tx_ic(desc);
+		priv->hw->desc->clear_tx_ic(desc);
 #endif
+
 	/* To avoid raise condition */
-	priv->mac_type->ops->set_tx_owner(first);
+	priv->hw->desc->set_tx_owner(first);
 
 	priv->cur_tx++;
 
@@ -1354,8 +1161,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->stats.tx_bytes += skb->len;
 
-	/* CSR1 enables the transmit DMA to check for new descriptor */
-	writel(1, dev->base_addr + DMA_XMT_POLL_DEMAND);
+	priv->hw->dma->enable_dma_transmission(dev->base_addr);
 
 	return NETDEV_TX_OK;
 }
@@ -1392,7 +1198,7 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 			}
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
-		priv->mac_type->ops->set_rx_owner(p + entry);
+		priv->hw->desc->set_rx_owner(p + entry);
 	}
 	return;
 }
@@ -1413,7 +1219,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	}
 #endif
 	count = 0;
-	while (!priv->mac_type->ops->get_rx_owner(p)) {
+	while (!priv->hw->desc->get_rx_owner(p)) {
 		int status;
 
 		if (count >= limit)
@@ -1426,15 +1232,15 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 		prefetch(p_next);
 
 		/* read the status of the incoming frame */
-		status = (priv->mac_type->ops->rx_status(&priv->dev->stats,
-							 &priv->xstats, p));
+		status = (priv->hw->desc->rx_status(&priv->dev->stats,
+						    &priv->xstats, p));
 		if (unlikely(status == discard_frame))
 			priv->dev->stats.rx_errors++;
 		else {
 			struct sk_buff *skb;
 			/* Length should omit the CRC */
 			int frame_len =
-			    priv->mac_type->ops->get_rx_frame_len(p) - 4;
+			    priv->hw->desc->get_rx_frame_len(p) - 4;
 
 #ifdef STMMAC_RX_DEBUG
 			if (frame_len > ETH_FRAME_LEN)
@@ -1570,7 +1376,7 @@ static void stmmac_multicast_list(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	spin_lock(&priv->lock);
-	priv->mac_type->ops->set_filter(dev);
+	priv->hw->mac->set_filter(dev);
 	spin_unlock(&priv->lock);
 	return;
 }
@@ -1623,10 +1429,10 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 
 	if (priv->is_gmac) {
 		unsigned long ioaddr = dev->base_addr;
-		/* To handle GMAC own interrupts */
-		priv->mac_type->ops->host_irq_status(ioaddr);
+		priv->hw->mac->host_irq_status(ioaddr);
 	}
-	stmmac_dma_interrupt(dev);
+
+	stmmac_dma_interrupt(priv);
 
 	return IRQ_HANDLED;
 }
@@ -1745,7 +1551,7 @@ static int stmmac_probe(struct net_device *dev)
 	netif_napi_add(dev, &priv->napi, stmmac_poll, 64);
 
 	/* Get the MAC address */
-	priv->mac_type->ops->get_umac_addr(dev->base_addr, dev->dev_addr, 0);
+	priv->hw->mac->get_umac_addr(dev->base_addr, dev->dev_addr, 0);
 
 	if (!is_valid_ether_addr(dev->dev_addr))
 		pr_warning("\tno valid MAC address;"
@@ -1787,9 +1593,9 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	if (!device)
 		return -ENOMEM;
 
-	priv->mac_type = device;
+	priv->hw = device;
 
-	priv->wolenabled = priv->mac_type->hw.pmt;	/* PMT supported */
+	priv->wolenabled = priv->hw->pmt;	/* PMT supported */
 	if (priv->wolenabled == PMT_SUPPORTED)
 		priv->wolopts = WAKE_MAGIC;		/* Magic Frame */
 
@@ -1798,8 +1604,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 static int stmmacphy_dvr_probe(struct platform_device *pdev)
 {
-	struct plat_stmmacphy_data *plat_dat;
-	plat_dat = (struct plat_stmmacphy_data *)((pdev->dev).platform_data);
+	struct plat_stmmacphy_data *plat_dat = pdev->dev.platform_data;
 
 	pr_debug("stmmacphy_dvr_probe: added phy for bus %d\n",
 	       plat_dat->bus_id);
@@ -1831,9 +1636,7 @@ static struct platform_driver stmmacphy_driver = {
 static int stmmac_associate_phy(struct device *dev, void *data)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)data;
-	struct plat_stmmacphy_data *plat_dat;
-
-	plat_dat = (struct plat_stmmacphy_data *)(dev->platform_data);
+	struct plat_stmmacphy_data *plat_dat = dev->platform_data;
 
 	DBG(probe, DEBUG, "%s: checking phy for bus %d\n", __func__,
 		plat_dat->bus_id);
@@ -1923,7 +1726,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->device = &(pdev->dev);
 	priv->dev = ndev;
-	plat_dat = (struct plat_stmmacenet_data *)((pdev->dev).platform_data);
+	plat_dat = pdev->dev.platform_data;
 	priv->bus_id = plat_dat->bus_id;
 	priv->pbl = plat_dat->pbl;	/* TLI */
 	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
@@ -1933,14 +1736,19 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	/* Set the I/O base addr */
 	ndev->base_addr = (unsigned long)addr;
 
+	/* Verify embedded resource for the platform */
+	ret = stmmac_claim_resource(pdev);
+	if (unlikely(ret < 0))
+		goto out;
+
 	/* MAC HW revice detection */
 	ret = stmmac_mac_device_setup(ndev);
-	if (ret < 0)
+	if (unlikely(ret < 0))
 		goto out;
 
 	/* Network Device Registration */
 	ret = stmmac_probe(ndev);
-	if (ret < 0)
+	if (unlikely(ret < 0))
 		goto out;
 
 	/* associate a PHY - it is provided by another platform bus */
@@ -1953,6 +1761,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	}
 
 	priv->fix_mac_speed = plat_dat->fix_mac_speed;
+	priv->bus_setup = plat_dat->bus_setup;
 	priv->bsp_priv = plat_dat->bsp_priv;
 
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
@@ -1987,12 +1796,13 @@ out:
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
@@ -2039,24 +1849,22 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 		napi_disable(&priv->napi);
 
 		/* Stop TX/RX DMA */
-		stmmac_dma_stop_tx(dev->base_addr);
-		stmmac_dma_stop_rx(dev->base_addr);
+		priv->hw->dma->stop_tx(dev->base_addr);
+		priv->hw->dma->stop_rx(dev->base_addr);
 		/* Clear the Rx/Tx descriptors */
-		priv->mac_type->ops->init_rx_desc(priv->dma_rx,
-						  priv->dma_rx_size, dis_ic);
-		priv->mac_type->ops->init_tx_desc(priv->dma_tx,
-						  priv->dma_tx_size);
+		priv->hw->desc->init_rx_desc(priv->dma_rx, priv->dma_rx_size,
+					     dis_ic);
+		priv->hw->desc->init_tx_desc(priv->dma_tx, priv->dma_tx_size);
 
 		stmmac_mac_disable_tx(dev->base_addr);
 
 		if (device_may_wakeup(&(pdev->dev))) {
 			/* Enable Power down mode by programming the PMT regs */
 			if (priv->wolenabled == PMT_SUPPORTED)
-				priv->mac_type->ops->pmt(dev->base_addr,
-							 priv->wolopts);
-		} else {
+				priv->hw->mac->pmt(dev->base_addr,
+						   priv->wolopts);
+		} else
 			stmmac_mac_disable_rx(dev->base_addr);
-		}
 	} else {
 		priv->shutdown = 1;
 		/* Although this can appear slightly redundant it actually
@@ -2094,15 +1902,15 @@ static int stmmac_resume(struct platform_device *pdev)
 	 * from another devices (e.g. serial console). */
 	if (device_may_wakeup(&(pdev->dev)))
 		if (priv->wolenabled == PMT_SUPPORTED)
-			priv->mac_type->ops->pmt(dev->base_addr, 0);
+			priv->hw->mac->pmt(dev->base_addr, 0);
 
 	netif_device_attach(dev);
 
 	/* Enable the MAC and DMA */
 	stmmac_mac_enable_rx(ioaddr);
 	stmmac_mac_enable_tx(ioaddr);
-	stmmac_dma_start_tx(ioaddr);
-	stmmac_dma_start_rx(ioaddr);
+	priv->hw->dma->start_tx(ioaddr);
+	priv->hw->dma->start_rx(ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm->timer_start(tmrate);
@@ -2205,6 +2013,6 @@ __setup("stmmaceth=", stmmac_cmdline_opt);
 module_init(stmmac_init_module);
 module_exit(stmmac_cleanup_module);
 
-MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet driver");
+MODULE_DESCRIPTION("Synopsys MAC 10/100/1000 Ethernet driver");
 MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/stmmac/stmmac_mdio.c
index 8498552..fffe1d0 100644
--- a/drivers/net/stmmac/stmmac_mdio.c
+++ b/drivers/net/stmmac/stmmac_mdio.c
@@ -24,7 +24,6 @@
   Maintainer: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#include <linux/netdevice.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
 
@@ -48,8 +47,8 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long ioaddr = ndev->base_addr;
-	unsigned int mii_address = priv->mac_type->hw.mii.addr;
-	unsigned int mii_data = priv->mac_type->hw.mii.data;
+	unsigned int mii_address = priv->hw->mii.addr;
+	unsigned int mii_data = priv->hw->mii.data;
 
 	int data;
 	u16 regValue = (((phyaddr << 11) & (0x0000F800)) |
@@ -80,8 +79,8 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long ioaddr = ndev->base_addr;
-	unsigned int mii_address = priv->mac_type->hw.mii.addr;
-	unsigned int mii_data = priv->mac_type->hw.mii.data;
+	unsigned int mii_address = priv->hw->mii.addr;
+	unsigned int mii_data = priv->hw->mii.data;
 
 	u16 value =
 	    (((phyaddr << 11) & (0x0000F800)) | ((phyreg << 6) & (0x000007C0)))
@@ -112,7 +111,7 @@ static int stmmac_mdio_reset(struct mii_bus *bus)
 	struct net_device *ndev = bus->priv;
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long ioaddr = ndev->base_addr;
-	unsigned int mii_address = priv->mac_type->hw.mii.addr;
+	unsigned int mii_address = priv->hw->mii.addr;
 
 	if (priv->phy_reset) {
 		pr_debug("stmmac_mdio_reset: calling phy_reset\n");
-- 
1.6.0.4

