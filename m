From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible DoS with 6RD border relay
Date: Wed, 04 Jan 2012 18:02:47 +0100
Message-ID: <1325696567.2428.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201201041048.44509.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brent Cook <bcook@breakingpoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38630 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481Ab2ADRCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 12:02:51 -0500
Received: by wgbdr13 with SMTP id dr13so29231954wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 09:02:50 -0800 (PST)
In-Reply-To: <201201041048.44509.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 janvier 2012 =C3=A0 10:48 -0600, Brent Cook a =C3=A9crit=
 :
> Hi All,
>=20
>   I have been doing some testing of Linux serving as a 6RD border rel=
ay. It=20
> seems that if a client sends 6RD-encapsulated packets and varies the =
lower 64-
> bits of the 6RD address over the range of the neighbor table size (th=
e bits=20
> below the delegated prefix), it causes the neighbor table to quickly =
overflow.=20
> However, viewing the neighbor table never shows more than a handful o=
f=20
> entries. When the neighbor table overflows, packet routing on my test=
 system=20
> slows from 1Gbps to a couple of Mbps at most.
>=20
> [28765.764079] net_ratelimit: 32003 callbacks suppressed
> [28765.764084] ipv6: Neighbour table overflow.
> [28765.764171] ipv6: Neighbour table overflow.
>=20
> root@target1:~# ip neigh
> fe80::1a:c5ff:fe02:2 dev test2  router FAILED
> 2001:1234::3 dev test2 lladdr 02:1a:c5:02:00:02 REACHABLE
> 192.168.2.1 dev mgmt0 lladdr 04:7d:7b:06:8d:2d REACHABLE
> 1.0.0.1 dev test0 lladdr 02:1a:c5:01:00:00 REACHABLE
>=20
> If I send packets much more slowly, the system works as expected. If =
the 6RD=20
> client sends from a constant address rather than varying the lower bi=
ts, it=20
> also works fine. I tested the two neighbor table checks in sit.c and=20
>=20
> The network topology looks something like this:
>=20
> 6RD client -> Router -> Linux (6RD BR) -> IPv6 host
>=20
> The 6RD client is at 1.1.1.1/24
> The Linux BR is at 1.0.0.2/24, the IPv4 router is at 1.0.0.1/24 and t=
he IPv6=20
> host is directly attached on a second physical interface at address=20
> 2001:1234::3
>=20
> A configuration script for configuring the BR follows:
>=20
> #!/bin/bash
> PREFIX1=3D"2001:0db8"                  # 6rd ipv6 prefix
> intf1=3Dtest0
> intf2=3Dtest2
>=20
> modprobe sit
>=20
> ## Setup the tunnel, it will create an interface named '6rd'
> ip addr add 1.0.0.2/24 dev $intf1
> ip link set $intf1 up
> sudo ip route add 1.1.1.0/24 via 1.0.0.1
> ip addr add 2001:1234::1/64 dev $intf2
> ip link set $intf2 up
> ip tunnel add 6rd mode sit local 1.0.0.2 dev $intf1 ttl 64
> ip tunnel 6rd dev 6rd 6rd-prefix ${PREFIX1}::/32
> ip addr add ${PREFIX1}::1/32 dev 6rd
> ip link set 6rd up
>=20
> sysctl -w net.ipv6.conf.all.forwarding=3D1

What kernel version do you use ?
