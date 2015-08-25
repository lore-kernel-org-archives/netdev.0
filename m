From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: add locking to phy_read_mmd_indirect()/phy_write_mmd_indirect()
Date: Tue, 25 Aug 2015 07:08:24 -0700
Message-ID: <55DC76D8.4090500@gmail.com>
References: <E1ZU9vP-0004nN-LW@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35241 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424AbbHYOI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 10:08:26 -0400
Received: by oiew67 with SMTP id w67so101405573oie.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 07:08:26 -0700 (PDT)
In-Reply-To: <E1ZU9vP-0004nN-LW@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/25/15 01:49, Russell King a =C3=A9crit :
> The phy layer is missing locking for the above two functions - it
> has been observed that two threads (userspace and the phy worker
> thread) can race, entering the bus ->write or ->read functions
> simultaneously.
>=20
> This causes the FEC driver to initialise a completion while another
> thread is waiting on it or while the interrupt is calling complete()
> on it, which causes spinlock unlock-without-lock, spinlock lockups,
> and completion timeouts.
>=20
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
=46ixes: a59a4d192 ("phy: add the EEE support and the way to access to =
the
MMD registers.")
=46ixes: 0c1d77dfb ("net: libphy: Add phy specific function to access m=
md
phy registers")

Thanks!

> ---
>  drivers/net/phy/phy.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 1e1fbb049ec6..34fe339f4e80 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -1038,10 +1038,14 @@ int phy_read_mmd_indirect(struct phy_device *=
phydev, int prtad,
>  	int value =3D -1;
> =20
>  	if (phydrv->read_mmd_indirect =3D=3D NULL) {
> -		mmd_phy_indirect(phydev->bus, prtad, devad, addr);
> +		struct mii_bus *bus =3D phydev->bus;
> +
> +		mutex_lock(&bus->mdio_lock);
> +		mmd_phy_indirect(bus, prtad, devad, addr);
> =20
>  		/* Read the content of the MMD's selected register */
> -		value =3D phydev->bus->read(phydev->bus, addr, MII_MMD_DATA);
> +		value =3D bus->read(bus, addr, MII_MMD_DATA);
> +		mutex_unlock(&bus->mdio_lock);
>  	} else {
>  		value =3D phydrv->read_mmd_indirect(phydev, prtad, devad, addr);
>  	}
> @@ -1071,10 +1075,14 @@ void phy_write_mmd_indirect(struct phy_device=
 *phydev, int prtad,
>  	struct phy_driver *phydrv =3D phydev->drv;
> =20
>  	if (phydrv->write_mmd_indirect =3D=3D NULL) {
> -		mmd_phy_indirect(phydev->bus, prtad, devad, addr);
> +		struct mii_bus *bus =3D phydev->bus;
> +
> +		mutex_lock(&bus->mdio_lock);
> +		mmd_phy_indirect(bus, prtad, devad, addr);
> =20
>  		/* Write the data into MMD's selected register */
> -		phydev->bus->write(phydev->bus, addr, MII_MMD_DATA, data);
> +		bus->write(bus, addr, MII_MMD_DATA, data);
> +		mutex_unlock(&bus->mdio_lock);
>  	} else {
>  		phydrv->write_mmd_indirect(phydev, prtad, devad, addr, data);
>  	}
>=20


--=20
=46lorian
