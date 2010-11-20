From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Question regarding expected behavior of two udp sockets with
 SO_REUSEADDR set
Date: Sat, 20 Nov 2010 10:04:41 -0500
Message-ID: <20101120150441.GA17907@hmsreliant.think-freely.org>
References: <20101120004847.GA2590@hmsreliant.think-freely.org>
 <1290226015.2756.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51813 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab0KTPId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 10:08:33 -0500
Content-Disposition: inline
In-Reply-To: <1290226015.2756.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 20, 2010 at 05:06:55AM +0100, Eric Dumazet wrote:
> Le vendredi 19 novembre 2010 =E0 19:48 -0500, Neil Horman a =E9crit :
> > Hey all-
> >=20
> > 	Got a question regarding expected/desired behavior of $SUBJECT
> >=20
> >=20
> > I have a report of a problem with a program that opens two sockets:
> >=20
> > The first socket is UDP and binds to 127.0.0.1 on a randomly select=
ed port
> >=20
> > The second socket is UDP and calls connect, sending to the first so=
cket
> >=20
> > Both sockets are part of the same process and have SO_REUSEADDR set
> >=20
> > After the connect the second socket sends a message to the first so=
cket.  The
> > first socket waits for the message by calling select().
> >=20
> > Its observed that occasionally the first socket fails to receive th=
e message,
> > which is odd, given that the system is unloaded, and this is the on=
ly message
> > being sent.  A little investigation shows that when this happens, t=
he client and
> > the server wind up bound to the same port.
> >=20
> > This happens because the second socket calls inet_autobind during t=
he connect
> > call, and since both it and the server have SO_REUSEADDR set, it is=
 possible
> > that the autobind will select the same port that the first socket i=
s bound to.
> > When this happens the sendmsg path can get confused.  Specifically,=
 when the skb
> > is delivered to the destination socket, the hash lookup might find =
the wrong
> > entry and enqueue the skb to the second socket instead of the first=
=2E
> >=20
> > Questions:
> >=20
> > 1) Is that expected?
> >=20
>=20
> Is SO_REUSADDR used on both sockets ?
>=20
Yes, both udp sockets have SO_REUSEADDR set on them

> May I ask why SO_REUSEADDR is set in the first place on UDP sockets ?
>=20
Honestly, I don't know.  This was reported to me as part of:
https://bugzilla.redhat.com/show_bug.cgi?id=3D643911
At first the consensus was that this bug was fixed by your patch series=
 that
adds a secondary hash for udp sockets, but on closer inspection it appe=
ars that
this is just a case of what I described above.  Specifically, that two =
sockets
are inadvertently binding to the same port/address, and as such when so=
meone
sends from socket A to socket B, A is actually the socket that receives=
 the
frame rather than socket B (as the program might have intended).

> I use it before a bind() on a given port (non null), but apparently y=
our
> program doesnt bind() the 2nd socket before its connect() ?
>=20
Correct, the second socket is autobound, via inet_autobind as called fr=
om
connect(), which we call on the second udp socket.  When that happens t=
he socket
is bound to a random port.  But sometimes if the socket has SO_REUSEADD=
R set it
winds up binding to the same port that the first socket is bound to, re=
sulting
in the above problem.

>=20
> > 2) If not, what do you think the best way to fix it is?
> >=20
> > 	a) Deny autobinds to the same port when SO_REUSEADDR is set, but a=
llow
> > explicity binds to the same port?
> >=20
> > 	b) Deny both autobinds and explicit binds to the same port/addr,
> > effectively disablind SO_REUSEADDR with UDP, kind of like with list=
ening TCP
> > sockets
> >=20
> > 	c) Add magic to udp_rcv to detect skbs originating from local sock=
ets,
> > and _dont_ deliver to the socket it originated from
>=20
> Why ? Its a valid use case IMHO, even with a single socket.
>=20
> >=20
> > I'm inclined to say, no this is not expected behavior, and that we =
should fix it
> > with option A, but I'm interested in getting other opinions before =
I go down any
> > particular path.
> >=20
>=20
> autobind certainly is a problem, we tried to 'fix' it in recent past =
and
> had to revert some patches. We tried to allow more sockets to be used
> but we failed.
>=20
Agreed.  My thought was to add logic to udp_lib_lport_inuse such that, =
if
sk_reuse is set on both sockets, and the input snum is 0 (indicating au=
tobind)
we should not allow binding sk to inet_sk(sk2)->num.  Thoughts?
Neil

>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
