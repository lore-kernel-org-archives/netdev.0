From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 3/3] ptp: Added a clock that uses the eTSEC found on the
	MPC85xx.
Date: Tue, 27 Apr 2010 11:14:49 +0200
Message-ID: <20100427091449.GA5122@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:47017 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab0D0JPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 05:15:03 -0400
Received: by pwj9 with SMTP id 9so9154199pwj.19
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 02:15:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eTSEC includes a PTP clock with quite a few features. This patch adds
support for the basic clock adjustment functions.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/Makefile          |    1 +
 drivers/net/gianfar_ptp.c     |  269 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/gianfar_ptp_reg.h |  107 ++++++++++++++++
 drivers/ptp/Kconfig           |   13 ++
 4 files changed, 390 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/gianfar_ptp.c
 create mode 100644 drivers/net/gianfar_ptp_reg.h

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ebf80b9..8f2c2ff 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_ATL2) += atlx/
 obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
+obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
new file mode 100644
index 0000000..eed3246
--- /dev/null
+++ b/drivers/net/gianfar_ptp.c
@@ -0,0 +1,269 @@
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
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/timex.h>
+#include <asm/io.h>
+
+#include <linux/ptp_clock_kernel.h>
+
+#include "gianfar_ptp_reg.h"
+
+/*
+ *
+ * TODO - get the following from device tree
+ *
+ */
+#define TMR_BASE_KERNEL	0xe0024e00 // CONFIG_PPC_85xx 0xffe24e00
+#define TIMER_OSC	166666666
+#define TCLK_PERIOD	10
+#define NOMINAL_FREQ	100000000
+#define DEF_TMR_PRSC	100
+#define DEF_TMR_ADD	0x999999A4
+#define DEFAULT_CKSEL   1
+
+#define REG_SIZE	(4 + TMR_ETTS2_L)
+
+struct etsects {
+	void *regs;
+	u32 timer_osc;    /* Hz */
+	u32 tclk_period;  /* nanoseconds */
+	s64 nominal_freq; /* Hz */
+	u32 tmr_prsc;
+	u32 tmr_add;
+	u32 cksel;
+};
+
+/* Private globals */
+static struct etsects the_clock;
+DEFINE_SPINLOCK(adjtime_lock);
+
+/*
+ * Register access functions
+ */
+
+static inline u32 reg_read(struct etsects *etsects, unsigned long offset)
+{
+	return in_be32(etsects->regs + offset);
+}
+
+static inline void reg_write(struct etsects *etsects,
+			     unsigned long offset, u32 val)
+{
+	out_be32(etsects->regs + offset, val);
+}
+
+static u64 tmr_cnt_read(struct etsects *etsects)
+{
+	u64 ns;
+	u32 lo, hi;
+	lo = reg_read(etsects, TMR_CNT_L);
+	hi = reg_read(etsects, TMR_CNT_H);
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	return ns;
+}
+
+static void tmr_cnt_write(struct etsects *etsects, u64 ns)
+{
+	u32 hi = ns >> 32;
+	u32 lo = ns & 0xffffffff;
+	reg_write(etsects, TMR_CNT_L, lo);
+	reg_write(etsects, TMR_CNT_H, hi);
+}
+
+static void set_alarm(struct etsects *etsects)
+{
+	u64 ns;
+	u32 lo, hi;
+	ns = tmr_cnt_read(etsects) + 1500000000ULL;
+	ns = div_u64(ns, 1000000000UL) * 1000000000ULL;
+	ns -= etsects->tclk_period;
+	hi = ns >> 32;
+	lo = ns & 0xffffffff;
+	reg_write(etsects, TMR_ALARM1_L, lo);
+	reg_write(etsects, TMR_ALARM1_H, hi);
+}
+
+static void set_fipers(struct etsects *etsects)
+{
+	u32 tmr_ctrl = reg_read(etsects, TMR_CTRL);
+
+	reg_write(etsects, TMR_CTRL,   tmr_ctrl & (~TE));
+	reg_write(etsects, TMR_PRSC,   etsects->tmr_prsc);
+	reg_write(etsects, TMR_FIPER1, 0x3B9AC9F6);
+	reg_write(etsects, TMR_FIPER2, 0x00018696);
+	set_alarm(etsects);
+	reg_write(etsects, TMR_CTRL,   tmr_ctrl|TE);
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
+	reg_write(etsects, TMR_ADD, tmr_add);
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
+	spin_lock_irqsave(&adjtime_lock, flags);
+
+	now = tmr_cnt_read(etsects);
+	now += delta;
+	tmr_cnt_write(etsects, now);
+
+	spin_unlock_irqrestore(&adjtime_lock, flags);
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
+	struct etsects *etsects = priv;
+	ns = tmr_cnt_read(etsects);
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+	return 0;
+}
+
+static int ptp_gianfar_settime(void *priv, struct timespec *ts)
+{
+	u64 ns;
+	struct etsects *etsects = priv;
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+	tmr_cnt_write(etsects, ns);
+	set_fipers(etsects);
+	return 0;
+}
+
+static int ptp_gianfar_enable(void *priv, struct ptp_clock_request rq, int on)
+{
+	/* We do not (yet) offer any ancillary features. */
+	return -EINVAL;
+}
+
+struct ptp_clock_info ptp_gianfar_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "gianfar clock",
+	.max_adj	= 512000,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+	.priv		= &the_clock,
+	.adjfreq	= ptp_gianfar_adjfreq,
+	.adjtime	= ptp_gianfar_adjtime,
+	.gettime	= ptp_gianfar_gettime,
+	.settime	= ptp_gianfar_settime,
+	.enable		= ptp_gianfar_enable,
+};
+
+/* module operations */
+
+static void __exit ptp_gianfar_exit(void)
+{
+	ptp_clock_unregister(&ptp_gianfar_caps);
+	iounmap(the_clock.regs);
+}
+
+static int __init ptp_gianfar_init(void)
+{
+	struct etsects *etsects = &the_clock;
+	struct timespec now;
+	phys_addr_t reg_addr = TMR_BASE_KERNEL;
+	unsigned long reg_size = REG_SIZE;
+	u32 tmr_ctrl;
+	int err;
+
+	etsects->regs = ioremap(reg_addr, reg_size);
+	if (!etsects->regs) {
+		pr_err("ioremap ptp registers failed\n");
+		return -EINVAL;
+	}
+	etsects->timer_osc = TIMER_OSC;
+	etsects->tclk_period = TCLK_PERIOD;
+	etsects->nominal_freq = NOMINAL_FREQ;
+	etsects->tmr_prsc = DEF_TMR_PRSC;
+	etsects->tmr_add = DEF_TMR_ADD;
+	etsects->cksel = DEFAULT_CKSEL;
+
+	tmr_ctrl =
+	  (etsects->tclk_period & TCLK_PERIOD_MASK) << TCLK_PERIOD_SHIFT |
+	  (etsects->cksel & CKSEL_MASK) << CKSEL_SHIFT;
+
+	getnstimeofday(&now);
+	ptp_gianfar_settime(etsects, &now);
+
+	reg_write(etsects, TMR_CTRL,   tmr_ctrl);
+	reg_write(etsects, TMR_ADD,    etsects->tmr_add);
+	reg_write(etsects, TMR_PRSC,   etsects->tmr_prsc);
+	reg_write(etsects, TMR_FIPER1, 0x3B9AC9F6);
+	reg_write(etsects, TMR_FIPER2, 0x00018696);
+	set_alarm(etsects);
+	reg_write(etsects, TMR_CTRL,   tmr_ctrl|FS|RTPE|TE);
+
+	err = ptp_clock_register(&ptp_gianfar_caps);
+	return err;
+}
+
+subsys_initcall(ptp_gianfar_init);
+module_exit(ptp_gianfar_exit);
+
+MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
+MODULE_DESCRIPTION("PTP clock using the eTSEC");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/gianfar_ptp_reg.h b/drivers/net/gianfar_ptp_reg.h
new file mode 100644
index 0000000..9c94677
--- /dev/null
+++ b/drivers/net/gianfar_ptp_reg.h
@@ -0,0 +1,107 @@
+/* gianfar_ptp_reg.h
+ * Generated by regen.tcl on Thu Apr 15 02:21:02 PM CEST 2010
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
+#define TMR_CTRL              0x00000000 /* Timer control register */
+#define TMR_TEVENT            0x00000004 /* Timestamp event register */
+#define TMR_TEMASK            0x00000008 /* Timer event mask register */
+#define TMR_PEVENT            0x0000000c /* Timestamp event register */
+#define TMR_PEMASK            0x00000010 /* Timer event mask register */
+#define TMR_STAT              0x00000014 /* Timestamp status register */
+#define TMR_CNT_H             0x00000018 /* Timer counter high register */
+#define TMR_CNT_L             0x0000001c /* Timer counter low register */
+#define TMR_ADD               0x00000020 /* Timer drift compensation addend register */
+#define TMR_ACC               0x00000024 /* Timer accumulator register */
+#define TMR_PRSC              0x00000028 /* Timer prescale */
+#define TMROFF_H              0x00000030 /* Timer offset high */
+#define TMROFF_L              0x00000034 /* Timer offset low */
+#define TMR_ALARM1_H          0x00000040 /* Timer alarm 1 high register */
+#define TMR_ALARM1_L          0x00000044 /* Timer alarm 1 high register */
+#define TMR_ALARM2_H          0x00000048 /* Timer alarm 2 high register */
+#define TMR_ALARM2_L          0x0000004c /* Timer alarm 2 high register */
+#define TMR_FIPER1            0x00000080 /* Timer fixed period interval */
+#define TMR_FIPER2            0x00000084 /* Timer fixed period interval */
+#define TMR_FIPER3            0x00000088 /* Timer fixed period interval */
+#define TMR_ETTS1_H           0x000000a0 /* Timestamp of general purpose external trigger */
+#define TMR_ETTS1_L           0x000000a4 /* Timestamp of general purpose external trigger */
+#define TMR_ETTS2_H           0x000000a8 /* Timestamp of general purpose external trigger */
+#define TMR_ETTS2_L           0x000000ac /* Timestamp of general purpose external trigger */
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
index 7113bef..2f8ab67 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -35,4 +35,17 @@ config PTP_1588_CLOCK_LINUX
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp_linux.ko.
 
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
+	  will be called gianfar_ptp.ko.
+
 endmenu
-- 
1.6.0.4

