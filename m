From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 2/4] vhost-vsock: add pkt cancel capability
Date: Wed, 7 Dec 2016 13:23:36 +0000
Message-ID: <20161207132336.GA31953@stefanha-x1.localdomain>
References: <1481104821-77294-1-git-send-email-bergwolf@gmail.com>
	<1481104821-77294-3-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8004239315174977118=="
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1481104821-77294-3-git-send-email-bergwolf@gmail.com>
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


--===============8004239315174977118==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Content-Disposition: inline


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 06:00:19PM +0800, Peng Tao wrote:
> To allow canceling all packets of a connection.
>=20
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  drivers/vhost/vsock.c        | 29 +++++++++++++++++++++++++++++
>  include/linux/virtio_vsock.h |  3 +++
>  2 files changed, 32 insertions(+)
>=20
> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
> index a504e2e0..0c23b55 100644
> --- a/drivers/vhost/vsock.c
> +++ b/drivers/vhost/vsock.c
> @@ -218,6 +218,34 @@ vhost_transport_send_pkt(struct virtio_vsock_pkt *pk=
t)
>  	return len;
>  }
> =20
> +static int
> +vhost_transport_cancel_pkt(struct vsock_sock *vsk)
> +{
> +	struct vhost_vsock *vsock;
> +	struct virtio_vsock_pkt *pkt, *n;
> +	LIST_HEAD(freeme);
> +
> +	/* Find the vhost_vsock according to guest context id  */
> +	vsock =3D vhost_vsock_get(vsk->remote_addr.svm_cid);
> +	if (!vsock)
> +		return -ENODEV;
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
> +		list_del(&pkt->list);
> +		virtio_transport_free_pkt(pkt);
> +	}

Please handle queued_replies so we can resume rx if we fall below the
threshold again.

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSA1YAAoJEJykq7OBq3PI0GAH/3BQjk9xlDOoo7c+OrsoXt6b
FawfQ8VemMTyx2jXFy2BmgrAQivTZmNsa4DLL/g267CUKrFYqXKLsMD4IyaxRuhe
MuDzqdkFN1SNvM5SQ5Te/LQ+FEE3Hcw6TFiJJZgQbWA9PvV4SHaYGjeoRWEMBWJ7
56+3ZeW78H1vtBPEBSO/xsis/RRrMfNInKpxlKLXs3Jx76iLmgOtng7gPSdYfGW1
XxS8CIh9NG4y3sLAl51I2zgwRub1W/LZE6Pn3ule+IIbWN/x8C1DqQOnQC4JZzjv
cgY9dKjV5fAuCZZWEjk9DaakeQ9q4VMUQ0fNGjzMhEPAqWc2x4+zbs+YvBTUQgg=
=RfZt
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--

--===============8004239315174977118==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8004239315174977118==--
