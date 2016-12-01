From: Tom Herbert <tom@herbertland.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 11:51:42 -0800
Message-ID: <CALx6S36ywu3ruY7AFKYk=N4Ekr5zjY33ivx92EgNNT36XoXhFA@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201024407.GE26507@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:35196 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcLATvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:51:44 -0500
Received: by mail-qt0-f182.google.com with SMTP id c47so231594228qtc.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 11:51:43 -0800 (PST)
In-Reply-To: <20161201024407.GE26507@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 6:44 PM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <tom@herbertland.com> wrote:
>> Posting for discussion....
>
> Warning: You are not going to like this reply...
>
>> Now that XDP seems to be nicely gaining traction
>
> Yes, I regret to see that.  XDP seems useful to create impressive
> benchmark numbers (and little else).
>
> I will send a separate email to keep that flamebait part away from
> this thread though.
>
> [..]
>
>> addresses the performance gap for stateless packet processing). The
>> problem statement is analogous to that which we had for XDP, namely
>> can we create a mode in the kernel that offer the same performance
>> that is seen with L4 protocols over kernel bypass
>
> Why?  If you want to bypass the kernel, then DO IT.
>
I don't want kernel bypass. I want the Linux stack to provide
something close to bare metal performance for TCP/UDP for some latency
sensitive applications we run.

> There is nothing wrong with DPDK.  The ONLY problem is that the kernel
> does not offer a userspace fastpath like Windows RIO or FreeBSDs netmap.
>
> But even without that its not difficult to get DPDK running.
>
That is not true for large scale deployments. Also, TXDP is about
accelerating transport layers like TCP, DPDK is just the interface
from userspace to device queues. We need a whole lot more with DPDK, a
userspace TCP/IP stack for instance, to consider that we have an
equivalent functionality.

> (T)XDP seems born from spite, not technical rationale.
> IMO everyone would be better off if we'd just have something netmap-esqe
> in the network core (also see below).
>
>> I imagine there are a few reasons why userspace TCP stacks can get
>> good performance:
>>
>> - Spin polling (we already can do this in kernel)
>> - Lockless, I would assume that threads typically have exclusive
>> access to a queue pair for a connection
>> - Minimal TCP/IP stack code
>> - Zero copy TX/RX
>> - Light weight structures for queuing
>> - No context switches
>> - Fast data path for in order, uncongested flows
>> - Silo'ing between application and device queues
>
> I only see two cases:
>
> 1. Many applications running (standard Os model) that need to
> send/receive data
> -> Linux Network Stack
>
> 2. Single dedicated application that does all rx/tx
>
> -> no queueing needed (can block network rx completely if receiver
> is slow)
> -> no allocations needed at runtime at all
> -> no locking needed (single produce, single consumer)
>
> If you have #2 and you need to be fast etc then full userspace
> bypass is fine.  We will -- no matter what we do in kernel -- never
> be able to keep up with the speed you can get with that
> because we have to deal with #1.  (Plus the ease of use/freedom of doing
> userspace programming).  And yes, I think that #2 is something we
> should address solely by providing netmap or something similar.
>
> But even considering #1 there are ways to speed stack up:
>
> I'd kill RPF/RPS so we don't have IPI anymore and skb stays
> on same cpu up to where it gets queued (ofo or rx queue).
>
The reference to RPS and RFS is only to move packets off the hot CPU
that are not in the datapath. For instance if we get a FIN for a
connection it we can put this into a slow path since FIN processing is
not latency sensitive but may take a considerable amount of CPU to
process.

> Then we could tell driver what happened with the skb it gave us, e.g.
> we can tell driver it can do immediate page/dma reuse, for example
> in pure ack case as opposed to skb sitting in ofo or receive queue.
>
> (RPS/RFS functionality could still be provided via one of the gazillion
>  hooks we now have in the stack for those that need/want it), so I do
> not think we would lose functionality.
>
>>   - Call into TCP/IP stack with page data directly from driver-- no
>> skbuff allocation or interface. This is essentially provided by the
>> XDP API although we would need to generalize the interface to call
>> stack functions (I previously posted patches for that). We will also
>> need a new action, XDP_HELD?, that indicates the XDP function held the
>> packet (put on a socket for instance).
>
> Seems this will not work at all with the planned page pool thing when
> pages start to be held indefinitely.
>
The processing needed to gift a page to the stack shouldn't be very
different than what a driver needs to do when and skbuff is created
when XDP_PASS is returned. We probably would want to pass additional
meta data, things like checksum and vlan information from received
descriptor to the stack. A callback can be included if the stack
decides it wants to hold on to the buffer and driver needs to do
dma_sync etc. for that.

> You can also never get even close to userspace offload stacks once you
> need/do this; allocations in hotpath are too expensive.
>
> [..]
>
>>   - When we transmit, it would be nice to go straight from TCP
>> connection to an XDP device queue and in particular skip the qdisc
>> layer. This follows the principle of low latency being first criteria.
>
> It will never be lower than userspace offloads so anyone with serious
> "low latency" requirement (trading) will use that instead.
>
Maybe, but the question is how close can we get? If we can get within
say 10-20% performance that would be a win.

> Whats your target audience?
>
Many applications, but the most recent one that seems to driving the
need for very low latency is machine learning. The competition here
really isn't DPDK but is still RDMA (tomorrow's technology for the
past twenty years ;-) ). When the apps guys run their tests, they see
a huge difference between RDMA performance and the stack out of the
box-- like latency for an op goes from 1 usec to 30 usecs. So the apps
guys naturally want RDMA, but anyone in kernel or network ops knows
the nightmare that deploying RDMA entails. If we can get the latencies
and variance down to something comparable (say <5 usecs) then we have
much stronger argument that we can avoid the immense costs that RDMA
brings in.

>> longer latencies in effect which likely means TXDP isn't appropriate
>> in such a cases. BQL is also out, however we would want the TX
>> batching of XDP.
>
> Right, congestion control and buffer bloat are totally overrated .. 8-(
>
> So far I haven't seen anything that would need XDP at all.
>
> What makes it technically impossible to apply these miracles to the
> stack...?
>
> E.g. "mini-skb": Even if we assume that this provides a speedup
> (where does that come from? should make no difference if a 32 or
>  320 byte buffer gets allocated).
>
It's the zero'ing of three cache lines. I believe we talked about that
as netdev.

> If we assume that its the zeroing of sk_buff (but iirc it made little
> to no difference), could add
>
> unsigned long skb_extensions[1];
>
> to sk_buff, then move everything not needed for tcp fastpath
> (e.g. secpath, conntrack, nf_bridge, tunnel encap, tc, ...)
> below that
>
Yes, that's the intent.

> Then convert accesses to accessors and init it on demand.
>
> One could probably also split cb[] into a smaller fastpath area
> and another one at the end that won't be touched at allocation time.
>
>> Miscellaneous
>
>> contemplating that connections/sockets can be bound to particularly
>> CPUs and that any operations (socket operations, timers, receive
>> processing) must occur on that CPU. The CPU would be the one where RX
>> happens. Note this implies perfect silo'ing, everything for driver RX
>> to application processing happens inline on the CPU. The stack would
>> not cross CPUs for a connection while in this mode.
>
> Again don't see how this relates to xdp.  Could also be done with
> current stack if we make rps/rfs pluggable since nothing else
> currently pushes skb to another cpu (except when scheduler is involved
> via tc mirred, netfilter userspace queueing etc) but that is always
> explicit (i.e. skb leaves softirq protection).
>
> Can we please fix and improve what we already have rather than creating
> yet another NIH thing that will have to be maintained forever?
>
That's what we are doing and this is major reason what we need to
improve Linux as opposed introducing to parallel stacks. The cost for
supporting modifications to Linux pale in comparison to we would need
to support a parallel stack.

Tom

> Thanks.
