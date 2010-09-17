From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 11:08:53 +0200
Message-ID: <1284714533.3391.53.camel@edumazet-laptop>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
	 <1284650768.3352.37.camel@edumazet-laptop>
	 <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
	 <1284652453.3352.38.camel@edumazet-laptop>
	 <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
	 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
	 <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33815 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab0IQJI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 05:08:58 -0400
In-Reply-To: <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 septembre 2010 =C3=A0 10:46 +0200, Nicola Padovano a =C3=
=A9crit :
> Aijaz, great! Now it' clear. Thank you.
> It remains a problem: the meaning of
>=20
> fl.nl_u.ip4_u.saddr =3D 0
>=20
> But, first of all:
> - we know that a routing table doesn't contain the ip source
> - but the routing cache contains it.
>=20
> so my first question is: why routing cache has it and routing cache
> not? what it its usage?
> Then my second question: the meaning of fl.nl_u.ip4_u.saddr =3D 0
>=20
> thank you very much

# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
qlen 1000 txqueues 4=20
    link/ether f4:ce:46:bb:32:d4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.108/24 brd 192.168.20.255 scope global eth1
    inet6 fe80::f6ce:46ff:febb:32d4/64 scope link=20
       valid_lft forever preferred_lft forever
# ip addr add 192.168.20.67/24 dev eth1
# ip addr show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
qlen 1000 txqueues 4=20
    link/ether f4:ce:46:bb:32:d4 brd ff:ff:ff:ff:ff:ff
    inet 192.168.20.108/24 brd 192.168.20.255 scope global eth1
    inet 192.168.20.67/24 scope global secondary eth1
    inet6 fe80::f6ce:46ff:febb:32d4/64 scope link=20
       valid_lft forever preferred_lft forever
# ip ro
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.108=20
default via 192.168.20.254 dev eth1=20

# ip ro flush cache
# ip ro flush cache
# ip ro get 192.168.20.110
192.168.20.110 dev eth1  src 192.168.20.108=20
    cache  mtu 1500 advmss 1460 hoplimit 64
# ip ro get 192.168.20.110 from 192.168.20.67
192.168.20.110 from 192.168.20.67 dev eth1=20
    cache  mtu 1500 advmss 1460 hoplimit 64
# ip ro list cache
192.168.20.110 dev eth1  src 192.168.20.108=20
    cache  mtu 1500 advmss 1460 hoplimit 64
192.168.20.110 from 192.168.20.67 dev eth1=20
    cache  mtu 1500 advmss 1460 hoplimit 64

You can see two different routes in cache to reach 192.168.20.110,
one from "0.0.0.0" (we force src 192.168.20.108),
one from 192.168.20.67=20

With different keys (src addr, tos, fwmark, ...) we can have a lot of
different routes for apparently same destination


