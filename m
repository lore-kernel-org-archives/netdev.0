From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 1/4] net/mlx5e: Restore the skb data pointer
 after xmit is finished
Date: Sun, 20 Dec 2015 15:02:07 +0200
Message-ID: <CALzJLG9dOPrN4E8qSTA8djtRS8fDmqY9XHz3X1acQnhPeUoEUg@mail.gmail.com>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
	<1450355735-30846-2-git-send-email-saeedm@mellanox.com>
	<20151217.152104.2240043588504838923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>, eranbe@mellanox.com,
	Tal Alon <talal@mellanox.com>, richardcochran@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34302 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbbLTNC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 08:02:28 -0500
Received: by mail-yk0-f175.google.com with SMTP id p130so106895336yka.1
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2015 05:02:08 -0800 (PST)
In-Reply-To: <20151217.152104.2240043588504838923.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 10:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Thu, 17 Dec 2015 14:35:32 +0200
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
>> index 1341b1d..0fcfe64 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
>> @@ -165,6 +165,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
>>       struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
>>       struct mlx5_wqe_data_seg *dseg;
>>
>> +     unsigned char *skb_data_orig = skb->data;
>>       u8  opcode = MLX5_OPCODE_SEND;
>>       dma_addr_t dma_addr = 0;
>>       bool bf = false;
>> @@ -263,6 +264,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
>>       cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | opcode);
>>       cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | ds_cnt);
>>
>> +     skb_push(skb, skb->data - skb_data_orig);
>>       sq->skb[pi] = skb;
>>
>>       MLX5E_TX_SKB_CB(skb)->num_wqebbs = DIV_ROUND_UP(ds_cnt,
>
> And in the middle of this we have:
>
>                 skb_pull_inline(skb, ihs);
>
> This is looks illegal.
>
> You must not modify the data pointers of any SKB that you receive for
> sending via ->ndo_start_xmit() unless you know that absolutely you are
> the one and only reference that exists to that SKB.
>
> And exactly for the case you are trying to "fix" here, you do not.  If
> the SKB is cloned, or has an elevated users count, someone else can be
> looking at it exactly at the same time you are messing with the data
> pointers.

Agree, we will provide a fix soon.

>
> I bet mlx4 has this bug too.

I did a quick review and I din't see that we mess with SKB data pointer in mlx4.
if you know of such bug in mlx4, please share with us, we will handle ASAP.

> You must fix this properly, by keeping track of an offset or similar
> internally to your driver, rather than changing the SKB data pointers.
>
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
