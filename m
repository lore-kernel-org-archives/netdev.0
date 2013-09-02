From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v3] ipv6:introduce function to find route for redirect
Date: Mon, 02 Sep 2013 10:38:20 +0800
Message-ID: <5223FA1C.5020501@cn.fujitsu.com>
References: <52217A8D.9010008@cn.fujitsu.com> <20130901210825.GD19455@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:3946 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757877Ab3IBCi7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 22:38:59 -0400
In-Reply-To: <20130901210825.GD19455@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8802=E6=97=A5 05:08, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Sat, Aug 31, 2013 at 01:09:33PM +0800, Duan Jiong wrote:
>> RFC 4861 says that the IP source address of the Redirect is the
>> same as the current first-hop router for the specified ICMP
>> Destination Address, so the gateway should be taken into
>> consideration when we find the route for redirect.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
> This patch looks good!
>=20
> Maybe you could also point to commit
> a6279458c534d01ccc39498aba61c93083ee0372 ("NDISC: Search over all pos=
sible
> rules on receipt of redirect.") and where the check went away?
>=20
> The bug is only "exploitable" on layer-2 because the source address o=
f the
> redirect is checked to be a valid link-local address but it makes spo=
ofing a
> lot easier in the same L2 domain nonetheless.
>=20
> Nice work!
>=20
> Some smaller comments inline:
>=20
Thanks very much for you comments=EF=BC=8C and i will correct those pro=
blems.
>> ---
>>  Changes for v3:
>>  1.Fix the comments style problems
>>
>>  net/ipv6/ah6.c     |  2 +-
>>  net/ipv6/esp6.c    |  2 +-
>>  net/ipv6/icmp.c    |  2 +-
>>  net/ipv6/ipcomp6.c |  2 +-
>>  net/ipv6/ndisc.c   |  3 ++-
>>  net/ipv6/route.c   | 78 +++++++++++++++++++++++++++++++++++++++++++=
++++++-----
>>  6 files changed, 78 insertions(+), 11 deletions(-)
>>
>> diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
>> index bb02e17..73784c3 100644
>> --- a/net/ipv6/ah6.c
>> +++ b/net/ipv6/ah6.c
>> @@ -628,7 +628,7 @@ static void ah6_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,
>>  		return;
>> =20
>>  	if (type =3D=3D NDISC_REDIRECT)
>> -		ip6_redirect(skb, net, 0, 0);
>> +		ip6_redirect(skb, net, skb->dev->ifindex, 0);
>>  	else
>>  		ip6_update_pmtu(skb, net, info, 0, 0);
>>  	xfrm_state_put(x);
>> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
>> index aeac0dc..d3618a7 100644
>> --- a/net/ipv6/esp6.c
>> +++ b/net/ipv6/esp6.c
>> @@ -447,7 +447,7 @@ static void esp6_err(struct sk_buff *skb, struct=
 inet6_skb_parm *opt,
>>  		return;
>> =20
>>  	if (type =3D=3D NDISC_REDIRECT)
>> -		ip6_redirect(skb, net, 0, 0);
>> +		ip6_redirect(skb, net, skb->dev->ifindex, 0);
>>  	else
>>  		ip6_update_pmtu(skb, net, info, 0, 0);
>>  	xfrm_state_put(x);
>> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
>> index 7cfc8d2..73681c2 100644
>> --- a/net/ipv6/icmp.c
>> +++ b/net/ipv6/icmp.c
>> @@ -92,7 +92,7 @@ static void icmpv6_err(struct sk_buff *skb, struct=
 inet6_skb_parm *opt,
>>  	if (type =3D=3D ICMPV6_PKT_TOOBIG)
>>  		ip6_update_pmtu(skb, net, info, 0, 0);
>>  	else if (type =3D=3D NDISC_REDIRECT)
>> -		ip6_redirect(skb, net, 0, 0);
>> +		ip6_redirect(skb, net, skb->dev->ifindex, 0);
>> =20
>>  	if (!(type & ICMPV6_INFOMSG_MASK))
>>  		if (icmp6->icmp6_type =3D=3D ICMPV6_ECHO_REQUEST)
>> diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
>> index 7af5aee..5636a91 100644
>> --- a/net/ipv6/ipcomp6.c
>> +++ b/net/ipv6/ipcomp6.c
>> @@ -76,7 +76,7 @@ static void ipcomp6_err(struct sk_buff *skb, struc=
t inet6_skb_parm *opt,
>>  		return;
>> =20
>>  	if (type =3D=3D NDISC_REDIRECT)
>> -		ip6_redirect(skb, net, 0, 0);
>> +		ip6_redirect(skb, net, skb->dev->ifindex, 0);
>>  	else
>>  		ip6_update_pmtu(skb, net, info, 0, 0);
>>  	xfrm_state_put(x);
>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index 04d31c2..90f474b 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -1370,7 +1370,8 @@ static void ndisc_redirect_rcv(struct sk_buff =
*skb)
>>  		return;
>> =20
>>  	if (!ndopts.nd_opts_rh) {
>> -		ip6_redirect_no_header(skb, dev_net(skb->dev), 0, 0);
>> +		ip6_redirect_no_header(skb, dev_net(skb->dev),
>> +							skb->dev->ifindex, 0);
>=20
> This is not indented correctly. skb->dev->ifindex should be placed ri=
ght below
> the upper skb variable.
>=20
>>  		return;
>>  	}
>> =20
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 8d9a93e..2e1d378 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1157,6 +1157,74 @@ void ip6_sk_update_pmtu(struct sk_buff *skb, =
struct sock *sk, __be32 mtu)
>>  }
>>  EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
>> =20
>> +/* Handle redirects */
>> +struct ip6rd_flowi {
>> +	struct flowi6 fl6;
>> +	struct in6_addr gateway;
>> +};
>> +
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
>=20
> [1] (backreference for a comment below)
>=20
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
>> +
>> +static struct dst_entry *ip6_route_redirect(const struct flowi6 *fl=
6,
>> +					   const struct in6_addr *gateway,
>> +					   struct net *net)
>=20
> The ordering of the arguments could be in the same style as the other
> ip6_route_* functions (net, flow, gateway). But that is not that impo=
rtant.
>=20
>> +{
>> +	int flags =3D RT6_LOOKUP_F_HAS_SADDR;
>> +	struct ip6rd_flowi rdfl;
>> +
>> +	rdfl.fl6 =3D *fl6;
>> +	rdfl.gateway =3D *gateway;
>> +
>> +	if (rt6_need_strict(&fl6->daddr))
>> +		flags |=3D RT6_LOOKUP_F_IFACE;
>=20
> This is not needed because you do the matching on interfaces yourself
> in __ip6_route_redirect. The flag should currently not be checked on
> this code path down in fib6_rule_lookup.
>=20
>> +
>> +	return fib6_rule_lookup(net, &rdfl.fl6,
>> +						   flags, __ip6_route_redirect);
>=20
> This line jumped a bit too far to the right, too. ;)
>=20
>> +}
>> +
>>  void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u3=
2 mark)
>=20
> Maybe we should rename oif to iif now?
Yes, that looks no ambiguity.
>=20
>>  {
>>  	const struct ipv6hdr *iph =3D (struct ipv6hdr *) skb->data;
>> @@ -1171,9 +1239,8 @@ void ip6_redirect(struct sk_buff *skb, struct =
net *net, int oif, u32 mark)
>>  	fl6.saddr =3D iph->saddr;
>>  	fl6.flowlabel =3D ip6_flowinfo(iph);
>> =20
>> -	dst =3D ip6_route_output(net, NULL, &fl6);
>> -	if (!dst->error)
>> -		rt6_do_redirect(dst, NULL, skb);
>> +	dst =3D ip6_route_redirect(&fl6, &ipv6_hdr(skb)->saddr, net);
>> +	rt6_do_redirect(dst, NULL, skb);
>=20
> What is the reason you left out the dst.error check? E.g. if a system=
 had a
> prohbit rule it is possible to circumvent this with a redirect packet=
 now.
>=20
That's my fault. i just understand the meaning of dst.error incorrectly=
, and
i will modify the patch according to your comment below.
> I would think about placing this check at [1] and fail the lookup
> early. rt6_do_redirect does check for null-entry, so you could omit t=
he
> check here, then.
>=20

Thanks,
  Duan
