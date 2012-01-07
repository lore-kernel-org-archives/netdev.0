From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 1/2] igb: add PTP Hardware Clock
	code
Date: Sat,  7 Jan 2012 20:38:20 +0100
Message-ID: <06a2d33bed05d5c17c03fca6f0fcc2fe3f6870f4.1325964581.git.richardcochran@gmail.com>
References: <cover.1325964581.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1325964581.git.richardcochran@gmail.com>
In-Reply-To: <cover.1325964581.git.richardcochran@gmail.com>
References: <cover.1325964581.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch adds a source file implementing a PHC. Only the basic
clock operations have been implemented, although the hardware
would offer some ancillary functions. The code is fairly self
contained and is not yet used in the main igb driver.

Every timestamp and clock read operation must consult the overflow
counter to form a correct time value. Access to the counter is
protected by a spin lock, and this would be sufficient, assuming that
the time values are monotonic.

However, this assumption does not hold in general. Consider the
following sequence.

 1. Hardware latches a receive timestamp (just before counter overflow).
 2. User calls clock_gettime() (just after counter overflow).
 3. User takes lock, detects 1-0 transition, and increments overflow count.
 4. Driver takes lock, incorrectly combines overflow count with timestamp.

A very similar race condition exists between two nearly simultaneous
hardware timestamps.

The implementation detects this race by checking the two most
significant bits for a transition from 11b to 00b. When this pattern
is detected, the code uses the previous value of the overflow count.

The two most significant bits divide the overflow period into four
regions, and so the watchdog timeout is set to sample the counter at
just over four times per period.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb.h     |    8 +
 drivers/net/ethernet/intel/igb/igb_ptp.c |  427 ++++++++++++++++++++++++++++++
 2 files changed, 435 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index c69feeb..f30458d 100644
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
+	unsigned int last_msb;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
new file mode 100644
index 0000000..dd27be1
--- /dev/null
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -0,0 +1,427 @@
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
+#define IGB_OVERFLOW_PERIOD	(HZ * 60 * 4)
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
+static u64 igb_overflow_get(struct igb_adapter *igb, u64 low, unsigned int nbit)
+{
+	unsigned int msb_set = (low >> (nbit - 2)) & 0x3;
+
+	if (msb_set == 0x3 && igb->last_msb == 0x0) {
+		/*
+		 * This time stamp was taken before the last overflow,
+		 * but it lost the race to read the overflow counter.
+		 * Therefore, we just use the previous overflow value.
+		 */
+		low |= ((u64) igb->overflow_counter - 1ULL) << nbit;
+		return low;
+	}
+
+	/*
+	 * Test for a one to zero transition of the most significant
+	 * bit, and increment the overflow counter.
+	 */
+	if ((igb->last_msb & 0x2) && !(msb_set & 0x2))
+		igb->overflow_counter++;
+
+	igb->last_msb = msb_set;
+
+	low |= ((u64) igb->overflow_counter) << nbit;
+
+	return low;
+}
+
+static void igb_overflow_set(struct igb_adapter *igb, u64 ns, unsigned int nbit)
+{
+	igb->overflow_counter = ns >> nbit;
+	igb->last_msb = (ns >> (nbit - 2)) & 0x3;
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
+	ns = igb_overflow_get(igb, ns, OFL_SHIFT_82576);
+
+	return ns;
+}
+
+static void igb_82576_systim_write(struct igb_adapter *igb, u64 ns)
+{
+	u32 hi, lo;
+	struct e1000_hw *hw = &igb->hw;
+
+	hi = (ns >> 13) & 0xffffffff;
+	lo = (ns & 0x1fff) << NS_SHIFT_82576;
+
+	wr32(E1000_SYSTIML, lo);
+	wr32(E1000_SYSTIMH, hi);
+
+	igb_overflow_set(igb, ns, OFL_SHIFT_82576);
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
+	ns = igb_overflow_get(igb, ns, OFL_SHIFT_82580);
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
+	igb_overflow_set(igb, ns, OFL_SHIFT_82580);
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
+		/* Enable the timer functions by clearing bit 31. */
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
+	schedule_delayed_work(&adapter->overflow_work, IGB_OVERFLOW_PERIOD);
+
+#ifdef CONFIG_PTP_1588_CLOCK
+
+	adapter->ptp_clock = ptp_clock_register(&adapter->caps);
+	if (IS_ERR(adapter->ptp_clock)) {
+		adapter->ptp_clock = NULL;
+		dev_err(&adapter->pdev->dev, "ptp_clock_register failed\n");
+	} else
+		dev_info(&adapter->pdev->dev, "added PHC on %s\n",
+			 adapter->netdev->name);
+
+#endif /*CONFIG_PTP_1588_CLOCK*/
+}
+
+void igb_ptp_remove(struct igb_adapter *adapter)
+{
+	cancel_delayed_work_sync(&adapter->overflow_work);
+
+#ifdef CONFIG_PTP_1588_CLOCK
+
+	if (adapter->ptp_clock) {
+		ptp_clock_unregister(adapter->ptp_clock);
+		dev_info(&adapter->pdev->dev, "removed PHC on %s\n",
+			 adapter->netdev->name);
+	}
+
+#endif /*CONFIG_PTP_1588_CLOCK*/
+}
-- 
1.7.2.5


------------------------------------------------------------------------------
Ridiculously easy VDI. With Citrix VDI-in-a-Box, you don't need a complex
infrastructure or vast IT resources to deliver seamless, secure access to
virtual desktops. With this all-in-one solution, easily deploy virtual 
desktops for less than the cost of PCs and save 60% on VDI infrastructure 
costs. Try it free! http://p.sf.net/sfu/Citrix-VDIinabox
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
