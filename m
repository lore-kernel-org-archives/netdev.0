From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: RTL-8110SC lockup with r8169
Date: Wed, 05 May 2010 17:05:17 +0100
Message-ID: <4BE1973D.8080502@draigBrady.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030705040103020003010906"
Cc: Francois Romieu <romieu@fr.zoreil.com>, Glen Gray <glen@lincor.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.slb.deg.dub.stisp.net ([84.203.253.98]:6384 "HELO
	mail1.slb.deg.dub.stisp.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932818Ab0EEQNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 12:13:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030705040103020003010906
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Hi,

We're having an issue with the r8169 driver, where very often
(1 in 10 boots) it will lockup and our netboot system will hang.
On this hardware previously, we used FC5 with the r1000 driver without issue.

The interesting (problematic) thing is that the system needs to
be _power cycled_ to get the link detected again.
A reboot does not suffice. The symptoms sound like:

http://kerneltrap.org/mailarchive/linux-netdev/2009/3/6/5110184
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.32.y.git;a=commitdiff;h=ea8dbdd17099a9a5864ebd4c87e01e657b19c7ab

However the above code wasn't in the 2.6.32.10-90.fc12 driver we used.
Also I've back-ported the latest r8169 driver from git to our kernel
and it still has the same issue. The inconsequential diff
between our driver and the latest in git are attached just in case.

In the following dmesg you can see a successful boot.
Why does the link go down twice even in that case?
On lockup one does not see the "link up" message and
a power cycle is required, as the link is not detected
by the netboot ROM on a reboot.

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:01:04.0: PCI INT A -> Link[LNKA] -> GSI 11 (level, low) -> IRQ 11
r8169 0000:01:04.0: no PCI Express capability
eth0: RTL8169sc/8110sc at 0xde87c000, 00:60:ef:08:49:f5, XID 98000000 IRQ 11
r8169: eth0: link down
r8169: eth0: link down
r8169: eth0: link up

I'm in a good position to test any patches/ideas you may have.

cheers,
Pádraig.

Ancillary version details are...

# dmesg | grep 8169
# lspci -n | grep -v 8086:
01:04.0 0200: 10ec:8167 (rev 10)

# ethtool -i eth0
driver: r8169
version: 2.3LK-NAPI
firmware-version:
bus-info: 0000:01:04.0

# uname -a
Linux Unit-00:60:ef:08:49:f5 2.6.32.10-90.fc12.i686 #1 SMP Tue Mar 23 10:21:29 UTC 2010 i686 i686 i386 GNU/Linux

--------------030705040103020003010906
Content-Type: text/x-patch;
 name="r8169-unimportant.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="r8169-unimportant.diff"

--- /home/padraig/kernel/r8169.c.latest	2010-05-05 11:42:54.345452634 +0100
+++ /home/padraig/kernel/r8169.c.new	2010-05-05 16:36:36.805627050 +0100
@@ -168,7 +168,7 @@
 static void rtl_hw_start_8168(struct net_device *);
 static void rtl_hw_start_8101(struct net_device *);
 
-static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
+static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
@@ -749,10 +749,12 @@
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		netif_carrier_on(dev);
-		netif_info(tp, ifup, dev, "link up\n");
+		if (netif_msg_ifup(tp))
+			printk(KERN_INFO PFX "%s: link up\n", dev->name);
 	} else {
+		if (netif_msg_ifdown(tp))
+			printk(KERN_INFO PFX "%s: link down\n", dev->name);
 		netif_carrier_off(dev);
-		netif_info(tp, ifdown, dev, "link down\n");
 	}
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
@@ -865,8 +867,11 @@
 	} else if (autoneg == AUTONEG_ENABLE)
 		RTL_W32(TBICSR, reg | TBINwEnable | TBINwRestart);
 	else {
-		netif_warn(tp, link, dev,
-			   "incorrect speed setting refused in TBI mode\n");
+		if (netif_msg_link(tp)) {
+			printk(KERN_WARNING "%s: "
+			       "incorrect speed setting refused in TBI mode\n",
+			       dev->name);
+		}
 		ret = -EOPNOTSUPP;
 	}
 
@@ -901,9 +906,9 @@
 		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
 			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
-		} else {
-			netif_info(tp, link, dev,
-				   "PHY does not support 1000Mbps\n");
+		} else if (netif_msg_link(tp)) {
+			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
+			       dev->name);
 		}
 
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
@@ -2705,7 +2710,8 @@
 	if (tp->link_ok(ioaddr))
 		goto out_unlock;
 
-	netif_warn(tp, link, dev, "PHY reset until link up\n");
+	if (netif_msg_link(tp))
+		printk(KERN_WARNING "%s: PHY reset until link up\n", dev->name);
 
 	tp->phy_reset_enable(ioaddr);
 
@@ -2776,7 +2782,8 @@
 			return;
 		msleep(1);
 	}
-	netif_err(tp, link, dev, "PHY reset failed\n");
+	if (netif_msg_link(tp))
+		printk(KERN_ERR "%s: PHY reset failed.\n", dev->name);
 }
 
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
@@ -2810,8 +2817,8 @@
 	 */
 	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
 
-	if (RTL_R8(PHYstatus) & TBI_Enable)
-		netif_info(tp, link, dev, "TBI auto-negotiating\n");
+	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
+		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 }
 
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
@@ -3016,33 +3023,41 @@
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
-		netif_err(tp, probe, dev, "enable failure\n");
+		if (netif_msg_probe(tp))
+			dev_err(&pdev->dev, "enable failure\n");
 		goto err_out_free_dev_1;
 	}
 
 	if (pci_set_mwi(pdev) < 0)
-		netif_info(tp, probe, dev, "Mem-Wr-Inval unavailable\n");
+		if (netif_msg_probe(tp)) {
+			dev_err(&pdev->dev, "Mem-Wr-Inval unavailable\n");
+		}
 
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
-		netif_err(tp, probe, dev,
-			  "region #%d not an MMIO resource, aborting\n",
-			  region);
+		if (netif_msg_probe(tp)) {
+			dev_err(&pdev->dev,
+				"region #%d not an MMIO resource, aborting\n",
+				region);
+		}
 		rc = -ENODEV;
 		goto err_out_mwi_2;
 	}
 
 	/* check for weird/broken PCI region reporting */
 	if (pci_resource_len(pdev, region) < R8169_REGS_SIZE) {
-		netif_err(tp, probe, dev,
-			  "Invalid PCI region size(s), aborting\n");
+		if (netif_msg_probe(tp)) {
+			dev_err(&pdev->dev,
+				"Invalid PCI region size(s), aborting\n");
+		}
 		rc = -ENODEV;
 		goto err_out_mwi_2;
 	}
 
 	rc = pci_request_regions(pdev, MODULENAME);
 	if (rc < 0) {
-		netif_err(tp, probe, dev, "could not request regions\n");
+		if (netif_msg_probe(tp))
+			dev_err(&pdev->dev, "could not request regions.\n");
 		goto err_out_mwi_2;
 	}
 
@@ -3055,7 +3070,10 @@
 	} else {
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
-			netif_err(tp, probe, dev, "DMA configuration failed\n");
+			if (netif_msg_probe(tp)) {
+				dev_err(&pdev->dev,
+					"DMA configuration failed.\n");
+			}
 			goto err_out_free_res_3;
 		}
 	}
@@ -3063,14 +3081,15 @@
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
-		netif_err(tp, probe, dev, "cannot remap MMIO, aborting\n");
+		if (netif_msg_probe(tp))
+			dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
 		goto err_out_free_res_3;
 	}
 
 	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (!tp->pcie_cap)
-		netif_info(tp, probe, dev, "no PCI Express capability\n");
+	if (!tp->pcie_cap && netif_msg_probe(tp))
+		dev_info(&pdev->dev, "no PCI Express capability\n");
 
 	RTL_W16(IntrMask, 0x0000);
 
@@ -3093,8 +3112,10 @@
 
 	/* Use appropriate default if unknown */
 	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
-		netif_notice(tp, probe, dev,
-			     "unknown MAC, using family default\n");
+		if (netif_msg_probe(tp)) {
+			dev_notice(&pdev->dev,
+				   "unknown MAC, using family default\n");
+		}
 		tp->mac_version = cfg->default_ver;
 	}
 
@@ -3176,10 +3197,19 @@
 
 	pci_set_drvdata(pdev, dev);
 
-	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
-		   rtl_chip_info[tp->chipset].name,
-		   dev->base_addr, dev->dev_addr,
-		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
+	if (netif_msg_probe(tp)) {
+		u32 xid = RTL_R32(TxConfig) & 0x9cf0f8ff;
+
+		printk(KERN_INFO "%s: %s at 0x%lx, "
+		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
+		       "XID %08x IRQ %d\n",
+		       dev->name,
+		       rtl_chip_info[tp->chipset].name,
+		       dev->base_addr,
+		       dev->dev_addr[0], dev->dev_addr[1],
+		       dev->dev_addr[2], dev->dev_addr[3],
+		       dev->dev_addr[4], dev->dev_addr[5], xid, dev->irq);
+	}
 
 	rtl8169_init_phy(dev, tp);
 
@@ -3231,8 +3261,8 @@
 	unsigned int max_frame = mtu + VLAN_ETH_HLEN + ETH_FCS_LEN;
 
 	if (max_frame != 16383)
-		printk(KERN_WARNING PFX "WARNING! Changing of MTU on this "
-			"NIC may lead to frame reception errors!\n");
+		printk(KERN_WARNING "WARNING! Changing of MTU on this NIC "
+			"May lead to frame reception errors!\n");
 
 	tp->rx_buf_sz = (max_frame > RX_BUF_SIZE) ? max_frame : RX_BUF_SIZE;
 }
@@ -4131,10 +4161,10 @@
 
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
-		if (net_ratelimit())
-			netif_err(tp, drv, dev,
-				  "reinit failure (status = %d). Rescheduling\n",
-				  ret);
+		if (net_ratelimit() && netif_msg_drv(tp)) {
+			printk(KERN_ERR PFX "%s: reinit failure (status = %d)."
+			       " Rescheduling.\n", dev->name, ret);
+		}
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
 	}
 
@@ -4164,8 +4194,10 @@
 		netif_wake_queue(dev);
 		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 	} else {
-		if (net_ratelimit())
-			netif_emerg(tp, intr, dev, "Rx buffers shortage\n");
+		if (net_ratelimit() && netif_msg_intr(tp)) {
+			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
+			       dev->name);
+		}
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
 	}
 
@@ -4253,7 +4285,11 @@
 	u32 opts1;
 
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
-		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
+		if (netif_msg_drv(tp)) {
+			printk(KERN_ERR
+			       "%s: BUG! Tx Ring full when queue awake!\n",
+			       dev->name);
+		}
 		goto err_stop;
 	}
 
@@ -4315,8 +4351,11 @@
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
 	pci_read_config_word(pdev, PCI_STATUS, &pci_status);
 
-	netif_err(tp, intr, dev, "PCI error (cmd = 0x%04x, status = 0x%04x)\n",
-		  pci_cmd, pci_status);
+	if (netif_msg_intr(tp)) {
+		printk(KERN_ERR
+		       "%s: PCI error (cmd = 0x%04x, status = 0x%04x).\n",
+		       dev->name, pci_cmd, pci_status);
+	}
 
 	/*
 	 * The recovery sequence below admits a very elaborated explanation:
@@ -4340,7 +4379,8 @@
 
 	/* The infamous DAC f*ckup only happens at boot time */
 	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
-		netif_info(tp, intr, dev, "disabling PCI DAC\n");
+		if (netif_msg_intr(tp))
+			printk(KERN_INFO "%s: disabling PCI DAC.\n", dev->name);
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 		dev->features &= ~NETIF_F_HIGHDMA;
@@ -4432,12 +4472,13 @@
 	if (pkt_size >= rx_copybreak)
 		goto out;
 
-	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
+	skb = netdev_alloc_skb(tp->dev, pkt_size + NET_IP_ALIGN);
 	if (!skb)
 		goto out;
 
 	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, pkt_size,
 				    PCI_DMA_FROMDEVICE);
+	skb_reserve(skb, NET_IP_ALIGN);
 	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
 	*sk_buff = skb;
 	done = true;
@@ -4475,8 +4516,11 @@
 		if (status & DescOwn)
 			break;
 		if (unlikely(status & RxRES)) {
-			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
-				   status);
+			if (netif_msg_rx_err(tp)) {
+				printk(KERN_INFO
+				       "%s: Rx ERROR. status = %08x\n",
+				       dev->name, status);
+			}
 			dev->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
 				dev->stats.rx_length_errors++;
@@ -4543,8 +4587,8 @@
 	tp->cur_rx = cur_rx;
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (!delta && count)
-		netif_info(tp, intr, dev, "no Rx buffer allocated\n");
+	if (!delta && count && netif_msg_intr(tp))
+		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
 	tp->dirty_rx += delta;
 
 	/*
@@ -4554,8 +4598,8 @@
 	 *   after refill ?
 	 * - how do others driver handle this condition (Uh oh...).
 	 */
-	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
-		netif_emerg(tp, intr, dev, "Rx buffers exhausted\n");
+	if ((tp->dirty_rx + NUM_RX_DESC == tp->cur_rx) && netif_msg_intr(tp))
+		printk(KERN_EMERG "%s: Rx buffers exhausted\n", dev->name);
 
 	return count;
 }
@@ -4610,9 +4654,10 @@
 
 			if (likely(napi_schedule_prep(&tp->napi)))
 				__napi_schedule(&tp->napi);
-			else
-				netif_info(tp, intr, dev,
-					   "interrupt %04x in poll\n", status);
+			else if (netif_msg_intr(tp)) {
+				printk(KERN_INFO "%s: interrupt %04x in poll\n",
+				dev->name, status);
+			}
 		}
 
 		/* We only get a new MSI interrupt when all active irq
@@ -4748,22 +4793,27 @@
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
-		netif_notice(tp, link, dev, "Promiscuous mode enabled\n");
+		if (netif_msg_link(tp)) {
+			printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
+			       dev->name);
+		}
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
-	} else if ((netdev_mc_count(dev) > multicast_filter_limit) ||
-		   (dev->flags & IFF_ALLMULTI)) {
+	} else if ((dev->mc_count > multicast_filter_limit)
+		   || (dev->flags & IFF_ALLMULTI)) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		rx_mode = AcceptBroadcast | AcceptMulticast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 	} else {
 		struct dev_mc_list *mclist;
+		unsigned int i;
 
 		rx_mode = AcceptBroadcast | AcceptMyPhys;
 		mc_filter[1] = mc_filter[0] = 0;
-		netdev_for_each_mc_addr(mclist, dev) {
+		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count;
+		     i++, mclist = mclist->next) {
 			int bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
 			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
 			rx_mode |= AcceptMulticast;

--------------030705040103020003010906--
