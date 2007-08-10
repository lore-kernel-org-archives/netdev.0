From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 15:51:11 -0400
Message-ID: <46BCC1AF.5050204@redhat.com>
References: <20070809135107.GA15985@shell.boston.redhat.com> <617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: "Luck, Tony" <tony.luck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937912AbXHJTvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 15:51:48 -0400
In-Reply-To: <617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luck, Tony wrote:
>> +#define atomic_read(v)		(*(volatile __s32 *)&(v)->counter)
>> +#define atomic64_read(v)	(*(volatile __s64 *)&(v)->counter)
>>
>>  #define atomic_set(v,i)		(((v)->counter) = (i))
>>  #define atomic64_set(v,i)	(((v)->counter) = (i))
> 
> 
> Losing the volatile from the "set" variants definitely changes
> the code generated.  Before the patch gcc would give us:
> 
> 	st4.rel [r37]=r9
> 
> after
> 	st4 [r37]=r9
> 
> It is unclear whether anyone relies on (or even whether they should
> rely on) the release semantics that are provided by the current
> version of atomic.h.  But making this change would require an
> audit of all the uses of atomic_set() to find an answer.
> 
> There is a more worrying difference in the generated code (this
> from the ancient and venerable gcc 3.4.6 that is on my build
> machine).   In rwsem_down_failed_common I see this change (after
> disassembling vmlinux, I used sed to zap the low 32-bits of addresses
> to make the diff manageable ... that's why the addresses all end
> in xxxxxxxx):
> 
> 712868,712873c712913,712921
> < a0000001xxxxxxxx:                 adds r16=-1,r30
> < a0000001xxxxxxxx:     [MII]       ld8.acq r33=[r32]
> < a0000001xxxxxxxx:                 nop.i 0x0;;
> < a0000001xxxxxxxx:                 add r42=r33,r16
> < a0000001xxxxxxxx:     [MMI]       mov.m ar.ccv=r33;;
> < a0000001xxxxxxxx:                 cmpxchg8.acq r34=[r32],r42,ar.ccv
> ---
>> a0000001xxxxxxxx:                 adds r16=-1,r31
>> a0000001xxxxxxxx:     [MMI]       ld4.acq r14=[r32];;
>> a0000001xxxxxxxx:                 nop.m 0x0
>> a0000001xxxxxxxx:                 sxt4 r34=r14
>> a0000001xxxxxxxx:     [MMI]       nop.m 0x0;;
>> a0000001xxxxxxxx:                 nop.m 0x0
>> a0000001xxxxxxxx:                 add r15=r34,r16
>> a0000001xxxxxxxx:     [MMI]       mov.m ar.ccv=r34;;
>> a0000001xxxxxxxx:                 cmpxchg8.acq r42=[r32],r15,ar.ccv
> 
> This code is probably from the rwsem_atomic_update(adjustment, sem) macro
> which is cpp'd to atomic64_add_return().  It looks really bad that the new
> code reads a 32-bit value and sign extends it rather than reading a 64-bit
> value (but I'm perplexed as to why this patch provoked this change in the
> generated code).
> 
> -Tony

That's distressing.  I'm about to resubmit with a volatile cast in 
atomic_set as well, since people expect that behavior and I've been 
shown a legitimate case where it could matter.  Does the assembly look 
right with that cast in atomic_set() as well?

	-- Chris
