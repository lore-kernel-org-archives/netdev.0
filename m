From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 08:04:15 +0100
Message-ID: <20090109070415.GA27758@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1296 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483AbZAIHEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 02:04:42 -0500
Content-Disposition: inline
In-Reply-To: <4966F2F4.9080901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 07:47:16AM +0100, Eric Dumazet wrote:
> > I'm not applying this until someone explains to me why
> > we should remove this test from the splice receive but
> > keep it in the tcp_recvmsg() code where it has been
> > essentially forever.
> 
> I found this patch usefull in my testings, but had a feeling something
> was not complete. If the goal is to reduce number of splice() calls,
> we also should reduce number of wakeups. If splice() is used in non
> blocking mode, nothing we can do here of course, since the application
> will use a poll()/select()/epoll() event before calling splice(). A
> good setting of SO_RCVLOWAT to (16*PAGE_SIZE)/2 might improve things.
> 
> I tested this on current tree and it is not working : we still have
> one wakeup for each frame (ethernet link is a 100 Mb/s one)

Well, it simply means that data are not coming in fast enough compared to
the tiny amount of work you have to perform to forward them, there's nothing
wrong with that. It is important in my opinion not to wait for *enough* data
to come in, otherwise it might become impossible to forward small chunks.
I mean, if there are only 300 bytes left to forward, we must not wait
indefinitely for more data to come, we must forward those 300 bytes.

In your case below, it simply means that the performance improvement brought
by splice will be really minor because you'll just avoid 2 memory copies,
which are ridiculously cheap at 100 Mbps. If you would change your program
to use recv/send, you would observe the exact same pattern, because as soon
as poll() wakes you up, you still only have one frame in the system buffers.
On a small machine I have here (geode 500 MHz), I easily have multiple
frames queued at 100 Mbps because when epoll() wakes me up, I have traffic
on something like 10-100 sockets, and by the time I process the first ones,
the later have time to queue up more data.

> bind(6, {sa_family=AF_INET, sin_port=htons(4711), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
> listen(6, 5)                            = 0
> accept(6, 0, NULL)                      = 7
> setsockopt(7, SOL_SOCKET, SO_RCVLOWAT, [32768], 4) = 0
> poll([{fd=7, events=POLLIN, revents=POLLIN|POLLERR|POLLHUP}], 1, -1) = 1
> splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    = 1024
> splice(0x3, 0, 0x5, 0, 0x400, 0x5)      = 1024
> poll([{fd=7, events=POLLIN, revents=POLLIN|POLLERR|POLLHUP}], 1, -1) = 1
> splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    = 1460
> splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      = 1460
> poll([{fd=7, events=POLLIN, revents=POLLIN|POLLERR|POLLHUP}], 1, -1) = 1
> splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    = 1460
> splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      = 1460
> poll([{fd=7, events=POLLIN, revents=POLLIN|POLLERR|POLLHUP}], 1, -1) = 1
> splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    = 1460
> splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      = 1460
> poll([{fd=7, events=POLLIN, revents=POLLIN|POLLERR|POLLHUP}], 1, -1) = 1
> splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    = 1460
> splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      = 1460
> poll([{fd=7, events=POLLIN, revents=POLLIN|POLLERR|POLLHUP}], 1, -1) = 1
> splice(0x7, 0, 0x4, 0, 0x10000, 0x3)    = 1460
> splice(0x3, 0, 0x5, 0, 0x5b4, 0x5)      = 1460

How much CPU is used for that ? Probably something like 1-2% ? If you could
retry with 100-1000 concurrent sessions, you would observe more traffic on
each socket, which is where the gain of splice becomes really important.

> About tcp_recvmsg(), we might also remove the "!timeo" test as well,
> more testings are needed.

No right now we can't (we must move it somewhere else at least). Because
once at least one byte has been received (copied != 0), no other check
will break out of the loop (or at least I have not found it).

> But remind that if an application provides
> a large buffer to tcp_recvmsg() call, removing the test will reduce
> the number of syscalls but might use more DCACHE. It could reduce
> performance on old cpus. With splice() call, we expect to not
> copy memory and trash DCACHE, and pipe buffers being limited to 16,
> we cope with a limited working set. 

That's an interesting point indeed !

Regards,
Willy

