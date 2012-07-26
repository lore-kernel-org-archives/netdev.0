From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 10:27:58 +0200
Message-ID: <1343291278.2626.11188.camel@edumazet-glaptop>
References: <20120725.163939.581743307449189972.davem@davemloft.net>
	 <20120725.175406.1331203183232530233.davem@davemloft.net>
	 <1343290414.2626.11181.camel@edumazet-glaptop>
	 <20120726.011853.973075299731735416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61028 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab2GZI2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 04:28:03 -0400
Received: by bkwj10 with SMTP id j10so1096602bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 01:28:01 -0700 (PDT)
In-Reply-To: <20120726.011853.973075299731735416.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-26 at 01:18 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Jul 2012 10:13:34 +0200
> 
> > On Wed, 2012-07-25 at 17:54 -0700, David Miller wrote:
> >> @@ -1216,9 +1215,15 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
> >>  
> >>  	prev = cmpxchg(p, orig, rt);
> >>  	if (prev == orig) {
> >> -		dst_clone(&rt->dst);
> >>  		if (orig)
> >> -			call_rcu_bh(&orig->dst.rcu_head, rt_release_rcu);
> >> +			rt_free(orig);
> >> +	} else {
> >> +		/* Routes we intend to cache in the FIB nexthop have
> >> +		 * the DST_NOCACHE bit set.  However, if we are
> >> +		 * unsuccessful at storing this route into the cache
> >> +		 * we really need to clear that bit.
> >> +		 */
> >> +		rt->dst.flags &= ~DST_NOCACHE;
> >>  	}
> >>  }
> >>  
> > 
> > Not sure why you removed the dst_clone(&rt->dst) ?
> 
> Because "cached" dst objects have no reference count.  When such a
> cached dst is "released", it is dst_free()'d instead of
> dst_release()'d.
> 
> > If it is not needed, we might need to release a reference in the else {}
> > clause, no ?
> 
> Nope.  'rt' has a reference count of one, which is for the caller, not
> for this cached location.

But isnt DST_NOCACHE intent reverted then ?

like you meant :

+       } else {
+               /* Routes we intend to cache in the FIB nexthop have
+                * the DST_NOCACHE bit unset.  However, if we are
+                * unsuccessful at storing this route into the cache
+                * we really need to set that bit.
+                */
+               rt->dst.flags |= DST_NOCACHE;
        }
