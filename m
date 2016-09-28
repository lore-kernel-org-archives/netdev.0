From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 3/6] net: phy: Threaded interrupts allow some simplification
Date: Wed, 28 Sep 2016 10:32:21 +0200
Message-ID: <1475051544-18561-4-git-send-email-andrew@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34943 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751634AbcI1IeY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 04:34:24 -0400
In-Reply-To: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY interrupts are now handled in a threaded interrupt handler,
which can sleep. The work queue is no longer needed, phy_change() can
be called directly. Additionally, none of the callers of
phy_mac_interrupt() did so in interrupt context, so fully remove the
work queue, and document that phy_mac_interrupt() should not be called
in interrupt context.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/phy.c        | 37 ++++++++++++++++---------------------
 drivers/net/phy/phy_device.c |  1 -
 include/linux/phy.h          |  4 +---
 3 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5c29ed72f721..09fa8a950af1 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -647,7 +647,7 @@ static void phy_error(struct phy_device *phydev)
  * @phy_dat: phy_device pointer
  *
  * Description: When a PHY interrupt occurs, the handler disables
- * interrupts, and schedules a work task to clear the interrupt.
+ * interrupts, and uses phy_change to handle the interrupt.
  */
 static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 {
@@ -656,15 +656,10 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 	if (PHY_HALTED == phydev->state)
 		return IRQ_NONE;		/* It can't be ours.  */
 
-	/* The MDIO bus is not allowed to be written in interrupt
-	 * context, so we need to disable the irq here.  A work
-	 * queue will write the PHY to disable and clear the
-	 * interrupt, and then reenable the irq line.
-	 */
 	disable_irq_nosync(irq);
 	atomic_inc(&phydev->irq_disable);
 
-	queue_work(system_power_efficient_wq, &phydev->phy_queue);
+	phy_change(phydev);
 
 	return IRQ_HANDLED;
 }
@@ -748,12 +743,6 @@ int phy_stop_interrupts(struct phy_device *phydev)
 
 	free_irq(phydev->irq, phydev);
 
-	/* Cannot call flush_scheduled_work() here as desired because
-	 * of rtnl_lock(), but we do not really care about what would
-	 * be done, except from enable_irq(), so cancel any work
-	 * possibly pending and take care of the matter below.
-	 */
-	cancel_work_sync(&phydev->phy_queue);
 	/* If work indeed has been cancelled, disable_irq() will have
 	 * been left unbalanced from phy_interrupt() and enable_irq()
 	 * has to be called so that other devices on the line work.
@@ -766,14 +755,11 @@ int phy_stop_interrupts(struct phy_device *phydev)
 EXPORT_SYMBOL(phy_stop_interrupts);
 
 /**
- * phy_change - Scheduled by the phy_interrupt/timer to handle PHY changes
- * @work: work_struct that describes the work to be done
+ * phy_change - Called by the phy_interrupt to handle PHY changes
+ * @phydev: phy_device struct that interrupted
  */
-void phy_change(struct work_struct *work)
+void phy_change(struct phy_device *phydev)
 {
-	struct phy_device *phydev =
-		container_of(work, struct phy_device, phy_queue);
-
 	if (phy_interrupt_is_valid(phydev)) {
 		if (phydev->drv->did_interrupt &&
 		    !phydev->drv->did_interrupt(phydev))
@@ -1097,12 +1083,21 @@ void phy_state_machine(struct work_struct *work)
 				   PHY_STATE_TIME * HZ);
 }
 
+/**
+ * phy_mac_interrupt - MAC says the link has changed
+ * @phydev: phy_device struct with changed link
+ * @new_link: Link is Up/Down.
+ *
+ * Description: The MAC layer is able indicate there has been a change
+ *   in the PHY link status. Set the new link status, and trigger the
+ *   state machine if needed.
+ *   Cannot be called in Interrupt context.
+ */
 void phy_mac_interrupt(struct phy_device *phydev, int new_link)
 {
 	phydev->link = new_link;
 
-	/* Trigger a state machine change */
-	queue_work(system_power_efficient_wq, &phydev->phy_queue);
+	phy_change(phydev);
 }
 EXPORT_SYMBOL(phy_mac_interrupt);
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e977ba931878..bae4452700ab 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -347,7 +347,6 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 
 	mutex_init(&dev->lock);
 	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
-	INIT_WORK(&dev->phy_queue, phy_change);
 
 	/* Request the appropriate module unconditionally; don't
 	 * bother trying to do so only if it isn't already loaded,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e25f1830fbcf..692e3e5a8a7c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -343,7 +343,6 @@ struct phy_c45_device_ids {
  * giving up on the current attempt at acquiring a link
  * irq: IRQ number of the PHY's interrupt (-1 if none)
  * phy_timer: The timer for handling the state machine
- * phy_queue: A work_queue for the interrupt
  * attached_dev: The attached enet driver's device instance ptr
  * adjust_link: Callback for the enet controller to respond to
  * changes in the link state.
@@ -416,7 +415,6 @@ struct phy_device {
 	void *priv;
 
 	/* Interrupt and Polling infrastructure */
-	struct work_struct phy_queue;
 	struct delayed_work state_queue;
 	atomic_t irq_disable;
 
@@ -802,7 +800,7 @@ int phy_driver_register(struct phy_driver *new_driver, struct module *owner);
 int phy_drivers_register(struct phy_driver *new_driver, int n,
 			 struct module *owner);
 void phy_state_machine(struct work_struct *work);
-void phy_change(struct work_struct *work);
+void phy_change(struct phy_device *phydev);
 void phy_mac_interrupt(struct phy_device *phydev, int new_link);
 void phy_start_machine(struct phy_device *phydev);
 void phy_stop_machine(struct phy_device *phydev);
-- 
2.9.3
