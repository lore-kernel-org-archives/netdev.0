From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Thu, 22 Dec 2011 13:51:27 -0500 (EST)
Message-ID: <20111222.135127.1577166695312077920.davem@davemloft.net>
References: <20111221085616.GO6348@secunet.com>
	<20111221.155615.990885397853981125.davem@davemloft.net>
	<20111222102526.GT6348@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217Ab1LVSwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 13:52:43 -0500
In-Reply-To: <20111222102526.GT6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 22 Dec 2011 11:25:26 +0100

> Actually, I'm getting some doubts on the concept of caching
> the metrics on the inetpeer. How should we handle the case when
> we have multiple routes with different metrics to the same
> destination? As it is, we can cache just one of them on the
> inetpeer.

In such cases the metrics won't be perfect.

Actually, we have two kinds of metrics and it might be best in the
long term to seperate them out explicitly.

We have "loose" metrics (such as all the TCP measurements) which,
if incorrect, will lead to suboptimal performance but will not
dramatically effect connectivity.

Then we have "strict" metrics like PMTU information and redirects,
which could have more fatal consequences if wrong.

The core issue is I want to keep these things tied only to destination
address, it is the only sane way to get the routing cache removed.

Sockets and the packet forwarding path in the future will be using
routes that cover whole subnets, or even the default route.  There
will be no "rt->rt_dst" and there will also be not attached inetpeer.

The inetpeer, or something like it, will be managed seperately.
Therefore metrics will need to be calculated using both objects (rt
and inetpeer).

This is one of the longer term design issues we face in the routing
cache removal and for which I don't have exact plans for yet.  I'm
still concentrating on "ref-less" neighbour entries, so once I finish
that work I can think more seriously about metrics in a world without
the routing cache.
