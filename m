From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: avoid cwnd moderation in undo
Date: Tue, 15 Mar 2011 17:34:56 -0700
Message-ID: <AANLkTinzkJKb9EtOys2EOW8SDnORdEOT=+UMNBACTJJe@mail.gmail.com>
References: <1299894051-13820-1-git-send-email-ycheng@google.com>
 <201103141106.19679.carsten@wolffcarsten.de> <AANLkTimra1e-ONMx2hTeN90HFEvxqb3jPAr4v9_C+9wR@mail.gmail.com>
 <201103151107.35379.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:54032 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094Ab1CPAfT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 20:35:19 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p2G0ZHQj018405
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 17:35:17 -0700
Received: from vxc11 (vxc11.prod.google.com [10.241.33.139])
	by wpaz24.hot.corp.google.com with ESMTP id p2G0Z6KH023843
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 17:35:16 -0700
Received: by vxc11 with SMTP id 11so1364348vxc.37
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 17:35:16 -0700 (PDT)
In-Reply-To: <201103151107.35379.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 15, 2011 at 3:07 AM, Carsten Wolff <carsten@wolffcarsten.de=
> wrote:
>
> Hi,
>
> On Monday 14 March 2011, Yuchung Cheng wrote:
> > On Mon, Mar 14, 2011 at 3:06 AM, Carsten Wolff <carsten@wolffcarste=
n.de>
> wrote:
> > In the presence of reordering, cwnd is already moderated in Disorde=
r
> > state before
> > =A0entering the (false) recovery.
>
> Sure, cwnd moderation to in_flight + 1 segment is applied in disorder=
 state,

it's in_flight + 3 usually. the moderation first happens
tcp_try_to_open() instead of tcp_cwnd_down()

>
> because this is implementing a form of extended limited transmit.
> Nevertheless, after a reordering event that caused a spurious fast re=
transmit,
> there can be an undo of congestion state changes (either after recove=
ry or
> interrupting recovery, depending on the options enabled in the connec=
tion). I
> just wanted to point out, that the moderation step happening upon an =
undo may
> allow a larger burst, if a previous reordering event was detected and=
 caused
> tp->reordering to be increased.

Your point is that cwnd should be moderated on reordering (in undo or
other events). Point taken.
=A0My point is that cwnd does not need to be moderated on false
recoveries. Do you agree?
To implement your design, tcp_update_reordering should do
tcp_cwnd_moderation().
To implement my point, the moderations should be avoided in undo operat=
ions.

The two aren't in conflict. But there are cases that have both undo
and reordering.
Are we on the same page?

>
> > > More importantly, the prior ssthresh is restored and not affected=
 by
> > > moderation. This means, if moderation reduces cwnd to a small val=
ue, then
> > > cwnd < ssthresh and TCP will quickly slow-start back to the previ=
ous
> > > state, without sending a big burst of segments.
>
> This is actually the more important point, because it means that the
> moderation does not negate the effects of the undo operation, as sugg=
ested by
> your patch-description.

It's a double-edge sword. Why slow-start if there is no real loss? It
hurts short
request-response type=A0traffic performance badly b/c each undo makes c=
wnd =3D 3.
>
> False fast retransmits are mostly caused by reordering, spurious RTOs=
 can also
> be caused by delay variations that do not exhibit reordering. Your pa=
tch
> touches all cases of spurious events. Anyway, I just mentioned reorde=
ring,
> because it is the event in which Linux already allows larger bursts o=
f size
> tp->reordering in the moderation function (i.e. tp->reordering might =
be
> increased). It's also not important to me if the undo is happening du=
ringor
> after recovery, the important question is, if burst protection in gen=
eral is
> an important goal, or not (and I think it's there for a reason).
I am hoping my previous explanation make sense to you (these two points=
 are
not in conflict).
