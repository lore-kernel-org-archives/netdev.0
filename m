From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v4] ipv6:introduce function to find route for redirect
Date: Tue, 03 Sep 2013 13:37:19 +0800
Message-ID: <5225758F.8080604@cn.fujitsu.com>
References: <52242CE1.5050501@cn.fujitsu.com> <20130902195056.GA5451@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:6176 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759354Ab3ICFh6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 01:37:58 -0400
In-Reply-To: <20130902195056.GA5451@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8803=E6=97=A5 03:50, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Mon, Sep 02, 2013 at 02:14:57PM +0800, Duan Jiong wrote:
>> +static struct rt6_info *__ip6_route_redirect(struct net *net,
>> +					     struct fib6_table *table,
>> +					     struct flowi6 *fl6,
>> +					     int flags)
>> +{
>> +	struct ip6rd_flowi *rdfl =3D (struct ip6rd_flowi *)fl6;
>> +	struct rt6_info *rt;
>> +	struct fib6_node *fn;
>> +
>> +	/* Get the "current" route for this destination and
>> +	 * check if the redirect has come from approriate router.
>> +	 *
>> +	 * RFC 4861 specifies that redirects should only be
>> +	 * accepted if they come from the nexthop to the target.
>> +	 * Due to the way the routes are chosen, this notion
>> +	 * is a bit fuzzy and one might need to check all possible
>> +	 * routes.
>> +	 */
>> +
>> +	read_lock_bh(&table->tb6_lock);
>> +	fn =3D fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
>> +restart:
>> +	for (rt =3D fn->leaf; rt; rt =3D rt->dst.rt6_next) {
>> +		if (rt6_check_expired(rt))
>> +			continue;
>> +		if (rt->dst.error)
>> +			continue;
>=20
> Sorry, I should have been more clear what I meant with failing early:
>=20
> I considered a setup like this:
>=20
> ip -6 r a default nexthop via fe80::1 dev eth0
> ip -6 r a prohibit 2002:1::/64
>=20
> If the kernel receives a redirect for a destination e.g. 2002:1::1 we
> would backtrack above the prohibit rule and return the dst of the def=
ault
> route and would insert a new cached route which could circumvent the
> prohibit rule. We have to try to lock down the tree below 2002:1::/64
> in that case. A possible solution for that would be to do something
> like this:
>=20
> 	/* We don't accept a redirect in case a more specific route is
> 	 * installed with dst.error and stop backtracking.
> 	 */
> 	if (rt->dst.error)
> 		break;
>=20
> Either we have to replace the rt with net->ipv6.ip6_null_entry in tha=
t
> case or check dst->error before calling rt6_do_redirect below.
>

Thanks for you comment, i understand what you mean.
=20
>> +		if (!(rt->rt6i_flags & RTF_GATEWAY))
>> +			continue;
>> +		if (fl6->flowi6_oif !=3D rt->dst.dev->ifindex)
>> +			continue;
>> +		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
>> +			continue;
>> +		break;
>> +	}
>> +
>> +	if (!rt)
>> +		rt =3D net->ipv6.ip6_null_entry;
>> +	BACKTRACK(net, &fl6->saddr);
>> +out:
>> +	dst_hold(&rt->dst);
>> +
>> +	read_unlock_bh(&table->tb6_lock);
>> +
>> +	return rt;
>> +};
>>
>> [...]
>>
>> @@ -1171,9 +1238,8 @@ void ip6_redirect(struct sk_buff *skb, struct =
net *net, int oif, u32 mark)
>>  	fl6.saddr =3D iph->saddr;
>>  	fl6.flowlabel =3D ip6_flowinfo(iph);
>> =20
>> -	dst =3D ip6_route_output(net, NULL, &fl6);
>> -	if (!dst->error)
>> -		rt6_do_redirect(dst, NULL, skb);
>> +	dst =3D ip6_route_redirect(net, &fl6, &ipv6_hdr(skb)->saddr);
>> +	rt6_do_redirect(dst, NULL, skb);
>>  	dst_release(dst);
>>  }
>>  EXPORT_SYMBOL_GPL(ip6_redirect);
>> @@ -1193,9 +1259,8 @@ void ip6_redirect_no_header(struct sk_buff *sk=
b, struct net *net, int oif,
>>  	fl6.daddr =3D msg->dest;
>>  	fl6.saddr =3D iph->daddr;
>> =20
>> -	dst =3D ip6_route_output(net, NULL, &fl6);
>> -	if (!dst->error)
>> -		rt6_do_redirect(dst, NULL, skb);
>> +	dst =3D ip6_route_redirect(net, &fl6, &iph->saddr);
>> +	rt6_do_redirect(dst, NULL, skb);
>>  	dst_release(dst);
>>  }
>=20
> Btw. I still think it should be possible to eliminate
> ip6_redirect_no_header:
>=20
> We could always use ip6_redirect_no_header and use the data of the re=
directed
> header option just for finding the socket to be notified. We can do t=
he whole
> verification and route updating in ndisc layer and then just call int=
o icmpv6
> layer if upper protocols need a notification of the redirect. But tha=
t should
> go into another patch. ;)
>=20

I think this is good, but i have a question below:

  if the socket type is connection-based, the dst information is stored=
 in related
sock struct, so there is no need to look up the route for redirect in i=
p6_redirect
or ip6_redirect_no_header, in this case, we do the verification and rou=
te=20
updating in the upper protocols' err_handler is better.=20

How do you think of this?

Thanks,
  Duan
