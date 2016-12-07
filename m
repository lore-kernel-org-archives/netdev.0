From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 3/4] vsock: add pkt cancel capability
Date: Wed, 7 Dec 2016 13:22:06 +0000
Message-ID: <20161207132206.GC31552@stefanha-x1.localdomain>
References: <1481104821-77294-1-git-send-email-bergwolf@gmail.com>
	<1481104821-77294-4-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7506902557732192408=="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481104821-77294-4-git-send-email-bergwolf@gmail.com>
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


--===============7506902557732192408==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bKyqfOwhbdpXa4YI"
Content-Disposition: inline


--bKyqfOwhbdpXa4YI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 06:00:20PM +0800, Peng Tao wrote:
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  net/vmw_vsock/virtio_transport.c | 36 ++++++++++++++++++++++++++++++++++=
++
>  1 file changed, 36 insertions(+)
>=20
> diff --git a/net/vmw_vsock/virtio_transport.c b/net/vmw_vsock/virtio_tran=
sport.c
> index 936d7ee..f88b6ed 100644
> --- a/net/vmw_vsock/virtio_transport.c
> +++ b/net/vmw_vsock/virtio_transport.c
> @@ -170,6 +170,41 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *p=
kt)
>  	return len;
>  }
> =20
> +static int
> +virtio_transport_cancel_pkt(struct vsock_sock *vsk)
> +{
> +	struct virtio_vsock *vsock;
> +	struct virtio_vsock_pkt *pkt, *n;
> +	int cnt =3D 0;
> +	LIST_HEAD(freeme);
> +
> +	vsock =3D virtio_vsock_get();
> +	if (!vsock) {
> +		return -ENODEV;
> +	}
> +
> +	if (pkt->reply)

pkt is uninitialized.  I guess this if statement should be deleted, you
already take care of counting reply packets below.

> +		cnt++;
> +
> +	spin_lock_bh(&vsock->send_pkt_list_lock);
> +	list_for_each_entry_safe(pkt, n, &vsock->send_pkt_list, list) {
> +		if (pkt->vsk !=3D vsk)
> +			continue;
> +		list_move(&pkt->list, &freeme);
> +	}
> +	spin_unlock_bh(&vsock->send_pkt_list_lock);
> +
> +	list_for_each_entry_safe(pkt, n, &freeme, list) {
> +		if (pkt->reply)
> +			cnt++;
> +		list_del(&pkt->list);
> +		virtio_transport_free_pkt(pkt);
> +	}
> +	atomic_sub(cnt, &vsock->queued_replies);

If we stopped rx because there were too many replies in flight then we
might be able to resume rx now:

/* Do we now have resources to resume rx processing? */
if (old_val >=3D virtqueue_get_vring_size(rx_vq) &&
    new_val < virtqueue_get_vring_size(rx_vq))
	queue_work(virtio_vsock_workqueue, &vsock->rx_work);

--bKyqfOwhbdpXa4YI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSAz+AAoJEJykq7OBq3PIGdAH/0tbXkMHOc3NpLHr6VvOZMvQ
ciZAzQoqwLW0gmEHL1hsZgAuHw4hobW813iSMDFHlOCy/lYz3wvvW/8dpcAm4mS8
VhRmF0sZs4vZ7EmKUwtyJFJ4BNIToW+UfPQ6L4Xe/ABSmaZsFnT/k6TXl7MgsNzv
+kdg1YOCYRQyHEUsJi0ZbJ10N+g11hhyrf1JM0wGjjAAr7s5UqK+R/N8vRWu1LAN
c3jc6qSgbOgHLKuKMVfjPjSK+2UKsSup8oH/DCRdLSqCzk5NEwV2EJfhbDyhx3I7
9PsuH0jbKK/5Dukkx8O4yix9p993xEdPz5P20NdMUvbohuoeBr5nbKT5VR3pr8Y=
=uNTh
-----END PGP SIGNATURE-----

--bKyqfOwhbdpXa4YI--

--===============7506902557732192408==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============7506902557732192408==--
