From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers and big packets in virtio_net
Date: Mon, 23 Nov 2009 11:38:30 +1030
Message-ID: <200911231138.30755.rusty@rustcorp.com.au>
References: <1258697745.7416.20.camel@localhost.localdomain> <4B063509.10006@gmail.com> <1258734101.11049.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1258734101.11049.1.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 21 Nov 2009 02:51:41 am Shirley Ma wrote:
> Signed-off-by: Shirley Ma (xma@us.ibm.com)

Hi Shirley,

   This patch seems like a good idea, but it needs some work.  As this is
the first time I've received a patch from you, I will go through it in extra
detail.  (As virtio maintainer, it's my responsibility to include this patch,
or not).

> -static void give_a_page(struct virtnet_info *vi, struct page *page)
> +static void give_pages(struct virtnet_info *vi, struct page *page)
>  {
> -	page->private = (unsigned long)vi->pages;
> +	struct page *npage = (struct page *)page->private;
> +
> +	if (!npage)
> +		page->private = (unsigned long)vi->pages;
> +	else {
> +		/* give a page list */
> +		while (npage) {
> +			if (npage->private == (unsigned long)0) {
> +				npage->private = (unsigned long)vi->pages;
> +				break;
> +			}
> +			npage = (struct page *)npage->private;
> +		}
> +	}
>  	vi->pages = page;

The loops should cover both cases of the if branch.  Either way, we want
to find the last page in the list so you can set that ->private pointer to 
vi->pages.

Also, the "== (unsigned long)0" is a little verbose.

How about:
	struct page *end;

	/* Find end of list, sew whole thing into vi->pages. */
	for (end = page; end->private; end = (struct page *)end->private);
	end->private = (unsigned long)vi->pages;
	vi->pages = page;

> +void virtio_free_pages(void *buf)

This is a terrible name; it's specific to virtio_net, plus it should be
static.  Just "free_pages" should be sufficient here I think.

> +{
> +	struct page *page = (struct page *)buf;
> +	struct page *npage;
> +
> +	while (page) {
> +		npage = (struct page *)page->private;
> +		__free_pages(page, 0);
> +		page = npage;
> +	}

This smells a lot like a for loop to me?

	struct page *i, *next;

	for (i = buf; next; i = next) {
		next = (struct page *)i->private;
		__free_pages(i, 0);
	}

> +static int set_skb_frags(struct sk_buff *skb, struct page *page,
> +				int offset, int len)

A better name might be "skb_add_frag()"?

> +static void receive_skb(struct net_device *dev, void *buf,
>  			unsigned len)
>  {
>  	struct virtnet_info *vi = netdev_priv(dev);
> -	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
> -	int err;
> +	struct skb_vnet_hdr *hdr;
> +	struct sk_buff *skb;
>  	int i;
>  
>  	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
> @@ -132,39 +173,71 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
>  		goto drop;
>  	}
>  
> -	if (vi->mergeable_rx_bufs) {
> -		unsigned int copy;
> -		char *p = page_address(skb_shinfo(skb)->frags[0].page);
> +	if (!vi->mergeable_rx_bufs && !vi->big_packets) {
> +		skb = (struct sk_buff *)buf;

This cast is unnecessary, but a comment would be nice:
	/* Simple case: the pointer is the 1514-byte skb */

> +	} else {

And a matching comment here:

	/* The pointer is a chain of pages. */

> +		struct page *page = (struct page *)buf;
> +		int copy, hdr_len, num_buf, offset;
> +		char *p;
> +
> +		p = page_address(page);
>  
> -		if (len > PAGE_SIZE)
> -			len = PAGE_SIZE;
> -		len -= sizeof(struct virtio_net_hdr_mrg_rxbuf);
> +		skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
> +		if (unlikely(!skb)) {
> +			dev->stats.rx_dropped++;

Does this mean we leak all those pages?  Shouldn't we give_pages() here?

> +			return;
> +		}
> +		skb_reserve(skb, NET_IP_ALIGN);
> +		hdr = skb_vnet_hdr(skb);
>  
> -		memcpy(&hdr->mhdr, p, sizeof(hdr->mhdr));
> -		p += sizeof(hdr->mhdr);
> +		if (vi->mergeable_rx_bufs) {
> +			hdr_len = sizeof(hdr->mhdr);
> +			memcpy(&hdr->mhdr, p, hdr_len);
> +			num_buf = hdr->mhdr.num_buffers;
> +			offset = hdr_len;
> +			if (len > PAGE_SIZE)
> +				len = PAGE_SIZE;
> +		} else {
> +			/* big packtes 6 bytes alignment between virtio_net
> +			 * header and data */
> +			hdr_len = sizeof(hdr->hdr);
> +			memcpy(&hdr->hdr, p, hdr_len);
> +			offset = hdr_len + 6;

Really?  I can't see where the current driver does this 6 byte offset.  There
should be a header, then the packet...

Ah, I see below that you set things up this way.  The better way to do this
is to create a new structure to use in various places.

	struct padded_vnet_hdr {
		struct virtio_net_hdr hdr;
		/* This padding makes our packet 16 byte aligned */
		char padding[6];
	};

However, I question whether making it 16 byte is the right thing: the
ethernet header is 14 bytes long, so don't we want 8 bytes of padding?

> +		}

I think you can move the memcpy outside the if, like so:

	memcpy(&hdr, p, hdr_len);

> +		if (!len)
> +			give_pages(vi, page);
> +		else {
> +			len = set_skb_frags(skb, page, copy + offset, len);
> +			/* process big packets */
> +			while (len > 0) {
> +				page = (struct page *)page->private;
> +				if (!page)
> +					break;
> +				len = set_skb_frags(skb, page, 0, len);
> +			}
> +			if (page && page->private)
> +				give_pages(vi, (struct page *)page->private);
>  		}

I can't help but think this statement should be one loop somehow.  Something
like:

	offset += copy;

	while (len) {
		len = skb_add_frag(skb, page, offset, len);
		page = (struct page *)page->private;
		offset = 0;
	}
	if (page)
		give_pages(vi, page);

> -static bool try_fill_recv_maxbufs(struct virtnet_info *vi, gfp_t gfp)
> +/* Returns false if we couldn't fill entirely (OOM). */
> +static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)

The result of trying to merge all the cases here is messy.  I'd split it
inside the loop into: add_recvbuf_small(vi, gfp), add_recvbuf_big(vi, gfp)
and add_recvbuf_mergeable(vi, gfp).

It'll also be easier for me to review each case then, as well as getting
rid of the big packets if we decide to do that later.  You could even do
that split as a separate patch, before this one.

> @@ -970,11 +1020,17 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
>  	}
>  	__skb_queue_purge(&vi->send);
>  
> -	BUG_ON(vi->num != 0);
> -
>  	unregister_netdev(vi->dev);
>  	cancel_delayed_work_sync(&vi->refill);
>  
> +	if (vi->mergeable_rx_bufs || vi->big_packets) {
> +		freed = vi->rvq->vq_ops->destroy_buf(vi->rvq,
> +						     virtio_free_pages);
> +		vi->num -= freed;
> +	}
> +
> +	BUG_ON(vi->num != 0);
> +

destroy_buf should really be called destroy_bufs().  And I don't think you
use the vi->recv skb list in this case at all, so the loop which purges those
should be under an "else {" of this branch.

> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
> index fbd2ecd..aec7fe7 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -334,6 +334,29 @@ static bool vring_enable_cb(struct virtqueue *_vq)
>  	return true;
>  }
>  
> +static int vring_destroy_buf(struct virtqueue *_vq, void (*callback)(void *))

This new parameter should be introduced as a separate patch.  It should also be
called destroy_bufs.  It also returns an unsigned int.  I would call the callback
something a little more informative, such as "destroy"; here and in the header.

> +	struct vring_virtqueue *vq = to_vvq(_vq);
> +	void *ret;
> +	unsigned int i;
> +	int freed = 0;
> +
> +	START_USE(vq);
> +
> +	for (i = 0; i < vq->vring.num; i++) {
> +		if (vq->data[i]) {
> +			/* detach_buf clears data, so grab it now. */
> +			ret = vq->data[i];
> +			detach_buf(vq, i);
> +			callback(ret);

ret is a bad name for this; how about buf?

Overall, the patch looks good.  But it would have been nicer if it were
split into several parts: cleanups, new infrastructure, then the actual
allocation change.

Thanks!
Rusty.
