From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v3 3/4] VSOCK: Introduce vhost-vsock.ko
Date: Tue, 15 Dec 2015 15:47:00 +0800
Message-ID: <20151215074700.GC30291@stefanha-x1.localdomain>
References: <1449662633-26623-1-git-send-email-stefanha@redhat.com>
 <1449662633-26623-4-git-send-email-stefanha@redhat.com>
 <87h9jpp092.fsf@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FsscpQKzF/jJk6ya"
Cc: kvm@vger.kernel.org, Matt Benjamin <mbenjamin@redhat.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	matt.ma@linaro.org, virtualization@lists.linux-foundation.org,
	Asias He <asias@redhat.com>
To: Alex =?iso-8859-1?Q?Benn=E9e?= <alex.bennee@linaro.org>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87h9jpp092.fsf@linaro.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FsscpQKzF/jJk6ya
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 11, 2015 at 01:45:29PM +0000, Alex Benn=E9e wrote:
> > +		if (head =3D=3D vq->num) {
> > +			if (unlikely(vhost_enable_notify(&vsock->dev, vq))) {
> > +				vhost_disable_notify(&vsock->dev, vq);
> > +				continue;
>=20
> Why are we doing this? If we enable something we then disable it? A
> comment as to what is going on here would be useful.

This is a standard optimization to avoid vmexits that other vhost
devices and QEMU implement too.

When the host begins pulling buffers off a virtqueue it first disables
guest->host notifications.  If the guest adds additional buffers while
the host is processing, the notification (vmexit) is skipped.  The host
re-enables guest->host notifications when it finishes virtqueue
processing.

If the guest added buffers after vhost_get_vq_desc() but before
vhost_enable_notify(), then vhost_enable_notify() returns true and the
host must process the buffers (i.e. restart the loop).  Failure to do so
could result in deadlocks because the guest didn't notify and the host
would be waiting for a notification.

I will add comments to the code.

> > +		vhost_add_used(vq, head, pkt->len); /* TODO should this
> > be sizeof(pkt->hdr) + pkt->len? */
>=20
> TODO needs sorting our or removing.

Will fix in the next revision.

> > +	/* Respect global tx buf limitation */
> > +	mutex_lock(&vq->mutex);
> > +	while (pkt_len + vsock->total_tx_buf >
> > VIRTIO_VSOCK_MAX_TX_BUF_SIZE) {
>=20
> I'm curious about the relationship between
> VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE above and VIRTIO_VSOCK_MAX_TX_BUF_SIZE
> just here. Why do we need to limit pkt_len to the smaller when really
> all that matters is pkt_len + vsock->total_tx_buf >
> VIRTIO_VSOCK_MAX_TX_BUF_SIZE?

There are two separate issues:

1. The total amount of pending data.  The idea is to stop queuing
   packets and make the caller wait until resources become available so
   that vhost_vsock.ko memory consumption is bounded.

   total_tx_buf len is an artificial limit that is lower than the actual
   virtqueue maximum data size.  Otherwise we could just rely on the
   virtqueue to limit the size but it can be very large.

2. Splitting data into packets that fit into rx virtqueue buffers.  The
   guest sets up the rx virtqueue with VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE
   buffers.  Here, vhost_vsock.ko is assuming that the rx virtqueue
   buffers are always VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE bytes so it
   splits data along this boundary.

   This is ugly because the guest could choose a different buffer size
   and the host has VIRTIO_VSOCK_DEFAULT_RX_BUF_SIZE hardcoded.  I'll
   look into eliminating this assumption.

> > +static void vhost_vsock_handle_ctl_kick(struct vhost_work *work)
> > +{
> > +	struct vhost_virtqueue *vq =3D container_of(work, struct vhost_virtqu=
eue,
> > +						  poll.work);
> > +	struct vhost_vsock *vsock =3D container_of(vq->dev, struct vhost_vsoc=
k,
> > +						 dev);
> > +
> > +	pr_debug("%s vq=3D%p, vsock=3D%p\n", __func__, vq, vsock);
> > +}
>=20
> This doesn't handle anything, it just prints debug stuff. Should this be
> a NOP function?

The control virtqueue is currently not used.  In the next revision this
function will be dropped.

> > +static int vhost_vsock_set_features(struct vhost_vsock *vsock, u64 fea=
tures)
> > +{
> > +	struct vhost_virtqueue *vq;
> > +	int i;
> > +
> > +	if (features & ~VHOST_VSOCK_FEATURES)
> > +		return -EOPNOTSUPP;
> > +
> > +	mutex_lock(&vsock->dev.mutex);
> > +	if ((features & (1 << VHOST_F_LOG_ALL)) &&
> > +	    !vhost_log_access_ok(&vsock->dev)) {
> > +		mutex_unlock(&vsock->dev.mutex);
> > +		return -EFAULT;
> > +	}
> > +
> > +	for (i =3D 0; i < VSOCK_VQ_MAX; i++) {
> > +		vq =3D &vsock->vqs[i].vq;
> > +		mutex_lock(&vq->mutex);
> > +		vq->acked_features =3D features;
>=20
> Is this a user supplied flag? Should it be masked to valid values?

That is already done above where VHOST_VSOCK_FEATURES is checked.

--FsscpQKzF/jJk6ya
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWb8V0AAoJEJykq7OBq3PIE04H/2eH1uaMqX/FAiA8/UZyZi9h
RS0Vz5ojCzqsYy3wJ4hVyEmcPU3CyPgoFF+GLVczLh2lx5rmqwl10ypqnTOeMXFN
8CQmvgNWDPPVB2eCdWy1dtnzD/7AJ5G+N29CtJwaXqWtecuYiN/Z6nBIzINCoNLY
pWnWcKQ9tv+J6m/QkCZvY2Y2U9+2wsr/p7F7BSto1e4+GIXKMMhlLheSTE5k2+KL
IyUKGmLqxnljHJFAcBTFebOfnfJ8gTv6YZiYXx0arjx3pNiIj2GQFMtg0nA/6/OT
cBk/LRfHb8dOqUrGjEMeUT/fv09rtPD5cZvWtsQGknVmURjNn2jJWy75+p4cziQ=
=FROJ
-----END PGP SIGNATURE-----

--FsscpQKzF/jJk6ya--
