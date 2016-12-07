From: Hassan Naveed <hassan.naveed@imgtec.com>
Subject: [PATCH] net: pch_gbe: Fix TX RX descriptor accesses for big endian systems
Date: Wed, 7 Dec 2016 09:58:54 -0800
Message-ID: <1481133534-26224-1-git-send-email-hassan.naveed@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Hassan Naveed <hassan.naveed@imgtec.com>,
        Paul Burton <paul.burton@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        =?UTF-8?q?fran=C3=A7ois=20romieu?= <romieu@fr.zoreil.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:22199 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbcLGSAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:00:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix pch_gbe driver for ethernet operations for a big endian CPU.
Values written to and read from transmit and receive descriptors
in the pch_gbe driver are byte swapped from the perspective of a
big endian CPU, since the ethernet controller always operates in
little endian mode. Rectify this by appropriately byte swapping
these descriptor field values in the driver software.

Signed-off-by: Hassan Naveed <hassan.naveed@imgtec.com>
Reviewed-by: Paul Burton <paul.burton@imgtec.com>
Reviewed-by: Matt Redfearn <matt.redfearn@imgtec.com>
Cc: Paul Burton <paul.burton@imgtec.com>
Cc: Matt Redfearn <matt.redfearn@imgtec.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Florian Westphal <fw@strlen.de>
Cc: françois romieu <romieu@fr.zoreil.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 66 ++++++++++++----------
 1 file changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index d1048dd..6937169 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1250,11 +1250,11 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 
 	/*-- Set Tx descriptor --*/
 	tx_desc = PCH_GBE_TX_DESC(*tx_ring, ring_num);
-	tx_desc->buffer_addr = (buffer_info->dma);
-	tx_desc->length = skb->len;
-	tx_desc->tx_words_eob = skb->len + 3;
-	tx_desc->tx_frame_ctrl = (frame_ctrl);
-	tx_desc->gbec_status = (DSC_INIT16);
+	tx_desc->buffer_addr = cpu_to_le32(buffer_info->dma);
+	tx_desc->length = cpu_to_le16(skb->len);
+	tx_desc->tx_words_eob = cpu_to_le16(skb->len + 3);
+	tx_desc->tx_frame_ctrl = cpu_to_le16(frame_ctrl);
+	tx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 
 	if (unlikely(++ring_num == tx_ring->count))
 		ring_num = 0;
@@ -1460,8 +1460,8 @@ static irqreturn_t pch_gbe_intr(int irq, void *data)
 		}
 		buffer_info->mapped = true;
 		rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
-		rx_desc->buffer_addr = (buffer_info->dma);
-		rx_desc->gbec_status = DSC_INIT16;
+		rx_desc->buffer_addr = cpu_to_le32(buffer_info->dma);
+		rx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 
 		netdev_dbg(netdev,
 			   "i = %d  buffer_info->dma = 0x08%llx  buffer_info->length = 0x%x\n",
@@ -1533,7 +1533,7 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 		skb_reserve(skb, PCH_GBE_DMA_ALIGN);
 		buffer_info->skb = skb;
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
-		tx_desc->gbec_status = (DSC_INIT16);
+		tx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 	}
 	return;
 }
@@ -1564,11 +1564,12 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 	i = tx_ring->next_to_clean;
 	tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
 	netdev_dbg(adapter->netdev, "gbec_status:0x%04x  dma_status:0x%04x\n",
-		   tx_desc->gbec_status, tx_desc->dma_status);
+		   le16_to_cpu(tx_desc->gbec_status), tx_desc->dma_status);
 
 	unused = PCH_GBE_DESC_UNUSED(tx_ring);
 	thresh = tx_ring->count - PCH_GBE_TX_WEIGHT;
-	if ((tx_desc->gbec_status == DSC_INIT16) && (unused < thresh))
+	if ((le16_to_cpu(tx_desc->gbec_status) == DSC_INIT16) &&
+		(unused < thresh))
 	{  /* current marked clean, tx queue filling up, do extra clean */
 		int j, k;
 		if (unused < 8) {  /* tx queue nearly full */
@@ -1583,47 +1584,49 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 		for (j = 0; j < PCH_GBE_TX_WEIGHT; j++)
 		{
 			tx_desc = PCH_GBE_TX_DESC(*tx_ring, k);
-			if (tx_desc->gbec_status != DSC_INIT16) break; /*found*/
+			if (le16_to_cpu(tx_desc->gbec_status) != DSC_INIT16)
+				break; /*found*/
 			if (++k >= tx_ring->count) k = 0;  /*increment, wrap*/
 		}
 		if (j < PCH_GBE_TX_WEIGHT) {
 			netdev_dbg(adapter->netdev,
 				   "clean_tx: unused=%d loops=%d found tx_desc[%x,%x:%x].gbec_status=%04x\n",
 				   unused, j, i, k, tx_ring->next_to_use,
-				   tx_desc->gbec_status);
+				   le16_to_cpu(tx_desc->gbec_status));
 			i = k;  /*found one to clean, usu gbec_status==2000.*/
 		}
 	}
 
-	while ((tx_desc->gbec_status & DSC_INIT16) == 0x0000) {
+	while ((cpu_to_le16(tx_desc->gbec_status) & DSC_INIT16) == 0x0000) {
 		netdev_dbg(adapter->netdev, "gbec_status:0x%04x\n",
-			   tx_desc->gbec_status);
+			   le16_to_cpu(tx_desc->gbec_status));
 		buffer_info = &tx_ring->buffer_info[i];
 		skb = buffer_info->skb;
 		cleaned = true;
 
-		if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_ABT)) {
+		if ((le16_to_cpu(tx_desc->gbec_status) &
+			PCH_GBE_TXD_GMAC_STAT_ABT)) {
 			adapter->stats.tx_aborted_errors++;
 			netdev_err(adapter->netdev, "Transfer Abort Error\n");
-		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CRSER)
-			  ) {
+		} else if ((le16_to_cpu(tx_desc->gbec_status) &
+				PCH_GBE_TXD_GMAC_STAT_CRSER)) {
 			adapter->stats.tx_carrier_errors++;
 			netdev_err(adapter->netdev,
 				   "Transfer Carrier Sense Error\n");
-		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_EXCOL)
-			  ) {
+		} else if ((le16_to_cpu(tx_desc->gbec_status) &
+					PCH_GBE_TXD_GMAC_STAT_EXCOL)) {
 			adapter->stats.tx_aborted_errors++;
 			netdev_err(adapter->netdev,
 				   "Transfer Collision Abort Error\n");
-		} else if ((tx_desc->gbec_status &
+		} else if ((le16_to_cpu(tx_desc->gbec_status) &
 			    (PCH_GBE_TXD_GMAC_STAT_SNGCOL |
 			     PCH_GBE_TXD_GMAC_STAT_MLTCOL))) {
 			adapter->stats.collisions++;
 			adapter->stats.tx_packets++;
 			adapter->stats.tx_bytes += skb->len;
 			netdev_dbg(adapter->netdev, "Transfer Collision\n");
-		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CMPLT)
-			  ) {
+		} else if ((le16_to_cpu(tx_desc->gbec_status) &
+				PCH_GBE_TXD_GMAC_STAT_CMPLT)) {
 			adapter->stats.tx_packets++;
 			adapter->stats.tx_bytes += skb->len;
 		}
@@ -1639,7 +1642,7 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 				   "trim buffer_info->skb : %d\n", i);
 			skb_trim(buffer_info->skb, 0);
 		}
-		tx_desc->gbec_status = DSC_INIT16;
+		tx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 		if (unlikely(++i == tx_ring->count))
 			i = 0;
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
@@ -1705,15 +1708,15 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 	while (*work_done < work_to_do) {
 		/* Check Rx descriptor status */
 		rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
-		if (rx_desc->gbec_status == DSC_INIT16)
+		if (le16_to_cpu(rx_desc->gbec_status) == DSC_INIT16)
 			break;
 		cleaned = true;
 		cleaned_count++;
 
 		dma_status = rx_desc->dma_status;
-		gbec_status = rx_desc->gbec_status;
-		tcp_ip_status = rx_desc->tcp_ip_status;
-		rx_desc->gbec_status = DSC_INIT16;
+		gbec_status = le16_to_cpu(rx_desc->gbec_status);
+		tcp_ip_status = le32_to_cpu(rx_desc->tcp_ip_status);
+		rx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 		buffer_info = &rx_ring->buffer_info[i];
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
@@ -1742,8 +1745,9 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
 		} else {
 			/* get receive length */
 			/* length convert[-3], length includes FCS length */
-			length = (rx_desc->rx_words_eob) - 3 - ETH_FCS_LEN;
-			if (rx_desc->rx_words_eob & 0x02)
+			length = le16_to_cpu(rx_desc->rx_words_eob) - 3 -
+					ETH_FCS_LEN;
+			if (le16_to_cpu(rx_desc->rx_words_eob) & 0x02)
 				length = length - 4;
 			/*
 			 * buffer_info->rx_buffer: [Header:14][payload]
@@ -1823,7 +1827,7 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 
 	for (desNo = 0; desNo < tx_ring->count; desNo++) {
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, desNo);
-		tx_desc->gbec_status = DSC_INIT16;
+		tx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 	}
 	netdev_dbg(adapter->netdev,
 		   "tx_ring->desc = 0x%p  tx_ring->dma = 0x%08llx next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
@@ -1864,7 +1868,7 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 	rx_ring->next_to_use = 0;
 	for (desNo = 0; desNo < rx_ring->count; desNo++) {
 		rx_desc = PCH_GBE_RX_DESC(*rx_ring, desNo);
-		rx_desc->gbec_status = DSC_INIT16;
+		rx_desc->gbec_status = cpu_to_le16(DSC_INIT16);
 	}
 	netdev_dbg(adapter->netdev,
 		   "rx_ring->desc = 0x%p  rx_ring->dma = 0x%08llx next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
-- 
1.9.1
