From: Josh Cartwright <joshc@ni.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Mon, 2 May 2016 14:38:04 -0500
Message-ID: <20160502193804.GD31001@jcartwri.amer.corp.natinst.com>
References: <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
 <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
 <57235655.3030104@atmel.com>
 <20160502183626.GC31001@jcartwri.amer.corp.natinst.com>
 <5727A5C2.804@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="YD3LsXFS42OYHhNZ"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Nathan Sullivan <nathan.sullivan@ni.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:53183 "EHLO ni.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754876AbcEBTiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 15:38:18 -0400
In-Reply-To: <5727A5C2.804@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YD3LsXFS42OYHhNZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 02, 2016 at 12:08:50PM -0700, Florian Fainelli wrote:
> On 02/05/16 11:36, Josh Cartwright wrote:
> > On Fri, Apr 29, 2016 at 02:40:53PM +0200, Nicolas Ferre wrote:
> > [..]
> >>>  static int macb_mii_init(struct macb *bp)
> >>>  {
> >>>  	struct macb_platform_data *pdata;
> >>>  	struct device_node *np;
> >>> -	int err =3D -ENXIO, i;
> >>> +	int err =3D -ENXIO;
> >>> =20
> >>>  	/* Enable management port */
> >>>  	macb_writel(bp, NCR, MACB_BIT(MPE));
> >>> @@ -446,33 +497,10 @@ static int macb_mii_init(struct macb *bp)
> >>>  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
> >>> =20
> >>>  	np =3D bp->pdev->dev.of_node;
> >>> -	if (np) {
> >>> -		/* try dt phy registration */
> >>> -		err =3D of_mdiobus_register(bp->mii_bus, np);
> >>> -
> >>> -		/* fallback to standard phy registration if no phy were
> >>> -		 * found during dt phy registration
> >>> -		 */
> >>> -		if (!err && !phy_find_first(bp->mii_bus)) {
> >>> -			for (i =3D 0; i < PHY_MAX_ADDR; i++) {
> >>> -				struct phy_device *phydev;
> >>> -
> >>> -				phydev =3D mdiobus_scan(bp->mii_bus, i);
> >>> -				if (IS_ERR(phydev)) {
> >>> -					err =3D PTR_ERR(phydev);
> >>> -					break;
> >>> -				}
> >>> -			}
> >>> -
> >>> -			if (err)
> >>> -				goto err_out_unregister_bus;
> >>> -		}
> >>> -	} else {
> >>> -		if (pdata)
> >>> -			bp->mii_bus->phy_mask =3D pdata->phy_mask;
> >>> -
> >>> -		err =3D mdiobus_register(bp->mii_bus);
> >>> -	}
> >>> +	if (np)
> >>> +		err =3D macb_mii_of_init(bp, np);
> >>> +	else
> >>> +		err =3D macb_mii_pdata_init(bp, pdata);
> >>> =20
> >>>  	if (err)
> >>>  		goto err_out_free_mdiobus;
> >>
> >> I'm okay with this. Thanks for having taken the initiative to implemen=
t it.
> >=20
> > Unfortunately, I don't think it's going to be as straightforward
> > as I originally thought.  Still doable, but more complicated.
> >=20
> > In particular, the macb bindings allow for a user to specify a
> > 'reset-gpios' property _at the PHY_ level, which is consumed by the
> > macb to adjust the PHY reset state on remove.
>=20
> In fact, not just on remove, anytime there is an opportunity to save
> power (interface down, closed) and putting the PHY into reset is usually
> guaranteed to be saving more power than e.g: a BMCR power down.

I can understand how that might have been a long term goal of managing a
reset GPIO in general, however as it stands in the macb driver the only
callsite where the reset gpio is tweaked macb_remove().

> > My question is: why is the PHY reset GPIO management not the
> > responsibility of the PHY driver/core itself?
>=20
> Well, this is actually being worked on at the moment by Sergei, since
> there is not necessarily a reason why PHYLIB can't deal with that:
>=20
> https://lkml.org/lkml/2016/4/28/831

Cool, thanks.  I was about to see about implementing this...but since
it's already been done, I'll rebase my set on Sergei's changes.

Thanks,
  Josh

--YD3LsXFS42OYHhNZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXJ6yYAAoJEKp7ZBKwQFArTuAH/33Q1lZILyyOTizFI77SaEGa
fzOUDNVoMhziLJGpHWaIQSBg/2ItlnDI5+f6DBKXX+Gx2EfszhhjGMNqK7PbjcQI
OgTha+VWqEcy01xmtrrVGoeXGLrHV7tAX/RL9FsC4HAnLCL/cw+4LXkwMuTMUwIz
qjwVaHMM4zTIJswI+HoeIMXcpn4yR74WTZ0xmMeUe24WscRkv6Dpp1OgVascizpi
zkgPihR0fUdSpCWxmCoXPEAqljK1Kyi79Sa6P6M0+1vIHwiIvQ9m2ZOsaDWI7SL0
o747qkkOyO77+0YQOhR8teK7mpUn1kKE5qIXOCeTix8jj8rpvOAA1oFxywC4tNY=
=CWb/
-----END PGP SIGNATURE-----

--YD3LsXFS42OYHhNZ--
