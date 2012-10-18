From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipv4: Fix flushing of cached routing informations
Date: Thu, 18 Oct 2012 09:52:37 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
References: <20121018052730.GB27385@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47595 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab2JRGqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 02:46:48 -0400
In-Reply-To: <20121018052730.GB27385@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 18 Oct 2012, Steffen Klassert wrote:

> Currently we can not flush cached pmtu/redirect informations via
> the ipv4_sysctl_rtcache_flush sysctl. We need to check the rt_genid
> of the old route and reset the nh exeption if the old route is
> expired when we bind a new route to a nh exeption.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |   16 ++++++++++------
>  1 files changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 432f4bb..defb98d 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1163,8 +1163,17 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
>  	spin_lock_bh(&fnhe_lock);
>  
>  	if (daddr == fnhe->fnhe_daddr) {
> -		struct rtable *orig;
> +		struct rtable *orig = rcu_dereference(fnhe->fnhe_rth);
> +		rcu_assign_pointer(fnhe->fnhe_rth, rt);

	May be the above rcu_assign_pointer should be after

	... if (!rt->rt_gateway)
		rt->rt_gateway = daddr;

	part. It is possible another __mkroute_output
caller to get the cached fnhe->fnhe_rth without valid
rt->rt_gateway. rcu_assign_pointer should be after all
writes to rt.

> +		if (orig) {
> +			if (rt_is_expired(orig)) {
> +				fnhe->fnhe_gw = 0;
> +				fnhe->fnhe_pmtu = 0;
> +				fnhe->fnhe_expires = 0;
> +			}
> +			rt_free(orig);
> +		}
>  		if (fnhe->fnhe_pmtu) {
>  			unsigned long expires = fnhe->fnhe_expires;
>  			unsigned long diff = expires - jiffies;
> @@ -1181,11 +1190,6 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
>  		} else if (!rt->rt_gateway)
>  			rt->rt_gateway = daddr;
>  
> -		orig = rcu_dereference(fnhe->fnhe_rth);
> -		rcu_assign_pointer(fnhe->fnhe_rth, rt);
> -		if (orig)
> -			rt_free(orig);
> -
>  		fnhe->fnhe_stamp = jiffies;
>  		ret = true;
>  	}
> -- 
> 1.7.0.4

Regards

--
Julian Anastasov <ja@ssi.bg>
