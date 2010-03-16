From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] route: Fix caught BUG_ON during
 rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 10:34:37 -0400
Message-ID: <20100316143437.GA8225@hmsreliant.think-freely.org>
References: <201003161407.51925.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60052 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966284Ab0CPOe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 10:34:58 -0400
Content-Disposition: inline
In-Reply-To: <201003161407.51925.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 16, 2010 at 02:07:51PM +0300, Vitaliy Gusev wrote:
> route: Fix caught BUG_ON during rt_secret_rebuild_oneshot()
> 
> Call rt_secret_rebuild can cause BUG_ON(timer_pending(&net->ipv4.rt_secret_timer)) in
> add_timer as there is not any synchronization for call rt_secret_rebuild_oneshot()
> for the same net namespace.
> 
> Also this issue affects to rt_secret_reschedule().
> 
> Thus use mod_timer enstead.
> 
> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> 
> ---
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 4f11faa..8a77318 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -922,10 +922,8 @@ static void rt_secret_rebuild_oneshot(struct net *net)
>  {
>  	del_timer_sync(&net->ipv4.rt_secret_timer);
>  	rt_cache_invalidate(net);
> -	if (ip_rt_secret_interval) {
> -		net->ipv4.rt_secret_timer.expires += ip_rt_secret_interval;
> -		add_timer(&net->ipv4.rt_secret_timer);
> -	}
> +	if (ip_rt_secret_interval)
> +		mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
>  }
>  
>  static void rt_emergency_hash_rebuild(struct net *net)
> @@ -3072,22 +3070,20 @@ static void rt_secret_reschedule(int old)
>  	rtnl_lock();
>  	for_each_net(net) {
>  		int deleted = del_timer_sync(&net->ipv4.rt_secret_timer);
> +		long time;
>  
>  		if (!new)
>  			continue;
>  
>  		if (deleted) {
> -			long time = net->ipv4.rt_secret_timer.expires - jiffies;
> +			time = net->ipv4.rt_secret_timer.expires - jiffies;
>  
>  			if (time <= 0 || (time += diff) <= 0)
>  				time = 0;
> -
> -			net->ipv4.rt_secret_timer.expires = time;
>  		} else
> -			net->ipv4.rt_secret_timer.expires = new;
> +			time = new;
>  
> -		net->ipv4.rt_secret_timer.expires += jiffies;
> -		add_timer(&net->ipv4.rt_secret_timer);
> +		mod_timer(&net->ipv4.rt_secret_timer, jiffies + time);
>  	}
>  	rtnl_unlock();
>  }

Yeah, this seems reasonable.  Although this might be a good time to bring up the
subject of deprecating or removing the secret interval.  We've had our
statistical analysis bits in place to drive the rebuilding of the cache in the
event that any one chain gets too long, and in the year or so that we've had it,
it seems we've shaken out a few bugs with it (which suggests that people are
using it routinely).  As such, might it be time to just drop the rebuild timer
in its entirety?

Until that decision is made of course, the above seems like a sane fix for it.
Acked-by: Neil Horman <nhorman@tuxdriver.com>

