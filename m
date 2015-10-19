From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net, can, ti_hecc: add DT support for the ti,hecc
 controller
Date: Mon, 19 Oct 2015 08:58:25 +0200
Message-ID: <56249491.4020009@pengutronix.de>
References: <1445236757-29019-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="p1uWq4Evi3qj038ALsUrBtN0U5RiJ8WAh"
Cc: =?UTF-8?Q?Beno=c3=aet_Cousson?= <bcousson@baylibre.com>,
	Anant Gole <anantgole@ti.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-omap@vger.kernel.org, anton.a.glukhov@gmail.com
To: Heiko Schocher <hs@denx.de>, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1445236757-29019-1-git-send-email-hs@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--p1uWq4Evi3qj038ALsUrBtN0U5RiJ8WAh
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/19/2015 08:39 AM, Heiko Schocher wrote:
> add DT support for the ti hecc controller, used on
> am3517 SoCs.

A similar patch was posted a few days ago, see
http://comments.gmane.org/gmane.linux.can/8616 and my comments.

Please coordinate with Anton Glukhov (Cc'ed) and/or pick up his patches
as they are in better shape.

Marc
>=20
> Signed-off-by: Heiko Schocher <hs@denx.de>
> ---
>=20
>  .../devicetree/bindings/net/can/ti_hecc-can.txt    | 20 ++++++++++
>  arch/arm/boot/dts/am3517.dtsi                      | 13 +++++++
>  drivers/net/can/ti_hecc.c                          | 45 ++++++++++++++=
+++++++-
>  3 files changed, 76 insertions(+), 2 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/can/ti_hecc-c=
an.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt =
b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
> new file mode 100644
> index 0000000..09fab59
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/ti_hecc-can.txt
> @@ -0,0 +1,20 @@
> +* TI HECC CAN *
> +
> +Required properties:
> +  - compatible: Should be "ti,hecc"

We usually put the name of the first SoC this IP core appears in to the
compatible.

> +  - reg: Should contain CAN controller registers location and length
> +  - interrupts: Should contain IRQ line for the CAN controller

I'm missing the description of the ti,* properties. I think they are
required, too. Although the code doesn't enforce it.

> +
> +Example:
> +
> +	can0: hecc@5c050000 {
> +		compatible =3D "ti,hecc";
> +		reg =3D <0x5c050000 0x4000>;
> +		interrupts =3D <24>;
> +		ti,hecc_scc_offset =3D <0>;
> +		ti,hecc_scc_ram_offset =3D <0x3000>;
> +		ti,hecc_ram_offset =3D <0x3000>;
> +		ti,hecc_mbx_offset =3D <0x2000>;
> +		ti,hecc_int_line =3D <0>;
> +		ti,hecc_version =3D <1>;

Versioning in the OF world is done via the compatible. Are the offsets a
per SoC parameter? I'm not sure if it's better to put
the offsets into the driver.

> +	};
> diff --git a/arch/arm/boot/dts/am3517.dtsi b/arch/arm/boot/dts/am3517.d=
tsi
> index 5e3f5e8..47bc429 100644
> --- a/arch/arm/boot/dts/am3517.dtsi
> +++ b/arch/arm/boot/dts/am3517.dtsi
> @@ -25,6 +25,19 @@
>  			interrupt-names =3D "mc";
>  		};
> =20
> +		can0: hecc@5c050000 {
> +			compatible =3D "ti,hecc";
> +			reg =3D <0x5c050000 0x4000>;
> +			interrupts =3D <24>;
> +			ti,hecc_scc_offset =3D <0>;
> +			ti,hecc_scc_ram_offset =3D <0x3000>;
> +			ti,hecc_ram_offset =3D <0x3000>;
> +			ti,hecc_mbx_offset =3D <0x2000>;
> +			ti,hecc_int_line =3D <0>;
> +			ti,hecc_version =3D <1>;
> +			status =3D "disabled";
> +		};
> +
>  		davinci_emac: ethernet@0x5c000000 {
>  			compatible =3D "ti,am3517-emac";
>  			ti,hwmods =3D "davinci_emac";
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index c08e8ea..f1705d5 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -875,16 +875,56 @@ static const struct net_device_ops ti_hecc_netdev=
_ops =3D {
>  	.ndo_change_mtu		=3D can_change_mtu,
>  };
> =20
> +#if defined(CONFIG_OF)
> +static const struct of_device_id ti_hecc_can_dt_ids[] =3D {
> +	{
> +		.compatible =3D "ti,hecc",
> +	}, {
> +		/* sentinel */
> +	}
> +};
> +MODULE_DEVICE_TABLE(of, ti_hecc_can_dt_ids);
> +#endif

Please remove the ifdef, use __maybe_unused instead.

> +
> +static const struct ti_hecc_platform_data
> +*ti_hecc_can_get_driver_data(struct platform_device *pdev)
> +{
> +	if (pdev->dev.of_node) {
> +		struct ti_hecc_platform_data *data;
> +		struct device_node *np =3D pdev->dev.of_node;
> +
> +		data =3D devm_kzalloc(&pdev->dev, sizeof(*data), GFP_KERNEL);
> +		if (!data)
> +			return NULL;
> +
> +		of_property_read_u32(np, "ti,hecc_scc_offset",
> +				     &data->scc_hecc_offset);
> +		of_property_read_u32(np, "ti,hecc_scc_ram_offset",
> +				     &data->scc_ram_offset);
> +		of_property_read_u32(np, "ti,hecc_ram_offset",
> +				     &data->hecc_ram_offset);
> +		of_property_read_u32(np, "ti,hecc_mbx_offset",
> +				     &data->mbx_offset);
> +		of_property_read_u32(np, "ti,hecc_int_line",
> +				     &data->int_line);
> +		of_property_read_u32(np, "ti,hecc_version",
> +				     &data->version);

I'm missing error handling here.

> +		return data;
> +	}
> +	return (const struct ti_hecc_platform_data *)
> +		dev_get_platdata(&pdev->dev);

Is this cast needed?

> +}
> +
>  static int ti_hecc_probe(struct platform_device *pdev)
>  {
>  	struct net_device *ndev =3D (struct net_device *)0;
>  	struct ti_hecc_priv *priv;
> -	struct ti_hecc_platform_data *pdata;
> +	const struct ti_hecc_platform_data *pdata;
>  	struct resource *mem, *irq;
>  	void __iomem *addr;
>  	int err =3D -ENODEV;
> =20
> -	pdata =3D dev_get_platdata(&pdev->dev);
> +	pdata =3D ti_hecc_can_get_driver_data(pdev);
>  	if (!pdata) {
>  		dev_err(&pdev->dev, "No platform data\n");
>  		goto probe_exit;
> @@ -1040,6 +1080,7 @@ static int ti_hecc_resume(struct platform_device =
*pdev)
>  static struct platform_driver ti_hecc_driver =3D {
>  	.driver =3D {
>  		.name    =3D DRV_NAME,
> +		.of_match_table =3D of_match_ptr(ti_hecc_can_dt_ids),
>  	},
>  	.probe =3D ti_hecc_probe,
>  	.remove =3D ti_hecc_remove,
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--p1uWq4Evi3qj038ALsUrBtN0U5RiJ8WAh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWJJSRAAoJEP5prqPJtc/HxakH/iz7POV7HgWhLljALyZG/VlC
ZwQb9kxyrcutiUzYSf8DCP2q8gqYXwFuzruM/9qWGrIumDspD6ZitGMIABm+nLSC
7ZnFkPIyP4rhkhFkdxyJvXzKxkaZyZmzv7Eev83xT8Py3NUvaB16AEVE1s0EZtww
sSh6ArHS/w3MAJqmHhkzve2OGmpf2lP+qS1Rjcuuyfd/NuJQsCc7eGk34NMeIPZ+
z0Ui/RRxJoiUvJoP1MkLYysfBJAxo/6X7g+k66hzTRWLlAOwMi3SYid+VTa+CkZE
kzTDejrqldqMBLLXWtAub4LtknnTOsxy56hjJlsUcaeZiLuL++cBvbGJlFDoMyc=
=Ygta
-----END PGP SIGNATURE-----

--p1uWq4Evi3qj038ALsUrBtN0U5RiJ8WAh--
