From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH revised 10/11][TG3]: Eliminate spurious interrupts.
Date: Sat, 05 May 2007 17:19:31 -0700
Message-ID: <1178410771.4859.50.camel@dell>
References: <20070504.194207.82054727.davem@davemloft.net>
 <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
 <20070504.204700.24899658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2687 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401AbXEEXcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 May 2007 19:32:13 -0400
In-Reply-To: <20070504.204700.24899658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Eliminate spurious interrupts.

Spurious interrupts are often encountered especially on systems
using the 8259 PIC mode.  This is because the I/O write to deassert
the interrupt is posted and won't get to the chip immediately.  As
a result, the IRQ may remain asserted after the IRQ handler exits,
causing spurious interrupts.

Flush the interrupt mailbox in non-MSI handlers to de-assert the
IRQ immediately.  This seems to be the most straight forward approach
after discussion with Jeff Garzik and David Miller.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index da1ab01..70b8c5e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3590,8 +3590,12 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	 * Writing non-zero to intr-mbox-0 additional tells the
 	 * NIC to stop sending us irqs, engaging "in-intr-handler"
 	 * event coalescing.
+	 *
+	 * Flush the mailbox to de-assert the IRQ immediately to prevent
+	 * spurious interrupts.  The flush impacts performance but
+	 * excessive spurious interrupts can be worse in some cases.
 	 */
-	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
 	sblk->status &= ~SD_STATUS_UPDATED;
@@ -3635,8 +3639,12 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * writing non-zero to intr-mbox-0 additional tells the
 	 * NIC to stop sending us irqs, engaging "in-intr-handler"
 	 * event coalescing.
+	 *
+	 * Flush the mailbox to de-assert the IRQ immediately to prevent
+	 * spurious interrupts.  The flush impacts performance but
+	 * excessive spurious interrupts can be worse in some cases.
 	 */
-	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
 	if (netif_rx_schedule_prep(dev)) {


