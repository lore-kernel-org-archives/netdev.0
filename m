From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/2) acenic - don't print eth%d in messages
Date: Mon, 26 Jul 2004 16:26:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040726162630.4520a785@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jes Sorensen <jes@wildopensource.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of all the places the acenic driver could print "eth%d" because
the device hasn't been registered yet.  Use the method of having a name pointer
in the private device structure that changes from pci_name() to dev->name.
There was already a field named 'name[]' in the private data structure, but
it was set and never used!

Use netdev_priv(dev) rather than dev->priv as well.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-07-26 16:20:07 -07:00
+++ b/drivers/net/acenic.c	2004-07-26 16:20:07 -07:00
@@ -477,6 +477,7 @@
 
 	ap = dev->priv;
 	ap->pdev = pdev;
+	ap->name = pci_name(pdev);
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 #if ACENIC_DO_VLAN
@@ -519,7 +520,7 @@
 	if (!(ap->pci_command & PCI_COMMAND_MEMORY)) {
 		printk(KERN_INFO "%s: Enabling PCI Memory Mapped "
 		       "access - was not enabled by BIOS/Firmware\n",
-		       dev->name);
+		       ap->name);
 		ap->pci_command = ap->pci_command | PCI_COMMAND_MEMORY;
 		pci_write_config_word(ap->pdev, PCI_COMMAND,
 				      ap->pci_command);
@@ -542,55 +543,40 @@
 	if (!ap->regs) {
 		printk(KERN_ERR "%s:  Unable to map I/O register, "
 		       "AceNIC %i will be disabled.\n",
-		       dev->name, boards_found);
+		       ap->name, boards_found);
 		goto fail_free_netdev;
 	}
 
 	switch(pdev->vendor) {
 	case PCI_VENDOR_ID_ALTEON:
 		if (pdev->device == PCI_DEVICE_ID_FARALLON_PN9100T) {
-			strncpy(ap->name, "Farallon PN9100-T "
-				"Gigabit Ethernet", sizeof (ap->name));
 			printk(KERN_INFO "%s: Farallon PN9100-T ",
-			       dev->name);
+			       ap->name);
 		} else {
-			strncpy(ap->name, "AceNIC Gigabit Ethernet",
-				sizeof (ap->name));
 			printk(KERN_INFO "%s: Alteon AceNIC ",
-			       dev->name);
+			       ap->name);
 		}
 		break;
 	case PCI_VENDOR_ID_3COM:
-		strncpy(ap->name, "3Com 3C985 Gigabit Ethernet",
-			sizeof (ap->name));
-		printk(KERN_INFO "%s: 3Com 3C985 ", dev->name);
+		printk(KERN_INFO "%s: 3Com 3C985 ", ap->name);
 		break;
 	case PCI_VENDOR_ID_NETGEAR:
-		strncpy(ap->name, "NetGear GA620 Gigabit Ethernet",
-			sizeof (ap->name));
-		printk(KERN_INFO "%s: NetGear GA620 ", dev->name);
+		printk(KERN_INFO "%s: NetGear GA620 ", ap->name);
 		break;
 	case PCI_VENDOR_ID_DEC:
 		if (pdev->device == PCI_DEVICE_ID_FARALLON_PN9000SX) {
-			strncpy(ap->name, "Farallon PN9000-SX "
-				"Gigabit Ethernet", sizeof (ap->name));
 			printk(KERN_INFO "%s: Farallon PN9000-SX ",
-			       dev->name);
+			       ap->name);
 			break;
 		}
 	case PCI_VENDOR_ID_SGI:
-		strncpy(ap->name, "SGI AceNIC Gigabit Ethernet",
-			sizeof (ap->name));
-		printk(KERN_INFO "%s: SGI AceNIC ", dev->name);
+		printk(KERN_INFO "%s: SGI AceNIC ", ap->name);
 		break;
 	default:
- 		strncpy(ap->name, "Unknown AceNIC based Gigabit "
-			"Ethernet", sizeof (ap->name));
-		printk(KERN_INFO "%s: Unknown AceNIC ", dev->name);
+		printk(KERN_INFO "%s: Unknown AceNIC ", ap->name);
 		break;
 	}
 
-	ap->name [sizeof (ap->name) - 1] = '\0';
 	printk("Gigabit Ethernet at 0x%08lx, ", dev->base_addr);
 #ifdef __sparc__
 	printk("irq %s\n", __irq_itoa(pdev->irq));
@@ -625,6 +611,7 @@
 		printk(KERN_ERR "acenic: device registration failed\n");
 		goto fail_uninit;
 	}
+	ap->name = dev->name;
 
 	if (ap->pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
@@ -644,7 +631,7 @@
 static void __devexit acenic_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 	short i;
 
@@ -755,7 +742,7 @@
 
 static void ace_free_descriptors(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	int size;
 
 	if (ap->rx_std_ring != NULL) {
@@ -805,7 +792,7 @@
 
 static int ace_allocate_descriptors(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	int size;
 
 	size = (sizeof(struct rx_desc) *
@@ -876,7 +863,7 @@
 {
 	struct ace_private *ap;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 
 	ace_free_descriptors(dev);
 
@@ -924,7 +911,7 @@
 	short i;
 	unsigned char cache_size;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	regs = ap->regs;
 
 	board_idx = ap->board_idx;
@@ -1390,7 +1377,7 @@
 	if (board_idx == BOARD_IDX_OVERFLOW) {
 		printk(KERN_WARNING "%s: more than %i NICs detected, "
 		       "ignoring module parameters!\n",
-		       dev->name, ACE_MAX_MOD_PARMS);
+		       ap->name, ACE_MAX_MOD_PARMS);
 	} else if (board_idx >= 0) {
 		if (tx_coal_tick[board_idx])
 			writel(tx_coal_tick[board_idx],
@@ -1429,7 +1416,7 @@
 
 		if (option & 0x01) {
 			printk(KERN_INFO "%s: Setting half duplex link\n",
-			       dev->name);
+			       ap->name);
 			tmp &= ~LNK_FULL_DUPLEX;
 		}
 		if (option & 0x02)
@@ -1442,7 +1429,7 @@
 			tmp |= LNK_1000MB;
 		if ((option & 0x70) == 0) {
 			printk(KERN_WARNING "%s: No media speed specified, "
-			       "forcing auto negotiation\n", dev->name);
+			       "forcing auto negotiation\n", ap->name);
 			tmp |= LNK_NEGOTIATE | LNK_1000MB |
 				LNK_100MB | LNK_10MB;
 		}
@@ -1450,12 +1437,12 @@
 			tmp |= LNK_NEG_FCTL;
 		else
 			printk(KERN_INFO "%s: Disabling flow control "
-			       "negotiation\n", dev->name);
+			       "negotiation\n", ap->name);
 		if (option & 0x200)
 			tmp |= LNK_RX_FLOW_CTL_Y;
 		if ((option & 0x400) && (ap->version >= 2)) {
 			printk(KERN_INFO "%s: Enabling TX flow control\n",
-			       dev->name);
+			       ap->name);
 			tmp |= LNK_TX_FLOW_CTL_Y;
 		}
 	}
@@ -1512,7 +1499,7 @@
 		cpu_relax();
 
 	if (!ap->fw_running) {
-		printk(KERN_ERR "%s: Firmware NOT running!\n", dev->name);
+		printk(KERN_ERR "%s: Firmware NOT running!\n", ap->name);
 
 		ace_dump_trace(ap);
 		writel(readl(&regs->CpuCtrl) | CPU_HALT, &regs->CpuCtrl);
@@ -1545,13 +1532,13 @@
 		ace_load_std_rx_ring(ap, RX_RING_SIZE);
 	else
 		printk(KERN_ERR "%s: Someone is busy refilling the RX ring\n",
-		       dev->name);
+		       ap->name);
 	if (ap->version >= 2) {
 		if (!test_and_set_bit(0, &ap->mini_refill_busy))
 			ace_load_mini_rx_ring(ap, RX_MINI_SIZE);
 		else
 			printk(KERN_ERR "%s: Someone is busy refilling "
-			       "the RX mini ring\n", dev->name);
+			       "the RX mini ring\n", ap->name);
 	}
 	return 0;
 
@@ -1567,7 +1554,7 @@
 	struct ace_regs *regs;
 	int board_idx;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	regs = ap->regs;
 
 	board_idx = ap->board_idx;
@@ -1607,7 +1594,7 @@
 static void ace_watchdog(struct net_device *data)
 {
 	struct net_device *dev = data;
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 
 	/*
@@ -1881,13 +1868,13 @@
 {
 	struct ace_private *ap;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 
 	while (evtcsm != evtprd) {
 		switch (ap->evt_ring[evtcsm].evt) {
 		case E_FW_RUNNING:
 			printk(KERN_INFO "%s: Firmware up and running\n",
-			       dev->name);
+			       ap->name);
 			ap->fw_running = 1;
 			wmb();
 			break;
@@ -1902,7 +1889,7 @@
 				u32 state = readl(&ap->regs->GigLnkState);
 				printk(KERN_WARNING "%s: Optical link UP "
 				       "(%s Duplex, Flow Control: %s%s)\n",
-				       dev->name,
+				       ap->name,
 				       state & LNK_FULL_DUPLEX ? "Full":"Half",
 				       state & LNK_TX_FLOW_CTL_Y ? "TX " : "",
 				       state & LNK_RX_FLOW_CTL_Y ? "RX" : "");
@@ -1910,15 +1897,15 @@
 			}
 			case E_C_LINK_DOWN:
 				printk(KERN_WARNING "%s: Optical link DOWN\n",
-				       dev->name);
+				       ap->name);
 				break;
 			case E_C_LINK_10_100:
 				printk(KERN_WARNING "%s: 10/100BaseT link "
-				       "UP\n", dev->name);
+				       "UP\n", ap->name);
 				break;
 			default:
 				printk(KERN_ERR "%s: Unknown optical link "
-				       "state %02x\n", dev->name, code);
+				       "state %02x\n", ap->name, code);
 			}
 			break;
 		}
@@ -1926,19 +1913,19 @@
 			switch(ap->evt_ring[evtcsm].code) {
 			case E_C_ERR_INVAL_CMD:
 				printk(KERN_ERR "%s: invalid command error\n",
-				       dev->name);
+				       ap->name);
 				break;
 			case E_C_ERR_UNIMP_CMD:
 				printk(KERN_ERR "%s: unimplemented command "
-				       "error\n", dev->name);
+				       "error\n", ap->name);
 				break;
 			case E_C_ERR_BAD_CFG:
 				printk(KERN_ERR "%s: bad config error\n",
-				       dev->name);
+				       ap->name);
 				break;
 			default:
 				printk(KERN_ERR "%s: unknown error %02x\n",
-				       dev->name, ap->evt_ring[evtcsm].code);
+				       ap->name, ap->evt_ring[evtcsm].code);
 			}
 			break;
 		case E_RESET_JUMBO_RNG:
@@ -1967,13 +1954,13 @@
 			ap->jumbo = 0;
 			ap->rx_jumbo_skbprd = 0;
 			printk(KERN_INFO "%s: Jumbo ring flushed\n",
-			       dev->name);
+			       ap->name);
 			clear_bit(0, &ap->jumbo_refill_busy);
 			break;
 		}
 		default:
 			printk(KERN_ERR "%s: Unhandled event 0x%02x\n",
-			       dev->name, ap->evt_ring[evtcsm].evt);
+			       ap->name, ap->evt_ring[evtcsm].evt);
 		}
 		evtcsm = (evtcsm + 1) % EVT_RING_ENTRIES;
 	}
@@ -1984,7 +1971,7 @@
 
 static void ace_rx_int(struct net_device *dev, u32 rxretprd, u32 rxretcsm)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	u32 idx;
 	int mini_count = 0, std_count = 0;
 
@@ -2111,7 +2098,7 @@
 static inline void ace_tx_int(struct net_device *dev,
 			      u32 txcsm, u32 idx)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 
 	do {
 		struct sk_buff *skb;
@@ -2184,7 +2171,7 @@
 	u32 txcsm, rxretcsm, rxretprd;
 	u32 evtcsm, evtprd;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	regs = ap->regs;
 
 	/*
@@ -2307,7 +2294,7 @@
 #if ACENIC_DO_VLAN
 static void ace_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -2322,7 +2309,7 @@
 
 static void ace_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -2343,7 +2330,7 @@
 	struct ace_regs *regs;
 	struct cmd cmd;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	regs = ap->regs;
 
 	if (!(ap->fw_running)) {
@@ -2410,7 +2397,7 @@
 	 */
 	netif_stop_queue(dev);
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	regs = ap->regs;
 
 	if (ap->promisc) {
@@ -2525,7 +2512,7 @@
 
 static int ace_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 	struct tx_desc *desc;
 	u32 idx, flagsize;
@@ -2664,7 +2651,7 @@
 
 static int ace_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 
 	if (new_mtu > ACE_JUMBO_MTU)
@@ -2701,7 +2688,7 @@
 
 static int ace_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 	u32 link;
 
@@ -2754,7 +2741,7 @@
 
 static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 	u32 link, speed;
 
@@ -2817,7 +2804,7 @@
 static void ace_get_drvinfo(struct net_device *dev, 
 			    struct ethtool_drvinfo *info)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 
 	strlcpy(info->driver, "acenic", sizeof(info->driver));
 	snprintf(info->version, sizeof(info->version), "%i.%i.%i", 
@@ -2847,7 +2834,7 @@
 
 	da = (u8 *)dev->dev_addr;
 
-	regs = ((struct ace_private *)dev->priv)->regs;
+	regs = ((struct ace_private *)netdev_priv(dev))->regs;
 	writel(da[0] << 8 | da[1], &regs->MacAddrHi);
 	writel((da[2] << 24) | (da[3] << 16) | (da[4] << 8) | da[5],
 	       &regs->MacAddrLo);
@@ -2863,7 +2850,7 @@
 
 static void ace_set_multicast_list(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 	struct cmd cmd;
 
@@ -2917,7 +2904,7 @@
 
 static struct net_device_stats *ace_get_stats(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_mac_stats *mac_stats =
 		(struct ace_mac_stats *)ap->regs->Stats;
 
@@ -3000,12 +2987,12 @@
 	struct ace_private *ap;
 	struct ace_regs *regs;
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	regs = ap->regs;
 
 	if (!(readl(&regs->CpuCtrl) & CPU_HALTED)) {
 		printk(KERN_ERR "%s: trying to download firmware while the "
-		       "CPU is running!\n", dev->name);
+		       "CPU is running!\n", ap->name);
 		return -EFAULT;
 	}
 
@@ -3181,6 +3168,7 @@
 static int __init read_eeprom_byte(struct net_device *dev,
 				   unsigned long offset)
 {
+	struct ace_private *ap;
 	struct ace_regs *regs;
 	unsigned long flags;
 	u32 local;
@@ -3190,10 +3178,11 @@
 	if (!dev) {
 		printk(KERN_ERR "No device!\n");
 		result = -ENODEV;
-		goto eeprom_read_error;
+		goto out;
 	}
 
-	regs = ((struct ace_private *)dev->priv)->regs;
+	ap = netdev_priv(dev);
+	regs = ap->regs;
 
 	/*
 	 * Don't take interrupts on this CPU will bit banging
@@ -3206,7 +3195,7 @@
 	eeprom_prep(regs, EEPROM_WRITE_SELECT);
 	if (eeprom_check_ack(regs)) {
 		local_irq_restore(flags);
-		printk(KERN_ERR "%s: Unable to sync eeprom\n", dev->name);
+		printk(KERN_ERR "%s: Unable to sync eeprom\n", ap->name);
 		result = -EIO;
 		goto eeprom_read_error;
 	}
@@ -3215,7 +3204,7 @@
 	if (eeprom_check_ack(regs)) {
 		local_irq_restore(flags);
 		printk(KERN_ERR "%s: Unable to set address byte 0\n",
-		       dev->name);
+		       ap->name);
 		result = -EIO;
 		goto eeprom_read_error;
 	}
@@ -3224,7 +3213,7 @@
 	if (eeprom_check_ack(regs)) {
 		local_irq_restore(flags);
 		printk(KERN_ERR "%s: Unable to set address byte 1\n",
-		       dev->name);
+		       ap->name);
 		result = -EIO;
 		goto eeprom_read_error;
 	}
@@ -3234,7 +3223,7 @@
 	if (eeprom_check_ack(regs)) {
 		local_irq_restore(flags);
 		printk(KERN_ERR "%s: Unable to set READ_SELECT\n",
-		       dev->name);
+		       ap->name);
 		result = -EIO;
 		goto eeprom_read_error;
 	}
@@ -3291,7 +3280,7 @@
 
  eeprom_read_error:
 	printk(KERN_ERR "%s: Unable to read eeprom byte 0x%02lx\n",
-	       dev->name, offset);
+	       ap->name, offset);
 	goto out;
 }
 
diff -Nru a/drivers/net/acenic.h b/drivers/net/acenic.h
--- a/drivers/net/acenic.h	2004-07-26 16:20:07 -07:00
+++ b/drivers/net/acenic.h	2004-07-26 16:20:07 -07:00
@@ -693,7 +693,7 @@
 	int			board_idx;
 	u16			pci_command;
 	u8			pci_latency;
-	char			name[48];
+	const char		*name;
 #ifdef INDEX_DEBUG
 	spinlock_t		debug_lock
 				__attribute__ ((aligned (SMP_CACHE_BYTES)));
