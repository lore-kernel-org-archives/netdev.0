From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 09 Aug 2007 03:47:57 -0400
Message-ID: <46BAC6AD.7050603@redhat.com>
References: <E1IIwQx-000468-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762815AbXHIHst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 03:48:49 -0400
In-Reply-To: <E1IIwQx-000468-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Chris Snook <csnook@redhat.com> wrote:
>> Some architectures currently do not declare the contents of an atomic_t to be
>> volatile.  This causes confusion since atomic_read() might not actually read
>> anything if an optimizing compiler re-uses a value stored in a register, which
>> can break code that loops until something external changes the value of an
>> atomic_t.  Avoiding such bugs requires using barrier(), which causes re-loads
> 
> Such loops should always use something like cpu_relax() which comes
> with a barrier.

If they're not doing anything, sure.  Plenty of loops actually do some sort of 
real work while waiting for their halt condition, possibly even work which is 
necessary for their halt condition to occur, and you definitely don't want to be 
doing cpu_relax() in this case.  On register-rich architectures you can do quite 
a lot of work without needing to reuse the register containing the result of the 
atomic_read().  Those are precisely the architectures where barrier() hurts the 
most.

>> of all registers used in the loop, thus hurting performance instead of helping
>> it, particularly on architectures where it's unnecessary.  Since we generally
> 
> Do you have an example of such a loop where performance is hurt by this?

Not handy.  Perhaps more interesting are cases where we access the same atomic_t 
twice in a hot path.  If we can remove some of those barriers, those hot paths 
will get faster.

Performance was only part of the motivation.  The IPVS bug was an example of how 
atomic_t is assumed (not always correctly) to work, and other recent discussions 
on this list have made it clear that most people assume atomic_read() actually 
reads something every time, and don't even think to consult the documentation 
until they find out the hard way that it does not.  I'm not saying we should 
encourage lazy programming, but in this case the assumption is reasonable 
because that's how people actually use atomic_t, and making this behavior 
uniform across all architectures makes it more convenient to do things the right 
way, which we should encourage.

> The IPVS code that led to this patch was simply broken and has been
> fixed to use cpu_relax().

I agree, busy-waiting should be done with cpu_relax(), if at all.  I'm more 
concerned about cases that are not busy-waiting, but could still get compiled 
with the same optimization.

	-- Chris
