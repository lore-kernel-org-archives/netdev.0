From: Willem de Bruijn <willemb@google.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Tue, 7 Oct 2014 00:24:14 -0400
Message-ID: <CA+FuTSfwTBtZLu7CXh4bPxUtVubOvpCPo+O38BsnSiLdvV_KEA@mail.gmail.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	john.ronciak@intel.com, Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, danny.zhou@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:40118 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaJGEYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:24:45 -0400
Received: by mail-qg0-f54.google.com with SMTP id z107so4794323qgd.27
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 21:24:44 -0700 (PDT)
In-Reply-To: <20141006000629.32055.2295.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Supporting some way to steer traffic to a queue
> is the _only_ hardware requirement to support the interface,

I would not impose his constraint. There may be legitimate use
cases for taking over all queues of a device. For instance, when
this is a secondary nic that does not carry any control traffic.

> Typically in an af_packet interface a packet_type handler is
> registered and used to filter traffic to the socket and do other
> things such as fan out traffic to multiple sockets. In this case the
> networking stack is being bypassed so this code is not run. So the
> hardware must push the correct traffic to the queues obtained from
> the ndo callback ndo_split_queue_pairs().

Why does the interface work at the level of queue_pairs instead of
individual queues?

>         /* Get the layout of ring space offset, page_sz, cnt */
>         getsockopt(fd, SOL_PACKET, PACKET_DEV_QPAIR_MAP_REGION_INFO,
>                    &info, &optlen);
>
>         /* request some queues from the driver */
>         setsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
>                    &qpairs_info, sizeof(qpairs_info));
>
>         /* if we let the driver pick us queues learn which queues
>          * we were given
>          */
>         getsockopt(fd, SOL_PACKET, PACKET_RXTX_QPAIRS_SPLIT,
>                    &qpairs_info, sizeof(qpairs_info));

If ethtool -U is used to steer traffic to a specific descriptor queue,
then the setsockopt can pass the exact id of that queue and there
is no need for a getsockopt follow-up.

>         /* And mmap queue pairs to user space */
>         mmap(NULL, info.tp_dev_bar_sz, PROT_READ | PROT_WRITE,
>              MAP_SHARED, fd, 0);

How will packet data be mapped and how will userspace translate
from paddr to vaddr? Is the goal to maintain long lived mappings
and instruct drivers to allocate from this restricted range (to
avoid per-packet system calls and vma operations)?

For throughput-oriented workloads, the syscall overhead
involved in kicking the nic (on tx, or for increasing the ring
consumer index on rx) can be amortized. And the operation
can perhaps piggy-back on interrupts or other events
(as long as interrupts are not disabled for full userspace
polling). Latency would be harder to satisfy while maintaining
some kernel policy enforcement. An extreme solution
uses an asynchronously busy polling kernel worker thread
(at high cycle cost, so acceptable for few workloads).

When keeping the kernel in the loop, it is possible to do
some basic sanity checking and transparently translate between
vaddr and paddr, even when exposing the hardware descriptors
directly. Though at this point it may be just as cheap to expose
an idealized virtualized descriptor format and copy fields between
that and device descriptors.

One assumption underlying exposing the hardware descriptors
is that they are quire similar between devices. How true is this
in the context of formats that span multiple descriptors?

> + * int (*ndo_split_queue_pairs) (struct net_device *dev,
> + *                              unsigned int qpairs_start_from,
> + *                              unsigned int qpairs_num,
> + *                              struct sock *sk)
> + *     Called to request a set of queues from the driver to be
> + *     handed to the callee for management. After this returns the
> + *     driver will not use the queues.

Are these queues also taken out of ethtool management, or is
this equivalent to taking removing them from the rss set with
ethtool -X?
