From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: call dev_queue_xmit_nit() after
 skb_dst_drop()
Date: Tue, 07 Dec 2010 11:30:37 +0100
Message-ID: <1291717837.2695.13.camel@edumazet-laptop>
References: <1291706359.2769.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:53604 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655Ab0LGKan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 05:30:43 -0500
Received: by wwi17 with SMTP id 17so718609wwi.1
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 02:30:42 -0800 (PST)
In-Reply-To: <1291706359.2769.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 d=C3=A9cembre 2010 =C3=A0 08:19 +0100, Eric Dumazet a =C3=A9=
crit :
> Avoid some atomic ops on dst refcount, calling dev_queue_xmit_nit()
> after skb_dst_drop() in dev_hard_start_xmit().
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> Next patch will perform the sk_run_filter() in dev_queue_xmit_nit(),
> before cloning skb and af_packet rcv() call.
>=20
>  net/core/dev.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 55ff66f..59360ef 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2025,9 +2025,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
>  	int rc =3D NETDEV_TX_OK;
> =20
>  	if (likely(!skb->next)) {
> -		if (!list_empty(&ptype_all))
> -			dev_queue_xmit_nit(skb, dev);
> -
>  		/*
>  		 * If device doesnt need skb->dst, release it right now while
>  		 * its hot in this cpu cache
> @@ -2037,6 +2034,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
> =20
>  		skb_orphan_try(skb);
> =20
> +		if (!list_empty(&ptype_all))
> +			dev_queue_xmit_nit(skb, dev);
> +
>  		if (vlan_tx_tag_present(skb) &&
>  		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
>  			skb =3D __vlan_put_tag(skb, vlan_tx_tag_get(skb));
>=20

Hmm, this was wrong, and not what I wanted to do :

in dev_queue_xmit_nit() do following tests :

        /* Never send packets back to the socket
         * they originated from - MvS (miquels@drinkel.ow.org)
         */
        if ((ptype->dev =3D=3D dev || !ptype->dev) &&
            (ptype->af_packet_priv =3D=3D NULL ||
             (struct sock *)ptype->af_packet_priv !=3D skb->sk)) {
                struct sk_buff *skb2 =3D skb_clone(skb, GFP_ATOMIC);

So we should not move dev_queue_xmit_nit() after
skb_orphan_try(skb) or the (ptype->af_packet_priv !=3D skb->sk) test=20
is always true.

Here is V2 of patch :

[PATCH v2 net-next-2.6] net: call dev_queue_xmit_nit() after skb_dst_dr=
op()

Avoid some atomic ops on dst refcount, calling dev_queue_xmit_nit()
after skb_dst_drop() in dev_hard_start_xmit().

When queueing a packet into af_packet socket, we drop dst anyway.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 55ff66f..58930e4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2025,9 +2025,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	int rc =3D NETDEV_TX_OK;
=20
 	if (likely(!skb->next)) {
-		if (!list_empty(&ptype_all))
-			dev_queue_xmit_nit(skb, dev);
-
 		/*
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
@@ -2035,6 +2032,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(skb);
=20
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(skb, dev);
+
 		skb_orphan_try(skb);
=20
 		if (vlan_tx_tag_present(skb) &&


