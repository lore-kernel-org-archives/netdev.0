From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] Failed neighbors attached to routes are not
 released
Date: Mon, 22 Aug 2011 18:44:15 +0200
Message-ID: <1314031455.2307.113.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAC67Hz-MpmPGX4c+DTCgXkfnKdinNCrc7xc9Q03=35t=LLnW+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Guy Yur <guyyur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62300 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab1HVQoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 12:44:14 -0400
Received: by wyg24 with SMTP id 24so3624504wyg.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 09:44:13 -0700 (PDT)
In-Reply-To: <CAC67Hz-MpmPGX4c+DTCgXkfnKdinNCrc7xc9Q03=35t=LLnW+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 ao=C3=BBt 2011 =C3=A0 21:53 +0300, Guy Yur a =C3=A9crit =
:
> Hi,
>=20
> The issue I am seeing is with a neighbor used as a gateway in a route=
,
> when the neighbor gets nud FAILED it will not be removed from the
> neighbor cache.
> The reference count for the neighbor remains > 1
> when neigh_periodic_work() is called.
>=20
> Issue noticed with IPv6 neighbors on Arch Linux with kernel 3.0.3
> kernel config includes CONFIG_IPV6_ROUTER_PREF
>=20
> The problem affects routing when the neighbor loses connectivity and =
returns.
>=20
> Scenario: Using a default route and a static route through different =
interfaces.
> When the neighbor gateway of the static route goes down the traffic
> will move to the default gateway as expected.
> Once the static route neighbor comes back up it is not asked for
> neighbor solicitation
> because the route is marked as FAILED and the traffic will continue t=
o
> pass through the default gateway.
>=20
> Steps to reproduce the route not being removed:
> 1. add an IPv6 address on an interface
> 2. add a route to a network through a gateway on the interface's netw=
ork
> 3. make sure the gateway address is not reachable
> 4. ping6 a host in the route network
> 5. "ip -6 nei" will show the gateway neighbor as FAILED and it won't =
be released
>=20
> Steps to reproduce the routing problem:
> 1. client and two gateway machines (A and B)
> 2. on the client define a static route through A and a default route =
through B
> 3. disconnect eth on A
> 4. ping6 a host in the network that should go through A
>    after a while the traffic will move through B which is the default=
 route
> 5. reconnect eth on A
> 6. ping6 a host in the network again, the traffic will still go throu=
gh B
>    "ip -6 nei" on the client will still show A as FAILED
>=20
>=20
> Patch to change the nud state to NONE if the reference count > 1
> allowing the neighbor to be released in a future pass.

I wonder why a 'future pass' is needed at all.

Shouldnt we immediately detect link becomes alive and force an immediat=
e
flush at this point, before waiting a garbage collect timer ?


>=20
> --- linux/net/core/neighbour.c.orig	2011-08-19 13:15:35.041524169 +03=
00
> +++ linux/net/core/neighbour.c	2011-08-19 18:19:07.271276096 +0300
> @@ -802,14 +802,16 @@ static void neigh_periodic_work(struct w
>  			if (time_before(n->used, n->confirmed))
>  				n->used =3D n->confirmed;
>=20
> -			if (atomic_read(&n->refcnt) =3D=3D 1 &&
> -			    (state =3D=3D NUD_FAILED ||
> +			if ((state =3D=3D NUD_FAILED ||
>  			     time_after(jiffies, n->used + n->parms->gc_staletime))) {
> -				*np =3D n->next;
> -				n->dead =3D 1;
> -				write_unlock(&n->lock);
> -				neigh_cleanup_and_release(n);
> -				continue;
> +				if (atomic_read(&n->refcnt) =3D=3D 1) {
> +					*np =3D n->next;
> +					n->dead =3D 1;
> +					write_unlock(&n->lock);
> +					neigh_cleanup_and_release(n);
> +					continue;
> +				} else
> +					n->nud_state =3D NUD_NONE;
>  			}
>  			write_unlock(&n->lock);
> --


