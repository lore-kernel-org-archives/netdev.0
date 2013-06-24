From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] mlx4: allow order-0 memory allocations in RX path
Date: Mon, 24 Jun 2013 17:10:54 +0300
Message-ID: <CAJZOPZLH8JEcHdv1v24BOTVd9b76dxKbVJv0127zAgGAPj_3Eg@mail.gmail.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	<1371757222-21412-2-git-send-email-amirv@mellanox.com>
	<1371763689.3252.419.camel@edumazet-glaptop>
	<51C6B602.20703@mellanox.com>
	<1372000676.3301.27.camel@edumazet-glaptop>
	<CAJZOPZ+-StTDm0D-jaeWGfQqOzz5e3C92zPmQf=0_mPV3MukCQ@mail.gmail.com>
	<1372022003.3301.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:51573 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab3FXOKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 10:10:55 -0400
Received: by mail-qa0-f53.google.com with SMTP id g10so2209820qah.5
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 07:10:54 -0700 (PDT)
In-Reply-To: <1372022003.3301.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 12:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2013-06-23 at 23:17 +0300, Or Gerlitz wrote:
>> On Sun, Jun 23, 2013 at 6:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> >
>> > mlx4 exclusively uses order-2 allocations in RX path, which are
>> > likely to fail under memory pressure.
>> >
>> > We therefore drop frames more than needed.
>> >
>> > This patch tries order-3, order-2, order-1 and finally order-0
>> > allocations to keep good performance, yet allow allocations if/when
>> > memory gets fragmented.
>> >
>> > By using larger pages, and avoiding unnecessary get_page()/put_page()
>> > on compound pages, this patch improves performance as well, lowering
>> > false sharing on struct page.
>>
>> Hi Eric, thanks for the patch, both Amir and Yevgeny are OOO, so it
>> will take us a bit more time to conduct the review... but lets start:
>> could you explain a little further what do you exactly refer to by
>> "false sharing" in this context?
>
> Every time mlx4 prepared a page frag into a skb, it did :
>  - a get_page() in mlx4_en_alloc_frags()
>  - a get_page() in mlx4_en_complete_rx_desc()
>  - a put_page() in mlx4_en_free_frag()
>
> -> lot of changes of page->_count
>
> When this skb is consumed, frag is freed -> put_page()
>
> -> decrement of page->_count
>
> If the consumer is on a different cpu, this adds false sharing on
> "struct page"
>
> After my patch, mlx4 driver touches this "struct page" only once,
> and the consumers will do their get_page() without being slowed down by
> mlx4 driver/cpu. This reduces latencies.
>
>>
>> Also, I am not fully sure, but I think the current driver code doesn't
>> support splice and this somehow relates to how RX skbs are spread over
>> pages. In that repsect, I wonder if this patch goes in the direction
>> that would allow to support splice, or maybe takes us a bit back, as
>> of moving to use order-3 allocations?
>
> splice is supported by core networking, no worries ;)
>
> It doesn't depend on order-whatever allocations.
>
> BTW, splice() works well for TCP over loopback, and TX already uses
> fragments in order-3 pages.

Yep, we've tried fio with splice today on mlx4_en NICs running
net-next and it works, I am not sure what was that past problem nor
does it matter too much when things are working now...

Or.
