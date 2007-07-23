From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Mon, 23 Jul 2007 15:27:12 -0700
Message-ID: <20070723152712.02ded067.akpm@linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	<20070723183839.GA5874@martell.zuzino.mipt.ru>
	<20070723190152.GA5755@martell.zuzino.mipt.ru>
	<20070723132431.42afbae8.akpm@linux-foundation.org>
	<20070723204045.GD5755@martell.zuzino.mipt.ru>
	<20070723210153.GA5753@martell.zuzino.mipt.ru>
	<20070723141137.171e4ac1.akpm@linux-foundation.org>
	<20070723220446.GA5822@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933611AbXGWW2j@vger.kernel.org>
In-Reply-To: <20070723220446.GA5822@martell.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2007 02:04:46 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Mon, Jul 23, 2007 at 02:11:37PM -0700, Andrew Morton wrote:
> > On Tue, 24 Jul 2007 01:01:53 +0400
> > Alexey Dobriyan <adobriyan@gmail.com> wrote:
> > 
> > > On Tue, Jul 24, 2007 at 12:40:45AM +0400, Alexey Dobriyan wrote:
> > > > > I had more complete info: http://article.gmane.org/gmane.linux.network/66966
> > > > > 
> > > > > You're using DEBUG_PAGEALLOC, but I was not, so I think we can rule that out.
> > > > > 
> > > > > I haven't worked out where that kmap_atomic() call is coming from yet. 
> > > > > Both traces point up into the page allocator, but I _think_ that's stack
> > > > > gunk.
> > > > 
> > > > Ahh, you suspect networking.
> > > > 
> > > > Here, setup is 2 cheap-ass 100Mb realtek 8139 NICs, one to campus network
> > > > receiving ~20 junk packets per second, one gathering netconsole output
> > > > and ssh to it, no conntracks and fancy stuff.
> > > > 
> > > > [reboots with cables physically unplugged]
> > > 
> > > OK, I run gdb recompile, cat(1) every file in /usr/portage (shitload of
> > > small files) with both cables unplugged. It all went fine for ~5 minutes
> > > after that it crashed exactly same way after 10 secs after plugging one
> > > of them.
> > 
> > It'd be nice to get a clean trace.  Are you able to obtain the full
> > trace with CONFIG_FRAME_POINTER=y?
> 
> Sorry, no camera shot, finding camera requires wakening up M. :)
> 
> It took longer that usual, but here it is
> 
> 	kmap_atomic
> 	get_page_from_freelist
> 	__alloc_pages
> 	cache_alloc_refill
> 	__alloc_pages
> 	cache_alloc_refill
> 	kmem_cache_alloc
> 	dst_alloc
> 	ip_route_input
> 	ip_rcv
> 	netif_receive_skb
> 	rtl8139_poll
> 	net_rx_action
> 	__do_softirq
> 	do_softirq
> 	irq_exit
> 	do_IRQ
> 	common_interrupt
> 	handle_mm_fault
> 	do_page_fault
> 	error_core
> 
> much more loaded x86_64 box near also running 2.6.23-rc1 with debugging
> turned on, using atl1 driver doesn't experience any crashes.
> 
> And I found 2.6.22-b91cba52e9b7b3f1c0037908a192d93a869ca9e5-x entry on
> top of grub config which means b91cba52e9b7b3f1c0037908a192d93a869ca9e5
> _without_ any debugging was OK.

I worked out that the crash I saw was in

        BUG_ON(!pte_none(*(kmap_pte-idx)));

in the read of kmap_pte[idx].  Which would be weird as the caller is using 
a literal KM_USER0.

So maybe I goofed, and that BUG_ON is triggering (it scrolled off, and I am
unable to reproduce it now).

If that BUG_ON _is_ triggering then it might indicate that someone is doing
a __GFP_HIGHMEM|__GFP_ZERO allocation while holding KM_USER0.

If they're holding an atomic kmap then they'll be running in_atomic so it
is unlikely that they accidentally added __GFP_WAIT because lots of people
would be getting lots of might_sleep() warnings.

Hence that first VM_BUG_ON in prep_zero_page() _should_ be triggering.

Do you have CONFIG_DEBUG_VM enabled?



Also, it might be useful to apply -mm's kmap_atomic-debugging.patch.  it
will detect lots of abuse.
