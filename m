From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Mon, 28 Mar 2005 10:28:04 -0600
Message-ID: <1112027284.5531.27.camel@mulgrave>
References: <4241D106.8050302@cs.wisc.edu>
	 <20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	 <1111628393.1548.307.camel@beastie>
	 <20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	 <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random>
	 <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
	 <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
	 <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmwn21hk.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-28 at 18:12 +0200, Andi Kleen wrote:
> This does not work because mempools assume you can sleep,
> and in most NIC drivers you cant while doing RX refill.
> The NIC drivers can be rewritten to do this refilling in
> a workqueue. But it is not clear it is useful anyways because
> Linux failing to allocate a buffer is no different from
> the network overflowing the hardware queue of the network
> device, which Linux cannot do anything about. 

Actually, not in 2.6 ... we had the same issue in SCSI using mempools
for sglist allocation.  All of the mempool alocation paths now take gfp_
flags, so you can specify GFP_ATOMIC for interrupt context.

> Basically a network consists of lots of interconnected
> queues, and even if you try to make the Linux specific
> side of the queue reliable there are lots of other queues
> that can still lose packets.
> 
> With TCP that is no problem of course because in case of 
> a packet loss the packet is just retransmitted. 
> 
> So in short using mempools on receiving is not needed.

The object isn't to make the queues *reliable* it's to ensure the system
can make forward progress.  So all we're trying to ensure is that the
sockets used to service storage have some probability of being able to
send and receive packets during low memory.

In your scenario, if we're out of memory and the system needs several
ACK's to the swap device for pages to be released to the system, I don't
see how we make forward progress since without a reserved resource to
allocate from how does the ack make it up the stack to the storage
driver layer?

James
