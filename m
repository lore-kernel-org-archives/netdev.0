From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 13:09:18 -0700 (PDT)
Message-ID: <20060427.130918.65400512.davem@davemloft.net>
References: <200604271331.37073.kelly@au.ibm.com>
	<20060426.232501.119306252.davem@davemloft.net>
	<20060427115126.GA11570@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kelly@au1.ibm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56460
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030215AbWD0UJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 16:09:40 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060427115126.GA11570@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 27 Apr 2006 15:51:26 +0400

> There are some caveats here found while developing zero-copy sniffer
> [1]. Project's goal was to remap skbs into userspace in real-time.
> While absolute numbers (posted to netdev@) were really high, it is only
> applicable to read-only application. As was shown in IOAT thread,
> data must be warmed in caches, so reading from mapped area will be as
> fast as memcpy() (read+write), and copy_to_user() actually almost equal
> to memcpy() (benchmarks were posted to netdev@). And we must add
> remapping overhead.

Yes, all of these issues are related quite strongly.  Thanks for
making the connection explicit.

But, the mapping overhead is zero for this net channel stuff, at
least as it is implemented and designed by Kelly.  Ring buffer is
setup ahead of time into the user's address space, and a ring of
buffers into that area are given to the networking card.

We remember the translations here, so no get_user_pages() on each
transfer and garbage like that.  And yes this all harks back to the
issues that are discussed in Chapter 5 of Networking Algorithmics.
But the core thing to understand is that by defining a new API and
setting up the buffer pool ahead of time, we avoid all of the
get_user_pages() overhead while retaining full kernel/user protection.

Evgeniy, the difference between this and your work is that you did not
have an intelligent piece of hardware that could be told to recognize
flows, and only put packets for a specific flow into that's flow's
buffer pool.

> If we want to dma data from nic into premapped userspace area, this will
> strike with message sizes/misalignment/slow read and so on, so
> preallocation has even more problems.

I do not really think this is an issue, we put the full packet into
user space and teach it where the offset is to the actual data.
We'll do the same things we do today to try and get the data area
aligned.  User can do whatever is logical and relevant on his end
to deal with strange cases.

In fact we can specify that card has to take some care to get data
area of packet aligned on say an 8 byte boundary or something like
that.  When we don't have hardware assist, we are going to be doing
copies.

> This change also requires significant changes in application, at least
> until recv/send are changed, which is not the best thing to do.

This is exactly the point, we can only do a good job and receive zero
copy if we can change the interfaces, and that's exactly what we're
doing here.

> I do think that significant win in VJ's tests belongs not to remapping
> and cache-oriented changes, but to move all protocol processing into
> process' context.

I partly disagree.  The biggest win is eliminating all of the control
overhead (all of "softint RX + protocol demux + IP route lookup +
socket lookup" is turned into single flow demux), and the SMP safe
data structure which makes it realistic enough to always move the bulk
of the packet work to the socket's home cpu.

I do not think userspace protocol implementation buys enough to
justify it.  We have to do the protection switch in and out of kernel
space anyways, so why not still do the protected protocol processing
work in the kernel?  It is still being done on the user's behalf,
contributes to his time slice, and avoids all of the terrible issues
of userspace protocol implementations.

So in my mind, the optimal situation from both a protection preservation
and also a performance perspective is net channels to kernel socket
protocol processing, buffers DMA'd directly into userspace if hardware
assist is present.

> I fully agree with Dave that it must be implemented step-by-step, and
> the most significant, IMHO, is moving protocol processing into socket's
> "place". This will force to netfilter changes, but I do think that for
> the proof-of-concept code we can turn it off.

And I also want to note that even if the whole idea explodes and
cannot be made to work, there are good arguments for transitioning
to SKB'less drivers for their own sake.  So work will really not
be lost.

Let's have 100 different implementations of net channels! :-)
