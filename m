From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Thu, 14 Oct 2010 00:16:15 +0200
Message-ID: <4CB62FAF.1030009@free.fr>
References: <m1y6a81vms.fsf@fess.ebiederm.org>	<20101008.102012.226761665.davem@davemloft.net>	<m11v801tfr.fsf@fess.ebiederm.org> <20101012.130520.48517464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, hans.schillstrom@ericsson.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:36977 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab0JMWQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 18:16:22 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.1/8.13.1) with ESMTP id o9DMGIQD007383
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 22:16:18 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9DMGI6J4116534
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 00:16:18 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o9DMGIeV016839
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 00:16:18 +0200
In-Reply-To: <20101012.130520.48517464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2010 10:05 PM, David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 08 Oct 2010 10:32:40 -0700
>
>    
>> It is just dealing with not flushing the entire routing cache, just the
>> routes that have expired.  Which prevents one network namespace from
>> flushing it's routes and DOS'ing another.
>>      
> That's a very indirect and obfuscated way of handling it.
>    

I agree.

> And I still don't know why we let the first contiguous set of expired
> entries in the chain get freed outside of the lock, and the rest
> inside the lock.  That really isn't explained by anything I've read.
>
> How about we just do exactly what's intended, and with no ifdefs?
>    
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

Dave,

do you mind to wait I test the patch before merging it ?
I would like to stress a bit this routine with multiple containers.

Thanks
    -- Daniel

> Signed-off-by: David S. Miller<davem@davemloft.net>
>
> diff --git a/include/net/route.h b/include/net/route.h
> index 7e5e73b..8d24761 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -106,7 +106,7 @@ extern int		ip_rt_init(void);
>   extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
>   				       __be32 src, struct net_device *dev);
>   extern void		rt_cache_flush(struct net *net, int how);
> -extern void		rt_cache_flush_batch(void);
> +extern void		rt_cache_flush_batch(struct net *net);
>   extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
>   extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
>   extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 919f2ad..4039f56 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -999,7 +999,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>   		rt_cache_flush(dev_net(dev), 0);
>   		break;
>   	case NETDEV_UNREGISTER_BATCH:
> -		rt_cache_flush_batch();
> +		rt_cache_flush_batch(dev_net(dev));
>   		break;
>   	}
>   	return NOTIFY_DONE;
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0755aa4..6ad730c 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -712,13 +712,14 @@ static inline int rt_is_expired(struct rtable *rth)
>    * Can be called by a softirq or a process.
>    * In the later case, we want to be reschedule if necessary
>    */
> -static void rt_do_flush(int process_context)
> +static void rt_do_flush(struct net *net, int process_context)
>   {
>   	unsigned int i;
>   	struct rtable *rth, *next;
> -	struct rtable * tail;
>
>   	for (i = 0; i<= rt_hash_mask; i++) {
> +		struct rtable *list, **pprev;
> +
>   		if (process_context&&  need_resched())
>   			cond_resched();
>   		rth = rt_hash_table[i].chain;
> @@ -726,41 +727,27 @@ static void rt_do_flush(int process_context)
>   			continue;
>
>   		spin_lock_bh(rt_hash_lock_addr(i));
> -#ifdef CONFIG_NET_NS
> -		{
> -		struct rtable ** prev, * p;
>
> -		rth = rt_hash_table[i].chain;
> +		pprev =&rt_hash_table[i].chain;
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
> -		prev =&rt_hash_table[i].chain;
> -		for (p = *prev; p; p = next) {
> -			next = p->dst.rt_next;
> -			if (!rt_is_expired(p)) {
> -				prev =&p->dst.rt_next;
> -			} else {
> -				*prev = next;
> -				rt_free(p);
> -			}
> -		}
> +				rth->dst.rt_next = list;
> +				list = rth;
> +			} else
> +				pprev =&rth->dst.rt_next;
> +
> +			rth = next;
>   		}
> -#else
> -		rth = rt_hash_table[i].chain;
> -		rt_hash_table[i].chain = NULL;
> -		tail = NULL;
> -#endif
> +
>   		spin_unlock_bh(rt_hash_lock_addr(i));
>
> -		for (; rth != tail; rth = next) {
> -			next = rth->dst.rt_next;
> -			rt_free(rth);
> +		for (; list; list = next) {
> +			next = list->dst.rt_next;
> +			rt_free(list);
>   		}
>   	}
>   }
> @@ -906,13 +893,13 @@ void rt_cache_flush(struct net *net, int delay)
>   {
>   	rt_cache_invalidate(net);
>   	if (delay>= 0)
> -		rt_do_flush(!in_softirq());
> +		rt_do_flush(net, !in_softirq());
>   }
>
>   /* Flush previous cache invalidated entries from the cache */
> -void rt_cache_flush_batch(void)
> +void rt_cache_flush_batch(struct net *net)
>   {
> -	rt_do_flush(!in_softirq());
> +	rt_do_flush(net, !in_softirq());
>   }
>
>   static void rt_emergency_hash_rebuild(struct net *net)
>
>    

