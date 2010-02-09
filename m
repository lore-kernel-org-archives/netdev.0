From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 2/7] drivers/net/atl1e: Use netdev_printk helpers
Date: Tue,  9 Feb 2010 13:49:48 -0800
Message-ID: <3984b8f2f8024231a3a82707f0a79e73205c2b4f.1265751024.git.joe@perches.com>
References: <cover.1265751023.git.joe@perches.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1909 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186Ab0BIVtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 16:49:55 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Logging messages sometimes had duplicated "ATL1E" output.

For instance:
ATL1E 0000:03:00.0: ATL1E: eth0 NIC Link is Up<100 Mbps Full Duplex>
is now:
ATL1E 0000:03:00.0: eth0: NIC Link is Up <100 Mbps Full Duplex>

Add some consistency to logging messages
Add some missing \n's to logging messages
Miscellaneous typo spelling corrections
Change atl1e_validate_option argument from pdev to adapter

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/atl1e/atl1e_hw.c    |   23 +++---
 drivers/net/atl1e/atl1e_main.c  |  153 +++++++++++++++++----------------------
 drivers/net/atl1e/atl1e_param.c |   35 +++++----
 3 files changed, 99 insertions(+), 112 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 4a77006..76cc043 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -394,7 +394,6 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
 int atl1e_phy_commit(struct atl1e_hw *hw)
 {
 	struct atl1e_adapter *adapter = hw->adapter;
-	struct pci_dev *pdev = adapter->pdev;
 	int ret_val;
 	u16 phy_data;
 
@@ -415,12 +414,12 @@ int atl1e_phy_commit(struct atl1e_hw *hw)
 		}
 
 		if (0 != (val & (MDIO_START | MDIO_BUSY))) {
-			dev_err(&pdev->dev,
-				"pcie linkdown at least for 25ms\n");
+			netdev_err(adapter->netdev,
+				   "pcie linkdown at least for 25ms\n");
 			return ret_val;
 		}
 
-		dev_err(&pdev->dev, "pcie linkup after %d ms\n", i);
+		netdev_err(adapter->netdev, "pcie linkup after %d ms\n", i);
 	}
 	return 0;
 }
@@ -428,7 +427,6 @@ int atl1e_phy_commit(struct atl1e_hw *hw)
 int atl1e_phy_init(struct atl1e_hw *hw)
 {
 	struct atl1e_adapter *adapter = hw->adapter;
-	struct pci_dev *pdev = adapter->pdev;
 	s32 ret_val;
 	u16 phy_val;
 
@@ -492,20 +490,22 @@ int atl1e_phy_init(struct atl1e_hw *hw)
 	/*Enable PHY LinkChange Interrupt */
 	ret_val = atl1e_write_phy_reg(hw, MII_INT_CTRL, 0xC00);
 	if (ret_val) {
-		dev_err(&pdev->dev, "Error enable PHY linkChange Interrupt\n");
+		netdev_err(adapter->netdev,
+			   "Error enable PHY linkChange Interrupt\n");
 		return ret_val;
 	}
 	/* setup AutoNeg parameters */
 	ret_val = atl1e_phy_setup_autoneg_adv(hw);
 	if (ret_val) {
-		dev_err(&pdev->dev, "Error Setting up Auto-Negotiation\n");
+		netdev_err(adapter->netdev,
+			   "Error Setting up Auto-Negotiation\n");
 		return ret_val;
 	}
 	/* SW.Reset & En-Auto-Neg to restart Auto-Neg*/
-	dev_dbg(&pdev->dev, "Restarting Auto-Neg");
+	netdev_dbg(adapter->netdev, "Restarting Auto-Negotiation\n");
 	ret_val = atl1e_phy_commit(hw);
 	if (ret_val) {
-		dev_err(&pdev->dev, "Error Resetting the phy");
+		netdev_err(adapter->netdev, "Error resetting the phy\n");
 		return ret_val;
 	}
 
@@ -559,9 +559,8 @@ int atl1e_reset_hw(struct atl1e_hw *hw)
 	}
 
 	if (timeout >= AT_HW_MAX_IDLE_DELAY) {
-		dev_err(&pdev->dev,
-			"MAC state machine cann't be idle since"
-			" disabled for 10ms second\n");
+		netdev_err(adapter->netdev,
+			   "MAC state machine can't be idle since disabled for 10ms second\n");
 		return AT_ERR_TIMEOUT;
 	}
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index d59f8e8..7d8de10 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -164,11 +164,10 @@ static int atl1e_check_link(struct atl1e_adapter *adapter)
 {
 	struct atl1e_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	struct pci_dev    *pdev   = adapter->pdev;
 	int err = 0;
 	u16 speed, duplex, phy_data;
 
-	/* MII_BMSR must read twise */
+	/* MII_BMSR must read twice */
 	atl1e_read_phy_reg(hw, MII_BMSR, &phy_data);
 	atl1e_read_phy_reg(hw, MII_BMSR, &phy_data);
 	if ((phy_data & BMSR_LSTATUS) == 0) {
@@ -195,12 +194,11 @@ static int atl1e_check_link(struct atl1e_adapter *adapter)
 			adapter->link_speed  = speed;
 			adapter->link_duplex = duplex;
 			atl1e_setup_mac_ctrl(adapter);
-			dev_info(&pdev->dev,
-				"%s: %s NIC Link is Up<%d Mbps %s>\n",
-				atl1e_driver_name, netdev->name,
-				adapter->link_speed,
-				adapter->link_duplex == FULL_DUPLEX ?
-				"Full Duplex" : "Half Duplex");
+			netdev_info(netdev,
+				    "NIC Link is Up <%d Mbps %s Duplex>\n",
+				    adapter->link_speed,
+				    adapter->link_duplex == FULL_DUPLEX ?
+				    "Full" : "Half");
 		}
 
 		if (!netif_carrier_ok(netdev)) {
@@ -230,7 +228,6 @@ static void atl1e_link_chg_task(struct work_struct *work)
 static void atl1e_link_chg_event(struct atl1e_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	struct pci_dev    *pdev   = adapter->pdev;
 	u16 phy_data = 0;
 	u16 link_up = 0;
 
@@ -243,8 +240,7 @@ static void atl1e_link_chg_event(struct atl1e_adapter *adapter)
 	if (!link_up) {
 		if (netif_carrier_ok(netdev)) {
 			/* old link state: Up */
-			dev_info(&pdev->dev, "%s: %s NIC Link is Down\n",
-					atl1e_driver_name, netdev->name);
+			netdev_info(netdev, "NIC Link is Down\n");
 			adapter->link_speed = SPEED_0;
 			netif_stop_queue(netdev);
 		}
@@ -321,10 +317,9 @@ static void atl1e_vlan_rx_register(struct net_device *netdev,
 				   struct vlan_group *grp)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
-	struct pci_dev *pdev = adapter->pdev;
 	u32 mac_ctrl_data = 0;
 
-	dev_dbg(&pdev->dev, "atl1e_vlan_rx_register\n");
+	netdev_dbg(adapter->netdev, "%s\n", __func__);
 
 	atl1e_irq_disable(adapter);
 
@@ -345,9 +340,7 @@ static void atl1e_vlan_rx_register(struct net_device *netdev,
 
 static void atl1e_restore_vlan(struct atl1e_adapter *adapter)
 {
-	struct pci_dev *pdev = adapter->pdev;
-
-	dev_dbg(&pdev->dev, "atl1e_restore_vlan !");
+	netdev_dbg(adapter->netdev, "%s\n", __func__);
 	atl1e_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 }
 /*
@@ -391,7 +384,7 @@ static int atl1e_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 			(max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
+		netdev_warn(adapter->netdev, "invalid MTU setting\n");
 		return -EINVAL;
 	}
 	/* set MTU */
@@ -438,7 +431,6 @@ static int atl1e_mii_ioctl(struct net_device *netdev,
 			   struct ifreq *ifr, int cmd)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
-	struct pci_dev *pdev = adapter->pdev;
 	struct mii_ioctl_data *data = if_mii(ifr);
 	unsigned long flags;
 	int retval = 0;
@@ -466,8 +458,8 @@ static int atl1e_mii_ioctl(struct net_device *netdev,
 			goto out;
 		}
 
-		dev_dbg(&pdev->dev, "<atl1e_mii_ioctl> write %x %x",
-				data->reg_num, data->val_in);
+		netdev_dbg(adapter->netdev, "<atl1e_mii_ioctl> write %x %x\n",
+			   data->reg_num, data->val_in);
 		if (atl1e_write_phy_reg(&adapter->hw,
 				     data->reg_num, data->val_in)) {
 			retval = -EIO;
@@ -602,7 +594,7 @@ static int __devinit atl1e_sw_init(struct atl1e_adapter *adapter)
 	hw->dmaw_dly_cnt = 4;
 
 	if (atl1e_alloc_queues(adapter)) {
-		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
+		netdev_err(adapter->netdev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
 
@@ -800,8 +792,8 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 			adapter->ring_size, &adapter->ring_dma);
 
 	if (adapter->ring_vir_addr == NULL) {
-		dev_err(&pdev->dev, "pci_alloc_consistent failed, "
-				    "size = D%d", size);
+		netdev_err(adapter->netdev,
+			   "pci_alloc_consistent failed, size = D%d\n", size);
 		return -ENOMEM;
 	}
 
@@ -817,7 +809,8 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 	size = sizeof(struct atl1e_tx_buffer) * (tx_ring->count);
 	tx_ring->tx_buffer = kzalloc(size, GFP_KERNEL);
 	if (tx_ring->tx_buffer == NULL) {
-		dev_err(&pdev->dev, "kzalloc failed , size = D%d", size);
+		netdev_err(adapter->netdev, "kzalloc failed, size = D%d\n",
+			   size);
 		err = -ENOMEM;
 		goto failed;
 	}
@@ -852,8 +845,8 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 	}
 
 	if (unlikely(offset > adapter->ring_size)) {
-		dev_err(&pdev->dev, "offset(%d) > ring size(%d) !!\n",
-				offset, adapter->ring_size);
+		netdev_err(adapter->netdev, "offset(%d) > ring size(%d) !!\n",
+			   offset, adapter->ring_size);
 		err = -1;
 		goto failed;
 	}
@@ -1077,7 +1070,6 @@ static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
 static int atl1e_configure(struct atl1e_adapter *adapter)
 {
 	struct atl1e_hw *hw = &adapter->hw;
-	struct pci_dev *pdev = adapter->pdev;
 
 	u32 intr_status_data = 0;
 
@@ -1130,8 +1122,8 @@ static int atl1e_configure(struct atl1e_adapter *adapter)
 
 	intr_status_data = AT_READ_REG(hw, REG_ISR);
 	if (unlikely((intr_status_data & ISR_PHY_LINKDOWN) != 0)) {
-		dev_err(&pdev->dev, "atl1e_configure failed,"
-				"PCIE phy link down\n");
+		netdev_err(adapter->netdev,
+			   "atl1e_configure failed, PCIE phy link down\n");
 		return -1;
 	}
 
@@ -1262,7 +1254,6 @@ static irqreturn_t atl1e_intr(int irq, void *data)
 {
 	struct net_device *netdev  = data;
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
-	struct pci_dev *pdev = adapter->pdev;
 	struct atl1e_hw *hw = &adapter->hw;
 	int max_ints = AT_MAX_INT_WORK;
 	int handled = IRQ_NONE;
@@ -1285,8 +1276,8 @@ static irqreturn_t atl1e_intr(int irq, void *data)
 		handled = IRQ_HANDLED;
 		/* check if PCIE PHY Link down */
 		if (status & ISR_PHY_LINKDOWN) {
-			dev_err(&pdev->dev,
-				"pcie phy linkdown %x\n", status);
+			netdev_err(adapter->netdev,
+				   "pcie phy linkdown %x\n", status);
 			if (netif_running(adapter->netdev)) {
 				/* reset MAC */
 				atl1e_irq_reset(adapter);
@@ -1297,9 +1288,9 @@ static irqreturn_t atl1e_intr(int irq, void *data)
 
 		/* check if DMA read/write error */
 		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			dev_err(&pdev->dev,
-				"PCIE DMA RW error (status = 0x%x)\n",
-				status);
+			netdev_err(adapter->netdev,
+				   "PCIE DMA RW error (status = 0x%x)\n",
+				   status);
 			atl1e_irq_reset(adapter);
 			schedule_work(&adapter->reset_task);
 			break;
@@ -1382,7 +1373,6 @@ static struct atl1e_rx_page *atl1e_get_rx_page(struct atl1e_adapter *adapter,
 static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 		   int *work_done, int work_to_do)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev  = adapter->netdev;
 	struct atl1e_rx_ring *rx_ring = (struct atl1e_rx_ring *)
 					 &adapter->rx_ring;
@@ -1404,11 +1394,10 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 						 rx_page->read_offset);
 			/* check sequence number */
 			if (prrs->seq_num != rx_page_desc[que].rx_nxseq) {
-				dev_err(&pdev->dev,
-					"rx sequence number"
-					" error (rx=%d) (expect=%d)\n",
-					prrs->seq_num,
-					rx_page_desc[que].rx_nxseq);
+				netdev_err(netdev,
+					   "rx sequence number error (rx=%d) (expect=%d)\n",
+					   prrs->seq_num,
+					   rx_page_desc[que].rx_nxseq);
 				rx_page_desc[que].rx_nxseq++;
 				/* just for debug use */
 				AT_WRITE_REG(&adapter->hw, REG_DEBUG_DATA0,
@@ -1424,9 +1413,9 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 					RRS_ERR_DRIBBLE | RRS_ERR_CODE |
 					RRS_ERR_TRUNC)) {
 				/* hardware error, discard this packet*/
-					dev_err(&pdev->dev,
-						"rx packet desc error %x\n",
-						*((u32 *)prrs + 1));
+					netdev_err(netdev,
+						   "rx packet desc error %x\n",
+						   *((u32 *)prrs + 1));
 					goto skip_pkt;
 				}
 			}
@@ -1435,8 +1424,8 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 					RRS_PKT_SIZE_MASK) - 4; /* CRC */
 			skb = netdev_alloc_skb_ip_align(netdev, packet_size);
 			if (skb == NULL) {
-				dev_warn(&pdev->dev, "%s: Memory squeeze,"
-					"deferring packet.\n", netdev->name);
+				netdev_warn(netdev,
+					    "Memory squeeze, deferring packet\n");
 				goto skip_pkt;
 			}
 			skb->dev = netdev;
@@ -1450,9 +1439,9 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 				u16 vlan_tag = (prrs->vtag >> 4) |
 					       ((prrs->vtag & 7) << 13) |
 					       ((prrs->vtag & 8) << 9);
-				dev_dbg(&pdev->dev,
-					"RXD VLAN TAG<RRD>=0x%04x\n",
-					prrs->vtag);
+				netdev_dbg(netdev,
+					   "RXD VLAN TAG<RRD>=0x%04x\n",
+					   prrs->vtag);
 				vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 							 vlan_tag);
 			} else {
@@ -1500,7 +1489,6 @@ static int atl1e_clean(struct napi_struct *napi, int budget)
 {
 	struct atl1e_adapter *adapter =
 			container_of(napi, struct atl1e_adapter, napi);
-	struct pci_dev    *pdev    = adapter->pdev;
 	u32 imr_data;
 	int work_done = 0;
 
@@ -1519,8 +1507,8 @@ quit_polling:
 		/* test debug */
 		if (test_bit(__AT_DOWN, &adapter->flags)) {
 			atomic_dec(&adapter->irq_sem);
-			dev_err(&pdev->dev,
-				"atl1e_clean is called when AT_DOWN\n");
+			netdev_err(adapter->netdev,
+				   "atl1e_clean is called when AT_DOWN\n");
 		}
 		/* reenable RX intr */
 		/*atl1e_irq_enable(adapter); */
@@ -1618,7 +1606,6 @@ static u16 atl1e_cal_tdp_req(const struct sk_buff *skb)
 static int atl1e_tso_csum(struct atl1e_adapter *adapter,
 		       struct sk_buff *skb, struct atl1e_tpd_desc *tpd)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	u8 hdr_len;
 	u32 real_len;
 	unsigned short offload_type;
@@ -1642,8 +1629,8 @@ static int atl1e_tso_csum(struct atl1e_adapter *adapter,
 			hdr_len = (skb_transport_offset(skb) + tcp_hdrlen(skb));
 			if (unlikely(skb->len == hdr_len)) {
 				/* only xsum need */
-				dev_warn(&pdev->dev,
-				      "IPV4 tso with zero data??\n");
+				netdev_warn(adapter->netdev,
+					    "IPV4 tso with zero data??\n");
 				goto check_sum;
 			} else {
 				ip_hdr(skb)->check = 0;
@@ -1672,8 +1659,8 @@ check_sum:
 
 		cso = skb_transport_offset(skb);
 		if (unlikely(cso & 0x1)) {
-			dev_err(&adapter->pdev->dev,
-			   "pay load offset should not ant event number\n");
+			netdev_err(adapter->netdev,
+				   "payload offset should not ant event number\n");
 			return -1;
 		} else {
 			css = cso + skb->csum_offset;
@@ -1886,8 +1873,8 @@ static int atl1e_request_irq(struct atl1e_adapter *adapter)
 	adapter->have_msi = true;
 	err = pci_enable_msi(adapter->pdev);
 	if (err) {
-		dev_dbg(&pdev->dev,
-			"Unable to allocate MSI interrupt Error: %d\n", err);
+		netdev_dbg(adapter->netdev,
+			   "Unable to allocate MSI interrupt Error: %d\n", err);
 		adapter->have_msi = false;
 	} else
 		netdev->irq = pdev->irq;
@@ -1898,13 +1885,13 @@ static int atl1e_request_irq(struct atl1e_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, atl1e_intr, flags,
 			netdev->name, netdev);
 	if (err) {
-		dev_dbg(&pdev->dev,
-			"Unable to allocate interrupt Error: %d\n", err);
+		netdev_dbg(adapter->netdev,
+			   "Unable to allocate interrupt Error: %d\n", err);
 		if (adapter->have_msi)
 			pci_disable_msi(adapter->pdev);
 		return err;
 	}
-	dev_dbg(&pdev->dev, "atl1e_request_irq OK\n");
+	netdev_dbg(adapter->netdev, "atl1e_request_irq OK\n");
 	return err;
 }
 
@@ -2078,7 +2065,7 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 		    (atl1e_write_phy_reg(hw,
 			   MII_ADVERTISE, mii_advertise_data) != 0) ||
 		    (atl1e_phy_commit(hw)) != 0) {
-			dev_dbg(&pdev->dev, "set phy register failed\n");
+			netdev_dbg(adapter->netdev, "set phy register failed\n");
 			goto wol_dis;
 		}
 
@@ -2100,17 +2087,14 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 				}
 
 				if ((mii_bmsr_data & BMSR_LSTATUS) == 0)
-					dev_dbg(&pdev->dev,
-						"%s: Link may change"
-						"when suspend\n",
-						atl1e_driver_name);
+					netdev_dbg(adapter->netdev,
+						   "Link may change when suspend\n");
 			}
 			wol_ctrl_data |=  WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN;
 			/* only link up can wake up */
 			if (atl1e_write_phy_reg(hw, MII_INT_CTRL, 0x400) != 0) {
-				dev_dbg(&pdev->dev, "%s: read write phy "
-						  "register failed.\n",
-						  atl1e_driver_name);
+				netdev_dbg(adapter->netdev,
+					   "read write phy register failed\n");
 				goto wol_dis;
 			}
 		}
@@ -2131,9 +2115,8 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 		if (wufc & AT_WUFC_MAG)
 			mac_ctrl_data |= MAC_CTRL_BC_EN;
 
-		dev_dbg(&pdev->dev,
-			"%s: suspend MAC=0x%x\n",
-			atl1e_driver_name, mac_ctrl_data);
+		netdev_dbg(adapter->netdev, "suspend MAC=0x%x\n",
+			   mac_ctrl_data);
 
 		AT_WRITE_REG(hw, REG_WOL_CTRL, wol_ctrl_data);
 		AT_WRITE_REG(hw, REG_MAC_CTRL, mac_ctrl_data);
@@ -2183,8 +2166,8 @@ static int atl1e_resume(struct pci_dev *pdev)
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		dev_err(&pdev->dev, "ATL1e: Cannot enable PCI"
-				" device from suspend\n");
+		netdev_err(adapter->netdev,
+			   "Cannot enable PCI device from suspend\n");
 		return err;
 	}
 
@@ -2315,7 +2298,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 
 	err = atl1e_init_netdev(netdev, pdev);
 	if (err) {
-		dev_err(&pdev->dev, "init netdevice failed\n");
+		netdev_err(netdev, "init netdevice failed\n");
 		goto err_init_netdev;
 	}
 	adapter = netdev_priv(netdev);
@@ -2326,7 +2309,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 	adapter->hw.hw_addr = pci_iomap(pdev, BAR_0, 0);
 	if (!adapter->hw.hw_addr) {
 		err = -EIO;
-		dev_err(&pdev->dev, "cannot map device registers\n");
+		netdev_err(netdev, "cannot map device registers\n");
 		goto err_ioremap;
 	}
 	netdev->base_addr = (unsigned long)adapter->hw.hw_addr;
@@ -2356,7 +2339,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 	/* setup the private structure */
 	err = atl1e_sw_init(adapter);
 	if (err) {
-		dev_err(&pdev->dev, "net device private data init failed\n");
+		netdev_err(netdev, "net device private data init failed\n");
 		goto err_sw_init;
 	}
 
@@ -2372,19 +2355,19 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 
 	if (atl1e_read_mac_addr(&adapter->hw) != 0) {
 		err = -EIO;
-		dev_err(&pdev->dev, "get mac address failed\n");
+		netdev_err(netdev, "get mac address failed\n");
 		goto err_eeprom;
 	}
 
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
-	dev_dbg(&pdev->dev, "mac address : %pM\n", adapter->hw.mac_addr);
+	netdev_dbg(netdev, "mac address : %pM\n", adapter->hw.mac_addr);
 
 	INIT_WORK(&adapter->reset_task, atl1e_reset_task);
 	INIT_WORK(&adapter->link_chg_task, atl1e_link_chg_task);
 	err = register_netdev(netdev);
 	if (err) {
-		dev_err(&pdev->dev, "register netdevice failed\n");
+		netdev_err(netdev, "register netdevice failed\n");
 		goto err_register;
 	}
 
@@ -2485,8 +2468,8 @@ static pci_ers_result_t atl1e_io_slot_reset(struct pci_dev *pdev)
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
-		dev_err(&pdev->dev,
-		       "ATL1e: Cannot re-enable PCI device after reset.\n");
+		netdev_err(adapter->netdev,
+			   "Cannot re-enable PCI device after reset\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}
 	pci_set_master(pdev);
@@ -2514,8 +2497,8 @@ static void atl1e_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (atl1e_up(adapter)) {
-			dev_err(&pdev->dev,
-			  "ATL1e: can't bring device back up after reset\n");
+			netdev_err(adapter->netdev,
+				   "can't bring device back up after reset\n");
 			return;
 		}
 	}
diff --git a/drivers/net/atl1e/atl1e_param.c b/drivers/net/atl1e/atl1e_param.c
index b3be59f..0ce60b6 100644
--- a/drivers/net/atl1e/atl1e_param.c
+++ b/drivers/net/atl1e/atl1e_param.c
@@ -116,7 +116,7 @@ struct atl1e_option {
 	} arg;
 };
 
-static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt, struct pci_dev *pdev)
+static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt, struct atl1e_adapter *adapter)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -127,16 +127,19 @@ static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt,
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			dev_info(&pdev->dev, "%s Enabled\n", opt->name);
+			netdev_info(adapter->netdev,
+				    "%s Enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			dev_info(&pdev->dev, "%s Disabled\n", opt->name);
+			netdev_info(adapter->netdev,
+				    "%s Disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			dev_info(&pdev->dev, "%s set to %i\n", opt->name, *value);
+			netdev_info(adapter->netdev, "%s set to %i\n",
+				    opt->name, *value);
 			return 0;
 		}
 		break;
@@ -148,8 +151,8 @@ static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt,
 				ent = &opt->arg.l.p[i];
 				if (*value == ent->i) {
 					if (ent->str[0] != '\0')
-						dev_info(&pdev->dev, "%s\n",
-							ent->str);
+						netdev_info(adapter->netdev,
+							    "%s\n", ent->str);
 					return 0;
 				}
 			}
@@ -159,8 +162,8 @@ static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt,
 		BUG();
 	}
 
-	dev_info(&pdev->dev, "Invalid %s specified (%i) %s\n",
-			opt->name, *value, opt->err);
+	netdev_info(adapter->netdev, "Invalid %s specified (%i) %s\n",
+		    opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -176,11 +179,13 @@ static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt,
  */
 void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	int bd = adapter->bd_number;
+
 	if (bd >= ATL1E_MAX_NIC) {
-		dev_notice(&pdev->dev, "no configuration for board #%i\n", bd);
-		dev_notice(&pdev->dev, "Using defaults for all values\n");
+		netdev_notice(adapter->netdev,
+			      "no configuration for board #%i\n", bd);
+		netdev_notice(adapter->netdev,
+			      "Using defaults for all values\n");
 	}
 
 	{ 		/* Transmit Ring Size */
@@ -196,7 +201,7 @@ void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
 		int val;
 		if (num_tx_desc_cnt > bd) {
 			val = tx_desc_cnt[bd];
-			atl1e_validate_option(&val, &opt, pdev);
+			atl1e_validate_option(&val, &opt, adapter);
 			adapter->tx_ring.count = (u16) val & 0xFFFC;
 		} else
 			adapter->tx_ring.count = (u16)opt.def;
@@ -215,7 +220,7 @@ void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
 		int val;
 		if (num_rx_mem_size > bd) {
 			val = rx_mem_size[bd];
-			atl1e_validate_option(&val, &opt, pdev);
+			atl1e_validate_option(&val, &opt, adapter);
 			adapter->rx_ring.page_size = (u32)val * 1024;
 		} else {
 			adapter->rx_ring.page_size = (u32)opt.def * 1024;
@@ -235,7 +240,7 @@ void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
 		int val;
 		if (num_int_mod_timer > bd) {
 			val = int_mod_timer[bd];
-			atl1e_validate_option(&val, &opt, pdev);
+			atl1e_validate_option(&val, &opt, adapter);
 			adapter->hw.imt = (u16) val;
 		} else
 			adapter->hw.imt = (u16)(opt.def);
@@ -254,7 +259,7 @@ void __devinit atl1e_check_options(struct atl1e_adapter *adapter)
 		int val;
 		if (num_media_type > bd) {
 			val = media_type[bd];
-			atl1e_validate_option(&val, &opt, pdev);
+			atl1e_validate_option(&val, &opt, adapter);
 			adapter->hw.media_type = (u16) val;
 		} else
 			adapter->hw.media_type = (u16)(opt.def);
-- 
1.7.0.rc1.33.g07cf0f

