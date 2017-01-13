From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v3 3/5] virtio_net: factor out xdp handler for
 readability
Date: Fri, 13 Jan 2017 15:40:48 +0800
Message-ID: <da246cbb-710c-275f-489c-251ea898a389@redhat.com>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
 <20170113025123.4535.75989.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750965AbdAMHvW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 02:51:22 -0500
In-Reply-To: <20170113025123.4535.75989.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月13日 10:51, John Fastabend wrote:
> At this point the do_xdp_prog is mostly if/else branches handling
> the different modes of virtio_net. So remove it and handle running
> the program in the per mode handlers.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   drivers/net/virtio_net.c |   76 +++++++++++++++++-----------------------------
>   1 file changed, 28 insertions(+), 48 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 43cb2e0..ec54644 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -388,49 +388,6 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
>   	virtqueue_kick(sq->vq);
>   }
>   

[...]

>   
>   		/* This happens when rx buffer size is underestimated */
> @@ -598,8 +570,10 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   		if (unlikely(hdr->hdr.gso_type))
>   			goto err_xdp;
>   
> -		act = do_xdp_prog(vi, rq, xdp_prog,
> -				  page_address(xdp_page) + offset, len);
> +		data = page_address(xdp_page) + offset;
> +		xdp.data = data + desc_room;
> +		xdp.data_end = xdp.data + (len - vi->hdr_len);

It looks desc_room is always vi->hdr_len.

> +		act = bpf_prog_run_xdp(xdp_prog, &xdp);
>   		switch (act) {
>   		case XDP_PASS:
>   			/* We can only create skb based on xdp_page. */
> @@ -613,13 +587,19 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>   			}
>   			break;
>   		case XDP_TX:
> +			qp = vi->curr_queue_pairs -
> +				vi->xdp_queue_pairs +
> +				smp_processor_id();
> +			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
>   			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>   			if (unlikely(xdp_page != page))
>   				goto err_xdp;
>   			rcu_read_unlock();
>   			goto xdp_xmit;
> -		case XDP_DROP:
>   		default:
> +			bpf_warn_invalid_xdp_action(act);
> +		case XDP_ABORTED:
> +		case XDP_DROP:
>   			if (unlikely(xdp_page != page))
>   				__free_pages(xdp_page, 0);
>   			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>
