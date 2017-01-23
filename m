From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency
 reserve
Date: Mon, 23 Jan 2017 09:39:40 +0100
Message-ID: <20170123093940.5d69539e@redhat.com>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
        <CALzJLG8DzzpO97ehxWAdm=18Hw3Q9N6poTviDYuEFgyc9+O9RA@mail.gmail.com>
        <CALx6S35+miSu6QgjyQYVDGqu4hkq0eoj+wHha35HH5+DdSQtEg@mail.gmail.com>
        <CAPe+=50xs=MMqxHPgTiGa3qytL7633Cygf_vBWuAuq=ceLyacg@mail.gmail.com>
        <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: brouer@redhat.com, Tom Herbert <tom@herbertland.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Davem <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdAWIjq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 03:39:46 -0500
In-Reply-To: <CALzJLG9JEorLwV48H3m0vQ1+VDnpYbKhiBoUw+WW-JFouJoj1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 21 Jan 2017 22:31:26 +0200 Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:

> > My previous measurements show approx 20℅ speedup on a UDP test with delivery
> > to remote CPU.
> >
> > Removing the cache would of cause be a good usecase for speeding up the page
> > allocator (PCP). Which Mel Gorman and me are working on. AFAIK current page
> > order0 cost 240 cycles. Mel have reduced til to 180, and without NUMA 150
> > cycles. And with bulking this can be amortized to 80 cycles.
> >  
> 
> Are you trying to say that we won't need the cache if you manage to
> deliver those optimizations ?

These page alloc optimization are good, but not fast-enough to replace
your cache.  Maybe I can improve it further, but it will be very hard
to compete with a recycle cache (it can skip many checks the page alloc
need, as it knows the page state).

Said in another way, the gap will be significantly smaller, and you
will not see a big boost from using this cache.


BUT there are other advantages of using a guaranteed recycle pool
facility (like the page_pool).  Namely, (1) DMA-overhead: keeping page
DMA mapped to counter DMA+IOMMU overhead, (2) RX-zero-copy: opens up
for a software memory model solution for pre-VMA-mapping pages to
userspace (See: [1] for argument how this avoids leaking kernel mem,
but only expose/leak packet-data mem)


> can you compare those optimizations with the page_frag_cache from
> dev_alloc_skb ?

IHMO the page_frag_cache is indirectly a bulk page allocator facility,
which is limiting the number of times the page allocator is called, and
thus amortize the cost of talking to the page allocator.  Performance
wise, it is likely comparable to your page cache, and likely faster
than the 80 cycles order0-bulking.
BUT we generally worry about using these 32K pages, as it opens a
window for attackers pinning down memory.


[1] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
