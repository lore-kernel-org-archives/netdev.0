From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 2/6] net: davinci_emac: Fix runtime pm calls for
 davinci_emac
Date: Tue, 13 Jan 2015 15:03:26 -0600
Message-ID: <20150113210326.GA16533@saruman>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-3-git-send-email-tony@atomide.com>
 <20150113195141.GT16533@saruman>
 <20150113205439.GK2419@atomide.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Qjo19A2vmS5T5MQB"
Cc: Felipe Balbi <balbi@ti.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>,
	"Mark A. Greer" <mgreer@animalcreek.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:53392 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbbAMVEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 16:04:14 -0500
Content-Disposition: inline
In-Reply-To: <20150113205439.GK2419@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Qjo19A2vmS5T5MQB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 13, 2015 at 12:54:40PM -0800, Tony Lindgren wrote:
> * Felipe Balbi <balbi@ti.com> [150113 11:55]:
> > On Tue, Jan 13, 2015 at 11:29:24AM -0800, Tony Lindgren wrote:
> > > --- a/drivers/net/ethernet/ti/davinci_emac.c
> > > +++ b/drivers/net/ethernet/ti/davinci_emac.c
> > > @@ -1538,7 +1538,7 @@ static int emac_dev_open(struct net_device *nde=
v)
> > >  	int i =3D 0;
> > >  	struct emac_priv *priv =3D netdev_priv(ndev);
> > > =20
> > > -	pm_runtime_get(&priv->pdev->dev);
> > > +	pm_runtime_get_sync(&priv->pdev->dev);
> >=20
> > gotta check return value on all pm_runtime_get_sync() calls. IIRC,
> > there's a coccinelle script for checking and patching this.
>=20
> Sure, here's an updated patch with error checking added.
>=20
> Regards,
>=20
> Tony
>=20
> 8< ---------------------
> From: Tony Lindgren <tony@atomide.com>
> Date: Mon, 22 Dec 2014 08:19:06 -0800
> Subject: [PATCH] net: davinci_emac: Fix runtime pm calls for davinci_emac
>=20
> Commit 3ba97381343b ("net: ethernet: davinci_emac: add pm_runtime support=
")
> added support for runtime PM, but it causes issues on omap3 related devic=
es
> that actually gate the clocks:
>=20
> Unhandled fault: external abort on non-linefetch (0x1008)
> ...
> [<c04160f0>] (emac_dev_getnetstats) from [<c04d6a3c>] (dev_get_stats+0x78=
/0xc8)
> [<c04d6a3c>] (dev_get_stats) from [<c04e9ccc>] (rtnl_fill_ifinfo+0x3b8/0x=
938)
> [<c04e9ccc>] (rtnl_fill_ifinfo) from [<c04eade4>] (rtmsg_ifinfo+0x68/0xd8)
> [<c04eade4>] (rtmsg_ifinfo) from [<c04dd35c>] (register_netdevice+0x3a0/0=
x4ec)
> [<c04dd35c>] (register_netdevice) from [<c04dd4bc>] (register_netdev+0x14=
/0x24)
> [<c04dd4bc>] (register_netdev) from [<c041755c>] (davinci_emac_probe+0x40=
8/0x5c8)
> [<c041755c>] (davinci_emac_probe) from [<c0396d78>] (platform_drv_probe+0=
x48/0xa4)
>=20
> Let's fix it by moving the pm_runtime_get() call earlier, and also add it=
 to
> the emac_dev_getnetstats(). Also note that we want to use pm_runtime_get_=
sync()
> as we don't want to have deferred_resume happen. And let's also check the
> return value for pm_runtime_get_sync() as noted by Felipe Balbi <balbi@ti=
=2Ecom>.
>=20
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: Mark A. Greer <mgreer@animalcreek.com>

Reviewed-by: Felipe Balbi <balbi@ti.com>

> Signed-off-by: Tony Lindgren <tony@atomide.com>
>=20
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1538,7 +1538,13 @@ static int emac_dev_open(struct net_device *ndev)
>  	int i =3D 0;
>  	struct emac_priv *priv =3D netdev_priv(ndev);
> =20
> -	pm_runtime_get(&priv->pdev->dev);
> +	ret =3D pm_runtime_get_sync(&priv->pdev->dev);
> +	if (ret < 0) {
> +		pm_runtime_put_noidle(&priv->pdev->dev);
> +		dev_err(&priv->pdev->dev, "%s: failed to get_sync(%d)\n",
> +			__func__, ret);
> +		return ret;
> +	}
> =20
>  	netif_carrier_off(ndev);
>  	for (cnt =3D 0; cnt < ETH_ALEN; cnt++)
> @@ -1725,6 +1731,15 @@ static struct net_device_stats *emac_dev_getnetsta=
ts(struct net_device *ndev)
>  	struct emac_priv *priv =3D netdev_priv(ndev);
>  	u32 mac_control;
>  	u32 stats_clear_mask;
> +	int err;
> +
> +	err =3D pm_runtime_get_sync(&priv->pdev->dev);
> +	if (err < 0) {
> +		pm_runtime_put_noidle(&priv->pdev->dev);
> +		dev_err(&priv->pdev->dev, "%s: failed to get_sync(%d)\n",
> +			__func__, err);
> +		return &ndev->stats;
> +	}
> =20
>  	/* update emac hardware stats and reset the registers*/
> =20
> @@ -1767,6 +1782,8 @@ static struct net_device_stats *emac_dev_getnetstat=
s(struct net_device *ndev)
>  	ndev->stats.tx_fifo_errors +=3D emac_read(EMAC_TXUNDERRUN);
>  	emac_write(EMAC_TXUNDERRUN, stats_clear_mask);
> =20
> +	pm_runtime_put(&priv->pdev->dev);
> +
>  	return &ndev->stats;
>  }
> =20
> @@ -1981,12 +1998,22 @@ static int davinci_emac_probe(struct platform_dev=
ice *pdev)
>  	ndev->ethtool_ops =3D &ethtool_ops;
>  	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_POLL_WEIGHT);
> =20
> +	pm_runtime_enable(&pdev->dev);
> +	rc =3D pm_runtime_get_sync(&pdev->dev);
> +	if (rc < 0) {
> +		pm_runtime_put_noidle(&pdev->dev);
> +		dev_err(&pdev->dev, "%s: failed to get_sync(%d)\n",
> +			__func__, rc);
> +		goto no_cpdma_chan;
> +	}
> +
>  	/* register the network device */
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
>  	rc =3D register_netdev(ndev);
>  	if (rc) {
>  		dev_err(&pdev->dev, "error in register_netdev\n");
>  		rc =3D -ENODEV;
> +		pm_runtime_put(&pdev->dev);
>  		goto no_cpdma_chan;
>  	}
> =20
> @@ -1996,9 +2023,7 @@ static int davinci_emac_probe(struct platform_devic=
e *pdev)
>  			   "(regs: %p, irq: %d)\n",
>  			   (void *)priv->emac_base_phys, ndev->irq);
>  	}
> -
> -	pm_runtime_enable(&pdev->dev);
> -	pm_runtime_resume(&pdev->dev);
> +	pm_runtime_put(&pdev->dev);
> =20
>  	return 0;
> =20

--=20
balbi

--Qjo19A2vmS5T5MQB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtYgeAAoJEIaOsuA1yqREQpwP+wR3rjWN5rT3RXoH0c8dvkR5
ZljF24YaAjaZTHBkGLBzpuol4l/PKsPsUdesbhFc3x10DIXMMJIqWj3zVL1I7Q9a
m+MNnvWNPoXNh2l0UEL8gxNOx+m/1Nn1xBwPZP37Fjow7cqFvCCP5zA+Cpkcgbah
JRVoaEA51UBJcL0ua3yNdM9EZ/0AQl1saU1sik97i4RqhNakpTK1uve+oSJnUllY
7sTAF+TBr+cr72e0kxB7VJgA4INlIoB2YBVCvQypMuEsHZeiUFNiT3VPumJcghAr
3ihH8UiGd5rL5bPyQa7r920WfSAiePl7k9+ivfiizZOIyVS8T+5THgzcJ+aDuNFc
xg4Y5+Zr9FF4pzaxieIeSzJK1NzpIQXxRzUQfSYXKRurylqJX0p11w3LPV1IQUrL
QdxIGCSZp0d4lWvwcw9U2HOUaPRP56If2I670coJhQxkX+SRtftwX0lyTiCez5KC
GtgtXBvbYYJIN4esahFnsYn1E+ScsQvu3AlkXkc7GrI0fhl2inHtclPp15LBbsAs
Ju9gM8u94Iw6iSF6O14yrh3UvbUaAUtktZj+0L/dp0UwQZX6SjvtzTDrSLs54vwR
iQD6V/I+Ce35vc7N/cOaQ5NDlvp4QAlZs4TOlrVszXj/9x59QW35JxXyjx2puefC
78oHD//51EnxGOTfAWzk
=A398
-----END PGP SIGNATURE-----

--Qjo19A2vmS5T5MQB--
