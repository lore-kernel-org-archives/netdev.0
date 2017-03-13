From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 14:01:10 +0200
Message-ID: <a6216d67-25b2-6355-e37b-b0e8ee66b7bb@gmail.com>
References: <20170313005848.7076-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33742 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752838AbdCMMBP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 08:01:15 -0400
Received: by mail-wr0-f193.google.com with SMTP id g10so19778536wrg.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 05:01:14 -0700 (PDT)
In-Reply-To: <20170313005848.7076-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric, thanks for your patch.

On 13/03/2017 2:58 AM, Eric Dumazet wrote:
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
> to lower TLB pressure.

I think MM-list people won't be happy with this.
We were doing a similar thing with order-5 pages in mlx5 Striding RQ:
Allocate and split high-order pages, to have:
- Physically contiguous memory,
- Less page allocations,
- Yet, keep a fine grained refcounts/truesize.
In case no high-order page available, fallback to using order-0 pages.

However, we changed this behavior, as it was fragmenting the memory, and 
depleting the high-order pages available quickly.

>
> On x86, memory allocations stay the same. (One page per RX slot for MTU=1500)
> But on PowerPC, this patch considerably reduces the allocated memory.
>
> Performance gain on PowerPC is about 50% for a single TCP flow.

Nice!

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
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 462 +++++++++++++++------------
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  15 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  54 +++-
>  3 files changed, 310 insertions(+), 221 deletions(-)
>

Thanks,
Tariq
