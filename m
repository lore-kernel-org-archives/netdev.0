From: Radu Rendec <radu.rendec@mindbit.ro>
Subject: TUN interfaces loopback
Date: Wed, 25 Nov 2015 18:58:13 +0200
Message-ID: <1448470693.7801.41.camel@mindbit.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.mindbit.ro ([80.86.127.26]:40475 "EHLO ns2.local.mindbit.ro"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750735AbbKYRQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 12:16:33 -0500
Received: from bat.mindbit.ro (xs1.mindbit.ro [80.86.107.70])
	by ns2.local.mindbit.ro (Postfix) with ESMTP id 0B8C71A212F
	for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 18:58:14 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disclaimer: I know this is a *development* list, but I feel the answer
lies deep down in the ipv4 routing code, so it's more likely that I
find help here.

That being said, I have two TUN interfaces that are "cross-connected"
in user space (i.e. whatever is read on the socket corresponding to
either interface is written to the socket of the other interface).

The problem: if I assign IPv4 addresses to both TUN interfaces, local
traffic to either address flows through the loopback interface. Getting
packets to be routed through the TUN interfaces is easy. The real
challenge is to get packets to be accepted/processed as input packets
when they pop out of the opposite TUN interface.

I tracked down the problem to=C2=A0ip_route_input_slow() in=C2=A0net/ip=
v4/route.c

What I tried so far:

1. Remove the implicit routes from the local table. This apparently
causes packets to be silently dropped by=C2=A0ip_route_input_slow(), si=
nce
it looks for a corresponding route and only delivers packets locally if
a local route is found.

2. Keep implicit routes in the local table, change the priority of the
"lookup local" ip rule, mark *output* packets with iptables and add a
higher priority rule to lookup the main table for marked packets.

By doing that, the main table is looked up on the egress path and
packets are routed through the TUN interface. When packets pop out of
the opposite TUN interface, they are no longer marked (because they are
actually different packets), so ingress routing correctly looks up the
local table.

The next problem is that packets are seen as "martians" and dropped,
most probably because of=C2=A0__fib_validate_source() failing due to th=
e
fact that the input interface is not the expected one.

This is where I stopped. Any idea or help would be highly appreciated.
Please CC my private address (I am not subscribed to the list). Thanks
in advance!
