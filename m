From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question regarding expected behavior of two udp sockets with
 SO_REUSEADDR set
Date: Sat, 20 Nov 2010 05:06:55 +0100
Message-ID: <1290226015.2756.14.camel@edumazet-laptop>
References: <20101120004847.GA2590@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35110 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251Ab0KTEHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 23:07:00 -0500
Received: by wyb28 with SMTP id 28so5182376wyb.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 20:06:59 -0800 (PST)
In-Reply-To: <20101120004847.GA2590@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 19:48 -0500, Neil Horman a =C3=A9cr=
it :
> Hey all-
>=20
> 	Got a question regarding expected/desired behavior of $SUBJECT
>=20
>=20
> I have a report of a problem with a program that opens two sockets:
>=20
> The first socket is UDP and binds to 127.0.0.1 on a randomly selected=
 port
>=20
> The second socket is UDP and calls connect, sending to the first sock=
et
>=20
> Both sockets are part of the same process and have SO_REUSEADDR set
>=20
> After the connect the second socket sends a message to the first sock=
et.  The
> first socket waits for the message by calling select().
>=20
> Its observed that occasionally the first socket fails to receive the =
message,
> which is odd, given that the system is unloaded, and this is the only=
 message
> being sent.  A little investigation shows that when this happens, the=
 client and
> the server wind up bound to the same port.
>=20
> This happens because the second socket calls inet_autobind during the=
 connect
> call, and since both it and the server have SO_REUSEADDR set, it is p=
ossible
> that the autobind will select the same port that the first socket is =
bound to.
> When this happens the sendmsg path can get confused.  Specifically, w=
hen the skb
> is delivered to the destination socket, the hash lookup might find th=
e wrong
> entry and enqueue the skb to the second socket instead of the first.
>=20
> Questions:
>=20
> 1) Is that expected?
>=20

Is SO_REUSADDR used on both sockets ?

May I ask why SO_REUSEADDR is set in the first place on UDP sockets ?

I use it before a bind() on a given port (non null), but apparently you=
r
program doesnt bind() the 2nd socket before its connect() ?


> 2) If not, what do you think the best way to fix it is?
>=20
> 	a) Deny autobinds to the same port when SO_REUSEADDR is set, but all=
ow
> explicity binds to the same port?
>=20
> 	b) Deny both autobinds and explicit binds to the same port/addr,
> effectively disablind SO_REUSEADDR with UDP, kind of like with listen=
ing TCP
> sockets
>=20
> 	c) Add magic to udp_rcv to detect skbs originating from local socket=
s,
> and _dont_ deliver to the socket it originated from

Why ? Its a valid use case IMHO, even with a single socket.

>=20
> I'm inclined to say, no this is not expected behavior, and that we sh=
ould fix it
> with option A, but I'm interested in getting other opinions before I =
go down any
> particular path.
>=20

autobind certainly is a problem, we tried to 'fix' it in recent past an=
d
had to revert some patches. We tried to allow more sockets to be used
but we failed.



