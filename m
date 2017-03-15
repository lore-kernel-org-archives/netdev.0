From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 16:34:51 -0700
Message-ID: <1489620891.28631.188.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170314151143.16231-1-edumazet@google.com>
         <20170315040657.GA29637@ast-mbp.thefacebook.com>
         <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170315230608.GA90318@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33630 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750771AbdCOXex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 19:34:53 -0400
Received: by mail-pg0-f65.google.com with SMTP id y17so3809924pgh.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 16:34:53 -0700 (PDT)
In-Reply-To: <20170315230608.GA90318@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-15 at 16:06 -0700, Alexei Starovoitov wrote:
> On Wed, Mar 15, 2017 at 06:21:29AM -0700, Eric Dumazet wrote:
> > On Tue, 2017-03-14 at 21:06 -0700, Alexei Starovoitov wrote:
> > > On Tue, Mar 14, 2017 at 08:11:43AM -0700, Eric Dumazet wrote:
> > > > +static struct page *mlx4_alloc_page(struct mlx4_en_priv *priv,
> > > > +				    struct mlx4_en_rx_ring *ring,
> > > > +				    dma_addr_t *dma,
> > > > +				    unsigned int node, gfp_t gfp)
> > > >  {
> > > > +	if (unlikely(!ring->pre_allocated_count)) {
> > > > +		unsigned int order = READ_ONCE(ring->rx_alloc_order);
> > > > +
> > > > +		page = __alloc_pages_node(node, (gfp & ~__GFP_DIRECT_RECLAIM) |
> > > > +						__GFP_NOMEMALLOC |
> > > > +						__GFP_NOWARN |
> > > > +						__GFP_NORETRY,
> > > > +					  order);
> > > > +		if (page) {
> > > > +			split_page(page, order);
> > > > +			ring->pre_allocated_count = 1U << order;
> > > > +		} else {
> > > > +			if (order > 1)
> > > > +				ring->rx_alloc_order--;
> > > > +			page = __alloc_pages_node(node, gfp, 0);
> > > > +			if (unlikely(!page))
> > > > +				return NULL;
> > > > +			ring->pre_allocated_count = 1U;
> > > >  		}
> > > > +		ring->pre_allocated = page;
> > > > +		ring->rx_alloc_pages += ring->pre_allocated_count;
> > > >  	}
> > > > +	page = ring->pre_allocated++;
> > > > +	ring->pre_allocated_count--;
> > > 
> > > do you think this style of allocation can be moved into net common?
> > > If it's a good thing then other drivers should be using it too, right?
> > 
> > Yes, we might do this once this proves to work well.
> 
> In theory it looks quite promising :)
> 
> > 
> > > 
> > > > +	ring->cons = 0;
> > > > +	ring->prod = 0;
> > > > +
> > > > +	/* Page recycling works best if we have enough pages in the pool.
> > > > +	 * Apply a factor of two on the minimal allocations required to
> > > > +	 * populate RX rings.
> > > > +	 */
> > > 
> > > i'm not sure how above comments matches the code below.
> > > If my math is correct a ring of 1k elements will ask for 1024
> > > contiguous pages.
> > 
> > On x86 it might be the case, unless you use MTU=900 ?
> > 
> > On PowerPC, PAGE_SIZE=65536
> > 
> > 65536/1536 = 42  
> > 
> > So for 1024 elements, we need 1024/42 = ~24 pages.
> > 
> > Thus allocating 48 pages is the goal.
> > Rounded to next power of two (although nothing in my code really needs
> > this additional constraint, a page pool does not have to have a power of
> > two entries)
> 
> on powerpc asking for roundup(48) = 64 contiguous pages sounds reasonable.
> on x86 it's roundup(1024 * 1500 * 2 / 4096) = 1024 contiguous pages.



> I thought it has zero chance of succeeding unless it's fresh boot ?

Don't you load your NIC at boot time ?

Anyway, not a big deal, order-0 pages will then be allocated,
but each order-0 page also decrease order to something that might be
available, like order-5, after 5 failed allocations.

> Should it be something like ?
> order = min_t(u32, ilog2(pages_per_ring), 5); 
> 
> > Later, we might chose a different factor, maybe an elastic one.
> > 
> > > 
> > > > +retry:
> > > > +	total = 0;
> > > > +	pages_per_ring = new_size * stride_bytes * 2 / PAGE_SIZE;
> > > > +	pages_per_ring = roundup_pow_of_two(pages_per_ring);
> > > > +
> > > > +	order = min_t(u32, ilog2(pages_per_ring), MAX_ORDER - 1);
> > > 
> > > if you're sure it doesn't hurt the rest of the system,
> > > why use MAX_ORDER - 1? why not MAX_ORDER?
> > 
> > alloc_page(GFP_...,   MAX_ORDER)  never succeeds ;)
> 
> but MAX_ORDER - 1 also almost never succeeds ?

It does on 100% of our hosts at boot time.

And if not, we will automatically converge to whatever order-X pages are
readily in buddy allocator.

> 
> > Because of the __GRP_NOWARN you would not see the error I guess, but we
> > would get one pesky order-0 page in the ring buffer ;)
> > 
> > > 
> > > >  
> > > > -/* We recover from out of memory by scheduling our napi poll
> > > > - * function (mlx4_en_process_cq), which tries to allocate
> > > > - * all missing RX buffers (call to mlx4_en_refill_rx_buffers).
> > > > +/* Under memory pressure, each ring->rx_alloc_order might be lowered
> > > > + * to very small values. Periodically increase t to initial value for
> > > > + * optimal allocations, in case stress is over.
> > > >   */
> > > > +	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
> > > > +		ring = priv->rx_ring[ring_ind];
> > > > +		order = min_t(unsigned int, ring->rx_alloc_order + 1,
> > > > +			      ring->rx_pref_alloc_order);
> > > > +		WRITE_ONCE(ring->rx_alloc_order, order);
> > > 
> > > when recycling is effective in a matter of few seconds it will
> > > increase ther order back to 10 and the first time the driver needs
> > > to allocate, it will start that tedious failure loop all over again.
> > > How about removing this periodic mlx4_en_recover_from_oom() completely
> > > and switch to increase the order inside mlx4_alloc_page().
> > > Like N successful __alloc_pages_node() with order X will bump it
> > > into order X+1. If it fails next time it will do only one failed attempt.
> > 
> > I wanted to do the increase out of line. (not in the data path)
> > 
> > We probably could increase only if ring->rx_alloc_pages got a
> > significant increase since the last mlx4_en_recover_from_oom() call.
> > 
> > (That would require a new ring->prior_rx_alloc_pages out of hot cache
> > lines)
> 
> right. rx_alloc_pages can also be reduce to 16-bit and this
> new one prior_rx_alloc_pages to 16-bit too, no?

Think about arches not having atomic 8-bit or 16-bit reads or writes.

READ_ONCE()/WRITE_ONCE() will not be usable.


> 
> > Or maybe attempt the allocation from process context (from
> > mlx4_en_recover_from_oom())
> 
> yeah. that won't be great. since this patch is removing that issue,
> the best is not to introduce it again.
> 
> > I have not really thought very hard about this, since data path, if
> > really needing new pages, will very fast probe rx_alloc_order back to
> > available pages in the zone.
> 
> I'm nit picking on it mainly because, if proven successful,
> this strategy will be adopted by other drivers and likely moved
> to net/common, so imo it's important to talk about these details.

Sure.

> interesting. fancy. so things like nbd will also be using them too, right?

Yes, I believe so.
