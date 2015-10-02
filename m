From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Fri, 2 Oct 2015 14:50:44 -0700
Message-ID: <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>, netdev@vger.kernel.org,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:57082 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbJBVuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 17:50:46 -0400
In-Reply-To: <20151002154039.69f82bdc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Oct 2015 15:40:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > Thus, I need introducing new code like this patch and at the same time
> > have to reduce the number of instruction-cache misses/usage.  In this
> > case we solve the problem by kmem_cache_free_bulk() not getting called
> > too often. Thus, +17 bytes will hopefully not matter too much... but on
> > the other hand we sort-of know that calling kmem_cache_free_bulk() will
> > cause icache misses.
> 
> I just tested this change on top of my net-use-case patchset... and for
> some strange reason the code with this WARN_ON is faster and have much
> less icache-misses (1,278,276 vs 2,719,158 L1-icache-load-misses).
> 
> Thus, I think we should keep your fix.
> 
> I cannot explain why using WARN_ON() is better and cause less icache
> misses.  And I hate when I don't understand every detail.
> 
>  My theory is, after reading the assembler code, that the UD2
> instruction (from BUG_ON) cause some kind of icache decoder stall
> (Intel experts???).  Now that should not be a problem, as UD2 is
> obviously placed as an unlikely branch and left at the end of the asm
> function call.  But the call to __slab_free() is also placed at the end
> of the asm function (gets inlined from slab_free() as unlikely).  And
> it is actually fairly likely that bulking is calling __slab_free (slub
> slowpath call).

Yes, I was looking at the asm code and the difference is pretty small:
a not-taken ud2 versus a not-taken "call warn_slowpath_null", mainly.

But I wouldn't assume that the microbenchmarking is meaningful.  I've
seen shockingly large (and quite repeatable) microbenchmarking
differences from small changes in code which isn't even executed (and
this is one such case, actually).  You add or remove just one byte of
text and half the kernel (or half the .o file?) gets a different
alignment and this seems to change everything.

Deleting the BUG altogether sounds the best solution.  As long as the
kernel crashes in some manner, we'll be able to work out what happened.
And it's cant-happen anyway, isn't it?
