From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 2.6.39 eats multicast packets
Date: Sat, 18 Jun 2011 12:25:24 +0200
Message-ID: <1308392724.3539.48.camel@edumazet-laptop>
References: <op.vw7on9im1qh6di@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Knut Tidemann <knut.andre.tidemann@jotron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60620 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab1FRKZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 06:25:30 -0400
Received: by wwe5 with SMTP id 5so1166458wwe.1
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2011 03:25:29 -0700 (PDT)
In-Reply-To: <op.vw7on9im1qh6di@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 juin 2011 =C3=A0 10:32 +0200, Knut Tidemann a =C3=A9crit=
 :
> Hello.
>=20
> We're seeing an issue where a listening UDP socket in a multicast gro=
up =20
> doesn't receive some multicast packets.
>  From simple testing it seems that the first packet from a new host i=
s not =20
> passed through the kernel and down to the socket, but the next packet=
s =20
> are. The packets can be
> seen with a tool such as tcpdump, but they never reach the user space=
 =20
> socket. It is worth noting, that the packet loss does not occur when =
=20
> sending to and from the same host,
> to a multicast address. The address and port we have been using in ou=
r =20
> tests are 224.0.1.75:5060. I've also attached the testing code at the=
 end =20
> of this email. The issue was also present in 3.0-rc1.
>=20
> This issue is not present in 2.6.38 and I've bisected the issue to th=
e =20
> following commit:
>=20
> ----
> b23dd4fe42b455af5c6e20966b7d6959fa8352ea is the first bad commit
> commit b23dd4fe42b455af5c6e20966b7d6959fa8352ea
> Author: David S. Miller <davem@davemloft.net>
> Date:   Wed Mar 2 14:31:35 2011 -0800
>=20
>      ipv4: Make output route lookup return rtable directly.
>=20
>      Instead of on the stack.
>=20
>      Signed-off-by: David S. Miller <davem@davemloft.net>
> ----
>=20

Knut, this is awesome, your bug report is perfect and was really helpfu=
l
to let me fix the bug in maybe 15 minutes, including reboot and tests ;=
)

Many thanks !

[PATCH] ipv4: fix multicast losses

Knut Tidemann found that first packet of a multicast flow was not
correctly received, and bisected the regression to commit b23dd4fe42b4
(Make output route lookup return rtable directly.)

Special thanks to Knut, who provided a very nice bug report, including
sample programs to demonstrate the bug.

Reported-and-bisectedby: Knut Tidemann <knut.andre.tidemann@jotron.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 045f0ec..aa13ef1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1902,9 +1902,7 @@ static int ip_route_input_mc(struct sk_buff *skb,=
 __be32 daddr, __be32 saddr,
=20
 	hash =3D rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
 	rth =3D rt_intern_hash(hash, rth, skb, dev->ifindex);
-	err =3D 0;
-	if (IS_ERR(rth))
-		err =3D PTR_ERR(rth);
+	return IS_ERR(rth) ? PTR_ERR(rth) : 0;
=20
 e_nobufs:
 	return -ENOBUFS;


