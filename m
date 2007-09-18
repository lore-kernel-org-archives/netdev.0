From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] PHYLIB: Spinlock fixes for softirqs
Date: Tue, 18 Sep 2007 15:58:13 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709181532190.9650@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:59315 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757937AbXIRO6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 10:58:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Use spin_lock_bh()/spin_unlock_bh() for the phydev lock throughout as it 
is used in phy_timer() that is called as a softirq and all the other 
operations may happen in the user context.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 There has been a change recently that did such a conversion for some of 
the operations on the lock, but some have been left intact.  Many of them, 
perhaps all, may be called in the user context and I was able to trigger 
recursive spinlock acquisition indeed, so I think for the sake of 
long-term maintenance it is best to convert them all, even if 
unnecessarily for one or two -- better safe than sorry.

 Perhaps one in phy_timer() could actually be skipped as only called as a 
softirq -- I can send an update if that sounds like a good idea.

 Checked with checkpatch.pl and at the runtime.

 Please apply,

  Maciej

patch-netdev-2.6.23-rc6-20070913-phy-spinlock-8 
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/phy/phy.c linux-netdev-2.6.23-rc6-20070913/drivers/net/phy/phy.c
--- linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/phy/phy.c	2007-09-13 17:27:52.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/drivers/net/phy/phy.c	2007-09-16 17:26:02.000000000 +0000
@@ -423,7 +423,7 @@ int phy_start_aneg(struct phy_device *ph
 {
 	int err;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	if (AUTONEG_DISABLE == phydev->autoneg)
 		phy_sanitize_settings(phydev);
@@ -444,7 +444,7 @@ int phy_start_aneg(struct phy_device *ph
 	}
 
 out_unlock:
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 	return err;
 }
 EXPORT_SYMBOL(phy_start_aneg);
@@ -489,10 +489,10 @@ void phy_stop_machine(struct phy_device 
 {
 	del_timer_sync(&phydev->phy_timer);
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	if (phydev->state > PHY_UP)
 		phydev->state = PHY_UP;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	phydev->adjust_state = NULL;
 }
@@ -536,9 +536,9 @@ static void phy_force_reduction(struct p
  */
 void phy_error(struct phy_device *phydev)
 {
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	phydev->state = PHY_HALTED;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 }
 
 /**
@@ -689,10 +689,10 @@ static void phy_change(struct work_struc
 	if (err)
 		goto phy_err;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
 		phydev->state = PHY_CHANGELINK;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	enable_irq(phydev->irq);
 
@@ -717,7 +717,7 @@ phy_err:
  */
 void phy_stop(struct phy_device *phydev)
 {
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
@@ -733,7 +733,7 @@ void phy_stop(struct phy_device *phydev)
 	}
 
 out_unlock:
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	/*
 	 * Cannot call flush_scheduled_work() here as desired because
@@ -781,7 +781,7 @@ static void phy_timer(unsigned long data
 	int needs_aneg = 0;
 	int err = 0;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	if (phydev->adjust_state)
 		phydev->adjust_state(phydev->attached_dev);
@@ -947,7 +947,7 @@ static void phy_timer(unsigned long data
 			break;
 	}
 
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	if (needs_aneg)
 		err = phy_start_aneg(phydev);
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/phy/phy_device.c linux-netdev-2.6.23-rc6-20070913/drivers/net/phy/phy_device.c
--- linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/phy/phy_device.c	2007-09-13 17:27:52.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/drivers/net/phy/phy_device.c	2007-09-16 17:27:48.000000000 +0000
@@ -670,9 +670,9 @@ static int phy_remove(struct device *dev
 
 	phydev = to_phy_device(dev);
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	phydev->state = PHY_DOWN;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	if (phydev->drv->remove)
 		phydev->drv->remove(phydev);
