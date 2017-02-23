From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Wed, 22 Feb 2017 17:08:54 -0800
Message-ID: <CAKgT0Uda3Q6MTCdFf2eR_5Sw9KMTzGrnTosxh2iFT6Sn6QCwrw@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com> <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mail-it0-f68.google.com ([209.85.214.68]:35330 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932197AbdBWBI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 20:08:56 -0500
Received: by mail-it0-f68.google.com with SMTP id 203so102938ith.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 17:08:55 -0800 (PST)
In-Reply-To: <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 10:21 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-22 at 09:23 -0800, Alexander Duyck wrote:
>> On Wed, Feb 22, 2017 at 8:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2017-02-13 at 11:58 -0800, Eric Dumazet wrote:
>> >> Use of order-3 pages is problematic in some cases.
>> >>
>> >> This patch might add three kinds of regression :
>> >>
>> >> 1) a CPU performance regression, but we will add later page
>> >> recycling and performance should be back.
>> >>
>> >> 2) TCP receiver could grow its receive window slightly slower,
>> >>    because skb->len/skb->truesize ratio will decrease.
>> >>    This is mostly ok, we prefer being conservative to not risk OOM,
>> >>    and eventually tune TCP better in the future.
>> >>    This is consistent with other drivers using 2048 per ethernet frame.
>> >>
>> >> 3) Because we allocate one page per RX slot, we consume more
>> >>    memory for the ring buffers. XDP already had this constraint anyway.
>> >>
>> >> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> >> ---
>> >
>> > Note that we also could use a different strategy.
>> >
>> > Assume RX rings of 4096 entries/slots.
>> >
>> > With this patch, mlx4 gets the strategy used by Alexander in Intel
>> > drivers :
>> >
>> > Each RX slot has an allocated page, and uses half of it, flipping to the
>> > other half every time the slot is used.
>> >
>> > So a ring buffer of 4096 slots allocates 4096 pages.
>> >
>> > When we receive a packet train for the same flow, GRO builds an skb with
>> > ~45 page frags, all from different pages.
>> >
>> > The put_page() done from skb_release_data() touches ~45 different struct
>> > page cache lines, and show a high cost. (compared to the order-3 used
>> > today by mlx4, this adds extra cache line misses and stalls for the
>> > consumer)
>> >
>> > If we instead try to use the two halves of one page on consecutive RX
>> > slots, we might instead cook skb with the same number of MSS (45), but
>> > half the number of cache lines for put_page(), so we should speed up the
>> > consumer.
>>
>> So there is a problem that is being overlooked here.  That is the cost
>> of the DMA map/unmap calls.  The problem is many PowerPC systems have
>> an IOMMU that you have to work around, and that IOMMU comes at a heavy
>> cost for every map/unmap call.  So unless you are saying you wan to
>> setup a hybrid between the mlx5 and this approach where we have a page
>> cache that these all fall back into you will take a heavy cost for
>> having to map and unmap pages.
>>
>> The whole reason why I implemented the Intel page reuse approach the
>> way I did is to try and mitigate the IOMMU issue, it wasn't so much to
>> resolve allocator/freeing expense.  Basically the allocator scales,
>> the IOMMU does not.  So any solution would require making certain that
>> we can leave the pages pinned in the DMA to avoid having to take the
>> global locks involved in accessing the IOMMU.
>
>
> I do not see any difference for the fact that we keep pages mapped the
> same way.
>
> mlx4_en_complete_rx_desc() will still use the :
>
> dma_sync_single_range_for_cpu(priv->ddev, dma, frags->page_offset,
>                               frag_size, priv->dma_dir);
>
> for every single MSS we receive.
>
> This wont change.

Right but you were talking about using both halves one after the
other.  If that occurs you have nothing left that you can reuse.  That
was what I was getting at.  If you use up both halves you end up
having to unmap the page.

The whole idea behind using only half the page per descriptor is to
allow us to loop through the ring before we end up reusing it again.
That buys us enough time that usually the stack has consumed the frame
before we need it again.

- Alex
