From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 11:10:10 +0400
Message-ID: <20060721071009.GA5151@2ka.mipt.ru>
References: <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru> <20060720225908.GA18362@ms2.inr.ac.ru> <20060720.215504.41641534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56018 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030462AbWGUHKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 03:10:23 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060720.215504.41641534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2006 at 09:55:04PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Date: Fri, 21 Jul 2006 02:59:08 +0400
> 
> > > Moving protocol (no matter if it is TCP or not) closer to user allows
> > > naturally control the dataflow - when user can read that data(and _this_
> > > is the main goal), user acks, when it can not - it does not generate
> > > ack. In theory
> > 
> > To all that I rememeber, in theory absence of feedback leads
> > to loss of control yet. The same is in practice, unfortunately.
> > You must say that window is closed, otherwise sender is totally
> > confused.
> 
> Correct, and too large delay even results in retransmits.  You can say
> that RTT will be adjusted by delay of ACK, but if user context
> switches cleanly at the beginning, resulting in near immediate ACKs,
> and then blocks later you will get spurious retransmits.  Alexey's
> example of blocking on a disk write is a good example.  I really don't
> like when pure NULL data sinks are used for "benchmarking" these kinds
> of things because real applications 1) touch the data, 2) do something
> with that data, and 3) have some life outside of TCP!

And what will happen with sockets?
Data will arive and ack will be generated, until queue is filled and
duplicate ack started to be sent thus reducing window even more.

Results _are_ the same, both will have duplicate acks and so on, but
with netchannels there is no complex queue management, no two or more
rings, where data is procesed (bh, process context and so on), no locks
and ... hugh, I reacll I wrote it already several times :)

My userspace applications do memset, and actually writing data into
/dev/null through the stdout pipe does not change the overall picture.

I read a lot of your critics about benchmarking, so I'm ready :)

> If you optimize an application that does nothing with the data it
> receives, you have likewise optimized nothing :-)

I've run that test - dump all data into file through pipe.

84byte packet bulk receiving: 

netchannels: 8 Mb/sec (down 6 when VFS cache is filled)
socket: 7 Mb/sec (down to 6 when VFS cache is filled)

So you asked to create narrow pipe, and speed becomes equal to the speed
of that pipe. No more, no less.

> All this talk reminds me of one thing, how expensive tcp_ack() is.
> And this expense has nothing to do with TCP really.  The main cost is
> purging and freeing up the skbs which have been ACK'd in the
> retransmit queue.

Yes, allocation always takes first places in all profiles.
I'm working to eliminate that - it is a "side effect" of zero-copy
networking design I'm working on right now.

> So tcp_ack() sort of inherits the cost of freeing a bunch of SKBs
> which haven't been touched by the cpu in some time and are thus nearly
> guarenteed to be cold in the cache.
> 
> This is the kind of work we could think about batching to user
> sleeping on some socket call.
> 
> Also notice that retransmit queue is potentially a good use of an
> array similar VJ netchannel lockless queue data structure. :)

Array has a lot of disadvantages with it's resizing, there will be a lot
of troubles with recv/send queue len changes.
But it allows to remove several pointer from skb, which is always a good
start.

> BTW, notice that TSO makes this work touch less skb state.  TSO also
> decreases cpu utilization.  I think these two things are no
> coincidence. :-)

TSO/GSO is a good idea definitely, but it is completely unrelated to
other problems. If it will be implemented with netchannels we will have
even better perfomance.

-- 
	Evgeniy Polyakov
