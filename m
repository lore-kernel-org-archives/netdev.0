From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Thu, 3 Apr 2008 16:22:26 +1100
Message-ID: <200804031622.26973.nickpiggin@yahoo.com.au>
References: <20080401235609.GA6947@codemonkey.org.uk> <200804022012.58760.nickpiggin@yahoo.com.au> <20080402085437.7d9abf1f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp114.mail.mud.yahoo.com ([209.191.84.67]:44892 "HELO
	smtp114.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752248AbYDCF3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:29:53 -0400
In-Reply-To: <20080402085437.7d9abf1f.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 April 2008 02:54, Andrew Morton wrote:
> On Wed, 2 Apr 2008 20:12:58 +1100 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > On Wednesday 02 April 2008 18:56, Andrew Morton wrote:
> > > > Limiting this to once per boot should suffice for debugging purposes.
> > > > Even if you manage to concoct a bug that always survives the first
> > > > failure, you should be able to take the hint when you keep seeing
> > > > this in dmesg.
> > >
> > > The appropriate thing to do here is to convert known-good drivers (such
> > > as e1000[e]) to use __GFP_NOWARN.
> > >
> > > Unfortunately netdev_alloc_skb() went and assumed GFP_ATOMIC, but I
> > > guess we can dive below the covers and use __netdev_alloc_skb():
> >
> > It's still actually nice to know how often it is happening even for
> > these known good sites because too much can indicate a problem and
> > that you could actually bring performance up by tuning some things.
>
> Yes, it's useful debugging.  It tells us when we mucked up the page
> allocator.

Right.


> It also tells us when we mucked up the net driver - I doubt if we (or at
> least, I) would have discovered that e1000 does a 32k allocation for a
> 5k(?) frame if this warning wasn't coming out.

Is that right? If it is allocating for 9K MTU, then the slab allocator
(slub in this case) will bump that up to the 16K kmalloc slab. If it is
a 5K frame, then it would get the 8K kmalloc slab I think.

Oh, but SLUB's default MIN_OBJECTS is 4, so 4*8 is 32 indeed. So slub
is probably deciding to round the kmalloc-8192 allocations up to order-3.
I think. How did you know it was a 5k frame? :)

