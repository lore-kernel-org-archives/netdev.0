From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv4: Fix flushing of cached routing informations
Date: Thu, 18 Oct 2012 09:40:36 +0200
Message-ID: <1350546036.26103.1120.camel@edumazet-glaptop>
References: <20121018052730.GB27385@secunet.com>
	 <alpine.LFD.2.00.1210180927230.1572@ja.ssi.bg>
	 <20121018071744.GD27385@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41870 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab2JRHkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 03:40:40 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so3962985bkc.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 00:40:39 -0700 (PDT)
In-Reply-To: <20121018071744.GD27385@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-18 at 09:17 +0200, Steffen Klassert wrote:
> Currently we can not flush cached pmtu/redirect informations via
> the ipv4_sysctl_rtcache_flush sysctl. We need to check the rt_genid
> of the old route and reset the nh exeption if the old route is
> expired when we bind a new route to a nh exeption.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 432f4bb..a8c6512 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1163,8 +1163,12 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
>  	spin_lock_bh(&fnhe_lock);
>  
>  	if (daddr == fnhe->fnhe_daddr) {
> -		struct rtable *orig;
> -
> +		struct rtable *orig = rcu_dereference(fnhe->fnhe_rth);
> +		if (orig && rt_is_expired(orig)) {
> +			fnhe->fnhe_gw = 0;
> +			fnhe->fnhe_pmtu = 0;
> +			fnhe->fnhe_expires = 0;
> +		}
>  		if (fnhe->fnhe_pmtu) {
>  			unsigned long expires = fnhe->fnhe_expires;
>  			unsigned long diff = expires - jiffies;
> @@ -1181,7 +1185,6 @@ static bool rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
>  		} else if (!rt->rt_gateway)
>  			rt->rt_gateway = daddr;
>  
> -		orig = rcu_dereference(fnhe->fnhe_rth);
>  		rcu_assign_pointer(fnhe->fnhe_rth, rt);
>  		if (orig)
>  			rt_free(orig);

Seems good to me. I'll have to rebase my patch, changing these
rcu_dereference() to rcu_dereference_protected() variant.

Acked-by: Eric Dumazet <edumazet@google.com>
