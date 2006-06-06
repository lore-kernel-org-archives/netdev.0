From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] skge: use workq for PHY handling
Date: Tue, 06 Jun 2006 10:11:11 -0700
Message-ID: <20060606171341.432229000@zqx3.pdx.osdl.net>
References: <20060606171110.592587000@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49618 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750708AbWFFROj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 13:14:39 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-phy-workq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since accessing the PHY can take 100's of usecs, use a work queue to
allow spinning in outside of soft/hard irq.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -603,7 +603,7 @@ static void skge_led(struct skge_port *s
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 
-	spin_lock_bh(&hw->phy_lock);
+	mutex_lock(&hw->phy_mutex);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		switch (mode) {
 		case LED_MODE_OFF:
@@ -663,7 +663,7 @@ static void skge_led(struct skge_port *s
 				     PHY_M_LED_MO_RX(MO_LED_ON));
 		}
 	}
-	spin_unlock_bh(&hw->phy_lock);
+	mutex_unlock(&hw->phy_mutex);
 }
 
 /* blink LED's for finding board */
@@ -2038,7 +2038,7 @@ static void skge_phy_reset(struct skge_p
 	netif_stop_queue(skge->netdev);
 	netif_carrier_off(skge->netdev);
 
-	spin_lock_bh(&hw->phy_lock);
+	mutex_lock(&hw->phy_mutex);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		genesis_reset(hw, port);
 		genesis_mac_init(hw, port);
@@ -2046,7 +2046,7 @@ static void skge_phy_reset(struct skge_p
 		yukon_reset(hw, port);
 		yukon_init(hw, port);
 	}
-	spin_unlock_bh(&hw->phy_lock);
+	mutex_unlock(&hw->phy_mutex);
 }
 
 /* Basic MII support */
@@ -2067,12 +2067,12 @@ static int skge_ioctl(struct net_device 
 		/* fallthru */
 	case SIOCGMIIREG: {
 		u16 val = 0;
-		spin_lock_bh(&hw->phy_lock);
+		mutex_lock(&hw->phy_mutex);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = __xm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
 		else
 			err = __gm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
-		spin_unlock_bh(&hw->phy_lock);
+		mutex_unlock(&hw->phy_mutex);
 		data->val_out = val;
 		break;
 	}
@@ -2081,14 +2081,14 @@ static int skge_ioctl(struct net_device 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_bh(&hw->phy_lock);
+		mutex_lock(&hw->phy_mutex);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = xm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
 		else
 			err = gm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
-		spin_unlock_bh(&hw->phy_lock);
+		mutex_unlock(&hw->phy_mutex);
 		break;
 	}
 	return err;
@@ -2191,12 +2191,12 @@ static int skge_up(struct net_device *de
 		goto free_rx_ring;
 
 	/* Initialize MAC */
-	spin_lock_bh(&hw->phy_lock);
+	mutex_lock(&hw->phy_mutex);
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		genesis_mac_init(hw, port);
 	else
 		yukon_mac_init(hw, port);
-	spin_unlock_bh(&hw->phy_lock);
+	mutex_unlock(&hw->phy_mutex);
 
 	/* Configure RAMbuffers */
 	chunk = hw->ram_size / ((hw->ports + 1)*2);
@@ -2847,16 +2847,16 @@ static void skge_error_irq(struct skge_h
 }
 
 /*
- * Interrupt from PHY are handled in tasklet (soft irq)
+ * Interrupt from PHY are handled in work queue
  * because accessing phy registers requires spin wait which might
  * cause excess interrupt latency.
  */
-static void skge_extirq(unsigned long data)
+static void skge_extirq(void *arg)
 {
-	struct skge_hw *hw = (struct skge_hw *) data;
+	struct skge_hw *hw = arg;
 	int port;
 
-	spin_lock(&hw->phy_lock);
+	mutex_lock(&hw->phy_mutex);
 	for (port = 0; port < hw->ports; port++) {
 		struct net_device *dev = hw->dev[port];
 		struct skge_port *skge = netdev_priv(dev);
@@ -2868,7 +2868,7 @@ static void skge_extirq(unsigned long da
 				bcom_phy_intr(skge);
 		}
 	}
-	spin_unlock(&hw->phy_lock);
+	mutex_unlock(&hw->phy_mutex);
 
 	hw->intr_mask |= IS_EXT_REG;
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
@@ -2886,7 +2886,7 @@ static irqreturn_t skge_intr(int irq, vo
 
 	if (status & IS_EXT_REG) {
 		hw->intr_mask &= ~IS_EXT_REG;
-		tasklet_schedule(&hw->ext_tasklet);
+		schedule_work(&hw->phy_work);
 	}
 
 	if (status & (IS_R1_F|IS_XA1_F)) {
@@ -2957,7 +2957,7 @@ static int skge_set_mac_address(struct n
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	spin_lock_bh(&hw->phy_lock);
+	mutex_lock(&hw->phy_mutex);
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	memcpy_toio(hw->regs + B2_MAC_1 + port*8,
 		    dev->dev_addr, ETH_ALEN);
@@ -2970,7 +2970,7 @@ static int skge_set_mac_address(struct n
 		gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
 		gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
 	}
-	spin_unlock_bh(&hw->phy_lock);
+	mutex_unlock(&hw->phy_mutex);
 
 	return 0;
 }
@@ -3150,14 +3150,14 @@ static int skge_reset(struct skge_hw *hw
 
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 
-	spin_lock_bh(&hw->phy_lock);
+	mutex_lock(&hw->phy_mutex);
 	for (i = 0; i < hw->ports; i++) {
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			genesis_reset(hw, i);
 		else
 			yukon_reset(hw, i);
 	}
-	spin_unlock_bh(&hw->phy_lock);
+	mutex_unlock(&hw->phy_mutex);
 
 	return 0;
 }
@@ -3305,8 +3305,8 @@ static int __devinit skge_probe(struct p
 	}
 
 	hw->pdev = pdev;
-	spin_lock_init(&hw->phy_lock);
-	tasklet_init(&hw->ext_tasklet, skge_extirq, (unsigned long) hw);
+	mutex_init(&hw->phy_mutex);
+	INIT_WORK(&hw->phy_work, skge_extirq, hw);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -3392,7 +3392,7 @@ static void __devexit skge_remove(struct
 	skge_write16(hw, B0_LED, LED_STAT_OFF);
 	skge_write8(hw, B0_CTST, CS_RST_SET);
 
-	tasklet_kill(&hw->ext_tasklet);
+	flush_scheduled_work();
 
 	free_irq(pdev->irq, hw);
 	pci_release_regions(pdev);
--- skge-2.6.orig/drivers/net/skge.h
+++ skge-2.6/drivers/net/skge.h
@@ -2399,9 +2399,8 @@ struct skge_hw {
 	u32	     	     ram_size;
 	u32	     	     ram_offset;
 	u16		     phy_addr;
-
-	struct tasklet_struct ext_tasklet;
-	spinlock_t	     phy_lock;
+	struct work_struct   phy_work;
+	struct mutex	     phy_mutex;
 };
 
 enum {

--

