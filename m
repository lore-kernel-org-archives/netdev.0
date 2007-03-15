From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 15 Mar 2007 15:56:50 -0400
Message-ID: <20070315195650.GA29332@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933606AbXCOT4y@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/natsemi.c                   |   58 ++++++++++++++++--------------
 drivers/net/netxen/netxen_nic.h         |    1 +
 drivers/net/netxen/netxen_nic_ethtool.c |    1 +
 drivers/net/netxen/netxen_nic_hw.c      |    5 ++-
 drivers/net/netxen/netxen_nic_init.c    |   11 +++++-
 drivers/net/skge.c                      |   28 +++++++++------
 6 files changed, 63 insertions(+), 41 deletions(-)

broonie@sirena.org.uk (3):
      natsemi: Consistently use interrupt enable/disable functions
      natsemi: Fix NAPI for interrupt sharing
      natsemi: Avoid IntrStatus lossage if RX state machine resets.

Linsys Contractor Mithlesh Thukral (2):
      NetXen: Bug fix for Jumbo frames on XG card
      NetXen: Fix softlockup seen during hardware access

Stephen Hemminger (1):
      skge: set mac address bonding fix

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index c6172a7..349b96a 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -1712,7 +1712,7 @@ static void init_registers(struct net_device *dev)
 
 	/* Enable interrupts by setting the interrupt mask. */
 	writel(DEFAULT_INTR, ioaddr + IntrMask);
-	writel(1, ioaddr + IntrEnable);
+	natsemi_irq_enable(dev);
 
 	writel(RxOn | TxOn, ioaddr + ChipCmd);
 	writel(StatsClear, ioaddr + StatsCtrl); /* Clear Stats */
@@ -2119,28 +2119,35 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 
-	if (np->hands_off)
+	/* Reading IntrStatus automatically acknowledges so don't do
+	 * that while interrupts are disabled, (for example, while a
+	 * poll is scheduled).  */
+	if (np->hands_off || !readl(ioaddr + IntrEnable))
 		return IRQ_NONE;
 
-	/* Reading automatically acknowledges. */
 	np->intr_status = readl(ioaddr + IntrStatus);
 
+	if (!np->intr_status)
+		return IRQ_NONE;
+
 	if (netif_msg_intr(np))
 		printk(KERN_DEBUG
 		       "%s: Interrupt, status %#08x, mask %#08x.\n",
 		       dev->name, np->intr_status,
 		       readl(ioaddr + IntrMask));
 
-	if (!np->intr_status)
-		return IRQ_NONE;
-
 	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
 
 	if (netif_rx_schedule_prep(dev)) {
 		/* Disable interrupts and register for poll */
 		natsemi_irq_disable(dev);
 		__netif_rx_schedule(dev);
-	}
+	} else
+		printk(KERN_WARNING
+	       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
+		       dev->name, np->intr_status,
+		       readl(ioaddr + IntrMask));
+
 	return IRQ_HANDLED;
 }
 
@@ -2156,6 +2163,20 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 	int work_done = 0;
 
 	do {
+		if (netif_msg_intr(np))
+			printk(KERN_DEBUG
+			       "%s: Poll, status %#08x, mask %#08x.\n",
+			       dev->name, np->intr_status,
+			       readl(ioaddr + IntrMask));
+
+		/* netdev_rx() may read IntrStatus again if the RX state
+		 * machine falls over so do it first. */
+		if (np->intr_status &
+		    (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
+		     IntrRxErr | IntrRxOverrun)) {
+			netdev_rx(dev, &work_done, work_to_do);
+		}
+
 		if (np->intr_status &
 		    (IntrTxDone | IntrTxIntr | IntrTxIdle | IntrTxErr)) {
 			spin_lock(&np->lock);
@@ -2167,12 +2188,6 @@ static int natsemi_poll(struct net_device *dev, int *budget)
 		if (np->intr_status & IntrAbnormalSummary)
 			netdev_error(dev, np->intr_status);
 
-		if (np->intr_status &
-		    (IntrRxDone | IntrRxIntr | RxStatusFIFOOver |
-		     IntrRxErr | IntrRxOverrun)) {
-			netdev_rx(dev, &work_done, work_to_do);
-		}
-
 		*budget -= work_done;
 		dev->quota -= work_done;
 
@@ -2399,19 +2414,8 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void natsemi_poll_controller(struct net_device *dev)
 {
-	struct netdev_private *np = netdev_priv(dev);
-
 	disable_irq(dev->irq);
-
-	/*
-	 * A real interrupt might have already reached us at this point
-	 * but NAPI might still haven't called us back.  As the interrupt
-	 * status register is cleared by reading, we should prevent an
-	 * interrupt loss in this case...
-	 */
-	if (!np->intr_status)
-		intr_handler(dev->irq, dev);
-
+	intr_handler(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
@@ -3071,7 +3075,7 @@ static void enable_wol_mode(struct net_device *dev, int enable_intr)
 		 * Could be used to send a netlink message.
 		 */
 		writel(WOLPkt | LinkChange, ioaddr + IntrMask);
-		writel(1, ioaddr + IntrEnable);
+		natsemi_irq_enable(dev);
 	}
 }
 
@@ -3202,7 +3206,7 @@ static int natsemi_suspend (struct pci_dev *pdev, pm_message_t state)
 		disable_irq(dev->irq);
 		spin_lock_irq(&np->lock);
 
-		writel(0, ioaddr + IntrEnable);
+		natsemi_irq_disable(dev);
 		np->hands_off = 1;
 		natsemi_stop_rxtx(dev);
 		netif_stop_queue(dev);
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 81742e4..dd8ce35 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -232,6 +232,7 @@ enum {
 #define MPORT_SINGLE_FUNCTION_MODE 0x1111
 
 extern unsigned long long netxen_dma_mask;
+extern unsigned long last_schedule_time;
 
 /*
  * NetXen host-peg signal message structure
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 986ef98..ee1b5a2 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -462,6 +462,7 @@ netxen_nic_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		}
 		printk(KERN_INFO "%s: flash unlocked. \n", 
 			netxen_nic_driver_name);
+		last_schedule_time = jiffies;
 		ret = netxen_flash_erase_secondary(adapter);
 		if (ret != FLASH_SUCCESS) {
 			printk(KERN_ERR "%s: Flash erase failed.\n", 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 1be5570..6537574 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -822,7 +822,10 @@ int netxen_nic_set_mtu_xgb(struct netxen_port *port, int new_mtu)
 {
 	struct netxen_adapter *adapter = port->adapter;
 	new_mtu += NETXEN_NIU_HDRSIZE + NETXEN_NIU_TLRSIZE;
-	netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
+	if (port->portnum == 0)
+	    netxen_nic_write_w0(adapter, NETXEN_NIU_XGE_MAX_FRAME_SIZE, new_mtu);
+	else if (port->portnum == 1)
+	    netxen_nic_write_w0(adapter, NETXEN_NIU_XG1_MAX_FRAME_SIZE, new_mtu);
 	return 0;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 586d32b..229aa1c 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -42,6 +42,8 @@ struct crb_addr_pair {
 	u32 data;
 };
 
+unsigned long last_schedule_time;
+
 #define NETXEN_MAX_CRB_XFORM 60
 static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
 #define NETXEN_ADDR_ERROR (0xffffffff)
@@ -404,9 +406,14 @@ static inline int do_rom_fast_write(struct netxen_adapter *adapter, int addr,
 static inline int
 do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 {
+	if (jiffies > (last_schedule_time + (8 * HZ))) {
+		last_schedule_time = jiffies;
+		schedule();
+	}
+
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
-	udelay(70);		/* prevent bursting on CRB */
+	udelay(100);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_INSTR_OPCODE, 0xb);
 	if (netxen_wait_rom_done(adapter)) {
@@ -415,7 +422,7 @@ do_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp)
 	}
 	/* reset abyte_cnt and dummy_byte_cnt */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 0);
-	udelay(70);		/* prevent bursting on CRB */
+	udelay(100);		/* prevent bursting on CRB */
 	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
 
 	*valp = netxen_nic_reg_read(adapter, NETXEN_ROMUSB_ROM_RDATA);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index eea75a4..8fecf1b 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3275,24 +3275,30 @@ static int skge_set_mac_address(struct net_device *dev, void *p)
 	struct skge_hw *hw = skge->hw;
 	unsigned port = skge->port;
 	const struct sockaddr *addr = p;
+	u16 ctrl;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	mutex_lock(&hw->phy_mutex);
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
-	memcpy_toio(hw->regs + B2_MAC_1 + port*8,
-		    dev->dev_addr, ETH_ALEN);
-	memcpy_toio(hw->regs + B2_MAC_2 + port*8,
-		    dev->dev_addr, ETH_ALEN);
 
-	if (hw->chip_id == CHIP_ID_GENESIS)
-		xm_outaddr(hw, port, XM_SA, dev->dev_addr);
-	else {
-		gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
-		gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
+	/* disable Rx */
+	ctrl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_RX_ENA);
+
+	memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
+	memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
+
+	if (netif_running(dev)) {
+		if (hw->chip_id == CHIP_ID_GENESIS)
+			xm_outaddr(hw, port, XM_SA, dev->dev_addr);
+		else {
+			gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
+			gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
+		}
 	}
-	mutex_unlock(&hw->phy_mutex);
+
+	gma_write16(hw, port, GM_GP_CTRL, ctrl);
 
 	return 0;
 }
