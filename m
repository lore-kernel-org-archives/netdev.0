From: Simon Roscic <simon@segfault.info>
Subject: gateway icmp redirect handling problem (3.0.36-3.0.23)
Date: Sat, 14 Jul 2012 20:57:13 +0200
Message-ID: <3383bade3b9d45d93fb42ffef3517c15@segfault.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from justitmail.at ([83.175.122.136]:50762 "EHLO justitmail.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452Ab2GNTEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 15:04:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I=C2=B4m experiencing the following problem with kernel versions 3.0.36=
=20
(down to 3.0.23):

on our network we all have one default gateway, it=C2=B4s 10.1.1.254, b=
ut=20
there are some networks for which we have another gateway and for this=20
networks the default gateway sends an icmp redirect.

lets assume my test machine has ip 10.1.20.79 netmask is 255.255.0.0=20
and my default gateway is 10.1.1.254, i now ping the following ip:=20
10.109.98.11, my default gateway (10.1.1.254) now sends me an icmp=20
redirect to another gateway (10.1.1.1) ... and now everything works as=20
expected, i get the replies from 10.109.98.11 but not for long, after=20
approx. 60 (or so) seconds i only get "ping: sendmsg: Network is down".
(exact same problem with all other tcp/udp protocols, but i used ping=20
for the tests because it also prints the redirect messages to the=20
console)

so let=C2=B4s have a closer look:

not ok - kernel versions 3.0.36 down to 3.0.23:
-----------------------------------------------

test-simon:~ # ping 10.109.98.10
=2E..
64 bytes from 10.109.98.11: icmp_seq=3D62 ttl=3D60 time=3D12.1 ms
64 bytes from 10.109.98.11: icmp_seq=3D63 ttl=3D60 time=3D11.6 ms
ping: sendmsg: Network is down
ping: sendmsg: Network is down

when looking at "ip neigh" the "ping: sendmsg: Network is down" message=
=20
appears in the exact moment when the arp entry for the default gateway=20
(10.1.1.254) gets removed from the arp cache:

ping "OK"
test-simon:~ # ip neigh
10.1.1.1 dev eth0 lladdr 00:00:0c:9f:f0:64 REACHABLE
10.1.1.254 dev eth0 lladdr 00:1a:64:8f:23:64 STALE

ping "dead"
test-simon:~ # ip neigh
10.1.1.1 dev eth0 lladdr 00:00:0c:9f:f0:64 REACHABLE

so it seems that when the default gateway is removed from the arp cache=
=20
something goes wrong in the kernel route handling. i don=C2=B4t know th=
e=20
internals of the linux route handling, now i need your help, any ideas=20
what=C2=B4s going wrong?

i did a lot of tests, the problem i described first happens with kernel=
=20
version 3.0.23, i found in the changelog of 3.0.23 the following two=20
commits:
(http://www.kernel.org/pub/linux/kernel/v3.0/ChangeLog-3.0.23)

commit 42ab5316ddcaa0de23e88e8a3d363c767b9ab0b3
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Fri Nov 18 15:24:32 2011 -0500
ipv4: fix redirect handling

commit bebee22bcbf0026f92141990972bd5863ef9b69c
Author: Flavio Leitner <fbl@redhat.com>
Date:   Mon Oct 24 02:56:38 2011 -0400
route: fix ICMP redirect validation

i then took the net/ipv4/route.c file from kernel 3.0.22 and replaced=20
the version in 3.0.23 with it, this reverts the two mentioned patches=20
above (if i havent overlooked something) after that the problem=20
disappears.
so those two patches surely fixed some problem but for kernel versions=20
3.0.23-3.0.36 they broke the gateway icmp redirect handling as describe=
d=20
by me here.

i did some further tests with different kernel versions:
3.5-rc6: OK
3.4.4: OK
3.2.22: OK
3.0.1 - 3.0.22: OK
3.0.23 - 3.0.36: not OK
2.6.35.13: OK

now lets have a closer look at a kernel version which works:
------------------------------------------------------------

this is from 3.5-rc6, but 3.4.4, 3.2.2 and 2.6.35.13 also behave=20
exactly this way, 3.0.1-3.0.22 behave slightly different, see note=20
below.

test-simon:~ # ping 10.109.98.11
PING 10.109.98.10 (10.109.98.11) 56(84) bytes of data.
64 bytes from 10.109.98.11: icmp_seq=3D1 ttl=3D60 time=3D15.2 ms
 From 10.1.1.254: icmp_seq=3D2 Redirect Host(New nexthop: 10.1.1.1)
=2E..

test-simon:~ # ip neigh
10.1.1.1 dev eth0 lladdr 00:00:0c:9f:f0:64 REACHABLE
10.1.1.254 dev eth0 lladdr 00:1a:64:8f:23:64 STALE

and after approx 60 or so seconds:

test-simon:~ # ip neigh
10.1.1.1 dev eth0 lladdr 00:00:0c:9f:f0:64 REACHABLE

and ping (and everything else) is as expected still working.

note:
-----

on 3.0.1-3.0.22:

i see lots of icmp redirects sent from the default gateway (10.1.1.254)=
=20
to my test machine, while running tcpdump on the default gateway=20
(10.1.1.254) i see every ping packet also arriving there and also some=20
icmp redirect messages going out to my test machine.
but everything works so i think my test machine is correctly talking to=
=20
the destination using the other gateway (10.1.1.1).
i also sniffed a windows 7 client pc, it looks the same there, so=20
possibly no problem, but i mention this because kernel versions 3.5-rc6=
,=20
3.4.4, 3.2.22 and 2.6.35.13 act differently (see below).

on 3.0.23-3.0.36:

i see lots of icmp redirects sent from the default gateway (10.1.1.254)=
=20
to my test machine, while running tcpdump on the default gateway=20
(10.1.1.254) i see up to 20 ping packets arriving there and also up to=20
17 icmp redirect messages going out to my test machine, after the 20th=20
ping packet i dont see further ping packets arriving at the default=20
gateway. so my test machine is then only talking to the other gateway=20
(10.1.1.1) i think.
=2E..
17:48:41.643952 IP 10.1.1.254 > 10.1.20.79: ICMP redirect 10.109.98.11=20
to host 10.1.1.1, length 92
=2E..
17:48:44.649008 IP 10.1.20.79 > 10.109.98.11: ICMP echo request, id=20
30733, seq 20, length 64
17:48:44.649018 IP 10.1.20.79 > 10.109.98.11: ICMP echo request, id=20
30733, seq 20, length 64

on 3.5-rc6, 3.4.4, 3.2.22 and 2.6.35.13:

here it looks different, and for me this is the expected behavior, or=20
at least the behavior i have seen from lots of linux machines on my=20
network. i see 1-2 icmp redirects sent from the default gateway=20
(10.1.1.254) to my test machine, while running tcpdump on the default=20
gateway (10.1.1.254) i only see up to 2 ping packets arriving then=20
nothing, so then my test machine seems to only talk to the other gatewa=
y=20
(10.1.1.1).

17:50:58.995894 IP 10.1.20.79 > 10.109.98.11: ICMP echo request, id=20
10766, seq 1, length 64
17:50:58.995914 IP 10.1.20.79 > 10.109.98.11: ICMP echo request, id=20
10766, seq 1, length 64
17:50:59.997260 IP 10.1.20.79 > 10.109.98.11: ICMP echo request, id=20
10766, seq 2, length 64
17:50:59.997277 IP 10.1.1.254 > 10.1.20.79: ICMP redirect 10.109.98.11=20
to host 10.1.1.1, length 92
17:50:59.997287 IP 10.1.20.79 > 10.109.98.11: ICMP echo request, id=20
10766, seq 2, length 64

=2E..

(before someone asks why i "must" use kernel 3.0.x ... because this are=
=20
SLES 11 SP2 VMs and they currently ship kernel 3.0.34)

i hope i described the problem in a way so that the kernel network=20
stack maintainers can understand the problem, please conact me if you=20
have further questions, and please CC me as i am not subscribed to=20
linux-netdev. if you wish you can also CC this message or replies to=20
linux-kernel.

kind regards,
Simon Roscic.
