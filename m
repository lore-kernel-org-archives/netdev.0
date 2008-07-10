From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 1/3]S2io: Fix IOMMU overflow checking.
Date: Wed, 9 Jul 2008 23:47:46 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10807092346390.5252-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37511 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbYGJD7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 23:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fix IOMMU overflow checking. As reported by Andi Kleen <ak@linux.intel.com> 
removed check for zero dma address.

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2.0.26.24/drivers/net/s2io.c 2.0.26.25P1/drivers/net/s2io.c
--- 2.0.26.24/drivers/net/s2io.c	2008-06-27 11:20:47.000000000 -0700
+++ 2.0.26.25P1/drivers/net/s2io.c	2008-06-27 13:22:02.000000000 -0700
@@ -2519,6 +2519,9 @@ static void stop_nic(struct s2io_nic *ni
 /**
  *  fill_rx_buffers - Allocates the Rx side skbs
  *  @ring_info: per ring structure
+ *  @from_card_up: If this is true, we will map the buffer to get
+ *     the dma address for buf0 and buf1 to give it to the card.
+ *     Else we will sync the already mapped buffer to give it to the card.
  *  Description:
  *  The function allocates Rx side skbs and puts the physical
  *  address of these buffers into the RxD buffer pointers, so that the NIC
@@ -2536,7 +2539,7 @@ static void stop_nic(struct s2io_nic *ni
  *  SUCCESS on success or an appropriate -ve value on failure.
  */
 
-static int fill_rx_buffers(struct ring_info *ring)
+static int fill_rx_buffers(struct ring_info *ring, int from_card_up)
 {
 	struct sk_buff *skb;
 	struct RxD_t *rxdp;
@@ -2655,17 +2658,16 @@ static int fill_rx_buffers(struct ring_i
 			skb->data = (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
 
-			/* AK: check is wrong. 0 can be valid dma address */
-			if (!(rxdp3->Buffer0_ptr))
+			if (from_card_up) {
 				rxdp3->Buffer0_ptr =
 				   pci_map_single(ring->pdev, ba->ba_0,
 					BUF0_LEN, PCI_DMA_FROMDEVICE);
-			else
+				if (pci_dma_mapping_error(rxdp3->Buffer0_ptr))
+					goto pci_map_failed;
+			} else
 				pci_dma_sync_single_for_device(ring->pdev,
 				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(rxdp3->Buffer0_ptr))
-				goto pci_map_failed;
 
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (ring->rxd_mode == RXD_MODE_3B) {
@@ -2682,21 +2684,22 @@ static int fill_rx_buffers(struct ring_i
 				if (pci_dma_mapping_error(rxdp3->Buffer2_ptr))
 					goto pci_map_failed;
 
-				/* AK: check is wrong */
-				if (!rxdp3->Buffer1_ptr)
+				if (from_card_up) {
 					rxdp3->Buffer1_ptr =
 						pci_map_single(ring->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
 
-				if (pci_dma_mapping_error(rxdp3->Buffer1_ptr)) {
-					pci_unmap_single
-						(ring->pdev,
-						(dma_addr_t)(unsigned long)
-						skb->data,
-						ring->mtu + 4,
-						PCI_DMA_FROMDEVICE);
-					goto pci_map_failed;
+					if (pci_dma_mapping_error
+						(rxdp3->Buffer1_ptr)) {
+						pci_unmap_single
+							(ring->pdev,
+						    (dma_addr_t)(unsigned long)
+							skb->data,
+							ring->mtu + 4,
+							PCI_DMA_FROMDEVICE);
+						goto pci_map_failed;
+					}
 				}
 				rxdp->Control_2 |= SET_BUFFER1_SIZE_3(1);
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
@@ -2831,7 +2834,7 @@ static void free_rx_buffers(struct s2io_
 
 static int s2io_chk_rx_buffers(struct ring_info *ring)
 {
-	if (fill_rx_buffers(ring) == -ENOMEM) {
+	if (fill_rx_buffers(ring, 0) == -ENOMEM) {
 		DBG_PRINT(INFO_DBG, "%s:Out of memory", ring->dev->name);
 		DBG_PRINT(INFO_DBG, " in Rx Intr!!\n");
 	}
@@ -2962,7 +2965,7 @@ static void s2io_netpoll(struct net_devi
 		rx_intr_handler(&mac_control->rings[i], 0);
 
 	for (i = 0; i < config->rx_ring_num; i++) {
-		if (fill_rx_buffers(&mac_control->rings[i]) == -ENOMEM) {
+		if (fill_rx_buffers(&mac_control->rings[i], 0) == -ENOMEM) {
 			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
 			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
 			break;
@@ -7204,7 +7207,7 @@ static int s2io_card_up(struct s2io_nic 
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		mac_control->rings[i].mtu = dev->mtu;
-		ret = fill_rx_buffers(&mac_control->rings[i]);
+		ret = fill_rx_buffers(&mac_control->rings[i], 1);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
 				  dev->name);

