From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Tue, 29 Mar 2005 09:56:48 -0600
Message-ID: <1112111808.5510.16.camel@mulgrave>
References: <424346FE.20704@cs.wisc.edu>
	 <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org>
	 <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050329152008.GD63268@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 17:20 +0200, Andi Kleen wrote:
> > Actually, not in 2.6 ... we had the same issue in SCSI using mempools
> > for sglist allocation.  All of the mempool alocation paths now take gfp_
> > flags, so you can specify GFP_ATOMIC for interrupt context.
> 
> Just does not work when you are actually short of memory.
> 
> Just think a second on how a mempool works: In the extreme
> case when it cannot allocate system memory anymore it has
> to wait for someone else to free a memory block into the mempool,
> then pass it on to the next allocator etc. Basically 
> it is a direct bypass pipeline for memory to pass memory
> directly from one high priority user to another. This only
> works with sleeping. Otherwise you could not handle an arbitary
> number of users with a single mempool.
> 
> So to get a reliable mempool you have to sleep on allocation.

But that's not what we use them for.  You are confusing reliability with
forward progress.

In SCSI we use GFP_ATOMIC mempools in order to make forward progress.
All the paths are coded to expect a failure (in which case we requeue).
For forward progress what we need is the knowledge that there are n
resources out there dedicated to us.  When they return they get
reallocated straight to us and we can restart the queue processing
(there's actually a SCSI trigger that does this).

For receive mempools, the situation is much the same; if you have n
reserved buffers, then you have to drop the n+1 th packet.  However, the
resources will free up and go back to your mempool, and eventually you
accept the packet on retransmit.

The killer scenario (and why we require a mempool) is that someone else
gets the memory before you but then becomes blocked on another
allocation, so now you have no more allocations to allow forward
progress.

James


> > The object isn't to make the queues *reliable* it's to ensure the system
> > can make forward progress.  So all we're trying to ensure is that the
> > sockets used to service storage have some probability of being able to
> > send and receive packets during low memory.
> 
> For that it is enough to make the sender reliable. Retransmit
> takes care of the rest.

No ... we cannot get down to the situation where GFP_ATOMIC always
fails.  Now we have no receive capacity at all and the system deadlocks.

> > In your scenario, if we're out of memory and the system needs several
> > ACK's to the swap device for pages to be released to the system, I don't
> > see how we make forward progress since without a reserved resource to
> > allocate from how does the ack make it up the stack to the storage
> > driver layer?
> 
> Typically because the RX ring of the driver has some packets left.
> 
> Also since TCP is very persistent and there is some memory
> activity left you will have at least occasionally a time slot
> where a GFP_ATOMIC allocation can succeed.

That's what I think a mempool is required to guarantee.  Without it,
there are scenarios where GFP_ATOMIC always fails.

James
