From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net] ipv6: do not create neighbor entries for local delivery
Date: Tue, 13 Aug 2013 00:26:42 +0200
Message-ID: <20130812222642.GA27385@order.stressinduktion.org>
References: <20130130082608.GA1604@minipsycho.orion> <CAATkVEzJgb+J-TAkTZCUbxLPj=b=wbOmsKbgNNimEfNaC8d0Aw@mail.gmail.com> <20130808194702.GH14001@order.stressinduktion.org> <20130808201627.GI14001@order.stressinduktion.org> <520924CF.6000805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Debabrata Banerjee <dbavatar@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	Joshua Hunt <johunt@akamai.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47406 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290Ab3HLW0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 18:26:45 -0400
Content-Disposition: inline
In-Reply-To: <520924CF.6000805@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcelo!

On Mon, Aug 12, 2013 at 03:09:19PM -0300, Marcelo Ricardo Leitner wrote:
> Hannes, would something like this be acceptable? I'm hoping it's not too 
> ugly/hacky... as far as I could track back, input and output routines were 
> merged mainly due code similarity.

Your idea seems sound and I don't think it is very ugly or hacky. It's
as minimal as a stable-only patch should be. But we could simplify the
logic a bit. ;) See below.

> TPROXY scenario needs to not create this neighbor entries on INPUT path, 
> while Debabrata ping test needs it on OUTPUT path. This patch limits my 
> previous patch to INPUT only then.

Yes, agreed. I don't see anything which could break because of this patch.
So I would go with it.

> Initial testing here seems good, TPROXY seems to be working as expected and 
> also the ping6 test.
> 
> What do you think?


> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 18ea73c..603f9d9 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -791,7 +791,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
>  }
>  
>  static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
> -				      struct flowi6 *fl6, int flags)
> +				      struct flowi6 *fl6, int flags, int output)

								     bool input

>  {
>  	struct fib6_node *fn;
>  	struct rt6_info *rt, *nrt;
> @@ -799,8 +799,11 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>  	int attempts = 3;
>  	int err;
>  	int reachable = net->ipv6.devconf_all->forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
> +	int local = RTF_NONEXTHOP;
>  
>  	strict |= flags & RT6_LOOKUP_F_IFACE;
> +	if (!output)
> +			local |= RTF_LOCAL;


	if (input)
			local |= RTF_LOCAL;

>  
>  relookup:
>  	read_lock_bh(&table->tb6_lock);
> @@ -820,7 +823,7 @@ restart:
>  	read_unlock_bh(&table->tb6_lock);
>  
>  	if (!dst_get_neighbour_raw(&rt->dst)
> -	    && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
> +	    && !(rt->rt6i_flags & local))
>  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
>  	else if (!(rt->dst.flags & DST_HOST))
>  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
> @@ -864,7 +867,7 @@ out2:
>  static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
>  					    struct flowi6 *fl6, int flags)
>  {
> -	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags);
> +	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags, 0);

								      true);


>  }
>  
>  void ip6_route_input(struct sk_buff *skb)
> @@ -890,7 +893,7 @@ void ip6_route_input(struct sk_buff *skb)
>  static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
>  					     struct flowi6 *fl6, int flags)
>  {
> -	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
> +	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags, 1);

								      false);

>  }
>  
>  struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,

Thanks,

  Hannes
