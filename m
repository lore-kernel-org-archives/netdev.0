From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 'tcp: bind() fix when many ports are bound' problem
Date: Tue, 04 Jan 2011 12:22:52 +0100
Message-ID: <1294140172.3579.81.camel@edumazet-laptop>
References: <AANLkTimrpZOWEc5qXPEbrJbt2Nmh2vY69aC1Dwf1cCPH@mail.gmail.com>
	 <AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Baluta <daniel.baluta@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:60028 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1ADLW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 06:22:56 -0500
Received: by wwi17 with SMTP id 17so14731335wwi.1
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 03:22:55 -0800 (PST)
In-Reply-To: <AANLkTinNcds1EAnWXOX6wAjg+wv4O=Xd65hHEGWoGos8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 13:12 +0400, Gaspar Chilingarov a =C3=A9=
crit :
> Hi there!
>=20
> Well, that looks strange.
>=20
> On my own side I've just put workaround (manually binding to all port=
s
> in sequence :)
> and moved production code to FreeBSD as it has better scalable networ=
k stack.
>=20
> I can see the potential problem with that bind() problem on highly
> loaded DNS servers/resolvers which establish tons of outgoing UDP
> connections.
>=20
> In some cases that connections could fail and as not receiving the
> answer it is normal condition for DNS this will go totally unnoticed.
>=20
> I don't think anyone will hit this bug in production environment
> except the very high load applications.

Dont mix TCP and UDP, they are not the same.

Problem with TCP is you can have TIME_WAIT sockets, disallowing a port
to be reused. Not with UDP.

The connect() [without a previous bind()], or a sendto() [without a
previous bind()] problem is more an API problem.

When kernel autobinds an UDP socket [to get a local IP/port], there is =
a
problem on the selection of the local address : It must be ANY_ADDR
(0.0.0.0)

While for TCP, the IP address wont change for the whole session.
Problem is : The port can really be random, while the local address
comes from routing tables. To reach one destination, we usually use one
pref IP address, even if many are available.

If you dont bind() a socket before sending an UDP frame, kernel cannot
assume the local IP address wont change later (for other sent frames, i=
f
routing takes another path), so must use the ANY address for the port
selection done in autobind. Max 2^16-1 choices.

If you have 100 IP addresses on your machine, it doesnt change this ANY
selection [for UDP] at all.

If you need more than 2^16 local endpoints and you have more than one
external IP address, the only portable way is to use bind() yourself an=
d
manage a pool of [tuples]. Well, this is not true for some old OSes
(Solaris 2.5.1 comes to mind with TCP sockets)



