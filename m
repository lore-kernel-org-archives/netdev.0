From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: fix potential corner case issue in segmentation (Was: Re: [PATCH] Do not use TSO/GSO when there is urgent data)
Date: Fri, 21 Nov 2008 16:51:51 +0100
Message-ID: <200811211651.52024.ptesarik@suse.cz>
References: <200811211319.45515.ptesarik@suse.cz> <Pine.LNX.4.64.0811211438420.3930@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Jan =?utf-8?q?=C5=A0embera?=" <jsembera@suse.cz>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52065 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752626AbYKUPuw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 10:50:52 -0500
In-Reply-To: <Pine.LNX.4.64.0811211438420.3930@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne Friday 21 of November 2008 14:07:32 Ilpo J=C3=A4rvinen napsal(a):
> On Fri, 21 Nov 2008, Petr Tesarik wrote:
> > This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=3D12014
> >
> > Since most (if not all) implementations of TSO and even the in-kern=
el
> > software GSO do not update the urgent pointer when splitting a larg=
e
> > segment, it is necessary to turn off TSO/GSO for all outgoing traff=
ic
> > with the URG pointer set.
>
> Good observation, I totally missed this possibility of T/GSO while
> looking.
>
> > Looking at tcp_current_mss (and the preceding comment) I even think
> > this was the original intention. However, this approach is insuffic=
ient,
> > because TSO/GSO is turned off only for newly created frames, not fo=
r
> > frames which were already pending at the arrival of a message with
> > MSG_OOB set. These frames were created when TSO/GSO was enabled,
> > so they may be large, and they will have the urgent pointer set
> > in tcp_transmit_skb().
> >
> > With this patch, such large packets will be fragmented again before
> > going to the transmit routine.
>
> I wonder if there's some corner case which still fails to fragment
> in tcp_retransmit_xmit's in skb->len <=3D cur_mss case if cur_mss
> grew very recently (and therefore skb-len now fits to a single segmen=
t).

This shouldn't be a problem, because TSO only applies to packets which =
are=20
larger than MSS, so the problematic case is when cur_mss gets smaller, =
not=20
when it grows. In other words, the original implementation of=20
tcp_retransmit_xmit() could never make use of TSO/GSO, anyway...

>[...]
> > Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
> > CC: Jan Sembera <jsembera@suse.cz>
> > CC: Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>
> >
> > --
> >  tcp_output.c |    7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -722,7 +722,8 @@ static void tcp_queue_skb(struct sock *sk, stru=
ct
> > sk_buff *skb)
> >  static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *=
skb,
> >  				 unsigned int mss_now)
> >  {
> > -	if (skb->len <=3D mss_now || !sk_can_gso(sk)) {
> > +	if (skb->len <=3D mss_now || !sk_can_gso(sk) ||
> > +	    tcp_urg_mode(tcp_sk(sk))) {
> >  		/* Avoid the costly divide in the normal
> >  		 * non-TSO case.
> >  		 */
> > @@ -1163,7 +1164,9 @@ static int tcp_init_tso_segs(struct sock *sk,
> > struct sk_buff *skb,
> >  {
> >  	int tso_segs =3D tcp_skb_pcount(skb);
> >
> > -	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) !=3D mss_now))=
 {
> > +	if (!tso_segs ||
> > +	    (tso_segs > 1 && (tcp_skb_mss(skb) !=3D mss_now ||
> > +			      tcp_urg_mode(tcp_sk(sk))))) {
> >  		tcp_set_skb_tso_segs(sk, skb, mss_now);
> >  		tso_segs =3D tcp_skb_pcount(skb);
> >  	}
>
> It's a bit intrusive but I couldn't immediately come up with alternat=
ive
> that would have worked (came up with some not working ones :-)).

Yes, I also noticed that. We could add some more code to tcp_mark_urg()=
, e.g.=20
walk sk_write_queue and adjust the pending SKBs there...

Is it OK to simply set all skb->gso_segs to zero, and let the next call=
 to=20
tcp_init_tso_segs redo them? I mean, will tcp_init_tso_segs() be always=
=20
called on all SKBs which are in the write queue at the time tcp_mark_ur=
g() is=20
called?

Petr
