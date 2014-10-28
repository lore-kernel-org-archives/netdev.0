From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 1/4] virtio_net: pass vi around
Date: Tue, 28 Oct 2014 10:57:31 +1030
Message-ID: <8738a9avik.fsf@rustcorp.com.au>
References: <1414099656-28090-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414099656-28090-1-git-send-email-mst@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> Too many places poke at [rs]q->vq->vdev->priv just to get
> the the vi structure.  Let's just pass the pointer around: seems
> cleaner, and might even be faster.

Agreed, it's neater.

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.

>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/virtio_net.c | 36 +++++++++++++++++++-----------------
>  1 file changed, 19 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 57cbc7d..36f3dfc 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -241,11 +241,11 @@ static unsigned long mergeable_buf_to_ctx(void *buf, unsigned int truesize)
>  }
>  
>  /* Called from bottom half context */
> -static struct sk_buff *page_to_skb(struct receive_queue *rq,
> +static struct sk_buff *page_to_skb(struct virtnet_info *vi,
> +				   struct receive_queue *rq,
>  				   struct page *page, unsigned int offset,
>  				   unsigned int len, unsigned int truesize)
>  {
> -	struct virtnet_info *vi = rq->vq->vdev->priv;
>  	struct sk_buff *skb;
>  	struct skb_vnet_hdr *hdr;
>  	unsigned int copy, hdr_len, hdr_padded_len;
> @@ -328,12 +328,13 @@ static struct sk_buff *receive_small(void *buf, unsigned int len)
>  }
>  
>  static struct sk_buff *receive_big(struct net_device *dev,
> +				   struct virtnet_info *vi,
>  				   struct receive_queue *rq,
>  				   void *buf,
>  				   unsigned int len)
>  {
>  	struct page *page = buf;
> -	struct sk_buff *skb = page_to_skb(rq, page, 0, len, PAGE_SIZE);
> +	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
>  
>  	if (unlikely(!skb))
>  		goto err;
> @@ -359,7 +360,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  	int offset = buf - page_address(page);
>  	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
>  
> -	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, truesize);
> +	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
> +					       truesize);
>  	struct sk_buff *curr_skb = head_skb;
>  
>  	if (unlikely(!curr_skb))
> @@ -433,9 +435,9 @@ err_buf:
>  	return NULL;
>  }
>  
> -static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
> +static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
> +			void *buf, unsigned int len)
>  {
> -	struct virtnet_info *vi = rq->vq->vdev->priv;
>  	struct net_device *dev = vi->dev;
>  	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>  	struct sk_buff *skb;
> @@ -459,9 +461,9 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  	if (vi->mergeable_rx_bufs)
>  		skb = receive_mergeable(dev, vi, rq, (unsigned long)buf, len);
>  	else if (vi->big_packets)
> -		skb = receive_big(dev, rq, buf, len);
> +		skb = receive_big(dev, vi, rq, buf, len);
>  	else
> -		skb = receive_small(buf, len);
> +		skb = receive_small(vi, buf, len);
>  
>  	if (unlikely(!skb))
>  		return;
> @@ -530,9 +532,9 @@ frame_err:
>  	dev_kfree_skb(skb);
>  }
>  
> -static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
> +static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
> +			     gfp_t gfp)
>  {
> -	struct virtnet_info *vi = rq->vq->vdev->priv;
>  	struct sk_buff *skb;
>  	struct skb_vnet_hdr *hdr;
>  	int err;
> @@ -655,9 +657,9 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>   * before we're receiving packets, or from refill_work which is
>   * careful to disable receiving (using napi_disable).
>   */
> -static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
> +static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
> +			  gfp_t gfp)
>  {
> -	struct virtnet_info *vi = rq->vq->vdev->priv;
>  	int err;
>  	bool oom;
>  
> @@ -668,7 +670,7 @@ static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
>  		else if (vi->big_packets)
>  			err = add_recvbuf_big(rq, gfp);
>  		else
> -			err = add_recvbuf_small(rq, gfp);
> +			err = add_recvbuf_small(vi, rq, gfp);
>  
>  		oom = err == -ENOMEM;
>  		if (err)
> @@ -717,7 +719,7 @@ static void refill_work(struct work_struct *work)
>  		struct receive_queue *rq = &vi->rq[i];
>  
>  		napi_disable(&rq->napi);
> -		still_empty = !try_fill_recv(rq, GFP_KERNEL);
> +		still_empty = !try_fill_recv(vi, rq, GFP_KERNEL);
>  		virtnet_napi_enable(rq);
>  
>  		/* In theory, this can happen: if we don't get any buffers in
> @@ -736,12 +738,12 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
>  
>  	while (received < budget &&
>  	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
> -		receive_buf(rq, buf, len);
> +		receive_buf(vi, rq, buf, len);
>  		received++;
>  	}
>  
>  	if (rq->vq->num_free > virtqueue_get_vring_size(rq->vq) / 2) {
> -		if (!try_fill_recv(rq, GFP_ATOMIC))
> +		if (!try_fill_recv(vi, rq, GFP_ATOMIC))
>  			schedule_delayed_work(&vi->refill, 0);
>  	}
>  
> @@ -817,7 +819,7 @@ static int virtnet_open(struct net_device *dev)
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		if (i < vi->curr_queue_pairs)
>  			/* Make sure we have some buffers: if oom use wq. */
> -			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
> +			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
>  				schedule_delayed_work(&vi->refill, 0);
>  		virtnet_napi_enable(&vi->rq[i]);
>  	}
> -- 
> MST
