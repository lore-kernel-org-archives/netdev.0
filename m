From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Regression: Bisected, IRQ and MSI allocations screwed without
 sparse irq
Date: Fri, 21 Nov 2008 20:35:32 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0811212022520.29808@ask.diku.dk>
References: <1226572171.6834.87.camel@localhost.localdomain>
 <20081113.141513.116537651.davem@davemloft.net>  <Pine.LNX.4.64.0811192333130.30818@ask.diku.dk>
  <20081119.151138.93409143.davem@davemloft.net>  <Pine.LNX.4.64.0811202035590.19962@ask.diku.dk>
  <alpine.LFD.2.00.0811201539360.3197@localhost.localdomain>
 <1227263614.25811.25.camel@localhost.localdomain>
 <alpine.LFD.2.00.0811210838360.3232@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Ingo Molnar <mingo@elte.hu>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:41111 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115AbYKUTfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:35:36 -0500
In-Reply-To: <alpine.LFD.2.00.0811210838360.3232@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008, Thomas Gleixner wrote:

> On Fri, 21 Nov 2008, Jesper Dangaard Brouer wrote:
>>> Can you please try the attached patch ?
>>
>> I have tried the patch and it solved the problem! :-)
>>
>> I'll gladly test other patches from your.  Guess this patch needs to be
>> brushed up before a mainline patch is ready.
>
> Ok, I queue it for mainline. This solves just the number of irqs
> limitation, the rmmod problem still persists, right ?

It solves both the irq limit and the NIU driver unload bug.

We should give it a good description.
I have cooked up a patch with a description below, will you accept that?

Who's tree do you want it to go upsteam via?
(You are listed as one of the X86 maintainers, but Ingo's tree seems more 
up-to-date. My patch below is agains DaveM's tree)

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------

Fixing irq limit and NIU driver unload bug.

Removing the config option HAVE_SPARSE_IRQ (commit
3235e936c0cc3589309280b6f59e5096779adae3) revealed a regression that
limited the number of irqs on the system.

Besides limiting the number of IRQ, this also caused unloading of the
NIU driver to fail during msi_free_irqs(). The reduced number of IRQs
caused the NIU driver to use "IO-APIC" based IRQs instead of
"PCI-MSI-edge".

This patch changes probe_nr_irqs() to return NR_IRQS, which is
basically the same as the NOT CONFIG_X86_IO_APIC case.  Thus being
fairly safe.

Thus, solving both the irq limit and the NIU driver unload bug.

Tested-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
  arch/x86/kernel/io_apic.c |   22 +---------------------
  1 files changed, 1 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kernel/io_apic.c b/arch/x86/kernel/io_apic.c
index c9513e1..1fec0f9 100644
--- a/arch/x86/kernel/io_apic.c
+++ b/arch/x86/kernel/io_apic.c
@@ -3608,27 +3608,7 @@ int __init io_apic_get_redir_entries (int ioapic)

  int __init probe_nr_irqs(void)
  {
-	int idx;
-	int nr = 0;
-#ifndef CONFIG_XEN
-	int nr_min = 32;
-#else
-	int nr_min = NR_IRQS;
-#endif
-
-	for (idx = 0; idx < nr_ioapics; idx++)
-		nr += io_apic_get_redir_entries(idx) + 1;
-
-	/* double it for hotplug and msi and nmi */
-	nr <<= 1;
-
-	/* something wrong ? */
-	if (nr < nr_min)
-		nr = nr_min;
-	if (WARN_ON(nr > NR_IRQS))
-		nr = NR_IRQS;
-
-	return nr;
+	return NR_IRQS;
  }

  /* --------------------------------------------------------------------------
-- 
1.5.4.2

