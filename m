From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 23:54:37 +0200
Message-ID: <20120517215437.GQ14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu> <1337290822.3403.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2348 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761192Ab2EQVyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 17:54:40 -0400
Content-Disposition: inline
In-Reply-To: <1337290822.3403.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 11:40:22PM +0200, Eric Dumazet wrote:
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 63ddaee..231fe53 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -917,8 +917,7 @@ new_segment:
> >  wait_for_sndbuf:
> >  		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
> >  wait_for_memory:
> > -		if (copied)
> > -			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
> > +		tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
> >  
> >  		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
> >  			goto do_error;
> 
> 
> I dont understand why we should tcp_push() if we sent 0 bytes in this
> splice() call.
> 
> The push() should have be done already by prior splice() call, dont you
> think ?
> 
> out:
> 	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
> 		tcp_push(sk, flags, mss_now, tp->nonagle);
> 

I do think so, but my guess is that something fails below us at some point.
I tracked the tcp_push() chain down to tcp_write_xmit() which I *think* might
fail. I'm not certain about the conditions which can make this happen though.
However what I'm almost sure is that if we fail one tcp_write_xmit() from a
call to tcp_push(), next time we come here in do_tcp_sendpages(), the buffers
won't have moved and this second splice() will immediately go to out with
copied == 0.

Maybe I just worked around the consequence of a deeper issue and something
else needs to enable tcp_push() when we fail, but it's not very clear to me.
I felt like the call to tcp_check_probe_timer() in __tcp_push_pending_frames()
is there for this purpose, but I'm not sure.

Willy
