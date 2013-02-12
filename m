From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH] atl1c: add error checking for pci_map_single functions
Date: Tue, 12 Feb 2013 08:44:40 +0800
Message-ID: <1360629880-9920-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<qca-linux-team@qca.qualcomm.com>, <nic-devel@qca.qualcomm.com>,
	<jwboyer@redhat.com>, xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

it is reported that code hit DMA-API errors on 3.8-rc6+,
(see https://bugzilla.redhat.com/show_bug.cgi?id=908436, and
     https://bugzilla.redhat.com/show_bug.cgi?id=908550)

this patch just adds error handler for
    pci_map_single and skb_frag_dma_map.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 71 ++++++++++++++++++++++---
 1 file changed, 64 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 571b514..8f33315 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -21,7 +21,7 @@
 
 #include "atl1c.h"
 
-#define ATL1C_DRV_VERSION "1.0.1.0-NAPI"
+#define ATL1C_DRV_VERSION "1.0.1.1-NAPI"
 char atl1c_driver_name[] = "atl1c";
 char atl1c_driver_version[] = ATL1C_DRV_VERSION;
 
@@ -1649,6 +1649,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 	u16 num_alloc = 0;
 	u16 rfd_next_to_use, next_next;
 	struct atl1c_rx_free_desc *rfd_desc;
+	dma_addr_t mapping;
 
 	next_next = rfd_next_to_use = rfd_ring->next_to_use;
 	if (++next_next == rfd_ring->count)
@@ -1675,9 +1676,18 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter)
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
-		buffer_info->dma = pci_map_single(pdev, vir_addr,
+		mapping = pci_map_single(pdev, vir_addr,
 						buffer_info->length,
 						PCI_DMA_FROMDEVICE);
+		if (unlikely(pci_dma_mapping_error(pdev, mapping))) {
+			dev_kfree_skb(skb);
+			buffer_info->skb = NULL;
+			buffer_info->length = 0;
+			ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
+			netif_warn(adapter, rx_err, adapter->netdev, "RX pci_map_single failed");
+			break;
+		}
+		buffer_info->dma = mapping;
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
 			ATL1C_PCIMAP_FROMDEVICE);
 		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
@@ -2012,7 +2022,29 @@ check_sum:
 	return 0;
 }
 
-static void atl1c_tx_map(struct atl1c_adapter *adapter,
+static void atl1c_tx_rollback(struct atl1c_adapter *adpt,
+			      struct atl1c_tpd_desc *first_tpd,
+			      enum atl1c_trans_queue type)
+{
+	struct atl1c_tpd_ring *tpd_ring = &adpt->tpd_ring[type];
+	struct atl1c_buffer *buffer_info;
+	struct atl1c_tpd_desc *tpd;
+	u16 first_index, index;
+
+	first_index = first_tpd - (struct atl1c_tpd_desc *)tpd_ring->desc;
+	index = first_index;
+	while (index != tpd_ring->next_to_use) {
+		tpd = ATL1C_TPD_DESC(tpd_ring, index);
+		buffer_info = &tpd_ring->buffer_info[index];
+		atl1c_clean_buffer(adpt->pdev, buffer_info, 0);
+		memset(tpd, 0, sizeof(struct atl1c_tpd_desc));
+		if (++index == tpd_ring->count)
+			index = 0;
+	}
+	tpd_ring->next_to_use = first_index;
+}
+
+static int atl1c_tx_map(struct atl1c_adapter *adapter,
 		      struct sk_buff *skb, struct atl1c_tpd_desc *tpd,
 			enum atl1c_trans_queue type)
 {
@@ -2037,7 +2069,10 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		buffer_info->length = map_len;
 		buffer_info->dma = pci_map_single(adapter->pdev,
 					skb->data, hdr_len, PCI_DMA_TODEVICE);
-		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
+		if (unlikely(pci_dma_mapping_error(adapter->pdev,
+						   buffer_info->dma)))
+			goto err_dma;
+
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
 			ATL1C_PCIMAP_TODEVICE);
 		mapped_len += map_len;
@@ -2059,6 +2094,10 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		buffer_info->dma =
 			pci_map_single(adapter->pdev, skb->data + mapped_len,
 					buffer_info->length, PCI_DMA_TODEVICE);
+		if (unlikely(pci_dma_mapping_error(adapter->pdev,
+						   buffer_info->dma)))
+			goto err_dma;
+
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
 			ATL1C_PCIMAP_TODEVICE);
@@ -2080,6 +2119,9 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 						    frag, 0,
 						    buffer_info->length,
 						    DMA_TO_DEVICE);
+		if (dma_mapping_error(&adapter->pdev->dev, buffer_info->dma))
+			goto err_dma;
+
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE,
 			ATL1C_PCIMAP_TODEVICE);
@@ -2092,6 +2134,13 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 	/* The last buffer info contain the skb address,
 	   so it will be free after unmap */
 	buffer_info->skb = skb;
+
+	return 0;
+
+err_dma:
+	buffer_info->dma = 0;
+	buffer_info->length = 0;
+	return -1;
 }
 
 static void atl1c_tx_queue(struct atl1c_adapter *adapter, struct sk_buff *skb,
@@ -2154,10 +2203,18 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 	if (skb_network_offset(skb) != ETH_HLEN)
 		tpd->word1 |= 1 << TPD_ETH_TYPE_SHIFT; /* Ethernet frame */
 
-	atl1c_tx_map(adapter, skb, tpd, type);
-	atl1c_tx_queue(adapter, skb, tpd, type);
+	if (atl1c_tx_map(adapter, skb, tpd, type) < 0) {
+		netif_info(adapter, tx_done, adapter->netdev,
+			   "tx-skb droppted due to dma error\n");
+		/* roll back tpd/buffer */
+		atl1c_tx_rollback(adapter, tpd, type);
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+		dev_kfree_skb(skb);
+	} else {
+		atl1c_tx_queue(adapter, skb, tpd, type);
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
+	}
 
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.11.7
