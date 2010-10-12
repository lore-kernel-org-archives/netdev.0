From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 00:24:35 -0700
Message-ID: <20101012002435.f51f2c0e.akpm@linux-foundation.org>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
	<20101011230322.f0f6dd47.akpm@linux-foundation.org>
	<1286866699.30423.234.camel@edumazet-laptop>
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
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54337 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754163Ab0JLHXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 03:23:55 -0400
In-Reply-To: <1286866699.30423.234.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Oct 2010 08:58:19 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 11 octobre 2010 __ 23:03 -0700, Andrew Morton a __crit :
> > On Tue, 12 Oct 2010 07:05:25 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > > [PATCH net-next] net: allocate skbs on local node
> > > 
> > > commit b30973f877 (node-aware skb allocation) spread a wrong habit of
> > > allocating net drivers skbs on a given memory node : The one closest to
> > > the NIC hardware. This is wrong because as soon as we try to scale
> > > network stack, we need to use many cpus to handle traffic and hit
> > > slub/slab management on cross-node allocations/frees when these cpus
> > > have to alloc/free skbs bound to a central node.
> > > 
> > > skb allocated in RX path are ephemeral, they have a very short
> > > lifetime : Extra cost to maintain NUMA affinity is too expensive. What
> > > appeared as a nice idea four years ago is in fact a bad one.
> > > 
> > > In 2010, NIC hardwares are multiqueue, or we use RPS to spread the load,
> > > and two 10Gb NIC might deliver more than 28 million packets per second,
> > > needing all the available cpus.
> > > 
> > > Cost of cross-node handling in network and vm stacks outperforms the
> > > small benefit hardware had when doing its DMA transfert in its 'local'
> > > memory node at RX time. Even trying to differentiate the two allocations
> > > done for one skb (the sk_buff on local node, the data part on NIC
> > > hardware node) is not enough to bring good performance.
> > > 
> > 
> > This is all conspicuously hand-wavy and unquantified.  (IOW: prove it!)
> > 
> 
> I would say, _you_ should prove that original patch was good. It seems
> no network guy was really in the discussion ?

Two wrongs and all that.  The 2006 patch has nothing to do with it,
apart from demonstrating the importance of including performance
measurements in a performance patch.

> Just run a test on a bnx2x or ixgbe multiqueue 10Gb adapter, and see the
> difference. Thats about a 40% slowdown on high packet rates, on a dual
> socket machine (dual X5570  @2.93GHz). You can expect higher values on
> four nodes (I dont have such hardware to do the test)

Like that.  Please flesh it out and stick it in the changelog.

> 
> > The mooted effects should be tested for on both slab and slub, I
> > suggest.  They're pretty different beasts.
> 
> SLAB is so slow on NUMA these days, you can forget it for good.

I'd love to forget it, but it's faster for some things (I forget
which).  Which is why it's still around.

And the ghastly thing about this is that you're forced to care about it
too because some people are, apparently, still using it.

