From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 29 Mar 2005 17:20:08 +0200
Message-ID: <20050329152008.GD63268@muc.de>
References: <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop> <20050326224621.61f6d917.davem@davemloft.net> <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com> <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Tue, 29 Mar 2005 17:20:08 +0200
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Content-Disposition: inline
In-Reply-To: <1112027284.5531.27.camel@mulgrave>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 10:28:04AM -0600, James Bottomley wrote:
> On Mon, 2005-03-28 at 18:12 +0200, Andi Kleen wrote:
> > This does not work because mempools assume you can sleep,
> > and in most NIC drivers you cant while doing RX refill.
> > The NIC drivers can be rewritten to do this refilling in
> > a workqueue. But it is not clear it is useful anyways because
> > Linux failing to allocate a buffer is no different from
> > the network overflowing the hardware queue of the network
> > device, which Linux cannot do anything about. 
> 
> Actually, not in 2.6 ... we had the same issue in SCSI using mempools
> for sglist allocation.  All of the mempool alocation paths now take gfp_
> flags, so you can specify GFP_ATOMIC for interrupt context.

Just does not work when you are actually short of memory.

Just think a second on how a mempool works: In the extreme
case when it cannot allocate system memory anymore it has
to wait for someone else to free a memory block into the mempool,
then pass it on to the next allocator etc. Basically 
it is a direct bypass pipeline for memory to pass memory
directly from one high priority user to another. This only
works with sleeping. Otherwise you could not handle an arbitary
number of users with a single mempool.

So to get a reliable mempool you have to sleep on allocation.

> The object isn't to make the queues *reliable* it's to ensure the system
> can make forward progress.  So all we're trying to ensure is that the
> sockets used to service storage have some probability of being able to
> send and receive packets during low memory.

For that it is enough to make the sender reliable. Retransmit
takes care of the rest.

> In your scenario, if we're out of memory and the system needs several
> ACK's to the swap device for pages to be released to the system, I don't
> see how we make forward progress since without a reserved resource to
> allocate from how does the ack make it up the stack to the storage
> driver layer?

Typically because the RX ring of the driver has some packets left.

Also since TCP is very persistent and there is some memory
activity left you will have at least occasionally a time slot
where a GFP_ATOMIC allocation can succeed.

-Andi
