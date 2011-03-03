From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v2] bonding: COW before overwriting the destination
 MAC address
Date: Thu, 03 Mar 2011 08:55:01 +0100
Message-ID: <1299138901.2456.32.camel@edumazet-laptop>
References: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63346 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab1CCHzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 02:55:06 -0500
Received: by fxm17 with SMTP id 17so835713fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 23:55:04 -0800 (PST)
In-Reply-To: <1299136034-5549-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 15:07 +0800, Changli Gao a =C3=A9crit :
> When there is a ptype handler holding a clone of this skb, whose
> destination MAC addresse is overwritten, the owner of this handler ma=
y
> get a corrupted packet.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
> v2: fix the bug in the previous one. Thank him.
>  drivers/net/bonding/bond_main.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 912b416..7b7ca97 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1511,9 +1511,13 @@ static struct sk_buff *bond_handle_frame(struc=
t sk_buff *skb)
>  	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
>  	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
>  	    skb->pkt_type =3D=3D PACKET_HOST) {
> -		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
> =20
> -		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
> +		if (unlikely(skb_cow_head(skb,
> +					  skb->data - skb_mac_header(skb)))) {
> +			kfree_skb(skb);
> +			return NULL;
> +		}
> +		memcpy(eth_hdr(skb)->h_dest, bond_dev->dev_addr, ETH_ALEN);
>  	}
> =20
>  	return skb;



Thats minor, but using :

u16 *dest =3D eth_hdr(skb)->h_dest;

memcpy(dest, ptr, ETH_ALEN);

Is better because compiler knows both destination and source are at
least aligned on shorts.

On some arches, it helps to not using 6 bytes copy, but 3 shorts.



