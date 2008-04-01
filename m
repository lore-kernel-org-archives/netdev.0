From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/6] IPV4 : use xor rather than multiple ands for route
 compare
Date: Tue, 01 Apr 2008 07:52:03 +0200
Message-ID: <47F1CD83.8090905@cosmosbay.com>
References: <20080401004708.009204033@vyatta.com> <20080401004724.601457403@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003av.neufgp.fr ([84.96.92.124]:57972 "EHLO
	neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751274AbYDAFwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 01:52:20 -0400
In-Reply-To: <20080401004724.601457403@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> The comparison in ip_route_input is a hot path, by recoding the C
> "and" as bit operations, fewer conditional branches get generated
> so the code should be faster. Maybe someday Gcc will be smart
> enough to do this?
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/ipv4/route.c	2008-03-31 10:57:30.000000000 -0700
> +++ b/net/ipv4/route.c	2008-03-31 11:10:44.000000000 -0700
> @@ -2079,14 +2079,14 @@ int ip_route_input(struct sk_buff *skb,=20
>  	rcu_read_lock();
>  	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
>  	     rth =3D rcu_dereference(rth->u.dst.rt_next)) {
> -		if (rth->fl.fl4_dst =3D=3D daddr &&
> -		    rth->fl.fl4_src =3D=3D saddr &&
> -		    rth->fl.iif =3D=3D iif &&
> -		    rth->fl.oif =3D=3D 0 &&
> -		    rth->fl.mark =3D=3D skb->mark &&
> -		    rth->fl.fl4_tos =3D=3D tos &&
> -		    net_eq(dev_net(rth->u.dst.dev), net) &&
> -		    rth->rt_genid =3D=3D atomic_read(&rt_genid)) {
> +		if (((rth->fl.fl4_dst ^ daddr) |
> +		     (rth->fl.fl4_src ^ saddr) |
> +		     (rth->fl.iif ^ iif) |
> +		     rth->fl.oif |
> +		     (rth->fl.mark ^ skb->mark) |
> +		     (rth->fl.fl4_tos ^ tos) |
> +		     (rth->rt_genid ^ atomic_read(&rt_genid))) =3D=3D 0 &&
> +		    net_eq(dev_net(rth->u.dst.dev), net)) {
>  			dst_use(&rth->u.dst, jiffies);
>  			RT_CACHE_STAT_INC(in_hit);
>  			rcu_read_unlock();
>=20

Are you sure all fields share same cache lines, on 32bit and 64bit arch=
es ?

I prefer having some conditional branches instead of cache misses, give=
n that=20
the first two branches are usually discriminant.

Maybe we could let one test on (daddr,saddr) to do a fast segregation (=
with=20
one cache line at most) of candidates, then one remaining compare on ot=
her keys ?

