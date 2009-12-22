From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: Kernel Panics in the network stack
Date: Tue, 22 Dec 2009 11:48:53 +0000
Message-ID: <1261482533.29570.31.camel@pc1117.cambridge.arm.com>
References: <20091222112505.GA11410@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Kevin Constantine <kevin.constantine@gmail.com>,
	netdev@vger.kernel.org,
	linux kernel <linux-kernel@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:35013 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbZLVLtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 06:49:01 -0500
In-Reply-To: <20091222112505.GA11410@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-22 at 11:25 +0000, Russell King - ARM Linux wrote:
> On Tue, Dec 22, 2009 at 11:08:25AM +0000, Catalin Marinas wrote:
> > On Tue, 2009-12-22 at 10:09 +0000, Eric Dumazet wrote:
> > > I found an old commit mentioning a problem with LDM instruction that
> > > could be interrupted/ restarted with a base register already changed
> > > -> we load registers with garbage.
> > [...]
> > > If the low interrupt latency mode is enabled for the CPU (from ARMv6
> > > onwards), the ldm/stm instructions are no longer atomic. An ldm instruction
> > > restoring the sp and pc registers can be interrupted immediately after sp
> > > was updated but before the pc. If this happens, the CPU restores the base
> > > register to the value before the ldm instruction but if the base register
> > > is not sp, the interrupt routine will corrupt the stack and the restarted
> > > ldm instruction will load garbage.
> > [...]
> > > I found one instance of LDM instruction in 2.6.30 that could have same problem :
> > >
> > > __switch_to:
> > >
> > > ...
> > >         ldm r4, {r4, r5, r6, r7, r8, r9, sl, fp, sp, pc}
> >
> > It looks to me like it is possible to get an interrupt after SP was
> > loaded but before PC, the stack could be corrupted and PC would be
> > loaded with garbage. One instance of your oops messages looks like PC
> > corruption but the other may be caused by something else. What ARM CPU
> > are you using?
> >
> > I'm cc'ing Russell as well, it's strange that we haven't got any issue
> > with this so far.
> 
> We don't see the issue because we explicitly disable low latency
> interrupt mode.

I think there are some processors where this is always on (but I think
the no-MMU ones).

But looking at this again, I don't think it actually matters since R4
doesn't point to the current stack but to the cpu_context in
thread_info. Even if interrupt occurs after SP was loaded and before PC,
it doesn't corrupt the thread_info structure and what the LDM re-reads.
> 
> > You could try #undef'ing __ARCH_WANT_INTERRUPTS_ON_CTXSW in
> > arch/arm/include/asm/system.h as a sanity check for your aborts.
> 
> Unfortunately, we can't do that for older ARM architectures without
> severely impacting the interrupt latency there.  Not only that, but
> the interrupt latency will be increased during any context switch.

I didn't say we should have this all the time, just as a check for
Eric's problem. But I don't think it's even needed.

-- 
Catalin

