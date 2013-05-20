From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 2/2 net-next v2] phy: add phy_mac_interrupt() to use
 with PHY_IGNORE_INTERRUPT
Date: Mon, 20 May 2013 08:53:43 +0000
Message-ID: <1369040023-22270-3-git-send-email-f.fainelli@gmail.com>
References: <1369040023-22270-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jogo@openwrt.org,
	thomas.petazzoni@free-electrons.com, afleming@freescale.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1998 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab3ETIyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 04:54:19 -0400
In-Reply-To: <1369040023-22270-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently no way for an Ethernet MAC driver servicing PHY link
interrupts to notify this to the PHY state machine without defining its
own state machine. Since most drivers are not so special, introduce a
helper: phy_mac_interrupt() which can be called from a link up/down
interrupt routine to update the PHY state machine. To avoid code
duplication some refactoring has been done to expose the workqueue and
its corresponding callback internally.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes since v1:
- rebased on top of net-next

 drivers/net/phy/phy.c        | 14 +++++++++-----
 drivers/net/phy/phy_device.c |  1 +
 include/linux/phy.h          |  2 ++
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3bcf099..2d28a0e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -419,8 +419,6 @@ out_unlock:
 EXPORT_SYMBOL(phy_start_aneg);
 
 
-static void phy_change(struct work_struct *work);
-
 /**
  * phy_start_machine - start PHY state machine tracking
  * @phydev: the phy_device struct
@@ -565,8 +563,6 @@ int phy_start_interrupts(struct phy_device *phydev)
 {
 	int err = 0;
 
-	INIT_WORK(&phydev->phy_queue, phy_change);
-
 	atomic_set(&phydev->irq_disable, 0);
 	if (request_irq(phydev->irq, phy_interrupt,
 				IRQF_SHARED,
@@ -623,7 +619,7 @@ EXPORT_SYMBOL(phy_stop_interrupts);
  * phy_change - Scheduled by the phy_interrupt/timer to handle PHY changes
  * @work: work_struct that describes the work to be done
  */
-static void phy_change(struct work_struct *work)
+void phy_change(struct work_struct *work)
 {
 	int err;
 	struct phy_device *phydev =
@@ -922,6 +918,14 @@ void phy_state_machine(struct work_struct *work)
 	schedule_delayed_work(&phydev->state_queue, PHY_STATE_TIME * HZ);
 }
 
+void phy_mac_interrupt(struct phy_device *phydev, int new_link)
+{
+	cancel_work_sync(&phydev->phy_queue);
+	phydev->link = new_link;
+	schedule_work(&phydev->phy_queue);
+}
+EXPORT_SYMBOL(phy_mac_interrupt);
+
 static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
 				    int addr)
 {
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8e29d22..b55aa33 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -189,6 +189,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 
 	mutex_init(&dev->lock);
 	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
+	INIT_WORK(&dev->phy_queue, phy_change);
 
 	/* Request the appropriate module unconditionally; don't
 	   bother trying to do so only if it isn't already loaded,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 8e4bc8a..fdfa115 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -557,6 +557,8 @@ void phy_drivers_unregister(struct phy_driver *drv, int n);
 int phy_driver_register(struct phy_driver *new_driver);
 int phy_drivers_register(struct phy_driver *new_driver, int n);
 void phy_state_machine(struct work_struct *work);
+void phy_change(struct work_struct *work);
+void phy_mac_interrupt(struct phy_device *phydev, int new_link);
 void phy_start_machine(struct phy_device *phydev,
 		void (*handler)(struct net_device *));
 void phy_stop_machine(struct phy_device *phydev);
-- 
1.8.1.2
