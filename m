From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Wed, 22 Feb 2017 09:23:51 -0800
Message-ID: <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35895 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932899AbdBVRXx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 12:23:53 -0500
Received: by mail-it0-f68.google.com with SMTP id w185so997951ita.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 09:23:53 -0800 (PST)
In-Reply-To: <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 8:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-02-13 at 11:58 -0800, Eric Dumazet wrote:
>> Use of order-3 pages is problematic in some cases.
>>
>> This patch might add three kinds of regression :
>>
>> 1) a CPU performance regression, but we will add later page
>> recycling and performance should be back.
>>
>> 2) TCP receiver could grow its receive window slightly slower,
>>    because skb->len/skb->truesize ratio will decrease.
>>    This is mostly ok, we prefer being conservative to not risk OOM,
>>    and eventually tune TCP better in the future.
>>    This is consistent with other drivers using 2048 per ethernet frame.
>>
>> 3) Because we allocate one page per RX slot, we consume more
>>    memory for the ring buffers. XDP already had this constraint anyway.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>
> Note that we also could use a different strategy.
>
> Assume RX rings of 4096 entries/slots.
>
> With this patch, mlx4 gets the strategy used by Alexander in Intel
> drivers :
>
> Each RX slot has an allocated page, and uses half of it, flipping to the
> other half every time the slot is used.
>
> So a ring buffer of 4096 slots allocates 4096 pages.
>
> When we receive a packet train for the same flow, GRO builds an skb with
> ~45 page frags, all from different pages.
>
> The put_page() done from skb_release_data() touches ~45 different struct
> page cache lines, and show a high cost. (compared to the order-3 used
> today by mlx4, this adds extra cache line misses and stalls for the
> consumer)
>
> If we instead try to use the two halves of one page on consecutive RX
> slots, we might instead cook skb with the same number of MSS (45), but
> half the number of cache lines for put_page(), so we should speed up the
> consumer.

So there is a problem that is being overlooked here.  That is the cost
of the DMA map/unmap calls.  The problem is many PowerPC systems have
an IOMMU that you have to work around, and that IOMMU comes at a heavy
cost for every map/unmap call.  So unless you are saying you wan to
setup a hybrid between the mlx5 and this approach where we have a page
cache that these all fall back into you will take a heavy cost for
having to map and unmap pages.

The whole reason why I implemented the Intel page reuse approach the
way I did is to try and mitigate the IOMMU issue, it wasn't so much to
resolve allocator/freeing expense.  Basically the allocator scales,
the IOMMU does not.  So any solution would require making certain that
we can leave the pages pinned in the DMA to avoid having to take the
global locks involved in accessing the IOMMU.

> This means the number of active pages would be minimal, especially on
> PowerPC. Pages that have been used by X=2 received frags would be put in
> a quarantine (size to be determined).
> On PowerPC, X would be PAGE_SIZE/frag_size
>
>
> This strategy would consume less memory on PowerPC :
> 65535/1536 = 42, so a 4096 RX ring would need 98 active pages instead of
> 4096.
>
> The quarantine would be sized to increase chances of reusing an old
> page, without consuming too much memory.
>
> Probably roundup_pow_of_two(rx_ring_size / (PAGE_SIZE/frag_size))
>
> x86 would still use 4096 pages, but PowerPC would use 98+128 pages
> instead of 4096) (14 MBytes instead of 256 MBytes)

So any solution will need to work with an IOMMU enabled on the
platform.  I assume you have some x86 test systems you could run with
an IOMMU enabled.  My advice would be to try running in that
environment and see where the overhead lies.

- Alex
