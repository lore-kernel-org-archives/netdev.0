From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/7] stmmac: rework normal and enhanced descriptors
Date: Wed, 14 Apr 2010 08:21:12 +0200
Message-ID: <1271226077-25882-2-git-send-email-peppe.cavallaro@st.com>
References: <1271226077-25882-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:53715 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753769Ab0DNGVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 02:21:40 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 21724118
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:29 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CCA8D11B1
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:28 +0000 (GMT)
In-Reply-To: <1271226077-25882-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the driver assumes that the mac10/100 can only use the
normal descriptor structure and the gmac can only use the
enhanced structures.
This patch removes the descriptor's code from the dma files
and adds two new files just for handling the normal and enhanced
descriptors.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Makefile         |    2 +-
 drivers/net/stmmac/common.h         |   15 ++-
 drivers/net/stmmac/dwmac100.h       |   12 --
 drivers/net/stmmac/dwmac1000.h      |   11 -
 drivers/net/stmmac/dwmac1000_core.c |   27 ++--
 drivers/net/stmmac/dwmac1000_dma.c  |  327 +---------------------------------
 drivers/net/stmmac/dwmac100_core.c  |    3 +-
 drivers/net/stmmac/dwmac100_dma.c   |  223 +----------------------
 drivers/net/stmmac/enh_desc.c       |  342 +++++++++++++++++++++++++++++++++++
 drivers/net/stmmac/norm_desc.c      |  240 ++++++++++++++++++++++++
 drivers/net/stmmac/stmmac.h         |    2 +
 drivers/net/stmmac/stmmac_main.c    |    7 +-
 12 files changed, 627 insertions(+), 584 deletions(-)
 create mode 100644 drivers/net/stmmac/enh_desc.c
 create mode 100644 drivers/net/stmmac/norm_desc.c

diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index b14bd56..9691733 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -2,4 +2,4 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
-	      dwmac100_core.o dwmac100_dma.o $(stmmac-y)
+	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 2a58172..bd3b785 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -22,8 +22,21 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
-#include "descs.h"
 #include <linux/netdevice.h>
+#include "descs.h"
+
+#undef CHIP_DEBUG_PRINT
+/* Turn-on extra printk debug for MAC core, dma and descriptors */
+/* #define CHIP_DEBUG_PRINT */
+
+#ifdef CHIP_DEBUG_PRINT
+#define CHIP_DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define CHIP_DBG(fmt, args...)  do { } while (0)
+#endif
+
+#undef FRAME_FILTER_DEBUG
+/* #define FRAME_FILTER_DEBUG */
 
 struct stmmac_extra_stats {
 	/* Transmit errors */
diff --git a/drivers/net/stmmac/dwmac100.h b/drivers/net/stmmac/dwmac100.h
index 9f4ba2e..97956cb 100644
--- a/drivers/net/stmmac/dwmac100.h
+++ b/drivers/net/stmmac/dwmac100.h
@@ -118,16 +118,4 @@ enum ttc_control {
 #define DMA_MISSED_FRAME_OVE_M	0x00010000	/* Missed Frame Overflow */
 #define DMA_MISSED_FRAME_M_CNTR	0x0000ffff	/* Missed Frame Couinter */
 
-#undef DWMAC100_DEBUG
-/* #define DWMAC100__DEBUG */
-#undef FRAME_FILTER_DEBUG
-/* #define FRAME_FILTER_DEBUG */
-#ifdef DWMAC100__DEBUG
-#define DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define DBG(fmt, args...)  do { } while (0)
-#endif
-
 extern struct stmmac_dma_ops dwmac100_dma_ops;
-extern struct stmmac_desc_ops dwmac100_desc_ops;
-
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
index 62dca0e..3b784fc 100644
--- a/drivers/net/stmmac/dwmac1000.h
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -206,15 +206,4 @@ enum rtc_control {
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
-#undef DWMAC1000_DEBUG
-/* #define DWMAC1000__DEBUG */
-#undef FRAME_FILTER_DEBUG
-/* #define FRAME_FILTER_DEBUG */
-#ifdef DWMAC1000__DEBUG
-#define DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define DBG(fmt, args...)  do { } while (0)
-#endif
-
 extern struct stmmac_dma_ops dwmac1000_dma_ops;
-extern struct stmmac_desc_ops dwmac1000_desc_ops;
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index f9c7c1c..0aa89ae 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -83,8 +83,8 @@ static void dwmac1000_set_filter(struct net_device *dev)
 	unsigned long ioaddr = dev->base_addr;
 	unsigned int value = 0;
 
-	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-	    __func__, netdev_mc_count(dev), netdev_uc_count(dev));
+	CHIP_DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
+		 __func__, netdev_mc_count(dev), netdev_uc_count(dev));
 
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
@@ -136,7 +136,7 @@ static void dwmac1000_set_filter(struct net_device *dev)
 #endif
 	writel(value, ioaddr + GMAC_FRAME_FILTER);
 
-	DBG(KERN_INFO "\tFrame Filter reg: 0x%08x\n\tHash regs: "
+	CHIP_DBG(KERN_INFO "\tFrame Filter reg: 0x%08x\n\tHash regs: "
 	    "HI 0x%08x, LO 0x%08x\n", readl(ioaddr + GMAC_FRAME_FILTER),
 	    readl(ioaddr + GMAC_HASH_HIGH), readl(ioaddr + GMAC_HASH_LOW));
 
@@ -148,18 +148,18 @@ static void dwmac1000_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
 {
 	unsigned int flow = 0;
 
-	DBG(KERN_DEBUG "GMAC Flow-Control:\n");
+	CHIP_DBG(KERN_DEBUG "GMAC Flow-Control:\n");
 	if (fc & FLOW_RX) {
-		DBG(KERN_DEBUG "\tReceive Flow-Control ON\n");
+		CHIP_DBG(KERN_DEBUG "\tReceive Flow-Control ON\n");
 		flow |= GMAC_FLOW_CTRL_RFE;
 	}
 	if (fc & FLOW_TX) {
-		DBG(KERN_DEBUG "\tTransmit Flow-Control ON\n");
+		CHIP_DBG(KERN_DEBUG "\tTransmit Flow-Control ON\n");
 		flow |= GMAC_FLOW_CTRL_TFE;
 	}
 
 	if (duplex) {
-		DBG(KERN_DEBUG "\tduplex mode: pause time: %d\n", pause_time);
+		CHIP_DBG(KERN_DEBUG "\tduplex mode: PAUSE %d\n", pause_time);
 		flow |= (pause_time << GMAC_FLOW_CTRL_PT_SHIFT);
 	}
 
@@ -172,10 +172,10 @@ static void dwmac1000_pmt(unsigned long ioaddr, unsigned long mode)
 	unsigned int pmt = 0;
 
 	if (mode == WAKE_MAGIC) {
-		DBG(KERN_DEBUG "GMAC: WOL Magic frame\n");
+		CHIP_DBG(KERN_DEBUG "GMAC: WOL Magic frame\n");
 		pmt |= power_down | magic_pkt_en;
 	} else if (mode == WAKE_UCAST) {
-		DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
+		CHIP_DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
 		pmt |= global_unicast;
 	}
 
@@ -190,16 +190,16 @@ static void dwmac1000_irq_status(unsigned long ioaddr)
 
 	/* Not used events (e.g. MMC interrupts) are not handled. */
 	if ((intr_status & mmc_tx_irq))
-		DBG(KERN_DEBUG "GMAC: MMC tx interrupt: 0x%08x\n",
+		CHIP_DBG(KERN_DEBUG "GMAC: MMC tx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_TX_INTR));
 	if (unlikely(intr_status & mmc_rx_irq))
-		DBG(KERN_DEBUG "GMAC: MMC rx interrupt: 0x%08x\n",
+		CHIP_DBG(KERN_DEBUG "GMAC: MMC rx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_INTR));
 	if (unlikely(intr_status & mmc_rx_csum_offload_irq))
-		DBG(KERN_DEBUG "GMAC: MMC rx csum offload: 0x%08x\n",
+		CHIP_DBG(KERN_DEBUG "GMAC: MMC rx csum offload: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
 	if (unlikely(intr_status & pmt_irq)) {
-		DBG(KERN_DEBUG "GMAC: received Magic frame\n");
+		CHIP_DBG(KERN_DEBUG "GMAC: received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT
 		 * status register. */
 		readl(ioaddr + GMAC_PMT);
@@ -230,7 +230,6 @@ struct mac_device_info *dwmac1000_setup(unsigned long ioaddr)
 	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
 
 	mac->mac = &dwmac1000_ops;
-	mac->desc = &dwmac1000_desc_ops;
 	mac->dma = &dwmac1000_dma_ops;
 
 	mac->pmt = PMT_SUPPORTED;
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index 39d436a..8d3ea99 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -3,7 +3,7 @@
   DWC Ether MAC 10/100/1000 Universal version 3.41a  has been used for
   developing this code.
 
-  This contains the functions to handle the dma and descriptors.
+  This contains the functions to handle the dma.
 
   Copyright (C) 2007-2009  STMicroelectronics Ltd
 
@@ -73,14 +73,14 @@ static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
 	if (txmode == SF_DMA_MODE) {
-		DBG(KERN_DEBUG "GMAC: enabling TX store and forward mode\n");
+		CHIP_DBG(KERN_DEBUG "GMAC: enable TX store and forward mode\n");
 		/* Transmit COE type 2 cannot be done in cut-through mode. */
 		csr6 |= DMA_CONTROL_TSF;
 		/* Operating on second frame increase the performance
 		 * especially when transmit store-and-forward is used.*/
 		csr6 |= DMA_CONTROL_OSF;
 	} else {
-		DBG(KERN_DEBUG "GMAC: disabling TX store and forward mode"
+		CHIP_DBG(KERN_DEBUG "GMAC: disabling TX store and forward mode"
 			      " (threshold = %d)\n", txmode);
 		csr6 &= ~DMA_CONTROL_TSF;
 		csr6 &= DMA_CONTROL_TC_TX_MASK;
@@ -98,10 +98,10 @@ static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
 	}
 
 	if (rxmode == SF_DMA_MODE) {
-		DBG(KERN_DEBUG "GMAC: enabling RX store and forward mode\n");
+		CHIP_DBG(KERN_DEBUG "GMAC: enable RX store and forward mode\n");
 		csr6 |= DMA_CONTROL_RSF;
 	} else {
-		DBG(KERN_DEBUG "GMAC: disabling RX store and forward mode"
+		CHIP_DBG(KERN_DEBUG "GMAC: disabling RX store and forward mode"
 			      " (threshold = %d)\n", rxmode);
 		csr6 &= ~DMA_CONTROL_RSF;
 		csr6 &= DMA_CONTROL_TC_RX_MASK;
@@ -141,305 +141,6 @@ static void dwmac1000_dump_dma_regs(unsigned long ioaddr)
 	return;
 }
 
-static int dwmac1000_get_tx_frame_status(void *data,
-				struct stmmac_extra_stats *x,
-				struct dma_desc *p, unsigned long ioaddr)
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
-			dwmac1000_flush_tx_fifo(ioaddr);
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
-			dwmac1000_flush_tx_fifo(ioaddr);
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
-			dwmac1000_flush_tx_fifo(ioaddr);
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
-static int dwmac1000_get_tx_len(struct dma_desc *p)
-{
-	return p->des01.etx.buffer1_size;
-}
-
-static int dwmac1000_coe_rdes0(int ipc_err, int type, int payload_err)
-{
-	int ret = good_frame;
-	u32 status = (type << 2 | ipc_err << 1 | payload_err) & 0x7;
-
-	/* bits 5 7 0 | Frame status
-	 * ----------------------------------------------------------
-	 *      0 0 0 | IEEE 802.3 Type frame (length < 1536 octects)
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
-static int dwmac1000_get_rx_frame_status(void *data,
-			struct stmmac_extra_stats *x, struct dma_desc *p)
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
-	ret = dwmac1000_coe_rdes0(p->des01.erx.ipc_csum_error,
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
-		x->rx_length++;
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
-static void dwmac1000_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
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
-static void dwmac1000_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
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
-static int dwmac1000_get_tx_owner(struct dma_desc *p)
-{
-	return p->des01.etx.own;
-}
-
-static int dwmac1000_get_rx_owner(struct dma_desc *p)
-{
-	return p->des01.erx.own;
-}
-
-static void dwmac1000_set_tx_owner(struct dma_desc *p)
-{
-	p->des01.etx.own = 1;
-}
-
-static void dwmac1000_set_rx_owner(struct dma_desc *p)
-{
-	p->des01.erx.own = 1;
-}
-
-static int dwmac1000_get_tx_ls(struct dma_desc *p)
-{
-	return p->des01.etx.last_segment;
-}
-
-static void dwmac1000_release_tx_desc(struct dma_desc *p)
-{
-	int ter = p->des01.etx.end_ring;
-
-	memset(p, 0, sizeof(struct dma_desc));
-	p->des01.etx.end_ring = ter;
-
-	return;
-}
-
-static void dwmac1000_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
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
-static void dwmac1000_clear_tx_ic(struct dma_desc *p)
-{
-	p->des01.etx.interrupt = 0;
-}
-
-static void dwmac1000_close_tx_desc(struct dma_desc *p)
-{
-	p->des01.etx.last_segment = 1;
-	p->des01.etx.interrupt = 1;
-}
-
-static int dwmac1000_get_rx_frame_len(struct dma_desc *p)
-{
-	return p->des01.erx.frame_length;
-}
-
 struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.init = dwmac1000_dma_init,
 	.dump_regs = dwmac1000_dump_dma_regs,
@@ -454,21 +155,3 @@ struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.stop_rx = dwmac_dma_stop_rx,
 	.dma_interrupt = dwmac_dma_interrupt,
 };
-
-struct stmmac_desc_ops dwmac1000_desc_ops = {
-	.tx_status = dwmac1000_get_tx_frame_status,
-	.rx_status = dwmac1000_get_rx_frame_status,
-	.get_tx_len = dwmac1000_get_tx_len,
-	.init_rx_desc = dwmac1000_init_rx_desc,
-	.init_tx_desc = dwmac1000_init_tx_desc,
-	.get_tx_owner = dwmac1000_get_tx_owner,
-	.get_rx_owner = dwmac1000_get_rx_owner,
-	.release_tx_desc = dwmac1000_release_tx_desc,
-	.prepare_tx_desc = dwmac1000_prepare_tx_desc,
-	.clear_tx_ic = dwmac1000_clear_tx_ic,
-	.close_tx_desc = dwmac1000_close_tx_desc,
-	.get_tx_ls = dwmac1000_get_tx_ls,
-	.set_tx_owner = dwmac1000_set_tx_owner,
-	.set_rx_owner = dwmac1000_set_rx_owner,
-	.get_rx_frame_len = dwmac1000_get_rx_frame_len,
-};
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
index 8ecb8c0..fab14a4 100644
--- a/drivers/net/stmmac/dwmac100_core.c
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -141,7 +141,7 @@ static void dwmac100_set_filter(struct net_device *dev)
 
 	writel(value, ioaddr + MAC_CONTROL);
 
-	DBG(KERN_INFO "%s: CTRL reg: 0x%08x Hash regs: "
+	CHIP_DBG(KERN_INFO "%s: CTRL reg: 0x%08x Hash regs: "
 	    "HI 0x%08x, LO 0x%08x\n",
 	    __func__, readl(ioaddr + MAC_CONTROL),
 	    readl(ioaddr + MAC_HASH_HIGH), readl(ioaddr + MAC_HASH_LOW));
@@ -188,7 +188,6 @@ struct mac_device_info *dwmac100_setup(unsigned long ioaddr)
 	pr_info("\tDWMAC100\n");
 
 	mac->mac = &dwmac100_ops;
-	mac->desc = &dwmac100_desc_ops;
 	mac->dma = &dwmac100_dma_ops;
 
 	mac->pmt = PMT_NOT_SUPPORTED;
diff --git a/drivers/net/stmmac/dwmac100_dma.c b/drivers/net/stmmac/dwmac100_dma.c
index 7fcc526..96d098d 100644
--- a/drivers/net/stmmac/dwmac100_dma.c
+++ b/drivers/net/stmmac/dwmac100_dma.c
@@ -5,7 +5,7 @@
   DWC Ether MAC 10/100 Universal version 4.0 has been used for developing
   this code.
 
-  This contains the functions to handle the dma and descriptors.
+  This contains the functions to handle the dma.
 
   Copyright (C) 2007-2009  STMicroelectronics Ltd
 
@@ -79,14 +79,14 @@ static void dwmac100_dump_dma_regs(unsigned long ioaddr)
 {
 	int i;
 
-	DBG(KERN_DEBUG "DWMAC 100 DMA CSR\n");
+	CHIP_DBG(KERN_DEBUG "DWMAC 100 DMA CSR\n");
 	for (i = 0; i < 9; i++)
 		pr_debug("\t CSR%d (offset 0x%x): 0x%08x\n", i,
 		       (DMA_BUS_MODE + i * 4),
 		       readl(ioaddr + DMA_BUS_MODE + i * 4));
-	DBG(KERN_DEBUG "\t CSR20 (offset 0x%x): 0x%08x\n",
+	CHIP_DBG(KERN_DEBUG "\t CSR20 (offset 0x%x): 0x%08x\n",
 	    DMA_CUR_TX_BUF_ADDR, readl(ioaddr + DMA_CUR_TX_BUF_ADDR));
-	DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
+	CHIP_DBG(KERN_DEBUG "\t CSR21 (offset 0x%x): 0x%08x\n",
 	    DMA_CUR_RX_BUF_ADDR, readl(ioaddr + DMA_CUR_RX_BUF_ADDR));
 	return;
 }
@@ -122,203 +122,6 @@ static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
 	return;
 }
 
-static int dwmac100_get_tx_status(void *data, struct stmmac_extra_stats *x,
-				  struct dma_desc *p, unsigned long ioaddr)
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
-static int dwmac100_get_tx_len(struct dma_desc *p)
-{
-	return p->des01.tx.buffer1_size;
-}
-
-/* This function verifies if each incoming frame has some errors
- * and, if required, updates the multicast statistics.
- * In case of success, it returns csum_none becasue the device
- * is not able to compute the csum in HW. */
-static int dwmac100_get_rx_status(void *data, struct stmmac_extra_stats *x,
-				  struct dma_desc *p)
-{
-	int ret = csum_none;
-	struct net_device_stats *stats = (struct net_device_stats *)data;
-
-	if (unlikely(p->des01.rx.last_descriptor == 0)) {
-		pr_warning("dwmac100 Error: Oversized Ethernet "
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
-		x->rx_length++;
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
-static void dwmac100_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
-				  int disable_rx_ic)
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
-static void dwmac100_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
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
-static int dwmac100_get_tx_owner(struct dma_desc *p)
-{
-	return p->des01.tx.own;
-}
-
-static int dwmac100_get_rx_owner(struct dma_desc *p)
-{
-	return p->des01.rx.own;
-}
-
-static void dwmac100_set_tx_owner(struct dma_desc *p)
-{
-	p->des01.tx.own = 1;
-}
-
-static void dwmac100_set_rx_owner(struct dma_desc *p)
-{
-	p->des01.rx.own = 1;
-}
-
-static int dwmac100_get_tx_ls(struct dma_desc *p)
-{
-	return p->des01.tx.last_segment;
-}
-
-static void dwmac100_release_tx_desc(struct dma_desc *p)
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
-static void dwmac100_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
-				     int csum_flag)
-{
-	p->des01.tx.first_segment = is_fs;
-	p->des01.tx.buffer1_size = len;
-}
-
-static void dwmac100_clear_tx_ic(struct dma_desc *p)
-{
-	p->des01.tx.interrupt = 0;
-}
-
-static void dwmac100_close_tx_desc(struct dma_desc *p)
-{
-	p->des01.tx.last_segment = 1;
-	p->des01.tx.interrupt = 1;
-}
-
-static int dwmac100_get_rx_frame_len(struct dma_desc *p)
-{
-	return p->des01.rx.frame_length;
-}
-
 struct stmmac_dma_ops dwmac100_dma_ops = {
 	.init = dwmac100_dma_init,
 	.dump_regs = dwmac100_dump_dma_regs,
@@ -333,21 +136,3 @@ struct stmmac_dma_ops dwmac100_dma_ops = {
 	.stop_rx = dwmac_dma_stop_rx,
 	.dma_interrupt = dwmac_dma_interrupt,
 };
-
-struct stmmac_desc_ops dwmac100_desc_ops = {
-	.tx_status = dwmac100_get_tx_status,
-	.rx_status = dwmac100_get_rx_status,
-	.get_tx_len = dwmac100_get_tx_len,
-	.init_rx_desc = dwmac100_init_rx_desc,
-	.init_tx_desc = dwmac100_init_tx_desc,
-	.get_tx_owner = dwmac100_get_tx_owner,
-	.get_rx_owner = dwmac100_get_rx_owner,
-	.release_tx_desc = dwmac100_release_tx_desc,
-	.prepare_tx_desc = dwmac100_prepare_tx_desc,
-	.clear_tx_ic = dwmac100_clear_tx_ic,
-	.close_tx_desc = dwmac100_close_tx_desc,
-	.get_tx_ls = dwmac100_get_tx_ls,
-	.set_tx_owner = dwmac100_set_tx_owner,
-	.set_rx_owner = dwmac100_set_rx_owner,
-	.get_rx_frame_len = dwmac100_get_rx_frame_len,
-};
diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_desc.c
new file mode 100644
index 0000000..e5ac259
--- /dev/null
+++ b/drivers/net/stmmac/enh_desc.c
@@ -0,0 +1,342 @@
+/*******************************************************************************
+  This contains the functions to handle the enhanced descriptors.
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
+#include "common.h"
+
+static int enh_desc_get_tx_status(void *data, struct stmmac_extra_stats *x,
+				  struct dma_desc *p, unsigned long ioaddr)
+{
+	int ret = 0;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.etx.error_summary)) {
+		CHIP_DBG(KERN_ERR "GMAC TX error... 0x%08x\n", p->des01.etx);
+		if (unlikely(p->des01.etx.jabber_timeout)) {
+			CHIP_DBG(KERN_ERR "\tjabber_timeout error\n");
+			x->tx_jabber++;
+		}
+
+		if (unlikely(p->des01.etx.frame_flushed)) {
+			CHIP_DBG(KERN_ERR "\tframe_flushed error\n");
+			x->tx_frame_flushed++;
+			/*enh_desc_flush_tx_fifo(ioaddr);*/
+		}
+
+		if (unlikely(p->des01.etx.loss_carrier)) {
+			CHIP_DBG(KERN_ERR "\tloss_carrier error\n");
+			x->tx_losscarrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely(p->des01.etx.no_carrier)) {
+			CHIP_DBG(KERN_ERR "\tno_carrier error\n");
+			x->tx_carrier++;
+			stats->tx_carrier_errors++;
+		}
+		if (unlikely(p->des01.etx.late_collision)) {
+			CHIP_DBG(KERN_ERR "\tlate_collision error\n");
+			stats->collisions += p->des01.etx.collision_count;
+		}
+		if (unlikely(p->des01.etx.excessive_collisions)) {
+			CHIP_DBG(KERN_ERR "\texcessive_collisions\n");
+			stats->collisions += p->des01.etx.collision_count;
+		}
+		if (unlikely(p->des01.etx.excessive_deferral)) {
+			CHIP_DBG(KERN_INFO "\texcessive tx_deferral\n");
+			x->tx_deferred++;
+		}
+
+		if (unlikely(p->des01.etx.underflow_error)) {
+			CHIP_DBG(KERN_ERR "\tunderflow error\n");
+			/*enh_desc_flush_tx_fifo(ioaddr);*/
+			x->tx_underflow++;
+		}
+
+		if (unlikely(p->des01.etx.ip_header_error)) {
+			CHIP_DBG(KERN_ERR "\tTX IP header csum error\n");
+			x->tx_ip_header_error++;
+		}
+
+		if (unlikely(p->des01.etx.payload_error)) {
+			CHIP_DBG(KERN_ERR "\tAddr/Payload csum error\n");
+			x->tx_payload_error++;
+			/*enh_desc_flush_tx_fifo(ioaddr);*/
+		}
+
+		ret = -1;
+	}
+
+	if (unlikely(p->des01.etx.deferred)) {
+		CHIP_DBG(KERN_INFO "GMAC TX status: tx deferred\n");
+		x->tx_deferred++;
+	}
+#ifdef STMMAC_VLAN_TAG_USED
+	if (p->des01.etx.vlan_frame) {
+		CHIP_DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
+		x->tx_vlan++;
+	}
+#endif
+
+	return ret;
+}
+
+static int enh_desc_get_tx_len(struct dma_desc *p)
+{
+	return p->des01.etx.buffer1_size;
+}
+
+static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_err)
+{
+	int ret = good_frame;
+	u32 status = (type << 2 | ipc_err << 1 | payload_err) & 0x7;
+
+	/* bits 5 7 0 | Frame status
+	 * ----------------------------------------------------------
+	 *      0 0 0 | IEEE 802.3 Type frame (length < 1536 octects)
+	 *      1 0 0 | IPv4/6 No CSUM errorS.
+	 *      1 0 1 | IPv4/6 CSUM PAYLOAD error
+	 *      1 1 0 | IPv4/6 CSUM IP HR error
+	 *      1 1 1 | IPv4/6 IP PAYLOAD AND HEADER errorS
+	 *      0 0 1 | IPv4/6 unsupported IP PAYLOAD
+	 *      0 1 1 | COE bypassed.. no IPv4/6 frame
+	 *      0 1 0 | Reserved.
+	 */
+	if (status == 0x0) {
+		CHIP_DBG(KERN_INFO "RX Des0 status: IEEE 802.3 Type frame.\n");
+		ret = good_frame;
+	} else if (status == 0x4) {
+		CHIP_DBG(KERN_INFO "RX Des0 status: IPv4/6 No CSUM errorS.\n");
+		ret = good_frame;
+	} else if (status == 0x5) {
+		CHIP_DBG(KERN_ERR "RX Des0 status: IPv4/6 Payload Error.\n");
+		ret = csum_none;
+	} else if (status == 0x6) {
+		CHIP_DBG(KERN_ERR "RX Des0 status: IPv4/6 Header Error.\n");
+		ret = csum_none;
+	} else if (status == 0x7) {
+		CHIP_DBG(KERN_ERR
+		    "RX Des0 status: IPv4/6 Header and Payload Error.\n");
+		ret = csum_none;
+	} else if (status == 0x1) {
+		CHIP_DBG(KERN_ERR
+		    "RX Des0 status: IPv4/6 unsupported IP PAYLOAD.\n");
+		ret = discard_frame;
+	} else if (status == 0x3) {
+		CHIP_DBG(KERN_ERR "RX Des0 status: No IPv4, IPv6 frame.\n");
+		ret = discard_frame;
+	}
+	return ret;
+}
+
+static int enh_desc_get_rx_status(void *data, struct stmmac_extra_stats *x,
+				  struct dma_desc *p)
+{
+	int ret = good_frame;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.erx.error_summary)) {
+		CHIP_DBG(KERN_ERR "GMAC RX Error Summary 0x%08x\n",
+				  p->des01.erx);
+		if (unlikely(p->des01.erx.descriptor_error)) {
+			CHIP_DBG(KERN_ERR "\tdescriptor error\n");
+			x->rx_desc++;
+			stats->rx_length_errors++;
+		}
+		if (unlikely(p->des01.erx.overflow_error)) {
+			CHIP_DBG(KERN_ERR "\toverflow error\n");
+			x->rx_gmac_overflow++;
+		}
+
+		if (unlikely(p->des01.erx.ipc_csum_error))
+			CHIP_DBG(KERN_ERR "\tIPC Csum Error/Giant frame\n");
+
+		if (unlikely(p->des01.erx.late_collision)) {
+			CHIP_DBG(KERN_ERR "\tlate_collision error\n");
+			stats->collisions++;
+			stats->collisions++;
+		}
+		if (unlikely(p->des01.erx.receive_watchdog)) {
+			CHIP_DBG(KERN_ERR "\treceive_watchdog error\n");
+			x->rx_watchdog++;
+		}
+		if (unlikely(p->des01.erx.error_gmii)) {
+			CHIP_DBG(KERN_ERR "\tReceive Error\n");
+			x->rx_mii++;
+		}
+		if (unlikely(p->des01.erx.crc_error)) {
+			CHIP_DBG(KERN_ERR "\tCRC error\n");
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
+	ret = enh_desc_coe_rdes0(p->des01.erx.ipc_csum_error,
+		p->des01.erx.frame_type, p->des01.erx.payload_csum_error);
+
+	if (unlikely(p->des01.erx.dribbling)) {
+		CHIP_DBG(KERN_ERR "GMAC RX: dribbling error\n");
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.erx.sa_filter_fail)) {
+		CHIP_DBG(KERN_ERR "GMAC RX : Source Address filter fail\n");
+		x->sa_rx_filter_fail++;
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.erx.da_filter_fail)) {
+		CHIP_DBG(KERN_ERR "GMAC RX : Dest Address filter fail\n");
+		x->da_rx_filter_fail++;
+		ret = discard_frame;
+	}
+	if (unlikely(p->des01.erx.length_error)) {
+		CHIP_DBG(KERN_ERR "GMAC RX: length_error error\n");
+		x->rx_length++;
+		ret = discard_frame;
+	}
+#ifdef STMMAC_VLAN_TAG_USED
+	if (p->des01.erx.vlan_tag) {
+		CHIP_DBG(KERN_INFO "GMAC RX: VLAN frame tagged\n");
+		x->rx_vlan++;
+	}
+#endif
+	return ret;
+}
+
+static void enh_desc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				  int disable_rx_ic)
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
+static void enh_desc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
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
+static int enh_desc_get_tx_owner(struct dma_desc *p)
+{
+	return p->des01.etx.own;
+}
+
+static int enh_desc_get_rx_owner(struct dma_desc *p)
+{
+	return p->des01.erx.own;
+}
+
+static void enh_desc_set_tx_owner(struct dma_desc *p)
+{
+	p->des01.etx.own = 1;
+}
+
+static void enh_desc_set_rx_owner(struct dma_desc *p)
+{
+	p->des01.erx.own = 1;
+}
+
+static int enh_desc_get_tx_ls(struct dma_desc *p)
+{
+	return p->des01.etx.last_segment;
+}
+
+static void enh_desc_release_tx_desc(struct dma_desc *p)
+{
+	int ter = p->des01.etx.end_ring;
+
+	memset(p, 0, sizeof(struct dma_desc));
+	p->des01.etx.end_ring = ter;
+
+	return;
+}
+
+static void enh_desc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				     int csum_flag)
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
+static void enh_desc_clear_tx_ic(struct dma_desc *p)
+{
+	p->des01.etx.interrupt = 0;
+}
+
+static void enh_desc_close_tx_desc(struct dma_desc *p)
+{
+	p->des01.etx.last_segment = 1;
+	p->des01.etx.interrupt = 1;
+}
+
+static int enh_desc_get_rx_frame_len(struct dma_desc *p)
+{
+	return p->des01.erx.frame_length;
+}
+
+struct stmmac_desc_ops enh_desc_ops = {
+	.tx_status = enh_desc_get_tx_status,
+	.rx_status = enh_desc_get_rx_status,
+	.get_tx_len = enh_desc_get_tx_len,
+	.init_rx_desc = enh_desc_init_rx_desc,
+	.init_tx_desc = enh_desc_init_tx_desc,
+	.get_tx_owner = enh_desc_get_tx_owner,
+	.get_rx_owner = enh_desc_get_rx_owner,
+	.release_tx_desc = enh_desc_release_tx_desc,
+	.prepare_tx_desc = enh_desc_prepare_tx_desc,
+	.clear_tx_ic = enh_desc_clear_tx_ic,
+	.close_tx_desc = enh_desc_close_tx_desc,
+	.get_tx_ls = enh_desc_get_tx_ls,
+	.set_tx_owner = enh_desc_set_tx_owner,
+	.set_rx_owner = enh_desc_set_rx_owner,
+	.get_rx_frame_len = enh_desc_get_rx_frame_len,
+};
diff --git a/drivers/net/stmmac/norm_desc.c b/drivers/net/stmmac/norm_desc.c
new file mode 100644
index 0000000..ecfcc00
--- /dev/null
+++ b/drivers/net/stmmac/norm_desc.c
@@ -0,0 +1,240 @@
+/*******************************************************************************
+  This contains the functions to handle the normal descriptors.
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
+#include "common.h"
+
+static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
+			       struct dma_desc *p, unsigned long ioaddr)
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
+static int ndesc_get_tx_len(struct dma_desc *p)
+{
+	return p->des01.tx.buffer1_size;
+}
+
+/* This function verifies if each incoming frame has some errors
+ * and, if required, updates the multicast statistics.
+ * In case of success, it returns csum_none becasue the device
+ * is not able to compute the csum in HW. */
+static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
+			       struct dma_desc *p)
+{
+	int ret = csum_none;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.rx.last_descriptor == 0)) {
+		pr_warning("ndesc Error: Oversized Ethernet "
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
+		x->rx_length++;
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
+static void ndesc_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+			       int disable_rx_ic)
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
+static void ndesc_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
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
+static int ndesc_get_tx_owner(struct dma_desc *p)
+{
+	return p->des01.tx.own;
+}
+
+static int ndesc_get_rx_owner(struct dma_desc *p)
+{
+	return p->des01.rx.own;
+}
+
+static void ndesc_set_tx_owner(struct dma_desc *p)
+{
+	p->des01.tx.own = 1;
+}
+
+static void ndesc_set_rx_owner(struct dma_desc *p)
+{
+	p->des01.rx.own = 1;
+}
+
+static int ndesc_get_tx_ls(struct dma_desc *p)
+{
+	return p->des01.tx.last_segment;
+}
+
+static void ndesc_release_tx_desc(struct dma_desc *p)
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
+static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				  int csum_flag)
+{
+	p->des01.tx.first_segment = is_fs;
+	p->des01.tx.buffer1_size = len;
+}
+
+static void ndesc_clear_tx_ic(struct dma_desc *p)
+{
+	p->des01.tx.interrupt = 0;
+}
+
+static void ndesc_close_tx_desc(struct dma_desc *p)
+{
+	p->des01.tx.last_segment = 1;
+	p->des01.tx.interrupt = 1;
+}
+
+static int ndesc_get_rx_frame_len(struct dma_desc *p)
+{
+	return p->des01.rx.frame_length;
+}
+
+struct stmmac_desc_ops ndesc_ops = {
+	.tx_status = ndesc_get_tx_status,
+	.rx_status = ndesc_get_rx_status,
+	.get_tx_len = ndesc_get_tx_len,
+	.init_rx_desc = ndesc_init_rx_desc,
+	.init_tx_desc = ndesc_init_tx_desc,
+	.get_tx_owner = ndesc_get_tx_owner,
+	.get_rx_owner = ndesc_get_rx_owner,
+	.release_tx_desc = ndesc_release_tx_desc,
+	.prepare_tx_desc = ndesc_prepare_tx_desc,
+	.clear_tx_ic = ndesc_clear_tx_ic,
+	.close_tx_desc = ndesc_close_tx_desc,
+	.get_tx_ls = ndesc_get_tx_ls,
+	.set_tx_owner = ndesc_set_tx_owner,
+	.set_rx_owner = ndesc_set_rx_owner,
+	.get_rx_frame_len = ndesc_get_rx_frame_len,
+};
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index ba35e69..55b9aca 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -120,3 +120,5 @@ static inline int stmmac_claim_resource(struct platform_device *pdev)
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
+extern struct stmmac_desc_ops enh_desc_ops;
+extern struct stmmac_desc_ops ndesc_ops;
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index cc532ef..dafe4dc 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1582,10 +1582,13 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	struct mac_device_info *device;
 
-	if (priv->is_gmac)
+	if (priv->is_gmac) {
 		device = dwmac1000_setup(ioaddr);
-	else
+		device->desc = &enh_desc_ops;
+	} else {
 		device = dwmac100_setup(ioaddr);
+		device->desc = &ndesc_ops;
+	}
 
 	if (!device)
 		return -ENOMEM;
-- 
1.6.0.4

