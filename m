From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Fri, 30 Dec 2011 02:18:46 +0100
Message-ID: <CACPM=kUy6RfHe48LRp-mcLHRia31g+DoJHXQFuk3tTBQnE1m7A@mail.gmail.com>
References: <20111229.170514.1766899380937848638.davem@davemloft.net>
	<CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com>
	<CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com>
	<20111229.184842.664528940770120593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111229.184842.664528940770120593.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/30 David Miller <davem@davemloft.net>:
> From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
> Date: Fri, 30 Dec 2011 00:37:17 +0100
>
>> Hmm, it seems like this problem isn't related to the driver, but
>> related to the current HEAD of net-next :)
>
> Please try this patch.
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 30de9e7..4a62c47 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -129,11 +129,14 @@ static struct neighbour *ip6_neigh_lookup(const=
 struct dst_entry *dst, const voi
> =A0 =A0 =A0 =A0return neigh_create(&nd_tbl, daddr, dst->dev);
> =A0}
>
> -static int rt6_bind_neighbour(struct rt6_info *rt)
> +static int rt6_bind_neighbour(struct rt6_info *rt, struct net_device=
 *dev)
> =A0{
> - =A0 =A0 =A0 struct neighbour *n =3D ip6_neigh_lookup(&rt->dst, &rt-=
>rt6i_gateway);
> - =A0 =A0 =A0 if (IS_ERR(n))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(n);
> + =A0 =A0 =A0 struct neighbour *n =3D __ipv6_neigh_lookup(&nd_tbl, de=
v, &rt->rt6i_gateway);
> + =A0 =A0 =A0 if (!n) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D neigh_create(&nd_tbl, &rt->rt6i_g=
ateway, dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(n))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(n);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0dst_set_neighbour(&rt->dst, n);
>
> =A0 =A0 =A0 =A0return 0;
> @@ -746,7 +749,7 @@ static struct rt6_info *rt6_alloc_cow(const struc=
t rt6_info *ort,
> =A0#endif
>
> =A0 =A0 =A0 =A0retry:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rt6_bind_neighbour(rt)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rt6_bind_neighbour(rt, rt->dst.dev)=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct net *net =3D de=
v_net(rt->dst.dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int saved_rt_min_inter=
val =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0net->i=
pv6.sysctl.ip6_rt_gc_min_interval;
> @@ -1397,7 +1400,7 @@ int ip6_route_add(struct fib6_config *cfg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rt->rt6i_prefsrc.plen =3D 0;
>
> =A0 =A0 =A0 =A0if (cfg->fc_flags & (RTF_GATEWAY | RTF_NONEXTHOP)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D rt6_bind_neighbour(rt);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D rt6_bind_neighbour(rt, dev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
> @@ -2084,7 +2087,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet=
6_dev *idev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rt->rt6i_flags |=3D RTF_ANYCAST;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rt->rt6i_flags |=3D RTF_LOCAL;
> - =A0 =A0 =A0 err =3D rt6_bind_neighbour(rt);
> + =A0 =A0 =A0 err =3D rt6_bind_neighbour(rt, rt->dst.dev);
> =A0 =A0 =A0 =A0if (err) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dst_free(&rt->dst);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(err);

Hey David,

That patch works, now it boots fine :)
I tried the driver on the 3.1.6 kernel to make sure nothing not tested
is causing problems.

/Bjarke

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
