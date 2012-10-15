From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [RFC PATCH net-next v2 0/1] Add support of ECMPv6
Date: Mon, 15 Oct 2012 14:36:08 +0200
Message-ID: <c6a5aae8c773f78aaa1c59cfb68a3d52@luffy.cx>
References: <505058F5.9020707@linux-ipv6.org>
 <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com>
 <87392l7xjc.fsf@guybrush.luffy.cx> <5053329F.6030109@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:41110 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752586Ab2JOMgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2012 08:36:11 -0400
In-Reply-To: <5053329F.6030109@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14.09.2012 15:35, Nicolas Dichtel a =C3=A9crit=C2=A0:

>> Therefore, the problem is not in iproute2 which knows how to display
>> those ECMP routes. I fear that this difference make support in=20
>> routing
>> daemons more difficult.
> Hmm, can you elaborate? Our routing daemon, quagga, manage it without
> any problem.

Hi!

Sorry for the late answer. I have been experimenting with your patch=20
and it seems that Quagga does not handle such routes. Do you have some=20
patchset on top of Quagga? I am looking at=20
28971c8cb1138700e87dc7da673e59b5596bb51b (which is fairly recent) and i=
n=20
zebra/rt_netlink.c, IPv6 routes are handled as IPv4 routes: multiple=20
hops are added as attributes.

In Quagga, I do:

ipv6 route 2001:db8:97::/64 2001:db8:1::2
ipv6 route 2001:db8:97::/64 2001:db8:2::2

And I get:

r1(VTY)# show ipv6  route
Codes: K - kernel route, C - connected, S - static, R - RIPng,
        O - OSPFv6, I - IS-IS, B - BGP, A - Babel,
        > - selected route, * - FIB route

C>* ::1/128 is directly connected, lo
O   2001:db8:1::/64 [110/1] is directly connected, eth0, 01:52:42
C>* 2001:db8:1::/64 is directly connected, eth0
O   2001:db8:2::/64 [110/1] is directly connected, eth1, 01:52:37
C>* 2001:db8:2::/64 is directly connected, eth1
S>  2001:db8:97::/64 [1/0] via 2001:db8:1::2, eth0
                            via 2001:db8:2::2, eth1
K>* 2001:db8:98::/64 via 2001:db8:2::2, eth1
C>* 2001:db8:99::/64 is directly connected, dummy0
C * fe80::/64 is directly connected, eth1
C * fe80::/64 is directly connected, eth0
C>* fe80::/64 is directly connected, dummy0

The route is not installed in the kernel (not "*"):

2012/10/15 14:22:01 ZEBRA: rib_process: 2001:db8:97::/64: Updating=20
existing route, select 0x7fee39f0ad10, fib 0x7fee39f0ad10
2012/10/15 14:22:01 ZEBRA: netlink_route_multipath() (multihop):=20
RTM_DELROUTE 2001:db8:97::/64, type IPv6 nexthop
2012/10/15 14:22:01 ZEBRA: netlink_route_multipath() (multihop):=20
nexthop via 2001:db8:1::2 if 4
2012/10/15 14:22:01 ZEBRA: netlink_talk: netlink-cmd type=20
RTM_DELROUTE(25), seq=3D27
2012/10/15 14:22:01 ZEBRA: netlink_route_multipath() (multihop):=20
RTM_NEWROUTE 2001:db8:97::/64, type IPv6 nexthop
2012/10/15 14:22:01 ZEBRA: netlink_route_multipath() (multihop):=20
nexthop via 2001:db8:1::2 if 4
2012/10/15 14:22:01 ZEBRA: netlink_route_multipath() (multihop):=20
RTM_NEWROUTE 2001:db8:97::/64, type IPv6 nexthop
2012/10/15 14:22:01 ZEBRA: netlink_route_multipath() (multihop):=20
nexthop via 2001:db8:2::2 if 5
2012/10/15 14:22:01 ZEBRA: netlink_talk: netlink-cmd type=20
RTM_NEWROUTE(24), seq=3D28
2012/10/15 14:22:01 ZEBRA: netlink-cmd error: No such process,=20
type=3DRTM_NEWROUTE(24), seq=3D28, pid=3D0

The problem is the same with BIRD. The difference with IPv4 makes it=20
difficult to factor the code between IPv4 and IPv6. What do you think?
