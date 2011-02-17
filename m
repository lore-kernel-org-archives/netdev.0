From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC patch net-next-2.6] net: convert bonding to use rx_handler
Date: Thu, 17 Feb 2011 14:20:35 +0100
Message-ID: <1297948835.2604.50.camel@edumazet-laptop>
References: <20110217125221.GA10436@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59865 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975Ab1BQNUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 08:20:42 -0500
Received: by fxm20 with SMTP id 20so2580019fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 05:20:41 -0800 (PST)
In-Reply-To: <20110217125221.GA10436@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 f=C3=A9vrier 2011 =C3=A0 13:52 +0100, Jiri Pirko a =C3=A9cr=
it :
> Hello.
>=20
> This is an attempt to convert bonding to use rx_handler. Result shoul=
d be
> cleaner __netif_receive_skb() with much less exceptions needed. I thi=
nk I
> covered all aspects, not sure though. I gave this quick smoke test on=
 my
> testing env. Please comment, test.
>=20
> Thanks!
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |   75 ++++++++++++++++++++-
>  include/linux/skbuff.h          |    1 +
>  net/core/dev.c                  |  144 +++++++++++------------------=
---------
>  3 files changed, 117 insertions(+), 103 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c


> +
> +static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
> +{
> +	struct net_device *slave_dev;
> +	struct net_device *bond_dev;
> +
> +	skb =3D skb_share_check(skb, GFP_ATOMIC);
> +	if (unlikely(!skb))
> +		return NULL;
> +	slave_dev =3D skb->dev;
> +	bond_dev =3D slave_dev->master;

I suggest being 10%% safe here :

	bond_dev =3D ACCESS_ONCE(slave_dev->master);

> +	if (unlikely(!bond_dev))
> +		return skb;
> +
> +	if (bond_dev->priv_flags & IFF_MASTER_ARPMON)
> +		slave_dev->last_rx =3D jiffies;
> +
> +	if (bond_should_deliver_exact_match(skb, slave_dev, bond_dev)) {
> +		skb->deliver_no_wcard =3D 1;
> +		return skb;
> +	}
> +
> +	skb->dev =3D bond_dev;
> +
> +	if (bond_dev->priv_flags & IFF_MASTER_ALB &&
> +	    bond_dev->priv_flags & IFF_BRIDGE_PORT &&
> +	    skb->pkt_type =3D=3D PACKET_HOST) {
> +		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
> +
> +		memcpy(dest, bond_dev->dev_addr, ETH_ALEN);
> +	}
> +
> +	netif_rx(skb);
> +	return NULL;
> +}
> +


> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 31f02d0..15b54ea 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -325,6 +325,7 @@ struct sk_buff {
> =20
>  	struct sock		*sk;
>  	struct net_device	*dev;
> +	struct net_device	*orig_dev;
> =20
>  	/*
>  	 * This is the control buffer. It is free to use for every

Thats a problem. lifetime of this field is so small, I wonder if you
cant find a solution to handle this differently. Maybe a percpu
variable, or in cb[] ?



