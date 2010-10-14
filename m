From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Wed, 13 Oct 2010 21:40:49 -0700
Message-ID: <m1fww94ca6.fsf@fess.ebiederm.org>
References: <m1y6a81vms.fsf@fess.ebiederm.org>
	<20101008.102012.226761665.davem@davemloft.net>
	<m11v801tfr.fsf@fess.ebiederm.org>
	<20101012.130520.48517464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hans.schillstrom@ericsson.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:40665 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab0JNElA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 00:41:00 -0400
In-Reply-To: <20101012.130520.48517464.davem@davemloft.net> (David Miller's
	message of "Tue, 12 Oct 2010 13:05:20 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 08 Oct 2010 10:32:40 -0700
>
>> It is just dealing with not flushing the entire routing cache, just the
>> routes that have expired.  Which prevents one network namespace from
>> flushing it's routes and DOS'ing another.
>
> That's a very indirect and obfuscated way of handling it.
>
> And I still don't know why we let the first contiguous set of expired
> entries in the chain get freed outside of the lock, and the rest
> inside the lock.  That really isn't explained by anything I've read.
>
> How about we just do exactly what's intended, and with no ifdefs?

I'm all for no ifdefs.

And reading the code your version looks much simpler and easier
to read and I am all for that.

However I think the test should still be rt_is_expired(), because
that is what rt_do_flush() is doing removing the expired entries
from the list.

The only difference being that we remove the assumption that all hash
table entries must be expired at this point.

We have very straight forwardly expired all of the route table entries
for the namespace that go this going earlier.


Eric


> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/include/net/route.h b/include/net/route.h
> index 7e5e73b..8d24761 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -106,7 +106,7 @@ extern int		ip_rt_init(void);
>  extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
>  				       __be32 src, struct net_device *dev);
>  extern void		rt_cache_flush(struct net *net, int how);
> -extern void		rt_cache_flush_batch(void);
> +extern void		rt_cache_flush_batch(struct net *net);
>  extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
>  extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
>  extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 919f2ad..4039f56 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  		rt_cache_flush(dev_net(dev), 0);
>  		break;
>  	case NETDEV_UNREGISTER_BATCH:
> -		rt_cache_flush_batch();
> +		rt_cache_flush_batch(dev_net(dev));

I believe this change is actually wrong.  dev here is the first
element of a list of network devices, and that list may span multiple
network namespaces.

>  		break;
>  	}
>  	return NOTIFY_DONE;
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0755aa4..6ad730c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -712,13 +712,14 @@ static inline int rt_is_expired(struct rtable *rth)
>   * Can be called by a softirq or a process.
>   * In the later case, we want to be reschedule if necessary
>   */
> -static void rt_do_flush(int process_context)
> +static void rt_do_flush(struct net *net, int process_context)
>  {
>  	unsigned int i;
>  	struct rtable *rth, *next;
> -	struct rtable * tail;
>  
>  	for (i = 0; i <= rt_hash_mask; i++) {
> +		struct rtable *list, **pprev;
> +
>  		if (process_context && need_resched())
>  			cond_resched();
>  		rth = rt_hash_table[i].chain;
> @@ -726,41 +727,27 @@ static void rt_do_flush(int process_context)
>  			continue;
>  
>  		spin_lock_bh(rt_hash_lock_addr(i));
> -#ifdef CONFIG_NET_NS
> -		{
> -		struct rtable ** prev, * p;
>  
> -		rth = rt_hash_table[i].chain;
> +		pprev = &rt_hash_table[i].chain;
> +		rth = *pprev;
> +		while (rth) {
> +			next = rth->dst.rt_next;
> +			if (dev_net(rth->dst.dev) == net) {
> +				*pprev = next;
>  
> -		/* defer releasing the head of the list after spin_unlock */
> -		for (tail = rth; tail; tail = tail->dst.rt_next)
> -			if (!rt_is_expired(tail))
> -				break;
> -		if (rth != tail)
> -			rt_hash_table[i].chain = tail;
> -
> -		/* call rt_free on entries after the tail requiring flush */
> -		prev = &rt_hash_table[i].chain;
> -		for (p = *prev; p; p = next) {
> -			next = p->dst.rt_next;
> -			if (!rt_is_expired(p)) {
> -				prev = &p->dst.rt_next;
> -			} else {
> -				*prev = next;
> -				rt_free(p);
> -			}
> -		}
> +				rth->dst.rt_next = list;
> +				list = rth;
> +			} else
> +				pprev = &rth->dst.rt_next;
> +
> +			rth = next;
>  		}
> -#else
> -		rth = rt_hash_table[i].chain;
> -		rt_hash_table[i].chain = NULL;
> -		tail = NULL;
> -#endif
> +
>  		spin_unlock_bh(rt_hash_lock_addr(i));
>  
> -		for (; rth != tail; rth = next) {
> -			next = rth->dst.rt_next;
> -			rt_free(rth);
> +		for (; list; list = next) {
> +			next = list->dst.rt_next;
> +			rt_free(list);
>  		}
>  	}
>  }
> @@ -906,13 +893,13 @@ void rt_cache_flush(struct net *net, int delay)
>  {
>  	rt_cache_invalidate(net);
>  	if (delay >= 0)
> -		rt_do_flush(!in_softirq());
> +		rt_do_flush(net, !in_softirq());
>  }
>  
>  /* Flush previous cache invalidated entries from the cache */
> -void rt_cache_flush_batch(void)
> +void rt_cache_flush_batch(struct net *net)
>  {
> -	rt_do_flush(!in_softirq());
> +	rt_do_flush(net, !in_softirq());
>  }
>  
>  static void rt_emergency_hash_rebuild(struct net *net)
