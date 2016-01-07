From: <Woojung.Huh@microchip.com>
Subject: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Thu, 7 Jan 2016 23:14:19 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:62895 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752593AbcAGXOV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 18:14:21 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces PHY_PSEUDO_INTERRUPT and routines to
handle pseudo (not-real-hardware) interrupt such as USB interrupt pipe for
USB-to-Ethernet device.

Unless having real hardware interrupt handler registered by request_irq(),
phy_state_machine() can't avoid calling phy_read_status()
to monitor link changes. This especially prevents USB-to-Ethernet device
from going to auto suspend to save power.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/phy.c | 31 +++++++++++++++++++++++++++++--
 include/linux/phy.h   |  6 ++++++
 2 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 47cd306..8f678e9 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -588,6 +588,25 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 }
 
 /**
+ * phy_pseudo_interrupt - PHY pseudo interrupt handler
+ * @phydev: target phy_device struct
+ *
+ * Description: This is for phy pseudo interrupt such as
+ * USB interrupt pipe for USB-to-Ethernet devices.
+ * When a PHY pseudo interrupt occurs, i.e, USB interrupt pipe completion,
+ * the handler schedules a work task to clear the interrupt.
+ */
+void phy_pseudo_interrupt(struct phy_device *phydev)
+{
+	if (phydev->state != PHY_HALTED) {
+		atomic_inc(&phydev->irq_disable);
+
+		queue_work(system_power_efficient_wq, &phydev->phy_queue);
+	}
+}
+EXPORT_SYMBOL(phy_pseudo_interrupt);
+
+/**
  * phy_enable_interrupts - Enable the interrupts from the PHY side
  * @phydev: target phy_device struct
  */
@@ -640,12 +659,20 @@ phy_err:
 int phy_start_interrupts(struct phy_device *phydev)
 {
 	atomic_set(&phydev->irq_disable, 0);
-	if (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
-			phydev) < 0) {
+
+	/* phydev->irq is bigger than zero when real H/W interrupt.
+	 * This avoids calling request_irq when pseudo interrupt such as
+	 * USB interrupt pipe for USB-to-Ethernet device.
+	 */
+	if ((phydev->irq > 0) &&
+	    (request_irq(phydev->irq, phy_interrupt, 0, "phy_interrupt",
+			 phydev) < 0)) {
 		pr_warn("%s: Can't get IRQ %d (PHY)\n",
 			phydev->bus->name, phydev->irq);
 		phydev->irq = PHY_POLL;
 		return 0;
+	} else if (phydev->irq == PHY_PSEUDO_INTERRUPT) {
+		phy_pseudo_interrupt(phydev);
 	}
 
 	return phy_enable_interrupts(phydev);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 05fde31..a68e690 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -55,6 +55,12 @@
 #define PHY_POLL		-1
 #define PHY_IGNORE_INTERRUPT	-2
 
+/*
+ * Set to PHY_PSEUDO_INTERRUPT when the attached driver uses
+ * not real hardware interrupt such as USB interrupt pipe.
+ */
+#define PHY_PSEUDO_INTERRUPT	-100
+
 #define PHY_HAS_INTERRUPT	0x00000001
 #define PHY_HAS_MAGICANEG	0x00000002
 #define PHY_IS_INTERNAL		0x00000004
-- 
2.1.4
