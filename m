From: mtk-lists@gmx.net
Subject: Re: shutdown() and SHUT_RD on TCP sockets - broken?
Date: Wed, 9 Jul 2003 12:11:19 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <27451.1057745479@www2.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, Andi Kleen <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Alexey and Andi,

[Alexey]

> > blocks.  I see that this also occurs on FreeBSD 4.8, Tru64 5.1B,
> > HP/UX 11 and Solaris 8.  Have I misunderstood Stevens,
>=20
> Most likely, it is that rare case when Stevens forgot to check the
> statement.

yes, it cerainly doesn't correspond to any current implementation=20
that I could find anyway. =20

I should of course have added that (as you are probably well aware) SUSv3=
 is

vague but does say:

SHUT_RD Disables further receive operations.

which suggest that we shouldn't be able to read any more.  It seems to me=
=20
that the only ways of satisfying that requirement are to either discard d=
ata

(a la Stevens) or send an RST to the writing peer (more on that in a mome=
nt)

so that it stops sending.

> From viewpoint of TCP the behaviour described in Stevens' book
> is highly unnatural. SHUT_RD on TCP does not make any sense.

A while back I had some communication with Andi Kleen on this point,
and he suggested that the TCP could send an RST in this case, much=20
as occurs if the reader close()s the socket.  Is this not a starter? =20
(Maybe not, for the reasons Andi outlined in his mail to this list -- quo=
ted

below.)

> > described here.  But, why do things happen in this way on Linux?
>=20
> Actually, you could check one more thing. What does happen after freebs=
d
> 4.8 returns 0 on read()? Does it open window eventually?

I'm not quite sure what you mean here.  Can you elaborate on the what=20
type of experiment I should perform and what you expect I might see?

[Andi]

> > 1. If we perform a read() on the socket and there is no data, then 0
> > (EOF) is (immediately) returned.  (This is what I expected.)
> >=20
> > 2. However, the peer can still write() to the socket, and afterwards =
we
> > can read() that data from the socket, even though the reading half of
the
> > socket should be shut down.  Instead of this behaviour, I expected th=
e
> > read() to continue to return 0 as in point 1.  This is what we see fo=
r
> > example in FreeBSD 4.8, Tru64 5.1B, and HP/UX 11. =20
>=20
> The problem is that it adds a new check to the input path. It's not cle=
ar
> how the check can be done outside the fast path (one way would be to
shrink
> the window forcedly and drop the receiver into slow path, but that woul=
d
be
> a severe protocol violation if the shrunk window leaks out with some AC=
K).
> I don't think it's a good idea to add a check for such an obscure
situation
> to the fast path.=20

Andi, I noted already your idea about delivering a RST in this case.  I
assume
the above is the practical reason that makes implementing this difficult?

> > 3. (A side point.) Looking at Stevens UNPv1, p161, there is a stateme=
nt=20
> > that after a SHUT_RD, "any data for a TCP socket is acknowledged and
then=20
> > silently discarded".  This implies to me that the sender could keep o=
n=20
> > writing to the socket and never block.  However, on Linux, if the pee=
r=20
> > keeps sending to a socket, then eventually (the channel is filled and=
)
it=20
> > blocks.  I see that this also occurs on FreeBSD 4.8, Tru64 5.1B, HP/U=
X
11
>=20
> That's because the data is not discarded so the window fills.=20

Yes,  I should perhaps have added that in the circumstances, blocking at
this=20
point is not surprising (to me).

> > and Solaris 8.  Have I misunderstood Stevens, or has something change=
d
> > since the implementation he described (or was his statement wrong)?  =
(In
>=20
> Probably Stevens was confused.

There seems to be a consensus emerging ;-).

Cheers,

Michael

--=20
+++ GMX - Mail, Messaging & more  http://www.gmx.net +++

Jetzt ein- oder umsteigen und USB-Speicheruhr als Pr=E4mie sichern!
