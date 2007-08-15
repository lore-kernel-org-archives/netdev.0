From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 12:13:12 -0400
Message-ID: <46C32618.2080108@redhat.com>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, clameter@sgi.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbXHOQOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 12:14:10 -0400
In-Reply-To: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Chris Snook <csnook@redhat.com> wrote:
>> Because atomic operations are generally used for synchronization, which requires 
>> volatile behavior.  Most such codepaths currently use an inefficient barrier(). 
>>  Some forget to and we get bugs, because people assume that atomic_read() 
>> actually reads something, and atomic_write() actually writes something.  Worse, 
>> these are architecture-specific, even compiler version-specific bugs that are 
>> often difficult to track down.
> 
> I'm yet to see a single example from the current tree where
> this patch series is the correct solution.  So far the only
> example has been a buggy piece of code which has since been
> fixed with a cpu_relax.

Part of the motivation here is to fix heisenbugs.  If I knew where they 
were, I'd be posting patches for them.  Unlike most bugs, where we want 
to expose them as obviously as possible, these can be extremely 
difficult to track down, and are often due to people assuming that the 
atomic_* operations have the same semantics they've historically had. 
Remember that until recently, all SMP architectures except s390 (which 
very few kernel developers outside of IBM, Red Hat, and SuSE do much 
work on) had volatile declarations for atomic_t.  Removing the volatile 
declarations from i386 and x86_64 may have created heisenbugs that won't 
manifest themselves until GCC 6.0 comes out and people start compiling 
kernels with -O5.  We should have consistent semantics for atomic_* 
operations.

The other motivation is to reduce the need for the barriers used to 
prevent/fix such problems which clobber all your registers, and instead 
force atomic_* operations to behave in the way they're actually used. 
After the (resubmitted) patchset is merged, we'll be able to remove a 
whole bunch of barriers, shrinking our source and our binaries, and 
improving performance.

	-- Chris
