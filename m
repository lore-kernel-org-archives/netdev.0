From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA will be reverted
Date: Tue, 04 Jul 2006 13:34:27 -0700
Message-ID: <adasllh9kj0.fsf@cisco.com>
References: <adawtazgawi.fsf@cisco.com>
	<20060630.141658.34759102.davem@davemloft.net>
	<1151708503.11835.8.camel@trinity.ogc.int>
	<200607011626.04539.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:10911 "EHLO
	sj-iport-1.cisco.com") by vger.kernel.org with ESMTP
	id S932391AbWGDUeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 16:34:31 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200607011626.04539.ak@suse.de> (Andi Kleen's message of "Sat, 1 Jul 2006 16:26:04 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Andi> Perhaps a good start of that discussion David asked for
    Andi> would be if you could give us an overview of the differences
    Andi> and how you avoid the TOE problems.

Well, here's a quick overview, leaving out some of the details.  The
difference between TOE and iWARP/RDMA is really the interface that
they present.

A TOE ("TCP Offload Engine") is a piece of hardware that offloads TCP
processing from the main system to handle regular sockets.  There is
either some way to hand off a socket from the host stack to the TOE,
or a socket is created on the TOE to start with, but in both cases,
the TOE is handling processing for normal TCP sockets.  This means
that the TOE has some hardware and/or firmware to do stateful TCP
processing.

An iWARP device, or RNIC (RDMA NIC), also usually has hardware and/or
firmware TCP processing, but this isn't exposed through the BSD socket
interface.  Instead, an RNIC presents an interface more like an
InfiniBand HCA: work requests (sends, receives, RDMA operations) are
passed to the RNIC via work queues, and completion notification is
returned asynchronously via completion queues.  An iWARP connection
can handle both send/receive ("two-sided") and get/put (RDMA or
"one-sided") operations.

For full details of the protocol used for this, you can look at the
drafs from the IETF rddp working group, but basically an RDMA protocol
is layered on top of a connected stream protocol -- usually TCP, but
SCTP could be used as well.

A lot of the perfomance of iWARP comes from the RDMA/direct placement
capabilities -- for example an NFS/RDMA server can process requests
out of order and put data directly into the buffer that's waiting for
it, without using any CPU on the destination -- but even send/receive
operations can be useful.

As a side note, an RNIC will also typically support the same sort of
kernel bypass as an IB HCA, where work queues can be safely mapped
into a userspace process's memory so that work requests can be posted
without a system call.  In fact, when people usually use RDMA as a
shorthand for the combination of the three features I described:
asynchronous work queues and completion queues, connections that
support both send/receive and RDMA, and kernel bypass.

In any case, RNIC support can be added to the existing IB stack with
fairly minor modifications -- you can search the netdev archives for
the patchsets posted by Steve Wise, but nearly all of the new code is
in the low-level hardware driver for the specific iWARP devices.

The real issues for netdev are things like Steve Wise's patch to add
route change notifiers, which could be used to tell RNICs when to
update the next hop for a connection they're handling.  More
generally, it would be interesting to see if it's possible to tie an
RNIC into the kernel's packet filtering, so that disallowed
connections don't get set up.  This seems very similar in spirit to
the problems around packet filtering that were raised for VJ netchannels.

 - Roland
