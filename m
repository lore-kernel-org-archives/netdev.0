From: Tom Herbert <tom@herbertland.com>
Subject: Initial thoughts on TXDP
Date: Wed, 30 Nov 2016 14:54:05 -0800
Message-ID: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34718 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcK3WyH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 17:54:07 -0500
Received: by mail-qk0-f172.google.com with SMTP id q130so39138821qke.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:54:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Posting for discussion....

Now that XDP seems to be nicely gaining traction we can start to
consider the next logical step which is to apply the principles of XDP
to accelerating transport protocols in the kernel. For lack of a
better name I'll refer to this as Transport eXpress Data Path, or just
TXDP :-). Pulling off TXDP might not be the most trivial of problems
to solve, but if we can this may address the performance gap between
kernel bypass and the stack for transport layer protocols (XDP
addresses the performance gap for stateless packet processing). The
problem statement is analogous to that which we had for XDP, namely
can we create a mode in the kernel that offer the same performance
that is seen with L4 protocols over kernel bypass (e.g. TCP/OpenOnload
or TCP/DPDK) or perhaps something reasonably close to a full HW
offload solution (such as RDMA)?

TXDP is different from XDP in that we are dealing with stateful
protocols and is part of a full protocol implementation, specifically
this would be an accelerated mode of transport connections (e.g. TCP)
in the kernel. Also, unlike XDP we now need to be concerned with
transmit path (both application generating packets as well as protocol
sourced packets like ACKs, retransmits, clocking out data, etc.).
Another distinction is that the user API needs to be considered, for
instance optimizing the nominal protocol stack but then using an
unmodified socket interface could easily undo the effects of
optimizing the lower layers. This last point actually implies a nice
constraint, if we can't keep the accelerated path simple its probably
not worth trying to accelerate.

One simplifying assumption we might make is that TXDP is primarily for
optimizing latency, specifically request/response type operations
(think HPC, HFT, flash server, or other tightly coupled communications
within the datacenter). Notably, I don't think that saving CPU is as
relevant to TXDP, in fact we have already seen that CPU utilization
can be traded off for lower latency via spin polling. Similar to XDP
though, we might assume that single CPU performance is relevant (i.e.
on a cache server we'd like to spin as few CPUs as needed and no more
to handle the load an maintain throughput and latency requirements).
High throughput (ops/sec) and low variance should be side effects of
any design.

As with XDP, TXDP is _not_ intended to be a completely generic and
transparent solution. The application may be specifically optimized
for use with TXDP (for instance to implement perfect lockless
silo'ing). So TXDP is not going to be for everyone and it should be as
minimally invasive to the rest of the stack as possible.

I imagine there are a few reasons why userspace TCP stacks can get
good performance:

- Spin polling (we already can do this in kernel)
- Lockless, I would assume that threads typically have exclusive
access to a queue pair for a connection
- Minimal TCP/IP stack code
- Zero copy TX/RX
- Light weight structures for queuing
- No context switches
- Fast data path for in order, uncongested flows
- Silo'ing between application and device queues

Not all of these have cognates in the Linux stack, for instance we
probably can't entirely eliminate context switches for a userspace
application.

So with that the components of TXDP might look something like:

RX

  - Call into TCP/IP stack with page data directly from driver-- no
skbuff allocation or interface. This is essentially provided by the
XDP API although we would need to generalize the interface to call
stack functions (I previously posted patches for that). We will also
need a new action, XDP_HELD?, that indicates the XDP function held the
packet (put on a socket for instance).
  - Perform connection lookup. If we assume lockless model as
described below then we should be able to perform lockless connection
lookup similar to work Eric did to optimize UDP lookups for tunnel
processing
  - Call function that implements expedited TCP/IP datapath (something
like Van Jacobson's famous 80 instructions? :-) ).
  - If there is anything funky about the packet, connection state, or
TCP connection is not being TXDP accelerated just return XDP_PASS so
that packet follows normal stack processing. Since we did connection
lookup we could return an early demux also.Since we're already in an
exception mode this is where we might want to move packet processing
to different CPU (can be done by RPS/RFS)..
  - If packet contains new data we can allocate a "mini skbfuf (talked
about that at netdev) for queuing on socket.
  - If packet is an ACK we can process it directly without ever creating skbuff
  - There is also the possibility of avoiding the skbuff allocation
for in-kernel applications. Stream parser might also be taught how to
deal with raw buffers.
  - If we're really ambitious we can also consider putting packets
into a packet ring for user space presuming that packets are typically
in order (might be a little orthogonal to TXDP.

TX

  - Normal TX socket options apply however they might be lockless
under locking constraints below
  - skbuff is required for keeping data on socket a TCP (not
necessarily for UDP though), but we might be able to use a mini skbuff
for this
  - We'd need an interface to transmit a packet in a page buffer
without an skbuff.
  - When we transmit, it would be nice to go straight from TCP
connection to an XDP device queue and in particular skip the qdisc
layer. This follows the principle of low latency being first criteria.
Effective use of qdiscs, especially non work conserving ones, imply
longer latencies in effect which likely means TXDP isn't appropriate
in such a cases. BQL is also out, however we would want the TX
batching of XDP.
  - If we really need priority queing we should have the option of
using device mulitple queue
  - Pure ACKs would not require an skb also
  - Zero copy TX (splice) can be used where needed. This might be
particular useful in a flash or remote memory server
  - TX completion would most like be happening on same CPU also

Miscellaneous

  - Under the simplicity principle we really only want the TXDP to
contain the minimal necessary path. What is "minimal" is a very
relevant question. If we constrain the use case to be communications
within a single rack such that we can engineer for basically no loss
and no congestion (pause might be reasonable here) then the TXDP data
path might just implement that. Mostly this would just be the
established data path that is accelerated, handling other states might
be done in existing path (which becomes slow path in TXDP).
  - To make transport sockets to have a lockless mode I am
contemplating that connections/sockets can be bound to particularly
CPUs and that any operations (socket operations, timers, receive
processing) must occur on that CPU. The CPU would be the one where RX
happens. Note this implies perfect silo'ing, everything for driver RX
to application processing happens inline on the CPU. The stack would
not cross CPUs for a connection while in this mode.
  - We might be able to take advantage of per connection queues or
ntuple filter to isolate flows to to certain queues and hence certain
CPUs. I don't think this can be a requirement though, TXDP should be
able to work well with generic MQ devices. Specialized devices queues
are an optimization, without having those those we'd want to push to
other CPUs as quickly as possible (RPS but maybe we can get away with
a mini-skbuff here).

Thanks,
Tom
