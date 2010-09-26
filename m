From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 19:40:15 +0200
Message-ID: <20100926174014.GA12373@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <1285520567.2530.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45691 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757197Ab0IZRkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 13:40:18 -0400
Content-Disposition: inline
In-Reply-To: <1285520567.2530.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Sun, Sep 26, 2010 at 07:02:47PM +0200, Eric Dumazet wrote:
> How could we delay the close() ? We must either send a FIN or RST.

I don't mean to delay the close(), but I'm aware that my description
was not very clear.

Here's what I would find normal :

1) upon close(), we send a FIN, whether there are incoming pending
   data or not (after all, the only difference is only a timing
   issue, as the data in the rx buffer might very well come just
   after the FIN, as it almost always does, BTW). The connection
   then becomes FIN_WAIT1 just as now.

2) mark the socket as orphaned

3) when an ACK comes from the other side, either it's below our last
   seq, and we simply ignore it, just as if we were in TIME_WAIT, or
   it is equal to the last seq and indicates that it's now safe to
   reset ; we would then just send the RST to notify the other side
   that the data it sent were not read. The connection can then either
   be destroyed or put in TIME_WAIT. It's the point where the connection
   normally switches from FIN_WAIT1 to FIN_WAIT2, since the FIN has been
   acked. The only difference is that we don't need a FIN_WAIT2 state
   for an orphan.

> I would say, fix the program, so that RST is avoided ?

Not that easy, see below.

> The program does :
> 
> recv() // read the request
> send() // queue the answer
> close() // could work if world was perfect...
> 
> Change it to
> 
> recv()
> send()
> shutdown()
> recv() // read & flush in excess data

New data arrives now, close() below will cause an RST again.

> close()
> 
> This for sure will send FIN after all queued data is sent.
> I am not sure the final rcv() is even needed, its Sunday after all ;)

Currently the real code (ie: not the poc I posted) does :

   recv()
   send()
   shutdown()
   close()

The extra CRLF almost always happens between the recv() and send(). What
I intend to do as a workaround is exactly what you described above, but
I'm well aware it's not enough. It will only reduce the rate at which this
case happens. Well, in fact, in 10 years of production at many sites, it's
the first time such an issue is reported and it could be tracked down to
these two extra bytes. But the workaround will not prevent the two extra
bytes from coming after the last recv().

Also, the issue remains when processing large POST requests. Let's suppose
the application is receiving a massive POST (eg: 10 MB) but the request is
not authenticated, so the application returns an HTTP 401 response to
require the client to authenticate. There's no way for the application to
be notified that the small response was completely read by the client and
that it's safe to close().

For these reasons, I concluded that the application can't get everything
right and needs help from the kernel (said differently, I think that the
RFC2525 fix is causing harm in addition to goods). In my opinion, this
section in the RFC was added based on a few observations of trivial cases
but was but its impact was not completely explored.

I'm willing to experiment, but I'm not much familiar with the code itself
and sometimes I'm not sure about what I'm doing, probably that some help
would be welcome. What I'd like to do is to implement the step 3 above,
which is to only send the RST upon receipt of an ACK on an orphan that
would switch a normal socket from FIN_WAIT1 to FIN_WAIT2.

Also, I'm not sure about what other OSes are doing. For instance, I tried
on Solaris and did not observe the issue at all, though I think that
Solaris simply does not implement the RFC2525 recommendation.

Have a nice sunday evening ;-)
Willy

