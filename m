From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v2 1/1] Add timer to handle OOM situations
Date: Fri, 29 Jul 2016 13:20:35 +0100
Message-ID: <20160729122035.GE5443@stefanha-x1.localdomain>
References: <20160726142821.31770-1-ggarcia@deic.uab.cat>
 <20160726142821.31770-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="a+b56+3nqLzpiR9O"
Cc: netdev@vger.kernel.org
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948AbcG2MUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 08:20:38 -0400
Content-Disposition: inline
In-Reply-To: <20160726142821.31770-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--a+b56+3nqLzpiR9O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 26, 2016 at 04:28:21PM +0200, ggarcia@abra.uab.cat wrote:
> @@ -493,6 +524,9 @@ static int vhost_vsock_dev_open(struct inode *inode, =
struct file *file)
>  		goto out;
>  	}
> =20
> +	setup_timer(&vsock->tx_kick,
> +		    vhost_vsock_rehandle_tx_kick, (unsigned long) NULL);
> +
>  	vqs[VSOCK_VQ_TX] =3D &vsock->vqs[VSOCK_VQ_TX];
>  	vqs[VSOCK_VQ_RX] =3D &vsock->vqs[VSOCK_VQ_RX];
>  	vsock->vqs[VSOCK_VQ_TX].handle_kick =3D vhost_vsock_handle_tx_kick;
> @@ -555,6 +589,7 @@ static int vhost_vsock_dev_release(struct inode *inod=
e, struct file *file)
>  	vhost_dev_stop(&vsock->dev);
>  	vhost_dev_cleanup(&vsock->dev, false);
>  	kfree(vsock->dev.vqs);
> +	del_timer(&vsock->tx_kick);

Please use del_timer_sync() so that we know the timer callback has
finished executing if it's racing with us.

Also please figure out the correct ordering of this call so
vhost_poll_queue() doesn't crash if the timer fires while we are
executing vhost_vsock_dev_release().  In other words, vq and vq->poll
must still be alive when we delete the timer, otherwise the callback
could fire an run on a vq that has already been cleaned up by
vhost_vsock_dev_release().

--a+b56+3nqLzpiR9O
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXm0oTAAoJEJykq7OBq3PIbwIH/j+6q+shR0rhnizd8em9pSh7
sym7BUQUmfM5E/YA4sto8BSuUu2cZVQ/bvbBh8L/MTlwssSELEJcmo3ba1NDhqcQ
AWP/zdqnXgLw3Hzqi8q793RAGYMtJ7t1Fhya1vOthJsBR+a0nwzMbPlxlDzzleXe
wSV8QcyZIAaK0E4iXGjzkc8mrBAYQT5i8DGAKo8ytLXPSjva/YF6hJZD0DZHQaxF
WBDhcQXaf/URuWJkYWTFYhdxS0EmHDtFWQzjE4Pc7O3htllBa9UivLhBJhWqy4jI
qB82pI2hQkRWyofPlGgSEq8HusQRBQobHSWiU+pzQFoLb6k33IOjo5zCl0dR4t8=
=T+n7
-----END PGP SIGNATURE-----

--a+b56+3nqLzpiR9O--
