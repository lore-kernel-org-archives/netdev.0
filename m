From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/3 -next] 6LoWPAN: use kfree_skb() instead of kfree()
Date: Tue, 30 Aug 2011 16:40:48 +0200
Message-ID: <1314715248.2935.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110830134552.GH3705@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:IEEE 802.15.4 SUB..."
	<linux-zigbee-devel@lists.sourceforge.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65482 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab1H3Okr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:40:47 -0400
In-Reply-To: <20110830134552.GH3705@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 16:45 +0300, Dan Carpenter a =C3=A9cr=
it :
> Use kfree_skb() to free sbk_buffs.
>=20
> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index cf304cc..8a9dbaa 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -674,7 +674,7 @@ lowpan_process_data(struct sk_buff *skb)
>  							sizeof(hdr));
>  	return lowpan_skb_deliver(skb, &hdr);
>  drop:
> -	kfree(skb);
> +	kfree_skb(skb);
>  	return -EINVAL;
>  }
> =20

Another bug is the skb_copy() done in lowpan_skb_deliver()

1) No check of skb_copy() return=20

2.1) Use of GFP_KERNEL : Is it safe at this point ? Aren=E2=80=99t we i=
n
softirq ?

2.2) If GFP_KERNEL is safe, why do we later do :

	if (in_interrupt())
		stat =3D netif_rx(skb);
	else
		stat =3D netif_rx_ni(skb);
