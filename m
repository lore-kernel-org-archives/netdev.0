From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH 9/9] ethernet: sun8i-emac: add pm_runtime support
Date: Sat, 17 Sep 2016 15:40:14 +0200
Message-ID: <20160917134014.GB17518@lukather>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-10-git-send-email-clabbe.montjoie@gmail.com>
 <20160912204451.GO9449@lukather>
 <20160914140304.GA27639@Red>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="4SFOXa2GPu3tIq4H"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160914140304.GA27639@Red>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--4SFOXa2GPu3tIq4H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 14, 2016 at 04:03:04PM +0200, LABBE Corentin wrote:
> > > +static int __maybe_unused sun8i_emac_suspend(struct platform_device =
*pdev, pm_message_t state)
> > > +{
> > > +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> > > +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
> > > +
> > > +	napi_disable(&priv->napi);
> > > +
> > > +	if (netif_running(ndev))
> > > +		netif_device_detach(ndev);
> > > +
> > > +	sun8i_emac_stop_tx(ndev);
> > > +	sun8i_emac_stop_rx(ndev);
> > > +
> > > +	sun8i_emac_rx_clean(ndev);
> > > +	sun8i_emac_tx_clean(ndev);
> > > +
> > > +	phy_stop(ndev->phydev);
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static int __maybe_unused sun8i_emac_resume(struct platform_device *=
pdev)
> > > +{
> > > +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> > > +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
> > > +
> > > +	phy_start(ndev->phydev);
> > > +
> > > +	sun8i_emac_start_tx(ndev);
> > > +	sun8i_emac_start_rx(ndev);
> > > +
> > > +	if (netif_running(ndev))
> > > +		netif_device_attach(ndev);
> > > +
> > > +	netif_start_queue(ndev);
> > > +
> > > +	napi_enable(&priv->napi);
> > > +
> > > +	return 0;
> > > +}
> >=20
> > The main idea behind the runtime PM hooks is that they bring the
> > device to a working state and shuts it down when it's not needed
> > anymore.

Indeed.

> I expect that the first part (all pm_runtime_xxx) of the patch bring that.
> When the interface is not opened:
> cat /sys/devices/platform/soc/1c30000.ethernet/power/runtime_status=20
> suspended
>=20
> > However, they shouldn't be called when the device is still in used, so
> > all the mangling with NAPI, the phy and so on is irrelevant here, but
> > the clocks, resets, for example, are.
> >=20
>=20
> I do the same as other ethernet driver for suspend/resume.

suspend / resume are used when you put the whole system into suspend,
and bring it back.

runtime_pm is only when the device is not used anymore. It makes sense
when you suspend to do whatever you're doing here. It doesn't make any
when the system is not suspended, but the device is.

> > >  static const struct of_device_id sun8i_emac_of_match_table[] =3D {
> > >  	{ .compatible =3D "allwinner,sun8i-a83t-emac",
> > >  	  .data =3D &emac_variant_a83t },
> > > @@ -2246,6 +2302,8 @@ static struct platform_driver sun8i_emac_driver=
 =3D {
> > >  		.name           =3D "sun8i-emac",
> > >  		.of_match_table	=3D sun8i_emac_of_match_table,
> > >  	},
> > > +	.suspend	=3D sun8i_emac_suspend,
> > > +	.resume		=3D sun8i_emac_resume,
> >=20
> > These are not the runtime PM hooks. How did you test that?
> >=20
>=20
> Anyway I didnt test suspend/resume so I will remove it until I
> successfully found how to hibernate my board.

So you submit code you never tested? That's usually a recipe for
disaster.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--4SFOXa2GPu3tIq4H
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX3Ue+AAoJEBx+YmzsjxAg+JAQALmjdGCW8ctIu5pMZPBgiEjP
wEcpBbTapEroaM1pHaOChpGhUwwxY2K2sBznf1gAJJcO5HTyBjWv1halNIt5guwd
zpVzWbxrGvQ48rcTc9pX17ZsuIcb99gpZ+kY3W8PPO+SXJPbhrPIcXyRRzg0F7nH
8/SF7J9Msg1sisdREMUKmfpc9SSu5gFXT4CwvwIW5Z3QWTl7+TdUB12hSdktv0w/
a5IGF3wudLc1GvbnKzus6Tqn6Ebz4hkeFxeS1XHXlFcJR+TuhY0VyRZQH5fPdTon
c79bz7N+tbjtoZhsVYBC8ia7gt7aoo8Vk0ZNDUSmW8Rytt3+Pts5axBB1CNsF0b3
oD0kF8ErYG97RhgC8O+9DLN6S55Y6sKBmAtjD/jjgzfjiS3NER04LK4epu96KHgz
ttpFYRye1X2hamt44kBlp12Cxt1gon0iK/q0UP/1BJEpQdvgDB8yZy0PNnsyPFQl
1yZTmJw9T083XPDA8AS9Hf/W53Zby2JSFmx8027I8VsB1VzZw8QDQrih2hV2S8xz
IbeJnC4DasbOLF8ZbPpFF7z/TB6Xm3AFzUB1OsCeaN3XcNwUHnAtd/1hLowDeGhM
TDcme049cE+Xy9ggaq79u5LDx2M6IatlofDLrITde6pktFP7nHJcNMsXFHc3YFmg
W0AtpBqOWTSjpJ2OZoG+
=Vt8G
-----END PGP SIGNATURE-----

--4SFOXa2GPu3tIq4H--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
