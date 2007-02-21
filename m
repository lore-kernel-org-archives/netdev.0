From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/29] swap over networked storage -v11
Date: Wed, 21 Feb 2007 15:43:04 +0100
Message-ID: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964982AbXBUPdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 10:33:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(patches against 2.6.20-mm1)

There is a fundamental deadlock associated with paging; when writing out a page
to free memory requires free memory to complete. The usually solution is to
keep a small amount of memory available at all times so we can overcome this
problem. This however assumes the amount of memory needed for writeout is
(constant and) smaller than the provided reserve.

It is this latter assumption that breaks when doing writeout over network.
Network can take up an unspecified amount of memory while waiting for a reply
to our write request. This re-introduces the deadlock; we might never complete
the writeout, for we might not have enough memory to receive the completion
message.

The proposed solution is simple, only allow traffic servicing the VM to make
use of the reserves. Since the VM is always present to service, this limited
amount of memory can sustain a full connection; after a packet has been
processed its memory can be re-used for the next packet.

This however implies you know what packets are for whom, which generally
speaking you don't. Hence we need to receive all packets but discard them as
soon as we encounter a non VM bound packet allocated from the reserves.

Also knowing it is headed towards the VM needs a little help, hence we
introduce the socket flag SOCK_VMIO to mark sockets with.

Of course, since we are paging all this has to happen in kernel-space, since
user-space might just not be there.

Since packet processing might also require memory, this all also implies that
those auxiliary allocations may use the reserves when an emergency packet is
processed. This is accomplished by using PF_MEMALLOC.

How much memory is to be reserved is also an issue, enough memory to saturate
both the route cache and IP fragment reassembly, along with various constants.

This patch-set comes in 5 parts:

1) introduce the memory reserve and make the SLAB allocator play nice with it.
   patches 01-09

2) add some needed infrastructure to the network code
   patches 10-12

3) implement the idea outlined above
   patches 13-19

4) teach the swap machinery to use generic address_spaces
   patches 20-23

5) implement swap over NFS using all the new stuff
   patches 24-29
-- 

