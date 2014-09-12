From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/11] e1000: add and use e1000_rx_buffer info for Rx
Date: Fri, 12 Sep 2014 05:33:48 -0700
Message-ID: <1410525231-19851-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49796 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754463AbaILMeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 08:34:06 -0400
In-Reply-To: <1410525231-19851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

e1000 uses the same metadata struct for Rx and Tx.  But Tx and Rx have
different requirements.

For Rx, we only need to store a buffer and a DMA address.

Follow-up patch will remove skb for Rx, bringing rx_buffer_info down
to 16 bytes on x86_64.

[ buffer_info is 48 bytes ]

Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h         |  8 +++++-
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  7 ++---
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 35 ++++++++++++------------
 3 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 10a0f22..81efe33 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -160,6 +160,12 @@ struct e1000_buffer {
 	u16 mapped_as_page;
 };
 
+struct e1000_rx_buffer {
+	struct sk_buff *skb;
+	dma_addr_t dma;
+	struct page *page;
+};
+
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
 	void *desc;
@@ -195,7 +201,7 @@ struct e1000_rx_ring {
 	/* next descriptor to check for DD status bit */
 	unsigned int next_to_clean;
 	/* array of buffer information structs */
-	struct e1000_buffer *buffer_info;
+	struct e1000_rx_buffer *buffer_info;
 	struct sk_buff *rx_skb_top;
 
 	/* cpu for rx queue */
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 9b50272..5ebc240 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -968,7 +968,7 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 			if (rxdr->buffer_info[i].dma)
 				dma_unmap_single(&pdev->dev,
 						 rxdr->buffer_info[i].dma,
-						 rxdr->buffer_info[i].length,
+						 E1000_RXBUFFER_2048,
 						 DMA_FROM_DEVICE);
 			if (rxdr->buffer_info[i].skb)
 				dev_kfree_skb(rxdr->buffer_info[i].skb);
@@ -1065,7 +1065,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!rxdr->count)
 		rxdr->count = E1000_DEFAULT_RXD;
 
-	rxdr->buffer_info = kcalloc(rxdr->count, sizeof(struct e1000_buffer),
+	rxdr->buffer_info = kcalloc(rxdr->count, sizeof(struct e1000_rx_buffer),
 				    GFP_KERNEL);
 	if (!rxdr->buffer_info) {
 		ret_val = 5;
@@ -1104,7 +1104,6 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		}
 		skb_reserve(skb, NET_IP_ALIGN);
 		rxdr->buffer_info[i].skb = skb;
-		rxdr->buffer_info[i].length = E1000_RXBUFFER_2048;
 		rxdr->buffer_info[i].dma =
 			dma_map_single(&pdev->dev, skb->data,
 				       E1000_RXBUFFER_2048, DMA_FROM_DEVICE);
@@ -1440,7 +1439,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 		do { /* receive the sent packets */
 			dma_sync_single_for_cpu(&pdev->dev,
 						rxdr->buffer_info[l].dma,
-						rxdr->buffer_info[l].length,
+						E1000_RXBUFFER_2048,
 						DMA_FROM_DEVICE);
 
 			ret_val = e1000_check_lbtest_frame(
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 79626ba..694db74 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1687,7 +1687,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	int size, desc_len;
 
-	size = sizeof(struct e1000_buffer) * rxdr->count;
+	size = sizeof(struct e1000_rx_buffer) * rxdr->count;
 	rxdr->buffer_info = vzalloc(size);
 	if (!rxdr->buffer_info)
 		return -ENOMEM;
@@ -2062,7 +2062,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 				struct e1000_rx_ring *rx_ring)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_buffer *buffer_info;
+	struct e1000_rx_buffer *buffer_info;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
 	unsigned int i;
@@ -2073,12 +2073,12 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 		if (buffer_info->dma &&
 		    adapter->clean_rx == e1000_clean_rx_irq) {
 			dma_unmap_single(&pdev->dev, buffer_info->dma,
-			                 buffer_info->length,
+					 adapter->rx_buffer_len,
 					 DMA_FROM_DEVICE);
 		} else if (buffer_info->dma &&
 		           adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
 			dma_unmap_page(&pdev->dev, buffer_info->dma,
-				       buffer_info->length,
+				       adapter->rx_buffer_len,
 				       DMA_FROM_DEVICE);
 		}
 
@@ -2099,7 +2099,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 		rx_ring->rx_skb_top = NULL;
 	}
 
-	size = sizeof(struct e1000_buffer) * rx_ring->count;
+	size = sizeof(struct e1000_rx_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
 
 	/* Zero out the descriptor ring */
@@ -3415,7 +3415,7 @@ rx_ring_summary:
 
 	for (i = 0; rx_ring->desc && (i < rx_ring->count); i++) {
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rx_ring, i);
-		struct e1000_buffer *buffer_info = &rx_ring->buffer_info[i];
+		struct e1000_rx_buffer *buffer_info = &rx_ring->buffer_info[i];
 		struct my_u { __le64 a; __le64 b; };
 		struct my_u *u = (struct my_u *)rx_desc;
 		const char *type;
@@ -3951,7 +3951,7 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 /**
  * e1000_consume_page - helper function
  **/
-static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
+static void e1000_consume_page(struct e1000_rx_buffer *bi, struct sk_buff *skb,
 			       u16 length)
 {
 	bi->page = NULL;
@@ -4104,7 +4104,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
-	struct e1000_buffer *buffer_info, *next_buffer;
+	struct e1000_rx_buffer *buffer_info, *next_buffer;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4137,7 +4137,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		cleaned = true;
 		cleaned_count++;
 		dma_unmap_page(&pdev->dev, buffer_info->dma,
-			       buffer_info->length, DMA_FROM_DEVICE);
+			       adapter->rx_buffer_len, DMA_FROM_DEVICE);
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
@@ -4273,7 +4273,7 @@ next_desc:
  * of reassembly being done in the stack
  */
 static struct sk_buff *e1000_copybreak(struct e1000_adapter *adapter,
-				       struct e1000_buffer *buffer_info,
+				       struct e1000_rx_buffer *buffer_info,
 				       u32 length, const void *data)
 {
 	struct sk_buff *skb;
@@ -4307,7 +4307,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
-	struct e1000_buffer *buffer_info, *next_buffer;
+	struct e1000_rx_buffer *buffer_info, *next_buffer;
 	u32 length;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4337,7 +4337,8 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			skb = buffer_info->skb;
 			buffer_info->skb = NULL;
 			dma_unmap_single(&pdev->dev, buffer_info->dma,
-					 buffer_info->length, DMA_FROM_DEVICE);
+					 adapter->rx_buffer_len,
+					 DMA_FROM_DEVICE);
 			buffer_info->dma = 0;
 		}
 
@@ -4443,7 +4444,7 @@ e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc;
-	struct e1000_buffer *buffer_info;
+	struct e1000_rx_buffer *buffer_info;
 	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int bufsz = 256 - 16 /*for skb_reserve */ ;
@@ -4466,7 +4467,6 @@ e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 		}
 
 		buffer_info->skb = skb;
-		buffer_info->length = adapter->rx_buffer_len;
 check_page:
 		/* allocate a new page if necessary */
 		if (!buffer_info->page) {
@@ -4480,7 +4480,7 @@ check_page:
 		if (!buffer_info->dma) {
 			buffer_info->dma = dma_map_page(&pdev->dev,
 							buffer_info->page, 0,
-							buffer_info->length,
+							PAGE_SIZE,
 							DMA_FROM_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
 				put_page(buffer_info->page);
@@ -4528,7 +4528,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc;
-	struct e1000_buffer *buffer_info;
+	struct e1000_rx_buffer *buffer_info;
 	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int bufsz = adapter->rx_buffer_len;
@@ -4576,10 +4576,9 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			dev_kfree_skb(oldskb);
 		}
 		buffer_info->skb = skb;
-		buffer_info->length = adapter->rx_buffer_len;
 		buffer_info->dma = dma_map_single(&pdev->dev,
 						  skb->data,
-						  buffer_info->length,
+						  adapter->rx_buffer_len,
 						  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
 			dev_kfree_skb(skb);
-- 
1.9.3
