From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/6] ipv4: add check if nh_pcpu_rth_output is
 allocated
Date: Sun, 07 Oct 2012 15:34:23 +0200
Message-ID: <1349616863.21172.2376.camel@edumazet-glaptop>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg>
	 <1349609168-9848-4-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60969 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab2JGNe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 09:34:29 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1614622bkc.19
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 06:34:27 -0700 (PDT)
In-Reply-To: <1349609168-9848-4-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-07 at 14:26 +0300, Julian Anastasov wrote:
> 	Avoid NULL ptr dereference and caching if
> nh_pcpu_rth_output is not allocated.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/ipv4/route.c |   12 +++++++++---
>  1 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 488a8bb..0a600cc 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1798,18 +1798,24 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>  	fnhe = NULL;
>  	if (fi) {
>  		struct rtable __rcu **prth;
> +		struct fib_nh *nh = &FIB_RES_NH(*res);
>  
> -		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
> +		fnhe = find_exception(nh, fl4->daddr);
>  		if (fnhe)
>  			prth = &fnhe->fnhe_rth;
> -		else
> -			prth = __this_cpu_ptr(FIB_RES_NH(*res).nh_pcpu_rth_output);
> +		else {
> +			if (!nh->nh_pcpu_rth_output)
> +				goto add;
> +			prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
> +		}
>  		rth = rcu_dereference(*prth);
>  		if (rt_cache_valid(rth)) {
>  			dst_hold(&rth->dst);
>  			return rth;
>  		}
>  	}
> +
> +add:
>  	rth = rt_dst_alloc(dev_out,
>  			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
>  			   IN_DEV_CONF_GET(in_dev, NOXFRM),

Alternative would be to make sure the allocation succeeded in
fib_create_info(), but I have no idea on the maximal number of fib_info
a complex routing setup might need ?

I guess a typical machine needs less than 30 fib_info...
