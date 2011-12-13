From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/2] igb: add PTP Hardware Clock code
Date: Tue, 13 Dec 2011 04:00:34 +0100
Message-ID: <382db16df224b31b126f26f0671cb5f67904e834.1323744725.git.richardcochran@gmail.com>
References: <cover.1323744724.git.richardcochran@gmail.com>
Cc: e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46590 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101Ab1LMDAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 22:00:48 -0500
Received: by eaaj10 with SMTP id j10so933152eaa.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 19:00:46 -0800 (PST)
In-Reply-To: <cover.1323744724.git.richardcochran@gmail.com>
In-Reply-To: <cover.1323744724.git.richardcochran@gmail.com>
References: <cover.1323744724.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a source file implementing a PHC. Only the basic
clock operations have been implemented, although the hardware
would offer some ancillary functions. The code is fairly self
contained and is not yet used in the main igb driver.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb.h     |    8 +
 drivers/net/ethernet/intel/igb/igb_ptp.c |  408 ++++++++++++++++++++++++++++++
 2 files changed, 416 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index c69feeb..001f95d 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -37,6 +37,7 @@
 #include <linux/clocksource.h>
 #include <linux/timecompare.h>
 #include <linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
 
@@ -364,6 +365,13 @@ struct igb_adapter {
 	u32 wvbr;
 	int node;
 	u32 *shadow_vfta;
+
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info caps;
+	struct delayed_work overflow_work;
+	spinlock_t tmreg_lock;
+	u32 overflow_counter;
+	int last_msb;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
new file mode 100644
index 0000000..7a9f6bc
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -0,0 +1,408 @@
+/*
+ * PTP Hardware Clock (PHC) driver for the Intel 82576 and 82580
+ *
+ * Copyright (C) 2011 Richard Cochran <richardcochran@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+#include <linux/device.h>
+#include <linux/pci.h>
+
+#include "igb.h"
+
+#define INCVALUE_MASK		0x7fffffff
+#define ISGN			0x80000000
+#define SYSTIMH_MSB_82576	0x80000000
+#define SYSTIMH_MSB_82580	0x00000080
+
+/*
+ * Neither the 82576 nor the 82580 offer registers wide enough to hold
+ * nanoseconds time values for very long. For the 82580, SYSTIM always
+ * counts nanoseconds, but the upper 24 bits are not availible. The
+ * frequency is adjusted by changing the 32 bit fractional nanoseconds
+ * register, TIMINCA.
+ *
+ * For the 82576, the SYSTIM register time unit is affect by the
+ * choice of the 24 bit TININCA:IV (incvalue) field. Five bits of this
+ * field are needed to provide the nominal 16 nanosecond period,
+ * leaving 19 bits for fractional nanoseconds.
+ *
+ *
+ *             SYSTIMH            SYSTIML
+ *        +--------------+   +---+---+------+
+ *  82576 |      32      |   | 8 | 5 |  19  |
+ *        +--------------+   +---+---+------+
+ *         \________ 45 bits _______/  fract
+ *
+ *        +----------+---+   +--------------+
+ *  82580 |    24    | 8 |   |      32      |
+ *        +----------+---+   +--------------+
+ *          reserved  \______ 40 bits _____/
+ *
+ *
+ * The 45 bit 82576 SYSTIM overflows every
+ *   2^45 * 10^-9 / 3600 = 9.77 hours.
+ *
+ * The 40 bit 82580 SYSTIM overflows every
+ *   2^40 * 10^-9 /  60  = 18.3 minutes.
+ *
+ * We implement a 32 bit overflow counter in software to hold the
+ * missing 19 or 24 bits, for a combined virtual nanosecond time
+ * register of 64 bits.
+ */
+
+#define IGB_OVERFLOW_PERIOD	(HZ * 60 * 5)
+#define INCPERIOD_82576		(1 << E1000_TIMINCA_16NS_SHIFT)
+#define INCVALUE_82576_MASK	((1 << E1000_TIMINCA_16NS_SHIFT) - 1)
+#define INCVALUE_82576		(16 << IGB_82576_TSYNC_SHIFT)
+#define OFL_SHIFT_82580		40
+#define OFL_SHIFT_82576		45
+#define NS_SHIFT_82576		IGB_82576_TSYNC_SHIFT
+
+/*
+ * Overflow counter for the SYSTIM register.
+ */
+
+static u64 igb_overflow_get(struct igb_adapter *igb, u64 low, int msb_set,
+			    unsigned int shift)
+{
+	if (igb->last_msb && !msb_set)
+		igb->overflow_counter++;
+
+	igb->last_msb = msb_set;
+
+	low |= ((u64) igb->overflow_counter) << shift;
+
+	return low;
+}
+
+static void igb_overflow_set(struct igb_adapter *igb, u64 ns, int msb_set,
+			     unsigned int shift)
+{
+	igb->overflow_counter = ns >> shift;
+	igb->last_msb = msb_set;
+}
+
+/*
+ * SYSTIM / overflow access functions for the 82576
+ */
+
+static u64 igb_82576_systim_read(struct igb_adapter *igb)
+{
+	u64 ns;
+	u32 lo, hi;
+	struct e1000_hw *hw = &igb->hw;
+
+	lo = rd32(E1000_SYSTIML);
+	hi = rd32(E1000_SYSTIMH);
+
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	ns >>= NS_SHIFT_82576;
+
+	ns = igb_overflow_get(igb, ns, hi & SYSTIMH_MSB_82576, OFL_SHIFT_82576);
+
+	return ns;
+}
+
+static void igb_82576_systim_write(struct igb_adapter *igb, u64 ns)
+{
+	u32 hi, lo;
+	struct e1000_hw *hw = &igb->hw;
+
+	hi = (ns >> 8) & 0xffffffff;
+	lo = (ns & 0xff) << NS_SHIFT_82576;
+
+	wr32(E1000_SYSTIML, lo);
+	wr32(E1000_SYSTIMH, hi);
+
+	igb_overflow_set(igb, ns, hi & SYSTIMH_MSB_82576, OFL_SHIFT_82576);
+}
+
+/*
+ * SYSTIM / overflow access functions for the 82580
+ */
+
+static u64 igb_82580_systim_read(struct igb_adapter *igb)
+{
+	u64 ns;
+	u32 lo, hi, jk;
+	struct e1000_hw *hw = &igb->hw;
+
+	jk = rd32(E1000_SYSTIMR);
+	lo = rd32(E1000_SYSTIML);
+	hi = rd32(E1000_SYSTIMH);
+
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+
+	ns = igb_overflow_get(igb, ns, hi & SYSTIMH_MSB_82580, OFL_SHIFT_82580);
+
+	return ns;
+}
+
+static void igb_82580_systim_write(struct igb_adapter *igb, u64 ns)
+{
+	u32 hi, lo;
+	struct e1000_hw *hw = &igb->hw;
+
+	hi = ns >> 32;
+	lo = ns & 0xffffffff;
+
+	wr32(E1000_SYSTIMR, 0);
+	wr32(E1000_SYSTIML, lo);
+	wr32(E1000_SYSTIMH, hi & 0xff);
+
+	igb_overflow_set(igb, ns, hi & SYSTIMH_MSB_82580, OFL_SHIFT_82580);
+}
+
+/*
+ * SYSTIM / overflow register access functions
+ * Callers must hold tmreg_lock.
+ */
+
+static u64 igb_systim_read(struct igb_adapter *igb)
+{
+	switch (igb->hw.mac.type) {
+	case e1000_i350:
+	case e1000_82580:
+		return igb_82580_systim_read(igb);
+	case e1000_82576:
+		return igb_82576_systim_read(igb);
+	default:
+		return 0;
+	}
+}
+
+static void igb_systim_write(struct igb_adapter *igb, u64 ns)
+{
+	switch (igb->hw.mac.type) {
+	case e1000_i350:
+	case e1000_82580:
+		igb_82580_systim_write(igb, ns);
+		break;
+	case e1000_82576:
+		igb_82576_systim_write(igb, ns);
+		break;
+	default:
+		break;
+	}
+}
+
+/*
+ * PTP clock operations
+ */
+
+static int ptp_82576_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	u64 rate;
+	u32 incvalue;
+	int neg_adj = 0;
+	struct igb_adapter *igb = container_of(ptp, struct igb_adapter, caps);
+	struct e1000_hw *hw = &igb->hw;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	rate = ppb;
+	rate <<= 14;
+	rate = div_u64(rate, 1953125);
+
+	incvalue = 16 << IGB_82576_TSYNC_SHIFT;
+
+	if (neg_adj)
+		incvalue -= rate;
+	else
+		incvalue += rate;
+
+	wr32(E1000_TIMINCA, INCPERIOD_82576 | (incvalue & INCVALUE_82576_MASK));
+
+	return 0;
+}
+
+static int ptp_82580_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	u64 rate;
+	u32 inca;
+	int neg_adj = 0;
+	struct igb_adapter *igb = container_of(ptp, struct igb_adapter, caps);
+	struct e1000_hw *hw = &igb->hw;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	rate = ppb;
+	rate <<= 26;
+	rate = div_u64(rate, 1953125);
+
+	inca = rate & INCVALUE_MASK;
+	if (neg_adj)
+		inca |= ISGN;
+
+	wr32(E1000_TIMINCA, inca);
+
+	return 0;
+}
+
+static int igb_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	s64 now;
+	unsigned long flags;
+	struct igb_adapter *igb = container_of(ptp, struct igb_adapter, caps);
+
+	spin_lock_irqsave(&igb->tmreg_lock, flags);
+
+	now = igb_systim_read(igb);
+	now += delta;
+	igb_systim_write(igb, now);
+
+	spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+
+	return 0;
+}
+
+static int igb_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+	struct igb_adapter *igb = container_of(ptp, struct igb_adapter, caps);
+
+	spin_lock_irqsave(&igb->tmreg_lock, flags);
+
+	ns = igb_systim_read(igb);
+
+	spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+
+	return 0;
+}
+
+static int igb_settime(struct ptp_clock_info *ptp, const struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct igb_adapter *igb = container_of(ptp, struct igb_adapter, caps);
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&igb->tmreg_lock, flags);
+
+	igb_systim_write(igb, ns);
+
+	spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+
+	return 0;
+}
+
+static int ptp_82576_enable(struct ptp_clock_info *ptp,
+			    struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static int ptp_82580_enable(struct ptp_clock_info *ptp,
+			    struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static void igb_overflow_check(struct work_struct *work)
+{
+	struct timespec ts;
+	struct igb_adapter *igb =
+		container_of(work, struct igb_adapter, overflow_work.work);
+
+	igb_gettime(&igb->caps, &ts);
+
+	pr_debug("igb overflow check at %ld.%09lu\n", ts.tv_sec, ts.tv_nsec);
+
+	schedule_delayed_work(&igb->overflow_work, IGB_OVERFLOW_PERIOD);
+}
+
+void igb_ptp_init(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	switch (hw->mac.type) {
+	case e1000_i350:
+	case e1000_82580:
+		adapter->caps.owner	= THIS_MODULE;
+		strcpy(adapter->caps.name, "igb-82580");
+		adapter->caps.max_adj	= 62499999;
+		adapter->caps.n_ext_ts	= 0;
+		adapter->caps.pps	= 0;
+		adapter->caps.adjfreq	= ptp_82580_adjfreq;
+		adapter->caps.adjtime	= igb_adjtime;
+		adapter->caps.gettime	= igb_gettime;
+		adapter->caps.settime	= igb_settime;
+		adapter->caps.enable	= ptp_82580_enable;
+		/* Enable the timer functions. */
+		wr32(E1000_TSAUXC, 0x0);
+		break;
+
+	case e1000_82576:
+		adapter->caps.owner	= THIS_MODULE;
+		strcpy(adapter->caps.name, "igb-82576");
+		adapter->caps.max_adj	= 1000000000;
+		adapter->caps.n_ext_ts	= 0;
+		adapter->caps.pps	= 0;
+		adapter->caps.adjfreq	= ptp_82576_adjfreq;
+		adapter->caps.adjtime	= igb_adjtime;
+		adapter->caps.gettime	= igb_gettime;
+		adapter->caps.settime	= igb_settime;
+		adapter->caps.enable	= ptp_82576_enable;
+		/* Dial the nominal frequency. */
+		wr32(E1000_TIMINCA, INCPERIOD_82576 | INCVALUE_82576);
+		break;
+
+	default:
+		adapter->ptp_clock = NULL;
+		return;
+	}
+
+	wrfl();
+
+	INIT_DELAYED_WORK(&adapter->overflow_work, igb_overflow_check);
+
+	spin_lock_init(&adapter->tmreg_lock);
+
+	adapter->ptp_clock = ptp_clock_register(&adapter->caps);
+	if (IS_ERR(adapter->ptp_clock)) {
+		adapter->ptp_clock = NULL;
+		dev_err(&adapter->pdev->dev, "ptp_clock_register failed\n");
+		return;
+	}
+
+	schedule_delayed_work(&adapter->overflow_work, IGB_OVERFLOW_PERIOD);
+
+	dev_info(&adapter->pdev->dev, "added PHC on %s\n",
+		 adapter->netdev->name);
+}
+
+void igb_ptp_remove(struct igb_adapter *adapter)
+{
+	if (adapter->ptp_clock) {
+		cancel_delayed_work_sync(&adapter->overflow_work);
+		ptp_clock_unregister(adapter->ptp_clock);
+		dev_info(&adapter->pdev->dev, "removed PHC on %s\n",
+			 adapter->netdev->name);
+	}
+}
-- 
1.7.2.5
