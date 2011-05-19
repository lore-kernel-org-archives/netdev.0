From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug, kernel panic, NULL dereference , cleanup_once /
 icmp_route_lookup.clone.19.clone / nat , 2.6.39-rc7-git11
Date: Thu, 19 May 2011 08:30:23 +0200
Message-ID: <1305786623.3019.10.camel@edumazet-laptop>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
	 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
	 <1305711471.2983.27.camel@edumazet-laptop>
	 <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
	 <1305713111.2991.1.camel@edumazet-laptop>
	 <1305719047.2991.4.camel@edumazet-laptop>
	 <4ae96506c000a4b3c8f78ccef836deaf@visp.net.lb>
	 <1305733944.2991.45.camel@edumazet-laptop>
	 <1305746989.3019.0.camel@edumazet-laptop>
	 <1305782397.3019.5.camel@edumazet-laptop>
	 <626ba8ae63cfc8fdb68c7f281463dc27@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64678 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932499Ab1ESGa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 02:30:27 -0400
Received: by wya21 with SMTP id 21so1719199wya.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 23:30:26 -0700 (PDT)
In-Reply-To: <626ba8ae63cfc8fdb68c7f281463dc27@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 09:11 +0300, Denys Fedoryshchenko a =C3=A9c=
rit :
> On Thu, 19 May 2011 07:19:57 +0200, Eric Dumazet wrote:
> > Le mercredi 18 mai 2011 =C3=A0 21:29 +0200, Eric Dumazet a =C3=A9cr=
it :
> >> Le mercredi 18 mai 2011 =C3=A0 17:52 +0200, Eric Dumazet a =C3=A9c=
rit :
> >>
> >> > Hmm, it seems we have some inetpeer refcount leak somewhere.
> >> >
> >> > Maybe one (struct rtable)->peer is not released on dst/rtable=20
> >> removal,
> >> > or we also leak dst/rtable (and their ->peer inetpeer)
> >> >
> >> > Watch :
> >> >
> >> > grep peer /proc/slabinfo
> >> > grep dst /proc/slabinfo
> >> >
> >>
> >> FYI, I started a bisection to find the faulty commit.
> >>
> >
> > Oh well, of course this came to 2c8cec5c10bced240
> > (ipv4: Cache learned PMTU information in inetpeer.)
> >
> > So my method to check if we have a leak might be wrong, since the=20
> > above
> > commit let cache full of garbage, and hope that following lookups=20
> > will
> > find and evict obsolete dst.
> >
> > Thats getting difficult :(
> >
> > Could you please send us
> >
> > grep . /proc/sys/net/ipv4/route/*
> >
> > Thanks !
>  NewNet-PPPoE ~ # grep . /proc/sys/net/ipv4/route/*
>  /proc/sys/net/ipv4/route/error_burst:5000
>  /proc/sys/net/ipv4/route/error_cost:1000
>  grep: /proc/sys/net/ipv4/route/flush: Permission denied
>  /proc/sys/net/ipv4/route/gc_elasticity:8
>  /proc/sys/net/ipv4/route/gc_interval:60
>  /proc/sys/net/ipv4/route/gc_min_interval:0
>  /proc/sys/net/ipv4/route/gc_min_interval_ms:500
>  /proc/sys/net/ipv4/route/gc_thresh:32768
>  /proc/sys/net/ipv4/route/gc_timeout:300
>  /proc/sys/net/ipv4/route/max_size:524288
>  /proc/sys/net/ipv4/route/min_adv_mss:256
>  /proc/sys/net/ipv4/route/min_pmtu:552
>  /proc/sys/net/ipv4/route/mtu_expires:600
>  /proc/sys/net/ipv4/route/redirect_load:20
>  /proc/sys/net/ipv4/route/redirect_number:9
>  /proc/sys/net/ipv4/route/redirect_silence:20480
>=20
>  I think it is default one.
>=20
>  PMTU is very actual for that, as it is pppoe, and up to 2k interface=
s=20
>  terminated there.
>=20

Yes, and every time an interface is added -> new route added, route
cache is invalidated (we change rt_genid)

>  I don't know, if it matters, but
>  iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS=20
>  --clamp-mss-to-pmtu
>  also there.
>=20
>  I can generate and put "ip route ls cache" and any other info.
>=20

Hmm would you please send :

rtstat -c10 -i1



