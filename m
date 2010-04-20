From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 20 Apr 2010 19:57:27 +0200
Message-ID: <1271786247.7895.130.camel@edumazet-laptop>
References: <20100420174401.GB1334@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41557 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787Ab0DTR5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 13:57:35 -0400
Received: by bwz25 with SMTP id 25so7077554bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 10:57:33 -0700 (PDT)
In-Reply-To: <20100420174401.GB1334@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 19:44 +0200, Jiri Bohac a =C3=A9crit :
> Hi,
>=20
> I found what I believe is a race condition in __ipv6_ifa_notify(), in=
 the call
> to dst_free().
>=20
> __ipv6_ifa_notify() contains:
>=20
>         case RTM_DELADDR:
>                 if (ifp->idev->cnf.forwarding)
>                         addrconf_leave_anycast(ifp);
>                 addrconf_leave_solict(ifp->idev, &ifp->addr);
>                 dst_hold(&ifp->rt->u.dst);
>                 if (ip6_del_rt(ifp->rt))
>                         dst_free(&ifp->rt->u.dst);
>                 break;
>=20
> AFAICT, ip6_del_rt() will call dst_free() itself if it finds and actu=
ally
> deletes the route:=20
> 	ip6_del_rt() -> __ip6_del_rt() -> fib6_del() -> fib6_del_route() ->
> 	-> rt6_release() -> dst_free()
>=20
> If it fails (like when it races with another invocation of ip6_del_rt=
()), it
> will return nonzero and this will cause the above code to call dst_fr=
ee() on its own.
>=20
> dst_free() has no protection against concurrent invocation and if

Sorry ? of course dst_free() has a protection...

By definition, the dst_destroy() is called only by the last thread with
the final refcount on object.

> two invocations make it through the "if (dst->obsolete > 1)"
> check before one of them calls __dst_free(), the same dst_entry
> may end up either:
> 	1) dst_destroy()ed and put on the dst_garbage.list, or
> 	2) put on the dst_garbage.list twice
> both resulting in trouble once the GC is run.
>=20
> One possible code path leading to two invocations of __ipv6_ifa_notif=
y() seems
> to be when two bonding slaves receive a NS/NA with the bonds IPv6 add=
ress when
> the bonding master is in the DAD phase with a tentative address:
>=20
> netif_receive_skb() gets invoked on two CPUs and sets skb->dev to the=
 bonding master ...
> ... ip6_mc_input() -> ip6_input_finish() -> icmpv6_rcv() -> ndisc_rcv=
() ->
>  -> ndisc_recv_ns() -> addrconf_dad_failure() -> ipv6_del_addr() -> i=
pv6_ifa_notify() ->
>  -> __ipv6_ifa_notify
>=20
>=20
> What is the reason __ipv6_ifa_notify() calls dst_free() when
> ip6_del_rt() fails? I don't see a way ip6_del_rt() could fail
> with the dst still needing to be freed.
>=20
> I am just testing whether the following will help:
>=20
> --- a/net/ipv6/addrconf.c	2010-04-17 00:12:32.000000000 +0200
> +++ b/net/ipv6/addrconf.c	2010-04-20 19:07:35.000000000 +0200
> @@ -3974,8 +3974,7 @@ static void __ipv6_ifa_notify(int event,
>  			addrconf_leave_anycast(ifp);
>  		addrconf_leave_solict(ifp->idev, &ifp->addr);
>  		dst_hold(&ifp->rt->u.dst);
> -		if (ip6_del_rt(ifp->rt))
> -			dst_free(&ifp->rt->u.dst);
> +		ip6_del_rt(ifp->rt);
>  		break;
>  	}
>  }
>=20


I dont understand the problem Jiri.

We just did dst_hold(&ifp->rt->u.dst), so if ip6_del_rt() fails we must
dst_free(), or we leak a refcount.



