From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Mon, 28 Mar 2005 18:12:39 +0200
Message-ID: <m1zmwn21hk.fsf@muc.de>
References: <4241D106.8050302@cs.wisc.edu>
	<20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	<1111628393.1548.307.camel@beastie>
	<20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	<1111633846.1548.318.camel@beastie>
	<20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu>
	<20050324233921.GZ14202@opteron.random>
	<20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
	<20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
	<20050326224621.61f6d917.davem@davemloft.net>
	<Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@redhat.com>
In-Reply-To: <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> (Rik
 van Riel's message of "Sun, 27 Mar 2005 22:54:11 -0500 (EST)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rik van Riel <riel@redhat.com> writes:
>    one for sending and one for receiving
> 2) have a global emergency mempool available to receive network
>    packets when GFP_ATOMIC fails - this is useful since we don't
>    know who a packet is for when we get the NIC interrupt, and
>    it's easy to have just one pool to check

This does not work because mempools assume you can sleep,
and in most NIC drivers you cant while doing RX refill.
The NIC drivers can be rewritten to do this refilling in
a workqueue. But it is not clear it is useful anyways because
Linux failing to allocate a buffer is no different from
the network overflowing the hardware queue of the network
device, which Linux cannot do anything about. 

Basically a network consists of lots of interconnected
queues, and even if you try to make the Linux specific
side of the queue reliable there are lots of other queues
that can still lose packets.

With TCP that is no problem of course because in case of 
a packet loss the packet is just retransmitted. 

So in short using mempools on receiving is not needed.

Now memory allocation for writing is a different chapter.
You cannot recover from a lost writing.
The kernel currently goes even in endless loops in this
case (e.g. on TCP FIN allocation)

With the exception of routing the allocation fortunately 
usually happens there in:
- socket context: great you can use a per socket mempool
- thread context: you can sleep

With routing that is not the case, but it does not matter
because it typically does not allocate new packets, but
just sends out existing ones.

In short you need mempool only for TX. With some luck you even only
need them for the skbuff head and a small header buffer, since I would
expect iscsi TX to be typically zero copy for data and just passing
struct page *s around.

-Andi
