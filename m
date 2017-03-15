From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 16:06:10 -0700
Message-ID: <20170315230608.GA90318@ast-mbp.thefacebook.com>
References: <20170314151143.16231-1-edumazet@google.com>
 <20170315040657.GA29637@ast-mbp.thefacebook.com>
 <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35754 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754068AbdCOXGQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 19:06:16 -0400
Received: by mail-pf0-f175.google.com with SMTP id x63so9784211pfx.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 16:06:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 06:21:29AM -0700, Eric Dumazet wrote:
> On Tue, 2017-03-14 at 21:06 -0700, Alexei Starovoitov wrote:
> > On Tue, Mar 14, 2017 at 08:11:43AM -0700, Eric Dumazet wrote:
> > > +static struct page *mlx4_alloc_page(struct mlx4_en_priv *priv,
> > > +				    struct mlx4_en_rx_ring *ring,
> > > +				    dma_addr_t *dma,
> > > +				    unsigned int node, gfp_t gfp)
> > >  {
> > > +	if (unlikely(!ring->pre_allocated_count)) {
> > > +		unsigned int order = READ_ONCE(ring->rx_alloc_order);
> > > +
> > > +		page = __alloc_pages_node(node, (gfp & ~__GFP_DIRECT_RECLAIM) |
> > > +						__GFP_NOMEMALLOC |
> > > +						__GFP_NOWARN |
> > > +						__GFP_NORETRY,
> > > +					  order);
> > > +		if (page) {
> > > +			split_page(page, order);
> > > +			ring->pre_allocated_count = 1U << order;
> > > +		} else {
> > > +			if (order > 1)
> > > +				ring->rx_alloc_order--;
> > > +			page = __alloc_pages_node(node, gfp, 0);
> > > +			if (unlikely(!page))
> > > +				return NULL;
> > > +			ring->pre_allocated_count = 1U;
> > >  		}
> > > +		ring->pre_allocated = page;
> > > +		ring->rx_alloc_pages += ring->pre_allocated_count;
> > >  	}
> > > +	page = ring->pre_allocated++;
> > > +	ring->pre_allocated_count--;
> > 
> > do you think this style of allocation can be moved into net common?
> > If it's a good thing then other drivers should be using it too, right?
> 
> Yes, we might do this once this proves to work well.

In theory it looks quite promising :)

> 
> > 
> > > +	ring->cons = 0;
> > > +	ring->prod = 0;
> > > +
> > > +	/* Page recycling works best if we have enough pages in the pool.
> > > +	 * Apply a factor of two on the minimal allocations required to
> > > +	 * populate RX rings.
> > > +	 */
> > 
> > i'm not sure how above comments matches the code below.
> > If my math is correct a ring of 1k elements will ask for 1024
> > contiguous pages.
> 
> On x86 it might be the case, unless you use MTU=900 ?
> 
> On PowerPC, PAGE_SIZE=65536
> 
> 65536/1536 = 42  
> 
> So for 1024 elements, we need 1024/42 = ~24 pages.
> 
> Thus allocating 48 pages is the goal.
> Rounded to next power of two (although nothing in my code really needs
> this additional constraint, a page pool does not have to have a power of
> two entries)

on powerpc asking for roundup(48) = 64 contiguous pages sounds reasonable.
on x86 it's roundup(1024 * 1500 * 2 / 4096) = 1024 contiguous pages.
I thought it has zero chance of succeeding unless it's fresh boot ?
Should it be something like ?
order = min_t(u32, ilog2(pages_per_ring), 5); 

> Later, we might chose a different factor, maybe an elastic one.
> 
> > 
> > > +retry:
> > > +	total = 0;
> > > +	pages_per_ring = new_size * stride_bytes * 2 / PAGE_SIZE;
> > > +	pages_per_ring = roundup_pow_of_two(pages_per_ring);
> > > +
> > > +	order = min_t(u32, ilog2(pages_per_ring), MAX_ORDER - 1);
> > 
> > if you're sure it doesn't hurt the rest of the system,
> > why use MAX_ORDER - 1? why not MAX_ORDER?
> 
> alloc_page(GFP_...,   MAX_ORDER)  never succeeds ;)

but MAX_ORDER - 1 also almost never succeeds ?

> Because of the __GRP_NOWARN you would not see the error I guess, but we
> would get one pesky order-0 page in the ring buffer ;)
> 
> > 
> > >  
> > > -/* We recover from out of memory by scheduling our napi poll
> > > - * function (mlx4_en_process_cq), which tries to allocate
> > > - * all missing RX buffers (call to mlx4_en_refill_rx_buffers).
> > > +/* Under memory pressure, each ring->rx_alloc_order might be lowered
> > > + * to very small values. Periodically increase t to initial value for
> > > + * optimal allocations, in case stress is over.
> > >   */
> > > +	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
> > > +		ring = priv->rx_ring[ring_ind];
> > > +		order = min_t(unsigned int, ring->rx_alloc_order + 1,
> > > +			      ring->rx_pref_alloc_order);
> > > +		WRITE_ONCE(ring->rx_alloc_order, order);
> > 
> > when recycling is effective in a matter of few seconds it will
> > increase ther order back to 10 and the first time the driver needs
> > to allocate, it will start that tedious failure loop all over again.
> > How about removing this periodic mlx4_en_recover_from_oom() completely
> > and switch to increase the order inside mlx4_alloc_page().
> > Like N successful __alloc_pages_node() with order X will bump it
> > into order X+1. If it fails next time it will do only one failed attempt.
> 
> I wanted to do the increase out of line. (not in the data path)
> 
> We probably could increase only if ring->rx_alloc_pages got a
> significant increase since the last mlx4_en_recover_from_oom() call.
> 
> (That would require a new ring->prior_rx_alloc_pages out of hot cache
> lines)

right. rx_alloc_pages can also be reduce to 16-bit and this
new one prior_rx_alloc_pages to 16-bit too, no?

> Or maybe attempt the allocation from process context (from
> mlx4_en_recover_from_oom())

yeah. that won't be great. since this patch is removing that issue,
the best is not to introduce it again.

> I have not really thought very hard about this, since data path, if
> really needing new pages, will very fast probe rx_alloc_order back to
> available pages in the zone.

I'm nit picking on it mainly because, if proven successful,
this strategy will be adopted by other drivers and likely moved
to net/common, so imo it's important to talk about these details.

> > 
> > > +static bool mlx4_replenish(struct mlx4_en_priv *priv,
> > > +			   struct mlx4_en_rx_ring *ring,
> > > +			   struct mlx4_en_frag_info *frag_info)
> > >  {
> > > +	struct mlx4_en_page *en_page = &ring->pool.array[ring->pool.pool_idx];
> > > +	if (!mlx4_page_is_reusable(en_page->page)) {
> > > +		page = mlx4_alloc_page(priv, ring, &dma, numa_mem_id(),
> > > +				       GFP_ATOMIC | __GFP_MEMALLOC);
> > 
> > I don't understand why page_is_reusable is doing !page_is_pfmemalloc(page))
> > check, but here you're asking for MEMALLOC pages too, so
> > under memory pressure the hw will dma the packet into this page,
> > but then the stack will still drop it, so under pressure
> > we'll keep alloc/free the pages from reserve. Isn't it better
> > to let the hw drop (since we cannot alloc and rx ring is empty) ?
> > What am I missing?
> 
> We do not want to drop packets that might help SWAP over NFS from
> freeing memory and help us recovering from pressure. This is the whole
> point of __GFP_MEMALLOC protocol : hw wont know that a particular TCP
> packet must not be dropped.

interesting. fancy. so things like nbd will also be using them too, right?

> > 
> > > @@ -767,10 +820,30 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> > >  			case XDP_PASS:
> > >  				break;
> > >  			case XDP_TX:
> > > +				/* Make sure we have one page ready to replace this one */
> > > +				npage = NULL;
> > > +				if (!ring->page_cache.index) {
> > > +					npage = mlx4_alloc_page(priv, ring,
> > > +								&ndma, numa_mem_id(),
> > > +								GFP_ATOMIC | __GFP_MEMALLOC);
> > > +					if (!npage) {
> > > +						ring->xdp_drop++;
> > > +						goto next;
> > > +					}
> > > +				}
> > 
> > I think the approach to drop packets after xdp prog executed is incorrect.
> > In such case xdp program already parsed the packet, performed all necessary
> > changes and now ready to xmit it out. Dropping packet so late, just
> > because page_cache is empty, doesn't make any sense. Therefore please change
> > this part back to how it was before: allocate buffer at the end of the loop.
> > I think you're trying too hard to avoid _oom() callback doing allocs. Say
> > all rx packets went via xdp_tx and we don't have any pages to put into rx ring
> > at the end of this rx loop. That's still not a problem. The hw will drop
> > few packets and when tx completion fires on the same cpu for xdp rings we
> > can without locks populate corresponding rx ring.
> > So XDP will be able to operate without allocations even when there is
> > no free memory in the rest of the system.
> > 
> > Also I was thinking to limit xdp rings to order 0 allocs only, but doing
> > large order can indeed decrease tlb misses. That has to be tested more
> > thoroughly and if large order will turn out to hurt we can add small patch
> > on top of this one to do order0 for xdp rings.
> 
> 
> > 
> > Overall I think there are several good ideas in this patch,
> > but drop after xdp_tx is the showstopper and has to be addressed
> > before this patch can be merged.
> > 
> 
> The xmit itself can drop the packet if TX ring is full.

yes. and we have 'xdp_tx_full' counter for it that we monitor.
When tx ring and mtu are sized properly, we don't expect to see it
incrementing at all. This is something in our control. 'Our' means
humans that setup the environment.
'cache empty' condition is something ephemeral. Packets will be dropped
and we won't have any tools to address it. These packets are real
people requests. Any drop needs to be categorized.
Like there is 'rx_fifo_errors' counter that mlx4 reports when
hw is dropping packets before they reach the driver. We see it
incrementing depending on the traffic pattern though overall Mpps
through the nic is not too high and this is something we
actively investigating too.

> I can do the change, but you are focusing on this allocation that will
> never happen but for the first packets going through XDP_TX

if 'page cache empty' condition happens once every 100 million packets
and we drop one due to failed alloc, it's a problem that I'd like to avoid.
Today xdp is mostly about ddos and lb. I'd like to get to the point
where all drop decisions are done by the program only.
xdp program should decide which traffic is bad and should pass
good traffic through. If there are drops due to surrounding
infrastructure (like driver logic or nic hw fifo full or cpu too slow)
we'll be fixing them.
And yes it means there will be more changes to the drivers due to xdp.

> I am fine adding overhead for the non XDP_TX, since you really want it.

Thank you. I don't understand the 'overhead' part.
I'll test the next version of this patch.
