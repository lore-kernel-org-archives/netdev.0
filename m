From: Matt Mackall <mpm@selenic.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sat, 26 Mar 2005 22:38:48 -0800
Message-ID: <20050327063848.GB15453@waste.org>
References: <1111628393.1548.307.camel@beastie> <20050324113312W.fujita.tomonori@lab.ntt.co.jp> <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org> <20050327060403.GE4053@g5.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, netdev@oss.sgi.com
To: Andrea Arcangeli <andrea@suse.de>
Content-Disposition: inline
In-Reply-To: <20050327060403.GE4053@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 27, 2005 at 08:04:03AM +0200, Andrea Arcangeli wrote:
> On Sat, Mar 26, 2005 at 09:48:31PM -0800, Matt Mackall wrote:
> > I believe the mempool can be shared among all sockets that represent
> > the same storage device. Packets out any socket represent progress.
> 
> What's the point to have more than one socket connected to each storage
> device anyway?

There may be multiple network addresses (with different network paths)
associated with the same device for purposes of throughput or reliability.

> One algo to handle this is: after we get the gfp_atomic failure, we
> look at all the mempools are registered for a certain NIC, and we pick
> a random mempools that isn't empty. We use the non-empty mempool to
> receive the packet, and we let the netif_rx process the packet. Then if
> going up the stack we find that the packet doesn't belong to the
> socket-mempool, we discard the packet and we release the ram back into
> the mempool. This should make progress since eventually the right packet
> will go in the right mempool.

What if the number of packets queued by the time we reach the softirq
side of the stack exceeds the available buffers?

Imagine that we've got heavy DNS and iSCSI on the same box and that the box
gets wedged in OOM such that it can't answer DNS queries. But we can't
distinguish at receive time between DNS and iSCSI. As iSCSI is TCP, it
will send repeat ACKs at relatively long intervals but the DNS clients
will potentially continue to hammer the machine, filling the reserve
buffers and starving out the ACKs. We've got to essentially be able to
say "we are OOM, drop all traffic to sockets not flagged for storage"
and do so quickly enough that we can eventually get the ACKs.

> > > Perhaps the mempooling overhead will be too huge to pay for it even when
> > > it's not necessary, in such case the iscsid will have to pass a new
> > > bitflag to the socket syscall, when it creates the socket meant to talk
> > > with the remote disk.
> > 
> > I think we probably attach a mempool to a socket after the fact. And
> 
> I guess you meant before the fact (i.e. before the connection to the
> server), anything attached after the fact (whatever the fact is ;) isn't
> going to help.

After the socket is created, but before we commit to pumping storage
data through it (iSCSI has multiple phases). A privileged
setsockopt-like interface ought to suffice. Or something completely
kernel internal.

Which reminds me: FUSE and friends presumably have a very similar set
of problems.

-- 
Mathematics is the supreme nostalgia of our time.
