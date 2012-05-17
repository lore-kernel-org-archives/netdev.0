From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 17:56:21 +0200
Message-ID: <20120517155621.GK14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu> <1337269380.3403.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2329 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754879Ab2EQP4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 11:56:24 -0400
Content-Disposition: inline
In-Reply-To: <1337269380.3403.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 05:43:00PM +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 17:01 +0200, Willy Tarreau wrote:
> > Hi Eric,
> > 
> > On Thu, May 17, 2012 at 02:18:00PM +0200, Willy Tarreau wrote:
> > > Hi Eric,
> > > 
> > > I'm facing a regression in stable 3.2.17 and 3.0.31 which is
> > > exhibited by your patch 'tcp: allow splice() to build full TSO
> > > packets' which unfortunately I am very interested in !
> > > 
> > > What I'm observing is that TCP transmits using splice() stall
> > > quite quickly if I'm using pipes larger than 64kB (even 65537
> > > is enough to reliably observe the stall).
> > (...)
> > 
> > I managed to fix the issue and I really think that the fix makes sense.
> > I'm appending the patch, please could you review it and if approved,
> > push it for inclusion ?
> > 
> > BTW, your patch significantly improves performance here. On this
> > machine I was reaching max 515 Mbps of proxied traffic, and with
> > the patch I reach 665 Mbps with the same test ! I think you managed
> > to fix what caused splice() to always be slightly slower than
> > recv/send() for a long time in my tests with a number of NICs !
> > 
> 
> What NIC do you use exactly ?

It's the NIC included in the system-on-chip (Marvell 88F6281), and the NIC
driver is mv643xx. It's the same hardware you find in sheevaplugs, guruplugs,
dreamplugs and almost all ARM-based cheap NAS boxes.

> With commit 1d0c0b328a6 in net-next
> (net: makes skb_splice_bits() aware of skb->head_frag)
> You'll be able to get even more speed, if NIC uses frag to hold frame.

I'm going to check this now, sounds interesting :-)

The NIC does not support TSO but I've seen an alternate driver for this
NIC which pretends to do TSO and in fact builds header frags so that the
NIC is able to send all frames at once. I think it's already what GSO is
doing but I'm wondering whether it would be possible to get more speed
by doing this than by relying on GSO to (possibly) split the frags earlier.

Note that I'm not quite skilled on this, so do not hesitate to correct me
if I'm saying stupid things.

(...)

> > Commit 2f533844242 (tcp: allow splice() to build full TSO packets)
> > significantly improved splice() performance for some workloads but
> > caused stalls when pipe buffers were larger than socket buffers.
> 
> But... This seems bug was already there ? Only having more data in pipe
> trigger it more often ?

I honnestly don't know. As I said in the initial mail, I suspect this is
the case because I don't see in your patch what could cause the bug, but
I suspect it makes it more frequent. Still, I could not manage to reproduce
the bug without your patch. So maybe we switched from just below a limit
to just over.

> > The issue seems to happen when no data can be copied at all due to
> > lack of buffers, which results in pending data never being pushed.
> > 
> > This change checks if all pending data has been pushed or not and
> > pushes them when waiting for send buffers.
> > ---
> >  net/ipv4/tcp.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 80b988f..f6d9e5f 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -850,7 +850,7 @@ new_segment:
> >  wait_for_sndbuf:
> >  		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
> >  wait_for_memory:
> > -		if (copied)
> > +		if (tcp_sk(sk)->pushed_seq != tcp_sk(sk)->write_seq)
> >  			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
> >  
> >  		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
> 
> Can you check you have commit 35f9c09fe9c72eb8ca2b8e89a593e1c151f28fc2 
> ( tcp: tcp_sendpages() should call tcp_push() once )

Yes I have it, in fact I'm on -stable (3.0.31) which includes your backport
of the two patches in a single one. It's just a few lines below, out of the
context of this patch.

Best regards,
Willy
