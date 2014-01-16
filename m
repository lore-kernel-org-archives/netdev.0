From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v3 5/5] virtio-net: initial rx sysfs support,
	export mergeable rx buffer size
Date: Thu, 16 Jan 2014 13:53:40 +0200
Message-ID: <20140116115340.GC29061@redhat.com>
References: <1389865126-26225-1-git-send-email-mwdalton@google.com>
	<1389865126-26225-5-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1389865126-26225-5-git-send-email-mwdalton@google.com>
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

On Thu, Jan 16, 2014 at 01:38:46AM -0800, Michael Dalton wrote:
> Add initial support for per-rx queue sysfs attributes to virtio-net. If
> mergeable packet buffers are enabled, adds a read-only mergeable packet
> buffer size sysfs attribute for each RX queue.
> 
> Signed-off-by: Michael Dalton <mwdalton@google.com>
> ---
>  drivers/net/virtio_net.c | 66 +++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 62 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 3e82311..f315cbb 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -27,6 +27,7 @@
>  #include <linux/slab.h>
>  #include <linux/cpu.h>
>  #include <linux/average.h>
> +#include <linux/seqlock.h>
>  
>  static int napi_weight = NAPI_POLL_WEIGHT;
>  module_param(napi_weight, int, 0444);
> @@ -89,6 +90,12 @@ struct receive_queue {
>  	/* Average packet length for mergeable receive buffers. */
>  	struct ewma mrg_avg_pkt_len;
>  
> +	/* Sequence counter to allow sysfs readers to safely access stats.
> +	 * Assumes a single virtio-net writer, which is enforced by virtio-net
> +	 * and NAPI.
> +	 */
> +	seqcount_t sysfs_seq;
> +
>  	/* Page frag for packet buffer allocation. */
>  	struct page_frag alloc_frag;
>  
> @@ -416,7 +423,9 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  		}
>  	}
>  
> +	write_seqcount_begin(&rq->sysfs_seq);
>  	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
> +	write_seqcount_end(&rq->sysfs_seq);
>  	return head_skb;
>  
>  err_skb:

Hmm this adds overhead just to prevent sysfs from getting wrong value.
Can't sysfs simply disable softirq while it's reading the value?

> @@ -604,18 +613,29 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
>  	return err;
>  }
>  
> -static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> +static unsigned int get_mergeable_buf_len(struct ewma *avg_pkt_len)
>  {
>  	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> +	unsigned int len;
> +
> +	len = hdr_len + clamp_t(unsigned int, ewma_read(avg_pkt_len),
> +			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> +	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
> +}
> +
> +static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> +{
>  	struct page_frag *alloc_frag = &rq->alloc_frag;
>  	char *buf;
>  	unsigned long ctx;
>  	int err;
>  	unsigned int len, hole;
>  
> -	len = hdr_len + clamp_t(unsigned int, ewma_read(&rq->mrg_avg_pkt_len),
> -				GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> -	len = ALIGN(len, MERGEABLE_BUFFER_ALIGN);
> +	/* avg_pkt_len is written only in NAPI rx softirq context. We may
> +	 * read avg_pkt_len without using the sysfs_seq seqcount, as this code
> +	 * is called only in NAPI rx softirq context or when NAPI is disabled.
> +	 */
> +	len = get_mergeable_buf_len(&rq->mrg_avg_pkt_len);
>  	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
>  		return -ENOMEM;
>  
> @@ -1557,6 +1577,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
>  			       napi_weight);
>  
>  		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
> +		seqcount_init(&vi->rq[i].sysfs_seq);
>  		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
>  		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
>  	}
> @@ -1594,6 +1615,39 @@ err:
>  	return ret;
>  }
>  
> +#ifdef CONFIG_SYSFS
> +static ssize_t mergeable_rx_buffer_size_show(struct netdev_rx_queue *queue,
> +		struct rx_queue_attribute *attribute, char *buf)
> +{
> +	struct virtnet_info *vi = netdev_priv(queue->dev);
> +	unsigned int queue_index = get_netdev_rx_queue_index(queue);
> +	struct receive_queue *rq;
> +	struct ewma avg;
> +	unsigned int start;
> +
> +	BUG_ON(queue_index >= vi->max_queue_pairs);
> +	rq = &vi->rq[queue_index];
> +	do {
> +		start = read_seqcount_begin(&rq->sysfs_seq);
> +		avg = rq->mrg_avg_pkt_len;
> +	} while (read_seqcount_retry(&rq->sysfs_seq, start));
> +	return sprintf(buf, "%u\n", get_mergeable_buf_len(&avg));
> +}
> +
> +static struct rx_queue_attribute mergeable_rx_buffer_size_attribute =
> +	__ATTR_RO(mergeable_rx_buffer_size);
> +
> +static struct attribute *virtio_net_mrg_rx_attrs[] = {
> +	&mergeable_rx_buffer_size_attribute.attr,
> +	NULL
> +};
> +
> +static const struct attribute_group virtio_net_mrg_rx_group = {
> +	.name = "virtio_net",
> +	.attrs = virtio_net_mrg_rx_attrs
> +};
> +#endif
> +
>  static int virtnet_probe(struct virtio_device *vdev)
>  {
>  	int i, err;
> @@ -1708,6 +1762,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (err)
>  		goto free_stats;
>  
> +#ifdef CONFIG_SYSFS
> +	if (vi->mergeable_rx_bufs)
> +		dev->sysfs_rx_queue_group = &virtio_net_mrg_rx_group;
> +#endif
>  	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
>  	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
>  
> -- 
> 1.8.5.2
