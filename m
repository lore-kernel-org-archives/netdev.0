From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 21 May 2009 13:55:15 -0300
Message-ID: <20090521165515.GK5956@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <469958e00905210938s371b5dect28c7b1f8bb751ad1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Caitlin Bestler <caitlin.bestler@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44710 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752720AbZEUQzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 12:55:19 -0400
Content-Disposition: inline
In-Reply-To: <469958e00905210938s371b5dect28c7b1f8bb751ad1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, May 21, 2009 at 09:38:47AM -0700, Caitlin Bestler escreveu:
> > +
> > + =A0 =A0 =A0 while (datagrams < vlen) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __sys_recvmsg(sock, (struct m=
sghdr __user *)entry, flags);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __put_user(err, &entry->msg_l=
en);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++entry;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++datagrams;
> > + =A0 =A0 =A0 }
> > =A0out_put:
> > =A0 =A0 =A0 =A0fput_light(sock->file, fput_needed);
> > =A0out:
> > + =A0 =A0 =A0 /*
> > + =A0 =A0 =A0 =A0* We may return less entries than requested (vlen)=
 if the
> > + =A0 =A0 =A0 =A0* sock is non block and there aren't enough datagr=
ams.
> > + =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 if (err =3D=3D 0 || (err =3D=3D -EAGAIN && (flags & M=
SG_DONTWAIT)))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return datagrams;
> > =A0 =A0 =A0 =A0return err;
> > =A0}
> >
=20
> There is an assumption here that unless MSG_DONTWAIT is set, or there
> is an error, that the caller will be willing to wait indefinitely for
> N messages to show up -- and that it is never worth waking up the
> caller earlier with less than N messages.
=20
> I think an application would more typically want to wait at most m
> msecs after the first message is received to see if any other message=
s
> can be delivered at the same time.

> A busy server could simply use DONTWAIT in a polling loop every cycle=
,
> but it would be nice to be able to wait indefinitely for *any* of you=
r
> clients to send you a message.
=20
> Further, with some sockets there are some messages that are more equa=
l
> than others.

> Although valid messages, with no errors, they should be delivered to
> user-mode immediately.

> The example that leaps to my mind immediately are SCTP Events,
> particularly with one-to-many sockets. You could be waiting for N
> messages, knowing that a specific peer has been asked to send N
> messages. The 2nd message could be an SCTP event announcing that the
> specific association has been torn down (and hence the remaining
> messages will not be arriving).  Waiting for a different association
> to send enough messages to complete the request will not provide very
> prompt service.

Good points, that will require some sort of change to sk->sk_rcvtimeo
handling so that the timeout for each datagram are deduced from the
configured timeout for the socket, so that the existing code doesn't
have to be changed.

I.e. recvmmsg would save the value of sk->sk_rcvtimeo at entry and
restore at exit, and would somehow go on subtracting the time
sock_recvmsg() took from it so that the following call finds a reduced
sk->sk_rcvtimeo iif it was configured in the first place and the socket
is in blocking mode.

How does that sound?

- Arnaldo
