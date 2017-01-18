From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small
 buffer XDP receive
Date: Wed, 18 Jan 2017 17:48:47 +0200
Message-ID: <20170118174841-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45614 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752629AbdARPst (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 10:48:49 -0500
Content-Disposition: inline
In-Reply-To: <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 02:19:50PM -0800, John Fastabend wrote:
> In the small buffer case during driver unload we currently use
> put_page instead of dev_kfree_skb. Resolve this by adding a check
> for virtnet mode when checking XDP queue type. Also name the
> function so that the code reads correctly to match the additional
> check.
> 
> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4a10500..d97bb71 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1890,8 +1890,12 @@ static void free_receive_page_frags(struct virtnet_info *vi)
>  			put_page(vi->rq[i].alloc_frag.page);
>  }
>  
> -static bool is_xdp_queue(struct virtnet_info *vi, int q)
> +static bool is_xdp_raw_buffer_queue(struct virtnet_info *vi, int q)
>  {
> +	/* For small receive mode always use kfree_skb variants */
> +	if (!vi->mergeable_rx_bufs)
> +		return false;
> +
>  	if (q < (vi->curr_queue_pairs - vi->xdp_queue_pairs))
>  		return false;
>  	else if (q < vi->curr_queue_pairs)
> @@ -1908,7 +1912,7 @@ static void free_unused_bufs(struct virtnet_info *vi)
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		struct virtqueue *vq = vi->sq[i].vq;
>  		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
> -			if (!is_xdp_queue(vi, i))
> +			if (!is_xdp_raw_buffer_queue(vi, i))
>  				dev_kfree_skb(buf);
>  			else
>  				put_page(virt_to_head_page(buf));
