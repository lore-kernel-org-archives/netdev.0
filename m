From: "Alex Aizman" <itn780@yahoo.com>
Subject: RE: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Sun, 27 Mar 2005 22:58:39 -0800
Message-ID: <200503280659.j2S6x1TS016054@oss.sgi.com>
References: <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>, <mpm@selenic.com>,
        <andrea@suse.de>, <michaelc@cs.wisc.edu>,
        <James.Bottomley@HansenPartnership.com>,
        <ksummit-2005-discuss@thunk.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <open-iscsi@googlegroups.com>, "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rik van Riel wrote:
>
> 1) have iSCSI, NFS, etc. open their sockets with a socket
>    option that indicates this is a VM deadlock sensitive
>    socket (SO_MEMALLOC?) - these sockets get two mempools,
>    one for sending and one for receiving
> 2) have a global emergency mempool available to receive network
>    packets when GFP_ATOMIC fails - this is useful since we don't
>    know who a packet is for when we get the NIC interrupt, and
>    it's easy to have just one pool to check
> 3) when a packet is received through this mempool, check
>    whether the packet is for an SO_MEMALLOC socket
>    ==> if not, discard the packet, free the memory
> 4) if the packet is for an SO_MEMALLOC socket, and that
>    socket has space left in its own receiving mempool,
>    and the packet is not out of order, then transfer the
>    data to the socket
>    ==> at this point, the space in the global network
>    receive mempool can be freed again
> 5) if we cannot handle the packet, drop it
> 

Let's say, there are only iSCSI and NFS sockets (no UDP, which is some
relief :-), and each opened with SO_MEMALLOC. The sockets are allowed to
oversubscribe (via tcp_rmem, tcp_wmem etc. defaults and socket options),
which means: the total amount of mempools memory can get beyond physically
available. It often does, actually. Which means: the 5) on the list above.
Once we allow for the non-determinism of an occasional packet drop, there's
a chance for the retransmission to not go through.

Otherwise, it's a great incremental step. The stack (for starters, and
ingoring for now resources of the NIC, iSCSI itself, etc.) needs to be aware
that some connections are more important than others. Some are
"resource-protected", others not. This is a useful piece of information.

Alex
