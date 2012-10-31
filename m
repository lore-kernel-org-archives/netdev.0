From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 4/4] FEC: Add time stamping code and a PTP hardware clock
Date: Wed, 31 Oct 2012 12:25:31 +0800
Message-ID: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznua@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:6721
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220Ab2JaFIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 01:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a driver for the FEC(MX6) that offers time
stamping and a PTP haderware clock. Because FEC\ENET(MX6)
hardware frequency adjustment is complex, we have implemented
this in software by changing the multiplication factor of the
timecounter.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig   |    9 +
 drivers/net/ethernet/freescale/Makefile  |    1 +
 drivers/net/ethernet/freescale/fec.c     |   88 +++++++-
 drivers/net/ethernet/freescale/fec.h     |   38 +++
 drivers/net/ethernet/freescale/fec_ptp.c |  386 ++++++++++++++++++++++++++++++
 5 files changed, 521 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/fec_ptp.c

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index feff516..ff3be53 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -92,4 +92,13 @@ config GIANFAR
 	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
 	  and MPC86xx family of chips, and the FEC on the 8540.
 
+config FEC_PTP
+	bool "PTP Hardware Clock (PHC)"
+	depends on FEC
+	select PPS
+	select PTP_1588_CLOCK
+	--help---
+	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
+	  driver.  Only the basic clock operations have been implemented.
+
 endif # NET_VENDOR_FREESCALE
diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
index 3d1839a..d4d19b3 100644
--- a/drivers/net/ethernet/freescale/Makefile
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -3,6 +3,7 @@
 #
 
 obj-$(CONFIG_FEC) += fec.o
+obj-$(CONFIG_FEC_PTP) += fec_ptp.o
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index d0e1b33..2665162 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -280,6 +280,17 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
 	bdp->cbd_sc = status;
 
+#ifdef CONFIG_FEC_PTP
+	bdp->cbd_bdu = 0;
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
+			fep->hwts_tx_en)) {
+			bdp->cbd_esc = (BD_ENET_TX_TS | BD_ENET_TX_INT);
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+	} else {
+
+		bdp->cbd_esc = BD_ENET_TX_INT;
+	}
+#endif
 	/* Trigger transmission start */
 	writel(0, fep->hwp + FEC_X_DES_ACTIVE);
 
@@ -437,10 +448,17 @@ fec_restart(struct net_device *ndev, int duplex)
 		writel(1 << 8, fep->hwp + FEC_X_WMRK);
 	}
 
+#ifdef CONFIG_FEC_PTP
+	ecntl |= (1 << 4);
+#endif
+
 	/* And last, enable the transmit and receive processing */
 	writel(ecntl, fep->hwp + FEC_ECNTRL);
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
+#ifdef CONFIG_FEC_PTP
+	fec_ptp_start_cyclecounter(ndev);
+#endif
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 }
@@ -526,6 +544,19 @@ fec_enet_tx(struct net_device *ndev)
 			ndev->stats.tx_packets++;
 		}
 
+#ifdef CONFIG_FEC_PTP
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
+			struct skb_shared_hwtstamps shhwtstamps;
+			unsigned long flags;
+
+			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+			spin_lock_irqsave(&fep->tmreg_lock, flags);
+			shhwtstamps.hwtstamp = ns_to_ktime(
+				timecounter_cyc2time(&fep->tc, bdp->ts));
+			spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+			skb_tstamp_tx(skb, &shhwtstamps);
+		}
+#endif
 		if (status & BD_ENET_TX_READY)
 			printk("HEY! Enet xmit interrupt and TX_READY.\n");
 
@@ -652,6 +683,21 @@ fec_enet_rx(struct net_device *ndev)
 			skb_put(skb, pkt_len - 4);	/* Make room */
 			skb_copy_to_linear_data(skb, data, pkt_len - 4);
 			skb->protocol = eth_type_trans(skb, ndev);
+#ifdef CONFIG_FEC_PTP
+			/* Get receive timestamp from the skb */
+			if (fep->hwts_rx_en) {
+				struct skb_shared_hwtstamps *shhwtstamps =
+							    skb_hwtstamps(skb);
+				unsigned long flags;
+
+				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+
+				spin_lock_irqsave(&fep->tmreg_lock, flags);
+				shhwtstamps->hwtstamp = ns_to_ktime(
+				    timecounter_cyc2time(&fep->tc, bdp->ts));
+				spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+			}
+#endif
 			if (!skb_defer_rx_timestamp(skb))
 				netif_rx(skb);
 		}
@@ -666,6 +712,12 @@ rx_processing_done:
 		status |= BD_ENET_RX_EMPTY;
 		bdp->cbd_sc = status;
 
+#ifdef CONFIG_FEC_PTP
+		bdp->cbd_esc = BD_ENET_RX_INT;
+		bdp->cbd_prot = 0;
+		bdp->cbd_bdu = 0;
+#endif
+
 		/* Update BD pointer to next entry */
 		if (status & BD_ENET_RX_WRAP)
 			bdp = fep->rx_bd_base;
@@ -1105,6 +1157,10 @@ static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
+#ifdef CONFIG_FEC_PTP
+	if (cmd == SIOCSHWTSTAMP)
+		return fec_ptp_ioctl(ndev, rq, cmd);
+#endif
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
@@ -1151,6 +1207,9 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		bdp->cbd_sc = BD_ENET_RX_EMPTY;
+#ifdef CONFIG_FEC_PTP
+		bdp->cbd_esc = BD_ENET_RX_INT;
+#endif
 		bdp++;
 	}
 
@@ -1164,6 +1223,10 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
+
+#ifdef CONFIG_FEC_PTP
+		bdp->cbd_esc = BD_ENET_RX_INT;
+#endif
 		bdp++;
 	}
 
@@ -1565,9 +1628,19 @@ fec_probe(struct platform_device *pdev)
 		goto failed_clk;
 	}
 
+#ifdef CONFIG_FEC_PTP
+	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
+	if (IS_ERR(fep->clk_ptp)) {
+		ret = PTR_ERR(fep->clk_ptp);
+		goto failed_clk;
+	}
+#endif
+
 	clk_prepare_enable(fep->clk_ahb);
 	clk_prepare_enable(fep->clk_ipg);
-
+#ifdef CONFIG_FEC_PTP
+	clk_prepare_enable(fep->clk_ptp);
+#endif
 	reg_phy = devm_regulator_get(&pdev->dev, "phy");
 	if (!IS_ERR(reg_phy)) {
 		ret = regulator_enable(reg_phy);
@@ -1595,6 +1668,10 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
+#ifdef CONFIG_FEC_PTP
+	fec_ptp_init(ndev, pdev);
+#endif
+
 	return 0;
 
 failed_register:
@@ -1604,6 +1681,9 @@ failed_init:
 failed_regulator:
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
+#ifdef CONFIG_FEC_PTP
+	clk_disable_unprepare(fep->clk_ptp);
+#endif
 failed_pin:
 failed_clk:
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
@@ -1636,6 +1716,12 @@ fec_drv_remove(struct platform_device *pdev)
 		if (irq > 0)
 			free_irq(irq, ndev);
 	}
+#ifdef CONFIG_FEC_PTP
+	del_timer_sync(&fep->time_keep);
+	clk_disable_unprepare(fep->clk_ptp);
+	if (fep->ptp_clock)
+		ptp_clock_unregister(fep->ptp_clock);
+#endif
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 	iounmap(fep->hwp);
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index e803812..c5a3bc1 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -13,6 +13,12 @@
 #define	FEC_H
 /****************************************************************************/
 
+#ifdef CONFIG_FEC_PTP
+#include <linux/clocksource.h>
+#include <linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
+#endif
+
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
     defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
     defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
@@ -88,6 +94,13 @@ struct bufdesc {
 	unsigned short cbd_datlen;	/* Data length */
 	unsigned short cbd_sc;	/* Control and status info */
 	unsigned long cbd_bufaddr;	/* Buffer address */
+#ifdef CONFIG_FEC_PTP
+	unsigned long cbd_esc;
+	unsigned long cbd_prot;
+	unsigned long cbd_bdu;
+	unsigned long ts;
+	unsigned short res0[4];
+#endif
 };
 #else
 struct bufdesc {
@@ -190,6 +203,9 @@ struct fec_enet_private {
 
 	struct clk *clk_ipg;
 	struct clk *clk_ahb;
+#ifdef CONFIG_FEC_PTP
+	struct clk *clk_ptp;
+#endif
 
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
 	unsigned char *tx_bounce[TX_RING_SIZE];
@@ -227,7 +243,29 @@ struct fec_enet_private {
 	int	full_duplex;
 	struct	completion mdio_done;
 	int	irq[FEC_IRQ_NUM];
+
+#ifdef CONFIG_FEC_PTP
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info ptp_caps;
+	unsigned long last_overflow_check;
+	spinlock_t tmreg_lock;
+	struct cyclecounter cc;
+	struct timecounter tc;
+	int rx_hwtstamp_filter;
+	u32 base_incval;
+	u32 cycle_speed;
+	int hwts_rx_en;
+	int hwts_tx_en;
+	struct timer_list time_keep;
+#endif
+
 };
 
+#ifdef CONFIG_FEC_PTP
+void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
+void fec_ptp_start_cyclecounter(struct net_device *ndev);
+int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd);
+#endif
+
 /****************************************************************************/
 #endif /* FEC_H */
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
new file mode 100644
index 0000000..9b91da9
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -0,0 +1,386 @@
+/*
+ * Fast Ethernet Controller (ENET) PTP driver for MX6x.
+ *
+ * Copyright (C) 2012 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/ptrace.h>
+#include <linux/errno.h>
+#include <linux/ioport.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/bitops.h>
+#include <linux/io.h>
+#include <linux/irq.h>
+#include <linux/clk.h>
+#include <linux/platform_device.h>
+#include <linux/phy.h>
+#include <linux/fec.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_gpio.h>
+#include <linux/of_net.h>
+
+#include "fec.h"
+
+/* FEC 1588 register bits */
+#define FEC_T_CTRL_SLAVE                0x00002000
+#define FEC_T_CTRL_CAPTURE              0x00000800
+#define FEC_T_CTRL_RESTART              0x00000200
+#define FEC_T_CTRL_PERIOD_RST           0x00000030
+#define FEC_T_CTRL_PERIOD_EN		0x00000010
+#define FEC_T_CTRL_ENABLE               0x00000001
+
+#define FEC_T_INC_MASK                  0x0000007f
+#define FEC_T_INC_OFFSET                0
+#define FEC_T_INC_CORR_MASK             0x00007f00
+#define FEC_T_INC_CORR_OFFSET           8
+
+#define FEC_ATIME_CTRL		0x400
+#define FEC_ATIME		0x404
+#define FEC_ATIME_EVT_OFFSET	0x408
+#define FEC_ATIME_EVT_PERIOD	0x40c
+#define FEC_ATIME_CORR		0x410
+#define FEC_ATIME_INC		0x414
+#define FEC_TS_TIMESTAMP	0x418
+
+#define FEC_CC_MULT	(1 << 31)
+/**
+ * fec_ptp_read - read raw cycle counter (to be used by time counter)
+ * @cc: the cyclecounter structure
+ *
+ * this function reads the cyclecounter registers and is called by the
+ * cyclecounter structure used to construct a ns counter from the
+ * arbitrary fixed point registers
+ */
+static cycle_t fec_ptp_read(const struct cyclecounter *cc)
+{
+	struct fec_enet_private *fep =
+		container_of(cc, struct fec_enet_private, cc);
+	u32 tempval;
+
+	tempval = readl(fep->hwp + FEC_ATIME_CTRL);
+	tempval |= FEC_T_CTRL_CAPTURE;
+	writel(tempval, fep->hwp + FEC_ATIME_CTRL);
+
+	return readl(fep->hwp + FEC_ATIME);
+}
+
+/**
+ * fec_ptp_start_cyclecounter - create the cycle counter from hw
+ * @ndev: network device
+ *
+ * this function initializes the timecounter and cyclecounter
+ * structures for use in generated a ns counter from the arbitrary
+ * fixed point cycles registers in the hardware.
+ */
+void fec_ptp_start_cyclecounter(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	unsigned long flags;
+	int inc;
+
+	inc = 1000000000 / clk_get_rate(fep->clk_ptp);
+
+	/* grab the ptp lock */
+	spin_lock_irqsave(&fep->tmreg_lock, flags);
+
+	/* 1ns counter */
+	writel(inc << FEC_T_INC_OFFSET, fep->hwp + FEC_ATIME_INC);
+
+	/* use free running count */
+	writel(0, fep->hwp + FEC_ATIME_EVT_PERIOD);
+
+	writel(FEC_T_CTRL_ENABLE, fep->hwp + FEC_ATIME_CTRL);
+
+	memset(&fep->cc, 0, sizeof(fep->cc));
+	fep->cc.read = fec_ptp_read;
+	fep->cc.mask = CLOCKSOURCE_MASK(32);
+	fep->cc.shift = 31;
+	fep->cc.mult = FEC_CC_MULT;
+
+	/* reset the ns time counter */
+	timecounter_init(&fep->tc, &fep->cc, ktime_to_ns(ktime_get_real()));
+
+	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+}
+
+/**
+ * fec_ptp_adjfreq - adjust ptp cycle frequency
+ * @ptp: the ptp clock structure
+ * @ppb: parts per billion adjustment from base
+ *
+ * Adjust the frequency of the ptp cycle counter by the
+ * indicated ppb from the base frequency.
+ *
+ * Because ENET hardware frequency adjust is complex,
+ * using software method to do that.
+ */
+static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	u64 diff;
+	unsigned long flags;
+	int neg_adj = 0;
+
+	struct fec_enet_private *fep =
+	    container_of(ptp, struct fec_enet_private, ptp_caps);
+
+	if (ppb < 0) {
+		ppb = -ppb;
+		neg_adj = 1;
+	}
+
+	spin_lock_irqsave(&fep->tmreg_lock, flags);
+	/*
+	 * dummy read to set cycle_last in tc to now.
+	 * So use adjusted mult to calculate when next call
+	 * timercounter_read.
+	 */
+	timecounter_read(&fep->tc);
+	fep->cc.mult = FEC_CC_MULT;
+	diff = fep->cc.mult;
+	diff *= ppb;
+	diff = div_u64(diff, 1000000000ULL);
+
+	if (neg_adj)
+		fep->cc.mult -= diff;
+	else
+		fep->cc.mult += diff;
+
+	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+
+	return 0;
+}
+
+/**
+ * fec_ptp_adjtime
+ * @ptp: the ptp clock structure
+ * @delta: offset to adjust the cycle counter by
+ *
+ * adjust the timer by resetting the timecounter structure.
+ */
+static int fec_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct fec_enet_private *fep =
+	    container_of(ptp, struct fec_enet_private, ptp_caps);
+	unsigned long flags;
+	u64 now;
+
+	spin_lock_irqsave(&fep->tmreg_lock, flags);
+
+	now = timecounter_read(&fep->tc);
+	now += delta;
+
+	/* reset the timecounter */
+	timecounter_init(&fep->tc, &fep->cc, now);
+
+	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+
+	return 0;
+}
+
+/**
+ * fec_ptp_gettime
+ * @ptp: the ptp clock structure
+ * @ts: timespec structure to hold the current time value
+ *
+ * read the timecounter and return the correct value on ns,
+ * after converting it into a struct timespec.
+ */
+static int fec_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	struct fec_enet_private *adapter =
+	    container_of(ptp, struct fec_enet_private, ptp_caps);
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+
+	spin_lock_irqsave(&adapter->tmreg_lock, flags);
+	ns = timecounter_read(&adapter->tc);
+	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
+	ts->tv_nsec = remainder;
+
+	return 0;
+}
+
+/**
+ * fec_ptp_settime
+ * @ptp: the ptp clock structure
+ * @ts: the timespec containing the new time for the cycle counter
+ *
+ * reset the timecounter to use a new base value instead of the kernel
+ * wall timer value.
+ */
+static int fec_ptp_settime(struct ptp_clock_info *ptp,
+			   const struct timespec *ts)
+{
+	struct fec_enet_private *fep =
+	    container_of(ptp, struct fec_enet_private, ptp_caps);
+
+	u64 ns;
+	unsigned long flags;
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&fep->tmreg_lock, flags);
+	timecounter_init(&fep->tc, &fep->cc, ns);
+	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+	return 0;
+}
+
+/**
+ * fec_ptp_enable
+ * @ptp: the ptp clock structure
+ * @rq: the requested feature to change
+ * @on: whether to enable or disable the feature
+ *
+ */
+static int fec_ptp_enable(struct ptp_clock_info *ptp,
+			  struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * fec_ptp_hwtstamp_ioctl - control hardware time stamping
+ * @ndev: pointer to net_device
+ * @ifreq: ioctl data
+ * @cmd: particular ioctl requested
+ */
+int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	struct hwtstamp_config config;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		fep->hwts_tx_en = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		fep->hwts_tx_en = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		if (fep->hwts_rx_en)
+			fep->hwts_rx_en = 0;
+		config.rx_filter = HWTSTAMP_FILTER_NONE;
+		break;
+
+	default:
+		/*
+		 * register RXMTRL must be set in order to do V1 packets,
+		 * therefore it is not possible to time stamp both V1 Sync and
+		 * Delay_Req messages and hardware does not support
+		 * timestamping all packets => return error
+		 */
+		fep->hwts_rx_en = 1;
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	}
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+	    -EFAULT : 0;
+}
+
+/**
+ * fec_time_keep - call timecounter_read every second to avoid timer overrun
+ *                 because ENET just support 32bit counter, will timeout in 4s
+ */
+static void fec_time_keep(unsigned long _data)
+{
+	struct fec_enet_private *fep = (struct fec_enet_private *)_data;
+	u64 ns;
+	unsigned long flags;
+
+	spin_lock_irqsave(&fep->tmreg_lock, flags);
+	ns = timecounter_read(&fep->tc);
+	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+
+	mod_timer(&fep->time_keep, jiffies + HZ);
+}
+
+/**
+ * fec_ptp_init
+ * @ndev: The FEC network adapter
+ *
+ * This function performs the required steps for enabling ptp
+ * support. If ptp support has already been loaded it simply calls the
+ * cyclecounter init routine and exits.
+ */
+
+void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	fep->ptp_caps.owner = THIS_MODULE;
+	snprintf(fep->ptp_caps.name, 16, "fec ptp");
+
+	fep->ptp_caps.max_adj = 250000000;
+	fep->ptp_caps.n_alarm = 0;
+	fep->ptp_caps.n_ext_ts = 0;
+	fep->ptp_caps.n_per_out = 0;
+	fep->ptp_caps.pps = 0;
+	fep->ptp_caps.adjfreq = fec_ptp_adjfreq;
+	fep->ptp_caps.adjtime = fec_ptp_adjtime;
+	fep->ptp_caps.gettime = fec_ptp_gettime;
+	fep->ptp_caps.settime = fec_ptp_settime;
+	fep->ptp_caps.enable = fec_ptp_enable;
+
+	spin_lock_init(&fep->tmreg_lock);
+
+	fec_ptp_start_cyclecounter(ndev);
+
+	init_timer(&fep->time_keep);
+	fep->time_keep.data = (unsigned long)fep;
+	fep->time_keep.function = fec_time_keep;
+	fep->time_keep.expires = jiffies + HZ;
+	add_timer(&fep->time_keep);
+
+	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
+	if (IS_ERR(fep->ptp_clock)) {
+		fep->ptp_clock = NULL;
+		pr_err("ptp_clock_register failed\n");
+	} else {
+		pr_info("registered PHC device on %s\n", ndev->name);
+	}
+}
+
-- 
1.7.1
