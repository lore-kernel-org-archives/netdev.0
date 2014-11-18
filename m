From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb()
 and fast_wmb()
Date: Tue, 18 Nov 2014 08:20:46 -0800
Message-ID: <546B71DE.4050506@redhat.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server> <20141117171812.22333.90395.stgit@ahduyck-server> <1416254687.18381.3.camel@kernel.crashing.org> <546A5968.1090201@gmail.com> <1416271167.18381.16.camel@kernel.crashing.org> <546AB959.1020602@redhat.com> <20141118115836.GL18842@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vn
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932100AbaKRQ3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 11:29:24 -0500
In-Reply-To: <20141118115836.GL18842@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/18/2014 03:58 AM, Will Deacon wrote:
> On Tue, Nov 18, 2014 at 03:13:29AM +0000, Alexander Duyck wrote:
>> On 11/17/2014 04:39 PM, Benjamin Herrenschmidt wrote:
>>> On Mon, 2014-11-17 at 12:24 -0800, Alexander Duyck wrote:
>>>> Yes and no.  So for example on ARM I used the dmb() operation, however
>>>> I
>>>> have to use the barrier at the system level instead of just the inner
>>>> shared domain.  However on many other architectures they are just the
>>>> same as the smp_* variants.
>>>>
>>>> Basically the resultant code is somewhere between the smp and non-smp
>>>> barriers in terms of what they cover.
>>> There I don't quite follow you. You need to explain better especially in
>>> the documentation because otherwise people will get it wrong...
>>>
>>> If it's ordering in the coherent domain, I fail to see how a DMA agent
>>> is different than another processor when it comes to barriers, so I fail
>>> to see the difference with smp_*
>>>
>>> I understand the MMIO vs. memory issue, we do have the same on powerpc,
>>> but that other aspect eludes me.
>>>
>> ARM adds some funky things.  They have two different types of
>> primitives, a dmb() which is a data memory barrier, and a dsb() which is
>> a data synchronization barrier.  Then with each of those they have the
>> "domains" the barriers are effective within.
>>
>> So for example on ARM a rmb() is dsb(sy) which means it is a system wide
>> synchronization barrier which stops execution on the CPU core until the
>> read completes.  However the smp_rmb() is a dmb(ish) which means it is
>> only a barrier as far as the inner shareable domain which I believe only
>> goes as far as the local shared cache hierarchy and only guarantees read
>> ordering without necessarily halting the CPU or stopping in-order
>> speculative reads.  So what a coherent_rmb() would be in my setup is
>> dmb(sy) which means the barrier runs all the way out to memory, and it
>> is allowed to speculative read as long as it does it in order.
>>
>> If it is still unclear you might check out Will Deacon's talk on the
>> topic at https://www.youtube.com/watch?v=6ORn6_35kKo, at about 7:00 in
>> he explains the whole domains thing, and at 13:30 he explains dmb()/dsb().
> So actually, this is an interesting case where the barrier would like to
> know whether the memory returned by dma_alloc_coherent is h/w coherent
> (normal, cacheable) or s/w coherent (normal, non-cacheable). I think Ben
> is thinking of the h/w coherent case (i.e. actual snooping into the CPU
> caches by the DMA master).
>
> For the former, we could use inner-shareable barriers. For the latter, we'd
> need to use outer-shareable barriers.
>
> If we can't tell, then these should be dmb(osh), which will work for both.
>
> Will

Okay, so I will update the ARM portion of my patches to use osh and 
oshst then since it sounds like I was using too strong of barriers.

- Alex
