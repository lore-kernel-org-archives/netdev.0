From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: [PATCH]: r8169: Message level support
Date: Sat, 26 Feb 2005 17:11:02 +0000
Message-ID: <4220ADA6.2040506@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050907010104070002090802"
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050907010104070002090802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello.

The attached patch against 2.6.11-rc5 adds support for setting the 
message level, which controls which messages are actually printk()'d. 
Changes:

* A module option "debug". This option is a bitfield of message options, 
like 8139cp's "debug" parameter.

* Support "ethtool -s ... msglvl". This sets the bitfield.

* Various debug messages are now enabled on NETIF_MSG_HW and are printed 
using KERN_DEBUG.

* Messages are printed when the interface goes up or down.

There seems to be a mixture of drivers using a bitfield and a level. 
Which is the currently preferred mechanism?

Bye, Rich =]

Signed-Off-By: Richard Dawe <rich@phekda.gotadsl.co.uk>

--------------050907010104070002090802
Content-Type: text/plain;
 name="r8169-netif-msg.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169-netif-msg.diff"

--- linux-2.6.11-rc5/drivers/net/r8169.c.orig	2005-02-24 16:40:30.000000000 +0000
+++ linux-2.6.11-rc5/drivers/net/r8169.c	2005-02-26 16:49:16.000000000 +0000
@@ -79,12 +79,14 @@ VERSION 2.2LK	<2005/01/25>
 	        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
         	#expr,__FILE__,__FUNCTION__,__LINE__);		\
         }
-#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
 #else
 #define assert(expr) do {} while (0)
-#define dprintk(fmt, args...)	do {} while (0)
 #endif /* RTL8169_DEBUG */
 
+#define DPRINTK(nlevel, klevel, fmt, args...) \
+	(void)((NETIF_MSG_##nlevel & tp->msg_enable) && \
+	printk(KERN_##klevel PFX "%s: " fmt, dev->name, ## args))
+
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
 
@@ -132,6 +134,10 @@ static int multicast_filter_limit = 32;
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
+#define RTL8169_DEF_MSG_ENABLE (NETIF_MSG_DRV		| \
+				NETIF_MSG_PROBE		| \
+				NETIF_MSG_LINK)
+
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
 #define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
@@ -407,6 +413,7 @@ struct rtl8169_private {
 #ifdef CONFIG_R8169_VLAN
 	struct vlan_group *vlgrp;
 #endif
+	u32 msg_enable;
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
@@ -421,6 +428,9 @@ module_param_array(media, int, &num_medi
 module_param(rx_copybreak, int, 0);
 module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
+static int debug = RTL8169_DEF_MSG_ENABLE;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Bitmapped message enable number");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
@@ -433,10 +443,10 @@ static void rtl8169_hw_start(struct net_
 static int rtl8169_close(struct net_device *dev);
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
-static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
+static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
-static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 
 #ifdef CONFIG_R8169_NAPI
@@ -543,14 +553,15 @@ static void rtl8169_check_link_status(st
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		netif_carrier_on(dev);
-		printk(KERN_INFO PFX "%s: link up\n", dev->name);
+		DPRINTK(LINK, INFO, "link up\n");
 	} else
 		netif_carrier_off(dev);
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
+static void rtl8169_link_option(struct net_device *dev, int idx, u8 *autoneg, u16 *speed, u8 *duplex)
 {
+	struct rtl8169_private *tp = netdev_priv(dev);
 	struct {
 		u16 speed;
 		u8 duplex;
@@ -570,7 +581,7 @@ static void rtl8169_link_option(int idx,
 	option = ((idx < MAX_UNITS) && (idx >= 0)) ? media[idx] : 0xff;
 
 	if ((option != 0xff) && !idx)
-		printk(KERN_WARNING PFX "media option is deprecated.\n");
+		DPRINTK(DRV, WARNING, "media option is deprecated.\n");
 
 	for (p = link_settings; p->media != 0xff; p++) {
 		if (p->media == option)
@@ -611,9 +622,8 @@ static int rtl8169_set_speed_tbi(struct 
 	} else if (autoneg == AUTONEG_ENABLE)
 		RTL_W32(TBICSR, reg | TBINwEnable | TBINwRestart);
 	else {
-		printk(KERN_WARNING PFX
-		       "%s: incorrect speed setting refused in TBI mode\n",
-		       dev->name);
+		DPRINTK(LINK, WARNING,
+		       "incorrect speed setting refused in TBI mode\n");
 		ret = -EOPNOTSUPP;
 	}
 
@@ -871,6 +881,18 @@ static void rtl8169_get_regs(struct net_
         spin_unlock_irqrestore(&tp->lock, flags);
 }
 
+static u32 r8169_get_msglevel(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	return tp->msg_enable;
+}
+
+static void r8169_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	tp->msg_enable = value;
+}
+
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
 	.get_regs_len		= rtl8169_get_regs_len,
@@ -886,6 +908,8 @@ static struct ethtool_ops rtl8169_ethtoo
 	.get_tso		= ethtool_op_get_tso,
 	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= rtl8169_get_regs,
+	.get_msglevel		= r8169_get_msglevel,
+	.set_msglevel		= r8169_set_msglevel,
 };
 
 static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum,
@@ -932,12 +956,15 @@ static void rtl8169_print_mac_version(st
 
 	for (p = mac_print; p->msg; p++) {
 		if (tp->mac_version == p->version) {
-			dprintk("mac_version == %s (%04d)\n", p->msg,
-				  p->version);
+			if (netif_msg_hw(tp))
+				printk(KERN_DEBUG
+				       "mac_version == %s (%04d)\n",
+				       p->msg, p->version);
 			return;
 		}
 	}
-	dprintk("mac_version == Unknown\n");
+	if (netif_msg_hw(tp))
+		printk(KERN_DEBUG "mac_version == Unknown\n");
 }
 
 static void rtl8169_get_phy_version(struct rtl8169_private *tp, void __iomem *ioaddr)
@@ -976,11 +1003,15 @@ static void rtl8169_print_phy_version(st
 
 	for (p = phy_print; p->msg; p++) {
 		if (tp->phy_version == p->version) {
-			dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
+			if (netif_msg_hw(tp))
+				printk(KERN_DEBUG
+				       "phy_version == %s (%04x)\n",
+				       p->msg, p->reg);
 			return;
 		}
 	}
-	dprintk("phy_version == Unknown\n");
+	if (netif_msg_hw(tp))
+		printk(KERN_DEBUG "phy_version == Unknown\n");
 }
 
 static void rtl8169_hw_phy_config(struct net_device *dev)
@@ -1027,8 +1058,8 @@ static void rtl8169_hw_phy_config(struct
 	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
 		return;
 
-	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
-	dprintk("Do final_reg2.cfg\n");
+	DPRINTK(HW, DEBUG, "MAC version != 0 && PHY version == 0 or 1\n");
+	DPRINTK(HW, DEBUG, "Do final_reg2.cfg\n");
 
 	/* Shazam ! */
 
@@ -1091,7 +1122,7 @@ static void rtl8169_phy_timer(unsigned l
 	if (tp->link_ok(ioaddr))
 		goto out_unlock;
 
-	printk(KERN_WARNING PFX "%s: PHY reset until link up\n", dev->name);
+	DPRINTK(LINK, WARNING, "PHY reset until link up\n");
 
 	tp->phy_reset_enable(ioaddr);
 
@@ -1169,7 +1200,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 	/* dev zeroed in alloc_etherdev */
 	dev = alloc_etherdev(sizeof (*tp));
 	if (dev == NULL) {
-		printk(KERN_ERR PFX "unable to alloc new ethernet\n");
+		if (debug & NETIF_MSG_PROBE)
+			printk(KERN_ERR PFX "unable to alloc new ethernet\n");
 		goto err_out;
 	}
 
@@ -1177,10 +1209,15 @@ rtl8169_init_board(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
 
+	tp->msg_enable = debug;
+
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		printk(KERN_ERR PFX "%s: enable failure\n", pdev->slot_name);
+		if (netif_msg_probe(tp))
+			printk(KERN_ERR PFX
+			       "%s: enable failure\n",
+			       pdev->slot_name);
 		goto err_out_free_dev;
 	}
 
@@ -1196,29 +1233,35 @@ rtl8169_init_board(struct pci_dev *pdev,
 		pci_read_config_word(pdev, pm_cap + PCI_PM_CTRL, &pwr_command);
 		acpi_idle_state = pwr_command & PCI_PM_CTRL_STATE_MASK;
 	} else {
-		printk(KERN_ERR PFX
-		       "Cannot find PowerManagement capability, aborting.\n");
+		if (netif_msg_probe(tp))
+			printk(KERN_ERR PFX
+			       "Cannot find PowerManagement capability, aborting.\n");
 		goto err_out_mwi;
 	}
 
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX
-		       "region #1 not an MMIO resource, aborting\n");
+		if (netif_msg_probe(tp))
+			printk(KERN_ERR PFX
+			       "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out_mwi;
 	}
 	/* check for weird/broken PCI region reporting */
 	if (pci_resource_len(pdev, 1) < R8169_REGS_SIZE) {
-		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
+		if (netif_msg_probe(tp))
+			printk(KERN_ERR PFX
+			       "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out_mwi;
 	}
 
 	rc = pci_request_regions(pdev, MODULENAME);
 	if (rc) {
-		printk(KERN_ERR PFX "%s: could not request regions.\n",
-		       pdev->slot_name);
+		if (netif_msg_probe(tp))
+			printk(KERN_ERR PFX
+			       "%s: could not request regions.\n",
+			       pdev->slot_name);
 		goto err_out_mwi;
 	}
 
@@ -1231,7 +1274,9 @@ rtl8169_init_board(struct pci_dev *pdev,
 	} else {
 		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc < 0) {
-			printk(KERN_ERR PFX "DMA configuration failed.\n");
+			if (netif_msg_probe(tp))
+				printk(KERN_ERR PFX
+				       "DMA configuration failed.\n");
 			goto err_out_free_res;
 		}
 	}
@@ -1241,7 +1286,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, 1), R8169_REGS_SIZE);
 	if (ioaddr == NULL) {
-		printk(KERN_ERR PFX "cannot remap MMIO, aborting\n");
+		if (netif_msg_probe(tp))
+			printk(KERN_ERR PFX "cannot remap MMIO, aborting\n");
 		rc = -EIO;
 		goto err_out_free_res;
 	}
@@ -1272,9 +1318,10 @@ rtl8169_init_board(struct pci_dev *pdev,
 	}
 	if (i < 0) {
 		/* Unknown chip: assume array element #0, original RTL-8169 */
-		printk(KERN_DEBUG PFX
-		       "PCI device %s: unknown chip version, assuming %s\n",
-		       pci_name(pdev), rtl_chip_info[0].name);
+		if (netif_msg_probe(tp))
+			printk(KERN_DEBUG PFX
+			       "PCI device %s: unknown chip version, assuming %s\n",
+			       pci_name(pdev), rtl_chip_info[0].name);
 		i++;
 	}
 	tp->chipset = i;
@@ -1391,39 +1438,40 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		return rc;
 	}
 
-	printk(KERN_DEBUG "%s: Identified chip type is '%s'.\n", dev->name,
-	       rtl_chip_info[tp->chipset].name);
+	DPRINTK(PROBE, DEBUG,
+		"Identified chip type is '%s'.\n",
+		rtl_chip_info[tp->chipset].name);
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: %s at 0x%lx, "
-	       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-	       "IRQ %d\n",
-	       dev->name,
-	       rtl_chip_info[ent->driver_data].name,
-	       dev->base_addr,
-	       dev->dev_addr[0], dev->dev_addr[1],
-	       dev->dev_addr[2], dev->dev_addr[3],
-	       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
+	DPRINTK(PROBE, INFO,
+		"%s at 0x%lx, "
+		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
+		"IRQ %d\n",
+		rtl_chip_info[ent->driver_data].name,
+		dev->base_addr,
+		dev->dev_addr[0], dev->dev_addr[1],
+		dev->dev_addr[2], dev->dev_addr[3],
+		dev->dev_addr[4], dev->dev_addr[5], dev->irq);
 
 	rtl8169_hw_phy_config(dev);
 
-	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+	DPRINTK(HW, DEBUG, "Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 	RTL_W8(0x82, 0x01);
 
 	if (tp->mac_version < RTL_GIGA_MAC_VER_E) {
-		dprintk("Set PCI Latency=0x40\n");
+		DPRINTK(HW, DEBUG, "Set PCI Latency=0x40\n");
 		pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0x40);
 	}
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
-		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+		DPRINTK(HW, DEBUG, "Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
 		RTL_W8(0x82, 0x01);
-		dprintk("Set PHY Reg 0x0bh = 0x00h\n");
+		DPRINTK(HW, DEBUG, "Set PHY Reg 0x0bh = 0x00h\n");
 		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
-	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
+	rtl8169_link_option(dev, board_idx, &autoneg, &speed, &duplex);
 
 	rtl8169_set_speed(dev, autoneg, speed, duplex);
 	
@@ -1504,6 +1552,8 @@ static int rtl8169_open(struct net_devic
 	struct pci_dev *pdev = tp->pci_dev;
 	int retval;
 
+	DPRINTK(IFUP, DEBUG, "enabling interface\n");
+
 	rtl8169_set_rxbufsize(tp, dev);
 
 	retval =
@@ -1602,7 +1652,8 @@ rtl8169_hw_start(struct net_device *dev)
 
 	if ((tp->mac_version == RTL_GIGA_MAC_VER_D) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_E)) {
-		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
+		DPRINTK(HW, DEBUG,
+			"Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14) | PCIMulRW;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
@@ -1857,8 +1908,12 @@ static void rtl8169_reinit_task(void *_d
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
 		if (net_ratelimit()) {
-			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
-			       " Rescheduling.\n", dev->name, ret);
+			struct rtl8169_private *tp = netdev_priv(dev);
+
+			DPRINTK(TIMER, ERR,
+				"reinit failure (status = %d)."
+				" Rescheduling.\n",
+				ret);
 		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
 	}
@@ -1883,8 +1938,7 @@ static void rtl8169_reset_task(void *_da
 		netif_wake_queue(dev);
 	} else {
 		if (net_ratelimit()) {
-			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
-			       dev->name);
+			DPRINTK(TX_ERR, EMERG, "Rx buffers shortage\n");
 		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
 	}
@@ -1970,8 +2024,7 @@ static int rtl8169_start_xmit(struct sk_
 	int ret = 0;
 	
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
+		DPRINTK(TX_ERR, ERR, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop;
 	}
 
@@ -2046,8 +2099,9 @@ static void rtl8169_pcierr_interrupt(str
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
 	pci_read_config_word(pdev, PCI_STATUS, &pci_status);
 
-	printk(KERN_ERR PFX "%s: PCI error (cmd = 0x%04x, status = 0x%04x).\n",
-	       dev->name, pci_cmd, pci_status);
+	DPRINTK(INTR, ERR,
+		"PCI error (cmd = 0x%04x, status = 0x%04x).\n",
+		pci_cmd, pci_status);
 
 	/*
 	 * The recovery sequence below admits a very elaborated explanation:
@@ -2066,7 +2120,7 @@ static void rtl8169_pcierr_interrupt(str
 
 	/* The infamous DAC f*ckup only happens at boot time */
 	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
-		printk(KERN_INFO PFX "%s: disabling PCI DAC.\n", dev->name);
+		DPRINTK(INTR, INFO, "disabling PCI DAC.\n");
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 		dev->features &= ~NETIF_F_HIGHDMA;
@@ -2182,7 +2236,7 @@ rtl8169_rx_interrupt(struct net_device *
 		if (status & DescOwn)
 			break;
 		if (status & RxRES) {
-			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);
+			DPRINTK(RX_ERR, INFO, "Rx ERROR!!!\n");
 			tp->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
 				tp->stats.rx_length_errors++;
@@ -2231,7 +2285,7 @@ rtl8169_rx_interrupt(struct net_device *
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
 	if (!delta && count)
-		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
+		DPRINTK(RX_ERR, INFO, "no Rx buffer allocated\n");
 	tp->dirty_rx += delta;
 
 	/*
@@ -2242,7 +2296,7 @@ rtl8169_rx_interrupt(struct net_device *
 	 * - how do others driver handle this condition (Uh oh...).
 	 */
 	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
-		printk(KERN_EMERG "%s: Rx buffers exhausted\n", dev->name);
+		DPRINTK(RX_ERR, EMERG, "Rx buffers exhausted\n");
 
 	return count;
 }
@@ -2294,8 +2348,9 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (likely(netif_rx_schedule_prep(dev)))
 			__netif_rx_schedule(dev);
 		else {
-			printk(KERN_INFO "%s: interrupt %04x taken in poll\n",
-			       dev->name, status);	
+			DPRINTK(INTR, INFO,
+				"interrupt %04x taken in poll\n",
+				status);	
 		}
 		break;
 #else
@@ -2312,8 +2367,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 	} while (boguscnt > 0);
 
 	if (boguscnt <= 0) {
-		printk(KERN_WARNING "%s: Too much work at interrupt!\n",
-		       dev->name);
+		DPRINTK(INTR, WARNING, "Too much work at interrupt!\n");
 		/* Clear all interrupt sources. */
 		RTL_W16(IntrStatus, 0xffff);
 	}
@@ -2408,6 +2462,8 @@ static int rtl8169_close(struct net_devi
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
 
+	DPRINTK(IFDOWN, DEBUG, "disabling interface\n");
+
 	rtl8169_down(dev);
 
 	free_irq(dev->irq, dev);
@@ -2436,8 +2492,7 @@ rtl8169_set_rx_mode(struct net_device *d
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
-		printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-		       dev->name);
+		DPRINTK(DRV, NOTICE, "Promiscuous mode enabled.\n");
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;

--------------050907010104070002090802--
