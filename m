From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Sun, 11 Oct 2009 11:24:22 +0200
Message-ID: <4AD1A446.2000602@gmail.com>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com>	 <200909120623.49764.elendil@planet.nl> <4AAE0F7B.5050203@kernel.org>	 <4AAE105E.1080005@kernel.org> <4807377b0910091724k2a332e90i9941971f6032663c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, hpa@zytor.com
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756238AbZJKJ0Q@vger.kernel.org>
In-Reply-To: <4807377b0910091724k2a332e90i9941971f6032663c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote, On 10/10/2009 02:24 AM:

> On Mon, Sep 14, 2009 at 2:43 AM, Tejun Heo <tj@kernel.org> wrote:
>> Tejun Heo wrote:
>>> Frans Pop wrote:
>>>> Jesse Brandeburg wrote:
>>>>> I've bisected, here is my bisect log, problem is that the commit
>>>>> identified is a merge commit, and *I don't know what to revert to test*.
>>>>> It appears the parent of the merge:
>>>>> 6e15cf04860074ad032e88c306bea656bbdd0f22 is marked good, but looks to be
>>>>> in a possibly related area to the panic.
>>>> That merge does contain quite a few merge fixups, so it's quite possible
>>>> one of them is the cause of the failure.
>>>> Maybe the simplest way to verify that is to compile both parents of the
>>>> merge to doublecheck that they work OK. Then, if a compile of the merge
>>>> itself is bad, the problem really is in the merge commit itself.
>>>>
>>>> That commit is the "percpu" merge, so I've added Tejun (author of most of
>>>> that branch) and Ingo (merger) in CC.
>>> Sorry, the oops doesn't ring a bell, well, not yet at least.  It would
>>> be great if the bisection can be narrowed down more.
>> Also, building w/ debug option on, capturing more oops traces and
>> pasting gdb output of l *<oops address> might shed some more light.
> 
> Okay, it has been a while and I have an update on this issue.  The
> actual panic seems to have disappeared in 2.6.32-rc1(2), however, with
> CONFIG_CC_STACKPROTECTOR=y, I am still panicking, the stack protector
> fault shows only this message, no backtrace is listed:
> 
> Kernel stack is corrupted in: ffffffff810b5b31
> 
> I've built with a full debug kernel before this crash, so I did:
> 
> (gdb) l *0xffffffff810b5b31
> 0xffffffff810b5b31 is in move_native_irq (kernel/irq/migration.c:67).
> 62			return;
> 63	
> 64		desc->chip->mask(irq);
> 65		move_masked_irq(irq);
> 66		desc->chip->unmask(irq);
>>>> 67	}
> 68	
> (gdb) l move_native_irq
> 54	void move_native_irq(int irq)
> 55	{
> 56		struct irq_desc *desc = irq_to_desc(irq);
> 57	
> 58		if (likely(!(desc->status & IRQ_MOVE_PENDING)))
> 59			return;
> 60	
> 61		if (unlikely(desc->status & IRQ_DISABLED))
> 62			return;
> 63	
> 64		desc->chip->mask(irq);
> 65		move_masked_irq(irq);
> 66		desc->chip->unmask(irq);
> 67	}
> 
> So, this seems very related to my panic, as it is likely that
> irqbalance or something else might try to move my interrupt from one
> core to another and this seems likely related, and the original issue
> as well as this one reproduce with LOTS of MSI-X vectors active.
> 
> - I tried connecting after the panic with kgdboc, no connection
> - I tried kdump, but the same kernel I am using panics/hangs during
> boot right after udev during the kexec() kernel boot (should I try
> harder to get this working given it got so far?)
> - I have ftrace function tracer running but no way to get at the log
> post panic (wouldn't it be great if the kernel just dumped the ftrace
> log on __stack_chk_fail?)
> 
> any other debugging tricks/ideas?
 

It seems CONFIG_CPUMASK_OFFSTACK (CONFIG_MAXSMP) can change something
around this - did you try?

Jarek P.
