From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] net: natsemi: ns83820: add checks for dma mapping error
Date: Sat, 22 Apr 2017 16:06:05 +0300
Message-ID: <1492866365-5422-1-git-send-email-khoroshilov@ispras.ru>
References: <20170417.151743.1779341653983811894.davem@davemloft.net>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:51976 "EHLO mail.ispras.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932448AbdDVNGc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Apr 2017 09:06:32 -0400
In-Reply-To: <20170417.151743.1779341653983811894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver does not check if mapping dma memory succeed.
The patch adds the checks and failure handling.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/natsemi/ns83820.c | 42 +++++++++++++++++++++++++++++++---
 1 file changed, 39 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 729095db3e08..dfc64e1e31f9 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -534,14 +534,19 @@ static inline int ns83820_add_rx_skb(struct ns83820 *dev, struct sk_buff *skb)
 		);
 #endif
 
+	buf = pci_map_single(dev->pci_dev, skb->data,
+			     REAL_RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(dev->pci_dev, buf)) {
+		kfree_skb(skb);
+		return 1;
+	}
+
 	sg = dev->rx_info.descs + (next_empty * DESC_SIZE);
 	BUG_ON(NULL != dev->rx_info.skbs[next_empty]);
 	dev->rx_info.skbs[next_empty] = skb;
 
 	dev->rx_info.next_empty = (next_empty + 1) % NR_RX_DESC;
 	cmdsts = REAL_RX_BUF_SIZE | CMDSTS_INTR;
-	buf = pci_map_single(dev->pci_dev, skb->data,
-			     REAL_RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 	build_rx_desc(dev, sg, 0, buf, cmdsts, 0);
 	/* update link of previous rx */
 	if (likely(next_empty != dev->rx_info.next_rx))
@@ -1068,6 +1073,7 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 	int stopped = 0;
 	int do_intr = 0;
 	volatile __le32 *first_desc;
+	volatile __le32 *desc;
 
 	dprintk("ns83820_hard_start_xmit\n");
 
@@ -1136,11 +1142,13 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 	if (nr_frags)
 		len -= skb->data_len;
 	buf = pci_map_single(dev->pci_dev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(dev->pci_dev, buf))
+		goto dma_error_first;
 
 	first_desc = dev->tx_descs + (free_idx * DESC_SIZE);
 
 	for (;;) {
-		volatile __le32 *desc = dev->tx_descs + (free_idx * DESC_SIZE);
+		desc = dev->tx_descs + (free_idx * DESC_SIZE);
 
 		dprintk("frag[%3u]: %4u @ 0x%08Lx\n", free_idx, len,
 			(unsigned long long)buf);
@@ -1160,6 +1168,8 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 
 		buf = skb_frag_dma_map(&dev->pci_dev->dev, frag, 0,
 				       skb_frag_size(frag), DMA_TO_DEVICE);
+		if (dma_mapping_error(&dev->pci_dev->dev, buf))
+			goto dma_error;
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
@@ -1183,6 +1193,32 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 		netif_start_queue(ndev);
 
 	return NETDEV_TX_OK;
+
+dma_error:
+	do {
+		free_idx = (free_idx + NR_TX_DESC - 1) % NR_TX_DESC;
+		desc = dev->tx_descs + (free_idx * DESC_SIZE);
+		cmdsts = le32_to_cpu(desc[DESC_CMDSTS]);
+		len = cmdsts & CMDSTS_LEN_MASK;
+		buf = desc_addr_get(desc + DESC_BUFPTR);
+		if (desc == first_desc)
+			pci_unmap_single(dev->pci_dev,
+					buf,
+					len,
+					PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(dev->pci_dev,
+					buf,
+					len,
+					PCI_DMA_TODEVICE);
+		desc[DESC_CMDSTS] = cpu_to_le32(0);
+		mb();
+	} while (desc != first_desc);
+
+dma_error_first:
+	dev_kfree_skb_any(skb);
+	ndev->stats.tx_errors++;
+	return NETDEV_TX_OK;
 }
 
 static void ns83820_update_stats(struct ns83820 *dev)
-- 
2.7.4
