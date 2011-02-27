From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 V3] net: convert bonding to use rx_handler
Date: Sun, 27 Feb 2011 15:17:01 +0100
Message-ID: <4D6A5CDD.4020009@gmail.com>
References: <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net> <20110218145850.GF2939@psychotron.redhat.com> <20110218.120656.104048936.davem@davemloft.net> <20110218205832.GE2602@psychotron.redhat.com> <20110223190541.GB2783@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36641 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845Ab1B0ORG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 09:17:06 -0500
Received: by fxm17 with SMTP id 17so3011739fxm.19
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 06:17:04 -0800 (PST)
In-Reply-To: <20110223190541.GB2783@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/02/2011 20:05, Jiri Pirko a =E9crit :
> This patch converts bonding to use rx_handler. Results in cleaner
> __netif_receive_skb() with much less exceptions needed. Also
> bond-specific work is moved into bond code.
>
> Did performance test using pktgen and counting incoming packets by
> iptables. No regression noted.
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>
> v1->v2:
>          using skb_iif instead of new input_dev to remember original
> 	device
>
> v2->v3:
> 	do another loop in case skb->dev is changed. That way orig_dev
> 	core can be left untouched.
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
> ---

[snip]

> +static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
> +{
> +	struct net_device *slave_dev;
> +	struct net_device *bond_dev;
> +
> +	skb =3D skb_share_check(skb, GFP_ATOMIC);
> +	if (unlikely(!skb))
> +		return NULL;
> +	slave_dev =3D skb->dev;
> +	bond_dev =3D ACCESS_ONCE(slave_dev->master);
> +	if (unlikely(!bond_dev))
> +		return skb;
> +
> +	if (bond_dev->priv_flags&  IFF_MASTER_ARPMON)
> +		slave_dev->last_rx =3D jiffies;
> +
> +	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
> +		skb->deliver_no_wcard =3D 1;
> +		return skb;

Shouldn't we return NULL here ?

> +	}
> +
> +	skb->dev =3D bond_dev;
> +
> +	if (bond_dev->priv_flags&  IFF_MASTER_ALB&&
> +	    bond_dev->priv_flags&  IFF_BRIDGE_PORT&&
> +	    skb->pkt_type =3D=3D PACKET_HOST) {
> +		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
> +
> +		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
> +	}
> +
> +	return skb;
> +}
> +

[snip]

> +static void vlan_on_bond_hook(struct sk_buff *skb)
>   {
> -	if (skb->pkt_type =3D=3D PACKET_HOST) {
> -		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
> +	/*
> +	 * Make sure ARP frames received on VLAN interfaces stacked on
> +	 * bonding interfaces still make their way to any base bonding
> +	 * device that may have registered for a specific ptype.
> +	 */
> +	if (skb->dev->priv_flags&  IFF_802_1Q_VLAN&&
> +	    vlan_dev_real_dev(skb->dev)->priv_flags&  IFF_BONDING&&
> +	    skb->protocol =3D=3D htons(ETH_P_ARP)) {

The vlan_on_bond case used to be cost effective. Now, we clone the skb =
and call netif_rx...

> +		struct sk_buff *skb2 =3D skb_clone(skb, GFP_ATOMIC);
>
> -		memcpy(dest, master->dev_addr, ETH_ALEN);
> +		if (!skb2)
> +			return;
> +		skb2->dev =3D vlan_dev_real_dev(skb->dev);
> +		netif_rx(skb2);
>   	}
>   }

[snip]

>   	if (rx_handler) {
> +		struct net_device *prev_dev;
> +
>   		if (pt_prev) {
>   			ret =3D deliver_skb(skb, pt_prev, orig_dev);
>   			pt_prev =3D NULL;
>   		}
> +		prev_dev =3D skb->dev;
>   		skb =3D rx_handler(skb);
>   		if (!skb)
>   			goto out;

I would instead consider NULL as meaning exact-match-delivery-only. (Th=
e same effect as=20
dev_bond_should_drop() returning true).

> +		if (skb->dev !=3D prev_dev)
> +			goto another_round;
>   	}

Anyway, all my comments can't be postponed to follow-up patchs. Thanks =
Jiri.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
