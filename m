From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: set mac address bonding fix
Date: Mon, 12 Mar 2007 16:18:58 -0700
Message-ID: <20070312161858.5fea9e63@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
	<20070308113427.6344a7f6@freekitty>
	<Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
	<20070308134811.38a8ec81@freekitty>
	<Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
	<23552.1173395045@death>
	<Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
	<Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
	<20070312151626.60d00e30@dxpl.pdx.osdl.net>
	<Pine.LNX.4.64.0703121527320.25767@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:49705 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbXCLXWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 19:22:20 -0400
In-Reply-To: <Pine.LNX.4.64.0703121527320.25767@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> * modprobe bonding miimon=100 mode=active-backup
>    modprobe skge
>    ifconfig bond0 up
>    ifenslave bond0 eth2 eth3
>    ifenslave -d bond0 eth2 eth3
> 
> That hangs the machine.  No output on serial console.  I have to power 
> cycle to restore access.
> 
> * modprobe skge
>    ifconfig eth2 up
>    ifconfig eth3 up
>    ifconfig eth3 down
>    ifconfig eth2 down

Sounds like a dual-port only problem.. Unfortunately, I don't have actual
dual port skge hardware to test.  Try this:



--- test.orig/drivers/net/skge.c
+++ test/drivers/net/skge.c
@@ -671,7 +671,7 @@ static void skge_led(struct skge_port *s
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&skge->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		switch (mode) {
 		case LED_MODE_OFF:
@@ -742,7 +742,7 @@ static void skge_led(struct skge_port *s
 				     PHY_M_LED_MO_RX(MO_LED_ON));
 		}
 	}
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&skge->phy_lock);
 }
 
 /* blink LED's for finding board */
@@ -1316,7 +1316,7 @@ static void xm_phy_init(struct skge_port
 	xm_phy_write(hw, port, PHY_XMAC_CTRL, ctrl);
 
 	/* Poll PHY for status changes */
-	schedule_delayed_work(&skge->link_thread, LINK_HZ);
+	mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static void xm_check_link(struct net_device *dev)
@@ -1391,10 +1391,9 @@ static void xm_check_link(struct net_dev
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
@@ -1414,13 +1413,13 @@ static void xm_link_timer(struct work_st
 			goto nochange;
 	}
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock(&skge->phy_lock);
 	xm_check_link(dev);
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock(&skge->phy_lock);
 
 nochange:
 	if (netif_running(dev))
-		schedule_delayed_work(&skge->link_thread, LINK_HZ);
+		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -2323,7 +2322,7 @@ static void skge_phy_reset(struct skge_p
 	netif_stop_queue(skge->netdev);
 	netif_carrier_off(skge->netdev);
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&skge->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		genesis_reset(hw, port);
 		genesis_mac_init(hw, port);
@@ -2331,7 +2330,7 @@ static void skge_phy_reset(struct skge_p
 		yukon_reset(hw, port);
 		yukon_init(hw, port);
 	}
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&skge->phy_lock);
 
 	dev->set_multicast_list(dev);
 }
@@ -2354,12 +2353,12 @@ static int skge_ioctl(struct net_device 
 		/* fallthru */
 	case SIOCGMIIREG: {
 		u16 val = 0;
-		mutex_lock(&hw->phy_mutex);
+		spin_lock_bh(&skge->phy_lock);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = __xm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
 		else
 			err = __gm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
-		mutex_unlock(&hw->phy_mutex);
+		spin_unlock_bh(&skge->phy_lock);
 		data->val_out = val;
 		break;
 	}
@@ -2368,14 +2367,14 @@ static int skge_ioctl(struct net_device 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		mutex_lock(&hw->phy_mutex);
+		spin_lock_bh(&skge->phy_lock);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = xm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
 		else
 			err = gm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
-		mutex_unlock(&hw->phy_mutex);
+		spin_unlock_bh(&skge->phy_lock);
 		break;
 	}
 	return err;
@@ -2481,12 +2480,12 @@ static int skge_up(struct net_device *de
 		goto free_rx_ring;
 
 	/* Initialize MAC */
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&skge->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		genesis_mac_init(hw, port);
 	else
 		yukon_mac_init(hw, port);
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&skge->phy_lock);
 
 	/* Configure RAMbuffers */
 	chunk = hw->ram_size / ((hw->ports + 1)*2);
@@ -2531,7 +2530,7 @@ static int skge_down(struct net_device *
 
 	netif_stop_queue(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
-		cancel_delayed_work(&skge->link_thread);
+		del_timer_sync(&skge->link_timer);
 
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	if (hw->chip_id == CHIP_ID_GENESIS)
@@ -3160,28 +3159,29 @@ static void skge_error_irq(struct skge_h
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
+			spin_lock(&skge->phy_lock);
 			if (hw->chip_id != CHIP_ID_GENESIS)
 				yukon_phy_intr(skge);
 			else if (hw->phy_type == SK_PHY_BCOM)
 				bcom_phy_intr(skge);
+			spin_unlock(&skge->phy_lock);
 		}
 	}
-	mutex_unlock(&hw->phy_mutex);
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= IS_EXT_REG;
@@ -3206,7 +3206,7 @@ static irqreturn_t skge_intr(int irq, vo
 	status &= hw->intr_mask;
 	if (status & IS_EXT_REG) {
 		hw->intr_mask &= ~IS_EXT_REG;
-		schedule_work(&hw->phy_work);
+		tasklet_schedule(&hw->ext_task);
 	}
 
 	if (status & (IS_XA1_F|IS_R1_F)) {
@@ -3484,14 +3484,12 @@ static int skge_reset(struct skge_hw *hw
 
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
@@ -3539,6 +3537,8 @@ static struct net_device *skge_devinit(s
 	skge->netdev = dev;
 	skge->hw = hw;
 	skge->msg_enable = netif_msg_init(debug, default_msg);
+	spin_lock_init(&skge->phy_lock);
+
 	skge->tx_ring.count = DEFAULT_TX_RING_SIZE;
 	skge->rx_ring.count = DEFAULT_RX_RING_SIZE;
 
@@ -3555,7 +3555,7 @@ static struct net_device *skge_devinit(s
 	skge->port = port;
 
 	/* Only used for Genesis XMAC */
-	INIT_DELAYED_WORK(&skge->link_thread, xm_link_timer);
+	setup_timer(&skge->link_timer, xm_link_timer, (unsigned long) skge);
 
 	if (hw->chip_id != CHIP_ID_GENESIS) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
@@ -3637,9 +3637,8 @@ static int __devinit skge_probe(struct p
 	}
 
 	hw->pdev = pdev;
-	mutex_init(&hw->phy_mutex);
-	INIT_WORK(&hw->phy_work, skge_extirq);
 	spin_lock_init(&hw->hw_lock);
+	tasklet_init(&hw->ext_task, &skge_extirq, (unsigned long) hw);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -3725,6 +3724,8 @@ static void __devexit skge_remove(struct
 	dev0 = hw->dev[0];
 	unregister_netdev(dev0);
 
+	tasklet_disable(&hw->ext_task);
+
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask = 0;
 	skge_write32(hw, B0_IMSK, 0);
--- test.orig/drivers/net/skge.h
+++ test/drivers/net/skge.h
@@ -2412,6 +2412,7 @@ struct skge_hw {
 	void __iomem  	     *regs;
 	struct pci_dev	     *pdev;
 	spinlock_t	     hw_lock;
+	struct tasklet_struct ext_task;
 	u32		     intr_mask;
 	struct net_device    *dev[2];
 
@@ -2424,8 +2425,6 @@ struct skge_hw {
 	u32	     	     ram_size;
 	u32	     	     ram_offset;
 	u16		     phy_addr;
-	struct work_struct   phy_work;
-	struct mutex	     phy_mutex;
 };
 
 enum pause_control {
@@ -2447,17 +2446,18 @@ enum pause_status {
 
 
 struct skge_port {
-	u32		     msg_enable;
 	struct skge_hw	     *hw;
 	struct net_device    *netdev;
 	int		     port;
+	u32		     msg_enable;
+	spinlock_t	     phy_lock;
 
 	struct skge_ring     tx_ring;
 	struct skge_ring     rx_ring;
 
 	struct net_device_stats net_stats;
 
-	struct delayed_work  link_thread;
+	struct timer_list    link_timer;
 	enum pause_control   flow_control;
 	enum pause_status    flow_status;
 	u8		     rx_csum;
