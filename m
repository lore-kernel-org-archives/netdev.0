From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 2/2 net-next] phy: add phy_mac_interrupt() to use with
 PHY_IGNORE_INTERRUPT
Date: Thu, 16 May 2013 18:04:56 +0000
Message-ID: <1368727496-25638-3-git-send-email-f.fainelli@gmail.com>
References: <1368727496-25638-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org,
	thomas.petazzoni@free-electrons.com, afleming@freescale.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1669 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559Ab3EPSFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 14:05:22 -0400
In-Reply-To: <1368727496-25638-1-git-send-email-f.fainelli@gmail.com>
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
 drivers/net/phy/phy.c        | 14 +++++++++-----
 drivers/net/phy/phy_device.c |  1 +
 include/linux/phy.h          |  2 ++
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 2de4290..8a3b83a 100644
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
@@ -921,6 +917,14 @@ void phy_state_machine(struct work_struct *work)
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
index 3cb80b8..59e0236 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -189,6 +189,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 
 	mutex_init(&dev->lock);
 	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
+	INIT_WORK(&dev->phy_queue, phy_change);
 
 	/* Request the appropriate module unconditionally; don't
 	   bother trying to do so only if it isn't already loaded,
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 9e11039..be3842b 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -545,6 +545,8 @@ void phy_drivers_unregister(struct phy_driver *drv, int n);
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
