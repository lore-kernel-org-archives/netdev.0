From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 -next] 6LoWPAN: fix skb_copy call
Date: Thu, 01 Sep 2011 17:31:03 +0200
Message-ID: <1314891063.2823.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314879675-31989-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1314885315-4033-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45975 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932397Ab1IAPbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 11:31:06 -0400
In-Reply-To: <1314885315-4033-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 septembre 2011 =C3=A0 17:55 +0400, Alexander Smirnov a =C3=A9=
crit :
> This patch fixes 2 issues in lowpan_skb_deliver function:
> 1. Check for return status of skb_copy call;
> 2. Use skb_copy with proper GFP flag, drop check for non-interrupt
> context.
>=20
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/ieee802154/6lowpan.c |   17 +++++++++--------
>  1 files changed, 9 insertions(+), 8 deletions(-)
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index cf304cc..deb2adf 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -479,10 +479,10 @@ static int lowpan_skb_deliver(struct sk_buff *s=
kb, struct ipv6hdr *hdr)
>  	int stat =3D NET_RX_SUCCESS;
> =20
>  	new =3D skb_copy_expand(skb, sizeof(struct ipv6hdr), skb_tailroom(s=
kb),
> -								GFP_KERNEL);
> +								GFP_ATOMIC);
>  	kfree_skb(skb);
> =20
> -	if (NULL =3D=3D new)
> +	if (!new)
>  		return -ENOMEM;
> =20
>  	skb_push(new, sizeof(struct ipv6hdr));
> @@ -495,13 +495,14 @@ static int lowpan_skb_deliver(struct sk_buff *s=
kb, struct ipv6hdr *hdr)
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(entry, &lowpan_devices, list)
>  		if (lowpan_dev_info(entry->ldev)->real_dev =3D=3D new->dev) {
> -			skb =3D skb_copy(new, GFP_KERNEL);
> -			skb->dev =3D entry->ldev;
> +			skb =3D skb_copy(new, GFP_ATOMIC);
> +			if (!skb) {
> +				stat =3D -ENOMEM;
> +				break;
> +			}
> =20
> -			if (in_interrupt())
> -				stat =3D netif_rx(skb);
> -			else
> -				stat =3D netif_rx_ni(skb);
> +			skb->dev =3D entry->ldev;
> +			stat =3D netif_rx(skb);
>  		}
>  	rcu_read_unlock();
> =20
