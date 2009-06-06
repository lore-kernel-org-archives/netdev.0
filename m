From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH qemu-kvm] Enable UFO on virtio-net/tap devices
Date: Sat, 06 Jun 2009 09:33:51 +0200
Message-ID: <4A2A1BDF.2060402@web.de>
References: <1244247408.1526.174.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig14872A704FF1AE24C188AB3C"
Cc: kvm@vger.kernel.org, herbert.xu@redhat.com, rusty@rustcorp.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:48726 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbZFFHd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 03:33:58 -0400
In-Reply-To: <1244247408.1526.174.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig14872A704FF1AE24C188AB3C
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Sridhar Samudrala wrote:
> Enable UFO on the host tap device if supported and allow setting UFO
> on virtio-net in the guest.
>=20
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>=20
>=20
> diff --git a/hw/virtio-net.c b/hw/virtio-net.c
> index 3c77b99..8a53e27 100644
> --- a/hw/virtio-net.c
> +++ b/hw/virtio-net.c
> @@ -134,7 +134,8 @@ static uint32_t virtio_net_get_features(VirtIODevic=
e *vdev)
>          features |=3D (1 << VIRTIO_NET_F_HOST_TSO6);
>          features |=3D (1 << VIRTIO_NET_F_HOST_ECN);
>          features |=3D (1 << VIRTIO_NET_F_MRG_RXBUF);
> -        /* Kernel can't actually handle UFO in software currently. */
> +       // features |=3D (1 << VIRTIO_NET_F_HOST_UFO);
> +        features |=3D (1 << VIRTIO_NET_F_GUEST_UFO);

Looks like you forgot some development fragments here.

>      }
>  #endif
> =20
> @@ -173,6 +174,7 @@ static void virtio_net_set_features(VirtIODevice *v=
dev, uint32_t features)
>                        (features >> VIRTIO_NET_F_GUEST_CSUM) & 1,
>                        (features >> VIRTIO_NET_F_GUEST_TSO4) & 1,
>                        (features >> VIRTIO_NET_F_GUEST_TSO6) & 1,
> +                      (features >> VIRTIO_NET_F_GUEST_UFO)  & 1,
>                        (features >> VIRTIO_NET_F_GUEST_ECN)  & 1);

So UFO is the last-but-one parameter to the callback...

>  #endif
>  }
> diff --git a/net.c b/net.c
> index 01e31db..e7dbcd0 100644
> --- a/net.c
> +++ b/net.c
> @@ -990,8 +990,13 @@ static int tap_probe_vnet_hdr(int fd)
>  }
> =20
>  #ifdef TUNSETOFFLOAD
> +
> +#ifndef TUN_F_UFO
> +#define TUN_F_UFO	0x10
> +#endif
> +
>  static void tap_set_offload(VLANClientState *vc, int csum, int tso4, i=
nt tso6,
> -			    int ecn)
> +			    int ecn, int ufo)

=2E..or is it the last one?

>  {
>      TAPState *s =3D vc->opaque;
>      unsigned int offload =3D 0;
> @@ -1004,11 +1009,18 @@ static void tap_set_offload(VLANClientState *vc=
, int csum, int tso4, int tso6,
>  	    offload |=3D TUN_F_TSO6;
>  	if ((tso4 || tso6) && ecn)
>  	    offload |=3D TUN_F_TSO_ECN;
> +	if (ufo)
> +	    offload |=3D TUN_F_UFO;
>      }
> =20
> -    if (ioctl(s->fd, TUNSETOFFLOAD, offload) !=3D 0)
> -	fprintf(stderr, "TUNSETOFFLOAD ioctl() failed: %s\n",
> -		strerror(errno));
> +    if (ioctl(s->fd, TUNSETOFFLOAD, offload) !=3D 0) {
> +        /* Try without UFO */
> +        offload &=3D ~TUN_F_UFO;
> +        if (ioctl(s->fd, TUNSETOFFLOAD, offload) !=3D 0) {
> +	    fprintf(stderr, "TUNSETOFFLOAD ioctl() failed: %s\n",
> +	   	strerror(errno));
> +        }
> +    }
>  }
>  #endif /* TUNSETOFFLOAD */
> =20
> @@ -1043,7 +1055,7 @@ static TAPState *net_tap_fd_init(VLANState *vlan,=

>      s->vc->fd_read_raw =3D tap_receive_raw;
>  #ifdef TUNSETOFFLOAD
>      s->vc->set_offload =3D tap_set_offload;
> -    tap_set_offload(s->vc, 0, 0, 0, 0);
> +    tap_set_offload(s->vc, 0, 0, 0, 0, 0);
>  #endif
>      qemu_set_fd_handler2(s->fd, tap_can_send, tap_send, NULL, s);
>      snprintf(s->vc->info_str, sizeof(s->vc->info_str), "fd=3D%d", fd);=

> diff --git a/net.h b/net.h
> index 3d0b6f2..ecfb1f9 100644
> --- a/net.h
> +++ b/net.h
> @@ -11,7 +11,7 @@ typedef struct VLANClientState VLANClientState;
> =20
>  typedef void (NetCleanup) (VLANClientState *);
>  typedef void (LinkStatusChanged)(VLANClientState *);
> -typedef void (SetOffload)(VLANClientState *, int, int, int, int);
> +typedef void (SetOffload)(VLANClientState *, int, int, int, int, int);=

> =20
>  struct VLANClientState {
>      IOReadHandler *fd_read;
>=20

Jan


--------------enig14872A704FF1AE24C188AB3C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAkoqG+cACgkQniDOoMHTA+nRHwCdHCDc0BStlX6D4MmUwvxbczZY
2ZkAnAqZlGuCy5yPoc0pj9XOOqHtx0GK
=H4iJ
-----END PGP SIGNATURE-----

--------------enig14872A704FF1AE24C188AB3C--
