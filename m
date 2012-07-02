From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [PATCH] net: dont use __netdev_alloc_skb for bounce buffer
Date: Mon, 02 Jul 2012 22:03:42 +0200
Message-ID: <4FF1FE9E.7020709@canonical.com>
References: <1341254172.22621.456.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig6E0782C97CE4BE5D75CD41AE"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48190 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236Ab2GBUDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 16:03:49 -0400
In-Reply-To: <1341254172.22621.456.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6E0782C97CE4BE5D75CD41AE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I can confirm that, with the below patch applied, at least the b44 regres=
sion is
fixed and network is usable again.

-Stefan

On 02.07.2012 20:36, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> commit a1c7fff7e1 (net: netdev_alloc_skb() use build_skb()) broke b44 o=
n
> some 64bit machines.
>=20
> It appears b44 and b43 use __netdev_alloc_skb() instead of alloc_skb()
> for their bounce buffers.
>=20
> There is no need to add an extra NET_SKB_PAD reservation for bounce
> buffers :
>=20
> - In TX path, NET_SKB_PAD is useless
>=20
> - In RX path in b44, we force a copy of incoming frames if
>   GFP_DMA allocations were needed.
>=20
> Reported-and-bisected-by: Stefan Bader <stefan.bader@canonical.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/broadcom/b44.c  |    4 ++--
>  drivers/net/wireless/b43legacy/dma.c |    2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet=
/broadcom/b44.c
> index 46b8b7d..d09c6b5 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -656,7 +656,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src=
_idx, u32 dest_idx_unmasked)
>  			dma_unmap_single(bp->sdev->dma_dev, mapping,
>  					     RX_PKT_BUF_SZ, DMA_FROM_DEVICE);
>  		dev_kfree_skb_any(skb);
> -		skb =3D __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DM=
A);
> +		skb =3D alloc_skb(RX_PKT_BUF_SZ, GFP_ATOMIC | GFP_DMA);
>  		if (skb =3D=3D NULL)
>  			return -ENOMEM;
>  		mapping =3D dma_map_single(bp->sdev->dma_dev, skb->data,
> @@ -967,7 +967,7 @@ static netdev_tx_t b44_start_xmit(struct sk_buff *s=
kb, struct net_device *dev)
>  			dma_unmap_single(bp->sdev->dma_dev, mapping, len,
>  					     DMA_TO_DEVICE);
> =20
> -		bounce_skb =3D __netdev_alloc_skb(dev, len, GFP_ATOMIC | GFP_DMA);
> +		bounce_skb =3D alloc_skb(len, GFP_ATOMIC | GFP_DMA);
>  		if (!bounce_skb)
>  			goto err_out;
> =20
> diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireles=
s/b43legacy/dma.c
> index f1f8bd0..c8baf02 100644
> --- a/drivers/net/wireless/b43legacy/dma.c
> +++ b/drivers/net/wireless/b43legacy/dma.c
> @@ -1072,7 +1072,7 @@ static int dma_tx_fragment(struct b43legacy_dmari=
ng *ring,
>  	meta->dmaaddr =3D map_descbuffer(ring, skb->data, skb->len, 1);
>  	/* create a bounce buffer in zone_dma on mapping failure. */
>  	if (b43legacy_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
> -		bounce_skb =3D __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
> +		bounce_skb =3D alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
>  		if (!bounce_skb) {
>  			ring->current_slot =3D old_top_slot;
>  			ring->used_slots =3D old_used_slots;
>=20
>=20




--------------enig6E0782C97CE4BE5D75CD41AE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP8f6eAAoJEOhnXe7L7s6j2k8QAMvZvl6OCyz6daHpXsuYv295
U/IkfabjQbjc37ScLidGcOJwadYpCeiEB3SeSDaHJt/yZWplkai0rN5l4ZIHq1MZ
kKuN23njbPtol6BcaBzOYLIl4VRjC1OIUxVwE7xw6Kkoc/PV1Hzcf6VoOIejhsxz
Smcw8eFZwTX8dQbbwrnbxVgZJSqtljQotrluHcDDyJBbGIis3C1Ni/WN9hwX3nHt
Ne15fUo2j/x4Ljj/BGGr+yhSxc0YMpVPstdl5ay0JxIzIXd/5kaZUnM+GYQl01C4
lQ1SWhjsjVqawhrGqwkI8GecrbHruhIGwK2OjcfDooNXIyZPv2XiHfQkzwQU6/Lz
HP4Jh+/A+h0uvd/bMUb5r80vuvy1LyaK+m8cv1HsI0fxl+rn1cdOjLf4oqVkSw8v
ogBjb+ejCu+quQYv2CUeFAx8zIYNWw6lUzDtTb+oh2mVcfuM+V68MaCJrkmUnjuy
D9eIgJ2Pe5Q1H0LNE26YQ/fHkFXu5C1439BTtRCOxXZh89dXJVJga86Il8CGCmEV
UVpjnOpjWHA/9D4rDu/UYiqEt0kT/59XOPk2mF+pZTLWIPmtmpjSXeE+KHrwXtfu
WAB/zXdcLh9camAfpqmkJOV0EnuwrJ0FDJZ7VZRKsuxYj3bnrw1BiA2YEG4KQSqw
7Bc9P0mil+sZL66EsWQx
=oGy7
-----END PGP SIGNATURE-----

--------------enig6E0782C97CE4BE5D75CD41AE--
