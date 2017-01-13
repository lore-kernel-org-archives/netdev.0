From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v3 1/5] virtio_net: use dev_kfree_skb for small buffer
 XDP receive
Date: Fri, 13 Jan 2017 11:47:13 +0800
Message-ID: <c2583ddd-5530-a58e-8c29-49ec47dcf087@redhat.com>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
 <20170113025036.4535.46911.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46252 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750960AbdAMDrV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 22:47:21 -0500
In-Reply-To: <20170113025036.4535.46911.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月13日 10:50, John Fastabend wrote:
> In the small buffer case during driver unload we currently use
> put_page instead of dev_kfree_skb. Resolve this by adding a check
> for virtnet mode when checking XDP queue type. Also name the
> function so that the code reads correctly to match the additional
> check.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   drivers/net/virtio_net.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4a10500..d97bb71 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1890,8 +1890,12 @@ static void free_receive_page_frags(struct virtnet_info *vi)
>   			put_page(vi->rq[i].alloc_frag.page);
>   }
>   
> -static bool is_xdp_queue(struct virtnet_info *vi, int q)
> +static bool is_xdp_raw_buffer_queue(struct virtnet_info *vi, int q)
>   {
> +	/* For small receive mode always use kfree_skb variants */
> +	if (!vi->mergeable_rx_bufs)
> +		return false;
> +
>   	if (q < (vi->curr_queue_pairs - vi->xdp_queue_pairs))
>   		return false;
>   	else if (q < vi->curr_queue_pairs)
> @@ -1908,7 +1912,7 @@ static void free_unused_bufs(struct virtnet_info *vi)
>   	for (i = 0; i < vi->max_queue_pairs; i++) {
>   		struct virtqueue *vq = vi->sq[i].vq;
>   		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
> -			if (!is_xdp_queue(vi, i))
> +			if (!is_xdp_raw_buffer_queue(vi, i))
>   				dev_kfree_skb(buf);
>   			else
>   				put_page(virt_to_head_page(buf));
>

Acked-by: Jason Wang <jasowang@redhat.com>
