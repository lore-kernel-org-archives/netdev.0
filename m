From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 3/5] net: phy: Threaded interrupts allow some simplification
Date: Sun, 16 Oct 2016 19:56:51 +0200
Message-ID: <1476640613-25365-4-git-send-email-andrew@lunn.ch>
References: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46313 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754005AbcJPR5X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 13:57:23 -0400
In-Reply-To: <1476640613-25365-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY interrupts are now handled in a threaded interrupt handler,
which can sleep. The work queue is no longer needed, phy_change() can
be called directly. phy_mac_interrupt() still needs to be safe to call
in interrupt context, so keep the work queue, and use a helper to call
phy_change().

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/phy.c        | 45 +++++++++++++++++++++++++-------------------
 drivers/net/phy/phy_device.c |  2 +-
 include/linux/phy.h          |  5 +++--
 3 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 25f2b296aaba..bb673c63c85c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -664,7 +664,7 @@ static void phy_error(struct phy_device *phydev)
  * @phy_dat: phy_device pointer
  *
  * Description: When a PHY interrupt occurs, the handler disables
- * interrupts, and schedules a work task to clear the interrupt.
+ * interrupts, and uses phy_change to handle the interrupt.
  */
 static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 {
@@ -673,15 +673,10 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
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
@@ -766,12 +761,6 @@ int phy_stop_interrupts(struct phy_device *phydev)
 
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
@@ -784,14 +773,11 @@ int phy_stop_interrupts(struct phy_device *phydev)
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
@@ -833,6 +819,18 @@ void phy_change(struct work_struct *work)
 }
 
 /**
+ * phy_change_work - Scheduled by the phy_mac_interrupt to handle PHY changes
+ * @work: work_struct that describes the work to be done
+ */
+void phy_change_work(struct work_struct *work)
+{
+	struct phy_device *phydev =
+		container_of(work, struct phy_device, phy_queue);
+
+	phy_change(phydev);
+}
+
+/**
  * phy_stop - Bring down the PHY link, and stop checking the status
  * @phydev: target phy_device struct
  */
@@ -1116,6 +1114,15 @@ void phy_state_machine(struct work_struct *work)
 				   PHY_STATE_TIME * HZ);
 }
 
+/**
+ * phy_mac_interrupt - MAC says the link has changed
+ * @phydev: phy_device struct with changed link
+ * @new_link: Link is Up/Down.
+ *
+ * Description: The MAC layer is able indicate there has been a change
+ *   in the PHY link status. Set the new link status, and trigger the
+ *   state machine, work a work queue.
+ */
 void phy_mac_interrupt(struct phy_device *phydev, int new_link)
 {
 	phydev->link = new_link;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e977ba931878..ac440a815353 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -347,7 +347,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 
 	mutex_init(&dev->lock);
 	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
-	INIT_WORK(&dev->phy_queue, phy_change);
+	INIT_WORK(&dev->phy_queue, phy_change_work);
 
 	/* Request the appropriate module unconditionally; don't
 	 * bother trying to do so only if it isn't already loaded,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e25f1830fbcf..c47378c93607 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -343,7 +343,7 @@ struct phy_c45_device_ids {
  * giving up on the current attempt at acquiring a link
  * irq: IRQ number of the PHY's interrupt (-1 if none)
  * phy_timer: The timer for handling the state machine
- * phy_queue: A work_queue for the interrupt
+ * phy_queue: A work_queue for the phy_mac_interrupt
  * attached_dev: The attached enet driver's device instance ptr
  * adjust_link: Callback for the enet controller to respond to
  * changes in the link state.
@@ -802,7 +802,8 @@ int phy_driver_register(struct phy_driver *new_driver, struct module *owner);
 int phy_drivers_register(struct phy_driver *new_driver, int n,
 			 struct module *owner);
 void phy_state_machine(struct work_struct *work);
-void phy_change(struct work_struct *work);
+void phy_change(struct phy_device *phydev);
+void phy_change_work(struct work_struct *work);
 void phy_mac_interrupt(struct phy_device *phydev, int new_link);
 void phy_start_machine(struct phy_device *phydev);
 void phy_stop_machine(struct phy_device *phydev);
-- 
2.9.3
