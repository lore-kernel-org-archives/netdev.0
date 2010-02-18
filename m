From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 09/15] drivers/net/sis190.c: Use
 (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 22:00:17 -0800
Message-ID: <1266472817.8446.258.camel@Joe-Laptop.home>
References: <cover.1266454575.git.joe@perches.com>
	 <a9449fa4b0219cd2e0699f3afe4f8ca811b72843.1266454576.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1090 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751955Ab0BRGAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 01:00:19 -0500
In-Reply-To: <a9449fa4b0219cd2e0699f3afe4f8ca811b72843.1266454576.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level> and netif_msg_<test>
Remove local #define net_<test> macros
Remove periods from formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sis190.c |  152 +++++++++++++++++++++++++-------------------------
 1 files changed, 75 insertions(+), 77 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index bf2ffbb..267409b 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -17,7 +17,9 @@
 
    See the file COPYING in this distribution for more information.
 
- */
+*/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -32,17 +34,6 @@
 #include <linux/dma-mapping.h>
 #include <asm/irq.h>
 
-#define net_drv(p, arg...)	if (netif_msg_drv(p)) \
-					printk(arg)
-#define net_probe(p, arg...)	if (netif_msg_probe(p)) \
-					printk(arg)
-#define net_link(p, arg...)	if (netif_msg_link(p)) \
-					printk(arg)
-#define net_intr(p, arg...)	if (netif_msg_intr(p)) \
-					printk(arg)
-#define net_tx_err(p, arg...)	if (netif_msg_tx_err(p)) \
-					printk(arg)
-
 #define PHY_MAX_ADDR		32
 #define PHY_ID_ANY		0x1f
 #define MII_REG_ANY		0x1f
@@ -50,7 +41,6 @@
 #define DRV_VERSION		"1.4"
 #define DRV_NAME		"sis190"
 #define SIS190_DRIVER_NAME	DRV_NAME " Gigabit Ethernet driver " DRV_VERSION
-#define PFX DRV_NAME ": "
 
 #define sis190_rx_skb			netif_rx
 #define sis190_rx_quota(count, quota)	count
@@ -382,7 +372,7 @@ static void __mdio_cmd(void __iomem *ioaddr, u32 ctl)
 	}
 
 	if (i > 99)
-		printk(KERN_ERR PFX "PHY command failed !\n");
+		pr_err("PHY command failed !\n");
 }
 
 static void mdio_write(void __iomem *ioaddr, int phy_id, int reg, int val)
@@ -590,8 +580,7 @@ static int sis190_rx_interrupt(struct net_device *dev,
 
 		status = le32_to_cpu(desc->PSize);
 
-		// net_intr(tp, KERN_INFO "%s: Rx PSize = %08x.\n", dev->name,
-		//	 status);
+		//netif_info(tp, intr, dev, "Rx PSize = %08x\n", status);
 
 		if (sis190_rx_pkt_err(status, stats) < 0)
 			sis190_give_to_asic(desc, tp->rx_buf_sz);
@@ -602,9 +591,8 @@ static int sis190_rx_interrupt(struct net_device *dev,
 			struct pci_dev *pdev = tp->pci_dev;
 
 			if (unlikely(pkt_size > tp->rx_buf_sz)) {
-				net_intr(tp, KERN_INFO
-					 "%s: (frag) status = %08x.\n",
-					 dev->name, status);
+				netif_info(tp, intr, dev,
+					   "(frag) status = %08x\n", status);
 				stats->rx_dropped++;
 				stats->rx_length_errors++;
 				sis190_give_to_asic(desc, tp->rx_buf_sz);
@@ -638,12 +626,12 @@ static int sis190_rx_interrupt(struct net_device *dev,
 	tp->cur_rx = cur_rx;
 
 	delta = sis190_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (!delta && count && netif_msg_intr(tp))
-		printk(KERN_INFO "%s: no Rx buffer allocated.\n", dev->name);
+	if (!delta && count)
+		netif_info(tp, intr, dev, "no Rx buffer allocated\n");
 	tp->dirty_rx += delta;
 
-	if (((tp->dirty_rx + NUM_RX_DESC) == tp->cur_rx) && netif_msg_intr(tp))
-		printk(KERN_EMERG "%s: Rx buffers exhausted.\n", dev->name);
+	if ((tp->dirty_rx + NUM_RX_DESC) == tp->cur_rx)
+		netif_emerg(tp, intr, dev, "Rx buffers exhausted\n");
 
 	return count;
 }
@@ -752,10 +740,10 @@ static irqreturn_t sis190_interrupt(int irq, void *__dev)
 
 	SIS_W32(IntrStatus, status);
 
-	// net_intr(tp, KERN_INFO "%s: status = %08x.\n", dev->name, status);
+//	netif_info(tp, intr, dev, "status = %08x\n", status);
 
 	if (status & LinkChange) {
-		net_intr(tp, KERN_INFO "%s: link change.\n", dev->name);
+		netif_info(tp, intr, dev, "link change\n");
 		schedule_work(&tp->phy_task);
 	}
 
@@ -933,8 +921,7 @@ static void sis190_phy_task(struct work_struct *work)
 	} else if (!(mdio_read_latched(ioaddr, phy_id, MII_BMSR) &
 		     BMSR_ANEGCOMPLETE)) {
 		netif_carrier_off(dev);
-		net_link(tp, KERN_WARNING "%s: auto-negotiating...\n",
-			 dev->name);
+		netif_warn(tp, link, dev, "auto-negotiating...\n");
 		mod_timer(&tp->timer, jiffies + SIS190_PHY_TIMEOUT);
 	} else {
 		/* Rejoice ! */
@@ -960,13 +947,13 @@ static void sis190_phy_task(struct work_struct *work)
 		u16 adv, autoexp, gigadv, gigrec;
 
 		val = mdio_read(ioaddr, phy_id, 0x1f);
-		net_link(tp, KERN_INFO "%s: mii ext = %04x.\n", dev->name, val);
+		netif_info(tp, link, dev, "mii ext = %04x\n", val);
 
 		val = mdio_read(ioaddr, phy_id, MII_LPA);
 		adv = mdio_read(ioaddr, phy_id, MII_ADVERTISE);
 		autoexp = mdio_read(ioaddr, phy_id, MII_EXPANSION);
-		net_link(tp, KERN_INFO "%s: mii lpa=%04x adv=%04x exp=%04x.\n",
-			 dev->name, val, adv, autoexp);
+		netif_info(tp, link, dev, "mii lpa=%04x adv=%04x exp=%04x\n",
+			   val, adv, autoexp);
 
 		if (val & LPA_NPAGE && autoexp & EXPANSION_NWAY) {
 			/* check for gigabit speed */
@@ -1007,8 +994,7 @@ static void sis190_phy_task(struct work_struct *work)
 
 		tp->negotiated_lpa = p->val;
 
-		net_link(tp, KERN_INFO "%s: link on %s mode.\n", dev->name,
-			 p->msg);
+		netif_info(tp, link, dev, "link on %s mode\n", p->msg);
 		netif_carrier_on(dev);
 	}
 
@@ -1194,9 +1180,8 @@ static netdev_tx_t sis190_start_xmit(struct sk_buff *skb,
 
 	if (unlikely(le32_to_cpu(desc->status) & OWNbit)) {
 		netif_stop_queue(dev);
-		net_tx_err(tp, KERN_ERR PFX
-			   "%s: BUG! Tx Ring full when queue awake!\n",
-			   dev->name);
+		netif_err(tp, tx_err, dev,
+			  "BUG! Tx Ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1296,9 +1281,9 @@ static u16 sis190_default_phy(struct net_device *dev)
 
 	if (mii_if->phy_id != phy_default->phy_id) {
 		mii_if->phy_id = phy_default->phy_id;
-		net_probe(tp, KERN_INFO
-		       "%s: Using transceiver at address %d as default.\n",
-		       pci_name(tp->pci_dev), mii_if->phy_id);
+		if (netif_msg_probe(tp))
+			pr_info("%s: Using transceiver at address %d as default\n",
+				pci_name(tp->pci_dev), mii_if->phy_id);
 	}
 
 	status = mdio_read(ioaddr, mii_if->phy_id, MII_BMCR);
@@ -1336,14 +1321,15 @@ static void sis190_init_phy(struct net_device *dev, struct sis190_private *tp,
 			((mii_status & (BMSR_100FULL | BMSR_100HALF)) ?
 				LAN : HOME) : p->type;
 		tp->features |= p->feature;
-		net_probe(tp, KERN_INFO "%s: %s transceiver at address %d.\n",
-			pci_name(tp->pci_dev), p->name, phy_id);
+		if (netif_msg_probe(tp))
+			pr_info("%s: %s transceiver at address %d\n",
+				pci_name(tp->pci_dev), p->name, phy_id);
 	} else {
 		phy->type = UNKNOWN;
-		net_probe(tp, KERN_INFO
-			"%s: unknown PHY 0x%x:0x%x transceiver at address %d\n",
-			pci_name(tp->pci_dev),
-			phy->id[0], (phy->id[1] & 0xfff0), phy_id);
+		if (netif_msg_probe(tp))
+			pr_info("%s: unknown PHY 0x%x:0x%x transceiver at address %d\n",
+				pci_name(tp->pci_dev),
+				phy->id[0], (phy->id[1] & 0xfff0), phy_id);
 	}
 }
 
@@ -1407,8 +1393,9 @@ static int __devinit sis190_mii_probe(struct net_device *dev)
 	}
 
 	if (list_empty(&tp->first_phy)) {
-		net_probe(tp, KERN_INFO "%s: No MII transceivers found!\n",
-			  pci_name(tp->pci_dev));
+		if (netif_msg_probe(tp))
+			pr_info("%s: No MII transceivers found!\n",
+				pci_name(tp->pci_dev));
 		rc = -EIO;
 		goto out;
 	}
@@ -1454,7 +1441,8 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 
 	dev = alloc_etherdev(sizeof(*tp));
 	if (!dev) {
-		net_drv(&debug, KERN_ERR PFX "unable to alloc new ethernet\n");
+		if (netif_msg_drv(&debug))
+			pr_err("unable to alloc new ethernet\n");
 		rc = -ENOMEM;
 		goto err_out_0;
 	}
@@ -1467,34 +1455,39 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 
 	rc = pci_enable_device(pdev);
 	if (rc < 0) {
-		net_probe(tp, KERN_ERR "%s: enable failure\n", pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_err("%s: enable failure\n", pci_name(pdev));
 		goto err_free_dev_1;
 	}
 
 	rc = -ENODEV;
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		net_probe(tp, KERN_ERR "%s: region #0 is no MMIO resource.\n",
-			  pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_err("%s: region #0 is no MMIO resource\n",
+			       pci_name(pdev));
 		goto err_pci_disable_2;
 	}
 	if (pci_resource_len(pdev, 0) < SIS190_REGS_SIZE) {
-		net_probe(tp, KERN_ERR "%s: invalid PCI region size(s).\n",
-			  pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_err("%s: invalid PCI region size(s)\n",
+			       pci_name(pdev));
 		goto err_pci_disable_2;
 	}
 
 	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc < 0) {
-		net_probe(tp, KERN_ERR PFX "%s: could not request regions.\n",
-			  pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_err("%s: could not request regions\n",
+			       pci_name(pdev));
 		goto err_pci_disable_2;
 	}
 
 	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (rc < 0) {
-		net_probe(tp, KERN_ERR "%s: DMA configuration failed.\n",
-			  pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_err("%s: DMA configuration failed\n",
+			       pci_name(pdev));
 		goto err_free_res_3;
 	}
 
@@ -1502,8 +1495,9 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 
 	ioaddr = ioremap(pci_resource_start(pdev, 0), SIS190_REGS_SIZE);
 	if (!ioaddr) {
-		net_probe(tp, KERN_ERR "%s: cannot remap MMIO, aborting\n",
-			  pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_err("%s: cannot remap MMIO, aborting\n",
+			       pci_name(pdev));
 		rc = -EIO;
 		goto err_free_res_3;
 	}
@@ -1539,9 +1533,8 @@ static void sis190_tx_timeout(struct net_device *dev)
 	if (tmp8 & CmdTxEnb)
 		SIS_W8(TxControl, tmp8 & ~CmdTxEnb);
 
-
-	net_tx_err(tp, KERN_INFO "%s: Transmit timeout, status %08x %08x.\n",
-		   dev->name, SIS_R32(TxControl), SIS_R32(TxSts));
+	netif_info(tp, tx_err, dev, "Transmit timeout, status %08x %08x\n",
+		   SIS_R32(TxControl), SIS_R32(TxSts));
 
 	/* Disable interrupts by clearing the interrupt mask. */
 	SIS_W32(IntrMask, 0x0000);
@@ -1570,15 +1563,16 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 	u16 sig;
 	int i;
 
-	net_probe(tp, KERN_INFO "%s: Read MAC address from EEPROM\n",
-		  pci_name(pdev));
+	if (netif_msg_probe(tp))
+		pr_info("%s: Read MAC address from EEPROM\n", pci_name(pdev));
 
 	/* Check to see if there is a sane EEPROM */
 	sig = (u16) sis190_read_eeprom(ioaddr, EEPROMSignature);
 
 	if ((sig == 0xffff) || (sig == 0x0000)) {
-		net_probe(tp, KERN_INFO "%s: Error EEPROM read %x.\n",
-			  pci_name(pdev), sig);
+		if (netif_msg_probe(tp))
+			pr_info("%s: Error EEPROM read %x\n",
+				pci_name(pdev), sig);
 		return -EIO;
 	}
 
@@ -1612,8 +1606,8 @@ static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 	u8 reg, tmp8;
 	unsigned int i;
 
-	net_probe(tp, KERN_INFO "%s: Read MAC address from APC.\n",
-		  pci_name(pdev));
+	if (netif_msg_probe(tp))
+		pr_info("%s: Read MAC address from APC\n", pci_name(pdev));
 
 	for (i = 0; i < ARRAY_SIZE(ids); i++) {
 		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, ids[i], NULL);
@@ -1622,8 +1616,9 @@ static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 	}
 
 	if (!isa_bridge) {
-		net_probe(tp, KERN_INFO "%s: Can not find ISA bridge.\n",
-			  pci_name(pdev));
+		if (netif_msg_probe(tp))
+			pr_info("%s: Can not find ISA bridge\n",
+				pci_name(pdev));
 		return -EIO;
 	}
 
@@ -1704,7 +1699,7 @@ static void sis190_set_speed_auto(struct net_device *dev)
 	int phy_id = tp->mii_if.phy_id;
 	int val;
 
-	net_link(tp, KERN_INFO "%s: Enabling Auto-negotiation.\n", dev->name);
+	netif_info(tp, link, dev, "Enabling Auto-negotiation\n");
 
 	val = mdio_read(ioaddr, phy_id, MII_ADVERTISE);
 
@@ -1831,7 +1826,8 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 	int rc;
 
 	if (!printed_version) {
-		net_drv(&debug, KERN_INFO SIS190_DRIVER_NAME " loaded.\n");
+		if (netif_msg_drv(&debug))
+			pr_info(SIS190_DRIVER_NAME " loaded\n");
 		printed_version = 1;
 	}
 
@@ -1871,12 +1867,14 @@ static int __devinit sis190_init_one(struct pci_dev *pdev,
 	if (rc < 0)
 		goto err_remove_mii;
 
-	net_probe(tp, KERN_INFO "%s: %s at %p (IRQ: %d), %pM\n",
-		  pci_name(pdev), sis_chip_info[ent->driver_data].name,
-		  ioaddr, dev->irq, dev->dev_addr);
-
-	net_probe(tp, KERN_INFO "%s: %s mode.\n", dev->name,
-		  (tp->features & F_HAS_RGMII) ? "RGMII" : "GMII");
+	if (netif_msg_probe(tp)) {
+		netdev_info(dev, "%s: %s at %p (IRQ: %d), %pM\n",
+			    pci_name(pdev),
+			    sis_chip_info[ent->driver_data].name,
+			    ioaddr, dev->irq, dev->dev_addr);
+		netdev_info(dev, "%s mode.\n",
+			    (tp->features & F_HAS_RGMII) ? "RGMII" : "GMII");
+	}
 
 	netif_carrier_off(dev);
 


