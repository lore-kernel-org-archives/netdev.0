From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next PATCH v2 5/5] virtio_net: XDP support for adjust_head
Date: Mon, 6 Feb 2017 15:08:03 +0800
Message-ID: <993d31de-57d9-fb7f-568e-c18fc9fadbc6@redhat.com>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
 <20170203031629.23054.25622.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, kubakici@wp.pl,
        ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47016 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751052AbdBFHIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 02:08:10 -0500
In-Reply-To: <20170203031629.23054.25622.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月03日 11:16, John Fastabend wrote:
> Add support for XDP adjust head by allocating a 256B header region
> that XDP programs can grow into. This is only enabled when a XDP
> program is loaded.
>
> In order to ensure that we do not have to unwind queue headroom push
> queue setup below bpf_prog_add. It reads better to do a prog ref
> unwind vs another queue setup call.
>
> At the moment this code must do a full reset to ensure old buffers
> without headroom on program add or with headroom on program removal
> are not used incorrectly in the datapath. Ideally we would only
> have to disable/enable the RX queues being updated but there is no
> API to do this at the moment in virtio so use the big hammer. In
> practice it is likely not that big of a problem as this will only
> happen when XDP is enabled/disabled changing programs does not
> require the reset. There is some risk that the driver may either
> have an allocation failure or for some reason fail to correctly
> negotiate with the underlying backend in this case the driver will
> be left uninitialized. I have not seen this ever happen on my test
> systems and for what its worth this same failure case can occur
> from probe and other contexts in virtio framework.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   drivers/net/virtio_net.c |  154 +++++++++++++++++++++++++++++++++++++---------
>   1 file changed, 125 insertions(+), 29 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 07f9076..52a18b8 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -42,6 +42,9 @@
>   #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
>   #define GOOD_COPY_LEN	128
>   
> +/* Amount of XDP headroom to prepend to packets for use by xdp_adjust_head */
> +#define VIRTIO_XDP_HEADROOM 256
> +
>   /* RX packet size EWMA. The average packet size is used to determine the packet
>    * buffer size when refilling RX rings. As the entire RX ring may be refilled
>    * at once, the weight is chosen so that the EWMA will be insensitive to short-
> @@ -368,6 +371,7 @@ static bool virtnet_xdp_xmit(struct virtnet_info *vi,
>   	}
>   
>   	if (vi->mergeable_rx_bufs) {
> +		xdp->data -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
>   		/* Zero header and leave csum up to XDP layers */
>   		hdr = xdp->data;
>   		memset(hdr, 0, vi->hdr_len);
> @@ -384,7 +388,9 @@ static bool virtnet_xdp_xmit(struct virtnet_info *vi,
>   		num_sg = 2;
>   		sg_init_table(sq->sg, 2);
>   		sg_set_buf(sq->sg, hdr, vi->hdr_len);
> -		skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
> +		skb_to_sgvec(skb, sq->sg + 1,
> +			     xdp->data - xdp->data_hard_start,
> +			     xdp->data_end - xdp->data);
>   	}
>   	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
>   				   data, GFP_ATOMIC);
> @@ -412,7 +418,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
>   	struct bpf_prog *xdp_prog;
>   
>   	len -= vi->hdr_len;
> -	skb_trim(skb, len);
>   
>   	rcu_read_lock();
>   	xdp_prog = rcu_dereference(rq->xdp_prog);
> @@ -424,12 +429,16 @@ static struct sk_buff *receive_small(struct net_device *dev,
>   		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
>   			goto err_xdp;
>   
> -		xdp.data = skb->data;
> +		xdp.data_hard_start = skb->data;
> +		xdp.data = skb->data + VIRTIO_XDP_HEADROOM;
>   		xdp.data_end = xdp.data + len;
>   		act = bpf_prog_run_xdp(xdp_prog, &xdp);
>   
>   		switch (act) {
>   		case XDP_PASS:
> +			/* Recalculate length in case bpf program changed it */
> +			__skb_pull(skb, xdp.data - xdp.data_hard_start);

But skb->len were trimmed to len below which seems wrong.

> +			len = xdp.data_end - xdp.data;
>   			break;
>   		case XDP_TX:
>   			if (unlikely(!virtnet_xdp_xmit(vi, rq, &xdp, skb)))
> @@ -446,6 +455,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
>   	}
>   	rcu_read_unlock();
>   
> +	skb_trim(skb, len);
>   	return skb;
>   
>   err_xdp:
> @@ -494,7 +504,7 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
>   				       unsigned int *len)
>   {
>   	struct page *page = alloc_page(GFP_ATOMIC);
> -	unsigned int page_off = 0;
> +	unsigned int page_off = VIRTIO_XDP_HEADROOM;
>   
>   	if (!page)
>   		return NULL;
> @@ -530,7 +540,8 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
>   		put_page(p);
>   	}
>   
> -	*len = page_off;
> +	/* Headroom does not contribute to packet length */
> +	*len = page_off - VIRTIO_XDP_HEADROOM;
>   	return page;
>   err_buf:
>   	__free_pages(page, 0);
> @@ -569,7 +580,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   						      page, offset, &len);
>   			if (!xdp_page)
>   				goto err_xdp;
> -			offset = 0;
> +			offset = VIRTIO_XDP_HEADROOM;
>   		} else {
>   			xdp_page = page;
>   		}
> @@ -582,19 +593,30 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   		if (unlikely(hdr->hdr.gso_type))
>   			goto err_xdp;
>   
> +		/* Allow consuming headroom but reserve enough space to push
> +		 * the descriptor on if we get an XDP_TX return code.
> +		 */
>   		data = page_address(xdp_page) + offset;
> +		xdp.data_hard_start = data - VIRTIO_XDP_HEADROOM + vi->hdr_len;

Should be data - VIRTIO_XDP_HEADROOM I think?

>   		xdp.data = data + vi->hdr_len;
>   		xdp.data_end = xdp.data + (len - vi->hdr_len);
>   		act = bpf_prog_run_xdp(xdp_prog, &xdp);
>   
>   		switch (act) {
>   		case XDP_PASS:
> +			/* recalculate offset to account for any header
> +			 * adjustments. Note other cases do not build an
> +			 * skb and avoid using offset
> +			 */
> +			offset = xdp.data -
> +					page_address(xdp_page) - vi->hdr_len;
> +
>   			/* We can only create skb based on xdp_page. */
>   			if (unlikely(xdp_page != page)) {
>   				rcu_read_unlock();
>   				put_page(page);
>   				head_skb = page_to_skb(vi, rq, xdp_page,
> -						       0, len, PAGE_SIZE);
> +						       offset, len, PAGE_SIZE);
>   				ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>   				return head_skb;
>   			}
> @@ -761,23 +783,30 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
>   	dev_kfree_skb(skb);
>   }
>   
> +static unsigned int virtnet_get_headroom(struct virtnet_info *vi)
> +{
> +	return vi->xdp_queue_pairs ? VIRTIO_XDP_HEADROOM : 0;
> +}
> +
>   static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
>   			     gfp_t gfp)
>   {
> +	int headroom = GOOD_PACKET_LEN + virtnet_get_headroom(vi);
> +	unsigned int xdp_headroom = virtnet_get_headroom(vi);
>   	struct sk_buff *skb;
>   	struct virtio_net_hdr_mrg_rxbuf *hdr;
>   	int err;
>   
> -	skb = __netdev_alloc_skb_ip_align(vi->dev, GOOD_PACKET_LEN, gfp);
> +	skb = __netdev_alloc_skb_ip_align(vi->dev, headroom, gfp);
>   	if (unlikely(!skb))
>   		return -ENOMEM;
>   
> -	skb_put(skb, GOOD_PACKET_LEN);
> +	skb_put(skb, headroom);
>   
>   	hdr = skb_vnet_hdr(skb);
>   	sg_init_table(rq->sg, 2);
>   	sg_set_buf(rq->sg, hdr, vi->hdr_len);
> -	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
> +	skb_to_sgvec(skb, rq->sg + 1, xdp_headroom, skb->len - xdp_headroom);
>   
>   	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
>   	if (err < 0)
> @@ -845,24 +874,27 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
>   	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
>   }
>   
> -static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> +static int add_recvbuf_mergeable(struct virtnet_info *vi,
> +				 struct receive_queue *rq, gfp_t gfp)
>   {
>   	struct page_frag *alloc_frag = &rq->alloc_frag;
> +	unsigned int headroom = virtnet_get_headroom(vi);
>   	char *buf;
>   	unsigned long ctx;
>   	int err;
>   	unsigned int len, hole;
>   
>   	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
> -	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
> +	if (unlikely(!skb_page_frag_refill(len + headroom, alloc_frag, gfp)))
>   		return -ENOMEM;
>   
>   	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> +	buf += headroom; /* advance address leaving hole at front of pkt */

Note: the headroom will reduce the possibility of frag coalescing which 
may damage the performance more or less.

[...]
