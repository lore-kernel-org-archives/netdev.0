From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 13/26] atl1: refactor interrupt handling
Date: Mon, 31 Dec 2007 20:22:40 -0600
Message-ID: <1199154173-4058-14-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:61218 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbYAAC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:12 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor interrupt handling to conform with the current vendor driver
version 1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |  196 ++++++++++++++++++++++-------------------------
 drivers/net/atlx/atl1.h |   25 +++++-
 drivers/net/atlx/atlx.c |    2 +-
 3 files changed, 114 insertions(+), 109 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index d38f26f..9c86ef4 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1740,12 +1740,11 @@ next:
 	return num_alloc;
 }
 
-static void atl1_intr_rx(struct atl1_adapter *adapter)
+static void atl1_clean_rx_irq(struct atl1_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	int i, count;
-	u16 length;
-	u16 rrd_next_to_clean;
-	u32 value;
+	u16 length, rrd_next_to_clean;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
 	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1_buffer *buffer_info;
@@ -1754,7 +1753,7 @@ static void atl1_intr_rx(struct atl1_adapter *adapter)
 
 	count = 0;
 
-	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
+	rrd_next_to_clean = (u16) atomic_read(&rrd_ring->next_to_clean);
 
 	while (1) {
 		rrd = ATL1_RRD_DESC(rrd_ring, rrd_next_to_clean);
@@ -1795,6 +1794,7 @@ chk_rrd:
 			/* bad rrd */
 			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"bad RRD\n");
+
 			/* see if update RFD index */
 			if (rrd->num_buf > 1)
 				atl1_update_rfd_index(adapter, rrd);
@@ -1823,13 +1823,18 @@ rrd_ok:
 		count++;
 
 		if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-			if (!(rrd->err_flg &
-				(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM
-				| ERR_FLAG_LEN))) {
-				/* packet error, don't need upstream */
-				buffer_info->alloced = 0;
-				rrd->xsz.valid = 0;
-				continue;
+			if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
+				ERR_FLAG_CODE | ERR_FLAG_OV)) {
+				if (!(netdev->flags & IFF_PROMISC)) {
+					/* packet error, don't need upstream */
+					buffer_info->alloced = 0;
+					rrd->xsz.valid = 0;
+					dev_printk(KERN_DEBUG,
+						&adapter->pdev->dev,
+						"rrd error flag 0x%08X\n",
+						rrd->err_flg);
+					continue;
+				}
 			}
 		}
 
@@ -1862,33 +1867,13 @@ rrd_ok:
 	}
 
 	atomic_set(&rrd_ring->next_to_clean, rrd_next_to_clean);
-
 	atl1_alloc_rx_buffers(adapter);
 
-	/* update mailbox ? */
-	if (count) {
-		u32 tpd_next_to_use;
-		u32 rfd_next_to_use;
-
-		spin_lock(&adapter->mb_lock);
-
-		tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
-		rfd_next_to_use =
-		    atomic_read(&adapter->rfd_ring.next_to_use);
-		rrd_next_to_clean =
-		    atomic_read(&adapter->rrd_ring.next_to_clean);
-		value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
-			MB_RFD_PROD_INDX_SHIFT) |
-                        ((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
-			MB_RRD_CONS_INDX_SHIFT) |
-                        ((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
-			MB_TPD_PROD_INDX_SHIFT);
-		iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
-		spin_unlock(&adapter->mb_lock);
-	}
+	if (count)
+		atl1_update_mailbox(adapter);
 }
 
-static void atl1_intr_tx(struct atl1_adapter *adapter)
+static bool atl1_clean_tx_irq(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
@@ -1905,7 +1890,7 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
 		if (buffer_info->dma) {
 			pci_unmap_page(adapter->pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+				buffer_info->length, PCI_DMA_TODEVICE);
 			buffer_info->dma = 0;
 		}
 
@@ -1922,6 +1907,11 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 	if (netif_queue_stopped(adapter->netdev)
 	    && netif_carrier_ok(adapter->netdev))
 		netif_wake_queue(adapter->netdev);
+
+	if (sw_tpd_next_to_clean == (u16) atomic_read(&tpd_ring->next_to_use))
+		return true;
+	else
+		return false;
 }
 
 static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
@@ -2285,80 +2275,75 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 static irqreturn_t atl1_intr(int irq, void *data)
 {
 	struct atl1_adapter *adapter = netdev_priv(data);
+	struct atl1_hw *hw = &adapter->hw;
 	u32 status;
-	u8 update_rx;
 	int max_ints = 10;
 
 	status = adapter->cmb.cmb->int_stats;
 	if (!status)
 		return IRQ_NONE;
 
-	update_rx = 0;
-
-	do {
-		/* clear CMB interrupt status at once */
-		adapter->cmb.cmb->int_stats = 0;
-
-		if (status & ISR_GPHY)	/* clear phy status */
-			atlx_clear_phy_int(adapter);
+loopint:
+	/* clear CMB interrupt status at once */
+	adapter->cmb.cmb->int_stats = 0;
 
-		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
-		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
+	if (status & ISR_GPHY)	/* clear phy status */
+		atlx_clear_phy_int(adapter);
 
-		/* check if SMB intr */
-		if (status & ISR_SMB)
-			atl1_inc_smb(adapter);
+	/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
+	status |= (ISR_DIS_INT | ISR_DIS_DMA);
+	iowrite32(status, adapter->hw.hw_addr + REG_ISR);
 
-		/* check if PCIE PHY Link down */
-		if (status & ISR_PHY_LINKDOWN) {
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"pcie phy link down %x\n", status);
-			if (netif_running(adapter->netdev)) {	/* reset MAC */
-				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-				schedule_work(&adapter->pcie_dma_to_rst_task);
-				return IRQ_HANDLED;
-			}
-		}
-
-		/* check if DMA read/write error ? */
-		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"pcie DMA r/w error (status = 0x%x)\n",
-				status);
-			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-			schedule_work(&adapter->pcie_dma_to_rst_task);
+	/* check if PCIE PHY Link down */
+	if (status & ISR_PHY_LINKDOWN) {
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+			"pcie phy link down %x\n", status);
+		if (netif_running(adapter->netdev)) {
+			/* reset MAC */
+			iowrite32(0, hw->hw_addr + REG_ISR);
+			iowrite32(0, hw->hw_addr + REG_IMR);
+			ioread32(hw->hw_addr + REG_IMR);
+			schedule_work(&adapter->reset_task);
 			return IRQ_HANDLED;
 		}
+	}
 
-		/* link event */
-		if (status & ISR_GPHY) {
-			adapter->soft_stats.tx_carrier_errors++;
-			atl1_check_for_link(adapter);
-		}
+	/* check if DMA read/write error ? */
+	if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+			"pcie DMA r/w error (status = 0x%x)\n",
+			status);
+		iowrite32(0, hw->hw_addr + REG_ISR);
+		iowrite32(0, hw->hw_addr + REG_IMR);
+		ioread32(hw->hw_addr + REG_IMR);
+		schedule_work(&adapter->reset_task);
+		return IRQ_HANDLED;
+	}
 
-		/* transmit event */
-		if (status & ISR_CMB_TX)
-			atl1_intr_tx(adapter);
-
-		/* rx exception */
-		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
-			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-				ISR_HOST_RRD_OV))
-				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-					"rx exception, ISR = 0x%x\n", status);
-			atl1_intr_rx(adapter);
-		}
+	/* check if SMB intr */
+	if (status & ISR_SMB)
+		atl1_inc_smb(adapter);
 
-		if (--max_ints < 0)
-			break;
+	/* link event */
+	if (status & (ISR_GPHY | ISR_MANUAL)) {
+		adapter->soft_stats.tx_carrier_errors++;
+		atl1_check_for_link(adapter);
+	}
+
+	/* transmit event */
+	if (status & ISR_TX_EVENT)
+		atl1_clean_tx_irq(adapter);
 
-	} while ((status = adapter->cmb.cmb->int_stats));
+	/* rx event */
+	if (status & ISR_RX_EVENT)
+		atl1_clean_rx_irq(adapter);
 
-	/* re-enable Interrupt */
-	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
+	status = adapter->cmb.cmb->int_stats;
+	if ((--max_ints > 0) && status)
+		goto loopint;
+
+	/* re-enable interrupts */
+	iowrite32((ISR_DIS_SMB | ISR_DIS_DMA), adapter->hw.hw_addr + REG_ISR);
 	return IRQ_HANDLED;
 }
 
@@ -2460,16 +2445,22 @@ void atl1_down(struct atl1_adapter *adapter)
 	atl1_clean_rx_ring(adapter);
 }
 
-static void atl1_tx_timeout_task(struct work_struct *work)
+static void atl1_reinit_locked(struct atl1_adapter *adapter)
 {
-	struct atl1_adapter *adapter =
-		container_of(work, struct atl1_adapter, tx_timeout_task);
-	struct net_device *netdev = adapter->netdev;
-
-	netif_device_detach(netdev);
+	WARN_ON(in_interrupt());
+	while (test_and_set_bit(__ATL1_RESETTING, &adapter->flags))
+		msleep(1);
 	atl1_down(adapter);
 	atl1_up(adapter);
-	netif_device_attach(netdev);
+	clear_bit(__ATL1_RESETTING, &adapter->flags);
+}
+
+static void atl1_reset_task(struct work_struct *work)
+{
+	struct atl1_adapter *adapter;
+
+	adapter = container_of(work, struct atl1_adapter, reset_task);
+	atl1_reinit_locked(adapter);
 }
 
 /*
@@ -2857,12 +2848,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	adapter->phy_config_timer.data = (unsigned long)adapter;
 	adapter->phy_timer_pending = false;
 
-	INIT_WORK(&adapter->tx_timeout_task, atl1_tx_timeout_task);
-
+	INIT_WORK(&adapter->reset_task, atl1_reset_task);
 	INIT_WORK(&adapter->link_chg_task, atlx_link_chg_task);
 
-	INIT_WORK(&adapter->pcie_dma_to_rst_task, atl1_tx_timeout_task);
-
 	err = register_netdev(netdev);
 	if (err)
 		goto err_common;
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 2c2570e..8198f82 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -262,7 +262,7 @@ extern const struct ethtool_ops atl1_ethtool_ops;
 #define ISR_RRD_OV				0x20
 #define ISR_TXF_UNRUN				0x40
 #define ISR_LINK				0x80
-#define ISR_HOST_RFD_UNRUN			0x100
+#define ISR_HOST_RFD_UR				0x100
 #define ISR_HOST_RRD_OV				0x200
 #define ISR_DMAR_TO_RST				0x400
 #define ISR_DMAW_TO_RST				0x800
@@ -288,6 +288,24 @@ extern const struct ethtool_ops atl1_ethtool_ops;
 	ISR_CMB_TX	|\
 	ISR_CMB_RX)
 
+#define ISR_TX_EVENT	(\
+	ISR_TXF_UNRUN	|\
+	ISR_TX_PKT	|\
+	ISR_TX_DMA	|\
+	ISR_CMB_TX	|\
+	ISR_MAC_TX)
+
+#define ISR_RX_EVENT	(\
+	ISR_RXF_OV	|\
+	ISR_RFD_UNRUN	|\
+	ISR_RRD_OV	|\
+	ISR_HOST_RFD_UR	|\
+	ISR_HOST_RRD_OV	|\
+	ISR_RX_PKT	|\
+	ISR_RX_DMA	|\
+	ISR_CMB_RX	|\
+	ISR_MAC_RX)
+
 /* Debug Interrupt Mask  (enable all interrupt) */
 #define IMR_DEBUG_MASK	(\
 	ISR_SMB		|\
@@ -762,10 +780,8 @@ struct atl1_adapter {
 	u32 wol;
 	u16 link_speed;
 	u16 link_duplex;
-	spinlock_t lock;
-	struct work_struct tx_timeout_task;
+	struct work_struct reset_task;
 	struct work_struct link_chg_task;
-	struct work_struct pcie_dma_to_rst_task;
 	struct timer_list watchdog_timer;
 	struct timer_list phy_config_timer;
 	bool phy_timer_pending;
@@ -776,6 +792,7 @@ struct atl1_adapter {
 	/* TX */
 	struct atl1_tpd_ring tpd_ring;
 	spinlock_t mb_lock;
+	spinlock_t lock;
 
 	/* RX */
 	struct atl1_rfd_ring rfd_ring;
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 354050f..18c2d7e 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -204,7 +204,7 @@ static void atlx_tx_timeout(struct net_device *netdev)
 {
 	struct atlx_adapter *adapter = netdev_priv(netdev);
 	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->tx_timeout_task);
+	schedule_work(&adapter->reset_task);
 }
 
 /*
-- 
1.5.3.3

