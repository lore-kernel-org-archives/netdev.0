From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 07/10] atl1: use netif_msg
Date: Sat,  2 Feb 2008 19:50:09 -0600
Message-ID: <1202003412-4028-7-git-send-email-jacliburn@bellsouth.net>
References: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:46094 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933547AbYBCBuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:25 -0500
In-Reply-To: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netif_msg_* for console messages emitted by the driver. Add a
parameter to allow control of messaging at driver startup, and also
add the ability to control it with ethtool.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Acked-by: Chris Snook <csnook@redhat.com>
---
 drivers/net/atlx/atl1.c |  155 +++++++++++++++++++++++++++++++++--------------
 drivers/net/atlx/atl1.h |    2 +-
 2 files changed, 111 insertions(+), 46 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 9929822..51eca23 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -100,6 +100,13 @@ static const struct pci_device_id atl1_pci_tbl[] = {
 };
 MODULE_DEVICE_TABLE(pci, atl1_pci_tbl);
 
+static const u32 atl1_default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
+	NETIF_MSG_LINK | NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP;
+
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Message level (0=none,...,16=all)");
+
 /*
  * atl1_sw_init - Initialize general software structures (struct atl1_adapter)
  * @adapter: board private structure to initialize
@@ -217,7 +224,9 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	size = sizeof(struct atl1_buffer) * (tpd_ring->count + rfd_ring->count);
 	tpd_ring->buffer_info = kzalloc(size, GFP_KERNEL);
 	if (unlikely(!tpd_ring->buffer_info)) {
-		dev_err(&pdev->dev, "kzalloc failed , size = D%d\n", size);
+		if (netif_msg_drv(adapter))
+			dev_err(&pdev->dev, "kzalloc failed , size = D%d\n",
+				size);
 		goto err_nomem;
 	}
 	rfd_ring->buffer_info =
@@ -239,7 +248,8 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
 		&ring_header->dma);
 	if (unlikely(!ring_header->desc)) {
-		dev_err(&pdev->dev, "pci_alloc_consistent failed\n");
+		if (netif_msg_drv(adapter))
+			dev_err(&pdev->dev, "pci_alloc_consistent failed\n");
 		goto err_nomem;
 	}
 
@@ -472,7 +482,8 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 		/* link down */
 		if (netif_carrier_ok(netdev)) {
 			/* old link state: Up */
-			dev_info(&adapter->pdev->dev, "link is down\n");
+			if (netif_msg_link(adapter))
+				dev_info(&adapter->pdev->dev, "link is down\n");
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
@@ -515,11 +526,12 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 			adapter->link_speed = speed;
 			adapter->link_duplex = duplex;
 			atl1_setup_mac_ctrl(adapter);
-			dev_info(&adapter->pdev->dev,
-				"%s link is up %d Mbps %s\n",
-				netdev->name, adapter->link_speed,
-				adapter->link_duplex == FULL_DUPLEX ?
-				"full duplex" : "half duplex");
+			if (netif_msg_link(adapter))
+				dev_info(&adapter->pdev->dev,
+					"%s link is up %d Mbps %s\n",
+					netdev->name, adapter->link_speed,
+					adapter->link_duplex == FULL_DUPLEX ?
+					"full duplex" : "half duplex");
 		}
 		if (!netif_carrier_ok(netdev)) {
 			/* Link down -> Up */
@@ -583,7 +595,8 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
+		if (netif_msg_link(adapter))
+			dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -997,8 +1010,9 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
 					ERR_FLAG_CODE | ERR_FLAG_OV)) {
 			adapter->hw_csum_err++;
-			dev_printk(KERN_DEBUG, &pdev->dev,
-				"rx checksum error\n");
+			if (netif_msg_rx_err(adapter))
+				dev_printk(KERN_DEBUG, &pdev->dev,
+					"rx checksum error\n");
 			return;
 		}
 	}
@@ -1017,9 +1031,10 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	}
 
 	/* IPv4, but hardware thinks its checksum is wrong */
-	dev_printk(KERN_DEBUG, &pdev->dev,
-		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
-		rrd->pkt_flg, rrd->err_flg);
+	if (netif_msg_rx_err(adapter))
+		dev_printk(KERN_DEBUG, &pdev->dev,
+			"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
+			rrd->pkt_flg, rrd->err_flg);
 	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
 	adapter->hw_csum_err++;
@@ -1133,14 +1148,17 @@ chk_rrd:
 			/* rrd seems to be bad */
 			if (unlikely(i-- > 0)) {
 				/* rrd may not be DMAed completely */
-				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-					"incomplete RRD DMA transfer\n");
+				if (netif_msg_rx_err(adapter))
+					dev_printk(KERN_DEBUG,
+						&adapter->pdev->dev,
+						"unexpected RRD count\n");
 				udelay(1);
 				goto chk_rrd;
 			}
 			/* bad rrd */
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"bad RRD\n");
+			if (netif_msg_rx_err(adapter))
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"bad RRD\n");
 			/* see if update RFD index */
 			if (rrd->num_buf > 1)
 				atl1_update_rfd_index(adapter, rrd);
@@ -1351,8 +1369,9 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 		cso = css + (u8) skb->csum_offset;
 		if (unlikely(css & 0x1)) {
 			/* L1 hardware requires an even number here */
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"payload offset not an even number\n");
+			if (netif_msg_tx_err(adapter))
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"payload offset not an even number\n");
 			return -1;
 		}
 		ptpd->word3 |= (css & TPD_PLOADOFFSET_MASK) <<
@@ -1573,7 +1592,9 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
 		/* Can't get lock - tell upper layer to requeue */
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
+		if (netif_msg_tx_queued(adapter))
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -1581,7 +1602,9 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx busy\n");
+		if (netif_msg_tx_queued(adapter))
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1657,8 +1680,9 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if PCIE PHY Link down */
 		if (status & ISR_PHY_LINKDOWN) {
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"pcie phy link down %x\n", status);
+			if (netif_msg_intr(adapter))
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"pcie phy link down %x\n", status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
 				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 				schedule_work(&adapter->pcie_dma_to_rst_task);
@@ -1668,9 +1692,10 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if DMA read/write error ? */
 		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"pcie DMA r/w error (status = 0x%x)\n",
-				status);
+			if (netif_msg_intr(adapter))
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"pcie DMA r/w error (status = 0x%x)\n",
+					status);
 			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 			schedule_work(&adapter->pcie_dma_to_rst_task);
 			return IRQ_HANDLED;
@@ -1693,8 +1718,11 @@ static irqreturn_t atl1_intr(int irq, void *data)
 			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
 				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
 				ISR_HOST_RRD_OV))
-				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-					"rx exception, ISR = 0x%x\n", status);
+				if (netif_msg_intr(adapter))
+					dev_printk(KERN_DEBUG,
+						&adapter->pdev->dev,
+						"rx exception, ISR = 0x%x\n",
+						status);
 			atl1_intr_rx(adapter);
 		}
 
@@ -1791,8 +1819,9 @@ s32 atl1_up(struct atl1_adapter *adapter)
 
 	err = pci_enable_msi(adapter->pdev);
 	if (err) {
-		dev_info(&adapter->pdev->dev,
-			"Unable to enable MSI: %d\n", err);
+		if (netif_msg_ifup(adapter))
+			dev_info(&adapter->pdev->dev,
+				"Unable to enable MSI: %d\n", err);
 		irq_flags |= IRQF_SHARED;
 	}
 
@@ -2061,6 +2090,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
+	adapter->msg_enable = netif_msg_init(debug, atl1_default_msg);
 
 	adapter->hw.hw_addr = pci_iomap(pdev, 0, 0);
 	if (!adapter->hw.hw_addr) {
@@ -2070,7 +2100,8 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	/* get device revision number */
 	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr +
 		(REG_MASTER_CTRL + 2));
-	dev_info(&pdev->dev, "version %s\n", ATLX_DRIVER_VERSION);
+	if (netif_msg_probe(adapter))
+		dev_info(&pdev->dev, "version %s\n", ATLX_DRIVER_VERSION);
 
 	/* set default ring resource counts */
 	adapter->rfd_ring.count = adapter->rrd_ring.count = ATL1_DEFAULT_RFD;
@@ -2390,7 +2421,9 @@ static int atl1_set_settings(struct net_device *netdev,
 	u16 old_media_type = hw->media_type;
 
 	if (netif_running(adapter->netdev)) {
-		dev_dbg(&adapter->pdev->dev, "ethtool shutting down adapter\n");
+		if (netif_msg_link(adapter))
+			dev_dbg(&adapter->pdev->dev,
+				"ethtool shutting down adapter\n");
 		atl1_down(adapter);
 	}
 
@@ -2399,8 +2432,9 @@ static int atl1_set_settings(struct net_device *netdev,
 	else {
 		if (ecmd->speed == SPEED_1000) {
 			if (ecmd->duplex != DUPLEX_FULL) {
-				dev_warn(&adapter->pdev->dev,
-					"can't force to 1000M half duplex\n");
+				if (netif_msg_link(adapter))
+					dev_warn(&adapter->pdev->dev,
+						"1000M half is invalid\n");
 				ret_val = -EINVAL;
 				goto exit_sset;
 			}
@@ -2438,8 +2472,9 @@ static int atl1_set_settings(struct net_device *netdev,
 	}
 	if (atl1_phy_setup_autoneg_adv(hw)) {
 		ret_val = -EINVAL;
-		dev_warn(&adapter->pdev->dev,
-			"invalid ethtool speed/duplex setting\n");
+		if (netif_msg_link(adapter))
+			dev_warn(&adapter->pdev->dev,
+				"invalid ethtool speed/duplex setting\n");
 		goto exit_sset;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
@@ -2471,10 +2506,14 @@ exit_sset:
 		hw->media_type = old_media_type;
 
 	if (netif_running(adapter->netdev)) {
-		dev_dbg(&adapter->pdev->dev, "ethtool starting adapter\n");
+		if (netif_msg_link(adapter))
+			dev_dbg(&adapter->pdev->dev,
+				"ethtool starting adapter\n");
 		atl1_up(adapter);
 	} else if (!ret_val) {
-		dev_dbg(&adapter->pdev->dev, "ethtool resetting adapter\n");
+		if (netif_msg_link(adapter))
+			dev_dbg(&adapter->pdev->dev,
+				"ethtool resetting adapter\n");
 		atl1_reset(adapter);
 	}
 	return ret_val;
@@ -2531,6 +2570,18 @@ static int atl1_set_wol(struct net_device *netdev,
 	return 0;
 }
 
+static u32 atl1_get_msglevel(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	return adapter->msg_enable;
+}
+
+static void atl1_set_msglevel(struct net_device *netdev, u32 value)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	adapter->msg_enable = value;
+}
+
 static int atl1_get_regs_len(struct net_device *netdev)
 {
 	return ATL1_REG_COUNT * sizeof(u32);
@@ -2772,6 +2823,8 @@ const struct ethtool_ops atl1_ethtool_ops = {
 	.get_drvinfo		= atl1_get_drvinfo,
 	.get_wol		= atl1_get_wol,
 	.set_wol		= atl1_set_wol,
+	.get_msglevel		= atl1_get_msglevel,
+	.set_msglevel		= atl1_set_msglevel,
 	.get_regs_len		= atl1_get_regs_len,
 	.get_regs		= atl1_get_regs,
 	.get_ringparam		= atl1_get_ringparam,
@@ -2797,6 +2850,7 @@ const struct ethtool_ops atl1_ethtool_ops = {
 s32 atl1_reset_hw(struct atl1_hw *hw)
 {
 	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
 	u32 icr;
 	int i;
 
@@ -2836,7 +2890,8 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 	}
 
 	if (icr) {
-		dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
+		if (netif_msg_hw(adapter))
+			dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
 		return icr;
 	}
 
@@ -3205,6 +3260,7 @@ s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
 static s32 atl1_phy_reset(struct atl1_hw *hw)
 {
 	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
 	s32 ret_val;
 	u16 phy_data;
 
@@ -3237,7 +3293,8 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 		u32 val;
 		int i;
 		/* pcie serdes link may be down! */
-		dev_dbg(&pdev->dev, "pcie phy link down\n");
+		if (netif_msg_hw(adapter))
+			dev_dbg(&pdev->dev, "pcie phy link down\n");
 
 		for (i = 0; i < 25; i++) {
 			msleep(1);
@@ -3247,7 +3304,9 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 		}
 
 		if ((val & (MDIO_START | MDIO_BUSY)) != 0) {
-			dev_warn(&pdev->dev, "pcie link down at least 25ms\n");
+			if (netif_msg_hw(adapter))
+				dev_warn(&pdev->dev,
+					"pcie link down at least 25ms\n");
 			return ret_val;
 		}
 	}
@@ -3338,6 +3397,7 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
 static s32 atl1_setup_link(struct atl1_hw *hw)
 {
 	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
 	s32 ret_val;
 
 	/*
@@ -3348,13 +3408,16 @@ static s32 atl1_setup_link(struct atl1_hw *hw)
 	 */
 	ret_val = atl1_phy_setup_autoneg_adv(hw);
 	if (ret_val) {
-		dev_dbg(&pdev->dev, "error setting up autonegotiation\n");
+		if (netif_msg_link(adapter))
+			dev_dbg(&pdev->dev,
+				"error setting up autonegotiation\n");
 		return ret_val;
 	}
 	/* SW.Reset , En-Auto-Neg if needed */
 	ret_val = atl1_phy_reset(hw);
 	if (ret_val) {
-		dev_dbg(&pdev->dev, "error resetting phy\n");
+		if (netif_msg_link(adapter))
+			dev_dbg(&pdev->dev, "error resetting phy\n");
 		return ret_val;
 	}
 	hw->phy_configured = true;
@@ -3429,6 +3492,7 @@ s32 atl1_init_hw(struct atl1_hw *hw)
 s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 {
 	struct pci_dev *pdev = hw->back->pdev;
+	struct atl1_adapter *adapter = hw->back;
 	s32 ret_val;
 	u16 phy_data;
 
@@ -3451,7 +3515,8 @@ s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 		*speed = SPEED_10;
 		break;
 	default:
-		dev_dbg(&pdev->dev, "error getting speed\n");
+		if (netif_msg_hw(adapter))
+			dev_dbg(&pdev->dev, "error getting speed\n");
 		return ATLX_ERR_PHY_SPEED;
 		break;
 	}
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 4d3d65b..12ec916 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -794,7 +794,7 @@ struct atl1_adapter {
 	struct atl1_rrd_ring rrd_ring;
 	u64 hw_csum_err;
 	u64 hw_csum_good;
-
+	u32 msg_enable;
 	u16 imt;		/* interrupt moderator timer (2us resolution) */
 	u16 ict;		/* interrupt clear timer (2us resolution */
 	struct mii_if_info mii;	/* MII interface info */
-- 
1.5.3.8

