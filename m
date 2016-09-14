From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 16:25:03 +0200
Message-ID: <20160914142503.GF28592@localhost.localdomain>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-9-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160914130231.3035-9-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 04:02:30PM +0300, Grygorii Strashko wrote:
> @@ -427,9 +427,6 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
>  	u64 ns;
>  	u64 frac;
>  
> -	if (cpts->cc_mult || cpts->cc.shift)
> -		return;
> -
>  	freq = clk_get_rate(cpts->refclk);
>  
>  	/* Calc the maximum number of seconds which we can run before

This hunk has nothing to do with $subject.

> @@ -442,11 +439,20 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
>  	else if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
>  		maxsec = 600;
>  
> +	/* Calc overflow check period (maxsec / 2) */
> +	cpts->ov_check_period = (HZ * maxsec) / 2;
> +	dev_info(cpts->dev, "cpts: overflow check period %lu\n",
> +		 cpts->ov_check_period);
> +
> +	if (cpts->cc_mult || cpts->cc.shift)
> +		return;
> +
>  	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
>  
>  	cpts->cc_mult = mult;
>  	cpts->cc.mult = mult;
>  	cpts->cc.shift = shift;
> +

Nor does this.

Thanks,
Richard


>  	/* Check calculations and inform if not precise */
>  	frac = 0;
>  	ns = cyclecounter_cyc2ns(&cpts->cc, freq, cpts->cc.mask, &frac);
> diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
> index 47026ec..e0e4a62b 100644
> --- a/drivers/net/ethernet/ti/cpts.h
> +++ b/drivers/net/ethernet/ti/cpts.h
> @@ -97,9 +97,6 @@ enum {
>  	CPTS_EV_TX,   /* Ethernet Transmit Event */
>  };
>  
> -/* This covers any input clock up to about 500 MHz. */
> -#define CPTS_OVERFLOW_PERIOD (HZ * 8)
> -
>  #define CPTS_FIFO_DEPTH 16
>  #define CPTS_MAX_EVENTS 32
>  
> @@ -127,6 +124,7 @@ struct cpts {
>  	struct list_head events;
>  	struct list_head pool;
>  	struct cpts_event pool_data[CPTS_MAX_EVENTS];
> +	unsigned long ov_check_period;
>  };
>  
>  int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
> -- 
> 2.9.3
> 
