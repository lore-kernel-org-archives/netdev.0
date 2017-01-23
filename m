From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Tue, 24 Jan 2017 00:28:53 +0200
Message-ID: <20170124002828-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
 <20170123205957-mutt-send-email-mst@kernel.org>
 <20170123220231-mutt-send-email-mst@kernel.org>
 <58867FDF.4070708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751183AbdAWW2y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 17:28:54 -0500
Content-Disposition: inline
In-Reply-To: <58867FDF.4070708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 02:12:47PM -0800, John Fastabend wrote:
> On 17-01-23 12:09 PM, Michael S. Tsirkin wrote:
> > On Mon, Jan 23, 2017 at 09:22:36PM +0200, Michael S. Tsirkin wrote:
> >> On Tue, Jan 17, 2017 at 02:22:59PM -0800, John Fastabend wrote:
> >>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >>> index 62dbf4b..3b129b4 100644
> >>> --- a/drivers/net/virtio_net.c
> >>> +++ b/drivers/net/virtio_net.c
> >>> @@ -41,6 +41,9 @@
> >>>  #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
> >>>  #define GOOD_COPY_LEN	128
> >>>  
> >>> +/* Amount of XDP headroom to prepend to packets for use by xdp_adjust_head */
> >>> +#define VIRTIO_XDP_HEADROOM 256
> >>> +
> >>>  /* RX packet size EWMA. The average packet size is used to determine the packet
> >>>   * buffer size when refilling RX rings. As the entire RX ring may be refilled
> >>>   * at once, the weight is chosen so that the EWMA will be insensitive to short-
> >>
> >> I wonder where does this number come from?  This is quite a lot and
> >> means that using XDP_PASS will slow down any sockets on top of it.
> >> Which in turn means people will try to remove XDP when not in use,
> >> causing resets.  E.g. build_skb (which I have a patch to switch to) uses
> >> a much more reasonable NET_SKB_PAD.
> 
> I just used the value Alexei (or someone?) came up with. I think it needs to be
> large enough to avoid copy in header encap cases. So minimum
> 
>   VXLAN_HDR + OUTER_UDP + OUTER_IPV6_HDR + OUTER_MAC =
>      8      +     8     +        40      +      14   =  70
> 
> The choice of VXLAN hdr was sort of arbitrary but seems good for estimates. For
> what its worth there is also a ndo_set_rx_headroom could we use that to set it
> and choose a reasonable default.
> 
> >>
> >> -- 
> >> MST
> > 
> > 
> > Let me show you a patch that I've been cooking.  What is missing there
> > is handling corner cases like e.g.  when ring size is ~4 entries so
> > using smaller buffers might mean we no longer have enough space to store
> > a full packet.  So it looks like I have to maintain the skb copy path
> > for this hardware.
> > 
> > With this patch, standard configuration has NET_SKB_PAD + NET_IP_ALIGN
> > bytes head padding. Would this be enough for XDP? If yes we do not
> > need the resets.
> 
> Based on above seems a bit small (L1_CACHE_BYTES + 2)? How tricky would it
> be to add support for ndo_set_rx_headroom.

Donnu but then what? Expose it to userspace and let admin
make the decision for us?


> > 
> > Thoughts?
> 
> I'll take a look at the patch this afternoon. Thanks.
> 
> > 
> > --->
> > 
> > virtio_net: switch to build_skb for mrg_rxbuf
> > 
> > For small packets data copy was observed to
> > take up about 15% CPU time. Switch to build_skb
> > and avoid the copy when using mergeable rx buffers.
> > 
> > As a bonus, medium-size skbs that fit in a page will be
> > completely linear.
> > 
> > Of course, we now need to lower the lower bound on packet size,
> > to make sure a sane number of skbs fits in rx socket buffer.
> > By how much? I don't know yet.
> > 
> > It might also be useful to prefetch the packet buffer since
> > net stack will likely use it soon.
> > 
> > Lightly tested, in particular, I didn't yet test what this
> > actually does to performance - sending this out for early
> > feedback/flames.
> > 
> > TODO: it appears that Linux won't handle correctly the case of first
> > buffer being very small (or consisting exclusively of virtio header).
> > This is already the case for current code, need to fix.
> > TODO: might be unfair to the last packet in a fragment as we include
> > remaining space if any in its truesize.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> > ----
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index b425fa1..a6b996f 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -38,6 +38,8 @@ module_param(gso, bool, 0444);
> >  
> >  /* FIXME: MTU in config. */
> >  #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
> > +//#define MIN_PACKET_ALLOC GOOD_PACKET_LEN
> > +#define MIN_PACKET_ALLOC 128
> >  #define GOOD_COPY_LEN	128
> >  
> >  /* RX packet size EWMA. The average packet size is used to determine the packet
> > @@ -246,6 +248,9 @@ static void *mergeable_ctx_to_buf_address(unsigned long mrg_ctx)
> >  static unsigned long mergeable_buf_to_ctx(void *buf, unsigned int truesize)
> >  {
> >  	unsigned int size = truesize / MERGEABLE_BUFFER_ALIGN;
> > +
> > +	BUG_ON((unsigned long)buf & (MERGEABLE_BUFFER_ALIGN - 1));
> > +	BUG_ON(size - 1 >= MERGEABLE_BUFFER_ALIGN);
> >  	return (unsigned long)buf | (size - 1);
> >  }
> >  
> > @@ -354,25 +359,54 @@ static struct sk_buff *receive_big(struct net_device *dev,
> >  	return NULL;
> >  }
> >  
> > +#define VNET_SKB_PAD (NET_SKB_PAD + NET_IP_ALIGN)
> > +#define VNET_SKB_BUG (VNET_SKB_PAD < sizeof(struct virtio_net_hdr_mrg_rxbuf))
> > +#define VNET_SKB_LEN(len) ((len) - sizeof(struct virtio_net_hdr_mrg_rxbuf))
> > +#define VNET_SKB_OFF VNET_SKB_LEN(VNET_SKB_PAD)
> > +
> > +static struct sk_buff *vnet_build_skb(struct virtnet_info *vi,
> > +				      void *buf,
> > +				      unsigned int len, unsigned int truesize)
> > +{
> > +	struct sk_buff *skb = build_skb(buf, truesize);
> > +
> > +	if (!skb)
> > +		return NULL;
> > +
> > +	skb_reserve(skb, VNET_SKB_PAD);
> > +	skb_put(skb, VNET_SKB_LEN(len));
> > +
> > +	return skb;
> > +}
> > +
> >  static struct sk_buff *receive_mergeable(struct net_device *dev,
> >  					 struct virtnet_info *vi,
> >  					 struct receive_queue *rq,
> >  					 unsigned long ctx,
> > -					 unsigned int len)
> > +					 unsigned int len,
> > +					 struct virtio_net_hdr_mrg_rxbuf *hdr)
> >  {
> >  	void *buf = mergeable_ctx_to_buf_address(ctx);
> > -	struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
> > -	u16 num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
> > +	u16 num_buf;
> >  	struct page *page = virt_to_head_page(buf);
> > -	int offset = buf - page_address(page);
> > -	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
> > +	unsigned int truesize = mergeable_ctx_to_buf_truesize(ctx);
> > +	int offset;
> > +	struct sk_buff *head_skb;
> > +	struct sk_buff *curr_skb;
> > +
> > +	BUG_ON(len > truesize);
> >  
> > -	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
> > -					       truesize);
> > -	struct sk_buff *curr_skb = head_skb;
> > +	/* copy header: build_skb will overwrite it */
> > +	memcpy(hdr, buf + VNET_SKB_OFF, sizeof *hdr);
> > +
> > +	head_skb = vnet_build_skb(vi, buf, len, truesize);
> > +	curr_skb = head_skb;
> > +
> > +	num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
> >  
> >  	if (unlikely(!curr_skb))
> >  		goto err_skb;
> > +
> >  	while (--num_buf) {
> >  		int num_skb_frags;
> >  
> > @@ -386,7 +420,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
> >  			goto err_buf;
> >  		}
> >  
> > -		buf = mergeable_ctx_to_buf_address(ctx);
> > +		buf = mergeable_ctx_to_buf_address(ctx) + VNET_SKB_OFF;
> >  		page = virt_to_head_page(buf);
> >  
> >  		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
> > @@ -403,7 +437,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
> >  			head_skb->truesize += nskb->truesize;
> >  			num_skb_frags = 0;
> >  		}
> > -		truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
> > +		truesize = mergeable_ctx_to_buf_truesize(ctx);
> > +		BUG_ON(len > truesize);
> >  		if (curr_skb != head_skb) {
> >  			head_skb->data_len += len;
> >  			head_skb->len += len;
> > @@ -449,6 +484,7 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
> >  	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
> >  	struct sk_buff *skb;
> >  	struct virtio_net_hdr_mrg_rxbuf *hdr;
> > +	struct virtio_net_hdr_mrg_rxbuf hdr0;
> >  
> >  	if (unlikely(len < vi->hdr_len + ETH_HLEN)) {
> >  		pr_debug("%s: short packet %i\n", dev->name, len);
> > @@ -465,17 +501,24 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
> >  		return;
> >  	}
> >  
> > -	if (vi->mergeable_rx_bufs)
> > -		skb = receive_mergeable(dev, vi, rq, (unsigned long)buf, len);
> > -	else if (vi->big_packets)
> > +	if (vi->mergeable_rx_bufs) {
> > +		skb = receive_mergeable(dev, vi, rq, (unsigned long)buf, len,
> > +					&hdr0);
> > +		if (unlikely(!skb))
> > +			return;
> > +		hdr = &hdr0;
> > +	} else if (vi->big_packets) {
> >  		skb = receive_big(dev, vi, rq, buf, len);
> > -	else
> > +		if (unlikely(!skb))
> > +			return;
> > +		hdr = skb_vnet_hdr(skb);
> > +	} else {
> >  		skb = receive_small(vi, buf, len);
> > +		if (unlikely(!skb))
> > +			return;
> > +		hdr = skb_vnet_hdr(skb);
> > +	}
> >  
> > -	if (unlikely(!skb))
> > -		return;
> > -
> > -	hdr = skb_vnet_hdr(skb);
> >  
> >  	u64_stats_update_begin(&stats->rx_syncp);
> >  	stats->rx_bytes += skb->len;
> > @@ -581,11 +624,14 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
> >  
> >  static unsigned int get_mergeable_buf_len(struct ewma_pkt_len *avg_pkt_len)
> >  {
> > -	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
> > +	unsigned int hdr;
> >  	unsigned int len;
> >  
> > -	len = hdr_len + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
> > -			GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
> > +	hdr = ALIGN(VNET_SKB_PAD + SKB_DATA_ALIGN(sizeof(struct skb_shared_info)),
> > +		    MERGEABLE_BUFFER_ALIGN);
> > +
> > +	len = hdr + clamp_t(unsigned int, ewma_pkt_len_read(avg_pkt_len),
> > +			    MIN_PACKET_ALLOC, PAGE_SIZE - hdr);
> >  	return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
> >  }
> >  
> > @@ -601,8 +647,11 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> >  	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
> >  		return -ENOMEM;
> >  
> > -	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
> > -	ctx = mergeable_buf_to_ctx(buf, len);
> > +	BUILD_BUG_ON(VNET_SKB_BUG);
> > +
> > +	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset +
> > +		VNET_SKB_OFF;
> > +	//ctx = mergeable_buf_to_ctx(buf - VNET_SKB_OFF, len);
> >  	get_page(alloc_frag->page);
> >  	alloc_frag->offset += len;
> >  	hole = alloc_frag->size - alloc_frag->offset;
> > @@ -615,8 +664,10 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
> >  		len += hole;
> >  		alloc_frag->offset += hole;
> >  	}
> > +	ctx = mergeable_buf_to_ctx(buf - VNET_SKB_OFF, len);
> >  
> > -	sg_init_one(rq->sg, buf, len);
> > +	sg_init_one(rq->sg, buf,
> > +		    len - VNET_SKB_OFF - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
> >  	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, (void *)ctx, gfp);
> >  	if (err < 0)
> >  		put_page(virt_to_head_page(buf));
> > 
