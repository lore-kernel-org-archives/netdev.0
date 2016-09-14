From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/9] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Wed, 14 Sep 2016 15:52:14 +0200
Message-ID: <20160914135214.GA28592@localhost.localdomain>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-4-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34367 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756319AbcINNwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 09:52:20 -0400
Content-Disposition: inline
In-Reply-To: <20160914130231.3035-4-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 04:02:25PM +0300, Grygorii Strashko wrote:
> @@ -323,7 +307,7 @@ void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
>  	u64 ns;
>  	struct skb_shared_hwtstamps *ssh;
>  
> -	if (!cpts->rx_enable)
> +	if (!cpts || !cpts->rx_enable)
>  		return;

This function is in the hot path, and you have added a pointless new
test.  Don't do that.

>  	ns = cpts_find_ts(cpts, skb, CPTS_EV_RX);
>  	if (!ns)
> @@ -338,7 +322,7 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
>  	u64 ns;
>  	struct skb_shared_hwtstamps ssh;
>  
> -	if (!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
> +	if (!cpts || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
>  		return;

Same here.

>  	ns = cpts_find_ts(cpts, skb, CPTS_EV_TX);
>  	if (!ns)
> @@ -348,53 +332,102 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
>  	skb_tstamp_tx(skb, &ssh);
>  }
>  
> -int cpts_register(struct device *dev, struct cpts *cpts,
> -		  u32 mult, u32 shift)
> +int cpts_register(struct cpts *cpts)
>  {
>  	int err, i;
> -	unsigned long flags;
>  
> -	cpts->info = cpts_info;
> -	cpts->clock = ptp_clock_register(&cpts->info, dev);
> -	if (IS_ERR(cpts->clock)) {
> -		err = PTR_ERR(cpts->clock);
> -		cpts->clock = NULL;
> -		return err;
> -	}
> -	spin_lock_init(&cpts->lock);
> -
> -	cpts->cc.read = cpts_systim_read;
> -	cpts->cc.mask = CLOCKSOURCE_MASK(32);
> -	cpts->cc_mult = mult;
> -	cpts->cc.mult = mult;
> -	cpts->cc.shift = shift;
> +	if (!cpts)
> +		return -EINVAL;

Not hot path, but still silly.  The caller should never pass NULL.

Thanks,
Richard
