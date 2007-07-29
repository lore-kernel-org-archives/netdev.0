From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Sun, 29 Jul 2007 18:07:22 +0200
Message-ID: <20070729160721.GA31276@1wt.eu>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu> <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi> <20070729085427.GA22784@1wt.eu> <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Darryl L. Miles" <darryl-mailinglists@netbauds.net>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4063 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762613AbXG2QHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 12:07:31 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 29, 2007 at 12:28:04PM +0300, Ilpo J=E4rvinen wrote:
(...)
> > > Limitation for 48 byte segments? You have to be kidding... :-) Bu=
t yes,
> > > it seems that one of the directions is dropping packets for some =
reason=20
> > > though I would not assume MTU limitation... Or did you mean some =
other=20
> > > segment?
> >=20
> > No, I was talking about the 1448 bytes segments. But in fact I don'=
t
> > believe it much because the SACKs are always retransmitted just aft=
erwards.
>=20
> Ah, but it's ACKed correctly right below it...:
>=20
> [...snip...]
> > > > > 09:21:39.490740 IP SERVER.ssh > CLIENT.50727: P 18200:18464(2=
64) ack 2991=20
> > > > > win 2728 <nop,nop,timestamp 7692910 800001727>
> > > > > 09:21:39.490775 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win=
 378=20
> > > > > <nop,nop,timestamp 800001755 7692910>
> > > > > 09:21:39.860245 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1=
448) ack 2991=20
> > > > > win 2728 <nop,nop,timestamp 7693293 800001749>
>=20
> ...segment below snd_una arrived =3D> snd_una remains 18464, receiver=
=20
> generates a duplicate ACK:
> =20
> > > > > 09:21:39.860302 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win=
 378=20
> > > > > <nop,nop,timestamp 800001847 7692910,nop,nop,sack sack 1 {124=
08:13856} >
>=20
> The cumulative ACK field of it covers _everything_ below 18464 (i.e.,=
 it=20
> ACKs them), including the 1448 bytes in 12408:13856... In addition, t=
he=20
> SACK block is DSACK information [RFC2883] telling explicitly the addr=
ess=20
> of the received duplicate block. However, if this ACK doesn't reach t=
he=20
> SERVER TCP, RTO is triggered and the first not yet cumulatively ACKed=
=20
> segment is retransmitted (I guess cumulative ACKs up to 12408 arrived=
=20
> without problems to the SERVER):

Oh yes, you're damn right. I did not notice that the ACK was higher tha=
n
the SACK, I'm more used to read traces with absolute rather than relati=
ve
seq/acks.

So I agree, it is this ACK which is lost between client and server,
reinforcing the supposition about the location of the capture (client s=
ide).

> [...snip...]
>=20
> > BTW, some information are missing. It would have been better if the=
 trace
> > had been read with tcpdump -Svv. We would have got seq numbers and =
ttl.
> > Also, we do not know if there's a firewall between both sides. Some=
times,
> > some IDS identify attacks in crypted traffic and kill connections. =
It
> > might have been the case here, with the connection closed one way o=
n an
> > intermediate firewall.
>=20
> Yeah, firewall or some other issue, I'd say it's quite unlikely a bug=
 in=20
> TCP because behavior to both directions indicate client -> sender=20
> blackhole independently of each other...

It would also be possible that something stupid between both ends simpl=
y
drops packets with the SACK option set. Also something which sometimes
happen is that some firewalls automatically translate sequence numbers
but not necessarily SACK values, which could pretty well lead to this
packet being received but ignored on the server side.

I'm pretty sure that the same trace taken on the server side will revea=
l
the reason for the problem.

Willy

