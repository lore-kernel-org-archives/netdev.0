From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: Rate Limitation of Router Reachability Probing for possible dead
 routers (is Re: ipv6: Do not depend on rt->n in rt6_probe().)
Date: Tue, 22 Jan 2013 12:47:42 +0900
Message-ID: <50FE0BDE.2080206@linux-ipv6.org>
References: <20130121182858.GA8808@elgon.mountain> <50FD8BC6.1030509@linux-ipv6.org> <50FD96E4.1020607@linux-ipv6.org> <20130121.154425.239941234471254414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51066 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752656Ab3AVDro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 22:47:44 -0500
In-Reply-To: <20130121.154425.239941234471254414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 22 Jan 2013 04:28:36 +0900
> 
>> Ok, fix is easy, but in fact, we have broken router reachability
>> probing.
>>
>> Here rt->n was neighbour entry for (unreachable) router.
>> The specification says, we SHOUDLD probe such router, but we
>> should  have some rate limit (once per minute, or so).
>>
>> We used "rt->n->updated" for this purpose, but now, if NS failed,
>> we may immediately removes neighbour entry for it.  So,
>> we might continue sending NS to dead router every 1 second.
>>
>> Any ideas?
> 
> I don't see exactly how looking up the neigh on demand is different
> from using a cached one in this context.
> 
> In both cases there should be a neigh entry in nd_tbl, why would
> there not be one?

Well, now, the almost only refcnt holder except table is timer.
because each route does not have reference to neighbour (thus no
refcnt) anymore.

If n->nud_state become NUD_FAILED (or even in NUD_STALE),
the entry does not have any refcnt holders other than table,
and then, neigh_periodic_work() will purge such entries.

> If necessary, you can decide to mark entries in such a way that
> they would have a lower priority for neigh GC purging if that
> is the issue.

It seems that we removed check for gc_thresh1 (number of
minimum entries) in neigh_alloc() during 2.3.x but I cannot
remember the reason (or just I do not know it).

--yoshfuji
