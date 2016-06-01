From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC 3/3] vsockmon: Add vsock hooks
Date: Wed, 1 Jun 2016 14:19:13 -0700
Message-ID: <20160601211913.GH15594@stefanha-x1.localdomain>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-4-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgApRN/oydYDdnYz"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbcFAVTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 17:19:17 -0400
Content-Disposition: inline
In-Reply-To: <20160528162907.14809-4-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OgApRN/oydYDdnYz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 28, 2016 at 06:29:07PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  drivers/vhost/vsock.c | 71 +++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 file changed, 71 insertions(+)
>=20
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index 17bfe4e..8fd5125 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
> @@ -14,8 +14,10 @@
>  #include <net/sock.h>
>  #include <linux/virtio_vsock.h>
>  #include <linux/vhost.h>
> +#include <linux/skbuff.h>
> =20
>  #include <net/af_vsock.h>
> +#include <uapi/linux/vsockmon.h>
>  #include "vhost.h"
> =20
>  #define VHOST_VSOCK_DEFAULT_HOST_CID	2
> @@ -45,6 +47,67 @@ struct vhost_vsock {
>  	u32 guest_cid;
>  };
> =20
> +static struct sk_buff *
> +virtio_vsock_pkt_to_skb(struct virtio_vsock_pkt *pkt)
> +{
> +	struct sk_buff *skb;
> +	struct af_vsockmon_hdr *hdr;
> +	void *payload;
> +
> +	u32 skb_len =3D sizeof(struct af_vsockmon_hdr) + pkt->len;
> +
> +	skb =3D alloc_skb(skb_len, GFP_ATOMIC);
> +	if (!skb)
> +		return NULL;
> +
> +	skb_reserve(skb, sizeof(struct af_vsockmon_hdr));
> +
> +	if (pkt->len) {
> +		payload =3D skb_put(skb, pkt->len);
> +		memcpy(payload, pkt->buf, pkt->len);
> +	}
> +
> +	hdr =3D (struct af_vsockmon_hdr *) skb_push(skb, sizeof(*hdr));
> +	hdr->type =3D AF_VSOCK_VIRTIO;
> +
> +	switch(pkt->hdr.op) {
> +		case VIRTIO_VSOCK_OP_REQUEST:
> +		case VIRTIO_VSOCK_OP_RESPONSE:
> +			hdr->g_hdr.op =3D AF_VSOCK_G_OP_CONNECT;
> +			break;
> +		case VIRTIO_VSOCK_OP_RST:
> +		case VIRTIO_VSOCK_OP_SHUTDOWN:
> +			hdr->g_hdr.op =3D AF_VSOCK_G_OP_DISCONNECT;
> +			break;
> +		case VIRTIO_VSOCK_OP_RW:
> +			hdr->g_hdr.op =3D AF_VSOCK_G_OP_PAYLOAD;
> +			break;
> +		case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
> +		case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
> +			hdr->g_hdr.op =3D AF_VSOCK_G_OP_CONTROL;
> +			break;
> +		default:
> +			hdr->g_hdr.op =3D AF_VSOCK_G_OP_UNKNOWN;
> +			break;
> +	}
> +
> +	hdr->g_hdr.src_cid =3D pkt->hdr.src_cid;
> +	hdr->g_hdr.src_port =3D pkt->hdr.src_port;
> +	hdr->g_hdr.dst_cid =3D pkt->hdr.dst_cid;
> +	hdr->g_hdr.dst_port =3D pkt->hdr.dst_port;

Careful with endianness here.  pkt->hdr uses little-endian fields.

> +
> +	hdr->t_hdr.virtio_hdr =3D pkt->hdr;
> +
> +	return skb;
> +}
> +
> +static void vsock_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
> +{
> +	struct sk_buff *skb =3D virtio_vsock_pkt_to_skb(pkt);
> +	if (skb)
> +		vsock_deliver_tap(skb);

vsock_deliver_tap() doesn't take ownership of skb so it is leaked here!

In fact, given that the core vsock code is not skb-based, perhaps the
tap code shouldn't clone at all.  Just take ownership of the skb.  This
avoids the extra allocation and memcpy.

> +}
> +
>  static u32 vhost_transport_get_local_cid(void)
>  {
>  	return VHOST_VSOCK_DEFAULT_HOST_CID;
> @@ -147,6 +210,11 @@ vhost_transport_do_send_pkt(struct vhost_vsock *vsoc=
k,
> =20
>  		vsock->total_tx_buf -=3D pkt->len;
> =20
> +		/* Deliver to monitoring devices all correctly transmitted
> +		 * packets.
> +		 */
> +		vsock_deliver_tap_pkt(pkt);
> +
>  		virtio_transport_free_pkt(pkt);
>  	}
>  	if (added)
> @@ -367,6 +435,9 @@ static void vhost_vsock_handle_tx_kick(struct vhost_w=
ork *work)
>  			continue;
>  		}
> =20
> +		/* Deliver to monitoring devices all received packets */
> +		vsock_deliver_tap_pkt(pkt);
> +
>  		/* Only accept correctly addressed packets */
>  		if (le64_to_cpu(pkt->hdr.src_cid) =3D=3D vsock->guest_cid)
>  			virtio_transport_recv_pkt(pkt);
> --=20
> 2.8.3
>=20

--OgApRN/oydYDdnYz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXT1FRAAoJEJykq7OBq3PINhEH/0fOIe98BHez07eE2S1SQx8m
nPW3lBh2EUo956teupeOhnVF7JLT9gX56kieZ/NPR6/k8+gagE53yaTAqtnNr42q
mmhqfOAc+DQzO0kG+Owo9ZsjB9CCQNzHwyiAITS+cjoOwn3PyB1/urX1mU2O9PKo
tsLbNSbXxYy5uRXzIFyoXG4iDNIsQL/QEzPSUmECuAyb6itFwbyU/bpiTnkyGSEe
1P2K/kvHFvKL/uBpbfWS1QukZsfKq9Ygk5t3IxI2wuCPehJKa4XCG1tc7ANSznlG
EvqQfcP0y6N+tMu/6TRGqe5xt6GlW2NK7zOS3RwcMUrm5DtKNwYp2fu/PyYHISU=
=EUGW
-----END PGP SIGNATURE-----

--OgApRN/oydYDdnYz--
