From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/7] skge: use per-port phy locking
Date: Fri, 16 Mar 2007 14:01:28 -0700
Message-ID: <20070316210155.954697018@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36176 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965940AbXCPVGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:42 -0400
Content-Disposition: inline; filename=skge-phy-port.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than a workqueue and a per-board mutex to control PHY,
use a tasklet and spinlock. Tasklet is lower overhead and works
just as well for this.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.c |   82 ++++++++++++++++++++++++++++-------------------------
 drivers/net/skge.h |    6 +--
 2 files changed, 47 insertions(+), 41 deletions(-)

--- skge-dev.orig/drivers/net/skge.c
+++ skge-dev/drivers/net/skge.c
@@ -672,7 +672,7 @@ static void skge_led(struct skge_port *s
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&hw->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		switch (mode) {
 		case LED_MODE_OFF:
@@ -743,7 +743,7 @@ static void skge_led(struct skge_port *s
 				     PHY_M_LED_MO_RX(MO_LED_ON));
 		}
 	}
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&hw->phy_lock);
 }
 
 /* blink LED's for finding board */
@@ -1317,7 +1317,7 @@ static void xm_phy_init(struct skge_port
 	xm_phy_write(hw, port, PHY_XMAC_CTRL, ctrl);
 
 	/* Poll PHY for status changes */
-	schedule_delayed_work(&skge->link_thread, LINK_HZ);
+	mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static void xm_check_link(struct net_device *dev)
@@ -1392,10 +1392,9 @@ static void xm_check_link(struct net_dev
  * Since internal PHY is wired to a level triggered pin, can't
  * get an interrupt when carrier is detected.
  */
-static void xm_link_timer(struct work_struct *work)
+static void xm_link_timer(unsigned long arg)
 {
-	struct skge_port *skge =
-		container_of(work, struct skge_port, link_thread.work);
+	struct skge_port *skge = (struct skge_port *) arg;
 	struct net_device *dev = skge->netdev;
  	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
@@ -1415,13 +1414,13 @@ static void xm_link_timer(struct work_st
 			goto nochange;
 	}
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock(&hw->phy_lock);
 	xm_check_link(dev);
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock(&hw->phy_lock);
 
 nochange:
 	if (netif_running(dev))
-		schedule_delayed_work(&skge->link_thread, LINK_HZ);
+		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -2324,7 +2323,7 @@ static void skge_phy_reset(struct skge_p
 	netif_stop_queue(skge->netdev);
 	netif_carrier_off(skge->netdev);
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&hw->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		genesis_reset(hw, port);
 		genesis_mac_init(hw, port);
@@ -2332,7 +2331,7 @@ static void skge_phy_reset(struct skge_p
 		yukon_reset(hw, port);
 		yukon_init(hw, port);
 	}
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&hw->phy_lock);
 
 	dev->set_multicast_list(dev);
 }
@@ -2355,12 +2354,12 @@ static int skge_ioctl(struct net_device 
 		/* fallthru */
 	case SIOCGMIIREG: {
 		u16 val = 0;
-		mutex_lock(&hw->phy_mutex);
+		spin_lock_bh(&hw->phy_lock);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = __xm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
 		else
 			err = __gm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
-		mutex_unlock(&hw->phy_mutex);
+		spin_unlock_bh(&hw->phy_lock);
 		data->val_out = val;
 		break;
 	}
@@ -2369,14 +2368,14 @@ static int skge_ioctl(struct net_device 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		mutex_lock(&hw->phy_mutex);
+		spin_lock_bh(&hw->phy_lock);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = xm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
 		else
 			err = gm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
-		mutex_unlock(&hw->phy_mutex);
+		spin_unlock_bh(&hw->phy_lock);
 		break;
 	}
 	return err;
@@ -2482,12 +2481,12 @@ static int skge_up(struct net_device *de
 		goto free_rx_ring;
 
 	/* Initialize MAC */
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&hw->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		genesis_mac_init(hw, port);
 	else
 		yukon_mac_init(hw, port);
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&hw->phy_lock);
 
 	/* Configure RAMbuffers */
 	chunk = hw->ram_size / ((hw->ports + 1)*2);
@@ -2537,7 +2536,7 @@ static int skge_down(struct net_device *
 
 	netif_stop_queue(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
-		cancel_delayed_work(&skge->link_thread);
+		del_timer_sync(&skge->link_timer);
 
 	netif_poll_disable(dev);
 
@@ -3173,28 +3172,29 @@ static void skge_error_irq(struct skge_h
 }
 
 /*
- * Interrupt from PHY are handled in work queue
+ * Interrupt from PHY are handled in tasklet (softirq)
  * because accessing phy registers requires spin wait which might
  * cause excess interrupt latency.
  */
-static void skge_extirq(struct work_struct *work)
+static void skge_extirq(unsigned long arg)
 {
-	struct skge_hw *hw = container_of(work, struct skge_hw, phy_work);
+	struct skge_hw *hw = (struct skge_hw *) arg;
 	int port;
 
-	mutex_lock(&hw->phy_mutex);
 	for (port = 0; port < hw->ports; port++) {
 		struct net_device *dev = hw->dev[port];
-		struct skge_port *skge = netdev_priv(dev);
 
 		if (netif_running(dev)) {
+			struct skge_port *skge = netdev_priv(dev);
+
+			spin_lock(&hw->phy_lock);
 			if (hw->chip_id != CHIP_ID_GENESIS)
 				yukon_phy_intr(skge);
 			else if (hw->phy_type == SK_PHY_BCOM)
 				bcom_phy_intr(skge);
+			spin_unlock(&hw->phy_lock);
 		}
 	}
-	mutex_unlock(&hw->phy_mutex);
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= IS_EXT_REG;
@@ -3219,7 +3219,7 @@ static irqreturn_t skge_intr(int irq, vo
 	status &= hw->intr_mask;
 	if (status & IS_EXT_REG) {
 		hw->intr_mask &= ~IS_EXT_REG;
-		schedule_work(&hw->phy_work);
+		tasklet_schedule(&hw->phy_task);
 	}
 
 	if (status & (IS_XA1_F|IS_R1_F)) {
@@ -3295,23 +3295,28 @@ static int skge_set_mac_address(struct n
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
-	/* disable Rx */
-	ctrl = gma_read16(hw, port, GM_GP_CTRL);
-	gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_RX_ENA);
+	if (!netif_running(dev)) {
+		memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
+		memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
+	} else {
+		/* disable Rx */
+		spin_lock_bh(&hw->phy_lock);
+		ctrl = gma_read16(hw, port, GM_GP_CTRL);
+		gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_RX_ENA);
 
-	memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
-	memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
+		memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
+		memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
 
-	if (netif_running(dev)) {
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			xm_outaddr(hw, port, XM_SA, dev->dev_addr);
 		else {
 			gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
 			gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
 		}
-	}
 
-	gma_write16(hw, port, GM_GP_CTRL, ctrl);
+		gma_write16(hw, port, GM_GP_CTRL, ctrl);
+		spin_unlock_bh(&hw->phy_lock);
+	}
 
 	return 0;
 }
@@ -3496,14 +3501,12 @@ static int skge_reset(struct skge_hw *hw
 
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 
-	mutex_lock(&hw->phy_mutex);
 	for (i = 0; i < hw->ports; i++) {
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			genesis_reset(hw, i);
 		else
 			yukon_reset(hw, i);
 	}
-	mutex_unlock(&hw->phy_mutex);
 
 	return 0;
 }
@@ -3551,6 +3554,7 @@ static struct net_device *skge_devinit(s
 	skge->netdev = dev;
 	skge->hw = hw;
 	skge->msg_enable = netif_msg_init(debug, default_msg);
+
 	skge->tx_ring.count = DEFAULT_TX_RING_SIZE;
 	skge->rx_ring.count = DEFAULT_RX_RING_SIZE;
 
@@ -3567,7 +3571,7 @@ static struct net_device *skge_devinit(s
 	skge->port = port;
 
 	/* Only used for Genesis XMAC */
-	INIT_DELAYED_WORK(&skge->link_thread, xm_link_timer);
+	setup_timer(&skge->link_timer, xm_link_timer, (unsigned long) skge);
 
 	if (hw->chip_id != CHIP_ID_GENESIS) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
@@ -3649,9 +3653,9 @@ static int __devinit skge_probe(struct p
 	}
 
 	hw->pdev = pdev;
-	mutex_init(&hw->phy_mutex);
-	INIT_WORK(&hw->phy_work, skge_extirq);
 	spin_lock_init(&hw->hw_lock);
+	spin_lock_init(&hw->phy_lock);
+	tasklet_init(&hw->phy_task, &skge_extirq, (unsigned long) hw);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -3737,6 +3741,8 @@ static void __devexit skge_remove(struct
 	dev0 = hw->dev[0];
 	unregister_netdev(dev0);
 
+	tasklet_disable(&hw->phy_task);
+
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask = 0;
 	skge_write32(hw, B0_IMSK, 0);
--- skge-dev.orig/drivers/net/skge.h
+++ skge-dev/drivers/net/skge.h
@@ -2424,8 +2424,8 @@ struct skge_hw {
 	u32	     	     ram_size;
 	u32	     	     ram_offset;
 	u16		     phy_addr;
-	struct work_struct   phy_work;
-	struct mutex	     phy_mutex;
+	spinlock_t	     phy_lock;
+	struct tasklet_struct phy_task;
 };
 
 enum pause_control {
@@ -2457,7 +2457,7 @@ struct skge_port {
 
 	struct net_device_stats net_stats;
 
-	struct delayed_work  link_thread;
+	struct timer_list    link_timer;
 	enum pause_control   flow_control;
 	enum pause_status    flow_status;
 	u8		     rx_csum;

-- 

