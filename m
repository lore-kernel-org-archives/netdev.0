From: Tejun Heo <tj@kernel.org>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Mon, 12 Oct 2009 16:52:58 +0900
Message-ID: <4AD2E05A.6060700@kernel.org>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com>	 <200909120623.49764.elendil@planet.nl> <4AAE0F7B.5050203@kernel.org>	 <4AAE105E.1080005@kernel.org> <4807377b0910091724k2a332e90i9941971f6032663c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Frans Pop <elendil@planet.nl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, hpa@zytor.com
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:52235 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbZJLHx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 03:53:56 -0400
In-Reply-To: <4807377b0910091724k2a332e90i9941971f6032663c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Brandeburg wrote:
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

Hmm... stackprotector adds considerable amount of stack usage and it
could be you're seeing stack overflow which would also explain the
random crashes you've been seeing.  Do you have DEBUG_STACKOVERFLOW
turned on?  This is on x86_64, right?

-- 
tejun
