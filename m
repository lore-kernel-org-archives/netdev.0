From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 07:48:24 +0200
Message-ID: <1285566504.2357.549.camel@edumazet-laptop>
References: <20100926225440.GH12373@1wt.eu>
	 <20100926.160838.246540910.davem@davemloft.net>
	 <20100926232530.GK12373@1wt.eu>
	 <20100926.181202.28824153.davem@davemloft.net>
	 <20100927053901.GL12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36236 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757653Ab0I0Fs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 01:48:29 -0400
Received: by wyb28 with SMTP id 28so3526675wyb.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 22:48:27 -0700 (PDT)
In-Reply-To: <20100927053901.GL12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 07:39 +0200, Willy Tarreau a =C3=A9cr=
it :
> On Sun, Sep 26, 2010 at 06:12:02PM -0700, David Miller wrote:
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Mon, 27 Sep 2010 01:25:30 +0200
> >=20
> > > Agreed. But that's not a reason for killing outgoing data that is
> > > being sent when there are some data left in the rcv buffer.
> >=20
> > What alternative notification to the peer do you suggest other than=
 a
> > reset, then?  TCP gives us no other.
>=20
> I know, and I agree to send the reset, but after the data are correct=
ly
> transferred. This reset's purpose is only to inform the other side th=
at
> the data it sent were destroyed. It is not a requirement to tell it t=
hey
> were destroyed earlier or later. What matters is that it's informed t=
hey
> were destroyed.
>=20
> That's why I think that it is perfectly reasonable to either destroy =
them
> after the ACK or simply notify about their destruction after the ACK.
>=20
> Instead of having :
>=20
>         A                                               B
>=20
>        --->     <SEQ=3D100><ACK=3D300>                     --->
>        <---     <SEQ=3D300><ACK=3D100><DATA=3D10>            <---
>        --->     <SEQ=3D100><ACK=3D310>                     --->
>        send(100)
>        shutdown()
>        close()
>        --->     <SEQ=3D100><CTL=3DRST>                     --->
>=20
> We would just have :
>=20
>         A                                               B
>=20
>        --->     <SEQ=3D100><ACK=3D300>                     --->
>        <---     <SEQ=3D300><ACK=3D100><DATA=3D10>            <---
>        --->     <SEQ=3D100><ACK=3D310>                     --->
>        send(100)
>        shutdown()
>        close()
>        --->     <SEQ=3D100><ACK=3D310><DATA=3D100><CTL=3DFIN>  --->
>        <---     <SEQ=3D300><ACK=3D111>                     <---
>        --->     <SEQ=3D111><CTL=3DRST>                     --->
>=20
> Note that the notification is exactly the same as if we wanted
> to notify B about the destruction of data that were sent just
> after the close, because the RST only carries a SEQ field and
> no ACK indicating what it destroyed :
>=20
>         A                                               B
>=20
>        --->     <SEQ=3D100><ACK=3D300>                     --->
>        send(100)
>        shutdown()
>        --->     <SEQ=3D100><ACK=3D310><DATA=3D100><CTL=3DFIN>  --->
>        <---     <SEQ=3D300><ACK=3D111><DATA=3D10>            <---
>        close()
>        --->     <SEQ=3D111><CTL=3DRST>                     --->
>=20
> In my opinion, last two examples are perfectly valid, they just mean
> "after that, I close and don't want to hear about you again".
>=20
> > That's the thing, data integrity is full duplex, thus once it has b=
een
> > compromised in one direction everything currently in flight must be
> > zapped.
>=20
> I'm well aware of that, and even though that's an annoying method, we
> must live with it, it's probably one of the things that contribute TC=
P
> its well known reliability. But I think that RFC 2525 abused the TCP
> use based on traces showing a bad behaviour and overlooked all impact=
s
> (nothing there talks about the case of data being sent or in flight a=
t
> the moment of the close).

If you can cook a patch that makes sure the RST is sent, just do so.

Your previous attempt was wrong, since the RST was sent only if client
sent "req3".

If it sent "req1", "req2" only, req2 was unread and still no RST sent.

This is an RFC violation.

Its a bit tricky, because you cannot send the FIN flag on the last
segment, but have to wait for the final ACK coming from client, to
finally send an RST.



