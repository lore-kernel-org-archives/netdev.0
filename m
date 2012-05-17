From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 22:41:19 +0200
Message-ID: <1337287279.3403.44.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52324 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab2EQUlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:41:24 -0400
Received: by wgbdr13 with SMTP id dr13so2116602wgb.1
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 13:41:23 -0700 (PDT)
In-Reply-To: <20120517121800.GA18052@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 14:18 +0200, Willy Tarreau wrote:
> Hi Eric,
> 
> I'm facing a regression in stable 3.2.17 and 3.0.31 which is
> exhibited by your patch 'tcp: allow splice() to build full TSO
> packets' which unfortunately I am very interested in !
> 
> What I'm observing is that TCP transmits using splice() stall
> quite quickly if I'm using pipes larger than 64kB (even 65537
> is enough to reliably observe the stall).
> 
> I'm seeing this on haproxy running on a small ARM machine (a
> dockstar), which exchanges data through a gig switch with my
> development PC. The NIC (mv643xx) doesn't support TSO but has
> GSO enabled. If I disable GSO, the problem remains. I can however
> make the problem disappear by disabling SG or Tx checksumming.
> BTW, using recv/send() instead of splice() also gets rid of the
> problem.
> 
> I can also reduce the risk of seeing the problem by increasing
> the default TCP buffer sizes in tcp_wmem. By default I'm running
> at 16kB, but if I increase the output buffer size above the pipe
> size, the problem *seems* to disappear though I can't be certain,
> since larger buffers generally means the problem takes longer to
> appear, probably due to the fact that the buffers don't need to
> be filled. Still I'm certain that with 64k TCP buffers and 128k
> pipes I'm still seeing it.
> 
> With strace, I'm seeing data fill up the pipe with the splice()
> call responsible for pushing the data to the output socket returing
> -1 EAGAIN. During this time, the client receives no data.
> 
> Something bugs me, I have tested with a dummy server of mine,
> httpterm, which uses tee+splice() to push data outside, and it
> has no problem filling the gig pipe, and correctly recoverers
> from the EAGAIN :
> 
>   send(13, "HTTP/1.1 200\r\nConnection: close\r"..., 160, MSG_DONTWAIT|MSG_NOSIGNAL) = 160
>   tee(0x3, 0x6, 0x10000, 0x2)             = 42552
>   splice(0x5, 0, 0xd, 0, 0xa00000, 0x2)   = 14440
>   tee(0x3, 0x6, 0x10000, 0x2)             = 13880
>   splice(0x5, 0, 0xd, 0, 0x9fc798, 0x2)   = -1 EAGAIN (Resource temporarily unavailable)
>   ...
>   tee(0x3, 0x6, 0x10000, 0x2)             = 13880
>   splice(0x5, 0, 0xd, 0, 0x9fc798, 0x2)   = 51100
>   tee(0x3, 0x6, 0x10000, 0x2)             = 50744
>   splice(0x5, 0, 0xd, 0, 0x9efffc, 0x2)   = 32120
>   tee(0x3, 0x6, 0x10000, 0x2)             = 30264
>   splice(0x5, 0, 0xd, 0, 0x9e8284, 0x2)   = -1 EAGAIN (Resource temporarily unavailable)
> 
> etc...
> 
> It's only with haproxy which uses splice() to copy data between
> two sockets that I'm getting the issue (data forwarded from fd 0xe
> to fd 0x6) :
> 
>   16:03:17.797144 pipe([36, 37])          = 0
>   16:03:17.797318 fcntl64(36, 0x407 /* F_??? */, 0x20000) = 131072 ## note: fcntl(F_SETPIPE_SZ, 128k)
>   16:03:17.797473 splice(0xe, 0, 0x25, 0, 0x9f2234, 0x3) = 10220
>   16:03:17.797706 splice(0x24, 0, 0x6, 0, 0x27ec, 0x3) = 10220
>   16:03:17.802036 gettimeofday({1324652597, 802093}, NULL) = 0
>   16:03:17.802200 epoll_wait(0x3, 0x99250, 0x16, 0x3e8) = 7
>   16:03:17.802363 gettimeofday({1324652597, 802419}, NULL) = 0
>   16:03:17.802530 splice(0xe, 0, 0x25, 0, 0x9efa48, 0x3) = 16060
>   16:03:17.802789 splice(0x24, 0, 0x6, 0, 0x3ebc, 0x3) = 16060
>   16:03:17.806593 gettimeofday({1324652597, 806651}, NULL) = 0
>   16:03:17.806759 epoll_wait(0x3, 0x99250, 0x16, 0x3e8) = 4
>   16:03:17.806919 gettimeofday({1324652597, 806974}, NULL) = 0
>   16:03:17.807087 splice(0xe, 0, 0x25, 0, 0x9ebb8c, 0x3) = 17520
>   16:03:17.807356 splice(0x24, 0, 0x6, 0, 0x4470, 0x3) = 17520
>   16:03:17.809565 gettimeofday({1324652597, 809620}, NULL) = 0
>   16:03:17.809726 epoll_wait(0x3, 0x99250, 0x16, 0x3e8) = 1
>   16:03:17.809883 gettimeofday({1324652597, 809937}, NULL) = 0
>   16:03:17.810047 splice(0xe, 0, 0x25, 0, 0x9e771c, 0x3) = 36500
>   16:03:17.810399 splice(0x24, 0, 0x6, 0, 0x8e94, 0x3) = 23360
>   16:03:17.810629 epoll_ctl(0x3, 0x1, 0x6, 0x85378) = 0       ## note: epoll_ctl(ADD, fd=6, dir=OUT).
>   16:03:17.810792 gettimeofday({1324652597, 810848}, NULL) = 0
>   16:03:17.810954 epoll_wait(0x3, 0x99250, 0x16, 0x3e8) = 1
>   16:03:17.811188 gettimeofday({1324652597, 811246}, NULL) = 0
>   16:03:17.811356 splice(0xe, 0, 0x25, 0, 0x9de888, 0x3) = 21900
>   16:03:17.811651 splice(0x24, 0, 0x6, 0, 0x88e0, 0x3) = -1 EAGAIN (Resource temporarily unavailable)
> 

Willy you say output to fd 6 hangs, but splice() returns EAGAIN here ?
(because socket buffer is full)

> So output fd 6 hangs here and will not appear anymore until
> here where I pressed Ctrl-C to stop the test :
> 

I just want to make sure its not a userland error that triggers now much
faster than with prior kernels.

You drain bytes from fd 0xe to pipe buffers, but I dont see you check
write ability on destination socket prior the splice(pipe -> socket)
