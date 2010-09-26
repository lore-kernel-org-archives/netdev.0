From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 20:49:14 +0200
Message-ID: <20100926184914.GC12373@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <1285520567.2530.8.camel@edumazet-laptop> <20100926174014.GA12373@1wt.eu> <1285526115.2530.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45694 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757160Ab0IZStS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 14:49:18 -0400
Content-Disposition: inline
In-Reply-To: <1285526115.2530.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 08:35:15PM +0200, Eric Dumazet wrote:
> I was referring to this code. It works well for me.
> 
> shutdown(fd, SHUT_RDWR);
> while (recv(fd, buff, sizeof(buff), 0) > 0)
> 	;
> close(fd);

Ah this one yes, but it's overkill. We're actively pumping data from the
other side to drop it on the floor until it finally closes while we only
need to know when it has ACKed the FIN. In practice, doing that on a POST
request which causes a 302 or 401 will result in the whole amount of data
being transferred twice. Not only this is bad for the bandwidth, this is
also bad for the user, as we're causing him to experience a complete upload
twice, just to be sure it has received the FIN, while it's pretty obvious
that it's not necessary in 99.9% of the cases.

Since this method is the least efficient one and clearly not acceptable
for practical cases, I wanted to dig at the root, where the information
is known. And the TCP recv code is precisely the place where we know
exactly when it's safe to reset.

Also there's another issue in doing this. It requires polling of the
receive side for all requests, which adds one epoll_ctl() syscall and
one recv() call, which have a much noticeable negative performance
impact at high rates (at 100000 connections per second, every syscall
counts). For now I could very well consider that I do this only for
POST requests, which currently are the ones exhibiting the issue the
most, but since HTTP browsers will try to enable pipelining again
soon, the problem will generalize to all types of requests. Hence my
attempts to do it the optimal way.

Regards,
Willy

