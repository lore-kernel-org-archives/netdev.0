From: Emmanuel Thierry <ml@sekil.fr>
Subject: ipv6: strange routing behaviors on a multi-interfaces setup
Date: Wed, 25 Sep 2013 18:53:07 +0200
Message-ID: <374AB8DA-F970-4652-B147-2094B56BE5F0@sekil.fr>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host1.trois-doubles.net ([95.130.12.24]:55650 "EHLO
	host1.trois-doubles.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab3IYRBz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 13:01:55 -0400
Received: from [IPv6:2001:660:7301:3728:226:b0ff:fefa:237d] (unknown [IPv6:2001:660:7301:3728:226:b0ff:fefa:237d])
	by host1.trois-doubles.net (Postfix) with ESMTPSA id B838320C56D
	for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 18:53:08 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm working on multi-interfaces setups on IPv6. I found several disturb=
ing route behaviors which sounds like bugs to me.

Both eth1 and eth2 interfaces receive RAs from distinct routers and aut=
oconfigure:
* their slaac address
* their default route, both with the same priority
Under these conditions, the following happen depending on the expiratio=
n time of each route.


1/ A ping with a specified source address and interface may go through =
the wrong interface.

# ping6  -c 1 -I "<slaac_eth1>%eth1" <dest>
=85 uses the right interface (eth1) with the right source address (<sla=
ac_eth1>).

# ping6  -c 1 -I "<slaac_eth2>%eth2" <dest>
=85 uses the wrong interface (eth1) with the right source address (<sla=
ac_eth2>).

The ping6 utility performed a bind() on <slaac_ethx> with scope id set =
to <ifindex_ethx>.
If we flush the routing cache between each ping, the routing is done as=
 expected.

As i could observe in the kernel. When ip6_pol_route() is called, oif i=
s equal to <ifindex_eth2> but the flag RT6_LOOKUP_F_IFACE is not set. T=
his makes routes through other interfaces to still be valid.
Shouldn't we set the RT6_LOOKUP_F_IFACE flag when a scope id is specifi=
ed ?


2/ A ping from a specified source address may go through the wrong inte=
rface.

# ping6  -I "<slaac_eth2>" <dest>
=85 may use eth1 with <slaac_eth2>.

The ping6 utility performed a bind() on <slaac_eth2>
This is a derivative from the first one, with the significative differe=
nce that it also happens if the routing cache is empty. The most recent=
 default route is chosen regardless of the source address.

Shouldn't we look in a first try for routes on the device corresponding=
 to the source address, and in a second try for others ?


3/ A ping from a specified interface may go through the wrong interface=
 with the wrong source address.

# ping6  -I "eth2" <dest>
=85 may use eth1 with <slaac_eth1>.

The ping6 performs a setsockopt(IPV6_PKTINFO) with <ifindex_ethx>, then=
 a connect() to the destination. In this case, source address selection=
 is concerned, but also routing since source address selection depends =
on routing.


I experienced these problems on a 3.11.1 kernel but they look to be qui=
te recurrent in the past versions as well.=20

Best regards
Emmanuel Thierry
