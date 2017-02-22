From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Wed, 22 Feb 2017 08:22:38 -0800
Message-ID: <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170213195858.5215-1-edumazet@google.com>
         <20170213195858.5215-9-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33796 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbdBVQWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:22:40 -0500
Received: by mail-pg0-f65.google.com with SMTP id s67so1078492pgb.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:22:40 -0800 (PST)
In-Reply-To: <20170213195858.5215-9-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-13 at 11:58 -0800, Eric Dumazet wrote:
> Use of order-3 pages is problematic in some cases.
> 
> This patch might add three kinds of regression :
> 
> 1) a CPU performance regression, but we will add later page
> recycling and performance should be back.
> 
> 2) TCP receiver could grow its receive window slightly slower,
>    because skb->len/skb->truesize ratio will decrease.
>    This is mostly ok, we prefer being conservative to not risk OOM,
>    and eventually tune TCP better in the future.
>    This is consistent with other drivers using 2048 per ethernet frame.
> 
> 3) Because we allocate one page per RX slot, we consume more
>    memory for the ring buffers. XDP already had this constraint anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Note that we also could use a different strategy.

Assume RX rings of 4096 entries/slots.

With this patch, mlx4 gets the strategy used by Alexander in Intel
drivers : 

Each RX slot has an allocated page, and uses half of it, flipping to the
other half every time the slot is used.

So a ring buffer of 4096 slots allocates 4096 pages.

When we receive a packet train for the same flow, GRO builds an skb with
~45 page frags, all from different pages.

The put_page() done from skb_release_data() touches ~45 different struct
page cache lines, and show a high cost. (compared to the order-3 used
today by mlx4, this adds extra cache line misses and stalls for the
consumer)

If we instead try to use the two halves of one page on consecutive RX
slots, we might instead cook skb with the same number of MSS (45), but
half the number of cache lines for put_page(), so we should speed up the
consumer.

This means the number of active pages would be minimal, especially on
PowerPC. Pages that have been used by X=2 received frags would be put in
a quarantine (size to be determined).
On PowerPC, X would be PAGE_SIZE/frag_size


This strategy would consume less memory on PowerPC : 
65535/1536 = 42, so a 4096 RX ring would need 98 active pages instead of
4096.

The quarantine would be sized to increase chances of reusing an old
page, without consuming too much memory.

Probably roundup_pow_of_two(rx_ring_size / (PAGE_SIZE/frag_size))

x86 would still use 4096 pages, but PowerPC would use 98+128 pages
instead of 4096) (14 MBytes instead of 256 MBytes)
