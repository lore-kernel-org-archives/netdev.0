From: akpm@linux-foundation.org
Subject: [patch 10/13] PHYLIB: IRQ event workqueue handling fixes
Date: Tue, 02 Oct 2007 14:11:42 -0700
Message-ID: <200710022111.l92LBg8w022504@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	macro@linux-mips.org, afleming@freescale.com, jgarzik@pobox.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49455 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753000AbXJBVOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:14:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Maciej W. Rozycki" <macro@linux-mips.org>

Keep track of disable_irq_nosync() invocations and call enable_irq() the
right number of times if work has been cancelled that would include them.

Now that the call to flush_work_keventd() (problematic because of
rtnl_mutex being held) has been replaced by cancel_work_sync() another
issue has arisen and been left unresolved.  As the MDIO bus cannot be
accessed from the interrupt context the PHY interrupt handler uses
disable_irq_nosync() to prevent from looping and schedules some work to be
done as a softirq, which, apart from handling the state change of the
originating PHY, is responsible for reenabling the interrupt.  Now if the
interrupt line is shared by another device and a call to the softirq
handler has been cancelled, that call to enable_irq() never happens and the
other device cannot use its interrupt anymore as its stuck disabled.

I decided to use a counter rather than a flag because there may be more
than one call to phy_change() cancelled in the queue -- a real one and a
fake one triggered by free_irq() if DEBUG_SHIRQ is used, if nothing else. 
Therefore because of its nesting property enable_irq() has to be called the
right number of times to match the number disable_irq_nosync() was called
and restore the original state.  This DEBUG_SHIRQ feature is also the
reason why free_irq() has to be called before cancel_work_sync().

While at it I updated the comment about phy_stop_interrupts() being called
from `keventd' -- this is no longer relevant as the use of
cancel_work_sync() makes such an approach unnecessary.  OTOH a similar
comment referring to flush_scheduled_work() in phy_stop() still applies as
using cancel_work_sync() there would be dangerous.

Checked with checkpatch.pl and at the run time (with and without
DEBUG_SHIRQ).

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
Cc: Andy Fleming <afleming@freescale.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/phy/phy.c |   24 +++++++++++++++++++-----
 include/linux/phy.h   |    3 +++
 2 files changed, 22 insertions(+), 5 deletions(-)

diff -puN drivers/net/phy/phy.c~phylib-irq-event-workqueue-handling-fixes drivers/net/phy/phy.c
--- a/drivers/net/phy/phy.c~phylib-irq-event-workqueue-handling-fixes
+++ a/drivers/net/phy/phy.c
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
@@ -562,6 +563,7 @@ static irqreturn_t phy_interrupt(int irq
 	 * queue will write the PHY to disable and clear the
 	 * interrupt, and then reenable the irq line. */
 	disable_irq_nosync(irq);
+	atomic_inc(&phydev->irq_disable);
 
 	schedule_work(&phydev->phy_queue);
 
@@ -632,6 +634,7 @@ int phy_start_interrupts(struct phy_devi
 
 	INIT_WORK(&phydev->phy_queue, phy_change);
 
+	atomic_set(&phydev->irq_disable, 0);
 	if (request_irq(phydev->irq, phy_interrupt,
 				IRQF_SHARED,
 				"phy_interrupt",
@@ -662,13 +665,22 @@ int phy_stop_interrupts(struct phy_devic
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
@@ -695,6 +707,7 @@ static void phy_change(struct work_struc
 		phydev->state = PHY_CHANGELINK;
 	spin_unlock_bh(&phydev->lock);
 
+	atomic_dec(&phydev->irq_disable);
 	enable_irq(phydev->irq);
 
 	/* Reenable interrupts */
@@ -708,6 +721,7 @@ static void phy_change(struct work_struc
 
 irq_enable_err:
 	disable_irq(phydev->irq);
+	atomic_inc(&phydev->irq_disable);
 phy_err:
 	phy_error(phydev);
 }
diff -puN include/linux/phy.h~phylib-irq-event-workqueue-handling-fixes include/linux/phy.h
--- a/include/linux/phy.h~phylib-irq-event-workqueue-handling-fixes
+++ a/include/linux/phy.h
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
 
_
