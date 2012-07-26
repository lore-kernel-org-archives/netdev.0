From: David Miller <davem@davemloft.net>
Subject: Re: open sockets preventing unregister_netdevice from completing
 in linux-next (next-20120724)
Date: Thu, 26 Jul 2012 14:10:47 -0700 (PDT)
Message-ID: <20120726.141047.1871303031596778701.davem@davemloft.net>
References: <1343227128.2626.11157.camel@edumazet-glaptop>
	<20120725.151737.1807149851147342859.davem@davemloft.net>
	<1343322928.2626.11764.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55913 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412Ab2GZVKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:10:53 -0400
In-Reply-To: <1343322928.2626.11764.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Jul 2012 19:15:28 +0200

> On Wed, 2012-07-25 at 15:17 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 25 Jul 2012 16:38:48 +0200
>> 
>> > Yes, we miss what was done with rt_cache_flush() : find all cached
>> > routes and release all dev references...
>> 
>> We can fix this with a two-pronged approach:
>> 
>> 1) Walk the FIB info nexthops and invalidate.
>> 
>> 2) Entries not cached in the FIB info nexthops go into a
>>    per-netns list which is scanned as well.
>> 
>> I'll try to work on this if nobody beats me to it.
> 
> With your latest patch, I can "rmmod tg3" while sockets are active.
> 
> Not sure we need all this now ?
> 
> (the trick is probably in fib_semantics.c, when you changed
> dst_release() to dst_free())

That's not the problem.  Not all routes are cached in the FIB nexthop.

Any route that doesn't resolve to a FIB info (255.255.255.255, etc.)
or uses special features (tclassid, etc.) doesn't get cached.

Therefore if a socket gets that kind of route, and then becomes
inactive, we can hold onto the device references forever.  The entity
with the route has to call dst_ops->check() to see that the route has
become invalid, but if the application is inactive, that will never
happen.

We have to put such non-cached routes into a special list or table of
some kind, so that we can zap a netdevice if it wants to go down or
unload before the final dst_release() happens.
