From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Fri, 28 Aug 2009 01:20:24 +0200
Message-ID: <20090827232024.GA30119@electric-eye.fr.zoreil.com>
References: <m1k50r8u4p.fsf@fess.ebiederm.org> <20090825221903.GA13630@electric-eye.fr.zoreil.com> <m1iqgbknun.fsf_-_@fess.ebiederm.org> <1251294974.14241.9.camel@obelisk.thedillows.org> <1251295175.14241.11.camel@obelisk.thedillows.org> <m11vmy737x.fsf@fess.ebiederm.org> <20090826213024.GA20428@electric-eye.fr.zoreil.com> <m1hbvu45jq.fsf@fess.ebiederm.org> <20090827052423.GA1709@electric-eye.fr.zoreil.com> <m1ocq1ke9u.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47023 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750770AbZH0XQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 19:16:20 -0400
Content-Disposition: inline
In-Reply-To: <m1ocq1ke9u.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> :
[...]
> Sounds good.

Gah, I was not able to test it with a decent packet load. Patch below against
the current tree:

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b82780d..6596ef6 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3549,21 +3549,39 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	return count;
 }
 
+static void rtl_napi_cond_schedule(struct rtl8169_private *tp, u16 status)
+{
+	if (status & tp->napi_event) {
+		void __iomem *ioaddr = tp->mmio_addr;
+
+		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+		mmiowb();
+		napi_schedule(&tp->napi);
+	}
+}
+
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	int handled = 0;
-	int status;
+	u16 status;
 
 	/* loop handling interrupts until we have no new ones or
 	 * we hit a invalid/hotplug case.
 	 */
 	status = RTL_R16(IntrStatus);
 	while (status && status != 0xffff) {
+		u16 acked;
+
 		handled = 1;
 
+		acked = (status & RxFIFOOver) ? (status | RxOverflow) : status;
+		acked &= ~tp->napi_event;
+
+		RTL_W16(IntrStatus, acked);
+
 		/* Handle all of the error cases first. These will reset
 		 * the chip, so just exit the loop.
 		 */
@@ -3574,7 +3592,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 
 		/* Work around for rx fifo overflow */
 		if (unlikely(status & RxFIFOOver) &&
-		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
 			netif_stop_queue(dev);
 			rtl8169_tx_timeout(dev);
 			break;
@@ -3588,31 +3606,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		if (status & LinkChg)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 
-		/* We need to see the lastest version of tp->intr_mask to
-		 * avoid ignoring an MSI interrupt and having to wait for
-		 * another event which may never come.
-		 */
-		smp_rmb();
-		if (status & tp->intr_mask & tp->napi_event) {
-			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-			tp->intr_mask = ~tp->napi_event;
-
-			if (likely(napi_schedule_prep(&tp->napi)))
-				__napi_schedule(&tp->napi);
-			else if (netif_msg_intr(tp)) {
-				printk(KERN_INFO "%s: interrupt %04x in poll\n",
-				dev->name, status);
-			}
-		}
+		rtl_napi_cond_schedule(tp, status);
 
-		/* We only get a new MSI interrupt when all active irq
-		 * sources on the chip have been acknowledged. So, ack
-		 * everything we've seen and check if new sources have become
-		 * active to avoid blocking all interrupts from the chip.
-		 */
-		RTL_W16(IntrStatus,
-			(status & RxFIFOOver) ? (status | RxOverflow) : status);
-		status = RTL_R16(IntrStatus);
+		break;
 	}
 
 	return IRQ_RETVAL(handled);
@@ -3625,22 +3621,19 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	void __iomem *ioaddr = tp->mmio_addr;
 	int work_done;
 
+
+	RTL_W16(IntrStatus, tp->napi_event);
+
 	work_done = rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
 
 	if (work_done < budget) {
 		napi_complete(napi);
 
-		/* We need for force the visibility of tp->intr_mask
-		 * for other CPUs, as we can loose an MSI interrupt
-		 * and potentially wait for a retransmit timeout if we don't.
-		 * The posted write to IntrMask is safe, as it will
-		 * eventually make it to the chip and we won't loose anything
-		 * until it does.
-		 */
-		tp->intr_mask = 0xffff;
-		smp_wmb();
 		RTL_W16(IntrMask, tp->intr_event);
+		mmiowb();
+
+		rtl_napi_cond_schedule(tp, RTL_R16(IntrStatus));
 	}
 
 	return work_done;

-- 
Ueimor
