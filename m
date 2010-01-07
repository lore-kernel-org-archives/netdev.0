From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 10/13] stmmac: rename the gmac as dwmac1000 and split core and dma parts
Date: Thu,  7 Jan 2010 10:07:20 +0100
Message-ID: <1262855243-6762-10-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-9-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:47130 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756346Ab0AGJHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:33 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3874B19C
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:28 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7CBB6BE9
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:27 +0000 (GMT)
In-Reply-To: <1262855243-6762-9-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dwmac1000 naming instead of gmac.
The patch also splits the gmac.c file in two new ones:
dwmac1000_core.c and dwmac1000_dma.c.
This could actually help on some architectures where different
DMA engines are used.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Makefile         |    5 +-
 drivers/net/stmmac/common.h         |    2 +-
 drivers/net/stmmac/descs.h          |    4 +-
 drivers/net/stmmac/dwmac1000.h      |  221 +++++++++++
 drivers/net/stmmac/dwmac1000_core.c |  245 ++++++++++++
 drivers/net/stmmac/dwmac1000_dma.c  |  474 ++++++++++++++++++++++++
 drivers/net/stmmac/gmac.c           |  700 -----------------------------------
 drivers/net/stmmac/gmac.h           |  204 ----------
 drivers/net/stmmac/stmmac_main.c    |    2 +-
 9 files changed, 947 insertions(+), 910 deletions(-)
 create mode 100644 drivers/net/stmmac/dwmac1000.h
 create mode 100644 drivers/net/stmmac/dwmac1000_core.c
 create mode 100644 drivers/net/stmmac/dwmac1000_dma.c
 delete mode 100644 drivers/net/stmmac/gmac.c
 delete mode 100644 drivers/net/stmmac/gmac.h

diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index 2ed8385..c776af1 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
-stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o dwmac_lib.o \
-		dwmac100.o  gmac.o $(stmmac-y)
+stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
+	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
+	      dwmac100.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 987faaa..25b53d4 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -224,7 +224,7 @@ struct mac_device_info {
 	struct mac_link link;
 };
 
-struct mac_device_info *gmac_setup(unsigned long addr);
+struct mac_device_info *dwmac1000_setup(unsigned long addr);
 struct mac_device_info *dwmac100_setup(unsigned long addr);
 
 extern void stmmac_set_mac_addr(unsigned long ioaddr, u8 addr[6],
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
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/stmmac/dwmac1000.h
new file mode 100644
index 0000000..3d54d6c
--- /dev/null
+++ b/drivers/net/stmmac/dwmac1000.h
@@ -0,0 +1,221 @@
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
+#include <linux/netdevice.h>
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
+enum dwmac1000_irq_status {
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
+/* Threshold for Activating the FC */
+enum rfa {
+	act_full_minus_1 = 0x00800000,
+	act_full_minus_2 = 0x00800200,
+	act_full_minus_3 = 0x00800400,
+	act_full_minus_4 = 0x00800600,
+};
+/* Threshold for Deactivating the FC */
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
+#undef DWMAC1000_DEBUG
+/* #define DWMAC1000__DEBUG */
+#undef FRAME_FILTER_DEBUG
+/* #define FRAME_FILTER_DEBUG */
+#ifdef DWMAC1000__DEBUG
+#define DBG(fmt, args...)  printk(fmt, ## args)
+#else
+#define DBG(fmt, args...)  do { } while (0)
+#endif
+
+extern struct stmmac_dma_ops dwmac1000_dma_ops;
+extern struct stmmac_desc_ops dwmac1000_desc_ops;
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
new file mode 100644
index 0000000..928eac0
--- /dev/null
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -0,0 +1,245 @@
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
+static void dwmac1000_core_init(unsigned long ioaddr)
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
+static void dwmac1000_dump_regs(unsigned long ioaddr)
+{
+	int i;
+	pr_info("\tDWMAC1000 regs (base addr = 0x%8x)\n", (unsigned int)ioaddr);
+
+	for (i = 0; i < 55; i++) {
+		int offset = i * 4;
+		pr_info("\tReg No. %d (offset 0x%x): 0x%08x\n", i,
+			offset, readl(ioaddr + offset));
+	}
+	return;
+}
+
+static void dwmac1000_set_umac_addr(unsigned long ioaddr, unsigned char *addr,
+				unsigned int reg_n)
+{
+	stmmac_set_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
+				GMAC_ADDR_LOW(reg_n));
+}
+
+static void dwmac1000_get_umac_addr(unsigned long ioaddr, unsigned char *addr,
+				unsigned int reg_n)
+{
+	stmmac_get_mac_addr(ioaddr, addr, GMAC_ADDR_HIGH(reg_n),
+				GMAC_ADDR_LOW(reg_n));
+}
+
+static void dwmac1000_set_filter(struct net_device *dev)
+{
+	unsigned long ioaddr = dev->base_addr;
+	unsigned int value = 0;
+
+	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
+	    __func__, dev->mc_count, dev->uc.count);
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
+	if (dev->uc.count > GMAC_MAX_UNICAST_ADDRESSES)
+		/* Switch to promiscuous mode is more than 16 addrs
+		   are required */
+		value |= GMAC_FRAME_FILTER_PR;
+	else {
+		int reg = 1;
+		struct netdev_hw_addr *ha;
+
+			list_for_each_entry(ha, &dev->uc.list, list) {
+				dwmac1000_set_umac_addr(ioaddr, ha->addr, reg);
+				reg++;
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
+static void dwmac1000_flow_ctrl(unsigned long ioaddr, unsigned int duplex,
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
+static void dwmac1000_pmt(unsigned long ioaddr, unsigned long mode)
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
+static void dwmac1000_irq_status(unsigned long ioaddr)
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
+struct stmmac_ops dwmac1000_ops = {
+	.core_init = dwmac1000_core_init,
+	.dump_regs = dwmac1000_dump_regs,
+	.host_irq_status = dwmac1000_irq_status,
+	.set_filter = dwmac1000_set_filter,
+	.flow_ctrl = dwmac1000_flow_ctrl,
+	.pmt = dwmac1000_pmt,
+	.set_umac_addr = dwmac1000_set_umac_addr,
+	.get_umac_addr = dwmac1000_get_umac_addr,
+};
+
+struct mac_device_info *dwmac1000_setup(unsigned long ioaddr)
+{
+	struct mac_device_info *mac;
+	u32 uid = readl(ioaddr + GMAC_VERSION);
+
+	pr_info("\tDWMAC1000 - user ID: 0x%x, Synopsys ID: 0x%x\n",
+		((uid & 0x0000ff00) >> 8), (uid & 0x000000ff));
+
+	mac = kzalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+
+	mac->mac = &dwmac1000_ops;
+	mac->desc = &dwmac1000_desc_ops;
+	mac->dma = &dwmac1000_dma_ops;
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
index 0000000..6824550
--- /dev/null
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -0,0 +1,474 @@
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
+static int dwmac1000_dma_init(unsigned long ioaddr, int pbl, u32 dma_tx,
+			      u32 dma_rx)
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
+static void dwmac1000_flush_tx_fifo(unsigned long ioaddr)
+{
+	u32 csr6 = readl(ioaddr + DMA_CONTROL);
+	writel((csr6 | DMA_CONTROL_FTF), ioaddr + DMA_CONTROL);
+
+	do {} while ((readl(ioaddr + DMA_CONTROL) & DMA_CONTROL_FTF));
+}
+
+static void dwmac1000_dma_operation_mode(unsigned long ioaddr, int txmode,
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
+		/* Set the transmit threshold */
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
+static void dwmac1000_dma_diagnostic_fr(void *data,
+		  struct stmmac_extra_stats *x, unsigned long ioaddr)
+{
+	return;
+}
+
+static void dwmac1000_dump_dma_regs(unsigned long ioaddr)
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
+static int dwmac1000_get_tx_frame_status(void *data,
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
+			dwmac1000_flush_tx_fifo(ioaddr);
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
+			dwmac1000_flush_tx_fifo(ioaddr);
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
+			dwmac1000_flush_tx_fifo(ioaddr);
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
+static int dwmac1000_get_tx_len(struct dma_desc *p)
+{
+	return p->des01.etx.buffer1_size;
+}
+
+static int dwmac1000_coe_rdes0(int ipc_err, int type, int payload_err)
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
+static int dwmac1000_get_rx_frame_status(void *data,
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
+	ret = dwmac1000_coe_rdes0(p->des01.erx.ipc_csum_error,
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
+static void dwmac1000_init_rx_desc(struct dma_desc *p, unsigned int ring_size,
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
+static void dwmac1000_init_tx_desc(struct dma_desc *p, unsigned int ring_size)
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
+static int dwmac1000_get_tx_owner(struct dma_desc *p)
+{
+	return p->des01.etx.own;
+}
+
+static int dwmac1000_get_rx_owner(struct dma_desc *p)
+{
+	return p->des01.erx.own;
+}
+
+static void dwmac1000_set_tx_owner(struct dma_desc *p)
+{
+	p->des01.etx.own = 1;
+}
+
+static void dwmac1000_set_rx_owner(struct dma_desc *p)
+{
+	p->des01.erx.own = 1;
+}
+
+static int dwmac1000_get_tx_ls(struct dma_desc *p)
+{
+	return p->des01.etx.last_segment;
+}
+
+static void dwmac1000_release_tx_desc(struct dma_desc *p)
+{
+	int ter = p->des01.etx.end_ring;
+
+	memset(p, 0, sizeof(struct dma_desc));
+	p->des01.etx.end_ring = ter;
+
+	return;
+}
+
+static void dwmac1000_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
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
+static void dwmac1000_clear_tx_ic(struct dma_desc *p)
+{
+	p->des01.etx.interrupt = 0;
+}
+
+static void dwmac1000_close_tx_desc(struct dma_desc *p)
+{
+	p->des01.etx.last_segment = 1;
+	p->des01.etx.interrupt = 1;
+}
+
+static int dwmac1000_get_rx_frame_len(struct dma_desc *p)
+{
+	return p->des01.erx.frame_length;
+}
+
+struct stmmac_dma_ops dwmac1000_dma_ops = {
+	.init = dwmac1000_dma_init,
+	.dump_regs = dwmac1000_dump_dma_regs,
+	.dma_mode = dwmac1000_dma_operation_mode,
+	.dma_diagnostic_fr = dwmac1000_dma_diagnostic_fr,
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
+struct stmmac_desc_ops dwmac1000_desc_ops = {
+	.tx_status = dwmac1000_get_tx_frame_status,
+	.rx_status = dwmac1000_get_rx_frame_status,
+	.get_tx_len = dwmac1000_get_tx_len,
+	.init_rx_desc = dwmac1000_init_rx_desc,
+	.init_tx_desc = dwmac1000_init_tx_desc,
+	.get_tx_owner = dwmac1000_get_tx_owner,
+	.get_rx_owner = dwmac1000_get_rx_owner,
+	.release_tx_desc = dwmac1000_release_tx_desc,
+	.prepare_tx_desc = dwmac1000_prepare_tx_desc,
+	.clear_tx_ic = dwmac1000_clear_tx_ic,
+	.close_tx_desc = dwmac1000_close_tx_desc,
+	.get_tx_ls = dwmac1000_get_tx_ls,
+	.set_tx_owner = dwmac1000_set_tx_owner,
+	.set_rx_owner = dwmac1000_set_rx_owner,
+	.get_rx_frame_len = dwmac1000_get_rx_frame_len,
+};
diff --git a/drivers/net/stmmac/gmac.c b/drivers/net/stmmac/gmac.c
deleted file mode 100644
index 0788092..0000000
--- a/drivers/net/stmmac/gmac.c
+++ /dev/null
@@ -1,700 +0,0 @@
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
-#include "dwmac_dma.h"
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
-		/* Set the transmit threshold */
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
-	    __func__, dev->mc_count, dev->uc.count);
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
-	if (dev->uc.count > GMAC_MAX_UNICAST_ADDRESSES)
-		/* Switch to promiscuous mode is more than 16 addrs
-		   are required */
-		value |= GMAC_FRAME_FILTER_PR;
-	else {
-		int reg = 1;
-		struct netdev_hw_addr *ha;
-
-		list_for_each_entry(ha, &dev->uc.list, list) {
-			gmac_set_umac_addr(ioaddr, ha->addr, reg);
-			reg++;
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
-struct stmmac_ops gmac_ops = {
-	.core_init = gmac_core_init,
-	.dump_regs = gmac_dump_regs,
-	.host_irq_status = gmac_irq_status,
-	.set_filter = gmac_set_filter,
-	.flow_ctrl = gmac_flow_ctrl,
-	.pmt = gmac_pmt,
-	.set_umac_addr = gmac_set_umac_addr,
-	.get_umac_addr = gmac_get_umac_addr,
-};
-
-struct stmmac_dma_ops gmac_dma_ops = {
-	.init = gmac_dma_init,
-	.dump_regs = gmac_dump_dma_regs,
-	.dma_mode = gmac_dma_operation_mode,
-	.dma_diagnostic_fr = gmac_dma_diagnostic_fr,
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
-struct stmmac_desc_ops gmac_desc_ops = {
-	.tx_status = gmac_get_tx_frame_status,
-	.rx_status = gmac_get_rx_frame_status,
-	.get_tx_len = gmac_get_tx_len,
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
-	mac->mac = &gmac_ops;
-	mac->desc = &gmac_desc_ops;
-	mac->dma = &gmac_dma_ops;
-
-	mac->pmt = PMT_SUPPORTED;
-	mac->link.port = GMAC_CONTROL_PS;
-	mac->link.duplex = GMAC_CONTROL_DM;
-	mac->link.speed = GMAC_CONTROL_FES;
-	mac->mii.addr = GMAC_MII_ADDR;
-	mac->mii.data = GMAC_MII_DATA;
-
-	return mac;
-}
diff --git a/drivers/net/stmmac/gmac.h b/drivers/net/stmmac/gmac.h
deleted file mode 100644
index 2e82d6c..0000000
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
-/* Threshold for Activating the FC */
-enum rfa {
-	act_full_minus_1 = 0x00800000,
-	act_full_minus_2 = 0x00800200,
-	act_full_minus_3 = 0x00800400,
-	act_full_minus_4 = 0x00800600,
-};
-/* Threshold for Deactivating the FC */
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
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index e79e00b..16d4e1c 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1583,7 +1583,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 	struct mac_device_info *device;
 
 	if (priv->is_gmac)
-		device = gmac_setup(ioaddr);
+		device = dwmac1000_setup(ioaddr);
 	else
 		device = dwmac100_setup(ioaddr);
 
-- 
1.6.0.4

