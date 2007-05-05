From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Fri, 04 May 2007 17:55:21 -0700
Message-ID: <1178326521.4859.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4066 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422996AbXEEAIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:08:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Reduce spurious interrupts.

Spurious interrupts are often encountered especially on systems
using the 8259 PIC mode.  This is because the I/O write to deassert
the interrupt is posted and won't get to the chip immediately.  As
a result, the IRQ may remain asserted after the IRQ handler exits,
causing spurious interrupts.

An unconditional read to flush the I/O write to force the IRQ to de-
assert immediately is not desirable because it impacts performance in
the fast path.  So we only do this after we have some indications of
spurious interrupts.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b3681e4..c264eb0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3608,12 +3608,31 @@ out:
 	return IRQ_RETVAL(handled);
 }
 
+static void tg3_check_spurious_int(struct tg3 *tp)
+{
+	if (tp->spurious_int_mode)
+		return;
+
+	/* Interrupt mailbox and status block have been flushed at this
+	 * point.  If the tag is unchanged, we are either getting a spurious
+	 * interrupt or sharing interrupt with another device.
+	 */
+	if (tp->hw_status->status_tag == tp->last_tag) {
+		tp->spurious_int++;
+		if (tp->spurious_int > 500)
+			/* Assume we're getting too many spurious interrupts.
+			 * Setting the flag will cause the IRQ handler to
+			 * do a read back to immediately deassert the IRQ.
+			 */
+			tp->spurious_int_mode = 1;
+	}
+}
+
 static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned int handled = 1;
 
 	/* In INTx mode, it is possible for the interrupt to arrive at
 	 * the CPU before the status block posted prior to the interrupt.
@@ -3621,11 +3640,15 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * interrupt is ours and will flush the status block.
 	 */
 	if (unlikely(sblk->status_tag == tp->last_tag)) {
-		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
-		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
-			handled = 0;
-			goto out;
-		}
+		u32 inta;
+
+		if (tp->tg3_flags & TG3_FLAG_CHIP_RESETTING)
+			return IRQ_NONE;
+
+		inta = tr32(TG3PCI_PCISTATE);
+		tg3_check_spurious_int(tp);
+		if (inta & PCISTATE_INT_NOT_ACTIVE)
+			return IRQ_NONE;
 	}
 
 	/*
@@ -3636,6 +3659,8 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * event coalescing.
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	if (unlikely(tp->spurious_int_mode))
+		tr32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 	if (tg3_irq_sync(tp))
 		goto out;
 	if (netif_rx_schedule_prep(dev)) {
@@ -3649,7 +3674,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 		__netif_rx_schedule(dev);
 	}
 out:
-	return IRQ_RETVAL(handled);
+	return IRQ_HANDLED;
 }
 
 /* ISR for interrupt test */
@@ -6886,6 +6911,8 @@ static int tg3_request_irq(struct tg3 *tp)
 	unsigned long flags;
 	struct net_device *dev = tp->dev;
 
+	tp->spurious_int = 0;
+	tp->spurious_int_mode = 0;
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		fn = tg3_msi;
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d88a859..7413643 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2151,6 +2151,9 @@ struct tg3 {
 	dma_addr_t			status_mapping;
 	u32				last_tag;
 
+	u16				spurious_int;
+	u16				spurious_int_mode;
+
 	u32				msg_enable;
 
 	/* begin "tx thread" cacheline section */


