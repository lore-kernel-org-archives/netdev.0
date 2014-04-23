From: Max Schwarz <max.schwarz@online.de>
Subject: Re: [PATCH 1/2] arc_emac: fix probe error path
Date: Wed, 23 Apr 2014 23:32:49 +0200
Message-ID: <4708161.tMhNKnF3yn@typ>
References: <2479609.DglKFY1Bsn@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	netdev@vger.kernel.org
To: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.13]:57276 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbaDWVdA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:33:00 -0400
In-Reply-To: <2479609.DglKFY1Bsn@phil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 April 2014 at 14:21:55, Heiko St=FCbner wrote:
> The probe function at the moment only frees the netdev but does not
> disconnect the phy or removes the mdio bus it registered.
>=20
> Signed-off-by: Heiko Stuebner <heiko@sntech.de>
> ---
>  drivers/net/ethernet/arc/emac_main.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/arc/emac_main.c
> b/drivers/net/ethernet/arc/emac_main.c index 9f45782..0cba97a 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -683,7 +683,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	priv->regs =3D devm_ioremap_resource(&pdev->dev, &res_regs);
>  	if (IS_ERR(priv->regs)) {
>  		err =3D PTR_ERR(priv->regs);
> -		goto out;
> +		goto out_netdev;
>  	}
>  	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs)=
;
>=20
> @@ -693,7 +693,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	if (!(id =3D=3D 0x0005fd02 || id =3D=3D 0x0007fd02)) {
>  		dev_err(&pdev->dev, "ARC EMAC not detected, id=3D0x%x\n", id);
>  		err =3D -ENODEV;
> -		goto out;
> +		goto out_netdev;
>  	}
>  	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
>=20
> @@ -708,7 +708,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  			       ndev->name, ndev);
>  	if (err) {
>  		dev_err(&pdev->dev, "could not allocate IRQ\n");
> -		goto out;
> +		goto out_netdev;
>  	}
>=20
>  	/* Get MAC address from device tree */
> @@ -729,7 +729,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	if (!priv->rxbd) {
>  		dev_err(&pdev->dev, "failed to allocate data buffers\n");
>  		err =3D -ENOMEM;
> -		goto out;
> +		goto out_netdev;
>  	}
>=20
>  	priv->txbd =3D priv->rxbd + RX_BD_NUM;
> @@ -741,7 +741,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	err =3D arc_mdio_probe(pdev, priv);
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to probe MII bus\n");
> -		goto out;
> +		goto out_netdev;
>  	}
>=20
>  	priv->phy_dev =3D of_phy_connect(ndev, phy_node, arc_emac_adjust_li=
nk, 0,
> @@ -749,7 +749,7 @@ static int arc_emac_probe(struct platform_device =
*pdev)
>  	if (!priv->phy_dev) {
>  		dev_err(&pdev->dev, "of_phy_connect() failed\n");
>  		err =3D -ENODEV;
> -		goto out;
> +		goto out_mdio;
>  	}
>=20
>  	dev_info(&pdev->dev, "connected to %s phy with id 0x%x\n",
> @@ -761,12 +761,18 @@ static int arc_emac_probe(struct platform_devic=
e
> *pdev) if (err) {
>  		netif_napi_del(&priv->napi);

That line shouldn't be there anymore, right? You're doing netif_api_del=
()=20
twice here.

>  		dev_err(&pdev->dev, "failed to register network device\n");
> -		goto out;
> +		goto out_netif_api;
>  	}
>=20
>  	return 0;
>=20
> -out:
> +out_netif_api:
> +	netif_napi_del(&priv->napi);
> +	phy_disconnect(priv->phy_dev);
> +	priv->phy_dev =3D NULL;
> +out_mdio:
> +	arc_mdio_remove(priv);
> +out_netdev:
>  	free_netdev(ndev);
>  	return err;
>  }

Everything else looks good.

Cheers,
  Max
