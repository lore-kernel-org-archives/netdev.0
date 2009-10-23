From: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
	high-order watermarks are hit
Date: Fri, 23 Oct 2009 12:25:13 +0100
Message-ID: <20091023112512.GW11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com> <20091023091334.GV11778@csn.ul.ie> <alpine.DEB.2.00.0910230229010.28109@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
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
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910230229010.28109-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2009 at 02:36:53AM -0700, David Rientjes wrote:
> On Fri, 23 Oct 2009, Mel Gorman wrote:
> 
> > > Hmm, is this really supposed to be added to __alloc_pages_high_priority()?  
> > > By the patch description I was expecting kswapd to be woken up 
> > > preemptively whenever the preferred zone is below ALLOC_WMARK_LOW and 
> > > we're known to have just allocated at a higher order, not just when 
> > > current was oom killed (when we should already be freeing a _lot_ of 
> > > memory soon) or is doing a higher order allocation during direct reclaim.
> > > 
> > 
> > It was a somewhat arbitrary choice to have it trigger in the event high
> > priority allocations were happening frequently.
> > 
> 
> I don't quite understand, users of PF_MEMALLOC shouldn't be doing these 
> higher order allocations and if ALLOC_NO_WATERMARKS is by way of the oom 
> killer, we should be freeing a substantial amount of memory imminently 
> when it exits that waking up kswapd would be irrelevant.
> 

I agree. I think it's highly unlikely this patch will make any
difference but I wanted to eliminate it as a possibility. Patch 3 and 4
were previously one patch that were tested together.

> > > If this is moved to the fastpath, why is this wake_all_kswapd() and not
> > > wakeup_kswapd(preferred_zone, order)?  Do we need to kick kswapd in all 
> > > zones even though they may be free just because preferred_zone is now 
> > > below the watermark?
> > > 
> > 
> > It probably makes no difference as zones are checked for their watermarks
> > before any real work happens. However, even if this patch makes a difference,
> > I don't want to see it merged.  At best, it is an extremely heavy-handed
> > hack which is why I asked for it to be tested in isolation. It shouldn't
> > be necessary at all because sort of pre-emptive waking of kswapd was never
> > necessary before.
> > 
> 
> Ahh, that makes a ton more sense: this particular patch is a debugging 
> effort while the first two are candidates for 2.6.32 and -stable.  Gotcha.
> 

Yep.

> > > Wouldn't it be better to do this on page_zone(page) instead of 
> > > preferred_zone anyway?
> > > 
> > 
> > No. The preferred_zone is the zone we should be allocating from. If we
> > failed to allocate from it, it implies the watermarks are not being met
> > so we want to wake it.
> > 
> 
> Oops, I'm even more confused now :)  I thought the existing 
> wake_all_kswapd() in the slowpath was doing that and that this patch was 
> waking them prematurely because it speculates that a subsequent high 
> order allocation will fail unless memory is reclaimed. 


It should be doing that. This patch should be junk but because it was tested
previously, I needed to be sure it was actually junk.

> I thought we'd  
> want to reclaim from the zone we just did a high order allocation from so 
> that the fastpath could find the memory next time with ALLOC_WMARK_LOW.

The fastpath should be getting the pages it needs from the
preferred_zone. If it's not, we still want to get pages back in that
zone and the zone we actually ended up getting pages from.

It's probably best to ignore this patch except in the unlikely event Tobias
says it makes a difference to his testing. I'm hoping he's covered by patches
1+2 and maybe 3 and that patches 4 and 5 of this set get consigned to
the bit bucket.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
