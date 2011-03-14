From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 18:01:45 +0100
Message-ID: <1300122105.3423.131.camel@edumazet-laptop>
References: <1300118888-2311-1-git-send-email-daniel.lezcano@free.fr>
	 <1300118888-2311-2-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37551 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab1CNRBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 13:01:51 -0400
Received: by fxm17 with SMTP id 17so3109023fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 10:01:50 -0700 (PDT)
In-Reply-To: <1300118888-2311-2-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 17:08 +0100, Daniel Lezcano a =C3=A9crit :
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
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Andrian Nord <nightnord@gmail.com>
> ---
>  net/core/dev.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6561021..010a0a9 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1526,8 +1526,10 @@ int dev_forward_skb(struct net_device *dev, st=
ruct sk_buff *skb)
>  	skb_orphan(skb);
>  	nf_reset(skb);
> =20
> -	if (unlikely(!(dev->flags & IFF_UP) ||
> -		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) =
{
> +	if (unlikely(!(skb->dev->features & NETIF_F_TSO) &&


Sorry, this needs a comment at least, or even better a helper function
on its own.

We test both skb->dev & dev, pointing to different devices, this is
really error prone.

Are we sure all callers set skb->dev before calling  dev_forward_skb() =
?


> +		     (!(dev->flags & IFF_UP) ||
> +		      (skb->len > (dev->mtu +
> +				   dev->hard_header_len + VLAN_HLEN))))) {
>  		atomic_long_inc(&dev->rx_dropped);
>  		kfree_skb(skb);
>  		return NET_RX_DROP;


