From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 23 May 2009 11:24:28 +0200
Message-ID: <200905231124.28925.mb@bu3sch.de>
References: <200903041828.49972.m.bueker@berlin.de> <4A0C7443.1010000@googlemail.com> <1243042174.3580.23.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:39330 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751697AbZEWJZq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 05:25:46 -0400
In-Reply-To: <1243042174.3580.23.camel@obelisk.thedillows.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 May 2009 03:29:34 David Dillow wrote:
> The 8169 chip only generates MSI interrupts when all enabled event
> sources are quiescent and one or more sources transition to active. If
> not all of the active events are acknowledged, or a new event becomes
> active while the existing ones are cleared in the handler, we will not
> see a new interrupt.
> 
> The current interrupt handler masks off the Rx and Tx events once the
> NAPI handler has been scheduled, which opens a race window in which we
> can get another Rx or Tx event and never ACK'ing it, stopping all
> activity until the link is reset (ifconfig down/up). Fix this by always
> ACK'ing all event sources, and loop in the handler until we have all
> sources quiescent.
> 
> Signed-off-by: David Dillow <dave@thedillows.org>

Thanks a lot, Dave! This fixes the issue on my chip.
You can add my:

Tested-by: Michael Buesch <mb@bu3sch.de>



Here's a patch that cleanly applies to 2.6.29.4:

Index: linux-2.6.29/drivers/net/r8169.c
===================================================================
--- linux-2.6.29.orig/drivers/net/r8169.c	2009-05-23 11:06:22.000000000 +0200
+++ linux-2.6.29/drivers/net/r8169.c	2009-05-23 11:08:17.000000000 +0200
@@ -3554,54 +3554,64 @@
 	int handled = 0;
 	int status;
 
+	/* loop handling interrupts until we have no new ones or
+	 * we hit a invalid/hotplug case.
+	 */
 	status = RTL_R16(IntrStatus);
+	while (status && status != 0xffff) {
+		handled = 1;
 
-	/* hotplug/major error/no more work/shared irq */
-	if ((status == 0xffff) || !status)
-		goto out;
-
-	handled = 1;
+		/* Handle all of the error cases first. These will reset
+		 * the chip, so just exit the loop.
+		 */
+		if (unlikely(!netif_running(dev))) {
+			rtl8169_asic_down(ioaddr);
+			break;
+		}
 
-	if (unlikely(!netif_running(dev))) {
-		rtl8169_asic_down(ioaddr);
-		goto out;
-	}
+		/* Work around for rx fifo overflow */
+		if (unlikely(status & RxFIFOOver) &&
+	    	(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+			netif_stop_queue(dev);
+			rtl8169_tx_timeout(dev);
+			break;
+		}
 
-	status &= tp->intr_mask;
-	RTL_W16(IntrStatus,
-		(status & RxFIFOOver) ? (status | RxOverflow) : status);
+		if (unlikely(status & SYSErr)) {
+			rtl8169_pcierr_interrupt(dev);
+			break;
+		}
 
-	if (!(status & tp->intr_event))
-		goto out;
+		if (status & LinkChg)
+			rtl8169_check_link_status(dev, tp, ioaddr);
 
-	/* Work around for rx fifo overflow */
-	if (unlikely(status & RxFIFOOver) &&
-	    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
-		netif_stop_queue(dev);
-		rtl8169_tx_timeout(dev);
-		goto out;
-	}
+		/* We need to see the lastest version of tp->intr_mask to
+		 * avoid ignoring an MSI interrupt and having to wait for
+		 * another event which may never come.
+		 */
+		smp_rmb();
+		if (status & tp->intr_mask & tp->napi_event) {
+			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+			tp->intr_mask = ~tp->napi_event;
+
+			if (likely(netif_rx_schedule_prep(&tp->napi)))
+				__netif_rx_schedule(&tp->napi);
+			else if (netif_msg_intr(tp)) {
+				printk(KERN_INFO "%s: interrupt %04x in poll\n",
+			       	dev->name, status);
+			}
+		}
 
-	if (unlikely(status & SYSErr)) {
-		rtl8169_pcierr_interrupt(dev);
-		goto out;
+		/* We only get a new MSI interrupt when all active irq
+		 * sources on the chip have been acknowledged. So, ack
+		 * everything we've seen and check if new sources have become
+		 * active to avoid blocking all interrupts from the chip.
+		 */
+		RTL_W16(IntrStatus,
+			(status & RxFIFOOver) ? (status | RxOverflow) : status);
+		status = RTL_R16(IntrStatus);
 	}
 
-	if (status & LinkChg)
-		rtl8169_check_link_status(dev, tp, ioaddr);
-
-	if (status & tp->napi_event) {
-		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-		tp->intr_mask = ~tp->napi_event;
-
-		if (likely(netif_rx_schedule_prep(&tp->napi)))
-			__netif_rx_schedule(&tp->napi);
-		else if (netif_msg_intr(tp)) {
-			printk(KERN_INFO "%s: interrupt %04x in poll\n",
-			       dev->name, status);
-		}
-	}
-out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -3617,13 +3627,15 @@
 
 	if (work_done < budget) {
 		netif_rx_complete(napi);
-		tp->intr_mask = 0xffff;
-		/*
-		 * 20040426: the barrier is not strictly required but the
-		 * behavior of the irq handler could be less predictable
-		 * without it. Btw, the lack of flush for the posted pci
-		 * write is safe - FR
+
+		/* We need for force the visibility of tp->intr_mask
+		 * for other CPUs, as we can loose an MSI interrupt
+		 * and potentially wait for a retransmit timeout if we don't.
+		 * The posted write to IntrMask is safe, as it will
+		 * eventually make it to the chip and we won't loose anything
+		 * until it does.
 		 */
+		tp->intr_mask = 0xffff;
 		smp_wmb();
 		RTL_W16(IntrMask, tp->intr_event);
 	}


-- 
Greetings, Michael.
