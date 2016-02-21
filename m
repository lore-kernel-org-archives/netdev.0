From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: switch to build_skb for mrg_rxbuf
Date: Sun, 21 Feb 2016 20:41:57 +0200
Message-ID: <20160221204110-mutt-send-email-mst@redhat.com>
References: <1456079998-5240-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1456079998-5240-1-git-send-email-mst@redhat.com>
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

On Sun, Feb 21, 2016 at 08:40:59PM +0200, Michael S. Tsirkin wrote:
> For small packets data copy was observed to
> take up about 15% CPU time. Switch to build_skb
> and avoid the copy when using mergeable rx buffers.
> 
> As a bonus, medium-size skbs that fit in a page will be
> completely linear.
> 
> Of course, we now need to lower the lower bound on packet size,
> to make sure a sane number of skbs fits in rx socket buffer.
> By how much? I don't know yet.
> 
> It might also be useful to prefetch the packet buffer since
> net stack will likely use it soon.
> 
> Lightly tested, in particular, I didn't yet test what this
> actually does to performance - sending this out for early
> feedback/flames.
> 
> TODO: it appears that Linux won't handle correctly the case of first
> buffer being very small (or consisting exclusively of virtio header).
> This is already the case for current code, so don't bother
> testing yet.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Oops. This should have been "RFC PATCH".
Please don't merge it yet, it's just a preview.

> ---
>  drivers/net/virtio_net.c | 44 +++++++++++++++++++++++++++++++++++---------
>  1 file changed, 35 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 767ab11..20f8dda 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -347,6 +347,26 @@ err:
>  	return NULL;
>  }
>  
> +#define VNET_SKB_PAD (NET_SKB_PAD + NET_IP_ALIGN)
> +#define VNET_SKB_BUG (VNET_SKB_PAD < sizeof(struct virtio_net_hdr_mrg_rxbuf))
> +#define VNET_SKB_LEN(len) ((len) - sizeof(struct virtio_net_hdr_mrg_rxbuf))
> +#define VNET_SKB_OFF VNET_SKB_LEN(VNET_SKB_PAD)
> +
> +static struct sk_buff *vnet_build_skb(struct virtnet_info *vi,
> +				      void *buf,
> +				      unsigned int len, unsigned int truesize)
> +{
> +	struct sk_buff *skb = build_skb(buf, truesize);
> +
> +	if (!skb)
> +		return NULL;
> +
> +	skb_reserve(skb, VNET_SKB_PAD);
> +	skb_put(skb, VNET_SKB_LEN(len));
> +
> +	return skb;
> +}
> +
>  static struct sk_buff *receive_mergeable(struct net_device *dev,
>  					 struct virtnet_info *vi,
>  					 struct receive_queue *rq,
> @@ -354,14 +374,13 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
>  					 unsigned int len)
>  {
>  	void *buf = mergeable_ctx_to_buf_address(ctx);
> -	struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
> +	struct virtio_net_hdr_mrg_rxbuf *hdr = buf + VNET_SKB_OFF;
>  	u16 num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
>  	struct page *page = virt_to_head_page(buf);
> -	int offset = buf - page_address(page);
>  	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
> +	int offset;
>  
> -	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
> -					       truesize);
> +	struct sk_buff *head_skb = vnet_build_skb(vi, buf, len, truesize);
>  	struct sk_buff *curr_skb = head_skb;
>  
>  	if (unlikely(!curr_skb))
> @@ -606,11 +625,14 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
>  
>  static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
>  {
> -	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> +	unsigned int hdr;
>  	unsigned int len;
>  
> -	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
> -			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> +	hdr = ALIGN(VNET_SKB_PAD + sizeof(struct skb_shared_info),
> +		    MERGEABLE_BUFFER_ALIGN);
> +
> +	len = hdr + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
> +			       500 /* TODO */, PAGE_SIZE - hdr);
>  	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
>  }
>  
> @@ -626,7 +648,10 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>  	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
>  		return -ENOMEM;
>  
> -	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> +	BUILD_BUG_ON(VNET_SKB_BUG);
> +
> +	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset +
> +		VNET_SKB_OFF;
>  	ctx = mergeable_buf_to_ctx(buf, len);
>  	get_page(alloc_frag->page);
>  	alloc_frag->offset += len;
> @@ -641,7 +666,8 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
>  		alloc_frag->offset += hole;
>  	}
>  
> -	sg_init_one(rq->sg, buf, len);
> +	sg_init_one(rq->sg, buf,
> +		    len - VNET_SKB_OFF - sizeof(struct skb_shared_info));
>  	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, (void *)ctx, gfp);
>  	if (err < 0)
>  		put_page(virt_to_head_page(buf));
> -- 
> MST
