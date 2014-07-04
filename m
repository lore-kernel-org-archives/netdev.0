From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 1/1] net: can: Remodel FlexCAN register read/write
 APIs for BE instances
Date: Fri, 04 Jul 2014 15:41:08 +0200
Message-ID: <53B6AEF4.6080301@pengutronix.de>
References: <1404478881-21853-1-git-send-email-bhupesh.sharma@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="fT0H515w4SlkG0r1t2K2DKp6Pn1f9vv6a"
Cc: wg@grandegger.com, netdev@vger.kernel.org
To: Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1404478881-21853-1-git-send-email-bhupesh.sharma@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fT0H515w4SlkG0r1t2K2DKp6Pn1f9vv6a
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/04/2014 03:01 PM, Bhupesh Sharma wrote:
> The FlexCAN IP on certain SoCs like (Freescale's LS1021A) is
> modelled in a big-endian fashion, i.e. the registers and the
> message buffers are organized in a BE way.
>=20
> More details about the LS1021A SoC can be seen here:
> http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=3DLS1021=
A&nodeId=3D018rH325E4017B#
>=20
> This patch ensures that the register read/write APIs are remodelled
> to address such cases, while ensuring that existing platforms (where
> the FlexCAN IP was modelled in LE way) do not break.
>=20
> Tested on LS1021A-QDS board.
>=20
> Signed-off-by: Bhupesh Sharma <bhupesh.sharma@freescale.com>
> ---
> Changes since v1:
> - Addressed Marc's review comments.
> - Also tried on ARM big-endian kernel
>=20
> Rebased against v3.16-rc2

Please use net-next or linux-can-next, but I think this makes no
difference here.

>  drivers/net/can/flexcan.c |  192 +++++++++++++++++++++++++++----------=
--------
>  1 file changed, 114 insertions(+), 78 deletions(-)

I'm missing the DT documentation update.

[...]

		of_property_read_u32(pdev->dev.of_node,
> @@ -1149,6 +1166,25 @@ static int flexcan_probe(struct platform_device =
*pdev)
>  	dev->flags |=3D IFF_ECHO;
> =20
>  	priv =3D netdev_priv(dev);
> +
> +	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
> +		core_is_little =3D false;
> +
> +	if (of_property_read_bool(dev->dev.of_node, "big-endian"))
> +		module_is_little =3D false;
> +
> +	if ((core_is_little && module_is_little) ||
> +	    (!core_is_little && !module_is_little)) {

I think this is broken on PPC, where both core and module are BE. Please
assume native endianess an default, if neither big-endian nor
little-endian is present.

> +		priv->read =3D flexcan_read_le;
> +		priv->write =3D flexcan_write_le;
> +	}
> +
> +	if ((!core_is_little && module_is_little) ||
> +	    (core_is_little && !module_is_little)) {
> +		priv->read =3D flexcan_read_be;
> +		priv->write =3D flexcan_write_be;
> +	}
> +
>  	priv->can.clock.freq =3D clock_freq;
>  	priv->can.bittiming_const =3D &flexcan_bittiming_const;
>  	priv->can.do_set_mode =3D flexcan_set_mode;
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fT0H515w4SlkG0r1t2K2DKp6Pn1f9vv6a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlO2rvQACgkQjTAFq1RaXHOC6QCfdPxxfuNFrMJHl6xsYN2+ECYw
GGAAniJvSgiutiGsUBRrCFtbXpsE9+TO
=VWgF
-----END PGP SIGNATURE-----

--fT0H515w4SlkG0r1t2K2DKp6Pn1f9vv6a--
