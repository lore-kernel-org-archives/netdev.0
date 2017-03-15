From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v2 net-next] mlx4: Better use of order-0 pages in RX path
Date: Wed, 15 Mar 2017 17:36:12 +0200
Message-ID: <60f6dc92-511d-b7be-64d2-2532e112d845@gmail.com>
References: <20170314151143.16231-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38670 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbdCOPgQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:36:16 -0400
Received: by mail-wm0-f50.google.com with SMTP id t189so26137065wmt.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 08:36:15 -0700 (PDT)
In-Reply-To: <20170314151143.16231-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 14/03/2017 5:11 PM, Eric Dumazet wrote:
> When adding order-0 pages allocations and page recycling in receive path,
> I added issues on PowerPC, or more generally on arches with large pages.
>
> A GRO packet, aggregating 45 segments, ended up using 45 page frags
> on 45 different pages. Before my changes we were very likely packing
> up to 42 Ethernet frames per 64KB page.
>
> 1) At skb freeing time, all put_page() on the skb frags now touch 45
>    different 'struct page' and this adds more cache line misses.
>    Too bad that standard Ethernet MTU is so small :/
>
> 2) Using one order-0 page per ring slot consumes ~42 times more memory
>    on PowerPC.
>
> 3) Allocating order-0 pages is very likely to use pages from very
>    different locations, increasing TLB pressure on hosts with more
>    than 256 GB of memory after days of uptime.
>
> This patch uses a refined strategy, addressing these points.
>
> We still use order-0 pages, but the page recyling technique is modified
> so that we have better chances to lower number of pages containing the
> frags for a given GRO skb (factor of 2 on x86, and 21 on PowerPC)
>
> Page allocations are split in two halves :
> - One currently visible by the NIC for DMA operations.
> - The other contains pages that already added to old skbs, put in
>   a quarantine.
>
> When we receive a frame, we look at the oldest entry in the pool and
> check if the page count is back to one, meaning old skbs/frags were
> consumed and the page can be recycled.
>
> Page allocations are attempted using high order ones, trying
> to lower TLB pressure. We remember in ring->rx_alloc_order the last attempted
> order and quickly decrement it in case of failures.
> Then mlx4_en_recover_from_oom() called every 250 msec will attempt
> to gradually restore rx_alloc_order to its optimal value.
>
> On x86, memory allocations stay the same. (One page per RX slot for MTU=1500)
> But on PowerPC, this patch considerably reduces the allocated memory.
>
> Performance gain on PowerPC is about 50% for a single TCP flow.
>
> On x86, I could not measure the difference, my test machine being
> limited by the sender (33 Gbit per TCP flow).
> 22 less cache line misses per 64 KB GRO packet is probably in the order
> of 2 % or so.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> Cc: Alexander Duyck <alexander.duyck@gmail.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 470 ++++++++++++++++-----------
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  15 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  54 ++-
>  3 files changed, 317 insertions(+), 222 deletions(-)
>

Hi Eric,

Thanks for your patch.

I will do the XDP tests and complete the review, by tomorrow.

Regards,
Tariq
