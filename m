From: Jason Lin <kernel.jason@gmail.com>
Subject: [RFC] net:phy:phylib: phy shares the same interrupt with mac
Date: Tue, 3 Apr 2012 10:11:19 +0800
Message-ID: <CAGCDX1nndpdGHZzhh_Y+2OMLZvvUmAqkAsmgHu9hdUXTJFE--Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34842 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab2DCCLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 22:11:20 -0400
Received: by iagz16 with SMTP id z16so4934388iag.19
        for <netdev@vger.kernel.org>; Mon, 02 Apr 2012 19:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1)  Add a new definition PHY_MAC if phy shares the same
     interrupt with mac.
2)  Add do_phy_workqueue(), that mac can invoke this function
     in its ISR when link status changed or other conditions.

Does this seems reasonable?


---------------------------
 drivers/net/phy/phy.c        |   27 +++++++++++++++++++++++++++
 drivers/net/phy/phy_device.c |    4 ++--
 include/linux/phy.h          |    3 +++
 3 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7670aac..c8009e9 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -527,6 +527,28 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
    return IRQ_HANDLED;
 }

+/*
+ * do_phy_workqueue - PHY interrupt handler used by MAC
+ * @irq: interrupt line
+ * @phydev: phy_device pointer
+ *
+ * Description: When a PHY use the same interrupt with MAC,
+ * the handler is invoked by MAC, and schedules  a work task
+ * to clear the PHY's interrupt.
+ * This handler is invoked only in MAC's ISR.
+ */
+irqreturn_t do_phy_workqueue(int irq, struct phy_device *phydev) {
+
+   BUG_ON(!in_interrupt());
+
+   if (PHY_HALTED == phydev->state)
+       return IRQ_NONE;
+
+   schedule_work(&phydev->phy_queue);
+   return IRQ_HANDLED;
+}
+EXPORT_SYMBOL(do_phy_workqueue);
+
 /**
  * phy_enable_interrupts - Enable the interrupts from the PHY side
  * @phydev: target phy_device struct
@@ -589,6 +611,11 @@ int phy_start_interrupts(struct phy_device *phydev)

    INIT_WORK(&phydev->phy_queue, phy_change);

+   if (phydev->irq == PHY_MAC) {
+       err = phy_enable_interrupts(phydev);
+       return err;
+   }
+
    atomic_set(&phydev->irq_disable, 0);
    if (request_irq(phydev->irq, phy_interrupt,
                IRQF_SHARED,
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 993c52c..1857097 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -345,7 +345,7 @@ int phy_connect_direct(struct net_device *dev,
struct phy_device *phydev,

    phy_prepare_link(phydev, handler);
    phy_start_machine(phydev, NULL);
-   if (phydev->irq > 0)
+   if ((phydev->irq > 0) || (phydev->irq == PHY_MAC))
        phy_start_interrupts(phydev);

    return 0;
@@ -399,7 +399,7 @@ EXPORT_SYMBOL(phy_connect);
  */
 void phy_disconnect(struct phy_device *phydev)
 {
-   if (phydev->irq > 0)
+   if ((phydev->irq > 0) || (phydev->irq == PHY_MAC))
        phy_stop_interrupts(phydev);

    phy_stop_machine(phydev);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7da5fa8..155822c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -44,9 +44,11 @@
  * Set phydev->irq to PHY_POLL if interrupts are not supported,
  * or not desired for this PHY.  Set to PHY_IGNORE_INTERRUPT if
  * the attached driver handles the interrupt
+ * Set to PHY_MAC if using the same interrupt with MAC
  */
 #define PHY_POLL       -1
 #define PHY_IGNORE_INTERRUPT   -2
+#define PHY_MAC        -3

 #define PHY_HAS_INTERRUPT  0x00000001
 #define PHY_HAS_MAGICANEG  0x00000002
@@ -510,6 +512,7 @@ int phy_ethtool_sset(struct phy_device *phydev,
struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_mii_ioctl(struct phy_device *phydev,
        struct ifreq *ifr, int cmd);
+irqreturn_t do_phy_workqueue(int irq, struct phy_device *phydev);
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 void phy_device_free(struct phy_device *phydev);
