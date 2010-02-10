From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 5/5] sky2: Avoid down and up during sky2_reset
Date: Wed, 10 Feb 2010 23:12:25 +0900
Message-ID: <4B72BEC9.4000004@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f202.google.com ([209.85.216.202]:46984 "EHLO
	mail-px0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab0BJORe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 09:17:34 -0500
Received: by mail-px0-f202.google.com with SMTP id 40so12303pxi.21
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 06:17:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rewrite sky2_reset to work with interrupts disabled and
 avoid freeing and reallocing memory.

The old code used sky2_down and sky2_up to implement sky2_reset,
 which meant interrupts could not be disabled, and the transmit and
 receive ring buffers would be free'd and reallocated.

To avoid the interrupt handler waking the transmit queue while
 we're doing a reset, it's better to have interrupts and NAPI
 polls disabled.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   70 ++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 49 insertions(+), 21 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 9ecc129..e922a59 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1898,10 +1898,6 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 
 	sky2->tx_cons = idx;
 	smp_mb();
-
-	/* Wake unless it's detached, and called e.g. from sky2_down() */
-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 && netif_device_present(dev))
-		netif_wake_queue(dev);
 }
 
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
@@ -1926,11 +1922,10 @@ static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
 }
 
-static void sky2_hw_down(struct sky2_port *sky2)
+static void sky2_hw_down(struct sky2_port *sky2, int interrupts_disabled)
 {
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 imask;
 	u16 ctrl;
 
 	/* Force flow control off */
@@ -1964,14 +1959,16 @@ static void sky2_hw_down(struct sky2_port *sky2)
 
 	sky2_rx_stop(sky2);
 
-	/* Disable port IRQ */
-	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~portirq_msk[port];
-	sky2_write32(hw, B0_IMSK, imask);
-	sky2_read32(hw, B0_IMSK);
+	if (!interrupts_disabled) {
+		/* Disable port IRQ */
+		u32 imask = sky2_read32(hw, B0_IMSK);
+		imask &= ~portirq_msk[port];
+		sky2_write32(hw, B0_IMSK, imask);
+		sky2_read32(hw, B0_IMSK);
 
-	synchronize_irq(hw->pdev->irq);
-	napi_synchronize(&hw->napi);
+		synchronize_irq(hw->pdev->irq);
+		napi_synchronize(&hw->napi);
+	}
 
 	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_power_down(hw, port);
@@ -1995,7 +1992,7 @@ static int sky2_down(struct net_device *dev)
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	sky2_hw_down(sky2);
+	sky2_hw_down(sky2, 0);
 
 	sky2_free_buffers(sky2);
 
@@ -2487,8 +2484,13 @@ static inline void sky2_tx_done(struct net_device *dev, u16 last)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (netif_running(dev))
+	if (netif_running(dev)) {
 		sky2_tx_complete(sky2, last);
+
+		/* Wake unless it's detached, and called e.g. from sky2_down() */
+		if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
+			netif_wake_queue(dev);
+	}
 }
 
 static inline void sky2_skb_rx(const struct sky2_port *sky2,
@@ -3283,20 +3285,46 @@ static int sky2_reattach(struct net_device *dev)
 static void sky2_restart(struct work_struct *work)
 {
 	struct sky2_hw *hw = container_of(work, struct sky2_hw, restart_work);
+	u32 imask;
 	int i;
 
 	rtnl_lock();
-	for (i = 0; i < hw->ports; i++)
-		sky2_detach(hw->dev[i]);
 
 	napi_disable(&hw->napi);
+	synchronize_irq(hw->pdev->irq);
+	imask = sky2_read32(hw, B0_IMSK);
 	sky2_write32(hw, B0_IMSK, 0);
+
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		if (!netif_running(dev))
+			continue;
+
+		netif_carrier_off(dev);
+		netif_tx_disable(dev);
+		sky2_hw_down(sky2, 1);
+	}
+
 	sky2_reset(hw);
-	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
-	napi_enable(&hw->napi);
 
-	for (i = 0; i < hw->ports; i++)
-		sky2_reattach(hw->dev[i]);
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		if (!netif_running(dev))
+			continue;
+
+		sky2_hw_up(sky2);
+		netif_wake_queue(dev);
+	}
+
+	sky2_write32(hw, B0_IMSK, imask);
+	sky2_read32(hw, B0_IMSK);
+
+	sky2_read32(hw, B0_Y2_SP_LISR);
+	napi_enable(&hw->napi);
 
 	rtnl_unlock();
 }
-- 
1.5.6.5

