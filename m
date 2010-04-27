From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/7] e1000: use DMA API instead of PCI DMA
	functions
Date: Tue, 27 Apr 2010 16:08:45 -0700
Message-ID: <20100427230836.26173.59671.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:36386 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750883Ab0D0XJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:09:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   46 +++++++++------
 drivers/net/e1000/e1000_main.c    |  110 +++++++++++++++++++++----------------
 2 files changed, 88 insertions(+), 68 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c67e931..616b405 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -980,9 +980,10 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 	if (txdr->desc && txdr->buffer_info) {
 		for (i = 0; i < txdr->count; i++) {
 			if (txdr->buffer_info[i].dma)
-				pci_unmap_single(pdev, txdr->buffer_info[i].dma,
+				dma_unmap_single(&pdev->dev,
+						 txdr->buffer_info[i].dma,
 						 txdr->buffer_info[i].length,
-						 PCI_DMA_TODEVICE);
+						 DMA_TO_DEVICE);
 			if (txdr->buffer_info[i].skb)
 				dev_kfree_skb(txdr->buffer_info[i].skb);
 		}
@@ -991,20 +992,23 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 	if (rxdr->desc && rxdr->buffer_info) {
 		for (i = 0; i < rxdr->count; i++) {
 			if (rxdr->buffer_info[i].dma)
-				pci_unmap_single(pdev, rxdr->buffer_info[i].dma,
+				dma_unmap_single(&pdev->dev,
+						 rxdr->buffer_info[i].dma,
 						 rxdr->buffer_info[i].length,
-						 PCI_DMA_FROMDEVICE);
+						 DMA_FROM_DEVICE);
 			if (rxdr->buffer_info[i].skb)
 				dev_kfree_skb(rxdr->buffer_info[i].skb);
 		}
 	}
 
 	if (txdr->desc) {
-		pci_free_consistent(pdev, txdr->size, txdr->desc, txdr->dma);
+		dma_free_coherent(&pdev->dev, txdr->size, txdr->desc,
+				  txdr->dma);
 		txdr->desc = NULL;
 	}
 	if (rxdr->desc) {
-		pci_free_consistent(pdev, rxdr->size, rxdr->desc, rxdr->dma);
+		dma_free_coherent(&pdev->dev, rxdr->size, rxdr->desc,
+				  rxdr->dma);
 		rxdr->desc = NULL;
 	}
 
@@ -1039,7 +1043,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
-	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
+					GFP_KERNEL);
 	if (!txdr->desc) {
 		ret_val = 2;
 		goto err_nomem;
@@ -1070,8 +1075,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		txdr->buffer_info[i].skb = skb;
 		txdr->buffer_info[i].length = skb->len;
 		txdr->buffer_info[i].dma =
-			pci_map_single(pdev, skb->data, skb->len,
-				       PCI_DMA_TODEVICE);
+			dma_map_single(&pdev->dev, skb->data, skb->len,
+				       DMA_TO_DEVICE);
 		tx_desc->buffer_addr = cpu_to_le64(txdr->buffer_info[i].dma);
 		tx_desc->lower.data = cpu_to_le32(skb->len);
 		tx_desc->lower.data |= cpu_to_le32(E1000_TXD_CMD_EOP |
@@ -1093,7 +1098,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	}
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
-	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
+					GFP_KERNEL);
 	if (!rxdr->desc) {
 		ret_val = 5;
 		goto err_nomem;
@@ -1126,8 +1132,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		rxdr->buffer_info[i].skb = skb;
 		rxdr->buffer_info[i].length = E1000_RXBUFFER_2048;
 		rxdr->buffer_info[i].dma =
-			pci_map_single(pdev, skb->data, E1000_RXBUFFER_2048,
-				       PCI_DMA_FROMDEVICE);
+			dma_map_single(&pdev->dev, skb->data,
+				       E1000_RXBUFFER_2048, DMA_FROM_DEVICE);
 		rx_desc->buffer_addr = cpu_to_le64(rxdr->buffer_info[i].dma);
 		memset(skb->data, 0x00, skb->len);
 	}
@@ -1444,10 +1450,10 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 		for (i = 0; i < 64; i++) { /* send the packets */
 			e1000_create_lbtest_frame(txdr->buffer_info[i].skb,
 					1024);
-			pci_dma_sync_single_for_device(pdev,
-					txdr->buffer_info[k].dma,
-				    	txdr->buffer_info[k].length,
-				    	PCI_DMA_TODEVICE);
+			dma_sync_single_for_device(&pdev->dev,
+						   txdr->buffer_info[k].dma,
+						   txdr->buffer_info[k].length,
+						   DMA_TO_DEVICE);
 			if (unlikely(++k == txdr->count)) k = 0;
 		}
 		ew32(TDT, k);
@@ -1455,10 +1461,10 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 		time = jiffies; /* set the start time for the receive */
 		good_cnt = 0;
 		do { /* receive the sent packets */
-			pci_dma_sync_single_for_cpu(pdev,
-					rxdr->buffer_info[l].dma,
-				    	rxdr->buffer_info[l].length,
-				    	PCI_DMA_FROMDEVICE);
+			dma_sync_single_for_cpu(&pdev->dev,
+						rxdr->buffer_info[l].dma,
+						rxdr->buffer_info[l].length,
+						DMA_FROM_DEVICE);
 
 			ret_val = e1000_check_lbtest_frame(
 					rxdr->buffer_info[l].skb,
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 974a02d..0a56e7d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -823,13 +823,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		return err;
 
-	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
-	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
+	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
 		pci_using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
 		if (err) {
-			err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
+			err = dma_set_coherent_mask(&pdev->dev,
+						    DMA_BIT_MASK(32));
 			if (err) {
 				E1000_ERR("No usable DMA configuration, "
 					  "aborting\n");
@@ -1395,7 +1396,8 @@ static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
 
-	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
+					GFP_KERNEL);
 	if (!txdr->desc) {
 setup_tx_desc_die:
 		vfree(txdr->buffer_info);
@@ -1411,18 +1413,21 @@ setup_tx_desc_die:
 		DPRINTK(TX_ERR, ERR, "txdr align check failed: %u bytes "
 				     "at %p\n", txdr->size, txdr->desc);
 		/* Try again, without freeing the previous */
-		txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+		txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size,
+						&txdr->dma, GFP_KERNEL);
 		/* Failed allocation, critical failure */
 		if (!txdr->desc) {
-			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			dma_free_coherent(&pdev->dev, txdr->size, olddesc,
+					  olddma);
 			goto setup_tx_desc_die;
 		}
 
 		if (!e1000_check_64k_bound(adapter, txdr->desc, txdr->size)) {
 			/* give up */
-			pci_free_consistent(pdev, txdr->size, txdr->desc,
-					    txdr->dma);
-			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			dma_free_coherent(&pdev->dev, txdr->size, txdr->desc,
+					  txdr->dma);
+			dma_free_coherent(&pdev->dev, txdr->size, olddesc,
+					  olddma);
 			DPRINTK(PROBE, ERR,
 				"Unable to allocate aligned memory "
 				"for the transmit descriptor ring\n");
@@ -1430,7 +1435,8 @@ setup_tx_desc_die:
 			return -ENOMEM;
 		} else {
 			/* Free old allocation, new allocation was successful */
-			pci_free_consistent(pdev, txdr->size, olddesc, olddma);
+			dma_free_coherent(&pdev->dev, txdr->size, olddesc,
+					  olddma);
 		}
 	}
 	memset(txdr->desc, 0, txdr->size);
@@ -1590,7 +1596,8 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	rxdr->size = rxdr->count * desc_len;
 	rxdr->size = ALIGN(rxdr->size, 4096);
 
-	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
+					GFP_KERNEL);
 
 	if (!rxdr->desc) {
 		DPRINTK(PROBE, ERR,
@@ -1607,10 +1614,12 @@ setup_rx_desc_die:
 		DPRINTK(RX_ERR, ERR, "rxdr align check failed: %u bytes "
 				     "at %p\n", rxdr->size, rxdr->desc);
 		/* Try again, without freeing the previous */
-		rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+		rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size,
+						&rxdr->dma, GFP_KERNEL);
 		/* Failed allocation, critical failure */
 		if (!rxdr->desc) {
-			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
+					  olddma);
 			DPRINTK(PROBE, ERR,
 				"Unable to allocate memory "
 				"for the receive descriptor ring\n");
@@ -1619,16 +1628,18 @@ setup_rx_desc_die:
 
 		if (!e1000_check_64k_bound(adapter, rxdr->desc, rxdr->size)) {
 			/* give up */
-			pci_free_consistent(pdev, rxdr->size, rxdr->desc,
-					    rxdr->dma);
-			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			dma_free_coherent(&pdev->dev, rxdr->size, rxdr->desc,
+					  rxdr->dma);
+			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
+					  olddma);
 			DPRINTK(PROBE, ERR,
 				"Unable to allocate aligned memory "
 				"for the receive descriptor ring\n");
 			goto setup_rx_desc_die;
 		} else {
 			/* Free old allocation, new allocation was successful */
-			pci_free_consistent(pdev, rxdr->size, olddesc, olddma);
+			dma_free_coherent(&pdev->dev, rxdr->size, olddesc,
+					  olddma);
 		}
 	}
 	memset(rxdr->desc, 0, rxdr->size);
@@ -1804,7 +1815,8 @@ static void e1000_free_tx_resources(struct e1000_adapter *adapter,
 	vfree(tx_ring->buffer_info);
 	tx_ring->buffer_info = NULL;
 
-	pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
+	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
+			  tx_ring->dma);
 
 	tx_ring->desc = NULL;
 }
@@ -1829,12 +1841,12 @@ static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 {
 	if (buffer_info->dma) {
 		if (buffer_info->mapped_as_page)
-			pci_unmap_page(adapter->pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+			dma_unmap_page(&adapter->pdev->dev, buffer_info->dma,
+				       buffer_info->length, DMA_TO_DEVICE);
 		else
-			pci_unmap_single(adapter->pdev,	buffer_info->dma,
+			dma_unmap_single(&adapter->pdev->dev, buffer_info->dma,
 					 buffer_info->length,
-					 PCI_DMA_TODEVICE);
+					 DMA_TO_DEVICE);
 		buffer_info->dma = 0;
 	}
 	if (buffer_info->skb) {
@@ -1912,7 +1924,8 @@ static void e1000_free_rx_resources(struct e1000_adapter *adapter,
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
-	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
+	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
+			  rx_ring->dma);
 
 	rx_ring->desc = NULL;
 }
@@ -1952,14 +1965,14 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 		buffer_info = &rx_ring->buffer_info[i];
 		if (buffer_info->dma &&
 		    adapter->clean_rx == e1000_clean_rx_irq) {
-			pci_unmap_single(pdev, buffer_info->dma,
+			dma_unmap_single(&pdev->dev, buffer_info->dma,
 			                 buffer_info->length,
-			                 PCI_DMA_FROMDEVICE);
+					 DMA_FROM_DEVICE);
 		} else if (buffer_info->dma &&
 		           adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
-			pci_unmap_page(pdev, buffer_info->dma,
-			               buffer_info->length,
-			               PCI_DMA_FROMDEVICE);
+			dma_unmap_page(&pdev->dev, buffer_info->dma,
+				       buffer_info->length,
+				       DMA_FROM_DEVICE);
 		}
 
 		buffer_info->dma = 0;
@@ -2714,9 +2727,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
 		buffer_info->mapped_as_page = false;
-		buffer_info->dma = pci_map_single(pdev,	skb->data + offset,
-						  size,	PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, buffer_info->dma))
+		buffer_info->dma = dma_map_single(&pdev->dev,
+						  skb->data + offset,
+						  size,	DMA_TO_DEVICE);
+		if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 			goto dma_error;
 		buffer_info->next_to_watch = i;
 
@@ -2760,10 +2774,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->mapped_as_page = true;
-			buffer_info->dma = pci_map_page(pdev, frag->page,
+			buffer_info->dma = dma_map_page(&pdev->dev, frag->page,
 							offset,	size,
-							PCI_DMA_TODEVICE);
-			if (pci_dma_mapping_error(pdev, buffer_info->dma))
+							DMA_TO_DEVICE);
+			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
 			buffer_info->next_to_watch = i;
 
@@ -3634,8 +3648,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		cleaned = true;
 		cleaned_count++;
-		pci_unmap_page(pdev, buffer_info->dma, buffer_info->length,
-		               PCI_DMA_FROMDEVICE);
+		dma_unmap_page(&pdev->dev, buffer_info->dma,
+			       buffer_info->length, DMA_FROM_DEVICE);
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
@@ -3817,8 +3831,8 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		cleaned = true;
 		cleaned_count++;
-		pci_unmap_single(pdev, buffer_info->dma, buffer_info->length,
-		                 PCI_DMA_FROMDEVICE);
+		dma_unmap_single(&pdev->dev, buffer_info->dma,
+				 buffer_info->length, DMA_FROM_DEVICE);
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
@@ -3998,11 +4012,11 @@ check_page:
 		}
 
 		if (!buffer_info->dma) {
-			buffer_info->dma = pci_map_page(pdev,
+			buffer_info->dma = dma_map_page(&pdev->dev,
 			                                buffer_info->page, 0,
-			                                buffer_info->length,
-			                                PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(pdev, buffer_info->dma)) {
+							buffer_info->length,
+							DMA_FROM_DEVICE);
+			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
 				put_page(buffer_info->page);
 				dev_kfree_skb(skb);
 				buffer_info->page = NULL;
@@ -4098,11 +4112,11 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 map_skb:
-		buffer_info->dma = pci_map_single(pdev,
+		buffer_info->dma = dma_map_single(&pdev->dev,
 						  skb->data,
 						  buffer_info->length,
-						  PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(pdev, buffer_info->dma)) {
+						  DMA_FROM_DEVICE);
+		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
 			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
 			buffer_info->dma = 0;
@@ -4126,9 +4140,9 @@ map_skb:
 			dev_kfree_skb(skb);
 			buffer_info->skb = NULL;
 
-			pci_unmap_single(pdev, buffer_info->dma,
+			dma_unmap_single(&pdev->dev, buffer_info->dma,
 					 adapter->rx_buffer_len,
-					 PCI_DMA_FROMDEVICE);
+					 DMA_FROM_DEVICE);
 			buffer_info->dma = 0;
 
 			adapter->alloc_rx_buff_failed++;

