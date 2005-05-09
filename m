From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TG3]: Add tagged status support
Date: Mon, 09 May 2005 15:54:44 -0700 (PDT)
Message-ID: <20050509.155444.74750731.davem@davemloft.net>
References: <1115418431.15156.153.camel@rh4>
	<20050509124832.2a073e11.davem@davemloft.net>
	<1115675082.8570.10.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1115675082.8570.10.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Add tagged status support
Date: Mon, 09 May 2005 14:44:42 -0700

> I found one typo during testing, flags2 should have been flags:
> 
> +		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {

Good catch, fixed.

> I think it will be better to move up this block of code because here we
> are at the point of returning error from tg3_open().

I agree.  Here is the updated version of the patch.

[TG3]: Add tagged status support.

When supported, use the TAGGED interrupt processing support
the chip provides.  In this mode, instead of a "on/off" binary
semaphore, an incrementing tag scheme is used to ACK interrupts.

All MSI supporting chips support TAGGED mode, so the tg3_msi()
interrupt handler uses it unconditionally.  This invariant is
verified when MSI support is tested.

Since we can invoke tg3_poll() multiple times per interrupt under
high packet load, we fetch a new copy of the tag value in the
status block right before we actually do the work.

Also, because the tagged status tells the chip exactly which
work we have processed, we can make two optimizations:

1) tg3_restart_ints() need not check tg3_has_work()
2) the tg3_timer() need not poke the chip 10 times per
   second to keep from losing interrupt events

Based upon valuable feedback from Michael Chan <mchan@broadcom.com>

Signed-off-by: David S. Miller <davem@davemloft.net>

--- 1/drivers/net/tg3.c.~1~	2005-05-09 15:51:29.000000000 -0700
+++ 2/drivers/net/tg3.c	2005-05-09 15:52:32.000000000 -0700
@@ -420,7 +420,8 @@ static void tg3_enable_ints(struct tg3 *
 {
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     (tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
-	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000000);
+	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+		     (tp->last_tag << 24));
 	tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 
 	tg3_cond_int(tp);
@@ -455,10 +456,16 @@ static void tg3_restart_ints(struct tg3 
 {
 	tw32(TG3PCI_MISC_HOST_CTRL,
 		(tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
-	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000000);
+	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+		     tp->last_tag << 24);
 	mmiowb();
 
-	if (tg3_has_work(tp))
+	/* When doing tagged status, this work check is unnecessary.
+	 * The last_tag we write above tells the chip which piece of
+	 * work we've completed.
+	 */
+	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
+	    tg3_has_work(tp))
 		tw32(HOSTCC_MODE, tp->coalesce_mode |
 		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
 }
@@ -2862,6 +2869,9 @@ static int tg3_poll(struct net_device *n
 
 	spin_lock_irqsave(&tp->lock, flags);
 
+	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+		tp->last_tag = sblk->status_tag;
+
 	/* handle link change and other phy events */
 	if (!(tp->tg3_flags &
 	      (TG3_FLAG_USE_LINKCHG_REG |
@@ -2928,22 +2938,21 @@ static irqreturn_t tg3_msi(int irq, void
 	spin_lock_irqsave(&tp->lock, flags);
 
 	/*
-	 * writing any value to intr-mbox-0 clears PCI INTA# and
+	 * Writing any value to intr-mbox-0 clears PCI INTA# and
 	 * chip-internal interrupt pending events.
-	 * writing non-zero to intr-mbox-0 additional tells the
+	 * Writing non-zero to intr-mbox-0 additional tells the
 	 * NIC to stop sending us irqs, engaging "in-intr-handler"
 	 * event coalescing.
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
+	tp->last_tag = sblk->status_tag;
 	sblk->status &= ~SD_STATUS_UPDATED;
-
 	if (likely(tg3_has_work(tp)))
 		netif_rx_schedule(dev);		/* schedule NAPI poll */
 	else {
-		/* no work, re-enable interrupts
-		 */
+		/* No work, re-enable interrupts.  */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     0x00000000);
+			     tp->last_tag << 24);
 	}
 
 	spin_unlock_irqrestore(&tp->lock, flags);
@@ -2969,21 +2978,62 @@ static irqreturn_t tg3_interrupt(int irq
 	if ((sblk->status & SD_STATUS_UPDATED) ||
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
 		/*
-		 * writing any value to intr-mbox-0 clears PCI INTA# and
+		 * Writing any value to intr-mbox-0 clears PCI INTA# and
 		 * chip-internal interrupt pending events.
-		 * writing non-zero to intr-mbox-0 additional tells the
+		 * Writing non-zero to intr-mbox-0 additional tells the
 		 * NIC to stop sending us irqs, engaging "in-intr-handler"
 		 * event coalescing.
 		 */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
+		sblk->status &= ~SD_STATUS_UPDATED;
+		if (likely(tg3_has_work(tp)))
+			netif_rx_schedule(dev);		/* schedule NAPI poll */
+		else {
+			/* No work, shared interrupt perhaps?  re-enable
+			 * interrupts, and flush that PCI write
+			 */
+			tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+			     	0x00000000);
+			tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+		}
+	} else {	/* shared interrupt */
+		handled = 0;
+	}
+
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	return IRQ_RETVAL(handled);
+}
+
+static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *dev = dev_id;
+	struct tg3 *tp = netdev_priv(dev);
+	struct tg3_hw_status *sblk = tp->hw_status;
+	unsigned long flags;
+	unsigned int handled = 1;
+
+	spin_lock_irqsave(&tp->lock, flags);
+
+	/* In INTx mode, it is possible for the interrupt to arrive at
+	 * the CPU before the status block posted prior to the interrupt.
+	 * Reading the PCI State register will confirm whether the
+	 * interrupt is ours and will flush the status block.
+	 */
+	if ((sblk->status & SD_STATUS_UPDATED) ||
+	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_INT_NOT_ACTIVE)) {
 		/*
-		 * Flush PCI write.  This also guarantees that our
-		 * status block has been flushed to host memory.
+		 * writing any value to intr-mbox-0 clears PCI INTA# and
+		 * chip-internal interrupt pending events.
+		 * writing non-zero to intr-mbox-0 additional tells the
+		 * NIC to stop sending us irqs, engaging "in-intr-handler"
+		 * event coalescing.
 		 */
-		tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+			     0x00000001);
+		tp->last_tag = sblk->status_tag;
 		sblk->status &= ~SD_STATUS_UPDATED;
-
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
 		else {
@@ -2991,7 +3041,7 @@ static irqreturn_t tg3_interrupt(int irq
 			 * interrupts, and flush that PCI write
 			 */
 			tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     	0x00000000);
+				     tp->last_tag << 24);
 			tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 		}
 	} else {	/* shared interrupt */
@@ -5445,7 +5495,8 @@ static int tg3_reset_hw(struct tg3 *tp)
 	udelay(100);
 
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0);
-	tr32(MAILBOX_INTERRUPT_0);
+	tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+	tp->last_tag = 0;
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		tw32_f(DMAC_MODE, DMAC_MODE_ENABLE);
@@ -5723,31 +5774,33 @@ static void tg3_timer(unsigned long __op
 	spin_lock_irqsave(&tp->lock, flags);
 	spin_lock(&tp->tx_lock);
 
-	/* All of this garbage is because when using non-tagged
-	 * IRQ status the mailbox/status_block protocol the chip
-	 * uses with the cpu is race prone.
-	 */
-	if (tp->hw_status->status & SD_STATUS_UPDATED) {
-		tw32(GRC_LOCAL_CTRL,
-		     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
-	} else {
-		tw32(HOSTCC_MODE, tp->coalesce_mode |
-		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
-	}
+	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
+		/* All of this garbage is because when using non-tagged
+		 * IRQ status the mailbox/status_block protocol the chip
+		 * uses with the cpu is race prone.
+		 */
+		if (tp->hw_status->status & SD_STATUS_UPDATED) {
+			tw32(GRC_LOCAL_CTRL,
+			     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
+		} else {
+			tw32(HOSTCC_MODE, tp->coalesce_mode |
+			     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
+		}
 
-	if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
-		tp->tg3_flags2 |= TG3_FLG2_RESTART_TIMER;
-		spin_unlock(&tp->tx_lock);
-		spin_unlock_irqrestore(&tp->lock, flags);
-		schedule_work(&tp->reset_task);
-		return;
+		if (!(tr32(WDMAC_MODE) & WDMAC_MODE_ENABLE)) {
+			tp->tg3_flags2 |= TG3_FLG2_RESTART_TIMER;
+			spin_unlock(&tp->tx_lock);
+			spin_unlock_irqrestore(&tp->lock, flags);
+			schedule_work(&tp->reset_task);
+			return;
+		}
 	}
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
-		tg3_periodic_fetch_stats(tp);
-
 	/* This part only runs once per second. */
 	if (!--tp->timer_counter) {
+		if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+			tg3_periodic_fetch_stats(tp);
+
 		if (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) {
 			u32 mac_stat;
 			int phy_event;
@@ -5846,9 +5899,13 @@ static int tg3_test_interrupt(struct tg3
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI)
 		err = request_irq(tp->pdev->irq, tg3_msi,
 				  SA_SAMPLE_RANDOM, dev->name, dev);
-	else
-		err = request_irq(tp->pdev->irq, tg3_interrupt,
+	else {
+		irqreturn_t (*fn)(int, void *, struct pt_regs *)=tg3_interrupt;
+		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+			fn = tg3_interrupt_tagged;
+		err = request_irq(tp->pdev->irq, fn,
 				  SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+	}
 
 	if (err)
 		return err;
@@ -5900,9 +5957,14 @@ static int tg3_test_msi(struct tg3 *tp)
 
 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
 
-	err = request_irq(tp->pdev->irq, tg3_interrupt,
-			  SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+	{
+		irqreturn_t (*fn)(int, void *, struct pt_regs *)=tg3_interrupt;
+		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+			fn = tg3_interrupt_tagged;
 
+		err = request_irq(tp->pdev->irq, fn,
+				  SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+	}
 	if (err)
 		return err;
 
@@ -5948,7 +6010,13 @@ static int tg3_open(struct net_device *d
 	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
 	    (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5750_AX) &&
 	    (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5750_BX)) {
-		if (pci_enable_msi(tp->pdev) == 0) {
+		/* All MSI supporting chips should support tagged
+		 * status.  Assert that this is the case.
+		 */
+		if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)) {
+			printk(KERN_WARNING PFX "%s: MSI without TAGGED? "
+			       "Not using MSI.\n", tp->dev->name);
+		} else if (pci_enable_msi(tp->pdev) == 0) {
 			u32 msi_mode;
 
 			msi_mode = tr32(MSGINT_MODE);
@@ -5959,9 +6027,14 @@ static int tg3_open(struct net_device *d
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI)
 		err = request_irq(tp->pdev->irq, tg3_msi,
 				  SA_SAMPLE_RANDOM, dev->name, dev);
-	else
-		err = request_irq(tp->pdev->irq, tg3_interrupt,
+	else {
+		irqreturn_t (*fn)(int, void *, struct pt_regs *)=tg3_interrupt;
+		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+			fn = tg3_interrupt_tagged;
+
+		err = request_irq(tp->pdev->irq, fn,
 				  SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+	}
 
 	if (err) {
 		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
@@ -5980,9 +6053,16 @@ static int tg3_open(struct net_device *d
 		tg3_halt(tp, 1);
 		tg3_free_rings(tp);
 	} else {
-		tp->timer_offset = HZ / 10;
-		tp->timer_counter = tp->timer_multiplier = 10;
-		tp->asf_counter = tp->asf_multiplier = (10 * 120);
+		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
+			tp->timer_offset = HZ;
+		else
+			tp->timer_offset = HZ / 10;
+
+		BUG_ON(tp->timer_offset > HZ);
+		tp->timer_counter = tp->timer_multiplier =
+			(HZ / tp->timer_offset);
+		tp->asf_counter = tp->asf_multiplier =
+			((HZ / tp->timer_offset) * 120);
 
 		init_timer(&tp->timer);
 		tp->timer.expires = jiffies + tp->timer_offset;
@@ -6005,6 +6085,7 @@ static int tg3_open(struct net_device *d
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		err = tg3_test_msi(tp);
+
 		if (err) {
 			spin_lock_irq(&tp->lock);
 			spin_lock(&tp->tx_lock);
@@ -8422,15 +8503,7 @@ static int __devinit tg3_get_invariants(
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 
-	/* Only 5701 and later support tagged irq status mode.
-	 * Also, 5788 chips cannot use tagged irq status.
-	 *
-	 * However, since we are using NAPI avoid tagged irq status
-	 * because the interrupt condition is more difficult to
-	 * fully clear in that mode.
-	 */
 	tp->coalesce_mode = 0;
-
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_AX &&
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
 		tp->coalesce_mode |= HOSTCC_MODE_32BYTE;
@@ -8494,6 +8567,18 @@ static int __devinit tg3_get_invariants(
 	     grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788M))
 		tp->tg3_flags2 |= TG3_FLG2_IS_5788;
 
+	if (!(tp->tg3_flags2 & TG3_FLG2_IS_5788) &&
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700))
+		tp->tg3_flags |= TG3_FLAG_TAGGED_STATUS;
+	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) {
+		tp->coalesce_mode |= (HOSTCC_MODE_CLRTICK_RXBD |
+				      HOSTCC_MODE_CLRTICK_TXBD);
+
+		tp->misc_host_ctrl |= MISC_HOST_CTRL_TAGGED_STATUS;
+		pci_write_config_dword(tp->pdev, TG3PCI_MISC_HOST_CTRL,
+				       tp->misc_host_ctrl);
+	}
+
 	/* these are limited to 10/100 only */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
 	     (grc_misc_cfg == 0x8000 || grc_misc_cfg == 0x4000)) ||
--- 1/drivers/net/tg3.h.~1~	2005-05-09 15:51:32.000000000 -0700
+++ 2/drivers/net/tg3.h	2005-05-09 15:51:40.000000000 -0700
@@ -2023,6 +2023,7 @@ struct tg3 {
 
 	struct tg3_hw_status		*hw_status;
 	dma_addr_t			status_mapping;
+	u32				last_tag;
 
 	u32				msg_enable;
 
@@ -2068,6 +2069,7 @@ struct tg3 {
 
 	u32				rx_offset;
 	u32				tg3_flags;
+#define TG3_FLAG_TAGGED_STATUS		0x00000001
 #define TG3_FLAG_TXD_MBOX_HWBUG		0x00000002
 #define TG3_FLAG_RX_CHECKSUMS		0x00000004
 #define TG3_FLAG_USE_LINKCHG_REG	0x00000008
