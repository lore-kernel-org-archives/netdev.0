From: Rik van Riel <riel@redhat.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
 Topics
Date: Sun, 27 Mar 2005 22:54:11 -0500 (EST)
Message-ID: <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
References: <4241D106.8050302@cs.wisc.edu> <20050324101622S.fujita.tomonori@lab.ntt.co.jp>
 <1111628393.1548.307.camel@beastie> <20050324113312W.fujita.tomonori@lab.ntt.co.jp>
 <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random>
 <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
 <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
 <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
 <20050326224621.61f6d917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dmitry Yusupov <dmitry_yus@yahoo.com>, mpm@selenic.com, andrea@suse.de,
        michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050326224621.61f6d917.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005, David S. Miller wrote:

> How does this solve your problem?  This is just simple SKB recycling,
> and it's a pretty old idea.
> 
> TCP packets can be held on receive for arbitrary amounts of time.

We shouldn't do that when we're really really low on
memory.  I envision something like this:

1) have iSCSI, NFS, etc. open their sockets with a socket
   option that indicates this is a VM deadlock sensitive
   socket (SO_MEMALLOC?) - these sockets get two mempools,
   one for sending and one for receiving
2) have a global emergency mempool available to receive network
   packets when GFP_ATOMIC fails - this is useful since we don't
   know who a packet is for when we get the NIC interrupt, and
   it's easy to have just one pool to check
3) when a packet is received through this mempool, check
   whether the packet is for an SO_MEMALLOC socket
   ==> if not, discard the packet, free the memory
4) if the packet is for an SO_MEMALLOC socket, and that
   socket has space left in its own receiving mempool,
   and the packet is not out of order, then transfer the
   data to the socket
   ==> at this point, the space in the global network
   receive mempool can be freed again
5) if we cannot handle the packet, drop it

This way:
1) memory critical sockets are protected from other network traffic
2) memory critical sockets are protected from each other
3) all memory critical sockets should be able to make progress

The only thing left would be the memory needed to do reconnects
to the storage device, while in this situation.  I suspect we may
be able to keep that out of the network layerr, if we allow drivers
like iSCSI to pass in their own memory reserve to get the mempool
populated.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
