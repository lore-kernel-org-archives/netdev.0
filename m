From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 23:01:11 +0200
Message-ID: <1285534871.2357.19.camel@edumazet-laptop>
References: <20100926131717.GA13046@1wt.eu>
	 <1285520567.2530.8.camel@edumazet-laptop> <20100926174014.GA12373@1wt.eu>
	 <1285526115.2530.12.camel@edumazet-laptop>  <20100926184914.GC12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33783 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932335Ab0IZVBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 17:01:16 -0400
Received: by wwd20 with SMTP id 20so86676wwd.1
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 14:01:15 -0700 (PDT)
In-Reply-To: <20100926184914.GC12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 septembre 2010 =C3=A0 20:49 +0200, Willy Tarreau a =C3=A9=
crit :
> On Sun, Sep 26, 2010 at 08:35:15PM +0200, Eric Dumazet wrote:
> > I was referring to this code. It works well for me.
> >=20
> > shutdown(fd, SHUT_RDWR);
> > while (recv(fd, buff, sizeof(buff), 0) > 0)
> > 	;
> > close(fd);
>=20
> Ah this one yes, but it's overkill. We're actively pumping data from =
the
> other side to drop it on the floor until it finally closes while we o=
nly
> need to know when it has ACKed the FIN. In practice, doing that on a =
POST
> request which causes a 302 or 401 will result in the whole amount of =
data
> being transferred twice. Not only this is bad for the bandwidth, this=
 is
> also bad for the user, as we're causing him to experience a complete =
upload
> twice, just to be sure it has received the FIN, while it's pretty obv=
ious
> that it's not necessary in 99.9% of the cases.
>=20

I dont understand how recv() could transfert data twice.

Once you issued shutdown(RDWR), socket rx buffer is freezed and no more
incoming data should be accepted/queued.

You only read from the socket receive queue to null buffer, and in most
cases a single recv() call will be enough to drain the queue.


> Since this method is the least efficient one and clearly not acceptab=
le
> for practical cases, I wanted to dig at the root, where the informati=
on
> is known. And the TCP recv code is precisely the place where we know
> exactly when it's safe to reset.
>=20

And its safe to reset exactly when application just does close(), if
unread data was not drained. Not only its safe, but required. A new RFC
might be needed ?


> Also there's another issue in doing this. It requires polling of the
> receive side for all requests, which adds one epoll_ctl() syscall and
> one recv() call, which have a much noticeable negative performance
> impact at high rates (at 100000 connections per second, every syscall
> counts). For now I could very well consider that I do this only for
> POST requests, which currently are the ones exhibiting the issue the
> most, but since HTTP browsers will try to enable pipelining again
> soon, the problem will generalize to all types of requests. Hence my
> attempts to do it the optimal way.

This might be overkill but is a portable way of doing this, on all
versions of linux.

Sure, you could patch kernel to add a new system call

close_proper(fd);

As shutdown() only uses two bits, you can eventually add another bit to
flush receive queue as well (to avoid the copy of it)

Another question, is : why the server closes the socket, if you believe
more pipelining is coming soon ?



