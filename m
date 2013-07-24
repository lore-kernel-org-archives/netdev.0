From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 05/13] tile: support PTP using the tilegx mPIPE (IEEE
 1588)
Date: Wed, 24 Jul 2013 08:25:33 +0200
Message-ID: <20130724062533.GA5163@netboy>
References: <cover.1374609948.git.cmetcalf@tilera.com>
 <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris,

This mail is a duplicate to you. I left off the CCs by mistake.

On Tue, Jul 23, 2013 at 04:05:48PM -0400, Chris Metcalf wrote:

> diff --git a/arch/tile/include/gxio/mpipe.h b/arch/tile/include/gxio/mpipe.h
> index b74f470..57f5ca2 100644
> --- a/arch/tile/include/gxio/mpipe.h
> +++ b/arch/tile/include/gxio/mpipe.h
> @@ -1733,4 +1733,17 @@ extern int gxio_mpipe_set_timestamp(gxio_mpipe_context_t *context,
>  extern int gxio_mpipe_adjust_timestamp(gxio_mpipe_context_t *context,
>  				       int64_t delta);
>  
> +/* Adjust the mPIPE timestamp clock frequency.
> + *
> + * @param context An initialized mPIPE context.
> + * @param ppb A 32-bits signed PPB(Parts Per Billion) value to adjust.
> + * The absolute value of ppb must be less than or equal to 1000000000,
> + * and should be larger then 30000, otherwise just ignored because of
> + * the clock precision restriction.

30 ppm? That is not too good.

What do you mean by "should be larger"? The caller (from user space)
has no way to know about this limitation.

> + * @return If the call was successful, zero; otherwise, a negative error
> + *  code.
> + */
> +extern int gxio_mpipe_adjust_timestamp_freq(gxio_mpipe_context_t *context,
> +					    int32_t ppb);
> +
>  #endif /* !_GXIO_MPIPE_H_ */

...

> diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
> index f3c2d03..3d4406c 100644
> --- a/drivers/net/ethernet/tile/tilegx.c
> +++ b/drivers/net/ethernet/tile/tilegx.c

...

> @@ -1284,6 +1325,12 @@ static int tile_net_stop(struct net_device *dev)
>  	return 0;
>  }
>  
> +gxio_mpipe_context_t *get_mpipe_context(int index)
> +{
> +	return ingress_irq < 0 ? NULL : &context;

So having a PHC depends on this IRQ having been initialized.
Why not just register the PHC in the same place?

> +}
> +EXPORT_SYMBOL_GPL(get_mpipe_context);
> +
>  /* Determine the VA for a fragment. */
>  static inline void *tile_net_frag_buf(skb_frag_t *f)
>  {

...

> @@ -1727,6 +1777,12 @@ static void tile_net_tx_timeout(struct net_device *dev)
>  /* Ioctl commands. */
>  static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>  {
> +#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
> +	if (cmd == SIOCSHWTSTAMP) {
> +		/* Hardware timestamping was enabled by default. */
> +		return 0;

This won't do. You need to update tx_type and rx_filter to reflect the
actual settings.

> +	}
> +#endif
>  	return -EOPNOTSUPP;
>  }
>  

> diff --git a/drivers/net/ethernet/tile/tilegx_ptp.c b/drivers/net/ethernet/tile/tilegx_ptp.c
> new file mode 100644
> index 0000000..a188463
> --- /dev/null
> +++ b/drivers/net/ethernet/tile/tilegx_ptp.c
> @@ -0,0 +1,202 @@
> +/*
> + * PTP 1588 clock using the TILE-Gx.
> + *
> + * Copyright 2013 Tilera Corporation. All Rights Reserved.
> + *
> + *   This program is free software; you can redistribute it and/or
> + *   modify it under the terms of the GNU General Public License
> + *   as published by the Free Software Foundation, version 2.
> + *
> + *   This program is distributed in the hope that it will be useful, but
> + *   WITHOUT ANY WARRANTY; without even the implied warranty of
> + *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
> + *   NON INFRINGEMENT.  See the GNU General Public License for
> + *   more details.
> + *
> + * This source code is derived from ptp_ixp46x.c wrote by Richard Cochran.
                                                    ^^^^^^^^
"written by"

> + */
> +
> +#include <linux/device.h>
> +#include <linux/err.h>
> +#include <linux/gpio.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/irq.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/ptp_clock_kernel.h>
> +
> +#include <gxio/mpipe.h>
> +#include <gxio/iorpc_mpipe.h>
> +
> +#define GBE_LINK_NR		4
> +
> +/* nanoseconds will be incremented each clock cycle. */
> +#define GBE_TIMER_INCREMENT	8
> +
> +
> +MODULE_AUTHOR("Tilera Corporation");
> +MODULE_DESCRIPTION("PTP clock using the TILE-Gx");
> +MODULE_LICENSE("GPL");

No need to make this a module at all. Just make the code conditionally
compiled, and register the clock along with your ingress_irq.

> +
> +
> +struct mpipe_clock {
> +	struct ptp_clock *ptp_clock;
> +	gxio_mpipe_context_t *context;
> +	struct ptp_clock_info caps;
> +	struct mutex lock;
> +};
> +
> +static struct mpipe_clock mpipe_clock;
> +
> +extern gxio_mpipe_context_t *get_mpipe_context(int index);
> +
> +/*
> + * Check if the context of mpipe device is valid.
> + */

This goes away with proper PHC registration as mentioned before.

> +static inline int mpipe_context_check(struct mpipe_clock *clock)
> +{
> +	if (!clock->context) {
> +		clock->context = get_mpipe_context(0);
> +		if (!clock->context) {
> +			pr_debug("Invalid mPIPE context.\n");
> +			return -EIO;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * PTP clock operations.
> + */
> +
> +static int ptp_mpipe_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	int ret = 0;
> +	struct mpipe_clock *clock = container_of(ptp, struct mpipe_clock, caps);
> +
> +	mutex_lock(&clock->lock);
> +	if (mpipe_context_check(clock)) {
> +		mutex_unlock(&clock->lock);
> +		return -EIO;
> +	}

This icky code block also goes away (in each method).

> +
> +	if (gxio_mpipe_adjust_timestamp_freq(clock->context, ppb))
> +		ret = -EINVAL;
> +
> +	mutex_unlock(&clock->lock);
> +	return ret;
> +}

...

> +static struct ptp_clock_info ptp_mpipe_caps = {
> +	.owner		= THIS_MODULE,
> +	.name		= "mPIPE ptp timer",
> +	.max_adj	= 512000,

But before, you said 10^9 ppb?

> +	.n_ext_ts	= 0,
> +	.pps		= 0,
> +	.adjfreq	= ptp_mpipe_adjfreq,
> +	.adjtime	= ptp_mpipe_adjtime,
> +	.gettime	= ptp_mpipe_gettime,
> +	.settime	= ptp_mpipe_settime,
> +};

Thanks,
Richard
