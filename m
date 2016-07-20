From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] Add timer to handle OOM situations
Date: Wed, 20 Jul 2016 10:36:45 +0100
Message-ID: <20160720093645.GG13233@stefanha-x1.localdomain>
References: <20160718151103.15076-1-ggarcia@deic.uab.cat>
 <20160718151103.15076-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KR/qxknboQ7+Tpez"
Cc: netdev@vger.kernel.org
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37291 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157AbcGTLcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 07:32:08 -0400
Content-Disposition: inline
In-Reply-To: <20160718151103.15076-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KR/qxknboQ7+Tpez
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 18, 2016 at 05:11:03PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Better testing support files
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  drivers/vhost/vsock.c | 52 +++++++++++++++++++++++++++++++++++++++++++++=
+-----
>  1 file changed, 47 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index 17bfe4e..d746454 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
> @@ -14,11 +14,13 @@
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
> @@ -43,8 +45,12 @@ struct vhost_vsock {
>  	u32 total_tx_buf;
> =20
>  	u32 guest_cid;
> +
> +	struct timer_list tx_kick;
>  };
> =20
> +
> +
>  static u32 vhost_transport_get_local_cid(void)
>  {
>  	return VHOST_VSOCK_DEFAULT_HOST_CID;
> @@ -273,7 +279,8 @@ vhost_transport_send_pkt(struct vsock_sock *vsk,
> =20
>  static struct virtio_vsock_pkt *
>  vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
> -		      unsigned int out, unsigned int in)
> +		      unsigned int out, unsigned int in,
> +		      int *error)

You can use <linux/err.h> ERR_PTR(errno) and IS_ERR(ptr)/PTR_ERR()
instead of adding int *error.

>  {
>  	struct virtio_vsock_pkt *pkt;
>  	struct iov_iter iov_iter;
> @@ -282,12 +289,15 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
> =20
>  	if (in !=3D 0) {
>  		vq_err(vq, "Expected 0 input buffers, got %u\n", in);
> +		*error =3D -EINVAL;
>  		return NULL;
>  	}
> =20
>  	pkt =3D kzalloc(sizeof(*pkt), GFP_KERNEL);
> -	if (!pkt)
> +	if (!pkt){
> +		*error =3D -ENOMEM;
>  		return NULL;
> +	}
> =20
>  	len =3D iov_length(vq->iov, out);
>  	iov_iter_init(&iov_iter, WRITE, vq->iov, out, len);
> @@ -297,6 +307,7 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
>  		vq_err(vq, "Expected %zu bytes for pkt->hdr, got %zu bytes\n",
>  		       sizeof(pkt->hdr), nbytes);
>  		kfree(pkt);
> +		*error =3D -EINVAL;
>  		return NULL;
>  	}
> =20
> @@ -310,12 +321,14 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
>  	/* The pkt is too big */
>  	if (pkt->len > VIRTIO_VSOCK_MAX_PKT_BUF_SIZE) {
>  		kfree(pkt);
> +		*error =3D -EINVAL;
>  		return NULL;
>  	}
> =20
>  	pkt->buf =3D kmalloc(pkt->len, GFP_KERNEL);
>  	if (!pkt->buf) {
>  		kfree(pkt);
> +		*error =3D -ENOMEM;
>  		return NULL;
>  	}
> =20
> @@ -324,6 +337,7 @@ vhost_vsock_alloc_pkt(struct vhost_virtqueue *vq,
>  		vq_err(vq, "Expected %u byte payload, got %zu bytes\n",
>  		       pkt->len, nbytes);
>  		virtio_transport_free_pkt(pkt);
> +		*error =3D -EINVAL;
>  		return NULL;
>  	}
> =20
> @@ -340,6 +354,7 @@ static void vhost_vsock_handle_tx_kick(struct vhost_w=
ork *work)
>  	int head;
>  	unsigned int out, in;
>  	bool added =3D false;
> +	int error;
> =20
>  	mutex_lock(&vq->mutex);
> =20
> @@ -361,10 +376,27 @@ static void vhost_vsock_handle_tx_kick(struct vhost=
_work *work)
>  			break;
>  		}
> =20
> -		pkt =3D vhost_vsock_alloc_pkt(vq, out, in);
> +		pkt =3D vhost_vsock_alloc_pkt(vq, out, in, &error);
> +
>  		if (!pkt) {
> -			vq_err(vq, "Faulted on pkt\n");
> -			continue;
> +			if (error =3D=3D -ENOMEM) {
> +				vhost_discard_vq_desc(vq, 1);
> +
> +				if (!timer_pending(&vsock->tx_kick)) {
> +					vsock->tx_kick.data =3D
> +						(unsigned long) vq;
> +					vsock->tx_kick.expires =3D
> +						jiffies + msecs_to_jiffies(OOM_RETRY_MS);
> +					add_timer(&vsock->tx_kick);
> +				}
> +
> +				break;
> +			} else {
> +				vq_err(vq, "Faulted on pkt\n");
> +				continue;

Please change continue to break (like drivers/vhost/net.c).  Let's not
process packets after an invalid one.

> +			}
> +		} else if (unlikely(timer_pending(&vsock->tx_kick))) {
> +			del_timer(&vsock->tx_kick);
>  		}
> =20
>  		/* Only accept correctly addressed packets */
> @@ -383,6 +415,13 @@ out:
>  	mutex_unlock(&vq->mutex);
>  }
> =20
> +static void vhost_vsock_rehandle_tx_kick(unsigned long data)
> +{
> +	struct vhost_virtqueue *vq =3D (struct vhost_virtqueue *) data;
> +
> +	vhost_poll_queue(&vq->poll);
> +}
> +
>  static void vhost_vsock_handle_rx_kick(struct vhost_work *work)
>  {
>  	struct vhost_virtqueue *vq =3D container_of(work, struct vhost_virtqueu=
e,
> @@ -493,6 +532,9 @@ static int vhost_vsock_dev_open(struct inode *inode, =
struct file *file)
>  		goto out;
>  	}
> =20
> +	setup_timer(&vsock->tx_kick,
> +		    vhost_vsock_rehandle_tx_kick, (unsigned long) NULL);
> +

Where is the timer deleted when the vhost_vsock instance is released?

--KR/qxknboQ7+Tpez
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXj0YtAAoJEJykq7OBq3PIY6EIAKHd1Y116Jd3sWn6xp+uD6eH
xLgewbdNX5IvJNXRsrQqcxTzhu1EUtGwa3pgBzBkEKYU1X0CNqvIWdCm19cKAWm4
h4wwpbE783iQC9U1tZWWGyMKrlV0h5Nia76YIcZAJUOxpdnu4XWfUUPDnvYR4YST
ptM0WvORfXvwJ6QYBUK2Ra0wAb8uwJmHX3UowtM3AqQuPd1Tzbnp2uFzYoXFomRo
CBxP5EyI7XebGFcIySYdEj7pQJTZypOKpSEfzB+Gpm+jlSEB1Wn+t1uyPw3aCQFS
WZ/lzF+MliLp3v2inZwNJ3YhoBxVVHvYtl59M4BFH/mN91A3MOwZA/oqlQTHbjM=
=CC5m
-----END PGP SIGNATURE-----

--KR/qxknboQ7+Tpez--
