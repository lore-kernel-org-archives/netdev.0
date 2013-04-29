From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the vhost tree with the net-next tree
Date: Mon, 29 Apr 2013 17:29:10 +1000
Message-ID: <20130429172910.80b06cc01be57d9cf9b7828a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__29_Apr_2013_17_29_10_+1000_OtY78OVW8BVKCspH"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Asias He <asias@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__29_Apr_2013_17_29_10_+1000_OtY78OVW8BVKCspH
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Michael,

Today's linux-next merge of the vhost tree got a conflict in
drivers/vhost/net.c between commit 70181d51209c ("vhost_net: remove tx
polling state") from the net-next tree and commits 11569c7119a6 ("vhost:
Allow device specific fields per vq"), 15a51679a0a1 ("vhost: Move
vhost-net zerocopy support fields to net.c") and 0cc4c2bd142b ("vhost:
move per-vq net specific fields out to net") from the vhost tree.

I fixed it up (I think - see below - there is probably a better way) and
can carry the fix as necessary (no action is required).

diff --cc drivers/vhost/net.c
index 87c216c,661d9be..0000000
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@@ -64,10 -64,46 +64,36 @@@ enum=20
  	VHOST_NET_VQ_MAX =3D 2,
  };
 =20
 -enum vhost_net_poll_state {
 -	VHOST_NET_POLL_DISABLED =3D 0,
 -	VHOST_NET_POLL_STARTED =3D 1,
 -	VHOST_NET_POLL_STOPPED =3D 2,
 -};
 -
+ struct vhost_ubuf_ref {
+ 	struct kref kref;
+ 	wait_queue_head_t wait;
+ 	struct vhost_virtqueue *vq;
+ };
+=20
+ struct vhost_net_virtqueue {
+ 	struct vhost_virtqueue vq;
+ 	/* hdr is used to store the virtio header.
+ 	 * Since each iovec has >=3D 1 byte length, we never need more than
+ 	 * header length entries to store the header. */
+ 	struct iovec hdr[sizeof(struct virtio_net_hdr_mrg_rxbuf)];
+ 	size_t vhost_hlen;
+ 	size_t sock_hlen;
+ 	/* vhost zerocopy support fields below: */
+ 	/* last used idx for outstanding DMA zerocopy buffers */
+ 	int upend_idx;
+ 	/* first used idx for DMA done zerocopy buffers */
+ 	int done_idx;
+ 	/* an array of userspace buffers info */
+ 	struct ubuf_info *ubuf_info;
+ 	/* Reference counting for outstanding ubufs.
+ 	 * Protected by vq mutex. Writers must also take device mutex. */
+ 	struct vhost_ubuf_ref *ubufs;
+ };
+=20
  struct vhost_net {
  	struct vhost_dev dev;
- 	struct vhost_virtqueue vqs[VHOST_NET_VQ_MAX];
+ 	struct vhost_net_virtqueue vqs[VHOST_NET_VQ_MAX];
  	struct vhost_poll poll[VHOST_NET_VQ_MAX];
 -	/* Tells us whether we are polling a socket for TX.
 -	 * We only do this when socket buffer fills up.
 -	 * Protected by tx vq lock. */
 -	enum vhost_net_poll_state tx_poll_state;
  	/* Number of TX recently submitted.
  	 * Protected by tx vq lock. */
  	unsigned tx_packets;
@@@ -224,8 -369,18 +337,8 @@@ static void handle_tx(struct vhost_net=20
  	mutex_lock(&vq->mutex);
  	vhost_disable_notify(&net->dev, vq);
 =20
- 	hdr_size =3D vq->vhost_hlen;
- 	zcopy =3D vq->ubufs;
 -	if (wmem < sock->sk->sk_sndbuf / 2)
 -		tx_poll_stop(net);
+ 	hdr_size =3D nvq->vhost_hlen;
+ 	zcopy =3D nvq->ubufs;
 =20
  	for (;;) {
  		/* Release DMAs done buffers first */
@@@ -246,11 -401,21 +359,12 @@@
  			/* If more outstanding DMAs, queue the work.
  			 * Handle upend_idx wrap around
  			 */
- 			num_pends =3D likely(vq->upend_idx >=3D vq->done_idx) ?
- 				    (vq->upend_idx - vq->done_idx) :
- 				    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
+ 			num_pends =3D likely(nvq->upend_idx >=3D nvq->done_idx) ?
+ 				    (nvq->upend_idx - nvq->done_idx) :
+ 				    (nvq->upend_idx + UIO_MAXIOV -
+ 				     nvq->done_idx);
 -			if (unlikely(num_pends > VHOST_MAX_PEND)) {
 -				tx_poll_start(net, sock);
 -				set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 +			if (unlikely(num_pends > VHOST_MAX_PEND))
  				break;
 -			}
  			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
  				vhost_disable_notify(&net->dev, vq);
  				continue;
@@@ -309,10 -474,12 +423,10 @@@
  			if (zcopy_used) {
  				if (ubufs)
  					vhost_ubuf_put(ubufs);
- 				vq->upend_idx =3D ((unsigned)vq->upend_idx - 1) %
- 					UIO_MAXIOV;
+ 				nvq->upend_idx =3D ((unsigned)nvq->upend_idx - 1)
+ 					% UIO_MAXIOV;
  			}
  			vhost_discard_vq_desc(vq, 1);
 -			if (err =3D=3D -EAGAIN || err =3D=3D -ENOBUFS)
 -				tx_poll_start(net, sock);
  			break;
  		}
  		if (err !=3D len)
@@@ -584,24 -770,32 +716,31 @@@ static int vhost_net_open(struct inode=20
  static void vhost_net_disable_vq(struct vhost_net *n,
  				 struct vhost_virtqueue *vq)
  {
- 	struct vhost_poll *poll =3D n->poll + (vq - n->vqs);
++	struct vhost_net_virtqueue *vnq;
++	struct vhost_poll *poll;
++
  	if (!vq->private_data)
  		return;
 -	if (vq =3D=3D &n->vqs[VHOST_NET_VQ_TX].vq) {
 -		tx_poll_stop(n);
 -		n->tx_poll_state =3D VHOST_NET_POLL_DISABLED;
 -	} else
 -		vhost_poll_stop(n->poll + VHOST_NET_VQ_RX);
++	vnq =3D container_of(vq, struct vhost_net_virtqueue, vq);
++	poll =3D n->poll + (vnq - n->vqs);
 +	vhost_poll_stop(poll);
  }
 =20
  static int vhost_net_enable_vq(struct vhost_net *n,
  				struct vhost_virtqueue *vq)
  {
- 	struct vhost_poll *poll =3D n->poll + (vq - n->vqs);
++	struct vhost_net_virtqueue *vnq;
++	struct vhost_poll *poll;
  	struct socket *sock;
 -	int ret;
 =20
  	sock =3D rcu_dereference_protected(vq->private_data,
  					 lockdep_is_held(&vq->mutex));
  	if (!sock)
  		return 0;
 -	if (vq =3D=3D &n->vqs[VHOST_NET_VQ_TX].vq) {
 -		n->tx_poll_state =3D VHOST_NET_POLL_STOPPED;
 -		ret =3D tx_poll_start(n, sock);
 -	} else
 -		ret =3D vhost_poll_start(n->poll + VHOST_NET_VQ_RX, sock->file);
++	vnq =3D container_of(vq, struct vhost_net_virtqueue, vq);
++	poll =3D n->poll + (vnq - n->vqs);
 =20
 -	return ret;
 +	return vhost_poll_start(poll, sock->file);
  }
 =20
  static struct socket *vhost_net_stop_vq(struct vhost_net *n,

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__29_Apr_2013_17_29_10_+1000_OtY78OVW8BVKCspH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRfiFGAAoJEECxmPOUX5FErdwP/RHzdB9YviZlCzQT2aOYZ7TK
FcT0TIL1v41f0oZJ40eATi1PCANoB+FEmE33IHBdnj+blMiCq14121/xVzKQs8Is
M1hb7bHQP9a5/YanfEOSKmcVKTFqy6cTgP7dd4x79nXDrItDYTlpV4YoDHPpicUi
/a4otC5/FNpPlhRTnRb5/5h9DBlqQtYDXHAuzAULeKMpYSaHuyU1+X1LzwEXDSkk
Xp4sapKkaS63/YKHD6jd8DU4pdA2eb6xT2CSK4Gi7vxV3stLhOETQMj67NU3j58Y
bKsqBB8SztoApXD+hAKzl+2tUkjv7kAxUgTq7d9SlGD/nw6Qd1hANDvMkHEFhrSf
IY6IhWE2XrHXdS3ZSIHeFnCJ6PDLzZBCl+fupRV9GmdVMwtQK+53F6TA1P9moVVe
okGuxAisMrMUm8zari1xyVrwVb6184dHbsivp0BoFmlzFeHqPZc+Pg3bwBw/O6uj
SjMNdBb2WuMQTfPunu+swkBCzM1/4EmvDfa/IF+DU+RzFny9hmUKTgecevcRR9LR
oBcaLCd/vIusqxd6NMbXVI3aof/u2xih6x3Jz+EeSZ8cj0GDTqfw2oflzbT/S5tO
Hqjcl9dEad8YD8bOU1P4+Mi0b9+qaeR6WHDmPto+tcACvDdaLsZK+QYViimcZvXw
bhSRy1TaCUMTZHuhGOPu
=BYhW
-----END PGP SIGNATURE-----

--Signature=_Mon__29_Apr_2013_17_29_10_+1000_OtY78OVW8BVKCspH--
