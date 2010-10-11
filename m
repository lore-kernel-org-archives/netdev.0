From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: speedup neigh_hh_init()
Date: Mon, 11 Oct 2010 09:18:56 -0700 (PDT)
Message-ID: <20101011.091856.71123383.davem@davemloft.net>
References: <1286456008.2912.171.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46642
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755313Ab0JKQSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 12:18:34 -0400
In-Reply-To: <1286456008.2912.171.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Oct 2010 14:53:28 +0200

> When a new dst is used to send a frame, neigh_resolve_output() tries to
> associate an struct hh_cache to this dst, calling neigh_hh_init() with
> the neigh rwlock write locked.
> 
> Most of the time, hh_cache is already known and linked into neighbour,
> so we find it and increment its refcount.
> 
> This patch changes the logic so that we call neigh_hh_init() with
> neighbour lock read locked only, so that fast path can be run in
> parallel by concurrent cpus.
> 
> This brings part of the speedup we got with commit c7d4426a98a5f
> (introduce DST_NOCACHE flag) for non cached dsts, even for cached ones,
> removing one of the contention point that routers hit on multiqueue
> enabled machines.
> 
> Further improvements would need to use a seqlock instead of an rwlock to
> protect neigh->ha[], to not dirty neigh too often and remove two atomic
> ops.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok this patch assumes that neighbours are highly shared, which
is a reasonable thing to optimize for.

So, applied, thanks a lot!

BTW, I think you can RCU this thing.  Require that every change
to the 'hh' entry be done in a newly allocated entry.

Then the cmpxchg() on the hh pointer interlocks.
