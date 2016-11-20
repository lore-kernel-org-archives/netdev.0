From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH v2 1/2] macb: Add 1588 support in Cadence GEM.
Date: Sun, 20 Nov 2016 20:18:24 +0100
Message-ID: <20161120191823.GA6950@localhost.localdomain>
References: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tbultel@pixelsurmer.com, boris.brezillon@free-electrons.com,
 netdev@vger.kernel.org, alexandre.belloni@free-electrons.com,
 nicolas.ferre@atmel.com, linux-kernel@vger.kernel.org,
 harinikatakamlinux@gmail.com, michals@xilinx.com, anirudh@xilinx.com,
 punnaia@xilinx.com, harini.katakam@xilinx.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
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

On Fri, Nov 18, 2016 at 03:21:51PM +0100, Andrei Pistirica wrote:
> - Frequency adjustment is not directly supported by this IP.

This statement still makes no sense.  Doesn't the following text...

>   addend is the initial value ns increment and similarly addendesub.
>   The ppb (parts per billion) provided is used as
>   ns_incr = addend +/- (ppb/rate).
>   Similarly the remainder of the above is used to populate subns increment.

describe how frequency adjustment is in fact supported?

> +config MACB_USE_HWSTAMP
> +	bool "Use IEEE 1588 hwstamp"
> +	depends on MACB
> +	default y
> +	select PTP_1588_CLOCK

This "select" pattern is going to be replaced with "imply" soon.

   http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1269181.html

You should use the new "imply" key word and reference that series in
your change log.

> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 3f385ab..2ee9af8 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -10,6 +10,10 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +#include <linux/net_tstamp.h>
> +#include <linux/ptp_clock.h>
> +#include <linux/ptp_clock_kernel.h>

Don't need net_tstamp.h here.  Move it into the .c file please.

> @@ -840,8 +902,26 @@ struct macb {
>  
>  	unsigned int		rx_frm_len_mask;
>  	unsigned int		jumbo_max_len;
> +
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +	unsigned int		hwts_tx_en;
> +	unsigned int		hwts_rx_en;

These two can be bool'eans.

> +	spinlock_t		tsu_clk_lock;
> +	unsigned int		tsu_rate;
> +
> +	struct ptp_clock	*ptp_clock;
> +	struct ptp_clock_info	ptp_caps;
> +	unsigned int		ns_incr;
> +	unsigned int		subns_incr;

These two are 32 bit register values, right?  Then use the u32 type.

> +#endif
>  };

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
> +	spin_lock(&bp->tsu_clk_lock);
> +
> +	/* TSH doesn't latch the time and no atomicity! */
> +	gem_writel(bp, TSH, sech);
> +	gem_writel(bp, TSL, secl);

If TN overflows here then the clock will be off by one whole second!
Why not clear TN first?

> +	gem_writel(bp, TN, ns);
> +
> +	spin_unlock(&bp->tsu_clk_lock);
> +}
> +
> +static int macb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +	u32 addend, addend_frac, rem;
> +	u64 drift_tmr, diff, diff_frac = 0;
> +	int neg_adj = 0;
> +
> +	if (ppb < 0) {
> +		neg_adj = 1;
> +		ppb = -ppb;
> +	}
> +
> +	/* drift/period */
> +	drift_tmr = (bp->ns_incr * ppb) +
> +		    ((bp->subns_incr * ppb) >> 16);

What?  Why the 16 bit shift?  Last time your said it was 24 bits.

> +	/* drift/cycle */
> +	diff = div_u64_rem(drift_tmr, 1000000000ULL, &rem);
> +
> +	/* drift fraction/cycle, if necessary */
> +	if (rem) {
> +		u64 fraction = rem;
> +		fraction = fraction << 16;
> +
> +		diff_frac = div_u64(fraction, 1000000000ULL);

If you use a combined tuning word like I explained last time, then you
will not need a second division.

Also, please use the new adjfine() PHC method, as adjfreq() is now deprecated.

> +	}
> +
> +	/* adjustmets */
> +	addend = neg_adj ? (bp->ns_incr - diff) : (bp->ns_incr + diff);
> +	addend_frac = neg_adj ? (bp->subns_incr - diff_frac) :
> +				(bp->subns_incr + diff_frac);
> +
> +	spin_lock(&bp->tsu_clk_lock);
> +
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, addend_frac));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, addend));
> +
> +	spin_unlock(&bp->tsu_clk_lock);
> +	return 0;
> +}

> +void macb_ptp_init(struct net_device *ndev)
> +{
> +	struct macb *bp = netdev_priv(ndev);
> +	struct timespec64 now;
> +	u32 rem = 0;
> +
> +	if (!(bp->caps | MACB_CAPS_GEM_HAS_PTP)){
> +		netdev_vdbg(bp->dev, "Platform does not support PTP!\n");
> +		return;
> +	}
> +
> +	spin_lock_init(&bp->tsu_clk_lock);
> +
> +	bp->ptp_caps = macb_ptp_caps;
> +	bp->tsu_rate = clk_get_rate(bp->pclk);
> +
> +	getnstimeofday64(&now);
> +	macb_tsu_set_time(bp, (const struct timespec64 *)&now);
> +
> +	bp->ns_incr = div_u64_rem(NSEC_PER_SEC, bp->tsu_rate, &rem);
> +	if (rem) {
> +		u64 adj = rem;
> +		/* Multiply by 2^16 as subns register is 16 bits */

Last time you said:
> +		/* Multiple by 2^24 as subns field is 24 bits */

> +		adj <<= 16;
> +		bp->subns_incr = div_u64(adj, bp->tsu_rate);
> +	} else {
> +		bp->subns_incr = 0;
> +	}
> +
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, bp->subns_incr));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, bp->ns_incr));
> +	gem_writel(bp, TA, 0);
> +
> +	bp->ptp_clock = ptp_clock_register(&bp->ptp_caps, NULL);

You call regsiter, but you never call unregister!

> +	if (IS_ERR(&bp->ptp_clock)) {
> +		bp->ptp_clock = NULL;
> +		pr_err("ptp clock register failed\n");
> +		return;
> +	}
> +
> +	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n", GMAC_TIMER_NAME);
> +}
> +
> -- 
> 1.9.1
> 

Thanks,
Richard
