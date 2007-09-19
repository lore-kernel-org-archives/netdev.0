From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Wed, 19 Sep 2007 15:38:19 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:47108 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbXISOi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 10:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Keep track of disable_irq_nosync() invocations and call enable_irq() the 
right number of times if work has been cancelled that would include them.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Now that the call to flush_work_keventd() (problematic because of 
rtnl_mutex being held) has been replaced by cancel_work_sync() another 
issue has arisen and been left unresolved.  As the MDIO bus cannot be 
accessed from the interrupt context the PHY interrupt handler uses 
disable_irq_nosync() to prevent from looping and schedules some work to be 
done as a softirq, which, apart from handling the state change of the 
originating PHY, is responsible for reenabling the interrupt.  Now if the 
interrupt line is shared by another device and a call to the softirq 
handler has been cancelled, that call to enable_irq() never happens and 
the other device cannot use its interrupt anymore as its stuck disabled.

 I decided to use a counter rather than a flag because there may be more 
than one call to phy_change() cancelled in the queue -- a real one and a 
fake one triggered by free_irq() if DEBUG_SHIRQ is used, if nothing else.  
Therefore because of its nesting property enable_irq() has to be called 
the right number of times to match the number disable_irq_nosync() was 
called and restore the original state.  This DEBUG_SHIRQ feature is also 
the reason why free_irq() has to be called before cancel_work_sync().

 While at it I updated the comment about phy_stop_interrupts() being 
called from `keventd' -- this is no longer relevant as the use of 
cancel_work_sync() makes such an approach unnecessary.  OTOH a similar 
comment referring to flush_scheduled_work() in phy_stop() still applies as 
using cancel_work_sync() there would be dangerous.

 Checked with checkpatch.pl and at the run time (with and without 
DEBUG_SHIRQ).

 Please apply.

  Maciej
 
patch-mips-2.6.23-rc5-20070904-phy-irq-fix-9
diff -up --recursive --new-file linux-mips-2.6.23-rc5-20070904.macro/drivers/net/phy/phy.c linux-mips-2.6.23-rc5-20070904/drivers/net/phy/phy.c
--- linux-mips-2.6.23-rc5-20070904.macro/drivers/net/phy/phy.c	2007-09-16 17:17:20.000000000 +0000
+++ linux-mips-2.6.23-rc5-20070904/drivers/net/phy/phy.c	2007-09-18 14:28:07.000000000 +0000
@@ -7,7 +7,7 @@
  * Author: Andy Fleming
  *
  * Copyright (c) 2004 Freescale Semiconductor, Inc.
- * Copyright (c) 2006  Maciej W. Rozycki
+ * Copyright (c) 2006, 2007  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -35,6 +35,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
+#include <asm/atomic.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
@@ -561,6 +562,7 @@ static irqreturn_t phy_interrupt(int irq
 	 * queue will write the PHY to disable and clear the
 	 * interrupt, and then reenable the irq line. */
 	disable_irq_nosync(irq);
+	atomic_inc(&phydev->irq_disable);
 
 	schedule_work(&phydev->phy_queue);
 
@@ -631,6 +633,7 @@ int phy_start_interrupts(struct phy_devi
 
 	INIT_WORK(&phydev->phy_queue, phy_change);
 
+	atomic_set(&phydev->irq_disable, 0);
 	if (request_irq(phydev->irq, phy_interrupt,
 				IRQF_SHARED,
 				"phy_interrupt",
@@ -661,13 +664,22 @@ int phy_stop_interrupts(struct phy_devic
 	if (err)
 		phy_error(phydev);
 
+	free_irq(phydev->irq, phydev);
+
 	/*
-	 * Finish any pending work; we might have been scheduled to be called
-	 * from keventd ourselves, but cancel_work_sync() handles that.
+	 * Cannot call flush_scheduled_work() here as desired because
+	 * of rtnl_lock(), but we do not really care about what would
+	 * be done, except from enable_irq(), so cancel any work
+	 * possibly pending and take care of the matter below.
 	 */
 	cancel_work_sync(&phydev->phy_queue);
-
-	free_irq(phydev->irq, phydev);
+	/*
+	 * If work indeed has been cancelled, disable_irq() will have
+	 * been left unbalanced from phy_interrupt() and enable_irq()
+	 * has to be called so that other devices on the line work.
+	 */
+	while (atomic_dec_return(&phydev->irq_disable) >= 0)
+		enable_irq(phydev->irq);
 
 	return err;
 }
@@ -694,6 +706,7 @@ static void phy_change(struct work_struc
 		phydev->state = PHY_CHANGELINK;
 	spin_unlock(&phydev->lock);
 
+	atomic_dec(&phydev->irq_disable);
 	enable_irq(phydev->irq);
 
 	/* Reenable interrupts */
@@ -707,6 +720,7 @@ static void phy_change(struct work_struc
 
 irq_enable_err:
 	disable_irq(phydev->irq);
+	atomic_inc(&phydev->irq_disable);
 phy_err:
 	phy_error(phydev);
 }
diff -up --recursive --new-file linux-mips-2.6.23-rc5-20070904.macro/include/linux/phy.h linux-mips-2.6.23-rc5-20070904/include/linux/phy.h
--- linux-mips-2.6.23-rc5-20070904.macro/include/linux/phy.h	2007-07-10 04:56:57.000000000 +0000
+++ linux-mips-2.6.23-rc5-20070904/include/linux/phy.h	2007-09-11 23:05:41.000000000 +0000
@@ -25,6 +25,8 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
+#include <asm/atomic.h>
+
 #define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
 				 SUPPORTED_10baseT_Full | \
 				 SUPPORTED_100baseT_Half | \
@@ -281,6 +283,7 @@ struct phy_device {
 	/* Interrupt and Polling infrastructure */
 	struct work_struct phy_queue;
 	struct timer_list phy_timer;
+	atomic_t irq_disable;
 
 	spinlock_t lock;
 
