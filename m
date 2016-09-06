From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH 1/2] macb: Add 1588 support in Cadence GEM.
Date: Tue, 6 Sep 2016 17:48:09 +0200
Message-ID: <20160906154809.GA7012@localhost.localdomain>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tbultel@pixelsurmer.com, boris.brezillon@free-electrons.com,
 Harini Katakam <harinik@xilinx.com>, netdev@vger.kernel.org,
 alexandre.belloni@free-electrons.com, nicolas.ferre@atmel.com,
 linux-kernel@vger.kernel.org, harinikatakamlinux@gmail.com, michals@xilinx.com,
 anirudh@xilinx.com, punnaia@xilinx.com, harini.katakam@xilinx.com,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


I have some issues with this patch...

On Fri, Sep 02, 2016 at 02:53:36PM +0200, Andrei Pistirica wrote:

> - Frequency adjustment is not directly supported by this IP.
>   addend is the initial value ns increment and similarly addendesub.
>   The ppb (parts per billion) provided is used as
>   ns_incr = addend +/- (ppb/rate).
>   Similarly the remainder of the above is used to populate subns increment.
>   In case the ppb requested is negative AND subns adjustment greater than
>   the addendsub, ns_incr is reduced by 1 and subns_incr is adjusted in
>   positive accordingly.

This makes no sense.  If you cannot adjust the frequency, then you
must implement a timecounter/cyclecounter and do in software.

> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 3f385ab..8c3779d 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -10,6 +10,12 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +#include <linux/net_tstamp.h>
> +#include <linux/ptp_clock.h>
> +#include <linux/ptp_clock_kernel.h>
> +#include <linux/skbuff.h>
> +#include <linux/timecounter.h>

Here in the header file, you only need ptp_clock_kernel.h.  You don't
need all the others here.  Move them to the .c file, but only if
really needed.  (timecounter.h isn't used, now is it?)

> @@ -129,6 +135,20 @@
>  #define GEM_RXIPCCNT		0x01a8 /* IP header Checksum Error Counter */
>  #define GEM_RXTCPCCNT		0x01ac /* TCP Checksum Error Counter */
>  #define GEM_RXUDPCCNT		0x01b0 /* UDP Checksum Error Counter */

> +#define GEM_TISUBN		0x01bc /* 1588 Timer Increment Sub-ns */

This regsiter does not exist.  Looking at
 
   Zynq-7000 AP SoC Technical Reference Manual
   UG585 (v1.10) February 23, 2015

starting on page 1273 we see:

udp_csum_errors 0x000001B0 32 ro    0x00000000 UDP checksum error
timer_strobe_s  0x000001C8 32 rw    0x00000000 1588 timer sync strobe seconds
timer_strobe_ns 0x000001CC 32 mixed 0x00000000 1588 timer sync strobe nanoseconds
timer_s         0x000001D0 32 rw    0x00000000 1588 timer seconds
timer_ns        0x000001D4 32 mixed 0x00000000 1588 timer nanoseconds
timer_adjust    0x000001D8 32 mixed 0x00000000 1588 timer adjust
timer_incr      0x000001DC 32 mixed 0x00000000 1588 timer increment

There is no register at 0x1BC.

> +#define GEM_TSH			0x01c0 /* 1588 Timer Seconds High */

This one doesn't exist either.  What is going on here?

> +#define GEM_TSL			0x01d0 /* 1588 Timer Seconds Low */
> +#define GEM_TN			0x01d4 /* 1588 Timer Nanoseconds */
> +#define GEM_TA			0x01d8 /* 1588 Timer Adjust */
> +#define GEM_TI			0x01dc /* 1588 Timer Increment */
> +#define GEM_EFTSL		0x01e0 /* PTP Event Frame Tx Seconds Low */
> +#define GEM_EFTN		0x01e4 /* PTP Event Frame Tx Nanoseconds */
> +#define GEM_EFRSL		0x01e8 /* PTP Event Frame Rx Seconds Low */
> +#define GEM_EFRN		0x01ec /* PTP Event Frame Rx Nanoseconds */
> +#define GEM_PEFTSL		0x01f0 /* PTP Peer Event Frame Tx Secs Low */
> +#define GEM_PEFTN		0x01f4 /* PTP Peer Event Frame Tx Ns */
> +#define GEM_PEFRSL		0x01f8 /* PTP Peer Event Frame Rx Sec Low */
> +#define GEM_PEFRN		0x01fc /* PTP Peer Event Frame Rx Ns */

BTW, it is really annoying that you invent new register names.  Why
can't you use the names from the TRM?

> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +void macb_ptp_init(struct net_device *ndev);
> +#else
> +void macb_ptp_init(struct net_device *ndev) { }

This should be static inline.

> +#endif

> diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
> new file mode 100644
> index 0000000..6d6a6ec
> --- /dev/null
> +++ b/drivers/net/ethernet/cadence/macb_ptp.c
> @@ -0,0 +1,224 @@
> +/*
> + * PTP 1588 clock for SAMA5D2 platform.
> + *
> + * Copyright (C) 2015 Xilinx Inc.
> + * Copyright (C) 2016 Microchip Technology
> + *
> + * Authors: Harini Katakam <harinik@xilinx.com>
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/device.h>
> +#include <linux/etherdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/time64.h>
> +#include <linux/ptp_classify.h>
> +#include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
> +
> +#include "macb.h"
> +
> +#define  GMAC_TIMER_NAME "gmac-ptp"
> +
> +static inline void macb_tsu_get_time(struct macb *bp, struct timespec64 *ts)
> +{
> +	u64 sech, secl;
> +
> +	/* get GEM internal time */
> +	sech = gem_readl(bp, TSH);
> +	secl = gem_readl(bp, TSL);

Does reading TSH latch the time?  The TRM is silent about that, and
most other designs latch on reading the LSB.

> +	ts->tv_sec = (sech << 32) | secl;
> +	ts->tv_nsec = gem_readl(bp, TN);
> +}
> +
> +static inline void macb_tsu_set_time(struct macb *bp,
> +				     const struct timespec64 *ts)
> +{
> +	u32 ns, sech, secl;
> +	s64 word_mask = 0xffffffff;
> +
> +	sech = (u32)ts->tv_sec;
> +	secl = (u32)ts->tv_sec;
> +	ns = ts->tv_nsec;
> +	if (ts->tv_sec > word_mask)
> +		sech = (ts->tv_sec >> 32);
> +
> +	/* set GEM internal time */

Writing three registers is supposed to be one operation, and yet you
have no mutex or spinlock to protect against concurrent settime calls.

> +	gem_writel(bp, TSH, sech);
> +	gem_writel(bp, TSL, secl);
> +	gem_writel(bp, TN, ns);

Also, how does the HW behave here?  Latch on TN write?

> +}
> +
> +static int macb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +	unsigned long rate = bp->tsu_rate;
> +	u64 adjsub;
> +	u32 addend, addendsub, diff, rem, diffsub, subnsreg;
> +	bool neg_adj = false;
> +
> +	if (ppb < 0) {
> +		neg_adj = true;
> +		ppb = -ppb;
> +	}
> +
> +	addend = bp->ns_incr;
> +	addendsub = bp->subns_incr;
> +
> +	diff = div_u64_rem(ppb, rate, &rem);

One ...

> +	addend = neg_adj ? addend - diff : addend + diff;
> +
> +	if (rem) {
> +		adjsub = rem;
> +		/* Multiple by 2^24 as subns field is 24 bits */
> +		adjsub = adjsub << 24;
> +
> +		diffsub = div_u64(adjsub, rate);

... Two ...

> +	} else {
> +		diffsub = 0;
> +	}
> +
> +	if (neg_adj && (diffsub > addendsub)) {
> +		addend -= 1;
> +		rem = (NSEC_PER_SEC - rem);
> +		neg_adj = false;
> +
> +		adjsub = rem;
> +		adjsub = adjsub << 24;
> +		diffsub = div_u64(adjsub, rate);

Three.  You need three 64 bit divisions?  There must be a better way.

If I guess correctly, the nsincr/subnsincr value is added to the
device's time on every clock.  So scaling these effectively adjusts
the frequency.  Here is an idea for you.

You have a 24 bit fractional field.  Combine that with 8 bits of whole
nanoseconds to form one 32 tuning word.  Restrict the nanoseconds to 8
bits in the setup code. (8 bits allows input clocks down to 4 MHz.)

Multiply the tuning word by the 32 ppb variable, keeping the 64 bit
result.  Divide the result by 10^9 and that gives you the delta to add
to (or subtract from) the nominal tuning word.

See gianfar.c for an example.

> +	}
> +
> +	addendsub = neg_adj ? addendsub - diffsub : addendsub + diffsub;
> +	/* RegBit[15:0] = Subns[23:8]; RegBit[31:24] = Subns[7:0] */
> +	subnsreg = ((addendsub & GEM_SUBNSINCL_MASK) << GEM_SUBNSINCL_SHFT) |
> +		   ((addendsub & GEM_SUBNSINCH_MASK) >> GEM_SUBNSINCH_SHFT);
> +
> +	gem_writel(bp, TISUBN, subnsreg);
> +	gem_writel(bp, TI, GEM_BF(NSINCR, addend));
> +
> +	return 0;
> +}

Thanks,
Richard
