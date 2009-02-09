From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 15:28:09 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902091513190.31742@wrl-59.cs.helsinki.fi>
References: <20090206054541.GA4954@gondor.apana.org.au>
 <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
 <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net>
 <20090209061151.GA3982@gondor.apana.org.au> <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
 <20090209072806.GB4380@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-721455914-1234186089=:31742"
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48965 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778AbZBIN2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:28:12 -0500
In-Reply-To: <20090209072806.GB4380@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-721455914-1234186089=:31742
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 9 Feb 2009, Herbert Xu wrote:

> On Mon, Feb 09, 2009 at 09:13:00AM +0200, Ilpo Järvinen wrote:
> > 
> > Hmm, what happens if a opposite dir ACK gets sent (it's zero sized seqno
> > range will be above urgent sequence when urg is not yet acknowledged)? So
> > we'll take the later branch after your change and send bogus 0xffff urg?
> > I think you're change might have actually broken bidir tcp completely (and
> > probably window probing as well under some conditions). Congraz, two flies
> > with a single stroke :-). You would have needed an additional check that
> > the tcb->seq is below urg...
> > 
> > ...Below is a patch but Jeff might need to revert the revert first if
> > he tests with the latest Linus' tree.
> 
> Good point! That would definitely explain this.
>  
> > [PATCH] tcp: check that we're still < urg instead of sending a bogus one
> > 
> > Opposite dir ACK with zero sized seqno range can go into the
> > later condition once urg is in the outstanding window not
> > yet acknowledge (we're still in urg mode but seqno we sent in
> > the ack won't be below snd_up). Need to check that we never
> > advertize bogus urg for a segment which is after the snd_up.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> > ---
> >  net/ipv4/tcp_output.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 557fe16..c808d73 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -667,7 +667,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
> >  		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF)) {
> >  			th->urg_ptr = htons(tp->snd_up - tcb->seq);
> >  			th->urg = 1;
> > -		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> > +		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt) &&
> > +			   before(tcb->seq, tcp->snd_up)) {
> >  			th->urg_ptr = 0xFFFF;
> >  			th->urg = 1;
> >  		}
> 
> We could rewrite this as
> 
> 	if (unlikely(tcp_urg_mode(tp) && before(tcb->seq, tcp->snd_up))) {
> 		if (before(tp->sndup, tcb->seq + 0x10000)) {
> 			th->urg_ptr = htons(tp->snd_up - tcb->seq);
> 			th->urg = 1;
> 		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
> 			th->urg_ptr = 0xFFFF;
> 			th->urg = 1;
> 		}
> 	}

Yes, that should work too except the gcc catchable typo.


-- 
 i.
---696208474-721455914-1234186089=:31742--
