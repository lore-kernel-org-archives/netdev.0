From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 02 Apr 2005 18:21:05 +1000
Message-ID: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
References: <424DD78D.7070001@cosmosbay.com>
Cc: davem@davemloft.net, netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com (Eric Dumazet)
In-Reply-To: <424DD78D.7070001@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> OK this patch includes everything...
> 
>  - Locking abstraction
>  - rt_check_expire() fixes
>  - New gc_interval_ms sysctl to be able to have timer gc_interval < 1 second
>  - New gc_debug sysctl to let sysadmin tune gc
>  - Less memory used by hash table (spinlocks moved to a smaller table)
>  - sizing of spinlocks table depends on NR_CPUS
>  - hash table allocated using alloc_large_system_hash() function
>  - header fix for /proc/net/stat/rt_cache

This patch is doing too many things.  How about splitting it up?

For instance the spin lock stuff is pretty straightforward and
should be in its own patch.

The benefits of the GC changes are not obvious to me.  rt_check_expire
is simply meant to kill off old entries.  It's not really meant to be
used to free up entries when the table gets full.

rt_garbage_collect on the other hand is designed to free entries
when it is needed.  Eric raised the point that rt_garbage_collect
is pretty expensive.  So what about amortising its cost a bit more?

For instance, we can set a new threshold that's lower than gc_thresh
and perform GC on the chain being inserted in rt_intern_hash if we're
above that threshold.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
