From: Florian Westphal <fw@strlen.de>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 03:44:07 +0100
Message-ID: <20161201024407.GE26507@breakpoint.cc>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:50354 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752576AbcLACrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 21:47:11 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> Posting for discussion....

Warning: You are not going to like this reply...

> Now that XDP seems to be nicely gaining traction

Yes, I regret to see that.  XDP seems useful to create impressive
benchmark numbers (and little else).

I will send a separate email to keep that flamebait part away from
this thread though.

[..]

> addresses the performance gap for stateless packet processing). The
> problem statement is analogous to that which we had for XDP, namely
> can we create a mode in the kernel that offer the same performance
> that is seen with L4 protocols over kernel bypass

Why?  If you want to bypass the kernel, then DO IT.

There is nothing wrong with DPDK.  The ONLY problem is that the kernel
does not offer a userspace fastpath like Windows RIO or FreeBSDs netmap.

But even without that its not difficult to get DPDK running.

(T)XDP seems born from spite, not technical rationale.
IMO everyone would be better off if we'd just have something netmap-esqe
in the network core (also see below).

> I imagine there are a few reasons why userspace TCP stacks can get
> good performance:
> 
> - Spin polling (we already can do this in kernel)
> - Lockless, I would assume that threads typically have exclusive
> access to a queue pair for a connection
> - Minimal TCP/IP stack code
> - Zero copy TX/RX
> - Light weight structures for queuing
> - No context switches
> - Fast data path for in order, uncongested flows
> - Silo'ing between application and device queues

I only see two cases:

1. Many applications running (standard Os model) that need to
send/receive data
-> Linux Network Stack

2. Single dedicated application that does all rx/tx

-> no queueing needed (can block network rx completely if receiver
is slow)
-> no allocations needed at runtime at all
-> no locking needed (single produce, single consumer)

If you have #2 and you need to be fast etc then full userspace
bypass is fine.  We will -- no matter what we do in kernel -- never
be able to keep up with the speed you can get with that
because we have to deal with #1.  (Plus the ease of use/freedom of doing
userspace programming).  And yes, I think that #2 is something we
should address solely by providing netmap or something similar.

But even considering #1 there are ways to speed stack up:

I'd kill RPF/RPS so we don't have IPI anymore and skb stays
on same cpu up to where it gets queued (ofo or rx queue).

Then we could tell driver what happened with the skb it gave us, e.g.
we can tell driver it can do immediate page/dma reuse, for example
in pure ack case as opposed to skb sitting in ofo or receive queue.

(RPS/RFS functionality could still be provided via one of the gazillion
 hooks we now have in the stack for those that need/want it), so I do
not think we would lose functionality.

>   - Call into TCP/IP stack with page data directly from driver-- no
> skbuff allocation or interface. This is essentially provided by the
> XDP API although we would need to generalize the interface to call
> stack functions (I previously posted patches for that). We will also
> need a new action, XDP_HELD?, that indicates the XDP function held the
> packet (put on a socket for instance).

Seems this will not work at all with the planned page pool thing when
pages start to be held indefinitely.

You can also never get even close to userspace offload stacks once you
need/do this; allocations in hotpath are too expensive.

[..]

>   - When we transmit, it would be nice to go straight from TCP
> connection to an XDP device queue and in particular skip the qdisc
> layer. This follows the principle of low latency being first criteria.

It will never be lower than userspace offloads so anyone with serious
"low latency" requirement (trading) will use that instead.

Whats your target audience?

> longer latencies in effect which likely means TXDP isn't appropriate
> in such a cases. BQL is also out, however we would want the TX
> batching of XDP.

Right, congestion control and buffer bloat are totally overrated .. 8-(

So far I haven't seen anything that would need XDP at all.

What makes it technically impossible to apply these miracles to the
stack...?

E.g. "mini-skb": Even if we assume that this provides a speedup
(where does that come from? should make no difference if a 32 or
 320 byte buffer gets allocated).

If we assume that its the zeroing of sk_buff (but iirc it made little
to no difference), could add

unsigned long skb_extensions[1];

to sk_buff, then move everything not needed for tcp fastpath
(e.g. secpath, conntrack, nf_bridge, tunnel encap, tc, ...)
below that

Then convert accesses to accessors and init it on demand.

One could probably also split cb[] into a smaller fastpath area
and another one at the end that won't be touched at allocation time.

> Miscellaneous

> contemplating that connections/sockets can be bound to particularly
> CPUs and that any operations (socket operations, timers, receive
> processing) must occur on that CPU. The CPU would be the one where RX
> happens. Note this implies perfect silo'ing, everything for driver RX
> to application processing happens inline on the CPU. The stack would
> not cross CPUs for a connection while in this mode.

Again don't see how this relates to xdp.  Could also be done with
current stack if we make rps/rfs pluggable since nothing else
currently pushes skb to another cpu (except when scheduler is involved
via tc mirred, netfilter userspace queueing etc) but that is always
explicit (i.e. skb leaves softirq protection).

Can we please fix and improve what we already have rather than creating
yet another NIH thing that will have to be maintained forever?

Thanks.
