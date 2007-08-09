From: Chris Snook <csnook@redhat.com>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Thu, 09 Aug 2007 08:40:43 -0400
Message-ID: <46BB0B4B.4070300@redhat.com>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com> <46BA30DC.20207@redhat.com> <20070809001533.GA17798@one.firstfloor.org> <200708091435.18595.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	torvalds@osdl.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764314AbXHIMlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 08:41:04 -0400
In-Reply-To: <200708091435.18595.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Thursday 09 August 2007 02:15:33 Andi Kleen wrote:
>> On Wed, Aug 08, 2007 at 05:08:44PM -0400, Chris Snook wrote:
>>> Heiko Carstens wrote:
>>>> On Wed, Aug 08, 2007 at 03:21:31AM -0700, David Miller wrote:
>>>>> From: Heiko Carstens <heiko.carstens@de.ibm.com>
>>>>> Date: Wed, 8 Aug 2007 11:33:00 +0200
>>>>>
>>>>>> Just saw this while grepping for atomic_reads in a while loops.
>>>>>> Maybe we should re-add the volatile to atomic_t. Not sure.
>>>>> I think whatever the choice, it should be done consistently
>>>>> on every architecture.
>>>>>
>>>>> It's just asking for trouble if your arch does it differently from
>>>>> every other.
>>>> Well..currently it's i386/x86_64 and s390 which have no volatile
>>>> in atomic_t. And yes, of course I agree it should be consistent
>>>> across all architectures. But it isn't.
>>> Based on recent discussion, it's pretty clear that there's a lot of 
>>> confusion about this.  A lot of people (myself included, until I thought 
>>> about it long and hard) will reasonably assume that calling 
>>> atomic_read() will actually read the value from memory.  Leaving out the 
>>> volatile declaration seems like a pessimization to me.  If you force 
>>> people to use barrier() everywhere they're working with atomic_t, it 
>>> will force re-reads of all the non-atomic data in use as well, which 
>>> will cause more memory fetches of things that generally don't need 
>>> barrier().  That and it's a bug waiting to happen.
>>>
>>> Andi -- your thoughts on the matter?
>> I also think readding volatile makes sense. An alternative would be
>> to stick an rmb() into atomic_read() -- that would also stop speculative reads.
>> Disadvantage is that it clobbers all memory, not just the specific value.
>>
>> But you really have to complain to Linus (cc'ed). He came up
>> with the volatile removale change iirc.
> 
> Isn't it possible through some inline assembly trick
> that only a certain variable has to be reloaded?
> So we could define something like that:
> 
> #define reload_var(x) __asm__ __volatile__ (whatever, x)
> 
> I don't know inline assembly that much, but isn't it possible
> with that to kind of "fake-touch" the variable, so the compiler
> must reload it (and only it) to make sure it's up to date?

We can do it in C, like this:

-#define atomic_read(v) ((v)->counter)
+#define atomic_read(v) (*(volatile int *)&(v)->counter)

By casting it volatile at the precise piece of code where we want to guarantee a 
read from memory, there's little risk of the compiler getting creative in its 
interpretation of the code.

Stay tuned for the patch set...

	-- Chris
