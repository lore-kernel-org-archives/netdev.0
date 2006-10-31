From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC] on the VM deadlock with networked swap
Date: Tue, 31 Oct 2006 16:33:58 +0100
Message-ID: <1162308838.24143.321.camel@taijtu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Daniel Phillips <phillips@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:23472 "EHLO
	amsfep12-int.chello.nl") by vger.kernel.org with ESMTP
	id S1423482AbWJaPdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 10:33:00 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

With this email I'm trying to start a discussion on the subject; there
is a growing demand for this feature and since my previous attempt was
not received well, I'm willing to start over.

Below I've tried to summarise the current state of affairs.

The problem (a):

In Linux memory is normally filled; a small amount of memory is kept
free for immediate allocation. Reclaim is charged with the task of
keeping this free reserve. It does this by trying to write pages out to
disk so they can be used for something else.

When we page to a networked storage device we can deadlock in the
following manner; freeing up memory requires network operation,
conversely, network operation requires memory.

Usually this will not deadlock because of this small reserve we have;
there will be enough free memory to complete the network operation and
we'll end up with more free memory than we started out with.

The problem (b):

The network is erratic - there is no guarantee that we'll receive the
packets needed to complete the reclaim network operation before memory
runs out; it is quite possible we'll deplete memory with queueing
packets for other sockets that cannot progress because user-space is
stalled (waiting on reclaim to free memory).

The buffer capacity of the network receive side is for all practical
purposes unbounded which makes it unsolvable by raising the free memory
limit. However, Linux does impose a practical limit and will drop
packets when this is exceeded - awaiting consumption. This can make the
deadlock happen even when there is memory left (admittedly a rare corner
case). 

A solution:

Daniel Phillips came up with a solution to this; his proposal is to have
a special free memory pool (implemented with an extra threshold in the
normal free memory reserve) and use that to service incoming packets
when normal free memory is depleted, however these packets are never to
be queued, that is, they may only be delivered to a guaranteed consumer.
This will allow continuous operation since no memory will be 'lost' in
buffers.

(NOTE the only possible guaranteed consumer at this point is reclaim;
all other consumers could be blocking on it)

An implementation:

http://www.spinics.net/lists/netdev/msg13207.html

The Critique:

 #1 - I[CG]MP should not be blocked; 1) they are needed for proper
TCP/UDP communication; 2) they are 'quickly' handled on receive anyway,
no buffering here.

 #2 - !AF_INET[46] protocols are not handled

 #{12} - perhaps use the existing fully subscribed points to reduce the
number of checks.

 #3 - netfilter - what!? (xfrm same I take it)

 #4 - 1 page fallback allocator vs jumbo frames.

 #5 - route allocation

 #6 - other input related memory allocations

The rebuttal:

 #1 - valid comment, easily fixed - thanks for the education.

 #2 - more work for me; AF_INET[46] is basically where the interest
lies, plain simply dropping all packets for the other families would be
fine with me. (AF_NETLINK is used by iSCSI to communicate with a special
daemon that runs with everything prealloced and mlockall)

 #{12} sock_queue_rcv_skb() and sk_stream_rmem_schedule() look good
places; except that tcp_rcv_established() needs to be forced out of the
fast path for these packets.

 #3 - The interest for this functionality comes from the cluster market,
they have very little need for netfilter and/or xfrm on their storage
network.

 #4 - !0-order allocs are pain esp. so under pressure. An arena based
heap allocator would be great, the emergency pool could then be an
emergency arena. (NOTE: I like this, however this would bring all of the
hugepages problems to networking too - OTOH that would be a good reason
to hurry up fixing those ;-))

 #5 - from what I could learn from the code local delivery -
ip_local_deliver() - routes should all be present, all other packets are
not _that_ interesting and can be dropped.

 #6 - will continue my exploration of the network code; all help
appreciated.


The future:

Its wide open, what do we want to do; 

Do people feel that such a feature should support everything the network
stack offers, or is a limited subset good enough? 

>From where I'm sitting atm ip_queue like things are fundamentally
incompatible with the problem in that user-space is basically stalled
during reclaim, except when coded with extreme care to avoid any VM
activity - prealloc everything and mlockall(). 
AF_PACKET could be done when only accepted packets are cloned, then the
emergency reserve must be large enough to contain the full network
operation for 1 writeout cycle, which should be doable.

Do people agree that the solution given is a solution, are other
solutions possible?



