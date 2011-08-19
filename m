From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 68/75] hv: netvsc: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:50:55 +0100
Message-ID: <1313761855.5010.368.camel@zakaz.uk.xensource.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	 <1313760467-8598-68-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Hank Janssen <hjanssen@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Abhishek Kane <v-abkane@microsoft.com>,
	<devel@driverdev.osuosl.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:14517 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781Ab1HSNu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 09:50:58 -0400
In-Reply-To: <1313760467-8598-68-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-19 at 14:27 +0100, Ian Campbell wrote:
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Hank Janssen <hjanssen@microsoft.com>
> Cc: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
> Cc: Abhishek Kane <v-abkane@microsoft.com>
> Cc: devel@driverdev.osuosl.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/cxgb4/sge.c         |   14 +++++-----
>  drivers/net/cxgb4vf/sge.c       |   18 ++++++------
>  drivers/net/mlx4/en_rx.c        |    2 +-
>  drivers/scsi/cxgbi/libcxgbi.c   |    2 +-
>  drivers/staging/hv/netvsc_drv.c |    2 +-
>  include/linux/skbuff.h          |   54 ++++++++++++++++++++++++++++++++++++---
>  net/core/skbuff.c               |   26 +++++++++++++++++-
>  7 files changed, 93 insertions(+), 25 deletions(-)

Somewhere along the line I've managed to rebase/merge the "net: add
support for per-paged-fragment destructors" patch into the preceding
patch :-( Everything here apart from the drivers/staging/hv/netvsc_drv.c
change should be a changeset with the following comment. I'll fix for
the next post.

    net: add support for per-paged-fragment destructors
    
    Entities which care about the complete lifecycle of pages which they inject
    into the network stack via an skb paged fragment can choose to set this
    destructor in order to receive a callback when the stack is really finished
    with a page (including all clones, retransmits, pull-ups etc etc).
    
    This destructor will always be propagated alongside the struct page when
    copying skb_frag_t->page. This is the reason I chose to embed the destructor in
    a "struct { } page" within the skb_frag_t, rather than as a separate field,
    since it allows existing code which propagates ->frags[N].page to Just
    Work(tm).
    
    When the destructor is present the page reference counting is done slightly
    differently. No references are held by the network stack on the struct page (it
    is up to the caller to manage this as necessary) instead the network stack will
    track references via the count embedded in the destructor structure. When this
    reference count reaches zero then the destructor will be called and the caller
    can take the necesary steps to release the page (i.e. release the struct page
    reference itself).
    
    The intention is that callers can use this callback to delay completion to
    _their_ callers until the network stack has completely released the page, in
    order to prevent use-after-free or modification of data pages which are still
    in use by the stack.
    
    It is allowable (indeed expected) for a caller to share a single destructor
    instance between multiple pages injected into the stack e.g. a group of pages
    included in a single higher level operation might share a destructor which is
    used to complete that higher level operation.
    
    NB: a small number of drivers use skb_frag_t independently of struct sk_buff so
    this patch is slightly larger than necessary. I did consider leaving skb_frag_t
    alone and defining a new (but similar) structure to be used in the struct
    sk_buff itself. This would also have the advantage of more clearly separating
    the two uses, which is useful since there are now special reference counting
    accessors for skb_frag_t within a struct sk_buff but not (necessarily) for
    those used outside of an skb.
    
    Signed-off-by: Ian Campbell <ian.campbell@citrix.com>


> 
> diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
> index f1813b5..3e7c4b3 100644
> --- a/drivers/net/cxgb4/sge.c
> +++ b/drivers/net/cxgb4/sge.c
> @@ -1416,7 +1416,7 @@ static inline void copy_frags(struct sk_buff *skb,
>  	unsigned int n;
>  
>  	/* usually there's just one frag */
> -	skb_frag_set_page(skb, 0, gl->frags[0].page);
> +	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
>  	ssi->frags[0].page_offset = gl->frags[0].page_offset + offset;
>  	ssi->frags[0].size = gl->frags[0].size - offset;
>  	ssi->nr_frags = gl->nfrags;
> @@ -1425,7 +1425,7 @@ static inline void copy_frags(struct sk_buff *skb,
>  		memcpy(&ssi->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
>  
>  	/* get a reference to the last page, we don't own it */
> -	get_page(gl->frags[n].page);
> +	get_page(gl->frags[n].page.p);	/* XXX */
>  }
>  
>  /**
> @@ -1482,7 +1482,7 @@ static void t4_pktgl_free(const struct pkt_gl *gl)
>  	const skb_frag_t *p;
>  
>  	for (p = gl->frags, n = gl->nfrags - 1; n--; p++)
> -		put_page(p->page);
> +		put_page(p->page.p); /* XXX */
>  }
>  
>  /*
> @@ -1635,7 +1635,7 @@ static void restore_rx_bufs(const struct pkt_gl *si, struct sge_fl *q,
>  		else
>  			q->cidx--;
>  		d = &q->sdesc[q->cidx];
> -		d->page = si->frags[frags].page;
> +		d->page = si->frags[frags].page.p; /* XXX */
>  		d->dma_addr |= RX_UNMAPPED_BUF;
>  		q->avail++;
>  	}
> @@ -1717,7 +1717,7 @@ static int process_responses(struct sge_rspq *q, int budget)
>  			for (frags = 0, fp = si.frags; ; frags++, fp++) {
>  				rsd = &rxq->fl.sdesc[rxq->fl.cidx];
>  				bufsz = get_buf_size(rsd);
> -				fp->page = rsd->page;
> +				fp->page.p = rsd->page; /* XXX */
>  				fp->page_offset = q->offset;
>  				fp->size = min(bufsz, len);
>  				len -= fp->size;
> @@ -1734,8 +1734,8 @@ static int process_responses(struct sge_rspq *q, int budget)
>  						get_buf_addr(rsd),
>  						fp->size, DMA_FROM_DEVICE);
>  
> -			si.va = page_address(si.frags[0].page) +
> -				si.frags[0].page_offset;
> +			si.va = page_address(si.frags[0].page.p) +
> +				si.frags[0].page_offset; /* XXX */
>  
>  			prefetch(si.va);
>  
> diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
> index 6d6060e..3688423 100644
> --- a/drivers/net/cxgb4vf/sge.c
> +++ b/drivers/net/cxgb4vf/sge.c
> @@ -1397,7 +1397,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
>  		skb_copy_to_linear_data(skb, gl->va, pull_len);
>  
>  		ssi = skb_shinfo(skb);
> -		skb_frag_set_page(skb, 0, gl->frags[0].page);
> +		skb_frag_set_page(skb, 0, gl->frags[0].page.p); /* XXX */
>  		ssi->frags[0].page_offset = gl->frags[0].page_offset + pull_len;
>  		ssi->frags[0].size = gl->frags[0].size - pull_len;
>  		if (gl->nfrags > 1)
> @@ -1410,7 +1410,7 @@ struct sk_buff *t4vf_pktgl_to_skb(const struct pkt_gl *gl,
>  		skb->truesize += skb->data_len;
>  
>  		/* Get a reference for the last page, we don't own it */
> -		get_page(gl->frags[gl->nfrags - 1].page);
> +		get_page(gl->frags[gl->nfrags - 1].page.p); /* XXX */
>  	}
>  
>  out:
> @@ -1430,7 +1430,7 @@ void t4vf_pktgl_free(const struct pkt_gl *gl)
>  
>  	frag = gl->nfrags - 1;
>  	while (frag--)
> -		put_page(gl->frags[frag].page);
> +		put_page(gl->frags[frag].page.p); /* XXX */
>  }
>  
>  /**
> @@ -1450,7 +1450,7 @@ static inline void copy_frags(struct sk_buff *skb,
>  	unsigned int n;
>  
>  	/* usually there's just one frag */
> -	skb_frag_set_page(skb, 0, gl->frags[0].page);
> +	skb_frag_set_page(skb, 0, gl->frags[0].page.p);	/* XXX */
>  	si->frags[0].page_offset = gl->frags[0].page_offset + offset;
>  	si->frags[0].size = gl->frags[0].size - offset;
>  	si->nr_frags = gl->nfrags;
> @@ -1460,7 +1460,7 @@ static inline void copy_frags(struct sk_buff *skb,
>  		memcpy(&si->frags[1], &gl->frags[1], n * sizeof(skb_frag_t));
>  
>  	/* get a reference to the last page, we don't own it */
> -	get_page(gl->frags[n].page);
> +	get_page(gl->frags[n].page.p); /* XXX */
>  }
>  
>  /**
> @@ -1613,7 +1613,7 @@ static void restore_rx_bufs(const struct pkt_gl *gl, struct sge_fl *fl,
>  		else
>  			fl->cidx--;
>  		sdesc = &fl->sdesc[fl->cidx];
> -		sdesc->page = gl->frags[frags].page;
> +		sdesc->page = gl->frags[frags].page.p; /* XXX */
>  		sdesc->dma_addr |= RX_UNMAPPED_BUF;
>  		fl->avail++;
>  	}
> @@ -1701,7 +1701,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
>  				BUG_ON(rxq->fl.avail == 0);
>  				sdesc = &rxq->fl.sdesc[rxq->fl.cidx];
>  				bufsz = get_buf_size(sdesc);
> -				fp->page = sdesc->page;
> +				fp->page.p = sdesc->page; /* XXX */
>  				fp->page_offset = rspq->offset;
>  				fp->size = min(bufsz, len);
>  				len -= fp->size;
> @@ -1719,8 +1719,8 @@ int process_responses(struct sge_rspq *rspq, int budget)
>  			dma_sync_single_for_cpu(rspq->adapter->pdev_dev,
>  						get_buf_addr(sdesc),
>  						fp->size, DMA_FROM_DEVICE);
> -			gl.va = (page_address(gl.frags[0].page) +
> -				 gl.frags[0].page_offset);
> +			gl.va = (page_address(gl.frags[0].page.p) +
> +				 gl.frags[0].page_offset); /* XXX */
>  			prefetch(gl.va);
>  
>  			/*
> diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
> index 0c26ee7..bd4e86e 100644
> --- a/drivers/net/mlx4/en_rx.c
> +++ b/drivers/net/mlx4/en_rx.c
> @@ -418,7 +418,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
>  			break;
>  
>  		/* Save page reference in skb */
> -		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page);
> +		__skb_frag_set_page(&skb_frags_rx[nr], skb_frags[nr].page.p); /* XXX */
>  		skb_frags_rx[nr].size = skb_frags[nr].size;
>  		skb_frags_rx[nr].page_offset = skb_frags[nr].page_offset;
>  		dma = be64_to_cpu(rx_desc->data[nr].addr);
> diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
> index 0debb06..43cc6c6 100644
> --- a/drivers/scsi/cxgbi/libcxgbi.c
> +++ b/drivers/scsi/cxgbi/libcxgbi.c
> @@ -1823,7 +1823,7 @@ static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
>  				return -EINVAL;
>  			}
>  
> -			frags[i].page = page;
> +			frags[i].page.p = page;
>  			frags[i].page_offset = sg->offset + sgoffset;
>  			frags[i].size = copy;
>  			i++;
> diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvsc_drv.c
> index 61989f0..4fc7b3e 100644
> --- a/drivers/staging/hv/netvsc_drv.c
> +++ b/drivers/staging/hv/netvsc_drv.c
> @@ -171,7 +171,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
>  
> -		packet->page_buf[i+2].pfn = page_to_pfn(f->page);
> +		packet->page_buf[i+2].pfn = page_to_pfn(skb_frag_page(f));
>  		packet->page_buf[i+2].offset = f->page_offset;
>  		packet->page_buf[i+2].len = f->size;
>  	}
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index c015e61..c6a3d4b 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -134,8 +134,17 @@ struct sk_buff;
>  
>  typedef struct skb_frag_struct skb_frag_t;
>  
> +struct skb_frag_destructor {
> +	atomic_t ref;
> +	int (*destroy)(void *data);
> +	void *data;
> +};
> +
>  struct skb_frag_struct {
> -	struct page *page;
> +	struct {
> +		struct page *p;
> +		struct skb_frag_destructor *destructor;
> +	} page;
>  #if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
>  	__u32 page_offset;
>  	__u32 size;
> @@ -1128,6 +1137,31 @@ static inline int skb_pagelen(const struct sk_buff *skb)
>  }
>  
>  /**
> + * skb_frag_set_destructor - set destructor for a paged fragment
> + * @skb: buffer containing fragment to be initialised
> + * @i: paged fragment index to initialise
> + * @destroy: the destructor to use for this fragment
> + *
> + * Sets @destroy as the destructor to be called when all references to
> + * the frag @i in @skb (tracked over skb_clone, retransmit, pull-ups,
> + * etc) are released.
> + *
> + * When a destructor is set then reference counting is performed on
> + * @destroy->ref. When the ref reaches zero then @destroy->destroy
> + * will be called. The caller is responsible for holding and managing
> + * any other references (such a the struct page reference count).
> + *
> + * This function must be called before any use of skb_frag_ref() or
> + * skb_frag_unref().
> + */
> +static inline void skb_frag_set_destructor(struct sk_buff *skb, int i,
> +					   struct skb_frag_destructor *destroy)
> +{
> +	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +	frag->page.destructor = destroy;
> +}
> +
> +/**
>   * __skb_fill_page_desc - initialise a paged fragment in an skb
>   * @skb: buffer containing fragment to be initialised
>   * @i: paged fragment index to initialise
> @@ -1145,7 +1179,8 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
>  {
>  	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
>  
> -	frag->page		  = page;
> +	frag->page.p		  = page;
> +	frag->page.destructor     = NULL;
>  	frag->page_offset	  = off;
>  	frag->size		  = size;
>  }
> @@ -1669,9 +1704,12 @@ static inline void netdev_free_page(struct net_device *dev, struct page *page)
>   */
>  static inline struct page *skb_frag_page(const skb_frag_t *frag)
>  {
> -	return frag->page;
> +	return frag->page.p;
>  }
>  
> +extern void skb_frag_destructor_ref(struct skb_frag_destructor *destroy);
> +extern void skb_frag_destructor_unref(struct skb_frag_destructor *destroy);
> +
>  /**
>   * __skb_frag_ref - take an addition reference on a paged fragment.
>   * @frag: the paged fragment
> @@ -1680,6 +1718,10 @@ static inline struct page *skb_frag_page(const skb_frag_t *frag)
>   */
>  static inline void __skb_frag_ref(skb_frag_t *frag)
>  {
> +	if (unlikely(frag->page.destructor)) {
> +		skb_frag_destructor_ref(frag->page.destructor);
> +		return;
> +	}
>  	get_page(skb_frag_page(frag));
>  }
>  
> @@ -1703,6 +1745,10 @@ static inline void skb_frag_ref(struct sk_buff *skb, int f)
>   */
>  static inline void __skb_frag_unref(skb_frag_t *frag)
>  {
> +	if (unlikely(frag->page.destructor)) {
> +		skb_frag_destructor_unref(frag->page.destructor);
> +		return;
> +	}
>  	put_page(skb_frag_page(frag));
>  }
>  
> @@ -1755,7 +1801,7 @@ static inline void *skb_frag_address_safe(const skb_frag_t *frag)
>   */
>  static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *page)
>  {
> -	frag->page = page;
> +	frag->page.p = page;
>  	__skb_frag_ref(frag);
>  }
>  
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 418f3435..906a3e7 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -292,6 +292,23 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
>  }
>  EXPORT_SYMBOL(dev_alloc_skb);
>  
> +void skb_frag_destructor_ref(struct skb_frag_destructor *destroy)
> +{
> +	BUG_ON(destroy == NULL);
> +	atomic_inc(&destroy->ref);
> +}
> +EXPORT_SYMBOL(skb_frag_destructor_ref);
> +
> +void skb_frag_destructor_unref(struct skb_frag_destructor *destroy)
> +{
> +	if (destroy == NULL)
> +		return;
> +
> +	if (atomic_dec_and_test(&destroy->ref))
> +		destroy->destroy(destroy->data);
> +}
> +EXPORT_SYMBOL(skb_frag_destructor_unref);
> +
>  static void skb_drop_list(struct sk_buff **listp)
>  {
>  	struct sk_buff *list = *listp;
> @@ -642,14 +659,19 @@ static int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
>  
>  	/* skb frags release userspace buffers */
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> -		put_page(skb_shinfo(skb)->frags[i].page);
> +		skb_frag_unref(skb, i);
>  
>  	uarg->callback(uarg);
>  
>  	/* skb frags point to kernel buffers */
>  	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
>  		skb_shinfo(skb)->frags[i - 1].page_offset = 0;
> -		skb_shinfo(skb)->frags[i - 1].page = head;
> +		skb_shinfo(skb)->frags[i - 1].page.p = head;
> +		/*
> +		 * The original destructor is called as necessary when
> +		 * releasing userspace buffers.
> +		 */
> +		skb_shinfo(skb)->frags[i - 1].page.destructor = NULL;
>  		head = (struct page *)head->private;
>  	}
>  	return 0;


