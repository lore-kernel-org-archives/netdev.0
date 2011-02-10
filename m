From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Thu, 10 Feb 2011 23:31:03 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1102102325270.27302@melkinpaasi.cs.helsinki.fi>
References: <1297119424-19956-1-git-send-email-ycheng@google.com> <20110207.150522.28821840.davem@davemloft.net> <alpine.DEB.2.00.1102080112450.29228@melkinpaasi.cs.helsinki.fi> <AANLkTikh4YXzJGgTWsTjpz6BczrfSGYD_qSg3WWmKrs9@mail.gmail.com>
 <alpine.DEB.2.00.1102081110050.26191@melkinpaasi.cs.helsinki.fi> <AANLkTikN9C6XV3JHUoypmVQ0H0cChmmvUU3zSWa8Fva8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1093806648-1297373464=:27302"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53980 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757113Ab1BJVbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 16:31:05 -0500
In-Reply-To: <AANLkTikN9C6XV3JHUoypmVQ0H0cChmmvUU3zSWa8Fva8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1093806648-1297373464=:27302
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 10 Feb 2011, Yuchung Cheng wrote:

> On Tue, Feb 8, 2011 at 1:54 AM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > On Mon, 7 Feb 2011, Yuchung Cheng wrote:
> >
> > > On Mon, Feb 7, 2011 at 3:36 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > > >
> > > > On Mon, 7 Feb 2011, David Miller wrote:
> > > >
> > > > > From: Yuchung Cheng <ycheng@google.com>
> > > > > Date: Mon,  7 Feb 2011 14:57:04 -0800
> > > > >
> > > > > > Fix a bug that undo_retrans is incorrectly decremented when undo_marker is
> > > > > > not set or undo_retrans is already 0. This happens when sender receives
> > > > > > more DSACK ACKs than packets retransmitted during the current
> > > > > > undo phase. This may also happen when sender receives DSACK after
> > > > > > the undo operation is completed or cancelled.
> > > > > >
> > > > > > Fix another bug that undo_retrans is incorrectly incremented when
> > > > > > sender retransmits an skb and tcp_skb_pcount(skb) > 1 (TSO). This case
> > > > > > is rare but not impossible.
> > > > > >
> > > > > > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> > > >
> > > > Neither is harmful to "fix" but I think they're partially also checking
> > > > for things which shouldn't cause problems... E.g., undo_retrans is only
> > > > used after checking undo_marker's validity first so I don't think
> > > > undo_marker check is exactly necessary there (but on the other hand it
> > > > does no harm)...
> > >
> > > logically we should check the validity of undo_marker/undo_retrans
> > > before we use them? The current code has no problem if
> > > tcp_fastretrans_alert() always call tcp_try_undo_*  functions whenever
> > > undo_marker != 0 and undo_retrans == 0. I don't think that's always
> > > true.
> >
> > We certainly should be letting the undo_retrans to underflow that in this
> > your patch has merit (the added tp->undo_retrans check).
> >
> > However, the only users are:
> >
> > static inline int tcp_may_undo(struct tcp_sock *tp)
> > {
> >         return tp->undo_marker && (!tp->undo_retrans ...)
> >
> > and:
> >
> > static void tcp_try_undo_dsack(struct sock *sk)
> > {
> >        struct tcp_sock *tp = tcp_sk(sk);
> >
> >        if (tp->undo_marker && !tp->undo_retrans) {
> >
> >
> > ...which check that undo_retrans is valid.
> But that does not make this bug go away.
> The sender does not always call these functions in tcp_fastretrans_alert().
> 
> A common example is that the sender receives a DUPACK with DSACK option
> during CA_Recovery and undo_retrans goes to 0. Since it's not a partial ACK,
> no undo function is called (another bug?) while processing the DUPACK. If the
> sender receives another DSACK, undo_retrans underflows and the undo
> chance is missed forever.

But the underflow can be fixed without checking for tp->undo_marker with 
the tp->undo_retrans > 0 condition only before decrementing it, right 
(in sacktag code like you do)? ...I don't understand what that has to do 
with these functions being called from tcp_fastretrans_alert or not.

> I think that's another potential bug in handling this situation but I
> want to fix in
> this boundary checks first.



-- 
 i.
--8323329-1093806648-1297373464=:27302--
