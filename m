From: <jie.yang@atheros.com>
Subject: [Patch net-next]atl1e:fix 2.6.31-git4 -- ATL1E 0000:03:00.0: DMA-API: device driver frees DMA
Date: Wed, 16 Sep 2009 14:21:53 +0800
Message-ID: <12530821133392-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <miles.lane@gmail.com>, <chris.snook@gmail.com>,
	<jcliburn@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755696AbZIPGW4@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 23:22:59 -0700
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[   25.059969] WARNING: at lib/dma-debug.c:816 check_unmap+0x383/0x55c()
[   25.059976] Hardware name: 1000HE
[   25.059984] ATL1E 0000:03:00.0: DMA-API: device driver frees DMA
    memory with wrong function [device address=0x0000000036b92802] 
    [size=90 bytes] [mapped as single] [unmapped as page]

use the wrong API when free dma. So when map dma use a flag to demostrate
whether it is 'pci_map_single' or 'pci_map_page'. When free the dma, check
the flags to select the right APIs('pci_unmap_single' or 'pci_unmap_page').
 
Signed-off-by: Jie Yang <jie.yang@atheros.com>
---
diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index ba48220..d63be5c 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -377,10 +377,19 @@ struct atl1e_hw {
  */
 struct atl1e_tx_buffer {
    struct sk_buff *skb;
+   unsigned long flags;
+#define ATL1E_TX_PCIMAP_SINGLE     0x0001
+#define ATL1E_TX_PCIMAP_PAGE       0x0002
+#define ATL1E_TX_PCIMAP_TYPE_MASK  0x3
    u16 length;
    dma_addr_t dma;
 };
 
+#define ATL1E_SET_PCIMAP_TYPE(tx_buff, type) do {      \
+   ((tx_buff)->flags) &= ~ATL1E_TX_PCIMAP_TYPE_MASK;   \
+   ((tx_buff)->flags) |= (type);               \
+   } while (0)
+
 struct atl1e_rx_page {
    dma_addr_t  dma;    /* receive rage DMA address */
    u8      *addr;   /* receive rage virtual address */
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 69b830f..955da73 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -635,7 +635,11 @@ static void atl1e_clean_tx_ring(struct atl1e_adapter *adapter)
    for (index = 0; index < ring_count; index++) {
        tx_buffer = &tx_ring->tx_buffer[index];
        if (tx_buffer->dma) {
-           pci_unmap_page(pdev, tx_buffer->dma,
+           if (tx_buffer->flags & ATL1E_TX_PCIMAP_SINGLE)
+               pci_unmap_single(pdev, tx_buffer->dma,
+                   tx_buffer->length, PCI_DMA_TODEVICE);
+           else if (tx_buffer->flags & ATL1E_TX_PCIMAP_PAGE)
+               pci_unmap_page(pdev, tx_buffer->dma,
                    tx_buffer->length, PCI_DMA_TODEVICE);
            tx_buffer->dma = 0;
        }
@@ -1220,7 +1224,11 @@ static bool atl1e_clean_tx_irq(struct atl1e_adapter *adapter)
    while (next_to_clean != hw_next_to_clean) {
        tx_buffer = &tx_ring->tx_buffer[next_to_clean];
        if (tx_buffer->dma) {
-           pci_unmap_page(adapter->pdev, tx_buffer->dma,
+           if (tx_buffer->flags & ATL1E_TX_PCIMAP_SINGLE)
+               pci_unmap_single(adapter->pdev, tx_buffer->dma,
+                   tx_buffer->length, PCI_DMA_TODEVICE);
+           else if (tx_buffer->flags & ATL1E_TX_PCIMAP_PAGE)
+               pci_unmap_page(adapter->pdev, tx_buffer->dma,
                    tx_buffer->length, PCI_DMA_TODEVICE);
            tx_buffer->dma = 0;
        }
@@ -1741,6 +1749,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
        tx_buffer->length = map_len;
        tx_buffer->dma = pci_map_single(adapter->pdev,
                    skb->data, hdr_len, PCI_DMA_TODEVICE);
+       ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_SINGLE);
        mapped_len += map_len;
        use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
        use_tpd->word2 = (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
@@ -1766,6 +1775,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
        tx_buffer->dma =
            pci_map_single(adapter->pdev, skb->data + mapped_len,
                    map_len, PCI_DMA_TODEVICE);
+       ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_SINGLE);
        mapped_len  += map_len;
        use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
        use_tpd->word2 = (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
@@ -1801,6 +1811,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
                        (i * MAX_TX_BUF_LEN),
                        tx_buffer->length,
                        PCI_DMA_TODEVICE);
+           ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_PAGE);
            use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
            use_tpd->word2 = (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
                    ((cpu_to_le32(tx_buffer->length) &
