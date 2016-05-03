From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH net] net: macb: Probe MDIO bus before registering netdev
Date: Tue, 3 May 2016 10:33:05 +0200
Message-ID: <57286241.9050405@atmel.com>
References: <1462239525-22723-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:28187 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcECIcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 04:32:52 -0400
In-Reply-To: <1462239525-22723-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/05/2016 03:38, Florian Fainelli a =E9crit :
> The current sequence makes us register for a network device prior to
> registering and probing the MDIO bus which could lead to some unwante=
d
> consequences, like a thread of execution calling into ndo_open before
> register_netdev() returns, while the MDIO bus is not ready yet.
>=20
> Rework the sequence to register for the MDIO bus, and therefore attac=
h
> to a PHY prior to calling register_netdev(), which implies reworking =
the
> error path a bit.
>=20
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks a lot Florian for this follow-up and the advices you had given t=
o
Alexandre during the debug session when you spotted this problem.

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
> Tracking down the exact commit which started doing that was a little
> difficult, so I can't really provide a proper Fixes tag yet that does
> not reference 4-5 commits

Yes, indeed. Macb is moving quite a bit those days ;-)


Bye,


>  drivers/net/ethernet/cadence/macb.c | 31 +++++++++++++++++++--------=
----
>  1 file changed, 19 insertions(+), 12 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 48a7d7dee846..e9b470a5ddd0 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -441,7 +441,7 @@ static int macb_mii_init(struct macb *bp)
>  	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
>  		bp->pdev->name, bp->pdev->id);
>  	bp->mii_bus->priv =3D bp;
> -	bp->mii_bus->parent =3D &bp->dev->dev;
> +	bp->mii_bus->parent =3D &bp->pdev->dev;
>  	pdata =3D dev_get_platdata(&bp->pdev->dev);
> =20
>  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
> @@ -3019,29 +3019,36 @@ static int macb_probe(struct platform_device =
*pdev)
>  	if (err)
>  		goto err_out_free_netdev;
> =20
> +	err =3D macb_mii_init(bp);
> +	if (err)
> +		goto err_out_free_netdev;
> +
> +	phydev =3D bp->phy_dev;
> +
> +	netif_carrier_off(dev);
> +
>  	err =3D register_netdev(dev);
>  	if (err) {
>  		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> -		goto err_out_unregister_netdev;
> +		goto err_out_unregister_mdio;
>  	}
> =20
> -	err =3D macb_mii_init(bp);
> -	if (err)
> -		goto err_out_unregister_netdev;
> -
> -	netif_carrier_off(dev);
> +	phy_attached_info(phydev);
> =20
>  	netdev_info(dev, "Cadence %s rev 0x%08x at 0x%08lx irq %d (%pM)\n",
>  		    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
>  		    dev->base_addr, dev->irq, dev->dev_addr);
> =20
> -	phydev =3D bp->phy_dev;
> -	phy_attached_info(phydev);
> -
>  	return 0;
> =20
> -err_out_unregister_netdev:
> -	unregister_netdev(dev);
> +err_out_unregister_mdio:
> +	phy_disconnect(bp->phy_dev);
> +	mdiobus_unregister(bp->mii_bus);
> +	mdiobus_free(bp->mii_bus);
> +
> +	/* Shutdown the PHY if there is a GPIO reset */
> +	if (bp->reset_gpio)
> +		gpiod_set_value(bp->reset_gpio, 0);
> =20
>  err_out_free_netdev:
>  	free_netdev(dev);
>=20


--=20
Nicolas Ferre
