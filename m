From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sun, 27 Mar 2005 08:04:03 +0200
Message-ID: <20050327060403.GE4053@g5.random>
References: <20050324101622S.fujita.tomonori@lab.ntt.co.jp> <1111628393.1548.307.camel@beastie> <20050324113312W.fujita.tomonori@lab.ntt.co.jp> <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random> <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random> <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20050327054831.GA15453@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 09:48:31PM -0800, Matt Mackall wrote:
> I believe the mempool can be shared among all sockets that represent
> the same storage device. Packets out any socket represent progress.

What's the point to have more than one socket connected to each storage
device anyway?

> Yes, done before it was even called iSCSI.

Ok, theoretical deadlock conditions aren't nice anyway, but knowing this
is a real life problem too makes it more interesting ;).

> The receive buffer is allocated at the time we DMA it from the card.
> We have no idea of its contents and we won't know what socket mempool
> to pull the receive skbuff from until much higher in the network
> stack, which could be quite a while later if we're under OOM load. And
> we can't have a mempool big enough to handle all the traffic that
> might potentially be deferred for softirq processing when we're OOM,
> especially at gigabit rates.
> 
> I think this is actually the tricky piece of the problem and solving
> the socket and send buffer allocation doesn't help until this gets
> figured out.
> 
> We could perhaps try to address this with another special receive-side
> alloc_skb that fails most of the time on OOM but sometimes pulls from
> a special reserve.

One algo to handle this is: after we get the gfp_atomic failure, we
look at all the mempools are registered for a certain NIC, and we pick
a random mempools that isn't empty. We use the non-empty mempool to
receive the packet, and we let the netif_rx process the packet. Then if
going up the stack we find that the packet doesn't belong to the
socket-mempool, we discard the packet and we release the ram back into
the mempool. This should make progress since eventually the right packet
will go in the right mempool.

> > Perhaps the mempooling overhead will be too huge to pay for it even when
> > it's not necessary, in such case the iscsid will have to pass a new
> > bitflag to the socket syscall, when it creates the socket meant to talk
> > with the remote disk.
> 
> I think we probably attach a mempool to a socket after the fact. And

I guess you meant before the fact (i.e. before the connection to the
server), anything attached after the fact (whatever the fact is ;) isn't
going to help.
