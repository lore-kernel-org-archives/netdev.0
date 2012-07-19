From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 10/16] ipv4: Cache output routes in fib_info nexthops.
Date: Fri, 20 Jul 2012 00:09:03 +0200
Message-ID: <1342735743.2626.5411.camel@edumazet-glaptop>
References: <20120719.143540.747492487297004222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:56721 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab2GSWJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 18:09:08 -0400
Received: by vbbff1 with SMTP id ff1so2400763vbb.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 15:09:07 -0700 (PDT)
In-Reply-To: <20120719.143540.747492487297004222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 14:35 -0700, David Miller wrote:
> If we have an output route that lacks nexthop exceptions, we can cache
> it in the FIB info nexthop.
> 
> Such routes will have DST_HOST cleared because such routes refer to a
> family of destinations, rather than just one.
> 
> The sequence of the handling of exceptions during route lookup is
> adjusted to make the logic work properly.
> 
> Before we allocate the route, we lookup the exception.
> 
> Then we know if we will cache this route or not, and therefore whether
> DST_HOST should be set on the allocated route.
> 
> Then we use DST_HOST to key off whether we should store the resulting
> route, during rt_set_nexthop(), in the FIB nexthop cache.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>


> +static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
> +{
> +	struct rtable *orig, *prev, **p = &nh->nh_rth_output;
> +
> +	orig = *p;
> +
> +	prev = cmpxchg(p, orig, rt);
> +	if (prev == orig) {
> +		dst_clone(&rt->dst);
> +		if (orig)
> +			dst_release(&orig->dst);
>  	}
>  }
>  

Hmm...

If we find orig not null, what can protect another cpu from reading
nh->nh_rth_output, then we dst_release(orig), and other cpu  does the
dst_use() too late ?
