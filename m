From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Fri, 11 Feb 2011 16:10:50 -0800
Message-ID: <AANLkTiktBOC_26Aox8LVjPCTh33Gztd7RvA-kQVdih=h@mail.gmail.com>
References: <1297119424-19956-1-git-send-email-ycheng@google.com>
 <20110207.150522.28821840.davem@davemloft.net> <alpine.DEB.2.00.1102080112450.29228@melkinpaasi.cs.helsinki.fi>
 <AANLkTikh4YXzJGgTWsTjpz6BczrfSGYD_qSg3WWmKrs9@mail.gmail.com> <alpine.DEB.2.00.1102081110050.26191@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:52357 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab1BLALO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 19:11:14 -0500
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p1C0BDeW006268
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 16:11:13 -0800
Received: from vws9 (vws9.prod.google.com [10.241.21.137])
	by kpbe20.cbf.corp.google.com with ESMTP id p1C0AmI7030140
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 16:11:11 -0800
Received: by vws9 with SMTP id 9so2081795vws.27
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 16:11:11 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102081110050.26191@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 8, 2011 at 1:54 AM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
>
> On Mon, 7 Feb 2011, Yuchung Cheng wrote:
>
> > On Mon, Feb 7, 2011 at 3:36 PM, Ilpo J=E4rvinen <ilpo.jarvinen@hels=
inki.fi> wrote:
> > >
> > > On Mon, 7 Feb 2011, David Miller wrote:
> > >
> > > > From: Yuchung Cheng <ycheng@google.com>
> > > > Date: Mon, =A07 Feb 2011 14:57:04 -0800
> > > >
> > > > > Fix a bug that undo_retrans is incorrectly decremented when u=
ndo_marker is
> > > > > not set or undo_retrans is already 0. This happens when sende=
r receives
> > > > > more DSACK ACKs than packets retransmitted during the current
> > > > > undo phase. This may also happen when sender receives DSACK a=
fter
> > > > > the undo operation is completed or cancelled.
> > > > >
> > > > > Fix another bug that undo_retrans is incorrectly incremented =
when
> > > > > sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). =
This case
> > > > > is rare but not impossible.
> > > > >
> > > > > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> > >
> > > Neither is harmful to "fix" but I think they're partially also ch=
ecking
> > > for things which shouldn't cause problems... E.g., undo_retrans i=
s only
> > > used after checking undo_marker's validity first so I don't think
> > > undo_marker check is exactly necessary there (but on the other ha=
nd it
> > > does no harm)...
> >
> > logically we should check the validity of undo_marker/undo_retrans
> > before we use them? The current code has no problem if
> > tcp_fastretrans_alert() always call tcp_try_undo_* =A0functions whe=
never
> > undo_marker !=3D 0 and undo_retrans =3D=3D 0. I don't think that's =
always
> > true.
>
> We certainly should be letting the undo_retrans to underflow that in =
this
> your patch has merit (the added tp->undo_retrans check).
>
> However, the only users are:
>
> static inline int tcp_may_undo(struct tcp_sock *tp)
> {
> =A0 =A0 =A0 =A0 return tp->undo_marker && (!tp->undo_retrans ...)
>
> and:
>
> static void tcp_try_undo_dsack(struct sock *sk)
> {
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
>
> =A0 =A0 =A0 =A0if (tp->undo_marker && !tp->undo_retrans) {
>
>
> ...which check that undo_retrans is valid.
>
> > > The tcp_retransmit_skb problem I don't understand at all as we sh=
ould be
> > > fragmenting or resetting pcount to 1 (the latter is true only if =
all
> > > bugfixes were included to the kernel where >1 pcount for a rexmit=
ted skb
> > > was seen). If pcount is indeed >1 we might have other issues too =
somewhere
> >
> > We found that sometimes pcount > 1 on real servers. This change kee=
ps
> > the retrans_out/undo_retrans counters consistent.
>
> There's still some bug then I guess... It might be related to the iss=
ues
> seen by those other guys who were complaining about small segments wi=
th
> >1 pcount breaking their hardware (few months ago). For the record, t=
he
> last fix is from 2.6.31 or so.
>
> Like I said, I don't oppose this change anyway:
>
> > > but I fail to remember immediately what they would be. That chang=
e is not
> > > bad though since using +/-1 is something we should be getting rid=
 of
> > > anyway and on long term it would be nice to make tcp_retransmit_s=
kb to be
> > > able to take advantage of TSO anyway whenever possible.
>
> ...it certainly won't hurt to be on the safe side here if/when someth=
ing
> else is wrong.
>
> > > I also noticed that the undo_retrans code in sacktag side is stil=
l doing
> > > undo_retrans-- ops which could certainly cause real miscounts, th=
ough
> > > it is extremely unlikely due to the fact that DSACK should be sen=
t
> > > immediately for a single segment at a time (so the sender would n=
eed to
> > > split+recollapse in between).
> >
> > I have the same doubt but our servers never hit this condition (pco=
unt
> > 1). So I keep this part intact.
>
> I could think of some scenario you cannot even reproduce in a large s=
cale
> tests, unlikely indeed :-). ...Or too stable connectivity on the send=
er
> side. But I've changed my mind... the -1 operation is the correct one=
 as
> we could otherwise overestimate due to pcount=3D1->2 split after the
> retransmission that triggered the DSACK (now that I remember this, I =
think
> I've once thought this line through already earlier... I'll try to wr=
ite a
> comment one day there).
>
> For -rc/next purposes I don't see any big enough reasons to withhold:
>
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>
> ...but if you want this to stables too I don't think it's minimal w.r=
=2Et.
> undo_marker check.
>

Dave/Ilpo: can this patch get applied or it needs more
clarification/justification? Thanks.


Yuchung
