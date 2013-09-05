From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: pcan_usb_core: fix memory leak on failure paths
 in peak_usb_start()
Date: Thu, 05 Sep 2013 11:33:58 +0200
Message-ID: <52285006.3080303@pengutronix.de>
References: <1378331169-26285-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="WXUl34DclNoQVdp7j29jCx9eeFBpUAvMI"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org,
	"s.grosjean@peak-system.com" <s.grosjean@peak-system.com>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1378331169-26285-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--WXUl34DclNoQVdp7j29jCx9eeFBpUAvMI
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Added Stephane to Cc.

On 09/04/2013 11:46 PM, Alexey Khoroshilov wrote:
> Tx and rx urbs are not deallocated if something goes wrong in peak_usb_=
start().
> The patch fixes error handling to deallocate all the resources.
>=20
> Found by Linux Driver Verification project (linuxtesting.org).
>=20
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Stephane, can you have a look at the patch and give your Acked-by.

Looks good to me.

tnx,
Marc
> ---
>  drivers/net/can/usb/peak_usb/pcan_usb_core.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net=
/can/usb/peak_usb/pcan_usb_core.c
> index a0f647f..0b7a4c3 100644
> --- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> @@ -463,7 +463,7 @@ static int peak_usb_start(struct peak_usb_device *d=
ev)
>  	if (i < PCAN_USB_MAX_TX_URBS) {
>  		if (i =3D=3D 0) {
>  			netdev_err(netdev, "couldn't setup any tx URB\n");
> -			return err;
> +			goto err_tx;
>  		}
> =20
>  		netdev_warn(netdev, "tx performance may be slow\n");
> @@ -472,7 +472,7 @@ static int peak_usb_start(struct peak_usb_device *d=
ev)
>  	if (dev->adapter->dev_start) {
>  		err =3D dev->adapter->dev_start(dev);
>  		if (err)
> -			goto failed;
> +			goto err_adapter;
>  	}
> =20
>  	dev->state |=3D PCAN_USB_STATE_STARTED;
> @@ -481,19 +481,26 @@ static int peak_usb_start(struct peak_usb_device =
*dev)
>  	if (dev->adapter->dev_set_bus) {
>  		err =3D dev->adapter->dev_set_bus(dev, 1);
>  		if (err)
> -			goto failed;
> +			goto err_adapter;
>  	}
> =20
>  	dev->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =20
>  	return 0;
> =20
> -failed:
> +err_adapter:
>  	if (err =3D=3D -ENODEV)
>  		netif_device_detach(dev->netdev);
> =20
>  	netdev_warn(netdev, "couldn't submit control: %d\n", err);
> =20
> +	for (i =3D 0; i < PCAN_USB_MAX_TX_URBS; i++) {
> +		usb_free_urb(dev->tx_contexts[i].urb);
> +		dev->tx_contexts[i].urb =3D NULL;
> +	}
> +err_tx:
> +	usb_kill_anchored_urbs(&dev->rx_submitted);
> +
>  	return err;
>  }
> =20
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--WXUl34DclNoQVdp7j29jCx9eeFBpUAvMI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIoUAYACgkQjTAFq1RaXHPNCQCfQtq3tJfXCkEB9ViuWDiTibpw
SZoAoIBOnhJ8MOMKEPHXq+N9+rhLNt5f
=BFF+
-----END PGP SIGNATURE-----

--WXUl34DclNoQVdp7j29jCx9eeFBpUAvMI--
