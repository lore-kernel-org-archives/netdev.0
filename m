From: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Subject: RE: [PATCH v1 2/4] net: fec: ptp: Use hardware algorithm to adjust
 PTP counter.
Date: Fri, 26 Sep 2014 05:53:41 +0000
Message-ID: <cd5a482f0db446f9adce6906b19a9c56@BY2PR03MB441.namprd03.prod.outlook.com>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-3-git-send-email-b45643@freescale.com>
 <20140925142923.GA21453@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0139.outbound.protection.outlook.com ([157.56.110.139]:11584
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753804AbaIZFxq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 01:53:46 -0400
In-Reply-To: <20140925142923.GA21453@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

See my feedback below. Thanks!

-----Original Message-----
From: Richard Cochran [mailto:richardcochran@gmail.com] 
Sent: Thursday, September 25, 2014 10:29 PM
To: Zhou Luwei-B45643
Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org; bhutchings@solarflare.com; Estevam Fabio-R49496; Duan Fugang-B38611; Li Frank-B20596; stephen@networkplumber.org
Subject: Re: [PATCH v1 2/4] net: fec: ptp: Use hardware algorithm to adjust PTP counter.

On Thu, Sep 25, 2014 at 04:10:19PM +0800, Luwei Zhou wrote:
> The FEC IP supports hardware adjustment for ptp timer. Refer to the 
> description of ENET_ATCOR and ENET_ATINC registers in the spec about 
> the hardware adjustment. This patch uses hardware support to adjust the ptp offset and frequency on the slave side.
> 
> Signed-off-by: Luwei Zhou <b45643@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> Signed-off-by: Fugang Duan <b38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_ptp.c | 68 
> +++++++++++++++++++++++++++-----
>  1 file changed, 58 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c 
> b/drivers/net/ethernet/freescale/fec_ptp.c
> index 8016bdd..e2bf786 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -71,6 +71,7 @@
>  
>  #define FEC_CC_MULT	(1 << 31)
>  #define FEC_COUNTER_PERIOD	(1 << 31)
> +#define FEC_T_PERIOD_ONE_SEC	(1000000000UL)

Why not use NSEC_PER_USEC?
[Zhou Luwei-B45643] Will update in the next version.

>  /**
>   * fec_ptp_read - read raw cycle counter (to be used by time counter)
>   * @cc: the cyclecounter structure
> @@ -145,33 +146,65 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
>   */
>  static int fec_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)  {
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
[Zhou Luwei-B45643] Will update in the next version.

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

Also, remember that this code is a performance critical path. You have a 64 bit division in every loop iteration. With a high Sync rate, this function will be called many times per second. You should really optimize here.

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
[Zhou Luwei-B45643] Thanks. It can pass compile without warning and test. In fact I used other tools to increase SYNC rate to 16 per second and it works well. The overflow issue didn't show up maybe because the "i" didn't reach 4 when running the test. I will fix the overflow issue and avoid the div as you mention in the next version.

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

[Zhou Luwei-B45643] This added to support more accurate pps output on the slave side.  The PTP slave side need to adjust offset to sync with master. But the next compare event counter has
Been written to the hardware register and can't modify when slave side need to be adjustment. I will give a example below:

Assuming the next compare event has been set to be 500ns to trigger a  PPS when global PTP time reach 5 second .  When PTP timer run to 200ns, the running PTP stack on the slave side needs to
Adjust 100ns offset after SYNC. If FEC_ATIME is not adjusted with ptp offset, the next PPS event would be triggered at 5second + 100ns not exactly 5 second. 

What I am trying to is to make "ptp timestamp & cc.mask = PTP timer value".

> +
>  	/* reset the timecounter */
>  	timecounter_init(&fep->tc, &fep->cc, now);
>  
> @@ -246,6 +287,7 @@ static int fec_ptp_settime(struct ptp_clock_info 
> *ptp,
>  
>  	u64 ns;
>  	unsigned long flags;
> +	u32 counter;
>  
>  	mutex_lock(&fep->ptp_clk_mutex);
>  	/* Check the ptp clock */
> @@ -256,8 +298,14 @@ static int fec_ptp_settime(struct ptp_clock_info 
> *ptp,
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
