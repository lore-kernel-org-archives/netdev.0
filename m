From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 3/4] net: fec: ptp: Enalbe PPS ouput based on ptp clock
Date: Thu, 25 Sep 2014 16:41:40 +0200
Message-ID: <20140925144140.GB21453@netboy>
References: <1411632621-17429-1-git-send-email-b45643@freescale.com>
 <1411632621-17429-4-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com, R49496@freescale.com,
	b38611@freescale.com, b20596@freescale.com,
	stephen@networkplumber.org
To: Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:36510 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbaIYOlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 10:41:49 -0400
Received: by mail-we0-f171.google.com with SMTP id k48so8041598wev.30
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 07:41:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1411632621-17429-4-git-send-email-b45643@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 04:10:20PM +0800, Luwei Zhou wrote:
> FEC ptp timer has 4 channel compare/trigger function. It can be used to enable pps output.
> The pulse would be ouput high exactly on N second. The pulse ouput high on compare event mode
> is used to produce pulse per second.  The pulse width would be one cycle based on ptp timer clock
> source.Since 31-bit ptp hardware timer is used, the timer will wrap more than 2 seconds. We need to
> reload the compare compare event about every 1 second.
> 
> Signed-off-by: Luwei Zhou <b45643@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      |   7 +
>  drivers/net/ethernet/freescale/fec_main.c |   2 +
>  drivers/net/ethernet/freescale/fec_ptp.c  | 223 +++++++++++++++++++++++++++++-
>  3 files changed, 231 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
> index 26fb1de..f8e23e6 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -481,12 +481,19 @@ struct fec_enet_private {
>  	unsigned int tx_pkts_itr;
>  	unsigned int tx_time_itr;
>  	unsigned int itr_clk_rate;
> +
> +	/* pps  */
> +	int pps_channel;
> +	unsigned int reload_period;
> +	int pps_enable;
> +	unsigned int next_counter;
>  };
>  
>  void fec_ptp_init(struct platform_device *pdev);
>  void fec_ptp_start_cyclecounter(struct net_device *ndev);
>  int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);
>  int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr);
> +uint fec_ptp_check_pps_event(struct fec_enet_private *fep);
>  
>  /****************************************************************************/
>  #endif /* FEC_H */
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 3a4ec0f..5a4ce36 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1558,6 +1558,8 @@ fec_enet_interrupt(int irq, void *dev_id)
>  		complete(&fep->mdio_done);
>  	}
>  
> +	fec_ptp_check_pps_event(fep);
> +
>  	return ret;
>  }
>  
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index e2bf786..c55239d 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -61,6 +61,24 @@
>  #define FEC_T_INC_CORR_MASK             0x00007f00
>  #define FEC_T_INC_CORR_OFFSET           8
>  
> +#define FEC_T_CTRL_PINPER		0x00000080
> +#define FEC_T_TF0_MASK			0x00000001
> +#define FEC_T_TF0_OFFSET		0
> +#define FEC_T_TF1_MASK			0x00000002
> +#define FEC_T_TF1_OFFSET		1
> +#define FEC_T_TF2_MASK			0x00000004
> +#define FEC_T_TF2_OFFSET		2
> +#define FEC_T_TF3_MASK			0x00000008
> +#define FEC_T_TF3_OFFSET		3
> +#define FEC_T_TDRE_MASK			0x00000001
> +#define FEC_T_TDRE_OFFSET		0
> +#define FEC_T_TMODE_MASK		0x0000003C
> +#define FEC_T_TMODE_OFFSET		2
> +#define FEC_T_TIE_MASK			0x00000040
> +#define FEC_T_TIE_OFFSET		6
> +#define FEC_T_TF_MASK			0x00000080
> +#define FEC_T_TF_OFFSET			7
> +
>  #define FEC_ATIME_CTRL		0x400
>  #define FEC_ATIME		0x404
>  #define FEC_ATIME_EVT_OFFSET	0x408
> @@ -69,9 +87,162 @@
>  #define FEC_ATIME_INC		0x414
>  #define FEC_TS_TIMESTAMP	0x418
>  
> +#define FEC_TGSR		0x604
> +#define FEC_TCSR(n)		(0x608 + n * 0x08)
> +#define FEC_TCCR(n)		(0x60C + n * 0x08)
> +#define MAX_TIMER_CHANNEL	3
> +#define FEC_TMODE_TOGGLE	0x05
> +#define FEC_HIGH_PULSE		0x0F
> +
>  #define FEC_CC_MULT	(1 << 31)
>  #define FEC_COUNTER_PERIOD	(1 << 31)
>  #define FEC_T_PERIOD_ONE_SEC	(1000000000UL)
> +#define PPS_OUPUT_RELOAD_PERIOD	FEC_T_PERIOD_ONE_SEC
> +
> +/**
> + * fec_ptp_enable_pps
> + * @fep: the fec_enet_private structure handle
> + * @enable: enable the channel pps output
> + *
> + * This function enble the PPS ouput on the timer channel.
> + */
> +static int fec_ptp_enable_pps(struct fec_enet_private *fep, uint enable)
> +{
> +	unsigned long flags;
> +	u32 val, tempval;
> +	int inc;
> +	struct timespec ts;
> +	u64 ns;
> +	u32 remainder;
> +	val = 0;
> +
> +	if (fep->pps_channel == -1 || fep->pps_channel > MAX_TIMER_CHANNEL) {
> +		dev_err(&fep->pdev->dev, "Invalid pps channel\n");
> +		return -EINVAL;
> +	}
> +
> +	if (!(fep->hwts_tx_en || fep->hwts_rx_en)) {
> +		dev_err(&fep->pdev->dev, "No ptp stack is running\n");
> +		return -EINVAL;
> +	}
> +
> +	if (fep->pps_enable == enable)
> +		return 0;
> +
> +	fep->reload_period = PPS_OUPUT_RELOAD_PERIOD;
> +	inc = FEC_T_PERIOD_ONE_SEC / clk_get_rate(fep->clk_ptp);
> +
> +	spin_lock_irqsave(&fep->tmreg_lock, flags);
> +
> +	if (enable) {
> +		/*
> +		 * clear capture or output compare interrupt status if have.
> +		 */
> +		writel(FEC_T_TF_MASK, fep->hwp + FEC_TCSR(fep->pps_channel));
> +
> +		/*
> +		 * It is recommended to doulbe check the TMODE field in the
> +		 * TCSR register to be cleared before the first compare counter
> +		 * is written into TCCR register. Just add a double check.
> +		 */
> +		val = readl(fep->hwp + FEC_TCSR(fep->pps_channel));
> +		do {
> +			val &= ~(FEC_T_TMODE_MASK);
> +			writel(val, fep->hwp + FEC_TCSR(fep->pps_channel));
> +			val = readl(fep->hwp + FEC_TCSR(fep->pps_channel));
> +		} while (val & FEC_T_TMODE_MASK);
> +
> +		/*
> +		 * Dummy read counter to update the counter
> +		 */
> +		timecounter_read(&fep->tc);
> +		/*
> +		 * linux ptp is running. We want to find the first compare event
                   ^^^^^^^^^^^^^^^^^^^^
What does this mean?

> +		 * in the next second point. So we need to know what the ptp time
> +		 * is now and how many nanoseconds is ahead to get next second.
> +		 * The remaining nanosecond ahead before the next second would be
> +		 * FEC_T_PERIOD_ONE_SEC - ts.tv_nsec. Add the remaining nanoseconds
> +		 * to current timer would be next second.
> +		 */
> +		tempval = readl(fep->hwp + FEC_ATIME_CTRL);
> +		tempval |= FEC_T_CTRL_CAPTURE;
> +		writel(tempval, fep->hwp + FEC_ATIME_CTRL);
> +
> +		tempval = readl(fep->hwp + FEC_ATIME);
> +		/*
> +		 * Converse the ptp local counter to 1588 timestamp
                   ^^^^^^^^
Convert?

> +		 */
> +		ns = timecounter_cyc2time(&fep->tc, tempval);
> +		ts.tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
> +		ts.tv_nsec = remainder;
> +
> +		/*
> +		 * The tempval is  less than 3 seconds, and  so val is less than
> +		 * 4 seconds. No overflow for 32bit calculation.
> +		 */
> +		val = FEC_T_PERIOD_ONE_SEC - (u32)ts.tv_nsec + tempval;
> +
> +		/* Need to consider the situation that the current time is
> +		 * very close to the second point, which means FEC_T_PERIOD_ONE_SEC
> +		 * - ts.tv_nsec is close to be zero(For example 20ns); Since the timer
> +		 * is still running when we calculate the first compare event, it is
> +		 * possible that the remaining nanoseonds run out before the compare
> +		 * counter is calculated and written into TCCR register. To avoid
> +		 * this possibility, we will set the compare event to be the next
> +		 * of next second. The current setting is 31-bit timer and wrap
> +		 * around over 2 seconds. So it is okay to set the next of next
> +		 * seond for the timer.
> +		 */
> +		val += FEC_T_PERIOD_ONE_SEC;
> +
> +		/*
> +		 * We add (2 *FEC_T_PERIOD_ONE_SEC - (u32)ts.tv_nsec) to current
> +		 * ptp counter, which maybe cause 32-bit wrap. Since the
> +		 * (FEC_T_PERIOD_ONE_SEC - (u32)ts.tv_nsec) is less than 2 second.
> +		 * We can ensure the wrap will not cause issue. If the offset
> +		 * is bigger than fep->cc.mask would be a error.
> +		 */
> +		val &= fep->cc.mask;
> +		writel(val, fep->hwp + FEC_TCCR(fep->pps_channel));
> +
> +		/*
> +		 * Calculate the second the compare event timestamp.
> +		 */
> +		fep->next_counter = (val + fep->reload_period) & fep->cc.mask;
> +
> +		/*
> +		 * Enable compare event when overflow
> +		 */
> +		val = readl(fep->hwp + FEC_ATIME_CTRL);
> +		val |= FEC_T_CTRL_PINPER;
> +		writel(val, fep->hwp + FEC_ATIME_CTRL);
> +
> +		/*
> +		 * Compare channel setting.
> +		 */
> +		val = readl(fep->hwp + FEC_TCSR(fep->pps_channel));
> +		val |= (1 << FEC_T_TF_OFFSET | 1 << FEC_T_TIE_OFFSET);
> +		val &= ~(1 << FEC_T_TDRE_OFFSET);
> +		val &= ~(FEC_T_TMODE_MASK);
> +		val |= (FEC_HIGH_PULSE << FEC_T_TMODE_OFFSET);
> +		writel(val, fep->hwp + FEC_TCSR(fep->pps_channel));
> +
> +		/*
> +		 * Write the second compare event timestamp and calculate
> +		 * the third timestamp. Refer the TCCR register detail in the spec.
> +		 */
> +		writel(fep->next_counter, fep->hwp + FEC_TCCR(fep->pps_channel));
> +		fep->next_counter = (fep->next_counter + fep->reload_period) & fep->cc.mask;
> +	} else {
> +		writel(0, fep->hwp + FEC_TCSR(fep->pps_channel));
> +	}
> +
> +	fep->pps_enable = enable;
> +	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> +
> +	return 0;
> +}
> +
>  /**
>   * fec_ptp_read - read raw cycle counter (to be used by time counter)
>   * @cc: the cyclecounter structure
> @@ -322,6 +493,15 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>  static int fec_ptp_enable(struct ptp_clock_info *ptp,
>  			  struct ptp_clock_request *rq, int on)
>  {
> +	struct fec_enet_private *fep =
> +	    container_of(ptp, struct fec_enet_private, ptp_caps);
> +	int ret = 0;
> +
> +	if (rq->type == PTP_CLK_REQ_PPS) {
> +		ret = fec_ptp_enable_pps(fep, on);
> +
> +		return ret;
> +	}
>  	return -EOPNOTSUPP;
>  }
>  
> @@ -427,6 +607,8 @@ void fec_ptp_init(struct platform_device *pdev)
>  {
>  	struct net_device *ndev = platform_get_drvdata(pdev);
>  	struct fec_enet_private *fep = netdev_priv(ndev);
> +	struct device_node *np = pdev->dev.of_node;
> +	int err;
>  
>  	fep->ptp_caps.owner = THIS_MODULE;
>  	snprintf(fep->ptp_caps.name, 16, "fec ptp");
> @@ -436,7 +618,7 @@ void fec_ptp_init(struct platform_device *pdev)
>  	fep->ptp_caps.n_ext_ts = 0;
>  	fep->ptp_caps.n_per_out = 0;
>  	fep->ptp_caps.n_pins = 0;
> -	fep->ptp_caps.pps = 0;
> +	fep->ptp_caps.pps = 1;
>  	fep->ptp_caps.adjfreq = fec_ptp_adjfreq;
>  	fep->ptp_caps.adjtime = fec_ptp_adjtime;
>  	fep->ptp_caps.gettime = fec_ptp_gettime;
> @@ -444,6 +626,10 @@ void fec_ptp_init(struct platform_device *pdev)
>  	fep->ptp_caps.enable = fec_ptp_enable;
>  
>  	fep->cycle_speed = clk_get_rate(fep->clk_ptp);
> +	err = of_property_read_u32(np, "pps-channel",
> +					&fep->pps_channel);

Please do not make another DT property for this.

Instead, use the PTP_PIN_SET/GETFUNC interface. You can add a new
enumeration value to ptp_pin_function, like PTP_PF_PPS.

Thanks,
Richard


> +	if (err)
> +		fep->pps_channel = -1;
>  
>  	spin_lock_init(&fep->tmreg_lock);
>  
> @@ -459,3 +645,38 @@ void fec_ptp_init(struct platform_device *pdev)
>  
>  	schedule_delayed_work(&fep->time_keep, HZ);
>  }
> +
> +/**
> + * fec_ptp_check_pps_event
> + * @fep: the fec_enet_private structure handle
> + *
> + * This function check the pps event and reload the timer compare counter.
> + */
> +uint fec_ptp_check_pps_event(struct fec_enet_private *fep)
> +{
> +	u32 val;
> +	u8 channel = fep->pps_channel;
> +	struct ptp_clock_event event;
> +
> +	val = readl(fep->hwp + FEC_TCSR(channel));
> +	if (val & FEC_T_TF_MASK) {
> +		/*
> +		 * Write the next next compare(not the next according the spec) value to the register
> +		 */
> +		writel(fep->next_counter, fep->hwp + FEC_TCCR(channel));
> +		do {
> +			writel(val, fep->hwp + FEC_TCSR(channel));
> +		} while (readl(fep->hwp + FEC_TCSR(channel)) & FEC_T_TF_MASK);
> +
> +		/*
> +		 * Update the counter;
> +		 */
> +		fep->next_counter = (fep->next_counter + fep->reload_period) & fep->cc.mask;
> +
> +		event.type = PTP_CLOCK_PPS;
> +		ptp_clock_event(fep->ptp_clock, &event);
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> -- 
> 1.9.1
> 
