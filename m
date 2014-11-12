From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net on
 arndale platform
Date: Wed, 12 Nov 2014 00:23:22 +0000
Message-ID: <1415751802.3398.107.camel@decadent.org.uk>
References: <20141104072236.GA559@afflict.kos.to>
	 <C89EFD3CD56F64468D3D206D683A8D2203985F49@ldam-msx2.fugro-nl.local>
	 <20141104094336.GA3145@afflict.kos.to>
	 <C89EFD3CD56F64468D3D206D683A8D2203985FA9@ldam-msx2.fugro-nl.local>
	 <20141104200914.GN23178@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AIfNf5xTiBlgC4y0RSEY"
Cc: "Stam, Michel [FINT]" <M.Stam@fugro.nl>,
	Riku Voipio <riku.voipio@iki.fi>, davem@davemloft.net,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org
To: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141104200914.GN23178@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AIfNf5xTiBlgC4y0RSEY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-04 at 20:09 +0000, Charles Keepax wrote:
> On Tue, Nov 04, 2014 at 11:23:06AM +0100, Stam, Michel [FINT] wrote:
> > Hello Riku,
> >=20
> > >Fixing a bug (ethtool support) must not cause breakage elsewhere (in
> > this case on arndale). This is now a regression of functionality from
> > 3.17.
> > >
> > >I think it would better to revert the change now and with less hurry
> > introduce a ethtool fix that doesn't break arndale.
> >=20
> > I don't fully agree here;=20
> > I would like to point out that this commit is a revert itself. Fixing
> > the armdale will then cause breakage in other implementations, such as
> > ours. Blankly reverting breaks other peoples' implementations.
> >=20
> > The PHY reset is the thing that breaks ethtool support, so any fix that
> > appeases all would have to take existing PHY state into account.=20
[...]
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -299,6 +299,7 @@ static int ax88772_reset(struct usbnet *dev)
>  {
>         struct asix_data *data =3D (struct asix_data *)&dev->data;
>         int ret, embd_phy;
> +       int reg;
>         u16 rx_ctl;
>=20
>         ret =3D asix_write_gpio(dev,
> @@ -359,8 +360,10 @@ static int ax88772_reset(struct usbnet *dev)
>         msleep(150);
>=20
>         asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
> -       asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
> -                       ADVERTISE_ALL | ADVERTISE_CSMA);
> +       reg =3D asix_mdio_read(dev->net, dev->mii.phy_id, MII_ADVERTISE);
> +       if (!reg)
> +               reg =3D ADVERTISE_ALL | ADVERTISE_CSMA;
> +       asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE, reg);
[...]

Why is there no sleep after setting the RESET bit?  Doesn't that make
the following register writes unreliable?

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-AIfNf5xTiBlgC4y0RSEY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVGKof+e/yOyVhhEJAQpNmA//YzP85bqno+y9Phv7nG3/6nobdFZ14xRa
2QqMNOfITadD1HEwmcRMgoyF4h8M3Wg4RVDKgFyyZcYGvSEXXvFw857X3yWG/WYv
LkHOdPWAtiFQBsJAzruRRwGaGhaG/IRKQFlSiIJZLRT4rVtrbpAdG3dPGmZvUjZV
WZx9ca2u5hy9gDWh6gc/AvoUDOcDZchMi4caYZrTH1q3RDui9Lp5PVkTZ8oqqa/p
Fa3awiqqIhhRDhTZltNrUxOh9llmlWC/q4sq+0PYu1uBozrkvzpLgsVqckECsTIl
cDfUiEKKaUVV6Y0AUbatJjx7oQcG2YFTyPhr1M76DT6TKdrL2WzemBNieouuqHbu
YT7pUWkCvt9avwDw3sJ/djkjottW2zhj8WWj1O6+O6evJP4rn5FkqXKdWQzyQyJv
UOYcQFQI04NJyrHKmc/uCcjt3zhX5/kOjZNdEAYXbWxmnFJMQEQWX4FiBViEY5Z4
AdqGhiAgm088aIEqg4fkJLUYxNnt9tkFXYfOUrK/fTIMc5pnfNuyabwMhEXbrvSz
w/5XF0p9eoYNwIWsX52I+sXfmwx/mt0FcxhGEn5uH2hOTEE28pSwexSv0V5tN8rw
msaCkSQD/X4+7UG6M6PzV+fFb1VtKz0Y/wtA4f1Tl/58VG5heAZttoeccjBW1zg2
EPmFxUZ98t4=
=Atva
-----END PGP SIGNATURE-----

--=-AIfNf5xTiBlgC4y0RSEY--
