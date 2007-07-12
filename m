From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 2/4]S2IO: Removing MSI support from the driver
Date: Thu, 12 Jul 2007 06:18:38 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10707120613450.16507-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:44727 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbXGLKSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 06:18:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Removed MSI support from driver - unused feature
 - Incorporated Jeff Garzik's comments on elimination of inline typecasting

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -Nurp 2.0.23.1P1/drivers/net/s2io.c 2.0.23.1P2/drivers/net/s2io.c
--- 2.0.23.1P1/drivers/net/s2io.c	2007-07-03 11:39:24.000000000 -0700
+++ 2.0.23.1P2/drivers/net/s2io.c	2007-07-04 02:05:10.000000000 -0700
@@ -37,7 +37,7 @@
  * tx_fifo_len: This too is an array of 8. Each element defines the number of
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be 0(INTA),
- *     1(MSI), 2(MSI_X). Default value is '0(INTA)'
+ *     2(MSI-X). Default value is '0(INTA)'
  * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
@@ -427,7 +427,7 @@ S2IO_PARM_INT(bimodal, 0);
 S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
-/* Interrupt type. Values can be 0(INTA), 1(MSI), 2(MSI_X) */
+/* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 0);
 /* Large receive offload feature */
 S2IO_PARM_INT(lro, 0);
@@ -2231,14 +2231,15 @@ static int fill_rxd_3buf(struct s2io_nic
 	struct net_device *dev = nic->dev;
 	struct sk_buff *frag_list;
 	void *tmp;
+	struct RxD3 *rxdp3 = (struct RxD3*)rxdp;
 
 	/* Buffer-1 receives L3/L4 headers */
-	((struct RxD3*)rxdp)->Buffer1_ptr = pci_map_single
+	rxdp3->Buffer1_ptr = pci_map_single
 			(nic->pdev, skb->data, l3l4hdr_size + 4,
 			PCI_DMA_FROMDEVICE);
 
-	if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
-		(((struct RxD3*)rxdp)->Buffer1_ptr == DMA_ERROR_CODE)) {
+	if ((rxdp3->Buffer1_ptr == 0) ||
+		(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
 		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
 		return -ENOMEM;
 	}
@@ -2263,11 +2264,11 @@ static int fill_rxd_3buf(struct s2io_nic
 	skb_reset_tail_pointer(frag_list);
 
 	/* Buffer-2 receives L4 data payload */
-	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
+	rxdp3->Buffer2_ptr = pci_map_single(nic->pdev,
 				frag_list->data, dev->mtu,
 				PCI_DMA_FROMDEVICE);
-	if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-		(((struct RxD3*)rxdp)->Buffer2_ptr == DMA_ERROR_CODE)) {
+	if ((rxdp3->Buffer2_ptr == 0) ||
+		(rxdp3->Buffer2_ptr == DMA_ERROR_CODE)) {
 		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
 		return -ENOMEM;
 	}
@@ -2313,6 +2314,8 @@ static int fill_rx_buffers(struct s2io_n
 	unsigned long flags;
 	struct RxD_t *first_rxdp = NULL;
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -2398,13 +2401,15 @@ static int fill_rx_buffers(struct s2io_n
 			+= skb->truesize;
 		if (nic->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
+
+			rxdp1 = (struct RxD1*)rxdp;
 			memset(rxdp, 0, sizeof(struct RxD1));
 			skb_reserve(skb, NET_IP_ALIGN);
-			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
+			rxdp1->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
-			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD1*)rxdp)->Buffer0_ptr == 
+			if ((rxdp1->Buffer0_ptr == 0) ||
+				(rxdp1->Buffer0_ptr == 
 				DMA_ERROR_CODE)) {
 				nic->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -2428,13 +2433,15 @@ static int fill_rx_buffers(struct s2io_n
 			 * payload
 			 */
 
+			rxdp3 = (struct RxD3*)rxdp;
+
 			/* save buffer pointers to avoid frequent dma mapping */
-			Buffer0_ptr = ((struct RxD3*)rxdp)->Buffer0_ptr;
-			Buffer1_ptr = ((struct RxD3*)rxdp)->Buffer1_ptr;
+			Buffer0_ptr = rxdp3->Buffer0_ptr;
+			Buffer1_ptr = rxdp3->Buffer1_ptr;
 			memset(rxdp, 0, sizeof(struct RxD3));
 			/* restore the buffer pointers for dma sync*/
-			((struct RxD3*)rxdp)->Buffer0_ptr = Buffer0_ptr;
-			((struct RxD3*)rxdp)->Buffer1_ptr = Buffer1_ptr;
+			rxdp3->Buffer0_ptr = Buffer0_ptr;
+			rxdp3->Buffer1_ptr = Buffer1_ptr;
 
 			ba = &mac_control->rings[ring_no].ba[block_no][off];
 			skb_reserve(skb, BUF0_LEN);
@@ -2444,11 +2451,11 @@ static int fill_rx_buffers(struct s2io_n
 			skb->data = (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
 
-			((struct RxD3*)rxdp)->Buffer0_ptr =
+			rxdp3->Buffer0_ptr =
 				pci_map_single(nic->pdev, ba->ba_0, BUF0_LEN,
 					PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+			if ((rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == 
 				DMA_ERROR_CODE)) {
 				nic->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -2465,11 +2472,11 @@ static int fill_rx_buffers(struct s2io_n
 				 * Buffer2 will have L3/L4 header plus
 				 * L4 payload
 				 */
-				((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single
+				rxdp3->Buffer2_ptr = pci_map_single
 					(nic->pdev, skb->data, dev->mtu + 4,
 					PCI_DMA_FROMDEVICE);
-				if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-					(((struct RxD3*)rxdp)->Buffer2_ptr == 
+				if ((rxdp3->Buffer2_ptr == 0) ||
+					(rxdp3->Buffer2_ptr == 
 					DMA_ERROR_CODE)) {
 					nic->mac_control.stats_info->sw_stat.
 						pci_map_fail_cnt++;
@@ -2479,12 +2486,12 @@ static int fill_rx_buffers(struct s2io_n
 					return -ENOMEM;
 				}
 
-				((struct RxD3*)rxdp)->Buffer1_ptr =
+				rxdp3->Buffer1_ptr =
 						pci_map_single(nic->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
-				if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
-					(((struct RxD3*)rxdp)->Buffer1_ptr == 
+				if ((rxdp3->Buffer1_ptr == 0) ||
+					(rxdp3->Buffer1_ptr == 
 					DMA_ERROR_CODE)) {
 					nic->mac_control.stats_info->sw_stat.
 						pci_map_fail_cnt++;
@@ -2558,6 +2565,8 @@ static void free_rxd_blk(struct s2io_nic
 	struct RxD_t *rxdp;
 	struct mac_info *mac_control;
 	struct buffAdd *ba;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	mac_control = &sp->mac_control;
 	for (j = 0 ; j < rxd_count[sp->rxd_mode]; j++) {
@@ -2569,8 +2578,9 @@ static void free_rxd_blk(struct s2io_nic
 			continue;
 		}
 		if (sp->rxd_mode == RXD_MODE_1) {
+			rxdp1 = (struct RxD1 *)rxdp;
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
+				 rxdp1->Buffer0_ptr,
 				 dev->mtu +
 				 HEADER_ETHERNET_II_802_3_SIZE
 				 + HEADER_802_2_SIZE +
@@ -2578,31 +2588,33 @@ static void free_rxd_blk(struct s2io_nic
 				 PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD1));
 		} else if(sp->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3*)rxdp;
 			ba = &mac_control->rings[ring_no].
 				ba[blk][j];
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
+				 rxdp3->Buffer0_ptr,
 				 BUF0_LEN,
 				 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
+				 rxdp3->Buffer1_ptr,
 				 BUF1_LEN,
 				 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
+				 rxdp3->Buffer2_ptr,
 				 dev->mtu + 4,
 				 PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		} else {
+			rxdp3 = (struct RxD3*)rxdp;
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
+				rxdp3->Buffer0_ptr, BUF0_LEN,
 				PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer1_ptr,
+				rxdp3->Buffer1_ptr,
 				l3l4hdr_size + 4,
 				PCI_DMA_FROMDEVICE);
 			pci_unmap_single(sp->pdev, (dma_addr_t)
-				((struct RxD3*)rxdp)->Buffer2_ptr, dev->mtu,
+				rxdp3->Buffer2_ptr, dev->mtu,
 				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
@@ -2799,6 +2811,8 @@ static void rx_intr_handler(struct ring_
 	struct sk_buff *skb;
 	int pkt_cnt = 0;
 	int i;
+	struct RxD1 *rxdp1;
+	struct RxD3 *rxdp3;
 
 	spin_lock(&nic->rx_lock);
 	if (atomic_read(&nic->card_state) == CARD_DOWN) {
@@ -2839,34 +2853,37 @@ static void rx_intr_handler(struct ring_
 			return;
 		}
 		if (nic->rxd_mode == RXD_MODE_1) {
+			rxdp1 = (struct RxD1 *)rxdp;
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD1*)rxdp)->Buffer0_ptr,
+				 rxdp1->Buffer0_ptr,
 				 dev->mtu +
 				 HEADER_ETHERNET_II_802_3_SIZE +
 				 HEADER_802_2_SIZE +
 				 HEADER_SNAP_SIZE,
 				 PCI_DMA_FROMDEVICE);
 		} else if (nic->rxd_mode == RXD_MODE_3B) {
+			rxdp3 = (struct RxD3 *)rxdp;
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr,
+				 rxdp3->Buffer0_ptr,
 				 BUF0_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
+				 rxdp3->Buffer1_ptr,
 				 BUF1_LEN, PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
+				 rxdp3->Buffer2_ptr,
 				 dev->mtu + 4,
 				 PCI_DMA_FROMDEVICE);
 		} else {
+			rxdp3 = (struct RxD3 *)rxdp;
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
+				 rxdp3->Buffer0_ptr, BUF0_LEN,
 				 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer1_ptr,
+				 rxdp3->Buffer1_ptr,
 				 l3l4hdr_size + 4,
 				 PCI_DMA_FROMDEVICE);
 			pci_unmap_single(nic->pdev, (dma_addr_t)
-				 ((struct RxD3*)rxdp)->Buffer2_ptr,
+				 rxdp3->Buffer2_ptr,
 				 dev->mtu, PCI_DMA_FROMDEVICE);
 		}
 		prefetch(skb->data);
@@ -3775,56 +3792,6 @@ static void store_xmsi_data(struct s2io_
 	}
 }
 
-int s2io_enable_msi(struct s2io_nic *nic)
-{
-	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	u16 msi_ctrl, msg_val;
-	struct config_param *config = &nic->config;
-	struct net_device *dev = nic->dev;
-	u64 val64, tx_mat, rx_mat;
-	int i, err;
-
-	val64 = readq(&bar0->pic_control);
-	val64 &= ~BIT(1);
-	writeq(val64, &bar0->pic_control);
-
-	err = pci_enable_msi(nic->pdev);
-	if (err) {
-		DBG_PRINT(ERR_DBG, "%s: enabling MSI failed\n",
-			  nic->dev->name);
-		return err;
-	}
-
-	/*
-	 * Enable MSI and use MSI-1 in stead of the standard MSI-0
-	 * for interrupt handling.
-	 */
-	pci_read_config_word(nic->pdev, 0x4c, &msg_val);
-	msg_val ^= 0x1;
-	pci_write_config_word(nic->pdev, 0x4c, msg_val);
-	pci_read_config_word(nic->pdev, 0x4c, &msg_val);
-
-	pci_read_config_word(nic->pdev, 0x42, &msi_ctrl);
-	msi_ctrl |= 0x10;
-	pci_write_config_word(nic->pdev, 0x42, msi_ctrl);
-
-	/* program MSI-1 into all usable Tx_Mat and Rx_Mat fields */
-	tx_mat = readq(&bar0->tx_mat0_n[0]);
-	for (i=0; i<config->tx_fifo_num; i++) {
-		tx_mat |= TX_MAT_SET(i, 1);
-	}
-	writeq(tx_mat, &bar0->tx_mat0_n[0]);
-
-	rx_mat = readq(&bar0->rx_mat);
-	for (i=0; i<config->rx_ring_num; i++) {
-		rx_mat |= RX_MAT_SET(i, 1);
-	}
-	writeq(rx_mat, &bar0->rx_mat);
-
-	dev->irq = nic->pdev->irq;
-	return 0;
-}
-
 static int s2io_enable_msi_x(struct s2io_nic *nic)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
@@ -4255,39 +4222,6 @@ static int s2io_chk_rx_buffers(struct s2
 	return 0;
 }
 
-static irqreturn_t s2io_msi_handle(int irq, void *dev_id)
-{
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct s2io_nic *sp = dev->priv;
-	int i;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	atomic_inc(&sp->isr_cnt);
-	mac_control = &sp->mac_control;
-	config = &sp->config;
-	DBG_PRINT(INTR_DBG, "%s: MSI handler\n", __FUNCTION__);
-
-	/* If Intr is because of Rx Traffic */
-	for (i = 0; i < config->rx_ring_num; i++)
-		rx_intr_handler(&mac_control->rings[i]);
-
-	/* If Intr is because of Tx Traffic */
-	for (i = 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&mac_control->fifos[i]);
-
-	/*
-	 * If the Rx buffer count is below the panic threshold then
-	 * reallocate the buffers from the interrupt handler itself,
-	 * else schedule a tasklet to reallocate the buffers.
-	 */
-	for (i = 0; i < config->rx_ring_num; i++)
-		s2io_chk_rx_buffers(sp, i);
-
-	atomic_dec(&sp->isr_cnt);
-	return IRQ_HANDLED;
-}
-
 static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 {
 	struct ring_info *ring = (struct ring_info *)dev_id;
@@ -6335,6 +6269,8 @@ static int set_rxd_buffer_pointer(struct
 	struct sk_buff *frag_list;
 
 	if ((sp->rxd_mode == RXD_MODE_1) && (rxdp->Host_Control == 0)) {
+		struct RxD1 *rxdp1 = (struct RxD1 *)rxdp;
+
 		/* allocate skb */
 		if (*skb) {
 			DBG_PRINT(INFO_DBG, "SKB is not NULL\n");
@@ -6343,7 +6279,7 @@ static int set_rxd_buffer_pointer(struct
 			 * using same mapped address for the Rxd
 			 * buffer pointer
 			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0;
+			rxdp1->Buffer0_ptr = *temp0;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6360,12 +6296,12 @@ static int set_rxd_buffer_pointer(struct
 			 * such it will be used for next rxd whose
 			 * Host Control is NULL
 			 */
-			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0 =
+			rxdp1->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, (*skb)->data,
 					size - NET_IP_ALIGN,
 					PCI_DMA_FROMDEVICE);
-			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD1*)rxdp)->Buffer0_ptr == 
+			if ((rxdp1->Buffer0_ptr == 0) ||
+				(rxdp1->Buffer0_ptr == 
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6378,10 +6314,12 @@ static int set_rxd_buffer_pointer(struct
 		}
 	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
 		/* Two buffer Mode */
+		struct RxD3 *rxdp3 = (struct RxD3 *)rxdp;
+
 		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
+			rxdp3->Buffer2_ptr = *temp2;
+			rxdp3->Buffer0_ptr = *temp0;
+			rxdp3->Buffer1_ptr = *temp1;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6394,12 +6332,12 @@ static int set_rxd_buffer_pointer(struct
 			}
 			sp->mac_control.stats_info->sw_stat.mem_allocated 
 				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
+			rxdp3->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
 					       PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer2_ptr ==
+			if ((rxdp3->Buffer2_ptr == 0) ||
+				(rxdp3->Buffer2_ptr ==
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6408,11 +6346,11 @@ static int set_rxd_buffer_pointer(struct
 				dev_kfree_skb(*skb);
 				return -ENOMEM;
 			}
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
+			rxdp3->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
 						PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+			if ((rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == 
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6427,11 +6365,11 @@ static int set_rxd_buffer_pointer(struct
 			rxdp->Host_Control = (unsigned long) (*skb);
 
 			/* Buffer-1 will be dummy buffer not used */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
+			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
 					       PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+			if ((rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == 
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6445,11 +6383,13 @@ static int set_rxd_buffer_pointer(struct
 			}
 		}
 	} else if ((rxdp->Host_Control == 0)) {
+		struct RxD3 *rxdp3 = (struct RxD3 *)rxdp;
+
 		/* Three buffer mode */
 		if (*skb) {
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
+			rxdp3->Buffer0_ptr = *temp0;
+			rxdp3->Buffer1_ptr = *temp1;
+			rxdp3->Buffer2_ptr = *temp2;
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
@@ -6462,11 +6402,11 @@ static int set_rxd_buffer_pointer(struct
 			}
 			sp->mac_control.stats_info->sw_stat.mem_allocated 
 				+= (*skb)->truesize;
-			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
+			rxdp3->Buffer0_ptr = *temp0 =
 				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
 					       PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer0_ptr == 
+			if ((rxdp3->Buffer0_ptr == 0) ||
+				(rxdp3->Buffer0_ptr == 
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6476,12 +6416,12 @@ static int set_rxd_buffer_pointer(struct
 				return -ENOMEM;
 			}
 			/* Buffer-1 receives L3/L4 headers */
-			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
+			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single( sp->pdev, (*skb)->data,
 						l3l4hdr_size + 4,
 						PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer1_ptr == 
+			if ((rxdp3->Buffer1_ptr == 0) ||
+				(rxdp3->Buffer1_ptr == 
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6517,11 +6457,11 @@ static int set_rxd_buffer_pointer(struct
 			/*
 			 * Buffer-2 receives L4 data payload
 			 */
-			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
+			rxdp3->Buffer2_ptr = *temp2 =
 				pci_map_single( sp->pdev, frag_list->data,
 						dev->mtu, PCI_DMA_FROMDEVICE);
-			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
-				(((struct RxD3*)rxdp)->Buffer2_ptr ==
+			if ((rxdp3->Buffer2_ptr == 0) ||
+				(rxdp3->Buffer2_ptr ==
 				DMA_ERROR_CODE)) {
 				sp->mac_control.stats_info->sw_stat.
 					pci_map_fail_cnt++;
@@ -6610,10 +6550,9 @@ static int s2io_add_isr(struct s2io_nic 
 	struct net_device *dev = sp->dev;
 	int err = 0;
 
-	if (sp->intr_type == MSI)
-		ret = s2io_enable_msi(sp);
-	else if (sp->intr_type == MSI_X)
+	if (sp->intr_type == MSI_X) 
 		ret = s2io_enable_msi_x(sp);
+
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Defaulting to INTA\n", dev->name);
 		sp->intr_type = INTA;
@@ -6623,16 +6562,6 @@ static int s2io_add_isr(struct s2io_nic 
 	store_xmsi_data(sp);
 
 	/* After proper initialization of H/W, register ISR */
-	if (sp->intr_type == MSI) {
-		err = request_irq((int) sp->pdev->irq, s2io_msi_handle,
-			IRQF_SHARED, sp->name, dev);
-		if (err) {
-			pci_disable_msi(sp->pdev);
-			DBG_PRINT(ERR_DBG, "%s: MSI registration failed\n",
-				  dev->name);
-			return -1;
-		}
-	}
 	if (sp->intr_type == MSI_X) {
 		int i, msix_tx_cnt=0,msix_rx_cnt=0;
 
@@ -6719,14 +6648,6 @@ static void s2io_rem_isr(struct s2io_nic
 		pci_disable_msix(sp->pdev);
 	} else {
 		free_irq(sp->pdev->irq, dev);
-		if (sp->intr_type == MSI) {
-			u16 val;
-
-			pci_disable_msi(sp->pdev);
-			pci_read_config_word(sp->pdev, 0x4c, &val);
-			val ^= 0x1;
-			pci_write_config_word(sp->pdev, 0x4c, val);
-		}
 	}
 	/* Waiting till all Interrupt handlers are complete */
 	cnt = 0;
@@ -7289,11 +7210,11 @@ static int s2io_verify_parm(struct pci_d
 #ifndef CONFIG_PCI_MSI
 	if (*dev_intr_type != INTA) {
 		DBG_PRINT(ERR_DBG, "s2io: This kernel does not support"
-			  "MSI/MSI-X. Defaulting to INTA\n");
+			  "MSI-X. Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
 #else
-	if (*dev_intr_type > MSI_X) {
+	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
@@ -7402,29 +7323,12 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
-	if (dev_intr_type != MSI_X) {
-		if (pci_request_regions(pdev, s2io_driver_name)) {
-			DBG_PRINT(ERR_DBG, "Request Regions failed\n");
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-	}
-	else {
-		if (!(request_mem_region(pci_resource_start(pdev, 0),
-               	         pci_resource_len(pdev, 0), s2io_driver_name))) {
-			DBG_PRINT(ERR_DBG, "bar0 Request Regions failed\n");
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-        	if (!(request_mem_region(pci_resource_start(pdev, 2),
-               	         pci_resource_len(pdev, 2), s2io_driver_name))) {
-			DBG_PRINT(ERR_DBG, "bar1 Request Regions failed\n");
-                	release_mem_region(pci_resource_start(pdev, 0),
-                                   pci_resource_len(pdev, 0));
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-	}
+
+	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __FUNCTION__, ret);
+ 		pci_disable_device(pdev);
+ 		return -ENODEV;
+ 	}
 
 	dev = alloc_etherdev(sizeof(struct s2io_nic));
 	if (dev == NULL) {
@@ -7739,9 +7643,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n", dev->name);
 		    break;
-		case MSI:
-		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI\n", dev->name);
-		    break;
 		case MSI_X:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n", dev->name);
 		    break;
@@ -7781,14 +7682,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
       mem_alloc_failed:
 	free_shared_mem(sp);
 	pci_disable_device(pdev);
-	if (dev_intr_type != MSI_X)
-		pci_release_regions(pdev);
-	else {
-		release_mem_region(pci_resource_start(pdev, 0),
-			pci_resource_len(pdev, 0));
-		release_mem_region(pci_resource_start(pdev, 2),
-			pci_resource_len(pdev, 2));
-	}
+	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
@@ -7823,14 +7717,7 @@ static void __devexit s2io_rem_nic(struc
 	free_shared_mem(sp);
 	iounmap(sp->bar0);
 	iounmap(sp->bar1);
-	if (sp->intr_type != MSI_X)
-		pci_release_regions(pdev);
-	else {
-		release_mem_region(pci_resource_start(pdev, 0),
-			pci_resource_len(pdev, 0));
-		release_mem_region(pci_resource_start(pdev, 2),
-			pci_resource_len(pdev, 2));
-	}
+	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	pci_disable_device(pdev);
diff -Nurp 2.0.23.1P1/drivers/net/s2io.h 2.0.23.1P2/drivers/net/s2io.h
--- 2.0.23.1P1/drivers/net/s2io.h	2007-07-03 11:39:27.000000000 -0700
+++ 2.0.23.1P2/drivers/net/s2io.h	2007-07-04 02:06:07.000000000 -0700
@@ -883,7 +883,6 @@ struct s2io_nic {
 	u16		lro_max_aggr_per_sess;
 
 #define INTA	0
-#define MSI	1
 #define MSI_X	2
 	u8 intr_type;
 
@@ -1027,8 +1026,6 @@ static int s2io_poll(struct net_device *
 static void s2io_init_pci(struct s2io_nic * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
-static int s2io_enable_msi(struct s2io_nic *nic);
-static irqreturn_t s2io_msi_handle(int irq, void *dev_id);
 static irqreturn_t
 s2io_msix_ring_handle(int irq, void *dev_id);
 static irqreturn_t

