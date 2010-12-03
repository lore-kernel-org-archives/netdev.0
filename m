From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about __alloc_skb() speedup
Date: Fri, 03 Dec 2010 11:50:29 +0100
Message-ID: <1291373429.2897.96.camel@edumazet-laptop>
References: <20101203101450.GA9573@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58517 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932346Ab0LCKug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 05:50:36 -0500
Received: by wwa36 with SMTP id 36so9879932wwa.1
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 02:50:35 -0800 (PST)
In-Reply-To: <20101203101450.GA9573@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 18:14 +0800, Junchang Wang a =C3=
=A9crit :
> Hi Eric,
>=20
> I'm reading your patch (ec7d2f2cf3a1 __alloc_skb() speedup),
> in which you prefetch skb and the shinfo part. I'm very
> curious why we don't prefetch skb->data. It seems that will
> help tx path a lot.
>=20
> I added the following code
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 104f844..c60a808 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -222,6 +222,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gf=
p_t gfp_mask,
> =20
>  		child->fclone =3D SKB_FCLONE_UNAVAILABLE;
>  	}
> +	prefetchw(data);
> +
>  out:
>  	return skb;
>  nodata:
>=20
> and the pktgen in my server (A Intel SR1625 server with two E5530=20
> 4-core processors and a single ixgbe-based NIC) goes from 7.6Mpps to
> 8.4Mpps (64 byte), with 10% performance gain.
>=20
> For rx path, I did experiments on both ixgbe and igb with pktgen+kute=
,
> and there is no change in system performance.
>=20
> welcome any suggestions and corrections.
>=20
> Thanks.

This is because __alloc_skb() is generic :

We dont know if the skb->data is going to be used right after or not at
all.

=46or example, NIC drivers call __alloc_skb() to refill their RX ring
buffer. There is no gain to prefetch data in this case since the data i=
s
going to be written by the NIC hardware. The reverse would be needed
actually : ask to local cpu to evict data from its cache, so that devic=
e
can DMA it faster (less bus transactions)

By the way, adding prefetchw() right before the "return skb;" is
probably not very useful. You can certainly try to add the prefetchw()
in pktgen itself, since you know for sure you are going to write the
data.

I dont understand your 10% speedup because pktgen actually uses
__netdev_alloc_skb(), so it calls skb_reserve(skb, NET_SKB_PAD) : your
prefetchw is bringing a cache line that wont be used at all by pktgen.

I would say 10% sounds highly suspect to me...



