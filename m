From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 2/4] net: fec: ptp: Use hardware algorithm to adjust
 PTP counter.
Date: Thu, 25 Sep 2014 16:29:23 +0200
Message-ID: <20140925142923.GA21453@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-3-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:65235 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbaIYO33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 10:29:29 -0400
Received: by mail-wi0-f179.google.com with SMTP id d1so9582491wiv.0
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 07:29:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411632621-17429-3-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 04:10:19PM +0800, Luwei Zhou wrote:
> The FEC IP supports hardware adjustment for ptp timer. Refer to the description of
> ENET_ATCOR and ENET_ATINC registers in the spec about the hardware adjustment. This
> patch uses hardware support to adjust the ptp offset and frequency on the slave side.
> 
> Signed-off-by: Luwei Zhou <b45643@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Fugang Duan <b38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_ptp.c | 68 +++++++++++++++++++++++++++-----
>  1 file changed, 58 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index 8016bdd..e2bf786 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -71,6 +71,7 @@
>  
>  #define FEC_CC_MULT	(1 << 31)
>  #define FEC_COUNTER_PERIOD	(1 << 31)
> +#define FEC_T_PERIOD_ONE_SEC	(1000000000UL)

Why not use NSEC_PER_USEC?

>  /**
>   * fec_ptp_read - read raw cycle counter (to be used by time counter)
>   * @cc: the cyclecounter structure
> @@ -145,33 +146,65 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
>   */
>  static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
>  {
> -	u64 diff;
>  	unsigned long flags;
>  	int neg_adj = 0;
> -	u32 mult = FEC_CC_MULT;
> +	u32 i, tmp;
> +	u32 ptp_ts_clk, ptp_inc;
> +	u32 corr_inc, corr_period;
> +	u32 corr_ns;
>  
>  	struct fec_enet_private *fep =
>  	    container_of(ptp, struct fec_enet_private, ptp_caps);
>  
> +	if (ppb == 0)
> +		return 0;
> +
>  	if (ppb < 0) {
>  		ppb = -ppb;
>  		neg_adj = 1;
>  	}
>  
> -	diff = mult;
> -	diff *= ppb;
> -	diff = div_u64(diff, 1000000000ULL);
> +	ptp_ts_clk = clk_get_rate(fep->clk_ptp);
> +	ptp_inc = FEC_T_PERIOD_ONE_SEC / ptp_ts_clk;

No need to calculate this every time.

> +
> +	/*
> +	 * In theory, corr_inc/corr_period = ppb/FEC_T_PERIOD_ONE_SEC;
> +	 * Try to find the corr_inc  between 1 to ptp_inc to meet adjustment
> +	 * requirement.
> +	 */
> +	for (i = 1; i <= ptp_inc; i++) {
> +		if (((i * FEC_T_PERIOD_ONE_SEC) / ppb) >= ptp_inc) {

Does this code even work?

(i * FEC_T_PERIOD_ONE_SEC) overflows when i > 4.

Does this code even compile? You don't use div_u64().

Also, remember that this code is a performance critical path. You have
a 64 bit division in every loop iteration. With a high Sync rate, this
function will be called many times per second. You should really
optimize here.

Instead of testing for

	i * FEC_T_PERIOD_ONE_SEC / ppb >= ptp_inc

why not something like

	u64 lhs = NSEC_PER_USEC, rhs = ptp_inc * ppb;

	for (i = 1; i <= ptp_inc; i++) {
		if (lhs >= rhs) {
			...
		}
		lhs += NSEC_PER_USEC;
	}

instead?

> +			corr_inc = i;
> +			corr_period = ((i * FEC_T_PERIOD_ONE_SEC) /
> +						(ptp_inc * ppb));

32 bit overflow again.

> +			break;
> +		}
> +	}
> +	/*
> +	 * Not found? Set it to high value - double speed
> +	 * correct in every clock step.
> +	 */
> +	if (i > ptp_inc) {
> +		corr_inc = ptp_inc;
> +		corr_period = 1;
> +	}
> +
> +	if (neg_adj)
> +		corr_ns = ptp_inc - corr_inc;
> +	else
> +		corr_ns = ptp_inc + corr_inc;
>  
>  	spin_lock_irqsave(&fep->tmreg_lock, flags);
> +
> +	tmp = readl(fep->hwp + FEC_ATIME_INC) & FEC_T_INC_MASK;
> +	tmp |= corr_ns << FEC_T_INC_CORR_OFFSET;
> +	writel(tmp, fep->hwp + FEC_ATIME_INC);
> +	writel(corr_period, fep->hwp + FEC_ATIME_CORR);
>  	/*
> -	 * dummy read to set cycle_last in tc to now.
> -	 * So use adjusted mult to calculate when next call
> -	 * timercounter_read.
> +	 * dummy read to update the timer.
>  	 */
>  	timecounter_read(&fep->tc);
>  
> -	fep->cc.mult = neg_adj ? mult - diff : mult + diff;
> -
>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>  
>  	return 0;
> @@ -190,12 +223,20 @@ static int fec_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
>  	    container_of(ptp, struct fec_enet_private, ptp_caps);
>  	unsigned long flags;
>  	u64 now;
> +	u32 counter;
>  
>  	spin_lock_irqsave(&fep->tmreg_lock, flags);
>  
>  	now = timecounter_read(&fep->tc);
>  	now += delta;
>  
> +	/*
> +	 * Get the timer value based on adjusted timestamp.
> +	 * Update the counter with the masked value.
> +	 */
> +	counter = now & fep->cc.mask;
> +	writel(counter, fep->hwp + FEC_ATIME);

Why is this needed?

Thanks,
Richard


> +
>  	/* reset the timecounter */
>  	timecounter_init(&fep->tc, &fep->cc, now);
>  
> @@ -246,6 +287,7 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>  
>  	u64 ns;
>  	unsigned long flags;
> +	u32 counter;
>  
>  	mutex_lock(&fep->ptp_clk_mutex);
>  	/* Check the ptp clock */
> @@ -256,8 +298,14 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>  
>  	ns = ts->tv_sec * 1000000000ULL;
>  	ns += ts->tv_nsec;
> +	/*
> +	 * Get the timer value based on timestamp.
> +	 * Update the counter with the masked value.
> +	 */
> +	counter = ns & fep->cc.mask;
>  
>  	spin_lock_irqsave(&fep->tmreg_lock, flags);
> +	writel(counter, fep->hwp + FEC_ATIME);
>  	timecounter_init(&fep->tc, &fep->cc, ns);
>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>  	mutex_unlock(&fep->ptp_clk_mutex);
> -- 
> 1.9.1
> 
