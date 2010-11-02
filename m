From: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Subject: Re: Routing over multiple interfaces
Date: Tue, 02 Nov 2010 23:56:32 +0100
Message-ID: <4CD09720.8030403@plouf.fr.eu.org>
References: <1288645922.5977.41.camel@macbook.infradead.org>	 <20101101.141638.116372747.davem@davemloft.net>	 <1288647330.2660.116.camel@edumazet-laptop>	 <4CD06AA4.6090005@plouf.fr.eu.org> <1288728267.2467.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bamako.nerim.net ([62.4.17.28]:62042 "EHLO bamako.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab0KBW4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 18:56:38 -0400
In-Reply-To: <1288728267.2467.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Le mardi 02 novembre 2010 =E0 20:46 +0100, Pascal Hambourg a =E9crit =
:
>=20
>> What about using iptables + routing rules ?
>> Mark every other packet going through the default PPP link with
>> iptables, and reroute marked packets through the other PPP link.
>=20
> OK. I provided a working setup, maybe you also could provide one base=
d
> on iptables as well ?

Arnd Hannemann provided something quite close to what I was thinking
about. I would just make a few adjustments. I added a rule for locally
generated traffic if needed. Also, using the PPP peer as gateway could
be troublesome if both links have the same peer address, so I used the
device instead.

iptables -t mangle -N mark6
iptables -t mangle -A mark6 -m statistic --mode nth --every 2 -j MARK
--set-mark 6

# forwarded traffic, $LANDEV is the interface connected to the LAN
iptables -t mangle -A PREROUTING -i $LANDEV -j mark6
# locally generated traffic to the PPP link
iptables -t mangle -A OUTPUT -o ppp0 -j mark6

ip rule add fwmark 6 table ppp1
ip route replace default dev ppp0
ip route replace default dev ppp1 table ppp1

It still needs some refinements such as excluding non-external
destinations from the PREROUTING rule. Your setup seems much simpler an=
d
efficient.
