From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Fri, 18 May 2012 00:24:31 +0200
Message-ID: <20120517222431.GT14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu> <1337290822.3403.47.camel@edumazet-glaptop> <1337291410.3403.52.camel@edumazet-glaptop> <1337292119.3403.60.camel@edumazet-glaptop> <20120517221641.GS14498@1wt.eu> <1337293351.3403.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2354 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030205Ab2EQWYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 18:24:33 -0400
Content-Disposition: inline
In-Reply-To: <1337293351.3403.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 18, 2012 at 12:22:31AM +0200, Eric Dumazet wrote:
> On Fri, 2012-05-18 at 00:16 +0200, Willy Tarreau wrote:
> > On Fri, May 18, 2012 at 12:01:59AM +0200, Eric Dumazet wrote:
> > > On Thu, 2012-05-17 at 23:50 +0200, Eric Dumazet wrote:
> > > > On Thu, 2012-05-17 at 23:40 +0200, Eric Dumazet wrote:
> > > > 
> > > > > I dont understand why we should tcp_push() if we sent 0 bytes in this
> > > > > splice() call.
> > > > > 
> > > > > The push() should have be done already by prior splice() call, dont you
> > > > > think ?
> > > > > 
> > > > > out:
> > > > > 	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
> > > > > 		tcp_push(sk, flags, mss_now, tp->nonagle);
> > > > > 
> > > > 
> > > > I think I now understand
> > > > 
> > > > One splice() syscall actually calls do_tcp_sendpages() several times
> > > > (N).
> > > > 
> > > > Problem is N-1 calls are done with MSG_SENDPAGE_NOTLAST set
> > > > 
> > > > And last one with MSG_SENDPAGE_NOTLAST unset
> > > > 
> > > > So maybe we should replace this test by :
> > > > 
> > > > 	if (!(flags & MSG_SENDPAGE_NOTLAST))
> > > > 		tcp_push(...);
> > > > 
> > > > 
> > > 
> > > Its more tricky than that.
> > > 
> > > If we return 0 from do_tcp_sendpages(), __splice_from_pipe() wont call
> > > us again, but we need to flush().  (This bug is indeed very old)
> > > 
> > > So maybe use :
> > > 
> > > if ((copied && !(flags & MSG_SENDPAGE_NOTLAST)) ||
> > >     !copied)
> > > 	tcp_push(...);
> > 
> > That's what I wanted to do at first but was still worried about the
> > situations where we fail upon first call due to lack of memory. And
> > indeed that did not fix the issue either :-(
> > 
> > At least now I've checked that we fail here in do_tcp_sendpages() :
> > 
> > 	if (!sk_stream_memory_free(sk)) {
> > 		printk(KERN_DEBUG "%s:%d copied=%d\n", __FUNCTION__, __LINE__, copied);
> > 		goto wait_for_sndbuf;
> > 	}
> > 
> > Well, finally I just put the same test as yours above for the call to
> > tcp_push() upon out of memory and it fixed it too. I have simplified
> > the expression, since ((A && !B) || !A) == !(A & B).
> > 
> > With the updated patch here it works for me. I don't know if it's
> > better.
> > 
> > Willy
> > 
> > -----
> > 
> > From 1f26263bd4f8827bbca4cef77a99fac128cf8ccc Mon Sep 17 00:00:00 2001
> > From: Willy Tarreau <w@1wt.eu>
> > Date: Thu, 17 May 2012 22:43:20 +0200
> > Subject: [PATCH] tcp: do_tcp_sendpages() must try to push data out on oom conditions
> > 
> > Since recent changes on TCP splicing (starting with commits 2f533844
> > and 35f9c09f), I started seeing massive stalls when forwarding traffic
> > between two sockets using splice() when pipe buffers were larger than
> > socket buffers.
> > 
> > Latest changes (net: netdev_alloc_skb() use build_skb()) made the
> > problem even more apparent.
> > 
> > The reason seems to be that if do_tcp_sendpages() fails on out of memory
> > condition without being able to send at least one byte, tcp_push() is not
> > called and the buffers cannot be flushed.
> > 
> > After applying the attached patch, I cannot reproduce the stalls at all
> > and the data rate it perfectly stable and steady under any condition
> > which previously caused the problem to be permanent.
> > 
> > The issue seems to have been there since before the kernel migrated to
> > git, which makes me think that the stalls I occasionally experienced
> > with tux during stress-tests years ago were probably related to the
> > same issue.
> > 
> > This issue was first encountered on 3.0.31 and 3.2.17, so please backport
> > to -stable.
> > 
> > Signed-off-by: Willy Tarreau <w@1wt.eu>
> > Cc: <stable@vger.kernel.org>
> > ---
> >  net/ipv4/tcp.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 63ddaee..cfe47c1 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -917,7 +917,7 @@ new_segment:
> >  wait_for_sndbuf:
> >  		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
> >  wait_for_memory:
> > -		if (copied)
> > +		if (!(copied && (flags & MSG_SENDPAGE_NOTLAST)))
> >  			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
> >  
> >  		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
> > @@ -927,7 +927,7 @@ wait_for_memory:
> >  	}
> >  
> >  out:
> > -	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
> > +	if (!(copied && (flags & MSG_SENDPAGE_NOTLAST)))
> >  		tcp_push(sk, flags, mss_now, tp->nonagle);
> >  	return copied;
> >  
> 
> 
> Hmm... I believe I prefer your prior patch ( the one I Acked)

I too, less changes are better :-)

Thanks,
Willy
