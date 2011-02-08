From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Tue, 8 Feb 2011 11:54:37 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1102081110050.26191@melkinpaasi.cs.helsinki.fi>
References: <1297119424-19956-1-git-send-email-ycheng@google.com> <20110207.150522.28821840.davem@davemloft.net> <alpine.DEB.2.00.1102080112450.29228@melkinpaasi.cs.helsinki.fi> <AANLkTikh4YXzJGgTWsTjpz6BczrfSGYD_qSg3WWmKrs9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1137111006-1297158877=:26191"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49230 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab1BHJyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 04:54:39 -0500
In-Reply-To: <AANLkTikh4YXzJGgTWsTjpz6BczrfSGYD_qSg3WWmKrs9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1137111006-1297158877=:26191
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 7 Feb 2011, Yuchung Cheng wrote:

> On Mon, Feb 7, 2011 at 3:36 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > On Mon, 7 Feb 2011, David Miller wrote:
> >
> > > From: Yuchung Cheng <ycheng@google.com>
> > > Date: Mon,  7 Feb 2011 14:57:04 -0800
> > >
> > > > Fix a bug that undo_retrans is incorrectly decremented when undo_marker is
> > > > not set or undo_retrans is already 0. This happens when sender receives
> > > > more DSACK ACKs than packets retransmitted during the current
> > > > undo phase. This may also happen when sender receives DSACK after
> > > > the undo operation is completed or cancelled.
> > > >
> > > > Fix another bug that undo_retrans is incorrectly incremented when
> > > > sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). This case
> > > > is rare but not impossible.
> > > >
> > > > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> >
> > Neither is harmful to "fix" but I think they're partially also checking
> > for things which shouldn't cause problems... E.g., undo_retrans is only
> > used after checking undo_marker's validity first so I don't think
> > undo_marker check is exactly necessary there (but on the other hand it
> > does no harm)...
>
> logically we should check the validity of undo_marker/undo_retrans
> before we use them? The current code has no problem if
> tcp_fastretrans_alert() always call tcp_try_undo_*  functions whenever
> undo_marker != 0 and undo_retrans == 0. I don't think that's always
> true.

We certainly should be letting the undo_retrans to underflow that in this 
your patch has merit (the added tp->undo_retrans check).

However, the only users are:

static inline int tcp_may_undo(struct tcp_sock *tp)
{
	 return tp->undo_marker && (!tp->undo_retrans ...)

and:

static void tcp_try_undo_dsack(struct sock *sk)
{
	struct tcp_sock *tp = tcp_sk(sk);

	if (tp->undo_marker && !tp->undo_retrans) {


...which check that undo_retrans is valid.

> > The tcp_retransmit_skb problem I don't understand at all as we should be
> > fragmenting or resetting pcount to 1 (the latter is true only if all
> > bugfixes were included to the kernel where >1 pcount for a rexmitted skb
> > was seen). If pcount is indeed >1 we might have other issues too somewhere
>
> We found that sometimes pcount > 1 on real servers. This change keeps
> the retrans_out/undo_retrans counters consistent.

There's still some bug then I guess... It might be related to the issues 
seen by those other guys who were complaining about small segments with
>1 pcount breaking their hardware (few months ago). For the record, the 
last fix is from 2.6.31 or so.

Like I said, I don't oppose this change anyway:

> > but I fail to remember immediately what they would be. That change is not
> > bad though since using +/-1 is something we should be getting rid of
> > anyway and on long term it would be nice to make tcp_retransmit_skb to be
> > able to take advantage of TSO anyway whenever possible.

...it certainly won't hurt to be on the safe side here if/when something 
else is wrong.

> > I also noticed that the undo_retrans code in sacktag side is still doing
> > undo_retrans-- ops which could certainly cause real miscounts, though
> > it is extremely unlikely due to the fact that DSACK should be sent
> > immediately for a single segment at a time (so the sender would need to
> > split+recollapse in between).
>
> I have the same doubt but our servers never hit this condition (pcount
> 1). So I keep this part intact.

I could think of some scenario you cannot even reproduce in a large scale 
tests, unlikely indeed :-). ...Or too stable connectivity on the sender 
side. But I've changed my mind... the -1 operation is the correct one as 
we could otherwise overestimate due to pcount=1->2 split after the 
retransmission that triggered the DSACK (now that I remember this, I think 
I've once thought this line through already earlier... I'll try to write a 
comment one day there).

For -rc/next purposes I don't see any big enough reasons to withhold:

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

...but if you want this to stables too I don't think it's minimal w.r.t. 
undo_marker check.

-- 
 i.
--8323329-1137111006-1297158877=:26191--
