From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: Re: [RFC PATCH v2 1/2] macb: Add 1588 support in Cadence GEM.
Date: Wed, 23 Nov 2016 14:34:03 +0100
Message-ID: <e592169a-6287-7f3c-b4fd-23c4c79198b0@microchip.com>
References: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
 <20161120191823.GA6950@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
        <harini.katakam@xilinx.com>, <punnaia@xilinx.com>,
        <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161120191823.GA6950@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 20.11.2016 20:18, Richard Cochran wrote:
> On Fri, Nov 18, 2016 at 03:21:51PM +0100, Andrei Pistirica wrote:
>> - Frequency adjustment is not directly supported by this IP.
>
> This statement still makes no sense.  Doesn't the following text...

This statement is inherited from original patch, and it refers to the 
fact that it doesn't change directly the frequency, it changes the 
increment value.
I'll remove it to avoid any confusion.

>
>>   addend is the initial value ns increment and similarly addendesub.
>>   The ppb (parts per billion) provided is used as
>>   ns_incr = addend +/- (ppb/rate).
>>   Similarly the remainder of the above is used to populate subns increment.
>
> describe how frequency adjustment is in fact supported?

Ack, I will clarify.

>
>> +config MACB_USE_HWSTAMP
>> +	bool "Use IEEE 1588 hwstamp"
>> +	depends on MACB
>> +	default y
>> +	select PTP_1588_CLOCK
>
> This "select" pattern is going to be replaced with "imply" soon.
>
>    http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1269181.html
>
> You should use the new "imply" key word and reference that series in
> your change log.

Ack.

>
>> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
>> index 3f385ab..2ee9af8 100644
>> --- a/drivers/net/ethernet/cadence/macb.h
>> +++ b/drivers/net/ethernet/cadence/macb.h
>> @@ -10,6 +10,10 @@
>>  #ifndef _MACB_H
>>  #define _MACB_H
>>
>> +#include <linux/net_tstamp.h>
>> +#include <linux/ptp_clock.h>
>> +#include <linux/ptp_clock_kernel.h>
>
> Don't need net_tstamp.h here.  Move it into the .c file please.

Ack.

>
>> @@ -840,8 +902,26 @@ struct macb {
>>
>>  	unsigned int		rx_frm_len_mask;
>>  	unsigned int		jumbo_max_len;
>> +
>> +#ifdef CONFIG_MACB_USE_HWSTAMP
>> +	unsigned int		hwts_tx_en;
>> +	unsigned int		hwts_rx_en;
>
> These two can be bool'eans.

Ack.

>
>> +	spinlock_t		tsu_clk_lock;
>> +	unsigned int		tsu_rate;
>> +
>> +	struct ptp_clock	*ptp_clock;
>> +	struct ptp_clock_info	ptp_caps;
>> +	unsigned int		ns_incr;
>> +	unsigned int		subns_incr;
>
> These two are 32 bit register values, right?  Then use the u32 type.

Yes. I will make the change.

>
>> +#endif
>>  };
>
>> +static inline void macb_tsu_set_time(struct macb *bp,
>> +				     const struct timespec64 *ts)
>> +{
>> +	u32 ns, sech, secl;
>> +	s64 word_mask = 0xffffffff;
>> +
>> +	sech = (u32)ts->tv_sec;
>> +	secl = (u32)ts->tv_sec;
>> +	ns = ts->tv_nsec;
>> +	if (ts->tv_sec > word_mask)
>> +		sech = (ts->tv_sec >> 32);
>> +
>> +	spin_lock(&bp->tsu_clk_lock);
>> +
>> +	/* TSH doesn't latch the time and no atomicity! */
>> +	gem_writel(bp, TSH, sech);
>> +	gem_writel(bp, TSL, secl);
>
> If TN overflows here then the clock will be off by one whole second!
> Why not clear TN first?

Ack.

>
>> +	gem_writel(bp, TN, ns);
>> +
>> +	spin_unlock(&bp->tsu_clk_lock);
>> +}
>> +
>> +static int macb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
>> +{
>> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
>> +	u32 addend, addend_frac, rem;
>> +	u64 drift_tmr, diff, diff_frac = 0;
>> +	int neg_adj = 0;
>> +
>> +	if (ppb < 0) {
>> +		neg_adj = 1;
>> +		ppb = -ppb;
>> +	}
>> +
>> +	/* drift/period */
>> +	drift_tmr = (bp->ns_incr * ppb) +
>> +		    ((bp->subns_incr * ppb) >> 16);
>
> What?  Why the 16 bit shift?  Last time your said it was 24 bits.

SAMA5D2/3/4 uses GEM-PTP version (16bit), while Harini wrote a driver
for GEM-GXL (24bit). Probably will be a patch on top of this one for 
GXL. This confusion was because I tried to keep the original patch 
unchanged.

>
>> +	/* drift/cycle */
>> +	diff = div_u64_rem(drift_tmr, 1000000000ULL, &rem);
>> +
>> +	/* drift fraction/cycle, if necessary */
>> +	if (rem) {
>> +		u64 fraction = rem;
>> +		fraction = fraction << 16;
>> +
>> +		diff_frac = div_u64(fraction, 1000000000ULL);
>
> If you use a combined tuning word like I explained last time, then you
> will not need a second division.

 From what I understand, your suggestion is:
(ns | frac) * ppb = (total_ns | total_frac)
(total_ns | total_frac) / 10^9 = (adj_ns | adj_frac)
This is correct iff total_ns/10^9 >= 1, but the problem is that there 
are missed fractions due to the following approximation:
frac*ppb =~ 
(ns*ppb+frac*ppb*2^16)*2^16-10^9*2^16*flor(ns*ppb+frac*ppb*2^16, 10^9).

An example which uses values from a real test:
let ppb=4891, ns=12 and frac=3158
- using suggested algorithm, yields: adj_ns = 0 and adj_frac = 0
- using in-place algorithm, yields: adj_ns = 0, adj_frac = 4
You can check the calculus.

Therefore, I would like to keep the in-place algorithm.

>
> Also, please use the new adjfine() PHC method, as adjfreq() is now deprecated.

Yes, I will port the patches on net-next and use adjfine.

>
>> +	}
>> +
>> +	/* adjustmets */
>> +	addend = neg_adj ? (bp->ns_incr - diff) : (bp->ns_incr + diff);
>> +	addend_frac = neg_adj ? (bp->subns_incr - diff_frac) :
>> +				(bp->subns_incr + diff_frac);
>> +
>> +	spin_lock(&bp->tsu_clk_lock);
>> +
>> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, addend_frac));
>> +	gem_writel(bp, TI, GEM_BF(NSINCR, addend));
>> +
>> +	spin_unlock(&bp->tsu_clk_lock);
>> +	return 0;
>> +}
>
>> +void macb_ptp_init(struct net_device *ndev)
>> +{
>> +	struct macb *bp = netdev_priv(ndev);
>> +	struct timespec64 now;
>> +	u32 rem = 0;
>> +
>> +	if (!(bp->caps | MACB_CAPS_GEM_HAS_PTP)){
>> +		netdev_vdbg(bp->dev, "Platform does not support PTP!\n");
>> +		return;
>> +	}
>> +
>> +	spin_lock_init(&bp->tsu_clk_lock);
>> +
>> +	bp->ptp_caps = macb_ptp_caps;
>> +	bp->tsu_rate = clk_get_rate(bp->pclk);
>> +
>> +	getnstimeofday64(&now);
>> +	macb_tsu_set_time(bp, (const struct timespec64 *)&now);
>> +
>> +	bp->ns_incr = div_u64_rem(NSEC_PER_SEC, bp->tsu_rate, &rem);
>> +	if (rem) {
>> +		u64 adj = rem;
>> +		/* Multiply by 2^16 as subns register is 16 bits */
>
> Last time you said:
>> +		/* Multiple by 2^24 as subns field is 24 bits */
>
>> +		adj <<= 16;
>> +		bp->subns_incr = div_u64(adj, bp->tsu_rate);
>> +	} else {
>> +		bp->subns_incr = 0;
>> +	}
>> +
>> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, bp->subns_incr));
>> +	gem_writel(bp, TI, GEM_BF(NSINCR, bp->ns_incr));
>> +	gem_writel(bp, TA, 0);
>> +
>> +	bp->ptp_clock = ptp_clock_register(&bp->ptp_caps, NULL);
>
> You call regsiter, but you never call unregister!

Ack. I did a stupid mistake... sorry.

>
>> +	if (IS_ERR(&bp->ptp_clock)) {
>> +		bp->ptp_clock = NULL;
>> +		pr_err("ptp clock register failed\n");
>> +		return;
>> +	}
>> +
>> +	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n", GMAC_TIMER_NAME);
>> +}
>> +
>> --
>> 1.9.1
>>
>
> Thanks,
> Richard
>

Regards,
Andrei
