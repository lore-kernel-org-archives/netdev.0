From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 4/7] drivers/net/r8196.c: Use netif_printk macros
Date: Tue,  9 Feb 2010 13:49:50 -0800
Message-ID: <7a3687b4acab70895eef9dada45e3e940f1ab179.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1913 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754216Ab0BIVtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:55 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the logic a bit, make the message logs a bit more consistent.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/r8169.c |  136 ++++++++++++++++++---------------------------------
 1 files changed, 48 insertions(+), 88 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c1bb24c..a545c15 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -744,12 +744,10 @@ static void rtl8169_check_link_status(struct net_device *dev,
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		netif_carrier_on(dev);
-		if (netif_msg_ifup(tp))
-			printk(KERN_INFO PFX "%s: link up\n", dev->name);
+		netif_info(tp, ifup, dev, "link up\n");
 	} else {
-		if (netif_msg_ifdown(tp))
-			printk(KERN_INFO PFX "%s: link down\n", dev->name);
 		netif_carrier_off(dev);
+		netif_info(tp, ifdown, dev, "link down\n");
 	}
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
@@ -862,11 +860,8 @@ static int rtl8169_set_speed_tbi(struct net_device *dev,
 	} else if (autoneg == AUTONEG_ENABLE)
 		RTL_W32(TBICSR, reg | TBINwEnable | TBINwRestart);
 	else {
-		if (netif_msg_link(tp)) {
-			printk(KERN_WARNING "%s: "
-			       "incorrect speed setting refused in TBI mode\n",
-			       dev->name);
-		}
+		netif_warn(tp, link, dev,
+			   "incorrect speed setting refused in TBI mode\n");
 		ret = -EOPNOTSUPP;
 	}
 
@@ -901,9 +896,9 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
 		    (tp->mac_version != RTL_GIGA_MAC_VER_16)) {
 			giga_ctrl |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
-		} else if (netif_msg_link(tp)) {
-			printk(KERN_INFO "%s: PHY does not support 1000Mbps.\n",
-			       dev->name);
+		} else {
+			netif_info(tp, link, dev,
+				   "PHY does not support 1000Mbps\n");
 		}
 
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
@@ -2705,8 +2700,7 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	if (tp->link_ok(ioaddr))
 		goto out_unlock;
 
-	if (netif_msg_link(tp))
-		printk(KERN_WARNING "%s: PHY reset until link up\n", dev->name);
+	netif_warn(tp, link, dev, "PHY reset until link up\n");
 
 	tp->phy_reset_enable(ioaddr);
 
@@ -2776,8 +2770,7 @@ static void rtl8169_phy_reset(struct net_device *dev,
 			return;
 		msleep(1);
 	}
-	if (netif_msg_link(tp))
-		printk(KERN_ERR "%s: PHY reset failed.\n", dev->name);
+	netif_err(tp, link, dev, "PHY reset failed\n");
 }
 
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
@@ -2811,8 +2804,8 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 	 */
 	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
 
-	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
-		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
+	if (RTL_R8(PHYstatus) & TBI_Enable)
+		netif_info(tp, link, dev, "TBI auto-negotiating\n");
 }
 
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
@@ -3012,8 +3005,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
-		if (netif_msg_probe(tp))
-			dev_err(&pdev->dev, "enable failure\n");
+		netif_err(tp, probe, dev, "enable failure\n");
 		goto err_out_free_dev_1;
 	}
 
@@ -3023,29 +3015,24 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(pci_resource_flags(pdev, region) & IORESOURCE_MEM)) {
-		if (netif_msg_probe(tp)) {
-			dev_err(&pdev->dev,
-				"region #%d not an MMIO resource, aborting\n",
-				region);
-		}
+		netif_err(tp, probe, dev,
+			  "region #%d not an MMIO resource, aborting\n",
+			  region);
 		rc = -ENODEV;
 		goto err_out_mwi_3;
 	}
 
 	/* check for weird/broken PCI region reporting */
 	if (pci_resource_len(pdev, region) < R8169_REGS_SIZE) {
-		if (netif_msg_probe(tp)) {
-			dev_err(&pdev->dev,
-				"Invalid PCI region size(s), aborting\n");
-		}
+		netif_err(tp, probe, dev,
+			  "Invalid PCI region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out_mwi_3;
 	}
 
 	rc = pci_request_regions(pdev, MODULENAME);
 	if (rc < 0) {
-		if (netif_msg_probe(tp))
-			dev_err(&pdev->dev, "could not request regions.\n");
+		netif_err(tp, probe, dev, "could not request regions\n");
 		goto err_out_mwi_3;
 	}
 
@@ -3058,10 +3045,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	} else {
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
-			if (netif_msg_probe(tp)) {
-				dev_err(&pdev->dev,
-					"DMA configuration failed.\n");
-			}
+			netif_err(tp, probe, dev, "DMA configuration failed\n");
 			goto err_out_free_res_4;
 		}
 	}
@@ -3069,15 +3053,14 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
-		if (netif_msg_probe(tp))
-			dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
+		netif_err(tp, probe, dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
 		goto err_out_free_res_4;
 	}
 
 	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (!tp->pcie_cap && netif_msg_probe(tp))
-		dev_info(&pdev->dev, "no PCI Express capability\n");
+	if (!tp->pcie_cap)
+		netif_info(tp, probe, dev, "no PCI Express capability\n");
 
 	RTL_W16(IntrMask, 0x0000);
 
@@ -3100,10 +3083,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Use appropriate default if unknown */
 	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
-		if (netif_msg_probe(tp)) {
-			dev_notice(&pdev->dev,
-				   "unknown MAC, using family default\n");
-		}
+		netif_notice(tp, probe, dev,
+			     "unknown MAC, using family default\n");
 		tp->mac_version = cfg->default_ver;
 	}
 
@@ -3185,14 +3166,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	if (netif_msg_probe(tp)) {
-		u32 xid = RTL_R32(TxConfig) & 0x9cf0f8ff;
-
-		printk(KERN_INFO "%s: %s at 0x%lx, %pM, XID %08x IRQ %d\n",
-		       dev->name,
-		       rtl_chip_info[tp->chipset].name,
-		       dev->base_addr, dev->dev_addr, xid, dev->irq);
-	}
+	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
+		   rtl_chip_info[tp->chipset].name,
+		   dev->base_addr, dev->dev_addr,
+		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
 
 	rtl8169_init_phy(dev, tp);
 
@@ -4131,10 +4108,10 @@ static void rtl8169_reinit_task(struct work_struct *work)
 
 	ret = rtl8169_open(dev);
 	if (unlikely(ret < 0)) {
-		if (net_ratelimit() && netif_msg_drv(tp)) {
-			printk(KERN_ERR PFX "%s: reinit failure (status = %d)."
-			       " Rescheduling.\n", dev->name, ret);
-		}
+		if (net_ratelimit())
+			netif_err(tp, drv, dev,
+				  "reinit failure (status = %d). Rescheduling\n",
+				  ret);
 		rtl8169_schedule_work(dev, rtl8169_reinit_task);
 	}
 
@@ -4164,10 +4141,8 @@ static void rtl8169_reset_task(struct work_struct *work)
 		netif_wake_queue(dev);
 		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 	} else {
-		if (net_ratelimit() && netif_msg_intr(tp)) {
-			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
-			       dev->name);
-		}
+		if (net_ratelimit())
+			netif_emerg(tp, intr, dev, "Rx buffers shortage\n");
 		rtl8169_schedule_work(dev, rtl8169_reset_task);
 	}
 
@@ -4255,11 +4230,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts1;
 
 	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
-		if (netif_msg_drv(tp)) {
-			printk(KERN_ERR
-			       "%s: BUG! Tx Ring full when queue awake!\n",
-			       dev->name);
-		}
+		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop;
 	}
 
@@ -4321,11 +4292,8 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 	pci_read_config_word(pdev, PCI_COMMAND, &pci_cmd);
 	pci_read_config_word(pdev, PCI_STATUS, &pci_status);
 
-	if (netif_msg_intr(tp)) {
-		printk(KERN_ERR
-		       "%s: PCI error (cmd = 0x%04x, status = 0x%04x).\n",
-		       dev->name, pci_cmd, pci_status);
-	}
+	netif_err(tp, intr, dev, "PCI error (cmd = 0x%04x, status = 0x%04x)\n",
+		  pci_cmd, pci_status);
 
 	/*
 	 * The recovery sequence below admits a very elaborated explanation:
@@ -4349,8 +4317,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	/* The infamous DAC f*ckup only happens at boot time */
 	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
-		if (netif_msg_intr(tp))
-			printk(KERN_INFO "%s: disabling PCI DAC.\n", dev->name);
+		netif_info(tp, intr, dev, "disabling PCI DAC\n");
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 		dev->features &= ~NETIF_F_HIGHDMA;
@@ -4477,11 +4444,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		if (status & DescOwn)
 			break;
 		if (unlikely(status & RxRES)) {
-			if (netif_msg_rx_err(tp)) {
-				printk(KERN_INFO
-				       "%s: Rx ERROR. status = %08x\n",
-				       dev->name, status);
-			}
+			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
+				   status);
 			dev->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
 				dev->stats.rx_length_errors++;
@@ -4544,8 +4508,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	tp->cur_rx = cur_rx;
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (!delta && count && netif_msg_intr(tp))
-		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
+	if (!delta && count)
+		netif_info(tp, intr, dev, "no Rx buffer allocated\n");
 	tp->dirty_rx += delta;
 
 	/*
@@ -4555,8 +4519,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 	 *   after refill ?
 	 * - how do others driver handle this condition (Uh oh...).
 	 */
-	if ((tp->dirty_rx + NUM_RX_DESC == tp->cur_rx) && netif_msg_intr(tp))
-		printk(KERN_EMERG "%s: Rx buffers exhausted\n", dev->name);
+	if (tp->dirty_rx + NUM_RX_DESC == tp->cur_rx)
+		netif_emerg(tp, intr, dev, "Rx buffers exhausted\n");
 
 	return count;
 }
@@ -4611,10 +4575,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 
 			if (likely(napi_schedule_prep(&tp->napi)))
 				__napi_schedule(&tp->napi);
-			else if (netif_msg_intr(tp)) {
-				printk(KERN_INFO "%s: interrupt %04x in poll\n",
-				dev->name, status);
-			}
+			else
+				netif_info(tp, intr, dev,
+					   "interrupt %04x in poll\n", status);
 		}
 
 		/* We only get a new MSI interrupt when all active irq
@@ -4750,10 +4713,7 @@ static void rtl_set_rx_mode(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
-		if (netif_msg_link(tp)) {
-			printk(KERN_NOTICE "%s: Promiscuous mode enabled.\n",
-			       dev->name);
-		}
+		netif_notice(tp, link, dev, "Promiscuous mode enabled\n");
 		rx_mode =
 		    AcceptBroadcast | AcceptMulticast | AcceptMyPhys |
 		    AcceptAllPhys;
-- 
1.7.0.rc1.33.g07cf0f

