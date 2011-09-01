From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1 -next] 6LoWPAN: fix skb_copy call
Date: Thu, 01 Sep 2011 13:30:15 +0200
Message-ID: <1314876615.2823.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314879675-31989-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36645 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab1IALaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 07:30:16 -0400
In-Reply-To: <1314879675-31989-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 septembre 2011 =C3=A0 16:21 +0400, Alexander Smirnov a =C3=A9=
crit :
> This patch fixes 2 issues in lowpan_skb_deliver function:
> 1. Check for return status of skb_copy call;
> 2. Use skb_copy with proper GFP flag depending on context.
>=20

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>

patch adds a new bug, see below

> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
>  net/ieee802154/6lowpan.c |   18 +++++++++++++++---
>  1 files changed, 15 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index cf304cc..cac1361 100644
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
> +
> +	new =3D skb_copy_expand(skb, sizeof(struct ipv6hdr),
> +					skb_tailroom(skb), mask);
>  	kfree_skb(skb);
> =20
>  	if (NULL =3D=3D new)
> @@ -495,7 +501,13 @@ static int lowpan_skb_deliver(struct sk_buff *sk=
b, struct ipv6hdr *hdr)
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(entry, &lowpan_devices, list)
>  		if (lowpan_dev_info(entry->ldev)->real_dev =3D=3D new->dev) {
> -			skb =3D skb_copy(new, GFP_KERNEL);
> +			skb =3D skb_copy(new, mask);
> +
> +			if (NULL =3D=3D skb) {
> +				kfree_skb(new);

rcu_read_unlock() missing.

	just do :=20
			stat =3D -ENOMEM;
			break; (to exit from list_for_each_entry_rcu())=20

> +				return -ENOMEM;
> +			}
> +
>  			skb->dev =3D entry->ldev;
> =20
>  			if (in_interrupt())
