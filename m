From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] tg3 intr masking update
Date: Sat, 21 Dec 2002 15:31:58 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E04CFBE.2060909@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000409090806070708070106"
Cc: Manish Lachwani <manish@Zambeel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000409090806070708070106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a better patch, after I mulled it over on the trip to Atlanta.

It is based on the premise, derived from the chip documentation, that

1) intr-mbox-0 register usage is used to indicate to the NIC that the 
driver is "in interrupt handler".
2) (intr-mbox-0 = 1) == pci-inta-mask + pci-inta-clear + stuff
3) the docs seem to be saying "just use intr-mbox-0 and ignore 
pci-inta-mask"

Based on these three observations, the attached patch updates tg3 for 
the following changes:

1) Mask ints in tg3_interrupt and unmask in tg3_poll.   We not only 
eliminate several MMIO writes/reads, but we also eliminate all usage of 
functions tg3_[un]mask_ints(), which bit-bangs the 
MISC_HOST_CTRL_MASK_PCI_INT bit in the TG3PCI_MISC_HOST_CTRL register.

2) If tg3_main_interrupt_work() returns no-work-exists, we [obviously 
must] unmask ints in tg3_interrupt.  But this is an unlikely case.

3) Simply call netif_rx_schedule(dev) in tg3_interrupt_main_work(). 
This was a change previously discussed.  Eliminates the "poll already 
scheduled" message which was often actually a bogus message.

4) Because of #2, tg3_interrupt_main_work returns boolean 'work_exists' now.

5) There are some Bugzilla bug reports for tg3 1.2, where NMI watchdog 
triggers in tg3_timer.  I did s/spin_lock_irq/spin_lock_irqsave/ in 
tg3_poll for safety, because we might be locking against a timer not 
only an interrupt handler.  And just for general paranoia and safety as 
an "obviously more safe" change.

Comments/feedback/corrections/flames requested :)

--------------000409090806070708070106
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/tg3.c 1.40 vs edited =====
--- 1.40/drivers/net/tg3.c	Mon Dec  9 21:32:02 2002
+++ edited/drivers/net/tg3.c	Sat Dec 21 15:06:34 2002
@@ -217,22 +217,6 @@
 	tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 }
 
-static inline void tg3_mask_ints(struct tg3 *tp)
-{
-	tw32(TG3PCI_MISC_HOST_CTRL,
-	     (tp->misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT));
-}
-
-static inline void tg3_unmask_ints(struct tg3 *tp)
-{
-	tw32(TG3PCI_MISC_HOST_CTRL,
-	     (tp->misc_host_ctrl & ~MISC_HOST_CTRL_MASK_PCI_INT));
-	if (tp->hw_status->status & SD_STATUS_UPDATED) {
-		tw32(GRC_LOCAL_CTRL,
-		     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
-	}
-}
-
 static void tg3_switch_clocks(struct tg3 *tp)
 {
 	if (tr32(TG3PCI_CLOCK_CTRL) & CLOCK_CTRL_44MHZ_CORE) {
@@ -2014,8 +1998,9 @@
 	struct tg3 *tp = netdev->priv;
 	struct tg3_hw_status *sblk = tp->hw_status;
 	int done;
+	unsigned long flags;
 
-	spin_lock_irq(&tp->lock);
+	spin_lock_irqsave(&tp->lock, flags);
 
 	if (!(tp->tg3_flags &
 	      (TG3_FLAG_USE_LINKCHG_REG |
@@ -2052,15 +2037,18 @@
 
 	if (done) {
 		netif_rx_complete(netdev);
-		tg3_unmask_ints(tp);
+		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+		     	     0x00000000);
+		/* don't care about flushing this write immediately */
 	}
 
-	spin_unlock_irq(&tp->lock);
+	spin_unlock_irqrestore(&tp->lock, flags);
 
 	return (done ? 0 : 1);
 }
 
-static __inline__ void tg3_interrupt_main_work(struct net_device *dev, struct tg3 *tp)
+static inline unsigned int tg3_interrupt_main_work(struct net_device *dev,
+					   	   struct tg3 *tp)
 {
 	struct tg3_hw_status *sblk = tp->hw_status;
 	int work_exists = 0;
@@ -2075,19 +2063,10 @@
 	    sblk->idx[0].rx_producer != tp->rx_rcb_ptr)
 		work_exists = 1;
 
-	if (!work_exists)
-		return;
+	if (work_exists)
+		netif_rx_schedule(dev);
 
-	if (netif_rx_schedule_prep(dev)) {
-		/* NOTE: These writes are posted by the readback of
-		 *       the mailbox register done by our caller.
-		 */
-		tg3_mask_ints(tp);
-		__netif_rx_schedule(dev);
-	} else {
-		printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
-		       dev->name);
-	}
+	return work_exists;
 }
 
 static void tg3_interrupt(int irq, void *dev_id, struct pt_regs *regs)
@@ -2102,13 +2081,16 @@
 	if (sblk->status & SD_STATUS_UPDATED) {
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
+		/* flush the intr clear-and-mask before updating status block */
+		tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 		sblk->status &= ~SD_STATUS_UPDATED;
 
-		tg3_interrupt_main_work(dev, tp);
-
-		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
-			     0x00000000);
-		tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+		if (!tg3_interrupt_main_work(dev, tp)) {
+			/* if work doesn't exist... */
+			tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
+			     	     0x00000000);
+			tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
+		}
 	}
 
 	spin_unlock_irqrestore(&tp->lock, flags);

--------------000409090806070708070106--
