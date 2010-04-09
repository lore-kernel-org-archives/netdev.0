From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: split core and dma for the mac10/100
Date: Fri,  9 Apr 2010 12:24:16 +0200
Message-ID: <1270808662-7115-2-git-send-email-peppe.cavallaro@st.com>
References: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:42281 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757611Ab0DIKYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 06:24:37 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 99B61153
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:24:34 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0B0EF195D
	for <netdev@vger.kernel.org>; Fri,  9 Apr 2010 10:24:33 +0000 (GMT)
In-Reply-To: <1270808662-7115-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch splits core and dma parts for the mac10/100 device.
This was already done for the GMAC device.
It should make more flexible the driver to support other chips.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Makefile        |    2 +-
 drivers/net/stmmac/dwmac100.c      |  537 ------------------------------------
 drivers/net/stmmac/dwmac100.h      |   17 ++
 drivers/net/stmmac/dwmac100_core.c |  202 ++++++++++++++
 drivers/net/stmmac/dwmac100_dma.c  |  353 +++++++++++++++++++++++
 5 files changed, 573 insertions(+), 538 deletions(-)
 delete mode 100644 drivers/net/stmmac/dwmac100.c
 create mode 100644 drivers/net/stmmac/dwmac100_core.c
 create mode 100644 drivers/net/stmmac/dwmac100_dma.c

diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index c776af1..b14bd56 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -2,4 +2,4 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
-	      dwmac100.o $(stmmac-y)
+	      dwmac100_core.o dwmac100_dma.o $(stmmac-y)
diff --git a/drivers/net/stmmac/dwmac100.c b/drivers/net/stmmac/dwmac100.c
deleted file mode 100644
index 803b037..0000000
--- a/drivers/net/stmmac/dwmac100.c
+++ /dev/null
@@ -1,537 +0,0 @@
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
-#include <linux/crc32.h>
-#include <linux/mii.h>
-#include <linux/phy.h>
-
-#include "common.h"
-#include "dwmac100.h"
-#include "dwmac_dma.h"
-
-#undef DWMAC100_DEBUG
-/*#define DWMAC100_DEBUG*/
-#ifdef DWMAC100_DEBUG
-#define DBG(fmt, args...)  printk(fmt, ## args)
-#else
-#define DBG(fmt, args...)  do { } while (0)
-#endif
-
-static void dwmac100_core_init(unsigned long ioaddr)
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
-static void dwmac100_dump_mac_regs(unsigned long ioaddr)
-{
-	pr_info("\t----------------------------------------------\n"
-		"\t  DWMAC 100 CSR (base addr = 0x%8x)\n"
-		"\t----------------------------------------------\n",
-		(unsigned int)ioaddr);
-	pr_info("\tcontrol reg (offset 0x%x): 0x%08x\n", MAC_CONTROL,
-		readl(ioaddr + MAC_CONTROL));
-	pr_info("\taddr HI (offset 0x%x): 0x%08x\n ", MAC_ADDR_HIGH,
-		readl(ioaddr + MAC_ADDR_HIGH));
-	pr_info("\taddr LO (offset 0x%x): 0x%08x\n", MAC_ADDR_LOW,
-		readl(ioaddr + MAC_ADDR_LOW));
-	pr_info("\tmulticast hash HI (offset 0x%x): 0x%08x\n",
-		MAC_HASH_HIGH, readl(ioaddr + MAC_HASH_HIGH));
-	pr_info("\tmulticast hash LO (offset 0x%x): 0x%08x\n",
-		MAC_HASH_LOW, readl(ioaddr + MAC_HASH_LOW));
-	pr_info("\tflow control (offset 0x%x): 0x%08x\n",
-		MAC_FLOW_CTRL, readl(ioaddr + MAC_FLOW_CTRL));
-	pr_info("\tVLAN1 tag (offset 0x%x): 0x%08x\n", MAC_VLAN1,
-		readl(ioaddr + MAC_VLAN1));
-	pr_info("\tVLAN2 tag (offset 0x%x): 0x%08x\n", MAC_VLAN2,
-		readl(ioaddr + MAC_VLAN2));
-	pr_info("\n\tMAC management counter registers\n");
-	pr_info("\t MMC crtl (offset 0x%x): 0x%08x\n",
-		MMC_CONTROL, readl(ioaddr + MMC_CONTROL));
-	pr_info("\t MMC High Interrupt (offset 0x%x): 0x%08x\n",
-		MMC_HIGH_INTR, readl(ioaddr + MMC_HIGH_INTR));
-	pr_info("\t MMC Low Interrupt (offset 0x%x): 0x%08x\n",
-		MMC_LOW_INTR, readl(ioaddr + MMC_LOW_INTR));
-	pr_info("\t MMC High Interrupt Mask (offset 0x%x): 0x%08x\n",
-		MMC_HIGH_INTR_MASK, readl(ioaddr + MMC_HIGH_INTR_MASK));
-	pr_info("\t MMC Low Interrupt Mask (offset 0x%x): 0x%08x\n",
-		MMC_LOW_INTR_MASK, readl(ioaddr + MMC_LOW_INTR_MASK));
-	return;
-}
-
-static int dwmac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
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
-static void dwmac100_dma_operation_mode(unsigned long ioaddr, int txmode,
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
-static void dwmac100_dump_dma_regs(unsigned long ioaddr)
-{
-	int i;
-
-	DBG(KERN_DEBUG "DWMAC 100 DMA CSR \n");
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
- * the receive missed frames. */
-static void dwmac100_dma_diagnostic_fr(void *data,
-				     struct stmmac_extra_stats *x,
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
-static int dwmac100_get_tx_frame_status(void *data,
-				      struct stmmac_extra_stats *x,
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
-static int dwmac100_get_tx_len(struct dma_desc *p)
-{
-	return p->des01.tx.buffer1_size;
-}
-
-/* This function verifies if each incoming frame has some errors
- * and, if required, updates the multicast statistics.
- * In case of success, it returns csum_none becasue the device
- * is not able to compute the csum in HW. */
-static int dwmac100_get_rx_frame_status(void *data,
-				      struct stmmac_extra_stats *x,
-				      struct dma_desc *p)
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
-static void dwmac100_irq_status(unsigned long ioaddr)
-{
-	return;
-}
-
-static void dwmac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
-			  unsigned int reg_n)
-{
-	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
-}
-
-static void dwmac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
-			  unsigned int reg_n)
-{
-	stmmac_get_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
-}
-
-static void dwmac100_set_filter(struct net_device *dev)
-{
-	unsigned long ioaddr = dev->base_addr;
-	u32 value = readl(ioaddr + MAC_CONTROL);
-
-	if (dev->flags & IFF_PROMISC) {
-		value |= MAC_CONTROL_PR;
-		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_IF | MAC_CONTROL_HO |
-			   MAC_CONTROL_HP);
-	} else if ((netdev_mc_count(dev) > HASH_TABLE_SIZE)
-		   || (dev->flags & IFF_ALLMULTI)) {
-		value |= MAC_CONTROL_PM;
-		value &= ~(MAC_CONTROL_PR | MAC_CONTROL_IF | MAC_CONTROL_HO);
-		writel(0xffffffff, ioaddr + MAC_HASH_HIGH);
-		writel(0xffffffff, ioaddr + MAC_HASH_LOW);
-	} else if (netdev_mc_empty(dev)) {	/* no multicast */
-		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF |
-			   MAC_CONTROL_HO | MAC_CONTROL_HP);
-	} else {
-		u32 mc_filter[2];
-		struct dev_mc_list *mclist;
-
-		/* Perfect filter mode for physical address and Hash
-		   filter for multicast */
-		value |= MAC_CONTROL_HP;
-		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR |
-			   MAC_CONTROL_IF | MAC_CONTROL_HO);
-
-		memset(mc_filter, 0, sizeof(mc_filter));
-		netdev_for_each_mc_addr(mclist, dev) {
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
-static void dwmac100_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
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
-/* No PMT module supported for this Ethernet Controller.
- * Tested on ST platforms only.
- */
-static void dwmac100_pmt(unsigned long ioaddr, unsigned long mode)
-{
-	return;
-}
-
-static void dwmac100_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
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
-				   int csum_flag)
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
-struct stmmac_ops dwmac100_ops = {
-	.core_init = dwmac100_core_init,
-	.dump_regs = dwmac100_dump_mac_regs,
-	.host_irq_status = dwmac100_irq_status,
-	.set_filter = dwmac100_set_filter,
-	.flow_ctrl = dwmac100_flow_ctrl,
-	.pmt = dwmac100_pmt,
-	.set_umac_addr = dwmac100_set_umac_addr,
-	.get_umac_addr = dwmac100_get_umac_addr,
-};
-
-struct stmmac_dma_ops dwmac100_dma_ops = {
-	.init = dwmac100_dma_init,
-	.dump_regs = dwmac100_dump_dma_regs,
-	.dma_mode = dwmac100_dma_operation_mode,
-	.dma_diagnostic_fr = dwmac100_dma_diagnostic_fr,
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
-struct stmmac_desc_ops dwmac100_desc_ops = {
-	.tx_status = dwmac100_get_tx_frame_status,
-	.rx_status = dwmac100_get_rx_frame_status,
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
-
-struct mac_device_info *dwmac100_setup(unsigned long ioaddr)
-{
-	struct mac_device_info *mac;
-
-	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
-
-	pr_info("\tDWMAC100\n");
-
-	mac->mac = &dwmac100_ops;
-	mac->desc = &dwmac100_desc_ops;
-	mac->dma = &dwmac100_dma_ops;
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
diff --git a/drivers/net/stmmac/dwmac100.h b/drivers/net/stmmac/dwmac100.h
index 0f8f110..9f4ba2e 100644
--- a/drivers/net/stmmac/dwmac100.h
+++ b/drivers/net/stmmac/dwmac100.h
@@ -22,6 +22,9 @@
   Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
 *******************************************************************************/
 
+#include <linux/phy.h>
+#include "common.h"
+
 /*----------------------------------------------------------------------------
  *	 			MAC BLOCK defines
  *---------------------------------------------------------------------------*/
@@ -114,3 +117,17 @@ enum ttc_control {
 #define DMA_MISSED_FRAME_OVE_CNTR 0x0ffe0000	/* Overflow Frame Counter */
 #define DMA_MISSED_FRAME_OVE_M	0x00010000	/* Missed Frame Overflow */
 #define DMA_MISSED_FRAME_M_CNTR	0x0000ffff	/* Missed Frame Couinter */
+
+#undef DWMAC100_DEBUG
+/* #define DWMAC100__DEBUG */
+#undef FRAME_FILTER_DEBUG
+/* #define FRAME_FILTER_DEBUG */
+#ifdef DWMAC100__DEBUG
+#define DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define DBG(fmt, args...)  do { } while (0)
+#endif
+
+extern struct stmmac_dma_ops dwmac100_dma_ops;
+extern struct stmmac_desc_ops dwmac100_desc_ops;
+
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/stmmac/dwmac100_core.c
new file mode 100644
index 0000000..7455a0c
--- /dev/null
+++ b/drivers/net/stmmac/dwmac100_core.c
@@ -0,0 +1,202 @@
+/*******************************************************************************
+  This is the driver for the MAC 10/100 on-chip Ethernet controller
+  currently tested on all the ST boards based on STb7109 and stx7200 SoCs.
+
+  DWC Ether MAC 10/100 Universal version 4.0 has been used for developing
+  this code.
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
+#include "dwmac100.h"
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
+static void dwmac100_irq_status(unsigned long ioaddr)
+{
+	return;
+}
+
+static void dwmac100_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+				   unsigned int reg_n)
+{
+	stmmac_set_mac_addr(ioaddr, addr, MAC_ADDR_HIGH, MAC_ADDR_LOW);
+}
+
+static void dwmac100_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+				   unsigned int reg_n)
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
+	} else if ((netdev_mc_count(dev) > HASH_TABLE_SIZE)
+		   || (dev->flags & IFF_ALLMULTI)) {
+		value |= MAC_CONTROL_PM;
+		value &= ~(MAC_CONTROL_PR | MAC_CONTROL_IF | MAC_CONTROL_HO);
+		writel(0xffffffff, ioaddr + MAC_HASH_HIGH);
+		writel(0xffffffff, ioaddr + MAC_HASH_LOW);
+	} else if (netdev_mc_empty(dev)) {	/* no multicast */
+		value &= ~(MAC_CONTROL_PM | MAC_CONTROL_PR | MAC_CONTROL_IF |
+			   MAC_CONTROL_HO | MAC_CONTROL_HP);
+	} else {
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
+		netdev_for_each_mc_addr(mclist, dev) {
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
+			       unsigned int fc, unsigned int pause_time)
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
diff --git a/drivers/net/stmmac/dwmac100_dma.c b/drivers/net/stmmac/dwmac100_dma.c
new file mode 100644
index 0000000..7fcc526
--- /dev/null
+++ b/drivers/net/stmmac/dwmac100_dma.c
@@ -0,0 +1,353 @@
+/*******************************************************************************
+  This is the driver for the MAC 10/100 on-chip Ethernet controller
+  currently tested on all the ST boards based on STb7109 and stx7200 SoCs.
+
+  DWC Ether MAC 10/100 Universal version 4.0 has been used for developing
+  this code.
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
+#include "dwmac100.h"
+#include "dwmac_dma.h"
+
+static int dwmac100_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
+			     u32 dma_rx)
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
+					int rxmode)
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
+	DBG(KERN_DEBUG "DWMAC 100 DMA CSR\n");
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
+static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
+				       unsigned long ioaddr)
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
+static int dwmac100_get_tx_status(void *data, struct stmmac_extra_stats *x,
+				  struct dma_desc *p, unsigned long ioaddr)
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
+static int dwmac100_get_rx_status(void *data, struct stmmac_extra_stats *x,
+				  struct dma_desc *p)
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
+static void dwmac100_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
+				  int disable_rx_ic)
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
+				     int csum_flag)
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
+	.tx_status = dwmac100_get_tx_status,
+	.rx_status = dwmac100_get_rx_status,
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
-- 
1.6.0.4

