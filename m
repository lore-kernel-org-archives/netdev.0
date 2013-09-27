From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: IPv6 path MTU discovery broken
Date: Fri, 27 Sep 2013 22:14:20 +0200
Message-ID: <20130927201420.GB12043@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:42575 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3I0UOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:14:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

PMTU discovery over IPv6 has been flaky for me for a while, but at some=
 point
between 3.10 and 3.11, it broke for me completely. Just checked with
3.12.0-rc2 and the problem is still there.

=46irst, a look at my routing table, which is slightly unusual due to t=
unnels
and BGP being involved:

  pannekake:~> sudo ip -6 route                =20
  2001:500:72::/48 via 2001:67c:29f4::1 dev eth0  proto zebra  metric 1=
024=20
  2001:67c:a4::/48 via fe80::230:48ff:fe55:5743 dev eth0  proto zebra  =
metric 100=20
  2001:67c:29f4::/64 dev eth0  proto kernel  metric 256=20
  2001:67c:29f4:1::/64 via fe80::230:48ff:fe55:5743 dev eth0  proto zeb=
ra  metric 100=20
  2001:67c:29f4:1000::/64 via fe80::230:48ff:fe55:5743 dev eth0  proto =
zebra  metric 100=20
  2001:67c:29f4:1001::/64 via fe80::230:48ff:fe55:5743 dev eth0  proto =
zebra  metric 100=20
  2001:67c:29f4:1003::/64 via fe80::230:48ff:fe55:5743 dev eth0  proto =
zebra  metric 100=20
  2001:67c:29f4:1005::/64 via fe80::230:48ff:fe55:5743 dev eth0  proto =
zebra  metric 100=20
  2001:67c:29f4:1007::/64 via fe80::230:48ff:fe55:5743 dev eth0  proto =
zebra  metric 100=20
  2001:67c:29f4::/48 via 2001:67c:29f4::1 dev eth0  proto zebra  metric=
 1024=20
  2001:700::/32 via 2001:67c:29f4::1 dev eth0  proto zebra  metric 1024=
=20
  2a02:2368::/32 via 2001:67c:29f4::1 dev eth0  proto zebra  metric 102=
4=20
  fe80::c30b:9a61 dev k_sessesveits  proto kernel  metric 256=20
  fe80::c30b:9a61 dev k_wikene  proto kernel  metric 256=20
  fe80::c30b:9a61 dev k_trygve  proto kernel  metric 256=20
  fe80::c30b:9a61 dev k_magne  proto kernel  metric 256=20
  fe80::c30b:9a61 dev k_berge  proto kernel  metric 256=20
  fe80::c30b:9a61 dev k_molven  proto kernel  metric 256=20
  fe80::/64 dev eth0  proto kernel  metric 256=20
  fe80::/64 dev k_sessesveits  proto kernel  metric 256=20
  fe80::/64 dev k_wikene  proto kernel  metric 256=20
  fe80::/64 dev k_trygve  proto kernel  metric 256=20
  fe80::/64 dev k_magne  proto kernel  metric 256=20
  fe80::/64 dev k_berge  proto kernel  metric 256=20
  fe80::/64 dev k_molven  proto kernel  metric 256=20
  default via 2001:67c:29f4::1 dev eth0  metric 1024=20

Note in particular that 2001:67c:a4::/48 goes to a link-local address. =
The
tcpdump is classic; when I try to do something big over my SSH session,
like an ls, it starts failing:

22:02:13.597303 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [P.], seq 5281:5521, ack 2802, win 149, options [nop=
,nop,TS val 1526325 ecr 45546957], length 240
22:02:13.597331 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [P.], seq 5521:5713, ack 2802, win 149, options [nop=
,nop,TS val 1526325 ecr 45546957], length 192
22:02:13.597353 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [P.], seq 5713:5921, ack 2802, win 149, options [nop=
,nop,TS val 1526325 ecr 45546957], length 208
22:02:13.597372 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [P.], seq 5921:6049, ack 2802, win 149, options [nop=
,nop,TS val 1526325 ecr 45546957], length 128
22:02:13.638445 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 3313, win 173, options [nop,nop,TS val 4554=
6972 ecr 1526306], length 0
22:02:13.638468 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 6049:7477, ack 2802, win 149, options [nop,=
nop,TS val 1526366 ecr 45546972], length 1428
22:02:13.638475 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 7477:8905, ack 2802, win 149, options [nop,=
nop,TS val 1526366 ecr 45546972], length 1428
22:02:13.654519 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 3585, win 188, options [nop,nop,TS val 4554=
6977 ecr 1526325], length 0
22:02:13.654538 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 8905:10333, ack 2802, win 149, options [nop=
,nop,TS val 1526382 ecr 45546977], length 1428
22:02:13.654545 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 10333:11761, ack 2802, win 149, options [no=
p,nop,TS val 1526382 ecr 45546977], length 1428
22:02:13.661389 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 4097, win 203, options [nop,nop,TS val 4554=
6977 ecr 1526325], length 0
22:02:13.661408 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 11761:13189, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546977], length 1428
22:02:13.661415 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 13189:14617, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546977], length 1428
22:02:13.661420 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 4705, win 218, options [nop,nop,TS val 4554=
6977 ecr 1526325], length 0
22:02:13.661431 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 14617:16045, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546977], length 1428
22:02:13.661436 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 16045:17473, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546977], length 1428
22:02:13.661441 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 5009, win 233, options [nop,nop,TS val 4554=
6978 ecr 1526325], length 0
22:02:13.661449 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 17473:18901, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661454 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 18901:20329, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661458 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 5281, win 248, options [nop,nop,TS val 4554=
6978 ecr 1526325], length 0
22:02:13.661464 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 20329:21757, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661468 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 21757:23185, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661472 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 5521, win 263, options [nop,nop,TS val 4554=
6978 ecr 1526325], length 0
22:02:13.661478 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 23185:24613, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661483 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 24613:26041, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661486 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 5713, win 278, options [nop,nop,TS val 4554=
6978 ecr 1526325], length 0
22:02:13.661493 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 26041:27469, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661496 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 27469:28897, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546978], length 1428
22:02:13.661500 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 5921, win 293, options [nop,nop,TS val 4554=
6979 ecr 1526325], length 0
22:02:13.661506 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 28897:30325, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546979], length 1428
22:02:13.661510 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 30325:31753, ack 2802, win 149, options [no=
p,nop,TS val 1526389 ecr 45546979], length 1428
22:02:13.662006 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:13.667419 IP6 2001:67c:a4:1:5c5f:5194:3a7e:4878.48943 > 2001:67c:=
29f4::50.22: Flags [.], ack 6049, win 307, options [nop,nop,TS val 4554=
6979 ecr 1526325], length 0
22:02:13.667437 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 31753:33181, ack 2802, win 149, options [no=
p,nop,TS val 1526395 ecr 45546979], length 1428
22:02:13.667444 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 33181:34609, ack 2802, win 149, options [no=
p,nop,TS val 1526395 ecr 45546979], length 1428
22:02:13.667724 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:13.667743 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:13.794924 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 34609:36037, ack 2802, win 149, options [no=
p,nop,TS val 1526523 ecr 45546979], length 1428
22:02:13.795182 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:14.059981 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 6049:7477, ack 2802, win 149, options [nop,=
nop,TS val 1526788 ecr 45546979], length 1428
22:02:14.060308 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:14.589978 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 6049:7477, ack 2802, win 149, options [nop,=
nop,TS val 1527318 ecr 45546979], length 1428
22:02:14.590185 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:15.647967 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 6049:7477, ack 2802, win 149, options [nop,=
nop,TS val 1528376 ecr 45546979], length 1428
22:02:15.648223 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240
22:02:17.768006 IP6 2001:67c:29f4::50.22 > 2001:67c:a4:1:5c5f:5194:3a7e=
:4878.48943: Flags [.], seq 6049:7477, ack 2802, win 149, options [nop,=
nop,TS val 1530496 ecr 45546979], length 1428
22:02:17.768307 IP6 2001:67c:29f4::31 > 2001:67c:29f4::50: ICMP6, packe=
t too big, mtu 1468, length 1240

So the =E2=80=9Cpacket too big=E2=80=9D packets really look like they'r=
e being ignored.
However, they _do_ reach the kernel somehow, since Icmp6InPktTooBigs
seems to increase.

Could this be related somehow to the packets coming from 2001:67c:29f4:=
:31,
while the default route is to a link-local address? (An RPF issue?) Thi=
s used
to work (although it was often flaky for me) in 3.10 and before. I can'=
t
easily bisect, though, as I don't boot this machine too often.

/* Steinar */
--=20
Homepage: http://www.sesse.net/
