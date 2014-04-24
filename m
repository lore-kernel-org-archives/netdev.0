From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Thu, 24 Apr 2014 16:20:30 +0200
Message-ID: <20140424142030.GD1960@order.stressinduktion.org>
References: <535918BC.5030708@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36913 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755932AbaDXOUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:20:32 -0400
Content-Disposition: inline
In-Reply-To: <535918BC.5030708@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Thu, Apr 24, 2014 at 09:59:24AM -0400, Chris Mason wrote:
> The ipv6 code to dump routes in /proc/net/ipv6_route can hold
> a read lock on the table for a very long time.  This ends up blocking
> writers and triggering softlockups.
>
> This patch is a simple work around to limit the number of entries
> we'll walk while processing /proc/net/ipv6_route.  It intentionally
> slows down proc file reading to make sure we don't lock out the
> real ipv6 traffic.

I guess most time is spent in formatting and printing the rt6_info details
to the procfs file. Have you tried excluding !(rt6_info->rt6i_flags &
RTF_CACHE) routes?

Maybe this is a viable alternative. A patch could also check for
RTF_DYNAMIC and RTF_MODIFIED so we would still show redirected and
mtu-caching nodes.

> This patch is also horrible, and doesn't actually fix the entire
> problem.  We still have rcu_read_lock held the whole time we cat
> /proc/net/ipv6_route.  On an unpatched machine, I've clocked the
> time required to cat /proc/net/ipv6_route at 14 minutes.
> 
> java cats this proc file on startup to search for local routes, and the
> resulting contention on the table lock makes our boxes fall over.

Urks, does plain openjdk do that or is this something in your application?

> 
> So, I'm sending the partial fix to get discussion started.

I am planing to submit patches which reduce the caching of DST_HOST
entries in the ipv6 fib next month which will result in a much smaller
fib to walk by then.

Greetings,

  Hannes
