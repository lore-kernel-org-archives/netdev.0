From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 08:04:45 +0200
Message-ID: <20100927060445.GO12373@1wt.eu>
References: <20100926225440.GH12373@1wt.eu> <20100926.160838.246540910.davem@davemloft.net> <20100926232530.GK12373@1wt.eu> <20100926.181202.28824153.davem@davemloft.net> <20100927053901.GL12373@1wt.eu> <1285566504.2357.549.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45716 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752610Ab0I0GEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 02:04:49 -0400
Content-Disposition: inline
In-Reply-To: <1285566504.2357.549.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 27, 2010 at 07:48:24AM +0200, Eric Dumazet wrote:
> Le lundi 27 septembre 2010 =E0 07:39 +0200, Willy Tarreau a =E9crit :
> > On Sun, Sep 26, 2010 at 06:12:02PM -0700, David Miller wrote:
> > > From: Willy Tarreau <w@1wt.eu>
> > > Date: Mon, 27 Sep 2010 01:25:30 +0200
> > >=20
> > > > Agreed. But that's not a reason for killing outgoing data that =
is
> > > > being sent when there are some data left in the rcv buffer.
> > >=20
> > > What alternative notification to the peer do you suggest other th=
an a
> > > reset, then?  TCP gives us no other.
> >=20
> > I know, and I agree to send the reset, but after the data are corre=
ctly
> > transferred. This reset's purpose is only to inform the other side =
that
> > the data it sent were destroyed. It is not a requirement to tell it=
 they
> > were destroyed earlier or later. What matters is that it's informed=
 they
> > were destroyed.
> >=20
> > That's why I think that it is perfectly reasonable to either destro=
y them
> > after the ACK or simply notify about their destruction after the AC=
K.
> >=20
> > Instead of having :
> >=20
> >         A                                               B
> >=20
> >        --->     <SEQ=3D100><ACK=3D300>                     --->
> >        <---     <SEQ=3D300><ACK=3D100><DATA=3D10>            <---
> >        --->     <SEQ=3D100><ACK=3D310>                     --->
> >        send(100)
> >        shutdown()
> >        close()
> >        --->     <SEQ=3D100><CTL=3DRST>                     --->
> >=20
> > We would just have :
> >=20
> >         A                                               B
> >=20
> >        --->     <SEQ=3D100><ACK=3D300>                     --->
> >        <---     <SEQ=3D300><ACK=3D100><DATA=3D10>            <---
> >        --->     <SEQ=3D100><ACK=3D310>                     --->
> >        send(100)
> >        shutdown()
> >        close()
> >        --->     <SEQ=3D100><ACK=3D310><DATA=3D100><CTL=3DFIN>  --->
> >        <---     <SEQ=3D300><ACK=3D111>                     <---
> >        --->     <SEQ=3D111><CTL=3DRST>                     --->
> >=20
> > Note that the notification is exactly the same as if we wanted
> > to notify B about the destruction of data that were sent just
> > after the close, because the RST only carries a SEQ field and
> > no ACK indicating what it destroyed :
> >=20
> >         A                                               B
> >=20
> >        --->     <SEQ=3D100><ACK=3D300>                     --->
> >        send(100)
> >        shutdown()
> >        --->     <SEQ=3D100><ACK=3D310><DATA=3D100><CTL=3DFIN>  --->
> >        <---     <SEQ=3D300><ACK=3D111><DATA=3D10>            <---
> >        close()
> >        --->     <SEQ=3D111><CTL=3DRST>                     --->
> >=20
> > In my opinion, last two examples are perfectly valid, they just mea=
n
> > "after that, I close and don't want to hear about you again".
> >=20
> > > That's the thing, data integrity is full duplex, thus once it has=
 been
> > > compromised in one direction everything currently in flight must =
be
> > > zapped.
> >=20
> > I'm well aware of that, and even though that's an annoying method, =
we
> > must live with it, it's probably one of the things that contribute =
TCP
> > its well known reliability. But I think that RFC 2525 abused the TC=
P
> > use based on traces showing a bad behaviour and overlooked all impa=
cts
> > (nothing there talks about the case of data being sent or in flight=
 at
> > the moment of the close).
>=20
> If you can cook a patch that makes sure the RST is sent, just do so.
>=20
> Your previous attempt was wrong, since the RST was sent only if clien=
t
> sent "req3".
>=20
> If it sent "req1", "req2" only, req2 was unread and still no RST sent=
=2E
>=20
> This is an RFC violation.

OK now I see your point and you're right. However, req3 is not required
in my tests. The simple fact of acknowledging the response causes the
RST to be emitted. However, if the client sends the FIN first, then it'=
s
true that there won't be an RST.

> Its a bit tricky, because you cannot send the FIN flag on the last
> segment, but have to wait for the final ACK coming from client, to
> finally send an RST.

Yes, that's what I was initially looking for then I thought its was
OK to send the FIN too, but you're right, we don't want to send it
if the client had already sent one, otherwise it won't be informed
about the error.

So basically that means not to send the FIN when in CLOSE_WAIT or
LAST_ACK with unread data so that we can send it to the client once
it ACKs our data.

I'll think about it, thanks for the brainstorming.

Willy

