From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 10:13:34 +0200
Message-ID: <1343290414.2626.11181.camel@edumazet-glaptop>
References: <CAKgT0UdcqE52WFCT-t2om0SN3Yq5GqiwN+JbwCcnBv4LDOB6BQ@mail.gmail.com>
	 <20120725.161732.91008692477078715.davem@davemloft.net>
	 <20120725.163939.581743307449189972.davem@davemloft.net>
	 <20120725.175406.1331203183232530233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34028 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab2GZINk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 04:13:40 -0400
Received: by bkwj10 with SMTP id j10so1088322bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 01:13:39 -0700 (PDT)
In-Reply-To: <20120725.175406.1331203183232530233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 17:54 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 25 Jul 2012 16:39:39 -0700 (PDT)
> 
> > From: David Miller <davem@davemloft.net>
> > Date: Wed, 25 Jul 2012 16:17:32 -0700 (PDT)
> > 
> >> From: Alexander Duyck <alexander.duyck@gmail.com>
> >> Date: Wed, 25 Jul 2012 16:02:45 -0700
> >> 
> >>> Since your patches are in I have started to re-run my tests. I am
> >>> seeing a significant drop in throughput with 8 flows which I expected,
> >>> however it looks like one of the biggest issues I am seeing is that
> >>> the dst_hold and dst_release calls seem to be causing some serious
> >>> cache thrash.  I was at 12.5Mpps w/ 8 flows before the patches, after
> >>> your patches it drops to 8.3Mpps.
> >> 
> >> Yes, this is something we knew would start happening.
> >> 
> >> One idea is to make cached dsts be per-cpu in the nexthops.
> > 
> > Actually I think what really kills your case is the removal of the
> > noref path for route lookups.  I'll work on a patch to restore that
> > in the case where we use cached routes from the FIB nexthops.
> 
> Alex, here is something I tossed together, does it help with the
> dst_hold()/dst_release() overhead at all?
> 

seems good to me, only one question :


>  static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
> @@ -1216,9 +1215,15 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
>  
>  	prev = cmpxchg(p, orig, rt);
>  	if (prev == orig) {
> -		dst_clone(&rt->dst);
>  		if (orig)
> -			call_rcu_bh(&orig->dst.rcu_head, rt_release_rcu);
> +			rt_free(orig);
> +	} else {
> +		/* Routes we intend to cache in the FIB nexthop have
> +		 * the DST_NOCACHE bit set.  However, if we are
> +		 * unsuccessful at storing this route into the cache
> +		 * we really need to clear that bit.
> +		 */
> +		rt->dst.flags &= ~DST_NOCACHE;
>  	}
>  }
>  

Not sure why you removed the dst_clone(&rt->dst) ?

If it is not needed, we might need to release a reference in the else {}
clause, no ?
