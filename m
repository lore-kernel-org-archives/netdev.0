From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/10] sky2: Avoid down and up during sky2_reset
Date: Fri, 12 Feb 2010 08:58:06 -0800
Message-ID: <20100212165938.144089870@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org, Mike McCormack <mikem@ring3k.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49516 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757444Ab0BLRIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:42 -0500
Content-Disposition: inline; filename=sky2-mike5.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Rewrite sky2_reset to work with interrupts disabled and
 avoid freeing and reallocing memory.

The old code used sky2_down and sky2_up to implement sky2_reset,
 which meant interrupts could not be disabled, and the transmit and
 receive ring buffers would be free'd and reallocated.

To avoid the interrupt handler waking the transmit queue while
 we're doing a reset, it's better to have interrupts and NAPI
 polls disabled.

Note: Modified Mike's patch to do IRQ disable in sky2_down before
 calling sky2_hw_down - Stephen

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |   68 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 47 insertions(+), 21 deletions(-)

--- a/drivers/net/sky2.c	2010-02-11 15:46:45.651858252 -0800
+++ b/drivers/net/sky2.c	2010-02-11 15:46:51.181857729 -0800
@@ -1880,10 +1880,6 @@ static void sky2_tx_complete(struct sky2
 
 	sky2->tx_cons = idx;
 	smp_mb();
-
-	/* Wake unless it's detached, and called e.g. from sky2_down() */
-	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 && netif_device_present(dev))
-		netif_wake_queue(dev);
 }
 
 static void sky2_tx_reset(struct sky2_hw *hw, unsigned port)
@@ -1912,7 +1908,6 @@ static void sky2_hw_down(struct sky2_por
 {
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u32 imask;
 	u16 ctrl;
 
 	/* Force flow control off */
@@ -1946,15 +1941,6 @@ static void sky2_hw_down(struct sky2_por
 
 	sky2_rx_stop(sky2);
 
-	/* Disable port IRQ */
-	imask = sky2_read32(hw, B0_IMSK);
-	imask &= ~portirq_msk[port];
-	sky2_write32(hw, B0_IMSK, imask);
-	sky2_read32(hw, B0_IMSK);
-
-	synchronize_irq(hw->pdev->irq);
-	napi_synchronize(&hw->napi);
-
 	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_power_down(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
@@ -1969,6 +1955,7 @@ static void sky2_hw_down(struct sky2_por
 static int sky2_down(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
 
 	/* Never really got started! */
 	if (!sky2->tx_le)
@@ -1977,6 +1964,14 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
+	/* Disable port IRQ */
+	sky2_write32(hw, B0_IMSK,
+		     sky2_read32(hw, B0_IMSK) & ~portirq_msk[sky2->port]);
+	sky2_read32(hw, B0_IMSK);
+
+	synchronize_irq(hw->pdev->irq);
+	napi_synchronize(&hw->napi);
+
 	sky2_hw_down(sky2);
 
 	sky2_free_buffers(sky2);
@@ -2475,8 +2470,13 @@ static inline void sky2_tx_done(struct n
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
@@ -3277,20 +3277,46 @@ static int sky2_reattach(struct net_devi
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
+		sky2_hw_down(sky2);
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

