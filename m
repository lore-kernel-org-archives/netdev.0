From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4_en: Pad ethernet packets smaller than 17 bytes
Date: Thu, 27 Feb 2014 16:02:05 +0200
Message-ID: <20140227140203.GA13112@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
 <1393504026-13384-4-git-send-email-amirv@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6CCB7E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63682 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaB0OCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 09:02:09 -0500
Received: by mail-wi0-f178.google.com with SMTP id cc10so3517770wib.5
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 06:02:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CCB7E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/02/14 13:08 +0000, David Laight wrote:
> From: Amir Vadai
> > Hardware can't accept packets smaller than 17 bytes. Therefore need to pad with
> > zeros.
> 
> Can they actually happen?
> A 16 byte packet would only have 2 bytes following the ethertype/length.
> The shortest LLC packets have 3 bytes.
Raw sockets might send such packets and it will put the HW into
unstable state.

> It may well be safe to discard them.
Yep - that another option.

> 
> ...
> > 
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > index 8dc7637..268cc4a 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > @@ -585,12 +585,19 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
> >  	int spc = MLX4_INLINE_ALIGN - CTRL_SIZE - sizeof *inl;
> > 
> >  	if (skb->len <= spc) {
> > -		inl->byte_count = cpu_to_be32(1 << 31 | skb->len);
> > +		inl->byte_count = cpu_to_be32(1 << 31 |
> > +					      max_t(typeof(skb->len),
> > +						    skb->len,
> > +						    MIN_PKT_LEN));
> >  		skb_copy_from_linear_data(skb, inl + 1, skb_headlen(skb));
> >  		if (skb_shinfo(skb)->nr_frags)
> >  			memcpy(((void *)(inl + 1)) + skb_headlen(skb), fragptr,
> >  			       skb_frag_size(&skb_shinfo(skb)->frags[0]));
> 
> Is there guaranteed to be only 1 fragment here?
> 
Yes, skb will not be classified as inline-able if nr_frags != 1.
See is_inline()

> > +		if (skb->len < MIN_PKT_LEN)
> > +			memset(((void *)(inl + 1)) + skb->len, 0,
> > +			       MIN_PKT_LEN - skb->len);
> > +
> 
> In any case you don't want 2 checks for skb->len < MIN_PKT_LEN,
> so reassign to inl->byte_count here.
> An unlikely() probably wouldn't go amiss either.
Right - will fix it for V1

> 
> 	David
> 

Thanks,
Amir
