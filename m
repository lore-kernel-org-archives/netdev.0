From: Jesse Larrew <jlarrew@linux.vnet.ibm.com>
Subject: Re: [Qemu-devel] [PATCH] virtio-net: put virtio net header inline
 with data
Date: Thu, 06 Jun 2013 14:59:44 -0500
Message-ID: <51B0EA30.3020804@linux.vnet.ibm.com>
References: <20130606095456.GA7865@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Cong Wang <amwang@redhat.com>, Amos Kong <akong@redhat.com>,
	Dave Jones <davej@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qemu-devel@nongnu.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130606095456.GA7865@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael!

On 06/06/2013 04:55 AM, Michael S. Tsirkin wrote:
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index c9e0038..d35a097 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -106,6 +106,9 @@ struct virtnet_info {
>  	/* Has control virtqueue */
>  	bool has_cvq;
> 
> +	/* Host can handle any s/g split between our header and packet data */
> +	bool any_header_sg;
> +
>  	/* enable config space updates */
>  	bool config_enable;
> 
> @@ -668,12 +671,28 @@ static void free_old_xmit_skbs(struct send_queue *sq)
> 
>  static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  {
> -	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
> +	struct skb_vnet_hdr *hdr;
>  	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
>  	struct virtnet_info *vi = sq->vq->vdev->priv;
>  	unsigned num_sg;
> +	unsigned hdr_len;
> +	bool can_push;
> 
>  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
> +	if (vi->mergeable_rx_bufs)
> +		hdr_len = sizeof hdr->mhdr;
> +	else
> +		hdr_len = sizeof hdr->hdr;

All conditionals need braces.

> +
> +	can_push = vi->any_header_sg &&
> +		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
> +		!skb_header_cloned(skb) && skb_headroom(skb) >= hdr_len;
> +	/* Even if we can, don't push here yet as this would skew
> +	 * csum_start offset below. */
> +	if (can_push)
> +		hdr = (struct skb_vnet_hdr *)(skb->data - hdr_len);
> +	else
> +		hdr = skb_vnet_hdr(skb);

Ditto.

> 
>  	if (skb->ip_summed == CHECKSUM_PARTIAL) {
>  		hdr->hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
> @@ -702,15 +721,18 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
>  		hdr->hdr.gso_size = hdr->hdr.hdr_len = 0;
>  	}
> 
> -	hdr->mhdr.num_buffers = 0;
> -
> -	/* Encode metadata header at front. */
>  	if (vi->mergeable_rx_bufs)
> -		sg_set_buf(sq->sg, &hdr->mhdr, sizeof hdr->mhdr);
> -	else
> -		sg_set_buf(sq->sg, &hdr->hdr, sizeof hdr->hdr);
> +		hdr->mhdr.num_buffers = 0;
> 

Here too, please.

> -	num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
> +	if (can_push) {
> +		__skb_push(skb, hdr_len);
> +		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
> +		/* Pull header back to avoid skew in tx bytes calculations. */
> +		__skb_pull(skb, hdr_len);
> +	} else {
> +		sg_set_buf(sq->sg, hdr, hdr_len);
> +		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
> +	}
>  	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
>  }
> 
> @@ -1554,6 +1576,9 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
>  		vi->mergeable_rx_bufs = true;
> 

This is just context, but we may as well fix this as well.

> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_ANY_HEADER_SG))
> +		vi->any_header_sg = true;
> +

Braces here, please.

>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>  		vi->has_cvq = true;
> 

Might as well fix this too.

> @@ -1729,6 +1754,7 @@ static unsigned int features[] = {
>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
>  	VIRTIO_NET_F_CTRL_MAC_ADDR,
> +	VIRTIO_NET_F_ANY_HEADER_SG,
>  };
> 
>  static struct virtio_driver virtio_net_driver = {
> diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> index c520203..9c98b7d 100644
> --- a/include/uapi/linux/virtio_net.h
> +++ b/include/uapi/linux/virtio_net.h
> @@ -55,6 +55,8 @@
>  					 * Steering */
>  #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
> 
> +#define VIRTIO_NET_F_ANY_HEADER_SG 25	/* Host can handle any header s/g */
> +
>  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
>  #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
> 
> @@ -70,7 +72,9 @@ struct virtio_net_config {
>  	__u16 max_virtqueue_pairs;
>  } __attribute__((packed));
> 
> -/* This is the first element of the scatter-gather list.  If you don't
> +/* This header comes first in the scatter-gather list.
> + * If VIRTIO_NET_F_ANY_HEADER_SG is not negotiated, it must
> + * be the first element of the scatter-gather list.  If you don't
>   * specify GSO or CSUM features, you can simply ignore the header. */
>  struct virtio_net_hdr {
>  #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
> 

Sincerely,

Jesse Larrew
Software Engineer, KVM Team
IBM Linux Technology Center
Phone: (512) 973-2052 (T/L: 363-2052)
jlarrew@linux.vnet.ibm.com
