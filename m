From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][v2] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 21:02:12 +0100
Message-ID: <1300132932.2649.2.camel@edumazet-laptop>
References: <1300129859-9525-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40850 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756730Ab1CNUCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:02:25 -0400
Received: by fxm17 with SMTP id 17so3301203fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 13:02:24 -0700 (PDT)
In-Reply-To: <1300129859-9525-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 20:10 +0100, Daniel Lezcano a =C3=A9crit :
> In case the device where is coming from the packet has TSO enabled,
> we should not check the mtu size value as this one could be bigger
> than the expected value.
>=20
> This is the case for the macvlan driver when the lower device has
> TSO enabled. The macvlan inherit this feature and forward the packets
> without fragmenting them. Then the packets go through dev_forward_skb
> and are dropped. This patch fix this by checking TSO is not enabled
> when we want to check the mtu size.
>=20
> Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Andrian Nord <nightnord@gmail.com>
> ---
>  net/core/dev.c |   24 ++++++++++++++++++++++--
>  1 files changed, 22 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6561021..f1607a0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1503,6 +1503,27 @@ static inline void net_timestamp_check(struct =
sk_buff *skb)
>  		__net_timestamp(skb);
>  }
> =20
> +static inline bool is_skb_forwardable(struct net_device *dev,
> +				      struct sk_buff *skb)
> +{
> +	unsigned int len;
> +
> +	if (!dev->flags & IFF_UP)
> +		return false;

	if (!(dev->flags & IFF_UP))
		return false;

> +
> +	/* we should not check the mtu size if TSO is enabled otherwise
> +	 * we may have a packet with a length bigger than the expected
> +	 * one as it was not segmented before */
> +	if (skb->dev && skb->dev->features & NETIF_F_TSO)
> +		return true;
> +
> +	len =3D dev->mtu + dev->hard_header_len + VLAN_HLEN;
> +	if (skb->len > len)
> +		return false;
> +


I suggest you reorder tests so that the first one is discriminant most
of the time

	maxlen =3D dev->mtu + dev->hard_header_len + VLAN_HLEN;
	if (skb->len < maxlen)
		return true;
=09
	if (skb->dev && skb->dev->features & NETIF_F_TSO)
		return true;

	return false;

> +	return true;
> +}
> +
>  /**
>   * dev_forward_skb - loopback an skb to another netif
>   *
> @@ -1526,8 +1547,7 @@ int dev_forward_skb(struct net_device *dev, str=
uct sk_buff *skb)
>  	skb_orphan(skb);
>  	nf_reset(skb);
> =20
> -	if (unlikely(!(dev->flags & IFF_UP) ||
> -		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) =
{
> +	if (unlikely(!is_skb_forwardable(dev, skb))) {
>  		atomic_long_inc(&dev->rx_dropped);
>  		kfree_skb(skb);
>  		return NET_RX_DROP;


