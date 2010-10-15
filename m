From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip6_tunnel. mtu/pmtu problems.
Date: Fri, 15 Oct 2010 15:09:11 +0200
Message-ID: <1287148151.2647.4.camel@edumazet-laptop>
References: <1287146439.27134.491.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Anders Franzen <Anders.Franzen@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59932 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab0JONJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 09:09:16 -0400
Received: by wyb28 with SMTP id 28so622539wyb.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 06:09:15 -0700 (PDT)
In-Reply-To: <1287146439.27134.491.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 15 octobre 2010 =C3=A0 14:40 +0200, Anders Franzen a =C3=A9=
crit :
> Hi, I've noticed that the ip6_tunnel driver completly ignore to updat=
e
> the route when a ''bearer'' has a lower mtu then whats expected by th=
e
> tunnel device.
>=20
> Comparing to the ipip tunnel I found that ip6_tunnel is missing the
> following line in the ip6_tnl_dev_setup:
>    dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE
>=20

Good catch :)

> Since it's not there, all code that are dependent on an skb_dst(skb)
> returning something, can be removed.
>  this is update_pmtu and icmp_send.
>=20
> Any how adding the flag to tell the device layer not to release skb->=
dst
> at dev_hard_start_xmit, made things better.
>=20
> But encap limit is on by default and it consumes 8 bytes, so true mtu
> for an ip6_tunnel over a 1500 bytes ethernet shall be 1452 not 1460.
>=20
> Is it is now I loose the first packet everytime a new route is create=
d.
>=20
> I updated the driver to take encap_limit into account, if enabled, no=
w
> it works even better.
>=20
> But I have one problem left, and I can reproduce it on the ipv4 ipip
> tunnel aswell.
>=20
> With a bit asymmetric routing setup, I can get the driver to generate=
 an
> icmp FRAG_NEEDED. If i configure the routing in such a way that the
> forwarding towards the src of the oversized packet, is via the tunnel=
=2E
>=20
> This happends:
>=20
> Dead loop on virtual device vip4, fix it urgently!
>=20
> It is because the dev layer has taken a lock on the tx queue for the
> device selected for the primary packet (the tunnel), and the tunnel
> wants to send an icmp, also on the same device, the lock is held for
> transmission of the primary packet, and the icmp gets discarded, with=
 a
> nasty kernel msg.
>=20
> I think this case is a valid case, and the Dead loop is just an
> implementation limitation.
>=20
> Maybe we should try to schedule the icmp do delay it until the primar=
y
> packet sending has returned and released the lock.
>=20
>=20
>=20
> This is the routing setup I use to trigger the Dead loop, both on ipi=
p
> tunnels and ip6_tunnels.
>=20
>=20
>      =20
>  We have 4 nodes A,B,C,D
>=20
>=20
>  C is a router, routing AB to/from D
>=20
>  B has a tunnel toward C
>  B has a default route using the tunnel to C
>=20
>  A has a route to D pointing to B
>=20
>  I raise the MTU of the tunnel endpoint at B by a couple of bytes, to
> simulate the encap_limit 8 bytes effect when left out. Or actually
> having a bearer device indicate a lower mtu than was expected.
>=20
> let A ping -M do -s 1470 D
>=20
> A sends to B, B forwards to tunnel, which will calculate it's mtu to
> 1480 (ipv4) based on its own overhead and the route mtu of the bearer
> route. Since we set the MTU of the tunnel higher than that, the tunne=
l
> will send an icmp back to A, but the route here says that you reach A
> via the tunnel it self, and Dead loop......
>=20
>=20
> If the lock in the device layer shall be there, then I think the icmp
> should be run from a kthread or something?

If the only thing blocking you is the dead loop, please try following
patch from net-next-2.6, currently a candidate for net-2.6

commit 745e20f1b626b1be4b100af5d4bf7b3439392f8f
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Sep 29 13:23:09 2010 -0700

    net: add a recursion limit in xmit path
   =20
    As tunnel devices are going to be lockless, we need to make sure a
    misconfigured machine wont enter an infinite loop.
   =20
    Add a percpu variable, and limit to three the number of stacked xmi=
ts.
   =20
    Reported-by: Jesse Gross <jesse@nicira.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3D745e20f1b626b1be4b100af5d4bf7b3439392f8f



