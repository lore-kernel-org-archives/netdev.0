From: <jie.yang@atheros.com>
Subject: [PATCH net-next]atl1c:add pci map direction in atl1c_buffer flags
Date: Mon, 7 Dec 2009 16:56:59 +0800
Message-ID: <12601762192681-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:29299 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934763AbZLGI46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 03:56:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jie Yang <jie.yang@atheros.com>

add pci map direction in atl1c_buffer flags, it is used when call pci_unmap 
apis.
Signed-off-by: Jie Yang <jie.yang@atheros.com>
---

 drivers/net/atl1c/atl1c.h      |   11 ++++++++---
 drivers/net/atl1c/atl1c_main.c |   22 ++++++++++++++++------
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index a348a22..7e09084 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -479,6 +479,9 @@ struct atl1c_buffer {
 #define ATL1C_PCIMAP_PAGE		0x0008
 #define ATL1C_PCIMAP_TYPE_MASK		0x000C
 
+#define ATL1C_PCIMAP_TODEVICE		0x0010
+#define ATL1C_PCIMAP_FROMDEVICE		0x0020
+#define ATL1C_PCIMAP_DIRECTION_MASK	0x0030
 	dma_addr_t dma;
 };
 
@@ -487,9 +490,11 @@ struct atl1c_buffer {
 	((buff)->flags) |= (state);			\
 	} while (0)
 
-#define ATL1C_SET_PCIMAP_TYPE(buff, type) do {		\
-	((buff)->flags) &= ~ATL1C_PCIMAP_TYPE_MASK;	\
-	((buff)->flags) |= (type);			\
+#define ATL1C_SET_PCIMAP_TYPE(buff, type, direction) do {	\
+	((buff)->flags) &= ~ATL1C_PCIMAP_TYPE_MASK;		\
+	((buff)->flags) |= (type);				\
+	((buff)->flags) &= ~ATL1C_PCIMAP_DIRECTION_MASK;	\
+	((buff)->flags) |= (direction);				\
 	} while (0)
 
 /* transimit packet descriptor (tpd) ring */
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1e2f57d..1098dad 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -713,15 +713,21 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 static inline void atl1c_clean_buffer(struct pci_dev *pdev,
 				struct atl1c_buffer *buffer_info, int in_irq)
 {
+	u16 pci_driection;
 	if (buffer_info->flags & ATL1C_BUFFER_FREE)
 		return;
 	if (buffer_info->dma) {
+		if (buffer_info->flags & ATL1C_PCIMAP_FROMDEVICE)
+			pci_driection = PCI_DMA_FROMDEVICE;
+		else
+			pci_driection = PCI_DMA_TODEVICE;
+
 		if (buffer_info->flags & ATL1C_PCIMAP_SINGLE)
 			pci_unmap_single(pdev, buffer_info->dma,
-					buffer_info->length, PCI_DMA_TODEVICE);
+					buffer_info->length, pci_driection);
 		else if (buffer_info->flags & ATL1C_PCIMAP_PAGE)
 			pci_unmap_page(pdev, buffer_info->dma,
-					buffer_info->length, PCI_DMA_TODEVICE);
+					buffer_info->length, pci_driection);
 	}
 	if (buffer_info->skb) {
 		if (in_irq)
@@ -1606,7 +1612,8 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid
 		buffer_info->dma = pci_map_single(pdev, vir_addr,
 						buffer_info->length,
 						PCI_DMA_FROMDEVICE);
-		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
+			ATL1C_PCIMAP_FROMDEVICE);
 		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 		rfd_next_to_use = next_next;
 		if (++next_next == rfd_ring->count)
@@ -1967,7 +1974,8 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		buffer_info->dma = pci_map_single(adapter->pdev,
 					skb->data, hdr_len, PCI_DMA_TODEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
-		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
+			ATL1C_PCIMAP_TODEVICE);
 		mapped_len += map_len;
 		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
 		use_tpd->buffer_len = cpu_to_le16(buffer_info->length);
@@ -1988,7 +1996,8 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 			pci_map_single(adapter->pdev, skb->data + mapped_len,
 					buffer_info->length, PCI_DMA_TODEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
-		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE,
+			ATL1C_PCIMAP_TODEVICE);
 		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
 		use_tpd->buffer_len  = cpu_to_le16(buffer_info->length);
 	}
@@ -2009,7 +2018,8 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 					buffer_info->length,
 					PCI_DMA_TODEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
-		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE,
+			ATL1C_PCIMAP_TODEVICE);
 		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
 		use_tpd->buffer_len  = cpu_to_le16(buffer_info->length);
 	}
