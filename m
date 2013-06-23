From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: allow order-0 memory allocations in RX
 path
Date: Sun, 23 Jun 2013 14:13:23 -0700
Message-ID: <1372022003.3301.47.camel@edumazet-glaptop>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	 <1371757222-21412-2-git-send-email-amirv@mellanox.com>
	 <1371763689.3252.419.camel@edumazet-glaptop> <51C6B602.20703@mellanox.com>
	 <1372000676.3301.27.camel@edumazet-glaptop>
	 <CAJZOPZ+-StTDm0D-jaeWGfQqOzz5e3C92zPmQf=0_mPV3MukCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:59979 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3FWVN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 17:13:27 -0400
Received: by mail-wg0-f53.google.com with SMTP id y10so7878773wgg.20
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 14:13:26 -0700 (PDT)
In-Reply-To: <CAJZOPZ+-StTDm0D-jaeWGfQqOzz5e3C92zPmQf=0_mPV3MukCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-23 at 23:17 +0300, Or Gerlitz wrote:
> On Sun, Jun 23, 2013 at 6:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> >
> > mlx4 exclusively uses order-2 allocations in RX path, which are
> > likely to fail under memory pressure.
> >
> > We therefore drop frames more than needed.
> >
> > This patch tries order-3, order-2, order-1 and finally order-0
> > allocations to keep good performance, yet allow allocations if/when
> > memory gets fragmented.
> >
> > By using larger pages, and avoiding unnecessary get_page()/put_page()
> > on compound pages, this patch improves performance as well, lowering
> > false sharing on struct page.
> 
> Hi Eric, thanks for the patch, both Amir and Yevgeny are OOO, so it
> will take us a bit more time to conduct the review... but lets start:
> could you explain a little further what do you exactly refer to by
> "false sharing" in this context?

Every time mlx4 prepared a page frag into a skb, it did :
 - a get_page() in mlx4_en_alloc_frags()
 - a get_page() in mlx4_en_complete_rx_desc()
 - a put_page() in mlx4_en_free_frag()

-> lot of changes of page->_count

When this skb is consumed, frag is freed -> put_page()

-> decrement of page->_count

If the consumer is on a different cpu, this adds false sharing on
"struct page"

After my patch, mlx4 driver touches this "struct page" only once,
and the consumers will do their get_page() without being slowed down by
mlx4 driver/cpu. This reduces latencies.

> 
> Also, I am not fully sure, but I think the current driver code doesn't
> support splice and this somehow relates to how RX skbs are spread over
> pages. In that repsect, I wonder if this patch goes in the direction
> that would allow to support splice, or maybe takes us a bit back, as
> of moving to use order-3 allocations?

splice is supported by core networking, no worries ;)

It doesn't depend on order-whatever allocations.

BTW, splice() works well for TCP over loopback, and TX already uses
fragments in order-3 pages.

> 
> You've mentioned performance improvement, could you be more specific?
> what's the scheme under which you saw the improvement and what was
> that improvement.

A cpu might be fully dedicated to softirq handling, and skb consumed on
other cpus.

My patch removes ~60 atomic operations per allocated page

(21 frags, and for each frag, two get_page() and one put_page())

> 
> Last, as Amir wrote you, we're looking on re-using skbs on the RX
> patch to avoid sever performance hits when IOMMU is enabled. The team
> has not provided me yet the patch, but basically, if you look on the
> ixgbe patch that was made largely for that very same purpose
> (improving perf under IOMMU) f800326dca7bc158f4c886aa92f222de37993c80
> "ixgbe: Replace standard receive path with a page based receive" ,
> they use there order-0 or order-1 allocations, but not order-2 or
> order-3, also here I have some more catch up to conduct, so we'll
> see...

ixgbe do not support frag_size of 1536 bytes, but 2048 or 4096 bytes.
So using order-3 pages is not win for it.

But for mlx4, we gain 5% occupancy using order-3 pages (21 frags per
32K) over order-2 pages (10 frags per 16K), and 30 % over order-0 pages
(2 frags per 4K)

I don't know, current mlx4 driver is barely usable as is, unless you
make sure the host has enough memory, with plenty of order-2 pages.

And unless you have really specialized applications, there is never
enough memory.
