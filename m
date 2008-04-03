From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Thu, 3 Apr 2008 12:59:22 +0400
Message-ID: <20080403085922.GA10874@2ka.mipt.ru>
References: <20080401235609.GA6947@codemonkey.org.uk> <200804022012.58760.nickpiggin@yahoo.com.au> <20080402085437.7d9abf1f.akpm@linux-foundation.org> <200804031622.26973.nickpiggin@yahoo.com.au> <20080402223254.5ac50337.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49659 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582AbYDCJDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 05:03:46 -0400
Content-Disposition: inline
In-Reply-To: <20080402223254.5ac50337.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2008 at 10:32:54PM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > > It also tells us when we mucked up the net driver - I doubt if we (or at
> > > least, I) would have discovered that e1000 does a 32k allocation for a
> > > 5k(?) frame if this warning wasn't coming out.
> > 
> > Is that right? If it is allocating for 9K MTU, then the slab allocator
> > (slub in this case) will bump that up to the 16K kmalloc slab. If it is
> > a 5K frame, then it would get the 8K kmalloc slab I think.
> > 
> > Oh, but SLUB's default MIN_OBJECTS is 4, so 4*8 is 32 indeed. So slub
> > is probably deciding to round the kmalloc-8192 allocations up to order-3.
> > I think. How did you know it was a 5k frame? :)
> 
> urgh, it was a while ago, and I don't know if e1000e retains the behaviour.
> 
> iirc the issue was with some errant versions of the hardware needing
> exorbitant alignment and additional padding at the end because of
> occasional DMA overruns.  Something like that.

e1000 hardware does require power-of-two alignment, network stack adds
additional structure at the end, so with e1000 it ends up with two
rounds to the higher power of two.
5k ends up with 16k allocations, 9k - to 32k.

This problem is known for years already and number of fixes was
proposed, but the really good one is to rewrite e1000 allocation path to
use fragments, which I believe was done in the new e1000 driver.

And as a side note: shuting allocation failures is a very bad step,
since it hides allocation problems for drivers. if people do care about
it add __GFP_SMALL_WARN flag which will just print that allocation
failed, its order and function where it happend.

-- 
	Evgeniy Polyakov
