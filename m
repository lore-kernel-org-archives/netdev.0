From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH 3/5] virtio_net: remove duplicate queue pair
 binding in XDP
Date: Fri, 3 Feb 2017 06:23:13 +0200
Message-ID: <20170203062308-mutt-send-email-mst@kernel.org>
References: <20170202231404.14366.64298.stgit@john-Precision-Tower-5810>
 <20170202232114.14366.57526.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44986 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752409AbdBCEXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 23:23:16 -0500
Content-Disposition: inline
In-Reply-To: <20170202232114.14366.57526.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 03:21:14PM -0800, John Fastabend wrote:
> Factor out qp assignment.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |   18 +++++++-----------
>  1 file changed, 7 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b9576f2..2dcb142 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -341,15 +341,19 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
>  
>  static bool virtnet_xdp_xmit(struct virtnet_info *vi,
>  			     struct receive_queue *rq,
> -			     struct send_queue *sq,
>  			     struct xdp_buff *xdp,
>  			     void *data)
>  {
>  	struct virtio_net_hdr_mrg_rxbuf *hdr;
>  	unsigned int num_sg, len;
> +	struct send_queue *sq;
> +	unsigned int qp;
>  	void *xdp_sent;
>  	int err;
>  
> +	qp = vi->curr_queue_pairs - vi->xdp_queue_pairs + smp_processor_id();
> +	sq = &vi->sq[qp];
> +
>  	/* Free up any pending old buffers before queueing new ones. */
>  	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>  		if (vi->mergeable_rx_bufs) {
> @@ -415,7 +419,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
>  	if (xdp_prog) {
>  		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
>  		struct xdp_buff xdp;
> -		unsigned int qp;
>  		u32 act;
>  
>  		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
> @@ -429,10 +432,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
>  		case XDP_PASS:
>  			break;
>  		case XDP_TX:
> -			qp = vi->curr_queue_pairs -
> -				vi->xdp_queue_pairs +
> -				smp_processor_id();
> -			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, skb);
> +			virtnet_xdp_xmit(vi, rq, &xdp, skb);
>  			rcu_read_unlock();
>  			goto xdp_xmit;
>  		default:
> @@ -557,7 +557,6 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  	if (xdp_prog) {
>  		struct page *xdp_page;
>  		struct xdp_buff xdp;
> -		unsigned int qp;
>  		void *data;
>  		u32 act;
>  
> @@ -599,10 +598,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  			}
>  			break;
>  		case XDP_TX:
> -			qp = vi->curr_queue_pairs -
> -				vi->xdp_queue_pairs +
> -				smp_processor_id();
> -			virtnet_xdp_xmit(vi, rq, &vi->sq[qp], &xdp, data);
> +			virtnet_xdp_xmit(vi, rq, &xdp, data);
>  			ewma_pkt_len_add(&rq->mrg_avg_pkt_len, len);
>  			if (unlikely(xdp_page != page))
>  				goto err_xdp;
