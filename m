From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] mdio_bus: Fix MDIO bus scanning in __mdiobus_register()
Date: Thu, 28 Apr 2016 18:49:47 -0700
Message-ID: <5722BDBB.40606@gmail.com>
References: <1461892155-10524-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S . Miller" <davem@davemloft.net>,
	Dinh Nguyen <dinguyen@opensource.altera.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36036 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbcD2Btu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:49:50 -0400
Received: by mail-oi0-f54.google.com with SMTP id x201so104029713oif.3
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 18:49:50 -0700 (PDT)
In-Reply-To: <1461892155-10524-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/04/2016 18:09, Marek Vasut a =C3=A9crit :
> Since commit b74766a0a0feeef5c779709cc5d109451c0d5b17 in linux-next,
> ( phylib: don't return NULL from get_phy_device() ), phy_get_device()
> will return ERR_PTR(-ENODEV) instead of NULL if the PHY device ID is
> all ones.
>=20
> This causes problem with stmmac driver and likely some other drivers
> which call mdiobus_register(). I triggered this bug on SoCFPGA MCVEVK
> board with linux-next 20160427 and 20160428. In case of the stmmac, i=
f
> there is no PHY node specified in the DT for the stmmac block, the st=
mmac
> driver ( drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c function
> stmmac_mdio_register() ) will call mdiobus_register() , which will
> register the MDIO bus and probe for the PHY.
>=20
> The mdiobus_register() resp. __mdiobus_register() iterates over all o=
f
> the addresses on the MDIO bus and calls mdiobus_scan() for each of th=
em,
> which invokes get_phy_device(). Before the aforementioned patch, the
> mdiobus_scan() would return NULL if no PHY was found on a given addre=
ss
> and mdiobus_register() would continue and try the next PHY address. N=
ow,
> mdiobus_scan() returns ERR_PTR(-ENODEV), which is caught by the
> 'if (IS_ERR(phydev))' condition and the loop exits immediatelly if th=
e
> PHY address does not contain PHY.
>=20
> Repair this by explicitly checking for the ERR_PTR(-ENODEV) and if th=
is
> error comes around, continue with the next PHY address.
>=20
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Dinh Nguyen <dinguyen@opensource.altera.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

I had an exact same patch posted yesterday but not formally like you
did, thanks!

> ---
>  drivers/net/phy/mdio_bus.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> NOTE: I don't quite like this explicit check , but I don't have bette=
r idea now.
>=20
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 499003ee..388f992 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -333,7 +333,7 @@ int __mdiobus_register(struct mii_bus *bus, struc=
t module *owner)
>  			struct phy_device *phydev;
> =20
>  			phydev =3D mdiobus_scan(bus, i);
> -			if (IS_ERR(phydev)) {
> +			if (IS_ERR(phydev) && (PTR_ERR(phydev) !=3D -ENODEV)) {
>  				err =3D PTR_ERR(phydev);
>  				goto error;
>  			}
>=20


--=20
=46lorian
