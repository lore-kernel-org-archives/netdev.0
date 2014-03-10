From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Mon, 10 Mar 2014 09:15:33 +0100
Message-ID: <20140310081533.GA27052@unicorn.suse.cz>
References: <20140308080616.GB5493@order.stressinduktion.org>
 <20140309.202658.205858191881011540.davem@davemloft.net>
 <20140310005220.GD5493@order.stressinduktion.org>
 <20140310.010313.703650662340510015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54267 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063AbaCJIPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 04:15:35 -0400
Content-Disposition: inline
In-Reply-To: <20140310.010313.703650662340510015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 01:03:13AM -0400, David Miller wrote:
> @@ -743,6 +743,30 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
>  		BUG_ON(rt6i_nsiblings != rt->rt6i_nsiblings);
>  	}
>  
> +	if (mx) {
> +		struct nlattr *nla;
> +		bool was_writable;
> +		int remaining;
> +		u32 *mp;
> +
> +		was_writable = !dst_metrics_read_only(&rt->dst);
> +		mp = dst_metrics_write_ptr(&rt->dst);
> +
> +		if (was_writable)
> +			memset(mp, 0, RTAX_MAX * sizeof(u32));
> +
> +		nla_for_each_attr(nla, mx, mx_len, remaining) {
> +			int type = nla_type(nla);
> +
> +			if (type) {
> +				if (type > RTAX_MAX)
> +					return -EINVAL;
> +
> +				mp[type - 1] = nla_get_u32(nla);
> +			}
> +		}
> +	}
> +
>  	/*
>  	 *	insert node
>  	 */

This is too early. After this point, the insertion can still fail if
(!found && !add) (i.e. when trying to modify a non-existent route with
"ip route change").

> @@ -1546,14 +1547,6 @@ int ip6_route_add(struct fib6_config *cfg)
>  	if (rt->rt6i_dst.plen == 128)
>  	       rt->dst.flags |= DST_HOST;
>  
> -	if (!(rt->dst.flags & DST_HOST) && cfg->fc_mx) {
> -		u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
> -		if (!metrics) {
> -			err = -ENOMEM;
> -			goto out;
> -		}
> -		dst_init_metrics(&rt->dst, metrics, 0);
> -	}
>  #ifdef CONFIG_IPV6_SUBTREES
>  	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
>  	rt->rt6i_src.plen = cfg->fc_src_len;

I think this should stay. We still need to allocate a separate copy of
metrics in the non-DST_HOST case, otherwise we would reintroduce the 
issue fixed by commit 8e2ec6391 ("ipv6: don't use inetpeer to store
metrics for routes."). Or rather get a null pointer dereference in 
fib6_add_rt2node() as dst_metrics_write_ptr() would return NULL. An 
alternative solution (and perhaps a more suitable one) would be to 
allocate the block in ip6_cow_metrics() instead of returning NULL.

Other than that, I believe this should work. Actually, I was also 
considering this approach but I wasn't brave enough to propose passing 
those extra parameters all the way down to rt6_add_rt2node(). But if you
are OK with it, I agree that saving the extra kzalloc()/kfree() is worth
that bit of ugliness. We could also extract the metrics from the info 
parameter we already have but it would be inefficient to parse the whole
message again.

                                                        Michal Kubecek
