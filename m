From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 02 Apr 2005 11:21:30 +0200
Message-ID: <424E641A.1020609@cosmosbay.com>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>>OK this patch includes everything...
>>
>> - Locking abstraction
>> - rt_check_expire() fixes
>> - New gc_interval_ms sysctl to be able to have timer gc_interval < 1 s=
econd
>> - New gc_debug sysctl to let sysadmin tune gc
>> - Less memory used by hash table (spinlocks moved to a smaller table)
>> - sizing of spinlocks table depends on NR_CPUS
>> - hash table allocated using alloc_large_system_hash() function
>> - header fix for /proc/net/stat/rt_cache
>=20
>=20
> This patch is doing too many things.  How about splitting it up?
>=20
> For instance the spin lock stuff is pretty straightforward and
> should be in its own patch.
>=20
> The benefits of the GC changes are not obvious to me.  rt_check_expire
> is simply meant to kill off old entries.  It's not really meant to be
> used to free up entries when the table gets full.

Well, I began my work because of the overflow bug in rt_check_expire()...
Then I realize this function could not work as expected. On a loaded mach=
ine, one timer tick is 1 ms.
During this time, number of chains that are scanned is ridiculous.
With the standard timer of 60 second, fact is rt_check_expire() is useles=
s.

>=20
> rt_garbage_collect on the other hand is designed to free entries
> when it is needed.  Eric raised the point that rt_garbage_collect
> is pretty expensive.  So what about amortising its cost a bit more?

Yes. rt_garbage_collect() has serious problems. But this function is sooo=
 complex I dont want to touch it and let experts do it if they=20
want. But then one may think why we have two similar functions that are d=
oing basically the same thing : garbage collection.

One of a production machine rtstat -i 1 output is :

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|r=
t_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt=
_cache|
  entries|  in_hit|in_slow_|in_slow_|in_no_ro|  in_brd|in_marti|in_marti|=
=20
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|ou=
t_hlis|
         |        |     tot|      mc|     ute|        |  an_dst|  an_src|=
        |    _tot|     _mc|        |      ed|    miss| verflow|=20
_search|t_search|
  2618087|   28581|    7673|       0|       0|       0|       0|       0|=
    1800|    1450|       0|       0|       0|       0|       0|=20
37630|    4783|
  2618689|   25444|    4918|       0|       0|       0|       0|       0|=
    2051|    1699|       0|       0|       0|       0|       0|=20
27741|    5461|
  2619369|   25000|    4567|       0|       0|       0|       0|       0|=
    1860|    1304|       0|       0|       0|       0|       0|=20
26606|    4563|
  2618396|   24830|    4633|       0|       0|       0|       0|       0|=
    1959|    1492|       0|       0|       0|       0|       0|=20
26643|    4930|


Without serious tuning, this machine could not handle this load, or even =
half of it.

Crashes usually occurs when secret_interval interval is elapsed : rt_cach=
e_flush(0); is called, and the whole machine begins to die.

>=20
> For instance, we can set a new threshold that's lower than gc_thresh
> and perform GC on the chain being inserted in rt_intern_hash if we're
> above that threshold.

We could also try to perform GC on L1_CACHE_SIZE/sizeof(struct rt_hash_bu=
cket) chains, not only the 'current chain', to fully use the cache=20
miss.

>=20
> Cheers,

Thank you
