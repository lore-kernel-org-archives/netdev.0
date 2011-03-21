From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Mon, 21 Mar 2011 22:42:24 +0100
Message-ID: <1300743744.2837.7.camel@edumazet-laptop>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56915 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab1CUVma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 17:42:30 -0400
Received: by fxm17 with SMTP id 17so5894559fxm.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 14:42:28 -0700 (PDT)
In-Reply-To: <m1wrjsi2tf.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 14:25 -0700, Eric W. Biederman a =C3=A9cri=
t :
> Today when gso packets reach dev_forward_skb through the macvlan driv=
er
> we drop them on the floor because they exceed the device mtu.  Ouch!
>=20
> I don't undersand the subtelties of gso but I think it is sufficient =
to
> simply relax the checks and let gso packets through without an mtu
> check, and it works in my test case.
>=20
> If needed we can split the gso packets into multiple packets here but
> that just seems like a wast of memory and time.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
>  net/core/dev.c |   16 ++++++++++------
>  1 files changed, 10 insertions(+), 6 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0b88eba..2e26606 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1527,17 +1527,21 @@ int dev_forward_skb(struct net_device *dev, s=
truct sk_buff *skb)
>  	skb_orphan(skb);
>  	nf_reset(skb);
> =20
> -	if (unlikely(!(dev->flags & IFF_UP) ||
> -		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) =
{
> -		atomic_long_inc(&dev->rx_dropped);
> -		kfree_skb(skb);
> -		return NET_RX_DROP;
> -	}
> +	if (unlikely(!(dev->flags & IFF_UP)))
> +		goto kfree_skb;
> +	/* Don't check mtu on gso packets... */
> +	if (unlikely(!skb_is_gso(skb) &&
> +		     (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN))))
> +		goto kfree_skb;
>  	skb_set_dev(skb, dev);
>  	skb->tstamp.tv64 =3D 0;
>  	skb->pkt_type =3D PACKET_HOST;
>  	skb->protocol =3D eth_type_trans(skb, dev);
>  	return netif_rx(skb);
> +kfree_skb:
> +	atomic_long_inc(&dev->rx_dropped);
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
>  }
>  EXPORT_SYMBOL_GPL(dev_forward_skb);
> =20


Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
discussion ?



