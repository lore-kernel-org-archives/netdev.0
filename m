From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH 5/5] virtio_net: XDP support for adjust_head
Date: Fri, 13 Jan 2017 00:22:44 +0200
Message-ID: <20170113002221-mutt-send-email-mst@kernel.org>
References: <20170112213919.3039.54165.stgit@john-Precision-Tower-5810>
 <20170112214519.3039.27879.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750995AbdALWWp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 17:22:45 -0500
Content-Disposition: inline
In-Reply-To: <20170112214519.3039.27879.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 01:45:19PM -0800, John Fastabend wrote:
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

Could you explain about this a bit more?
Thanks!

> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/virtio_net.c |  155 ++++++++++++++++++++++++++++++++++++++++------
>  drivers/virtio/virtio.c  |    9 ++-
>  include/linux/virtio.h   |    3 +
>  3 files changed, 144 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 6041828..8b897e7 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -28,6 +28,7 @@
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
>  #include <linux/average.h>
> +#include <linux/pci.h>
>  #include <net/busy_poll.h>
>  
>  static int napi_weight = NAPI_POLL_WEIGHT;
> @@ -159,6 +160,9 @@ struct virtnet_info {
>  	/* Ethtool settings */
>  	u8 duplex;
>  	u32 speed;
> +
> +	/* Headroom allocated in RX Queue */
> +	unsigned int headroom;
>  };
>  
>  struct padded_vnet_hdr {
> @@ -359,6 +363,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
>  	}
>  
>  	if (vi->mergeable_rx_bufs) {
> +		xdp->data -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
>  		/* Zero header and leave csum up to XDP layers */
>  		hdr = xdp->data;
>  		memset(hdr, 0, vi->hdr_len);
> @@ -375,7 +380,9 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
>  		num_sg = 2;
>  		sg_init_table(sq->sg, 2);
>  		sg_set_buf(sq->sg, hdr, vi->hdr_len);
> -		skb_to_sgvec(skb, sq->sg + 1, 0, skb->len);
> +		skb_to_sgvec(skb, sq->sg + 1,
> +			     xdp->data - xdp->data_hard_start,
> +			     xdp->data_end - xdp->data);
>  	}
>  	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
>  				   data, GFP_ATOMIC);
> @@ -401,7 +408,6 @@ static struct sk_buff *receive_small(struct net_device *dev,
>  	struct bpf_prog *xdp_prog;
>  
>  	len -= vi->hdr_len;
> -	skb_trim(skb, len);
>  
>  	rcu_read_lock();
>  	xdp_prog = rcu_dereference(rq->xdp_prog);
> @@ -413,11 +419,15 @@ static struct sk_buff *receive_small(struct net_device *dev,
>  		if (unlikely(hdr->hdr.gso_type || hdr->hdr.flags))
>  			goto err_xdp;
>  
> -		xdp.data = skb->data;
> +		xdp.data_hard_start = skb->data;
> +		xdp.data = skb->data + vi->headroom;
>  		xdp.data_end = xdp.data + len;
>  		act = bpf_prog_run_xdp(xdp_prog, &xdp);
>  		switch (act) {
>  		case XDP_PASS:
> +			/* Recalculate length in case bpf program changed it */
> +			len = xdp.data_end - xdp.data;
> +			__skb_pull(skb, xdp.data - xdp.data_hard_start);
>  			break;
>  		case XDP_TX:
>  			virtnet_xdp_xmit(vi, rq, &xdp, skb);
> @@ -432,6 +442,7 @@ static struct sk_buff *receive_small(struct net_device *dev,
>  	}
>  	rcu_read_unlock();
>  
> +	skb_trim(skb, len);
>  	return skb;
>  
>  err_xdp:
> @@ -569,7 +580,11 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  		if (unlikely(hdr->hdr.gso_type))
>  			goto err_xdp;
>  
> +		/* Allow consuming headroom but reserve enough space to push
> +		 * the descriptor on if we get an XDP_TX return code.
> +		 */
>  		data = page_address(xdp_page) + offset;
> +		xdp.data_hard_start = data - vi->headroom + desc_room;
>  		xdp.data = data + desc_room;
>  		xdp.data_end = xdp.data + (len - vi->hdr_len);
>  		act = bpf_prog_run_xdp(xdp_prog, &xdp);
> @@ -748,20 +763,21 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
>  static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
>  			     gfp_t gfp)
>  {
> +	int headroom = GOOD_PACKET_LEN + vi->headroom;
>  	struct sk_buff *skb;
>  	struct virtio_net_hdr_mrg_rxbuf *hdr;
>  	int err;
>  
> -	skb = __netdev_alloc_skb_ip_align(vi->dev, GOOD_PACKET_LEN, gfp);
> +	skb = __netdev_alloc_skb_ip_align(vi->dev, headroom, gfp);
>  	if (unlikely(!skb))
>  		return -ENOMEM;
>  
> -	skb_put(skb, GOOD_PACKET_LEN);
> +	skb_put(skb, headroom);
>  
>  	hdr = skb_vnet_hdr(skb);
>  	sg_init_table(rq->sg, 2);
>  	sg_set_buf(rq->sg, hdr, vi->hdr_len);
> -	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
> +	skb_to_sgvec(skb, rq->sg + 1, vi->headroom, skb->len - vi->headroom);
>  
>  	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
>  	if (err < 0)
> @@ -829,24 +845,27 @@ static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
>  	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
>  }
>  
> -static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> +static int add_recvbuf_mergeable(struct virtnet_info *vi,
> +				 struct receive_queue *rq, gfp_t gfp)
>  {
>  	struct page_frag *alloc_frag = &rq->alloc_frag;
> +	unsigned int headroom = vi->headroom;
>  	char *buf;
>  	unsigned long ctx;
>  	int err;
>  	unsigned int len, hole;
>  
>  	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
> -	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
> +	if (unlikely(!skb_page_frag_refill(len + headroom, alloc_frag, gfp)))
>  		return -ENOMEM;
>  
>  	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> +	buf += headroom; /* advance address leaving hole at front of pkt */
>  	ctx = mergeable_buf_to_ctx(buf, len);
>  	get_page(alloc_frag->page);
> -	alloc_frag->offset += len;
> +	alloc_frag->offset += len + headroom;
>  	hole = alloc_frag->size - alloc_frag->offset;
> -	if (hole < len) {
> +	if (hole < len + headroom) {
>  		/* To avoid internal fragmentation, if there is very likely not
>  		 * enough space for another buffer, add the remaining space to
>  		 * the current buffer. This extra space is not included in
> @@ -880,7 +899,7 @@ static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
>  	gfp |= __GFP_COLD;
>  	do {
>  		if (vi->mergeable_rx_bufs)
> -			err = add_recvbuf_mergeable(rq, gfp);
> +			err = add_recvbuf_mergeable(vi, rq, gfp);
>  		else if (vi->big_packets)
>  			err = add_recvbuf_big(vi, rq, gfp);
>  		else
> @@ -1675,12 +1694,90 @@ static void virtnet_init_settings(struct net_device *dev)
>  	.set_settings = virtnet_set_settings,
>  };
>  
> +#define VIRTIO_XDP_HEADROOM 256
> +
> +static int init_vqs(struct virtnet_info *vi);
> +static void remove_vq_common(struct virtnet_info *vi, bool lock);
> +
> +/* Reset virtio device with RTNL held this is very similar to the
> + * freeze()/restore() logic except we need to ensure locking. It is
> + * possible that this routine may fail and leave the driver in a
> + * failed state. However assuming the driver negotiated correctly
> + * at probe time we _should_ be able to (re)negotiate driver again.
> + */
> +static int virtnet_xdp_reset(struct virtnet_info *vi)
> +{
> +	struct virtio_device *vdev = vi->vdev;
> +	unsigned int status;
> +	int i, ret;
> +
> +	/* Disable and unwind rings */
> +	virtio_config_disable(vdev);
> +	vdev->failed = vdev->config->get_status(vdev) & VIRTIO_CONFIG_S_FAILED;
> +
> +	netif_device_detach(vi->dev);
> +	cancel_delayed_work_sync(&vi->refill);
> +	if (netif_running(vi->dev)) {
> +		for (i = 0; i < vi->max_queue_pairs; i++)
> +			napi_disable(&vi->rq[i].napi);
> +	}
> +
> +	remove_vq_common(vi, false);
> +
> +	/* Do a reset per virtio spec recommendation */
> +	vdev->config->reset(vdev);
> +
> +	/* Acknowledge that we've seen the device. */
> +	status = vdev->config->get_status(vdev);
> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_ACKNOWLEDGE);
> +
> +	/* Notify driver is up and finalize features per specification. The
> +	 * error code from finalize features is checked here but should not
> +	 * fail because we assume features were previously synced successfully.
> +	 */
> +	status = vdev->config->get_status(vdev);
> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_DRIVER);
> +	ret = virtio_finalize_features(vdev);
> +	if (ret) {
> +		netdev_warn(vi->dev, "virtio_finalize_features failed during reset aborting\n");
> +		goto err;
> +	}
> +
> +	ret = init_vqs(vi);
> +	if (ret) {
> +		netdev_warn(vi->dev, "init_vqs failed during reset aborting\n");
> +		goto err;
> +	}
> +	virtio_device_ready(vi->vdev);
> +
> +	if (netif_running(vi->dev)) {
> +		for (i = 0; i < vi->curr_queue_pairs; i++)
> +			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
> +				schedule_delayed_work(&vi->refill, 0);
> +
> +		for (i = 0; i < vi->max_queue_pairs; i++)
> +			virtnet_napi_enable(&vi->rq[i]);
> +	}
> +	netif_device_attach(vi->dev);
> +	/* Finally, tell the device we're all set */
> +	status = vdev->config->get_status(vdev);
> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_DRIVER_OK);
> +	virtio_config_enable(vdev);
> +
> +	return 0;
> +err:
> +	status = vdev->config->get_status(vdev);
> +	vdev->config->set_status(vdev, status | VIRTIO_CONFIG_S_FAILED);
> +	return ret;
> +}
> +
>  static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  {
>  	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct bpf_prog *old_prog;
>  	u16 xdp_qp = 0, curr_qp;
> +	unsigned int old_hr;
>  	int i, err;
>  
>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
> @@ -1712,18 +1809,31 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  		return -ENOMEM;
>  	}
>  
> -	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
> -	if (err) {
> -		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
> -		return err;
> -	}
> -
> +	old_hr = vi->headroom;
>  	if (prog) {
>  		prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
> -		if (IS_ERR(prog)) {
> -			virtnet_set_queues(vi, curr_qp);
> +		if (IS_ERR(prog))
>  			return PTR_ERR(prog);
> -		}
> +		vi->headroom = VIRTIO_XDP_HEADROOM;
> +	} else {
> +		vi->headroom = 0;
> +	}
> +
> +	/* Changing the headroom in buffers is a disruptive operation because
> +	 * existing buffers must be flushed and reallocated. This will happen
> +	 * when a xdp program is initially added or xdp is disabled by removing
> +	 * the xdp program.
> +	 */
> +	if (old_hr != vi->headroom) {
> +		err = virtnet_xdp_reset(vi);
> +		if (err)
> +			goto err_reset;
> +	}
> +
> +	err = virtnet_set_queues(vi, curr_qp + xdp_qp);
> +	if (err) {
> +		dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
> +		goto err_reset;
>  	}
>  
>  	vi->xdp_queue_pairs = xdp_qp;
> @@ -1737,6 +1847,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  	}
>  
>  	return 0;
> +err_reset:
> +	if (prog)
> +		bpf_prog_sub(prog, vi->max_queue_pairs - 1);
> +	vi->headroom = old_hr;
> +	return err;
>  }
>  
>  static bool virtnet_xdp_query(struct net_device *dev)
> diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
> index 7062bb0..0e922b9 100644
> --- a/drivers/virtio/virtio.c
> +++ b/drivers/virtio/virtio.c
> @@ -145,14 +145,15 @@ void virtio_config_changed(struct virtio_device *dev)
>  }
>  EXPORT_SYMBOL_GPL(virtio_config_changed);
>  
> -static void virtio_config_disable(struct virtio_device *dev)
> +void virtio_config_disable(struct virtio_device *dev)
>  {
>  	spin_lock_irq(&dev->config_lock);
>  	dev->config_enabled = false;
>  	spin_unlock_irq(&dev->config_lock);
>  }
> +EXPORT_SYMBOL_GPL(virtio_config_disable);
>  
> -static void virtio_config_enable(struct virtio_device *dev)
> +void virtio_config_enable(struct virtio_device *dev)
>  {
>  	spin_lock_irq(&dev->config_lock);
>  	dev->config_enabled = true;
> @@ -161,8 +162,9 @@ static void virtio_config_enable(struct virtio_device *dev)
>  	dev->config_change_pending = false;
>  	spin_unlock_irq(&dev->config_lock);
>  }
> +EXPORT_SYMBOL_GPL(virtio_config_enable);
>  
> -static int virtio_finalize_features(struct virtio_device *dev)
> +int virtio_finalize_features(struct virtio_device *dev)
>  {
>  	int ret = dev->config->finalize_features(dev);
>  	unsigned status;
> @@ -182,6 +184,7 @@ static int virtio_finalize_features(struct virtio_device *dev)
>  	}
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(virtio_finalize_features);
>  
>  static int virtio_dev_probe(struct device *_d)
>  {
> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
> index d5eb547..eac8f05 100644
> --- a/include/linux/virtio.h
> +++ b/include/linux/virtio.h
> @@ -137,6 +137,9 @@ static inline struct virtio_device *dev_to_virtio(struct device *_dev)
>  
>  void virtio_break_device(struct virtio_device *dev);
>  
> +void virtio_config_disable(struct virtio_device *dev);
> +void virtio_config_enable(struct virtio_device *dev);
> +int virtio_finalize_features(struct virtio_device *dev);
>  void virtio_config_changed(struct virtio_device *dev);
>  #ifdef CONFIG_PM_SLEEP
>  int virtio_device_freeze(struct virtio_device *dev);
