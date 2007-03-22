From: Bernhard Walle <bwalle@suse.de>
Subject: [PATCH] Fix crash in tg3 when using irqpoll
Date: Thu, 22 Mar 2007 21:46:35 +0100
Message-ID: <20070322204635.GA27152@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:57167 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934235AbXCVUqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 16:46:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using irqpoll I had a crash when I loaded the tg3 network driver
(on IA64). The stack trace was:

        ia64_leave_kernel
        [tg3]tg3_interrupt_tagged
        note_interrupt
        __do_IRQ
        ia64_handle_irq
        ia64_leave_kernel
        _spin_unlock_irqrestore
        pci_bus_read_config_dword
        pci_restore_state
        [tg3]tg3_chip_reset
        [tg3]tg3_reset_hw
        [tg3]tg3_init_hw
        [tg3]tg3_open
        dev_open
        dev_change_flags
        devinet_ioctl
        inet_ioctl
        sock_ioctl
        do_ioctl
        vfs_ioctl
        sys_ioctl
        ia64_ret_from_syscall
        __kernel_syscall_via_break

Also, I had a MCA that ended up in a read from a PCI address that belongs to the
tg3 driver.

This patch makes sure that even the tr32() instruction in the interrupt handler
is not executed which accesses PCI memory. Accessing PCI memory when
pci_restore_state() is called is a bad idea because that function modifies
the BARs of the PCI device.

I think the problem could also happen when using shared interrupts, not only
irqpoll.


Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 drivers/net/tg3.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

Index: mainline-msi-init/drivers/net/tg3.c
===================================================================
--- mainline-msi-init.orig/drivers/net/tg3.c
+++ mainline-msi-init/drivers/net/tg3.c
@@ -3561,7 +3561,10 @@ static irqreturn_t tg3_interrupt(int irq
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned int handled = 1;
+	unsigned int handled = 0;
+
+	if (tg3_irq_sync(tp))
+		goto out;
 
 	/* In INTx mode, it is possible for the interrupt to arrive at
 	 * the CPU before the status block posted prior to the interrupt.
@@ -3579,8 +3582,6 @@ static irqreturn_t tg3_interrupt(int irq
 		 */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
-		if (tg3_irq_sync(tp))
-			goto out;
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp))) {
 			prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
@@ -3592,8 +3593,7 @@ static irqreturn_t tg3_interrupt(int irq
 			tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     	0x00000000);
 		}
-	} else {	/* shared interrupt */
-		handled = 0;
+		handled = 1;
 	}
 out:
 	return IRQ_RETVAL(handled);
@@ -3604,7 +3604,10 @@ static irqreturn_t tg3_interrupt_tagged(
 	struct net_device *dev = dev_id;
 	struct tg3 *tp = netdev_priv(dev);
 	struct tg3_hw_status *sblk = tp->hw_status;
-	unsigned int handled = 1;
+	unsigned int handled = 0;
+
+	if (tg3_irq_sync(tp))
+		goto out;
 
 	/* In INTx mode, it is possible for the interrupt to arrive at
 	 * the CPU before the status block posted prior to the interrupt.
@@ -3622,8 +3625,6 @@ static irqreturn_t tg3_interrupt_tagged(
 		 */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
-		if (tg3_irq_sync(tp))
-			goto out;
 		if (netif_rx_schedule_prep(dev)) {
 			prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 			/* Update last_tag to mark that this status has been
@@ -3634,8 +3635,7 @@ static irqreturn_t tg3_interrupt_tagged(
 			tp->last_tag = sblk->status_tag;
 			__netif_rx_schedule(dev);
 		}
-	} else {	/* shared interrupt */
-		handled = 0;
+		handled = 1;
 	}
 out:
 	return IRQ_RETVAL(handled);
@@ -7052,7 +7052,7 @@ static int tg3_open(struct net_device *d
 		return err;
 	}
 
-	tg3_full_lock(tp, 0);
+	tg3_full_lock(tp, 1);
 
 	err = tg3_init_hw(tp, 1);
 	if (err) {
