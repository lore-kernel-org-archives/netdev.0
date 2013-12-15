From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 8/8] b44: add dummy PHY device if we do not find any
Date: Sun, 15 Dec 2013 21:26:07 +0000
Message-ID: <1931903.b5YbP2FvL1@lenovo>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de> <1387132925-18651-9-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:65163 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914Ab3LOV0P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 16:26:15 -0500
Received: by mail-wg0-f44.google.com with SMTP id a1so3817220wgh.23
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 13:26:13 -0800 (PST)
In-Reply-To: <1387132925-18651-9-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hauke,

Le dimanche 15 d=E9cembre 2013, 19:42:05 Hauke Mehrtens a =E9crit :
> The ADM6996L switches used on some routers do not return a valid valu=
e
> when reading the PHY id register and Linux thinks there is not PHY at
> all, but that is wrong. This created a dummy PHY and uses that instea=
d.

As far as I read it from the ADM6996L datasheet; the management interfa=
ce on=20
these switches is via a serial EEPROM which was usually wired up to the=
=20
BCM47xx SoC to some GPIOs (kmod-switch driver in OpenWrt). If MII_PHYSI=
D1 and=20
MII_PHYSID2 present bad values, I would assume that MII_BMSR would also=
 return=20
bad values too and that if you are given a valid link speed/duplex this=
 might=20
just be because all bits are set?

In any case this is a case where you should register a fixed PHY device=
 instead=20
of creating such a dummy device which will still make the mdiobus drive=
r/PHY=20
state machine issue real reads/writes on the MDIO bus to a non-existent=
 PHY.

>=20
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/net/ethernet/broadcom/b44.c |   23 +++++++++++++++++++----
>  drivers/net/ethernet/broadcom/b44.h |    3 +++
>  2 files changed, 22 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/b44.c
> b/drivers/net/ethernet/broadcom/b44.c index b65a463..07e58c2 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -2233,6 +2233,8 @@ static int b44_register_phy_one(struct b44 *bp)
>  	struct ssb_device *sdev =3D bp->sdev;
>  	struct phy_device *phydev;
>  	int err;
> +	struct phy_c45_device_ids c45_ids =3D {0};
> +	struct ssb_sprom *sprom =3D &sdev->bus->sprom;
>=20
>  	mii_bus =3D mdiobus_alloc();
>  	if (!mii_bus) {
> @@ -2266,10 +2268,23 @@ static int b44_register_phy_one(struct b44 *b=
p)
>  	}
>=20
>  	phydev =3D bp->mii_bus->phy_map[bp->phy_addr];
> -	if (!phydev) {
> -		dev_err(sdev->dev, "could not find PHY at %i\n", bp->phy_addr);
> -		err =3D -ENODEV;
> -		goto err_out_mdiobus_unregister;
> +	if (!phydev &&
> +	    (sprom->boardflags_lo & (B44_BOARDFLAG_ROBO | B44_BOARDFLAG_ADM=
))) {
> +		dev_info(sdev->dev, "could not find PHY at %i, create dummy one\n"=
,
> +			 bp->phy_addr);

Your commit subject says ADM6996L but here you are also treating Broadc=
om=20
switches that way, this might deserve a comment to explain that some BC=
M53xx=20
switches might be SPI/GPIO connected.

> +
> +		phydev =3D phy_device_create(bp->mii_bus, bp->phy_addr, 0x0,
> +					   false, &c45_ids);
> +		if (IS_ERR(phydev)) {
> +			err =3D PTR_ERR(phydev);
> +			dev_err(sdev->dev, "Can not create dummy PHY\n");
> +			goto err_out_mdiobus_unregister;
> +		}
> +		err =3D phy_device_register(phydev);
> +		if (err) {
> +			dev_err(sdev->dev, "failed to register MII bus\n");
> +			goto err_out_mdiobus_unregister;
> +		}
>  	}
>=20
>  	err =3D phy_connect_direct(bp->dev, phydev, &b44_adjust_link,
> diff --git a/drivers/net/ethernet/broadcom/b44.h
> b/drivers/net/ethernet/broadcom/b44.h index c5ec9b4..e6780fe 100644
> --- a/drivers/net/ethernet/broadcom/b44.h
> +++ b/drivers/net/ethernet/broadcom/b44.h
> @@ -345,6 +345,9 @@ B44_STAT_REG_DECLARE
>  	struct u64_stats_sync	syncp;
>  };
>=20
> +#define	B44_BOARDFLAG_ROBO		0x0010  /* Board has robo switch */
> +#define	B44_BOARDFLAG_ADM		0x0080  /* Board has ADMtek switch */
> +
>  struct ssb_device;
>=20
>  struct b44 {

--=20
=46lorian
