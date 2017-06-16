From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH v3 4/4] net: macb: Add hardware PTP support
Date: Fri, 16 Jun 2017 13:01:51 +0100
Message-ID: <1497614511-22953-1-git-send-email-rafalo@cadence.com>
References: <1497614298-14074-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: David Miller <davem@davemloft.net>, <nicolas.ferre@atmel.com>,
        Richard Cochran <richardcochran@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <harini.katakam@xilinx.com>, <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497614298-14074-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is based on original Harini's patch and Andrei's patch,
implemented in a separate file to ease the review/maintanance
and integration with other platforms.

This driver supports GEM-GXL:
- Register ptp clock framework
- Initialize PTP related registers
- HW time stamp on the PTP Ethernet packets are received using the
  SO_TIMESTAMPING API. Time stamps are obtained from the dma buffer
  descriptors
- add macb_ptp to compilation chain

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
 drivers/net/ethernet/cadence/Makefile    |   4 +
 drivers/net/ethernet/cadence/macb.h      | 126 ++++++++
 drivers/net/ethernet/cadence/macb_main.c |  90 +++++-
 drivers/net/ethernet/cadence/macb_ptp.c  | 518 +++++++++++++++++++++++++++++++
 4 files changed, 732 insertions(+), 6 deletions(-)
 create mode 100755 drivers/net/ethernet/cadence/macb_ptp.c

diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
index 31ea6e3..1d66ddb 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -3,5 +3,9 @@
 #
 macb-y	:= macb_main.o
 
+ifeq ($(CONFIG_MACB_USE_HWSTAMP),y)
+macb-y	+= macb_ptp.o
+endif
+
 obj-$(CONFIG_MACB) += macb.o
 obj-$(CONFIG_MACB_PCI) += macb_pci.o
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 4359b08..4285daa6 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -11,6 +11,8 @@
 #define _MACB_H
 
 #include <linux/phy.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/net_tstamp.h>
 
 #if defined(CONFIG_ARCH_DMA_ADDR_T_64BIT) || defined(CONFIG_MACB_USE_HWSTAMP)
 #define MACB_EXT_DESC
@@ -90,6 +92,10 @@
 #define GEM_SA3T		0x009C /* Specific3 Top */
 #define GEM_SA4B		0x00A0 /* Specific4 Bottom */
 #define GEM_SA4T		0x00A4 /* Specific4 Top */
+#define GEM_EFTSH		0x00e8 /* PTP Event Frame Transmitted Seconds Register 47:32 */
+#define GEM_EFRSH		0x00ec /* PTP Event Frame Received Seconds Register 47:32 */
+#define GEM_PEFTSH		0x00f0 /* PTP Peer Event Frame Transmitted Seconds Register 47:32 */
+#define GEM_PEFRSH		0x00f4 /* PTP Peer Event Frame Received Seconds Register 47:32 */
 #define GEM_OTX			0x0100 /* Octets transmitted */
 #define GEM_OCTTXL		0x0100 /* Octets transmitted [31:0] */
 #define GEM_OCTTXH		0x0104 /* Octets transmitted [47:32] */
@@ -159,6 +165,9 @@
 #define GEM_DCFG6		0x0294 /* Design Config 6 */
 #define GEM_DCFG7		0x0298 /* Design Config 7 */
 
+#define GEM_TXBDCTRL	0x04cc /* TX Buffer Descriptor control register */
+#define GEM_RXBDCTRL	0x04d0 /* RX Buffer Descriptor control register */
+
 #define GEM_ISR(hw_q)		(0x0400 + ((hw_q) << 2))
 #define GEM_TBQP(hw_q)		(0x0440 + ((hw_q) << 2))
 #define GEM_TBQPH(hw_q)		(0x04C8)
@@ -195,6 +204,8 @@
 #define MACB_TZQ_OFFSET		12 /* Transmit zero quantum pause frame */
 #define MACB_TZQ_SIZE		1
 #define MACB_SRTSM_OFFSET	15
+#define MACB_OSSMODE_OFFSET 24 /* Enable One Step Synchro Mode */
+#define MACB_OSSMODE_SIZE	1
 
 /* Bitfields in NCFGR */
 #define MACB_SPD_OFFSET		0 /* Speed */
@@ -452,6 +463,52 @@
 #define GEM_NSINCR_OFFSET			0
 #define GEM_NSINCR_SIZE				8
 
+/* Bitfields in TSH */
+#define GEM_TSH_OFFSET				0 /* TSU timer value (s). MSB [47:32] of seconds timer count */
+#define GEM_TSH_SIZE				16
+
+/* Bitfields in TSL */
+#define GEM_TSL_OFFSET				0 /* TSU timer value (s). LSB [31:0] of seconds timer count */
+#define GEM_TSL_SIZE				32
+
+/* Bitfields in TN */
+#define GEM_TN_OFFSET				0 /* TSU timer value (ns) */
+#define GEM_TN_SIZE					30
+
+/* Bitfields in TXBDCTRL */
+#define GEM_TXTSMODE_OFFSET			4 /* TX Descriptor Timestamp Insertion mode */
+#define GEM_TXTSMODE_SIZE			2
+
+/* Bitfields in RXBDCTRL */
+#define GEM_RXTSMODE_OFFSET			4 /* RX Descriptor Timestamp Insertion mode */
+#define GEM_RXTSMODE_SIZE			2
+
+/* Transmit DMA buffer descriptor Word 1 */
+#define GEM_DMA_TXVALID_OFFSET		23 /* timestamp has been captured in the Buffer Descriptor */
+#define GEM_DMA_TXVALID_SIZE		1
+
+/* Receive DMA buffer descriptor Word 0 */
+#define GEM_DMA_RXVALID_OFFSET		2 /* indicates a valid timestamp in the Buffer Descriptor */
+#define GEM_DMA_RXVALID_SIZE		1
+
+/* DMA buffer descriptor Word 2 (32 bit addressing) or Word 4 (64 bit addressing) */
+#define GEM_DMA_SECL_OFFSET			30 /* Timestamp seconds[1:0]  */
+#define GEM_DMA_SECL_SIZE			2
+#define GEM_DMA_NSEC_OFFSET			0 /* Timestamp nanosecs [29:0] */
+#define GEM_DMA_NSEC_SIZE			30
+
+/* DMA buffer descriptor Word 3 (32 bit addressing) or Word 5 (64 bit addressing) */
+
+/* New hardware supports 12 bit precision of timestamp in DMA buffer descriptor.
+ * Old hardware supports only 6 bit precision but it is enough for PTP.
+ * Less accuracy is used always instead of checking hardware version.
+ */
+#define GEM_DMA_SECH_OFFSET			0 /* Timestamp seconds[5:2] */
+#define GEM_DMA_SECH_SIZE			4
+#define GEM_DMA_SEC_WIDTH			(GEM_DMA_SECH_SIZE + GEM_DMA_SECL_SIZE)
+#define GEM_DMA_SEC_TOP				(1 << GEM_DMA_SEC_WIDTH)
+#define GEM_DMA_SEC_MASK			(GEM_DMA_SEC_TOP - 1)
+
 /* Bitfields in ADJ */
 #define GEM_ADDSUB_OFFSET			31
 #define GEM_ADDSUB_SIZE				1
@@ -527,6 +584,8 @@
 #define queue_readl(queue, reg)		(queue)->bp->macb_reg_readl((queue)->bp, (queue)->reg)
 #define queue_writel(queue, reg, value)	(queue)->bp->macb_reg_writel((queue)->bp, (queue)->reg, (value))
 
+#define PTP_TS_BUFFER_SIZE		128 /* must be power of 2 */
+
 /* Conditional GEM/MACB macros.  These perform the operation to the correct
  * register dependent on whether the device is a GEM or a MACB.  For registers
  * and bitfields that are common across both devices, use macb_{read,write}l
@@ -574,6 +633,11 @@ struct macb_dma_desc_ptp {
 	u32	ts_1;
 	u32	ts_2;
 };
+
+struct gem_tx_ts {
+	struct sk_buff *skb;
+	struct macb_dma_desc_ptp desc_ptp;
+};
 #endif
 
 /* DMA descriptor bitfields */
@@ -889,6 +953,11 @@ struct macb_config {
 	int	jumbo_max_len;
 };
 
+struct tsu_incr {
+	u32 sub_ns;
+	u32 ns;
+};
+
 struct macb_queue {
 	struct macb		*bp;
 	int			irq;
@@ -905,6 +974,12 @@ struct macb_queue {
 	struct macb_tx_skb	*tx_skb;
 	dma_addr_t		tx_ring_dma;
 	struct work_struct	tx_error_task;
+
+#ifdef CONFIG_MACB_USE_HWSTAMP
+	struct work_struct	tx_ts_task;
+	unsigned int		tx_ts_head, tx_ts_tail;
+	struct gem_tx_ts	tx_timestamps[PTP_TS_BUFFER_SIZE];
+#endif
 };
 
 struct macb {
@@ -975,8 +1050,59 @@ struct macb {
 #ifdef MACB_EXT_DESC
 	uint8_t hw_dma_cap;
 #endif
+	spinlock_t tsu_clk_lock; /* gem tsu clock locking */
+	unsigned int tsu_rate;
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info ptp_clock_info;
+	struct tsu_incr tsu_incr;
+	struct hwtstamp_config tstamp_config;
 };
 
+#ifdef CONFIG_MACB_USE_HWSTAMP
+#define GEM_TSEC_SIZE  (GEM_TSH_SIZE + GEM_TSL_SIZE)
+#define TSU_SEC_MAX_VAL (((u64)1 << GEM_TSEC_SIZE) - 1)
+#define TSU_NSEC_MAX_VAL ((1 << GEM_TN_SIZE) - 1)
+
+enum macb_bd_control {
+	TSTAMP_DISABLED,
+	TSTAMP_FRAME_PTP_EVENT_ONLY,
+	TSTAMP_ALL_PTP_FRAMES,
+	TSTAMP_ALL_FRAMES,
+};
+
+void gem_ptp_init(struct net_device *ndev);
+void gem_ptp_remove(struct net_device *ndev);
+int gem_ptp_txstamp(struct macb_queue *queue, struct sk_buff *skb, struct macb_dma_desc *des);
+void gem_ptp_rxstamp(struct macb *bp, struct sk_buff *skb, struct macb_dma_desc *desc);
+static inline int gem_ptp_do_txstamp(struct macb_queue *queue, struct sk_buff *skb, struct macb_dma_desc *desc)
+{
+	if (queue->bp->tstamp_config.tx_type == TSTAMP_DISABLED)
+		return -ENOTSUPP;
+
+	return gem_ptp_txstamp(queue, skb, desc);
+}
+
+static inline void gem_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb, struct macb_dma_desc *desc)
+{
+	if (bp->tstamp_config.rx_filter == TSTAMP_DISABLED)
+		return;
+
+	gem_ptp_rxstamp(bp, skb, desc);
+}
+int gem_get_hwtst(struct net_device *dev, struct ifreq *rq);
+int gem_set_hwtst(struct net_device *dev, struct ifreq *ifr, int cmd);
+#else
+static inline void gem_ptp_init(struct net_device *ndev) { }
+static inline void gem_ptp_remove(struct net_device *ndev) { }
+
+static inline int gem_ptp_do_txstamp(struct macb_queue *queue, struct sk_buff *skb, struct macb_dma_desc *desc)
+{
+	return -1;
+}
+
+static inline void gem_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb, struct macb_dma_desc *desc) { }
+#endif
+
 static inline bool macb_is_gem(struct macb *bp)
 {
 	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index 3151429..2437d42 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -828,6 +828,12 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 
 			/* First, update TX stats if needed */
 			if (skb) {
+				if (gem_ptp_do_txstamp(queue, skb, desc) == 0) {
+					/* skb now belongs to timestamp buffer
+					 * and will be removed later
+					 */
+					tx_skb->skb = NULL;
+				}
 				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
 					    macb_tx_ring_wrap(bp, tail),
 					    skb->data);
@@ -994,6 +1000,8 @@ static int gem_rx(struct macb *bp, int budget)
 		bp->dev->stats.rx_packets++;
 		bp->dev->stats.rx_bytes += skb->len;
 
+		gem_ptp_do_rxstamp(bp, skb, desc);
+
 #if defined(DEBUG) && defined(VERBOSE_DEBUG)
 		netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
 			    skb->len, skb->csum);
@@ -1315,7 +1323,6 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
 				queue_writel(queue, ISR, MACB_BIT(HRESP));
 		}
-
 		status = queue_readl(queue, ISR);
 	}
 
@@ -1645,7 +1652,6 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Make newly initialized descriptor visible to hardware */
 	wmb();
-
 	skb_tx_timestamp(skb);
 
 	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
@@ -2503,6 +2509,70 @@ static int macb_set_ringparam(struct net_device *netdev,
 	return 0;
 }
 
+#ifdef CONFIG_MACB_USE_HWSTAMP
+static unsigned int gem_get_tsu_rate(struct macb *bp)
+{
+	struct clk *tsu_clk;
+	unsigned int tsu_rate;
+
+	tsu_clk = devm_clk_get(&bp->pdev->dev, "tsu_clk");
+	if (!IS_ERR(tsu_clk))
+		tsu_rate = clk_get_rate(tsu_clk);
+	/* try pclk instead */
+	else if (!IS_ERR(bp->pclk)) {
+		tsu_clk = bp->pclk;
+		tsu_rate = clk_get_rate(tsu_clk);
+	} else
+		return -ENOTSUPP;
+	return tsu_rate;
+}
+
+static s32 gem_get_ptp_max_adj(void)
+{
+	return 64000000;
+}
+
+static int gem_get_ts_info(struct net_device *dev,
+			   struct ethtool_ts_info *info)
+{
+	struct macb *bp = netdev_priv(dev);
+
+	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0) {
+		ethtool_op_get_ts_info(dev, info);
+		return 0;
+	}
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE |
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->tx_types =
+		(1 << HWTSTAMP_TX_ONESTEP_SYNC) |
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_ALL);
+
+	info->phc_index = bp->ptp_clock ? ptp_clock_index(bp->ptp_clock) : -1;
+
+	return 0;
+}
+
+static struct macb_ptp_info gem_ptp_info = {
+	.ptp_init	 = gem_ptp_init,
+	.ptp_remove	 = gem_ptp_remove,
+	.get_ptp_max_adj = gem_get_ptp_max_adj,
+	.get_tsu_rate	 = gem_get_tsu_rate,
+	.get_ts_info	 = gem_get_ts_info,
+	.get_hwtst	 = gem_get_hwtst,
+	.set_hwtst	 = gem_set_hwtst,
+};
+#endif
+
 static int macb_get_ts_info(struct net_device *netdev,
 			    struct ethtool_ts_info *info)
 {
@@ -2636,12 +2706,16 @@ static void macb_configure_caps(struct macb *bp,
 		dcfg = gem_readl(bp, DCFG2);
 		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) == 0)
 			bp->caps |= MACB_CAPS_FIFO_MODE;
-		if (IS_ENABLED(CONFIG_MACB_USE_HWSTAMP) && gem_has_ptp(bp)) {
+#ifdef CONFIG_MACB_USE_HWSTAMP
+		if (gem_has_ptp(bp)) {
 			if (!GEM_BFEXT(TSU, gem_readl(bp, DCFG5)))
 				pr_err("GEM doesn't support hardware ptp.\n");
-			else
+			else {
 				bp->hw_dma_cap |= HW_DMA_CAP_PTP;
+				bp->ptp_info = &gem_ptp_info;
+			}
 		}
+#endif
 	}
 
 	dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps);
@@ -3247,7 +3321,9 @@ static const struct macb_config np4_config = {
 };
 
 static const struct macb_config zynqmp_config = {
-	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
+	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE |
+			MACB_CAPS_JUMBO |
+			MACB_CAPS_GEM_HAS_PTP,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
@@ -3281,7 +3357,9 @@ MODULE_DEVICE_TABLE(of, macb_dt_ids);
 #endif /* CONFIG_OF */
 
 static const struct macb_config default_gem_config = {
-	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
+	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE |
+			MACB_CAPS_JUMBO |
+			MACB_CAPS_GEM_HAS_PTP,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
new file mode 100755
index 0000000..67cca08
--- /dev/null
+++ b/drivers/net/ethernet/cadence/macb_ptp.c
@@ -0,0 +1,518 @@
+/**
+ * 1588 PTP support for Cadence GEM device.
+ *
+ * Copyright (C) 2017 Cadence Design Systems - http://www.cadence.com
+ *
+ * Authors: Rafal Ozieblo <rafalo@cadence.com>
+ *          Bartosz Folta <bfolta@cadence.com>
+ *
+ * This program is free software: you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2  of
+ * the License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/clk.h>
+#include <linux/device.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/time64.h>
+#include <linux/ptp_classify.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/net_tstamp.h>
+#include <linux/circ_buf.h>
+#include <linux/spinlock.h>
+
+#include "macb.h"
+
+#define  GEM_PTP_TIMER_NAME "gem-ptp-timer"
+
+static struct macb_dma_desc_ptp *macb_ptp_desc(struct macb *bp,
+					       struct macb_dma_desc *desc)
+{
+	if (bp->hw_dma_cap == HW_DMA_CAP_PTP)
+		return (struct macb_dma_desc_ptp *)
+				((u8 *)desc + sizeof(struct macb_dma_desc));
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B_PTP)
+		return (struct macb_dma_desc_ptp *)
+				((u8 *)desc + sizeof(struct macb_dma_desc)
+				+ sizeof(struct macb_dma_desc_64));
+	return NULL;
+}
+
+static int gem_tsu_get_time(struct ptp_clock_info *ptp, struct timespec64 *ts)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
+	unsigned long flags;
+	long first, second;
+	u32 secl, sech;
+
+	spin_lock_irqsave(&bp->tsu_clk_lock, flags);
+	first = gem_readl(bp, TN);
+	secl = gem_readl(bp, TSL);
+	sech = gem_readl(bp, TSH);
+	second = gem_readl(bp, TN);
+
+	/* test for nsec rollover */
+	if (first > second) {
+		/* if so, use later read & re-read seconds
+		 * (assume all done within 1s)
+		 */
+		ts->tv_nsec = gem_readl(bp, TN);
+		secl = gem_readl(bp, TSL);
+		sech = gem_readl(bp, TSH);
+	} else {
+		ts->tv_nsec = first;
+	}
+
+	spin_unlock_irqrestore(&bp->tsu_clk_lock, flags);
+	ts->tv_sec = (((u64)sech << GEM_TSL_SIZE) | secl)
+			& TSU_SEC_MAX_VAL;
+	return 0;
+}
+
+static int gem_tsu_set_time(struct ptp_clock_info *ptp,
+			    const struct timespec64 *ts)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
+	unsigned long flags;
+	u32 ns, sech, secl;
+
+	secl = (u32)ts->tv_sec;
+	sech = (ts->tv_sec >> GEM_TSL_SIZE) & ((1 << GEM_TSH_SIZE) - 1);
+	ns = ts->tv_nsec;
+
+	spin_lock_irqsave(&bp->tsu_clk_lock, flags);
+
+	/* TSH doesn't latch the time and no atomicity! */
+	gem_writel(bp, TN, 0); /* clear to avoid overflow */
+	gem_writel(bp, TSH, sech);
+	/* write lower bits 2nd, for synchronized secs update */
+	gem_writel(bp, TSL, secl);
+	gem_writel(bp, TN, ns);
+
+	spin_unlock_irqrestore(&bp->tsu_clk_lock, flags);
+
+	return 0;
+}
+
+static int gem_tsu_incr_set(struct macb *bp, struct tsu_incr *incr_spec)
+{
+	unsigned long flags;
+
+	/* tsu_timer_incr register must be written after
+	 * the tsu_timer_incr_sub_ns register and the write operation
+	 * will cause the value written to the tsu_timer_incr_sub_ns register
+	 * to take effect.
+	 */
+	spin_lock_irqsave(&bp->tsu_clk_lock, flags);
+	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, incr_spec->sub_ns));
+	gem_writel(bp, TI, GEM_BF(NSINCR, incr_spec->ns));
+	spin_unlock_irqrestore(&bp->tsu_clk_lock, flags);
+
+	return 0;
+}
+
+static int gem_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
+	struct tsu_incr incr_spec;
+	bool neg_adj = false;
+	u32 word;
+	u64 adj;
+
+	if (scaled_ppm < 0) {
+		neg_adj = true;
+		scaled_ppm = -scaled_ppm;
+	}
+
+	/* Adjustment is relative to base frequency */
+	incr_spec.sub_ns = bp->tsu_incr.sub_ns;
+	incr_spec.ns = bp->tsu_incr.ns;
+
+	/* scaling: unused(8bit) | ns(8bit) | fractions(16bit) */
+	word = ((u64)incr_spec.ns << GEM_SUBNSINCR_SIZE) + incr_spec.sub_ns;
+	adj = (u64)scaled_ppm * word;
+	/* Divide with rounding, equivalent to floating dividing:
+	 * (temp / USEC_PER_SEC) + 0.5
+	 */
+	adj += (USEC_PER_SEC >> 1);
+	adj >>= GEM_SUBNSINCR_SIZE; /* remove fractions */
+	adj = div_u64(adj, USEC_PER_SEC);
+	adj = neg_adj ? (word - adj) : (word + adj);
+
+	incr_spec.ns = (adj >> GEM_SUBNSINCR_SIZE)
+			& ((1 << GEM_NSINCR_SIZE) - 1);
+	incr_spec.sub_ns = adj & ((1 << GEM_SUBNSINCR_SIZE) - 1);
+	gem_tsu_incr_set(bp, &incr_spec);
+	return 0;
+}
+
+static int gem_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_clock_info);
+	struct timespec64 now, then = ns_to_timespec64(delta);
+	u32 adj, sign = 0;
+
+	if (delta < 0) {
+		sign = 1;
+		delta = -delta;
+	}
+
+	if (delta > TSU_NSEC_MAX_VAL) {
+		gem_tsu_get_time(&bp->ptp_clock_info, &now);
+		if (sign)
+			now = timespec64_sub(now, then);
+		else
+			now = timespec64_add(now, then);
+
+		gem_tsu_set_time(&bp->ptp_clock_info,
+				 (const struct timespec64 *)&now);
+	} else {
+		adj = (sign << GEM_ADDSUB_OFFSET) | delta;
+
+		gem_writel(bp, TA, adj);
+	}
+
+	return 0;
+}
+
+static int gem_ptp_enable(struct ptp_clock_info *ptp,
+			  struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info gem_ptp_caps_template = {
+	.owner		= THIS_MODULE,
+	.name		= GEM_PTP_TIMER_NAME,
+	.max_adj	= 0,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.n_pins		= 0,
+	.pps		= 1,
+	.adjfine	= gem_ptp_adjfine,
+	.adjtime	= gem_ptp_adjtime,
+	.gettime64	= gem_tsu_get_time,
+	.settime64	= gem_tsu_set_time,
+	.enable		= gem_ptp_enable,
+};
+
+static void gem_ptp_init_timer(struct macb *bp)
+{
+	u32 rem = 0;
+	u64 adj;
+
+	bp->tsu_incr.ns = div_u64_rem(NSEC_PER_SEC, bp->tsu_rate, &rem);
+	if (rem) {
+		adj = rem;
+		adj <<= GEM_SUBNSINCR_SIZE;
+		bp->tsu_incr.sub_ns = div_u64(adj, bp->tsu_rate);
+	} else {
+		bp->tsu_incr.sub_ns = 0;
+	}
+}
+
+static void gem_ptp_init_tsu(struct macb *bp)
+{
+	struct timespec64 ts;
+
+	/* 1. get current system time */
+	ts = ns_to_timespec64(ktime_to_ns(ktime_get_real()));
+
+	/* 2. set ptp timer */
+	gem_tsu_set_time(&bp->ptp_clock_info, &ts);
+
+	/* 3. set PTP timer increment value to BASE_INCREMENT */
+	gem_tsu_incr_set(bp, &bp->tsu_incr);
+
+	gem_writel(bp, TA, 0);
+}
+
+static void gem_ptp_clear_timer(struct macb *bp)
+{
+	bp->tsu_incr.sub_ns = 0;
+	bp->tsu_incr.ns = 0;
+
+	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, 0));
+	gem_writel(bp, TI, GEM_BF(NSINCR, 0));
+	gem_writel(bp, TA, 0);
+}
+
+static int gem_hw_timestamp(struct macb *bp, u32 dma_desc_ts_1,
+			    u32 dma_desc_ts_2, struct timespec64 *ts)
+{
+	struct timespec64 tsu;
+
+	ts->tv_sec = (GEM_BFEXT(DMA_SECH, dma_desc_ts_2) << GEM_DMA_SECL_SIZE) |
+			GEM_BFEXT(DMA_SECL, dma_desc_ts_1);
+	ts->tv_nsec = GEM_BFEXT(DMA_NSEC, dma_desc_ts_1);
+
+	/* TSU overlapping workaround
+	 * The timestamp only contains lower few bits of seconds,
+	 * so add value from 1588 timer
+	 */
+	gem_tsu_get_time(&bp->ptp_clock_info, &tsu);
+
+	/* If the top bit is set in the timestamp,
+	 * but not in 1588 timer, it has rolled over,
+	 * so subtract max size
+	 */
+	if ((ts->tv_sec & (GEM_DMA_SEC_TOP >> 1)) &&
+	    !(tsu.tv_sec & (GEM_DMA_SEC_TOP >> 1)))
+		ts->tv_sec -= GEM_DMA_SEC_TOP;
+
+	ts->tv_sec += ((~GEM_DMA_SEC_MASK) & tsu.tv_sec);
+
+	return 0;
+}
+
+void gem_ptp_rxstamp(struct macb *bp, struct sk_buff *skb,
+		     struct macb_dma_desc *desc)
+{
+	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+	struct macb_dma_desc_ptp *desc_ptp;
+	struct timespec64 ts;
+
+	if (GEM_BFEXT(DMA_RXVALID, desc->addr)) {
+		desc_ptp = macb_ptp_desc(bp, desc);
+		gem_hw_timestamp(bp, desc_ptp->ts_1, desc_ptp->ts_2, &ts);
+		memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
+		shhwtstamps->hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
+	}
+}
+
+static void gem_tstamp_tx(struct macb *bp, struct sk_buff *skb,
+			  struct macb_dma_desc_ptp *desc_ptp)
+{
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct timespec64 ts;
+
+	gem_hw_timestamp(bp, desc_ptp->ts_1, desc_ptp->ts_2, &ts);
+	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+	shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
+	skb_tstamp_tx(skb, &shhwtstamps);
+}
+
+int gem_ptp_txstamp(struct macb_queue *queue, struct sk_buff *skb,
+		    struct macb_dma_desc *desc)
+{
+	unsigned long tail = READ_ONCE(queue->tx_ts_tail);
+	unsigned long head = queue->tx_ts_head;
+	struct macb_dma_desc_ptp *desc_ptp;
+	struct gem_tx_ts *tx_timestamp;
+
+	if (!GEM_BFEXT(DMA_TXVALID, desc->ctrl))
+		return -EINVAL;
+
+	if (CIRC_SPACE(head, tail, PTP_TS_BUFFER_SIZE) == 0)
+		return -ENOMEM;
+
+	skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+	desc_ptp = macb_ptp_desc(queue->bp, desc);
+	tx_timestamp = &queue->tx_timestamps[head];
+	tx_timestamp->skb = skb;
+	tx_timestamp->desc_ptp.ts_1 = desc_ptp->ts_1;
+	tx_timestamp->desc_ptp.ts_2 = desc_ptp->ts_2;
+	/* move head */
+	smp_store_release(&queue->tx_ts_head,
+			  (head + 1) & (PTP_TS_BUFFER_SIZE - 1));
+
+	schedule_work(&queue->tx_ts_task);
+	return 0;
+}
+
+static void gem_tx_timestamp_flush(struct work_struct *work)
+{
+	struct macb_queue *queue =
+			container_of(work, struct macb_queue, tx_ts_task);
+	unsigned long head, tail;
+	struct gem_tx_ts *tx_ts;
+
+	/* take current head */
+	head = smp_load_acquire(&queue->tx_ts_head);
+	tail = queue->tx_ts_tail;
+
+	while (CIRC_CNT(head, tail, PTP_TS_BUFFER_SIZE)) {
+		tx_ts = &queue->tx_timestamps[tail];
+		gem_tstamp_tx(queue->bp, tx_ts->skb, &tx_ts->desc_ptp);
+		/* cleanup */
+		dev_kfree_skb_any(tx_ts->skb);
+		/* remove old tail */
+		smp_store_release(&queue->tx_ts_tail,
+				  (tail + 1) & (PTP_TS_BUFFER_SIZE - 1));
+		tail = queue->tx_ts_tail;
+	}
+}
+
+void gem_ptp_init(struct net_device *dev)
+{
+	struct macb *bp = netdev_priv(dev);
+	struct macb_queue *queue;
+	unsigned int q;
+
+	bp->ptp_clock_info = gem_ptp_caps_template;
+
+	/* nominal frequency and maximum adjustment in ppb */
+	bp->tsu_rate = bp->ptp_info->get_tsu_rate(bp);
+	bp->ptp_clock_info.max_adj = bp->ptp_info->get_ptp_max_adj();
+	gem_ptp_init_timer(bp);
+	bp->ptp_clock = ptp_clock_register(&bp->ptp_clock_info, &dev->dev);
+	if (IS_ERR(bp->ptp_clock)) {
+		pr_err("ptp clock register failed: %ld\n",
+			PTR_ERR(bp->ptp_clock));
+		bp->ptp_clock = NULL;
+		return;
+	} else if (bp->ptp_clock == NULL) {
+		pr_err("ptp clock register failed\n");
+		return;
+	}
+
+	spin_lock_init(&bp->tsu_clk_lock);
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		queue->tx_ts_head = 0;
+		queue->tx_ts_tail = 0;
+		INIT_WORK(&queue->tx_ts_task, gem_tx_timestamp_flush);
+	}
+
+	gem_ptp_init_tsu(bp);
+
+	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n",
+		 GEM_PTP_TIMER_NAME);
+}
+
+void gem_ptp_remove(struct net_device *ndev)
+{
+	struct macb *bp = netdev_priv(ndev);
+
+	if (bp->ptp_clock)
+		ptp_clock_unregister(bp->ptp_clock);
+
+	gem_ptp_clear_timer(bp);
+
+	dev_info(&bp->pdev->dev, "%s ptp clock unregistered.\n",
+		 GEM_PTP_TIMER_NAME);
+}
+
+static int gem_ptp_set_ts_mode(struct macb *bp,
+			       enum macb_bd_control tx_bd_control,
+			       enum macb_bd_control rx_bd_control)
+{
+	gem_writel(bp, TXBDCTRL, GEM_BF(TXTSMODE, tx_bd_control));
+	gem_writel(bp, RXBDCTRL, GEM_BF(RXTSMODE, rx_bd_control));
+
+	return 0;
+}
+
+int gem_get_hwtst(struct net_device *dev, struct ifreq *rq)
+{
+	struct hwtstamp_config *tstamp_config;
+	struct macb *bp = netdev_priv(dev);
+
+	tstamp_config = &bp->tstamp_config;
+	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0)
+		return -EOPNOTSUPP;
+
+	if (copy_to_user(rq->ifr_data, tstamp_config, sizeof(*tstamp_config)))
+		return -EFAULT;
+	else
+		return 0;
+}
+
+static int gem_ptp_set_one_step_sync(struct macb *bp, u8 enable)
+{
+	u32 reg_val;
+
+	reg_val = macb_readl(bp, NCR);
+
+	if (enable)
+		macb_writel(bp, NCR, reg_val | MACB_BIT(OSSMODE));
+	else
+		macb_writel(bp, NCR, reg_val & ~MACB_BIT(OSSMODE));
+
+	return 0;
+}
+
+int gem_set_hwtst(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	enum macb_bd_control tx_bd_control = TSTAMP_DISABLED;
+	enum macb_bd_control rx_bd_control = TSTAMP_DISABLED;
+	struct hwtstamp_config *tstamp_config;
+	struct macb *bp = netdev_priv(dev);
+	u32 regval;
+
+	tstamp_config = &bp->tstamp_config;
+	if ((bp->hw_dma_cap & HW_DMA_CAP_PTP) == 0)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(tstamp_config, ifr->ifr_data,
+			   sizeof(*tstamp_config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (tstamp_config->flags)
+		return -EINVAL;
+
+	switch (tstamp_config->tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+	case HWTSTAMP_TX_ONESTEP_SYNC:
+		if (gem_ptp_set_one_step_sync(bp, 1) != 0)
+			return -ERANGE;
+	case HWTSTAMP_TX_ON:
+		tx_bd_control = TSTAMP_ALL_FRAMES;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (tstamp_config->rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		rx_bd_control =  TSTAMP_ALL_PTP_FRAMES;
+		tstamp_config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		regval = macb_readl(bp, NCR);
+		macb_writel(bp, NCR, (regval | MACB_BIT(SRTSM)));
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_ALL:
+		rx_bd_control = TSTAMP_ALL_FRAMES;
+		tstamp_config->rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		tstamp_config->rx_filter = HWTSTAMP_FILTER_NONE;
+		return -ERANGE;
+	}
+
+	if (gem_ptp_set_ts_mode(bp, tx_bd_control, rx_bd_control) != 0)
+		return -ERANGE;
+
+	if (copy_to_user(ifr->ifr_data, tstamp_config, sizeof(*tstamp_config)))
+		return -EFAULT;
+	else
+		return 0;
+}
+
-- 
2.4.5
