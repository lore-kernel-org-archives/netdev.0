From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 2/7] mlx4: use napi_consume_skb API to get bulk
 free operations
Date: Wed, 9 Mar 2016 08:47:58 -0800
Message-ID: <CAKgT0UeiAaMdGOzqFcC2iWRvrFC1MUcFM6czU=Kd+Et=5MGp0w@mail.gmail.com>
References: <20160304130054.32651.51776.stgit@firesoul>
	<20160304130133.32651.55278.stgit@firesoul>
	<20160308.142422.1791364638495761357.davem@davemloft.net>
	<20160309120039.38cfdb88@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, eugenia@mellanox.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36212 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933344AbcCIQr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 11:47:59 -0500
Received: by mail-io0-f171.google.com with SMTP id z76so72835941iof.3
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 08:47:58 -0800 (PST)
In-Reply-To: <20160309120039.38cfdb88@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2016 at 3:00 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Tue, 08 Mar 2016 14:24:22 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
>
>> From: Jesper Dangaard Brouer <brouer@redhat.com>
>> Date: Fri, 04 Mar 2016 14:01:33 +0100
>>
>> > @@ -276,7 +276,8 @@ static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
>> >
>> >  static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
>> >                             struct mlx4_en_tx_ring *ring,
>> > -                           int index, u8 owner, u64 timestamp)
>> > +                           int index, u8 owner, u64 timestamp,
>> > +                           int napi_mode)
>> >  {
>> >     struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
>> >     struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
>> > @@ -347,7 +348,11 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
>> >                     }
>> >             }
>> >     }
>> > -   dev_consume_skb_any(skb);
>> > +   if (unlikely(napi_mode < 0))
>> > +           dev_consume_skb_any(skb); /* none-NAPI via mlx4_en_stop_port */
>> > +   else
>> > +           napi_consume_skb(skb, napi_mode);
>> > +
>> >     return tx_info->nr_txbb;
>> >  }
>>
>> If '0' is the signal that napi_consume_skb() uses to detect the case where we
>> can't bulk, just pass that instead of having a special test here on yet another
>> special value "-1".
>
> Cannot use '0' to signal this, because napi_consume_skb() invoke
> dev_consume_skb_irq(), and here we need dev_consume_skb_any(), as
> mlx4_en_stop_port() assume memory is released immediately.
>
> I guess, we can (in napi_consume_skb) just replace the
> dev_consume_skb_irq() with dev_consume_skb_any(), and then use '0' to
> signal both situations?
>
>
>> If it makes any nicer, you can define a NAPI_BUDGET_FROM_NETPOLL macro
>> or similar.
>>
>> I also wonder if passing the budget around all the way down to
>> napi_consume_skb() is the cleanest thing to do, as we just want to
>> know if bulk freeing is possible or not.
>
> Passing the budget down was Alex'es design.  Axel any thoughts?

I'd say just use dev_consume_skb_any in the bulk free instead of
dev_consume_skb_irq.  This is slow path, as you said, so it shouldn't
come up often.

> Perhaps we can use another way to detect if bulk freeing is possible?
> E.g. using test in_serving_softirq() ?
>
>    if (!in_serving_softirq())
>        dev_consume_skb_any(skb); /* cannot bulk free */
>
> Or maybe in_softirq() is enough? (to also allows callers having bh disabled).

I wasn't so much concerned about the check as us getting it mixed up.
For example the Tx path has soft IRQ disabled if I recall correctly.
Is this called from there?  At least with the "any" approach you can
guarantee you don't leave stale buffers sitting in the lists until
someone wakes up NAPI.

> I do wonder how expensive this check is... as it goes into a code
> hotpath, which is very unlikely.  The good thing would be, that we
> handle if buggy drivers call this function from a none softirq context
> (as these bugs could be hard to catch).
>
> Can netpoll ever be called from softirq or with BH disabled? (It
> disables IRQs, which would break calling kmem_cache_free_bulk).

It is better for us to switch things out so that the napi_consume_skb
is the fast path with dev_consume_skb_any as the slow.  There are too
many scenarios where we could be invoking something that makes use of
this within the Tx path so it is probably easiest to just solve it
that way so we don't have to deal with it again in the future.

- Alex
