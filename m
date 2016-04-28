From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 17:44:14 +0200
Message-ID: <57222FCE.8050407@atmel.com>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Nathan Sullivan <nathan.sullivan@ni.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 28/04/2016 16:46, Nathan Sullivan a =E9crit :
> Since of_mdiobus_register and mdiobus_register will scan automaticall=
y,
> do not manually scan for PHY devices in the macb ethernet driver. Doi=
ng
> so will result in many nonexistent PHYs on the MDIO bus if the MDIO
> lines are floating or grounded, such as when they are not used.
>=20
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>

Well, as explained in the commit message that added this feature and in
the comment, if no phy is specified in the DT we end up without phy...

There are AT91 platforms which lack specification for the phy node in
the DT. So, I don't know if there is a better way to deal with this cas=
e
but I see this removal as risky.

Bye,


> ---
>  drivers/net/ethernet/cadence/macb.c |   19 +------------------
>  1 file changed, 1 insertion(+), 18 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 48a7d7d..6506b4e 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -424,7 +424,7 @@ static int macb_mii_init(struct macb *bp)
>  {
>  	struct macb_platform_data *pdata;
>  	struct device_node *np;
> -	int err =3D -ENXIO, i;
> +	int err =3D -ENXIO;
> =20
>  	/* Enable management port */
>  	macb_writel(bp, NCR, MACB_BIT(MPE));
> @@ -450,23 +450,6 @@ static int macb_mii_init(struct macb *bp)
>  	if (np) {
>  		/* try dt phy registration */
>  		err =3D of_mdiobus_register(bp->mii_bus, np);
> -
> -		/* fallback to standard phy registration if no phy were
> -		   found during dt phy registration */
> -		if (!err && !phy_find_first(bp->mii_bus)) {
> -			for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> -				struct phy_device *phydev;
> -
> -				phydev =3D mdiobus_scan(bp->mii_bus, i);
> -				if (IS_ERR(phydev)) {
> -					err =3D PTR_ERR(phydev);
> -					break;
> -				}
> -			}
> -
> -			if (err)
> -				goto err_out_unregister_bus;
> -		}
>  	} else {
>  		if (pdata)
>  			bp->mii_bus->phy_mask =3D pdata->phy_mask;
>=20


--=20
Nicolas Ferre
