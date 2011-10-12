From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Wed, 12 Oct 2011 17:02:18 -0400 (EDT)
Message-ID: <20111012.170218.279202034199478303.davem@davemloft.net>
References: <20111011110842.GC1830@secunet.com>
	<20111011110922.GD1830@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab1JLVCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 17:02:38 -0400
In-Reply-To: <20111011110922.GD1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 11 Oct 2011 13:09:22 +0200

> Since commit 2c8cec5c (ipv4: Cache learned PMTU information in inetpeer)
> we cache the learned pmtu informations in inetpeer and propagate these
> informations with the dst_ops->check() functions. However, these functions
> might not be called for udp and raw packets. As a consequence, we don't
> use the learned pmtu informations in these cases. With this patch we
> call dst_check() from ip_setup_cork() to propagate the pmtu informations.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

This dst_check() call will only do something if dst->obsolete is non-zero.

If dst->obsolete can be set in these circumstances, that's a bug.  The
caller is responsible for providing either a freshly looked up route
or a cached route which has had dst_check() or sk_dst_check() invoked
upon it.

I am pretty sure these rules are followed by the current code.

Again, there are only two scenerios:

1) 'rt' is just looked up by caller (f.e. udp_sendmsg() in rt == NULL case),
   here dst->obsolete is very unlikely to be non-zero.

2) Connected case, and we use cached route from the socket, but here
   we'll use sk_dst_check() to validate the route.  sk_dst_check()
   makes the necessary dst->ops->check() call if dst->obsolete is
   non-zero, and in fact that is it's one and only job.

So I cannot see a case where your new check can be necessary.
