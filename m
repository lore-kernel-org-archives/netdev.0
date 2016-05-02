From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Mon, 2 May 2016 13:36:26 -0500
Message-ID: <20160502183626.GC31001@jcartwri.amer.corp.natinst.com>
References: <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
 <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
 <57235655.3030104@atmel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ADZbWkCsHQ7r3kzd"
Cc: Andrew Lunn <andrew@lunn.ch>,
	Nathan Sullivan <nathan.sullivan@ni.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:40054 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755039AbcEBSvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 14:51:02 -0400
In-Reply-To: <57235655.3030104@atmel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ADZbWkCsHQ7r3kzd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 29, 2016 at 02:40:53PM +0200, Nicolas Ferre wrote:
[..]
> >  static int macb_mii_init(struct macb *bp)
> >  {
> >  	struct macb_platform_data *pdata;
> >  	struct device_node *np;
> > -	int err =3D -ENXIO, i;
> > +	int err =3D -ENXIO;
> > =20
> >  	/* Enable management port */
> >  	macb_writel(bp, NCR, MACB_BIT(MPE));
> > @@ -446,33 +497,10 @@ static int macb_mii_init(struct macb *bp)
> >  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
> > =20
> >  	np =3D bp->pdev->dev.of_node;
> > -	if (np) {
> > -		/* try dt phy registration */
> > -		err =3D of_mdiobus_register(bp->mii_bus, np);
> > -
> > -		/* fallback to standard phy registration if no phy were
> > -		 * found during dt phy registration
> > -		 */
> > -		if (!err && !phy_find_first(bp->mii_bus)) {
> > -			for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> > -				struct phy_device *phydev;
> > -
> > -				phydev =3D mdiobus_scan(bp->mii_bus, i);
> > -				if (IS_ERR(phydev)) {
> > -					err =3D PTR_ERR(phydev);
> > -					break;
> > -				}
> > -			}
> > -
> > -			if (err)
> > -				goto err_out_unregister_bus;
> > -		}
> > -	} else {
> > -		if (pdata)
> > -			bp->mii_bus->phy_mask =3D pdata->phy_mask;
> > -
> > -		err =3D mdiobus_register(bp->mii_bus);
> > -	}
> > +	if (np)
> > +		err =3D macb_mii_of_init(bp, np);
> > +	else
> > +		err =3D macb_mii_pdata_init(bp, pdata);
> > =20
> >  	if (err)
> >  		goto err_out_free_mdiobus;
>=20
> I'm okay with this. Thanks for having taken the initiative to implement i=
t.

Unfortunately, I don't think it's going to be as straightforward
as I originally thought.  Still doable, but more complicated.

In particular, the macb bindings allow for a user to specify a
'reset-gpios' property _at the PHY_ level, which is consumed by the
macb to adjust the PHY reset state on remove.

My question is: why is the PHY reset GPIO management not the
responsibility of the PHY driver/core itself?

  Josh

--ADZbWkCsHQ7r3kzd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXJ54nAAoJEKp7ZBKwQFArwxIH/iB3kt9+eWeNfP7/mncysTAe
PPcV/57UgjpsCmWqyFCLa+jko9hQwZ8W/sdqJFbk1C/FXAnMX65i+OMOXe9Yv4AT
OYSQGi7wHjNhD9WR2CZSeMESpu6HHFLwC99NI/1PLwKi45Nyq76kswrrdLOEnxk8
LarUUqSOUBcxEiTQGXvn3h29BjeBvKPwYPstN5P2sTWfWStvMXA5Cyryym4lbC5j
09l8Wg4CN9AzjgBIxvFK5e9tEJupoLCmP7W45Zfec97HxQNVX0nMYXQ+nvHWZOq2
lUqiJ2BNaIwyX1EX3fTXCY/a/oPH52YrIxX1Wp0w5amaycWG+cRgqEuAh0CZMhk=
=hrFB
-----END PGP SIGNATURE-----

--ADZbWkCsHQ7r3kzd--
