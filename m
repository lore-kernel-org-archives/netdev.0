From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Fri, 25 Apr 2014 23:52:19 +0200
Message-ID: <20140425215219.GF7050@order.stressinduktion.org>
References: <535918BC.5030708@fb.com> <20140425.160929.1031376209639331549.davem@davemloft.net> <535AC529.4030107@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40578 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbaDYVwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 17:52:20 -0400
Content-Disposition: inline
In-Reply-To: <535AC529.4030107@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 04:27:21PM -0400, Chris Mason wrote:
> On 04/25/2014 04:09 PM, David Miller wrote:
> >From: Chris Mason <clm@fb.com>
> >Date: Thu, 24 Apr 2014 09:59:24 -0400
> >
> >>The ipv6 code to dump routes in /proc/net/ipv6_route can hold
> >>a read lock on the table for a very long time.  This ends up blocking
> >>writers and triggering softlockups.
> >>
> >>This patch is a simple work around to limit the number of entries
> >>we'll walk while processing /proc/net/ipv6_route.  It intentionally
> >>slows down proc file reading to make sure we don't lock out the
> >>real ipv6 traffic.
> >>
> >>This patch is also horrible, and doesn't actually fix the entire
> >>problem.  We still have rcu_read_lock held the whole time we cat
> >>/proc/net/ipv6_route.  On an unpatched machine, I've clocked the
> >>time required to cat /proc/net/ipv6_route at 14 minutes.
> >
> >There is another way to more effectively mitigate this.
> >
> >Take the rtnl mutex over the traversals.
> >
> >The tables cannot change if you hold it.
> >
> >Then you can use rcu_dereference_rtnl() in the table traversals and
> >get rid of the RCU locking entirely.

That's a pretty good idea!

> Ah ok, so the rtnl mutex can replace rcu_read_lock().  Will it end up 
> blocking any traffic? (sorry, filesystem guys are a little slow)

Traffic flow shouldn't get stopped but any network stack configuration
would wait for the time being completly, this could also affect ipv4.

> >Now you're only left with the read locking over the individual trees.
> >And as in your patch we can drop it temporarily after a limit is hit.
> 
> That would be wonderful because I can use some cond_resched() variant, 
> and get rid of the max_walk counter completely.
> 
> >
> >But yes, longer term we need to convert the ipv6 route trees over to
> >RCU or similar.
> 
> Instead of the ->skip counter, can we get a cursor into the tree and 
> just resume walking at the first entry after that cursor?  It would have 
> to be a key that we copy out instead of a pointer so we can drop the 
> rcu_read_lock()

The keys could be struct rt6key (rt6i_dst, rt6i_src) and the table
(which won't get dropped because of rtnl lock).

The function to locate the node would be fib6_locate, because we would
have to respect the prefix lengths during lookup.

> >Even better would be to align the ipv6 routing with how ipv4 works
> >since the routing-cache removal.
> >
> 
> I'll shop task that around here.

I'll send out some patches reducing DST_CACHE entries soon (hopefully
next week), so we can build up on them.

I am very keen on getting this task done.

Thanks,

  Hannes
