From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH 29/29] fm10k: Add support for PTP
Date: Fri, 19 Sep 2014 19:35:04 +0200
Message-ID: <20140919173504.GA4136@localhost.localdomain>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
 <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:61902 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757518AbaISRfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 13:35:09 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so134910wes.18
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 10:35:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 06:40:46PM -0400, Alexander Duyck wrote:

> +static s32 fm10k_1588_msg_vf(struct fm10k_hw *hw, u32 **results,
> +			     struct fm10k_mbx_info *mbx)
> +{
> +	struct fm10k_intfc *interface = container_of(hw,
> +						     struct fm10k_intfc,
> +						     hw);

This looks really funny to me here and in the other spot. Why not this?

	struct fm10k_intfc *interface = container_of(hw, struct fm10k_intfc, hw);

Its only one over the 80 km/h speed limit.

> +	u64 timestamp;
> +	s32 err;
> +
> +	err = fm10k_tlv_attr_get_u64(results[FM10K_1588_MSG_TIMESTAMP],
> +				     &timestamp);
> +	if (err)
> +		return err;
> +
> +	fm10k_ts_tx_hwtstamp(interface, 0, timestamp);
> +
> +	return 0;
> +}

> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
> new file mode 100644
> index 0000000..41da724
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c

> +/* We use a 64b counter so overflow is extremely seldom.  Just
> + * to keep things sane we should check for overflow once per day
> + */

Hm...

> +void fm10k_ts_start_cc(struct fm10k_intfc *interface)
> +{
> +	struct fm10k_hw *hw = &interface->hw;
> +
> +	/* Initialize cycle counter */
> +	interface->cc.read = (hw->mac.type == fm10k_mac_pf) ? fm10k_cc_read_pf :
> +							      fm10k_cc_read_vf;
> +	interface->cc.mask = CLOCKSOURCE_MASK(64);
> +	interface->cc.mult = 1;

So shift = 0 and multi = 1. Your clock counts nanoseconds. Why not use
it directly? Then you won't need the timecounter stuff or the overflow
watchdog either.

> +
> +	/* Initialize lock protecting register access */
> +	rwlock_init(&interface->tsreg_lock);
> +
> +	/* Initialize skb queue for pending timestamp requests */
> +	skb_queue_head_init(&interface->ts_tx_skb_queue);
> +
> +	/* Initialize the clock */
> +	fm10k_ts_reset_cc(interface);
> +
> +	/* Initialize the overflow work */
> +	INIT_DELAYED_WORK(&interface->ts_overflow_work,
> +			  fm10k_ts_overflow_check);
> +	schedule_delayed_work(&interface->ts_overflow_work,
> +			      FM10K_SYSTIME_OVERFLOW_PERIOD);
> +}

> +static int fm10k_ptp_enable(struct ptp_clock_info *ptp,
> +			    struct ptp_clock_request *rq, int on)
> +{
> +	struct fm10k_intfc *interface =
> +		container_of(ptp, struct fm10k_intfc, ptp_caps);
> +	struct ptp_clock_time *t = &rq->perout.period;
> +	struct fm10k_hw *hw = &interface->hw;
> +	u64 period;
> +	u32 step;
> +
> +	/* we can only support periodic output */
> +	if (rq->type != PTP_CLK_REQ_PEROUT)
> +		return -EINVAL;
> +
> +	/* verify the requested channel is there */
> +	if (rq->perout.index >= ptp->n_per_out)
> +		return -EINVAL;
> +
> +	/* we simply cannot support the operation if we don't have BAR4 */
> +	if (!hw->sw_addr)
> +		return -ENOTSUPP;
> +
> +	/* we cannot enforce start time as there is no
> +	 * mechanism for that in the hardware, we can only control
> +	 * the period.
> +	 */

Is this because of the timecounter in the way? Another reason to use
the 64 bit nanosecond counter directly.

> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
> index 5055bef..dac5b79 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
> @@ -225,11 +225,7 @@ struct fm10k_hw;
>  #define FM10K_STATS_NODESC_DROP		0x3807
>  
>  /* Timesync registers */
> -#define FM10K_RRTIME_CFG	0x3808
> -#define FM10K_RRTIME_LIMIT(_n)	((_n) + 0x380C)
> -#define FM10K_RRTIME_COUNT(_n)	((_n) + 0x3810)
>  #define FM10K_SYSTIME		0x3814
> -#define FM10K_SYSTIME0		0x3816
>  #define FM10K_SYSTIME_CFG	0x3818
>  #define FM10K_SYSTIME_CFG_STEP_MASK		0x0000000F
>  
> @@ -368,9 +364,6 @@ struct fm10k_hw;
>  #define FM10K_VFITR(_n)		((_n) + 0x00060)
>  
>  /* Registers contained in BAR 4 for Switch management */
> -#define FM10K_SW_SYSTIME_CFG	0x0224C
> -#define FM10K_SW_SYSTIME_CFG_STEP_SHIFT		4
> -#define FM10K_SW_SYSTIME_CFG_ADJUST_MASK	0xFF000000

You added these three lines in the previous patch.

>  #define FM10K_SW_SYSTIME_ADJUST	0x0224D
>  #define FM10K_SW_SYSTIME_ADJUST_MASK		0x3FFFFFFF
>  #define FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE	0x80000000
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks,
Richard
