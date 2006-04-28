From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 10:05:03 +0400
Message-ID: <20060428060503.GC17360@2ka.mipt.ru>
References: <200604271331.37073.kelly@au.ibm.com> <20060426.232501.119306252.davem@davemloft.net> <20060427115126.GA11570@2ka.mipt.ru> <20060427.130918.65400512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kelly@au1.ibm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36049 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965195AbWD1GGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 02:06:06 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060427.130918.65400512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2006 at 01:09:18PM -0700, David S. Miller (davem@davemloft.net) wrote:
> Evgeniy, the difference between this and your work is that you did not
> have an intelligent piece of hardware that could be told to recognize
> flows, and only put packets for a specific flow into that's flow's
> buffer pool.

There are the most "intellegent" NICs which use MMIO copy like Realtek 8139 :)
which were used in receiving zero-copy [1] project.

There was special alorithm researched for receiving zero-copy [1] to allow 
to put not page-aligned TCP frames into pages, but there was other
problem when page was committed, since no byte commit is allowed in VFS.

In this case we do not have that problem, but instead we must force userspace to
be very smart when dealing with mapped buffers, instead of simple recv().
And for sending it must be even smarter, since data must be properly
aligned. And what about crappy hardware which can DMA only into limited
memory area, or NIC that can not do sg? Or do we need remapping for NIC
that can not do checksum calculation?

> > If we want to dma data from nic into premapped userspace area, this will
> > strike with message sizes/misalignment/slow read and so on, so
> > preallocation has even more problems.
> 
> I do not really think this is an issue, we put the full packet into
> user space and teach it where the offset is to the actual data.
> We'll do the same things we do today to try and get the data area
> aligned.  User can do whatever is logical and relevant on his end
> to deal with strange cases.
> 
> In fact we can specify that card has to take some care to get data
> area of packet aligned on say an 8 byte boundary or something like
> that.  When we don't have hardware assist, we are going to be doing
> copies.

Userspace must be too smart, and as we saw with various java tests, it
can not be so even now.
And what if pages are shared and several threads are trying to write
into the same remapped area? Will we use COW and be blamed like Mach
and FreeBSD developers? :)

> > I do think that significant win in VJ's tests belongs not to remapping
> > and cache-oriented changes, but to move all protocol processing into
> > process' context.
> 
> I partly disagree.  The biggest win is eliminating all of the control
> overhead (all of "softint RX + protocol demux + IP route lookup +
> socket lookup" is turned into single flow demux), and the SMP safe
> data structure which makes it realistic enough to always move the bulk
> of the packet work to the socket's home cpu.
> 
> I do not think userspace protocol implementation buys enough to
> justify it.  We have to do the protection switch in and out of kernel
> space anyways, so why not still do the protected protocol processing
> work in the kernel?  It is still being done on the user's behalf,
> contributes to his time slice, and avoids all of the terrible issues
> of userspace protocol implementations.

After hard irq softirq is scheduled, then later userspace is scheduled,
at least 2 context switch just to move a packet, and "slow" userspace
code is interrupted by both irqs again...
I run some tests on ppc32 embedded boards which showed that rescheduling
latency tend to have milliseconds delay sometimes (about 4 running processes
on 200mhz cpu), although we do not have some real-time requirements here
it is not a good sign...

> And I also want to note that even if the whole idea explodes and
> cannot be made to work, there are good arguments for transitioning
> to SKB'less drivers for their own sake.  So work will really not
> be lost.
> 
> Let's have 100 different implementations of net channels! :-)

:)

-- 
	Evgeniy Polyakov
