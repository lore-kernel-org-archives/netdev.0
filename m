From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Regression: Bisected, IRQ and MSI allocations screwed without
 sparse irq
Date: Thu, 20 Nov 2008 16:34:29 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0811201539360.3197@localhost.localdomain>
References: <1226572171.6834.87.camel@localhost.localdomain> <20081113.141513.116537651.davem@davemloft.net> <Pine.LNX.4.64.0811192333130.30818@ask.diku.dk> <20081119.151138.93409143.davem@davemloft.net> <Pine.LNX.4.64.0811202035590.19962@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:32768 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634AbYKUAex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 19:34:53 -0500
In-Reply-To: <Pine.LNX.4.64.0811202035590.19962@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper,

On Thu, 20 Nov 2008, Jesper Dangaard Brouer wrote:
> I have bisected a regression to your commit
> 3235e936c0cc3589309280b6f59e5096779adae3,
> "x86: remove sparse irq from Kconfig".
> 
> Its actually not necessary your fault, as your commit simply removes
> the config option HAVE_SPARSE_IRQ.  This revels the bug / regression
> I'm exposted to.

Yup, the bisect result is pretty useless.
 
> The cause of this problem (tracked down together with Robert Olsson)
> is that on 2.6.28 I have a lot less IRQs available.  It seems max 34
> IRQs.  Due the reduced number of IRQs the NIU driver cannot get
> enough IRQs to the interfaces, and starts to use "IO-APIC" based
> IRQs.

Can you please try the attached patch ?

Thanks,

	tglx

-----
 arch/x86/kernel/io_apic.c |   22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

Index: linux-2.6/arch/x86/kernel/io_apic.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/io_apic.c
+++ linux-2.6/arch/x86/kernel/io_apic.c
@@ -3594,27 +3594,7 @@ int __init io_apic_get_redir_entries (in
 
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
