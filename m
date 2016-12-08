From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH v2 4/4] vsock: cancel packets when failing to connect
Date: Thu, 8 Dec 2016 09:24:46 +0000
Message-ID: <20161208092446.GB10780@stefanha-x1.localdomain>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
	<1481123652-80603-5-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8509759705530135674=="
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>,
	kvm@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481123652-80603-5-git-send-email-bergwolf@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============8509759705530135674==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XOIedfhf+7KOe/yw"
Content-Disposition: inline


--XOIedfhf+7KOe/yw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 11:14:12PM +0800, Peng Tao wrote:
> Otherwise we'll leave the packets queued until releasing vsock device.
> E.g., if guest is slow to start up, resulting ETIMEDOUT on connect, guest
> will get the connect requests from failed host sockets.
>=20
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  include/linux/virtio_vsock.h            | 7 +++++++
>  net/vmw_vsock/af_vsock.c                | 7 +++++++
>  net/vmw_vsock/virtio_transport_common.c | 7 -------
>  3 files changed, 14 insertions(+), 7 deletions(-)
>=20
> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
> index b92e88d..ff6850a 100644
> --- a/include/linux/virtio_vsock.h
> +++ b/include/linux/virtio_vsock.h
> @@ -156,4 +156,11 @@ void virtio_transport_inc_tx_pkt(struct virtio_vsock=
_sock *vvs, struct virtio_vs
>  u32 virtio_transport_get_credit(struct virtio_vsock_sock *vvs, u32 wante=
d);
>  void virtio_transport_put_credit(struct virtio_vsock_sock *vvs, u32 cred=
it);
> =20
> +static inline const struct virtio_transport *virtio_transport_get_ops(vo=
id)
> +{
> +	const struct vsock_transport *t =3D vsock_core_get_transport();
> +
> +	return container_of(t, struct virtio_transport, transport);
> +}
> +
>  #endif /* _LINUX_VIRTIO_VSOCK_H */
> diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
> index 8a398b3..ebb50d6 100644
> --- a/net/vmw_vsock/af_vsock.c
> +++ b/net/vmw_vsock/af_vsock.c
> @@ -104,6 +104,7 @@
>  #include <linux/unistd.h>
>  #include <linux/wait.h>
>  #include <linux/workqueue.h>
> +#include <linux/virtio_vsock.h>
>  #include <net/sock.h>
>  #include <net/af_vsock.h>
> =20
> @@ -1105,6 +1106,7 @@ static void vsock_connect_timeout(struct work_struc=
t *work)
>  {
>  	struct sock *sk;
>  	struct vsock_sock *vsk;
> +	int cancel =3D 0;
> =20
>  	vsk =3D container_of(work, struct vsock_sock, dwork.work);
>  	sk =3D sk_vsock(vsk);
> @@ -1115,8 +1117,11 @@ static void vsock_connect_timeout(struct work_stru=
ct *work)
>  		sk->sk_state =3D SS_UNCONNECTED;
>  		sk->sk_err =3D ETIMEDOUT;
>  		sk->sk_error_report(sk);
> +		cancel =3D 1;
>  	}
>  	release_sock(sk);
> +	if (cancel)
> +		virtio_transport_get_ops()->cancel_pkt(vsk);

This doesn't work with the VMCI transport.  Remember af_vsock.c is
common code shared by all transports.

You need to add a struct vsock_transport->cancel_pkt() callback instead
os a struct virtio_transport->cancel_pkt() callback.  And you need to
handle the case where cancel_pkt =3D=3D NULL if you don't implement it for
VMCI.

> =20
>  	sock_put(sk);
>  }
> @@ -1223,11 +1228,13 @@ static int vsock_stream_connect(struct socket *so=
ck, struct sockaddr *addr,
>  			err =3D sock_intr_errno(timeout);
>  			sk->sk_state =3D SS_UNCONNECTED;
>  			sock->state =3D SS_UNCONNECTED;
> +			virtio_transport_get_ops()->cancel_pkt(vsk);
>  			goto out_wait;
>  		} else if (timeout =3D=3D 0) {
>  			err =3D -ETIMEDOUT;
>  			sk->sk_state =3D SS_UNCONNECTED;
>  			sock->state =3D SS_UNCONNECTED;
> +			virtio_transport_get_ops()->cancel_pkt(vsk);
>  			goto out_wait;
>  		}
> =20
> diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virt=
io_transport_common.c
> index cc1eeb5..72c5dff 100644
> --- a/net/vmw_vsock/virtio_transport_common.c
> +++ b/net/vmw_vsock/virtio_transport_common.c
> @@ -25,13 +25,6 @@
>  /* How long to wait for graceful shutdown of a connection */
>  #define VSOCK_CLOSE_TIMEOUT (8 * HZ)
> =20
> -static const struct virtio_transport *virtio_transport_get_ops(void)
> -{
> -	const struct vsock_transport *t =3D vsock_core_get_transport();
> -
> -	return container_of(t, struct virtio_transport, transport);
> -}
> -
>  struct virtio_vsock_pkt *
>  virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
>  			   size_t len,
> --=20
> 2.7.4
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--XOIedfhf+7KOe/yw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSSbeAAoJEJykq7OBq3PIp+kIAIT/QSpqRVkCD+xsEpO44Fb1
DLncLOEDynZqxirhyyQzY/KdYZT0sK2pJt1jMAcBzXefS5xNKWuvZoLMnJGF61BN
Ht9soEqumegxJ/LLDnVURELspzRKhgHK0YEr0ppID9zFtuGU0TGJ/CHahdriBuni
miZ7Ofdp8kW1f/0rPngPFgViIqRHfszE/Wi3zrCWSrNKLWe0tVT6WuN1eJ9Is0R4
KeKo7g0k9YqSYr2Z0ZIhtDoBiJhBghdyZPdNz4mbCVlx3krcLLDSuO+hEIbzpyTG
sXQMqvqU0vfzgBD58E7/84HraE4Ba3A+3g6npohHStqMns+memXPHBli9+BLwRg=
=SVQA
-----END PGP SIGNATURE-----

--XOIedfhf+7KOe/yw--

--===============8509759705530135674==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8509759705530135674==--
