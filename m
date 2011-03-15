From: Carsten Wolff <carsten@wolffcarsten.de>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Tue, 15 Mar 2011 11:07:34 +0100
Message-ID: <201103151107.35379.carsten@wolffcarsten.de>
References: <1299894051-13820-1-git-send-email-ycheng@google.com> <201103141106.19679.carsten@wolffcarsten.de> <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1346787.stratoserver.net ([85.214.49.182]:42972 "EHLO
	h1346787.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829Ab1COKHu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:07:50 -0400
In-Reply-To: <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Monday 14 March 2011, Yuchung Cheng wrote:
> On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff <carsten@wolffcarsten.=
de>=20
wrote:
> > The moderation is in place to avoid gigantic segment bursts, which =
could
> > cause unnecessary pressure on buffers. In my eyes it's already
> > suboptimal that the moderation is weakened in the presence of (dete=
cted)
> > reordering, let alone removing it completely.
>=20
> In the presence of reordering, cwnd is already moderated in Disorder
> state before
>  entering the (false) recovery.

Sure, cwnd moderation to in_flight + 1 segment is applied in disorder s=
tate,=20
because this is implementing a form of extended limited transmit.=20
Nevertheless, after a reordering event that caused a spurious fast retr=
ansmit,=20
there can be an undo of congestion state changes (either after recovery=
 or=20
interrupting recovery, depending on the options enabled in the connecti=
on). I=20
just wanted to point out, that the moderation step happening upon an un=
do may=20
allow a larger burst, if a previous reordering event was detected and c=
aused=20
tp->reordering to be increased.

> > More importantly, the prior ssthresh is restored and not affected b=
y
> > moderation. This means, if moderation reduces cwnd to a small value=
, then
> > cwnd < ssthresh and TCP will quickly slow-start back to the previou=
s
> > state, without sending a big burst of segments.

This is actually the more important point, because it means that the=20
moderation does not negate the effects of the undo operation, as sugges=
ted by=20
your patch-description.

> > Also, you intended to remove cwnd moderation only from an undo duri=
ng
> > recovery, but I think your patch also removes cwnd moderation when =
the
> > undo is caused by D-SACK, i.e. most likely after recovery already e=
nded.
>=20
> Thanks. I will update my patch description. But the same principle
> applies that cwnd
> should not be moderated on false events. Whether it should be moderat=
ed on
> reordering or other events is another (complex) design issue. But thi=
s
> patch does not touch that.

=46alse fast retransmits are mostly caused by reordering, spurious RTOs=
 can also=20
be caused by delay variations that do not exhibit reordering. Your patc=
h=20
touches all cases of spurious events. Anyway, I just mentioned reorderi=
ng,=20
because it is the event in which Linux already allows larger bursts of =
size=20
tp->reordering in the moderation function (i.e. tp->reordering might be=
=20
increased). It's also not important to me if the undo is happening duri=
ngor=20
after recovery, the important question is, if burst protection in gener=
al is=20
an important goal, or not (and I think it's there for a reason).

Carsten
--=20
           /\-=C2=B4-/\
          (  @ @  )
________o0O___^___O0o________
