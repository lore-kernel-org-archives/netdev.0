From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 10:22:07 +0200
Message-ID: <20070724082207.GN3287@kernel.dk>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org> <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru> <20070723132431.42afbae8.akpm@linux-foundation.org> <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru> <20070723141137.171e4ac1.akpm@linux-foundation.org> <20070723220446.GA5822@martell.zuzino.mipt.ru> <20070723152712.02ded067.akpm@linux-foundation.org> <20070724081750.GM3287@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mark.fasheh@oracle.com, dan.j.williams@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:10094 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbXGXIVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 04:21:47 -0400
Content-Disposition: inline
In-Reply-To: <20070724081750.GM3287@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24 2007, Jens Axboe wrote:
> On Mon, Jul 23 2007, Andrew Morton wrote:
> > I worked out that the crash I saw was in
> > 
> >         BUG_ON(!pte_none(*(kmap_pte-idx)));
> > 
> > in the read of kmap_pte[idx].  Which would be weird as the caller is using 
> > a literal KM_USER0.
> > 
> > So maybe I goofed, and that BUG_ON is triggering (it scrolled off, and I am
> > unable to reproduce it now).
> > 
> > If that BUG_ON _is_ triggering then it might indicate that someone is doing
> > a __GFP_HIGHMEM|__GFP_ZERO allocation while holding KM_USER0.
> 
> Or doing double kunmaps, or doing a kunmap_atomic() on the page, not the
> address. I've seen both of those end up triggering that BUG_ON() in a
> later kmap.
> 
> Looking over the 2.6.22..2.6.23-rc1 diff, I found one such error in
> ocfs2 at least. But you are probably not using that, so I'll keep
> looking...

What about the new async crypto stuff? I've been looking, but is it
guarenteed that async_memcpy() runs in process context with interrupts
enabled always? If not, there's a km type bug there.

In general, I think the highmem stuff could do with more safety checks:

- People ALWAYS get the atomic unmaps wrong, passing in the page instead
  of the address. I've seen tons of these. And since kunmap_atomic()
  takes a void pointer, nobody notices until it goes boom.
- People easily get the km type wrong - they use KM_USERx in interrupt
  context, or one of the irq variants without disabling interrupts.

If we could just catch these two types of bugs, we've got a lot of these
problems covered.


-- 
Jens Axboe

