From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [patch 3/6] 2.6.18: sb1250-mac: Phylib IRQ handling fixes
Date: Thu, 30 Nov 2006 18:07:45 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0611301757200.1757@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0610031509380.4642@blysk.ds.pg.gda.pl>
 <E2ACBAE3-B0E1-4D90-BF25-6981543090C4@freescale.com>
 <Pine.LNX.4.64N.0610231752440.4426@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:44295 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1030923AbWK3SHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 13:07:49 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <Pine.LNX.4.64N.0610231752440.4426@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006, Maciej W. Rozycki wrote:

> > I'm not too enthusiastic about requiring the ethernet drivers to call
> > phy_disconnect in a separate thread after "close" is called.  Assuming there's
> > not some sort of "squash work queue" function that can be invoked with
> > rtnl_lock held, I think phy_disconnect should schedule itself to flush the
> > queue.  This would also require that mdiobus_unregister hold off on freeing
> > phydevs if any of the phys were still waiting for pending flush_pending calls
> > to finish.  Which would, in turn, require mdiobus_unregister to schedule
> > cleaning up memory for some later time.
> 
>  This could work, indeed.
> 
> > I'm not enthusiastic about that implementation, either, but it maintains the
> > abstractions I consider important for this code.  The ethernet driver should
> > not need to know what structures the PHY lib uses to implement its interrupt
> > handling, and how to work around their failings, IMHO.
> 
>  Agreed.

 So what's the plan?

 Here's a new version of the patch that addresses your other concerns.

  Maciej

patch-mips-2.6.18-20060920-phy-irq-18
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c linux-mips-2.6.18-20060920/drivers/net/phy/phy.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c	2006-08-05 04:58:46.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/phy/phy.c	2006-11-30 17:58:37.000000000 +0000
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
@@ -596,14 +609,17 @@ static void phy_change(void *data)
 		goto phy_err;
 
 	spin_lock(&phydev->lock);
+
 	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
 		phydev->state = PHY_CHANGELINK;
-	spin_unlock(&phydev->lock);
 
 	enable_irq(phydev->irq);
 
 	/* Reenable interrupts */
-	err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+	if (PHY_HALTED != phydev->state)
+		err = phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED);
+
+	spin_unlock(&phydev->lock);
 
 	if (err)
 		goto irq_enable_err;
@@ -624,15 +640,15 @@ void phy_stop(struct phy_device *phydev)
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
