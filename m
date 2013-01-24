From: Axel Neumann <neumann@cgws.de>
Subject: Re: [PATCH net-next] ipv6: fix handling of throw routes
Date: Thu, 24 Jan 2013 10:11:39 +0000 (UTC)
Message-ID: <loom.20130124T102348-176@post.gmane.org>
References: <5048A374.60005@6wind.com> <1346946815-3094-1-git-send-email-nicolas.dichtel@6wind.com> <20120907.141808.933339383624986735.davem@davemloft.net> <504D93A4.4090706@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:34520 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752956Ab3AXKO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 05:14:57 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TyJpp-0001jQ-Rl
	for netdev@vger.kernel.org; Thu, 24 Jan 2013 11:15:06 +0100
Received: from p5795A1B6.dip0.t-ipconnect.de ([87.149.161.182])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 11:15:05 +0100
Received: from neumann by p5795A1B6.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 11:15:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Nicolas Dichtel <nicolas.dichtel <at> 6wind.com> writes:

>=20
> Le 07/09/2012 20:18, David Miller a =C3=A9crit :
> > From: Nicolas Dichtel <nicolas.dichtel <at> 6wind.com>
> > Date: Thu,  6 Sep 2012 11:53:35 -0400
> >
> >> It's the same problem that previous fix about blackhole and prohib=
it routes.
> >>
> >> When adding a throw route, it was handled like a classic route.
> >> Moreover, it was only possible to add this kind of routes by speci=
fying
> >> an interface.
> >>
> >> Before the patch:
> >>    $ ip route add throw 2001::2/128
> >>    RTNETLINK answers: No such device
> >>    $ ip route add throw 2001::2/128 dev eth0
> >>    $ ip -6 route | grep 2001::2
> >>    2001::2 dev eth0  metric 1024
> >>
> >> After:
> >>    $ ip route add throw 2001::2/128
> >>    $ ip -6 route | grep 2001::2
> >>    throw 2001::2 dev lo  metric 1024  error -11
> >>
> >> Reported-by: Markus Stenberg <markus.stenberg <at> iki.fi>
> >> Signed-off-by: Nicolas Dichtel <nicolas.dichtel <at> 6wind.com>
> >
> > Applied, thanks.


Although 'ip -6 route show' now reports a "throw" instead of an "unreac=
hable"
route the behavior of a configured IPv6 "throw" route still seems incor=
rect and
similar to that of an "unreachable" route!


I've tested with kernel 3.7.4 which includes this patch:
http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dcomm=
itdiff;h=3Def2c7d7b59708d54213c7556a82d14de9a7e4475

An example scenario using a dedicated routing table (IMHO the main use =
case for
throw routes) is given below...

greetings
/axel



The following scenario shows an example:
computer 1001 and 1002 connected via ethernet eth2
computer 1002 has 1001:2::2/64 on eth2


Now at computer 1001:

root@mlc1001:~# ping6 1001:2::2 -c 1
connect: Network is unreachable

root@mlc1001:~# ip a add 1001:2::1/64 dev eth2

root@mlc1001:~# ip -6 rule add from all lookup 10 pref 1000

root@mlc1001:~# ip -6 rule   =20
0:      from all lookup local=20
1000:   from all lookup 10=20
32766:  from all lookup main=20

root@mlc1001:~# ip -6 route list table 10

root@mlc1001:~# ping6 1001:2::2 -c 1
PING 1001:2::2(1001:2::2) 56 data bytes
64 bytes from 1001:2::2: icmp_seq=3D1 ttl=3D64 time=3D0.263 ms
--- 1001:2::2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 0.263/0.263/0.263/0.000 ms

root@mlc1001:~# ip -6 route add throw 1001:2::/64 table 10

root@mlc1001:~# ip -6 route list table 10
throw 1001:2::/64 dev lo  metric 1024  error -11

root@mlc1001:~# ping6 1001:2::2 -c 1
connect: Resource temporarily unavailable


# Although the destination lookup should only be thrown for table 10
# and continue on the main table where a valid local route exists
# it fails. For remote throw routes the error says something like:
# From 1001:2::2 icmp_seq=3D1 Destination unreachable: No route
# Removing the throw route again it works again...


root@mlc1001:~# ip -6 r
1001:2::/64 dev eth2  proto kernel  metric 256=20
fe80::/64 dev eth0  proto kernel  metric 256=20
fe80::/64 dev eth1  proto kernel  metric 256=20
fe80::/64 dev eth2  proto kernel  metric 256=20

root@mlc1001:~# ip -6 route del throw 1001:2::/64 table 10

root@mlc1001:~# ping6 1001:2::2 -c 1
PING 1001:2::2(1001:2::2) 56 data bytes
64 bytes from 1001:2::2: icmp_seq=3D1 ttl=3D64 time=3D0.264 ms
--- 1001:2::2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 0.264/0.264/0.264/0.000 ms

root@mlc1001:~# ip -6 r
1001:2::2 via 1001:2::2 dev eth2  metric 0=20
    cache=20
1001:2::/64 dev eth2  proto kernel  metric 256=20
fe80::/64 dev eth0  proto kernel  metric 256=20
fe80::/64 dev eth1  proto kernel  metric 256=20
fe80::/64 dev eth2  proto kernel  metric 256=20
root@mlc1001:~#=20
