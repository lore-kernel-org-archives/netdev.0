From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 2/3] phylib: add support for shared PHY interrupts
Date: Mon, 16 Feb 2009 21:53:50 +0100
Message-ID: <1234817631-7981-2-git-send-email-agust@denx.de>
References: <>
 <1234817631-7981-1-git-send-email-agust@denx.de>
Cc: Anatolij Gustschin <agust@denx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:39641 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbZBPUx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 15:53:56 -0500
In-Reply-To: <1234817631-7981-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell 88E1121R PHY device can be hardware-configured
to use shared interrupt pin for both PHY ports. This
patch adds support for shared PHY interrupts to the PHY
framework to enable support for such PHY configurations.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/phy/phy.c        |   13 +++++++++++++
 drivers/net/phy/phy_device.c |    2 ++
 include/linux/phy.h          |    4 ++++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index df4e625..93d387e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -657,9 +657,17 @@ EXPORT_SYMBOL(phy_stop_interrupts);
 static void phy_change(struct work_struct *work)
 {
 	int err;
+	int src;
 	struct phy_device *phydev =
 		container_of(work, struct phy_device, phy_queue);
 
+	if (phydev->drv->flags & PHY_INTERRUPTS_SHARED
+	    && phydev->drv->interrupt_src) {
+		src = phydev->drv->interrupt_src(phydev);
+		if ((src == -1) || (src != phydev->addr))
+			goto ignore;
+	}
+
 	err = phy_disable_interrupts(phydev);
 
 	if (err)
@@ -688,6 +696,11 @@ static void phy_change(struct work_struct *work)
 
 	return;
 
+ignore:
+	atomic_dec(&phydev->irq_disable);
+	enable_irq(phydev->irq);
+	return;
+
 irq_enable_err:
 	disable_irq(phydev->irq);
 	atomic_inc(&phydev->irq_disable);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e11b03b..dccc445 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -401,6 +401,8 @@ void phy_detach(struct phy_device *phydev)
 	 * real driver could be loaded */
 	if (phydev->dev.driver == &genphy_driver.driver)
 		device_release_driver(&phydev->dev);
+	else if (phydev->drv->remove)
+		phydev->drv->remove(phydev);
 }
 EXPORT_SYMBOL(phy_detach);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 77c4ed6..a844c2a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -49,6 +49,7 @@
 
 #define PHY_HAS_INTERRUPT	0x00000001
 #define PHY_HAS_MAGICANEG	0x00000002
+#define PHY_INTERRUPTS_SHARED	0x00000004
 
 /* Interface Mode definitions */
 typedef enum {
@@ -389,6 +390,9 @@ struct phy_driver {
 	/* Enables or disables interrupts */
 	int (*config_intr)(struct phy_device *phydev);
 
+	/* Returns interrupt source if interrupt pin is shared */
+	int (*interrupt_src)(struct phy_device *phydev);
+
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
-- 
1.5.4.3

