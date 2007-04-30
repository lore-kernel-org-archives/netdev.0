From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 1/2] atl1: use dev_printk macros
Date: Sun, 29 Apr 2007 21:42:10 -0500
Message-ID: <11779009313497-git-send-email-jacliburn@bellsouth.net>
References: <11779009311121-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf07aec.mail.bellsouth.net ([205.152.59.55]:33213 "EHLO
	imf07aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422854AbXD3DOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 23:14:10 -0400
In-Reply-To: <11779009311121-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_printk macros for PCI related errors, warnings, debug and info
console messages.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_ethtool.c |   19 +++------
 drivers/net/atl1/atl1_hw.c      |   22 +++++------
 drivers/net/atl1/atl1_main.c    |   83 +++++++++++++++++---------------------
 drivers/net/atl1/atl1_param.c   |   31 +++++++--------
 4 files changed, 68 insertions(+), 87 deletions(-)

diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index c11c277..1f616c5 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -156,8 +156,7 @@ static int atl1_set_settings(struct net_device *netdev,
 	u16 old_media_type = hw->media_type;
 
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool shutting down adapter\n",
-			atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "ethtool shutting down adapter\n");
 		atl1_down(adapter);
 	}
 
@@ -166,9 +165,8 @@ static int atl1_set_settings(struct net_device *netdev,
 	else {
 		if (ecmd->speed == SPEED_1000) {
 			if (ecmd->duplex != DUPLEX_FULL) {
-				printk(KERN_WARNING
-				       "%s: can't force to 1000M half duplex\n",
-					atl1_driver_name);
+				dev_warn(&adapter->pdev->dev,
+					"can't force to 1000M half duplex\n");
 				ret_val = -EINVAL;
 				goto exit_sset;
 			}
@@ -206,9 +204,8 @@ static int atl1_set_settings(struct net_device *netdev,
 	}
 	if (atl1_phy_setup_autoneg_adv(hw)) {
 		ret_val = -EINVAL;
-		printk(KERN_WARNING
-			"%s: invalid ethtool speed/duplex setting\n",
-			atl1_driver_name);
+		dev_warn(&adapter->pdev->dev,
+			"invalid ethtool speed/duplex setting\n");
 		goto exit_sset;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
@@ -239,12 +236,10 @@ exit_sset:
 		hw->media_type = old_media_type;
 
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool starting adapter\n",
-			atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "ethtool starting adapter\n");
 		atl1_up(adapter);
 	} else if (!ret_val) {
-		printk(KERN_DEBUG "%s: ethtool resetting adapter\n",
-			atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "ethtool resetting adapter\n");
 		atl1_reset(adapter);
 	}
 	return ret_val;
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 69482e0..5b9dd3c 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -38,6 +38,7 @@
  */
 s32 atl1_reset_hw(struct atl1_hw *hw)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	u32 icr;
 	int i;
 
@@ -74,7 +75,7 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 	}
 
 	if (icr) {
-		printk (KERN_DEBUG "icr = %x\n", icr); 
+		dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
 		return icr;
 	}
 
@@ -437,6 +438,7 @@ s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
  */
 static s32 atl1_phy_reset(struct atl1_hw *hw)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	s32 ret_val;
 	u16 phy_data;
 
@@ -468,8 +470,7 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 		u32 val;
 		int i;
 		/* pcie serdes link may be down! */
-		printk(KERN_DEBUG "%s: autoneg caused pcie phy link down\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "pcie phy link down\n");
 
 		for (i = 0; i < 25; i++) {
 			msleep(1);
@@ -479,9 +480,7 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 		}
 
 		if ((val & (MDIO_START | MDIO_BUSY)) != 0) {
-			printk(KERN_WARNING 
-				"%s: pcie link down at least for 25ms\n", 
-				atl1_driver_name);
+			dev_warn(&pdev->dev, "pcie link down at least 25ms\n");
 			return ret_val;
 		}
 	}
@@ -571,6 +570,7 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
  */
 static s32 atl1_setup_link(struct atl1_hw *hw)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	s32 ret_val;
 
 	/*
@@ -581,15 +581,13 @@ static s32 atl1_setup_link(struct atl1_hw *hw)
 	 */
 	ret_val = atl1_phy_setup_autoneg_adv(hw);
 	if (ret_val) {
-		printk(KERN_DEBUG "%s: error setting up autonegotiation\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "error setting up autonegotiation\n");
 		return ret_val;
 	}
 	/* SW.Reset , En-Auto-Neg if needed */
 	ret_val = atl1_phy_reset(hw);
 	if (ret_val) {
-		printk(KERN_DEBUG "%s: error resetting the phy\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "error resetting phy\n");
 		return ret_val;
 	}
 	hw->phy_configured = true;
@@ -669,6 +667,7 @@ s32 atl1_init_hw(struct atl1_hw *hw)
  */
 s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	s32 ret_val;
 	u16 phy_data;
 
@@ -691,8 +690,7 @@ s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 		*speed = SPEED_10;
 		break;
 	default:
-		printk(KERN_DEBUG "%s: error getting speed\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "error getting speed\n");
 		return ATL1_ERR_PHY_SPEED;
 		break;
 	}
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 4b1d4d1..d28f88b 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -188,8 +188,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	size = sizeof(struct atl1_buffer) * (tpd_ring->count + rfd_ring->count);
 	tpd_ring->buffer_info = kzalloc(size, GFP_KERNEL);
 	if (unlikely(!tpd_ring->buffer_info)) {
-		printk(KERN_WARNING "%s: kzalloc failed , size = D%d\n",
-			atl1_driver_name, size);
+		dev_err(&pdev->dev, "kzalloc failed , size = D%d\n", size);
 		goto err_nomem;
 	}
 	rfd_ring->buffer_info =
@@ -207,9 +206,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
 						&ring_header->dma);
 	if (unlikely(!ring_header->desc)) {
-		printk(KERN_WARNING
-			"%s: pci_alloc_consistent failed, size = D%d\n",
-			atl1_driver_name, size);
+		dev_err(&pdev->dev, "pci_alloc_consistent failed\n");
 		goto err_nomem;
 	}
 
@@ -373,8 +370,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
 					ERR_FLAG_CODE | ERR_FLAG_OV)) {
 			adapter->hw_csum_err++;
-			printk(KERN_DEBUG "%s: rx checksum error\n",
-				atl1_driver_name);
+			dev_dbg(&adapter->pdev->dev, "rx checksum error\n");
 			return;
 		}
 	}
@@ -393,8 +389,9 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	}
 
 	/* IPv4, but hardware thinks its checksum is wrong */
-	printk(KERN_DEBUG "%s: hw csum wrong pkt_flag:%x, err_flag:%x\n",
-		atl1_driver_name, rrd->pkt_flg, rrd->err_flg);
+	dev_dbg(&adapter->pdev->dev,
+		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
+		rrd->pkt_flg, rrd->err_flg);
 	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
 	adapter->hw_csum_err++;
@@ -507,14 +504,13 @@ chk_rrd:
 			/* rrd seems to be bad */
 			if (unlikely(i-- > 0)) {
 				/* rrd may not be DMAed completely */
-				printk(KERN_DEBUG
-					"%s: RRD may not be DMAed completely\n",
-					atl1_driver_name);
+				dev_dbg(&adapter->pdev->dev,
+					"incomplete RRD DMA transfer\n");
 				udelay(1);
 				goto chk_rrd;
 			}
 			/* bad rrd */
-			printk(KERN_DEBUG "%s: bad RRD\n", atl1_driver_name);
+			dev_dbg(&adapter->pdev->dev, "bad RRD\n");
 			/* see if update RFD index */
 			if (rrd->num_buf > 1) {
 				u16 num_buf;
@@ -685,8 +681,8 @@ static void atl1_check_for_link(struct atl1_adapter *adapter)
 	/* notify upper layer link down ASAP */
 	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
 		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			printk(KERN_INFO "%s: %s link is down\n",
-			       atl1_driver_name, netdev->name);
+			dev_info(&adapter->pdev->dev, "%s link is down\n",
+				netdev->name);
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
@@ -731,8 +727,8 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if PCIE PHY Link down */
 		if (status & ISR_PHY_LINKDOWN) {
-			printk(KERN_DEBUG "%s: pcie phy link down %x\n",
-				atl1_driver_name, status);
+			dev_dbg(&adapter->pdev->dev, "pcie phy link down %x\n",
+				status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
 				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 				schedule_work(&adapter->pcie_dma_to_rst_task);
@@ -742,9 +738,9 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if DMA read/write error ? */
 		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			printk(KERN_DEBUG
-				"%s: pcie DMA r/w error (status = 0x%x)\n",
-				atl1_driver_name, status);
+			dev_dbg(&adapter->pdev->dev,
+				"pcie DMA r/w error (status = 0x%x)\n",
+				status);
 			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 			schedule_work(&adapter->pcie_dma_to_rst_task);
 			return IRQ_HANDLED;
@@ -762,14 +758,13 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* rx exception */
 		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
+			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
 				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-				ISR_HOST_RRD_OV | ISR_CMB_RX))) {
-			if (status &
-			    (ISR_RXF_OV | ISR_RFD_UNRUN | ISR_RRD_OV |
-			     ISR_HOST_RFD_UNRUN | ISR_HOST_RRD_OV))
-				printk(KERN_INFO
-					"%s: rx exception: status = 0x%x\n",
-					atl1_driver_name, status);
+				ISR_HOST_RRD_OV))
+				dev_dbg(&adapter->pdev->dev,
+					"rx exception, ISR = 0x%x\n", status);
 			atl1_intr_rx(adapter);
 		}
 
@@ -874,8 +869,7 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	atl1_read_phy_reg(hw, MII_BMSR, &phy_data);
 	if (!(phy_data & BMSR_LSTATUS)) {	/* link down */
 		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			printk(KERN_INFO "%s: link is down\n",
-				atl1_driver_name);
+			dev_info(&adapter->pdev->dev, "link is down\n");
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
@@ -918,11 +912,11 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 			adapter->link_speed = speed;
 			adapter->link_duplex = duplex;
 			atl1_setup_mac_ctrl(adapter);
-			printk(KERN_INFO "%s: %s link is up %d Mbps %s\n",
-			       atl1_driver_name, netdev->name,
-			       adapter->link_speed,
-			       adapter->link_duplex ==
-			       FULL_DUPLEX ? "full duplex" : "half duplex");
+			dev_info(&adapter->pdev->dev,
+				"%s link is up %d Mbps %s\n",
+				netdev->name, adapter->link_speed,
+				adapter->link_duplex == FULL_DUPLEX ?
+				"full duplex" : "half duplex");
 		}
 		if (!netif_carrier_ok(netdev)) {	/* Link down -> Up */
 			netif_carrier_on(netdev);
@@ -1330,8 +1324,8 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 		cso = skb_transport_offset(skb);
 		css = cso + skb->csum_offset;
 		if (unlikely(cso & 0x1)) {
-			printk(KERN_DEBUG "%s: payload offset != even number\n",
-				atl1_driver_name);
+			dev_dbg(&adapter->pdev->dev,
+				"payload offset not an even number\n");
 			return -1;
 		}
 		csum->csumpl |= (cso & CSUM_PARAM_PLOADOFFSET_MASK) <<
@@ -1579,7 +1573,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (!spin_trylock(&adapter->lock)) {
 		/* Can't get lock - tell upper layer to requeue */
 		local_irq_restore(flags);
-		printk(KERN_DEBUG "%s: TX locked\n", atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -1587,7 +1581,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		printk(KERN_DEBUG "%s: TX busy\n", atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1841,8 +1835,7 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		printk(KERN_WARNING "%s: invalid MTU setting\n",
-			atl1_driver_name);
+		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -2136,9 +2129,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
-			printk(KERN_DEBUG
-				"%s: no usable DMA configuration, aborting\n",
-				atl1_driver_name);
+			dev_err(&pdev->dev, "no usable DMA configuration\n");
 			goto err_dma;
 		}
 		pci_using_64 = false;
@@ -2175,7 +2166,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		goto err_pci_iomap;
 	}
 	/* get device revision number */
-	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr + (REG_MASTER_CTRL + 2));
+	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr +
+					(REG_MASTER_CTRL + 2));
+	dev_info(&pdev->dev, "version %s\n", DRIVER_VERSION);
 
 	/* set default ring resource counts */
 	adapter->rfd_ring.count = adapter->rrd_ring.count = ATL1_DEFAULT_RFD;
@@ -2466,8 +2459,6 @@ static void __exit atl1_exit_module(void)
  */
 static int __init atl1_init_module(void)
 {
-	printk(KERN_INFO "%s - version %s\n", atl1_driver_string, DRIVER_VERSION);
-	printk(KERN_INFO "%s\n", atl1_copyright);
 	return pci_register_driver(&atl1_driver);
 }
 
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atl1/atl1_param.c
index c407214..b80391a 100644
--- a/drivers/net/atl1/atl1_param.c
+++ b/drivers/net/atl1/atl1_param.c
@@ -94,7 +94,7 @@ struct atl1_option {
 	} arg;
 };
 
-static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
+static int __devinit atl1_validate_option(int *value, struct atl1_option *opt, struct pci_dev *pdev)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -105,19 +105,17 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			printk(KERN_INFO "%s: %s Enabled\n", atl1_driver_name,
-				opt->name);
+			dev_info(&pdev->dev, "%s enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			printk(KERN_INFO "%s: %s Disabled\n", atl1_driver_name,
-				opt->name);
+			dev_info(&pdev->dev, "%s disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			printk(KERN_INFO "%s: %s set to %i\n",
-				atl1_driver_name, opt->name, *value);
+			dev_info(&pdev->dev, "%s set to %i\n", opt->name,
+				*value);
 			return 0;
 		}
 		break;
@@ -129,8 +127,8 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 				ent = &opt->arg.l.p[i];
 				if (*value == ent->i) {
 					if (ent->str[0] != '\0')
-						printk(KERN_INFO "%s: %s\n",
-						       atl1_driver_name, ent->str);
+						dev_info(&pdev->dev, "%s\n",
+							ent->str);
 					return 0;
 				}
 			}
@@ -141,8 +139,8 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 		break;
 	}
 
-	printk(KERN_INFO "%s: invalid %s specified (%i) %s\n",
-	       atl1_driver_name, opt->name, *value, opt->err);
+	dev_info(&pdev->dev, "invalid %s specified (%i) %s\n",
+		opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -158,12 +156,11 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
  */
 void __devinit atl1_check_options(struct atl1_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	int bd = adapter->bd_number;
 	if (bd >= ATL1_MAX_NIC) {
-		printk(KERN_NOTICE "%s: warning: no configuration for board #%i\n",
-			atl1_driver_name, bd);
-		printk(KERN_NOTICE "%s: using defaults for all values\n",
-			atl1_driver_name);
+		dev_notice(&pdev->dev, "no configuration for board#%i\n", bd);
+		dev_notice(&pdev->dev, "using defaults for all values\n");
 	}
 	{			/* Interrupt Moderate Timer */
 		struct atl1_option opt = {
@@ -178,7 +175,7 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 		int val;
 		if (num_int_mod_timer > bd) {
 			val = int_mod_timer[bd];
-			atl1_validate_option(&val, &opt);
+			atl1_validate_option(&val, &opt, pdev);
 			adapter->imt = (u16) val;
 		} else
 			adapter->imt = (u16) (opt.def);
@@ -198,7 +195,7 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 		int val;
 		if (num_flash_vendor > bd) {
 			val = flash_vendor[bd];
-			atl1_validate_option(&val, &opt);
+			atl1_validate_option(&val, &opt, pdev);
 			adapter->hw.flash_vendor = (u8) val;
 		} else
 			adapter->hw.flash_vendor = (u8) (opt.def);
-- 
1.5.0.6

