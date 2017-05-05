From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 2/2] can: m_can: add deep Suspend/Resume support
Date: Fri, 5 May 2017 14:06:54 +0200
Message-ID: <14d84b69-d65f-fdfd-b41f-7559b4e45c9a@pengutronix.de>
References: <20170505114646.1278-1-quentin.schulz@free-electrons.com>
 <20170505114646.1278-2-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="rUpQNU3s2WvaQqvpoa5RSbN63jot6RNxK"
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net, socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170505114646.1278-2-quentin.schulz@free-electrons.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--rUpQNU3s2WvaQqvpoa5RSbN63jot6RNxK
Content-Type: multipart/mixed; boundary="BJAK1NqM9uwx284n4Rieir6Ba0jANwEiJ";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Quentin Schulz <quentin.schulz@free-electrons.com>, wg@grandegger.com,
 mario.huettel@gmx.net, socketcan@hartkopp.net
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 thomas.petazzoni@free-electrons.com
Message-ID: <14d84b69-d65f-fdfd-b41f-7559b4e45c9a@pengutronix.de>
Subject: Re: [PATCH v3 2/2] can: m_can: add deep Suspend/Resume support
References: <20170505114646.1278-1-quentin.schulz@free-electrons.com>
 <20170505114646.1278-2-quentin.schulz@free-electrons.com>
In-Reply-To: <20170505114646.1278-2-quentin.schulz@free-electrons.com>

--BJAK1NqM9uwx284n4Rieir6Ba0jANwEiJ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 05/05/2017 01:46 PM, Quentin Schulz wrote:
> This adds Power Management deep Suspend/Resume support for Bosch M_CAN
> chip.
>=20
> When entering deep sleep, the clocks are gated, the interrupts are
> disabled. When resuming from deep sleep, the chip needs to be
> reinitialized, the clocks ungated and the interrupts enabled.
>=20
> Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
> ---
>=20
> v3:
>  - do not close/reopen the can interface (which was previously done whe=
n
>  calling m_can_close), basically do the same routine as in probe but
>  it does not close/open the can device,

much better!

>  - update commit log,
>=20
> v2:
>  - fix erroneous commit log,
>=20
>  drivers/net/can/m_can/m_can.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index 3f0445440146..0a06690febe2 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1672,10 +1672,9 @@ static __maybe_unused int m_can_suspend(struct d=
evice *dev)
>  	if (netif_running(ndev)) {
>  		netif_stop_queue(ndev);
>  		netif_device_detach(ndev);
> +		m_can_stop(ndev);
>  	}
> =20
> -	/* TODO: enter low power */
> -
>  	priv->can.state =3D CAN_STATE_SLEEPING;
> =20
>  	return 0;
> @@ -1686,11 +1685,23 @@ static __maybe_unused int m_can_resume(struct d=
evice *dev)
>  	struct net_device *ndev =3D dev_get_drvdata(dev);
>  	struct m_can_priv *priv =3D netdev_priv(ndev);
> =20
> -	/* TODO: exit low power */
> +	m_can_init_ram(priv);
> =20
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
>  	if (netif_running(ndev)) {
> +		int ret =3D clk_prepare_enable(priv->hclk);
> +
> +		if (ret)
> +			return ret;
> +
> +		ret =3D clk_prepare_enable(priv->cclk);
> +		if (ret) {
> +			clk_disable_unprepare(priv->hclk);
> +			return ret;
> +		}
> +
> +		m_can_start(ndev);

Using m_can_stop() m_can_start() here is the way to go. However, when
looking at this hook we se, that the m_can_start/stop functions are not
symmetric (as they should be). Either move the clock handling to
completely in or out of m_can_start/stop.

>  		netif_device_attach(ndev);
>  		netif_start_queue(ndev);
>  	}
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--BJAK1NqM9uwx284n4Rieir6Ba0jANwEiJ--

--rUpQNU3s2WvaQqvpoa5RSbN63jot6RNxK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkMat4ACgkQHv7KIOw4
HPaRKgf7Bq6ASafay2UV7UBIayrkx2k7Oncs4jqKEabiP3LeHyP4PTmiGtogKnZK
fStjxLT37RLDuCWuCSOWe7IDe7ypUh4WadRXjd4JiuztfoWzcbiReWnmLtzppgDC
7MwFRbqufR2gNhZCRMk4CicVGD0LDd66HbDRW/5txQZviVnGXCQCjda+lrY9FoIS
ldVXMBbCAbLpmigRCm87YUHP0rwRZv4UhPlzxXYaDsr/Qu3dYOksdO+QZmm7WU2L
TKU03QUPih+q8Cx3555jT682Xbz6gCnHquLYWob0hGsdNuAeVxQSOTj3STPB9d19
Tzhvv6i9r//QdDBYmdhWYx8aNdXHoQ==
=i5ov
-----END PGP SIGNATURE-----

--rUpQNU3s2WvaQqvpoa5RSbN63jot6RNxK--
