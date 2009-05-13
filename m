From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 16:17:08 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0905131612180.3561@localhost.localdomain>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com> <20090508.234815.127227651.davem@davemloft.net> <4A086DB2.8040703@nortel.com> <20090511.162436.193717082.davem@davemloft.net> <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>
 <4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org> <4A0AC9EC.6070908@nortel.com> <20090513141532.GT19296@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Friesen <cfriesen@nortel.com>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:35217 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752246AbZEMOSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 10:18:33 -0400
In-Reply-To: <20090513141532.GT19296@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 May 2009, Andi Kleen wrote:

> > "If a soft irq is raised in process context, raise_softirq() in
> > kernel/softirq.c calls wakeup_softirqd() to make sure that ksoftirqd
> 
> softirqd is only used when the softirq runs for too long or when
> there are no suitable irq exits for a long time.
> 
> In normal situations (not excessive time in softirq) they don't
> do anything. 

Err, no. Chris is completely correct:

        if (!in_interrupt())
		wakeup_softirqd();

We can not rely on irqs coming in when the softirq is raised from
thread context. An irq_exit might be faster to process it than the
scheduler can schedule ksoftirqd in, but ksoftirqd is woken and runs
nevertheless. If it finds a softirq pending then it processes them in
it's context and irq_exit calls to softirq are returning right away.

Thanks,

	tglx
