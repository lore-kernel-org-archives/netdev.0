From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH 06/13] stmmac: add DMA support for GMAC 4.xx
Date: Fri, 25 Mar 2016 10:14:13 +0100
Message-ID: <1458897260-14104-7-git-send-email-alexandre.torgue@st.com>
References: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lars Persson <lars.persson@axis.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:63347 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752517AbcCYJO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 05:14:56 -0400
In-Reply-To: <1458897260-14104-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DMA behavior is linked to descriptor management:

-descriptor mechanism (Tx for example, but it is exactly the same for RX):
-useful registers:
-DMA_CH#_TxDesc_Ring_Len: length of transmit descriptor ring
-DMA_CH#_TxDesc_List_Address: start address of the ring
	-DMA_CH#_TxDesc_Tail_Pointer: address of the last
					      descriptor to send + 1.
	-DMA_CH#_TxDesc_Current_App_TxDesc: address of the current
						    descriptor

-The descriptor Tail Pointer register contains the pointer to the
 descriptor address (N). The base address and the current
 descriptor decide the address of the current descriptor that the
 DMA can process. The descriptors up to one location less than the
 one indicated by the descriptor tail pointer (N-1) are owned by
 the DMA. The DMA continues to process the descriptors until the
 following condition occurs:
 "current descriptor pointer == Descriptor Tail pointer"

Then the DMA goes into suspend mode. The application must perform
a write to descriptor tail pointer register and update the tail
pointer to have the following condition and to start a new transfer:
"current descriptor pointer < Descriptor tail pointer"

The DMA automatically wraps around the base address when the end
of ring is reached.

Up to 8 DMA could be use but currently we only use one (channel0)

Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index fa000fd..9398ace 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -3,7 +3,7 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
 	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o dwmac4_descs.o	\
-	      $(stmmac-y)
+	      dwmac4_dma.o dwmac4_lib.o $(stmmac-y)
 
 # Ordering matters. Generic driver must be last.
 obj-$(CONFIG_STMMAC_PLATFORM)	+= stmmac-platform.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index ea7eb0d..2a5126e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -41,6 +41,8 @@
 /* Synopsys Core versions */
 #define	DWMAC_CORE_3_40	0x34
 #define	DWMAC_CORE_3_50	0x35
+#define	DWMAC_CORE_4_00	0x40
+#define STMMAC_CHAN0	0	/* Always supported and default for all chips */
 
 #define DMA_TX_SIZE 512
 #define DMA_RX_SIZE 512
@@ -270,6 +272,7 @@ enum dma_irq_status {
 #define	CORE_PCS_ANE_COMPLETE		(1 << 5)
 #define	CORE_PCS_LINK_STATUS		(1 << 6)
 #define	CORE_RGMII_IRQ			(1 << 7)
+#define CORE_IRQ_MTL_RX_OVERFLOW	BIT(8)
 
 /* Physical Coding Sublayer */
 struct rgmii_adv {
@@ -301,8 +304,10 @@ struct dma_features {
 	/* 802.3az - Energy-Efficient Ethernet (EEE) */
 	unsigned int eee;
 	unsigned int av;
+	unsigned int tsoen;
 	/* TX and RX csum */
 	unsigned int tx_coe;
+	unsigned int rx_coe;
 	unsigned int rx_coe_type1;
 	unsigned int rx_coe_type2;
 	unsigned int rxfifo_over_2048;
@@ -425,6 +430,11 @@ struct stmmac_dma_ops {
 			       struct dma_features *dma_cap);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog) (void __iomem *ioaddr, u32 riwt);
+	void (*set_tx_ring_len)(void __iomem *ioaddr, u32 len);
+	void (*set_rx_ring_len)(void __iomem *ioaddr, u32 len);
+	void (*set_rx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
+	void (*set_tx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
+	void (*enable_tso)(void __iomem *ioaddr, bool en, u32 chan);
 };
 
 struct mac_device_info;
@@ -473,6 +483,7 @@ struct stmmac_hwtimestamp {
 };
 
 extern const struct stmmac_hwtimestamp stmmac_ptp;
+extern const struct stmmac_mode_ops dwmac4_ring_mode_ops;
 
 struct mac_link {
 	int port;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
new file mode 100644
index 0000000..116151c
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -0,0 +1,354 @@
+/*
+ * This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
+ * DWC Ether MAC version 4.xx  has been used for  developing this code.
+ *
+ * This contains the functions to handle the dma.
+ *
+ * Copyright (C) 2015  STMicroelectronics Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Alexandre Torgue <alexandre.torgue@st.com>
+ */
+
+#include <linux/io.h>
+#include "dwmac4.h"
+#include "dwmac4_dma.h"
+
+static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
+{
+	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
+	int i;
+
+	pr_info("dwmac4: Master AXI performs %s burst length\n",
+		(value & DMA_SYS_BUS_FB) ? "fixed" : "any");
+
+	if (axi->axi_lpi_en)
+		value |= DMA_AXI_EN_LPI;
+	if (axi->axi_xit_frm)
+		value |= DMA_AXI_LPI_XIT_FRM;
+
+	value |= (axi->axi_wr_osr_lmt & DMA_AXI_OSR_MAX) <<
+		 DMA_AXI_WR_OSR_LMT_SHIFT;
+
+	value |= (axi->axi_rd_osr_lmt & DMA_AXI_OSR_MAX) <<
+		 DMA_AXI_RD_OSR_LMT_SHIFT;
+
+	/* Depending on the UNDEF bit the Master AXI will perform any burst
+	 * length according to the BLEN programmed (by default all BLEN are
+	 * set).
+	 */
+	for (i = 0; i < AXI_BLEN; i++) {
+		switch (axi->axi_blen[i]) {
+		case 256:
+			value |= DMA_AXI_BLEN256;
+			break;
+		case 128:
+			value |= DMA_AXI_BLEN128;
+			break;
+		case 64:
+			value |= DMA_AXI_BLEN64;
+			break;
+		case 32:
+			value |= DMA_AXI_BLEN32;
+			break;
+		case 16:
+			value |= DMA_AXI_BLEN16;
+			break;
+		case 8:
+			value |= DMA_AXI_BLEN8;
+			break;
+		case 4:
+			value |= DMA_AXI_BLEN4;
+			break;
+		}
+	}
+
+	writel(value, ioaddr + DMA_SYS_BUS_MODE);
+}
+
+static void dwmac4_dma_init_channel(void __iomem *ioaddr, int pbl,
+				    u32 dma_tx_phy, u32 dma_rx_phy,
+				    u32 channel)
+{
+	u32 value;
+
+	/* set PBL for each channels. Currently we affect same configuration
+	 * on each channel
+	 */
+	value = readl(ioaddr + DMA_CHAN_CONTROL(channel));
+	value = value | DMA_BUS_MODE_PBL;
+	writel(value, ioaddr + DMA_CHAN_CONTROL(channel));
+
+	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(channel));
+	value = value | (pbl << DMA_BUS_MODE_PBL_SHIFT);
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(channel));
+
+	value = readl(ioaddr + DMA_CHAN_RX_CONTROL(channel));
+	value = value | (pbl << DMA_BUS_MODE_RPBL_SHIFT);
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(channel));
+
+	/* Mask interrupts by writing to CSR7 */
+	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr + DMA_CHAN_INTR_ENA(channel));
+
+	writel(dma_tx_phy, ioaddr + DMA_CHAN_TX_BASE_ADDR(channel));
+	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
+}
+
+static void dwmac4_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
+			    int aal, u32 dma_tx, u32 dma_rx, int atds)
+{
+	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
+	int i;
+
+	/* Set the Fixed burst mode */
+	if (fb)
+		value |= DMA_SYS_BUS_FB;
+
+	/* Mixed Burst has no effect when fb is set */
+	if (mb)
+		value |= DMA_SYS_BUS_MB;
+
+	if (aal)
+		value |= DMA_SYS_BUS_AAL;
+
+	writel(value, ioaddr + DMA_SYS_BUS_MODE);
+
+	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
+		dwmac4_dma_init_channel(ioaddr, pbl, dma_tx, dma_rx, i);
+}
+
+static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
+{
+	pr_debug(" Channel %d\n", channel);
+	pr_debug("\tDMA_CHAN_CONTROL, offset: 0x%x, val: 0x%x\n", 0,
+		 readl(ioaddr + DMA_CHAN_CONTROL(channel)));
+	pr_debug("\tDMA_CHAN_TX_CONTROL, offset: 0x%x, val: 0x%x\n", 0x4,
+		 readl(ioaddr + DMA_CHAN_TX_CONTROL(channel)));
+	pr_debug("\tDMA_CHAN_RX_CONTROL, offset: 0x%x, val: 0x%x\n", 0x8,
+		 readl(ioaddr + DMA_CHAN_RX_CONTROL(channel)));
+	pr_debug("\tDMA_CHAN_TX_BASE_ADDR, offset: 0x%x, val: 0x%x\n", 0x14,
+		 readl(ioaddr + DMA_CHAN_TX_BASE_ADDR(channel)));
+	pr_debug("\tDMA_CHAN_RX_BASE_ADDR, offset: 0x%x, val: 0x%x\n", 0x1c,
+		 readl(ioaddr + DMA_CHAN_RX_BASE_ADDR(channel)));
+	pr_debug("\tDMA_CHAN_TX_END_ADDR, offset: 0x%x, val: 0x%x\n", 0x20,
+		 readl(ioaddr + DMA_CHAN_TX_END_ADDR(channel)));
+	pr_debug("\tDMA_CHAN_RX_END_ADDR, offset: 0x%x, val: 0x%x\n", 0x28,
+		 readl(ioaddr + DMA_CHAN_RX_END_ADDR(channel)));
+	pr_debug("\tDMA_CHAN_TX_RING_LEN, offset: 0x%x, val: 0x%x\n", 0x2c,
+		 readl(ioaddr + DMA_CHAN_TX_RING_LEN(channel)));
+	pr_debug("\tDMA_CHAN_RX_RING_LEN, offset: 0x%x, val: 0x%x\n", 0x30,
+		 readl(ioaddr + DMA_CHAN_RX_RING_LEN(channel)));
+	pr_debug("\tDMA_CHAN_INTR_ENA, offset: 0x%x, val: 0x%x\n", 0x34,
+		 readl(ioaddr + DMA_CHAN_INTR_ENA(channel)));
+	pr_debug("\tDMA_CHAN_RX_WATCHDOG, offset: 0x%x, val: 0x%x\n", 0x38,
+		 readl(ioaddr + DMA_CHAN_RX_WATCHDOG(channel)));
+	pr_debug("\tDMA_CHAN_SLOT_CTRL_STATUS, offset: 0x%x, val: 0x%x\n", 0x3c,
+		 readl(ioaddr + DMA_CHAN_SLOT_CTRL_STATUS(channel)));
+	pr_debug("\tDMA_CHAN_CUR_TX_DESC, offset: 0x%x, val: 0x%x\n", 0x44,
+		 readl(ioaddr + DMA_CHAN_CUR_TX_DESC(channel)));
+	pr_debug("\tDMA_CHAN_CUR_RX_DESC, offset: 0x%x, val: 0x%x\n", 0x4c,
+		 readl(ioaddr + DMA_CHAN_CUR_RX_DESC(channel)));
+	pr_debug("\tDMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x%x, val: 0x%x\n", 0x54,
+		 readl(ioaddr + DMA_CHAN_CUR_TX_BUF_ADDR(channel)));
+	pr_debug("\tDMA_CHAN_CUR_RX_BUF_ADDR, offset: 0x%x, val: 0x%x\n", 0x5c,
+		 readl(ioaddr + DMA_CHAN_CUR_RX_BUF_ADDR(channel)));
+	pr_debug("\tDMA_CHAN_STATUS, offset: 0x%x, val: 0x%x\n", 0x60,
+		 readl(ioaddr + DMA_CHAN_STATUS(channel)));
+}
+
+static void dwmac4_dump_dma_regs(void __iomem *ioaddr)
+{
+	int i;
+
+	pr_debug(" GMAC4 DMA registers\n");
+
+	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
+		_dwmac4_dump_dma_regs(ioaddr, i);
+}
+
+static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+{
+	int i;
+
+	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
+		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(i));
+}
+
+static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
+				    int rxmode, u32 channel)
+{
+	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
+
+	/* Following code only done for channel 0, other channels not yet
+	 * supported.
+	 */
+	mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel));
+
+	if (txmode == SF_DMA_MODE) {
+		pr_debug("GMAC: enable TX store and forward mode\n");
+		/* Transmit COE type 2 cannot be done in cut-through mode. */
+		mtl_tx_op |= MTL_OP_MODE_TSF;
+	} else {
+		pr_debug("GMAC: disabling TX SF (threshold %d)\n", txmode);
+		mtl_tx_op &= ~MTL_OP_MODE_TSF;
+		mtl_tx_op &= MTL_OP_MODE_TTC_MASK;
+		/* Set the transmit threshold */
+		if (txmode <= 32)
+			mtl_tx_op |= MTL_OP_MODE_TTC_32;
+		else if (txmode <= 64)
+			mtl_tx_op |= MTL_OP_MODE_TTC_64;
+		else if (txmode <= 96)
+			mtl_tx_op |= MTL_OP_MODE_TTC_96;
+		else if (txmode <= 128)
+			mtl_tx_op |= MTL_OP_MODE_TTC_128;
+		else if (txmode <= 192)
+			mtl_tx_op |= MTL_OP_MODE_TTC_192;
+		else if (txmode <= 256)
+			mtl_tx_op |= MTL_OP_MODE_TTC_256;
+		else if (txmode <= 384)
+			mtl_tx_op |= MTL_OP_MODE_TTC_384;
+		else
+			mtl_tx_op |= MTL_OP_MODE_TTC_512;
+	}
+
+	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
+
+	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
+
+	if (rxmode == SF_DMA_MODE) {
+		pr_debug("GMAC: enable RX store and forward mode\n");
+		mtl_rx_op |= MTL_OP_MODE_RSF;
+	} else {
+		pr_debug("GMAC: disable RX SF mode (threshold %d)\n", rxmode);
+		mtl_rx_op &= ~MTL_OP_MODE_RSF;
+		mtl_rx_op &= MTL_OP_MODE_RTC_MASK;
+		if (rxmode <= 32)
+			mtl_rx_op |= MTL_OP_MODE_RTC_32;
+		else if (rxmode <= 64)
+			mtl_rx_op |= MTL_OP_MODE_RTC_64;
+		else if (rxmode <= 96)
+			mtl_rx_op |= MTL_OP_MODE_RTC_96;
+		else
+			mtl_rx_op |= MTL_OP_MODE_RTC_128;
+	}
+
+	writel(mtl_rx_op, ioaddr + MTL_CHAN_RX_OP_MODE(channel));
+
+	/* Enable MTL RX overflow */
+	mtl_rx_int = readl(ioaddr + MTL_CHAN_INT_CTRL(channel));
+	writel(mtl_rx_int | MTL_RX_OVERFLOW_INT_EN,
+	       ioaddr + MTL_CHAN_INT_CTRL(channel));
+}
+
+static void dwmac4_dma_operation_mode(void __iomem *ioaddr, int txmode,
+				      int rxmode, int rxfifosz)
+{
+	/* Only Channel 0 is actually configured and used */
+	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
+}
+
+static void dwmac4_get_hw_feature(void __iomem *ioaddr,
+				  struct dma_features *dma_cap)
+{
+	u32 hw_cap = readl(ioaddr + GMAC_HW_FEATURE0);
+
+	/*  MAC HW feature0 */
+	dma_cap->mbps_10_100 = (hw_cap & GMAC_HW_FEAT_MIISEL);
+	dma_cap->mbps_1000 = (hw_cap & GMAC_HW_FEAT_GMIISEL) >> 1;
+	dma_cap->half_duplex = (hw_cap & GMAC_HW_FEAT_HDSEL) >> 2;
+	dma_cap->hash_filter = (hw_cap & GMAC_HW_FEAT_VLHASH) >> 4;
+	dma_cap->multi_addr = (hw_cap & GMAC_HW_FEAT_ADDMAC) >> 18;
+	dma_cap->pcs = (hw_cap & GMAC_HW_FEAT_PCSSEL) >> 3;
+	dma_cap->sma_mdio = (hw_cap & GMAC_HW_FEAT_SMASEL) >> 5;
+	dma_cap->pmt_remote_wake_up = (hw_cap & GMAC_HW_FEAT_RWKSEL) >> 6;
+	dma_cap->pmt_magic_frame = (hw_cap & GMAC_HW_FEAT_MGKSEL) >> 7;
+	/* MMC */
+	dma_cap->rmon = (hw_cap & GMAC_HW_FEAT_MMCSEL) >> 8;
+	/* IEEE 1588-2008 */
+	dma_cap->atime_stamp = (hw_cap & GMAC_HW_FEAT_TSSEL) >> 12;
+	/* 802.3az - Energy-Efficient Ethernet (EEE) */
+	dma_cap->eee = (hw_cap & GMAC_HW_FEAT_EEESEL) >> 13;
+	/* TX and RX csum */
+	dma_cap->tx_coe = (hw_cap & GMAC_HW_FEAT_TXCOSEL) >> 14;
+	dma_cap->rx_coe =  (hw_cap & GMAC_HW_FEAT_RXCOESEL) >> 16;
+
+	/* MAC HW feature1 */
+	hw_cap = readl(ioaddr + GMAC_HW_FEATURE1);
+	dma_cap->av = (hw_cap & GMAC_HW_FEAT_AVSEL) >> 20;
+	dma_cap->tsoen = (hw_cap & GMAC_HW_TSOEN) >> 18;
+	/* MAC HW feature2 */
+	hw_cap = readl(ioaddr + GMAC_HW_FEATURE2);
+	/* TX and RX number of channels */
+	dma_cap->number_rx_channel =
+		((hw_cap & GMAC_HW_FEAT_RXCHCNT) >> 12) + 1;
+	dma_cap->number_tx_channel =
+		((hw_cap & GMAC_HW_FEAT_TXCHCNT) >> 18) + 1;
+
+	/* IEEE 1588-2002 */
+	dma_cap->time_stamp = 0;
+}
+
+/* Enable/disable TSO feature and set MSS */
+static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
+{
+	u32 value;
+
+	if (en) {
+		/* enable TSO */
+		value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
+		writel(value | DMA_CONTROL_TSE,
+		       ioaddr + DMA_CHAN_TX_CONTROL(chan));
+	} else {
+		/* enable TSO */
+		value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
+		writel(value & ~DMA_CONTROL_TSE,
+		       ioaddr + DMA_CHAN_TX_CONTROL(chan));
+	}
+}
+
+const struct stmmac_dma_ops dwmac4_dma_ops = {
+	.reset = dwmac4_dma_reset,
+	.init = dwmac4_dma_init,
+	.axi = dwmac4_dma_axi,
+	.dump_regs = dwmac4_dump_dma_regs,
+	.dma_mode = dwmac4_dma_operation_mode,
+	.enable_dma_irq = dwmac4_enable_dma_irq,
+	.disable_dma_irq = dwmac4_disable_dma_irq,
+	.start_tx = dwmac4_dma_start_tx,
+	.stop_tx = dwmac4_dma_stop_tx,
+	.start_rx = dwmac4_dma_start_rx,
+	.stop_rx = dwmac4_dma_stop_rx,
+	.dma_interrupt = dwmac4_dma_interrupt,
+	.get_hw_feature = dwmac4_get_hw_feature,
+	.rx_watchdog = dwmac4_rx_watchdog,
+	.set_rx_ring_len = dwmac4_set_rx_ring_len,
+	.set_tx_ring_len = dwmac4_set_tx_ring_len,
+	.set_rx_tail_ptr = dwmac4_set_rx_tail_ptr,
+	.set_tx_tail_ptr = dwmac4_set_tx_tail_ptr,
+	.enable_tso = dwmac4_enable_tso,
+};
+
+const struct stmmac_dma_ops dwmac410_dma_ops = {
+	.reset = dwmac4_dma_reset,
+	.init = dwmac4_dma_init,
+	.axi = dwmac4_dma_axi,
+	.dump_regs = dwmac4_dump_dma_regs,
+	.dma_mode = dwmac4_dma_operation_mode,
+	.enable_dma_irq = dwmac410_enable_dma_irq,
+	.disable_dma_irq = dwmac4_disable_dma_irq,
+	.start_tx = dwmac4_dma_start_tx,
+	.stop_tx = dwmac4_dma_stop_tx,
+	.start_rx = dwmac4_dma_start_rx,
+	.stop_rx = dwmac4_dma_stop_rx,
+	.dma_interrupt = dwmac4_dma_interrupt,
+	.get_hw_feature = dwmac4_get_hw_feature,
+	.rx_watchdog = dwmac4_rx_watchdog,
+	.set_rx_ring_len = dwmac4_set_rx_ring_len,
+	.set_tx_ring_len = dwmac4_set_tx_ring_len,
+	.set_rx_tail_ptr = dwmac4_set_rx_tail_ptr,
+	.set_tx_tail_ptr = dwmac4_set_tx_tail_ptr,
+	.enable_tso = dwmac4_enable_tso,
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
new file mode 100644
index 0000000..1b06df7
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
@@ -0,0 +1,202 @@
+/*
+ * DWMAC4 DMA Header file.
+ *
+ *
+ * Copyright (C) 2007-2015  STMicroelectronics Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Alexandre Torgue <alexandre.torgue@st.com>
+ */
+
+#ifndef __DWMAC4_DMA_H__
+#define __DWMAC4_DMA_H__
+
+/* Define the max channel number used for tx (also rx).
+ * dwmac4 accepts up to 8 channels for TX (and also 8 channels for RX
+ */
+#define DMA_CHANNEL_NB_MAX		1
+
+#define DMA_BUS_MODE			0x00001000
+#define DMA_SYS_BUS_MODE		0x00001004
+#define DMA_STATUS			0x00001008
+#define DMA_DEBUG_STATUS_0		0x0000100c
+#define DMA_DEBUG_STATUS_1		0x00001010
+#define DMA_DEBUG_STATUS_2		0x00001014
+#define DMA_AXI_BUS_MODE		0x00001028
+
+/* DMA Bus Mode bitmap */
+#define DMA_BUS_MODE_SFT_RESET		BIT(0)
+
+/* DMA SYS Bus Mode bitmap */
+#define DMA_BUS_MODE_SPH		BIT(24)
+#define DMA_BUS_MODE_PBL		BIT(16)
+#define DMA_BUS_MODE_PBL_SHIFT		16
+#define DMA_BUS_MODE_RPBL_SHIFT		16
+#define DMA_BUS_MODE_MB			BIT(14)
+#define DMA_BUS_MODE_FB			BIT(0)
+
+/* DMA Interrupt top status */
+#define DMA_STATUS_MAC			BIT(17)
+#define DMA_STATUS_MTL			BIT(16)
+#define DMA_STATUS_CHAN7		BIT(7)
+#define DMA_STATUS_CHAN6		BIT(6)
+#define DMA_STATUS_CHAN5		BIT(5)
+#define DMA_STATUS_CHAN4		BIT(4)
+#define DMA_STATUS_CHAN3		BIT(3)
+#define DMA_STATUS_CHAN2		BIT(2)
+#define DMA_STATUS_CHAN1		BIT(1)
+#define DMA_STATUS_CHAN0		BIT(0)
+
+/* DMA debug status bitmap */
+#define DMA_DEBUG_STATUS_TS_MASK	0xf
+#define DMA_DEBUG_STATUS_RS_MASK	0xf
+
+/* DMA AXI bitmap */
+#define DMA_AXI_EN_LPI			BIT(31)
+#define DMA_AXI_LPI_XIT_FRM		BIT(30)
+#define DMA_AXI_WR_OSR_LMT		GENMASK(27, 24)
+#define DMA_AXI_WR_OSR_LMT_SHIFT	24
+#define DMA_AXI_RD_OSR_LMT		GENMASK(19, 16)
+#define DMA_AXI_RD_OSR_LMT_SHIFT	16
+
+#define DMA_AXI_OSR_MAX			0xf
+#define DMA_AXI_MAX_OSR_LIMIT ((DMA_AXI_OSR_MAX << DMA_AXI_WR_OSR_LMT_SHIFT) | \
+				(DMA_AXI_OSR_MAX << DMA_AXI_RD_OSR_LMT_SHIFT))
+
+#define DMA_SYS_BUS_MB			BIT(14)
+#define DMA_AXI_1KBBE			BIT(13)
+#define DMA_SYS_BUS_AAL			BIT(12)
+#define DMA_AXI_BLEN256			BIT(7)
+#define DMA_AXI_BLEN128			BIT(6)
+#define DMA_AXI_BLEN64			BIT(5)
+#define DMA_AXI_BLEN32			BIT(4)
+#define DMA_AXI_BLEN16			BIT(3)
+#define DMA_AXI_BLEN8			BIT(2)
+#define DMA_AXI_BLEN4			BIT(1)
+#define DMA_SYS_BUS_FB			BIT(0)
+
+#define DMA_BURST_LEN_DEFAULT		(DMA_AXI_BLEN256 | DMA_AXI_BLEN128 | \
+					DMA_AXI_BLEN64 | DMA_AXI_BLEN32 | \
+					DMA_AXI_BLEN16 | DMA_AXI_BLEN8 | \
+					DMA_AXI_BLEN4)
+
+#define DMA_AXI_BURST_LEN_MASK		0x000000FE
+
+/* Following DMA defines are chanels oriented */
+#define DMA_CHAN_BASE_ADDR		0x00001100
+#define DMA_CHAN_BASE_OFFSET		0x80
+#define DMA_CHANX_BASE_ADDR(x)		(DMA_CHAN_BASE_ADDR + \
+					(x * DMA_CHAN_BASE_OFFSET))
+#define DMA_CHAN_REG_NUMBER		17
+
+#define DMA_CHAN_CONTROL(x)		DMA_CHANX_BASE_ADDR(x)
+#define DMA_CHAN_TX_CONTROL(x)		(DMA_CHANX_BASE_ADDR(x) + 0x4)
+#define DMA_CHAN_RX_CONTROL(x)		(DMA_CHANX_BASE_ADDR(x) + 0x8)
+#define DMA_CHAN_TX_BASE_ADDR(x)	(DMA_CHANX_BASE_ADDR(x) + 0x14)
+#define DMA_CHAN_RX_BASE_ADDR(x)	(DMA_CHANX_BASE_ADDR(x) + 0x1c)
+#define DMA_CHAN_TX_END_ADDR(x)		(DMA_CHANX_BASE_ADDR(x) + 0x20)
+#define DMA_CHAN_RX_END_ADDR(x)		(DMA_CHANX_BASE_ADDR(x) + 0x28)
+#define DMA_CHAN_TX_RING_LEN(x)		(DMA_CHANX_BASE_ADDR(x) + 0x2c)
+#define DMA_CHAN_RX_RING_LEN(x)		(DMA_CHANX_BASE_ADDR(x) + 0x30)
+#define DMA_CHAN_INTR_ENA(x)		(DMA_CHANX_BASE_ADDR(x) + 0x34)
+#define DMA_CHAN_RX_WATCHDOG(x)		(DMA_CHANX_BASE_ADDR(x) + 0x38)
+#define DMA_CHAN_SLOT_CTRL_STATUS(x)	(DMA_CHANX_BASE_ADDR(x) + 0x3c)
+#define DMA_CHAN_CUR_TX_DESC(x)		(DMA_CHANX_BASE_ADDR(x) + 0x44)
+#define DMA_CHAN_CUR_RX_DESC(x)		(DMA_CHANX_BASE_ADDR(x) + 0x4c)
+#define DMA_CHAN_CUR_TX_BUF_ADDR(x)	(DMA_CHANX_BASE_ADDR(x) + 0x54)
+#define DMA_CHAN_CUR_RX_BUF_ADDR(x)	(DMA_CHANX_BASE_ADDR(x) + 0x5c)
+#define DMA_CHAN_STATUS(x)		(DMA_CHANX_BASE_ADDR(x) + 0x60)
+
+/* DMA Control X */
+#define DMA_CONTROL_MSS_MASK		GENMASK(13, 0)
+
+/* DMA Tx Channel X Control register defines */
+#define DMA_CONTROL_TSE			BIT(12)
+#define DMA_CONTROL_OSP			BIT(4)
+#define DMA_CONTROL_ST			BIT(0)
+
+/* DMA Rx Channel X Control register defines */
+#define DMA_CONTROL_SR			BIT(0)
+
+/* Interrupt status per channel */
+#define DMA_CHAN_STATUS_REB		GENMASK(21, 19)
+#define DMA_CHAN_STATUS_REB_SHIFT	19
+#define DMA_CHAN_STATUS_TEB		GENMASK(18, 16)
+#define DMA_CHAN_STATUS_TEB_SHIFT	16
+#define DMA_CHAN_STATUS_NIS		BIT(15)
+#define DMA_CHAN_STATUS_AIS		BIT(14)
+#define DMA_CHAN_STATUS_CDE		BIT(13)
+#define DMA_CHAN_STATUS_FBE		BIT(12)
+#define DMA_CHAN_STATUS_ERI		BIT(11)
+#define DMA_CHAN_STATUS_ETI		BIT(10)
+#define DMA_CHAN_STATUS_RWT		BIT(9)
+#define DMA_CHAN_STATUS_RPS		BIT(8)
+#define DMA_CHAN_STATUS_RBU		BIT(7)
+#define DMA_CHAN_STATUS_RI		BIT(6)
+#define DMA_CHAN_STATUS_TBU		BIT(2)
+#define DMA_CHAN_STATUS_TPS		BIT(1)
+#define DMA_CHAN_STATUS_TI		BIT(0)
+
+/* Interrupt enable bits per channel */
+#define DMA_CHAN_INTR_ENA_NIE		BIT(16)
+#define DMA_CHAN_INTR_ENA_AIE		BIT(15)
+#define DMA_CHAN_INTR_ENA_NIE_4_10	BIT(15)
+#define DMA_CHAN_INTR_ENA_AIE_4_10	BIT(14)
+#define DMA_CHAN_INTR_ENA_CDE		BIT(13)
+#define DMA_CHAN_INTR_ENA_FBE		BIT(12)
+#define DMA_CHAN_INTR_ENA_ERE		BIT(11)
+#define DMA_CHAN_INTR_ENA_ETE		BIT(10)
+#define DMA_CHAN_INTR_ENA_RWE		BIT(9)
+#define DMA_CHAN_INTR_ENA_RSE		BIT(8)
+#define DMA_CHAN_INTR_ENA_RBUE		BIT(7)
+#define DMA_CHAN_INTR_ENA_RIE		BIT(6)
+#define DMA_CHAN_INTR_ENA_TBUE		BIT(2)
+#define DMA_CHAN_INTR_ENA_TSE		BIT(1)
+#define DMA_CHAN_INTR_ENA_TIE		BIT(0)
+
+#define DMA_CHAN_INTR_NORMAL		(DMA_CHAN_INTR_ENA_NIE | \
+					 DMA_CHAN_INTR_ENA_RIE | \
+					 DMA_CHAN_INTR_ENA_TIE)
+
+#define DMA_CHAN_INTR_ABNORMAL		(DMA_CHAN_INTR_ENA_AIE | \
+					 DMA_CHAN_INTR_ENA_FBE)
+/* DMA default interrupt mask for 4.00 */
+#define DMA_CHAN_INTR_DEFAULT_MASK	(DMA_CHAN_INTR_NORMAL | \
+					 DMA_CHAN_INTR_ABNORMAL)
+
+#define DMA_CHAN_INTR_NORMAL_4_10	(DMA_CHAN_INTR_ENA_NIE_4_10 | \
+					 DMA_CHAN_INTR_ENA_RIE | \
+					 DMA_CHAN_INTR_ENA_TIE)
+
+#define DMA_CHAN_INTR_ABNORMAL_4_10	(DMA_CHAN_INTR_ENA_AIE_4_10 | \
+					 DMA_CHAN_INTR_ENA_FBE)
+/* DMA default interrupt mask for 4.10a */
+#define DMA_CHAN_INTR_DEFAULT_MASK_4_10	(DMA_CHAN_INTR_NORMAL_4_10 | \
+					 DMA_CHAN_INTR_ABNORMAL_4_10)
+
+/* channel 0 specific fields */
+#define DMA_CHAN0_DBG_STAT_TPS		GENMASK(15, 12)
+#define DMA_CHAN0_DBG_STAT_TPS_SHIFT	12
+#define DMA_CHAN0_DBG_STAT_RPS		GENMASK(11, 8)
+#define DMA_CHAN0_DBG_STAT_RPS_SHIFT	8
+
+int dwmac4_dma_reset(void __iomem *ioaddr);
+void dwmac4_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
+void dwmac4_enable_dma_irq(void __iomem *ioaddr);
+void dwmac410_enable_dma_irq(void __iomem *ioaddr);
+void dwmac4_disable_dma_irq(void __iomem *ioaddr);
+void dwmac4_dma_start_tx(void __iomem *ioaddr);
+void dwmac4_dma_stop_tx(void __iomem *ioaddr);
+void dwmac4_dma_start_rx(void __iomem *ioaddr);
+void dwmac4_dma_stop_rx(void __iomem *ioaddr);
+int dwmac4_dma_interrupt(void __iomem *ioaddr,
+			 struct stmmac_extra_stats *x);
+void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len);
+void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len);
+void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
+void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
+
+#endif /* __DWMAC4_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
new file mode 100644
index 0000000..c7326d5
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -0,0 +1,225 @@
+/*
+ * Copyright (C) 2007-2015  STMicroelectronics Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * Author: Alexandre Torgue <alexandre.torgue@st.com>
+ */
+
+#include <linux/io.h>
+#include <linux/delay.h>
+#include "common.h"
+#include "dwmac4_dma.h"
+#include "dwmac4.h"
+
+int dwmac4_dma_reset(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_BUS_MODE);
+	int limit;
+
+	/* DMA SW reset */
+	value |= DMA_BUS_MODE_SFT_RESET;
+	writel(value, ioaddr + DMA_BUS_MODE);
+	limit = 10;
+	while (limit--) {
+		if (!(readl(ioaddr + DMA_BUS_MODE) & DMA_BUS_MODE_SFT_RESET))
+			break;
+		mdelay(10);
+	}
+
+	if (limit < 0)
+		return -EBUSY;
+
+	return 0;
+}
+
+void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
+{
+	writel(tail_ptr, ioaddr + DMA_CHAN_RX_END_ADDR(0));
+}
+
+void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
+{
+	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(0));
+}
+
+void dwmac4_dma_start_tx(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+
+	value |= DMA_CONTROL_ST;
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+
+	value = readl(ioaddr + GMAC_CONFIG);
+	value |= GMAC_CONFIG_TE;
+	writel(value, ioaddr + GMAC_CONFIG);
+}
+
+void dwmac4_dma_stop_tx(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+
+	value &= ~DMA_CONTROL_ST;
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+
+	value = readl(ioaddr + GMAC_CONFIG);
+	value &= ~GMAC_CONFIG_TE;
+	writel(value, ioaddr + GMAC_CONFIG);
+}
+
+void dwmac4_dma_start_rx(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+
+	value |= DMA_CONTROL_SR;
+
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+
+	value = readl(ioaddr + GMAC_CONFIG);
+	value |= GMAC_CONFIG_RE;
+	writel(value, ioaddr + GMAC_CONFIG);
+}
+
+void dwmac4_dma_stop_rx(void __iomem *ioaddr)
+{
+	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+
+	value &= ~DMA_CONTROL_SR;
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+
+	value = readl(ioaddr + GMAC_CONFIG);
+	value &= ~GMAC_CONFIG_RE;
+	writel(value, ioaddr + GMAC_CONFIG);
+}
+
+void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len)
+{
+	writel(len, ioaddr + DMA_CHAN_TX_RING_LEN(STMMAC_CHAN0));
+}
+
+void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len)
+{
+	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(STMMAC_CHAN0));
+}
+
+void dwmac4_enable_dma_irq(void __iomem *ioaddr)
+{
+	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr +
+	       DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+}
+
+void dwmac410_enable_dma_irq(void __iomem *ioaddr)
+{
+	writel(DMA_CHAN_INTR_DEFAULT_MASK_4_10,
+	       ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+}
+
+void dwmac4_disable_dma_irq(void __iomem *ioaddr)
+{
+	writel(0, ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+}
+
+int dwmac4_dma_interrupt(void __iomem *ioaddr,
+			 struct stmmac_extra_stats *x)
+{
+	int ret = 0;
+
+	u32 intr_status = readl(ioaddr + DMA_CHAN_STATUS(0));
+
+	/* ABNORMAL interrupts */
+	if (unlikely(intr_status & DMA_CHAN_STATUS_AIS)) {
+		if (unlikely(intr_status & DMA_CHAN_STATUS_RBU))
+			x->rx_buf_unav_irq++;
+		if (unlikely(intr_status & DMA_CHAN_STATUS_RPS))
+			x->rx_process_stopped_irq++;
+		if (unlikely(intr_status & DMA_CHAN_STATUS_RWT))
+			x->rx_watchdog_irq++;
+		if (unlikely(intr_status & DMA_CHAN_STATUS_ETI))
+			x->tx_early_irq++;
+		if (unlikely(intr_status & DMA_CHAN_STATUS_TPS)) {
+			x->tx_process_stopped_irq++;
+			ret = tx_hard_error;
+		}
+		if (unlikely(intr_status & DMA_CHAN_STATUS_FBE)) {
+			x->fatal_bus_error_irq++;
+			ret = tx_hard_error;
+		}
+	}
+	/* TX/RX NORMAL interrupts */
+	if (likely(intr_status & DMA_CHAN_STATUS_NIS)) {
+		x->normal_irq_n++;
+		if (likely(intr_status & DMA_CHAN_STATUS_RI)) {
+			u32 value;
+
+			value = readl(ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+			/* to schedule NAPI on real RIE event. */
+			if (likely(value & DMA_CHAN_INTR_ENA_RIE)) {
+				x->rx_normal_irq_n++;
+				ret |= handle_rx;
+			}
+		}
+		if (likely(intr_status & DMA_CHAN_STATUS_TI)) {
+			x->tx_normal_irq_n++;
+			ret |= handle_tx;
+		}
+		if (unlikely(intr_status & DMA_CHAN_STATUS_ERI))
+			x->rx_early_irq++;
+	}
+
+	/* Clear the interrupt by writing a logic 1 to the chanX interrupt
+	 * status [21-0] expect reserved bits [5-3]
+	 */
+	writel((intr_status & 0x3fffc7),
+	       ioaddr + DMA_CHAN_STATUS(STMMAC_CHAN0));
+
+	return ret;
+}
+
+void stmmac_dwmac4_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
+				unsigned int high, unsigned int low)
+{
+	unsigned long data;
+
+	data = (addr[5] << 8) | addr[4];
+	/* For MAC Addr registers se have to set the Address Enable (AE)
+	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
+	 * is RO.
+	 */
+	data |= (STMMAC_CHAN0 << GMAC_HI_DCS_SHIFT);
+	writel(data | GMAC_HI_REG_AE, ioaddr + high);
+	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
+	writel(data, ioaddr + low);
+}
+
+/* Enable disable MAC RX/TX */
+void stmmac_dwmac4_set_mac(void __iomem *ioaddr, bool enable)
+{
+	u32 value = readl(ioaddr + GMAC_CONFIG);
+
+	if (enable)
+		value |= GMAC_CONFIG_RE | GMAC_CONFIG_TE;
+	else
+		value &= ~(GMAC_CONFIG_TE | GMAC_CONFIG_RE);
+
+	writel(value, ioaddr + GMAC_CONFIG);
+}
+
+void stmmac_dwmac4_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
+				unsigned int high, unsigned int low)
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
+}
-- 
1.9.1
