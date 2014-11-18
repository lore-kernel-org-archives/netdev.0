From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb()
 and fast_wmb()
Date: Mon, 17 Nov 2014 19:13:29 -0800
Message-ID: <546AB959.1020602@redhat.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server>	 <20141117171812.22333.90395.stgit@ahduyck-server>	 <1416254687.18381.3.camel@kernel.crashing.org> <546A5968.1090201@gmail.com> <1416271167.18381.16.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mathieu.desnoyers@polymtl.ca,
	peterz@infradead.org, heiko.carstens@de.ibm.com, mingo@kernel.org,
	mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, paulmck@linux.vnet.ibm.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com,
	davem@davemloft.net
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416271167.18381.16.camel@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/17/2014 04:39 PM, Benjamin Herrenschmidt wrote:
> On Mon, 2014-11-17 at 12:24 -0800, Alexander Duyck wrote:
>> Yes and no.  So for example on ARM I used the dmb() operation, however
>> I
>> have to use the barrier at the system level instead of just the inner
>> shared domain.  However on many other architectures they are just the
>> same as the smp_* variants.
>>
>> Basically the resultant code is somewhere between the smp and non-smp
>> barriers in terms of what they cover.
> There I don't quite follow you. You need to explain better especially in
> the documentation because otherwise people will get it wrong...
>
> If it's ordering in the coherent domain, I fail to see how a DMA agent
> is different than another processor when it comes to barriers, so I fail
> to see the difference with smp_*
>
> I understand the MMIO vs. memory issue, we do have the same on powerpc,
> but that other aspect eludes me.
>
> Ben.

ARM adds some funky things.  They have two different types of 
primitives, a dmb() which is a data memory barrier, and a dsb() which is 
a data synchronization barrier.  Then with each of those they have the 
"domains" the barriers are effective within.

So for example on ARM a rmb() is dsb(sy) which means it is a system wide 
synchronization barrier which stops execution on the CPU core until the 
read completes.  However the smp_rmb() is a dmb(ish) which means it is 
only a barrier as far as the inner shareable domain which I believe only 
goes as far as the local shared cache hierarchy and only guarantees read 
ordering without necessarily halting the CPU or stopping in-order 
speculative reads.  So what a coherent_rmb() would be in my setup is 
dmb(sy) which means the barrier runs all the way out to memory, and it 
is allowed to speculative read as long as it does it in order.

If it is still unclear you might check out Will Deacon's talk on the 
topic at https://www.youtube.com/watch?v=6ORn6_35kKo, at about 7:00 in 
he explains the whole domains thing, and at 13:30 he explains dmb()/dsb().

- Alex
