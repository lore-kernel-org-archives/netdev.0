From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Mon, 23 Jul 2007 13:24:31 -0700
Message-ID: <20070723132431.42afbae8.akpm@linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	<20070723183839.GA5874@martell.zuzino.mipt.ru>
	<20070723190152.GA5755@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38875 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935701AbXGWUYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 16:24:39 -0400
In-Reply-To: <20070723190152.GA5755@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jul 2007 23:01:52 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Mon, Jul 23, 2007 at 10:38:39PM +0400, Alexey Dobriyan wrote:
> > Managed to hit BUG_ON() in kmap_atomic_prot() three times while doing
> > nothing unusual for this box (two times it was under X, so I can't
> > guarantee, one time while trying to reproduce via ./configure in gdb
> > tarball)

Yeah, I hit this several times a few days ago.  Same story: it just
randomly went splat in response to no obvious stimulus.  Reported it to
netdev, was greeted with stunned silence.


> > Box has 2.5G of RAM. 2.6.22 was OK.
> > 
> > [dives into framebuffer console setup for complete oops]
> 
> kernel BUG at arch/i386/mm/highmem.c:38
> PREEMPT DEBUG_PAGEALLOC SLAB
> EIP at kmap_atomic_prot+0x32/0x93
> 	get_page_from_freelist
> 	__alloc_pages
> 	cache_alloc_refill
> 	cache_alloc_refill
> 	kmem_cache_alloc
> 	dst_alloc
> 	dst_alloc
> 	__ip_route_output_key
> 	[some junk I don't trust]
> 
> eax: 0000000c
> ebx: 00000003
> ecx: c065efe0
> edx: 00000003
> edi: 00000163
> 
> 
> c010cc9b <kmap_atomic_prot>:
> c010cc9b:	57                   	push   %edi
> c010cc9c:	56                   	push   %esi
> c010cc9d:	53                   	push   %ebx
> c010cc9e:	89 c6                	mov    %eax,%esi
> c010cca0:	89 d3                	mov    %edx,%ebx
> c010cca2:	89 cf                	mov    %ecx,%edi
> c010cca4:	b8 01 00 00 00       	mov    $0x1,%eax
> c010cca9:	e8 dd 1b 00 00       	call   c010e88b <add_preempt_count>
> c010ccae:	e8 b1 ac 0e 00       	call   c01f7964 <debug_smp_processor_id>
> c010ccb3:	6b c0 0d             	imul   $0xd,%eax,%eax
> c010ccb6:	8d 14 03             	lea    (%ebx,%eax,1),%edx
> c010ccb9:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
> c010ccc0:	8b 0d 30 a1 3e c0    	mov    0xc03ea130,%ecx
> c010ccc6:	29 c1                	sub    %eax,%ecx
> c010ccc8:	83 39 00             	cmpl   $0x0,(%ecx)
> c010cccb:	74 04                	je     c010ccd1 <kmap_atomic_prot+0x36>
> c010cccd:	0f 0b                	ud2a   

I had more complete info: http://article.gmane.org/gmane.linux.network/66966

You're using DEBUG_PAGEALLOC, but I was not, so I think we can rule that out.

I haven't worked out where that kmap_atomic() call is coming from yet. 
Both traces point up into the page allocator, but I _think_ that's stack
gunk.
