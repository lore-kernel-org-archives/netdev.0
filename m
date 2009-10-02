From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/31] mm: tag reseve pages
Date: Fri, 2 Oct 2009 02:50:39 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.0910020243190.22702@chino.kir.corp.google.com>
References: <1254405917-15796-1-git-send-email-sjayaraman@suse.de> <alpine.DEB.1.00.0910011407390.32006@chino.kir.corp.google.com> <19141.34038.274185.392663@notabene.brown>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>,
        Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>,
        trond.myklebust@fys.uio.no
To: Neil Brown <neilb@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <19141.34038.274185.392663@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Oct 2009, Neil Brown wrote:

> Normally if zones are above their watermarks, page->reserve will not
> be set.
> This is because __alloc_page_nodemask (which seems to be the main
> non-inline entrypoint) first calls get_page_from_freelist with
> alloc_flags set to ALLOC_WMARK_LOW|ALLOC_CPUSET.
> Only if this fails does __alloc_page_nodemask call
> __alloc_pages_slowpath which potentially sets ALLOC_NO_WATERMARKS in
> alloc_flags.
> 
> So page->reserved being set actually tells us:
>   PF_MEMALLOC or GFP_MEMALLOC were used, and
>   a WMARK_LOW allocation attempt failed very recently
> 
> which is close enough to "the emergency reserves were used" I think.
> 

There're a couple cornercases for GFP_ATOMIC, though:

 - it isn't restricted by cpuset, so ALLOC_CPUSET will never get set for 
   the slowpath allocs and may very well allow the allocation to succeed 
   in zones far above their min watermark.

 - it allows for allocating beyond the min watermark in allowed zones
   simply by setting ALLOC_HARDER; these types of "reserve" allocations
   wouldn't be marked as page->reserve with your patches if
   ALLOC_NO_WATERMARKS wasn't set because of the allocation context.

The second one is debatable whether it fits your definition of reserve or 
not, but there's an inconsistency if it doesn't because the allocation may 
succeed in "no watermark" context (for example, in hard irq context) even 
though that privilege wasn't necessary to successfully allocate: perhaps 
it only needed ALLOC_HARDER.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
