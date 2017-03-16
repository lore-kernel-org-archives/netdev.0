From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 17:44:13 -0700
Message-ID: <20170316004411.GA4848@ast-mbp.thefacebook.com>
References: <20170314151143.16231-1-edumazet@google.com>
 <20170315040657.GA29637@ast-mbp.thefacebook.com>
 <1489584089.28631.147.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170315230608.GA90318@ast-mbp.thefacebook.com>
 <1489620891.28631.188.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mail-pg0-f46.google.com ([74.125.83.46]:36597 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdCPAoS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 20:44:18 -0400
Received: by mail-pg0-f46.google.com with SMTP id g2so16533434pge.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 17:44:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489620891.28631.188.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 15, 2017 at 04:34:51PM -0700, Eric Dumazet wrote:
> > > > > -/* We recover from out of memory by scheduling our napi poll
> > > > > - * function (mlx4_en_process_cq), which tries to allocate
> > > > > - * all missing RX buffers (call to mlx4_en_refill_rx_buffers).
> > > > > +/* Under memory pressure, each ring->rx_alloc_order might be lowered
> > > > > + * to very small values. Periodically increase t to initial value for
> > > > > + * optimal allocations, in case stress is over.
> > > > >   */
> > > > > +	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
> > > > > +		ring = priv->rx_ring[ring_ind];
> > > > > +		order = min_t(unsigned int, ring->rx_alloc_order + 1,
> > > > > +			      ring->rx_pref_alloc_order);
> > > > > +		WRITE_ONCE(ring->rx_alloc_order, order);
> > > > 
> > > > when recycling is effective in a matter of few seconds it will
> > > > increase ther order back to 10 and the first time the driver needs
> > > > to allocate, it will start that tedious failure loop all over again.
> > > > How about removing this periodic mlx4_en_recover_from_oom() completely
> > > > and switch to increase the order inside mlx4_alloc_page().
> > > > Like N successful __alloc_pages_node() with order X will bump it
> > > > into order X+1. If it fails next time it will do only one failed attempt.
> > > 
> > > I wanted to do the increase out of line. (not in the data path)
> > > 
> > > We probably could increase only if ring->rx_alloc_pages got a
> > > significant increase since the last mlx4_en_recover_from_oom() call.
> > > 
> > > (That would require a new ring->prior_rx_alloc_pages out of hot cache
> > > lines)
> > 
> > right. rx_alloc_pages can also be reduce to 16-bit and this
> > new one prior_rx_alloc_pages to 16-bit too, no?
> 
> Think about arches not having atomic 8-bit or 16-bit reads or writes.
> 
> READ_ONCE()/WRITE_ONCE() will not be usable.

I mean if you really want to squeeze space these two:
+       unsigned int                    pre_allocated_count;
+       unsigned int                    rx_alloc_order;

can become 16-bit and have room for 'rx_alloc_pages_without_fail'
that will count to small N and then bump 'rx_alloc_order' by 1.
and since _oom() will be gone. There is no need for read/write__once.

anyway, looking forward to your next version.
