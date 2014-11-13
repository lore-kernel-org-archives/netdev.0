From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v5 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Thu, 13 Nov 2014 17:03:45 +0100
Message-ID: <5464D661.7080505@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <5464CCFF.5010004@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="fs1NdbNEJ87RHFRqEdxWW79S520rud0k8"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5464CCFF.5010004@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fs1NdbNEJ87RHFRqEdxWW79S520rud0k8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2014 04:23 PM, Roger Quadros wrote:
> DRA7 CAN IP suffers from a problem which causes it to be prevented
> from fully turning OFF (i.e. stuck in transition) if the module was
> disabled while there was traffic on the CAN_RX line.
>=20
> To work around this issue we select the SLEEP pin state by default
> on probe and use the DEFAULT pin state on CAN up and back to the
> SLEEP pin state on CAN down.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  drivers/net/can/c_can/c_can.c | 37 +++++++++++++++++++++++++++++++++++=
++
>  drivers/net/can/c_can/c_can.h |  1 +
>  2 files changed, 38 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> index 8e78bb4..c80cb3d 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -35,6 +35,7 @@
>  #include <linux/list.h>
>  #include <linux/io.h>
>  #include <linux/pm_runtime.h>
> +#include <linux/pinctrl/consumer.h>
> =20
>  #include <linux/can.h>
>  #include <linux/can/dev.h>
> @@ -587,6 +588,21 @@ static int c_can_chip_config(struct net_device *de=
v)
>  	return c_can_set_bittiming(dev);
>  }
> =20
> +/*
> + * Selects the pinctrl state specified in the name.
> + */
> +static void c_can_pinctrl_select_state(struct c_can_priv *priv,
> +				      const char *name)
> +{
> +	if (!IS_ERR(priv->pinctrl)) {
> +		struct pinctrl_state *s;
> +
> +		s =3D pinctrl_lookup_state(priv->pinctrl, name);
> +		if (!IS_ERR(s))
> +			pinctrl_select_state(priv->pinctrl, s);
> +	}
> +}
> +
>  static int c_can_start(struct net_device *dev)
>  {
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> @@ -603,6 +619,8 @@ static int c_can_start(struct net_device *dev)
> =20
>  	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
> +	/* activate pins */
> +	c_can_pinctrl_select_state(priv, PINCTRL_STATE_DEFAULT);
>  	return 0;
>  }
> =20
> @@ -611,6 +629,9 @@ static void c_can_stop(struct net_device *dev)
>  	struct c_can_priv *priv =3D netdev_priv(dev);
> =20
>  	c_can_irq_control(priv, false);
> +
> +	/* deactivate pins */
> +	c_can_pinctrl_select_state(priv, PINCTRL_STATE_SLEEP);
>  	priv->can.state =3D CAN_STATE_STOPPED;
>  }
> =20
> @@ -1244,6 +1265,22 @@ int register_c_can_dev(struct net_device *dev)
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	int err;
> =20
> +	priv->pinctrl =3D devm_pinctrl_get(dev->dev.parent);

What's dev->dev.parent?
Ah, this is set by SET_NETDEV_DEV(dev, &pdev->dev); Good work!

I thought we had to set priv->pinctrl in the platform.c.

> +	if (!IS_ERR(priv->pinctrl)) {
> +		struct pinctrl_state *s;
> +
> +		/* Deactivate pins to prevent DRA7 DCAN IP from being
> +		 * stuck in transition when module is disabled.
> +		 * Pins are activated in c_can_start() and deactivated
> +		 * in c_can_stop()
> +		 */
> +		s =3D pinctrl_lookup_state(priv->pinctrl, PINCTRL_STATE_SLEEP);
> +		if (!IS_ERR(s))
> +			pinctrl_select_state(priv->pinctrl, s);
> +	} else {
> +		netdev_dbg(dev, "failed to get pinctrl\n");
> +	}
> +
The above can be replace by this?

	c_can_pinctrl_select_state(priv, PINCTRL_STATE_SLEEP)

Then we don't have the worrying looking error message if there isn't any
pinctrl, e.g. for the PCI driver with pinctrl enabled in the Kernel.

I just stumbled over pinctrl_pm_select_sleep_state(), is it possible to
integrate this into runtime pm?

http://lxr.free-electrons.com/source/drivers/pinctrl/core.c#L1282

>  	c_can_pm_runtime_enable(priv);
> =20
>  	dev->flags |=3D IFF_ECHO;	/* we support local echo */
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index c6715ca..3cedf48 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -210,6 +210,7 @@ struct c_can_priv {
>  	u32 comm_rcv_high;
>  	u32 rxmasked;
>  	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
> +	struct pinctrl *pinctrl;
>  };
> =20
>  struct net_device *alloc_c_can_dev(void);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--fs1NdbNEJ87RHFRqEdxWW79S520rud0k8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZNZhAAoJECte4hHFiupUNrgP/jLcYc14YyaicO46SCACijPe
oohLxBL6kjwLTRsK27BU3INxg8LEI8acW0kQd/xiafwZWN89JqZY3seyFKcs3PFL
RU5kXmTfXWN5bi8KAAJIxPHpmuab1H0ZT851l+ZE5Fyxys7bVh7XYt9OoatmXZRR
orpb6NjqyvooZ+UhSBpP+V9nSlJx/VddPJjgbgRFjRlnAnOtnNXqAiG4qZwDiTWq
tvawMqGBBoxk6M6FkA2XGXWT5xUCv8NqnCm7gXFAp2vROfJmX1+rjM8Jsp4xSzod
DaKY+LOHsFuO7OqVWvoIfwbOqUSE/0+KyO1Tr5UIO2Y6ytEX+28qhPRTIZXi1ILp
Y9sSOT/NVCg/pS0EyujMKM5k5k7ESvkYKakOV1iAds3fAVQdXZLKJBpnvjhNMw3K
dY6HEbg4wHFsqSbUia//Ia6lDLXfwZ6uK8QFsswwG5MKzWLzk6u64wmnIn4+49fS
znh9Dcgins3vwLk4PY5dqcKt0yawhnxFi0kmr9B+kOK2SgPZWCCdf8sBwy6Ie0NV
VNMwb3OK7y1ne+JGDM8km8Q+hbzTJB7zyrrkiJe1cEH38OhLFzI5EfPXlqrnOBWw
4ThWQ7QqFqxV9IvkQEYu+R2kyjE8bZvNo/VDoRhgIYSdMbdEhGTi0MCX7zR6c3s1
/Hs63uP+Y/lIHnlHzqRP
=ODCb
-----END PGP SIGNATURE-----

--fs1NdbNEJ87RHFRqEdxWW79S520rud0k8--
