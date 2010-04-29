From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 3/3] ptp: Added a clock that uses the eTSEC found on the
 MPC85xx.
Date: Thu, 29 Apr 2010 14:41:30 +0200
Message-ID: <4BD97E7A.4080401@grandegger.com>
References: <20100427091449.GA5122@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:38620 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758050Ab0D3QzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:55:19 -0400
In-Reply-To: <20100427091449.GA5122@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> The eTSEC includes a PTP clock with quite a few features. This patch adds
> support for the basic clock adjustment functions.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/Makefile          |    1 +
>  drivers/net/gianfar_ptp.c     |  269 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/gianfar_ptp_reg.h |  107 ++++++++++++++++
>  drivers/ptp/Kconfig           |   13 ++
>  4 files changed, 390 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/gianfar_ptp.c
>  create mode 100644 drivers/net/gianfar_ptp_reg.h
> 
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index ebf80b9..8f2c2ff 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -28,6 +28,7 @@ obj-$(CONFIG_ATL2) += atlx/
>  obj-$(CONFIG_ATL1E) += atl1e/
>  obj-$(CONFIG_ATL1C) += atl1c/
>  obj-$(CONFIG_GIANFAR) += gianfar_driver.o
> +obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
>  obj-$(CONFIG_TEHUTI) += tehuti.o
>  obj-$(CONFIG_ENIC) += enic/
>  obj-$(CONFIG_JME) += jme.o
> diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/gianfar_ptp.c
> new file mode 100644
> index 0000000..eed3246
> --- /dev/null
> +++ b/drivers/net/gianfar_ptp.c
> @@ -0,0 +1,269 @@
> +/*
> + * PTP 1588 clock using the eTSEC
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <linux/device.h>
> +#include <linux/hrtimer.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/timex.h>
> +#include <asm/io.h>
> +
> +#include <linux/ptp_clock_kernel.h>
> +
> +#include "gianfar_ptp_reg.h"
> +
> +/*
> + *
> + * TODO - get the following from device tree
> + *
> + */
> +#define TMR_BASE_KERNEL	0xe0024e00 // CONFIG_PPC_85xx 0xffe24e00
> +#define TIMER_OSC	166666666

fsl_get_sys_freq() does return that frequency. But that part is
temporary anyway and you already posted a patch to get them from the
device tree.

> +#define TCLK_PERIOD	10
> +#define NOMINAL_FREQ	100000000
> +#define DEF_TMR_PRSC	100
> +#define DEF_TMR_ADD	0x999999A4
> +#define DEFAULT_CKSEL   1
> +
> +#define REG_SIZE	(4 + TMR_ETTS2_L)
> +
> +struct etsects {
> +	void *regs;
> +	u32 timer_osc;    /* Hz */
> +	u32 tclk_period;  /* nanoseconds */
> +	s64 nominal_freq; /* Hz */
> +	u32 tmr_prsc;
> +	u32 tmr_add;
> +	u32 cksel;
> +};
> +
> +/* Private globals */
> +static struct etsects the_clock;
> +DEFINE_SPINLOCK(adjtime_lock);
> +
> +/*
> + * Register access functions
> + */
> +
> +static inline u32 reg_read(struct etsects *etsects, unsigned long offset)
> +{
> +	return in_be32(etsects->regs + offset);
> +}
> +
> +static inline void reg_write(struct etsects *etsects,
> +			     unsigned long offset, u32 val)
> +{
> +	out_be32(etsects->regs + offset, val);
> +}

For compatibility with the gianfar implementation and to profit from
type checking I would prefer to use a structure to describe the register
layout. This would make the functions above obsolete.

> +static u64 tmr_cnt_read(struct etsects *etsects)
> +{
> +	u64 ns;
> +	u32 lo, hi;

Empty line? While I'm at it, some coding style fixes.

> +	lo = reg_read(etsects, TMR_CNT_L);
> +	hi = reg_read(etsects, TMR_CNT_H);
> +	ns = ((u64) hi) << 32;
> +	ns |= lo;
> +	return ns;
> +}
> +
> +static void tmr_cnt_write(struct etsects *etsects, u64 ns)
> +{
> +	u32 hi = ns >> 32;
> +	u32 lo = ns & 0xffffffff;

Ditto.

> +	reg_write(etsects, TMR_CNT_L, lo);
> +	reg_write(etsects, TMR_CNT_H, hi);
> +}
> +
> +static void set_alarm(struct etsects *etsects)
> +{
> +	u64 ns;
> +	u32 lo, hi;

Ditto.

> +	ns = tmr_cnt_read(etsects) + 1500000000ULL;
> +	ns = div_u64(ns, 1000000000UL) * 1000000000ULL;
> +	ns -= etsects->tclk_period;
> +	hi = ns >> 32;
> +	lo = ns & 0xffffffff;
> +	reg_write(etsects, TMR_ALARM1_L, lo);
> +	reg_write(etsects, TMR_ALARM1_H, hi);
> +}
> +
> +static void set_fipers(struct etsects *etsects)
> +{
> +	u32 tmr_ctrl = reg_read(etsects, TMR_CTRL);
> +
> +	reg_write(etsects, TMR_CTRL,   tmr_ctrl & (~TE));
> +	reg_write(etsects, TMR_PRSC,   etsects->tmr_prsc);
> +	reg_write(etsects, TMR_FIPER1, 0x3B9AC9F6);
> +	reg_write(etsects, TMR_FIPER2, 0x00018696);
> +	set_alarm(etsects);
> +	reg_write(etsects, TMR_CTRL,   tmr_ctrl|TE);
> +}

These hardcode values should be replaced with values derived from the
input clock frequency, clock period, etc.

> +/*
> + * PTP clock operations
> + */
> +
> +static int ptp_gianfar_adjfreq(void *priv, s32 ppb)
> +{
> +	u64 adj;
> +	u32 diff, tmr_add;
> +	int neg_adj = 0;
> +	struct etsects *etsects = priv;
> +
> +	if (!ppb)
> +		return 0;
> +
> +	if (ppb < 0) {
> +		neg_adj = 1;
> +		ppb = -ppb;
> +	}
> +	tmr_add = etsects->tmr_add;
> +	adj = tmr_add;
> +	adj *= ppb;
> +	diff = div_u64(adj, 1000000000ULL);
> +
> +	tmr_add = neg_adj ? tmr_add - diff : tmr_add + diff;
> +
> +	reg_write(etsects, TMR_ADD, tmr_add);
> +
> +	return 0;
> +}
> +
> +static int ptp_gianfar_adjtime(void *priv, struct timespec *ts)
> +{
> +	s64 delta, now;
> +	unsigned long flags;
> +	struct etsects *etsects = priv;
> +
> +	delta = 1000000000LL * ts->tv_sec;
> +	delta += ts->tv_nsec;
> +
> +	spin_lock_irqsave(&adjtime_lock, flags);
> +
> +	now = tmr_cnt_read(etsects);
> +	now += delta;
> +	tmr_cnt_write(etsects, now);
> +
> +	spin_unlock_irqrestore(&adjtime_lock, flags);
> +
> +	set_fipers(etsects);
> +
> +	return 0;
> +}
> +
> +static int ptp_gianfar_gettime(void *priv, struct timespec *ts)
> +{
> +	u64 ns;
> +	u32 remainder;
> +	struct etsects *etsects = priv;

Empty line?

> +	ns = tmr_cnt_read(etsects);
> +	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
> +	ts->tv_nsec = remainder;
> +	return 0;
> +}
> +
> +static int ptp_gianfar_settime(void *priv, struct timespec *ts)
> +{
> +	u64 ns;
> +	struct etsects *etsects = priv;

Ditto.

> +	ns = ts->tv_sec * 1000000000ULL;
> +	ns += ts->tv_nsec;
> +	tmr_cnt_write(etsects, ns);
> +	set_fipers(etsects);
> +	return 0;
> +}
> +
> +static int ptp_gianfar_enable(void *priv, struct ptp_clock_request rq, int on)
> +{
> +	/* We do not (yet) offer any ancillary features. */
> +	return -EINVAL;
> +}
> +
> +struct ptp_clock_info ptp_gianfar_caps = {
> +	.owner		= THIS_MODULE,
> +	.name		= "gianfar clock",
> +	.max_adj	= 512000,
> +	.n_alarm	= 0,
> +	.n_ext_ts	= 0,
> +	.n_per_out	= 0,
> +	.pps		= 0,
> +	.priv		= &the_clock,
> +	.adjfreq	= ptp_gianfar_adjfreq,
> +	.adjtime	= ptp_gianfar_adjtime,
> +	.gettime	= ptp_gianfar_gettime,
> +	.settime	= ptp_gianfar_settime,
> +	.enable		= ptp_gianfar_enable,
> +};
> +
> +/* module operations */
> +
> +static void __exit ptp_gianfar_exit(void)
> +{
> +	ptp_clock_unregister(&ptp_gianfar_caps);
> +	iounmap(the_clock.regs);
> +}

Maybe some more cleanup is necessary, e.g. stopping the PPS.

> +static int __init ptp_gianfar_init(void)
> +{
> +	struct etsects *etsects = &the_clock;
> +	struct timespec now;
> +	phys_addr_t reg_addr = TMR_BASE_KERNEL;
> +	unsigned long reg_size = REG_SIZE;
> +	u32 tmr_ctrl;
> +	int err;
> +
> +	etsects->regs = ioremap(reg_addr, reg_size);
> +	if (!etsects->regs) {
> +		pr_err("ioremap ptp registers failed\n");
> +		return -EINVAL;
> +	}
> +	etsects->timer_osc = TIMER_OSC;
> +	etsects->tclk_period = TCLK_PERIOD;
> +	etsects->nominal_freq = NOMINAL_FREQ;
> +	etsects->tmr_prsc = DEF_TMR_PRSC;
> +	etsects->tmr_add = DEF_TMR_ADD;
> +	etsects->cksel = DEFAULT_CKSEL;
> +
> +	tmr_ctrl =
> +	  (etsects->tclk_period & TCLK_PERIOD_MASK) << TCLK_PERIOD_SHIFT |
> +	  (etsects->cksel & CKSEL_MASK) << CKSEL_SHIFT;
> +
> +	getnstimeofday(&now);
> +	ptp_gianfar_settime(etsects, &now);
> +
> +	reg_write(etsects, TMR_CTRL,   tmr_ctrl);
> +	reg_write(etsects, TMR_ADD,    etsects->tmr_add);
> +	reg_write(etsects, TMR_PRSC,   etsects->tmr_prsc);
> +	reg_write(etsects, TMR_FIPER1, 0x3B9AC9F6);
> +	reg_write(etsects, TMR_FIPER2, 0x00018696);
> +	set_alarm(etsects);
> +	reg_write(etsects, TMR_CTRL,   tmr_ctrl|FS|RTPE|TE);
> +
> +	err = ptp_clock_register(&ptp_gianfar_caps);
> +	return err;
> +}
> +
> +subsys_initcall(ptp_gianfar_init);
> +module_exit(ptp_gianfar_exit);

As already mentioned, ptp_clock_register() did fail when this driver is
statically linked into the kernel.

Wolfgang.
