From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Wed, 16 Mar 2011 17:18:38 +0100
Message-ID: <201103161718.39110.carsten@wolffcarsten.de>
References: <1299894051-13820-1-git-send-email-ycheng@google.com> <201103151107.35379.carsten@wolffcarsten.de> <AANLkTinzkJKb9EtOys2EOW8SDnORdEOT=+UMNBACTJJe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6022996.I0sTYRgpz7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev@vger.kernel.org,
	Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:46802 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab1CPQTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 12:19:15 -0400
In-Reply-To: <AANLkTinzkJKb9EtOys2EOW8SDnORdEOT=+UMNBACTJJe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart6022996.I0sTYRgpz7
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hi again,

On Wednesday 16 March 2011, Yuchung Cheng wrote:
> On Tue, Mar 15, 2011 at 3:07 AM, Carsten Wolff <carsten@wolffcarsten.de>=
=20
wrote:
> > Hi,
> >=20
> > On Monday 14 March 2011, Yuchung Cheng wrote:
> > > On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff
> > > <carsten@wolffcarsten.de>
> >=20
> > wrote:
> > > In the presence of reordering, cwnd is already moderated in Disorder
> > > state before
> > >  entering the (false) recovery.
> >=20
> > Sure, cwnd moderation to in_flight + 1 segment is applied in disorder
> > state,
>=20
> it's in_flight + 3 usually. the moderation first happens
> tcp_try_to_open() instead of tcp_cwnd_down()

In disorder state, tcp_try_to_open() calls tcp_cwnd_down() which clamps cwn=
d=20
to in_flight + 1 for dupacks (where tcp_packets_in_flight() is not to be=20
confused with the IN_FLIGHT variable in IETF documents, which is called=20
packets_out in Linux ...). Otherwise, Linux would be violating RFC3042, whi=
ch=20
allows to send one SMSS of data on each dupack before recovery (actually, j=
ust=20
the first two, but since the DupThresh can be larger than 3 in linux, it=20
extends Limited Transmit to more than just the first two dupacks). This is=
=20
mostly equivalent to the aggressive variant of extended limited transmit in=
=20
RFC4653.

> > because this is implementing a form of extended limited transmit.
> > Nevertheless, after a reordering event that caused a spurious fast
> > retransmit, there can be an undo of congestion state changes (either
> > after recovery or interrupting recovery, depending on the options
> > enabled in the connection). I just wanted to point out, that the
> > moderation step happening upon an undo may allow a larger burst, if a
> > previous reordering event was detected and caused tp->reordering to be
> > increased.
>=20
> Your point is that cwnd should be moderated on reordering (in undo or
> other events). Point taken.
>  My point is that cwnd does not need to be moderated on false
> recoveries. Do you agree?
> To implement your design, tcp_update_reordering should do
> tcp_cwnd_moderation().
> To implement my point, the moderations should be avoided in undo
> operations.
>=20
> The two aren't in conflict. But there are cases that have both undo
> and reordering.
> Are we on the same page?

Unfortunately, no. ;-) My point is, that cwnd should be moderated when the=
=20
congestion state changes are undone after a spurious recovery has been=20
detected. Reordering is only one possible reason for a false recovery. And =
I=20
stick to that point because of the thoughts I pointed out in my mail to joh=
n,=20
i.e. undo typically leading to exceptionally large segment bursts.

As for cwnd moderation upon the detection of a reordering event (that's a=20
different thing at a differnt point in time than detection of a false=20
recovery!): This wouldn't make sense to me. The detection of the reordering=
=20
event together with a metric that measures the extent of the reordering can=
 be=20
used to try and prevent false recoverys in future reordering events, by=20
delaying the congestion reaction (i.e. fast retransmit) then.

Reordering can be a cause of spurious recovery. But undo mechanisms and=20
mechanisms to prevent false recovery(s) are orthogonal.

Your patch touches all undos, while reordering is just an example for a cau=
se=20
of false recovery.

> > > > More importantly, the prior ssthresh is restored and not affected by
> > > > moderation. This means, if moderation reduces cwnd to a small value,
> > > > then cwnd < ssthresh and TCP will quickly slow-start back to the
> > > > previous state, without sending a big burst of segments.
> >=20
> > This is actually the more important point, because it means that the
> > moderation does not negate the effects of the undo operation, as
> > suggested by your patch-description.
>=20
> It's a double-edge sword. Why slow-start if there is no real loss?

Its a timing thing. I mean, it is an undo operation: the harm has been done=
,=20
some opportunity to send new data has been lost. Trying to send all that da=
ta=20
at once now without an ACK-clock will cause more harm when buffers are unde=
r=20
pressure. The undo operation should not try to make up for lost opportunity=
,=20
only try to reduce further loss of opportunity to send new data. For this, =
the=20
segment bursts have to be moderated.

> It
> hurts short
> request-response type traffic performance badly b/c each undo makes cwnd =
=3D
> 3.
>=20
> > False fast retransmits are mostly caused by reordering, spurious RTOs c=
an
> > also be caused by delay variations that do not exhibit reordering. Your
> > patch touches all cases of spurious events. Anyway, I just mentioned
> > reordering, because it is the event in which Linux already allows larger
> > bursts of size tp->reordering in the moderation function (i.e.
> > tp->reordering might be increased). It's also not important to me if the
> > undo is happening duringor after recovery, the important question is, if
> > burst protection in general is an important goal, or not (and I think
> > it's there for a reason).
>=20
> I am hoping my previous explanation make sense to you (these two points a=
re
> not in conflict).

I hope the same for my explanations. :-)

Cheers
Carsten
=2D-=20
           /\-=C2=B4-/\
          (  @ @  )
________o0O___^___O0o________

--nextPart6022996.I0sTYRgpz7
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQBNgOLf8elb1gg1f/QRAoxYAKCnFEMYSc1GnAa/bSrkKvmjW5zbQACfXJpd
Zs3OENMqBuC2uSBXFYGZags=
=5eBL
-----END PGP SIGNATURE-----

--nextPart6022996.I0sTYRgpz7--
