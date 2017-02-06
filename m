From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next PATCH v2 2/5] virtio_net: factor out xdp handler for
 readability
Date: Mon, 6 Feb 2017 14:49:09 +0800
Message-ID: <7eb3b18d-7c1c-9808-e37e-2dd458aac655@redhat.com>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
 <20170203031501.23054.61223.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, kubakici@wp.pl,
        ast@fb.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52134 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751047AbdBFGtR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 01:49:17 -0500
In-Reply-To: <20170203031501.23054.61223.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年02月03日 11:15, John Fastabend wrote:
> At this point the do_xdp_prog is mostly if/else branches handling
> the different modes of virtio_net. So remove it and handle running
> the program in the per mode handlers.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jason Wang <jasowang@redhat.com>

> ---
>   drivers/net/virtio_net.c |   86 +++++++++++++++++++---------------------------
>   1 file changed, 35 insertions(+), 51 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f8ba586..3b49363 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -399,52 +399,6 @@ static bool virtnet_xdp_xmit(struct virtnet_info *vi,
>   	return true;
>   }
>   
> -static u32 do_xdp_prog(struct virtnet_info *vi,
> -		       struct receive_queue *rq,
> -		       struct bpf_prog *xdp_prog,
> -		       void *data, int len)
> -{
> -	int hdr_padded_len;
> -	struct xdp_buff xdp;
> -	void *buf;
> -	unsigned int qp;
> -	u32 act;
> -
> -	if (vi->mergeable_rx_bufs) {
> -		hdr_padded_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> -		xdp.data = data + hdr_padded_len;
> -		xdp.data_end = xdp.data + (len - vi->hdr_len);
> -		buf = data;
> -	} else { /* small buffers */
> -		struct sk_buff *skb = data;
> -
> -		xdp.data = skb->data;
> -		xdp.data_end = xdp.data + len;
> -		buf = skb->data;
> -	}
> -
> -	act = bpf_prog_run_xdp(xdp_prog, &xdp);
> -	switch (act) {
> -	case XDP_PASS:
> -		return XDP_PASS;
> -	case XDP_TX:
> -		qp = vi->curr_queue_pairs -
> -			vi->xdp_queue_pairs +
> -			smp_processor_id();
> -		xdp.data = buf;
> -		if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp,
> -					       data)))
> -			trace_xdp_exception(vi->dev, xdp_prog, act);
> -		return XDP_TX;
> -	default:
> -		bpf_warn_invalid_xdp_action(act);
> -	case XDP_ABORTED:
> -		trace_xdp_exception(vi->dev, xdp_prog, act);
> -	case XDP_DROP:
> -		return XDP_DROP;
> -	}
> -}
> -
>   static struct sk_buff *receive_small(struct net_device *dev,
>   				     struct virtnet_info *vi,
>   				     struct receive_queue *rq,
> @@ -460,19 +414,34 @@ static struct sk_buff *receive_small(struct net_device *dev,
>   	xdp_prog = rcu_dereference(rq->xdp_prog);
>   	if (xdp_prog) {
>   		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
> +		struct xdp_buff xdp;
> +		unsigned int qp;
>   		u32 act;
>   
>   		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
>   			goto err_xdp;
> -		act = do_xdp_prog(vi, rq, xdp_prog, skb, len);
> +
> +		xdp.data = skb->data;
> +		xdp.data_end = xdp.data + len;
> +		act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +
>   		switch (act) {
>   		case XDP_PASS:
>   			break;
>   		case XDP_TX:
> +			qp = vi->curr_queue_pairs -
> +				vi->xdp_queue_pairs +
> +				smp_processor_id();
> +			if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp],
> +						       &xdp, skb)))
> +				trace_xdp_exception(vi->dev, xdp_prog, act);
>   			rcu_read_unlock();
>   			goto xdp_xmit;
> -		case XDP_DROP:
>   		default:
> +			bpf_warn_invalid_xdp_action(act);
> +		case XDP_ABORTED:
> +			trace_xdp_exception(vi->dev, xdp_prog, act);
> +		case XDP_DROP:
>   			goto err_xdp;
>   		}
>   	}
> @@ -590,6 +559,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   	xdp_prog = rcu_dereference(rq->xdp_prog);
>   	if (xdp_prog) {
>   		struct page *xdp_page;
> +		struct xdp_buff xdp;
> +		unsigned int qp;
> +		void *data;
>   		u32 act;
>   
>   		/* This happens when rx buffer size is underestimated */
> @@ -612,8 +584,11 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   		if (unlikely(hdr->hdr.gso_type))
>   			goto err_xdp;
>   
> -		act = do_xdp_prog(vi, rq, xdp_prog,
> -				  page_address(xdp_page) + offset, len);
> +		data = page_address(xdp_page) + offset;
> +		xdp.data = data + vi->hdr_len;
> +		xdp.data_end = xdp.data + (len - vi->hdr_len);
> +		act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +
>   		switch (act) {
>   		case XDP_PASS:
>   			/* We can only create skb based on xdp_page. */
> @@ -627,13 +602,22 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   			}
>   			break;
>   		case XDP_TX:
> +			qp = vi->curr_queue_pairs -
> +				vi->xdp_queue_pairs +
> +				smp_processor_id();
> +			if (unlikely(!virtnet_xdp_xmit(vi, rq, &vi->sq[qp],
> +						       &xdp, data)))
> +				trace_xdp_exception(vi->dev, xdp_prog, act);
>   			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>   			if (unlikely(xdp_page != page))
>   				goto err_xdp;
>   			rcu_read_unlock();
>   			goto xdp_xmit;
> -		case XDP_DROP:
>   		default:
> +			bpf_warn_invalid_xdp_action(act);
> +		case XDP_ABORTED:
> +			trace_xdp_exception(vi->dev, xdp_prog, act);
> +		case XDP_DROP:
>   			if (unlikely(xdp_page != page))
>   				__free_pages(xdp_page, 0);
>   			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>
