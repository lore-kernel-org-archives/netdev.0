From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/5] netxen: refactor tx dma mapping code
Date: Sun, 23 Aug 2009 11:35:11 -0700
Message-ID: <1251052513-27618-3-git-send-email-dhananjay@netxen.com>
References: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:19503 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S933658AbZHWSfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 14:35:13 -0400
In-Reply-To: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all tx skb mapping code into netxen_map_tx_skb().

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |  112 ++++++++++++++++++----------------
 1 files changed, 60 insertions(+), 52 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 0086574..f618e7c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1518,22 +1518,52 @@ netxen_tso_check(struct net_device *netdev,
 	barrier();
 }
 
-static void
-netxen_clean_tx_dma_mapping(struct pci_dev *pdev,
-		struct netxen_cmd_buffer *pbuf, int last)
+static int
+netxen_map_tx_skb(struct pci_dev *pdev,
+		struct sk_buff *skb, struct netxen_cmd_buffer *pbuf)
 {
-	int k;
-	struct netxen_skb_frag *buffrag;
+	struct netxen_skb_frag *nf;
+	struct skb_frag_struct *frag;
+	int i, nr_frags;
+	dma_addr_t map;
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	nf = &pbuf->frag_array[0];
+
+	map = pci_map_single(pdev, skb->data,
+			skb_headlen(skb), PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, map))
+		goto out_err;
 
-	buffrag = &pbuf->frag_array[0];
-	pci_unmap_single(pdev, buffrag->dma,
-			buffrag->length, PCI_DMA_TODEVICE);
+	nf->dma = map;
+	nf->length = skb_headlen(skb);
+
+	for (i = 0; i < nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		nf = &pbuf->frag_array[i+1];
+
+		map = pci_map_page(pdev, frag->page, frag->page_offset,
+				frag->size, PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, map))
+			goto unwind;
+
+		nf->dma = map;
+		nf->length = frag->size;
+	}
+
+	return 0;
 
-	for (k = 1; k < last; k++) {
-		buffrag = &pbuf->frag_array[k];
-		pci_unmap_page(pdev, buffrag->dma,
-			buffrag->length, PCI_DMA_TODEVICE);
+unwind:
+	while (i > 0) {
+		nf = &pbuf->frag_array[i];
+		pci_unmap_page(pdev, nf->dma, nf->length, PCI_DMA_TODEVICE);
 	}
+
+	nf = &pbuf->frag_array[0];
+	pci_unmap_single(pdev, nf->dma, skb_headlen(skb), PCI_DMA_TODEVICE);
+
+out_err:
+	return -ENOMEM;
 }
 
 static inline void
@@ -1548,17 +1578,14 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
-	struct skb_frag_struct *frag;
 	struct netxen_cmd_buffer *pbuf;
 	struct netxen_skb_frag *buffrag;
 	struct cmd_desc_type0 *hwdesc, *first_desc;
 	struct pci_dev *pdev;
-	dma_addr_t temp_dma;
 	int i, k;
-	unsigned long offset;
 
 	u32 producer;
-	int len, frag_count, no_of_desc;
+	int frag_count, no_of_desc;
 	u32 num_txd = tx_ring->num_desc;
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
@@ -1572,72 +1599,53 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	producer = tx_ring->producer;
+	pbuf = &tx_ring->cmd_buf_arr[producer];
 
 	pdev = adapter->pdev;
-	len = skb->len - skb->data_len;
 
-	temp_dma = pci_map_single(pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(pdev, temp_dma))
+	if (netxen_map_tx_skb(pdev, skb, pbuf))
 		goto drop_packet;
 
-	pbuf = &tx_ring->cmd_buf_arr[producer];
 	pbuf->skb = skb;
 	pbuf->frag_count = frag_count;
 
-	buffrag = &pbuf->frag_array[0];
-	buffrag->dma = temp_dma;
-	buffrag->length = len;
-
 	first_desc = hwdesc = &tx_ring->desc_head[producer];
 	netxen_clear_cmddesc((u64 *)hwdesc);
-	netxen_set_tx_frags_len(hwdesc, frag_count, skb->len);
-	netxen_set_tx_port(hwdesc, adapter->portnum);
 
-	hwdesc->buffer_length[0] = cpu_to_le16(len);
-	hwdesc->addr_buffer1 = cpu_to_le64(temp_dma);
+	netxen_set_tx_frags_len(first_desc, frag_count, skb->len);
+	netxen_set_tx_port(first_desc, adapter->portnum);
 
-	for (i = 1, k = 1; i < frag_count; i++, k++) {
+	for (i = 0; i < frag_count; i++) {
 
-		/* move to next desc. if there is a need */
-		if ((i & 0x3) == 0) {
-			k = 0;
+		k = i % 4;
+
+		if ((k == 0) && (i > 0)) {
+			/* move to next desc.*/
 			producer = get_next_index(producer, num_txd);
 			hwdesc = &tx_ring->desc_head[producer];
 			netxen_clear_cmddesc((u64 *)hwdesc);
-			pbuf = &tx_ring->cmd_buf_arr[producer];
-			pbuf->skb = NULL;
-		}
-		buffrag = &pbuf->frag_array[i];
-		frag = &skb_shinfo(skb)->frags[i - 1];
-		len = frag->size;
-		offset = frag->page_offset;
-
-		temp_dma = pci_map_page(pdev, frag->page, offset,
-					len, PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, temp_dma)) {
-			netxen_clean_tx_dma_mapping(pdev, pbuf, i);
-			goto drop_packet;
+			tx_ring->cmd_buf_arr[producer].skb = NULL;
 		}
 
-		buffrag->dma = temp_dma;
-		buffrag->length = len;
+		buffrag = &pbuf->frag_array[i];
 
-		hwdesc->buffer_length[k] = cpu_to_le16(len);
+		hwdesc->buffer_length[k] = cpu_to_le16(buffrag->length);
 		switch (k) {
 		case 0:
-			hwdesc->addr_buffer1 = cpu_to_le64(temp_dma);
+			hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
 			break;
 		case 1:
-			hwdesc->addr_buffer2 = cpu_to_le64(temp_dma);
+			hwdesc->addr_buffer2 = cpu_to_le64(buffrag->dma);
 			break;
 		case 2:
-			hwdesc->addr_buffer3 = cpu_to_le64(temp_dma);
+			hwdesc->addr_buffer3 = cpu_to_le64(buffrag->dma);
 			break;
 		case 3:
-			hwdesc->addr_buffer4 = cpu_to_le64(temp_dma);
+			hwdesc->addr_buffer4 = cpu_to_le64(buffrag->dma);
 			break;
 		}
 	}
+
 	tx_ring->producer = get_next_index(producer, num_txd);
 
 	netxen_tso_check(netdev, tx_ring, first_desc, skb);
-- 
1.6.0.2

