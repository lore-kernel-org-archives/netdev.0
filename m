From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio-net: per cpu 64 bit stats
Date: Wed, 15 Jun 2011 17:58:58 +0200
Message-ID: <1308153538.3128.3.camel@edumazet-laptop>
References: <20110615114337.09fe62f6@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46657 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab1FOP7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 11:59:11 -0400
Received: by wya21 with SMTP id 21so410753wya.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 08:59:10 -0700 (PDT)
In-Reply-To: <20110615114337.09fe62f6@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 juin 2011 =C3=A0 11:43 -0400, Stephen Hemminger a =C3=A9=
crit :
> Use per-cpu variables to maintain 64 bit statistics.
> Compile tested only.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/drivers/net/virtio_net.c	2011-06-14 15:18:46.448596355 -0400
> +++ b/drivers/net/virtio_net.c	2011-06-15 09:54:22.914426067 -0400
> @@ -40,6 +40,15 @@ module_param(gso, bool, 0444);
> =20
>  #define VIRTNET_SEND_COMMAND_SG_MAX    2
> =20
> +struct virtnet_stats {
> +	struct u64_stats_sync syncp;
> +	u64 tx_bytes;
> +	u64 tx_packets;
> +
> +	u64 rx_bytes;
> +	u64 rx_packets;
> +};
> +
>  struct virtnet_info {
>  	struct virtio_device *vdev;
>  	struct virtqueue *rvq, *svq, *cvq;
> @@ -56,6 +65,9 @@ struct virtnet_info {
>  	/* Host will merge rx buffers for big packets (shake it! shake it!)=
 */
>  	bool mergeable_rx_bufs;
> =20
> +	/* Active statistics */
> +	struct virtnet_stats __percpu *stats;
> +
>  	/* Work struct for refilling if we run low on memory. */
>  	struct delayed_work refill;
> =20
> @@ -209,7 +221,6 @@ static int receive_mergeable(struct virt
>  			skb->dev->stats.rx_length_errors++;
>  			return -EINVAL;
>  		}
> -
>  		page =3D virtqueue_get_buf(vi->rvq, &len);
>  		if (!page) {
>  			pr_debug("%s: rx error: %d buffers missing\n",
> @@ -217,6 +228,7 @@ static int receive_mergeable(struct virt
>  			skb->dev->stats.rx_length_errors++;
>  			return -EINVAL;
>  		}
> +
>  		if (len > PAGE_SIZE)
>  			len =3D PAGE_SIZE;
> =20
> @@ -230,6 +242,7 @@ static int receive_mergeable(struct virt
>  static void receive_buf(struct net_device *dev, void *buf, unsigned =
int len)
>  {
>  	struct virtnet_info *vi =3D netdev_priv(dev);
> +	struct virtnet_stats __percpu *stats =3D this_cpu_ptr(vi->stats);
>  	struct sk_buff *skb;
>  	struct page *page;
>  	struct skb_vnet_hdr *hdr;
> @@ -265,8 +278,11 @@ static void receive_buf(struct net_devic
> =20
>  	hdr =3D skb_vnet_hdr(skb);
>  	skb->truesize +=3D skb->data_len;
> -	dev->stats.rx_bytes +=3D skb->len;
> -	dev->stats.rx_packets++;
> +
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->rx_bytes +=3D skb->len;
> +	stats->rx_packets++;
> +	u64_stats_update_begin(&stats->syncp);

	u64_stats_update_end(&stats->syncp);


> =20
>  	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
>  		pr_debug("Needs csum!\n");
> @@ -515,11 +531,16 @@ static unsigned int free_old_xmit_skbs(s
>  {
>  	struct sk_buff *skb;
>  	unsigned int len, tot_sgs =3D 0;
> +	struct virtnet_stats __percpu *stats =3D this_cpu_ptr(vi->stats);
> =20
>  	while ((skb =3D virtqueue_get_buf(vi->svq, &len)) !=3D NULL) {
>  		pr_debug("Sent skb %p\n", skb);
> -		vi->dev->stats.tx_bytes +=3D skb->len;
> -		vi->dev->stats.tx_packets++;
> +
> +		u64_stats_update_begin(&stats->syncp);
> +		stats->tx_bytes +=3D skb->len;
> +		stats->tx_packets++;
> +		u64_stats_update_begin(&stats->syncp);

	u64_stats_update_end(&stats->syncp);

> +
>  		tot_sgs +=3D skb_vnet_hdr(skb)->num_sg;
>  		dev_kfree_skb_any(skb);
>  	}
> @@ -641,6 +662,40 @@ static int virtnet_set_mac_address(struc
>  	return 0;
>  }
> =20


