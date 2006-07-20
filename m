From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 01:08:49 +0400
Message-ID: <20060720210849.GA28715@tservice.net.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.178.208.66] ([195.178.208.66]:23447 "EHLO tservice.net.ru")
	by vger.kernel.org with ESMTP id S1030319AbWGTVIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 17:08:51 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060720164100.GA9213@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2006 at 08:41:00PM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> Hello!

Hello, Alexey.

> Small question first:
> 
> > userspace, but also there are big problems, like one syscall per ack,
> 
> I do not see redundant syscalls. Is not it expected to send ACKs only
> after receiving data as you said? What is the problem?

I mean that each ack is a pure syscall without any data, so overhead is
quite huge compared to the situatin when acks are created in
kernelspace.
At least slow start will eat a lot of CPU with them.

> Now boring things:
> 
> > There is no BH protocol processing at all, so there is no need to
> > pprotect against someone who will add data while you are processing own
> > chunk.
> 
> Essential part of socket user lock is the same mutex.
> 
> Backlog is actually not a protection, but a thing equivalent to netchannel.
> The difference is only that it tries to process something immediately,
> when it is safe. You can omit this and push everything to backlog(=netchannel),
> which is processed only by syscalls, if you do not care about latency.

If we consider netchannels as how Van Jackobson discribed them, then
mutext is not needed, since it is impossible to have several readers or
writers. But in socket case even if there is only one userspace
consumer, that lock must be held to protect against bh (or introduce
several queues and complicate a lot their's management (ucopy for
example)).
 
> > How many hacks just to be a bit closer to userspace processing,
> > implemented in netchannels!
> 
> Moving processing closer to userspace is not a goal, it is a tool.
> Which sometimes useful, but generally quite useless.
> 
> F.e. in your tests it should not affect performance at all,
> end user is just a sink.
> 
> What's about prequeueing, it is a bright example. Guess why is it useful?
> What does it save? Nothing, like netchannel. Answer is: it is just a tool
> to generate coarsed ACKs in a controlled manner without essential violation
> of protocol. (Well, and to combine checksumming and copy if you do not like how
> your card does this)

I can not agree here. 
The main goal of the protocol is data delivery to the user, but not
it's blind accepting and data transmit from user, but not some other
ring.
As you see, sending is already implemented in process' context,
but receiving is not directly connected to the user.
THe more elemnts between user and it's data we have, the more
probability of some problems there. And we already have two queues just
to eliminate one of them.
Moving protocol (no matter if it is TCP or not) closer to user allows
naturally control the dataflow - when user can read that data(and _this_
is the main goal), user acks, when it can not - it does not generate
ack. In theory that can lead to the full absence of the congestions,
especially if receiving window can be controlled in both directions.
At least with current state of routers it does not lead to the broken
connections.

> > If userspace is scheduled away for too much time, it is bloody wrong to
> > ack the data, that is impossible to read due to the fact that system is
> > being busy. It is just postponing the work from one end to another - ack
> > now and stop when queue is full, or postpone the ack generation when
> > segment is realy being read.
> 
> ... when you get all the segments nicely aligned, blah-blah-blah.
> 
> If you do not care about losses-congestion-delays-delacks-whatever,
> you have a totally different protocol. Sending window feedback
> is only a minor part of tcp. But even these boring tcp intrinsics
> are not so important, look at ideal lossless network:
> 
> Think what happens f.e. while plain file transfer to your notebook.
> You get 110MB/sec for a few seconds, then writeback is fired and
> disk io subsystems discovers that the disk holds only 50MB/sec.
> If you are unlucky and some another application starts, disk is so congested
> that it will take lots of seconds to make a progress with io.
> For this time another side will retransmit, because poor thing thought
> rtt is 100 usecs and you will never return to 50MB/sec.
> 
> You have to _CLOSE_ window in the case of long delay, rather than to forget
> to ack. See the difference?
> 
> It is just because actual "end" user is still far far away.
> And this happens all the time, when you relay the results to another
> application via pipe, when... Well, the only case where real "end user"
> is user of "netchannel" is when you receive to a sink.

There is one problem in your logic.
RTT will not be so small, since acks are not sent when user does not
read data.

> > >But I said not this. I said it looks _worse_. A bit, but worse.
> > 
> > At least for 80 bytes it does not matter at all.
> 
> Hello-o, do you hear me? :-)
> 
> I am asking: it looks not much better, but a bit worse,
> then what is real reason for better performance, unless it is
> due to castration of protocol?

Well, if speed would be measured in lines of code, that atcp gets far less than
existing tcp, but performance win is only 2.5 times.

> Simplify protocol, move all the processing (even memory copies) to softirq,
> leave to user space only feeding pages to copy and you will have unbeatable
> performance. Been there, done that, not with TCP of course, but if you do not
> care about losses and ACK clocking and send an ACK once per window,
> I do not see how it can spoil the situation.

Do you live in a perfect world, where user does not want what was
requested? I thought we both live in Russia or at least on the same Earth. 
I'm not 100% sure now...

Userspace needs that data, and it gets
it with netchannels (and sends it, and copies using copy_to_user()).
 
> > And actually I never understood nanooptimisation behind more serious
> > problems (i.e. one cache line vs. 50MB/sec speed).
> 
> You deal with 80 byte packets, to all that I understand.
> If you lose one cacheline per packet, it is a big problem.

So actual netchannels speed is even better? :)

> All that we can change is protocol overhead. Handling data part
> is invariant anyway. You are scared of complexity of tcp, but
> you obviously forget one thing: cpu is fast.
> The code can look very complicated: some crazy hash functions,
> damn hairy protocol processing, but if you take care about caches etc.,
> all this is dominated by the first look into packet in eth_type_trans()
> or ip_rcv().

I think I start to repeat myself: cache issues are the same.
You get headers into the cache in bh/interrupt time, you ron protocol
processing. softirq is completed, block layer flushes everything away,
you run recv() -> tcp_recvmsg() which loads into the cache skb->cb.
Point.

> BTW, when you deal with normal data flow, cache can be not dirtied
> by data at all, it can be bypassed.

You cut the lines about misaligned data, which is very common case.
So part of the header is in a cache line. You also cut lines about
exactly the same problem with existing code, since it stores a lot of
variables in skb->cb which is flushed away too.

You forget to say that with disabled bh you must done a lot of things -
ack (with atomic allocation), queueing, out-of-ordder handling and much
more. And then your process is scheduled away, skb->cb and other
variables are flushed away, and in tcp_recvmsg() time you get them
again. And you never measured that impact on performance, as long as I
never did that too, since it is quite hard to determine how much is the
cache line flushing price and how many of them were removed.
In theory it is perfect, but in practice netchannels perform much
better, although they have "all those problems"...
If protocol is "castrated", but it still allows to work faster, then
tell me, why we should keep (enabled) that redundant functionality?
Because it can work better in some other places, and that is correct,
but why it should be enabled then in majority of the cases?
 
> > works perfectly ok, but it is possible to have better performance by
> > changing architecture, and it was done.
> 
> It is exactly the point of trouble. From all that I see and you said,
> better performance is got not due to change of architecture,
> but despite of this.
> 
> A proof that we can perform better by changing protocol is not required,
> it is kinda obvious. The question is how to make existing protocol
> to perform better.
> 
> I have no idea, why your tcp performs better. It can be everything:
> absence of slow start, more coarse ACKs, whatever. I believe you were careful
> to check those reasons and to do a fair comparison, but then the only guess
> remains that you saved lots of i-cache getting rid of long code path.
> 
> And none of those guesses can be attributed to "netchannels". :-)

Well, atcp does have slow start, I implemented several ack generation algos,
and there was noticeble difference, but in any case netchannels were
faster, there were used several different MSS combining methods, and a
lot of testing to achieve current state of the atcp, so I think protocol
itself can produce some gain in performance. Cache issues are the same.

Let's draw the line.

You do not know, why netchannels work faster, but you are sure it
is not because of protocol processing happens in process context,
since you do not know why it can help in that case.

I understand your position.

My point of view, as one can expect, differs  from yours - netchannels
perform faster not only because of different TCP implementation, but
because of architectural changes (no BH/irq processing, no bh/irq locks, 
no complex queue management, no atomic allocations, no false (I do
understand that it is wrong word in this context, but from above one can
see, what I mean) acks, thus no possible queue overfull, natural flow
control and other things).

According to your logic, it is impossible to have faster processing
(with existing socket code), when protocol management is moved totally
into process context, but I showed with my initial netchannel implementation,
that it can be done - and there was small, but 100% reproducible steady
performance win (about 2-3 MB/sec and several % of CPU usage) with
big-sized chunks. Unfortunately I did not test small-sized ones, which
show big perfomance win with netchannels and atcp. Those results were
not enough for me, so I implemented different stack, which does not
have anything related to the two step processing, and it can be one of the reasons
for faster processing. It can have bugs, but the whole idea was proven
to be absolutely correct (when using either socket code, or atcp).

That was my opinion on the topic. It looks like neither you, nor me will
not change our point of view about that right now :)
But anyway it is a good discussion, let's see what others think about
it.

> Alexey

-- 
	Evgeniy Polyakov
