From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fix NULL pointer + success return in route lookup path
Date: Sat, 20 Jun 2009 14:37:00 +0200
Message-ID: <4A3CD7EC.2040904@gmail.com>
References: <20090619171814.GE18237@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbizon@freebox.fr, dada1@cosmosbay.com,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f214.google.com ([209.85.220.214]:46471 "EHLO
	mail-fx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbZFTMhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 08:37:20 -0400
Received: by fxm10 with SMTP id 10so132524fxm.37
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2009 05:37:22 -0700 (PDT)
In-Reply-To: <20090619171814.GE18237@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote, On 06/19/2009 07:18 PM:

> Don't drop route if we're not caching	
> 
> 	I recently got a report of an oops on a route lookup.  Maxime was
> testing what would happen if route caching was turned off (doing so by setting
> making rt_caching always return 0), and found that it triggered an oops.  I
> looked at it and found that the problem stemmed from the fact that the route
> lookup routines were returning success from their lookup paths (which is good),
> but never set the **rp pointer to anything (which is bad).  This happens because
> in rt_intern_hash, if rt_caching returns false, we call rt_drop and return 0.
> This almost emulates slient success.  What we should be doing is assigning *rp =
> rt and _not_ dropping the route.  This way, during slow path lookups, when we
> create a new route cache entry, we don't immediately discard it, rather we just
> don't add it into the cache hash table, but we let this one lookup use it for
> the purpose of this route request.  Maxime has tested and reports it prevents
> the oops.

Hmm... So, IOW, do you mean the same Maxime, by whom it was "Reported-by" and
"Tested-by", and probably anonymous on the Cc list, or I miss something?

Regards,
Jarek P.

> There is still a subsequent routing issue that I'm looking into
> further, but I'm confident that, even if its related to this same path, this
> patch makes sense to take.
> 
> Regards
> Neil
>     
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  route.c |   14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index cd76b3c..65b3a8b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1085,8 +1085,16 @@ restart:
>  	now = jiffies;
>  
>  	if (!rt_caching(dev_net(rt->u.dst.dev))) {
> -		rt_drop(rt);
> -		return 0;
> +		/*
> +		 * If we're not caching, just tell the caller we
> +		 * were successful and don't touch the route.  The
> +		 * caller hold the sole reference to the cache entry, and
> +		 * it will be released when the caller is done with it.
> +		 * If we drop it here, the callers have no way to resolve routes
> +		 * when we're not caching.  Instead, just point *rp at rt, so
> +		 * the caller gets a single use out of the route
> +		 */
> +		goto report_and_exit;
>  	}
>  
>  	rthp = &rt_hash_table[hash].chain;
> @@ -1217,6 +1225,8 @@ restart:
>  	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
>  
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
> +
> +report_and_exit:
>  	if (rp)
>  		*rp = rt;
>  	else
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


