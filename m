From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V15 2/4] ptp: Added a clock that uses the eTSEC found on
 the MPC85xx.
Date: Fri, 22 Apr 2011 12:03:54 +0200
Message-ID: <8234cd9cbcbb64d0b5b25f260afcb864c2e44a56.1303466103.git.richard.cochran@omicron.at>
References: <cover.1303466102.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1303466102.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The eTSEC includes a PTP clock with quite a few features. This patch adds
support for the basic clock adjustment functions, plus two external time
stamps, one alarm, and the PPS callback.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Acked-by: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 .../devicetree/bindings/net/fsl-tsec-phy.txt       |   54 ++
 arch/powerpc/boot/dts/mpc8313erdb.dts              |   13 +
 arch/powerpc/boot/dts/mpc8572ds.dts                |   13 +
 arch/powerpc/boot/dts/p2020ds.dts                  |   13 +
 arch/powerpc/boot/dts/p2020rdb.dts                 |   13 +
 drivers/net/Makefile                               |    1 +
 drivers/net/gianfar_ptp.c                          |  588 ++++++++++++++++++++
 drivers/ptp/Kconfig                                |   13 +
 8 files changed, 708 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/gianfar_ptp.c

diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
index edb7ae1..2c6be03 100644
--- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -74,3 +74,57 @@ Example:
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
+  - fsl,tclk-period  Timer reference clock period in nanoseconds.
+  - fsl,tmr-prsc     Prescaler, divides the output clock.
+  - fsl,tmr-add      Frequency compensation value.
+  - fsl,tmr-fiper1   Fixed interval period pulse generator.
+  - fsl,tmr-fiper2   Fixed interval period pulse generator.
+  - fsl,max-adj      Maximum frequency adjustment in parts per billion.
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
+		fsl,tclk-period = <10>;
+		fsl,tmr-prsc    = <100>;
+		fsl,tmr-add     = <0x999999A4>;
+		fsl,tmr-fiper1  = <0x3B9AC9F6>;
+		fsl,tmr-fiper2  = <0x00018696>;
+		fsl,max-adj     = <659999998>;
+	};
diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
index 183f2aa..502e17c 100644
--- a/arch/powerpc/boot/dts/mpc8313erdb.dts
+++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
@@ -208,6 +208,19 @@
 			sleep = <&pmc 0x00300000>;
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <12 0x8 13 0x8>;
+			interrupt-parent = < &ipic >;
+			fsl,tclk-period = <10>;
+			fsl,tmr-prsc    = <100>;
+			fsl,tmr-add     = <0x999999A4>;
+			fsl,tmr-fiper1  = <0x3B9AC9F6>;
+			fsl,tmr-fiper2  = <0x00018696>;
+			fsl,max-adj     = <659999998>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/mpc8572ds.dts b/arch/powerpc/boot/dts/mpc8572ds.dts
index cafc128..f6c04d2 100644
--- a/arch/powerpc/boot/dts/mpc8572ds.dts
+++ b/arch/powerpc/boot/dts/mpc8572ds.dts
@@ -324,6 +324,19 @@
 			};
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <68 2 69 2 70 2 71 2>;
+			interrupt-parent = < &mpic >;
+			fsl,tclk-period = <5>;
+			fsl,tmr-prsc = <200>;
+			fsl,tmr-add = <0xAAAAAAAB>;
+			fsl,tmr-fiper1 = <0x3B9AC9FB>;
+			fsl,tmr-fiper2 = <0x3B9AC9FB>;
+			fsl,max-adj = <499999999>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/p2020ds.dts b/arch/powerpc/boot/dts/p2020ds.dts
index 1101914..3956daf 100644
--- a/arch/powerpc/boot/dts/p2020ds.dts
+++ b/arch/powerpc/boot/dts/p2020ds.dts
@@ -336,6 +336,19 @@
 			phy_type = "ulpi";
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <68 2 69 2 70 2>;
+			interrupt-parent = < &mpic >;
+			fsl,tclk-period = <5>;
+			fsl,tmr-prsc = <200>;
+			fsl,tmr-add = <0xCCCCCCCD>;
+			fsl,tmr-fiper1 = <0x3B9AC9FB>;
+			fsl,tmr-fiper2 = <0x0001869B>;
+			fsl,max-adj = <249999999>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/arch/powerpc/boot/dts/p2020rdb.dts b/arch/powerpc/boot/dts/p2020rdb.dts
index e2d48fd..6c55f24 100644
--- a/arch/powerpc/boot/dts/p2020rdb.dts
+++ b/arch/powerpc/boot/dts/p2020rdb.dts
@@ -396,6 +396,19 @@
 			phy_type = "ulpi";
 		};
 
+		ptp_clock@24E00 {
+			compatible = "fsl,etsec-ptp";
+			reg = <0x24E00 0xB0>;
+			interrupts = <68 2 69 2 70 2>;
+			interrupt-parent = < &mpic >;
+			fsl,tclk-period = <5>;
+			fsl,tmr-prsc = <200>;
+			fsl,tmr-add = <0xCCCCCCCD>;
+			fsl,tmr-fiper1 = <0x3B9AC9FB>;
+			fsl,tmr-fiper2 = <0x0001869B>;
+			fsl,max-adj = <249999999>;
+		};
+
 		enet0: ethernet@24000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 01b604a..97a0cef 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -31,6 +31,7 @@ obj-$(CONFIG_ATL2) += atlx/
 obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
+obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
new file mode 100644
index 0000000..d8e1753
--- /dev/null
+++ b/drivers/net/gianfar_ptp.c
@@ -0,0 +1,588 @@
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
+#include "gianfar.h"
+
+/*
+ * gianfar ptp registers
+ * Generated by regen.tcl on Thu May 13 01:38:57 PM CEST 2010
+ */
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
+#define COPH                  (1<<7) /* Generated clock output phase. */
+#define CIPH                  (1<<6) /* External oscillator input clock phase */
+#define TMSR                  (1<<5) /* Timer soft reset. */
+#define BYP                   (1<<3) /* Bypass drift compensated clock */
+#define TE                    (1<<2) /* 1588 timer enable. */
+#define CKSEL_SHIFT           (0)    /* 1588 Timer reference clock source */
+#define CKSEL_MASK            (0x3)
+
+/* Bit definitions for the TMR_TEVENT register */
+#define ETS2                  (1<<25) /* External trigger 2 timestamp sampled */
+#define ETS1                  (1<<24) /* External trigger 1 timestamp sampled */
+#define ALM2                  (1<<17) /* Current time = alarm time register 2 */
+#define ALM1                  (1<<16) /* Current time = alarm time register 1 */
+#define PP1                   (1<<7)  /* periodic pulse generated on FIPER1 */
+#define PP2                   (1<<6)  /* periodic pulse generated on FIPER2 */
+#define PP3                   (1<<5)  /* periodic pulse generated on FIPER3 */
+
+/* Bit definitions for the TMR_TEMASK register */
+#define ETS2EN                (1<<25) /* External trigger 2 timestamp enable */
+#define ETS1EN                (1<<24) /* External trigger 1 timestamp enable */
+#define ALM2EN                (1<<17) /* Timer ALM2 event enable */
+#define ALM1EN                (1<<16) /* Timer ALM1 event enable */
+#define PP1EN                 (1<<7) /* Periodic pulse event 1 enable */
+#define PP2EN                 (1<<6) /* Periodic pulse event 2 enable */
+
+/* Bit definitions for the TMR_PEVENT register */
+#define TXP2                  (1<<9) /* PTP transmitted timestamp im TXTS2 */
+#define TXP1                  (1<<8) /* PTP transmitted timestamp in TXTS1 */
+#define RXP                   (1<<0) /* PTP frame has been received */
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
+
+#define DRIVER		"gianfar_ptp"
+#define DEFAULT_CKSEL	1
+#define N_ALARM		1 /* first alarm is used internally to reset fipers */
+#define N_EXT_TS	2
+#define REG_SIZE	sizeof(struct gianfar_ptp_registers)
+
+struct etsects {
+	struct gianfar_ptp_registers *regs;
+	spinlock_t lock; /* protects regs */
+	struct ptp_clock *clock;
+	struct ptp_clock_info caps;
+	struct resource *rsrc;
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
+/*
+ * Register access functions
+ */
+
+/* Caller must hold etsects->lock. */
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
+/* Caller must hold etsects->lock. */
+static void tmr_cnt_write(struct etsects *etsects, u64 ns)
+{
+	u32 hi = ns >> 32;
+	u32 lo = ns & 0xffffffff;
+
+	gfar_write(&etsects->regs->tmr_cnt_l, lo);
+	gfar_write(&etsects->regs->tmr_cnt_h, hi);
+}
+
+/* Caller must hold etsects->lock. */
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
+/* Caller must hold etsects->lock. */
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
+			spin_lock(&etsects->lock);
+			gfar_write(&etsects->regs->tmr_alarm2_l, lo);
+			gfar_write(&etsects->regs->tmr_alarm2_h, hi);
+			spin_unlock(&etsects->lock);
+			etsects->alarm_value = ns;
+		} else {
+			gfar_write(&etsects->regs->tmr_tevent, ALM2);
+			spin_lock(&etsects->lock);
+			mask = gfar_read(&etsects->regs->tmr_temask);
+			mask &= ~ALM2EN;
+			gfar_write(&etsects->regs->tmr_temask, mask);
+			spin_unlock(&etsects->lock);
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
+static int ptp_gianfar_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	u64 adj;
+	u32 diff, tmr_add;
+	int neg_adj = 0;
+	struct etsects *etsects = container_of(ptp, struct etsects, caps);
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
+static int ptp_gianfar_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	s64 now;
+	unsigned long flags;
+	struct etsects *etsects = container_of(ptp, struct etsects, caps);
+
+	spin_lock_irqsave(&etsects->lock, flags);
+
+	now = tmr_cnt_read(etsects);
+	now += delta;
+	tmr_cnt_write(etsects, now);
+
+	spin_unlock_irqrestore(&etsects->lock, flags);
+
+	set_fipers(etsects);
+
+	return 0;
+}
+
+static int ptp_gianfar_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+	struct etsects *etsects = container_of(ptp, struct etsects, caps);
+
+	spin_lock_irqsave(&etsects->lock, flags);
+
+	ns = tmr_cnt_read(etsects);
+
+	spin_unlock_irqrestore(&etsects->lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+	return 0;
+}
+
+static int ptp_gianfar_settime(struct ptp_clock_info *ptp,
+			       const struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct etsects *etsects = container_of(ptp, struct etsects, caps);
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&etsects->lock, flags);
+
+	tmr_cnt_write(etsects, ns);
+	set_fipers(etsects);
+
+	spin_unlock_irqrestore(&etsects->lock, flags);
+
+	return 0;
+}
+
+static int ptp_gianfar_enable(struct ptp_clock_info *ptp,
+			      struct ptp_clock_request *rq, int on)
+{
+	struct etsects *etsects = container_of(ptp, struct etsects, caps);
+	unsigned long flags;
+	u32 bit, mask;
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		switch (rq->extts.index) {
+		case 0:
+			bit = ETS1EN;
+			break;
+		case 1:
+			bit = ETS2EN;
+			break;
+		default:
+			return -EINVAL;
+		}
+		spin_lock_irqsave(&etsects->lock, flags);
+		mask = gfar_read(&etsects->regs->tmr_temask);
+		if (on)
+			mask |= bit;
+		else
+			mask &= ~bit;
+		gfar_write(&etsects->regs->tmr_temask, mask);
+		spin_unlock_irqrestore(&etsects->lock, flags);
+		return 0;
+
+	case PTP_CLK_REQ_PPS:
+		spin_lock_irqsave(&etsects->lock, flags);
+		mask = gfar_read(&etsects->regs->tmr_temask);
+		if (on)
+			mask |= PP1EN;
+		else
+			mask &= ~PP1EN;
+		gfar_write(&etsects->regs->tmr_temask, mask);
+		spin_unlock_irqrestore(&etsects->lock, flags);
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
+	.adjfreq	= ptp_gianfar_adjfreq,
+	.adjtime	= ptp_gianfar_adjtime,
+	.gettime	= ptp_gianfar_gettime,
+	.settime	= ptp_gianfar_settime,
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
+static int gianfar_ptp_probe(struct platform_device *dev)
+{
+	struct device_node *node = dev->dev.of_node;
+	struct etsects *etsects;
+	struct timespec now;
+	int err = -ENOMEM;
+	u32 tmr_ctrl;
+	unsigned long flags;
+
+	etsects = kzalloc(sizeof(*etsects), GFP_KERNEL);
+	if (!etsects)
+		goto no_memory;
+
+	err = -ENODEV;
+
+	etsects->caps = ptp_gianfar_caps;
+	etsects->cksel = DEFAULT_CKSEL;
+
+	if (get_of_u32(node, "fsl,tclk-period", &etsects->tclk_period) ||
+	    get_of_u32(node, "fsl,tmr-prsc", &etsects->tmr_prsc) ||
+	    get_of_u32(node, "fsl,tmr-add", &etsects->tmr_add) ||
+	    get_of_u32(node, "fsl,tmr-fiper1", &etsects->tmr_fiper1) ||
+	    get_of_u32(node, "fsl,tmr-fiper2", &etsects->tmr_fiper2) ||
+	    get_of_u32(node, "fsl,max-adj", &etsects->caps.max_adj)) {
+		pr_err("device tree node missing required elements\n");
+		goto no_node;
+	}
+
+	etsects->irq = platform_get_irq(dev, 0);
+
+	if (etsects->irq == NO_IRQ) {
+		pr_err("irq not in device tree\n");
+		goto no_node;
+	}
+	if (request_irq(etsects->irq, isr, 0, DRIVER, etsects)) {
+		pr_err("request_irq failed\n");
+		goto no_node;
+	}
+
+	etsects->rsrc = platform_get_resource(dev, IORESOURCE_MEM, 0);
+	if (!etsects->rsrc) {
+		pr_err("no resource\n");
+		goto no_resource;
+	}
+	if (request_resource(&ioport_resource, etsects->rsrc)) {
+		pr_err("resource busy\n");
+		goto no_resource;
+	}
+
+	spin_lock_init(&etsects->lock);
+
+	etsects->regs = ioremap(etsects->rsrc->start,
+				1 + etsects->rsrc->end - etsects->rsrc->start);
+	if (!etsects->regs) {
+		pr_err("ioremap ptp registers failed\n");
+		goto no_ioremap;
+	}
+	getnstimeofday(&now);
+	ptp_gianfar_settime(&etsects->caps, &now);
+
+	tmr_ctrl =
+	  (etsects->tclk_period & TCLK_PERIOD_MASK) << TCLK_PERIOD_SHIFT |
+	  (etsects->cksel & CKSEL_MASK) << CKSEL_SHIFT;
+
+	spin_lock_irqsave(&etsects->lock, flags);
+
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl);
+	gfar_write(&etsects->regs->tmr_add,    etsects->tmr_add);
+	gfar_write(&etsects->regs->tmr_prsc,   etsects->tmr_prsc);
+	gfar_write(&etsects->regs->tmr_fiper1, etsects->tmr_fiper1);
+	gfar_write(&etsects->regs->tmr_fiper2, etsects->tmr_fiper2);
+	set_alarm(etsects);
+	gfar_write(&etsects->regs->tmr_ctrl,   tmr_ctrl|FS|RTPE|TE);
+
+	spin_unlock_irqrestore(&etsects->lock, flags);
+
+	etsects->clock = ptp_clock_register(&etsects->caps);
+	if (IS_ERR(etsects->clock)) {
+		err = PTR_ERR(etsects->clock);
+		goto no_clock;
+	}
+
+	dev_set_drvdata(&dev->dev, etsects);
+
+	return 0;
+
+no_clock:
+no_ioremap:
+	release_resource(etsects->rsrc);
+no_resource:
+	free_irq(etsects->irq, etsects);
+no_node:
+	kfree(etsects);
+no_memory:
+	return err;
+}
+
+static int gianfar_ptp_remove(struct platform_device *dev)
+{
+	struct etsects *etsects = dev_get_drvdata(&dev->dev);
+
+	gfar_write(&etsects->regs->tmr_temask, 0);
+	gfar_write(&etsects->regs->tmr_ctrl,   0);
+
+	ptp_clock_unregister(etsects->clock);
+	iounmap(etsects->regs);
+	release_resource(etsects->rsrc);
+	free_irq(etsects->irq, etsects);
+	kfree(etsects);
+
+	return 0;
+}
+
+static struct of_device_id match_table[] = {
+	{ .compatible = "fsl,etsec-ptp" },
+	{},
+};
+
+static struct platform_driver gianfar_ptp_driver = {
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
+	return platform_driver_register(&gianfar_ptp_driver);
+}
+
+module_init(ptp_gianfar_init);
+
+static void __exit ptp_gianfar_exit(void)
+{
+	platform_driver_unregister(&gianfar_ptp_driver);
+}
+
+module_exit(ptp_gianfar_exit);
+
+MODULE_AUTHOR("Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>");
+MODULE_DESCRIPTION("PTP clock using the eTSEC");
+MODULE_LICENSE("GPL");
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 70d4bb1..12eb844 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -27,4 +27,17 @@ config PTP_1588_CLOCK
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp.
 
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
