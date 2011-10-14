From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Fri, 14 Oct 2011 07:54:06 +0200
Message-ID: <20111014055406.GP1830@secunet.com>
References: <20111011110922.GD1830@secunet.com>
 <20111012.170218.279202034199478303.davem@davemloft.net>
 <20111013100950.GO1830@secunet.com>
 <20111013.135808.636341622629050648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41003 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755170Ab1JNFyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 01:54:13 -0400
Content-Disposition: inline
In-Reply-To: <20111013.135808.636341622629050648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2011 at 01:58:08PM -0400, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 13 Oct 2011 12:09:50 +0200
> 
> > At least it seems that raw_sendmsg() and ping_sendmsg() don't use
> > a cached route, they do the route lookup in any case. I don't see
> > where we check if we learned a new pmtu in this cases. 
> 
> A freshly looked up route should not have ->obsolete set.
> 
> That's why we don't do dst_check() in that part of the ip_output.c
> helper code you're modifying.
> 
> Please find out exactly why dst->obsolete is non-zero on a freshly
> looked up route.  It's unexpected.

Hm, on a slow path route lookup e.g. __mkroute_output() calls
rt_dst_alloc() which initializes dst->obsolete to -1. It seems
that ___dst_free() is the only function that ever changes the
initial obsolete value. After calling ___dst_free() dst->obsolete
is 2.

Btw. on a slow path route lookup, __mkroute_output() and friends
initialize the pmtu informations via rt_set_nexthop(). How do we
check if these informations are still valid if we get the route
via the routing hash cache? Do we need to check in this case?

The raw protocol uses ip4_datagram_connect() as it's connect function.
ip4_datagram_connect() uses sk_dst_set() to cache the dst_entry on
the socket, why we don't use this cached dst_entry on raw_sendmsg()
in the connected case?
