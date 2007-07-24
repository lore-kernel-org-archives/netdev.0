From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 01:34:55 -0700
Message-ID: <20070724013455.691e6752.akpm@linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	<20070723183839.GA5874@martell.zuzino.mipt.ru>
	<20070723190152.GA5755@martell.zuzino.mipt.ru>
	<20070723132431.42afbae8.akpm@linux-foundation.org>
	<20070723204045.GD5755@martell.zuzino.mipt.ru>
	<20070723210153.GA5753@martell.zuzino.mipt.ru>
	<20070723141137.171e4ac1.akpm@linux-foundation.org>
	<20070723220446.GA5822@martell.zuzino.mipt.ru>
	<20070723152712.02ded067.akpm@linux-foundation.org>
	<20070724081750.GM3287@kernel.dk>
	<20070724082207.GN3287@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mark.fasheh@oracle.com, dan.j.williams@intel.com,
	"Nelson, Shannon" <shannon.nelson@intel.com>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51196 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752480AbXGXIfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 04:35:45 -0400
In-Reply-To: <20070724082207.GN3287@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2007 10:22:07 +0200 Jens Axboe <jens.axboe@oracle.com> wrote:

> On Tue, Jul 24 2007, Jens Axboe wrote:
> > On Mon, Jul 23 2007, Andrew Morton wrote:
> > > I worked out that the crash I saw was in
> > > 
> > >         BUG_ON(!pte_none(*(kmap_pte-idx)));
> > > 
> > > in the read of kmap_pte[idx].  Which would be weird as the caller is using 
> > > a literal KM_USER0.
> > > 
> > > So maybe I goofed, and that BUG_ON is triggering (it scrolled off, and I am
> > > unable to reproduce it now).
> > > 
> > > If that BUG_ON _is_ triggering then it might indicate that someone is doing
> > > a __GFP_HIGHMEM|__GFP_ZERO allocation while holding KM_USER0.
> > 
> > Or doing double kunmaps, or doing a kunmap_atomic() on the page, not the
> > address. I've seen both of those end up triggering that BUG_ON() in a
> > later kmap.
> > 
> > Looking over the 2.6.22..2.6.23-rc1 diff, I found one such error in
> > ocfs2 at least. But you are probably not using that, so I'll keep
> > looking...
> 
> What about the new async crypto stuff? I've been looking, but is it
> guarenteed that async_memcpy() runs in process context with interrupts
> enabled always? If not, there's a km type bug there.

I think Shannon maintains that now.

> In general, I think the highmem stuff could do with more safety checks:
> 
> - People ALWAYS get the atomic unmaps wrong, passing in the page instead
>   of the address. I've seen tons of these. And since kunmap_atomic()
>   takes a void pointer, nobody notices until it goes boom.

yeah, it's a real trap.  For a while I had a patch which converted
kmap_atomic() to return a char*, and kunmap_atomic() to take a char*, so
misuse got compile warnings.  But it was a pig to maintain so I tossed it. 
It'd be somewhat easier to do now we've converted a lot of callers to
clear_user_highpage() and similar.

> - People easily get the km type wrong - they use KM_USERx in interrupt
>   context, or one of the irq variants without disabling interrupts.
> 
> If we could just catch these two types of bugs, we've got a lot of these
> problems covered.

Here's the -mm debug patch:


diff -puN arch/i386/mm/highmem.c~kmap_atomic-debugging arch/i386/mm/highmem.c
--- a/arch/i386/mm/highmem.c~kmap_atomic-debugging
+++ a/arch/i386/mm/highmem.c
@@ -30,7 +30,44 @@ void *kmap_atomic(struct page *page, enu
 {
 	enum fixed_addresses idx;
 	unsigned long vaddr;
+	static unsigned warn_count = 10;
 
+	if (unlikely(warn_count == 0))
+		goto skip;
+
+	if (unlikely(in_interrupt())) {
+		if (in_irq()) {
+			if (type != KM_IRQ0 && type != KM_IRQ1 &&
+			    type != KM_BIO_SRC_IRQ && type != KM_BIO_DST_IRQ &&
+			    type != KM_BOUNCE_READ) {
+				WARN_ON(1);
+				warn_count--;
+			}
+		} else if (!irqs_disabled()) {	/* softirq */
+			if (type != KM_IRQ0 && type != KM_IRQ1 &&
+			    type != KM_SOFTIRQ0 && type != KM_SOFTIRQ1 &&
+			    type != KM_SKB_SUNRPC_DATA &&
+			    type != KM_SKB_DATA_SOFTIRQ &&
+			    type != KM_BOUNCE_READ) {
+				WARN_ON(1);
+				warn_count--;
+			}
+		}
+	}
+
+	if (type == KM_IRQ0 || type == KM_IRQ1 || type == KM_BOUNCE_READ ||
+			type == KM_BIO_SRC_IRQ || type == KM_BIO_DST_IRQ) {
+		if (!irqs_disabled()) {
+			WARN_ON(1);
+			warn_count--;
+		}
+	} else if (type == KM_SOFTIRQ0 || type == KM_SOFTIRQ1) {
+		if (irq_count() == 0 && !irqs_disabled()) {
+			WARN_ON(1);
+			warn_count--;
+		}
+	}
+skip:
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
 
_

