From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] softirq: punt to ksoftirqd if __do_softirq recently looped
Date: Fri, 11 Apr 2014 20:02:25 -0400
Message-ID: <53488291.1040501@redhat.com>
References: <20140410115706.662fb5e7@annuminas.surriel.com> <20140411.163342.1319748709214614224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jbenc@redhat.com, peterz@infradead.org, tglx@linutronix.de,
	fweisbec@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140411.163342.1319748709214614224.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2014 04:33 PM, David Miller wrote:
> From: Rik van Riel <riel@redhat.com>
> Date: Thu, 10 Apr 2014 11:57:06 -0400
> 
>> @@ -330,7 +334,11 @@ void irq_enter(void)
>>  
>>  static inline void invoke_softirq(void)
>>  {
>> -	if (!force_irqthreads) {
>> +	/*
>> +	 * If force_irqthreads is set, or if we looped in __do_softirq this
>> +	 * jiffie, punt to ksoftirqd to prevent userland starvation.
>> +	 */
>> +	if (!force_irqthreads && this_cpu_read(softirq_looped) != jiffies) {
> 
> If we do this, which I'm not convinced of yet, I think we should use two
> jiffies as the cutoff.

I am not fully convinced, either.  This patch mostly just illustrates
the problem, and gives something that solves Jiri's immediate problem.

It is quite likely that there is a better way to solve the problem of:
1) softirq handling starving out userspace processing,
2) which could be solved by moving the userspace process elsewhere, and
3) shifting softirq processing to ksoftirqd

A working patch seems to be one of the better ways to start a
discussion, though.

If anybody has a nicer idea on how to solve the problem, I'd even be
willing to implement your idea, and give Jiri another patch to test :)

-- 
All rights reversed
