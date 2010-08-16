From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Mon, 16 Aug 2010 12:19:20 +0200
Message-ID: <1281953960.2524.23.camel@edumazet-laptop>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 ao=C3=BBt 2010 =C3=A0 19:55 +0200, Thomas Habets a =C3=A9=
crit :
> (originally sent to netdev on aug 6th)
>=20

CC netdev again

> IPv6 initially works, but when I leave it alone overnight I'm unable =
to ping=20
> even my default gw.
>=20
> Static global IPv6 addresses configured on both ends. No access lists=
 on either=20
> end.
>=20
> Kernel version: 2.6.35 mainline (amd64) and 2.6.33.6.
> Kernel config: http://pastebin.com/raw.php?i=3DY6S8iKW7
> Dist: Debian Lenny (5.0.5), nothing special to my knowledge.
>=20
> I seem to have the same issue that Mikael Abrahamsson encountered wit=
h Ubuntu=20
> kernels 2.6.26.3, 2.6.26-5-generic and 2.6.27-2-generic, and mainline=
 kernels=20
> 2.6.25, 2.6.26 and 2.6.27:
>    https://bugs.launchpad.net/ubuntu/+source/linux/+bug/263260
>=20
> He got IPv6 running again without rebooting using "networking stop, i=
fconfig=20
> eth0 down, networking start, kill dhclient", while I narrowed it down=
 to just=20
> deleting the ipv6 neighbor (ip ne del..., see below). Rebooting also =
causes it=20
> to start working again.
>=20
> It's very reproducible. I just leave it overnight and it breaks every=
 time.
>=20
> I am willing and able to try patches at any time, the box is not in p=
roduction.
>=20
> No iptables, no ip6tables. IP6tables support is not even compiled in.
>=20
> NIC is "Broadcom Corporation NetXtreme BCM5715 Gigabit ethernet (rev =
a3)"
> according to lspci.
>=20
> Other end is a directly connected Cisco 7600 (routed port) that I hav=
e access=20
> to, but it's in production use. IPv4 works perfectly over this same p=
ort. Only=20
> lo and eth0 are UP.
>=20
>=20
> Output when broken
> ------------------
> $ uname -a
> Linux XXXXX 2.6.35 #1 SMP Tue Aug 3 09:25:51 CEST 2010 x86_64
> GNU/Linux
>=20
> $ ip -6 a sh
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
>      inet6 2a00:800:1000:64::1/128 scope global
>         valid_lft forever preferred_lft forever
>      inet6 ::1/128 scope host
>         valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>      inet6 2a00:800:752:1::5c:2/112 scope global
>         valid_lft forever preferred_lft forever
>      inet6 fe80::224:81ff:fea3:4424/64 scope link
>         valid_lft forever preferred_lft forever
>=20
> (I have tried removing 2a00:800:1000:64::1/128 from lo, same issue)
>=20
> $ ip -6 r sh
> 2a00:800:752:1::5c:0/112 dev eth0  proto kernel  metric 256  mtu 1500
> advmss 14 hoplimit 4294967295 unreachable

advmss 14 ? or is it a copy/paste error ?
unreachable ?

This route seems wrong.

> 2a00:800:1000:64::1 dev lo proto kernel  metric 256  error -101 mtu 1=
6436=20
> advmss 16376 hoplimit 4294967295
> fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
> hoplimit 4294967295
> default via 2a00:800:752:1::5c:1 dev eth0  metric 1024  mtu 1500 advm=
ss 1440=20
> hoplimit 4294967295
>=20
> $ ping6 2a00:800:752:1::5c:1
> PING 2a00:800:752:1::5c:1(2a00:800:752:1::5c:1) 56 data bytes
> ^C
> --- 2a00:800:752:1::5c:1 ping statistics ---
> 22 packets transmitted, 0 received, 100% packet loss, time 21006ms
>=20
>=20
> # Tcpdpump on the problem machine shows mostly the pings, but also pe=
riodically=20
> some ND:
>=20
> [...]
> 12:54:02.683672 00:24:81:a3:44:24 > 00:22:55:17:4b:80, ethertype IPv6
> (0x86dd), length 118: 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: IC=
MP6, echo=20
> request, seq 12, length 64

> 12:54:02.693669 00:24:81:a3:44:24 > 00:22:55:17:4b:80, ethertype IPv6
> (0x86dd), length 86: fe80::224:81ff:fea3:4424 > 2a00:800:752:1::5c:1:=
 ICMP6,=20
> neighbor solicitation, who has 2a00:800:752:1::5c:1, length 32

Sollicitation comes from fe80::224:81ff:fea3:4424 instead of
2a00:800:752:1::5c:2

> 12:54:02.693832 00:22:55:17:4b:80 > 00:24:81:a3:44:24, ethertype IPv6
> (0x86dd), length 78: 2a00:800:752:1::5c:1 > fe80::224:81ff:fea3:4424:=
 ICMP6,=20
> neighbor advertisement, tgt is 2a00:800:752:1::5c:1, length 24



> 12:54:03.683672 00:24:81:a3:44:24 > 00:22:55:17:4b:80, ethertype IPv6
> (0x86dd), length 118: 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: IC=
MP6, echo=20
> request, seq 13, length 64
> [...]
>=20
> $ ip -6 ne
> fe80::222:55ff:fe17:4b80 dev eth0 lladdr 00:22:55:17:4b:80 router STA=
LE
> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router STALE
>=20
>=20
> Fixing the adjacency
> --------------------
> $ ping6 2a00:800:752:1::5c:1
> PING 2a00:800:752:1::5c:1(2a00:800:752:1::5c:1) 56 data bytes
> ^C
> --- 2a00:800:752:1::5c:1 ping statistics ---
> 51 packets transmitted, 0 received, 100% packet loss, time 50006ms
>=20
> $ sudo ip ne del 2a00:800:752:1::5c:1 dev eth0
> $ ping6 2a00:800:752:1::5c:1
> PING 2a00:800:752:1::5c:1(2a00:800:752:1::5c:1) 56 data bytes
> 64 bytes from 2a00:800:752:1::5c:1: icmp_seq=3D1 ttl=3D64 time=3D31.9=
 ms
> 64 bytes from 2a00:800:752:1::5c:1: icmp_seq=3D2 ttl=3D64 time=3D0.21=
2 ms
>=20
> $ ip -6 ne
> fe80::222:55ff:fe17:4b80 dev eth0 lladdr 00:22:55:17:4b:80 router REA=
CHABLE
> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router REACHAB=
LE
>=20
> (Note that after a few minutes it goes back to STALE, but pinging sti=
ll works=20
> and brings back the state to REACHABLE, so it's not that it can't get=
 out of=20
> STALE once there, it seems).
>=20

I am wondering if you have some lowlevel problem, say lost frames in an
otherwise idle link, maybe a full/half duplex mismatch ?
