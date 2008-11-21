From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix potential corner case issue in segmentation
 (Was: Re: [PATCH] Do not use TSO/GSO when there is urgent data)
Date: Fri, 21 Nov 2008 19:49:02 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811211901120.9953@wrl-59.cs.helsinki.fi>
References: <200811211319.45515.ptesarik@suse.cz>
 <Pine.LNX.4.64.0811211438420.3930@wrl-59.cs.helsinki.fi>
 <200811211651.52024.ptesarik@suse.cz>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-887022033-1227287286=:9953"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Jan =?utf-8?q?=C5=A0embera?=" <jsembera@suse.cz>
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46083 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbYKURtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 12:49:06 -0500
In-Reply-To: <200811211651.52024.ptesarik@suse.cz>
Content-ID: <Pine.LNX.4.64.0811211940410.9953@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-887022033-1227287286=:9953
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811211908151.9953@wrl-59.cs.helsinki.fi>

On Fri, 21 Nov 2008, Petr Tesarik wrote:

> Dne Friday 21 of November 2008 14:07:32 Ilpo Järvinen napsal(a):
> > On Fri, 21 Nov 2008, Petr Tesarik wrote:
> > > This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=12014
> > >
> > > Since most (if not all) implementations of TSO and even the in-kernel
> > > software GSO do not update the urgent pointer when splitting a large
> > > segment, it is necessary to turn off TSO/GSO for all outgoing traffic
> > > with the URG pointer set.
> >
> > Good observation, I totally missed this possibility of T/GSO while
> > looking.
> >
> > > Looking at tcp_current_mss (and the preceding comment) I even think
> > > this was the original intention. However, this approach is insufficient,
> > > because TSO/GSO is turned off only for newly created frames, not for
> > > frames which were already pending at the arrival of a message with
> > > MSG_OOB set. These frames were created when TSO/GSO was enabled,
> > > so they may be large, and they will have the urgent pointer set
> > > in tcp_transmit_skb().
> > >
> > > With this patch, such large packets will be fragmented again before
> > > going to the transmit routine.
> >
> > I wonder if there's some corner case which still fails to fragment
> > in tcp_retransmit_xmit's in skb->len <= cur_mss case if cur_mss
> > grew very recently (and therefore skb-len now fits to a single segment).
> 
> This shouldn't be a problem, because TSO only applies to packets which are 
> larger than MSS, so the problematic case is when cur_mss gets smaller, not 
> when it grows. In other words, the original implementation of 
> tcp_retransmit_xmit() could never make use of TSO/GSO, anyway...

I disagree:

1. mss == x
2. skb->len == 2*x => Send using TSO/GSO
3. mss = 2*x (e.g, mtu probe completes)
4. rexmit skb, nothing resets TSO/GSO fields though now skb->len <= mss, 
thus it will get sent as two, smaller than what's necessary, packets using 
TSO/GSO and will not get into that fixed place of yours.

Or did I miss something?

> >[...]
> > > Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
> > > CC: Jan Sembera <jsembera@suse.cz>
> > > CC: Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>
> > >
> > > --
> > >  tcp_output.c |    7 +++++--
> > >  1 file changed, 5 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > > --- a/net/ipv4/tcp_output.c
> > > +++ b/net/ipv4/tcp_output.c
> > > @@ -722,7 +722,8 @@ static void tcp_queue_skb(struct sock *sk, struct
> > > sk_buff *skb)
> > >  static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
> > >  				 unsigned int mss_now)
> > >  {
> > > -	if (skb->len <= mss_now || !sk_can_gso(sk)) {
> > > +	if (skb->len <= mss_now || !sk_can_gso(sk) ||
> > > +	    tcp_urg_mode(tcp_sk(sk))) {
> > >  		/* Avoid the costly divide in the normal
> > >  		 * non-TSO case.
> > >  		 */
> > > @@ -1163,7 +1164,9 @@ static int tcp_init_tso_segs(struct sock *sk,
> > > struct sk_buff *skb,
> > >  {
> > >  	int tso_segs = tcp_skb_pcount(skb);
> > >
> > > -	if (!tso_segs || (tso_segs > 1 && tcp_skb_mss(skb) != mss_now)) {
> > > +	if (!tso_segs ||
> > > +	    (tso_segs > 1 && (tcp_skb_mss(skb) != mss_now ||
> > > +			      tcp_urg_mode(tcp_sk(sk))))) {
> > >  		tcp_set_skb_tso_segs(sk, skb, mss_now);
> > >  		tso_segs = tcp_skb_pcount(skb);
> > >  	}
> >
> > It's a bit intrusive but I couldn't immediately come up with alternative
> > that would have worked (came up with some not working ones :-)).
> 
> Yes, I also noticed that. We could add some more code to tcp_mark_urg(), e.g. 
> walk sk_write_queue and adjust the pending SKBs there...
>
> Is it OK to simply set all skb->gso_segs to zero, and let the next call to 
> tcp_init_tso_segs redo them?

If we walk backwards we could consider short-circuit the walk at 16-bit 
urg field limit. I wouldn't mind if users of such obscure feature pay the 
price but the final decision is up to Dave of course.

> I mean, will tcp_init_tso_segs() be always 
> called on all SKBs which are in the write queue at the time tcp_mark_urg() is 
> called?

I realized there is more breakage: That tcp_current_mss tcp_urg_mode 
is too late as well, it won't work either until we're already past the 
relevant seqno range... It basically starts working at snd_up upwards 
rather than working on snd_up-2^16..snd_up region.

In addition, it's quite impossible to tso/gso successfully past
ceil_to_mss(snd_up - 2^16) boundary anyway because we don't have enough 
bits in the urgent field to tell at which point the fields should get set 
(unless there would be some out-of-band communication channel for the 
urgent sequence number).


-- 
 i.
---696208474-887022033-1227287286=:9953--
