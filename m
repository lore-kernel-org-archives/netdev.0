From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 2/4] VSOCK: Introduce virtio-vsock.ko
Date: Fri, 11 Dec 2015 11:00:28 +0800
Message-ID: <20151211030028.GB6367@stefanha-x1.localdomain>
References: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
 <1449662633-26623-3-git-send-email-stefanha@redhat.com>
 <87io46ov5e.fsf@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p4qYPpj5QlsIQJ0K"
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Matt Benjamin <mbenjamin@redhat.com>,
	Asias He <asias@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	matt.ma@linaro.org
To: Alex =?iso-8859-1?Q?Benn=E9e?= <alex.bennee@linaro.org>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87io46ov5e.fsf@linaro.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--p4qYPpj5QlsIQJ0K
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 10, 2015 at 09:23:25PM +0000, Alex Benn=E9e wrote:
> Stefan Hajnoczi <stefanha@redhat.com> writes:
>=20
> > From: Asias He <asias@redhat.com>
> >
> > VM sockets virtio transport implementation. This module runs in guest
> > kernel.
>=20
> checkpatch warns on a bunch of whitespace/tab issues.

Will fix in the next version.

> > +struct virtio_vsock {
> > +	/* Virtio device */
> > +	struct virtio_device *vdev;
> > +	/* Virtio virtqueue */
> > +	struct virtqueue *vqs[VSOCK_VQ_MAX];
> > +	/* Wait queue for send pkt */
> > +	wait_queue_head_t queue_wait;
> > +	/* Work item to send pkt */
> > +	struct work_struct tx_work;
> > +	/* Work item to recv pkt */
> > +	struct work_struct rx_work;
> > +	/* Mutex to protect send pkt*/
> > +	struct mutex tx_lock;
> > +	/* Mutex to protect recv pkt*/
> > +	struct mutex rx_lock;
>=20
> Further down I got confused by what lock was what and exactly what was
> being protected. If the receive and transmit paths touch separate things
> it might be worth re-arranging the structure to make it clearer, eg:
>=20
>    /* The transmit path is protected by tx_lock */
>    struct mutex tx_lock;
>    struct work_struct tx_work;
>    ..
>    ..
>=20
>    /* The receive path is protected by rx_lock */
>    wait_queue_head_t queue_wait;
>    ..
>    ..
>=20
>  Which might make things a little clearer. Then all the redundant
>  information in the comments can be removed. I don't need to know what
>  is a Virtio device, virtqueue or wait_queue etc as they are implicit in
>  the structure name.

Thanks, that is a nice idea.

> > +	mutex_lock(&vsock->tx_lock);
> > +	while ((ret =3D virtqueue_add_sgs(vq, sgs, out_sg, in_sg, pkt,
> > +					GFP_KERNEL)) < 0) {
> > +		prepare_to_wait_exclusive(&vsock->queue_wait, &wait,
> > +					  TASK_UNINTERRUPTIBLE);
> > +		mutex_unlock(&vsock->tx_lock);
> > +		schedule();
> > +		mutex_lock(&vsock->tx_lock);
> > +		finish_wait(&vsock->queue_wait, &wait);
> > +	}
> > +	virtqueue_kick(vq);
> > +	mutex_unlock(&vsock->tx_lock);
>=20
> What are we protecting with tx_lock here? See comments above about
> making the lock usage semantics clearer.

vq (vsock->vqs[VSOCK_VQ_TX]) is being protected.  Concurrent calls to
virtqueue_add_sgs() are not allowed.

> > +
> > +	return pkt_len;
> > +}
> > +
> > +static struct virtio_transport_pkt_ops virtio_ops =3D {
> > +	.send_pkt =3D virtio_transport_send_pkt,
> > +};
> > +
> > +static void virtio_vsock_rx_fill(struct virtio_vsock *vsock)
> > +{
> > +	int buf_len =3D VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE;
> > +	struct virtio_vsock_pkt *pkt;
> > +	struct scatterlist hdr, buf, *sgs[2];
> > +	struct virtqueue *vq;
> > +	int ret;
> > +
> > +	vq =3D vsock->vqs[VSOCK_VQ_RX];
> > +
> > +	do {
> > +		pkt =3D kzalloc(sizeof(*pkt), GFP_KERNEL);
> > +		if (!pkt) {
> > +			pr_debug("%s: fail to allocate pkt\n", __func__);
> > +			goto out;
> > +		}
> > +
> > +		/* TODO: use mergeable rx buffer */
>=20
> TODO's should end up in merged code.

Will fix in next revision.

> > +		pkt->buf =3D kmalloc(buf_len, GFP_KERNEL);
> > +		if (!pkt->buf) {
> > +			pr_debug("%s: fail to allocate pkt->buf\n", __func__);
> > +			goto err;
> > +		}
> > +
> > +		sg_init_one(&hdr, &pkt->hdr, sizeof(pkt->hdr));
> > +		sgs[0] =3D &hdr;
> > +
> > +		sg_init_one(&buf, pkt->buf, buf_len);
> > +	        sgs[1] =3D &buf;
> > +		ret =3D virtqueue_add_sgs(vq, sgs, 0, 2, pkt, GFP_KERNEL);
> > +		if (ret)
> > +			goto err;
> > +		vsock->rx_buf_nr++;
> > +	} while (vq->num_free);
> > +	if (vsock->rx_buf_nr > vsock->rx_buf_max_nr)
> > +		vsock->rx_buf_max_nr =3D vsock->rx_buf_nr;
> > +out:
> > +	virtqueue_kick(vq);
> > +	return;
> > +err:
> > +	virtqueue_kick(vq);
> > +	virtio_transport_free_pkt(pkt);
>=20
> You could free the pkt memory at the fail site and just have one exit pat=
h.

Okay, I agree the err label is of marginal use.  Let's get rid of it.

>=20
> > +	return;
> > +}
> > +
> > +static void virtio_transport_send_pkt_work(struct work_struct *work)
> > +{
> > +	struct virtio_vsock *vsock =3D
> > +		container_of(work, struct virtio_vsock, tx_work);
> > +	struct virtio_vsock_pkt *pkt;
> > +	bool added =3D false;
> > +	struct virtqueue *vq;
> > +	unsigned int len;
> > +	struct sock *sk;
> > +
> > +	vq =3D vsock->vqs[VSOCK_VQ_TX];
> > +	mutex_lock(&vsock->tx_lock);
> > +	do {
>=20
> You can move the declarations of pkt/len into the do block.

Okay.

>=20
> > +		virtqueue_disable_cb(vq);
> > +		while ((pkt =3D virtqueue_get_buf(vq, &len)) !=3D NULL) {
>=20
> And the sk declaration here

Okay.

> > +static void virtio_transport_recv_pkt_work(struct work_struct *work)
> > +{
> > +	struct virtio_vsock *vsock =3D
> > +		container_of(work, struct virtio_vsock, rx_work);
> > +	struct virtio_vsock_pkt *pkt;
> > +	struct virtqueue *vq;
> > +	unsigned int len;
>=20
> Same as above for pkt, len.

Okay.

> > +	vsock =3D kzalloc(sizeof(*vsock), GFP_KERNEL);
> > +	if (!vsock) {
> > +		ret =3D -ENOMEM;
> > +		goto out;
>=20
> Won't this attempt to kfree a NULL vsock?

kfree(NULL) is a nop so this is safe.

--p4qYPpj5QlsIQJ0K
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWajxMAAoJEJykq7OBq3PIARUH/2+ozsM6kUlwi23aFZTjXcre
aYnnq7MXRSLvzC69EGWR+tQ5Mn6vpcExy3v2G5vmRUaKWntSqhbNSWQ5iW4ssTrP
AYZOGtO68Qi2fYF5I1hAa2qvRzfwZLMutUxTKjtmFiWqjnHOOmzfb6ZQ+WtK+ShP
6Qm12R+n3SXGkRVsABS2Omdyzv4uZ7UpfuhXQmGxlxKCObZVKLhg6ie/k8Ka4e3Q
UtIVmv3khOlR4WjgH7d/6a/Kg/sDh9basE7te7yjcw+An0M+mJDb9zQ7g0p8wTsU
vOhsC1UjHqpdDcgd8AE5gnlV1sZ0VrcWzq9RbbWGwPoZM2HN3JKmbOuPOVZpJ/A=
=gJQ8
-----END PGP SIGNATURE-----

--p4qYPpj5QlsIQJ0K--
