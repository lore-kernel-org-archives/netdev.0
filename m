From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 68/75] hv: netvsc: convert to SKB paged frag API.
Date: Wed, 24 Aug 2011 14:30:10 -0400
Message-ID: <20110824183010.GG15675@dumpdata.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
 <1313760467-8598-68-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hank Janssen <hjanssen@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Abhishek Kane <v-abkane@microsoft.com>,
	devel@driverdev.osuosl.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1313760467-8598-68-git-send-email-ian.campbell@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What is with the 'XXX' ?

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
