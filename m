From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 19:37:40 +0200
Message-ID: <27f856305da1a17bd4527a831976e6da@kernel.crashing.org>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	satyam@infradead.org, clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57801 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754376AbXHQRjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 13:39:18 -0400
In-Reply-To: <46C505B2.6030704@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>>> Part of the motivation here is to fix heisenbugs.  If I knew 
>>>>>> where they
>>>>>
>>>>> By the same token we should probably disable optimisations
>>>>> altogether since that too can create heisenbugs.
>>>>
>>>> Almost everything is a tradeoff; and so is this.  I don't
>>>> believe most people would find disabling all compiler
>>>> optimisations an acceptable price to pay for some peace
>>>> of mind.
>>>
>>>
>>> So why is this a good tradeoff?
>> It certainly is better than disabling all compiler optimisations!
>
> It's easy to be better than something really stupid :)

Sure, it wasn't me who made the comparison though.

> So i386 and x86-64 don't have volatiles there, and it saves them a
> few K of kernel text.

Which has to be investigated.  A few kB is a lot more than expected.

> What you need to justify is why it is a good
> tradeoff to make them volatile (which btw, is much harder to go
> the other way after we let people make those assumptions).

My point is that people *already* made those assumptions.  There
are two ways to clean up this mess:

1) Have the "volatile" semantics by default, change the users
    that don't need it;
2) Have "non-volatile" semantics by default, change the users
    that do need it.

Option 2) randomly breaks stuff all over the place, option 1)
doesn't.  Yeah 1) could cause some extremely minor speed or
code size regression, but only temporarily until everything has
been audited.

>>> I also think that just adding things to APIs in the hope it might fix
>>> up some bugs isn't really a good road to go down. Where do you stop?
>> I look at it the other way: keeping the "volatile" semantics in
>> atomic_XXX() (or adding them to it, whatever) helps _prevent_ bugs;
>
> Yeah, but we could add lots of things to help prevent bugs and
> would never be included. I would also contend that it helps _hide_
> bugs and encourages people to be lazy when thinking about these
> things.

Sure.  We aren't _adding_ anything here though, not on the platforms
where it is most likely to show up, anyway.

> Also, you dismiss the fact that we'd actually be *adding* volatile
> semantics back to the 2 most widely tested architectures (in terms
> of test time, number of testers, variety of configurations, and
> coverage of driver code).

I'm not dismissing that.  x86 however is one of the few architectures
where mistakenly leaving out a "volatile" will not easily show up on
user testing, since the compiler will very often produce a memory
reference anyway because it has no registers to play with.

> This is a very important different from
> just keeping volatile semantics because it is basically a one-way
> API change.

That's a good point.  Maybe we should create _two_ new APIs, one
explicitly going each way.

>> certainly most people expect that behaviour, and also that behaviour
>> is *needed* in some places and no other interface provides that
>> functionality.
>
> I don't know that most people would expect that behaviour.

I didn't conduct any formal poll either :-)

> Is there any documentation anywhere that would suggest this?

Not really I think, no.  But not the other way around, either.
Most uses of it seem to expect it though.

>> [some confusion about barriers wrt atomics snipped]
>
> What were you confused about?

Me?  Not much.


Segher

