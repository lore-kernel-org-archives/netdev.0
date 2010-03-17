From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 18 Mar 2010 00:55:05 +0100
Message-ID: <20100317235505.GA6674@electric-eye.fr.zoreil.com>
References: <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
 <20100317072539.GA3579@swordfish>
 <1268811437.2932.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 16.239.115-78.rev.gaoland.net ([78.115.239.16]:56068 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751294Ab0CRAGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 20:06:09 -0400
Content-Disposition: inline
In-Reply-To: <1268811437.2932.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 17, 2010 at 08:37:17AM +0100, Eric Dumazet wrote:
[...]
> I suspect lot of work is needed on this driver to make it working, but I
> dont have a machine with said adapter.

This one should help too if Sergey owns a (MSI) 8168.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dfc3573..721e7f3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4532,21 +4532,39 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
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
@@ -4557,7 +4575,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 
 		/* Work around for rx fifo overflow */
 		if (unlikely(status & RxFIFOOver) &&
-		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		    (tp->mac_version == RTL_GIGA_MAC_VER_11)) {
 			netif_stop_queue(dev);
 			rtl8169_tx_timeout(dev);
 			break;
@@ -4571,30 +4589,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
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
-			else
-				netif_info(tp, intr, dev,
-					   "interrupt %04x in poll\n", status);
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
@@ -4607,22 +4604,19 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
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
