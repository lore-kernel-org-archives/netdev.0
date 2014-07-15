From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next] virtio-net: rx busy polling support
Date: Tue, 15 Jul 2014 21:16:15 +0930
Message-ID: <871ttm4zg8.fsf@rustcorp.com.au>
References: <1405417265-13103-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1405417265-13103-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Jason Wang <jasowang@redhat.com> writes:
> Add basic support for rx busy polling.
>
> 1 byte netperf tcp_rr on mlx4 shows 116% improvement: the transaction
> rate was increased from 9151.94 to 19787.37.
>
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Nice!  But I'm deeply unqualified to review it :(

Thanks,
Rusty.

> ---
>  drivers/net/virtio_net.c | 241 +++++++++++++++++++++++++++++++++++++++++++----
>  1 file changed, 225 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 7d9f84a..a5ce604 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -27,6 +27,7 @@
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
>  #include <linux/average.h>
> +#include <net/busy_poll.h>
>  
>  static int napi_weight = NAPI_POLL_WEIGHT;
>  module_param(napi_weight, int, 0444);
> @@ -94,8 +95,144 @@ struct receive_queue {
>  
>  	/* Name of this receive queue: input.$index */
>  	char name[40];
> +
> +#ifdef CONFIG_NET_RX_BUSY_POLL
> +	unsigned int state;
> +#define VIRTNET_RQ_STATE_IDLE        0
> +#define VIRTNET_RQ_STATE_NAPI	     1    /* NAPI or refill owns this RQ */
> +#define VIRTNET_RQ_STATE_POLL	     2    /* poll owns this RQ */
> +#define VIRTNET_RQ_STATE_DISABLED    4    /* RQ is disabled */
> +#define VIRTNET_RQ_OWNED (VIRTNET_RQ_STATE_NAPI | VIRTNET_RQ_STATE_POLL)
> +#define VIRTNET_RQ_LOCKED (VIRTNET_RQ_OWNED | VIRTNET_RQ_STATE_DISABLED)
> +#define VIRTNET_RQ_STATE_NAPI_YIELD  8    /* NAPI or refill yielded this RQ */
> +#define VIRTNET_RQ_STATE_POLL_YIELD  16   /* poll yielded this RQ */
> +#define VIRTNET_RQ_YIELD (VIRTNET_RQ_STATE_NAPI_YIELD | VIRTNET_RQ_STATE_POLL_YIELD)
> +	spinlock_t lock;
> +#endif  /* CONFIG_NET_RX_BUSY_POLL */
>  };
>  
> +#ifdef CONFIG_NET_RX_BUSY_POLL
> +static inline void virtnet_rq_init_lock(struct receive_queue *rq)
> +{
> +
> +	spin_lock_init(&rq->lock);
> +	rq->state = VIRTNET_RQ_STATE_IDLE;
> +}
> +
> +/* called from the device poll routine or refill routine to get ownership of a
> + * receive queue.
> + */
> +static inline bool virtnet_rq_lock_napi_refill(struct receive_queue *rq)
> +{
> +	int rc = true;
> +
> +	spin_lock(&rq->lock);
> +	if (rq->state & VIRTNET_RQ_LOCKED) {
> +		WARN_ON(rq->state & VIRTNET_RQ_STATE_NAPI);
> +		rq->state |= VIRTNET_RQ_STATE_NAPI_YIELD;
> +		rc = false;
> +	} else
> +		/* we don't care if someone yielded */
> +		rq->state = VIRTNET_RQ_STATE_NAPI;
> +	spin_unlock(&rq->lock);
> +	return rc;
> +}
> +
> +/* returns true is someone tried to get the rq while napi or refill had it */
> +static inline bool virtnet_rq_unlock_napi_refill(struct receive_queue *rq)
> +{
> +	int rc = false;
> +
> +	spin_lock(&rq->lock);
> +	WARN_ON(rq->state & (VIRTNET_RQ_STATE_POLL |
> +			     VIRTNET_RQ_STATE_NAPI_YIELD));
> +
> +	if (rq->state & VIRTNET_RQ_STATE_POLL_YIELD)
> +		rc = true;
> +	/* will reset state to idle, unless RQ is disabled */
> +	rq->state &= VIRTNET_RQ_STATE_DISABLED;
> +	spin_unlock(&rq->lock);
> +	return rc;
> +}
> +
> +/* called from virtnet_low_latency_recv() */
> +static inline bool virtnet_rq_lock_poll(struct receive_queue *rq)
> +{
> +	int rc = true;
> +
> +	spin_lock_bh(&rq->lock);
> +	if ((rq->state & VIRTNET_RQ_LOCKED)) {
> +		rq->state |= VIRTNET_RQ_STATE_POLL_YIELD;
> +		rc = false;
> +	} else
> +		/* preserve yield marks */
> +		rq->state |= VIRTNET_RQ_STATE_POLL;
> +	spin_unlock_bh(&rq->lock);
> +	return rc;
> +}
> +
> +/* returns true if someone tried to get the receive queue while it was locked */
> +static inline bool virtnet_rq_unlock_poll(struct receive_queue *rq)
> +{
> +	int rc = false;
> +
> +	spin_lock_bh(&rq->lock);
> +	WARN_ON(rq->state & (VIRTNET_RQ_STATE_NAPI));
> +
> +	if (rq->state & VIRTNET_RQ_STATE_POLL_YIELD)
> +		rc = true;
> +	/* will reset state to idle, unless RQ is disabled */
> +	rq->state &= VIRTNET_RQ_STATE_DISABLED;
> +	spin_unlock_bh(&rq->lock);
> +	return rc;
> +}
> +
> +/* return false if RQ is currently owned */
> +static inline bool virtnet_rq_disable(struct receive_queue *rq)
> +{
> +	int rc = true;
> +
> +	spin_lock_bh(&rq->lock);
> +	if (rq->state & VIRTNET_RQ_OWNED)
> +		rc = false;
> +	rq->state |= VIRTNET_RQ_STATE_DISABLED;
> +	spin_unlock_bh(&rq->lock);
> +
> +	return rc;
> +}
> +
> +#else /* CONFIG_NET_RX_BUSY_POLL */
> +static inline void virtnet_rq_init_lock(struct receive_queue *rq)
> +{
> +}
> +
> +static inline bool virtnet_rq_lock_napi_refill(struct receive_queue *rq)
> +{
> +	return true;
> +}
> +
> +static inline bool virtnet_rq_unlock_napi_refill(struct receive_queue *rq)
> +{
> +	return false;
> +}
> +
> +static inline bool virtnet_rq_lock_poll(struct receive_queue *rq)
> +{
> +	return false;
> +}
> +
> +static inline bool virtnet_rq_unlock_poll(struct receive_queue *rq)
> +{
> +	return false;
> +}
> +
> +static inline bool virtnet_rq_disable(struct receive_queue *rq)
> +{
> +	return true;
> +}
> +
> +#endif /* CONFIG_NET_RX_BUSY_POLL */
> +
>  struct virtnet_info {
>  	struct virtio_device *vdev;
>  	struct virtqueue *cvq;
> @@ -521,6 +658,8 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  		skb_shinfo(skb)->gso_segs = 0;
>  	}
>  
> +	skb_mark_napi_id(skb, &rq->napi);
> +
>  	netif_receive_skb(skb);
>  	return;
>  
> @@ -714,7 +853,12 @@ static void refill_work(struct work_struct *work)
>  		struct receive_queue *rq = &vi->rq[i];
>  
>  		napi_disable(&rq->napi);
> +		if (!virtnet_rq_lock_napi_refill(rq)) {
> +			virtnet_napi_enable(rq);
> +			continue;
> +		}
>  		still_empty = !try_fill_recv(rq, GFP_KERNEL);
> +		virtnet_rq_unlock_napi_refill(rq);
>  		virtnet_napi_enable(rq);
>  
>  		/* In theory, this can happen: if we don't get any buffers in
> @@ -725,16 +869,13 @@ static void refill_work(struct work_struct *work)
>  	}
>  }
>  
> -static int virtnet_poll(struct napi_struct *napi, int budget)
> +static int virtnet_receive(struct receive_queue *rq, int budget)
>  {
> -	struct receive_queue *rq =
> -		container_of(napi, struct receive_queue, napi);
>  	struct virtnet_info *vi = rq->vq->vdev->priv;
>  	void *buf;
> -	unsigned int r, len, received = 0;
> +	unsigned int len, received = 0;
>  
> -again:
> -	while (received < budget &&
> +	while ((received < budget) &&
>  	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
>  		receive_buf(rq, buf, len);
>  		received++;
> @@ -745,6 +886,24 @@ again:
>  			schedule_delayed_work(&vi->refill, 0);
>  	}
>  
> +	return received;
> +}
> +
> +static int virtnet_poll(struct napi_struct *napi, int budget)
> +{
> +	struct receive_queue *rq =
> +		container_of(napi, struct receive_queue, napi);
> +	unsigned int r, received = 0;
> +
> +again:
> +
> +	if (!virtnet_rq_lock_napi_refill(rq))
> +		return budget;
> +
> +	received = virtnet_receive(rq, budget);
> +
> +	virtnet_rq_unlock_napi_refill(rq);
> +
>  	/* Out of packets? */
>  	if (received < budget) {
>  		r = virtqueue_enable_cb_prepare(rq->vq);
> @@ -760,6 +919,52 @@ again:
>  	return received;
>  }
>  
> +#ifdef CONFIG_NET_RX_BUSY_POLL
> +/* must be called with local_bh_disable()d */
> +static int virtnet_low_latency_recv(struct napi_struct *napi)
> +{
> +	struct receive_queue *rq =
> +		container_of(napi, struct receive_queue, napi);
> +	struct virtnet_info *vi = rq->vq->vdev->priv;
> +	int received;
> +
> +	if (!(vi->status & VIRTIO_NET_S_LINK_UP))
> +		return LL_FLUSH_FAILED;
> +
> +	if (!virtnet_rq_lock_poll(rq))
> +		return LL_FLUSH_BUSY;
> +
> +	received = virtnet_receive(rq, 4);
> +
> +	virtnet_rq_unlock_poll(rq);
> +
> +	return received;
> +}
> +#endif	/* CONFIG_NET_RX_BUSY_POLL */
> +
> +static void virtnet_napi_enable_all(struct virtnet_info *vi)
> +{
> +	int i;
> +
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		virtnet_rq_init_lock(&vi->rq[i]);
> +		virtnet_napi_enable(&vi->rq[i]);
> +	}
> +}
> +
> +static void virtnet_napi_disable_all(struct virtnet_info *vi)
> +{
> +	int i;
> +
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		napi_disable(&vi->rq[i].napi);
> +		while (!virtnet_rq_disable(&vi->rq[i])) {
> +			pr_info("RQ %d locked\n", i);
> +			usleep_range(1000, 20000);
> +		}
> +	}
> +}
> +
>  static int virtnet_open(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> @@ -770,9 +975,10 @@ static int virtnet_open(struct net_device *dev)
>  			/* Make sure we have some buffers: if oom use wq. */
>  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
> -		virtnet_napi_enable(&vi->rq[i]);
>  	}
>  
> +	virtnet_napi_enable_all(vi);
> +
>  	return 0;
>  }
>  
> @@ -1076,13 +1282,11 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
>  static int virtnet_close(struct net_device *dev)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> -	int i;
>  
>  	/* Make sure refill_work doesn't re-enable napi! */
>  	cancel_delayed_work_sync(&vi->refill);
>  
> -	for (i = 0; i < vi->max_queue_pairs; i++)
> -		napi_disable(&vi->rq[i].napi);
> +	virtnet_napi_disable_all(vi);
>  
>  	return 0;
>  }
> @@ -1347,6 +1551,9 @@ static const struct net_device_ops virtnet_netdev = {
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller = virtnet_netpoll,
>  #endif
> +#ifdef CONFIG_NET_RX_BUSY_POLL
> +	.ndo_busy_poll		= virtnet_low_latency_recv,
> +#endif
>  };
>  
>  static void virtnet_config_changed_work(struct work_struct *work)
> @@ -1552,6 +1759,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
>  		vi->rq[i].pages = NULL;
>  		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
>  			       napi_weight);
> +		napi_hash_add(&vi->rq[i].napi);
>  
>  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
>  		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
> @@ -1854,10 +2062,12 @@ static int virtnet_freeze(struct virtio_device *vdev)
>  	cancel_delayed_work_sync(&vi->refill);
>  
>  	if (netif_running(vi->dev))
> -		for (i = 0; i < vi->max_queue_pairs; i++) {
> -			napi_disable(&vi->rq[i].napi);
> -			netif_napi_del(&vi->rq[i].napi);
> -		}
> +		virtnet_napi_disable_all(vi);
> +
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
> +		napi_hash_del(&vi->rq[i].napi);
> +		netif_napi_del(&vi->rq[i].napi);
> +	}
>  
>  	remove_vq_common(vi);
>  
> @@ -1880,8 +2090,7 @@ static int virtnet_restore(struct virtio_device *vdev)
>  			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
>  
> -		for (i = 0; i < vi->max_queue_pairs; i++)
> -			virtnet_napi_enable(&vi->rq[i]);
> +		virtnet_napi_enable_all(vi);
>  	}
>  
>  	netif_device_attach(vi->dev);
> -- 
> 1.9.1
