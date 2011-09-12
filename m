From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Incorrect routing to lo in spite of correct record in routing
 table
Date: Mon, 12 Sep 2011 20:47:51 +0200
Message-ID: <1315853271.2556.9.camel@edumazet-laptop>
References: <CAEmTpZGKnU4z4J43XGa-1YZ0WW6rnKdpTRJDFEeUTfVmZQH84g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41872 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093Ab1ILSr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 14:47:56 -0400
Received: by wwf22 with SMTP id 22so1782311wwf.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 11:47:55 -0700 (PDT)
In-Reply-To: <CAEmTpZGKnU4z4J43XGa-1YZ0WW6rnKdpTRJDFEeUTfVmZQH84g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 septembre 2011 =C3=A0 23:14 +0600, =D0=9C=D0=B0=D1=80=D0=BA=
 =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
> Suppose this (note netowrk masks):
>=20
> [mmarkk@mmarkk-devel ~]# uname -a
> Linux mmarkk-devel 2.6.32-71.el6.x86_64 #1 SMP Wed Sep 1 01:33:01 EDT
> 2010 x86_64 x86_64 x86_64 GNU/Linux
>=20
> [mmarkk@mmarkk-devel ~]# ip addr
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>     inet 127.0.0.1/32 scope host lo
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP qlen 1000
>     inet 10.80.20.21/16 brd 10.80.255.255 scope global eth0
> 3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN
>     inet 127.0.0.2/32 scope host dummy0
>=20
> [mmarkk@mmarkk-devel ~]# ip route show
> 10.80.0.0/16 dev eth0  proto kernel  scope link  src 10.80.20.21
> unreachable 127.0.0.0/8 <---------------------- has been added by han=
d
> default via 10.80.90.40 dev eth0
>=20
> [mmarkk@mmarkk-devel ~]# ip route show table local
> broadcast 10.80.0.0 dev eth0  proto kernel  scope link  src 10.80.20.=
21
> local 10.80.20.21 dev eth0  proto kernel  scope host  src 10.80.20.21
> local 127.0.0.2 dev dummy0  proto kernel  scope host  src 127.0.0.2
> broadcast 10.80.255.255 dev eth0  proto kernel  scope link  src 10.80=
=2E20.21
> local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1
>=20
> [mmarkk@mmarkk-devel ~]# ip route flush cache
>=20
> [mmarkk@mmarkk-devel ~]# ip route get 127.0.0.3
> RTNETLINK answers: Network is unreachable <------------ good, that is=
 OK
>=20
> [mmarkk@mmarkk-devel ~]# ip route get 127.0.0.1
> local 127.0.0.1 dev lo  src 127.0.0.1  <--------- Good, that's OK too
>     cache <local>  mtu 16436 advmss 16396 hoplimit 64
>=20
> [mmarkk@mmarkk-devel ~]# ip route get 127.0.0.2
> local 127.0.0.2 dev lo  src 127.0.0.2 <------------ HAY! this is not =
I
> want. Why device is "lo" (instead of dummy0) ?!
>     cache <local>  mtu 16436 advmss 16396 hoplimit 64
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
> The problem is that I want to do DNAT to localhost. I know, why DNAT
> to 127.0.0.1 (to interface "lo") does not work. I decide to do that
> using interface dummy0. It works as expected if I choose any address
> not in 127.0.0.0/8.
>=20
> RFC 3330 said:
> -------------
> A datagram sent by a higher level protocol to an  address anywhere
> within this block should loop back inside the host. This is ordinaril=
y
> implemented using only 127.0.0.1/32 for loopback, but no addresses
> within this block should ever appear on any network anywhere
> -------------
> So, my question: Why the kernel routes 127.0.0.2 to lo (instead of du=
mmy0) ?
>=20
> Well, If kernel is so smart to route any 127.0.0.0/8 to "lo", why it
> routes 127.0.0.3 to default gateway if I remove "unreachable
> 127.0.0.0/8" ?!
>=20

Because you have 127.0.0.1/32 on lo, not 127.0.0.1/8

> I think there is some bug in kernel. What are you thinking about?
>=20

I have no idea why you think there is a bug.

127.0.0.2 (dummy0) is a local address like 10.80.20.21 (eth0)

When you ping 10.80.20.21, the frame goes through loopback, not eth0.

# ip ro get 10.80.20.21
local 10.80.20.21 dev lo  src 10.80.20.21=20
    cache <local>=20

BTW, if you 'ifconfig lo down', ping to 10.80.20.21 doesnt work.
