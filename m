From: David Ahern <dsahern@gmail.com>
Subject: Re: [net-next v1] net: ipv6: avoid overhead when no custom FIB rules
 are installed
Date: Tue, 8 Aug 2017 08:46:23 -0600
Message-ID: <66e3d00a-6788-2e86-9563-fc1424a6a250@gmail.com>
References: <20170808115121.21283-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34979 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752093AbdHHOq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 10:46:27 -0400
Received: by mail-pf0-f196.google.com with SMTP id j68so3261968pfc.2
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 07:46:26 -0700 (PDT)
In-Reply-To: <20170808115121.21283-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/17 5:51 AM, Vincent Bernat wrote:
> diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
> index 2f29e4e33bd3..693c27ede40e 100644
> --- a/net/ipv6/fib6_rules.c
> +++ b/net/ipv6/fib6_rules.c
> @@ -63,19 +63,32 @@ unsigned int fib6_rules_seq_read(struct net *net)
>  struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
>  				   int flags, pol_lookup_t lookup)
>  {
> -	struct fib_lookup_arg arg = {
> -		.lookup_ptr = lookup,
> -		.flags = FIB_LOOKUP_NOREF,
> -	};
> -
>  	/* update flow if oif or iif point to device enslaved to l3mdev */
>  	l3mdev_update_flow(net, flowi6_to_flowi(fl6));

The l3mdev_update_flow can be moved to the has_custom_rules block.
l3mdev requires FIB rules for the lookups to work, so no rules means no
l3mdev configured.

Rest looks good to me.


>  
> -	fib_rules_lookup(net->ipv6.fib6_rules_ops,
> -			 flowi6_to_flowi(fl6), flags, &arg);
> -
> -	if (arg.result)
> -		return arg.result;
> +	if (net->ipv6.fib6_has_custom_rules) {
> +		struct fib_lookup_arg arg = {
> +			.lookup_ptr = lookup,
> +			.flags = FIB_LOOKUP_NOREF,
> +		};
> +
> +		fib_rules_lookup(net->ipv6.fib6_rules_ops,
> +				 flowi6_to_flowi(fl6), flags, &arg);
> +
> +		if (arg.result)
> +			return arg.result;
> +	} else {
> +		struct rt6_info *rt;
> +
> +		rt = lookup(net, net->ipv6.fib6_local_tbl, fl6, flags);
> +		if (rt != net->ipv6.ip6_null_entry && rt->dst.error != -EAGAIN)
> +			return &rt->dst;
> +		ip6_rt_put(rt);
> +		rt = lookup(net, net->ipv6.fib6_main_tbl, fl6, flags);
> +		if (rt->dst.error != -EAGAIN)
> +			return &rt->dst;
> +		ip6_rt_put(rt);
> +	}
>  
>  	dst_hold(&net->ipv6.ip6_null_entry->dst);
>  	return &net->ipv6.ip6_null_entry->dst;
