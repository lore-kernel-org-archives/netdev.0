From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 3/5] atl1: cleanup atl1_main
Date: Sun, 15 Jul 2007 11:03:27 -0500
Message-ID: <11845154093583-git-send-email-jacliburn@bellsouth.net>
References: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Cc: jacliburn@bellsouth.net, csnook@redhat.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:35329 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759293AbXGOQDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 12:03:32 -0400
In-Reply-To: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix indentation, remove dead code, improve some comments, change dev_dbg to
dev_printk.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |  278 +++++++++++++++++++++---------------------
 1 files changed, 137 insertions(+), 141 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 6c8cf98..b40f1c7 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -38,7 +38,7 @@
  * TODO:
  * Fix TSO; tx performance is horrible with TSO enabled.
  * Wake on LAN.
- * Add more ethtool functions, including set ring parameters.
+ * Add more ethtool functions.
  * Fix abstruse irq enable/disable condition described here:
  *	http://marc.theaimsgroup.com/?l=linux-netdev&m=116398508500553&w=2
  *
@@ -191,19 +191,22 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 		goto err_nomem;
 	}
 	rfd_ring->buffer_info =
-	    (struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
+		(struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
 
-	/* real ring DMA buffer */
-	ring_header->size = size = sizeof(struct tx_packet_desc) *
-					tpd_ring->count
-	    + sizeof(struct rx_free_desc) * rfd_ring->count
-	    + sizeof(struct rx_return_desc) * rrd_ring->count
-	    + sizeof(struct coals_msg_block)
-	    + sizeof(struct stats_msg_block)
-	    + 40;		/* "40: for 8 bytes align" huh? -- CHS */
+	/* real ring DMA buffer
+	 * each ring/block may need up to 8 bytes for alignment, hence the
+	 * additional 40 bytes tacked onto the end.
+	 */
+	ring_header->size = size =
+		sizeof(struct tx_packet_desc) * tpd_ring->count
+		+ sizeof(struct rx_free_desc) * rfd_ring->count
+		+ sizeof(struct rx_return_desc) * rrd_ring->count
+		+ sizeof(struct coals_msg_block)
+		+ sizeof(struct stats_msg_block)
+		+ 40;
 
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
-						&ring_header->dma);
+		&ring_header->dma);
 	if (unlikely(!ring_header->desc)) {
 		dev_err(&pdev->dev, "pci_alloc_consistent failed\n");
 		goto err_nomem;
@@ -227,7 +230,6 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	rfd_ring->desc = (u8 *) tpd_ring->desc + (tpd_ring->size + offset);
 	rfd_ring->size = sizeof(struct rx_free_desc) * rfd_ring->count;
 	rfd_ring->next_to_clean = 0;
-	/* rfd_ring->next_to_use = rfd_ring->count - 1; */
 	atomic_set(&rfd_ring->next_to_use, 0);
 
 	/* init RRD ring */
@@ -243,16 +245,16 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	adapter->cmb.dma = rrd_ring->dma + rrd_ring->size;
 	offset = (adapter->cmb.dma & 0x7) ? (8 - (adapter->cmb.dma & 0x7)) : 0;
 	adapter->cmb.dma += offset;
-	adapter->cmb.cmb =
-	    (struct coals_msg_block *) ((u8 *) rrd_ring->desc +
-				   (rrd_ring->size + offset));
+	adapter->cmb.cmb = (struct coals_msg_block *)
+		((u8 *) rrd_ring->desc + (rrd_ring->size + offset));
 
 	/* init SMB */
 	adapter->smb.dma = adapter->cmb.dma + sizeof(struct coals_msg_block);
 	offset = (adapter->smb.dma & 0x7) ? (8 - (adapter->smb.dma & 0x7)) : 0;
 	adapter->smb.dma += offset;
 	adapter->smb.smb = (struct stats_msg_block *)
-	    ((u8 *) adapter->cmb.cmb + (sizeof(struct coals_msg_block) + offset));
+		((u8 *) adapter->cmb.cmb +
+		(sizeof(struct coals_msg_block) + offset));
 
 	return ATL1_SUCCESS;
 
@@ -291,25 +293,19 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
 	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
 	adapter->soft_stats.multicast += smb->rx_mcast;
-	adapter->soft_stats.collisions += (smb->tx_1_col +
-					   smb->tx_2_col * 2 +
-					   smb->tx_late_col +
-					   smb->tx_abort_col *
-					   adapter->hw.max_retry);
+	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col * 2 +
+		smb->tx_late_col + smb->tx_abort_col * adapter->hw.max_retry);
 
 	/* Rx Errors */
-	adapter->soft_stats.rx_errors += (smb->rx_frag +
-					  smb->rx_fcs_err +
-					  smb->rx_len_err +
-					  smb->rx_sz_ov +
-					  smb->rx_rxf_ov +
-					  smb->rx_rrd_ov + smb->rx_align_err);
+	adapter->soft_stats.rx_errors += (smb->rx_frag + smb->rx_fcs_err +
+		smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
+		smb->rx_rrd_ov + smb->rx_align_err);
 	adapter->soft_stats.rx_fifo_errors += smb->rx_rxf_ov;
 	adapter->soft_stats.rx_length_errors += smb->rx_len_err;
 	adapter->soft_stats.rx_crc_errors += smb->rx_fcs_err;
 	adapter->soft_stats.rx_frame_errors += smb->rx_align_err;
 	adapter->soft_stats.rx_missed_errors += (smb->rx_rrd_ov +
-						 smb->rx_rxf_ov);
+		smb->rx_rxf_ov);
 
 	adapter->soft_stats.rx_pause += smb->rx_pause;
 	adapter->soft_stats.rx_rrd_ov += smb->rx_rrd_ov;
@@ -317,8 +313,7 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 
 	/* Tx Errors */
 	adapter->soft_stats.tx_errors += (smb->tx_late_col +
-					  smb->tx_abort_col +
-					  smb->tx_underrun + smb->tx_trunc);
+		smb->tx_abort_col + smb->tx_underrun + smb->tx_trunc);
 	adapter->soft_stats.tx_fifo_errors += smb->tx_underrun;
 	adapter->soft_stats.tx_aborted_errors += smb->tx_abort_col;
 	adapter->soft_stats.tx_window_errors += smb->tx_late_col;
@@ -340,36 +335,38 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 	adapter->net_stats.collisions = adapter->soft_stats.collisions;
 	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
 	adapter->net_stats.rx_over_errors =
-	    adapter->soft_stats.rx_missed_errors;
+		adapter->soft_stats.rx_missed_errors;
 	adapter->net_stats.rx_length_errors =
-	    adapter->soft_stats.rx_length_errors;
+		adapter->soft_stats.rx_length_errors;
 	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
 	adapter->net_stats.rx_frame_errors =
-	    adapter->soft_stats.rx_frame_errors;
+		adapter->soft_stats.rx_frame_errors;
 	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
 	adapter->net_stats.rx_missed_errors =
-	    adapter->soft_stats.rx_missed_errors;
+		adapter->soft_stats.rx_missed_errors;
 	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
 	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
 	adapter->net_stats.tx_aborted_errors =
-	    adapter->soft_stats.tx_aborted_errors;
+		adapter->soft_stats.tx_aborted_errors;
 	adapter->net_stats.tx_window_errors =
-	    adapter->soft_stats.tx_window_errors;
+		adapter->soft_stats.tx_window_errors;
 	adapter->net_stats.tx_carrier_errors =
-	    adapter->soft_stats.tx_carrier_errors;
+		adapter->soft_stats.tx_carrier_errors;
 }
 
 static void atl1_rx_checksum(struct atl1_adapter *adapter,
-					struct rx_return_desc *rrd,
-					struct sk_buff *skb)
+	struct rx_return_desc *rrd, struct sk_buff *skb)
 {
+	struct pci_dev *pdev = adapter->pdev;
+
 	skb->ip_summed = CHECKSUM_NONE;
 
 	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
 		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
 					ERR_FLAG_CODE | ERR_FLAG_OV)) {
 			adapter->hw_csum_err++;
-			dev_dbg(&adapter->pdev->dev, "rx checksum error\n");
+			dev_printk(KERN_DEBUG, &pdev->dev,
+				"rx checksum error\n");
 			return;
 		}
 	}
@@ -388,7 +385,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	}
 
 	/* IPv4, but hardware thinks its checksum is wrong */
-	dev_dbg(&adapter->pdev->dev,
+	dev_printk(KERN_DEBUG, &pdev->dev,
 		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
 		rrd->pkt_flg, rrd->err_flg);
 	skb->ip_summed = CHECKSUM_COMPLETE;
@@ -503,13 +500,14 @@ chk_rrd:
 			/* rrd seems to be bad */
 			if (unlikely(i-- > 0)) {
 				/* rrd may not be DMAed completely */
-				dev_dbg(&adapter->pdev->dev,
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 					"incomplete RRD DMA transfer\n");
 				udelay(1);
 				goto chk_rrd;
 			}
 			/* bad rrd */
-			dev_dbg(&adapter->pdev->dev, "bad RRD\n");
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"bad RRD\n");
 			/* see if update RFD index */
 			if (rrd->num_buf > 1) {
 				u16 num_buf;
@@ -697,7 +695,6 @@ static void atl1_check_for_link(struct atl1_adapter *adapter)
  */
 static irqreturn_t atl1_intr(int irq, void *data)
 {
-	/*struct atl1_adapter *adapter = ((struct net_device *)data)->priv;*/
 	struct atl1_adapter *adapter = netdev_priv(data);
 	u32 status;
 	u8 update_rx;
@@ -725,8 +722,8 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if PCIE PHY Link down */
 		if (status & ISR_PHY_LINKDOWN) {
-			dev_dbg(&adapter->pdev->dev, "pcie phy link down %x\n",
-				status);
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie phy link down %x\n", status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
 				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 				schedule_work(&adapter->pcie_dma_to_rst_task);
@@ -736,7 +733,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if DMA read/write error ? */
 		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			dev_dbg(&adapter->pdev->dev,
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"pcie DMA r/w error (status = 0x%x)\n",
 				status);
 			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
@@ -761,7 +758,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
 				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
 				ISR_HOST_RRD_OV))
-				dev_dbg(&adapter->pdev->dev,
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 					"rx exception, ISR = 0x%x\n", status);
 			atl1_intr_rx(adapter);
 		}
@@ -973,7 +970,7 @@ static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 	lo = value * 7 / 8;
 
 	value = ((hi & RXQ_RXF_PAUSE_TH_HI_MASK) << RXQ_RXF_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, adapter->hw.hw_addr + REG_RXQ_RXF_PAUSE_THRESH);
 
 	/* RRD Flow Control */
@@ -983,7 +980,7 @@ static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 	if (lo < 2)
 		lo = 2;
 	value = ((hi & RXQ_RRD_PAUSE_TH_HI_MASK) << RXQ_RRD_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, adapter->hw.hw_addr + REG_RXQ_RRD_PAUSE_THRESH);
 }
 
@@ -1000,7 +997,7 @@ static void set_flow_ctrl_new(struct atl1_hw *hw)
 	if (hi < lo)
 		hi = lo + 16;
 	value = ((hi & RXQ_RXF_PAUSE_TH_HI_MASK) << RXQ_RXF_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RXF_PAUSE_TH_LO_MASK) << RXQ_RXF_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_RXQ_RXF_PAUSE_THRESH);
 
 	/* RRD Flow Control */
@@ -1012,7 +1009,7 @@ static void set_flow_ctrl_new(struct atl1_hw *hw)
 	if (hi < lo)
 		hi = lo + 3;
 	value = ((hi & RXQ_RRD_PAUSE_TH_HI_MASK) << RXQ_RRD_PAUSE_TH_HI_SHIFT) |
-	    ((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
+		((lo & RXQ_RRD_PAUSE_TH_LO_MASK) << RXQ_RRD_PAUSE_TH_LO_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_RXQ_RRD_PAUSE_THRESH);
 }
 
@@ -1069,31 +1066,31 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* config Mailbox */
 	value = ((atomic_read(&adapter->tpd_ring.next_to_use)
 		  & MB_TPD_PROD_INDX_MASK) << MB_TPD_PROD_INDX_SHIFT) |
-	    ((atomic_read(&adapter->rrd_ring.next_to_clean)
-	      & MB_RRD_CONS_INDX_MASK) << MB_RRD_CONS_INDX_SHIFT) |
-	    ((atomic_read(&adapter->rfd_ring.next_to_use)
-	      & MB_RFD_PROD_INDX_MASK) << MB_RFD_PROD_INDX_SHIFT);
+		((atomic_read(&adapter->rrd_ring.next_to_clean)
+		& MB_RRD_CONS_INDX_MASK) << MB_RRD_CONS_INDX_SHIFT) |
+		((atomic_read(&adapter->rfd_ring.next_to_use)
+		& MB_RFD_PROD_INDX_MASK) << MB_RFD_PROD_INDX_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_MAILBOX);
 
 	/* config IPG/IFG */
 	value = (((u32) hw->ipgt & MAC_IPG_IFG_IPGT_MASK)
 		 << MAC_IPG_IFG_IPGT_SHIFT) |
-	    (((u32) hw->min_ifg & MAC_IPG_IFG_MIFG_MASK)
-	     << MAC_IPG_IFG_MIFG_SHIFT) |
-	    (((u32) hw->ipgr1 & MAC_IPG_IFG_IPGR1_MASK)
-	     << MAC_IPG_IFG_IPGR1_SHIFT) |
-	    (((u32) hw->ipgr2 & MAC_IPG_IFG_IPGR2_MASK)
-	     << MAC_IPG_IFG_IPGR2_SHIFT);
+		(((u32) hw->min_ifg & MAC_IPG_IFG_MIFG_MASK)
+		<< MAC_IPG_IFG_MIFG_SHIFT) |
+		(((u32) hw->ipgr1 & MAC_IPG_IFG_IPGR1_MASK)
+		<< MAC_IPG_IFG_IPGR1_SHIFT) |
+		(((u32) hw->ipgr2 & MAC_IPG_IFG_IPGR2_MASK)
+		<< MAC_IPG_IFG_IPGR2_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_MAC_IPG_IFG);
 
 	/* config  Half-Duplex Control */
 	value = ((u32) hw->lcol & MAC_HALF_DUPLX_CTRL_LCOL_MASK) |
-	    (((u32) hw->max_retry & MAC_HALF_DUPLX_CTRL_RETRY_MASK)
-	     << MAC_HALF_DUPLX_CTRL_RETRY_SHIFT) |
-	    MAC_HALF_DUPLX_CTRL_EXC_DEF_EN |
-	    (0xa << MAC_HALF_DUPLX_CTRL_ABEBT_SHIFT) |
-	    (((u32) hw->jam_ipg & MAC_HALF_DUPLX_CTRL_JAMIPG_MASK)
-	     << MAC_HALF_DUPLX_CTRL_JAMIPG_SHIFT);
+		(((u32) hw->max_retry & MAC_HALF_DUPLX_CTRL_RETRY_MASK)
+		<< MAC_HALF_DUPLX_CTRL_RETRY_SHIFT) |
+		MAC_HALF_DUPLX_CTRL_EXC_DEF_EN |
+		(0xa << MAC_HALF_DUPLX_CTRL_ABEBT_SHIFT) |
+		(((u32) hw->jam_ipg & MAC_HALF_DUPLX_CTRL_JAMIPG_MASK)
+		<< MAC_HALF_DUPLX_CTRL_JAMIPG_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_MAC_HALF_DUPLX_CTRL);
 
 	/* set Interrupt Moderator Timer */
@@ -1109,10 +1106,10 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* jumbo size & rrd retirement timer */
 	value = (((u32) hw->rx_jumbo_th & RXQ_JMBOSZ_TH_MASK)
 		 << RXQ_JMBOSZ_TH_SHIFT) |
-	    (((u32) hw->rx_jumbo_lkah & RXQ_JMBO_LKAH_MASK)
-	     << RXQ_JMBO_LKAH_SHIFT) |
-	    (((u32) hw->rrd_ret_timer & RXQ_RRD_TIMER_MASK)
-	     << RXQ_RRD_TIMER_SHIFT);
+		(((u32) hw->rx_jumbo_lkah & RXQ_JMBO_LKAH_MASK)
+		<< RXQ_JMBO_LKAH_SHIFT) |
+		(((u32) hw->rrd_ret_timer & RXQ_RRD_TIMER_MASK)
+		<< RXQ_RRD_TIMER_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_RXQ_JMBOSZ_RRDTIM);
 
 	/* Flow Control */
@@ -1131,35 +1128,36 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* config TXQ */
 	value = (((u32) hw->tpd_burst & TXQ_CTRL_TPD_BURST_NUM_MASK)
 		 << TXQ_CTRL_TPD_BURST_NUM_SHIFT) |
-	    (((u32) hw->txf_burst & TXQ_CTRL_TXF_BURST_NUM_MASK)
-	     << TXQ_CTRL_TXF_BURST_NUM_SHIFT) |
-	    (((u32) hw->tpd_fetch_th & TXQ_CTRL_TPD_FETCH_TH_MASK)
-	     << TXQ_CTRL_TPD_FETCH_TH_SHIFT) | TXQ_CTRL_ENH_MODE | TXQ_CTRL_EN;
+		(((u32) hw->txf_burst & TXQ_CTRL_TXF_BURST_NUM_MASK)
+		<< TXQ_CTRL_TXF_BURST_NUM_SHIFT) |
+		(((u32) hw->tpd_fetch_th & TXQ_CTRL_TPD_FETCH_TH_MASK)
+		<< TXQ_CTRL_TPD_FETCH_TH_SHIFT) | TXQ_CTRL_ENH_MODE |
+		TXQ_CTRL_EN;
 	iowrite32(value, hw->hw_addr + REG_TXQ_CTRL);
 
 	/* min tpd fetch gap & tx jumbo packet size threshold for taskoffload */
 	value = (((u32) hw->tx_jumbo_task_th & TX_JUMBO_TASK_TH_MASK)
-		 << TX_JUMBO_TASK_TH_SHIFT) |
-	    (((u32) hw->tpd_fetch_gap & TX_TPD_MIN_IPG_MASK)
-	     << TX_TPD_MIN_IPG_SHIFT);
+		<< TX_JUMBO_TASK_TH_SHIFT) |
+		(((u32) hw->tpd_fetch_gap & TX_TPD_MIN_IPG_MASK)
+		<< TX_TPD_MIN_IPG_SHIFT);
 	iowrite32(value, hw->hw_addr + REG_TX_JUMBO_TASK_TH_TPD_IPG);
 
 	/* config RXQ */
 	value = (((u32) hw->rfd_burst & RXQ_CTRL_RFD_BURST_NUM_MASK)
-		 << RXQ_CTRL_RFD_BURST_NUM_SHIFT) |
-	    (((u32) hw->rrd_burst & RXQ_CTRL_RRD_BURST_THRESH_MASK)
-	     << RXQ_CTRL_RRD_BURST_THRESH_SHIFT) |
-	    (((u32) hw->rfd_fetch_gap & RXQ_CTRL_RFD_PREF_MIN_IPG_MASK)
-	     << RXQ_CTRL_RFD_PREF_MIN_IPG_SHIFT) |
-	    RXQ_CTRL_CUT_THRU_EN | RXQ_CTRL_EN;
+		<< RXQ_CTRL_RFD_BURST_NUM_SHIFT) |
+		(((u32) hw->rrd_burst & RXQ_CTRL_RRD_BURST_THRESH_MASK)
+		<< RXQ_CTRL_RRD_BURST_THRESH_SHIFT) |
+		(((u32) hw->rfd_fetch_gap & RXQ_CTRL_RFD_PREF_MIN_IPG_MASK)
+		<< RXQ_CTRL_RFD_PREF_MIN_IPG_SHIFT) | RXQ_CTRL_CUT_THRU_EN |
+		RXQ_CTRL_EN;
 	iowrite32(value, hw->hw_addr + REG_RXQ_CTRL);
 
 	/* config DMA Engine */
 	value = ((((u32) hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-		 << DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
-	    ((((u32) hw->dmaw_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-	     << DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
-	    DMA_CTRL_DMAR_EN | DMA_CTRL_DMAW_EN;
+		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
+		((((u32) hw->dmaw_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
+		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) | DMA_CTRL_DMAR_EN |
+		DMA_CTRL_DMAW_EN;
 	value |= (u32) hw->dma_ord;
 	if (atl1_rcb_128 == hw->rcb_value)
 		value |= DMA_CTRL_RCB_VALUE;
@@ -1200,7 +1198,7 @@ static void atl1_irq_disable(struct atl1_adapter *adapter)
 }
 
 static void atl1_vlan_rx_register(struct net_device *netdev,
-				struct vlan_group *grp)
+	struct vlan_group *grp)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	unsigned long flags;
@@ -1235,9 +1233,9 @@ static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 next_to_use = atomic_read(&tpd_ring->next_to_use);
-	return ((next_to_clean >
-		 next_to_use) ? next_to_clean - next_to_use -
-		1 : tpd_ring->count + next_to_clean - next_to_use - 1);
+	return ((next_to_clean > next_to_use) ?
+		next_to_clean - next_to_use - 1 :
+		tpd_ring->count + next_to_clean - next_to_use - 1);
 }
 
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
@@ -1270,7 +1268,8 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			tso->tsopl |= (iph->ihl &
 				CSUM_PARAM_IPHL_MASK) << CSUM_PARAM_IPHL_SHIFT;
 			tso->tsopl |= (tcp_hdrlen(skb) &
-				TSO_PARAM_TCPHDRLEN_MASK) << TSO_PARAM_TCPHDRLEN_SHIFT;
+				TSO_PARAM_TCPHDRLEN_MASK) <<
+				TSO_PARAM_TCPHDRLEN_SHIFT;
 			tso->tsopl |= (skb_shinfo(skb)->gso_size &
 				TSO_PARAM_MSS_MASK) << TSO_PARAM_MSS_SHIFT;
 			tso->tsopl |= 1 << TSO_PARAM_IPCKSUM_SHIFT;
@@ -1283,7 +1282,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 }
 
 static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
-			struct csum_param *csum)
+	struct csum_param *csum)
 {
 	u8 css, cso;
 
@@ -1291,7 +1290,7 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 		cso = skb_transport_offset(skb);
 		css = cso + skb->csum_offset;
 		if (unlikely(cso & 0x1)) {
-			dev_dbg(&adapter->pdev->dev,
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"payload offset not an even number\n");
 			return -1;
 		}
@@ -1306,8 +1305,8 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 	return true;
 }
 
-static void atl1_tx_map(struct atl1_adapter *adapter,
-				struct sk_buff *skb, bool tcp_seg)
+static void atl1_tx_map(struct atl1_adapter *adapter, struct sk_buff *skb,
+	bool tcp_seg)
 {
 	/* We enter this function holding a spinlock. */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -1344,7 +1343,8 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 
 		if (first_buf_len > proto_hdr_len) {
 			len12 = first_buf_len - proto_hdr_len;
-			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
+			m = (len12 + ATL1_MAX_TX_BUF_LEN - 1) /
+				ATL1_MAX_TX_BUF_LEN;
 			for (i = 0; i < m; i++) {
 				buffer_info =
 				    &tpd_ring->buffer_info[tpd_next_to_use];
@@ -1354,16 +1354,14 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 				     len12) ? ATL1_MAX_TX_BUF_LEN : len12;
 				len12 -= buffer_info->length;
 				page = virt_to_page(skb->data +
-						 (proto_hdr_len +
-						  i * ATL1_MAX_TX_BUF_LEN));
+					(proto_hdr_len +
+					i * ATL1_MAX_TX_BUF_LEN));
 				offset = (unsigned long)(skb->data +
-							(proto_hdr_len +
-							i * ATL1_MAX_TX_BUF_LEN)) &
-							~PAGE_MASK;
-				buffer_info->dma =
-				    pci_map_page(adapter->pdev, page, offset,
-						 buffer_info->length,
-						 PCI_DMA_TODEVICE);
+					(proto_hdr_len +
+					i * ATL1_MAX_TX_BUF_LEN)) & ~PAGE_MASK;
+				buffer_info->dma = pci_map_page(adapter->pdev,
+					page, offset, buffer_info->length,
+					PCI_DMA_TODEVICE);
 				if (++tpd_next_to_use == tpd_ring->count)
 					tpd_next_to_use = 0;
 			}
@@ -1374,8 +1372,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 		page = virt_to_page(skb->data);
 		offset = (unsigned long)skb->data & ~PAGE_MASK;
 		buffer_info->dma = pci_map_page(adapter->pdev, page,
-						offset, first_buf_len,
-						PCI_DMA_TODEVICE);
+			offset, first_buf_len, PCI_DMA_TODEVICE);
 		if (++tpd_next_to_use == tpd_ring->count)
 			tpd_next_to_use = 0;
 	}
@@ -1393,13 +1390,13 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 			if (unlikely(buffer_info->skb))
 				BUG();
 			buffer_info->skb = NULL;
-			buffer_info->length =
-			    (lenf > ATL1_MAX_TX_BUF_LEN) ? ATL1_MAX_TX_BUF_LEN : lenf;
+			buffer_info->length = (lenf > ATL1_MAX_TX_BUF_LEN) ?
+				ATL1_MAX_TX_BUF_LEN : lenf;
 			lenf -= buffer_info->length;
-			buffer_info->dma =
-			    pci_map_page(adapter->pdev, frag->page,
-					 frag->page_offset + i * ATL1_MAX_TX_BUF_LEN,
-					 buffer_info->length, PCI_DMA_TODEVICE);
+			buffer_info->dma = pci_map_page(adapter->pdev,
+				frag->page,
+				frag->page_offset + (i * ATL1_MAX_TX_BUF_LEN),
+				buffer_info->length, PCI_DMA_TODEVICE);
 
 			if (++tpd_next_to_use == tpd_ring->count)
 				tpd_next_to_use = 0;
@@ -1411,7 +1408,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 }
 
 static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
-			       union tpd_descr *descr)
+       union tpd_descr *descr)
 {
 	/* We enter this function holding a spinlock. */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -1515,8 +1512,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	for (f = 0; f < nr_frags; f++) {
 		frag_size = skb_shinfo(skb)->frags[f].size;
 		if (frag_size)
-			count +=
-			    (frag_size + ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
+			count += (frag_size + ATL1_MAX_TX_BUF_LEN - 1) /
+				ATL1_MAX_TX_BUF_LEN;
 	}
 
 	/* mss will be nonzero if we're doing segment offload (TSO/GSO) */
@@ -1532,7 +1529,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			/* need additional TPD ? */
 			if (proto_hdr_len != len)
 				count += (len - proto_hdr_len +
-					ATL1_MAX_TX_BUF_LEN - 1) / ATL1_MAX_TX_BUF_LEN;
+					ATL1_MAX_TX_BUF_LEN - 1) /
+					ATL1_MAX_TX_BUF_LEN;
 		}
 	}
 
@@ -1540,7 +1538,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (!spin_trylock(&adapter->lock)) {
 		/* Can't get lock - tell upper layer to requeue */
 		local_irq_restore(flags);
-		dev_dbg(&adapter->pdev->dev, "tx locked\n");
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -1548,7 +1546,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		dev_dbg(&adapter->pdev->dev, "tx busy\n");
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1619,10 +1617,8 @@ static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 	for (i = 0; i < rfd_ring->count; i++) {
 		buffer_info = &rfd_ring->buffer_info[i];
 		if (buffer_info->dma) {
-			pci_unmap_page(pdev,
-					buffer_info->dma,
-					buffer_info->length,
-					PCI_DMA_FROMDEVICE);
+			pci_unmap_page(pdev, buffer_info->dma,
+				buffer_info->length, PCI_DMA_FROMDEVICE);
 			buffer_info->dma = 0;
 		}
 		if (buffer_info->skb) {
@@ -1661,7 +1657,7 @@ static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 		buffer_info = &tpd_ring->buffer_info[i];
 		if (buffer_info->dma) {
 			pci_unmap_page(pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+				buffer_info->length, PCI_DMA_TODEVICE);
 			buffer_info->dma = 0;
 		}
 	}
@@ -1703,7 +1699,7 @@ void atl1_free_ring_resources(struct atl1_adapter *adapter)
 
 	kfree(tpd_ring->buffer_info);
 	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
-			    ring_header->dma);
+		ring_header->dma);
 
 	tpd_ring->buffer_info = NULL;
 	tpd_ring->desc = NULL;
@@ -1752,11 +1748,6 @@ s32 atl1_up(struct atl1_adapter *adapter)
 	atl1_check_link(adapter);
 	return 0;
 
-	/* FIXME: unreachable code! -- CHS */
-	/* free irq disable any interrupt */
-	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-	free_irq(adapter->pdev->irq, netdev);
-
 err_up:
 	pci_disable_msi(adapter->pdev);
 	/* free rx_buffers */
@@ -1867,7 +1858,8 @@ static int mdio_read(struct net_device *netdev, int phy_id, int reg_num)
 	return result;
 }
 
-static void mdio_write(struct net_device *netdev, int phy_id, int reg_num, int val)
+static void mdio_write(struct net_device *netdev, int phy_id, int reg_num,
+	int val)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
@@ -2015,11 +2007,14 @@ static void atl1_poll_controller(struct net_device *netdev)
 #endif
 
 /*
+ * Orphaned vendor comment left intact here:
+ * <vendor comment>
  * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
  * will assert. We do soft reset <0x1400=1> according
  * with the SPEC. BUT, it seemes that PCIE or DMA
  * state-machine will not be reset. DMAR_TO_INT will
  * assert again and again.
+ * </vendor comment>
  */
 static void atl1_tx_timeout_task(struct work_struct *work)
 {
@@ -2053,6 +2048,8 @@ static void atl1_link_chg_task(struct work_struct *work)
 static void atl1_pcie_patch(struct atl1_adapter *adapter)
 {
 	u32 value;
+
+	/* much vendor magic here */
 	value = 0x6500;
 	iowrite32(value, adapter->hw.hw_addr + 0x12FC);
 	/* pcie flow control mode change */
@@ -2089,7 +2086,7 @@ static void atl1_via_workaround(struct atl1_adapter *adapter)
  * and a hardware reset occur.
  */
 static int __devinit atl1_probe(struct pci_dev *pdev,
-			      const struct pci_device_id *ent)
+	const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct atl1_adapter *adapter;
@@ -2143,7 +2140,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	}
 	/* get device revision number */
 	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr +
-					(REG_MASTER_CTRL + 2));
+		(REG_MASTER_CTRL + 2));
 	dev_info(&pdev->dev, "version %s\n", DRIVER_VERSION);
 
 	/* set default ring resource counts */
@@ -2296,7 +2293,8 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 	 * address, we need to save the permanent one.
 	 */
 	if (memcmp(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN)) {
-		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr, ETH_ALEN);
+		memcpy(adapter->hw.mac_addr, adapter->hw.perm_mac_addr,
+			ETH_ALEN);
 		atl1_set_mac_addr(&adapter->hw);
 	}
 
@@ -2363,11 +2361,11 @@ static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 		ctrl |= MAC_CTRL_RX_EN;
 		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
 		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);	/* 4 == D3 cold */
+		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
 		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
 		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);	/* 4 == D3 cold */
+		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
 	pci_save_state(pdev);
@@ -2412,8 +2410,6 @@ static struct pci_driver atl1_driver = {
 	.id_table = atl1_pci_tbl,
 	.probe = atl1_probe,
 	.remove = __devexit_p(atl1_remove),
-	/* Power Managment Hooks */
-	/* probably broken right now -- CHS */
 	.suspend = atl1_suspend,
 	.resume = atl1_resume
 };
-- 
1.5.2.2

