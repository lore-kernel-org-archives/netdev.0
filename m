From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use skb_get_rxhash()
Date: Tue, 24 Aug 2010 12:21:02 +0200
Message-ID: <1282645262.2477.64.camel@edumazet-laptop>
References: <1282643558-20866-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59158 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188Ab0HXKVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 06:21:08 -0400
Received: by wyb35 with SMTP id 35so281534wyb.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 03:21:07 -0700 (PDT)
In-Reply-To: <1282643558-20866-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9crit=
 :
> Although it is rare the line contains skb->rxhash is executed:
>=20
>  * The forwarded skbs should have the the rx queue recoreded.
>  * The local generated skbs should have non zero sk_hash in most of c=
ases.
>=20
> when it is executed, a non zero rxhash will be better.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 859e30f..ea041fd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2034,7 +2034,7 @@ u16 skb_tx_hash(const struct net_device *dev, c=
onst struct sk_buff *skb)
>  	if (skb->sk && skb->sk->sk_hash)
>  		hash =3D skb->sk->sk_hash;
>  	else
> -		hash =3D (__force u16) skb->protocol ^ skb->rxhash;
> +		hash =3D (__force u16) skb->protocol ^ skb_get_rxhash(skb);
>  	hash =3D jhash_1word(hash, hashrnd);
> =20
>  	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
> --

Instead of adding hacks and growing kernel code (considering your
previous patch), could we sit down and fix existing code, if really
needed ?

Spirit of existing code is that tcp/udp sockets have a sk_hash field,
and this feeds skb->rxhash in transmit path.

(check commit 87fd308c for an example of a fix)

I do think its better to chose a hash value per socket, instead of doin=
g
it per packet (duplicated work, and slowdown mono threaded apps because
their working set will be shared by several queues, then several cpus)




