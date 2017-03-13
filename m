From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 05:54:49 -0700
Message-ID: <1489409689.28631.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170313005848.7076-1-edumazet@google.com>
         <a6216d67-25b2-6355-e37b-b0e8ee66b7bb@gmail.com>
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
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35766 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdCMMzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 08:55:06 -0400
Received: by mail-pg0-f41.google.com with SMTP id b129so63420831pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 05:55:05 -0700 (PDT)
In-Reply-To: <a6216d67-25b2-6355-e37b-b0e8ee66b7bb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 14:01 +0200, Tariq Toukan wrote:

> I think MM-list people won't be happy with this.
> We were doing a similar thing with order-5 pages in mlx5 Striding RQ:
> Allocate and split high-order pages, to have:
> - Physically contiguous memory,
> - Less page allocations,
> - Yet, keep a fine grained refcounts/truesize.
> In case no high-order page available, fallback to using order-0 pages.
> 
> However, we changed this behavior, as it was fragmenting the memory, and 
> depleting the high-order pages available quickly.


Sure, I was not happy with this schem either.

I was the first to complain and suggest split_page() one year ago.

mlx5 was using __GFP_MEMALLOC for its MLX5_MPWRQ_WQE_PAGE_ORDER
allocations, and failure had no fallback.

mlx5e_alloc_rx_mpwqe() was simply giving up immediately.

Very different behavior there, since :

1) we normally recycle 99% [1] of the pages, and rx_alloc_order quickly
decreases under memory pressure.


2) My high order allocations use __GFP_NOMEMALLOC to cancel the
__GFP_MEMALLOC

3) Also note that I chose to periodically reset rx_alloc_order from
mlx4_en_recover_from_oom() to the initial value.
   We could later change this to a slow recovery if really needed, but
   my tests were fine with this.


[1] This driver might need to change the default RX ring sizes.
    1024 slots is a bit short for 40Gbit NIC these days.

    (We tune this to 4096)

Thanks !
