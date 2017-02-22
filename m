From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: switch to use build_skb() for small
 buffer
Date: Wed, 22 Feb 2017 09:17:04 -0800
Message-ID: <58ADC790.8000805@gmail.com>
References: <1487666788-9658-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36751 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932225AbdBVRRS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 12:17:18 -0500
In-Reply-To: <1487666788-9658-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-21 12:46 AM, Jason Wang wrote:
> This patch switch to use build_skb() for small buffer which can have
> better performance for both TCP and XDP (since we can work at page
> before skb creation). It also remove lots of XDP codes since both
> mergeable and small buffer use page frag during refill now.
> 
>                        Before   | After
> XDP_DROP(xdp1) 64B  :  11.1Mpps | 14.4Mpps
> 
> Tested with xdp1/xdp2/xdp_ip_tx_tunnel and netperf.

When you do the xdp tests are you generating packets with pktgen on the
corresponding tap devices?

Also another thought, have you looked at using some of the buffer recycling
techniques used in the hardware drivers such as ixgbe and with Eric's latest
patches mlx? I have seen significant performance increases for some
workloads doing this. I wanted to try something like this out on virtio
but haven't had time yet.

> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

[...]

>  static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
>  			     gfp_t gfp)
>  {
> -	int headroom = GOOD_PACKET_LEN + virtnet_get_headroom(vi);
> +	struct page_frag *alloc_frag = &rq->alloc_frag;
> +	char *buf;
>  	unsigned int xdp_headroom = virtnet_get_headroom(vi);
> -	struct sk_buff *skb;
> -	struct virtio_net_hdr_mrg_rxbuf *hdr;
> +	int len = vi->hdr_len + VIRTNET_RX_PAD + GOOD_PACKET_LEN + xdp_headroom;
>  	int err;
>  
> -	skb = __netdev_alloc_skb_ip_align(vi->dev, headroom, gfp);
> -	if (unlikely(!skb))
> +	len = SKB_DATA_ALIGN(len) +
> +	      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
>  		return -ENOMEM;
>  
> -	skb_put(skb, headroom);
> -
> -	hdr = skb_vnet_hdr(skb);
> -	sg_init_table(rq->sg, 2);
> -	sg_set_buf(rq->sg, hdr, vi->hdr_len);
> -	skb_to_sgvec(skb, rq->sg + 1, xdp_headroom, skb->len - xdp_headroom);
> -
> -	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
> +	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> +	get_page(alloc_frag->page);
> +	alloc_frag->offset += len;
> +	sg_init_one(rq->sg, buf + VIRTNET_RX_PAD + xdp_headroom,
> +		    vi->hdr_len + GOOD_PACKET_LEN);
> +	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);

Nice this cleans up a lot of the branching code. Thanks.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
