From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Mon, 06 Feb 2012 15:29:16 -0500 (EST)
Message-ID: <20120206.152916.224032109057159733.davem@davemloft.net>
References: <20120202101141.GC23142@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538Ab2BFU3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 15:29:34 -0500
In-Reply-To: <20120202101141.GC23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 2 Feb 2012 11:11:41 +0100

> At the moment we initialize the routing metrics with the, on the inetpeer
> cached values in rt_init_metrics(). So if we have the metrics cached on the
> inetpeer, we ignore the user configured fib_metrics. This leads to the fact 
> that we can't configure the mtu, hoplimit etc. if we have learned metrics 
> cached. This patchset adds a possibility to invalidate and exchange the
> cached inetpeer metrics. In detail it does:
> 
> 1. Allocate the inetpeer metrics dynamically and add a reference
> to the inetpeer.
> 
> 2. Remove the direct reference of the inetpeer metrics from
> dst->_metrics and access the metrics via the inetpeer reference
> of the route. This makes it possible to exchange the inetpeer
> metrics if they get invalidated.
> 
> 3. Protect the inetpeer metrics with rcu.
> 
> 4. Add a peer_genid to invalidate the metrics. When the peer_genid
> is incremeted we allocate new metrics and exchange the metrics
> pointer of the inetpeer.
> 
> For the case that such a approach is acceptable, I have another patch
> to unify peer_genid and redirect_genid.

Thinking about this, it seems overkill to check this on every metric
access.

You have an opportunity to validate metrics when the peer is bound to
the route.

This is because any change to the FIB metrics, is in turn a change
to the FIB, which therefore invalidates the entire routing cache.

So you can be sure that a new route cache entry will be created, and
at that creation time you can ensure that we'll respect the updated
FIB metrics if encessary.
