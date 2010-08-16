From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/5] ptp: Added a clock that uses the eTSEC found on the
	MPC85xx.
Date: Mon, 16 Aug 2010 13:18:20 +0200
Message-ID: <eb955d2380398447d94a14a75b5908c01f46ee77.1281956490.git.richard.cochran@omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, Rodolfo Giometti <giometti@linux.it>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <cover.1281956490.git.richard.cochran@omicron.at>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The eTSEC includes a PTP clock with quite a few features. This patch adds
support for the basic clock adjustment functions, plus two external time
stamps and one alarm.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 Documentation/powerpc/dts-bindings/fsl/tsec.txt |   57 +++
 arch/powerpc/boot/dts/mpc8313erdb.dts           |   14 +
 arch/powerpc/boot/dts/mpc8572ds.dts             |   14 +
 arch/powerpc/boot/dts/p2020ds.dts               |   14 +
 arch/powerpc/boot/dts/p2020rdb.dts              |   14 +
 drivers/net/Makefile                            |    1 +
 drivers/net/gianfar_ptp.c                       |  527 +++++++++++++++++++++++
 drivers/net/gianfar_ptp_reg.h                   |  113 +++++
 drivers/ptp/Kconfig                             |   13 +
 9 files changed, 767 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h

diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
index edb7ae1..f6edbb8 100644
--- a/Documentation/powerpc/dts-bindings/fsl/tsec.txt
+++ b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
@@ -74,3 +74,60 @@ Example:
 		interrupt-parent = <&mpic>;
 		phy-handle = <&phy0>
 	};
+
+* Gianfar PTP clock nodes
+
+General Properties:
+
+  - compatible   Should be "fsl,etsec-ptp"
+  - reg          Offset and length of the register set for the device
+  - interrupts   There should be at least two interrupts. Some devices
+                 have as many as four PTP related interrupts.
+
+Clock Properties:
+
+  - tclk-period  Timer reference clock period in nanoseconds.
+  - tmr-prsc     Prescaler, divides the output clock.
+  - tmr-add      Frequency compensation value.
+  - cksel        0= external clock, 1= eTSEC system clock, 3= RTC clock input.
+                 Currently the driver only supports choice "1".
+  - tmr-fiper1   Fixed interval period pulse generator.
+  - tmr-fiper2   Fixed interval period pulse generator.
+  - max-adj      Maximum frequency adjustment in parts per billion.
+
+  These properties set the operational parameters for the PTP
+  clock. You must choose these carefully for the clock to work right.
+  Here is how to figure good values:
+
+  TimerOsc     = system clock               MHz
+  tclk_period  = desired clock period       nanoseconds
+  NominalFreq  = 1000 / tclk_period         MHz
+  FreqDivRatio = TimerOsc / NominalFreq     (must be greater that 1.0)
+  tmr_add      = ceil(2^32 / FreqDivRatio)
+  OutputClock  = NominalFreq / tmr_prsc     MHz
+  PulseWidth   = 1 / OutputClock            microseconds
+  FiperFreq1   = desired frequency in Hz
+  FiperDiv1    = 1000000 * OutputClock / FiperFreq1
+  tmr_fiper1   = tmr_prsc * tclk_period * FiperDiv1 - tclk_period
+  max_adj      = 1000000000 * (FreqDivRatio - 1.0) - 1
+
+  The calculation for tmr_fiper2 is the same as for tmr_fiper1. The
+  driver expects that tmr_fiper1 will be correctly set to produce a 1
+  Pulse Per Second (PPS) signal, since this will be offered to the PPS
+  subsystem to synchronize the Linux clock.
+
+Example:
+
+	ptp_clock@24E00 {
+		compatible = "fsl,etsec-ptp";
+		reg = <0x24E00 0xB0>;
+		interrupts = <12 0x8 13 0x8>;
+		interrupt-parent = < &ipic >;
+		tclk-period = <10>;
+		tmr-prsc    = <100>;
+		tmr-add     = <0x999999A4>;
+		cksel       = <0x1>;
+		tmr-fiper1  = <0x3B9AC9F6>;
+		tmr-fiper2  = <0x00018696>;
+		max-adj     = <659999998>;
+	};
diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
index 183f2aa..85a7eaa 100644
--- a/arch/powerpc/boot/dts/mpc8313erdb.dts
+++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
@@ -208,6 +208,20 @@
 			sleep = <&pmc 0x00300000>;
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <12 0x8 13 0x8>;
+			interrupt-parent = < &ipic >;
+			tclk-period = <10>;
+			tmr-prsc    = <100>;
+			tmr-add     = <0x999999A4>;
+			cksel       = <0x1>;
+			tmr-fiper1  = <0x3B9AC9F6>;
+			tmr-fiper2  = <0x00018696>;
+			max-adj     = <659999998>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/mpc8572ds.dts b/arch/powerpc/boot/dts/mpc8572ds.dts
index cafc128..74208cd 100644
--- a/arch/powerpc/boot/dts/mpc8572ds.dts
+++ b/arch/powerpc/boot/dts/mpc8572ds.dts
@@ -324,6 +324,20 @@
 			};
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <68 2 69 2 70 2 71 2>;
+			interrupt-parent = < &mpic >;
+			tclk-period = <5>;
+			tmr-prsc = <200>;
+			tmr-add = <0xAAAAAAAB>;
+			cksel = <1>;
+			tmr-fiper1 = <0x3B9AC9FB>;
+			tmr-fiper2 = <0x3B9AC9FB>;
+			max-adj = <499999999>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/p2020ds.dts b/arch/powerpc/boot/dts/p2020ds.dts
index 1101914..39d73bb 100644
--- a/arch/powerpc/boot/dts/p2020ds.dts
+++ b/arch/powerpc/boot/dts/p2020ds.dts
@@ -336,6 +336,20 @@
 			phy_type = "ulpi";
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <68 2 69 2 70 2>;
+			interrupt-parent = < &mpic >;
+			tclk-period = <5>;
+			tmr-prsc = <200>;
+			tmr-add = <0xCCCCCCCD>;
+			cksel = <1>;
+			tmr-fiper1 = <0x3B9AC9FB>;
+			tmr-fiper2 = <0x0001869B>;
+			max-adj = <249999999>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/p2020rdb.dts b/arch/powerpc/boot/dts/p2020rdb.dts
index da4cb0d..5498fb9 100644
--- a/arch/powerpc/boot/dts/p2020rdb.dts
+++ b/arch/powerpc/boot/dts/p2020rdb.dts
@@ -396,6 +396,20 @@
 			phy_type = "ulpi";
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <68 2 69 2 70 2>;
+			interrupt-parent = < &mpic >;
+			tclk-period = <5>;
+			tmr-prsc = <200>;
+			tmr-add = <0xCCCCCCCD>;
+			cksel = <1>;
+			tmr-fiper1 = <0x3B9AC9FB>;
+			tmr-fiper2 = <0x0001869B>;
+			max-adj = <249999999>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 56e8c27..ea164ba 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_ATL2) += atlx/
 obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
+obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
new file mode 100644
index 0000000..637c8a7
--- /dev/null
+++ b/drivers/net/gianfar_ptp.c
@@ -0,0 +1,527 @@
+/*
+ * PTP 1588 clock using the eTSEC
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include <linux/device.h>
+#include <linux/hrtimer.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_platform.h>
+#include <linux/timex.h>
+#include <linux/io.h>
+
+#include <linux/ptp_clock_kernel.h>
+
+#include "gianfar_ptp_reg.h"
+#include "gianfar.h"
+
+#define DRIVER		"gianfar_ptp"
+#define N_ALARM		1 /* first alarm is used internally to reset fipers */
+#define N_EXT_TS	2
+#define REG_SIZE	sizeof(struct gianfar_ptp_registers)
+
+struct etsects {
+	struct gianfar_ptp_registers *regs;
+	struct ptp_clock *clock;
+	int irq;
+	u64 alarm_interval; /* for periodic alarm */
+	u64 alarm_value;
+	u32 tclk_period;  /* nanoseconds */
+	u32 tmr_prsc;
+	u32 tmr_add;
+	u32 cksel;
+	u32 tmr_fiper1;
+	u32 tmr_fiper2;
+};
+
+/* Private globals */
+static struct etsects the_clock;
+DEFINE_SPINLOCK(register_lock);
+
+/*
+ * Register access functions
+ */
+
+static u64 tmr_cnt_read(struct etsects *etsects)
+{
+	u64 ns;
+	u32 lo, hi;
+
+	lo = gfar_read(&etsects->regs->tmr_cnt_l);
+	hi = gfar_read(&etsects->regs->tmr_cnt_h);
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	return ns;
+}
+
+static void tmr_cnt_write(struct etsects *etsects, u64 ns)
+{
+	u32 hi = ns >> 32;
+	u32 lo = ns & 0xffffffff;
+
+	gfar_write(&etsects->regs->tmr_cnt_l, lo);
+	gfar_write(&etsects->regs->tmr_cnt_h, hi);
+}
+
+static void set_alarm(struct etsects *etsects)
+{
+	u64 ns;
+	u32 lo, hi;
+
+	ns = tmr_cnt_read(etsects) + 1500000000ULL;
+	ns = div_u64(ns, 1000000000UL) * 1000000000ULL;
+	ns -= etsects->tclk_period;
+	hi = ns >> 32;
+	lo = ns & 0xffffffff;
+	gfar_write(&etsects->regs->tmr_alarm1_l, lo);
+	gfar_write(&etsects->regs->tmr_alarm1_h, hi);
+}
+
+static void set_fipers(struct etsects *etsects)
+{
+	u32 tmr_ctrl = gfar_read(&etsects->regs->tmr_ctrl);
+
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl & (~TE));
+	gfar_write(&etsects->regs->tmr_prsc,   etsects->tmr_prsc);
+	gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fiper1);
+	gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fiper2);
+	set_alarm(etsects);
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|TE);
+}
+
+/*
+ * Interrupt service routine
+ */
+
+static irqreturn_t isr(int irq, void *priv)
+{
+	struct etsects *etsects = priv;
+	struct ptp_clock_event event;
+	u64 ns;
+	u32 ack = 0, lo, hi, mask, val;
+
+	val = gfar_read(&etsects->regs->tmr_tevent);
+
+	if (val & ETS1) {
+		ack |= ETS1;
+		hi = gfar_read(&etsects->regs->tmr_etts1_h);
+		lo = gfar_read(&etsects->regs->tmr_etts1_l);
+		event.type = PTP_CLOCK_EXTTS;
+		event.index = 0;
+		event.timestamp = ((u64) hi) << 32;
+		event.timestamp |= lo;
+		ptp_clock_event(etsects->clock, &event);
+	}
+
+	if (val & ETS2) {
+		ack |= ETS2;
+		hi = gfar_read(&etsects->regs->tmr_etts2_h);
+		lo = gfar_read(&etsects->regs->tmr_etts2_l);
+		event.type = PTP_CLOCK_EXTTS;
+		event.index = 1;
+		event.timestamp = ((u64) hi) << 32;
+		event.timestamp |= lo;
+		ptp_clock_event(etsects->clock, &event);
+	}
+
+	if (val & ALM2) {
+		ack |= ALM2;
+		if (etsects->alarm_value) {
+			event.type = PTP_CLOCK_ALARM;
+			event.index = 0;
+			event.timestamp = etsects->alarm_value;
+			ptp_clock_event(etsects->clock, &event);
+		}
+		if (etsects->alarm_interval) {
+			ns = etsects->alarm_value + etsects->alarm_interval;
+			hi = ns >> 32;
+			lo = ns & 0xffffffff;
+			spin_lock(&register_lock);
+			gfar_write(&etsects->regs->tmr_alarm2_l, lo);
+			gfar_write(&etsects->regs->tmr_alarm2_h, hi);
+			spin_unlock(&register_lock);
+			etsects->alarm_value = ns;
+		} else {
+			gfar_write(&etsects->regs->tmr_tevent, ALM2);
+			spin_lock(&register_lock);
+			mask = gfar_read(&etsects->regs->tmr_temask);
+			mask &= ~ALM2EN;
+			gfar_write(&etsects->regs->tmr_temask, mask);
+			spin_unlock(&register_lock);
+			etsects->alarm_value = 0;
+			etsects->alarm_interval = 0;
+		}
+	}
+
+	if (val & PP1) {
+		ack |= PP1;
+		event.type = PTP_CLOCK_PPS;
+		ptp_clock_event(etsects->clock, &event);
+	}
+
+	if (ack) {
+		gfar_write(&etsects->regs->tmr_tevent, ack);
+		return IRQ_HANDLED;
+	} else
+		return IRQ_NONE;
+}
+
+/*
+ * PTP clock operations
+ */
+
+static int ptp_gianfar_adjfreq(void *priv, s32 ppb)
+{
+	u64 adj;
+	u32 diff, tmr_add;
+	int neg_adj = 0;
+	struct etsects *etsects = priv;
+
+	if (!ppb)
+		return 0;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	tmr_add = etsects->tmr_add;
+	adj = tmr_add;
+	adj *= ppb;
+	diff = div_u64(adj, 1000000000ULL);
+
+	tmr_add = neg_adj ? tmr_add - diff : tmr_add + diff;
+
+	gfar_write(&etsects->regs->tmr_add, tmr_add);
+
+	return 0;
+}
+
+static int ptp_gianfar_adjtime(void *priv, struct timespec *ts)
+{
+	s64 delta, now;
+	unsigned long flags;
+	struct etsects *etsects = priv;
+
+	delta = 1000000000LL * ts->tv_sec;
+	delta += ts->tv_nsec;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	now = tmr_cnt_read(etsects);
+	now += delta;
+	tmr_cnt_write(etsects, now);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	set_fipers(etsects);
+
+	return 0;
+}
+
+static int ptp_gianfar_gettime(void *priv, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+	struct etsects *etsects = priv;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	ns = tmr_cnt_read(etsects);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+	return 0;
+}
+
+static int ptp_gianfar_settime(void *priv, struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct etsects *etsects = priv;
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	tmr_cnt_write(etsects, ns);
+	set_fipers(etsects);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	return 0;
+}
+
+static int ptp_gianfar_gettimer(void *priv, int index, struct itimerspec *ts)
+{
+	u64 now, ns;
+	u32 remainder;
+	unsigned long flags;
+	struct etsects *etsects = priv;
+
+	ns = etsects->alarm_interval;
+
+	ts->it_interval.tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->it_interval.tv_nsec = remainder;
+
+	spin_lock_irqsave(&register_lock, flags);
+	now = tmr_cnt_read(etsects);
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	ns = etsects->alarm_value - now;
+
+	ts->it_value.tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->it_value.tv_nsec = remainder;
+
+	return 0;
+}
+
+static int ptp_gianfar_settimer(void *p, int i, int abs, struct itimerspec *ts)
+{
+	u64 ns;
+	u32 lo, hi, mask;
+	unsigned long flags;
+	struct etsects *etsects = p;
+
+	ns = ts->it_interval.tv_sec * 1000000000ULL;
+	ns += ts->it_interval.tv_nsec;
+
+	etsects->alarm_interval = ns;
+
+	ns = ts->it_value.tv_sec * 1000000000ULL;
+	ns += ts->it_value.tv_nsec;
+
+	if (!ns) {
+		/* Cancel the timer. */
+		etsects->alarm_value = 0;
+		etsects->alarm_interval = 0;
+		return 0;
+	}
+
+	if (!abs) {
+		spin_lock_irqsave(&register_lock, flags);
+		ns += tmr_cnt_read(etsects);
+		spin_unlock_irqrestore(&register_lock, flags);
+	}
+
+	etsects->alarm_value = ns;
+
+	hi = ns >> 32;
+	lo = ns & 0xffffffff;
+
+	spin_lock_irqsave(&register_lock, flags);
+
+	gfar_write(&etsects->regs->tmr_alarm2_l, lo);
+	gfar_write(&etsects->regs->tmr_alarm2_h, hi);
+
+	mask = gfar_read(&etsects->regs->tmr_temask);
+	mask |= ALM2EN;
+	gfar_write(&etsects->regs->tmr_temask, mask);
+
+	spin_unlock_irqrestore(&register_lock, flags);
+
+	return 0;
+}
+
+static int ptp_gianfar_enable(void *priv, struct ptp_clock_request *rq, int on)
+{
+	struct etsects *etsects = priv;
+	unsigned long flags;
+	u32 bit, mask;
+
+	switch (rq->type) {
+	case PTP_REQUEST_EXTTS:
+		switch (rq->index) {
+		case 0:
+			bit = ETS1EN;
+			break;
+		case 1:
+			bit = ETS2EN;
+			break;
+		default:
+			return -EINVAL;
+		}
+		spin_lock_irqsave(&register_lock, flags);
+		mask = gfar_read(&etsects->regs->tmr_temask);
+		if (on)
+			mask |= bit;
+		else
+			mask &= ~bit;
+		gfar_write(&etsects->regs->tmr_temask, mask);
+		spin_unlock_irqrestore(&register_lock, flags);
+		return 0;
+
+	case PTP_REQUEST_PPS:
+		spin_lock_irqsave(&register_lock, flags);
+		mask = gfar_read(&etsects->regs->tmr_temask);
+		if (on)
+			mask |= PP1EN;
+		else
+			mask &= ~PP1EN;
+		gfar_write(&etsects->regs->tmr_temask, mask);
+		spin_unlock_irqrestore(&register_lock, flags);
+		return 0;
+
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info ptp_gianfar_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "gianfar clock",
+	.max_adj	= 512000,
+	.n_alarm	= N_ALARM,
+	.n_ext_ts	= N_EXT_TS,
+	.n_per_out	= 0,
+	.pps		= 1,
+	.priv		= &the_clock,
+	.adjfreq	= ptp_gianfar_adjfreq,
+	.adjtime	= ptp_gianfar_adjtime,
+	.gettime	= ptp_gianfar_gettime,
+	.settime	= ptp_gianfar_settime,
+	.gettimer	= ptp_gianfar_gettimer,
+	.settimer	= ptp_gianfar_settimer,
+	.enable		= ptp_gianfar_enable,
+};
+
+/* OF device tree */
+
+static int get_of_u32(struct device_node *node, char *str, u32 *val)
+{
+	int plen;
+	const u32 *prop = of_get_property(node, str, &plen);
+
+	if (!prop || plen != sizeof(*prop))
+		return -1;
+	*val = *prop;
+	return 0;
+}
+
+static int gianfar_ptp_probe(struct of_device *dev,
+			     const struct of_device_id *match)
+{
+	struct device_node *node = dev->dev.of_node;
+	struct etsects *etsects = &the_clock;
+	struct timespec now;
+	u32 tmr_ctrl;
+
+	if (get_of_u32(node, "tclk-period", &etsects->tclk_period) ||
+	    get_of_u32(node, "tmr-prsc", &etsects->tmr_prsc) ||
+	    get_of_u32(node, "tmr-add", &etsects->tmr_add) ||
+	    get_of_u32(node, "cksel", &etsects->cksel) ||
+	    get_of_u32(node, "tmr-fiper1", &etsects->tmr_fiper1) ||
+	    get_of_u32(node, "tmr-fiper2", &etsects->tmr_fiper2) ||
+	    get_of_u32(node, "max-adj", &ptp_gianfar_caps.max_adj)) {
+		pr_err("device tree node missing required elements\n");
+		return -ENODEV;
+	}
+
+	etsects->irq = irq_of_parse_and_map(node, 0);
+
+	if (etsects->irq == NO_IRQ) {
+		pr_err("irq not in device tree\n");
+		return -ENODEV;
+	}
+	if (request_irq(etsects->irq, isr, 0, DRIVER, etsects)) {
+		pr_err("request_irq failed\n");
+		return -ENODEV;
+	}
+
+	etsects->regs = of_iomap(node, 0);
+	if (!etsects->regs) {
+		pr_err("of_iomap ptp registers failed\n");
+		return -EINVAL;
+	}
+
+	tmr_ctrl =
+	  (etsects->tclk_period & TCLK_PERIOD_MASK) << TCLK_PERIOD_SHIFT |
+	  (etsects->cksel & CKSEL_MASK) << CKSEL_SHIFT;
+
+	getnstimeofday(&now);
+	ptp_gianfar_settime(etsects, &now);
+
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl);
+	gfar_write(&etsects->regs->tmr_add,    etsects->tmr_add);
+	gfar_write(&etsects->regs->tmr_prsc,   etsects->tmr_prsc);
+	gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fiper1);
+	gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fiper2);
+	set_alarm(etsects);
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|FS|RTPE|TE);
+
+	etsects->clock = ptp_clock_register(&ptp_gianfar_caps);
+
+	return IS_ERR(etsects->clock) ? PTR_ERR(etsects->clock) : 0;
+}
+
+static int gianfar_ptp_remove(struct of_device *dev)
+{
+	gfar_write(&the_clock.regs->tmr_temask, 0);
+	gfar_write(&the_clock.regs->tmr_ctrl,   0);
+
+	ptp_clock_unregister(the_clock.clock);
+
+	free_irq(the_clock.irq, &the_clock);
+
+	iounmap(the_clock.regs);
+
+	return 0;
+}
+
+static struct of_device_id match_table[] = {
+	{ .compatible = "fsl,etsec-ptp" },
+	{},
+};
+
+static struct of_platform_driver gianfar_ptp_driver = {
+	.driver = {
+		.name		= "gianfar_ptp",
+		.of_match_table	= match_table,
+		.owner		= THIS_MODULE,
+	},
+	.probe       = gianfar_ptp_probe,
+	.remove      = gianfar_ptp_remove,
+};
+
+/* module operations */
+
+static int __init ptp_gianfar_init(void)
+{
+	return of_register_platform_driver(&gianfar_ptp_driver);
+}
+
+module_init(ptp_gianfar_init);
+
+static void __exit ptp_gianfar_exit(void)
+{
+	of_unregister_platform_driver(&gianfar_ptp_driver);
+}
+
+module_exit(ptp_gianfar_exit);
+
+MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_DESCRIPTION("PTP clock using the eTSEC");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/gianfar_ptp_reg.h b/drivers/net/gianfar_ptp_reg.h
new file mode 100644
index 0000000..95e171f
--- /dev/null
+++ b/drivers/net/gianfar_ptp_reg.h
@@ -0,0 +1,113 @@
+/* gianfar_ptp_reg.h
+ * Generated by regen.tcl on Thu May 13 01:38:57 PM CEST 2010
+ *
+ * PTP 1588 clock using the gianfar eTSEC
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _GIANFAR_PTP_REG_H_
+#define _GIANFAR_PTP_REG_H_
+
+struct gianfar_ptp_registers {
+	u32 tmr_ctrl;     /* Timer control register */
+	u32 tmr_tevent;   /* Timestamp event register */
+	u32 tmr_temask;   /* Timer event mask register */
+	u32 tmr_pevent;   /* Timestamp event register */
+	u32 tmr_pemask;   /* Timer event mask register */
+	u32 tmr_stat;     /* Timestamp status register */
+	u32 tmr_cnt_h;    /* Timer counter high register */
+	u32 tmr_cnt_l;    /* Timer counter low register */
+	u32 tmr_add;      /* Timer drift compensation addend register */
+	u32 tmr_acc;      /* Timer accumulator register */
+	u32 tmr_prsc;     /* Timer prescale */
+	u8  res1[4];
+	u32 tmroff_h;     /* Timer offset high */
+	u32 tmroff_l;     /* Timer offset low */
+	u8  res2[8];
+	u32 tmr_alarm1_h; /* Timer alarm 1 high register */
+	u32 tmr_alarm1_l; /* Timer alarm 1 high register */
+	u32 tmr_alarm2_h; /* Timer alarm 2 high register */
+	u32 tmr_alarm2_l; /* Timer alarm 2 high register */
+	u8  res3[48];
+	u32 tmr_fiper1;   /* Timer fixed period interval */
+	u32 tmr_fiper2;   /* Timer fixed period interval */
+	u32 tmr_fiper3;   /* Timer fixed period interval */
+	u8  res4[20];
+	u32 tmr_etts1_h;  /* Timestamp of general purpose external trigger */
+	u32 tmr_etts1_l;  /* Timestamp of general purpose external trigger */
+	u32 tmr_etts2_h;  /* Timestamp of general purpose external trigger */
+	u32 tmr_etts2_l;  /* Timestamp of general purpose external trigger */
+};
+
+/* Bit definitions for the TMR_CTRL register */
+#define ALM1P                 (1<<31) /* Alarm1 output polarity */
+#define ALM2P                 (1<<30) /* Alarm2 output polarity */
+#define FS                    (1<<28) /* FIPER start indication */
+#define PP1L                  (1<<27) /* Fiper1 pulse loopback mode enabled. */
+#define PP2L                  (1<<26) /* Fiper2 pulse loopback mode enabled. */
+#define TCLK_PERIOD_SHIFT     (16) /* 1588 timer reference clock period. */
+#define TCLK_PERIOD_MASK      (0x3ff)
+#define RTPE                  (1<<15) /* Record Tx Timestamp to PAL Enable. */
+#define FRD                   (1<<14) /* FIPER Realignment Disable */
+#define ESFDP                 (1<<11) /* External Tx/Rx SFD Polarity. */
+#define ESFDE                 (1<<10) /* External Tx/Rx SFD Enable. */
+#define ETEP2                 (1<<9) /* External trigger 2 edge polarity */
+#define ETEP1                 (1<<8) /* External trigger 1 edge polarity */
+#define COPH                  (1<<7) /* Generated clock (TSEC_1588_GCLK) output phase. */
+#define CIPH                  (1<<6) /* External oscillator input clock phase. */
+#define TMSR                  (1<<5) /* Timer soft reset. When enabled, it resets all the timer registers and state machines. */
+#define BYP                   (1<<3) /* Bypass drift compensated clock */
+#define TE                    (1<<2) /* 1588 timer enable. If not enabled, all the timer registers and state machines are disabled. */
+#define CKSEL_SHIFT           (0) /* 1588 Timer reference clock source select. */
+#define CKSEL_MASK            (0x3)
+
+/* Bit definitions for the TMR_TEVENT register */
+#define ETS2                  (1<<25) /* External trigger 2 timestamp sampled */
+#define ETS1                  (1<<24) /* External trigger 1 timestamp sampled */
+#define ALM2                  (1<<17) /* Current time equaled alarm time register 2 */
+#define ALM1                  (1<<16) /* Current time equaled alarm time register 1 */
+#define PP1                   (1<<7) /* Indicates that a periodic pulse has been generated based on FIPER1 register */
+#define PP2                   (1<<6) /* Indicates that a periodic pulse has been generated based on FIPER2 register */
+#define PP3                   (1<<5) /* Indicates that a periodic pulse has been generated based on FIPER3 register */
+
+/* Bit definitions for the TMR_TEMASK register */
+#define ETS2EN                (1<<25) /* External trigger 2 timestamp sample event enable */
+#define ETS1EN                (1<<24) /* External trigger 1 timestamp sample event enable */
+#define ALM2EN                (1<<17) /* Timer ALM2 event enable */
+#define ALM1EN                (1<<16) /* Timer ALM1 event enable */
+#define PP1EN                 (1<<7) /* Periodic pulse event 1 enable */
+#define PP2EN                 (1<<6) /* Periodic pulse event 2 enable */
+
+/* Bit definitions for the TMR_PEVENT register */
+#define TXP2                  (1<<9) /* Indicates that a PTP frame has been transmitted and its timestamp is stored in TXTS2 register */
+#define TXP1                  (1<<8) /* Indicates that a PTP frame has been transmitted and its timestamp is stored in TXTS1 register */
+#define RXP                   (1<<0) /* Indicates that a PTP frame has been received */
+
+/* Bit definitions for the TMR_PEMASK register */
+#define TXP2EN                (1<<9) /* Transmit PTP packet event 2 enable */
+#define TXP1EN                (1<<8) /* Transmit PTP packet event 1 enable */
+#define RXPEN                 (1<<0) /* Receive PTP packet event enable */
+
+/* Bit definitions for the TMR_STAT register */
+#define STAT_VEC_SHIFT        (0) /* Timer general purpose status vector */
+#define STAT_VEC_MASK         (0x3f)
+
+/* Bit definitions for the TMR_PRSC register */
+#define PRSC_OCK_SHIFT        (0) /* Output clock division/prescale factor. */
+#define PRSC_OCK_MASK         (0xffff)
+
+#endif
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 3aa517a..aaf957f 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -36,4 +36,17 @@ config PTP_1588_CLOCK_LINUX
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp_linux.
 
+config PTP_1588_CLOCK_GIANFAR
+	tristate "Freescale eTSEC as PTP clock"
+	depends on PTP_1588_CLOCK
+	depends on GIANFAR
+	help
+	  This driver adds support for using the eTSEC as a PTP
+	  clock. This clock is only useful if your PTP programs are
+	  getting hardware time stamps on the PTP Ethernet packets
+	  using the SO_TIMESTAMPING API.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called gianfar_ptp.
+
 endmenu
-- 
1.7.0.4
