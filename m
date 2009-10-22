From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
 high-order watermarks are hit
Date: Thu, 22 Oct 2009 12:41:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Mohamed Abbas <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org\"" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1256221356-26049-5-git-send-email-mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Oct 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7f2aa3e..851df40 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1596,6 +1596,17 @@ try_next_zone:
>  	return page;
>  }
>  
> +static inline
> +void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> +						enum zone_type high_zoneidx)
> +{
> +	struct zoneref *z;
> +	struct zone *zone;
> +
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> +		wakeup_kswapd(zone, order);
> +}
> +
>  static inline int
>  should_alloc_retry(gfp_t gfp_mask, unsigned int order,
>  				unsigned long pages_reclaimed)
> @@ -1730,18 +1741,18 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
>  			congestion_wait(BLK_RW_ASYNC, HZ/50);
>  	} while (!page && (gfp_mask & __GFP_NOFAIL));
>  
> -	return page;
> -}
> -
> -static inline
> -void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> -						enum zone_type high_zoneidx)
> -{
> -	struct zoneref *z;
> -	struct zone *zone;
> +	/*
> +	 * If after a high-order allocation we are now below watermarks,
> +	 * pre-emptively kick kswapd rather than having the next allocation
> +	 * fail and have to wake up kswapd, potentially failing GFP_ATOMIC
> +	 * allocations or entering direct reclaim
> +	 */
> +	if (unlikely(order) && page && !zone_watermark_ok(preferred_zone, order,
> +				preferred_zone->watermark[ALLOC_WMARK_LOW],
> +				zone_idx(preferred_zone), ALLOC_WMARK_LOW))
> +		wake_all_kswapd(order, zonelist, high_zoneidx);
>  
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		wakeup_kswapd(zone, order);
> +	return page;
>  }
>  
>  static inline int

Hmm, is this really supposed to be added to __alloc_pages_high_priority()?  
By the patch description I was expecting kswapd to be woken up 
preemptively whenever the preferred zone is below ALLOC_WMARK_LOW and 
we're known to have just allocated at a higher order, not just when 
current was oom killed (when we should already be freeing a _lot_ of 
memory soon) or is doing a higher order allocation during direct reclaim.

For the best coverage, it would have to be add the branch to the fastpath.  
That seems fine for a debugging aid and to see if progress is being made 
on the GFP_ATOMIC allocation issues, but doesn't seem like it should make 
its way to mainline, the subsequent GFP_ATOMIC allocation could already be 
happening and in the page allocator's slowpath at this point that this 
wakeup becomes unnecessary.

If this is moved to the fastpath, why is this wake_all_kswapd() and not
wakeup_kswapd(preferred_zone, order)?  Do we need to kick kswapd in all 
zones even though they may be free just because preferred_zone is now 
below the watermark?

Wouldn't it be better to do this on page_zone(page) instead of 
preferred_zone anyway?
