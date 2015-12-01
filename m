From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: TUN interfaces loopback
Date: Tue, 01 Dec 2015 12:02:15 +0100
Message-ID: <1448967735.3317024.454539225.4F16ACA3@webmail.messagingengine.com>
References: <1448470693.7801.41.camel@mindbit.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Radu Rendec <radu.rendec@mindbit.ro>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41618 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752314AbbLALCh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 06:02:37 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id BDBA621153
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 06:02:16 -0500 (EST)
In-Reply-To: <1448470693.7801.41.camel@mindbit.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Nov 25, 2015, at 17:58, Radu Rendec wrote:
> Disclaimer: I know this is a *development* list, but I feel the answe=
r
> lies deep down in the ipv4 routing code, so it's more likely that I
> find help here.
>=20
> That being said, I have two TUN interfaces that are "cross-connected"
> in user space (i.e. whatever is read on the socket corresponding to
> either interface is written to the socket of the other interface).
>=20
> The problem: if I assign IPv4 addresses to both TUN interfaces, local
> traffic to either address flows through the loopback interface. Getti=
ng
> packets to be routed through the TUN interfaces is easy. The real
> challenge is to get packets to be accepted/processed as input packets
> when they pop out of the opposite TUN interface.

Why do you require them to be marked as "input" packets?

> I tracked down the problem to=C2=A0ip_route_input_slow() in=C2=A0net/=
ipv4/route.c
>=20
> What I tried so far:
>=20
> 1. Remove the implicit routes from the local table. This apparently
> causes packets to be silently dropped by=C2=A0ip_route_input_slow(), =
since
> it looks for a corresponding route and only delivers packets locally =
if
> a local route is found.
>=20
> 2. Keep implicit routes in the local table, change the priority of th=
e
> "lookup local" ip rule, mark *output* packets with iptables and add a
> higher priority rule to lookup the main table for marked packets.
>=20
> By doing that, the main table is looked up on the egress path and
> packets are routed through the TUN interface. When packets pop out of
> the opposite TUN interface, they are no longer marked (because they a=
re
> actually different packets), so ingress routing correctly looks up th=
e
> local table.
>=20
> The next problem is that packets are seen as "martians" and dropped,
> most probably because of=C2=A0__fib_validate_source() failing due to =
the
> fact that the input interface is not the expected one.
>=20
> This is where I stopped. Any idea or help would be highly appreciated=
=2E
> Please CC my private address (I am not subscribed to the list). Thank=
s
> in advance!

Have you tried ip route add local-ip-addr/32 dev tun0 and handle arp on
the outside interfaces with arp proxying or other means (routing
protocols)?

Thanks,
Hannes
