From: Thierry Reding <treding@nvidia.com>
Subject: Re: [PATCH 4/4] net: stmmac: adding multiple napi mechanism
Date: Tue, 4 Apr 2017 21:28:49 +0200
Message-ID: <20170404192849.GF24271@ulmo.ba.sec>
References: <433505e9e631db632be7a37a316a03ace802863c.1491328304.git.jpinto@synopsys.com>
 <7af29adf8064bf5bb55b5a4e9fb2a3f325c873a2.1491328304.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3yNHWXBV/QO9xKNm"
Cc: <davem@davemloft.net>, <clabbe.montjoie@gmail.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:4284 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754765AbdDDT26 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 15:28:58 -0400
In-Reply-To: <7af29adf8064bf5bb55b5a4e9fb2a3f325c873a2.1491328304.git.jpinto@synopsys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--3yNHWXBV/QO9xKNm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 04, 2017 at 06:54:27PM +0100, Joao Pinto wrote:
[...]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
[...]
> @@ -1259,7 +1317,6 @@ static int init_dma_tx_desc_rings(struct net_device *dev)
>  		/* TX INITIALIZATION */
>  		for (i = 0; i < DMA_TX_SIZE; i++) {
>  			struct dma_desc *p;
> -
>  			if (priv->extend_desc)
>  				p = &((tx_q->dma_etx + i)->basic);
>  			else

I think checkpatch would complain about this now because we're supposed
to separate variable declarations from code by a single blank line.

> -	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
> +	ret = alloc_dma_desc_resources(priv);
> +	if (ret < 0) {
> +		netdev_err(priv->dev, "%s: DMA descriptors allocation failed\n",
> +			   __func__);
> +		goto init_dma_error;
> +	}
> +
> +	ret = init_dma_desc_rings(priv->dev, GFP_KERNEL);
> +	if (ret < 0) {
> +		netdev_err(priv->dev, "%s: DMA descriptors initialization failed\n",
> +			   __func__);
> +		goto init_dma_error;
> +	}
> +
> +	for (queue = 0; queue < priv->plat->rx_queues_to_use; queue++) {
> +		struct stmmac_rx_queue *rx_q = &priv->rx_queue[queue];
> +
> +		netif_napi_add(ndev, &rx_q->napi, stmmac_poll,
> +			       (8 * priv->plat->rx_queues_to_use));
> +	}

Why is this moving to ->probe() now?

This works on Tegra186, so:

Reviewed-by: Thierry Reding <treding@nvidia.com>

--3yNHWXBV/QO9xKNm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljj8/EACgkQ3SOs138+
s6G/TA//eE9w4UdL/+ay0Insrm0KPME/qtSp396cWL5bg0s0oY0/AN0iLmwYGBjJ
bvnwSi6GiO56mvuy+cM1c1KBCPp6Pjx8fZOUiDvg0O6cnkZOY5pdE6hboFmjLokc
F/pgptxe4kREKmxu7AVjp2i8IY4QJBk4Itf771GxZuW5vC3JbmFWansC0WG9RyyK
DIzzGIma10uj29SHpV8jQv/18dt5Wet/oqy1i27QfCq+OCjAilP/cYLQ0N0x7Hdp
p3dWLCH4GGxQ6HU51WoLOLpvbxRoNdTcW39LqksiuzAMlHwcswyJdvL4t/akbyw9
znIlUb8AMYGSGGcO5CSGTkoiaq2vq/P4mTZyb/w4hiVEQrY2h4wNZoNKgSKtHj17
rFgzz7rBqIP0n/qOHnOrfUHQBpBxnuhgcPJoXKaI21k41n3LU0PXJXDMsZYrlrHi
B8f/ESxttKlYPIE13pZBKdxhz5bpjl3YIDsp2ulnvKWwZr56Hc7w1jbGrwCS+go0
Nr3eGW7eibHGBJFuRPBYoQ1S3Kpaqz6Skck3+3sY0hZG0GTz9eRivOKpcxazmaKS
xO2+Mf1MTa1OK7eUy+tVF/ErkQ3DLW1MtYnE4rrBanDuUla1g+2FYVVnTECjCdtJ
UX3b17RSqbRQEm+VeT1grpbvkYHmqLdw0ZL0rU5cHijSjqP8yKM=
=M9tg
-----END PGP SIGNATURE-----

--3yNHWXBV/QO9xKNm--
