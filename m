From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
Date: Sat, 4 Feb 2012 13:15:03 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C9FCF6@EUSAACMS0702.eamcs.ericsson.se>
References: <1328300212-18836-1-git-send-email-shawn.lu@ericsson.com>
	 <1328304719.2480.5.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5C9FB94@EUSAACMS0702.eamcs.ericsson.se>
 <1328342816.2577.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:56282 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753209Ab2BDSPO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 13:15:14 -0500
In-Reply-To: <1328342816.2577.8.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric:

> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> I repeat my question :
>=20
> Why do you believe only RST should be handled in a different=20
> manner than other TCP messages ?
>=20
> If we decide to break asymmetric routing, we should do it=20
> completely and document it.
>=20
> It might already be broken for IPv6 and nobody cared / noticed.

RST is specical. if a packet caused RST, connection is gone.
We lost all socket option (or bind information) for that socket.
So we build reply only basing on parameters arrived with
The segement.  It's nature to use another one from segment: inet_iif(sk=
b).

In the same time, I agree with you that it breaks asymmetric routing.

It may be more propertly to do it when routing fails.
Will send out another patch to replace this patch.=20

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: Saturday, February 04, 2012 12:07 AM
> To: Shawn Lu
> Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
> Subject: RE: [PATCH] tcp: RST: binding oif to iif for tcp v4
>=20
> Le vendredi 03 f=E9vrier 2012 =E0 16:43 -0500, Shawn Lu a =E9crit :
>=20
> > [shawn Lu] ok.  Tcp socket is bind to device using=20
> SO_BINDTODEVICE  to=20
> > Limit traffic to specifc interface.  Sometime, it may not=20
> have a valid=20
> > Source address to get through ip_route_output_key.
> >=20
>=20
> Define "Sometime" ?
My case is in router. Forwarding is done in line card. Any packet that =
can't process by
=46orwarding(such as bgp) will "punt" to control plane(another box, we =
called RP). In RP,
routing is bypassed if packet is from line card, because we know it is =
target to
local. On egress path, we also need bind traffic to this interface to b=
e able to go back
To line card. In TCP case, when connection is gone, all binding informa=
tion is gone, we can't
=46igure out egress path depend only destination address.=20
But we still able to send it back if iif is used.=20
>=20
> We have to force the oif only if requested by the socket in this case=
=2E
>=20
> arg.bound_dev_if =3D sk ? sk->sk_bound_dev_if : 0;
>=20
> Thats what we do in tcp_v4_send_ack() :
> 	if (oif)
> 		arg.bound_dev_if =3D oif;
>=20
>=20
>=20
>=20
>=20
It won't work.  For RST, socket is gone. In most case, there is no sock=
et
Associated with it.  Only under one case (it fall in to listener that i=
s not bind to specifc
Address), we can only get sk_bound_dev_if from listener. In addition, i=
n this case,
The listener is most likely not bind to any interface to be able to get=
 connection
Request from all interface.
