From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4 net-next] tg3: PTP - Implement the ptp api and
 ethtool functions
Date: Mon, 3 Dec 2012 19:51:59 +0100
Message-ID: <20121203185157.GB2531@netboy.at.omicron.at>
References: <1354506171-1646-1-git-send-email-mchan@broadcom.com>
 <1354506171-1646-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51244 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2LCSwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:52:12 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1780386eek.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 10:52:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1354506171-1646-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2012 at 07:42:49PM -0800, Michael Chan wrote:
> From: Matt Carlson <mcarlson@broadcom.com>
> 
> This patch updates the ptp_caps structure with implementation functions.
> All the basic clock operations as described in
> Documentation/ptp/ptp.txt are supported.
> 
> Frequency adjustment is performed using hardware with a 24 bit
> accumulator and a programmable correction value. On each clk, the
> correction value gets added to the accumulator and when it overflows,
> the time counter is incremented/decremented and the accumulator reset.
> 
> So conversion from ppb to correction value is
> 	ppb * (1 << 24) / 1000000000

Are you sure about this? I don't know your hardware, but the others
ones with an addend and an accumulator work differently. Usually there
is a default addend based on the frequency ratio between the input
clock and the divided nominal clock. Then the ppb is applied to the
default addend.

For example, see how tmr_add is calculated in 

   Documentation/devicetree/bindings/net/fsl-tsec-phy.txt

> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |  125 ++++++++++++++++++++++++++++++++++-
>  1 files changed, 123 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 38047a9..a54d194 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -5519,6 +5519,14 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
>  	return err;
>  }
>  
> +
> +static u64 tg3_refclk_read(struct tg3 *tp)
> +{
> +	u64 stamp = tr32(TG3_EAV_REF_CLCK_LSB);
> +
> +	return stamp | (u64) tr32(TG3_EAV_REF_CLCK_MSB) << 32;
> +}
> +
>  static void tg3_refclk_write(struct tg3 *tp, u64 newval)
>  {
>  	tw32(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_STOP);
> @@ -5527,14 +5535,127 @@ static void tg3_refclk_write(struct tg3 *tp, u64 newval)
>  	tw32_f(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_RESUME);
>  }
>  
> +static inline void tg3_full_lock(struct tg3 *tp, int irq_sync);
> +static inline void tg3_full_unlock(struct tg3 *tp);
> +static int tg3_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +
> +	info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
> +				SOF_TIMESTAMPING_RX_SOFTWARE |
> +				SOF_TIMESTAMPING_SOFTWARE    |
> +				SOF_TIMESTAMPING_TX_HARDWARE |
> +				SOF_TIMESTAMPING_RX_HARDWARE |
> +				SOF_TIMESTAMPING_RAW_HARDWARE;
> +
> +	if (tp->ptp_clock)
> +		info->phc_index = ptp_clock_index(tp->ptp_clock);
> +	else
> +		info->phc_index = -1;
> +
> +	info->tx_types = (1 << HWTSTAMP_TX_OFF) |
> +			 (1 << HWTSTAMP_TX_ON);
> +
> +	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
> +			   (1 << HWTSTAMP_FILTER_ALL);
> +	return 0;
> +}
> +
> +static int tg3_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
> +	bool neg_adj = false;
> +	u32 correction = 0;
> +
> +	if (ppb < 0) {
> +		neg_adj = true;
> +		ppb = -ppb;
> +	}
> +
> +	/* Frequency adjustment is performed using hardware with a 24 bit
> +	 * accumulator and a programmable correction value. On each clk, the
> +	 * correction value gets added to the accumulator and when it
> +	 * overflows, the time counter is incremented/decremented.
> +	 *
> +	 * So conversion from ppb to correction value is
> +	 *		ppb * (1 << 24) / 1000000000
> +	 */
> +	correction = div_u64((u64)ppb * (1 << 24), 1000000000ULL) &
> +		     TG3_EAV_REF_CLK_CORRECT_MASK;
> +
> +	tg3_full_lock(tp, 0);
> +
> +	if (correction)
> +		tw32(TG3_EAV_REF_CLK_CORRECT_CTL,
> +		     TG3_EAV_REF_CLK_CORRECT_EN |
> +		     (neg_adj ? TG3_EAV_REF_CLK_CORRECT_NEG : 0) | correction);
> +	else
> +		tw32(TG3_EAV_REF_CLK_CORRECT_CTL, 0);
> +
> +	tg3_full_unlock(tp);
> +
> +	return 0;
> +}
> +
> +static int tg3_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
> +{
> +	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
> +	tp->ptp_adjust += delta;

This 'ptp_adjust' should be placed under the lock. This races with the
reader method.

> +	return 0;
> +}
> +
> +static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
> +{
> +	u64 ns;
> +	u32 remainder;
> +	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
> +
> +	tg3_full_lock(tp, 0);
> +	ns = tg3_refclk_read(tp);
> +	tg3_full_unlock(tp);
> +	ns += tp->ptp_adjust;
> +
> +	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
> +	ts->tv_nsec = remainder;
> +
> +	return 0;
> +}
> +
> +static int tg3_ptp_settime(struct ptp_clock_info *ptp,
> +			   const struct timespec *ts)
> +{
> +	u64 ns;
> +	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
> +
> +	ns = timespec_to_ns(ts);
> +
> +	tg3_full_lock(tp, 0);
> +	tg3_refclk_write(tp, ns);
> +	tg3_full_unlock(tp);
> +	tp->ptp_adjust = 0;
> +
> +	return 0;
> +}
> +
> +static int tg3_ptp_enable(struct ptp_clock_info *ptp,
> +			  struct ptp_clock_request *rq, int on)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  static const struct ptp_clock_info tg3_ptp_caps = {
>  	.owner		= THIS_MODULE,
>  	.name		= "",
> -	.max_adj	= 0,
> +	.max_adj	= 250000000,
>  	.n_alarm	= 0,
>  	.n_ext_ts	= 0,
>  	.n_per_out	= 0,
>  	.pps		= 0,
> +	.adjfreq	= tg3_ptp_adjfreq,
> +	.adjtime	= tg3_ptp_adjtime,
> +	.gettime	= tg3_ptp_gettime,
> +	.settime	= tg3_ptp_settime,
> +	.enable		= tg3_ptp_enable,

These are missing from patch #1.

>  };
>  
>  static void tg3_ptp_init(struct tg3 *tp)

Thanks,
Richard
