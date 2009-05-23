From: David Dillow <dave@thedillows.org>
Subject: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Fri, 22 May 2009 21:29:34 -0400
Message-ID: <1243042174.3580.23.camel@obelisk.thedillows.org>
References: <200903041828.49972.m.bueker@berlin.de>
	 <1242001754.4093.12.camel@obelisk.thedillows.org>
	 <200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
	 <1242077392.3716.15.camel@lap75545.ornl.gov>
	 <4A09DC3E.2080807@googlemail.com>
	 <1242268709.4979.7.camel@obelisk.thedillows.org>
	 <4A0C6504.8000704@googlemail.com>
	 <1242328457.32579.12.camel@lap75545.ornl.gov>
	 <4A0C7443.1010000@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:51808 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228AbZEWB3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 21:29:36 -0400
In-Reply-To: <4A0C7443.1010000@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8169 chip only generates MSI interrupts when all enabled event
sources are quiescent and one or more sources transition to active. If
not all of the active events are acknowledged, or a new event becomes
active while the existing ones are cleared in the handler, we will not
see a new interrupt.

The current interrupt handler masks off the Rx and Tx events once the
NAPI handler has been scheduled, which opens a race window in which we
can get another Rx or Tx event and never ACK'ing it, stopping all
activity until the link is reset (ifconfig down/up). Fix this by always
ACK'ing all event sources, and loop in the handler until we have all
sources quiescent.

Signed-off-by: David Dillow <dave@thedillows.org>
---
This fixes the lockups I've seen. Both MSI and level-triggered interrupt
configurations survive over an hour of testing when it would lockup in
under 90 seconds before. I am certain of the analysis of the root cause,
but there may be better ways to fix it. There may also be a theoretical
race window between the ending of a NAPI poll cycle and a link change
interrupt coming in, but I'm not sure it would matter. 

Some variant of this should also be applied to the currently running
stable trees, as the problem is long-standing.

 r8169.c |  102 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 57 insertions(+), 45 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0b6e8c8..bdc8d5a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3554,54 +3554,64 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
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
+			if (likely(napi_schedule_prep(&tp->napi)))
+				__napi_schedule(&tp->napi);
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
-		if (likely(napi_schedule_prep(&tp->napi)))
-			__napi_schedule(&tp->napi);
-		else if (netif_msg_intr(tp)) {
-			printk(KERN_INFO "%s: interrupt %04x in poll\n",
-			       dev->name, status);
-		}
-	}
-out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -3617,13 +3627,15 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		napi_complete(napi);
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



