From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Wed, 24 Jul 2013 09:57:59 +0200
Message-ID: <20130724075759.GS10216@zirkel.wertarbyte.de>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
 <20130724021420.GA10670@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:45825 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab3GXH6F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 03:58:05 -0400
Content-Disposition: inline
In-Reply-To: <20130724021420.GA10670@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb Hannes Frederic Sowa (hannes@stressinduktion.org):

> Yeah, it is sometimes pretty hideous to set up, especially if one use=
s
> ppp stuff and such. But I am unsure if this change does actually impr=
ove
> that considerable. Static setups should be easily doable right now an=
d for
> ppp/vpn stuff, I fear, it would still lack a bit of flexibility.

Well, it does work for me. I am using a dynamic PPP uplink and an OpenV=
PN
tunnel where some marked traffic is guided through.

To achieve this, I always had to configure pppd with "nodefaultroute" j=
ust to
add the default route it manually in a separate table, complicating the
configuration process.

With my patches added, I can just reference a "masked" version of the m=
ain
routing table at first, ignoring the default route placed there by pppd=
:

echo "vpn" >> /etc/iproute2/rt_tables
ip route add table vpn default via tun0
ip rule add pref 100 lookup main prefixlength 0
ip rule add pref 200 fwmark 0xA lookup vpn

             |
             V
[ table main prefixlength >0 ]
             |
             V
       <fwmark 0xA?>   ->  [ table vpn ]
             |                   |
	     |    ,--------------=B4
	     V    V
        [ table main ]

That way, there is no need to reconfigure pppd, dhclient etc. If a spec=
ific
route of the main table matches, it will we used. If the main table jus=
t points
to the default route (prefixlengt =3D=3D 0), it will be ignored and the=
 packet
travels to the next rule. In the end, the complete main table might sti=
ll be
consulted, including the previously shunned default route.

Works great and requires little to no hacking around distribution speci=
fic
network scripts.

> I would try to factor the prefixlen_min check out into a
> e.g. fib4_rule_constrain function for which a new field in fib_rules_=
ops
> needs to be created as callback. Also it would be nice to have IPv6
> support, too. ;)

Why not, sure. Working solutions today, better solutions tomorrow :-)
