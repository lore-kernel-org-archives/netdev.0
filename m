From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH 1/2 2.6] e100: fix NAPI race with watchdog
Date: Wed, 22 Sep 2004 12:25:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409221217010.7544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While polling in NAPI mode, we were occassionally getting interrupts 
re-enabled by the watchdog trying to generate a software interrupt.  Fix 
is to add a spinlock around that shared hardware register to allow a 
read-modify-write operation.  This was nasty nasty.  I don't like the 
spinlock in the hot path but i see no other way.  Comments are welcome.
Updates the driver version as well.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

--- netdev-2.6/drivers/net/e100.c	2004-09-21 13:54:33.000000000 -0700
+++ /home/jbrandeb/netdev-2.6/drivers/net/e100.c.watchdog.patch	2004-09-22 11:49:05.000000000 -0700
@@ -155,7 +155,7 @@
 
 #define DRV_NAME		"e100"
 #define DRV_EXT		"-NAPI"
-#define DRV_VERSION		"3.1.4"DRV_EXT
+#define DRV_VERSION		"3.1.4-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
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
+	* allocation failure.
+	* Unfortunately have to use a spinlock to not re-enable interrupts
+	* accidentally, due to hardware that shares a register between the
+	* interrupt mask bit and the SW Interrupt generation bit */
+	spin_lock_irq(&nic->cmd_lock);
+	writeb(readb(&nic->csr->scb.cmd_hi) | irq_sw_gen,&nic->csr->scb.cmd_hi);
+	spin_unlock_irq(&nic->cmd_lock);
 	e100_write_flush(nic);
 
 	e100_update_stats(nic);
