From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] gianfar: Fix invalid TX frames returned on error
 queue when time stamping.
Date: Mon, 09 Jan 2012 16:12:00 +0100
Message-ID: <1326121920.2407.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326120774-20647-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@mvista.com,
	richardcochran@gmail.com
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59509 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab2AIPMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 10:12:05 -0500
Received: by wibhm6 with SMTP id hm6so2632111wib.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 07:12:04 -0800 (PST)
In-Reply-To: <1326120774-20647-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 janvier 2012 =C3=A0 15:52 +0100, Manfred Rudigier a =C3=A9c=
rit :
> When TX time stamping for PTP messages is enabled on a socket, a time
> stamp is returned on the socket error queue to the user space applica=
tion
> after the frame was transmitted. The transmitted frame is also return=
ed on
> the error queue so that an application knows to which frame the time =
stamp
> belongs.

=2E..

>  	/* make space for additional header when fcb is needed */
>  	if (((skb->ip_summed =3D=3D CHECKSUM_PARTIAL) ||
>  			vlan_tx_tag_present(skb) ||
>  			unlikely(do_tstamp)) &&
> -			(skb_headroom(skb) < GMAC_FCB_LEN)) {
> +			(skb_headroom(skb) < fcb_length)) {
>  		struct sk_buff *skb_new;
> =20
> -		skb_new =3D skb_realloc_headroom(skb, GMAC_FCB_LEN);
> +		skb_new =3D skb_realloc_headroom(skb, fcb_length);
>  		if (!skb_new) {
>  			dev->stats.tx_errors++;
>  			kfree_skb(skb);
>  			return NETDEV_TX_OK;
>  		}
> +
> +		/* Hold sock reference for processing TX time stamps */
> +		if (unlikely(do_tstamp)) {
> +			struct sock *sk =3D skb->sk;

Not clear to me why sk_refcnt could be 0 here

> +			if (!atomic_inc_not_zero(&sk->sk_refcnt)) {
> +				dev->stats.tx_errors++;
> +				kfree_skb(skb_new);
> +				kfree_skb(skb);
> +				return NETDEV_TX_OK;
> +			}
> +			skb_new->sk =3D skb->sk;
> +		}
> +
>  		kfree_skb(skb);
>  		skb =3D skb_new;

Not clear to me why ->destructor access is not needed here.

This change should be isolated from your patch IMHO

I would rather do something like :

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/eth=
ernet/freescale/gianfar.c
index e01cdaa..8e00461 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2086,6 +2086,8 @@ static int gfar_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 			kfree_skb(skb);
 			return NETDEV_TX_OK;
 		}
+		swap(skb_new->sk, skb->sk);
+		swap(skb_new->destructor, skb->destructor);
 		kfree_skb(skb);
 		skb =3D skb_new;
 	}
