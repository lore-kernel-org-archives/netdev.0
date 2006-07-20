From: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 20 Jul 2006 11:32:23 +0400
Message-ID: <20060720073223.GA15567@tservice.net.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.178.208.66] ([195.178.208.66]:35772 "EHLO tservice.net.ru")
	by vger.kernel.org with ESMTP id S964826AbWGTHc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 03:32:26 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060719131915.GA21942@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hello!

Hello, Alexey.

[ Sorry for long delay, there are some problems with mail servers, so I
can not access them remotely, so I create mail by hads, hopefully thread
will not be broken. ]

>> There is no socket spinlock anymore.
>> Above lock is skb_queue lock which is held inside
>> skb_dequeue/skb_queue_tail calls.

> Lock is named differently, but it is still here.
> BTW for UDP even the name is the same.

There is no bh processing, that lock is needed for 4 operations when skb
is enqueued/dequeued.

And if I would changed skbs to different structures there were no locks
at all - it is extremely lightweight, it can not be compared with socket
lock at all.

No bh/irq processing at all, natural speed management - that is main idea
behind netchannels.

>> > Equivalent of socket user lock.
>> 
>> No, it is an equivalent for hash lock in socket table.

>OK. But you have to introduce socket mutex somewhere in any case.
>Even in ATCP.

Actually not - VJ's idea is to have only one consumer and one provider,
so no locks needed, but I agree, in general case it is needed, but _only_
to protect against several netchannel userspace consumers.
There is no BH protocol processing at all, so there is no need to
pprotect against someone who will add data while you are processing own
chunk.

>> Just an example - tcp_established() can be called with bh disabled
>> under the socket lock.

> When we have a process context in hands, it is not.

>Did you ask youself, why do not we put all the packets to
>backlog/prequeue
>and just wait when user will read the data? It would be 100% equivalent
>to "netchannels".

How many hacks just to be a bit closer to userspace processing,
implemented in netchannels!

>The answer is simple: because we cannot wait. If user delays for
>200msec,
>wait for connection collapse due to retransmissions. If the segment is
>out of order, immediate attention is required. Any scheme, which tries
>to wait for user unconditionally, at least has to run a watchdog timer,
>which fires before sender senses the gap.

If userspace is scheduled away for too much time, it is bloody wrong to
ack the data, that is impossible to read due to the fact that system is
being busy. It is just postponing the work from one end to another - ack
now and stop when queue is full, or postpone the ack generation when
segment is realy being read.

>And this is what we do for ages. Grep for "VJ" in sources. :-)
>netchannels have nothing to do with it, it is much elder idea.

And it was Van, who decided to move away from BH/irq processing.
It was slow and a bit pain way (how many hacks with prequeue, with
direct processing, it is enough just to look how TCP socket lock is locked
in different contexts :)

>> In that case one copies the whole data into userspace, so access for
>> 20 bytes of headers completely does not matter.

>For short packets it matters.

>But I said not this. I said it looks _worse_. A bit, but worse.

At least for 80 bytes it does not matter at all.
And it is very likely that data is misaligned, so half of the
header will be in a cache line. And socket code has the same problem -
skb->cb can be flushed away, and tcp_recvmsg() needs to get it again.
And actually I never understood nanooptimisation behind more serious
problems (i.e. one cache line vs. 50MB/sec speed).

>> Hmm, for 80 bytes sized packets win was about 2.5 times. Could you
>> please show me lines inside existing code, which should be commented,
>> so I got 50Mbyte/sec for that?

>If I knew it would be done. :-)
>
>Actually, it is the action, which I would expect. This, but
>not dropping all the TCP stack.

I tried to use existing one, and I had speed and CPU usage win, but it's
magnitude was not what I expected, so I started userspace network stack
implementation. It was succeded, and there are _very_ major
optimisations over existing code, when processing is fully moved into
userspace, but also there are big problems, like one syscall per ack, 
so I decided to use that stack as a base for in-kernel process protocol 
processing, and I succeded. Probably I will return to the userspace 
network stack idea when I complete zero-copy networking support.

>> I showed there, that using existing stack it is imposible

>Please, understand, it is such statements that compromise your work.
>If it is impossible then it is not interesting.

Do not mix soft and warm - I just post the facts, that netchannel TCP
implementation works (sumetimes much) faster.
It is socket code that probably has some misoptimisations, and if it is
impossible to fix them (well, it least it is very hard), then it is not
interesting.

I definitely do not say, that it must be removed/replaced/anything - it
works perfectly ok, but it is possible to have better performance by
changing architecture, and it was done.

>Alexey

-- 
	Evgeniy Polyakov
