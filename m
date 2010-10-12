From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Mon, 11 Oct 2010 23:03:22 -0700
Message-ID: <20101011230322.f0f6dd47.akpm@linux-foundation.org>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58378 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752995Ab0JLGCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 02:02:40 -0400
In-Reply-To: <1286859925.30423.184.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Oct 2010 07:05:25 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 12 octobre 2010 __ 01:22 +0200, Eric Dumazet a __crit :
> > Le mardi 12 octobre 2010 __ 01:03 +0200, Eric Dumazet a __crit :
> > > 
> > > For multi queue devices, it makes more sense to allocate skb on local
> > > node of the cpu handling RX interrupts. This allow each cpu to
> > > manipulate its own slub/slab queues/structures without doing expensive
> > > cross-node business.
> > > 
> > > For non multi queue devices, IRQ affinity should be set so that a cpu
> > > close to the device services interrupts. Even if not set, using
> > > dev_alloc_skb() is faster.
> > > 
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > 
> > Or maybe revert :
> > 
> > commit b30973f877fea1a3fb84e05599890fcc082a88e5
> > Author: Christoph Hellwig <hch@lst.de>
> > Date:   Wed Dec 6 20:32:36 2006 -0800
> > 
> >     [PATCH] node-aware skb allocation
> >     
> >     Node-aware allocation of skbs for the receive path.
> >     
> >     Details:
> >     
> >       - __alloc_skb gets a new node argument and cals the node-aware
> >         slab functions with it.
> >       - netdev_alloc_skb passed the node number it gets from dev_to_node
> >         to it, everyone else passes -1 (any node)
> >     
> >     Signed-off-by: Christoph Hellwig <hch@lst.de>
> >     Cc: Christoph Lameter <clameter@engr.sgi.com>
> >     Cc: "David S. Miller" <davem@davemloft.net>
> >     Signed-off-by: Andrew Morton <akpm@osdl.org>
> > 
> > 
> > Apparently, only Christoph and Andrew signed it.
> > 
> > 
> 
> [PATCH net-next] net: allocate skbs on local node
> 
> commit b30973f877 (node-aware skb allocation) spread a wrong habit of
> allocating net drivers skbs on a given memory node : The one closest to
> the NIC hardware. This is wrong because as soon as we try to scale
> network stack, we need to use many cpus to handle traffic and hit
> slub/slab management on cross-node allocations/frees when these cpus
> have to alloc/free skbs bound to a central node.
> 
> skb allocated in RX path are ephemeral, they have a very short
> lifetime : Extra cost to maintain NUMA affinity is too expensive. What
> appeared as a nice idea four years ago is in fact a bad one.
> 
> In 2010, NIC hardwares are multiqueue, or we use RPS to spread the load,
> and two 10Gb NIC might deliver more than 28 million packets per second,
> needing all the available cpus.
> 
> Cost of cross-node handling in network and vm stacks outperforms the
> small benefit hardware had when doing its DMA transfert in its 'local'
> memory node at RX time. Even trying to differentiate the two allocations
> done for one skb (the sk_buff on local node, the data part on NIC
> hardware node) is not enough to bring good performance.
> 

This is all conspicuously hand-wavy and unquantified.  (IOW: prove it!)

The mooted effects should be tested for on both slab and slub, I
suggest.  They're pretty different beasts.
