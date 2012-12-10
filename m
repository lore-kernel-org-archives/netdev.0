From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the virtio tree with the net-next tree
Date: Mon, 10 Dec 2012 13:28:08 +1100
Message-ID: <20121210132808.10517f2be447d1e6c7900f63@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__10_Dec_2012_13_28_08_+1100_F36pLXHux09RGYoc"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__10_Dec_2012_13_28_08_+1100_F36pLXHux09RGYoc
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Rusty,

Today's linux-next merge of the virtio tree got a conflict in
drivers/net/virtio_net.c between commit e9d7417b97f4 ("virtio-net:
separate fields of sending/receiving queue from virtnet_info") and
986a4f4d452d ("virtio_net: multiqueue support") from the net-next tree
and commit a89f05573fa2 ("virtio-net: remove unused skb_vnet_hdr->num_sg
field"), 2c6d439a7316 ("virtio-net: correct capacity math on ring full"),
e794093a52cd ("virtio_net: don't rely on virtqueue_add_buf() returning
capacity") and 7dc5f95d9b6c ("virtio: net: make it clear that
virtqueue_add_buf() no longer returns > 0") from the virtio tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/virtio_net.c
index a644eeb,6289891..0000000
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@@ -523,20 -464,21 +522,21 @@@ static bool try_fill_recv(struct receiv
 =20
  	do {
  		if (vi->mergeable_rx_bufs)
 -			err =3D add_recvbuf_mergeable(vi, gfp);
 +			err =3D add_recvbuf_mergeable(rq, gfp);
  		else if (vi->big_packets)
 -			err =3D add_recvbuf_big(vi, gfp);
 +			err =3D add_recvbuf_big(rq, gfp);
  		else
 -			err =3D add_recvbuf_small(vi, gfp);
 +			err =3D add_recvbuf_small(rq, gfp);
 =20
  		oom =3D err =3D=3D -ENOMEM;
- 		if (err < 0)
+ 		if (err)
  			break;
 -		++vi->num;
 -	} while (vi->rvq->num_free);
 +		++rq->num;
- 	} while (err > 0);
++	} while (rq->vq->num_free);
+=20
 -	if (unlikely(vi->num > vi->max))
 -		vi->max =3D vi->num;
 -	virtqueue_kick(vi->rvq);
 +	if (unlikely(rq->num > rq->max))
 +		rq->max =3D rq->num;
 +	virtqueue_kick(rq->vq);
  	return !oom;
  }
 =20
@@@ -625,29 -557,13 +625,29 @@@ again
  	return received;
  }
 =20
 -static void free_old_xmit_skbs(struct virtnet_info *vi)
 +static int virtnet_open(struct net_device *dev)
 +{
 +	struct virtnet_info *vi =3D netdev_priv(dev);
 +	int i;
 +
 +	for (i =3D 0; i < vi->max_queue_pairs; i++) {
 +		/* Make sure we have some buffers: if oom use wq. */
 +		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
 +			schedule_delayed_work(&vi->refill, 0);
 +		virtnet_napi_enable(&vi->rq[i]);
 +	}
 +
 +	return 0;
 +}
 +
- static unsigned int free_old_xmit_skbs(struct send_queue *sq)
++static void free_old_xmit_skbs(struct send_queue *sq)
  {
  	struct sk_buff *skb;
- 	unsigned int len, tot_sgs =3D 0;
+ 	unsigned int len;
 +	struct virtnet_info *vi =3D sq->vq->vdev->priv;
  	struct virtnet_stats *stats =3D this_cpu_ptr(vi->stats);
 =20
 -	while ((skb =3D virtqueue_get_buf(vi->svq, &len)) !=3D NULL) {
 +	while ((skb =3D virtqueue_get_buf(sq->vq, &len)) !=3D NULL) {
  		pr_debug("Sent skb %p\n", skb);
 =20
  		u64_stats_update_begin(&stats->tx_syncp);
@@@ -655,17 -571,15 +655,16 @@@
  		stats->tx_packets++;
  		u64_stats_update_end(&stats->tx_syncp);
 =20
- 		tot_sgs +=3D skb_vnet_hdr(skb)->num_sg;
  		dev_kfree_skb_any(skb);
  	}
- 	return tot_sgs;
  }
 =20
 -static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 +static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
  {
  	struct skb_vnet_hdr *hdr =3D skb_vnet_hdr(skb);
  	const unsigned char *dest =3D ((struct ethhdr *)skb->data)->h_dest;
+ 	unsigned num_sg;
 +	struct virtnet_info *vi =3D sq->vq->vdev->priv;
 =20
  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 =20
@@@ -700,42 -614,32 +699,35 @@@
 =20
  	/* Encode metadata header at front. */
  	if (vi->mergeable_rx_bufs)
 -		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
 +		sg_set_buf(sq->sg, &hdr->mhdr, sizeof hdr->mhdr);
  	else
 -		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
 +		sg_set_buf(sq->sg, &hdr->hdr, sizeof hdr->hdr);
 =20
- 	hdr->num_sg =3D skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
- 	return virtqueue_add_buf(sq->vq, sq->sg, hdr->num_sg,
 -	num_sg =3D skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
 -	return virtqueue_add_buf(vi->svq, vi->tx_sg, num_sg,
++	num_sg =3D skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
++	return virtqueue_add_buf(sq->vq, sq->sg, num_sg,
  				 0, skb, GFP_ATOMIC);
  }
 =20
  static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
  {
  	struct virtnet_info *vi =3D netdev_priv(dev);
 +	int qnum =3D skb_get_queue_mapping(skb);
 +	struct send_queue *sq =3D &vi->sq[qnum];
- 	int capacity;
+ 	int err;
 =20
  	/* Free up any pending old buffers before queueing new ones. */
 -	free_old_xmit_skbs(vi);
 +	free_old_xmit_skbs(sq);
 =20
  	/* Try to transmit */
- 	capacity =3D xmit_skb(sq, skb);
-=20
- 	/* This can happen with OOM and indirect buffers. */
- 	if (unlikely(capacity < 0)) {
- 		if (likely(capacity =3D=3D -ENOMEM)) {
- 			if (net_ratelimit())
- 				dev_warn(&dev->dev,
- 					 "TXQ (%d) failure: out of memory\n",
- 					 qnum);
- 		} else {
- 			dev->stats.tx_fifo_errors++;
- 			if (net_ratelimit())
- 				dev_warn(&dev->dev,
- 					 "Unexpected TXQ (%d) failure: %d\n",
- 					 qnum, capacity);
- 		}
 -	err =3D xmit_skb(vi, skb);
++	err =3D xmit_skb(sq, skb);
+=20
+ 	/* This should not happen! */
+ 	if (unlikely(err)) {
+ 		dev->stats.tx_fifo_errors++;
+ 		if (net_ratelimit())
+ 			dev_warn(&dev->dev,
 -				 "Unexpected TX queue failure: %d\n", err);
++				 "Unexpected TXQ (%d) failure: %d\n",
++				 qnum, err);
  		dev->stats.tx_dropped++;
  		kfree_skb(skb);
  		return NETDEV_TX_OK;
@@@ -748,14 -652,14 +740,13 @@@
 =20
  	/* Apparently nice girls don't return TX_BUSY; stop the queue
  	 * before it gets out of hand.  Naturally, this wastes entries. */
- 	if (capacity < 2+MAX_SKB_FRAGS) {
 -	if (vi->svq->num_free < 2+MAX_SKB_FRAGS) {
 -		netif_stop_queue(dev);
 -		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
++	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
 +		netif_stop_subqueue(dev, qnum);
 +		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
  			/* More just got used, free them then recheck. */
- 			capacity +=3D free_old_xmit_skbs(sq);
- 			if (capacity >=3D 2+MAX_SKB_FRAGS) {
 -			free_old_xmit_skbs(vi);
 -			if (vi->svq->num_free >=3D 2+MAX_SKB_FRAGS) {
 -				netif_start_queue(dev);
 -				virtqueue_disable_cb(vi->svq);
++			if (sq->vq->num_free >=3D 2+MAX_SKB_FRAGS) {
 +				netif_start_subqueue(dev, qnum);
 +				virtqueue_disable_cb(sq->vq);
  			}
  		}
  	}

--Signature=_Mon__10_Dec_2012_13_28_08_+1100_F36pLXHux09RGYoc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQxUi4AAoJEECxmPOUX5FESGgP/07f3JsTVMYbh0krq+wysiCW
VQtCyJ4hnEZF9xNRDu23Uvodq+gnTM2Y51Fkslnfiz0JFv6k26V5fpcQrfsYFRqA
ZZ302wzyKI0FmiKAa5cIl7vNGP1M4hOz0bsttm9/fyy8qfBE7tsgdwHs4lgKl3yH
8OmLsrNM0tja5EE+riFoUKkqOdHmRW4vKCXQASGb2oIl1DJbHKQljNah4MOCmX3I
O/SffXe/OpvlAbkT1uoh4ee7F+Qsy6s1VFcg2/mPdy8Zlh63RwY/+H7M+H5EtK6V
xRtJOp9zAZUfRV6i7yysJtFpn70fByY68s7gG5bzG/aFAwQiQ+GVB8W2Ljsfc35C
zJJ/pNZqzyd6btWXrIFWqg7Tx2oqDnCIdTSIp4A1UOh5LJU7AUzKPE2kHfom7k04
zS39gCj7ZGbnWaGahccyV650U5X17jI2J4l+k62tvoJmltqPi2dcG9p68bZlLbwS
+tbUGqJ1eHZye3tLSt7lxO6pk0BQ6HmRkV+RGAMbqle9Nfacc3Ba9nEHXoGVVdLR
1lGEv4GWgEXltmOt6j5u5PHpDjWrqPDMYSUO0k0qiCjE/I+B27xt+E1Xzai9a/Gn
jnn/SGcjctwIeKH9xreDQTgNOLZTYumKuEnNXGXjF6RTND+1+pCLc/axpRUaQqtA
jskLqR7El+gEDngUDU/w
=DgXc
-----END PGP SIGNATURE-----

--Signature=_Mon__10_Dec_2012_13_28_08_+1100_F36pLXHux09RGYoc--
