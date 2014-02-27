From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/9] net/mlx4_en: Pad ethernet packets smaller
 than 17 bytes
Date: Thu, 27 Feb 2014 13:08:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CCB7E@AcuExch.aculab.com>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
 <1393504026-13384-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"Eugenia Emantayev" <eugenia@mellanox.com>
To: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36380 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750742AbaB0NKG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 08:10:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10254-06 for <netdev@vger.kernel.org>;
 Thu, 27 Feb 2014 13:10:02 +0000 (GMT)
In-Reply-To: <1393504026-13384-4-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai
> Hardware can't accept packets smaller than 17 bytes. Therefore need to pad with
> zeros.

Can they actually happen?
A 16 byte packet would only have 2 bytes following the ethertype/length.
The shortest LLC packets have 3 bytes.
It may well be safe to discard them.

...
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 8dc7637..268cc4a 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -585,12 +585,19 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
>  	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
> 
>  	if (skb->len <= spc) {
> -		inl->byte_count = cpu_to_be32(1 << 31 | skb->len);
> +		inl->byte_count = cpu_to_be32(1 << 31 |
> +					      max_t(typeof(skb->len),
> +						    skb->len,
> +						    MIN_PKT_LEN));
>  		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
>  		if (skb_shinfo(skb)->nr_frags)
>  			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
>  			       skb_frag_size(&skb_shinfo(skb)->frags[0]));

Is there guaranteed to be only 1 fragment here?

> +		if (skb->len < MIN_PKT_LEN)
> +			memset(((void *)(inl + 1)) + skb->len, 0,
> +			       MIN_PKT_LEN - skb->len);
> +

In any case you don't want 2 checks for skb->len < MIN_PKT_LEN,
so reassign to inl->byte_count here.
An unlikely() probably wouldn't go amiss either.

	David
