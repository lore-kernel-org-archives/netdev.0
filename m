From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 5/5] atl1: reorder atl1_main functions
Date: Sun, 15 Jul 2007 11:03:29 -0500
Message-ID: <1184515409122-git-send-email-jacliburn@bellsouth.net>
References: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Cc: jacliburn@bellsouth.net, csnook@redhat.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:32787 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760957AbXGOQDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 12:03:43 -0400
In-Reply-To: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reorder functions in atl1_main into more logical groupings to make the
code easier to follow. This patch is large, but it's harmless; it neither
adds nor removes any functionality whatsoever.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c | 1950 +++++++++++++++++++++---------------------
 1 files changed, 975 insertions(+), 975 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 67ddf8d..f7ac475 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -168,6 +168,64 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	return 0;
 }
 
+static int mdio_read(struct net_device *netdev, int phy_id, int reg_num)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	u16 result;
+
+	atl1_read_phy_reg(&adapter->hw, reg_num & 0x1f, &result);
+
+	return result;
+}
+
+static void mdio_write(struct net_device *netdev, int phy_id, int reg_num,
+	int val)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+
+	atl1_write_phy_reg(&adapter->hw, reg_num, val);
+}
+
+/*
+ * atl1_mii_ioctl -
+ * @netdev:
+ * @ifreq:
+ * @cmd:
+ */
+static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
+	int retval;
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	spin_lock_irqsave(&adapter->lock, flags);
+	retval = generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+
+	return retval;
+}
+
+/*
+ * atl1_ioctl -
+ * @netdev:
+ * @ifreq:
+ * @cmd:
+ */
+static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return atl1_mii_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 /*
  * atl1_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
@@ -276,555 +334,116 @@ void atl1_init_ring_ptrs(struct atl1_adapter *adapter)
 }
 
 /*
- * atl1_irq_enable - Enable default interrupt generation settings
+ * atl1_clean_rx_ring - Free RFD Buffers
  * @adapter: board private structure
  */
-static void atl1_irq_enable(struct atl1_adapter *adapter)
-{
-	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
-	ioread32(adapter->hw.hw_addr + REG_IMR);
-}
-
-static void atl1_clear_phy_int(struct atl1_adapter *adapter)
-{
-	u16 phy_data;
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
-static void atl1_inc_smb(struct atl1_adapter *adapter)
-{
-	struct stats_msg_block *smb = adapter->smb.smb;
-
-	/* Fill out the OS statistics structure */
-	adapter->soft_stats.rx_packets += smb->rx_ok;
-	adapter->soft_stats.tx_packets += smb->tx_ok;
-	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
-	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
-	adapter->soft_stats.multicast += smb->rx_mcast;
-	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col * 2 +
-		smb->tx_late_col + smb->tx_abort_col * adapter->hw.max_retry);
-
-	/* Rx Errors */
-	adapter->soft_stats.rx_errors += (smb->rx_frag + smb->rx_fcs_err +
-		smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
-		smb->rx_rrd_ov + smb->rx_align_err);
-	adapter->soft_stats.rx_fifo_errors += smb->rx_rxf_ov;
-	adapter->soft_stats.rx_length_errors += smb->rx_len_err;
-	adapter->soft_stats.rx_crc_errors += smb->rx_fcs_err;
-	adapter->soft_stats.rx_frame_errors += smb->rx_align_err;
-	adapter->soft_stats.rx_missed_errors += (smb->rx_rrd_ov +
-		smb->rx_rxf_ov);
-
-	adapter->soft_stats.rx_pause += smb->rx_pause;
-	adapter->soft_stats.rx_rrd_ov += smb->rx_rrd_ov;
-	adapter->soft_stats.rx_trunc += smb->rx_sz_ov;
-
-	/* Tx Errors */
-	adapter->soft_stats.tx_errors += (smb->tx_late_col +
-		smb->tx_abort_col + smb->tx_underrun + smb->tx_trunc);
-	adapter->soft_stats.tx_fifo_errors += smb->tx_underrun;
-	adapter->soft_stats.tx_aborted_errors += smb->tx_abort_col;
-	adapter->soft_stats.tx_window_errors += smb->tx_late_col;
-
-	adapter->soft_stats.excecol += smb->tx_abort_col;
-	adapter->soft_stats.deffer += smb->tx_defer;
-	adapter->soft_stats.scc += smb->tx_1_col;
-	adapter->soft_stats.mcc += smb->tx_2_col;
-	adapter->soft_stats.latecol += smb->tx_late_col;
-	adapter->soft_stats.tx_underun += smb->tx_underrun;
-	adapter->soft_stats.tx_trunc += smb->tx_trunc;
-	adapter->soft_stats.tx_pause += smb->tx_pause;
-
-	adapter->net_stats.rx_packets = adapter->soft_stats.rx_packets;
-	adapter->net_stats.tx_packets = adapter->soft_stats.tx_packets;
-	adapter->net_stats.rx_bytes = adapter->soft_stats.rx_bytes;
-	adapter->net_stats.tx_bytes = adapter->soft_stats.tx_bytes;
-	adapter->net_stats.multicast = adapter->soft_stats.multicast;
-	adapter->net_stats.collisions = adapter->soft_stats.collisions;
-	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
-	adapter->net_stats.rx_over_errors =
-		adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.rx_length_errors =
-		adapter->soft_stats.rx_length_errors;
-	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
-	adapter->net_stats.rx_frame_errors =
-		adapter->soft_stats.rx_frame_errors;
-	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
-	adapter->net_stats.rx_missed_errors =
-		adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
-	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
-	adapter->net_stats.tx_aborted_errors =
-		adapter->soft_stats.tx_aborted_errors;
-	adapter->net_stats.tx_window_errors =
-		adapter->soft_stats.tx_window_errors;
-	adapter->net_stats.tx_carrier_errors =
-		adapter->soft_stats.tx_carrier_errors;
-}
-
-static void atl1_rx_checksum(struct atl1_adapter *adapter,
-	struct rx_return_desc *rrd, struct sk_buff *skb)
-{
-	struct pci_dev *pdev = adapter->pdev;
-
-	skb->ip_summed = CHECKSUM_NONE;
-
-	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
-					ERR_FLAG_CODE | ERR_FLAG_OV)) {
-			adapter->hw_csum_err++;
-			dev_printk(KERN_DEBUG, &pdev->dev,
-				"rx checksum error\n");
-			return;
-		}
-	}
-
-	/* not IPv4 */
-	if (!(rrd->pkt_flg & PACKET_FLAG_IPV4))
-		/* checksum is invalid, but it's not an IPv4 pkt, so ok */
-		return;
-
-	/* IPv4 packet */
-	if (likely(!(rrd->err_flg &
-		(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM)))) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		adapter->hw_csum_good++;
-		return;
-	}
-
-	/* IPv4, but hardware thinks its checksum is wrong */
-	dev_printk(KERN_DEBUG, &pdev->dev,
-		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
-		rrd->pkt_flg, rrd->err_flg);
-	skb->ip_summed = CHECKSUM_COMPLETE;
-	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
-	adapter->hw_csum_err++;
-	return;
-}
-
-/*
- * atl1_alloc_rx_buffers - Replace used receive buffers
- * @adapter: address of board private structure
- */
-static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
-{
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-	struct pci_dev *pdev = adapter->pdev;
-	struct page *page;
-	unsigned long offset;
-	struct atl1_buffer *buffer_info, *next_info;
-	struct sk_buff *skb;
-	u16 num_alloc = 0;
-	u16 rfd_next_to_use, next_next;
-	struct rx_free_desc *rfd_desc;
-
-	next_next = rfd_next_to_use = atomic_read(&rfd_ring->next_to_use);
-	if (++next_next == rfd_ring->count)
-		next_next = 0;
-	buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
-	next_info = &rfd_ring->buffer_info[next_next];
-
-	while (!buffer_info->alloced && !next_info->alloced) {
-		if (buffer_info->skb) {
-			buffer_info->alloced = 1;
-			goto next;
-		}
-
-		rfd_desc = ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
-
-		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
-		if (unlikely(!skb)) {	/* Better luck next round */
-			adapter->net_stats.rx_dropped++;
-			break;
-		}
-
-		/*
-		 * Make buffer alignment 2 beyond a 16 byte boundary
-		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed
-		 */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		buffer_info->alloced = 1;
-		buffer_info->skb = skb;
-		buffer_info->length = (u16) adapter->rx_buffer_len;
-		page = virt_to_page(skb->data);
-		offset = (unsigned long)skb->data & ~PAGE_MASK;
-		buffer_info->dma = pci_map_page(pdev, page, offset,
-						adapter->rx_buffer_len,
-						PCI_DMA_FROMDEVICE);
-		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
-		rfd_desc->buf_len = cpu_to_le16(adapter->rx_buffer_len);
-		rfd_desc->coalese = 0;
-
-next:
-		rfd_next_to_use = next_next;
-		if (unlikely(++next_next == rfd_ring->count))
-			next_next = 0;
-
-		buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
-		next_info = &rfd_ring->buffer_info[next_next];
-		num_alloc++;
-	}
-
-	if (num_alloc) {
-		/*
-		 * Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64).
-		 */
-		wmb();
-		atomic_set(&rfd_ring->next_to_use, (int)rfd_next_to_use);
-	}
-	return num_alloc;
-}
-
-static void atl1_clean_alloc_flag(struct atl1_adapter *adapter,
-	struct rx_return_desc *rrd, u16 offset)
-{
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-
-	while (rfd_ring->next_to_clean != (rrd->buf_indx + offset)) {
-		rfd_ring->buffer_info[rfd_ring->next_to_clean].alloced = 0;
-		if (++rfd_ring->next_to_clean == rfd_ring->count) {
-			rfd_ring->next_to_clean = 0;
-		}
-	}
-}
-
-static void atl1_update_rfd_index(struct atl1_adapter *adapter,
-	struct rx_return_desc *rrd)
-{
-	u16 num_buf;
-
-	num_buf = (rrd->xsz.xsum_sz.pkt_size + adapter->rx_buffer_len - 1) /
-		adapter->rx_buffer_len;
-	if (rrd->num_buf == num_buf)
-		/* clean alloc flag for bad rrd */
-		atl1_clean_alloc_flag(adapter, rrd, num_buf);
-}
-
-static void atl1_intr_rx(struct atl1_adapter *adapter)
+static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 {
-	int i, count;
-	u16 length;
-	u16 rrd_next_to_clean;
-	u32 value;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
 	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1_buffer *buffer_info;
-	struct rx_return_desc *rrd;
-	struct sk_buff *skb;
-
-	count = 0;
-
-	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
-
-	while (1) {
-		rrd = ATL1_RRD_DESC(rrd_ring, rrd_next_to_clean);
-		i = 1;
-		if (likely(rrd->xsz.valid)) {	/* packet valid */
-chk_rrd:
-			/* check rrd status */
-			if (likely(rrd->num_buf == 1))
-				goto rrd_ok;
-
-			/* rrd seems to be bad */
-			if (unlikely(i-- > 0)) {
-				/* rrd may not be DMAed completely */
-				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-					"incomplete RRD DMA transfer\n");
-				udelay(1);
-				goto chk_rrd;
-			}
-			/* bad rrd */
-			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-				"bad RRD\n");
-			/* see if update RFD index */
-			if (rrd->num_buf > 1)
-				atl1_update_rfd_index(adapter, rrd);
-
-			/* update rrd */
-			rrd->xsz.valid = 0;
-			if (++rrd_next_to_clean == rrd_ring->count)
-				rrd_next_to_clean = 0;
-			count++;
-			continue;
-		} else {	/* current rrd still not be updated */
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long size;
+	unsigned int i;
 
-			break;
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rfd_ring->count; i++) {
+		buffer_info = &rfd_ring->buffer_info[i];
+		if (buffer_info->dma) {
+			pci_unmap_page(pdev, buffer_info->dma,
+				buffer_info->length, PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
 		}
-rrd_ok:
-		/* clean alloc flag for bad rrd */
-		atl1_clean_alloc_flag(adapter, rrd, 0);
-
-		buffer_info = &rfd_ring->buffer_info[rrd->buf_indx];
-		if (++rfd_ring->next_to_clean == rfd_ring->count)
-			rfd_ring->next_to_clean = 0;
-
-		/* update rrd next to clean */
-		if (++rrd_next_to_clean == rrd_ring->count)
-			rrd_next_to_clean = 0;
-		count++;
-
-		if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-			if (!(rrd->err_flg &
-				(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM
-				| ERR_FLAG_LEN))) {
-				/* packet error, don't need upstream */
-				buffer_info->alloced = 0;
-				rrd->xsz.valid = 0;
-				continue;
-			}
+		if (buffer_info->skb) {
+			dev_kfree_skb(buffer_info->skb);
+			buffer_info->skb = NULL;
 		}
-
-		/* Good Receive */
-		pci_unmap_page(adapter->pdev, buffer_info->dma,
-			       buffer_info->length, PCI_DMA_FROMDEVICE);
-		skb = buffer_info->skb;
-		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
-
-		skb_put(skb, length - ETHERNET_FCS_SIZE);
-
-		/* Receive Checksum Offload */
-		atl1_rx_checksum(adapter, rrd, skb);
-		skb->protocol = eth_type_trans(skb, adapter->netdev);
-
-		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
-			u16 vlan_tag = (rrd->vlan_tag >> 4) |
-					((rrd->vlan_tag & 7) << 13) |
-					((rrd->vlan_tag & 8) << 9);
-			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
-		} else
-			netif_rx(skb);
-
-		/* let protocol layer free skb */
-		buffer_info->skb = NULL;
-		buffer_info->alloced = 0;
-		rrd->xsz.valid = 0;
-
-		adapter->netdev->last_rx = jiffies;
 	}
 
-	atomic_set(&rrd_ring->next_to_clean, rrd_next_to_clean);
-
-	atl1_alloc_rx_buffers(adapter);
+	size = sizeof(struct atl1_buffer) * rfd_ring->count;
+	memset(rfd_ring->buffer_info, 0, size);
 
-	/* update mailbox ? */
-	if (count) {
-		u32 tpd_next_to_use;
-		u32 rfd_next_to_use;
-		u32 rrd_next_to_clean;
+	/* Zero out the descriptor ring */
+	memset(rfd_ring->desc, 0, rfd_ring->size);
 
-		spin_lock(&adapter->mb_lock);
+	rfd_ring->next_to_clean = 0;
+	atomic_set(&rfd_ring->next_to_use, 0);
 
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
+	rrd_ring->next_to_use = 0;
+	atomic_set(&rrd_ring->next_to_clean, 0);
 }
 
-static void atl1_intr_tx(struct atl1_adapter *adapter)
+/*
+ * atl1_clean_tx_ring - Free Tx Buffers
+ * @adapter: board private structure
+ */
+static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
-	u16 sw_tpd_next_to_clean;
-	u16 cmb_tpd_next_to_clean;
-
-	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
-	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
-
-	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
-		struct tx_packet_desc *tpd;
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long size;
+	unsigned int i;
 
-		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
-		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
+	/* Free all the Tx ring sk_buffs */
+	for (i = 0; i < tpd_ring->count; i++) {
+		buffer_info = &tpd_ring->buffer_info[i];
 		if (buffer_info->dma) {
-			pci_unmap_page(adapter->pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+			pci_unmap_page(pdev, buffer_info->dma,
+				buffer_info->length, PCI_DMA_TODEVICE);
 			buffer_info->dma = 0;
 		}
+	}
 
+	for (i = 0; i < tpd_ring->count; i++) {
+		buffer_info = &tpd_ring->buffer_info[i];
 		if (buffer_info->skb) {
-			dev_kfree_skb_irq(buffer_info->skb);
+			dev_kfree_skb_any(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
-		tpd->buffer_addr = 0;
-		tpd->desc.data = 0;
-
-		if (++sw_tpd_next_to_clean == tpd_ring->count)
-			sw_tpd_next_to_clean = 0;
 	}
-	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
-
-	if (netif_queue_stopped(adapter->netdev)
-	    && netif_carrier_ok(adapter->netdev))
-		netif_wake_queue(adapter->netdev);
-}
-
-static void atl1_check_for_link(struct atl1_adapter *adapter)
-{
-	struct net_device *netdev = adapter->netdev;
-	u16 phy_data = 0;
-
-	spin_lock(&adapter->lock);
-	adapter->phy_timer_pending = false;
-	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
-	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
-	spin_unlock(&adapter->lock);
 
-	/* notify upper layer link down ASAP */
-	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
-		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			dev_info(&adapter->pdev->dev, "%s link is down\n",
-				netdev->name);
-			adapter->link_speed = SPEED_0;
-			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
-		}
-	}
-	schedule_work(&adapter->link_chg_task);
-}
-
-/*
- * atl1_intr - Interrupt Handler
- * @irq: interrupt number
- * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
- */
-static irqreturn_t atl1_intr(int irq, void *data)
-{
-	struct atl1_adapter *adapter = netdev_priv(data);
-	u32 status;
-	u8 update_rx;
-	int max_ints = 10;
-
-	status = adapter->cmb.cmb->int_stats;
-	if (!status)
-		return IRQ_NONE;
-
-	update_rx = 0;
-
-	do {
-		/* clear CMB interrupt status at once */
-		adapter->cmb.cmb->int_stats = 0;
-
-		if (status & ISR_GPHY)	/* clear phy status */
-			atl1_clear_phy_int(adapter);
-
-		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
-		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
-
-		/* check if SMB intr */
-		if (status & ISR_SMB)
-			atl1_inc_smb(adapter);
-
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
-			return IRQ_HANDLED;
-		}
-
-		/* link event */
-		if (status & ISR_GPHY) {
-			adapter->soft_stats.tx_carrier_errors++;
-			atl1_check_for_link(adapter);
-		}
-
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
-
-		if (--max_ints < 0)
-			break;
+	size = sizeof(struct atl1_buffer) * tpd_ring->count;
+	memset(tpd_ring->buffer_info, 0, size);
 
-	} while ((status = adapter->cmb.cmb->int_stats));
+	/* Zero out the descriptor ring */
+	memset(tpd_ring->desc, 0, tpd_ring->size);
 
-	/* re-enable Interrupt */
-	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
-	return IRQ_HANDLED;
+	atomic_set(&tpd_ring->next_to_use, 0);
+	atomic_set(&tpd_ring->next_to_clean, 0);
 }
 
 /*
- * atl1_set_multi - Multicast and Promiscuous mode set
- * @netdev: network interface device structure
+ * atl1_free_ring_resources - Free Tx / RX descriptor Resources
+ * @adapter: board private structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
- * promiscuous mode, and all-multi behavior.
+ * Free all transmit software resources
  */
-static void atl1_set_multi(struct net_device *netdev)
+void atl1_free_ring_resources(struct atl1_adapter *adapter)
 {
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct atl1_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
-	u32 rctl;
-	u32 hash_value;
+	struct pci_dev *pdev = adapter->pdev;
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+	struct atl1_ring_header *ring_header = &adapter->ring_header;
 
-	/* Check for Promiscuous and All Multicast modes */
-	rctl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-	if (netdev->flags & IFF_PROMISC)
-		rctl |= MAC_CTRL_PROMIS_EN;
-	else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= MAC_CTRL_MC_ALL_EN;
-		rctl &= ~MAC_CTRL_PROMIS_EN;
-	} else
-		rctl &= ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
+	atl1_clean_tx_ring(adapter);
+	atl1_clean_rx_ring(adapter);
 
-	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
+	kfree(tpd_ring->buffer_info);
+	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
+		ring_header->dma);
 
-	/* clear the old settings from the multicast hash table */
-	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+	tpd_ring->buffer_info = NULL;
+	tpd_ring->desc = NULL;
+	tpd_ring->dma = 0;
 
-	/* compute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
-		hash_value = atl1_hash_mc_addr(hw, mc_ptr->dmi_addr);
-		atl1_hash_set(hw, hash_value);
-	}
+	rfd_ring->buffer_info = NULL;
+	rfd_ring->desc = NULL;
+	rfd_ring->dma = 0;
+
+	rrd_ring->desc = NULL;
+	rrd_ring->dma = 0;
 }
 
 static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
@@ -865,6 +484,31 @@ static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
 	iowrite32(value, hw->hw_addr + REG_MAC_CTRL);
 }
 
+/*
+ * atl1_set_mac - Change the Ethernet Address of the NIC
+ * @netdev: network interface device structure
+ * @p: pointer to an address structure
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int atl1_set_mac(struct net_device *netdev, void *p)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+
+	atl1_set_mac_addr(&adapter->hw);
+	return 0;
+}
+
 static u32 atl1_check_link(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
@@ -972,6 +616,103 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	return ATL1_SUCCESS;
 }
 
+static void atl1_check_for_link(struct atl1_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	u16 phy_data = 0;
+
+	spin_lock(&adapter->lock);
+	adapter->phy_timer_pending = false;
+	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
+	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
+	spin_unlock(&adapter->lock);
+
+	/* notify upper layer link down ASAP */
+	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
+		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
+			dev_info(&adapter->pdev->dev, "%s link is down\n",
+				netdev->name);
+			adapter->link_speed = SPEED_0;
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
+	}
+	schedule_work(&adapter->link_chg_task);
+}
+
+/*
+ * atl1_set_multi - Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ *
+ * The set_multi entry point is called whenever the multicast address
+ * list or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper multicast,
+ * promiscuous mode, and all-multi behavior.
+ */
+static void atl1_set_multi(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_hw *hw = &adapter->hw;
+	struct dev_mc_list *mc_ptr;
+	u32 rctl;
+	u32 hash_value;
+
+	/* Check for Promiscuous and All Multicast modes */
+	rctl = ioread32(hw->hw_addr + REG_MAC_CTRL);
+	if (netdev->flags & IFF_PROMISC)
+		rctl |= MAC_CTRL_PROMIS_EN;
+	else if (netdev->flags & IFF_ALLMULTI) {
+		rctl |= MAC_CTRL_MC_ALL_EN;
+		rctl &= ~MAC_CTRL_PROMIS_EN;
+	} else
+		rctl &= ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
+
+	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
+
+	/* clear the old settings from the multicast hash table */
+	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+
+	/* compute mc addresses' hash value ,and put it into hash table */
+	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
+		hash_value = atl1_hash_mc_addr(hw, mc_ptr->dmi_addr);
+		atl1_hash_set(hw, hash_value);
+	}
+}
+
+/*
+ * atl1_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	int old_mtu = netdev->mtu;
+	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
+
+	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
+	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
+		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	adapter->hw.max_frame_size = max_frame;
+	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
+	adapter->rx_buffer_len = (max_frame + 7) & ~7;
+	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
+
+	netdev->mtu = new_mtu;
+	if ((old_mtu != new_mtu) && netif_running(netdev)) {
+		atl1_down(adapter);
+		atl1_up(adapter);
+	}
+
+	return 0;
+}
+
 static void set_flow_ctrl_old(struct atl1_adapter *adapter)
 {
 	u32 hi, lo, value;
@@ -1202,6 +943,48 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 }
 
 /*
+ * atl1_pcie_patch - Patch for PCIE module
+ */
+static void atl1_pcie_patch(struct atl1_adapter *adapter)
+{
+	u32 value;
+
+	/* much vendor magic here */
+	value = 0x6500;
+	iowrite32(value, adapter->hw.hw_addr + 0x12FC);
+	/* pcie flow control mode change */
+	value = ioread32(adapter->hw.hw_addr + 0x1008);
+	value |= 0x8000;
+	iowrite32(value, adapter->hw.hw_addr + 0x1008);
+}
+
+/*
+ * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
+ * on PCI Command register is disable.
+ * The function enable this bit.
+ * Brackett, 2006/03/15
+ */
+static void atl1_via_workaround(struct atl1_adapter *adapter)
+{
+	unsigned long value;
+
+	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
+	if (value & PCI_COMMAND_INTX_DISABLE)
+		value &= ~PCI_COMMAND_INTX_DISABLE;
+	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
+}
+
+/*
+ * atl1_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ */
+static void atl1_irq_enable(struct atl1_adapter *adapter)
+{
+	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
+}
+
+/*
  * atl1_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
@@ -1212,36 +995,434 @@ static void atl1_irq_disable(struct atl1_adapter *adapter)
 	synchronize_irq(adapter->pdev->irq);
 }
 
-static void atl1_vlan_rx_register(struct net_device *netdev,
-	struct vlan_group *grp)
+static void atl1_clear_phy_int(struct atl1_adapter *adapter)
 {
-	struct atl1_adapter *adapter = netdev_priv(netdev);
+	u16 phy_data;
 	unsigned long flags;
-	u32 ctrl;
 
 	spin_lock_irqsave(&adapter->lock, flags);
-	/* atl1_irq_disable(adapter); */
-	adapter->vlgrp = grp;
+	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
 
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl |= MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+static void atl1_inc_smb(struct atl1_adapter *adapter)
+{
+	struct stats_msg_block *smb = adapter->smb.smb;
+
+	/* Fill out the OS statistics structure */
+	adapter->soft_stats.rx_packets += smb->rx_ok;
+	adapter->soft_stats.tx_packets += smb->tx_ok;
+	adapter->soft_stats.rx_bytes += smb->rx_byte_cnt;
+	adapter->soft_stats.tx_bytes += smb->tx_byte_cnt;
+	adapter->soft_stats.multicast += smb->rx_mcast;
+	adapter->soft_stats.collisions += (smb->tx_1_col + smb->tx_2_col * 2 +
+		smb->tx_late_col + smb->tx_abort_col * adapter->hw.max_retry);
+
+	/* Rx Errors */
+	adapter->soft_stats.rx_errors += (smb->rx_frag + smb->rx_fcs_err +
+		smb->rx_len_err + smb->rx_sz_ov + smb->rx_rxf_ov +
+		smb->rx_rrd_ov + smb->rx_align_err);
+	adapter->soft_stats.rx_fifo_errors += smb->rx_rxf_ov;
+	adapter->soft_stats.rx_length_errors += smb->rx_len_err;
+	adapter->soft_stats.rx_crc_errors += smb->rx_fcs_err;
+	adapter->soft_stats.rx_frame_errors += smb->rx_align_err;
+	adapter->soft_stats.rx_missed_errors += (smb->rx_rrd_ov +
+		smb->rx_rxf_ov);
+
+	adapter->soft_stats.rx_pause += smb->rx_pause;
+	adapter->soft_stats.rx_rrd_ov += smb->rx_rrd_ov;
+	adapter->soft_stats.rx_trunc += smb->rx_sz_ov;
+
+	/* Tx Errors */
+	adapter->soft_stats.tx_errors += (smb->tx_late_col +
+		smb->tx_abort_col + smb->tx_underrun + smb->tx_trunc);
+	adapter->soft_stats.tx_fifo_errors += smb->tx_underrun;
+	adapter->soft_stats.tx_aborted_errors += smb->tx_abort_col;
+	adapter->soft_stats.tx_window_errors += smb->tx_late_col;
+
+	adapter->soft_stats.excecol += smb->tx_abort_col;
+	adapter->soft_stats.deffer += smb->tx_defer;
+	adapter->soft_stats.scc += smb->tx_1_col;
+	adapter->soft_stats.mcc += smb->tx_2_col;
+	adapter->soft_stats.latecol += smb->tx_late_col;
+	adapter->soft_stats.tx_underun += smb->tx_underrun;
+	adapter->soft_stats.tx_trunc += smb->tx_trunc;
+	adapter->soft_stats.tx_pause += smb->tx_pause;
+
+	adapter->net_stats.rx_packets = adapter->soft_stats.rx_packets;
+	adapter->net_stats.tx_packets = adapter->soft_stats.tx_packets;
+	adapter->net_stats.rx_bytes = adapter->soft_stats.rx_bytes;
+	adapter->net_stats.tx_bytes = adapter->soft_stats.tx_bytes;
+	adapter->net_stats.multicast = adapter->soft_stats.multicast;
+	adapter->net_stats.collisions = adapter->soft_stats.collisions;
+	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
+	adapter->net_stats.rx_over_errors =
+		adapter->soft_stats.rx_missed_errors;
+	adapter->net_stats.rx_length_errors =
+		adapter->soft_stats.rx_length_errors;
+	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
+	adapter->net_stats.rx_frame_errors =
+		adapter->soft_stats.rx_frame_errors;
+	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
+	adapter->net_stats.rx_missed_errors =
+		adapter->soft_stats.rx_missed_errors;
+	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
+	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
+	adapter->net_stats.tx_aborted_errors =
+		adapter->soft_stats.tx_aborted_errors;
+	adapter->net_stats.tx_window_errors =
+		adapter->soft_stats.tx_window_errors;
+	adapter->net_stats.tx_carrier_errors =
+		adapter->soft_stats.tx_carrier_errors;
+}
+
+/*
+ * atl1_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ *
+ * Returns the address of the device statistics structure.
+ * The statistics are actually updated from the timer callback.
+ */
+static struct net_device_stats *atl1_get_stats(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	return &adapter->net_stats;
+}
+
+static void atl1_update_mailbox(struct atl1_adapter *adapter)
+{
+	unsigned long flags;
+	u32 tpd_next_to_use;
+	u32 rfd_next_to_use;
+	u32 rrd_next_to_clean;
+	u32 value;
+
+	spin_lock_irqsave(&adapter->mb_lock, flags);
+
+	tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
+	rfd_next_to_use = atomic_read(&adapter->rfd_ring.next_to_use);
+	rrd_next_to_clean = atomic_read(&adapter->rrd_ring.next_to_clean);
+
+	value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
+		MB_RFD_PROD_INDX_SHIFT) |
+		((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
+		MB_RRD_CONS_INDX_SHIFT) |
+		((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
+		MB_TPD_PROD_INDX_SHIFT);
+	iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
+
+	spin_unlock_irqrestore(&adapter->mb_lock, flags);
+}
+
+static void atl1_clean_alloc_flag(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd, u16 offset)
+{
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+
+	while (rfd_ring->next_to_clean != (rrd->buf_indx + offset)) {
+		rfd_ring->buffer_info[rfd_ring->next_to_clean].alloced = 0;
+		if (++rfd_ring->next_to_clean == rfd_ring->count) {
+			rfd_ring->next_to_clean = 0;
+		}
 	}
+}
 
-	/* atl1_irq_enable(adapter); */
-	spin_unlock_irqrestore(&adapter->lock, flags);
+static void atl1_update_rfd_index(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd)
+{
+	u16 num_buf;
+
+	num_buf = (rrd->xsz.xsum_sz.pkt_size + adapter->rx_buffer_len - 1) /
+		adapter->rx_buffer_len;
+	if (rrd->num_buf == num_buf)
+		/* clean alloc flag for bad rrd */
+		atl1_clean_alloc_flag(adapter, rrd, num_buf);
 }
 
-static void atl1_restore_vlan(struct atl1_adapter *adapter)
+static void atl1_rx_checksum(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd, struct sk_buff *skb)
 {
-	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	struct pci_dev *pdev = adapter->pdev;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
+		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
+					ERR_FLAG_CODE | ERR_FLAG_OV)) {
+			adapter->hw_csum_err++;
+			dev_printk(KERN_DEBUG, &pdev->dev,
+				"rx checksum error\n");
+			return;
+		}
+	}
+
+	/* not IPv4 */
+	if (!(rrd->pkt_flg & PACKET_FLAG_IPV4))
+		/* checksum is invalid, but it's not an IPv4 pkt, so ok */
+		return;
+
+	/* IPv4 packet */
+	if (likely(!(rrd->err_flg &
+		(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM)))) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		adapter->hw_csum_good++;
+		return;
+	}
+
+	/* IPv4, but hardware thinks its checksum is wrong */
+	dev_printk(KERN_DEBUG, &pdev->dev,
+		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
+		rrd->pkt_flg, rrd->err_flg);
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
+	adapter->hw_csum_err++;
+	return;
+}
+
+/*
+ * atl1_alloc_rx_buffers - Replace used receive buffers
+ * @adapter: address of board private structure
+ */
+static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
+{
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct pci_dev *pdev = adapter->pdev;
+	struct page *page;
+	unsigned long offset;
+	struct atl1_buffer *buffer_info, *next_info;
+	struct sk_buff *skb;
+	u16 num_alloc = 0;
+	u16 rfd_next_to_use, next_next;
+	struct rx_free_desc *rfd_desc;
+
+	next_next = rfd_next_to_use = atomic_read(&rfd_ring->next_to_use);
+	if (++next_next == rfd_ring->count)
+		next_next = 0;
+	buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
+	next_info = &rfd_ring->buffer_info[next_next];
+
+	while (!buffer_info->alloced && !next_info->alloced) {
+		if (buffer_info->skb) {
+			buffer_info->alloced = 1;
+			goto next;
+		}
+
+		rfd_desc = ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
+
+		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+		if (unlikely(!skb)) {	/* Better luck next round */
+			adapter->net_stats.rx_dropped++;
+			break;
+		}
+
+		/*
+		 * Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		buffer_info->alloced = 1;
+		buffer_info->skb = skb;
+		buffer_info->length = (u16) adapter->rx_buffer_len;
+		page = virt_to_page(skb->data);
+		offset = (unsigned long)skb->data & ~PAGE_MASK;
+		buffer_info->dma = pci_map_page(pdev, page, offset,
+						adapter->rx_buffer_len,
+						PCI_DMA_FROMDEVICE);
+		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
+		rfd_desc->buf_len = cpu_to_le16(adapter->rx_buffer_len);
+		rfd_desc->coalese = 0;
+
+next:
+		rfd_next_to_use = next_next;
+		if (unlikely(++next_next == rfd_ring->count))
+			next_next = 0;
+
+		buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
+		next_info = &rfd_ring->buffer_info[next_next];
+		num_alloc++;
+	}
+
+	if (num_alloc) {
+		/*
+		 * Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+		atomic_set(&rfd_ring->next_to_use, (int)rfd_next_to_use);
+	}
+	return num_alloc;
+}
+
+static void atl1_intr_rx(struct atl1_adapter *adapter)
+{
+	int i, count;
+	u16 length;
+	u16 rrd_next_to_clean;
+	u32 value;
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+	struct atl1_buffer *buffer_info;
+	struct rx_return_desc *rrd;
+	struct sk_buff *skb;
+
+	count = 0;
+
+	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
+
+	while (1) {
+		rrd = ATL1_RRD_DESC(rrd_ring, rrd_next_to_clean);
+		i = 1;
+		if (likely(rrd->xsz.valid)) {	/* packet valid */
+chk_rrd:
+			/* check rrd status */
+			if (likely(rrd->num_buf == 1))
+				goto rrd_ok;
+
+			/* rrd seems to be bad */
+			if (unlikely(i-- > 0)) {
+				/* rrd may not be DMAed completely */
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"incomplete RRD DMA transfer\n");
+				udelay(1);
+				goto chk_rrd;
+			}
+			/* bad rrd */
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"bad RRD\n");
+			/* see if update RFD index */
+			if (rrd->num_buf > 1)
+				atl1_update_rfd_index(adapter, rrd);
+
+			/* update rrd */
+			rrd->xsz.valid = 0;
+			if (++rrd_next_to_clean == rrd_ring->count)
+				rrd_next_to_clean = 0;
+			count++;
+			continue;
+		} else {	/* current rrd still not be updated */
+
+			break;
+		}
+rrd_ok:
+		/* clean alloc flag for bad rrd */
+		atl1_clean_alloc_flag(adapter, rrd, 0);
+
+		buffer_info = &rfd_ring->buffer_info[rrd->buf_indx];
+		if (++rfd_ring->next_to_clean == rfd_ring->count)
+			rfd_ring->next_to_clean = 0;
+
+		/* update rrd next to clean */
+		if (++rrd_next_to_clean == rrd_ring->count)
+			rrd_next_to_clean = 0;
+		count++;
+
+		if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
+			if (!(rrd->err_flg &
+				(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM
+				| ERR_FLAG_LEN))) {
+				/* packet error, don't need upstream */
+				buffer_info->alloced = 0;
+				rrd->xsz.valid = 0;
+				continue;
+			}
+		}
+
+		/* Good Receive */
+		pci_unmap_page(adapter->pdev, buffer_info->dma,
+			       buffer_info->length, PCI_DMA_FROMDEVICE);
+		skb = buffer_info->skb;
+		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
+
+		skb_put(skb, length - ETHERNET_FCS_SIZE);
+
+		/* Receive Checksum Offload */
+		atl1_rx_checksum(adapter, rrd, skb);
+		skb->protocol = eth_type_trans(skb, adapter->netdev);
+
+		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
+			u16 vlan_tag = (rrd->vlan_tag >> 4) |
+					((rrd->vlan_tag & 7) << 13) |
+					((rrd->vlan_tag & 8) << 9);
+			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
+		} else
+			netif_rx(skb);
+
+		/* let protocol layer free skb */
+		buffer_info->skb = NULL;
+		buffer_info->alloced = 0;
+		rrd->xsz.valid = 0;
+
+		adapter->netdev->last_rx = jiffies;
+	}
+
+	atomic_set(&rrd_ring->next_to_clean, rrd_next_to_clean);
+
+	atl1_alloc_rx_buffers(adapter);
+
+	/* update mailbox ? */
+	if (count) {
+		u32 tpd_next_to_use;
+		u32 rfd_next_to_use;
+		u32 rrd_next_to_clean;
+
+		spin_lock(&adapter->mb_lock);
+
+		tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
+		rfd_next_to_use =
+		    atomic_read(&adapter->rfd_ring.next_to_use);
+		rrd_next_to_clean =
+		    atomic_read(&adapter->rrd_ring.next_to_clean);
+		value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
+			MB_RFD_PROD_INDX_SHIFT) |
+                        ((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
+			MB_RRD_CONS_INDX_SHIFT) |
+                        ((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
+			MB_TPD_PROD_INDX_SHIFT);
+		iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
+		spin_unlock(&adapter->mb_lock);
+	}
+}
+
+static void atl1_intr_tx(struct atl1_adapter *adapter)
+{
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
+	struct atl1_buffer *buffer_info;
+	u16 sw_tpd_next_to_clean;
+	u16 cmb_tpd_next_to_clean;
+
+	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
+	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
+
+	while (cmb_tpd_next_to_clean != sw_tpd_next_to_clean) {
+		struct tx_packet_desc *tpd;
+
+		tpd = ATL1_TPD_DESC(tpd_ring, sw_tpd_next_to_clean);
+		buffer_info = &tpd_ring->buffer_info[sw_tpd_next_to_clean];
+		if (buffer_info->dma) {
+			pci_unmap_page(adapter->pdev, buffer_info->dma,
+				       buffer_info->length, PCI_DMA_TODEVICE);
+			buffer_info->dma = 0;
+		}
+
+		if (buffer_info->skb) {
+			dev_kfree_skb_irq(buffer_info->skb);
+			buffer_info->skb = NULL;
+		}
+		tpd->buffer_addr = 0;
+		tpd->desc.data = 0;
+
+		if (++sw_tpd_next_to_clean == tpd_ring->count)
+			sw_tpd_next_to_clean = 0;
+	}
+	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
+
+	if (netif_queue_stopped(adapter->netdev)
+	    && netif_carrier_ok(adapter->netdev))
+		netif_wake_queue(adapter->netdev);
 }
 
 static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
@@ -1465,31 +1646,6 @@ static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
 	atomic_set(&tpd_ring->next_to_use, (int)tpd_next_to_use);
 }
 
-static void atl1_update_mailbox(struct atl1_adapter *adapter)
-{
-	unsigned long flags;
-	u32 tpd_next_to_use;
-	u32 rfd_next_to_use;
-	u32 rrd_next_to_clean;
-	u32 value;
-
-	spin_lock_irqsave(&adapter->mb_lock, flags);
-
-	tpd_next_to_use = atomic_read(&adapter->tpd_ring.next_to_use);
-	rfd_next_to_use = atomic_read(&adapter->rfd_ring.next_to_use);
-	rrd_next_to_clean = atomic_read(&adapter->rrd_ring.next_to_clean);
-
-	value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
-		MB_RFD_PROD_INDX_SHIFT) |
-		((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
-		MB_RRD_CONS_INDX_SHIFT) |
-		((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
-		MB_TPD_PROD_INDX_SHIFT);
-	iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
-
-	spin_unlock_irqrestore(&adapter->mb_lock, flags);
-}
-
 static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1601,129 +1757,208 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 }
 
 /*
- * atl1_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
+ * atl1_intr - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ * @pt_regs: CPU registers structure
  */
-static struct net_device_stats *atl1_get_stats(struct net_device *netdev)
+static irqreturn_t atl1_intr(int irq, void *data)
 {
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	return &adapter->net_stats;
-}
+	struct atl1_adapter *adapter = netdev_priv(data);
+	u32 status;
+	u8 update_rx;
+	int max_ints = 10;
 
-/*
- * atl1_clean_rx_ring - Free RFD Buffers
- * @adapter: board private structure
- */
-static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
-{
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
-	struct atl1_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
-	unsigned long size;
-	unsigned int i;
+	status = adapter->cmb.cmb->int_stats;
+	if (!status)
+		return IRQ_NONE;
 
-	/* Free all the Rx ring sk_buffs */
-	for (i = 0; i < rfd_ring->count; i++) {
-		buffer_info = &rfd_ring->buffer_info[i];
-		if (buffer_info->dma) {
-			pci_unmap_page(pdev, buffer_info->dma,
-				buffer_info->length, PCI_DMA_FROMDEVICE);
-			buffer_info->dma = 0;
+	update_rx = 0;
+
+	do {
+		/* clear CMB interrupt status at once */
+		adapter->cmb.cmb->int_stats = 0;
+
+		if (status & ISR_GPHY)	/* clear phy status */
+			atl1_clear_phy_int(adapter);
+
+		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
+		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
+
+		/* check if SMB intr */
+		if (status & ISR_SMB)
+			atl1_inc_smb(adapter);
+
+		/* check if PCIE PHY Link down */
+		if (status & ISR_PHY_LINKDOWN) {
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie phy link down %x\n", status);
+			if (netif_running(adapter->netdev)) {	/* reset MAC */
+				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+				schedule_work(&adapter->pcie_dma_to_rst_task);
+				return IRQ_HANDLED;
+			}
 		}
-		if (buffer_info->skb) {
-			dev_kfree_skb(buffer_info->skb);
-			buffer_info->skb = NULL;
+
+		/* check if DMA read/write error ? */
+		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie DMA r/w error (status = 0x%x)\n",
+				status);
+			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+			schedule_work(&adapter->pcie_dma_to_rst_task);
+			return IRQ_HANDLED;
 		}
-	}
 
-	size = sizeof(struct atl1_buffer) * rfd_ring->count;
-	memset(rfd_ring->buffer_info, 0, size);
+		/* link event */
+		if (status & ISR_GPHY) {
+			adapter->soft_stats.tx_carrier_errors++;
+			atl1_check_for_link(adapter);
+		}
 
-	/* Zero out the descriptor ring */
-	memset(rfd_ring->desc, 0, rfd_ring->size);
+		/* transmit event */
+		if (status & ISR_CMB_TX)
+			atl1_intr_tx(adapter);
 
-	rfd_ring->next_to_clean = 0;
-	atomic_set(&rfd_ring->next_to_use, 0);
+		/* rx exception */
+		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
+			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+				ISR_HOST_RRD_OV))
+				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+					"rx exception, ISR = 0x%x\n", status);
+			atl1_intr_rx(adapter);
+		}
 
-	rrd_ring->next_to_use = 0;
-	atomic_set(&rrd_ring->next_to_clean, 0);
+		if (--max_ints < 0)
+			break;
+
+	} while ((status = adapter->cmb.cmb->int_stats));
+
+	/* re-enable Interrupt */
+	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
+	return IRQ_HANDLED;
 }
 
 /*
- * atl1_clean_tx_ring - Free Tx Buffers
- * @adapter: board private structure
+ * atl1_watchdog - Timer Call-back
+ * @data: pointer to netdev cast into an unsigned long
  */
-static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
+static void atl1_watchdog(unsigned long data)
 {
-	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-	struct atl1_buffer *buffer_info;
-	struct pci_dev *pdev = adapter->pdev;
-	unsigned long size;
-	unsigned int i;
+	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
 
-	/* Free all the Tx ring sk_buffs */
-	for (i = 0; i < tpd_ring->count; i++) {
-		buffer_info = &tpd_ring->buffer_info[i];
-		if (buffer_info->dma) {
-			pci_unmap_page(pdev, buffer_info->dma,
-				buffer_info->length, PCI_DMA_TODEVICE);
-			buffer_info->dma = 0;
-		}
-	}
+	/* Reset the timer */
+	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+}
 
-	for (i = 0; i < tpd_ring->count; i++) {
-		buffer_info = &tpd_ring->buffer_info[i];
-		if (buffer_info->skb) {
-			dev_kfree_skb_any(buffer_info->skb);
-			buffer_info->skb = NULL;
-		}
-	}
+/*
+ * atl1_phy_config - Timer Call-back
+ * @data: pointer to netdev cast into an unsigned long
+ */
+static void atl1_phy_config(unsigned long data)
+{
+	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
+	struct atl1_hw *hw = &adapter->hw;
+	unsigned long flags;
 
-	size = sizeof(struct atl1_buffer) * tpd_ring->count;
-	memset(tpd_ring->buffer_info, 0, size);
+	spin_lock_irqsave(&adapter->lock, flags);
+	adapter->phy_timer_pending = false;
+	atl1_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_reg);
+	atl1_write_phy_reg(hw, MII_AT001_CR, hw->mii_1000t_ctrl_reg);
+	atl1_write_phy_reg(hw, MII_BMCR, MII_CR_RESET | MII_CR_AUTO_NEG_EN);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
 
-	/* Zero out the descriptor ring */
-	memset(tpd_ring->desc, 0, tpd_ring->size);
+/*
+ * atl1_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ */
+static void atl1_tx_timeout(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	/* Do the reset outside of interrupt context */
+	schedule_work(&adapter->tx_timeout_task);
+}
 
-	atomic_set(&tpd_ring->next_to_use, 0);
-	atomic_set(&tpd_ring->next_to_clean, 0);
+/*
+ * Orphaned vendor comment left intact here:
+ * <vendor comment>
+ * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
+ * will assert. We do soft reset <0x1400=1> according
+ * with the SPEC. BUT, it seemes that PCIE or DMA
+ * state-machine will not be reset. DMAR_TO_INT will
+ * assert again and again.
+ * </vendor comment>
+ */
+static void atl1_tx_timeout_task(struct work_struct *work)
+{
+	struct atl1_adapter *adapter =
+		container_of(work, struct atl1_adapter, tx_timeout_task);
+	struct net_device *netdev = adapter->netdev;
+
+	netif_device_detach(netdev);
+	atl1_down(adapter);
+	atl1_up(adapter);
+	netif_device_attach(netdev);
 }
 
 /*
- * atl1_free_ring_resources - Free Tx / RX descriptor Resources
- * @adapter: board private structure
- *
- * Free all transmit software resources
+ * atl1_link_chg_task - deal with link change event Out of interrupt context
  */
-void atl1_free_ring_resources(struct atl1_adapter *adapter)
+static void atl1_link_chg_task(struct work_struct *work)
 {
-	struct pci_dev *pdev = adapter->pdev;
-	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
-	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
-	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
-	struct atl1_ring_header *ring_header = &adapter->ring_header;
+	struct atl1_adapter *adapter =
+               container_of(work, struct atl1_adapter, link_chg_task);
+	unsigned long flags;
 
-	atl1_clean_tx_ring(adapter);
-	atl1_clean_rx_ring(adapter);
+	spin_lock_irqsave(&adapter->lock, flags);
+	atl1_check_link(adapter);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
 
-	kfree(tpd_ring->buffer_info);
-	pci_free_consistent(pdev, ring_header->size, ring_header->desc,
-		ring_header->dma);
+static void atl1_vlan_rx_register(struct net_device *netdev,
+	struct vlan_group *grp)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
+	u32 ctrl;
 
-	tpd_ring->buffer_info = NULL;
-	tpd_ring->desc = NULL;
-	tpd_ring->dma = 0;
+	spin_lock_irqsave(&adapter->lock, flags);
+	/* atl1_irq_disable(adapter); */
+	adapter->vlgrp = grp;
 
-	rfd_ring->buffer_info = NULL;
-	rfd_ring->desc = NULL;
-	rfd_ring->dma = 0;
+	if (grp) {
+		/* enable VLAN tag insert/strip */
+		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+		ctrl |= MAC_CTRL_RMV_VLAN;
+		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+		ctrl &= ~MAC_CTRL_RMV_VLAN;
+		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+	}
 
-	rrd_ring->desc = NULL;
-	rrd_ring->dma = 0;
+	/* atl1_irq_enable(adapter); */
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
+static void atl1_restore_vlan(struct atl1_adapter *adapter)
+{
+	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+}
+
+int atl1_reset(struct atl1_adapter *adapter)
+{
+	int ret;
+
+	ret = atl1_reset_hw(&adapter->hw);
+	if (ret != ATL1_SUCCESS)
+		return ret;
+	return atl1_init_hw(&adapter->hw);
 }
 
 s32 atl1_up(struct atl1_adapter *adapter)
@@ -1793,173 +2028,6 @@ void atl1_down(struct atl1_adapter *adapter)
 }
 
 /*
- * atl1_change_mtu - Change the Maximum Transfer Unit
- * @netdev: network interface device structure
- * @new_mtu: new value for maximum frame size
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-
-	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
-
-	adapter->hw.max_frame_size = max_frame;
-	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
-	adapter->rx_buffer_len = (max_frame + 7) & ~7;
-	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
-
-	netdev->mtu = new_mtu;
-	if ((old_mtu != new_mtu) && netif_running(netdev)) {
-		atl1_down(adapter);
-		atl1_up(adapter);
-	}
-
-	return 0;
-}
-
-/*
- * atl1_set_mac - Change the Ethernet Address of the NIC
- * @netdev: network interface device structure
- * @p: pointer to an address structure
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_set_mac(struct net_device *netdev, void *p)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct sockaddr *addr = p;
-
-	if (netif_running(netdev))
-		return -EBUSY;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
-
-	atl1_set_mac_addr(&adapter->hw);
-	return 0;
-}
-
-/*
- * atl1_watchdog - Timer Call-back
- * @data: pointer to netdev cast into an unsigned long
- */
-static void atl1_watchdog(unsigned long data)
-{
-	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
-
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
-}
-
-static int mdio_read(struct net_device *netdev, int phy_id, int reg_num)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	u16 result;
-
-	atl1_read_phy_reg(&adapter->hw, reg_num & 0x1f, &result);
-
-	return result;
-}
-
-static void mdio_write(struct net_device *netdev, int phy_id, int reg_num,
-	int val)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-
-	atl1_write_phy_reg(&adapter->hw, reg_num, val);
-}
-
-/*
- * atl1_mii_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
-static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
-	int retval;
-
-	if (!netif_running(netdev))
-		return -EINVAL;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	retval = generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-
-	return retval;
-}
-
-/*
- * atl1_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
-static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
-{
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		return atl1_mii_ioctl(netdev, ifr, cmd);
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-/*
- * atl1_tx_timeout - Respond to a Tx Hang
- * @netdev: network interface device structure
- */
-static void atl1_tx_timeout(struct net_device *netdev)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->tx_timeout_task);
-}
-
-/*
- * atl1_phy_config - Timer Call-back
- * @data: pointer to netdev cast into an unsigned long
- */
-static void atl1_phy_config(unsigned long data)
-{
-	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
-	struct atl1_hw *hw = &adapter->hw;
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	adapter->phy_timer_pending = false;
-	atl1_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_reg);
-	atl1_write_phy_reg(hw, MII_AT001_CR, hw->mii_1000t_ctrl_reg);
-	atl1_write_phy_reg(hw, MII_BMCR, MII_CR_RESET | MII_CR_AUTO_NEG_EN);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
-int atl1_reset(struct atl1_adapter *adapter)
-{
-	int ret;
-
-	ret = atl1_reset_hw(&adapter->hw);
-	if (ret != ATL1_SUCCESS)
-		return ret;
-	return atl1_init_hw(&adapter->hw);
-}
-
-/*
  * atl1_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2011,82 +2079,113 @@ static int atl1_close(struct net_device *netdev)
 	return 0;
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void atl1_poll_controller(struct net_device *netdev)
-{
-	disable_irq(netdev->irq);
-	atl1_intr(netdev->irq, netdev);
-	enable_irq(netdev->irq);
-}
-#endif
-
-/*
- * Orphaned vendor comment left intact here:
- * <vendor comment>
- * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
- * will assert. We do soft reset <0x1400=1> according
- * with the SPEC. BUT, it seemes that PCIE or DMA
- * state-machine will not be reset. DMAR_TO_INT will
- * assert again and again.
- * </vendor comment>
- */
-static void atl1_tx_timeout_task(struct work_struct *work)
+#ifdef CONFIG_PM
+static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	struct atl1_adapter *adapter =
-		container_of(work, struct atl1_adapter, tx_timeout_task);
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_hw *hw = &adapter->hw;
+	u32 ctrl = 0;
+	u32 wufc = adapter->wol;
 
 	netif_device_detach(netdev);
-	atl1_down(adapter);
-	atl1_up(adapter);
-	netif_device_attach(netdev);
-}
+	if (netif_running(netdev))
+		atl1_down(adapter);
 
-/*
- * atl1_link_chg_task - deal with link change event Out of interrupt context
- */
-static void atl1_link_chg_task(struct work_struct *work)
-{
-	struct atl1_adapter *adapter =
-               container_of(work, struct atl1_adapter, link_chg_task);
-	unsigned long flags;
+	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
+	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
+	if (ctrl & BMSR_LSTATUS)
+		wufc &= ~ATL1_WUFC_LNKC;
 
-	spin_lock_irqsave(&adapter->lock, flags);
-	atl1_check_link(adapter);
-	spin_unlock_irqrestore(&adapter->lock, flags);
+	/* reduce speed to 10/100M */
+	if (wufc) {
+		atl1_phy_enter_power_saving(hw);
+		/* if resume, let driver to re- setup link */
+		hw->phy_configured = false;
+		atl1_set_mac_addr(hw);
+		atl1_set_multi(netdev);
+
+		ctrl = 0;
+		/* turn on magic packet wol */
+		if (wufc & ATL1_WUFC_MAG)
+			ctrl = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
+
+		/* turn on Link change WOL */
+		if (wufc & ATL1_WUFC_LNKC)
+			ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
+		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
+
+		/* turn on all-multi mode if wake on multicast is enabled */
+		ctrl = ioread32(hw->hw_addr + REG_MAC_CTRL);
+		ctrl &= ~MAC_CTRL_DBG;
+		ctrl &= ~MAC_CTRL_PROMIS_EN;
+		if (wufc & ATL1_WUFC_MC)
+			ctrl |= MAC_CTRL_MC_ALL_EN;
+		else
+			ctrl &= ~MAC_CTRL_MC_ALL_EN;
+
+		/* turn on broadcast mode if wake on-BC is enabled */
+		if (wufc & ATL1_WUFC_BC)
+			ctrl |= MAC_CTRL_BC_EN;
+		else
+			ctrl &= ~MAC_CTRL_BC_EN;
+
+		/* enable RX */
+		ctrl |= MAC_CTRL_RX_EN;
+		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
+		pci_enable_wake(pdev, PCI_D3hot, 1);
+		pci_enable_wake(pdev, PCI_D3cold, 1);
+	} else {
+		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+	}
+
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
 }
 
-/*
- * atl1_pcie_patch - Patch for PCIE module
- */
-static void atl1_pcie_patch(struct atl1_adapter *adapter)
+static int atl1_resume(struct pci_dev *pdev)
 {
-	u32 value;
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	u32 ret_val;
 
-	/* much vendor magic here */
-	value = 0x6500;
-	iowrite32(value, adapter->hw.hw_addr + 0x12FC);
-	/* pcie flow control mode change */
-	value = ioread32(adapter->hw.hw_addr + 0x1008);
-	value |= 0x8000;
-	iowrite32(value, adapter->hw.hw_addr + 0x1008);
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev);
+
+	ret_val = pci_enable_device(pdev);
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
+	atl1_reset(adapter);
+
+	if (netif_running(netdev))
+		atl1_up(adapter);
+	netif_device_attach(netdev);
+
+	atl1_via_workaround(adapter);
+
+	return 0;
 }
+#else
+#define atl1_suspend NULL
+#define atl1_resume NULL
+#endif
 
-/*
- * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
- * on PCI Command register is disable.
- * The function enable this bit.
- * Brackett, 2006/03/15
- */
-static void atl1_via_workaround(struct atl1_adapter *adapter)
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void atl1_poll_controller(struct net_device *netdev)
 {
-	unsigned long value;
-
-	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
-	if (value & PCI_COMMAND_INTX_DISABLE)
-		value &= ~PCI_COMMAND_INTX_DISABLE;
-	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
+	disable_irq(netdev->irq);
+	atl1_intr(netdev->irq, netdev);
+	enable_irq(netdev->irq);
 }
+#endif
 
 /*
  * atl1_probe - Device Initialization Routine
@@ -2320,105 +2419,6 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-#ifdef CONFIG_PM
-static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct atl1_hw *hw = &adapter->hw;
-	u32 ctrl = 0;
-	u32 wufc = adapter->wol;
-
-	netif_device_detach(netdev);
-	if (netif_running(netdev))
-		atl1_down(adapter);
-
-	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
-	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
-	if (ctrl & BMSR_LSTATUS)
-		wufc &= ~ATL1_WUFC_LNKC;
-
-	/* reduce speed to 10/100M */
-	if (wufc) {
-		atl1_phy_enter_power_saving(hw);
-		/* if resume, let driver to re- setup link */
-		hw->phy_configured = false;
-		atl1_set_mac_addr(hw);
-		atl1_set_multi(netdev);
-
-		ctrl = 0;
-		/* turn on magic packet wol */
-		if (wufc & ATL1_WUFC_MAG)
-			ctrl = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
-
-		/* turn on Link change WOL */
-		if (wufc & ATL1_WUFC_LNKC)
-			ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
-		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
-
-		/* turn on all-multi mode if wake on multicast is enabled */
-		ctrl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_DBG;
-		ctrl &= ~MAC_CTRL_PROMIS_EN;
-		if (wufc & ATL1_WUFC_MC)
-			ctrl |= MAC_CTRL_MC_ALL_EN;
-		else
-			ctrl &= ~MAC_CTRL_MC_ALL_EN;
-
-		/* turn on broadcast mode if wake on-BC is enabled */
-		if (wufc & ATL1_WUFC_BC)
-			ctrl |= MAC_CTRL_BC_EN;
-		else
-			ctrl &= ~MAC_CTRL_BC_EN;
-
-		/* enable RX */
-		ctrl |= MAC_CTRL_RX_EN;
-		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
-		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
-	}
-
-	pci_save_state(pdev);
-	pci_disable_device(pdev);
-
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return 0;
-}
-
-static int atl1_resume(struct pci_dev *pdev)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	u32 ret_val;
-
-	pci_set_power_state(pdev, 0);
-	pci_restore_state(pdev);
-
-	ret_val = pci_enable_device(pdev);
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
-	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
-	atl1_reset(adapter);
-
-	if (netif_running(netdev))
-		atl1_up(adapter);
-	netif_device_attach(netdev);
-
-	atl1_via_workaround(adapter);
-
-	return 0;
-}
-#else
-#define atl1_suspend NULL
-#define atl1_resume NULL
-#endif
-
 static struct pci_driver atl1_driver = {
 	.name = atl1_driver_name,
 	.id_table = atl1_pci_tbl,
-- 
1.5.2.2

