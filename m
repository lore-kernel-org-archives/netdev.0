From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 0/9] mlx4: order-0 allocations and page recycling
Date: Tue, 7 Feb 2017 11:18:27 -0800
Message-ID: <CANn89iKvA6FBbN2o8dnisd_VFrFfm+WFqMFX50gdQCpRTdpX1Q@mail.gmail.com>
References: <20170207030240.31357-1-edumazet@google.com> <3b996d14-0471-1fa3-e686-15cf48db4c19@gmail.com>
 <1486483592.7793.56.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486484783.7793.61.camel@edumazet-glaptop3.roam.corp.google.com> <20170207190546.GA51444@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:32861 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754217AbdBGTS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:18:29 -0500
Received: by mail-io0-f176.google.com with SMTP id v96so98229696ioi.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 11:18:29 -0800 (PST)
In-Reply-To: <20170207190546.GA51444@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 11:05 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Feb 07, 2017 at 08:26:23AM -0800, Eric Dumazet wrote:
>> On Tue, 2017-02-07 at 08:06 -0800, Eric Dumazet wrote:
>>
>
> Awesome that you've started working on this. I think it's correct approach
> and mlx5 should be cleaned up in similar way.
> Long term we should be able to move all page alloc/free out of the drivers
> completely.
>
>> >             /*
>> >              * make sure we read the CQE after we read the ownership bit
>> >              */
>> >             dma_rmb();
>> > +           prefetch(frags[0].page);
>>
>> Note that I would like to instead do a prefetch(frags[1].page)
>
> yeah, this two look weird:
> +               prefetch(frags[0].page);
> +               va = page_address(frags[0].page) + frags[0].page_offset;
>
> on most archs page_addres() is just math (not a load from memory),
> but the result != frags[0].page, so I'm missing what are you trying to prefetch?
>
> prefetch(frags[1].page)
> is even more confusing. what will it prefetch?


The "struct page"  of the following frame

Remember we need :

                 release = page_count(page) != 1 ||
                                page_is_pfmemalloc(page) ||
                                page_to_nid(page) != numa_mem_id();

Then :

page_ref_inc(page);


My patch now does :

prefetch(frags[priv->num_frags].page);

>
> btw we had a patch that was doing prefetch of 'va' of next packet
> and it was very helpful. Like this:

I preferred to fetch the second cache line of this frame,
because TCP is mostly used with timestamps : total of 66 bytes of
header with IPv4, and more for IPV6 of course.


>    pref_index = (index + 1) & ring->size_mask;
>    pref = ring->rx_info + (pref_index << priv->log_rx_info);
>    prefetch(page_address(pref->page) + pref->page_offset);
>
> but since you're redesigning rxing->rx_info... not sure how will it fit.
>
>> So I will probably change how ring->rx_info is allocated
>>
>> wasting all that space and forcing vmalloc() is silly :
>>
>> tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
>>                                 sizeof(struct mlx4_en_rx_alloc));
>
> I think you'd still need roundup_pow_of_two otherwise priv->log_rx_info
> optimization won't work.

No more log_rx_info trick.

Simply : frags = priv->rx_info + (index * priv->rx_info_bytes_per_slot);

A multiply is damn fast these days compared to cache misses.

Using 24*<rx_ring_size> bytes is better than 32*<rx_ring_size>, our
L1/L2 caches are quite small.

Of course, this applies to the 'stress' mode, not the light mode where
we receive one single packet per IRQ.
