From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: irq safe sk_dst_[re]set() and
 ipv4_sk_update_pmtu() fix
Date: Mon, 30 Jun 2014 23:43:44 -0700 (PDT)
Message-ID: <20140630.234344.1428744076534818932.davem@davemloft.net>
References: <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>
	<1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
	<1404116783.15139.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dormando@rydia.net, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59011 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbaGAGnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 02:43:47 -0400
In-Reply-To: <1404116783.15139.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Jun 2014 01:26:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We have two different ways to handle changes to sk->sk_dst
> 
> First way (used by TCP) assumes socket lock is owned by caller, and use
> no extra lock : __sk_dst_set() & __sk_dst_reset()
> 
> Another way (used by UDP) uses sk_dst_lock because socket lock is not
> always taken. Note that sk_dst_lock is not softirq safe.
> 
> These ways are not inter changeable for a given socket type.
> 
> ipv4_sk_update_pmtu(), added in linux-3.8, added a race, as it used
> the socket lock as synchronization, but users might be UDP sockets.
> 
> Instead of converting sk_dst_lock to a softirq safe version, use xchg()
> as we did for sk_rx_dst in commit e47eb5dfb296b ("udp: ipv4: do not use
> sk_dst_lock from softirq context")
> 
> In a follow up patch, we probably can remove sk_dst_lock, as it is
> only used in IPv6.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Fixes: 9cb3a50c5f63e ("ipv4: Invalidate the socket cached route on pmtu events if possible")

Applied, and queued up for -stable, thanks Eric.

That dst_check() sequence in ipv4_sk_update_pmtu() is superfluous if "!new",
in fact how can it trigger?

If new is true, we just got the route from ip_route_output_flow() and we
presume it to be ok.

If new is not true, we just did the odst->ops->check() and it returned
non-NULL.

Hmmm?
