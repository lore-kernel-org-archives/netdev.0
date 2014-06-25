From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: Remodel FlexCAN register read/write APIs for
 BE instances
Date: Wed, 25 Jun 2014 10:27:49 +0200
Message-ID: <53AA8805.3050309@pengutronix.de>
References: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="jSSE1lf9APbGap9fRPKhgaER7aigdwjhs"
Cc: wg@grandegger.com, netdev@vger.kernel.org
To: Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1403625285-27824-1-git-send-email-bhupesh.sharma@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jSSE1lf9APbGap9fRPKhgaER7aigdwjhs
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/24/2014 05:54 PM, Bhupesh Sharma wrote:
> The FlexCAN IP on certain SoCs like (Freescale's LS1021A) is
> modelled in a big-endian fashion, i.e. the registers and the
> message buffers are organized in a BE way.

Do you have any idea, why fsl did this? The messed up the network
controller on the mx28, too. :/

> More details about the LS1021A SoC can be seen here:
> http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=3DLS1021=
A&nodeId=3D018rH325E4017B#

Is there any "real" documentation for this SoC available?

> This patch ensures that the register read/write APIs are remodelled
> to address such cases, while ensuring that existing platforms (where
> the FlexCAN IP was modelled in LE way) do not break.

I'm not sure if it's better to handle this via the DT attributes
big-endian, little-endian, no attribute would mean native endianess for
backwards compatibility.

With this solution, you're breaking all ARM non DT boards, as the struct
platform_device_id still uses fsl_p1010_devtype_data. You're breaking DT
based mx35, as struct of_device_id has no entry for mx35.

With this patch fsl,p1010-flexcan isn't compatible with the imx/mxs any
more, please change the device trees in the kernel.

Please update the "FLEXCAN hardware feature flags" table in the driver
and check if any of the mentioned quirks are needed for the LS1021A.

See comment inline.....

> Signed-off-by: Bhupesh Sharma <bhupesh.sharma@freescale.com>
> ---
> Rebased againt v3.16-rc1
>=20
>  drivers/net/can/flexcan.c |  213 +++++++++++++++++++++++++++----------=
--------
>  1 file changed, 126 insertions(+), 87 deletions(-)
>=20
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index f425ec2..00c4740 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c

[...]

>  static const struct can_bittiming_const flexcan_bittiming_const =3D {
> @@ -237,32 +256,36 @@ static const struct can_bittiming_const flexcan_b=
ittiming_const =3D {
>  };
> =20
>  /*
> - * Abstract off the read/write for arm versus ppc. This
> - * assumes that PPC uses big-endian registers and everything
> - * else uses little-endian registers, independent of CPU
> - * endianess.
> + * FlexCAN module is essentially modelled as a little-endian IP in mos=
t
> + * SoCs, i.e the registers as well as the message buffer areas are
> + * implemented in a little-endian fashion.
> + *
> + * However there are some SoCs (e.g. LS1021A) which implement the Flex=
CAN
> + * module in a big-endian fashion (i.e the registers as well as the
> + * message buffer areas are implemented in a big-endian way).
> + *
> + * In addition, the FlexCAN module can be found on SoCs having ARM or
> + * PPC cores. So, we need to abstract off the register read/write
> + * functions, ensuring that these cater to all the combinations of mod=
ule
> + * endianess and underlying CPU endianess.
>   */
> -#if defined(CONFIG_PPC)
> -static inline u32 flexcan_read(void __iomem *addr)
> +static inline u32 flexcan_read(const struct flexcan_priv *priv,
> +			       void __iomem *addr)
>  {
> -	return in_be32(addr);
> -}
> -
> -static inline void flexcan_write(u32 val, void __iomem *addr)
> -{
> -	out_be32(addr, val);
> -}
> -#else
> -static inline u32 flexcan_read(void __iomem *addr)
> -{
> -	return readl(addr);
> +	if (priv->devtype_data->module_is_big_endian)
> +		return ioread32be(addr);
> +	else
> +		return ioread32(addr);
>  }
> =20
> -static inline void flexcan_write(u32 val, void __iomem *addr)
> +static inline void flexcan_write(const struct flexcan_priv *priv,
> +				 u32 val, void __iomem *addr)
>  {
> -	writel(val, addr);
> +	if (priv->devtype_data->module_is_big_endian)

Please move the devtype_data into the struct flexcan_priv, so that you
don't need a double pointer dereference in the hot path.

> +		iowrite32be(val, addr);
> +	else
> +		iowrite32(val, addr);
>  }
> -#endif

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--jSSE1lf9APbGap9fRPKhgaER7aigdwjhs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOqiAUACgkQjTAFq1RaXHMNsACff8PBzo29bO4DGN6RccikgXd1
THsAnAxAiJii4Nb/oF385zJsuorEbNZk
=Out5
-----END PGP SIGNATURE-----

--jSSE1lf9APbGap9fRPKhgaER7aigdwjhs--
