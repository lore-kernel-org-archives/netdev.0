From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2/7] 2.6.6-rc3-mm1 - r8169 janitoring
Date: Sat, 1 May 2004 02:25:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501022552.B500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <20040501022439.A500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501022439.A500@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:24:39AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Spring cleanup
- missing ULL qualifier;
- unsigned int (u32) should be slightly faster on ppc64 (Jon D Mason);
- misc minor de-uglyfication.


diff -puN drivers/net/r8169.c~r8169-janitorial drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-janitorial	2004-05-01 01:46:31.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:31.000000000 +0200
@@ -315,10 +315,10 @@ struct RxDesc {
 };
 
 struct rtl8169_private {
-	void *mmio_addr;	/* memory map physical address */
+	void *mmio_addr;		/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device  */
 	struct net_device_stats stats;	/* statistics of net device */
-	spinlock_t lock;	/* spin lock flag */
+	spinlock_t lock;		/* spin lock flag */
 	int chipset;
 	int mac_version;
 	int phy_version;
@@ -326,12 +326,12 @@ struct rtl8169_private {
 	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
 	u32 dirty_rx;
 	u32 dirty_tx;
-	struct TxDesc *TxDescArray;	/* Index of 256-alignment Tx Descriptor buffer */
-	struct RxDesc *RxDescArray;	/* Index of 256-alignment Rx Descriptor buffer */
+	struct TxDesc *TxDescArray;	/* 256-aligned Tx descriptor ring */
+	struct RxDesc *RxDescArray;	/* 256-aligned Rx descriptor ring */
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
 	struct sk_buff *Rx_skbuff[NUM_RX_DESC];	/* Rx data buffers */
-	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Index of Transmit data buffer */
+	struct sk_buff *Tx_skbuff[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
 	unsigned long phy_link_down_cnt;
 	u16 cp_cmd;
@@ -379,11 +379,9 @@ static void mdio_write(void *ioaddr, int
 
 	for (i = 2000; i > 0; i--) {
 		// Check if the RTL8169 has completed writing to the specified MII register
-		if (!(RTL_R32(PHYAR) & 0x80000000)) {
+		if (!(RTL_R32(PHYAR) & 0x80000000)) 
 			break;
-		} else {
-			udelay(100);
-		}
+		udelay(100);
 	}
 }
 
@@ -408,7 +406,7 @@ static int mdio_read(void *ioaddr, int R
 static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 
 	strcpy(info->driver, RTL8169_DRIVER_NAME);
 	strcpy(info->version, RTL8169_VERSION );
@@ -515,7 +513,7 @@ static void rtl8169_print_phy_version(st
 
 static void rtl8169_hw_phy_config(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	struct {
 		u16 regs[5]; /* Beware of bit-sign propagation */
@@ -583,7 +581,7 @@ static void rtl8169_hw_phy_config(struct
 
 static void rtl8169_hw_phy_reset(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i, val;
 
@@ -607,7 +605,7 @@ static void rtl8169_hw_phy_reset(struct 
 static void rtl8169_phy_timer(unsigned long __opaque)
 {
 	struct net_device *dev = (struct net_device *)__opaque;
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 	void *ioaddr = tp->mmio_addr;
 
@@ -635,7 +633,7 @@ static void rtl8169_phy_timer(unsigned l
 
 static inline void rtl8169_delete_timer(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
@@ -649,7 +647,7 @@ static inline void rtl8169_delete_timer(
 
 static inline void rtl8169_request_timer(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct timer_list *timer = &tp->timer;
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
@@ -696,7 +694,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 	// enable device (incl. PCI PM wakeup and hotplug setup)
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		printk(KERN_ERR PFX "%s: unable to enable device\n", pdev->slot_name);
+		printk(KERN_ERR PFX "%s: enable failure\n", pdev->slot_name);
 		goto err_out;
 	}
 
@@ -708,7 +706,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 		pci_read_config_word(pdev, pm_cap + PCI_PM_CTRL, &pwr_command);
 		acpi_idle_state = pwr_command & PCI_PM_CTRL_STATE_MASK;
 	} else {
-		printk(KERN_ERR PFX "Cannot find PowerManagement capability, aborting.\n");
+		printk(KERN_ERR PFX
+		       "Cannot find PowerManagement capability, aborting.\n");
 		goto err_out_free_res;
 	}
 
@@ -733,7 +732,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	rc = pci_request_regions(pdev, dev->name);
 	if (rc) {
-		printk(KERN_ERR PFX "%s: Could not request regions.\n", pdev->slot_name);
+		printk(KERN_ERR PFX "%s: could not request regions.\n",
+		       pdev->slot_name);
 		goto err_out_disable;
 	}
 
@@ -937,13 +937,16 @@ rtl8169_init_one(struct pci_dev *pdev, c
 			default:
 				break;
 			}
-			mdio_write(ioaddr, PHY_AUTO_NEGO_REG, Cap10_100 | (val & 0x1F));	//leave PHY_AUTO_NEGO_REG bit4:0 unchanged
+			// leave PHY_AUTO_NEGO_REG bit4:0 unchanged
+			mdio_write(ioaddr, PHY_AUTO_NEGO_REG,
+				   Cap10_100 | (val & 0x1F));
 			mdio_write(ioaddr, PHY_1000_CTRL_REG, Cap1000);
 		} else {
 			printk(KERN_INFO "%s: Auto-negotiation Enabled.\n",
 			       dev->name);
 
-			// enable 10/100 Full/Half Mode, leave PHY_AUTO_NEGO_REG bit4:0 unchanged
+			// enable 10/100 Full/Half Mode
+			// leave PHY_AUTO_NEGO_REG bit4:0 unchanged
 			mdio_write(ioaddr, PHY_AUTO_NEGO_REG,
 				   PHY_Cap_100_Full_Or_Less | (val & 0x1f));
 
@@ -982,7 +985,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 			} else {
 				udelay(100);
 			}
-		}		// end for-loop to wait for auto-negotiation process
+		}	// end for-loop to wait for auto-negotiation process
 
 	} else {
 		udelay(100);
@@ -990,7 +993,6 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		       "%s: 1000Mbps Full-duplex operation, TBI Link %s!\n",
 		       dev->name,
 		       (RTL_R32(TBICSR) & TBILinkOK) ? "OK" : "Failed");
-
 	}
 
 	return 0;
@@ -1000,7 +1002,7 @@ static void __devexit
 rtl8169_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -1019,7 +1021,7 @@ rtl8169_remove_one(struct pci_dev *pdev)
 static int rtl8169_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -1060,7 +1062,7 @@ static int rtl8169_resume(struct pci_dev
 static int
 rtl8169_open(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
 	int retval;
 
@@ -1109,7 +1111,7 @@ err_free_irq:
 static void
 rtl8169_hw_start(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 
@@ -1120,8 +1122,7 @@ rtl8169_hw_start(struct net_device *dev)
 	for (i = 1000; i > 0; i--) {
 		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
 			break;
-		else
-			udelay(10);
+		udelay(10);
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
@@ -1132,8 +1133,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W16(RxMaxSize, RxPacketMaxSize);
 
 	// Set Rx Config register
-	i = rtl8169_rx_config | (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].
-				 RxConfigMask);
+	i = rtl8169_rx_config |
+		(RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
 	RTL_W32(RxConfig, i);
 
 	/* Set DMA burst size and Interframe Gap Time */
@@ -1144,7 +1145,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
-		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0: bit-3 and bit-14 MUST be 1\n");
+		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
+			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14) | PCIMulRW;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 	}
@@ -1169,12 +1171,11 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W16(IntrMask, rtl8169_intr_mask);
 
 	netif_start_queue(dev);
-
 }
 
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
-	desc->addr = 0x0badbadbadbadbad;
+	desc->addr = 0x0badbadbadbadbadULL;
 	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
 }
 
@@ -1266,7 +1267,7 @@ static inline void rtl8169_mark_as_last_
 
 static int rtl8169_init_ring(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 
 	tp->cur_rx = tp->dirty_rx = 0;
 	tp->cur_tx = tp->dirty_tx = 0;
@@ -1320,10 +1321,11 @@ rtl8169_tx_clear(struct rtl8169_private 
 static void
 rtl8169_tx_timeout(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u8 tmp8;
 
+	printk(KERN_INFO "%s: TX Timeout\n", dev->name);
 	/* disable Tx, if not already */
 	tmp8 = RTL_R8(ChipCmd);
 	if (tmp8 & CmdTxEnb)
@@ -1346,9 +1348,9 @@ rtl8169_tx_timeout(struct net_device *de
 static int
 rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
-	int entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int entry = tp->cur_tx % NUM_TX_DESC;
 	u32 len = skb->len;
 
 	if (unlikely(skb->len < ETH_ZLEN)) {
@@ -1400,7 +1402,7 @@ static void
 rtl8169_tx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void *ioaddr)
 {
-	unsigned long dirty_tx, tx_left;
+	unsigned int dirty_tx, tx_left;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -1410,7 +1412,7 @@ rtl8169_tx_interrupt(struct net_device *
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
-		int entry = dirty_tx % NUM_TX_DESC;
+		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct sk_buff *skb = tp->Tx_skbuff[entry];
 		u32 status;
 
@@ -1476,7 +1478,7 @@ rtl8169_rx_interrupt(struct net_device *
 	rx_left = rtl8169_rx_quota(rx_left, (u32) dev->quota);
 
 	while (rx_left > 0) {
-		int entry = cur_rx % NUM_RX_DESC;
+		unsigned int entry = cur_rx % NUM_RX_DESC;
 		u32 status;
 
 		rmb();
@@ -1552,7 +1554,7 @@ static irqreturn_t
 rtl8169_interrupt(int irq, void *dev_instance, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
 	int status = 0;
@@ -1646,7 +1648,7 @@ static int rtl8169_poll(struct net_devic
 static int
 rtl8169_close(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
 	void *ioaddr = tp->mmio_addr;
 
@@ -1688,7 +1690,7 @@ rtl8169_close(struct net_device *dev)
 static void
 rtl8169_set_rx_mode(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 	u32 mc_filter[2];	/* Multicast hash filter */
@@ -1722,10 +1724,8 @@ rtl8169_set_rx_mode(struct net_device *d
 
 	spin_lock_irqsave(&tp->lock, flags);
 
-	tmp =
-	    rtl8169_rx_config | rx_mode | (RTL_R32(RxConfig) &
-					   rtl_chip_info[tp->chipset].
-					   RxConfigMask);
+	tmp = rtl8169_rx_config | rx_mode |
+	      (RTL_R32(RxConfig) & rtl_chip_info[tp->chipset].RxConfigMask);
 
 	RTL_W32(RxConfig, tmp);
 	RTL_W32(MAR0 + 0, mc_filter[0]);
@@ -1742,7 +1742,7 @@ rtl8169_set_rx_mode(struct net_device *d
  */
 static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 {
-	struct rtl8169_private *tp = dev->priv;
+	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 

_
