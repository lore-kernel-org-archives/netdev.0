From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after
	random time
Date: Fri, 10 Aug 2007 11:38:39 +0200
Message-ID: <20070810093839.GB19777@elte.hu>
References: <JMJTMH$F1699B57C9B0E170ED337488612E649B@xandmail.com> <20070810083720.GE1764@ff.dom.local> <20070810084841.GA11086@elte.hu> <20070810090318.GG1764@ff.dom.local> <20070810090833.GA15121@elte.hu> <20070810091954.GI1764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	"marcin.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40291 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754628AbXHJJiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:38:52 -0400
Content-Disposition: inline
In-Reply-To: <20070810091954.GI1764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> All correct! There was also checked a possibility it can be not hw 
> itself, but wrong way of handling after hw (acking too late). This was 
> false idea (or bad implementation), so it looks like hw vs lapic 
> problem.

i think the problem is that local APIC 'self vectors' might be 
edge-triggered by default. I'm not exactly sure whether passing in 
APIC_INT_LEVELTRIG to send_IPI_self() will truly be interpreted by the 
local APIC into any external IO-APIC ACK sequence (the local APIC might 
just treat self-vectors as always-edge) - and it might also be that the 
pure act of mixing self-triggered vectors with level-triggered external 
irqs sometimes confuses the IO-APIC <-> local-APIC messaging. One more 
test of the patch below will tell us a bit more about this part of the 
story.

	Ingo

Index: linux/arch/i386/kernel/io_apic.c
===================================================================
--- linux.orig/arch/i386/kernel/io_apic.c
+++ linux/arch/i386/kernel/io_apic.c
@@ -735,7 +735,8 @@ void fastcall send_IPI_self(int vector)
 	 * Wait for idle.
 	 */
 	apic_wait_icr_idle();
-	cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL;
+	cfg = APIC_DM_FIXED | APIC_DEST_SELF | vector | APIC_DEST_LOGICAL |
+		APIC_INT_LEVELTRIG;
 	/*
 	 * Send the IPI. The write to APIC_ICR fires this off.
 	 */
