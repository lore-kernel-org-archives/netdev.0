From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Wed, 08 Jan 2014 14:23:47 +0800
Message-ID: <52CCEEF3.5070904@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	virtualization@lists.linux-foundation.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389072355-20666-3-git-send-email-mwdalton@google.com>
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

On 01/07/2014 01:25 PM, Michael Dalton wrote:
> Commit 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page frag
> allocators") changed the mergeable receive buffer size from PAGE_SIZE to
> MTU-size, introducing a single-stream regression for benchmarks with large
> average packet size. There is no single optimal buffer size for all
> workloads.  For workloads with packet size <= MTU bytes, MTU + virtio-net
> header-sized buffers are preferred as larger buffers reduce the TCP window
> due to SKB truesize. However, single-stream workloads with large average
> packet sizes have higher throughput if larger (e.g., PAGE_SIZE) buffers
> are used.
>
> This commit auto-tunes the mergeable receiver buffer packet size by
> choosing the packet buffer size based on an EWMA of the recent packet
> sizes for the receive queue. Packet buffer sizes range from MTU_SIZE +
> virtio-net header len to PAGE_SIZE. This improves throughput for
> large packet workloads, as any workload with average packet size >=
> PAGE_SIZE will use PAGE_SIZE buffers.
>
> These optimizations interact positively with recent commit
> ba275241030c ("virtio-net: coalesce rx frags when possible during rx"),
> which coalesces adjacent RX SKB fragments in virtio_net. The coalescing
> optimizations benefit buffers of any size.
>
> Benchmarks taken from an average of 5 netperf 30-second TCP_STREAM runs
> between two QEMU VMs on a single physical machine. Each VM has two VCPUs
> with all offloads & vhost enabled. All VMs and vhost threads run in a
> single 4 CPU cgroup cpuset, using cgroups to ensure that other processes
> in the system will not be scheduled on the benchmark CPUs. Trunk includes
> SKB rx frag coalescing.
>
> net-next w/ virtio_net before 2613af0ed18a (PAGE_SIZE bufs): 14642.85Gb/s
> net-next (MTU-size bufs):  13170.01Gb/s
> net-next + auto-tune: 14555.94Gb/s
>
> Jason Wang also reported a throughput increase on mlx4 from 22Gb/s
> using MTU-sized buffers to about 26Gb/s using auto-tuning.
>
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---
> v2: Add per-receive queue metadata ring to track precise truesize for
>     mergeable receive buffers. Remove all truesize approximation. Never
>     try to fill a full RX ring (required for metadata ring in v2).
>
>  drivers/net/virtio_net.c | 145 ++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 107 insertions(+), 38 deletions(-)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 526dfd8..f6e1ee0 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -26,6 +26,7 @@
>  #include <linux/if_vlan.h>
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
> +#include <linux/average.h>
>  
>  static int napi_weight = NAPI_POLL_WEIGHT;
>  module_param(napi_weight, int, 0444);
> @@ -36,11 +37,15 @@ module_param(gso, bool, 0444);
>  
>  /* FIXME: MTU in config. */
>  #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
> -#define MERGE_BUFFER_LEN (ALIGN(GOOD_PACKET_LEN + \
> -                                sizeof(struct virtio_net_hdr_mrg_rxbuf), \
> -                                L1_CACHE_BYTES))
>  #define GOOD_COPY_LEN	128
>  
> +/* Weight used for the RX packet size EWMA. The average packet size is used to
> + * determine the packet buffer size when refilling RX rings. As the entire RX
> + * ring may be refilled at once, the weight is chosen so that the EWMA will be
> + * insensitive to short-term, transient changes in packet size.
> + */
> +#define RECEIVE_AVG_WEIGHT 64
> +
>  #define VIRTNET_DRIVER_VERSION "1.0.0"
>  
>  struct virtnet_stats {
> @@ -65,11 +70,30 @@ struct send_queue {
>  	char name[40];
>  };
>  
> +/* Per-packet buffer context for mergeable receive buffers. */
> +struct mergeable_receive_buf_ctx {
> +	/* Packet buffer base address. */
> +	void *buf;
> +
> +	/* Original size of the packet buffer for use in SKB truesize. Does not
> +	 * include any padding space used to avoid internal fragmentation.
> +	 */
> +	unsigned int truesize;
> +};
> +
>  /* Internal representation of a receive virtqueue */
>  struct receive_queue {
>  	/* Virtqueue associated with this receive_queue */
>  	struct virtqueue *vq;
>  
> +	/* Circular buffer of mergeable rxbuf contexts. */
> +	struct mergeable_receive_buf_ctx *mrg_buf_ctx;
> +
> +	/* Number of elements & head index of mrg_buf_ctx. Size must be
> +	 * equal to the associated virtqueue's vring size.
> +	 */
> +	unsigned int mrg_buf_ctx_size, mrg_buf_ctx_head;
> +
>  	struct napi_struct napi;
>  
>  	/* Number of input buffers, and max we've ever had. */
> @@ -78,6 +102,9 @@ struct receive_queue {
>  	/* Chain pages by the private ptr. */
>  	struct page *pages;
>  
> +	/* Average packet length for mergeable receive buffers. */
> +	struct ewma mrg_avg_pkt_len;
> +
>  	/* Page frag for packet buffer allocation. */
>  	struct page_frag alloc_frag;
>  
> @@ -327,32 +354,32 @@ err:
>  
>  static struct sk_buff *receive_mergeable(struct net_device *dev,
>  					 struct receive_queue *rq,
> -					 void *buf,
> +					 struct mergeable_receive_buf_ctx *ctx,
>  					 unsigned int len)
>  {
> -	struct skb_vnet_hdr *hdr = buf;
> +	struct skb_vnet_hdr *hdr = ctx->buf;
>  	int num_buf = hdr->mhdr.num_buffers;
> -	struct page *page = virt_to_head_page(buf);
> -	int offset = buf - page_address(page);
> -	unsigned int truesize = max_t(unsigned int, len, MERGE_BUFFER_LEN);
> +	struct page *page = virt_to_head_page(ctx->buf);
> +	int offset = ctx->buf - page_address(page);
> +	unsigned int truesize = max(len, ctx->truesize);

This looks unnecessary, we've already had precise truesize for this
buffer. ctx->trusize should be always greater or equal to len here.
> +
>  	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, truesize);
>  	struct sk_buff *curr_skb = head_skb;
>  
>  	if (unlikely(!curr_skb))
>  		goto err_skb;
> -
>  	while (--num_buf) {
>  		int num_skb_frags;
>  
> -		buf = virtqueue_get_buf(rq->vq, &len);
> -		if (unlikely(!buf)) {
> +		ctx = virtqueue_get_buf(rq->vq, &len);
> +		if (unlikely(!ctx)) {
>  			pr_debug("%s: rx error: %d buffers out of %d missing\n",
>  				 dev->name, num_buf, hdr->mhdr.num_buffers);
>  			dev->stats.rx_length_errors++;
>  			goto err_buf;
>  		}
>  
> -		page = virt_to_head_page(buf);
> +		page = virt_to_head_page(ctx->buf);
>  		--rq->num;
>  
>  		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
> @@ -369,13 +396,13 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  			head_skb->truesize += nskb->truesize;
>  			num_skb_frags = 0;
>  		}
> -		truesize = max_t(unsigned int, len, MERGE_BUFFER_LEN);
> +		truesize = max(len, ctx->truesize);

And this.
>  		if (curr_skb != head_skb) {
>  			head_skb->data_len += len;
>  			head_skb->len += len;
>  			head_skb->truesize += truesize;
>  		}
> -		offset = buf - page_address(page);
> +		offset = ctx->buf - page_address(page);
>  		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
>  			put_page(page);
>  			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
> @@ -386,19 +413,20 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  		}
>  	}
>  
> +	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
>  	return head_skb;
>  
>  err_skb:
>  	put_page(page);
>  	while (--num_buf) {
> -		buf = virtqueue_get_buf(rq->vq, &len);
> -		if (unlikely(!buf)) {
> +		ctx = virtqueue_get_buf(rq->vq, &len);
> +		if (unlikely(!ctx)) {
>  			pr_debug("%s: rx error: %d buffers missing\n",
>  				 dev->name, num_buf);
>  			dev->stats.rx_length_errors++;
>  			break;
>  		}
> -		page = virt_to_head_page(buf);
> +		page = virt_to_head_page(ctx->buf);
>  		put_page(page);
>  		--rq->num;
>  	}
> @@ -419,12 +447,14 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
>  	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
>  		pr_debug("%s: short packet %i\n", dev->name, len);
>  		dev->stats.rx_length_errors++;
> -		if (vi->mergeable_rx_bufs)
> -			put_page(virt_to_head_page(buf));
> -		else if (vi->big_packets)
> +		if (vi->mergeable_rx_bufs) {
> +			struct mergeable_receive_buf_ctx *ctx = buf;
> +			put_page(virt_to_head_page(ctx->buf));
> +		} else if (vi->big_packets) {
>  			give_pages(rq, buf);
> -		else
> +		} else {
>  			dev_kfree_skb(buf);
> +		}
>  		return;
>  	}
>  
> @@ -572,29 +602,43 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
>  
>  static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>  {
> +	const unsigned int ring_size = rq->mrg_buf_ctx_size;
> +	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>  	struct page_frag *alloc_frag = &rq->alloc_frag;
> -	char *buf;
> +	struct mergeable_receive_buf_ctx *ctx;
>  	int err;
>  	unsigned int len, hole;
>  
> -	if (unlikely(!skb_page_frag_refill(MERGE_BUFFER_LEN, alloc_frag, gfp)))
> +	len = hdr_len + clamp_t(unsigned int, ewma_read(&rq->mrg_avg_pkt_len),
> +				GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> +	len = ALIGN(len, L1_CACHE_BYTES);
> +	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
>  		return -ENOMEM;
> -	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> +
> +	ctx = &rq->mrg_buf_ctx[rq->mrg_buf_ctx_head];
> +	ctx->buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> +	ctx->truesize = len;
>  	get_page(alloc_frag->page);
> -	len = MERGE_BUFFER_LEN;
>  	alloc_frag->offset += len;
>  	hole = alloc_frag->size - alloc_frag->offset;
> -	if (hole < MERGE_BUFFER_LEN) {
> +	if (hole < len) {
> +		/* To avoid internal fragmentation, if there is very likely not
> +		 * enough space for another buffer, add the remaining space to
> +		 * the current buffer. This extra space is not included in
> +		 * ctx->truesize.
> +		 */

What's the reason that this extra space is not accounted for truesize?
>  		len += hole;
>  		alloc_frag->offset += hole;
>  	}
>  
> -	sg_init_one(rq->sg, buf, len);
> -	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
> -	if (err < 0)
> -		put_page(virt_to_head_page(buf));
> -
> -	return err;
> +	sg_init_one(rq->sg, ctx->buf, len);
> +	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, ctx, gfp);
> +	if (err < 0) {
> +		put_page(virt_to_head_page(ctx->buf));
> +		return err;

Should we also roll back the frag offset added above to avoid leaking frags?
> +	}
> +	rq->mrg_buf_ctx_head = (rq->mrg_buf_ctx_head + 1) & (ring_size - 1);
> +	return 0;
>  }
>  
>  /*
> @@ -610,6 +654,9 @@ static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
>  	int err;
>  	bool oom;
>  
> +	/* Do not attempt to add a buffer if the RX ring is full. */
> +	if (unlikely(!rq->vq->num_free))
> +		return true;

I haven't figured out why this is needed. It seems safe for
virtqueue_add_inbuf() just fail in add_recv_xx()?
>  	gfp |= __GFP_COLD;
>  	do {
>  		if (vi->mergeable_rx_bufs)
> @@ -1354,8 +1401,10 @@ static void virtnet_free_queues(struct virtnet_info *vi)
>  {
>  	int i;
>  
> -	for (i = 0; i < vi->max_queue_pairs; i++)
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		netif_napi_del(&vi->rq[i].napi);
> +		kfree(vi->rq[i].mrg_buf_ctx);
> +	}
>  
>  	kfree(vi->rq);
>  	kfree(vi->sq);
> @@ -1394,12 +1443,14 @@ static void free_unused_bufs(struct virtnet_info *vi)
>  		struct virtqueue *vq = vi->rq[i].vq;
>  
>  		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
> -			if (vi->mergeable_rx_bufs)
> -				put_page(virt_to_head_page(buf));
> -			else if (vi->big_packets)
> +			if (vi->mergeable_rx_bufs) {
> +				struct mergeable_receive_buf_ctx *ctx = buf;
> +				put_page(virt_to_head_page(ctx->buf));
> +			} else if (vi->big_packets) {
>  				give_pages(&vi->rq[i], buf);
> -			else
> +			} else {
>  				dev_kfree_skb(buf);
> +			}
>  			--vi->rq[i].num;
>  		}
>  		BUG_ON(vi->rq[i].num != 0);
> @@ -1509,6 +1560,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
>  			       napi_weight);
>  
>  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
> +		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
>  		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
>  	}
>  
> @@ -1522,7 +1574,8 @@ err_sq:
>  
>  static int init_vqs(struct virtnet_info *vi)
>  {
> -	int ret;
> +	struct virtio_device *vdev = vi->vdev;
> +	int i, ret;
>  
>  	/* Allocate send & receive queues */
>  	ret = virtnet_alloc_queues(vi);
> @@ -1533,12 +1586,28 @@ static int init_vqs(struct virtnet_info *vi)
>  	if (ret)
>  		goto err_free;
>  
> +	if (vi->mergeable_rx_bufs) {
> +		for (i = 0; i < vi->max_queue_pairs; i++) {
> +			struct receive_queue *rq = &vi->rq[i];
> +			rq->mrg_buf_ctx_size = virtqueue_get_vring_size(rq->vq);
> +			rq->mrg_buf_ctx = kmalloc(sizeof(*rq->mrg_buf_ctx) *
> +						  rq->mrg_buf_ctx_size,
> +						  GFP_KERNEL);
> +			if (!rq->mrg_buf_ctx) {
> +				ret = -ENOMEM;
> +				goto err_del_vqs;
> +			}
> +		}
> +	}
> +
>  	get_online_cpus();
>  	virtnet_set_affinity(vi);
>  	put_online_cpus();
>  
>  	return 0;
>  
> +err_del_vqs:
> +	vdev->config->del_vqs(vdev);
>  err_free:
>  	virtnet_free_queues(vi);
>  err:
