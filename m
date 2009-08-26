From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Wed, 26 Aug 2009 00:58:56 -0700
Message-ID: <m1iqgbknun.fsf_-_@fess.ebiederm.org>
References: <1250895567.23419.1.camel@obelisk.thedillows.org>
	<1250897657.23419.5.camel@obelisk.thedillows.org>
	<m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org>
	<1250973787.3582.14.camel@obelisk.thedillows.org>
	<m1r5v0ogvw.fsf@fess.ebiederm.org>
	<1251169150.4023.11.camel@obelisk.thedillows.org>
	<m1prajabk8.fsf@fess.ebiederm.org>
	<1251232848.9607.15.camel@lap75545.ornl.gov>
	<m1k50r8u4p.fsf@fess.ebiederm.org>
	<20090825221903.GA13630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51456 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbZHZH7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 03:59:00 -0400
In-Reply-To: <20090825221903.GA13630@electric-eye.fr.zoreil.com> (Francois Romieu's message of "Wed\, 26 Aug 2009 00\:19\:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As of 2.6.30 I have been observing soft lockups and netdev watchdog
timeouts caused by looping in the r8169 interrupt handler.

- Introduce a hard limit to the maximum number of times we will loop in
  the interrupt handler, and print a message when we hit it.

- Break out of the loop if after looking none of the events in status
  are events we expect to be delivered by an interrupt.

With just the hard limit and message bits of my patch in my test case
I get hit my limit of 10 loops 12 times.  After filtering by intr_mask
and intr_event I don't get any warnings.

Any complaints from those who know the driver better than I?

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/r8169.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3b19e0c..2214945 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -61,6 +61,8 @@ static const int multicast_filter_limit = 32;
 /* MAC address length */
 #define MAC_ADDR_LEN	6
 
+#define MAX_INTR_LOOPS 10	/* Limit the msi acking loop from going crazy */
+
 #define MAX_READ_REQUEST_SHIFT	12
 #define RX_FIFO_THRESH	7	/* 7 means NO threshold, Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
@@ -3552,6 +3554,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	void __iomem *ioaddr = tp->mmio_addr;
 	int handled = 0;
 	int status;
+	int count = 0;
 
 	/* loop handling interrupts until we have no new ones or
 	 * we hit a invalid/hotplug case.
@@ -3560,6 +3563,17 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 	while (status && status != 0xffff) {
 		handled = 1;
 
+		if (count++ >= MAX_INTR_LOOPS) {
+			if (netif_msg_intr(tp) && net_ratelimit()) {
+				printk(KERN_INFO " %s Screaming irq "
+					"status %08x mask %08x event %08x "
+					"napi %08x\n",
+					dev->name, status, tp->intr_mask,
+					tp->intr_event,	tp->napi_event);
+			}
+			break;
+		}
+
 		/* Handle all of the error cases first. These will reset
 		 * the chip, so just exit the loop.
 		 */
@@ -3609,6 +3623,13 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrStatus,
 			(status & RxFIFOOver) ? (status | RxOverflow) : status);
 		status = RTL_R16(IntrStatus);
+
+		/* Ignore the parts of status that reflect more than
+		 * the enabled interrupts.
+		 */
+		smp_rmb();
+		if (!(status & tp->intr_mask & tp->intr_event))
+			break;
 	}
 
 	return IRQ_RETVAL(handled);
-- 
1.6.2.5

