From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Mon, 7 Feb 2011 16:22:59 -0800
Message-ID: <AANLkTikh4YXzJGgTWsTjpz6BczrfSGYD_qSg3WWmKrs9@mail.gmail.com>
References: <1297119424-19956-1-git-send-email-ycheng@google.com>
 <20110207.150522.28821840.davem@davemloft.net> <alpine.DEB.2.00.1102080112450.29228@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:56125 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab1BHAXX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 19:23:23 -0500
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p180NLZt013163
	for <netdev@vger.kernel.org>; Mon, 7 Feb 2011 16:23:21 -0800
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by hpaq13.eem.corp.google.com with ESMTP id p180MKJO027061
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 7 Feb 2011 16:23:20 -0800
Received: by qwa26 with SMTP id 26so3900063qwa.0
        for <netdev@vger.kernel.org>; Mon, 07 Feb 2011 16:23:20 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102080112450.29228@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 7, 2011 at 3:36 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
>
> On Mon, 7 Feb 2011, David Miller wrote:
>
> > From: Yuchung Cheng <ycheng@google.com>
> > Date: Mon, =A07 Feb 2011 14:57:04 -0800
> >
> > > Fix a bug that undo_retrans is incorrectly decremented when undo_=
marker is
> > > not set or undo_retrans is already 0. This happens when sender re=
ceives
> > > more DSACK ACKs than packets retransmitted during the current
> > > undo phase. This may also happen when sender receives DSACK after
> > > the undo operation is completed or cancelled.
> > >
> > > Fix another bug that undo_retrans is incorrectly incremented when
> > > sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). This=
 case
> > > is rare but not impossible.
> > >
> > > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> >
> > Looks good, Ilpo could you please review this real quick?
>
> I already too a quick look so you're real lucky, only delay of writin=
g is
> needed... :-)
thanks.
>
> Neither is harmful to "fix" but I think they're partially also checki=
ng
> for things which shouldn't cause problems... E.g., undo_retrans is on=
ly
> used after checking undo_marker's validity first so I don't think
> undo_marker check is exactly necessary there (but on the other hand i=
t
> does no harm)...
logically we should check the validity of undo_marker/undo_retrans
before we use them? The current code has no problem if
tcp_fastretrans_alert() always call tcp_try_undo_*  functions whenever
undo_marker !=3D 0 and undo_retrans =3D=3D 0. I don't think that's alwa=
ys
true.

>
> The tcp_retransmit_skb problem I don't understand at all as we should=
 be
> fragmenting or resetting pcount to 1 (the latter is true only if all
> bugfixes were included to the kernel where >1 pcount for a rexmitted =
skb
> was seen). If pcount is indeed >1 we might have other issues too some=
where
We found that sometimes pcount > 1 on real servers. This change keeps
the retrans_out/undo_retrans counters consistent.

> but I fail to remember immediately what they would be. That change is=
 not
> bad though since using +/-1 is something we should be getting rid of
> anyway and on long term it would be nice to make tcp_retransmit_skb t=
o be
> able to take advantage of TSO anyway whenever possible.
>
> I also noticed that the undo_retrans code in sacktag side is still do=
ing
> undo_retrans-- ops which could certainly cause real miscounts, though
> it is extremely unlikely due to the fact that DSACK should be sent
> immediately for a single segment at a time (so the sender would need =
to
> split+recollapse in between).
I have the same doubt but our servers never hit this condition (pcount
> 1). So I keep this part intact.

>
> --
> =A0i.
