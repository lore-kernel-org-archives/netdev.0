From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 10/13] qla3xxx: Check return code from pci_map_single() in ql_release_to_lrg_buf_free_list(), ql_populate_free_queue(), ql_alloc_large_buffers(), and ql3xxx_send()
Date: Mon, 26 Feb 2007 11:06:40 -0800
Message-ID: <11725168031319-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030469AbXBZTHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:46 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

pci_map_single() could fail.  We need to properly check the return
code from pci_map_single().  If we can not properly map this address,
then we should cleanup and return the proper return code.

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |  114 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 107 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index d2f4397..63522ea 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -276,7 +276,8 @@ static void ql_enable_interrupts(struct ql3_adapter *qdev)
 static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 					    struct ql_rcv_buf_cb *lrg_buf_cb)
 {
-	u64 map;
+	dma_addr_t map;
+	int err;
 	lrg_buf_cb->next = NULL;
 
 	if (qdev->lrg_buf_free_tail == NULL) {	/* The list is empty  */
@@ -304,6 +305,17 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 					     qdev->lrg_buffer_len -
 					     QL_HEADER_SPACE,
 					     PCI_DMA_FROMDEVICE);
+			err = pci_dma_mapping_error(map);
+			if(err) {
+				printk(KERN_ERR "%s: PCI mapping failed with error: %d\n", 
+				       qdev->ndev->name, err);
+				dev_kfree_skb(lrg_buf_cb->skb);
+				lrg_buf_cb->skb = NULL;
+
+				qdev->lrg_buf_skb_check++;
+				return;
+			}
+
 			lrg_buf_cb->buf_phy_addr_low =
 			    cpu_to_le32(LS_64BITS(map));
 			lrg_buf_cb->buf_phy_addr_high =
@@ -1642,7 +1654,8 @@ static const struct ethtool_ops ql3xxx_ethtool_ops = {
 static int ql_populate_free_queue(struct ql3_adapter *qdev)
 {
 	struct ql_rcv_buf_cb *lrg_buf_cb = qdev->lrg_buf_free_head;
-	u64 map;
+	dma_addr_t map;
+	int err;
 
 	while (lrg_buf_cb) {
 		if (!lrg_buf_cb->skb) {
@@ -1664,6 +1677,17 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 						     qdev->lrg_buffer_len -
 						     QL_HEADER_SPACE,
 						     PCI_DMA_FROMDEVICE);
+
+				err = pci_dma_mapping_error(map);
+				if(err) {
+					printk(KERN_ERR "%s: PCI mapping failed with error: %d\n", 
+					       qdev->ndev->name, err);
+					dev_kfree_skb(lrg_buf_cb->skb);
+					lrg_buf_cb->skb = NULL;
+					break;
+				}
+
+
 				lrg_buf_cb->buf_phy_addr_low =
 				    cpu_to_le32(LS_64BITS(map));
 				lrg_buf_cb->buf_phy_addr_high =
@@ -2165,7 +2189,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	struct oal *oal;
 	struct oal_entry *oal_entry;
 	int len = skb_headlen(skb);
-	u64 map;
+	dma_addr_t map;
+	int err;
+	int completed_segs, i;
 	int seg_cnt, seg = 0;
 	int frag_cnt = (int)skb_shinfo(skb)->nr_frags;
 
@@ -2178,6 +2204,15 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	 * Map the skb buffer first.
 	 */
 	map = pci_map_single(qdev->pdev, skb->data, len, PCI_DMA_TODEVICE);
+
+	err = pci_dma_mapping_error(map);
+	if(err) {
+		printk(KERN_ERR "%s: PCI mapping failed with error: %d\n", 
+		       qdev->ndev->name, err);
+
+		return NETDEV_TX_BUSY;
+	}
+	
 	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
 	oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 	oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
@@ -2191,10 +2226,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 		oal_entry->len =
 		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
 	} else {
-		int i;
 		oal = tx_cb->oal;
-		for (i=0; i<frag_cnt; i++,seg++) {
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		for (completed_segs=0; completed_segs<frag_cnt; completed_segs++,seg++) {
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[completed_segs];
 			oal_entry++;
 			if ((seg == 2 && seg_cnt > 3) ||	/* Check for continuation */
 			    (seg == 7 && seg_cnt > 8) ||	/* requirements. It's strange */
@@ -2204,6 +2238,15 @@ static int ql_send_map(struct ql3_adapter *qdev,
 				map = pci_map_single(qdev->pdev, oal,
 						     sizeof(struct oal),
 						     PCI_DMA_TODEVICE);
+
+				err = pci_dma_mapping_error(map);
+				if(err) {
+
+					printk(KERN_ERR "%s: PCI mapping outbound address list with error: %d\n", 
+					       qdev->ndev->name, err);
+					goto map_error;
+				}
+
 				oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 				oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
 				oal_entry->len =
@@ -2222,6 +2265,14 @@ static int ql_send_map(struct ql3_adapter *qdev,
 			    pci_map_page(qdev->pdev, frag->page,
 					 frag->page_offset, frag->size,
 					 PCI_DMA_TODEVICE);
+
+			err = pci_dma_mapping_error(map);
+			if(err) {
+				printk(KERN_ERR "%s: PCI mapping frags failed with error: %d\n", 
+				       qdev->ndev->name, err);
+				goto map_error;
+			}
+
 			oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 			oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
 			oal_entry->len = cpu_to_le32(frag->size);
@@ -2233,7 +2284,46 @@ static int ql_send_map(struct ql3_adapter *qdev,
 		oal_entry->len =
 		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
 	}
+
 	return NETDEV_TX_OK;
+
+map_error:
+	/* A PCI mapping failed and now we will need to back out
+	 * We need to traverse through the oal's and associated pages which 
+	 * have been mapped and now we must unmap them to clean up properly
+	 */
+	
+	seg = 1;
+	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
+	oal = tx_cb->oal;
+	for (i=0; i<completed_segs; i++,seg++) {
+		oal_entry++;
+
+		if((seg == 2 && seg_cnt > 3) ||        /* Check for continuation */
+		   (seg == 7 && seg_cnt > 8) ||        /* requirements. It's strange */
+		   (seg == 12 && seg_cnt > 13) ||      /* but necessary. */
+		   (seg == 17 && seg_cnt > 18)) {
+			pci_unmap_single(qdev->pdev,
+				pci_unmap_addr(&tx_cb->map[seg], mapaddr),
+				pci_unmap_len(&tx_cb->map[seg], maplen),
+				 PCI_DMA_TODEVICE);
+			oal++;
+			seg++;
+		}
+
+		pci_unmap_page(qdev->pdev,
+			       pci_unmap_addr(&tx_cb->map[seg], mapaddr),
+			       pci_unmap_len(&tx_cb->map[seg], maplen),
+			       PCI_DMA_TODEVICE);
+	}
+
+	pci_unmap_single(qdev->pdev,
+			 pci_unmap_addr(&tx_cb->map[0], mapaddr),
+			 pci_unmap_addr(&tx_cb->map[0], maplen),
+			 PCI_DMA_TODEVICE);
+
+	return NETDEV_TX_BUSY;
+
 }
 
 /*
@@ -2546,7 +2636,8 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 	int i;
 	struct ql_rcv_buf_cb *lrg_buf_cb;
 	struct sk_buff *skb;
-	u64 map;
+	dma_addr_t map;
+	int err;
 
 	for (i = 0; i < qdev->num_large_buffers; i++) {
 		skb = netdev_alloc_skb(qdev->ndev,
@@ -2576,6 +2667,15 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 					     qdev->lrg_buffer_len -
 					     QL_HEADER_SPACE,
 					     PCI_DMA_FROMDEVICE);
+
+			err = pci_dma_mapping_error(map);
+			if(err) {
+				printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
+				       qdev->ndev->name, err);
+				ql_free_large_buffers(qdev);
+				return -ENOMEM;
+			}
+
 			pci_unmap_addr_set(lrg_buf_cb, mapaddr, map);
 			pci_unmap_len_set(lrg_buf_cb, maplen,
 					  qdev->lrg_buffer_len -
-- 
1.5.0.rc4.16.g9e258

