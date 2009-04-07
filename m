From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH 2/3] phylib: Allow early-out in phy_change
Date: Tue,  7 Apr 2009 14:01:42 +0200
Message-ID: <1239105703-26240-2-git-send-email-agust@denx.de>
References: <1239105703-26240-1-git-send-email-agust@denx.de>
Cc: afleming@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:55745 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbZDGMBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 08:01:50 -0400
In-Reply-To: <1239105703-26240-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell 88E1121R Dual PHY device can be hardware-configured
to use shared interrupt pin for both PHY ports. For such
PHY configurations using shared PHY interrupt phy_interrupt()
handler will also schedule a work for PHY port which didn't
cause an interrupt.

This patch adds a possibility for PHY drivers to provide
did_interrupt() function which reports if the PHY (or a PHY
port in a multi-PHY device) generated an interrupt. This
function is called in phy_change() as phy_change() shouldn't
proceed if it is invoked for a PHY which didn't cause an
interrupt. So check for interrupt originator in phy_change()
to allow early-out.

Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
 drivers/net/phy/phy.c |    9 +++++++++
 include/linux/phy.h   |    6 ++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3ff1f42..e3b8932 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -655,6 +655,10 @@ static void phy_change(struct work_struct *work)
 	struct phy_device *phydev =
 		container_of(work, struct phy_device, phy_queue);
 
+	if (phydev->drv->did_interrupt &&
+	    !phydev->drv->did_interrupt(phydev))
+		goto ignore;
+
 	err = phy_disable_interrupts(phydev);
 
 	if (err)
@@ -681,6 +685,11 @@ static void phy_change(struct work_struct *work)
 
 	return;
 
+ignore:
+	atomic_dec(&phydev->irq_disable);
+	enable_irq(phydev->irq);
+	return;
+
 irq_enable_err:
 	disable_irq(phydev->irq);
 	atomic_inc(&phydev->irq_disable);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 32cf14a..c871065 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -388,6 +388,12 @@ struct phy_driver {
 	/* Enables or disables interrupts */
 	int (*config_intr)(struct phy_device *phydev);
 
+	/*
+	 * Checks if the PHY generated an interrupt.
+	 * For multy-PHY devices with shared PHY interrupt pin
+	 */
+	int (*did_interrupt)(struct phy_device *phydev);
+
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
-- 
1.5.6.3

