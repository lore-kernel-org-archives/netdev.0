From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 2/4] Defer skb allocation -- new skb_set calls &
	chain pages in virtio_net
Date: Sun, 13 Dec 2009 13:24:52 +0200
Message-ID: <20091213112452.GB7074@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au> <20091208122134.GA17286@redhat.com> <1260534506.30371.6.camel@localhost.localdomain> <1260535382.30371.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260535382.30371.20.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 11, 2009 at 04:43:02AM -0800, Shirley Ma wrote:
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> --------------
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index bb5eb7b..100b4b9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -80,29 +80,25 @@ static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
>  	return (struct skb_vnet_hdr *)skb->cb;
>  }
>  
> -static void give_a_page(struct virtnet_info *vi, struct page *page)
> +static void give_pages(struct virtnet_info *vi, struct page *page)
>  {
> -	page->private = (unsigned long)vi->pages;
> -	vi->pages = page;
> -}
> +	struct page *end;
>  
> -static void trim_pages(struct virtnet_info *vi, struct sk_buff *skb)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> -		give_a_page(vi, skb_shinfo(skb)->frags[i].page);
> -	skb_shinfo(skb)->nr_frags = 0;
> -	skb->data_len = 0;
> +	/* Find end of list, sew whole thing into vi->pages. */
> +	for (end = page; end->private; end = (struct page *)end->private);

Hmm, this scans the whole list each time.
OTOH, the caller probably can easily get list tail as well as head.
If we ask caller to give us list tail, and chain them at head, then
1. we won't have to scan the list each time
2. we get better memory locality reusing same pages over and over again


> +	end->private = (unsigned long)vi->pages;
> +	vi->pages = page;
>  }
>  
>  static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
>  {
>  	struct page *p = vi->pages;
>  
> -	if (p)
> +	if (p) {
>  		vi->pages = (struct page *)p->private;
> -	else
> +		/* use private to chain pages for big packets */
> +		p->private = 0;

So this comment does not explain why this = 0 is here.
clearly = 0 does not chain anything.
Please add a bigger comment.

I think you also want to extend the comment at top of
file, where datastructure is, that explains the deferred
alogorigthm and how pages are chained.

> +	} else
>  		p = alloc_page(gfp_mask);
>  	return p;
>  }
> @@ -128,6 +124,85 @@ static void skb_xmit_done(struct virtqueue *svq)
>  	netif_wake_queue(vi->dev);
>  }
>  
> +static int skb_set_frag(struct sk_buff *skb, struct page *page,
> +				int offset, int len)

Maybe it's better not to prefix functions with skb_, one
tries to look them up in skbuff.h immediately.

> +{
> +	int i = skb_shinfo(skb)->nr_frags;
> +	skb_frag_t *f;
> +
> +	i = skb_shinfo(skb)->nr_frags;
> +	f = &skb_shinfo(skb)->frags[i];

i seems unused below, so opencode it.

> +	f->page = page;
> +	f->page_offset = offset;
> +
> +	if (len > PAGE_SIZE - f->page_offset)
> +		f->size = PAGE_SIZE - f->page_offset;

Will be a bit clearer with s/f->page_offset/offset/.

> +	else
> +		f->size = len;

Use min for clarity instead of opencoded if.
This will make it obvious that len won't ever become
negative below.

> +
> +	skb_shinfo(skb)->nr_frags++;
> +	skb->data_len += f->size;
> +	skb->len += f->size;


> +
> +	len -= f->size;
> +	return len;
> +}
> +
> +static struct sk_buff *skb_goodcopy(struct virtnet_info *vi, struct page **page,

I know you got this name from GOOD_COPY_LEN, but it's not
very good for a function :) and skb_ prefix is also confusing.
Just copy_small_skb or something like that?

> +				    unsigned int *len)

Comments about splitting patches  apply here as well.
No way to understand what this should do and whether it
does it correctly just by looking at patch.

> +{
> +	struct sk_buff *skb;
> +	struct skb_vnet_hdr *hdr;
> +	int copy, hdr_len, offset;
> +	char *p;
> +
> +	p = page_address(*page);
> +
> +	skb = netdev_alloc_skb(vi->dev, GOOD_COPY_LEN + NET_IP_ALIGN);
> +	if (unlikely(!skb))
> +		return NULL;
> +
> +	skb_reserve(skb, NET_IP_ALIGN);
> +	hdr = skb_vnet_hdr(skb);
> +
> +	if (vi->mergeable_rx_bufs) {
> +		hdr_len = sizeof(hdr->mhdr);

sizeof(hdr->mhdr) -> sizeof hdr->mhdr

> +		offset = hdr_len;
> +	} else {
> +		/* share one page between virtio_net header and data */
> +		struct padded_vnet_hdr {
> +			struct virtio_net_hdr hdr;
> +			/* This padding makes our data 16 byte aligned */

I think reader will still wonder about is "why does it
need to be 16 byte aligned?". And this is what
comment should explain I think.

> +			char padding[6];
> +		};
> +		hdr_len = sizeof(hdr->hdr);
> +		offset = sizeof(struct padded_vnet_hdr);
> +	}
> +
> +	memcpy(hdr, p, hdr_len);
> +
> +	*len -= hdr_len;
> +	p += offset;
> +
> +	copy = *len;
> +	if (copy > skb_tailroom(skb))
> +		copy = skb_tailroom(skb);
> +	memcpy(skb_put(skb, copy), p, copy);
> +
> +	*len -= copy;
> +	offset += copy;
> +
> +	if (*len) {
> +		*len = skb_set_frag(skb, *page, offset, *len);

So you are overriding *len here? why bother calculating it
then?

Also - this does *not* always copy all of data, and *page
tells us whether it did a copy or not? This is pretty confusing,
as APIs go. Also, if we have scatter/gather anyway,
why do we bother copying the head?
Also, before skb_set_frag skb is linear, right?
So in fact you do not need generic skb_set_frag,
you can just put stuff in the first fragment.
For example, pass the fragment number to skb_set_frag,
compiler will be able to better optimize.

> +		*page = (struct page *)(*page)->private;
> +	} else {
> +		give_pages(vi, *page);
> +		*page = NULL;
> +	}
> +
> +	return skb;
> +}
> +
>  static void receive_skb(struct net_device *dev, struct sk_buff *skb,
>  			unsigned len)
>  {
> @@ -162,7 +237,7 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
>  		len -= copy;
>  
>  		if (!len) {
> -			give_a_page(vi, skb_shinfo(skb)->frags[0].page);
> +			give_pages(vi, skb_shinfo(skb)->frags[0].page);
>  			skb_shinfo(skb)->nr_frags--;
>  		} else {
>  			skb_shinfo(skb)->frags[0].page_offset +=
> 
