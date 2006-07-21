From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 00:47:13 -0700 (PDT)
Message-ID: <20060721.004713.71097915.davem@davemloft.net>
References: <20060720225908.GA18362@ms2.inr.ac.ru>
	<20060720.215504.41641534.davem@davemloft.net>
	<20060721071009.GA5151@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26855
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964855AbWGUHrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 03:47:15 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060721071009.GA5151@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 21 Jul 2006 11:10:10 +0400

> On Thu, Jul 20, 2006 at 09:55:04PM -0700, David Miller (davem@davemloft.net) wrote:
> > Correct, and too large delay even results in retransmits.  You can say
> > that RTT will be adjusted by delay of ACK, but if user context
> > switches cleanly at the beginning, resulting in near immediate ACKs,
> > and then blocks later you will get spurious retransmits.  Alexey's
> > example of blocking on a disk write is a good example.  I really don't
> > like when pure NULL data sinks are used for "benchmarking" these kinds
> > of things because real applications 1) touch the data, 2) do something
> > with that data, and 3) have some life outside of TCP!
> 
> And what will happen with sockets?
> Data will arive and ack will be generated, until queue is filled and
> duplicate ack started to be sent thus reducing window even more.
> 
> Results _are_ the same, both will have duplicate acks and so on, but
> with netchannels there is no complex queue management, no two or more
> rings, where data is procesed (bh, process context and so on), no locks
> and ... hugh, I reacll I wrote it already several times :)

Packets will be retransmitted spuriously and unnecessarily, and we
cannot over-stress how bad this is.

Sure, your local 1gbit network can absorb this extra cost when
the application is blocked for a long time, but in the real internet
it is a real concern.

Please address the fact that your design makes for retransmits that
are totally unnecessary.  Your TCP stack is flawed if it allows this
to happen.  Proper closing of window and timely ACKs are not some
optional feature of TCP, they are in fact mandatory.

If you want to bypass these things, this is fine, but do not name it
TCP :-)))

As a related example, deeply stretched ACKs can help and are perfect
when there is no packet loss.  But in the event of packet loss a
stretch ACK will kill performance, because it makes packet loss
recovery take at least one extra round trip to occur.

Therefore I disabled stretch ACKs in the input path of TCP last year.

> > If you optimize an application that does nothing with the data it
> > receives, you have likewise optimized nothing :-)
> 
> I've run that test - dump all data into file through pipe.
> 
> 84byte packet bulk receiving: 
> 
> netchannels: 8 Mb/sec (down 6 when VFS cache is filled)
> socket: 7 Mb/sec (down to 6 when VFS cache is filled)
> 
> So you asked to create narrow pipe, and speed becomes equal to the speed
> of that pipe. No more, no less.

If you cause unnecessary retransmits, you add unnecessary congestion
to the network for other flows.

> > All this talk reminds me of one thing, how expensive tcp_ack() is.
> > And this expense has nothing to do with TCP really.  The main cost is
> > purging and freeing up the skbs which have been ACK'd in the
> > retransmit queue.
> 
> Yes, allocation always takes first places in all profiles.
> I'm working to eliminate that - it is a "side effect" of zero-copy
> networking design I'm working on right now.

When you say these things over and over again, people like Alexey
and myself perceive it as "La la la la, I'm not listening to you
guys"

Our point is not that your work cannot lead you to fixing these
problems.  Our point is that existing TCP stack can have these
problems fixed too!  With advantage that we don't need all the
negative aspects of moving TCP into userspace.

You can eliminate allocation overhead in our existing stack, with
the simple design I outlined.  In fact, I outlined two approaches,
there is such an abundance of ways to do it that you have a choice
of which one you like the best :)

> Array has a lot of disadvantages with it's resizing, there will be a lot
> of troubles with recv/send queue len changes.
> But it allows to remove several pointer from skb, which is always a good
> start.

Yes it is something to consider.  Large pipes with 4000+ packet
windows present considerable problems in this area.

> TSO/GSO is a good idea definitely, but it is completely unrelated to
> other problems. If it will be implemented with netchannels we will have
> even better perfomance.

I like TSO-like ideas because it points to solutions within existing
stack.

Radical changes are great, when they buy us something that is
"impossible" with current design.  A lot of things being shown and
discussed here are indeed possible with current design.

You have a nice toy and you should be proud of it, but do not make
it into panacea.
