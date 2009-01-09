From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 08:42:17 +0100
Message-ID: <20090109074217.GB27758@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <20090109070415.GA27758@1wt.eu> <4966FC89.8040006@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754583AbZAIHm4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4966FC89.8040006@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 09, 2009 at 08:28:09AM +0100, Eric Dumazet wrote:
> My point is to use Gigabit links or 10Gb links and hundred or thousand of flows :)
> 
> But if it doesnt work on a single flow, it wont work on many :)

Yes it will, precisely because during the time you spend processing flow #1,
you're still receiving data for flow #2. I really invite you to try. That's
what I've been observing for years of userland coding of proxies.

> I tried my test program with a Gb link, one flow, and got splice() calls returns 23000 bytes
> in average, using a litle too much of CPU : If poll() could wait a litle bit more, CPU
> could be available for other tasks.

I also observe 23000 bytes on average on gigabit, which is very good
(only about 5000 calls per second). And the CPU usage is lower than
with recv/send, and I'd like to be able to run some profiling because
I observed very different performance patterns depending on the network
cards used. Generally, almost all the time is spent in softirqs.

It's easy to make poll wait a little bit more : call it later and do
your work before calling it. Also, epoll_wait() lets you ask it to
return just a few amount of FDs. This really improves data gathering.
I generally observe best performance between 30-200 FDs per call, even
with 10000 concurrent connections. During the time I process the first
200 FDs, data is accumulating in the other's buffers.

> If the application uses setsockopt(sock, SOL_SOCKET, SO_RCVLOWAT, [32768], 4), it
> would be good if kernel was smart enough and could reduce number of wakeups.

Yes, I agree about that. But my comment was about not making this
behaviour mandatory for splice(). Letting the application choose is
the way to go, of course.

> (Next blocking point is the fixed limit of 16 pages per pipe, but
> thats another story)

Yes but that's not always easy to guess how many data you can feed
into the pipe. It seems that depending on how the segments are
gathered, you can store between 16 segments and 64 kB. I have
observed some cases in blocking mode where I could not push more
than a few kbytes with a small MSS, indicating to me that all those
segments were each on a distinct page. I don't know precisely how
that's handled internally.

> >> About tcp_recvmsg(), we might also remove the "!timeo" test as well,
> >> more testings are needed.
> > 
> > No right now we can't (we must move it somewhere else at least). Because
> > once at least one byte has been received (copied != 0), no other check
> > will break out of the loop (or at least I have not found it).
> > 
> 
> Of course we cant remove the test totally, but change the logic so that several skb
> might be used/consumed per tcp_recvmsg() call, like your patch did for splice()

OK, I initially understood that you suggested we could simply remove
it like I did for splice.

> Lets focus on functional changes, not on implementation details :)

Agreed :-)

Willy
