From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 8/8] stmmac: limit max_mtu in case of 4KiB and use
 __netdev_alloc_skb.
Date: Tue, 18 Oct 2011 12:18:30 +0200
Message-ID: <1318933110.2657.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318932085-14927-1-git-send-email-peppe.cavallaro@st.com>
	 <1318932085-14927-9-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42569 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab1JRKSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 06:18:10 -0400
Received: by gyb13 with SMTP id 13so398759gyb.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 03:18:10 -0700 (PDT)
In-Reply-To: <1318932085-14927-9-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 12:01 +0200, Giuseppe CAVALLARO a =C3=A9=
crit :
> Problem using big mtu around 4096 bytes is you end allocating (4096
> +NET_SKB_PAD + NET_IP_ALIGN + sizeof(struct skb_shared_info) bytes ->
> 8192 bytes : order-1 pages
>=20
> It's better to limit the mtu to SKB_MAX_HEAD(NET_SKB_PAD),
> to have no more than one page per skb.
>=20
> Also the patch changes the netdev_alloc_skb_ip_align() done in
> init_dma_desc_rings() and uses a variant allowing GFP_KERNEL allocati=
ons
> allowing the driver to load even in case of memory pressure.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 +++++++++--=
--
>  1 files changed, 9 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driv=
ers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 1848a16..f5ca3be 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -474,11 +474,13 @@ static void init_dma_desc_rings(struct net_devi=
ce *dev)
>  	for (i =3D 0; i < rxsize; i++) {
>  		struct dma_desc *p =3D priv->dma_rx + i;
> =20
> -		skb =3D netdev_alloc_skb_ip_align(dev, bfsize);
> +		skb =3D __netdev_alloc_skb(dev, bfsize + NET_IP_ALIGN,
> +					 GFP_KERNEL);
>  		if (unlikely(skb =3D=3D NULL)) {
>  			pr_err("%s: Rx init fails; skb is NULL\n", __func__);
>  			break;
>  		}
> +		skb_reserve(skb, NET_IP_ALIGN);
>  		priv->rx_skbuff[i] =3D skb;
>  		priv->rx_skbuff_dma[i] =3D dma_map_single(priv->device, skb->data,
>  						bfsize, DMA_FROM_DEVICE);
> @@ -1176,12 +1178,15 @@ static inline void stmmac_rx_refill(struct st=
mmac_priv *priv)
> =20
>  			skb =3D __skb_dequeue(&priv->rx_recycle);
>  			if (skb =3D=3D NULL)
> -				skb =3D netdev_alloc_skb_ip_align(priv->dev,
> -								bfsize);
> +				skb =3D __netdev_alloc_skb(priv->dev, bfsize +
> +							 NET_IP_ALIGN,
> +							 GFP_KERNEL);
> =20

No, you cant do that in softirq context. We cant sleep here and must us=
e
GFP_ATOMIC

Only the init_dma_desc_rings() part is OK, we run in process context an=
d
are allowed to sleep in memory allocations (GFP_KERNEL)


>  			if (unlikely(skb =3D=3D NULL))
>  				break;
> =20
> +			skb_reserve(skb, NET_IP_ALIGN);
> +
>  			priv->rx_skbuff[entry] =3D skb;
>  			priv->rx_skbuff_dma[entry] =3D
>  			    dma_map_single(priv->device, skb->data, bfsize,
> @@ -1401,7 +1406,7 @@ static int stmmac_change_mtu(struct net_device =
*dev, int new_mtu)
>  	if (priv->plat->enh_desc)
>  		max_mtu =3D JUMBO_LEN;
>  	else
> -		max_mtu =3D BUF_SIZE_4KiB;
> +		max_mtu =3D SKB_MAX_HEAD(NET_SKB_PAD);
> =20

minor nit (since NET_IP_ALIGN is 0 anyway on modern x86)
max_mtu =3D SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);


>  	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
>  		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
