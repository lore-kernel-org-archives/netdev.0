From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 -next] 6LoWPAN: fix skb_copy call
Date: Thu, 01 Sep 2011 14:00:43 +0200
Message-ID: <1314878443.2823.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314879675-31989-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	 <1314881653-1104-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53352 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab1IAMAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 08:00:44 -0400
In-Reply-To: <1314881653-1104-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 septembre 2011 =C3=A0 16:54 +0400, Alexander Smirnov a =C3=A9=
crit :
> This patch fixes 2 issues in lowpan_skb_deliver function:
> 1. Check for return status of skb_copy call;
> 2. Use skb_copy with proper GFP flag depending on context.
>=20
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
>  net/ieee802154/6lowpan.c |   18 +++++++++++++++---
>  1 files changed, 15 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index cf304cc..16100be 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -477,9 +477,15 @@ static int lowpan_skb_deliver(struct sk_buff *sk=
b, struct ipv6hdr *hdr)
>  	struct sk_buff *new;
>  	struct lowpan_dev_record *entry;
>  	int stat =3D NET_RX_SUCCESS;
> +	gfp_t mask;
> =20
> -	new =3D skb_copy_expand(skb, sizeof(struct ipv6hdr), skb_tailroom(s=
kb),
> -								GFP_KERNEL);
> +	if (in_interrupt())
> +		mask =3D GFP_ATOMIC;
> +	else
> +		mask =3D GFP_KERNEL;

I am not sure to understand if lowpan_skb_deliver() can be called in
pure process context. I feel we are in softirq handler or we have
disabled BH, so GFP_ATOMIC is the only choice.

If you are unsure, you could use following helper :

	mask =3D gfp_any();

> +
> +	new =3D skb_copy_expand(skb, sizeof(struct ipv6hdr),
> +					skb_tailroom(skb), mask);
>  	kfree_skb(skb);
> =20
