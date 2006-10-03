From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Tue, 3 Oct 2006 16:18:35 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:3855 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S964852AbWJCPSf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 11:18:35 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

 This patch fixes a couple of problems discovered with interrupt handling 
in the phylib core, namely:

1. The driver uses timer and workqueue calls, but does not include 
   <linux/timer.h> nor <linux/workqueue.h>.

2. The driver uses schedule_work() for handling interrupts, but does not 
   make sure any pending work scheduled thus has been completed before 
   driver's structures get freed from memory.  This is especially 
   important as interrupts may keep arriving if the line is shared with 
   another PHY.

   The solution is to ignore phy_interrupt() calls if the reported device 
   has already been halted and calling flush_scheduled_work() from 
   phy_stop_interrupts() (but guarded with current_is_keventd() in case 
   the function has been called through keventd from the MAC device's 
   close call to avoid a deadlock on the netlink lock).

 Please consider.

  Maciej

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

patch-mips-2.6.18-20060920-phy-irq-16
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c linux-mips-2.6.18-20060920/drivers/net/phy/phy.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c	2006-08-05 04:58:46.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/phy/phy.c	2006-10-03 14:19:21.000000000 +0000
@@ -7,6 +7,7 @@
  * Author: Andy Fleming
  *
  * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2006  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -32,6 +33,8 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/timer.h>
+#include <linux/workqueue.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -484,6 +487,9 @@ static irqreturn_t phy_interrupt(int irq
 {
 	struct phy_device *phydev = phy_dat;
 
+	if (PHY_HALTED == phydev->state)
+		return IRQ_NONE;		/* It can't be ours.  */
+
 	/* The MDIO bus is not allowed to be written in interrupt
 	 * context, so we need to disable the irq here.  A work
 	 * queue will write the PHY to disable and clear the
@@ -577,6 +583,13 @@ int phy_stop_interrupts(struct phy_devic
 	if (err)
 		phy_error(phydev);
 
+	/*
+	 * Finish any pending work; we might have been scheduled
+	 * to be called from keventd ourselves, though.
+	 */
+	if (!current_is_keventd())
+		flush_scheduled_work();
+
 	free_irq(phydev->irq, phydev);
 
 	return err;
@@ -603,7 +616,8 @@ static void phy_change(void *data)
 	enable_irq(phydev->irq);
 
 	/* Reenable interrupts */
-	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+	if (PHY_HALTED != phydev->state)
+		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
 
 	if (err)
 		goto irq_enable_err;
@@ -624,18 +638,24 @@ void phy_stop(struct phy_device *phydev)
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
 
-	if (phydev->irq != PHY_POLL) {
-		/* Clear any pending interrupts */
-		phy_clear_interrupt(phydev);
+	phydev->state = PHY_HALTED;
 
+	if (phydev->irq != PHY_POLL) {
 		/* Disable PHY Interrupts */
 		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
-	}
 
-	phydev->state = PHY_HALTED;
+		/* Clear any pending interrupts */
+		phy_clear_interrupt(phydev);
+	}
 
 out_unlock:
 	spin_unlock(&phydev->lock);
+
+	/*
+	 * Cannot call flush_scheduled_work() here as desired because
+	 * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
+	 * will not reenable interrupts.
+	 */
 }
 
 
