From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4] ipv6:introduce function to find route for redirect
Date: Mon, 2 Sep 2013 21:50:56 +0200
Message-ID: <20130902195056.GA5451@order.stressinduktion.org>
References: <52242CE1.5050501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33312 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758923Ab3IBTu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 15:50:57 -0400
Content-Disposition: inline
In-Reply-To: <52242CE1.5050501@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 02, 2013 at 02:14:57PM +0800, Duan Jiong wrote:
> +static struct rt6_info *__ip6_route_redirect(struct net *net,
> +					     struct fib6_table *table,
> +					     struct flowi6 *fl6,
> +					     int flags)
> +{
> +	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl6;
> +	struct rt6_info *rt;
> +	struct fib6_node *fn;
> +
> +	/* Get the "current" route for this destination and
> +	 * check if the redirect has come from approriate router.
> +	 *
> +	 * RFC 4861 specifies that redirects should only be
> +	 * accepted if they come from the nexthop to the target.
> +	 * Due to the way the routes are chosen, this notion
> +	 * is a bit fuzzy and one might need to check all possible
> +	 * routes.
> +	 */
> +
> +	read_lock_bh(&table->tb6_lock);
> +	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
> +restart:
> +	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
> +		if (rt6_check_expired(rt))
> +			continue;
> +		if (rt->dst.error)
> +			continue;

Sorry, I should have been more clear what I meant with failing early:

I considered a setup like this:

ip -6 r a default nexthop via fe80::1 dev eth0
ip -6 r a prohibit 2002:1::/64

If the kernel receives a redirect for a destination e.g. 2002:1::1 we
would backtrack above the prohibit rule and return the dst of the default
route and would insert a new cached route which could circumvent the
prohibit rule. We have to try to lock down the tree below 2002:1::/64
in that case. A possible solution for that would be to do something
like this:

	/* We don't accept a redirect in case a more specific route is
	 * installed with dst.error and stop backtracking.
	 */
	if (rt->dst.error)
		break;

Either we have to replace the rt with net->ipv6.ip6_null_entry in that
case or check dst->error before calling rt6_do_redirect below.

> +		if (!(rt->rt6i_flags & RTF_GATEWAY))
> +			continue;
> +		if (fl6->flowi6_oif != rt->dst.dev->ifindex)
> +			continue;
> +		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
> +			continue;
> +		break;
> +	}
> +
> +	if (!rt)
> +		rt = net->ipv6.ip6_null_entry;
> +	BACKTRACK(net, &fl6->saddr);
> +out:
> +	dst_hold(&rt->dst);
> +
> +	read_unlock_bh(&table->tb6_lock);
> +
> +	return rt;
> +};
>
> [...]
>
> @@ -1171,9 +1238,8 @@ void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
>  	fl6.saddr = iph->saddr;
>  	fl6.flowlabel = ip6_flowinfo(iph);
>  
> -	dst = ip6_route_output(net, NULL, &fl6);
> -	if (!dst->error)
> -		rt6_do_redirect(dst, NULL, skb);
> +	dst = ip6_route_redirect(net, &fl6, &ipv6_hdr(skb)->saddr);
> +	rt6_do_redirect(dst, NULL, skb);
>  	dst_release(dst);
>  }
>  EXPORT_SYMBOL_GPL(ip6_redirect);
> @@ -1193,9 +1259,8 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
>  	fl6.daddr = msg->dest;
>  	fl6.saddr = iph->daddr;
>  
> -	dst = ip6_route_output(net, NULL, &fl6);
> -	if (!dst->error)
> -		rt6_do_redirect(dst, NULL, skb);
> +	dst = ip6_route_redirect(net, &fl6, &iph->saddr);
> +	rt6_do_redirect(dst, NULL, skb);
>  	dst_release(dst);
>  }

Btw. I still think it should be possible to eliminate
ip6_redirect_no_header:

We could always use ip6_redirect_no_header and use the data of the redirected
header option just for finding the socket to be notified. We can do the whole
verification and route updating in ndisc layer and then just call into icmpv6
layer if upper protocols need a notification of the redirect. But that should
go into another patch. ;)

Thanks,

  Hannes
