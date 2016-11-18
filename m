From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: [RFC PATCH v2 1/2] macb: Add 1588 support in Cadence GEM.
Date: Fri, 18 Nov 2016 15:21:51 +0100
Message-ID: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>,
        <richardcochran@gmail.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
        <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cadence GEM provides a 102 bit time counter with 48 bits for seconds,
30 bits for nsecs and 24 bits for sub-nsecs to control 1588 timestamping.

This patch does the following:
- Registers to ptp clock framework
- Timer initialization is done by writing time of day to the timer counter.
- ns increment register is programmed as NSEC_PER_SEC/TSU_CLK.
  For a 16 bit subns precision, the subns increment equals
  remainder of (NS_PER_SEC/TSU_CLK) * (2^16).
- HW time stamp capabilities are advertised via ethtool and macb ioctl is
  updated accordingly.
- Timestamps are obtained from the TX/RX PTP event/PEER registers.
  The timestamp obtained thus is updated in skb for upper layers to access.
- The drivers register functions with ptp to perform time and frequency
  adjustment.
- Time adjustment is done by writing to the 1558_ADJUST register.
  The controller will read the delta in this register and update the timer
  counter register. Alternatively, for large time offset adjustments,
  the driver reads the secs and nsecs counter values, adds/subtracts the
  delta and updates the timer counter.
- Frequency adjustment is not directly supported by this IP.
  addend is the initial value ns increment and similarly addendesub.
  The ppb (parts per billion) provided is used as
  ns_incr = addend +/- (ppb/rate).
  Similarly the remainder of the above is used to populate subns increment.
  In case the ppb requested is negative AND subns adjustment greater than
  the addendsub, ns_incr is reduced by 1 and subns_incr is adjusted in
  positive accordingly.

Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
Version 2 patch for: https://patchwork.kernel.org/patch/9310989/.
Modifications:
- bitfields for TSU are named according to SAMA5D2 data sheet
- identify GEM-PTP support based on platform capability
- add spinlock for TSU access
- change macb_ptp_adjfreq and use fewer 64bit divisions

 drivers/net/ethernet/cadence/Kconfig    |  10 +-
 drivers/net/ethernet/cadence/Makefile   |   8 +-
 drivers/net/ethernet/cadence/macb.h     |  80 +++++++++++
 drivers/net/ethernet/cadence/macb_ptp.c | 229 ++++++++++++++++++++++++++++++++
 4 files changed, 325 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/cadence/macb_ptp.c

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index f0bcb15..ebbc65f 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -29,6 +29,14 @@ config MACB
 	  support for the MACB/GEM chip.
 
 	  To compile this driver as a module, choose M here: the module
-	  will be called macb.
+	  will be called cadence-macb.
+
+config MACB_USE_HWSTAMP
+	bool "Use IEEE 1588 hwstamp"
+	depends on MACB
+	default y
+	select PTP_1588_CLOCK
+	---help---
+	  Enable IEEE 1588 Precision Time Protocol (PTP) support for MACB.
 
 endif # NET_CADENCE
diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
index 91f79b1..4402d42 100644
--- a/drivers/net/ethernet/cadence/Makefile
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -2,4 +2,10 @@
 # Makefile for the Atmel network device drivers.
 #
 
-obj-$(CONFIG_MACB) += macb.o
+cadence-macb-y	:= macb.o
+
+ifeq ($(CONFIG_MACB_USE_HWSTAMP),y)
+cadence-macb-y	+= macb_ptp.o
+endif
+
+obj-$(CONFIG_MACB) += cadence-macb.o
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 3f385ab..2ee9af8 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -10,6 +10,10 @@
 #ifndef _MACB_H
 #define _MACB_H
 
+#include <linux/net_tstamp.h>
+#include <linux/ptp_clock.h>
+#include <linux/ptp_clock_kernel.h>
+
 #define MACB_GREGS_NBR 16
 #define MACB_GREGS_VERSION 2
 #define MACB_MAX_QUEUES 8
@@ -129,6 +133,20 @@
 #define GEM_RXIPCCNT		0x01a8 /* IP header Checksum Error Counter */
 #define GEM_RXTCPCCNT		0x01ac /* TCP Checksum Error Counter */
 #define GEM_RXUDPCCNT		0x01b0 /* UDP Checksum Error Counter */
+#define GEM_TISUBN		0x01bc /* 1588 Timer Increment Sub-ns */
+#define GEM_TSH			0x01c0 /* 1588 Timer Seconds High */
+#define GEM_TSL			0x01d0 /* 1588 Timer Seconds Low */
+#define GEM_TN			0x01d4 /* 1588 Timer Nanoseconds */
+#define GEM_TA			0x01d8 /* 1588 Timer Adjust */
+#define GEM_TI			0x01dc /* 1588 Timer Increment */
+#define GEM_EFTSL		0x01e0 /* PTP Event Frame Tx Seconds Low */
+#define GEM_EFTN		0x01e4 /* PTP Event Frame Tx Nanoseconds */
+#define GEM_EFRSL		0x01e8 /* PTP Event Frame Rx Seconds Low */
+#define GEM_EFRN		0x01ec /* PTP Event Frame Rx Nanoseconds */
+#define GEM_PEFTSL		0x01f0 /* PTP Peer Event Frame Tx Secs Low */
+#define GEM_PEFTN		0x01f4 /* PTP Peer Event Frame Tx Ns */
+#define GEM_PEFRSL		0x01f8 /* PTP Peer Event Frame Rx Sec Low */
+#define GEM_PEFRN		0x01fc /* PTP Peer Event Frame Rx Ns */
 #define GEM_DCFG1		0x0280 /* Design Config 1 */
 #define GEM_DCFG2		0x0284 /* Design Config 2 */
 #define GEM_DCFG3		0x0288 /* Design Config 3 */
@@ -171,6 +189,7 @@
 #define MACB_NCR_TPF_SIZE	1
 #define MACB_TZQ_OFFSET		12 /* Transmit zero quantum pause frame */
 #define MACB_TZQ_SIZE		1
+#define MACB_SRTSM_OFFSET	15
 
 /* Bitfields in NCFGR */
 #define MACB_SPD_OFFSET		0 /* Speed */
@@ -312,6 +331,36 @@
 #define MACB_PFR_SIZE		1
 #define MACB_PTZ_OFFSET		13 /* Enable pause time zero interrupt */
 #define MACB_PTZ_SIZE		1
+#define MACB_PFTR_OFFSET	14 /* Pause Frame Transmitted */
+#define MACB_PFTR_SIZE		1
+#define MACB_DRQFR_OFFSET	18 /* PTP Delay Request Frame Received */
+#define MACB_DRQFR_SIZE		1
+#define MACB_SFR_OFFSET		19 /* PTP Sync Frame Received */
+#define MACB_SFR_SIZE		1
+#define MACB_DRQFT_OFFSET	20 /* PTP Delay Request Frame Transmitted */
+#define MACB_DRQFT_SIZE		1
+#define MACB_SFT_OFFSET		21 /* PTP Sync Frame Transmitted */
+#define MACB_SFT_SIZE		1
+#define MACB_PDRQFR_OFFSET	22 /* PDelay Request Frame Received */
+#define MACB_PDRQFR_SIZE	1
+#define MACB_PDRSFR_OFFSET	23 /* PDelay Response Frame Received */
+#define MACB_PDRSFR_SIZE	1
+#define MACB_PDRQFT_OFFSET	24 /* PDelay Request Frame Transmitted */
+#define MACB_PDRQFT_SIZE	1
+#define MACB_PDRSFT_OFFSET	25 /* PDelay Response Frame Transmitted */
+#define MACB_PDRSFT_SIZE	1
+#define MACB_SRI_OFFSET		26 /* TSU Seconds Register Increment */
+#define MACB_SRI_SIZE		1
+#define MACB_WOL_OFFSET		28 /* Wake On LAN */
+#define MACB_WOL_SIZE		1
+
+/* Timer increment fields */
+#define MACB_TI_CNS_OFFSET	0
+#define MACB_TI_CNS_SIZE	8
+#define MACB_TI_ACNS_OFFSET	8
+#define MACB_TI_ACNS_SIZE	8
+#define MACB_TI_NIT_OFFSET	16
+#define MACB_TI_NIT_SIZE	8
 
 /* Bitfields in MAN */
 #define MACB_DATA_OFFSET	0 /* data */
@@ -375,6 +424,18 @@
 #define GEM_TX_PKT_BUFF_OFFSET			21
 #define GEM_TX_PKT_BUFF_SIZE			1
 
+/* Bitfields in TISUBN */
+#define GEM_SUBNSINCR_OFFSET			0
+#define GEM_SUBNSINCR_SIZE			16
+
+/* Bitfields in TI */
+#define GEM_NSINCR_OFFSET			0
+#define GEM_NSINCR_SIZE				8
+
+/* Bitfields in ADJ */
+#define GEM_ADDSUB_OFFSET			31
+#define GEM_ADDSUB_SIZE				1
+
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
@@ -405,6 +466,7 @@
 #define MACB_CAPS_SG_DISABLED			0x40000000
 #define MACB_CAPS_MACB_IS_GEM			0x80000000
 #define MACB_CAPS_JUMBO				0x00000010
+#define MACB_CAPS_GEM_HAS_PTP			0x00000020
 
 /* Bit manipulation macros */
 #define MACB_BIT(name)					\
@@ -840,8 +902,26 @@ struct macb {
 
 	unsigned int		rx_frm_len_mask;
 	unsigned int		jumbo_max_len;
+
+#ifdef CONFIG_MACB_USE_HWSTAMP
+	unsigned int		hwts_tx_en;
+	unsigned int		hwts_rx_en;
+	spinlock_t		tsu_clk_lock;
+	unsigned int		tsu_rate;
+
+	struct ptp_clock	*ptp_clock;
+	struct ptp_clock_info	ptp_caps;
+	unsigned int		ns_incr;
+	unsigned int		subns_incr;
+#endif
 };
 
+#ifdef CONFIG_MACB_USE_HWSTAMP
+void macb_ptp_init(struct net_device *ndev);
+#else
+void macb_ptp_init(struct net_device *ndev) { }
+#endif
+
 static inline bool macb_is_gem(struct macb *bp)
 {
 	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
new file mode 100644
index 0000000..81ce3a9
--- /dev/null
+++ b/drivers/net/ethernet/cadence/macb_ptp.c
@@ -0,0 +1,229 @@
+/*
+ * PTP 1588 clock for SAMA5D2 platform.
+ *
+ * Copyright (C) 2015 Xilinx Inc.
+ * Copyright (C) 2016 Microchip Technology
+ *
+ * Authors: Harini Katakam <harinik@xilinx.com>
+ *
+ * This file is licensed under the terms of the GNU General Public
+ * License version 2. This program is licensed "as is" without any
+ * warranty of any kind, whether express or implied.
+ */
+
+#include <linux/clk.h>
+#include <linux/device.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/time64.h>
+#include <linux/ptp_classify.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+
+#include "macb.h"
+
+#define  GMAC_TIMER_NAME "gmac-gem-ptp"
+
+static inline void macb_tsu_get_time(struct macb *bp, struct timespec64 *ts)
+{
+	u64 sec, sech, secl;
+
+	spin_lock(&bp->tsu_clk_lock);
+
+	/* get GEM internal time */
+	sech = gem_readl(bp, TSH);
+	secl = gem_readl(bp, TSL);
+	ts->tv_nsec = gem_readl(bp, TN);
+	ts->tv_sec = (sech << 32) | secl;
+
+	/* minimize the error */
+	sech = gem_readl(bp, TSH);
+	secl = gem_readl(bp, TSL);
+	sec = (sech << 32) | secl;
+	if (ts->tv_sec != sec) {
+		ts->tv_sec = sec;
+		ts->tv_nsec = gem_readl(bp, TN);
+	}
+
+	spin_unlock(&bp->tsu_clk_lock);
+}
+
+static inline void macb_tsu_set_time(struct macb *bp,
+				     const struct timespec64 *ts)
+{
+	u32 ns, sech, secl;
+	s64 word_mask = 0xffffffff;
+
+	sech = (u32)ts->tv_sec;
+	secl = (u32)ts->tv_sec;
+	ns = ts->tv_nsec;
+	if (ts->tv_sec > word_mask)
+		sech = (ts->tv_sec >> 32);
+
+	spin_lock(&bp->tsu_clk_lock);
+
+	/* TSH doesn't latch the time and no atomicity! */
+	gem_writel(bp, TSH, sech);
+	gem_writel(bp, TSL, secl);
+	gem_writel(bp, TN, ns);
+
+	spin_unlock(&bp->tsu_clk_lock);
+}
+
+static int macb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
+	u32 addend, addend_frac, rem;
+	u64 drift_tmr, diff, diff_frac = 0;
+	int neg_adj = 0;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+
+	/* drift/period */
+	drift_tmr = (bp->ns_incr * ppb) +
+		    ((bp->subns_incr * ppb) >> 16);
+
+	/* drift/cycle */
+	diff = div_u64_rem(drift_tmr, 1000000000ULL, &rem);
+
+	/* drift fraction/cycle, if necessary */
+	if (rem) {
+		u64 fraction = rem;
+		fraction = fraction << 16;
+
+		diff_frac = div_u64(fraction, 1000000000ULL);
+	}
+
+	/* adjustmets */
+	addend = neg_adj ? (bp->ns_incr - diff) : (bp->ns_incr + diff);
+	addend_frac = neg_adj ? (bp->subns_incr - diff_frac) :
+				(bp->subns_incr + diff_frac);
+
+	spin_lock(&bp->tsu_clk_lock);
+
+	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, addend_frac));
+	gem_writel(bp, TI, GEM_BF(NSINCR, addend));
+
+	spin_unlock(&bp->tsu_clk_lock);
+	return 0;
+}
+
+static int macb_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
+	struct timespec64 now, then = ns_to_timespec64(delta);
+	u32 adj, sign = 0;
+
+	if (delta < 0) {
+		delta = -delta;
+		sign = 1;
+	}
+
+	if (delta > 0x3FFFFFFF) {
+		macb_tsu_get_time(bp, &now);
+
+		if (sign)
+			now = timespec64_sub(now, then);
+		else
+			now = timespec64_add(now, then);
+
+		macb_tsu_set_time(bp, (const struct timespec64 *)&now);
+	} else {
+		adj = delta;
+		if (sign)
+			adj |= GEM_BIT(ADDSUB);
+
+		gem_writel(bp, TA, adj);
+	}
+
+	return 0;
+}
+
+static int macb_ptp_gettime(struct ptp_clock_info *ptp,
+			    struct timespec64 *ts)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
+
+	macb_tsu_get_time(bp, ts);
+
+	return 0;
+}
+
+static int macb_ptp_settime(struct ptp_clock_info *ptp,
+			    const struct timespec64 *ts)
+{
+	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
+
+	macb_tsu_set_time(bp, ts);
+
+	return 0;
+}
+
+static int macb_ptp_enable(struct ptp_clock_info *ptp,
+			   struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info macb_ptp_caps = {
+	.owner		= THIS_MODULE,
+	.name		= GMAC_TIMER_NAME,
+	.max_adj	= 250000000,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.n_pins		= 0,
+	.pps		= 0,
+	.adjfreq	= macb_ptp_adjfreq,
+	.adjtime	= macb_ptp_adjtime,
+	.gettime64	= macb_ptp_gettime,
+	.settime64	= macb_ptp_settime,
+	.enable		= macb_ptp_enable,
+};
+
+void macb_ptp_init(struct net_device *ndev)
+{
+	struct macb *bp = netdev_priv(ndev);
+	struct timespec64 now;
+	u32 rem = 0;
+
+	if (!(bp->caps | MACB_CAPS_GEM_HAS_PTP)){
+		netdev_vdbg(bp->dev, "Platform does not support PTP!\n");
+		return;
+	}
+
+	spin_lock_init(&bp->tsu_clk_lock);
+
+	bp->ptp_caps = macb_ptp_caps;
+	bp->tsu_rate = clk_get_rate(bp->pclk);
+
+	getnstimeofday64(&now);
+	macb_tsu_set_time(bp, (const struct timespec64 *)&now);
+
+	bp->ns_incr = div_u64_rem(NSEC_PER_SEC, bp->tsu_rate, &rem);
+	if (rem) {
+		u64 adj = rem;
+		/* Multiply by 2^16 as subns register is 16 bits */
+		adj <<= 16;
+		bp->subns_incr = div_u64(adj, bp->tsu_rate);
+	} else {
+		bp->subns_incr = 0;
+	}
+
+	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, bp->subns_incr));
+	gem_writel(bp, TI, GEM_BF(NSINCR, bp->ns_incr));
+	gem_writel(bp, TA, 0);
+
+	bp->ptp_clock = ptp_clock_register(&bp->ptp_caps, NULL);
+	if (IS_ERR(&bp->ptp_clock)) {
+		bp->ptp_clock = NULL;
+		pr_err("ptp clock register failed\n");
+		return;
+	}
+
+	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n", GMAC_TIMER_NAME);
+}
+
-- 
1.9.1
