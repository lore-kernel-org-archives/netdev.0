From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 13:06:11 +0400
Message-ID: <20060721090610.GF5151@2ka.mipt.ru>
References: <20060720225908.GA18362@ms2.inr.ac.ru> <20060720.215504.41641534.davem@davemloft.net> <20060721071009.GA5151@2ka.mipt.ru> <20060721.004713.71097915.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:22195 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030428AbWGUJG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 05:06:59 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060721.004713.71097915.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 12:47:13AM -0700, David Miller (davem@davemloft.net) wrote:
> > > Correct, and too large delay even results in retransmits.  You can say
> > > that RTT will be adjusted by delay of ACK, but if user context
> > > switches cleanly at the beginning, resulting in near immediate ACKs,
> > > and then blocks later you will get spurious retransmits.  Alexey's
> > > example of blocking on a disk write is a good example.  I really don't
> > > like when pure NULL data sinks are used for "benchmarking" these kinds
> > > of things because real applications 1) touch the data, 2) do something
> > > with that data, and 3) have some life outside of TCP!
> > 
> > And what will happen with sockets?
> > Data will arive and ack will be generated, until queue is filled and
> > duplicate ack started to be sent thus reducing window even more.
> > 
> > Results _are_ the same, both will have duplicate acks and so on, but
> > with netchannels there is no complex queue management, no two or more
> > rings, where data is procesed (bh, process context and so on), no locks
> > and ... hugh, I reacll I wrote it already several times :)
> 
> Packets will be retransmitted spuriously and unnecessarily, and we
> cannot over-stress how bad this is.

In theory practice and theory are the same, but in practice they are
different (c) Larry McVoy as far as I recall :)
And even in theory Linux behaves the same.

I see the only point about process context tcp processing is following
issue:
we started tcp connection, and acks are generated very fast, then
suddenly receiving userspace is blocked.
In that case BH processing apologists state that sending side starts to
retransmit.
Let's see how it works.
If receiving side works for a long with maximum speed, then window is
opened enough, so it can even exceed socket buffer size (max 200k, I saw
several megs socket windows in my tests), so sending side will continue
to send until window is filled. 
Receiving side, nor matter if it is socket or netchannel, will drop
packets (socket due to queue overfull, netchannels will not drop, but
will not ack (it's maximum queue len is 1mb)).

So both approaches behave _exactly_ the same.
Did I miss something?

Btw, here are tests which were ran with netchannels:
 * surfing the web (index pages of different remote sites only)
 * 1gb transfers
 * 1gb <-> 100mb transfers

> Sure, your local 1gbit network can absorb this extra cost when
> the application is blocked for a long time, but in the real internet
> it is a real concern.

Writing into the pipe (or into 100mb NIC) and file is a real internet 
example - data is blocked, acks and retransmits happen.

> Please address the fact that your design makes for retransmits that
> are totally unnecessary.  Your TCP stack is flawed if it allows this
> to happen.  Proper closing of window and timely ACKs are not some
> optional feature of TCP, they are in fact mandatory.
> 
> If you want to bypass these things, this is fine, but do not name it
> TCP :-)))

Hey, you did not look into atcp.c in my patches :)

> As a related example, deeply stretched ACKs can help and are perfect
> when there is no packet loss.  But in the event of packet loss a
> stretch ACK will kill performance, because it makes packet loss
> recovery take at least one extra round trip to occur.
> 
> Therefore I disabled stretch ACKs in the input path of TCP last year.

For slow start it is definitely a must.
If stretching alog is based on timers and round trip time, then I do not
have that in atcp, but proper delaying based on sequence is used instead.

> > > If you optimize an application that does nothing with the data it
> > > receives, you have likewise optimized nothing :-)
> > 
> > I've run that test - dump all data into file through pipe.
> > 
> > 84byte packet bulk receiving: 
> > 
> > netchannels: 8 Mb/sec (down 6 when VFS cache is filled)
> > socket: 7 Mb/sec (down to 6 when VFS cache is filled)
> > 
> > So you asked to create narrow pipe, and speed becomes equal to the speed
> > of that pipe. No more, no less.
> 
> If you cause unnecessary retransmits, you add unnecessary congestion
> to the network for other flows.

Please refer to my description above.
Situation is perfectly the same as with socket code or with netchannels.

> > > All this talk reminds me of one thing, how expensive tcp_ack() is.
> > > And this expense has nothing to do with TCP really.  The main cost is
> > > purging and freeing up the skbs which have been ACK'd in the
> > > retransmit queue.
> > 
> > Yes, allocation always takes first places in all profiles.
> > I'm working to eliminate that - it is a "side effect" of zero-copy
> > networking design I'm working on right now.
> 
> When you say these things over and over again, people like Alexey
> and myself perceive it as "La la la la, I'm not listening to you
> guys"

Hmm, I've confirmed that allocation is a problem no matter which stack
is used. My problem fix has nothing special to netchannels at all.

> Our point is not that your work cannot lead you to fixing these
> problems.  Our point is that existing TCP stack can have these
> problems fixed too!  With advantage that we don't need all the
> negative aspects of moving TCP into userspace.
> 
> You can eliminate allocation overhead in our existing stack, with
> the simple design I outlined.  In fact, I outlined two approaches,
> there is such an abundance of ways to do it that you have a choice
> of which one you like the best :)

TCP stack has nothing to the allocation problem, and I work on
eliminating that problem regardless high-level interface.
Stack should net be fixed, if allocation takes too long.

> > Array has a lot of disadvantages with it's resizing, there will be a lot
> > of troubles with recv/send queue len changes.
> > But it allows to remove several pointer from skb, which is always a good
> > start.
> 
> Yes it is something to consider.  Large pipes with 4000+ packet
> windows present considerable problems in this area.
> 
> > TSO/GSO is a good idea definitely, but it is completely unrelated to
> > other problems. If it will be implemented with netchannels we will have
> > even better perfomance.
> 
> I like TSO-like ideas because it points to solutions within existing
> stack.
> 
> Radical changes are great, when they buy us something that is
> "impossible" with current design.  A lot of things being shown and
> discussed here are indeed possible with current design.
>
> You have a nice toy and you should be proud of it, but do not make
> it into panacea.

I do not force anyone to use netchannels - yes, one can consider it as a
toy. That toy has a lot inside and that toy proved that it is correct 
(with existing stack too).

No need to say a panacea, since there is no sickness.
Socket code has it's own design and it fits it's needs perfectly.
If we want to move further, something must be changed, since all of
_addons_ to the exisintg design do not and can not _change_ it's nature
(I do not say, that it is a problem, but nature of the existing network
stack design), and that addons (like TSO, GSO and any other) helps to
any stack, but stack itself is not a problem. 

I do not want to say, that existing tcp has bugs and must be replaced
with my implementation, or that socket code has bugs, and must be
replaced with netchannels. 

When moving outside existing design it is possible to have all those
advantages _and_ additional gains from removing several levels of
processing, simplification of the low-level data (queues and locks),
allocation changes (no more atomic allocations) and so on.

That's it.

-- 
	Evgeniy Polyakov
