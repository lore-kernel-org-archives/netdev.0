From: "Anoop P.A" <anoop.pa@gmail.com>
Subject: [PATCH] Network driver for PMC-Sierra MSP71xx TSMAC.
Date: Thu, 24 Feb 2011 17:27:40 +0530
Message-ID: <1298548660-10546-1-git-send-email-anoop.pa@gmail.com>
Cc: Anoop P A <anoop.pa@gmail.com>
To: davem@davemloft.net, khilman@deeprootsystems.com, cyril@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anoop P A <anoop.pa@gmail.com>

This driver add support for triple speed mac (TSMAC) commonly found in MSP71xx family of SoC's.
It will make use of phylib.

Signed-off-by: Anoop P A <anoop.pa@gmail.com>
---
 drivers/net/Kconfig                             |    1 +
 drivers/net/Makefile                            |    1 +
 drivers/net/pmcmsp_tsmac/Kconfig                |   36 +
 drivers/net/pmcmsp_tsmac/Makefile               |    5 +
 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.c         | 4266 +++++++++++++++++++++++
 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.h         |  105 +
 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_local.h   |  924 +++++
 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_mdiobus.c |  205 ++
 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_user.c    | 2687 ++++++++++++++
 9 files changed, 8230 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/pmcmsp_tsmac/Kconfig
 create mode 100644 drivers/net/pmcmsp_tsmac/Makefile
 create mode 100644 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.c
 create mode 100644 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.h
 create mode 100644 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_local.h
 create mode 100644 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_mdiobus.c
 create mode 100644 drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_user.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 58706c1..c17ab81 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2531,6 +2531,7 @@ config S6GMAC
 	  will be called s6gmac.
 
 source "drivers/net/stmmac/Kconfig"
+source "drivers/net/pmcmsp_tsmac/Kconfig"
 
 config PCH_GBE
 	tristate "PCH Gigabit Ethernet"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index adc48c4..0d6454a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -37,6 +37,7 @@ obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_BE2NET) += benet/
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 obj-$(CONFIG_BNA) += bna/
+obj-$(CONFIG_PMC_MSP_TSMAC) += pmcmsp_tsmac/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff --git a/drivers/net/pmcmsp_tsmac/Kconfig b/drivers/net/pmcmsp_tsmac/Kconfig
new file mode 100644
index 0000000..3ec3acc
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/Kconfig
@@ -0,0 +1,36 @@
+config PMC_MSP_TSMAC
+	depends on MSP_HAS_TSMAC
+	select PHYLIB
+	select CRC32
+	select MII
+	tristate "PMC-Sierra MSP Triple-Speed Ethernet Support"
+	help
+	  This enables support for the integrated 10/100/1000 Ethernet
+	  of PMC-Sierra's MSP7140/MSP7150/MSP82XX SoC.
+
+if PMC_MSP_TSMAC
+
+config DESC_ALL_DSPRAM
+	bool "TX/RX Descriptors in DSPRAM"
+	depends on DMA_TO_SPRAM
+	default n
+	help
+	  Turning this on puts TX/RX descriptors in DSPRAM. Otherwise they are in
+	  DRAM.
+
+config TSMAC_LINELOOPBACK_FEATURE
+	bool "lineLoopBack command"
+	default n
+	help
+	  Turning this on includes the lineLoopBack command in the driver's proc
+	  interface.  Echoing 1 into the lineLoopBack results in all rx packets
+	  being transmitted out the same port.
+
+config TSMAC_TEST_CMDS
+	bool "test commands"
+	default n
+	help
+	  Turning this on includes the testing commands in the driver's proc
+	  interface.  These are used internally by PMC.
+
+endif
diff --git a/drivers/net/pmcmsp_tsmac/Makefile b/drivers/net/pmcmsp_tsmac/Makefile
new file mode 100644
index 0000000..0f9a6bd
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the PMC MSP TSMAC Ethernet drivers
+#
+obj-$(CONFIG_PMC_MSP_TSMAC) += pmcmsp_tsmac_mdiobus.o pmcmsp_tsmac.o pmcmsp_tsmac_user.o
+
diff --git a/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.c b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.c
new file mode 100644
index 0000000..d819401
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.c
@@ -0,0 +1,4266 @@
+/******************************************************************************
+** Copyright 2006-2011 PMC-Sierra, Inc
+**
+** PMC-SIERRA DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER
+** RESULTING FROM THE USE OF THIS SOFTWARE
+**
+** FILE NAME: pmcmsp_tsmac.c
+**
+** DESCRIPTION: Linux 2.6 driver for  TSMAC 3 speed ethernet device.
+**
+** This program is free software; you can redistribute  it and/or modify it
+** under  the terms of  the GNU General  Public License as published by the
+** Free Software Foundation;
+**
+******************************************************************************/
+
+#include <linux/kernel.h>
+#include <msp_prom.h>
+#include "pmcmsp_tsmac.h"
+#include "pmcmsp_tsmac_local.h"
+
+/*
+ * Definition of MTU is the packet size minus CRC and MAC header, so
+ * 64 - 18 = 46 is the minimum MTU
+ */
+#define MIN_MTU_SIZE       46
+#define PMC_FAST
+#define MAX_MTU_SIZE       1766
+/* PKT_SIZE = MTU_SIZE + MAC Header (14) + VLAN header (4) + CRC (4) */
+#define MAX_PKT_SIZE       (MAX_MTU_SIZE + 22)
+/* align the IP header to the 16 byte boundary */
+#define IP_HDR_ALIGN       2
+#define RXALIGN_PAD        4
+/*
+* Pad so all possible RXALIGN can't overrun end of buffer. Typically RXALIGN
+* is IP_HDR_ALIGN
+*/
+#define TSMAC_BUFSIZE      roundup((MAX_PKT_SIZE+RXALIGN_PAD), 4)
+
+/* roundup may report isse with preprocessor
+#if (TSMAC_BUFSIZE >= 2048)
+#error TSMAC_BUFSIZE exceeds maximum supported by hardware
+#endif
+*/
+/* PMON environment */
+#define TSMAC_VAR_MACADDR  "ethaddr"
+
+/* NAPI quota per interface */
+#define TSMAC_NAPI_WEIGHT  64
+
+#define VQ_INC_FREQUENCY   16
+
+#ifdef CONFIG_TSMAC_VQ_TOKEN_CNT_WORKAROUND
+/* frequency (number of packets) of incrementing the VQ token count */
+
+/*
+ * Frequency (number of increments) of checking and correcting the VQ token
+ * count
+ */
+#define VQ_CORRECT_FREQUENCY  100
+#endif
+
+/* TSMAC register starting addresses */
+#define MSP_DMA_START ((u32)&((struct msp_regs *)0)->dma)
+#define MSP_MAC_START ((u32)&((struct msp_regs *)0)->mac)
+#define MSP_GPMII_START ((u32)&((struct msp_regs *)0)->gpmii)
+
+static int PMC_FAST tsmac_rx_poll(struct napi_struct *napi, int budget);
+/* TSMAC driver information */
+const char version[] = "pmcmsp_tsmac.c:v2.0 01/09/2007, PMC-Sierra\n";
+const char cardname[] = "pmcmsp_tsmac";
+const char drv_version[] = "Revision: 1.1.2.2 ";
+const char drv_reldate[] = "$Date: 2010/07/15 07:38:59 $";
+const char drv_file[] = __FILE__;
+
+/* reset values for the supported HW units */
+static u32 tsmac_rstpats[TSMAC_MAX_UNITS] = {
+	TSMAC_EA_RST,
+	TSMAC_EB_RST,
+	TSMAC_EC_RST
+};
+
+/**
+ * tsmac_ls_bit_pattern() - get the correct bit pattern for the link speed
+ * @speed: link speed
+ *
+ * This function returns the corresponding bit patters of @speed, which is
+ * used to configure the TSMAC GPMII registers.
+ */
+static int tsmac_ls_bit_pattern(int speed)
+{
+	if (speed == SPEED_1000)
+		return 0x2;	/* bit pattern for link speed 1000 */
+	if (speed == SPEED_100)
+		return 0x1;	/* bit pattern for link speed 100 */
+
+	return 0x0;		/* bit pattern for link speed 10 */
+}
+
+/**
+ * tsmac_duplex_bit_pattern() - get the correct bit pattern for the duplex mode
+ * @duplex: duplex mode
+ *
+ * This function returns the corresponding bit patterns of @duplex mode, which
+ * is used to configure the TSMAC GPMII registers.
+ */
+static int tsmac_duplex_bit_pattern(int duplex)
+{
+	if (duplex == DUPLEX_FULL)
+		return 0x0;	/* bit pattern for full duplex */
+
+	return 0x1;		/* bit pattern for half duplex */
+}
+
+/*
+ * Coherent path flush
+ */
+static inline void tsmac_coherent_flush(void)
+{
+	u32 __iomem *coherent;
+	u32 dummy_read;
+
+	/* memory barrier to ensure read below not moved by compiler */
+	barrier();
+
+	/*
+	 * Do a dummy read of coherent path SDRAM to ensure that share control
+	 * structure has made it all the way to SDRAM
+	 */
+	coherent = (u32 __iomem *)0xB7F00000;
+
+	dummy_read = __raw_readl(coherent);
+	dummy_read++;
+}
+
+/*
+ * DSPRAM path flush via the coherent path
+ */
+static inline void tsmac_dspram_flush(void)
+{
+#ifdef CONFIG_DESC_ALL_DSPRAM
+	u32 __iomem *dspram;
+	u32 dummy_read;
+
+	/* memory barrier to ensure read below not moved by compiler */
+	barrier();
+
+	/*
+	 * Do a dummy read of coherent path to ensure that share control
+	 * structure has made it all the way to DSPRAM
+	 */
+	dspram = (u32 __iomem *)0xB8100000;
+
+	dummy_read = __raw_readl(dspram);
+	dummy_read++;
+#else				/* do nothing */
+#endif
+}
+
+/*
+ * CPU to TSMAC coherent path flush
+ */
+static inline void tsmac_cpu_to_tsmac_flush(unsigned int dev_id)
+{
+	u32 __iomem *tsmac;
+	u32 dummy_read;
+
+	/* memory barrier to ensure read below not moved by compiler */
+	barrier();
+
+	if (dev_id == 0)
+		tsmac = (u32 __iomem *)0xB860801C;
+	else if (dev_id == 2)
+		tsmac = (u32 __iomem *)0xB890801C;
+	else if (dev_id == 1)
+		tsmac = (u32 __iomem *)0xB870801C;
+	else
+		return;
+
+	/*
+	 * Do a dummy read of coherent path from CPU to TSMAC to ensure that
+	 * previous write to the TSMAC has made through
+	 */
+	dummy_read = __raw_readl(tsmac);
+	dummy_read++;
+}
+
+/* assume not using fastpath by default */
+#define CONFIG_USE_FASTPATH
+#ifdef CONFIG_USE_FASTPATH
+/*
+ * Fastpath flush.
+ */
+static inline void tsmac_fastpath_flush(void)
+{
+	u32 __iomem *fastpath;
+	u32 dummy_read;
+
+	/* memory barrier to ensure read below not moved by compiler */
+	barrier();
+
+	/*
+	 * Do a dummy read of fast path SDRAM to ensure that share control
+	 * structure has made it all the way to SDRAM
+	 */
+	fastpath = (u32 __iomem *)0x81000000;
+
+	dummy_read = __raw_readl(fastpath);
+	dummy_read++;
+}
+#endif
+
+/*
+ * Allocates descriptor memory from dspram or offchip
+ */
+static inline void *tsmac_mem_alloc(size_t size)
+{
+#ifdef CONFIG_DESC_ALL_DSPRAM	/* scratch pad */
+	/*
+	 * Spinlocks should NOT be allocated from DSPRAM. Spinlocks use the
+	 * Store Conditional (SC) instruction, which when executed to DSPRAM
+	 * will never update its destination register or updates the register
+	 * with an incorrect value. Implications are: a GPR may be written with
+	 * wrong data, or; if the SC fails to write its GPR, the core will hang
+	 * when executing an instruction dependant on that GPR.
+	 *
+	 */
+	return msp_spram_alloc(size);
+#else				/* offchip DDR */
+
+	void *m = kmalloc(size, GFP_KERNEL | GFP_DMA);
+	if (m)
+		m = (void *)KSEG1ADDR(m);
+
+	return m;
+#endif
+}
+
+/*
+ * Free descriptor memory
+ */
+static inline void tsmac_mem_free(void *m)
+{
+#ifdef CONFIG_DESC_ALL_DSPRAM	/* scratch pad */
+	msp_spram_free(m);
+#else				/* offchip DDR */
+	m = (void *)KSEG0ADDR(m);
+	kfree(m);
+#endif
+}
+
+/*
+ * Convert virutal address to physical address for DMA usage
+ */
+static inline dma_addr_t tsmac_dma_addr(void *addr)
+{
+#ifdef CONFIG_DESC_ALL_DSPRAM	/* scratch pad */
+	return (dma_addr_t) spram2dma(addr);
+#else
+	return (dma_addr_t) CPHYSADDR(addr);
+#endif
+}
+
+/*
+ * Allocate and align a max length skb. The sk_buff data buffer is mapped into
+ * the given buffer descriptor
+ */
+static TSMAC_ATTR_INLINE int tsmac_buffer_prepare(struct net_device *dev,
+						  struct tsmac_private *lp,
+						  struct Q_Desc *desc,
+						  unsigned int index)
+{
+	struct sk_buff *skb;
+	dma_addr_t dma_skb;
+
+	/* allocate skb */
+	skb = dev_alloc_skb(TSMAC_BUFSIZE);
+	if (unlikely(skb == NULL))
+		return -ENOMEM;
+
+	lp->rx.skb_pp[index] = skb;
+
+	/*
+	 * Update fields in the given buffer descriptor and invalidate packet
+	 * buffer
+	 */
+#ifdef CONFIG_CACHE_OPTIMIZATION
+	dma_skb = pmc_skb_inv(skb);
+#else
+	dma_skb = dma_map_single(lp->dev, skb->data, TSMAC_BUFSIZE,
+				 DMA_FROM_DEVICE);
+#endif
+	desc->FDBuffPtr = ((u32) dma_skb) & FD_RxBuff_Mask;
+
+	/* align and fill out fields specific to our device */
+	skb_reserve(skb, IP_HDR_ALIGN);
+
+	skb->dev = dev;
+
+	return 0;
+}
+
+/*
+ * Release and unmap skb assigned by tsmac_buffer_prepare()
+ */
+static TSMAC_ATTR_INLINE void tsmac_buffer_clear(struct sk_buff **skb_pp,
+						 unsigned int index)
+{
+	struct sk_buff *skb = skb_pp[index];
+	if (likely(skb != NULL))
+		dev_kfree_skb_any(skb);
+
+	skb_pp[index] = NULL;
+}
+
+/*
+ * This routine frees all skb memory associated with TX/RX descriptors
+ */
+static void tsmac_free_queues(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct tsmac_rx *rx;
+	unsigned int qnum, desc_index;
+	struct Q_Desc *desc;
+
+	/* free RX skb and reset RX descriptor ring */
+	rx = &lp->rx;
+	desc = &rx->desc_p[0];
+	if (desc != NULL) {
+		for (desc_index = 0; desc_index < rx->size; desc_index++) {
+			desc = &rx->desc_p[desc_index];
+			desc->FDCtl = 0;
+			tsmac_buffer_clear(rx->skb_pp, desc_index);
+		}
+		/* reset RX descriptor ring */
+		rx->index = 0;
+	}
+
+	/* free TX skb and reset TX descriptor ring */
+	for (qnum = TSMAC_DESC_PRI_HI; qnum < TSMAC_NUM_TX_CH; qnum++) {
+		tx = &lp->tx[qnum];
+		desc = &tx->desc_p[0];
+		if (desc != NULL) {
+			for (desc_index = 0; desc_index < tx->size;
+			     desc_index++) {
+				desc = &tx->desc_p[desc_index];
+				desc->FDCtl = 0;
+				tsmac_buffer_clear(tx->skb_pp, desc_index);
+			}
+			/* reset TX descriptor ring */
+			tx->head = 0;
+			tx->tail = 0;
+			tx->qcnt = 0;
+		}
+	}
+}
+
+/*
+ * Initialize the TX/RX queues by setting up TX/RX descriptor ring linked list
+ * and allocate skb memory. Since this routine allocates memory, care must
+ * be taken to free these memory (tsmac_free_queues) when they are no longer
+ * needed
+ */
+static int tsmac_init_queues(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct tsmac_rx *rx;
+	unsigned int qnum, desc_index, next_desc;
+	struct Q_Desc *desc;
+
+	rx = &lp->rx;
+	rx->index = 0;
+	desc_index = rx->size - 1;
+	do {
+		next_desc = desc_index + 1;
+		if (next_desc >= rx->size)
+			next_desc = 0;
+
+		if (tsmac_buffer_prepare(dev, lp, &rx->desc_p[desc_index],
+					 desc_index)) {
+			printk(KERN_ERR "Cannot allocate skbuff for %s RX "
+			       "descriptors!\n", dev->name);
+			goto alloc_skb_fail;
+		}
+
+		/* set descriptors */
+		desc = &rx->desc_p[desc_index];
+		desc->FDNext = tsmac_dma_addr(&rx->desc_p[next_desc]);
+		desc->FDStat = 0;
+		/* TODO: barrier and flush? */
+		desc->FDCtl = (FD_DMA_Own | (TSMAC_BUFSIZE - RXALIGN_PAD));
+	} while (desc_index--);
+
+	/* setup descriptors for each TX channel */
+	for (qnum = TSMAC_DESC_PRI_HI; qnum < TSMAC_NUM_TX_CH; qnum++) {
+		tx = &lp->tx[qnum];
+
+		/* initialize head, tail, and queue count */
+		tx->head = 0;
+		tx->tail = 0;
+		tx->qcnt = 0;
+
+		/* initialize TX descriptors */
+		desc_index = tx->size - 1;
+		do {
+			next_desc = desc_index + 1;
+			if (next_desc >= tx->size)
+				next_desc = 0;
+
+			tx->skb_pp[desc_index] = NULL;
+
+			desc = &tx->desc_p[desc_index];
+			desc->FDNext = tsmac_dma_addr(&tx->desc_p[next_desc]);
+			desc->FDBuffPtr = 0;
+			desc->FDCtl = 0;
+			desc->FDStat = 0;
+		} while (desc_index--);
+	}
+
+	return TSMAC_SUCCESS;
+
+ alloc_skb_fail:
+	/* free allocated resources */
+	tsmac_free_queues(dev);
+	return TSMAC_Q_INIT_ERROR;
+}
+
+/*
+ * This routine frees all memory associated with the TX and RX descriptor
+ * rings. Note that before calling this routine, tsmac_free_queues should be
+ * called first to free the skb memory otherwise memory leaks
+ */
+static void tsmac_free_desc(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct tsmac_rx *rx;
+	unsigned int qnum;
+
+	/* free RX descriptor ring */
+	rx = &lp->rx;
+	if (rx->desc_base != NULL) {
+		tsmac_mem_free(rx->desc_base);
+		tsmac_mem_free(rx->skb_base);
+		rx->desc_base = NULL;
+		rx->desc_p = NULL;
+		rx->skb_base = NULL;
+		rx->skb_pp = NULL;
+	}
+
+	/* free TX descriptor ring */
+	for (qnum = TSMAC_DESC_PRI_HI; qnum < TSMAC_NUM_TX_CH; qnum++) {
+		tx = &lp->tx[qnum];
+		if (tx->desc_base != NULL) {
+			tsmac_mem_free(tx->desc_base);
+			tsmac_mem_free(tx->skb_base);
+			tx->desc_base = NULL;
+			tx->desc_p = NULL;
+			tx->skb_base = NULL;
+			tx->skb_pp = NULL;
+		}
+	}
+}
+
+/*
+ * Allocate memory for TX/RX descriptors
+ */
+static int tsmac_alloc_desc(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct tsmac_rx *rx;
+	int qnum;
+	size_t size_desc_rx, size_desc_tx[TSMAC_NUM_TX_CH];
+	size_t size_skb_rx, size_skb_tx[TSMAC_NUM_TX_CH];
+
+	size_desc_rx = lp->rx.size * sizeof(struct Q_Desc);
+	size_skb_rx = lp->rx.size * sizeof(struct sk_buff *);
+
+	size_desc_tx[TSMAC_DESC_PRI_HI] = lp->tx[TSMAC_DESC_PRI_HI].size *
+	    sizeof(struct Q_Desc);
+	size_skb_tx[TSMAC_DESC_PRI_HI] = lp->tx[TSMAC_DESC_PRI_HI].size *
+	    sizeof(struct sk_buff *);
+	size_desc_tx[TSMAC_DESC_PRI_LO] = lp->tx[TSMAC_DESC_PRI_LO].size *
+	    sizeof(struct Q_Desc);
+	size_skb_tx[TSMAC_DESC_PRI_LO] = lp->tx[TSMAC_DESC_PRI_LO].size *
+	    sizeof(struct sk_buff *);
+
+	/* allocate memory for RX descriptors and skb pointers */
+	rx = &lp->rx;
+	if (rx->desc_base == NULL) {
+		rx->desc_base = tsmac_mem_alloc(size_desc_rx);
+		if (rx->desc_base == NULL) {
+			printk(KERN_ERR "Cannot allocate space for %s RX "
+			       "descriptors!\n", dev->name);
+			goto alloc_desc_fail;
+		}
+		memset(rx->desc_base, 0, size_desc_rx);
+
+		rx->skb_base = tsmac_mem_alloc(size_skb_rx);
+		if (rx->skb_base == NULL) {
+			printk(KERN_ERR "Cannot allocate space for %s RX "
+			       "skb address hodler!\n", dev->name);
+			goto alloc_desc_fail;
+		}
+		memset(rx->skb_base, 0, size_skb_rx);
+
+	}
+	rx->desc_p = (struct Q_Desc *)((u32) rx->desc_base);
+	rx->skb_pp = (struct sk_buff **)((u32) rx->skb_base);
+
+	/* allocate memory for each channel of the TX descriptors */
+	for (qnum = TSMAC_DESC_PRI_HI; qnum < TSMAC_NUM_TX_CH; qnum++) {
+		tx = &lp->tx[qnum];
+		if (tx->desc_base == NULL) {
+			tx->desc_base = tsmac_mem_alloc(size_desc_tx[qnum]);
+			if (tx->desc_base == NULL) {
+				printk(KERN_ERR "Cannot allocate space for %s "
+				       "TX descriptors!\n", dev->name);
+				goto alloc_desc_fail;
+			}
+			memset(tx->desc_base, 0, size_desc_tx[qnum]);
+
+			tx->skb_base = tsmac_mem_alloc(size_skb_tx[qnum]);
+			if (tx->skb_base == NULL) {
+				printk(KERN_ERR "Cannot allocate space for %s "
+				       "skb address!\n", dev->name);
+				goto alloc_desc_fail;
+			}
+			memset(tx->skb_base, 0, size_skb_tx[qnum]);
+		}
+		tx->desc_p = (struct Q_Desc *)((u32) tx->desc_base);
+		tx->skb_pp = (struct sk_buff **)((u32) tx->skb_base);
+	}
+
+	return TSMAC_SUCCESS;
+
+ alloc_desc_fail:
+	/* free resoruces */
+	tsmac_free_desc(dev);
+	return TSMAC_Q_INIT_ERROR;
+}
+
+/*
+ * Configure the TSMAC clocking based on MII mode and link speed. Note this
+ * routine should only be called when the MAC subsystem is held in reset
+ */
+static void tsmac_config_clks(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 bit_shift;
+	u32 tmp_reg = 0;
+	u32 ctl_cmd;
+
+	switch (lp->unit) {
+	case 0:
+		bit_shift = SYS_MACA_Shift;
+		break;
+	case 1:
+		bit_shift = SYS_MACB_Shift;
+		break;
+	case 2:
+	default:
+		bit_shift = SYS_MACC_Shift;
+		break;
+	}
+
+	tmp_reg = (tsmac_ls_bit_pattern(lp->speed) << SYS_LinkSpeed_Shift);
+	/* always use TX_CLK_IN for RMII */
+	tmp_reg |= (TSMAC_RMII_TX_CLK_IN << SYS_RMII_Clk_Shift);
+
+	if (lp->speed == SPEED_1000) {
+		/* use fast sys clk for Gbps */
+		tmp_reg |= (TSMAC_SYS_CLK_FAST << SYS_Sclk_Sel_Shift);
+		tmp_reg |= (lp->mii_type << SYS_Mode_Shift);
+	} else {
+		/* use slow sys clk for 10/100 Mbps */
+		tmp_reg |= (TSMAC_SYS_CLK_SLOW << SYS_Sclk_Sel_Shift);
+		if (lp->mii_type == TSMAC_MT_GMII)
+			tmp_reg |= (TSMAC_MT_MII << SYS_Mode_Shift);
+		else
+			tmp_reg |= (lp->mii_type << SYS_Mode_Shift);
+	}
+
+	tmp_reg <<= bit_shift;
+
+	/* configure clock manager */
+	ctl_cmd = tsmac_read((void *)TSMAC_CTRL_OUTPUT);
+	ctl_cmd &= ~(0xFE << bit_shift);
+	ctl_cmd |= tmp_reg;
+
+	/* config system register */
+	tsmac_write(ctl_cmd, (void *)TSMAC_CTRL_OUTPUT);
+}
+
+/*
+ * Reset the MAC subsystem
+ */
+static void tsmac_mac_reset(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	int i;
+	u32 rstpat;
+
+	/* stop TX/RX after completion of any current packets */
+	tsmac_write(MAC_HaltReq, &lp->reg_map->mac.mac_ctl);
+
+	/*
+	 * Flush various data path including CPU -> TSMAC, CPU -> DDR, and
+	 * CPU -> DSPRAM
+	 */
+	tsmac_cpu_to_tsmac_flush(lp->unit);
+	tsmac_coherent_flush();
+	tsmac_dspram_flush();
+
+	/* wait to make sure finish transactions on the current packet */
+	mdelay(100);
+
+	mutex_lock(&lp->bus.mdio_lock);
+
+	/* assert subsystem warm reset */
+	rstpat = tsmac_rstpats[lp->unit];
+	tsmac_write(rstpat, (void *)RST_SET_REG);
+
+	/* set clock registers before taking out of reset */
+	tsmac_config_clks(dev);
+
+	/* allow clocks to stabilize, then bring the subsystem out of reset */
+	mdelay(1);
+	tsmac_write(rstpat, (void *)RST_CLR_REG);
+	for (i = 0; i < 10; i++) {
+		if ((tsmac_read((void *)RST_STS_REG) & rstpat) == 0)
+			break;
+		ndelay(100);
+	}
+
+	mutex_unlock(&lp->bus.mdio_lock);
+}
+
+/*
+ * Initialize the GPMII registers. Enabling the TX/RX datapaths
+ * is deferred to tsmac_start_txrx().
+ */
+static void tsmac_init_gpmii(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 gpmii_cmd;
+
+	/*
+	 * Setup GPMII Configuration Mode register.
+	 * - MII mode is based on the connection type or the user
+	 *   specified setting.
+	 * - Duplex setting and link speed selection are based on the
+	 *   user specified setting or the auto negotiation result.
+	 */
+	if ((lp->mii_type == TSMAC_MT_GMII) && (lp->speed != SPEED_1000))
+		gpmii_cmd = TSMAC_MT_MII & GPMII_Mode_Mask;
+	else
+		gpmii_cmd = lp->mii_type & GPMII_Mode_Mask;
+
+	gpmii_cmd |= (tsmac_ls_bit_pattern(lp->speed)
+		      << GPMII_LinkSpeed_Shift);
+	gpmii_cmd |= (tsmac_duplex_bit_pattern(lp->duplex)
+		      << GPMII_Dplx_Shift);
+
+	/* configure GPMII */
+	tsmac_write(gpmii_cmd, &lp->reg_map->gpmii.conf_mode);
+
+	gpmii_cmd = 0;
+	if (lp->duplex == DUPLEX_FULL)
+		gpmii_cmd |= GPMII_Force_Crs_Col_En;
+	if (gpmii_cmd)
+		tsmac_write(gpmii_cmd, &lp->reg_map->gpmii.conf_general);
+}
+
+/*
+ * Toggle enable/disable status of the flood control logic
+ */
+static int set_floodctl_reg(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 saved_rxctl;
+	u8 flood_enable;
+
+	/* update device details */
+	flood_enable = lp->vqnflood.flood_enable;
+
+	/* RXEN should be disabled while enabling/disabling flood control */
+	saved_rxctl = tsmac_read(&lp->reg_map->mac.rx_ctl);
+	tsmac_write(saved_rxctl & ~Rx_En, &lp->reg_map->mac.rx_ctl);
+
+#if defined(TSMAC_FLOOD_WORKAROUND)	/* always enable flood control */
+	saved_rxctl |= Rx_FloodEn;
+#else
+	if (flood_enable == 1)
+		saved_rxctl |= Rx_FloodEn;
+	else
+		saved_rxctl &= ~Rx_FloodEn;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+	tsmac_write(saved_rxctl, &lp->reg_map->mac.rx_ctl);
+	return 0;
+}
+
+#ifdef TSMAC_FLOOD_WORKAROUND
+/*
+ * Configure flood control to pass all packets (no dropping)
+ */
+static void flood_pass_all(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 i;
+
+	/* clear classifier RAM */
+	for (i = L2_ARC_Class_Min; i <= L2_ARC_Class_Max; i += 4) {
+		tsmac_write(i, &lp->reg_map->mac.arc_addr);
+		tsmac_write(0, &lp->reg_map->mac.arc_data);
+	}
+
+	/* disable L2 rules */
+	tsmac_write(0, &lp->reg_map->mac.l2_rule_ena);
+
+	/* set default VQ to "0" */
+	tsmac_write(0, &lp->reg_map->mac.vq_conf);
+
+	/* don't drop packets in VQ0 */
+	tsmac_write(VQ_TC_Drop_Disable, &lp->reg_map->mac.vq_token_cnt[0]);
+}
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+/*
+ * Set network device multicast address to ARC table
+ */
+static void tsmac_set_multicast_list(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 reg;
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Enable promiscuous mode */
+		tsmac_write(ARC_CompEn | ARC_BroadAcc | ARC_GroupAcc |
+			    ARC_StationAcc, &lp->reg_map->mac.arc_ctl);
+	} else if ((dev->flags & IFF_ALLMULTI) ||
+		   dev->mc.count > ARC_ENTRY_MAX - 3) {
+		/* Disable promiscuous mode, use normal mode. */
+		tsmac_write(ARC_CompEn | ARC_BroadAcc | ARC_GroupAcc,
+			    &lp->reg_map->mac.arc_ctl);
+	} else if (dev->mc.count) {
+		struct netdev_hw_addr *ha;
+		int i = 0;
+		int ena_bits = ARC_Ena_Bit(ARC_ENTRY_MAC);
+
+		tsmac_write(0, &lp->reg_map->mac.arc_ctl);
+		/* Walk the address list, and load the filter */
+		netdev_for_each_mc_addr(ha, dev) {
+			/* use free ARC location */
+			tsmac_set_arc_entry(dev, ARC_ENTRY_PAUSE_RX + 1 + i,
+					    ha->addr);
+			ena_bits |= ARC_Ena_Bit(ARC_ENTRY_PAUSE_RX + 1 + i);
+			i++;
+		}
+		reg = tsmac_read(&lp->reg_map->mac.arc_ena) | ena_bits;
+		tsmac_write(reg, &lp->reg_map->mac.arc_ena);
+		tsmac_write(ARC_CompEn | ARC_BroadAcc,
+			    &lp->reg_map->mac.arc_ctl);
+	} else {
+		reg = tsmac_read(&lp->reg_map->mac.arc_ena) |
+		    ARC_Ena_Bit(ARC_ENTRY_MAC);
+		tsmac_write(reg, &lp->reg_map->mac.arc_ena);
+		tsmac_write(ARC_CompEn | ARC_BroadAcc,
+			    &lp->reg_map->mac.arc_ctl);
+	}
+}
+
+/*
+ * Configure the TSMAC registers, including ARC table.
+ * TX/RX datapath enabling is deferred to tsmac_start_txrx().
+ */
+static int tsmac_init_tsmac(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 max_len, tmp;
+	u8 tmp_addr[6];
+
+	/* set maximum frame size */
+	max_len = dev->mtu + 18;
+	tsmac_write(((max_len + 4) << 16) | max_len,
+		    &lp->reg_map->mac.max_length);
+
+	/* clear entire ARC table (MAC filtering, PAUSE, Classification) */
+	for (tmp = 0; tmp <= L2_ARC_Class_Max; tmp += 4) {
+		tsmac_write(tmp, &lp->reg_map->mac.arc_addr);
+		tsmac_write(0, &lp->reg_map->mac.arc_data);
+	}
+
+	/* load device MAC address to ARC table entry and enable it */
+	tsmac_set_arc_entry(dev, ARC_ENTRY_MAC, dev->dev_addr);
+	tmp = tsmac_read(&lp->reg_map->mac.arc_ena) |
+	    ARC_Ena_Bit(ARC_ENTRY_MAC);
+	tsmac_write(tmp, &lp->reg_map->mac.arc_ena);
+
+	/* load special multicast address to ARC table entry and enable it */
+	tmp_addr[0] = 0x01;
+	tmp_addr[1] = 0x80;
+	tmp_addr[2] = 0xC2;
+	tmp_addr[3] = 0x00;
+	tmp_addr[4] = 0x00;
+	tmp_addr[5] = 0x01;
+	tsmac_set_arc_entry(dev, ARC_ENTRY_PAUSE_RX, tmp_addr);
+	tmp = tsmac_read(&lp->reg_map->mac.arc_ena) |
+	    ARC_Ena_Bit(ARC_ENTRY_PAUSE_RX);
+	tsmac_write(tmp, &lp->reg_map->mac.arc_ena);
+
+	/* Set multicast flags according to what was set previously */
+	tsmac_set_multicast_list(dev);
+
+	/* ensure that MAC control register HALTIMM and HALTREQ bits are 0 */
+	tsmac_write(0x00000000, &lp->reg_map->mac.mac_ctl);
+
+	/* set flow control */
+	tsmac_set_pause_param(dev);
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0) {
+		flood_pass_all(dev);
+		return 0;
+	}
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+	return tsmac_set_vqnpause(dev);
+}
+
+/*
+ * Initialize the TSMAC DMA.
+ */
+static void tsmac_init_dma(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	dma_addr_t dma_desc;
+
+	/* set Tx Poll count of each Tx channel */
+	tsmac_write(TXPOLLCNT_CH0, &lp->reg_map->dma.txpollcnt_ch0);
+	tsmac_write(TXPOLLCNT_CH1, &lp->reg_map->dma.txpollcnt_ch1);
+
+	/* enable interrupts */
+	tsmac_write(INT_EN_CMD, &lp->reg_map->dma.int_ena);
+
+	/* configure IP Header offset of vlan and non-vlan packets */
+	lp->iphdr_offset.vlan = IPHDR_OFFSET_IPV4_VLAN;
+	lp->iphdr_offset.nvlan = IPHDR_OFFSET_IPV4_NVLAN;
+	tsmac_write((lp->iphdr_offset.vlan << DMA_OffsetVLAN_Shift) |
+		    lp->iphdr_offset.nvlan, &lp->reg_map->dma.iphdr_offset);
+
+	/*
+	 * Configure TX descriptor pointer registers for channel 0 and 1 with
+	 * the address of the first descriptor in the TX descriptor linked
+	 * list
+	 */
+	dma_desc = tsmac_dma_addr(&lp->tx[0].desc_p[0]);
+	tsmac_write(((u32) dma_desc) & DMA_TxDesc_AddrMask,
+		    &lp->reg_map->dma.txdesc_ch0);
+	dma_desc = tsmac_dma_addr(&lp->tx[1].desc_p[0]);
+	tsmac_write(((u32) dma_desc) & DMA_TxDesc_AddrMask,
+		    &lp->reg_map->dma.txdesc_ch1);
+
+	/* configure RX descriptor pointer registers */
+	dma_desc = tsmac_dma_addr(&lp->rx.desc_p[0]);
+	tsmac_write(((u32) dma_desc) & DMA_RxDesc_AddrMask,
+		    &lp->reg_map->dma.rxdesc);
+
+	/*
+	 * configure DMA to align 2 byte for the recieved packets that
+	 * it writes into system memory
+	 */
+	tsmac_write(DMA_CTL_CMD, &lp->reg_map->dma.dma_ctl);
+}
+
+/*
+ * Flip the switches in the correct order to enable
+ * the Tx/Rx datapaths in each subsystem.
+ */
+static int tsmac_enable_txrx(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 cmd;
+	int n = 0;
+
+	/* enable the TX path in the order of GPMII, MAC, DMA */
+	cmd = tsmac_read(&lp->reg_map->gpmii.conf_general);
+	cmd |= GPMII_TxDataPath_En;
+	tsmac_write(cmd, &lp->reg_map->gpmii.conf_general);
+	tsmac_write(TX_CFG(TX_CTL_DIS, lp->flow_ctl.enable),
+		    &lp->reg_map->mac.tx_ctl);
+	tsmac_write(DMA_TxInit_DescList, &lp->reg_map->dma.dma_init);
+
+	/* enable the rx path in the order of DMA, MAC, GPMII */
+	tsmac_write(DMA_RxInit_DescList, &lp->reg_map->dma.dma_init);
+	tsmac_write(RX_CTL_ENA, &lp->reg_map->mac.rx_ctl);
+	tsmac_write(tsmac_read(&lp->reg_map->gpmii.conf_general)
+		    | GPMII_RxDataPath_En, &lp->reg_map->gpmii.conf_general);
+	/*
+	 * As per the TSMAC eng doc, wait until RxDataPath_En = 1
+	 */
+	cmd = tsmac_read(&lp->reg_map->gpmii.conf_general);
+	while (n < 10 && !(cmd & GPMII_RxDataPath_En)) {
+		++n;
+		mdelay(10);
+		cmd = tsmac_read(&lp->reg_map->gpmii.conf_general);
+	}
+	if (n >= 10) {
+		printk(KERN_WARNING "Receive datapath not enabled.\n");
+		return -EBUSY;
+	}
+	return 0;
+}
+
+/*
+ * Initialize the MAC, DMA, and GPMII control registers. Activation order
+ * should be:
+ *
+ * TX - GPMII, MAC, DMA
+ * RX - DMA, MAC, GPMII
+ */
+static int tsmac_mac_init(struct net_device *dev)
+{
+	int ret;
+
+	/* set some device structure parameters */
+	dev->tx_queue_len = TX_RING_SIZE_DEF;
+
+	/* initialize DMA */
+	tsmac_init_dma(dev);
+
+	ret = tsmac_init_tsmac(dev);
+	if (ret)
+		goto out;
+
+	/* initialize GPMII */
+	tsmac_init_gpmii(dev);
+
+ out:
+	return ret;
+}
+
+/**
+ * tsmac_check_phy_driver() - re-attach if the generic PHY driver is used
+ * @dev: mac interface
+ *
+ * If the PHY/Switch connected to the interface is currently using a generic
+ * PHY driver, then disconnect and reconnect again to see if there is better
+ * driver available (0xffffffff is the phy_id of generic PHY driver).
+ * Return 0 if the generic PHY driver is never used or the appropriate driver
+ * is attached to replace generic PHY driver.  Return -1 if there is an error
+ * occur while attaching the appropriate PHY driver.
+ */
+static int tsmac_check_phy_driver(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct phy_driver *phydrv;
+
+	if (lp->phyptr == NULL)
+		return 0;
+
+	phydrv = to_phy_driver(lp->phyptr->dev.driver);
+
+	/* only check for new driver is the attached one is generic */
+	if (phydrv->phy_id != 0xffffffff)
+		return 0;
+
+	if (lp->conn_type == MSP_CT_ETHPHY) {
+		phy_disconnect(lp->phyptr);
+
+		lp->phyptr = tsmac_mii_probe(dev, &tsmac_adjust_link);
+
+		if (lp->phyptr == NULL)
+			return -1;
+
+		phydrv = to_phy_driver(lp->phyptr->dev.driver);
+	} else if (lp->conn_type == MSP_CT_ETHSWITCH) {
+		char bus_id[MII_BUS_ID_SIZE];
+		char bus_unit[4];
+		sprintf(bus_unit, "%x", lp->bus_unit);
+		phy_detach(lp->phyptr);
+
+		snprintf(bus_id, MII_BUS_ID_SIZE, PHY_ID_FMT, bus_unit,
+			 lp->phy_addr);
+		lp->phyptr = phy_attach(dev, bus_id, 0,
+					PHY_INTERFACE_MODE_GMII);
+	}
+
+	return 0;
+}
+
+/*
+ * This routine seizes all possible TX/RX traffic so the user can schedule the
+ * tsmac_restart later to restart the device
+ */
+static void tsmac_shutdown(struct net_device *dev)
+{
+	printk(KERN_INFO "TSMAC (tsmac_shutdown) %s: Device shutdown\n",
+	       dev->name);
+
+	/* disable device based interrupt line */
+	disable_irq(dev->irq);
+
+	/* turn off carrier so the polling can quit */
+	netif_carrier_off(dev);
+
+	/* stop the egress queue */
+	netif_stop_queue(dev);
+
+	/*
+	 * Don't stop the RX polling routine here since it can wait for a
+	 * long time and this routine can be running in an interrupt context
+	 * or softirq
+	 */
+}
+
+/*
+ * This routine serves as a recovery mechanism. The user should always schedule
+ * a workqueue for this routine (since it can sleep) and before calling this
+ * routine, tsmac_shutdown should be called first
+ */
+static void tsmac_restart(struct work_struct *work)
+{
+	struct tsmac_private *lp = container_of(work, struct tsmac_private,
+						restart_task.work);
+	struct net_device *dev = lp->ndev;
+	unsigned long flags;
+
+	printk(KERN_INFO "TSMAC (tsmac_restart) %s: Device restart\n",
+	       dev->name);
+
+	spin_lock(&lp->restart_lock);
+
+	/*
+	 * If the device is already being closed, we should quit tsmac_restart
+	 */
+	if (atomic_read(&lp->close_flag))
+		goto restart_exit;
+
+	/* stop RX polling routine */
+	napi_disable(&lp->napi);
+
+	/* we need the locks since TX runs at the bottom half */
+	spin_lock_irqsave(&lp->tx_lock, flags);
+
+	if (lp->conn_type == MSP_CT_ETHPHY)
+		phy_stop(lp->phyptr);
+	else
+		netif_carrier_off(dev);
+
+	/* prevent control plane from accessing registers */
+	spin_lock(&lp->control_lock);
+	/* reset the MAC */
+	tsmac_mac_reset(dev);
+	/* allow control plane to access registers */
+	spin_unlock(&lp->control_lock);
+
+	/* Try to restart the adaptor. */
+	tsmac_free_queues(dev);
+	tsmac_init_queues(dev);
+
+	tsmac_mac_init(dev);
+
+	if (tsmac_check_phy_driver(dev))
+		goto restart_exit;
+
+	if (lp->conn_type == MSP_CT_ETHPHY)
+		/* PAL takes care of netif_carrier_on */
+		phy_start(lp->phyptr);
+	else
+		/* assume carrier is up */
+		netif_carrier_on(dev);
+
+	/* enable TX/RX path in the correct order */
+	tsmac_enable_txrx(dev);
+
+	/* wake up the egress queue */
+	dev->trans_start = jiffies;
+	netif_wake_queue(dev);
+
+	/* start RX polling */
+	napi_enable(&lp->napi);
+
+	/* re-enable IRQ */
+	enable_irq(dev->irq);
+
+	/* unlock TX and restore IRQ */
+	spin_unlock_irqrestore(&lp->tx_lock, flags);
+
+ restart_exit:
+	spin_unlock(&lp->restart_lock);
+	atomic_dec(&lp->restart_pending_cnt);
+}
+
+/*
+ * Interrupt handler
+ */
+static irqreturn_t tsmac_interrupt(int irq, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 status;
+
+	/* collect irq status */
+	status = tsmac_read(&lp->reg_map->dma.int_src);
+
+	/* nothing */
+	if (status == 0)
+		return IRQ_NONE;
+
+	/* bad address read/write or system bus error */
+	if (status & (IntEn_BadAddrRd | IntEn_BadAddrWr | IntEn_SysBusErr)) {
+		printk(KERN_WARNING "TSMAC (tsmac_interrupt) %s: bad address "
+		       "or system bus err\n", dev->name);
+		/* restart the device and return */
+		tsmac_shutdown(dev);
+		if (schedule_delayed_work_on(atomic_read(&lp->timer_task_cpu),
+					     &lp->restart_task, 0))
+			atomic_inc(&lp->restart_pending_cnt);
+
+		tsmac_write(status, &lp->reg_map->dma.int_src);
+		return IRQ_HANDLED;
+	}
+
+	/* RX or RX exhausted */
+	if (status & (IntSrc_MACRx | IntSrc_RxDescEx)) {
+		/* disable RX receive and RX exhausted interrupts */
+		tsmac_write((INT_EN_CMD & ~IntEn_RxDescEx),
+			    &lp->reg_map->dma.int_ena);
+		tsmac_write(RX_CTL_DIS, &lp->reg_map->mac.rx_ctl);
+
+		/*
+		 * If not already scheduled, schedule the NAPI RX polling
+		 * routine
+		 */
+		if (napi_schedule_prep(&lp->napi))
+			__napi_schedule(&lp->napi);
+
+		/*
+		 * Acknowledge RX receive interrupt is needed otherwise
+		 * it might be triggered right away even if interrupt
+		 * has been disabled due to the way the HW is architected
+		 */
+		tsmac_write(IntSrc_MACRx, &lp->reg_map->dma.int_src);
+
+		lp->sw_stats.rx_ints++;
+	}
+
+	/*
+	 * Only take actions when TX complete interrupt from Channel 0 (high
+	 * priority) is received. TX complete interrupt from Channel 1 (low
+	 * priority) can be ignored safely
+	 */
+	if (status & IntSrc_MACTx_CH0) {
+		/* disable TX complete interrupt */
+		tsmac_write(TX_CFG(TX_CTL_DIS, lp->flow_ctl.enable),
+			    &lp->reg_map->mac.tx_ctl);
+
+		/* wake up Linux egress queue */
+		netif_wake_queue(dev);
+
+		lp->sw_stats.tx_ints++;
+	}
+
+	/* acknowledge all interrupts except RX receive and RX exhausted */
+	tsmac_write(status & (~IntSrc_MACRx) & (~IntSrc_RxDescEx),
+		    &lp->reg_map->dma.int_src);
+
+	/*
+	 * Flush the CPU to TSMAC path here to make sure the TSMAC gets all
+	 * important commands
+	 */
+	tsmac_cpu_to_tsmac_flush(lp->unit);
+
+	return IRQ_HANDLED;
+}
+
+/*
+ * Software-aided TCP/UDP checksum calculator using previously calculated
+ * checksum based on IPv4 packets (done in HW)
+ */
+static TSMAC_ATTR_INLINE int tsmac_ipv6_chksum_calc(u16 *data_ptr,
+						    const u16 hw_chksum,
+						    const int vlan_flag)
+{
+	u32 accum;
+	u16 chksum, len, payload_len;
+	u16 *cur_ptr, *end_ptr;
+	u8 vlan_offset;
+
+	if (unlikely(data_ptr == NULL))
+		return 1;
+
+	if (vlan_flag)		/* VLAN packet, add 4-byte offset */
+		vlan_offset = 2;
+	else
+		vlan_offset = 0;
+
+	/* IPv6 payload length is TCP header + TCP data */
+	payload_len = data_ptr[2 + vlan_offset];
+
+	/* HW calculated only valid if len >= 20 bytes */
+	if (unlikely(payload_len < 20))
+		return 1;
+
+	accum = hw_chksum;
+
+	/* add next header */
+	accum += (data_ptr[3 + vlan_offset] >> 8);
+
+	/* add upper 16-bit of SA0 */
+	accum += data_ptr[4 + vlan_offset];
+
+	/* add lower 16-bit of SA0 in format SA0[15:8], 8b0 */
+	accum += (data_ptr[5 + vlan_offset] & 0xFF00);
+
+	/* add upper 16 bit of SA1 */
+	accum += data_ptr[6 + vlan_offset];
+
+	/* add 20 since IPv6 uses payload length instead of IP packet length */
+	accum += 20;
+
+	/* add the missing 38 bytes of data */
+	len = payload_len;
+	len -= 20;
+	len >>= 1;
+
+	cur_ptr = &data_ptr[len + 11 + vlan_offset];
+	end_ptr = &data_ptr[20 + (payload_len >> 1) + vlan_offset];
+
+	while (cur_ptr < end_ptr)
+		accum += *cur_ptr++;
+
+	/* for the odd byte */
+	if (payload_len & 0x0001) {
+		accum -= data_ptr[len + 11 + vlan_offset] & 0xFF00;
+		accum += (*cur_ptr) & 0xFF00;
+	}
+
+	/*
+	 * Keep only the last 16 bits of the 32 bit sum and add back the
+	 * carries
+	 */
+	while (accum >> 16)
+		accum = (accum & 0xFFFF) + (accum >> 16);
+
+	chksum = accum;
+
+	if (chksum == 0xFFFF)	/* checksum correct */
+		return 0;
+	else
+		return 1;
+}
+
+/*
+ * Verify L4 TCP/UDP checksum. The HW calculates the checksum with IPv4 pseudo
+ * header. Therefore, if it's an IPv6 packet, the driver needs to cover the
+ * missing fields
+ */
+static TSMAC_ATTR_INLINE void tsmac_chksum_verify(struct sk_buff *skb,
+						  struct Q_Desc *desc)
+{
+	u16 checksum;
+	unsigned char ip_version;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* hardware calculated IPv4-based TCP/UDP checksum */
+	checksum = (desc->FDCtl & FD_RxChksum_Mask) >> FD_RxChksum_Shift;
+
+	/* validate TCP/UDP checksum based on protocol */
+	switch (skb->protocol) {
+	case (ETH_P_IP):	/* IPv4 */
+		if (likely(checksum == 0xFFFF))	/* checksum correct */
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
+
+	case (ETH_P_IPV6):	/* IPv6 */
+		if (tsmac_ipv6_chksum_calc((u16 *) skb->data, checksum, 0) == 0)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
+
+	case (ETH_P_8021Q):	/* VLAN */
+		/*
+		 * Obtain IP version using the version field in the IP header.
+		 * Since VLAN packet has 4-byte header between the Ethernet
+		 * header and the IP header, the version field starts on the
+		 * 5th byte of skb->data
+		 */
+		ip_version = ((unsigned char *)skb->data)[4];
+		if ((ip_version & 0xF0) == 0x40) {	/* IPv4 */
+			if ((desc->FDCtl & FD_RxChksum_Mask) ==
+			    FD_RxChksum_Mask)
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+		} else if ((ip_version & 0xF0) == 0x60) {	/* IPv6 */
+			if (tsmac_ipv6_chksum_calc((u16 *) skb->data,
+						   checksum, 1) == 0)
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+		}
+		break;
+
+	default:		/* unknow protocol, let kernel handle it */
+		break;
+	}
+}
+
+/*
+ * Increment VQ token count by num_tokens.
+ */
+static TSMAC_ATTR_INLINE void tsmac_rx_token_inc(struct tsmac_private *lp,
+						 const u32 vq_num,
+						 const u16 num_tokens)
+{
+	void *addr;
+	u32 data;
+
+	if (num_tokens == 0)
+		return;
+
+	addr = &lp->reg_map->mac.vq_token_cnt[vq_num];
+	data = num_tokens;
+
+	tsmac_write(data, addr);
+}
+
+#ifdef CONFIG_TSMAC_VQ_TOKEN_CNT_WORKAROUND
+/*
+ * Read the current VQ token count and check the number of low-priority packets
+ * in the descriptor ring
+ */
+static unsigned int tsmac_rx_token_check(struct tsmac_private *lp,
+					 const u32 vq_num,
+					 unsigned int rx_index)
+{
+	int i;
+	struct Q_Desc *desc = &lp->rx.desc_p[rx_index];
+	unsigned int init_cnt;
+	unsigned int lp_pkt_cnt = 0;	/* low priority packet count */
+	int error_cnt;
+
+	/*
+	 * If the number of low-priority packets + the current VQ token count
+	 * > initial VQ token count, we have token count overflow error due to
+	 * the HW bug. In this case, we force the VQ token count value back to
+	 * its initial value
+	 */
+
+	init_cnt = lp->vqnflood.vq_config[vq_num].vq_token_count;
+
+	/*
+	 * Go through the RX descriptor ring and count the number of
+	 * low-priority packets in the ring
+	 *
+	 * Note that we should always start with the oldest packet in the ring
+	 * to minimize the counting error
+	 */
+	for (i = 0; i < lp->rx.size; i++) {
+		if ((desc->FDCtl & FD_DMA_Own) != FD_DMA_Own) {
+			if ((desc->FDStat & Rx_VQ_Mask) == vq_num)
+				lp_pkt_cnt++;
+		}
+		rx_index++;
+		if (rx_index >= lp->rx.size)
+			rx_index = 0;
+		desc = &lp->rx.desc_p[rx_index];
+	}
+
+	/* read current VQ token count */
+	lp_pkt_cnt += tsmac_read(&lp->reg_map->mac.vq_token_cnt[vq_num]) &
+	    VQ_TC_Token_Cnt_Mask;
+
+	error_cnt = lp_pkt_cnt - init_cnt + VQ_INC_FREQUENCY;
+	if (error_cnt > 0) {
+		if (error_cnt >= VQ_INC_FREQUENCY)
+			return 0;
+		else
+			return VQ_INC_FREQUENCY - error_cnt;
+	} else {
+		/* no error */
+		return VQ_INC_FREQUENCY;
+	}
+}
+#endif				/* CONFIG_TSMAC_VQ_TOKEN_CNT_WORKAROUND */
+
+/*
+ * Control the frequency of updating the VQ token
+ */
+static TSMAC_ATTR_INLINE void tsmac_rx_token_ctrl(struct tsmac_private *lp,
+						  const u32 vq_num,
+						  const unsigned int rx_index)
+{
+#ifdef CONFIG_TSMAC_VQ_TOKEN_CNT_WORKAROUND
+	/*
+	 * Only do VQ token count check and update when drop disable is NOT
+	 * set. When drop disable is set the VQ token count value will be
+	 * ignored in the HW so there's no point to update it here
+	 */
+	if (lp->vqnflood.vq_config[vq_num].vq_drop_disable == 0) {
+		struct tsmac_rx_vq_token *vq_token = &lp->vq_token[vq_num];
+		/* number of tokens to be incremented */
+		unsigned int inc_token;
+
+		vq_token->pkt_cnt++;
+
+		/*
+		 * Update the token count once every VQ_INC_FREQUENCY packets
+		 * to minimize collision rate
+		 */
+		if (vq_token->pkt_cnt >= VQ_INC_FREQUENCY) {
+			vq_token->pkt_cnt = 0;
+			vq_token->update_cnt++;
+
+			/*
+			 * Check for possible VQ token errors once every
+			 * VQ_CORRECT_FREQUENCY increments
+			 */
+			if (vq_token->update_cnt >= VQ_CORRECT_FREQUENCY) {
+				/*
+				 * Normally, if there's no error detected in
+				 * the VQ token count, we increment the VQ
+				 * token count by VQ_INC_FREQUENCY.
+				 *
+				 * If there's error detected, we compensate
+				 * the error by NOT incrementing or doing less
+				 * increment
+				 */
+				vq_token->update_cnt = 0;
+				inc_token = tsmac_rx_token_check(lp, vq_num,
+								 rx_index);
+
+			} else {
+				inc_token = VQ_INC_FREQUENCY;
+			}
+
+			/* update token count */
+			tsmac_rx_token_inc(lp, vq_num, inc_token);
+		}
+	}
+#else
+	/*
+	 * Only do VQ token count check and update when drop disable is NOT
+	 * set. When drop disable is set the VQ token count value will be
+	 * ignored in the HW so there's no point to update it here
+	 */
+	if (lp->vqnflood.vq_config[vq_num].vq_drop_disable == 0) {
+		struct tsmac_rx_vq_token *vq_token = &lp->vq_token[vq_num];
+		vq_token->pkt_cnt++;
+
+		if (vq_token->pkt_cnt >= VQ_INC_FREQUENCY) {
+			/* update token count */
+			tsmac_rx_token_inc(lp, vq_num, vq_token->pkt_cnt);
+			vq_token->pkt_cnt = 0;
+		}
+	}
+#endif
+}
+
+void tsmac_rx_register_hook(struct net_device *dev,
+			    tsmac_hook_function fp, void *data)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* Assume that the rx_hook function and the private data are all
+	 * un-registered, user cannot invoke the register for multiple t
+	 * imes to update the registration, SHOULD unregister first.
+	 */
+
+	/* Protecting multiple writers with the lp->control lock, and as
+	 * sign the private data prior the rx_hook function.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	rcu_assign_pointer(lp->rx_priv, data);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+
+	/* Protecting multiple writers with the lp->control lock, now en
+	 * able the rx_hook function.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	rcu_assign_pointer(lp->tsmac_rx_hook, fp);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(tsmac_rx_register_hook);
+
+void tsmac_rx_unregister_hook(struct net_device *dev,
+			      tsmac_hook_function fp, void **data)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* Protecting multiple writers with the lp->control lock, and de
+	 * tach the rx_hook function prior the private data.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	rcu_assign_pointer(lp->tsmac_rx_hook, NULL);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+
+	/* Protecting multiple writers with the lp->control lock, and re
+	 * lease the private data, notice that the data MAY be allocated
+	 * by 3rd party function and need to be passed back for cleanup.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	if (NULL != data)
+		*data = rcu_dereference(lp->rx_priv);
+
+	rcu_assign_pointer(lp->rx_priv, NULL);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(tsmac_rx_unregister_hook);
+
+void tsmac_tx_register_hook(struct net_device *dev,
+			    tsmac_hook_function fp, void *data)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* Assume that the tx_hook function and the private data are all
+	 * un-registered, user cannot invoke the register for multiple t
+	 * imes to update the registration, SHOULD unregister first.
+	 */
+
+	/* Protecting multiple writers with the lp->control lock, and as
+	 * sign the private data prior the tx_hook function.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	rcu_assign_pointer(lp->tx_priv, data);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+
+	/* Protecting multiple writers with the lp->control lock, now en
+	 * able the tx_hook function.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	rcu_assign_pointer(lp->tsmac_tx_hook, fp);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(tsmac_tx_register_hook);
+
+void tsmac_tx_unregister_hook(struct net_device *dev,
+			      tsmac_hook_function fp, void **data)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* Protecting multiple writers with the lp->control lock, and de
+	 * tach the tx_hook function prior the private data.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	rcu_assign_pointer(lp->tsmac_tx_hook, NULL);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+
+	/* Protecting multiple writers with the lp->control lock, and re
+	 * lease the private data, notice that the data MAY be allocated
+	 * by 3rd party function and need to be passed back for cleanup.
+	 */
+	spin_lock_bh(&lp->control_lock);
+	if (NULL != data)
+		*data = rcu_dereference(lp->tx_priv);
+
+	rcu_assign_pointer(lp->tx_priv, NULL);
+	spin_unlock_bh(&lp->control_lock);
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(tsmac_tx_unregister_hook);
+
+/*
+ * skb manipulation, set up skb data structure and verify L4 checksum before
+ * sending it up to the network stack
+ */
+static TSMAC_ATTR_INLINE int tsmac_rx_skb(struct net_device *dev,
+					  struct Q_Desc *desc,
+					  struct sk_buff *skb,
+					  const u16 pkt_len)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	tsmac_hook_function tsmac_rx_hook = NULL;
+
+	/* initialize skb length */
+	skb_put(skb, pkt_len);
+
+	/* strip out 4-byte CRC */
+	pskb_trim_rcsum(skb, skb->len - 4);
+
+	rcu_read_lock();
+	tsmac_rx_hook = rcu_dereference(lp->tsmac_rx_hook);
+
+	if (unlikely(tsmac_rx_hook)) {
+		void *priv = rcu_dereference(lp->rx_priv);
+
+		if (unlikely(tsmac_rx_hook(&skb, dev, priv) < 0)) {
+			rcu_read_unlock();
+			return -1;
+		}
+	}
+	rcu_read_unlock();
+
+	/* update skb protocol field */
+	skb->protocol = eth_type_trans(skb, dev);
+
+	/* verify L4 TCP/UDP checksum */
+	tsmac_chksum_verify(skb, desc);
+
+	return 0;
+}
+
+static TSMAC_ATTR_INLINE void tsmac_rx_loopback(struct net_device *,
+						struct sk_buff *);
+/*
+ * Go through the RX descriptor ring to process each received packet and send
+ * it up to the network stack until either 1) running out of quota or 2) RX
+ * descriptor ring is empty
+ */
+static TSMAC_ATTR_INLINE unsigned int tsmac_rx_get_pkts(struct net_device *dev,
+							struct tsmac_private
+							*lp,
+							const unsigned int
+							work_limit)
+{
+	struct Q_Desc *desc;
+
+	unsigned int desc_index;
+	u32 desc_ctl;
+	unsigned int pkt_processed = 0;
+	const unsigned int rx_size = lp->rx.size;
+	struct sk_buff *skb;
+	struct net_device_stats *const lx_stats = &lp->lx_stats;
+	struct tsmac_stats_sw *const sw_stats = &lp->sw_stats;
+
+	desc_index = lp->rx.index;
+	desc = &lp->rx.desc_p[desc_index];
+	desc_ctl = desc->FDCtl;
+
+	/* loop until the descriptor ring is empty or running out of quota */
+	while (((desc_ctl & FD_DMA_Own) == 0) && (pkt_processed < work_limit)) {
+		/* get descriptor information */
+		const u32 desc_status = desc->FDStat;
+		const u16 pkt_len = desc_ctl & FD_RxBuffLn_Mask;
+		const u32 vq_num = desc_status & Rx_VQ_Mask;
+		const bool sop = ((desc_ctl & FD_SOP) != 0);
+
+		/*
+		 * if we've got a good packet, the skb address needs to be
+		 * saved before a new skb is allocated
+		 */
+		skb = lp->rx.skb_pp[desc_index];
+		prefetch(skb->data - NET_IP_ALIGN);
+		prefetch(skb->data - NET_IP_ALIGN + L1_CACHE_BYTES);
+
+		/* received error packet, update error statistics */
+		if (unlikely(!sop || ((desc_ctl & FD_EOP) == 0) ||
+			     ((desc_status & Rx_Good) == 0) ||
+			     (pkt_len > MAX_PKT_SIZE))) {
+			skb = NULL;
+
+			if (sop) {
+				lx_stats->rx_errors++;
+
+				if (desc_status & Rx_LenErr)
+					lx_stats->rx_length_errors++;
+				if (desc_status & Rx_LongErr)
+					sw_stats->rx_long_errors++;
+				if (desc_status & Rx_CRCErr)
+					lx_stats->rx_crc_errors++;
+				if (desc_status & Rx_AlignErr)
+					lx_stats->rx_frame_errors++;
+				if (desc_ctl & FD_RxTrunc)
+					sw_stats->rx_trunc_errors++;
+			}
+
+			goto tsmac_rx_next_desc;
+		}
+
+		/*
+		 * If a replacement skb cannot be allocated, drop the packet
+		 * and reuse the existing buffer
+		 */
+		if (unlikely(tsmac_buffer_prepare(dev, lp, desc,
+						  desc_index) != 0)) {
+			skb = NULL;
+			lx_stats->rx_dropped++;
+			goto tsmac_rx_next_desc;
+		}
+#ifdef CONFIG_USE_FASTPATH
+		/* DDR coherent flush if skb is using fast path */
+		tsmac_coherent_flush();
+#endif
+
+		/* skb manipulation */
+		if (unlikely(tsmac_rx_skb(dev, desc, skb, pkt_len) < 0)) {
+			skb = NULL;
+			lx_stats->rx_dropped++;
+			goto tsmac_rx_next_desc;
+		}
+
+		/* update statistics */
+		lx_stats->rx_packets++;
+		sw_stats->rx_bytes += pkt_len;
+		if (desc_status & Rx_MCast)
+			lx_stats->multicast++;
+		sw_stats->rx_vq_frames[vq_num]++;
+
+#ifdef CONFIG_TSMAC_TEST_CMDS
+		/* checksum failed bad packet or not supported
+		 * by controller */
+		if (skb->ip_summed == CHECKSUM_NONE) {
+			if (skb->protocol == ETH_P_8021Q)
+				sw_stats->rx_nochksum_vlan++;
+			else
+				sw_stats->rx_nochksum_nonvlan++;
+		}
+#endif
+
+		dev->last_rx = jiffies;
+
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+		if (lp->loopback_enable)
+			tsmac_rx_loopback(dev, skb);
+#endif
+
+ tsmac_rx_next_desc:
+		/*
+		 * Put memory barrier here to make sure descriptor control
+		 * register is last set
+		 */
+		barrier();
+
+		/* give the descriptor back to DMA */
+		desc->FDCtl = (FD_DMA_Own | (TSMAC_BUFSIZE - RXALIGN_PAD));
+
+		/* advance to the next descriptor */
+		desc_index++;
+		if (unlikely(desc_index >= rx_size))
+			desc_index = 0;
+		desc = &lp->rx.desc_p[desc_index];
+
+		if (sop) {
+			/* update VQ token count after each packet received */
+			tsmac_rx_token_ctrl(lp, vq_num, desc_index);
+		}
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+		if (lp->loopback_enable)
+			return 0;
+#endif
+		/* send skb up to the network stack */
+		if (likely(skb != NULL))
+			netif_receive_skb(skb);
+
+		pkt_processed++;
+		desc_ctl = desc->FDCtl;
+	}			/* end while loop */
+
+	lp->rx.index = desc_index;
+	return pkt_processed;
+}
+
+/*
+ * RX polling routine used in NAPI
+ */
+static int PMC_FAST tsmac_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct tsmac_private *lp = container_of(napi, struct tsmac_private,
+						napi);
+	struct net_device *dev = lp->ndev;
+
+	unsigned int work_done;
+
+	unsigned long irq_flag, irq_status;
+
+	/* carrier is down, quit right away */
+	if (unlikely(!netif_carrier_ok(dev) || !netif_running(dev))) {
+		napi_complete(napi);
+
+		printk(KERN_DEBUG "%s: Quit RX polling routine\n", dev->name);
+
+		/* enable RX interrupts */
+		local_irq_save(irq_flag);
+
+		/* enable RX receive interrupt */
+		tsmac_write(RX_CTL_ENA, &lp->reg_map->mac.rx_ctl);
+
+		/* ack possible RX exhausted interrupts to prevent deadlock */
+		tsmac_write(IntSrc_RxDescEx, &lp->reg_map->dma.int_src);
+
+		/* enable RX exhausted interrupt */
+		tsmac_write(INT_EN_CMD, &lp->reg_map->dma.int_ena);
+
+		/* flush to make sure TSMAC gets it */
+		tsmac_cpu_to_tsmac_flush(lp->unit);
+
+		local_irq_restore(irq_flag);
+
+		return 0;
+	}
+
+	/* flush descriptors into the DSPRAM */
+	tsmac_dspram_flush();
+
+	/* loop until descriptor ring is empty or running out of quota */
+	work_done = tsmac_rx_get_pkts(dev, lp, budget);
+
+	/* update device based quota and CPU budget */
+	budget -= work_done;
+
+	/* running out of quota */
+	if (work_done >= budget) {
+		/* got some room, clear possible RX exhausted interrupt */
+		tsmac_write(IntSrc_RxDescEx, &lp->reg_map->dma.int_src);
+
+		/* update RX exhausted counter */
+		irq_status = tsmac_read(&lp->reg_map->dma.int_src);
+		if (irq_status & IntSrc_RxDescEx)
+			lp->lx_stats.rx_fifo_errors++;
+
+		return 1;
+	}
+
+	/*
+	 * If we got here, we've finished processing all outstanding packets
+	 * and the RX descriptor ring is empty
+	 */
+
+	/* tell the kernel that we are done */
+	napi_complete(napi);
+
+	/*
+	 * enabling RX receive and RX exhausted interrupt cannot be interrupted
+	 */
+	local_irq_save(irq_flag);
+
+	/* enable RX receive interrupt */
+	tsmac_write(RX_CTL_ENA, &lp->reg_map->mac.rx_ctl);
+
+	/* ack possible RX exhausted interrupts to prevent deadlock */
+	tsmac_write(IntSrc_RxDescEx, &lp->reg_map->dma.int_src);
+
+	/* enable RX exhausted interrupt */
+	tsmac_write(INT_EN_CMD, &lp->reg_map->dma.int_ena);
+
+	/* flush to make sure TSMAC gets it */
+	tsmac_cpu_to_tsmac_flush(lp->unit);
+
+	/* update RX exhausted counter */
+	irq_status = tsmac_read(&lp->reg_map->dma.int_src);
+	if (irq_status & IntSrc_RxDescEx)
+		lp->lx_stats.rx_fifo_errors++;
+
+	local_irq_restore(irq_flag);
+
+	/*
+	 * There is a window above where new packet can come in before RX
+	 * interrupt is enabled. Therefore, we do the check below to make
+	 * sure no packet will be missed
+	 */
+
+	/* make sure descriptors going to the DSPRAM */
+	tsmac_dspram_flush();
+
+	/* advance to the next RX descriptor */
+	if ((lp->rx.desc_p[lp->rx.index].FDCtl & FD_DMA_Own) !=
+	    FD_DMA_Own && napi_reschedule(napi)) {
+		/* disable interrupts */
+		tsmac_write((INT_EN_CMD & ~IntEn_RxDescEx),
+			    &lp->reg_map->dma.int_ena);
+		tsmac_write(RX_CTL_DIS, &lp->reg_map->mac.rx_ctl);
+		/* flush to make sure TSMAC gets it */
+		tsmac_cpu_to_tsmac_flush(lp->unit);
+
+		/* get Linux to schedule RX polling */
+		return 1;
+	}
+
+	return 0;
+}
+
+#define TX_STA_ERR (Tx_ExColl | Tx_SQErr | Tx_LCarr | Tx_ExDefer | Tx_LateColl)
+/*
+ * Update TX statistics counters
+ */
+static TSMAC_ATTR_INLINE void tsmac_update_tx_stat(struct tsmac_private *lp,
+						   struct Q_Desc *desc)
+{
+	u32 status = desc->FDStat;
+
+	if (unlikely(status & Tx_TxColl_Mask))
+		lp->lx_stats.collisions += status & Tx_TxColl_Mask;
+
+	if (likely(!(status & TX_STA_ERR))) {
+		lp->lx_stats.tx_packets++;
+		/* remember to add 4 bytes CRC */
+		lp->sw_stats.tx_bytes += (desc->FDCtl & FD_TxBuffLn_Mask) + 4;
+	} else {
+		lp->lx_stats.tx_errors++;
+	}
+}
+
+/*
+* Place holder for integrating the TX QoS mechanism with Linux TC. Assume all
+* outgoing packets are high priority for now.
+*/
+static inline u32 tsmac_get_tx_qnum(struct sk_buff *skb,
+				    struct tsmac_private *lp)
+{
+	/*
+	 * If the skb->priority value is outside of supported range, then treat
+	 * as low priority packet. Otherwise, use the skb->priority to egress
+	 * queue mapping.
+	 */
+	if (skb->priority >= TSMAC_NUM_SKB_PRIORITY)
+		return TSMAC_DESC_PRI_LO;
+	else
+		return lp->egress_prio[skb->priority];
+}
+
+/*
+* Clear transmitted packets. This routine also returns number of packets been
+* cleared
+*/
+static TSMAC_ATTR_INLINE u32 tsmac_tx_clear(struct tsmac_private *lp,
+					    const u32 ch)
+{
+	struct tsmac_tx *tx = &lp->tx[ch];
+	u32 tail = tx->tail;
+	struct Q_Desc *desc = &tx->desc_p[tail];
+	u32 pkt_cleared = 0;
+
+	while (1) {
+		/* DMA owns the descriptor */
+		if (desc->FDCtl & FD_DMA_Own)
+			break;
+
+		/* TX descriptor ring is empty */
+		if (tx->qcnt == 0)
+			break;
+
+		/* update statistics */
+		tsmac_update_tx_stat(lp, desc);
+
+		/* clear descriptor and free skb */
+		tsmac_buffer_clear(tx->skb_pp, tail);
+
+		/* advance to the next descriptor */
+		tx->qcnt--;
+		tail++;
+		if (unlikely(tail >= tx->size))
+			tail = 0;
+		desc = &tx->desc_p[tail];
+
+		pkt_cleared++;
+	}
+
+	tx->tail = tail;
+
+	return pkt_cleared;
+}
+
+/*
+* TSMAC TX, called from the Linux network stack
+*/
+static int PMC_FAST tsmac_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct Q_Desc *desc;
+	u32 qnum = 0;
+	u32 qhead;
+	dma_addr_t dma_skb;
+	tsmac_hook_function tsmac_tx_hook = NULL;
+
+	spin_lock(&lp->tx_lock);
+
+	/* carrier is turned down by somebody else */
+	if (unlikely(!netif_carrier_ok(dev))) {
+		/* drop packet, update counter, and free skb */
+		lp->lx_stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
+		spin_unlock(&lp->tx_lock);
+		return NETDEV_TX_OK;
+	}
+
+	rcu_read_lock();
+	tsmac_tx_hook = rcu_dereference(lp->tsmac_tx_hook);
+	if (unlikely(tsmac_tx_hook)) {
+		void *priv = rcu_dereference(lp->tx_priv);
+
+		if (unlikely(tsmac_tx_hook(&skb, dev, priv) < 0)) {
+			rcu_read_unlock();
+			lp->lx_stats.tx_dropped++;
+			dev_kfree_skb_any(skb);
+			spin_unlock(&lp->tx_lock);
+			return NETDEV_TX_OK;
+		}
+	}
+	rcu_read_unlock();
+
+	/* determine priority of packet to transmit */
+	qnum = tsmac_get_tx_qnum(skb, lp);
+
+	/* clean up previously transmitted packets */
+	tsmac_tx_clear(lp, qnum);
+
+	tx = &lp->tx[qnum];
+
+	/*
+	 * If the high priority (Channel 0) TX descriptor ring is full, stop
+	 * the Linux egress queue. Also, enable the TX complete interrupt so
+	 * we can re-enable the egress queue when there's room.
+	 *
+	 * If the low priority (Channel 1) TX descriptor ring is full, simply
+	 * drop the packet.
+	 *
+	 * Must have at least 2 descriptors owned by the driver so the
+	 * controller does not loop around and re-transmit an old packet.
+	 */
+	if (unlikely(tx->qcnt >= tx->size - 2)) {
+		lp->sw_stats.tx_full[qnum]++;
+		if (qnum == TSMAC_DESC_PRI_HI) {
+			/* stop queue and enable TX complete interrupt */
+			netif_stop_queue(dev);
+			tsmac_write(TX_CFG(TX_CTL_ENA, lp->flow_ctl.enable),
+				    &lp->reg_map->mac.tx_ctl);
+
+			/* flush to make sure TSMAC gets it */
+			tsmac_cpu_to_tsmac_flush(lp->unit);
+			spin_unlock(&lp->tx_lock);
+			return NETDEV_TX_BUSY;
+		} else {	/* low priority packet */
+			/* drop packet and free skb */
+			lp->lx_stats.tx_dropped++;
+			dev_kfree_skb_any(skb);
+			spin_unlock(&lp->tx_lock);
+			return NETDEV_TX_OK;
+		}
+	}
+
+	qhead = tx->head;
+	desc = &tx->desc_p[qhead];
+	tx->head = qhead + 1;
+	if (unlikely(tx->head >= tx->size))
+		tx->head = 0;
+	tx->skb_pp[qhead] = skb;
+
+	/* map buffer to device and writeback cache to packet buffer */
+#ifdef CONFIG_CACHE_OPTIMIZATION
+	dma_skb = pmc_skb_wback_inv(skb);
+#else
+	dma_skb = dma_map_single(lp->dev, skb->data, skb->len, DMA_TO_DEVICE);
+#endif
+
+	/*
+	 * If skb using fast path, flush the fastpath DXU here to make sure
+	 * it goes in the DRAM before the device uses it
+	 */
+#ifdef CONFIG_USE_FASTPATH
+	tsmac_fastpath_flush();
+#else
+#ifdef CONFIG_DESC_ALL_DSPRAM
+	tsmac_coherent_flush();
+#endif
+#endif
+
+	tx->qcnt++;
+
+	/* set up TX descriptor */
+	desc->FDBuffPtr = ((u32) dma_skb) & FD_TxBuff_Mask;
+
+	/*
+	 * FD_DMA_Own should be the last field to modify in the descriptor;
+	 * therefore, we use barrier() here to prevent compiler optimization
+	 * from moving it around
+	 */
+	barrier();
+	desc->FDCtl = (FD_DMA_Own | FD_SOP | FD_EOP |
+		       (skb->len & FD_TxBuffLn_Mask));
+
+	/* wake up the transmitter */
+	switch (qnum) {
+	case TSMAC_DESC_PRI_HI:
+		tsmac_write(DMA_TxWakeUp_CH0, &lp->reg_map->dma.dma_init);
+		break;
+	case TSMAC_DESC_PRI_LO:
+		tsmac_write(DMA_TxWakeUp_CH1, &lp->reg_map->dma.dma_init);
+		break;
+	default:
+		break;
+	}
+
+	dev->trans_start = jiffies;
+
+	spin_unlock(&lp->tx_lock);
+	return NETDEV_TX_OK;
+}				/* tsmac_tx() */
+
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+/*
+* Do a line loopback by transmitting the received packets on the same
+* interface
+*/
+static TSMAC_ATTR_INLINE void tsmac_rx_loopback(struct net_device *dev,
+						struct sk_buff *skb)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct Q_Desc *desc;
+	u32 qnum = TSMAC_DESC_PRI_HI;
+	u32 qhead;
+	dma_addr_t dma_skb;
+
+	skb->dev = dev;
+	dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL, skb->len);
+
+	tsmac_tx_clear(lp, qnum);
+
+	tx = &lp->tx[qnum];
+
+	/* there's no room in the TX descriptor ring */
+	if (tx->qcnt >= tx->size - 2) {
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
+	/* we have room, so get the next available Tx desc */
+	qhead = tx->head;
+	desc = &tx->desc_p[qhead];
+	tx->head = qhead + 1;
+	if (tx->head >= tx->size)
+		tx->head = 0;
+
+	/* map buffer to device AND writeback cache to packet buffer */
+	dma_skb = dma_map_single(lp->dev, skb->data, skb->len, DMA_TO_DEVICE);
+
+	/* update TX queue counter */
+	tx->qcnt++;
+
+	/* set up TX descriptor */
+	desc->FDBuffPtr = ((u32) dma_skb) & FD_TxBuff_Mask;
+
+	barrier();
+	desc->FDCtl = (FD_DMA_Own | FD_SOP | FD_EOP |
+		       (skb->len & FD_TxBuffLn_Mask));
+
+	/* wake up transmitter */
+	tsmac_write(DMA_TxWakeUp_CH0, &lp->reg_map->dma.dma_init);
+}
+#endif
+
+/*
+ * Timer function when expired checking the HW counter statistics to prevent
+ * overflow
+ */
+static void tsmac_stats_check(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* Acquire lock to make sure TSMAC is not restarting */
+	tsmac_update_hw_stats(dev);
+
+	/* reschedule itself */
+	lp->stats_timer.expires = jiffies + HZ * STATS_CHK_TIME;
+	add_timer_on(&lp->stats_timer, atomic_read(&lp->timer_task_cpu));
+}
+
+/*
+ * Initialize the TSMAC interface, invoked some time after booting when
+ * 'ifconfig' is called
+ */
+static int tsmac_open(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	int err = -EBUSY;
+
+	/*TODO: spin_lock required ? */
+
+	/* allocate memory for TX/RX descriptors */
+	if (tsmac_alloc_desc(dev) == TSMAC_Q_INIT_ERROR) {
+		printk(KERN_WARNING "TSMAC %s: Unable to allocate queues\n",
+		       dev->name);
+		/* free descriptor memory */
+		tsmac_free_desc(dev);
+		goto out_err;
+	}
+
+	/* set up the descriptor ring and allocate skb */
+	if (tsmac_init_queues(dev) == TSMAC_Q_INIT_ERROR) {
+		printk(KERN_WARNING "TSMAC %s: Unable to set up queues\n",
+		       dev->name);
+		/* free skb and descriptor memory */
+		tsmac_free_queues(dev);
+		tsmac_free_desc(dev);
+		goto out_err;
+	}
+
+	/* initialize the MAC */
+	spin_lock_bh(&lp->control_lock);
+	tsmac_mac_reset(dev);
+	spin_unlock_bh(&lp->control_lock);
+
+	err = tsmac_mac_init(dev);
+	if (err)
+		goto out_reset_mac;
+
+	err = tsmac_check_phy_driver(dev);
+	if (err)
+		goto out_reset_mac;
+
+	if (lp->conn_type == MSP_CT_ETHPHY)
+		/* PAL takes care of netif_carrier_on */
+		phy_start(lp->phyptr);
+	else
+		/* assume carrier is up */
+		netif_carrier_on(dev);
+
+	/* initialize the statistics timer */
+	init_timer(&lp->stats_timer);
+	lp->stats_timer.expires = jiffies + HZ * STATS_CHK_TIME;
+	lp->stats_timer.data = (u32) dev;
+	lp->stats_timer.function = tsmac_stats_check;
+	add_timer_on(&lp->stats_timer, atomic_read(&lp->timer_task_cpu));
+	/* start up the Linux egress queue */
+	netif_start_queue(dev);
+
+	/* enable NAPI */
+	napi_enable(&lp->napi);
+
+	atomic_set(&lp->close_flag, 0);
+
+	/* Allocate the IRQ */
+	if (request_irq(dev->irq, &tsmac_interrupt,
+					IRQF_SHARED, cardname, dev)) {
+		printk(KERN_WARNING "TSMAC %s: unable to reserve IRQ %d\n",
+		       dev->name, dev->irq);
+		goto out_reset_mac;
+	}
+	/* enable TX/RX path in the correct order */
+	tsmac_enable_txrx(dev);
+
+	return 0;
+
+ out_reset_mac:
+	spin_lock_bh(&lp->control_lock);
+	tsmac_mac_reset(dev);
+	spin_unlock_bh(&lp->control_lock);
+ out_err:
+	return err;
+}
+
+/*
+ * Close the TSMAC interface and clean up, usually invoked when 'ifconfig down'
+ * is called
+ */
+static int tsmac_close(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	/* This guarantees no IRQ (of the dev) will be called */
+	free_irq(dev->irq, dev);
+
+	if (lp->conn_type == MSP_CT_ETHPHY)
+		phy_stop(lp->phyptr);
+	else
+		/* bring down the carrier */
+		netif_carrier_off(dev);
+
+	/* stop the egress queue */
+	netif_stop_queue(dev);
+
+	/* Disable NAPI */
+	napi_disable(&lp->napi);
+
+	/* set close flag so tsmac_restart cannot run */
+	atomic_set(&lp->close_flag, 1);
+
+	/* mark MAC link is down */
+	lp->link = 0;
+
+	/*
+	 * If tsmac_restart has already been scheduled, wait until all of them
+	 * quit
+	 */
+	if (atomic_read(&lp->restart_pending_cnt)) {
+		cancel_delayed_work_sync(&lp->restart_task);
+		atomic_set(&lp->restart_pending_cnt, 0);
+	}
+
+	/* delete the stats timer */
+	del_timer_sync(&lp->stats_timer);
+
+	/*
+	 * Since we are resetting the MAC subsystem, we should disable local
+	 * IRQ so we don't get interrupted
+	 */
+	local_irq_save(flags);
+
+	/* disable TSMAC interrupts */
+	tsmac_write(0, &lp->reg_map->dma.int_ena);
+	tsmac_write(Rx_FloodEn, &lp->reg_map->mac.rx_ctl);
+	tsmac_write(TX_CFG(TX_CTL_DIS, lp->flow_ctl.enable),
+		    &lp->reg_map->mac.tx_ctl);
+
+	/* Clean up the adaptor. */
+	spin_lock(&lp->control_lock);
+	tsmac_mac_reset(dev);
+	spin_unlock(&lp->control_lock);
+
+	/* free the the skb memeory and reset the descriptor ring */
+	tsmac_free_queues(dev);
+
+	/* free the descriptor ring memory */
+	tsmac_free_desc(dev);
+
+	local_irq_restore(flags);
+
+	return 0;
+}
+
+/*
+ * Change MTU size (called via ifconfig ethX mtu 1000)
+ */
+static int tsmac_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 length;
+
+	if ((new_mtu < MIN_MTU_SIZE) || (new_mtu > MAX_MTU_SIZE))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	length = new_mtu + 18;
+
+	/* set MTU for both VLAN and non-VLAN frames */
+	tsmac_write(((length + 4) << 16) | length,
+		    &lp->reg_map->mac.max_length);
+
+	return 0;
+}
+
+/*
+ * If there is a transmit timeout we schedule to restart the device
+ */
+static void tsmac_tx_timeout(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	tsmac_shutdown(dev);
+	if (schedule_delayed_work_on(atomic_read(&lp->timer_task_cpu),
+				     &lp->restart_task, 0))
+		atomic_inc(&lp->restart_pending_cnt);
+}
+
+/*
+ * Get the current counter statistics
+ */
+static struct net_device_stats *tsmac_get_stats(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* get TX/RX bytes from software counters */
+	lp->lx_stats.rx_bytes = (u32) lp->sw_stats.rx_bytes;
+	lp->lx_stats.tx_bytes = (u32) lp->sw_stats.tx_bytes;
+
+	if (netif_running(dev))
+		tsmac_update_hw_stats(dev);
+
+	return &lp->lx_stats;
+}
+
+static const struct net_device_ops tsmac_netdev_ops = {
+	.ndo_open = tsmac_open,
+	.ndo_start_xmit = tsmac_tx,
+	.ndo_stop = tsmac_close,
+	.ndo_change_mtu = tsmac_change_mtu,
+	.ndo_set_multicast_list = tsmac_set_multicast_list,
+	.ndo_tx_timeout = tsmac_tx_timeout,
+	.ndo_do_ioctl = tsmac_ioctl,
+	.ndo_get_stats = tsmac_get_stats,
+	.ndo_set_mac_address = eth_mac_addr,
+};
+
+/*
+ * Probe for a TSMAC interface
+ */
+static int tsmac_probe(struct platform_device *pldev)
+{
+	int unit = pldev->id;
+	int i;
+	int err = -ENODEV;
+	u8 macaddr[8];
+	struct tsmac_private *lp;
+	char tmp_str[12];
+	struct net_device *dev = NULL;
+	struct resource *res;
+	void *mapaddr;
+	int ret;
+	struct eth_platform_data *eth_data = pldev->dev.platform_data;
+
+	/* check the hardware parameters */
+	if (unit < 0)
+		goto out_err;
+
+	/* Sanity checks on parameters */
+	if (unit >= TSMAC_MAX_UNITS)
+		goto out_err;
+
+	dev = alloc_etherdev(sizeof(struct tsmac_private));
+	if (dev == NULL) {
+		err = -ENOMEM;
+		goto out_err;
+	}
+	SET_NETDEV_DEV(dev, &pldev->dev);
+	dev_set_drvdata(&pldev->dev, dev);
+
+	lp = netdev_priv(dev);
+	memset(lp, 0, sizeof(struct tsmac_private));
+
+	res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
+	if (!res) {
+		printk(KERN_ERR "tsmac_probe: IOMEM resource not found for "
+		       "tsmac%d\n", unit);
+		goto out_netdev;
+	}
+	dev->base_addr = res->start;
+
+	/* reserve the memory region */
+	if (!request_mem_region(res->start + MSP_DMA_START,
+				sizeof(struct msp_dma_regs), "tsmac dma")) {
+		err = -EBUSY;
+		goto out_netdev;
+	}
+	if (!request_mem_region(res->start + MSP_MAC_START,
+				sizeof(struct msp_mac_regs), "tsmac mac")) {
+		err = -EBUSY;
+		goto out_memdma;
+	}
+	if (!request_mem_region(res->start + MSP_GPMII_START,
+				sizeof(struct msp_gpmii_regs), "tsmac gpmii")) {
+		err = -EBUSY;
+		goto out_memmac;
+	}
+
+	/* remap the memory */
+	mapaddr = ioremap_nocache(res->start, res->end - res->start + 1);
+	if (!mapaddr) {
+		printk(KERN_WARNING
+		       "TSMAC %s: unable to ioremap address 0x%08x\n",
+		       dev->name, res->start);
+		goto out_memgpmii;
+	}
+	lp->reg_map = mapaddr;
+	dev->irq = platform_get_irq(pldev, 0);
+
+	/* set the logical and hardware units */
+	lp->unit = unit;
+
+	/* set the loopback status */
+	lp->loopback_enable = 0;
+
+	/* set default TX/RX descriptor ring size and mask */
+	lp->rx.size = RX_RING_SIZE_DEF;
+	lp->tx[0].size = TX_RING_SIZE_DEF;
+	lp->tx[1].size = TX_RING_SIZE_DEF;
+
+	/* Store the struct device pointer, for DMA ops */
+	lp->dev = &pldev->dev;
+	lp->ndev = dev;
+
+	/* set connection type using platform data. The connection type can
+	   be changed by the user via /proc/net/ethX/connType */
+	if (eth_data == NULL) {
+		printk(KERN_WARNING
+		       "TSMAC%d: No default connection type provided"
+		       " assuming phy\n", lp->unit);
+		ret = tsmac_set_conntype(dev, MSP_CT_ETHPHY);
+	} else
+		ret = tsmac_set_conntype(dev, eth_data->conn_type);
+
+	if (ret)
+		goto out_unmap;
+
+	/* parse MAC address */
+	/* Retrieve the mac address from the PROM */
+	snprintf(tmp_str, 12, TSMAC_VAR_MACADDR "%d", lp->unit);
+	if (get_ethernet_addr(tmp_str, macaddr)) {
+		printk(KERN_INFO "TSMAC%d: no MAC addr specified\n", lp->unit);
+	} else if (macaddr[0] & 0x01) {
+		printk(KERN_WARNING
+		       "TSMAC%d: bad Multicast MAC addr specified "
+		       "%02x:%02x:%02x:%02x:%02x:%02x\n",
+		       lp->unit,
+		       macaddr[0], macaddr[1], macaddr[2],
+		       macaddr[3], macaddr[4], macaddr[5]);
+	} else {
+		/* MAC address */
+		dev->addr_len = ETH_ALEN;
+		for (i = 0; i < dev->addr_len; i++)
+			dev->dev_addr[i] = macaddr[i];
+		printk(KERN_INFO "TSMAC%d: assigned MAC address: "
+		       "%02x:%02x:%02x:%02x:%02x:%02x\n",
+		       lp->unit, macaddr[0], macaddr[1], macaddr[2],
+		       macaddr[3], macaddr[4], macaddr[5]);
+	}
+
+	/* if no default PHY setup, TSMAC will scan for an available PHY */
+	if (eth_data != NULL) {
+		lp->bus_unit = eth_data->bus_unit;
+		lp->phy_addr = eth_data->phy_addr;
+	}
+
+	lp->bus.priv = dev;
+	tsmac_register_bus(&lp->bus, lp->unit);
+
+	if (lp->conn_type == MSP_CT_ETHPHY) {
+		lp->phyptr = tsmac_mii_probe(dev, &tsmac_adjust_link);
+		lp->link = 0;
+		lp->speed = 0;
+		lp->duplex = -1;
+
+		if (lp->phyptr == NULL) {
+			err = -1;
+			goto out_unmap;
+		}
+	} else if (lp->conn_type == MSP_CT_ETHSWITCH) {
+		char bus_id[MII_BUS_ID_SIZE];
+		char bus_unit[4];
+		sprintf(bus_unit, "%x", lp->bus_unit);
+
+		snprintf(bus_id, MII_BUS_ID_SIZE, PHY_ID_FMT, bus_unit,
+			 lp->phy_addr);
+		lp->phyptr = phy_attach(dev, bus_id, 0,
+					PHY_INTERFACE_MODE_GMII);
+	}
+
+	/* set the various call back functions */
+	SET_ETHTOOL_OPS(dev, &tsmac_ethtool_ops);
+	dev->watchdog_timeo = TX_TIMEOUT * HZ;
+	dev->netdev_ops = &tsmac_netdev_ops;
+
+	/* initialize NAPI */
+	netif_napi_add(dev, &lp->napi, tsmac_rx_poll, TSMAC_NAPI_WEIGHT);
+
+	/* set default CPU for timer tasks */
+	atomic_set(&lp->timer_task_cpu, TSMAC_TASK_CPU_DEFAULT);
+
+	/* initialize a work queue for the restart task */
+	INIT_DELAYED_WORK(&lp->restart_task, tsmac_restart);
+
+	/* load default values of VQs and Flood Control details */
+	tsmac_config_def_vqnpause(dev);
+
+	/* set default mapping for skb->priority values to egress queues */
+	for (i = 0; i < TSMAC_NUM_SKB_PRIORITY; i++)
+		lp->egress_prio[i] = TSMAC_DESC_PRI_HI;
+
+#ifndef MODULE
+	{
+		static u8 printed_version;
+
+		if (!printed_version++) {
+			printk(KERN_INFO "%s: %s, %s\n",
+			       drv_file, drv_version, drv_reldate);
+			printk(KERN_INFO "%s: PMC-Sierra,"
+			       " www.pmc-sierra.com\n", drv_file);
+		}
+	}
+#endif				/* !MODULE */
+
+	printk(KERN_INFO "TSMAC%d: found at physical address %lx, "
+	       "irq %d\n", unit, dev->base_addr, dev->irq);
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_WARNING "TSMAC%d: unable to register network "
+		       "device\n", unit);
+		goto out_unmap;
+	}
+
+	tsmac_create_proc_entries(dev);
+
+	/* initialize spinlocks */
+	spin_lock_init(&lp->control_lock);
+	spin_lock_init(&lp->restart_lock);
+	spin_lock_init(&lp->tx_lock);
+	spin_lock_init(&lp->stats_lock);
+
+	atomic_set(&lp->restart_pending_cnt, 0);
+
+	return 0;
+
+ out_unmap:
+	iounmap(mapaddr);
+ out_memgpmii:
+	release_mem_region(dev->base_addr + MSP_GPMII_START,
+			   sizeof(struct msp_gpmii_regs));
+ out_memmac:
+	release_mem_region(dev->base_addr + MSP_MAC_START,
+			   sizeof(struct msp_mac_regs));
+ out_memdma:
+	release_mem_region(dev->base_addr + MSP_DMA_START,
+			   sizeof(struct msp_dma_regs));
+ out_netdev:
+	free_netdev(dev);
+ out_err:
+	return err;
+}
+
+/*
+ * This function removes allocated resources for the driver
+ */
+static int tsmac_remove(struct platform_device *pldev)
+{
+	struct net_device *dev = dev_get_drvdata(&pldev->dev);
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	tsmac_remove_proc_entries();
+	mdiobus_unregister(&lp->bus);
+	unregister_netdev(dev);
+
+	iounmap(lp->reg_map);
+	lp->reg_map = NULL;
+	release_mem_region(dev->base_addr + MSP_DMA_START,
+			   sizeof(struct msp_dma_regs));
+	release_mem_region(dev->base_addr + MSP_MAC_START,
+			   sizeof(struct msp_mac_regs));
+	release_mem_region(dev->base_addr + MSP_GPMII_START,
+			   sizeof(struct msp_gpmii_regs));
+
+	free_netdev(dev);
+	return 0;
+}
+
+/* platform device stuff for linux 2.6 */
+static char tsmac_string[] = MSP_TSMAC_ID;
+
+static struct platform_driver tsmac_driver = {
+	.probe = tsmac_probe,
+	.remove = __devexit_p(tsmac_remove),
+	.driver = {
+		   .name = tsmac_string,
+		   },
+};
+
+/*
+ * Initializes the driver module. Register driver for the device
+ */
+static int __init tsmac_init_module(void)
+{
+	printk(KERN_NOTICE "PMC-Sierra TSMAC Gigabit Ethernet Driver\n");
+
+	if (platform_driver_register(&tsmac_driver)) {
+		printk(KERN_ERR "Driver registration failed\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+/*
+ * Clean up the module. Unregisters the driver and platform devices from the\
+ * kernel
+ */
+static void __exit tsmac_cleanup_module(void)
+{
+	platform_driver_unregister(&tsmac_driver);
+
+}
+
+MODULE_DESCRIPTION("PMC TSMAC 10/100/1000 Ethernet driver");
+MODULE_LICENSE("GPL");
+
+module_init(tsmac_init_module);
+module_exit(tsmac_cleanup_module);
+
+/*
+ * Read a TSMAC register
+ */
+u32 tsmac_read(void *addr)
+{
+	return __raw_readl(addr);
+}
+
+/*
+ * Write to a TSMAC register
+ */
+void PMC_FAST tsmac_write(u32 val, void *addr)
+{
+	__raw_writel(val, addr);
+}
+
+/* TODO : remove or modify for the proc file entry */
+#if 0
+int tsmac_get_phy(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct mii_ioctl_data *data = if_mii(req);
+	struct tsmac_phy tmp_phy;
+	uint16_t mii_reg = 0;
+	u32 mii_data = 0;
+
+	/* need to lock just in case interface is about to be closed */
+	spin_lock_bh(&lp->control_lock);
+	if (lp->phyptr == NULL) {
+		spin_unlock_bh(&lp->control_lock);
+		return -1;
+	}
+
+	tmp_phy.dev_control_lock = lp->phyptr->dev_control_lock;
+	spin_unlock_bh(&lp->control_lock);
+
+	tmp_phy.phyaddr = (data->phy_id & 0x1F);
+	tmp_phy.memaddr = &lp->reg_map->mac.md_data;
+
+	mii_reg = (data->reg_num & 0x1F);
+	mii_data = tsmac_phy_read(&tmp_phy, mii_reg);
+
+	data->val_out = (mii_data & 0xFFFF);
+	return 0;
+}
+
+int tsmac_get_phy_id(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct mii_ioctl_data *data = if_mii(req);
+
+	data->phy_id = lp->phy_addr;
+	return 0;
+}
+
+int tsmac_set_phy(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct mii_ioctl_data *data = if_mii(req);
+	struct tsmac_phy tmp_phy;
+	uint16_t mii_reg = 0;
+	u32 mii_data = 0;
+
+	/* need to lock just in case interface is about to be closed */
+	spin_lock_bh(&lp->control_lock);
+	if (lp->phyptr == NULL) {
+		spin_unlock_bh(&lp->control_lock);
+		return -1;
+	}
+
+	tmp_phy.dev_control_lock = lp->phyptr->dev_control_lock;
+	spin_unlock_bh(&lp->control_lock);
+
+	tmp_phy.phyaddr = (data->phy_id & 0x1F);
+	tmp_phy.memaddr = &lp->reg_map->mac.md_data;
+
+	mii_reg = (data->reg_num & 0x1F);
+	mii_data = (data->val_in & 0xFFFF);
+	tsmac_phy_write(&tmp_phy, mii_reg, mii_data);
+
+	return 0;
+}
+#endif				/* TODO : remove or modify */
+
+int tsmac_copy_to_mem(void *dst, void *src, u32 n, u8 context)
+{
+	if (context == TSMAC_USER_DATA)
+		return copy_to_user(dst, src, n);
+	else {
+		memcpy(dst, src, n);
+		return 0;
+	}
+}
+
+int tsmac_copy_from_mem(void *dst, void *src, u32 n, u8 context)
+{
+	if (context == TSMAC_USER_DATA)
+		return copy_from_user(dst, src, n);
+	else {
+		memcpy(dst, src, n);
+		return 0;
+	}
+}
+
+/*
+ * Write data to the ARC entry in big endian order
+ */
+void tsmac_set_arc_entry(struct net_device *dev, int index, unsigned char *addr)
+{
+	int arc_index = index * 6;
+	unsigned long arc_data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+#ifdef TSMAC_DEBUG
+	{
+		int i;
+		printk(KERN_INFO "%s: arc %d:", cardname, index);
+		for (i = 0; i < 6; i++)
+			printk(KERN_INFO " %02x", addr[i]);
+		printk(KERN_INFO "\n");
+	}
+#endif
+
+	/* starting location is an ODD address */
+	if (index & 1) {
+		/* read-modify-write first 2-bytes of data */
+		tsmac_write(arc_index - 2, &lp->reg_map->mac.arc_addr);
+		arc_data = tsmac_read(&lp->reg_map->mac.arc_data) & 0xffff0000;
+		arc_data |= (addr[0] << 8) | addr[1];
+		tsmac_write(arc_data, &lp->reg_map->mac.arc_data);
+
+		/* write last 4-bytes of data */
+		tsmac_write(arc_index + 2, &lp->reg_map->mac.arc_addr);
+		arc_data = (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) |
+		    addr[5];
+		tsmac_write(arc_data, &lp->reg_map->mac.arc_data);
+
+		/* starting location is an EVEN address */
+	} else {
+		/* write first 4-bytes of data */
+		tsmac_write(arc_index, &lp->reg_map->mac.arc_addr);
+		arc_data = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) |
+		    addr[3];
+		tsmac_write(arc_data, &lp->reg_map->mac.arc_data);
+
+		/* read-modify-write last 2-bytes of data */
+		tsmac_write(arc_index + 4, &lp->reg_map->mac.arc_addr);
+		arc_data = tsmac_read(&lp->reg_map->mac.arc_data) & 0x0000ffff;
+		arc_data |= (addr[4] << 24) | (addr[5] << 16);
+		tsmac_write(arc_data, &lp->reg_map->mac.arc_data);
+	}
+
+#if defined(TSMAC_DEBUG)
+	{
+		int i;
+		for (i = arc_index / 4; i < arc_index / 4 + 2; i++) {
+			tsmac_write(i * 4, &lp->reg_map->mac.arc_addr);
+			printk(KERN_INFO "arc 0x%x: %08x\n",
+			       i * 4, tsmac_read(&lp->reg_map->mac.arc_data));
+		}
+	}
+#endif
+}
+
+int tsmac_set_mac_addr(struct net_device *dev, void *addr)
+{
+	struct sockaddr *saddr = addr;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* conntype can ONLY be changed if the interface is NOT running */
+	if (netif_running(dev)) {
+		printk(KERN_WARNING "TSMAC %s: cannot change MAC address "
+		       "while the interface is running\n", dev->name);
+		return -1;
+	}
+
+	memcpy(dev->dev_addr, saddr->sa_data, dev->addr_len);
+	tsmac_set_arc_entry(dev, ARC_ENTRY_MAC, dev->dev_addr);
+
+	/* also copy MAC address to source address of PAUSE generation */
+	memcpy(lp->flow_ctl.src_addr, dev->dev_addr, dev->addr_len);
+	tsmac_set_arc_entry(dev, ARC_ENTRY_PAUSE_SRC, lp->flow_ctl.src_addr);
+
+	return 0;
+}
+
+int tsmac_set_conntype(struct net_device *dev, enum msp_conntype_enum conn_type)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* conntype can ONLY be changed if the interface is NOT running */
+	if (netif_running(dev)) {
+		printk(KERN_WARNING "TSMAC %s: cannot change connection type "
+		       "while the interface is running\n", dev->name);
+		return -1;
+	}
+
+	lp->conn_type = conn_type;
+
+	switch (conn_type) {
+	case (MSP_CT_MOCA):
+	case (MSP_CT_ETHPHY):
+		if (lp->unit == TSMAC_C)
+			tsmac_enable_mac_c(dev);
+
+		tsmac_set_mii_type(dev, TSMAC_MT_GMII);
+		break;
+	case (MSP_CT_GPON):
+	case (MSP_CT_ETHSWITCH):
+		if (lp->unit == TSMAC_C)
+			tsmac_enable_mac_c(dev);
+
+		lp->speed = SPEED_1000;
+		lp->duplex = DUPLEX_FULL;
+		lp->link = 1;
+		tsmac_set_mii_type(dev, TSMAC_MT_GMII);
+		break;
+	default:
+		tsmac_set_mii_type(dev, TSMAC_MT_GMII);
+		break;
+	}
+
+	return 0;
+}
+
+int tsmac_set_phyaddr(struct net_device *dev, int bus_unit, int phy_addr)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* PHY address can ONLY be changed if the interface is NOT running */
+	if (netif_running(dev)) {
+		printk(KERN_WARNING "TSMAC %s: cannot change PHY address "
+		       "while the interface is running\n", dev->name);
+		return -1;
+	}
+
+	lp->bus_unit = bus_unit;
+	lp->phy_addr = phy_addr;
+
+	return 0;
+}
+
+int tsmac_set_mii_type(struct net_device *dev,
+		       enum tsmac_mii_type_enum mii_type)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* conntype can ONLY be changed if the interface is NOT running */
+	if (netif_running(dev)) {
+		printk(KERN_WARNING
+		       "TSMAC %s: cannot change connection type "
+		       "while the interface is running\n", dev->name);
+		return -1;
+	}
+
+	lp->mii_type = mii_type;
+
+	return 0;
+}
+
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+/*
+ * Get the line loopback status
+ */
+int tsmac_get_loopback(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	u8 loopback;
+
+	/* get the loopback status from the device object */
+	loopback = lp->loopback_enable;
+
+	if (tsmac_copy_to_mem(iodata->data, &loopback,
+			      sizeof(loopback), context)) {
+		printk(KERN_WARNING "TSMAC %s: copy to user failed\n",
+		       dev->name);
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int tsmac_set_loopback(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	u8 loopback;
+
+	if (tsmac_copy_from_mem(&loopback, iodata->data, sizeof(u8), context)) {
+		printk(KERN_WARNING "TSMAC %s: copy from user failed\n",
+		       dev->name);
+		return -EFAULT;
+	}
+
+	/* write the loopback enable/disable status in device object */
+	lp->loopback_enable = loopback;
+	return 0;
+}
+#endif
+
+/*
+ * Set full duplex flow control parameters of PAUSE operations
+ */
+void tsmac_set_pause_param(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_flow_ctl *flow_ctl = &lp->flow_ctl;
+	u8 tmp[6];
+	u32 saved_addr, reg;
+
+	/* program ARC entry table with the destination address */
+	tsmac_set_arc_entry(dev, ARC_ENTRY_PAUSE_DST, flow_ctl->dest_addr);
+
+	/*
+	 * Program ARC entry table with the source address
+	 *
+	 * Note: Always link the source adress with the deivce MAC address
+	 */
+	memcpy(flow_ctl->src_addr, dev->dev_addr, sizeof(u8) * 6);
+	tsmac_set_arc_entry(dev, ARC_ENTRY_PAUSE_SRC, flow_ctl->src_addr);
+
+	/*
+	 * Program ARC entry table with MAC control type, PAUSE operation
+	 * opcode, and PAUSE duration
+	 */
+	/* set MAC control type */
+	tmp[0] = 0x88;
+	tmp[1] = 0x08;
+
+	/* set PAUSE opearation opcode */
+	tmp[2] = 0x00;
+	tmp[3] = 0x01;
+
+	/* set PAUSE duration */
+	tmp[4] = (flow_ctl->duration & 0xFF00) >> 8;
+	tmp[5] = flow_ctl->duration & 0x00FF;
+
+	tsmac_set_arc_entry(dev, ARC_ENTRY_PAUSE_CTL, tmp);
+
+	/* enable above ARC entries */
+	reg = tsmac_read(&lp->reg_map->mac.arc_ena) |
+	    ARC_Ena_Bit(ARC_ENTRY_PAUSE_DST) |
+	    ARC_Ena_Bit(ARC_ENTRY_PAUSE_SRC) | ARC_Ena_Bit(ARC_ENTRY_PAUSE_CTL);
+	tsmac_write(reg, &lp->reg_map->mac.arc_ena);
+
+	/* program the two bytes after ARC location #20 with 0x0000 */
+	saved_addr = tsmac_read(&lp->reg_map->mac.arc_addr);
+	tsmac_write(0x7C, &lp->reg_map->mac.arc_addr);
+	reg = tsmac_read(&lp->reg_map->mac.arc_data) & 0xFFFF0000;
+	tsmac_write(reg, &lp->reg_map->mac.arc_data);
+
+	/* program the locations MC#1 and MC#2 with 0x0000_0000 */
+	tsmac_write(0x80, &lp->reg_map->mac.arc_addr);
+	tsmac_write(0x00, &lp->reg_map->mac.arc_data);
+	tsmac_write(0x84, &lp->reg_map->mac.arc_addr);
+	tsmac_write(0x00, &lp->reg_map->mac.arc_data);
+	tsmac_write(saved_addr, &lp->reg_map->mac.arc_addr);
+
+	/* set XON/XOFF */
+	tsmac_write(flow_ctl->xoff, &lp->reg_map->mac.xoff_thresh);
+	tsmac_write(flow_ctl->xon, &lp->reg_map->mac.xon_thresh);
+
+	/* set compare value */
+	tsmac_write(flow_ctl->compare, &lp->reg_map->mac.rmt_pause_cmp);
+
+	/* enable/disable PAUSE generation */
+	reg = tsmac_read(&lp->reg_map->mac.tx_ctl) | flow_ctl->enable;
+	tsmac_write(TX_CFG(TX_CTL_DIS, flow_ctl->enable),
+		    &lp->reg_map->mac.tx_ctl);
+}
+
+/*
+ * Print Pause/ARC memory map
+ */
+int tsmac_print_map_pause_arc(struct tsmac_private *lp, char *buffer)
+{
+	u32 arc_off, arc_data;
+	int len = 0;
+
+	for (arc_off = 0x00; arc_off <= 0x84; arc_off += 0x4) {
+		tsmac_write(arc_off, &lp->reg_map->mac.arc_addr);
+		arc_data = tsmac_read(&lp->reg_map->mac.arc_data);
+		len += sprintf(buffer + len, "0x%x\t\t\t\t0x%08x\n",
+			       arc_off, arc_data);
+	}
+
+	return len;
+}
+
+/*
+ * Print classifier memory map
+ */
+int tsmac_print_map_classifier(struct tsmac_private *lp, char *buffer)
+{
+	u32 arc_off, arc_data;
+	u32 classifier_pos_off = 0x88;
+	int len = 0;
+	int msg_index = 0;
+	/* to select the messages from the messages array */
+	char *messages[] = { "L2 DA Rule 0",
+		"L2 DA Rule 1",
+		"L2 DA Rule 2",
+		"L2 DA Rule 3",
+		"L2 SA Rule 0",
+		"L2 SA Rule 1",
+		"L2 SA Rule 2",
+		"L2 SA Rule 3",
+		"L2 VQ Mapping",
+		"ETYPE Classification",
+		"VLAN VQ Mapping",
+		"IPv4 VQ Mapping Table",
+		"IPv6 VQ Mapping Table"
+	};
+
+	/*
+	 * Read all the four L2 rule configuration from classifier RAM; starts
+	 * at 0x88. add 0x04 to get the next entry
+	 */
+	for (arc_off = 0x88; arc_off <= 0xE4; arc_off += 0x4) {
+		tsmac_write(arc_off, &lp->reg_map->mac.arc_addr);
+		arc_data = tsmac_read(&lp->reg_map->mac.arc_data);
+		printk(KERN_INFO "arc_data = %x\n", arc_data);
+
+		if (arc_off == classifier_pos_off) {
+			/* add the message string in the output */
+			len += sprintf(buffer + len, "0x%x\t%s\t\t0x%08x\n",
+				       arc_off, messages[msg_index++],
+				       arc_data);
+			/* rules started at 0x88, 0x94, 0xA0 ... */
+			classifier_pos_off += 0xC;
+		} else
+			len += sprintf(buffer + len, "0x%x\t\t\t\t0x%08x\n",
+				       arc_off, arc_data);
+	}
+
+	/*
+	 * Read L2 VQ, ETYPE Classification, and VLAN VQ mapping from the
+	 * classifier RAM
+	 */
+	for (; arc_off <= 0xF0; arc_off += 0x4) {
+		tsmac_write(arc_off, &lp->reg_map->mac.arc_addr);
+		arc_data = tsmac_read(&lp->reg_map->mac.arc_data);
+		len += sprintf(buffer + len, "0x%x\t%-24s0x%08x\n", arc_off,
+			       messages[msg_index++], arc_data);
+	}
+
+	/* read ipv4, ipv6 VQ mapping table from the classifier RAM */
+	classifier_pos_off = arc_off;
+	for (; arc_off <= 0x130; arc_off += 0x4) {
+		tsmac_write(arc_off, &lp->reg_map->mac.arc_addr);
+		arc_data = tsmac_read(&lp->reg_map->mac.arc_data);
+
+		if (arc_off == classifier_pos_off) {
+			/* add the message string in the output */
+			len += sprintf(buffer + len, "0x%x\t%s\t0x%08x\n",
+				       arc_off, messages[msg_index++],
+				       arc_data);
+			classifier_pos_off += 0x20;
+		} else {
+			len += sprintf(buffer + len, "0x%x\t\t\t\t0x%08x\n",
+				       arc_off, arc_data);
+		}
+	}
+	return len;
+}
+
+int tsmac_get_default_vq_map(struct net_device *dev, struct ifreq *req,
+			     u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	u32 reg;
+	u8 default_vq;
+
+	/* by default, read from device */
+	reg = tsmac_read(&lp->reg_map->mac.vq_conf);
+	reg &= VQ_Def_Map_Mask;
+	reg >>= VQ_Def_Map_Shift;
+	default_vq = reg;
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	/* flood control is disabled */
+	if (lp->vqnflood.flood_enable == 0) {
+		/* read from software copy */
+		default_vq = lp->vqnflood.default_vq;
+	}
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	if (tsmac_copy_to_mem(iodata->data, &default_vq, sizeof(default_vq),
+			      context)) {
+		printk(KERN_WARNING "(tsmac_get_default_vq_map) copy touser "
+		       "failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int tsmac_set_default_vq_map(struct net_device *dev, struct ifreq *req,
+			     u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	u8 default_vq;
+	u32 reg;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(&default_vq, iodata->data, sizeof(default_vq),
+				context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	/* update software copy */
+	lp->vqnflood.default_vq = default_vq;
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	/* if flood control is disabled */
+	if (lp->vqnflood.flood_enable == 0)
+		return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	/* update device */
+	reg = (default_vq << VQ_Def_Map_Shift);
+	tsmac_write(reg, &lp->reg_map->mac.vq_conf);
+
+	return 0;
+}
+
+/*
+ * Read L2 class rule from the memory map
+ */
+void tsmac_get_l2_class_entry(struct net_device *dev, u32 entry_addr,
+			      unsigned char *data)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	unsigned long reg;
+	int i;
+
+	if (entry_addr & 2) {
+		/* read modify write */
+		tsmac_write(entry_addr, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data);
+		data[0] = (reg >> 8) & 0xFF;
+		data[1] = reg & 0xFF;
+
+		/* read whole word */
+		tsmac_write(entry_addr + 2, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data);
+		for (i = 0; i < 4; i++)
+			data[i + 2] = (reg >> (24 - i * 8)) & 0xFF;
+	} else {
+		/* read whole word */
+		tsmac_write(entry_addr, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data);
+		for (i = 0; i < 4; i++)
+			data[i] = (reg >> (24 - i * 8)) & 0xFF;
+
+		/* read modify write */
+		tsmac_write(entry_addr + 4, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data);
+		data[4] = (reg >> 24) & 0xFF;
+		data[5] = (reg >> 16) & 0xFF;
+	}
+}
+
+/*
+ * Write L2 class rule to the memory map in big endian order
+ */
+void tsmac_set_l2_class_entry(struct net_device *dev, u32 entry_addr,
+			      unsigned char *data)
+{
+	unsigned long reg;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	if (entry_addr & 2) {
+		/* read modify write */
+		tsmac_write(entry_addr, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data) & 0xffff0000;
+		reg |= data[0] << 8 | data[1];
+		tsmac_write(reg, &lp->reg_map->mac.arc_data);
+
+		/* write whole word */
+		tsmac_write(entry_addr + 2, &lp->reg_map->mac.arc_addr);
+		reg = (data[2] << 24) | (data[3] << 16) | (data[4] << 8) |
+		    data[5];
+		tsmac_write(reg, &lp->reg_map->mac.arc_data);
+	} else {
+		/* write whole word */
+		tsmac_write(entry_addr, &lp->reg_map->mac.arc_addr);
+		reg = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) |
+		    data[3];
+		tsmac_write(reg, &lp->reg_map->mac.arc_data);
+
+		/* read modify write */
+		tsmac_write(entry_addr + 4, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data) & 0x0000ffff;
+		reg |= data[4] << 24 | (data[5] << 16);
+		tsmac_write(reg, &lp->reg_map->mac.arc_data);
+	}
+}
+
+/*
+ * Get L2 classification rules
+ */
+int tsmac_get_addr_class_rule(struct net_device *dev, struct ifreq *req,
+			      u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_l2_class_rule l2_rule_array[4];
+	u32 reg;
+	int i;
+
+	/* by default, read from device */
+	for (i = 0; i < 4; i++) {
+		l2_rule_array[i].rule_num = i;
+
+		/* read Dest Addr/Mask and Src Addr/Mask */
+		tsmac_get_l2_class_entry(dev, (L2_DA_Rule0_offset +
+					       L2_Rule_Index * i),
+					 l2_rule_array[i].DA);
+		tsmac_get_l2_class_entry(dev,
+					 (L2_DA_Rule0_offset +
+					  L2_Rule_Index * i + 6),
+					 l2_rule_array[i].DM);
+		tsmac_get_l2_class_entry(dev,
+					 (L2_SA_Rule0_offset +
+					  L2_Rule_Index * i),
+					 l2_rule_array[i].SA);
+		tsmac_get_l2_class_entry(dev,
+					 (L2_SA_Rule0_offset +
+					  L2_Rule_Index * i + 6),
+					 l2_rule_array[i].SM);
+
+		/* read L2 VQ mapping */
+		tsmac_write(L2_VQ_Map_Offset, &lp->reg_map->mac.arc_addr);
+
+		reg = tsmac_read(&lp->reg_map->mac.arc_data);
+		l2_rule_array[i].vqnum = (reg >> (28 - 4 * i)) & 0x0F;
+
+		/* read enable bit */
+		reg = tsmac_read(&lp->reg_map->mac.l2_rule_ena);
+		l2_rule_array[i].enable = (reg >> i) & 0x1;
+	}
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		/* if flood control is disabled */
+		/* read from software copy */
+		memcpy(l2_rule_array, lp->vqnflood.l2_rule,
+		       4 * sizeof(struct tsmac_l2_class_rule));
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	if (tsmac_copy_to_mem(iodata->data, l2_rule_array,
+			      4 * sizeof(struct tsmac_l2_class_rule),
+			      context)) {
+		printk(KERN_WARNING "(tsmac_get_addr_class_rule) copy to user "
+		       "failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+/*
+ * Set L2 classification rules
+ */
+int tsmac_set_addr_class_rule(struct net_device *dev, struct ifreq *req,
+			      u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_l2_class_rule l2_rule;
+	u8 rnum;
+	u32 reg;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(&l2_rule, iodata->data,
+				sizeof(struct tsmac_l2_class_rule), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	rnum = l2_rule.rule_num;
+
+	if (!l2_rule.change_state_only) {
+		memcpy((void *)&lp->vqnflood.l2_rule[rnum], (void *)&l2_rule,
+		       sizeof(struct tsmac_l2_class_rule));
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+		if (lp->vqnflood.flood_enable == 0)
+			return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+		/* update device with Dest Addr/Mask and Src Addr/Mask */
+		tsmac_set_l2_class_entry(dev, (L2_DA_Rule0_offset +
+					       L2_Rule_Index * rnum),
+					 l2_rule.DA);
+		tsmac_set_l2_class_entry(dev,
+					 (L2_DA_Rule0_offset +
+					  L2_Rule_Index * rnum + 6),
+					 l2_rule.DM);
+		tsmac_set_l2_class_entry(dev,
+					 (L2_SA_Rule0_offset +
+					  L2_Rule_Index * rnum), l2_rule.SA);
+		tsmac_set_l2_class_entry(dev,
+					 (L2_SA_Rule0_offset +
+					  L2_Rule_Index * rnum + 6),
+					 l2_rule.SM);
+
+		tsmac_write(L2_VQ_Map_Offset, &lp->reg_map->mac.arc_addr);
+
+		/* update VQ number, in order vq0 vq1 vq2 vq3, size of nibble
+		 */
+		reg = tsmac_read(&lp->reg_map->mac.arc_data) & ~(L2_VQ_Map_Mask
+								 >> (rnum * 4));
+		reg |= l2_rule.vqnum << (28 - rnum * 4);
+		tsmac_write(reg, &lp->reg_map->mac.arc_data);
+
+		/* update enable bit */
+		reg = (tsmac_read(&lp->reg_map->mac.l2_rule_ena) &
+		       ~(0x1 << rnum));
+		reg |= l2_rule.enable << rnum;
+		tsmac_write(reg, &lp->reg_map->mac.l2_rule_ena);
+	} else {
+		lp->vqnflood.l2_rule[rnum].enable = l2_rule.enable;
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+		if (lp->vqnflood.flood_enable == 0)
+			return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+		/* update device */
+		reg = (tsmac_read(&lp->reg_map->mac.l2_rule_ena) &
+		       ~(0x1 << rnum));
+		reg |= l2_rule.enable << rnum;
+		tsmac_write(reg, &lp->reg_map->mac.l2_rule_ena);
+	}
+	return 0;
+}
+
+int tsmac_get_vlan_class_rule(struct net_device *dev, struct ifreq *req,
+			      u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_vlanvq_config vlan_vq;
+	u32 reg;
+	int i;
+
+	/* by default, read from device */
+	/* read VLAN TCI offset */
+	reg = tsmac_read(&lp->reg_map->mac.vlan_tci_offset);
+	reg &= VLAN_TCI_Offset_Mask;
+	vlan_vq.tci_offset = reg;
+
+	/* read VLAN VQ map */
+	tsmac_write(VLAN_VQ_Map_Offset, &lp->reg_map->mac.arc_addr);
+
+	reg = tsmac_read(&lp->reg_map->mac.arc_data);
+	for (i = 0; i < 4; i++) {
+		vlan_vq.vlanvq[i] = (reg >> (28 - (i * 8))) & 0xF;
+		vlan_vq.vlanvq[i] |= ((reg >> (28 - (i * 8) - 4)) & 0xF) << 4;
+	}
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		/* read from software copy */
+		memcpy((void *)&vlan_vq, (void *)&lp->vqnflood.vlanvq_config,
+		       sizeof(struct tsmac_vlanvq_config));
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	if (tsmac_copy_to_mem(iodata->data, &vlan_vq,
+			      sizeof(struct tsmac_vlanvq_config), context)) {
+		printk(KERN_WARNING "(tsmac_get_vlan_class_rule) copy to user"
+		       " failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int tsmac_set_vlan_class_rule(struct net_device *dev, struct ifreq *req,
+			      u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_vlanvq_config vlan_vq;
+	u32 reg;
+	u32 saved_addr;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(&vlan_vq, iodata->data,
+				sizeof(struct tsmac_vlanvq_config), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	/* update software copy */
+	memcpy((void *)&lp->vqnflood.vlanvq_config, (void *)&vlan_vq,
+	       sizeof(struct tsmac_vlanvq_config));
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	/* update device */
+	tsmac_write(vlan_vq.tci_offset, &lp->reg_map->mac.vlan_tci_offset);
+	saved_addr = tsmac_read(&lp->reg_map->mac.arc_addr);
+	tsmac_write(VLAN_VQ_Map_Offset, &lp->reg_map->mac.arc_addr);
+	reg = ((vlan_vq.vlanvq[0] & 0x0F) << 28) |
+	    ((vlan_vq.vlanvq[0] & 0xF0) << 20) |
+	    ((vlan_vq.vlanvq[1] & 0x0F) << 20) |
+	    ((vlan_vq.vlanvq[1] & 0xF0) << 12) |
+	    ((vlan_vq.vlanvq[2] & 0x0F) << 12) |
+	    ((vlan_vq.vlanvq[2] & 0xF0) << 4) |
+	    ((vlan_vq.vlanvq[3] & 0x0F) << 4) |
+	    ((vlan_vq.vlanvq[3] & 0xF0) >> 4);
+	tsmac_write(reg, &lp->reg_map->mac.arc_data);
+	tsmac_write(saved_addr, &lp->reg_map->mac.arc_addr);
+	return 0;
+}
+
+/*
+ * Get IPv4/IPv6 VQ values. 6-bit DSCP field implies 64 different mappings to
+ * virtual queue. These 64 fields are divided into 8 DSCP ranges, (0-7,
+ * 8-15,... 56-63). All VQs are retreived together
+ */
+int tsmac_get_ip_class_rule(struct net_device *dev, struct ifreq *req,
+			    u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_ipvq_config ip_rule_array[8];
+	u32 addr, reg, saved_addr;
+	int i, j;
+	unsigned short ipv4_flag;
+
+	/*
+	 * Get the version of the rule (ipv4/ipv6) from the first strcut
+	 * field
+	 */
+	if (tsmac_copy_from_mem(&ip_rule_array[0], iodata->data,
+				sizeof(struct tsmac_ipvq_config), context)) {
+		printk(KERN_WARNING "(tsmac_get_ip_class_rule) copy from user "
+		       "failed\n");
+		return -EFAULT;
+	}
+
+	ipv4_flag = ip_rule_array[0].ipv4;
+
+	/* by default, read from device */
+	/* IPv4 or IPv6 */
+	addr = (ipv4_flag) ? IPv4_VQ_Map_Offset : IPv6_VQ_Map_Offset;
+	saved_addr = tsmac_read(&lp->reg_map->mac.arc_addr);
+
+	for (i = 0; i < 8; i++) {
+		tsmac_write(addr, &lp->reg_map->mac.arc_addr);
+		reg = tsmac_read(&lp->reg_map->mac.arc_data);
+		for (j = 0; j < 4; j++) {
+			ip_rule_array[i].ip_vq[j] = (reg >> (28 - (j * 8)))
+			    & 0xF;
+			ip_rule_array[i].ip_vq[j] |= ((reg >> (28 - (j * 8)
+							       -
+							       4)) & 0xF) << 4;
+		}
+		addr += 4;
+	}
+
+	tsmac_write(saved_addr, &lp->reg_map->mac.arc_addr);
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		/* read from software copy */
+		memcpy((void *)ip_rule_array,
+		       (void *)((ipv4_flag) ? (&lp->vqnflood.ipv4_vq) :
+				(&lp->vqnflood.ipv6_vq)),
+		       8 * sizeof(struct tsmac_ipvq_config));
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	if (tsmac_copy_to_mem(iodata->data, ip_rule_array,
+			      8 * sizeof(struct tsmac_ipvq_config), context)) {
+		printk(KERN_WARNING "(tsmac_get_ip_class_rule) copy to user "
+		       "failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+/*
+ * Set IPv4/IPv6 VQ values. 6-bit DSCP field implies 64 different mappings to
+ * virtual queue. Eight VQs of a purticular DSCP range, are defined at a time
+ */
+int tsmac_set_ip_class_rule(struct net_device *dev, struct ifreq *req,
+			    u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_ipvq_config ip_rule;
+	u8 rnum;
+	u32 addr, val;
+	u32 saved_addr;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	/*
+	 * Get the version of the rule (ipv4/ipv6) from the first strcut
+	 * field
+	 */
+	if (tsmac_copy_from_mem(&ip_rule, iodata->data,
+				sizeof(struct tsmac_ipvq_config), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	/* convert dsp range into rule number */
+	rnum = ip_rule.dsp_range / 8;
+
+	/* update software copy */
+	memcpy((void *)((ip_rule.ipv4) ?
+			&(lp->vqnflood.ipv4_vq[rnum]) :
+			&(lp->vqnflood.ipv6_vq[rnum])),
+	       (void *)&ip_rule, sizeof(struct tsmac_ipvq_config));
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	/* update device */
+	addr = ((ip_rule.ipv4) ? IPv4_VQ_Map_Offset : IPv6_VQ_Map_Offset) +
+	    IP_VQ_Map_Index * rnum;
+	saved_addr = tsmac_read(&lp->reg_map->mac.arc_addr);
+	tsmac_write(addr, &lp->reg_map->mac.arc_addr);
+	val = ((ip_rule.ip_vq[0] & 0x0F) << 28) |
+	    ((ip_rule.ip_vq[0] & 0xF0) << 20) |
+	    ((ip_rule.ip_vq[1] & 0x0F) << 20) |
+	    ((ip_rule.ip_vq[1] & 0xF0) << 12) |
+	    ((ip_rule.ip_vq[2] & 0x0F) << 12) |
+	    ((ip_rule.ip_vq[2] & 0xF0) << 4) |
+	    ((ip_rule.ip_vq[3] & 0x0F) << 4) | ((ip_rule.ip_vq[3] & 0xF0) >> 4);
+	tsmac_write(val, &lp->reg_map->mac.arc_data);
+	tsmac_write(saved_addr, &lp->reg_map->mac.arc_addr);
+	return 0;
+}
+
+/*
+ * Get user-defined Ethernet type field, status (enabled/disabled) and VQ
+ * number
+ */
+int tsmac_get_ethtype_class_rule(struct net_device *dev,
+				 struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_ethtype_config evq;
+	u32 reg;
+	u32 saved_addr;
+
+	/* by default, read from device */
+	saved_addr = tsmac_read(&lp->reg_map->mac.arc_addr);
+	tsmac_write(Ethtype_VQ_Offset, &lp->reg_map->mac.arc_addr);
+
+	reg = tsmac_read(&lp->reg_map->mac.arc_data);
+	evq.ethtype_vq = (reg & 0xF0000000) >> 28;
+	evq.ethtype_enable = (reg & 0x08000000) >> 27;
+	evq.ethtype[1] = (reg & 0xFF);
+	evq.ethtype[0] = (reg & 0xFF00) >> 8;
+
+	tsmac_write(saved_addr, &lp->reg_map->mac.arc_addr);
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		/* read from software copy */
+		memcpy((void *)&evq, (void *)&lp->vqnflood.ethtype_config,
+		       sizeof(struct tsmac_ethtype_config));
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	if (tsmac_copy_to_mem(iodata->data, &evq,
+			      sizeof(struct tsmac_ethtype_config), context)) {
+		printk(KERN_WARNING "(tsmac_get_ethtype_class_rule) copy to "
+		       "user failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+/*
+ * Set user-defined Ethernet type field, status (enabled/disabled) and VQ
+ * number
+ */
+int tsmac_set_ethtype_class_rule(struct net_device *dev, struct ifreq *req,
+				 u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_ethtype_config evq;
+	u32 val;
+	u32 saved_addr;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(&evq, iodata->data,
+				sizeof(struct tsmac_ethtype_config), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	/* update device details */
+	memcpy((void *)&lp->vqnflood.ethtype_config, (void *)&evq,
+	       sizeof(struct tsmac_ethtype_config));
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	/* update device */
+	saved_addr = tsmac_read(&lp->reg_map->mac.arc_addr);
+	tsmac_write(Ethtype_VQ_Offset, &lp->reg_map->mac.arc_addr);
+	val = (evq.ethtype_vq << 28) | (evq.ethtype_enable << 27) |
+	    (evq.ethtype[0] << 8) | evq.ethtype[1];
+	tsmac_write(val, &lp->reg_map->mac.arc_data);
+	tsmac_write(saved_addr, &lp->reg_map->mac.arc_addr);
+	return 0;
+}
+
+int tsmac_get_vq_config(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_vq_config vq_config_array[VQ_MAX];
+	u32 reg;
+	int i;
+
+	/* by default, read from device */
+	for (i = 0; i < VQ_MAX; i++) {
+		vq_config_array[i].vq_num = i;
+
+		/* read size from software copy */
+		vq_config_array[i].vq_token_count =
+		    lp->vqnflood.vq_config[i].vq_token_count;
+
+		/* read drop disable bit */
+		reg = tsmac_read(&lp->reg_map->mac.vq_token_cnt[i]);
+		reg &= VQ_TC_Drop_Disable;
+		reg >>= VQ_TC_Drop_Disable_Shift;
+		vq_config_array[i].vq_drop_disable = reg;
+	}
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		memcpy((void *)vq_config_array, (void *)lp->vqnflood.vq_config,
+		       VQ_MAX * sizeof(struct tsmac_vq_config));
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	if (tsmac_copy_to_mem(iodata->data, vq_config_array,
+			      VQ_MAX * sizeof(struct tsmac_vq_config),
+			      context)) {
+		printk(KERN_WARNING "(tsmac_get_vq_config) copy to user "
+		       "failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int tsmac_set_vq_config(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_vq_config vq_conf;
+	u8 vqnum;
+	u32 data;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(&vq_conf, iodata->data,
+				sizeof(struct tsmac_vq_config), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	vqnum = vq_conf.vq_num;
+	memcpy((void *)&lp->vqnflood.vq_config[vqnum], (void *)&vq_conf,
+	       sizeof(struct tsmac_vq_config));
+
+#if defined(TSMAC_FLOOD_WORKAROUND)
+	if (lp->vqnflood.flood_enable == 0)
+		return 0;
+#endif				/* TSMAC_FLOOD_WORKAROUND */
+
+	/*
+	 * Load a new value to TOKEN_CNT by writing a new value to it with
+	 * WR_OP bit set to 1
+	 */
+	data = tsmac_read(&lp->reg_map->mac.vq_token_cnt[vqnum]) &
+	    ~VQ_TC_Token_Cnt_Mask;
+	data |= vq_conf.vq_token_count & VQ_TC_Token_Cnt_Mask;
+	tsmac_write(data | VQ_TC_Wr_Op, &lp->reg_map->mac.vq_token_cnt[vqnum]);
+
+	/* set drop disable state */
+	data = (tsmac_read(&lp->reg_map->mac.vq_token_cnt[vqnum]) &
+		~VQ_TC_Drop_Disable);
+	data &= ~VQ_TC_Token_Cnt_Mask;	/* to avoid increment token count */
+	data |= vq_conf.vq_drop_disable << VQ_TC_Drop_Disable_Shift;
+	tsmac_write(data, &lp->reg_map->mac.vq_token_cnt[vqnum]);
+
+	return 0;
+}
+
+int tsmac_get_drop_thresh(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_drop_threshold drop_level;
+	u32 reg;
+
+	/* read from device */
+	reg = tsmac_read(&lp->reg_map->mac.drop_on_thresh);
+	reg &= RX_DropOn_Mask;
+	drop_level.drop_on_thresh = reg;
+
+	reg = tsmac_read(&lp->reg_map->mac.drop_off_thresh);
+	reg &= RX_DropOff_Mask;
+	drop_level.drop_off_thresh = reg;
+
+	if (tsmac_copy_to_mem(iodata->data, &drop_level,
+			      sizeof(struct tsmac_drop_threshold), context)) {
+		printk(KERN_WARNING "(tsmac_get_drop_thresh) copy to user "
+		       "failed\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int tsmac_set_drop_thresh(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	struct tsmac_drop_threshold threshold;
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(&threshold, iodata->data,
+				sizeof(struct tsmac_drop_threshold), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	/* update software copy */
+	memcpy((void *)&lp->vqnflood.drop_threshold, (void *)&threshold,
+	       sizeof(struct tsmac_drop_threshold));
+
+	/* update device */
+	tsmac_write(threshold.drop_on_thresh, &lp->reg_map->mac.drop_on_thresh);
+	tsmac_write(threshold.drop_off_thresh,
+		    &lp->reg_map->mac.drop_off_thresh);
+	return 0;
+}
+
+/*
+ * Apply the stored Flood control and Full Duplex Flow Control parameters from
+ * the instance of the device data into the device registers
+ */
+int tsmac_set_vqnpause(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	u8 i;
+	int err = 0;
+
+	ifr.ifr_data = &iodata;
+
+	/* default_vq */
+	iodata.data = &lp->vqnflood.default_vq;
+	err = tsmac_set_default_vq_map(dev, &ifr, TSMAC_KERNEL_DATA);
+	if (err)
+		goto seterr;
+
+	/* L2 Rules */
+	for (i = 0; i < 4; i++) {
+		lp->vqnflood.l2_rule[i].change_state_only = 0;
+		iodata.data = &lp->vqnflood.l2_rule[i];
+		err = tsmac_set_addr_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+		if (err)
+			goto seterr;
+	}
+
+	/* VLAN priorities and tci_offset */
+	iodata.data = &lp->vqnflood.vlanvq_config;
+	err = tsmac_set_vlan_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+	if (err)
+		goto seterr;
+
+	/* 8 set IPv4/IPv6 VQs values */
+	for (i = 0; i < 8; i++) {
+		iodata.data = &lp->vqnflood.ipv4_vq[i];
+		err = tsmac_set_ip_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+		if (err)
+			goto seterr;
+
+		iodata.data = &lp->vqnflood.ipv6_vq[i];
+		err = tsmac_set_ip_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+		if (err)
+			goto seterr;
+	}
+
+	/* Ethertype */
+	iodata.data = &lp->vqnflood.ethtype_config;
+	err = tsmac_set_ethtype_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+	if (err)
+		goto seterr;
+
+	/* drop threshold values */
+	iodata.data = &lp->vqnflood.drop_threshold;
+	err = tsmac_set_drop_thresh(dev, &ifr, TSMAC_KERNEL_DATA);
+	if (err)
+		goto seterr;
+
+	/* Virtual Queue Configuration */
+	for (i = 0; i < 8; i++) {
+		iodata.data = &lp->vqnflood.vq_config[i];
+		err = tsmac_set_vq_config(dev, &ifr, TSMAC_KERNEL_DATA);
+		if (err)
+			goto seterr;
+	}
+
+	/* flood control */
+	err = set_floodctl_reg(dev);
+	if (err)
+		goto seterr;
+
+	return 0;
+ seterr:
+	return err;
+}
+
+int tsmac_get_egress_prio(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+
+	if (tsmac_copy_to_mem(iodata->data, lp->egress_prio,
+			      sizeof(lp->egress_prio), context)) {
+		printk(KERN_WARNING "(%s) copy to user failed\n", __func__);
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int tsmac_set_egress_prio(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *iodata = req->ifr_data;
+	enum tsmac_egress_prio egress_prio_new[2];
+
+	if (!capable(CAP_NET_ADMIN)) {
+		printk(KERN_ERR "(%s) Operation not permitted\n", __func__);
+		return -EPERM;
+	}
+
+	if (tsmac_copy_from_mem(egress_prio_new, iodata->data,
+				sizeof(egress_prio_new), context)) {
+		printk(KERN_ERR "(%s) copy from user failed\n", __func__);
+		return -EFAULT;
+	}
+
+	/*
+	 * The first number in the array is the skb->priority, and the second
+	 * number is the egress queue number.
+	 */
+	lp->egress_prio[egress_prio_new[0]] = egress_prio_new[1];
+
+	return 0;
+}
+
+/*
+ * Configure the device with default values of flood control and flow control
+ */
+void tsmac_config_def_vqnpause(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_flow_ctl *flow_ctl = &lp->flow_ctl;
+	struct tsmac_vqnflood_configure *vqnflood = &lp->vqnflood;
+	u8 i, j;
+
+	/* wipe out previous config */
+	memset(flow_ctl, 0, sizeof(lp->flow_ctl));
+	memset(vqnflood, 0, sizeof(lp->vqnflood));
+
+	/* disable pause generation by default */
+	flow_ctl->enable = 0;
+
+	/* copy device MAC addr to PAUSE generation source addr */
+	memcpy(flow_ctl->src_addr, dev->dev_addr, sizeof(u8) * 6);
+
+	/* flood control, enable by default */
+	vqnflood->flood_enable = 1;
+
+	/* default VQ */
+	vqnflood->default_vq = VQ_DEFAULT;
+
+	/* L2Rule[n].vqnum = 7, where n=0 to 3 */
+	for (i = 0; i < 4; i++) {
+		vqnflood->l2_rule[i].vqnum = VQ_DEFAULT;
+		vqnflood->l2_rule[i].rule_num = i;
+	}
+
+	/* VLAN priorities 0-7 map to default VQ, and tci_offset = 14 */
+	for (i = 0; i < 4; i++) {
+		vqnflood->vlanvq_config.vlanvq[i] = VQ_DEFAULT;
+		vqnflood->vlanvq_config.vlanvq[i] |= VQ_DEFAULT << 4;
+	}
+	vqnflood->vlanvq_config.tci_offset = 14;
+
+	/*
+	 * IPv4/IPv6 VQs are 8 * 8 sets, each set will have identical values in
+	 * the increasing order 0-7
+	 */
+	for (i = 0; i < 8; i++) {
+		vqnflood->ipv4_vq[i].dsp_range = i * 8;
+		vqnflood->ipv4_vq[i].ipv4 = 1;
+		vqnflood->ipv6_vq[i].dsp_range = i * 8;
+		vqnflood->ipv6_vq[i].ipv4 = 0;
+
+		for (j = 0; j < 4; j++) {
+			vqnflood->ipv4_vq[i].ip_vq[j] = VQ_DEFAULT;
+			vqnflood->ipv4_vq[i].ip_vq[j] |= VQ_DEFAULT << 4;
+			vqnflood->ipv6_vq[i].ip_vq[j] = VQ_DEFAULT;
+			vqnflood->ipv6_vq[i].ip_vq[j] |= VQ_DEFAULT << 4;
+		}
+	}
+
+	/* Default ETYPE classification to all-zero initially */
+
+	/* default drop threshold */
+	vqnflood->drop_threshold.drop_on_thresh = 6144;
+	vqnflood->drop_threshold.drop_off_thresh = 2048;
+
+	/* VQ configuration */
+	for (i = 0; i < 8; i++)
+		vqnflood->vq_config[i].vq_num = i;
+
+	/*
+	 * Due to the VQ token count HW bug, only 2 VQ can be used, with VQ
+	 * 0 set to low-priority and VQ 1 set to high-priority and disable
+	 * drop
+	 */
+
+	/* Note: assuming default VQ is VQ 0 */
+	vqnflood->vq_config[VQ_DEFAULT].vq_drop_disable = 0;
+	vqnflood->vq_config[VQ_DEFAULT].vq_token_count = 64;
+
+	vqnflood->vq_config[1].vq_drop_disable = 1;
+}
+
+/*
+ * Collect HW stats data from the TSMAC status registers and updates stats
+ * structure of the device object.
+ *
+ * Note:
+ *
+ * This function needs to be called periodically (worst case is data running
+ * at Gigabit line rate a 32-bit HW bytes counter can overflow in ~34
+ * seconds) to prevent counter overflow
+ */
+void tsmac_update_hw_stats(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	int n = 0;
+
+	/*
+	 * Since this routine may be called by various sources, we need to
+	 * lock it
+	 */
+	spin_lock_bh(&lp->control_lock);
+	spin_lock(&lp->stats_lock);
+
+	/*
+	 * Set SNAP bit to take the snapshot of statistics maintained by
+	 * the MAC. The MAC clears this bit to 0 upon transferring
+	 * contents of the hardware statistics counters to the software
+	 * readable statistics registers. After that counters reset to 0.
+	 */
+	tsmac_write(tsmac_read(&lp->reg_map->mac.mac_ctl) | MAC_Snap,
+		    &lp->reg_map->mac.mac_ctl);
+
+	/* flush to make sure SNAP bit write go into the TSMAC subsystem */
+	tsmac_cpu_to_tsmac_flush(lp->unit);
+
+	/*
+	 * The time the HW takes to clear the SNAP bit depends on the link
+	 * speed: 31.25 ns, 140 ns, 860 ns for 1000 Mbps, 100 Mbps, 10 Mbps,
+	 * respectively. The following while loop times out in 3 us, which is
+	 * good for all link speeds
+	 */
+	while ((tsmac_read(&lp->reg_map->mac.mac_ctl) & MAC_Snap) && n <= 10)
+		++n;
+
+	if (n > 10) {
+		/* 081205: Do not print warnings when connType is GPON, since
+		 * the link will not be established until GPON device is
+		 * initialized. */
+		if (lp->conn_type != MSP_CT_GPON)
+			printk(KERN_DEBUG
+			       "TSMAC%d: Unable to update stats counters\n",
+			       lp->unit);
+		goto update_hw_stats_done;
+	}
+
+	lp->hw_stats.tx_packets +=
+	    tsmac_read(&lp->reg_map->mac.tx_good_frame_stat);
+
+	lp->hw_stats.tx_bytes +=
+	    tsmac_read(&lp->reg_map->mac.tx_good_byte_stat);
+
+	lp->hw_stats.rx_packets +=
+	    tsmac_read(&lp->reg_map->mac.rx_total_frame_stat);
+
+	lp->hw_stats.rx_bytes +=
+	    tsmac_read(&lp->reg_map->mac.rx_total_byte_stat);
+
+	lp->lx_stats.rx_over_errors +=
+	    tsmac_read(&lp->reg_map->mac.rx_over_frame_stat);
+
+	lp->hw_stats.rx_dropped_bytes +=
+	    tsmac_read(&lp->reg_map->mac.rx_dropped_byte_stat);
+
+	lp->hw_stats.rx_vq_drops[0] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[0]);
+	lp->hw_stats.rx_vq_drops[1] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[1]);
+	lp->hw_stats.rx_vq_drops[2] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[2]);
+	lp->hw_stats.rx_vq_drops[3] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[3]);
+	lp->hw_stats.rx_vq_drops[4] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[4]);
+	lp->hw_stats.rx_vq_drops[5] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[5]);
+	lp->hw_stats.rx_vq_drops[6] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[6]);
+	lp->hw_stats.rx_vq_drops[7] +=
+	    tsmac_read(&lp->reg_map->mac.vq_dropped_stat[7]);
+
+ update_hw_stats_done:
+
+	spin_unlock(&lp->stats_lock);
+	spin_unlock_bh(&lp->control_lock);
+}
+
+#ifdef CONFIG_PMC_MSP7150_GW_MOCA
+int
+tsmac_moca_reset(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	int reset = req->ifr_ifru.ifru_ivalue;
+	int gpio;
+
+	switch (lp->unit) {
+	case 1:
+		gpio = TSMAC_RESET_GPIO_MACB;
+		break;
+
+	case 2:
+		gpio = TSMAC_RESET_GPIO_MACC;
+		break;
+
+	default:
+		printk(KERN_ERR "TSMAC%d: Invalid MoCA device\n"
+								, lp->unit);
+		return -EINVAL;
+	}
+
+	if (reset)
+		gpio_direction_output(gpio, 0);
+	else
+		gpio_direction_output(gpio, 1);
+
+	return 0;
+}
+
+#else
+int
+tsmac_moca_reset(struct net_device *dev, struct ifreq *req, u8 context)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	int reset = req->ifr_ifru.ifru_ivalue;
+	/* reset not supported on this platform */
+	printk(KERN_WARNING "TSMAC%d: Faking MoCA reset to %d\n"
+						, lp->unit, reset);
+	return 0;
+}
+#endif
+
+void tsmac_enable_mac_c(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 mac_c_out_reg;
+
+	if (lp->unit != TSMAC_C)
+		return;
+
+	mac_c_out_reg = tsmac_read((void *)TSMAC_MAC_C_OUTPUT_CTRL);
+	mac_c_out_reg |= MAC_C_EN1;
+	mac_c_out_reg &= ~MAC_C_EN2B;
+	mac_c_out_reg |= MAC_C_EN3;
+	mac_c_out_reg |= MAC_C_EN4;
+
+	tsmac_write(mac_c_out_reg, (void *)TSMAC_MAC_C_OUTPUT_CTRL);
+}
+
+/**
+ * tsmac_adjust_link() - callback function for PAL to adjust mac link status
+ * @dev: mac interface whose link status is to be adjusted
+ *
+ * Callback function for PAL layer to notify TSMAC regarding PHY's state
+ * change, so TSMAC can sync up its link state to PHY's.
+ */
+void tsmac_adjust_link(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct phy_device *phydev = lp->phyptr;
+	unsigned long flags;
+	int status_change = 0;
+	int mac_restart = 0;
+
+	spin_lock_irqsave(&lp->control_lock, flags);
+
+	if (phydev->link) {
+		if (lp->speed != phydev->speed) {
+			lp->speed = phydev->speed;
+			status_change = 1;
+			mac_restart = 1;
+		}
+
+		if (lp->duplex != phydev->duplex) {
+			lp->duplex = phydev->duplex;
+			status_change = 1;
+			mac_restart = 1;
+		}
+
+		if (!lp->link) {
+			netif_tx_schedule_all(dev);
+			lp->link = phydev->link;
+			status_change = 1;
+		}
+	} else if (lp->link) {
+		lp->link = phydev->link;
+		status_change = 1;
+	}
+
+	if (status_change) {
+		printk(KERN_INFO "TSMAC%d: ", lp->unit);
+		phy_print_status(phydev);
+
+		if (mac_restart) {
+			tsmac_shutdown(dev);
+			if (schedule_delayed_work_on
+			    (atomic_read(&lp->timer_task_cpu),
+			     &lp->restart_task, 0))
+				atomic_inc(&lp->restart_pending_cnt);
+		}
+	}
+
+	spin_unlock_irqrestore(&lp->control_lock, flags);
+}
diff --git a/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.h b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.h
new file mode 100644
index 0000000..a889c9d
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac.h
@@ -0,0 +1,105 @@
+/******************************************************************************
+** Copyright 2006 - 2011 PMC-Sierra, Inc
+**
+** PMC-SIERRA DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER
+** RESULTING FROM THE USE OF THIS SOFTWARE
+**
+** FILE NAME: pmcmsp_tsmac.h
+**
+** DESCRIPTION: Linux 2.6 driver public header for TSMAC.
+**
+** This program is free software; you can redistribute  it and/or modify it
+** under  the terms of  the GNU General  Public License as published by the
+** Free Software Foundation;
+******************************************************************************/
+
+#ifndef _PMCMSP_TSMAC_H_
+#define _PMCMSP_TSMAC_H_
+
+#include <linux/phy.h>
+
+#define MSP_TSMAC_ID	"pmc_tsmac"
+
+/* TX/RX descriptor ring size */
+/* TODO: increase RX_RING_SIZE to inccrease RX queue depth */
+#define RX_RING_SIZE_DEF          256
+#define TX_RING_SIZE_DEF          32
+
+#define MAX_RING_SIZE             512
+#define MIN_RING_SIZE             16
+
+/* TX polling timer */
+#define TXPOLLCNT_CH0		  0
+#define TXPOLLCNT_CH1		  0
+
+/* packet header offset, for checksum calculation */
+#define IPHDR_OFFSET_IPV4_VLAN    18
+#define IPHDR_OFFSET_IPV4_NVLAN   14
+#define IPHDR_OFFSET_IPV6_VLAN    20
+#define IPHDR_OFFSET_IPV6_NVLAN   16
+
+/* IOCTL commands */
+#define TSMACIOCTL_COUNT                        12
+#define TSMACIOCTL				SIOCDEVPRIVATE
+#define PMC_ETH_IOCMD_CLASSDEFVQ_READ		(TSMACIOCTL + 2)
+#define PMC_ETH_IOCMD_CLASSDEFVQ_WRITE		(TSMACIOCTL + 2)
+#define PMC_ETH_IOCMD_CLASSADDR_READ		(TSMACIOCTL + 3)
+#define PMC_ETH_IOCMD_CLASSADDR_WRITE		(TSMACIOCTL + 3)
+#define PMC_ETH_IOCMD_CLASSVLAN_READ		(TSMACIOCTL + 4)
+#define PMC_ETH_IOCMD_CLASSVLAN_WRITE		(TSMACIOCTL + 4)
+#define PMC_ETH_IOCMD_CLASS4DSCP_READ		(TSMACIOCTL + 5)
+#define PMC_ETH_IOCMD_CLASS4DSCP_WRITE		(TSMACIOCTL + 5)
+#define PMC_ETH_IOCMD_CLASS6DSCP_READ		(TSMACIOCTL + 6)
+#define PMC_ETH_IOCMD_CLASS6DSCP_WRITE		(TSMACIOCTL + 6)
+#define PMC_ETH_IOCMD_CLASSETHTYPE_READ		(TSMACIOCTL + 7)
+#define PMC_ETH_IOCMD_CLASSETHTYPE_WRITE	(TSMACIOCTL + 7)
+#define PMC_ETH_IOCMD_PROVFIFO_READ		(TSMACIOCTL + 8)
+#define PMC_ETH_IOCMD_PROVFIFO_WRITE		(TSMACIOCTL + 8)
+#define PMC_ETH_IOCMD_HWPAUSE_READ		(TSMACIOCTL + 9)
+#define PMC_ETH_IOCMD_HWPAUSE_WRITE		(TSMACIOCTL + 9)
+#define PMC_ETH_IOCMD_PROVVQ_READ		(TSMACIOCTL + 10)
+#define PMC_ETH_IOCMD_PROVVQ_WRITE		(TSMACIOCTL + 10)
+#define PMC_ETH_IOCMD_TXPRIOTHRES_READ		(TSMACIOCTL + 11)
+#define PMC_ETH_IOCMD_TXPRIOTHRE_WRITE		(TSMACIOCTL + 11)
+#define PMC_ETH_IOCMD_QOSDEFAULT_WRITE		(TSMACIOCTL + 12)
+#define PMC_ETH_IOCMD_LINELOOP_READ		(TSMACIOCTL + 13)
+#define PMC_ETH_IOCMD_LINELOOP_WRITE		(TSMACIOCTL + 13)
+
+/**
+ * enum tsmac_conntype_enum - connection type of the MAC interface
+ * @MSP_CT_UNSED: the port is not used
+ * @MSP_CT_ETHYPHY: the port is connected to a sigle PHY
+ * @MSP_CT_ETHNOPHY: the port is connected to non-ethernet PHY.
+ * @MSP_CT_ETHSWITCH: the port is connected to a switch
+ * @MSP_CT_MOCA: the port is used for MoCA
+ * @MSP_CT_GPON: the port is used for GPON
+ * @MSP_CT_MAX: this indicates total number of members in this enum
+ */
+enum msp_conntype_enum {
+	MSP_CT_UNUSED = 0,
+	MSP_CT_ETHPHY,
+	MSP_CT_ETHSWITCH,
+	MSP_CT_ETHNOPHY,
+	MSP_CT_MOCA,
+	MSP_CT_GPON,
+	MSP_CT_MAX
+};
+
+
+/**
+ * struct eth_platform_data - static MAC and PHY setup of the platform
+ * @phy_addr: address of the PHY on the MDIO bus (@bus_unit)
+ * @bus_unit: the actual MDIO bus that the PHY at @phy_addr is on
+ * @conn_type: default connection type of the MAC interface
+ *
+ * This structure contains the platform specific data of PHY's connection, i.e.
+ * that address of the PHY and the actual MDIO bus it is connected to.  As
+ * well, this struct contains the connection type of the MAC interface.
+ */
+struct eth_platform_data {
+	int phy_addr;
+	int bus_unit;
+	enum msp_conntype_enum conn_type;
+};
+
+#endif				/* _PMCMSP_TSMAC_H_ */
diff --git a/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_local.h b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_local.h
new file mode 100644
index 0000000..5437029
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_local.h
@@ -0,0 +1,924 @@
+/******************************************************************************
+** Copyright 2006 - 2011 PMC-Sierra, Inc
+**
+** PMC-SIERRA DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER
+** RESULTING FROM THE USE OF THIS SOFTWARE
+**
+** FILE NAME: pmcmsp_tsmac_local.h
+**
+** DESCRIPTION: Linux 2.6 driver local header for  TSMAC.
+**
+** This program is free software; you can redistribute  it and/or modify it
+** under  the terms of  the GNU General  Public License as published by the
+** Free Software Foundation
+******************************************************************************/
+
+#ifndef _PMCMSP_TSMAC_LOCAL_H_
+#define _PMCMSP_TSMAC_LOCAL_H_
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/ioport.h>
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/ptrace.h>
+#include <linux/mii.h>
+#include <linux/in.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/dma-mapping.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/delay.h>
+#include <linux/bitops.h>
+#include <linux/io.h>
+#include <asm/system.h>
+#include <asm/dma.h>
+#include <asm/byteorder.h>
+#include <asm/bootinfo.h>
+#include <asm/cpu-features.h>
+/*Platform headers*/
+#include <msp_int.h>
+#include <msp_regs.h>
+
+#include "pmcmsp_tsmac.h"
+
+/*
+ * Workaround, Flood Control must always be enabled
+ * (PEP 33290, PM71_69_25_A/APOLLO_EMU)
+ *
+ * Driver simulates Flood Control disable by configuring
+ * it so packets are never dropped
+ */
+#define TSMAC_FLOOD_WORKAROUND
+
+#define TSMAC_MAX_UNITS		3
+#define TSMAC_NUM_TX_CH		2
+
+/* default CPU for running non-datapath background/timer tasks */
+#define TSMAC_TASK_CPU_DEFAULT	0
+
+/* number of skb->priority values we support (starting from 0) */
+#define TSMAC_NUM_SKB_PRIORITY	8
+
+/* low priority egress queue pause enable flag */
+#define TSMAC_EGRESS_LO_PRIO_PAUSE	1
+
+/* low priority egress queue full */
+#define TSMAC_EGRESS_LO_PRIO_FULL	2
+
+/* For debugging */
+#define TSMAC_ATTR_INLINE     __attribute__ ((__always_inline__))
+
+#define TSMAC_SUCCESS        (0)
+#define TSMAC_ERROR          (1)
+#define TSMAC_ERROR_BASE     (9000)
+#define TSMAC_Q_INIT_ERROR   (TSMAC_ERROR_BASE + 1)
+#define TSMAC_Q_FREE_ERROR   (TSMAC_ERROR_BASE + 2)
+#define TSMAC_NO_PHY         (TSMAC_ERROR_BASE + 3)
+#define TSMAC_PHY_INIT_ERROR (TSMAC_ERROR_BASE + 4)
+
+/* Tuning parameters */
+#define TX_TIMEOUT         (5)	/* TX timeout (seconds) */
+#define STATS_CHK_TIME     (20)	/* time (sec) to check stats */
+
+#define TSMAC_KERNEL_DATA  0
+#define TSMAC_USER_DATA    1
+
+/* clock config for different link speeds */
+#define TSMAC_RMII_TX_CLK_IN  0
+#define TSMAC_RMII_REF_CLK_IN 1
+#define TSMAC_SYS_CLK_SLOW    0
+#define TSMAC_SYS_CLK_FAST    1
+
+/* TX/RX descriptor */
+#define FD_DMA_Own           (REG_BIT31)
+#define FD_SOP               (REG_BIT30)
+#define FD_EOP               (REG_BIT29)
+#define FD_TxInt_En          (REG_BIT28)
+#define FD_TxCRC_Dis         (REG_BIT27)
+#define FD_TxPad_Dis         (REG_BIT26)
+#define FD_RxTrunc           (REG_BIT12)
+#define FD_RxBuff_Mask       (0x1FFFFFFC)
+#define FD_TxBuff_Mask       (0x1FFFFFFF)
+#define FD_Next_Mask         (0xFFFFFFF0)
+#define FD_RxChksum_Mask     (0x1FFFE000)
+#define FD_RxChksum_Shift    (13)
+#define FD_TxBuffLn_Mask     (0x00000FFF)
+#define FD_RxBuffLn_Mask     (0x00000FFF)
+
+/* QoS, L2 classification */
+#define VQ_DEFAULT           0
+#define VQ_MAX		     2
+#define L2_ARC_Class_Min     (0x88)
+#define L2_ARC_Class_Max     (0x130)
+#define L2_DA_Rule0_offset   (0x88)
+#define L2_SA_Rule0_offset   (0xB8)
+#define L2_Rule_Index        (12)
+#define L2_Mask_Index        (6)
+#define L2_VQ_Map_Offset     (232)
+#define L2_VQ_Map_Mask       (0xF0000000)
+#define Ethtype_VQ_Offset    (236)
+#define VLAN_VQ_Map_Offset   (240)
+#define IPv4_VQ_Map_Offset   (244)
+#define IPv6_VQ_Map_Offset   (276)
+#define IP_VQ_Map_Index      (4)
+
+/* PAUSE frame */
+#define Pause_Control_Offset   (120)
+#define Pause_MAC_Control_Type (0x8808)
+#define Pause_Operation_Opcode (0x0001)
+
+/* ARC entry */
+/* max number of ARC entries */
+#define ARC_ENTRY_MAX             21
+/* ARC entry for destination address of PAUSE frame (transmit) */
+#define ARC_ENTRY_PAUSE_DST       0
+/* ARC entry for source address of PAUSE frame (transmit) */
+#define ARC_ENTRY_PAUSE_SRC       1
+/* ARC entry for device MAC address */
+#define ARC_ENTRY_MAC             2
+/* ARC entry for special multicast address of PAUSE frame (receive) */
+#define ARC_ENTRY_PAUSE_RX        3
+/* ARC entry for MAC control type, PAUSE frame opcode, and operand value */
+#define ARC_ENTRY_PAUSE_CTL       20
+
+/* bit assignments */
+#define REG_BIT0             0x00000001
+#define REG_BIT1             0x00000002
+#define REG_BIT2             0x00000004
+#define REG_BIT3             0x00000008
+#define REG_BIT4             0x00000010
+#define REG_BIT5             0x00000020
+#define REG_BIT6             0x00000040
+#define REG_BIT7             0x00000080
+#define REG_BIT8             0x00000100
+#define REG_BIT9             0x00000200
+#define REG_BIT10            0x00000400
+#define REG_BIT11            0x00000800
+#define REG_BIT12            0x00001000
+#define REG_BIT13            0x00002000
+#define REG_BIT14            0x00004000
+#define REG_BIT15            0x00008000
+#define REG_BIT16            0x00010000
+#define REG_BIT17            0x00020000
+#define REG_BIT18            0x00040000
+#define REG_BIT19            0x00080000
+#define REG_BIT20            0x00100000
+#define REG_BIT21            0x00200000
+#define REG_BIT22            0x00400000
+#define REG_BIT23            0x00800000
+#define REG_BIT24            0x01000000
+#define REG_BIT25            0x02000000
+#define REG_BIT26            0x04000000
+#define REG_BIT27            0x08000000
+#define REG_BIT28            0x10000000
+#define REG_BIT29            0x20000000
+#define REG_BIT30            0x40000000
+#define REG_BIT31            0x80000000
+
+/* TSMAC reset bit */
+#define TSMAC_EA_RST          0x00000040
+#define TSMAC_EB_RST          0x00000080
+#define TSMAC_EC_RST          0x00000004
+
+#ifdef CONFIG_PMC_MSP7150_GW_MOCA
+/* GPIO for MAC C ethernet/moca MUX */
+#define MACC_MUX_GPIO         10
+/* GPIOs for MoCA reset */
+#define TSMAC_RESET_GPIO_MACB 21
+#define TSMAC_RESET_GPIO_MACC 23
+#endif
+
+/* control output register */
+#define TSMAC_CTRL_OUTPUT     0xBC0003DC
+#define SYS_LinkSpeed_Shift   (1)
+#define	SYS_Mode_Shift        (3)
+#define SYS_RMII_Clk_Shift    (6)
+#define SYS_Sclk_Sel_Shift    (7)
+#define	SYS_MACA_Shift        (16)
+#define SYS_MACB_Shift        (8)
+#define SYS_MACC_Shift        (0)
+
+/* MAC C output control register (defunct DSL output control register) */
+#define TSMAC_MAC_C_OUTPUT_CTRL 0xBC0003E0
+#define MAC_C_EN1	(REG_BIT4)	/* set to 1 to enable MAC C */
+#define MAC_C_EN2B	(REG_BIT3)	/* set to 0 to enable MAC C */
+#define MAC_C_EN3	(REG_BIT2)	/* set to 1 to enable MAC C */
+#define MAC_C_EN4	(REG_BIT0)	/* set to 1 to enable MAC C */
+
+/* DMA registers */
+struct msp_dma_regs {
+	u32 dma_ctl;		/* 0x00 */
+#define DMA_TxDisable_CH1         (REG_BIT5)
+#define DMA_TxDisable_CH0         (REG_BIT4)
+#define DMA_RxAlign_Mask          (0x0000000C)
+#define DMA_RxAlign_Shift         (2)
+#define DMA_IntMask               (REG_BIT1)
+#define DMA_SWIntReq              (REG_BIT0)
+
+	u32 dma_init;		/* 0x04 */
+#define DMA_RxInit_DescList       (REG_BIT3)
+#define DMA_TxInit_DescList       (REG_BIT2)
+#define DMA_TxWakeUp_CH1          (REG_BIT1)
+#define DMA_TxWakeUp_CH0          (1)
+
+	u32 txdesc_ch0;		/* 0x08 */
+	u32 txdesc_ch1;		/* 0x0C */
+#define DMA_TxDesc_AddrMask       (0X1FFFFFF0)
+#define DMA_TxDesc_AddrShift      (4)
+
+	u32 reserved0;		/* 0x10 */
+	u32 txpollcnt_ch0;	/* 0x14 */
+	u32 txpollcnt_ch1;	/* 0x18 */
+#define DMA_TxPCTR_Mask           (0X00003FFF)
+
+	u32 rxdesc;		/* 0x1C */
+#define DMA_RxDesc_AddrMask       (0X1FFFFFF0)
+#define DMA_RxDesc_AddrShift      (4)
+
+	u32 iphdr_offset;	/* 0x20 */
+#define DMA_OffsetVLAN_Mask       (0X0000FF00)
+#define DMA_OffsetVLAN_Shift      (8)
+#define DMA_OffsetNonVLAN_Mask    (0X000000FF)
+
+	u32 int_ena;		/* 0x24 */
+#define IntEn_BadAddrRd           (REG_BIT9)
+#define IntEn_BadAddrWr           (REG_BIT8)
+#define IntEn_RxDescEx            (REG_BIT4)
+#define IntEn_SysBusErr           (REG_BIT3)
+
+	u32 int_src;		/* 0x28 */
+#define IntSrc_BadAddrRd          (REG_BIT9)
+#define IntSrc_BadAddrWr          (REG_BIT8)
+#define IntSrc_MAC                (REG_BIT7)
+#define IntSrc_GPMII              (REG_BIT6)
+#define IntSrc_SwInt              (REG_BIT5)
+#define IntSrc_RxDescEx           (REG_BIT4)
+#define IntSrc_SysBusErr          (REG_BIT3)
+#define IntSrc_MACRx              (REG_BIT2)
+#define IntSrc_MACTx_CH1          (REG_BIT1)
+#define IntSrc_MACTx_CH0          (REG_BIT0)
+
+	u32 reserved1;		/* 0x2C */
+	u32 bad_addr_rd_err;	/* 0x30 */
+#define BadAddrRd_Mask            (0X1FFFFFFF)
+
+	u32 bad_addr_wr_err;	/* 0x34 */
+#define BadAddrWr_Mask            (0X1FFFFFFF)
+};
+
+/* MAC registers */
+struct msp_mac_regs {
+	u32 pause_cnt;		/* 0x8000 */
+#define PAUSE_COUNT_Mask          (0X0000FFFF)
+
+	u32 rmt_pause_cnt;	/* 0x8004 */
+#define REMPAU_COUNT_Mask         (0X0000FFFF)
+
+	u32 tx_ctl_frame_stat;	/* 0x8008 */
+#define TXSTAT_VALUE_Mask         (0X003FFFFF)
+
+	u32 mac_ctl;		/* 0x800C */
+#define MAC_StatRoll              (REG_BIT31)
+#define MAC_TxPauRoll             (REG_BIT30)
+#define MAC_RxPauRoll             (REG_BIT29)
+#define MAC_Snap                  (REG_BIT17)
+#define MAC_EnStatRoll            (REG_BIT16)
+#define MAC_HaltImm               (REG_BIT1)
+#define MAC_HaltReq               (1)
+
+	u32 arc_ctl;		/* 0x8010 */
+#define ARC_CompEn                (REG_BIT4)
+#define ARC_NegARC                (REG_BIT3)
+#define ARC_BroadAcc              (REG_BIT2)
+#define ARC_GroupAcc              (REG_BIT1)
+#define ARC_StationAcc            (1)
+
+	u32 tx_ctl;		/* 0x8014 */
+#define Tx_HwPAUSE_En             (REG_BIT15)
+#define Tx_EnComp                 (REG_BIT14)
+#define Tx_EnLateColl             (REG_BIT12)
+#define Tx_EnExColl               (REG_BIT11)
+#define Tx_EnLCarr                (REG_BIT10)
+#define Tx_EnExDefer              (REG_BIT9)
+#define Tx_MII_10                 (REG_BIT7)
+#define Tx_SdPAUSE                (REG_BIT6)
+#define Tx_NoExDef                (REG_BIT5)
+#define Tx_FBack                  (REG_BIT4)
+#define Tx_NoCRC                  (REG_BIT3)
+#define Tx_Halt                   (REG_BIT1)
+#define Tx_En                     (1)
+
+	u32 tx_stat;		/*0x8018 */
+#define Tx_PAUSE                  (REG_BIT21)
+#define Tx_MACB                   (REG_BIT20)
+#define Tx_VLAN                   (REG_BIT19)
+#define Tx_BCast                  (REG_BIT18)
+#define Tx_MCast                  (REG_BIT17)
+#define Tx_SQErr                  (REG_BIT16)
+#define Tx_Halted                 (REG_BIT15)
+#define Tx_Comp                   (REG_BIT14)
+#define Tx_Good                   (REG_BIT13)
+#define Tx_LateColl               (REG_BIT12)
+#define Tx_LCarr                  (REG_BIT10)
+#define Tx_ExDefer                (REG_BIT9)
+#define Tx_IntTx                  (REG_BIT7)
+#define Tx_Paused                 (REG_BIT6)
+#define Tx_TxDefer                (REG_BIT5)
+#define Tx_ExColl                 (REG_BIT4)
+#define Tx_TxColl_Mask            (0X0000000F)
+
+	u32 rx_ctl;		/* 0x801C */
+#define Rx_EnGood                 (REG_BIT20)
+#define Rx_EnLenErr               (REG_BIT19)
+#define Rx_EnLongErr              (REG_BIT18)
+#define Rx_EnOver                 (REG_BIT17)
+#define Rx_EnCRCErr               (REG_BIT16)
+#define Rx_EnAlign                (REG_BIT15)
+#define Rx_IgnorePause_Frm        (REG_BIT10)
+#define Rx_FloodEn                (REG_BIT9)
+#define Rx_FloodEn_Shift          (9)
+#define Rx_IgnoreCRC              (REG_BIT7)
+#define Rx_PassPAUSE              (REG_BIT6)
+#define Rx_PassCtl                (REG_BIT5)
+#define Rx_Halt                   (REG_BIT1)
+#define Rx_En                     (1)
+
+	u32 rx_stat;		/* 0x8020 */
+#define Rx_Good                   (REG_BIT31)
+#define Rx_ARCEnt_Mask            (0x1F000000)
+#define Rx_ARCEnt_Shift           (25)
+#define Rx_ARCStat_Mask           (0x00F00000)
+#define Rx_ARCStat_Shift          (21)
+#define Rx_RxPAUSE                (REG_BIT20)
+#define Rx_RxVLAN                 (REG_BIT19)
+#define Rx_BCast                  (REG_BIT18)
+#define Rx_MCast                  (REG_BIT17)
+#define Rx_Halted                 (REG_BIT15)
+#define Rx_LongErr                (REG_BIT11)
+#define Rx_OverFlow               (REG_BIT10)
+#define Rx_CRCErr                 (REG_BIT9)
+#define Rx_AlignErr               (REG_BIT8)
+#define Rx_IntRx                  (REG_BIT6)
+#define Rx_CTLRecd                (REG_BIT5)
+#define Rx_LenErr                 (REG_BIT4)
+#define Rx_VQ_Mask                (0x0000000F)
+
+	u32 md_data;		/* 0x8024 */
+#define MD_Data_Mask              (0x0000ffff)
+
+	u32 md_ca;		/* 0x8028 */
+#define MD_CA_PreSup              (REG_BIT12)
+#define MD_CA_Busy                (REG_BIT11)
+#define MD_CA_Wr                  (REG_BIT10)
+#define MD_CA_PHY_Mask            (0x000003E0)
+#define MD_CA_PHY_Shift           (5)
+#define MD_CA_PHYReg_Mask         (0x0000001F)
+
+	u32 arc_addr;		/* 0x802C */
+#define ARC_MemLoc_Mask           (0x000001FC)
+#define ARC_MemLoc_Shift          (2)
+
+	u32 arc_data;		/* 0x8030 */
+#define ARC_Data0_Mask            (0xFF000000)
+#define ARC_Data0_Shift           (24)
+#define ARC_Data1_Mask            (0x00FF0000)
+#define ARC_Data1_Shift           (16)
+#define ARC_Data2_Mask            (0x0000FF00)
+#define ARC_Data2_Shift           (8)
+#define ARC_Data3_Mask            (0x000000FF)
+#define ARC_Data3_Shift           (0)
+
+	u32 arc_ena;		/* 0x8034 */
+#define ARC_Ena_Mask              ((1 << ARC_ENTRY_MAX)-1)
+#define ARC_Ena_Bit(index)        (1<<(index))
+
+	u32 max_length;		/* 0x8038 */
+	u32 xoff_thresh;	/* 0x803C */
+	u32 xon_thresh;		/* 0x8040 */
+	u32 rmt_pause_cmp;	/* 0x8044 */
+	u32 drop_on_thresh;	/* 0x8048 */
+#define RX_DROPON_MAX             (8188)
+#define RX_DropOn_Mask            (0x0000FFFF)
+	u32 drop_off_thresh;	/* 0x804C */
+#define RX_DROPOFF_MAX            (8188)
+#define RX_DropOff_Mask           (0x0000FFFF)
+	u32 vq_conf;		/* 0x8050 */
+#define VQ_Drop_Disable           (REG_BIT30)
+#define VQ_Wr_Op                  (REG_BIT31)
+#define VQ_Def_Map_Mask           (0xF0000000)
+#define VQ_Def_Map_Shift          (28)
+
+	u32 l2_rule_ena;	/* 0x8054 */
+	u32 vlan_tci_offset;	/* 0x8058 */
+#define VLAN_TCI_Offset_Mask      (0x0000003F)
+	u32 reserved[9];	/* 0x805C */
+	u32 vq_token_cnt[8];	/* 0x8080 */
+#define VQ_TC_Wr_Op               (REG_BIT31)
+#define VQ_TC_Drop_Disable        (REG_BIT30)
+#define VQ_TC_Drop_Disable_Shift  (30)
+#define	VQ_TC_Token_Cnt_Mask      (0xFFFF)
+#define	VQ_TC_Token_Cnt_Shift     (0)
+
+	u32 reserved1[24];	/* 0x8084 */
+	u32 tx_good_frame_stat;	/* 0x8100 */
+	u32 tx_good_byte_stat;	/* 0x8104 */
+	u32 rx_good_frame_stat;	/* 0x8108 */
+	u32 rx_good_byte_stat;	/* 0x810C */
+	u32 rx_total_frame_stat;	/* 0x8110 */
+	u32 rx_total_byte_stat;	/* 0x8114 */
+	u32 rx_over_frame_stat;	/* 0x8118 */
+	u32 rx_over_byte_stat;	/* 0x811C */
+	u32 pause_frame_stat;	/* 0x8120 */
+	u32 rx_dropped_byte_stat;	/* 0x8124 */
+	u32 vq_dropped_stat[8];	/* 0x8128 */
+};
+
+/* GPMII registers */
+struct msp_gpmii_regs {
+	u32 int_stat;
+	u32 int_ena;
+	u32 int_val;
+#define GPMII_RCLKMON_MASK        (0x00000003)
+
+	u32 conf_general;
+#define GPMII_Force_Crs_Col_En    (REG_BIT15)
+#define GPMII_Felbk               (REG_BIT8)
+#define GPMII_TxDataPath_En       (REG_BIT1)
+#define GPMII_RxDataPath_En       (REG_BIT0)
+
+	u32 conf_mode;
+#define GPMII_Dplx_Sel            (REG_BIT12)
+#define GPMII_Dplx_Shift          (12)
+#define GPMII_LinkSpeed_Mask      (0x00000300)
+#define GPMII_LinkSpeed_Shift     (8)
+#define GPMII_Mode_Mask           (0x00000007)
+
+	u32 conf_rx_override;
+	u32 conf_tx_override;
+	u32 diag_stat;
+};
+
+/* DMA RX packet offset */
+#define DMA_CTL_CMD	(IP_HDR_ALIGN << DMA_RxAlign_Shift)
+/* TX control, enable TX completion interrupts */
+#define TX_CTL_ENA	(Tx_EnComp | Tx_EnLateColl | Tx_EnExColl | \
+			Tx_EnLCarr | Tx_EnExDefer | Tx_En)
+
+/* TX control, disable TX completion interrupts */
+#define TX_CTL_DIS	(Tx_EnLateColl | Tx_EnExColl | Tx_EnLCarr | \
+			Tx_EnExDefer | Tx_En)
+
+/* enable/disable pause frame generation */
+#define TX_CFG(cmd, pause_enable) (pause_enable ? (cmd | Tx_HwPAUSE_En) : \
+				(cmd & ~Tx_HwPAUSE_En))
+
+/* RX control, enable RX interrupts */
+#define RX_CTL_ENA	(Rx_EnGood | Rx_EnLenErr | Rx_EnLongErr | Rx_EnOver | \
+			Rx_EnCRCErr | Rx_EnAlign | Rx_PassPAUSE | \
+			Rx_PassCtl | Rx_FloodEn | Rx_En)
+
+/* RX, control, disable RX interrupts */
+#define RX_CTL_DIS	(Rx_PassPAUSE | Rx_PassCtl | Rx_FloodEn | Rx_En)
+
+/* enbale bus error and RX exhausted interrupts */
+#define INT_EN_CMD      (IntEn_RxDescEx | IntEn_SysBusErr | IntEn_BadAddrRd | \
+			IntEn_BadAddrWr)
+
+/* TSMAC register structures */
+struct msp_regs {
+	struct msp_dma_regs dma;
+	struct msp_mac_regs __attribute__ ((aligned(0x8000))) mac;
+	struct msp_gpmii_regs __attribute__ ((aligned(0x10000))) gpmii;
+};
+
+/* egress queue priorities */
+enum tsmac_egress_prio {
+	TSMAC_DESC_PRI_HI = 0,
+	TSMAC_DESC_PRI_LO
+};
+
+extern const char *msp_conntype_str[MSP_CT_MAX];
+
+/* MII types */
+enum tsmac_mii_type_enum {
+	TSMAC_MT_MII,
+	TSMAC_MT_GMII,
+	TSMAC_MT_RMII,
+	TSMAC_MT_MAX
+};
+extern const char *tsmac_mii_type_str[TSMAC_MT_MAX];
+
+#define TSMAC_A   0
+#define TSMAC_B   1
+#define TSMAC_C   2
+
+/* VQ configuration */
+struct tsmac_vq_config {
+	/* number of packets mapped to a VQ */
+	unsigned short vq_token_count;
+
+	/* to disable packet drop on a VQ */
+	unsigned char vq_drop_disable;
+
+	/* VQ number (0 to 7) */
+	unsigned char vq_num;
+};
+
+/* RX packets threshold configuration */
+struct tsmac_drop_threshold {
+	/* FIFO threshold to start dropping low-priority packets */
+	unsigned short drop_off_thresh;
+
+	/* FIFO threshold to stop dropping */
+	unsigned short drop_on_thresh;
+};
+
+/* L2 classification rules */
+struct tsmac_l2_class_rule {
+	/* rule number 0-3 */
+	unsigned char rule_num;
+
+	/* status of the rule */
+	unsigned char enable;
+
+	/* matching VQ */
+	unsigned char vqnum;
+
+	/* Destination Address */
+	unsigned char DA[6];
+
+	/* Destination Address Mask */
+	unsigned char DM[6];
+
+	/* Source Address */
+	unsigned char SA[6];
+
+	/* Source Address Mask */
+	unsigned char SM[6];
+
+	/*
+	 * enable/disable can be edited without changing MAC,
+	 * 1 = change the status of the rule only, 0 = set the entire rule
+	 */
+	unsigned char change_state_only;
+};
+
+/* full duplex flow control using PAUSE frames */
+struct tsmac_flow_ctl {
+	u32 enable;
+
+	/* XOFF - PAUSE frame triggering level when RX FIFO >= XOFF */
+	unsigned short xoff;
+
+	/* XON - PAUSE frame triggering level when RX FIFO <= XON */
+	unsigned short xon;
+
+	/* compare against the XOFF */
+	unsigned short compare;
+
+	/* source address for PAUSE operations */
+	unsigned char src_addr[6];
+
+	/* destination address for PAUSE operations */
+	unsigned char dest_addr[6];
+
+	/* duration of pause */
+	unsigned short duration;
+};
+
+/* VLAN VQ configuration*/
+struct tsmac_vlanvq_config {
+	/* VQ mapping for 8 VLAN user priority levels each of size a nibble */
+	unsigned char vlanvq[4];
+
+	/* Byte offset of the VLAN TCI field from start of received packet */
+	unsigned char tci_offset;
+};
+
+/* configurable Ethernet type values*/
+struct tsmac_ethtype_config {
+	/* configurable Ethernet type value */
+	unsigned char ethtype[2];
+
+	/* status of the Ethernet type rule */
+	unsigned char ethtype_enable;
+
+	/* VQ (0-7) number for Ethernet type rule */
+	unsigned char ethtype_vq;
+};
+
+/* IPv4/IPv6 DSCP-VQ map configuration */
+struct tsmac_ipvq_config {
+	/* IPv4/IPv6 virtual queue mapping table */
+	unsigned char ip_vq[4];
+
+	/* 1 = IPv4 rule, 0 = IPv6 rule */
+	unsigned short ipv4;
+
+	/* DSCP range (0-7, 8-15,... 56-63) */
+	unsigned short dsp_range;
+};
+
+/* flood control */
+struct tsmac_vqnflood_configure {
+	u8 flood_enable;
+	u8 default_vq;
+
+	/* virtual queue configuration */
+	struct tsmac_vq_config vq_config[8];
+
+	/* RX packets drop threshold */
+	struct tsmac_drop_threshold drop_threshold;
+
+	/* L2 classification rules, Rule 0 - Rule 3 */
+	struct tsmac_l2_class_rule l2_rule[4];
+
+	/* VLAN VQ configuration */
+	struct tsmac_vlanvq_config vlanvq_config;
+
+	/* Ethernet type */
+	struct tsmac_ethtype_config ethtype_config;
+
+	/* IPv4/IPv6 DSCP classification of 64 mappings to VQ */
+	struct tsmac_ipvq_config ipv4_vq[8];
+	struct tsmac_ipvq_config ipv6_vq[8];
+};
+
+/* IP header offset configuration */
+struct tsmac_iphdroffset_configure {
+	unsigned char vlan;
+	unsigned char nvlan;
+};
+
+/*
+ * Structure to define DMA data buffers. Must be aligned to a 16-byte boundary
+ * to meet alignment restrictions for the Q_Desc
+ */
+#define __tsmac_desc_align __attribute__((aligned(16)))
+
+/* TX/RX descriptor structure, shared between CPU and DMA */
+struct Q_Desc {
+	u32 FDNext;	/* next descriptor */
+	u32 FDBuffPtr;	/* data buffer pointer */
+	u32 FDCtl;	/* descriptor control */
+	u32 FDStat;	/* descriptor status */
+} __tsmac_desc_align;
+
+/* TX descriptor ring and management field */
+struct tsmac_tx {
+	void *desc_base;	/* TX descriptors base address */
+	void *skb_base;		/* TX skb pointers base address */
+	unsigned int size;	/* TX descriptor ring size */
+	unsigned int head;	/* TX queues head index */
+	unsigned int tail;	/* TX queues tail index */
+	u32 qcnt;		/* used TX descriptor count */
+	struct Q_Desc *desc_p;	/* pointer to the descriptor array */
+	struct sk_buff **skb_pp;	/* pointer to the skb pointer array */
+};
+
+/* RX descriptor ring and management field */
+struct tsmac_rx {
+	void *desc_base;	/* RX descriptors base address */
+	void *skb_base;		/* RX skb pointers base address */
+	unsigned int size;	/* RX descriptor ring size */
+	unsigned int index;	/* current RX descriptor index */
+	struct Q_Desc *desc_p;	/* pointer to the descriptor array */
+	struct sk_buff **skb_pp;	/* pointer to the skb pointer array */
+};
+
+/*
+ * Counter statistics maintained in software, normally we use net_device_stats
+ * in Linux. This structure defines addtional stats supported in TSMAC
+ */
+struct tsmac_stats_sw {
+	u64 rx_bytes;		/* received bytes */
+	u32 rx_ints;		/* RX interrupts */
+	u32 rx_vq_frames[8];	/* received packets in each VQ */
+
+	u32 rx_long_errors;	/* packet exceeds supported length */
+	u32 rx_trunc_errors;	/* packet was truncated */
+
+	u64 tx_bytes;		/* transmitted bytes */
+	u32 tx_ints;		/* TX interrupts */
+	u32 tx_full[TSMAC_NUM_TX_CH];	/* TX queue is full */
+
+#ifdef CONFIG_TSMAC_TEST_CMDS
+	u32 rx_nochksum_vlan;	/* VLAN packets with wrong L4 checksum */
+	u32 rx_nochksum_nonvlan;	/* non-VLAN packets with
+					 * wrong L4 chksum
+					 */
+#endif
+};
+
+/*
+ * RX VQ token counter
+ */
+struct tsmac_rx_vq_token {
+	u32 pkt_cnt;		/* number of packets received in a VQ */
+#ifdef CONFIG_TSMAC_VQ_TOKEN_CNT_WORKAROUND
+	u32 update_cnt;		/* number of updates performed on a VQ */
+#endif
+};
+
+/* counter statistics maintained in hardware */
+struct tsmac_stats_hw {
+	u32 rx_packets;		/* received packets */
+	u64 rx_bytes;		/* received bytes */
+	u64 rx_dropped_bytes;	/* dropped bytes on the RX side */
+	u32 rx_vq_drops[8];	/* VQ where RX packets are dropped */
+
+	u32 tx_packets;		/* transmitted packets */
+	u64 tx_bytes;		/* transmitted bytes */
+};
+
+/* hook function prototype declaration */
+typedef int (*tsmac_hook_function) (struct sk_buff **skb,
+				    struct net_device *dev, void *priv);
+
+/* private information each interface */
+struct tsmac_private {
+	u8 unit;		/* logical unit number */
+	u8 loopback_enable;	/* line loopback status */
+	enum msp_conntype_enum conn_type;	/* eth, switch, etc. */
+	enum tsmac_mii_type_enum mii_type;	/* MII/RMII/GMII */
+
+	/* MAC link status */
+	int link;
+	int speed;
+	int duplex;
+
+	/* phy configuration */
+	u32 bus_unit;
+	u32 phy_addr;
+
+	struct phy_device *phyptr;
+	struct mii_bus bus;
+
+	/* ioremapped register access cookie */
+	struct msp_regs __iomem *reg_map;
+
+	/* stats counter timer */
+	struct timer_list stats_timer;
+
+	/* lock for stats access */
+	spinlock_t stats_lock;
+
+	/* lock for control access */
+	spinlock_t control_lock;
+
+	/* statistics */
+	struct net_device_stats lx_stats;	/* Linux standard stats */
+	struct tsmac_stats_sw sw_stats;	/* additional software stats */
+	struct tsmac_stats_hw hw_stats;	/* hardware stats */
+
+	/* work queue for the restart task */
+	struct delayed_work restart_task;
+
+	/* TX/RX descriptor rings */
+	struct tsmac_tx tx[TSMAC_NUM_TX_CH];
+	struct tsmac_rx rx;
+
+	/* lock for TX */
+	spinlock_t tx_lock;
+
+	/* locks for the restart task */
+	spinlock_t restart_lock;
+	atomic_t restart_pending_cnt;
+	atomic_t close_flag;
+
+	/* device object pointer */
+	struct device *dev;
+	struct net_device *ndev;
+	struct napi_struct napi;
+
+	/* full duplex flow control using PAUSE frames */
+	struct tsmac_flow_ctl flow_ctl;
+
+	/* VQ and Flood control parameters */
+	struct tsmac_vqnflood_configure vqnflood;
+
+	/* IP header offset configuration parameters */
+	struct tsmac_iphdroffset_configure iphdr_offset;
+
+	/* TX packet skb->priority to dual egress queue priority mapping */
+	enum tsmac_egress_prio egress_prio[TSMAC_NUM_SKB_PRIORITY];
+
+	struct tsmac_rx_vq_token vq_token[8];
+
+	/* CPU on which the timer tasks should run on */
+	atomic_t timer_task_cpu;
+
+	/* Hook points to allow 3rd party functions to hook in and manipulate
+	 * packets
+	 */
+	tsmac_hook_function tsmac_rx_hook;
+	tsmac_hook_function tsmac_tx_hook;
+
+	/* private datas to be used freely by the hook functions. */
+	void *rx_priv, *tx_priv;
+};
+
+/* TSMAC specific data for Set/Get commands */
+struct tsmac_io_data {
+	/* Set/Get command (1 = get-command, 0 = set-command) */
+	unsigned long subcmd;
+
+	/* command specific data */
+	void *data;
+};
+
+/* TSMAC driver information */
+extern const char version[];
+extern const char cardname[];
+extern const char drv_version[];
+extern const char drv_reldate[];
+extern const char drv_file[];
+
+extern struct ethtool_ops tsmac_ethtool_ops;
+
+extern u32 tsmac_read(void *addr);
+extern void tsmac_write(u32 val, void *addr);
+extern void tsmac_adjust_link(struct net_device *dev);
+extern void tsmac_register_bus(struct mii_bus *bus, int mac_unit);
+extern struct phy_device *tsmac_mii_probe(struct net_device *dev,
+					  void (*adjust_link) (struct net_device
+							       *));
+extern int tsmac_copy_to_mem(void *dst, void *src, u32 n, u8 context);
+extern int tsmac_copy_from_mem(void *dst, void *src, u32 n, u8 context);
+extern void tsmac_set_arc_entry(struct net_device *dev, int index,
+				unsigned char *addr);
+extern int tsmac_set_mac_addr(struct net_device *dev, void *addr);
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+extern int tsmac_get_loopback(struct net_device *dev, struct ifreq *req,
+			      u8 context);
+extern int tsmac_set_loopback(struct net_device *dev, struct ifreq *req,
+			      u8 context);
+#endif
+extern void tsmac_set_pause_param(struct net_device *dev);
+extern int tsmac_print_map_pause_arc(struct tsmac_private *lp, char *buffer);
+extern int tsmac_print_map_classifier(struct tsmac_private *lp, char *buffer);
+extern int tsmac_get_default_vq_map(struct net_device *dev, struct ifreq *req,
+				    u8 context);
+extern int tsmac_set_default_vq_map(struct net_device *dev, struct ifreq *req,
+				    u8 context);
+extern void tsmac_get_l2_class_entry(struct net_device *dev, u32 entry_addr,
+				     unsigned char *data);
+extern void tsmac_set_l2_class_entry(struct net_device *dev, u32 entry_addr,
+				     unsigned char *data);
+extern int tsmac_get_addr_class_rule(struct net_device *dev, struct ifreq *req,
+				     u8 context);
+extern int tsmac_set_addr_class_rule(struct net_device *dev, struct ifreq *req,
+				     u8 context);
+extern int tsmac_get_vlan_class_rule(struct net_device *dev, struct ifreq *req,
+				     u8 context);
+extern int tsmac_set_vlan_class_rule(struct net_device *dev, struct ifreq *req,
+				     u8 context);
+extern int tsmac_get_ip_class_rule(struct net_device *dev, struct ifreq *req,
+				   u8 context);
+extern int tsmac_set_ip_class_rule(struct net_device *dev, struct ifreq *req,
+				   u8 context);
+extern int tsmac_get_ethtype_class_rule(struct net_device *dev,
+					struct ifreq *req, u8 context);
+extern int tsmac_set_ethtype_class_rule(struct net_device *dev,
+					struct ifreq *req, u8 context);
+extern int tsmac_get_vq_config(struct net_device *dev, struct ifreq *req,
+			       u8 context);
+extern int tsmac_set_vq_config(struct net_device *dev, struct ifreq *req,
+			       u8 context);
+extern int tsmac_get_drop_thresh(struct net_device *dev, struct ifreq *req,
+				 u8 context);
+extern int tsmac_set_drop_thresh(struct net_device *dev, struct ifreq *req,
+				 u8 context);
+extern int tsmac_set_vqnpause(struct net_device *dev);
+extern int tsmac_get_egress_prio(struct net_device *dev, struct ifreq *req,
+				 u8 context);
+extern int tsmac_set_egress_prio(struct net_device *dev, struct ifreq *req,
+				 u8 context);
+extern void tsmac_config_def_vqnpause(struct net_device *dev);
+extern void tsmac_update_hw_stats(struct net_device *dev);
+extern int tsmac_moca_reset(struct net_device *dev, struct ifreq *req,
+			    u8 context);
+
+extern int tsmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
+extern void tsmac_create_proc_entries(struct net_device *dev);
+extern void tsmac_remove_proc_entries(void);
+extern int tsmac_set_phyaddr(struct net_device *dev, int phyunit, int phyaddr);
+extern int tsmac_set_conntype(struct net_device *dev,
+			      enum msp_conntype_enum conn_type);
+extern int tsmac_set_mii_type(struct net_device *dev,
+			      enum tsmac_mii_type_enum mii_type);
+extern void tsmac_enable_mac_c(struct net_device *dev);
+#endif				/* _PMCMSP_TSMAC_LOCAL_H_ */
diff --git a/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_mdiobus.c b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_mdiobus.c
new file mode 100644
index 0000000..b954448
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_mdiobus.c
@@ -0,0 +1,205 @@
+/**
+ * Copyright 2006 - 2011 PMC-Sierra, Inc
+ * @file /drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_mdiobus.c
+ *
+ * MDIO bus interface for msp71xx/msp82xx TSMAC driver.  It
+ * provides the mean to access TSMAC's station management registers.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License.
+ *
+ */
+
+#include "pmcmsp_tsmac_local.h"
+
+#define PHY_MII_DATA		(0x00)
+#define PHY_MII_CTRL		(0x04)
+#define TSMAC_MDIOBUS_TIMEOUT	100
+
+/**
+ * tsmac_mdiobus_wait() - busy wait till MDIO bus is free
+ * @bus: pointer to the MDIO bus that is being accessed
+ */
+static int tsmac_mdiobus_wait(struct mii_bus *bus)
+{
+	struct net_device *dev = bus->priv;
+	struct tsmac_private *lp = netdev_priv(dev);
+	void __iomem *memaddr = &lp->reg_map->mac.md_data;
+	int timeout = TSMAC_MDIOBUS_TIMEOUT;
+
+	while (tsmac_read(memaddr + PHY_MII_CTRL) & MD_CA_Busy) {
+		udelay(50);
+		if (--timeout == 0)
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+/**
+ * tsmac_mdiobus_read() - read data from PHY via MDIO bus
+ * @bus: pointer to the MDIO bus that is used to access the PHY
+ * @phyaddr: PHY address of the PHY that is being read
+ * @phy_reg: PHY register of the PHY that is being read
+ *
+ * This function read the data of the @phy_reg of the PHY at @phyaddr.
+ */
+
+static int tsmac_mdiobus_read(struct mii_bus *bus, int phyaddr, int phy_reg)
+{
+	struct net_device *dev = bus->priv;
+	struct tsmac_private *lp = netdev_priv(dev);
+	void __iomem *memaddr = &lp->reg_map->mac.md_data;
+	u16 data;
+	int err;
+
+	err = tsmac_mdiobus_wait(bus);
+	if (err < 0)
+		return err;
+
+	tsmac_write(MD_CA_Busy | (phyaddr << MD_CA_PHY_Shift) | phy_reg,
+		    memaddr + PHY_MII_CTRL);
+
+	err = tsmac_mdiobus_wait(bus);
+	if (err < 0) {
+		printk(KERN_ERR "%s: mdio_read busy timeout!!\n", dev->name);
+		return err;
+	}
+
+	data = tsmac_read(memaddr + PHY_MII_DATA);
+	return data;
+}
+
+/**
+ * tsmac_mdiobus_write() - write data to PHY via MDIO bus
+ * @bus: pointer to the MDIO bus that is used to access the PHY
+ * @phyaddr: PHY address of the PHY that is being written
+ * @phy_reg: PHY register of the PHY that is being written
+ * @data: the value to be written to the PHY
+ *
+ * This function writes @data to the @phy_reg of the PHY at @phyaddr.
+ */
+static int tsmac_mdiobus_write(struct mii_bus *bus, int phyaddr, int phy_reg,
+			       u16 data)
+{
+	struct net_device *dev = bus->priv;
+	struct tsmac_private *lp = netdev_priv(dev);
+	void __iomem *memaddr = &lp->reg_map->mac.md_data;
+	int err;
+
+	err = tsmac_mdiobus_wait(bus);
+	if (err < 0)
+		return err;
+
+	tsmac_write(data, memaddr + PHY_MII_DATA);
+	tsmac_write(MD_CA_Busy | MD_CA_Wr | (phyaddr << MD_CA_PHY_Shift) |
+		    phy_reg, memaddr + PHY_MII_CTRL);
+
+	err = tsmac_mdiobus_wait(bus);
+	if (err < 0) {
+		printk(KERN_ERR "%s: mdio_write busy timeout!!\n", dev->name);
+		return err;
+	}
+
+	return 0;
+}
+
+/**
+ * tsmac_mdiobus_reset() - dummy reset function for the TSMAC MDIO bus
+ * @bus: pointer to the MDIO bus that is to be reseted.
+ *
+ * TSMAC MDIO bus requires no action for reset; hence, return 0 immediately.
+ */
+static int tsmac_mdiobus_reset(struct mii_bus *bus)
+{
+	return 0;
+}
+
+/**
+ * tsmac_register_bus() - initialize the MDIO bus struct
+ * @dev: pointer to the net device whose MDIO bus struct is being initialized
+ * @mac_unit: the TSMAC unit that the bus is connected to
+ */
+void tsmac_register_bus(struct mii_bus *bus, int mac_unit)
+{
+	int i;
+	char mdiobus_id[25];
+
+	/* set up mii_bus struct */
+	bus->read = tsmac_mdiobus_read;
+	bus->write = tsmac_mdiobus_write;
+	bus->reset = tsmac_mdiobus_reset;
+	bus->state = MDIOBUS_ALLOCATED;
+	snprintf(mdiobus_id, 25, "TSMAC%d MDIO bus", mac_unit);
+	bus->name = mdiobus_id;
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", mac_unit);
+	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		bus->irq[i] = PHY_POLL;
+
+	/* bring up all PHYs connected to this MDIO bus */
+	mdiobus_register(bus);
+}
+
+/**
+ * tsmac_mii_probe() - find and attach an available PHY to the MAC
+ * @dev: pointer to the net device that is to be attached with a PHY
+ * @adjust_link: callback funciont provided to PAL to sync up MAC link status
+ *		 to the PHY link status.
+ *
+ * Search for an available PHY, either statically or dynamically, on the given
+ * MDIO bus and then attach it to the MAC interface.  Both PHY's supported &
+ * advertising features are initialized to match MAC's supported features.
+ */
+struct phy_device *tsmac_mii_probe(struct net_device *dev,
+				   void (*adjust_link) (struct net_device *))
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct phy_device *phydev = NULL;
+	int phy_addr;
+	char bus_id[MII_BUS_ID_SIZE];
+	char bus_unit[4];
+	char unit[4];
+
+	if (lp->dev->platform_data) {
+		/* static PHY setup is provided */
+		sprintf(bus_unit, "%x", lp->bus_unit);
+		snprintf(bus_id, MII_BUS_ID_SIZE, PHY_ID_FMT, bus_unit,
+			 lp->phy_addr);
+	} else {
+		/* scan for the first available PHY to attach */
+		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+			if (lp->bus.phy_map[phy_addr]) {
+				sprintf(unit, "%x", lp->unit);
+				snprintf(bus_id, MII_BUS_ID_SIZE, PHY_ID_FMT,
+					 unit, phy_addr);
+				break;
+			}
+		}
+	}
+
+	phydev = phy_connect(dev, bus_id, adjust_link, 0,
+			     PHY_INTERFACE_MODE_GMII);
+
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return NULL;
+	}
+
+	/* 1000/Half is not supported by TSMAC */
+	phydev->supported &= (SUPPORTED_10baseT_Half
+			      | SUPPORTED_10baseT_Full
+			      | SUPPORTED_100baseT_Half
+			      | SUPPORTED_100baseT_Full
+			      | SUPPORTED_1000baseT_Full
+			      | SUPPORTED_Autoneg
+			      | SUPPORTED_MII | SUPPORTED_TP);
+
+	phydev->advertising = phydev->supported;
+
+	printk(KERN_INFO "TSMAC%d: attached PHY driver [%s] "
+	       "(mii_bus:phy_addr)\n", lp->unit,
+	       phydev->drv->name);
+
+	return phydev;
+}
diff --git a/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_user.c b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_user.c
new file mode 100644
index 0000000..aa294f0
--- /dev/null
+++ b/drivers/net/pmcmsp_tsmac/pmcmsp_tsmac_user.c
@@ -0,0 +1,2687 @@
+/******************************************************************************
+** Copyright 2006 - 2007 PMC-Sierra, Inc
+**
+** PMC-SIERRA DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY DAMAGES WHATSOEVER
+** RESULTING FROM THE USE OF THIS SOFTWARE
+**
+** FILE NAME: pmcmsp_tsmac_user.c
+**
+** DESCRIPTION: Linux 2.6 driver for TSMAC.
+**
+** This program is free software; you can redistribute  it and/or modify it
+** under  the terms of  the GNU General  Public License as published by the
+** Free Software Foundation;
+**
+******************************************************************************/
+
+#include "pmcmsp_tsmac.h"
+#include "pmcmsp_tsmac_local.h"
+
+/*
+ * Proc file config and name string
+ */
+/* config */
+#define KERN_BUF_MAX_SIZE        256
+#define TSMAC_REG_COUNT          50
+#define TSMAC_PROC_PERM          0644
+/* general */
+#define TSMAC_PROC_INFO          "info"
+#define TSMAC_PROC_MACADDR       "macAddr"
+#define TSMAC_PROC_REGCONTENTS   "reg"
+#define TSMAC_PROC_PAUSEARC      "pauseARC"
+#define TSMAC_PROC_MII           "mii"
+#define TSMAC_PROC_STATS         "stats"
+#define TSMAC_PROC_DUMPRX        "dumpRX"
+#define TSMAC_PROC_DUMPTX        "dumpTX"
+#define TSMAC_PROC_LOOPBACK      "lineLoopBack"
+#define TSMAC_PROC_IPHDROFFSET   "ipHeaderOffset"
+#define TSMAC_PROC_DESCSIZE      "descSize"
+#define TSMAC_PROC_CONNTYPE      "connType"
+#define TSMAC_PROC_PHYADDR       "phyAddr"
+#define TSMAC_PROC_MIITYPE       "miiType"
+#define TSMAC_PROC_LINKMODE      "linkMode"
+#define TSMAC_PROC_TASKCPU       "taskCpu"
+
+/* pause frames */
+#define TSMAC_PROC_PAUSEENABLE   "pauseEnable"
+#define TSMAC_PROC_THRESHOLD     "threshold"
+#define TSMAC_PROC_COMPARE       "compare"
+#define TSMAC_PROC_DESTADDR      "destAddr"
+#define TSMAC_PROC_DURATION      "duration"
+
+/* flood control */
+#define TSMAC_PROC_EGRESSPRIO    "egressPriority"
+#define TSMAC_PROC_DEFAULT       "default"
+#define TSMAC_PROC_L2RULE        "macAddr"
+#define TSMAC_PROC_ETHTYPEVLAN   "ethTypeVlan"
+#define TSMAC_PROC_ETHTYPEIPV4   "ethTypeIpv4"
+#define TSMAC_PROC_ETHTYPEIPV6   "ethTypeIpv6"
+#define TSMAC_PROC_ETHTYPEUSER   "ethTypeUser"
+#define TSMAC_PROC_DUMP          "dump"
+#define TSMAC_PROC_DROPTHRESHOLD "dropThres"
+#define TSMAC_PROC_VQ            "vq"
+
+
+const char *tsmac_mii_type_str[TSMAC_MT_MAX] = {
+	"MII",
+	"GMII",
+	"RMII"
+};
+
+
+const char *msp_conntype_str[MSP_CT_MAX] = {
+	"unused",
+	"eth",
+	"switch",
+	"eth_nophy",
+	"moca",
+	"gpon"
+};
+
+
+
+/* static funtion prototypes */
+static void tsmac_ethtool_get_drvinfo(struct net_device *dev,
+				      struct ethtool_drvinfo *info);
+static int tsmac_ethtool_get_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd);
+static int tsmac_ethtool_set_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd);
+static void tsmac_ethtool_get_pauseparam(struct net_device *dev,
+					 struct ethtool_pauseparam *pause);
+static int tsmac_ethtool_set_pauseparam(struct net_device *dev,
+					struct ethtool_pauseparam *pause);
+static int tsmac_proc_read_txdesc_open(struct inode *inode, struct file *filp);
+static int tsmac_proc_read_rxdesc_open(struct inode *inode, struct file *filp);
+
+/* register name string */
+static struct reg_mess {
+	int regnum;
+	char *desc_ptr;
+} eth_reg_array[] = {
+	{0x0, "DMA Control"},
+	{0x4, "Descriptor Init and Transmit Wakeup"},
+	{0x8, "Transmit Desc Pointer, Chan 0"},
+	{0xC, "Transmit Desc Pointer, Chan 1"},
+	{0x14, "Transmit Polling Counter, Chan 0"},
+	{0x18, "Transmit Polling Counter, Chan 1"},
+	{0x1C, "Receive Desc Pointer"},
+	{0x20, "IP Header Offset"},
+	{0x24, "Interrupt Enable"},
+	{0x28, "Interrupt Source"},
+	{0x30, "Bad Address Read Error"},
+	{0x34, "Bad Address Write Error"},
+	{0x8008, "Transmit Control Frame Status"},
+	{0x800C, "MAC Control"},
+	{0x8010, "ARC Control"},
+	{0x8014, "Transmit Control"},
+	{0x8018, "Transmit Status"},
+	{0x801C, "Receive Control"},
+	{0x8020, "Receive Status"},
+	{0x8024, "Station Management Data"},
+	{0x8028, "Station Management Control and Address"},
+	{0x802C, "ARC Address"},
+	{0x8030, "ARC Data"},
+	{0x8034, "ARC Enable"},
+	{0x8038, "Maximum Length"},
+	{0x8048, "Drop-On Threshold"},
+	{0x804C, "Drop-Off Threshold"},
+	{0x8050, "VQ Configuration"},
+	{0x8054, "L2 Rule Enable"},
+	{0x8058, "VLAN TCI Offset"},
+	{0x8080, "Token Count VQ0"},
+	{0x8084, "Token Count VQ1"},
+	{0x8100, "Transmitted Good Frames"},
+	{0x8104, "Transmitted Good Bytess"},
+	{0x8108, "Received Good Frames"},
+	{0x810C, "Received Good Bytes"},
+	{0x8110, "Received Total Frames"},
+	{0x8114, "Received Total Bytes"},
+	{0x8118, "Received Overflowed Frames"},
+	{0x811C, "Received Overflowed Bytes"},
+	{0x8124, "Received Dropped Bytes"},
+	{0x8128, "Received Dropped Frames VQ0"},
+	{0x812C, "Received Dropped Frames VQ1"},
+	{0x10000, "GPMII - Interrupt"},
+	{0x10004, "GPMII - Interrupt Enable"},
+	{0x10008, "GPMII - Interrupt Value"},
+	{0x1000C, "GPMII - Config General"},
+	{0x10010, "GPMII - Config Mode"},
+	{0x10014, "GPMII - Config RX Override"},
+	{0x10018, "GPMII - Config TX Override"},
+	{0x1001C, "GPMII - Diagnostic Status"}
+};
+
+static char tsmac_usage_egressprio[] =
+	"Usage: echo <skb->priority> <high/low> > egressPriority\n";
+
+static char tsmac_usage_default[] =
+	"Usage: echo <VQ> > default\n\n" "- VQ 0-1\n";
+
+static char tsmac_usage_l2rule[] =
+	"Usage: echo <rule/enable> > macAddr\n"
+	"       OR\n"
+	"       echo <rule/enable> <VQ> <dest> <destMsk> <src> <srcMsk> > "
+	"macAddr\n\n"
+	"- rule number is 0-3, enable is 1 or 0\n"
+	"- VQ 0-1\n"
+	"- dest is the destination MAC address, eg 11:22:33:44:55:66\n"
+	"- destMsk 0 bits indicate which addresses bit to include, eg "
+	"00:00:00:00:00:00\n";
+
+static char tsmac_usage_ethtypevlan[] =
+	"Usage: echo <TCI_offset> <VQ_of_prio0> <VQ_of_prio1> ... <VQ_of_prio7>"
+	" > ethTypeVlan\n\n"
+	"- TCI_offset is the byte offset of the VLAN TCI field from the start "
+	"of the packet\n"
+	"- TCI_offset 0-63\n"
+	"- VQ_of_prio0 is the VQ (0-1) for VLAN priority 0\n";
+
+static char tsmac_usage_ethtypeip[] =
+	"Usage: echo <row> <VQa> <VQb> <VQc> <VQd> <VQe> <VQf> <VQg> <VQh>\n\n"
+	"- one row, 8 DSCPs, are edited at a time\n"
+	"- <row> is 0, 8, 16, 24, 32, 40, 48, or 56\n"
+	"- <VQa> is the VQ (0-1) for the first of 8 DSCPs\n";
+
+static char tsmac_usage_ethtypeuser[] =
+	"Usage: echo <etherType/enable> <VQ> > ethTypeUser\n\n"
+	"- etherType is a 16-bit hexadecimal type, enable is 1 or 0\n"
+	"- VQ 0-1\n";
+
+static char tsmac_usage_dropthreshold[] =
+	"Usage: echo <DropOff> <DropOn> > dropThres\n\n"
+	"- DropOff 0-8184, DropOn 4-8188\n"
+	"- each a multiple of 4-bytes, and DropOff < DropOn\n";
+
+static char tsmac_usage_vq[] =
+	"Usage: echo <VQ/drop_disable> <size> > vq\n\n"
+	"- VQ is virtual queue number 0-1, drop_disable is 1 or 0\n"
+	"- size is packets 0-65535\n";
+
+static char tsmac_usage_iphdroffset[] =
+	"Usage: echo <vlan_offset> <non_vlan_offset>  > ipHeaderOffset\n\n"
+	"- vlan_offset is the byte offset of the VLAN header from the start "
+	"of the VLAN packet\n"
+	"- non_vlan_offset is the byte offset of the IP header from the start "
+	"of the non-VLAN packet\n";
+
+static char tsmac_usage_reg[] =
+	"Usage: echo <reg_num> <reg_val> > reg\n\n"
+	"- reg_num is the TSMAC register number reported by 'cat reg'\n"
+	"- reg_val is the value to write to the register\n";
+
+static char tsmac_usage_pause_arc[] =
+	"Usage: echo <addr> <val> > pauseARC\n\n"
+	"- addr is the PAUSE/ARC memory map address reported by "
+	"'cat pauseARC'\n"
+	"- addr needs to be in the range 0x00 - 0x84 and a multiple of 4\n"
+	"- val is the value to write to the address\n";
+
+static char tsmac_usage_dump[] =
+	"Usage: echo <addr> <val> > dump\n\n"
+	"- addr is the classifier memory map address reported by "
+	"'cat dump'\n"
+	"- addr needs to be in the range 0x88 - 0x130 and a multiple of 4\n"
+	"- val is the value to write to the address\n";
+
+static char tsmac_usage_desc_size[] =
+	"Usage: echo <sel> <new_size> > descSize\n\n"
+	"sel is the ID of the descriptor ring\n"
+	"0 for RX; 1 for TX (high prio); 2 for TX (low prio)\n"
+	"new_size is the new size of the descriptor ring\n";
+
+/* procfs entries */
+struct tsmac_proc_dirs {
+	struct proc_dir_entry *eth_dir;
+	struct proc_dir_entry *qos_dir;
+	struct proc_dir_entry *classify_dir;
+	struct proc_dir_entry *provision_dir;
+};
+
+/* procfs entry directories */
+static struct tsmac_proc_dirs tsmac_proc[TSMAC_MAX_UNITS];
+
+struct ethtool_ops tsmac_ethtool_ops = {
+	.get_drvinfo = tsmac_ethtool_get_drvinfo,
+	.get_settings = tsmac_ethtool_get_settings,
+	.set_settings = tsmac_ethtool_set_settings,
+	.get_pauseparam = tsmac_ethtool_get_pauseparam,
+	.set_pauseparam = tsmac_ethtool_set_pauseparam,
+	.get_link = ethtool_op_get_link,
+};
+
+const struct file_operations txdesc_fops = {
+	.owner = THIS_MODULE,
+	.open = tsmac_proc_read_txdesc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+const struct file_operations rxdesc_fops = {
+	.owner = THIS_MODULE,
+	.open = tsmac_proc_read_rxdesc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+/*
+ * ETHTOOLS support for GET DRVINFO
+ */
+static void tsmac_ethtool_get_drvinfo(struct net_device *dev,
+				      struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, cardname);
+	strcpy(info->version, version);
+	strcpy(info->fw_version, drv_version);
+	strcpy(info->bus_info, "GMII");
+}
+
+/*
+ * ETHTOOLS support for GET SETTINGS
+ * NB: We only support MoCA as this time.
+ */
+static int tsmac_ethtool_get_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	/* printk(KERN_DEBUG "%s\n", __func__); */
+
+	if (lp->conn_type == MSP_CT_MOCA) {
+		cmd->speed = lp->speed;
+		cmd->duplex = lp->duplex;
+		cmd->supported = SUPPORTED_100baseT_Full;
+		cmd->port = PORT_TP;
+		cmd->phy_address = 1;
+		cmd->transceiver = XCVR_INTERNAL;
+		cmd->autoneg = AUTONEG_DISABLE;
+	} else if (lp->conn_type == MSP_CT_ETHSWITCH) {
+		cmd->speed = lp->speed;
+		cmd->duplex = lp->duplex;
+		cmd->supported = SUPPORTED_1000baseT_Full | SUPPORTED_MII;
+		cmd->port = PORT_MII;
+		cmd->phy_address = lp->phy_addr;
+		cmd->transceiver = XCVR_EXTERNAL;
+		cmd->autoneg = AUTONEG_DISABLE;
+	} else if (lp->conn_type == MSP_CT_ETHPHY) {
+		return phy_ethtool_gset(lp->phyptr, cmd);
+	} else {
+		return -EFAULT;
+	}
+	return 0;
+}
+
+/*
+ * ETHTOOLS support for SET SETTINGS
+ * NB: We only support MoCA as this time.
+ */
+static int tsmac_ethtool_set_settings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	/* printk(KERN_DEBUG "%s\n", __func__); */
+
+	if ((lp->conn_type == MSP_CT_MOCA) ||
+	    (lp->conn_type == MSP_CT_ETHSWITCH)) {
+		/* Nothing to do for MoCA, but must return success */
+		return 0;
+	} else if (lp->conn_type == MSP_CT_ETHPHY) {
+		return phy_ethtool_sset(lp->phyptr, cmd);
+	} else {
+		/* We only support MoCA */
+		return -EFAULT;
+	}
+}
+
+/*
+ * ETHTOOLS support for GET PAUSE PARAM
+ */
+static void tsmac_ethtool_get_pauseparam(struct net_device *dev,
+					 struct ethtool_pauseparam *pause)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	/* printk(KERN_DEBUG "%s\n", __func__); */
+
+	if (lp->flow_ctl.enable) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
+	} else {
+		pause->rx_pause = 0;
+		pause->tx_pause = 0;
+	}
+}
+
+/*
+ * ETHTOOLS support for SET PAUSE PARAM
+ * NB: We only support MoCA as this time.
+ */
+static int tsmac_ethtool_set_pauseparam(struct net_device *dev,
+					struct ethtool_pauseparam *pause)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	/* printk(KERN_DEBUG "%s\n", __func__); */
+
+	if (lp->conn_type == MSP_CT_MOCA) {
+		/* Nothing to do for MoCA, but must return success */
+		return 0;
+	} else {
+		/* We only support MoCA */
+		return -EFAULT;
+	}
+}
+
+/*
+ * Read the options that were defined while compiling the driver
+ */
+static int tsmac_proc_read_info(char *buffer, char **start, off_t off,
+				int count, int *eof, void *data)
+{
+	int len = 0;
+	struct net_device *dev = data;
+
+	/* if offset is not zero stop reading */
+	if (off > 0)
+		return 0;
+
+#ifdef CONFIG_DESC_ALL_DSPRAM
+	len += sprintf(buffer + len, "All descriptors on DSPRAM\n");
+#else
+	len += sprintf(buffer + len, "All descriptors on DDR (offchip)\n");
+#endif
+
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+	len += sprintf(buffer + len, "CONFIG_TSMAC_LINELOOPBACK_FEATURE=y\n");
+#else
+	len += sprintf(buffer + len, "CONFIG_TSMAC_LINELOOPBACK_FEATURE is "
+		       "not set\n");
+#endif
+
+#ifdef TSMAC_DEBUG
+	len += sprintf(buffer + len, "TSMAC_DEBUG=y\n");
+#else
+	len += sprintf(buffer + len, "TSMAC_DEBUG is not set\n");
+#endif
+	len += sprintf(buffer + len, "MTU=%d\n", dev->mtu);
+	return len;
+}
+
+/*
+ * Read the connection type of an interface
+ */
+static int tsmac_proc_read_conntype(char *buffer, char **start, off_t off,
+				    int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	if (off > 0)
+		return 0;
+
+	return sprintf(buffer, "%s\n", msp_conntype_str[lp->conn_type]);
+}
+
+static int tsmac_proc_write_conntype(struct file *file,
+				     const char __user *buffer,
+				     unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	enum msp_conntype_enum conn_type = MSP_CT_MAX;
+	u32 ret = 0;
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	memset(kernel_buffer, 0, KERN_BUF_MAX_SIZE);
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(%s): copy_from_user failed\n",
+		       __func__);
+		goto err_usage;
+	}
+
+	if (sscanf(kernel_buffer, "%s", kernel_buffer) != 1) {
+		goto err_usage;
+	};
+
+	for (conn_type = 0; conn_type < MSP_CT_MAX; conn_type++) {
+		if (!strcmp(kernel_buffer, msp_conntype_str[conn_type])) {
+			/* apply the new connection type setting
+			   to the interface */
+			ret = tsmac_set_conntype(dev, conn_type);
+			if (!ret) {
+				printk(KERN_INFO "The following settings "
+				       "will be applied to %s:\n", dev->name);
+				printk(KERN_INFO " Connection Type : %s\n",
+				       msp_conntype_str[conn_type]);
+				printk(KERN_INFO " MII Type        : %s\n",
+				       tsmac_mii_type_str[lp->mii_type]);
+				printk(KERN_INFO " PHY Address     : %d:%d\n",
+				       lp->bus_unit, lp->phy_addr);
+			}
+			return count;
+		}
+	}
+
+err_usage:
+	if (conn_type == MSP_CT_MAX) {
+		printk(KERN_ERR "Usage: echo <type> > connType\n\n");
+		printk(KERN_ERR "Change the connection"
+						"type of an interface\n\n");
+		printk(KERN_ERR "type:\n");
+		for (conn_type = 0; conn_type < MSP_CT_MAX; conn_type++)
+			printk(KERN_ERR "\t%s\n", msp_conntype_str[conn_type]);
+	}
+
+	return count;
+}
+
+/*
+ * Read the PHY address
+ */
+static int tsmac_proc_read_phyaddr(char *buffer, char **start, off_t off,
+				   int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	int len = 0;
+	struct tsmac_private *attached;
+
+	if ((lp->conn_type != MSP_CT_ETHPHY) &&
+				(lp->conn_type != MSP_CT_ETHSWITCH)) {
+		len += sprintf(buffer + len, "Not supported for this "
+			       "Connection Type\n");
+		return len;
+	}
+
+	if (lp->phyptr) {
+		attached = netdev_priv(lp->phyptr->attached_dev);
+		len += sprintf(buffer + len, "%d:%d\n",
+			       attached->unit, lp->phyptr->addr);
+		len += sprintf(buffer + len, "Status: attached\n");
+	} else {
+		len += sprintf(buffer + len, "%d:%d\n", lp->bus_unit,
+			       lp->phy_addr);
+		len += sprintf(buffer + len, "Status: detached\n");
+	}
+
+	return len;
+}
+
+/*
+ * Write the PHY address
+ */
+static int tsmac_proc_write_phyaddr(struct file *file,
+				    const char __user *buffer,
+				    unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	int phyunit, phyaddr;
+	int ret = 0;
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	memset(kernel_buffer, 0, KERN_BUF_MAX_SIZE);
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(%s): copy_from_user failed\n",
+		       __func__);
+		goto err_usage;
+	}
+
+	if (sscanf(kernel_buffer, "%d:%d", &phyunit, &phyaddr) != 2) {
+		goto err_usage;
+	};
+
+	ret = tsmac_set_phyaddr(dev, phyunit, phyaddr);
+	return count;
+
+err_usage:
+	printk(KERN_ERR "Usage: echo <unit:addr> > phyAddr\n\n");
+	printk(KERN_ERR "Change the PHY address of an interface\n\n");
+	return count;
+}
+
+/*
+ * Read the MII interface type
+ */
+static int tsmac_proc_read_miitype(char *buffer, char **start, off_t off,
+				   int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	return sprintf(buffer, "%s\n", tsmac_mii_type_str[lp->mii_type]);
+}
+
+static int tsmac_proc_write_miitype(struct file *file,
+				    const char __user *buffer,
+				    unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	enum tsmac_mii_type_enum mii_type = TSMAC_MT_MAX;
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	memset(kernel_buffer, 0, KERN_BUF_MAX_SIZE);
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(%s): copy_from_user failed\n",
+		       __func__);
+		goto err_usage;
+	}
+
+	if (sscanf(kernel_buffer, "%s", kernel_buffer) != 1) {
+		goto err_usage;
+	};
+
+	for (mii_type = 0; mii_type < TSMAC_MT_MAX; mii_type++) {
+		if (!strcmp(kernel_buffer, tsmac_mii_type_str[mii_type])) {
+			/* apply the new MII type setting to the interface */
+			tsmac_set_mii_type(dev, mii_type);
+			return count;
+		}
+	}
+
+err_usage:
+	if (mii_type == TSMAC_MT_MAX) {
+		printk(KERN_ERR "Usage: echo <type> > miiType\n\n");
+		printk(KERN_ERR "Change the MII type of an interface\n\n");
+		printk(KERN_ERR "type:\n");
+		for (mii_type = 0; mii_type < TSMAC_MT_MAX; mii_type++)
+			printk(KERN_ERR "\t%s\n",
+						tsmac_mii_type_str[mii_type]);
+	}
+
+	return count;
+}
+
+/*
+ * Read the link mode
+ */
+static int tsmac_proc_read_linkmode(char *buffer, char **start, off_t off,
+				    int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	int len = 0;
+
+	len += sprintf(buffer + len, "MAC link status : %d%s\n",
+		       (lp->speed == SPEED_1000) ? 1000 :
+		       ((lp->speed == SPEED_100) ? 100 : 10),
+		       (lp->duplex) ? "Full" : "Half");
+	return len;
+}
+
+/*
+ * Read the CPU for running non-datapath timer/background tasks
+ */
+static int tsmac_proc_read_taskcpu(char *buffer, char **start, off_t off,
+				   int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	int len = 0;
+
+	len += sprintf(buffer + len,
+		       "CPU for running non-datapath timer/background tasks: "
+		       "%d\n", atomic_read(&lp->timer_task_cpu));
+	return len;
+}
+
+static int tsmac_proc_write_taskcpu(struct file *file,
+				    const char __user *buffer,
+				    unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	unsigned int cpu = 0;
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	memset(kernel_buffer, 0, KERN_BUF_MAX_SIZE);
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(%s): copy_from_user failed\n",
+		       __func__);
+		goto err_usage;
+	}
+
+	if (sscanf(kernel_buffer, "%d", &cpu) != 1)
+		goto err_usage;
+
+	if (cpu < num_possible_cpus()) {
+		atomic_set(&lp->timer_task_cpu, cpu);
+		return count;
+	}
+
+err_usage:
+	printk(KERN_ERR "Usage <cpu> > taskCpu\n");
+	printk(KERN_ERR "Change the CPU for running non-datapath"
+					"timer/background tasks.\n");
+	printk(KERN_ERR "cpu: 0 - %d\n", num_possible_cpus() - 1);
+
+	return count;
+}
+
+static int tsmac_proc_read_mii(char *buffer, char **start, off_t off,
+			       int count, int *eof, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	int len = 0;
+	struct tsmac_private *attached;
+
+	/* if offset is not zero stop reading */
+	if (off > 0)
+		return 0;
+
+	if (lp->conn_type == MSP_CT_ETHPHY) {
+		if (lp->phyptr == NULL) {
+			printk(KERN_ERR "TSMAC: PHY pointer is NULL!\n");
+			return 0;
+		}
+		attached = netdev_priv(lp->phyptr->attached_dev);
+		len += sprintf(buffer, "phyaddr%d %d:%d\n", lp->unit,
+			       attached->unit, lp->phyptr->addr);
+		len += sprintf(buffer + len, "00  0x%04x  Control\n",
+			       phy_read(lp->phyptr, MII_BMCR));
+		len += sprintf(buffer + len, "01  0x%04x  Status\n",
+			       phy_read(lp->phyptr, MII_BMSR));
+		len += sprintf(buffer + len, "02  0x%04x  PHY ID 1\n",
+			       phy_read(lp->phyptr, MII_PHYSID1));
+		len += sprintf(buffer + len, "03  0x%04x  PHY ID 2\n",
+			       phy_read(lp->phyptr, MII_PHYSID2));
+		len += sprintf(buffer + len, "04  0x%04x  Auto-Neg "
+			       "Advertisement\n",
+			       phy_read(lp->phyptr, MII_ADVERTISE));
+		len += sprintf(buffer + len, "05  0x%04x  Auto-Neg Link "
+			       "Partner Ability\n",
+			       phy_read(lp->phyptr, MII_LPA));
+	} else
+		len += sprintf(buffer + len, "Not supported for this "
+			       "Connection Type\n");
+	return len;
+}
+
+/* find the no. of args */
+static int str_arg_count(const char *s, unsigned long count)
+{
+	char tmpbuf[KERN_BUF_MAX_SIZE];
+	char *tmpbufp = tmpbuf;
+	int arg_no = 0;
+
+	if (count > KERN_BUF_MAX_SIZE)
+		return 0;
+
+	memcpy(tmpbuf, s, count);
+	while (strsep(&tmpbufp, " "))
+		arg_no++;
+
+	return arg_no;
+}
+
+static int tsmac_proc_read_macaddr(char *buffer, char **start, off_t off,
+				   int count, int *eof, void *data)
+{
+	int len = 0;
+	struct net_device *dev = data;
+
+	/* if offset is not zero stop reading */
+	if (off > 0)
+		return 0;
+
+	/* copy the MAC address stored in the device object to the buffer */
+	len += sprintf(buffer + len, "%02x:%02x:%02x:%02x:%02x:%02x",
+		       dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
+		       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+
+	/* add newline at end of the string */
+	len += sprintf(buffer + len, "\n");
+
+	return len;
+}
+
+static int tsmac_proc_write_macaddr(struct file *file,
+				    const char __user *buffer,
+				    unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+
+	/* kernel space buffer */
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	struct sockaddr addr;
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	/* copy the user space data to the kernel space buffer */
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_macaddr): "
+		       "copy_from_userfailed\n");
+		return -EFAULT;
+	}
+
+	/* parse the individual bytes from the buffer */
+	if (sscanf(kernel_buffer, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		   &addr.sa_data[0], &addr.sa_data[1],
+		   &addr.sa_data[2], &addr.sa_data[3],
+		   &addr.sa_data[4], &addr.sa_data[5]) != 6) {
+		printk(KERN_WARNING "ERROR: Invalid argument count\n");
+		return count;
+	}
+
+	/* now change the MAC address of the interface */
+	if (!tsmac_set_mac_addr(dev, &addr))
+		return count;
+	else
+		return -EBUSY;
+}
+
+static int tsmac_proc_read_txdesc(struct seq_file *f, void *v)
+{
+	struct net_device *dev = (struct net_device *)f->private;
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_tx *tx;
+	struct Q_Desc *desc;
+	u32 flags;
+	u32 status;
+	u32 index;
+	u32 qnum;
+
+	if (&lp->tx[0].desc_p[0] == NULL) {
+		seq_printf(f, "%s has not been configured\n", dev->name);
+		return 0;
+	}
+
+	seq_printf(f, "Ethernet interface: %s\nNetwork carrier state: %s\n",
+		   (netif_running(dev)) ? "enabled" : "disabled",
+		   (netif_carrier_ok(dev)) ? "connected" : "not connected");
+
+	for (qnum = 0; qnum < TSMAC_NUM_TX_CH; qnum++) {
+		tx = &lp->tx[qnum];
+		seq_printf(f, "CHAN %d\n", qnum);
+		seq_printf(f, "Tx descriptor base=%p, ring size=%d, "
+			   "free space=%d\n", tx->desc_base, tx->size,
+			   tx->size - tx->qcnt);
+		seq_printf(f, "head index [%d], tail index [%d]\n",
+			   tx->head, tx->tail);
+
+		for (index = 0; index < tx->size; index++) {
+			desc = &tx->desc_p[index];
+			seq_printf(f, "[%3d] %p NextDescrPtr=0x%x "
+				   "BuffDataPtr=0x%x "
+				   "skb=%p\n",
+				   index, desc, desc->FDNext,
+				   desc->FDBuffPtr, tx->skb_pp[index]);
+			flags = desc->FDCtl;
+			status = desc->FDStat;
+			seq_printf(f, "       DMAOWN=%d len=%d Flags=0x%x, "
+				   "Status=0x%x PAUSED=%d GOOD=%d\n",
+				   (flags & FD_DMA_Own) ? 1 : 0,
+				   flags & FD_RxBuffLn_Mask,
+				   flags, status,
+				   (status & Tx_Paused) ? 1 : 0,
+				   (status & Tx_Good) ? 1 : 0);
+		}
+	}
+	return 0;
+}
+
+static int tsmac_proc_read_rxdesc(struct seq_file *f, void *v)
+{
+	struct net_device *dev = f->private;
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct Q_Desc *desc;
+	u32 index;
+	u32 flags;
+	u32 status;
+	int good;
+
+	if (&lp->rx.desc_p[0] == NULL) {
+		seq_printf(f, "%s has not been configured\n", dev->name);
+		return 0;
+	}
+
+	seq_printf(f, "Ethernet interface: %s\nNetwork carrier state: %s\n",
+		   (netif_running(dev)) ? "enabled" : "disabled",
+		   (netif_carrier_ok(dev)) ? "connected" : "not connected");
+
+	seq_printf(f, "Rx descriptor base=%p, ring size=%d, current ring "
+		   "index=%d\n", lp->rx.desc_base, lp->rx.size, lp->rx.index);
+
+	for (index = 0; index < lp->rx.size; index++) {
+		desc = &lp->rx.desc_p[index];
+		seq_printf(f, "[%3d] %p NextDescrPtr=0x%x BuffDataPtr=0x%x "
+			   "skb=%p skb->data=%p\n", index, desc,
+			   desc->FDNext, desc->FDBuffPtr,
+			   lp->rx.skb_pp[index], lp->rx.skb_pp[index]->data);
+		flags = desc->FDCtl;
+		status = desc->FDStat;
+		good = status & Rx_Good;
+		seq_printf(f, "       DMAOWN=%d TRUNC=%d len=%d Flags=0x%x, "
+			   "Status=0x%x GOOD=%d",
+			   (flags & FD_DMA_Own) ? 1 : 0,
+			   (flags & FD_RxTrunc) ? 1 : 0,
+			   flags & FD_RxBuffLn_Mask, flags, status,
+			   (good) ? 1 : 0);
+		if (good)
+			seq_printf(f, "\n");
+		else {
+			seq_printf(f, " OVERFLOW=%d CRCERR=%d LENERR=%d\n",
+				   (status & Rx_OverFlow) ? 1 : 0,
+				   (status & Rx_CRCErr) ? 1 : 0,
+				   (status & Rx_LenErr) ? 1 : 0);
+		}
+	}
+	return 0;
+}
+
+static int tsmac_proc_read_stats(char *buffer, char **start, off_t off,
+				 int count, int *eof, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	len += sprintf(buffer + len, "\nSoftware Counters\n\n");
+
+	len += sprintf(buffer + len, "RX Stats\n");
+	/* RX packets */
+	len += sprintf(buffer + len, "RX Packets:                  %lu\n",
+		       lp->lx_stats.rx_packets);
+	/* RX multicast packets */
+	len += sprintf(buffer + len, "RX Multicast Packets:        %lu\n",
+		       lp->lx_stats.multicast);
+	/* RX bytes */
+	len += sprintf(buffer + len, "RX Bytes:                    %llu\n",
+		       lp->sw_stats.rx_bytes);
+	/* RX packets in each VQ */
+	len += sprintf(buffer + len, "RX VQ0:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[0]);
+	len += sprintf(buffer + len, "RX VQ1:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[1]);
+	len += sprintf(buffer + len, "RX VQ2:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[2]);
+	len += sprintf(buffer + len, "RX VQ3:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[3]);
+	len += sprintf(buffer + len, "RX VQ4:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[4]);
+	len += sprintf(buffer + len, "RX VQ5:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[5]);
+	len += sprintf(buffer + len, "RX VQ6:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[6]);
+	len += sprintf(buffer + len, "RX VQ7:                      %u\n",
+		       lp->sw_stats.rx_vq_frames[7]);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "RX Error Stats\n");
+	/* RX error packets */
+	len += sprintf(buffer + len, "RX Errors:                   %lu\n",
+		       lp->lx_stats.rx_errors);
+	/* RX long error */
+	len += sprintf(buffer + len, "RX Long Errors:              %u\n",
+		       lp->sw_stats.rx_long_errors);
+	/* RX packet length error */
+	len += sprintf(buffer + len, "RX Length Errors:            %lu\n",
+		       lp->lx_stats.rx_length_errors);
+	/* RX packet alignment error */
+	len += sprintf(buffer + len, "RX Align Errors:             %lu\n",
+		       lp->lx_stats.rx_frame_errors);
+	/* RX packet CRC errors */
+	len += sprintf(buffer + len, "RX CRC Errors:               %lu\n",
+		       lp->lx_stats.rx_crc_errors);
+	/* RX packet truncated errors */
+	len += sprintf(buffer + len, "RX Truncated:                %u\n",
+		       lp->sw_stats.rx_trunc_errors);
+#ifdef CONFIG_TSMAC_TEST_CMDS
+	/* RX incorrect L4 checksum on VLAN packets */
+	len += sprintf(buffer + len, "RX Chksum Errors (VLAN):     %u\n",
+		       lp->sw_stats.rx_nochksum_vlan);
+	/* RX incorrect L4 checksum on non-VLAN packets */
+	len += sprintf(buffer + len, "RX Chksum Errors (non-VLAN): %u\n",
+		       lp->sw_stats.rx_nochksum_nonvlan);
+#endif
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "RX Util Stats\n");
+	/* RX interrupts */
+	len += sprintf(buffer + len, "RX Interrupts:               %u\n",
+		       lp->sw_stats.rx_ints);
+	/* RX descriptor ring exhausted */
+	len += sprintf(buffer + len, "RX Exhausted:                %lu\n",
+		       lp->lx_stats.rx_fifo_errors);
+	/* RX dropped packets due to out of memory */
+	len += sprintf(buffer + len, "RX Dropped Packets (NOMEM):  %lu\n",
+		       lp->lx_stats.rx_dropped);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "TX Stats\n");
+	/* TX packets */
+	len += sprintf(buffer + len, "TX Packets:                  %lu\n",
+		       lp->lx_stats.tx_packets);
+	/* TX bytes */
+	len += sprintf(buffer + len, "TX Bytes:                    %llu\n",
+		       lp->sw_stats.tx_bytes);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "TX Error Stats\n");
+	/* TX error packets */
+	len += sprintf(buffer + len, "TX Errors:                   %lu\n",
+		       lp->lx_stats.tx_errors);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "TX Util Stats\n");
+	/* TX interrupts */
+	len += sprintf(buffer + len, "TX Interrupts:               %u\n",
+		       lp->sw_stats.tx_ints);
+	/* TX full */
+	len += sprintf(buffer + len, "TX Full (high priority):     %u\n",
+		       lp->sw_stats.tx_full[TSMAC_DESC_PRI_HI]);
+	len += sprintf(buffer + len, "TX Full (low priority):      %u\n",
+		       lp->sw_stats.tx_full[TSMAC_DESC_PRI_LO]);
+	/* TX collisions */
+	len += sprintf(buffer + len, "TX Collisions:               %lu\n",
+		       lp->lx_stats.collisions);
+	len += sprintf(buffer + len, "TX Dropped Packets:          %lu\n",
+		       lp->lx_stats.tx_dropped);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "Hardware Counters\n\n");
+
+	/* accumulate counters from device */
+	tsmac_update_hw_stats(dev);
+
+	len += sprintf(buffer + len, "RX Stats\n");
+	/* RX packets */
+	len += sprintf(buffer + len, "RX Packets:                  %u\n",
+		       lp->hw_stats.rx_packets);
+	/* RX bytes */
+	len += sprintf(buffer + len, "RX Bytes:                    %llu\n",
+		       lp->hw_stats.rx_bytes);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "RX Error Stats\n");
+	/* RX FIFO overflows */
+	len += sprintf(buffer + len, "RX FIFO Overflow:            %lu\n",
+		       lp->lx_stats.rx_over_errors);
+	/* RX dropped bytes */
+	len += sprintf(buffer + len, "RX Dropped Bytes:            %llu\n",
+		       lp->hw_stats.rx_dropped_bytes);
+	/* RX VQ dropped packets */
+	len += sprintf(buffer + len, "RX Drop VQ0:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[0]);
+	len += sprintf(buffer + len, "RX Drop VQ1:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[1]);
+	len += sprintf(buffer + len, "RX Drop VQ2:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[2]);
+	len += sprintf(buffer + len, "RX Drop VQ3:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[3]);
+	len += sprintf(buffer + len, "RX Drop VQ4:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[4]);
+	len += sprintf(buffer + len, "RX Drop VQ5:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[5]);
+	len += sprintf(buffer + len, "RX Drop VQ6:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[6]);
+	len += sprintf(buffer + len, "RX Drop VQ7:                 %u\n",
+		       lp->hw_stats.rx_vq_drops[7]);
+	len += sprintf(buffer + len, "\n");
+
+	len += sprintf(buffer + len, "TX Stats\n");
+	len += sprintf(buffer + len, "TX Packets:                  %u\n",
+		       lp->hw_stats.tx_packets);
+	len += sprintf(buffer + len, "TX Bytes:                    %llu\n",
+		       lp->hw_stats.tx_bytes);
+
+	return len;
+}
+
+static int tsmac_proc_write_stats(struct file *file, const char __user *buffer,
+				  unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* clear counters in device */
+	tsmac_update_hw_stats(dev);
+
+	/* clear software counters */
+	memset(&lp->lx_stats, 0, sizeof(lp->lx_stats));
+	memset(&lp->sw_stats, 0, sizeof(lp->sw_stats));
+	memset(&lp->hw_stats, 0, sizeof(lp->hw_stats));
+
+	return count;
+}
+
+static int tsmac_proc_read_reg(char *buf, char **bloc, off_t off, int length,
+			       int *eof, void *data)
+{
+	int len = 0;
+	u32 i;
+	u32 regnum;
+	u32 regval;
+	struct reg_mess *regp;
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* finished reading regardless of anything else */
+	if (off > 0)
+		return 0;
+
+	/* print each register in the TSMAC subsystem */
+	regp = eth_reg_array;
+	for (i = 0; i < TSMAC_REG_COUNT; ++i, ++regp) {
+		regnum = regp->regnum;
+		regval = tsmac_read((void *)((u32) lp->reg_map + regnum));
+		len += sprintf(buf + len, "0x%05x  0x%08x  %s\n",
+			       regnum, regval, regp->desc_ptr);
+	}
+
+#if !defined(CONFIG_PMC_MSP7140_FPGA)
+	/* and the Clock Manager register edited by the driver */
+	regnum = TSMAC_CTRL_OUTPUT;
+	regval = tsmac_read((void *)regnum);
+	len += sprintf(buf + len, "0x%05x  0x%08x  %s\n",
+		       regnum, regval, "CLK_MGR_MSP - TSMAC Control Output");
+
+	/* MAC C output control register */
+	regnum = TSMAC_MAC_C_OUTPUT_CTRL;
+	regval = tsmac_read((void *)regnum);
+	len += sprintf(buf + len, "0x%05x  0x%08x  %s\n",
+		       regnum, regval, "CLK_MGR_MSP - MAC C Output Control");
+#endif
+	return len;
+}
+
+static int tsmac_proc_write_reg(struct file *file, const char __user *buffer,
+				unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct reg_mess *regp;
+	u32 regnum, regval;
+	int i, args;
+
+	/* kernel space buffer */
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	/* copy the user space data to the kernel space buffer */
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	/* IF wrong # of arguments */
+	args = sscanf(kernel_buffer, "%x %x", &regnum, &regval);
+	if ((args != 1) && (args != 2)) {
+		printk(KERN_WARNING "%s", tsmac_usage_reg);
+		return count;
+	}
+
+	/* validate register num */
+	regp = eth_reg_array;
+	for (i = 0; i < TSMAC_REG_COUNT; ++i, ++regp) {
+		if (regnum == regp->regnum)
+			break;
+	}
+	if (i >= TSMAC_REG_COUNT) {
+		printk(KERN_WARNING "%s", tsmac_usage_reg);
+		return count;
+	}
+
+	/* IF only register number provided */
+	if (args == 1) {
+		/* print 1 register */
+		regval = tsmac_read((void *)((u32) lp->reg_map + regnum));
+		printk(KERN_INFO "0x%05x  0x%08x  %s\n",
+		       regnum, regval, regp->desc_ptr);
+		return count;
+	}
+
+	/* edit register */
+	tsmac_write(regval, (void *)((u32) lp->reg_map + regnum));
+
+	return count;
+}
+
+static int tsmac_proc_read_pause_arc(char *buffer, char **start, off_t off,
+				     int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	if (off > 0)
+		return 0;
+
+	return tsmac_print_map_pause_arc(lp, buffer);
+}
+
+static int tsmac_proc_write_pause_arc(struct file *file,
+				      const char __user *buffer,
+				      unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	u32 addr, val;
+	int args;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (!netif_running(dev)) {
+		printk(KERN_WARNING "Interface is currently down!\n");
+		return count;
+	}
+
+	/* wrong # of arguments */
+	args = sscanf(kernel_buffer, "%x %x", &addr, &val);
+	if (args != 2) {
+		printk(KERN_WARNING "%s", tsmac_usage_pause_arc);
+		return count;
+	}
+
+	/* validate memory address */
+	if (addr > 0x84 || ((addr & 0x3) != 0)) {
+		printk(KERN_WARNING "%s", tsmac_usage_pause_arc);
+		return count;
+	}
+
+	/* load the word into memory */
+	tsmac_write(addr, &lp->reg_map->mac.arc_addr);
+	tsmac_write(val, &lp->reg_map->mac.arc_data);
+
+	return count;
+}
+
+static int tsmac_proc_read_desc_size(char *buffer, char **start, off_t off,
+				     int count, int *eof, void *data)
+{
+	int len = 0;
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	if (off > 0)
+		return 0;
+
+	len += sprintf(buffer, "ID\tDescriptor\tSize\n");
+	len += sprintf(buffer + len, "0\tRX\t\t%u\n", lp->rx.size);
+	len += sprintf(buffer + len, "1\tTX - Hi\t\t%u\n", lp->tx[0].size);
+	len += sprintf(buffer + len, "2\tTX - Lo\t\t%u\n", lp->tx[1].size);
+
+	return len;
+}
+
+static int tsmac_proc_write_desc_size(struct file *file,
+				      const char __user *buffer,
+				      unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	int sel;
+	unsigned int new_size;
+	int args;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (netif_running(dev)) {
+		printk(KERN_WARNING "\nInterface is currently up! Descriptor "
+		       "ring size can only be changed when the interface is "
+		       "down\n");
+		return count;
+	}
+
+	/* wrong # of arguments */
+	args = sscanf(kernel_buffer, "%d %u", &sel, &new_size);
+	if (args != 2) {
+		printk(KERN_WARNING "%s", tsmac_usage_desc_size);
+		return count;
+	}
+
+	/* validate descriptor ring size */
+	if (new_size > MAX_RING_SIZE || new_size < MIN_RING_SIZE) {
+		printk(KERN_WARNING "%s", tsmac_usage_desc_size);
+		return count;
+	}
+
+	switch (sel) {
+	case 0:		/* for RX descriptor ring size */
+		lp->rx.size = new_size;
+		break;
+
+	case 1:		/* for TX - high priority */
+		lp->tx[0].size = new_size;
+		break;
+
+	case 2:		/* for TX - low priority */
+		lp->tx[1].size = new_size;
+		break;
+
+	default:
+		break;
+	}
+
+	printk(KERN_WARNING "\n\nWARNING: Setting the descriptor ring too "
+	       "large on multiple interfaces might cause the system "
+	       "running out of scratch pad ram\n");
+
+	return count;
+}
+
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+static int tsmac_proc_read_lineloopback(char *buffer, char **start, off_t off,
+					int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	u8 loopback;
+
+	int len = 0;
+
+	/* if offset is not zero stop reading */
+	if (off > 0)
+		return 0;
+
+	iodata.data = &loopback;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_loopback(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "%d\n", loopback);
+
+	return len;
+}
+
+static int tsmac_proc_write_lineloopback(struct file *file,
+					 const char __user *buffer,
+					 unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	u8 loopback;
+
+	/* kernel space buffer */
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	/* copy the user space data to the kernel space buffer */
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_lineloopback): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%hhu", &loopback) != 1) {
+		printk(KERN_WARNING "ERROR: Invalid argument count\n");
+		return count;
+	}
+
+	iodata.data = &loopback;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_loopback(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+#endif
+
+/*
+ * Read the IP header offset register
+ */
+static int tsmac_proc_read_iphdroffset(char *buffer, char **start, off_t off,
+				       int count, int *eof, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	u32 reg;
+	u8 offset_vlan;
+	u8 offset_nvlan;
+	int len = 0;
+
+	/* if offset is not zero stop reading */
+	if (off > 0)
+		return 0;
+
+	reg = tsmac_read(&lp->reg_map->dma.iphdr_offset);
+
+	offset_vlan = (reg & DMA_OffsetVLAN_Mask) >> DMA_OffsetVLAN_Shift;
+	offset_nvlan = reg & DMA_OffsetNonVLAN_Mask;
+
+	len += sprintf(buffer + len, "IP Header Offset for VLAN packets: %u\n",
+		       offset_vlan);
+	len += sprintf(buffer + len, "IP Header Offset for non-VLAN packets:"
+		       " %u\n", offset_nvlan);
+	return len;
+}
+
+/*
+ * Configure the IP header offset register
+ */
+static int tsmac_proc_write_iphdroffset(struct file *file,
+					const char __user *buffer,
+					unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	u8 offset_vlan;
+	u8 offset_nvlan;
+
+	/* kernel space buffer */
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	/* copy the user space data to the kernel space buffer */
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_iphdroffset): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%hhu %hhu", &offset_vlan,
+		   &offset_nvlan) != 2) {
+		printk(KERN_WARNING "%s", tsmac_usage_iphdroffset);
+		return count;
+	}
+
+	lp->iphdr_offset.vlan = offset_vlan;
+	lp->iphdr_offset.nvlan = offset_nvlan;
+
+	tsmac_write((offset_vlan << DMA_OffsetVLAN_Shift) | offset_nvlan,
+		    &lp->reg_map->dma.iphdr_offset);
+
+	return count;
+}
+
+static int tsmac_proc_read_egressprio(char *buffer, char **start, off_t off,
+				      int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	enum tsmac_egress_prio egress_prio[TSMAC_NUM_SKB_PRIORITY];
+	int i;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = egress_prio;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_egress_prio(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "skb->priority\tEgress Queue\n");
+	for (i = 0; i < TSMAC_NUM_SKB_PRIORITY; i++) {
+		len += sprintf(buffer + len, "\t%d\t%s\n", i, egress_prio[i] ==
+			       TSMAC_DESC_PRI_HI ? "high" : "low");
+	}
+	return len;
+}				/* tsmac_proc_read_egressprio() */
+
+static int tsmac_proc_write_egressprio(struct file *file,
+				       const char __user *buffer,
+				       unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	enum tsmac_egress_prio egress_prio_new[2];
+	char priority[12];
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(%s): copy_from_user failed\n",
+		       __func__);
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%d %s", (int *)&egress_prio_new[0],
+		   priority) != 2) {
+		printk(KERN_WARNING "%s", tsmac_usage_egressprio);
+		return count;
+	}
+
+	/* validate skb->priority number */
+	if (egress_prio_new[0] >= TSMAC_NUM_SKB_PRIORITY) {
+		printk(KERN_WARNING "%s", tsmac_usage_egressprio);
+		return count;
+	}
+
+	if (!strcmp(priority, "high"))
+		egress_prio_new[1] = TSMAC_DESC_PRI_HI;
+	else
+		egress_prio_new[1] = TSMAC_DESC_PRI_LO;
+
+	iodata.data = egress_prio_new;
+	ifr.ifr_data = &iodata;
+	tsmac_set_egress_prio(dev, &ifr, TSMAC_KERNEL_DATA);
+	return count;
+}				/* tsmac_proc_write_egressprio() */
+
+static int tsmac_proc_read_default(char *buffer, char **start, off_t off,
+				   int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	u8 default_vq;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = &default_vq;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_default_vq_map(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "Default VQ is %d\n", default_vq);
+
+	return len;
+}
+
+static int tsmac_proc_write_default(struct file *file,
+				    const char __user *buffer,
+				    unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	u8 default_vq;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_default): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%hhu", &default_vq) != 1) {
+		printk(KERN_WARNING "%s", tsmac_usage_default);
+		return count;
+	}
+
+	if (default_vq >= VQ_MAX) {
+		printk(KERN_WARNING "%s", tsmac_usage_default);
+		return count;
+	}
+
+	iodata.data = &default_vq;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_default_vq_map(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+
+static int tsmac_proc_read_l2rule(char *buffer, char **start, off_t off,
+				  int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_l2_class_rule l2rules[4];
+	int len = 0;
+	int i;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = l2rules;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_addr_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer,
+		       "R/E  Q  Dest Addr\t\tDest Mask\t\tSource Addr\t\t"
+		       "Source Mask\n");
+
+	for (i = 0; i < 4; i++) {
+		len += sprintf(buffer + len, "%d/%d  %d  ",
+			       l2rules[i].rule_num, l2rules[i].enable,
+			       l2rules[i].vqnum);
+		len += sprintf(buffer + len, "%02x:%02x:%02x:%02x:%02x:%02x\t",
+			       l2rules[i].DA[0], l2rules[i].DA[1],
+			       l2rules[i].DA[2], l2rules[i].DA[3],
+			       l2rules[i].DA[4], l2rules[i].DA[5]);
+		len += sprintf(buffer + len, "%02x:%02x:%02x:%02x:%02x:%02x\t",
+			       l2rules[i].DM[0], l2rules[i].DM[1],
+			       l2rules[i].DM[2], l2rules[i].DM[3],
+			       l2rules[i].DM[4], l2rules[i].DM[5]);
+		len += sprintf(buffer + len, "%02x:%02x:%02x:%02x:%02x:%02x\t",
+			       l2rules[i].SA[0], l2rules[i].SA[1],
+			       l2rules[i].SA[2], l2rules[i].SA[3],
+			       l2rules[i].SA[4], l2rules[i].SA[5]);
+		len += sprintf(buffer + len, "%02x:%02x:%02x:%02x:%02x:%02x\n",
+			       l2rules[i].SM[0], l2rules[i].SM[1],
+			       l2rules[i].SM[2], l2rules[i].SM[3],
+			       l2rules[i].SM[4], l2rules[i].SM[5]);
+	}
+	return len;
+}
+
+static int tsmac_proc_write_l2rule(struct file *file,
+				   const char __user *buffer,
+				   unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_l2_class_rule cfg;
+	int arg_no;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	/* copy the user space data to the kernel space buffer */
+	if ((count > KERN_BUF_MAX_SIZE) ||
+	    copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_l2rule): copy_from_user"
+		       " failed\n");
+		return -EFAULT;
+	}
+
+	/* find the no. of args */
+	arg_no = str_arg_count(kernel_buffer, count);
+
+	cfg.change_state_only = 0;
+
+	if (arg_no == 1) {
+		/* get the Rule/enable value */
+		sscanf(kernel_buffer, "%hhu/%hhu", &cfg.rule_num, &cfg.enable);
+		cfg.change_state_only = 1;
+	} else {
+		unsigned int ret;
+		ret = sscanf(kernel_buffer,
+			     "%hhu/%hhu %hhu %hhx:%hhx:%hhx:%hhx:%hhx:%hhx "
+			     "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx %hhx:%hhx:%hhx:"
+			     "%hhx:%hhx:%hhx %hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+			     &cfg.rule_num, &cfg.enable, &cfg.vqnum,
+			     &cfg.DA[0], &cfg.DA[1], &cfg.DA[2],
+			     &cfg.DA[3], &cfg.DA[4], &cfg.DA[5],
+			     &cfg.DM[0], &cfg.DM[1], &cfg.DM[2],
+			     &cfg.DM[3], &cfg.DM[4], &cfg.DM[5],
+			     &cfg.SA[0], &cfg.SA[1], &cfg.SA[2],
+			     &cfg.SA[3], &cfg.SA[4], &cfg.SA[5],
+			     &cfg.SM[0], &cfg.SM[1], &cfg.SM[2],
+			     &cfg.SM[3], &cfg.SM[4], &cfg.SM[5]);
+		if (ret != 27) {
+			printk(KERN_WARNING "%s", tsmac_usage_l2rule);
+			return count;
+		}
+	}
+
+	/* validate rule number and VQ number */
+	if ((cfg.rule_num >= 4) || ((arg_no > 1) && (cfg.vqnum >= VQ_MAX))) {
+		printk(KERN_WARNING "%s", tsmac_usage_l2rule);
+		return count;
+	}
+
+	if (cfg.enable != 0)
+		cfg.enable = 1;
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_addr_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+
+static int tsmac_proc_read_ethtypevlan(char *buffer, char **start, off_t off,
+				       int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_vlanvq_config cfg;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_vlan_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "TCI\tP0 P1 P2 P3 P4 P5 P6 P7\n");
+	len += sprintf(buffer + len, "%d\t%d  %d  %d  %d  %d  %d  %d  %d\n",
+		       cfg.tci_offset,
+		       (cfg.vlanvq[0] & 0x0F),
+		       (cfg.vlanvq[0] & 0xF0) >> 4,
+		       (cfg.vlanvq[1] & 0x0F),
+		       (cfg.vlanvq[1] & 0xF0) >> 4,
+		       (cfg.vlanvq[2] & 0x0F),
+		       (cfg.vlanvq[2] & 0xF0) >> 4,
+		       (cfg.vlanvq[3] & 0x0F), (cfg.vlanvq[3] & 0xF0) >> 4);
+	return len;
+}
+
+static int tsmac_proc_write_ethtypevlan(struct file *file,
+					const char __user *buffer,
+					unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_vlanvq_config cfg;
+	u8 priority[8];
+	int i, j;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_ethtypevlan): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%hhu %hhu %hhu %hhu %hhu %hhu %hhu %hhu "
+		   "%hhu", &cfg.tci_offset, &priority[0], &priority[1],
+		   &priority[2], &priority[3], &priority[4],
+		   &priority[5], &priority[6], &priority[7]) != 9) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypevlan);
+		return count;
+	}
+
+	/* validate VLAN offset */
+	if (cfg.tci_offset >= 63) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypevlan);
+		return count;
+	}
+
+	/* validate VQ mapping */
+	for (i = 0; i < 8; i++) {
+		if (priority[i] >= VQ_MAX) {
+			printk(KERN_WARNING "%s", tsmac_usage_ethtypevlan);
+			return count;
+		}
+	}
+
+	/*
+	 * Update the device object with the new values; each VQ mapping is
+	 * represented by 4 bits
+	 */
+	for (i = 0, j = 0; i < 4; i++) {
+		cfg.vlanvq[i] = (priority[j++] & 0x0F);
+		cfg.vlanvq[i] |= (priority[j++] & 0x0F) << 4;
+	}
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_vlan_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+
+static int tsmac_proc_read_ethtypeipv4(char *buffer, char **start, off_t off,
+				       int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_ipvq_config cfg[8];
+	int row, dscp = 0;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	/* set the variable indicating ipv4/ipv6 */
+	cfg[0].ipv4 = 1;	/* only set the first one is enough */
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_ip_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	for (row = 0; row < 8; row++) {
+		len += sprintf(buffer + len, "dscp  %02d-%02d: ", dscp,
+			       dscp + 7);
+		len += sprintf(buffer + len, "%d %d %d %d %d %d %d %d\n",
+			       (cfg[row].ip_vq[0] & 0x0F),
+			       (cfg[row].ip_vq[0] & 0xF0) >> 4,
+			       (cfg[row].ip_vq[1] & 0x0F),
+			       (cfg[row].ip_vq[1] & 0xF0) >> 4,
+			       (cfg[row].ip_vq[2] & 0x0F),
+			       (cfg[row].ip_vq[2] & 0xF0) >> 4,
+			       (cfg[row].ip_vq[3] & 0x0F),
+			       (cfg[row].ip_vq[3] & 0xF0) >> 4);
+		dscp += 8;
+	}
+
+	return len;
+}
+
+static int tsmac_proc_read_ethtypeipv6(char *buffer, char **start, off_t off,
+				       int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_ipvq_config cfg[8];
+	int row, dscp = 0;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	/* set the variable indicating ipv4/ipv6 */
+	cfg[0].ipv4 = 0;	/* onlythe set the first one is enough */
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_ip_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	for (row = 0; row < 8; row++) {
+		len += sprintf(buffer + len, "dscp  %02d-%02d: ", dscp,
+			       dscp + 7);
+		len += sprintf(buffer + len, "%d %d %d %d %d %d %d %d\n",
+			       (cfg[row].ip_vq[0] & 0x0F),
+			       (cfg[row].ip_vq[0] & 0xF0) >> 4,
+			       (cfg[row].ip_vq[1] & 0x0F),
+			       (cfg[row].ip_vq[1] & 0xF0) >> 4,
+			       (cfg[row].ip_vq[2] & 0x0F),
+			       (cfg[row].ip_vq[2] & 0xF0) >> 4,
+			       (cfg[row].ip_vq[3] & 0x0F),
+			       (cfg[row].ip_vq[3] & 0xF0) >> 4);
+		dscp += 8;
+	}
+	return len;
+}
+
+static int tsmac_proc_write_ethtypeipv4(struct file *file,
+					const char __user *buffer,
+					unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_ipvq_config cfg;
+	u8 vqmap[8];
+	int row, i, j;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_ethtypeipv4): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%d %hhu %hhu %hhu %hhu %hhu %hhu %hhu %hhu",
+		   &row, &vqmap[0], &vqmap[1], &vqmap[2], &vqmap[3], &vqmap[4],
+		   &vqmap[5], &vqmap[6], &vqmap[7]) != 9) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypeip);
+		return count;
+	}
+
+	/* validate DSCP range */
+	if (row < 0 || row > 63) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypeip);
+		return count;
+	}
+
+	/* validate VQ mapping */
+	for (i = 0; i < 8; i++) {
+		if (vqmap[i] >= VQ_MAX) {
+			printk(KERN_WARNING "%s", tsmac_usage_ethtypeip);
+			return count;
+		}
+	}
+
+	/*
+	 * Update the device object with the new values; each VQ mapping is "
+	 * represented by 4 bits
+	 */
+	for (i = 0, j = 0; i < 4; i++) {
+		cfg.ip_vq[i] = (vqmap[j++] & 0x0F);
+		cfg.ip_vq[i] |= (vqmap[j++] & 0x0F) << 4;
+	}
+
+	/* set the variable indicating ipv4/ipv6 */
+	cfg.ipv4 = 1;		/* we are setting ipv4 rules */
+
+	/* set the row */
+	cfg.dsp_range = row;
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_ip_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+
+static int tsmac_proc_write_ethtypeipv6(struct file *file,
+					const char __user *buffer,
+					unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_ipvq_config cfg;
+	u8 vqmap[8];
+	int row, i, j;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_ethtypeipv6): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%d %hhu %hhu %hhu %hhu %hhu %hhu %hhu %hhu",
+		   &row, &vqmap[0], &vqmap[1], &vqmap[2], &vqmap[3], &vqmap[4],
+		   &vqmap[5], &vqmap[6], &vqmap[7]) != 9) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypeip);
+		return count;
+	}
+
+	/* validate DSCP range */
+	if (row < 0 || row > 63) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypeip);
+		return count;
+	}
+
+	/* validate VQ mapping */
+	for (i = 0; i < 8; i++) {
+		if (vqmap[i] >= VQ_MAX) {
+			printk(KERN_WARNING "%s", tsmac_usage_ethtypeip);
+			return count;
+		}
+	}
+
+	/*
+	 * Update the device object with the new values; each VQ mapping is
+	 * represented by 4 bits
+	 */
+	for (i = 0, j = 0; i < 4; i++) {
+		cfg.ip_vq[i] = (vqmap[j++] & 0x0F);
+		cfg.ip_vq[i] |= (vqmap[j++] & 0x0F) << 4;
+	}
+
+	/* set the variable indicating ipv4/ipv6 */
+	cfg.ipv4 = 0;		/* we are setting ipv6 rules */
+
+	/* set the row */
+	cfg.dsp_range = row;
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_ip_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+	return count;
+}
+
+static int tsmac_proc_read_ethtypeuser(char *buffer, char **start, off_t off,
+				       int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_ethtype_config cfg;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_ethtype_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "EthType/E Q\n");
+	len += sprintf(buffer + len, " 0x%02x%02x/%d %d\n",
+		       cfg.ethtype[0], cfg.ethtype[1],
+		       cfg.ethtype_enable, cfg.ethtype_vq);
+	return len;
+}
+
+static int tsmac_proc_write_ethtypeuser(struct file *file,
+					const char __user *buffer,
+					unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_ethtype_config cfg;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_ethtypeuser): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%hx/%hhu %hhu",
+		   (unsigned short *)&cfg.ethtype[0],
+		   &cfg.ethtype_enable, &cfg.ethtype_vq) != 3) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypeuser);
+		return count;
+	}
+
+	if (cfg.ethtype_enable != 0)
+		cfg.ethtype_enable = 1;
+
+	/* validate VQ number */
+	if (cfg.ethtype_vq >= VQ_MAX) {
+		printk(KERN_WARNING "%s", tsmac_usage_ethtypeuser);
+		return count;
+	}
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_ethtype_class_rule(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+
+static int tsmac_proc_read_dump(char *buffer, char **start, off_t off,
+				int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	if (off > 0)
+		return 0;
+
+	return tsmac_print_map_classifier(lp, buffer);
+}
+
+static int tsmac_proc_write_dump(struct file *file,
+				 const char __user *buffer,
+				 unsigned long count, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+	u32 addr, val;
+	int args;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (!netif_running(dev)) {
+		printk(KERN_WARNING "Interface is currently down!\n");
+		return count;
+	}
+
+	/* wrong # of arguments */
+	args = sscanf(kernel_buffer, "%x %x", &addr, &val);
+	if (args != 2) {
+		printk(KERN_WARNING "%s", tsmac_usage_dump);
+		return count;
+	}
+
+	/* validate memory address */
+	if (addr < 0x84 || addr > 0x130 || ((addr & 0x03) != 0)) {
+		printk(KERN_WARNING "%s", tsmac_usage_dump);
+		return count;
+	}
+
+	/* load the word into memory */
+	tsmac_write(addr, &lp->reg_map->mac.arc_addr);
+	tsmac_write(val, &lp->reg_map->mac.arc_data);
+
+	return count;
+}
+
+static int tsmac_proc_read_dropthreshold(char *buffer, char **start, off_t off,
+					 int count, int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_drop_threshold cfg;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_drop_thresh(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "DropOff\tDropOn\n");
+
+	len += sprintf(buffer + len, "%7d%7d\n", cfg.drop_off_thresh,
+		       cfg.drop_on_thresh);
+
+	return len;
+}
+
+static int tsmac_proc_write_dropthreshold(struct file *file,
+					  const char __user *buffer,
+					  unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_drop_threshold cfg;
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_dropthreshold): "
+		       "copy_from_user failed\n");
+		return -EFAULT;
+	}
+
+	if (sscanf(kernel_buffer, "%hu %hu", &cfg.drop_off_thresh,
+		   &cfg.drop_on_thresh) != 2) {
+		printk(KERN_WARNING "%s", tsmac_usage_dropthreshold);
+		return count;
+	}
+
+	/* validate drop off level */
+	if ((cfg.drop_off_thresh > RX_DROPOFF_MAX) ||
+	    (cfg.drop_off_thresh & 0x3)) {
+		printk(KERN_WARNING "%s", tsmac_usage_dropthreshold);
+		return count;
+	}
+
+	/* validate drop on level */
+	if ((cfg.drop_on_thresh > RX_DROPON_MAX) ||
+	    (cfg.drop_on_thresh & 0x3)) {
+		printk(KERN_WARNING "%s", tsmac_usage_dropthreshold);
+		return count;
+	}
+
+	if (cfg.drop_off_thresh >= cfg.drop_on_thresh) {
+		printk(KERN_WARNING "%s", tsmac_usage_dropthreshold);
+		return count;
+	}
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_drop_thresh(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	return count;
+}
+
+static int tsmac_proc_read_vq(char *buffer, char **start, off_t off, int count,
+			      int *eof, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_vq_config cfg[VQ_MAX];
+	int i;
+	int len = 0;
+
+	if (off > 0)
+		return 0;
+
+	iodata.data = cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_get_vq_config(dev, &ifr, TSMAC_KERNEL_DATA);
+
+	len += sprintf(buffer, "Q/D\tSize\tCurrent\n");
+	for (i = 0; i < VQ_MAX; i++) {
+		len += sprintf(buffer + len, "%d/%d\t%d\t%d\n",
+			       cfg[i].vq_num,
+			       cfg[i].vq_drop_disable,
+			       cfg[i].vq_token_count,
+			       (tsmac_read(&lp->reg_map->mac.vq_token_cnt[i])
+				& VQ_TC_Token_Cnt_Mask));
+	}
+	return len;
+}
+
+static int tsmac_proc_write_vq(struct file *file, const char __user *buffer,
+			       unsigned long count, void *data)
+{
+	struct net_device *dev = data;
+	struct tsmac_io_data iodata;
+	struct ifreq ifr;
+	struct tsmac_vq_config cfg;
+	char tmpbuf[80];
+	char kernel_buffer[KERN_BUF_MAX_SIZE];
+
+	if (count > KERN_BUF_MAX_SIZE)
+		count = KERN_BUF_MAX_SIZE;
+
+	if (copy_from_user(kernel_buffer, buffer, count)) {
+		printk(KERN_WARNING "(tsmac_proc_write_vq): copy_from_user "
+		       "failed\n");
+		return -EFAULT;
+	}
+
+	/* copy data from kernel buffer to a tmp buff */
+	memcpy(tmpbuf, kernel_buffer, count);
+
+	if (sscanf(kernel_buffer, "%hhu/%hhu %hu", &cfg.vq_num,
+		   &cfg.vq_drop_disable, &cfg.vq_token_count) != 3) {
+		printk(KERN_WARNING "%s", tsmac_usage_vq);
+		return count;
+	}
+
+	/* validate vq number */
+	if (cfg.vq_num >= VQ_MAX) {
+		printk(KERN_WARNING "%s", tsmac_usage_vq);
+		return count;
+	}
+
+	if (cfg.vq_drop_disable != 0)
+		cfg.vq_drop_disable = 1;
+
+	iodata.data = &cfg;
+	ifr.ifr_data = &iodata;
+
+	tsmac_set_vq_config(dev, &ifr, TSMAC_KERNEL_DATA);
+	return count;
+}
+
+/*
+ * Callback for open method of seq_file interface
+ */
+static int tsmac_proc_read_txdesc_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, tsmac_proc_read_txdesc, PDE(inode)->data);
+}
+
+static int tsmac_proc_read_rxdesc_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, tsmac_proc_read_rxdesc, PDE(inode)->data);
+}
+
+/*
+ * Create and register the proc file entries
+ */
+void tsmac_create_proc_entries(struct net_device *dev)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+
+	/* general */
+	struct proc_dir_entry *proc_macaddr;
+	struct proc_dir_entry *proc_reg;
+	struct proc_dir_entry *proc_txdesc;
+	struct proc_dir_entry *proc_rxdesc;
+	struct proc_dir_entry *proc_stats;
+	struct proc_dir_entry *proc_mii;
+	struct proc_dir_entry *proc_iphdroffset;
+	struct proc_dir_entry *proc_pause_arc;
+	struct proc_dir_entry *proc_desc_size;
+	struct proc_dir_entry *proc_conntype;
+	struct proc_dir_entry *proc_phyaddr;
+	struct proc_dir_entry *proc_miitype;
+	struct proc_dir_entry *proc_linkmode;
+	struct proc_dir_entry *proc_taskcpu;
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+	struct proc_dir_entry *proc_loopback;
+#endif
+
+	/* for flood control */
+	struct proc_dir_entry *proc_egressprio;
+	struct proc_dir_entry *proc_default;
+	struct proc_dir_entry *proc_dump;
+	struct proc_dir_entry *proc_l2rule;
+	struct proc_dir_entry *proc_ethtypevlan;
+	struct proc_dir_entry *proc_ethtypeipv4;
+	struct proc_dir_entry *proc_ethtypeipv6;
+	struct proc_dir_entry *proc_ethtypeuser;
+	struct proc_dir_entry *proc_dropthreshold;
+	struct proc_dir_entry *proc_vq;
+
+	tsmac_proc[lp->unit].eth_dir = proc_mkdir(dev->name,
+						init_net.proc_net);
+
+	tsmac_proc[lp->unit].qos_dir = proc_mkdir("qos",
+						tsmac_proc[lp->unit].eth_dir);
+
+	tsmac_proc[lp->unit].classify_dir = proc_mkdir("classify",
+						       tsmac_proc[lp->unit].
+						       qos_dir);
+
+	tsmac_proc[lp->unit].provision_dir = proc_mkdir("provision",
+							tsmac_proc[lp->unit].
+							qos_dir);
+
+	create_proc_read_entry(TSMAC_PROC_INFO, TSMAC_PROC_PERM,
+			       tsmac_proc[lp->unit].eth_dir,
+			       tsmac_proc_read_info, dev);
+
+	proc_stats = create_proc_entry(TSMAC_PROC_STATS,
+				       TSMAC_PROC_PERM,
+				       tsmac_proc[lp->unit].eth_dir);
+	if (proc_stats) {
+		proc_stats->read_proc = tsmac_proc_read_stats;
+		proc_stats->write_proc = tsmac_proc_write_stats;
+		proc_stats->data = dev;
+	}
+
+	proc_macaddr = create_proc_entry(TSMAC_PROC_MACADDR, TSMAC_PROC_PERM,
+					 tsmac_proc[lp->unit].eth_dir);
+	if (proc_macaddr) {
+		proc_macaddr->read_proc = tsmac_proc_read_macaddr;
+		proc_macaddr->write_proc = tsmac_proc_write_macaddr;
+		proc_macaddr->data = dev;
+	}
+
+	proc_reg = create_proc_entry(TSMAC_PROC_REGCONTENTS, TSMAC_PROC_PERM,
+				     tsmac_proc[lp->unit].eth_dir);
+	if (proc_reg) {
+		proc_reg->read_proc = tsmac_proc_read_reg;
+		proc_reg->write_proc = tsmac_proc_write_reg;
+		proc_reg->data = dev;
+	}
+
+	proc_pause_arc = create_proc_entry(TSMAC_PROC_PAUSEARC,
+					   TSMAC_PROC_PERM,
+					   tsmac_proc[lp->unit].eth_dir);
+	if (proc_pause_arc) {
+		proc_pause_arc->read_proc = tsmac_proc_read_pause_arc;
+		proc_pause_arc->write_proc = tsmac_proc_write_pause_arc;
+		proc_pause_arc->data = dev;
+	}
+
+	proc_desc_size = create_proc_entry(TSMAC_PROC_DESCSIZE,
+					   TSMAC_PROC_PERM,
+					   tsmac_proc[lp->unit].eth_dir);
+	if (proc_desc_size) {
+		proc_desc_size->read_proc = tsmac_proc_read_desc_size;
+		proc_desc_size->write_proc = tsmac_proc_write_desc_size;
+		proc_desc_size->data = dev;
+	}
+
+	proc_txdesc = create_proc_entry(TSMAC_PROC_DUMPTX, TSMAC_PROC_PERM,
+					tsmac_proc[lp->unit].eth_dir);
+	if (proc_txdesc) {
+		proc_txdesc->proc_fops = &txdesc_fops;
+		proc_txdesc->data = dev;
+	}
+
+	proc_rxdesc = create_proc_entry(TSMAC_PROC_DUMPRX, TSMAC_PROC_PERM,
+					tsmac_proc[lp->unit].eth_dir);
+	if (proc_rxdesc) {
+		proc_rxdesc->proc_fops = &rxdesc_fops;
+		proc_rxdesc->data = dev;
+	}
+
+	proc_mii = create_proc_entry(TSMAC_PROC_MII, TSMAC_PROC_PERM,
+				     tsmac_proc[lp->unit].eth_dir);
+	if (proc_mii) {
+		proc_mii->read_proc = tsmac_proc_read_mii;
+		proc_mii->data = dev;
+	}
+
+	proc_egressprio = create_proc_entry(TSMAC_PROC_EGRESSPRIO,
+					    TSMAC_PROC_PERM,
+					    tsmac_proc[lp->unit].qos_dir);
+	if (proc_egressprio) {
+		proc_egressprio->read_proc = tsmac_proc_read_egressprio;
+		proc_egressprio->write_proc = tsmac_proc_write_egressprio;
+		proc_egressprio->data = dev;
+	}
+
+	proc_default = create_proc_entry(TSMAC_PROC_DEFAULT,
+					 TSMAC_PROC_PERM,
+					 tsmac_proc[lp->unit].classify_dir);
+	if (proc_default) {
+		proc_default->read_proc = tsmac_proc_read_default;
+		proc_default->write_proc = tsmac_proc_write_default;
+		proc_default->data = dev;
+	}
+
+	proc_dump = create_proc_entry(TSMAC_PROC_DUMP,
+				      TSMAC_PROC_PERM,
+				      tsmac_proc[lp->unit].classify_dir);
+	if (proc_dump) {
+		proc_dump->read_proc = tsmac_proc_read_dump;
+		proc_dump->write_proc = tsmac_proc_write_dump;
+		proc_dump->data = dev;
+	}
+
+	proc_l2rule = create_proc_entry(TSMAC_PROC_L2RULE,
+					TSMAC_PROC_PERM,
+					tsmac_proc[lp->unit].classify_dir);
+	if (proc_l2rule) {
+		proc_l2rule->read_proc = tsmac_proc_read_l2rule;
+		proc_l2rule->write_proc = tsmac_proc_write_l2rule;
+		proc_l2rule->data = dev;
+	}
+
+	proc_ethtypevlan = create_proc_entry(TSMAC_PROC_ETHTYPEVLAN,
+			TSMAC_PROC_PERM, tsmac_proc[lp->unit].classify_dir);
+	if (proc_ethtypevlan) {
+		proc_ethtypevlan->read_proc = tsmac_proc_read_ethtypevlan;
+		proc_ethtypevlan->write_proc = tsmac_proc_write_ethtypevlan;
+		proc_ethtypevlan->data = dev;
+	}
+
+	proc_ethtypeipv4 = create_proc_entry(TSMAC_PROC_ETHTYPEIPV4,
+		TSMAC_PROC_PERM, tsmac_proc[lp->unit].classify_dir);
+	if (proc_ethtypeipv4) {
+		proc_ethtypeipv4->read_proc = tsmac_proc_read_ethtypeipv4;
+		proc_ethtypeipv4->write_proc = tsmac_proc_write_ethtypeipv4;
+		proc_ethtypeipv4->data = dev;
+	}
+
+	proc_ethtypeipv6 = create_proc_entry(TSMAC_PROC_ETHTYPEIPV6,
+			TSMAC_PROC_PERM, tsmac_proc[lp->unit].classify_dir);
+	if (proc_ethtypeipv6) {
+		proc_ethtypeipv6->read_proc = tsmac_proc_read_ethtypeipv6;
+		proc_ethtypeipv6->write_proc = tsmac_proc_write_ethtypeipv6;
+		proc_ethtypeipv6->data = dev;
+	}
+
+	proc_ethtypeuser = create_proc_entry(TSMAC_PROC_ETHTYPEUSER,
+			TSMAC_PROC_PERM, tsmac_proc[lp->unit].classify_dir);
+	if (proc_ethtypeuser) {
+		proc_ethtypeuser->read_proc = tsmac_proc_read_ethtypeuser;
+		proc_ethtypeuser->write_proc = tsmac_proc_write_ethtypeuser;
+		proc_ethtypeuser->data = dev;
+	}
+
+	proc_dropthreshold = create_proc_entry(TSMAC_PROC_DROPTHRESHOLD,
+					       TSMAC_PROC_PERM,
+					       tsmac_proc[lp->unit].
+					       provision_dir);
+	if (proc_dropthreshold) {
+		proc_dropthreshold->read_proc = tsmac_proc_read_dropthreshold;
+		proc_dropthreshold->write_proc =
+					tsmac_proc_write_dropthreshold;
+		proc_dropthreshold->data = dev;
+	}
+
+	proc_vq = create_proc_entry(TSMAC_PROC_VQ, TSMAC_PROC_PERM,
+				    tsmac_proc[lp->unit].provision_dir);
+	if (proc_vq) {
+		proc_vq->read_proc = tsmac_proc_read_vq;
+		proc_vq->write_proc = tsmac_proc_write_vq;
+		proc_vq->data = dev;
+	}
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+	proc_loopback = create_proc_entry(TSMAC_PROC_LOOPBACK,
+					  TSMAC_PROC_PERM,
+					  tsmac_proc[lp->unit].eth_dir);
+	if (proc_loopback) {
+		proc_loopback->read_proc = tsmac_proc_read_lineloopback;
+		proc_loopback->write_proc = tsmac_proc_write_lineloopback;
+		proc_loopback->data = dev;
+	}
+#endif
+	proc_iphdroffset = create_proc_entry(TSMAC_PROC_IPHDROFFSET,
+					     TSMAC_PROC_PERM,
+					     tsmac_proc[lp->unit].eth_dir);
+	if (proc_iphdroffset) {
+		proc_iphdroffset->read_proc = tsmac_proc_read_iphdroffset;
+		proc_iphdroffset->write_proc = tsmac_proc_write_iphdroffset;
+		proc_iphdroffset->data = dev;
+	}
+
+	proc_conntype = create_proc_entry(TSMAC_PROC_CONNTYPE, TSMAC_PROC_PERM,
+					  tsmac_proc[lp->unit].eth_dir);
+	if (proc_conntype) {
+		proc_conntype->read_proc = tsmac_proc_read_conntype;
+		proc_conntype->write_proc = tsmac_proc_write_conntype;
+		proc_conntype->data = dev;
+	}
+
+	proc_phyaddr = create_proc_entry(TSMAC_PROC_PHYADDR,
+					 TSMAC_PROC_PERM,
+					 tsmac_proc[lp->unit].eth_dir);
+	if (proc_phyaddr) {
+		proc_phyaddr->read_proc = tsmac_proc_read_phyaddr;
+		proc_phyaddr->write_proc = tsmac_proc_write_phyaddr;
+		proc_phyaddr->data = dev;
+	}
+
+	proc_miitype = create_proc_entry(TSMAC_PROC_MIITYPE, TSMAC_PROC_PERM,
+					 tsmac_proc[lp->unit].eth_dir);
+	if (proc_miitype) {
+		proc_miitype->read_proc = tsmac_proc_read_miitype;
+		proc_miitype->write_proc = tsmac_proc_write_miitype;
+		proc_miitype->data = dev;
+	}
+
+	proc_linkmode = create_proc_entry(TSMAC_PROC_LINKMODE, TSMAC_PROC_PERM,
+					  tsmac_proc[lp->unit].eth_dir);
+	if (proc_linkmode) {
+		proc_linkmode->read_proc = tsmac_proc_read_linkmode;
+		proc_linkmode->data = dev;
+	}
+
+	proc_taskcpu = create_proc_entry(TSMAC_PROC_TASKCPU, TSMAC_PROC_PERM,
+					 tsmac_proc[lp->unit].eth_dir);
+	if (proc_taskcpu) {
+		proc_taskcpu->read_proc = tsmac_proc_read_taskcpu;
+		proc_taskcpu->write_proc = tsmac_proc_write_taskcpu;
+		proc_taskcpu->data = dev;
+	}
+
+	return;
+}
+
+/*
+ * Remove the proc file entries
+ */
+void tsmac_remove_proc_entries(void)
+{
+	char tmp_str[80];
+	int i;
+
+	for (i = 0; i < TSMAC_MAX_UNITS; i++) {
+		sprintf(tmp_str, "tsmac%d", i);
+
+		/* general */
+		remove_proc_entry(tmp_str, init_net.proc_net);
+		remove_proc_entry(TSMAC_PROC_INFO, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_CONNTYPE, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_STATS, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_DUMPRX, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_DUMPTX, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_MACADDR, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_REGCONTENTS,
+				  tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_MII, tsmac_proc[i].eth_dir);
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+		remove_proc_entry(TSMAC_PROC_LOOPBACK, tsmac_proc[i].eth_dir);
+#endif
+		remove_proc_entry(TSMAC_PROC_IPHDROFFSET,
+				  tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_PAUSEARC, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_DESCSIZE, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_PHYADDR, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_MIITYPE, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_LINKMODE, tsmac_proc[i].eth_dir);
+		remove_proc_entry(TSMAC_PROC_TASKCPU, tsmac_proc[i].eth_dir);
+
+		remove_proc_entry(TSMAC_PROC_EGRESSPRIO,
+				  tsmac_proc[i].qos_dir);
+		remove_proc_entry(TSMAC_PROC_DEFAULT,
+				  tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_L2RULE,
+				  tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_ETHTYPEVLAN,
+				  tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_ETHTYPEIPV4,
+				  tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_ETHTYPEIPV6,
+				  tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_ETHTYPEUSER,
+				  tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_DUMP, tsmac_proc[i].classify_dir);
+		remove_proc_entry(TSMAC_PROC_DROPTHRESHOLD,
+				  tsmac_proc[i].provision_dir);
+		remove_proc_entry(TSMAC_PROC_VQ, tsmac_proc[i].provision_dir);
+	}
+	return;
+}
+
+/*
+ * Performs interface-specific ioctl commands to configure and manage the
+ * Ethernet interfaces. READ and WRITE functions are using same command number
+ * but each is identifying independently with the help of sub command
+ */
+int tsmac_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct tsmac_private *lp = netdev_priv(dev);
+	struct tsmac_io_data *data = ifr->ifr_data;
+	int ret;
+
+	if (lp->conn_type == MSP_CT_MOCA) {
+
+		/* Handle MoCA ioctls */
+		switch (cmd) {
+		case SIOCDEVPRIVATE:
+			/* Reset */
+			ret = tsmac_moca_reset(dev, ifr, TSMAC_USER_DATA);
+			break;
+/* TODO : decide to remove or modify, this is for MoCA */
+#if 0
+		case SIOCGMIIREG:
+			/* PHY MII Read */
+			ret = tsmac_get_phy(dev, ifr, TSMAC_USER_DATA);
+			break;
+
+		case SIOCSMIIREG:
+			/* PHY MII Write */
+			ret = tsmac_set_phy(dev, ifr, TSMAC_USER_DATA);
+			break;
+
+		case SIOCGMIIPHY:
+			/* PHY MII ID */
+			ret = tsmac_get_phy_id(dev, ifr, TSMAC_USER_DATA);
+			break;
+#endif
+		default:
+			ret = -EOPNOTSUPP;
+		}
+
+	} else {
+
+		switch (cmd) {
+		case PMC_ETH_IOCMD_CLASSDEFVQ_READ:
+			if (data->subcmd)
+				ret = tsmac_get_default_vq_map(dev, ifr,
+							TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_default_vq_map(dev, ifr,
+							TSMAC_USER_DATA);
+			break;
+
+		case PMC_ETH_IOCMD_CLASSADDR_READ:
+			if (data->subcmd)
+				ret = tsmac_get_addr_class_rule(dev, ifr,
+							TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_addr_class_rule(dev, ifr,
+							TSMAC_USER_DATA);
+			break;
+
+#ifdef CONFIG_TSMAC_LINELOOPBACK_FEATURE
+		case PMC_ETH_IOCMD_LINELOOP_READ:
+			if (data->subcmd)
+				ret = tsmac_get_loopback(dev, ifr,
+							 TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_loopback(dev, ifr,
+							 TSMAC_USER_DATA);
+			break;
+#endif
+
+		case PMC_ETH_IOCMD_CLASSVLAN_READ:
+			if (data->subcmd)
+				ret = tsmac_get_vlan_class_rule(dev, ifr,
+							TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_vlan_class_rule(dev, ifr,
+							TSMAC_USER_DATA);
+			break;
+
+		case PMC_ETH_IOCMD_CLASS4DSCP_READ:
+			if (data->subcmd)
+				ret = tsmac_get_ip_class_rule(dev, ifr,
+							      TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_ip_class_rule(dev, ifr,
+							      TSMAC_USER_DATA);
+			break;
+
+		case PMC_ETH_IOCMD_CLASSETHTYPE_READ:
+			if (data->subcmd)
+				ret = tsmac_get_ethtype_class_rule(dev, ifr,
+							TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_ethtype_class_rule(dev, ifr,
+							TSMAC_USER_DATA);
+			break;
+
+		case PMC_ETH_IOCMD_PROVFIFO_READ:
+			if (data->subcmd)
+				ret = tsmac_get_drop_thresh(dev, ifr,
+							    TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_drop_thresh(dev, ifr,
+							    TSMAC_USER_DATA);
+			break;
+
+		case PMC_ETH_IOCMD_PROVVQ_READ:
+			if (data->subcmd)
+				ret = tsmac_get_vq_config(dev, ifr,
+							  TSMAC_USER_DATA);
+			else
+				ret = tsmac_set_vq_config(dev, ifr,
+							  TSMAC_USER_DATA);
+			break;
+
+		case PMC_ETH_IOCMD_QOSDEFAULT_WRITE:
+			tsmac_config_def_vqnpause(dev);
+			ret = tsmac_set_vqnpause(dev);
+			break;
+
+		default:
+			ret = -EOPNOTSUPP;
+		}
+	}
+
+	return ret;
+}
-- 
1.7.0.4
