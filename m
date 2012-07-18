From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 22:34:19 +0200
Message-ID: <1342643659.2626.3636.camel@edumazet-glaptop>
References: <20120718.112404.1910372180742347127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:60801 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2GRUeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:34:24 -0400
Received: by yhmm54 with SMTP id m54so2044597yhm.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 13:34:23 -0700 (PDT)
In-Reply-To: <20120718.112404.1910372180742347127.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 11:24 -0700, David Miller wrote:
> If we have an output route that lacks nexthop exceptions, we can cache
> it in the FIB info nexthop.
> 
> Such routes will have DST_HOST cleared because such routes refer to a
> family of destinations, rather than just one.


> -			   const struct fib_result *res,
> +static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
> +{
> +	static DEFINE_SPINLOCK(fib_cache_lock);
> +	struct rtable **p = &nh->nh_rth_output;
> +
> +	if (*p)
> +		return;
> +
> +	spin_lock_bh(&fib_cache_lock);
> +	if (!*p) {
> +		*p = rt;
> +		dst_clone(&rt->dst);
> +	}
> +	spin_unlock_bh(&fib_cache_lock);
> +}
> +

This probably should use cmpxchg()

static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
{
	struct rtable **p = &nh->nh_rth_output;

	if (*p)
               return;

	if (cmpxchg(p, NULL, rt) == NULL)
		dst_clone(&rt->dst);
}
