From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2 RFC PATCH 2/4] Changes for virtio-net
Date: Fri, 17 Sep 2010 12:25:54 +0200
Message-ID: <1284719154.3391.84.camel@edumazet-laptop>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
	 <20100917100319.21276.271.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com,
	kvm@vger.kernel.org, arnd@arndb.de, netdev@vger.kernel.org,
	avi@redhat.com, anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54165 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab0IQKZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 06:25:59 -0400
In-Reply-To: <20100917100319.21276.271.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 septembre 2010 =C3=A0 15:33 +0530, Krishna Kumar a =C3=A9=
crit :
> Implement mq virtio-net driver.=20
>=20
> Though struct virtio_net_config changes, it works with old
> qemu's since the last element is not accessed, unless qemu
> sets VIRTIO_NET_F_NUMTXQS.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  drivers/net/virtio_net.c   |  213 ++++++++++++++++++++++++++--------=
-
>  include/linux/virtio_net.h |    3=20
>  2 files changed, 163 insertions(+), 53 deletions(-)
>=20
> diff -ruNp org2/include/linux/virtio_net.h tx_only2/include/linux/vir=
tio_net.h
> --- org2/include/linux/virtio_net.h	2010-02-10 13:20:27.000000000 +05=
30
> +++ tx_only2/include/linux/virtio_net.h	2010-09-16 15:24:01.000000000=
 +0530
> @@ -26,6 +26,7 @@
>  #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support *=
/
>  #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering =
*/
>  #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control suppo=
rt */
> +#define VIRTIO_NET_F_NUMTXQS	21	/* Device supports multiple TX queue=
 */
> =20
>  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
> =20
> @@ -34,6 +35,8 @@ struct virtio_net_config {
>  	__u8 mac[6];
>  	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
>  	__u16 status;
> +	/* number of transmit queues */
> +	__u16 numtxqs;
>  } __attribute__((packed));
> =20
>  /* This is the first element of the scatter-gather list.  If you don=
't
> diff -ruNp org2/drivers/net/virtio_net.c tx_only2/drivers/net/virtio_=
net.c
> --- org2/drivers/net/virtio_net.c	2010-07-08 12:54:32.000000000 +0530
> +++ tx_only2/drivers/net/virtio_net.c	2010-09-16 15:24:01.000000000 +=
0530
> @@ -40,9 +40,20 @@ module_param(gso, bool, 0444);
> =20
>  #define VIRTNET_SEND_COMMAND_SG_MAX    2
> =20
> +/* Our representation of a send virtqueue */
> +struct send_queue {
> +	struct virtqueue *svq;
> +
> +	/* TX: fragments + linear part + virtio header */
> +	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
> +};

You probably want ____cacheline_aligned_in_smp


> +
>  struct virtnet_info {
>  	struct virtio_device *vdev;
> -	struct virtqueue *rvq, *svq, *cvq;
> +	int numtxqs;			/* Number of tx queues */
> +	struct send_queue *sq;
> +	struct virtqueue *rvq;
> +	struct virtqueue *cvq;
>  	struct net_device *dev;

struct napi will probably be dirtied by RX processing

You should make sure it doesnt dirty cache line of above (read mostly)
fields


>  	struct napi_struct napi;
>  	unsigned int status;
> @@ -62,9 +73,8 @@ struct virtnet_info {
>  	/* Chain pages by the private ptr. */
>  	struct page *pages;
> =20
> -	/* fragments + linear part + virtio header */
> +	/* RX: fragments + linear part + virtio header */
>  	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
> -	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
>  };
> =20
>  struct skb_vnet_hdr {
> @@ -120,12 +130,13 @@ static struct page *get_a_page(struct vi
>  static void skb_xmit_done(struct virtqueue *svq)
>  {
>  	struct virtnet_info *vi =3D svq->vdev->priv;
> +	int qnum =3D svq->queue_index - 1;	/* 0 is RX vq */
> =20
>  	/* Suppress further interrupts. */
>  	virtqueue_disable_cb(svq);
> =20
>  	/* We were probably waiting for more output buffers. */
> -	netif_wake_queue(vi->dev);
> +	netif_wake_subqueue(vi->dev, qnum);
>  }
> =20
>  static void set_skb_frag(struct sk_buff *skb, struct page *page,
> @@ -495,12 +506,13 @@ again:
>  	return received;
>  }
> =20
> -static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
> +static unsigned int free_old_xmit_skbs(struct virtnet_info *vi,
> +				       struct virtqueue *svq)
>  {
>  	struct sk_buff *skb;
>  	unsigned int len, tot_sgs =3D 0;
> =20
> -	while ((skb =3D virtqueue_get_buf(vi->svq, &len)) !=3D NULL) {
> +	while ((skb =3D virtqueue_get_buf(svq, &len)) !=3D NULL) {
>  		pr_debug("Sent skb %p\n", skb);
>  		vi->dev->stats.tx_bytes +=3D skb->len;
>  		vi->dev->stats.tx_packets++;
> @@ -510,7 +522,8 @@ static unsigned int free_old_xmit_skbs(s
>  	return tot_sgs;
>  }
> =20
> -static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
> +static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb,
> +		    struct virtqueue *svq, struct scatterlist *tx_sg)
>  {
>  	struct skb_vnet_hdr *hdr =3D skb_vnet_hdr(skb);
>  	const unsigned char *dest =3D ((struct ethhdr *)skb->data)->h_dest;
> @@ -548,12 +561,12 @@ static int xmit_skb(struct virtnet_info=20
> =20
>  	/* Encode metadata header at front. */
>  	if (vi->mergeable_rx_bufs)
> -		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
> +		sg_set_buf(tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
>  	else
> -		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
> +		sg_set_buf(tx_sg, &hdr->hdr, sizeof hdr->hdr);
> =20
> -	hdr->num_sg =3D skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
> -	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
> +	hdr->num_sg =3D skb_to_sgvec(skb, tx_sg + 1, 0, skb->len) + 1;
> +	return virtqueue_add_buf(svq, tx_sg, hdr->num_sg,
>  					0, skb);
>  }
> =20
> @@ -561,31 +574,34 @@ static netdev_tx_t start_xmit(struct sk_
>  {
>  	struct virtnet_info *vi =3D netdev_priv(dev);
>  	int capacity;
> +	int qnum =3D skb_get_queue_mapping(skb);
> +	struct virtqueue *svq =3D vi->sq[qnum].svq;
> =20
>  	/* Free up any pending old buffers before queueing new ones. */
> -	free_old_xmit_skbs(vi);
> +	free_old_xmit_skbs(vi, svq);
> =20
>  	/* Try to transmit */
> -	capacity =3D xmit_skb(vi, skb);
> +	capacity =3D xmit_skb(vi, skb, svq, vi->sq[qnum].tx_sg);
> =20
>  	/* This can happen with OOM and indirect buffers. */
>  	if (unlikely(capacity < 0)) {
>  		if (net_ratelimit()) {
>  			if (likely(capacity =3D=3D -ENOMEM)) {
>  				dev_warn(&dev->dev,
> -					 "TX queue failure: out of memory\n");
> +					 "TXQ (%d) failure: out of memory\n",
> +					 qnum);
>  			} else {
>  				dev->stats.tx_fifo_errors++;
>  				dev_warn(&dev->dev,
> -					 "Unexpected TX queue failure: %d\n",
> -					 capacity);
> +					 "Unexpected TXQ (%d) failure: %d\n",
> +					 qnum, capacity);
>  			}
>  		}
>  		dev->stats.tx_dropped++;
>  		kfree_skb(skb);
>  		return NETDEV_TX_OK;
>  	}
> -	virtqueue_kick(vi->svq);
> +	virtqueue_kick(svq);
> =20
>  	/* Don't wait up for transmitted skbs to be freed. */
>  	skb_orphan(skb);
> @@ -594,13 +610,13 @@ static netdev_tx_t start_xmit(struct sk_
>  	/* Apparently nice girls don't return TX_BUSY; stop the queue
>  	 * before it gets out of hand.  Naturally, this wastes entries. */
>  	if (capacity < 2+MAX_SKB_FRAGS) {
> -		netif_stop_queue(dev);
> -		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
> +		netif_stop_subqueue(dev, qnum);
> +		if (unlikely(!virtqueue_enable_cb(svq))) {
>  			/* More just got used, free them then recheck. */
> -			capacity +=3D free_old_xmit_skbs(vi);
> +			capacity +=3D free_old_xmit_skbs(vi, svq);
>  			if (capacity >=3D 2+MAX_SKB_FRAGS) {
> -				netif_start_queue(dev);
> -				virtqueue_disable_cb(vi->svq);
> +				netif_start_subqueue(dev, qnum);
> +				virtqueue_disable_cb(svq);
>  			}
>  		}
>  	}
> @@ -871,10 +887,10 @@ static void virtnet_update_status(struct
> =20
>  	if (vi->status & VIRTIO_NET_S_LINK_UP) {
>  		netif_carrier_on(vi->dev);
> -		netif_wake_queue(vi->dev);
> +		netif_tx_wake_all_queues(vi->dev);
>  	} else {
>  		netif_carrier_off(vi->dev);
> -		netif_stop_queue(vi->dev);
> +		netif_tx_stop_all_queues(vi->dev);
>  	}
>  }
> =20
> @@ -885,18 +901,112 @@ static void virtnet_config_changed(struc
>  	virtnet_update_status(vi);
>  }
> =20
> +#define MAX_DEVICE_NAME		16
> +static int initialize_vqs(struct virtnet_info *vi, int numtxqs)
> +{
> +	vq_callback_t **callbacks;
> +	struct virtqueue **vqs;
> +	int i, err =3D -ENOMEM;
> +	int totalvqs;
> +	char **names;
> +
> +	/* Allocate send queues */

no check on numtxqs ? Hmm...

Please then use kcalloc(numtxqs, sizeof(*vi->sq), GFP_KERNEL) so that
some check is done for you ;)

> +	vi->sq =3D kzalloc(numtxqs * sizeof(*vi->sq), GFP_KERNEL);
> +	if (!vi->sq)
> +		goto out;
> +
> +	/* setup initial send queue parameters */
> +	for (i =3D 0; i < numtxqs; i++)
> +		sg_init_table(vi->sq[i].tx_sg, ARRAY_SIZE(vi->sq[i].tx_sg));
> +
> +	/*
> +	 * We expect 1 RX virtqueue followed by 'numtxqs' TX virtqueues, an=
d
> +	 * optionally one control virtqueue.
> +	 */
> +	totalvqs =3D 1 + numtxqs +
> +		   virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ);
> +
> +	/* Setup parameters for find_vqs */
> +	vqs =3D kmalloc(totalvqs * sizeof(*vqs), GFP_KERNEL);
> +	callbacks =3D kmalloc(totalvqs * sizeof(*callbacks), GFP_KERNEL);
> +	names =3D kzalloc(totalvqs * sizeof(*names), GFP_KERNEL);
> +	if (!vqs || !callbacks || !names)
> +		goto free_mem;
> +

