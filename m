From: Willy Tarreau <w@1wt.eu>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Mon, 19 Jan 2009 10:53:21 +0100
Message-ID: <20090119095320.GC14531@1wt.eu>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106185012.GA30322@1wt.eu> <20090119083921.GA17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1622 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbZASJxd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 04:53:33 -0500
Content-Disposition: inline
In-Reply-To: <20090119083921.GA17124@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 09:39:21AM +0100, Lennert Buytenhek wrote:
> On Tue, Jan 06, 2009 at 07:50:12PM +0100, Willy Tarreau wrote:
> 
> > > Thanks a lot for the test application, it will greatly help to resolve
> > > this issue.
> > 
> > I figured it was an absolute necessity. The original code in my proxy is in
> > an experimental state and far too hard to debug for these purposes. It was
> > enough to detect the problem, but I could run a lot more tests with this
> > small test app ! An who know, maybe it will serve as an example for
> > non-blocking splice ;-)
> 
> :-)
> 
> Just to throw some more (hacky) example code into the pool, below is
> an echo server that I hacked up to test nonblocking splice().  (You'll
> need sf.net/projects/libivykis to use it.)  I also have a splice()
> discard server and a patch to my intercept-connection-via-iptables-and-
> forward-it-to-a-remote-SOCKS5-server-to-deal-with-crappy-VPNs app to
> use splice() somewhere.
> 
> My main annoyances with splice(2) are/were:
> 
> 1. -EAGAIN return on splice from socket/pipe to socket/pipe doesn't
>    directly tell you whether the source ran out of data or the
>    destination can't accept more data, which means you can't e.g. use
>    epoll in edge triggered mode without jumping through some minor
>    number of extra hoops.  (For a pipe you can keep track of how many
>    bytes are in it by hand, but for a socket->pipe splice -EAGAIN return
>    you'll have to assume that the pipe is full if there are >0 bytes in
>    it.)

I proceeded the same way : if EAGAIN and data still in the pipe, then
stop polling.

> 2. Because of (1), and because when splicing from a socket to a pipe
>    it returns after the first bit of data (you mentioned this as well),
>    you don't know at that point whether your pipe is full or not.

In fact this is fixed now. tcp_splice_read() returns all available data,
which somewhat hides problem #1. I'm running with 23 kB in a push/pull
method all the time, so it remains optimal.

> 3. Always returns -EAGAIN even if there was a FIN or error on the
>    source socket.  (Now fixed.)

Yes I saw your fix, it was indeed very annoying because the only workaround
I found was to perform an recv(MSG_PEEK) on the socket after each EAGAIN
to check whether the connection was closed or not.

For these reasons, I'd really love to see the few recent fixes backported
to -stable ASAP. It will boost splice() adoption among products.

Regards,
Willy

