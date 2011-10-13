From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Thu, 13 Oct 2011 12:09:50 +0200
Message-ID: <20111013100950.GO1830@secunet.com>
References: <20111011110842.GC1830@secunet.com>
 <20111011110922.GD1830@secunet.com>
 <20111012.170218.279202034199478303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41347 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553Ab1JMKJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Oct 2011 06:09:57 -0400
Content-Disposition: inline
In-Reply-To: <20111012.170218.279202034199478303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 05:02:18PM -0400, David Miller wrote:
> 
> This dst_check() call will only do something if dst->obsolete is non-zero.
> 
> If dst->obsolete can be set in these circumstances, that's a bug.  The
> caller is responsible for providing either a freshly looked up route
> or a cached route which has had dst_check() or sk_dst_check() invoked
> upon it.

dst->obsolete was -1 in all cases I observed, regardless if connected or not.

> 
> I am pretty sure these rules are followed by the current code.
> 
> Again, there are only two scenerios:
> 
> 1) 'rt' is just looked up by caller (f.e. udp_sendmsg() in rt == NULL case),
>    here dst->obsolete is very unlikely to be non-zero.
> 
> 2) Connected case, and we use cached route from the socket, but here
>    we'll use sk_dst_check() to validate the route.  sk_dst_check()
>    makes the necessary dst->ops->check() call if dst->obsolete is
>    non-zero, and in fact that is it's one and only job.
> 

At least it seems that raw_sendmsg() and ping_sendmsg() don't use
a cached route, they do the route lookup in any case. I don't see
where we check if we learned a new pmtu in this cases. 

I added some debugging output and saw that peer->pmtu_learned
has the correct pmtu value, but it never ends up in the metric
of the dst_entry.

With a ping -s 1400 to a destination where the pmtu is 1000
I get for each packet 'Frag needed and DF set (mtu = 1000)'.
That's how I noticed that something changed.

With the dst_check() in ip_setup_cork() I get
'Frag needed and DF set (mtu = 1000)' for the first packet and
all further packets reach the destination, as it was before
commmit 2c8cec5c.
