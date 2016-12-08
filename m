From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v5 4/6] virtio_net: add dedicated XDP transmit
 queues
Date: Thu, 8 Dec 2016 07:59:54 +0200
Message-ID: <20161208075459-mutt-send-email-mst@kernel.org>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
 <20161207201223.28121.87060.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, shm@cumulusnetworks.com, davem@davemloft.net,
        tgraf@suug.ch, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750800AbcLHGAg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 01:00:36 -0500
Content-Disposition: inline
In-Reply-To: <20161207201223.28121.87060.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 12:12:23PM -0800, John Fastabend wrote:
> XDP requires using isolated transmit queues to avoid interference
> with normal networking stack (BQL, NETDEV_TX_BUSY, etc).
> This patch
> adds a XDP queue per cpu when a XDP program is loaded and does not
> expose the queues to the OS via the normal API call to
> netif_set_real_num_tx_queues(). This way the stack will never push
> an skb to these queues.
> 
> However virtio/vhost/qemu implementation only allows for creating
> TX/RX queue pairs at this time so creating only TX queues was not
> possible. And because the associated RX queues are being created I
> went ahead and exposed these to the stack and let the backend use
> them. This creates more RX queues visible to the network stack than
> TX queues which is worth mentioning but does not cause any issues as
> far as I can tell.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |   30 ++++++++++++++++++++++++++++--
>  1 file changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index a009299..28b1196 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -114,6 +114,9 @@ struct virtnet_info {
>  	/* # of queue pairs currently used by the driver */
>  	u16 curr_queue_pairs;
>  
> +	/* # of XDP queue pairs currently used by the driver */
> +	u16 xdp_queue_pairs;
> +
>  	/* I like... big packets and I cannot lie! */
>  	bool big_packets;
>  
> @@ -1547,7 +1550,8 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct bpf_prog *old_prog;
> -	int i;
> +	u16 xdp_qp = 0, curr_qp;
> +	int i, err;
>  
>  	if ((dev->features & NETIF_F_LRO) && prog) {
>  		netdev_warn(dev, "can't set XDP while LRO is on, disable LRO first\n");
> @@ -1564,12 +1568,34 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  		return -EINVAL;
>  	}
>  
> +	curr_qp = vi->curr_queue_pairs - vi->xdp_queue_pairs;
> +	if (prog)
> +		xdp_qp = nr_cpu_ids;
> +
> +	/* XDP requires extra queues for XDP_TX */
> +	if (curr_qp + xdp_qp > vi->max_queue_pairs) {
> +		netdev_warn(dev, "request %i queues but max is %i\n",
> +			    curr_qp + xdp_qp, vi->max_queue_pairs);
> +		return -ENOMEM;
> +	}

Can't we disable XDP_TX somehow? Many people might only want RX drop,
and extra queues are not always there.


> +
> +	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
> +	if (err) {
> +		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
> +		return err;
> +	}
> +
>  	if (prog) {
>  		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
> -		if (IS_ERR(prog))
> +		if (IS_ERR(prog)) {
> +			virtnet_set_queues(vi, curr_qp);
>  			return PTR_ERR(prog);
> +		}
>  	}
>  
> +	vi->xdp_queue_pairs = xdp_qp;
> +	netif_set_real_num_rx_queues(dev, curr_qp + xdp_qp);
> +
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		old_prog = rtnl_dereference(vi->rq[i].xdp_prog);
>  		rcu_assign_pointer(vi->rq[i].xdp_prog, prog);
