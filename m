From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] net: ipv6: fallback to full lookup if table lookup is unsuitable
Date: Fri, 16 Sep 2016 21:15:14 +0200
Message-ID: <m3twdfk665.fsf@neo.luffy.cx>
References: <20160916125531.3486-1-vincent@bernat.im>
        <adff2e07-75e1-d44c-4799-0920ffcd2622@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:46035 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756501AbcIPTPT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 15:15:19 -0400
In-Reply-To: <adff2e07-75e1-d44c-4799-0920ffcd2622@cumulusnetworks.com> (David
        Ahern's message of "Fri, 16 Sep 2016 12:36:04 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 16 septembre 2016 20:36 CEST, David Ahern <dsa@cumulusnetworks.c=
om>=C2=A0:

>> contained a non-connected route (like a default gateway) fails while it
>> was previously working:
>>=20
>>     $ ip link add eth0 type dummy
>>     $ ip link set up dev eth0
>>     $ ip addr add 2001:db8::1/64 dev eth0
>>     $ ip route add ::/0 via 2001:db8::5 dev eth0 table 20
>>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>>     RTNETLINK answers: No route to host
>>     $ ip -6 route show table 20
>>     default via 2001:db8::5 dev eth0  metric 1024  pref medium
>
> so your table 20 is not complete in that it lacks a connected route to
> resolve 2001:db8::6 as a nexthop, so you are relying on a fallback to
> other tables (main in this case).

Yes.

>> @@ -1991,33 +2015,15 @@ static struct rt6_info *ip6_route_info_create(st=
ruct fib6_config *cfg)
>>  			if (!(gwa_type & IPV6_ADDR_UNICAST))
>>  				goto out;
>>=20=20
>> +			err =3D -EHOSTUNREACH;
>>  			if (cfg->fc_table)
>>  				grt =3D ip6_nh_lookup_table(net, cfg, gw_addr);
>
> -----8<-----
>
>> -			if (!(grt->rt6i_flags & RTF_GATEWAY))
>> -				err =3D 0;
>
> This is the check that is failing for your use
> case. ip6_nh_lookup_table is returning the default route and nexthops
> can not rely on a gateway. Given that a simpler and more direct change
> is (whitespace mangled on paste):
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index ad4a7ff301fc..48bae2ee2e18 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1991,9 +1991,19 @@ static struct rt6_info *ip6_route_info_create(stru=
ct fib6_config *cfg)
>                         if (!(gwa_type & IPV6_ADDR_UNICAST))
>                                 goto out;
>
> -                       if (cfg->fc_table)
> +                       if (cfg->fc_table) {
>                                 grt =3D ip6_nh_lookup_table(net, cfg, gw_=
addr);
>
> +                               /* a nexthop lookup can not go through a =
gw.
> +                                * if this happens on a table based lookup
> +                                * then fallback to a full lookup
> +                                */
> +                               if (grt && grt->rt6i_flags & RTF_GATEWAY)=
 {
> +                                       ip6_rt_put(grt);
> +                                       grt =3D NULL;
> +                               }
> +                       }
> +
>                         if (!grt)
>                                 grt =3D rt6_lookup(net, gw_addr, NULL,
>                                                  cfg->fc_ifindex, 1);

OK. Should the dev check be dismissed or do we add "dev && dev !=3D
grt->dst.dev" just as a safety net (this would be a convulated setup,
but the correct direct route could be in an ip rule with higher priority
while the one in this table is incorrect)?
--=20
"... an experienced, industrious, ambitious, and often quite often
picturesque liar."
		-- Mark Twain
