From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2 7/7] netxen: handle dma mapping failures
Date: Tue, 13 Jan 2009 11:52:44 -0800
Message-ID: <1231876364-866-8-git-send-email-dhananjay@netxen.com>
References: <1231876364-866-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:60181 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753452AbZAMTwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 14:52:49 -0500
In-Reply-To: <1231876364-866-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Bail out if pci_map_single() fails while replenishing rx ring.
o Drop packet if pci_map_{single,page}() fail in tx.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 -
 drivers/net/netxen/netxen_nic_init.c |   68 ++++++++++++++++------------------
 drivers/net/netxen/netxen_nic_main.c |   38 +++++++++++++++++-
 3 files changed, 67 insertions(+), 40 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6598a34..c11c568 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -860,7 +860,6 @@ struct nx_host_rds_ring {
 	u32 skb_size;
 	struct netxen_rx_buffer *rx_buf_arr;	/* rx buffers for receive   */
 	struct list_head free_list;
-	int begin_alloc;
 };
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index a320364..ca7c8d8 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -308,7 +308,6 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			}
 			memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
 			INIT_LIST_HEAD(&rds_ring->free_list);
-			rds_ring->begin_alloc = 0;
 			/*
 			 * Now go through all of them, set reference handles
 			 * and put them in the queues.
@@ -1435,7 +1434,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
 	int count = 0;
-	int index = 0;
 	netxen_ctx_msg msg = 0;
 	dma_addr_t dma;
 	struct list_head *head;
@@ -1443,7 +1441,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
-	index = rds_ring->begin_alloc;
 	head = &rds_ring->free_list;
 
 	/* We can start writing rx descriptors into the phantom memory. */
@@ -1451,39 +1448,37 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 
 		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
-			rds_ring->begin_alloc = index;
 			break;
 		}
 
+		if (!adapter->ahw.cut_through)
+			skb_reserve(skb, 2);
+
+		dma = pci_map_single(pdev, skb->data,
+				rds_ring->dma_size, PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(pdev, dma)) {
+			dev_kfree_skb_any(skb);
+			break;
+		}
+
+		count++;
 		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
 		list_del(&buffer->list);
 
-		count++;	/* now there should be no failure */
-		pdesc = &rds_ring->desc_head[producer];
-
-		if (!adapter->ahw.cut_through)
-			skb_reserve(skb, 2);
-		/* This will be setup when we receive the
-		 * buffer after it has been filled  FSL  TBD TBD
-		 * skb->dev = netdev;
-		 */
-		dma = pci_map_single(pdev, skb->data, rds_ring->dma_size,
-				     PCI_DMA_FROMDEVICE);
-		pdesc->addr_buffer = cpu_to_le64(dma);
 		buffer->skb = skb;
 		buffer->state = NETXEN_BUFFER_BUSY;
 		buffer->dma = dma;
+
 		/* make a rcv descriptor  */
+		pdesc = &rds_ring->desc_head[producer];
+		pdesc->addr_buffer = cpu_to_le64(dma);
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
-		DPRINTK(INFO, "done writing descripter\n");
-		producer =
-		    get_next_index(producer, rds_ring->max_rx_desc_count);
-		index = get_next_index(index, rds_ring->max_rx_desc_count);
+
+		producer = get_next_index(producer, rds_ring->max_rx_desc_count);
 	}
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
-		rds_ring->begin_alloc = index;
 		rds_ring->producer = producer;
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
@@ -1522,49 +1517,50 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
 	int count = 0;
-	int index = 0;
 	struct list_head *head;
+	dma_addr_t dma;
 
 	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
-	index = rds_ring->begin_alloc;
 	head = &rds_ring->free_list;
 	/* We can start writing rx descriptors into the phantom memory. */
 	while (!list_empty(head)) {
 
 		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
-			rds_ring->begin_alloc = index;
 			break;
 		}
 
+		if (!adapter->ahw.cut_through)
+			skb_reserve(skb, 2);
+
+		dma = pci_map_single(pdev, skb->data,
+				rds_ring->dma_size, PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(pdev, dma)) {
+			dev_kfree_skb_any(skb);
+			break;
+		}
+
+		count++;
 		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
 		list_del(&buffer->list);
 
-		count++;	/* now there should be no failure */
-		pdesc = &rds_ring->desc_head[producer];
-		if (!adapter->ahw.cut_through)
-			skb_reserve(skb, 2);
 		buffer->skb = skb;
 		buffer->state = NETXEN_BUFFER_BUSY;
-		buffer->dma = pci_map_single(pdev, skb->data,
-					     rds_ring->dma_size,
-					     PCI_DMA_FROMDEVICE);
+		buffer->dma = dma;
 
 		/* make a rcv descriptor  */
+		pdesc = &rds_ring->desc_head[producer];
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
-		producer =
-		    get_next_index(producer, rds_ring->max_rx_desc_count);
-		index = get_next_index(index, rds_ring->max_rx_desc_count);
-		buffer = &rds_ring->rx_buf_arr[index];
+
+		producer = get_next_index(producer, rds_ring->max_rx_desc_count);
 	}
 
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
-		rds_ring->begin_alloc = index;
 		rds_ring->producer = producer;
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9268fd2..8686740 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1200,6 +1200,24 @@ static bool netxen_tso_check(struct net_device *netdev,
 	return tso;
 }
 
+static void
+netxen_clean_tx_dma_mapping(struct pci_dev *pdev,
+		struct netxen_cmd_buffer *pbuf, int last)
+{
+	int k;
+	struct netxen_skb_frag *buffrag;
+
+	buffrag = &pbuf->frag_array[0];
+	pci_unmap_single(pdev, buffrag->dma,
+			buffrag->length, PCI_DMA_TODEVICE);
+
+	for (k = 1; k < last; k++) {
+		buffrag = &pbuf->frag_array[k];
+		pci_unmap_page(pdev, buffrag->dma,
+			buffrag->length, PCI_DMA_TODEVICE);
+	}
+}
+
 static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
@@ -1208,6 +1226,8 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct netxen_cmd_buffer *pbuf;
 	struct netxen_skb_frag *buffrag;
 	struct cmd_desc_type0 *hwdesc;
+	struct pci_dev *pdev = adapter->pdev;
+	dma_addr_t temp_dma;
 	int i, k;
 
 	u32 producer, consumer;
@@ -1240,8 +1260,12 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	pbuf->skb = skb;
 	pbuf->frag_count = frag_count;
 	buffrag = &pbuf->frag_array[0];
-	buffrag->dma = pci_map_single(adapter->pdev, skb->data, first_seg_len,
+	temp_dma = pci_map_single(pdev, skb->data, first_seg_len,
 				      PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, temp_dma))
+		goto drop_packet;
+
+	buffrag->dma = temp_dma;
 	buffrag->length = first_seg_len;
 	netxen_set_tx_frags_len(hwdesc, frag_count, skb->len);
 	netxen_set_tx_port(hwdesc, adapter->portnum);
@@ -1253,7 +1277,6 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		struct skb_frag_struct *frag;
 		int len, temp_len;
 		unsigned long offset;
-		dma_addr_t temp_dma;
 
 		/* move to next desc. if there is a need */
 		if ((i & 0x3) == 0) {
@@ -1269,8 +1292,12 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		offset = frag->page_offset;
 
 		temp_len = len;
-		temp_dma = pci_map_page(adapter->pdev, frag->page, offset,
+		temp_dma = pci_map_page(pdev, frag->page, offset,
 					len, PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, temp_dma)) {
+			netxen_clean_tx_dma_mapping(pdev, pbuf, i);
+			goto drop_packet;
+		}
 
 		buffrag++;
 		buffrag->dma = temp_dma;
@@ -1345,6 +1372,11 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	netdev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
+
+drop_packet:
+	adapter->stats.txdropped++;
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
 }
 
 static int netxen_nic_check_temp(struct netxen_adapter *adapter)
-- 
1.6.0.2

