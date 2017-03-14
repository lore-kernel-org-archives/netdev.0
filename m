From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Tue, 14 Mar 2017 06:34:45 -0700
Message-ID: <CANn89i+y3ZSfb+3+W=0-5uGJ=gm0tr2sY033ZFmL2Xc4X6__eQ@mail.gmail.com>
References: <20170313173432.GA31333@ast-mbp.thefacebook.com>
 <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
 <20170313183121.GA36306@ast-mbp.thefacebook.com> <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
 <20170313202300.GA52396@ast-mbp.thefacebook.com> <CANn89iK6+1KMuxv11TqvfNd2cWRPjWDNkFnO00uC15GMQfqs-g@mail.gmail.com>
 <20170313232137.GA77943@ast-mbp.thefacebook.com> <CANn89iL3ODh0xf=+P0gSYN-mGwACeeCO+OwtJzK5JEtOtMdPuw@mail.gmail.com>
 <20170313234050.GA82263@ast-mbp.thefacebook.com> <1489453331.28631.102.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170314045730.GA5211@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34416 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdCNNes (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:34:48 -0400
Received: by mail-io0-f180.google.com with SMTP id b140so10308402iof.1
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 06:34:47 -0700 (PDT)
In-Reply-To: <20170314045730.GA5211@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 9:57 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Mar 13, 2017 at 06:02:11PM -0700, Eric Dumazet wrote:
>> On Mon, 2017-03-13 at 16:40 -0700, Alexei Starovoitov wrote:
>>
>> > that's not how it works. It's a job of submitter to prove
>> > that additional code doesn't cause regressions especially
>> > when there are legitimate concerns.
>>
>> This test was moved out of the mlx4_en_prepare_rx_desc() section into
>> the XDP_TX code path.
>>
>>
>>         if (ring->page_cache.index > 0) {
>>                 /* XDP uses a single page per frame */
>>                 if (!frags->page) {
>>                         ring->page_cache.index--;
>>                         frags->page = ring->page_cache.buf[ring->page_cache.index].page;
>>                         frags->dma  = ring->page_cache.buf[ring->page_cache.index].dma;
>>                 }
>>                 frags->page_offset = XDP_PACKET_HEADROOM;
>>                 rx_desc->data[0].addr = cpu_to_be64(frags->dma +
>>                                                     XDP_PACKET_HEADROOM);
>>                 return 0;
>>         }
>>
>> Can you check again your claim, because I see no additional cost
>> for XDP_TX.
>
> Let's look what it was:
> - xdp_tx xmits the page regardless whether driver can replenish
> - at the end of the napi mlx4_en_refill_rx_buffers() will replenish
> rx in bulk either from page_cache or by allocating one page at a time
>
> after the changes:
> - xdp_tx will check page_cache if it's empty it will try to do
> order 10 (ten!!) alloc, will fail, will try to alloc single page,
> will xmit the packet, and will place just allocated page into rx ring.
> on the next packet in the same napi loop, it will try to allocate
> order 9 (since the cache is still empty), will fail, will try single
> page, succeed... next packet will try order 8 and so on.
> And that spiky order 10 allocations will be happening 4 times a second
> due to new logic in mlx4_en_recover_from_oom().
> We may get lucky and order 2 alloc will succeed, but before that
> we will waste tons of cycles.
> If an attacker somehow makes existing page recycling logic not effective,
> the xdp performance will be limited by order0 page allocator.
> Not great, but still acceptable.
> After this patch it will just tank due to this crazy scheme.
> Yet you're not talking about this new behavior in the commit log.
> You didn't test XDP at all and still claiming that everything is fine ?!
> NACK


Ouch. You NACK a patch based on fears from your side, just because I
said I would not spend time on XDP at this very moment.

We hardly allocate a page in our workloads, and a failed attempt to
get an order-10 page
with GFP_ATOMIC has exactly the same cost than a failed attempt of
order-0 or order-1 or order-X,
the buddy page allocator gives that for free.

So I will leave this to Mellanox for XDP tests and upstreaming this,
and will stop arguing with you, this is going nowhere.

I suggested some changes but you blocked everything just because I
publicly said that I would not use XDP,
which added a serious mess to this driver.
