From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 1/5 2.5] e100: Fix e100_watchdog to not accidentally re-enable
 interrupts when setting the software interrupt bit.
Date: Fri, 15 Oct 2004 06:53:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150549450.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.c.new
--- netdev-2.6/drivers/net/e100.c	2004-10-07 13:58:59.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-07 13:59:00.000000000 -0700
@@ -575,13 +575,21 @@ static inline void e100_write_flush(stru
 
 static inline void e100_enable_irq(struct nic *nic)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&nic->cmd_lock, flags);
 	writeb(irq_mask_none, &nic->csr->scb.cmd_hi);
+	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 	e100_write_flush(nic);
 }
 
 static inline void e100_disable_irq(struct nic *nic)
 {
+	unsigned long flags;
+
+	spin_lock_irqsave(&nic->cmd_lock, flags);
 	writeb(irq_mask_all, &nic->csr->scb.cmd_hi);
+	spin_unlock_irqrestore(&nic->cmd_lock, flags);
 	e100_write_flush(nic);
 }
 
@@ -1254,8 +1262,13 @@ static void e100_watchdog(unsigned long 
 	mii_check_link(&nic->mii);
 
 	/* Software generated interrupt to recover from (rare) Rx
-	 * allocation failure */
-	writeb(irq_sw_gen, &nic->csr->scb.cmd_hi);
+	 * allocation failure. 
+	 * Unfortunately have to use a spinlock to not re-enable interrupts 
+	 * accidentally, due to hardware that shares a register between the 
+	 * interrupt mask bit and the SW Interrupt generation bit */
+	spin_lock_irq(&nic->cmd_lock);
+	writeb(readb(&nic->csr->scb.cmd_hi) | irq_sw_gen,&nic->csr->scb.cmd_hi);
+	spin_unlock_irq(&nic->cmd_lock);
 	e100_write_flush(nic);
 
 	e100_update_stats(nic);
