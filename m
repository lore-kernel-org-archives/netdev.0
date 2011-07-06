From: Zan Lynx <zlynx@acm.org>
Subject: Re: [PATCH V8 2/4 net-next] skbuff: skb supports zero-copy buffers
Date: Wed, 06 Jul 2011 17:01:13 -0600
Message-ID: <4E14E939.5040904@acm.org>
References: <1309990932.10209.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1309990932.10209.19.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/6/2011 4:22 PM, Shirley Ma wrote:
> This patch adds userspace buffers support in skb shared info. A new 
> struct skb_ubuf_info is needed to maintain the userspace buffers
> argument and index, a callback is used to notify userspace to release
> the buffers once lower device has done DMA (Last reference to that skb
> has gone).
> 
> If there is any userspace apps to reference these userspace buffers,
> then these userspaces buffers will be copied into kernel. This way we
> can prevent userspace apps from holding these userspace buffers too long.
> 
> Use destructor_arg to point to the userspace buffer info; a new tx flags
> SKBTX_DEV_ZEROCOPY is added for zero-copy buffer check.
> 
> Signed-off-by: Shirley Ma <xma@...ibm.com>

I was just reading this patch and noticed that you check if
uarg->callback is set before calling it in skb_release_data, but you do
not check before calling it in skb_copy_ubufs.

I was only skimming so I have probably missed something...

> ---
> 
>  include/linux/skbuff.h |   16 ++++++++++
>  net/core/skbuff.c      |   79 +++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 94 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 3e54337..08d4507 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -187,6 +187,20 @@ enum {
>  
>  	/* ensure the originating sk reference is available on driver level */
>  	SKBTX_DRV_NEEDS_SK_REF = 1 << 3,
> +
> +	/* device driver supports TX zero-copy buffers */
> +	SKBTX_DEV_ZEROCOPY = 1 << 4,
> +};
> +
> +/*
> + * The callback notifies userspace to release buffers when skb DMA is done in
> + * lower device, the skb last reference should be 0 when calling this.
> + * The desc is used to track userspace buffer index.
> + */
> +struct ubuf_info {
> +	void (*callback)(void *);
> +	void *arg;
> +	unsigned long desc;
>  };
>  
>  /* This data is invariant across clones and lives at
> @@ -211,6 +225,7 @@ struct skb_shared_info {
>  	/* Intermediate layers must ensure that destructor_arg
>  	 * remains valid until skb destructor */
>  	void *		destructor_arg;
> +
>  	/* must be last field, see pskb_expand_head() */
>  	skb_frag_t	frags[MAX_SKB_FRAGS];
>  };
> @@ -2265,5 +2280,6 @@ static inline void skb_checksum_none_assert(struct sk_buff *skb)
>  }
>  
>  bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
> +
>  #endif	/* __KERNEL__ */
>  #endif	/* _LINUX_SKBUFF_H */
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 46cbd28..42462f5 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -329,6 +329,18 @@ static void skb_release_data(struct sk_buff *skb)
>  				put_page(skb_shinfo(skb)->frags[i].page);
>  		}
>  
> +		/*
> +		 * If skb buf is from userspace, we need to notify the caller
> +		 * the lower device DMA has done;
> +		 */
> +		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +			struct ubuf_info *uarg;
> +
> +			uarg = skb_shinfo(skb)->destructor_arg;
> +			if (uarg->callback)
> +				uarg->callback(uarg);
> +		}
> +
>  		if (skb_has_frag_list(skb))
>  			skb_drop_fraglist(skb);
>  
> @@ -481,6 +493,9 @@ bool skb_recycle_check(struct sk_buff *skb, int skb_size)
>  	if (irqs_disabled())
>  		return false;
>  
> +	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)
> +		return false;
> +
>  	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
>  		return false;
>  
> @@ -596,6 +611,50 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
>  }
>  EXPORT_SYMBOL_GPL(skb_morph);
>  
> +/* skb frags copy userspace buffers to kernel */
> +static int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> +{
> +	int i;
> +	int num_frags = skb_shinfo(skb)->nr_frags;
> +	struct page *page, *head = NULL;
> +	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
> +
> +	for (i = 0; i < num_frags; i++) {
> +		u8 *vaddr;
> +		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> +
> +		page = alloc_page(GFP_ATOMIC);
> +		if (!page) {
> +			while (head) {
> +				put_page(head);
> +				head = (struct page *)head->private;
> +			}
> +			return -ENOMEM;
> +		}
> +		vaddr = kmap_skb_frag(&skb_shinfo(skb)->frags[i]);
> +		memcpy(page_address(page),
> +		       vaddr + f->page_offset, f->size);
> +		kunmap_skb_frag(vaddr);
> +		page->private = (unsigned long)head;
> +		head = page;
> +	}
> +
> +	/* skb frags release userspace buffers */
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> +		put_page(skb_shinfo(skb)->frags[i].page);
> +
> +	uarg->callback(uarg);
> +
> +	/* skb frags point to kernel buffers */
> +	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
> +		skb_shinfo(skb)->frags[i - 1].page_offset = 0;
> +		skb_shinfo(skb)->frags[i - 1].page = head;
> +		head = (struct page *)head->private;
> +	}
> +	return 0;
> +}
> +
> +
>  /**
>   *	skb_clone	-	duplicate an sk_buff
>   *	@skb: buffer to clone
> @@ -614,6 +673,11 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
>  {
>  	struct sk_buff *n;
>  
> +	if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +		if (skb_copy_ubufs(skb, gfp_mask))
> +			return NULL;
> +	}
> +
>  	n = skb + 1;
>  	if (skb->fclone == SKB_FCLONE_ORIG &&
>  	    n->fclone == SKB_FCLONE_UNAVAILABLE) {
> @@ -731,6 +795,12 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
>  	if (skb_shinfo(skb)->nr_frags) {
>  		int i;
>  
> +		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +			if (skb_copy_ubufs(skb, gfp_mask)) {
> +				kfree(n);
> +				goto out;
> +			}
> +		}
>  		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  			skb_shinfo(n)->frags[i] = skb_shinfo(skb)->frags[i];
>  			get_page(skb_shinfo(n)->frags[i].page);
> @@ -788,7 +858,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  		fastpath = true;
>  	else {
>  		int delta = skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1;
> -
>  		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
>  	}
>  
> @@ -819,6 +888,11 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  	if (fastpath) {
>  		kfree(skb->head);
>  	} else {
> +		/* copy this zero copy skb frags */
> +		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +			if (skb_copy_ubufs(skb, gfp_mask))
> +				goto nofrags;
> +		}
>  		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
>  			get_page(skb_shinfo(skb)->frags[i].page);
>  
> @@ -853,6 +927,8 @@ adjust_others:
>  	atomic_set(&skb_shinfo(skb)->dataref, 1);
>  	return 0;
>  
> +nofrags:
> +	kfree(data);
>  nodata:
>  	return -ENOMEM;
>  }
> @@ -1354,6 +1430,7 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len)
>  		}
>  		start = end;
>  	}
> +
>  	if (!len)
>  		return 0;
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

