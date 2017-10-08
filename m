From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next] ipv6: Do not use this_cpu_ptr() in preemptible
 context
Date: Sun, 8 Oct 2017 19:54:07 +0300
Message-ID: <20171008165407.GA26635@shredder.mtl.com>
References: <20171008151839.24519-1-idosch@mellanox.com>
 <1507478633.14419.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
        davem@davemloft.net, weiwan@google.com, mlxsw@mellanox.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39859 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751553AbdJHQyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 12:54:10 -0400
Content-Disposition: inline
In-Reply-To: <1507478633.14419.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Sun, Oct 08, 2017 at 09:03:53AM -0700, Eric Dumazet wrote:
> Thanks Ido for this patch.
> 
> IMO, we no longer play this read_lock() -> write_lock() game since
> ip6_dst_gc() could be called from rt6_make_pcpu_route()

Right, cause we can't deadlock anymore as with the rwlock.

> 
> So we might simplify things quite a bit, by blocking BH (and thus
> preventing preemption)
> 
> Something like :
> 
>  net/ipv6/route.c |   26 ++++++--------------------
>  1 file changed, 6 insertions(+), 20 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 399d1bceec4a6e6736c367e706dd2acbd4093d58..606e80325b21c0e10a02e9c7d5b3fcfbfc26a003 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1136,15 +1136,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
>  	dst_hold(&pcpu_rt->dst);
>  	p = this_cpu_ptr(rt->rt6i_pcpu);
>  	prev = cmpxchg(p, NULL, pcpu_rt);
> -	if (prev) {
> -		/* If someone did it before us, return prev instead */
> -		/* release refcnt taken by ip6_rt_pcpu_alloc() */
> -		dst_release_immediate(&pcpu_rt->dst);
> -		/* release refcnt taken by above dst_hold() */
> -		dst_release_immediate(&pcpu_rt->dst);
> -		dst_hold(&prev->dst);
> -		pcpu_rt = prev;
> -	}
> +	BUG_ON(prev);

Is this BUG_ON() now valid because of the local_bh_disable() in
ip6_pol_route()?

>  
>  	rt6_dst_from_metrics_check(pcpu_rt);
>  	return pcpu_rt;
> @@ -1739,31 +1731,25 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>  		struct rt6_info *pcpu_rt;
>  
>  		dst_use_noref(&rt->dst, jiffies);
> +		local_bh_disable();
>  		pcpu_rt = rt6_get_pcpu_route(rt);
>  
> -		if (pcpu_rt) {
> -			rcu_read_unlock();
> -		} else {
> +		if (!pcpu_rt) {
>  			/* atomic_inc_not_zero() is needed when using rcu */
>  			if (atomic_inc_not_zero(&rt->rt6i_ref)) {
> -				/* We have to do the read_unlock first
> -				 * because rt6_make_pcpu_route() may trigger
> -				 * ip6_dst_gc() which will take the write_lock.
> -				 *
> -				 * No dst_hold() on rt is needed because grabbing
> +				/* No dst_hold() on rt is needed because grabbing
>  				 * rt->rt6i_ref makes sure rt can't be released.
>  				 */
> -				rcu_read_unlock();
>  				pcpu_rt = rt6_make_pcpu_route(rt);
>  				rt6_release(rt);
>  			} else {
>  				/* rt is already removed from tree */
> -				rcu_read_unlock();
>  				pcpu_rt = net->ipv6.ip6_null_entry;
>  				dst_hold(&pcpu_rt->dst);
>  			}
>  		}
> -
> +		local_bh_enable();
> +		rcu_read_unlock();
>  		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
>  		return pcpu_rt;
>  	}

I replaced my patch with yours and I don't trigger the bug anymore. Feel
free to add my tag:

Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
