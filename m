From: Adrian Bunk <bunk@stusta.de>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 19:59:51 +0200
Message-ID: <20070724175951.GC6019@stusta.de>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org> <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru> <20070723132431.42afbae8.akpm@linux-foundation.org> <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru> <20070723141137.171e4ac1.akpm@linux-foundation.org> <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:43251 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755310AbXGXSA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 14:00:27 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 23, 2007 at 02:28:11PM -0700, Linus Torvalds wrote:
> 
> 
> On Mon, 23 Jul 2007, Andrew Morton wrote:
> > 
> > It'd be nice to get a clean trace.  Are you able to obtain the full
> > trace with CONFIG_FRAME_POINTER=y?
> 
> If you are talking about
> 
> 	http://userweb.kernel.org/~akpm/dsc03659.jpg
> 
> then I think that _is_ a full trace. It's certainly not very messy, and it 
> seems accurate. It's just that inlining makes it much harder to see the 
> call-graphs, but that's what inlining does..
> 
> For example, missing from the call graph is
> 
> 	get_page_from_freelist ->
> 	  buffered_rmqueue ->		[ missing - inlined ]
> 	    prep_new_page ->		[ missing - inlined ]
> 	      prep_zero_page ->		[ missing - inlined ]
> 		clear_highpage ->	[ missing - inlined ]
> 		  kmap_atomic ->	[ missing - tailcall ]
> 		    kmap_atomic_prot
> 
> but I'm pretty sure the call trace is good (and I'm also pretty sure gcc 
> is overly aggressive at inlining, and that it causes us pain for 
> debugging, but whatever)
>...

For prep_zero_page() and clear_highpage() we can't blame gcc since we 
force gcc to always inline them.

buffered_rmqueue() and prep_new_page() are static functions with only 
one caller each, and for the normal non-debug case it's a really nice 
optimization to have them inlined automatically. But it might make sense 
to add -fno-inline-functions-called-once to the CFLAGS depending on some 
debug option?

> 			Linus

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

