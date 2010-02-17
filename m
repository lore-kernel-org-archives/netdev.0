From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH v2 3/3] fs_enet: add FEC TX buffer alignment
	workaround for MPC5121
Date: Wed, 17 Feb 2010 08:13:52 -0700
Message-ID: <fa686aa41002170713g1ece7377l73142f854807f3f@mail.gmail.com>
References: <1266418530-2727-1-git-send-email-agust@denx.de>
	<1266418530-2727-2-git-send-email-agust@denx.de> <1266418530-2727-3-git-send-email-agust@denx.de>
	<1266418530-2727-4-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"David S. Miller" <davem@davemloft.net>,
	Detlev Zundel <dzu@denx.de>, Wolfgang Denk <wd@denx.de>,
	John Rigby <jcrigby@gmail.com>,
	Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48855 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757346Ab0BQPOR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 10:14:17 -0500
Received: by vws8 with SMTP id 8so786939vws.19
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 07:14:13 -0800 (PST)
In-Reply-To: <1266418530-2727-4-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2010 at 7:55 AM, Anatolij Gustschin <agust@denx.de> wro=
te:
> MPC5121 FEC requeries 4-byte alignmnent for TX data buffers.
> This patch is a work around that copies misaligned tx packets
> to an aligned skb before sending.
>
> Signed-off-by: John Rigby <jcrigby@gmail.com>
> Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
> =A0drivers/net/fs_enet/fs_enet-main.c | =A0 44 ++++++++++++++++++++++=
++++++++++++++
> =A01 files changed, 44 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index 4297021..166a89d 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -580,6 +580,37 @@ void fs_cleanup_bds(struct net_device *dev)
>
> =A0/*****************************************************************=
*****************/
>
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> +/*
> + * MPC5121 FEC requeries 4-byte alignment for TX data buffer!
> + */
> +static struct sk_buff *tx_skb_align_workaround(struct net_device *de=
v,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 struct sk_buff *new_skb;
> + =A0 =A0 =A0 struct fs_enet_private *fep =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 /* Alloc new skb */
> + =A0 =A0 =A0 new_skb =3D dev_alloc_skb(ENET_RX_FRSIZE + 4);
> + =A0 =A0 =A0 if (!new_skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_warn(fep->dev, "Memory squeeze, dro=
pping tx packet.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Make sure new skb is properly aligned */
> + =A0 =A0 =A0 skb_align(new_skb, 4);
> +
> + =A0 =A0 =A0 /* Copy data to new skb ... */
> + =A0 =A0 =A0 skb_copy_from_linear_data(skb, new_skb->data, skb->len)=
;
> + =A0 =A0 =A0 skb_put(new_skb, skb->len);
> +
> + =A0 =A0 =A0 /* ... and free an old one */
> + =A0 =A0 =A0 dev_kfree_skb_any(skb);
> +
> + =A0 =A0 =A0 return new_skb;
> +}
> +#endif
> +
> =A0static int fs_enet_start_xmit(struct sk_buff *skb, struct net_devi=
ce *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> @@ -588,6 +619,19 @@ static int fs_enet_start_xmit(struct sk_buff *sk=
b, struct net_device *dev)
> =A0 =A0 =A0 =A0u16 sc;
> =A0 =A0 =A0 =A0unsigned long flags;
>
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 if (((unsigned long)skb->data) & 0x3) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D tx_skb_align_workaround(dev, sk=
b);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We have lost packe=
t due to memory allocation error
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in tx_skb_align_wo=
rkaround(). Hopefully original
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* skb is still valid=
, so try transmit it later.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NETDEV_TX_BUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +#endif

Instead of
> =A0 =A0 =A0 =A0spin_lock_irqsave(&fep->tx_lock, flags);
>
> =A0 =A0 =A0 =A0/*
> --
> 1.6.3.3
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
