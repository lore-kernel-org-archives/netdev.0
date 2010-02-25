From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCHv2] can: ti hecc module : add platform specific
	initialization callback.
Date: Thu, 25 Feb 2010 19:00:24 +0100
Message-ID: <4B86BAB8.8090603@pengutronix.de>
References: <1267118802-19263-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1409634064=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1267118802-19263-1-git-send-email-srk-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============1409634064==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4833F621162261436612D2CE"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4833F621162261436612D2CE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Sriramakrishnan wrote:
> CAN module on AM3517 requires programming of IO expander as part
> of init sequence - to enable CAN PHY. Added platform specific
> callback to handle phy control(switch on /off).
>=20
> Signed-off-by: Sriramakrishnan <srk-l0cyMroinI0@public.gmane.org>

looks good, just minor nitpicking inline

Cheers, Marc

> ---
> Modified as per review comments received.
>=20
>  drivers/net/can/ti_hecc.c            |   15 ++++++++++++++-
>  include/linux/can/platform/ti_hecc.h |    3 ++-
>  2 files changed, 16 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index df27d82..871a3fe 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -28,9 +28,11 @@
>   *         .mbx_offset             =3D 0x2000,
>   *         .int_line               =3D 0,
>   *         .revision               =3D 1,
> + *         .transceiver_switch     =3D hecc_phy_control,
>   * };
>   *
> - * Please see include/can/platform/ti_hecc.h for description of above =
fields
> + * Please see include/linux/can/platform/ti_hecc.h for description of
> + * above fields.
>   *
>   */
> =20
> @@ -220,6 +222,7 @@ struct ti_hecc_priv {
>  	u32 tx_head;
>  	u32 tx_tail;
>  	u32 rx_next;
> +	void (*transceiver_switch)(int);
>  };
> =20
>  static inline int get_tx_head_mb(struct ti_hecc_priv *priv)
> @@ -317,6 +320,13 @@ static int ti_hecc_set_btc(struct ti_hecc_priv *pr=
iv)
>  	return 0;
>  }
> =20
> +static void ti_hecc_transceiver_switch(const struct ti_hecc_priv *priv=
,
> +					int on)
> +{
> +	if (priv->transceiver_switch)
> +		priv->transceiver_switch(on);
> +}
> +
>  static void ti_hecc_reset(struct net_device *ndev)
>  {
>  	u32 cnt;
> @@ -824,6 +834,7 @@ static int ti_hecc_open(struct net_device *ndev)
>  		return err;
>  	}
> =20
> +	ti_hecc_transceiver_switch(priv, 1);
>  	ti_hecc_start(ndev);
>  	napi_enable(&priv->napi);
>  	netif_start_queue(ndev);
> @@ -840,6 +851,7 @@ static int ti_hecc_close(struct net_device *ndev)
>  	ti_hecc_stop(ndev);
>  	free_irq(ndev->irq, ndev);
>  	close_candev(ndev);
> +	ti_hecc_transceiver_switch(priv, 0);

nitpick: it's not symetric to the _start function.

> =20
>  	return 0;
>  }
> @@ -901,6 +913,7 @@ static int ti_hecc_probe(struct platform_device *pd=
ev)
>  	priv->hecc_ram_offset =3D pdata->hecc_ram_offset;
>  	priv->mbx_offset =3D pdata->mbx_offset;
>  	priv->int_line =3D pdata->int_line;
> +	priv->transceiver_switch =3D pdata->transceiver_switch;
> =20
>  	priv->can.bittiming_const =3D &ti_hecc_bittiming_const;
>  	priv->can.do_set_mode =3D ti_hecc_do_set_mode;
> diff --git a/include/linux/can/platform/ti_hecc.h b/include/linux/can/p=
latform/ti_hecc.h
> index 4688c7b..825bc6a 100644
> --- a/include/linux/can/platform/ti_hecc.h
> +++ b/include/linux/can/platform/ti_hecc.h
> @@ -23,6 +23,7 @@
>   * @mbx_offset:		Mailbox RAM offset
>   * @int_line:		Interrupt line to use - 0 or 1
>   * @version:		version for future use
> + * @transceiver_switch  platform specific callback fn for transceiver =
control
                         ^^
nitpick:
these are spaces, but the other lines use tabs

>   *
>   * Platform data structure to get all platform specific settings.
>   * this structure also accounts the fact that the IP may have differen=
t
> @@ -35,6 +36,6 @@ struct ti_hecc_platform_data {
>  	u32 mbx_offset;
>  	u32 int_line;
>  	u32 version;
> +	void (*transceiver_switch) (int);
>  };
> =20
> -


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig4833F621162261436612D2CE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkuGurwACgkQjTAFq1RaXHNz+gCeKMtqDdkELjAJO8rV1XWUTbev
4ckAoJfY5C5aHI4mJ6eYF4co9j1fRIqf
=jENa
-----END PGP SIGNATURE-----

--------------enig4833F621162261436612D2CE--

--===============1409634064==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1409634064==--
