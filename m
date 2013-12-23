From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] net: auto-tune mergeable rx buffer size for
	improved performance
Date: Mon, 23 Dec 2013 14:51:23 +0200
Message-ID: <20131223125123.GA18168@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-3-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1387239389-13216-3-git-send-email-mwdalton@google.com>
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

On Mon, Dec 16, 2013 at 04:16:29PM -0800, Michael Dalton wrote:
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
> Signed-off-by: Michael Dalton <mwdalton@google.com>

OK so a high level benchmark shows it's worth it,
but how well does the logic work?
I think we should make the buffer size accessible in sysfs
or debugfs, and look at it, otherwise we don't really know.

> ---
>  drivers/net/virtio_net.c | 63 +++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 46 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index d38d130..904af37 100644
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
> @@ -78,6 +83,9 @@ struct receive_queue {
>  	/* Chain pages by the private ptr. */
>  	struct page *pages;
>  
> +	/* Average packet length for mergeable receive buffers. */
> +	struct ewma mrg_avg_pkt_len;
> +
>  	/* Page frag for GFP_ATOMIC packet buffer allocation. */
>  	struct page_frag atomic_frag;
>  
> @@ -339,13 +347,11 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  	int num_buf = hdr->mhdr.num_buffers;
>  	struct page *page = virt_to_head_page(buf);
>  	int offset = buf - page_address(page);
> -	int truesize = max_t(int, len, MERGE_BUFFER_LEN);
> -	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, truesize);
> +	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, len);
>  	struct sk_buff *curr_skb = head_skb;
>  
>  	if (unlikely(!curr_skb))
>  		goto err_skb;
> -


Don't like this chunk :)

>  	while (--num_buf) {
>  		int num_skb_frags;
>  
> @@ -374,23 +380,40 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  			head_skb->truesize += nskb->truesize;
>  			num_skb_frags = 0;
>  		}
> -		truesize = max_t(int, len, MERGE_BUFFER_LEN);
>  		if (curr_skb != head_skb) {
>  			head_skb->data_len += len;
>  			head_skb->len += len;
> -			head_skb->truesize += truesize;
> +			head_skb->truesize += len;
>  		}
>  		offset = buf - page_address(page);
>  		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
>  			put_page(page);
>  			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
> -					     len, truesize);
> +					     len, len);
>  		} else {
>  			skb_add_rx_frag(curr_skb, num_skb_frags, page,
> -					offset, len, truesize);
> +					offset, len, len);
>  		}
>  	}
>  
> +	/* All frags before the last frag are fully used -- for those frags,
> +	 * truesize = len. Use the size of the most recent buffer allocation
> +	 * from the last frag's page to estimate the truesize of the last frag.

I don't get the real motivation for this.

We have skbs A,B,C sharing a page, with chunk D being unused.
This randomly charges chunk D to an skb that ended up last
in the page.
Correct?
Why does this make sense?

> +	 * EWMA with a weight of 64 makes the size adjustments quite small in
> +	 * the frags allocated on one page (even a order-3 one), and truesize
> +	 * doesn't need to be 100% accurate.

If the explanation for the above is that we don't care where D is
charged, let's not charge it to any skbs.

> +	 */
> +	if (skb_is_nonlinear(head_skb)) {
> +		u32 est_buffer_len = page_private(page);
> +		if (est_buffer_len > len) {
> +			u32 truesize_delta = est_buffer_len - len;
> +
> +			curr_skb->truesize += truesize_delta;
> +			if (curr_skb != head_skb)
> +				head_skb->truesize += truesize_delta;
> +		}
> +	}
> +	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);

Why head_skb only? Why not full buffer size that comes from host?
This is simply len.


>  	return head_skb;
>  
>  err_skb:
> @@ -578,24 +601,29 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
>  static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>  {
>  	struct virtnet_info *vi = rq->vq->vdev->priv;
> +	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
>  	struct page_frag *alloc_frag;
>  	char *buf;
> -	int err, len, hole;
> +	int err, hole;
> +	u32 buflen;
>  
> +	buflen = hdr_len + clamp_t(u32, ewma_read(&rq->mrg_avg_pkt_len),
> +				   GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> +	buflen = ALIGN(buflen, L1_CACHE_BYTES);
>  	alloc_frag = (gfp & __GFP_WAIT) ? &vi->sleep_frag : &rq->atomic_frag;
> -	if (unlikely(!skb_page_frag_refill(MERGE_BUFFER_LEN, alloc_frag, gfp)))
> +	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, gfp)))
>  		return -ENOMEM;
>  	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
>  	get_page(alloc_frag->page);
> -	len = MERGE_BUFFER_LEN;
> -	alloc_frag->offset += len;
> +	alloc_frag->offset += buflen;
> +	set_page_private(alloc_frag->page, buflen);
>  	hole = alloc_frag->size - alloc_frag->offset;
> -	if (hole < MERGE_BUFFER_LEN) {
> -		len += hole;
> +	if (hole < buflen) {
> +		buflen += hole;
>  		alloc_frag->offset += hole;
>  	}
>  
> -	sg_init_one(rq->sg, buf, len);
> +	sg_init_one(rq->sg, buf, buflen);
>  	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
>  	if (err < 0)
>  		put_page(virt_to_head_page(buf));
> @@ -1516,6 +1544,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
>  			       napi_weight);
>  
>  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
> +		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
>  		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
>  	}
>  
> -- 
> 1.8.5.1
