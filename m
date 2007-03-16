From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/7] skge: mask irqs when device down
Date: Fri, 16 Mar 2007 14:01:27 -0700
Message-ID: <20070316210155.883374405@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36171 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965934AbXCPVGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:40 -0400
Content-Disposition: inline; filename=skge-noirq-down.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wheen a port on the skge driver is not used, it should
mask off interrupts from theat port.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

--- skge-dev.orig/drivers/net/skge.c
+++ skge-dev/drivers/net/skge.c
@@ -105,7 +105,8 @@ static const int txqaddr[] = { Q_XA1, Q_
 static const int rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 rxirqmask[] = { IS_R1_F, IS_R2_F };
 static const u32 txirqmask[] = { IS_XA1_F, IS_XA2_F };
-static const u32 irqmask[] = { IS_R1_F|IS_XA1_F, IS_R2_F|IS_XA2_F };
+static const u32 napimask[] = { IS_R1_F|IS_XA1_F, IS_R2_F|IS_XA2_F };
+static const u32 portmask[] = { IS_PORT_1, IS_PORT_2 };
 
 static int skge_get_regs_len(struct net_device *dev)
 {
@@ -2504,6 +2505,11 @@ static int skge_up(struct net_device *de
 	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
 	skge_led(skge, LED_MODE_ON);
 
+	spin_lock_irq(&hw->hw_lock);
+	hw->intr_mask |= portmask[port];
+	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	spin_unlock_irq(&hw->hw_lock);
+
 	netif_poll_enable(dev);
 	return 0;
 
@@ -2533,6 +2539,13 @@ static int skge_down(struct net_device *
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
 		cancel_delayed_work(&skge->link_thread);
 
+	netif_poll_disable(dev);
+
+	spin_lock_irq(&hw->hw_lock);
+	hw->intr_mask &= ~portmask[port];
+	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	spin_unlock_irq(&hw->hw_lock);
+
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		genesis_stop(skge);
@@ -2575,8 +2588,6 @@ static int skge_down(struct net_device *
 
 	skge_led(skge, LED_MODE_OFF);
 
-	netif_poll_disable(dev);
-
 	netif_tx_lock_bh(dev);
 	skge_tx_clean(dev);
 	netif_tx_unlock_bh(dev);
@@ -3051,7 +3062,7 @@ static int skge_poll(struct net_device *
 
 	spin_lock_irqsave(&hw->hw_lock, flags);
 	__netif_rx_complete(dev);
-	hw->intr_mask |= irqmask[skge->port];
+	hw->intr_mask |= napimask[skge->port];
   	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	skge_read32(hw, B0_IMSK);
 	spin_unlock_irqrestore(&hw->hw_lock, flags);
@@ -3415,10 +3426,9 @@ static int skge_reset(struct skge_hw *hw
 	else
 		hw->ram_size = t8 * 4096;
 
-	hw->intr_mask = IS_HW_ERR | IS_PORT_1;
-	if (hw->ports > 1)
-		hw->intr_mask |= IS_PORT_2;
+	hw->intr_mask = IS_HW_ERR;
 
+	/* Use PHY IRQ for all but fiber based Genesis board */
 	if (!(hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC))
 		hw->intr_mask |= IS_EXT_REG;
 

-- 

