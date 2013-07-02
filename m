From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git] stmmac: dity-up and rework the driver debug levels
Date: Tue,  2 Jul 2013 14:12:36 +0200
Message-ID: <1372767156-12619-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:57274 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750769Ab3GBMN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 08:13:56 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9C9EA157
	for <netdev@vger.kernel.org>; Tue,  2 Jul 2013 12:13:49 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E06DE4869
	for <netdev@vger.kernel.org>; Tue,  2 Jul 2013 12:13:22 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior this patch, the internal debugging was based on ifdef
and also some printk were useless because many info are exposed
via ethtool.
This patch remove all the ifdef defines and now we only use
netif_msg_XXX levels.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   10 --
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   57 +++------
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   10 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    4 -
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    8 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |   72 ++++--------
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   95 ++++-----------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  124 ++++++--------------
 9 files changed, 117 insertions(+), 267 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 7788fbe..9911b93 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -38,16 +38,6 @@
 #include "descs.h"
 #include "mmc.h"
 
-#undef CHIP_DEBUG_PRINT
-/* Turn-on extra printk debug for MAC core, dma and descriptors */
-/* #define CHIP_DEBUG_PRINT */
-
-#ifdef CHIP_DEBUG_PRINT
-#define CHIP_DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define CHIP_DBG(fmt, args...)  do { } while (0)
-#endif
-
 /* Synopsys Core versions */
 #define	DWMAC_CORE_3_40	0x34
 #define	DWMAC_CORE_3_50	0x35
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 7e05e8d..cdd9268 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -91,8 +91,8 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 	unsigned int value = 0;
 	unsigned int perfect_addr_number;
 
-	CHIP_DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-		 __func__, netdev_mc_count(dev), netdev_uc_count(dev));
+	pr_debug("%s: # mcasts %d, # unicast %d\n", __func__,
+		 netdev_mc_count(dev), netdev_uc_count(dev));
 
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
@@ -152,7 +152,7 @@ static void dwmac1000_set_filter(struct net_device *dev, int id)
 #endif
 	writel(value, ioaddr + GMAC_FRAME_FILTER);
 
-	CHIP_DBG(KERN_INFO "\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
+	pr_debug("\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
 		 readl(ioaddr + GMAC_FRAME_FILTER),
 		 readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
 }
@@ -162,18 +162,18 @@ static void dwmac1000_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
 {
 	unsigned int flow = 0;
 
-	CHIP_DBG(KERN_DEBUG "GMAC Flow-Control:\n");
+	pr_debug("GMAC Flow-Control:\n");
 	if (fc & FLOW_RX) {
-		CHIP_DBG(KERN_DEBUG "\tReceive Flow-Control ON\n");
+		pr_debug("\tReceive Flow-Control ON\n");
 		flow |= GMAC_FLOW_CTRL_RFE;
 	}
 	if (fc & FLOW_TX) {
-		CHIP_DBG(KERN_DEBUG "\tTransmit Flow-Control ON\n");
+		pr_debug("\tTransmit Flow-Control ON\n");
 		flow |= GMAC_FLOW_CTRL_TFE;
 	}
 
 	if (duplex) {
-		CHIP_DBG(KERN_DEBUG "\tduplex mode: PAUSE %d\n", pause_time);
+		pr_debug("\tduplex mode: PAUSE %d\n", pause_time);
 		flow |= (pause_time << GMAC_FLOW_CTRL_PT_SHIFT);
 	}
 
@@ -185,11 +185,11 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 	unsigned int pmt = 0;
 
 	if (mode & WAKE_MAGIC) {
-		CHIP_DBG(KERN_DEBUG "GMAC: WOL Magic frame\n");
+		pr_debug("GMAC: WOL Magic frame\n");
 		pmt |= power_down | magic_pkt_en;
 	}
 	if (mode & WAKE_UCAST) {
-		CHIP_DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
+		pr_debug("GMAC: WOL on global unicast\n");
 		pmt |= global_unicast;
 	}
 
@@ -203,23 +203,13 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 	int ret = 0;
 
 	/* Not used events (e.g. MMC interrupts) are not handled. */
-	if ((intr_status & mmc_tx_irq)) {
-		CHIP_DBG(KERN_INFO "GMAC: MMC tx interrupt: 0x%08x\n",
-			 readl(ioaddr + GMAC_MMC_TX_INTR));
+	if ((intr_status & mmc_tx_irq))
 		x->mmc_tx_irq_n++;
-	}
-	if (unlikely(intr_status & mmc_rx_irq)) {
-		CHIP_DBG(KERN_INFO "GMAC: MMC rx interrupt: 0x%08x\n",
-			 readl(ioaddr + GMAC_MMC_RX_INTR));
+	if (unlikely(intr_status & mmc_rx_irq))
 		x->mmc_rx_irq_n++;
-	}
-	if (unlikely(intr_status & mmc_rx_csum_offload_irq)) {
-		CHIP_DBG(KERN_INFO "GMAC: MMC rx csum offload: 0x%08x\n",
-			 readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
+	if (unlikely(intr_status & mmc_rx_csum_offload_irq))
 		x->mmc_rx_csum_offload_irq_n++;
-	}
 	if (unlikely(intr_status & pmt_irq)) {
-		CHIP_DBG(KERN_INFO "GMAC: received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT status reg */
 		readl(ioaddr + GMAC_PMT);
 		x->irq_receive_pmt_irq_n++;
@@ -229,32 +219,22 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 		/* Clean LPI interrupt by reading the Reg 12 */
 		ret = readl(ioaddr + LPI_CTRL_STATUS);
 
-		if (ret & LPI_CTRL_STATUS_TLPIEN) {
-			CHIP_DBG(KERN_INFO "GMAC TX entered in LPI\n");
+		if (ret & LPI_CTRL_STATUS_TLPIEN)
 			x->irq_tx_path_in_lpi_mode_n++;
-		}
-		if (ret & LPI_CTRL_STATUS_TLPIEX) {
-			CHIP_DBG(KERN_INFO "GMAC TX exit from LPI\n");
+		if (ret & LPI_CTRL_STATUS_TLPIEX)
 			x->irq_tx_path_exit_lpi_mode_n++;
-		}
-		if (ret & LPI_CTRL_STATUS_RLPIEN) {
-			CHIP_DBG(KERN_INFO "GMAC RX entered in LPI\n");
+		if (ret & LPI_CTRL_STATUS_RLPIEN)
 			x->irq_rx_path_in_lpi_mode_n++;
-		}
-		if (ret & LPI_CTRL_STATUS_RLPIEX) {
-			CHIP_DBG(KERN_INFO "GMAC RX exit from LPI\n");
+		if (ret & LPI_CTRL_STATUS_RLPIEX)
 			x->irq_rx_path_exit_lpi_mode_n++;
-		}
 	}
 
 	if ((intr_status & pcs_ane_irq) || (intr_status & pcs_link_irq)) {
-		CHIP_DBG(KERN_INFO "GMAC PCS ANE IRQ\n");
 		readl(ioaddr + GMAC_AN_STATUS);
 		x->irq_pcs_ane_n++;
 	}
 	if (intr_status & rgmii_irq) {
 		u32 status = readl(ioaddr + GMAC_S_R_GMII);
-		CHIP_DBG(KERN_INFO "GMAC RGMII/SGMII interrupt\n");
 		x->irq_rgmii_n++;
 
 		/* Save and dump the link status. */
@@ -271,11 +251,12 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 				x->pcs_speed = SPEED_10;
 
 			x->pcs_link = 1;
-			pr_debug("Link is Up - %d/%s\n", (int)x->pcs_speed,
+			pr_debug("%s: Link is Up - %d/%s\n", __func__,
+				 (int)x->pcs_speed,
 				 x->pcs_duplex ? "Full" : "Half");
 		} else {
 			x->pcs_link = 0;
-			pr_debug("Link is Down\n");
+			pr_debug("%s: Link is Down\n", __func__);
 		}
 	}
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index 2c431b6..0c2058a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -116,7 +116,7 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
 	if (txmode == SF_DMA_MODE) {
-		CHIP_DBG(KERN_DEBUG "GMAC: enable TX store and forward mode\n");
+		pr_debug("GMAC: enable TX store and forward mode\n");
 		/* Transmit COE type 2 cannot be done in cut-through mode. */
 		csr6 |= DMA_CONTROL_TSF;
 		/* Operating on second frame increase the performance
@@ -124,8 +124,7 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 		 */
 		csr6 |= DMA_CONTROL_OSF;
 	} else {
-		CHIP_DBG(KERN_DEBUG "GMAC: disabling TX SF (threshold %d)\n",
-			 txmode);
+		pr_debug("GMAC: disabling TX SF (threshold %d)\n", txmode);
 		csr6 &= ~DMA_CONTROL_TSF;
 		csr6 &= DMA_CONTROL_TC_TX_MASK;
 		/* Set the transmit threshold */
@@ -142,11 +141,10 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	}
 
 	if (rxmode == SF_DMA_MODE) {
-		CHIP_DBG(KERN_DEBUG "GMAC: enable RX store and forward mode\n");
+		pr_debug("GMAC: enable RX store and forward mode\n");
 		csr6 |= DMA_CONTROL_RSF;
 	} else {
-		CHIP_DBG(KERN_DEBUG "GMAC: disable RX SF mode (threshold %d)\n",
-			 rxmode);
+		pr_debug("GMAC: disable RX SF mode (threshold %d)\n", rxmode);
 		csr6 &= ~DMA_CONTROL_RSF;
 		csr6 &= DMA_CONTROL_TC_RX_MASK;
 		if (rxmode <= 32)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 007bb2b..5857d67 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -135,10 +135,6 @@ static void dwmac100_set_filter(struct net_device *dev, int id)
 	}
 
 	writel(value, ioaddr + MAC_CONTROL);
-
-	CHIP_DBG(KERN_INFO "%s: Filter: 0x%08x Hash: HI 0x%08x, LO 0x%08x\n",
-		 __func__, readl(ioaddr + MAC_CONTROL),
-		 readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
 }
 
 static void dwmac100_flow_ctrl(void __iomem *ioaddr, unsigned int duplex,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index 67551c1..7d1dce9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -90,14 +90,14 @@ static void dwmac100_dump_dma_regs(void __iomem *ioaddr)
 {
 	int i;
 
-	CHIP_DBG(KERN_DEBUG "DWMAC 100 DMA CSR\n");
+	pr_debug("DWMAC 100 DMA CSR\n");
 	for (i = 0; i < 9; i++)
 		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
 			 (DMA_BUS_MODE + i * 4),
 			 readl(ioaddr + DMA_BUS_MODE + i * 4));
-	CHIP_DBG(KERN_DEBUG "\t CSR20 (offset 0x%x): 0x%08x\n",
-		 DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
-	CHIP_DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
+
+	pr_debug("\tCSR20 (0x%x): 0x%08x, CSR21 (0x%x): 0x%08x\n",
+		 DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR),
 		 DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 491d7e9..484e3cf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -24,13 +24,6 @@
 #include "common.h"
 #include "dwmac_dma.h"
 
-#undef DWMAC_DMA_DEBUG
-#ifdef DWMAC_DMA_DEBUG
-#define DWMAC_LIB_DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define DWMAC_LIB_DBG(fmt, args...)  do { } while (0)
-#endif
-
 #define GMAC_HI_REG_AE		0x80000000
 
 /* CSR1 enables the transmit DMA to check for new descriptor */
@@ -85,24 +78,24 @@ static void show_tx_process_state(unsigned int status)
 
 	switch (state) {
 	case 0:
-		pr_info("- TX (Stopped): Reset or Stop command\n");
+		pr_debug("- TX (Stopped): Reset or Stop command\n");
 		break;
 	case 1:
-		pr_info("- TX (Running):Fetching the Tx desc\n");
+		pr_debug("- TX (Running):Fetching the Tx desc\n");
 		break;
 	case 2:
-		pr_info("- TX (Running): Waiting for end of tx\n");
+		pr_debug("- TX (Running): Waiting for end of tx\n");
 		break;
 	case 3:
-		pr_info("- TX (Running): Reading the data "
+		pr_debug("- TX (Running): Reading the data "
 		       "and queuing the data into the Tx buf\n");
 		break;
 	case 6:
-		pr_info("- TX (Suspended): Tx Buff Underflow "
+		pr_debug("- TX (Suspended): Tx Buff Underflow "
 		       "or an unavailable Transmit descriptor\n");
 		break;
 	case 7:
-		pr_info("- TX (Running): Closing Tx descriptor\n");
+		pr_debug("- TX (Running): Closing Tx descriptor\n");
 		break;
 	default:
 		break;
@@ -116,29 +109,29 @@ static void show_rx_process_state(unsigned int status)
 
 	switch (state) {
 	case 0:
-		pr_info("- RX (Stopped): Reset or Stop command\n");
+		pr_debug("- RX (Stopped): Reset or Stop command\n");
 		break;
 	case 1:
-		pr_info("- RX (Running): Fetching the Rx desc\n");
+		pr_debug("- RX (Running): Fetching the Rx desc\n");
 		break;
 	case 2:
-		pr_info("- RX (Running):Checking for end of pkt\n");
+		pr_debug("- RX (Running):Checking for end of pkt\n");
 		break;
 	case 3:
-		pr_info("- RX (Running): Waiting for Rx pkt\n");
+		pr_debug("- RX (Running): Waiting for Rx pkt\n");
 		break;
 	case 4:
-		pr_info("- RX (Suspended): Unavailable Rx buf\n");
+		pr_debug("- RX (Suspended): Unavailable Rx buf\n");
 		break;
 	case 5:
-		pr_info("- RX (Running): Closing Rx descriptor\n");
+		pr_debug("- RX (Running): Closing Rx descriptor\n");
 		break;
 	case 6:
-		pr_info("- RX(Running): Flushing the current frame"
+		pr_debug("- RX(Running): Flushing the current frame"
 		       " from the Rx buf\n");
 		break;
 	case 7:
-		pr_info("- RX (Running): Queuing the Rx frame"
+		pr_debug("- RX (Running): Queuing the Rx frame"
 		       " from the Rx buf into memory\n");
 		break;
 	default:
@@ -154,51 +147,37 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* read the status register (CSR5) */
 	u32 intr_status = readl(ioaddr + DMA_STATUS);
 
-	DWMAC_LIB_DBG(KERN_INFO "%s: [CSR5: 0x%08x]\n", __func__, intr_status);
 #ifdef DWMAC_DMA_DEBUG
-	/* It displays the DMA process states (CSR5 register) */
+	/* Enable it to monitor DMA rx/tx status in case of critical problems */
+	pr_debug("%s: [CSR5: 0x%08x]\n", __func__, intr_status);
 	show_tx_process_state(intr_status);
 	show_rx_process_state(intr_status);
 #endif
 	/* ABNORMAL interrupts */
 	if (unlikely(intr_status & DMA_STATUS_AIS)) {
-		DWMAC_LIB_DBG(KERN_INFO "CSR5[15] DMA ABNORMAL IRQ: ");
 		if (unlikely(intr_status & DMA_STATUS_UNF)) {
-			DWMAC_LIB_DBG(KERN_INFO "transmit underflow\n");
 			ret = tx_hard_error_bump_tc;
 			x->tx_undeflow_irq++;
 		}
-		if (unlikely(intr_status & DMA_STATUS_TJT)) {
-			DWMAC_LIB_DBG(KERN_INFO "transmit jabber\n");
+		if (unlikely(intr_status & DMA_STATUS_TJT))
 			x->tx_jabber_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_OVF)) {
-			DWMAC_LIB_DBG(KERN_INFO "recv overflow\n");
+
+		if (unlikely(intr_status & DMA_STATUS_OVF))
 			x->rx_overflow_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_RU)) {
-			DWMAC_LIB_DBG(KERN_INFO "receive buffer unavailable\n");
+
+		if (unlikely(intr_status & DMA_STATUS_RU))
 			x->rx_buf_unav_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_RPS)) {
-			DWMAC_LIB_DBG(KERN_INFO "receive process stopped\n");
+		if (unlikely(intr_status & DMA_STATUS_RPS))
 			x->rx_process_stopped_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_RWT)) {
-			DWMAC_LIB_DBG(KERN_INFO "receive watchdog\n");
+		if (unlikely(intr_status & DMA_STATUS_RWT))
 			x->rx_watchdog_irq++;
-		}
-		if (unlikely(intr_status & DMA_STATUS_ETI)) {
-			DWMAC_LIB_DBG(KERN_INFO "transmit early interrupt\n");
+		if (unlikely(intr_status & DMA_STATUS_ETI))
 			x->tx_early_irq++;
-		}
 		if (unlikely(intr_status & DMA_STATUS_TPS)) {
-			DWMAC_LIB_DBG(KERN_INFO "transmit process stopped\n");
 			x->tx_process_stopped_irq++;
 			ret = tx_hard_error;
 		}
 		if (unlikely(intr_status & DMA_STATUS_FBI)) {
-			DWMAC_LIB_DBG(KERN_INFO "fatal bus error\n");
 			x->fatal_bus_error_irq++;
 			ret = tx_hard_error;
 		}
@@ -224,12 +203,11 @@ int dwmac_dma_interrupt(void __iomem *ioaddr,
 	/* Optional hardware blocks, interrupts should be disabled */
 	if (unlikely(intr_status &
 		     (DMA_STATUS_GPI | DMA_STATUS_GMI | DMA_STATUS_GLI)))
-		pr_info("%s: unexpected status %08x\n", __func__, intr_status);
+		pr_warn("%s: unexpected status %08x\n", __func__, intr_status);
 
 	/* Clear the interrupt by writing a logic 1 to the CSR5[15-0] */
 	writel((intr_status & 0x1ffff), ioaddr + DMA_STATUS);
 
-	DWMAC_LIB_DBG(KERN_INFO "\n\n");
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 0fbc8fa..7e6628a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -33,54 +33,40 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
 	if (unlikely(p->des01.etx.error_summary)) {
-		CHIP_DBG(KERN_ERR "GMAC TX error... 0x%08x\n", p->des01.etx);
-		if (unlikely(p->des01.etx.jabber_timeout)) {
-			CHIP_DBG(KERN_ERR "\tjabber_timeout error\n");
+		if (unlikely(p->des01.etx.jabber_timeout))
 			x->tx_jabber++;
-		}
 
 		if (unlikely(p->des01.etx.frame_flushed)) {
-			CHIP_DBG(KERN_ERR "\tframe_flushed error\n");
 			x->tx_frame_flushed++;
 			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
 
 		if (unlikely(p->des01.etx.loss_carrier)) {
-			CHIP_DBG(KERN_ERR "\tloss_carrier error\n");
 			x->tx_losscarrier++;
 			stats->tx_carrier_errors++;
 		}
 		if (unlikely(p->des01.etx.no_carrier)) {
-			CHIP_DBG(KERN_ERR "\tno_carrier error\n");
 			x->tx_carrier++;
 			stats->tx_carrier_errors++;
 		}
-		if (unlikely(p->des01.etx.late_collision)) {
-			CHIP_DBG(KERN_ERR "\tlate_collision error\n");
+		if (unlikely(p->des01.etx.late_collision))
 			stats->collisions += p->des01.etx.collision_count;
-		}
-		if (unlikely(p->des01.etx.excessive_collisions)) {
-			CHIP_DBG(KERN_ERR "\texcessive_collisions\n");
+
+		if (unlikely(p->des01.etx.excessive_collisions))
 			stats->collisions += p->des01.etx.collision_count;
-		}
-		if (unlikely(p->des01.etx.excessive_deferral)) {
-			CHIP_DBG(KERN_INFO "\texcessive tx_deferral\n");
+
+		if (unlikely(p->des01.etx.excessive_deferral))
 			x->tx_deferred++;
-		}
 
 		if (unlikely(p->des01.etx.underflow_error)) {
-			CHIP_DBG(KERN_ERR "\tunderflow error\n");
 			dwmac_dma_flush_tx_fifo(ioaddr);
 			x->tx_underflow++;
 		}
 
-		if (unlikely(p->des01.etx.ip_header_error)) {
-			CHIP_DBG(KERN_ERR "\tTX IP header csum error\n");
+		if (unlikely(p->des01.etx.ip_header_error))
 			x->tx_ip_header_error++;
-		}
 
 		if (unlikely(p->des01.etx.payload_error)) {
-			CHIP_DBG(KERN_ERR "\tAddr/Payload csum error\n");
 			x->tx_payload_error++;
 			dwmac_dma_flush_tx_fifo(ioaddr);
 		}
@@ -88,15 +74,12 @@ static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 		ret = -1;
 	}
 
-	if (unlikely(p->des01.etx.deferred)) {
-		CHIP_DBG(KERN_INFO "GMAC TX status: tx deferred\n");
+	if (unlikely(p->des01.etx.deferred))
 		x->tx_deferred++;
-	}
+
 #ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.etx.vlan_frame) {
-		CHIP_DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
+	if (p->des01.etx.vlan_frame)
 		x->tx_vlan++;
-	}
 #endif
 
 	return ret;
@@ -123,30 +106,20 @@ static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
 	 *      0 1 1 | COE bypassed.. no IPv4/6 frame
 	 *      0 1 0 | Reserved.
 	 */
-	if (status == 0x0) {
-		CHIP_DBG(KERN_INFO "RX Des0 status: IEEE 802.3 Type frame.\n");
+	if (status == 0x0)
 		ret = llc_snap;
-	} else if (status == 0x4) {
-		CHIP_DBG(KERN_INFO "RX Des0 status: IPv4/6 No CSUM errorS.\n");
+	else if (status == 0x4)
 		ret = good_frame;
-	} else if (status == 0x5) {
-		CHIP_DBG(KERN_ERR "RX Des0 status: IPv4/6 Payload Error.\n");
+	else if (status == 0x5)
 		ret = csum_none;
-	} else if (status == 0x6) {
-		CHIP_DBG(KERN_ERR "RX Des0 status: IPv4/6 Header Error.\n");
+	else if (status == 0x6)
 		ret = csum_none;
-	} else if (status == 0x7) {
-		CHIP_DBG(KERN_ERR
-		    "RX Des0 status: IPv4/6 Header and Payload Error.\n");
+	else if (status == 0x7)
 		ret = csum_none;
-	} else if (status == 0x1) {
-		CHIP_DBG(KERN_ERR
-		    "RX Des0 status: IPv4/6 unsupported IP PAYLOAD.\n");
+	else if (status == 0x1)
 		ret = discard_frame;
-	} else if (status == 0x3) {
-		CHIP_DBG(KERN_ERR "RX Des0 status: No IPv4, IPv6 frame.\n");
+	else if (status == 0x3)
 		ret = discard_frame;
-	}
 	return ret;
 }
 
@@ -208,36 +181,26 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
 	if (unlikely(p->des01.erx.error_summary)) {
-		CHIP_DBG(KERN_ERR "GMAC RX Error Summary 0x%08x\n",
-				  p->des01.erx);
 		if (unlikely(p->des01.erx.descriptor_error)) {
-			CHIP_DBG(KERN_ERR "\tdescriptor error\n");
 			x->rx_desc++;
 			stats->rx_length_errors++;
 		}
-		if (unlikely(p->des01.erx.overflow_error)) {
-			CHIP_DBG(KERN_ERR "\toverflow error\n");
+		if (unlikely(p->des01.erx.overflow_error))
 			x->rx_gmac_overflow++;
-		}
 
 		if (unlikely(p->des01.erx.ipc_csum_error))
-			CHIP_DBG(KERN_ERR "\tIPC Csum Error/Giant frame\n");
+			pr_err("\tIPC Csum Error/Giant frame\n");
 
 		if (unlikely(p->des01.erx.late_collision)) {
-			CHIP_DBG(KERN_ERR "\tlate_collision error\n");
-			stats->collisions++;
 			stats->collisions++;
 		}
-		if (unlikely(p->des01.erx.receive_watchdog)) {
-			CHIP_DBG(KERN_ERR "\treceive_watchdog error\n");
+		if (unlikely(p->des01.erx.receive_watchdog))
 			x->rx_watchdog++;
-		}
-		if (unlikely(p->des01.erx.error_gmii)) {
-			CHIP_DBG(KERN_ERR "\tReceive Error\n");
+
+		if (unlikely(p->des01.erx.error_gmii))
 			x->rx_mii++;
-		}
+
 		if (unlikely(p->des01.erx.crc_error)) {
-			CHIP_DBG(KERN_ERR "\tCRC error\n");
 			x->rx_crc++;
 			stats->rx_crc_errors++;
 		}
@@ -251,30 +214,24 @@ static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	ret = enh_desc_coe_rdes0(p->des01.erx.ipc_csum_error,
 		p->des01.erx.frame_type, p->des01.erx.rx_mac_addr);
 
-	if (unlikely(p->des01.erx.dribbling)) {
-		CHIP_DBG(KERN_ERR "GMAC RX: dribbling error\n");
+	if (unlikely(p->des01.erx.dribbling))
 		x->dribbling_bit++;
-	}
+
 	if (unlikely(p->des01.erx.sa_filter_fail)) {
-		CHIP_DBG(KERN_ERR "GMAC RX : Source Address filter fail\n");
 		x->sa_rx_filter_fail++;
 		ret = discard_frame;
 	}
 	if (unlikely(p->des01.erx.da_filter_fail)) {
-		CHIP_DBG(KERN_ERR "GMAC RX : Dest Address filter fail\n");
 		x->da_rx_filter_fail++;
 		ret = discard_frame;
 	}
 	if (unlikely(p->des01.erx.length_error)) {
-		CHIP_DBG(KERN_ERR "GMAC RX: length_error error\n");
 		x->rx_length++;
 		ret = discard_frame;
 	}
 #ifdef STMMAC_VLAN_TAG_USED
-	if (p->des01.erx.vlan_tag) {
-		CHIP_DBG(KERN_INFO "GMAC RX: VLAN frame tagged\n");
+	if (p->des01.erx.vlan_tag)
 		x->rx_vlan++;
-	}
 #endif
 
 	return ret;
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index 11775b9..35ad4f4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -52,10 +52,8 @@ static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 		ret = -1;
 	}
 
-	if (p->des01.etx.vlan_frame) {
-		CHIP_DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
+	if (p->des01.etx.vlan_frame)
 		x->tx_vlan++;
-	}
 
 	if (unlikely(p->des01.tx.deferred))
 		x->tx_deferred++;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5206933..62e3105 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -51,32 +51,6 @@
 #include "stmmac_ptp.h"
 #include "stmmac.h"
 
-#undef STMMAC_DEBUG
-/*#define STMMAC_DEBUG*/
-#ifdef STMMAC_DEBUG
-#define DBG(nlevel, klevel, fmt, args...) \
-		((void)(netif_msg_##nlevel(priv) && \
-		printk(KERN_##klevel fmt, ## args)))
-#else
-#define DBG(nlevel, klevel, fmt, args...) do { } while (0)
-#endif
-
-#undef STMMAC_RX_DEBUG
-/*#define STMMAC_RX_DEBUG*/
-#ifdef STMMAC_RX_DEBUG
-#define RX_DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define RX_DBG(fmt, args...)  do { } while (0)
-#endif
-
-#undef STMMAC_XMIT_DEBUG
-/*#define STMMAC_XMIT_DEBUG*/
-#ifdef STMMAC_XMIT_DEBUG
-#define TX_DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define TX_DBG(fmt, args...)  do { } while (0)
-#endif
-
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 #define JUMBO_LEN	9000
 
@@ -214,19 +188,17 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 	}
 }
 
-#if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
 static void print_pkt(unsigned char *buf, int len)
 {
 	int j;
-	pr_info("len = %d byte, buf addr: 0x%p", len, buf);
+	pr_debug("len = %d byte, buf addr: 0x%p", len, buf);
 	for (j = 0; j < len; j++) {
 		if ((j % 16) == 0)
-			pr_info("\n %03x:", j);
-		pr_info(" %02x", buf[j]);
+			pr_debug("\n %03x:", j);
+		pr_debug(" %02x", buf[j]);
 	}
-	pr_info("\n");
+	pr_debug("\n");
 }
-#endif
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define STMMAC_TX_THRESH(x)	(x->dma_tx_size/4)
@@ -698,9 +670,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 	if (phydev == NULL)
 		return;
 
-	DBG(probe, DEBUG, "stmmac_adjust_link: called.  address %d link %d\n",
-	    phydev->addr, phydev->link);
-
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (phydev->link) {
@@ -772,8 +741,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 	stmmac_eee_adjust(priv);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
-
-	DBG(probe, DEBUG, "stmmac_adjust_link: exiting\n");
 }
 
 /**
@@ -1014,8 +981,9 @@ static void init_dma_desc_rings(struct net_device *dev)
 	if (bfsize < BUF_SIZE_16KiB)
 		bfsize = stmmac_set_bfsize(dev->mtu, priv->dma_buf_sz);
 
-	DBG(probe, INFO, "stmmac: txsize %d, rxsize %d, bfsize %d\n",
-	    txsize, rxsize, bfsize);
+	if (netif_msg_probe(priv))
+		pr_debug("%s: txsize %d, rxsize %d, bfsize %d\n", __func__,
+			 txsize, rxsize, bfsize);
 
 	if (priv->extend_desc) {
 		priv->dma_erx = dma_alloc_coherent(priv->device, rxsize *
@@ -1051,12 +1019,13 @@ static void init_dma_desc_rings(struct net_device *dev)
 					    GFP_KERNEL);
 	priv->tx_skbuff = kmalloc_array(txsize, sizeof(struct sk_buff *),
 					GFP_KERNEL);
-	if (netif_msg_drv(priv))
+	if (netif_msg_probe(priv)) {
 		pr_debug("(%s) dma_rx_phy=0x%08x dma_tx_phy=0x%08x\n", __func__,
 			 (u32) priv->dma_rx_phy, (u32) priv->dma_tx_phy);
 
-	/* RX INITIALIZATION */
-	DBG(probe, INFO, "stmmac: SKB addresses:\nskb\t\tskb data\tdma data\n");
+		/* RX INITIALIZATION */
+		pr_debug("\tSKB addresses:\nskb\t\tskb data\tdma data\n");
+	}
 	for (i = 0; i < rxsize; i++) {
 		struct dma_desc *p;
 		if (priv->extend_desc)
@@ -1067,8 +1036,10 @@ static void init_dma_desc_rings(struct net_device *dev)
 		if (stmmac_init_rx_buffers(priv, p, i))
 			break;
 
-		DBG(probe, INFO, "[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
-		    priv->rx_skbuff[i]->data, priv->rx_skbuff_dma[i]);
+		if (netif_msg_probe(priv))
+			pr_debug("[%p]\t[%p]\t[%x]\n", priv->rx_skbuff[i],
+				 priv->rx_skbuff[i]->data,
+				 (unsigned int)priv->rx_skbuff_dma[i]);
 	}
 	priv->cur_rx = 0;
 	priv->dirty_rx = (unsigned int)(i - rxsize);
@@ -1243,8 +1214,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
-		TX_DBG("%s: curr %d, dirty %d\n", __func__,
-		       priv->cur_tx, priv->dirty_tx);
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: curr %d, dirty %d\n", __func__,
+				 priv->cur_tx, priv->dirty_tx);
 
 		if (likely(priv->tx_skbuff_dma[entry])) {
 			dma_unmap_single(priv->device,
@@ -1269,7 +1241,8 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
 		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
-			TX_DBG("%s: restart transmit\n", __func__);
+			if (netif_msg_tx_done(priv))
+				pr_debug("%s: restart transmit\n", __func__);
 			netif_wake_queue(priv->dev);
 		}
 		netif_tx_unlock(priv->dev);
@@ -1658,7 +1631,7 @@ static int stmmac_open(struct net_device *dev)
 		pr_warn("%s: failed debugFS registration\n", __func__);
 #endif
 	/* Start the ball rolling... */
-	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
+	pr_debug("%s: DMA RX/TX processes started...\n", dev->name);
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
@@ -1800,16 +1773,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	entry = priv->cur_tx % txsize;
 
-#ifdef STMMAC_XMIT_DEBUG
-	if ((skb->len > ETH_FRAME_LEN) || nfrags)
-		pr_debug("%s: [entry %d]: skb addr %p len: %d nopagedlen: %d\n"
-			 "\tn_frags: %d - ip_summed: %d - %s gso\n"
-			 "\ttx_count_frames %d\n", __func__, entry,
-			 skb, skb->len, nopaged_len, nfrags, skb->ip_summed,
-			 !skb_is_gso(skb) ? "isn't" : "is",
-			 priv->tx_count_frames);
-#endif
-
 	csum_insertion = (skb->ip_summed == CHECKSUM_PARTIAL);
 
 	if (priv->extend_desc)
@@ -1819,12 +1782,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	first = desc;
 
-#ifdef STMMAC_XMIT_DEBUG
-	if ((nfrags > 0) || (skb->len > ETH_FRAME_LEN))
-		pr_debug("\tskb len: %d, nopaged_len: %d,\n"
-			 "\t\tn_frags: %d, ip_summed: %d\n",
-			 skb->len, nopaged_len, nfrags, skb->ip_summed);
-#endif
 	priv->tx_skbuff[entry] = skb;
 
 	/* To program the descriptors according to the size of the frame */
@@ -1860,7 +1817,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		else
 			desc = priv->dma_tx + entry;
 
-		TX_DBG("\t[entry %d] segment len: %d\n", entry, len);
 		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
 					      DMA_TO_DEVICE);
 		priv->tx_skbuff_dma[entry] = desc->des2;
@@ -1884,8 +1840,6 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (priv->tx_coal_frames > priv->tx_count_frames) {
 		priv->hw->desc->clear_tx_ic(desc);
 		priv->xstats.tx_reset_ic_bit++;
-		TX_DBG("\t[entry %d]: tx_count_frames %d\n", entry,
-		       priv->tx_count_frames);
 		mod_timer(&priv->txtimer,
 			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
 	} else
@@ -1897,22 +1851,22 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	priv->cur_tx++;
 
-#ifdef STMMAC_XMIT_DEBUG
 	if (netif_msg_pktdata(priv)) {
-		pr_info("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
+		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
 			__func__, (priv->cur_tx % txsize),
 			(priv->dirty_tx % txsize), entry, first, nfrags);
+
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_etx, txsize, 1);
 		else
 			stmmac_display_ring((void *)priv->dma_tx, txsize, 0);
 
-		pr_info(">>> frame to be transmitted: ");
+		pr_debug(">>> frame to be transmitted: ");
 		print_pkt(skb->data, skb->len);
 	}
-#endif
 	if (unlikely(stmmac_tx_avail(priv) <= (MAX_SKB_FRAGS + 1))) {
-		TX_DBG("%s: stop transmitted packets\n", __func__);
+		if (netif_msg_hw(priv))
+			pr_debug("%s: stop transmitted packets\n", __func__);
 		netif_stop_queue(dev);
 	}
 
@@ -1972,7 +1926,8 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 
 			priv->hw->ring->refill_desc3(priv, p);
 
-			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
+			if (netif_msg_rx_status(priv))
+				pr_debug("\trefill entry #%d\n", entry);
 		}
 		wmb();
 		priv->hw->desc->set_rx_owner(p);
@@ -1995,15 +1950,13 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 	unsigned int count = 0;
 	int coe = priv->plat->rx_coe;
 
-#ifdef STMMAC_RX_DEBUG
-	if (netif_msg_hw(priv)) {
-		pr_debug(">>> stmmac_rx: descriptor ring:\n");
+	if (netif_msg_rx_status(priv)) {
+		pr_debug("%s: descriptor ring:\n", __func__);
 		if (priv->extend_desc)
 			stmmac_display_ring((void *)priv->dma_erx, rxsize, 1);
 		else
 			stmmac_display_ring((void *)priv->dma_rx, rxsize, 0);
 	}
-#endif
 	while (count < limit) {
 		int status;
 		struct dma_desc *p;
@@ -2057,15 +2010,14 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			 */
 			if (unlikely(status != llc_snap))
 				frame_len -= ETH_FCS_LEN;
-#ifdef STMMAC_RX_DEBUG
-			if (frame_len > ETH_FRAME_LEN)
-				pr_debug("\tRX frame size %d, COE status: %d\n",
-					 frame_len, status);
 
-			if (netif_msg_hw(priv))
+			if (netif_msg_rx_status(priv)) {
 				pr_debug("\tdesc: %p [entry %d] buff=0x%x\n",
 					 p, entry, p->des2);
-#endif
+				if (frame_len > ETH_FRAME_LEN)
+					pr_debug("\tframe size %d, COE: %d\n",
+						 frame_len, status);
+			}
 			skb = priv->rx_skbuff[entry];
 			if (unlikely(!skb)) {
 				pr_err("%s: Inconsistent Rx descriptor chain\n",
@@ -2082,12 +2034,12 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 			dma_unmap_single(priv->device,
 					 priv->rx_skbuff_dma[entry],
 					 priv->dma_buf_sz, DMA_FROM_DEVICE);
-#ifdef STMMAC_RX_DEBUG
+
 			if (netif_msg_pktdata(priv)) {
-				pr_info(" frame received (%dbytes)", frame_len);
+				pr_debug("frame received (%dbytes)", frame_len);
 				print_pkt(skb->data, frame_len);
 			}
-#endif
+
 			skb->protocol = eth_type_trans(skb, priv->dev);
 
 			if (unlikely(!coe))
-- 
1.7.4.4
