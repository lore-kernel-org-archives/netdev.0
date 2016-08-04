From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 1/1] Add timer to handle OOM situations
Date: Thu, 4 Aug 2016 13:30:44 +0100
Message-ID: <20160804123044.GL14185@stefanha-x1.localdomain>
References: <20160802172326.1220-1-ggarcia@deic.uab.cat>
 <20160802172326.1220-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2OzUYMsT4j3Kc+NU"
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932165AbcHDMas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 08:30:48 -0400
Content-Disposition: inline
In-Reply-To: <20160802172326.1220-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2OzUYMsT4j3Kc+NU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 02, 2016 at 07:23:26PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>

Missing commit description.  From your cover letter:

  Once the guest puts a packet in the virtqueue it is guaranteed
  that it will be delivered.

  This patch addresses the problem of packets being discarded when
  there is not available memory in the host.

>=20
> v3:
>  * Avoid race condition when freeing timer.
>=20
> v2:
> * Use of ERR_PTR/PTR_ERR/IS_ERR
> * Timer cleaned on device release.
> * Do not process more packets on error.
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  drivers/vhost/vsock.c | 52 +++++++++++++++++++++++++++++++++++++++++----=
------
>  1 file changed, 42 insertions(+), 10 deletions(-)

The changelog must be below the '---' to prevent it from being included
in git log.  (The changelog isn't useful once the patch has been
merged.)

>=20
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index 028ca16..8d4fb13 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
> @@ -15,11 +15,13 @@
>  #include <net/sock.h>
>  #include <linux/virtio_vsock.h>
>  #include <linux/vhost.h>
> +#include <linux/timer.h>
> =20
>  #include <net/af_vsock.h>
>  #include "vhost.h"
> =20
>  #define VHOST_VSOCK_DEFAULT_HOST_CID	2
> +#define OOM_RETRY_MS	100
> =20
>  enum {
>  	VHOST_VSOCK_FEATURES =3D VHOST_FEATURES,
> @@ -43,6 +45,8 @@ struct vhost_vsock {
>  	atomic_t queued_replies;
> =20
>  	u32 guest_cid;
> +
> +	struct timer_list tx_kick;
>  };
> =20
>  static u32 vhost_transport_get_local_cid(void)
> @@ -229,12 +233,13 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
> =20
>  	if (in !=3D 0) {
>  		vq_err(vq, "Expected 0 input buffers, got %u\n", in);
> -		return NULL;
> +		return ERR_PTR(-EINVAL);
>  	}
> =20
>  	pkt =3D kzalloc(sizeof(*pkt), GFP_KERNEL);
> -	if (!pkt)
> -		return NULL;
> +	if (!pkt){
> +		return ERR_PTR(-ENOMEM);
> +	}

Kernel coding style omits the curly braces in a single-line if
statement.

--2OzUYMsT4j3Kc+NU
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXozV0AAoJEJykq7OBq3PIEasIALcG/T1e6dweVKpsZuHoJAYS
mJE9K0QGDIDHUeOEV8zL9X3oZ+Cwp+AxzbqAQqkZUqmdaGsL0QO4wo094cwq68/k
uu+vMB9Z2zRSZ640UEPH9e1eat/KqyzjwFfYaUQ4tXXJS1i0EM68yOVhpG589ll8
JtTbWJZGnwfvva/geUa0TWixl1S/W9wSYQRcmUU9O5NSqbVxQYhpwpF0tknl1rv2
FeljTqoWSwDViJHWtoeoqncnuTDvHk4x4zn+2mIudXUYS4CONY4D/qFAYAQioXDJ
r8gqca4KZyPihR5XzbZAO3qP8Y4xs+ct5qTxbJW1PBj5sENMsqC3blw4dNU6HMQ=
=1gad
-----END PGP SIGNATURE-----

--2OzUYMsT4j3Kc+NU--
