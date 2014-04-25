From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for
 /proc/net/ipv6_route
Date: Fri, 25 Apr 2014 16:09:29 -0400 (EDT)
Message-ID: <20140425.160929.1031376209639331549.davem@davemloft.net>
References: <535918BC.5030708@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clm@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbaDYUJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 16:09:30 -0400
In-Reply-To: <535918BC.5030708@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Mason <clm@fb.com>
Date: Thu, 24 Apr 2014 09:59:24 -0400

> The ipv6 code to dump routes in /proc/net/ipv6_route can hold
> a read lock on the table for a very long time.  This ends up blocking
> writers and triggering softlockups.
> 
> This patch is a simple work around to limit the number of entries
> we'll walk while processing /proc/net/ipv6_route.  It intentionally
> slows down proc file reading to make sure we don't lock out the
> real ipv6 traffic.
> 
> This patch is also horrible, and doesn't actually fix the entire
> problem.  We still have rcu_read_lock held the whole time we cat
> /proc/net/ipv6_route.  On an unpatched machine, I've clocked the
> time required to cat /proc/net/ipv6_route at 14 minutes.

There is another way to more effectively mitigate this.

Take the rtnl mutex over the traversals.

The tables cannot change if you hold it.

Then you can use rcu_dereference_rtnl() in the table traversals and
get rid of the RCU locking entirely.

Now you're only left with the read locking over the individual trees.
And as in your patch we can drop it temporarily after a limit is hit.

But yes, longer term we need to convert the ipv6 route trees over to
RCU or similar.

Even better would be to align the ipv6 routing with how ipv4 works
since the routing-cache removal.
