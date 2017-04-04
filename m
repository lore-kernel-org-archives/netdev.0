From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 1/4] net: stmmac: break some functions into RX and TX
 scopes
Date: Tue, 4 Apr 2017 20:57:35 +0200
Message-ID: <20170404185735.GA24271@ulmo.ba.sec>
References: <cover.1491327063.git.jpinto@synopsys.com>
 <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:8815 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754991AbdDDS5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 14:57:42 -0400
In-Reply-To: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 04, 2017 at 06:54:24PM +0100, Joao Pinto wrote:
> This patch breaks several functions into RX and TX scopes, which
> will be useful when adding multiple buffers mechanism.
>=20
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 350 ++++++++++++++++=
+-----
>  1 file changed, 268 insertions(+), 82 deletions(-)

A couple of small nits below.

> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/=
net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
> @@ -924,16 +941,16 @@ static int stmmac_set_bfsize(int mtu, int bufsize)
>  }
> =20
>  /**
> - * stmmac_clear_descriptors - clear descriptors
> + * stmmac_clear_rx_descriptors - clear RX descriptors
>   * @priv: driver private structure
> - * Description: this function is called to clear the tx and rx descripto=
rs
> + * Description: this function is called to clear the rx descriptors

You seem to be transitioning to "RX" and "TX" everywhere, maybe do the
same in this comment for consistency?

Also, on a general note: there's no need for "Description:" here. The
kerneldoc format mandates that you leave a blank line after the block
of parameter descriptions, and the paragraph that follows becomes the
description. I know that these are static functions and are therefore
not parsed by kerneldoc, but since you already use the syntax anyway,
you might as well get it right.

>   * in case of both basic and extended descriptors are used.
>   */
> -static void stmmac_clear_descriptors(struct stmmac_priv *priv)
> +static void stmmac_clear_rx_descriptors(struct stmmac_priv *priv)
>  {
>  	int i;

This could be unsigned.

> =20
> -	/* Clear the Rx/Tx descriptors */
> +	/* Clear the RX descriptors */
>  	for (i =3D 0; i < DMA_RX_SIZE; i++)
>  		if (priv->extend_desc)
>  			priv->hw->desc->init_rx_desc(&priv->dma_erx[i].basic,
> @@ -943,6 +960,19 @@ static void stmmac_clear_descriptors(struct stmmac_p=
riv *priv)
>  			priv->hw->desc->init_rx_desc(&priv->dma_rx[i],
>  						     priv->use_riwt, priv->mode,
>  						     (i =3D=3D DMA_RX_SIZE - 1));
> +}
> +
> +/**
> + * stmmac_clear_tx_descriptors - clear tx descriptors
> + * @priv: driver private structure
> + * Description: this function is called to clear the tx descriptors
> + * in case of both basic and extended descriptors are used.
> + */
> +static void stmmac_clear_tx_descriptors(struct stmmac_priv *priv)
> +{
> +	int i;

Same here. There are a couple of other such occurrences throughout the
file. This already exists in many places in the driver, so I don't think
this needs to be changed. Or at least it could be a follow-up patch.

> +
> +	/* Clear the TX descriptors */
>  	for (i =3D 0; i < DMA_TX_SIZE; i++)
>  		if (priv->extend_desc)
>  			priv->hw->desc->init_tx_desc(&priv->dma_etx[i].basic,
> @@ -955,6 +985,21 @@ static void stmmac_clear_descriptors(struct stmmac_p=
riv *priv)
>  }
> =20
>  /**
> + * stmmac_clear_descriptors - clear descriptors
> + * @priv: driver private structure
> + * Description: this function is called to clear the tx and rx descripto=
rs
> + * in case of both basic and extended descriptors are used.
> + */
> +static void stmmac_clear_descriptors(struct stmmac_priv *priv)
> +{
> +	/* Clear the RX descriptors */
> +	stmmac_clear_rx_descriptors(priv);
> +
> +	/* Clear the TX descriptors */
> +	stmmac_clear_tx_descriptors(priv);
> +}
> +
> +/**
>   * stmmac_init_rx_buffers - init the RX descriptor buffer.
>   * @priv: driver private structure
>   * @p: descriptor pointer
> @@ -996,6 +1041,11 @@ static int stmmac_init_rx_buffers(struct stmmac_pri=
v *priv, struct dma_desc *p,
>  	return 0;
>  }
> =20
> +/**
> + * stmmac_free_rx_buffers - free RX dma buffers
> + * @priv: private structure
> + * @i: buffer index.

If this operates on a single buffer, as specified by the buffer index,
maybe this should be named singular stmmac_free_rx_buffer()?

> + */
>  static void stmmac_free_rx_buffers(struct stmmac_priv *priv, int i)

The index could be unsigned.

>  {
>  	if (priv->rx_skbuff[i]) {
> @@ -1007,14 +1057,42 @@ static void stmmac_free_rx_buffers(struct stmmac_=
priv *priv, int i)
>  }
> =20
>  /**
> - * init_dma_desc_rings - init the RX/TX descriptor rings
> + * stmmac_free_tx_buffers - free RX dma buffers
> + * @priv: private structure
> + * @i: buffer index.
> + */
> +static void stmmac_free_tx_buffers(struct stmmac_priv *priv, int i)
> +{
> +	if (priv->tx_skbuff_dma[i].buf) {
> +		if (priv->tx_skbuff_dma[i].map_as_page)
> +			dma_unmap_page(priv->device,
> +				       priv->tx_skbuff_dma[i].buf,
> +				       priv->tx_skbuff_dma[i].len,
> +				       DMA_TO_DEVICE);
> +		else
> +			dma_unmap_single(priv->device,
> +					 priv->tx_skbuff_dma[i].buf,
> +					 priv->tx_skbuff_dma[i].len,
> +					 DMA_TO_DEVICE);
> +	}
> +
> +	if (priv->tx_skbuff[i]) {
> +		dev_kfree_skb_any(priv->tx_skbuff[i]);
> +		priv->tx_skbuff[i] =3D NULL;
> +		priv->tx_skbuff_dma[i].buf =3D 0;
> +		priv->tx_skbuff_dma[i].map_as_page =3D false;
> +	}
> +}
> +
> +/**
> + * init_dma_rx_desc_rings - init the RX descriptor rings
>   * @dev: net device structure
>   * @flags: gfp flag.
> - * Description: this function initializes the DMA RX/TX descriptors
> + * Description: this function initializes the DMA RX descriptors
>   * and allocates the socket buffers. It supports the chained and ring
>   * modes.
>   */
> -static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
> +static int init_dma_rx_desc_rings(struct net_device *dev, gfp_t flags)
>  {
>  	int i;
>  	struct stmmac_priv *priv =3D netdev_priv(dev);
> @@ -1030,8 +1108,7 @@ static int init_dma_desc_rings(struct net_device *d=
ev, gfp_t flags)
>  	priv->dma_buf_sz =3D bfsize;
> =20
>  	netif_dbg(priv, probe, priv->dev,
> -		  "(%s) dma_rx_phy=3D0x%08x dma_tx_phy=3D0x%08x\n",
> -		  __func__, (u32)priv->dma_rx_phy, (u32)priv->dma_tx_phy);
> +		  "(%s) dma_rx_phy=3D0x%08x\n", __func__, (u32)priv->dma_rx_phy);
> =20
>  	/* RX INITIALIZATION */
>  	netif_dbg(priv, probe, priv->dev,
> @@ -1058,17 +1135,44 @@ static int init_dma_desc_rings(struct net_device =
*dev, gfp_t flags)
> =20
>  	/* Setup the chained descriptor addresses */
>  	if (priv->mode =3D=3D STMMAC_CHAIN_MODE) {
> -		if (priv->extend_desc) {
> +		if (priv->extend_desc)
>  			priv->hw->mode->init(priv->dma_erx, priv->dma_rx_phy,
>  					     DMA_RX_SIZE, 1);
> -			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
> -					     DMA_TX_SIZE, 1);
> -		} else {
> +		else
>  			priv->hw->mode->init(priv->dma_rx, priv->dma_rx_phy,
>  					     DMA_RX_SIZE, 0);
> +	}
> +
> +	return 0;
> +err_init_rx_buffers:
> +	while (--i >=3D 0)
> +		stmmac_free_rx_buffers(priv, i);
> +	return ret;
> +}
> +
> +/**
> + * init_dma_tx_desc_rings - init the TX descriptor rings
> + * @dev: net device structure.
> + * Description: this function initializes the DMA TX descriptors
> + * and allocates the socket buffers. It supports the chained and ring
> + * modes.
> + */
> +static int init_dma_tx_desc_rings(struct net_device *dev)
> +{
> +	struct stmmac_priv *priv =3D netdev_priv(dev);
> +	int i;
> +
> +	netif_dbg(priv, probe, priv->dev,
> +		  "(%s) dma_tx_phy=3D0x%08x\n", __func__, (u32)priv->dma_rx_phy);
> +
> +	/* Setup the chained descriptor addresses */
> +	if (priv->mode =3D=3D STMMAC_CHAIN_MODE) {
> +		if (priv->extend_desc)
> +			priv->hw->mode->init(priv->dma_etx, priv->dma_tx_phy,
> +					     DMA_TX_SIZE, 1);
> +		else
>  			priv->hw->mode->init(priv->dma_tx, priv->dma_tx_phy,
>  					     DMA_TX_SIZE, 0);
> -		}
>  	}
> =20
>  	/* TX INITIALIZATION */
> @@ -1099,18 +1203,42 @@ static int init_dma_desc_rings(struct net_device =
*dev, gfp_t flags)
>  	priv->cur_tx =3D 0;
>  	netdev_reset_queue(priv->dev);
> =20
> +	return 0;
> +}
> +
> +/**
> + * init_dma_desc_rings - init the RX/TX descriptor rings
> + * @dev: net device structure
> + * @flags: gfp flag.
> + * Description: this function initializes the DMA RX/TX descriptors
> + * and allocates the socket buffers. It supports the chained and ring
> + * modes.
> + */
> +static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
> +{
> +	struct stmmac_priv *priv =3D netdev_priv(dev);
> +	int ret;
> +
> +	/* RX INITIALIZATION */
> +	ret =3D init_dma_rx_desc_rings(dev, flags);

That comment already exists in init_dma_rx_desc_rings(). And even there
it doesn't provide any useful information, so might as well drop it.

> +	if (ret)
> +		return ret;
> +
> +	/* TX INITIALIZATION */
> +	ret =3D init_dma_tx_desc_rings(dev);

Same here.

[...]
> -static void free_dma_desc_resources(struct stmmac_priv *priv)
> +/**
> + * alloc_dma_desc_resources - alloc TX/RX resources.
> + * @priv: private structure
> + * Description: according to which descriptor can be used (extend or bas=
ic)
> + * this function allocates the resources for TX and RX paths. In case of
> + * reception, for example, it pre-allocated the RX socket buffer in orde=
r to
> + * allow zero-copy mechanism.
> + */
> +static int alloc_dma_desc_resources(struct stmmac_priv *priv)
> +{
> +	/* RX Allocation */
> +	int ret =3D alloc_dma_rx_desc_resources(priv);

And here.

> +
> +	if (ret)
> +		return ret;
> +
> +	/* TX Allocation */
> +	ret =3D alloc_dma_tx_desc_resources(priv);

And here.

None of the above comments are critical and this could be cleaned up in
follow-up patches, so:

Reviewed-by: Thierry Reding <treding@nvidia.com>

It also doesn't break on Tegra186, so

Tested-by: Thierry Reding <treding@nvidia.com>

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljj7J0ACgkQ3SOs138+
s6FRNBAAubp+8I9ZdFyl/IMH6xPYOy1jy8tO9aKPNoJdECN5DjLe/TN9d+w3EzRL
StmQ4qt/ZBT49gMqP/feftw8hN5/KQktVdQPy+V/5+F0ixUvAmVtJAVuLlUEgXEf
Wk4Tt6pbapX/QJaEndXcUblAOIGlAR8f/USbVk6XqlTN9Tgm/z7I12CS6JtQlO8R
DSWGdjga9GQzfY8VDv+BT5lQtkAWbljoJgejOin/rKr3lPJrZ24wEdHXni24/y91
J20hYgho9ul/geTTiRC6rR/vwF/08B4C8BZ7dleeV07p+QykMzrroTq7zdKLg2JZ
FFnZ993XtpBgyjh+LJbVppUnRdXVBIInzmOwdj/pgFscYwOSbwvdYr6qn10BEU7e
g78tSqvL8F9iVW6Cxh+Lgy0X7jYQ642XONm/Mo4aHAmjcyrem7pNouzLOO5xReKK
gXRhSLXzYkzJYQD/f/UFc4YYgq+ZLRNnEpYIchKelHmHiCFj1js8xPgFAxeD3Pr1
sYg4JG8gKLY+B+J/xTX1078zVIlZaL3Ftq/ew08UvlfyU75i66Jg4FmiXWeQB05Z
G53Al9uDxSY4ZvbDNV00kUhfmxrc4Fxlev2kePjQHnKeTfsoDFQNZOXYxZxF0NiI
pBQzF2kwpbgx3c24MOL3GO+NxR8it7K1NHcsKR/pw2sXQphR7YI=
=Q2OT
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--
