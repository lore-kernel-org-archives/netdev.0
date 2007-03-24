From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 2/3]: Exit irq handler during chip reset.
Date: Fri, 23 Mar 2007 16:13:07 -0800
Message-ID: <1174695187.4834.9.camel@dell>
References: <20070322204635.GA27152@strauss.suse.de>
 <1174601067.9753.42.camel@dell> <20070322232048.GC3333@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, "Bernhard Walle" <bwalle@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4325 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934333AbXCWX3P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:29:15 -0400
In-Reply-To: <20070322232048.GC3333@sykes.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Exit irq handler during chip reset.

On most tg3 chips, the memory enable bit in the PCI command register
gets cleared during chip reset and must be restored before accessing
PCI registers using memory cycles.  The chip does not generate
interrupt during chip reset, but the irq handler can still be called
because of irq sharing or irqpoll.  Reading a register in the irq
handler can cause a master abort in this scenario and may result in a
crash on some architectures.

Use the TG3_FLAG_CHIP_RESETTING flag to tell the irq handler to exit
without touching any registers.  The checking of the flag is in the
"slow" path of the irq handler and will not affect normal performance.
The msi handler is not shared and therefore does not require checking
the flag.

Thanks to Bernhard Walle <bwalle@suse.de> for reporting the problem.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ab87bb1..9aca100 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3568,32 +3568,34 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	 * Reading the PCI State register will confirm whether the
 	 * interrupt is ours and will flush the status block.
 	 */
-	if ((sblk->status & SD_STATUS_UPDATED) ||
-	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
-		/*
-		 * Writing any value to intr-mbox-0 clears PCI INTA# and
-		 * chip-internal interrupt pending events.
-		 * Writing non-zero to intr-mbox-0 additional tells the
-		 * NIC to stop sending us irqs, engaging "in-intr-handler"
-		 * event coalescing.
-		 */
-		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     0x00000001);
-		if (tg3_irq_sync(tp))
+	if (unlikely(!(sblk->status & SD_STATUS_UPDATED))) {
+		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
+		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
+			handled = 0;
 			goto out;
-		sblk->status &= ~SD_STATUS_UPDATED;
-		if (likely(tg3_has_work(tp))) {
-			prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-			netif_rx_schedule(dev);		/* schedule NAPI poll */
-		} else {
-			/* No work, shared interrupt perhaps?  re-enable
-			 * interrupts, and flush that PCI write
-			 */
-			tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     	0x00000000);
 		}
-	} else {	/* shared interrupt */
-		handled = 0;
+	}
+
+	/*
+	 * Writing any value to intr-mbox-0 clears PCI INTA# and
+	 * chip-internal interrupt pending events.
+	 * Writing non-zero to intr-mbox-0 additional tells the
+	 * NIC to stop sending us irqs, engaging "in-intr-handler"
+	 * event coalescing.
+	 */
+	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	if (tg3_irq_sync(tp))
+		goto out;
+	sblk->status &= ~SD_STATUS_UPDATED;
+	if (likely(tg3_has_work(tp))) {
+		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+		netif_rx_schedule(dev);		/* schedule NAPI poll */
+	} else {
+		/* No work, shared interrupt perhaps?  re-enable
+		 * interrupts, and flush that PCI write
+		 */
+		tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+		     	0x00000000);
 	}
 out:
 	return IRQ_RETVAL(handled);
@@ -3611,31 +3613,33 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	 * Reading the PCI State register will confirm whether the
 	 * interrupt is ours and will flush the status block.
 	 */
-	if ((sblk->status_tag != tp->last_tag) ||
-	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
-		/*
-		 * writing any value to intr-mbox-0 clears PCI INTA# and
-		 * chip-internal interrupt pending events.
-		 * writing non-zero to intr-mbox-0 additional tells the
-		 * NIC to stop sending us irqs, engaging "in-intr-handler"
-		 * event coalescing.
-		 */
-		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     0x00000001);
-		if (tg3_irq_sync(tp))
+	if (unlikely(sblk->status_tag == tp->last_tag)) {
+		if ((tp->tg3_flags & TG3_FLAG_CHIP_RESETTING) ||
+		    (tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
+			handled = 0;
 			goto out;
-		if (netif_rx_schedule_prep(dev)) {
-			prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-			/* Update last_tag to mark that this status has been
-			 * seen. Because interrupt may be shared, we may be
-			 * racing with tg3_poll(), so only update last_tag
-			 * if tg3_poll() is not scheduled.
-			 */
-			tp->last_tag = sblk->status_tag;
-			__netif_rx_schedule(dev);
 		}
-	} else {	/* shared interrupt */
-		handled = 0;
+	}
+
+	/*
+	 * writing any value to intr-mbox-0 clears PCI INTA# and
+	 * chip-internal interrupt pending events.
+	 * writing non-zero to intr-mbox-0 additional tells the
+	 * NIC to stop sending us irqs, engaging "in-intr-handler"
+	 * event coalescing.
+	 */
+	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	if (tg3_irq_sync(tp))
+		goto out;
+	if (netif_rx_schedule_prep(dev)) {
+		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
+		/* Update last_tag to mark that this status has been
+		 * seen. Because interrupt may be shared, we may be
+		 * racing with tg3_poll(), so only update last_tag
+		 * if tg3_poll() is not scheduled.
+		 */
+		tp->last_tag = sblk->status_tag;
+		__netif_rx_schedule(dev);
 	}
 out:
 	return IRQ_RETVAL(handled);
@@ -4823,6 +4827,19 @@ static int tg3_chip_reset(struct tg3 *tp)
 	if (write_op == tg3_write_flush_reg32)
 		tp->write32 = tg3_write32;
 
+	/* Prevent the irq handler from reading or writing PCI registers
+	 * during chip reset when the memory enable bit in the PCI command
+	 * register may be cleared.  The chip does not generate interrupt
+	 * at this time, but the irq handler may still be called due to irq
+	 * sharing or irqpoll.
+	 */
+	tp->tg3_flags |= TG3_FLAG_CHIP_RESETTING;
+	tp->hw_status->status = 0;
+	tp->hw_status->status_tag = 0;
+	tp->last_tag = 0;
+	smp_mb();
+	synchronize_irq(tp->pdev->irq);
+
 	/* do the reset */
 	val = GRC_MISC_CFG_CORECLK_RESET;
 
@@ -4904,6 +4921,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	pci_restore_state(tp->pdev);
 
+	tp->tg3_flags &= ~TG3_FLAG_CHIP_RESETTING;
+
 	/* Make sure PCI-X relaxed ordering bit is clear. */
 	pci_read_config_dword(tp->pdev, TG3PCI_X_CAPS, &val);
 	val &= ~PCIX_CAPS_RELAXED_ORDERING;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5df8f76..d515ed2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2223,6 +2223,7 @@ struct tg3 {
 #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
 #define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
 #define TG3_FLAG_GOT_SERDES_FLOWCTL	0x20000000
+#define TG3_FLAG_CHIP_RESETTING		0x40000000
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;
 #define TG3_FLG2_RESTART_TIMER		0x00000001


