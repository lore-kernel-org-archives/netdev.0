From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4] route cache: Introduce rt_genid for smooth cache
 invalidation
Date: Thu, 31 Jan 2008 17:05:36 -0800 (PST)
Message-ID: <20080131.170536.111281174.davem@davemloft.net>
References: <47A03098.7060100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert.Olsson@data.slu.se
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52661
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935063AbYBABFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 20:05:16 -0500
In-Reply-To: <47A03098.7060100@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 30 Jan 2008 09:08:56 +0100

> Current ip route cache implementation is not suited to large caches.
> 
> We can consume a lot of CPU when cache must be invalidated, since we
> currently need to evict all cache entries, and this eviction is
> sometimes asynchronous. min_delay & max_delay can somewhat control this
> asynchronism behavior, but whole thing is a kludge, regularly triggering
> infamous soft lockup messages. When entries are still in use, this also
> consumes a lot of ram, filling dst_garbage.list.
> 
> A better scheme is to use a generation identifier on each entry,
> so that cache invalidation can be performed by changing the table
> identifier, without having to scan all entries.
> No more delayed flushing, no more stalling when secret_interval expires.
> 
> Invalidated entries will then be freed at GC time (controled by
> ip_rt_gc_timeout or stress), or when an invalidated entry is found
> in a chain when an insert is done.
> Thus we keep a normal equilibrium.
> 
> This patch :
> - renames rt_hash_rnd to rt_genid (and makes it an atomic_t)
> - Adds a new rt_genid field to 'struct rtable' (filling a hole on 64bit)
> - Checks entry->rt_genid at appropriate places :
> --- Readers have to ignore invalidated entries.
> --- Writers can delete invalidated entries.
> - Removes rt_flush_timer timer
> - Removes unused /proc/sys/net/ipv4/{min_delay,max_delay}
> 
> We even reduce size of route.o
> 
> # size net/ipv4/route.o
>     text    data     bss     dec     hex filename
>    20038    1331     160   21529    5419 net/ipv4/route.o.before
>    19991    1203     104   21298    5332 net/ipv4/route.o
> 
> Next step will be to audit all rt_cache_flush(0) (aka flushes) users, see
> if they can be converted to "invalidate the cache" users.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

This looks really nice, applied, thanks Eric.
