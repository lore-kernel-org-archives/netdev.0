From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 13/14] mlx4_en: Moving to work with GRO
Date: Sat, 28 Aug 2010 12:56:14 +0200
Message-ID: <1282992974.2277.17.camel@edumazet-laptop>
References: <4C73CD46.10907@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eugenia@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44102 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab0H1K4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 06:56:20 -0400
Received: by wwb28 with SMTP id 28so4758916wwb.1
        for <netdev@vger.kernel.org>; Sat, 28 Aug 2010 03:56:18 -0700 (PDT)
In-Reply-To: <4C73CD46.10907@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 16:46 +0300, Yevgeny Petrilin a =C3=A9=
crit :
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/en_ethtool.c |   58 +------------------------------=
---
>  drivers/net/mlx4/en_main.c    |    5 ---
>  drivers/net/mlx4/en_netdev.c  |    3 +-
>  drivers/net/mlx4/en_rx.c      |   68 ++++++++-----------------------=
----------
>  drivers/net/mlx4/en_tx.c      |    1 +
>  drivers/net/mlx4/mlx4_en.h    |    6 ---
>  6 files changed, 17 insertions(+), 124 deletions(-)
>=20



>  err_hwq:
>  	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
>  err_ring:
> @@ -412,7 +380,6 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv =
*priv,
>  {
>  	struct mlx4_en_dev *mdev =3D priv->mdev;
> =20
> -	kfree(ring->lro.lro_arr);
>  	mlx4_en_unmap_buffer(&ring->wqres.buf);
>  	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size + TXBB_SI=
ZE);
>  	vfree(ring->rx_info);
> @@ -563,7 +530,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev,=
 struct mlx4_en_cq *cq, int bud
>  	struct mlx4_cqe *cqe;
>  	struct mlx4_en_rx_ring *ring =3D &priv->rx_ring[cq->ring];
>  	struct skb_frag_struct *skb_frags;
> -	struct skb_frag_struct lro_frags[MLX4_EN_MAX_RX_FRAGS];
>  	struct mlx4_en_rx_desc *rx_desc;
>  	struct sk_buff *skb;
>  	int index;
> @@ -623,37 +589,33 @@ int mlx4_en_process_rx_cq(struct net_device *de=
v, struct mlx4_en_cq *cq, int bud
>  				 * - TCP/IP (v4)
>  				 * - without IP options
>  				 * - not an IP fragment */
> -				if (mlx4_en_can_lro(cqe->status) &&
> -				    dev->features & NETIF_F_LRO) {
> +				if (dev->features & NETIF_F_GRO) {
> +					struct sk_buff *gro_skb =3D napi_get_frags(&cq->napi);
> =20

napi_get_frags() can return NULL, please fix your driver.

>  					nr =3D mlx4_en_complete_rx_desc(
>  						priv, rx_desc,
> -						skb_frags, lro_frags,
> +						skb_frags, skb_shinfo(gro_skb)->frags,
>  						ring->page_alloc, length);
>  					if (!nr)
>  						goto next;
> =20


Thanks


