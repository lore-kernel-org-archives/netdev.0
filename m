From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 09/13] stmmac: rename mac100 as dwmac100 and fix spare coding style
Date: Thu,  7 Jan 2010 10:07:19 +0100
Message-ID: <1262855243-6762-9-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:59531 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756339Ab0AGJHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:32 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4826C19A
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:27 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 95921BE2
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:26 +0000 (GMT)
In-Reply-To: <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch renames the mac100.[ch] as dwmac100.[ch]; this
looks more specific and appropriate for these chip series.
The patch also fixes some spare coding style issues.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Makefile      |    2 +-
 drivers/net/stmmac/common.h      |    2 +-
 drivers/net/stmmac/dwmac100.c    |  540 ++++++++++++++++++++++++++++++++++++++
 drivers/net/stmmac/dwmac100.h    |  116 ++++++++
 drivers/net/stmmac/mac100.c      |  535 -------------------------------------
 drivers/net/stmmac/mac100.h      |  116 --------
 drivers/net/stmmac/stmmac_main.c |    2 +-
 7 files changed, 659 insertions(+), 654 deletions(-)
 create mode 100644 drivers/net/stmmac/dwmac100.c
 create mode 100644 drivers/net/stmmac/dwmac100.h
 delete mode 100644 drivers/net/stmmac/mac100.c
 delete mode 100644 drivers/net/stmmac/mac100.h

diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index c8f499a..2ed8385 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o dwmac_lib.o \
-		mac100.o  gmac.o $(stmmac-y)
+		dwmac100.o  gmac.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 6f8fe64..987faaa 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -225,7 +225,7 @@ struct mac_device_info {
 };
 
 struct mac_device_info *gmac_setup(unsigned long addr);
-struct mac_device_info *mac100_setup(unsigned long addr);
+struct mac_device_info *dwmac100_setup(unsigned long addr);
 
 extern void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
 				unsigned int high, unsigned int low);
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
new file mode 100644
index 0000000..010c8b2
--- /dev/null
+++ b/drivers/net/stmmac/dwmac100.c
@@ -0,0 +1,540 @@
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
+#include <linux/netdevice.h>
+#include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#include "common.h"
+#include "dwmac100.h"
+#include "dwmac_dma.h"
+
+#undef DWMAC100_DEBUG
+/*#define DWMAC100_DEBUG*/
+#ifdef DWMAC100_DEBUG
+#define DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define DBG(fmt, args...)  do { } while (0)
+#endif
+
+static void dwmac100_core_init(unsigned long ioaddr)
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
+static void dwmac100_dump_mac_regs(unsigned long ioaddr)
+{
+	pr_info("\t----------------------------------------------\n"
+		"\t  DWMAC 100 CSR (base addr = 0x%8x)\n"
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
+static int dwmac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
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
+static void dwmac100_dma_operation_mode(unsigned long ioaddr, int txmode,
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
+static void dwmac100_dump_dma_regs(unsigned long ioaddr)
+{
+	int i;
+
+	DBG(KERN_DEBUG "DWMAC 100 DMA CSR \n");
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
+static void dwmac100_dma_diagnostic_fr(void *data,
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
+static int dwmac100_get_tx_frame_status(void *data,
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
+static int dwmac100_get_tx_len(struct dma_desc *p)
+{
+	return p->des01.tx.buffer1_size;
+}
+
+/* This function verifies if each incoming frame has some errors
+ * and, if required, updates the multicast statistics.
+ * In case of success, it returns csum_none becasue the device
+ * is not able to compute the csum in HW. */
+static int dwmac100_get_rx_frame_status(void *data,
+				      struct stmmac_extra_stats *x,
+				      struct dma_desc *p)
+{
+	int ret = csum_none;
+	struct net_device_stats *stats = (struct net_device_stats *)data;
+
+	if (unlikely(p->des01.rx.last_descriptor == 0)) {
+		pr_warning("dwmac100 Error: Oversized Ethernet "
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
+static void dwmac100_irq_status(unsigned long ioaddr)
+{
+	return;
+}
+
+static void dwmac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+			  unsigned int reg_n)
+{
+	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
+}
+
+static void dwmac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+			  unsigned int reg_n)
+{
+	stmmac_get_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
+}
+
+static void dwmac100_set_filter(struct net_device *dev)
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
+static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
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
+static void dwmac100_pmt(unsigned long ioaddr, unsigned long mode)
+{
+	return;
+}
+
+static void dwmac100_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
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
+static void dwmac100_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
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
+static int dwmac100_get_tx_owner(struct dma_desc *p)
+{
+	return p->des01.tx.own;
+}
+
+static int dwmac100_get_rx_owner(struct dma_desc *p)
+{
+	return p->des01.rx.own;
+}
+
+static void dwmac100_set_tx_owner(struct dma_desc *p)
+{
+	p->des01.tx.own = 1;
+}
+
+static void dwmac100_set_rx_owner(struct dma_desc *p)
+{
+	p->des01.rx.own = 1;
+}
+
+static int dwmac100_get_tx_ls(struct dma_desc *p)
+{
+	return p->des01.tx.last_segment;
+}
+
+static void dwmac100_release_tx_desc(struct dma_desc *p)
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
+static void dwmac100_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
+				   int csum_flag)
+{
+	p->des01.tx.first_segment = is_fs;
+	p->des01.tx.buffer1_size = len;
+}
+
+static void dwmac100_clear_tx_ic(struct dma_desc *p)
+{
+	p->des01.tx.interrupt = 0;
+}
+
+static void dwmac100_close_tx_desc(struct dma_desc *p)
+{
+	p->des01.tx.last_segment = 1;
+	p->des01.tx.interrupt = 1;
+}
+
+static int dwmac100_get_rx_frame_len(struct dma_desc *p)
+{
+	return p->des01.rx.frame_length;
+}
+
+struct stmmac_ops dwmac100_ops = {
+	.core_init = dwmac100_core_init,
+	.dump_regs = dwmac100_dump_mac_regs,
+	.host_irq_status = dwmac100_irq_status,
+	.set_filter = dwmac100_set_filter,
+	.flow_ctrl = dwmac100_flow_ctrl,
+	.pmt = dwmac100_pmt,
+	.set_umac_addr = dwmac100_set_umac_addr,
+	.get_umac_addr = dwmac100_get_umac_addr,
+};
+
+struct stmmac_dma_ops dwmac100_dma_ops = {
+	.init = dwmac100_dma_init,
+	.dump_regs = dwmac100_dump_dma_regs,
+	.dma_mode = dwmac100_dma_operation_mode,
+	.dma_diagnostic_fr = dwmac100_dma_diagnostic_fr,
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
+struct stmmac_desc_ops dwmac100_desc_ops = {
+	.tx_status = dwmac100_get_tx_frame_status,
+	.rx_status = dwmac100_get_rx_frame_status,
+	.get_tx_len = dwmac100_get_tx_len,
+	.init_rx_desc = dwmac100_init_rx_desc,
+	.init_tx_desc = dwmac100_init_tx_desc,
+	.get_tx_owner = dwmac100_get_tx_owner,
+	.get_rx_owner = dwmac100_get_rx_owner,
+	.release_tx_desc = dwmac100_release_tx_desc,
+	.prepare_tx_desc = dwmac100_prepare_tx_desc,
+	.clear_tx_ic = dwmac100_clear_tx_ic,
+	.close_tx_desc = dwmac100_close_tx_desc,
+	.get_tx_ls = dwmac100_get_tx_ls,
+	.set_tx_owner = dwmac100_set_tx_owner,
+	.set_rx_owner = dwmac100_set_rx_owner,
+	.get_rx_frame_len = dwmac100_get_rx_frame_len,
+};
+
+struct mac_device_info *dwmac100_setup(unsigned long ioaddr)
+{
+	struct mac_device_info *mac;
+
+	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+
+	pr_info("\tDWMAC100\n");
+
+	mac->mac = &dwmac100_ops;
+	mac->desc = &dwmac100_desc_ops;
+	mac->dma = &dwmac100_dma_ops;
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
diff --git a/drivers/net/stmmac/mac100.c b/drivers/net/stmmac/mac100.c
deleted file mode 100644
index b675f7c..0000000
--- a/drivers/net/stmmac/mac100.c
+++ /dev/null
@@ -1,535 +0,0 @@
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
-#include "dwmac_dma.h"
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
-struct stmmac_ops mac100_ops = {
-	.core_init = mac100_core_init,
-	.dump_regs = mac100_dump_mac_regs,
-	.host_irq_status = mac100_irq_status,
-	.set_filter = mac100_set_filter,
-	.flow_ctrl = mac100_flow_ctrl,
-	.pmt = mac100_pmt,
-	.set_umac_addr = mac100_set_umac_addr,
-	.get_umac_addr = mac100_get_umac_addr,
-};
-
-struct stmmac_dma_ops mac100_dma_ops = {
-	.init = mac100_dma_init,
-	.dump_regs = mac100_dump_dma_regs,
-	.dma_mode = mac100_dma_operation_mode,
-	.dma_diagnostic_fr = mac100_dma_diagnostic_fr,
-	.enable_dma_transmission = dwmac_enable_dma_transmission,
-	.enable_dma_irq = dwmac_enable_dma_irq,
-	.disable_dma_irq = dwmac_disable_dma_irq,
-	.start_tx = dwmac_dma_start_tx,
-	.stop_tx = dwmac_dma_stop_tx,
-	.start_rx = dwmac_dma_start_rx,
-	.stop_rx = dwmac_dma_stop_rx,
-	.dma_interrupt = dwmac_dma_interrupt,
-};
-
-struct stmmac_desc_ops mac100_desc_ops = {
-	.tx_status = mac100_get_tx_frame_status,
-	.rx_status = mac100_get_rx_frame_status,
-	.get_tx_len = mac100_get_tx_len,
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
-	mac->mac = &mac100_ops;
-	mac->desc = &mac100_desc_ops;
-	mac->dma = &mac100_dma_ops;
-
-	mac->pmt = PMT_NOT_SUPPORTED;
-	mac->link.port = MAC_CONTROL_PS;
-	mac->link.duplex = MAC_CONTROL_F;
-	mac->link.speed = 0;
-	mac->mii.addr = MAC_MII_ADDR;
-	mac->mii.data = MAC_MII_DATA;
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
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index e6c5a3c..e79e00b 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1585,7 +1585,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	if (priv->is_gmac)
 		device = gmac_setup(ioaddr);
 	else
-		device = mac100_setup(ioaddr);
+		device = dwmac100_setup(ioaddr);
 
 	if (!device)
 		return -ENOMEM;
-- 
1.6.0.4

