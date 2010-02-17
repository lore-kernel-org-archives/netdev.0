From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] fs_enet: add FEC TX buffer
 alignment workaround for MPC5121
Date: Wed, 17 Feb 2010 16:17:16 +0100
Message-ID: <1266419836.3075.12.camel@edumazet-laptop>
References: <1266418530-2727-1-git-send-email-agust@denx.de>
	 <1266418530-2727-2-git-send-email-agust@denx.de>
	 <1266418530-2727-3-git-send-email-agust@denx.de>
	 <1266418530-2727-4-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Detlev Zundel <dzu@denx.de>, Wolfgang Denk <wd@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36418 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757346Ab0BQPRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 10:17:23 -0500
Received: by bwz19 with SMTP id 19so5608901bwz.28
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 07:17:20 -0800 (PST)
In-Reply-To: <1266418530-2727-4-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 f=C3=A9vrier 2010 =C3=A0 15:55 +0100, Anatolij Gustschin=
 a =C3=A9crit :
> MPC5121 FEC requeries 4-byte alignmnent for TX data buffers.
> This patch is a work around that copies misaligned tx packets
> to an aligned skb before sending.
>=20
> Signed-off-by: John Rigby <jcrigby@gmail.com>
> Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |   44 ++++++++++++++++++++++++++=
++++++++++
>  1 files changed, 44 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index 4297021..166a89d 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -580,6 +580,37 @@ void fs_cleanup_bds(struct net_device *dev)
> =20
>  /*******************************************************************=
***************/
> =20
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> +/*
> + * MPC5121 FEC requeries 4-byte alignment for TX data buffer!
> + */
> +static struct sk_buff *tx_skb_align_workaround(struct net_device *de=
v,
> +					       struct sk_buff *skb)
> +{
> +	struct sk_buff *new_skb;
> +	struct fs_enet_private *fep =3D netdev_priv(dev);
> +
> +	/* Alloc new skb */
> +	new_skb =3D dev_alloc_skb(ENET_RX_FRSIZE + 4);


ENET_RX_FRSIZE looks strange in TX path

Why not using skb->len + 4 instead of ENET_RX_FRSIZE + 4 ?


> +	if (!new_skb) {
> +		dev_warn(fep->dev, "Memory squeeze, dropping tx packet.\n");

I am just wondering if this is ratelimited ?

> +		return NULL;
> +	}
> +
> +	/* Make sure new skb is properly aligned */
> +	skb_align(new_skb, 4);

> +
> +	/* Copy data to new skb ... */
> +	skb_copy_from_linear_data(skb, new_skb->data, skb->len);
> +	skb_put(new_skb, skb->len);
> +
> +	/* ... and free an old one */
> +	dev_kfree_skb_any(skb);
> +
> +	return new_skb;
> +}
> +#endif
> +
>  static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device=
 *dev)
>  {
>  	struct fs_enet_private *fep =3D netdev_priv(dev);
> @@ -588,6 +619,19 @@ static int fs_enet_start_xmit(struct sk_buff *sk=
b, struct net_device *dev)
>  	u16 sc;
>  	unsigned long flags;
> =20
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> +	if (((unsigned long)skb->data) & 0x3) {
> +		skb =3D tx_skb_align_workaround(dev, skb);
> +		if (!skb) {
> +			/*
> +			 * We have lost packet due to memory allocation error
> +			 * in tx_skb_align_workaround(). Hopefully original
> +			 * skb is still valid, so try transmit it later.
> +			 */

Could you define 'try to transmit later' ?
Who is responsible to trigger this event ?


> +			return NETDEV_TX_BUSY;
> +		}
> +	}
> +#endif
>  	spin_lock_irqsave(&fep->tx_lock, flags);
> =20
>  	/*


