From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sat, 26 Mar 2005 21:48:31 -0800
Message-ID: <20050327054831.GA15453@waste.org>
References: <4241D106.8050302@cs.wisc.edu> <20050324101622S.fujita.tomonori@lab.ntt.co.jp> <1111628393.1548.307.camel@beastie> <20050324113312W.fujita.tomonori@lab.ntt.co.jp> <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: Andrea Arcangeli <andrea@suse.de>
Content-Disposition: inline
In-Reply-To: <20050327035149.GD4053@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm cc:ing this to netdev, where this discussion really ought to be.
There's a separate networking summit and I suspect most of the
networking heavies aren't reading ksummit-discuss or open-iscsi.
It's getting rather far afield for ksummit-discuss so people should
trim that from follow-ups.

On Sun, Mar 27, 2005 at 05:51:49AM +0200, Andrea Arcangeli wrote:
> On Thu, Mar 24, 2005 at 07:43:41PM -0800, Matt Mackall wrote:
> > There may be network multipath. But I think we can have a single
> > socket mempool per logical device and a single skbuff mempool shared
> > among those sockets.
> 
> If we'll have to reserve more than 1 packet per each socket context,
> then the mempool probably can't be shared.

I believe the mempool can be shared among all sockets that represent
the same storage device. Packets out any socket represent progress.

> I wonder if somebody has ever reproduced deadlocks
> by swapping on software-tcp-iscsi.

Yes, done before it was even called iSCSI.

> > And that still leaves us with the lack of buffers to receive ACKs
> > problem, which is perhaps worse.
> 
> The mempooling should take care of the acks too.

The receive buffer is allocated at the time we DMA it from the card.
We have no idea of its contents and we won't know what socket mempool
to pull the receive skbuff from until much higher in the network
stack, which could be quite a while later if we're under OOM load. And
we can't have a mempool big enough to handle all the traffic that
might potentially be deferred for softirq processing when we're OOM,
especially at gigabit rates.

I think this is actually the tricky piece of the problem and solving
the socket and send buffer allocation doesn't help until this gets
figured out.

We could perhaps try to address this with another special receive-side
alloc_skb that fails most of the time on OOM but sometimes pulls from
a special reserve.

> Perhaps the mempooling overhead will be too huge to pay for it even when
> it's not necessary, in such case the iscsid will have to pass a new
> bitflag to the socket syscall, when it creates the socket meant to talk
> with the remote disk.

I think we probably attach a mempool to a socket after the fact. And
no, we can't have a mempool attached to every socket.

-- 
Mathematics is the supreme nostalgia of our time.
