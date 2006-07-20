From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 20 Jul 2006 20:41:00 +0400
Message-ID: <20060720164100.GA9213@ms2.inr.ac.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:155 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030364AbWGTQlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 12:41:31 -0400
To: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Content-Disposition: inline
In-Reply-To: <20060720073223.GA15567@tservice.net.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Small question first:

> userspace, but also there are big problems, like one syscall per ack,

I do not see redundant syscalls. Is not it expected to send ACKs only
after receiving data as you said? What is the problem?


Now boring things:

> There is no BH protocol processing at all, so there is no need to
> pprotect against someone who will add data while you are processing own
> chunk.

Essential part of socket user lock is the same mutex.

Backlog is actually not a protection, but a thing equivalent to netchannel.
The difference is only that it tries to process something immediately,
when it is safe. You can omit this and push everything to backlog(=netchannel),
which is processed only by syscalls, if you do not care about latency.


> How many hacks just to be a bit closer to userspace processing,
> implemented in netchannels!

Moving processing closer to userspace is not a goal, it is a tool.
Which sometimes useful, but generally quite useless.

F.e. in your tests it should not affect performance at all,
end user is just a sink.

What's about prequeueing, it is a bright example. Guess why is it useful?
What does it save? Nothing, like netchannel. Answer is: it is just a tool
to generate coarsed ACKs in a controlled manner without essential violation
of protocol. (Well, and to combine checksumming and copy if you do not like how
your card does this)


> If userspace is scheduled away for too much time, it is bloody wrong to
> ack the data, that is impossible to read due to the fact that system is
> being busy. It is just postponing the work from one end to another - ack
> now and stop when queue is full, or postpone the ack generation when
> segment is realy being read.

... when you get all the segments nicely aligned, blah-blah-blah.

If you do not care about losses-congestion-delays-delacks-whatever,
you have a totally different protocol. Sending window feedback
is only a minor part of tcp. But even these boring tcp intrinsics
are not so important, look at ideal lossless network:

Think what happens f.e. while plain file transfer to your notebook.
You get 110MB/sec for a few seconds, then writeback is fired and
disk io subsystems discovers that the disk holds only 50MB/sec.
If you are unlucky and some another application starts, disk is so congested
that it will take lots of seconds to make a progress with io.
For this time another side will retransmit, because poor thing thought
rtt is 100 usecs and you will never return to 50MB/sec.

You have to _CLOSE_ window in the case of long delay, rather than to forget
to ack. See the difference?

It is just because actual "end" user is still far far away.
And this happens all the time, when you relay the results to another
application via pipe, when... Well, the only case where real "end user"
is user of "netchannel" is when you receive to a sink.


> >But I said not this. I said it looks _worse_. A bit, but worse.
> 
> At least for 80 bytes it does not matter at all.

Hello-o, do you hear me? :-)

I am asking: it looks not much better, but a bit worse,
then what is real reason for better performance, unless it is
due to castration of protocol?

Simplify protocol, move all the processing (even memory copies) to softirq,
leave to user space only feeding pages to copy and you will have unbeatable
performance. Been there, done that, not with TCP of course, but if you do not
care about losses and ACK clocking and send an ACK once per window,
I do not see how it can spoil the situation.


> And actually I never understood nanooptimisation behind more serious
> problems (i.e. one cache line vs. 50MB/sec speed).

You deal with 80 byte packets, to all that I understand.
If you lose one cacheline per packet, it is a big problem.

All that we can change is protocol overhead. Handling data part
is invariant anyway. You are scared of complexity of tcp, but
you obviously forget one thing: cpu is fast.
The code can look very complicated: some crazy hash functions,
damn hairy protocol processing, but if you take care about caches etc.,
all this is dominated by the first look into packet in eth_type_trans()
or ip_rcv().

BTW, when you deal with normal data flow, cache can be not dirtied
by data at all, it can be bypassed.


> works perfectly ok, but it is possible to have better performance by
> changing architecture, and it was done.

It is exactly the point of trouble. From all that I see and you said,
better performance is got not due to change of architecture,
but despite of this.

A proof that we can perform better by changing protocol is not required,
it is kinda obvious. The question is how to make existing protocol
to perform better.

I have no idea, why your tcp performs better. It can be everything:
absence of slow start, more coarse ACKs, whatever. I believe you were careful
to check those reasons and to do a fair comparison, but then the only guess
remains that you saved lots of i-cache getting rid of long code path.

And none of those guesses can be attributed to "netchannels". :-)

Alexey
